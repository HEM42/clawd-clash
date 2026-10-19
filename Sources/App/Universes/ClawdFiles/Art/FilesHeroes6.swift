import Foundation

// Heroes: allies of the X-Files. Max Fenig, Agent Pendrill, Arthur Dales, Clyde Bruckclaw, Jose Chung, Leyla Harriclaw
// and Frank Blackclaw. A UFO chaser, a lab man, a retired agent with a bat, a psychic, a writer, a fan in the Bureau and
// a man who sees too much: most of them don't carry a gun, and each wears something nobody else in the cast does.

let filesHeroes6: [FilesHero: Persona] = [
    .maxFenig: Persona(name: "Max Fenig", weapon: .none, headTop: 19, signature: 3.2, callout: "They're here. I've seen them.",
                       draw: drawMaxFenig),
    .pendrill: Persona(name: "Agent Pendrill", weapon: .none, headTop: 21, signature: 3.0, callout: "Oh! Agent Scrawly. Hi.",
                       draw: drawPendrill),
    .arthurDales: Persona(name: "Arthur Dales", weapon: .saber, headTop: 21, signature: 3.2, callout: "Back in '52…",
                          draw: drawArthurDales),
    .clydeBruckclaw: Persona(name: "Clyde Bruckclaw", weapon: .none, headTop: 18, signature: 3.4,
                             callout: "There are worse ways to go.",
                             draw: drawClydeBruckclaw),
    .joseChung: Persona(name: "Jose Chung", weapon: .none, headTop: 24, signature: 3.4,
                        callout: "Truth is as subjective as reality.",
                        draw: drawJoseChung),
    .leylaHarriclaw: Persona(name: "Leyla Harriclaw", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                             headTop: 20, signature: 3.0, callout: "I've read every one of your cases!",
                             draw: drawLeylaHarriclaw),
    .frankBlackclaw: Persona(name: "Frank Blackclaw", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                             headTop: 21, signature: 3.4, callout: "This is who we are.",
                             draw: drawFrankBlackclaw),
]

// MARK: - Shared bits

private let clear = C(0x000000, 0)

private func line(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.7) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: clear, coreR: r, glowR: r + 0.1)
}

/// The arms for someone with no weapon: hands down at the sides, or both thrown up while they cheer a fight on. With
/// `cuff`, a cuff a shade apart above each hand.
private func drawPlainArms(_ c: PixelCanvas, _ p: Pose, sleeve: Px, cuff: Px? = nil) {
    if p.cheering {
        let up = Int(p.t * 6) % 2
        c.rect(14, 28 - up, 3, 5, sleeve); c.rect(14, 26 - up, 3, 2, clawdOrange)
        c.rect(38, 28 - up, 3, 5, sleeve); c.rect(38, 26 - up, 3, 2, clawdOrange)
    } else {
        c.rect(15, 33, 3, 3, sleeve); c.rect(15, 35, 3, 1, clawdOrange)
        c.rect(38, 33, 3, 3, sleeve); c.rect(38, 35, 3, 1, clawdOrange)
        if let cuff { c.rect(15, 34, 3, 1, cuff); c.rect(38, 34, 3, 1, cuff) }
    }
}

/// Round frames over the eyes, in `frame`.
private func drawRoundGlasses(_ c: PixelCanvas, _ frame: Px) {
    for x0 in [20, 30] {
        c.pattern(x0, 27, [".FFFF.", "F....F", "F....F", "F....F", ".FFFF."], ["F": frame])
        c.rect(x0 + 1, 28, 4, 3, C(0xE8F4FF, 0.22))
    }
    c.rect(26, 29, 4, 1, frame)
}

/// A long coat's tails over the legs (shorter seated).
private func drawTails(_ c: PixelCanvas, _ coat: Px, _ dark: Px, length: Int) {
    let tails = seatedPose ? 1 : length
    c.rect(17, 38, 22, tails, coat); c.rect(17, 37 + tails, 22, 1, dark); c.rect(28, 38, 1, tails, dark)
    if !seatedPose { c.rect(22, 38, 1, 2, dark); c.rect(34, 38, 1, 2, dark) }   // folds in the tails
}

