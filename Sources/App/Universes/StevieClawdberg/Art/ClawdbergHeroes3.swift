import Foundation

// Heroes: Gremlins. The people of Kingston Falls (and the Clamp Centre) as Clawd in costume: hair, hats, sweaters,
// aprons and robes over the blocky body, Clawd's own orange face showing; and Gizmoe, Clawd in a small brown-and-white
// mogwai suit, big ears and all.

let clawdbergHeroes3: [ClawdbergHero: Persona] = [
    .billyPeltclawd: Persona(name: "Billy Peltclawd", weapon: .saber, headTop: 20, signature: 3.4,
                             callout: "Don’t get him wet!", draw: drawBillyPeltclawd),
    .kateBeringer: Persona(name: "Kate Beringer", weapon: .blaster,
                           shot: .energy(core: C(0xFFFFFF), glow: C(0xFFF2A0)), muzzle: (46, 30), headTop: 21,
                           signature: 2.8, draw: drawKateBeringer),
    .gizmoe: Persona(name: "Gizmoe", weapon: .blaster, shot: .arrow, muzzle: (48, 34), headTop: 24, signature: 3.2,
                     callout: "Bright light!", draw: drawGizmoe),
    .randPeltclawd: Persona(name: "Rand Peltclawd", weapon: .blaster,
                            shot: .beam(core: C(0xFFD27A), glow: C(0xFF8A1A)), muzzle: (49, 32), headTop: 19,
                            signature: 3.2, draw: drawRandPeltclawd),
    .lynnPeltclawd: Persona(name: "Lynn Peltclawd", weapon: .saber, headTop: 21, draw: drawLynnPeltclawd),
    .mrWing: Persona(name: "Mr. Wing", headTop: 22, signature: 3.4, callout: "Never after midnight",
                     draw: drawMrWing),
    .futterclaw: Persona(name: "Murray Futterclaw", weapon: .blaster,
                         shot: .beam(core: C(0xEAF6FF), glow: C(0x5AA8F0)), muzzle: (49, 32), headTop: 21,
                         signature: 3.0, callout: "Gremlins!", draw: drawFutterclaw),
    .grandpaDread: Persona(name: "Grandpa Dread", headTop: 18, signature: 2.6, draw: drawGrandpaDread),
]

// MARK: - Billy Peltclawd

