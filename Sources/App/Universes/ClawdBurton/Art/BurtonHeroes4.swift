import Foundation

// Heroes: Sleepy Hollow and Mars Attacks! From Sleepy Hollow: Ichabod Craine, the constable with his magnifying
// spectacles; Katrina Van Tassle and her book of charms; Young Masbeth with his father's lantern; and big Brom Van
// Bruntt. From Mars Attacks!: Richie Norriss and his Grandma Florenz with her yodelling record, President Dayle,
// Byron Wilyums the old boxer, and Professor Kessclawd, who thinks the Martians come in peace. Every one of them is
// Clawd in costume.

let burtonHeroes4: [BurtonHero: Persona] = [
    .ichabodCraine: Persona(name: "Ichabod Craine", weapon: .none, headTop: 21, signature: 4.0, callout: "Villainy!",
                            draw: drawIchabod),
    .katrinaVanTassle: Persona(name: "Katrina Van Tassle", weapon: .lightning,
                               magic: Magic(core: C(0xFFF4D0), glow: C(0xD4A645), jagged: false, touch: true),
                               pivot: raisedHand, headTop: 20, signature: 3.6, draw: drawKatrina),
    .youngMasbeth: Persona(name: "Young Masbeth", weapon: .none, headTop: 24, signature: 3.2, draw: drawMasbeth),
    .bromVanBruntt: Persona(name: "Brom Van Bruntt", weapon: .saber, pivot: bromShoulder, bulk: 2, headTop: 20,
                            signature: 3.8, draw: drawBrom),
    .richieNorriss: Persona(name: "Richie Norriss", weapon: .blaster, shot: .thrown(C(0xD8302A)), muzzle: (46, 30.5),
                            headTop: 20, signature: 3.2, draw: drawRichie),
    .grandmaFlorenz: Persona(name: "Grandma Florenz", weapon: .lightning,
                             magic: Magic(core: C(0xFFF0E0), glow: C(0xFF9EC8), jagged: false, waves: true),
                             pivot: playerSpeaker, headTop: 15, signature: 3.6, draw: drawGrandmaFlorenz),
    .presidentDayle: Persona(name: "President Dayle", weapon: .none, headTop: 21, signature: 3.8,
                             callout: "Why can't we all just get along?", draw: drawPresident),
    .byronWilyums: Persona(name: "Byron Wilyums", weapon: .saber, pivot: byronShoulder, headTop: 22, signature: 3.4,
                           draw: drawByron),
    .professorKessclawd: Persona(name: "Professor Kessclawd", weapon: .none, headTop: 20, signature: 3.2,
                                 callout: "A peaceful people.", draw: drawKessclawd),
]

/// A caster's raised right hand: Katrina's charm glows from there (raised by `armRaise`).
private let raisedHand = (x: 42.5, y: 32.5)
/// Brom's right shoulder: his fist swings from there.
private let bromShoulder = (x: 40.5, y: 33.5)
/// Byron's right shoulder: his fist swings from there.
private let byronShoulder = (x: 39.5, y: 34.5)
/// The speaker on the front of Grandma Florenz's record player: her yodelling pours out of it.
private let playerSpeaker = (x: 49.5, y: 35.5)

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// Up between `a` and `b`, held, and back down between `c` and `d`.
private func swell(_ s: Double?, _ a: Double, _ b: Double, _ c: Double, _ d: Double) -> Double {
    guard let s else { return 0 }
    return min(ramp(s, a, b), 1 - ramp(s, c, d))
}

/// Draws `art` on a layer of its own, with the canvas's offsets, and lays it over `c` faded to `alpha` (a prop
/// appearing out of nowhere, rather than sliding in from the edge).
private func fadeIn(_ c: PixelCanvas, _ alpha: Double, _ art: (PixelCanvas) -> Void) {
    guard alpha > 0 else { return }
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    c.paste(s, alpha: alpha)
    c.ox = ox; c.oy = oy; c.baseY = by
}

/// A filled ellipse round (cx, cy).
private func hmBlob(_ c: PixelCanvas, _ cx: Double, _ cy: Double, _ rx: Double, _ ry: Double, _ col: Px) {
    for y in Int((cy - ry).rounded(.down))...Int((cy + ry).rounded(.up)) {
        for x in Int((cx - rx).rounded(.down))...Int((cx + rx).rounded(.up)) {
            let dx = (Double(x) + 0.5 - cx) / rx, dy = (Double(y) + 0.5 - cy) / ry
            if dx * dx + dy * dy <= 1 { c.px(x, y, col) }
        }
    }
}

/// A fist swung along `angle` from the shoulder `s`: the sleeve out to it, the fist on its end, and faint fists where a
/// fast punch just was.
private func fistSwing(_ c: PixelCanvas, _ s: (x: Double, y: Double), angle: Double, trail: [Double], reach: Double,
                       sleeve: Px, fist: Px, size: Int) {
    let half = Double(size) / 2
    for (i, a) in trail.enumerated() {
        let e = burtonReach(s, a, reach)
        c.glowLine(e.x, e.y, e.x, e.y, core: fist.alpha(0.3 / Double(i + 1)), glow: C(0, 0), coreR: half,
                   glowR: half + 0.1)
    }
    let e = burtonReach(s, angle, reach)
    burtonLine(c, s.x, s.y, e.x, e.y, sleeve, 1.4)
    c.rect(Int((e.x - half).rounded()), Int((e.y - half).rounded()), size, size, fist)
}

