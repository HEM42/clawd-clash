import Foundation

/// Clawd Burton, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct BurtonUniverse: UniverseModule {
    var theme: Theme { burtonTheme }
    var places: [Location: Place] { burtonPlaces }
    var hem: HemCostume { burtonHem }
    var transitions: TransitionSet? {
        TransitionSet(pick: { last, cast, from, to in BurtonTrip.pick(after: (last as? BurtonTrip)?.kind, cast: cast, from: from, to: to) },
                      every: { from, to in ShownTrip.all(BurtonWipe.allCases) { BurtonTrip(kind: $0, from: from, to: to) } })
    }

    var preview: PreviewInfo {
        .of(.clawdBurton, heroes: "burtonHeroes", [burtonHeroes1, burtonHeroes2, burtonHeroes3, burtonHeroes4,
                                                   burtonHeroes5, burtonHeroes6, burtonHeroes7, burtonHeroes8],
            villains: "burtonVillains", [burtonVillains1, burtonVillains2, burtonVillains3, burtonVillains4, burtonVillains5,
                                         burtonVillains6, burtonVillains7])
    }

    var playgroundPrompts: [String] {
        ["find out why the topiary test keeps snipping the wrong branch", "write a handbook for the recently deleted files",
         "add a lightning-rod check before the reanimate step", "make the golden-ticket lookup ignore case",
         "count the Martians in the logs and tell me which ones come in peace"]
    }
    /// Nobody in Clawd Burton's films floats cross-legged.
    var meditation: Meditation { Meditation(who: .never) }
}
