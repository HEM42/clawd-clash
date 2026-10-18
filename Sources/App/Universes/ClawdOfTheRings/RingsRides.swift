import Foundation

// Clawd of the Rings' ride: the Great Eagle. Drawn with the ride kit in Rides.swift.

/// One of the Eagle's wings, from the shoulder (`hx`, `hy`) out along `angle` (radians, y down) for `len` px: a broad
/// plank of feathers, pale coverts along its leading edge and dark flight feathers behind, striped along their length
/// and darkest toward the tip, where (`splay`) the primaries part into fingers. `side` puts the trailing edge
/// clockwise of the wing's direction on screen (+1) or anticlockwise (-1): -1 for a wing reaching back with its
/// trailing edge below it.
private func eagleWing(_ c: PixelCanvas, hx: Double, hy: Double, angle: Double, len: Double, width: Double,
                       side: Double, splay: Bool, cover: Px, flight: Px, stripe: Px, tip: Px) {
    let dx = cos(angle), dy = sin(angle), nx = -dy * side, ny = dx * side
    let x0 = Int(floor(min(hx, hx + dx * len) - width - 1)), x1 = Int(ceil(max(hx, hx + dx * len) + width + 1))
    let y0 = Int(floor(min(hy, hy + dy * len) - width - 1)), y1 = Int(ceil(max(hy, hy + dy * len) + width + 1))
    for y in y0...y1 { for x in x0...x1 {
        let px = Double(x) + 0.5 - hx, py = Double(y) + 0.5 - hy
        let a = px * dx + py * dy, b = px * nx + py * ny          // along the wing, and across it toward the trailing edge
        let f = a / len, half = width * (1 - 0.3 * f)
        guard a >= 0, b >= -1.6, b <= half else { continue }
        let reach = splay ? len + 2 * (b / half) : len - 1.5 * max(0, -b) // the tip: fingers fan out, or a round end
        guard a <= reach else { continue }
        if splay && f > 0.6 && b > 1 && Int((a * 0.9).rounded()) % 3 == 0 { continue }   // the gaps between fingers
        let col: Px
        if b < 0.2 { col = cover }
        else { col = Int(b.rounded()) % 2 == 0 ? (f > 0.7 ? tip : flight) : stripe }
        c.px(x, y, col)
    } }
}

/// Wing beats a second while the Eagle flies: slow and heavy, as a great eagle's are.
private let eagleBeats = 1.8

/// The Great Eagle, facing right: a brown body with a golden head and a hooked beak, its tail fanned behind. Landed,
/// the wings fold along its back and `ramp` lowers the near one to the ground to climb on; flying (`engines`), the
/// wings spread wide and beat `eagleBeats` times a second on the clock `t`, tips up (the body dipping) then down.
/// `gear`: talons down.
func drawEagle(_ c: PixelCanvas, ramp: Double, engines: Bool, gear: Bool, t: Double) {
    let body = C(0x6A4A2A), bodyLight = C(0x8A6440), bodyDark = C(0x4A321C), head = C(0xC8A060)
    let headLight = C(0xE2C488), headDark = C(0x9A7A44), feather = C(0x543A20), flight = C(0x3E2A16)
    let tipCol = C(0x2E1E10), beak = C(0xE8C860), beakDark = C(0x8A6A2A), talon = C(0xE0B040), claw = C(0x22180E)
    var up = false
    if engines { let beat: Double = (t * eagleBeats).truncatingRemainder(dividingBy: 1); up = beat < 0.5 }
    let by: Double = engines ? (up ? 19 : 13) : 17                       // the body's centre line
    let iy = Int(by), ry = engines ? 5 : 6
    // The far wing, behind the body (folded, it's hidden behind the near one)
    if engines {
        let a: Double = up ? -1.95 : 2.3
        eagleWing(c, hx: up ? 45 : 44, hy: up ? by - 2 : by + 1, angle: a, len: 17, width: 6, side: up ? -1 : 1,
                  splay: true, cover: body, flight: flight, stripe: tipCol, tip: tipCol)
    }
    // Talons: feathered legs and hooked yellow feet
    if gear {
        let foot = engines ? min(27, iy + 9) : 27
        for lx in [30, 37] {
            c.rect(lx, iy + 3, 2, foot - iy - 3, bodyDark)
            c.rect(lx, foot - 1, 2, 1, talon)
            c.pattern(lx - 2, foot, ["TTTTTT", "K.K..K"], ["T": talon, "K": claw])
        }
    }
    // The tail, fanned out behind and drooping a little when landed, its feather tips notched
    for x in 8...23 {
        let f = Double(23 - x) / 15, half = 1.8 + f * 3.4, mid = by - 0.5 + (engines ? 0 : f * 1.5)
        let t = Int((mid - half).rounded()), b = Int((mid + half).rounded())
        for y in t...b where x > 8 || (y - t) % 3 != 2 {                 // notched at the end
            c.px(x, y, x < 11 ? flight : (y % 2 == 0 ? feather : C(0x5C4024)))
        }
        c.px(x, t, bodyLight)
    }
    // The body: brown, lit along the back, darker on the belly
    c.ellipse(34, iy, 14, ry, body)
    for x in 21...47 {
        let u = Double(x - 34) / 14, h = (1 - u * u).squareRoot() * Double(ry)
        c.px(x, Int((by - h).rounded()), bodyLight)
        c.px(x, Int((by + h).rounded()), bodyDark)
        if h > 3 { c.px(x, Int((by + h).rounded()) - 1, bodyDark) }
    }
    // The neck and the golden head, with a dark eye under a brow and the hooked beak
    let hy = iy - 6
    c.ellipse(47, iy - 2, 5, 4, head)
    c.circle(52, hy, 5, head)
    for x in 48...56 { c.px(x, hy - 5 + (x == 48 || x == 56 ? 1 : 0), headLight) }
    c.rect(46, iy + 1, 6, 1, headDark)
    for y in iy - 5...iy + 1 { c.px(42 + (y & 1), y, headDark); c.px(41 + (y & 1) * 2, y, head) }   // ragged hackles
    c.rect(53, hy - 2, 3, 1, headDark)                                   // the brow
    c.rect(54, hy - 1, 2, 2, C(0x1A120A)); c.px(55, hy - 1, C(0xFFF0C0))
    c.pattern(56, hy - 2, [
        "BBBB....",
        "BBBBBB..",
        "BBBBBBBB",
        "DDDDB.BB",
        "DDD....D",
    ], ["B": beak, "D": beakDark])
    if engines {
        // The near wing, spread wide: raised up and back, or swept down and back below the body
        let a: Double = up ? -2.2 : 2.55
        eagleWing(c, hx: 42, hy: up ? by - 2 : by, angle: a, len: up ? 19 : 23, width: 7.5, side: up ? -1 : 1,
                  splay: true, cover: bodyLight, flight: feather, stripe: flight, tip: tipCol)
    } else {
        // Folded along the back; `ramp` swings the near wing down about the shoulder to its foot on the ground
        let hx = 44.0, hy = by - 4
        let foot = (x: 19.0, y: 27.5)
        let closed: Double = atan2(1.0, -26.0), open = atan2(foot.y - hy, foot.x - hx)
        let a = closed + (open - closed) * ramp
        let len = 26.0 + (hypot(foot.x - hx, foot.y - hy) - 26.0) * ramp
        eagleWing(c, hx: hx, hy: hy, angle: a, len: len, width: 5, side: -1, splay: ramp > 0.5, cover: bodyLight,
                  flight: feather, stripe: flight, tip: tipCol)
    }
}
