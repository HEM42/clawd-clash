import Foundation

// Places: Hopper's cabin in the woods, the Creel house and Vecna's mind. The cabin is honey logs and lamplight, cosy
// and cluttered; the Creel house is a 1950s home left to rot, faded green paper and dust sheets, its light failing;
// Vecna's mind is red, a burning sky over dark ground, his grandfather clock standing in it and pieces of the world
// floating loose. The floor and the band above it stay plain and mid-dark so the crew's outlines and names read.

let hawkinsScenes4: [Location: Place] = [
    .hawkinsCabin: Place(name: "Hopper's Cabin", panel: 0x1E140C, still: Scenes.hawkinsCabin, moving: Scenes.hawkinsCabinLife),
    .hawkinsCreel: Place(name: "The Creel House", panel: 0x141810, still: Scenes.hawkinsCreel, moving: Scenes.hawkinsCreelLife),
    .hawkinsMind: Place(name: "Vecna's Mind", panel: 0x1E0808, still: Scenes.hawkinsMind, moving: Scenes.hawkinsMindLife),
]

// MARK: - Shared bits for these scenes

/// A grandfather clock standing on `base` with its middle at `x`: a tall dark wooden case with a hood and finials, a
/// pale face with its hands at the hour, the glass over the pendulum's room (the moving layer swings the pendulum) and
/// a plinth. `h` is its height; the face's middle and the pendulum's pivot come back for the moving layer.
@discardableResult
private func hawkinsP4Clock(_ c: PixelCanvas, _ x: Int, _ base: Int, _ s: Int, h: Int, wood: Px, woodD: Px, woodL: Px)
    -> (face: (x: Int, y: Int, r: Int), pivot: (x: Int, y: Int), drop: Int) {
    let w = 14 * s, top = base - h
    // The plinth, the trunk and the hood.
    c.rect(x - w / 2 - s, base - 6 * s, w + 2 * s, 6 * s, woodD); c.rect(x - w / 2 - s, base - 6 * s, w + 2 * s, s, woodL)
    c.rect(x - w / 2 + s, top + 18 * s, w - 2 * s, h - 24 * s, wood)
    c.rect(x - w / 2 + s, top + 18 * s, s, h - 24 * s, woodL); c.rect(x + w / 2 - 2 * s, top + 18 * s, s, h - 24 * s, woodD)
    c.rect(x - w / 2, top + 2 * s, w, 17 * s, wood); c.rect(x - w / 2, top + 2 * s, w, s, woodL); c.rect(x + w / 2 - s, top + 2 * s, s, 17 * s, woodD)
    c.rect(x - w / 2 - s, top + 18 * s, w + 2 * s, s, woodD)
    for k in 0..<3 { c.rect(x - w / 2 + k * (w / 2) - (k == 2 ? s : 0), top - s, 2 * s, 3 * s, woodL) }   // the finials
    c.rect(x - w / 2 + 2 * s, top, w - 4 * s, 2 * s, woodD)
    // The face: pale with a brass ring, the hours as dots, the hands.
    let fy = top + 10 * s, r = 5 * s
    c.circle(x, fy, r + s, C(0xB89040)); c.circle(x, fy, r, C(0xE8DCC0))
    for k in 0..<12 { let a = Double(k) * .pi / 6; c.px(x + Int(cos(a) * Double(r - s)), fy + Int(sin(a) * Double(r - s)), C(0x2A2A2A)) }
    c.rect(x, fy - 4 * s, s, 4 * s, C(0x1A1A1A)); c.rect(x - 3 * s, fy, 3 * s, s, C(0x1A1A1A))
    // The pendulum's room: dark glass with a lit edge.
    let gy = top + 21 * s, gh = h - 30 * s
    c.rect(x - 4 * s, gy, 8 * s, gh, C(0x14100E)); c.rect(x - 4 * s, gy, 8 * s, s, C(0x3A322A)); c.rect(x - 4 * s, gy, s, gh, C(0x2A221C))
    return ((x, fy, r), (x, gy + s), gh - 4 * s)
}

/// The pendulum in a clock's glass: a brass rod from `pivot`, `drop` long, and its bob, swung `angle` radians.
private func hawkinsP4Pendulum(_ c: PixelCanvas, _ pivot: (x: Int, y: Int), _ drop: Int, _ angle: Double, _ s: Int, bob: Px) {
    let n = max(1, drop / s)
    for k in 0..<n {
        let d = Double(k * s)
        c.rect(pivot.x + Int(sin(angle) * d), pivot.y + Int(cos(angle) * d), s, s, C(0xA88430))
    }
    let bx = pivot.x + Int(sin(angle) * Double(drop)), by = pivot.y + Int(cos(angle) * Double(drop))
    c.circle(bx, by, 2 * s, bob); c.px(bx - s, by - s, C(0xF8E8A0))
}

/// A floating rock in Vecna's mind, `r` across from its middle: a lumpy flat top, the underside tapering away jagged
/// beneath it, lit dull red from below where the burning horizon catches it, a root or two trailing; `seed` shapes it.
private func hawkinsP4Rock(_ c: PixelCanvas, _ x: Int, _ y: Int, _ r: Int, _ s: Int, seed: Int, roots: Bool = true) {
    let w = r * 3 / 2
    for dx in stride(from: -w, through: w, by: s) {
        let u = Double(dx) / Double(w)
        let top = y - Int((noise(seed * 37 + dx / s) * 0.4 + 0.3) * Double(r) * 0.4 * (1 - u * u)) - s
        let depth = Int(Double(r) * 1.3 * (1 - u * u) * (0.75 + noise(seed * 53 + dx / (2 * s)) * 0.5)) + s
        c.rect(x + dx, top, s, y + depth - top, C(0x2A1414))
        c.rect(x + dx, top, s, s, C(0x4E2A26))
        c.rect(x + dx, y + depth - s, s, s, C(0x8A3024))
        if dx > w / 3 { c.rect(x + dx, top + s, s, y + depth - top - 2 * s, C(0x221010)) }   // the far side in shade
    }
    guard roots else { return }
    for k in 0..<max(1, r / (3 * s)) {
        let rx = x - r / 2 + k * 3 * s + Int(noise(seed * 11 + k) * Double(2 * s))
        let d0 = Int(Double(r) * 1.3 * (1 - pow(Double(rx - x) / Double(w), 2))) - s
        for j in 0..<((3 + k % 3 * 2) * s) { c.rect(rx + (j / (3 * s)) * s * (k % 2 == 0 ? 1 : -1), y + d0 + j, s, s, C(0x1A0C0C)) }
    }
}

// MARK: - Hopper's cabin

extension Scenes {
    /// Where things stand in the cabin: the front door, the window, the kitchen counter, Eleven's door, the TV and its
    /// screen, the recliner and the wood stove (its fire's window).
    static func hawkinsCabinFrame(_ c: PixelCanvas, _ g: Int)
        -> (door: Int, window: Int, kitchen: Int, elDoor: Int, tv: (x: Int, y: Int, w: Int, h: Int), chair: Int, stove: Int) {
        let s = unit(g), tvx = c.w * 66 / 100
        return (c.w * 7 / 100, c.w * 19 / 100, c.w * 34 / 100, c.w * 51 / 100, (x: tvx - 9 * s, y: g - 25 * s, w: 15 * s, h: 11 * s),
                c.w * 78 / 100, c.w * 92 / 100)
    }

