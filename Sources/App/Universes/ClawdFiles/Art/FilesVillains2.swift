import Foundation

// Villains: the Syndicate. Clawdcek, the Well-Manicured Clawd, the First Elder, Diana Fowlclawd, Kersh and the Toothpick
// Man. Clawd in costume like the rest: each of them a different cut of the conspiracy, from a leather jacket to a
// three-piece suit, so they read apart at a glance.

let filesVillains2: [FilesVillain: Persona] = [
    .clawcek: Persona(name: "Alex Clawdcek", weapon: .saber, headTop: 21, signature: 3.0,
                      callout: "We want the same thing.", draw: drawClawcek),
    .wellManicured: Persona(name: "The Well-Manicured Clawd", weapon: .blaster, shot: .bullet, muzzle: (46, 31),
                            handGun: false, headTop: 20, signature: 3.4,
                            callout: "Quite.", draw: drawWellManicured),
    .firstElder: Persona(name: "The First Elder", weapon: .saber, headTop: 26, signature: 3.0,
                         callout: "We've come too far.", draw: drawFirstElder),
    .dianaFowlclaw: Persona(name: "Diana Fowlclawd", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                            headTop: 19, signature: 3.2, callout: "I've always been on your side.",
                            draw: drawDianaFowlclaw),
    .kersh: Persona(name: "Deputy Director Kersh", weapon: .saber, headTop: 21, signature: 2.6,
                    callout: "My office. Now.", draw: drawKersh),
    .toothpickMan: Persona(name: "The Toothpick Man", weapon: .saber, armoured: true, headTop: 21, signature: 3.0,
                           callout: "Nothing personal.", draw: drawToothpickMan),
]

// MARK: - Shared bits

/// A solid straight stroke from (x0, y0) to (x1, y1), `r` pixels from its centre line.
private func bar(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.7) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: C(0x000000, 0), coreR: r, glowR: r + 0.1)
}

/// The point `len` pixels from `from` along `angle` degrees (0 forward, -90 straight up).
private func along(_ angle: Double, _ len: Double, from h: (x: Double, y: Double) = Sprite.hand) -> (x: Double, y: Double) {
    let r = angle * .pi / 180
    return (h.x + cos(r) * len, h.y + sin(r) * len)
}

/// A punch: the sleeve out from the shoulder to the fist at `angle`, earlier fists fading behind a fast one.
private func drawPunch(_ c: PixelCanvas, angle: Double, trail: [Double], sleeve: Px, fist: Px = clawdOrange) {
    for (i, a) in trail.enumerated() {
        let e = along(a, 7)
        c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 3, 3, fist.alpha(0.35 / Double(i + 1)))
    }
    let e = along(angle, 7)
    bar(c, Sprite.hand.x - 2, Sprite.hand.y - 0.5, e.x, e.y, sleeve, 1.2)
    c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 3, 3, fist)
}

/// Clawd's two eyes, drawn by hand (for those whose eyes change).
private func drawEyes(_ c: PixelCanvas, _ col: Px = ink) {
    c.rect(22, 29, 2, 3, col); c.rect(32, 29, 2, 3, col)
}

// MARK: - Alex Clawdcek

