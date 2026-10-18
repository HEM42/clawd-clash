import Foundation

/// Marvelous Clawds, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct MarvelousUniverse: UniverseModule {
    var theme: Theme { marvelTheme }
    var places: [Location: Place] { marvelPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in ComicTrip.pick(after: (last as? ComicTrip)?.kind, cast: cast, to: to) }
    }

    var preview: PreviewInfo {
        .of(.marvel, heroes: "heroes", [heroes1, heroes2, heroes3, heroes4, heroes5, heroes6, heroes7, heroes8, heroes9, heroes10],
            villains: "villains", [villains1, villains2, villains3, villains4, villains5, villains6, villains7, villains8, villains9])
    }
}
