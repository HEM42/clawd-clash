import Foundation

// Villains: the Master's Order of Aurelius and the vampires who came after it. Clawd in costume like the rest of the
// cast; a vampire's game face (a ridged brow, yellow eyes and fangs over Clawd's own orange face) is fine detail, so
// each one's outfit and outline carries them, and the face only comes out when they fight (Lukewarm wears it always).

let slayerVillains2: [SlayerVillain: Persona] = [
    .lukewarm: Persona(name: "Lukewarm", weapon: .saber, bulk: 2, headTop: 21, signature: 3.6, draw: drawLukewarm),
    .darlah: Persona(name: "Darlah", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 20, signature: 3.0,
                     draw: drawDarlah),
    .drusillah: Persona(name: "Drusillah", weapon: .lightning,
                        magic: Magic(core: C(0xF2E2FF), glow: C(0xB46AA8), jagged: false, rings: true),
                        pivot: (44.0, 31.0), headTop: 20, signature: 3.6, callout: "Naming all the stars.",
                        draw: drawDrusillah),
    .mrTricks: Persona(name: "Mr. Tricks", weapon: .saber, headTop: 22, signature: 2.8, draw: drawMrTricks),
    .harmonyClawdall: Persona(name: "Harmony Clawdall", weapon: .blaster, shot: .arrow, muzzle: (47, 32), handGun: false,
                              headTop: 20, signature: 2.6, callout: "Blondie Bear!", draw: drawHarmonyClawdall),
]

// MARK: - Shared bits

/// Fighting, or squaring up to it: when a vampire's game face comes out.
private func slFighting(_ p: Pose) -> Bool {
    p.melee != nil || p.fire != nil || p.zap != nil || p.hit || p.ready
}

/// The game face over Clawd's own: the ridged brow, yellow eyes with a dark pupil, the bumpy nose and the two fangs.
/// Draw the body with `eye: nil` under it.
private func slGameFace(_ c: PixelCanvas, ridge: Px = C(0x9A4A30)) {
    let eye = C(0xF2D040)
    c.pattern(21, 27, ["RRRR......RRRR", ".RR........RR."], ["R": ridge])
    c.rect(22, 29, 2, 2, eye); c.px(23, 30, ink); c.rect(32, 29, 2, 2, eye); c.px(32, 30, ink)
    c.pattern(26, 30, ["R..R", ".RR."], ["R": ridge])
    c.rect(25, 32, 6, 1, C(0x5A2418)); c.px(26, 33, white); c.px(29, 33, white)
}

/// A punch along `angle`: the sleeve thrown out, a big fist on the end (with a shirt cuff, if there's one), and a faint
/// smear where a fast swing just was.
private func slFist(_ c: PixelCanvas, angle: Double, trail: [Double], sleeve: Px, cuff: Px? = nil, reach len: Double = 7) {
    slayerSmear(c, slayerHand, trail, from: len - 1, to: len + 2, C(0xF4E8D0))
    let e = slayerReach(slayerHand, angle, len)
    slayerLine(c, slayerHand.x - 2, slayerHand.y - 0.5, e.x, e.y, sleeve, 1.3)
    if let cuff {
        let k = slayerReach(slayerHand, angle, len - 2)
        c.rect(Int(k.x.rounded()) - 1, Int(k.y.rounded()) - 1, 2, 2, cuff)
    }
    c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 4, 4, clawdOrange)
    c.px(Int(e.x.rounded()) + 2, Int(e.y.rounded()) + 2, clawdShade)
}

// MARK: - Lukewarm

