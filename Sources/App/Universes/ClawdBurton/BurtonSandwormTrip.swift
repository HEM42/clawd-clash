import CoreGraphics

extension BurtonTrip {
    /// The Sandworm (not drawn yet: a crossfade).
    func drawSandworm(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        Self.crossfade(ctx, old: old, new: new, k: k, in: r)
    }
}
