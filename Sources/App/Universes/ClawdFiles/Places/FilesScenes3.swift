import Foundation

// Outdoors and underground: the Bellefleur woods, Area 51 and the sewers of Newark.

let filesScenes3: [Location: Place] = [
    .bellefleurWoods: Place(name: "Bellefleur Woods", panel: 0x08100E, still: Scenes.bellefleurWoods,
                            moving: Scenes.bellefleurWoodsLife),
    .area51: Place(name: "Area 51", panel: 0x0E1020, still: Scenes.area51, moving: Scenes.area51Life),
    .newarkSewers: Place(name: "The Sewers of Newark", panel: 0x141810, still: Scenes.newarkSewers,
                         moving: Scenes.newarkSewersLife),
]

// MARK: - Shared bits

extension Scenes {
    /// A pine, its tip at (`cx`, `base` - `h`): tiers of branches widening down to the trunk.
    static func filesPine(_ c: PixelCanvas, cx: Int, base: Int, h: Int, s: Int, _ col: Px, edge: Px? = nil) {
        let trunk = max(s, h / 12)
        c.rect(cx - trunk / 2, base - h / 5, max(1, trunk), h / 5, col)
        // Four tiers, each overhanging the one below it so the outline steps in at every tier.
        let tiers = 4, spacing = Double(h) * 0.8 / Double(tiers)
        for t in 0..<tiers {
            let top = base - h + Int(spacing * Double(t)), height = Int(spacing * 1.45)
            let width = Double(h) * (0.11 + 0.065 * Double(t))
            for y in top..<min(top + height, base - h / 7) {
                let k = Double(y - top) / Double(max(1, height))
                let half = Int(width * k) + s / 2
                c.rect(cx - half, y, half * 2 + 1, 1, col)
                if let edge, half > 2, y == top + height - 1 { c.rect(cx - half, y, half * 2 + 1, 1, edge) }
            }
        }
    }

    /// A cone of light from (`ox`, `oy`) at `angle` (radians, 0 = right, negative = up), `spread` either side, `len` long.
    static func filesBeam(_ c: PixelCanvas, ox: Int, oy: Int, angle: Double, spread: Double, len: Int, _ col: Px, step: Int = 1) {
        let rays = max(8, Int(spread * Double(len) * 1.2))
        for i in 0...rays {
            let a = angle - spread + 2 * spread * Double(i) / Double(rays)
            let dx = cos(a), dy = sin(a)
            for r in stride(from: 0, to: len, by: max(1, step)) {
                let fade = 1 - Double(r) / Double(len)
                c.px(ox + Int(dx * Double(r)), oy + Int(dy * Double(r)), col.alpha(fade))
            }
        }
    }
}

// MARK: - Bellefleur Woods

extension Scenes {
    /// Bellefleur, Oregon: pine woods at night. A low cloudy sky with a few stars, a far ridge of firs, and nearer pines
    /// standing black against it, the forest floor a carpet of needles. On the screen saver the trees stand much taller
    /// under a wider sky.
    static func bellefleurWoods(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        c.gradient(0, g, C(0x05080E), C(0x16222A), bands: 8)
        c.stars(0, g / 2, density: tall ? 260 : 120, seed: 51)
        // A faint haze low over the ridge.
        for k in 0..<4 { c.rect(0, g - (tall ? g / 4 : 14 * s) + k * 3 * s, c.w, 3 * s, C(0x2A3E3A, 0.05 * Double(k + 1))) }
        // The far ridge of firs.
        let far = C(0x0E1A1C)
        var x = -6 * s
        var i = 0
        while x < c.w + 8 * s {
            let h = (tall ? g / 4 : 20 * s) + Int(noise(i + 300) * Double(10 * s))
            filesPine(c, cx: x, base: g - 6 * s, h: h, s: s, far)
            x += 5 * s + Int(noise(i + 340) * Double(4 * s)); i += 1
        }
        c.rect(0, g - 7 * s, c.w, 7 * s, far)
        // Nearer pines, black, in clumps; a gap in the middle where the beams come through.
        let near = C(0x060B0A), edge = C(0x14201C)
        for j in 0..<14 {
            let px = Int(noise(j * 5 + 400) * Double(c.w))
            if abs(px - c.w / 2) < c.w / 10 { continue }
            let h = (tall ? g * 2 / 3 : g - 6 * s) - Int(noise(j * 5 + 401) * Double(tall ? g / 4 : 14 * s))
            filesPine(c, cx: px, base: g + s, h: h, s: s, near, edge: edge)
        }
        // The forest floor: needles and the odd fern.
        c.ground(g, C(0x161C14), edge: C(0x2A3624), speck: C(0x0C100A), seed: 52)
        for j in 0..<10 {
            let fx = Int(noise(j + 460) * Double(c.w))
            c.rect(fx, g - s, 3 * s, s, C(0x1E2C1E)); c.rect(fx + s, g - 2 * s, s, s, C(0x1E2C1E))
        }
    }

