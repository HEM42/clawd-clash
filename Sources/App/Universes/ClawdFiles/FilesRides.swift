import Foundation

// The Clawd Files' rides (`Ride`), drawn nose to the right on the ships' `Ride.width`×`Ride.height` canvas: the FBI's
// unmarked sedan for the agents and their friends (it drives in along the ground rather than flying, `Ride.drives`
// in Theme.swift), the Syndicate's black helicopter, and the saucer that takes the aliens, whose "ramp" is its beam
// of light.

/// The FBI's unmarked sedan: a boxy dark blue-grey four-door saloon (bonnet, cabin, a boot of its own), its rear door the
/// boarding ramp (`ramp` 0…1 swings it open on the lit inside, its foot about 14 px left of centre), `lights` on:
/// headlights and a red light flashing on the dash.
func drawSedan(_ c: PixelCanvas, ramp: Double, lights: Bool) {
    let body = C(0x2E3A4E), light = C(0x4A5A72), dark = C(0x1C2432), glass = C(0x16202C), shine = C(0x8AA0B8)
    let chrome = C(0xB8C0C8), tyre = C(0x101114), hub = C(0x8A9098), arch = C(0x0C1018)
    // The lower body, the boot lid behind and the bonnet in front, a step down from the cabin each side.
    c.rect(4, 17, 58, 8, body)
    c.rect(4, 16, 13, 1, body); c.rect(4, 16, 13, 1, light)       // the boot lid
    c.rect(46, 16, 15, 1, body); c.rect(46, 16, 15, 1, light)     // the bonnet
    c.rect(3, 18, 1, 6, body); c.rect(62, 18, 1, 6, body)          // the bumpers' ends
    c.rect(4, 24, 58, 1, dark)
    c.rect(4, 20, 58, 1, chrome.alpha(0.7))                       // the trim line along the side
    // The cabin: the rear window sloping up from the boot, the roof, the windscreen sloping down to the bonnet.
    for y in 9..<16 {
        let up = 16 - y                                   // rows above the waist, 1…7
        let back = 16 + up * 2 / 3, front = 47 - up * 3 / 4
        c.rect(back, y, front - back, 1, body)
    }
    c.rect(21, 9, 20, 1, light)
    // The side windows, slanted at the ends, and the pillar between them.
    for y in 11..<16 {
        let up = 16 - y
        let rearEdge = 18 + up * 2 / 3, frontEdge = 45 - up * 3 / 4
        c.rect(rearEdge, y, 31 - rearEdge, 1, glass)
        c.rect(33, y, frontEdge - 33, 1, glass)
    }
    c.px(22, 11, shine); c.px(34, 11, shine); c.px(35, 11, shine)
    c.rect(31, 10, 2, 7, body)                 // the pillar between the doors
    c.rect(32, 17, 1, 7, dark)                 // the doors' seam
    c.rect(19, 17, 1, 7, dark)                 // the rear door's back edge
    c.rect(28, 18, 2, 1, chrome); c.rect(41, 18, 2, 1, chrome)
    // Lights: headlight and tail light, and the dash light the agents put up.
    c.rect(61, 18, 1, 2, lights ? C(0xFFF6C8) : C(0xC8C8B8))
    if lights { c.rect(62, 18, 1, 2, C(0xFFF6C8, 0.6)) }
    c.rect(4, 18, 1, 2, C(0xC82A2A))
    if lights { c.rect(41, 14, 2, 1, C(0xFF3A3A)) }
    // The wheels, in their arches.
    for wx in [13, 52] {
        c.circle(wx, 24, 5, arch)
        c.circle(wx, 24, 4, tyre); c.circle(wx, 24, 2, hub); c.px(wx, 24, tyre)
    }
    // The rear door swinging open on the warm light inside.
    if ramp > 0 {
        let w = 12, open = Int((Double(w) * ramp).rounded())
        c.rect(20, 11, w, 13, C(0xFFE8B0, 0.85)); c.rect(20, 11, w, 1, C(0xFFF6D8))
        c.rect(20, 10, max(1, w - open), 14, body); c.rect(20, 10, max(1, w - open), 1, light)
    }
}

