import Foundation

let doctorScenes1: [Location: Place] = [
    .consoleRoom: Place(name: "The Console Room", panel: 0x0C1A20, still: Scenes.consoleRoom, moving: Scenes.consoleRoomLife),
]

// MARK: - The TARDIS console room

extension Scenes {
    /// Where the console stands: its centre, the top of its deck and its half-width; the rotor's glass column rises
    /// from the deck to `rotorTop`, a fixed height on every screen.
    static func consoleFrame(_ c: PixelCanvas, _ g: Int) -> (cx: Int, deck: Int, half: Int, rotorTop: Int, rotorHalf: Int) {
        let s = unit(g), tall = isTall(c)
        let deck = g - 12 * s
        return (c.w / 2, deck, 30 * s, max(4 * s, deck - (tall ? 40 : 30) * s), 4 * s)
    }

    /// The TARDIS console room: bigger on the inside. Round walls of glowing roundels in a teal gloom, two great coral
    /// struts curving up into the dark, a metal grating underfoot. In the middle stands the six-sided console, its
    /// panels studded with switches, and out of it rises the glass column of the time rotor. On the screen saver the
    /// roundels climb on up to a gallery running round the room.
    static func consoleRoom(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = consoleFrame(c, g)
        c.gradient(0, g, C(0x08141A), C(0x16323C), bands: 8)
        // The roundels, in staggered rows, dimmer further up.
        let step = 14 * s
        var row = 0
        for y in stride(from: g - 8 * s, to: -step, by: -step) {
            let fade = max(0.35, 1 - Double(g - y) / Double(max(g, 1)) * 0.8)
            for x in stride(from: (row % 2) * step / 2 - step, to: c.w + step, by: step) {
                c.circle(x, y, 5 * s, C(0x1E3E48).alpha(fade))
                c.circle(x, y, 4 * s, C(0x2E6A76).alpha(fade))
                c.circle(x, y, 2 * s, C(0x8AE0E8).alpha(fade * 0.55))
            }
            row += 1
        }
        if tall {
            // The gallery: a walkway with its railing round the room, two thirds of the way down.
            let gy = g * 2 / 3
            c.rect(0, gy, c.w, 3 * s, C(0x24424C)); c.rect(0, gy, c.w, s, C(0x5A9AA4))
            c.rect(0, gy - 8 * s, c.w, s, C(0x5A9AA4))
            for x in stride(from: 0, to: c.w, by: 6 * s) { c.rect(x, gy - 8 * s, s, 8 * s, C(0x3E727C)) }
        }
        // The coral struts, curving in from the sides.
        for side in [-1, 1] {
            let baseX = side < 0 ? c.w / 8 : c.w - c.w / 8
            for y in 0..<g {
                let k = Double(g - y) / Double(g)
                let x = baseX - side * Int(k * k * Double(c.w) * 0.12)
                c.rect(x - 3 * s, y, 6 * s, 1, C(0xB8683A))
                c.rect(x - 3 * s, y, s, 1, C(0xE89A62))
                c.rect(x + 2 * s, y, s, 1, C(0x7A4224))
            }
        }
        // The console: six sides seen from the front, three panels showing.
        let deck = f.deck, half = f.half, cx = f.cx
        c.rect(cx - half / 2, deck + 4 * s, half, g - deck - 4 * s, C(0x2A3A40))   // the pedestal
        for (i, x0) in [cx - half, cx - half / 3, cx + half / 3].enumerated() {
            let w = half * 2 / 3
            let col = i == 1 ? C(0x5A7A82) : C(0x46626A)
            c.rect(x0, deck, w, 5 * s, col)
            c.rect(x0, deck, w, s, C(0x9AC8D0))
            c.rect(x0 + w - s, deck, s, 5 * s, C(0x2E444A))
        }
        c.rect(cx - half, deck + 5 * s, half * 2, s, C(0x1E2C32))
        // The rotor's glass column and the ceiling fitting it rises into.
        let rh = f.rotorHalf
        c.rect(cx - rh - s, f.rotorTop, s, deck - f.rotorTop, C(0x8AE0E8, 0.55))
        c.rect(cx + rh, f.rotorTop, s, deck - f.rotorTop, C(0x8AE0E8, 0.55))
        c.rect(cx - rh, f.rotorTop, rh * 2, deck - f.rotorTop, C(0x2E8A9A, 0.25))
        c.rect(cx - rh - 2 * s, f.rotorTop - 2 * s, rh * 2 + 4 * s, 2 * s, C(0x46626A))
        // The rotor's crown: a stepped cap of coral and metal, with a little light on top.
        let crown = Pen(c, cx, f.rotorTop - 2 * s, g)
        crown.rect(-5, -2, 10, 2, C(0x5A7A82)); crown.rect(-5, -2, 10, 1, C(0x9AC8D0))
        crown.rect(-3, -4, 6, 2, C(0xB8683A)); crown.rect(-3, -4, 1, 2, C(0xE89A62))
        crown.rect(-1, -6, 2, 2, C(0x8AE0E8, 0.8))
        doctorConsoleDetails(c, g)
        // The grating underfoot.
        c.ground(g, C(0x22343A), edge: C(0x6A9AA4), speck: C(0x1A282E), seed: 9)
        for x in stride(from: 0, to: c.w, by: 4 * s) { c.rect(x, g + 1, s, c.h - g - 1, C(0x1A282E)) }
    }