// MARK: - Ichabod Craine

/// Ichabod Craine: the New York constable: Clawd with neat black hair parted in the middle, round spectacles with
/// extra magnifying lenses folded up on his brow, a black frock coat, its tails over his legs, and a white cravat. He
/// doesn't fight. Signature: he flips the magnifying lenses down, his eyes huge behind them, stares, and faints clean
/// away, stiff as a board, flat on his back; then he gets up again.
private func drawIchabod(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature
    let fall = sig.map { s in s < 0.5 ? 0 : s < 0.58 ? pow(ramp(s, 0.5, 0.58), 2) : 1 - ramp(s, 0.86, 0.95) } ?? 0
    guard fall > 0 else { drawIchabodFigure(c, p, fainted: false); return }
    // Fainting: the whole of him tips over backwards about his heels, landing a little further on.
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    drawIchabodFigure(s, p, fainted: true)
    let heel = (x: Double(18 + c.ox), y: Double(44 + c.oy + c.baseY))
    let r = s.rotated(-90 * fall, about: heel, into: c.w, c.h, at: (heel.x + 25 * fall, heel.y - 5 * fall))
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    c.paste(r)
    c.ox = ox; c.oy = oy; c.baseY = by
    if fall > 0.95 {
        // Little stars over his dizzy head on the ground.
        for i in 0..<3 {
            let a = p.t * 4 + Double(i) * 2.1
            let x = 22 + Int((cos(a) * 4).rounded()), y = 21 + Int((sin(a) * 1.5).rounded())
            c.pattern(x, y, [".Y.", "YYY", ".Y."], ["Y": C(0xFFE07A, 0.9)])
        }
    }
}

private func drawIchabodFigure(_ c: PixelCanvas, _ p: Pose, fainted: Bool) {
    let coat = C(0x1C1C24), coatD = C(0x111117), coatL = C(0x3A3A48), hair = C(0x14141A), hairL = C(0x34344A)
    let rim = C(0x8A7A50), glass = C(0xCDE4F4)
    let sig = p.signature
    let lenses = swell(sig, 0.08, 0.16, 0.95, 0.99)   // the magnifying lenses flipped down
    let staring = sig.map { $0 > 0.18 && $0 < 0.5 } ?? false

    drawLegs(c, Look(leg: C(0x2A2A30)), step: p.step)
    burtonBoots(c, step: p.step, C(0x0C0B0E), height: 2)
    c.oy += p.breathe
    // The frock coat: its tails over his legs, buttoned over the bottom of Clawd, the white cravat at his throat.
    let tails = seatedPose ? 1 : 3
    c.rect(17, 38, 22, tails, coat); c.rect(17, 37 + tails, 22, 1, coatD); c.rect(28, 38, 1, tails, coatD)
    drawBody(c, Look(arm: coat, eye: nil))
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD); c.rect(18, 37, 20, 1, coatD)
    c.pattern(25, 33, ["WWWWWW", ".WWWW.", "..WW.."], ["W": C(0xF2EEE3)])
    c.px(23, 35, coatL); c.px(23, 37, coatL); c.px(32, 35, coatL)
    // Neat black hair over the top of Clawd, parted in the middle, a blue sheen on it, its sides running down.
    c.pattern(17, 21, [
        "....HHHHHH..HHHHHH....",
        "..HHhhhhHH..HHhhhhHH..",
        ".HHHHHHHHHH.HHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHH............HHHH.",
        ".HH................HH.",
        ".H..................H.",
    ], ["H": hair, "h": hairL])
    // His eyes: ordinary, huge behind the lenses while he stares, shut when he's fainted.
    for ex in [22, 32] {
        if fainted { c.rect(ex - 1, 30, 4, 1, ink) }
        else if staring && lenses > 0.9 { c.rect(ex - 1, 28, 4, 5, ink); c.px(ex - 1, 28, C(0xFFFFFF)) }
        else { c.rect(ex, 29, 2, 3, ink) }
    }
    // The spectacles: round rims on his eyes, a bridge between them.
    c.pattern(20, 27, ["RRRRRR....RRRRRR", "R....RRRRRR....R", "R....R....R....R", "R....R....R....R",
                       "R....R....R....R", "RRRRRR....RRRRRR"], ["R": rim])
    // The magnifying lenses: folded up on his brow, or flipped down over his eyes.
    for lx in [20, 30] {
        if lenses > 0.5 {
            c.pattern(lx, 27, [".RRRR.", "RGGGGR", "RG...R", "RG...R", "RG...R", ".RRRR."],
                      ["R": rim, "G": glass.alpha(0.35)])
            c.px(lx + 1, 28, C(0xFFFFFF, 0.8))
        } else {
            c.pattern(lx + 1, 24, ["RRRR", "RGGR", "RRRR"], ["R": rim, "G": glass])
        }
    }
    // Arms: flung out stiff while he's fainted, at his sides otherwise.
    if fainted { c.rect(13, 31, 3, 3, coat); c.rect(40, 31, 3, 3, coat) }
}

// MARK: - Katrina Van Tassle

