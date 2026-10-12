import Foundation

// The ships that come to pick someone up when their agent is done (`Cast.ride`): the Quinjet for the Avengers,
// the Milano for the Guardians. Drawn nose to the right on a `Ride.width`×`Ride.height` canvas, sitting on its bottom
// row when landed; the boarding ramp comes down to the left of centre, its foot about 14 px left of the middle.

extension Ride {
    static let width = 66, height = 29
}

/// `ramp` 0…1 lowers the boarding ramp, `engines` lights the thrusters, `gear`: landing gear down.
func drawRide(_ c: PixelCanvas, _ ride: Ride, ramp: Double, engines: Bool, gear: Bool) {
    switch ride {
    case .quinjet: drawQuinjet(c, ramp: ramp, engines: engines, gear: gear)
    case .milano: drawMilano(c, ramp: ramp, engines: engines, gear: gear)
    }
}

/// The hull's outline at column `x`, read off a polyline of (x, y) points (straight between them).
private func profile(_ x: Int, _ pts: [(Double, Double)]) -> Int {
    let fx = Double(x)
    for i in 1..<pts.count where fx <= pts[i].0 {
        let (a, b) = (pts[i - 1], pts[i])
        return Int((a.1 + (b.1 - a.1) * (fx - a.0) / (b.0 - a.0)).rounded())
    }
    return Int(pts[pts.count - 1].1.rounded())
}

/// A hull filled column by column between the `top` and `bottom` outlines, lit along its spine and shaded
/// along its belly.
private func hull(_ c: PixelCanvas, x0: Int, x1: Int, top: [(Double, Double)], bottom: [(Double, Double)],
                  body: Px, light: Px, dark: Px) {
    for x in x0...x1 {
        let t = profile(x, top), b = profile(x, bottom)
        guard b >= t else { continue }
        c.rect(x, t, 1, b - t + 1, body)
        c.px(x, t, light)
        c.px(x, b, dark)
        if b - t > 4 { c.px(x, b - 1, dark) }
    }
}

/// The boarding ramp, hinged under the hull at (`hx`, `hy`) and swinging down to its foot on the ground about 14 px
/// left of centre; a warm light spills from the hold behind it.
private func drawRamp(_ c: PixelCanvas, ramp: Double, hx: Double, hy: Double, plate: Px, edge: Px) {
    guard ramp > 0 else { return }
    let foot = (x: 19.0, y: 27.5)
    let closed = atan2(0.0, -1.0), open = atan2(foot.y - hy, foot.x - hx)
    let a = closed + (open - closed) * ramp, len = hypot(foot.x - hx, foot.y - hy)
    let tip = (x: hx + cos(a) * len, y: hy + sin(a) * len)
    c.rect(Int(tip.x) + 1, Int(hy) - 3, Int(hx - tip.x) - 1, 3, C(0xFFD890, 0.35 + 0.5 * ramp))   // the lit hold
    c.glowLine(hx, hy, tip.x, tip.y, core: plate, glow: C(0x000000, 0), coreR: 1, glowR: 1.1)
    c.glowLine(hx, hy - 0.6, tip.x, tip.y - 0.6, core: edge, glow: C(0x000000, 0), coreR: 0.35, glowR: 0.4)
}

/// Landing legs with wide feet, standing on the bottom row.
private func drawGear(_ c: PixelCanvas, xs: [Int], from y: Int, strut: Px, foot: Px) {
    for x in xs {
        c.rect(x, y, 1, 27 - y, strut)
        c.rect(x - 1, 27, 3, 1, foot); c.rect(x - 2, 28, 5, 1, foot)
    }
}

