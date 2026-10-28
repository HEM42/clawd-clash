import Foundation

// Heroes: Edward Scissorhands. From the castle on the hill, Edward Scissorclawds, the unfinished boy with scissors for
// hands, and the Inventor who made him; from the pastel suburb below, Kim Boggz and her mother Peg, the Avon lady.

let burtonHeroes3: [BurtonHero: Persona] = [
    .edwardScissorclawds: Persona(name: "Edward Scissorclawds", weapon: .saber, headTop: 13, signature: 3.8,
                                  callout: "I'm not finished.", draw: drawEdward),
    .kimBoggz: Persona(name: "Kim Boggz", weapon: .none, headTop: 20, signature: 3.6, draw: drawKim),
    .pegBoggz: Persona(name: "Peg Boggz", weapon: .none, headTop: 18, signature: 3.2, callout: "Avon calling!",
                       draw: drawPeg),
    .theInventor: Persona(name: "The Inventor", weapon: .none, headTop: 20, signature: 3.2, draw: drawInventor),
]

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// `art` drawn on a layer of its own at the canvas's current origin, laid over `c` at `alpha` (props fading in).
private func faded(_ c: PixelCanvas, _ alpha: Double, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    c.paste(s, alpha: alpha)
    c.ox = ox; c.oy = oy; c.baseY = by
}

// MARK: - Edward Scissorclawds

/// Edward Scissorclawds: the Clawd block deathly pale, dark rings round his eyes and a few little scars, a wild black
/// mane bursting out over the top of him, black leather strapped and buckled over the bottom of him and down his
/// legs, and in place of hands, bunches of long thin silver scissor blades splayed out, dark between each blade and
/// the next. He fights with them, snipping. Signature: a hedge appears in front of him and his blades flash through
/// it, leaves flying, until it's a little dinosaur.
private func drawEdward(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xE8E6EE), skinD = C(0xC4C2D0), leather = C(0x1C1A20), leatherL = C(0x3A3644), leatherD = C(0x0E0D12)
    let buckle = C(0xC0C4CE), hair = C(0x111014), hairL = C(0x2C2A36)
    let sig = p.signature
    let hedgeA = sig.map { min(ramp($0, 0.03, 0.14), 1 - ramp($0, 0.86, 0.97)) } ?? 0
    let cut = sig.map { ramp($0, 0.18, 0.7) } ?? 0
    let snipping = sig.map { $0 > 0.16 && $0 < 0.72 } ?? false
    if hedgeA > 0 { faded(c, hedgeA) { edwardHedge($0, cut: cut, t: p.t, snipping: snipping) } }

    drawLegs(c, Look(leg: leather), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let y = p.step >= 0 && i % 2 == p.step ? 38 : 39
            c.rect(lx, y, 2, 1, leatherL); c.px(lx, y, buckle)
        }
    }
    burtonBoots(c, step: p.step, leatherD, height: 2)
    c.oy += p.breathe
    // The wild black mane, spikes bursting out every which way over the top of him.
    for k in 0..<13 {
        let a = (170.0 + 200.0 * Double(k) / 12 + sin(p.lt * 1.7 + Double(k)) * 2) * .pi / 180
        let len = 10 + noise(k + 5200) * 3, cx = 28.0, cy = 26.0
        let tip = (cx + cos(a) * len * 1.2, cy + sin(a) * len)
        let nx = -sin(a), ny = cos(a), r0 = 3.0, w = 2.2
        burtonTriangle(c, tip, (cx + cos(a) * r0 + nx * w, cy + sin(a) * r0 + ny * w),
                       (cx + cos(a) * r0 - nx * w, cy + sin(a) * r0 - ny * w), k % 3 == 1 ? hairL : hair)
    }
    c.ellipse(28, 24, 8, 2, hair)
    // The pale block: dark-ringed eyes, little scars, a small uncertain mouth; a ragged fringe over its top edge.
    drawBody(c, Look(body: skin, shade: skinD, arm: leather, eye: nil))
    for ex in [21, 31] { c.rect(ex, 28, 4, 5, C(0xB0A8BE)); c.rect(ex + 1, 29, 2, 3, ink) }
    c.px(26, 28, C(0xB89AA8)); c.px(27, 29, C(0xB89AA8)); c.px(34, 33, C(0xB89AA8)); c.px(20, 33, C(0xB89AA8))
    c.rect(27, 32, 3, 1, C(0x8A7484))
    for (x, len) in [(20, 2), (24, 3), (28, 1), (31, 3), (35, 2)] {
        burtonTriangle(c, (Double(x) - 1.5, 25.5), (Double(x) + 1.5, 25.5), (Double(x), 25.5 + Double(len)), hair)
    }
    // Black leather over the bottom of him: straps across it, silver buckles.
    c.rect(18, 33, 20, 5, leather); c.rect(37, 33, 1, 5, leatherD)
    c.rect(18, 34, 20, 1, leatherL); c.rect(18, 36, 20, 1, leatherL)
    for (x, y) in [(22, 34), (31, 34), (26, 36), (34, 36)] { c.rect(x, y, 2, 1, buckle) }
    c.pattern(25, 33, ["L....L", ".L..L."], ["L": leatherL])

    // The left hand: a bunch of blades splayed out behind him (tipped up when he sits, clear of the floor).
    let tilt = seatedPose ? 14.0 : 0
    c.rect(15, 33, 3, 3, leather); c.px(16, 34, buckle)
    edwardBlades(c, from: (16, 35.5), angle: 180 + tilt, spread: 14, lengths: [10, 12, 11, 10])
    // The right hand: the blades swung along `p.melee`, snipping while he sculpts, or splayed out at his side.
    c.rect(38, 33, 3, 3, leather); c.px(39, 34, buckle)
    if snipping {
        let a = -18 + sin(p.t * 9) * 16
        edwardBlades(c, from: Sprite.hand, angle: a, spread: 5 + 6 * abs(sin(p.t * 30)), lengths: [10, 12, 9])
    } else if let a = p.melee {
        for (i, ta) in p.trail.enumerated() {
            let e = burtonReach(Sprite.hand, ta, 11)
            c.glowLine(Sprite.hand.x, Sprite.hand.y, e.x, e.y, core: C(0xE8ECF4), glow: C(0xE8ECF4), coreR: 0.8,
                       glowR: 2.2, strength: 0.3 / Double(i + 1))
        }
        edwardBlades(c, from: Sprite.hand, angle: a, spread: 11, lengths: [10, 12, 9])
    } else {
        edwardBlades(c, from: Sprite.hand, angle: -tilt, spread: 14, lengths: [11, 12, 11, 10])
    }
}

