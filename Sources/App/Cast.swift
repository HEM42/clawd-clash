import Foundation

/// Anyone in the cast: a dark-side villain or a light-side hero. Any of them can be a session (drawn large)
/// or an agent (drawn small). Ids match `StatusStore`: villains < 100, heroes 100 + Companion.
enum Cast: Hashable {
    case villain(Leader)
    case hero(Companion)

    init(id: Int) {
        if id >= StatusStore.heroBase {
            self = .hero(Companion(rawValue: (id - StatusStore.heroBase) % Companion.allCases.count) ?? .luke)
        } else {
            self = .villain(Leader(index: id))
        }
    }

    /// An agent's character (records from before the shared cast only have a hero index).
    static func of(_ a: AgentRecord) -> Cast { Cast(id: a.cast ?? StatusStore.heroBase + a.character) }

    var id: Int {
        switch self {
        case .villain(let l): return l.rawValue
        case .hero(let h): return StatusStore.heroBase + h.rawValue
        }
    }

    var name: String {
        switch self { case .villain(let l): return l.name; case .hero(let h): return h.name }
    }

    var weapon: Weapon {
        switch self { case .villain(let l): return l.weapon; case .hero(let h): return h.weapon }
    }

    var isDark: Bool { if case .villain = self { return true } else { return false } }

    var home: Location {
        switch self { case .villain(let l): return Location.home(of: l); case .hero(let h): return Location.home(of: h) }
    }

    /// Top row of the head on the 72×52 canvas (for labels).
    var headTop: Int {
        switch self { case .villain(let l): return l.headTop; case .hero(let h): return h.headTop }
    }

    /// Where blaster bolts leave from (canvas pixels).
    var muzzle: (x: Double, y: Double) {
        switch self {
        case .villain(let l): return (Double(l.muzzle.x), Double(l.muzzle.y))
        case .hero(let h): return h.muzzle
        }
    }

    /// Bolts ricochet off it (armour or a metal shell).
    var armoured: Bool { if case .villain(let l) = self { return l.armoured } else { return false } }

    var isHan: Bool { if case .hero(.han) = self { return true } else { return false } }

    /// Draw this character. `asSession` = it's a whole Claude/Codex session (it has moods: idle, thinking,
    /// waiting…); agents are always at work.
    func draw(_ c: PixelCanvas, t: Double, mode: VaderMode, walking: Bool, role: FightRole,
              urgent: Bool = false, sitting: Bool = false, asSession: Bool) {
        switch self {
        case .villain(let l):
            drawLeader(c, l, t: t, mode: asSession ? mode : .working, walking: walking, role: role,
                       urgent: asSession && urgent, sitting: asSession && sitting)
        case .hero(let h):
            // A hero leading a session rests (saber off, blaster lowered) unless it's working or fighting.
            var r = role
            if asSession, case .none = role, mode != .working { r = .rest }
            drawCompanion(c, h, t: t, walking: walking, role: r)
        }
    }
}
