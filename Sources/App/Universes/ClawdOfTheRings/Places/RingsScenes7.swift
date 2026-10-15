import Foundation

// The Dead Merges, Dol Build-ur and Go-blin Town.
let ringsScenes7: [Location: Place] = [
    .deadMarshes: Place(name: "The Dead Merges", panel: 0x14180E, still: Scenes.deadMarshes),
    .dolGuldur: Place(name: "Dol Build-ur", panel: 0x120E14, still: Scenes.dolGuldur),
    .goblinTown: Place(name: "Go-blin Town", panel: 0x18140E, still: Scenes.goblinTown),
]

// MARK: - Shared bits for these scenes

/// A straight line of `s`-pixel dots.
private func r7Line(_ c: PixelCanvas, _ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, _ col: Px, s: Int) {
    let n = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in 0...n {
        let k = Double(i) / Double(n)
        c.rect(x0 + Int((Double(x1 - x0) * k).rounded()), y0 + Int((Double(y1 - y0) * k).rounded()), s, s, col)
    }
}

/// A rope or chain sagging from one point to another, `sag` pixels at its lowest, `s` pixels thick. Returns the row
/// it hangs at in each column, from `x0` on.
@discardableResult
private func r7Sag(_ c: PixelCanvas, _ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, sag: Int, _ col: Px, s: Int) -> [Int] {
    guard x1 > x0 else { return [] }
    var rows: [Int] = [], prev = y0
    for x in x0..<x1 {
        let k = Double(x - x0) / Double(x1 - x0)
        let y = y0 + Int(Double(y1 - y0) * k + Double(sag) * 4 * k * (1 - k))
        c.rect(x, min(prev, y), 1, abs(y - prev) + s, col)
        rows.append(y); prev = y
    }
    return rows
}

/// A soft round glow: discs of `col` stacked thicker towards the middle.
private func r7Glow(_ c: PixelCanvas, _ x: Int, _ y: Int, _ r: Int, _ col: Px, _ a: Double) {
    for k in 0..<4 { c.circle(x, y, max(1, r * (4 - k) / 4), col.alpha(a)) }
}

/// A jagged range: straight slopes between crags of random height every `step` columns, with smaller crags on them,
/// filled down to `bottom`; `edge` lines the crest.
private func r7Range(_ c: PixelCanvas, base: Int, amp: Int, step: Int, bottom: Int, _ col: Px, edge: Px, seed: Int) {
    let st = max(2, step), st2 = max(2, step / 3)
    for x in 0..<c.w {
        let i = x / st, f = Double(x % st) / Double(st)
        let j = x / st2, f2 = Double(x % st2) / Double(st2)
        let big: Double = noise(i * 2 + seed) * (1 - f) + noise(i * 2 + 2 + seed) * f
        let fine: Double = noise(j * 2 + seed + 501) * (1 - f2) + noise(j * 2 + 2 + seed + 501) * f2
        let top = base - Int(pow(big * 0.8 + fine * 0.2, 1.3) * Double(amp))
        if top < bottom { c.rect(x, top, 1, bottom - top, col); c.px(x, top, edge) }
    }
}

/// A dead tree: a crooked trunk tapering up from `base`, bare limbs reaching up off it, each forking into two twigs.
/// Returns each limb's fork and its two twig tips, for webs.
@discardableResult
private func r7DeadTree(_ c: PixelCanvas, _ x: Int, _ base: Int, _ hgt: Int, s: Int, seed: Int, limbs: Int,
                        _ col: Px, lit: Px) -> [(hub: (x: Int, y: Int), a: (x: Int, y: Int), b: (x: Int, y: Int))] {
    guard hgt > 1 else { return [] }
    let foot = max(s, hgt / 10)
    let lean: Double = (noise(seed) - 0.5) * 0.35
    // the trunk's middle, `y` rows up from the base: a slow wiggle and a lean
    func trunkX(_ y: Int) -> Int {
        let k = Double(y) / Double(hgt)
        return x + Int(sin(k * 5 + Double(seed)) * Double(hgt) * 0.035 + lean * k * Double(hgt))
    }
    // roots, splayed
    for side in [-1, 1] { r7Line(c, x, base - foot, x + side * foot * 2, base, col, s: max(1, foot / 2)) }
    for y in 0..<hgt {
        let k = Double(y) / Double(hgt)
        let w = max(s, Int(Double(foot) * (1 - k * 0.8)))
        let tx = trunkX(y)
        c.rect(tx - w / 2, base - y, w, 1, col)
        c.px(tx - w / 2, base - y, lit)
    }
    var forks: [(hub: (x: Int, y: Int), a: (x: Int, y: Int), b: (x: Int, y: Int))] = []
    for i in 0..<max(0, limbs) {
        let k: Double = 0.35 + noise(seed * 7 + i * 3 + 1) * 0.55
        let y0 = Int(k * Double(hgt)), bx = trunkX(y0), by = base - y0
        let side = i % 2 == 0 ? -1 : 1
        let len: Double = Double(hgt) * (0.2 + noise(seed * 7 + i * 3 + 2) * 0.18) * (1.25 - k * 0.6)
        let ang: Double = 0.35 + noise(seed * 7 + i * 3 + 3) * 0.6
        // each limb bends once on its way out
        let mx = bx + side * Int(len * 0.5 * cos(ang + 0.3)), my = by - Int(len * 0.5 * sin(ang + 0.3))
        let ex = mx + side * Int(len * 0.5 * cos(ang - 0.15)), ey = my - Int(len * 0.5 * sin(ang - 0.15))
        let lw = max(s, Int(Double(foot) * (1 - k) * 0.7))
        r7Line(c, bx, by, mx, my, col, s: lw)
        r7Line(c, mx, my, ex, ey, col, s: max(s, lw * 2 / 3))
        var tips: [(x: Int, y: Int)] = []
        for t in 0..<2 {
            let tl: Double = len * (0.35 + noise(seed * 7 + i * 3 + t + 40) * 0.2)
            let ta: Double = ang + (t == 0 ? 0.65 : -0.45)
            let tx = ex + side * Int(tl * cos(ta)), ty = ey - Int(tl * sin(ta))
            r7Line(c, ex, ey, tx, ty, col, s: s)
            tips.append((tx, ty))
        }
        forks.append(((ex, ey), tips[0], tips[1]))
    }
    // the snapped-off top
    let tx = trunkX(hgt - 1)
    c.rect(tx - s, base - hgt - s, s, 2 * s, col)
    return forks
}