/// The black helicopter: a dark fuselage with a tinted nose bubble, its tail boom off to the left, skids under it and
/// the rotor on top (a long blur while `engines` turn it, the blades drooping when they don't). The side door slides
/// back for boarding (`ramp` 0…1), showing the red-lit cabin.
func drawHelicopter(_ c: PixelCanvas, ramp: Double, engines: Bool, gear: Bool) {
    let hull = C(0x1C1E22), sheen = C(0x3A3E46), dark = C(0x0E0F12), glass = C(0x2A3A44), glint = C(0x8AA8B8)
    // The tail boom, the fin and the tail rotor.
    for x in 2..<20 {
        let h = 3 - (20 - x) / 9
        c.rect(x, 14 - h / 2, 1, max(1, h), hull)
    }
    c.rect(2, 8, 3, 7, hull); c.rect(2, 8, 1, 7, sheen)
    if engines { c.rect(0, 9, 7, 1, C(0x8A8E96, 0.4)); c.rect(3, 6, 1, 7, C(0x8A8E96, 0.35)) } else { c.rect(1, 10, 5, 1, sheen) }
    // The fuselage: rounded front and back.
    for y in 10..<23 {
        let dy = abs(Double(y) - 16.5) / 6.5
        let half = Int((17 * (1 - dy * dy * 0.55)).squareRoot() * 4.2)
        c.rect(36 - half, y, half * 2, 1, hull)
    }
    c.rect(22, 10, 26, 1, sheen); c.rect(20, 22, 30, 1, dark)
    // The nose bubble.
    for y in 11..<19 { let w = 8 - abs(y - 14) / 2; c.rect(46 - w + 6, y, w, 1, glass) }
    c.px(48, 12, glint); c.px(49, 13, glint)
    // The side door: slid back to board, the cabin lit red inside.
    let doorX = 24 - Int((8 * ramp).rounded())
    if ramp > 0 { c.rect(24, 12, 10, 9, C(0x6A1A1A)); c.rect(24, 12, 10, 1, C(0xC83A3A, 0.8)) }
    c.rect(doorX, 12, 10, 9, hull); c.rect(doorX, 12, 1, 9, sheen); c.rect(doorX + 2, 13, 6, 3, glass)
    // The mast and the rotor.
    c.rect(34, 7, 3, 3, dark)
    if engines {
        c.rect(3, 6, 62, 1, C(0x9AA0A8, 0.45)); c.rect(14, 5, 40, 1, C(0x9AA0A8, 0.3))
    } else {
        // Two pixels thick, so the outline doesn't double them.
        c.rect(14, 7, 20, 2, hull); c.rect(37, 7, 20, 2, hull); c.rect(12, 8, 2, 2, hull); c.rect(57, 8, 2, 2, hull)
    }
    // The skids.
    if gear {
        c.rect(24, 23, 1, 4, dark); c.rect(44, 23, 1, 4, dark)
        c.rect(18, 27, 34, 1, dark); c.rect(17, 26, 1, 1, dark); c.rect(52, 26, 1, 1, dark)
    }
    // A red light on the tail while it flies.
    if engines { c.px(2, 7, C(0xFF3A3A)) }
}

/// The saucer: a wide grey disc with a lit dome on top and a ring of lights round its rim (all lit while `engines`
/// run), a glow underneath. Its boarding "ramp" is the beam (`ramp` 0…1): a cone of pale green light down to the ground
/// under its middle, which whoever's taken walks into.
func drawSaucer(_ c: PixelCanvas, ramp: Double, engines: Bool) {
    let metal = C(0xA8B0B8), light = C(0xD4DAE0), dark = C(0x5E6670), dome = C(0x9AF0C8)
    let cx = 33
    // The beam, first, so the disc sits over its top.
    if ramp > 0 {
        for y in 18..<c.h {
            let k = Double(y - 18) / Double(max(1, c.h - 19))
            let half = Int((5 + 9 * k) * min(1, ramp * 1.2))
            c.rect(cx - half, y, half * 2 + 1, 1, C(0xC8FFE0, 0.28 * ramp))
            c.rect(cx - half / 3, y, half / 3 * 2 + 1, 1, C(0xE8FFF4, 0.22 * ramp))
        }
    }
    // The dome.
    for dy in 0...5 {
        let hw = Int((9 * (1 - Double(dy * dy) / 25)).squareRoot() * 3)
        c.rect(cx - hw, 9 - dy, hw * 2 + 1, 1, dome.alpha(0.75))
    }
    c.px(cx - 3, 6, C(0xF0FFF8)); c.px(cx - 2, 5, C(0xF0FFF8))
    // The disc: the upper hull, the rim, the underside.
    c.ellipse(cx, 12, 20, 3, metal)
    c.ellipse(cx, 14, 29, 3, metal)
    c.rect(cx - 28, 13, 57, 1, light)
    // The underside in plain rows: an ellipse this flat ends in one lone pixel, whose outline showed as a stray dot.
    c.rect(cx - 22, 16, 45, 1, dark); c.rect(cx - 15, 17, 31, 1, dark)
    c.rect(cx - 7, 17, 15, 1, C(0x8AFFC8, engines ? 0.8 : 0.4))
    // The rim lights: every one lit while it flies, every other one when it's settled.
    for (i, x) in stride(from: cx - 25, through: cx + 25, by: 5).enumerated() {
        c.px(x, 14, engines || i % 2 == 0 ? C(0xE8FFF0) : C(0x6A8A7A))
    }
}
