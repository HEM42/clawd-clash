import Foundation

// Places from Alice in Wonderland, Frankenweenie and Pee-wee's Big Adventure: the mad tea party under the dead tree,
// the Red Queen's castle at Salazen Grum, Victor's attic lab in New Holland, the windmill mini-golf above the fair,
// and Pee-wee's toy-crammed kitchen with his breakfast machine.

let burtonScenes6: [Location: Place] = [
    .madTeaParty: Place(name: "The Mad Tea Party", panel: 0x0E221E, still: Scenes.madTeaParty,
                        moving: Scenes.madTeaPartyLife),
    .salazenGrum: Place(name: "The Red Queen's Castle", panel: 0x1E0C10, still: Scenes.salazenGrum,
                        moving: Scenes.salazenGrumLife),
    .newHollandAttic: Place(name: "Victor's Attic Lab, New Holland", panel: 0x141414, still: Scenes.newHollandAttic,
                            moving: Scenes.newHollandAtticLife),
    .windmillMiniGolf: Place(name: "The Windmill Mini-Golf", panel: 0x161616, still: Scenes.windmillMiniGolf,
                             moving: Scenes.windmillMiniGolfLife),
    .breakfastMachineHouse: Place(name: "Pee-wee's House", panel: 0x1A2A50, still: Scenes.breakfastMachineHouse,
                                  moving: Scenes.breakfastMachineHouseLife),
]

// MARK: - The Mad Tea Party

extension Scenes {
    /// Where things stand at the tea party: the size unit of the near things, the table's ends and top row, the dead
    /// tree's foot and the windmill's middle.
    static func tpFrame(_ c: PixelCanvas, _ g: Int) -> (k: Int, x0: Int, x1: Int, top: Int, tree: Int, mill: Int) {
        let s = unit(g), k = (isTall(c) ? 2 : 1) * s
        return (k, c.w * 25 / 100, c.w * 84 / 100, g - 11 * k, c.w * 9 / 100, c.w * (isTall(c) ? 89 : 92) / 100)
    }

    /// The china along the table, left to right: what each piece is (0 a teapot, 1 a cup on its saucer, 2 a wobbly
    /// stack of cups, 3 a cake stand, 4 a milk jug), where it stands and its colour.
    static func tpChina(_ f: (k: Int, x0: Int, x1: Int, top: Int, tree: Int, mill: Int))
        -> [(kind: Int, x: Int, col: Px)] {
        let cols = [C(0xE07AA8), C(0x3AB8A8), C(0xE8C040), C(0x8A5AC8), C(0xECE8DC), C(0x4A7AD8), C(0xE8743A)]
        let kinds = [0, 1, 2, 1, 0, 3, 1, 4, 0, 1, 2, 0, 1, 3, 1, 0, 4, 1, 2, 0, 1, 3, 0, 1]
        var out: [(kind: Int, x: Int, col: Px)] = [], x = f.x0 + 5 * f.k, i = 0
        while x < f.x1 - 5 * f.k {
            let kind = kinds[i % kinds.count]
            out.append((kind, x, cols[(i * 3 + Int(noise(i + 6100) * 4)) % cols.count]))
            x += ([11, 7, 7, 10, 8][kind] + Int(noise(i + 6110) * 3)) * f.k; i += 1
        }
        return out
    }

    /// Which cup rattles (drawn by the moving layer, not the still picture).
    static func tpRattler(_ china: [(kind: Int, x: Int, col: Px)]) -> Int {
        china.indices.filter { china[$0].kind == 1 }.dropFirst(2).first ?? -1
    }

    /// A teapot standing on row `base`: a round body with a lid and knob, a curved handle behind and a spout reaching
    /// up to the right; returns the spout's tip, where the steam comes out.
    @discardableResult
    static func tpTeapot(_ c: PixelCanvas, x: Int, base: Int, k: Int, _ col: Px) -> (x: Int, y: Int) {
        let shade = lerp(col, C(0x10201C), 0.35), lit = lerp(col, C(0xFFFFFF), 0.35)
        c.rect(x - 7 * k, base - 6 * k, k, 4 * k, shade); c.rect(x - 7 * k, base - 6 * k, 3 * k, k, shade)
        c.rect(x - 7 * k, base - 3 * k, 3 * k, k, shade)
        burtonLine(c, Double(x + 3 * k), Double(base - 3 * k), Double(x + 7 * k), Double(base - 7 * k), col,
                   Double(k) * 0.7)
        c.ellipse(x, base - 3 * k, 5 * k, 3 * k, col)
        c.ellipse(x + k, base - 2 * k, 4 * k, 2 * k, shade); c.ellipse(x, base - 3 * k, 4 * k, 2 * k, col)
        c.rect(x - 3 * k, base - 5 * k, 2 * k, k, lit)
        c.rect(x - 3 * k, base - 7 * k, 6 * k, k, col); c.rect(x - k, base - 8 * k, 2 * k, k, shade)
        return (x + 7 * k, base - 8 * k)
    }

    /// A teacup on its saucer, standing on row `base`.
    static func tpCup(_ c: PixelCanvas, x: Int, base: Int, k: Int, _ col: Px) {
        c.rect(x - 3 * k, base - k, 7 * k, k, lerp(col, C(0xFFFFFF), 0.3))
        c.rect(x - 2 * k, base - 4 * k, 4 * k, 3 * k, col)
        c.rect(x + k, base - 4 * k, k, 3 * k, lerp(col, C(0x10201C), 0.3))
        c.rect(x + 2 * k, base - 4 * k, k, k, col); c.rect(x + 3 * k, base - 3 * k, k, k, col)
        c.rect(x - 2 * k, base - 4 * k, 4 * k, k, lerp(col, C(0xFFFFFF), 0.3))
    }

    /// One piece of china on the table (see `tpChina`).
    private static func tpPiece(_ c: PixelCanvas, _ p: (kind: Int, x: Int, col: Px), base: Int, k: Int, i: Int) {
        let cols = [C(0xE07AA8), C(0x3AB8A8), C(0xE8C040), C(0x8A5AC8), C(0xECE8DC)]
        switch p.kind {
        case 0: tpTeapot(c, x: p.x, base: base, k: k, p.col)
        case 1: tpCup(c, x: p.x, base: base, k: k, p.col)
        case 2:   // cups stacked crooked, every one a different set
            for n in 0..<4 {
                tpCup(c, x: p.x + (n % 2 == 0 ? 0 : (i % 2 == 0 ? k : -k)), base: base - n * 4 * k, k: k,
                      cols[(i + n) % cols.count])
            }
        case 3:   // a cake stand: two plates on a stem, little cakes on them
            c.rect(p.x, base - 10 * k, k, 10 * k, C(0xC8B060)); c.rect(p.x - 2 * k, base - k, 5 * k, k, C(0xC8B060))
            c.rect(p.x - 5 * k, base - 5 * k, 11 * k, k, C(0xECE8DC))
            c.rect(p.x - 3 * k, base - 10 * k, 7 * k, k, C(0xECE8DC))
            for n in 0..<4 {
                c.rect(p.x - 4 * k + n * 3 * k, base - 7 * k, 2 * k, 2 * k, [C(0xF09AC0), C(0xF0D060)][n % 2])
            }
            for n in 0..<2 {
                c.rect(p.x - 2 * k + n * 3 * k, base - 12 * k, 2 * k, 2 * k, [C(0x9AD860), C(0xF09AC0)][n])
            }
        default:   // a tall milk jug with a lip
            c.rect(p.x - 2 * k, base - 7 * k, 4 * k, 7 * k, p.col)
            c.rect(p.x + k, base - 7 * k, k, 7 * k, lerp(p.col, C(0x10201C), 0.3))
            c.rect(p.x - 3 * k, base - 8 * k, 2 * k, k, p.col); c.rect(p.x + 2 * k, base - 6 * k, k, 3 * k, p.col)
        }
    }

    /// A gnarled branch from (x, y) heading `angle` degrees, kinked half way, forking `depth` more times.
    private static func tpBranch(_ c: PixelCanvas, _ x: Double, _ y: Double, angle: Double, len: Double, r: Double,
                                 depth: Int, seed: Int, _ col: Px) {
        let mid = burtonReach((x, y), angle + (noise(seed) - 0.5) * 40, len / 2)
        let end = burtonReach(mid, angle + (noise(seed + 1) - 0.5) * 30, len / 2)
        burtonLine(c, x, y, mid.x, mid.y, col, r); burtonLine(c, mid.x, mid.y, end.x, end.y, col, max(0.5, r * 0.8))
        guard depth > 0 else { return }
        for (n, turn) in [-28.0, 24.0].enumerated() {
            tpBranch(c, end.x, end.y, angle: angle + turn + (noise(seed + 2 + n) - 0.5) * 30, len: len * 0.66,
                     r: max(0.5, r * 0.62), depth: depth - 1, seed: seed * 3 + n + 7, col)
        }
    }

    /// The dead tree over the head of the table: a thick twisted trunk with roots, its bare branches reaching out over
    /// the china; `th` is the trunk's height.
    private static func tpTree(_ c: PixelCanvas, x: Int, base: Int, th: Int, k: Int) {
        let bark = C(0x3A3034), lit = C(0x6A5C58)
        let top = (x: Double(x + 3 * k), y: Double(base - th))
        for (dx, col) in [(-k, lit), (0, bark)] {
            burtonLine(c, Double(x + dx), Double(base), Double(x - k + dx), Double(base - th / 2), col, Double(3 * k))
            burtonLine(c, Double(x - k + dx), Double(base - th / 2), top.x + Double(dx), top.y, col, Double(5 * k) / 2)
        }
        for (dx, dy) in [(-6, 3), (6, 2), (-3, 1)] {
            burtonLine(c, Double(x), Double(base - 3 * k), Double(x + dx * k), Double(base + dy), bark, Double(k))
        }
        for (n, a) in [-150.0, -105.0, -62.0, -28.0].enumerated() {
            let len = Double(th) * [0.55, 0.6, 0.7, 0.85][n]
            tpBranch(c, top.x, top.y, angle: a, len: len, r: Double(2 * k), depth: 3, seed: 6200 + n * 11, bark)
        }
    }

    /// The March Hare's windmill: a crooked stone tower with a straw cap, a door and windows, its four sails set
    /// still.
    private static func tpWindmill(_ c: PixelCanvas, x: Int, base: Int, k: Int) {
        let stone = C(0x6E8676), shade = C(0x4A6052), straw = C(0xA89A58), dark = C(0x1E2A24)
        let h = 28 * k
        for r in 0..<h {
            let half = 8 * k - (3 * k) * r / h, lean = r * r / (h * 6)
            c.rect(x - half + lean, base - r - 1, half * 2, 1, stone)
            c.rect(x + half + lean - 2 * k, base - r - 1, 2 * k, 1, shade)
        }
        c.ellipse(x + 2 * k, base - h, 6 * k, 4 * k, straw)
        c.ellipse(x + 3 * k, base - h + k, 5 * k, 2 * k, C(0x7E7240))
        c.rect(x - 2 * k, base - 7 * k, 4 * k, 7 * k, dark); c.rect(x - k, base - 15 * k, 2 * k, 3 * k, dark)
        let hub = (x: Double(x + 2 * k), y: Double(base - h))
        for a in [-70.0, 20.0, 110.0, 200.0] {
            let e = burtonReach(hub, a, Double(18 * k))
            burtonLine(c, hub.x, hub.y, e.x, e.y, C(0x4A3A2A), Double(k) * 0.6)
            let p = burtonReach(e, a + 90, Double(4 * k))
            let m = burtonReach(hub, a, Double(4 * k))
            let q = burtonReach(m, a + 90, Double(4 * k))
            burtonTriangle(c, (m.x, m.y), (e.x, e.y), (p.x, p.y), C(0xC8C4A8))
            burtonTriangle(c, (m.x, m.y), (q.x, q.y), (p.x, p.y), C(0xC8C4A8))
            for d in [8.0, 13.0] {
                let u = burtonReach(hub, a, Double(k) * d), v = burtonReach(u, a + 90, Double(4 * k))
                burtonLine(c, u.x, u.y, v.x, v.y, C(0x8A8468), Double(k) * 0.5)
            }
        }
        c.circle(Int(hub.x), Int(hub.y), k, C(0x4A3A2A))
    }

    /// A chair behind the table, its back standing above the cloth: an armchair (0), a tall ladder-back (1), a
    /// balloon-back (2) or a gothic one with spikes (3).
    private static func tpChair(_ c: PixelCanvas, x: Int, top: Int, k: Int, kind: Int) {
        switch kind {
        case 0:
            let col = C(0x6A3A8A), lit = C(0x9A6ABA)
            c.rect(x - 6 * k, top - 10 * k, 12 * k, 10 * k, col); c.ellipse(x, top - 10 * k, 6 * k, 3 * k, col)
            c.rect(x - 6 * k, top - 10 * k, k, 10 * k, lit); c.ellipse(x - k, top - 11 * k, 4 * k, k, lit)
            for n in 0..<3 { c.rect(x - 3 * k + n * 3 * k, top - 8 * k + (n % 2) * 2 * k, k, k, C(0x4A2A62)) }
        case 1:
            let wood = C(0x5A3A22)
            c.rect(x - 3 * k, top - 17 * k, k, 17 * k, wood); c.rect(x + 2 * k, top - 17 * k, k, 17 * k, wood)
            for n in 0..<4 { c.rect(x - 3 * k, top - 16 * k + n * 4 * k, 6 * k, k, C(0x7A5232)) }
            c.rect(x - 3 * k, top - 18 * k, k, k, wood); c.rect(x + 2 * k, top - 18 * k, k, k, wood)
        case 2:
            c.rect(x - 3 * k, top - 4 * k, k, 4 * k, C(0x1E5A5A)); c.rect(x + 2 * k, top - 4 * k, k, 4 * k, C(0x1E5A5A))
            c.ellipse(x, top - 8 * k, 4 * k, 5 * k, C(0x2A8A8A)); c.ellipse(x, top - 8 * k, 2 * k, 3 * k, C(0x0E2E2E))
        default:
            let col = C(0xA82A3A)
            c.rect(x - 4 * k, top - 12 * k, 8 * k, 12 * k, col); c.rect(x + 3 * k, top - 12 * k, k, 12 * k, C(0x781A28))
            for n in 0..<3 {
                let px = Double(x - 4 * k + n * 3 * k)
                burtonTriangle(c, (px, Double(top - 12 * k)), (px + Double(2 * k), Double(top - 12 * k)),
                               (px + Double(k), Double(top - (n == 1 ? 18 : 15) * k)), col)
            }
        }
    }