/// A spider's web strung in a fork: spokes from the hub out to the line between the two tips, and threads across.
private func r7Web(_ c: PixelCanvas, hub: (x: Int, y: Int), _ a: (x: Int, y: Int), _ b: (x: Int, y: Int), _ col: Px) {
    let spokes = 5
    var prev: [(x: Int, y: Int)] = []
    for ring in [0.3, 0.55, 0.8, 1.0] {
        var pts: [(x: Int, y: Int)] = []
        for j in 0...spokes {
            let f = Double(j) / Double(spokes)
            let ex = Double(a.x) + Double(b.x - a.x) * f, ey = Double(a.y) + Double(b.y - a.y) * f
            pts.append((hub.x + Int((ex - Double(hub.x)) * ring), hub.y + Int((ey - Double(hub.y)) * ring)))
        }
        for (p, q) in zip(pts, pts.dropFirst()) { r7Line(c, p.x, p.y, q.x, q.y, col, s: 1) }
        prev = pts
    }
    for p in prev { r7Line(c, hub.x, hub.y, p.x, p.y, col, s: 1) }
}

// MARK: - The Dead Merges

extension Scenes {
    /// Where the bog meets the foot of the mountains.
    static func deadMarshesHorizon(_ c: PixelCanvas, _ g: Int) -> Int { Int(Double(g) * (isTall(c) ? 0.46 : 0.5)) }

