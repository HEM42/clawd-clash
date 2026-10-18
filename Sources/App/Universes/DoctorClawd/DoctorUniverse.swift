import Foundation

/// Doctor Clawd, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct DoctorUniverse: UniverseModule {
    var theme: Theme { doctorTheme }
    var places: [Location: Place] { doctorPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in DoctorTrip.pick(after: (last as? DoctorTrip)?.kind, cast: cast, to: to) }
    }

    var preview: PreviewInfo {
        .of(.doctor, heroes: "doctorHeroes", [doctorHeroes1, doctorHeroes2, doctorHeroes3, doctorHeroes4, doctorHeroes5, doctorHeroes6, doctorHeroes7],
            villains: "doctorVillains", [doctorVillains1, doctorVillains2, doctorVillains3, doctorVillains4, doctorVillains5])
    }

    var playgroundPrompts: [String] {
        ["make the rotor pump faster", "make the window resize to fit the Claudes", "why won't the Angle move?",
         "write a nice README with screenshots", "fix the portrait crop for the Dalick Emperor"]
    }
    /// A sonic screwdriver is no reason to float cross-legged.
    var meditation: Meditation { Meditation(who: .never) }

    /// A Weeping Angle only moves while nobody's looking at it.
    var quirks: StageQuirks { StageQuirks(unseenMovers: [.villain(DoctorVillain.weepingAngle)]) }
    var rides: [Ride] { [.tardis] }
}

extension Ride {
    /// The TARDIS: it fades in and out where it stands, taller than a ship, its door 6 px left of centre.
    static let tardis = Ride(key: "tardis", arrival: .materialises, canvasHeight: 36, boardingOffset: 6) { c, ramp, engines, _, _ in
        drawTardis(c, door: ramp, lamp: engines)
    }
}
