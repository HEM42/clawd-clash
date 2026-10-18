import Foundation

// Clawd Slayer's facts: its cast's enums and what the hook, the app and the screen saver need to know about it. Plain data,
// no drawing: the hook compiles this file too. The enums' order is the ids, so only ever append cases (HEM stays last)
// and never reorder or remove one: running sessions keep their characters across an update.

enum SlayerHero: Int, CaseIterable {
    // The Scooby Gang
    case buffyClawmers, willowRosenclaw, xanderHarrows, rupertGyles, cordeliaChaise, ozz, anyaJinkins, taraMaclaw
    case spyke, dawnClawmers, joyceClawmers
    // Slayers, Watchers and Potentials
    case faithLehayne, kendraYung, firstSlayer, jennyClawlendar, robinWoode, kennedie, vy, rhona
    // Sunnydale friends
    case rileyFynn, jonathanLevinsun, clemm, whistlr, sidTheDummy
    // Angel Investigations
    case angstel, wesleyWindupPryce, charlesGunne, fredBurkel, lorn, doyl, conner, kateLockclaw, groosalug, drogynn
    // Pets (agent-only)
    case missKitty
    case hem   // always last (`Universe.hem`)

}

enum SlayerVillain: Int, CaseIterable {
    // Vampires
    case oldMaster, lukewarm, darlah, drusillah, mrTricks, harmonyClawdall, kakistoes, sundae, lyleGrouch, draclawla
    case turokHahn
    // Big Bads
    case judge, mayorWilclaws, adamm, professorWalshe, glorificlaws, firstEvil, preacherCalebb, darkWillow
    // Henchmen, rivals and monsters of the week
    case bringer, knightOfByzantium, dok, gentlemen, andrewWellz, ethanRaine, sweete, tedd, molok, olaffTheTroll
    case dHoffrin, halfreck, veruka, gwendolynPoste, quentinTravesty, principalSnide
    // Wolfram & Hart and Angel's foes
    case lindseyMcDonclawd, lilahMorgane, hollandMannerly, jazzmine, stoneBeast, holts, sahjhann, illyrya, skipp
    // Agent-only small fry
    case fledgling, gloryMinion, gachnar, amyTheRat

}

extension Universe {
    /// Clawd Slayer: number 7, for good (its ids are 7000 and up).
    static let slayer = Universe(number: 7)
}

enum SlayerFacts {
    static let entry = UniverseEntry(universe: .slayer, key: "slayer", title: "Clawd Slayer", facts: facts)
    static let facts = UniverseFacts(
        villainCount: SlayerVillain.allCases.count, heroCount: SlayerHero.allCases.count,
        // a fledgling vampire, one of Glory's minions, Gachnar, Amy the rat; Miss Kitty Fanclawstico
        agentOnly: Set((44...47).map { $0 } + [UniverseFacts.heroBase + 34]),
        rivals: [UniverseFacts.heroBase + 24, UniverseFacts.heroBase + 8],      // Angstel and Spyke
        // The eight from "Tabula Rasa" (Buffy, Willow, Xander, Giles, Anya, Tara, Spyke, Dawn): Willow's forgetting
        // spell goes off, then wears off, the same face (`SlayerTabulaRasa`).
        compaction: .away(who: Set([0, 1, 2, 3, 6, 7, 8, 9].map { UniverseFacts.heroBase + $0 }))
    )
}
