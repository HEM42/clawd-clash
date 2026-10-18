import Foundation

/// What every part of Clawd Clash needs to know about a universe: plain numbers, no drawing. Each universe's
/// `<Prefix>Facts.swift` holds its cast's enums and one of these; the hook compiles those files too, so it can cast
/// characters and handle compaction without a single sprite.
///
/// Ids here are local: villains `0..<100`, heroes `StatusStore.heroBase…` (HEM last). `Universe` adds its `base`.
struct UniverseFacts {
    /// From the enums (`allCases.count`), never typed by hand: agent-only characters included.
    let villainCount: Int
    /// From the enums: HEM included, always last.
    let heroCount: Int
    /// Small fry that only ever turn up as agents, never leading a session.
    var agentOnly: Set<Int> = []
    /// With another AI running, Claude Code's side: false = heroes, true = villains, nil = whoever came first keeps
    /// the side it mostly has (Star Clawds, as Clawd Wars always did).
    var claudeSide: Bool? = false
    /// Characters that never lead two sessions back to back (Vader and Kylo; Angstel and Spyke).
    var rivals: Set<Int> = []
    /// One character in two guises: never on screen together.
    var guises: [Set<Int>] = []
    /// Characters who only ever appear at home, as id → place key.
    var homebound: [Int: String] = [:]
    /// What happens to a session's leader when its context is compacted.
    var compaction: UniverseCompaction? = nil
}

/// What a compaction does to a session's leader (`StatusStore`'s PreCompact).
enum UniverseCompaction {
    /// Doctor Clawd: the next face in `order`, same session.
    case regenerate(order: [Int])
    /// The Clawd Files, Stevie Clawdberg, Clawd Slayer: `who` are gone for a moment and come back the same.
    case away(who: Set<Int>)
}
