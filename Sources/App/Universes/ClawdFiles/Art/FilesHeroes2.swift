import Foundation

// Heroes: the rest of the FBI. Skinnard, Doggedd, Reyez, Einstine and Millar. Two brawlers who settle things with their
// fists, and three more agents with the sidearm and the flashlight; each in their own colours so a line of suits still
// reads apart: Skinnard in shirtsleeves, Doggedd in navy, Reyez in brown leather, Einstine in pale grey, Millar in blue.

let filesHeroes2: [FilesHero: Persona] = [
    .skinnard: Persona(name: "A.D. Walter Skinnard", weapon: .saber, headTop: 26, signature: 3.2, callout: "Sit down, Agent.",
                       draw: drawSkinnard),
    .doggedd: Persona(name: "John Doggedd", weapon: .saber, headTop: 22, signature: 2.8, callout: "Show me.",
                      draw: drawDoggedd),
    .reyez: Persona(name: "Monica Reyez", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                    headTop: 21, signature: 3.4, callout: "Did you feel that?",
                    draw: drawReyez),
    .einstine: Persona(name: "Agent Einstine", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                       headTop: 21, signature: 3.0, callout: "There's an explanation.",
                       draw: drawEinstine),
    .millar: Persona(name: "Agent Millar", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                     headTop: 20, signature: 3.0, callout: "Let me look that up.",
                     draw: drawMillar),
]

// MARK: - Shared bits

private let clear = C(0x000000, 0)

private func bar(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.7) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: clear, coreR: r, glowR: r + 0.1)
}

/// The point `len` pixels from `from` along `angle` degrees (0 forward, -90 straight up).
private func along(_ angle: Double, _ len: Double, from h: (x: Double, y: Double) = Sprite.hand) -> (x: Double, y: Double) {
    let r = angle * .pi / 180
    return (h.x + cos(r) * len, h.y + sin(r) * len)
}

/// A punch: the sleeve out from the shoulder along `angle`, the fist at its end, and faded copies of earlier swings.
private func drawPunch(_ c: PixelCanvas, angle a: Double, trail: [Double], sleeve: Px) {
    for (i, t) in trail.enumerated() {
        let e = along(t, 7)
        c.rect(Int(e.x) - 1, Int(e.y) - 1, 3, 3, clawdOrange.alpha(0.35 / Double(i + 1)))
    }
    let h = Sprite.hand
    let e = along(a, 6)
    bar(c, h.x - 3, h.y - 0.5, e.x, e.y, sleeve, 1.4)
    c.rect(Int(e.x) - 1, Int(e.y) - 1, 3, 3, clawdOrange)
    c.px(Int(e.x) - 1, Int(e.y) - 1, clawdShade)
}

/// Rectangular dark frames over the eyes.
private func drawFrames(_ c: PixelCanvas, _ frame: Px) {
    c.pattern(20, 28, ["FFFFFF....FFFFFF", "F....FFFFFF....F", "F....F....F....F", "FFFFFF....FFFFFF"], ["F": frame])
    c.rect(21, 29, 4, 2, C(0xDFF0FF, 0.25)); c.rect(31, 29, 4, 2, C(0xDFF0FF, 0.25))
}

// MARK: - A.D. Walter Skinnard