    /// The Dead Merges: a low grey-green sky, a smudge of red over the black jagged mountains of Mordor on the
    /// horizon, and the bog stretching out to them: still black pools rimmed with reeds, rotting stumps and dead
    /// snags, mist lying on the water and pale corpse-lights floating over it. In one pool near the path a drowned face
    /// looks up from under the surface. The crew stands on the narrow tussocky path through it. On tall screens the
    /// mountains rise high under the glow, and the marsh runs a long way out to them.
    static func deadMarshes(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), hz = deadMarshesHorizon(c, g)
        c.gradient(0, hz, C(0x262B25), C(0x7A8070), bands: tall ? 10 : 6)
        // heavy cloud
        for i in 0..<(tall ? 12 : 5) {
            let x = Int(noise(i * 5 + 300) * Double(c.w)), y = Int(noise(i * 5 + 301) * Double(hz) * 0.6)
            wisp(c, x, y, (40 + Int(noise(i * 5 + 302) * 90.0)) * s, C(0x1C201A, 0.5), s: (tall ? 2 : 1) * s)
        }
        // the red smudge of Mordor over the mountains
        let mx = Int(Double(c.w) * 0.68)
        c.ellipse(mx, hz - (tall ? g / 8 : 7 * s), c.w / 3, tall ? g / 7 : 10 * s, C(0x8A3A22, 0.12))
        c.ellipse(mx, hz - (tall ? g / 14 : 4 * s), c.w / 5, tall ? g / 12 : 6 * s, C(0xA8482A, 0.12))
        // the mountains: a far range in haze and the black near one
        r7Range(c, base: hz - (tall ? 6 : 2) * s, amp: tall ? g / 5 : 14 * s, step: (tall ? 44 : 26) * s, bottom: hz,
                C(0x45443F), edge: C(0x5E5048), seed: 310)
        r7Range(c, base: hz, amp: tall ? g / 9 : 8 * s, step: (tall ? 28 : 17) * s, bottom: hz, C(0x22231F),
                edge: C(0x4A3430), seed: 330)
        for k in 0..<3 { c.rect(0, hz - (k + 1) * 2 * s, c.w, 2 * s, C(0x9AA090, 0.12 * Double(3 - k))) }
        // the bog, paler where the mist lies on it far out
        c.gradient(hz, g, C(0x606858), C(0x3A3F2C), bands: tall ? 10 : 6)
        deadMarshesPools(c, g)
        deadMarshesSnags(c, g)
        // mist lying on the water
        for i in 0..<(tall ? 18 : 7) {
            let x = Int(noise(i * 5 + 320) * Double(c.w))
            let y = hz + Int(noise(i * 5 + 321) * Double(g - hz) * 0.85)
            let len = (50 + Int(noise(i * 5 + 322) * 120.0)) * s
            wisp(c, x, y, len, C(0xA8B0A0, 0.16), s: (tall ? 2 : 1) * s)
        }
        deadMarshesLights(c, g)
        // the path: tussocks of coarse grass, flattened where it's walked
        c.ground(g, C(0x48482E), edge: C(0x6A6A42), speck: C(0x3A3A24), seed: 77)
        for i in 0..<(c.w / (5 * s)) {
            let x = Int(noise(i * 3 + 380) * Double(c.w)), hgt = (1 + Int(noise(i * 3 + 381) * 2.0)) * s
            c.rect(x, g - hgt, s, hgt, C(0x5E5E3A))
            c.rect(x + s, g - hgt + s, s, hgt - s, C(0x6E6C44))
        }
        // a few puddles in the path's ruts
        for i in 0..<(c.w / (60 * s)) where c.h - g > 4 * s {
            let x = Int(noise(i * 3 + 390) * Double(c.w)), y = g + 2 * s + Int(noise(i * 3 + 391) * Double(c.h - g - 4 * s))
            c.ellipse(x, y, (4 + Int(noise(i * 3 + 392) * 5.0)) * s, max(1, s / 2), C(0x1A1E16))
        }
    }

    /// The pools, rimmed with reeds: far ones thin slivers paled by the mist, near ones black and wide. One near the
    /// path holds the drowned face.
    static func deadMarshesPools(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), hz = deadMarshesHorizon(c, g), depth = max(1, g - hz - 2 * s)
        // a pool at `x`, `y`, `k` of the way from the horizon to the path
        func pool(_ x: Int, _ y: Int, _ rx: Int, _ ry: Int, _ k: Double) {
            c.ellipse(x, y - max(1, ry / 3), rx + s, ry, C(0x6E7254, 0.8 - k * 0.4))
            c.ellipse(x, y, rx, ry, lerp(C(0x646C5E), C(0x0C100C), pow(k, 0.5)))
            c.rect(x - rx / 2, y - ry / 2, max(1, rx / 3), 1, C(0xA8B0A0, 0.12 + (1 - k) * 0.2))
        }
        var pools: [(x: Int, y: Int, rx: Int, ry: Int, k: Double)] = []
        for i in 0..<max(0, c.w / ((tall ? 4 : 5) * s)) {
            let k: Double = pow(noise(i * 4 + 340), 1.4)
            let y = hz + s + Int(k * Double(depth))
            let ry = max(1, Int(k * Double(depth) * 0.06))
            let rx = ry * (4 + Int(noise(i * 4 + 341) * 6.0)) + 2 * s
            pools.append((Int(noise(i * 4 + 342) * Double(c.w)), y, rx, ry, k))
        }
        pools.sort { $0.y < $1.y }
        for p in pools {
            pool(p.x, p.y, p.rx, p.ry, p.k)
            // reeds at one end or both, some topped with a bulrush
            for end in [-1, 1] where noise(p.x + end + 350) > 0.45 {
                let rh = max(2 * s, p.ry * 2 + Int(p.k * 4.0) * s)
                for r in 0..<(2 + Int(noise(p.x + end + 351) * 3.0)) {
                    let x = p.x + end * (p.rx - 2 * s + r * s)
                    let hgt = rh - Int(noise(p.x * 3 + r + 352) * Double(rh) * 0.5)
                    c.rect(x, p.y - hgt, max(1, s), hgt, r % 2 == 0 ? C(0x5C5A3C) : C(0x46462E))
                    if noise(p.x * 3 + r + 353) > 0.7, hgt > 3 * s { c.rect(x, p.y - hgt, max(1, s), 2 * s, C(0x3E2C1C)) }
                }
            }
        }
        // tufts of grass on the hummocks between them
        for i in 0..<max(0, c.w * depth / (50 * s * s)) {
            let k: Double = noise(i * 3 + 360)
            let x = Int(noise(i * 3 + 361) * Double(c.w)), y = hz + s + Int(k * Double(depth))
            c.rect(x, y - max(1, Int(k * 3.0) * s), s, max(1, Int(k * 3.0) * s), C(0x6A6A44, 0.8))
        }
        // the drowned face, pale under the black water of a pool beside the path
        let fx = Int(Double(c.w) * 0.62), fy = hz + s + Int(0.8 * Double(depth))
        let fry = max(2 * s, Int(0.8 * Double(depth) * 0.06)), fs = max(1, fry / 2)
        pool(fx, fy, fry * 7, fry, 0.8)
        c.ellipse(fx, fy, fs * 2, max(1, fs + fs / 2), C(0x9AAA94, 0.22))
        c.rect(fx - fs, fy - fs / 2, max(1, fs / 2 + fs / 3), max(1, fs / 2), C(0x020402, 0.5))
        c.rect(fx + fs / 2, fy - fs / 2, max(1, fs / 2 + fs / 3), max(1, fs / 2), C(0x020402, 0.5))
        c.rect(fx - fs / 3, fy + fs, max(1, fs * 2 / 3), max(1, fs / 3), C(0x020402, 0.4))
        // the hair drifting round it
        for k in 0..<5 {
            let a: Double = Double.pi * (1.1 + Double(k) * 0.2)
            c.rect(fx + Int(cos(a) * Double(fs * 3)), fy + Int(sin(a) * Double(fs * 2)), max(1, fs), max(1, s), C(0x3A4030, 0.4))
        }
    }

    /// Rotting stumps and dead snags out in the bog, bigger the nearer they stand.
    static func deadMarshesSnags(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), hz = deadMarshesHorizon(c, g), depth = max(1, g - hz)
        let n = tall ? 11 : 6
        var snags: [(x: Int, k: Double, stump: Bool)] = []
        for i in 0..<n {
            snags.append((Int(noise(i * 4 + 370) * Double(c.w)), 0.1 + noise(i * 4 + 371) * 0.85, noise(i * 4 + 372) > 0.55))
        }
        for (i, sn) in snags.sorted(by: { $0.k < $1.k }).enumerated() {
            let base = hz + Int(sn.k * Double(depth)) - s
            let col = lerp(C(0x5A5E50), C(0x1E1E16), pow(sn.k, 0.6)), lit = lerp(col, C(0x8A8E78), 0.3)
            let full = (tall ? 0.9 : 1.1) * Double(depth)
            if sn.stump {
                let hgt = max(2 * s, Int(full * 0.18 * sn.k)), w = max(s, hgt * 2 / 3)
                c.rect(sn.x - w / 2, base - hgt, w, hgt, col)
                c.rect(sn.x - w / 2, base - hgt, max(1, s), hgt, lit)
                // the broken top, splintered
                for k in 0..<max(1, w / s) where noise(i * 13 + k + 375) > 0.4 {
                    c.rect(sn.x - w / 2 + k * s, base - hgt - s - Int(noise(i * 13 + k + 376) * 2.0) * s, s, 2 * s, col)
                }
            } else {
                r7DeadTree(c, sn.x, base, max(2 * s, Int(full * (0.35 + sn.k * 0.5))), s: s, seed: i + 380,
                           limbs: 2 + i % 2, col, lit: lit)
            }
        }
    }

    /// The corpse-lights: pale candle flames floating over the pools, each with its reflection on the water.
    static func deadMarshesLights(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), hz = deadMarshesHorizon(c, g), depth = max(1, g - hz - 2 * s)
        for i in 0..<(tall ? 10 : 5) {
            let k: Double = 0.15 + noise(i * 3 + 390) * 0.75
            let x = Int(noise(i * 3 + 391) * Double(c.w)), wy = hz + s + Int(k * Double(depth))
            let lift = max(3 * s, Int(k * Double(depth) * 0.2)), ly = wy - lift
            let core = max(1, Int(k * 2.5) * s)
            c.ellipse(x, wy, core * 6 + 2 * s, max(1, core), C(0x0C100C))
            r7Glow(c, x, ly, max(3 * s, lift), C(0xC8E0B0), 0.05)
            c.rect(x - core / 2, ly - core, core, core * 2, C(0xE8F4D0))
            c.rect(x - core / 2, ly - core * 2, max(1, core / 2), core, C(0xC8E0B0, 0.6))
            c.rect(x - core / 2, wy, core, max(1, lift / 3), C(0xC8E0B0, 0.25))
        }
    }
}

// MARK: - Dol Build-ur

extension Scenes {
    /// The top of the courtyard's back wall.
    static func dolGuldurWallTop(_ c: PixelCanvas, _ g: Int) -> Int { g - (isTall(c) ? 30 : 15) * unit(g) }

