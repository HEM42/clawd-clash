import Foundation

// Clawd Burton: the director's gothic-but-warm universe. One ensemble from The Nightmare Before Christmas, Beetlejuice
// (and Beetlejuice Beetlejuice), Edward Scissorhands, Corpse Bride, Sleepy Hollow, Mars Attacks!, Charlie and the
// Chocolate Factory, Alice in Wonderland, Frankenweenie and Pee-wee's Big Adventure. Any character can lead a session
// (drawn large) or be an agent (small). Who they are, how they fight and how they move is a `Persona`, registered in
// one of the Art/*.swift files next to its drawing code; who lives where, who fights whom first and who gets picked up
// is decided here, in `burtonTheme`.
//
// Ids are stored in the status file: `Universe.clawdBurton.base` plus `BurtonVillain.rawValue` (< 100) or
// 100 + `BurtonHero.rawValue`. Only ever append cases (HEM stays last), so running sessions keep their characters
// across an update.

enum BurtonHero: Int, CaseIterable {
    // The Nightmare Before Christmas
    case jackSkullington, sallee, zeero, theMayor, sandyClawz
    // Beetlejuice and Beetlejuice Beetlejuice
    case lydiaDeathz, adamMaitclawd, barbaraMaitclawd, deliaDeathz, astridDeathz, junoh, wolfJaxon, shrunkenHeadMan
    // Edward Scissorhands
    case edwardScissorclaws, kimBoggz, pegBoggz, theInventor
    // Corpse Bride
    case victorVanDawt, emilee, victoriaEverclawt, scrapz, elderGutknocked, bonejingles, generalBonesapart
    // Sleepy Hollow
    case ichabodCraine, katrinaVanTassle, youngMasbeth, bromVanBruntt
    // Mars Attacks!
    case richieNorriss, grandmaFlorenz, presidentDayle, byronWilyums, professorKessclaw
    // Charlie and the Chocolate Factory
    case willyWonky, charlieBuckett, grampaJoe, oompaLoompah, drWilburWonky
    // Alice in Wonderland
    case aliceKingsclaw, tarrantHightop, chessur, mirana, mcTwisp, mally, thackeryHare
    // Frankenweenie
    case victorFrankenstien, sparkie, elsaVanHelsclaw, mrRzykrusky
    // Pee-wee's Big Adventure
    case peeweeHerclawd, dottie, largeMarge
    // Agent-only
    case maggott
    case hem   // always last (`Universe.hem`)

    var persona: Persona { burtonHeroPersonas[self] ?? Persona.missing(String(describing: self)) }
}

enum BurtonVillain: Int, CaseIterable {
    // Beetlejuice and Beetlejuice Beetlejuice
    case beetlejooce, sandwurm, delorez, otho, jeremee
    // The Nightmare Before Christmas
    case ooogieBoogie, lok, shok, barrell, drFinkelclawd, wolfclawd, tearAwayClown, halloweenWitch
    // Edward Scissorhands
    case jimm, joyceMonrow
    // Corpse Bride
    case lordBarkissBittern, pastorGallswell, finisEverclawt, maudelineEverclawt
    // Sleepy Hollow
    case headlessHorseclawd, ladyVanTassle, westernWoodsCrone
    // Mars Attacks!
    case martianLeader, martianAmbassador, martianTrooper, martianSpy, martianWalker
    // Charlie and the Chocolate Factory
    case augustusGloopp, verucaSaltt, violetBluregarde, mikeTeevee, slugwurth
    // Alice in Wonderland
    case redQueen, stayne, jabberclawky, bandersnatch, redCardKnight
    // Frankenweenie
    case edgarGorr, nassorr, toshiakki, weirdGurl, mrWhiskerz, shellee, colossuss, wereRat
    // Pee-wee's Big Adventure
    case francisBuxtun, bikeThief, madamRubee, andee
    // Agent-only small fry
    case bob, oogieBug, nutSquirrel, seaMonkey

    var persona: Persona { burtonVillainPersonas[self] ?? Persona.missing(String(describing: self)) }
}