    /// What moves in the woods: two flashlight beams sweeping through the trees from either side, and three lights
    /// in the sky, holding a triangle as they drift and pulse.
    static func bellefleurWoodsLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c)
        // The lights: white, green and red, drifting across slowly.
        let span = Double(c.w + 40 * s)
        let lx = Int((t * 6 * Double(s) + Double(c.w) * 0.55).truncatingRemainder(dividingBy: span)) - 20 * s
        let ly = (tall ? g / 4 : g / 4) + Int(sin(t * 0.4) * Double(3 * s))
        for (k, (dx, dy, col)) in [(0, 0, C(0xF4F8FF)), (8, 3, C(0x8AFFB4)), (-8, 3, C(0xFF8A7A))].enumerated() {
            let pulse = 0.55 + 0.45 * sin(t * 3 + Double(k) * 2.1)
            let x = lx + dx * s, y = ly + dy * s
            c.circle(x, y, 4 * s, col.alpha(0.1 * pulse)); c.circle(x, y, 2 * s, col.alpha(0.25 * pulse))
            c.rect(x - s, y - s / 2, 2 * s, s, col.alpha(0.7 + 0.3 * pulse)); c.rect(x - s / 2, y - s, s, 2 * s, col.alpha(0.7 + 0.3 * pulse))
        }
        // The beams, low among the trees, swinging slowly.
        let beam = C(0xFFF4C8, 0.05)
        let len = tall ? c.w / 2 : c.w / 3
        filesBeam(c, ox: -2 * s, oy: g - 8 * s, angle: -0.18 + 0.22 * sin(t * 0.7), spread: 0.09, len: len, beam, step: s)
        filesBeam(c, ox: c.w + 2 * s, oy: g - 10 * s, angle: .pi + 0.16 + 0.2 * sin(t * 0.55 + 1.3), spread: 0.08, len: len,
                  beam, step: s)
    }
}

// MARK: - Area 51

extension Scenes {
    /// Where things stand at Area 51: the hangar's left edge and roofline, the fence's height.
    static func area51Frame(_ c: PixelCanvas, _ g: Int) -> (hangarX: Int, roof: Int, fence: Int) {
        let s = unit(g), tall = isTall(c)
        let roof = tall ? g - g / 3 : max(6 * s, g - 34 * s)
        return (c.w * 58 / 100, roof, 11 * s)
    }

