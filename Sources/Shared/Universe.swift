import Foundation

/// The universes Clawd Clash can show. One at a time, except in Clawd Royale (`Roster`), where a scene mixes all of them.
/// A universe can be built before it's released (`isReleased`; every one is today): only the tools see an unreleased one.
///
/// Cast ids are stored in the status file and the screen-saver feed: `universe.base + local`, where local ids are
/// villains `0..<100` and heroes `100…`. Star Wars keeps Clawd Wars' ids (base 0), so its saved state carries over.
enum Universe: Int, CaseIterable, Codable {
    case starWars = 0
    case marvel = 1
    case dc = 2
    case doctor = 3
    case clawdFiles = 4
    case clawdberg = 5
    case middleEarth = 6

    var key: String {
        switch self {
        case .starWars: return "starWars"; case .marvel: return "marvel"; case .dc: return "dc"; case .doctor: return "doctor"
        case .clawdFiles: return "clawdFiles"; case .clawdberg: return "clawdberg"; case .middleEarth: return "middleEarth"
        }
    }
    init?(key: String) { self.init(rawValue: Universe.allCases.first { $0.key == key }?.rawValue ?? -1) }

    var title: String {
        switch self {
        case .starWars: return "Star Clawds"; case .marvel: return "Marvelous Clawds"; case .dc: return "Detective Clawds"; case .doctor: return "Doctor Clawd"
        case .clawdFiles: return "The Clawd Files"; case .clawdberg: return "Stevie Clawdberg"; case .middleEarth: return "Clawd of the Rings"
        }
    }
    var base: Int { rawValue * 1000 }

    var villainCount: Int {
        switch self { case .starWars: return 46; case .marvel: return 88; case .dc: return 97; case .doctor: return 42; case .clawdFiles: return 46
        case .clawdberg: return 54; case .middleEarth: return 38 }
    }
    var heroCount: Int {
        switch self { case .starWars: return 36; case .marvel: return 106; case .dc: return 111; case .doctor: return 56; case .clawdFiles: return 36
        case .clawdberg: return 64; case .middleEarth: return 38 }
    }

    /// HEM: the same rare face in every universe, last of the heroes. He's never in the regular pools (`lightCast`);
    /// a new session or agent turns out to be him now and then (`hemOdds`), and he stays himself across universes.
    var hem: Int { base + StatusStore.heroBase + heroCount - 1 }
    func isHem(_ id: Int) -> Bool { id % 1000 == StatusStore.heroBase + heroCount - 1 }
    /// The chance a new session's character, or a new agent's, is HEM.
    static let hemOdds = (session: 1.0 / 50, agent: 1.0 / 150)

    /// Small fry that only ever turn up as agents, never leading a session (global ids).
    var agentOnly: Set<Int> {
        switch self {
        case .starWars: return [23, 26]                                           // MSE-6, ID9 seeker droid
        case .marvel: return Set([11, 33, 190, 202, 203, 204].map { base + $0 })  // Ultron Sentry, Doombot, Jeff, Zabu, Morris, Dum-E
        // Joker Goon, Dex-Starr, Mister Mind, Krypto, Ch'p, Ace the Bat-Hound, Streaky, Gleek, Beppo
        case .dc: return Set([22, 49, 77, 131, 139, 206, 207, 208, 209].map { base + $0 })
        case .doctor: return Set([39, 40, 41].map { base + $0 })                // Adipoze, Cybermite, Toclafayne
        case .clawdFiles: return Set([43, 44, 45].map { base + $0 })            // killer bee, robo-roach, flukeworm
        case .clawdberg: return Set((49...53).map { base + $0 })                // Compy, mogwai pup, snake, frog, Croc Clock
        case .middleEarth: return []
        }
    }

    /// With another AI running, Claude Code's side: false = heroes, true = villains, nil = whoever came first keeps
    /// the side it mostly has (Star Wars, as Clawd Wars always did).
    var claudeSide: Bool? { self == .starWars ? nil : false }

    /// Characters that never lead two sessions back to back (Vader and Kylo), as global ids.
    var rivals: Set<Int> { self == .starWars ? [0, 1] : [] }

    /// One character in two guises, as global ids: never on screen together (the casting and `StatusStore.snapshot`
    /// keep to it). Clawd of the Rings: Gandclawd the Grey and the White (`RingsHero` 0 and 17), Arrogorn and Stride-r
    /// (`RingsHero` 4 and 28), Sarumanual and Sharkey (`RingsVillain` 1 and 30), Sourun and the Necro-maintainer
    /// (`RingsVillain` 0 and 31).
    var guises: [Set<Int>] {
        guard self == .middleEarth else { return [] }
        let hero = base + StatusStore.heroBase
        return [[hero, hero + 17], [hero + 4, hero + 28], [base + 1, base + 30], [base, base + 31]]
    }

    /// Characters who only ever appear at home, as global id → place key: anywhere else, and on the desktop (no place),
    /// they're shown as someone else (`Roster.recast`). Clawd of the Rings: Smaug the Stashed (`RingsVillain` 32) on his
    /// hoard in the Lonely Mount-point.
    var homebound: [Int: String] { self == .middleEarth ? [base + 32: "erebor"] : [:] }

