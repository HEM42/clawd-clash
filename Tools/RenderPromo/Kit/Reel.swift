import AppKit

// A universe's own trailer, as the tool asks for it, and the reel on show.
// Part of RenderPromo's kit: declarations only. main.swift picks the reel and runs it; its header has the build
// command.

// MARK: A universe's own trailer

/// A universe's trailer, in its folder as `Promo/<Prefix>Reel.swift` (Tools/universes.sh lists them in
/// `registeredReels`): everything the tool asks a reel for, from its REEL name to its soundtrack.
protocol PromoReel {
    /// Its REEL name: `REEL=starclawds build/renderpromo video promo`.
    var name: String { get }
    /// The video's file name, without ".mp4" ("star-clawds-promo"); the storyboard is named after it.
    var base: String { get }
    /// The GitHub-sized copy's name in promo/720p, without ".mp4" ("Star-Clawds").
    var small: String { get }
    /// The storyboard sheet's title.
    var title: String { get }
    /// The storyboard's beats: a time in the reel, and what happens then.
    var beats: [(key: Double, beat: Beat)] { get }
    /// The reel's shots, in order.
    var shots: [Shot] { get }
    /// What Gemini's terminal on the desktop is busy with, in this universe.
    var geminiTask: String { get }
    /// The soft promo wipe's length: the trailers keep their slower one (2.7 s).
    var softWipe: Double { get }
    /// The first frame, the poster GitHub shows before play: a shot and a time into it.
    var poster: (shot: String, at: Double) { get }
    /// Writes the reel's score and effects into `m`.
    func sound(_ m: Mix)
    /// The universe it's the trailer of.
    var universe: Universe { get }
    /// Who's in its desktop brawl, and its caption (the shared shot `brawl`, which the promo plays too).
    var brawl: BrawlCast { get }
    /// Who's in its window, and what you asked them (the shared shot `windowShot`, which the promo plays too).
    var window: WindowCast { get }
    /// Its panel on the promo's comic page (`nil` until it has one; the promo stops if a universe it shows has none).
    var comic: ComicPanel? { get }
}

/// A universe's panel on the promo's Pick your universe page: who faces off on it, its sound word and pop-art colours
/// (base, pattern), and the big moment the camera reads on it: a word, a moment of its trailer (drawn from `piece`'s
/// time, about 0.8 to 1.5 s into the panel) and the hit heard as the camera gets there (`hit`, at that time).
struct ComicPanel {
    let hero, villain: Cast; let sound: String; let pop: (UInt32, UInt32)
    let word: String; let piece: (CGContext, Double, Double) -> Void; let hit: (Mix, Double) -> Void
}

/// A universe's desktop brawl: Claude's session against the other AI's, an agent of each trading shots, and the
/// caption under the universe's pill (a line, and a yellow one under it).
struct BrawlCast { let claude, other, agent, otherAgent: Cast; let line, sub: String }

/// A universe's window: its place, Claude's session fighting the other AI's, two of Claude's agents cheering, one of
/// the other AI's at the right, and the prompts on the two sessions' cards.
struct WindowCast { let place: Location; let claude, other, agentA, agentB, extra: Cast; let prompt, otherPrompt: String }

/// The trailer of `u`, for the shared shots that ask it who's in them.
func promoReel(_ u: Universe) -> PromoReel {
    guard let r = registeredReels.first(where: { $0.universe == u }) else {
        preconditionFailure("\(u.title) has no trailer yet: the shared shots ask its Promo/<Prefix>Reel.swift who's in them")
    }
    return r
}

extension PromoReel {
    var softWipe: Double { 2.7 }
    var poster: (shot: String, at: Double) { ("endcard", 2.5) }
    var comic: ComicPanel? { nil }
    /// The storyboard's file name: "storyboard-star-clawds.png" for "star-clawds-promo".
    var storyboardFile: String { "storyboard-\(base.hasSuffix("-promo") ? String(base.dropLast(6)) : base).png" }
}

// MARK: The reel on show

// main.swift sets these from REEL before anything is drawn or heard.

/// Its shots, in order.
var shots: [Shot] = []
/// What's drawn over its cuts.
var overlays: [Overlay] = []
var duration: Double { shots.last!.end }
/// The soft promo wipe's length: the owner's reels keep the quicker one.
var softWipe = 2.0
/// Its first frame, the poster GitHub shows before play: a shot and a time into it.
var poster: (shot: String, at: Double) = ("worlds", 9.0)
/// What Gemini's terminal on the desktop is busy with, in the reel's universe.
var geminiTask = "gemini ▸ fix the clawdarang"