    /// A field of giant chessboard squares stretching to the horizon at row `yh`, fading into the haze, down to row
    /// `y1`, with a far rook and pawn standing on it.
    private static func tpChessField(_ c: PixelCanvas, yh: Int, y1: Int, s: Int, haze: Px) {
        let a = Double(400 * s), f = a * 0.24, cx = Double(c.w) / 2
        for y in yh..<y1 {
            let d = Double(y - yh) + 1, z = a / d
            let row = Int(floor(z))
            for x in 0..<c.w {
                let col = Int(floor((Double(x) - cx) * z / f + 1000))
                let sq = (row + col) % 2 == 0 ? C(0xC8CCA8) : C(0x34504A)
                c.px(x, y, lerp(sq, haze, max(0, 1 - d / Double(90 * s)) * 0.9 + 0.1))
            }
        }
        let ink = lerp(C(0x22342E), haze, 0.45)
        let rook = (x: c.w * 64 / 100, base: yh + 26 * s), pawn = (x: c.w * 30 / 100, base: yh + 16 * s)
        c.rect(rook.x - 5 * s, rook.base - 22 * s, 10 * s, 22 * s, ink)
        c.rect(rook.x - 7 * s, rook.base - 3 * s, 14 * s, 3 * s, ink)
        for n in 0..<3 { c.rect(rook.x - 6 * s + n * 5 * s, rook.base - 26 * s, 3 * s, 4 * s, ink) }
        c.rect(rook.x - 6 * s, rook.base - 23 * s, 12 * s, 2 * s, ink)
        c.rect(pawn.x - 2 * s, pawn.base - 9 * s, 4 * s, 9 * s, ink)
        c.rect(pawn.x - 4 * s, pawn.base - 2 * s, 8 * s, 2 * s, ink)
        c.circle(pawn.x, pawn.base - 11 * s, 3 * s, ink)
    }

    /// The mad tea party in Underland: a sickly green-teal sky, a long table with a white cloth running under a dead
    /// tree, crowded with mismatched china (teapots, cups on saucers, crooked stacks of cups, cake stands, milk jugs),
    /// chairs of every kind behind it, and the March Hare's crooked windmill at the far end. On the screen saver,
    /// Underland's strange swirling sky and a field of giant chessboard squares running off to the horizon.
    static func madTeaParty(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = tpFrame(c, g), k = f.k
        let haze = C(0x9CC4A0)
        c.gradient(0, g, C(0x163230), haze, bands: 7)
        // The strange sky: a pale moon in a green halo and slow swirls in the clouds.
        let m = tall ? (x: c.w * 74 / 100, y: g * 22 / 100, r: 18 * s) : (x: c.w * 70 / 100, y: 14 * s, r: 7 * s)
        c.circle(m.x, m.y, m.r + m.r / 2, C(0xD8F0B0, 0.10)); c.circle(m.x, m.y, m.r, C(0xE4ECC4))
        c.circle(m.x - m.r / 3, m.y + m.r / 4, m.r / 4, C(0xC8D4A8))
        c.circle(m.x + m.r / 3, m.y - m.r / 3, m.r / 6, C(0xC8D4A8))
        for i in 0..<5 {
            let x = Double(c.w) * (0.08 + Double(i) * 0.21) + (tall ? 0 : Double(30 * s))
            let y = tall ? Double(g) * (0.12 + noise(i + 6300) * 0.3) : Double((8 + Int(noise(i + 6300) * 14)) * s)
            let r = tall ? (22 + Int(noise(i + 6310) * 16)) * s : (8 + Int(noise(i + 6310) * 5)) * s
            burtonSpiralDisc(c, x, y, r: Double(r), C(0xC8E8B8, 0.12), C(0x000000, 0), turn: noise(i + 6320))
        }
        if tall { tpChessField(c, yh: g - 135 * s, y1: g - 50 * s, s: s, haze: haze) }
        // Long streaks of pale cloud.
        for i in 0..<(tall ? 9 : 4) {
            let y = Int(noise(i + 6330) * Double(tall ? g - 160 * s : g / 2)) + 3 * s
            wisp(c, Int(noise(i + 6340) * Double(c.w)), y, (30 + Int(noise(i + 6350) * 40)) * s, C(0xC8E4B8, 0.35),
                 s: s)
        }
        // Far hills, dark teal, then nearer greener ones.
        c.dunes(base: g - (tall ? 54 : 14) * s, amp: 3 * Double(s), freq: 0.03, phase: 1.3, bottom: g, C(0x24504A))
        c.dunes(base: g - (tall ? 34 : 8) * s, amp: 2 * Double(s), freq: 0.05, phase: 0.2, bottom: g, C(0x2E5E3A))
        tpWindmill(c, x: f.mill, base: g - 2 * k, k: k)
        tpTree(c, x: f.tree, base: g, th: (tall ? 46 : 26) * k, k: k)
        // The chairs, each a different kind, then the table and its cloth.
        var cx = f.x0 + 4 * k, n = 0
        while cx < f.x1 - 4 * k {
            tpChair(c, x: cx, top: f.top, k: k, kind: [1, 0, 3, 2, 1, 2, 0, 3][n % 8])
            cx += (16 + Int(noise(n + 6400) * 8)) * k; n += 1
        }
        tpChair(c, x: f.x0 - 3 * k, top: f.top + 2 * k, k: k + k / 2, kind: 0)   // the big armchair at the head
        let wood = C(0x4A3020), cloth = C(0xE8E2CC), clothShade = C(0xB4AE98)
        for lx in [f.x0 + 2 * k, (f.x0 + f.x1) / 2, f.x1 - 4 * k] { c.rect(lx, f.top, 2 * k, g - f.top, wood) }
        c.rect(f.x0, f.top, f.x1 - f.x0, 4 * k, cloth); c.rect(f.x0, f.top + 3 * k, f.x1 - f.x0, k, clothShade)
        for x in stride(from: f.x0, to: f.x1 - 2 * k, by: 6 * k) {
            c.ellipse(x + 3 * k, f.top + 4 * k, 3 * k, k, cloth)
        }
        c.rect(f.x0, f.top, f.x1 - f.x0, k, C(0xF8F4E8))
        // The china.
        let china = tpChina(f), rattler = tpRattler(china)
        for (i, p) in china.enumerated() where i != rattler { tpPiece(c, p, base: f.top, k: k, i: i) }
        // The overgrown lawn, and odd mushrooms round the tree's roots.
        c.ground(g, C(0x2E5A26), edge: C(0x6AA040), speck: C(0x1E3E1A), seed: 61)
        for (i, mx) in [f.tree - 9 * k, f.tree + 8 * k, f.tree + 13 * k].enumerated() {
            let r = (3 - i % 2) * k
            c.rect(mx, g - 3 * k, k, 3 * k, C(0xE8E0C8)); c.ellipse(mx, g - 3 * k, r + k, r - k / 2, C(0xC83A6A))
            c.rect(mx - k, g - 4 * k, k, k, C(0xF8E8F0))
        }
    }

    /// What moves at the tea party: steam curling up from every teapot's spout, and one cup rattling on its saucer
    /// now and then.
    static func madTeaPartyLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let f = tpFrame(c, g), k = f.k, china = tpChina(f), rattler = tpRattler(china)
        for (i, p) in china.enumerated() where p.kind == 0 {
            let tip = (x: p.x + 7 * k, y: f.top - 8 * k)
            for n in 0..<9 {
                let q = (t * 0.4 + Double(n) / 9 + noise(i + 6500)).truncatingRemainder(dividingBy: 1)
                let x = Double(tip.x) + sin(q * 8 - t * 1.5 + Double(i)) * Double(3 * k) * (0.3 + q)
                let y = Double(tip.y) - q * Double(16 * k)
                let r = k + Int(q * 2 * Double(k))
                c.rect(Int(x.rounded()) - r / 2, Int(y.rounded()) - r / 2, r, r, C(0xF4FFF4, 0.8 * (1 - q)))
            }
        }
        guard rattler >= 0 else { return }
        let p = china[rattler], shaking = t.truncatingRemainder(dividingBy: 3.2) < 0.9
        let jig = shaking ? (Int(t * 18) % 2 == 0 ? -k : k) : 0, hop = shaking && Int(t * 18) % 4 == 0 ? k : 0
        tpCup(c, x: p.x + jig, base: f.top - hop, k: k, p.col)
        if shaking {
            for side in [-1, 1] {
                c.rect(p.x + side * 6 * k, f.top - 4 * k + (Int(t * 9) % 2) * k, k, 2 * k, C(0xFFFFFF, 0.7))
            }
        }
    }
}

// MARK: - The Red Queen's castle

extension Scenes {
    /// Where things stand in the Red Queen's courtyard: the size unit of the near things, the wall's top row, the
    /// throne's middle, and the battlements' spacing and merlon width.
    static func sgFrame(_ c: PixelCanvas, _ g: Int) -> (k: Int, wall: Int, throne: Int, period: Int, merlon: Int) {
        let s = unit(g), k = (isTall(c) ? 2 : 1) * s
        return (k, g - 30 * k, c.w / 2, 12 * k, 7 * k)
    }

    /// Whether (x, y) is behind one of the battlements' merlons (which hide the card knights walking the wall).
    static func sgBehindMerlon(_ f: (k: Int, wall: Int, throne: Int, period: Int, merlon: Int), _ x: Int,
                               _ y: Int) -> Bool {
        y >= f.wall - 5 * f.k && ((x % f.period) + f.period) % f.period < f.merlon
    }

    /// Where the banners hang on the wall: their left edges.
    static func sgBanners(_ c: PixelCanvas, _ f: (k: Int, wall: Int, throne: Int, period: Int, merlon: Int)) -> [Int] {
        [-1, 1].flatMap { side in [26, 78, 130].map { f.throne + side * $0 * f.k - 4 * f.k } }.filter {
            $0 > 0 && $0 < c.w - 8 * f.k
        }
    }

    /// A heart `w` across with its point on row `tip`, centred on `x`.
    static func sgHeart(_ c: PixelCanvas, x: Int, tip: Int, w: Int, _ col: Px) {
        let r = max(1, w * 3 / 10), lobe = tip - w * 9 / 10 + r
        c.circle(x - w / 2 + r, lobe, r, col); c.circle(x + w / 2 - r, lobe, r, col)
        burtonTriangle(c, (Double(x - w / 2) - 0.5, Double(lobe)), (Double(x + w / 2) + 0.5, Double(lobe)),
                       (Double(x), Double(tip)), col)
    }

    /// A topiary clipped into a heart, on a bare stem in a stone urn standing on row `base`.
    private static func sgTopiary(_ c: PixelCanvas, x: Int, base: Int, k: Int) {
        c.rect(x - 4 * k, base - 4 * k, 8 * k, 4 * k, C(0xB8A890))
        c.rect(x - 5 * k, base - 5 * k, 10 * k, 2 * k, C(0xD8CCB0))
        c.rect(x + 2 * k, base - 4 * k, 2 * k, 4 * k, C(0x8A7C68))
        c.rect(x - k / 2, base - 12 * k, max(1, k), 7 * k, C(0x4A3020))
        sgHeart(c, x: x, tip: base - 9 * k, w: 14 * k, C(0x1E5A2A))
        sgHeart(c, x: x - k, tip: base - 10 * k, w: 11 * k, C(0x2E7A36))
        c.circle(x - 4 * k, base - 19 * k, k, C(0x5AA04A)); c.rect(x - 2 * k, base - 16 * k, k, k, C(0x5AA04A))
    }

    /// The Red Queen's throne on its stepped dais: red velvet, gold legs and arms, and a great heart for a back with a
    /// gold rim and a little crown on top.
    private static func sgThrone(_ c: PixelCanvas, x: Int, base: Int, k: Int) {
        let gold = C(0xE8B830), goldD = C(0xA87A18), velvet = C(0xC81E2A), velvetD = C(0x8A1020)
        for (i, w) in [36, 28, 20].enumerated() {
            let y = base - (i + 1) * 2 * k
            c.rect(x - w * k / 2, y, w * k, 2 * k, velvetD)
            c.rect(x - w * k / 2, y, w * k, k / 2 + (k > 1 ? 0 : 1), velvet)
            c.rect(x - w * k / 2, y + 2 * k - max(1, k / 2), w * k, max(1, k / 2), gold)
        }
        let seat = base - 6 * k
        sgHeart(c, x: x, tip: seat - 2 * k, w: 30 * k, gold)
        sgHeart(c, x: x, tip: seat - 4 * k, w: 25 * k, velvet)
        sgHeart(c, x: x - k, tip: seat - 7 * k, w: 16 * k, C(0xE0303A))
        c.pattern(x - 3 * k, seat - 31 * k, bjScale(["Y.Y.Y", "YYYYY", "YYYYY"], k), ["Y": gold])
        c.rect(x - 9 * k, seat - 5 * k, 18 * k, 5 * k, velvet); c.rect(x - 9 * k, seat - 5 * k, 18 * k, k, C(0xE84048))
        for side in [-1, 1] {
            c.rect(x + side * 10 * k - k, seat - 8 * k, 2 * k, 8 * k, gold)
            c.rect(x + side * 10 * k - k, seat - 8 * k, 2 * k, k, goldD)
            c.circle(x + side * 10 * k, seat - 9 * k, k, gold)
        }
    }

    /// One of the castle's round towers rising from row `base`: red stone shaded round, a dark conical roof with a
    /// gold heart on its tip, a band of battlements and arched windows.
    private static func sgTower(_ c: PixelCanvas, x: Int, base: Int, w: Int, h: Int, s: Int) {
        let top = base - h
        for dx in 0..<w {
            let k = Double(dx) / Double(w)
            c.rect(x + dx, top, 1, h, k < 0.25 ? C(0xC0383A) : (k < 0.7 ? C(0x9A2226) : C(0x6A141A)))
        }
        for y in stride(from: top + 6 * s, to: base, by: 6 * s) { c.rect(x, y, w, max(1, s / 2), C(0x5A1016, 0.6)) }
        c.rect(x - 2 * s, top, w + 4 * s, 4 * s, C(0xB02C30))
        for mx in stride(from: x - 2 * s, to: x + w + 2 * s, by: 5 * s) {
            c.rect(mx, top - 3 * s, 3 * s, 3 * s, C(0xB02C30))
        }
        let rh = w * 6 / 5
        for r in 0..<rh {
            let half = (w / 2 + s) * (rh - r) / rh
            c.rect(x + w / 2 - half, top - 4 * s - r, half * 2, 1, r % (3 * s) == 0 ? C(0x501018) : C(0x3A0C14))
        }
        sgHeart(c, x: x + w / 2, tip: top - 4 * s - rh - s, w: 6 * s, C(0xE8B830))
        for wy in stride(from: top + 10 * s, to: base - 12 * s, by: 22 * s) {
            c.rect(x + w / 2 - 2 * s, wy, 4 * s, 7 * s, C(0x1A0608)); c.circle(x + w / 2, wy, 2 * s, C(0x1A0608))
        }
    }

