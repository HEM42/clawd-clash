import Foundation

// Heroes: the Gunclawds' friends, the Scrawlys, the Clawders and two who switched sides. Jimmy Bondd and Yves Harlowe
// run with the Lone Gunclawds; Melissa and Margaret Scrawly are Dana's sister and mother (the same auburn hair); Teena
// Clawder is Fox's mother; Jeffrey Spendr and Shannon McMahawk were made by the other side and came over to ours.

let filesHeroes5: [FilesHero: Persona] = [
    .jimmyBondd: Persona(name: "Jimmy Bondd", weapon: .none, headTop: 21, signature: 2.6, callout: "Hey, guys!",
                         draw: drawJimmyBondd),
    .yvesHarlowe: Persona(name: "Yves Harlowe", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                          headTop: 20, signature: 3.2, callout: "You never saw me.",
                          draw: drawYvesHarlowe),
    .melissaScrawly: Persona(name: "Melissa Scrawly", weapon: .none, headTop: 20, signature: 3.0,
                             callout: "Trust what you feel, Dana.",
                             draw: drawMelissaScrawly),
    .margaretScrawly: Persona(name: "Margaret Scrawly", weapon: .none, headTop: 20, signature: 2.8, callout: "Be careful, Dana.",
                              draw: drawMargaretScrawly),
    .teenaClawder: Persona(name: "Teena Clawder", weapon: .none, headTop: 20, signature: 3.2,
                           callout: "Some things are best forgotten.",
                           draw: drawTeenaClawder),
    .jeffreySpendr: Persona(name: "Jeffrey Spendr", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                            headTop: 20, signature: 3.0, callout: "I'm on your side now.",
                            draw: drawJeffreySpendr),
    .shannonMcMahawk: Persona(name: "Shannon McMahawk", weapon: .saber, armoured: true, headTop: 20, signature: 3.2,
                              callout: "Get behind me.",
                              draw: drawShannonMcMahawk),
]

// MARK: - Shared bits

private let clear = C(0x000000, 0)

private func bar(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.7) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: clear, coreR: r, glowR: r + 0.1)
}

/// The point `len` pixels from the hand along `angle` degrees (0 forward, -90 straight up).
private func along(_ angle: Double, _ len: Double) -> (x: Double, y: Double) {
    let r = angle * .pi / 180
    return (Sprite.hand.x + cos(r) * len, Sprite.hand.y + sin(r) * len)
}

/// A punch: the sleeve out from the shoulder along `angle`, the fist at its end, and faded copies of earlier swings.
private func drawPunch(_ c: PixelCanvas, angle a: Double, trail: [Double], sleeve: Px) {
    for (i, t) in trail.enumerated() {
        let e = along(t, 7)
        c.rect(Int(e.x) - 1, Int(e.y) - 1, 3, 3, clawdOrange.alpha(0.35 / Double(i + 1)))
    }
    let e = along(a, 6)
    bar(c, Sprite.hand.x - 3, Sprite.hand.y - 0.5, e.x, e.y, sleeve, 1.4)
    c.rect(Int(e.x) - 1, Int(e.y) - 1, 3, 3, clawdOrange)
    c.px(Int(e.x) - 1, Int(e.y) - 1, clawdShade)
}

/// Unarmed arms: both up and waving while they cheer a fight on, otherwise down at the sides (with `cuff`, a cuff a
/// shade apart above each hand).
private func drawPlainArms(_ c: PixelCanvas, _ p: Pose, sleeve: Px, cuff: Px? = nil) {
    if p.cheering {
        let up = Int(p.t * 5) % 2
        c.rect(14, 28 - up, 3, 5, sleeve); c.rect(14, 26 - up, 3, 2, clawdOrange)
        c.rect(39, 27 + up, 3, 5, sleeve); c.rect(39, 25 + up, 3, 2, clawdOrange)
    } else {
        c.rect(15, 33, 3, 3, sleeve); c.rect(38, 33, 3, 3, sleeve)
        c.rect(15, 35, 3, 1, clawdOrange); c.rect(38, 35, 3, 1, clawdOrange)
        if let cuff { c.rect(15, 34, 3, 1, cuff); c.rect(38, 34, 3, 1, cuff) }
    }
}

/// Pearls round the neck, at the collar.
private func drawPearls(_ c: PixelCanvas, y: Int) {
    for (i, x) in (24...31).enumerated() { c.px(x, y + (i == 0 || i == 7 ? 0 : 1), C(i % 2 == 0 ? 0xF4F0E6 : 0xD8D2C4)) }
}

