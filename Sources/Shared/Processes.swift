import Darwin
import Foundation

/// Finds running Claude Code sessions directly from the process table, so sessions show up even
/// before (or without) their hooks firing, and vanish the moment their process exits.
enum ClaudeProcesses {
    struct Info { let pid: Int32; let project: String; var assistant = "claude" }

    private static let shells: Set<String> = ["sh", "bash", "zsh", "dash", "fish", "env"]

    static func name(_ pid: Int32) -> String {
        var buf = [CChar](repeating: 0, count: 1024)
        proc_name(pid, &buf, UInt32(buf.count))
        return String(cString: buf)
    }

    static func parent(_ pid: Int32) -> Int32? {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
        guard sysctl(&mib, 4, &info, &size, nil, 0) == 0, size > 0 else { return nil }
        let p = info.kp_eproc.e_ppid
        return p > 1 ? p : nil
    }

    /// The Claude Code process that ran this hook: the first ancestor that isn't a shell.
    static func hookOwner() -> Int32? {
        var pid = getppid()
        for _ in 0..<6 {
            if !shells.contains(name(pid)) { return pid }
            guard let p = parent(pid) else { return nil }
            pid = p
        }
        return nil
    }

    static func arguments(_ pid: Int32) -> [String] {
        var mib: [Int32] = [CTL_KERN, KERN_PROCARGS2, pid]
        var size = 0
        guard sysctl(&mib, 3, nil, &size, nil, 0) == 0, size > 4 else { return [] }
        var buf = [UInt8](repeating: 0, count: size)
        guard sysctl(&mib, 3, &buf, &size, nil, 0) == 0 else { return [] }
        let argc = buf.withUnsafeBytes { $0.load(as: Int32.self) }
        var i = 4
        while i < size && buf[i] != 0 { i += 1 }   // exec path
        while i < size && buf[i] == 0 { i += 1 }   // padding
        var args: [String] = []
        while args.count < argc && i < size {
            let start = i
            while i < size && buf[i] != 0 { i += 1 }
            args.append(String(decoding: buf[start..<i], as: UTF8.self))
            i += 1
        }
        return args
    }

    /// Total CPU time used by a process, in seconds.
    static func cpuSeconds(_ pid: Int32) -> Double? {
        var info = proc_taskinfo()
        let size = Int32(MemoryLayout<proc_taskinfo>.size)
        guard proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &info, size) == size else { return nil }
        var tb = mach_timebase_info_data_t()
        mach_timebase_info(&tb)
        let ticks = Double(info.pti_total_user + info.pti_total_system)
        return ticks * Double(tb.numer) / Double(tb.denom) / 1e9
    }

    static func cwd(_ pid: Int32) -> String? {
        var info = proc_vnodepathinfo()
        let size = Int32(MemoryLayout<proc_vnodepathinfo>.size)
        guard proc_pidinfo(pid, PROC_PIDVNODEPATHINFO, 0, &info, size) == size else { return nil }
        return withUnsafePointer(to: &info.pvi_cdir.vip_path) {
            $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXPATHLEN)) { String(cString: $0) }
        }
    }

    /// Interactive `claude` sessions (not `claude -p` one-shots, MCP servers or the Chrome bridge).
    static func running() -> [Info] {
        let count = proc_listallpids(nil, 0)
        guard count > 0 else { return [] }
        var pids = [Int32](repeating: 0, count: Int(count) + 64)
        let n = proc_listallpids(&pids, Int32(pids.count * MemoryLayout<Int32>.size))
        let me = getuid()
        var found: [Info] = []
        for pid in pids.prefix(Int(max(n, 0))) where pid > 0 {
            var info = kinfo_proc()
            var size = MemoryLayout<kinfo_proc>.stride
            var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
            guard sysctl(&mib, 4, &info, &size, nil, 0) == 0, info.kp_eproc.e_ucred.cr_uid == me else { continue }
            let args = arguments(pid)
            guard let first = args.first else { continue }
            let exe = (first as NSString).lastPathComponent
            let isClaude = exe == "claude" || args.contains { $0.hasSuffix("@anthropic-ai/claude-code/cli.js") }
            let isCodex = exe == "codex" || args.contains { $0.contains("@openai/codex") && $0.hasSuffix(".js") }
            guard isClaude || isCodex else { continue }
            let skip = ["-p", "--print", "--chrome-native-host", "mcp", "--version", "-v", "update", "doctor",
                        "exec", "login", "logout", "app-server", "mcp-server", "completion", "proto"]
            if args.dropFirst().contains(where: { skip.contains($0) }) { continue }
            let project = cwd(pid).map { ($0 as NSString).lastPathComponent } ?? ""
            found.append(Info(pid: pid, project: project, assistant: isCodex ? "codex" : "claude"))
        }
        // A claude launched by another claude (e.g. a nested tool) isn't a separate session.
        let ids = Set(found.map(\.pid))
        return found.filter { parent($0.pid).map { !ids.contains($0) } ?? true }.sorted { $0.pid < $1.pid }
    }
}