    /// The Red Queen's castle at Salazen Grum: a sickly teal sky over a courtyard wall of red stone with battlements,
    /// the throne with its great heart back on a stepped dais in the middle, heart-shaped topiaries in stone urns and
    /// rose bushes either side, and a red carpet running down from the throne. The banners and the card knights on
    /// the wall are in the moving layer. On the screen saver, the castle's round towers with their dark cones and
    /// gold hearts rise behind, across the moat full of lily pads.
    static func salazenGrum(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = sgFrame(c, g), k = f.k
        c.gradient(0, g, C(0x183A3A), C(0x7AA894), bands: 7)
        for i in 0..<(tall ? 8 : 4) {
            let y = Int(noise(i + 6600) * Double(tall ? g / 3 : g / 3)) + 4 * s
            wisp(c, Int(noise(i + 6610) * Double(c.w)), y, (30 + Int(noise(i + 6620) * 40)) * s, C(0xB8DCC0, 0.35),
                 s: s)
        }
        if tall {   // Underland's slow swirls in the clouds
            for i in 0..<4 {
                let x = Double(c.w) * (0.12 + Double(i) * 0.25), y = Double(g) * (0.08 + noise(i + 6630) * 0.22)
                burtonSpiralDisc(c, x, y, r: Double((18 + Int(noise(i + 6640) * 14)) * s), C(0xB8DCC0, 0.10),
                                 C(0x000000, 0), turn: noise(i + 6645))
            }
        }
        if tall {
            let moat = f.wall - 16 * s
            // The curtain walls between the towers, then the towers, the keep tallest in the middle.
            c.rect(0, moat - 40 * s, c.w, 40 * s, C(0x8A1E22))
            for mx in stride(from: 0, to: c.w, by: 9 * s) { c.rect(mx, moat - 44 * s, 5 * s, 4 * s, C(0x8A1E22)) }
            for y in stride(from: moat - 34 * s, to: moat, by: 6 * s) {
                c.rect(0, y, c.w, max(1, s / 2), C(0x5A1016, 0.5))
            }
            for (fx, w, h) in [(0.10, 26, 92), (0.27, 30, 122), (0.50, 46, 168), (0.73, 30, 128), (0.90, 26, 98)] {
                let tw = w * s
                sgTower(c, x: Int(Double(c.w) * fx) - tw / 2, base: moat, w: tw, h: h * s, s: s)
            }
            let keep = c.w / 2
            sgHeart(c, x: keep, tip: moat - 108 * s, w: 18 * s, C(0xE8B830))
            sgHeart(c, x: keep, tip: moat - 110 * s, w: 13 * s, C(0x2A0A0E))
            // The moat: dark green water with ripples and lily pads, some flowering.
            c.rect(0, moat, c.w, f.wall - moat, C(0x1E4A3A)); c.rect(0, moat, c.w, s, C(0x0E2A20))
            for i in 0..<(c.w / (6 * s)) {
                let lx = Int(noise(i + 6650) * Double(c.w)), ly = moat + 3 * s + Int(noise(i + 6660) * Double(11 * s))
                if i % 3 == 0 { c.rect(lx, ly, 8 * s, max(1, s / 2), C(0x5A8A70)); continue }
                c.ellipse(lx, ly, 4 * s, 2 * s, C(0x4A9A3A)); c.rect(lx, ly - 2 * s, s, 2 * s, C(0x1E4A3A))
                if i % 4 == 1 { c.rect(lx - s, ly - s, 2 * s, 2 * s, C(0xF0B8D0)) }
            }
        }
        // The courtyard wall: red stone blocks, a lit coping, and battlements.
        c.rect(0, f.wall, c.w, g - f.wall, C(0x9A2226))
        for (row, y) in stride(from: f.wall + 2 * k, to: g, by: 5 * k).enumerated() {
            c.rect(0, y, c.w, max(1, k / 2), C(0x6A1418))
            for x in stride(from: (row % 2) * 5 * k, to: c.w, by: 10 * k) {
                c.rect(x, y, max(1, k / 2), 5 * k, C(0x6A1418))
            }
            for x in stride(from: (row % 2) * 5 * k + k, to: c.w, by: 10 * k) {
                c.rect(x, y + k, 3 * k, max(1, k / 2), C(0xB83438))
            }
        }
        c.rect(0, f.wall, c.w, 2 * k, C(0xC84448))
        for x in stride(from: 0, to: c.w, by: f.period) {
            c.rect(x, f.wall - 5 * k, f.merlon, 5 * k, C(0x9A2226)); c.rect(x, f.wall - 5 * k, f.merlon, k, C(0xC84448))
            c.rect(x + f.merlon - k, f.wall - 5 * k, k, 5 * k, C(0x6A1418))
        }
        // The banners' gold rods.
        for bx in sgBanners(c, f) { c.rect(bx - k, f.wall + 2 * k, 10 * k, k, C(0xE8B830)) }
        // Rose bushes along the wall's foot, the topiaries, the throne.
        for i in 0..<(c.w / (16 * k)) {
            let bx = i * 16 * k + Int(noise(i + 6700) * Double(6 * k))
            guard abs(bx - f.throne) > 22 * k else { continue }
            c.ellipse(bx, g - 3 * k, 7 * k, 4 * k, C(0x1E4A26)); c.ellipse(bx - k, g - 4 * k, 5 * k, 3 * k, C(0x2A6230))
            for r in 0..<4 { c.rect(bx - 5 * k + r * 3 * k, g - 6 * k + (r % 2) * 2 * k, 2 * k, 2 * k, C(0xE0202A)) }
        }
        for side in [-1, 1] {
            for d in stride(from: 52, to: 400, by: 52) {
                let tx = f.throne + side * d * k
                guard tx > 6 * k, tx < c.w - 6 * k else { continue }
                sgTopiary(c, x: tx, base: g, k: k)
            }
        }
        sgThrone(c, x: f.throne, base: g, k: k)
        // Red flagstones and the carpet running down from the dais.
        c.ground(g, C(0x5A3A3A), edge: C(0x8A5A56), speck: C(0x46282A), seed: 66)
        for x in stride(from: 0, to: c.w, by: 8 * k) { c.rect(x, g + k, max(1, k / 2), c.h - g, C(0x46282A)) }
        c.rect(f.throne - 9 * k, g, 18 * k, c.h - g, C(0xC81E2A)); c.rect(f.throne - 9 * k, g, k, c.h - g, C(0xE8B830))
        c.rect(f.throne + 8 * k, g, k, c.h - g, C(0xE8B830))
    }

    /// What moves at the Red Queen's castle: the red banners rippling on the wall, the card knights marching along
    /// the battlements (half hidden behind the merlons), and on the screen saver the towers' pennants flying.
    static func salazenGrumLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = sgFrame(c, g), k = f.k
        // The banners: red with a gold border and a gold heart, a swallowtail at the foot, rippling.
        let len = 18 * k
        for (i, bx) in sgBanners(c, f).enumerated() {
            for r in 0..<len {
                let wave = sin(t * 2.6 - Double(r) / Double(4 * k) + Double(i))
                let sway = Int((wave * Double(r) / Double(len) * 2 * Double(k)).rounded())
                let notch = r >= len - 3 * k ? (r - (len - 3 * k)) : 0
                let y = f.wall + 3 * k + r, x = bx + sway
                c.rect(x, y, 4 * k - notch, 1, C(0xD8202A)); c.rect(x + 4 * k + notch, y, 4 * k - notch, 1, C(0xD8202A))
                c.rect(x, y, k, 1, C(0xE8B830)); c.rect(x + 7 * k, y, k, 1, C(0xE8B830))
            }
            let sway = Int((sin(t * 2.6 - 2.2 + Double(i)) * Double(k)).rounded())
            sgHeart(c, x: bx + 4 * k + sway, tip: f.wall + 3 * k + len / 2 + 2 * k, w: 5 * k, C(0xE8B830))
        }
        // The card knights: two files marching opposite ways along the wall walk.
        let card = C(0xECE6D8), pip = C(0xC8202A), ink = C(0x2A1A1E)
        for file in 0..<2 {
            for n in 0..<3 {
                let span = Double(c.w + 60 * k), speed = Double(9 * k)
                var x = (t * speed + Double(file) * span / 2 + Double(n * 12 * k)).truncatingRemainder(dividingBy: span)
                if file == 1 { x = span - x }
                let kx = Int(x) - 30 * k, step = (Int(t * 4) + n) % 2 == 0
                let legs = step ? ".K.K." : "K...K"
                let rows = ["..K..", ".KKK.", "CCCCC", "CPCPC", "CCCCC", "CPCPC", "CCCCC", legs, legs]
                let y0 = f.wall - 9 * k
                for (r, row) in rows.enumerated() {
                    for (q, ch) in row.enumerated() where ch != "." {
                        let px = kx + q * k, py = y0 + r * k
                        guard !sgBehindMerlon(f, px, py) else { continue }
                        c.rect(px, py, k, k, ch == "C" ? card : (ch == "P" ? pip : ink))
                    }
                }
                let spear = file == 0 ? kx + 6 * k : kx - 2 * k
                for r in 0..<(12 * k) where !sgBehindMerlon(f, spear, y0 - 4 * k + r) {
                    c.px(spear, y0 - 4 * k + r, ink)
                }
                if !sgBehindMerlon(f, spear, y0 - 5 * k) {
                    c.rect(spear - k / 2, y0 - 6 * k, max(1, k), 2 * k, C(0xB8B8C0))
                }
            }
        }
        guard tall else { return }
        // Pennants flying from the towers.
        let moat = f.wall - 16 * s
        for (fx, w, h) in [(0.10, 26, 92), (0.27, 30, 122), (0.73, 30, 128), (0.90, 26, 98)] {
            let tw = w * s, x = Int(Double(c.w) * fx), top = moat - h * s - 4 * s - tw * 6 / 5 - 5 * s
            c.rect(x, top - 10 * s, s, 10 * s + s, C(0x2A0A0E))
            for q in 0..<(12 * s) {
                let flap = sin(t * 4 - Double(q) / Double(3 * s))
                let wave = Int((flap * Double(s) * Double(q) / Double(6 * s)).rounded())
                let half = max(1, (3 * s) * (12 * s - q) / (12 * s))
                c.rect(x + s + q, top - 10 * s + wave + (3 * s - half), 1, half * 2, C(0xD8202A))
            }
        }
    }
}

// MARK: - Victor's attic lab

extension Scenes {
    /// Where things stand in Victor's attic: the size unit of the near things, the middle (under the skylight), the
    /// skylight's opening (on the screen saver, the glass round the roof's ridge), the operating table's top row,
    /// the lightning rod's tip, and on the screen saver the eaves' row and the roof's slope.
    static func naFrame(_ c: PixelCanvas, _ g: Int) -> (k: Int, cx: Int, sky: (x0: Int, y0: Int, x1: Int, y1: Int),
                                                         table: Int, rod: (x: Int, y: Int), eaves: Int, slope: Double) {
        let s = unit(g), tall = isTall(c), k = (tall ? 2 : 1) * s, cx = c.w / 2
        guard tall else {
            return (k, cx, (cx - 28 * k, 0, cx + 28 * k, 17 * k), g - 12 * k, (cx + 9 * k, -4 * k), -1, 0)
        }
        let eaves = g - 56 * k, apex = max(72 * s, eaves - Int(Double(c.w) * 0.3))
        let slope = Double(eaves - apex) / Double(c.w / 2)
        let gw = 26 * k
        return (k, cx, (cx - gw, apex, cx + gw, apex + Int(Double(gw) * slope)), g - 12 * k, (cx, apex - 34 * s),
                eaves, slope)
    }

    /// The roof's underside on the screen saver: the row where the attic's ceiling is above column `x`.
    static func naRoof(_ c: PixelCanvas, _ f: (k: Int, cx: Int, sky: (x0: Int, y0: Int, x1: Int, y1: Int), table: Int,
                                               rod: (x: Int, y: Int), eaves: Int, slope: Double), _ x: Int) -> Int {
        min(f.eaves, f.sky.y0 + Int(Double(abs(x - f.cx)) * f.slope))
    }

    /// A diamond kite of pale paper on two dark spars, hung at its top point (x, y), `h` tall, turned `angle` degrees
    /// from upright, with a bowed tail swinging `swing`.
    static func naKite(_ c: PixelCanvas, x: Int, y: Int, h: Int, angle: Double, swing: Double, k: Int) {
        let top = (x: Double(x), y: Double(y)), a = 90 + angle
        let bottom = burtonReach(top, a, Double(h)), mid = burtonReach(top, a, Double(h) * 0.35)
        let left = burtonReach(mid, a + 90, Double(h) * 0.36), right = burtonReach(mid, a - 90, Double(h) * 0.36)
        burtonTriangle(c, (top.x, top.y), (left.x, left.y), (bottom.x, bottom.y), C(0xD4D4D4))
        burtonTriangle(c, (top.x, top.y), (right.x, right.y), (bottom.x, bottom.y), C(0xA8A8A8))
        burtonLine(c, top.x, top.y, bottom.x, bottom.y, C(0x2C2C2C), Double(k) * 0.5)
        burtonLine(c, left.x, left.y, right.x, right.y, C(0x2C2C2C), Double(k) * 0.5)
        var p = bottom
        for n in 0..<5 {
            let q = burtonReach(p, a + sin(swing + Double(n) * 0.9) * 25, Double(4 * k))
            burtonLine(c, p.x, p.y, q.x, q.y, C(0x1E1E1E), Double(k) * 0.4)
            if n % 2 == 1 { c.rect(Int(q.x) - k, Int(q.y) - k / 2, 3 * k, max(1, k), C(0xEEEEEE)) }
            p = q
        }
    }