let burtonHeroPersonas: [BurtonHero: Persona] = [burtonHeroes1]
    .reduce([.hem: hemPersona(.clawdBurton)]) { $0.merging($1) { a, _ in a } }
let burtonVillainPersonas: [BurtonVillain: Persona] = [burtonVillains1, burtonVillains2]
    .reduce([:]) { $0.merging($1) { a, _ in a } }

// MARK: - Homes

extension Location {
    static func burtonHome(of leader: BurtonVillain) -> Location {
        switch leader {
        case .beetlejooce, .bob: return .modelWinterRiver
        case .sandwurm: return .sandwormSaturn
        case .delorez, .jeremee: return .afterlifeWaitingRoom
        case .otho: return .maitlandHouse
        case .ooogieBoogie, .oogieBug, .lok, .shok, .barrell: return .oogiesLair
        case .drFinkelclawd, .wolfclawd, .tearAwayClown, .halloweenWitch: return .halloweenTown
        case .jimm, .joyceMonrow: return .pastelSuburbia
        case .lordBarkissBittern, .pastorGallswell, .finisEverclawt, .maudelineEverclawt: return .everglotVillage
        case .headlessHorseclawd, .westernWoodsCrone: return .treeOfTheDead
        case .ladyVanTassle: return .hollowVillage
        case .martianLeader, .martianAmbassador, .martianTrooper, .martianSpy: return .martianSaucerDeck
        case .martianWalker: return .perkinsvilleKansas
        case .augustusGloopp, .verucaSaltt, .violetBluregarde, .mikeTeevee, .slugwurth, .nutSquirrel: return .chocolateRoom
        case .redQueen, .stayne, .jabberclawky, .bandersnatch, .redCardKnight: return .salazenGrum
        case .edgarGorr, .nassorr, .toshiakki, .weirdGurl, .mrWhiskerz, .shellee, .colossuss, .wereRat, .seaMonkey:
            return .windmillMiniGolf
        case .francisBuxtun, .bikeThief, .madamRubee, .andee: return .breakfastMachineHouse
        }
    }

    static func burtonHome(of hero: BurtonHero) -> Location {
        switch hero {
        case .jackSkullington, .sallee, .zeero, .theMayor, .hem: return .halloweenTown
        case .sandyClawz: return .christmasTown
        case .lydiaDeathz, .adamMaitclawd, .barbaraMaitclawd, .deliaDeathz, .astridDeathz: return .maitlandHouse
        case .junoh, .wolfJaxon, .shrunkenHeadMan: return .afterlifeWaitingRoom
        case .edwardScissorclaws, .theInventor: return .inventorsCastle
        case .kimBoggz, .pegBoggz: return .pastelSuburbia
        case .emilee, .scrapz, .elderGutknocked, .bonejingles, .generalBonesapart, .maggott: return .landOfTheDead
        case .victorVanDawt, .victoriaEverclawt: return .everglotVillage
        case .ichabodCraine, .katrinaVanTassle, .youngMasbeth, .bromVanBruntt: return .hollowVillage
        case .richieNorriss, .grandmaFlorenz, .presidentDayle, .professorKessclaw: return .perkinsvilleKansas
        case .byronWilyums: return .galaxyHotel
        case .willyWonky, .charlieBuckett, .grampaJoe, .oompaLoompah, .drWilburWonky: return .chocolateRoom
        case .aliceKingsclaw, .tarrantHightop, .chessur, .mirana, .mcTwisp, .mally, .thackeryHare: return .madTeaParty
        case .victorFrankenstien, .sparkie, .mrRzykrusky: return .newHollandAttic
        case .elsaVanHelsclaw: return .windmillMiniGolf
        case .peeweeHerclawd, .dottie, .largeMarge: return .breakfastMachineHouse
        }
    }
}

// MARK: - The theme

extension Cast {
    static func hero(_ h: BurtonHero) -> Cast { Cast(universe: .clawdBurton, isDark: false, index: h.rawValue) }
    static func villain(_ v: BurtonVillain) -> Cast { Cast(universe: .clawdBurton, isDark: true, index: v.rawValue) }
}