// MARK: - Max Fenig

/// Max Fenig: Clawd in a green NICAP cap with its white patch, the brim out front, long brown hair down his back, big
/// brown-framed glasses and an army-surplus jacket over a grey T-shirt. He doesn't fight. Signature: he raises his
/// camcorder to his eye and films the sky, the red REC light blinking.
private func drawMaxFenig(_ c: PixelCanvas, _ p: Pose) {
    let cap = C(0x3E5A34), capD = C(0x2A3E24), patch = C(0xEDEDE4), hair = C(0x5A3A22), hairD = C(0x3E2816)
    let jacket = C(0x6A7448), jacketD = C(0x4E5634), tee = C(0x8A8E96)
    let filming = p.signature.map { $0 > 0.08 && $0 < 0.92 } ?? false

    drawLegs(c, Look(leg: C(0x3A4A6A)), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0x4A3826))
    c.oy += p.breathe
    drawBody(c, Look(arm: jacket))
    // The jacket open over the T-shirt, its pockets.
    c.rect(18, 34, 20, 4, jacket); c.rect(37, 34, 1, 4, jacketD); c.rect(25, 34, 6, 4, tee)
    c.rect(19, 35, 3, 1, jacketD); c.rect(34, 35, 3, 1, jacketD); c.px(20, 36, jacketD); c.px(35, 36, jacketD)   // pocket flaps
    c.rect(18, 34, 3, 1, C(0x868E60)); c.rect(24, 34, 1, 4, jacketD); c.rect(31, 34, 1, 4, jacketD)   // lit shoulder, the opening
    c.rect(25, 37, 6, 1, C(0x6E7278))   // the T-shirt's fold
    // The cap and the hair under it: down past his shoulders at the back.
    c.pattern(17, 19, [
        "......CCLLLCCCC.........",
        "....CCLLCCCCCCccC.......",
        "...CCLCCCCWWWCCCcc......",
        "..CCCCCCCCWWWCCCCcc.....",
        "..CCCCCCCCCCCCCCCCcc....",
        ".HcccccccccccccccccBBBBB",
        ".HlHHHHHHHHHHHHHHHHhh...",
        ".HlH................hH..",
        ".HlH....................",
        ".HHl....................",
        ".Hl.....................",
        "..H.....................",
    ], ["C": cap, "c": capD, "W": patch, "B": capD, "H": hair, "h": hairD, "L": C(0x587A4A), "l": C(0x7A5232)])
    drawRoundGlasses(c, C(0x6A4A2A))

    if filming {
        // The camcorder up at his eye, the left hand steadying it.
        c.rect(38, 29, 3, 4, jacket)
        c.pattern(36, 26, ["KKKKKKKKK.", "KGGKKKKKKL", "KKKKKKKKKL", "KKKKKKKKK.", ".KK......."],
                  ["K": C(0x26262C), "G": C(0x4A4A52), "L": C(0x7AA8C8)])
        if Int(p.t * 3) % 2 == 0 { c.px(37, 27, C(0xFF3A2A)) }
        c.rect(15, 33, 3, 3, jacket); c.rect(15, 35, 3, 1, clawdOrange); c.rect(15, 34, 3, 1, jacketD)
        return
    }
    drawPlainArms(c, p, sleeve: jacket, cuff: jacketD)
}

// MARK: - Agent Pendrill