/// Assistant Director Walter Skinnard: Clawd bald, a dark fringe of stubble low round the sides, wire-rimmed glasses,
/// a white shirt with the sleeves rolled up, a dark red tie loosened, grey trousers. No jacket: he's been at his desk
/// all night. He settles things with his fists. Signature: he takes his glasses off, rubs his eyes with finger and
/// thumb, and puts them back on.
private func drawSkinnard(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0xF0EEE8), shirtD = C(0xC8C6C0), tie = C(0x7A1E2A), trousers = C(0x4A4C54)
    let stubble = C(0x5A3A26), frame = C(0x8A8E98)
    let sig = p.signature
    let off = sig.map { $0 > 0.12 && $0 < 0.88 } ?? false
    let rubbing = sig.map { $0 > 0.25 && $0 < 0.75 } ?? false

    h14Trousers(c, leg: trousers, step: p.step)
    drawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: shirt))
    // The bald crown's shine and the stubble low round the sides.
    c.rect(24, 26, 6, 1, C(0xE8957A)); c.px(23, 27, C(0xE8957A))
    c.rect(18, 28, 1, 4, stubble); c.rect(37, 28, 1, 4, stubble)
    // The shirt, rolled sleeves (orange forearms), the loosened tie.
    c.rect(18, 34, 20, 4, shirt); c.rect(37, 34, 1, 4, shirtD); c.rect(18, 37, 20, 1, shirtD)
    c.pattern(25, 34, ["s.TT.s", "..TT..", "..TT..", "...T.."], ["s": shirtD, "T": tie])
    c.rect(26, 33, 4, 1, shirtD)
    // The glasses: on his nose, or in his hand while he rubs his eyes.
    if !off { drawFrames(c, frame) }
    c.rect(15, 33, 3, 3, shirt); c.px(15, 35, clawdOrange)

    if off {
        // The glasses dangling from his left hand; the right arm up across his face, the white sleeve reaching to the
        // hand at the bridge of his nose, finger and thumb pressed into his eyes (the hand outlined in shade, so it
        // shows on his face).
        c.pattern(11, 34, ["FFF.FFF", "F.FFF.F", "FFF.FFF"], ["F": frame])
        let dy: Int = rubbing && Int(p.t * 6) % 2 == 0 ? -1 : 0
        c.rect(38, 30, 3, 4, shirt); c.rect(34, 30 + dy, 4, 2, shirt); c.rect(34, 31 + dy, 4, 1, shirtD)
        c.pattern(26, 27 + dy, [
            "s.....s.",
            "o.sssso.",
            "osooooos",
            "soooooos",
            ".ssssss.",
        ], ["o": C(0xF2A888), "s": clawdShade])   // the hand lit paler than the face behind it
        return
    }
    if let a = p.cheering ? -95 : p.melee {
        drawPunch(c, angle: a, trail: p.trail, sleeve: shirt)
    } else {
        c.rect(38, 33, 3, 3, shirt); c.rect(38, 35, 3, 1, clawdOrange)
    }
}

// MARK: - John Doggedd

/// John Doggedd: Clawd with a sandy crew cut cropped flat, a heavy brow, a navy suit, white shirt and a plain blue-grey
/// tie, an ex-Marine's square shoulders. He fights with his fists. Signature: he squares up, both fists raised in a
/// boxer's guard, bouncing on his toes.
private func drawDoggedd(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x26304A), suitD = C(0x1A2236), suitL = C(0x3A4664), shirt = C(0xEDEDE8), tie = C(0x5A6A84)
    let hair = C(0xA88A5A), hairD = C(0x7E6640)
    let sig = p.signature
    let guarding = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false
    if guarding && Int(p.t * 5) % 2 == 0 { c.oy -= 1 }

    h14Trousers(c, leg: suit, step: p.step)
    drawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    // The crew cut: short and flat across the top, close at the sides.
    c.pattern(17, 23, [
        "..hHHhHHhHHhHHhHHhHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HD................DH.",
        ".D..................D.",
    ], ["H": hair, "h": hairD, "D": hairD])
    // The heavy brow over the eyes.
    c.rect(21, 28, 4, 1, hairD); c.rect(31, 28, 4, 1, hairD)
    // The suit, shirt and tie.
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(24, 33, ["lSTTSl", ".lTTl.", "..TT..", "..TT.."], ["l": suitL, "S": shirt, "T": tie])

    if guarding {
        // Both fists up before his face.
        c.rect(15, 30, 3, 4, suit); c.rect(16, 28, 3, 3, clawdOrange); c.px(16, 28, clawdShade)
        c.rect(38, 30, 3, 4, suit); c.rect(38, 27, 3, 3, clawdOrange); c.px(40, 27, clawdShade)
        return
    }
    c.rect(15, 33, 3, 3, suit)
    if let a = p.cheering ? -95 : p.melee {
        drawPunch(c, angle: a, trail: p.trail, sleeve: suit)
    } else {
        c.rect(38, 33, 3, 3, suit); c.rect(38, 35, 3, 1, clawdOrange)
    }
}

// MARK: - Monica Reyez