/// Arch-enemies: whenever both are fighting, they're paired with each other first, wherever they are in the line.
private let burtonNemeses: [(BurtonHero, BurtonVillain)] = [
    (.jackSkullington, .ooogieBoogie), (.sallee, .drFinkelclawd), (.sandyClawz, .lok), (.lydiaDeathz, .beetlejooce),
    (.adamMaitclawd, .otho), (.barbaraMaitclawd, .sandwurm), (.astridDeathz, .jeremee), (.wolfJaxon, .delorez),
    (.edwardScissorclaws, .jimm), (.pegBoggz, .joyceMonrow), (.emilee, .lordBarkissBittern),
    (.victorVanDawt, .pastorGallswell), (.ichabodCraine, .headlessHorseclawd), (.katrinaVanTassle, .ladyVanTassle),
    (.presidentDayle, .martianLeader), (.byronWilyums, .martianAmbassador), (.richieNorriss, .martianWalker),
    (.willyWonky, .slugwurth), (.charlieBuckett, .verucaSaltt), (.aliceKingsclaw, .jabberclawky), (.mirana, .redQueen),
    (.tarrantHightop, .stayne), (.victorFrankenstien, .edgarGorr), (.sparkie, .mrWhiskerz),
    (.peeweeHerclawd, .francisBuxtun),
]

let burtonTheme = Theme(
    universe: .clawdBurton,
    villains: BurtonVillain.allCases.map(\.persona),
    heroes: BurtonHero.allCases.map(\.persona),
    places: [.halloweenTown, .spiralHill, .oogiesLair, .christmasTown, .maitlandHouse, .modelWinterRiver,
             .afterlifeWaitingRoom, .sandwormSaturn, .pastelSuburbia, .inventorsCastle, .landOfTheDead, .everglotVillage,
             .hollowVillage, .treeOfTheDead, .perkinsvilleKansas, .galaxyHotel, .martianSaucerDeck, .chocolateRoom,
             .madTeaParty, .salazenGrum, .newHollandAttic, .windmillMiniGolf, .breakfastMachineHouse],
    home: { c in
        c.isDark ? .burtonHome(of: BurtonVillain(rawValue: c.index) ?? .beetlejooce)
                 : .burtonHome(of: BurtonHero(rawValue: c.index) ?? .jackSkullington)
    },
    nemeses: burtonNemeses.map { (.hero($0.0), .villain($0.1)) },
    ride: { _ in nil },
    menuIcon: drawSpiralHillIcon,
    legend: .hero(.jackSkullington))

// MARK: - Places

extension Location {
    static let halloweenTown = Location("halloweenTown")
    static let spiralHill = Location("spiralHill")
    static let oogiesLair = Location("oogiesLair")
    static let christmasTown = Location("christmasTown")
    static let maitlandHouse = Location("maitlandHouse")
    static let modelWinterRiver = Location("modelWinterRiver")
    static let afterlifeWaitingRoom = Location("afterlifeWaitingRoom")
    static let sandwormSaturn = Location("sandwormSaturn")
    static let pastelSuburbia = Location("pastelSuburbia")
    static let inventorsCastle = Location("inventorsCastle")
    static let landOfTheDead = Location("landOfTheDead")
    static let everglotVillage = Location("everglotVillage")
    static let hollowVillage = Location("hollowVillage")
    static let treeOfTheDead = Location("treeOfTheDead")
    static let perkinsvilleKansas = Location("perkinsvilleKansas")
    static let galaxyHotel = Location("galaxyHotel")
    static let martianSaucerDeck = Location("martianSaucerDeck")
    static let chocolateRoom = Location("chocolateRoom")
    static let madTeaParty = Location("madTeaParty")
    static let salazenGrum = Location("salazenGrum")
    static let newHollandAttic = Location("newHollandAttic")
    static let windmillMiniGolf = Location("windmillMiniGolf")
    static let breakfastMachineHouse = Location("breakfastMachineHouse")
}

/// Every Clawd Burton place, from the Places/BurtonScenes*.swift files.
let burtonPlaces: [Location: Place] = [burtonScenes1, burtonScenes2]
    .reduce([:]) { $0.merging($1) { a, _ in a } }
