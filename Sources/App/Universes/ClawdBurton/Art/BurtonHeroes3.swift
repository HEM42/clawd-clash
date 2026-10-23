import Foundation

// Heroes: Edward Scissorhands and Corpse Bride. From the castle on the hill, Edward Scissorclawds, the unfinished boy
// with scissors for hands, and the Inventor who made him; from the pastel suburb below, Kim Boggz and her mother Peg,
// the Avon lady. From Corpse Bride, the living, drawn in the grey-blues of their dreary town (Victor Van Dawt and
// Victoria Everclawd), and the dead, in colour: Emilee the blue bride, Scrapz the skeleton dog, Elder Gutknocked with
// his book, Bonejingles the band leader and the tiny General Bonesapart.

let burtonHeroes3: [BurtonHero: Persona] = [
    .edwardScissorclawds: Persona(name: "Edward Scissorclawds", weapon: .saber, headTop: 13, signature: 3.8,
                                  callout: "I'm not finished.", draw: drawEdward),
    .kimBoggz: Persona(name: "Kim Boggz", weapon: .none, headTop: 20, signature: 3.6, draw: drawKim),
    .pegBoggz: Persona(name: "Peg Boggz", weapon: .none, headTop: 18, signature: 3.2, callout: "Avon calling!",
                       draw: drawPeg),
    .theInventor: Persona(name: "The Inventor", weapon: .none, headTop: 20, signature: 3.2, draw: drawInventor),
    .victorVanDawt: Persona(name: "Victor Van Dawt", weapon: .none, headTop: 18, signature: 3.6,
                            callout: "With this hand…", draw: drawVictor),
    .emilee: Persona(name: "Emilee", weapon: .none, headTop: 18, signature: 3.6, callout: "I do.", draw: drawEmilee),
    .victoriaEverclawd: Persona(name: "Victoria Everclawd", weapon: .none, headTop: 16, signature: 3.0,
                                draw: drawVictoria),
    .scrapz: Persona(name: "Scrapz", weapon: .saber, pivot: scrapzMouth, headTop: 19, signature: 3.4,
                     draw: drawScrapz),
    .elderGutknocked: Persona(name: "Elder Gutknocked", weapon: .none, headTop: 25, signature: 3.6,
                              draw: drawElderGutknocked),
    .bonejingles: Persona(name: "Bonejingles", weapon: .none, headTop: 19, signature: 3.6, callout: "Hit it, boys!",
                          draw: drawBonejingles),
    .generalBonesapart: Persona(name: "General Bonesapart", weapon: .saber, pivot: generalHand, headTop: 24,
                                signature: 3.4, draw: drawGeneralBonesapart),
]

/// Scrapz's jaws: his bite snaps from there.
private let scrapzMouth = (x: 44.0, y: 29.0)
/// General Bonesapart's sword hand (he's a small one).
private let generalHand = (x: 36.5, y: 34.5)

private let bone = C(0xF2EEE3), boneD = C(0xC8C2B4)

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
/// legs, and in place of hands, bunches of long silver scissor blades. He fights with them, snipping. Signature: a
/// hedge appears in front of him and his blades flash through it, leaves flying, until it's a little dinosaur.
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

    // The left hand: a bunch of blades hanging down behind.
    c.rect(15, 33, 3, 3, leather); c.px(16, 34, buckle)
    edwardBlades(c, from: (16, 35.5), angle: 112, spread: 14, lengths: [6, 7, 5])
    // The right hand: the blades swung along `p.melee`, snipping while he sculpts, or hanging at his side.
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
        edwardBlades(c, from: Sprite.hand, angle: 72, spread: 20, lengths: [7, 8, 7])
    }
}

