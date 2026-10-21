import CoreGraphics

extension BurtonTrip {
    /// Wonkavision (not drawn yet: a crossfade).
    func drawWonkavision(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        Self.crossfade(ctx, old: old, new: new, k: k, in: r)
    }
}
