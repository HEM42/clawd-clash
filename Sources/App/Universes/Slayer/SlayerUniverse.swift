import Foundation

/// Clawd Slayer, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct SlayerUniverse: UniverseModule {
    var theme: Theme { slayerTheme }
    var places: [Location: Place] { slayerPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in SlayerTrip.pick(after: (last as? SlayerTrip)?.kind, cast: cast, from: from, to: to) }
    }

    var preview: PreviewInfo {
        .of(.slayer, heroes: "slayerHeroes", [slayerHeroes1, slayerHeroes2, slayerHeroes3, slayerHeroes4, slayerHeroes5, slayerHeroes6],
            villains: "slayerVillains", [slayerVillains1, slayerVillains2, slayerVillains3, slayerVillains4, slayerVillains5, slayerVillains6, slayerVillains7, slayerVillains8, slayerVillains9])
    }

    var playgroundPrompts: [String] {
        ["stake the bug in the Hellmouth loop", "make the window resize to fit the Claudes",
         "why does the library's book cage keep swinging?", "write a nice README with screenshots",
         "fix the portrait crop for Glorificlaws's hair"]
    }
    /// Only the witches float cross-legged (Willow does in "Lessons" and "Chosen").
    var meditation: Meditation { Meditation(who: .heroes(slayerWitches)) }
}