/// A bunch of scissor blades fanned out from `h` along `angle` (degrees), `spread` apart, riveted to a knuckle
/// plate: each a long thin blade a pixel wide, bright steel, duller near its root, a dark gap between one blade and
/// the next.
private func edwardBlades(_ c: PixelCanvas, from h: (x: Double, y: Double), angle: Double, spread: Double,
                          lengths: [Double]) {
    let steel = C(0x868C98), steelL = C(0xDCE0E8), gap = C(0x2A2C36)
    /// A hard one-pixel line, no softening.
    func pixels(_ p: (x: Double, y: Double), _ q: (x: Double, y: Double), _ col: Px) {
        let n = max(1, Int(max(abs(q.x - p.x), abs(q.y - p.y)).rounded(.up)))
        for k in 0...n {
            let f = Double(k) / Double(n)
            c.px(Int((p.x + (q.x - p.x) * f).rounded(.down)), Int((p.y + (q.y - p.y) * f).rounded(.down)), col)
        }
    }
    // Each blade rooted on its own knuckle, two pixels from the next, across the way the bunch points.
    let r = angle * .pi / 180, mid = Double(lengths.count - 1) / 2
    let blades = lengths.enumerated().map { i, len -> (root: (x: Double, y: Double), tip: (x: Double, y: Double)) in
        let k = Double(i) - mid, a = angle + spread * k
        let root = (x: h.x + cos(r) * 0.5 - sin(r) * k * 2, y: h.y + sin(r) * 0.5 + cos(r) * k * 2)
        return (root, burtonReach(root, a, len))
    }
    // The dark between the blades first, out to where the gap is wide enough not to fill with outline.
    func toward(_ p: (x: Double, y: Double), _ q: (x: Double, y: Double), _ f: Double) -> (Double, Double) {
        (p.x + (q.x - p.x) * f, p.y + (q.y - p.y) * f)
    }
    for (b, n) in zip(blades, blades.dropFirst()) {
        let bt = toward(b.root, b.tip, 0.6), nt = toward(n.root, n.tip, 0.6)
        burtonTriangle(c, (b.root.x, b.root.y), (n.root.x, n.root.y), nt, gap)
        burtonTriangle(c, (b.root.x, b.root.y), nt, bt, gap)
    }
    // The knuckle plate they're riveted to.
    if let f = blades.first, let l = blades.last {
        burtonLine(c, f.root.x, f.root.y, l.root.x, l.root.y, C(0x5A5E68), 1)
    }
    for b in blades {
        pixels(b.root, b.tip, steelL)
        let s = toward(b.root, b.tip, 0.3)
        pixels(b.root, (x: s.0, y: s.1), steel)
    }
}

