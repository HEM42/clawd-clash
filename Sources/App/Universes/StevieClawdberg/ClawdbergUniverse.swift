import Foundation

/// Stevie Clawdberg, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct ClawdbergUniverse: UniverseModule {
    var theme: Theme { clawdbergTheme }
    var places: [Location: Place] { clawdbergPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in ClawdbergTrip.pick(after: (last as? ClawdbergTrip)?.kind, cast: cast, from: from, to: to) }
    }

    var preview: PreviewInfo {
        .of(.clawdberg, heroes: "clawdbergHeroes", [clawdbergHeroes1, clawdbergHeroes2, clawdbergHeroes3, clawdbergHeroes4, clawdbergHeroes5, clawdbergHeroes6, clawdbergHeroes7],
            villains: "clawdbergVillains", [clawdbergVillains1, clawdbergVillains2, clawdbergVillains3, clawdbergVillains4, clawdbergVillains5, clawdbergVillains6, clawdbergVillains7])
    }

    var playgroundPrompts: [String] {
        ["get the DeLorean up to 88 mph", "make the window resize to fit the Claudes",
         "why does the water glass keep rippling?", "write a nice README with screenshots",
         "fix the portrait crop for T. Wrecks's tiny arms"]
    }
    /// A bullwhip is no reason to float cross-legged.
    var meditation: Meditation { Meditation(who: .never) }
}
