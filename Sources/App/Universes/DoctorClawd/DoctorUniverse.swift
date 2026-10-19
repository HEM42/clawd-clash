import Foundation

/// Doctor Clawd, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct DoctorUniverse: UniverseModule {
    var theme: Theme { doctorTheme }
    var places: [Location: Place] { doctorPlaces }
    var hem: HemCostume { doctorHem }
    var drills: [Cast: BespokeDrill] { doctorBespokeDrills }
    var transitions: TransitionSet? {
        TransitionSet(pick: { last, cast, from, to in DoctorTrip.pick(after: (last as? DoctorTrip)?.kind, cast: cast, to: to) },
                      every: { from, to in ShownTrip.all(DoctorWipe.allCases) { DoctorTrip(kind: $0) } })
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

extension DoctorUniverse {
    /// The README's desktop line-up and social preview.
    var docs: DocsInfo {
        DocsInfo(lineup: [
            [LineupSlot(who: .villain(DoctorVillain.davross), leader: true, label: "Davross", x: 30, facing: 1, role: .zap),
             LineupSlot(who: .hero(DoctorHero.doctorTen), leader: true, label: "Doctor Ten", x: 98, facing: -1, role: .hit)],
            [LineupSlot(who: .hero(DoctorHero.jack), leader: false, label: "Check git history", x: 132, facing: 1, role: .shoot(offset: 0)),
             LineupSlot(who: .villain(DoctorVillain.cyberperson), leader: false, label: "Write changelog", x: 182, facing: -1, role: .shoot(offset: blasterPeriod / 2))],
            [LineupSlot(who: .hero(DoctorHero.rory), leader: false, label: "Plan the refactor", x: 214, facing: 1, role: .duel),
             LineupSlot(who: .villain(DoctorVillain.clockworkDroid), leader: false, label: "Review Overlay.swift", x: 244, facing: -1, role: .duel)],
            [LineupSlot(who: .hero(DoctorHero.vasta), leader: true, label: "Madame Vasta", x: 282, facing: 1, role: .deflect),
             LineupSlot(who: .villain(DoctorVillain.dalick), leader: true, label: "Dalick", x: 352, facing: -1, role: .shoot(offset: 0))],
            [LineupSlot(who: .hero(DoctorHero.kCanine), leader: false, label: "Run the test suite", x: 388, facing: 1, role: .cheer)],
        ], social: (title: "DOCTOR CLAWD", subtitle: "Your Claude Code sessions as a pixel-art time-travel battle on your desktop",
                       cast: [.hero(DoctorHero.doctorTen), .hero(DoctorHero.doctorFour), .hero(DoctorHero.rose),
                              .hero(DoctorHero.doctorEleven), .villain(DoctorVillain.dalick),
                              .villain(DoctorVillain.master), .villain(DoctorVillain.cyberperson),
                              .villain(DoctorVillain.weepingAngle)]))
    }
}
