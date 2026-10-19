import Foundation

/// Clawd Slayer, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct SlayerUniverse: UniverseModule {
    var theme: Theme { slayerTheme }
    var places: [Location: Place] { slayerPlaces }
    var hem: HemCostume { slayerHem }
    var drills: [Cast: BespokeDrill] { slayerBespokeDrills }
    var transitions: TransitionSet? {
        TransitionSet(pick: { last, cast, from, to in SlayerTrip.pick(after: (last as? SlayerTrip)?.kind, cast: cast, from: from, to: to) },
                      every: { from, to in ShownTrip.all(SlayerWipe.allCases) { SlayerTrip(kind: $0, from: from, to: to) } })
    }

    var preview: PreviewInfo {
        .of(.slayer, heroes: "slayerHeroes", [slayerHeroes1, slayerHeroes2, slayerHeroes3, slayerHeroes4, slayerHeroes5, slayerHeroes6],
            villains: "slayerVillains", [slayerVillains1, slayerVillains2, slayerVillains3, slayerVillains4, slayerVillains5, slayerVillains6, slayerVillains7, slayerVillains8, slayerVillains9])
    }

    var playgroundPrompts: [String] {
        ["stake the bug in the Hellmouth loop", "make the window resize to fit the Claudes",
         "why does the library's book cage keep swinging?", "write a nice README with screenshots",
         "fix the portrait crop for Glorificlaws's hair"]
    }
    /// Only the witches float cross-legged (Willow does in "Lessons" and "Chosen").
    var meditation: Meditation { Meditation(who: .heroes(slayerWitches)) }

    /// A compacted "Tabula Rasa" eight: Willow's forgetting spell, cast and broken.
    func compactionLook(k: Double, cast: Cast) -> CompactionLook? { SlayerTabulaRasa(k: k, cast: cast) }
    var rides: [Ride] { [.schoolBus, .deSoto, .gtx] }
}

extension Ride {
    /// The school bus from the "Chosen" escape: it drives in, its door up front by the bonnet, 11 right of centre.
    static let schoolBus = Ride(key: "schoolBus", arrival: .drives, boardingOffset: -11) { c, ramp, engines, _, _ in
        slayerSchoolBus(c, ramp: ramp, lit: engines)
    }
    /// Spyke's DeSoto, its windows painted over: it drives in.
    static let deSoto = Ride(key: "deSoto", arrival: .drives) { c, ramp, engines, _, _ in slayerDeSoto(c, ramp: ramp, lit: engines) }
    /// Angstel's convertible: it drives in.
    static let gtx = Ride(key: "gtx", arrival: .drives) { c, ramp, engines, _, _ in slayerGTX(c, ramp: ramp, lit: engines) }

    /// Hush: while the Gentlemen are on stage, nobody has a voice. Mayor Wilclaws wipes his hands after every duel.
    var quirks: StageQuirks { StageQuirks(hushers: [.villain(SlayerVillain.gentlemen)], afterDuel: [.villain(SlayerVillain.mayorWilclaws)]) }
}

extension SlayerUniverse {
    /// The README's desktop line-up (the Old Master and Buffy, Willow's spell against Drusillah's, Xander's 2×4 against
    /// a fledgling, Spyke against Draclawla, Rupert Gyles cheering) and social preview.
    var docs: DocsInfo {
        DocsInfo(lineup: [
            LineupSlot.pair(.villain(SlayerVillain.oldMaster), true, "", 30, .hero(SlayerHero.buffyClawmers), true, "", 98),
            LineupSlot.pair(.hero(SlayerHero.willowRosenclaw), false, "Check git history", 132, .villain(SlayerVillain.drusillah), false, "Write changelog", 182),
            LineupSlot.pair(.hero(SlayerHero.xanderHarrows), false, "Plan the refactor", 214, .villain(SlayerVillain.fledgling), false, "Review Overlay.swift", 244),
            LineupSlot.pair(.hero(SlayerHero.spyke), true, "", 282, .villain(SlayerVillain.draclawla), true, "", 352),
            [LineupSlot(who: .hero(SlayerHero.rupertGyles), leader: false, label: "Run the test suite", x: 388, facing: 1, role: .cheer)],
        ], social: (title: "CLAWD SLAYER", subtitle: "Your AI sessions as a pixel-art vampire hunt on your desktop",
                       cast: [.hero(SlayerHero.buffyClawmers), .hero(SlayerHero.willowRosenclaw),
                              .hero(SlayerHero.spyke), .hero(SlayerHero.angstel), .villain(SlayerVillain.oldMaster),
                              .villain(SlayerVillain.glorificlaws), .villain(SlayerVillain.drusillah),
                              .villain(SlayerVillain.mayorWilclaws)]))
    }
}