/// Billy Peltclawd: Clawd with a mop of brown hair over his forehead, a green knit sweater over a white tee, jeans
/// and white sneakers, his sketch pad tucked under his arm. He fights with the ornamental sword off the kitchen wall,
/// a curved blade with a gold guard. Signature: he holds the pad up and
/// sketches Gizmoe on it, the little mogwai appearing line by line.
private func drawBillyPeltclawd(_ c: PixelCanvas, _ p: Pose) {
    let sweater = C(0x3E7A3A), sweaterD = C(0x2A5A28), sweaterL = C(0x5A9A4E), jeans = C(0x3A5A8A)
    let hair = C(0x6A4226), hairL = C(0x8A5A34), tee = C(0xEAE6DC), pad = C(0xF4F0E4), pencil = C(0x5A5A62)
    let gold = C(0xE0B040), steel = C(0xD4DAE2), grip = C(0x7A2A22)
    let sig = p.signature
    let sketching = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: jeans), step: p.step)
    cbBoots(c, step: p.step, C(0xE8E4DA), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: sweater))
    // The green sweater, knit ribs, the white tee at the collar.
    c.rect(18, 33, 20, 5, sweater); c.rect(37, 33, 1, 5, sweaterD); c.rect(18, 37, 20, 1, sweaterD)
    for x in stride(from: 19, to: 37, by: 3) { c.px(x, 35, sweaterL) }
    c.rect(25, 33, 6, 1, tee)
    // The mop of brown hair, a ragged fringe over his forehead.
    c.pattern(17, 21, [
        "....HHHHHHHHHHHHH.....",
        "..HHHHHHhHHHHHHHHHH...",
        ".HHHHHHHHHHHHHHhHHHHH.",
        "HHHHHhHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHH.HHH.HHHH.HHHHH.HHH",
        "HH...H......H......HH.",
    ], ["H": hair, "h": hairL])

    if sketching {
        // The pad held up in front, the pencil working, Gizmoe appearing on the page.
        let k = sig!
        c.rect(38, 31, 3, 3, sweater)
        c.rect(40, 25, 9, 11, pad); c.rect(40, 25, 9, 1, C(0x9A9AA4))
        for x in stride(from: 41, to: 48, by: 2) { c.px(x, 24, pencil) }
        let sketch = [
            ".........",
            "P.......P",
            "PP.PPP.PP",
            ".PP...PP.",
            "..P.P.P..",
            "..P...P..",
            "...PPP...",
            "..P...P..",
            "..PPPPP..",
        ]
        let shown = Int((min(1, (k - 0.06) / 0.7) * Double(sketch.count)).rounded())
        c.pattern(40, 26, Array(sketch.prefix(shown)), ["P": C(0x4A4A52)])
        // His pencil hand, scribbling.
        let wob = Int((sin(p.t * 22) * 1.2).rounded())
        let px = 43 + wob + (shown % 3), py = 26 + min(shown, 8)
        c.rect(px - 1, py + 1, 2, 2, clawdOrange)
        c.px(px, py, pencil); c.px(px + 1, py - 1, C(0xE8C850))
        return
    }
    if let a = p.melee {
        // The ornamental sword: a dark red grip, a gold guard, a long slightly curved steel blade.
        cbSmear(c, cbHand, p.trail, from: 4, to: 17, C(0xEAF0F8))
        cbBar(c, cbHand, a, from: -2, to: 2, grip, r: 0.8)
        let g0 = cbReach(cbHand, a - 90, 2), g1 = cbReach(cbHand, a + 90, 2)
        let gc = cbReach(cbHand, a, 2.5)
        cbLine(c, g0.x + gc.x - cbHand.x, g0.y + gc.y - cbHand.y, g1.x + gc.x - cbHand.x, g1.y + gc.y - cbHand.y, gold, 0.6)
        cbBar(c, cbHand, a, from: 3, to: 12, steel, r: 0.7)
        cbBar(c, cbHand, a + 4, from: 12, to: 17, steel, r: 0.6)
        c.rect(40, 33, 3, 3, clawdOrange)
        return
    }
    // The sketch pad under his left arm.
    c.rect(12, 30, 5, 7, pad); c.rect(12, 30, 5, 1, C(0x9A9AA4)); c.rect(15, 32, 3, 3, sweater)
}

// MARK: - Kate Beringer

