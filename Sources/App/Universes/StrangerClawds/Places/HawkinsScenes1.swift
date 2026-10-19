import Foundation

// Places, a few to a file: each one a `Place` in the dictionary below (its name, the tint of the window's card area
// under it, its still picture and what moves there) and its drawing in an extension of `Scenes`. A full universe has
// about 20. Check them with `build/preview place out.png <key>`, which draws each at window size and at screen-saver
// size.
//
// The rules, from the clawdify guide's "Look and style":
//   - The same pixel art as the crew, at the same pixel size: flat colours, two or three tones a material, the light
//     from the front left. A palette of the franchise's own, with grain or halftone where it helps. Nothing painted,
//     glossy or photographic.
//   - The crew stands on the ground row `g` (the rows under it are floor) and their names and speech go above them:
//     keep the floor and the band just above it plain and mid-to-dark, so white outlines and labels read on it. The
//     busy detail goes higher up and at the sides.
//   - Never a bare backdrop: even an empty place gets its furniture, lit on the side the light comes from with a
//     shadow on the ground, and something far off.
//   - Props keep their size: draw buildings, doors and machines in `Scenes.unit(g)` steps, never as a fraction of the
//     canvas's height. The screen saver's canvas is many times taller than the window's strip, and a door sized from
//     the height turns into a sliver.
//   - The window shows a short strip; the screen saver shows it much taller (`Scenes.isTall`), and its upper part
//     needs something in it, not a big empty sky.
//   - The moving layer is drawn every frame, so keep it light, and subtle: a flicker, rain, a blinking light, nothing
//     that flashes across the crew.
//   - Text in a place is short and big enough to read at window size, or left out.

let hawkinsScenes1: [Location: Place] = [
    .hawkinsMeadow: Place(name: "Sample Meadow", panel: 0x1A2414, still: Scenes.hawkinsMeadow, moving: Scenes.hawkinsMeadowLife),
]

// MARK: - Sample Meadow

extension Scenes {
    /// Where things stand in the meadow, shared by the still picture and the moving layer so they line up: the far
    /// hills' line, the barn (x, width and height, in whole units), the fence's top and the windmill's hub.
    static func hawkinsMeadowFrame(_ c: PixelCanvas, _ g: Int) -> (hills: Int, barn: (x: Int, w: Int, h: Int), fence: Int,
                                                                  mill: (x: Int, y: Int)) {
        let s = unit(g)
        let hills = g - (isTall(c) ? 36 : 24) * s
        return (hills, (x: c.w * 62 / 100, w: 30 * s, h: 22 * s), g - 7 * s, (x: c.w * 18 / 100, y: hills - 6 * s))
    }

