import Foundation

/// A project's name and where its remote lives, read from the repo's `.git/config` on disk (no network needed).
struct GitRemote {
    let name: String    // the repo name from the remote's URL, e.g. "clawd-wars"
    let host: String    // "GitHub", "GitLab", "Bitbucket", "Codeberg", or the bare host name

    private static var cache: [String: (remote: GitRemote?, checked: Double)] = [:]
    private static let lock = NSLock()
    /// How long an answer is trusted: a project that gets a remote later is picked up within this.
    static let recheck: Double = 5

    /// The remote of the repo containing `cwd` (origin, else the first one), or nil if it has none or isn't a repo.
    static func of(_ cwd: String, now: Double = Date().timeIntervalSince1970) -> GitRemote? {
        lock.lock(); defer { lock.unlock() }
        if let hit = cache[cwd], now - hit.checked < recheck { return hit.remote }
        let remote = configPath(from: cwd).flatMap { try? String(contentsOfFile: $0, encoding: .utf8) }
            .flatMap(remoteURL).flatMap(parse)
        cache[cwd] = (remote, now)
        return remote
    }

    /// The shared `config` of the repo containing `cwd`, walking up from it. Handles worktrees and
    /// submodules, whose `.git` is a file pointing at the real git dir.
    static func configPath(from cwd: String) -> String? {
        let fm = FileManager.default
        var dir = URL(fileURLWithPath: cwd).standardizedFileURL
        while true {
            let dotGit = dir.appendingPathComponent(".git")
            var isDir: ObjCBool = false
            if fm.fileExists(atPath: dotGit.path, isDirectory: &isDir) {
                var gitDir = dotGit
                if !isDir.boolValue {   // "gitdir: <path>"
                    guard let text = try? String(contentsOf: dotGit, encoding: .utf8),
                          let line = text.split(separator: "\n").first(where: { $0.hasPrefix("gitdir:") }) else { return nil }
                    let path = line.dropFirst("gitdir:".count).trimmingCharacters(in: .whitespaces)
                    gitDir = URL(fileURLWithPath: path, relativeTo: dir).standardizedFileURL
                }
                // A worktree's git dir names the main repo's in "commondir"; that's where the config is.
                if let common = try? String(contentsOf: gitDir.appendingPathComponent("commondir"), encoding: .utf8) {
                    gitDir = URL(fileURLWithPath: common.trimmingCharacters(in: .whitespacesAndNewlines),
                                 relativeTo: gitDir.appendingPathComponent("")).standardizedFileURL
                }
                let config = gitDir.appendingPathComponent("config").path
                return fm.fileExists(atPath: config) ? config : nil
            }
            let parent = dir.deletingLastPathComponent()
            if parent.path == dir.path { return nil }
            dir = parent
        }
    }

    /// origin's url, else the first remote's.
    static func remoteURL(config: String) -> String? {
        var urls: [(remote: String, url: String)] = []
        var section: String?
        for raw in config.split(whereSeparator: \.isNewline) {
            let line = raw.trimmingCharacters(in: .whitespaces)
            if line.hasPrefix("[") {
                // [remote "origin"]
                let parts = line.dropFirst().dropLast().split(separator: "\"")
                section = parts.count >= 2 && parts[0].trimmingCharacters(in: .whitespaces) == "remote" ? String(parts[1]) : nil
            } else if let remote = section, let eq = line.firstIndex(of: "="),
                      line[..<eq].trimmingCharacters(in: .whitespaces) == "url" {
                urls.append((remote, line[line.index(after: eq)...].trimmingCharacters(in: .whitespaces)))
            }
        }
        return (urls.first { $0.remote == "origin" } ?? urls.first)?.url
    }

    /// `git@github.com:me/repo.git`, `https://gitlab.com/group/sub/repo`, `ssh://git@host:22/me/repo.git`…
    /// Remotes on disk (`/srv/repo.git`, `file://…`) aren't remote, so they give nil.
    static func parse(_ url: String) -> GitRemote? {
        var host: String?, path: String?
        if url.contains("://") {
            guard let c = URLComponents(string: url), c.scheme != "file" else { return nil }
            host = c.host
            path = c.path
        } else if let colon = url.firstIndex(of: ":"), !url[..<colon].contains("/") {   // scp-like: [user@]host:path
            let left = url[..<colon]
            host = String(left.split(separator: "@").last ?? left)
            path = String(url[url.index(after: colon)...])
        }
        guard let host, !host.isEmpty, let path else { return nil }
        var name = (path as NSString).lastPathComponent
        if name.hasSuffix(".git") { name = String(name.dropLast(4)) }
        guard !name.isEmpty, name != "/" else { return nil }
        return GitRemote(name: name, host: label(host.lowercased()))
    }

    static func label(_ host: String) -> String {
        let known = ["github": "GitHub", "gitlab": "GitLab", "bitbucket": "Bitbucket", "codeberg": "Codeberg",
                     "dev.azure": "Azure DevOps", "visualstudio": "Azure DevOps", "sr.ht": "SourceHut"]
        if let hit = known.first(where: { host.contains($0.key) }) { return hit.value }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
}
