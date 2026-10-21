import CoreGraphics

extension BurtonTrip {
    /// The Horseman's Ride (not drawn yet: a crossfade).
    func drawHorseman(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        Self.crossfade(ctx, old: old, new: new, k: k, in: r)
    }
}
