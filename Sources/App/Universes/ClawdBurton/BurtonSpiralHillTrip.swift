import CoreGraphics

extension BurtonTrip {
    /// Spiral Hill Unfurls (not drawn yet: a crossfade).
    func drawSpiralHill(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        Self.crossfade(ctx, old: old, new: new, k: k, in: r)
    }
}
