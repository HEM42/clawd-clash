import Foundation

// The Clawd Files: the paranormal universe. FBI agents, their informants and the Lone Gunclawds against the Syndicate,
// the aliens and the monsters of the week. Any character can lead a session (drawn large) or be an agent (small). Who
// they are, how they fight and how they move is a `Persona`, registered in one of the Art/*.swift files next to its
// drawing code; who lives where, who fights whom first and who gets picked up is decided here, in `filesTheme`.
//
// Ids are stored in the status file: `Universe.clawdFiles.base` plus `FilesVillain.rawValue` (< 100) or
// 100 + `FilesHero.rawValue`. Only ever append cases (HEM stays last), so running sessions keep their characters
// across an update.

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

    var persona: Persona { filesHeroPersonas[self] ?? Persona.missing(String(describing: self)) }
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

    var persona: Persona { filesVillainPersonas[self] ?? Persona.missing(String(describing: self)) }
}

let filesHeroPersonas: [FilesHero: Persona] = [filesHeroes1, filesHeroes2, filesHeroes3, filesHeroes4,
                                                filesHeroes5, filesHeroes6, filesHeroes7]
    .reduce([.hem: hemPersona(.clawdFiles)]) { $0.merging($1) { a, _ in a } }
let filesVillainPersonas: [FilesVillain: Persona] = [filesVillains1, filesVillains2, filesVillains3,
                                                      filesVillains4, filesVillains5, filesVillains6,
                                                      filesVillains7, filesVillains8]
    .reduce([:]) { $0.merging($1) { a, _ in a } }

// MARK: - Homes

extension Location {
    static func filesHome(of leader: FilesVillain) -> Location {
        switch leader {
        case .smokingClawd, .clawcek, .wellManicured, .firstElder, .strughold, .billClawder: return .syndicateClub
        case .dianaFowlclaw: return .xFilesOffice
        case .kersh, .toothpickMan, .pusher, .follmer: return .skinnardsOffice
        case .bountyHunter, .grey, .billyMiles, .jerseyDevil, .mothmen: return .bellefleurWoods
        case .blackOil, .knowleRohrer, .duffyHaskell, .crewCutMan: return .area51
        case .facelessRebel: return .ruskinDam
        case .colonist, .lordKinbote: return .mothership
        case .tooms, .virgilIncanto: return .toomsBlock
        case .flukeman, .flukeworm, .trashman: return .newarkSewers
        case .killerBee: return .beeDomes
        case .roboRoach, .eddieVanBlundht, .wendigo: return .bellefleurWoods
        case .leonardBetts, .eve6, .lutherLeeBoggs: return .autopsyBay
        case .greatMutato: return .mutatoFarm
        case .chuckleteeth, .tulpa: return .apartment42
        case .chupacabra, .tithonus, .cecilLively: return .quarantineCar
        case .bigBlue: return .lakeOkobogee
        case .ronnieStrickland, .guyMann, .rainKing: return .chaneyMotel
        case .teliko: return .reflectingPool
        }
    }

    static func filesHome(of hero: FilesHero) -> Location {
        switch hero {
        case .foxClawder, .danaScrawly, .einstine, .millar, .leylaHarriclaw, .hem: return .xFilesOffice
        case .skinnard, .doggedd, .jeffreySpendr: return .skinnardsOffice
        case .reyez, .samantha, .maxFenig: return .bellefleurWoods
        case .bytes, .frohack, .lanky, .jimmyBondd, .yvesHarlowe: return .gunclawdsDen
        case .misterX, .daggoo, .teenaClawder: return .apartment42
        case .deepClawt: return .reflectingPool
        case .gibsonPrays, .shannonMcMahawk: return .area51
        case .marita: return .antarctic
        case .melissaScrawly, .margaretScrawly, .queequeg: return .lakeOkobogee
        case .pendrill, .clydeBruckclaw: return .autopsyBay
        case .arthurDales, .frankBlackclaw: return .quarantineCar
        case .joseChung: return .mothership
        case .tadOClawley: return .beeDomes
        case .drBlockclaw, .conundrum: return .gibsonton
        case .sheriffHartwell: return .chaneyMotel
        }
    }
}

