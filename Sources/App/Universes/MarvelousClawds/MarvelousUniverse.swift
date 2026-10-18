import Foundation

/// Marvelous Clawds, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct MarvelousUniverse: UniverseModule {
    var theme: Theme { marvelTheme }
    var places: [Location: Place] { marvelPlaces }
    var hem: HemCostume { marvelousHem }
    var drills: [Cast: BespokeDrill] { marvelousBespokeDrills }
    var transitions: TransitionSet? {
        TransitionSet(pick: { last, cast, from, to in ComicTrip.pick(after: (last as? ComicTrip)?.kind, cast: cast, to: to) }, every: marvelousEveryTrip)
    }

    var preview: PreviewInfo {
        .of(.marvel, heroes: "heroes", [heroes1, heroes2, heroes3, heroes4, heroes5, heroes6, heroes7, heroes8, heroes9, heroes10],
            villains: "villains", [villains1, villains2, villains3, villains4, villains5, villains6, villains7, villains8, villains9])
    }

    /// Who moonwalks when idle: dancers, with legs free to show it (four plain legs, nothing hanging over them).
    var moonwalkers: Set<Cast> { [.hero(MarvelHero.starLord), .hero(MarvelHero.deadpool), .hero(MarvelHero.howardTheDuck)] }
    var rides: [Ride] { [.quinjet, .milano] }
}

/// Tools/Transitions' Marvelous Clawds sheet: every kind, and the burst once for each sound word, with Deadpool's two.
private func marvelousEveryTrip(from: Location, to: Location) -> [ShownTrip] {
    func shown(_ kind: ComicWipe, _ key: String, _ title: String, sound: ComicSound = .kapow) -> ShownTrip {
        ShownTrip(key: key, title: title, trip: ComicTrip(kind: kind, sound: sound, caption: "MEANWHILE, IN \(to.name.uppercased())…",
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