/// Alex Clawdcek: Clawd with dark hair cropped short, a black leather jacket zipped half up over a grey T-shirt, dark
/// jeans and boots. A brawler: he fights with his fists, a pistol tucked away. Now and then the black oil surfaces:
/// his eyes go glossy black with a blue sheen rippling across them. Signature: the oil takes him fully, swimming over
/// his eyes and down his cheeks, then sinks back.
private func drawClawcek(_ c: PixelCanvas, _ p: Pose) {
    let leather = C(0x1C1C20), leatherL = C(0x3C3C44), leatherD = C(0x101014), tee = C(0x5A5E66)
    let jeans = C(0x2A3A56), hair = C(0x1E1814), hairL = C(0x3E342C), hairD = C(0x120E0B)
    let sig = p.signature
    // The oil: a second now and then on its own, the whole of the signature.
    let habit = frac(p.lt / 11) < 0.09
    let oil = sig.map { $0 > 0.08 && $0 < 0.92 } ?? habit

    drawLegs(c, Look(leg: jeans), step: p.step)
    filesDrawDressShoes(c, step: p.step, color: C(0x2A1E16))
    c.oy += p.breathe
    drawBody(c, Look(arm: leather, eye: nil))
    // The T-shirt and the jacket over it, zipped halfway, a shine on the leather.
    c.rect(18, 33, 20, 5, leather); c.rect(37, 33, 1, 5, leatherD)
    c.rect(25, 33, 6, 3, tee); c.rect(27, 36, 2, 2, C(0x8A8E96))   // the zip
    c.rect(20, 34, 1, 3, leatherL); c.rect(34, 34, 1, 2, leatherL)
    c.pattern(23, 32, ["L..........L"], ["L": leather])           // the collar, turned up
    c.rect(18, 37, 20, 1, leatherD)
    c.rect(18, 33, 2, 1, leatherL); c.rect(35, 33, 2, 1, leatherL)   // lit shoulders
    c.rect(22, 35, 1, 2, leatherD); c.rect(33, 35, 1, 2, leatherD)   // the creases where it falls open
    c.rect(19, 36, 3, 1, leatherL)                                   // a zipped pocket
    // Short dark hair, cropped close: lit in short runs on top, the far side in shadow.
    c.pattern(17, 21, [
        "......HHHLLLHHHH......",
        "....HHLLHHHHLLHHHH....",
        "...HHHHHHHHHHHHHHdH...",
        "..HHHHHHHHHHHHHHHHdH..",
        ".HHH..............dHH.",
    ], ["H": hair, "L": hairL, "d": hairD])

    if oil {
        let k = sig.map { min(1, ($0 - 0.08) / 0.15, (0.92 - $0) / 0.15) } ?? 1
        drawEyes(c, C(0x060608))
        let sheen = Int(p.t * 5) % 3
        c.px(22 + sheen % 2, 29 + sheen, C(0x6A8AFF)); c.px(32 + sheen % 2, 29 + sheen, C(0x6A8AFF))
        if sig != nil && k > 0.5 {
            // It spills over: a film swimming round the eyes and a trickle down each cheek.
            for (x0, x1) in [(21, 24), (31, 34)] {
                c.rect(x0, 28, x1 - x0 + 1, 1, C(0x0A0A12, 0.7)); c.rect(x0, 32, x1 - x0 + 1, 1, C(0x0A0A12, 0.7))
                c.rect(x0, 33, 1, Int(k * 2), C(0x0A0A12, 0.8))
            }
        }
    } else {
        drawEyes(c)
    }

    c.rect(15, 33, 3, 3, leather); c.rect(15, 33, 3, 1, leatherL); c.rect(15, 35, 3, 1, leatherD)   // the cuff
    if let a = p.melee {
        drawPunch(c, angle: a, trail: p.trail, sleeve: leather)
    } else {
        // A fist ready, the pistol's grip showing at his belt.
        c.rect(38, 33, 3, 3, leather); c.rect(38, 32, 3, 1, clawdOrange)
        c.rect(36, 36, 2, 2, C(0x24242A))
    }
}

// MARK: - The Well-Manicured Clawd

