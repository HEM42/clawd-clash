import Foundation

/// Star Clawds, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct StarClawdsUniverse: UniverseModule {
    var theme: Theme { starWarsTheme }
    var places: [Location: Place] { starWarsPlaces }
    var hem: HemCostume { starClawdsHem }
    var drills: [Cast: BespokeDrill] { starClawdsBespokeDrills }
    // No transitions of its own: Clawd Wars' edge and clock wipes.

    var preview: PreviewInfo {
        .of(.starWars, heroes: "starWarsHeroes", [starWarsHeroes1, starWarsHeroes2, starWarsHeroes3],
            villains: "starWarsVillains", [starWarsVillains1, starWarsVillains2, starWarsVillains3])
    }

    /// Jedi and Sith alike float cross-legged, with bits of rock lifted round them.
    var meditation: Meditation { Meditation(who: .castersAndSabers, stones: true) }
    var poseStyle: PoseStyle { .classic }

    /// HEM has a word with Princess Laya about buns.
    var quirks: StageQuirks { StageQuirks(remark: starClawdsBunTalk) }

    /// Han shoots first.
    var shootOuts: [ShootOut] {
        [ShootOut(shooter: .hero(SWHero.han), target: .villain(SWVillain.greedo), says: "Sorry about the mess.",
                  comebacks: ["That hurt!", "Ow! Maclunkey…", "Han shot first!", "Not the vest!", "I'm OK!", "Every time…"])]
    }
    var rides: [Ride] { [.falcon] }
}

extension StarClawdsUniverse {
    /// The README's desktop line-up and social preview.
    var docs: DocsInfo {
        DocsInfo(lineup: [
            [LineupSlot(who: .villain(SWVillain.boba), leader: true, label: "", x: 30, facing: 1, role: .shoot(offset: 0)),
             LineupSlot(who: .hero(SWHero.han), leader: false, label: "Review Overlay.swift", x: 92, facing: -1, role: .shoot(offset: blasterPeriod / 2))],
            [LineupSlot(who: .hero(SWHero.leia), leader: false, label: "Run the test suite", x: 132, facing: 1, role: .shoot(offset: 0)),
             LineupSlot(who: .villain(SWVillain.trooper), leader: false, label: "Write changelog", x: 182, facing: -1, role: .shoot(offset: blasterPeriod / 2))],
            [LineupSlot(who: .hero(SWHero.luke), leader: false, label: "Find hook events", x: 214, facing: 1, role: .duel),
             LineupSlot(who: .villain(SWVillain.maul), leader: false, label: "Audit permissions", x: 244, facing: -1, role: .duel)],
            [LineupSlot(who: .hero(SWHero.obiwan), leader: true, label: "", x: 290, facing: 1, role: .duel),
             LineupSlot(who: .villain(SWVillain.vader), leader: true, label: "", x: 347, facing: -1, role: .duel)],
            [LineupSlot(who: .hero(SWHero.r2d2), leader: false, label: "Plan the refactor", x: 388, facing: 1, role: .cheer)],
        ], social: (title: "CLAWD WARS", subtitle: "Your Claude Code sessions as a pixel-art Star Clawds battle on your desktop",
                       cast: [.hero(SWHero.luke), .hero(SWHero.han), .hero(SWHero.leia), .hero(SWHero.yoda),
                              .villain(SWVillain.vader), .villain(SWVillain.boba), .villain(SWVillain.kylo),
                              .villain(SWVillain.trooper)]))
    }
}
