import Foundation

// Heroes: Sunnydale's friendly demons and the rest of Angel Investigations. Clawd in costume like the rest of the
// cast: hair, skin and clothes drawn over the blocky body, with Clawd's own face showing (tinted green for Lorn,
// painted over for Sid the Dummy).

let slayerHeroes5: [SlayerHero: Persona] = [
    .clemm: Persona(name: "Clemm", headTop: 21, signature: 3.6, draw: drawClemm),
    .whistlr: Persona(name: "Whistlr", headTop: 17, signature: 3.2, draw: drawWhistlr),
    .sidTheDummy: Persona(name: "Sid the Dummy", weapon: .saber, pivot: h5SidHand, headTop: 25, signature: 3.4,
                          draw: drawSidTheDummy),
    .charlesGunne: Persona(name: "Charles Gunne", weapon: .saber, headTop: 22, signature: 3.0, draw: drawCharlesGunne),
    .fredBurkel: Persona(name: "Fred Burkel", headTop: 20, signature: 3.8, draw: drawFredBurkel),
    .lorn: Persona(name: "Lorn", headTop: 20, signature: 3.8, draw: drawLorn),
    .doyl: Persona(name: "Doyl", weapon: .saber, headTop: 19, signature: 3.2, draw: drawDoyl),
]

// MARK: - Shared bits

/// 0…1 through the middle stretch of a signature move (`from`…`to` of it), or -1 outside it.
private func h5Span(_ p: Pose, _ from: Double, _ to: Double) -> Double {
    guard let s = p.signature, s > from, s < to else { return -1 }
    return (s - from) / (to - from)
}

/// An unarmed hero's free arm: up and waving while cheering or calling you urgently, otherwise drawBody's own.
private func h5Wave(_ c: PixelCanvas, _ p: Pose, sleeve: Px) {
    guard p.cheering || (p.ready && p.urgent) else { return }
    let up = sin(p.t * 10) > 0 ? 1 : 0
    c.rect(38, 26 - up, 3, 7 + up, sleeve); c.rect(38, 24 - up, 3, 2, clawdOrange)
}

/// A swing angle in -180…180.
private func h5Norm(_ a: Double) -> Double {
    var n = a.truncatingRemainder(dividingBy: 360)
    if n > 180 { n -= 360 }
    if n <= -180 { n += 360 }
    return n
}

/// The high backhand and the top of a twirl: a swing here would sweep a held weapon across the eyes, so it goes round
/// behind the head instead, drawn before the body (no jump at the top of the twirl).
private func h5Behind(_ a: Double) -> Bool {
    let n = h5Norm(a)
    return n < -112 || n > 150
}

/// The smear behind a swing in front of the body: only the angles that don't pass behind the head.
private func h5Front(_ trail: [Double]) -> [Double] { trail.filter { !h5Behind($0) } }

/// A punch along `angle`: the sleeve thrown out and a fist on the end, a smear where a fast one just was.
private func h5Punch(_ c: PixelCanvas, angle a: Double, trail: [Double], sleeve: Px, reach len: Double = 7) {
    slayerSmear(c, slayerHand, h5Behind(a) ? [] : h5Front(trail), from: 3, to: len + 1, C(0xF4E8D0))
    let e = slayerReach(slayerHand, a, len)
    slayerLine(c, slayerHand.x - 2, slayerHand.y - 0.5, e.x, e.y, sleeve, 1.2)
    c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 3, 3, clawdOrange)
    c.px(Int(e.x.rounded()) + 1, Int(e.y.rounded()) - 1, clawdShade)   // the knuckles
}

/// A filled disc of radius `r` round (x, y).
private func h5Disc(_ c: PixelCanvas, _ x: Double, _ y: Double, _ r: Double, _ col: Px) {
    let n = Int(r.rounded(.up))
    for dy in -n...n {
        for dx in -n...n where Double(dx * dx + dy * dy) <= r * r + 0.4 {
            c.px(Int(x.rounded()) + dx, Int(y.rounded()) + dy, col)
        }
    }
}

// MARK: - Clemm

