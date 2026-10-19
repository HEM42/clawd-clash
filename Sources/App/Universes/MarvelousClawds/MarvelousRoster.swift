import Foundation

// The Marvel universe: 105 heroes, 88 villains and 43 places. Any character can lead a session (drawn large) or be an
// agent (small). Who they are, how they fight and how they move is a `Persona`, registered in one of the Art/*.swift
// files next to its drawing code; who lives where, who fights whom first and who gets picked up is decided here, in
// `marvelousTheme`.
//
// Ids are stored in the status file: `Universe.marvel.base` plus `MarvelousVillain.rawValue` (< 100) or
// 100 + `MarvelousHero.rawValue`. Only ever append cases, so running sessions keep their characters across an update.

extension MarvelousHero {
    var persona: Persona { heroPersonas[self] ?? Persona.missing(String(describing: self)) }
}

extension MarvelousVillain {
    var persona: Persona { villainPersonas[self] ?? Persona.missing(String(describing: self)) }
}

private let heroPersonas: [MarvelousHero: Persona] = marvelousHeroes1.merging(marvelousHeroes2) { a, _ in a }.merging(marvelousHeroes3) { a, _ in a }
    .merging(marvelousHeroes4) { a, _ in a }
    .merging(marvelousHeroes5) { a, _ in a }.merging(marvelousHeroes6) { a, _ in a }.merging(marvelousHeroes7) { a, _ in a }
    .merging(marvelousHeroes8) { a, _ in a }.merging(marvelousHeroes9) { a, _ in a }
    .merging(marvelousHeroes10) { a, _ in a }.merging([.hem: hemPersona(.marvel)]) { a, _ in a }
private let villainPersonas: [MarvelousVillain: Persona] = marvelousVillains1.merging(marvelousVillains2) { a, _ in a }.merging(marvelousVillains3) { a, _ in a }
    .merging(marvelousVillains4) { a, _ in a }
    .merging(marvelousVillains5) { a, _ in a }.merging(marvelousVillains6) { a, _ in a }.merging(marvelousVillains7) { a, _ in a }
    .merging(marvelousVillains8) { a, _ in a }.merging(marvelousVillains9) { a, _ in a }

// MARK: - Homes

extension Location {
    static func marvelHome(of leader: MarvelousVillain) -> Location {
        switch leader {
        case .thanos, .nebula, .ebonyMaw: return .titan
        case .loki, .hela: return .asgard
        case .ultron, .ultronSentry, .whiplash: return .avengersTower
        case .redSkull: return .vormir
        case .doctorDoom, .doombot: return .latveria
        case .ronan: return .knowhere
        case .chitauri, .vulture: return .battleOfNewYork
        case .grandmaster, .abomination, .finFangFoom: return .sakaar
        case .greenGoblin, .venom, .docOck, .mysterio: return .dailyBugle
        case .carnage, .electro, .rhino, .sandman, .taskmaster: return .raft
        case .lizard, .kraven, .sabretooth: return .savageLand
        case .magneto: return .asteroidM
        case .juggernaut, .mystique, .sentinel: return .xMansion
        case .apocalypse: return .krakoa
        case .modok, .hydraAgent, .aimAgent, .zemo: return .hydraBase
        case .dormammu: return .darkDimension
        case .kingpin, .bullseye, .handNinja: return .hellsKitchen
        case .skrull, .batroc: return .helicarrier
        case .mandarin: return .kamarTaj
        case .killmonger: return .wakanda
        case .galactus: return .worldship
        case .kang: return .quantumRealm
        case .mephisto, .knull: return .darkDimension
        case .annihilus: return .baxterBuilding
        case .highEvolutionary: return .knowhere
        case .morganLeFay: return .latveria
        case .scorpion, .chameleon, .absorbingMan, .theLeader: return .raft
        case .shocker, .hobgoblin: return .dailyBugle
        case .morbius, .omegaRed, .countNefaria: return .madripoor
        case .misterNegative, .tombstone: return .harlem
        case .misterSinister, .toad, .pyro, .cassandraNova: return .genosha
        case .blob: return .xMansion
        case .brood, .kreeSoldier: return .hala
        case .graviton: return .helicarrier
        case .crimsonDynamo, .hydraSuperSoldier: return .sokovia
        case .wrecker: return .battleOfNewYork
        case .baronMordo: return .kamarTaj
        case .enchantress: return .asgard
        case .arnimZola: return .hydraBase
        case .maestro: return .sakaar
        case .malekith, .frostGiant: return .jotunheim
        case .surtur, .kurse: return .muspelheim
        case .missMinutes: return .tva
        case .callisto: return .morlockTunnels
        case .exodus: return .asteroidM
        case .soulEater: return .taLo
        case .redRoomWidow: return .redRoom
        }
    }