// MARK: - Jimmy Bondd

/// Jimmy Bondd: big, sweet and not very quick, the Gunclawds' benefactor: Clawd under a red ball cap with shaggy blond
/// hair poking out round it, a denim shirt with the sleeves pushed up, khaki trousers and sneakers. Unarmed; he cheers
/// a fight on. Signature: a big grin and a thumbs-up held out, with a little sparkle.
private func drawJimmyBondd(_ c: PixelCanvas, _ p: Pose) {
    let cap = C(0xC8282E), capD = C(0x8E1A1E), capL = C(0xE04A48), hair = C(0xD8B66A), hairD = C(0xB8944A)
    let denim = C(0x6A8EB8), denimD = C(0x4E6E96), denimL = C(0x8EACD0)
    let sig = p.signature
    let thumbs = sig.map { $0 > 0.1 && $0 < 0.9 } ?? false

    drawLegs(c, Look(leg: C(0xB89E6E)), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let y = p.step >= 0 && i % 2 == p.step ? 41 : 42
            c.rect(lx, y, 2, 1, C(0xE8E8E2)); c.rect(lx, y + 1, 2, 1, C(0x3A3A40))
        }
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: denim))
    // The denim shirt, open at the collar, a pocket each side.
    c.rect(18, 33, 20, 5, denim); c.rect(37, 33, 1, 5, denimD); c.rect(18, 37, 20, 1, denimD)
    c.rect(26, 33, 4, 2, clawdOrange); c.px(27, 35, denimD); c.px(28, 36, denimD)
    c.rect(20, 34, 3, 2, denimD); c.rect(33, 34, 3, 2, denimD)
    c.rect(20, 35, 3, 1, denim); c.rect(33, 35, 3, 1, denim); c.px(21, 34, denimL); c.px(34, 34, denimL)   // flaps, buttons
    c.rect(18, 33, 2, 1, denimL); c.rect(36, 33, 1, 1, denimL); c.rect(36, 34, 1, 3, denimD)              // lit shoulders, far side
    c.rect(18, 37, 20, 1, C(0x5A4630)); c.rect(27, 37, 2, 1, C(0xC8B8A0))                                   // the belt and buckle
    // The cap: crown, band and the brim out front; the hair shaggy out from under it at the sides and back.
    c.pattern(16, 21, [
        "......CCLLLCCCC.........",
        "....CCLLCCCCCCCdd.......",
        "...CCLCCCcCCdCCCdd......",
        "..CCCCCCCCCCdCCCCdd.....",
        "..ddddddddddddddddddBBBB",
        ".HhH..............HhH...",
        ".hH................hH...",
    ], ["C": cap, "c": C(0xF2F0EA), "d": capD, "B": capD, "H": hair, "h": hairD, "L": capL])
    if thumbs {
        // The grin, and the thumb up at arm's length.
        c.rect(25, 33, 6, 1, ink); c.rect(26, 34, 4, 1, C(0xF2F0EA))
        c.rect(38, 30, 4, 3, denim)
        c.rect(42, 29, 3, 3, clawdOrange); c.rect(43, 26, 2, 3, clawdOrange); c.px(42, 29, clawdShade)
        if Int(p.t * 6) % 2 == 0 { c.px(46, 25, C(0xFFF6B0)); c.px(47, 24, C(0xFFF6B0, 0.6)) }
        c.rect(15, 33, 3, 3, denim); c.rect(15, 35, 3, 1, denimD)
        return
    }
    drawPlainArms(c, p, sleeve: denim, cuff: denimD)
}

// MARK: - Yves Harlowe