/// The Well-Manicured Clawd: Clawd with silver hair neatly parted, little round spectacles, a navy pinstriped
/// three-piece suit with a waistcoat, a silk tie and a white pocket square: the Syndicate's English gentleman. He holds
/// a brandy glass; in a fight he moves it to his other hand and fires a little nickel-plated pistol. Signature: he
/// raises the glass, swirls it, and sips.
private func drawWellManicured(_ c: PixelCanvas, _ p: Pose) {
    let navy = C(0x22304E), navyD = C(0x161F36), stripe = C(0x3A4C70), waistcoat = C(0x2E3A5A)
    let shirt = C(0xF0EEE6), tie = C(0x6A1E3A), hair = C(0xD8DAE0), hairD = C(0xA8AAB4), wire = C(0xC4CAD2)
    let hairL = C(0xF4F4F8), navyL = C(0x34466E)
    let brandy = C(0xB8641E), glass = C(0xE8F0F4, 0.55)
    let sig = p.signature
    let raised = sig.map { $0 > 0.1 && $0 < 0.9 } ?? false
    let sipping = sig.map { $0 > 0.55 && $0 < 0.85 } ?? false

    drawLegs(c, Look(leg: navy), step: p.step)
    filesDrawDressShoes(c, step: p.step, color: C(0x3A1E10))
    c.oy += p.breathe
    drawBody(c, Look(arm: navy))
    // The jacket's pinstripes, the waistcoat with its buttons, shirt, tie and pocket square.
    c.rect(18, 33, 20, 5, navy); c.rect(37, 33, 1, 5, navyD)
    for x in stride(from: 19, to: 37, by: 3) { c.rect(x, 33, 1, 5, stripe) }
    c.rect(23, 33, 10, 5, waistcoat)
    c.pattern(25, 33, ["SSTTSS", ".STTS.", "..TT..", "......"], ["S": shirt, "T": tie])
    c.px(27, 36, C(0xC8B060)); c.px(28, 37, C(0xC8B060))
    c.pattern(19, 33, ["WW", "W."], ["W": shirt])
    c.rect(18, 37, 20, 1, navyD)
    c.rect(21, 33, 2, 1, navyL); c.rect(33, 33, 3, 1, navyL)        // lit shoulders
    c.rect(33, 35, 2, 1, navyD)                                      // a pocket flap
    // Silver hair, a neat side parting, combed in lit runs, the far side shaded.
    c.pattern(17, 21, [
        ".......HHHHLLLHH......",
        ".....HHHHHhLLLHHHH....",
        "...HHLLHhHHHHHLLHHd...",
        "..HHHHHHhHHHHHHHHHdH..",
        ".HHH...........HHHdH..",
        ".HH...............dH..",
    ], ["H": hair, "h": hairD, "L": hairL, "d": hairD])
    // Little round wire spectacles, the eyes behind them.
    for x0 in [21, 31] { c.pattern(x0, 28, [".WW.", "W..W", "W..W", ".WW."], ["W": wire]) }
    c.rect(25, 29, 6, 1, wire.alpha(0.8))

    if p.fire != nil || p.hit {
        // The glass in his other hand, kept level; the pistol out in this one.
        c.rect(15, 33, 3, 3, navy); c.rect(15, 35, 3, 1, shirt)
        c.pattern(12, 30, ["GGG", "GbG", ".G.", "GGG"], ["G": glass, "b": brandy])
        c.oy += p.gunY
        c.rect(38, 33, 3, 3, navy)
        c.pattern(40, 31, ["NNNNNN", "NNdN..", "Nw....", "N....."], ["N": C(0xB8BEC8), "d": C(0x6E747E), "w": C(0xE8D8B8)])
        c.px(41, 31, C(0xEEF2F6))
        return
    }
    c.rect(15, 33, 3, 3, navy); c.rect(15, 35, 3, 1, shirt)   // the sleeve and its shirt cuff
    // The brandy glass: at his chest, or raised to his mouth, swirling.
    let gx = raised ? (sipping ? 33 : 39) : 39, gy = raised ? (sipping ? 30 : 27) : 31
    c.rect(38, raised ? gy + 2 : 33, 3, 3, navy)
    let swirl = raised && !sipping ? Int(p.t * 6) % 2 : 0
    c.pattern(gx, gy, [".GGGG.", "GbbbbG", "GbbbbG", ".GGGG.", "..GG..", ".GGGG."],
              ["G": glass, "b": brandy])
    if swirl == 1 { c.px(gx + 2, gy + 1, C(0xE8A050)) }
}

// MARK: - The First Elder