/// A bunch of scissor blades fanned out from `h` along `angle` (degrees), `spread` apart: each a filled silver
/// sliver, lit along one edge.
private func edwardBlades(_ c: PixelCanvas, from h: (x: Double, y: Double), angle: Double, spread: Double,
                          lengths: [Double]) {
    let steel = C(0x868C98), steelL = C(0xDCE0E8)
    for (i, len) in lengths.enumerated() {
        let a = angle + spread * Double(i - lengths.count / 2)
        let r = a * .pi / 180, sx = -sin(r), sy = cos(r)
        let base = burtonReach(h, a, 0.5), tip = burtonReach(h, a, len)
        let b0 = (base.x + sx * 1.2, base.y + sy * 1.2), b1 = (base.x - sx * 1.2, base.y - sy * 1.2)
        burtonTriangle(c, b0, b1, (tip.x, tip.y), steel)
        burtonTriangle(c, b1, (base.x, base.y), (tip.x, tip.y), steelL)
    }
    c.rect(Int(h.x) - 1, Int(h.y) - 1, 2, 2, C(0x5A5E68))
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
    // A kindly face: lines under the eyes, the thin moustache, a smile (broad while he admires the biscuit).
    c.px(21, 32, skinD); c.px(34, 32, skinD)
    c.pattern(24, 31, ["MMM..MMM", up > 0.5 ? ".K....K." : "........", up > 0.5 ? "..KKKK.." : "...KK..."],
              ["M": C(0x5A5660), "K": C(0x7A3A3A)])
    // The velvet smoking jacket over the bottom of him: quilted, black satin lapels, the white cravat.
    c.rect(18, 33, 20, 5, velvet); c.rect(37, 33, 1, 5, velvetD); c.rect(18, 37, 20, 1, velvetD)
    for (x, y) in [(20, 35), (23, 36), (33, 35), (35, 36)] { c.px(x, y, velvetL) }
    c.pattern(22, 33, ["SSSWWWWWWSSS", ".SSSWWWWSSS.", "..SSS..SSS..", "...S....S..."],
              ["S": C(0x3A1622), "W": C(0xF4F0E8)])
    c.px(28, 35, C(0xD8B040)); c.px(15, 35, satin); c.px(40, 35, satin)
    c.rect(18, 21, 20, 5, skin); c.rect(37, 21, 1, 5, skinD)
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

// MARK: - Victor Van Dawt

/// Victor Van Dawt: tall, thin and nervous, drawn in the living world's grey-blues: the block tinted grey-blue and
/// stretched a little taller, shadows under his worried eyes, dark hair neatly parted with one lock falling loose,
/// a high white collar and cravat, and a dark Victorian tailcoat, its tails over his legs. He doesn't fight.
/// Signature: he practises his vows, holding the ring out; it slips from his fingers, bounces and rolls away, and he
/// looks down at it in dismay.
private func drawVictor(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xA8B4C8), skinD = C(0x8692AC), coat = C(0x2C3040), coatL = C(0x404658), coatD = C(0x1C1E2A)
    let hair = C(0x1C1E26), hairL = C(0x343846), gold = C(0xE0B840)
    let sig = p.signature
    let holding = sig.map { $0 > 0.06 && $0 < 0.36 } ?? false
    let ringK = sig.map { ramp($0, 0.36, 0.62) } ?? 0
    let ringA = sig.map { 1 - ramp($0, 0.84, 0.96) } ?? 0
    let dismay = sig.map { $0 > 0.4 && $0 < 0.94 } ?? false

    if let s = sig, s > 0.36, ringA > 0 {
        // The dropped ring: falling, bouncing twice, rolling away along the floor.
        let x = 44 + ringK * 12
        let bounce = abs(sin(ringK * .pi * 2.5)) * 9 * (1 - ringK)
        let y = s < 0.4 ? 34 + ramp(s, 0.36, 0.4) * 8 : 42 - bounce
        faded(c, ringA) { l in l.pattern(Int(x), Int(y), [".G.", "G.G", ".G."], ["G": gold]) }
    }
    drawLegs(c, Look(leg: C(0x3A3E4C)), step: p.step)
    burtonBoots(c, step: p.step, C(0x121218), height: 1)
    c.oy += p.breathe
    // The tailcoat's tails over his legs.
    let tails = seatedPose ? 1 : 3
    c.rect(17, 38, 22, tails, coat); c.rect(28, 38, 1, tails, coatD); c.rect(17, 37 + tails, 22, 1, coatD)
    // The grey-blue block, two rows taller: worried eyes (looking down in dismay), shadows under them.
    drawBody(c, Look(body: skin, shade: skinD, arm: coat, eye: nil))
    c.rect(18, 24, 20, 2, skin); c.rect(37, 24, 1, 2, skinD)
    let ey = dismay ? 30 : 29
    c.rect(22, ey, 2, 3, ink); c.rect(32, ey, 2, 3, ink)
    c.rect(21, 33 - (dismay ? 0 : 1), 4, 1, skinD); c.rect(31, 33 - (dismay ? 0 : 1), 4, 1, skinD)
    c.pattern(21, 27, ["..K......K..", "KK........KK"], ["K": hair])
    if dismay { c.rect(27, 32, 3, 1, C(0x4A4E60)); c.pattern(36, 26, [".W", "WW", "WW"], ["W": C(0xD8ECFF, 0.85)]) }
    // The high white collar and cravat, the tailcoat over the bottom of him, open over a grey waistcoat.
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD); c.rect(19, 33, 1, 5, coatL)
    c.rect(24, 33, 8, 5, C(0x6A7080)); c.rect(24, 33, 8, 1, C(0xE8ECF0))
    c.pattern(26, 33, ["WWWW", ".KK.", ".KK."], ["W": C(0xF0F2F4), "K": C(0x1A1A22)])
    c.pattern(23, 33, ["L.........L", ".L.......L."], ["L": coatL])
    c.rect(18, 20, 20, 4, skin); c.rect(37, 20, 1, 4, skinD)
    // Dark hair, neatly parted, one lock falling loose over his brow.
    c.pattern(17, 18, [
        "....HHHHHHHHHHHHHH....",
        "..HHHHHHHHhHHHHHHHHH..",
        ".HHHHHHHHHhHHHHHHHHHH.",
        ".HHHHHHHHH.HHHHHHHHHH.",
        ".HHHHHHH...HHHHHHHHHH.",
        ".HHH........HH....HHH.",
        ".HH..........H.....HH.",
        ".H..................H.",
    ], ["H": hair, "h": hairL])
    // His right hand: holding the ring out in front of him, or at his side.
    if holding {
        burtonLine(c, 39.5, 34, 42.5, 30, coat, 1.1); c.rect(42, 28, 2, 2, skin)
        c.pattern(43, 25, [".G.", "G.G", ".G."], ["G": gold])
    } else if let s = sig, s >= 0.36, s < 0.42 {
        burtonLine(c, 39.5, 34, 42.5, 31, coat, 1.1); c.rect(42, 30, 2, 2, skin)
    }
}

