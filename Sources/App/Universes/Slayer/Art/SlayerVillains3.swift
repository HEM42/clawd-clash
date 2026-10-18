import Foundation

// Villains: the rest of the vampires. Kakistoes and the Turok-Hahn are big Clawds (a taller, broader block, their
// `bulk` and fist say so) still on four legs; Sundae, Lyle Grouch and Draclawla are Clawd at Clawd's own size. Each is
// carried by an outfit and a silhouette first (the game face is fine detail): a battered greatcoat and cloven hooves,
// a punk's red crop and tartan, a cowboy hat, a flaring red-lined collar, bare grey muscle and bat ears.

let slayerVillains3: [SlayerVillain: Persona] = [
    .kakistoes: Persona(name: "Kakistoes", weapon: .saber, pivot: v3KakistoesFist, bulk: 4, headTop: 18, signature: 3.0,
                        draw: drawKakistoes),
    .sundae: Persona(name: "Sundae", weapon: .saber, headTop: 18, signature: 3.4, draw: drawSundae),
    .lyleGrouch: Persona(name: "Lyle Grouch", weapon: .saber, headTop: 14, signature: 3.2, draw: drawLyleGrouch),
    .draclawla: Persona(name: "Draclawla", weapon: .lightning,
                        magic: Magic(core: C(0xFFF6F2), glow: C(0xB0101E), jagged: false, rings: true),
                        pivot: (44.0, 31.0), headTop: 19, signature: 3.6, draw: drawDraclawla),
    .turokHahn: Persona(name: "The Turok-Hahn", weapon: .saber, armoured: true, canSit: false, pivot: v3TurokFist,
                        bulk: 6, headTop: 10, signature: 2.8, draw: drawTurokHahn),
]

// MARK: - Shared bits

/// 0 before `a`, 1 after `b`, a straight line between.
private func v3Ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// 0 outside `a`…`b`, rising over the first `edge` of it and falling over the last.
private func v3Arc(_ s: Double, _ a: Double, _ b: Double, edge: Double = 0.1) -> Double {
    min(v3Ramp(s, a, a + edge), 1 - v3Ramp(s, b - edge, b))
}

/// A heavy punch along `angle` from the shoulder `s`: the arm thrown out `reach` pixels, a smear where a fast swing
/// just was, and `fist` drawing whatever is on the end, centred on the point it's given.
private func v3Punch(_ c: PixelCanvas, from s: (x: Double, y: Double), angle: Double, trail: [Double], reach: Double,
                     arm: Px, thick: Double, smear: Px, fist: (Int, Int) -> Void) {
    slayerSmear(c, s, trail, from: reach - 3, to: reach + 2, smear)
    let e = slayerReach(s, angle, reach)
    slayerLine(c, s.x, s.y, e.x, e.y, arm, thick)
    fist(Int(e.x.rounded()), Int(e.y.rounded()))
}

/// A vampire's game face over Clawd's own: ridged brow, yellow eyes (instead of the plain ones) and a pair of fangs.
private func v3GameFace(_ c: PixelCanvas, ridge: Px = C(0x9A4A30)) {
    c.pattern(21, 27, ["RRRR......RRRR", ".RR........RR."], ["R": ridge])
    c.rect(22, 29, 2, 2, C(0xF2D040)); c.px(23, 30, ink); c.rect(32, 29, 2, 2, C(0xF2D040)); c.px(32, 30, ink)
    c.pattern(26, 30, ["R..R", ".RR."], ["R": ridge])
    c.rect(25, 32, 6, 1, C(0x5A2418)); c.px(26, 33, white); c.px(29, 33, white)
}

// MARK: - Kakistoes

/// Where Kakistoes' cloven fist swings from: out in front of his big body.
private let v3KakistoesFist: (x: Double, y: Double) = (45.0, 34.5)