/// The First Elder: Clawd as an old man, bald on top with a fringe of white hair, bushy white eyebrows, a brown
/// double-breasted suit with a burgundy tie, leaning on a black cane with a silver knob, which he swings when it comes
/// to it. Signature: he taps the cane twice on the floor and leans on it with both hands.
private func drawFirstElder(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x5A3E2A), suitD = C(0x3E2A1C), button = C(0xC8A860), tie = C(0x6E1E26), shirt = C(0xEDE8DC)
    let white = C(0xEEEEEA), whiteD = C(0xC4C4C8), cane = C(0x1A1A1E), knob = C(0xC8CCD4), suitL = C(0x765440)
    let sig = p.signature
    let leaning = sig.map { $0 > 0.45 && $0 < 0.95 } ?? false
    let tap = sig.map { s -> Int in (s > 0.08 && s < 0.18) || (s > 0.25 && s < 0.35) ? 1 : 0 } ?? 0

    drawLegs(c, Look(leg: suit), step: p.step)
    filesDrawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    // The double-breasted jacket, its two rows of buttons, shirt and tie.
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(25, 33, ["SSTTSS", ".STTS.", "..TT.."], ["S": shirt, "T": tie])
    for y in [35, 37] { c.px(23, y, button); c.px(33, y, button) }
    c.rect(18, 33, 3, 1, suitL); c.rect(34, 33, 3, 1, suitL)         // lit shoulders
    c.rect(21, 33, 1, 3, suitD); c.rect(34, 34, 1, 3, suitD)         // the lapels' edges
    c.rect(19, 35, 1, 2, suitD)                                      // a fold
    // Bald on top (a few lines on the dome), the white fringe round the sides, combed in strands, bushy brows.
    c.rect(24, 26, 3, 1, clawdShade); c.rect(29, 26, 3, 1, clawdShade)
    c.pattern(17, 26, [
        "HHH................HHd",
        "HwH................HwH",
        "Hw..................wH",
    ], ["H": white, "w": whiteD, "d": whiteD])
    c.rect(21, 27, 4, 1, white); c.rect(31, 27, 4, 1, white)

    c.rect(15, 33, 3, 3, suit); c.rect(15, 35, 3, 1, shirt)   // the sleeve and its shirt cuff
    if let a = p.melee {
        // The cane swung like a club.
        let e = along(a, 13)
        bar(c, Sprite.hand.x, Sprite.hand.y, e.x, e.y, cane, 0.8)
        c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 2, 2, knob)
        c.rect(38, 33, 3, 3, suit)
        return
    }
    if leaning {
        // Both hands on the knob, the cane planted in front of him.
        c.rect(38, 30, 4, 3, suit); c.rect(41, 29, 2, 2, knob)
        c.rect(41, 31, 1, 12, cane)
        return
    }
    // At his side, lifted and tapped down in the signature.
    c.rect(38, 33 - tap, 3, 3, suit); c.rect(41, 31 - tap, 2, 2, knob)
    c.rect(41, 33 - tap, 1, 10, cane)
}

// MARK: - Diana Fowlclawd

/// Diana Fowlclawd: Clawd with long straight dark hair over her shoulders, a slate-green trouser suit and a cream blouse,
/// an FBI sidearm. She's always a step behind someone. Signature: a glance over her shoulder, then a quiet word into
/// her mobile phone.
private func drawDianaFowlclaw(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x3E4E46), suitD = C(0x2A3630), blouse = C(0xEEE4CC), hair = C(0x1E1410), hairL = C(0x3A2A20)
    let suitL = C(0x56685E), hairD = C(0x120B08)
    let sig = p.signature
    let glance = sig.map { $0 > 0.06 && $0 < 0.4 } ?? false
    let phoning = sig.map { $0 >= 0.4 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: suit), step: p.step)
    filesDrawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit, eye: nil))
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(25, 33, ["BBBBBB", ".BBBB.", "..BB.."], ["B": blouse])
    c.rect(22, 33, 1, 3, suitL); c.rect(33, 33, 1, 3, suitL)
    c.rect(18, 33, 3, 1, suitL); c.rect(35, 33, 2, 1, suitL)         // lit shoulders
    c.rect(20, 35, 1, 2, suitD); c.rect(35, 35, 1, 2, suitD)         // folds
    // Long dark hair, a centre parting, falling past her shoulders: lit strands on the crown, the far side shaded.
    c.pattern(16, 20, [
        "........HHHHHHHH........",
        "......HHllHHlHHllHH.....",
        "....HHllHHHHlHHHHllHH...",
        "...HHHHHHHHHlHHHHHHdHH..",
        "..HHlHHHHH..l..HHHHHdHH.",
        "..HHlHHH..........HHdHH.",
        ".HHlH...............HdHH",
        ".HlH.................HdH",
        ".HlH.................HdH",
        ".HHH.................HdH",
        ".HlH.................HdH",
        ".HlH.................HHH",
        ".HHH.................HdH",
        "..HH.................HH.",
    ], ["H": hair, "l": hairL, "d": hairD])
    // Her eyes: looking back over her shoulder in the glance.
    let ex = glance ? -1 : 0
    c.rect(22 + ex, 29, 2, 3, ink); c.rect(32 + ex, 29, 2, 3, ink)

    c.rect(15, 33, 3, 3, suit); c.rect(15, 35, 3, 1, blouse)   // the sleeve and the blouse's cuff
    if phoning {
        // The phone at her ear, its little aerial up, her voice down.
        c.rect(38, 28, 3, 5, suit)
        c.rect(40, 24, 2, 5, C(0x2A2A30)); c.px(40, 23, C(0x2A2A30)); c.px(41, 26, C(0x8AE08A))
        return
    }
    c.oy += p.gunY
    filesDrawSidearm(c, sleeve: suit, searching: false)
}

