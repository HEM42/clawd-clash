import Foundation

/// Detective Clawds, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct DetectiveUniverse: UniverseModule {
    var theme: Theme { detectiveTheme }
    var places: [Location: Place] { detectivePlaces }
    var hem: HemCostume { detectiveHem }
    var drills: [Cast: BespokeDrill] { detectiveBespokeDrills }
    var transitions: TransitionSet? {
        TransitionSet(pick: { last, cast, from, to in DetectiveComicTrip.pick(after: (last as? DetectiveComicTrip)?.kind, cast: cast, to: to) },
                      every: { from, to in ShownTrip.all(DetectiveComicWipe.allCases) { DetectiveComicTrip(kind: $0, caption: "MEANWHILE, IN \(to.name.uppercased())…") } })
    }

    var preview: PreviewInfo {
        .of(.dc, heroes: "dcHeroes", [detectiveHeroes1, detectiveHeroes2, detectiveHeroes3, detectiveHeroes4, detectiveHeroes5, detectiveHeroes6, detectiveHeroes7, detectiveHeroes8, detectiveHeroes9, detectiveHeroes10],
            villains: "dcVillains", [detectiveVillains1, detectiveVillains2, detectiveVillains3, detectiveVillains4, detectiveVillains5, detectiveVillains6, detectiveVillains7, detectiveVillains8, detectiveVillains9])
    }

    /// The web line is grey here.
    var swingLine: Px? { C(0xB8BCC8, 0.95) }
    var rides: [Ride] { [.javelin, .batwing] }
}

extension DetectiveUniverse {
    /// The README's desktop line-up and social preview.
    var docs: DocsInfo {
        DocsInfo(lineup: [
            [LineupSlot(who: .villain(DetectiveVillain.darkseid), leader: true, label: "Darkseid", x: 30, facing: 1, role: .zap),
             LineupSlot(who: .hero(DetectiveHero.superman), leader: true, label: "Superman", x: 98, facing: -1, role: .hit, up: 10)],
            [LineupSlot(who: .hero(DetectiveHero.greenArrow), leader: false, label: "Check git history", x: 132, facing: 1, role: .shoot(offset: 0)),
             LineupSlot(who: .villain(DetectiveVillain.deadshot), leader: false, label: "Write changelog", x: 182, facing: -1, role: .shoot(offset: blasterPeriod / 2))],
            [LineupSlot(who: .hero(DetectiveHero.batman), leader: false, label: "Plan the refactor", x: 214, facing: 1, role: .duel),
             LineupSlot(who: .villain(DetectiveVillain.bane), leader: false, label: "Review Overlay.swift", x: 244, facing: -1, role: .duel)],
            [LineupSlot(who: .hero(DetectiveHero.wonderWoman), leader: true, label: "Wonder Woman", x: 282, facing: 1, role: .deflect),
             LineupSlot(who: .villain(DetectiveVillain.joker), leader: true, label: "The Joker", x: 352, facing: -1, role: .shoot(offset: 0))],
            [LineupSlot(who: .hero(DetectiveHero.flash), leader: false, label: "Run the test suite", x: 388, facing: 1, role: .cheer)],
        ], social: (title: "JUSTICE CLAWDS: CLAWD WARS", subtitle: "Your Claude Code sessions as a pixel-art Detective Clawds battle on your desktop",
                       cast: [.hero(DetectiveHero.superman), .hero(DetectiveHero.batman), .hero(DetectiveHero.wonderWoman),
                              .hero(DetectiveHero.flash), .villain(DetectiveVillain.joker), .villain(DetectiveVillain.lexLuthor),
                              .villain(DetectiveVillain.darkseid), .villain(DetectiveVillain.harleyQuinn)]))
    }
}