/// Yves Harlowe: the Gunclawds' rival and, now and then, partner: Clawd with a sleek black bob and a blunt fringe, dark
/// red lips, a long black coat buttoned to the throat and black gloves; a pistol. Signature: she's gone: the picture
/// breaks up into a few scattered pixels, empty air for a beat, and she's back.
private func drawYvesHarlowe(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x24242E), coatL = C(0x4A4A5A), coatD = C(0x121218), hair = C(0x0E0E12), hairL = C(0x3A3A4C)
    let shine = C(0x6A6A82), silver = C(0xB8BCC8)
    if let s = p.signature, s > 0.25, s < 0.75 {
        // Breaking up: fewer pixels as she goes, none at the middle, more as she comes back.
        let k = abs(s - 0.5) / 0.25   // 1 at the edges, 0 in the middle
        guard k > 0.15 else { return }
        for i in 0..<Int(40 * k) {
            let x = 17 + Int(noise(i * 3 + 7) * 22), y = 20 + Int(noise(i * 3 + 8) * 23)
            c.px(x, y, (i % 3 == 0 ? clawdOrange : coatL).alpha(0.4 + 0.6 * k))
        }
        return
    }

    // The coat to below the knees, black boots.
    drawLegs(c, Look(leg: C(0x16161C)), step: p.step)
    filesDrawDressShoes(c, step: p.step)
    c.oy += p.breathe
    if !seatedPose {
        c.rect(17, 38, 22, 3, coat); c.rect(17, 40, 22, 1, coatL); c.rect(28, 38, 1, 3, coatL)
        c.rect(17, 38, 1, 3, coatL); c.rect(38, 38, 1, 3, coatD)   // the coat's edges, lit on one side
    }
    drawBody(c, Look(arm: coat))
    // The coat buttoned up to a high collar, wide lapels picked out, a belt with a silver buckle.
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD)
    c.pattern(22, 33, ["LLL....LLL", ".LL....LL.", "..L....L.."], ["L": coatL])
    c.rect(18, 36, 20, 1, coatD); c.rect(26, 36, 3, 1, silver)
    for y in [34, 35] { c.px(27, y, silver) }
    c.rect(26, 32, 3, 1, C(0xA8202E)); c.px(27, 33, C(0x8A1A26))   // dark red lips just above the collar
    // The bob: a blunt fringe straight across, the sides cut straight at the jaw.
    c.pattern(16, 20, [
        "......HHHHHHHHHHH.......",
        "....HHHHHhHHHHHHHHH.....",
        "...HHHHHHHHHHHHHhHHH....",
        "..HHHHHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHH..............HHH..",
        "..HHH..............HHH..",
        "..HHH..............HHH..",
        "..HHH..............HHH..",
        "..HHH..............HHH..",
        "..HHH..............HHH..",
    ], ["H": hair, "h": hairL])
    // The bob's sheen: a lit band across the crown and down the near side.
    c.pattern(18, 21, [
        "......ssssss........",
        "...sSSSSSSSSss......",
        "..s..........ss.....",
        "s...................",
        "s..................s",
    ], ["s": hairL, "S": shine])
    c.rect(15, 33, 3, 3, coat)
    c.oy += p.gunY
    filesDrawSidearm(c, sleeve: coat, searching: false)
    c.rect(38, 33, 3, 3, C(0x0E0E12))   // gloved hand
}

// MARK: - Melissa Scrawly

