import Foundation

// The DC universe (Justice League: Clawd Wars' cast): 110 heroes, 97 villains and 43 places. Any character can lead a
// session (drawn large) or be an agent (small). Who they are, how they fight and how they move is a `Persona`,
// registered in one of the Art/*.swift files next to its drawing code; who lives where, who fights whom first and who
// gets picked up is decided here, in `detectiveTheme`.
//
// Ids are stored in the status file: `Universe.dc.base` plus `DetectiveVillain.rawValue` (< 100) or 100 + `DetectiveHero.rawValue`.
// Only ever append cases, so running sessions keep their characters across an update.

extension DetectiveHero {
    var persona: Persona { dcHeroPersonas[self] ?? Persona.missing(String(describing: self)) }
}

extension DetectiveVillain {
    var persona: Persona { dcVillainPersonas[self] ?? Persona.missing(String(describing: self)) }
}

private let dcHeroPersonas: [DetectiveHero: Persona] = detectiveHeroes1.merging(detectiveHeroes2) { a, _ in a }.merging(detectiveHeroes3) { a, _ in a }
    .merging(detectiveHeroes4) { a, _ in a }.merging(detectiveHeroes5) { a, _ in a }.merging(detectiveHeroes6) { a, _ in a }
    .merging(detectiveHeroes7) { a, _ in a }.merging(detectiveHeroes8) { a, _ in a }.merging(detectiveHeroes9) { a, _ in a }
    .merging(detectiveHeroes10) { a, _ in a }.merging([.hem: hemPersona(.dc)]) { a, _ in a }
private let dcVillainPersonas: [DetectiveVillain: Persona] = detectiveVillains1.merging(detectiveVillains2) { a, _ in a }.merging(detectiveVillains3) { a, _ in a }
    .merging(detectiveVillains4) { a, _ in a }.merging(detectiveVillains5) { a, _ in a }.merging(detectiveVillains6) { a, _ in a }
    .merging(detectiveVillains7) { a, _ in a }.merging(detectiveVillains8) { a, _ in a }.merging(detectiveVillains9) { a, _ in a }

// MARK: - Homes

extension Location {
    static func dcHome(of leader: DetectiveVillain) -> Location {
        switch leader {
        case .joker, .jokerGoon: return .aceChemicals
        case .harleyQuinn, .riddler, .scarecrow, .poisonIvy, .mrFreeze, .killerCroc, .madHatter, .zsasz, .calendarMan: return .arkham
        case .penguin, .twoFace, .bane, .clayface, .hush, .firefly, .manBat, .ventriloquist, .blackMask: return .gotham
        case .rasAlGhul, .talia, .cheshire, .leagueAssassin: return .nandaParbat
        case .deathstroke, .trigon, .brotherBlood: return .titansTower
        case .talon: return .wayneManor
        case .lexLuthor, .doctorPoison: return .lexCorp
        case .generalZod, .ursa: return .phantomZone
        case .brainiac: return .kandor
        case .doomsday: return .krypton
        case .bizarro, .mrMxyzptlk, .livewire: return .metropolis
        case .metallo, .parasite, .toyman: return .strykersIsland
        case .darkseid, .steppenwolf, .desaad, .grannyGoodness, .kalibak, .parademon: return .apokolips
        case .lobo, .mongul, .despero, .cyborgSuperman: return .warworld
        case .antiMonitor, .parallax, .manhunter: return .oa
        case .sinestro, .atrocitus, .larfleeze, .dexStarr: return .korugar
        case .amazo, .eclipso, .giganta, .vandalSavage, .monsieurMallah, .copperhead: return .hallOfDoom
        case .starro, .maxwellLord: return .watchtower
        case .reverseFlash, .zoom, .savitar: return .speedForce
        case .captainCold, .heatWave, .mirrorMaster, .weatherWizard, .trickster: return .ironHeights
        case .gorillaGrodd: return .gorillaCity
        case .captainBoomerang, .deadshot, .amandaWaller, .enchantress: return .belleReve
        case .goldenGlider: return .centralCity
        case .cheetah, .ares, .circe, .silverSwan: return .themyscira
        case .blackManta, .oceanMaster, .trench: return .atlantis
        case .blackAdam, .kobraAgent: return .kahndaq
        case .doctorSivana, .mrMind: return .fawcettCity
        case .solomonGrundy, .gentlemanGhost: return .bayou
        case .felixFaust, .klarion: return .houseOfMystery
        case .killerFrost: return .starLabs
        case .blackHand, .starSapphire: return .coastCity
        }
    }

