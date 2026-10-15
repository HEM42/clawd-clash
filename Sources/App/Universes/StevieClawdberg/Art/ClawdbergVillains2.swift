import Foundation

// Villains: Back to the Future. Clawd in costume here too: three generations of Tannins (letterman jacket, cane,
// bionics on a hoverboard, a gunslinger's duster), the school's bald disciplinarian and a mulleted 1985 rival, all
// drawn over the blocky body.

let clawdbergVillains2: [ClawdbergVillain: Persona] = [
    .biffTannin: Persona(name: "Biff Tannin", weapon: .saber, bulk: 1, headTop: 20, signature: 3.0,
                         callout: "Hello? McFly?", draw: drawBiffTannin),
    .oldBiff: Persona(name: "Old Biff", weapon: .saber, headTop: 23, signature: 3.2, draw: drawOldBiff),
    .griffTannin: Persona(name: "Griff Tannin", weapon: .saber, motion: .hover, canSit: false, headTop: 15,
                          signature: 2.4, draw: drawGriffTannin),
    .madDogTannin: Persona(name: "Mad Dog Tannin", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 18,
                           signature: 3.0, draw: drawMadDogTannin),
    .mrStricklaw: Persona(name: "Mr. Stricklaw", headTop: 23, signature: 3.0, callout: "Slacker!",
                          draw: drawMrStricklaw),
    .needles: Persona(name: "Needles", headTop: 20, signature: 2.6, callout: "Chicken!", draw: drawNeedles),
]

// MARK: - Biff Tannin

/// Biff Tannin: a bigger Clawd than most (taller and broader), his sandy hair greased up into a pompadour, in a
/// maroon letterman jacket with cream sleeves and a cream letter on the chest, and jeans. He fights with his fists.
/// Signature: he knocks on an invisible head in front of him, knuckles rapping ("Hello? McFly?").
private func drawBiffTannin(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x7A1E2A), jacketD = C(0x5A1420), sleeve = C(0xEADFC4), sleeveD = C(0xC8BC9E)
    let hair = C(0x9A7444), hairL = C(0xBA9460)
    let sig = p.signature
    let knocking = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false

    drawLegs(c, Look(leg: C(0x3E5888)), step: p.step)
    cbBoots(c, step: p.step, C(0x2A2420), height: 1)
    c.oy += p.breathe
    // The big body: a row taller and a pixel wider each side than plain Clawd.
    c.rect(17, 25, 22, 13, clawdOrange)
    c.rect(38, 25, 1, 13, clawdShade); c.rect(17, 37, 22, 1, clawdShade)
    c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    c.rect(22, 28, 3, 1, C(0x8A4A30)); c.rect(31, 28, 3, 1, C(0x8A4A30))     // the scowl
    // The letterman jacket: ribbed cream collar, the letter, cream sleeves.
    c.rect(17, 33, 22, 5, jacket); c.rect(38, 33, 1, 5, jacketD); c.rect(17, 37, 22, 1, jacketD)
    c.rect(22, 33, 12, 1, sleeve)
    c.pattern(19, 34, ["LLL", "LL.", "LLL"], ["L": sleeve])
    c.rect(27, 34, 1, 4, jacketD)
    // The pompadour, piled up at the front.
    c.pattern(16, 19, [
        "............HHHHHHH...",
        "........HHHHHHHHhHHHH.",
        ".....HHHHHHHHHHHHHHhHH",
        "...HHHHHHHHHHhHHHHHHHH",
        "..HHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHH",
        ".HHH...............HH.",
    ], ["H": hair, "h": hairL])
    c.rect(14, 33, 3, 3, sleeve); c.rect(14, 35, 3, 1, sleeveD)

    if knocking {
        // His arm up at head height, knuckles rapping forward, the knock marks flying off.
        let rap = Int(p.t * 7) % 2
        c.rect(39, 27, 3, 6, sleeve)
        c.rect(42 + rap, 26, 3, 3, clawdOrange); c.px(44 + rap, 26, C(0xB85F40))
        if rap == 1 {
            c.px(48, 24, white); c.px(49, 27, white); c.px(48, 30, white)
        }
        return
    }
    if let a = p.melee {
        cbPunch(c, angle: a, trail: p.trail, arm: sleeve)
    } else {
        c.rect(39, 33, 3, 3, sleeve); c.rect(39, 35, 3, 1, sleeveD)
    }
}

