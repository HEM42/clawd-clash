import Foundation

/// The Clawd Files, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct FilesUniverse: UniverseModule {
    var theme: Theme { filesTheme }
    var places: [Location: Place] { filesPlaces }
    var hem: HemCostume { filesHem }
    var drills: [Cast: BespokeDrill] { filesBespokeDrills }
    var transitions: TransitionSet? {
        TransitionSet(pick: { last, cast, from, to in FilesTrip.pick(after: (last as? FilesTrip)?.kind, cast: cast, from: from, to: to) },
                      every: { from, to in ShownTrip.all(FilesWipe.allCases) { FilesTrip(kind: $0, from: from, to: to) } })
    }

    var preview: PreviewInfo {
        .of(.clawdFiles, heroes: "filesHeroes", [filesHeroes1, filesHeroes2, filesHeroes3, filesHeroes4, filesHeroes5, filesHeroes6, filesHeroes7],
            villains: "filesVillains", [filesVillains1, filesVillains2, filesVillains3, filesVillains4, filesVillains5, filesVillains6, filesVillains7, filesVillains8])
    }

    var playgroundPrompts: [String] {
        ["redact the case file before Skinnard sees it", "make the window resize to fit the Claudes",
         "why does the slide projector keep flickering?", "write a nice README with screenshots",
         "fix the portrait crop for the Smoking Clawd's smoke"]
    }
    /// A flashlight is no reason to float cross-legged.
    var meditation: Meditation { Meditation(who: .never) }

    /// Every scene opens with the place typed in, as in the show (`FilesCaption`).
    var placeCaption: PlaceCaption? { PlaceCaption(typed: FilesCaption.typed, done: FilesCaption.done, font: FilesCaption.font) }

    /// A compacted FBI agent loses some time: lifted away in a beam of light and set back down.
    func compactionLook(k: Double, cast: Cast) -> CompactionLook? { FilesMissingTime(k: k) }
    var rides: [Ride] { [.sedan, .helicopter, .saucer] }
}

extension Ride {
    /// The unmarked sedan: it drives in.
    static let sedan = Ride(key: "sedan", arrival: .drives) { c, ramp, engines, _, _ in filesDrawSedan(c, ramp: ramp, lights: engines) }
    /// The black helicopter.
    static let helicopter = Ride(key: "helicopter") { c, ramp, engines, gear, _ in filesDrawHelicopter(c, ramp: ramp, engines: engines, gear: gear) }
    /// The saucer: whoever's taken stands right under its beam.
    static let saucer = Ride(key: "saucer", boardingOffset: 0) { c, ramp, engines, _, _ in filesDrawSaucer(c, ramp: ramp, engines: engines) }
}

extension FilesUniverse {
    /// The README's desktop line-up and social preview.
    var docs: DocsInfo {
        DocsInfo(lineup: [
            LineupSlot.pair(.villain(FilesVillain.smokingClawd), true, "", 30, .hero(FilesHero.foxClawder), true, "", 98),
            LineupSlot.pair(.hero(FilesHero.danaScrawly), false, "Check git history", 132, .villain(FilesVillain.clawcek), false, "Write changelog", 182),
            LineupSlot.pair(.hero(FilesHero.frohack), false, "Plan the refactor", 214, .villain(FilesVillain.grey), false, "Review Overlay.swift", 244),
            LineupSlot.pair(.hero(FilesHero.doggedd), true, "", 282, .villain(FilesVillain.knowleRohrer), true, "", 352),
            [LineupSlot(who: .hero(FilesHero.queequeg), leader: false, label: "Run the test suite", x: 388, facing: 1, role: .cheer)],
        ], social: (title: "THE CLAWD FILES", subtitle: "Your AI sessions as a pixel-art paranormal investigation on your desktop",
                       cast: [.hero(FilesHero.foxClawder), .hero(FilesHero.danaScrawly), .hero(FilesHero.skinnard),
                              .hero(FilesHero.lanky), .villain(FilesVillain.smokingClawd),
                              .villain(FilesVillain.grey), .villain(FilesVillain.flukeman),
                              .villain(FilesVillain.bountyHunter)]))
    }
}
