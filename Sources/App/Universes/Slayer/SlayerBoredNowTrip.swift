import CoreGraphics
import Foundation

// Bored Now (`SlayerWipe.boredNow`): see the plan's Transitions table. Not drawn yet: a crossfade stands in.

extension SlayerTrip {
    func drawBoredNow(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        Self.crossfade(ctx, old: old, new: new, k: k, in: r)
    }
}