    /// Hopper's cabin in the woods, winter 1984: walls of honey-coloured logs with pale chinking between them; the
    /// front door with its three bolts and Hopper's tripwire strung across it at ankle height, tin cans hanging on the
    /// line; the window with its blind half down on the snow and the pines; the kitchen corner with its cupboards, a
    /// toaster and a box of Eggos on the counter, the old cream fridge; Eleven's door, open just a crack; the TV on a
    /// stand with rabbit ears, Hopper's sagging recliner and the side table with his mug; and the black wood stove with
    /// its pipe and the logs stacked beside it, antlers on the wall above. A dark plank floor along the front. On the
    /// screen saver the logs go up into the gable: the ridge beam and rafters, a lantern hanging, snowshoes and a
    /// fishing rod on the wall, and the gable window full of tall pines and falling snow.
    static func hawkinsCabin(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsCabinFrame(c, g), tall = isTall(c)
        // The logs: each a rounded band lit along its top, shaded underneath, the chinking pale between; a knot here
        // and there and the odd split.
        let log = C(0x7A5230), logL = C(0x96693E), logD = C(0x52361E), chink = C(0xA89878)
        c.rect(0, 0, c.w, g, log)
        var row = 0
        for y in stride(from: g - 7 * s, to: -7 * s, by: -7 * s) {
            c.rect(0, y, c.w, s, chink); c.rect(0, y + s, c.w, s, logL); c.rect(0, y + 5 * s, c.w, 2 * s, logD)
            for k in 0..<(c.w / (40 * s) + 1) {
                let kx = k * 40 * s + Int(noise(row * 13 + k) * Double(30 * s))
                if noise(row * 7 + k * 3) > 0.5 { c.ellipse(kx, y + 3 * s, 2 * s, s, logD); c.px(kx, y + 3 * s, C(0x3E2A16)) }
                else { c.rect(kx, y + 3 * s, 6 * s, s, C(0x7A5230)) }
            }
            row += 1
        }
        // Corner posts at the edges.
        for px in [0, c.w - 5 * s] { c.rect(px, 0, 5 * s, g, C(0x6E4A2A)); c.rect(px + s, 0, s, g, C(0x9A6E42)) }

        if tall {
            // The gable: the ridge beam high in the middle and the roof's underside sloping down either side of the
            // log wall, boarded along the slope with purlins across it; a tie beam over the room with the lantern
            // hanging from it.
            let ridge = 6 * s, eave = g - 92 * s
            if eave > ridge + 20 * s {
                let half = c.w / 2
                for x in 0..<c.w {
                    let d = abs(x - half), y = ridge + d * (eave - ridge) / half
                    for yy in stride(from: 0, to: y, by: 1) {
                        // Boards along the slope, their seams parallel to its edge, and every so often a purlin.
                        let k = (y - yy) / s
                        c.px(x, yy, k % 24 < 4 && k > 6 ? (k % 24 == 0 ? C(0x7A5230) : C(0x5E3E22)) : k % 6 == 0 ? C(0x2A1C10) : k % 6 < 3 ? C(0x4A321E) : C(0x422C1A))
                    }
                    c.rect(x, y, 1, 4 * s, C(0x6E4A2A)); c.rect(x, y, 1, s, C(0x9A6E42))
                }
                c.rect(half - 4 * s, 0, 8 * s, ridge + 4 * s, C(0x5E3E22)); c.rect(half - 4 * s, 0, s, ridge + 4 * s, C(0x8A5E36))
                let tb = eave + 6 * s
                c.rect(0, tb, c.w, 5 * s, C(0x6E4A2A)); c.rect(0, tb, c.w, s, C(0x9A6E42)); c.rect(0, tb + 4 * s, c.w, s, C(0x3E2A16))
                let lnx = c.w * 34 / 100
                for k in 0..<5 { c.rect(lnx, tb + 5 * s + k * 2 * s, s, s, C(0x5A5A60)) }
                c.rect(lnx - 3 * s, tb + 15 * s, 7 * s, 9 * s, C(0x3A3A40)); c.rect(lnx - 2 * s, tb + 16 * s, 5 * s, 7 * s, C(0xE8C070))
                c.rect(lnx - 3 * s, tb + 14 * s, 7 * s, s, C(0x5A5A60))
            }
            // Pegs by the door with Hopper's hat and his jacket on them, and a shelf with books and a radio.
            let pgx = c.w * 6 / 100, pgy = g - 70 * s
            c.rect(pgx - 2 * s, pgy, 30 * s, 3 * s, C(0x5E3E22)); c.rect(pgx - 2 * s, pgy, 30 * s, s, C(0x8A5E36))
            c.rect(pgx + 2 * s, pgy + 3 * s, 12 * s, 16 * s, C(0x6A6A4A)); c.rect(pgx + 2 * s, pgy + 3 * s, s, 16 * s, C(0x7E7E5A))
            c.rect(pgx + 7 * s, pgy + 3 * s, 2 * s, 8 * s, C(0x4A4A32)); c.rect(pgx + 4 * s, pgy + 8 * s, 2 * s, 2 * s, C(0xC8A848))
            c.ellipse(pgx + 21 * s, pgy - 2 * s, 7 * s, 2 * s, C(0xA88A58)); c.rect(pgx + 17 * s, pgy - 8 * s, 9 * s, 6 * s, C(0xA88A58))
            c.rect(pgx + 20 * s, pgy - 9 * s, 3 * s, 2 * s, C(0x8A6E40)); c.rect(pgx + 17 * s, pgy - 4 * s, 9 * s, s, C(0x5A3E22))
            let bsx = c.w * 72 / 100, bsy = g - 76 * s
            c.rect(bsx - 18 * s, bsy, 36 * s, 2 * s, C(0x6E4A2A)); c.rect(bsx - 18 * s, bsy, 36 * s, s, C(0x9A6E42))
            for (k, w) in [3, 2, 3, 2, 3, 2].enumerated() { c.rect(bsx - 16 * s + k * 3 * s, bsy - (6 + k % 3) * s, w * s, (6 + k % 3) * s, [C(0x8A2A22), C(0x2A4A6A), C(0x5A6A3A), C(0xC8A848), C(0x6A3A5A), C(0x3A3A3A)][k]) }
            c.rect(bsx + 4 * s, bsy - 7 * s, 12 * s, 7 * s, C(0x3A3A40)); c.rect(bsx + 5 * s, bsy - 6 * s, 5 * s, 4 * s, C(0x8A8A70))
            c.circle(bsx + 13 * s, bsy - 4 * s, s, C(0xB8B8B0)); c.rect(bsx + 14 * s, bsy - 13 * s, s, 6 * s, C(0xB8B8C0))
            // The gable window: pines dark against a snowy night, snow on the sill.
            let gw = 62 * s, gh = 58 * s, gx = c.w / 2 - gw / 2, gy = max(ridge + 30 * s, g - 168 * s)
            c.rect(gx - 3 * s, gy - 3 * s, gw + 6 * s, gh + 6 * s, C(0x5E3E22))
            c.rect(gx, gy, gw, gh, C(0x1A2236)); c.rect(gx, gy, gw, gh / 3, C(0x222C44))
            for k in 0..<7 {
                let tx = gx + 4 * s + k * 9 * s, th = (28 + Int(noise(k + 70) * 20)) * s
                for r in 0..<(th / s) {
                    let half = (r / 2 + 1) * s / 2 + (r % 6 < 3 ? s : 0)
                    c.rect(tx - half, gy + gh - th + r * s, half * 2 + s, s, k % 2 == 0 ? C(0x14261E) : C(0x18301E))
                    if r % 6 == 0 { c.rect(tx - half, gy + gh - th + r * s, half, s, C(0xD8E0E8)) }
                }
            }
            for k in 0..<30 { c.rect(gx + Int(noise(k + 80) * Double(gw)), gy + Int(noise(k + 90) * Double(gh)), s, s, C(0xE8F0F8)) }
            c.rect(gx + gw / 2 - s, gy, 2 * s, gh, C(0x5E3E22)); c.rect(gx, gy + gh / 2, gw, 2 * s, C(0x5E3E22))
            c.rect(gx - 4 * s, gy + gh + 2 * s, gw + 8 * s, 3 * s, C(0x6E4A2A)); c.rect(gx - 3 * s, gy + gh + s, gw + 6 * s, s, C(0xE8F0F8))
            // Snowshoes crossed on the left wall, a fishing rod and creel on the right.
            let sx0 = c.w * 22 / 100, sy0 = g - 116 * s
            for dx in [-3, 3] {
                c.ellipse(sx0 + dx * s, sy0, 5 * s, 12 * s, C(0x8A6A3A)); c.ellipse(sx0 + dx * s, sy0, 4 * s, 11 * s, C(0x6E4A2A))
                for y in stride(from: sy0 - 9 * s, to: sy0 + 10 * s, by: 2 * s) { c.rect(sx0 + dx * s - 3 * s, y, 6 * s, 1, C(0xC8B890)) }
                c.rect(sx0 + dx * s - s, sy0 + 11 * s, 2 * s, 5 * s, C(0x8A6A3A))
            }
            let rx0 = c.w * 82 / 100, ry0 = g - 116 * s
            for k in 0..<(46 * s) { c.rect(rx0 - 20 * s + k, ry0 + k / 6, s, s, C(0x3A2A1A)) }
            c.circle(rx0 - 12 * s, ry0 + 2 * s, 2 * s, C(0x9A9AA0))
            c.rect(rx0 + 6 * s, ry0 + 12 * s, 14 * s, 10 * s, C(0xA8884A)); c.rect(rx0 + 6 * s, ry0 + 12 * s, 14 * s, 2 * s, C(0x7A5A2A))
            for k in 0..<3 { c.rect(rx0 + (7 + k * 4) * s, ry0 + 15 * s, s, 6 * s, C(0x8A6A3A)) }
        }

        // The front door: heavy planks, three bolts, a peephole; and the tripwire across it at ankle height with
        // tin cans hanging on it.
        let dx = f.door, dw = 18 * s, dh = 34 * s
        c.rect(dx - 2 * s, g - dh - 2 * s, dw + 4 * s, dh + 2 * s, C(0x5E3E22)); c.rect(dx - 2 * s, g - dh - 2 * s, dw + 4 * s, s, C(0x8A5E36))
        c.rect(dx, g - dh, dw, dh, C(0x6E4A2A))
        for x in stride(from: dx, to: dx + dw, by: 4 * s) { c.rect(x, g - dh, s, dh, C(0x553820)); c.rect(x + s, g - dh, s, dh, C(0x7E5632)) }
        for y in [g - dh + 5 * s, g - 9 * s] { c.rect(dx, y, dw, 3 * s, C(0x5E3E22)); c.rect(dx, y, dw, s, C(0x86603A)) }
        for k in 0..<3 { let by = g - dh + (9 + k * 5) * s; c.rect(dx + 12 * s, by, 5 * s, 2 * s, C(0x8A8A92)); c.rect(dx + 12 * s, by, 5 * s, s, C(0xC0C0C8)); c.rect(dx + 15 * s, by + 2 * s, 2 * s, s, C(0x5A5A62)) }
        c.rect(dx + 13 * s, g - 19 * s, 2 * s, 2 * s, C(0xC8A040)); c.rect(dx + 8 * s, g - dh + 3 * s, s, s, C(0x1A1A1A))
        let wireY = g - 5 * s
        c.rect(dx - 4 * s, wireY, dw + 8 * s, 1, C(0xD8D8D0))
        c.rect(dx - 4 * s, wireY - s, s, 3 * s, C(0x8A8A92)); c.rect(dx + dw + 3 * s, wireY - s, s, 3 * s, C(0x8A8A92))
        for (k, cx) in [dx + 3 * s, dx + 9 * s, dx + 14 * s].enumerated() {
            c.rect(cx, wireY + s, s, s, C(0xD8D8D0))
            c.rect(cx - s, wireY + 2 * s, 3 * s, 3 * s, k == 1 ? C(0xC84A3A) : C(0xB8BCC4)); c.rect(cx - s, wireY + 2 * s, s, 3 * s, C(0xE0E4EA))
        }

        // The window: a frame, snow and pines outside, a blind half down, snow on the outside sill.
        let wx = f.window, wy = g - 44 * s, ww = 26 * s, wh = 22 * s
        c.rect(wx - ww / 2 - 2 * s, wy - 2 * s, ww + 4 * s, wh + 4 * s, C(0x5E3E22))
        c.rect(wx - ww / 2, wy, ww, wh, C(0x1C2638))
        for k in 0..<4 {
            let tx = wx - ww / 2 + 3 * s + k * 7 * s, th = (12 + Int(noise(k + 33) * 8)) * s
            for r in 0..<(th / s) { let half = (r / 2) * s / 2 + s; c.rect(tx - half, wy + wh - th + r * s, half * 2, s, C(0x16281E)) }
        }
        c.rect(wx - ww / 2, wy + wh - 3 * s, ww, 3 * s, C(0xD8E0E8))
        c.rect(wx - ww / 2, wy, ww, 9 * s, C(0xD8C8A0))
        for y in stride(from: wy + s, to: wy + 9 * s, by: 2 * s) { c.rect(wx - ww / 2, y, ww, s, C(0xC0B088)) }
        c.rect(wx - s, wy + 9 * s, 2 * s, 3 * s, C(0xE8D8B0))
        c.rect(wx - s / 2, wy + 9 * s, max(1, s), wh - 9 * s, C(0x5E3E22))
        c.rect(wx - ww / 2 - 4 * s, wy + wh + 2 * s, ww + 8 * s, 2 * s, C(0x7A5230)); c.rect(wx - ww / 2 - 4 * s, wy + wh + 2 * s, ww + 8 * s, s, C(0x9A6E42))

        // The kitchen: wall cupboards over a counter with a sink, the toaster and a box of Eggos, a coffee pot; the
        // cupboards under it; and the cream fridge at the end.
        let kx = f.kitchen, kw = 46 * s
        c.rect(kx - kw / 2, g - 16 * s, kw, 16 * s, C(0x6A4A2C))
        for k in 0..<3 {
            let cx = kx - kw / 2 + k * kw / 3
            c.rect(cx + s, g - 14 * s, kw / 3 - 2 * s, 12 * s, C(0x7A5634)); c.rect(cx + s, g - 14 * s, kw / 3 - 2 * s, s, C(0x9A7044))
            c.rect(cx + kw / 6 - s, g - 11 * s, 2 * s, s, C(0xC8B888))
        }
        c.rect(kx - kw / 2 - s, g - 18 * s, kw + 2 * s, 2 * s, C(0xC8B890)); c.rect(kx - kw / 2 - s, g - 18 * s, kw + 2 * s, s, C(0xE0D0A8))
        c.rect(kx - 4 * s, g - 18 * s, 10 * s, s, C(0x8A8E94)); c.rect(kx + s, g - 23 * s, s, 5 * s, C(0xA8ACB4)); c.rect(kx + s, g - 23 * s, 3 * s, s, C(0xA8ACB4))
        // The toaster, chrome, and the Eggo box beside it: yellow, the red badge, a waffle on the front.
        let tx = kx - kw / 2 + 4 * s
        c.rect(tx, g - 23 * s, 8 * s, 5 * s, C(0xB8BCC4)); c.rect(tx, g - 23 * s, 8 * s, s, C(0xE0E4EA)); c.rect(tx + 7 * s, g - 23 * s, s, 5 * s, C(0x7A7E86))
        c.rect(tx + 2 * s, g - 24 * s, 4 * s, s, C(0x2A2A2A)); c.rect(tx + 8 * s, g - 21 * s, s, 2 * s, C(0x2A2A2A))
        let ex = kx + 9 * s
        c.rect(ex, g - 28 * s, 9 * s, 10 * s, C(0xF0C830)); c.rect(ex, g - 28 * s, 9 * s, s, C(0xF8E070)); c.rect(ex + 8 * s, g - 28 * s, s, 10 * s, C(0xC09A20))
        c.ellipse(ex + 4 * s, g - 25 * s, 3 * s, s, C(0xD02A2A))
        c.rect(ex + 2 * s, g - 22 * s, 5 * s, 3 * s, C(0xC88A3A)); c.rect(ex + 3 * s, g - 22 * s, s, 3 * s, C(0xA86A2A)); c.rect(ex + 5 * s, g - 22 * s, s, 3 * s, C(0xA86A2A))
        c.rect(ex + 2 * s, g - 21 * s, 5 * s, s, C(0xA86A2A))
        let cp = kx + 20 * s
        c.rect(cp - 2 * s, g - 25 * s, 5 * s, 7 * s, C(0x2A2A2E)); c.rect(cp - s, g - 23 * s, 3 * s, 4 * s, C(0x5A3A22))
        c.rect(cp - 2 * s, g - 26 * s, 5 * s, s, C(0x4A4A50))
        // The wall cupboards.
        c.rect(kx - kw / 2, g - 46 * s, kw, 14 * s, C(0x6A4A2C)); c.rect(kx - kw / 2, g - 46 * s, kw, s, C(0x8A603A)); c.rect(kx - kw / 2, g - 33 * s, kw, s, C(0x3E2A16))
        for k in 0..<3 {
            let cx = kx - kw / 2 + k * kw / 3
            c.rect(cx + 2 * s, g - 44 * s, kw / 3 - 4 * s, 10 * s, C(0x7A5634)); c.rect(cx + kw / 6 - s, g - 37 * s, 2 * s, s, C(0xC8B888))
        }
        // The fridge.
        let fx = kx + kw / 2 + 9 * s
        c.rect(fx - 8 * s, g - 34 * s, 16 * s, 34 * s, C(0xE0D8C0)); c.rect(fx - 8 * s, g - 34 * s, 16 * s, s, C(0xF0EAD8))
        c.rect(fx + 7 * s, g - 34 * s, s, 34 * s, C(0xA8A088)); c.rect(fx - 8 * s, g - 22 * s, 16 * s, s, C(0xA8A088))
        c.rect(fx - 6 * s, g - 31 * s, s, 6 * s, C(0x8A8E94)); c.rect(fx - 6 * s, g - 19 * s, s, 8 * s, C(0x8A8E94))
        c.rect(fx - 2 * s, g - 30 * s, 5 * s, 6 * s, C(0xF8F8F0)); for k in 0..<3 { c.rect(fx - s, g - (29 - k * 2) * s, 3 * s, s, C(0x3A3A6A)) }   // Hopper's list of rules
        c.rect(fx + 3 * s, g - 17 * s, 3 * s, 3 * s, C(0xC84A3A))

        // Eleven's door, open a crack: the dark of her room showing down its edge.
        let ed = f.elDoor, edh = 34 * s
        c.rect(ed - 10 * s, g - edh - 2 * s, 20 * s, edh + 2 * s, C(0x5E3E22)); c.rect(ed - 10 * s, g - edh - 2 * s, 20 * s, s, C(0x8A5E36))
        c.rect(ed - 8 * s, g - edh, 16 * s, edh, C(0x8A6A44))
        for y in [g - edh + 3 * s, g - edh + 18 * s] { c.rect(ed - 6 * s, y, 12 * s, 12 * s, C(0x7A5A38)); c.rect(ed - 6 * s, y, 12 * s, s, C(0x6A4A2C)) }
        c.rect(ed + 5 * s, g - edh, 3 * s, edh, C(0x120C08)); c.rect(ed + 4 * s, g - 17 * s, s, 2 * s, C(0xC8A040))
        c.rect(ed - 4 * s, g - edh + 6 * s, 8 * s, 5 * s, C(0xE8E0D0))
        for k in 0..<3 { c.rect(ed - 3 * s + k * 2 * s, g - edh + 8 * s, s, 2 * s, [C(0x3A6AC0), C(0xC84A6A), C(0x3A9A4A)][k]) }   // her drawing taped up

        // The TV on its stand: a wood-grain set with rabbit ears, the screen (the moving layer fills it with static).
        let tv = f.tv
        c.rect(tv.x - 3 * s, tv.y - 3 * s, tv.w + 13 * s, tv.h + 6 * s, C(0x5A3E26)); c.rect(tv.x - 3 * s, tv.y - 3 * s, tv.w + 13 * s, s, C(0x7A5634))
        c.rect(tv.x - 2 * s, tv.y - 2 * s, tv.w + 4 * s, tv.h + 4 * s, C(0x2A2A2E)); c.rect(tv.x, tv.y, tv.w, tv.h, C(0x4A5A5A))
        for k in 0..<2 { c.circle(tv.x + tv.w + 5 * s, tv.y + (2 + k * 5) * s, s, C(0xC8C0A8)) }
        for k in 0..<8 { c.px(tv.x + 4 * s - k * s, tv.y - 4 * s - k * s, C(0xB8B8C0)); c.px(tv.x + 10 * s + k * s * 2 / 3, tv.y - 4 * s - k * s, C(0xB8B8C0)) }
        c.rect(tv.x + 4 * s, tv.y - 4 * s, 7 * s, s, C(0x2A2A2E))
        let st = tv.y + tv.h + 3 * s
        c.rect(tv.x - 4 * s, st, tv.w + 15 * s, 2 * s, C(0x6A4A2C)); c.rect(tv.x - 4 * s, st, tv.w + 15 * s, s, C(0x8A603A))
        c.rect(tv.x - 3 * s, st + 2 * s, s, g - st - 2 * s, C(0x4E3420)); c.rect(tv.x + tv.w + 9 * s, st + 2 * s, s, g - st - 2 * s, C(0x4E3420))
        c.rect(tv.x - 2 * s, st + 5 * s, tv.w + 10 * s, 4 * s, C(0x1E1E22)); c.rect(tv.x, st + 6 * s, 6 * s, s, C(0x3A3A40))   // the VCR

        // Hopper's recliner: tan vinyl, a tall rounded back with a dip where he sits, padded arms, the footrest
        // down, a blanket thrown over its arm.
        let ax = f.chair, vin = C(0x9A6A3E), vinD = C(0x6E4626), vinL = C(0xB88A56)
        c.rect(ax - 9 * s, g - 28 * s, 18 * s, 18 * s, vin); c.rect(ax - 8 * s, g - 29 * s, 16 * s, s, vin)
        c.rect(ax - 7 * s, g - 29 * s, 14 * s, s, vinL); c.rect(ax - 9 * s, g - 27 * s, s, 16 * s, vinL); c.rect(ax + 8 * s, g - 27 * s, s, 17 * s, vinD)
        c.rect(ax - 6 * s, g - 24 * s, 12 * s, s, vinD); c.rect(ax - 6 * s, g - 18 * s, 12 * s, s, vinD)
        c.rect(ax - 7 * s, g - 12 * s, 14 * s, 4 * s, vin); c.rect(ax - 7 * s, g - 12 * s, 14 * s, s, vinL)
        for (arm, lit) in [(ax - 12 * s, true), (ax + 7 * s, false)] {
            c.rect(arm, g - 15 * s, 5 * s, 12 * s, vin); c.rect(arm, g - 15 * s, 5 * s, s, vinL)
            c.rect(lit ? arm : arm + 4 * s, g - 14 * s, s, 11 * s, lit ? vinL : vinD)
        }
        c.rect(ax - 12 * s, g - 3 * s, 24 * s, s, C(0x3A2414))
        c.rect(ax - 7 * s, g - 8 * s, 14 * s, 5 * s, vinD)
        for k in 0..<4 { c.rect(ax + 7 * s, g - (15 - k * 3) * s, 5 * s, 2 * s, k % 2 == 0 ? C(0x2E4A6A) : C(0xC8B888)) }
        // The side table: a mug, a lamp with a plaid shade.
        let sx = ax - 18 * s
        c.rect(sx - 5 * s, g - 12 * s, 10 * s, 2 * s, C(0x7A5232)); c.rect(sx - 4 * s, g - 10 * s, s, 10 * s, C(0x5A3A22)); c.rect(sx + 3 * s, g - 10 * s, s, 10 * s, C(0x5A3A22))
        c.rect(sx + s, g - 15 * s, 3 * s, 3 * s, C(0xE8E0D0)); c.rect(sx + 4 * s, g - 14 * s, s, s, C(0xE8E0D0))
        c.rect(sx - 3 * s, g - 16 * s, 2 * s, 4 * s, C(0x6A6A70))
        c.rect(sx - 5 * s, g - 21 * s, 6 * s, 5 * s, C(0x9A3A2A)); for k in 0..<3 { c.rect(sx - 5 * s + k * 2 * s, g - 21 * s, s, 5 * s, C(0x5A2A1E)) }

        // The wood stove: black iron on short legs, its fire's little window (lit by the moving layer), the pipe up
        // the wall; logs stacked beside it; antlers on the wall above.
        let ws = f.stove
        c.rect(ws - 9 * s, g - 20 * s, 18 * s, 16 * s, C(0x2A2A2E)); c.rect(ws - 9 * s, g - 20 * s, 18 * s, s, C(0x4A4A52)); c.rect(ws + 8 * s, g - 20 * s, s, 16 * s, C(0x18181C))
        c.rect(ws - 10 * s, g - 21 * s, 20 * s, 2 * s, C(0x3A3A40))
        c.rect(ws - 5 * s, g - 16 * s, 10 * s, 7 * s, C(0x3A1A10)); c.rect(ws - 5 * s, g - 16 * s, 10 * s, s, C(0x5A5A62))
        c.rect(ws - 8 * s, g - 4 * s, 2 * s, 4 * s, C(0x1E1E22)); c.rect(ws + 6 * s, g - 4 * s, 2 * s, 4 * s, C(0x1E1E22))
        c.rect(ws - 2 * s, 0, 4 * s, g - 21 * s, C(0x2E2E34)); c.rect(ws - 2 * s, 0, s, g - 21 * s, C(0x4A4A52))
        for y in stride(from: g - 28 * s, to: 0, by: -24 * s) { c.rect(ws - 3 * s, y, 6 * s, s, C(0x3A3A40)) }
        for r in 0..<3 { for k in 0..<(3 - r % 2) {
            let lx = ws - 22 * s + k * 5 * s + (r % 2) * 2 * s, ly = g - 4 * s - r * 4 * s
            c.circle(lx, ly, 2 * s, C(0x8A6038)); c.px(lx, ly, C(0xC8A070)); c.px(lx - s, ly - s, C(0xA87A4A))
        } }
        let ay = g - 50 * s
        c.rect(ws - 3 * s, ay, 6 * s, 5 * s, C(0x5E3E22))
        for side in [-1, 1] {
            for k in 0..<10 { c.rect(ws + side * (2 + k) * s, ay - k * s / 2, s, s, C(0xD8C8A8)) }
            for (o, l) in [(3, 4), (6, 5), (9, 3)] { for k in 0..<l { c.rect(ws + side * (2 + o) * s, ay - o * s / 2 - k * s, s, s, C(0xD8C8A8)) } }
        }

        // The floor: dark planks, plain, a lit edge where it meets the wall.
        c.ground(g, C(0x4A3220), edge: C(0x6A4A30), speck: C(0x3E2A1A), seed: 61)
        for x in stride(from: 13 * s, to: c.w, by: 26 * s) { c.rect(x, g + 2 * s, s, s, C(0x3A2616)) }
    }

