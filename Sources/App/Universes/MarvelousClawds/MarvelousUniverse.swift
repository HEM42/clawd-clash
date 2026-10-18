import Foundation

/// Marvelous Clawds, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct MarvelousUniverse: UniverseModule {
    var theme: Theme { marvelTheme }
    var places: [Location: Place] { marvelPlaces }
    var hem: HemCostume { marvelousHem }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in ComicTrip.pick(after: (last as? ComicTrip)?.kind, cast: cast, to: to) }
    }

    var preview: PreviewInfo {
        .of(.marvel, heroes: "heroes", [heroes1, heroes2, heroes3, heroes4, heroes5, heroes6, heroes7, heroes8, heroes9, heroes10],
            villains: "villains", [villains1, villains2, villains3, villains4, villains5, villains6, villains7, villains8, villains9])
    }

    /// Who moonwalks when idle: dancers, with legs free to show it (four plain legs, nothing hanging over them).
    var moonwalkers: Set<Cast> { [.hero(MarvelHero.starLord), .hero(MarvelHero.deadpool), .hero(MarvelHero.howardTheDuck)] }
    var rides: [Ride] { [.quinjet, .milano] }
}

extension Ride {
    /// The Avengers' Quinjet.
    static let quinjet = Ride(key: "quinjet") { c, ramp, engines, gear, _ in drawQuinjet(c, ramp: ramp, engines: engines, gear: gear) }
    /// The Guardians' Milano.
    static let milano = Ride(key: "milano") { c, ramp, engines, gear, _ in drawMilano(c, ramp: ramp, engines: engines, gear: gear) }
}
