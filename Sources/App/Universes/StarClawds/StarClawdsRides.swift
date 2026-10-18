import Foundation

// Star Clawds' ride: the Millennial Falcon. Drawn with the ride kit in Rides.swift.

extension Ride {
    /// The Millennial Falcon, for Han and his crew.
    static let falcon = Ride(key: "falcon") { c, ramp, engines, gear, _ in drawFalcon(c, ramp: ramp, engines: engines, gear: gear) }
}

/// The Millennium Falcon, nose to the right: the disc, the forward mandibles, the offset cockpit, the radar
/// dish. `ramp` 0…1 lowers the boarding ramp (down and to the left), `engines` lights the blue glow.
private func drawFalcon(_ c: PixelCanvas, ramp: Double, engines: Bool, gear: Bool) {
    // Seen slightly from above, so the round saucer, the central hatch and the split front read clearly.
    let hull = C(0xB8B6AC), hullLight = C(0xD2D0C6), hullDark = C(0x8A8880), panel = C(0x6E6C66)
    if gear {
        for gx in [18, 44] { c.rect(gx, 24, 1, 3, hullDark); c.rect(gx - 1, 27, 3, 1, panel) }
    }
    if ramp > 0 {                                                       // boarding ramp, toward the left
        let len = Int((ramp * 9).rounded())
        for k in 0..<len { c.rect(31 - k, 24 + k / 3, 2, 1, hullDark) }
    }
    c.ellipse(32, 18, 28, 7, hullDark)                                  // rim / underside
    c.ellipse(32, 16, 28, 8, hull)                                      // the saucer, seen from above
    c.ellipse(30, 15, 22, 6, hullLight)
    c.circle(30, 15, 4, hull); c.circle(30, 15, 2, panel)               // central hatch
    for (x, y) in [(12, 15), (18, 11), (40, 11), (46, 16), (20, 20), (40, 20), (24, 14), (36, 18)] { c.rect(x, y, 3, 1, panel) }
    // the split front: two mandibles with the cargo gap between them
    c.rect(55, 11, 10, 3, hull); c.rect(55, 18, 10, 3, hull)
    c.rect(55, 14, 7, 4, C(0x2A2A28))
    c.rect(63, 11, 2, 3, hullLight); c.rect(63, 18, 2, 3, hullLight)
    // cockpit off to the side, and the radar dish
    c.rect(46, 6, 10, 3, hull); c.circle(56, 7, 2, hull); c.rect(56, 6, 2, 2, C(0x3A5A7A))
    c.rect(22, 6, 1, 4, panel); c.ellipse(21, 5, 4, 1, hullLight)
    if engines {                                                        // the blue engine glow along the back
        c.rect(3, 12, 2, 9, C(0x6FB8FF)); c.rect(2, 14, 1, 5, C(0xBFE0FF))
    }
}