// MARK: - Emilee

/// Emilee: the Corpse Bride, dead and in colour: the block pale blue, big dark eyes under long lashes and dark blue
/// lips, long dark blue hair falling down her back, a torn veil streaming out behind her, a tattered wedding dress
/// ragged at the hem, and one arm nothing but bone. She doesn't fight. Signature: a swirl of blue butterflies rises
/// off her and flutters away.
private func drawEmilee(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x92B6DA), skinD = C(0x6E92BC), hair = C(0x1E2846), hairL = C(0x36446E)
    let dress = C(0xDCE6F0), dressD = C(0xAEBED4), veil = C(0xD4E0EE), veilD = C(0xA8BAD2)
    let sig = p.signature

    drawLegs(c, Look(leg: skin), step: p.step)
    c.oy += p.breathe
    // The torn veil streaming out behind her, rippling, its edge ragged.
    for x in 6...19 {
        let d = Double(20 - x)
        let wave = sin(p.lt * 2.5 - d * 0.45) * (0.4 + d * 0.1)
        let top = 21 + d * 0.35 + d * d * 0.015 + wave, h = 3 + d * 0.4
        let torn = noise(x * 17) < 0.3 ? 1 : 0
        let y0 = Int(top.rounded()), y1 = Int((top + h).rounded()) - torn
        guard y1 > y0 else { continue }
        c.rect(x, y0, 1, y1 - y0, veil); c.px(x, y1 - 1, veilD)
        if x % 4 == 1 { c.px(x, y0 + 1, veilD) }
    }
    // Long dark blue hair down her back.
    c.rect(15, 24, 4, 12, hair); c.rect(15, 26, 1, 9, hairL)
    // The tattered dress: ragged over her legs, the bodice over the bottom of her.
    let hem = seatedPose ? 38 : 40
    for x in 16...39 {
        let rag = noise(x * 29) < 0.4 ? 1 : 0
        c.rect(x, 38, 1, hem - 38 + 1 - rag, x > 36 ? dressD : dress)
    }
    drawBody(c, Look(body: skin, shade: skinD, arm: skin, eye: nil))
    // Big dark eyes, long lashes, the dark blue lips.
    for ex in [21, 31] {
        c.pattern(ex, 27, ["K..K", ".KKK", "KKKK", "KWKK", "KKKK"], ["K": C(0x10121E), "W": C(0xC8D8F0)])
    }
    c.pattern(26, 32, ["LLLL", ".LL."], ["L": C(0x2A3A6A)])
    c.rect(18, 34, 20, 4, dress); c.rect(37, 34, 1, 4, dressD)
    c.pattern(18, 33, ["DD.DDDDDDDDDDDDD.DDD", ".D..D.D....D.D..D..D"], ["D": dressD])
    c.px(25, 36, skinD); c.px(32, 35, skinD)
    c.rect(18, 22, 20, 4, skin); c.rect(37, 22, 1, 4, skinD)
    // Hair over the top of her, a little bridal headdress pinned on it.
    c.pattern(16, 19, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHHHHHHlHHHHHH...",
        "..HHHHHlHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHH....HHHHHHH.",
        ".HHHH...............HHH.",
        ".HHH.................HH.",
    ], ["H": hair, "l": hairL])
    c.pattern(20, 18, ["W.W.W", "WWWWW"], ["W": C(0xF4F4F8)])
    // The bony left arm: bare bone down to its long fingers; the right hand at her side.
    c.pattern(14, 32, [".BBB", ".BB.", ".BB.", ".BBd", "BB.B", "B..B", "B..."], ["B": bone, "d": boneD])
    if let s = sig { emileeButterflies(c, s, t: p.t) }
}