    /// The towers: middle (share of the width), width in units, top row, and how far off in the haze (0 near).
    static func dolGuldurTowers(_ c: PixelCanvas, _ g: Int) -> [(x: Int, w: Int, top: Int, haze: Double)] {
        let s = unit(g)
        if isTall(c) {
            let list: [(Double, Int, Double, Double)] = [
                (0.10, 18, 0.40, 0.6), (0.96, 14, 0.46, 0.6), (0.27, 22, 0.24, 0.3), (0.70, 20, 0.30, 0.3),
                (0.86, 26, 0.17, 0.15), (0.52, 34, 0.08, 0),
            ]
            return list.map { (Int(Double(c.w) * $0.0), $0.1 * s, Int(Double(g) * $0.2), $0.3) }
        }
        let list: [(Double, Int, Int, Double)] = [
            (0.08, 12, 22, 0.6), (0.70, 14, 14, 0.4), (0.27, 16, -10, 0.25), (0.88, 20, 5, 0.15), (0.50, 26, 2, 0),
        ]
        return list.map { (Int(Double(c.w) * $0.0), $0.1 * s, $0.2 * s, $0.3) }
    }

    /// Dol Build-ur: a bruised night sky with a pale moon, and a sickly green-grey haze rising off the dead forest
    /// below the hill. The Necromancer's fortress stands round the crew: jagged black towers, broken off and bristling
    /// with thorn-like spikes, a few slit windows glowing a faint green, and the courtyard's broken back wall. Dead
    /// trees stand in the courtyard with webs strung in their forks, and the crew stands on its cracked flagstones.
    /// On tall screens the towers stand in full, and in the haze between them a faint fiery eye.
    static func dolGuldur(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), wt = dolGuldurWallTop(c, g)
        c.gradient(0, g, C(0x120E18), C(0x3E4638), bands: tall ? 10 : 7)
        c.stars(0, g / 3, density: tall ? 260 : 160, seed: 41)
        // the moon, veiled
        let mx = Int(Double(c.w) * 0.17), my = tall ? Int(Double(g) * 0.12) : 10 * s, mr = (tall ? 15 : 6) * s
        c.circle(mx, my, mr * 3, C(0xC8D0B8, 0.04)); c.circle(mx, my, mr * 2, C(0xC8D0B8, 0.06))
        c.circle(mx, my, mr, C(0xD8DCC4))
        c.circle(mx - mr / 3, my - mr / 4, max(1, mr / 4), C(0xBCC2AA)); c.circle(mx + mr / 3, my + mr / 3, max(1, mr / 5), C(0xBCC2AA))
        wisp(c, mx, my + mr / 3, mr * 4, C(0x2A2A30, 0.55), s: s)
        // haze clouds
        for i in 0..<(tall ? 12 : 5) {
            let x = Int(noise(i * 5 + 420) * Double(c.w)), y = Int((0.15 + noise(i * 5 + 421) * 0.6) * Double(wt))
            wisp(c, x, y, (40 + Int(noise(i * 5 + 422) * 80.0)) * s, C(0x5A6650, 0.16), s: (tall ? 2 : 1) * s)
        }
        if tall { dolGuldurEye(c, g) }
        // the dead forest far below the hill, bare tops bristling
        let ft = tall ? Int(Double(g) * 0.66) : wt - 5 * s
        c.dunes(base: ft, amp: Double(2 * s), freq: 0.05, phase: 0.7, bottom: g, C(0x1E241C))
        for i in 0..<(c.w / (3 * s)) {
            let x = Int(noise(i * 3 + 430) * Double(c.w)), hgt = (2 + Int(noise(i * 3 + 431) * 5.0)) * s
            r7Line(c, x, ft + 2 * s, x + Int((noise(i * 3 + 432) - 0.5) * 3.0) * s, ft + 2 * s - hgt, C(0x1E241C), s: 1)
        }
        c.rect(0, ft - 3 * s, c.w, 4 * s, C(0x6A7858, 0.12))
        for t in dolGuldurTowers(c, g) { dolGuldurTower(c, g, t) }
        dolGuldurWall(c, g)
        // haze drifting round the feet of the towers
        for i in 0..<(tall ? 10 : 5) {
            let x = Int(noise(i * 5 + 440) * Double(c.w)), y = wt - Int(noise(i * 5 + 441) * Double(tall ? g / 4 : 10 * s))
            wisp(c, x, y, (50 + Int(noise(i * 5 + 442) * 90.0)) * s, C(0x6A7858, 0.14), s: (tall ? 2 : 1) * s)
        }
        // dead trees in the courtyard, webs in their forks
        let trees: [(Double, Double, Int)] = [(0.045, tall ? 0.6 : 0.75, 451), (0.95, tall ? 0.48 : 0.62, 452)]
        for (xs, hs, seed) in trees {
            let forks = r7DeadTree(c, Int(Double(c.w) * xs), g, Int(Double(g) * hs), s: s, seed: seed, limbs: tall ? 5 : 4,
                                   C(0x0E0C10), lit: C(0x3A3842))
            for (j, f) in forks.enumerated() where j % 2 == 1 { r7Web(c, hub: f.hub, f.a, f.b, C(0x8A8C94, 0.28)) }
        }
        // rubble fallen from the wall
        for i in 0..<(c.w / (40 * s)) {
            let x = Int(noise(i * 3 + 460) * Double(c.w)), bw = (2 + Int(noise(i * 3 + 461) * 4.0)) * s
            let bh = (1 + Int(noise(i * 3 + 462) * 2.0)) * s
            c.rect(x, g - bh, bw, bh, C(0x24222A)); c.rect(x, g - bh, bw, s, C(0x3A3842))
        }
        // the flagstones, cracked
        c.ground(g, C(0x2C2826), edge: C(0x4A4440), speck: C(0x24201E), seed: 91)
        for (j, y) in stride(from: g + 3 * s, to: c.h, by: 4 * s).enumerated() {
            c.rect(0, y, c.w, max(1, s / 2), C(0x1C1918))
            for x in stride(from: (j % 2) * 7 * s, to: c.w, by: 14 * s) { c.rect(x, y - 4 * s + s, max(1, s / 2), 3 * s, C(0x1C1918)) }
        }
        for i in 0..<(c.w / (50 * s)) {
            var x = Int(noise(i * 3 + 470) * Double(c.w)), y = g + s
            for k in 0..<max(0, c.h - g - s) {
                c.px(x, y, C(0x141212)); y += 1
                if noise(i * 71 + k) > 0.55 { x += noise(i * 71 + k + 3) > 0.5 ? 1 : -1 }
            }
        }
    }

    /// One tower: tapering black masonry lit along its left side by the moon, thorn-like spikes jutting up its
    /// flanks, a jagged broken top with a shard or two still standing, and slit windows. Far ones fade into the haze.
    static func dolGuldurTower(_ c: PixelCanvas, _ g: Int, _ t: (x: Int, w: Int, top: Int, haze: Double)) {
        let s = unit(g), wt = dolGuldurWallTop(c, g), hz = C(0x4A5444)
        let body = lerp(C(0x16141A), hz, t.haze * 0.6), lit = lerp(C(0x3A3844), hz, t.haze * 0.6)
        let shade = lerp(C(0x0C0A0E), hz, t.haze * 0.6), mortar = lerp(C(0x100E14), hz, t.haze * 0.6)
        let base = wt + 2 * s, span = max(1, base - t.top)
        func half(_ y: Int) -> Int { t.w / 2 + (y - t.top) * t.w / (6 * span) }
        // the broken top: each column of the crown stops at its own ragged height
        for dx in -t.w / 2..<max(-t.w / 2, t.w / 2 + 1) {
            let n = noise(dx / max(1, 2 * s) + t.x + 480)
            let top = t.top + Int(n * Double(t.w) * 0.9)
            for y in top..<max(top, base) {
                let h = half(y), x = t.x + dx * h / max(1, t.w / 2)
                c.rect(x, y, max(1, h / max(1, t.w / 2)), 1, dx > t.w / 4 ? shade : body)
            }
        }
        // shards still standing on the crown
        for k in 0..<3 {
            let sx = t.x + Int((noise(t.x + k * 3 + 490) - 0.5) * Double(t.w) * 0.7)
            let sh = Int((0.6 + noise(t.x + k * 3 + 491) * 1.0) * Double(t.w)), sw = max(s, t.w / 6)
            for j in 0..<max(0, sh) {
                let w = max(1, sw * (sh - j) / max(1, sh))
                c.rect(sx - w / 2, t.top + t.w / 6 - j, w, 1, body)
            }
        }
        // the moonlit edge and the masonry
        for y in t.top..<max(t.top, base) {
            let h = half(y)
            c.rect(t.x - h, y, s, 1, lit)
            if (y - t.top) % (4 * s) == 0, y > t.top + t.w / 2 { c.rect(t.x - h + s, y, 2 * h - s, max(1, s / 2), mortar) }
        }
        // thorns jutting up and out of the flanks
        for (k, y) in stride(from: t.top + t.w / 2 + 3 * s, to: wt, by: max(4 * s, t.w)).enumerated() {
            let len = max(2 * s, t.w / 6) + Int(noise(t.x + k + 500) * Double(t.w) / 8)
            for side in [-1, 1] where noise(t.x + k * 2 + side + 505) > 0.3 {
                let h = half(y)
                r7Line(c, t.x + side * h, y, t.x + side * (h + len), y - len * 3 / 2, body, s: s)
            }
        }
        // slit windows, a few glowing a sickly green
        for i in 0..<max(0, span / (14 * s)) {
            let y = t.top + t.w / 2 + 4 * s + Int(noise(t.x + i * 3 + 510) * Double(max(1, span - t.w / 2 - 12 * s)))
            let x = t.x + Int((noise(t.x + i * 3 + 511) - 0.5) * Double(t.w) * 0.5)
            let glow = noise(t.x + i * 3 + 512) > 0.65
            c.rect(x, y, s, 3 * s, glow ? C(0x8AAA6A, 0.75 - t.haze * 0.5) : C(0x06050A))
            c.px(x, y - 1, glow ? C(0x8AAA6A, 0.4) : C(0x06050A))
            if glow { c.circle(x, y + s, 3 * s, C(0x8AAA6A, 0.08)) }
        }
    }

    /// The courtyard's back wall: broken crenellations, two breaches down nearly to the flagstones, courses of
    /// masonry and a row of spikes along what's left of the parapet.
    static func dolGuldurWall(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), wt = dolGuldurWallTop(c, g), wh = g - wt
        let body = C(0x221F26), lit = C(0x403C48), mortar = C(0x18161C)
        let breaches: [(x: Int, half: Int)] = [(Int(Double(c.w) * 0.39), 14 * s), (Int(Double(c.w) * 0.79), 10 * s)]
        var tops: [Int] = []
        for x in 0..<c.w {
            var top = wt - (((x + 2 * s) / (5 * s)) % 2 == 0 && noise(x / (5 * s) + 520) > 0.3 ? 3 * s : 0)
            top += Int(noise(x / max(1, s) + 525) * 1.5)
            for b in breaches where abs(x - b.x) < b.half {
                let k = 1 - Double(abs(x - b.x)) / Double(b.half)
                top = max(top, wt + Int(k * Double(wh) * 0.75) + Int(noise(x + 530) * Double(2 * s)))
            }
            tops.append(top)
            if top < g { c.rect(x, top, 1, g - top, body); c.px(x, top, lit) }
        }
        // courses of masonry
        for (j, y) in stride(from: wt + 3 * s, to: g, by: 3 * s).enumerated() {
            for x in 0..<c.w where tops[x] < y { c.px(x, y, mortar) }
            for x in stride(from: (j % 2) * 4 * s, to: c.w, by: 8 * s) where tops[x] < y - 3 * s {
                c.rect(x, y - 3 * s + 1, 1, 3 * s - 1, mortar)
            }
        }
        // spikes along the parapet
        for x in stride(from: 3 * s, to: c.w, by: 11 * s) where tops[x] <= wt {
            r7Line(c, x, tops[x], x - s, tops[x] - 4 * s, body, s: s)
        }
    }

    /// Tall screens: a faint fiery eye in the haze between the towers, its slit black.
    static func dolGuldurEye(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), x = Int(Double(c.w) * 0.395), y = Int(Double(g) * 0.22)
        c.ellipse(x, y, 34 * s, 12 * s, C(0xE8501E, 0.05))
        c.ellipse(x, y, 24 * s, 7 * s, C(0xE8501E, 0.07))
        c.ellipse(x, y, 14 * s, 4 * s, C(0xFFB03A, 0.08))
        c.rect(x - s, y - 6 * s, 2 * s, 12 * s, C(0x0A0608, 0.3))
        wisp(c, x + 6 * s, y + 3 * s, 60 * s, C(0x5A6650, 0.2), s: 2 * s)
    }
}

