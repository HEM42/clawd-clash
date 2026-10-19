import Foundation

/// Detective Clawds, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct DetectiveUniverse: UniverseModule {
    var theme: Theme { dcTheme }
    var places: [Location: Place] { dcPlaces }
    var hem: HemCostume { detectiveHem }
    var drills: [Cast: BespokeDrill] { detectiveBespokeDrills }
    var transitions: TransitionSet? {
        TransitionSet(pick: { last, cast, from, to in DCComicTrip.pick(after: (last as? DCComicTrip)?.kind, cast: cast, to: to) },
                      every: { from, to in ShownTrip.all(DCComicWipe.allCases) { DCComicTrip(kind: $0, caption: "MEANWHILE, IN \(to.name.uppercased())…") } })
    }

    var preview: PreviewInfo {
        .of(.dc, heroes: "dcHeroes", [dcHeroes1, dcHeroes2, dcHeroes3, dcHeroes4, dcHeroes5, dcHeroes6, dcHeroes7, dcHeroes8, dcHeroes9, dcHeroes10],
            villains: "dcVillains", [dcVillains1, dcVillains2, dcVillains3, dcVillains4, dcVillains5, dcVillains6, dcVillains7, dcVillains8, dcVillains9])
    }

    /// The web line is grey here.
    var swingLine: Px? { C(0xB8BCC8, 0.95) }
    var rides: [Ride] { [.javelin, .batwing] }
}

extension DetectiveUniverse {
    /// The README's desktop line-up and social preview.
    var docs: DocsInfo {
        DocsInfo(lineup: [
            [LineupSlot(who: .villain(DCVillain.darkseid), leader: true, label: "Darkseid", x: 30, facing: 1, role: .zap),
             LineupSlot(who: .hero(DCHero.superman), leader: true, label: "Superman", x: 98, facing: -1, role: .hit, up: 10)],
            [LineupSlot(who: .hero(DCHero.greenArrow), leader: false, label: "Check git history", x: 132, facing: 1, role: .shoot(offset: 0)),
             LineupSlot(who: .villain(DCVillain.deadshot), leader: false, label: "Write changelog", x: 182, facing: -1, role: .shoot(offset: blasterPeriod / 2))],
            [LineupSlot(who: .hero(DCHero.batman), leader: false, label: "Plan the refactor", x: 214, facing: 1, role: .duel),
             LineupSlot(who: .villain(DCVillain.bane), leader: false, label: "Review Overlay.swift", x: 244, facing: -1, role: .duel)],
            [LineupSlot(who: .hero(DCHero.wonderWoman), leader: true, label: "Wonder Woman", x: 282, facing: 1, role: .deflect),
             LineupSlot(who: .villain(DCVillain.joker), leader: true, label: "The Joker", x: 352, facing: -1, role: .shoot(offset: 0))],
            [LineupSlot(who: .hero(DCHero.flash), leader: false, label: "Run the test suite", x: 388, facing: 1, role: .cheer)],
        ], social: (title: "JUSTICE CLAWDS: CLAWD WARS", subtitle: "Your Claude Code sessions as a pixel-art Detective Clawds battle on your desktop",
                       cast: [.hero(DCHero.superman), .hero(DCHero.batman), .hero(DCHero.wonderWoman),
                              .hero(DCHero.flash), .villain(DCVillain.joker), .villain(DCVillain.lexLuthor),
                              .villain(DCVillain.darkseid), .villain(DCVillain.harleyQuinn)]))
    }
}