/// Agent Pendrill: Clawd with neat auburn hair, a white lab coat buttoned over a blue shirt and tie, the coat's tails
/// down over his legs. He doesn't fight. Signature: he holds up a test tube of something green to the light, and blushes
/// pink as he does (Agent Scrawly must be passing).
private func drawPendrill(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0xF0F0EC), coatD = C(0xC4C8CE), shirt = C(0x8AAAD8), tie = C(0x2A3E6A)
    let hair = C(0x9A4A26), hairL = C(0xB8603A)
    let sig = p.signature
    let holding = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false
    let blush = sig.map { $0 > 0.3 && $0 < 0.95 } ?? false

    drawTails(c, coat, coatD, length: 4)
    drawLegs(c, Look(leg: C(0x4A4E58)), step: p.step)
    drawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: coat))
    // The lab coat, its lapels open on the shirt and tie, a pen in the breast pocket.
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD); c.rect(18, 37, 20, 1, coatD)
    c.pattern(24, 33, ["dSSTTSSd", ".dSTTSd.", "..dTTd..", "...TT..."], ["d": coatD, "S": shirt, "T": tie])
    c.rect(33, 34, 3, 1, coatD); c.px(34, 33, C(0x2A3E6A))
    // A fold, the far side in shade, the coat's buttons.
    c.rect(20, 35, 1, 2, coatD); c.rect(36, 35, 1, 2, coatD); c.px(23, 36, C(0xA8ACB4))
    // Neat side-parted hair, short at the back.
    c.pattern(17, 21, [
        "......HHHHllHHH.......",
        "....HHlllHlHHHllHH....",
        "...HHlHHHHHlHHHHHHd...",
        "..HHHHHHHHHHHlllHHdd..",
        ".HHlllHHHHHHHHHHHHHdd.",
        ".HH................dd.",
    ], ["H": hair, "l": hairL, "d": C(0x7A3A1E)])
    if blush {   // a proper blush, both cheeks
        for x in [19, 34] { c.rect(x, 31, 3, 2, C(0xF0607A)); c.px(x + 1, 31, C(0xFF8A9A)) }
    }

    if holding {
        // The test tube held up in his right hand, green and glowing faintly.
        c.rect(38, 28, 3, 5, coat)
        c.rect(39, 20, 2, 8, C(0xDCEEF0, 0.85)); c.rect(39, 23, 2, 5, C(0x6ADB5A)); c.px(39, 20, C(0xB8C4C8))
        c.rect(38, 22, 4, 6, C(0x8AFF6A, 0.12))
        c.rect(15, 33, 3, 3, coat); c.rect(15, 35, 3, 1, clawdOrange); c.rect(15, 34, 3, 1, coatD)
        return
    }
    drawPlainArms(c, p, sleeve: coat, cuff: coatD)
}

// MARK: - Arthur Dales

/// Arthur Dales: Clawd as the retired agent, thin white hair combed back and bushy white brows, a maroon cardigan
/// buttoned over a shirt and brown trousers. His weapon is a baseball bat, swung like he still means it, and rested on
/// his shoulder between swings. Signature: a home-run swing, the ball sailing up and away out of the park.
private func drawArthurDales(_ c: PixelCanvas, _ p: Pose) {
    let cardigan = C(0x7A2E32), cardiganD = C(0x58202A), shirt = C(0xE6E2D6), hair = C(0xE8E8EC), hairD = C(0xB8BAC2)
    let sig = p.signature

    drawLegs(c, Look(leg: C(0x6A5440)), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0x3A2416))
    c.oy += p.breathe
    drawBody(c, Look(arm: cardigan))
    // The cardigan, its buttons and the shirt collar.
    c.rect(18, 33, 20, 5, cardigan); c.rect(37, 33, 1, 5, cardiganD); c.rect(18, 37, 20, 1, cardiganD)
    c.pattern(25, 33, ["SSSSSS", ".SSSS.", "..dd.."], ["S": shirt, "d": cardiganD])
    for y in [35, 37] { c.px(28, y, C(0xD8C8A0)) }
    // Light on the shoulders, a fold either side, the knit's ribbed hem.
    c.rect(18, 33, 3, 1, C(0x9A4048)); c.rect(34, 33, 2, 1, C(0x9A4048))
    c.rect(21, 35, 1, 2, cardiganD); c.rect(35, 34, 1, 3, cardiganD)
    for x in stride(from: 19, to: 37, by: 3) { c.px(x, 37, C(0x8A3A40)) }
    // Thin white hair combed back, and the bushy brows.
    c.pattern(17, 21, [
        ".......HHHHHHHH.......",
        ".....HHhhHHHHhhHH.....",
        "...HHHHHHHhhHHHHHHH...",
        "..HHHHhhHHHHHHHhhHHh..",
        ".HHHHHHHHHHhhHHHHHHhh.",
        ".HH................hh.",
    ], ["H": hair, "h": hairD])
    c.rect(21, 27, 4, 1, hair); c.rect(31, 27, 4, 1, hair)

    if let s = sig, s > 0.12, s < 0.95 {
        // The swing: from wound back over his shoulder, round and through, then the follow-through; the ball flies.
        let k = min(1, max(0, (s - 0.12) / 0.3))
        let angle = -150 + 175 * (0.5 - 0.5 * cos(k * .pi))
        if k > 0.2 && k < 1 { for i in 1...2 { drawBat(c, angle: angle - Double(i) * 18, alpha: 0.3 / Double(i)) } }
        drawBat(c, angle: angle)
        if s > 0.42 {
            let f = (s - 0.42) / 0.53
            c.rect(46 + Int(f * 24), 30 - Int(f * 26), 2, 2, white)
        }
        c.rect(15, 33, 3, 3, cardigan); drawCuffs(c, cardiganD, right: false)
        return
    }
    c.rect(15, 33, 3, 3, cardigan); drawCuffs(c, cardiganD, right: false)
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() { drawBat(c, angle: ta, alpha: 0.35 / Double(i + 1)) }
        drawBat(c, angle: a)
    } else {
        drawBat(c, angle: p.cheering ? -95 : -120)   // resting on his shoulder
    }
    c.rect(38, 33, 3, 3, cardigan); drawCuffs(c, cardiganD, left: false)
}

