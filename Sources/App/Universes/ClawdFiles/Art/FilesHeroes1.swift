import Foundation

// Heroes: the X-Files unit. Clawd in costume like the rest of the cast: hair, suit and coat drawn over the blocky body,
// with Clawd's own orange face showing. FBI agents carry a sidearm, and in a fight a flashlight under it throws its
// pale beam ahead of them, the way every dark room in the show is searched.

let filesHeroes1: [FilesHero: Persona] = [
    .foxClawder: Persona(name: "Fox Clawder", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                         headTop: 20, signature: 3.6, callout: "The truth is out there.",
                         draw: drawFoxClawder),
    .danaScrawly: Persona(name: "Dana Scrawly", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                          headTop: 20, signature: 3.0, callout: "Mulder, it's me.",
                          draw: drawDanaScrawly),
]

// MARK: - Shared bits

/// Black dress shoes on the four feet; the lifted pair a row higher while walking.
func filesDrawDressShoes(_ c: PixelCanvas, step: Int, color: Px = C(0x18181C)) {
    guard !seatedPose else { return }
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        c.rect(lx, step >= 0 && i % 2 == step ? 41 : 42, 2, 2, color)
    }
}


/// The FBI sidearm in the right hand (its muzzle at (47, 32)) and, when `searching`, the flashlight held under it with
/// its pale beam spreading ahead into the dark.
func filesDrawSidearm(_ c: PixelCanvas, sleeve: Px, searching: Bool) {
    c.rect(38, 33, 3, 3, sleeve)
    c.pattern(40, 31, ["KKKKKKK", "KKGKK..", "KK.....", "KK....."], ["K": C(0x24242A), "G": C(0x5E626C)])
    guard searching else { return }
    c.rect(41, 34, 4, 1, C(0x3A3A42)); c.px(45, 34, C(0xFFF6D0))
    for x in 46...70 {
        let half = (x - 46) / 5, fade = 1 - Double(x - 46) / 25
        c.rect(x, 34 - half, 1, half * 2 + 1, C(0xFFF0B0, 0.32 * fade))
        c.px(x, 34, C(0xFFF8DC, 0.4 * fade))   // brighter down the middle
    }
}

/// The small detail on a jacket over Clawd's front (its block at x 18...37, rows 33...37): light along the shoulders,
/// a fold, the far side in shade and, with `pocket`, a pocket flap low on the far side.
func filesDrawJacketDetail(_ c: PixelCanvas, dark: Px, light: Px, pocket: Bool = true) {
    c.rect(18, 33, 3, 1, light); c.rect(34, 33, 2, 1, light)
    c.rect(20, 35, 1, 2, dark); c.rect(36, 34, 1, 3, dark)
    if pocket { c.rect(32, 36, 2, 1, dark) }
}

/// Cuffs a shade apart at the ends of the sleeves hanging at Clawd's sides.
func filesDrawCuffs(_ c: PixelCanvas, _ col: Px, left: Bool = true, right: Bool = true) {
    if left { c.rect(15, 35, 3, 1, col) }
    if right { c.rect(38, 35, 3, 1, col) }
}

/// A long coat's tails, hanging over the legs (shorter seated).
private func drawCoatTails(_ c: PixelCanvas, coat: Px, dark: Px, length: Int) {
    let tails = seatedPose ? 1 : length
    c.rect(17, 38, 22, tails, coat); c.rect(17, 37 + tails, 22, 1, dark); c.rect(28, 38, 1, tails, dark)
}

// MARK: - Fox Clawder

