import AppKit

let args = CommandLine.arguments

if args.contains("--install-hooks") || args.contains("--uninstall-hooks") {
    // Each AI on its own: one that fails doesn't stop the others, and every failure is reported.
    let errors: [String]
    if args.contains("--install-hooks") {
        let result = HookInstaller.installAll()
        for name in result.installed {
            let file = HookInstaller.other(name)?.file.path ?? HookInstaller.settingsURL.path
            print("Installed \(HookInstaller.displayName(name)) hooks → \(file)"
                  + (name == "codex" ? " (trust them once: run /hooks in Codex and approve)" : ""))
        }
        if !HookInstaller.claudeAvailable { print("Claude Code isn't installed: skipped it") }
        errors = result.errors
    } else {
        let result = HookInstaller.uninstallAll()
        // `brew upgrade` runs this too: the next launch puts back exactly what was removed here.
        HookInstaller.rememberRemoved(result.removed)
        print(result.removed.isEmpty ? "No Clawd Wars hooks were installed"
              : "Removed the Clawd Wars hooks from " + result.removed.map(HookInstaller.displayName).joined(separator: ", "))
        errors = result.errors
    }
    for e in errors { FileHandle.standardError.write("Error: \(e)\n".data(using: .utf8)!) }
    exit(errors.isEmpty ? 0 : 1)
}

if let arg = args.first(where: { $0.hasPrefix("--jump=") }), let pid = Int32(arg.dropFirst(7)) {
    var lines: [String] = []
    Jump.log = { lines.append($0) }
    Jump.toSession(pid: pid)
    RunLoop.main.run(until: Date().addingTimeInterval(2.5))
    lines.append("frontmost after: \(NSWorkspace.shared.frontmostApplication?.localizedName ?? "?")")
    try? lines.joined(separator: "\n").write(toFile: args.last!, atomically: true, encoding: .utf8)
    exit(0)
}

if let arg = args.first(where: { $0.hasPrefix("--ax-dump=") }), let pid = Int32(arg.dropFirst(10)) {
    let report = Jump.dump(pid: pid)
    if let out = args.last, out != arg { try? report.write(toFile: out, atomically: true, encoding: .utf8) } else { print(report) }
    exit(0)
}

// Only one Clawd Wars at a time.
if let id = Bundle.main.bundleIdentifier,
   NSRunningApplication.runningApplications(withBundleIdentifier: id).count > 1 {
    exit(0)
}

// Hooks taken out by a Homebrew upgrade (see `HookInstaller.rememberRemoved`) go back in, quietly. Only on a
// normal launch: test and screenshot runs (--playground, --chaos…) may be a dev copy that shouldn't take the hooks.
if !args.dropFirst().contains(where: { $0.hasPrefix("--") }), ProcessInfo.processInfo.environment["CLAWD_SHOT"] == nil {
    let restored = HookInstaller.restoreRemoved()
    if !restored.installed.isEmpty { NSLog("Clawd Wars: reconnected \(restored.installed.joined(separator: ", ")) after an upgrade") }
    for e in restored.errors { NSLog("Clawd Wars: couldn't reconnect hooks: \(e)") }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let controller = OverlayController()
app.delegate = controller
app.run()