    /// The kites hung about the attic (but not the one the moving layer swings): their top points and heights.
    static func naKites(_ c: PixelCanvas, _ f: (k: Int, cx: Int, sky: (x0: Int, y0: Int, x1: Int, y1: Int), table: Int,
                                                rod: (x: Int, y: Int), eaves: Int, slope: Double),
                        tall: Bool) -> [(x: Int, y: Int, h: Int)] {
        let k = f.k
        if !tall {
            return [(c.w * 9 / 100, 4 * k, 17 * k), (c.w * 31 / 100, 5 * k, 14 * k), (c.w * 67 / 100, 4 * k, 16 * k)]
        }
        return [(14, 10, 16), (31, 8, 14), (66, 8, 14), (82, 10, 15)].map { fx, dy, h in
            (c.w * fx / 100, naRoof(c, f, c.w * fx / 100) + dy * k, h * k)
        }
    }

    /// A stormy grey sky through a window or over the roofs: banded from `top` to `bottom`, with heavy clouds.
    private static func naStorm(_ c: PixelCanvas, x0: Int, y0: Int, x1: Int, y1: Int, s: Int, seed: Int) {
        for y in y0..<y1 {
            let k = Double(y - y0) / Double(max(1, y1 - y0))
            c.rect(x0, y, x1 - x0, 1, lerp(C(0x2A2A2A), C(0x7A7A7A), (k * 5).rounded(.down) / 5))
        }
        // Clumps of cloud: three puffs each, lit along the top, kept inside the box.
        func blob(_ cx: Int, _ cy: Int, _ rx: Int, _ ry: Int, _ col: Px) {
            for dy in -ry...ry {
                let half = Int((Double(rx) * (1 - Double(dy * dy) / Double(max(1, ry * ry))).squareRoot()).rounded())
                let y = cy + dy, a = max(x0, cx - half), b = min(x1, cx + half + 1)
                if y >= y0, y < y1, b > a { c.rect(a, y, b - a, 1, col) }
            }
        }
        for i in 0..<max(3, (x1 - x0) / (16 * s)) {
            let cx = x0 + Int(noise(seed + i * 3) * Double(x1 - x0))
            let cy = y0 + Int(noise(seed + i * 3 + 1) * Double(y1 - y0))
            let r = (3 + Int(noise(seed + i * 3 + 2) * 6)) * s
            for (j, col) in [C(0x4A4A4A), C(0x1E1E1E)].enumerated() {
                for p in 0..<3 {
                    blob(cx + (p - 1) * r * 3 / 2, cy - (p == 1 ? r / 2 : 0) + j * s, r * 3 / 2,
                         r * 2 / 3 + (p == 1 ? r / 3 : 0), col)
                }
            }
        }
    }

    /// A jar on a shelf, standing on row `base`: grey glass, something murky floating inside, a dark lid.
    private static func naJar(_ c: PixelCanvas, x: Int, base: Int, w: Int, h: Int, k: Int, seed: Int) {
        c.rect(x, base - h, w, h, C(0x8A8A8A))
        c.rect(x + w - k, base - h, k, h, C(0x5A5A5A))
        c.rect(x + k, base - h + k, k, h - 2 * k, C(0xC8C8C8))
        c.ellipse(x + w / 2, base - h / 2 + k, max(1, w / 4), max(1, h / 5),
                  noise(seed) > 0.5 ? C(0x2C2C2C) : C(0x4A4A4A))
        c.rect(x - k / 2, base - h - k, w + k, k + k / 2, C(0x1E1E1E))
    }

    /// Victor's attic lab in New Holland, in black and white like the film: bare plank walls under the roof, a
    /// skylight full of storm in the middle, the operating table beneath it with a sheet and leather straps, two wires
    /// looping down to it, a coil tower with rings, a crank, kites hung from the rafters, shelves of jars, and a desk
    /// with a lamp and a film projector, a bare bulb and sketches pinned to the planks. On the screen saver the attic
    /// is cut open under its roof: the shingled gable and its glass ridge, the lightning rod on top, Victor's film
    /// screen and a window, and outside a storm split by lightning over the rooftops of New Holland and the windmill
    /// on its hill.
    static func newHollandAttic(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = naFrame(c, g), k = f.k
        let wall = C(0x3A3A3A), seam = C(0x262626), board = C(0x464646)
        if tall {
            // Outside: the storm, the lightning frozen in it, far rooftops and the windmill on its hill.
            naStorm(c, x0: 0, y0: 0, x1: c.w, y1: f.eaves, s: s, seed: 6900)
            var p = (x: Double(c.w) * 0.84, y: 0.0)
            for n in 0..<9 {
                let q = (x: p.x + (noise(n + 6950) - 0.55) * Double(16 * s), y: p.y + Double(f.eaves) / 11)
                burtonLine(c, p.x, p.y, q.x, q.y, C(0xFFFFFF, 0.25), Double(3 * s))
                burtonLine(c, p.x, p.y, q.x, q.y, C(0xFFFFFF), Double(s) * 0.7)
                if n == 3 {
                    let b = (x: q.x + Double(14 * s), y: q.y + Double(10 * s))
                    burtonLine(c, q.x, q.y, b.x, b.y, C(0xEEEEEE), Double(s) * 0.5)
                }
                p = q
            }
            // The windmill on its hill (left), the town on its ridge with its lights on (right).
            let hill = (x: c.w * 8 / 100, y: naRoof(c, f, c.w * 8 / 100) - 26 * s)
            c.ellipse(hill.x, hill.y + 30 * s, 60 * s, 30 * s, C(0x222222))
            c.rect(hill.x - 4 * s, hill.y - 16 * s, 8 * s, 18 * s, C(0x161616))
            c.rect(hill.x - 5 * s, hill.y - 19 * s, 10 * s, 3 * s, C(0x161616))
            for a in [-55.0, 35.0, 125.0, 215.0] {
                let hub = (x: Double(hill.x), y: Double(hill.y - 15 * s)), e = burtonReach(hub, a, Double(15 * s))
                burtonLine(c, hub.x, hub.y, e.x, e.y, C(0x161616), Double(s) * 0.6)
                let m = burtonReach(hub, a, Double(4 * s))
                let p = burtonReach(e, a + 90, Double(3 * s))
                let q = burtonReach(m, a + 90, Double(3 * s))
                burtonTriangle(c, (m.x, m.y), (e.x, e.y), (p.x, p.y), C(0x7A7A7A))
                burtonTriangle(c, (m.x, m.y), (q.x, q.y), (p.x, p.y), C(0x7A7A7A))
            }
            let ridge = (x: c.w * 92 / 100, y: naRoof(c, f, c.w * 92 / 100) - 18 * s)
            c.ellipse(ridge.x, ridge.y + 26 * s, 70 * s, 26 * s, C(0x222222))
            for i in 0..<8 {
                let hx = ridge.x - 44 * s + i * 12 * s, hy = ridge.y + Int(Double(abs(hx - ridge.x)) * 0.25) + s
                let hw = 9 * s, hh = (5 + Int(noise(i + 6971) * 5)) * s
                c.rect(hx, hy - hh, hw, hh, C(0x161616))
                for r in 0..<(hw / 2 + s) {
                    c.rect(hx + hw / 2 - r, hy - hh - hw / 2 - s + r, r * 2 + 1, 1, C(0x161616))
                }
                if noise(i + 6972) > 0.3 { c.rect(hx + 3 * s, hy - hh + 2 * s, 2 * s, 2 * s, C(0xE8E8E8)) }
            }
            // Inside: the plank walls up under the roof, then the roof itself, shingled, with glass along the ridge.
            for x in 0..<c.w { let r = naRoof(c, f, x); c.rect(x, r, 1, g - r, wall) }
            for x in stride(from: 0, to: c.w, by: 9 * k) {
                let r = naRoof(c, f, x)
                c.rect(x, r, max(1, k / 2), g - r, seam)
                if noise(x + 6980) > 0.6 { let r2 = naRoof(c, f, x + 4 * k); c.rect(x + k, r2, 7 * k, g - r2, board) }
            }
            for x in 0..<c.w {
                let r = naRoof(c, f, x), glass = x > f.sky.x0 && x < f.sky.x1
                c.rect(x, r - 6 * k, 1, 6 * k, glass ? C(0x9AA0A4, 0.45) : C(0x1E1E1E))
                if !glass, (x / (3 * k)) % 2 == 0 { c.rect(x, r - 6 * k, 1, k, C(0x3C3C3C)) }
                c.rect(x, r, 1, 2 * k, glass ? C(0x5A5A5A) : C(0x161616))
            }
            for x in stride(from: f.sky.x0, through: f.sky.x1, by: 13 * k) {
                let r = naRoof(c, f, x); c.rect(x - k / 2, r - 6 * k, max(1, k), 8 * k, C(0x5A5A5A))
            }
            // Rafters running up under the roof.
            for x in stride(from: 20 * k, to: c.w - 10 * k, by: 34 * k) where abs(x - f.cx) > 30 * k {
                let r = naRoof(c, f, x)
                c.rect(x, r, 3 * k, f.eaves - r + 4 * k, C(0x2A2A2A))
                c.rect(x, r, k, f.eaves - r + 4 * k, C(0x4E4E4E))
            }
            c.rect(0, f.eaves, c.w, 4 * k, C(0x2A2A2A)); c.rect(0, f.eaves, c.w, k, C(0x4E4E4E))
            // The lightning rod on the ridge.
            c.rect(f.rod.x - s, f.rod.y, 2 * s, f.sky.y0 - f.rod.y, C(0x8A8A8A))
            c.rect(f.rod.x - s, f.rod.y, s, f.sky.y0 - f.rod.y, C(0xC4C4C4))
            c.circle(f.rod.x, f.sky.y0 - 8 * s, 2 * s, C(0x8A8A8A))
            for side in [-1, 1] {
                burtonLine(c, Double(f.rod.x), Double(f.sky.y0 - 4 * s), Double(f.rod.x + side * 8 * s),
                           Double(f.sky.y0 - 2 * s + 4 * s),
                           C(0x5A5A5A), Double(s) * 0.5)
            }
            // Victor's film screen on the left wall, a window on the right, and a bare bulb hanging on its flex.
            let sc = (x: c.w * 9 / 100, y: f.eaves + 9 * k)
            c.rect(sc.x, sc.y, 30 * k, 19 * k, C(0xE4E4E4)); c.rect(sc.x + 29 * k, sc.y, k, 19 * k, C(0xB4B4B4))
            c.rect(sc.x - k, sc.y - k, 32 * k, 2 * k, C(0x1E1E1E))
            c.rect(sc.x + 14 * k, sc.y - 4 * k, 2 * k, 3 * k, C(0x1E1E1E))
            let wn = (x: c.w * 62 / 100, y: f.eaves + 10 * k)
            c.rect(wn.x - k, wn.y - k, 20 * k, 16 * k, C(0x1E1E1E))
            naStorm(c, x0: wn.x, y0: wn.y, x1: wn.x + 18 * k, y1: wn.y + 14 * k, s: s, seed: 6990)
            c.rect(wn.x + 8 * k, wn.y, 2 * k, 14 * k, C(0x1E1E1E))
            c.rect(wn.x, wn.y + 6 * k, 18 * k, 2 * k, C(0x1E1E1E))
            c.rect(wn.x - 2 * k, wn.y + 14 * k, 22 * k, 2 * k, C(0x5A5A5A))
            let bulb = (x: c.w * 36 / 100, y: naRoof(c, f, c.w * 36 / 100))
            c.rect(bulb.x, bulb.y, max(1, k / 2), 30 * k, C(0x1A1A1A))
            c.rect(bulb.x - k, bulb.y + 30 * k, 2 * k, 2 * k, C(0x555555))
            c.circle(bulb.x, bulb.y + 34 * k, 2 * k, C(0xEEEEEE))
        } else {
            // The strip: plank walls, the slope of the roof in the corners, a beam across, the skylight.
            c.rect(0, 0, c.w, g, wall)
            for x in stride(from: 0, to: c.w, by: 9 * k) {
                c.rect(x, 0, max(1, k / 2), g, seam)
                if noise(x + 6980) > 0.6 { c.rect(x + k, 0, 7 * k, g, board) }
            }
            for side in [0, 1] {
                for r in 0..<(30 * k) {
                    let w = (30 * k - r) * 3
                    c.rect(side == 0 ? 0 : c.w - w, r, w, 1, r % (5 * k) == 0 ? C(0x2C2C2C) : C(0x1E1E1E))
                }
            }
            naStorm(c, x0: f.sky.x0, y0: f.sky.y0, x1: f.sky.x1, y1: f.sky.y1, s: s, seed: 6900)
            c.rect(f.rod.x - k / 2, 0, max(1, k), f.sky.y1, C(0x9A9A9A))
            for x in stride(from: f.sky.x0, through: f.sky.x1, by: 12 * k) {
                c.rect(x - k, 0, 2 * k, f.sky.y1, C(0x5A5A5A))
            }
            c.rect(f.sky.x0 - 2 * k, f.sky.y1, f.sky.x1 - f.sky.x0 + 4 * k, 2 * k, C(0x5A5A5A))
            c.rect(f.sky.x0 - 2 * k, f.sky.y1 + 2 * k, f.sky.x1 - f.sky.x0 + 4 * k, k, C(0x1E1E1E))
            c.rect(f.sky.x0 - 3 * k, 0, 2 * k, f.sky.y1 + 2 * k, C(0x5A5A5A))
            c.rect(f.sky.x1 + k, 0, 2 * k, f.sky.y1 + 2 * k, C(0x5A5A5A))
            // A bare bulb on its flex, and Victor's sketches pinned to the planks.
            let bulb = c.w * 41 / 100
            c.rect(bulb, 0, 1, 15 * k, C(0x1A1A1A))
            c.rect(bulb - k, 15 * k, 2 * k, 2 * k, C(0x555555))
            c.circle(bulb, 19 * k, 2 * k, C(0xEEEEEE))
            for (i, (fx, y)) in [(0.56, 22), (0.61, 26), (0.89, 14), (0.20, 22)].enumerated() {
                let px = Int(Double(c.w) * fx)
                c.rect(px, y * k, 8 * k, 6 * k, C(0xDCDCDC)); c.rect(px + 3 * k, y * k - k, 2 * k, k, C(0x1E1E1E))
                for r in 0..<2 {
                    c.rect(px + k + (i + r) % 2 * k, y * k + 2 * k + r * 2 * k, 5 * k - (i % 2) * k, max(1, k / 2),
                           C(0x6A6A6A))
                }
            }
        }
        // The kites hung from above, on their strings.
        for (n, kite) in naKites(c, f, tall: tall).enumerated() {
            c.rect(kite.x, kite.y - 4 * k, max(1, k / 2), 4 * k, C(0x1A1A1A))
            naKite(c, x: kite.x, y: kite.y, h: kite.h, angle: [8.0, -12.0, 15.0, -6.0][n % 4], swing: Double(n), k: k)
        }
        // Shelves of jars on the right.
        let sx = c.w * 74 / 100, sw = 36 * k
        for (r, y) in [g - 34 * k, g - 22 * k].enumerated() {
            c.rect(sx, y, sw, k, C(0x6A6A6A))
            c.rect(sx + 2 * k, y + k, k, 2 * k, C(0x1E1E1E))
            c.rect(sx + sw - 3 * k, y + k, k, 2 * k, C(0x1E1E1E))
            var jx = sx + k, n = 0
            while jx < sx + sw - 5 * k {
                let jw = (4 + Int(noise(r * 20 + n + 7000) * 3)) * k, jh = (5 + Int(noise(r * 20 + n + 7010) * 4)) * k
                naJar(c, x: jx, base: y, w: jw, h: jh, k: k, seed: r * 20 + n); jx += jw + k + k * (n % 2); n += 1
            }
        }
        // The desk on the left: a lamp and the film projector with its two reels.
        let dx = c.w * 8 / 100, dw = 30 * k, dt = g - 13 * k
        c.rect(dx, dt, dw, 2 * k, C(0x5A5A5A)); c.rect(dx, dt + 2 * k, dw, k, C(0x2A2A2A))
        c.rect(dx + k, dt + 3 * k, 2 * k, g - dt - 3 * k, C(0x2A2A2A))
        c.rect(dx + dw - 3 * k, dt + 3 * k, 2 * k, g - dt - 3 * k, C(0x2A2A2A))
        c.rect(dx + 3 * k, dt - 9 * k, k, 9 * k, C(0x1E1E1E))
        c.ellipse(dx + 5 * k, dt - 9 * k, 3 * k, 2 * k, C(0x1E1E1E))
        c.rect(dx + 3 * k, dt - 8 * k, 4 * k, k, C(0xEEEEEE))
        c.rect(dx + 12 * k, dt - 6 * k, 12 * k, 6 * k, C(0x1E1E1E))
        c.rect(dx + 24 * k, dt - 5 * k, 3 * k, 3 * k, C(0x555555))
        for rx in [dx + 14 * k, dx + 22 * k] {
            c.circle(rx, dt - 10 * k, 4 * k, C(0x555555))
            c.circle(rx, dt - 10 * k, k, C(0x1E1E1E))
        }
        // The coil tower beside the table: a post wound with rings, a ball on top.
        let tx = f.cx - 30 * k
        c.rect(tx - 2 * k, g - 26 * k, 4 * k, 26 * k, C(0x555555))
        c.rect(tx - 2 * k, g - 26 * k, k, 26 * k, C(0x8A8A8A))
        for r in 0..<5 {
            c.rect(tx - 4 * k, g - 24 * k + r * 4 * k, 8 * k, k, C(0xA8A8A8))
            c.rect(tx + 3 * k, g - 24 * k + r * 4 * k, k, k, C(0x5A5A5A))
        }
        c.circle(tx, g - 29 * k, 3 * k, C(0xC4C4C4)); c.circle(tx - k, g - 30 * k, k, C(0xEEEEEE))
        c.rect(tx - 6 * k, g - 3 * k, 12 * k, 3 * k, C(0x2A2A2A))
        // The operating table: a sheet over it, leather straps, a crank wheel underneath.
        let t0 = f.cx - 17 * k, tw = 34 * k
        for lx in [t0 + 2 * k, t0 + tw - 4 * k] { c.rect(lx, f.table + 3 * k, 2 * k, g - f.table - 3 * k, C(0x2A2A2A)) }
        c.rect(t0 + 2 * k, g - 4 * k, tw - 4 * k, k, C(0x2A2A2A))
        c.circle(f.cx, g - 7 * k, 4 * k, C(0x555555)); c.circle(f.cx, g - 7 * k, 2 * k, C(0x2A2A2A))
        burtonLine(c, Double(f.cx), Double(g - 7 * k), Double(f.cx + 5 * k), Double(g - 11 * k), C(0x8A8A8A),
                   Double(k) * 0.6)
        c.rect(t0, f.table, tw, 3 * k, C(0x555555))
        c.rect(t0 - k, f.table - 2 * k, tw + 2 * k, 3 * k, C(0xE4E4E4))
        c.rect(t0 - k, f.table + k, tw + 2 * k, 2 * k, C(0xB4B4B4))
        c.rect(t0 - k, f.table + 3 * k, 3 * k, 3 * k, C(0xB4B4B4))
        c.rect(t0 + tw - 2 * k, f.table + 3 * k, 3 * k, 3 * k, C(0xB4B4B4))
        c.ellipse(t0 + 4 * k, f.table - 3 * k, 3 * k, k, C(0xF0F0F0))
        for bx in [t0 + 12 * k, t0 + 22 * k] { c.rect(bx, f.table - 2 * k, 2 * k, 6 * k, C(0x1E1E1E)) }
        // The wires looping down from above to the table's head and foot.
        let top = tall ? f.sky.y1 : f.sky.y1 + 2 * k
        for (from, to) in [(f.sky.x0 + 4 * k, t0 + k), (f.sky.x1 - 4 * k, t0 + tw - k)] {
            var p = (x: Double(from), y: Double(top))
            for n in 1...12 {
                let q = Double(n) / 12
                let x = Double(from) + Double(to - from) * q
                let y = Double(top) + Double(f.table - 2 * k - top) * q + sin(q * .pi) * Double(6 * k)
                burtonLine(c, p.x, p.y, x, y, C(0x141414), Double(k) * 0.5); p = (x, y)
            }
        }
        // The floorboards.
        c.ground(g, C(0x3A3A3A), edge: C(0x707070), speck: C(0x2A2A2A), seed: 69)
        for y in stride(from: g + 3 * k, to: c.h, by: 3 * k) { c.rect(0, y, c.w, max(1, k / 2), C(0x262626)) }
    }

