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
    // The X-Files unit
    case foxClawder, danaScrawly
    case hem   // always last (`Universe.hem`)

    var persona: Persona { filesHeroPersonas[self] ?? Persona.missing(String(describing: self)) }
}

enum FilesVillain: Int, CaseIterable {
    // The Syndicate
    case smokingClawd

    var persona: Persona { filesVillainPersonas[self] ?? Persona.missing(String(describing: self)) }
}

let filesHeroPersonas: [FilesHero: Persona] = [filesHeroes1]
    .reduce([.hem: hemPersona(.clawdFiles)]) { $0.merging($1) { a, _ in a } }
let filesVillainPersonas: [FilesVillain: Persona] = [filesVillains1]
    .reduce([:]) { $0.merging($1) { a, _ in a } }

// MARK: - Homes

extension Location {
    static func filesHome(of leader: FilesVillain) -> Location {
        switch leader {
        case .smokingClawd: return .xFilesOffice
        }
    }

    static func filesHome(of hero: FilesHero) -> Location {
        switch hero {
        case .foxClawder, .danaScrawly, .hem: return .xFilesOffice
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
    (.foxClawder, .smokingClawd),
]

let filesTheme = Theme(
    universe: .clawdFiles,
    villains: FilesVillain.allCases.map(\.persona),
    heroes: FilesHero.allCases.map(\.persona),
    places: [.xFilesOffice],
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
}

/// Every Clawd Files place, from the Places/FilesScenes*.swift files.
let filesPlaces: [Location: Place] = [filesScenes1]
    .reduce([:]) { $0.merging($1) { a, _ in a } }
