import Foundation

/// Clawd Slayer, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct SlayerUniverse: UniverseModule {
    var theme: Theme { slayerTheme }
    var places: [Location: Place] { slayerPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in SlayerTrip.pick(after: (last as? SlayerTrip)?.kind, cast: cast, from: from, to: to) }
    }
}
