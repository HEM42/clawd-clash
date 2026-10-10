import AppKit
import ApplicationServices

/// Brings the terminal or editor hosting a Claude session to the front.
/// - Terminal.app / iTerm2: selects the exact tab by its tty.
/// - Anything else (VS Code, Cursor, …): raises the window whose title names the session's project
///   (needs Accessibility permission; without it, the app is just activated).
enum Jump {
    /// Set by the `--jump=` diagnostic to trace each step.
    static var log: ((String) -> Void)?

    static func toSession(pid: Int32) {
        guard let app = hostApp(of: pid) else { log?("no host app for \(pid)"); NSSound.beep(); return }
        log?("host \(app.bundleIdentifier ?? "?") pid \(app.processIdentifier); cwd \(ClaudeProcesses.cwd(pid) ?? "?")")
        let tty = ttyPath(pid)

        switch app.bundleIdentifier {
        case "com.apple.Terminal":
            if let tty, run(terminalScript(tty)) { return }
        case "com.googlecode.iterm2":
            if let tty, run(iTermScript(tty)) { return }
        default:
            break
        }
        let cwd = ClaudeProcesses.cwd(pid) ?? ""
        let folders = cwd.split(separator: "/").map(String.init)
            .filter { !["Users", "Volumes", NSUserName()].contains($0) }
        log?("folders (deepest first): \(Array(folders.reversed()))")
        raiseWindow(of: app, matching: folders.reversed(), cwd: cwd)
    }

    private static var hostCache: [Int32: pid_t] = [:]

    /// Which of these sessions is the one you're looking at: its host app is frontmost and, when several
    /// sessions share that app (VS Code windows or native tabs), the focused window's title names its project.
    static func focusedSession(among sessions: [(pid: Int32, project: String)]) -> Int32? {
        guard let front = NSWorkspace.shared.frontmostApplication else { return nil }
        let inFront = sessions.filter { s in
            if let host = hostCache[s.pid] { return host == front.processIdentifier }
            guard let app = hostApp(of: s.pid) else { return false }
            hostCache[s.pid] = app.processIdentifier
            return app.processIdentifier == front.processIdentifier
        }
        if inFront.count <= 1 { return inFront.first?.pid }
        guard AXIsProcessTrusted() else { return nil }
        let axApp = AXUIElementCreateApplication(front.processIdentifier)
        guard let window = attribute(axApp, kAXFocusedWindowAttribute) else { return nil }
        let parts = titleParts(attribute(window as! AXUIElement, kAXTitleAttribute) as? String)
        return inFront.first { parts.contains($0.project) }?.pid
    }

    /// First GUI app up the process tree (e.g. Code Helper → Visual Studio Code).
    private static func hostApp(of pid: Int32) -> NSRunningApplication? {
        var current: Int32? = pid
        for _ in 0..<12 {
            guard let p = current else { return nil }
            if let app = NSRunningApplication(processIdentifier: p), app.activationPolicy == .regular { return app }
            current = ClaudeProcesses.parent(p)
        }
        return nil
    }

    private static func ttyPath(_ pid: Int32) -> String? {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
        guard sysctl(&mib, 4, &info, &size, nil, 0) == 0 else { return nil }
        let dev = info.kp_eproc.e_tdev
        guard dev != -1, let name = devname(dev, S_IFCHR) else { return nil }
        return "/dev/" + String(cString: name)
    }

    private static func raiseWindow(of app: NSRunningApplication, matching folders: [String], cwd: String) {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        guard AXIsProcessTrustedWithOptions(options) else { log?("not trusted"); activate(app); return }

        let axApp = AXUIElementCreateApplication(app.processIdentifier)
        let windows = (attribute(axApp, kAXWindowsAttribute) as? [AXUIElement]) ?? []

        // Native window tabs (e.g. VS Code with "window.nativeTabs"): every project is a tab in a shared
        // window, and only the selected tab's title is the window title.
        var tabs: [(tab: AXUIElement, window: AXUIElement, parts: [String])] = []
        for w in windows {
            for group in descendants(of: w, role: kAXTabGroupRole, depth: 3) {
                for tab in (attribute(group, kAXChildrenAttribute) as? [AXUIElement]) ?? []
                where (attribute(tab, kAXRoleAttribute) as? String) == kAXRadioButtonRole {
                    tabs.append((tab, w, titleParts(attribute(tab, kAXTitleAttribute) as? String)))
                }
            }
        }
        let titled = windows.map { ($0, titleParts(attribute($0, kAXTitleAttribute) as? String)) }
        log?("windows: \(titled.map(\.1)); tabs: \(tabs.map(\.parts))")

        // Deepest folder first, exact title segment before substring match.
        for folder in folders {
            if let hit = tabs.first(where: { $0.parts.contains(folder) })
                ?? tabs.first(where: { $0.parts.contains { $0.contains(folder) } }) {
                selectTab(hit.tab, window: hit.window, app: app, axApp: axApp, folder: folder, cwd: cwd)
                return
            }
            if let hit = titled.first(where: { $0.1.contains(folder) })
                ?? titled.first(where: { $0.1.contains { $0.contains(folder) } }) {
                bringForward(hit.0, in: axApp)
                activate(app)
                return
            }
        }
        activate(app)
    }