/// Melissa Scrawly: Dana's free-spirited older sister: Clawd with long wavy auburn hair (the family colour) down past
/// her shoulders, a loose purple tunic with a teal sash and a crystal on a cord. Unarmed. Signature: she holds the
/// crystal up to the light and it sparkles, colours glinting off it.
private func drawMelissaScrawly(_ c: PixelCanvas, _ p: Pose) {
    let tunic = C(0x6E4A8E), tunicD = C(0x523470), sash = C(0x2E9A8E)
    let hair = C(0xB4492E), hairL = C(0xD4643E), hairD = C(0x86321E), crystal = C(0xC8F0FF)
    let sig = p.signature
    let holding = sig.map { $0 > 0.1 && $0 < 0.9 } ?? false

    // The long hair behind her, down past the shoulders.
    c.rect(15, 30, 3, 9, hair); c.rect(38, 30, 3, 9, hair); c.px(15, 38, hairD); c.px(40, 38, hairD)
    c.rect(16, 31, 1, 3, hairL); c.rect(15, 35, 1, 2, hairL); c.rect(39, 32, 1, 3, hairD); c.rect(40, 35, 1, 2, hairD)
    drawLegs(c, Look(leg: C(0x8A6A4E)), step: p.step)
    filesDrawDressShoes(c, step: p.step, color: C(0x6A4A2E))
    c.oy += p.breathe
    if !seatedPose {   // the tunic's hem, to the knee, falling in folds
        c.rect(17, 38, 22, 3, tunic); c.rect(17, 40, 22, 1, tunicD)
        c.rect(22, 38, 1, 2, tunicD); c.rect(28, 38, 1, 2, tunicD); c.rect(34, 38, 1, 2, tunicD)
    }
    drawBody(c, Look(arm: tunic))
    c.rect(18, 33, 20, 5, tunic); c.rect(37, 33, 1, 5, tunicD); c.rect(18, 36, 20, 1, sash)
    c.px(27, 33, C(0x8A6A4E)); c.px(27, 34, crystal)   // the crystal on its cord
    c.rect(18, 33, 3, 1, C(0x8A64A8)); c.rect(20, 34, 1, 2, tunicD); c.rect(36, 34, 1, 2, tunicD)   // lit shoulder, folds
    c.rect(18, 36, 20, 1, sash); c.rect(32, 36, 2, 2, C(0x22786E)); c.px(19, 36, C(0x5AC0B4))      // the sash's knot
    // Long waves, parted in the middle, falling down both sides of her face.
    c.pattern(16, 20, [
        ".......HHHlllHHHH.......",
        ".....HHlllHlHHHlHHH.....",
        "...HHlHHHHHlHHHHlHHHd...",
        "..HHlHlHHHHHHHHHHlHHdd..",
        ".HHlHHHHHHHHHHHHHHHdHHd.",
        ".HlHHHHHHHHHlHHHHHHHdHd.",
        "HlHHHH.............HdHdH",
        "HHlHd...............dHdH",
        "HlHH.................HdH",
        "HHld.................ddH",
        "HlHH.................HdH",
        ".HHd.................dHd",
    ], ["H": hair, "l": hairL, "d": hairD])
    if holding {
        // The crystal held up at eye level, glinting.
        c.rect(38, 28, 3, 5, tunic)
        c.pattern(41, 22, [".C.", "CcC", "CcC", ".C."], ["C": crystal, "c": C(0x8AD8F0)])
        let k = Int(p.t * 7)
        let glints = [C(0xFF8AD8), C(0xFFF08A), C(0x8AFFD0), C(0xFFFFFF)]
        for i in 0..<3 {
            let a = Double(i) * 2.1 + p.t * 3
            c.px(42 + Int(cos(a) * 4), 23 + Int(sin(a) * 3), glints[(i + k) % glints.count])
        }
        c.rect(15, 33, 3, 3, tunic); c.rect(15, 35, 3, 1, tunicD)
        return
    }
    drawPlainArms(c, p, sleeve: tunic, cuff: tunicD)
}

// MARK: - Margaret Scrawly

/// Margaret Scrawly: Dana's mother: Clawd with short, set auburn hair going grey at the temples, a sage-green cardigan
/// over a cream blouse, pearls and the same small gold cross her daughter wears. Unarmed. Signature: she opens her arms
/// wide for a hug, and a little heart floats up.
private func drawMargaretScrawly(_ c: PixelCanvas, _ p: Pose) {
    let cardigan = C(0x7A8E6A), cardiganD = C(0x5A6E4C), blouse = C(0xEDE4CC), gold = C(0xE8C04A)
    let hair = C(0xA8503A), hairL = C(0xC46A4C), grey = C(0xB8B0AA)
    let sig = p.signature
    let hugging = sig.map { $0 > 0.12 && $0 < 0.88 } ?? false

    drawLegs(c, Look(leg: C(0x5A5048)), step: p.step)
    filesDrawDressShoes(c, step: p.step, color: C(0x4A3A2E))
    c.oy += p.breathe
    if !seatedPose {   // a skirt to the knee, a pleat or two
        c.rect(17, 38, 22, 2, C(0x6A5E54)); c.px(22, 39, C(0x54493F)); c.px(28, 38, C(0x54493F)); c.px(34, 39, C(0x54493F))
    }
    drawBody(c, Look(arm: cardigan))
    c.rect(18, 33, 20, 5, cardigan); c.rect(37, 33, 1, 5, cardiganD); c.rect(18, 37, 20, 1, cardiganD)
    c.rect(24, 33, 8, 5, blouse); for y in [34, 36] { c.px(23, y, C(0xD8D0B8)) }
    // The cardigan: its button band and buttons, lit shoulders, a fold, the far side in shade.
    c.rect(22, 33, 1, 5, cardiganD); c.px(22, 34, C(0xE8E0C8)); c.px(22, 36, C(0xE8E0C8))
    c.rect(18, 33, 3, 1, C(0x96A886)); c.rect(34, 33, 2, 1, C(0x96A886))
    c.rect(20, 35, 1, 2, cardiganD); c.rect(35, 34, 1, 3, cardiganD)
    drawPearls(c, y: 33)
    c.px(27, 35, gold); c.rect(26, 36, 3, 1, gold); c.px(27, 37, gold)
    // Short set waves, grey coming in at the temples.
    c.pattern(17, 20, [
        "......HHHllHHHHH......",
        "...HHllHHHHHllHHHH....",
        "..HHHHHHHlllHHHHHHdH..",
        ".HHllHHHHHHHHHHllHHdH.",
        ".HHHHHHHHddHHHHHHHdHH.",
        ".gHHHHHHHHHHHHHHHHHHg.",
        ".gHH..............HHg.",
        "..g................g..",
    ], ["H": hair, "l": hairL, "g": grey, "d": C(0x86402E)])
    // The grey at the temples, a streak swept back into the auburn above each.
    c.pattern(17, 22, [
        "..W................W..",
        ".gW................Wg.",
        "gWg................gWg",
        "gWg................gWg",
        "gW..................Wg",
        "gW..................Wg",
    ], ["g": grey, "W": C(0xE4E0DA)])
    if hugging {
        // Both arms open wide, a heart rising over her head.
        let k = sig.map { ($0 - 0.12) / 0.76 } ?? 0
        c.rect(11, 29, 5, 3, cardigan); c.rect(9, 28, 2, 3, clawdOrange)
        c.rect(40, 29, 5, 3, cardigan); c.rect(45, 28, 2, 3, clawdOrange)
        let hy = 16 - Int(k * 8)
        c.pattern(34, hy, ["R.R", "RRR", ".R."], ["R": C(0xE8506A).alpha(1 - k * 0.6)])
        return
    }
    drawPlainArms(c, p, sleeve: cardigan, cuff: cardiganD)
}

