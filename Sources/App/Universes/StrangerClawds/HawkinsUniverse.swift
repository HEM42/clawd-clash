import Foundation

// Stranger Clawds: the kids of Hawkins, Indiana, 1983 to 1987, their walkie-talkies and their basement, and what comes
// through from the Upside Down. The folder holds everything of it:
//   universe.conf            the manifest: number 9, key `hawkins`, for good.
//   HawkinsFacts.swift       the cast's enums and plain facts (the hook compiles it too, so no drawing in it).
//   HawkinsUniverse.swift    this file: the one type the engine asks everything (`UniverseModule`).
//   HawkinsRoster.swift      personas, homes, nemeses, the `Theme`, the place keys.
//   HawkinsHem.swift         HEM's costume here.        HawkinsIcon.swift   the menu bar icon.
//   Art/                     the characters.            Places/             the places.
//   HawkinsRides.swift       the Party's BMX bikes.  HawkinsTaken.swift  taken to the Upside Down (compaction).
//   HawkinsHabits.swift      the nosebleed, Vecna's clock, the babysitter.
//   HawkinsDrills.swift      the bespoke drills.     HawkinsFlip.swift   the Upside Down turning over now and then.
//   HawkinsTrips.swift       the ten trips between places, each drawn in its own Hawkins…Trip.swift, and
//   HawkinsLights.swift      Joyce's Christmas lights spelling the new place's name at the end of every one.
//   Promo/HawkinsReel.swift  the trailer, compiled only into Tools/RenderPromo, never into the app.

/// Stranger Clawds, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct HawkinsUniverse: UniverseModule {
    /// The cast, the places in order, who lives where, arch-enemies, the menu icon: HawkinsRoster.swift.
    var theme: Theme { hawkinsTheme }
    /// Every place's drawing, by key, merged from the Places files.
    var places: [Location: Place] { hawkinsPlaces }
    /// HEM's costume here: HawkinsHem.swift.
    var hem: HemCostume { hawkinsHem }
    /// The batch names for the art files, one per file in order, and the characters by enum case name.
    var preview: PreviewInfo {
        .of(.hawkins, heroes: "hawkinsHeroes", [hawkinsHeroes1, hawkinsHeroes2, hawkinsHeroes3, hawkinsHeroes4,
                                                hawkinsHeroes5],
            villains: "hawkinsVillains", [hawkinsVillains1, hawkinsVillains2, hawkinsVillains3, hawkinsVillains4])
    }
    /// The ten trips, each finished with Joyce's Christmas lights spelling the new place: HawkinsTrips.swift.
    var transitions: TransitionSet? {
        TransitionSet(pick: { last, cast, from, to in HawkinsTrip.pick(after: (last as? HawkinsTrip)?.kind, cast: cast, from: from, to: to) },
                      every: { from, to in ShownTrip.all(HawkinsWipe.allCases) { HawkinsTrip(kind: $0, from: from, to: to) } })
    }

    /// The Playground's five cards, in the Party's voice.
    var playgroundPrompts: [String] {
        ["Spell the error out on the Christmas lights.", "Find out what's living in the Upside Down of the build folder.",
         "Roll a d20 for the flaky test.", "Get the Party on their bikes and ride to the deploy.",
         "Suzie, do you copy? Send the logs over."]
    }
    /// Nobody floats cross-legged here: Eleven's powers aren't a meditation.
    var meditation: Meditation { Meditation(who: .never) }
    /// Eleven crushing a can, the Party's d20, Steve's batting practice: HawkinsDrills.swift.
    var drills: [Cast: BespokeDrill] { hawkinsBespokeDrills }
    /// The Party's BMX bikes: HawkinsRides.swift.
    var rides: [Ride] { [.hawkinsBikes] }
    /// Taken to the Upside Down, back through the wall and slimy: HawkinsTaken.swift.
    func compactionLook(k: Double, cast: Cast) -> CompactionLook? { HawkinsTaken(k: k) }
    /// The nosebleed after a fight, Vecna's clock, Steve minding the kids: HawkinsHabits.swift.
    var quirks: StageQuirks {
        StageQuirks(jitter: hawkinsStageJitter, prop: hawkinsVecnaClock, remark: hawkinsBabysitter,
                    afterDuel: [.hero(HawkinsHero.eleven)], afterDuelFrom: [.hero(HawkinsHero.eleven): hawkinsNosebleedFrom])
    }
    /// Now and then the Upside Down turns over: HawkinsFlip.swift.
    var sceneFlip: SceneFlip? { hawkinsUpsideDownTurn }

    /// The README's desktop line-up (Vecna and Eleven, Steve's nail bat against the Democlawdgon, Nancy's shotgun
    /// against a Demodog, Hopper against Billy, Dustin cheering) and social preview.
    var docs: DocsInfo {
        DocsInfo(lineup: [
            LineupSlot.pair(.villain(HawkinsVillain.vecna), true, "", 30, .hero(HawkinsHero.eleven), true, "", 98),
            LineupSlot.pair(.hero(HawkinsHero.steveHarringclawd), false, "Check git history", 132,
                            .villain(HawkinsVillain.democlawdgon), false, "Write changelog", 182),
            LineupSlot.pair(.hero(HawkinsHero.nancyWheeler), false, "Plan the refactor", 214,
                            .villain(HawkinsVillain.demodog), false, "Review Overlay.swift", 252),
            LineupSlot.pair(.hero(HawkinsHero.chiefHopper), true, "", 282, .villain(HawkinsVillain.billyHargrove), true, "", 352),
            [LineupSlot(who: .hero(HawkinsHero.dustinHenderson), leader: false, label: "Run the test suite", x: 388, facing: 1,
                        role: .cheer)],
        ], social: (title: Universe.hawkins.title.uppercased(), subtitle: "Your AI sessions as a pixel-art Hawkins brawl on your desktop",
                    cast: [.hero(HawkinsHero.eleven), .hero(HawkinsHero.mikeWheeler), .hero(HawkinsHero.dustinHenderson),
                           .hero(HawkinsHero.steveHarringclawd), .villain(HawkinsVillain.vecna),
                           .villain(HawkinsVillain.democlawdgon), .villain(HawkinsVillain.billyHargrove),
                           .villain(HawkinsVillain.drBrenner)]))
    }
}