/// Her butterflies: a dozen little blue ones lifting off her one after another, spiralling up and away and fading.
private func emileeButterflies(_ c: PixelCanvas, _ s: Double, t: Double) {
    for k in 0..<12 {
        let start = 0.06 + Double(k) * 0.045, f = ramp(s, start, start + 0.5)
        guard f > 0, f < 1 else { continue }
        let side = k % 2 == 0 ? 1.0 : -1.0
        let ang = f * 5 + Double(k)
        let x = 28 + side * (11 + f * 12) + cos(ang) * 3, y = 31 - f * 26 + sin(ang) * 2
        let a = min(1, f * 6) * min(1, (1 - f) * 3) * 0.95
        let open = Int(t * 10 + Double(k)) % 2 == 0
        let ix = Int(x.rounded()), iy = Int(y.rounded())
        let pal: [Character: Px] = ["W": C(0x3A94FF, a), "L": C(0xA8DCFF, a), "B": C(0x1A2A5A, a)]
        c.pattern(ix - 2, iy - 1, open ? ["LW.WL", "WWBWW", ".W.W."] : [".LBL.", "..B.."], pal)
    }
}

// MARK: - Victoria Everclawd

/// Victoria Everclawd: gentle and shy, in the living world's grey-blues: the block pale grey-blue with a faint blush,
/// dark auburn hair neatly parted and pinned up in a bun, a grey-lilac gown with a high lace collar up her sides,
/// puffed sleeves and a long full skirt. She doesn't fight. Signature: a shy curtsey: she holds her skirt out, dips,
/// eyes lowered, blushing.
private func drawVictoria(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xBCC2D0), skinD = C(0x989EB0), gown = C(0x9C92B0), gownD = C(0x7A7092), gownL = C(0xB8AECA)
    let hair = C(0x4E302C), hairL = C(0x6E4840), lace = C(0xE4E2EC)
    let sig = p.signature
    let k = sig.map { min(ramp($0, 0.12, 0.35), 1 - ramp($0, 0.7, 0.9)) } ?? 0
    let dip = Int((k * 2).rounded()), spread = Int((k * 3).rounded())

    drawLegs(c, Look(leg: C(0x8A8698)), step: p.step)
    burtonBoots(c, step: p.step, C(0x3A3446), height: 1)
    c.oy += p.breathe + dip
    // The long full skirt, held out wider as she curtseys.
    let hem = seatedPose ? 38 : 40 - dip
    for y in 38...max(38, hem) {
        let hw = 11 + (y - 38) / 2 + spread
        c.rect(28 - hw, y, hw * 2, 1, gown); c.px(28 + hw - 1, y, gownD); c.px(28 - hw, y, gownL)
    }
    drawBody(c, Look(body: skin, shade: skinD, arm: gown, eye: k > 0.4 ? nil : ink))
    if k > 0.4 { c.rect(22, 31, 2, 1, ink); c.rect(32, 31, 2, 1, ink) }
    let blush = k > 0.4 ? C(0xD898A8) : C(0xC8A8B8)
    c.rect(20, 32, 2, 1, blush); c.rect(34, 32, 2, 1, blush)
    c.rect(27, 33, 2, 1, C(0x6A5A70))
    // The bodice over the bottom of her, and the high lace collar up her sides and round her neck.
    c.rect(18, 34, 20, 4, gown); c.rect(37, 34, 1, 4, gownD); c.rect(18, 37, 20, 1, gownD)
    c.pattern(18, 30, ["L..................L", "LL................LL", "LL................LL", ".LLLLLLL.LL.LLLLLLL."],
              ["L": lace])
    c.px(28, 35, gownL); c.px(28, 36, gownL)
    // Puffed sleeves.
    c.rect(14, 32, 4, 4, gown); c.rect(14, 32, 4, 1, gownL); c.rect(38, 32, 4, 4, gown); c.rect(41, 32, 1, 4, gownD)
    c.rect(18, 21, 20, 5, skin); c.rect(37, 21, 1, 5, skinD)
    // Neat hair, parted in the middle, pinned up in a bun at the back.
    c.pattern(18, 16, ["HHHH", "HHHH", "HhHH", ".HH."], ["H": hair, "h": hairL])
    c.pattern(16, 20, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHHHHH.HHHHHHH...",
        "..HhHHHHHHHH..HHHHHHhH..",
        ".HHHHHHHHHH....HHHHHHHH.",
        ".HHHHHHH..........HHHHH.",
        ".HHH................HHH.",
        ".HH..................HH.",
    ], ["H": hair, "h": hairL])
    // Curtseying: her hands holding the skirt out at her sides.
    if k > 0.3 {
        c.rect(14 - spread, 37, 2, 2, skin); c.rect(40 + spread, 37, 2, 2, skin)
    }
}

