import Foundation

// Stevie Clawdberg's rides (`Ride`), drawn nose to the right on the ships' `Ride.width`×`Ride.height` canvas: the
// DeLorean for Back to the Future (it drives in along the ground, `Ride.drives`, crackling blue with fire in its
// tracks), the moon bike for the E.T. kids and the Goonies (it flies, the basket up front), the mothership for Close
// Encounters (its "ramp" is the light pouring out under it), and the park jeep for Jurassic Park's people.

/// The DeLorean: a low brushed-steel wedge with gull-wing doors, the flux-capacitor glow through the back window and the
/// time machine's coils and vents on its tail. `ramp` 0…1 lifts the gull-wing door; `lit`: on the move at 88 mph, blue
/// sparks crackling over it and two fire trails burning behind its wheels.
func drawDelorean(_ c: PixelCanvas, ramp: Double, lit: Bool) {
    let steel = C(0xB8BEC6), shine = C(0xDCE2E8), dark = C(0x6E747C), black = C(0x1A1C20), glass = C(0x2A3440)
    let tyre = C(0x101114), hub = C(0x9AA0A8)
    if lit {   // the fire trails, first, so the car sits over their ends
        for (i, y) in [24, 25].enumerated() {
            for x in 0..<14 {
                let flick = noise(x * 7 + i * 31) * 0.4
                c.px(x, y, (x % 3 == 0 ? C(0xFFE04A) : C(0xFF7A1A)).alpha(0.35 + Double(x) / 14 * (0.5 + flick)))
            }
        }
    }
    // The wedge: a long low body, the cabin's slope, the louvred back.
    c.rect(8, 17, 52, 7, steel); c.rect(8, 23, 52, 1, dark)
    c.rect(6, 18, 2, 5, steel); c.rect(60, 19, 2, 4, steel)
    c.rect(8, 17, 52, 1, shine)
    for y in 10..<17 {
        let up = 17 - y, back = 14 + up * 2, front = 46 - up * 2
        c.rect(back, y, front - back, 1, steel)
    }
    c.rect(28, 10, 10, 1, shine)
    // The windows: the side glass, and the back louvres over the warm flux glow.
    for y in 11..<16 { let up = 17 - y; c.rect(28 - up, y, 16 - up / 2, 1, glass) }
    c.rect(16, 13, 8, 3, C(0xFFD27A, 0.7))
    for x in stride(from: 16, to: 24, by: 2) { c.rect(x, 12, 1, 4, dark) }
    c.rect(8, 20, 52, 1, black)                                    // the black stripe along the sill
    // The time machine's kit on the tail: the coil, the vents, and Mr. Fusion on top.
    c.rect(4, 15, 4, 6, dark); c.rect(5, 16, 2, 4, C(0x8A9098))
    c.rect(9, 14, 3, 2, C(0xE8E8EC)); c.rect(10, 13, 1, 1, C(0xE8E8EC))
    c.rect(8, 16, 6, 1, C(0x4A8AD8, 0.8))
    c.rect(59, 19, 1, 2, lit ? C(0xFFF6C8) : C(0xC8C8B8))         // the headlights
    c.rect(7, 19, 1, 2, C(0xC82A2A))
    // The wheels.
    for wx in [17, 50] { c.circle(wx, 24, 4, tyre); c.circle(wx, 24, 2, hub); c.px(wx, 24, tyre) }
    // The gull-wing door, lifting.
    if ramp > 0 {
        let up = Int((8 * ramp).rounded())
        c.rect(27, 12, 12, 10, C(0xFFE8B0, 0.8))
        c.rect(27, 12 - up, 12, 2, steel); c.rect(27, 12 - up, 12, 1, shine)
        c.rect(37, 12 - up, 2, up, dark)
    }
    if lit {   // blue sparks crackling over the body
        let k = 3
        for i in 0..<5 {
            let x = 10 + Int(noise(i * 5 + k) * 46), y = 9 + Int(noise(i * 5 + k + 2) * 14)
            c.px(x, y, C(0xCFE8FF)); c.px(x + 1, y - 1, C(0x7AB8FF, 0.8)); c.px(x - 1, y + 1, C(0x7AB8FF, 0.6))
        }
    }
}

/// The moon bike: a red BMX ridden by a kid in a red hoodie, the little alien in a white blanket in the basket up
/// front, flying. No ramp: whoever's taken climbs on at the middle.
func drawMoonBike(_ c: PixelCanvas, ramp: Double, lit: Bool) {
    let frame = C(0xC82A2A), tyre = C(0x18181C), hoodie = C(0xB8202A), basket = C(0xC8A060), sheet = C(0xF2F0EA)
    // The wheels.
    for wx in [20, 46] {
        c.circle(wx, 22, 5, tyre); c.circle(wx, 22, 3, C(0x3A3A44)); c.rect(wx - 3, 22, 7, 1, C(0x8A8A90)); c.rect(wx, 19, 1, 7, C(0x8A8A90))
    }
    // The frame, the handlebars and the seat.
    cbLine(c, 20, 22, 30, 16, frame, 0.6); cbLine(c, 30, 16, 42, 16, frame, 0.6)
    cbLine(c, 30, 16, 33, 22, frame, 0.6); cbLine(c, 20, 22, 33, 22, frame, 0.6)
    cbLine(c, 42, 16, 46, 22, frame, 0.6); cbLine(c, 42, 16, 41, 11, frame, 0.6)
    c.rect(39, 10, 4, 1, C(0x2A2A30)); c.rect(27, 14, 5, 1, C(0x2A2A30))
    // The basket, and the little alien in his blanket peeking out.
    c.rect(44, 11, 8, 5, basket); c.rect(44, 11, 8, 1, C(0x8A6A3A))
    c.rect(45, 6, 6, 5, sheet); c.rect(46, 5, 4, 1, sheet)
    c.rect(46, 8, 4, 3, C(0x8A6A4A)); c.px(47, 9, C(0x1A1410)); c.px(49, 9, C(0x1A1410))
    // The rider, leaning in, hood up.
    c.rect(27, 6, 9, 8, hoodie); c.rect(28, 4, 7, 3, hoodie); c.rect(33, 6, 3, 3, C(0xE8B898))
    c.rect(35, 9, 5, 2, hoodie)
    c.rect(29, 14, 3, 5, C(0x3A4A6A)); c.rect(30, 18, 3, 2, C(0x3A4A6A))
    if ramp > 0 { c.rect(29, 19, 2, 2, white.alpha(ramp * 0.5)) }
}

