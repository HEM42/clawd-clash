import Foundation

// Clawd Burton's facts: its cast's enums and what the hook, the app and the screen saver need to know about it. Plain
// data, no drawing: the hook compiles this file too. The enums' order is the ids, so only ever append cases (HEM stays
// last) and never reorder or remove one: running sessions keep their characters across an update.

enum BurtonHero: Int, CaseIterable {
    // The Nightmare Before Christmas
    case jackSkullington, sallee, zeero, theMayor, sandyClawdz
    // Beetlejuice and Beetlejuice Beetlejuice
    case lydiaDeathz, adamMaitclawd, barbaraMaitclawd, deliaDeathz, astridDeathz, junoh, wolfJaxon, shrunkenHeadMan
    // Edward Scissorhands
    case edwardScissorclawds, kimBoggz, pegBoggz, theInventor
    // Corpse Bride
    case victorVanDawt, emilee, victoriaEverclawd, scrapz, elderGutknocked, bonejingles, generalBonesapart
    // Sleepy Hollow
    case ichabodCraine, katrinaVanTassle, youngMasbeth, bromVanBruntt
    // Mars Attacks!
    case richieNorriss, grandmaFlorenz, presidentDayle, byronWilyums, professorKessclawd
    // Charlie and the Chocolate Factory
    case willyWonky, charlieBuckett, grampaJoe, oompaLoompah, drWilburWonky
    // Alice in Wonderland
    case aliceKingsclawd, tarrantHightop, chessur, mirana, mcTwisp, mally, thackeryHare
    // Frankenweenie
    case victorFrankenstien, sparkie, elsaVanHelsclawd, mrRzykrusky
    // Pee-wee's Big Adventure
    case peeweeHerclawd, dottie, largeMarge
    // Agent-only
    case maggott
    case hem   // always last (`Universe.hem`)
}

enum BurtonVillain: Int, CaseIterable {
    // Beetlejuice and Beetlejuice Beetlejuice
    case beetlejooce, sandwurm, delorez, otho, jeremee
    // The Nightmare Before Christmas
    case ooogieBoogie, lok, shok, barrell, drFinkelclawd, wolfclawd, tearAwayClown, halloweenWitch
    // Edward Scissorhands
    case jimm, joyceMonrow
    // Corpse Bride
    case lordBarkissBittern, pastorGallswell, finisEverclawd, maudelineEverclawd
    // Sleepy Hollow
    case headlessHorseclawd, ladyVanTassle, westernWoodsCrone
    // Mars Attacks!
    case martianLeader, martianAmbassador, martianTrooper, martianSpy, martianWalker
    // Charlie and the Chocolate Factory
    case augustusGloopp, verucaSaltt, violetBluregarde, mikeTeevee, slugwurth
    // Alice in Wonderland
    case redQueen, stayne, jabberclawdky, bandersnatch, redCardKnight
    // Frankenweenie
    case edgarGorr, nassorr, toshiakki, weirdGurl, mrWhiskerz, shellee, colossuss, wereRat
    // Pee-wee's Big Adventure
    case francisBuxtun, bikeThief, madamRubee, andee
    // Agent-only small fry
    case bob, oogieBug, nutSquirrel, seaMonkey
}

extension Universe {
    /// Clawd Burton: number 8, for good (its ids are 8000 and up).
    static let clawdBurton = Universe(number: 8)
}

enum BurtonFacts {
    static let entry = UniverseEntry(universe: .clawdBurton, key: "clawdBurton", title: "Clawd Burton", facts: facts)
    static let facts = UniverseFacts(
        villainCount: BurtonVillain.allCases.count, heroCount: BurtonHero.allCases.count,
        // Bob, an Oogie bug, a nut-sorting squirrel, a Sea-Monkey; Maggott
        agentOnly: Set([BurtonVillain.bob, .oogieBug, .nutSquirrel, .seaMonkey].map(\.rawValue)
                       + [UniverseFacts.heroBase + BurtonHero.maggott.rawValue]),
        // The two Victors, Van Dawt and Frankenstien, both pale, dark-haired boys called Victor
        rivals: [UniverseFacts.heroBase + BurtonHero.victorVanDawt.rawValue,
                 UniverseFacts.heroBase + BurtonHero.victorFrankenstien.rawValue]
    )
}