/// Kakistoes: the ancient vampire so old his hands and feet have turned to cloven hooves. A big Clawd, a third again as
/// tall, bald, his head knotted with lumps and ridges, tiny yellow eyes deep under a massive brow, fangs like tusks; a
/// battered brown greatcoat, patched and torn at the hem, its collar up, over a dirty shirt. He fights with his hooves.
/// Signature: he stamps a hoof, twice, impatient, and the ground cracks and puffs dust under it.
private func drawKakistoes(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x5A4230), coatD = C(0x36261A), coatL = C(0x7A5E46), shirt = C(0x8A8270), shirtD = C(0x5A5446)
    // Grey trousers, well apart from the brown coat, so the legs (and the stamping one) stand out from it.
    let trousers = C(0x6E6A72), hoof = C(0x2E2622), hoofL = C(0x5E4E44)
    let ridge = C(0x8E3A24), ridgeD = C(0x6A2818), eye = C(0xF2D040)
    // The stamp: how high the front hoof is, and how far through the dust after it lands.
    var stamp = 0, impact = -1.0
    if let s = p.signature {
        for (a, b) in [(0.08, 0.46), (0.5, 0.9)] where s >= a && s < b {
            let k = (s - a) / (b - a)
            if k < 0.45 { stamp = Int((k / 0.45 * 5).rounded()) } else if k < 0.55 { stamp = 5 } else { impact = (k - 0.55) / 0.45 }
        }
    }

    // The back arm, in its coat sleeve, the hoof of a hand hanging below.
    c.oy += p.breathe
    c.rect(11, 27, 3, 9, coat); c.rect(11, 27, 1, 9, coatL); c.rect(10, 33, 5, 3, coat); c.rect(10, 33, 1, 3, coatL)
    c.rect(10, 35, 5, 1, coatD)
    c.pattern(10, 36, ["hHHH", "HHdH"], ["H": hoof, "h": hoofL, "d": C(0x140E0C)])
    c.oy -= p.breathe
    // Four legs ending in cloven hooves, the front one stamping.
    if seatedPose {
        for lx in [19, 23, 31, 35] { c.rect(lx - 1, 38, 4, 2, trousers); c.rect(lx + 1, 38, 2, 2, hoof); c.px(lx + 1, 38, hoofL) }
    } else {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lift = (p.step >= 0 && i % 2 == p.step ? 1 : 0) + (i == 3 ? stamp : 0)
            let bottom = 43 - lift
            kakistoesLeg(c, lx, bottom: bottom, trousers: trousers, hoof: hoof, hoofL: hoofL)
        }
    }
    if impact >= 0 {
        // Cracks under the hoof and dust puffing out either side of it.
        let crack = C(0x1A1416, 0.6)   // soft, on the floor, not a solid shape the outline would go round
        if impact < 0.7 {
            c.rect(31, 44, 11, 1, crack); c.px(30, 45, crack); c.px(29, 46, crack); c.px(42, 45, crack); c.px(43, 46, crack)
            c.px(36, 45, crack); c.px(36, 46, crack)
        }
        let r = Int(1 + impact * 3)
        let dust = C(0xC8B898, 0.6 * (1 - impact))
        c.circle(42 + Int(impact * 5), 42, r, dust); c.circle(47 + Int(impact * 7), 41, max(0, r - 1), dust)
        c.circle(29 - Int(impact * 5), 42, max(0, r - 1), dust)
        // Grit kicked up off the floor.
        for k in 0..<3 { c.px(38 + k * 3, 42 - Int(impact * Double(6 + k * 2)), C(0xA89878, 0.8 * (1 - impact))) }
        if impact < 0.25 { c.oy += 1 }   // the jolt goes up through him
    }
    c.oy += p.breathe
    // The body: Clawd's block, a third taller, the head a little narrower than the hunched coat shoulders under it.
    c.rect(16, 21, 24, 17, clawdOrange); c.rect(17, 20, 22, 1, clawdOrange); c.rect(19, 19, 18, 1, clawdOrange)
    c.rect(39, 21, 1, 17, clawdShade); c.px(38, 20, clawdShade)
    // The greatcoat from the shoulders to the shins, its collar up round his jaw, open over the shirt.
    c.rect(14, 30, 28, 8, coat); c.rect(41, 30, 1, 8, coatD); c.rect(14, 30, 1, 8, coatL)
    c.rect(25, 30, 6, 7, shirt); c.rect(25, 36, 6, 1, shirtD); c.px(27, 32, shirtD); c.px(29, 34, shirtD)
    c.pattern(21, 30, ["LLLL......LLLL", ".LLL......LLd.", "..LL......Ld..", "...L......d...", "...L......d..."],
              ["L": coatL, "d": coatD])
    // The collar turned up round his jaw, highest against his head and sloping away over hunched shoulders.
    c.pattern(12, 23, ["..LD", ".LDD", "LDDD", "LDDD", "LDDD", "LDDD", ".LDD"], ["L": coatL, "D": coatD])
    c.pattern(40, 23, ["DD..", "DDD.", "DDDD", "DDDD", "DDDD", "DDDD", "DDD."], ["D": coatD])
    if !seatedPose {
        // The skirts flaring out past his body, the hem torn ragged.
        c.rect(13, 38, 30, 1, coat); c.px(13, 38, coatL); c.px(42, 38, coatD)
        c.pattern(12, 39, ["CCC..CCdC..CCCC.CdCC.CC.CCCdCCC", "C.....d...........d.........C.."], ["C": coat, "d": coatD])
    } else {
        c.rect(14, 38, 28, 1, coatD)
    }
    // Patches and a tear.
    c.rect(17, 33, 3, 2, coatL); c.px(18, 33, coatD); c.rect(35, 35, 2, 1, coatD); c.px(36, 34, coatD)
    // The bald, knotted head: lumps on the crown, ridges down the brow to a massive shelf over tiny eyes.
    c.rect(20, 18, 3, 1, clawdOrange); c.rect(27, 18, 3, 1, clawdOrange); c.rect(33, 18, 3, 1, clawdOrange)
    c.px(21, 19, ridge); c.px(28, 19, ridge); c.px(34, 19, ridge)
    c.px(33, 20, ridgeD); c.px(34, 21, ridgeD); c.px(35, 21, ridgeD)   // an old scar on the dome
    c.pattern(17, 22, [
        "RRRRRRRRR....RRRRRRRRR",
        ".DDDDDDDD....DDDDDDDD.",
    ], ["R": ridge, "D": ridgeD])
    c.rect(21, 24, 2, 2, eye); c.px(22, 25, ink); c.rect(33, 24, 2, 2, eye); c.px(33, 25, ink)
    c.pattern(26, 22, [".RR.", "R..R", "RRRR", "D..D"], ["R": ridge, "D": ridgeD])
    // The wide mouth and its tusks.
    c.rect(21, 27, 14, 1, C(0x4A1A12))
    c.rect(22, 28, 1, 2, white); c.rect(33, 28, 1, 2, white); c.px(25, 28, white); c.px(30, 28, white)

    if stamp > 0 && !seatedPose {
        // The stamping leg, lifted forward out from under the coat, the hoof raised.
        c.oy -= p.breathe
        let hx = 36 + stamp, bottom = 43 - stamp
        slayerLine(c, 36, 37, Double(hx) + 0.5, Double(bottom - 3), trousers, 1.0)
        kakistoesLeg(c, hx, bottom: bottom, trousers: trousers, hoof: hoof, hoofL: hoofL, top: bottom - 3)
        c.oy += p.breathe
    }
    // The front arm: a coat sleeve out to a hoof for a fist.
    let hoofFist = { (x: Int, y: Int) in
        c.pattern(x - 2, y - 1, ["hHHH", "HHHH", "HHdH"], ["H": hoof, "h": hoofL, "d": C(0x140E0C)])
    }
    if let a = p.melee {
        v3Punch(c, from: (40.5, 31), angle: a, trail: p.trail, reach: 7, arm: coat, thick: 1.6, smear: C(0xC8B8A0), fist: hoofFist)
    } else if p.signature.map({ $0 > 0.06 && $0 < 0.92 }) ?? false {
        // Stamping, the fist lifted out of the leg's way, for balance.
        slayerLine(c, 40.5, 31, 44, 28, coat, 1.6)
        hoofFist(45, 27)
    } else {
        slayerLine(c, 40.5, 31, 44, 34, coat, 1.6)
        hoofFist(45, 35)
    }
}