    /// What moves in the attic: lightning flashing through the skylight now and then (twice in quick succession, a
    /// bolt cracking across the glass, a shaft of light dropping onto the table and the whole room lit white), the
    /// coil's ball crackling, and one kite swinging and flapping in the draught.
    static func newHollandAtticLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let s = unit(g), tall = isTall(c), f = naFrame(c, g), k = f.k
        // The kite on the left, swinging from its string.
        let kx = tall ? c.w * 45 / 100 : c.w * 20 / 100, ky = tall ? naRoof(c, f, c.w * 45 / 100) + 10 * k : 5 * k
        let swingA = sin(t * 1.7) * 14 + sin(t * 4.3) * 4
        c.rect(kx, ky - 4 * k, max(1, k / 2), 4 * k, C(0x1A1A1A))
        naKite(c, x: kx, y: ky, h: 13 * k, angle: swingA, swing: t * 5, k: k)
        // The coil's ball fizzing.
        let tx = f.cx - 30 * k
        if Int(t * 7) % 3 != 0 {
            for n in 0..<3 {
                let a = noise(Int(t * 7) * 5 + n) * 360
                let e = burtonReach((Double(tx), Double(g - 29 * k)), a, Double(5 * k))
                burtonLine(c, Double(tx), Double(g - 29 * k), e.x, e.y, C(0xFFFFFF, 0.7), Double(k) * 0.4)
            }
        }
        // The lightning: every 6 seconds, two flashes.
        let p = t.truncatingRemainder(dividingBy: 6)
        let flash = p < 0.12 ? 1 - p / 0.12 : (p > 0.24 && p < 0.5 ? 1 - (p - 0.24) / 0.26 : 0)
        guard flash > 0 else { return }
        let seed = Int(t / 6)
        if tall {
            c.rect(0, 0, c.w, f.eaves, C(0xFFFFFF, 0.25 * flash))
            var q = (x: Double(f.rod.x) + (noise(seed + 7100) - 0.5) * Double(c.w) * 0.3, y: 0.0)
            for n in 1...8 {
                let y = Double(f.rod.y) * Double(n) / 8
                let jag = (noise(seed * 9 + n + 7110) - 0.5) * Double(18 * s)
                let x = n == 8 ? Double(f.rod.x) : q.x + (Double(f.rod.x) - q.x) / Double(9 - n) + jag
                burtonLine(c, q.x, q.y, x, y, C(0xFFFFFF, 0.3 * flash), Double(4 * s))
                burtonLine(c, q.x, q.y, x, y, C(0xFFFFFF, flash), Double(s)); q = (x, y)
            }
            for x in f.sky.x0..<f.sky.x1 {
                let r = naRoof(c, f, x)
                c.rect(x, r - 6 * k, 1, 6 * k, C(0xFFFFFF, 0.6 * flash))
            }
        } else {
            c.rect(f.sky.x0, 0, f.sky.x1 - f.sky.x0, f.sky.y1, C(0xFFFFFF, 0.65 * flash))
            var q = (x: Double(f.sky.x0) + noise(seed + 7100) * Double(f.sky.x1 - f.sky.x0), y: 0.0)
            for n in 1...4 {
                let x = q.x + (noise(seed * 9 + n + 7110) - 0.5) * Double(14 * k), y = Double(f.sky.y1) * Double(n) / 4
                burtonLine(c, q.x, q.y, x, y, C(0xFFFFFF, flash), Double(k) * 0.8); q = (x, y)
            }
        }
        // The shaft of light down onto the table, and the room lit up.
        let y0 = tall ? f.sky.y1 : f.sky.y1 + 2 * k
        for y in y0..<f.table {
            let q = Double(y - y0) / Double(max(1, f.table - y0))
            let half = Int(Double(f.sky.x1 - f.sky.x0) / 2 * (1 - q) + Double(20 * k) * q)
            c.rect(f.cx - half, y, half * 2, 1, C(0xFFFFFF, 0.16 * flash))
        }
        c.rect(0, 0, c.w, c.h, C(0xFFFFFF, 0.07 * flash))
    }
}

// MARK: - The windmill mini-golf

extension Scenes {
    /// Where things stand at the mini-golf: the size unit of the near things, the hill's middle and top row, the
    /// windmill's hub and sail length, the big wheel's middle and radius, and the torches along the front.
    static func wmFrame(_ c: PixelCanvas, _ g: Int) -> (k: Int, hill: (x: Int, top: Int), hub: (x: Int, y: Int),
                                                         sail: Int, wheel: (x: Int, y: Int, r: Int), torches: [Int]) {
        let s = unit(g), k = (isTall(c) ? 2 : 1) * s
        let hx = c.w * 27 / 100, top = g - 16 * k
        let torches = [22, 40, 48, 64, 83, 97].map { c.w * $0 / 100 }
        return (k, (hx, top), (hx, top - 27 * k), 20 * k, (c.w * 74 / 100, g - 27 * k, 22 * k), torches)
    }

    /// A striped fairground tent standing on row `base`: canvas walls in grey and white stripes, a peaked roof, a dark
    /// doorway and a pennant on top.
    private static func wmTent(_ c: PixelCanvas, x: Int, base: Int, w: Int, k: Int) {
        let wallH = w / 2, roofH = w * 2 / 5
        for dx in 0..<w { c.rect(x + dx, base - wallH, 1, wallH, (dx / (3 * k)) % 2 == 0 ? C(0xD8D8D8) : C(0x6A6A6A)) }
        for r in 0..<roofH {
            let half = (w / 2 + k) * (roofH - r) / roofH
            for dx in -half..<half {
                c.px(x + w / 2 + dx, base - wallH - r, ((dx + w) / (3 * k)) % 2 == 0 ? C(0xE8E8E8) : C(0x4A4A4A))
            }
        }
        for dx in stride(from: 0, to: w, by: 3 * k) { c.ellipse(x + dx + k, base - wallH, k + k / 2, k, C(0xF0F0F0)) }
        c.rect(x + w / 2 - 2 * k, base - wallH / 2 - 2 * k, 4 * k, wallH / 2 + 2 * k, C(0x141414))
        c.rect(x + w / 2, base - wallH - roofH - 5 * k, max(1, k / 2), 5 * k, C(0x2A2A2A))
        burtonTriangle(c, (Double(x + w / 2 + 1), Double(base - wallH - roofH - 5 * k)),
                       (Double(x + w / 2 + 1 + 5 * k), Double(base - wallH - roofH - 4 * k)),
                       (Double(x + w / 2 + 1), Double(base - wallH - roofH - 3 * k)), C(0xEEEEEE))
    }