/// Clemm: Clawd under a great loose hood of droopy, wrinkled grey-pink skin, folds over his brow so his eyes look
/// sleepy, long floppy flaps hanging down either side and jowls sagging at his cheeks. A comfy mustard cardigan over a
/// pale blue shirt, brown slacks. He doesn't fight. Signature: he munches from a bag of cheesy snacks, flicking puffs
/// up into his mouth one after another, chewing, orange crumbs falling.
private func drawClemm(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xC8A89A), skinL = C(0xE4CCC0), fold = C(0x9A7A6E)
    let cardi = C(0xB89040), cardiD = C(0x8C6A26), cardiL = C(0xD6B05E), shirt = C(0xA8C2DC), button = C(0x5A3A1A)
    let munchK = h5Span(p, 0.06, 0.94)

    drawLegs(c, Look(leg: C(0x7A5E44)), step: p.step)
    slayerBoots(c, step: p.step, C(0x3A2818), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: cardi), armRight: munchK >= 0 ? 2 : 0)
    // The cardigan, open over the shirt, buttons down one edge, a pocket on each side.
    c.rect(18, 33, 20, 5, cardi); c.rect(37, 33, 1, 5, cardiD); c.rect(18, 37, 20, 1, cardiD)
    c.rect(25, 33, 6, 5, shirt); c.rect(24, 33, 1, 5, cardiL); c.rect(31, 33, 1, 5, cardiD)
    c.px(23, 34, button); c.px(23, 36, button)
    c.rect(19, 35, 3, 1, cardiD); c.rect(33, 35, 3, 1, cardiD)
    // The droopy skin: a bald wrinkled dome, arched folds across the brow, and long floppy ears hanging down either
    // side like a hound's, so his face shows in the middle of it all.
    let skinD = C(0xA88678)
    c.pattern(13, 25, [".lSSS", "lSSSw", "lSSwS", "lSSwS", "lSwSS", "lSwSS", ".SSSS", "..SS."],
              ["S": skin, "l": skinL, "w": fold])
    c.pattern(38, 25, ["SSSd.", "wSSSd", "SwSSd", "SwSSd", "SSwSd", "SSwSd", "SSSd.", ".Sd.."],
              ["S": skin, "d": skinD, "w": fold])
    c.pattern(17, 21, [
        ".......lllSSSSS.......",
        "....llSSSSSSSSSSSSd...",
        "..lSSSSSSSSSSSSSSSSSd.",
        ".lSSSSSwwwwwwwwSSSSSSd",
        "SSSSSSSSSSSSSSSSSSSSSd",
        "SSSSwwwSSSSSSSSwwwSSSd",
        "SSS................SSd",
        "SS..SSSS......SSSS..Sd",
        "SS..................Sd",
    ], ["S": skin, "l": skinL, "w": fold, "d": skinD])
    // Heavy lids: the top of each eye under a fold of skin.
    c.rect(22, 29, 2, 1, skin); c.rect(32, 29, 2, 1, skin)
    // Jowls, sagging at his cheeks.
    let chew = munchK >= 0 && Int(p.t * 8) % 2 == 0 ? 1 : 0
    c.pattern(19, 31 + chew, ["SSw", "wS."], ["S": skin, "w": fold])
    c.pattern(34, 31 + chew, ["wSS", ".Sw"], ["S": skin, "w": fold])

    if munchK < 0 { h5Wave(c, p, sleeve: cardi); return }
    // The bag of cheesy snacks in his right hand: bright orange, a yellow band, a cheesy puff on the front.
    let bagC = C(0xE86A1A), band = C(0xF8D040), bagD = C(0xB04A10)
    c.rect(40, 29, 5, 8, bagC); c.rect(40, 31, 5, 2, band); c.rect(44, 29, 1, 8, bagD)
    c.pattern(41, 33, [".P.", "PLP", ".P."], ["P": C(0xF8A040), "L": C(0xFFD070)])
    c.pattern(40, 28, ["x.x.x"], ["x": bagD])
    c.rect(38, 31, 2, 3, clawdOrange)
    // Three puffs, each flicked up out of the bag in an arc into his mouth, then chewed.
    let m = (munchK * 3).truncatingRemainder(dividingBy: 1)
    let puff = C(0xF89A2A), puffL = C(0xFFD070)
    if m < 0.45 {
        // A fat cheesy puff, flicked up and over into the corner of his mouth.
        let f = m / 0.45
        let x = Int((42 - f * 8).rounded()), y = Int((27 - sin(f * .pi) * 6 + f * 4).rounded())
        c.pattern(x - 1, y - 1, [".P.", "PLP", ".P."], ["P": puff, "L": puffL])
    } else {
        // Chewing: his mouth working, a crumb or two falling.
        c.rect(31, 32, 3, 1, C(0x5A2A1A))
        if Int(p.t * 8) % 2 == 0 { c.rect(31, 33, 2, 1, C(0x5A2A1A)) }
        let f = (m - 0.45) / 0.55
        if f < 0.8 { c.px(36, 34 + Int(f * 8), puff) }
        if f > 0.3 && f < 0.9 { c.px(35, 34 + Int((f - 0.3) * 10), puffL) }
    }
}

// MARK: - Whistlr

