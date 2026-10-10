import Foundation

/// Adds/removes the vader-hook entries in ~/.claude/settings.json, leaving everything else untouched.
enum HookInstaller {
    static let events = [
        "SessionStart", "SessionEnd", "UserPromptSubmit", "PreToolUse", "PostToolUse", "PostToolUseFailure",
        "PermissionRequest", "Notification", "Stop", "StopFailure", "SubagentStart", "SubagentStop",
    ]
    static let toolEvents: Set<String> = ["PreToolUse", "PostToolUse", "PostToolUseFailure", "PermissionRequest"]
    static let marker = "vader-hook"

    static var settingsURL: URL {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude/settings.json")
    }

    static var hookBinary: String {
        Bundle.main.bundleURL.appendingPathComponent("Contents/MacOS/vader-hook").path
    }

    private static func readSettings() throws -> [String: Any] {
        guard let data = try? Data(contentsOf: settingsURL), !data.isEmpty else { return [:] }
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "VaderClaude", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "settings.json is not a JSON object"])
        }
        return root
    }

    private static func writeSettings(_ root: [String: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .withoutEscapingSlashes])
        try data.write(to: settingsURL, options: .atomic)
    }

    private static func withoutOurs(_ groups: [[String: Any]]) -> [[String: Any]] {
        groups.compactMap { group in
            var g = group
            let hooks = (g["hooks"] as? [[String: Any]] ?? []).filter {
                !(($0["command"] as? String) ?? "").contains(marker)
            }
            if hooks.isEmpty { return nil }
            g["hooks"] = hooks
            return g
        }
    }

    static var isInstalled: Bool {
        guard let root = try? readSettings(), let hooks = root["hooks"] as? [String: Any] else { return false }
        return events.allSatisfy { e in
            let groups = hooks[e] as? [[String: Any]] ?? []
            return groups.contains { g in
                (g["hooks"] as? [[String: Any]] ?? []).contains {
                    (($0["command"] as? String) ?? "").contains(marker)
                }
            }
        }
    }

    static func install() throws {
        var root = try readSettings()
        let backup = settingsURL.appendingPathExtension("before-vader")
        if FileManager.default.fileExists(atPath: settingsURL.path), !FileManager.default.fileExists(atPath: backup.path) {
            try? FileManager.default.copyItem(at: settingsURL, to: backup)
        }
        var hooks = root["hooks"] as? [String: Any] ?? [:]
        for e in events {
            var groups = withoutOurs(hooks[e] as? [[String: Any]] ?? [])
            var group: [String: Any] = ["hooks": [["type": "command", "command": "\"\(hookBinary)\"", "timeout": 5]]]
            if toolEvents.contains(e) { group["matcher"] = "*" }
            groups.append(group)
            hooks[e] = groups
        }
        root["hooks"] = hooks
        try writeSettings(root)
    }

    static func uninstall() throws {
        var root = try readSettings()
        guard var hooks = root["hooks"] as? [String: Any] else { return }
        for e in events {
            let groups = withoutOurs(hooks[e] as? [[String: Any]] ?? [])
            hooks[e] = groups.isEmpty ? nil : groups
        }
        root["hooks"] = hooks.isEmpty ? nil : hooks
        try writeSettings(root)
    }

    // MARK: Other AIs (Codex, Qwen Code, Gemini CLI, Copilot CLI)
    //
    // All read Claude Code-style hook config: { "hooks": { Event: [ { matcher?, hooks: [ {type, command, timeout} ] } ] } }
    // (Copilot CLI uses flat entries: { "hooks": { Event: [ {type, bash, timeoutSec} ] } }). Our handler runs the same
    // hook binary with `--assistant <name>` so it knows which AI is calling, and `--event <name>` where the payload
    // doesn't say (or uses that AI's own event names, which the hook translates).

    struct OtherAI {
        let name: String            // "codex" / "qwen" / "gemini" / "copilot" — passed to the hook as --assistant
        let dir: URL                // ~/.codex, ~/.qwen, ~/.gemini, ~/.copilot
        let file: URL               // the file our hooks go in
        let events: [String]
        let toolEvents: Set<String> // events that take a matcher
        let matcherAll: String?     // how this AI spells "match every tool" (nil = omit the matcher)
        var shortTimeoutEvents: Set<String> = []
        var binaries: [String] = []  // if set, installed only when one of these commands exists (its dir alone isn't proof)
        var flat = false             // Copilot: entries are the handlers themselves, no nested "hooks" array
        var commandKey = "command"
        var timeoutKey = "timeout"
        var timeoutScale = 1         // Gemini wants milliseconds
        var passEvent = false        // add --event <Event> to each handler
        var name_: String? = nil     // handler "name" (lets the AI toggle it in /hooks)
        var eventAliases: [String: String] = [:]   // config key → event name to pass (Copilot's camelCase subagentStart)
        var ownFile = false          // the whole file is ours (deleted on uninstall when nothing else is left)
    }

    static let codex = OtherAI(
        name: "codex", dir: home(".codex"), file: home(".codex/hooks.json"),
        events: ["SessionStart", "SessionEnd", "UserPromptSubmit", "PreToolUse", "PostToolUse", "PermissionRequest",
                 "Stop", "Interrupt", "SubagentStart", "SubagentStop"],
        toolEvents: [], matcherAll: nil, shortTimeoutEvents: ["SessionEnd", "Interrupt"])   // these allow ≤ 3 s

    static let qwen = OtherAI(
        name: "qwen", dir: home(".qwen"), file: home(".qwen/settings.json"),
        events: ["SessionStart", "SessionEnd", "UserPromptSubmit", "PreToolUse", "PostToolUse", "PostToolUseFailure",
                 "PermissionRequest", "Notification", "Stop", "StopFailure", "SubagentStart", "SubagentStop"],
        toolEvents: ["PreToolUse", "PostToolUse", "PostToolUseFailure", "PermissionRequest"],
        matcherAll: ".*", name_: "clawd-wars")                                                // Qwen matchers are regexes

    /// Gemini CLI: its own event names (BeforeAgent, AfterTool…), translated by the hook. ~/.gemini is shared with
    /// Antigravity, so only a `gemini` command counts as installed.
    static let gemini = OtherAI(
        name: "gemini", dir: home(".gemini"), file: home(".gemini/settings.json"),
        events: ["SessionStart", "SessionEnd", "BeforeAgent", "AfterAgent", "BeforeTool", "AfterTool", "Notification"],
        toolEvents: ["BeforeTool", "AfterTool"], matcherAll: ".*",
        binaries: ["gemini"], timeoutScale: 1000, passEvent: true, name_: "clawd-wars")

    /// GitHub Copilot CLI: a file of our own in ~/.copilot/hooks. PascalCase event names select its Claude-compatible
    /// payloads (snake_case fields, Claude tool names); SubagentStart only exists as camelCase.
    static let copilot = OtherAI(
        name: "copilot", dir: home(".copilot"), file: home(".copilot/hooks/clawd-wars.json"),
        events: ["SessionStart", "SessionEnd", "UserPromptSubmit", "PreToolUse", "PostToolUse", "PostToolUseFailure",
                 "PermissionRequest", "Notification", "Stop", "subagentStart", "SubagentStop"],
        toolEvents: [], matcherAll: nil,
        binaries: ["copilot"], flat: true, commandKey: "bash", timeoutKey: "timeoutSec", passEvent: true,
        eventAliases: ["subagentStart": "SubagentStart"], ownFile: true)

    static let others = [codex, qwen, gemini, copilot]

    static func other(_ name: String) -> OtherAI? { others.first { $0.name == name } }

    /// Is Claude Code on this Mac? ~/.claude alone isn't proof: Clawd Wars keeps its own state in there.
    static var claudeAvailable: Bool {
        [".claude/projects", ".claude.json", ".claude/settings.json"].contains {
            FileManager.default.fileExists(atPath: home($0).path)
        }
    }

    /// Display name for an assistant id.
    static func displayName(_ assistant: String) -> String {
        switch assistant {
        case "codex": return "Codex"
        case "qwen": return "Qwen Code"
        case "gemini": return "Gemini CLI"
        case "copilot": return "Copilot CLI"
        default: return "Claude Code"
        }
    }

    /// What to do when this AI's session runs but our hook never reports.
    static func silentFix(_ assistant: String) -> String {
        switch assistant {
        case "codex": return "type /hooks in Codex and approve Clawd Wars"
        case "qwen": return "type /hooks in Qwen Code and make sure clawd-wars is enabled"
        case "gemini": return "type /hooks panel in Gemini CLI and make sure clawd-wars is enabled"
        case "copilot": return "check hooks aren't turned off (disableAllHooks) and restart Copilot CLI"
        default: return "type /hooks in Claude Code and check the Clawd Wars hooks are listed"
        }
    }

    private static func home(_ path: String) -> URL { FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(path) }

    /// Where command-line tools usually live. The app is launched by launchd with a bare PATH, so look ourselves.
    private static var binDirs: [String] {
        var dirs = ["/opt/homebrew/bin", "/usr/local/bin", "/usr/bin"]
            + [".local/bin", ".npm-global/bin", ".volta/bin", ".bun/bin", "Library/pnpm", ".yarn/bin", ".asdf/shims",
               ".local/share/mise/shims", ".npm/bin"].map { home($0).path }
        let nvm = home(".nvm/versions/node")
        if let versions = try? FileManager.default.contentsOfDirectory(atPath: nvm.path) {
            dirs += versions.map { nvm.appendingPathComponent($0).appendingPathComponent("bin").path }
        }
        return dirs
    }

    static func available(_ ai: OtherAI) -> Bool {
        guard ai.binaries.isEmpty else {
            return binDirs.contains { d in ai.binaries.contains { FileManager.default.isExecutableFile(atPath: d + "/" + $0) } }
        }
        return FileManager.default.fileExists(atPath: ai.dir.path)
    }

    private static func read(_ ai: OtherAI) throws -> [String: Any] {
        guard let data = try? Data(contentsOf: ai.file), !data.isEmpty else { return [:] }
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "ClawdWars", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "\(ai.file.path) is not a JSON object"])
        }
        return root
    }

    /// An entry (group or flat handler) is ours if any command in it runs our hook.
    private static func isOurs(_ entry: [String: Any]) -> Bool {
        let handlers = (entry["hooks"] as? [[String: Any]] ?? []) + [entry]
        return handlers.contains { h in ["command", "bash"].contains { ((h[$0] as? String) ?? "").contains(marker) } }
    }

    private static func withoutOurs(_ ai: OtherAI, _ entries: [[String: Any]]) -> [[String: Any]] {
        ai.flat ? entries.filter { !isOurs($0) } : withoutOurs(entries)
    }

    static func installed(_ ai: OtherAI) -> Bool {
        guard let root = try? read(ai), let hooks = root["hooks"] as? [String: Any] else { return false }
        return ai.events.allSatisfy { e in (hooks[e] as? [[String: Any]] ?? []).contains(where: isOurs) }
    }

    /// Adds our hook to every event, keeping everything else in the file (a backup is kept the first time).
    static func install(_ ai: OtherAI) throws {
        guard available(ai) else { return }
        var root = try read(ai)
        let backup = ai.file.appendingPathExtension("before-clawd-wars")
        if !ai.ownFile, FileManager.default.fileExists(atPath: ai.file.path), !FileManager.default.fileExists(atPath: backup.path) {
            try? FileManager.default.copyItem(at: ai.file, to: backup)
        }
        try FileManager.default.createDirectory(at: ai.file.deletingLastPathComponent(), withIntermediateDirectories: true)
        if ai.flat { root["version"] = 1 }
        var hooks = root["hooks"] as? [String: Any] ?? [:]
        for e in ai.events {
            var entries = withoutOurs(ai, hooks[e] as? [[String: Any]] ?? [])
            var command = "\"\(hookBinary)\" --assistant \(ai.name)"
            if ai.passEvent { command += " --event \(ai.eventAliases[e] ?? e)" }
            var handler: [String: Any] = ["type": "command", ai.commandKey: command,
                                          ai.timeoutKey: (ai.shortTimeoutEvents.contains(e) ? 3 : 5) * ai.timeoutScale]
            if let n = ai.name_ { handler["name"] = n }
            if ai.flat {
                entries.append(handler)
            } else {
                var group: [String: Any] = ["hooks": [handler]]
                if ai.toolEvents.contains(e), let all = ai.matcherAll { group["matcher"] = all }
                entries.append(group)
            }
            hooks[e] = entries
        }
        root["hooks"] = hooks
        let data = try JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .withoutEscapingSlashes])
        try data.write(to: ai.file, options: .atomic)
    }

    static func uninstall(_ ai: OtherAI) throws {
        guard FileManager.default.fileExists(atPath: ai.file.path) else { return }
        var root = try read(ai)
        guard var hooks = root["hooks"] as? [String: Any] else { return }
        for e in ai.events {
            let entries = withoutOurs(ai, hooks[e] as? [[String: Any]] ?? [])
            hooks[e] = entries.isEmpty ? nil : entries
        }
        if ai.ownFile && hooks.isEmpty {
            try FileManager.default.removeItem(at: ai.file)
            return
        }
        root["hooks"] = hooks.isEmpty ? nil : hooks
        let data = try JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .withoutEscapingSlashes])
        try data.write(to: ai.file, options: .atomic)
    }

    // Codex conveniences used by the app and CLI
    static var codexAvailable: Bool { available(codex) }
    static var codexInstalled: Bool { installed(codex) }
    static func installCodex() throws { try install(codex) }
    static func uninstallCodex() throws { try uninstall(codex) }
}