    /// Area 51 at night: desert under a starry sky, low mountains far off, a great hangar with its doors cracked open on
    /// a green glow inside, and a chain-link perimeter fence with a warning sign. The helicopter and the searchlights
    /// come with the moving layer.
    static func area51(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = area51Frame(c, g)
        c.gradient(0, g, C(0x070A18), C(0x2A2838), bands: 8)
        c.stars(0, g * 2 / 3, density: tall ? 150 : 70, seed: 57)
        // The mountains, two ranges.
        c.dunes(base: g - (tall ? g / 6 : 19 * s), amp: Double(tall ? g / 12 : 7 * s), freq: 0.018 / Double(s), phase: 1.2,
                bottom: g, C(0x1A1A28))
        c.dunes(base: g - (tall ? g / 12 : 13 * s), amp: Double(tall ? g / 24 : 3 * s), freq: 0.03 / Double(s), phase: 4.0,
                bottom: g, C(0x2A2430))
        // The hangar: a long low shed with a curved roof, its doors open a crack.
        let hx = f.hangarX, hw = c.w - hx + 4 * s, top = f.roof
        c.rect(hx, top, hw, g - top, C(0x3E434A)); c.rect(hx, top, hw, s, C(0x6A7078))
        for y in stride(from: top - 4 * s, to: top, by: s) {
            let k = Double(top - y) / Double(4 * s)
            c.rect(hx + Int(k * k * Double(6 * s)), y, hw, 1, C(0x4A5058))
        }
        let doorX = hx + 6 * s, doorW = min(hw - 12 * s, 60 * s), doorTop = top + 4 * s
        c.rect(doorX, doorTop, doorW, g - doorTop, C(0x2E3238))
        for x in stride(from: doorX, to: doorX + doorW, by: 6 * s) { c.rect(x, doorTop, s, g - doorTop, C(0x24282C)) }
        let gap = doorX + doorW / 2
        c.rect(gap - 2 * s, doorTop, 4 * s, g - doorTop, C(0x0A1A12))
        c.rect(gap - s, doorTop + 2 * s, 2 * s, g - doorTop - 2 * s, C(0x3AA86A, 0.5))
        // The hangar's number, painted big on its wall beside the doors.
        let numX = doorX + doorW + 8 * s
        if numX + 16 * s < c.w { drawSignText(c, "51", x: numX, y: top + 6 * s, s: 3 * s, col: C(0x5A6068)) }
        // Lights on the hangar's front.
        for x in stride(from: hx + 4 * s, to: c.w, by: 22 * s) { c.rect(x, top + 2 * s, 2 * s, s, C(0xFFD27A)) }
        // The desert floor.
        c.ground(g, C(0x3A3228), edge: C(0x5C4E3C), speck: C(0x2A241C), seed: 58)
        // The fence: posts, the chain link, barbed wire on top.
        let ft = g - f.fence, fenceEnd = hx - 2 * s
        for x in stride(from: 0, to: fenceEnd, by: 2 * s) {
            for y in stride(from: ft + (x / (2 * s)) % 2 * s, to: g, by: 2 * s) { c.rect(x, y, max(1, s / 2), max(1, s / 2), C(0x8A9098, 0.45)) }
        }
        for x in stride(from: 0, to: fenceEnd, by: 16 * s) { c.rect(x, ft - 2 * s, s, f.fence + 2 * s, C(0x6A7078)) }
        c.rect(0, ft - 2 * s, fenceEnd, max(1, s / 2), C(0x8A9098))
        for x in stride(from: 0, to: fenceEnd, by: 3 * s) { c.px(x, ft - 3 * s, C(0x8A9098)); c.px(x + s, ft - s, C(0x8A9098)) }
        // The warning sign on the fence.
        let sx = c.w * 18 / 100, sy = ft - s
        c.rect(sx, sy, 29 * s, 13 * s, C(0xEDEAE0)); c.rect(sx, sy, 29 * s, 3 * s, C(0xB8202A))
        drawSignText(c, "AREA 51", x: sx + 3 * s, y: sy + 5 * s, s: s, col: C(0x1A1A1E))
        c.rect(sx + 3 * s, sy + 11 * s, 23 * s, max(1, s / 2), C(0x8A8676))
    }