/// Whistlr: Clawd in a black pork-pie hat with a red band, short dark hair and sideburns under its brim, a loud red
/// shirt printed with yellow and black diamonds, its collar wide open, and grey slacks. He doesn't fight; he's the
/// balance. Signature: he flips a coin off his thumb, it spins up and drops back into his palm, and he gives you a
/// knowing grin, one brow up.
private func drawWhistlr(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0xC8302A), shirtD = C(0x962018), dia = C(0xF2C432), blk = C(0x1E1A1E)
    let hat = C(0x24222A), hatL = C(0x48444E), hatD = C(0x121116), band = C(0xB02A2A)
    let hair = C(0x2A1E18), hairD = C(0x1A120E)
    let flipK = h5Span(p, 0.08, 0.7)
    let grinK = h5Span(p, 0.55, 0.96)

    drawLegs(c, Look(leg: C(0x5E5C68)), step: p.step)
    slayerBoots(c, step: p.step, C(0x1A1618), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: shirt), armRight: flipK >= 0 ? 2 : 0)
    // The loud shirt: diamonds in yellow and black, the wide collar open at the neck.
    c.rect(18, 33, 20, 5, shirt); c.rect(37, 33, 1, 5, shirtD); c.rect(18, 37, 20, 1, shirtD)
    for (i, x) in stride(from: 19, through: 35, by: 4).enumerated() {
        let y = 34 + (i % 2)
        c.pattern(x, y, [".D.", "DKD", ".D."], ["D": dia, "K": blk])
    }
    c.pattern(23, 33, ["SSS....SSS", ".S......S."], ["S": C(0xF2EAE0)])
    c.rect(26, 33, 4, 2, clawdOrange)
    // Short dark hair under the hat, sideburns down in front of his ears, a tuft at the back.
    c.pattern(16, 22, [
        "..HHHHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHH..",
        "HHHHHHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHH..",
        "..HH..............HHd...",
        "..H................d....",
        "..d.....................",
    ], ["H": hair, "d": hairD])
    // The pork-pie hat: a short flat crown with a pinched top, a red band, a short brim turned up at the edge.
    c.pattern(16, 17, [
        ".......KKKKKKKKKK.......",
        "......KLLLLLLLLLKK......",
        "......KKKKKKKKKKKK......",
        "......RRRRRRRRRRRR......",
        "..dKKKKKKKKKKKKKKKKKKd..",
        "...DDDDDDDDDDDDDDDDDD...",
    ], ["K": hat, "L": hatL, "R": band, "D": hatD, "d": hatL])

    if grinK >= 0 {
        // The knowing grin, wide and lopsided with a flash of teeth, and one brow cocked up.
        c.pattern(24, 30, ["......M", "MWWWWM.", ".MMMM.."], ["M": C(0x6A2418), "W": C(0xF4EEE4)])
        c.rect(21, 28, 3, 1, hairD); c.rect(31, 26, 3, 1, hairD)
    }
    if flipK < 0 {
        h5Wave(c, p, sleeve: shirt)
        return
    }
    // The coin, flipped off his thumb: up it goes, turning over, and back down into his raised hand.
    c.rect(38, 30, 3, 2, clawdOrange)
    let h = sin(flipK * .pi) * 13
    let cy = 28 - Int(h.rounded())
    // A big gold coin, tumbling end over end: face on with a glint, then tilted to an oval, then edge on.
    let gold = C(0xF2CC44), goldD = C(0xA88220), goldL = C(0xFFF2B0)
    switch Int(flipK * 18) % 4 {
    case 0: c.pattern(39, cy - 2, [".GG.", "GLGG", "GGGd", ".dd."], ["G": gold, "L": goldL, "d": goldD])
    case 1, 3: c.pattern(39, cy - 1, [".GG.", "GLGG", ".dd."], ["G": gold, "L": goldL, "d": goldD])
    default: c.rect(39, cy, 4, 1, goldD); c.px(40, cy, gold)
    }
}

// MARK: - Sid the Dummy

private let h5SidHand = (x: 38.5, y: 35.5)

