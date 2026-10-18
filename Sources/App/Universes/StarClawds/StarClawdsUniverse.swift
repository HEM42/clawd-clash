import Foundation

/// Star Clawds, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct StarClawdsUniverse: UniverseModule {
    var theme: Theme { starWarsTheme }
    var places: [Location: Place] { starWarsPlaces }
    // No transitions of its own: Clawd Wars' edge and clock wipes.
}
