import Foundation

/// The universes Clawd Clash can show. One at a time: a scene never mixes characters from two of them.
///
/// Cast ids are stored in the status file and the screen-saver feed: `universe.base + local`, where local ids are
/// villains `0..<100` and heroes `100…`. Star Wars keeps Clawd Wars' ids (base 0), so its saved state carries over.
enum Universe: Int, CaseIterable, Codable {
    case starWars = 0
    case marvel = 1

    var key: String { self == .starWars ? "starWars" : "marvel" }
    init?(key: String) { self.init(rawValue: Universe.allCases.first { $0.key == key }?.rawValue ?? -1) }

    var title: String { self == .starWars ? "Star Wars" : "Marvel" }
    var base: Int { rawValue * 1000 }

    var villainCount: Int { self == .starWars ? 46 : 88 }
    var heroCount: Int { self == .starWars ? 35 : 105 }

    /// Small fry that only ever turn up as agents, never leading a session (global ids).
    var agentOnly: Set<Int> {
        switch self {
        case .starWars: return [23, 26]                                           // MSE-6, ID9 seeker droid
        case .marvel: return Set([11, 33, 190, 202, 203, 204].map { base + $0 })  // Ultron Sentry, Doombot, Jeff, Zabu, Morris, Dum-E
        }
    }

    /// With another AI running, Claude Code's side: false = heroes, true = villains, nil = whoever came first keeps
    /// the side it mostly has (Star Wars, as Clawd Wars always did).
    var claudeSide: Bool? { self == .marvel ? false : nil }

    /// Characters that never lead two sessions back to back (Vader and Kylo), as global ids.
    var rivals: Set<Int> { self == .starWars ? [0, 1] : [] }

    var darkCast: [Int] { (0..<villainCount).map { base + $0 } }
    var lightCast: [Int] { (0..<heroCount).map { base + StatusStore.heroBase + $0 } }

    /// Which universe a cast id belongs to.
    static func of(_ id: Int) -> Universe { Universe(rawValue: id / 1000) ?? .starWars }
    static func isDark(_ id: Int) -> Bool { id % 1000 < StatusStore.heroBase }

    /// `id` as a member of this universe: itself if it already is one, otherwise the character in the same place on
    /// the same side here (the screen saver showing another universe, or the universe switched with sessions open).
    func adopt(_ id: Int) -> Int {
        guard Universe.of(id) != self else { return id }
        let local = id % 1000
        return Universe.isDark(id) ? base + local % villainCount
                                   : base + StatusStore.heroBase + (local - StatusStore.heroBase) % heroCount
    }
}

/// Which universe the screen saver shows.
enum SaverUniverse: String, Codable, CaseIterable {
    case same      // the app's
    case random    // a different one now and then, picked afresh on each trip somewhere new
}