// MARK: - Go-blin Town

extension Scenes {
    /// The walkways: left and right edge, deck row, and how deep in the dark (0 near). Higher ones are further off.
    static func goblinTownWalks(_ c: PixelCanvas, _ g: Int) -> [(x0: Int, x1: Int, y: Int, dim: Double)] {
        let s = unit(g), w = Double(c.w)
        // (left, right as shares of the width, deck row, dimness)
        var list: [(Double, Double, Int, Double)]
        if isTall(c) {
            let gd = Double(g)
            list = [
                (0.36, 0.64, Int(gd * 0.25), 0.55),
                (0.02, 0.22, Int(gd * 0.36), 0.5), (0.74, 0.97, Int(gd * 0.4), 0.5),
                (0.12, 0.42, Int(gd * 0.52), 0.42), (0.58, 0.9, Int(gd * 0.56), 0.42),
                (-0.05, 0.2, Int(gd * 0.7), 0.32), (0.34, 0.66, Int(gd * 0.68), 0.32), (0.8, 1.05, Int(gd * 0.74), 0.32),
                (0.15, 0.4, Int(gd * 0.86), 0.2), (0.62, 0.88, Int(gd * 0.88), 0.2),
            ]
        } else {
            list = [
                (-0.04, 0.27, g - 34 * s, 0.45), (0.46, 0.76, g - 36 * s, 0.45), (0.86, 1.04, g - 30 * s, 0.45),
                (0.18, 0.4, g - 17 * s, 0.25), (0.6, 0.86, g - 19 * s, 0.25),
            ]
        }
        return list.map { (Int($0.0 * w), Int($0.1 * w), $0.2, $0.3) }
    }

