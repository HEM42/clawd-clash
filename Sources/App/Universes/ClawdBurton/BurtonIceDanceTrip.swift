import CoreGraphics

extension BurtonTrip {
    /// Ice Dance (not drawn yet: a crossfade).
    func drawIceDance(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        Self.crossfade(ctx, old: old, new: new, k: k, in: r)
    }
}