/// Kate Beringer: Clawd with a dark glossy bob and a straight fringe, a burgundy blouse, the white bar apron from
/// Dorry's tied round her waist, dark tights; the camera on its strap round her neck. In a fight she holds the camera
/// up and pops its flash at them (white bursts, a pale yellow glow). Signature: the flash goes off in her own face
/// and she throws an arm up over her eyes.
private func drawKateBeringer(_ c: PixelCanvas, _ p: Pose) {
    let blouse = C(0x8A2A3A), blouseD = C(0x6A1E2A), apron = C(0xF2EEE4), apronD = C(0xCFC8B8)
    let hair = C(0x241A18), hairL = C(0x4A3430), cam = C(0x2A2A30), camL = C(0x6A6A74), tights = C(0x6A5A62)
    let sig = p.signature

    drawLegs(c, Look(leg: tights), step: p.step)
    cbBoots(c, step: p.step, C(0x141416), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: blouse))
    c.rect(18, 33, 20, 5, blouse); c.rect(37, 33, 1, 5, blouseD)
    // The bar apron, down over the tops of her legs, its ties at the back.
    c.rect(21, 35, 14, 4, apron); c.rect(21, 38, 14, 1, apronD); c.rect(18, 35, 20, 1, apronD)
    c.px(17, 35, apronD); c.px(16, 36, apronD)
    // The bob: a straight fringe, straight sides down to her jaw.
    c.pattern(16, 21, [
        ".....HHHHHHHHHHHH.....",
        "...HHHHHHHHhHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHhHHHHHHHHHHHhHHH.",
        ".HHHHHHHHHHHHHHHHHHHHH",
        ".HHHHHHHHHHHHHHHHHHHHH",
        ".HHH...............HHH",
        ".HHH...............HHH",
        ".HHH...............HHH",
        ".HHH...............HH.",
        "..HH...............HH.",
    ], ["H": hair, "h": hairL])

    let up = p.fire != nil || p.ready || p.gunLift > 0
    if let k = sig, k > 0.08 && k < 0.92 {
        // The camera held up; the flash pops, and her arm comes up over her eyes.
        c.rect(38, 31, 3, 3, blouse)
        c.rect(40, 29, 6, 4, cam); c.rect(42, 30, 2, 2, camL); c.rect(44, 27, 2, 2, C(0xDADADF))
        if k < 0.35 {
            let f = (0.35 - k) / 0.27
            c.glowLine(45, 28, 45, 28, core: white, glow: C(0xFFF2A0), coreR: 1.5 + f * 2, glowR: 4 + f * 6)
        }
        if k > 0.2 {
            c.rect(14, 28, 13, 3, blouse); c.rect(24, 28, 3, 3, clawdOrange)   // the forearm across her eyes
            c.px(14, 31, blouseD)
        }
        return
    }
    if up {
        // The camera raised to her eye, the flash unit on top.
        let y = 29 + p.gunY
        c.rect(38, y + 2, 3, 3, blouse)
        c.rect(38, y, 7, 4, cam); c.rect(40, y + 1, 2, 2, camL); c.px(44, y + 1, C(0x8AA0C8))
        c.rect(43, y - 2, 3, 2, C(0xDADADF)); c.px(45, y - 2, white)
        return
    }
    // The camera hanging on its strap at her chest.
    c.px(24, 33, cam); c.px(25, 34, cam); c.px(32, 33, cam); c.px(31, 34, cam)
    c.rect(25, 34, 7, 4, cam); c.rect(27, 35, 3, 2, camL); c.rect(30, 34, 2, 1, C(0xDADADF))
}

// MARK: - Gizmoe