/// One of Kakistoes' legs, from `top` down to a cloven hoof whose bottom row is `bottom`.
private func kakistoesLeg(_ c: PixelCanvas, _ lx: Int, bottom: Int, trousers: Px, hoof: Px, hoofL: Px, top: Int = 36) {
    if bottom - 1 > top { c.rect(lx, top, 2, bottom - 1 - top, trousers); c.rect(lx, top, 1, bottom - 1 - top, C(0x8A8690)) }
    // The hoof: a solid dark wedge, a sheen across its top and the cleft a darker notch, not a gap.
    c.rect(lx, bottom - 1, 3, 2, hoof); c.rect(lx, bottom - 1, 2, 1, hoofL); c.px(lx + 1, bottom, C(0x140E0C))
}

// MARK: - Sundae

/// Sundae: the punk vampire who ran the campus in "The Freshman". A short spiky crop dyed deep crimson, a black
/// leather jacket with silver studs on the shoulders over a white tee with a red scrawl, a studded choker, a red tartan
/// mini skirt, dark tights and chunky boots. She fights with her fists and nails, game face on. Signature: she holds up
/// Buffy's umbrella (the Class Protector one), bends it over her knee... well, her hands, snaps it in two with a grin,
/// and drops the halves.
private func drawSundae(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x1E1A1E), jacketD = C(0x0E0C0E), jacketL = C(0x3C343C), stud = C(0xD8DCE4)
    let tee = C(0xE8E4DC), scrawl = C(0xC02030), tartan = C(0xA02030), tartanD = C(0x5A0E18), tartanL = C(0xE0B040)
    let hair = C(0x8A1E2A), hairL = C(0xC03848), hairD = C(0x5A1018)
    let sig = p.signature.map { $0 > 0.06 && $0 < 0.94 ? $0 : -1 } ?? -1
    let holding = sig >= 0.06 && sig < 0.82

    drawLegs(c, Look(leg: C(0x2A2430)), step: p.step)
    slayerBoots(c, step: p.step, C(0x101012), height: 3)
    // The tartan skirt, short, over the tights: the four legs show below it.
    c.rect(17, 38, 22, seatedPose ? 1 : 2, tartan)
    if !seatedPose {
        for x in stride(from: 19, to: 39, by: 4) { c.rect(x, 38, 1, 2, tartanD) }
        c.rect(17, 39, 22, 1, tartanD); for x in stride(from: 21, to: 39, by: 4) { c.px(x, 38, tartanL) }
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: jacket, eye: p.melee == nil ? ink : nil))
    // The jacket, open over the tee with its scrawl, studs along the shoulders.
    c.rect(18, 34, 20, 4, jacket); c.rect(37, 34, 1, 4, jacketD); c.rect(18, 37, 20, 1, jacketD)
    c.rect(24, 34, 8, 4, tee); c.rect(24, 37, 8, 1, C(0xB8B4AC))
    c.pattern(25, 35, ["X.XX.X", ".X..X."], ["X": scrawl])
    c.rect(23, 34, 1, 3, jacketL); c.rect(32, 34, 1, 3, jacketL)
    for x in [19, 21, 34, 36] { c.px(x, 34, stud) }
    // The studded choker.
    c.rect(24, 33, 8, 1, jacketD); c.px(26, 33, stud); c.px(29, 33, stud)
    // The short crimson crop, spiked up on top in ragged tufts of different heights, cut close at the sides.
    c.pattern(17, 18, [
        "......l.......l.....l...",
        "..l..Hl..l...HH....Hl...",
        "..HH.HHH.HHl.HHHl.HHH.l.",
        "..HHHlHHHHHHlHHHHHlHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHHH",
        ".HHHHHHHHHHHHHHHHHHHHHHd",
        ".HHHHHHHHHHHHHHHHHHHHHHd",
        ".HHHHH.HH..H.HH...HHHHHd",
        ".HHH................HHHd",
        ".HHd.................Hd.",
    ], ["S": hairL, "H": hair, "l": hairL, "d": hairD])
    if p.melee != nil { v3GameFace(c) }

    if holding {
        sundaeUmbrella(c, sig)
        if sig >= 0.42 { c.px(26, 33, white); c.px(29, 33, white) }   // the grin, fangs and all
        return
    }
    if sig >= 0.82 {
        // The halves dropped, falling to the ground.
        let f = v3Ramp(sig, 0.82, 0.92)
        sundaeHalves(c, bend: 26, gap: 6, drop: f * 10)
    }
    if let a = p.melee { slayerClaws(c, angle: a, trail: p.trail, sleeve: jacket) }
}