/// Lukewarm: the Master's right hand from "The Harvest", a big vampire with broad, hunched shoulders under a long black
/// coat, dark hair slicked straight back, and his game face always on. He fights with his fists. Signature: the sermon
/// at the Bronze: he spreads both arms wide, palms up, and preaches, his mouth working.
private func drawLukewarm(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x1E1C22), coatD = C(0x0E0D12), coatL = C(0x3C3842), shirt = C(0x4A1A22)
    let hair = C(0x1A1418), hairL = C(0x3A2E34)
    let preachK = p.signature.map { $0 > 0.08 && $0 < 0.92 ? ($0 - 0.08) / 0.84 : -1 } ?? -1
    let spread = preachK >= 0 ? min(1, min(preachK, 1 - preachK) * 5) : 0

    // Mid-grey trousers, lit down their left side, so the legs read as legs once outlined, not as white stripes.
    drawLegs(c, Look(leg: C(0x4A4652)), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx, 38, 1, 4, C(0x625C6C)) } }
    slayerBoots(c, step: p.step, C(0x0E0C10), height: 2)
    c.oy += p.breathe
    // The long coat's skirts over the legs, split up the middle.
    c.rect(16, 38, 24, seatedPose ? 1 : 3, coat); c.rect(16, seatedPose ? 38 : 40, 24, 1, coatD)
    if !seatedPose { c.rect(28, 38, 1, 3, coatD) }
    drawBody(c, Look(arm: coat, eye: nil))
    // Broad shoulders, hunched up past Clawd's own, and the coat over the chest, open on a dark red shirt.
    c.rect(16, 33, 24, 5, coat); c.rect(15, 32, 4, 2, coat); c.rect(37, 32, 4, 2, coat)
    c.rect(39, 33, 1, 5, coatD); c.rect(16, 37, 24, 1, coatD)
    c.rect(25, 33, 6, 5, shirt); c.rect(24, 33, 1, 5, coatL); c.rect(31, 33, 1, 5, coatL)
    c.rect(16, 32, 3, 1, coatL)
    c.rect(16, 33, 1, 4, coatL)                                              // the coat lit down the near side
    c.rect(20, 35, 1, 2, coatD); c.rect(35, 35, 1, 2, coatD)                 // folds
    // Hair slicked straight back off the brow, lying flat on top.
    c.pattern(17, 21, [
        "....HHHHHHHHHHHH....",
        "..HHHhhhHHHHhhHHHHH.",
        ".HHHHHHHHHHHHHHHHHHH",
        ".HHhhHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHH",
        "HHHH............HHHH",
        "HHH..............HHH",
        "HH................HH",
    ], ["H": hair, "h": hairL])
    slayerGameFaceLuke(c, mouth: preachK >= 0 && Int(p.t * 5) % 2 == 0)

    if preachK >= 0 {
        // Arms out wide, palms up: the congregation of the Bronze.
        let s = spread
        let lx = 15 - s * 6, rx = 40 + s * 6, ay = 33 - s * 4
        slayerLine(c, 17, 33.5, lx, ay, coat, 1.3); slayerLine(c, 39, 33.5, rx, ay, coat, 1.3)
        c.rect(Int(lx.rounded()) - 2, Int(ay.rounded()) - 1, 3, 2, clawdOrange)
        c.rect(Int(rx.rounded()), Int(ay.rounded()) - 1, 3, 2, clawdOrange)
        return
    }
    if let a = p.melee {
        slFist(c, angle: a, trail: p.trail, sleeve: coat)
    } else {
        c.rect(39, 35, 3, 3, clawdOrange)   // a big fist at his side
    }
}

/// Lukewarm's face, heavier than the rest: a thick ridged brow, deep-set yellow eyes, the bumpy nose and fangs, the
/// mouth open when he's preaching.
private func slayerGameFaceLuke(_ c: PixelCanvas, mouth open: Bool) {
    let ridge = C(0x8E3E26)
    c.pattern(20, 26, ["RRRRRR..RRRRRR", ".RRRR....RRRR."], ["R": ridge])
    c.rect(22, 28, 2, 2, C(0xF2D040)); c.px(23, 29, ink); c.rect(31, 28, 2, 2, C(0xF2D040)); c.px(31, 29, ink)
    c.pattern(26, 28, ["R..R", "R..R", ".RR."], ["R": ridge])
    c.rect(24, 31, 8, open ? 2 : 1, C(0x4A1A12))
    c.px(25, 32, white); c.px(30, 32, white)
}

// MARK: - Darlah

