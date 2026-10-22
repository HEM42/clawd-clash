import Foundation

// The universe's facts: its cast's enums and what the hook, the app and the screen saver need to know about it. Plain
// data, no drawing: the hook compiles this file too (and nothing else in the folder), so keep it to enums and numbers.
//
// Ids: a character's id is the universe's number × 1000 plus its local id: villains 0…99 by `<Prefix>Villain`'s order,
// heroes 100… by `<Prefix>Hero`'s. Ids are saved in running sessions, the hook's state file and the screen-saver feed,
// so the enums are append-only:
//   - only ever add cases at the end;
//   - never reorder, rename into another character or remove a case once it's on `main`;
//   - HEM is always the last hero (`Universe.hem` counts on it), so new heroes go just before him.
// Group the cases with a comment line per group, as the other universes do. A full universe has 80 to 110 characters.
//
// One exception, made once and never again: in phase 4 (2026-10-20) the Mind Flayer stopped being a character and
// became the Upside Down's scenery, so its villain case was taken out and the cases after it moved up one. Stranger
// Clawds had never shipped, so no saved state held its ids. That was the last time these enums may be reordered.

enum HawkinsHero: Int, CaseIterable {
    // The Party
    case eleven, mikeWheeler, dustinHenderson
    case lucasSinclawd, willByers, maxMayfield, ericaSinclair
    // The teenagers
    case steveHarringclawd, nancyWheeler, jonathanByers, robinBuckley, eddieMunclawd, argyle, barb, derekTurnbow
    // The grown-ups
    case chiefHopper, joyceByers
    case murrayBauman, bobNewby, mrClarke, bennyHammond, drOwens
    // Allies
    case kali, suzie, alexei, yuri
    // Season 5's Wheelers
    case hollyWheeler, karenWheeler
    case hem   // always last (`Universe.hem`)
}

enum HawkinsVillain: Int, CaseIterable {
    // The Upside Down and the people who hunt the kids
    case vecna
    case one, democlawdgon, drBrenner, billyHargrove
    case grigori, jasonCarver, mayorKline, drKay, colonelSullivan, connieFrazier
    // Small fry, agents only
    case demodog, dart, demobat, flayedRat
}

extension Universe {
    /// The universe's constant: `Cast(universe: .hawkins, …)` inside this folder. Code outside the folder never names
    /// it. The number is the one NUMBERS gives you, for good.
    static let hawkins = Universe(number: 9)
}

enum HawkinsFacts {
    static let entry = UniverseEntry(universe: .hawkins, key: "hawkins", title: "Stranger Clawds", facts: facts)
    static let facts = UniverseFacts(
        // The counts come from the enums, never typed by hand.
        villainCount: HawkinsVillain.allCases.count, heroCount: HawkinsHero.allCases.count,
        // The Upside Down's small fry (a Demodog, Dart, a Demobat and a flayed rat) only ever turn up as agents.
        agentOnly: Set([HawkinsVillain.demodog, .dart, .demobat, .flayedRat].map(\.rawValue)),
        // Vecna and One are the same man in two forms, so they never lead sessions back to back.
        rivals: [HawkinsVillain.vecna.rawValue, HawkinsVillain.one.rawValue],
        // The ones who've been to the Upside Down (Will, Eleven, Max, Holly, Nancy, Steve, Robin and Eddie): a
        // compaction takes them there for a moment, back through the wall, and they come back slimy (`HawkinsTaken`).
        compaction: .away(who: Set([HawkinsHero.willByers, .eleven, .maxMayfield, .hollyWheeler, .nancyWheeler,
                                    .steveHarringclawd, .robinBuckley, .eddieMunclawd]
                                    .map { UniverseFacts.heroBase + $0.rawValue }))
        //
        // Everything below is optional: uncomment what your universe needs. Ids here are local: a villain's is its
        // rawValue, a hero's `UniverseFacts.heroBase + rawValue`.
        //
        // With another AI running, which side Claude Code plays: false (the default) the heroes, true the villains,
        // nil whoever came first keeps the side it mostly has (Star Clawds):
        //   , claudeSide: false
        // Two who never lead sessions back to back (Vader and Kylo; Angstel and Spyke):
        //   , rivals: [UniverseFacts.heroBase + HawkinsHero.a.rawValue, UniverseFacts.heroBase + HawkinsHero.b.rawValue]
        // One character in two guises, never on screen together (Clawd of the Rings' Strider and Aragorn):
        //   , guises: [[UniverseFacts.heroBase + HawkinsHero.a.rawValue, UniverseFacts.heroBase + HawkinsHero.b.rawValue]]
        // Someone who only ever appears at home, as id and place key (Smaug the Stashed, at the Lonely Mountain):
        //   , homebound: [HawkinsVillain.dragon.rawValue: "hawkinsLair"]
        // What a compaction does to a session's leader, one of two kinds (the module draws it: `compactionLook` or
        // `regeneration` in HawkinsUniverse.swift):
        //   , compaction: .regenerate(order: [...])   // Doctor Clawd: the next face in the list, same session
        //   , compaction: .away(who: [...])           // The Clawd Files: gone for a moment, back the same
    )
}