/// The mothership: a vast dark dome crowned with lights, coloured lamps in rows round its belly and a blaze of white
/// light underneath. Its "ramp" is that light pouring down (`ramp` 0…1), which whoever's taken walks into; `lit`: the
/// lamps chase round while it moves.
func drawMothership(_ c: PixelCanvas, ramp: Double, lit: Bool) {
    let cx = 33
    if ramp > 0 {
        for y in 16..<c.h {
            let k = Double(y - 16) / Double(max(1, c.h - 17))
            let half = Int((10 + 8 * k) * min(1, ramp * 1.2))
            c.rect(cx - half, y, half * 2 + 1, 1, C(0xFFF8E8, 0.32 * ramp))
        }
    }
    // The dome, dark, built up of rings, with points of light on it.
    c.ellipse(cx, 12, 30, 6, C(0x2A2A36)); c.ellipse(cx, 9, 22, 6, C(0x34343F)); c.ellipse(cx, 6, 12, 4, C(0x3E3E4A))
    c.rect(cx, 0, 1, 3, C(0x8A8A96))
    for i in 0..<14 { c.px(cx - 20 + Int(noise(i + 600) * 40), 4 + Int(noise(i + 610) * 8), C(0xFFFFFF, 0.8)) }
    // The rows of coloured lamps round the belly, shifting while it moves.
    let colours = [C(0xFF4A4A), C(0xFFB84A), C(0xFFF04A), C(0x4AE87A), C(0x4AB8FF), C(0xC86AFF)]
    let k = lit ? 1 : 0
    for (row, y) in [13, 15].enumerated() {
        for (i, x) in stride(from: cx - 27 + row * 3, through: cx + 27 - row * 3, by: 3).enumerated() {
            c.rect(x, y, 2, 1, colours[(i + k + row * 2) % colours.count])
        }
    }
    // The glare underneath.
    c.ellipse(cx, 17, 16, 2, C(0xFFF8E8, lit ? 0.95 : 0.7)); c.ellipse(cx, 17, 8, 1, white)
}

/// The park jeep: a red-and-green Jurassic Park Wrangler with the yellow band and the logo on its door, a roll bar and
/// a spare tyre on the back. `ramp`: its side opens up (it has no doors to speak of); `lit`: headlights on.
func drawParkJeep(_ c: PixelCanvas, ramp: Double, lit: Bool) {
    let green = C(0x2E6A3A), red = C(0xC82A2A), yellow = C(0xF2C82A), dark = C(0x1A2A1E), tyre = C(0x101114)
    // The roll bar and the windscreen.
    c.rect(18, 7, 2, 10, C(0x3A3A40)); c.rect(32, 7, 2, 10, C(0x3A3A40)); c.rect(18, 7, 16, 2, C(0x3A3A40))
    c.rect(42, 9, 2, 8, C(0x3A3A40)); c.rect(42, 10, 2, 6, C(0x8AB8C8, 0.6))
    // The body: green bonnet and sides, the red flank, the yellow band, the grille.
    c.rect(8, 16, 50, 8, green); c.rect(8, 16, 50, 1, C(0x4A8A56))
    c.rect(8, 20, 50, 2, red); c.rect(8, 19, 50, 1, yellow)
    c.rect(56, 17, 3, 6, C(0x1E3A24)); for y in [18, 20] { c.rect(56, y, 3, 1, C(0x5A6A5E)) }
    c.rect(8, 23, 50, 1, dark)
    // The logo on the door: a red disc with the skeleton's black outline.
    c.circle(30, 18, 2, red); c.px(30, 18, C(0x1A1A1A)); c.px(31, 17, C(0x1A1A1A))
    // The spare tyre on the back, and the wheels.
    c.circle(6, 18, 4, tyre); c.circle(6, 18, 2, C(0x5A5A60))
    for wx in [17, 49] { c.circle(wx, 24, 5, tyre); c.circle(wx, 24, 2, C(0x8A8A90)); c.px(wx, 24, tyre) }
    c.rect(58, 18, 1, 2, lit ? C(0xFFF6C8) : C(0xC8C8B8))
    if ramp > 0 { c.rect(22, 12, 10, 4, C(0xE8D8A8, 0.5 * ramp)) }
}