    /// The cabin's life: the TV showing nothing but static, the fire flickering in the stove's window, a warm glow off
    /// it; on the screen saver the lantern's flame.
    static func hawkinsCabinLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hawkinsCabinFrame(c, g), tv = f.tv
        let frame = Int(t * 18)
        for y in stride(from: tv.y, to: tv.y + tv.h, by: s) {
            for x in stride(from: tv.x, to: tv.x + tv.w, by: s) {
                let v = noise(frame * 4099 + y * 131 + x * 7)
                c.rect(x, y, s, s, v > 0.66 ? C(0xE0E8E8) : v > 0.33 ? C(0x8A9696) : C(0x2E3838))
            }
        }
        c.rect(tv.x, tv.y + (frame * 3 % max(1, tv.h / s)) * s, tv.w, s, C(0xFFFFFF, 0.3))
        for (r, a) in [(10, 0.04), (6, 0.05)] { c.circle(tv.x + tv.w / 2, tv.y + tv.h / 2, r * s, C(0xC8E0F0, a)) }
        // The fire.
        let ws = f.stove, flick = noise(Int(t * 9) + 11)
        c.rect(ws - 4 * s, g - 15 * s, 8 * s, 6 * s, C(0xC84A1A))
        for k in 0..<4 {
            let h = (2 + Int(noise(Int(t * 9) * 5 + k) * 4)) * s
            c.rect(ws - 4 * s + k * 2 * s, g - 9 * s - h, 2 * s, h, k % 2 == 0 ? C(0xF0A030) : C(0xF8D060))
        }
        for (r, a) in [(16, 0.04 + flick * 0.02), (10, 0.05)] { c.circle(ws, g - 12 * s, r * s, C(0xFF9040, a)) }
        if isTall(c) {
            let eave = g - 92 * s, lnx = c.w * 34 / 100, tb = eave + 6 * s
            if eave > 26 * s {
                for (r, a) in [(10, 0.05), (6, 0.08)] { c.circle(lnx, tb + 20 * s, r * s, C(0xFFD070, a)) }
                c.rect(lnx - s, tb + 18 * s - Int(flick * 2) * s / 2, 2 * s, 3 * s, C(0xFFF0B0))
            }
        }
    }
}