// MARK: - Deputy Director Kersh

/// Deputy Director Kersh: Clawd with close-cropped dark hair and a hard frown, a mid-grey suit, a white shirt and a
/// maroon tie with an FBI pin. He holds a case file, and in a fight he swats with it, rolled up tight, pages flying.
/// Signature: he lifts the file and slams it down, papers jumping out of it.
private func drawKersh(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x5A5E68), suitD = C(0x42454E), shirt = C(0xF2F2EE), tie = C(0x6A1A22), hair = C(0x241A14)
    let manila = C(0xD8B870), manilaD = C(0xA88A48), suitL = C(0x767A86), hairL = C(0x46362A)
    let sig = p.signature
    let lifting = sig.map { $0 > 0.1 && $0 < 0.45 } ?? false
    let slam = sig.map { $0 >= 0.45 && $0 < 0.8 } ?? false

    drawLegs(c, Look(leg: suit), step: p.step)
    filesDrawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit, eye: nil))
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(25, 33, ["SSTTSS", ".STTS.", "..TT..", "..TT.."], ["S": shirt, "T": tie])
    c.px(22, 34, C(0xC8A84A))   // the FBI pin
    c.rect(18, 33, 3, 1, suitL); c.rect(34, 33, 3, 1, suitL)         // lit shoulders
    c.rect(24, 34, 1, 2, suitD); c.rect(31, 34, 1, 2, suitD)         // the lapels' edges
    c.rect(19, 35, 1, 2, suitD); c.rect(32, 36, 3, 1, suitD)         // a fold, a pocket flap
    // Close-cropped hair, receding at the temples, a lit run along the top.
    c.pattern(17, 22, [
        "......HHLLLLHHHH......",
        "...HHHHHHHHHHHHHHHd...",
        "..HHH............HdH..",
    ], ["H": hair, "L": hairL, "d": C(0x16100C)])
    // The frown: brows down to the middle, eyes narrowed.
    c.pattern(21, 27, ["KK.......", "..K......"], ["K": ink]); c.pattern(31, 27, [".......KK", "......K.."], ["K": ink])
    c.rect(22, 30, 2, 2, ink); c.rect(32, 30, 2, 2, ink)

    c.rect(15, 33, 3, 3, suit); c.rect(15, 35, 3, 1, shirt)   // the sleeve and its shirt cuff
    if let a = p.melee {
        // The file rolled into a baton and swung, a loose page or two fluttering off the end.
        for (i, ta) in p.trail.enumerated() {
            let e = along(ta, 9)
            bar(c, Sprite.hand.x, Sprite.hand.y, e.x, e.y, manila.alpha(0.3 / Double(i + 1)), 1.0)
        }
        c.rect(38, 33, 3, 3, suit)
        let e = along(a, 9), m = along(a, 5)
        bar(c, Sprite.hand.x, Sprite.hand.y, e.x, e.y, manila, 1.1)
        c.rect(Int(m.x.rounded()), Int(m.y.rounded()), 1, 1, manilaD)
        if !p.trail.isEmpty {
            let f = along(a, 11)
            c.rect(Int(f.x.rounded()) + 1, Int(f.y.rounded()) - 2, 2, 1, C(0xF4F2EA))
        }
        return
    }
    if lifting {
        c.rect(38, 26, 3, 7, suit)
        c.pattern(37, 21, ["FFFFFF", "FFFFFF", "FFFFFF", "ffffff"], ["F": manila, "f": manilaD])
        return
    }
    if slam {
        // Slammed down: the file flat in front of him, papers flying, a thump.
        c.rect(38, 34, 3, 3, suit)
        c.rect(39, 37, 8, 2, manila); c.rect(39, 39, 8, 1, manilaD)
        let k = (sig! - 0.45) / 0.35
        for i in 0..<3 {
            let x = 41 + i * 3 + Int(k * Double(i) * 3), y = 36 - Int(k * Double(5 + i * 2))
            c.rect(x, y, 2, 1, C(0xF4F2EA, 1 - k * 0.6))
        }
        if k < 0.3 { c.px(48, 37, white); c.px(49, 35, white); c.px(38, 36, white) }
        return
    }
    // The file under his arm.
    c.rect(38, 33, 3, 3, suit)
    c.rect(37, 32, 2, 6, manila); c.rect(37, 37, 2, 1, manilaD)
}