/// Buffy's umbrella in Sundae's hands, `s` through her signature: held up straight, bent, snapped (a flash where it
/// goes), and the two halves held apart.
private func sundaeUmbrella(_ c: PixelCanvas, _ s: Double) {
    let bend = v3Ramp(s, 0.2, 0.4) * 18 + v3Ramp(s, 0.42, 0.55) * 8
    let gap = v3Ramp(s, 0.4, 0.55) * 6
    sundaeHalves(c, bend: bend, gap: gap, drop: 0)
    if s >= 0.39 && s < 0.5 {
        let k = v3Ramp(s, 0.39, 0.5), a = 0.9 * (1 - k)
        for (dx, dy) in [(0, 2), (0, 3), (-2, 1), (2, 1), (-3, 0), (3, 0)] { c.px(28 + dx, 35 + dy + Int(k * 2), white.alpha(a)) }
    }
}

/// The two halves of the umbrella, held across her waist below her face, each turned `bend` degrees down from straight
/// about the break, `gap` pixels apart, and `drop` pixels on their way to the floor. The handle half (left) has its gold crook; the tip half the furled
/// canopy and the ferrule.
private func sundaeHalves(_ c: PixelCanvas, bend: Double, gap: Double, drop: Double) {
    let canopy = C(0xB89AD8), canopyD = C(0x8A6AAE), shaft = C(0xC0C4CC), gold = C(0xE0B040)
    let mid = (x: 28.0, y: 35.5 + drop)
    let left = (x: mid.x - gap, y: mid.y), right = (x: mid.x + gap, y: mid.y)
    let la = 180 - bend, ra = bend
    // The handle half: the shaft, the canopy's furled start, and the crook.
    slayerBar(c, left, la, from: 0, to: 11, shaft, r: 0.5)
    slayerBar(c, left, la, from: 0, to: 7, canopyD, r: 1.2)
    slayerBar(c, left, la, from: 0, to: 6.5, canopy, r: 0.8)
    let h0 = slayerReach(left, la, 11), h1 = slayerReach(left, la, 13.5)
    slayerLine(c, h0.x, h0.y, h1.x, h1.y, gold, 0.6)
    let hook = slayerReach(h1, la - 90, 2)
    slayerLine(c, h1.x, h1.y, hook.x, hook.y, gold, 0.6)
    // The tip half: the canopy tapering to the ferrule.
    slayerBar(c, right, ra, from: 0, to: 8, canopyD, r: 1.2)
    slayerBar(c, right, ra, from: 0, to: 7.5, canopy, r: 0.8)
    slayerBar(c, right, ra, from: 7.5, to: 11, canopy, r: 0.5)
    let tip = slayerReach(right, ra, 12.5)
    c.px(Int(tip.x.rounded()), Int(tip.y.rounded()), shaft)
    // Her fists round each half, while she's still holding them.
    if drop == 0 {
        for (o, a) in [(left, la), (right, ra)] {
            let f = slayerReach(o, a, 9)
            c.rect(Int(f.x.rounded()) - 1, Int(f.y.rounded()) - 1, 3, 3, clawdOrange)
        }
    }
}

