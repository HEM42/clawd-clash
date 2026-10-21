import Foundation

// Villains: Edward Scissorhands and Corpse Bride. From the pastel suburb, Jimm the bully in his letterman jacket and
// Joyce Monrow, the neighbourhood's gossip; from Corpse Bride's dreary town, drawn in its grey-blues, Lord Barkiss
// Bittern the fortune hunter, Pastor Gallswell with his jaw and his staff, and the Everclawts, sour Finis and
// rigid Maudeline.

let burtonVillains3: [BurtonVillain: Persona] = [
    .jimm: Persona(name: "Jimm", weapon: .blaster, shot: .bullet, muzzle: (48, 31.5), headTop: 19, signature: 3.0,
                   draw: drawJimm),
    .joyceMonrow: Persona(name: "Joyce Monrow", weapon: .none, headTop: 18, signature: 3.4, draw: drawJoyce),
    .lordBarkissBittern: Persona(name: "Lord Barkiss Bittern", weapon: .saber, headTop: 15, signature: 3.4,
                                 draw: drawBarkiss),
    .pastorGallswell: Persona(name: "Pastor Gallswell", weapon: .saber, bulk: 2, headTop: 20, signature: 3.4,
                              draw: drawGallswell),
    .finisEverclawt: Persona(name: "Finis Everclawt", weapon: .saber, headTop: 26, signature: 3.0, draw: drawFinis),
    .maudelineEverclawt: Persona(name: "Maudeline Everclawt", weapon: .none, headTop: 9, signature: 3.2,
                                 draw: drawMaudeline),
]

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// Light swept off a fast swing of something `length` long from `h`: faint copies where it just was.
private func swingTrail(_ c: PixelCanvas, from h: (x: Double, y: Double), _ trail: [Double], length: Double) {
    for (i, ta) in trail.enumerated() {
        let e = burtonReach(h, ta, length)
        c.glowLine(h.x, h.y, e.x, e.y, core: C(0xE8ECF4), glow: C(0xE8ECF4), coreR: 0.6, glowR: 1.8,
                   strength: 0.3 / Double(i + 1))
    }
}

// MARK: - Jimm

/// Jimm: the suburb's bully: Clawd with a blond mullet, short and spiky on top and long down the back, a sneer, and
/// a red letterman jacket with cream sleeves and striped cuffs, jeans and white sneakers. He shoots a pistol.
/// Signature: he dangles the keys to his van from one finger, jangling them, and sneers.
private func drawJimm(_ c: PixelCanvas, _ p: Pose) {
    let red = C(0xB8202A), redD = C(0x8A1420), cream = C(0xF0E4C8), creamD = C(0xCCBE9E)
    let hair = C(0xE8C860), hairL = C(0xF8E49A), hairD = C(0xB89838), gun = C(0x2A2A30), gunL = C(0x5A5A66)
    let sig = p.signature
    let jangling = sig.map { $0 > 0.08 && $0 < 0.9 } ?? false

    drawLegs(c, Look(leg: C(0x3A4A6A)), step: p.step)
    burtonBoots(c, step: p.step, C(0xF0F0F0), height: 2)
    c.oy += p.breathe
    // The long back of the mullet, hanging down behind him.
    c.pattern(14, 25, ["HHHH", "HHHH", "HHhH", "HHHH", "HhHH", ".HHH", ".HH.", "..H."], ["H": hair, "h": hairD])
    drawBody(c, Look(arm: cream))
    // The sneer: one brow down, the lip curled up on one side.
    c.pattern(21, 27, ["KKK.......KK", "...K.....K.."], ["K": hairD])
    c.pattern(25, 31, [".....K", "KKKKK."], ["K": C(0x6A2A22)])
    // The letterman jacket over the bottom of him: ribbed collar and hem, snaps down the front, a cream patch.
    c.rect(18, 33, 20, 5, red); c.rect(37, 33, 1, 5, redD)
    burtonStripes(c, 18, 37, 20, 1, alongX: true, width: 1, light: cream, dark: red)
    for y in [34, 36] { c.px(28, y, cream) }
    c.pattern(32, 34, ["CCC", "CRC", "CCC"], ["C": cream, "R": redD])
    c.rect(15, 35, 3, 1, creamD); c.rect(38, 35, 3, 1, creamD)
    c.rect(18, 21, 20, 5, clawdOrange); c.rect(37, 21, 1, 5, clawdShade)
    // The mullet's top: short and spiky.
    c.pattern(17, 19, [
        "....H..H..H...H.......",
        "...HH.HHH.HH.HHH......",
        "..HHHHHHHHHHHHHHHH....",
        ".HHHHhhHHHHhhHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHH...........HHHHHH.",
        ".HH.................H.",
    ], ["H": hair, "h": hairL])
    // The van keys dangling from his left hand, swinging.
    if jangling {
        burtonLine(c, 16.5, 34, 14, 29, cream, 1.0); c.rect(13, 27, 2, 2, clawdOrange)
        c.rect(13, 29, 2, 1, C(0xC8CCD4))
        let swing = sin(p.t * 14) * 2
        for (k, dx) in [-1.5, 0.0, 1.5].enumerated() {
            let x = 13.5 + dx + swing * (0.6 + Double(k) * 0.2), y = 33.0 + Double(k % 2)
            burtonLine(c, 13.5, 30, x, y, C(0xC8CCD4), 0.5)
            c.rect(Int(x.rounded()) - 1, Int(y.rounded()), 2, 2, k == 1 ? C(0xE0B840) : C(0xC8CCD4))
        }
        if frac(p.t * 3) < 0.3 { c.pattern(8, 29, ["W.", ".W", "..", ".W", "W."], ["W": C(0xFFFFFF, 0.9)]) }
    }
    // The pistol: raised to fire, or down at his side.
    if p.fire != nil || p.ready || p.gunLift > 0 {
        c.oy += p.gunY
        c.rect(40, 32, 2, 2, clawdOrange)
        c.pattern(41, 30, ["KKKKKKK", "KLKKKKK", "KK.....", "KK....."], ["K": gun, "L": gunL])
    } else {
        c.pattern(39, 36, ["KK", "KL", "K.", "K."], ["K": gun, "L": gunL])
    }
}