    /// What fills the room round the console, every piece a fixed size standing on the grating: the police box's
    /// doors seen from inside on the left, their windows lit from outside; a hat stand hung with a long coat and a
    /// striped scarf on the right; the scanner screen on its arm over the console; cables snaking along the foot of
    /// the walls. On the screen saver round doorways open off the gallery and a ceiling hub caps the struts.
    static func doctorConsoleDetails(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = consoleFrame(c, g)
        // Cables along the foot of the walls, behind everything else.
        for (k, y) in [g - 3 * s, g - 5 * s].enumerated() {
            for x in stride(from: 0, to: c.w, by: s) where abs(x - f.cx) > f.half / 2 + s {
                let sag = Int((sin(Double(x) / Double(18 * s) + Double(k) * 2) * 0.5 + 0.5) * Double(2 * s))
                c.rect(x, y - sag, s, s, k == 0 ? C(0x10202A) : C(0x1A3038))
            }
        }
        // The doors.
        let door = Pen(c, c.w * 24 / 100, g, g)
        door.rect(-12, -38, 24, 38, C(0x0E1C22))                                        // the frame's shadow
        door.rect(-11, -37, 22, 37, C(0x1C3A62))
        door.rect(-11, -37, 1, 37, C(0x3A6AA0)); door.rect(10, -37, 1, 37, C(0x10243E))
        door.rect(0, -36, 1, 36, C(0x10243E))                                           // the seam
        for side in [-9, 2] {
            door.rect(side, -35, 7, 7, C(0xCCE6EE))                                     // windows, lit from outside
            door.rect(side + 3, -35, 1, 7, C(0x1C3A62)); door.rect(side, -32, 7, 1, C(0x1C3A62))
            for k in 0..<3 {
                door.rect(side, -26 + k * 8, 7, 7, C(0x16304E)); door.rect(side, -26 + k * 8, 7, 1, C(0x2E5A8A))
            }
        }
        door.rect(-8, -24, 5, 3, C(0xD8D8C8, 0.8))                                       // the notice
        door.rect(-2, -16, 1, 2, C(0xC8B060)); door.rect(1, -16, 1, 2, C(0xC8B060))       // handles
        c.rect(door.x - 22 * s, g - 2 * s, 44 * s, 2 * s, C(0xCCE6EE, 0.08))               // light spilling under them
        // The hat stand, hung with a coat and a scarf.
        let hs = Pen(c, c.w * 79 / 100, g, g)
        hs.rect(-4, -1, 9, 1, C(0x3A2418)); hs.rect(0, -36, 1, 36, C(0x5A3A24))
        hs.rect(-3, -34, 7, 1, C(0x5A3A24)); hs.rect(-3, -35, 1, 1, C(0x5A3A24)); hs.rect(3, -35, 1, 1, C(0x5A3A24))
        hs.rect(-4, -33, 4, 18, C(0x4A3426)); hs.rect(-4, -33, 1, 18, C(0x6A4A34))        // the long coat
        hs.rect(-3, -15, 3, 2, C(0x4A3426))
        for k in 0..<12 {                                                                // the scarf, in stripes
            let col = [C(0xB8683A), C(0xC8A060), C(0x7A4A6A), C(0x6A8A4A)][k % 4]
            hs.rect(1 + (k > 6 ? 1 : 0), -33 + k * 2, 2, 2, col)
        }
        hs.rect(-2, -37, 5, 1, C(0x2A2A30)); hs.rect(-1, -38, 3, 1, C(0x2A2A30))            // a hat on top
        // The scanner screen on its jointed arm over the console's right side.
        let sc = Pen(c, f.cx + f.half - 6 * s, f.deck, g)
        sc.rect(0, -10, 1, 10, C(0x46626A)); sc.rect(0, -10, 6, 1, C(0x46626A))
        sc.rect(4, -18, 12, 9, C(0x2E444A)); sc.rect(5, -17, 10, 7, C(0x0A2028))
        sc.rect(6, -15, 6, 1, C(0x6AE8F4, 0.6)); sc.rect(6, -13, 8, 1, C(0x6AE8F4, 0.4))
        guard tall else { return }
        // The gallery's round doorways, standing on its walkway.
        let gy = g * 2 / 3
        for fx in [30, 70] {
            let d = Pen(c, c.w * fx / 100, gy, g)
            d.ellipse(0, -14, 11, 12, C(0x1E3E48)); d.ellipse(0, -14, 9, 10, C(0x081418))
            d.rect(-9, -14, 18, 14, C(0x081418)); d.rect(-11, -14, 2, 14, C(0x1E3E48)); d.rect(9, -14, 2, 14, C(0x1E3E48))
            d.circle(0, -12, 3, C(0x2E6A76, 0.6)); d.circle(0, -12, 1, C(0x8AE0E8, 0.4))
        }
        // A bookcase and a reading lamp at the gallery's far end.
        let bk = Pen(c, c.w * 88 / 100, gy, g)
        bk.rect(-9, -22, 18, 22, C(0x3A2418)); bk.rect(-8, -21, 16, 20, C(0x1A1010))
        for (r, v) in [-21, -14, -7].enumerated() {
            var u = -8
            while u < 7 {
                let w = 1 + Int(noise(r * 17 + u + 60) * 2)
                bk.rect(u, v + 1 + (u + r) % 2, w, 6 - (u + r) % 2, [C(0x7A2A2A), C(0x2A4A6A), C(0x8A6A2A), C(0x3A5A3A)][(u + r * 3 + 8) % 4])
                u += w + 1
            }
            bk.rect(-8, v + 6, 16, 1, C(0x3A2418))
        }
        bk.rect(12, -18, 1, 18, C(0x46626A)); bk.rect(10, -21, 5, 3, C(0xE8C070, 0.85))
        // The ceiling hub the struts curve up into, ringed with lights, cables hanging from it with lamps on.
        let hub = Pen(c, c.w / 2, 0, g)
        hub.ellipse(0, 0, 44, 12, C(0x7A4224)); hub.ellipse(0, 0, 42, 10, C(0x24424C)); hub.ellipse(0, -1, 34, 7, C(0x16323C))
        hub.rect(-44, 0, 88, 1, C(0xE89A62))
        for k in stride(from: -32, through: 32, by: 8) { hub.circle(k, 6, 2, C(0x2E6A76)); hub.circle(k, 6, 1, C(0x8AE0E8, 0.8)) }
        for (k, u) in [-36, -20, 20, 36].enumerated() {
            let len = [26, 40, 34, 22][k]
            for v in 10..<(10 + len) { hub.rect(u + (v / 9) % 2, v, 1, 1, C(0x10202A)) }
            hub.rect(u - 1, 10 + len, 3, 2, C(0x46626A)); hub.rect(u, 12 + len, 1, 1, C(0xFFE8A8))
            c.circle(hub.x + u * s, (12 + len) * s, 4 * s, C(0xFFE8A8, 0.12))
        }
    }

