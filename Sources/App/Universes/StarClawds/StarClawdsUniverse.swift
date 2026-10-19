import Foundation

/// Star Clawds, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct StarClawdsUniverse: UniverseModule {
    var theme: Theme { starClawdsTheme }
    var places: [Location: Place] { starClawdsPlaces }
    var hem: HemCostume { starClawdsHem }
    var drills: [Cast: BespokeDrill] { starClawdsBespokeDrills }
    // No transitions of its own: Clawd Wars' edge and clock wipes.

    var preview: PreviewInfo {
        .of(.starWars, heroes: "starWarsHeroes", [starClawdsHeroes1, starClawdsHeroes2, starClawdsHeroes3],
            villains: "starWarsVillains", [starClawdsVillains1, starClawdsVillains2, starClawdsVillains3])
    }

    /// Jedi and Sith alike float cross-legged, with bits of rock lifted round them.
    var meditation: Meditation { Meditation(who: .castersAndSabers, stones: true) }
    var poseStyle: PoseStyle { .classic }

    /// HEM has a word with Princess Laya about buns.
    var quirks: StageQuirks { StageQuirks(remark: starClawdsBunTalk) }

    /// Han shoots first.
    var shootOuts: [ShootOut] {
        [ShootOut(shooter: .hero(StarClawdsHero.han), target: .villain(StarClawdsVillain.greedo), says: "Sorry about the mess.",
                  comebacks: ["That hurt!", "Ow! Maclunkey…", "Han shot first!", "Not the vest!", "I'm OK!", "Every time…"])]
    }
    var rides: [Ride] { [.falcon] }
}

extension StarClawdsUniverse {
    /// The README's desktop line-up and social preview.
    var docs: DocsInfo {
        DocsInfo(lineup: [
            [LineupSlot(who: .villain(StarClawdsVillain.boba), leader: true, label: "", x: 30, facing: 1, role: .shoot(offset: 0)),
             LineupSlot(who: .hero(StarClawdsHero.han), leader: false, label: "Review Overlay.swift", x: 92, facing: -1, role: .shoot(offset: blasterPeriod / 2))],
            [LineupSlot(who: .hero(StarClawdsHero.leia), leader: false, label: "Run the test suite", x: 132, facing: 1, role: .shoot(offset: 0)),
             LineupSlot(who: .villain(StarClawdsVillain.trooper), leader: false, label: "Write changelog", x: 182, facing: -1, role: .shoot(offset: blasterPeriod / 2))],
            [LineupSlot(who: .hero(StarClawdsHero.luke), leader: false, label: "Find hook events", x: 214, facing: 1, role: .duel),
             LineupSlot(who: .villain(StarClawdsVillain.maul), leader: false, label: "Audit permissions", x: 244, facing: -1, role: .duel)],
            [LineupSlot(who: .hero(StarClawdsHero.obiwan), leader: true, label: "", x: 290, facing: 1, role: .duel),
             LineupSlot(who: .villain(StarClawdsVillain.vader), leader: true, label: "", x: 347, facing: -1, role: .duel)],
            [LineupSlot(who: .hero(StarClawdsHero.r2d2), leader: false, label: "Plan the refactor", x: 388, facing: 1, role: .cheer)],
        ], social: (title: "CLAWD WARS", subtitle: "Your Claude Code sessions as a pixel-art Star Clawds battle on your desktop",
                       cast: [.hero(StarClawdsHero.luke), .hero(StarClawdsHero.han), .hero(StarClawdsHero.leia), .hero(StarClawdsHero.yoda),
                              .villain(StarClawdsVillain.vader), .villain(StarClawdsVillain.boba), .villain(StarClawdsVillain.kylo),
                              .villain(StarClawdsVillain.trooper)]))
    }
}