// MARK: - The Creel house

extension Scenes {
    /// Where things stand in the Creel house: the top of the wainscot, the boarded window, the grandfather clock, the
    /// fireplace, the sheeted chair and sofa, the stairs' foot (on the right), the wall lamps and the chandelier.
    static func hawkinsCreelFrame(_ c: PixelCanvas, _ g: Int)
        -> (dado: Int, window: Int, clock: Int, fire: Int, chair: Int, sofa: Int, stairs: Int, sconces: [Int], chandelier: (x: Int, y: Int)) {
        let s = unit(g)
        return (g - 18 * s, c.w * 21 / 100, c.w * 33 / 100, c.w * 48 / 100, c.w * 7 / 100, c.w * 63 / 100, c.w * 77 / 100,
                [c.w * 40 / 100, c.w * 56 / 100], (x: c.w * 63 / 100, y: g - 58 * s))
    }

    /// The Creel house, left empty since 1959: faded green damask paper over a dark wainscot, peeling at the seams
    /// and stained; the tall window boarded up, moonlight through the gaps; the family's grandfather clock; the
    /// fireplace cold, a cracked mirror over the mantel and a dusty radio on it; an armchair and a sofa under grey dust
    /// sheets; brass wall lamps and a chandelier hung with cobwebs; the stairs going up on the right into the dark
    /// with their turned balusters. Bare dark boards along the front. On the screen saver the stairs climb to the
    /// landing and the dark upstairs: a gallery rail, bedroom doors, one ajar on blackness, and a window with the moon.
    static func hawkinsCreel(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsCreelFrame(c, g), tall = isTall(c)
        // The paper: faded green with a darker damask figure in rows, stained in places and peeling at a seam or two.
        let paper = C(0x56624E), fig = C(0x4A5644), figL = C(0x606C58)
        c.rect(0, 0, c.w, f.dado, paper)
        for (r, y) in stride(from: 4 * s, to: f.dado - 6 * s, by: 12 * s).enumerated() {
            for x in stride(from: (r % 2) * 8 * s, to: c.w, by: 16 * s) {
                c.rect(x + 2 * s, y + 2 * s, 3 * s, 4 * s, fig); c.rect(x + s, y + 3 * s, 5 * s, 2 * s, fig)
                c.rect(x + 3 * s, y, s, 2 * s, fig); c.rect(x + 3 * s, y + 6 * s, s, 2 * s, fig); c.px(x + 3 * s, y + 3 * s, figL)
            }
        }
        for k in 0..<(c.w / (60 * s) + 1) {
            let x = k * 60 * s + Int(noise(k + 5) * Double(30 * s)), y = Int(noise(k + 15) * Double(max(1, f.dado - 30 * s)))
            c.ellipse(x, y + 12 * s, 6 * s, 10 * s, C(0x4E5846, 0.6))
            if noise(k + 25) > 0.5 {   // a strip peeling down, the plaster under it
                c.rect(x + 8 * s, y, 5 * s, 14 * s, C(0x8A8670)); c.rect(x + 13 * s, y + 3 * s, 3 * s, 10 * s, C(0x6A7460))
                c.rect(x + 13 * s, y + 13 * s, 4 * s, 2 * s, C(0x3E4836))
            }
        }
        // The wainscot: dark wood in panels, a rail along its top and the skirting.
        c.rect(0, f.dado, c.w, g - f.dado, C(0x3A2C22))
        for x in stride(from: 3 * s, to: c.w, by: 18 * s) { c.rect(x, f.dado + 4 * s, 14 * s, g - f.dado - 8 * s, C(0x32261C)); c.rect(x, f.dado + 4 * s, 14 * s, s, C(0x2A2018)); c.rect(x, g - 5 * s, 14 * s, s, C(0x4A3A2C)) }
        c.rect(0, f.dado - 2 * s, c.w, 2 * s, C(0x4A3A2C)); c.rect(0, f.dado - 2 * s, c.w, s, C(0x5E4C3A))
        c.rect(0, g - 3 * s, c.w, 3 * s, C(0x2A2018))

        if tall {
            // The landing and the gallery across the top of the stairs, the upstairs hall dark behind its balusters,
            // doors along it, one ajar on blackness, a window with the moon; a ceiling with a water stain above.
            let ly = g - 140 * s
            if ly > 70 * s {
                c.rect(0, 0, c.w, ly, C(0x2E3628))
                for (r, y) in stride(from: 4 * s, to: ly - 6 * s, by: 12 * s).enumerated() {
                    for x in stride(from: (r % 2) * 8 * s, to: c.w, by: 16 * s) { c.rect(x + 2 * s, y + 2 * s, 3 * s, 4 * s, C(0x283024)) }
                }
                // Paper peeling off the upstairs wall in long strips.
                for k in 0..<6 {
                    let px0 = c.w * (8 + k * 16) / 100 + Int(noise(k + 160) * Double(10 * s)), py0 = 14 * s + Int(noise(k + 170) * Double(max(1, ly - 80 * s)))
                    c.rect(px0, py0, 6 * s, (10 + k % 3 * 6) * s, C(0x5E5A48)); c.rect(px0 + 6 * s, py0 + 2 * s, 3 * s, (8 + k % 3 * 6) * s, C(0x3A4430))
                    c.rect(px0 + 6 * s, py0 + (10 + k % 3 * 6) * s, 4 * s, 2 * s, C(0x222A1C))
                }
                for (k, dx) in [c.w * 16 / 100, c.w * 40 / 100, c.w * 64 / 100 + 30 * s].enumerated() {
                    c.rect(dx - 10 * s, ly - 36 * s, 20 * s, 36 * s, C(0x241C16)); c.rect(dx - 9 * s, ly - 35 * s, 18 * s, 35 * s, C(0x3A2C22))
                    c.rect(dx - 9 * s, ly - 35 * s, s, 35 * s, C(0x4A3A2C))
                    if k == 1 { c.rect(dx - 9 * s, ly - 35 * s, 11 * s, 35 * s, C(0x060606)); c.rect(dx + 2 * s, ly - 35 * s, 7 * s, 35 * s, C(0x32261C)) }
                    else { c.rect(dx + 5 * s, ly - 18 * s, 2 * s, 2 * s, C(0x8A7A4A)) }
                }
                // Portraits of the family in heavy frames along the upstairs wall, their faces gone dark, and a
                // tall arched window over the stairs with the moon in it.
                for (k, px0) in [c.w * 28 / 100, c.w * 52 / 100, c.w * 74 / 100].enumerated() {
                    let py0 = ly - 52 * s - (k % 2) * 8 * s
                    c.rect(px0 - 8 * s, py0, 16 * s, 20 * s, C(0x6A5430)); c.rect(px0 - 6 * s, py0 + 2 * s, 12 * s, 16 * s, C(0x2A2A22))
                    c.circle(px0, py0 + 8 * s, 3 * s, C(0x4A443A)); c.rect(px0 - 4 * s, py0 + 12 * s, 8 * s, 6 * s, C(0x1E1E18))
                    c.rect(px0 - 8 * s, py0, 16 * s, s, C(0x8A7040))
                }
                let awx = c.w * 90 / 100, awy = max(20 * s, ly - 100 * s)
                c.rect(awx - 13 * s, awy, 26 * s, 44 * s, C(0x3A2C22)); c.ellipse(awx, awy, 13 * s, 10 * s, C(0x3A2C22))
                c.rect(awx - 11 * s, awy, 22 * s, 42 * s, C(0x101828)); c.ellipse(awx, awy, 11 * s, 8 * s, C(0x101828))
                c.circle(awx - 3 * s, awy + 4 * s, 4 * s, C(0xD8DCD0))
                c.rect(awx - s, awy - 8 * s, 2 * s, 50 * s, C(0x3A2C22)); c.rect(awx - 11 * s, awy + 14 * s, 22 * s, 2 * s, C(0x3A2C22))
                c.rect(awx - 11 * s, awy + 28 * s, 22 * s, 2 * s, C(0x3A2C22))
                for k in 0..<14 { c.rect(awx - 14 * s - k * 2 * s, awy + 44 * s + k * 4 * s, 8 * s, 2 * s, C(0x8A9AAA, 0.05)) }
                let mwx = c.w * 6 / 100 + 6 * s
                c.rect(mwx - 12 * s, ly - 44 * s, 24 * s, 30 * s, C(0x3A2C22)); c.rect(mwx - 10 * s, ly - 42 * s, 20 * s, 26 * s, C(0x101828))
                c.circle(mwx + 4 * s, ly - 34 * s, 3 * s, C(0xD8DCD0)); c.circle(mwx + 5 * s, ly - 35 * s, 3 * s, C(0x101828))
                c.rect(mwx - s, ly - 42 * s, 2 * s, 26 * s, C(0x3A2C22)); c.rect(mwx - 10 * s, ly - 30 * s, 20 * s, 2 * s, C(0x3A2C22))
                for k in 0..<6 { c.rect(mwx - 10 * s + k * 4 * s, ly - 16 * s, 2 * s, s, C(0x8A9AAA, 0.3)) }
                // The gallery: its floor edge, a handrail and turned balusters.
                c.rect(0, ly, c.w, 5 * s, C(0x3A2C22)); c.rect(0, ly, c.w, s, C(0x5E4C3A)); c.rect(0, ly + 5 * s, c.w, s, C(0x1A140E))
                c.rect(0, ly - 14 * s, c.w, 2 * s, C(0x5E4C3A)); c.rect(0, ly - 14 * s, c.w, s, C(0x7A6650))
                for x in stride(from: 2 * s, to: c.w, by: 6 * s) { c.rect(x, ly - 12 * s, 2 * s, 12 * s, C(0x4A3A2C)); c.rect(x - s / 2, ly - 7 * s, 3 * s, 2 * s, C(0x5E4C3A)) }
                // The ceiling: its cornice, a stain, a patch where the plaster has fallen and the laths show, and the
                // attic hatch.
                c.rect(0, 0, c.w, 8 * s, C(0x3E4436)); c.rect(0, 8 * s, c.w, 2 * s, C(0x5A6250))
                c.ellipse(c.w * 30 / 100, 4 * s, 20 * s, 3 * s, C(0x343A2C))
                let lpx = c.w * 70 / 100
                c.rect(lpx - 14 * s, 0, 28 * s, 7 * s, C(0x1E2018))
                for k in 0..<3 { c.rect(lpx - 13 * s, k * 2 * s + s, 26 * s, s, C(0x5E4C3A)) }
                c.rect(c.w * 46 / 100, 0, 18 * s, 6 * s, C(0x32261C)); c.rect(c.w * 46 / 100 + s, s, 16 * s, 4 * s, C(0x3A2C22))
                c.rect(c.w * 46 / 100 + 8 * s, 6 * s, s, 6 * s, C(0x8A8A80)); c.rect(c.w * 46 / 100 + 7 * s, 12 * s, 3 * s, 2 * s, C(0x8A8A80))
                // On the downstairs wall, high up, a big landscape in a gilt frame, gone dark with age.
                let lsx = c.w * 34 / 100, lsy = ly + 16 * s
                if lsy + 26 * s < g - 64 * s {
                    c.rect(lsx - 22 * s, lsy, 44 * s, 26 * s, C(0x8A7040)); c.rect(lsx - 20 * s, lsy + 2 * s, 40 * s, 22 * s, C(0x2E3426))
                    c.rect(lsx - 20 * s, lsy + 2 * s, 40 * s, 9 * s, C(0x4A4A3A)); c.ellipse(lsx + 8 * s, lsy + 16 * s, 14 * s, 5 * s, C(0x26301E))
                    c.rect(lsx - 12 * s, lsy + 12 * s, 3 * s, 10 * s, C(0x1E2416)); c.circle(lsx - 11 * s, lsy + 10 * s, 4 * s, C(0x1E2416))
                    c.rect(lsx - 22 * s, lsy, 44 * s, s, C(0xB89A58))
                }
            }
        }

        // The tall window, boarded up: the frame, the dark, planks nailed across at angles and moonlight in the gaps.
        let wx = f.window, wy = g - 50 * s, ww = 22 * s, wh = 36 * s
        c.rect(wx - ww / 2 - 3 * s, wy - 3 * s, ww + 6 * s, wh + 6 * s, C(0x3A2C22)); c.rect(wx - ww / 2 - 3 * s, wy - 3 * s, ww + 6 * s, s, C(0x5E4C3A))
        c.rect(wx - ww / 2, wy, ww, wh, C(0x0E1218))
        for k in 0..<5 { c.rect(wx - ww / 2 + Int(noise(k + 40) * Double(ww)), wy + k * 8 * s + 2 * s, s, 3 * s, C(0xA8B8C8)) }
        for k in 0..<6 {
            let by = wy + 2 * s + k * 7 * s, tilt = (k % 2 == 0 ? 1 : -1) * Int(noise(k + 50) * 3)
            for x in stride(from: wx - ww / 2 - 4 * s, to: wx + ww / 2 + 4 * s, by: s) {
                let y = by + (x - wx) * tilt / (ww / 2 + 4 * s) * s
                c.rect(x, y, s, 4 * s, C(0x5E5040)); c.rect(x, y, s, s, C(0x7A6A54)); c.rect(x, y + 3 * s, s, s, C(0x3E3428))
            }
            c.rect(wx - ww / 2 - 2 * s, by + s, s, s, C(0x9A9AA0)); c.rect(wx + ww / 2 + s, by + s, s, s, C(0x9A9AA0))
        }
        c.rect(wx - ww / 2 - 5 * s, wy + wh + 3 * s, ww + 10 * s, 2 * s, C(0x4A3A2C))

        // The grandfather clock (its pendulum swings in the moving layer).
        hawkinsP4Clock(c, f.clock, g - s, s, h: 48 * s, wood: C(0x4A2C1C), woodD: C(0x2E1A10), woodL: C(0x6A4430))

        // The fireplace: a brick surround, the dark hearth with old ash, a mantel shelf with a dusty radio and a
        // photo, and the cracked mirror over it.
        let fx = f.fire, fw = 36 * s
        c.rect(fx - fw / 2, g - 26 * s, fw, 26 * s, C(0x6A3A2E))
        for (r, y) in stride(from: g - 26 * s, to: g, by: 3 * s).enumerated() {
            c.rect(fx - fw / 2, y, fw, s, C(0x4A2A22))
            for x in stride(from: fx - fw / 2 + (r % 2) * 3 * s, to: fx + fw / 2, by: 6 * s) { c.rect(x, y, s, 3 * s, C(0x4A2A22)) }
        }
        c.rect(fx - 10 * s, g - 17 * s, 20 * s, 17 * s, C(0x120C0A)); c.rect(fx - 10 * s, g - 17 * s, 20 * s, s, C(0x2A1A16))
        c.rect(fx - 7 * s, g - 3 * s, 14 * s, 2 * s, C(0x5A5650)); c.rect(fx - 4 * s, g - 4 * s, 6 * s, s, C(0x3A3632))
        c.rect(fx - fw / 2 - 3 * s, g - 29 * s, fw + 6 * s, 3 * s, C(0x4A3A2C)); c.rect(fx - fw / 2 - 3 * s, g - 29 * s, fw + 6 * s, s, C(0x6A5644))
        c.rect(fx - 13 * s, g - 35 * s, 10 * s, 6 * s, C(0x6A4A30)); c.rect(fx - 13 * s, g - 35 * s, 10 * s, s, C(0x8A6A44))
        c.rect(fx - 12 * s, g - 33 * s, 5 * s, 3 * s, C(0xA89A6A)); c.circle(fx - 5 * s, g - 32 * s, s, C(0xC8B888))
        c.rect(fx + 6 * s, g - 35 * s, 6 * s, 6 * s, C(0x8A7A4A)); c.rect(fx + 7 * s, g - 34 * s, 4 * s, 4 * s, C(0x6A6A62))
        let my = g - 58 * s
        c.rect(fx - 12 * s, my, 24 * s, 20 * s, C(0x8A7040)); c.rect(fx - 10 * s, my + 2 * s, 20 * s, 16 * s, C(0x5A6A6E))
        c.rect(fx - 8 * s, my + 3 * s, 3 * s, 10 * s, C(0x7A8A8E))
        for k in 0..<10 { c.rect(fx - 2 * s + k * s * 2 / 3, my + 4 * s + k * s * 3 / 2, s, s, C(0x2A3436)) }
        for k in 0..<6 { c.rect(fx + 2 * s - k * s, my + 9 * s + k * s, s, s, C(0x2A3436)) }

        // The wall lamps: brass arms with a bulb each (they flicker in the moving layer), cobwebs strung from one.
        for lx in f.sconces {
            c.rect(lx - s, g - 40 * s, 3 * s, 5 * s, C(0x8A7040)); c.rect(lx - 3 * s, g - 36 * s, 7 * s, s, C(0x8A7040))
            c.rect(lx - 3 * s, g - 38 * s, s, 2 * s, C(0x8A7040)); c.rect(lx + 3 * s, g - 38 * s, s, 2 * s, C(0x8A7040))
            c.rect(lx - 3 * s, g - 40 * s, s, 2 * s, C(0x5A5444)); c.rect(lx + 3 * s, g - 40 * s, s, 2 * s, C(0x5A5444))
        }
        for k in 0..<8 { c.px(f.sconces[1] + 4 * s + k * s, g - 40 * s - k * s / 2, C(0xB8BCB0, 0.6)); c.px(f.sconces[1] + 4 * s + k * s, g - 38 * s - k * s, C(0xB8BCB0, 0.4)) }

        // The armchair and the sofa under their dust sheets: grey, draped, folds hanging to the floor.
        let sheet = C(0x8A8C84), sheetD = C(0x6E706A), sheetL = C(0xA0A298)
        let ch = f.chair
        c.ellipse(ch, g - 14 * s, 9 * s, 6 * s, sheet); c.rect(ch - 10 * s, g - 14 * s, 20 * s, 14 * s, sheet)
        c.ellipse(ch - 9 * s, g - 10 * s, 3 * s, 3 * s, sheet); c.ellipse(ch + 9 * s, g - 10 * s, 3 * s, 3 * s, sheet)
        c.rect(ch - 7 * s, g - 19 * s, 10 * s, s, sheetL)
        for x in stride(from: ch - 9 * s, to: ch + 10 * s, by: 4 * s) { c.rect(x, g - 9 * s, s, 9 * s, sheetD) }
        let sf = f.sofa
        c.ellipse(sf, g - 16 * s, 26 * s, 5 * s, sheet); c.rect(sf - 28 * s, g - 16 * s, 56 * s, 16 * s, sheet)
        c.ellipse(sf - 26 * s, g - 12 * s, 4 * s, 5 * s, sheet); c.ellipse(sf + 26 * s, g - 12 * s, 4 * s, 5 * s, sheet)
        c.rect(sf - 20 * s, g - 20 * s, 30 * s, s, sheetL)
        for x in stride(from: sf - 26 * s, to: sf + 28 * s, by: 5 * s) { c.rect(x, g - 8 * s, s, 8 * s, sheetD) }
        c.rect(sf - 28 * s, g - s, 56 * s, s, sheetD)

        // The chandelier, hanging from above: a brass ring of candle bulbs, crystals, cobwebs (the moving layer lights it).
        let cl = f.chandelier, hook = tall ? g - 134 * s : 0
        c.rect(cl.x, hook, s, cl.y - hook, C(0x5A4A2A))
        if tall { c.circle(cl.x, hook, 3 * s, C(0x5A6250)) }
        c.rect(cl.x - 12 * s, cl.y + 3 * s, 25 * s, 2 * s, C(0x8A7040)); c.rect(cl.x - 12 * s, cl.y + 3 * s, 25 * s, s, C(0xB89A58))
        c.rect(cl.x - 2 * s, cl.y, 5 * s, 6 * s, C(0x8A7040))
        for k in 0..<5 {
            let bx = cl.x - 12 * s + k * 6 * s
            c.rect(bx, cl.y, s, 3 * s, C(0xE8E0C8)); c.rect(bx, cl.y + 5 * s, s, 2 * s, C(0xB8C8D0))
        }
        for k in 0..<10 { c.px(cl.x - 10 * s + k * 2 * s, cl.y + 6 * s + (k % 3) * s, C(0xC8CCC0, 0.5)) }

        // The stairs on the right: treads climbing to the right, the stringer, turned balusters and the newel post.
        let run = 5 * s, rise = 4 * s, top = tall ? g - 140 * s : -4 * s
        var k = 0
        while true {
            k += 1
            let x = f.stairs + k * run, y = g - k * rise
            if x > c.w || y < top { break }
            c.rect(x, y, c.w - x, rise, C(0x4A3A2C)); c.rect(x, y, c.w - x, s, C(0x6A5644)); c.rect(x, y + s, run, s, C(0x2A2018))
            if k % 2 == 1 { c.rect(x + 2 * s, y - 13 * s, s, 13 * s, C(0x5E4C3A)); c.rect(x + s, y - 8 * s, 3 * s, 2 * s, C(0x6A5644)) }
        }
        for j in 0...(k * run / s) {
            let x = f.stairs + j * s, y = g - 14 * s - j * rise / run
            if x > c.w || y < top - 14 * s { break }
            c.rect(x, y, s, 2 * s, C(0x6A5644)); c.px(x, y, C(0x8A7458))
        }
        c.rect(f.stairs - 2 * s, g - 18 * s, 4 * s, 18 * s, C(0x5E4C3A)); c.rect(f.stairs - 2 * s, g - 18 * s, s, 18 * s, C(0x7A6650))
        c.circle(f.stairs, g - 19 * s, 2 * s, C(0x6A5644))
        // A cobweb in the corner over the stairs.
        for k2 in 0..<12 { c.px(c.w - s - k2 * s, k2 * s / 2 + (tall ? g - 140 * s : 0), C(0xB8BCB0, 0.4)); c.px(c.w - s - k2 * s / 2, k2 * s + (tall ? g - 140 * s : 0), C(0xB8BCB0, 0.4)) }

        // The floor: bare dark boards, dusty, a lit edge.
        c.ground(g, C(0x3A2E26), edge: C(0x54443A), speck: C(0x32281F), seed: 71)
    }