// MARK: - Scrapz

/// Scrapz: Victor's dog, long dead and all bones, at Clawd size: a skull with a long snout, a big black eye socket
/// and a bony grin, a red collar with a tag, a rib cage on four bony legs, and a tail that never stops wagging. He
/// bites. Signature: he pulls one of his own ribs out, tosses it up, catches it, and pops it back.
private func drawScrapz(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature
    let ribOut = sig.map { $0 > 0.1 && $0 < 0.86 } ?? false
    let throwK = sig.map { ramp($0, 0.22, 0.6) } ?? 0
    let flying = throwK > 0 && throwK < 1
    let jump = sig.map { $0 > 0.5 && $0 < 0.64 ? -Int((sin(ramp($0, 0.5, 0.64) * .pi) * 3).rounded()) : 0 } ?? 0
    let wag = sin(p.lt * (ribOut ? 18 : 7))

    // Four bony legs, knobbly at the knees, little paws.
    drawLegs(c, Look(leg: bone), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, lifted ? 38 : 39, 2, 1, boneD)
            c.rect(lx + (i < 2 ? 0 : 1), lifted ? 42 : 43, 2, 1, boneD)
        }
    }
    c.oy += p.breathe + jump
    // The tail, wagging.
    let tip = (x: 12.0 + wag * 1.5, y: 25.0 - abs(wag))
    burtonLine(c, 18, 30, 15, 28, bone, 0.9); burtonLine(c, 15, 28, tip.x, tip.y, bone, 0.8)
    // The rib cage: a solid barrel of bone, dark gaps between the ribs, the spine along its top.
    c.pattern(17, 27, [
        "..SSSSSSSSSSSSSSSSS..",
        ".SSSSSSSSSSSSSSSSSSS.",
        "SBBKBBKBBKBBKBBKBBKBd",
        "SBBKBBKBBKBBKBBKBBKBd",
        "SBBKBBKBBKBBKBBKBBKBd",
        "SBBKBBKBBKBBKBBKBBKBd",
        ".BBKBBKBBKBBKBBKBBKd.",
        "..BBBBBBBBBBBBBBBBB..",
        "....BBBBBBBBBBBBB....",
    ], ["S": bone, "B": bone, "K": C(0x3A3640), "d": boneD])
    if ribOut { c.rect(29, 29, 2, 5, C(0x3A3640)) }
    // The skull: on the end of the neck, snout forward; lunging and gaping while he bites.
    let biting = p.melee.map { $0 > -50 } ?? false
    let lunge = biting ? Int((max(0, 1 - abs((p.melee ?? 0) + 10) / 50) * 3).rounded()) : 0
    let gape = biting || !p.trail.isEmpty || (sig.map { $0 > 0.6 && $0 < 0.86 } ?? false)
    let hx = 33 + lunge, hy = 19
    c.rect(33, 26, 4, 3, bone)
    c.pattern(hx, hy, [
        "...EE.......",
        "..EBBBBB....",
        ".BBBBBBBB...",
        "BBBKKKBBBB..",
        "BBBKKKBBBBBB",
        "BBBKKBBBBBBN",
        ".BBBBBBBBBBN",
        "..BBBTBTBTB.",
    ], ["B": bone, "K": ink, "E": boneD, "N": ink])
    if gape {
        c.pattern(hx + 4, hy + 8, ["KKKKKKK", "BTBTBB.", "BBBBB.."], ["K": C(0x3A1A20), "B": bone, "T": boneD])
    } else {
        c.pattern(hx + 3, hy + 8, ["BBBBBBB", ".BBBBB."], ["B": bone])
    }
    // The red collar with its tag.
    c.rect(32, 26, 5, 2, C(0xC8202A)); c.px(34, 28, C(0xE0B840))
    // The thrown rib: up in an arc and back down into his jaws.
    if flying {
        let x = 46 + sin(throwK * .pi) * 4, y = 27 - sin(throwK * .pi) * 18
        let a = throwK * 720 * .pi / 180
        scrapzBone(c, x, y, angle: a)
    } else if let s = sig, s >= 0.6, s < 0.86 {
        scrapzBone(c, Double(hx + 10), Double(hy + 8), angle: 0)
    } else if let s = sig, s > 0.1, s <= 0.22 {
        scrapzBone(c, Double(hx + 10), Double(hy + 7), angle: -0.4)
    }
}