    /// Electron apps ignore AXPress on a native tab while they're in the background, so: bring the app
    /// forward, press the tab, and if the window still shows another project, ask the app to open that
    /// project folder — which, because it's already open in that tab, just focuses the tab.
    private static func selectTab(_ tab: AXUIElement, window: AXUIElement, app: NSRunningApplication,
                                  axApp: AXUIElement, folder: String, cwd: String) {
        func selected() -> Bool { titleParts(attribute(window, kAXTitleAttribute) as? String).contains(folder) }
        activate(app)
        AXUIElementSetAttributeValue(axApp, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            let r = AXUIElementPerformAction(tab, kAXPressAction as CFString)
            log?("pressed tab \(folder) after activating → \(r.rawValue)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if selected() { log?("tab selected via AX"); bringForward(window, in: axApp); return }
                // Fall back: reopen the folder (only the exact folder whose name is an open tab's title).
                guard let range = cwd.range(of: "/" + folder), let appURL = app.bundleURL else { return }
                let path = String(cwd[..<range.upperBound])
                log?("AX press ignored; opening \(path) in \(appURL.lastPathComponent)")
                let config = NSWorkspace.OpenConfiguration()
                config.activates = true
                NSWorkspace.shared.open([URL(fileURLWithPath: path)], withApplicationAt: appURL, configuration: config)
            }
        }
    }

    private static func bringForward(_ window: AXUIElement, in app: AXUIElement) {
        AXUIElementPerformAction(window, kAXRaiseAction as CFString)
        AXUIElementSetAttributeValue(window, kAXMainAttribute as CFString, kCFBooleanTrue)
        AXUIElementSetAttributeValue(app, kAXFrontmostAttribute as CFString, kCFBooleanTrue)
    }

    /// VS Code-style titles: "file.swift — project — Visual Studio Code" → ["file.swift", "project", "Visual Studio Code"]
    private static func titleParts(_ title: String?) -> [String] {
        (title ?? "").components(separatedBy: " — ").flatMap { $0.components(separatedBy: " - ") }
            .map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    private static func attribute(_ el: AXUIElement, _ name: String) -> CFTypeRef? {
        var v: CFTypeRef?
        return AXUIElementCopyAttributeValue(el, name as CFString, &v) == .success ? v : nil
    }

    private static func descendants(of el: AXUIElement, role: String, depth: Int) -> [AXUIElement] {
        guard depth > 0 else { return [] }
        var found: [AXUIElement] = []
        for child in (attribute(el, kAXChildrenAttribute) as? [AXUIElement]) ?? [] {
            if (attribute(child, kAXRoleAttribute) as? String) == role { found.append(child) }
            found += descendants(of: child, role: role, depth: depth - 1)
        }
        return found
    }

    /// Diagnostics (`--ax-dump=<pid> <file>`): what the Accessibility API exposes for the app hosting a session.
    static func dump(pid: Int32) -> String {
        var out = "trusted: \(AXIsProcessTrusted())\n"
        guard let app = hostApp(of: pid) else { return out + "no host app\n" }
        out += "host: \(app.localizedName ?? "?") \(app.bundleIdentifier ?? "")\n"
        out += "cwd: \(ClaudeProcesses.cwd(pid) ?? "?")\n"
        let axApp = AXUIElementCreateApplication(app.processIdentifier)
        for w in (attribute(axApp, kAXWindowsAttribute) as? [AXUIElement]) ?? [] {
            out += "window: \(attribute(w, kAXTitleAttribute) as? String ?? "?")\n"
            for group in descendants(of: w, role: kAXTabGroupRole, depth: 3) {
                for tab in (attribute(group, kAXChildrenAttribute) as? [AXUIElement]) ?? [] {
                    out += "   tab [\(attribute(tab, kAXRoleAttribute) as? String ?? "?")]: \(attribute(tab, kAXTitleAttribute) as? String ?? "?")\n"
                }
            }
        }
        return out
    }

    private static func activate(_ app: NSRunningApplication) {
        guard let url = app.bundleURL else { app.activate(); return }
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        NSWorkspace.shared.openApplication(at: url, configuration: config)
    }

    private static func run(_ source: String) -> Bool {
        var error: NSDictionary?
        let result = NSAppleScript(source: source)?.executeAndReturnError(&error)
        return error == nil && result?.booleanValue == true
    }

    private static func terminalScript(_ tty: String) -> String {
        """
        tell application "Terminal"
            repeat with w in windows
                repeat with t in tabs of w
                    if tty of t is "\(tty)" then
                        set selected of t to true
                        set index of w to 1
                        activate
                        return true
                    end if
                end repeat
            end repeat
        end tell
        return false
        """
    }

    private static func iTermScript(_ tty: String) -> String {
        """
        tell application "iTerm2"
            repeat with w in windows
                repeat with t in tabs of w
                    repeat with s in sessions of t
                        if tty of s is "\(tty)" then
                            select w
                            tell t to select
                            tell s to select
                            activate
                            return true
                        end if
                    end repeat
                end repeat
            end repeat
        end tell
        return false
        """
    }
}