    /// The Creel house's life: the clock's pendulum ticking from side to side, the wall lamps and the chandelier
    /// burning dim and every so often flickering out and back.
    static func hawkinsCreelLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hawkinsCreelFrame(c, g)
        // The pendulum: a beat a second, one way and back.
        let h = 48 * s, top = g - s - h
        let ang = sin(t * .pi) * 0.22
        hawkinsP4Pendulum(c, (f.clock, top + 22 * s), h - 34 * s, ang, s, bob: C(0xC8A040))
        // The lights.
        let out = noise(Int(t * 12)) < 0.12 || (noise(Int(t * 2.5) + 300) < 0.15 && Int(t * 18) % 2 == 0)
        let lit = out ? C(0x6A6450) : C(0xF0D890)
        for lx in f.sconces {
            if !out { for (r, a) in [(8, 0.05), (5, 0.07)] { c.circle(lx, g - 41 * s, r * s, C(0xF8D890, a)) } }
            c.rect(lx - 3 * s, g - 41 * s, s, s, lit); c.rect(lx + 3 * s, g - 41 * s, s, s, lit)
        }
        let cl = f.chandelier
        if !out { for (r, a) in [(16, 0.04), (10, 0.05)] { c.circle(cl.x, cl.y + 2 * s, r * s, C(0xF8D890, a)) } }
        for k in 0..<5 { c.rect(cl.x - 12 * s + k * 6 * s, cl.y - s, s, s, k == 2 && !out ? C(0x6A6450) : lit) }
    }
}