    /// The Sample Meadow on a summer's afternoon: a blue sky in soft bands, green hills rolling away to the horizon
    /// with a windmill on the far one, a red barn on the right with its white trim, its door and a hayloft, a wooden
    /// fence along the back of the meadow, flowers in the grass, and a path of packed earth along the front where the
    /// crew stands. On the screen saver, the sky rises much higher, with clouds at fixed sizes up in it and a line of
    /// distant poplars on the hills.
    static func hawkinsMeadow(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsMeadowFrame(c, g), tall = isTall(c)
        // The sky, darkening upwards in bands, and (on the screen saver) clouds high up, each the same size as it
        // would be in the window.
        c.gradient(0, g, C(0x3E78C8), C(0xA8D4F0), bands: 7)
        if tall {
            for k in 0..<4 {
                cloud(c, c.w * (12 + k * 24) / 100, f.hills * (20 + (k % 2) * 25) / 100, 5 * s, seed: k + 3)
            }
        }
        // The far hills, two ranges, the nearer one darker; on the screen saver, poplars along the far one.
        c.dunes(base: f.hills, amp: Double(4 * s), freq: 0.02 / Double(s), phase: 1.3, bottom: g, C(0x8AB86A), shade: C(0xA2CC80))
        if tall {
            for k in 0..<9 {
                let x = c.w * (40 + k * 6) / 100, h = (7 + Int(noise(k * 5) * 4)) * s
                c.ellipse(x, f.hills - h / 2, 2 * s, h / 2, C(0x5E8A44)); c.rect(x - s / 2, f.hills - s, max(1, s), 2 * s, C(0x4A3A24))
            }
        }
        c.dunes(base: f.hills + 6 * s, amp: Double(3 * s), freq: 0.03 / Double(s), phase: 4.1, bottom: g, C(0x6E9E50), shade: C(0x86B464))
        // On the screen saver, the nearer hill is deeper: round oaks on it, each the same size as in the window would
        // be, a shade under each on the side away from the light.
        if tall {
            for k in 0..<5 {
                let x = c.w * (8 + k * 21) / 100 + Int(noise(k * 3 + 40) * Double(8 * s)), y = f.hills + 16 * s
                c.rect(x - s / 2, y, max(1, s), 5 * s, C(0x4A3A24))
                c.circle(x, y - 2 * s, 5 * s, C(0x3E7230)); c.circle(x - s, y - 3 * s, 3 * s, C(0x5A9440))
                c.ellipse(x + 2 * s, y + 5 * s, 4 * s, s, C(0x5A8A3E))
            }
        }
        // The windmill on the far hill: a white tower, its cap and its sails (the moving layer turns them).
        let m = f.mill
        c.rect(m.x - 3 * s, m.y, 6 * s, f.hills + 4 * s - m.y, C(0xE8E4D8)); c.rect(m.x + 2 * s, m.y, s, f.hills + 4 * s - m.y, C(0xC8C2B0))
        c.rect(m.x - 4 * s, m.y - 2 * s, 8 * s, 2 * s, C(0x8A4A32)); c.rect(m.x - 1, m.y + 6 * s, 2 * s, 3 * s, C(0x4A3A30))
        // The barn: red boards lit on the left, white trim, a pitched roof with its shadow under the eaves, the big
        // door with its cross brace, the hayloft's opening, and its shadow on the grass to the right.
        let b = f.barn, by = g - 4 * s - b.h
        c.rect(b.x + b.w, g - 6 * s, 6 * s, 2 * s, C(0x4E7A3A))                     // its shadow
        c.rect(b.x, by, b.w, b.h, C(0xA8382C))
        for x in stride(from: b.x, to: b.x + b.w, by: 3 * s) { c.rect(x, by, max(1, s / 2), b.h, C(0x8A2A22)) }
        c.rect(b.x, by, 2 * s, b.h, C(0xC24A3A)); c.rect(b.x + b.w - s, by, s, b.h, C(0x7A2420))
        for k in 0..<(b.w / 2 + 2 * s) {                                             // the roof, stepped
            let y = by - k * 8 * s / (b.w / 2 + 2 * s)
            c.rect(b.x - 2 * s + k, y, b.w + 4 * s - 2 * k, max(1, s), C(0x4A3A3A))
        }
        c.rect(b.x, by, b.w, s, C(0x2E2222))                                         // under the eaves
        let dx = b.x + b.w / 2 - 6 * s, dh = 13 * s
        c.rect(dx - s, by + b.h - dh - s, 14 * s, dh + s, C(0xF0EAE0))               // the door's trim
        c.rect(dx, by + b.h - dh, 12 * s, dh, C(0x7A2A22))
        for k in 0..<12 { c.rect(dx + k * s, by + b.h - dh + k * dh / 12, s, max(1, s), C(0xF0EAE0)) }   // the brace
        c.rect(b.x + b.w / 2 - 3 * s, by - 5 * s, 6 * s, 4 * s, C(0x2A1A16)); c.rect(b.x + b.w / 2 - 3 * s, by - 5 * s, 6 * s, s, C(0xF0EAE0))
        // The fence along the back of the meadow: posts at fixed spacing, two rails lit on top.
        let rail = C(0x9A7A52), railD = C(0x6E5436)
        c.rect(0, f.fence, c.w, s, rail); c.rect(0, f.fence + 3 * s, c.w, s, rail)
        c.rect(0, f.fence + s, c.w, max(1, s / 2), railD); c.rect(0, f.fence + 4 * s, c.w, max(1, s / 2), railD)
        for x in stride(from: 4 * s, to: c.w, by: 16 * s) { c.rect(x, f.fence - 2 * s, 2 * s, 9 * s, railD); c.rect(x, f.fence - 2 * s, s, 9 * s, rail) }
        // The grass up to the path, and flowers in it, up near the fence rather than down where the crew stands.
        c.rect(0, g - 4 * s, c.w, 4 * s, C(0x5A8A3E))
        for i in 0..<(c.w / (6 * s)) {
            let x = Int(noise(i * 7 + 1) * Double(c.w)), y = f.fence + 6 * s + Int(noise(i * 7 + 2) * Double(3 * s))
            let col = [C(0xF4D04A), C(0xF0F0F0), C(0xE070A0)][i % 3]
            c.rect(x, y, s, s, col); c.rect(x, y + s, s, s, C(0x3E6E2A))
        }
        // The path: packed earth, plain and mid-dark so the crew's outlines and names read on it, a lit edge where the
        // grass meets it and a few pebbles.
        c.ground(g, C(0x7A5E3E), edge: C(0x94784E), speck: C(0x6A4E32), seed: 23)
    }

    /// The meadow's life: the windmill's sails turning slowly, and two butterflies wandering over the grass up by the
    /// fence, well above the crew's heads.
    static func hawkinsMeadowLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hawkinsMeadowFrame(c, g)
        // The sails: four of them, a full turn every 12 seconds.
        let hub = (x: Double(f.mill.x), y: Double(f.mill.y + 2 * s))
        for k in 0..<4 {
            let a = t * 2 * .pi / 12 + Double(k) * .pi / 2
            for r in stride(from: Double(s), through: Double(9 * s), by: 0.5) {
                c.px(Int(hub.x + cos(a) * r), Int(hub.y + sin(a) * r), C(0xD8D0C0))
            }
        }
        c.rect(Int(hub.x) - s / 2, Int(hub.y) - s / 2, max(1, s), max(1, s), C(0x4A3A30))
        // Two butterflies, each on its own wandering loop, wings open and shut.
        for k in 0..<2 {
            let ph = t * (0.25 + 0.07 * Double(k)) + Double(k) * 3
            let x = Int(Double(c.w) * (0.3 + 0.35 * Double(k) + 0.08 * sin(ph * 1.7)))
            let y = f.fence + Int(Double(5 * s) * sin(ph * 2.3)) - 3 * s
            let open = Int(t * 6 + Double(k)) % 2 == 0
            let col = k == 0 ? C(0xF4C430) : C(0xF0F0F8)
            c.rect(x, y, s, s, C(0x2A2A2A))
            if open { c.rect(x - s, y - s, s, s, col); c.rect(x + s, y - s, s, s, col) } else { c.rect(x, y - s, s, s, col) }
        }
    }
}