/// Gizmoe: Clawd in a small mogwai suit, shorter than the rest: a brown back and crown, a white face and tummy, big
/// dark eyes with a glint, a pink nose, and huge leaf-shaped ears with pink insides out to either side; the red
/// headband from his Rambo days tied round his head, its tails flying. He fights with a little bow and a flaming
/// arrow. Signature: he hums his little song, eyes closed, ears swaying, notes floating up.
private func drawGizmoe(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0x8A5A32), furD = C(0x6A4224), cream = C(0xF4ECDA), creamD = C(0xD8CCB4), pink = C(0xE8A0A0)
    let band = C(0xD02A2A), bow = C(0x8A5A2E), string = C(0xE8E4DA)
    let sig = p.signature
    let humming = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false

    drawLegs(c, Look(leg: fur), step: p.step)
    // Little cream toes.
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, lifted ? 42 : 43, 2, 1, cream)
        }
    }
    c.oy += p.breathe
    let shooting = p.fire != nil || p.ready || p.gunLift > 0
    // The body, a few rows shorter than Clawd's: brown back and crown, white face and tummy.
    c.rect(18, 29, 20, 9, cream)
    c.rect(18, 29, 20, 2, fur); c.rect(18, 29, 3, 9, fur); c.rect(25, 31, 6, 1, fur)
    c.rect(36, 31, 2, 4, fur); c.rect(18, 37, 20, 1, creamD); c.rect(37, 29, 1, 9, furD)
    c.rect(21, 35, 2, 2, furD)
    // The ears: big leaves out to either side, swaying while he hums.
    let sway = humming ? (sin(p.t * 5) > 0 ? 1 : -1) : 0
    let earL = [
        "EEE.......",
        ".EEEEE....",
        "..EppEEEEE",
        "..EEpppEEE",
        "...EEEEEEE",
        ".....EEEE.",
    ], earR = earL.map { String($0.reversed()) }
    c.pattern(8, 28 + sway, earL, ["E": fur, "p": pink])
    c.pattern(38, 28 - sway, earR, ["E": fur, "p": pink])
    // Eyes, nose and mouth.
    if humming {
        c.rect(22, 32, 3, 1, ink); c.rect(31, 32, 3, 1, ink)
        c.rect(27, 35, 2, 1, C(0x8A3A3A))
    } else {
        c.rect(22, 31, 3, 3, ink); c.rect(31, 31, 3, 3, ink)
        c.px(22, 31, white); c.px(31, 31, white)
        c.pattern(26, 35, ["M..M", ".MM."], ["M": C(0x8A3A3A)])
    }
    c.rect(27, 34, 2, 1, pink)
    // The red headband round his crown, its tails flying out behind.
    c.rect(18, 29, 20, 1, band)
    let flap = Int(p.t * 6) % 2
    c.pattern(13, 29, ["BBBBB", flap == 0 ? "BB..." : ".BB..", flap == 0 ? "...B." : "B...."], ["B": band])
    c.rect(15, 33, 3, 3, cream)

    if humming {
        // The notes of his little song drifting up.
        let k = sig!
        for i in 0..<3 {
            let f = frac(k * 2 + Double(i) / 3)
            let x = 34 + Int(f * 8) + Int(sin(f * 9) * 1.5), y = 28 - Int(f * 12)
            let col = C(0xF4ECDA).alpha(1 - f * 0.6)
            c.rect(x, y, 1, 3, col); c.px(x - 1, y + 2, col); c.px(x + 1, y, col)
        }
        c.rect(38, 33, 3, 3, cream)
        return
    }
    if shooting {
        // The bow held out upright, a flaming arrow drawn back on the string.
        let y = p.gunY
        c.pattern(42, 26 + y, [".B", "B.", "B.", "B.", "B.", "B.", "B.", "B.", "B.", "B.", "B.", "B.", ".B"],
                  ["B": bow])
        c.rect(44, 26 + y, 1, 13, string.alpha(0.8))
        c.rect(36, 34 + y, 12, 1, C(0x6A4A2A)); c.px(48, 34 + y, C(0xC8CCD4))
        let flick = Int(p.t * 14) % 2
        c.px(48, 33 + y, C(0xFFB02A)); c.px(49, 33 + y - flick, C(0xFF6A1A)); c.px(48, 32 + y, C(0xFFE27A))
        c.rect(38, 33 + y, 3, 3, cream)
        return
    }
    c.rect(38, 33, 3, 3, cream)
}

// MARK: - Rand Peltclawd