// MARK: - Joyce Monrow

/// Joyce Monrow: the neighbourhood's man-eater and gossip: Clawd under a huge mane of teased red hair, blue eye
/// shadow, red lips and gold hoops, in a leopard-print dress, a pink telephone receiver in her hand. She doesn't
/// fight. Signature: the receiver up at her ear, she gossips into it, eyes wide, mouth going nineteen to the dozen.
private func drawJoyce(_ c: PixelCanvas, _ p: Pose) {
    let hair = C(0xC8401E), hairL = C(0xE8683A), hairD = C(0x8E2A12), phone = C(0xF0A0C0), phoneD = C(0xC87898)
    let leo = C(0xD8A250), leoD = C(0x3A2414), leoM = C(0x8A5A2A)
    let sig = p.signature
    let talking = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false
    let mouthOpen = talking && frac(p.t * 5) < 0.5

    drawLegs(c, Look(), step: p.step)
    burtonBoots(c, step: p.step, C(0x1A1418), height: 1)
    c.oy += p.breathe
    c.rect(18, 21, 20, 5, clawdOrange); c.rect(37, 21, 1, 5, clawdShade)
    // The big hair, behind: teased out wide and falling to her shoulders.
    c.pattern(13, 18, [
        "......HHhHHHHHHHHhHHHHH......",
        "...HHHHHHHHHHHHHHHHHHHHHHH...",
        "..HHHHhHHHHHHHHHHHHHHhHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHH...................HHHHH",
        "HHHH.....................HHHH",
        "HHHH.....................HHHH",
        "HHHd.....................dHHH",
        ".HHd.....................dHH.",
        ".HH.......................HH.",
        "..H.......................H..",
    ], ["H": hair, "h": hairL, "d": hairD])
    for (x, y) in [(16, 20), (24, 19), (33, 20), (38, 22), (20, 22)] { c.px(x, y, hairL) }
    // The leopard-print dress: a short skirt over her legs, the bodice over the bottom of her.
    let hem = seatedPose ? 38 : 39
    for y in 33...hem {
        for x in 17...38 where y >= 38 || (x >= 18 && x <= 37) {
            let n = noise(x * 37 + y * 101 + 900)
            c.px(x, y, n < 0.14 ? leoD : n < 0.24 ? leoM : leo)
        }
    }
    drawBody(c, Look(arm: leo, eye: nil))
    for y in 33...37 {
        for x in 18...37 {
            let n = noise(x * 37 + y * 101 + 900)
            c.px(x, y, n < 0.14 ? leoD : n < 0.24 ? leoM : x == 37 ? leoM : leo)
        }
    }
    // Eyes (wide while she gossips), blue shadow over them, red lips, gold hoops.
    if talking {
        for ex in [21, 31] { c.pattern(ex, 28, ["WWWW", "WKKW", "WKKW", "WWWW"], ["W": C(0xFFFFFF), "K": ink]) }
    } else {
        c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
        c.rect(21, 28, 4, 1, C(0x4A8AD8)); c.rect(31, 28, 4, 1, C(0x4A8AD8))
    }
    c.pattern(25, 32, mouthOpen ? [".RRRR.", "RKKKKR", ".RRRR."] : ["RRRRRR", ".RRRR."],
              ["R": C(0xD0202A), "K": C(0x4A0A10)])
    c.pattern(17, 31, [".G.", "G.G", ".G."], ["G": C(0xE0B830)])
    // The phone receiver: at her ear while she gossips, or dangling from her hand.
    if talking {
        burtonLine(c, 39.5, 34, 40.5, 32, leo, 1.1)
        c.pattern(37, 24, [".PP", "PPP", "PP.", "Pd.", "Pd.", "Pd.", "PP.", "PPP", ".PP"], ["P": phone, "d": phoneD])
        if frac(p.t * 1.7) < 0.6 {
            c.pattern(42, 22, ["W.W.W"], ["W": C(0xFFFFFF, 0.85)])
            c.pattern(43, 19, ["W..W", ".WW."], ["W": C(0xFFFFFF, 0.6)])
        }
    } else {
        c.pattern(39, 35, ["PPPPPPP", "PP...PP", "P.....P"], ["P": phone])
    }
}

