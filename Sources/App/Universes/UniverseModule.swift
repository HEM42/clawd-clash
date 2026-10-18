import AppKit

/// One universe, as the app sees it: everything the engine asks a universe for. Each universe's folder has exactly one
/// type conforming to this, in its `<Prefix>Universe.swift`. Members without a default must be written; the rest have
/// sensible defaults. (Its plain numbers, which the hook needs too, are its `UniverseFacts`.)
protocol UniverseModule {
    /// The cast, the places in order, who lives where, arch-enemies, rides, the menu icon and the legend.
    var theme: Theme { get }
    /// Every place's drawing, by key. Keys are unique across universes.
    var places: [Location: Place] { get }
    /// Its trips between places; nil: plain edge and clock wipes (`Wipe`), as Star Clawds keeps.
    var transitions: TransitionSet? { get }
    /// What Tools/Preview needs: the batch names for its art files, and its characters by enum case name.
    var preview: PreviewInfo { get }

    // Have defaults
    /// Five sample prompts for the Playground's cards.
    var playgroundPrompts: [String] { get }
    /// Who floats cross-legged in meditation, and what floats round them.
    var meditation: Meditation { get }
    /// How guns are drawn: `.classic` is Clawd Wars' way (Star Clawds only).
    var poseStyle: PoseStyle { get }
    /// Who has the moonwalk among their habits.
    var moonwalkers: Set<Cast> { get }
    /// The web line's colour for characters who swing; nil: the usual near-white.
    var swingLine: Px? { get }
    /// A caption that types the place in when the scene changes, in place of the usual place name (The Clawd Files').
    var placeCaption: PlaceCaption? { get }
    /// What a compacted session's leader looks like while it's away and back (`UniverseCompaction.away`), `k` (0…1)
    /// through it; nil: nothing to see.
    func compactionLook(k: Double, cast: Cast) -> CompactionLook?
    /// Little things certain characters do on stage: the Weeping Angle, Captain Clawk's flinch, T. Wrecks's glass…
    var quirks: StageQuirks { get }
}

extension UniverseModule {
    var transitions: TransitionSet? { nil }
    var playgroundPrompts: [String] {
        ["add a snowtaunt", "make the window resize to fit the Claudes", "why does the duel not start?",
         "write a nice README with screenshots", "fix the portrait crop for wide characters"]
    }
    var meditation: Meditation { Meditation() }
    var poseStyle: PoseStyle { .modern }
    var moonwalkers: Set<Cast> { [] }
    var swingLine: Px? { nil }
    var placeCaption: PlaceCaption? { nil }
    func compactionLook(k: Double, cast: Cast) -> CompactionLook? { nil }
    var quirks: StageQuirks { StageQuirks() }
}

/// Someone on the stage, as a universe's quirks see them.
struct OnStage {
    let cast: Cast
    let x: CGFloat
    /// -1 facing left, 1 facing right.
    let facing: CGFloat
    let walking: Bool
    let leaving: Bool
    /// Its own offset (0…1), so two of them don't do the same thing at the same moment.
    let phase: Double
}

/// A universe's stage quirks: things certain characters do, whoever else is about.
struct StageQuirks {
    /// Only move while nobody's looking at them, and then quickly (the Weeping Angle).
    var unseenMovers: Set<Cast> = []
    /// A jump and a shiver, in sprite pixels, and maybe a muttered line: `who` among `others`, at `place`.
    var jitter: ((_ who: OnStage, _ others: [OnStage], _ place: Location?, _ t: Double) -> (dx: Int, up: Int, line: String?))? = nil
    /// Something drawn beside `who`, standing on `ground`, `scale` points to an art pixel.
    var prop: ((_ who: OnStage, _ ground: CGFloat, _ scale: CGFloat, _ t: Double) -> StageLayer?)? = nil
    /// A word to someone nearby: which way `who` turns to say it, and the line. `zoom`: the stage's zoom.
    var remark: ((_ who: OnStage, _ others: [OnStage], _ zoom: CGFloat, _ t: Double) -> (facing: CGFloat, line: String)?)? = nil
}

/// A moment of a compaction on stage: The Clawd Files' abduction beam, Stevie Clawdberg's 88 mph, Clawd Slayer's
/// forgetting spell. The overlay asks for it every frame while it plays.
protocol CompactionLook {
    /// A line over the character's head ("WHERE DID THE TIME GO?").
    var caption: String? { get }
    /// How much of the character shows (fading into a beam or a flash).
    var alpha: Double { get }
    /// How far it's lifted, in art pixels.
    var lift: Double { get }
    /// Art pixels kept clear over its head for a mark (the forgetting spell's "?"), so its name tag sits above.
    var markRoom: Double { get }
    /// What's drawn round it, placed for a character at `x` (screen points, its middle) standing on `y`, already lifted
    /// `lift` points, drawn `scale` points to an art pixel and facing `facing` (-1 left, 1 right).
    func layers(cast: Cast, x: CGFloat, y: CGFloat, lift: CGFloat, scale: CGFloat, facing: CGFloat, t: Double) -> [StageLayer]
    /// Anything done to the character's own picture (a shimmer).
    func touch(_ sprite: PixelCanvas, t: Double)
}