/// Sid the Dummy: a ventriloquist's dummy, and the smallest of the cast: Clawd shrunk into a little brown tweed suit
/// with a white shirt and a red bow tie, glossy painted black hair with a curl at the front, and a dummy's face painted
/// over Clawd's: big round eyes, rosy cheeks, red lips and the two hinge lines of his jaw. He hunts demons with a knife.
/// Signature: he turns his head right round, all the way, and back to the front.
private func drawSidTheDummy(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x8A6440), suitD = C(0x664828), suitL = C(0xA87E52), shirtC = C(0xF2EEE6), bow = C(0xC8202A)
    let paint = C(0x1A1418), shine = C(0x5A5466)
    let turnK = h5Span(p, 0.12, 0.88)
    // The head's turn: 0 facing front, round through his back, and front again.
    let theta = turnK >= 0 ? (1 - cos(turnK * .pi)) * .pi : 0

    // Little legs in tweed trousers, small black shoes.
    let legs = [21, 24, 30, 33]
    for (i, lx) in legs.enumerated() {
        if seatedPose {
            c.rect(lx - 1, 38, 3, 2, suit)
            continue
        }
        let lifted = p.step >= 0 && i % 2 == p.step
        c.rect(lx, 36, 2, lifted ? 7 : 8, suit)
        c.rect(lx, lifted ? 41 : 42, 2, 2, paint)
        c.px(lx, 36, suitL)
    }
    c.oy += p.breathe
    if let a = p.melee, h5Behind(a) { h5SidKnife(c, p) }
    // The head: Clawd's own orange block, smaller.
    c.rect(21, 29, 14, 5, clawdOrange); c.rect(34, 29, 1, 5, clawdShade)
    // The little suit: jacket, white shirt front and a red bow tie.
    c.rect(21, 34, 14, 4, suit); c.rect(34, 34, 1, 4, suitD); c.rect(21, 37, 14, 1, suitD)
    c.rect(26, 34, 4, 3, shirtC); c.rect(25, 34, 1, 3, suitL); c.rect(30, 34, 1, 3, suitD)
    c.pattern(26, 34, ["B..B", "BBBB"], ["B": bow])
    // Little arms.
    c.rect(18, 34, 3, 3, suit); c.rect(18, 37, 2, 1, clawdOrange)
    let armUp = p.cheering ? (sin(p.t * 10) > 0 ? 3 : 2) : 0
    c.rect(35, 34 - armUp, 3, 3, suit)

    // His painted hair, glossy black with a shine and a curl at the front.
    let back = cos(theta) < 0.15
    c.pattern(20, 25, [
        "....PPPPPPP.....",
        "..PPPSSSPPPPP...",
        ".PPPPPPPPPPPPP..",
        "PPPPPPPPPPPPPPPP",
        ".P............PP",
    ], ["P": paint, "S": shine])
    if back {
        // The back of his head: all painted hair, a seam down it.
        c.rect(21, 29, 14, 3, paint); c.px(22, 29, shine); c.px(23, 30, shine)
        c.rect(27, 29, 1, 3, C(0x3A3440))
        c.rect(21, 32, 14, 2, clawdOrange); c.rect(34, 32, 1, 2, clawdShade)
    } else {
        // Turning: the painted hair at the back of his head comes round on the side the face is leaving, so the head
        // reads as turning all the way through, not only when it's round the back.
        let d = sin(theta) * 9
        let hairW = min(13, Int(abs(d).rounded()))
        if hairW > 0 {
            let hx = d > 0 ? 21 : 35 - hairW
            c.rect(hx, 29, hairW, 3, paint); c.px(d > 0 ? 21 : 34, 29, shine)
        }
        // The painted face, kept simple so it reads small: big round eyes, rosy cheeks and red lips with the two
        // hinge lines of a dummy's jaw down from them. It slides round with the turn, clipped to the head.
        func put(_ x: Double, _ y: Int, _ w: Int, _ h: Int, _ col: Px) {
            for i in 0..<w {
                let px = Int((x + d).rounded()) + i
                if px >= 21 && px <= 34 { c.rect(px, y, 1, h, col) }
            }
        }
        put(23, 29, 3, 3, white); put(30, 29, 3, 3, white)
        put(24, 30, 2, 2, ink); put(31, 30, 2, 2, ink)
        put(21, 32, 2, 1, C(0xF07A86)); put(33, 32, 2, 1, C(0xF07A86))
        put(26, 32, 4, 1, C(0xB01828))
        put(26, 33, 1, 1, C(0x6A3420)); put(29, 33, 1, 1, C(0x6A3420))
        if d < 4 { c.pattern(32, 28, ["PP.", ".PP"], ["P": paint]) }   // the curl at the front
    }

    if p.melee == nil || !h5Behind(p.melee!) { h5SidKnife(c, p) }
}

/// Sid's knife, a short blade and a dark grip: swung in a fight (round behind his head at the top of a twirl, so it's
/// drawn before him then), held low and point down at rest.
private func h5SidKnife(_ c: PixelCanvas, _ p: Pose) {
    let grip = C(0x3A2418), blade = C(0xD8DEE8), bladeD = C(0x8A94A4)
    let h = h5SidHand
    if let a = p.melee {
        if !h5Behind(a) { slayerSmear(c, h, h5Front(p.trail), from: 2, to: 7, C(0xF0F4FF)) }
        slayerBar(c, h, a, from: -1.5, to: 1, grip, r: 0.8)
        slayerBar(c, h, a, from: 2, to: 6.5, bladeD, r: 0.8)
        slayerBar(c, h, a, from: 2, to: 6, blade, r: 0.5)
        c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 2, 2, clawdOrange)
    } else {
        // Held low and ready, point down.
        c.rect(38, 35, 2, 2, clawdOrange)
        c.rect(38, 37, 1, 1, grip); c.rect(38, 38, 1, 3, blade); c.px(39, 38, bladeD)
    }
}