/// Monica Reyez: Clawd with long dark hair parted in the middle and falling past her shoulders, a brown leather jacket
/// over a dark top, a little silver pendant. In a fight, the sidearm and the flashlight. Signature: she blows a pink
/// gum bubble till it pops, then stops still: a faint shimmer passes round her, and she's felt something.
private func drawReyez(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x5E3A24), jacketD = C(0x42281A), jacketL = C(0x7E5238), top = C(0x2A2228)
    let hair = C(0x241812), hairL = C(0x3E2A1E)
    let sig = p.signature

    h14Trousers(c, leg: C(0x2A2A32), step: p.step)
    drawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: jacket))
    // The jacket open over the dark top, its collar, the pendant.
    c.rect(18, 33, 20, 5, jacket); c.rect(37, 33, 1, 5, jacketD); c.rect(18, 37, 20, 1, jacketD)
    c.rect(24, 33, 8, 5, top); c.px(27, 35, C(0xC8CCD4)); c.px(28, 35, C(0xC8CCD4))
    c.rect(22, 33, 2, 2, jacketL); c.rect(32, 33, 2, 2, jacketL)
    // The long hair: a middle parting, down past her shoulders on both sides.
    c.pattern(16, 21, [
        "......HHHHHHHHHHH.......",
        "....HHHHHHHlHHHHHHH.....",
        "...HHHHHHHHlHHHHHHHHH...",
        "..HHHHHHHHHlHHHHHHHHHH..",
        "..HHHHHhHHHlHHHHhHHHHH..",
        ".HHHHHH........HHHHHHHH.",
        ".HHHH..............HHHH.",
        ".HHH................HHH.",
        ".HHh................hHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHh................hHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        "..HH................HH..",
        "..H..................H..",
    ], ["H": hair, "l": hairL, "h": hairL])

    if let s = sig, s > 0.05, s < 0.95 {
        if s < 0.5 {
            // The bubble at her lips, swelling, then a pop of pink bits.
            let k = (s - 0.05) / 0.4
            if k < 0.9 {
                let r = 1 + Int(k * 4)
                c.circle(29, 33, r, C(0xF7A8D0)); c.px(29 - r / 2, 33 - r / 2, C(0xFFE0F0))
            } else {
                for (dx, dy) in [(-3, -2), (3, -2), (-4, 1), (4, 1), (0, -4)] { c.px(29 + dx, 33 + dy, C(0xF7A8D0)) }
            }
        } else {
            // The shimmer: pale violet motes turning round her.
            let k = (s - 0.5) / 0.45
            for i in 0..<7 {
                let a = Double(i) / 7 * 2 * .pi + k * 4
                c.px(28 + Int(cos(a) * 15), 31 + Int(sin(a) * 9), C(0xD8C8FF, 0.8 * sin(k * .pi)))
            }
        }
        c.rect(15, 33, 3, 3, jacket)
        c.rect(38, 33, 3, 3, jacket); c.rect(38, 35, 3, 1, clawdOrange)
        return
    }
    c.rect(15, 33, 3, 3, jacket)
    c.oy += p.gunY
    drawSidearm(c, sleeve: jacket, searching: p.ready || p.fire != nil)
}

// MARK: - Agent Einstine

