import Foundation

/// Detective Clawds, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct DetectiveUniverse: UniverseModule {
    var theme: Theme { dcTheme }
    var places: [Location: Place] { dcPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in DCComicTrip.pick(after: (last as? DCComicTrip)?.kind, cast: cast, to: to) }
    }
}
