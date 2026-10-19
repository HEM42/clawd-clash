import Foundation

// Heroes: the Party. Clawd in costume like every other cast: hair and clothes drawn over the blocky body, with Clawd's
// own orange face showing. They're kids, so most of them don't fight: they run, point and cheer, and Eleven does the
// fighting for them.

let hawkinsHeroes1: [HawkinsHero: Persona] = [
    .eleven: Persona(name: "Eleven", weapon: .lightning,
                     magic: Magic(core: C(0xFFE4E4), glow: C(0xE86A7A), jagged: false, waves: true),
                     headTop: 24, signature: 3.4, callout: "Friends don't lie.", draw: drawEleven),
    .mikeWheeler: Persona(name: "Mike Wheeler", headTop: 20, signature: 3.0, callout: "Over.", draw: drawMikeWheeler),
    .dustinHenderson: Persona(name: "Dustin Henderson", headTop: 18, signature: 3.6, callout: "Suzie, do you copy?",
                              draw: drawDustinHenderson),
]

// MARK: - Eleven

/// Eleven, as she was in season 1: a buzz cut grown out a little, a pink dress with a white Peter Pan collar under a
/// navy zip jacket, white tube socks with a blue stripe and grey sneakers. Her telekinesis is pale red waves pulsing
/// out of her raised hand. Signature: she munches an Eggo, bite by bite, then her nose bleeds a little and she wipes
/// it with the back of her hand.
private func drawEleven(_ c: PixelCanvas, _ p: Pose) {
    let dress = C(0xE48CA8), dressD = C(0xBE6A86), dressL = C(0xF4B4C8)
    let jacket = C(0x2E4C80), jacketD = C(0x1E3460), jacketL = C(0x4C6CA4)
    let collar = C(0xF2EEE6), collarD = C(0xCFC8BC)
    let hair = C(0x4E3A2C), hairD = C(0x33241A), hairL = C(0x6E5644)
    let sock = C(0xF0EEE8), sockD = C(0xC8C4BC), stripe = C(0x3E64A8), shoe = C(0x6A6E7C)
    // The signature: the Eggo up at her mouth for the first half, then the nosebleed, then the wipe.
    let eat = p.signature.map { $0 > 0.06 && $0 < 0.58 ? ($0 - 0.06) / 0.52 : -1 } ?? -1
    let bleed = p.signature.map { $0 > 0.6 && $0 < 0.95 ? ($0 - 0.6) / 0.35 : -1 } ?? -1
    let wiping = bleed > 0.68

    // Her legs bare under the dress, the tube socks pulled up with a blue stripe round the top, grey sneakers.
    drawLegs(c, Look(leg: clawdOrange), step: p.step)
    drawBoots(c, sock, step: p.step, rows: 3)
    drawBoots(c, shoe, step: p.step, rows: 1)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let bottom = p.step >= 0 && i % 2 == p.step ? 42 : 43
            c.rect(lx, bottom - 2, 2, 1, stripe); c.px(lx + 1, bottom - 1, sockD)
        }
    }

    c.oy += p.breathe
    let arm = eat >= 0 ? 4 : wiping ? 3 : p.armRaise
    drawBody(c, Look(arm: jacket), armRight: arm)

    // The dress: the bodice between the open jacket, a fold or two, and the skirt falling over the tops of her legs,
    // its hem in shade between them, so all four legs still show below it.
    c.rect(18, 33, 20, 5, dress)
    c.px(24, 34, dressL); c.px(24, 35, dressL); c.px(26, 36, dressD); c.px(29, 36, dressD)
    if seatedPose {
        c.rect(17, 38, 22, 1, dress)
    } else {
        c.rect(17, 38, 22, 1, dress); c.px(17, 38, dressL)
        c.rect(16, 39, 24, 1, dressD)
        for x in [19, 23, 31, 35] { c.rect(x, 39, 2, 1, dress) }
    }
    // The white collar, two round flaps at her throat.
    c.pattern(24, 33, ["CCC..CCC", ".Cc..cC."], ["C": collar, "c": collarD])
    // The navy jacket, open down the front: its zip edges lit and shaded, the far side and the hem darker, a pocket.
    c.rect(18, 33, 6, 5, jacket); c.rect(32, 33, 6, 5, jacket)
    c.rect(18, 33, 1, 5, jacketL); c.rect(19, 33, 4, 1, jacketL); c.rect(33, 33, 3, 1, jacketL)
    c.rect(23, 34, 1, 4, jacketL); c.rect(32, 34, 1, 4, jacketD)
    c.rect(37, 33, 1, 5, jacketD); c.rect(18, 37, 6, 1, jacketD); c.rect(32, 37, 6, 1, jacketD)
    c.rect(20, 36, 2, 1, jacketD); c.rect(34, 36, 2, 1, jacketD)
    c.rect(15, 35, 3, 1, jacketD)   // the cuff

    // The buzz cut, grown out to a short dark fuzz: strokes across the top of her head, a lit run on the left, and a
    // little lower at her temples.
    c.pattern(18, 23, [
        "....HHHHHHHHHHHH....",
        "..HHlHHlHHHhHHHhHH..",
        ".HlHHhHHlHHHhHHHhHH.",
        "HHHhHHHhHHHhHHHHhHhH",
        "Hh................hH",
    ], ["H": hair, "h": hairD, "l": hairL])

    // The nosebleed: a thin red line running down from between her eyes, then wiped away.
    if bleed >= 0 && !wiping {
        let len = 1 + min(2, Int(bleed / 0.45 * 3))
        c.rect(28, 31, 1, len, C(0x9C1424)); c.px(28, 31, C(0xC02A34))
    }
    if wiping {
        // The back of her hand across her face, the jacket's cuff under it.
        c.rect(30, 31, 5, 2, clawdOrange); c.rect(30, 32, 5, 1, clawdShade); c.rect(35, 31, 3, 2, jacket)
    }

    guard eat >= 0 else { return }
    // The Eggo, held up at her mouth, a bite gone from it each time she munches.
    let bites = min(3, Int(eat * 4))
    var rows = [".WWWW.", "WgWgWW", "WWWWWW", "WgWgWW", "WWWWWW", ".WWWW."]
    for b in 0..<bites {
        for r in (1 + b % 2)...(3 + b % 2) where r < rows.count {
            var row = Array(rows[r]); for k in 0...min(5, b + 1) { row[k] = "." }; rows[r] = String(row)
        }
    }
    c.pattern(36, 26, rows, ["W": C(0xD8A048), "g": C(0xA87028)])
    c.rect(37, 26, 3, 1, C(0xF0C870))
    c.rect(38, 32, 2, 1, clawdOrange)   // her fingers under it
}