/// Agent Einstine: Clawd with sleek blonde hair to the jaw, swept off her forehead, a pale grey trouser suit and a
/// white blouse; a sceptic's flat stare. In a fight, the sidearm and the flashlight. Signature: she folds her arms
/// and gives you the look, one foot tapping.
private func drawEinstine(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0xA4A8B2), suitD = C(0x80848E), suitL = C(0xC0C4CC), blouse = C(0xF4F2EE)
    let hair = C(0xE8C878), hairL = C(0xF6E2A8), hairD = C(0xC4A256)
    let sig = p.signature
    let folded = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    h14Trousers(c, leg: suit, step: p.step)
    if folded && !seatedPose {
        // One foot tapping.
        let up = Int(p.t * 6) % 2 == 0
        for (i, lx) in [19, 23, 31, 35].enumerated() { c.rect(lx, i == 3 && up ? 41 : 42, 2, 2, C(0x18181C)) }
    } else {
        drawDressShoes(c, step: p.step)
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    // The flat, unimpressed stare: lids halfway down over the eyes.
    c.rect(22, 29, 2, 1, clawdShade); c.rect(32, 29, 2, 1, clawdShade)
    // The suit and the blouse's collar.
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(24, 33, ["lBBBBl", ".lBBl.", "..BB..", "......"], ["l": suitL, "B": blouse])
    // The hair: swept back off the forehead, sleek to the jaw.
    c.pattern(16, 21, [
        ".......HHHHHHHHH........",
        ".....HHHHHHHHHHHHHH.....",
        "...HHlHHHHHHHHHHHlHHH...",
        "..HHHHHlHHHHHHHlHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHH..",
        ".HHHHH............HHHHH.",
        ".HHH................HHH.",
        ".HHd................dHH.",
        ".HHH................HHH.",
        ".HHd................dHH.",
        "..HH................HH..",
    ], ["H": hair, "l": hairL, "d": hairD])

    if folded {
        // Arms folded across her front: one forearm over the other, lighter on top, each hand tucked at the far elbow,
        // the elbows standing out at her sides.
        c.rect(16, 33, 3, 4, suit); c.rect(37, 33, 3, 4, suit)          // the elbows
        c.rect(19, 35, 18, 2, suit); c.rect(19, 37, 18, 1, suitD)       // the lower forearm
        c.rect(33, 35, 3, 2, clawdOrange)                                 // its hand, under the far elbow
        c.rect(19, 33, 18, 2, suitL); c.rect(19, 34, 18, 1, suitD)      // the upper forearm, over it
        c.rect(20, 33, 3, 2, clawdOrange)                                 // its hand
        c.px(23, 33, suitD); c.px(32, 35, suitD)                          // the cuffs
        return
    }
    c.rect(15, 33, 3, 3, suit)
    c.oy += p.gunY
    drawSidearm(c, sleeve: suit, searching: p.ready || p.fire != nil)
}

// MARK: - Agent Millar

/// Agent Millar: Clawd young and eager, light brown hair neatly combed with a side parting and a quiff at the front, a
/// bright blue suit, white shirt and a navy tie. In a fight, the sidearm and the flashlight. Signature: he flips open
/// a laptop and taps away, the screen's glow on his face.
private func drawMillar(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x2E5CA8), suitD = C(0x204482), suitL = C(0x4A7AC8), shirt = C(0xF0F0EC), tie = C(0x1A2440)
    let hair = C(0x8A5E36), hairL = C(0xA87A4A), hairD = C(0x6A4628)
    let sig = p.signature
    let laptop = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    h14Trousers(c, leg: suit, step: p.step)
    drawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    // The suit, shirt and tie.
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(24, 33, ["lSTTSl", ".lTTl.", "..TT..", "..TT.."], ["l": suitL, "S": shirt, "T": tie])
    // The hair: neat, a side parting, a little quiff up at the front.
    c.pattern(17, 20, [
        "............ll........",
        "......HHHHHHHHHH......",
        "....HHHHHHHHHHlHHH....",
        "...HHHdHHHHHHHHlHHH...",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHH..............HHH.",
        ".HH................HH.",
    ], ["H": hair, "l": hairL, "d": hairD])

    if laptop {
        // The laptop held open in front of him, the screen lit, his fingers tapping.
        let open = min(1, (sig! - 0.06) / 0.1)
        c.rect(15, 33, 3, 3, suit); c.rect(38, 33, 3, 3, suit)
        c.rect(36, 35, 12, 2, C(0xB8BCC4)); c.rect(36, 36, 12, 1, C(0x8A8E98))
        if open >= 1 {
            c.rect(46, 26, 2, 10, C(0x8A8E98)); c.rect(47, 27, 1, 8, C(0x9AD0FF))
            c.rect(31, 31, 4, 1, C(0x9AD0FF, 0.35))   // the glow on his face
            c.px(Int(p.t * 8) % 2 == 0 ? 40 : 43, 34, clawdOrange)
        } else {
            c.rect(36, 34, 12, 1, C(0x8A8E98))
        }
        return
    }
    c.rect(15, 33, 3, 3, suit)
    c.oy += p.gunY
    drawSidearm(c, sleeve: suit, searching: p.ready || p.fire != nil)
}