/// A wooden baseball bat from the hand at `angle` degrees (0 forward, -90 up), thicker towards the barrel.
private func drawBat(_ c: PixelCanvas, angle: Double, alpha: Double = 1) {
    let r = angle * .pi / 180, h = Sprite.hand
    let wood = C(0xC89A5A).alpha(alpha), woodD = C(0x9A7040).alpha(alpha), grip = C(0x2A2A30).alpha(alpha)
    let at = { (d: Double) in (h.x + cos(r) * d, h.y + sin(r) * d) }
    let a = at(-1), b = at(3), m = at(9), e = at(17)
    line(c, a.0, a.1, b.0, b.1, grip, 0.8)
    line(c, b.0, b.1, m.0, m.1, wood, 0.9)
    line(c, m.0, m.1, e.0, e.1, wood, 1.5)
    line(c, m.0 + 0.4, m.1 + 0.4, e.0 + 0.4, e.1 + 0.4, woodD, 0.6)
}

// MARK: - Clyde Bruckclaw

/// Clyde Bruckclaw: Clawd under a sad brown fedora with a dark band, grey hair showing at the sides, heavy lids over
/// tired eyes, and a rumpled tan suit with a crooked tie. He sees how people die and doesn't fight. Signature: he
/// holds up a little kewpie doll, then shudders at what he's just seen.
private func drawClydeBruckclaw(_ c: PixelCanvas, _ p: Pose) {
    let hat = C(0x6A5238), hatD = C(0x4A3826), band = C(0x2A2018), suit = C(0xA8946A), suitD = C(0x86744E)
    let shirt = C(0xE4DFD0), tie = C(0x5A6A3A), grey = C(0x9A9CA4)
    let sig = p.signature
    let doll = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false
    let shudder = sig.map { $0 > 0.5 && $0 < 0.85 } ?? false
    if shudder { c.ox += Int(p.t * 30) % 2 == 0 ? 1 : 0 }

    drawLegs(c, Look(leg: suitD), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0x3A2A1E))
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    // The rumpled suit (creases), the crooked tie.
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.rect(20, 34, 1, 2, suitD); c.px(21, 36, suitD); c.rect(33, 34, 1, 2, suitD); c.px(34, 36, suitD)
    c.rect(18, 33, 3, 1, C(0xC0AC80)); c.rect(36, 34, 1, 3, suitD)   // a lit shoulder, the far side in shade
    c.rect(18, 37, 20, 1, C(0x4A3A2A)); c.rect(27, 37, 2, 1, C(0xB8A880))   // the belt, its buckle
    c.pattern(25, 33, ["SSSSSS", ".SSTS.", "..TT..", "...T.."], ["S": shirt, "T": tie])
    // The fedora, its brim all round, grey hair at the sides under it.
    c.pattern(16, 18, [
        "........HHLLLHHh........",
        "......HHLHHHHHHHhh......",
        "......HHHHHHddHHhh......",
        "......BBBBBBBBBBBB......",
        "..hhhhhhhhhhhhhhhhhhhh..",
        "..gssssssssssssssssssg..",
        "..gssssssssssssssssssg..",
        "..gssssssssssssssssssg..",
        "..gg................gg..",
        "..gg................gg..",
    ], ["H": hat, "B": band, "h": hatD, "g": grey, "s": clawdShade, "L": C(0x86684A), "d": hatD])
    // Heavy lids over the eyes.
    c.rect(22, 28, 2, 1, clawdShade); c.rect(32, 28, 2, 1, clawdShade)

    if doll {
        // The kewpie doll in his right hand: pink, a tuft on top, its arms out.
        c.rect(38, 30, 3, 4, suit)
        c.pattern(37, 20, [
            "....T...",
            "...TT...",
            "..PPPPP.",
            ".PkPPkPP",
            ".PPPrPPd",
            "..PPPPd.",
            "pPPPPPPp",
            "..PPPPd.",
            "..PP.Pd.",
        ], ["T": C(0xB8862A), "P": C(0xFFA8A0), "d": C(0xE07C7A), "p": C(0xFFA8A0), "k": ink, "r": C(0xD8404A)])
        c.rect(15, 33, 3, 3, suit); c.rect(15, 35, 3, 1, clawdOrange); c.rect(15, 34, 3, 1, suitD)
        return
    }
    drawPlainArms(c, p, sleeve: suit, cuff: suitD)
}