/// Rand Peltclawd: Clawd under a tan cowboy hat with its brim curled up, a bushy brown moustache, a brown corduroy
/// jacket over a pale blue shirt and a string tie; his briefcase of inventions in his other hand. In a fight he aims
/// his Peltclawd juicer, which sprays orange juice. Signature: one of his inventions goes off and sprays juice
/// everywhere, and he wipes his face.
private func drawRandPeltclawd(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x7A5232), jacketD = C(0x5A3A22), shirt = C(0xB4CCE4), hat = C(0xC8A06A), hatD = C(0x9A784A)
    let tache = C(0x5A3A22), trousers = C(0x5A4A3A), case_ = C(0x5A3420), chrome = C(0xC4CAD4), juice = C(0xFFA42A)
    let sig = p.signature

    drawLegs(c, Look(leg: trousers), step: p.step)
    cbBoots(c, step: p.step, C(0x3A2416), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: jacket))
    c.rect(18, 34, 20, 4, jacket); c.rect(37, 34, 1, 4, jacketD); c.rect(18, 37, 20, 1, jacketD)
    c.rect(25, 34, 6, 4, shirt); c.rect(27, 34, 1, 3, ink); c.rect(29, 34, 1, 3, ink); c.px(28, 34, C(0xC8A040))
    // The moustache.
    c.pattern(23, 32, [".TTTTTTTTT.", "TTT.....TTT"], ["T": tache])
    // The cowboy hat, its brim curled up at the ends.
    c.pattern(16, 19, [
        "........HHHHHHHH........",
        ".......HHHHdHHHHH.......",
        ".......HHHHHHHHHH.......",
        ".......BBBBBBBBBB.......",
        "HH....HHHHHHHHHHHH....HH",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        "..dddddddddddddddddddd..",
    ], ["H": hat, "d": hatD, "B": C(0x4A2E1A)])

    if let k = sig, k > 0.06 && k < 0.94 {
        // The gadget spraying juice in every direction, then a wipe of his face.
        c.rect(38, 32, 3, 3, jacket)
        c.rect(40, 30, 5, 5, chrome); c.rect(41, 28, 3, 2, juice); c.px(45, 31, ink)
        if k < 0.6 {
            for i in 0..<10 {
                let a = Double(i) / 10 * 2 * .pi + p.t * 3
                let r = 3 + frac(p.t * 2 + Double(i) * 0.37) * 9
                let x = 42.5 + cos(a) * r, y = 31.5 + sin(a) * r * 0.7
                c.rect(Int(x), Int(y), r < 7 ? 2 : 1, 1, juice.alpha(1.1 - r / 16))
            }
        }
        // Juice on his face.
        for (x, y) in [(21, 28), (26, 30), (33, 27), (30, 31), (24, 33)] { c.px(x, y, juice) }
        if k > 0.55 {
            let sweep = Int(((k - 0.55) / 0.39 * 12).rounded())
            c.rect(14 + sweep, 29, 6, 3, jacket); c.rect(19 + sweep, 29, 2, 3, clawdOrange)
        } else {
            c.rect(15, 33, 3, 3, jacket)
        }
        return
    }
    if p.fire != nil || p.ready || p.gunLift > 0 {
        // The juicer aimed: a chrome body, an orange reservoir, a nozzle.
        let y = 30 + p.gunY
        c.rect(38, y + 2, 3, 3, jacket)
        c.rect(40, y, 7, 4, chrome); c.rect(40, y + 3, 7, 1, C(0x8A909A))
        c.rect(41, y - 2, 4, 2, juice); c.px(42, y - 2, C(0xFFD27A))
        c.rect(47, y + 1, 2, 2, C(0x6A707A))
        c.rect(12, 34, 5, 4, case_); c.rect(13, 33, 3, 1, C(0x2A1A10))
        return
    }
    // The briefcase in his left hand, the juicer hanging at rest in his right.
    c.rect(11, 35, 7, 5, case_); c.rect(11, 35, 7, 1, C(0x7A4A2E)); c.rect(13, 34, 3, 1, C(0x2A1A10))
    c.px(14, 37, C(0xC8A040))
    c.rect(39, 35, 4, 4, chrome); c.rect(40, 34, 2, 1, juice)
}

// MARK: - Lynn Peltclawd