    /// The windmill mini-golf in Frankenweenie's black and white: the white wooden windmill on its hill (its sails
    /// turn in the moving layer) with the course's flags round it and its sign, the fair below on the right with its
    /// big wheel, striped tents and a string of bulbs, torches on posts along the front, all under a heavy storm. On
    /// the screen saver, a moon behind the clouds and New Holland's lights spread along the far hills.
    static func windmillMiniGolf(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = wmFrame(c, g), k = f.k
        naStorm(c, x0: 0, y0: 0, x1: c.w, y1: g, s: s, seed: 7300)
        if tall {
            // Great banks of storm cloud rolling over, lit along their tops, and the moon breaking through.
            for i in 0..<max(7, c.w * g / (24_000 * s * s)) {
                let bx = Int(noise(i + 7330) * Double(c.w))
                let by = Int(Double(g) * (0.06 + noise(i + 7331) * 0.4))
                let r = (14 + Int(noise(i + 7332) * 12)) * s
                for p in 0..<4 {
                    let px = bx + (p - 2) * r, py = by - (p % 2) * r / 3
                    c.ellipse(px, py - s * 2, r + r / 3, r * 2 / 3, C(0x5E5E5E))
                    c.ellipse(px, py, r + r / 3, r * 2 / 3, C(0x242424))
                }
            }
            let m = (x: c.w * 58 / 100, y: g * 18 / 100, r: 16 * s)
            c.circle(m.x, m.y, m.r + 8 * s, C(0xFFFFFF, 0.06)); c.circle(m.x, m.y, m.r, C(0xD8D8D8))
            c.circle(m.x - m.r / 3, m.y + m.r / 4, m.r / 4, C(0xB8B8B8))
            for i in 0..<3 {
                c.ellipse(m.x - 20 * s + i * 22 * s, m.y + m.r - 2 * s + (i % 2) * 3 * s, 16 * s, 4 * s, C(0x2A2A2A))
            }
            // New Holland on the far hills: rows of houses, a steeple, a water tower, their lights on.
            let ridge = g - 66 * s
            c.dunes(base: ridge, amp: 6 * Double(s), freq: 0.02, phase: 0.8, bottom: g, C(0x262626))
            for i in 0..<(c.w / (11 * s)) {
                let hx = i * 11 * s + Int(noise(i + 7350) * Double(4 * s))
                let swell = sin(Double(hx) * 0.02 + 0.8) * 0.6 + sin(Double(hx) * 0.046 + 1.36) * 0.4
                let hy = ridge - Int(swell * 6 * Double(s)) + 2 * s
                let hw = (7 + Int(noise(i + 7351) * 3)) * s, hh = (4 + Int(noise(i + 7352) * 5)) * s
                c.rect(hx, hy - hh, hw, hh, C(0x1A1A1A))
                for r in 0..<(hw / 2) { c.rect(hx + r, hy - hh - hw / 2 + r, hw - 2 * r, 1, C(0x1A1A1A)) }
                if noise(i + 7353) > 0.35 { c.rect(hx + 2 * s, hy - hh + s, 2 * s, 2 * s, C(0xF0F0E0)) }
                if noise(i + 7354) > 0.7 { c.rect(hx + hw - 3 * s, hy - hh + s, s, 2 * s, C(0xC8C8C8)) }
            }
            let sx = c.w * 44 / 100, sy = ridge - 2 * s
            c.rect(sx, sy - 22 * s, 6 * s, 22 * s, C(0x1A1A1A))
            for r in 0..<(12 * s) {
                c.rect(sx + 3 * s - (12 * s - r) / 4, sy - 22 * s - r, max(1, (12 * s - r) / 2), 1, C(0x1A1A1A))
            }
            let wt = (x: c.w * 88 / 100, y: ridge - 6 * s)
            c.ellipse(wt.x, wt.y - 18 * s, 8 * s, 5 * s, C(0x1A1A1A))
            for dx in [-6, -2, 2, 6] { c.rect(wt.x + dx * s, wt.y - 14 * s, s, 16 * s, C(0x1A1A1A)) }
        }
        // The far fields, then the hill with the windmill.
        c.dunes(base: g - (tall ? 40 : 12) * s, amp: 2 * Double(s), freq: 0.04, phase: 2.2, bottom: g, C(0x303030))
        // The fair: tents, the big wheel, a string of bulbs.
        wmTent(c, x: c.w * 50 / 100, base: g, w: 20 * k, k: k)
        wmTent(c, x: c.w * 88 / 100, base: g, w: 22 * k, k: k)
        let w = f.wheel
        for side in [-1, 1] {
            burtonLine(c, Double(w.x), Double(w.y), Double(w.x + side * w.r * 2 / 3), Double(g), C(0x3A3A3A), Double(k))
        }
        for a in stride(from: 0.0, to: 360.0, by: 30.0) {
            let e = burtonReach((Double(w.x), Double(w.y)), a, Double(w.r))
            burtonLine(c, Double(w.x), Double(w.y), e.x, e.y, C(0x5A5A5A), Double(k) * 0.4)
        }
        for ring in [w.r, w.r - 2 * k] {
            for n in 0..<(ring * 7) {
                let a = Double(n) / Double(ring * 7) * 2 * .pi
                c.rect(w.x + Int((cos(a) * Double(ring)).rounded()), w.y + Int((sin(a) * Double(ring)).rounded()),
                       max(1, k), max(1, k), C(0x8A8A8A))
            }
        }
        for a in stride(from: 15.0, to: 360.0, by: 45.0) {
            let e = burtonReach((Double(w.x), Double(w.y)), a, Double(w.r))
            c.rect(Int(e.x) - 2 * k, Int(e.y) + k, 4 * k, 3 * k, C(0x2A2A2A))
            c.rect(Int(e.x) - 2 * k, Int(e.y) + k, 4 * k, k, C(0xB8B8B8))
            c.rect(Int(e.x) - k / 2, Int(e.y), max(1, k), k + 1, C(0x5A5A5A))
        }
        c.circle(w.x, w.y, 2 * k, C(0xB8B8B8))
        wmTent(c, x: c.w * 59 / 100, base: g, w: 16 * k, k: k)
        let lx0 = c.w * 47 / 100, lx1 = c.w * 99 / 100, ly = g - 22 * k
        for x in lx0..<lx1 {
            let q = Double(x - lx0) / Double(lx1 - lx0), y = ly + Int(sin(q * .pi * 3).magnitude * Double(5 * k))
            c.px(x, y, C(0x1A1A1A))
            if (x - lx0) % (4 * k) == 0 { c.rect(x, y + 1, max(1, k), max(1, k), C(0xF4F4F4)) }
        }
        // The hill, the course's flags and the sign.
        c.ellipse(f.hill.x, g + 4 * k, 70 * k, 20 * k, C(0x3E3E3E))
        c.ellipse(f.hill.x - 6 * k, g + 4 * k, 60 * k, 19 * k, C(0x4A4A4A))
        for (dx, dy) in [(-46, 8), (-20, 3), (24, 4), (48, 10)] {
            let fx = f.hill.x + dx * k, fy = f.hill.top + dy * k
            c.ellipse(fx, fy, 6 * k, k, C(0x5E5E5E)); c.rect(fx - k / 2, fy - 9 * k, max(1, k), 9 * k, C(0xD8D8D8))
            burtonTriangle(c, (Double(fx), Double(fy - 9 * k)), (Double(fx + 5 * k), Double(fy - 7 * k)),
                           (Double(fx), Double(fy - 5 * k)), C(0x1A1A1A))
        }
        let sg = (x: c.w * 3 / 100, y: g - 17 * k), tw = bjTextWidth("MINI GOLF", s: k)
        c.rect(sg.x + 3 * k, sg.y + 8 * k, max(1, k), 9 * k, C(0x1A1A1A))
        c.rect(sg.x + tw, sg.y + 8 * k, max(1, k), 9 * k, C(0x1A1A1A))
        c.rect(sg.x, sg.y, tw + 4 * k, 9 * k, C(0x1A1A1A)); c.rect(sg.x + k, sg.y + k, tw + 2 * k, 7 * k, C(0xE8E8E8))
        bjText(c, "MINI GOLF", x: sg.x + 2 * k, y: sg.y + 2 * k, s: k, C(0x1A1A1A))
        // The windmill: a tapering white wooden tower with a gallery round it, a dark cap, a door and windows.
        let base = f.hill.top + 2 * k, th = base - f.hub.y - 2 * k
        for r in 0..<th {
            let half = 9 * k - 4 * k * r / th
            c.rect(f.hill.x - half, base - r - 1, half * 2, 1, C(0xC8C8C8))
            c.rect(f.hill.x + half - 3 * k, base - r - 1, 3 * k, 1, C(0x8E8E8E))
            c.rect(f.hill.x - half, base - r - 1, k, 1, C(0xEEEEEE))
            if r % (3 * k) == 0 { c.rect(f.hill.x - half, base - r - 1, half * 2, max(1, k / 2), C(0xA8A8A8)) }
        }
        c.rect(f.hill.x - 11 * k, base - th / 3, 22 * k, k, C(0x2A2A2A))
        for x in stride(from: f.hill.x - 11 * k, through: f.hill.x + 10 * k, by: 3 * k) {
            c.rect(x, base - th / 3 - 3 * k, max(1, k / 2), 3 * k, C(0x2A2A2A))
        }
        c.rect(f.hill.x - 11 * k, base - th / 3 - 3 * k, 22 * k, max(1, k / 2), C(0x2A2A2A))
        c.rect(f.hill.x - 3 * k, base - 8 * k, 6 * k, 8 * k, C(0x1A1A1A))
        c.ellipse(f.hill.x, base - 8 * k, 3 * k, 2 * k, C(0x1A1A1A))
        c.rect(f.hill.x - 2 * k, base - th * 2 / 3, 3 * k, 3 * k, C(0x1A1A1A))
        c.ellipse(f.hub.x, f.hub.y + k, 7 * k, 5 * k, C(0x3A3A3A))
        c.rect(f.hub.x - 7 * k, f.hub.y + k, 14 * k, 5 * k, C(0x3A3A3A))
        c.ellipse(f.hub.x - 2 * k, f.hub.y - k, 3 * k, 2 * k, C(0x5A5A5A))
        // Torch posts along the front.
        for x in f.torches {
            c.rect(x - k, g - 12 * k, 2 * k, 12 * k, C(0x2A2A2A))
            c.rect(x - 2 * k, g - 14 * k, 4 * k, 3 * k, C(0x4A4A4A))
        }
        // Dark grass.
        c.ground(g, C(0x2E2E2E), edge: C(0x5A5A5A), speck: C(0x202020), seed: 73)
    }

    /// What moves at the mini-golf: the windmill's four lattice sails turning, and the torches' flames flickering.
    static func windmillMiniGolfLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let f = wmFrame(c, g), k = f.k, hub = (x: Double(f.hub.x), y: Double(f.hub.y))
        for n in 0..<4 {
            let a = t * 35 + Double(n) * 90
            let e = burtonReach(hub, a, Double(f.sail)), m = burtonReach(hub, a, Double(4 * k))
            let p = burtonReach(e, a + 90, Double(5 * k)), q = burtonReach(m, a + 90, Double(5 * k))
            burtonTriangle(c, (m.x, m.y), (e.x, e.y), (p.x, p.y), C(0xE4E4E4))
            burtonTriangle(c, (m.x, m.y), (q.x, q.y), (p.x, p.y), C(0xE4E4E4))
            for d in stride(from: 7.0, to: Double(f.sail / k), by: 4) {
                let u = burtonReach(hub, a, Double(k) * d), v = burtonReach(u, a + 90, Double(5 * k))
                burtonLine(c, u.x, u.y, v.x, v.y, C(0x6A6A6A), Double(k) * 0.5)
            }
            let side = burtonReach(burtonReach(hub, a, Double(f.sail)), a + 90, Double(5 * k))
            burtonLine(c, q.x, q.y, side.x, side.y, C(0x5A5A5A), Double(k) * 0.4)
            burtonLine(c, hub.x, hub.y, e.x, e.y, C(0x2A2A2A), Double(k) * 0.8)
        }
        c.circle(f.hub.x, f.hub.y, 2 * k, C(0x1A1A1A))
        for (i, x) in f.torches.enumerated() {
            let n = noise(Int(t * 10) * 7 + i * 13)
            let h = Double(5 * k) + n * Double(3 * k)
            let lean = (noise(Int(t * 10) * 7 + i * 13 + 1) - 0.5) * Double(2 * k)
            let y = Double(g - 14 * k)
            c.circle(x, Int(y) - 3 * k, 5 * k, C(0xFFFFFF, 0.08 + n * 0.05))
            burtonTriangle(c, (Double(x - 2 * k), y), (Double(x + 2 * k), y), (Double(x) + lean, y - h), C(0xC8C8C8))
            burtonTriangle(c, (Double(x - k), y), (Double(x + k), y), (Double(x) + lean / 2, y - h * 0.6), C(0xFFFFFF))
        }
    }
}

// MARK: - Pee-wee's house

extension Scenes {
    private static let bmRed = C(0xE8302A), bmRedD = C(0xB01E1A), bmYellow = C(0xF8D030), bmBlue = C(0x2A6AD8),
                       bmBlueD = C(0x1A4AA8), bmGreen = C(0x3AB04A), bmWhite = C(0xF8F8F0), bmInk = C(0x1E1E28),
                       bmChrome = C(0xC8D0D8), bmChromeD = C(0x8A96A0), bmPancake = C(0xE0A050)

    /// Where things stand in Pee-wee's kitchen: the size unit of the room, the (bigger) size unit of the breakfast
    /// machine, the counter's ends and top row, the machine's pieces along it (the dinosaur's front foot, the ramp's
    /// two ends, the toaster's left side, the griddle's left side, the plate's middle), the door's left side and the
    /// bike's middle.
    static func bmFrame(_ c: PixelCanvas, _ g: Int) -> (k: Int, m: Int, x0: Int, x1: Int, top: Int, dino: Int,
                                                         ramp: (x0: Int, y0: Int, x1: Int, y1: Int), toaster: Int,
                                                         griddle: Int, plate: Int, door: Int, bike: Int) {
        let s = unit(g), tall = isTall(c), k = (tall ? 2 : 1) * s, m = (tall ? 3 : 2) * s
        let x0 = c.w * 6 / 100, top = g - 18 * k, toaster = c.w * 31 / 100
        return (k, m, x0, c.w * 78 / 100, top, x0 + 11 * m, (x0 + 14 * m, top - 8 * m, toaster - 2 * m, top - 2 * m),
                toaster, c.w * 45 / 100, c.w * 64 / 100, c.w * 82 / 100, c.w * 91 / 100)
    }

    /// The breakfast machine's clock: where in its eight-second loop it is (0…1).
    static func bmPhase(_ t: Double) -> Double { t.truncatingRemainder(dividingBy: 8) / 8 }

    /// String art drawn `k` times over and turned `angle` degrees about the pixel (`at`) of the art that sits on
    /// (`x`, `y`).
    static func bmTurned(_ c: PixelCanvas, _ rows: [String], _ pal: [Character: Px], at: (Double, Double),
                         x: Double, y: Double, angle: Double, k: Int) {
        let a = angle * .pi / 180, ca = cos(a), sa = sin(a)
        let reach = Int(Double(max(rows.count, rows.map(\.count).max() ?? 0) * k) * 1.5) + 2
        for py in (Int(y) - reach)...(Int(y) + reach) {
            for px in (Int(x) - reach)...(Int(x) + reach) {
                let dx = Double(px) + 0.5 - x, dy = Double(py) + 0.5 - y
                let u = (dx * ca + dy * sa) / Double(k) + at.0, v = (-dx * sa + dy * ca) / Double(k) + at.1
                let r = Int(floor(v)), q = Int(floor(u))
                guard r >= 0, r < rows.count, q >= 0 else { continue }
                let row = Array(rows[r])
                guard q < row.count, let col = pal[row[q]] else { continue }
                c.px(px, py, col)
            }
        }
    }

