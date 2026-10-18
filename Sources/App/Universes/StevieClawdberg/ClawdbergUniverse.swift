import Foundation

/// Stevie Clawdberg, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct ClawdbergUniverse: UniverseModule {
    var theme: Theme { clawdbergTheme }
    var places: [Location: Place] { clawdbergPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in ClawdbergTrip.pick(after: (last as? ClawdbergTrip)?.kind, cast: cast, from: from, to: to) }
    }
}
