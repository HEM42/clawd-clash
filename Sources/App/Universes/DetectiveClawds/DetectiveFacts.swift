import Foundation

// Detective Clawds's facts: its cast's enums and what the hook, the app and the screen saver need to know about it. Plain data,
// no drawing: the hook compiles this file too. The enums' order is the ids, so only ever append cases (HEM stays last)
// and never reorder or remove one: running sessions keep their characters across an update.

enum DetectiveHero: Int, CaseIterable {
    // The Justice League
    case superman, batman, wonderWoman, flash, greenLantern, aquaman, cyborg, martianManhunter, greenArrow, blackCanary
    case shazam
    // The Bat-family and Gotham
    case robin, nightwing, batgirl, redHood, redRobin, catwoman, huntress, batwoman, orphan, spoiler
    case commissionerGordon
    // The Super-family and Metropolis
    case supergirl, superboy, powerGirl, steel, jonKent, loisLane, jimmyOlsen, alfred, luciusFox, krypto
    // The Green Lantern Corps and the Thanagarians
    case johnStewart, guyGardner, kyleRayner, jessicaCruz, simonBaz, kilowog, tomarRe, chP, adamStrange, hawkman
    case hawkgirl
    // Speedsters and the Teen Titans
    case wallyWest, jayGarrick, impulse, jesseQuick, raven, beastBoy, starfire, wonderGirl, aqualad, arsenal
    // The Justice Society
    case alanScott, doctorFate, hourman, stargirl, wildcat, atomSmasher, cyclone, doctorMidnite, sandman, mrTerrific
    // Justice League Dark
    case zatanna, constantine, swampThing, deadman, spectre, etrigan, madameXanadu, phantomStranger, ragman, dream
    // Justice League International and friends
    case blueBeetle, boosterGold, theAtom, firestorm, plasticMan, elongatedMan, vixen, blackLightning, theQuestion, metamorpho
    case redTornado, captainAtom
    // Amazons, Atlanteans, New Gods and more
    case mera, artemis, donnaTroy, nubia, hippolyta, steveTrevor, mrMiracle, bigBarda, orion, animalMan
    case katana
    // The Suicide Squad, the Legion, the Wonder Twins and the pets
    case peacemaker, bloodsport, ratcatcher2, kingShark, polkaDotMan, saturnGirl, cosmicBoy, lightningLad, zan, jayna
    case aceTheBatHound, streaky, gleek, beppo
    case hem   // always last (`Universe.hem`)

}

enum DetectiveVillain: Int, CaseIterable {
    // Batman's rogues
    case joker, harleyQuinn, penguin, riddler, twoFace, scarecrow, poisonIvy, mrFreeze, bane, killerCroc
    case rasAlGhul
    // More of Gotham's worst
    case talia, deathstroke, madHatter, clayface, hush, zsasz, firefly, manBat, ventriloquist, talon
    case calendarMan, jokerGoon
    // Superman's rogues
    case lexLuthor, generalZod, ursa, brainiac, doomsday, bizarro, metallo, parasite, toyman, mrMxyzptlk
    case livewire
    // Apokolips and the cosmic tyrants
    case darkseid, steppenwolf, desaad, grannyGoodness, kalibak, parademon, lobo, mongul, trigon, antiMonitor
    // The other Corps, androids and alien conquerors
    case sinestro, atrocitus, larfleeze, parallax, manhunter, dexStarr, amazo, starro, despero, eclipso
    // The Flash's Rogues and the evil speedsters
    case reverseFlash, zoom, captainCold, heatWave, mirrorMaster, gorillaGrodd, weatherWizard, captainBoomerang, trickster, savitar
    case goldenGlider
    // Wonder Woman's and Aquaman's foes
    case cheetah, ares, circe, maxwellLord, doctorPoison, giganta, silverSwan, blackManta, oceanMaster, trench
    // Shazam, the Titans, the JSA and the Legion of Doom
    case blackAdam, doctorSivana, mrMind, brotherBlood, solomonGrundy, vandalSavage, felixFaust, klarion, monsieurMallah, gentlemanGhost
    case blackMask
    // The Squad, the assassins and the ring-wielders
    case deadshot, killerFrost, amandaWaller, enchantress, copperhead, cheshire, blackHand, cyborgSuperman, leagueAssassin, kobraAgent
    case starSapphire


}

extension Universe {
    /// Detective Clawds: number 2, for good (its ids are 2000 and up).
    static let dc = Universe(number: 2)
}

enum DetectiveFacts {
    static let entry = UniverseEntry(universe: .dc, key: "dc", title: "Detective Clawds", facts: facts)
    static let facts = UniverseFacts(
        villainCount: DetectiveVillain.allCases.count, heroCount: DetectiveHero.allCases.count,
        // Joker Goon, Dex-Starr, Mister Mind, Krypto, Ch'p, Ace the Bat-Hound, Streaky, Gleek, Beppo
        agentOnly: [22, 49, 77, 131, 139, 206, 207, 208, 209]
    )
}