/// Lynn Peltclawd: Clawd as the mum of the house, short permed brown curls, a powder-blue blouse and a white apron
/// with a frilled hem tied over it. She defends her kitchen with a kitchen knife.
private func drawLynnPeltclawd(_ c: PixelCanvas, _ p: Pose) {
    let blouse = C(0x8AB0D4), blouseD = C(0x6A8EB2), apron = C(0xF6F2EA), apronD = C(0xD4CCBC), skirt = C(0x6A7A9A)
    let hair = C(0x7A4A2A), hairL = C(0x9A6238), blade = C(0xDCE2EA), handle = C(0x2A2420)

    drawLegs(c, Look(leg: skirt), step: p.step)
    cbBoots(c, step: p.step, C(0x6A3A2A), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: blouse))
    c.rect(18, 33, 20, 5, blouse); c.rect(37, 33, 1, 5, blouseD)
    // The apron: a bib up the front, ties at the waist, a frilled hem over the tops of her legs.
    c.rect(22, 33, 12, 6, apron); c.rect(23, 33, 10, 1, apronD)
    c.rect(18, 35, 4, 1, apron); c.rect(34, 35, 3, 1, apron)
    for x in stride(from: 22, to: 34, by: 2) { c.px(x, 39, apronD) }
    // Short permed curls.
    c.pattern(16, 21, [
        "....hHHhHHhHHhHHhH....",
        "..HHhHHHHHHHHHHHhHHH..",
        ".HHHHHHhHHHHhHHHHHHHH.",
        "HHhHHHHHHHHHHHHHHHhHHH",
        "HHHHHH.HHHHHH.HHHHHHHH",
        ".HHH..H..H...H..H.HHH.",
        "..HH..............HH..",
        "..H................H..",
    ], ["H": hair, "h": hairL])

    if let a = p.melee {
        // The kitchen knife: a black handle, a broad pointed blade.
        cbSmear(c, cbHand, p.trail, from: 3, to: 11, C(0xEAF0F8))
        cbBar(c, cbHand, a, from: -2, to: 2.5, handle, r: 0.8)
        cbBar(c, cbHand, a, from: 3, to: 9, blade, r: 1.0)
        cbBar(c, cbHand, a, from: 9, to: 11, blade, r: 0.5)
        c.rect(40, 33, 3, 3, clawdOrange)
        return
    }
    // At rest: the knife held point down at her side.
    c.rect(41, 36, 1, 2, handle); c.rect(41, 38, 1, 4, blade); c.px(41, 42, blade.alpha(0.6))
    c.rect(40, 34, 3, 2, clawdOrange)
}

// MARK: - Mr. Wing

/// Mr. Wing: Clawd as the old Chinatown shopkeeper, a round black cap, white eyebrows, a long wispy white beard and a
/// drooping moustache, a deep red robe down over the tops of his legs, his hands folded in its wide sleeves. He
/// doesn't fight. Signature: the covered box beside him; he lifts the cloth off it, and a mogwai's ears and eyes
/// peep out over the edge.
private func drawMrWing(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0x7A1E22), robeD = C(0x5A1418), trim = C(0xC8A040), cap = C(0x16161B), beard = C(0xEDEAE2)
    let wood = C(0x8A5A2E), woodD = C(0x5A3A1E), cloth = C(0xC8B48A), clothD = C(0x9A8A68)

    drawLegs(c, Look(leg: C(0x2A2A30)), step: p.step)
    cbBoots(c, step: p.step, C(0x16161B), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: robe))
    // The robe, down over the tops of his legs, a gold trim down its front.
    c.rect(18, 33, 20, 7, robe); c.rect(37, 33, 1, 7, robeD); c.rect(18, 39, 20, 1, robeD)
    c.rect(26, 33, 1, 6, trim); c.rect(18, 33, 20, 1, robeD)
    // White brows, drooping moustache, the long wispy beard.
    c.rect(21, 28, 4, 1, beard); c.rect(31, 28, 4, 1, beard)
    c.pattern(22, 32, [
        "..BBBBBBBBB..",
        ".B..BBBBB..B.",
        "B...BBBBB...B",
        "B....BBB....B",
        ".....BBB.....",
        ".....BBB.....",
        "......BB.....",
        "......BB.....",
        ".......B.....",
    ], ["B": beard])
    // The round cap.
    c.pattern(19, 21, ["......KK......", "...KKKKKKKK...", ".KKKKKKKKKKKK.", "KKKKKKKKKKKKKK", "KKrKKKKKKKKrKK"],
              ["K": cap, "r": C(0x3A2A2A)])
    c.rect(18, 25, 20, 1, cap)
    // Hands folded in his sleeves.
    c.rect(15, 33, 3, 3, robe)

    // The box beside him, its cloth on, or lifted away.
    let k = p.signature ?? 0
    let lift = k <= 0.08 ? 0 : k < 0.35 ? (k - 0.08) / 0.27 : k < 0.8 ? 1 : max(0, (0.95 - k) / 0.15)
    guard p.signature != nil else { c.rect(38, 33, 3, 3, robe); return }
    c.rect(44, 34, 12, 10, wood); c.rect(44, 34, 12, 1, woodD); c.rect(44, 43, 12, 1, woodD)
    for x in stride(from: 46, to: 56, by: 3) { c.rect(x, 35, 1, 8, woodD) }
    if lift > 0.6 {
        // The mogwai peeping out over the edge.
        let fur = C(0x8A5A32)
        c.pattern(42, 29, ["EEE..........EEE", ".EEEEFFFFFFEEEE.", "...FFFFFFFFFF...", "...WWkkWWkkWW...",
                           "...WWkkWWkkWW...", "...WWWWppWWWW..."],
                  ["E": fur, "F": fur, "W": C(0xF4ECDA), "k": ink, "p": C(0xE8A0A0)])
    }
    let up = Int((lift * 9).rounded())
    c.pattern(42, 31 - up, ["..CCCCCCCCCCC..", ".CCCCCCCCCCCCC.", "CCcCCCCcCCCCcCC", "C.............C",
                            "c.............c"], ["C": cloth, "c": clothD])
    c.rect(38, 32 - up / 2, 3, 3, robe); c.rect(41, 31 - up, 2, 2, clawdOrange)
}

