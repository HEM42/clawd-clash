import Foundation

/// What the screen saver shows, published by the running app about once a second (`~/Library/Application Support/
/// Clawd Clash/screensaver.json`). The saver runs sandboxed in macOS's screen saver host, so it reads this one file
/// rather than working anything out itself; when the file goes stale, Clawd Clash isn't running and the saver says so.
struct SaverFeed: Codable {
    var at: Double                 // when it was written: older than `staleAfter` means the app isn't running
    var location: String           // `Location.rawValue`
    var sessions: [Session]
    var events: [Event]
    var universe: Int?             // `Universe.rawValue` the app shows (nil: from before universes, Star Wars)
    var mixed: Bool? = nil         // Clawd Royale: everyone as themselves, places from every universe
    var removed: [Int]? = nil      // universes unchecked in the app's Settings: the saver offers them nowhere
    var privacy: Privacy? = nil    // what the screen saver shows, as the app's Settings last set it

    /// What the screen saver shows of your work, so someone walking past can't read it: the banner along the bottom
    /// (what happened lately) and the session cards (projects, prompts, what each one is doing). Set in the app's
    /// Settings or in the saver's Options; whichever was changed last (`at`) wins.
    struct Privacy: Codable {
        var banner = true
        var cards = true
        var at: Double = 0
    }

    struct Session: Codable {
        var id: String
        var cast: Int              // `Cast.id`
        var assistant: String      // "claude", "codex"… (its outline colour)
        var project: String
        var accent: UInt32?        // the project's colour, as in the app
        var mood: String           // "working", "thinking", "waiting", "idle"
        var urgent = false         // waiting and ignored for a while
        var asleep = false         // idle for a long time
        var sitting = false
        var unknown = false        // no hooks: we can't tell what it's doing
        var focused: Bool?         // its terminal is the one in front (the project you're in)
        var since: Double          // when the current mood began
        var activity: String?      // "Edit WindowMode.swift"
        var prompt: String?        // your last prompt
        var agents: [Agent]
    }

    struct Agent: Codable {
        var id: String
        var cast: Int
        var task: String
    }

    struct Event: Codable {
        var at: Double
        var text: String
    }

    /// The app writes the feed about once a second, so a few seconds without one means it isn't running.
    static let staleAfter = 5.0

    /// The real home folder: inside the screen saver's sandbox `NSHomeDirectory()` and `$HOME` point at its container.
    static var home: String {
        if let pw = getpwuid(getuid()), let dir = pw.pointee.pw_dir { return String(cString: dir) }
        return NSHomeDirectory()
    }

    static var url: URL {
        URL(fileURLWithPath: home + "/Library/Application Support/Clawd Clash/screensaver.json")
    }

    /// The saver as installed for this user, or for everyone.
    static var installedSaver: URL? {
        [home + "/Library/Screen Savers/Clawd Clash.saver", "/Library/Screen Savers/Clawd Clash.saver"]
            .map { URL(fileURLWithPath: $0) }
            .first { FileManager.default.fileExists(atPath: $0.path) }
    }

    static func load() -> SaverFeed? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(SaverFeed.self, from: data)
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        _ = Self.ownerOnlyFolder
        try? data.write(to: Self.url, options: .atomic)
        chmod(Self.url.path, 0o600)
    }

    /// The feed holds your prompts and projects: its folder is made owner-only once per launch, which tightens
    /// folders created 0755 by earlier versions too.
    private static let ownerOnlyFolder: Void = {
        let dir = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        chmod(dir.path, 0o700)
    }()
}