// MARK: - Charles Gunne

/// Charles Gunne: Clawd with a shaved head, just a shadow of stubble over the top, a slate-blue hoodie with the hood
/// bunched down round his neck, a pouch pocket and white drawstrings, khaki cargo trousers and white trainers. He
/// fights with his home-made hubcap axe: a long iron pole with a sharpened hubcap for a blade. Signature: he spins the
/// hubcap axe round in one hand, fast, and catches it.
private func drawCharlesGunne(_ c: PixelCanvas, _ p: Pose) {
    let hood = C(0x46597A), hoodD = C(0x30405C), hoodL = C(0x627A9E), string = C(0xE8E8EC)
    let stubbleTint = C(0xC66A4C)
    let spinK = h5Span(p, 0.1, 0.9)

    drawLegs(c, Look(leg: C(0x8A8266)), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.px(lx + 1, 39, C(0x6A6450)) } }   // the cargo pockets
    slayerBoots(c, step: p.step, C(0xF0F0F2), height: 2)
    c.oy += p.breathe
    // Up in his raised fist, spun round its middle like a baton: twice round, slowing, and caught. While the hubcap
    // swings round past his face it goes behind his head.
    let ease = spinK * spinK * (3 - 2 * spinK)
    let spinHand = (x: 44.0, y: 27.0), spinA = -80 + ease * 720
    let spinBehind = spinK >= 0 && cos(spinA * .pi / 180) < -0.3
    if spinBehind { h5HubcapAxe(c, hand: spinHand, angle: spinA, from: -6) }
    if spinK < 0, let a = p.melee, h5Behind(a) { h5HubcapAxe(c, hand: slayerHand, angle: a) }
    drawBody(c, Look(arm: hood), armRight: spinK >= 0 ? 4 : 0)
    // The hoodie: the pouch pocket, the drawstrings, and the hood bunched round his neck in soft folds, a roll of it
    // at each side of his collar.
    c.rect(18, 33, 20, 5, hood); c.rect(37, 33, 1, 5, hoodD); c.rect(18, 37, 20, 1, hoodD)
    c.rect(22, 35, 12, 2, hoodD); c.rect(22, 35, 12, 1, hoodL)
    c.rect(26, 33, 1, 2, string); c.rect(30, 33, 1, 2, string)
    c.rect(18, 32, 20, 1, hood)
    for x in stride(from: 19, through: 36, by: 3) { c.px(x, 32, hoodL) }
    c.pattern(17, 31, ["LH", "HD"], ["L": hoodL, "H": hood, "D": hoodD])
    c.pattern(36, 31, ["HD", "DD"], ["H": hood, "D": hoodD])
    // The shaved head: Clawd's own orange smoothed over the top with a shine on it, a faint shadow of stubble, and a
    // stern brow.
    c.rect(19, 25, 17, 1, clawdOrange); c.rect(35, 25, 1, 1, clawdShade)
    c.rect(20, 25, 4, 1, C(0xF4A07C)); c.rect(21, 26, 2, 1, C(0xF4A07C))
    for x in stride(from: 25, through: 35, by: 4) { c.px(x, 25, stubbleTint); c.px(x - 2, 26, stubbleTint) }
    c.rect(21, 28, 3, 1, C(0x5A2E1A)); c.rect(31, 28, 3, 1, C(0x5A2E1A))

    if spinK >= 0 {
        slayerLine(c, 39, 30.5, spinHand.x, spinHand.y, hood, 1.2)
        if !spinBehind { h5HubcapAxe(c, hand: spinHand, angle: spinA, from: -6) }
        c.rect(Int(spinHand.x) - 1, Int(spinHand.y) - 1, 3, 3, clawdOrange)
        return
    }
    if let a = p.melee {
        if !h5Behind(a) { h5HubcapAxe(c, hand: slayerHand, angle: a, trail: h5Front(p.trail)) }
    } else {
        // At rest, held upright at his side, the hubcap up by his shoulder.
        h5HubcapAxe(c, hand: slayerHand, angle: -80)
        if p.cheering { c.rect(14, 30, 3, 3, hood) }
    }
    c.rect(Int(slayerHand.x.rounded()) - 1, Int(slayerHand.y.rounded()) - 1, 3, 3, clawdOrange)
}