// MARK: - Vecna's mind

extension Scenes {
    /// Where things stand in Vecna's mind: the horizon, the far-off Creel house, the grandfather clock, and the big
    /// pieces of floating rock (on the screen saver, more of them up in the sky).
    static func hawkinsMindFrame(_ c: PixelCanvas, _ g: Int) -> (horizon: Int, house: Int, clock: Int) {
        let s = unit(g)
        return (g - 14 * s, c.w * 24 / 100, c.w * 72 / 100)
    }

    /// The floating debris, shared by the moving layer: where each piece hangs, how big, and how it bobs.
    private static func hawkinsMindDebris(_ c: PixelCanvas, _ g: Int) -> [(x: Int, y: Int, r: Int, kind: Int, seed: Int)] {
        let s = unit(g), tall = isTall(c), n = tall ? 22 : 9
        let span = tall ? g - 30 * s : 34 * s, base = tall ? 10 * s : g - 58 * s
        return (0..<n).map { k in
            let x = Int(noise(k * 7 + 300) * Double(c.w - 20 * s)) + 10 * s
            let y = base + Int(noise(k * 7 + 301) * Double(span))
            return (x, y, (2 + Int(noise(k * 7 + 302) * (tall ? 7 : 4))) * s, k % 5, k)
        }
    }

