import Foundation

// Stevie Clawdberg's facts: its cast's enums and what the hook, the app and the screen saver need to know about it. Plain data,
// no drawing: the hook compiles this file too. The enums' order is the ids, so only ever append cases (HEM stays last)
// and never reorder or remove one: running sessions keep their characters across an update.

enum ClawdbergHero: Int, CaseIterable {
    // Gremlins
    case billyPeltclawd, kateBeringer, gizmoe, randPeltclawd, lynnPeltclawd, mrWing, futterclaw, grandpaDread
    // E.T.
    case eClawd, elliclawd, gurtie
    // Jaws
    case chiefBroody, hoopah, squint
    // The Goonies
    case mikeyWaltz, brandWaltz, chunk, mouth, data, andyCarmichaw, stefSteinclawd, slawth
    // Indiana Jones
    case indianaBones, marion, shortRounds, willieScoot, sallaw, henryBones, marcusBrodie, grailKnight, mutt, helenaShore
    // Jurassic Park
    case alanGrand, ellieSaddler, ianMalclawm, johnHammend, muldune, timMurphey, lexMurphey, rayArnie, owenGravy
    case claireDaring, blue, trike
    // Close Encounters
    case royNeery, jillianGeyser, littleBarry, clawdLacombe, tallVisitor
    // Hook
    case peterPanning, tinkerbelle, roofio, thudButt, jackBanning, tootles
    // Back to the Future
    case martyMcFry, docBrawn, jenniferParka, georgeMcFry, lorraineBaynes, einsteinDog, claraClawton, goldieWilsun
    case hem   // always last (`Universe.hem`)

}

enum ClawdbergVillain: Int, CaseIterable {
    // Gremlins
    case strype, mohawk, theBrain, batGremlin, electricGremlin, greta, daffy, mrsDeegle, drClawtheter
    // E.T.
    case keyz, spacesuitMan
    // Jaws
    case bruise, mayorVaun
    // The Goonies
    case mamaFratelly, jakeFratelly, francisFratelly, troyPerkins, elginPerkins, oneEyedWilly
    // Indiana Jones
    case reneBellock, majorTote, cairoSwordsman, mechanic, molaRamm, laoChay, colonelVogle, walterDonnervan
    case elsaSnyder, irinaSpalco, jurgenVollar, maharajah
    // Jurassic Park
    case tWrecks, cleverGirl, spitter, dennisNerdry, indominusRex, gennarrow, drWoo
    // Close Encounters
    case majorMildBill, gasMaskTrooper
    // Hook
    case captainClawk, mrSmeeh, billJukes
    // Back to the Future
    case biffTannin, oldBiff, griffTannin, madDogTannin, mrStricklaw, needles
    // Agent-only small fry
    case compy, mogwaiPup, snake, frog, crocClock

}

extension Universe {
    /// Stevie Clawdberg: number 5, for good (its ids are 5000 and up).
    static let clawdberg = Universe(number: 5)
}

enum ClawdbergFacts {
    static let entry = UniverseEntry(universe: .clawdberg, key: "clawdberg", title: "Stevie Clawdberg", facts: facts)
    static let facts = UniverseFacts(
        villainCount: ClawdbergVillain.allCases.count, heroCount: ClawdbergHero.allCases.count,
        agentOnly: Set(49...53),             // Compy, mogwai pup, snake, frog, Croc Clock
        // Back to the Future's time travellers (Marty, Doc Brawn, Jennifer, Einstein the Dog, and Old Biff, who stole the
        // DeLorean): they hit 88 mph and come back (`ClawdbergOutaTime`).
        compaction: .away(who: Set([55, 56, 57, 60].map { UniverseFacts.heroBase + $0 } + [44]))
    )
}