/// Katrina Van Tassle: Clawd with long pale-blonde hair falling past her shoulders, a white gown with a high lace
/// collar, its skirt over her legs, and her little book of charms in her left hand. She protects: a charm glows at her
/// fingertip, and round whoever she points at. Signature: she traces a charm in the air, a circle with an eye in it,
/// and it glows golden and fades.
private func drawKatrina(_ c: PixelCanvas, _ p: Pose) {
    let gown = C(0xF4F0E6), gownD = C(0xD2CCBE), hair = C(0xF0D890), hairL = C(0xFFF0BC), hairD = C(0xC8A858)
    let sig = p.signature
    let tracing = sig.map { $0 > 0.06 && $0 < 0.9 } ?? false

    drawLegs(c, Look(leg: clawdOrange), step: p.step)
    burtonBoots(c, step: p.step, C(0xD8D0C0), height: 1)
    c.oy += p.breathe
    // The gown: its skirt flaring over her legs, the bodice over the bottom of Clawd, lace at its neck.
    let tails = seatedPose ? 1 : 3
    for y in 38..<(38 + tails) { let hw = 11 + (y - 38); c.rect(28 - hw, y, hw * 2, 1, gown); c.px(27 + hw, y, gownD) }
    drawBody(c, Look(arm: gown))
    c.rect(18, 33, 20, 5, gown); c.rect(37, 33, 1, 5, gownD); c.rect(18, 37, 20, 1, gownD)
    c.pattern(24, 33, ["L.L.L.L.", ".L.L.L.L"], ["L": gownD]); c.px(28, 35, C(0xD4A645))
    // Long pale-blonde hair over the top of Clawd, falling down her sides.
    c.pattern(16, 20, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHlHHHHHHHHHHH...",
        "..HHHHlHHHHHHHHHlHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHH....HHHHHHHH.",
        ".HHHH..............HHHH.",
        ".HHH................HHd.",
        ".HHH................HHd.",
        ".HHd................dHd.",
        ".HHd................dHd.",
        ".HH..................Hd.",
        ".HH..................Hd.",
        ".Hd..................dd.",
        "..d...................d.",
    ], ["H": hair, "l": hairL, "d": hairD])
    // The book of charms in her left hand: brown leather, a gold sign on its cover.
    c.pattern(11, 32, ["bBBBBB", "bBGGBB", "bBGBGB", "bBBGGB", "bBBBBB", "bPPPPP"],
                  ["B": C(0x6A4428), "b": C(0x4A2E1A), "G": C(0xD4A645), "P": C(0xF0E8D4)])
    c.rect(15, 33, 3, 3, gown)
    // The right hand: tracing the charm, raised with it glowing, or at her side.
    if tracing, let s = sig {
        let k = ramp(s, 0.12, 0.5), a = -.pi / 2 + k * 2 * .pi
        let centre = (x: 53.0, y: 23.0), r = 6.5
        let tip = k < 1 ? (x: centre.x + cos(a) * r, y: centre.y + sin(a) * r)
                        : (x: centre.x - 4 + 2 * sin(p.t * 3), y: centre.y + 5)
        let hx = 38 + (tip.x - 38) * 0.42, hy = 34 + (tip.y - 34) * 0.42
        burtonLine(c, 39.5, 34, hx, hy, gown, 1.2); c.rect(Int(hx.rounded()), Int(hy.rounded()) - 1, 2, 2, clawdOrange)
        let fade = 1 - ramp(s, 0.78, 0.9), glow = s > 0.5 ? 0.6 + 0.4 * sin(ramp(s, 0.5, 0.78) * .pi) : 0.6
        let core = C(0xFFF4D0, 0.92 * fade), halo = C(0xD4A645, 0.55 * fade * glow)
        // The circle, drawn round as far as her finger has gone.
        let n = Int(k * 40)
        for i in 0..<n {
            let a0 = -.pi / 2 + Double(i) / 40 * 2 * .pi, a1 = -.pi / 2 + Double(i + 1) / 40 * 2 * .pi
            c.glowLine(centre.x + cos(a0) * r, centre.y + sin(a0) * r, centre.x + cos(a1) * r, centre.y + sin(a1) * r,
                       core: core, glow: halo, coreR: 0.5, glowR: 1.8)
        }
        // Then the eye inside it.
        let e = ramp(s, 0.5, 0.6)
        if e > 0 {
            let w = 4.0 * e
            for side in [-1.0, 1.0] {
                let mid = centre.y + side * 2.2 * e
                c.glowLine(centre.x - w, centre.y, centre.x, mid, core: core, glow: halo, coreR: 0.45, glowR: 1.5)
                c.glowLine(centre.x, mid, centre.x + w, centre.y, core: core, glow: halo, coreR: 0.45, glowR: 1.5)
            }
            c.glowLine(centre.x, centre.y, centre.x, centre.y, core: core, glow: halo, coreR: 1.0, glowR: 2.2)
        }
    } else if p.zap != nil || p.armRaise > 0 {
        let hy = 32.5 - Double(p.armRaise)
        burtonLine(c, 39.5, 34, 41.5, hy, gown, 1.2); c.rect(42, Int(hy) - 1, 2, 2, clawdOrange)
    }
}

// MARK: - Young Masbeth