    static func marvelHome(of hero: MarvelousHero) -> Location {
        switch hero {
        case .vision, .hem: return .avengersTower
        case .ironMan: return .starkWorkshop
        case .captainAmerica, .blackWidow, .falcon, .nickFury: return .helicarrier
        case .thor: return .asgard
        case .hulk: return .sakaar
        case .hawkeye: return .battleOfNewYork
        case .spiderMan: return .newYorkStreets
        case .blackPanther: return .wakanda
        case .doctorStrange: return .sanctum
        case .scarletWitch, .winterSoldier: return .hydraBase
        case .captainMarvel, .starLord, .drax, .rocket, .groot: return .knowhere
        case .antMan, .wasp: return .quantumRealm
        case .gamora, .silverSurfer: return .titan
        case .mantis: return .egosPlanet
        case .sheHulk, .colossus: return .raft
        case .wolverine, .gambit, .rogue: return .savageLand
        case .cyclops, .storm, .jeanGrey, .professorX, .beast, .nightcrawler, .iceman: return .xMansion
        case .humanTorch, .mrFantastic, .invisibleWoman, .thing: return .baxterBuilding
        case .daredevil, .deadpool, .moonKnight: return .hellsKitchen
        case .shangChi: return .taLo
        case .msMarvel: return .attilan
        case .ghostRider: return .darkDimension
        case .sentry, .blackKnight: return .avengersTower
        case .warMachine: return .avengersCompound
        case .wiccan, .speed, .quicksilver: return .sokovia
        case .kateBishop, .spiderGwen: return .dailyBugle
        case .psylocke, .domino, .x23, .blade: return .madripoor
        case .yelena: return .redRoom
        case .okoye, .shuri: return .wakanda
        case .valkyrie, .korg: return .sakaar
        case .wong: return .kamarTaj
        case .hercules, .throg: return .asgard
        case .cosmo, .kraglin, .adamWarlock, .howardTheDuck: return .knowhere
        case .monicaRambeau: return .hala
        case .nova: return .xandar
        case .kittyPryde, .jubilee, .banshee, .angel: return .xMansion
        case .bishop, .cable, .havok: return .genosha
        case .emmaFrost: return .krakoa
        case .milesMorales, .lukeCage: return .harlem
        case .spiderWoman: return .helicarrier
        case .blackCat, .jessicaJones, .punisher: return .hellsKitchen
        case .ironFist, .elektra: return .kunLun
        case .clea: return .darkDimension
        case .doctorVoodoo: return .sanctum
        case .squirrelGirl, .jeffTheLandShark, .forbushMan: return .baxterBuilding
        case .lockjaw: return .attilan
        case .mobius, .sylvie, .kidLoki, .alligatorLoki, .hunterB15: return .tva
        case .redGuardian: return .redRoom
        case .kaZar, .zabu: return .savageLandCitadel
        case .rescue: return .avengersCompound
        case .morris: return .taLo
        case .dumE: return .starkWorkshop
        }
    }
}

// MARK: - The theme

extension Cast {
    static func hero(_ h: MarvelousHero) -> Cast { Cast(universe: .marvel, isDark: false, index: h.rawValue) }
    static func villain(_ v: MarvelousVillain) -> Cast { Cast(universe: .marvel, isDark: true, index: v.rawValue) }
}

/// Arch-enemies: whenever both are fighting, they're paired with each other first, wherever they are in the line.
private let marvelNemeses: [(MarvelousHero, MarvelousVillain)] = [
    (.captainAmerica, .redSkull), (.thor, .loki), (.spiderMan, .greenGoblin), (.spiderMan, .venom),
    (.wolverine, .sabretooth), (.blackPanther, .killmonger), (.doctorStrange, .dormammu), (.hulk, .abomination),
    (.vision, .ultron), (.ironMan, .ultron), (.daredevil, .kingpin), (.daredevil, .bullseye), (.gamora, .nebula),
    (.starLord, .ronan), (.thor, .hela), (.shangChi, .mandarin), (.mrFantastic, .doctorDoom),
    (.blackWidow, .taskmaster), (.ironMan, .whiplash), (.captainMarvel, .skrull), (.cyclops, .magneto),
    (.storm, .apocalypse), (.captainAmerica, .zemo),
    (.silverSurfer, .galactus), (.antMan, .kang), (.ghostRider, .mephisto), (.doctorStrange, .baronMordo),
    (.thor, .malekith), (.thor, .surtur), (.valkyrie, .hela), (.punisher, .kingpin), (.wolverine, .omegaRed),
    (.cyclops, .misterSinister), (.hulk, .theLeader), (.hulk, .maestro), (.blade, .morbius), (.elektra, .bullseye),
    (.spiderMan, .scorpion), (.milesMorales, .hobgoblin), (.rocket, .highEvolutionary), (.captainMarvel, .kreeSoldier),
    (.lukeCage, .tombstone), (.ironFist, .handNinja), (.thor, .absorbingMan), (.mrFantastic, .annihilus),
    (.ironMan, .crimsonDynamo), (.thor, .frostGiant), (.spiderGwen, .lizard),
    (.sylvie, .missMinutes), (.blackWidow, .redRoomWidow), (.shangChi, .soulEater), (.storm, .callisto), (.cyclops, .exodus),
]