    /// AREA 51 in a 3×5 font, for the fence's sign.
    private static func drawSignText(_ c: PixelCanvas, _ text: String, x: Int, y: Int, s: Int, col: Px) {
        let glyphs: [Character: [String]] = [
            "A": [".#.", "#.#", "###", "#.#", "#.#"], "R": ["##.", "#.#", "##.", "#.#", "#.#"],
            "E": ["###", "#..", "##.", "#..", "###"], "5": ["###", "#..", "##.", "..#", "##."],
            "1": [".#", "##", ".#", ".#", ".#"], " ": [".", ".", ".", ".", "."],
        ]
        var cx = x
        for ch in text {
            let rows = glyphs[ch] ?? glyphs[" "]!
            for (dy, row) in rows.enumerated() { for (dx, p) in row.enumerated() where p == "#" { c.rect(cx + dx * s, y + dy * s, s, s, col) } }
            cx += (rows[0].count + 1) * s
        }
    }

    /// What moves at Area 51: two searchlights on the hangar roof sweeping the sky, the green inside the door
    /// breathing, and a black helicopter hovering, rotor spinning, its red light blinking.
    static func area51Life(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = area51Frame(c, g)
        // The searchlights.
        let len = tall ? g * 3 / 4 : g
        for (k, x) in [f.hangarX + 10 * s, c.w - 14 * s].enumerated() {
            let a = -.pi / 2 + 0.55 * sin(t * 0.35 + Double(k) * 2.4)
            filesBeam(c, ox: x, oy: f.roof - 4 * s, angle: a, spread: 0.07, len: len, C(0xEEF4FF, 0.13), step: s)
            c.rect(x - s, f.roof - 5 * s, 3 * s, 2 * s, C(0xF4F8FF))
        }
        // The glow inside the hangar.
        let doorW = min(c.w - f.hangarX - 8 * s, 60 * s), gap = f.hangarX + 6 * s + doorW / 2
        c.rect(gap - 6 * s, f.roof + 4 * s, 12 * s, g - f.roof - 4 * s, C(0x6AFFA8, 0.05 + 0.04 * sin(t * 1.6)))
        // The helicopter, bobbing over the desert.
        let hx = c.w * 30 / 100 + Int(sin(t * 0.25) * Double(c.w / 12)), hy = (tall ? g / 3 : max(8 * s, g / 3)) + Int(sin(t * 1.3) * Double(s))
        let body = C(0x0C0C10), glass = C(0x2A3440)
        c.ellipse(hx, hy, 7 * s, 3 * s, body)
        c.rect(hx + 3 * s, hy - 2 * s, 3 * s, 2 * s, glass)
        c.rect(hx - 16 * s, hy - s, 10 * s, s, body); c.rect(hx - 17 * s, hy - 3 * s, s, 4 * s, body)
        c.rect(hx - 4 * s, hy + 3 * s, 10 * s, max(1, s / 2), body)   // the skids
        c.rect(hx, hy - 4 * s, s, s, body)
        let blade = Int(t * 30) % 2 == 0 ? 11 : 6
        c.rect(hx - blade * s, hy - 5 * s, blade * 2 * s, max(1, s / 2), C(0x3A3A44, 0.8))
        if Int(t * 2) % 2 == 0 { c.rect(hx - 17 * s, hy - 4 * s, s, s, C(0xFF3A2A)) }
        // A cone of light under it, faint, on the desert.
        filesBeam(c, ox: hx, oy: hy + 3 * s, angle: .pi / 2 + 0.25 * sin(t * 0.5), spread: 0.12, len: g - hy - 3 * s,
                  C(0xEEF4FF, 0.05), step: s)
    }
}

// MARK: - The sewers of Newark

extension Scenes {
    /// Where things stand in the sewer: the top of the water channel and the walkway's edge.
    static func sewerFrame(_ c: PixelCanvas, _ g: Int) -> (water: Int, wall: Int, outlet: (x: Int, y: Int, r: Int),
                                                            lamps: [(x: Int, y: Int)]) {
        let s = unit(g), water = g - 9 * s, r = 7 * s
        let lampY = g - 40 * s
        return (water, isTall(c) ? g / 3 : 0, (c.w * 42 / 100, water - r + 2 * s, r),
                lampY > 3 * s ? [(c.w * 20 / 100, lampY), (c.w * 62 / 100, lampY)] : [])
    }