/// A child: a 14×9 Clawd on short legs, the body at (21, 30), dressed in `body`; applies the breathing bob.
private func child(_ c: PixelCanvas, _ p: Pose, body: Px, shade: Px, leg: Px, shoe: Px) {
    if seatedPose {
        for lx in [22, 25, 30, 33] { c.rect(lx - 1, 37, 3, 2, leg) }
    } else {
        for (i, lx) in [22, 25, 30, 33].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, 39, 2, lifted ? 3 : 4, leg); c.rect(lx, lifted ? 41 : 42, 2, 1, shoe)
        }
    }
    c.oy += p.breathe
    c.rect(21, 30, 14, 9, body); c.rect(21, 38, 14, 1, shade); c.rect(34, 30, 1, 9, shade)
}

/// Young Masbeth: a small boy, a child-sized Clawd under a flat brown cap, tufts of hair sticking out, a brown
/// waistcoat and short trousers, and his dead father's tin lantern glowing in his hand. He doesn't fight. Signature:
/// he holds the lantern up high, brave, its light flaring.
private func drawMasbeth(_ c: PixelCanvas, _ p: Pose) {
    let vest = C(0x6A4A30), vestD = C(0x4E3420), cap = C(0x5A4E40), capD = C(0x3E342A), hair = C(0x8A5A2E)
    let up = swell(p.signature, 0.08, 0.22, 0.82, 0.95)
    child(c, p, body: clawdOrange, shade: clawdShade, leg: C(0x4A4038), shoe: C(0x1E1A16))
    // The waistcoat over the bottom of him, a white shirt at its neck.
    c.rect(21, 35, 14, 4, vest); c.rect(34, 35, 1, 4, vestD); c.rect(21, 38, 14, 1, vestD)
    c.pattern(26, 35, ["WWWW", ".WW."], ["W": C(0xF0E8D8)]); c.px(28, 37, C(0xD8B040))
    // Eyes, brows set brave while he holds the lantern up.
    c.rect(24, 31, 2, 3, ink); c.rect(30, 31, 2, 3, ink)
    if up > 0.5 { c.pattern(23, 30, ["KK....KK."], ["K": hair]); c.rect(26, 34, 4, 1, ink) }
    // The flat cap, its peak out over his brow, tufts of hair from under it.
    c.pattern(20, 25, ["...CCCCCCCC....", "..CCCCCCCCCC...", ".CCCCCCCCCCCCC.", ".ccccccccccccccc"],
              ["C": cap, "c": capD])
    c.pattern(20, 29, ["HH.........HH", "H...........H"], ["H": hair])
    // His left arm, and the lantern: hanging from his right hand, or held up high.
    c.rect(18, 34, 3, 3, vest)
    let lx = up > 0 ? 38.0 : 37.0, ly = 35.0 - up * 15
    if up > 0 { burtonLine(c, 35, 35, lx, ly - 1, vest, 1.1) } else { c.rect(35, 34, 3, 3, vest) }
    let x = Int(lx.rounded()), y = Int(ly.rounded())
    c.rect(x, y - 1, 2, 2, clawdOrange)
    c.pattern(x - 2, y + 1, ["..T..", ".TTT.", "TYYYT", "TYWYT", "TYYYT", ".TTT."],
              ["T": C(0x5A5A62), "Y": C(0xFFD050), "W": C(0xFFF6D0)])
    let flare = 0.18 + up * 0.22 + 0.04 * sin(p.t * 9)
    c.glowLine(Double(x) + 0.5, Double(y) + 4, Double(x) + 0.5, Double(y) + 4, core: C(0, 0), glow: C(0xFFD050, flare),
               coreR: 0, glowR: 4 + up * 3)
}

// MARK: - Brom Van Bruntt