/// Darlah: Clawd with long golden hair falling in waves past her shoulders, a dark burgundy dress with a low square
/// neck and long sleeves, and a pistol in each hand, as when she came for Buffy in "Angel". Signature: she twirls both
/// pistols round her trigger fingers, then catches them pointing forward.
private func drawDarlah(_ c: PixelCanvas, _ p: Pose) {
    let dress = C(0x5A1A2E), dressD = C(0x3A0E1C), dressL = C(0x7E2E44)
    let hair = C(0xE0B456), hairL = C(0xF4D68A), hairD = C(0xB48A36)
    let steel = C(0xA4AAB6), steelD = C(0x5A5E6A), grip = C(0x3A2620)
    let twirlK = p.signature.map { $0 > 0.1 && $0 < 0.9 ? ($0 - 0.1) / 0.8 : -1 } ?? -1
    let face = slFighting(p)

    drawLegs(c, Look(leg: C(0x2A1A22)), step: p.step)
    slayerBoots(c, step: p.step, C(0x141014), height: 1)
    // The dress, falling over the legs to the shins.
    c.rect(17, 38, 22, seatedPose ? 1 : 3, dress); c.rect(17, seatedPose ? 38 : 40, 22, 1, dressD)
    if !seatedPose { c.rect(22, 38, 1, 2, dressL); c.rect(33, 38, 1, 2, dressD) }
    c.oy += p.breathe
    drawBody(c, Look(arm: dress, eye: face ? nil : ink), armLeft: twirlK >= 0 ? 2 : 0, armRight: twirlK >= 0 ? 2 : 0)
    c.rect(18, 34, 20, 4, dress); c.rect(37, 34, 1, 4, dressD); c.rect(18, 37, 20, 1, dressD)
    c.rect(24, 34, 8, 1, dressD); c.rect(19, 35, 1, 2, dressL)
    if face { slGameFace(c) }
    // Long golden waves from a middle parting, spilling out past her shoulders and ending in curls: narrow at the
    // crown and widening as it falls, its edge bulging in and out with each wave, the light along each strand.
    c.pattern(14, 20, [
        "..........HHHHHHH...........",
        "........HHHHHdHHlHH.........",
        "......HHlHHHHdHHHlHHH.......",
        ".....HHlHHHHHdHHHHlHHH......",
        "....HHlHHHlHHHHHHHHlHHH.....",
        "....HlHHHlHHHHHHHHHHlHHH....",
        "...HlHHHH..........HHlHH....",
        "..HlHHHH............HHlHH...",
        "..HHlHH..............HHlH...",
        ".HHlHH...............HHHlH..",
        ".HlHHd................HlHH..",
        "HHHlH.................HHlHH.",
        ".HHlHd................dHHlH.",
        "HHlHHd................dHHlHH",
        ".HHHlH................HHlHH.",
        "HHdHHd................dHHdHH",
        ".dHd.d................d.dHd.",
        "..d......................d..",
    ], ["H": hair, "l": hairL, "d": hairD])

    if twirlK >= 0 {
        // Both arms out and up, a pistol spinning round each trigger finger, a faint blur where it's just been.
        slayerLine(c, 17, 34, 13, 28, dress, 1.2); slayerLine(c, 39, 34, 43, 28, dress, 1.2)
        let a = -twirlK * 4 * 360
        for (hx, hy, dir) in [(43.0, 26.0, 1.0), (13.0, 26.0, -1.0)] {
            let spin = dir > 0 ? a : 180 - a
            for k in 1...3 {
                let g = slayerReach((hx, hy), spin + dir * Double(k) * 35, 5.5)
                c.px(Int(g.x.rounded()), Int(g.y.rounded()), steel.alpha(0.2 / Double(k)))
            }
            slayerBar(c, (hx, hy), spin + dir * 100, from: 0.5, to: 4, grip, r: 0.9)
            slayerBar(c, (hx, hy), spin, from: -1.5, to: 6.5, steelD, r: 1.0)
            slayerBar(c, (hx, hy), spin, from: -1, to: 6, steel, r: 0.6)
            c.rect(Int(hx.rounded()) - 1, Int(hy.rounded()) - 1, 2, 2, clawdOrange)
        }
        return
    }
    // The second pistol in her left hand, reaching round under the first.
    c.oy += p.gunY
    c.rect(34, 35, 4, 2, dress)
    c.pattern(37, 34, ["SSSSSS", "GG....", "G....."], ["S": steelD, "G": grip])
    // The first, in her right hand, its muzzle at (47, 32).
    c.rect(38, 33, 3, 3, dress)
    c.pattern(40, 31, ["SSSSSSS", "DDDDD..", "GG.....", "GG....."], ["S": steel, "D": steelD, "G": grip])
}

// MARK: - Drusillah