// MARK: - Lyle Grouch

/// Lyle Grouch: the Texan vampire. A wide brown cowboy hat with its brim curled up at the sides, long greasy brown
/// hair under it, a horseshoe moustache; a faded denim jacket over a red-checked shirt, a silver bolo tie, a big gold
/// buckle, jeans and cowboy boots with spurs. He fights with his fists, game face on. Signature: he spins a lasso over
/// his hat, round and round, and reels it back in.
private func drawLyleGrouch(_ c: PixelCanvas, _ p: Pose) {
    let denim = C(0x4A6A9A), denimD = C(0x34507A), denimL = C(0x6A8ABA)
    let check = C(0xB03A2A), checkL = C(0xE0D0B0), gold = C(0xD4AA4A), silver = C(0xD8DCE4)
    let hat = C(0x7A5532), hatD = C(0x553A20), hatL = C(0x9A7448), band = C(0x2A1E14)
    let hair = C(0x4A3424), hairD = C(0x2E2016), boot = C(0x6A4428)
    let lasso = p.signature.map { $0 > 0.06 && $0 < 0.94 ? $0 : -1 } ?? -1

    drawLegs(c, Look(leg: C(0x3A4A6A)), step: p.step)
    slayerBoots(c, step: p.step, boot, height: 3)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let bottom = p.step >= 0 && i % 2 == p.step ? 42 : 43
            c.px(lx, bottom, C(0x3A2414)); c.px(lx - 1, bottom - 1, gold)   // the heel and the spur
        }
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: denim, eye: p.melee == nil ? ink : nil), armRight: lasso >= 0 ? 7 : 0)
    // The jacket over the checked shirt, the bolo tie and the buckle.
    c.rect(18, 34, 20, 4, denim); c.rect(37, 34, 1, 4, denimD); c.rect(18, 37, 20, 1, denimD)
    c.rect(24, 34, 8, 4, check)
    for y in 34...37 { for x in 24...31 where (x + y) % 2 == 0 { c.px(x, y, checkL) } }
    c.rect(23, 34, 1, 4, denimL); c.rect(32, 34, 1, 4, denimL)
    c.px(27, 34, silver); c.px(28, 34, silver); c.px(27, 35, ink); c.px(28, 36, ink)
    c.rect(26, 37, 4, 1, gold)
    // Long greasy hair down from under the hat, and the horseshoe moustache.
    c.rect(16, 22, 4, 9, hair); c.rect(36, 22, 4, 9, hair); c.rect(16, 30, 1, 2, hairD); c.rect(39, 30, 1, 2, hairD)
    c.rect(17, 31, 2, 1, hair); c.rect(37, 31, 2, 1, hair); c.rect(19, 30, 1, 1, hairD); c.rect(36, 30, 1, 1, hairD)
    c.rect(16, 22, 24, 4, hair); c.rect(20, 26, 3, 1, hair); c.rect(29, 26, 5, 1, hair); c.px(25, 26, hair)
    c.rect(24, 32, 8, 1, hairD); c.px(24, 33, hairD); c.px(31, 33, hairD)
    if p.melee != nil { v3GameFace(c) }
    // The hat: a creased crown, a dark band, and the wide brim curled up at both sides.
    c.rect(22, 14, 12, 1, hat); c.rect(21, 15, 14, 5, hat); c.rect(21, 15, 1, 5, hatL); c.rect(34, 15, 1, 5, hatD)
    c.rect(26, 14, 4, 1, hatD); c.rect(27, 15, 2, 1, hatD)
    c.rect(21, 19, 14, 1, band)
    c.rect(15, 20, 26, 1, hat); c.rect(13, 18, 2, 2, hat); c.rect(41, 18, 2, 2, hat)
    c.rect(15, 20, 6, 1, hatL); c.rect(17, 21, 22, 1, hatD)

    if lasso >= 0 {
        // The hand up and out past the hat brim, the rope rising from it to a wide loop spinning above, clear of the hat.
        slayerLine(c, 39.5, 27, 43.5, 21, denim, 1.1)
        c.rect(43, 19, 2, 2, clawdOrange)
        let k = v3Arc(lasso, 0.06, 0.94, edge: 0.14)
        let hand = (x: 44.0, y: 19.0)
        let cx = 42.0 + (hand.x - 42) * (1 - k), cy = 8.0 + (hand.y - 8) * (1 - k)
        let rx = 11 * k, ry = 3 * k
        let rope = C(0xD8B878), ropeD = C(0x9A7A48)
        let spin = p.t * 11
        var a = 0.0
        while a < 2 * .pi {
            let x = cx + cos(a) * rx, y = cy + sin(a) * ry
            c.px(Int(x.rounded()), Int(y.rounded()), sin(a) < 0 ? ropeD : rope)
            a += .pi / 40
        }
        let knot = (x: cx + cos(spin) * rx, y: cy + sin(spin) * ry)
        slayerLine(c, hand.x, hand.y, knot.x, knot.y, rope, 0.5)
        c.rect(Int(knot.x.rounded()) - 1, Int(knot.y.rounded()), 2, 1, rope)
        return
    }
    if let a = p.melee { slayerClaws(c, angle: a, trail: p.trail, sleeve: denim) }
}

