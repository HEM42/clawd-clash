import CoreGraphics

extension BurtonTrip {
    /// Saucer Swarm (not drawn yet: a crossfade).
    func drawSaucers(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        Self.crossfade(ctx, old: old, new: new, k: k, in: r)
    }
}