/// Drusillah: Clawd with long dark hair falling loose to her waist, in a long white Victorian dress with a high lace
/// collar, a lace bodice and long sleeves. Her magic is her hypnotic stare: lilac rings rippling out along a faint
/// mauve thread. Signature: she holds up Miss Edith, her china doll, and sways, naming all the stars.
private func drawDrusillah(_ c: PixelCanvas, _ p: Pose) {
    let dress = C(0xE6DED2), dressD = C(0xB8AEA2), lace = C(0xFAF6EE), stare = C(0xC48ACC)
    let hair = C(0x2A1A22), hairL = C(0x46303A), hairD = C(0x180E14)
    let dollK = p.signature.map { $0 > 0.06 && $0 < 0.94 ? ($0 - 0.06) / 0.88 : -1 } ?? -1
    let face = slFighting(p)

    // Dark stockings and little black button boots: four dark legs under the pale gown, so they read at a glance.
    drawLegs(c, Look(leg: C(0x5A4458)), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx, 38, 1, 4, C(0x765E74)) } }
    slayerBoots(c, step: p.step, C(0x241A22), height: 2)
    // The long skirt, falling in soft folds to the shins, a plain band of lace along its hem.
    if seatedPose {
        c.rect(17, 38, 22, 1, dress); c.rect(38, 38, 1, 1, dressD)
    } else {
        c.rect(17, 38, 22, 2, dress); c.rect(16, 39, 1, 2, dress); c.rect(39, 39, 1, 2, dressD); c.rect(17, 40, 22, 1, lace)
        for x in [21, 26, 31, 35] { c.rect(x, 38, 1, 2, dressD); c.px(x, 40, dressD) }
        for x in [20, 25, 30] { c.rect(x, 38, 1, 2, lace) }
    }
    c.oy += p.breathe
    // Swaying from the waist up while she holds up the doll.
    let sway = dollK >= 0 ? Int((sin(dollK * 3 * .pi) * 2.4).rounded()) : 0
    c.ox += sway
    // Hair down her back, behind her.
    c.pattern(13, 26, ["HHHH", "HHHH", ".HHH", "HHdH", ".HHH", "HHHd", ".HHH", "..Hd"], ["H": hair, "d": hairD])
    drawBody(c, Look(arm: dress, eye: face ? nil : ink), armRight: dollK >= 0 ? 7 : p.armRaise)
    // The bodice: lace down the front, the high collar, a ribbon at the waist.
    c.rect(18, 33, 20, 5, dress); c.rect(37, 33, 1, 5, dressD); c.rect(18, 37, 20, 1, C(0x8A6E8E))
    c.rect(24, 33, 8, 1, lace); c.rect(25, 34, 6, 3, lace)
    for (x, y) in [(26, 34), (29, 35), (27, 36), (30, 34)] { c.px(x, y, dressD) }
    if face {
        slGameFace(c)
    } else {
        // Wide, faraway eyes, a mauve shadow under each.
        c.px(22, 31, stare); c.px(23, 31, stare); c.px(32, 31, stare); c.px(33, 31, stare)
    }
    // Long loose dark hair, a centre parting, down past her shoulders.
    c.pattern(16, 20, [
        "......HHHHHHHHHHH.......",
        "....HHHHHHHlHHHHHHH.....",
        "...HHHlHHHHHHHHHHlHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHH.........HHHHHHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHl................HHH.",
        ".HHH................lHH.",
        ".HHH................HHH.",
        ".HHd................dHH.",
        ".HHH................HHd.",
        ".dHd................dHH.",
        ".HHd................dHd.",
        ".dd..................dd.",
    ], ["H": hair, "l": hairL, "d": hairD])

    if dollK >= 0 {
        // Miss Edith held up in her raised hand: dark ringlets, a china face, a cream frock, a little blindfold.
        c.rect(38, 24, 3, 3, dress); c.rect(38, 27, 3, 2, dress)
        c.pattern(39, 15, [
            ".DDDD.",
            "DDDDDD",
            "DFFFFD",
            "DbbbbD",
            "DFFFFD",
            ".FFFF.",
            "ccPPcc",
            ".cccc.",
            "cccccc",
            "cccccc",
        ], ["D": C(0x3A2418), "F": C(0xF6E6DA), "b": C(0x2A2A30), "P": C(0xC86A8A), "c": C(0xEEE2C8)])
        c.rect(40, 24, 2, 2, clawdOrange)
        return
    }
    if p.zap != nil || p.ready {
        // A pointing hand at `pivot`, and two staring lilac rings tightening round it while she casts.
        let raise = p.armRaise
        c.rect(38, 31 - raise, 3, 3, dress); c.rect(41, 32 - raise, 3, 1, clawdOrange)
        if p.zap == true {
            let k = frac(p.t * 2)
            let r = 4 - k * 3
            for a in stride(from: 0.0, to: 2 * .pi, by: .pi / 4) {
                c.px(44 + Int((cos(a) * r).rounded()), 31 - raise + Int((sin(a) * r).rounded()), stare.alpha(0.2 + 0.5 * k))
            }
        }
    }
}