// MARK: - Lord Barkiss Bittern

/// Lord Barkiss Bittern: a fortune hunter posing as a lord, in the living world's grey-blues: the block grey-blue with
/// sly half-lidded eyes, a thin moustache and a great long chin jutting out in front, a wide plumed hat, a dark
/// doublet with gold buttons, and a red cape flung back off his shoulders. He fights with a rapier. Signature: he
/// sweeps his cape round in front of him and back, with a sly grin and a glint off his teeth.
private func drawBarkiss(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xA4AEC2), skinD = C(0x828CA4), cape = C(0xB0202A), capeD = C(0x7A1420), capeL = C(0xD03A40)
    let doublet = C(0x2A2834), doubletD = C(0x1A1820), hat = C(0x2A1E30), hatL = C(0x44344E), gold = C(0xE0B840)
    let sig = p.signature
    let sweep = sig.map { sin(ramp($0, 0.1, 0.8) * .pi) } ?? 0
    let grin = sig.map { $0 > 0.3 && $0 < 0.9 } ?? false
    let glint = sig.map { $0 > 0.5 && $0 < 0.62 } ?? false

    drawLegs(c, Look(leg: C(0x3A3A48)), step: p.step)
    burtonBoots(c, step: p.step, C(0x14121A), height: 3)
    c.oy += p.breathe
    // The red cape flung back off his shoulders, hanging behind him.
    if sweep < 0.3 {
        c.pattern(10, 29, [
            "......CCCC",
            ".....CCCCC",
            "....CCCCCC",
            "...CCCcCCC",
            "...CCCcCCC",
            "..CCCCcCCC",
            "..CCCCCcCC",
            ".CCCCCCcCC",
            ".CCCCCCcCC",
            "CCCCCCCcCC",
            "CCCCCCCCcC",
            "dddddddddd",
        ], ["C": cape, "c": capeD, "d": capeD])
    }
    drawBody(c, Look(body: skin, shade: skinD, arm: doublet, eye: nil))
    // The great long chin, jutting out in front of him.
    c.pattern(36, 30, ["SSSS..", "SSSSSS", "SSSSSS", "SSSSSd", ".SSSd.", "..dd.."], ["S": skin, "d": skinD])
    // Sly half-lidded eyes, the thin moustache, a smirk (a toothy grin with a glint in the signature).
    for ex in [22, 32] { c.rect(ex - 1, 29, 3, 1, skinD); c.rect(ex, 30, 2, 2, ink) }
    c.pattern(28, 31, ["MMMMMMMM", "M......M"], ["M": C(0x1E1C24)])
    if grin {
        c.pattern(29, 32, ["KWWWWWK", ".KKKKK."], ["K": C(0x3A1A22), "W": C(0xF4F2EA)])
    } else {
        c.pattern(30, 33, ["KKKK.K", "....K."], ["K": C(0x3A1A22)])
    }
    if glint { c.pattern(33, 29, ["..W..", ".WWW.", "WWWWW", ".WWW.", "..W.."], ["W": C(0xFFFFFF, 0.95)]) }
    // The doublet over the bottom of him, a white lace jabot, gold buttons.
    c.rect(18, 35, 20, 3, doublet); c.rect(37, 35, 1, 3, doubletD)
    c.pattern(24, 35, ["WWWW", ".WW."], ["W": C(0xE8E8EE)])
    c.px(30, 36, gold); c.px(33, 36, gold)
    // The wide hat, its brim swept up, a white plume curling back off it.
    c.pattern(16, 19, [
        "......HHHHHHHHHH......",
        ".....HHHHHHHHHHHH.....",
        ".....HHHHHHHHHHHH.....",
        ".....BBBBBBBBBBBB.....",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "LHHHHHHHHHHHHHHHHHHHHH",
        "...LLLLLLLLLLLLLLLL...",
    ], ["H": hat, "L": hatL, "B": cape])
    c.pattern(9, 15, ["......WW..", "....WWWWW.", "..WWWWWWWW", ".WWWWWGWWW", "WWWW....GW", "WW........", "W........."],
              ["W": C(0xF0EEF4), "G": C(0xC8C4D0)])
    // The cape swept round in front of him, up to his chin.
    if sweep >= 0.3 {
        // Its front edge swings out in a curve, billowing; folds run down it, and its lining shows at the edge.
        let edge = 12.0 + sweep * 30
        for y in 32...41 {
            let f = Double(y - 32) / 9
            let right = Int((edge - sin(f * .pi) * 4 * sweep + f * 2).rounded())
            let left = 11 + Int((f * 2).rounded())
            guard right > left else { continue }
            c.rect(left, y, right - left, 1, cape)
            for fx in stride(from: left + 3, to: right - 2, by: 5) { c.px(fx + (y % 3 == 0 ? 1 : 0), y, capeD) }
            c.rect(right - 2, y, 2, 1, capeD)
            if y == 32 { c.rect(left, y, right - left, 1, capeL) }
            if y == 41 { c.rect(left, y, right - left, 1, capeD) }
        }
        return
    }
    // The rapier: swung along `p.melee`, or at his hip.
    if let a = p.melee {
        swingTrail(c, from: Sprite.hand, p.trail, length: 16)
        let s = burtonReach(Sprite.hand, a, -2), g = burtonReach(Sprite.hand, a, 1.5)
        let e = burtonReach(Sprite.hand, a, 17)
        let r = a * .pi / 180, sx = -sin(r), sy = cos(r)
        burtonLine(c, s.x, s.y, g.x, g.y, C(0x3A2A1A), 0.7)
        burtonLine(c, g.x, g.y, e.x, e.y, C(0xD0D4DC), 0.55)
        burtonLine(c, g.x + sx * 2, g.y + sy * 2, g.x - sx * 2, g.y - sy * 2, gold, 0.7)
        c.rect(Int(g.x.rounded()) - 1, Int(g.y.rounded()) - 1, 2, 2, gold)
    } else {
        c.rect(38, 36, 3, 2, gold); burtonLine(c, 40, 37, 47, 41, C(0x1E1A22), 0.7)
    }
}