// MARK: - Mike Wheeler

/// Mike Wheeler: a dark, shaggy mop of hair with a fringe down to his eyebrows, a cream shirt with a red and a navy
/// stripe across it and a little collar, a brown belt, jeans and white sneakers, his walkie-talkie clipped to his belt.
/// He doesn't fight. Signature: he lifts the walkie-talkie to his mouth, its aerial up, and talks into it, the static
/// crackling out of the grille.
private func drawMikeWheeler(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0xE6DCC6), shirtD = C(0xC4B89E), red = C(0xB03C34), redD = C(0x86281F), navy = C(0x2C3C66), navyD = C(0x1E2A4A)
    let jeans = C(0x3E5680), jeansD = C(0x2C3E60), belt = C(0x5A3A22)
    let hair = C(0x241A16), hairD = C(0x120C0A), hairL = C(0x4A3A30)
    let talk = p.signature.map { $0 > 0.08 && $0 < 0.9 ? ($0 - 0.08) / 0.82 : -1 } ?? -1

    drawLegs(c, Look(leg: jeans), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let bottom = p.step >= 0 && i % 2 == p.step ? 42 : 43
            c.px(lx + 1, bottom - 4, jeansD)   // a crease at the knee
        }
    }
    drawBoots(c, C(0xE4E4DE), step: p.step, rows: 2)
    drawBoots(c, C(0xA8A8B2), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: shirt), armRight: talk >= 0 ? 6 : 0)

    // The shirt: cream with a red and a navy stripe across it and down the sleeves, the far side in shade, a little
    // collar with its placket, and the belt with its buckle.
    c.rect(18, 33, 20, 4, shirt)
    c.rect(18, 34, 20, 1, red); c.rect(18, 36, 20, 1, navy)
    c.rect(37, 33, 1, 4, shirtD); c.px(37, 34, redD); c.px(37, 36, navyD)
    c.pattern(24, 33, ["dd..dd", "..dd.."], ["d": shirtD])
    c.px(27, 35, shirtD)
    c.rect(18, 37, 20, 1, belt); c.rect(27, 37, 2, 1, C(0xC8C8CC))
    c.px(15, 34, red); c.px(16, 34, red); c.px(17, 34, red)   // the far sleeve's stripe
    if talk < 0 { c.rect(38, 34, 3, 1, red) }

    // The mop: thick, dark and straight, combed down in strands from the crown, a fringe to his brows, over his ears.
    c.pattern(16, 20, [
        ".....HHHHHHHHHHHH.......",
        "...HHHlllHHHHHHHHHH.....",
        "..HHlllHHHHhHHHHhHHH....",
        ".HHlHHHhHHHhHHHHhHHHH...",
        ".HHHHhHHhHHHhHHHhHHHhH..",
        ".HHHhHHHhHHHhHHHHhHHhH..",
        "HHHHhHHHhHHHHhHHHhHHHHH.",
        "HHHh.HHh.HHHh.HHHh.HHHH.",
        "HHH.................HHH.",
        ".HH.................hH..",
    ], ["H": hair, "h": hairD, "l": hairL])

    if talk < 0 {
        // The walkie-talkie clipped to his belt at the hip, its stubby aerial up over his shirt.
        mikeWalkie(c, x: 33, y: 32, aerial: 2)
        return
    }
    // Up at his mouth, the aerial pulled up, and the static crackling out in little arcs.
    mikeWalkie(c, x: 39, y: 22, aerial: 7)
    c.rect(39, 29, 3, 2, clawdOrange)   // his fingers round it
    let on = Int(p.t * 6) % 2 == 0
    if talk > 0.15 && talk < 0.9 {
        let a = on ? 0.7 : 0.4
        c.px(45, 23, C(0xF4F0E0, a)); c.px(46, 24, C(0xF4F0E0, a)); c.px(46, 25, C(0xF4F0E0, a)); c.px(45, 26, C(0xF4F0E0, a))
        if on { c.px(48, 23, C(0xF4F0E0, 0.3)); c.px(48, 24, C(0xF4F0E0, 0.3)); c.px(48, 25, C(0xF4F0E0, 0.3)); c.px(48, 26, C(0xF4F0E0, 0.3)) }
    }
}

