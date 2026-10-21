import CoreGraphics

extension BurtonTrip {
    /// Down the Rabbit Hole (not drawn yet: a crossfade).
    func drawRabbitHole(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        Self.crossfade(ctx, old: old, new: new, k: k, in: r)
    }
}
