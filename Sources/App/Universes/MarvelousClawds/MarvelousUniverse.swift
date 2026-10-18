import Foundation

/// Marvelous Clawds, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct MarvelousUniverse: UniverseModule {
    var theme: Theme { marvelTheme }
    var places: [Location: Place] { marvelPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in ComicTrip.pick(after: (last as? ComicTrip)?.kind, cast: cast, to: to) }
    }
}
