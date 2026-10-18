import Foundation

/// Star Clawds, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct StarClawdsUniverse: UniverseModule {
    var theme: Theme { starWarsTheme }
    var places: [Location: Place] { starWarsPlaces }
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
}
