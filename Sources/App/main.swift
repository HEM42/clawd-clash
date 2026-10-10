import AppKit

let args = CommandLine.arguments

if args.contains("--install-hooks") || args.contains("--uninstall-hooks") {
    do {
        if args.contains("--install-hooks") {
            try HookInstaller.install()
            print("Installed Claude Code hooks → \(HookInstaller.hookBinary)")
            for ai in HookInstaller.others where HookInstaller.available(ai) {
                try HookInstaller.install(ai)
                print("Installed \(ai.name.capitalized) hooks → \(ai.file.path)"
                      + (ai.name == "codex" ? " (trust them once: run /hooks in Codex and approve)" : ""))
            }
        } else {
            try HookInstaller.uninstall()
            for ai in HookInstaller.others { try HookInstaller.uninstall(ai) }
            print("Removed the Claude Code, Codex and Qwen hooks")
        }
        exit(0)
    } catch {
        FileHandle.standardError.write("Error: \(error.localizedDescription)\n".data(using: .utf8)!)
        exit(1)
    }
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

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let controller = OverlayController()
app.delegate = controller
app.run()