    /// Go-blin Town: the cavern under the Misty Mountains, black overhead with stalactites hanging from the roof.
    /// Rickety walkways on spindly posts are strung across the dark, joined by sagging rope bridges and ladders,
    /// with torches burning on their posts, chains and a cage hanging from the roof and goblin junk piled on the
    /// decks. The crew stands on a broad platform of rough planks. On tall screens the walkways stack up into the dark
    /// level on level, and high up at the top sits the Go-blin King's throne between two torches.
    static func goblinTown(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        c.gradient(0, g, C(0x0C0907), C(0x1E1610), bands: tall ? 10 : 6)
        // the far cave wall, barely there
        for i in 0..<max(0, c.w * g / (220 * s)) {
            let x = Int(noise(i * 4 + 540) * Double(c.w)), y = Int(noise(i * 4 + 541) * Double(g))
            let len = (3 + Int(noise(i * 4 + 542) * 9.0)) * s
            c.rect(x, y, len, s, C(0x2A2016, 0.25 + 0.4 * Double(y) / Double(max(1, g))))
        }
        let walks = goblinTownWalks(c, g)
        // what joins the walkways: rope bridges along a level, ladders between levels
        for (a, b) in zip(walks, walks.dropFirst()) where a.dim == b.dim && b.x0 > a.x1 {
            goblinTownBridge(c, g, a.x1, a.y, b.x0, b.y, dim: a.dim)
        }
        for (i, a) in walks.enumerated() {
            if let b = walks.first(where: { $0.y > a.y + 8 * s && $0.x0 < a.x1 - 6 * s && $0.x1 > a.x0 + 6 * s }) {
                let lx = max(a.x0, b.x0) + 4 * s + Int(noise(i + 550) * Double(max(1, min(a.x1, b.x1) - max(a.x0, b.x0) - 8 * s)))
                goblinTownLadder(c, g, lx, a.y, b.y, dim: (a.dim + b.dim) / 2)
            }
        }
        for (i, wk) in walks.enumerated() { goblinTownWalk(c, g, wk, seed: i) }
        if tall { goblinTownThrone(c, g) }
        goblinTownRoof(c, g)
        // the chasm under the platform's edge, falling away into black
        let fade = min(g, (tall ? 26 : 8) * s)
        for y in (g - fade)..<g {
            c.rect(0, y, c.w, 1, C(0x050403, 0.7 * Double(y - g + fade) / Double(max(1, fade))))
        }
        // the platform: rough planks, butted at staggered joints and nailed
        c.rect(0, g, c.w, c.h - g, C(0x4E3A26))
        for (j, y) in stride(from: g, to: c.h, by: 4 * s).enumerated() {
            c.rect(0, y + 3 * s, c.w, s, C(0x2A1E14))
            var x = Int(noise(j * 7 + 560) * Double(20 * s))
            while x < c.w {
                c.rect(x, y, s, 3 * s, C(0x2A1E14))
                c.px(x + s, y + s, C(0x8A7458)); c.px(x - s - 1, y + s, C(0x8A7458))
                x += (24 + Int(noise(j * 7 + x + 561) * 30.0)) * s
            }
        }
        for i in 0..<(c.w * (c.h - g) / max(1, 12 * s)) {
            let x = Int(noise(i * 2 + 570) * Double(c.w)), y = g + Int(noise(i * 2 + 571) * Double(max(1, c.h - g)))
            c.rect(x, y, 2 * s, 1, C(0x3E2E1E))
        }
        c.rect(0, g, c.w, s, C(0x7E6040))
    }

    /// The colour `p` sunk `dim` of the way into the dark.
    static func goblinTownDim(_ p: Px, _ dim: Double) -> Px { lerp(p, C(0x0A0806), dim) }