// MARK: - Pastor Gallswell

/// Pastor Gallswell: the town's thundering pastor, in the living world's grey-blues: the block grey-blue with a huge
/// jaw jutting forward under it, an underbite of teeth, beetling brows, a flat black clerical hat, and long black robes
/// to the floor with white preaching bands at the neck. He fights with his crooked staff. Signature: he thunders a
/// sermon, finger raised, the jaw going, thumping his staff on the floor.
private func drawGallswell(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x9CA6BA), skinD = C(0x7A849C), robe = C(0x1C1A22), robeD = C(0x121016), robeL = C(0x34303C)
    let wood = C(0x5A3E26), woodL = C(0x7A5A3A), gold = C(0xC8A040), tooth = C(0xE8E4D8)
    let sig = p.signature
    let preaching = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false
    let shout = preaching && frac(p.t * 3) < 0.55
    let thump = preaching && frac(p.t * 1.5) < 0.12 ? 1 : 0

    drawLegs(c, Look(leg: robeD), step: p.step)
    burtonBoots(c, step: p.step, C(0x08080A), height: 1)
    c.oy += p.breathe
    // The long black robe over his legs, nearly to the floor.
    let hem = seatedPose ? 39 : 41
    for y in 38...hem { let hw = 11 + (y - 38) / 2; c.rect(28 - hw, y, hw * 2, 1, robe); c.px(28 + hw - 1, y, robeD) }
    drawBody(c, Look(body: skin, shade: skinD, arm: robe, eye: nil))
    // The huge jaw jutting out under the block, an underbite of teeth along its top; open while he shouts.
    let drop = shout ? 2 : 0
    c.pattern(20, 31 + drop, [
        "..SSSSSSSSSSSSSSSSSSSS",
        ".SSSSSSSSSSSSSSSSSSSSS",
        "SSSSSSSSSSSSSSSSSSSSSd",
        "SSSSSSSSSSSSSSSSSSSSd.",
        ".dddddddddddddddddd...",
    ], ["S": skin, "d": skinD])
    if shout { c.rect(24, 31, 16, 2, C(0x2A1418)) }
    c.pattern(24, 31 + drop, ["T.T.T.T.T.T.T.T."], ["T": tooth])
    // Beetling brows over small fierce eyes.
    c.pattern(20, 27, ["BBBBB.....BBBBB", "...BB.....BB..."], ["B": C(0x3A3E4A)])
    c.rect(22, 29, 2, 2, ink); c.rect(32, 29, 2, 2, ink)
    // The robe over the bottom of him, the white preaching bands at his neck.
    c.rect(18, 36 + drop / 2, 20, 2 - drop / 2, robe)
    c.rect(18, 36, 1, 2, robeL)
    c.pattern(26, 36, ["WW.WW", "WW.WW"], ["W": C(0xF0F0F4)])
    // The flat black clerical hat on top.
    c.pattern(17, 20, [
        "....HHHHHHHHHHHHHH....",
        "...HHHHHHHHHHHHHHHH...",
        "...HHHHHHHHHHHHHHHH...",
        "...LLLLLLLLLLLLLLLL...",
        "HHHHHHHHHHHHHHHHHHHHHH",
        ".HHHHHHHHHHHHHHHHHHHH.",
    ], ["H": robe, "L": robeL])
    // His left hand: a finger raised to heaven while he preaches.
    if preaching {
        burtonLine(c, 16.5, 34, 13, 26, robe, 1.2); c.rect(12, 24, 3, 2, skin); c.rect(13, 20, 1, 4, skin)
        if shout {
            for (x, y) in [(43, 28), (45, 31), (43, 34)] { c.rect(x, y, 2, 1, C(0xFFFFFF, 0.8)) }
        }
    }
    // The crooked staff: swung along `p.melee`, or planted upright beside him (thumped down as he preaches).
    if let a = p.melee, !preaching {
        swingTrail(c, from: Sprite.hand, p.trail, length: 15)
        let s = burtonReach(Sprite.hand, a, -4), e = burtonReach(Sprite.hand, a, 15)
        burtonLine(c, s.x, s.y, e.x, e.y, wood, 0.8)
        let k = burtonReach(e, a, 2)
        c.rect(Int(k.x.rounded()) - 1, Int(k.y.rounded()) - 1, 3, 3, gold)
        c.rect(39, 33, 3, 3, robe)
    } else {
        c.oy += thump
        c.rect(43, 20, 2, 23 - thump, wood); c.rect(43, 20, 1, 23 - thump, woodL)
        c.pattern(41, 15, [".GGG.", "GG.GG", "G...G", ".G.G.", "..G.."], ["G": gold])
        c.rect(40, 32, 4, 3, robe)
        if thump > 0 { c.pattern(40, 42, ["D.....D", ".D...D."], ["D": C(0xC8C4BC, 0.7)]) }
    }
}