/// Gunn's hubcap axe along `angle` from `hand`: an iron pole, and a sharpened hubcap on the end, its rim bright.
private func h5HubcapAxe(_ c: PixelCanvas, hand: (x: Double, y: Double), angle: Double, trail: [Double] = [],
                         from: Double = -2) {
    slayerSmear(c, hand, trail, from: 6, to: 12, C(0xE4ECF8))
    slayerBar(c, hand, angle, from: from, to: 6, C(0x4A4C54), r: 0.8)
    let ctr = slayerReach(hand, angle, from < -3 ? 7.5 : 9)
    h5Disc(c, ctr.x, ctr.y, 2.9, C(0xE8ECF2))
    h5Disc(c, ctr.x, ctr.y, 2.0, C(0xA8AEBA))
    c.px(Int(ctr.x.rounded()), Int(ctr.y.rounded()), C(0x5A5E68))
}

// MARK: - Fred Burkel

/// Fred Burkel: Clawd with long chestnut hair parted in the middle and tied in two low bunches that flare out at her
/// shoulders, little black-framed glasses, a mint cardigan over a pink top, and blue jeans. She doesn't fight; she
/// works it out. Signature: she lifts her pen and scribbles an equation in the air, pale blue chalk-light marks
/// appearing one by one beside her, then fading.
private func drawFredBurkel(_ c: PixelCanvas, _ p: Pose) {
    let cardi = C(0x8CC8A8), cardiD = C(0x64A084), cardiL = C(0xB4E2C8), top = C(0xE88AA0), topD = C(0xC8667E)
    let hair = C(0x7C4A2A), hairL = C(0xA06A40), hairD = C(0x52301A), frame = C(0x241C20)
    let writeK = h5Span(p, 0.06, 0.94)

    drawLegs(c, Look(leg: C(0x5A7AB0)), step: p.step)
    slayerBoots(c, step: p.step, C(0x8A4A3A), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: cardi), armRight: writeK >= 0 ? 6 : 0)
    // The cardigan, open over the pink top.
    c.rect(18, 33, 20, 5, cardi); c.rect(37, 33, 1, 5, cardiD); c.rect(18, 37, 20, 1, cardiD)
    c.rect(25, 33, 6, 5, top); c.rect(25, 37, 6, 1, topD); c.rect(24, 33, 1, 5, cardiL); c.rect(31, 33, 1, 5, cardiD)
    c.rect(18, 24, 20, 2, clawdOrange)
    // Long hair parted in the middle, down to her shoulders, the ties of the bunches at the sides; loose strands.
    c.pattern(16, 20, [
        "......HHHHHpHHHHH.......",
        "....HHHHHHHpHHHHHHH.....",
        "...HHHlHHHHpHHHHHlHH....",
        "..HHHHHHHHHpHHHHHHHHH...",
        "..HHHHHHHHHpHHHHHHHHHH..",
        ".HHHHHHHHH....HHHHHHHHH.",
        ".HHHHH............HHHHH.",
        ".HHH................HHH.",
        "HHHl................lHHH",
        ".HHt................tHH.",
        "..H..................H..",
    ], ["H": hair, "l": hairL, "d": hairD, "p": hairD, "t": C(0xE8507A)])
    // The two bunches, tied low and falling forward over her shoulders onto the cardigan, so they read as hair
    // hanging down and not as ears sticking out.
    c.pattern(16, 30, ["HHH", "HlH", "HHH", "HlH", "dHd", ".d."], ["H": hair, "l": hairL, "d": hairD])
    c.pattern(37, 30, ["HHH", "HlH", "HHH", "HHd", "dHd", ".d."], ["H": hair, "l": hairL, "d": hairD])
    // Her glasses: little black frames round both eyes, and the bridge.
    for ex in [20, 30] {
        c.rect(ex, 28, 6, 1, frame); c.rect(ex, 32, 6, 1, frame)
        c.rect(ex, 29, 1, 3, frame); c.rect(ex + 5, 29, 1, 3, frame)
        c.rect(ex + 1, 29, 1, 1, C(0xF0B8A0))   // a glint on the lens
    }
    c.rect(26, 29, 4, 1, frame)

    guard writeK >= 0 else { h5Wave(c, p, sleeve: cardi); return }
    // Her hand up with the pen, the pen's tip moving along as she writes.
    let glyphs: [[String]] = [
        ["XXX", "X..", "XX.", "X..", "XXX"],      // E
        ["...", "XXX", "...", "XXX", "..."],      // =
        ["...", "...", "XXX", "XXX", "X.X"],      // m
        ["...", "...", ".XX", "X..", ".XX"],      // c
        ["XX.", "..X", ".X.", "XXX", "..."],      // ²
    ]
    // Solid chalk-light (so it gets an outline and reads on any desktop), and it goes the way it came: the first mark
    // written is the first to wink out.
    let shown = min(glyphs.count, Int(writeK * 7))
    let gone = writeK > 0.8 ? Int((writeK - 0.8) / 0.2 * Double(glyphs.count + 1)) : 0
    let chalk = C(0x5CC4F4)
    for (i, g) in glyphs.prefix(shown).enumerated() where i >= gone {
        let y = i == 4 ? 13 : 15
        c.pattern(42 + i * 5, y, g, ["X": chalk])
    }
    let tip = writeK < 0.72 ? 43.0 + min(4.6, writeK * 7) * 5 : 43.0 + 4.6 * 5
    let hx = min(41.0 + (tip - 43) * 0.25, 45)
    c.rect(38, 27, 3, 3, cardi)
    c.rect(Int(hx) - 1, 25, 3, 3, clawdOrange)
    slayerLine(c, hx, 25, hx + 2, 22, C(0x3A5AD0), 0.5)
    c.px(Int(hx) + 2, 21, C(0xE8E8F0))
}