// MARK: - Jose Chung

/// Jose Chung: Clawd bald on top with a grey fringe round the sides, round tortoiseshell glasses, a red bow tie and a
/// navy blazer over a white shirt. A writer, not a fighter. Signature: a little typewriter in front of him clacks away,
/// the carriage jumping, and finished pages float up and away.
private func drawJoseChung(_ c: PixelCanvas, _ p: Pose) {
    let blazer = C(0x24304E), blazerD = C(0x18203A), shirt = C(0xF0EEE8), bow = C(0xB8202A), grey = C(0xB8BAC2)
    let sig = p.signature

    drawLegs(c, Look(leg: C(0x5A5A62)), step: p.step)
    drawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: blazer))
    // The blazer, shirt and bow tie.
    c.rect(18, 33, 20, 5, blazer); c.rect(37, 33, 1, 5, blazerD); c.rect(18, 37, 20, 1, blazerD)
    c.rect(24, 33, 8, 5, shirt); c.rect(22, 33, 2, 3, blazerD); c.rect(32, 33, 2, 3, blazerD)
    c.pattern(25, 33, ["BB..BB", "BBBBBB", "BB..BB"], ["B": bow])
    drawJacketDetail(c, dark: blazerD, light: C(0x38466A), pocket: false)
    c.rect(34, 34, 2, 1, shirt); c.px(29, 36, blazerD)   // a pocket square; a button on the shirt
    // The grey fringe round the sides of a bald head.
    c.pattern(16, 25, ["GGG...................GGG", "GGG...................GGG", ".GG...................GG.", ".G.....................G."],
              ["G": grey])
    drawRoundGlasses(c, C(0x7A4A22))

    if let s = sig, s > 0.06, s < 0.94 {
        // The typewriter in front of him, keys clacking, the carriage jumping, pages floating up and away.
        let tap = Int(p.t * 10) % 2
        c.pattern(37, 33, ["..PPPPP..", "KKKKKKKKK", "KkKkKkKkK", "KKKKKKKKK"],
                  ["P": C(0xF4F2EA), "K": C(0x3A3A40), "k": C(0x8A8A92)])
        c.rect(37 + tap, 32, 9, 1, C(0x5A5A62))
        c.rect(38, 31, 3, 2, blazer); c.rect(15, 33, 3, 3, blazer); drawCuffs(c, blazerD, right: false)
        for i in 0..<3 {
            let f = (s * 3 + Double(i) / 3).truncatingRemainder(dividingBy: 1)
            guard f > 0.1 else { continue }
            let x = 41 + Int(f * 10) + Int(sin(f * 9 + Double(i)) * 2), y = 30 - Int(f * 24)
            c.rect(x, y, 3, 4, C(0xF4F2EA, 1 - f * 0.6)); c.rect(x, y + 1, 2, 1, C(0x8A8A92, 1 - f * 0.6))
        }
        return
    }
    drawPlainArms(c, p, sleeve: blazer, cuff: blazerD)
}

