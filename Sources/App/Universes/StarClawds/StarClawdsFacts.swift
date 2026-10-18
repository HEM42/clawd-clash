import Foundation

// Star Clawds's facts: its cast's enums and what the hook, the app and the screen saver need to know about it. Plain data,
// no drawing: the hook compiles this file too. The enums' order is the ids, so only ever append cases (HEM stays last)
// and never reorder or remove one: running sessions keep their characters across an update.

enum SWVillain: Int, CaseIterable {
    case vader, kylo, maul, boba, trooper, emperor, rogr, dooku, gamorrean, jabba, ig88, atst, atat, rancor, greedo, royalGuard
    case sebulba, salacious, grievous, tusken, cadBane, thrawn, hammerhead, mse6, baylan, shinHati, id9, grandInquisitor, secondSister, bantha, bibFortuna
    case watto, moffGideon, deathTrooper, scoutTrooper, ventress, savageOpress, jangoFett, bossk, dengar, droideka, phasma, krennic, tarkin, fifthBrother, reva

}

enum SWHero: Int, CaseIterable {
    case luke, han, leia, obiwan, r2d2, c3po, quigon, mace, yoda, jawa, chewie, rey, ahsoka, ewok, tauntaun
    case jarjar, lando, zorii, boKatan, maz, wedge, l337, monMothma, padme, ackbar
    case grogu, babuFrik, mando, k2so, gonk, cassian, bix, cobbVanth, pitDroid, kuiil
    case hem   // always last (`Universe.hem`)

}

extension Universe {
    /// Star Clawds: number 0, for good (its ids are 0000 and up).
    static let starWars = Universe(number: 0)
}

enum StarClawdsFacts {
    static let entry = UniverseEntry(universe: .starWars, key: "starWars", title: "Star Clawds", facts: facts)
    static let facts = UniverseFacts(
        villainCount: SWVillain.allCases.count, heroCount: SWHero.allCases.count,
        agentOnly: [23, 26],                 // MSE-6, ID9 seeker droid
        claudeSide: nil,
        rivals: [0, 1]                        // Darth Vapor and Kylo Rant
    )
}
