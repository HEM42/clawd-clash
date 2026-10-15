import CoreGraphics

/// A comic-book trip between two places, in a universe that has them: Marvel's (`ComicTrip`), DC's (`DCComicTrip`) or
/// Doctor Clawd's trips through time and space (`DoctorTrip`) or The Clawd Files' (`FilesTrip`).
/// Star Wars has none: it keeps its edge and clock wipes (`Wipe`), and so does Stevie Clawdberg until its own trips come. Shared by the window and the screen saver.
enum ComicTransition {
    case marvel(ComicTrip)
    case dc(DCComicTrip)
    case doctor(DoctorTrip)
    case files(FilesTrip)

    var duration: Double {
        switch self { case .marvel(let t): return t.duration; case .dc(let t): return t.duration; case .doctor(let t): return t.duration
        case .files(let t): return t.duration }
    }

    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`.
    func draw(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        switch self {
        case .marvel(let t): t.draw(ctx, old: old, new: new, k: k, in: r)
        case .dc(let t): t.draw(ctx, old: old, new: new, k: k, in: r)
        case .doctor(let t): t.draw(ctx, old: old, new: new, k: k, in: r)
        case .files(let t): t.draw(ctx, old: old, new: new, k: k, in: r)
        }
    }

    /// The trip to `place`, never the same kind as `last` when it's in the same universe; nil where the universe
    /// uses plain wipes. `from`, where it's coming from, if it's known.
    static func pick(after last: ComicTransition?, cast: [Cast], from: Location? = nil, to place: Location) -> ComicTransition? {
        switch place.universe {
        case .starWars, .clawdberg:
            return nil
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
        }
    }
}
