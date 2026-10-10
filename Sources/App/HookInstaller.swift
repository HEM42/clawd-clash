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

    // MARK: Other AIs (Codex, Qwen Code)
    //
    // Both read Claude Code-style hook config: { "hooks": { Event: [ { matcher?, hooks: [ {type, command, timeout} ] } ] } }.
    // Our handler runs the same hook binary with `--assistant <name>` so it knows which AI is calling.

    struct OtherAI {
        let name: String            // "codex" / "qwen" — passed to the hook as --assistant
        let dir: URL                // ~/.codex, ~/.qwen
        let file: URL               // hooks.json / settings.json
        let events: [String]
        let toolEvents: Set<String> // events that take a matcher
        let matcherAll: String?     // how this AI spells "match every tool" (nil = omit the matcher)
        let shortTimeoutEvents: Set<String>
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
        matcherAll: ".*", shortTimeoutEvents: [])                                              // Qwen matchers are regexes

    static let others = [codex, qwen]

    /// Is Claude Code on this Mac? ~/.claude alone isn't proof: Clawd Wars keeps its own state in there.
    static var claudeAvailable: Bool {
        [".claude/projects", ".claude.json", ".claude/settings.json"].contains {
            FileManager.default.fileExists(atPath: home($0).path)
        }
    }

    /// Display name for an assistant id ("claude", "codex", "qwen").
    static func displayName(_ assistant: String) -> String {
        switch assistant { case "codex": return "Codex"; case "qwen": return "Qwen Code"; default: return "Claude Code" }
    }

    /// What to do when this AI's session runs but our hook never reports.
    static func silentFix(_ assistant: String) -> String {
        switch assistant {
        case "codex": return "type /hooks in Codex and approve Clawd Wars"
        case "qwen": return "type /hooks in Qwen Code and make sure clawd-wars is enabled"
        default: return "type /hooks in Claude Code and check the Clawd Wars hooks are listed"
        }
    }

    private static func home(_ path: String) -> URL { FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(path) }

    static func available(_ ai: OtherAI) -> Bool { FileManager.default.fileExists(atPath: ai.dir.path) }

    private static func read(_ ai: OtherAI) throws -> [String: Any] {
        guard let data = try? Data(contentsOf: ai.file), !data.isEmpty else { return [:] }
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "ClawdWars", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "\(ai.file.path) is not a JSON object"])
        }
        return root
    }

    static func installed(_ ai: OtherAI) -> Bool {
        guard let root = try? read(ai), let hooks = root["hooks"] as? [String: Any] else { return false }
        return ai.events.allSatisfy { e in
            (hooks[e] as? [[String: Any]] ?? []).contains { g in
                (g["hooks"] as? [[String: Any]] ?? []).contains { (($0["command"] as? String) ?? "").contains(marker) }
            }
        }
    }

    /// Adds our hook to every event, keeping everything else in the file (a backup is kept the first time).
    static func install(_ ai: OtherAI) throws {
        guard available(ai) else { return }
        var root = try read(ai)
        let backup = ai.file.appendingPathExtension("before-clawd-wars")
        if FileManager.default.fileExists(atPath: ai.file.path), !FileManager.default.fileExists(atPath: backup.path) {
            try? FileManager.default.copyItem(at: ai.file, to: backup)
        }
        var hooks = root["hooks"] as? [String: Any] ?? [:]
        for e in ai.events {
            var groups = withoutOurs(hooks[e] as? [[String: Any]] ?? [])
            var handler: [String: Any] = ["type": "command", "command": "\"\(hookBinary)\" --assistant \(ai.name)",
                                          "timeout": ai.shortTimeoutEvents.contains(e) ? 3 : 5]
            if ai.name == "qwen" { handler["name"] = "clawd-wars" }        // lets Qwen toggle it in /hooks
            var group: [String: Any] = ["hooks": [handler]]
            if ai.toolEvents.contains(e), let all = ai.matcherAll { group["matcher"] = all }
            groups.append(group)
            hooks[e] = groups
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
            let groups = withoutOurs(hooks[e] as? [[String: Any]] ?? [])
            hooks[e] = groups.isEmpty ? nil : groups
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
