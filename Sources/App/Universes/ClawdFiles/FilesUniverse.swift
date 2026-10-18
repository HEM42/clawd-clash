import Foundation

/// The Clawd Files, as the app sees it: everything the engine asks of it (`UniverseModule`).
struct FilesUniverse: UniverseModule {
    var theme: Theme { filesTheme }
    var places: [Location: Place] { filesPlaces }
    var transitions: TransitionSet? {
        TransitionSet { last, cast, from, to in FilesTrip.pick(after: (last as? FilesTrip)?.kind, cast: cast, from: from, to: to) }
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
    func compactionLook(k: Double, cast: Cast) -> CompactionLook? { MissingTime(k: k) }
}