    /// The sewers of Newark: a brick tunnel, its walls sweating, pipes running along it with a valve wheel and rusted
    /// joints, and a channel of black-green water behind the walkway. On the screen saver the vault arches overhead,
    /// with a grating letting in a shaft of light.
    static func newarkSewers(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = sewerFrame(c, g)
        c.rect(0, 0, c.w, g, C(0x1E1A14))
        // The bricks.
        let bw = 8 * s, bh = 3 * s
        for (row, y) in stride(from: g - 9 * s - bh, to: -bh, by: -bh).enumerated() {
            let off = row % 2 == 0 ? 0 : bw / 2
            let k = Double(y) / Double(g)
            let dim = tall ? max(0.12, k * k) : 0.35 + 0.4 * k
            for x in stride(from: -off, to: c.w, by: bw) {
                let n = noise(row * 131 + x / max(1, bw))
                let brick = lerp(C(0x3A2E22), C(0x4E3A28), n)
                c.rect(x + s / 2, y + s / 2, bw - s, bh - s, lerp(C(0x14120E), brick, dim))
            }
        }
        // Damp streaks down the wall.
        for i in 0..<9 {
            let x = Int(noise(i + 600) * Double(c.w)), len = (10 + Int(noise(i + 610) * 20)) * s
            c.rect(x, max(0, g - 9 * s - len), s, len, C(0x2E4A32, 0.35))
        }
        if tall {
            // The vault: courses of brick curving overhead, and a grating at the top.
            let cx = c.w / 2, r = max(c.w / 2, g / 2)
            for y in 0..<f.wall {
                let dy = Double(f.wall - y) / Double(max(1, f.wall))
                let inset = Int(Double(r) * (1 - (1 - dy * dy).squareRoot()))
                c.rect(0, y, inset, 1, C(0x0E0C0A)); c.rect(c.w - inset, y, inset, 1, C(0x0E0C0A))
            }
            c.rect(cx - 12 * s, 0, 24 * s, 4 * s, C(0x2A2620))
            for x in stride(from: cx - 11 * s, to: cx + 12 * s, by: 3 * s) { c.rect(x, 0, s, 4 * s, C(0x0A0A08)) }
        }
        // The pipes: two along the wall, with joints, one with a valve wheel.
        let pipes = [g - 30 * s, g - 22 * s].filter { $0 > 2 * s }
        for (k, py) in pipes.enumerated() {
            let r = (k == 0 ? 3 : 2) * s
            c.rect(0, py, c.w, r, C(0x4A5248)); c.rect(0, py, c.w, max(1, s / 2), C(0x6E7A6A)); c.rect(0, py + r - s, c.w, s, C(0x2E342C))
            for x in stride(from: 20 * s + k * 13 * s, to: c.w, by: 46 * s) { c.rect(x, py - s, 3 * s, r + 2 * s, C(0x5A4430)) }
        }
        if let py = pipes.first {
            let vx = c.w * 72 / 100
            c.circle(vx, py - 4 * s, 3 * s, C(0x8A2A22)); c.circle(vx, py - 4 * s, 2 * s, C(0x1E1A14)); c.rect(vx, py - 4 * s, s, 4 * s, C(0x6A6E66))
        }
        // The caged lamps, and the light they throw on the bricks.
        for l in f.lamps {
            c.circle(l.x, l.y + 6 * s, 22 * s, C(0xC8B060, 0.06)); c.circle(l.x, l.y + 4 * s, 12 * s, C(0xD8C070, 0.08))
            c.rect(l.x - 2 * s, l.y - 3 * s, 4 * s, s, C(0x2A2620))
            c.rect(l.x - s, l.y - 2 * s, 2 * s, 3 * s, C(0xF4E08A)); c.rect(l.x - 2 * s, l.y - 2 * s, s, 3 * s, C(0x2A2620))
            c.rect(l.x + s, l.y - 2 * s, s, 3 * s, C(0x2A2620)); c.rect(l.x - 2 * s, l.y + s, 4 * s, s, C(0x2A2620))
        }
        // The outlet: a round pipe mouth in the wall above the channel.
        let o = f.outlet
        c.circle(o.x, o.y, o.r + s, C(0x5A4C3A)); c.circle(o.x, o.y, o.r, C(0x070605))
        c.circle(o.x, o.y + o.r / 3, o.r * 2 / 3, C(0x0C1410))
        // The channel of water, then the walkway's lip.
        c.rect(0, f.water, c.w, g - f.water, C(0x0C1A14))
        c.rect(0, f.water, c.w, s, C(0x2A4A38))
        c.rect(0, g - 2 * s, c.w, 2 * s, C(0x4A4A42))
        // The walkway.
        c.ground(g, C(0x34342E), edge: C(0x5A5A50), speck: C(0x24241F), seed: 61)
    }

