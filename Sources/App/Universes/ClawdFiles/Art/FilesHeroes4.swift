import Foundation

// Heroes: the informants and the lost. Mister X, Marita, Gibson Prays and Samantha Clawder. The grown-ups are Clawd in
// costume like the rest of the cast; the two children are a smaller Clawd on short legs, like Kid Lokee.

let filesHeroes4: [FilesHero: Persona] = [
    .misterX: Persona(name: "Mister X", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                      headTop: 18, signature: 3.4, callout: "You're looking in the wrong place.",
                      draw: drawMisterX),
    .marita: Persona(name: "Marita Covarrubyass", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                     headTop: 20, signature: 2.8, callout: "I answer to the United Nations.",
                     draw: drawMarita),
    .gibsonPrays: Persona(name: "Gibson Prays", weapon: .lightning,
                          magic: Magic(core: C(0xF0E8FF), glow: C(0x9A7AFF), jagged: false),
                          pivot: (35.5, 31.5), headTop: 25, signature: 3.2, callout: "I know what you're thinking.",
                          draw: drawGibsonPrays),
    .samantha: Persona(name: "Samantha Clawder", weapon: .none, headTop: 24, signature: 3.6, callout: "Fox? Is that you?",
                       draw: drawSamantha),
]

// MARK: - Shared bits

/// A child: a 14×9 Clawd on short legs, the body at (21, 30), like Kid Lokee. Draws the legs in `leg` with `shoe` feet,
/// applies the breathing bob, and draws the body; the caller dresses it.
private func drawChildBody(_ c: PixelCanvas, _ p: Pose, leg: Px, shoe: Px) {
    if seatedPose {
        for lx in [22, 25, 30, 33] { c.rect(lx - 1, 37, 3, 2, leg) }
    } else {
        for (i, lx) in [22, 25, 30, 33].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, 39, 2, lifted ? 3 : 4, leg)
            c.rect(lx, lifted ? 41 : 42, 2, 1, shoe)
        }
    }
    c.oy += p.breathe
    c.rect(21, 30, 14, 9, clawdOrange)
    c.rect(21, 38, 14, 1, clawdShade); c.rect(34, 30, 1, 9, clawdShade)
}

// MARK: - Mister X

/// Mister X: a tall Clawd, his body a head taller than the others, shaved bald, in a long black overcoat with the collar
/// turned up over a black suit. He fires a pistol. Signature: a window pane appears beside him and he presses a strip
/// of white tape across it, then a second one: the X that means he wants a meeting.
private func drawMisterX(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x1E1E22), coatD = C(0x121215), coatL = C(0x34343A)
    let shirt = C(0xE8E6E0), tie = C(0x2A2A30)
    let sig = p.signature
    let taping = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false

    if let s = sig, taping {
        // The window: a pane of night blue in a pale frame, the tape going on strip by strip.
        let fade = min(1, (s - 0.05) / 0.08, (0.95 - s) / 0.08)
        c.rect(44, 14, 14, 18, C(0xD8D4C8, fade)); c.rect(45, 15, 12, 16, C(0x1E2E4A, fade))
        c.rect(50, 15, 1, 16, C(0xD8D4C8, fade)); c.rect(45, 22, 12, 1, C(0xD8D4C8, fade))
        let tape = C(0xF4F2EA, fade)
        let first = min(1, max(0, (s - 0.18) / 0.25)), second = min(1, max(0, (s - 0.48) / 0.25))
        for i in 0..<Int(first * 12) { c.px(45 + i, 16 + i * 14 / 12, tape); c.px(46 + i, 16 + i * 14 / 12, tape) }
        for i in 0..<Int(second * 12) { c.px(56 - i, 16 + i * 14 / 12, tape); c.px(55 - i, 16 + i * 14 / 12, tape) }
    }
    // The coat's long tails over black trousers.
    let tails = seatedPose ? 1 : 4
    drawLegs(c, Look(leg: C(0x18181C)), step: p.step)
    drawDressShoes(c, step: p.step)
    c.rect(17, 38, 22, tails, coat); c.rect(17, 37 + tails, 22, 1, coatD); c.rect(28, 38, 1, tails, coatD)
    c.oy += p.breathe
    // A taller body: the head rises four rows above plain Clawd's.
    c.rect(18, 22, 20, 16, clawdOrange); c.rect(37, 22, 1, 16, clawdShade)
    c.rect(19, 22, 18, 1, C(0xC8664A))   // the shaved scalp catching the light
    c.rect(22, 26, 2, 3, ink); c.rect(32, 26, 2, 3, ink)
    c.rect(21, 25, 4, 1, C(0x8A3E28)); c.rect(31, 25, 4, 1, C(0x8A3E28))   // a level, unsmiling brow
    // Suit, white shirt, dark tie; the coat over it with its collar turned up.
    c.rect(18, 32, 20, 6, C(0x26262C))
    c.pattern(25, 32, ["lSTTSl", ".lTTl.", "..TT..", "..TT..", "..TT.."], ["l": coatD, "S": shirt, "T": tie])
    c.rect(18, 31, 5, 7, coat); c.rect(33, 31, 5, 7, coat); c.rect(37, 31, 1, 7, coatD)
    c.rect(17, 29, 3, 4, coatL); c.rect(36, 29, 3, 4, coatL)   // the turned-up collar
    c.rect(18, 37, 20, 1, coatD)
    c.rect(15, 33, 3, 3, coat)
    if taping {
        // His arm up at the pane, pressing the tape down.
        let s = sig!, k = s < 0.48 ? (s - 0.18) / 0.25 : (s - 0.48) / 0.25
        let reach = max(0, min(1, k))
        c.rect(38, 28 - Int(reach * 6), 3, 3, coat); c.rect(41, 28 - Int(reach * 6), 3, 2, coat)
        c.px(44, 28 - Int(reach * 6), clawdOrange)
        return
    }
    c.oy += p.gunY
    drawSidearm(c, sleeve: coat, searching: false)
}

