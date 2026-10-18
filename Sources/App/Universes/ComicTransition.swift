import CoreGraphics

/// A trip between two places in a universe that has them (`UniverseModule.transitions`): Marvel's comic panels, the
/// TARDIS's vortex, The Clawd Files' black oil… Star Clawds has none: it keeps its edge and clock wipes (`Wipe`).
/// Shared by the window and the screen saver.
struct ComicTransition {
    let trip: Trip

    init(_ trip: Trip) { self.trip = trip }

    var duration: Double { trip.duration }

    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`.
    func draw(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        trip.draw(ctx, old: old, new: new, k: k, in: r)
    }

    /// How much of the crew shows at `k` (0…1): 1 while the trip stays on the ground, less while it leaves it (the
    /// Great Eagle's open sky), so nobody is left standing on thin air.
    func crewShown(_ k: Double) -> Double { trip.crewShown(k) }

    /// The trip to `place`, never the same kind as `last` when it's in the same universe; nil where the universe
    /// uses plain wipes. `from`, where it's coming from, if it's known.
    static func pick(after last: ComicTransition?, cast: [Cast], from: Location? = nil, to place: Location) -> ComicTransition? {
        guard let set = place.universe.module.transitions else { return nil }
        return ComicTransition(set.pick(last?.trip, cast, from, place))
    }
}