    /// What moves in the sewer: water dripping from the pipe joints into the channel, rings spreading where it lands,
    /// light shimmering on the water, and every so often a pale shape gliding just under the surface, its wake behind it.
    static func newarkSewersLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = sewerFrame(c, g)
        let pipeY = g - 22 * s + 2 * s
        // The drips.
        for i in 0..<4 {
            let x = 20 * s + i * 46 * s + (i % 2) * 13 * s + s
            guard x < c.w else { continue }
            let period = 2.2 + noise(i + 700) * 1.6
            let k = ((t + noise(i + 710) * period) / period).truncatingRemainder(dividingBy: 1)
            let fall = f.water - pipeY
            if k < 0.6 {
                c.rect(x, pipeY + Int(Double(fall) * k / 0.6), s, s, C(0x9AC8B0, 0.8))
            } else {
                let r = Int((k - 0.6) / 0.4 * 6) * s
                c.rect(x - r, f.water + s, r * 2 + s, max(1, s / 2), C(0x6AA88A, 0.5 * (1 - (k - 0.6) / 0.4)))
            }
        }
        // Water pouring from the outlet into the channel, and the froth where it lands.
        let o = f.outlet
        for i in 0..<3 {
            let x = o.x - s + i * s, wob = noise(Int(t * 12) + i * 7) > 0.5 ? s : 0
            c.rect(x, o.y + o.r - 2 * s + wob, s, f.water - (o.y + o.r - 2 * s) - wob + s, C(0x8AB8A0, 0.45))
        }
        for i in 0..<4 { c.rect(o.x - 4 * s + Int(noise(Int(t * 8) + i * 3) * Double(8 * s)), f.water + s, s, s, C(0xC8E0D0, 0.6)) }
        // Light on the water.
        for i in 0..<14 {
            let x = Int(noise(i + 720) * Double(c.w)), y = f.water + 2 * s + Int(noise(i + 730) * Double(5 * s))
            if sin(t * 2 + Double(i)) > 0.3 { c.rect(x, y, 3 * s, max(1, s / 2), C(0x3A6A50, 0.6)) }
        }
        // The shape under the water: a pale hump crossing every 14 s, its wake fanning out behind.
        let cycle = (t / 14).truncatingRemainder(dividingBy: 1)
        if cycle < 0.5 {
            let k = cycle / 0.5
            let x = Int(k * Double(c.w + 40 * s)) - 20 * s, y = f.water + 4 * s
            c.ellipse(x, y, 7 * s, 2 * s, C(0xC8C8B0, 0.35))
            c.ellipse(x + 2 * s, y - s, 3 * s, s, C(0xE0E0C8, 0.3))
            for w in 1...4 {
                let wx = x - w * 6 * s
                c.rect(wx - w * s, f.water + s + (w % 2) * s, 3 * s + w * 2 * s, max(1, s / 2), C(0x6AA88A, 0.35 / Double(w)))
            }
        }
        if tall {
            // The shaft of light from the grating.
            filesBeam(c, ox: c.w / 2, oy: 4 * s, angle: .pi / 2 + 0.06, spread: 0.09, len: g - 4 * s, C(0xD8F0D8, 0.06), step: s)
        }
    }
}