    /// The Clawd Files: the seven FBI agents (Clawder, Scrawly, Skinnard, Doggedd, Reyez, Einstine, Millar), as global
    /// ids. When one's session is compacted they lose some time: abducted and set back down, the same face
    /// (`StatusStore`'s PreCompact, `MissingTime`).
    /// Stevie Clawdberg: Back to the Future's time travellers (Marty, Doc Brawn, Jennifer, Einstein the Dog, and Old
    /// Biff, who stole the DeLorean). When one's session is compacted they hit 88 mph and come back (`OutaTime`).
    var abductees: Set<Int> {
        switch self {
        case .clawdFiles: return Set((0...6).map { base + StatusStore.heroBase + $0 })
        case .clawdberg: return Set([55, 56, 57, 60].map { base + StatusStore.heroBase + $0 } + [base + 44])
        default: return []
        }
    }

    /// Doctor Clawd: the Doctors in order (One … Fifteen), as global ids. When a session's context is compacted, its
    /// Doctor regenerates into the next one (`StatusStore`'s PreCompact); nobody else changes.
    var regenerations: [Int] {
        self == .doctor ? [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 10, 11, 12, 13, 14].map { base + StatusStore.heroBase + $0 } : []
    }

    /// Whether people can pick it: Settings, Random, Clawd Royale and the screen saver only offer released universes.
    /// An unreleased one exists for the tools (the workbench, the docs and promo renderers) until it's ready.
    var isReleased: Bool { true }
    /// The universes people can pick, in menu order.
    static var offered: [Universe] { allCases.filter(\.isReleased) }
    /// A stored key, but only for a universe people can pick: an unreleased one reads as unset.
    static func offered(key: String) -> Universe? { Universe(key: key).flatMap { $0.isReleased ? $0 : nil } }

    var darkCast: [Int] { (0..<villainCount).map { base + $0 } }
    var lightCast: [Int] { (0..<heroCount - 1).map { base + StatusStore.heroBase + $0 } }   // all but HEM

    /// Which universe a cast id belongs to.
    static func of(_ id: Int) -> Universe { Universe(rawValue: id / 1000) ?? .starWars }
    static func isDark(_ id: Int) -> Bool { id % 1000 < StatusStore.heroBase }

    /// `id` as a member of this universe: itself if it already is one, otherwise the character in the same place on
    /// the same side here (the screen saver showing another universe, or the universe switched with sessions open).
    func adopt(_ id: Int) -> Int {
        guard Universe.of(id) != self else { return id }
        if Universe.of(id).isHem(id) { return hem }
        let local = id % 1000
        return Universe.isDark(id) ? base + local % villainCount
                                   : base + StatusStore.heroBase + (local - StatusStore.heroBase) % (heroCount - 1)
    }
}

/// Who can be cast and shown: one universe, or every one of them at once (Clawd Royale), each character as itself.
struct Roster {
    let universes: [Universe]

    init(_ universe: Universe, mixed: Bool) { universes = mixed ? Universe.offered : [universe] }

    var mixed: Bool { universes.count > 1 }
    var darkCast: [Int] { universes.flatMap(\.darkCast) }
    var lightCast: [Int] { universes.flatMap(\.lightCast) }
    var agentOnly: Set<Int> { universes.reduce(into: Set<Int>()) { $0.formUnion($1.agentOnly) } }
    var rivals: Set<Int> { universes.reduce(into: Set<Int>()) { $0.formUnion($1.rivals) } }
    var guises: [Set<Int>] { universes.flatMap(\.guises) }
    /// Who can't join while `shown` (ids as of this roster) are on screen: the other guises of anyone there.
    func ruledOut(by shown: Set<Int>) -> Set<Int> {
        guises.reduce(into: Set<Int>()) { out, g in if !g.isDisjoint(with: shown) { out.formUnion(g.subtracting(shown)) } }
    }
    var homebound: [Int: String] { universes.reduce(into: [:]) { $0.merge($1.homebound) { a, _ in a } } }
    /// Whether `id` may appear at `place` (a place key; nil: no place, the desktop): anyone but the homebound, and
    /// those only at home.
    func allowed(_ id: Int, at place: String?) -> Bool { homebound[id].map { $0 == place } ?? true }
    /// `ids` (as of this roster) as they may appear at `place`: anyone homebound elsewhere is shown as someone else on
    /// the same side, not on screen already and not the other guise of anyone there, picked by `seeds` (one per id) so
    /// it's the same someone on every refresh.
    func recast(_ ids: [Int], seeds: [String], at place: String?) -> [Int] {
        guard !homebound.isEmpty else { return ids }
        var out = ids
        for (i, id) in ids.enumerated() where !allowed(id, at: place) {
            let taken = Set(out), ruled = ruledOut(by: taken)
            let pool = (StatusStore.isDark(id) ? darkCast : lightCast)
                .filter { !taken.contains($0) && !ruled.contains($0) && !agentOnly.contains($0) && allowed($0, at: place) }
            if !pool.isEmpty { out[i] = pool[Int(StatusStore.stableHash(seeds[i]) % UInt64(pool.count))] }
        }
        return out
    }
    /// With another AI running, Claude Code's side (`Universe.claudeSide`); in Clawd Royale, the heroes.
    var claudeSide: Bool? { mixed ? false : universes[0].claudeSide }
    /// HEM, once for each universe here.
    var hems: Set<Int> { Set(universes.map(\.hem)) }
    /// Whether `id` is HEM, in whichever universe it's from.
    static func isHem(_ id: Int) -> Bool { Universe.of(id).isHem(id) }
    /// `id` as one of this roster: itself in Clawd Royale, otherwise the universe's `adopt`.
    func adopt(_ id: Int) -> Int { mixed ? id : universes[0].adopt(id) }
}
