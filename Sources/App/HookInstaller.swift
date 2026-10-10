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

    // MARK: Codex (~/.codex/hooks.json)

    static let codexEvents = [
        "SessionStart", "SessionEnd", "UserPromptSubmit", "PreToolUse", "PostToolUse", "PermissionRequest",
        "Stop", "Interrupt", "SubagentStart", "SubagentStop",
    ]
    static var codexDir: URL { FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".codex") }
    static var codexHooksURL: URL { codexDir.appendingPathComponent("hooks.json") }
    static var codexAvailable: Bool { FileManager.default.fileExists(atPath: codexDir.path) }

    private static func readCodexHooks() throws -> [String: Any] {
        guard let data = try? Data(contentsOf: codexHooksURL), !data.isEmpty else { return [:] }
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "ClawdWars", code: 2, userInfo: [NSLocalizedDescriptionKey: "~/.codex/hooks.json is not a JSON object"])
        }
        return root
    }

    static var codexInstalled: Bool {
        guard let root = try? readCodexHooks(), let hooks = root["hooks"] as? [String: Any] else { return false }
        return codexEvents.allSatisfy { e in
            (hooks[e] as? [[String: Any]] ?? []).contains { g in
                (g["hooks"] as? [[String: Any]] ?? []).contains { (($0["command"] as? String) ?? "").contains(marker) }
            }
        }
    }

    /// Adds our hook (with `--assistant codex`) to every Codex event, keeping whatever else is in the file.
    /// Codex runs new hooks only after you trust them: `/hooks` in Codex.
    static func installCodex() throws {
        guard codexAvailable else { return }
        var root = try readCodexHooks()
        let backup = codexHooksURL.appendingPathExtension("before-clawd-wars")
        if FileManager.default.fileExists(atPath: codexHooksURL.path), !FileManager.default.fileExists(atPath: backup.path) {
            try? FileManager.default.copyItem(at: codexHooksURL, to: backup)
        }
        var hooks = root["hooks"] as? [String: Any] ?? [:]
        for e in codexEvents {
            var groups = withoutOurs(hooks[e] as? [[String: Any]] ?? [])
            // SessionEnd and Interrupt allow at most 3 s; the hook takes milliseconds anyway.
            let handler: [String: Any] = ["type": "command", "command": "\"\(hookBinary)\" --assistant codex",
                                          "timeout": ["SessionEnd", "Interrupt"].contains(e) ? 3 : 5]
            groups.append(["hooks": [handler]])
            hooks[e] = groups
        }
        root["hooks"] = hooks
        let data = try JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .withoutEscapingSlashes])
        try data.write(to: codexHooksURL, options: .atomic)
    }

    static func uninstallCodex() throws {
        guard FileManager.default.fileExists(atPath: codexHooksURL.path) else { return }
        var root = try readCodexHooks()
        guard var hooks = root["hooks"] as? [String: Any] else { return }
        for e in codexEvents {
            let groups = withoutOurs(hooks[e] as? [[String: Any]] ?? [])
            hooks[e] = groups.isEmpty ? nil : groups
        }
        root["hooks"] = hooks.isEmpty ? nil : hooks
        let data = try JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .withoutEscapingSlashes])
        try data.write(to: codexHooksURL, options: .atomic)
    }
}