/// A bone, 7 pixels long, centred on (x, y) and turned `angle` radians: a shaft with a knob at each end.
private func scrapzBone(_ c: PixelCanvas, _ x: Double, _ y: Double, angle a: Double) {
    let ux = cos(a) * 2.8, uy = sin(a) * 2.8
    burtonLine(c, x - ux, y - uy, x + ux, y + uy, bone, 0.6)
    for e in [(x - ux, y - uy), (x + ux, y + uy)] { c.rect(Int(e.0.rounded()) - 1, Int(e.1.rounded()) - 1, 2, 2, bone) }
}

// MARK: - Elder Gutknocked

/// Elder Gutknocked: the oldest of the dead, a skeleton so ancient his bones have yellowed: the block bone-tinted
/// with small deep sockets and two tiny glints for eyes, a few wisps of hair, a long grey beard flowing down over a
/// ragged brown robe, and under his arm the huge book of the Underworld's rules. He doesn't fight. Signature: he
/// heaves the book open and thumbs through it, pages flipping.
private func drawElderGutknocked(_ c: PixelCanvas, _ p: Pose) {
    let skull = C(0xE0D8BE), skullD = C(0xB8AE94), robe = C(0x5A4A3A), robeD = C(0x3E3226), beard = C(0xD4D4DA)
    let beardD = C(0xA4A4AE), book = C(0x6A3A22), bookD = C(0x4A2414), gold = C(0xD8B040), page = C(0xF0E6CC)
    let sig = p.signature
    let reading = sig.map { $0 > 0.08 && $0 < 0.9 } ?? false

    drawLegs(c, Look(leg: skullD), step: p.step)
    c.oy += p.breathe
    // The ragged robe over his legs.
    for x in 17...38 {
        let rag = noise(x * 41 + 7) < 0.45 ? 1 : 0
        c.rect(x, 38, 1, (seatedPose ? 1 : 3) - rag, x > 35 ? robeD : robe)
    }
    drawBody(c, Look(body: skull, shade: skullD, arm: robe, eye: nil))
    // Small deep sockets with a glint in each, the nose hole.
    for ex in [21, 31] { c.rect(ex, 28, 4, 4, C(0x2A2420)); c.px(ex + 1, 29, C(0xF4ECC8)) }
    c.pattern(27, 31, ["K.K"], ["K": C(0x2A2420)])
    // The robe over the bottom of him, a rope belt.
    c.rect(18, 34, 20, 4, robe); c.rect(37, 34, 1, 4, robeD); c.rect(18, 36, 20, 1, C(0x8A7A5A))
    // The long grey beard flowing down from under his nose.
    c.pattern(21, 32, [
        "BBBBBBBBBBBBBB",
        "BBBBBBbBBBBBBb",
        ".BBBBBbBBBBBb.",
        ".BBBBBBbBBBBb.",
        "..BBBBBbBBBb..",
        "..BBBBBBbBBb..",
        "...BBBBbBBb...",
        "....BBBBBb....",
        ".....BBBb.....",
    ], ["B": beard, "b": beardD])
    // Long thin white hair straggling down the sides of his bald skull.
    c.pattern(15, 25, ["..WW................WW..", ".WWW................WWW.",
                       ".WW..................WW.", "WWW..................WWW",
                       "WW....................WW", "W.....................WW"], ["W": beard])
    c.rect(15, 33, 3, 3, robe)
    if reading {
        // The book heaved up and open in front of him, a page turning over.
        burtonLine(c, 39.5, 34, 40, 33, robe, 1.1)
        c.rect(36, 30, 17, 9, bookD)
        c.rect(37, 30, 7, 8, page); c.rect(45, 30, 7, 8, page); c.rect(44, 30, 1, 8, bookD)
        for y in stride(from: 31, to: 37, by: 2) { c.rect(38, y, 5, 1, C(0xA89A7A)); c.rect(46, y, 5, 1, C(0xA89A7A)) }
        let f = frac(p.t * 1.6)
        let w = Int((cos(f * .pi) * 7).rounded())
        if w > 0 { c.rect(45, 29, w, 8, C(0xFAF2DE)) } else if w < 0 { c.rect(44 + w, 29, -w, 8, C(0xFAF2DE)) }
        // His eyes down on the page.
        for ex in [21, 31] { c.rect(ex + 1, 29, 1, 1, C(0x2A2420)); c.px(ex + 2, 31, C(0xF4ECC8)) }
    } else {
        // The book under his arm, its gold corners.
        c.rect(37, 27, 12, 14, book); c.rect(37, 27, 1, 14, bookD); c.rect(48, 27, 1, 14, bookD)
        c.rect(38, 40, 10, 1, page)
        for (x, y) in [(38, 28), (47, 28), (38, 38), (47, 38)] { c.px(x, y, gold) }
        c.pattern(41, 31, ["GGGG", "G..G", "GGGG", "....", ".GG."], ["G": gold])
        c.rect(38, 33, 3, 3, robe)
    }
}