    static func dcHome(of hero: DetectiveHero) -> Location {
        switch hero {
        case .superman, .krypto, .beppo: return .fortressOfSolitude
        case .batman, .robin, .orphan, .aceTheBatHound: return .batcave
        case .wonderWoman, .artemis, .donnaTroy, .nubia, .hippolyta, .steveTrevor: return .themyscira
        case .flash, .jesseQuick, .elongatedMan: return .centralCity
        case .greenLantern: return .coastCity
        case .aquaman, .aqualad, .mera: return .atlantis
        case .cyborg, .firestorm: return .starLabs
        case .martianManhunter, .simonBaz, .adamStrange, .redTornado, .captainAtom: return .watchtower
        case .greenArrow, .blackCanary, .arsenal: return .starCity
        case .shazam, .phantomStranger: return .rockOfEternity
        case .nightwing: return .bludhaven
        case .batgirl, .redHood, .catwoman, .huntress, .batwoman, .spoiler, .commissionerGordon, .ragman, .hem: return .gotham
        case .redRobin, .raven, .beastBoy, .starfire, .wonderGirl: return .titansTower
        case .supergirl: return .kandor
        case .superboy, .jonKent, .streaky: return .smallville
        case .powerGirl, .steel, .loisLane, .jimmyOlsen, .blackLightning: return .metropolis
        case .alfred, .luciusFox: return .wayneManor
        case .johnStewart, .guyGardner, .kyleRayner, .jessicaCruz, .kilowog, .tomarRe, .chP: return .oa
        case .hawkman, .hawkgirl: return .thanagar
        case .wallyWest, .impulse: return .speedForce
        case .jayGarrick, .alanScott, .doctorFate, .hourman, .stargirl, .wildcat, .atomSmasher, .cyclone, .sandman: return .jsaHQ
        case .doctorMidnite, .mrTerrific, .blueBeetle, .theAtom, .plasticMan, .vixen, .theQuestion, .metamorpho, .zan, .jayna, .gleek: return .hallOfJustice
        case .zatanna, .constantine, .spectre, .madameXanadu: return .houseOfMystery
        case .swampThing, .animalMan: return .bayou
        case .deadman, .katana: return .nandaParbat
        case .etrigan, .dream: return .theDreaming
        case .boosterGold, .saturnGirl, .cosmicBoy, .lightningLad: return .legionHQ
        case .mrMiracle, .bigBarda, .orion: return .newGenesis
        case .peacemaker, .bloodsport, .ratcatcher2, .kingShark, .polkaDotMan: return .belleReve
        }
    }
}

// MARK: - The theme

extension Cast {
    static func hero(_ h: DetectiveHero) -> Cast { Cast(universe: .dc, isDark: false, index: h.rawValue) }
    static func villain(_ v: DetectiveVillain) -> Cast { Cast(universe: .dc, isDark: true, index: v.rawValue) }
}

