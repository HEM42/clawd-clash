import Foundation

/// Clawd of the Rings, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct RingsUniverse: UniverseModule {
    var theme: Theme { middleEarthTheme }
    var places: [Location: Place] { middleEarthPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in RingsTrip.pick(after: (last as? RingsTrip)?.kind, cast: cast, from: from, to: to) }
    }

    var preview: PreviewInfo {
        .of(.middleEarth, heroes: "ringsHeroes", [ringsHeroes1, ringsHeroes2, ringsHeroes3, ringsHeroes4, ringsHeroes5, ringsHeroes6, ringsHeroes7, ringsHeroes8],
            villains: "ringsVillains", [ringsVillains1, ringsVillains2, ringsVillains3, ringsVillains4, ringsVillains5, ringsVillains6, ringsVillains7, ringsVillains8],
            // "hem" and "HEM" find the first universe's HEM; this batch is Clawd of the Rings' own
            extra: [("ringsHem", [.hero(RingsHero.hem)])])
    }

    var playgroundPrompts: [String] {
        ["make the Eagle wait for the last subagent", "make the window resize to fit the Claudes",
         "why won't the Ballrog cross the bridge?", "write a nice README with screenshots",
         "fix the portrait crop for Shellob's legs"]
    }
}