// MARK: - The theme

extension Cast {
    static func hero(_ h: FilesHero) -> Cast { Cast(universe: .clawdFiles, isDark: false, index: h.rawValue) }
    static func villain(_ v: FilesVillain) -> Cast { Cast(universe: .clawdFiles, isDark: true, index: v.rawValue) }
}

/// Arch-enemies: whenever both are fighting, they're paired with each other first, wherever they are in the line.
private let filesNemeses: [(FilesHero, FilesVillain)] = [
    (.foxClawder, .smokingClawd), (.danaScrawly, .tooms), (.skinnard, .clawcek), (.doggedd, .knowleRohrer),
    (.reyez, .toothpickMan), (.einstine, .trashman), (.millar, .trashman), (.bytes, .strughold),
    (.frohack, .strughold), (.lanky, .strughold), (.deepClawt, .wellManicured), (.misterX, .bountyHunter),
    (.marita, .blackOil), (.gibsonPrays, .facelessRebel), (.jeffreySpendr, .firstElder), (.arthurDales, .colonist),
    (.sheriffHartwell, .ronnieStrickland), (.joseChung, .lordKinbote), (.drBlockclaw, .jerseyDevil),
    (.samantha, .grey),
]

let filesTheme = Theme(
    universe: .clawdFiles,
    villains: FilesVillain.allCases.map(\.persona),
    heroes: FilesHero.allCases.map(\.persona),
    places: [.xFilesOffice, .skinnardsOffice, .gunclawdsDen, .apartment42, .syndicateClub, .bellefleurWoods, .area51,
             .antarctic, .quarantineCar, .toomsBlock, .newarkSewers, .gibsonton, .beeDomes, .lakeOkobogee, .mutatoFarm,
             .ruskinDam, .autopsyBay, .chaneyMotel, .reflectingPool, .mothership],
    home: { c in
        c.isDark ? .filesHome(of: FilesVillain(rawValue: c.index) ?? .smokingClawd)
                 : .filesHome(of: FilesHero(rawValue: c.index) ?? .foxClawder)
    },
    nemeses: filesNemeses.map { (.hero($0.0), .villain($0.1)) },
    ride: { _ in nil },   // the FBI sedan, the black helicopter and the saucer come with the mechanics
    menuIcon: drawSaucerIcon,
    legend: .hero(.foxClawder))

// MARK: - Places

extension Location {
    static let xFilesOffice = Location("xFilesOffice")
    static let skinnardsOffice = Location("skinnardsOffice")
    static let gunclawdsDen = Location("gunclawdsDen")
    static let apartment42 = Location("apartment42")
    static let syndicateClub = Location("syndicateClub")
    static let bellefleurWoods = Location("bellefleurWoods")
    static let area51 = Location("area51")
    static let newarkSewers = Location("newarkSewers")
    static let antarctic = Location("antarctic")
    static let quarantineCar = Location("quarantineCar")
    static let toomsBlock = Location("toomsBlock")
    static let gibsonton = Location("gibsonton")
    static let beeDomes = Location("beeDomes")
    static let lakeOkobogee = Location("lakeOkobogee")
    static let mutatoFarm = Location("mutatoFarm")
    static let ruskinDam = Location("ruskinDam")
    static let autopsyBay = Location("autopsyBay")
    static let chaneyMotel = Location("chaneyMotel")
    static let reflectingPool = Location("reflectingPool")
    static let mothership = Location("mothership")
}

/// Every Clawd Files place, from the Places/FilesScenes*.swift files.
let filesPlaces: [Location: Place] = [filesScenes1, filesScenes2, filesScenes3, filesScenes4, filesScenes5,
                                                filesScenes6]
    .reduce([:]) { $0.merging($1) { a, _ in a } }