// MARK: - Finis Everclawt

/// Finis Everclawt: Victoria's father, short, stout and sour, in the living world's grey-blues: a squat, wide grey-blue
/// block, bald on top with grey side-whiskers, bushy brows over a scowl, a turned-down mouth, a dark frock coat over a
/// grey waistcoat with a gold watch chain. He fights with his cane. Signature: he taps the cane on the floor, twice,
/// and scowls harder.
private func drawFinis(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xA0AABE), skinD = C(0x7E889E), coat = C(0x262A36), coatD = C(0x181A24), vest = C(0x6A6E7A)
    let whisker = C(0xC8CCD4), cane = C(0x16141A), knob = C(0xD0D4DC), gold = C(0xE0B840)
    let sig = p.signature
    let tapK = sig.map { $0 > 0.1 && $0 < 0.6 ? frac(ramp($0, 0.1, 0.6) * 2) : 1 } ?? 1
    let tapping = sig.map { $0 > 0.1 && $0 < 0.6 } ?? false
    let lift = tapping ? Int((sin(tapK * .pi) * 3).rounded()) : 0
    let scowl = sig.map { $0 > 0.55 && $0 < 0.95 } ?? false

    drawLegs(c, Look(leg: C(0x2A2C38)), step: p.step)
    burtonBoots(c, step: p.step, C(0x0C0C10), height: 1)
    c.oy += p.breathe
    // The coat's short tails over his legs.
    c.rect(16, 38, 24, seatedPose ? 1 : 2, coat); c.rect(28, 38, 1, seatedPose ? 1 : 2, coatD)
    // A squat, wide block: stout.
    for y in 26...37 {
        let inset = max(0, 3 - (y - 26))
        c.rect(16 + inset, y, 24 - inset * 2, 1, skin); c.px(39 - inset, y, skinD)
    }
    c.rect(16, 37, 24, 1, skinD)
    c.rect(13, 33, 3, 3, coat); c.rect(40, 33, 3, 3, coat)
    // Bushy brows (lower when he scowls hard), small eyes, the turned-down mouth.
    let by = scowl ? 30 : 29
    c.pattern(20, by, ["WWWWW......WWWWW", "...WW......WW..."], ["W": whisker])
    c.rect(22, 31, 2, 2, ink); c.rect(32, 31, 2, 2, ink)
    c.pattern(25, 33, scowl ? [".KKKKKK.", "K......K"] : ["..KKKK..", ".K....K."], ["K": C(0x2A2A34)])
    // Grey side-whiskers, the bald top.
    c.pattern(14, 28, [".WW", "WWW", "WWWW", "WWWW", "WWW", ".WW", "..W"], ["W": whisker])
    c.pattern(38, 28, ["WW.", "WWW", "WWWW", "WWWW", "WWW", "WW.", "W.."], ["W": whisker])
    c.rect(22, 26, 10, 1, C(0xC0C8D8)); c.rect(20, 27, 3, 1, C(0xC0C8D8))
    // The frock coat over the bottom of him, open on the waistcoat and its gold watch chain.
    c.rect(16, 35, 24, 3, coat); c.rect(39, 35, 1, 3, coatD)
    c.rect(24, 35, 8, 3, vest); c.pattern(24, 36, ["GG..GGG."], ["G": gold])
    // The cane: swung along `p.melee`, or planted in front of him, tapping.
    if let a = p.melee, !tapping {
        swingTrail(c, from: Sprite.hand, p.trail, length: 12)
        let s = burtonReach(Sprite.hand, a, -2), e = burtonReach(Sprite.hand, a, 13)
        burtonLine(c, s.x, s.y, e.x, e.y, cane, 0.7)
        c.rect(Int(s.x.rounded()) - 1, Int(s.y.rounded()) - 1, 3, 2, knob)
    } else {
        let top = 31 - lift
        c.rect(43, top + 2, 1, 43 - top - 2 - lift, cane); c.rect(42, top, 3, 2, knob)
        c.rect(41, 33, 2, 2, coat)
        if tapping && lift == 0 { c.pattern(40, 42, ["D...D"], ["D": C(0xC8C4BC, 0.7)]) }
    }
    if scowl, let s = sig, frac(s * 6) < 0.5 {
        c.pattern(12, 25, ["W.", ".W", "W."], ["W": C(0xFFFFFF, 0.6)])
    }
}