// MARK: - Old Biff

/// Old Biff: Clawd in 2015, thin grey hair combed back, heavy grey brows, a brown suit jacket over a pale shirt and a
/// dark tie, a little stooped; he fights with his walking cane. Signature: he waves the sports almanac overhead, the
/// red-and-white book that makes him rich.
private func drawOldBiff(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x6E5440), suitD = C(0x4E3A2C), shirt = C(0xA8B8CC), tie = C(0x8A2A30)
    let hair = C(0xBEBEBA), hairD = C(0x8E8E8A), cane = C(0x5A3A22), caneL = C(0x7A5232)
    let sig = p.signature
    let waving = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: C(0x5A4A3A)), step: p.step)
    cbBoots(c, step: p.step, C(0x2A1E16), height: 1)
    c.oy += p.breathe
    c.oy += 1                                                      // a little stooped
    drawBody(c, Look(arm: suit))
    c.rect(18, 33, 20, 4, suit); c.rect(37, 33, 1, 4, suitD); c.rect(18, 36, 20, 1, suitD)
    c.rect(25, 33, 6, 3, shirt); c.rect(27, 33, 2, 3, tie)
    c.rect(24, 33, 1, 3, suitD); c.rect(31, 33, 1, 3, suitD)
    // Heavy grey brows and thin grey hair combed straight back.
    c.rect(21, 28, 4, 1, hair); c.rect(31, 28, 4, 1, hair)
    c.pattern(17, 23, [
        "......h.H.h.H.h.......",
        "...HHhHhHHhHHhHHhH....",
        ".HHHHHHHHHHHHHHHHHHH..",
        ".HH................H..",
    ], ["H": hair, "h": hairD])
    c.rect(15, 33, 3, 3, suit)

    if waving {
        // The almanac held up overhead and waved, its red cover with the white band.
        let wave = Int((sin(p.t * 8) * 2).rounded())
        c.rect(38, 22, 3, 11, suit)
        let bx = 38 + wave
        c.pattern(bx, 14, ["RRRRR", "RWWWR", "RRRRR", "RyRyR", "RRRRR", "RRRRR", "rrrrr"],
                  ["R": C(0xC8282A), "W": C(0xF4F0E4), "y": C(0xF2C84A), "r": C(0x8A1A1A)])
        // The cane hooked over his other arm meanwhile.
        c.rect(14, 30, 3, 1, cane); c.rect(14, 31, 1, 7, cane)
        return
    }
    if let a = p.melee {
        cbSmear(c, cbHand, p.trail, from: 3, to: 13, C(0xE8D8B8))
        cbBar(c, cbHand, a, from: -1, to: 12, cane, r: 0.7)
        let grip = cbReach(cbHand, a, -1)
        cbBar(c, grip, a - 90, from: 0, to: 2.5, caneL, r: 0.6)   // the crook
        c.rect(38, 33, 3, 3, suit)
        return
    }
    // At rest: leaning on the cane, planted on the floor.
    c.rect(38, 33, 3, 3, suit)
    c.rect(41, 33, 1, 11, cane)
    c.rect(41, 32, 3, 1, caneL); c.px(43, 33, caneL)
}

// MARK: - Griff Tannin

