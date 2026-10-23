import Foundation

// Clawd Burton: the director's gothic-but-warm universe. One ensemble from The Nightmare Before Christmas, Beetlejuice
// (and Beetlejuice Beetlejuice), Edward Scissorhands, Corpse Bride, Sleepy Hollow, Mars Attacks!, Charlie and the
// Chocolate Factory, Alice in Wonderland, Frankenweenie and Pee-wee's Big Adventure. Any character can lead a session
// (drawn large) or be an agent (small). Who they are, how they fight and how they move is a `Persona`, registered in
// one of the Art/*.swift files next to its drawing code; who lives where, who fights whom first and who gets picked up
// is decided here, in `burtonTheme`.

extension BurtonHero {
    var persona: Persona { burtonHeroPersonas[self] ?? Persona.missing(String(describing: self)) }
}

extension BurtonVillain {
    var persona: Persona { burtonVillainPersonas[self] ?? Persona.missing(String(describing: self)) }
}

let burtonHeroPersonas: [BurtonHero: Persona] = [burtonHeroes1, burtonHeroes2, burtonHeroes3, burtonHeroes4, burtonHeroes5,
                                                  burtonHeroes6, burtonHeroes7, burtonHeroes8]
    .reduce([.hem: hemPersona(.clawdBurton)]) { $0.merging($1) { a, _ in a } }
let burtonVillainPersonas: [BurtonVillain: Persona] = [burtonVillains1, burtonVillains2, burtonVillains3, burtonVillains4,
                                                        burtonVillains5, burtonVillains6, burtonVillains7]
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
        case .lordBarkissBittern, .pastorGallswell, .finisEverclawd, .maudelineEverclawd: return .everglotVillage
        case .headlessHorseclawd, .westernWoodsCrone: return .treeOfTheDead
        case .ladyVanTassle: return .hollowVillage
        case .martianLeader, .martianAmbassador, .martianTrooper, .martianSpy: return .martianSaucerDeck
        case .martianWalker: return .perkinsvilleKansas
        case .augustusGloopp, .verucaSaltt, .violetBluregarde, .mikeTeevee, .slugwurth, .nutSquirrel: return .chocolateRoom
        case .redQueen, .stayne, .jabberclawdky, .bandersnatch, .redCardKnight: return .salazenGrum
        case .edgarGorr, .nassorr, .toshiakki, .weirdGurl, .mrWhiskerz, .shellee, .colossuss, .wereRat, .seaMonkey:
            return .windmillMiniGolf
        case .francisBuxtun, .bikeThief, .madamRubee, .andee: return .breakfastMachineHouse
        }
    }

    static func burtonHome(of hero: BurtonHero) -> Location {
        switch hero {
        case .jackSkullington, .sallee, .zeero, .theMayor, .hem: return .halloweenTown
        case .sandyClawdz: return .christmasTown
        case .lydiaDeathz, .adamMaitclawd, .barbaraMaitclawd, .deliaDeathz, .astridDeathz: return .maitlandHouse
        case .junoh, .wolfJaxon, .shrunkenHeadMan: return .afterlifeWaitingRoom
        case .edwardScissorclawds, .theInventor: return .inventorsCastle
        case .kimBoggz, .pegBoggz: return .pastelSuburbia
        case .emilee, .scrapz, .elderGutknocked, .bonejingles, .generalBonesapart, .maggott: return .landOfTheDead
        case .victorVanDawt, .victoriaEverclawd: return .everglotVillage
        case .ichabodCraine, .katrinaVanTassle, .youngMasbeth, .bromVanBruntt: return .hollowVillage
        case .richieNorriss, .grandmaFlorenz, .presidentDayle, .professorKessclawd: return .perkinsvilleKansas
        case .byronWilyums: return .galaxyHotel
        case .willyWonky, .charlieBuckett, .grampaJoe, .oompaLoompah, .drWilburWonky: return .chocolateRoom
        case .aliceKingsclawd, .tarrantHightop, .chessur, .mirana, .mcTwisp, .mally, .thackeryHare: return .madTeaParty
        case .victorFrankenstien, .sparkie, .mrRzykrusky: return .newHollandAttic
        case .elsaVanHelsclawd: return .windmillMiniGolf
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
    (.jackSkullington, .ooogieBoogie), (.sallee, .drFinkelclawd), (.sandyClawdz, .lok), (.lydiaDeathz, .beetlejooce),
    (.adamMaitclawd, .otho), (.barbaraMaitclawd, .sandwurm), (.astridDeathz, .jeremee), (.wolfJaxon, .delorez),
    (.edwardScissorclawds, .jimm), (.pegBoggz, .joyceMonrow), (.emilee, .lordBarkissBittern),
    (.victorVanDawt, .pastorGallswell), (.ichabodCraine, .headlessHorseclawd), (.katrinaVanTassle, .ladyVanTassle),
    (.presidentDayle, .martianLeader), (.byronWilyums, .martianAmbassador), (.richieNorriss, .martianWalker),
    (.willyWonky, .slugwurth), (.charlieBuckett, .verucaSaltt), (.aliceKingsclawd, .jabberclawdky),
    (.mirana, .redQueen), (.tarrantHightop, .stayne), (.victorFrankenstien, .edgarGorr), (.sparkie, .mrWhiskerz),
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
    menuIcon: burtonMenuIcon,
    legend: .hero(BurtonHero.jackSkullington))

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
let burtonPlaces: [Location: Place] = [burtonScenes1, burtonScenes2, burtonScenes3, burtonScenes4, burtonScenes5,
                                       burtonScenes6]
    .reduce([:]) { $0.merging($1) { a, _ in a } }