/// The Avengers' Quinjet (the films): a matt dark-grey stealth wedge with a sloping glass canopy, a swept wing with
/// its big lift-fan nacelle, twin canted tail fins with the Avengers "A", and blue thrusters at the tail.
private func drawQuinjet(_ c: PixelCanvas, ramp: Double, engines: Bool, gear: Bool) {
    let body = C(0x3E434E), light = C(0x6A717E), dark = C(0x252830), panel = C(0x30343D), steel = C(0x8A929E)
    if gear { drawGear(c, xs: [12, 50], from: 22, strut: dark, foot: steel) }
    // The far tail fin, behind
    for y in 4...13 {
        let f = Double(y - 4) / 9
        let l = Int(9 + f * 4), r = Int(13 + f * 9)
        c.rect(l, y, r - l + 1, 1, panel)
    }
    hull(c, x0: 4, x1: 65, top: [(4, 15), (14, 12), (34, 10), (48, 11), (58, 15), (65, 18)],
         bottom: [(4, 20), (9, 23), (50, 23), (59, 21), (65, 19)], body: body, light: light, dark: dark)
    // The near tail fin, canted back, with the "A" in a white roundel
    for y in 2...12 {
        let f = Double(y - 2) / 10
        let l = Int(4 + f * 4), r = Int(8 + f * 10)
        c.rect(l, y, r - l + 1, 1, body)
        c.px(l, y, light)
    }
    c.circle(11, 8, 2, C(0xE8ECF2))
    c.pattern(10, 7, [".K.", "KKK", "K.K"], ["K": C(0x2A3A6A)])
    // Canopy: dark glass along the nose, with a sky-blue glint
    for x in 46...59 {
        let t = profile(x, [(4, 15), (14, 12), (34, 10), (48, 11), (58, 15), (65, 18)])
        c.rect(x, t + 1, 1, 2, C(0x1E2A3A))
        if x > 48 && x < 55 { c.px(x, t + 1, C(0x8AC8F0)) }
    }
    c.rect(14, 17, 34, 1, panel)                                     // panel line down the flank
    for x in stride(from: 18, through: 44, by: 6) { c.px(x, 15, panel) }
    // Wing root and the lift-fan nacelle
    c.pattern(18, 17, [
        "......LLLLLLLLLLLLLLLL......",
        "....BBBBBBBBBBBBBBBBBBBBK...",
        "..BBBBBBBBBBBBBBBBBBBBBBKK..",
        "DDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    ], ["L": light, "B": steel, "K": dark, "D": dark])
    c.rect(41, 18, 2, 2, C(0x16181E))                                // the fan intake
    drawRamp(c, ramp: ramp, hx: 33, hy: 23, plate: panel, edge: steel)
    if engines {
        c.rect(1, 15, 3, 5, C(0x6FB8FF)); c.rect(0, 16, 1, 3, C(0xBFE0FF))
        c.rect(25, 21, 14, 1, C(0x6FB8FF, 0.8))                       // the fan's downwash glow
    }
}

/// The Guardians' Milano (the films): a long blue hull with orange stripes, the bubble cockpit up front, a swept
/// wing rising behind with an engine pod at its tip, a ventral fin, and orange thrusters.
private func drawMilano(_ c: PixelCanvas, ramp: Double, engines: Bool, gear: Bool) {
    let body = C(0x2E5AA8), light = C(0x6A96E0), dark = C(0x1C366E), orange = C(0xE8782A), orangeD = C(0xB0561A)
    let steel = C(0x9AA2AE)
    if gear { drawGear(c, xs: [14, 50], from: 22, strut: dark, foot: steel) }
    // The far wing, behind, rising up and back with its engine pod
    c.pattern(14, 2, [
        "..PPPPPP..............",
        ".PPPPPPPP.............",
        "..PPPPPP..............",
        "...WWW................",
        "....WWWWW.............",
        ".....WWWWWWW..........",
        "......WWWWWWWWW.......",
        ".......WWWWWWWWWWW....",
        "........WWWWWWWWWWWWW.",
    ], ["W": dark, "P": C(0x24304A)])
    hull(c, x0: 6, x1: 65, top: [(6, 14), (16, 11), (40, 11), (50, 12), (58, 15), (65, 18)],
         bottom: [(6, 20), (11, 23), (48, 23), (58, 21), (65, 19)], body: body, light: light, dark: dark)
    // Orange stripes down the flank and the nose tip
    for x in 8...62 { c.px(x, profile(x, [(6, 14), (16, 11), (40, 11), (50, 12), (58, 15), (65, 18)]) + 5, orange) }
    for x in 12...56 { c.px(x, profile(x, [(6, 14), (16, 11), (40, 11), (50, 12), (58, 15), (65, 18)]) + 6, orangeD) }
    c.rect(63, 18, 3, 1, orange)
    // The bubble cockpit
    c.ellipse(52, 12, 5, 2, C(0x1E2A3A))
    c.rect(49, 11, 4, 1, C(0xF0C870)); c.px(54, 11, C(0xF0C870))
    c.rect(47, 13, 11, 1, orange)
    // The near wing: swept up and back from the hull, orange on its leading edge, engine pod at the tip
    c.pattern(9, 0, [
        "..PPPPPPPP..............",
        ".PPpppppPPP.............",
        "PPPPPPPPPPPP............",
        ".PPPPPPPPPP.............",
        "...OOOO.................",
        "....WWWOO...............",
        ".....WWWWOO.............",
        "......WWWWWOO...........",
        ".......WWWWWWOO.........",
        "........WWWWWWWOO.......",
        ".........WWWWWWWWOOO....",
        "..........WWWWWWWWWWOOO.",
    ], ["W": body, "O": orange, "P": C(0x3A4458), "p": steel])
    // Ventral fin
    c.pattern(10, 21, ["FFFFFF", ".FFFF.", "..FF.."], ["F": dark])
    for x in stride(from: 20, through: 44, by: 8) { c.rect(x, 16, 1, 3, dark) }   // hull panel seams
    drawRamp(c, ramp: ramp, hx: 33, hy: 23, plate: dark, edge: orange)
    if engines {
        c.rect(3, 15, 3, 5, C(0xFF9A4A)); c.rect(2, 16, 1, 3, C(0xFFE0A0))
        c.rect(6, 2, 3, 3, C(0xFF9A4A)); c.px(5, 3, C(0xFFE0A0))      // the wing pod's thruster
    }
}