/// The hedge he sculpts, in front of him: a round green bush; as `cut` goes 0…1 everything that isn't the little
/// dinosaur inside it is snipped away, leaves falling.
private func edwardHedge(_ c: PixelCanvas, cut: Double, t: Double, snipping: Bool) {
    let leaf = C(0x3E8030), leafL = C(0x62A846), leafD = C(0x275A20)
    let dino = [
        "..............DDDD.",
        ".............DDDDDD",
        ".............DDD...",
        "............DDD....",
        "............DDD....",
        "...........DDD.....",
        "......DDDDDDDD.....",
        "....DDDDDDDDDDD....",
        "..DDDDDDDDDDDDDD...",
        "DDDDDDDDDDDDDDDD...",
        ".DDDDDDDDDDDDDDD...",
        "....DD.DD..DD.DD...",
        "....DD.DD..DD.DD...",
        "....DD.DD..DD.DD...",
    ]
    let ox = 47, oy = 28
    func inDino(_ x: Int, _ y: Int) -> Bool {
        let r = y - oy, k = x - ox
        guard r >= 0, r < dino.count, k >= 0, k < 19 else { return false }
        return Array(dino[r])[k] == "D"
    }
    // How far each bit of bush is from the dinosaur: the snipping works in from the outside.
    var shape: [(Int, Int)] = []
    for (r, row) in dino.enumerated() {
        for (k, ch) in row.enumerated() where ch == "D" { shape.append((ox + k, oy + r)) }
    }
    for y in 24...41 {
        for x in 45...67 {
            let dx = (Double(x) + 0.5 - 56.5) / 11, dy = (Double(y) + 0.5 - 33.5) / 9
            let bush = dx * dx + dy * dy <= 1
            let d = inDino(x, y)
            if !d {
                guard bush, cut < 1 else { continue }
                let far = shape.reduce(99) { min($0, max(abs($1.0 - x), abs($1.1 - y))) }
                guard Double(far) <= (1 - cut) * 9 + noise(x * 71 + y * 13) * 0.8 else { continue }
            }
            let n = noise(x * 31 + y * 57)
            c.px(x, y, d && cut > 0.95 ? (y == oy + dino.count - 1 || x > 62 ? leafD : leaf)
                                        : n < 0.18 ? leafL : n > 0.8 ? leafD : leaf)
        }
    }
    // A pot of earth under it.
    c.rect(49, 42, 13, 2, C(0x6A4A30)); c.rect(49, 42, 13, 1, C(0x8A6440))
    guard snipping else { return }
    for k in 0..<6 {
        let f = frac(t * 1.6 + Double(k) / 6)
        let x = 48 + Int(noise(k * 7 + Int(t * 1.6 + Double(k) / 6) * 3) * 16), y = 28 + Int(f * 14)
        c.px(x + Int((sin(f * 9) * 1.5).rounded()), y, (k % 2 == 0 ? leafL : leaf))
    }
}

// MARK: - Kim Boggz