/// Arch-enemies: whenever both are fighting, they're paired with each other first, wherever they are in the line.
private let dcNemeses: [(DetectiveHero, DetectiveVillain)] = [
    (.superman, .lexLuthor), (.superman, .doomsday), (.superman, .generalZod), (.superman, .brainiac),
    (.superman, .darkseid), (.superman, .bizarro), (.superman, .metallo), (.superman, .parasite),
    (.batman, .joker), (.batman, .bane), (.batman, .rasAlGhul), (.batman, .riddler), (.batman, .twoFace),
    (.batman, .scarecrow), (.batman, .hush), (.batman, .penguin), (.batman, .mrFreeze), (.batman, .killerCroc),
    (.wonderWoman, .cheetah), (.wonderWoman, .ares), (.wonderWoman, .circe), (.wonderWoman, .maxwellLord),
    (.flash, .reverseFlash), (.flash, .captainCold), (.flash, .gorillaGrodd), (.flash, .mirrorMaster), (.flash, .savitar),
    (.wallyWest, .zoom), (.impulse, .zoom), (.flash, .heatWave), (.flash, .weatherWizard), (.flash, .trickster),
    (.greenLantern, .sinestro), (.greenLantern, .parallax), (.greenLantern, .blackHand), (.greenLantern, .starSapphire),
    (.johnStewart, .sinestro), (.guyGardner, .atrocitus), (.kyleRayner, .parallax), (.jessicaCruz, .larfleeze),
    (.kilowog, .manhunter), (.simonBaz, .blackHand), (.aquaman, .blackManta), (.aquaman, .oceanMaster),
    (.mera, .trench), (.aqualad, .blackManta), (.cyborg, .darkseid), (.cyborg, .steppenwolf), (.cyborg, .parademon),
    (.martianManhunter, .despero), (.greenArrow, .deathstroke), (.arsenal, .cheshire), (.blackCanary, .copperhead),
    (.shazam, .blackAdam), (.shazam, .doctorSivana), (.shazam, .mrMind), (.robin, .talia), (.robin, .leagueAssassin),
    (.nightwing, .deathstroke), (.nightwing, .blackMask), (.redHood, .joker), (.redRobin, .talon), (.batgirl, .killerCroc),
    (.batwoman, .madHatter), (.spoiler, .blackMask), (.orphan, .cheshire), (.commissionerGordon, .joker),
    (.huntress, .zsasz), (.catwoman, .penguin), (.supergirl, .ursa), (.supergirl, .cyborgSuperman),
    (.superboy, .lexLuthor), (.steel, .toyman), (.powerGirl, .mrMxyzptlk), (.jonKent, .livewire),
    (.hawkman, .vandalSavage), (.hawkman, .gentlemanGhost), (.hawkgirl, .gentlemanGhost), (.raven, .trigon),
    (.beastBoy, .brotherBlood), (.starfire, .brotherBlood), (.wonderGirl, .giganta), (.alanScott, .solomonGrundy),
    (.doctorFate, .klarion), (.zatanna, .felixFaust), (.constantine, .felixFaust), (.spectre, .eclipso),
    (.swampThing, .solomonGrundy), (.mrMiracle, .grannyGoodness), (.bigBarda, .grannyGoodness), (.orion, .darkseid),
    (.orion, .kalibak), (.boosterGold, .maxwellLord), (.blueBeetle, .maxwellLord), (.firestorm, .killerFrost),
    (.blackLightning, .livewire), (.katana, .leagueAssassin), (.hippolyta, .ares), (.steveTrevor, .doctorPoison),
    (.artemis, .cheetah), (.donnaTroy, .silverSwan), (.peacemaker, .amandaWaller), (.bloodsport, .deadshot),
    (.kingShark, .trench), (.redTornado, .amazo), (.captainAtom, .eclipso), (.adamStrange, .starro),
    (.martianManhunter, .starro), (.theQuestion, .vandalSavage), (.elongatedMan, .goldenGlider),
    (.lightningLad, .weatherWizard), (.dream, .desaad), (.jayGarrick, .savitar), (.kyleRayner, .mongul),
    (.superman, .mongul), (.greenLantern, .antiMonitor), (.jesseQuick, .captainBoomerang), (.atomSmasher, .giganta),
    (.cyclone, .weatherWizard), (.stargirl, .solomonGrundy), (.wildcat, .monsieurMallah), (.vixen, .copperhead),
    (.animalMan, .manBat), (.ragman, .clayface), (.mrTerrific, .lexLuthor), (.theAtom, .lobo),
]

/// When these agents are done, their ship comes to pick them up instead of them just fading out.
private let javelinCrew: [DetectiveHero] = [.greenArrow, .blackCanary, .vixen, .theQuestion, .mrTerrific, .steveTrevor, .blackLightning,
                                     .elongatedMan, .plasticMan, .zan, .jayna]
private let batwingCrew: [DetectiveHero] = [.batman, .robin, .nightwing, .batgirl, .redRobin, .batwoman, .orphan, .spoiler, .redHood,
                                     .huntress]

