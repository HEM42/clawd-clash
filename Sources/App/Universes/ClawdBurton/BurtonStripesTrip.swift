import CoreGraphics

extension BurtonTrip {
    /// Black-and-White Stripes (not drawn yet: a crossfade).
    func drawStripes(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        Self.crossfade(ctx, old: old, new: new, k: k, in: r)
    }
}