/// Kim Boggz: Clawd with long, wavy blonde hair falling down both sides, a fringe swept to one side, rosy cheeks, and
/// a pastel pink dress with a white collar. She doesn't fight. Signature: snow starts falling all round her (ice
/// shavings off Edward's sculpture) and she dances in it, arms up, eyes closed, swaying.
private func drawKim(_ c: PixelCanvas, _ p: Pose) {
    let dress = C(0xF0C4D4), dressD = C(0xD4A0B8), collar = C(0xFAF6F2)
    let hair = C(0xF0D488), hairD = C(0xC8A858), hairL = C(0xFFF0BC)
    let sig = p.signature
    let snow = sig.map { min(ramp($0, 0.02, 0.15), 1 - ramp($0, 0.85, 0.98)) } ?? 0
    let dancing = sig.map { $0 > 0.12 && $0 < 0.88 } ?? false
    if snow > 0 {
        for k in 0..<22 {
            let f = frac(p.t * 0.22 + noise(k * 3 + 1))
            let x = 4 + noise(k * 5 + 2) * 62 + sin(p.t * 1.5 + Double(k)) * 2, y = 2 + f * 40
            let a = snow * min(1, (1 - f) * 4) * 0.9
            c.px(Int(x), Int(y), C(0xFFFFFF, a))
            if k % 3 == 0 {
                c.px(Int(x) + 1, Int(y), C(0xFFFFFF, a * 0.5));
                c.px(Int(x), Int(y) + 1, C(0xFFFFFF, a * 0.5))
            }
        }
    }
    let sway = dancing ? Int((sin(p.t * 4) * 1.6).rounded()) : 0

    drawLegs(c, Look(), step: p.step)
    burtonBoots(c, step: p.step, C(0xF4F0EC), height: 1)
    c.oy += p.breathe
    c.ox += sway
    // The long hair down her back and sides, swinging out as she dances.
    let swing = dancing ? Int((sin(p.t * 4 - 0.6) * 2).rounded()) : 0
    for y in 26...36 where !(seatedPose && y > 35) {
        let out = y > 31 ? swing : 0
        c.rect(15 - max(0, -out), y, 3, 1, y % 3 == 0 ? hairD : hair)
        c.rect(38 + max(0, out), y, 3, 1, y % 3 == 1 ? hairD : hair)
    }
    // The dress: its skirt over the tops of her legs, the bodice over the bottom of Clawd, a white collar.
    c.rect(17, 38, 22, seatedPose ? 1 : 2, dress); c.rect(37, 38, 2, seatedPose ? 1 : 2, dressD)
    drawBody(c, Look(arm: dress, eye: dancing ? nil : ink))
    if dancing { for ex in [22, 32] { c.pattern(ex - 1, 30, ["K..K", ".KK."], ["K": ink]) } }
    c.px(20, 32, C(0xF09A9A)); c.px(35, 32, C(0xF09A9A))
    c.rect(18, 33, 20, 5, dress); c.rect(37, 33, 1, 5, dressD); c.rect(18, 37, 20, 1, dressD)
    c.pattern(23, 33, ["CCCCCCCCCC", ".CCC..CCC."], ["C": collar])
    c.px(28, 35, collar); c.px(28, 36, dressD)
    c.rect(18, 22, 20, 4, clawdOrange); c.rect(37, 22, 1, 4, clawdShade)
    // The top of her hair, the fringe swept across.
    c.pattern(16, 20, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHHHHHHlHHHHHH...",
        "..HHHHHHHlllHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHd.",
        ".HHHHHHHHHHHHH.....HHHd.",
        ".HHHHHH............HHHd.",
        ".HHH................HHd.",
    ], ["H": hair, "l": hairL, "d": hairD])
    // Her arms: both up over her head while she dances, at her sides otherwise.
    if dancing {
        let lift = 1 + Int((sin(p.t * 4) * 1).rounded())
        burtonLine(c, 16.5, 34, 13, Double(23 + lift), dress, 1.1); c.rect(12, 21 + lift, 2, 2, clawdOrange)
        burtonLine(c, 39.5, 34, 43, Double(23 - lift), dress, 1.1); c.rect(42, 21 - lift, 2, 2, clawdOrange)
    }
}

