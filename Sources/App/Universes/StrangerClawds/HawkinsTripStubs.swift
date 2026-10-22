import CoreGraphics

extension HawkinsTrip {
    func drawTitle(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) { ctx.drawShot(old, in: r); ctx.setAlpha(CGFloat(Self.ease(k))); ctx.drawShot(new, in: r); ctx.setAlpha(1) }
    func drawInsertCoin(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) { ctx.drawShot(old, in: r); ctx.setAlpha(CGFloat(Self.ease(k))); ctx.drawShot(new, in: r); ctx.setAlpha(1) }
}
