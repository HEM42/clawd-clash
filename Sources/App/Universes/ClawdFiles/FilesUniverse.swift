import Foundation

/// The Clawd Files, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct FilesUniverse: UniverseModule {
    var theme: Theme { filesTheme }
    var places: [Location: Place] { filesPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in FilesTrip.pick(after: (last as? FilesTrip)?.kind, cast: cast, from: from, to: to) }
    }

    var preview: PreviewInfo {
        .of(.clawdFiles, heroes: "filesHeroes", [filesHeroes1, filesHeroes2, filesHeroes3, filesHeroes4, filesHeroes5, filesHeroes6, filesHeroes7],
            villains: "filesVillains", [filesVillains1, filesVillains2, filesVillains3, filesVillains4, filesVillains5, filesVillains6, filesVillains7, filesVillains8])
    }
}
