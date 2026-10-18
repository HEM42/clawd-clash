import Foundation

/// Clawd of the Rings, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct RingsUniverse: UniverseModule {
    var theme: Theme { middleEarthTheme }
    var places: [Location: Place] { middleEarthPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in RingsTrip.pick(after: (last as? RingsTrip)?.kind, cast: cast, from: from, to: to) }
    }
}
