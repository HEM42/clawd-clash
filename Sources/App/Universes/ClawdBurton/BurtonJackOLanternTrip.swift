import CoreGraphics

extension BurtonTrip {
    /// The Jack-o'-Lantern (not drawn yet: a crossfade).
    func drawJackOLantern(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        Self.crossfade(ctx, old: old, new: new, k: k, in: r)
    }
}
