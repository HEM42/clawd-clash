import Foundation

// The Clawd Files's facts: its cast's enums and what the hook, the app and the screen saver need to know about it. Plain data,
// no drawing: the hook compiles this file too. The enums' order is the ids, so only ever append cases (HEM stays last)
// and never reorder or remove one: running sessions keep their characters across an update.

enum FilesHero: Int, CaseIterable {
    // The X-Files unit and the FBI
    case foxClawder, danaScrawly
    case skinnard, doggedd, reyez, einstine, millar
    // The Lone Gunclawds
    case bytes, frohack, lanky
    // Informants and allies
    case deepClawt, misterX, marita, gibsonPrays, samantha
    // More of the family, the Gunclawds' friends and the allies
    case jimmyBondd, yvesHarlowe, melissaScrawly, margaretScrawly, teenaClawder, jeffreySpendr, shannonMcMahawk
    case maxFenig, pendrill, arthurDales, clydeBruckclaw, joseChung, leylaHarriclaw, frankBlackclaw
    // Friendly oddities and pets
    case tadOClawley, drBlockclaw, conundrum, sheriffHartwell, queequeg, daggoo
    case hem   // always last (`Universe.hem`)

}

enum FilesVillain: Int, CaseIterable {
    // The Syndicate
    case smokingClawd
    case clawcek, wellManicured, firstElder, dianaFowlclaw, kersh, toothpickMan
    // The aliens and their soldiers
    case bountyHunter, blackOil, grey, facelessRebel, knowleRohrer, billyMiles
    // Monsters of the week
    case tooms, flukeman, pusher, jerseyDevil
    // More of the Syndicate and the aliens
    case strughold, follmer, billClawder, crewCutMan, colonist, duffyHaskell, lordKinbote
    // More monsters of the week
    case leonardBetts, greatMutato, wendigo, chuckleteeth, eve6, virgilIncanto
    case chupacabra, bigBlue, tithonus, cecilLively, lutherLeeBoggs, eddieVanBlundht
    case ronnieStrickland, guyMann, trashman, tulpa, mothmen, rainKing, teliko
    // Agent-only small fry
    case killerBee, roboRoach, flukeworm

}

extension Universe {
    /// The Clawd Files: number 4, for good (its ids are 4000 and up).
    static let clawdFiles = Universe(number: 4)
}

enum FilesFacts {
    static let entry = UniverseEntry(universe: .clawdFiles, key: "clawdFiles", title: "The Clawd Files", facts: facts)
    static let facts = UniverseFacts(
        villainCount: FilesVillain.allCases.count, heroCount: FilesHero.allCases.count,
        agentOnly: [43, 44, 45],             // killer bee, robo-roach, flukeworm
        // The seven FBI agents (Clawder, Scrawly, Skinnard, Doggedd, Reyez, Einstine, Millar): abducted and set back
        // down, the same face (`MissingTime`).
        compaction: .away(who: Set((0...6).map { StatusStore.heroBase + $0 }))
    )
}