// MARK: - Peg Boggz

/// Peg Boggz: the Avon lady, all smiles: Clawd with short, curly auburn hair puffed up on top, blue eyeshadow, rosy
/// cheeks and pink lips, a lilac skirt suit with a white blouse at the collar, and her make-up case in her hand. She
/// doesn't fight. Signature: she holds the case up and opens it, rows of lipsticks and compacts inside.
private func drawPeg(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0xB8A2DA), suitD = C(0x9682BE), suitL = C(0xD0C0EC), hair = C(0x9A4A2A), hairL = C(0xC0683E)
    let hairD = C(0x6E3018), case_ = C(0xF0D8E0), caseD = C(0xC8A8B8)
    let sig = p.signature
    let lift = sig.map { min(ramp($0, 0.06, 0.2), 1 - ramp($0, 0.84, 0.96)) } ?? 0
    let open = sig.map { min(ramp($0, 0.22, 0.32), 1 - ramp($0, 0.74, 0.82)) } ?? 0

    drawLegs(c, Look(), step: p.step)
    burtonBoots(c, step: p.step, C(0x7A5AA8), height: 1)
    c.oy += p.breathe
    // The skirt over the tops of her legs, the jacket over the bottom of Clawd, the blouse's white bow.
    c.rect(18, 38, 20, seatedPose ? 1 : 2, suit); c.rect(37, 38, 1, seatedPose ? 1 : 2, suitD)
    drawBody(c, Look(arm: suit))
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(25, 33, ["LWWWWL", ".LWWL."], ["W": C(0xFAF8F4), "L": suitL])
    c.px(22, 36, C(0xE8D8F8)); c.px(33, 36, C(0xE8D8F8))
    // Her made-up face: blue eyeshadow, rosy cheeks, a big pink smile.
    c.rect(22, 28, 2, 1, C(0x6A9AE0)); c.rect(32, 28, 2, 1, C(0x6A9AE0))
    c.px(20, 31, C(0xF08AA0)); c.px(35, 31, C(0xF08AA0))
    c.pattern(25, 31, ["P....P", ".PPPP."], ["P": C(0xD83A6A)])
    c.rect(18, 21, 20, 5, clawdOrange); c.rect(37, 21, 1, 5, clawdShade)
    // Short curly auburn hair, puffed up on top.
    c.pattern(16, 18, [
        ".......hHHhHHhHH........",
        ".....HHHHHHHHHHHHHH.....",
        "...HHhHHHHhHHHHhHHHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        ".HHHHhHHHHHHHhHHHHHHHHd.",
        ".HHHHHHHHHHHHHHHHHHHHHd.",
        ".HHHHH.HH..HHH..HH.HHHd.",
        ".HHH................HHd.",
        "..HH................Hd..",
        "..d..................d..",
    ], ["H": hair, "h": hairL, "d": hairD])
    // The make-up case: down at her side, or held up and opened.
    if lift > 0 {
        let y = 36 - Int((lift * 6).rounded())
        burtonLine(c, 39.5, 34, 41, Double(y + 3), suit, 1.1)
        c.rect(39, y, 11, 6, case_); c.rect(39, y + 5, 11, 1, caseD);
        c.rect(49, y, 1, 6, caseD); c.rect(43, y + 2, 3, 1, C(0xD8B040))
        if open > 0 {
            // The lid up, its mirror flashing; lipsticks and compacts in rows inside.
            let h = Int((open * 6).rounded())
            if h > 0 {
                c.rect(39, y - h, 11, h, case_); c.rect(40, y - h + 1, 9, max(0, h - 2), C(0xD8E8F4))
                c.rect(39, y - 1, 11, 1, caseD)
            }
            if open > 0.8 {
                c.pattern(40, y, ["RrPRrPRrP", "CCcCCcCCc"], ["R": C(0xC8203A), "r": C(0xE85A7A), "P": C(0xE8A0C0),
                                                               "C": C(0xF4E4C8), "c": C(0xC8B080)])
                if frac(p.t * 2) < 0.3 { c.px(42, y - h + 2, C(0xFFFFFF)) }
            }
        }
    } else {
        c.rect(40, 36, 1, 1, C(0xD8B040))
        c.rect(38, 37, 9, 5, case_); c.rect(38, 41, 9, 1, caseD); c.rect(46, 37, 1, 5, caseD)
        c.pattern(40, 35, ["HHHHH", "H...H"], ["H": caseD]); c.rect(41, 39, 3, 1, C(0xD8B040))
    }
}

