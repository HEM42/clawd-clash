import Foundation

/// The Clawd Files, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct FilesUniverse: UniverseModule {
    var theme: Theme { filesTheme }
    var places: [Location: Place] { filesPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in FilesTrip.pick(after: (last as? FilesTrip)?.kind, cast: cast, from: from, to: to) }
    }
}