/// Brom Van Bruntt: big and burly, a Clawd block a size wider and taller, dark curly hair and sideburns, a brown
/// leather coat with a thick cream sheepskin collar standing up round his shoulders, big hands. He fights with his
/// fists. Signature: he flexes both arms, then puts a carved pumpkin over his head to play the Headless Horseman.
private func drawBrom(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x6A4428), coatD = C(0x4E301C), fleece = C(0xEDE2C8), fleeceD = C(0xC8BA9A)
    let hair = C(0x2A1C14), hairL = C(0x4A3424)
    let sig = p.signature
    let flex = swell(sig, 0.06, 0.14, 0.4, 0.46)
    let pumpkin = swell(sig, 0.5, 0.62, 0.88, 0.97)   // lowered over his head

    drawLegs(c, Look(leg: C(0x4A3A30)), step: p.step)
    burtonBoots(c, step: p.step, C(0x1E1612), height: 3)
    c.oy += p.breathe
    // The big block, a column wider each side and two rows taller.
    c.rect(17, 24, 22, 14, clawdOrange); c.rect(38, 24, 1, 14, clawdShade); c.rect(17, 37, 22, 1, clawdShade)
    c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    // The coat over the bottom of him, the sheepskin collar fluffed up round its top.
    c.rect(17, 33, 22, 5, coat); c.rect(38, 33, 1, 5, coatD); c.rect(17, 37, 22, 1, coatD); c.rect(28, 34, 1, 4, coatD)
    c.pattern(15, 31, ["FF.FF..............FF.FF", "FFFFFfF..........FfFFFFf", ".FFFFFFFFFFFFFFFFFFFFFf.",
                       "..fF.fF.fF.fF.fF.fF.fF.."], ["F": fleece, "f": fleeceD])
    // Dark curly hair over the top of him, sideburns down the sides.
    c.pattern(16, 20, [
        "....HHhHHHHhHHHHhHHH....",
        "..HHHHHHHhHHHHHHHHhHHH..",
        ".HHhHHHHHHHHHhHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHH.HHHHH.HHH.HHHHH.",
        ".HHH................HHH.",
        ".HH..................HH.",
        ".HH..................HH.",
        ".HH..................HH.",
        "..H..................H..",
    ], ["H": hair, "h": hairL])
    if pumpkin > 0 {
        // The carved pumpkin coming down over his head.
        let y = 6 + Int((pumpkin * 15).rounded())
        c.pattern(18, y, [
            ".........ss.........",
            "........ss..........",
            "....OOOOOOOOOOOO....",
            "..OOOOoOOOOOoOOOOO..",
            ".OOOOOoOOOOOoOOOOOO.",
            "OOOOKKoOOOOOoKKOOOOd",
            "OOOKKKKOOOOOKKKKOOOd",
            "OOOOOoOOOKOOoOOOOOOd",
            "OOOOOoOOKKKOoOOOOOOd",
            "OOKOKoKOKOKOKOKOKOOd",
            "OOOKKKKKKKKKKKKKOOOd",
            ".OOOOoOOOOOOoOOOOOd.",
            "..OOOOOOOOOOOOOOOd..",
            "....dddddddddddd....",
        ], ["O": C(0xE87A1E), "o": C(0xC85E12), "d": C(0xA84A0E), "K": C(0x3A1A08), "s": C(0x4A6A2A)])
    }
    // Arms: flexing, a fist swinging, or at his sides.
    if flex > 0 {
        let h = Int((flex * 6).rounded())
        for (x, d) in [(12, -1), (39, 1)] {
            c.rect(x, 31 - h, 5, 4, coat); c.rect(x + (d > 0 ? 1 : 0), 27 - h, 4, 4, coat)
            c.rect(x + (d > 0 ? 1 : 0), 24 - h, 4, 3, clawdOrange)
            c.rect(x + (d > 0 ? 2 : 1), 30 - h, 2, 1, coatD)
        }
        return
    }
    c.rect(13, 32, 4, 4, coat); c.rect(13, 35, 4, 1, clawdOrange)
    if let a = p.melee {
        fistSwing(c, bromShoulder, angle: a, trail: p.trail, reach: 7, sleeve: coat, fist: clawdOrange, size: 4)
    } else {
        c.rect(39, 32, 4, 4, coat); c.rect(39, 35, 4, 1, clawdOrange)
    }
}

// MARK: - Richie Norriss

/// Richie Norriss: Clawd with a floppy mop of brown hair, in his doughnut-shop uniform: a pink shirt with a white
/// collar, a name badge and a little doughnut on the pocket. He throws vinyl records. Signature: he spins a record on
/// one finger.
private func drawRichie(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0xE88AA8), shirtD = C(0xC06A88), hair = C(0x6A4428), hairL = C(0x8A5E38), hairD = C(0x4E3018)
    let disc = C(0x16161B), label = C(0xD8302A)
    let spinning = p.signature.map { $0 > 0.08 && $0 < 0.92 } ?? false

    drawLegs(c, Look(leg: C(0x3A4A6A)), step: p.step)
    burtonBoots(c, step: p.step, C(0xF0F0F0), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: shirt))
    // The uniform shirt: a white collar, the name badge, a doughnut on the pocket.
    c.rect(18, 33, 20, 5, shirt); c.rect(37, 33, 1, 5, shirtD); c.rect(18, 37, 20, 1, shirtD)
    c.pattern(24, 33, ["DDD..DDD", ".DD..DD."], ["D": shirtD])
    c.rect(21, 35, 3, 1, C(0xF8F4F0))
    c.pattern(32, 34, [".DD.", "DPPD", ".DD."], ["D": C(0xB07A40), "P": C(0xFFC8E0)])
    // The mop of hair: thick over the top, a shaggy fringe hanging down to his brows, shaggy at the sides.
    c.pattern(16, 20, [
        "....HHHHlHHHHHlHHHH.....",
        "..HHHHlHHHHHHHHHHHlHH...",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHdHHHdHHHHdHHHHdHHHHH",
        ".HHH.HH..HH..HH..HH.HHH.",
        ".HH..H...............HH.",
        ".HH..................HH.",
        "..d..................d..",
    ], ["H": hair, "l": hairL, "d": hairD])
    // A record: spinning on his finger, raised to throw, or held at his side.
    if spinning {
        burtonLine(c, 39.5, 34, 42, 26, shirt, 1.1); c.rect(41, 23, 2, 3, clawdOrange)
        let k = frac(p.t * 3)
        hmBlob(c, 42, 20.5, 5.5, 2.5, disc); c.rect(41, 20, 3, 1, label)
        let gx = 38 + Int(k * 9)
        c.px(gx, 19 + (gx > 39 && gx < 45 ? 0 : 1), C(0x6A6A78))
        return
    }
    if p.fire != nil || p.ready || p.gunLift > 0 {
        c.oy += p.gunY
        c.rect(38, 31, 3, 3, shirt)
        hmBlob(c, 43.5, 29.5, 3.5, 3.5, disc); c.rect(43, 29, 2, 2, label); c.px(42, 27, C(0x4A4A58))
        return
    }
    hmBlob(c, 42, 37.5, 3.5, 3.5, disc); c.rect(41, 37, 2, 2, label)
}