// MARK: - Leyla Harriclaw

/// Leyla Harriclaw: Clawd with a strawberry-blonde ponytail that bounces as she walks, a navy blazer over a pink blouse
/// and an FBI sidearm with its flashlight. She knows every case by heart. Signature: she holds up her notebook and the
/// file folders flutter round her, one after another.
private func drawLeylaHarriclaw(_ c: PixelCanvas, _ p: Pose) {
    let blazer = C(0x2A3858), blazerD = C(0x1C2840), blouse = C(0xF0A8B8), hair = C(0xD8925A), hairL = C(0xEAAE72)
    let sig = p.signature
    let notebook = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false
    let bob = p.step >= 0 ? p.step : 0

    drawLegs(c, Look(leg: blazerD), step: p.step)
    drawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: blazer))
    c.rect(18, 33, 20, 5, blazer); c.rect(37, 33, 1, 5, blazerD); c.rect(18, 37, 20, 1, blazerD)
    c.pattern(24, 33, ["dBBBBBBd", ".dBBBBd.", "..dBBd.."], ["d": blazerD, "B": blouse])
    drawJacketDetail(c, dark: blazerD, light: C(0x3E4E74))
    c.px(28, 36, C(0xC8B060))   // the blazer's brass button
    // The hair pulled back, the ponytail out behind her (on the left), swinging a pixel as she walks.
    c.pattern(17, 20, [
        "......HHHllHHHH.......",
        "....HHlllHHHlHHHHH....",
        "...HHHHHHHHHHlllHHH...",
        "..HHlllHHHHHHHHHHHdd..",
        ".HHHHHHHHHHHlllHHHHdd.",
        ".HHHHHHHHHHHHHHHHHHdd.",
        ".HH................dd.",
    ], ["H": hair, "l": hairL, "d": C(0xB4743E)])
    c.pattern(11, 22 + bob, ["..HlHH", ".HlHHd", "HlHd..", "HHd...", "Hd....", ".d...."], ["H": hair, "l": hairL, "d": C(0xB4743E)])
    c.rect(16, 23, 2, 2, C(0x2A3858))   // the hair tie

    if let s = sig, notebook {
        // Her notebook held up, and the case files fluttering round her.
        c.rect(38, 29, 3, 4, blazer)
        c.pattern(38, 24, ["NNNNN", "NwwwN", "NwwwN", "NwwwN", "NNNNN"], ["N": C(0x8A2A2A), "w": C(0xF4F2EA)])
        for i in 0..<3 {
            let a = s * 2 * .pi * 1.5 + Double(i) * 2.1
            let x = 26 + Int(cos(a) * 20), y = 11 + Int(sin(a) * 4)
            c.rect(x, y, 4, 3, C(0xD8B878)); c.rect(x, y, 2, 1, C(0xC09A58))
        }
        c.rect(15, 33, 3, 3, blazer); drawCuffs(c, blazerD, right: false)
        return
    }
    c.rect(15, 33, 3, 3, blazer); drawCuffs(c, blazerD, right: false)
    c.oy += p.gunY
    drawSidearm(c, sleeve: blazer, searching: p.ready || p.fire != nil)
    drawCuffs(c, blazerD, left: false)
}