// MARK: - Mr. Tricks

/// Mr. Tricks: smooth and sharp. Clawd with a close-cropped black fade and a neat little goatee, in a slim charcoal
/// suit with a gold tie, a white shirt and a pocket square, and gold cufflinks. He fights with his fists, cuffs showing.
/// Signature: he straightens his tie, a tug and a slide, and it catches the light.
private func drawMrTricks(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x2C2C36), suitD = C(0x1A1A22), suitL = C(0x4A4A58), shirt = C(0xF0EEE8), tie = C(0xD8A830)
    let tieD = C(0x9A7418), hair = C(0x141216), square = C(0xC83A4A)
    let tieK = p.signature.map { $0 > 0.12 && $0 < 0.88 ? ($0 - 0.12) / 0.76 : -1 } ?? -1
    let face = slFighting(p)

    // Charcoal trousers a shade lighter than the jacket, lit down their left side: legs, not white stripes, once outlined.
    drawLegs(c, Look(leg: C(0x50505E)), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx, 36, 1, 6, C(0x6A6A7C)) } }
    slayerBoots(c, step: p.step, C(0x0E0E12), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit, eye: face ? nil : ink))
    // The jacket, slim and pinstriped, buttoned low, wide lapels round a deep V of white shirt.
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    for x in [19, 22, 34] { c.rect(x, 34, 1, 3, suitL) }
    c.pattern(24, 33, ["SSSSSSSS", ".SSSSSS.", "..SSSS..", "...SS..."], ["S": shirt])
    c.pattern(22, 33, ["LL........LL", ".LL......LL.", "..LL....LL..", "...LL..LL...", "....LLLL...."], ["L": suitL])
    c.px(24, 33, C(0xC8C4BC)); c.px(31, 33, C(0xC8C4BC))   // the collar points
    // A red silk square, its points up out of the breast pocket.
    c.pattern(19, 33, ["S.S", "SSS"], ["S": square]); c.rect(19, 35, 3, 1, suitD)
    // The tie, gold and broad: crooked first, straightened in the signature.
    let crooked = tieK >= 0 && tieK < 0.45
    c.rect(27, 33, 2, 1, tieD)
    c.rect(27, 34, 2, 1, tie); c.rect(crooked ? 28 : 27, 35, 2, 2, tie); c.px(crooked ? 29 : 28, 36, tieD)
    c.px(crooked ? 28 : 27, 37, tieD)
    if face { slGameFace(c, ridge: C(0x8A4228)) }
    // The goatee, neat, under the mouth.
    c.rect(27, 32, 2, 1, hair)
    // The fade: close-cropped, a sharp hairline.
    c.pattern(18, 22, [
        "..hHHHHHHHHHHHHHHh..",
        ".HHHHHHHhHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHH",
        "HHHH............HHHH",
        "HH................HH",
    ], ["H": hair, "h": C(0x2E2A30)])

    if tieK >= 0 {
        // His hand across his chest to the knot, a white cuff showing: a tug down, a slide back up, and a glint off the gold.
        let y = tieK < 0.45 ? 35 : 34
        slayerLine(c, 39, 34.5, 33, Double(y) + 1, suit, 1.3)
        c.rect(33, y, 4, 1, suitL)   // the light along the top of his sleeve, so the arm shows against the jacket
        c.rect(31, y, 2, 3, shirt); c.px(32, y + 1, C(0xD8A830))
        c.rect(28, y, 3, 3, clawdOrange); c.rect(28, y + 2, 3, 1, clawdShade)
        if tieK > 0.6 && tieK < 0.85 {
            let g = C(0xFFF8D0)
            c.px(27, 36, white); c.px(26, 36, g); c.px(27, 35, g); c.px(27, 37, g)
            c.px(25, 36, g.alpha(0.5)); c.px(26, 35, g.alpha(0.4)); c.px(26, 37, g.alpha(0.4))
        }
        return
    }
    if let a = p.melee {
        slFist(c, angle: a, trail: p.trail, sleeve: suit, cuff: shirt)
    } else {
        c.px(38, 36, tie)   // a gold cufflink
    }
}

// MARK: - Harmony Clawdall