// MARK: - Draclawla

/// Draclawla: the Count himself, in Sunnydale for the Slayer. Black hair slicked back to a widow's peak, a neat dark
/// goatee, a black suit and a white ruffled shirt with a red-stoned medallion; a long black cape lined in blood red,
/// its high collar flaring to two points behind his head. His thrall is rings of blood red, from a clawed hand held
/// out, his eyes glowing red with it. Signature: he turns to mist, a red-grey fog swirling where he stood with two red
/// eyes in it, and back.
private func drawDraclawla(_ c: PixelCanvas, _ p: Pose) {
    guard let s = p.signature, s > 0.08, s < 0.92 else { drawDraclawlaBody(c, p); return }
    var q = p
    q.signature = nil
    let fig = PixelCanvas(Sprite.width, Sprite.height)
    drawDraclawlaBody(fig, q)
    // He's see-through only for a moment either way: the fade is quick, and the mist is already thick round him by
    // then, so he's either solid or gone into it.
    let solid = 1 - v3Arc(s, 0.08, 0.92, edge: 0.1)
    if solid > 0 { c.paste(fig, alpha: solid) }
    // The mist, thickest while he's gone, swirling and drifting up.
    let mist = v3Arc(s, 0.04, 0.96, edge: 0.12)
    for i in 0..<16 {
        let fi = Double(i)
        let a = fi * 2.4 + s * 6 * (i % 2 == 0 ? 1 : -1)
        let r = 4 + Double((i * 5) % 9)
        let x = 28 + cos(a) * r * 1.2, y = 33 + sin(a) * r * 0.6 - s * 3
        let col = (i % 3 == 0 ? C(0xC89098) : C(0xB8B0BC)).alpha(0.24 * mist)
        c.circle(Int(x.rounded()), Int(y.rounded()), 2 + i % 3, col)
    }
    if s > 0.38 && s < 0.62 {
        let e = v3Arc(s, 0.38, 0.62, edge: 0.06)
        c.px(24, 30, C(0xFF3040).alpha(0.9 * e)); c.px(31, 30, C(0xFF3040).alpha(0.9 * e))
    }
}

/// Draclawla himself (drawn into a canvas of its own and faded for his signature).
private func drawDraclawlaBody(_ c: PixelCanvas, _ p: Pose) {
    let cape = C(0x161218), capeD = C(0x08060A), capeL = C(0x34293A), lining = C(0x9A1020), liningD = C(0x6A0A16)
    let hair = C(0x16121A), hairL = C(0x3E3446), shirt = C(0xECE4DC), shirtD = C(0xB8B0A8), gold = C(0xD4AA4A)
    let using = p.zap != nil || p.ready
    // The cape hanging behind him, its red lining showing at the edge; it stirs at the hem.
    let stir = Int((sin(p.t * p.capeSpeed * 2) * 1).rounded())
    let hem = seatedPose ? 39 : 41
    c.rect(14, 28, 4, hem - 28, cape); c.rect(14, 28, 1, hem - 28, capeL); c.rect(17, 28, 1, hem - 28, lining)
    c.rect(13 + stir, hem - 4, 2, 4, cape); c.rect(15, hem - 1, 3, 1, liningD)
    c.rect(38, 30, 3, hem - 1 - 30, cape); c.rect(38, 30, 1, hem - 1 - 30, liningD)
    drawLegs(c, Look(leg: C(0x1A161C)), step: p.step)
    slayerBoots(c, step: p.step, C(0x0A080C), height: 1)
    c.oy += p.breathe
    // The high collar, standing up and flaring out either side of his head, red inside, its tops rounded like a
    // stiffened cape collar (pointed, they read as horns).
    c.pattern(12, 22, [".KKK..", "KRRK..", "KRRK..", "KRRK..", ".KRRK.", ".KRRK.", "..KRR.", "..KRR.", "..KRR.", "...KR.", "...KR."],
              ["K": cape, "R": lining])
    c.pattern(38, 22, ["..KKK.", "..KRRK", "..KRRK", "..KRRK", ".KRRK.", ".KRRK.", ".RRK..", ".RRK..", ".RRK..", ".RK...", ".RK..."],
              ["K": cape, "R": lining])
    drawBody(c, Look(arm: cape, eye: using ? C(0xE02030) : ink))
    if using { c.px(23, 29, C(0xFF8090)); c.px(33, 29, C(0xFF8090)) }
    // The suit, the ruffled shirt and the medallion.
    c.rect(18, 34, 20, 4, cape); c.rect(37, 34, 1, 4, capeD); c.rect(18, 37, 20, 1, capeD)
    c.rect(25, 33, 6, 5, shirt); c.px(26, 34, shirtD); c.px(29, 35, shirtD); c.px(26, 36, shirtD); c.px(29, 37, shirtD)
    c.rect(24, 34, 1, 4, capeL); c.rect(31, 34, 1, 4, capeL)
    c.rect(27, 35, 2, 2, gold); c.px(27, 35, lining); c.px(28, 36, liningD)
    // The cape's clasp lines over the shoulders.
    c.rect(18, 33, 3, 1, gold); c.rect(35, 33, 3, 1, gold)
    // Black hair slicked back off a widow's peak, and the goatee.
    c.pattern(17, 21, [
        "...HHHHHHHHHHHHHHHH...",
        "..HHHHlllHHHHHHHHHHH..",
        ".HHHHHHHHlllHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHH.....HHHH.....HHH.",
        ".HH.......HH.......HH.",
        ".HH................HH.",
    ], ["H": hair, "l": hairL])
    c.rect(25, 32, 6, 1, hair); c.rect(27, 33, 2, 1, hair)

    if using {
        // The clawed hand held out, fingers spread, its tip at `pivot`; red rings tighten round it while he casts.
        let raise = p.armRaise
        c.rect(38, 31 - raise, 3, 3, cape)
        c.pattern(41, 30 - raise, ["..O", "OOO", "OOO", "..O"], ["O": clawdOrange])
        if p.zap == true {
            let k = (p.t * 2).truncatingRemainder(dividingBy: 1), r = 4 - k * 3
            for a in stride(from: 0.0, to: 2 * .pi, by: .pi / 4) {
                c.px(45 + Int((cos(a) * r).rounded()), 31 - raise + Int((sin(a) * r).rounded()), C(0xE02030).alpha(0.3 + 0.5 * k))
            }
        }
    } else {
        c.rect(39, 36, 2, 1, clawdOrange)
    }
}