    /// What moves in the console room: the rotor pumping up and down in its glass column with the glow breathing,
    /// and the console's lights blinking.
    static func consoleRoomLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = consoleFrame(c, g)
        let cx = f.cx, rh = f.rotorHalf, span = f.deck - f.rotorTop
        guard span > 4 * s else { return }
        let pump = 0.5 - 0.5 * cos(t * 2 * .pi / 2.6)
        // The glow, brighter as the rotor rises.
        c.rect(cx - rh, f.rotorTop, rh * 2, span, C(0x6AE8F4, 0.12 + 0.18 * pump))
        // Two stacks of crystal rings, the upper one coming down as the lower one goes up.
        let travel = Double(span) * 0.3
        for (k, base) in [(0, f.deck - 2 * s), (1, f.rotorTop + 2 * s)] {
            let off = Int((k == 0 ? -1.0 : 1.0) * travel * pump)
            for i in 0..<3 {
                let y = base + off + (k == 0 ? -i * 3 * s : i * 3 * s)
                guard y > f.rotorTop, y < f.deck else { continue }
                c.rect(cx - rh + s, y, rh * 2 - 2 * s, s, C(0xC8F4F8, 0.85))
                c.rect(cx - rh + 2 * s, y + s, rh * 2 - 4 * s, s, C(0x4AB8C8, 0.7))
            }
        }
        // The console's lights.
        let deck = f.deck, half = f.half
        for i in 0..<12 {
            let x = cx - half + 2 * s + Int(noise(i * 5 + 1) * Double(half * 2 - 4 * s))
            let y = deck + 2 * s + Int(noise(i * 5 + 2) * Double(2 * s))
            let on = noise(i * 13 + Int(t * (1.5 + noise(i) * 2))) > 0.45
            let col = [C(0xFF6A4A), C(0x6AFF8A), C(0xFFD24A), C(0x6AC8FF)][i % 4]
            if on { c.rect(x, y, s, s, col) }
        }
    }
}