// MARK: - Frank Blackclaw

/// Frank Blackclaw: Clawd with close-cropped grey hair, a lined, tired look, and a heavy charcoal-brown coat with its
/// collar turned up over a dark shirt; an FBI sidearm. Signature: he sees: stark black-and-white flashes burst round
/// him, one after another, while he presses a hand to his temple.
private func drawFrankBlackclaw(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x4A3E34), coatD = C(0x32281E), coatL = C(0x645446), shirt = C(0x2A2C34), hair = C(0x8E9098)
    let hairD = C(0x6A6C74)
    let sig = p.signature
    let seeing = sig.map { $0 > 0.1 && $0 < 0.9 } ?? false

    if let s = sig, seeing {
        // The visions: hard-edged flashes, white with jagged black strokes, popping up round him.
        let k = Int(s * 14)
        for i in 0..<2 {
            let n = k * 2 + i
            guard noise(n * 7 + 1) > 0.35 else { continue }
            let x = 2 + Int(noise(n * 7 + 2) * 56), y = 2 + Int(noise(n * 7 + 3) * 16)
            c.rect(x, y, 10, 7, C(0xF2F2F2, 0.9))
            line(c, Double(x + 1), Double(y + 5), Double(x + 4), Double(y + 1), ink, 0.5)
            line(c, Double(x + 4), Double(y + 1), Double(x + 6), Double(y + 6), ink, 0.5)
            line(c, Double(x + 6), Double(y + 6), Double(x + 9), Double(y + 2), ink, 0.5)
        }
    }
    drawTails(c, coat, coatD, length: 3)
    drawLegs(c, Look(leg: C(0x2E2E34)), step: p.step)
    drawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: coat))
    // The heavy coat, collar up, over a dark shirt.
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD); c.rect(18, 37, 20, 1, coatD)
    c.rect(25, 33, 6, 5, shirt)
    c.rect(24, 33, 1, 5, coatL); c.rect(31, 33, 1, 5, coatD)   // the coat's front edges
    c.rect(20, 35, 1, 2, coatD); c.rect(36, 34, 1, 3, coatD); c.rect(32, 36, 3, 1, coatD)   // a fold, far side, pocket
    c.px(23, 34, coatD); c.px(23, 36, coatD)   // buttons
    // The collar turned up: points standing at his shoulders, lit on the outside, shadowed on the inside.
    c.pattern(16, 27, ["L...", "L...", "LL..", "LcL.", "LcL.", "LccL", "LccL"], ["L": coatL, "c": coatD])
    c.pattern(36, 27, ["...L", "...L", "..LL", ".LcL", ".LcL", "LccL", "LccL"], ["L": coatL, "c": coatD])
    // Close-cropped grey hair; lines under the eyes.
    c.pattern(17, 21, [
        ".......HHllllHH.......",
        ".....HHllHHHHHHlH.....",
        "...HHHHHHHHHHHHHHHh...",
        "..HHHHHHhhHHHHhhHHhh..",
        ".HHHHHHHHHHHHHHHHHHhh.",
    ], ["H": hair, "h": hairD, "l": C(0xAEB0B8)])
    c.px(22, 32, clawdShade); c.px(33, 32, clawdShade)

    if seeing {
        // His hand at his temple, his eyes squeezed shut.
        c.rect(38, 26, 3, 7, coat); c.rect(36, 26, 2, 2, clawdOrange)
        c.rect(22, 30, 2, 1, ink); c.rect(32, 30, 2, 1, ink)
        c.rect(15, 33, 3, 3, coat); drawCuffs(c, coatD, right: false)
        return
    }
    c.rect(15, 33, 3, 3, coat); drawCuffs(c, coatD, right: false)
    c.oy += p.gunY
    drawSidearm(c, sleeve: coat, searching: p.ready || p.fire != nil)
    drawCuffs(c, coatD, left: false)
}