    /// Vecna's mind: a red sky in bands, darkest overhead and burning orange low down, storm cloud streaked across it
    /// and the far ground cracked and glowing; dark ground rolling away to the horizon with dead trees on it and the Creel house
    /// far off, a black shape against the glow; and nearby, standing on its own in the open, the grandfather clock,
    /// tall and dark, its face pale. Pieces of the world hang in the air: rocks, planks, a chair (the moving layer
    /// drifts them). The ground in front plain and dark. On the screen saver the sky goes up and up, great rocks
    /// floating in it, the cloud spiralling round a darker heart.
    static func hawkinsMind(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), f = hawkinsMindFrame(c, g), tall = isTall(c)
        // The sky.
        c.gradient(0, f.horizon, C(0x2A0608), C(0xB8402A), bands: 8)
        // Streaks of cloud across it, darker red, lit along their tops.
        for k in 0..<(f.horizon / (5 * s)) {
            let y = k * 5 * s + Int(noise(k + 400) * Double(3 * s))
            let x = Int(noise(k + 410) * Double(c.w)) - 40 * s, w = (60 + Int(noise(k + 420) * 120)) * s
            let depth = Double(y) / Double(max(1, f.horizon))
            c.rect(x, y, w, s, lerp(C(0x1A0406), C(0x6A1814), depth)); c.rect(x + 10 * s, y - s, w / 2, s, lerp(C(0x4A0C10), C(0xD8603A), depth))
        }
        if tall {
            // The spiral of cloud round a dark heart high in the sky.
            let hx = c.w / 2, hy = f.horizon / 4
            for k in 0..<240 {
                let a = Double(k) * 0.12, r = 4 + Double(k) * 0.9
                let x = hx + Int(cos(a) * r * Double(s) * 1.6), y = hy + Int(sin(a) * r * Double(s) * 0.5)
                c.rect(x, y, 4 * s, s, k % 3 == 0 ? C(0x5A1418) : C(0x1E0406))
            }
            c.ellipse(hx, hy, 14 * s, 5 * s, C(0x120204))
            // Great rocks floating in the sky, far off.
            for k in 0..<5 {
                let rx = c.w * (10 + k * 20) / 100 + Int(noise(k + 520) * Double(20 * s)), ry = f.horizon * (28 + Int(noise(k + 500) * 44)) / 100
                hawkinsP4Rock(c, rx, ry, (12 + Int(noise(k + 510) * 12)) * s, s, seed: k + 50)
            }
        }
        // The far ground: low rolling hills, darker in front.
        c.dunes(base: f.horizon, amp: Double(3 * s), freq: 0.02 / Double(s), phase: 1, bottom: g, C(0x3A1A1A), shade: C(0x5A2620))
        c.dunes(base: f.horizon + 5 * s, amp: Double(2 * s), freq: 0.035 / Double(s), phase: 4, bottom: g, C(0x2E1616))
        // The Creel house far off: a black shape with its gables and chimney, one window glowing faint red.
        let hx = f.house, hb = f.horizon + 2 * s
        c.rect(hx - 14 * s, hb - 14 * s, 28 * s, 14 * s, C(0x140808))
        for y in 0..<(9 * s) { let half = 15 * s - y * 15 / 9; c.rect(hx - 6 * s - half, hb - 14 * s - y, half * 2, 1, C(0x140808)) }
        for y in 0..<(7 * s) { let half = 9 * s - y * 9 / 7; c.rect(hx + 8 * s - half, hb - 14 * s - y, half * 2, 1, C(0x140808)) }
        c.rect(hx + 2 * s, hb - 26 * s, 3 * s, 8 * s, C(0x140808))
        c.rect(hx - 8 * s, hb - 10 * s, 3 * s, 4 * s, C(0x8A2018)); c.rect(hx + 6 * s, hb - 10 * s, 3 * s, 4 * s, C(0x2A0C0C))
        // Dead trees on the ridge, bare and twisted.
        for (k, tx) in [c.w * 6 / 100, c.w * 44 / 100, c.w * 53 / 100, c.w * 90 / 100].enumerated() {
            let th = (16 + k % 2 * 8) * s, ty = f.horizon + 4 * s
            c.rect(tx, ty - th, 2 * s, th, C(0x160A0A))
            for b in 0..<4 {
                let by = ty - th + (2 + b * 4) * s, dir = (b + k) % 2 == 0 ? 1 : -1
                for d in 0..<((7 - b) * s) { c.rect(tx + dir * d, by - d * 2 / 3, s, s, C(0x160A0A)) }
            }
        }
        // Cracks in the far ground glowing red, as if the world were splitting along them.
        for k in 0..<5 {
            var x = c.w * (8 + k * 21) / 100, y = f.horizon + 4 * s + (k % 2) * 2 * s
            for st in 0..<(14 + k % 3 * 6) {
                c.rect(x, y, 2 * s, s, C(0xE0502A)); c.rect(x, y + s, 2 * s, s, C(0x6A1A14))
                x += 2 * s; y += (noise(k * 41 + st) > 0.5 ? 1 : -1) * (st % 3 == 0 ? s : 0)
            }
        }
        // Rocks hanging further off in the haze, still, smaller than the ones drifting near.
        if !tall {
            for (k, rx) in [c.w * 13 / 100, c.w * 40 / 100, c.w * 58 / 100, c.w * 93 / 100].enumerated() {
                hawkinsP4Rock(c, rx, g - (46 + k % 2 * 10) * s, (5 + k % 3 * 2) * s, s, seed: k + 70)
            }
        }
        // Vines creeping across the near ground towards the clock.
        for k in 0..<6 {
            var x = Double(f.clock + (k - 3) * 14 * s), y = Double(g - 2 * s), a = k < 3 ? Double.pi : 0
            for st in 0..<(30 + k * 6) {
                c.rect(Int(x), Int(y), 2 * s, s, C(0x1E0C0E)); if st % 4 == 0 { c.px(Int(x), Int(y), C(0x5A1A1C)) }
                x += cos(a) * Double(s); y += sin(a) * Double(s) * 0.3; a += (noise(k * 70 + st) - 0.5) * 0.4
                if y > Double(g) { y = Double(g - s) }
            }
        }
        // The clock, standing alone, tall.
        hawkinsP4Clock(c, f.clock, g - s, s, h: 56 * s, wood: C(0x3A1C14), woodD: C(0x1E0C08), woodL: C(0x6A3424))
        // A rock or two lying where they fell.
        for (k, rx) in [f.clock - 26 * s, c.w * 36 / 100, c.w * 88 / 100].enumerated() {
            c.ellipse(rx, g - 3 * s, (4 + k) * s, (3 + k % 2) * s, C(0x2A1414)); c.ellipse(rx - s, g - 4 * s, (2 + k) * s, s, C(0x4A2420))
        }