/// Griff Tannin: Clawd as the 2015 bionic punk, bleached hair spiked straight up, wraparound mirrored shades, a black
/// jacket with chrome bionic plates on the arm and a glowing implant at the temple, riding a black-and-magenta
/// hoverboard (he never touches the ground). He fights with a chrome baseball bat. Signature: a twitchy bionic jerk,
/// his body glitching side to side with sparks crackling off the implant and the shades flashing red.
private func drawGriffTannin(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x26222E), jacketD = C(0x16141C), chrome = C(0xC8D0DC), chromeD = C(0x7A8494)
    let hair = C(0xF0E2A0), hairD = C(0xC8B66A), shades = C(0x1A1A24), bat = C(0xD8DEE8)
    let sig = p.signature
    let twitch = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false
    var jerk = 0
    if twitch {
        let n = noise(Int(p.t * 14))
        jerk = n > 0.66 ? 2 : (n < 0.33 ? -2 : 0)
    }

    // The hoverboard under his feet, with its glow beneath.
    let glow = 0.4 + 0.25 * sin(p.t * 9)
    c.rect(18, 46, 22, 1, C(0xFF4AC8, glow * 0.5)); c.rect(21, 47, 16, 1, C(0xFF4AC8, glow * 0.3))
    c.pattern(15, 44, [".KKKKKKKKKKKKKKKKKKKKKKKKK.", "KmmmmKKKKKKKKKKKKKKKKKmmmmK", ".KKKKKKKKKKKKKKKKKKKKKKKKK."],
              ["K": C(0x1E1C24), "m": C(0xE83AAA)])
    c.ox += jerk
    drawLegs(c, Look(leg: C(0x3A3A44)), step: p.step)
    cbBoots(c, step: p.step, C(0x8A8A96), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: jacket, eye: nil))
    c.rect(18, 33, 20, 5, jacket); c.rect(37, 33, 1, 5, jacketD); c.rect(18, 37, 20, 1, jacketD)
    c.rect(25, 33, 6, 4, C(0x8A2AE0)); c.rect(26, 34, 4, 1, C(0x3A0E6A))   // a loud purple tee
    c.rect(24, 33, 1, 5, chromeD); c.rect(31, 33, 1, 5, chromeD)          // the zips
    // The spiked bleached hair.
    c.pattern(17, 15, [
        "...H....H....H....H...",
        "...HH..HH...HH...HH...",
        "..HHH..HHH..HHH.HHH...",
        "..HHHh.HHHh.HHHhHHHh..",
        ".HHHHhHHHHhHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHH",
        ".HHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHhHHHHHHHHhHHHH",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HH..................HH",
    ], ["H": hair, "h": hairD])
    // The wraparound shades and the implant at the temple.
    let flash = twitch && Int(p.t * 10) % 2 == 0
    c.rect(20, 29, 18, 2, shades)
    c.rect(32, 29, 3, 1, flash ? C(0xFF3A3A) : C(0x7AE8FF))
    c.rect(22, 29, 2, 1, flash ? C(0xFF3A3A) : C(0x4A5A8A))
    c.rect(19, 27, 2, 2, chrome); c.px(19, 27, C(0x7AE8FF))
    if twitch {
        let i = Int(p.t * 20)
        c.px(17 - Int(noise(i) * 3), 26 + Int(noise(i + 1) * 3), C(0xBFEFFF))
        c.px(18 - Int(noise(i + 2) * 3), 25 + Int(noise(i + 3) * 3), white)
    }
    // Chrome bionic plates on the sleeves.
    c.rect(15, 33, 3, 3, jacket); c.rect(15, 33, 3, 1, chrome)

    if let a = p.melee {
        cbSmear(c, cbHand, p.trail, from: 3, to: 15, C(0xE8F0FF))
        cbBar(c, cbHand, a, from: -1, to: 4, C(0x2A2A30), r: 0.6)
        cbBar(c, cbHand, a, from: 4, to: 14, bat, r: 1.0)
        cbBar(c, cbHand, a, from: 8, to: 14, chromeD, r: 0.3)
        c.rect(38, 33, 3, 3, jacket); c.rect(38, 33, 3, 1, chrome)
        return
    }
    // At rest: the bat hanging from his hand, its end down by his feet.
    cbLine(c, 41.5, 34, 44, 37, C(0x2A2A30), 0.6)
    cbLine(c, 44, 37, 47, 43, bat, 1.0)
    c.rect(38, 33, 3, 3, jacket); c.rect(38, 33, 3, 1, chrome)
}

// MARK: - Mad Dog Tannin