    /// Pee-wee's red-and-white bike standing on row `base` round `x`: white-walled tyres under white fenders, a red
    /// frame with a striped tank, a chrome handlebar sweeping back, a headlight and a bell.
    private static func bmBike(_ c: PixelCanvas, x: Int, base: Int, k: Int) {
        let r = 6 * k, back = (x: x - 9 * k, y: base - r), front = (x: x + 9 * k, y: base - r)
        for w in [back, front] {
            c.circle(w.x, w.y, r, bmInk); c.circle(w.x, w.y, r - k, bmWhite); c.circle(w.x, w.y, r - 2 * k, C(0x9AA4B0))
            for a in stride(from: 0.0, to: 180.0, by: 45.0) {
                let p = burtonReach((Double(w.x), Double(w.y)), a, Double(r - 2 * k))
                let q = burtonReach((Double(w.x), Double(w.y)), a + 180, Double(r - 2 * k))
                burtonLine(c, p.x, p.y, q.x, q.y, bmChrome, 0.4)
            }
            c.circle(w.x, w.y, k, bmChromeD)
            for a in stride(from: 195.0, through: 345.0, by: 6.0) {
                let p = burtonReach((Double(w.x), Double(w.y)), a, Double(r + k))
                c.rect(Int(p.x), Int(p.y), max(1, k), max(1, k), bmWhite)
            }
        }
        let mid = (x: Double(x - k), y: Double(base - r + k)), seat = (x: Double(x - 5 * k), y: Double(base - 15 * k))
        let head = (x: Double(x + 6 * k), y: Double(base - 14 * k))
        for (p, q) in [((Double(back.x), Double(back.y)), mid), (mid, seat), ((Double(back.x), Double(back.y)), seat),
                       (mid, head), (head, (Double(front.x), Double(front.y)))] {
            burtonLine(c, p.0, p.1, q.0, q.1, bmRed, Double(k) * 0.9)
        }
        burtonTriangle(c, (seat.x + Double(k), seat.y + Double(2 * k)), (head.x, head.y),
                       (mid.x + Double(2 * k), mid.y - Double(3 * k)), bmRed)
        burtonLine(c, seat.x + Double(3 * k), seat.y + Double(3 * k), head.x - Double(k), head.y + Double(2 * k),
                   bmWhite, Double(k) * 0.5)
        c.rect(Int(seat.x) - 3 * k, Int(seat.y) - 2 * k, 6 * k, 2 * k, bmInk)
        c.rect(Int(seat.x) - 3 * k, Int(seat.y) - 2 * k, 6 * k, max(1, k / 2), C(0x4A4A58))
        burtonLine(c, head.x, head.y, head.x - Double(k), head.y - Double(4 * k), bmChrome, Double(k) * 0.6)
        burtonLine(c, head.x - Double(k), head.y - Double(4 * k), head.x - Double(5 * k), head.y - Double(3 * k),
                   bmChrome, Double(k) * 0.6)
        c.rect(Int(head.x) + k, Int(head.y) - k, 3 * k, 3 * k, bmChrome)
        c.rect(Int(head.x) + 3 * k, Int(head.y), k, k, bmYellow)
        c.circle(Int(head.x) - 3 * k, Int(head.y) - 5 * k, k, bmYellow)
    }

    /// A toy on the kitchen shelf standing on row `base`: blocks with letters, a rocket, a ball, a toy car, a top or a
    /// jack-in-the-box; returns how wide it is.
    private static func bmToy(_ c: PixelCanvas, kind: Int, x: Int, base: Int, k: Int) -> Int {
        switch kind {
        case 0:
            for (i, (ch, col)) in [("A", bmRed), ("B", bmBlue), ("C", bmGreen)].enumerated() {
                let bx = x + i * 6 * k
                c.rect(bx, base - 6 * k, 6 * k, 6 * k, col)
                c.rect(bx + 5 * k, base - 6 * k, k, 6 * k, lerp(col, bmInk, 0.3))
                bjText(c, ch, x: bx + k, y: base - 6 * k + k / 2 + (k > 1 ? 0 : 0), s: k, bmWhite)
            }
            bjText(c, "", x: x, y: base, s: k, bmWhite)
            c.rect(x + 3 * k, base - 12 * k, 6 * k, 6 * k, bmYellow)
            bjText(c, "X", x: x + 4 * k, y: base - 12 * k + k / 2, s: k, bmRed)
            return 18 * k
        case 1:
            c.rect(x + 2 * k, base - 12 * k, 4 * k, 10 * k, bmWhite)
            c.rect(x + 5 * k, base - 12 * k, k, 10 * k, C(0xC8C8C8))
            burtonTriangle(c, (Double(x + 2 * k), Double(base - 12 * k)), (Double(x + 6 * k), Double(base - 12 * k)),
                           (Double(x + 4 * k), Double(base - 16 * k)), bmRed)
            burtonTriangle(c, (Double(x + 2 * k), Double(base - 5 * k)), (Double(x), Double(base)),
                           (Double(x + 2 * k), Double(base)), bmRed)
            burtonTriangle(c, (Double(x + 6 * k), Double(base - 5 * k)), (Double(x + 8 * k), Double(base)),
                           (Double(x + 6 * k), Double(base)), bmRed)
            c.circle(x + 4 * k, base - 9 * k, k, bmBlue)
            return 9 * k
        case 2:
            c.circle(x + 4 * k, base - 4 * k, 4 * k, bmRed)
            c.rect(x, base - 5 * k, 9 * k, 2 * k, bmWhite)
            c.circle(x + 2 * k, base - 6 * k, k, C(0xFFB0A0))
            return 9 * k
        case 3:
            c.rect(x, base - 5 * k, 12 * k, 3 * k, bmBlue); c.rect(x + 3 * k, base - 8 * k, 6 * k, 3 * k, bmBlue)
            c.rect(x + 4 * k, base - 7 * k, 4 * k, 2 * k, C(0xB8E8FF))
            c.circle(x + 3 * k, base - 2 * k, 2 * k, bmInk); c.circle(x + 9 * k, base - 2 * k, 2 * k, bmInk)
            return 13 * k
        case 4:
            burtonTriangle(c, (Double(x), Double(base - 6 * k)), (Double(x + 8 * k), Double(base - 6 * k)),
                           (Double(x + 4 * k), Double(base)), bmYellow)
            c.rect(x, base - 8 * k, 8 * k, 2 * k, bmRed); c.rect(x + 3 * k, base - 11 * k, 2 * k, 3 * k, bmGreen)
            return 9 * k
        default:
            c.rect(x, base - 8 * k, 8 * k, 8 * k, bmGreen); c.rect(x + 7 * k, base - 8 * k, k, 8 * k, C(0x22803A))
            c.rect(x + 2 * k, base - 6 * k, 4 * k, 4 * k, bmYellow)
            c.rect(x + 9 * k, base - 5 * k, 2 * k, k, bmChromeD)
            c.circle(x + 4 * k, base - 11 * k, 3 * k, bmRed); c.rect(x + 3 * k, base - 12 * k, 2 * k, 2 * k, bmWhite)
            return 12 * k
        }
    }

    /// A shelf of toys from `x0` to `x1` on row `y`.
    private static func bmShelf(_ c: PixelCanvas, x0: Int, x1: Int, y: Int, k: Int, seed: Int) {
        c.rect(x0, y, x1 - x0, 2 * k, bmBlue); c.rect(x0, y + 2 * k, x1 - x0, k, bmBlueD)
        for bx in stride(from: x0 + 4 * k, to: x1, by: 40 * k) {
            burtonTriangle(c, (Double(bx), Double(y + 3 * k)), (Double(bx + 4 * k), Double(y + 3 * k)),
                           (Double(bx), Double(y + 7 * k)), bmBlueD)
        }
        var x = x0 + 2 * k, n = 0
        while x < x1 - 20 * k {
            x += bmToy(c, kind: (n + seed) % 6, x: x, base: y, k: k) + (4 + Int(noise(seed + n) * 6)) * k; n += 1
        }
    }

    /// The window on the screen saver: Pee-wee's sunny yard, its white picket fence, and Francis's mansion over the
    /// fence next door, grand and pink with white columns.
    private static func bmYard(_ c: PixelCanvas, x0: Int, y0: Int, x1: Int, y1: Int, s: Int) {
        let w = x1 - x0, h = y1 - y0
        for y in y0..<y1 { c.rect(x0, y, w, 1, lerp(C(0x4AA8F0), C(0xB8E4FF), Double(y - y0) / Double(h))) }
        c.circle(x0 + w * 85 / 100, y0 + h * 16 / 100, 9 * s, C(0xFFF4A0))
        c.circle(x0 + w * 85 / 100, y0 + h * 16 / 100, 7 * s, C(0xFFE040))
        // The mansion: a wide pink house, white columns along its porch, a slate roof with dormers, a turret.
        let mx = x0 + w * 30 / 100, mw = w * 52 / 100, mb = y0 + h * 70 / 100, mh = h * 30 / 100
        c.rect(mx, mb - mh, mw, mh, C(0xF4B8C8)); c.rect(mx + mw - 3 * s, mb - mh, 3 * s, mh, C(0xD898A8))
        let rh = mh / 2
        for r in 0..<rh { c.rect(mx - 4 * s + r, mb - mh - r, mw + 8 * s - 2 * r, 1, C(0x5A6A8A)) }
        for dx in stride(from: mx + 10 * s, to: mx + mw - 10 * s, by: 18 * s) {
            c.rect(dx, mb - mh - rh + 2 * s, 8 * s, rh - 2 * s, C(0x5A6A8A))
            c.rect(dx + 2 * s, mb - mh - rh + 5 * s, 4 * s, 5 * s, C(0xFFFFFF))
        }
        for row in 0..<2 {
            for dx in stride(from: mx + 6 * s, to: mx + mw - 6 * s, by: 12 * s) {
                c.rect(dx, mb - mh + 5 * s + row * (mh / 2), 5 * s, 7 * s, C(0x3A4A6A))
                c.rect(dx, mb - mh + 5 * s + row * (mh / 2), 5 * s, s, C(0xFFFFFF))
            }
        }
        c.rect(mx - 4 * s, mb - mh / 2 - 2 * s, mw + 8 * s, 2 * s, C(0xFFFFFF))
        for dx in stride(from: mx - 2 * s, to: mx + mw + 4 * s, by: 10 * s) {
            c.rect(dx, mb - mh / 2, 3 * s, mh / 2, C(0xFFFFFF))
        }
        let tx = mx + mw - 6 * s
        c.rect(tx, mb - mh - rh - 14 * s, 14 * s, mh + rh + 14 * s, C(0xF4B8C8))
        for r in 0..<(12 * s) {
            let half = r * 3 / 4 + s
            c.rect(tx + 7 * s - half, mb - mh - rh - 14 * s - 12 * s + r, half * 2, 1, C(0x5A6A8A))
        }
        c.rect(tx + 4 * s, mb - mh - rh - 8 * s, 6 * s, 8 * s, C(0x3A4A6A))
        // Trees either side, the lawn, the fence.
        for (fx, r) in [(0.10, 16), (0.94, 13)] {
            let tx = x0 + Int(Double(w) * fx)
            c.rect(tx - 2 * s, mb - 20 * s, 4 * s, 20 * s, C(0x7A4A2A))
            c.circle(tx, mb - 24 * s, r * s, C(0x2E9A3A))
            c.circle(tx - 4 * s, mb - 28 * s, r * s / 2, C(0x5AC84A))
        }
        c.rect(x0, mb, w, y1 - mb, C(0x5AC84A)); c.rect(x0, mb, w, 2 * s, C(0x8AE060))
        let fb = mb + (y1 - mb) * 2 / 3
        c.rect(x0, fb - 9 * s, w, 2 * s, C(0xFFFFFF)); c.rect(x0, fb - 4 * s, w, 2 * s, C(0xFFFFFF))
        for px in stride(from: x0 + 2 * s, to: x1, by: 6 * s) {
            c.rect(px, fb - 13 * s, 4 * s, 13 * s, C(0xFFFFFF)); c.rect(px + s, fb - 14 * s, 2 * s, s, C(0xFFFFFF))
            c.rect(px + 3 * s, fb - 13 * s, s, 13 * s, C(0xD0D8E0))
        }
        for i in 0..<3 {
            cloud(c, x0 + w * (15 + i * 28) / 100, y0 + h * (12 + (i % 2) * 8) / 100, 4 * s, seed: 7600 + i)
        }
    }