// MARK: - Teena Clawder

/// Teena Clawder: Fox's mother, who knows more than she'll say: Clawd with dark hair set in a neat short bob, a
/// lavender twinset, pearls, a grey skirt and a black handbag on her arm. Unarmed. Signature: the guarded look: her
/// eyes slide away, she lifts a finger to her lips, and the handbag clutched tighter.
private func drawTeenaClawder(_ c: PixelCanvas, _ p: Pose) {
    let twin = C(0x9A88B8), twinD = C(0x7A6A98), hair = C(0x2E2420), hairL = C(0x4A3A30), bag = C(0x7A2A34)
    let sig = p.signature
    let guarded = sig.map { $0 > 0.1 && $0 < 0.92 } ?? false

    drawLegs(c, Look(leg: C(0x6A6A70)), step: p.step)
    filesDrawDressShoes(c, step: p.step)
    c.oy += p.breathe
    if !seatedPose {   // the grey skirt, a pleat or two
        c.rect(17, 38, 22, 2, C(0x5A5A62)); c.px(22, 39, C(0x46464E)); c.px(28, 38, C(0x46464E)); c.px(34, 39, C(0x46464E))
    }
    drawBody(c, Look(arm: twin, eye: guarded ? nil : ink))
    if guarded {   // the eyes slid to one side, not meeting yours
        c.rect(20, 30, 2, 2, ink); c.rect(30, 30, 2, 2, ink)
    }
    c.rect(18, 33, 20, 5, twin); c.rect(37, 33, 1, 5, twinD); c.rect(18, 37, 20, 1, twinD)
    c.rect(24, 33, 8, 1, twinD)   // the cardigan's neckline over the sweater
    // The cardigan's edges either side of the sweater, lit shoulders, a fold, the far side in shade.
    c.rect(23, 34, 1, 4, twinD); c.rect(32, 34, 1, 4, twinD)
    c.rect(18, 33, 3, 1, C(0xB4A4CE)); c.rect(34, 33, 2, 1, C(0xB4A4CE))
    c.rect(20, 35, 1, 2, twinD); c.rect(35, 34, 1, 3, twinD)
    drawPearls(c, y: 33)
    // The handbag hanging from her left arm by its strap: burgundy leather, a gold clasp.
    c.pattern(12, 32, ["..SS.", ".S..S", "BBBBB", "BbBBB", "BBBBB", ".bbb."], ["S": C(0x3A1A1E), "B": bag, "b": C(0x4A1E22)])
    c.px(14, 34, C(0xE8C04A))
    // A neat bob, curled under at the jaw.
    c.pattern(16, 20, [
        "......HHHlllHHHHHH......",
        "....HHlllHlHHHHHllHH....",
        "...HHlHHHHHHHHHlHHHHd...",
        "..HHlHHHHHHHHHHHHHHHdd..",
        "..HlHHHHHHHHHHHHHHHHdd..",
        "..HlHHlHHHHHHHHHHHHHdd..",
        "..HlH..............Hdd..",
        "..HlH..............HdH..",
        "..HHH..............dHH..",
        "...HH..............HH...",
    ], ["H": hair, "l": hairL, "d": C(0x1E1814)])
    if guarded {
        // A finger to her lips.
        c.rect(38, 30, 3, 3, twin); c.rect(31, 31, 4, 1, twin); c.rect(28, 30, 2, 3, clawdOrange)
        return
    }
    if p.cheering {
        c.rect(39, 28, 3, 5, twin); c.rect(39, 26, 3, 2, clawdOrange)
    } else {
        c.rect(38, 33, 3, 3, twin); c.rect(38, 35, 3, 1, clawdOrange); c.rect(38, 34, 3, 1, twinD)
    }
}