/// Mike's walkie-talkie, a little black box: the grille, a red light, and its aerial `aerial` pixels up from the top.
private func mikeWalkie(_ c: PixelCanvas, x: Int, y: Int, aerial: Int) {
    c.rect(x + 1, y - aerial, 1, aerial, C(0x2A2A2E)); c.px(x + 1, y - aerial, C(0x5A5A62))
    c.pattern(x, y, ["KKKK", "KggK", "KggK", "KKKK", "KrKK", "KKKK"],
              ["K": C(0x26262A), "g": C(0x55555E), "r": C(0xE03A3A)])
    c.rect(x, y, 4, 1, C(0x44444C))
}

// MARK: - Dustin Henderson

/// Dustin Henderson: a trucker cap, white at the front with a little blue and red badge and navy round the back, its
/// peak forward, his brown curls bursting out from under it, and the grin with his front teeth missing. A white raglan
/// tee with navy sleeves and an iron-on on the chest, brown cords and blue sneakers. He doesn't fight. Signature: Cerebro's
/// radio: he lifts a chunky radio, pulls its aerial up as high as it goes and calls Suzie, the signal pulsing off the
/// tip, then pushes it back down.
private func drawDustinHenderson(_ c: PixelCanvas, _ p: Pose) {
    let tee = C(0xEEEAE0), teeD = C(0xCCC6B8), navy = C(0x2A3A6A), navyD = C(0x1C2850)
    let cords = C(0x7E6040), cordsD = C(0x5E4630)
    let hair = C(0x6A4428), hairD = C(0x4A2E18), hairL = C(0x8E6238)
    let cap = C(0x2A3E78), capD = C(0x1C2A56), capL = C(0x4058A0), front = C(0xF0ECE2), frontD = C(0xCFC8BA)
    let call = p.signature.map { $0 > 0.06 && $0 < 0.94 ? ($0 - 0.06) / 0.88 : -1 } ?? -1

    // Brown cords, a crease at each knee, and blue sneakers with white soles.
    drawLegs(c, Look(leg: cords), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let bottom = p.step >= 0 && i % 2 == p.step ? 42 : 43
            c.px(lx + 1, bottom - 4, cordsD)
        }
    }
    drawBoots(c, C(0x4A5A8E), step: p.step, rows: 2)
    drawBoots(c, C(0xDCDCD4), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: navy), armRight: call >= 0 ? 5 : 0)

    // The raglan tee: white, the navy sleeves running up to the neck, the far side and the hem in shade, an iron-on.
    c.rect(18, 33, 20, 5, tee)
    c.rect(18, 33, 4, 1, navy); c.rect(18, 34, 2, 1, navy); c.rect(34, 33, 4, 1, navyD); c.rect(36, 34, 2, 1, navyD)
    c.rect(37, 35, 1, 3, teeD); c.rect(18, 37, 20, 1, teeD)
    c.rect(25, 33, 6, 1, teeD)
    c.pattern(25, 35, ["rryy", "bbbb"], ["r": C(0xD04030), "y": C(0xF0C040), "b": C(0x3A6AB0)])
    c.rect(15, 35, 3, 1, navyD)

    // The grin, with the gap where his front teeth should be.
    c.pattern(24, 32, ["mWW..WWm", ".mmmmmm."], ["m": C(0x5A1A1E), "W": C(0xF4F0E6)])
    c.rect(27, 32, 2, 1, C(0x5A1A1E))

    // The curls bursting out under the cap: a fringe of them along his brow and a bush at the back of his head,
    // little round strokes lit on top.
    c.pattern(14, 24, [
        "..HHlHhHlHhHlHhHlHhHlH..",
        ".HlHHhHHhHHhHHhHHhHHhHH.",
        "HHhHlH..............hHH.",
        "HlHHhH..................",
        ".HhHHh..................",
        "..hHh...................",
    ], ["H": hair, "h": hairD, "l": hairL])
    // The cap: navy mesh round the back, the white foam front with its little badge, a seam, and the peak forward.
    c.pattern(17, 17, [
        "......NNNNNNNN........",
        "....NNlFFFFFFNNN......",
        "...NlFFFFFFFFFFNN.....",
        "..NNFFFrrbbFFFFFNN....",
        "..NNFFFrrbbFFFFfNN....",
        ".NNNFFFFFFFFFFffNNN...",
        ".BBBBBBBBBBBBBBBBBBpppp",
        "...................PPPPP",
    ], ["N": cap, "l": capL, "F": front, "f": frontD, "r": C(0xD03A2A), "b": C(0x3A6AB0), "B": capD, "P": capD, "p": capL])

    guard call >= 0 else { return }
    // The radio: up by his face, a chunky beige box with its dial and grille, and the aerial sliding up out of it,
    // the signal pulsing off the tip while he calls.
    let up = call < 0.2 ? call / 0.2 : call > 0.85 ? (1 - call) / 0.15 : 1
    let aerial = 2 + Int((up * 12).rounded())
    c.rect(42, 23 - aerial, 1, aerial, C(0xB8BCC4)); c.px(42, 23 - aerial, C(0xE8ECF0))
    c.pattern(38, 23, ["BBBBBB", "BkBggB", "BBBggB", "BdBggB", "BBBBBB", "BBBBBB"],
              ["B": C(0xB8AE96), "k": C(0x3A3A3A), "g": C(0x6E6658), "d": C(0xE04A3A)])
    c.rect(38, 23, 6, 1, C(0xD4CCB4)); c.rect(43, 24, 1, 5, C(0x8E846E))
    c.rect(38, 29, 3, 2, clawdOrange)
    if up >= 1 && Int(p.t * 4) % 2 == 0 {
        let ty = 23 - aerial
        for (dx, dy) in [(-3, -1), (-3, 0), (-3, 1), (3, -1), (3, 0), (3, 1), (-2, -2), (2, -2)] {
            c.px(42 + dx, ty + dy, C(0xFFE07A, 0.6))
        }
    }
}
