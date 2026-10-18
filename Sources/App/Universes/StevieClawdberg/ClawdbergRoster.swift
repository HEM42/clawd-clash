import Foundation

// Stevie Clawdberg: the blockbuster universe. One ensemble from Jaws, Close Encounters, the Indiana Jones films, E.T.,
// Hook, Jurassic Park, Gremlins, The Goonies and Back to the Future. Any character can lead a session (drawn large) or
// be an agent (small). Who they are, how they fight and how they move is a `Persona`, registered in one of the
// Art/*.swift files next to its drawing code; who lives where, who fights whom first and who gets picked up is decided
// here, in `clawdbergTheme`.
//
// Ids are stored in the status file: `Universe.clawdberg.base` plus `ClawdbergVillain.rawValue` (< 100) or
// 100 + `ClawdbergHero.rawValue`. Only ever append cases (HEM stays last), so running sessions keep their characters
// across an update.

extension ClawdbergHero {
    var persona: Persona { clawdbergHeroPersonas[self] ?? Persona.missing(String(describing: self)) }
}

extension ClawdbergVillain {
    var persona: Persona { clawdbergVillainPersonas[self] ?? Persona.missing(String(describing: self)) }
}

let clawdbergHeroPersonas: [ClawdbergHero: Persona] = [clawdbergHeroes1, clawdbergHeroes2, clawdbergHeroes3,
                                                         clawdbergHeroes4, clawdbergHeroes5, clawdbergHeroes6,
                                                         clawdbergHeroes7]
    .reduce([.hem: hemPersona(.clawdberg)]) { $0.merging($1) { a, _ in a } }
let clawdbergVillainPersonas: [ClawdbergVillain: Persona] = [clawdbergVillains1, clawdbergVillains2,
                                                               clawdbergVillains3, clawdbergVillains4,
                                                               clawdbergVillains5, clawdbergVillains6,
                                                               clawdbergVillains7]
    .reduce([:]) { $0.merging($1) { a, _ in a } }

// MARK: - Homes

extension Location {
    static func clawdbergHome(of leader: ClawdbergVillain) -> Location {
        switch leader {
        case .strype, .greta, .daffy, .mrsDeegle: return .kingstonFalls
        case .mohawk, .theBrain, .batGremlin, .electricGremlin, .drClawtheter: return .clampCentre
        case .mogwaiPup: return .wingShop
        case .keyz, .spacesuitMan, .frog: return .elliottStreet
        case .bruise: return .orca
        case .mayorVaun: return .amityBeach
        case .mamaFratelly, .jakeFratelly, .francisFratelly, .troyPerkins, .elginPerkins: return .goondocks
        case .oneEyedWilly: return .inferno
        case .reneBellock, .cairoSwordsman, .irinaSpalco, .jurgenVollar: return .idolTemple
        case .majorTote, .mechanic, .snake: return .wellOfSouls
        case .molaRamm, .laoChay, .maharajah: return .templeOfDoom
        case .colonelVogle, .walterDonnervan, .elsaSnyder: return .grailTemple
        case .tWrecks, .cleverGirl, .spitter, .dennisNerdry, .indominusRex, .gennarrow, .compy: return .rexPaddock
        case .drWoo: return .parkGates
        case .majorMildBill, .gasMaskTrooper: return .devilsTower
        case .captainClawk, .mrSmeeh: return .jollyRoger
        case .billJukes, .crocClock: return .pirateTown
        case .biffTannin, .oldBiff, .griffTannin, .mrStricklaw, .needles: return .biffsParadise
        case .madDogTannin: return .hillValley1885
        }
    }

    static func clawdbergHome(of hero: ClawdbergHero) -> Location {
        switch hero {
        case .billyPeltclawd, .kateBeringer, .randPeltclawd, .lynnPeltclawd, .futterclaw: return .kingstonFalls
        case .gizmoe, .mrWing: return .wingShop
        case .grandpaDread: return .clampCentre
        case .eClawd: return .moonHill
        case .elliclawd, .gurtie: return .elliottStreet
        case .chiefBroody, .hoopah, .squint: return .orca
        case .mikeyWaltz, .brandWaltz, .chunk, .mouth, .data, .andyCarmichaw, .stefSteinclawd: return .goondocks
        case .slawth: return .inferno
        case .indianaBones, .mutt, .helenaShore: return .idolTemple
        case .marion, .sallaw: return .wellOfSouls
        case .shortRounds, .willieScoot: return .templeOfDoom
        case .henryBones, .marcusBrodie, .grailKnight: return .grailTemple
        case .alanGrand, .ellieSaddler, .ianMalclawm, .johnHammend, .timMurphey, .lexMurphey, .rayArnie, .trike:
            return .visitorCentre
        case .muldune, .owenGravy, .claireDaring, .blue: return .parkGates
        case .royNeery, .jillianGeyser, .littleBarry, .clawdLacombe, .tallVisitor: return .devilsTower
        case .peterPanning, .tinkerbelle, .roofio, .thudButt, .jackBanning, .tootles: return .neverland
        case .martyMcFry, .docBrawn, .georgeMcFry, .lorraineBaynes, .einsteinDog, .goldieWilsun, .hem: return .hillValley1955
        case .jenniferParka, .claraClawton: return .hillValley1885
        }
    }
}

// MARK: - The theme

extension Cast {
    static func hero(_ h: ClawdbergHero) -> Cast { Cast(universe: .clawdberg, isDark: false, index: h.rawValue) }
    static func villain(_ v: ClawdbergVillain) -> Cast { Cast(universe: .clawdberg, isDark: true, index: v.rawValue) }
}