// MARK: - Jeffrey Spendr

/// Jeffrey Spendr: the Smoking Clawd's son, a young agent who started out against the X-Files and ended up on their
/// side: Clawd with neat dark-blond hair, side-parted and gelled, a sharp slate-blue suit, a white shirt and a thin
/// burgundy tie; the FBI sidearm and flashlight. Signature: he feeds a case file into a shredder, the strips spilling
/// out underneath, and dusts off his hands.
private func drawJeffreySpendr(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x4A5A7A), suitD = C(0x36445E), suitL = C(0x62749A), shirt = C(0xEDEDE8), tie = C(0x7A1E3A)
    let hair = C(0xA8884E), hairL = C(0xC8A866), hairD = C(0x7E643A)
    let sig = p.signature
    let shredding = sig.map { $0 > 0.08 && $0 < 0.8 } ?? false

    drawLegs(c, Look(leg: suit), step: p.step)
    filesDrawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(24, 33, ["lSSTSSl", ".lSTSl.", "..STS..", "...T..."], ["l": suitD, "S": shirt, "T": tie])
    filesDrawJacketDetail(c, dark: suitD, light: suitL)
    c.px(27, 36, suitD)   // the jacket's button
    // Gelled hair, a hard side parting, combed over.
    c.pattern(17, 20, [
        "......HHHHHHHHHH......",
        "....HHHHHHHHHHHHHH....",
        "...HHHlllHHHHHHHHHH...",
        "..dHHHHHHlllHHHHHHHH..",
        "..dHHHHHHHHHHHlllHHH..",
        ".ddHHHHHHHHHHHHHHHHHH.",
        ".dH................HH.",
    ], ["H": hair, "l": hairL, "d": hairD])
    if shredding {
        // The shredder on its basket beside him, the file going in at the top and strips falling out below.
        let k: Double = (sig! - 0.08) / 0.72
        let paper = C(0xF0E4BC), paperD = C(0xC8B888)
        // The basket, brimming with strips already, its wire mesh.
        c.rect(43, 36, 13, 7, C(0x4A4E58)); c.rect(43, 36, 13, 1, C(0x8A8E98)); c.rect(55, 36, 1, 7, C(0x34363E))
        for x in stride(from: 45, through: 53, by: 2) { c.rect(x, 37, 1, 6, C(0x34363E)) }
        c.pattern(44, 34, [".p.pp.p.pp.", "pPpPPpPpPPp"], ["p": paperD, "P": paper])
        // The shredder head on top: dark, the slot, its green light.
        c.rect(42, 30, 15, 4, C(0x2A2A30)); c.rect(42, 30, 15, 1, C(0x5A5A66)); c.rect(44, 31, 11, 1, C(0x0A0A0C))
        c.px(55, 32, Int(p.t * 4) % 2 == 0 ? C(0x5AE85A) : C(0x2A7A2A))
        c.rect(38, 31, 5, 3, suit)
        // The file going in at the top, lined with type.
        let fileH: Int = max(0, 7 - Int(k * 7))
        if fileH > 0 {
            c.rect(45, 31 - fileH, 9, fileH, C(0xE8D8A8))
            for y in stride(from: 31 - fileH + 1, to: 31, by: 2) { c.rect(46, y, 6, 1, C(0x8A8070)) }
        }
        // Strips spilling out under the head into the basket, long enough to read even standing still.
        for i in 0..<6 {
            let drop: Int = Int((k * 9 + Double(i) * 1.7).truncatingRemainder(dividingBy: 3))
            c.rect(44 + i * 2, 34 + drop, 1, 2, i % 2 == 0 ? paper : paperD)
        }
        c.rect(15, 33, 3, 3, suit); filesDrawCuffs(c, suitD, right: false)
        return
    }
    c.rect(15, 33, 3, 3, suit); filesDrawCuffs(c, suitD, right: false)
    c.oy += p.gunY
    filesDrawSidearm(c, sleeve: suit, searching: p.ready || p.fire != nil)
    filesDrawCuffs(c, suitD, left: false)
}