    /// Pee-wee's house, all toy-box primaries: a sunny yellow kitchen papered in stripes under a red-and-white
    /// border, a long shelf crammed with toys, a red-and-blue counter with the breakfast machine running along it (a
    /// toy dinosaur on its pedestal, a ball on a ramp on stilts, a chrome toaster with a lever, a pulley and string,
    /// a griddle with a flipper, a plate with pancakes waiting), the red door and the red-and-white bike by it, on a
    /// red-and-white tiled floor. The machine's moving parts are in the moving layer. On the screen saver, a big
    /// window looks out on the sunny yard and Francis's mansion over the fence.
    static func breakfastMachineHouse(_ c: PixelCanvas, _ g: Int) {
        let s = unit(g), tall = isTall(c), f = bmFrame(c, g), k = f.k, m = f.m, top = f.top
        // The wall: yellow stripes, a red-and-white border along the top.
        for x in stride(from: 0, to: c.w, by: 4 * k) {
            c.rect(x, 0, 4 * k, g, (x / (4 * k)) % 2 == 0 ? C(0xFFE890) : C(0xFFDC6A))
        }
        c.rect(0, 0, c.w, 4 * k, bmRed)
        for x in stride(from: 0, to: c.w, by: 6 * k) { c.circle(x + 3 * k, 2 * k, k, bmWhite) }
        c.rect(0, 4 * k, c.w, k, bmBlue)
        if tall {
            // The big window onto the yard, with checked curtains, and a second shelf of toys either side.
            let wx0 = c.w * 22 / 100, wx1 = c.w * 66 / 100, wy0 = 18 * s, wy1 = top - 48 * k
            c.rect(wx0 - 4 * s, wy0 - 4 * s, wx1 - wx0 + 8 * s, wy1 - wy0 + 8 * s, bmWhite)
            bmYard(c, x0: wx0, y0: wy0, x1: wx1, y1: wy1, s: s)
            c.rect((wx0 + wx1) / 2 - 2 * s, wy0, 4 * s, wy1 - wy0, bmWhite)
            c.rect(wx0, (wy0 + wy1) / 2 - 2 * s, wx1 - wx0, 4 * s, bmWhite)
            c.rect(wx0 - 6 * s, wy1 + 4 * s, wx1 - wx0 + 12 * s, 4 * s, bmBlue)
            for side in [0, 1] {
                let cx = side == 0 ? wx0 - 8 * s : wx1 - 8 * s
                for y in stride(from: wy0 - 8 * s, to: wy1 + 2 * s, by: 4 * s) {
                    for x in stride(from: cx, to: cx + 16 * s, by: 4 * s) {
                        c.rect(x, y, 4 * s, 4 * s,
                               ((x - cx) / (4 * s) + (y - wy0) / (4 * s)) % 2 == 0 ? bmRed : bmWhite)
                    }
                }
            }
            c.rect(wx0 - 12 * s, wy0 - 10 * s, wx1 - wx0 + 24 * s, 3 * s, bmYellow)
            bmShelf(c, x0: c.w * 2 / 100, x1: wx0 - 14 * s, y: wy0 + 40 * s, k: k, seed: 3)
            bmShelf(c, x0: c.w * 2 / 100, x1: wx0 - 14 * s, y: wy0 + 80 * s, k: k, seed: 5)
            bmShelf(c, x0: wx1 + 12 * s, x1: c.w * 98 / 100, y: wy0 + 40 * s, k: k, seed: 1)
            bmShelf(c, x0: wx1 + 12 * s, x1: c.w * 98 / 100, y: wy0 + 80 * s, k: k, seed: 4)
            // A clock shaped like a sun over the door.
            let cl = (x: f.door + 9 * k, y: g - 50 * k)
            for a in stride(from: 0.0, to: 360.0, by: 30.0) {
                let e = burtonReach((Double(cl.x), Double(cl.y)), a, Double(9 * k))
                burtonLine(c, Double(cl.x), Double(cl.y), e.x, e.y, bmYellow, Double(k))
            }
            c.circle(cl.x, cl.y, 6 * k, bmRed); c.circle(cl.x, cl.y, 5 * k, bmWhite)
            c.rect(cl.x, cl.y - 4 * k, max(1, k), 4 * k, bmInk); c.rect(cl.x, cl.y, 3 * k, max(1, k), bmInk)
        }
        // The long shelf of toys over the counter.
        bmShelf(c, x0: c.w * 3 / 100, x1: c.w * 78 / 100, y: top - (tall ? 28 : 34) * k, k: k, seed: 0)
        // The door, and the bike by it.
        let dw = 18 * k, dh = 36 * k
        c.rect(f.door - 2 * k, g - dh - 2 * k, dw + 4 * k, dh + 2 * k, bmWhite)
        c.rect(f.door, g - dh, dw, dh, bmRed); c.rect(f.door + dw - 2 * k, g - dh, 2 * k, dh, bmRedD)
        c.circle(f.door + dw / 2, g - dh + 8 * k, 4 * k, bmWhite)
        c.circle(f.door + dw / 2, g - dh + 8 * k, 3 * k, C(0x8ACCF8))
        c.rect(f.door + 3 * k, g - dh + 16 * k, dw - 6 * k, 14 * k, bmRedD)
        c.rect(f.door + 4 * k, g - dh + 17 * k, dw - 8 * k, 12 * k, bmRed)
        c.circle(f.door + dw - 4 * k, g - dh / 2, k, bmYellow)
        bmBike(c, x: f.bike, base: g, k: k)
        // The counter: red cupboards with white knobs, a blue top.
        c.rect(f.x0, top, f.x1 - f.x0, g - top, bmRed)
        for x in stride(from: f.x0 + k, to: f.x1 - 10 * k, by: 12 * k) {
            c.rect(x, top + 4 * k, 10 * k, g - top - 7 * k, bmRedD)
            c.rect(x + k, top + 5 * k, 8 * k, g - top - 9 * k, bmRed)
            c.circle(x + 5 * k, top + 7 * k, k, bmWhite)
        }
        c.rect(f.x0, g - 3 * k, f.x1 - f.x0, 3 * k, bmInk)
        c.rect(f.x0 - 2 * k, top - k, f.x1 - f.x0 + 4 * k, 3 * k, bmBlue)
        c.rect(f.x0 - 2 * k, top - k, f.x1 - f.x0 + 4 * k, k, C(0x6AA0F0))
        c.rect(f.x0 - 2 * k, top + 2 * k, f.x1 - f.x0 + 4 * k, k, bmBlueD)
        // The machine's still parts. The dinosaur's pedestal.
        c.rect(f.x0 + 2 * m, top - 5 * m, 10 * m, 4 * m, bmYellow); c.rect(f.x0 + 2 * m, top - 4 * m, 10 * m, m, bmRed)
        // The ramp on its stilts, a stop at its top end.
        let r = f.ramp
        for n in 0...4 {
            let q = Double(n) / 4
            let x = Double(r.x0) + Double(r.x1 - r.x0) * q
            let y = Double(r.y0) + Double(r.y1 - r.y0) * q
            c.rect(Int(x) - m / 2, Int(y), max(1, m), top - Int(y), bmYellow)
        }
        burtonLine(c, Double(r.x0), Double(r.y0), Double(r.x1), Double(r.y1), bmBlue, Double(m))
        burtonLine(c, Double(r.x0), Double(r.y0) + Double(m), Double(r.x1), Double(r.y1) + Double(m), bmBlueD,
                   Double(m) * 0.5)
        // The toaster: chrome, two slots, a red lever on its side.
        let tx = f.toaster
        c.rect(tx, top - 10 * m, 12 * m, 9 * m, bmChrome); c.ellipse(tx + 6 * m, top - 10 * m, 6 * m, m, bmChrome)
        c.rect(tx + 10 * m, top - 10 * m, 2 * m, 9 * m, bmChromeD); c.rect(tx + m, top - 8 * m, m, 6 * m, bmWhite)
        c.rect(tx + 2 * m, top - 11 * m, 3 * m, m, bmInk); c.rect(tx + 7 * m, top - 11 * m, 3 * m, m, bmInk)
        c.rect(tx - m, top - 6 * m, m, 3 * m, bmInk); c.rect(tx - 3 * m, top - 6 * m, 2 * m, 2 * m, bmRed)
        // The pulley on its post, its string from the toaster over to the flipper.
        let pl = (x: tx + 17 * m, y: top - 14 * m)
        c.rect(pl.x - m / 2, pl.y, max(1, m), top - pl.y, bmGreen)
        c.circle(pl.x, pl.y, 2 * m, bmRed)
        c.circle(pl.x, pl.y, m / 2, bmWhite)
        burtonLine(c, Double(tx + 6 * m), Double(top - 11 * m), Double(pl.x - 2 * m), Double(pl.y), bmInk, 0.4)
        burtonLine(c, Double(pl.x + 2 * m), Double(pl.y), Double(f.griddle + 13 * m), Double(top - 6 * m), bmInk, 0.4)
        // The griddle on its little red stove.
        c.rect(f.griddle, top - 4 * m, 15 * m, 4 * m, bmRed); c.rect(f.griddle, top - 4 * m, 15 * m, m, C(0xFF6A5A))
        c.rect(f.griddle + 2 * m, top - m, 2 * m, m, bmInk); c.rect(f.griddle + 11 * m, top - m, 2 * m, m, bmInk)
        c.rect(f.griddle + m, top - 5 * m, 12 * m, m, bmInk)
        c.rect(f.griddle + 13 * m, top - 6 * m, 2 * m, 2 * m, bmChromeD)
        // The plate with pancakes waiting, butter and syrup.
        c.ellipse(f.plate, top - m, 8 * m, m, bmWhite); c.rect(f.plate - 8 * m, top - m, 16 * m, m, C(0xD8D8E0))
        for n in 0..<2 {
            c.ellipse(f.plate, top - 3 * m - n * 2 * m, 5 * m, m, bmPancake)
            c.rect(f.plate - 5 * m, top - 3 * m - n * 2 * m, 10 * m, max(1, m / 2), C(0xF0C070))
        }
        let sy = f.plate - 14 * m
        c.rect(sy, top - 10 * m, 4 * m, 9 * m, C(0x9A4A1A))
        c.rect(sy + m, top - 12 * m, 2 * m, 2 * m, bmRed)
        c.rect(sy, top - 6 * m, 4 * m, 2 * m, bmWhite)
        // A cereal box at the end of the counter.
        c.rect(f.x1 - 10 * m, top - 14 * m, 8 * m, 13 * m, bmBlue)
        c.rect(f.x1 - 9 * m, top - 12 * m, 6 * m, 5 * m, bmYellow)
        c.circle(f.x1 - 6 * m, top - 4 * m, m, bmRed)
        // The tiled floor, red and white.
        let tile = 4 * k
        for y in stride(from: g, to: c.h, by: tile) {
            for x in stride(from: 0, to: c.w, by: tile) {
                c.rect(x, y, tile, tile, ((x + y - g) / tile) % 2 == 0 ? bmWhite : bmRed)
            }
        }
        c.rect(0, g, c.w, k, C(0x1A4AA8))
    }

    /// What moves in Pee-wee's kitchen: the breakfast machine running its loop every eight seconds. The dinosaur
    /// tips over onto the ball, the ball rolls down the ramp and hits the toaster's lever, the toast pops up, the
    /// string snaps the flipper over, and the pancake flies, flipping, onto the plate. Then everything sets itself
    /// back up.
    static func breakfastMachineHouseLife(_ c: PixelCanvas, _ g: Int, _ t: Double) {
        let f = bmFrame(c, g), m = f.m, top = f.top, u = bmPhase(t)
        func ramp(_ a: Double, _ b: Double, _ x: Double) -> Double { max(0, min(1, (x - a) / (b - a))) }
        // The dinosaur, tipping forward about its front foot.
        let dino = [
            ".......GGGG.",
            "......GGWKGG",
            "......GGGGGG",
            "......GGGRRR",
            ".....GGGG...",
            ".D..GGGGGG..",
            "DDGGGGGGG.G.",
            ".DGGGGGYG...",
            "..DGGGGGG...",
            "...GG..GG...",
            "...GG..GG...",
        ]
        let tip = ramp(0.04, 0.12, u) * 72 - ramp(0.86, 0.96, u) * 72
        bmTurned(c, dino, ["G": bmGreen, "D": C(0x22803A), "W": bmWhite, "K": bmInk, "R": bmRed, "Y": bmYellow],
                 at: (9, 11),
                 x: Double(f.dino), y: Double(top - 5 * m), angle: tip, k: m)
        // The ball rolling down the ramp, gone at the bottom while everything resets, back at the top.
        let r = f.ramp, roll = pow(ramp(0.12, 0.38, u), 1.6)
        let bx = Double(r.x0 + 2 * m) + Double(r.x1 - r.x0 - 3 * m) * roll
        let by = Double(r.y0) + Double(r.y1 - r.y0) * roll - Double(2 * m)
        let ballA = u < 0.88 ? 1 : (u < 0.92 ? 1 - (u - 0.88) / 0.04 : 0)
        if ballA > 0 {
            c.circle(Int(bx), Int(by), 2 * m, C(0xE8302A, ballA))
            c.rect(Int(bx) - m, Int(by) - m, max(1, m), max(1, m), C(0xFFFFFF, ballA))
        }
        if u > 0.92 { c.circle(r.x0 + 2 * m, r.y0 - 2 * m, 2 * m, C(0xE8302A, (u - 0.92) / 0.08)) }
        // The toast, popping up with a bounce.
        let pop = ramp(0.38, 0.43, u), sink = ramp(0.9, 0.96, u)
        let lift = (pop < 1 ? pop * 1.3 : 1 + 0.15 * sin(ramp(0.43, 0.5, u) * .pi)) * (1 - sink)
        let ty = top - 12 * m - Int(lift * Double(5 * m))
        for sx in [f.toaster + 2 * m, f.toaster + 7 * m] {
            c.rect(sx, ty, 3 * m, 6 * m, C(0xD89A50)); c.rect(sx, ty, 3 * m, m, C(0x9A5A2A))
        }
        c.rect(f.toaster, top - 10 * m, 12 * m, 3 * m, C(0xC8D0D8))
        c.rect(f.toaster + 10 * m, top - 10 * m, 2 * m, 3 * m, C(0x8A96A0))
        c.rect(f.toaster + 2 * m, top - 11 * m, 3 * m, m, C(0x1E1E28))
        c.rect(f.toaster + 7 * m, top - 11 * m, 3 * m, m, C(0x1E1E28))
        c.ellipse(f.toaster + 6 * m, top - 10 * m, 6 * m, m, C(0xC8D0D8))
        // The flipper on its hinge, snapping over and back.
        let hinge = (x: Double(f.griddle + 13 * m), y: Double(top - 6 * m))
        let swing = 180 + 105 * ramp(0.46, 0.5, u) - 105 * ramp(0.6, 0.7, u)
        let end = burtonReach(hinge, swing, Double(11 * m))
        burtonLine(c, hinge.x, hinge.y, end.x, end.y, C(0x8A96A0), Double(m) * 0.6)
        let blade = burtonReach(hinge, swing, Double(7 * m))
        let side = burtonReach(blade, swing - 90, Double(m)), side2 = burtonReach(end, swing - 90, Double(m))
        burtonTriangle(c, (blade.x, blade.y), (end.x, end.y), (side2.x, side2.y), C(0xC8D0D8))
        burtonTriangle(c, (blade.x, blade.y), (side.x, side.y), (side2.x, side2.y), C(0xC8D0D8))
        // The pancake: on the griddle, flying and flipping, on the plate, then a fresh one on the griddle.
        let fly = ramp(0.48, 0.72, u)
        let start = (x: Double(f.griddle + 6 * m), y: Double(top - 7 * m))
        let land = (x: Double(f.plate), y: Double(top - 7 * m))
        let px = start.x + (land.x - start.x) * fly
        let py = start.y + (land.y - start.y) * fly - sin(fly * .pi) * Double(13 * m)
        let flat = abs(cos(fly * .pi * 3)), a = u < 0.88 ? 1 : max(0, 1 - (u - 0.88) / 0.04)
        let ry = max(1, Int((Double(3 * m) * (1 - flat) + Double(m) * flat).rounded()))
        if a > 0 {
            c.ellipse(Int(px), Int(py), 5 * m, ry, C(0xE0A050, a))
            c.rect(Int(px) - 4 * m, Int(py) - ry, 8 * m, max(1, m / 2), C(0xF0C070, a))
            if fly >= 1 { c.rect(Int(px) - m, Int(py) - 2 * m, 2 * m, m, C(0xFFF0A0, a)) }
        }
        if u > 0.92 { c.ellipse(Int(start.x), Int(start.y), 5 * m, m, C(0xE0A050, (u - 0.92) / 0.08)) }
    }
}