// MARK: - Marita Covarrubyass

/// Marita Covarrubyass: Clawd with straight blonde hair to the shoulders, parted in the middle, in a pale grey-blue
/// United Nations skirt suit over a white blouse, a small UN pin at the lapel, and dark heels. She fires a pistol.
/// Signature: a cool glance back over her shoulder, her hair swinging, her eyes on whoever's behind her.
private func drawMarita(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x8A9AB0), suitD = C(0x6A7A90), suitL = C(0xA8B6C8), blouse = C(0xF2F0EA)
    let hair = C(0xE8D07A), hairL = C(0xF6E6A8), hairD = C(0xB89A48)
    let sig = p.signature
    let glance = sig.map { $0 > 0.15 && $0 < 0.85 } ?? false
    let swing = glance ? -1 : 0

    // Legs below the skirt, dark heels.
    drawLegs(c, Look(leg: C(0xD8A890)), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0x2A2028))
    c.rect(17, 38, 22, seatedPose ? 1 : 2, suit); c.rect(17, seatedPose ? 38 : 39, 22, 1, suitD)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit, eye: nil))
    // The eyes: straight ahead, or slid hard to the back as she glances over her shoulder.
    if glance { c.rect(19, 29, 2, 3, ink); c.rect(29, 29, 2, 3, ink) } else { c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink) }
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD)
    c.pattern(25, 33, ["BBBBBB", ".BBBB.", "..BB.."], ["B": blouse])
    c.rect(20, 33, 2, 4, suitL); c.rect(34, 33, 2, 4, suitL)   // the lapels
    c.px(21, 34, C(0x4A8AD8))   // the UN pin
    c.rect(18, 37, 20, 1, suitD)
    // The hair: centre parting, straight down to the shoulders.
    c.pattern(16 + swing, 20, [
        "......HHHHHHHHHHH.......",
        "....HHHHHHHHlHHHHHH.....",
        "..HHHHHHHHHHlHHHHHHHH...",
        ".HHHHLHHHHHHdHHHHHLHHH..",
        ".HHHHHHHHHH...HHHHHHHHH.",
        ".HHHHHHHHHHH.HHHHHHHHHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHd................dHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHd................dHH.",
        "..Hd................dH..",
        "..d..................d..",
    ], ["H": hair, "L": hairL, "l": hairL, "d": hairD])
    c.rect(15, 33, 3, 3, suit)
    c.oy += p.gunY
    drawSidearm(c, sleeve: suit, searching: false)
}

// MARK: - Gibson Prays

