import Foundation

/// Detective Clawds, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct DetectiveUniverse: UniverseModule {
    var theme: Theme { dcTheme }
    var places: [Location: Place] { dcPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in DCComicTrip.pick(after: (last as? DCComicTrip)?.kind, cast: cast, to: to) }
    }

    var preview: PreviewInfo {
        .of(.dc, heroes: "dcHeroes", [dcHeroes1, dcHeroes2, dcHeroes3, dcHeroes4, dcHeroes5, dcHeroes6, dcHeroes7, dcHeroes8, dcHeroes9, dcHeroes10],
            villains: "dcVillains", [dcVillains1, dcVillains2, dcVillains3, dcVillains4, dcVillains5, dcVillains6, dcVillains7, dcVillains8, dcVillains9])
    }
}