extension CompactionLook {
    var caption: String? { nil }
    var alpha: Double { 1 }
    var lift: Double { 0 }
    var markRoom: Double { 0 }
    func touch(_ sprite: PixelCanvas, t: Double) {}
}

/// A picture drawn on the stage, in screen points.
struct StageLayer {
    let image: CGImage
    let rect: CGRect
    var mirrored = false
}

/// The place's name, typed in a letter at a time when the scene changes, shown by the window and the screen saver in
/// place of the usual place name.
struct PlaceCaption {
    /// What's been typed `t` seconds after it started, line by line (the place, then where it is).
    let typed: (_ place: Location, _ t: Double) -> [String]
    /// Whether it's done typing (and blinking) `t` seconds after it started.
    let done: (_ place: Location, _ t: Double) -> Bool
    /// The typeface, at a size.
    let font: (CGFloat) -> NSFont
}

/// Who meditates in a universe (floating cross-legged, among their drills), if their persona can sit at all.
struct Meditation {
    enum Who {
        case never                      // a sonic screwdriver, a flashlight or a bullwhip is no reason to float
        case casters                    // magic users
        case castersAndSabers           // magic users and everyone with a saber: Jedi and Sith alike
        case heroes(Set<Int>)           // just these heroes, by local index (Clawd Slayer's witches)
    }
    var who: Who = .casters
    /// Bits of rock float round them (Star Clawds); otherwise motes of their own magic.
    var stones = false
}

/// How a universe draws guns.
enum PoseStyle {
    case modern
    /// As Clawd Wars did: never raised while waiting or cheering, the flash at the resting muzzle, and heroes don't
    /// raise theirs to check them either.
    case classic
}

extension Universe {
    /// The universe's module. Hand-listed for now; the universe-modules refactor generates this list from the folders.
    var module: UniverseModule {
        switch self {
        case .starWars: return StarClawdsUniverse()
        case .marvel: return MarvelousUniverse()
        case .dc: return DetectiveUniverse()
        case .doctor: return DoctorUniverse()
        case .clawdFiles: return FilesUniverse()
        case .clawdberg: return ClawdbergUniverse()
        case .middleEarth: return RingsUniverse()
        case .slayer: return SlayerUniverse()
        }
    }
}

/// A universe's characters as Tools/Preview finds them: by batch (one art file's worth, "slayerHeroes1") and by enum
/// case name (`buffy`).
struct PreviewInfo {
    var batches: [(name: String, cast: [Cast])] = []
    var caseName: (String) -> Cast? = { _ in nil }

    /// The usual shape: hero files `<heroes>1…`, villain files `<villains>1…` (each a `[Enum: Persona]`, as the art
    /// files define them), plus any `extra` batches, and the case names of both enums.
    static func of<H, V>(_ u: Universe, heroes: String, _ heroFiles: [[H: Persona]], villains: String, _ villainFiles: [[V: Persona]],
                         extra: [(name: String, cast: [Cast])] = []) -> PreviewInfo
    where H: CaseIterable & RawRepresentable & Hashable, V: CaseIterable & RawRepresentable & Hashable, H.RawValue == Int, V.RawValue == Int {
        func hero(_ h: H) -> Cast { Cast(universe: u, isDark: false, index: h.rawValue) }
        func villain(_ v: V) -> Cast { Cast(universe: u, isDark: true, index: v.rawValue) }
        var out = PreviewInfo()
        for (i, b) in heroFiles.enumerated() { out.batches.append(("\(heroes)\(i + 1)", b.keys.sorted { $0.rawValue < $1.rawValue }.map(hero))) }
        for (i, b) in villainFiles.enumerated() { out.batches.append(("\(villains)\(i + 1)", b.keys.sorted { $0.rawValue < $1.rawValue }.map(villain))) }
        out.batches += extra
        out.caseName = { n in H.allCases.first { "\($0)" == n }.map(hero) ?? V.allCases.first { "\($0)" == n }.map(villain) }
        return out
    }
}

/// One trip between two places: Marvel's comic panels, the TARDIS's vortex, The Clawd Files' black oil…
protocol Trip {
    var duration: Double { get }
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`.
    func draw(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect)
    /// How much of the crew shows at `k` (0…1): 1 while the trip stays on the ground, less while it leaves it (the
    /// Great Eagle's open sky), so nobody is left standing on thin air.
    func crewShown(_ k: Double) -> Double
}

extension Trip {
    func crewShown(_ k: Double) -> Double { 1 }
}

/// A universe's trips.
struct TransitionSet {
    /// The trip to `to`, coming `from` (if known). `last` is the previous trip if it was this universe's, so it can pick
    /// a different kind.
    let pick: (_ last: Trip?, _ cast: [Cast], _ from: Location?, _ to: Location) -> Trip
}