// MARK: - Grandma Florenz

/// Grandma Florenz: Clawd under a big white-lavender bouffant, little round glasses, a dusty-rose cardigan over a
/// lace blouse, and her teal portable record player held at her side, a record on it. Her yodelling record is her
/// weapon: it pours out of the speaker in pink waves. Signature: she turns up the volume, and taps her foot and nods
/// along, notes bobbing out of the speaker.
private func drawGrandmaFlorenz(_ c: PixelCanvas, _ p: Pose) {
    let cardi = C(0xC8788E), cardiD = C(0xA05A70), hair = C(0xECE6F2), hairD = C(0xBDB4CC)
    let case_ = C(0x2E8A8A), caseD = C(0x1E6262)
    let sig = p.signature
    let turning = sig.map { $0 > 0.08 && $0 < 0.28 } ?? false
    let tapping = sig.map { $0 >= 0.28 && $0 < 0.92 } ?? false
    let beat = tapping && frac(p.t * 2.2) < 0.5

    var step = p.step
    if tapping && step < 0 && beat && !seatedPose { step = 1 }   // her front foot taps
    drawLegs(c, Look(leg: C(0xD8B8A8)), step: step)
    burtonBoots(c, step: step, C(0x6A4A3A), height: 1)
    c.oy += p.breathe + (beat ? 1 : 0)
    // The skirt over the tops of her legs, the cardigan over the bottom of Clawd, lace at the neck.
    c.rect(18, 38, 20, seatedPose ? 1 : 2, C(0x6A5A70))
    drawBody(c, Look(arm: cardi))
    c.rect(18, 33, 20, 5, cardi); c.rect(37, 33, 1, 5, cardiD); c.rect(18, 37, 20, 1, cardiD)
    c.pattern(25, 33, ["WWWWWW", ".WWWW.", "..WW.."], ["W": C(0xF4EEE6)])
    c.px(24, 35, C(0xF0E8D8)); c.px(24, 37, C(0xF0E8D8))
    // Little round glasses, and a contented smile.
    c.pattern(21, 28, [".PP.......PP.", "P..P.....P..P", "P..PPPPPPP..P", ".PP.......PP."], ["P": C(0xB8A890)])
    c.pattern(26, 32, ["K..K", ".KK."], ["K": clawdShade])
    // The big bouffant, piled high over the top of Clawd and curling down her sides.
    c.pattern(15, 15, [
        "........HHHHHHHHHH........",
        ".....HHHHHHHHHHHHHHHH.....",
        "....HHHHHdHHHHHHHdHHHH....",
        "...HHHHHHHHHHHHHHHHHHHH...",
        "..HHHHdHHHHHHHHHHHHHdHHH..",
        "..HHHHHHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHdHHHHHHHHHHHHHHHHdHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHHHd.",
        ".HHHHHHHHHHHHHHHHHHHHHHHd.",
        "..HHHH..............HHHd..",
        "..HHH................HHd..",
        "..HHd................dHd..",
        "...H..................d...",
    ], ["H": hair, "d": hairD])
    // The record player: raised a little while it plays at someone, a record turning on top, the speaker in front.
    let lift = (p.zap != nil || p.armRaise > 0) ? p.armRaise : 0
    c.oy -= lift
    c.rect(38, 33, 3, 3, cardi)
    c.pattern(40, 33, ["CCCCCCCCCC", "CSSSSSSSSd", "CSGSGSGSSd", "CSSSSSSSSd", "CSGSGSGSRd", "dddddddddd"],
              ["C": C(0x4AAAAA), "S": case_, "G": caseD, "d": caseD, "R": C(0xE84A3A)])
    let spin = Int(p.t * 8) % 3
    c.pattern(41, 31, [".KKKKKK.", "KKKKKKKK"], ["K": C(0x16161B)]); c.px(42 + spin * 2, 31, C(0x5A5A68))
    c.px(44, 32, C(0xD8302A)); c.px(45, 32, C(0xD8302A))
    c.oy += lift
    if turning, let s = sig {
        // Her right hand reaching down the front of the player to the red volume knob, turning it.
        burtonLine(c, 39.5, 34, 46, 36.5, cardi, 1.1)
        c.rect(46 + Int(ramp(s, 0.08, 0.28) * 4) % 2, 36, 2, 2, clawdOrange)
    }
    if tapping, let s = sig {
        // Notes bobbing up out of the speaker.
        for i in 0..<3 {
            let f = frac(s * 3 + Double(i) / 3)
            let x = 50 + i * 4 + Int(sin(f * 6 + Double(i)) * 1.5), y = 31 - Int(f * 14)
            c.pattern(x, y, ["..NN", "..N.", "NNN.", "NN.."], ["N": C(0xFF9EC8, min(1, 1.6 * (1 - f)))])
        }
    }
}

// MARK: - President Dayle