// MARK: - Bonejingles

/// Bonejingles: the band leader at the Ball and Socket: the block bone-white with a skull's face on it, one empty
/// socket and in the other an eyeball, a toothy grin, a battered black bowler on top, a rib cage below and a red bow
/// tie, and his golden trumpet. He doesn't fight. Signature: he puts the trumpet up and plays a riff, notes popping
/// out of the bell, and shuffles his bones to it.
private func drawBonejingles(_ c: PixelCanvas, _ p: Pose) {
    let felt = C(0x1E1C22), feltL = C(0x3A3644), brass = C(0xE0B030), brassL = C(0xFFE27A), brassD = C(0xA8801A)
    let sig = p.signature
    let playing = sig.map { $0 > 0.08 && $0 < 0.9 } ?? false
    let beat = playing ? Int(p.t * 6) % 2 : 0

    drawLegs(c, Look(leg: bone), step: playing ? beat : p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx, 39, 2, 1, boneD) } }
    c.oy += p.breathe
    c.ox += playing ? (beat == 0 ? -1 : 1) : 0
    drawBody(c, Look(body: bone, shade: boneD, arm: bone, eye: nil))
    // The skull: one empty socket, the other with an eyeball rolling in it; the nose hole; the grin.
    c.pattern(20, 27, [".KKK.", "KKKKK", "KKKKK", ".KKK."], ["K": ink])
    c.pattern(30, 27, [".KKK.", "KWWWK", "KWKWK", ".KKK."], ["K": ink, "W": C(0xFFFFFF)])
    c.pattern(27, 31, ["K.K"], ["K": ink])
    if !playing { c.pattern(21, 32, ["K............K", ".KWKWKWKWKWKK."], ["K": ink, "W": bone]) }
    // The rib cage below it, the red bow tie at its top.
    c.rect(18, 34, 20, 4, bone); c.rect(37, 34, 1, 4, boneD)
    for y in [34, 36] { c.rect(19, y, 8, 1, C(0x5A5664)); c.rect(29, y, 8, 1, C(0x5A5664)) }
    c.rect(27, 34, 2, 4, boneD)
    c.pattern(25, 33, ["RR.RR", "RRRRR", "RR.RR"], ["R": C(0xC8202A)])
    // The battered bowler on top.
    c.pattern(18, 19 + (playing ? beat : 0), [
        ".....HHHHHHHHH......",
        "....HHHHHHHHHHH.....",
        "...HHhHHHHHHHHHH....",
        "...HHhHHHHHHHHHHH...",
        "...BBBBBBBBBBBBBB...",
        "..HHHHHHHHHHHHHHHH..",
        "HHHHHHHHHHHHHHHHHHHH",
    ], ["H": felt, "h": feltL, "B": C(0x4A4652)])
    c.px(15, 36, bone); c.px(17, 36, bone)
    if playing {
        // The trumpet up at his mouth, its bell pointing up and out, and the notes popping out of it.
        c.rect(36, 30, 3, 3, bone)
        burtonLine(c, 30, 33, 44, 29.5, brass, 0.9); c.rect(35, 30, 1, 2, brassD); c.rect(37, 29, 1, 2, brassD)
        burtonTriangle(c, (43, 29.8), (46.3, 25.4), (48, 31.4), brass); c.px(46, 27, brassL); c.px(45, 28, brassL)
        for k in 0..<4 {
            let f = frac(p.t * 0.9 + Double(k) / 4)
            let x = 49 + f * 12 + sin(f * 8 + Double(k)) * 2, y = 21 - f * 17
            let col = C(k % 2 == 0 ? 0xFFE27A : 0xF4F0E0, (1 - f) * 0.9)
            let ix = Int(x.rounded()), iy = Int(y.rounded())
            c.rect(ix, iy + 2, 2, 2, col); c.rect(ix + 1, iy - 1, 1, 3, col); c.px(ix + 2, iy - 1, col)
        }
        return
    }
    // The trumpet held down at his side.
    c.rect(38, 33, 3, 3, bone)
    burtonLine(c, 40, 35.5, 46, 35.5, brass, 0.8); burtonTriangle(c, (45, 35.5), (49, 32.5), (49, 38.5), brass)
    c.rect(42, 33, 1, 2, brassD); c.rect(44, 33, 1, 2, brassD); c.px(47, 34, brassL)
}