// MARK: - Murray Futterclaw

/// Murray Futterclaw: Clawd as the grumpy old WWII vet next door, an olive peaked cap, bushy grey brows, stubble, and
/// a red-and-black buffalo-plaid jacket. In a fight he turns a fire hose on them, a brass nozzle and a canvas hose,
/// a hard spray of water. Signature: a little foreign car putters past and he shakes his fist at it.
private func drawFutterclaw(_ c: PixelCanvas, _ p: Pose) {
    let red = C(0xB02A26), black = C(0x1E1A1A), capC = C(0x5A6040), capD = C(0x3E4430), grey = C(0xB4B0A8)
    let trousers = C(0x5A5448), brass = C(0xD4A440), hose = C(0xC8B890)
    let sig = p.signature

    drawLegs(c, Look(leg: trousers), step: p.step)
    cbBoots(c, step: p.step, C(0x2A1E16), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: red))
    // The buffalo plaid: red, with black checks.
    c.rect(18, 33, 20, 5, red)
    for y in [33, 35, 37] { for x in stride(from: 18 + (y % 4 == 1 ? 0 : 2), to: 38, by: 4) { c.rect(x, y, 2, 1, black) } }
    c.rect(28, 33, 1, 5, black)
    c.rect(15, 34, 3, 1, black); c.rect(38, 34, 3, 1, black)
    // Bushy grey brows and stubble.
    c.rect(21, 28, 4, 1, grey); c.rect(31, 28, 4, 1, grey)
    for (x, y) in [(22, 33), (25, 32), (29, 33), (33, 32), (26, 34), (31, 34)] { c.px(x, y, C(0x9A6A52)) }
    // The cap, its peak forward.
    c.pattern(18, 21, ["...CCCCCCCCCCCC.....", "..CCCCCCCCCCCCCC....", ".CCCCCCCCCCCCCCCC...",
                       "CCCCCCCCCCCCCCCCCCPPPP", "dddddddddddddddddddddd"], ["C": capC, "d": capD, "P": capD])

    if let k = sig, k > 0.05 && k < 0.95 {
        // The little car going past, and his fist shaking at it.
        let x = 70 - Int(((k - 0.05) / 0.9 * 34).rounded())
        c.oy -= p.breathe
        c.pattern(x, 36, ["...RRRRR....", "..RgggRRR...", "RRRRRRRRRRRR", "RRRRRRRRRRRw", ".KK.....KK.."],
                  ["R": C(0xE8C83A), "g": C(0x8ACCE8), "w": C(0xFFF6C8), "K": ink])
        c.oy += p.breathe
        let shake = Int(p.t * 14) % 2
        c.rect(38, 28 - shake, 3, 6, red); c.rect(38, 26 - shake, 3, 3, clawdOrange)
        c.rect(21, 28, 4, 1, grey); c.px(24, 29, grey); c.px(31, 29, grey)   // brows knitted
        c.rect(25, 34, 6, 1, ink)
        return
    }
    if p.fire != nil || p.ready || p.gunLift > 0 {
        // The fire hose: the canvas hose trailing back down to the ground, the brass nozzle out front.
        let y = 32 + p.gunY
        cbLine(c, 12, 42, 18, 39, hose, 1.0); cbLine(c, 18, 39, 39, Double(y) + 1.5, hose, 1.0)
        c.rect(38, y, 3, 3, red)
        c.rect(41, y, 6, 3, brass); c.rect(47, y + 1, 2, 1, C(0x9A7A2A)); c.px(43, y, C(0xF4D47A))
        return
    }
    c.rect(38, 33, 3, 3, red); c.rect(38, 35, 3, 1, clawdOrange)
}