let detectiveTheme = Theme(
    universe: .dc,
    villains: DetectiveVillain.allCases.map(\.persona),
    heroes: DetectiveHero.allCases.map(\.persona),
    places: [.watchtower, .metropolis, .gotham, .batcave, .fortressOfSolitude, .themyscira, .atlantis, .hallOfJustice, .arkham,
             .centralCity, .starCity, .oa, .apokolips, .krypton, .titansTower, .smallville, .strykersIsland, .belleReve,
             .nandaParbat, .houseOfMystery, .rockOfEternity, .newGenesis, .thanagar, .kandor, .phantomZone, .kahndaq,
             .ironHeights, .speedForce, .wayneManor, .legionHQ, .aceChemicals, .lexCorp, .bayou, .theDreaming, .coastCity,
             .gorillaCity, .korugar, .warworld, .bludhaven, .jsaHQ, .fawcettCity, .starLabs, .hallOfDoom],
    home: { c in
        c.isDark ? .dcHome(of: DetectiveVillain(rawValue: c.index) ?? .joker) : .dcHome(of: DetectiveHero(rawValue: c.index) ?? .superman)
    },
    nemeses: dcNemeses.map { (.hero($0.0), .villain($0.1)) },
    ride: { c in
        guard c.universe == .dc, !c.isDark, let h = DetectiveHero(rawValue: c.index) else { return nil }
        return javelinCrew.contains(h) ? .javelin : batwingCrew.contains(h) ? .batwing : nil
    },
    menuIcon: detectiveDrawCShieldIcon,
    legend: .hero(.superman))

// MARK: - Places

extension Location {
    static let metropolis = Location("metropolis")
    static let gotham = Location("gotham")
    static let batcave = Location("batcave")
    static let fortressOfSolitude = Location("fortressOfSolitude")
    static let themyscira = Location("themyscira")
    static let atlantis = Location("atlantis")
    static let watchtower = Location("watchtower")
    static let hallOfJustice = Location("hallOfJustice")
    static let arkham = Location("arkham")
    static let centralCity = Location("centralCity")
    static let starCity = Location("starCity")
    static let oa = Location("oa")
    static let apokolips = Location("apokolips")
    static let krypton = Location("krypton")
    static let titansTower = Location("titansTower")
    static let smallville = Location("smallville")
    static let strykersIsland = Location("strykersIsland")
    static let belleReve = Location("belleReve")
    static let nandaParbat = Location("nandaParbat")
    static let houseOfMystery = Location("houseOfMystery")
    static let rockOfEternity = Location("rockOfEternity")
    static let newGenesis = Location("newGenesis")
    static let thanagar = Location("thanagar")
    static let kandor = Location("kandor")
    static let phantomZone = Location("phantomZone")
    static let kahndaq = Location("kahndaq")
    static let ironHeights = Location("ironHeights")
    static let speedForce = Location("speedForce")
    static let wayneManor = Location("wayneManor")
    static let legionHQ = Location("legionHQ")
    static let aceChemicals = Location("aceChemicals")
    static let lexCorp = Location("lexCorp")
    static let bayou = Location("bayou")
    static let theDreaming = Location("theDreaming")
    static let coastCity = Location("coastCity")
    static let gorillaCity = Location("gorillaCity")
    static let korugar = Location("korugar")
    static let warworld = Location("warworld")
    static let bludhaven = Location("bludhaven")
    static let jsaHQ = Location("jsaHQ")
    static let fawcettCity = Location("fawcettCity")
    static let starLabs = Location("starLabs")
    static let hallOfDoom = Location("hallOfDoom")
}

/// Every DC place, from the Places/DetectiveScenes*.swift files.
let detectivePlaces: [Location: Place] = detectiveScenes1.merging(detectiveScenes2) { a, _ in a }.merging(detectiveScenes3) { a, _ in a }
    .merging(detectiveScenes4) { a, _ in a }.merging(detectiveScenes5) { a, _ in a }.merging(detectiveScenes6) { a, _ in a }
    .merging(detectiveScenes7) { a, _ in a }