    /// One walkway: a plank deck on spindly posts running down into the dark, cross-braced, with a rope rail on
    /// stakes, a torch on one of its posts and a bit of junk on the deck.
    static func goblinTownWalk(_ c: PixelCanvas, _ g: Int, _ wk: (x0: Int, x1: Int, y: Int, dim: Double), seed: Int) {
        let s = unit(g), d = { (p: Px) in goblinTownDim(p, wk.dim) }
        guard wk.x1 > wk.x0 else { return }
        // posts and braces
        let posts = Array(stride(from: wk.x0 + 3 * s, to: wk.x1 - 2 * s, by: 15 * s))
        for x in posts { c.rect(x, wk.y + 2 * s, 2 * s, g - wk.y, d(C(0x3E2C1C))); c.px(x, wk.y + 2 * s, d(C(0x5E4630))) }
        for (a, b) in zip(posts, posts.dropFirst()) {
            r7Line(c, a + 2 * s, wk.y + 3 * s, b, wk.y + 3 * s + (b - a) * 2 / 3, d(C(0x35261A)), s: s)
            r7Line(c, b, wk.y + 3 * s, a + 2 * s, wk.y + 3 * s + (b - a) * 2 / 3, d(C(0x35261A)), s: s)
        }
        // the deck
        c.rect(wk.x0, wk.y, wk.x1 - wk.x0, 3 * s, d(C(0x5E4630)))
        c.rect(wk.x0, wk.y, wk.x1 - wk.x0, s, d(C(0x8A6A46)))
        c.rect(wk.x0, wk.y + 2 * s, wk.x1 - wk.x0, s, d(C(0x3A2A1A)))
        for x in stride(from: wk.x0 + Int(noise(seed + 580) * Double(5 * s)), to: wk.x1, by: 5 * s) {
            c.rect(x, wk.y + s, max(1, s), s, d(C(0x3A2A1A)))
        }
        // the rail: stakes and a sagging rope
        let stakes = Array(stride(from: wk.x0 + s, to: wk.x1, by: 12 * s))
        for x in stakes { c.rect(x, wk.y - 6 * s, s, 6 * s, d(C(0x4A3622))) }
        for (a, b) in zip(stakes, stakes.dropFirst()) { r7Sag(c, a, wk.y - 5 * s, b, wk.y - 5 * s, sag: 2 * s, d(C(0x8A7650)), s: max(1, s / 2 + s / 2)) }
        // junk on the deck
        let jx = wk.x0 + Int((0.15 + noise(seed + 585) * 0.7) * Double(wk.x1 - wk.x0))
        goblinTownJunk(c, g, jx, wk.y, kind: seed % 3, dim: wk.dim)
        // a torch on a post
        if let tx = posts.dropFirst(seed % 2).first { goblinTownTorch(c, g, tx + s, wk.y - 2 * s, dim: wk.dim * 0.6) }
    }

    /// Junk on a deck standing on row `y`: a barrel and a crate, a crude shield propped up, or a skull on a pike.
    static func goblinTownJunk(_ c: PixelCanvas, _ g: Int, _ x: Int, _ y: Int, kind: Int, dim: Double) {
        let s = unit(g), d = { (p: Px) in goblinTownDim(p, dim) }
        switch kind {
        case 0:
            c.rect(x, y - 6 * s, 5 * s, 6 * s, d(C(0x5A3E24)))
            c.rect(x, y - 5 * s, 5 * s, s, d(C(0x3A3A3E))); c.rect(x, y - 2 * s, 5 * s, s, d(C(0x3A3A3E)))
            c.rect(x + 6 * s, y - 4 * s, 4 * s, 4 * s, d(C(0x6A5034)))
            r7Line(c, x + 6 * s, y - 4 * s, x + 9 * s, y - s, d(C(0x3E2C1C)), s: s)
        case 1:
            c.circle(x + 3 * s, y - 4 * s, 4 * s, d(C(0x4A3A2E)))
            c.circle(x + 3 * s, y - 4 * s, 3 * s, d(C(0x6A4A2E)))
            c.circle(x + 3 * s, y - 4 * s, s, d(C(0x8A8A8E)))
            r7Line(c, x + 9 * s, y - s, x + 13 * s, y - 9 * s, d(C(0x7A7A80)), s: s)
        default:
            c.rect(x, y - 12 * s, s, 12 * s, d(C(0x4A3622)))
            c.rect(x - s, y - 15 * s, 3 * s, 3 * s, d(C(0xC8BCA0)))
            c.px(x - s, y - 14 * s, d(C(0x1A1410))); c.px(x + s, y - 14 * s, d(C(0x1A1410)))
            c.rect(x + 3 * s, y - 3 * s, 4 * s, 3 * s, d(C(0x5A3E24)))
        }
    }

    /// A torch: a stick with a flame on top, and its warm glow on the dark round it.
    static func goblinTownTorch(_ c: PixelCanvas, _ g: Int, _ x: Int, _ y: Int, dim: Double) {
        let s = unit(g), d = { (p: Px) in goblinTownDim(p, dim) }
        r7Glow(c, x, y - 6 * s, 16 * s, C(0xE8801E), 0.05 * (1 - dim))
        c.rect(x - s / 2, y - 5 * s, s, 6 * s, d(C(0x3A2A1A)))
        c.rect(x - s, y - 6 * s, 2 * s, s, d(C(0x5A5A5E)))
        c.rect(x - s, y - 9 * s, 2 * s, 3 * s, d(C(0xE8701E)))
        c.rect(x - s / 2, y - 11 * s, s, 2 * s, d(C(0xE8701E)))
        c.rect(x - s / 2, y - 8 * s, s, 2 * s, d(C(0xFFD060)))
    }

    /// A rope bridge sagging from one walkway to the next: a deck of slats on its foot ropes, a hand rope above, and
    /// the cords between.
    static func goblinTownBridge(_ c: PixelCanvas, _ g: Int, _ x0: Int, _ y0: Int, _ x1: Int, _ y1: Int, dim: Double) {
        let s = unit(g), d = { (p: Px) in goblinTownDim(p, dim) }
        let sag = max(2 * s, (x1 - x0) / 7)
        let deck = r7Sag(c, x0, y0, x1, y1, sag: sag, d(C(0x8A7650)), s: s)
        let hand = r7Sag(c, x0, y0 - 6 * s, x1, y1 - 6 * s, sag: sag, d(C(0x8A7650)), s: max(1, s / 2 + s / 2))
        for i in stride(from: 0, to: deck.count, by: 3 * s) { c.rect(x0 + i, deck[i] - s, 2 * s, 2 * s, d(C(0x6A5034))) }
        for i in stride(from: 2 * s, to: min(deck.count, hand.count), by: 6 * s) {
            c.rect(x0 + i, hand[i], 1, max(1, deck[i] - hand[i]), d(C(0x6E5E40)))
        }
    }

    /// A ladder from a walkway at row `top` down to one at row `bottom`.
    static func goblinTownLadder(_ c: PixelCanvas, _ g: Int, _ x: Int, _ top: Int, _ bottom: Int, dim: Double) {
        let s = unit(g), d = { (p: Px) in goblinTownDim(p, dim) }
        guard bottom > top else { return }
        c.rect(x, top - 3 * s, s, bottom - top + 3 * s, d(C(0x5E4630)))
        c.rect(x + 5 * s, top - 3 * s, s, bottom - top + 3 * s, d(C(0x4A3622)))
        for y in stride(from: top + s, to: bottom, by: 3 * s) { c.rect(x, y, 6 * s, s, d(C(0x6A5034))) }
    }