/// Fox Clawder: Clawd with dark brown hair, short with a floppy fringe, a grey suit with a loud wide tie, and a long
/// charcoal trench coat open over it. In a fight, the sidearm and the flashlight. Signature: he cracks a few sunflower
/// seeds, flicking the shells away, then points up at the sky, where a little saucer blinks over his head ("I want to
/// believe").
private func drawFoxClawder(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x4A4740), coatD = C(0x32302B), coatL = C(0x66625A)
    let suit = C(0x6C707A), shirt = C(0xEDEDE8), tie = C(0x8A2A3A), tieDot = C(0xC8A04A)
    let hair = C(0x3A2618), hairL = C(0x56391F), hairD = C(0x281A10)
    let sig = p.signature
    let seeds = sig.map { $0 > 0.05 && $0 < 0.45 } ?? false
    let pointing = sig.map { $0 > 0.5 && $0 < 0.95 } ?? false

    drawLegs(c, Look(leg: C(0x3A3C44)), step: p.step)
    filesDrawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawCoatTails(c, coat: coat, dark: coatD, length: 3)
    if !seatedPose { c.rect(22, 38, 1, 2, coatD); c.rect(34, 38, 1, 2, coatD) }   // folds in the tails
    drawBody(c, Look(arm: coat))
    // The suit and its tie, the coat open over it.
    c.rect(18, 34, 20, 4, suit); c.rect(37, 34, 1, 4, C(0x52565E))
    c.pattern(24, 34, ["lSTTSl", ".lTTl.", "..TT..", "..tT.."], ["l": C(0x52565E), "S": shirt, "T": tie, "t": tieDot])
    c.rect(18, 33, 4, 5, coat); c.rect(34, 33, 4, 5, coat); c.rect(37, 33, 1, 5, coatD)
    c.rect(22, 33, 1, 3, coatL); c.rect(33, 33, 1, 3, coatL)   // the lapels
    c.rect(18, 33, 3, 1, coatL); c.rect(34, 33, 2, 1, coatL)   // light along the shoulders
    c.rect(20, 35, 1, 2, coatD); c.rect(36, 34, 1, 3, coatD)   // a fold, and the far side in shade
    c.rect(19, 36, 2, 1, coatD); c.px(30, 36, C(0x52565E))     // a pocket flap; the jacket's button
    c.rect(18, 37, 20, 1, coatD)
    // The hair: short, a side parting, the fringe falling over his forehead.
    c.pattern(17, 20, [
        ".......HHHhhHHH.......",
        "....HHHhhHHHHHHhhH....",
        "...HHhHHHHHHHHhHHHH...",
        "..HHHHHHHhhHHHHhHHHd..",
        "..HHhHHHHHHHHHHHHhHdd.",
        ".HHHHHHhHHHHHHHHHHHdd.",
        ".HHH...HHHHd......Hdd.",
        ".HH.....HH.........Hd.",
    ], ["H": hair, "h": hairL, "d": hairD])

    if seeds {
        // A hand at his mouth; the cracked shells flick out and drop, one every so often.
        c.rect(36, 31, 3, 3, coat); c.px(35, 32, clawdOrange)
        let k = (sig! - 0.05) / 0.4
        for i in 0..<3 {
            let s = k * 3 - Double(i)
            guard s > 0, s < 1 else { continue }
            c.px(36 + Int(s * 9), 32 - Int(sin(s * .pi) * 5), C(0x2A2A26))
            c.px(37 + Int(s * 9), 32 - Int(sin(s * .pi) * 5), C(0xE8E4D4))
        }
        c.rect(15, 33, 3, 3, coat); c.rect(15, 35, 3, 1, coatD)   // the sleeve and its cuff
        return
    }
    if pointing {
        // His arm straight up, a finger to the sky, and the little saucer up there with its light blinking.
        c.rect(38, 21, 3, 12, coat); c.rect(39, 18, 1, 3, clawdOrange)
        let blink = Int(p.t * 4) % 2 == 0
        c.pattern(50, 4, ["..DDD..", "HHHHHHH", ".hhhhh."], ["D": C(0x9AA8B0), "H": C(0xC4CCD2), "h": C(0x6E7880)])
        c.px(blink ? 51 : 55, 5, C(0x8AFFB4))
        c.rect(15, 33, 3, 3, coat); c.rect(15, 35, 3, 1, coatD)   // the sleeve and its cuff
        return
    }
    c.rect(15, 33, 3, 3, coat); c.rect(15, 35, 3, 1, coatD)   // the sleeve and its cuff
    c.oy += p.gunY
    filesDrawSidearm(c, sleeve: coat, searching: p.ready || p.fire != nil)
    c.rect(38, 35, 3, 1, coatD)
}