// MARK: - The Turok-Hahn

/// Where the Turok-Hahn's clawed fist swings from: out in front of his huge body.
private let v3TurokFist: (x: Double, y: Double) = (46.0, 34.0)

/// The Turok-Hahn: the primordial vampire from under the Hellmouth, the First's foot soldier. A big Clawd, a third again
/// as tall and broad, bare grey muscle from his pointed bat's ears down: hulking shoulders, a heavy chest; only Clawd's
/// orange face shows, set in a permanent game face, a squashed bat's nose and a brow of grey ridges, yellow eyes, fangs.
/// Rags of dark leather at his waist, clawed grey feet. He fights with his claws, and blows bounce off him. Signature: he
/// throws his arms up and roars.
private func drawTurokHahn(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xA4A4B0), skinD = C(0x74747F), skinL = C(0xC6C6D0), skinDD = C(0x55555F)
    let rag = C(0x3A302A), ragD = C(0x241E1A), nail = C(0xE8E0C8), eye = C(0xF2D040)
    let roar = p.signature.map { v3Arc($0, 0.1, 0.9, edge: 0.12) } ?? 0
    let up = roar > 0.5

    if roar > 0.5, let s = p.signature { c.ox += Int(s * 60) % 2 }   // shaking with it
    // The back arm, raised in the roar or hanging, claws at the end.
    c.oy += p.breathe
    if up {
        slayerLine(c, 13, 26, 8, 16, skin, 2.0)
        c.rect(6, 13, 4, 4, skin); c.rect(6, 13, 1, 4, skinL)
        for x in [6, 8] { c.px(x, 12, nail) }; c.px(10, 13, nail)
    } else {
        c.rect(9, 25, 5, 11, skin); c.rect(9, 25, 1, 11, skinL); c.rect(13, 27, 1, 9, skinD); c.rect(10, 30, 3, 1, skinD)
        for x in [9, 11, 13] { c.px(x, 36, nail) }
    }
    c.oy -= p.breathe
    // Four thick grey legs on clawed feet.
    if seatedPose {
        for lx in [17, 22, 32, 37] { c.rect(lx - 1, 38, 5, 2, skin); c.px(lx + 4, 39, nail) }
    } else {
        for (i, lx) in [17, 22, 32, 37].enumerated() {
            let bottom = p.step >= 0 && i % 2 == p.step ? 42 : 43
            c.rect(lx, 36, 3, bottom - 35, skin); c.rect(lx + 2, 36, 1, bottom - 35, skinD); c.px(lx + 3, bottom, nail)
        }
    }
    c.oy += p.breathe
    // The body: hulking, the shoulders bulging over the top of the arms.
    c.rect(15, 19, 26, 1, skin); c.rect(14, 20, 28, 18, skin); c.rect(41, 20, 1, 18, skinD); c.rect(14, 20, 1, 17, skinL)
    c.rect(11, 23, 4, 6, skin); c.rect(11, 23, 2, 1, skinL); c.rect(41, 23, 3, 6, skin); c.rect(43, 24, 1, 5, skinD)
    // The bat's ears: broad, leaning out from his head, round at the tip, ribbed inside like a wing.
    c.pattern(9, 11, [".SS.....", "SddS....", "SdddS...", ".SdddS..", ".SdSddS.", "..SdSddS", "..SddSdS", "...SdSdS", "...SSdSS", "....SSSS"],
              ["S": skin, "d": skinDD])
    c.pattern(39, 11, [".....SS.", "....SddS", "...SdddS", "..SdddS.", ".SddSdS.", "SddSdS..", "SdSddS..", "SdSdS...", "SSdSS...", "SSSS...."],
              ["S": skin, "d": skinDD])
    // His chest: the pecs, a line down the middle, the ribs and belly under them.
    c.pattern(18, 33, [
        ".DDDDDDDD..DDDDDDDD.",
        "..........D.........",
        "...D.D....D....D.D..",
        "..........D.........",
    ], ["D": skinD])
    c.rect(16, 33, 2, 1, skinL)
    // Rags of dark leather at his waist, hanging in strips over the tops of his legs.
    c.rect(14, 37, 28, 1, rag)
    if !seatedPose { c.pattern(14, 38, ["RR.RRR.RRdR.RR.RRR.RdRR.RRR", "R..R.R..R.R..R..R.R..R...R."], ["R": rag, "d": ragD]) }
    // The face: Clawd's own orange, set in grey: the brow ridges, yellow eyes, the squashed bat's nose and fangs.
    // The face narrows to a heavy jaw, set into the grey with folds of skin round it, not a flat panel.
    c.rect(19, 23, 18, 6, clawdOrange); c.rect(20, 29, 16, 2, clawdOrange); c.rect(21, 31, 14, 1, clawdOrange)
    c.rect(22, 32, 12, 1, clawdOrange); c.rect(36, 23, 1, 6, clawdShade); c.rect(35, 29, 1, 2, clawdShade)
    c.rect(18, 24, 1, 5, skinD); c.rect(37, 24, 1, 5, skinD); c.px(19, 29, skinD); c.px(36, 29, skinD)
    c.px(19, 30, skinD); c.px(36, 30, skinD); c.px(20, 31, skinD); c.px(35, 31, skinD); c.px(21, 32, skinD); c.px(34, 32, skinD)
    c.px(20, 29, skinD); c.px(35, 29, skinD)
    c.pattern(19, 23, [
        "SSSSSSSS..SSSSSSSS",
        ".SSSSSS....SSSSSS.",
        "..DDD........DDD..",
    ], ["S": skin, "D": skinD])
    c.rect(26, 23, 4, 1, skinD); c.px(27, 24, skinD); c.px(28, 24, skinD)
    c.rect(21, 26, 3, 2, eye); c.px(23, 27, ink); c.rect(32, 26, 3, 2, eye); c.px(32, 27, ink)
    if roar > 0.3 { c.px(22, 26, white); c.px(33, 26, white) }
    c.pattern(26, 26, [".SS.", "SSSS", "D..D"], ["S": skin, "D": skinDD])
    if roar > 0.2 {
        // The jaws wide open, fangs above and below.
        c.rect(22, 29, 12, 4, C(0x3A0E0C)); c.rect(24, 30, 8, 2, C(0x8A2020))
        for x in [22, 24, 31, 33] { c.px(x, 29, white); c.px(x, 32, white) }
    } else {
        c.rect(22, 30, 12, 1, C(0x3A1410)); c.px(23, 31, white); c.px(24, 31, white); c.px(31, 31, white); c.px(32, 31, white)
    }

    // The front arm and its claws.
    let fist = { (x: Int, y: Int) in
        c.rect(x - 2, y - 2, 4, 4, skin); c.rect(x - 2, y + 1, 4, 1, skinD)
        for k in 0..<3 { c.px(x + 2, y - 2 + k + (k > 0 ? 1 : 0), nail) }
    }
    if up {
        slayerLine(c, 41.5, 26, 48, 18, skin, 1.8)
        fist(49, 17)
        if roar > 0.6 {
            // The roar going out ahead of him.
            let k = (p.t * 3).truncatingRemainder(dividingBy: 1)
            for i in 0..<3 {
                let x = 51.0 + Double(i) * 4 + k * 4, a = 0.6 * (1 - (Double(i) + k) / 3)
                slayerLine(c, x, 24, x + 2, 27, white.alpha(a), 0.4)
                slayerLine(c, x + 2, 29, x, 32, white.alpha(a), 0.4)
            }
        }
    } else if let a = p.melee {
        v3Punch(c, from: (41.5, 27), angle: a, trail: p.trail, reach: 9, arm: skin, thick: 1.8, smear: C(0xE0E0E8), fist: fist)
    } else {
        slayerLine(c, 41.5, 27, 45, 32, skin, 1.8)
        fist(46, 34)
    }
}
