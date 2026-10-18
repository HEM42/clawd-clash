import Foundation

/// Stevie Clawdberg, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct ClawdbergUniverse: UniverseModule {
    var theme: Theme { clawdbergTheme }
    var places: [Location: Place] { clawdbergPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in ClawdbergTrip.pick(after: (last as? ClawdbergTrip)?.kind, cast: cast, from: from, to: to) }
    }

    var preview: PreviewInfo {
        .of(.clawdberg, heroes: "clawdbergHeroes", [clawdbergHeroes1, clawdbergHeroes2, clawdbergHeroes3, clawdbergHeroes4, clawdbergHeroes5, clawdbergHeroes6, clawdbergHeroes7],
            villains: "clawdbergVillains", [clawdbergVillains1, clawdbergVillains2, clawdbergVillains3, clawdbergVillains4, clawdbergVillains5, clawdbergVillains6, clawdbergVillains7])
    }

    var playgroundPrompts: [String] {
        ["get the DeLorean up to 88 mph", "make the window resize to fit the Claudes",
         "why does the water glass keep rippling?", "write a nice README with screenshots",
         "fix the portrait crop for T. Wrecks's tiny arms"]
    }
    /// A bullwhip is no reason to float cross-legged.
    var meditation: Meditation { Meditation(who: .never) }

    /// A compacted time traveller hits 88 mph: gone in a flash, back with three booms.
    func compactionLook(k: Double, cast: Cast) -> CompactionLook? { OutaTime(k: k) }

    /// Captain Clawk flinches at the Croc Clock's tick; T. Wrecks's footsteps ripple a glass of water.
    var quirks: StageQuirks { StageQuirks(jitter: clawdbergClawkFlinch, prop: clawdbergWaterGlass) }

    /// Indy's version: no time for the Cairo Swordsman's twirling.
    var shootOuts: [ShootOut] {
        [ShootOut(shooter: .hero(ClawdbergHero.indianaBones), target: .villain(ClawdbergVillain.cairoSwordsman),
                  says: "I don't have time for this.", comebacks: ["But my twirl!", "I practised for weeks!", "Not fair!", "I'm OK!", "Every time…"],
                  drawsGun: true)]
    }
    var rides: [Ride] { [.delorean, .moonBike, .mothership, .jeep] }
}

extension Ride {
    /// The DeLorean: it drives in.
    static let delorean = Ride(key: "delorean", arrival: .drives) { c, ramp, engines, _, _ in drawDelorean(c, ramp: ramp, lit: engines) }
    /// Elliott's bike across the moon: whoever's taken climbs on right under its middle.
    static let moonBike = Ride(key: "moonBike", boardingOffset: 0) { c, ramp, engines, _, _ in drawMoonBike(c, ramp: ramp, lit: engines) }
    /// The mothership: right under its light.
    static let mothership = Ride(key: "mothership", boardingOffset: 0) { c, ramp, engines, _, _ in drawMothership(c, ramp: ramp, lit: engines) }
    /// The park jeep: it drives in.
    static let jeep = Ride(key: "jeep", arrival: .drives) { c, ramp, engines, _, _ in drawParkJeep(c, ramp: ramp, lit: engines) }
}
