import Foundation

/// Clawd of the Rings, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct RingsUniverse: UniverseModule {
    var theme: Theme { ringsTheme }
    var places: [Location: Place] { ringsPlaces }
    var hem: HemCostume { ringsHem }
    var transitions: TransitionSet? {
        TransitionSet(pick: { last, cast, from, to in RingsTrip.pick(after: (last as? RingsTrip)?.kind, cast: cast, from: from, to: to) },
                      every: { from, to in ShownTrip.all(RingsWipe.allCases) { RingsTrip(kind: $0, from: from, to: to) } })
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
    var rides: [Ride] { [.eagle] }
}

extension RingsUniverse {
    /// The README's desktop line-up (the Witch-king and Arrogorn, Leggolas against an orc, Gimli against an Uruk,
    /// Gandclawd and the Ballrog, Samwise cheering) and social preview.
    var docs: DocsInfo {
        DocsInfo(lineup: [
            LineupSlot.pair(.villain(RingsVillain.witchKing), true, "", 30, .hero(RingsHero.aragorn), true, "", 98),
            LineupSlot.pair(.hero(RingsHero.legolas), false, "Check git history", 132, .villain(RingsVillain.orc), false, "Write changelog", 182),
            LineupSlot.pair(.hero(RingsHero.gimli), false, "Plan the refactor", 214, .villain(RingsVillain.uruk), false, "Review Overlay.swift", 244),
            LineupSlot.pair(.hero(RingsHero.gandalf), true, "", 282, .villain(RingsVillain.balrog), true, "", 342),
            [LineupSlot(who: .hero(RingsHero.sam), leader: false, label: "Run the test suite", x: 396, facing: 1, role: .cheer)],
        ], social: (title: "CLAWD OF THE RINGS", subtitle: "Your AI sessions as a pixel-art quest on your desktop",
                       cast: [.hero(RingsHero.gandalf), .hero(RingsHero.frodo), .hero(RingsHero.aragorn),
                              .hero(RingsHero.legolas), .villain(RingsVillain.balrog), .villain(RingsVillain.sauron),
                              .villain(RingsVillain.witchKing), .villain(RingsVillain.gollum)]))
    }
}