/// Mad Dog Tannin: Clawd as the 1885 outlaw, a black cowboy hat with a curled brim, a drooping dark moustache, a long
/// black duster over a dark red shirt and waistcoat, its tails over his legs, and spurred boots. He fights with his
/// revolver. Signature: he fires at the floor in front of him (dance!), the bullets kicking up dust at the ground.
private func drawMadDogTannin(_ c: PixelCanvas, _ p: Pose) {
    let duster = C(0x2E2A26), dusterD = C(0x1C1A18), dusterL = C(0x4A443E), shirt = C(0x7A2420)
    let hat = C(0x1E1C1C), hatD = C(0x3A3634), band = C(0x6A5A48), tache = C(0x2A1E16)
    let sig = p.signature
    let shooting = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: C(0x4A3E34)), step: p.step)
    cbBoots(c, step: p.step, C(0x3A2618), height: 3)
    if !seatedPose {
        c.px(18, 42, C(0xC8CCD4)); c.px(30, 42, C(0xC8CCD4))     // spurs
    }
    c.oy += p.breathe
    // The duster's tails over his legs.
    let tails = seatedPose ? 1 : 3
    c.rect(17, 37, 22, tails + 1, duster); c.rect(17, 37 + tails, 22, 1, dusterD); c.rect(28, 38, 1, tails, dusterD)
    drawBody(c, Look(arm: duster))
    c.rect(18, 33, 20, 5, duster); c.rect(37, 33, 1, 5, dusterD); c.rect(18, 37, 20, 1, dusterD)
    c.rect(24, 33, 8, 4, shirt); c.rect(24, 33, 1, 4, dusterL); c.rect(31, 33, 1, 4, dusterL)
    c.rect(25, 35, 6, 2, C(0x3A3230))                               // the waistcoat
    // The drooping moustache.
    c.pattern(24, 31, [".TTTTTTTT.", "TTT....TTT", "T........T"], ["T": tache])
    // The cowboy hat: tall pinched crown, brim curled up at both ends.
    c.pattern(15, 18, [
        "........HHHHHHHH........",
        ".......HHHHdHHHHH.......",
        ".......HHHHHHHHHH.......",
        ".......HHHHHHHHHH.......",
        ".......BBBBBBBBBB.......",
        "HH...HHHHHHHHHHHHHH...HH",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        "..dddddddddddddddddddd..",
    ], ["H": hat, "d": hatD, "B": band])
    c.rect(15, 33, 3, 3, duster)

    if shooting {
        // The revolver pointed down at the ground ahead; each shot kicks up a spurt of dust.
        c.rect(38, 34, 3, 3, duster)
        c.pattern(40, 35, ["KK...", "KKKK.", ".KKKK", "...KK"], ["K": C(0x2A2A30)])
        let period = 0.45
        let f = frac(p.t / period)
        let shot = Int(p.t / period)
        let hx = 50 + Int(noise(shot) * 12)
        if f < 0.1 { c.rect(45, 38, 2, 2, C(0xFFE27A)) }
        if f < 0.9 {
            let rise = Int(f * 6)
            let dust = C(0xD8BC8A, 1 - f)
            c.rect(hx, 42 - rise, 1, 2, dust)
            c.rect(hx - 2, 42 - rise / 2, 2, 2, dust)
            c.rect(hx + 1, 42 - rise / 2, 2, 2, dust)
            c.px(hx, 43, C(0xFFE8A0, 0.9 - f))
        }
        return
    }
    if p.fire != nil || p.ready {
        c.oy += p.gunY
        c.rect(38, 33, 3, 3, duster)
        drawPistol(c, x: 40, y: 31, body: C(0x2A2A30), trim: C(0x9A9AA6))
        return
    }
    // At rest: the revolver in its holster at his hip.
    c.rect(38, 33, 3, 3, duster)
    c.pattern(36, 36, [".GG", "HHH", "HHH", ".H."], ["G": C(0x5A5A62), "H": C(0x6A4A2A)])
}

// MARK: - Mr. Stricklaw