        // The ground in front: dark and plain, a dull red edge.
        c.ground(g, C(0x2A1616), edge: C(0x4A2624), speck: C(0x241212), seed: 81)
    }

    /// Vecna's mind's life: the debris hanging in the air drifting slowly up and down and turning, the clock's
    /// pendulum swinging, and now and then a flicker of red lightning far off on the horizon.
    static func hawkinsMindLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), f = hawkinsMindFrame(c, g)
        for d in hawkinsMindDebris(c, g) where abs(d.x - f.clock) > 16 * s {
            let bob = Int(sin(t * 0.5 + Double(d.seed)) * Double(3 * s)), x = d.x + Int(sin(t * 0.2 + Double(d.seed) * 2) * Double(2 * s)), y = d.y + bob
            switch d.kind {
            case 1:   // a plank
                c.rect(x - d.r * 2, y, d.r * 4, 2 * s, C(0x4A2A1E)); c.rect(x - d.r * 2, y, d.r * 4, s, C(0x6A3A26))
                c.rect(x - d.r * 2 + s, y + s, s, s, C(0x2A1610))
            case 3:   // a chair, upside down and turning
                let tilt = Int(sin(t * 0.3 + Double(d.seed)) * 2) * s
                c.rect(x - 3 * s, y, 7 * s, 2 * s, C(0x3A1E14)); c.rect(x - 3 * s, y + 2 * s - tilt, s, 5 * s, C(0x3A1E14))
                c.rect(x + 3 * s, y + 2 * s + tilt, s, 5 * s, C(0x3A1E14)); c.rect(x - 3 * s, y - 5 * s, s, 5 * s, C(0x3A1E14))
                c.rect(x - 3 * s, y, 7 * s, s, C(0x5A2E1E))
            default:  // a rock
                hawkinsP4Rock(c, x, y, d.r, s, seed: d.seed + 7, roots: d.r > 3 * s)
            }
        }
        // The pendulum.
        let h = 56 * s, top = g - s - h
        hawkinsP4Pendulum(c, (f.clock, top + 22 * s), h - 34 * s, sin(t * .pi * 0.8) * 0.25, s, bob: C(0xB89030))
        // Far lightning on the horizon.
        let period = 5.1, ph = t.truncatingRemainder(dividingBy: period)
        if ph < 0.18 {
            let n = Int(t / period), lx = Int(noise(n + 900) * Double(c.w))
            var x = lx, y = f.horizon - 26 * s
            while y < f.horizon { let nx = x + Int((noise(n * 31 + y) - 0.5) * Double(5 * s)); c.rect(min(x, nx), y, abs(nx - x) + s, s, C(0xFF6A50)); x = nx; y += s }
            c.ellipse(lx, f.horizon - 10 * s, 30 * s, 12 * s, C(0xFF5030, 0.06))
        }
    }
}