// MARK: - The Inventor

/// The Inventor: an old gentleman, Clawd a little paler, silver hair swept back from a high brow, a thin moustache,
/// a burgundy velvet smoking jacket with black satin lapels and a white cravat. He doesn't fight. Signature: he holds
/// up a heart-shaped biscuit, beaming at it.
private func drawInventor(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xE0A88E), skinD = C(0xC08A70), velvet = C(0x6E1A2C), velvetL = C(0x8E2E40), velvetD = C(0x4C0E1C)
    let satin = C(0x1A1418), hair = C(0xC8C8D0), hairD = C(0x9A9AA6)
    let sig = p.signature
    let up = sig.map { min(ramp($0, 0.08, 0.24), 1 - ramp($0, 0.8, 0.94)) } ?? 0

    drawLegs(c, Look(leg: C(0x3A3640)), step: p.step)
    burtonBoots(c, step: p.step, C(0x141216), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(body: skin, shade: skinD, arm: velvet))
    // A kindly face: lines under the eyes.
    c.px(21, 32, skinD); c.px(34, 32, skinD)
    // The velvet smoking jacket over the bottom of him: quilted, black satin lapels, the white cravat.
    c.rect(18, 33, 20, 5, velvet); c.rect(37, 33, 1, 5, velvetD); c.rect(18, 37, 20, 1, velvetD)
    for (x, y) in [(20, 35), (23, 36), (33, 35), (35, 36)] { c.px(x, y, velvetL) }
    c.pattern(22, 33, ["SSSWWWWWWSSS", ".SSSWWWWSSS.", "..SSS..SSS..", "...S....S..."],
              ["S": C(0x3A1622), "W": C(0xF4F0E8)])
    c.px(28, 35, C(0xD8B040)); c.px(15, 35, satin); c.px(40, 35, satin)
    // The thin moustache under the eyes, one shape, and below it his smile over the top of the cravat (broad, its
    // corners turned up, while he admires the biscuit).
    c.pattern(24, 32, [up > 0.5 ? "K......K" : "........", up > 0.5 ? ".KKKKKK." : "...KK..."], ["K": C(0x7A3A3A)])
    c.rect(25, 32, 6, 1, C(0x5A5660))
    // His high brow, up under the hair.
    c.rect(18, 23, 20, 3, skin); c.rect(37, 23, 1, 3, skinD)
    // Silver hair, swept back from a high brow, longer at the back.
    c.pattern(16, 20, [
        "......HHHHHHHHHHH.......",
        "....HHHHHHHHHHHHHHH.....",
        "..HHhhhhHHHHHHHHHHHHH...",
        ".HHHHHHHHHHHHHHHHHHHHH..",
        ".HHH.............HHHHHh.",
        ".HH...............HHHHh.",
        "HH.................HHhh.",
        "Hh..................Hh..",
    ], ["H": hair, "h": hairD])
    // The heart-shaped biscuit, held up in his right hand.
    if up > 0 {
        let hy = 33 - Int((up * 9).rounded())
        burtonLine(c, 39.5, 34, 42, Double(hy + 2), velvet, 1.2); c.rect(41, hy, 3, 2, skin)
        c.pattern(39, hy - 7, [".BB.BB.", "BbBBBBB", "BBBBBbB", "BBBBBBB", ".BBBBB.", "..BBB..", "...B..."],
                  ["B": C(0xC8884A), "b": C(0xF4E4C8)])
        if up > 0.9 && frac(p.t * 1.5) < 0.4 { c.pattern(46, hy - 9, [".W.", "WWW", ".W."], ["W": C(0xFFFFFF, 0.9)]) }
    }
}