// MARK: - General Bonesapart

/// General Bonesapart: a tiny skeleton general, a small block tinted bone with a skull face, a huge black bicorne
/// with gold trim and a cockade, gold epaulettes on a blue coat, and a sword run right through him, its hilt out of
/// his back and its point out of his front. He fights with it. Signature: he snaps a salute, then pulls the sword out
/// of himself and waves it over his head.
private func drawGeneralBonesapart(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x2A3A7A), coatD = C(0x1C2858), gold = C(0xE0B840), hat = C(0x16141C), steel = C(0xC8CCD4)
    let sig = p.signature
    let saluting = sig.map { $0 > 0.06 && $0 < 0.34 } ?? false
    let waving = sig.map { $0 >= 0.42 && $0 < 0.94 } ?? false
    let inHand = p.melee != nil || waving
    // The sword through him: the blade behind his body, poking out of his front, the hilt out of his back.
    if !inHand { burtonLine(c, 17, 31, 41, 40, steel, 0.8) }
    // Short bony legs.
    if seatedPose {
        for lx in [22, 25, 30, 33] { c.rect(lx - 1, 37, 3, 2, bone) }
    } else {
        for (i, lx) in [22, 25, 30, 33].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, 39, 2, lifted ? 3 : 4, bone); c.rect(lx, lifted ? 41 : 42, 2, 1, C(0x1A1A1E))
        }
    }
    c.oy += p.breathe
    // The little block: a skull face on top, the blue coat with gold buttons below.
    c.rect(21, 30, 14, 9, bone); c.rect(34, 30, 1, 9, boneD)
    c.rect(23, 31, 3, 3, ink); c.rect(30, 31, 3, 3, ink); c.px(27, 33, ink); c.px(28, 33, ink)
    c.pattern(24, 35, ["KWKWKWKK"], ["K": ink, "W": bone])
    c.rect(21, 36, 14, 3, coat); c.rect(34, 36, 1, 3, coatD); c.px(26, 37, gold); c.px(29, 37, gold)
    c.rect(19, 35, 3, 2, gold); c.rect(34, 35, 3, 2, gold)
    if !inHand {
        // The hilt sticking out of his back: a gold guard, a dark grip.
        c.rect(17, 29, 1, 5, gold); burtonLine(c, 13, 29, 16.5, 31, C(0x4A2E1A), 0.8); c.px(12, 28, gold)
    }
    // The huge bicorne, worn side on, gold-trimmed, a red, white and blue cockade.
    c.pattern(18, 24, [
        "......HHHHHH......",
        "...HHHHHHHHHHHH...",
        ".HHHHHHHHBWRHHHHH.",
        "HHHHHHHHHHHHHHHHHH",
        "GGGGGGGGGGGGGGGGGG",
        ".G..............G.",
    ], ["H": hat, "G": gold, "B": C(0x2A4AC8), "W": C(0xF4F4F4), "R": C(0xC8202A)])
    // Arms: a salute at the brim, the sword waved overhead or swung along `p.melee`, or at his sides.
    c.rect(18, 36, 3, 2, bone)
    if saluting {
        burtonLine(c, 35, 36, 37, 29, bone, 0.9); c.rect(35, 27, 3, 2, bone)
        return
    }
    let angle = waving ? -95 + sin(p.t * 10) * 30 : p.melee
    c.rect(35, 34, 3, 2, bone)
    if let a = angle {
        for (i, ta) in (waving ? [] : p.trail).enumerated() {
            let e = burtonReach(generalHand, ta, 12)
            c.glowLine(generalHand.x, generalHand.y, e.x, e.y, core: C(0xE8ECF4), glow: C(0xE8ECF4), coreR: 0.5,
                       glowR: 1.6, strength: 0.3 / Double(i + 1))
        }
        let s = burtonReach(generalHand, a, -2), g = burtonReach(generalHand, a, 1.5)
        let e = burtonReach(generalHand, a, 13)
        let r = a * .pi / 180, sx = -sin(r), sy = cos(r)
        burtonLine(c, s.x, s.y, g.x, g.y, C(0x4A2E1A), 0.7)
        burtonLine(c, g.x + sx * 2, g.y + sy * 2, g.x - sx * 2, g.y - sy * 2, gold, 0.6)
        burtonLine(c, g.x, g.y, e.x, e.y, steel, 0.75)
    }
}
