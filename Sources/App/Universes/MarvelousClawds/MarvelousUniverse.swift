import Foundation

/// Marvelous Clawds, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct MarvelousUniverse: UniverseModule {
    var theme: Theme { marvelousTheme }
    var places: [Location: Place] { marvelousPlaces }
    var hem: HemCostume { marvelousHem }
    var drills: [Cast: BespokeDrill] { marvelousBespokeDrills }
    var transitions: TransitionSet? {
        TransitionSet(pick: { last, cast, from, to in MarvelousComicTrip.pick(after: (last as? MarvelousComicTrip)?.kind, cast: cast, to: to) }, every: marvelousEveryTrip)
    }

    var preview: PreviewInfo {
        .of(.marvel, heroes: "heroes", [marvelousHeroes1, marvelousHeroes2, marvelousHeroes3, marvelousHeroes4, marvelousHeroes5, marvelousHeroes6, marvelousHeroes7, marvelousHeroes8, marvelousHeroes9, marvelousHeroes10],
            villains: "villains", [marvelousVillains1, marvelousVillains2, marvelousVillains3, marvelousVillains4, marvelousVillains5, marvelousVillains6, marvelousVillains7, marvelousVillains8, marvelousVillains9])
    }

    /// Who moonwalks when idle: dancers, with legs free to show it (four plain legs, nothing hanging over them).
    var moonwalkers: Set<Cast> { [.hero(MarvelousHero.starLord), .hero(MarvelousHero.deadpool), .hero(MarvelousHero.howardTheDuck)] }
    var rides: [Ride] { [.quinjet, .milano] }
}

/// Tools/Transitions' Marvelous Clawds sheet: every kind, and the burst once for each sound word, with Deadpool's two.
private func marvelousEveryTrip(from: Location, to: Location) -> [ShownTrip] {
    func shown(_ kind: MarvelousComicWipe, _ key: String, _ title: String, sound: MarvelousComicSound = .kapow) -> ShownTrip {
        ShownTrip(key: key, title: title, trip: MarvelousComicTrip(kind: kind, sound: sound, caption: "MEANWHILE, IN \(to.name.uppercased())…",
                                                          quip: "Psst. Yes, you. Hold on, I'll change the set."))
    }
    return [
        shown(.halftone, "1-halftone", "Halftone dots"),
        shown(.burst, "2-burst-kapow", "KAPOW! (nobody in particular)"),
        shown(.burst, "2-burst-snikt", "SNIKT! (Wolverine, X-23)", sound: .snikt),
        shown(.burst, "2-burst-bamf", "BAMF! (Nightcrawler)", sound: .bamf),
        shown(.burst, "2-burst-krakatoom", "KRAKATOOM! (Thor)", sound: .krakatoom),
        shown(.burst, "2-burst-thwip", "THWIP! (Spider-Man, Miles, Spider-Gwen)", sound: .thwip),
        shown(.burst, "2-burst-baroom", "BAROOM! (Hulk, the Thing)", sound: .baroom),
        shown(.panels, "3-panels", "Panels slam in"),
        shown(.speedLines, "4-speedlines", "Speed-line zoom"),
        shown(.meanwhile, "5-meanwhile", "Iris and caption"),
        shown(.fourthWall, "6-deadpool-fourth-wall", "Deadpool peels the page"),
        shown(.chimichanga, "7-deadpool-chimichanga", "Deadpool's chimichanga"),
    ]
}

extension MarvelousUniverse {
    /// The README's desktop line-up and social preview.
    var docs: DocsInfo {
        DocsInfo(lineup: [
            [LineupSlot(who: .villain(.thanos), leader: true, label: "Thanos", x: 30, facing: 1, role: .zap),
             LineupSlot(who: .hero(.ironMan), leader: true, label: "Iron Man", x: 98, facing: -1, role: .hit, up: 10)],
            [LineupSlot(who: .hero(.spiderMan), leader: false, label: "Check git history", x: 132, facing: 1, role: .shoot(offset: 0)),
             LineupSlot(who: .villain(.greenGoblin), leader: false, label: "Write changelog", x: 182, facing: -1, role: .shoot(offset: blasterPeriod / 2))],
            [LineupSlot(who: .hero(.wolverine), leader: false, label: "Plan the refactor", x: 214, facing: 1, role: .duel),
             LineupSlot(who: .villain(.sabretooth), leader: false, label: "Review Overlay.swift", x: 244, facing: -1, role: .duel)],
            [LineupSlot(who: .hero(.captainAmerica), leader: true, label: "Captain America", x: 282, facing: 1, role: .deflect),
             LineupSlot(who: .villain(.redSkull), leader: true, label: "Red Skull", x: 352, facing: -1, role: .shoot(offset: 0))],
            [LineupSlot(who: .hero(.groot), leader: false, label: "Run the test suite", x: 388, facing: 1, role: .cheer)],
        ], social: (title: "CLAWDVENGERS: CLAWD WARS", subtitle: "Your Claude Code sessions as a pixel-art Marvelous Clawds battle on your desktop",
                       cast: [.hero(MarvelousHero.thor), .hero(MarvelousHero.spiderMan), .hero(MarvelousHero.captainAmerica),
                              .hero(MarvelousHero.ironMan), .villain(MarvelousVillain.thanos),
                              .villain(MarvelousVillain.loki), .villain(MarvelousVillain.greenGoblin),
                              .villain(MarvelousVillain.venom)]))
    }
}
