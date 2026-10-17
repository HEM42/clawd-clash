import CoreGraphics
import Foundation

// Hush (`SlayerWipe.hush`): see the plan's Transitions table. Not drawn yet: a crossfade stands in.

extension SlayerTrip {
    func drawHush(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        Self.crossfade(ctx, old: old, new: new, k: k, in: r)
    }
}
