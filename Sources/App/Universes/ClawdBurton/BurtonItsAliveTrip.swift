import CoreGraphics

extension BurtonTrip {
    /// It's Alive! (not drawn yet: a crossfade).
    func drawItsAlive(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        Self.crossfade(ctx, old: old, new: new, k: k, in: r)
    }
}