/// When these agents are done, their ship comes to pick them up instead of them just fading out.
private let quinjetCrew: [MarvelousHero] = [.captainAmerica, .blackWidow, .hawkeye, .nickFury, .hulk, .kateBishop, .yelena]
private let milanoCrew: [MarvelousHero] = [.starLord, .gamora, .drax, .rocket, .groot, .mantis, .kraglin, .cosmo]

let marvelousTheme = Theme(
    universe: .marvel,
    villains: MarvelousVillain.allCases.map(\.persona),
    heroes: MarvelousHero.allCases.map(\.persona),
    places: [.avengersTower, .sanctum, .wakanda, .asgard, .sakaar, .knowhere, .titan, .helicarrier, .xMansion, .hellsKitchen,
             .vormir, .quantumRealm, .latveria, .hydraBase, .dailyBugle, .egosPlanet, .kamarTaj, .raft, .battleOfNewYork,
             .darkDimension, .attilan, .savageLand, .baxterBuilding, .jotunheim, .muspelheim, .hala, .genosha, .madripoor,
             .sokovia, .worldship, .harlem, .kunLun, .xandar, .avengersCompound, .tva, .krakoa, .morlockTunnels, .asteroidM,
             .newYorkStreets, .savageLandCitadel, .starkWorkshop, .redRoom, .taLo],
    home: { c in
        c.isDark ? .marvelHome(of: MarvelousVillain(rawValue: c.index) ?? .thanos) : .marvelHome(of: MarvelousHero(rawValue: c.index) ?? .ironMan)
    },
    nemeses: marvelNemeses.map { (.hero($0.0), .villain($0.1)) },
    ride: { c in
        guard c.universe == .marvel, !c.isDark, let h = MarvelousHero(rawValue: c.index) else { return nil }
        return quinjetCrew.contains(h) ? .quinjet : milanoCrew.contains(h) ? .milano : nil
    },
    menuIcon: drawMenuBarShield,
    legend: .hero(.ironMan))

// MARK: - Places

extension Location {
    static let avengersTower = Location("avengersTower"), sanctum = Location("sanctum"), wakanda = Location("wakanda")
    static let asgard = Location("asgard"), sakaar = Location("sakaar"), knowhere = Location("knowhere"), titan = Location("titan")
    static let helicarrier = Location("helicarrier"), xMansion = Location("xMansion"), hellsKitchen = Location("hellsKitchen")
    static let vormir = Location("vormir"), quantumRealm = Location("quantumRealm"), latveria = Location("latveria")
    static let hydraBase = Location("hydraBase"), dailyBugle = Location("dailyBugle"), egosPlanet = Location("egosPlanet")
    static let kamarTaj = Location("kamarTaj"), raft = Location("raft"), battleOfNewYork = Location("battleOfNewYork")
    static let darkDimension = Location("darkDimension"), attilan = Location("attilan"), savageLand = Location("savageLand")
    static let baxterBuilding = Location("baxterBuilding"), jotunheim = Location("jotunheim"), muspelheim = Location("muspelheim")
    static let hala = Location("hala"), genosha = Location("genosha"), madripoor = Location("madripoor"), sokovia = Location("sokovia")
    static let worldship = Location("worldship"), harlem = Location("harlem"), kunLun = Location("kunLun"), xandar = Location("xandar")
    static let avengersCompound = Location("avengersCompound"), tva = Location("tva"), krakoa = Location("krakoa")
    static let morlockTunnels = Location("morlockTunnels"), asteroidM = Location("asteroidM")
    static let newYorkStreets = Location("newYorkStreets"), savageLandCitadel = Location("savageLandCitadel")
    static let starkWorkshop = Location("starkWorkshop"), redRoom = Location("redRoom"), taLo = Location("taLo")
}

/// Every Marvel place, from the Places/MarvelousScenes*.swift files.
let marvelousPlaces: [Location: Place] = marvelousScenes1.merging(marvelousScenes2) { a, _ in a }.merging(marvelousScenes3) { a, _ in a }
    .merging(marvelousScenes4) { a, _ in a }.merging(marvelousScenes5) { a, _ in a }.merging(marvelousScenes6) { a, _ in a }.merging(marvelousScenes7) { a, _ in a }