/// Harmony Clawdall: Clawd with long platinum-blonde hair and a pink clip in it, a bubblegum-pink top with a little
/// heart on it, and white jeans. She shoots a crossbow with a pink stock, as in "The Real Me". Signature: the hair flip:
/// a hand to her head and her hair swings out behind her and settles ("Blondie Bear!").
private func drawHarmonyClawdall(_ c: PixelCanvas, _ p: Pose) {
    let top = C(0xF07AB0), topD = C(0xC8508A), topL = C(0xFAA8CE)
    let hair = C(0xF4E4A0), hairL = C(0xFFF6CC), hairD = C(0xD4BE70)
    let flipK = p.signature.map { $0 > 0.15 && $0 < 0.85 ? ($0 - 0.15) / 0.7 : -1 } ?? -1
    let face = slFighting(p)

    drawLegs(c, Look(leg: C(0xE4E0E8)), step: p.step)
    slayerBoots(c, step: p.step, C(0xE05A9A), height: 1)
    c.oy += p.breathe
    // The flick of hair behind her, swung out and up during the flip.
    let swing = flipK >= 0 ? sin(flipK * .pi) : 0
    if swing > 0 {
        for i in 0..<3 {
            let a = 100 + swing * 70 + Double(i) * 8
            let e = slayerReach((18, 24 + Double(i) * 2), a, 7 + swing * 2)
            slayerLine(c, 18, 24 + Double(i) * 2, e.x, e.y, i == 1 ? hairL : hair, 1.0)
        }
    }
    drawBody(c, Look(arm: top, eye: face ? nil : ink), armRight: flipK >= 0 ? 6 : 0)
    // The pink top, a little heart on it.
    c.rect(18, 34, 20, 4, top); c.rect(37, 34, 1, 4, topD); c.rect(18, 37, 20, 1, topD)
    c.rect(24, 34, 8, 1, topL)
    c.pattern(27, 35, ["W.W", ".W."], ["W": topL])
    c.rect(18, 34, 1, 3, topL)                                               // the top lit down the near side
    c.rect(21, 35, 1, 2, topD); c.rect(34, 35, 1, 2, topD)                   // folds
    if face { slGameFace(c) }
    // Long straight platinum hair, a pink clip at the side; the back curtain swings away in the flip.
    let back = swing > 0.3
    c.pattern(16, 20, [
        "......HHHHHHHHHHHH......",
        "....HHHlllHHHHHHHHH.....",
        "...HHlHHHHHHllHHHHHH....",
        "..HHlHHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHPPHH..",
        ".HHHHHHHHHHHHHHHHHPPHHH.",
        ".HHHHHH.........HHPPHHH.",
        ".HHHH...............HHH.",
        ".HHl................HHH.",
        ".HHl................lHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHd................dHH.",
        ".dHd................dHd.",
    ].enumerated().map { i, r in back && i >= 7 ? "...." + r.dropFirst(4) : r },
              ["H": hair, "l": hairL, "d": hairD, "P": C(0xE05A9A)])

    if flipK >= 0 {
        // Her hand up at her hair, and the crossbow tucked down by her side.
        c.rect(36, 26, 3, 3, top); c.rect(35, 25, 2, 2, clawdOrange)
        return
    }
    c.oy += p.gunY
    let firing = p.fire.map { frac($0.t / p.firePeriod) < 0.4 } ?? false
    slHarmonyCrossbow(c, cocked: !firing)
    c.rect(38, 33, 3, 3, top)
}

/// Harmony's crossbow, gripped at the hand: a pink stock, a dark bow across its nose, a bolt on top when `cocked`.
private func slHarmonyCrossbow(_ c: PixelCanvas, cocked: Bool) {
    let stock = C(0xE05A9A), stockD = C(0xA83A70), limb = C(0x2A2230), string = C(0xE8E4EC)
    c.rect(36, 33, 11, 2, stock); c.rect(36, 34, 11, 1, stockD); c.rect(38, 35, 2, 2, stockD)
    slayerLine(c, 45.5, 33.5, 43.5, 28.5, limb, 0.6); slayerLine(c, 45.5, 33.5, 43.5, 38.5, limb, 0.6)
    let back = cocked ? 41.0 : 43.5
    slayerLine(c, 43.5, 28.5, back, 33.5, string, 0.35); slayerLine(c, 43.5, 38.5, back, 33.5, string, 0.35)
    if cocked {
        c.rect(41, 32, 6, 1, slayerStakeWood); c.px(47, 32, slayerStakePoint)
        c.px(41, 31, C(0xF07AB0))
    }
}
