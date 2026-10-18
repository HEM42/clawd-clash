import Foundation

// Marvelous Clawds's facts: its cast's enums and what the hook, the app and the screen saver need to know about it. Plain data,
// no drawing: the hook compiles this file too. The enums' order is the ids, so only ever append cases (HEM stays last)
// and never reorder or remove one: running sessions keep their characters across an update.

enum MarvelHero: Int, CaseIterable {
    // Avengers
    case ironMan, captainAmerica, thor, hulk, blackWidow, hawkeye, spiderMan, blackPanther, doctorStrange, scarletWitch
    case vision, captainMarvel
    // More Avengers and the Guardians of the Galaxy
    case antMan, wasp, falcon, winterSoldier, starLord, gamora, drax, rocket, groot, mantis, nickFury, sheHulk
    // X-Men
    case wolverine, cyclops, storm, jeanGrey, professorX, beast, nightcrawler, gambit, rogue, iceman, colossus
    // Fantastic Four, the street and the rest
    case humanTorch, thing, mrFantastic, invisibleWoman, silverSurfer, daredevil, deadpool, shangChi, msMarvel
    case moonKnight, ghostRider
    // War Machine, the Maximoff kids, Wakanda and Sakaar.
    case warMachine, wiccan, speed, quicksilver, kateBishop, yelena, okoye, shuri, valkyrie, korg
    // Kamar-Taj, the cosmos and the younger X-Men.
    case wong, hercules, sentry, cosmo, kraglin, adamWarlock, nova, kittyPryde, jubilee, psylocke
    // more X-Men and the Spider-heroes.
    case bishop, cable, havok, emmaFrost, banshee, angel, domino, x23, milesMorales, spiderGwen
    // the street, Defenders, Punisher, Blade and friends.
    case spiderWoman, blackCat, lukeCage, ironFist, jessicaJones, punisher, elektra, blade, blackKnight
    // mystics, cosmic and the funny ones.
    case monicaRambeau, clea, doctorVoodoo, howardTheDuck, squirrelGirl, jeffTheLandShark, throg, lockjaw, forbushMan
    // The TVA, the Red Room, the Savage Land, Stark's workshop and Ta Lo
    case mobius, sylvie, kidLoki, alligatorLoki, hunterB15, redGuardian, kaZar, rescue, zabu, morris, dumE
    case hem   // always last (`Universe.hem`)

}

enum MarvelVillain: Int, CaseIterable {
    // Cosmic and Avengers foes
    case thanos, loki, ultron, redSkull, doctorDoom, hela, ronan, nebula, ebonyMaw, chitauri, grandmaster, ultronSentry
    // Spider-Man's rogues
    case greenGoblin, venom, carnage, docOck, mysterio, electro, vulture, rhino, sandman, lizard, kraven
    // Mutants, monsters and machines
    case magneto, juggernaut, sabretooth, mystique, apocalypse, sentinel, abomination, finFangFoom, modok, dormammu
    case doombot
    // The street, spies and soldiers
    case kingpin, bullseye, handNinja, hydraAgent, aimAgent, skrull, taskmaster, zemo, whiplash, mandarin, killmonger
    case batroc
    // cosmic powers and more of Spider-Man's rogues.
    case galactus, kang, mephisto, knull, annihilus, highEvolutionary, morganLeFay, scorpion, shocker, hobgoblin
    // the street and the mutant foes.
    case morbius, misterNegative, chameleon, tombstone, misterSinister, omegaRed, toad, pyro, blob
    // aliens, Avengers foes and sorcerers.
    case brood, cassandraNova, graviton, absorbingMan, crimsonDynamo, wrecker, baronMordo, enchantress, arnimZola
    // gamma, Asgard's enemies and foot soldiers.
    case countNefaria, theLeader, maestro, malekith, surtur, kurse, frostGiant, hydraSuperSoldier, kreeSoldier
    // The TVA, the Morlock Tunnels, Asteroid M, Ta Lo and the Red Room
    case missMinutes, callisto, exodus, soulEater, redRoomWidow


}

enum MarvelousFacts {
    static let facts = UniverseFacts(
        villainCount: MarvelVillain.allCases.count, heroCount: MarvelHero.allCases.count,
        agentOnly: [11, 33, 190, 202, 203, 204]   // Ultron Sentry, Doombot, Jeff, Zabu, Morris, Dum-E
    )
}