/// Gibson Prays: a boy, a small Clawd on short legs, with short dark hair, big round glasses and a striped T-shirt over
/// jeans. He reads minds: a soft lavender ray from his forehead. Signature: a little chessboard floats up beside him
/// and a pawn rises off it, glides two squares and settles, without him laying a finger on it.
private func drawGibsonPrays(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0x3A6AA8), stripe = C(0xE8E6E0), jeans = C(0x3A4A6A), hair = C(0x2A1E16)
    let frame = C(0x8A6A3A)
    let sig = p.signature

    if let s = sig, s > 0.05, s < 0.95 {
        // The board, and the pawn moving across it on its own.
        let fade = min(1, (s - 0.05) / 0.08, (0.95 - s) / 0.08)
        for row in 0..<2 {
            for col in 0..<6 {
                c.rect(40 + col * 2, 40 + row, 2, 1, (row + col) % 2 == 0 ? C(0xE8E0CC, fade) : C(0x5A3E26, fade))
            }
        }
        let k = min(1, max(0, (s - 0.25) / 0.45))
        let px = 41 + Int(k * 4), lift = Int(sin(k * .pi) * 4)
        c.pattern(px, 35 - lift, [".K.", "KKK", ".K.", "KKK"], ["K": C(0x1E1E22, fade)])
        if k > 0, k < 1 { c.px(px + 1, 33 - lift, C(0xC8B8FF, 0.7 * fade)) }   // the shimmer of his mind on it
    }
    drawChildBody(c, p, leg: jeans, shoe: C(0xE8E6E0))
    // The striped T-shirt.
    c.rect(21, 35, 14, 3, shirt); c.rect(21, 36, 14, 1, stripe); c.rect(21, 37, 14, 1, C(0x2A5088))
    c.rect(19, 35, 2, 2, shirt)
    c.rect(35, 35 - p.armRaise, 2, 2, shirt); c.px(36, 35 - p.armRaise, clawdOrange)
    // Short hair, and the big round glasses over his eyes.
    c.pattern(20, 27, [
        "...HHHHHHHHHH...",
        "..HHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHH.",
        ".HH..........HH.",
    ], ["H": hair])
    c.rect(24, 32, 2, 2, ink); c.rect(30, 32, 2, 2, ink)
    c.pattern(22, 31, ["FFFFF.FFFFF", "F...FFF...F", "F...F.F...F", "FFFFF.FFFFF"], ["F": frame])
    c.rect(23, 32, 3, 2, C(0xDFF0FF, 0.25)); c.rect(29, 32, 3, 2, C(0xDFF0FF, 0.25))
    if p.zap == true { c.px(35, 31, C(0xF0E8FF)) }   // the ray's start, at his temple
}

// MARK: - Samantha Clawder

/// Samantha Clawder: a girl, a small Clawd on short legs, with dark brown hair to her shoulders and a fringe, in
/// 1970s pyjamas, pale yellow with little orange flowers. She doesn't fight. Signature: a white beam of light comes
/// down on her from above and she rises a little inside it, glowing, then settles again.
private func drawSamantha(_ c: PixelCanvas, _ p: Pose) {
    let pj = C(0xF2E2A0), pjD = C(0xD8C47A), flower = C(0xE8843A), hair = C(0x4A2E1C), hairD = C(0x34200F)
    let sig = p.signature
    var glow = 0.0
    if let s = sig, s > 0.05, s < 0.95 {
        glow = min(1, (s - 0.05) / 0.15, (0.95 - s) / 0.15)
        // The beam, from the top of the canvas down to the ground, wider at the bottom: a clear pale light, brighter
        // down its middle and at its edges, so it reads as light on a dark place as well as a light one.
        for y in 0..<44 {
            let hw: Int = 4 + y / 6
            c.rect(28 - hw, y, hw * 2, 1, C(0xE8FFF0, 0.42 * glow))
            c.px(28 - hw, y, C(0xF4FFF8, 0.7 * glow)); c.px(27 + hw, y, C(0xF4FFF8, 0.7 * glow))
        }
        c.rect(26, 0, 4, 44, C(0xFFFFFF, 0.35 * glow))
        c.oy -= Int((glow * 3).rounded())
    }
    drawChildBody(c, p, leg: pj, shoe: C(0xF4E8C8))
    // The pyjama top, with little flowers.
    c.rect(21, 35, 14, 4, pj); c.rect(21, 38, 14, 1, pjD)
    for (x, y) in [(22, 36), (26, 35), (30, 37), (33, 35), (24, 38)] { c.px(x, y, flower) }
    c.rect(27, 35, 2, 1, C(0xFFFFFF))   // the collar
    c.rect(19, 35, 2, 2, pj); c.rect(35, 35, 2, 2, pj)
    // Hair: a straight fringe, down past her ears.
    c.pattern(19, 27, [
        "...HHHHHHHHHHH....",
        "..HHHHHHHHHHHHH...",
        ".HHHHHHHHHHHHHHH..",
        ".HHHdHHHdHHHdHHH..",
        ".HH...........HH..",
        ".HH...........HH..",
        ".Hd...........dH..",
        ".H.............H..",
    ], ["H": hair, "d": hairD])
    c.rect(24, 32, 2, 2, ink); c.rect(30, 32, 2, 2, ink)
    if glow > 0 {
        // She glows: light catching the top of her hair and her shoulders, and a ring of it round her feet (not a
        // wash over her, which hid her face).
        let rim: Px = C(0xF4FFF8, 0.85 * glow)
        c.rect(23, 27, 10, 1, rim); c.px(22, 28, rim); c.px(33, 28, rim)
        c.rect(19, 35, 2, 1, rim); c.rect(35, 35, 2, 1, rim)
        c.ellipse(28, 43, 7, 1, C(0xE8FFF0, 0.6 * glow))
    }
}