/// President Dayle: Clawd with dark hair combed flat from a sharp side parting, a confident grin, a dark suit, white
/// shirt and red tie, and a little flag pin on his lapel. He doesn't fight. Signature: a podium appears beside him,
/// the presidential seal on its front and a microphone on top, and he gives a speech, his fist jabbing the air.
private func drawPresident(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x262A3E), suitD = C(0x181A28), suitL = C(0x3A4058), hair = C(0x2A2420), hairL = C(0x5A4E46)
    let sig = p.signature
    let podium = swell(sig, 0.04, 0.18, 0.84, 0.97)
    let talking = sig.map { $0 > 0.2 && $0 < 0.82 } ?? false
    let jab = talking ? sin(p.t * 7) : 0

    drawLegs(c, Look(leg: suitD), step: p.step)
    burtonBoots(c, step: p.step, C(0x0C0B0E), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    // The suit, white shirt and red tie; the flag pin on his lapel.
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(25, 33, ["WWRRWW", ".WRRW.", "..RR..", "..RR.."], ["W": C(0xF4F4F0), "R": C(0xC0202A)])
    c.pattern(22, 33, ["L......L", "L......L", ".L....L."], ["L": suitL])
    c.pattern(33, 34, ["RB", "WR"], ["R": C(0xE0303A), "B": C(0x2A4AB0), "W": C(0xFFFFFF)])
    // A confident grin, mouth working while he speaks.
    if talking && frac(p.t * 4) < 0.5 { c.pattern(26, 32, ["KKKK", ".KK."], ["K": ink]) }
    else { c.pattern(25, 32, ["K....K", ".KKKK."], ["K": ink]) }
    // Dark hair combed flat from a side parting on his left, the sides neat and short.
    c.pattern(17, 21, [
        "....HHHHHHHHHHHHHH....",
        "..HHHHlHHHHHHHHHHHHH..",
        ".HHHlHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHH.HHHHHHHHHHHHHHHH.",
        ".HH.............HHHHH.",
        ".H..................H.",
    ], ["H": hair, "l": hairL])
    c.rect(21, 22, 1, 3, C(0x0E0C0A))
    fadeIn(c, podium) { s in
        // The podium: polished wood, the seal on its front, a microphone curving up from its top.
        let wood = C(0x6A4428), woodD = C(0x4A2E1A), woodL = C(0x8A5E38)
        s.rect(43, 31, 12, 2, woodL); s.rect(44, 33, 10, 11, wood); s.rect(53, 33, 1, 11, woodD)
        s.rect(42, 43, 14, 1, woodD)
        s.circle(49, 37, 3, C(0xD8B040)); s.circle(49, 37, 2, C(0x1E3A8A)); s.px(49, 37, C(0xF4F4F0))
        burtonLine(s, 45, 31, 43, 27, C(0x3A3A40), 0.5); s.rect(42, 25, 2, 2, C(0x16161B))
    }
    if podium > 0.5 {
        // His right fist jabbing the air over the podium.
        let hy = 27 + jab * 2
        burtonLine(c, 39.5, 34, 41, hy + 1, suit, 1.2); c.rect(40, Int(hy.rounded()) - 2, 3, 3, clawdOrange)
        if talking && frac(p.t * 2) < 0.6 {
            c.pattern(46, 21, ["W.W", ".W.", "..."], ["W": C(0xFFFFFF, 0.8)])
        }
    }
}

// MARK: - Byron Wilyums

/// Byron Wilyums: a big old heavyweight boxer, now greeting guests at an Egyptian-themed Las Vegas casino: a
/// dark-skinned Clawd in the casino's pharaoh get-up over its maroon uniform: a gold-and-blue striped nemes headdress,
/// a gold cobra on its brow band and its striped lappets down either side of his face, a broad collar of gold and
/// lapis over the uniform's gold braid and buttons, white gloves. He fights with his fists. Signature: he
/// shadow-boxes, quick jabs left and right, then raises his gloves high like a champion.
private func drawByron(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x8A5A3A), skinD = C(0x6A4228), coat = C(0x7A1A28), coatD = C(0x56101C), gold = C(0xE0B040)
    let goldD = C(0xB08420), goldL = C(0xFFDC70), blue = C(0x2448A8), blueD = C(0x18307A)
    let glove = C(0xF4F2EA)
    let sig = p.signature
    let boxing = sig.map { $0 > 0.06 && $0 < 0.6 } ?? false
    let champ = swell(sig, 0.6, 0.68, 0.88, 0.96)

    drawLegs(c, Look(leg: C(0x1E1A22)), step: p.step)
    burtonBoots(c, step: p.step, C(0x0C0B0E), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(body: skin, shade: skinD, arm: coat))
    // The uniform: maroon, gold braid down the front, a gold button.
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD); c.rect(18, 37, 20, 1, coatD)
    c.rect(24, 33, 1, 5, gold); c.rect(31, 33, 1, 5, gold); c.px(28, 37, gold)
    // The broad collar over it: a gold rim, a band of lapis, and a fringe of gold drops.
    c.rect(18, 33, 20, 1, gold); c.rect(18, 34, 20, 1, blue); c.rect(37, 33, 1, 2, goldD)
    c.pattern(19, 35, ["G.G.G.G.G.G.G.G.G."], ["G": gold])
    // A broken boxer's nose and a set jaw.
    c.rect(27, 30, 2, 1, skinD)
    // The nemes: gold and blue stripes over the top of him, a gold brow band with the cobra rising from it, and the
    // striped lappets down either side of his face.
    c.pattern(16, 22, [
        "......GGGGGGGGGGGG......",
        "....BBBBBBBBBBBBBBBB....",
        "...GGGGGGGGUUGGGGGGGG...",
        "..BBBBBBBBBUkBBBBBBBBB..",
        ".GGGGGGGGGGGUGGGGGGGGGd.",
        "BBBBUUUUUUUUUUUUUUUUBBBb",
        "GGGG................GGGd",
        "BBBB................BBBb",
        ".GGG................GGd.",
        "..BB................Bb..",
        "..GG................Gd..",
    ], ["G": gold, "d": goldD, "B": blue, "b": blueD, "U": goldL, "k": C(0x101014)])
    // Arms: shadow-boxing, raised like a champion, a fist swinging, or at his sides.
    if boxing {
        let jab = frac(p.t * 3.5) < 0.5
        let near = jab ? 6.0 : 2.0
        burtonLine(c, 39.5, 34, 39.5 + near, 32, coat, 1.3); c.rect(Int(39.5 + near), 30, 3, 3, glove)
        let back = jab ? 0 : 2
        burtonLine(c, 17, 34, Double(15 - back), 31, coat, 1.3); c.rect(13 - back, 29, 3, 3, glove)
        return
    }
    if champ > 0 {
        let h = 34 - champ * 13
        for (sx, hx) in [(17.0, 13.0), (39.5, 42.0)] {
            burtonLine(c, sx, 34, hx + 1, h + 2, coat, 1.3); c.rect(Int(hx), Int(h.rounded()) - 1, 3, 3, glove)
        }
        return
    }
    c.rect(15, 33, 3, 3, coat); c.rect(15, 35, 3, 1, glove)
    if let a = p.melee {
        fistSwing(c, byronShoulder, angle: a, trail: p.trail, reach: 6, sleeve: coat, fist: glove, size: 3)
    } else {
        c.rect(38, 35, 3, 1, glove)
    }
}