// MARK: - Grandpa Dread

/// Grandpa Dread: Clawd as the late-night vampire horror host, black hair slicked down to a sharp widow's peak, dark
/// shadows round his eyes and two little fangs, a black suit and a white shirt with a red medallion, and a black cape
/// with a tall red-lined collar standing up behind his head. He doesn't fight. Signature: he swirls the cape up and
/// round in front of him, Dracula style, and back.
private func drawGrandpaDread(_ c: PixelCanvas, _ p: Pose) {
    let cape = C(0x141418), capeL = C(0x2E2E36), lining = C(0xA01A26), suit = C(0x1E1E24), shirt = C(0xF0EEE8)
    let hair = C(0x0E0E12), sig = p.signature

    drawLegs(c, Look(leg: suit), step: p.step)
    cbBoots(c, step: p.step, C(0x0A0A0C), height: 1)
    c.oy += p.breathe
    // The cape behind him, its collar standing up behind his head.
    c.rect(15, 27, 3, 13, cape); c.rect(38, 27, 2, 12, cape)
    let collar = ["CCCC..", "CLLLC.", "CLLLC.", ".CLLLC", ".CLLLC", "..CLLC", "..CLLC", "...CCC"]
    c.pattern(12, 21, collar, ["L": lining, "C": cape])
    c.pattern(38, 21, collar.map { String($0.reversed()) }, ["L": lining, "C": cape])
    drawBody(c, Look(arm: suit))
    // Suit, shirt front and medallion.
    c.rect(18, 33, 20, 5, suit); c.rect(25, 33, 6, 4, shirt); c.rect(27, 35, 2, 2, lining); c.px(27, 35, C(0xE8C850))
    // Shadowed eyes, fangs.
    c.rect(21, 28, 4, 1, C(0x5A3040)); c.rect(31, 28, 4, 1, C(0x5A3040))
    c.px(25, 32, white); c.px(30, 32, white); c.rect(25, 31, 6, 1, C(0x5A1A1A))
    // The slicked hair and its widow's peak.
    c.pattern(18, 22, ["...HHHHHHHHHHHHHH...", ".HHHHHHHHHHHHHHHHHH.", "HHHhHHHHHHHHHHHhHHHH",
                       "HHHHHHHHHHHHHHHHHHHH", "HHHHHHHHH..HHHHHHHHH", "HH......HHH.......HH",
                       "H........H.........H"], ["H": hair, "h": C(0x3A3A44)])

    if let k = sig, k > 0.05 && k < 0.95 {
        // The cape swept up and across in front of him, then flung open again.
        let open = k < 0.5 ? (k - 0.05) / 0.45 : (0.95 - k) / 0.45
        let w = Int((open * 16).rounded())
        c.rect(38, 28, 3, 3, suit)
        c.pattern(40, 27, ["CCCC", "CCCC", "CCC."], ["C": cape])
        c.rect(40 - w, 30, w, 9, cape); c.rect(40 - w, 30, w, 1, capeL)
        c.rect(40 - w, 38, w, 1, lining)
        if w > 12 { c.rect(20, 29, 2, 1, cape) }
        return
    }
    c.rect(38, 33, 3, 3, suit); c.rect(15, 33, 3, 3, suit)
}