// MARK: - Lorn

/// Lorn: Clawd tinted green all over, with red eyes, two little red horns on his forehead and auburn hair swept up in
/// a quiff; a bright magenta suit with wide lapels over a yellow shirt and a purple tie. He doesn't fight; he reads
/// your soul when you sing. Signature: karaoke at Caritas: he lifts a microphone and sings, notes floating up.
private func drawLorn(_ c: PixelCanvas, _ p: Pose) {
    let green = C(0x62B45A), greenD = C(0x428A40), eye = C(0xA01424)
    let suit = C(0xC2369E), suitD = C(0x902478), suitL = C(0xE468C4), shirtC = C(0xF2D048), tie = C(0x5A1E7A)
    let hair = C(0x8A3A22), hairL = C(0xB25A36), hairD = C(0x5E2414), horn = C(0xD02A2A), hornL = C(0xF2705A)
    let singK = h5Span(p, 0.06, 0.94)

    drawLegs(c, Look(leg: suitD), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx, 37, 1, 4, suit) } }   // a crease down each leg
    slayerBoots(c, step: p.step, C(0xF0E8D8), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(body: green, shade: greenD, arm: suit, eye: eye), armRight: singK >= 0 ? 5 : 0)
    // The suit: wide lapels over the yellow shirt and a purple tie.
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.rect(25, 33, 6, 5, shirtC); c.rect(27, 34, 2, 4, tie)
    c.pattern(22, 33, ["LLL......LLL", ".LL......LL.", "..L......L.."], ["L": suitL])
    c.px(20, 35, C(0xF2D048))   // a pocket square
    // Auburn hair swept up in a quiff, and the little red horns on his brow.
    c.rect(18, 24, 20, 2, green)
    c.pattern(16, 19, [
        "........HHHH............",
        "......HHHHHHHH..H.......",
        "....HHHHlHHHHHHHH.......",
        "...HHHHHHHHlHHHHHHH.....",
        "..HHHHHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HH.HHH........HHHHHH..",
        "..dH................Hd..",
    ], ["H": hair, "l": hairL, "d": hairD])
    c.pattern(21, 22, ["h.", "rh", "rr", "rr", "rr"], ["r": horn, "h": hornL])
    c.pattern(33, 22, [".h", "hr", "rr", "rr", "rr"], ["r": horn, "h": hornL])

    guard singK >= 0 else { h5Wave(c, p, sleeve: suit); return }
    // The microphone, up by his mouth.
    // A big silver ball of a microphone on a black handle, its mesh catching the light.
    c.rect(39, 25, 2, 5, C(0x2A2A30)); c.rect(38, 28, 3, 3, clawdOrange)
    c.pattern(37, 19, [".MMM.", "MSMSM", "MMSMM", "MSMSM", ".MMd.", "..k.."],
              ["M": C(0x8E929C), "S": C(0xE4E8EE), "d": C(0x5E626C), "k": C(0x2A2A30)])
    // Notes floating up off it, drifting as they rise: solid all the way, so they keep their outline on any
    // desktop, and near the top each shrinks to a dot and pops.
    let noteShapes: [[String]] = [[".XX", ".X.", ".X.", "XX.", "XX."], ["XXX", "X.X", "X.X", "X.X", "X.X"]]
    let cols = [C(0xFF6AC8), C(0xFFD84A), C(0x6AE0FF)]
    for i in 0..<4 {
        let age = singK * 2.4 - Double(i) * 0.25   // each note sung a little after the one before
        guard age >= 0 else { continue }
        let f = age.truncatingRemainder(dividingBy: 1)
        let x = 44 + Int(f * 14 + sin(f * 9 + Double(i)) * 2), y = 20 - Int(f * 16)
        if f < 0.78 {
            c.pattern(x, y, noteShapes[i % 2 == 0 ? 0 : 1], ["X": cols[i % 3]])
        } else if f < 0.9 {
            c.rect(x, y + 2, 2, 2, cols[i % 3])
        }
    }
}