// MARK: - Dana Scrawly

/// Dana Scrawly: Clawd with an auburn bob down to her jaw, a dark trouser suit with a small gold cross at the collar,
/// and a long camel coat over it. In a fight, the sidearm and the flashlight. Signature: she holds up her badge, the
/// wallet open on the gold shield, one eyebrow raised.
private func drawDanaScrawly(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0xB08A5A), coatD = C(0x86683F), coatL = C(0xCCA672)
    let suit = C(0x2E3442), shirt = C(0xE6E2DA), gold = C(0xE8C04A)
    let hair = C(0xB4492E), hairL = C(0xD4643E), hairD = C(0x86321E)
    let sig = p.signature
    let badge = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: suit), step: p.step)
    filesDrawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawCoatTails(c, coat: coat, dark: coatD, length: 3)
    if !seatedPose { c.rect(22, 38, 1, 2, coatD); c.rect(34, 38, 1, 2, coatD) }   // folds in the tails
    drawBody(c, Look(arm: coat))
    // The suit, its open collar and the cross; the coat over it.
    c.rect(18, 34, 20, 4, suit); c.rect(37, 34, 1, 4, C(0x20242E))
    c.pattern(25, 34, ["SSSSSS", ".SgGS.", "..GG.."], ["S": shirt, "g": gold, "G": gold])
    c.rect(18, 33, 4, 5, coat); c.rect(34, 33, 4, 5, coat); c.rect(37, 33, 1, 5, coatD)
    c.rect(22, 33, 1, 3, coatL); c.rect(33, 33, 1, 3, coatL)
    c.rect(18, 33, 3, 1, coatL); c.rect(34, 33, 2, 1, coatL)   // light along the shoulders
    c.rect(20, 35, 1, 2, coatD); c.rect(36, 34, 1, 3, coatD)   // a fold, and the far side in shade
    // The coat's belt, tied at the side.
    c.rect(18, 36, 5, 1, coatD); c.rect(33, 36, 5, 1, coatD); c.px(19, 37, C(0x6E5232))
    c.rect(18, 37, 20, 1, coatD)
    // The bob: a side parting, the sides down past the eyes to the jaw.
    c.pattern(16, 20, [
        ".......HHHllHHHH........",
        ".....HHHHllHHHHlHHH.....",
        "...HHllHHHHHHHHHlHHHHd..",
        "..HlHHHHHHHHllHHHHHHHdd.",
        "..lHHHHHHHHHHHHHHHllHdd.",
        ".HlHHHHHHHHHHHHHHHHHHHdd",
        ".HlHHH...HHHHH......HHdd",
        ".lHHd...............dHdH",
        ".lHH.................HdH",
        ".HHd.................dHd",
        ".HlH.................HdH",
        "..Hd.................dH.",
    ], ["H": hair, "l": hairL, "d": hairD])

    if badge {
        // The raised eyebrow, and the badge held up and out: a black wallet open on the gold shield.
        c.rect(31, 26, 3, 1, hairD)
        c.rect(38, 28, 3, 6, coat)
        c.pattern(40, 23, ["KKKKKKK", "KGGKwwK", "KGGKwwK", "KGGKwwK", "KKKKKKK"],
                  ["K": C(0x1E1E22), "G": gold, "w": C(0xF2F2EE)])
        c.rect(15, 33, 3, 3, coat); c.rect(15, 35, 3, 1, coatD)   // the sleeve and its cuff
        return
    }
    c.rect(15, 33, 3, 3, coat); c.rect(15, 35, 3, 1, coatD)   // the sleeve and its cuff
    c.oy += p.gunY
    filesDrawSidearm(c, sleeve: coat, searching: p.ready || p.fire != nil)
    c.rect(38, 35, 3, 1, coatD)
}
