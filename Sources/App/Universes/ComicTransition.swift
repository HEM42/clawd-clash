import CoreGraphics

/// A comic-book trip between two places, in a universe that has them: Marvel's (`ComicTrip`), DC's (`DCComicTrip`),
/// Doctor Clawd's trips through time and space (`DoctorTrip`), The Clawd Files' (`FilesTrip`), Stevie Clawdberg's
/// (`ClawdbergTrip`), Clawd of the Rings' (`RingsTrip`) or Clawd Slayer's (`SlayerTrip`).
/// Star Wars has none: it keeps its edge and clock wipes (`Wipe`). Shared by the window and the screen saver.
enum ComicTransition {
    case marvel(ComicTrip)
    case dc(DCComicTrip)
    case doctor(DoctorTrip)
    case files(FilesTrip)
    case clawdberg(ClawdbergTrip)
    case middleEarth(RingsTrip)
    case slayer(SlayerTrip)

    var duration: Double {
        switch self {
        case .marvel(let t): return t.duration
        case .dc(let t): return t.duration
        case .doctor(let t): return t.duration
        case .files(let t): return t.duration
        case .clawdberg(let t): return t.duration
        case .middleEarth(let t): return t.duration
        case .slayer(let t): return t.duration
        }
    }

    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`.
    func draw(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        switch self {
        case .marvel(let t): t.draw(ctx, old: old, new: new, k: k, in: r)
        case .dc(let t): t.draw(ctx, old: old, new: new, k: k, in: r)
        case .doctor(let t): t.draw(ctx, old: old, new: new, k: k, in: r)
        case .files(let t): t.draw(ctx, old: old, new: new, k: k, in: r)
        case .clawdberg(let t): t.draw(ctx, old: old, new: new, k: k, in: r)
        case .middleEarth(let t): t.draw(ctx, old: old, new: new, k: k, in: r)
        case .slayer(let t): t.draw(ctx, old: old, new: new, k: k, in: r)
        }
    }

    /// How much of the crew shows at `k` (0…1): 1 while the trip stays on the ground, less while it leaves it (the
    /// Great Eagle's open sky), so nobody is left standing on thin air.
    func crewShown(_ k: Double) -> Double {
        if case .middleEarth(let t) = self { return t.crewShown(k) }
        if case .slayer(let t) = self { return t.crewShown(k) }
        return 1
    }

    /// The trip to `place`, never the same kind as `last` when it's in the same universe; nil where the universe
    /// uses plain wipes. `from`, where it's coming from, if it's known.
    static func pick(after last: ComicTransition?, cast: [Cast], from: Location? = nil, to place: Location) -> ComicTransition? {
        switch place.universe {
        case .starWars:
            return nil
        case .clawdberg:
            if case .clawdberg(let l)? = last { return .clawdberg(ClawdbergTrip.pick(after: l.kind, cast: cast, from: from, to: place)) }
            return .clawdberg(ClawdbergTrip.pick(after: nil, cast: cast, from: from, to: place))
        case .clawdFiles:
            if case .files(let l)? = last { return .files(FilesTrip.pick(after: l.kind, cast: cast, from: from, to: place)) }
            return .files(FilesTrip.pick(after: nil, cast: cast, from: from, to: place))
        case .marvel:
            if case .marvel(let l)? = last { return .marvel(ComicTrip.pick(after: l.kind, cast: cast, to: place)) }
            return .marvel(ComicTrip.pick(after: nil, cast: cast, to: place))
        case .dc:
            if case .dc(let l)? = last { return .dc(DCComicTrip.pick(after: l.kind, cast: cast, to: place)) }
            return .dc(DCComicTrip.pick(after: nil, cast: cast, to: place))
        case .doctor:
            if case .doctor(let l)? = last { return .doctor(DoctorTrip.pick(after: l.kind, cast: cast, to: place)) }
            return .doctor(DoctorTrip.pick(after: nil, cast: cast, to: place))
        case .middleEarth:
            if case .middleEarth(let l)? = last { return .middleEarth(RingsTrip.pick(after: l.kind, cast: cast, from: from, to: place)) }
            return .middleEarth(RingsTrip.pick(after: nil, cast: cast, from: from, to: place))
        case .slayer:
            if case .slayer(let l)? = last { return .slayer(SlayerTrip.pick(after: l.kind, cast: cast, from: from, to: place)) }
            return .slayer(SlayerTrip.pick(after: nil, cast: cast, from: from, to: place))
        }
    }
}

extension ComicTransition {
    /// How a trip resamples the old and new pictures it was handed, while it scales, turns or shakes them. nil (the
    /// screen saver, and place changes in the window's scene strip) leaves the trip's own setting, `.none`: those
    /// pictures are pixel art. The window sets it while the universe changes (`ClawdWindow.switchFrame`), when they are
    /// snapshots of the whole window, its anti-aliased cards and info list among them, which nearest-neighbour breaks
    /// into blocks. A trip's own art (its canvases, sprites and lettering) is drawn with plain `draw` and stays crisp.
    static var snapshotQuality: CGInterpolationQuality?
}

extension CGContext {
    /// Draws a trip's old or new picture, resampled as `ComicTransition.snapshotQuality` says.
    func drawShot(_ image: CGImage, in rect: CGRect) {
        guard let quality = ComicTransition.snapshotQuality else { draw(image, in: rect); return }
        let was = interpolationQuality
        interpolationQuality = quality
        draw(image, in: rect)
        interpolationQuality = was
    }
}
