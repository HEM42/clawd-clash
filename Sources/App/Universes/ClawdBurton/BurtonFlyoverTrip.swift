import CoreGraphics

extension BurtonTrip {
    /// The Model Town Flyover (not drawn yet: a crossfade).
    func drawFlyover(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        Self.crossfade(ctx, old: old, new: new, k: k, in: r)
    }
}