    /// The cavern roof: a ragged band of rock with stalactites hanging from it, chains dangling, and a cage.
    static func goblinTownRoof(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c)
        let rock = C(0x1A140E), lit = C(0x3A2C1E)
        let band = (tall ? 8 : 3) * s
        for x in 0..<c.w { c.rect(x, 0, 1, band + Int(noise(x / max(1, 3 * s) + 590) * Double(3 * s)), rock) }
        for i in 0..<(c.w / (7 * s)) {
            let x = Int(noise(i * 3 + 600) * Double(c.w))
            let len = Int((tall ? 10.0 + noise(i * 3 + 601) * 60 : 4.0 + noise(i * 3 + 601) * 16) * Double(s))
            let wd = max(s, len / 4)
            for k in 0..<max(0, len) {
                let hw = wd * (len - k) / max(1, len)
                c.rect(x - hw, band + k, hw * 2 + 1, 1, rock)
                c.px(x - hw, band + k, lit)
            }
        }
        // chains hanging from the roof, some with a hook
        for i in 0..<(tall ? 8 : 4) {
            let x = Int(noise(i * 3 + 610) * Double(c.w))
            let len = Int((tall ? 0.1 + noise(i * 3 + 611) * 0.25 : 0.2 + noise(i * 3 + 611) * 0.3) * Double(g))
            for y in stride(from: band, to: band + len, by: 2 * s) {
                c.rect(x, y, s, s, C(0x4A4A4E)); c.rect(x + ((y / (2 * s)) % 2 == 0 ? -s : s), y + s, s, s, C(0x34343A))
            }
            if i % 2 == 0 { r7Line(c, x, band + len, x + 2 * s, band + len + 2 * s, C(0x5A5A5E), s: s) }
        }
        // the cage
        let cx = Int(Double(c.w) * (tall ? 0.76 : 0.58)), cw = (tall ? 12 : 8) * s, ch = (tall ? 16 : 10) * s
        let cy = band + (tall ? Int(Double(g) * 0.12) : 9 * s)
        for y in stride(from: band, to: cy, by: 2 * s) { c.rect(cx, y, s, s, C(0x4A4A4E)) }
        c.ellipse(cx, cy + s, cw / 2, 2 * s, C(0x3A3A3E))
        c.rect(cx - cw / 2, cy + s, cw + 1, ch, C(0x0A0806, 0.5))
        for x in stride(from: cx - cw / 2, through: cx + cw / 2, by: 2 * s) { c.rect(x, cy + s, s, ch, C(0x3A3A3E)) }
        c.rect(cx - cw / 2, cy + ch, cw + s, 2 * s, C(0x2E2E32))
        c.rect(cx - cw / 2, cy + ch / 2, cw + s, s, C(0x2E2E32))
    }

    /// Tall screens: the Go-blin King's throne on the highest platform, a heap of crude timber and bone with a jagged
    /// back, a skull on top, steps up to it and a torch either side.
    static func goblinTownThrone(_ c: PixelCanvas, _ g: Int) {
        // drawn in double units so it reads from the bottom of a tall screen
        let s = unit(g), u = 2 * s, dim = 0.3, d = { (p: Px) in goblinTownDim(p, dim) }
        let x = c.w / 2, y = Int(Double(g) * 0.25)
        let wood = d(C(0x5A4028)), dark = d(C(0x3A2A1A)), bone = d(C(0xC8BCA0)), lit = d(C(0x8A6A46))
        r7Glow(c, x, y - 12 * u, 26 * u, C(0xE8801E), 0.03)
        // the back: rough planks of uneven heights, each topped with a bone spike
        for k in 0..<9 {
            let px = x - 11 * u + k * 5 * u / 2, hgt = (12 + Int(noise(k + 620) * 5.0) - abs(k - 4)) * u
            c.rect(px, y - 6 * u - hgt, 2 * u, hgt, k % 2 == 0 ? wood : dark)
            c.rect(px, y - 6 * u - hgt, s, hgt, lit)
            c.rect(px + s, y - 6 * u - hgt - 2 * u, s, 2 * u, bone)
        }
        // lashings across the back
        c.rect(x - 11 * u, y - 13 * u, 22 * u, s, d(C(0x8A7650))); c.rect(x - 11 * u, y - 19 * u, 22 * u, s, d(C(0x8A7650)))
        // the skull on top
        let sy = y - 30 * u
        c.rect(x - 3 * u, sy, 6 * u, 5 * u, bone); c.rect(x - 2 * u, sy + 5 * u, 4 * u, 2 * u, bone)
        c.rect(x - 2 * u, sy + 2 * u, u, 2 * u, d(C(0x1A1410))); c.rect(x + u, sy + 2 * u, u, 2 * u, d(C(0x1A1410)))
        c.rect(x - s / 2, sy + 4 * u, s, u, d(C(0x1A1410)))
        // seat and arms, with bones lashed on
        c.rect(x - 13 * u, y - 7 * u, 26 * u, 3 * u, wood); c.rect(x - 13 * u, y - 7 * u, 26 * u, s, lit)
        for side in [-1, 1] {
            let ax = side < 0 ? x - 15 * u : x + 11 * u
            c.rect(ax, y - 12 * u, 4 * u, 8 * u, dark); c.rect(ax - s, y - 13 * u, 4 * u + 2 * s, 2 * s, bone)
            c.rect(ax + u, y - 14 * u, 2 * u, u, bone)
        }
        c.rect(x - 12 * u, y - 4 * u, 3 * u, 4 * u, dark); c.rect(x + 9 * u, y - 4 * u, 3 * u, 4 * u, dark)
        // the step in front
        c.rect(x - 16 * u, y - u, 32 * u, u, wood); c.rect(x - 16 * u, y - u, 32 * u, s, lit)
        // torches either side on tall stakes
        for side in [-1, 1] {
            let tx = x + side * 21 * u
            c.rect(tx - s / 2, y - 14 * u, s, 14 * u, dark)
            goblinTownTorch(c, g, tx, y - 14 * u, dim: 0.1)
        }
    }
}