// MARK: - The Toothpick Man

/// The Toothpick Man: Clawd as a super soldier in a black suit, a pale blond crew cut, a dead-eyed stare and a toothpick at
/// the corner of his mouth that never stops moving. Bullets bounce off him, and he fights with his fists. When he's
/// hit, the metal of his spine shows through. Signature: he flicks the toothpick up, catches it in his teeth, and rolls
/// his neck.
private func drawToothpickMan(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x16181E), suitL = C(0x2C3038), shirt = C(0xE8E8E4), tie = C(0x16181E), hair = C(0xD8C890)   // a pale blond crew cut
    let pick = C(0xF4E4B4), pickD = C(0x8A6A3A), steel = C(0xB8C4D0), hairL = C(0xF0E4B4), hairD = C(0xB0A070)
    let suitD = C(0x0C0D10)
    let sig = p.signature
    let flick = sig.map { $0 > 0.08 && $0 < 0.4 } ?? false
    let roll = sig.map { $0 >= 0.5 && $0 < 0.9 } ?? false

    drawLegs(c, Look(leg: suit), step: p.step)
    filesDrawDressShoes(c, step: p.step)
    c.oy += p.breathe
    if roll { c.ox += Int(sin((sig! - 0.5) / 0.4 * 2 * .pi).rounded()) }
    drawBody(c, Look(arm: suit, eye: nil))
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitL); c.rect(18, 37, 20, 1, suitL)
    c.pattern(25, 33, ["SSTTSS", ".STTS.", "..TT.."], ["S": shirt, "T": tie])
    c.rect(18, 33, 3, 1, suitL); c.rect(33, 33, 3, 1, suitL)         // lit shoulders
    c.rect(20, 35, 1, 2, suitD); c.rect(34, 35, 1, 2, suitD)         // folds
    // The crew cut: flat on top, the sides clipped close; the bristles lit in short runs, the far side shaded.
    c.rect(19, 22, 18, 3, hair); c.rect(18, 25, 2, 3, hair); c.rect(36, 25, 2, 3, hair)
    c.rect(21, 22, 4, 1, hairL); c.rect(28, 22, 5, 1, hairL); c.rect(35, 23, 2, 2, hairD); c.rect(37, 25, 1, 3, hairD)
    c.rect(20, 21, 16, 1, C(0x2A2A2A))
    // The flat stare.
    c.rect(22, 30, 2, 2, ink); c.rect(32, 30, 2, 2, ink)
    // The toothpick: in the corner of his mouth, wagging; flicked up and caught in the signature.
    if flick {
        // Up in the air, turning over, and caught.
        let k = (sig! - 0.08) / 0.32
        let y = 31 - Int(sin(k * .pi) * 8), x = 37 + Int(k * 2)
        let turn = Int(k * 6) % 2 == 0
        if turn { c.rect(x, y, 6, 1, pick); c.rect(x, y + 1, 6, 1, pickD) }
        else { c.rect(x + 2, y - 2, 1, 5, pick); c.rect(x + 3, y - 2, 1, 5, pickD) }
    } else {
        // Out of the corner of his mouth, tilted up past his cheek, its tip wagging.
        let wag = Int(sin(p.lt * 2.2).rounded())
        c.px(33, 32, ink)
        c.rect(34, 32, 3, 1, pick); c.rect(37, 31, 3, 1, pick); c.rect(40, 30 + wag, 2, 1, pick)
        c.rect(37, 32, 3, 1, pickD); c.rect(40, 31 + wag, 2, 1, pickD)
    }
    // Hit: the steel of his spine shows down his back.
    if p.hit {
        for y in stride(from: 27, to: 38, by: 2) { c.rect(17, y, 2, 1, steel) }
    }

    c.rect(15, 33, 3, 3, suit); c.rect(15, 35, 3, 1, shirt)   // the sleeve and its shirt cuff
    if let a = p.melee {
        drawPunch(c, angle: a, trail: p.trail, sleeve: suit)
    } else {
        c.rect(38, 33, 3, 3, suit); c.rect(38, 36, 3, 1, clawdOrange)
    }
}