// MARK: - Maudeline Everclawt

/// Maudeline Everclawt: Victoria's mother, tall and rigid as a poker, in the living world's grey-blues: the block
/// grey-blue and drawn up taller, her hair scraped up into a towering grey beehive, narrowed eyes and a tiny pinched
/// mouth, a grey gown buttoned to a high collar and falling straight to the floor, a gold lorgnette in her hand. She
/// doesn't fight. Signature: she raises the lorgnette to her eyes and sniffs, disapproving.
private func drawMaudeline(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xA8B0C4), skinD = C(0x868EA6), gown = C(0x5E6270), gownD = C(0x464A56), gownL = C(0x7A7E8C)
    let hair = C(0x7A7C88), hairL = C(0x9EA0AC), hairD = C(0x5A5C68), gold = C(0xE0B840)
    let sig = p.signature
    let up = sig.map { min(ramp($0, 0.08, 0.22), 1 - ramp($0, 0.82, 0.94)) } ?? 0
    let sniff = sig.map { $0 > 0.35 && $0 < 0.75 } ?? false

    drawLegs(c, Look(leg: gownD), step: p.step)
    burtonBoots(c, step: p.step, C(0x101014), height: 1)
    c.oy += p.breathe
    // The gown falling straight to the floor over her legs.
    let hem = seatedPose ? 38 : 40
    c.rect(17, 38, 22, hem - 37, gown); c.rect(37, 38, 2, hem - 37, gownD); c.rect(17, 38, 1, hem - 37, gownL)
    // The block, drawn up three rows taller.
    drawBody(c, Look(body: skin, shade: skinD, arm: gown, eye: nil))
    c.rect(18, 23, 20, 3, skin); c.rect(37, 23, 1, 3, skinD)
    // Narrowed eyes under thin arched brows (shut while she sniffs), the tiny pinched mouth.
    c.pattern(21, 26, [".KKK......KKK.", "K...K....K...K"], ["K": hairD])
    if sniff {
        c.rect(22, 30, 2, 1, ink); c.rect(32, 30, 2, 1, ink)
    } else {
        c.rect(22, 29, 2, 2, ink); c.rect(32, 29, 2, 2, ink)
    }
    c.pattern(26, 32, ["K..K", ".KK."], ["K": C(0x3A3644)])
    // The gown over the bottom of her, the high collar up her neck, buttons.
    c.rect(18, 34, 20, 4, gown); c.rect(37, 34, 1, 4, gownD)
    c.pattern(18, 31, ["GG................GG", "GGG..............GGG", "GGGGGGGGGGGGGGGGGGGG"], ["G": gownL])
    for y in [35, 37] { c.px(28, y, gownL) }
    c.rect(18, 19, 20, 4, skin); c.rect(37, 19, 1, 4, skinD)
    // The towering beehive, scraped up off her brow.
    c.pattern(18, 9, [
        "......HHHHHHH.......",
        ".....HHHHHHHHH......",
        "....HHhHHHHHHHH.....",
        "....HHhHHHHHHHd.....",
        "....HHHhHHHHHHd.....",
        "....HHHhHHHHHHd.....",
        "...HHHHHhHHHHHHd....",
        "...HHHHHHHHHHHHd....",
        "..HHHHHHHHHHHHHHd...",
        ".HHHHHHHHHHHHHHHHd..",
        ".HHHHHHHHHHHHHHHHHd.",
        "HHHHHHHHHHHHHHHHHHHd",
        "HHHH............HHHd",
        "HH................Hd",
    ], ["H": hair, "h": hairL, "d": hairD])
    for y in [12, 15, 18] { c.rect(23, y, 9, 1, hairD) }
    c.rect(21, 21, 13, 1, hairD)
    // The lorgnette: at her eyes on its handle, or held down at her side.
    if up > 0 {
        let y = 34 - Int((up * 6).rounded())
        burtonLine(c, 39.5, 34, 40, Double(y + 1), gown, 1.1); c.rect(39, y, 2, 2, skin)
        if up > 0.9 {
            c.pattern(20, 27, ["GGGG......GGGG", "G..GGGGGGGG..G", "G..G......G..G", "GGGG......GGGG"], ["G": gold])
            burtonLine(c, 35, 29, 39.5, Double(y), gold, 0.5)
        } else {
            burtonLine(c, 40, Double(y), 41, Double(y - 5), gold, 0.5)
        }
        if sniff, frac(p.t * 2.5) < 0.5 {
            c.pattern(34, 25, [".W.W", "W.W."], ["W": C(0xFFFFFF, 0.75)])
        }
    } else {
        c.rect(38, 33, 3, 3, gown)
        burtonLine(c, 40, 36, 40, 40, gold, 0.5); c.pattern(39, 40, ["GGG", "G.G", "GGG"], ["G": gold])
    }
}