/// Mr. Stricklaw: Clawd bald as a cue ball (a shiny dome on top of his head), a grey fringe at the back, a short-sleeved
/// white shirt with a red bow tie, grey trousers and a stern stare. He stays out of fights. Signature: he holds out a
/// pink tardy slip at arm's length.
private func drawMrStricklaw(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0xF2F2EE), shirtD = C(0xCFCFC8), bow = C(0xC8202A), fringe = C(0x9A9A96)
    let sig = p.signature
    let handing = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false

    drawLegs(c, Look(leg: C(0x6A6A6E)), step: p.step)
    cbBoots(c, step: p.step, C(0x2A1E18), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: shirt))
    // The bald dome over the top of his head, and its shine.
    c.rect(21, 24, 14, 2, clawdOrange); c.rect(19, 25, 18, 1, clawdOrange)
    c.rect(34, 24, 1, 2, clawdShade); c.rect(36, 25, 1, 1, clawdShade)
    c.rect(24, 24, 3, 1, C(0xF6B496)); c.px(27, 25, C(0xF6B496))
    // The grey fringe round the back and sides, and the stern brows.
    c.rect(18, 26, 2, 5, fringe); c.px(20, 26, fringe); c.rect(36, 26, 1, 3, fringe)
    c.rect(21, 28, 4, 1, C(0x5A4A40)); c.rect(31, 28, 4, 1, C(0x5A4A40))
    // The shirt and the bow tie.
    c.rect(18, 33, 20, 5, shirt); c.rect(37, 33, 1, 5, shirtD); c.rect(18, 37, 20, 1, shirtD)
    c.rect(18, 37, 20, 1, C(0x3A3A3E))                              // the belt
    c.pattern(25, 32, ["BB.BB", "BBBBB", "BB.BB"], ["B": bow])
    c.rect(15, 33, 3, 3, shirt)

    if handing {
        // The arm straight out, a pink tardy slip held up between finger and thumb.
        let k = sig!
        let out = Int((min(1, (k - 0.08) / 0.15) * 4).rounded())
        c.rect(38, 32, 3 + out, 3, shirt)
        c.rect(41 + out, 32, 2, 2, clawdOrange)
        c.pattern(42 + out, 27, ["PPPPP", "PlllP", "PPPPP", "PllPP", "PPPPP"],
                  ["P": C(0xF6B0C8), "l": C(0xB06080)])
        return
    }
    c.rect(38, 33, 3, 3, shirt)
}

// MARK: - Needles

/// Needles: Clawd as Marty's 1985 rival, a dark mullet (short on top, long down the back of his neck), a black leather
/// jacket over a white tee, grey jeans and black high-tops. He stays out of fights. Signature: he flaps his elbows
/// like a chicken, a loose feather or two drifting off ("Chicken!").
private func drawNeedles(_ c: PixelCanvas, _ p: Pose) {
    let leather = C(0x1E1E24), leatherL = C(0x3E3E48), tee = C(0xF2F2EE)
    let hair = C(0x1E1A18), hairL = C(0x463C34)
    let sig = p.signature
    let flapping = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false
    let flap = flapping && Int(p.t * 10) % 2 == 0 ? 4 : (flapping ? 1 : 0)

    drawLegs(c, Look(leg: C(0x7A7A80)), step: p.step)
    cbBoots(c, step: p.step, C(0x16161A), height: 2)
    c.oy += p.breathe
    // The mullet's long back, down past his neck.
    c.pattern(13, 25, [".HHHH", "HHHHH", "HHHHH", "HHHHh", "HHHH.", "HHHh.", ".HHH.", ".HH..", "..H.."], ["H": hair, "h": hairL])
    drawBody(c, Look(arm: leather), armLeft: flap, armRight: flap)
    c.rect(18, 33, 20, 5, leather); c.rect(37, 33, 1, 5, C(0x0E0E12)); c.rect(18, 37, 20, 1, C(0x0E0E12))
    c.rect(25, 33, 6, 4, tee)
    c.rect(24, 33, 1, 5, leatherL); c.rect(31, 33, 1, 5, leatherL); c.px(23, 33, leatherL); c.px(32, 33, leatherL)
    // Short and spiky on top.
    c.pattern(17, 20, [
        "....H..H..H..H........",
        "...HHHHHHHHHHHHHH.....",
        "..HHHHHhHHHHHhHHHHH...",
        ".HHHHHHHHHHHHHHHHHHH..",
        "HHHHHHHHHHHHHHHHHHHH..",
        "HHHHHHHHHHHHHHHHHHHHH.",
        "HHH.................H.",
    ], ["H": hair, "h": hairL])
    if flapping {
        let f = frac(p.t * 0.7)
        c.pattern(44 + Int(f * 6), 26 + Int(f * 10), ["WW.", ".WW"], ["W": C(0xF4F0E6, 1 - f)])
        let g = frac(p.t * 0.7 + 0.5)
        c.pattern(8 + Int(g * 3), 24 + Int(g * 10), [".WW", "WW."], ["W": C(0xF4F0E6, 1 - g)])
    }
}