// MARK: - Professor Kessclawd

/// Professor Kessclawd: the President's science adviser: Clawd with grey-streaked hair swept back, a warm, trusting
/// smile, a pipe clamped in the corner of his mouth, and a brown tweed jacket over a shirt and knitted tie. He doesn't
/// fight. Signature: he takes his pipe out and points it up at the sky, towards the Martians he's sure are friendly.
private func drawKessclawd(_ c: PixelCanvas, _ p: Pose) {
    let tweed = C(0x8A7458), tweedD = C(0x6A5640), fleck = C(0xA89070), hair = C(0x34343A), hairL = C(0x8A8A92)
    let pipe = C(0x5A3A22), stem = C(0x1E1A16)
    let pointing = swell(p.signature, 0.08, 0.25, 0.8, 0.95)

    drawLegs(c, Look(leg: C(0x5A5048)), step: p.step)
    burtonBoots(c, step: p.step, C(0x3A2418), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: tweed))
    // The tweed jacket, flecked, over a pale shirt and a knitted tie.
    c.rect(18, 33, 20, 5, tweed); c.rect(37, 33, 1, 5, tweedD); c.rect(18, 37, 20, 1, tweedD)
    for y in 33...36 { for x in 18...36 where (x * 3 + y * 5) % 7 == 0 { c.px(x, y, fleck) } }
    c.pattern(25, 33, ["SSGGSS", ".SGGS.", "..GG..", "..GG.."], ["S": C(0xE8E4DA), "G": C(0x3A5A3A)])
    // The trusting smile.
    c.pattern(24, 32, ["K......K", ".KKKKKK."], ["K": ink])
    // Grey-streaked hair swept back from his brow.
    c.pattern(17, 20, [
        "..........HHHHHHHH....",
        "....HHHHHHHHHlllHHHH..",
        "..HHHlllHHHHHHHHHHHHH.",
        ".HHHHHHHHHllHHHHHHHHHH",
        ".HHHHHHHHHHHHHHHHHHHHH",
        ".HHH..............HHHH",
        ".lH................HH.",
    ], ["H": hair, "l": hairL])
    // The pipe: in his mouth, or out in his hand pointing at the sky.
    if pointing > 0 {
        let hx = 40 + pointing * 4, hy = 34 - pointing * 10
        burtonLine(c, 39.5, 34, hx, hy, tweed, 1.2)
        let (x, y) = (Int(hx.rounded()), Int(hy.rounded()))
        c.rect(x - 1, y - 1, 2, 2, clawdOrange)
        burtonLine(c, Double(x), Double(y) - 1, Double(x) + 3 * pointing, Double(y) - 1 - 4 * pointing, stem, 0.5)
        c.pattern(x - 2, y - 1, ["PP", "PP"], ["P": pipe])
        if pointing > 0.9 {
            let f = frac(p.t * 1.5)
            c.glowLine(Double(x) - 1, Double(y) - 3 - f * 5, Double(x) - 1, Double(y) - 3 - f * 5,
                       core: C(0xE8ECF0, 0.6 * (1 - f)), glow: C(0xC8CCD4, 0.3 * (1 - f)), coreR: 0.8, glowR: 1.8)
        }
        return
    }
    c.rect(33, 32, 4, 1, stem); c.pattern(36, 29, ["P.P", "PPP", "PPP"], ["P": pipe])
    let f = frac(p.lt * 0.6)
    c.glowLine(37.5 + f * 2, 28 - f * 6, 37.5 + f * 2, 28 - f * 6, core: C(0xE8ECF0, 0.5 * (1 - f)),
               glow: C(0xC8CCD4, 0.25 * (1 - f)), coreR: 0.7, glowR: 1.6)
}
