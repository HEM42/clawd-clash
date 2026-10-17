import Foundation

/// How full a session's context window is, for the pill on its card: 0…1, nil when it can't be told. Read from the
/// end of the session's own log, and only re-read when that file changes.
/// - Claude Code: its transcript (`~/.claude/projects/<folder>/<session>.jsonl`) records each reply's token usage;
///   what the next request carries is the input plus the cache read and written. The window is 1M tokens for a
///   `[1m]` model (as the hooks record it, or as `~/.claude/settings.json` picks it when the hooks didn't say),
///   else 200k, and 1M anyway once a session has gone past 200k.
/// - Codex: its rollout (`~/.codex/sessions/YYYY/MM/DD/rollout-…-<session>.jsonl`) logs a `token_count` after each
///   turn with the last turn's tokens and the model's context window.
/// Other AIs: nil, so their cards show no pill.
enum ContextUsage {
    private static var files: [String: URL] = [:]
    private static var cache: [String: (modified: Date, value: Double?)] = [:]

    static func fraction(session id: String, assistant: String, model: String?) -> Double? {
        let fm = FileManager.default
        guard let url = file(for: id, assistant: assistant),
              let modified = (try? fm.attributesOfItem(atPath: url.path))?[.modificationDate] as? Date else { return nil }
        if let hit = cache[id], hit.modified == modified { return hit.value }
        let value: Double?
        switch assistant {
        case "claude": value = claude(url, model: model)
        case "codex": value = codex(url)
        default: value = nil
        }
        cache[id] = (modified, value)
        return value
    }

    /// The session's log, found once and remembered.
    private static func file(for id: String, assistant: String) -> URL? {
        if let f = files[id] { return f }
        let fm = FileManager.default, home = fm.homeDirectoryForCurrentUser
        var found: URL?
        switch assistant {
        case "claude":
            let root = home.appendingPathComponent(".claude/projects")
            for dir in (try? fm.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)) ?? [] {
                let f = dir.appendingPathComponent(id + ".jsonl")
                if fm.fileExists(atPath: f.path) { found = f; break }
            }
        case "codex":
            // Newest days first: a running session's rollout is in today's folder, or a recent one.
            let root = home.appendingPathComponent(".codex/sessions")
            let suffix = "-" + id + ".jsonl"
            func sorted(_ u: URL) -> [URL] {
                ((try? fm.contentsOfDirectory(at: u, includingPropertiesForKeys: nil)) ?? []).sorted { $0.lastPathComponent > $1.lastPathComponent }
            }
            search: for year in sorted(root) { for month in sorted(year) { for day in sorted(month).prefix(40) {
                if let f = sorted(day).first(where: { $0.lastPathComponent.hasSuffix(suffix) }) { found = f; break search }
            } } }
        default: break
        }
        if let found { files[id] = found }
        return found
    }

    /// The JSON objects on the last lines of `url`, newest first: the last 256 KB, then up to 2 MB when a long tool
    /// result has pushed the last usage further back.
    private static func lastObjects(_ url: URL, where match: String) -> [[String: Any]] {
        guard let h = try? FileHandle(forReadingFrom: url) else { return [] }
        defer { try? h.close() }
        let size = (try? h.seekToEnd()) ?? 0
        for span in [UInt64(262_144), 2_097_152] {
            try? h.seek(toOffset: size > span ? size - span : 0)
            let data = h.readDataToEndOfFile()
            var out: [[String: Any]] = []
            for line in data.split(separator: UInt8(ascii: "\n")).reversed() where line.count < 4_000_000 {
                guard let text = String(data: line, encoding: .utf8), text.contains(match),
                      let obj = (try? JSONSerialization.jsonObject(with: Data(line))) as? [String: Any] else { continue }
                out.append(obj)
                if out.count >= 5 { return out }
            }
            if !out.isEmpty || size <= span { return out }
        }
        return []
    }

    /// Whether Claude Code's settings pick a 1M-token model by default (`"model": "opus[1m]"`), read once a minute.
    private static var settingsRead: (at: Date, big: Bool)?
    private static var defaultIs1M: Bool {
        if let s = settingsRead, Date().timeIntervalSince(s.at) < 60 { return s.big }
        let url = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude/settings.json")
        let json = (try? Data(contentsOf: url)).flatMap { try? JSONSerialization.jsonObject(with: $0) } as? [String: Any]
        let big = (json?["model"] as? String)?.contains("[1m]") ?? false
        settingsRead = (Date(), big)
        return big
    }

    private static func number(_ any: Any?) -> Double { (any as? NSNumber)?.doubleValue ?? 0 }

    private static func claude(_ url: URL, model: String?) -> Double? {
        // The newest reply in the main conversation (not an agent's side chain) that carries its usage.
        for obj in lastObjects(url, where: "\"usage\"") where (obj["isSidechain"] as? Bool) != true {
            guard let message = obj["message"] as? [String: Any], let usage = message["usage"] as? [String: Any] else { continue }
            let used = number(usage["input_tokens"]) + number(usage["cache_read_input_tokens"])
                + number(usage["cache_creation_input_tokens"]) + number(usage["output_tokens"])
            guard used > 0 else { continue }
            let big = (model ?? "").contains("[1m]") || defaultIs1M || used > 200_000
            return min(1, used / (big ? 1_000_000 : 200_000))
        }
        return nil
    }

    private static func codex(_ url: URL) -> Double? {
        for obj in lastObjects(url, where: "\"token_count\"") {
            let payload = obj["payload"] as? [String: Any] ?? obj
            guard let info = payload["info"] as? [String: Any],
                  let last = info["last_token_usage"] as? [String: Any] else { continue }
            let window = number(info["model_context_window"]), used = number(last["total_tokens"])
            guard window > 0, used > 0 else { continue }
            return min(1, used / window)
        }
        return nil
    }
}