// MARK: - Doyl

/// Doyl: Clawd with tousled dark hair, a rumpled grey jacket with patched elbows over a rust-red shirt, and jeans. He
/// fights with his fists. Signature: his half-Brachen side shows: he shudders, his face goes blue and sprouts pale
/// spikes all over, for a moment, then he shakes it off and he's himself again.
private func drawDoyl(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x6E6A64), jacketD = C(0x4E4A46), jacketL = C(0x8E8A82), shirtC = C(0xB04A2A)
    let hair = C(0x2E2018), hairL = C(0x4E3A2C), hairD = C(0x1A120C)
    let s = p.signature ?? -1
    // The change: a shudder in, the demon face held, a shudder out. No flicker: halfway through the shudder he goes
    // blue with the spikes just breaking through, then they're out in full; going back, the same the other way.
    let into = s > 0.15 && s < 0.28, outOf = s > 0.68 && s < 0.8
    let stage = s >= 0.24 && s <= 0.72 ? 2 : (s >= 0.2 && s <= 0.76 ? 1 : 0)
    let demon = stage > 0
    if into || outOf { c.ox += Int(p.t * 30) % 2 == 0 ? 1 : -1 }
    let blue = C(0x6A8CCC), blueD = C(0x4A68A8)
    let spike = C(0xE8E0CC), spikeD = C(0x9E9480)   // bone, darker where it breaks through the skin

    drawLegs(c, Look(leg: C(0x4A5E86)), step: p.step)
    slayerBoots(c, step: p.step, C(0x2A2018), height: 2)
    c.oy += p.breathe
    if !(s > 0.1 && s < 0.85), let a = p.melee, h5Behind(a) { h5Punch(c, angle: a, trail: [], sleeve: jacket) }
    drawBody(c, Look(body: demon ? blue : clawdOrange, shade: demon ? blueD : clawdShade, arm: jacket,
                     eye: demon ? C(0xF2E070) : ink))
    // The rumpled jacket, open over the rust shirt, a patch on the elbow.
    c.rect(18, 33, 20, 5, jacket); c.rect(24, 33, 8, 5, shirtC)
    c.rect(23, 33, 1, 5, jacketL); c.rect(32, 33, 1, 5, jacketD); c.rect(37, 33, 1, 5, jacketD)
    c.rect(18, 37, 20, 1, jacketD); c.rect(24, 37, 8, 1, C(0x8A3820))
    c.rect(22, 33, 2, 1, jacketL); c.rect(32, 33, 2, 1, jacketL)
    c.rect(15, 34, 2, 1, C(0x5A5040))
    // Tousled dark hair, strands sticking up and falling over his brow.
    c.rect(18, 24, 20, 2, demon ? blue : clawdOrange)
    c.pattern(16, 19, [
        ".....H...H..H...H.......",
        "....HHH.HH.HHH.HHH.H....",
        "...HHHHHHHHHHHHHHHHHH...",
        "..HHHlHHHHHHlHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        "..HHHHHH.HHHHH..HHHHHH..",
        "..dHH......H.......HHd..",
        "..dH................Hd..",
        "...d................d...",
    ], ["H": hair, "l": hairL, "d": hairD])

    if demon {
        // The Brachen face: bony quills out through his hair, fanning outwards and tapering to a point, and a row
        // jutting sideways from each cheek; stubs only while they're breaking through.
        let full = stage == 2
        for (x, lean, h) in [(19, -1, 3), (23, -1, 4), (28, 0, 4), (32, 1, 4), (36, 1, 3)] {
            let n = full ? h : 1
            c.rect(x, 19, 2, 1, spikeD)
            for i in 0..<n { c.px(x + (lean < 0 ? 0 : 1) + lean * (i + 1) / 2, 18 - i, spike) }
        }
        for y in [27, 29, 31] {
            let n = full ? (y == 29 ? 3 : 2) : 1
            c.px(17, y, spikeD); c.rect(17 - n, y, n, 1, spike)
            c.px(38, y, spikeD); c.rect(39, y, n, 1, spike)
        }
        c.rect(21, 28, 3, 1, blueD); c.rect(32, 28, 3, 1, blueD)
        c.px(27, 31, blueD); c.px(28, 31, blueD)   // the ridge of his nose
    }
    if s >= 0 && s < 0.85 && s > 0.1 {
        c.rect(38, 33, 3, 3, jacket); c.rect(41, 34, 2, 2, demon ? blue : clawdOrange)
        return
    }
    if let a = p.melee {
        if !h5Behind(a) { h5Punch(c, angle: a, trail: p.trail, sleeve: jacket) }
    } else {
        c.rect(38, 33, 3, 3, jacket); c.rect(41, 34, 2, 2, clawdOrange)   // a fist at his side
    }
}