/// Arch-enemies: whenever both are fighting, they're paired with each other first, wherever they are in the line.
private let clawdbergNemeses: [(ClawdbergHero, ClawdbergVillain)] = [
    (.indianaBones, .reneBellock), (.marion, .majorTote), (.shortRounds, .molaRamm), (.henryBones, .walterDonnervan),
    (.helenaShore, .jurgenVollar), (.mutt, .irinaSpalco), (.martyMcFry, .madDogTannin), (.georgeMcFry, .biffTannin),
    (.docBrawn, .oldBiff), (.martyMcFry, .griffTannin), (.billyPeltclawd, .strype), (.gizmoe, .mohawk),
    (.futterclaw, .batGremlin), (.eClawd, .keyz), (.elliclawd, .spacesuitMan), (.chiefBroody, .bruise),
    (.hoopah, .mayorVaun), (.mikeyWaltz, .mamaFratelly), (.data, .francisFratelly), (.brandWaltz, .troyPerkins),
    (.ianMalclawm, .tWrecks), (.muldune, .cleverGirl), (.lexMurphey, .dennisNerdry), (.owenGravy, .indominusRex),
    (.peterPanning, .captainClawk), (.roofio, .billJukes), (.royNeery, .majorMildBill),
]

let clawdbergTheme = Theme(
    universe: .clawdberg,
    villains: ClawdbergVillain.allCases.map(\.persona),
    heroes: ClawdbergHero.allCases.map(\.persona),
    places: [.hillValley1955, .biffsParadise, .hillValley1885, .amityBeach, .orca, .kingstonFalls, .wingShop,
             .clampCentre, .elliottStreet, .moonHill, .goondocks, .inferno, .idolTemple, .wellOfSouls, .templeOfDoom,
             .grailTemple, .parkGates, .visitorCentre, .rexPaddock, .devilsTower, .neverland, .pirateTown, .jollyRoger],
    home: { c in
        c.isDark ? .clawdbergHome(of: ClawdbergVillain(rawValue: c.index) ?? .reneBellock)
                 : .clawdbergHome(of: ClawdbergHero(rawValue: c.index) ?? .indianaBones)
    },
    nemeses: clawdbergNemeses.map { (.hero($0.0), .villain($0.1)) },
    ride: { c in
        // The DeLorean for Back to the Future's people (and Old Biff, who stole it); the moon bike for the E.T. kids
        // and the Goonies; the mothership for Close Encounters; the park jeep for Jurassic Park's people. Everyone
        // else leaves on foot.
        guard c.universe == .clawdberg else { return nil }
        if c.isDark {
            switch ClawdbergVillain(rawValue: c.index) {
            case .oldBiff?: return .delorean
            case .dennisNerdry?, .gennarrow?, .drWoo?: return .jeep
            default: return nil
            }
        }
        switch ClawdbergHero(rawValue: c.index) {
        case .martyMcFry?, .docBrawn?, .jenniferParka?, .georgeMcFry?, .lorraineBaynes?, .einsteinDog?, .claraClawton?,
             .goldieWilsun?:
            return .delorean
        case .eClawd?, .elliclawd?, .gurtie?, .mikeyWaltz?, .brandWaltz?, .chunk?, .mouth?, .data?, .andyCarmichaw?,
             .stefSteinclawd?, .slawth?:
            return .moonBike
        case .royNeery?, .jillianGeyser?, .littleBarry?, .clawdLacombe?, .tallVisitor?:
            return .mothership
        case .alanGrand?, .ellieSaddler?, .ianMalclawm?, .johnHammend?, .muldune?, .timMurphey?, .lexMurphey?,
             .rayArnie?, .owenGravy?, .claireDaring?:
            return .jeep
        default:
            return nil
        }
    },
    menuIcon: drawMoonBikeIcon,
    legend: .hero(.indianaBones))

// MARK: - Places

extension Location {
    static let hillValley1955 = Location("hillValley1955")
    static let biffsParadise = Location("biffsParadise")
    static let hillValley1885 = Location("hillValley1885")
    static let amityBeach = Location("amityBeach")
    static let orca = Location("orca")
    static let kingstonFalls = Location("kingstonFalls")
    static let wingShop = Location("wingShop")
    static let clampCentre = Location("clampCentre")
    static let elliottStreet = Location("elliottStreet")
    static let moonHill = Location("moonHill")
    static let goondocks = Location("goondocks")
    static let inferno = Location("inferno")
    static let idolTemple = Location("idolTemple")
    static let wellOfSouls = Location("wellOfSouls")
    static let templeOfDoom = Location("templeOfDoom")
    static let grailTemple = Location("grailTemple")
    static let parkGates = Location("parkGates")
    static let visitorCentre = Location("visitorCentre")
    static let rexPaddock = Location("rexPaddock")
    static let devilsTower = Location("devilsTower")
    static let neverland = Location("neverland")
    static let pirateTown = Location("pirateTown")
    static let jollyRoger = Location("jollyRoger")
}

/// Every Stevie Clawdberg place, from the Places/ClawdbergScenes*.swift files.
let clawdbergPlaces: [Location: Place] = [clawdbergScenes1, clawdbergScenes2, clawdbergScenes3, clawdbergScenes4,
                                                  clawdbergScenes5, clawdbergScenes6, clawdbergScenes7, clawdbergScenes8,
                                                  clawdbergScenes9, clawdbergScenes10]
    .reduce([:]) { $0.merging($1) { a, _ in a } }
