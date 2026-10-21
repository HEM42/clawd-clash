import CoreGraphics

extension BurtonTrip {
    /// Grey to Colour (not drawn yet: a crossfade).
    func drawGreyToColour(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        Self.crossfade(ctx, old: old, new: new, k: k, in: r)
    }
}