// MARK: - Shannon McMahawk

/// Shannon McMahawk: a super soldier who chose the right side: Clawd with dark hair cropped short at the back and a
/// long side-swept fringe, a black leather jacket over an olive T-shirt, dark jeans and boots. Bullets glance off her and
/// she fights with her fists. Signature: she wrenches a car door off its hinges and holds it up over her head, then
/// tosses it aside.
private func drawShannonMcMahawk(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x26201E), jacketL = C(0x463A34), tee = C(0x5E6A3E), hair = C(0x241812), hairL = C(0x3E2A1E)
    let sig = p.signature

    drawLegs(c, Look(leg: C(0x2A3446)), step: p.step)
    filesDrawDressShoes(c, step: p.step, color: C(0x1A1412))
    c.oy += p.breathe
    drawBody(c, Look(arm: jacket))
    c.rect(18, 33, 20, 5, jacket); c.rect(24, 33, 8, 5, tee); c.rect(18, 37, 20, 1, C(0x161210))
    c.rect(22, 33, 2, 4, jacketL); c.rect(32, 33, 2, 4, jacketL)
    filesDrawJacketDetail(c, dark: C(0x161210), light: jacketL, pocket: false)
    c.rect(24, 36, 8, 1, C(0x4A5530)); c.px(23, 35, C(0x8A8A90))   // the T-shirt's fold; the zip's pull
    // Short at the back, the fringe swept long over one eye.
    c.pattern(17, 20, [
        ".......HHHllHHH.......",
        ".....HHllHHHHHllH.....",
        "...HHlHHHHHlHHHHHHd...",
        "..HHHHHHHHHHllHHHHdd..",
        "..HHHHHHHHHHHHllHHHdd.",
        ".HHHHHHHHHHHHHHHlHHdd.",
        ".HH.......HHHHHHHlHdd.",
        ".H.........HHHHHH..d..",
    ], ["H": hair, "l": hairL, "d": C(0x160E0A)])
    if let s = sig, s > 0.1, s < 0.9 {
        // The car door: wrenched up, held overhead, flung away at the end.
        let lift = min(1, (s - 0.1) / 0.2), fling = max(0, (s - 0.75) / 0.15)
        let dx = 30 + Int(fling * 18), dy = 14 - Int(lift * 8) + Int(fling * 6)
        c.rect(dx, dy, 18, 11, C(0x7A2A2A)); c.rect(dx, dy, 18, 1, C(0xA84A4A)); c.rect(dx + 17, dy, 1, 11, C(0x4E1A1A))
        c.rect(dx + 2, dy + 1, 13, 4, C(0x9AC8D8, 0.8)); c.rect(dx + 2, dy + 1, 13, 1, C(0xD8F0F8, 0.8))   // its window
        c.rect(dx + 11, dy + 6, 4, 1, C(0xC8C8D0))   // the handle
        if fling < 1 {
            c.rect(36, dy + 10, 3, 18 - dy, jacket); c.rect(36, dy + 9, 3, 2, clawdOrange)
            c.rect(17, dy + 10, 3, 18 - dy, jacket); c.rect(17, dy + 9, 3, 2, clawdOrange)
        }
        return
    }
    c.rect(15, 33, 3, 3, jacket); filesDrawCuffs(c, C(0x161210), right: false)
    if let a = p.cheering ? -95 : p.melee {
        drawPunch(c, angle: a, trail: p.trail, sleeve: jacket)
    } else {
        c.rect(38, 33, 3, 3, jacket); c.rect(38, 35, 3, 1, clawdOrange); c.rect(38, 34, 3, 1, C(0x161210))
    }
}
