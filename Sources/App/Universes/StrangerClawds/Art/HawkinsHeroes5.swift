import Foundation

// Heroes: the allies who come over to the kids' side (Kali, Suzie, Alexei and Yuri) and season 5's Wheelers, Holly
// and her mother Karen. Clawd in costume like the rest, with Clawd's own orange face showing. Holly is about ten, so
// she stands lower, as Erica does; her blonde hair and book keep her apart from Max.

let hawkinsHeroes5: [HawkinsHero: Persona] = [
    .kali: Persona(name: "Kali", weapon: .lightning,
                   magic: Magic(core: C(0xF8E8FF), glow: C(0xB04ACC), jagged: false, spell: true),
                   headTop: 18, signature: 3.6, draw: drawKali),
    .suzie: Persona(name: "Suzie", headTop: 17, signature: 3.4, draw: drawSuzie),
    .alexei: Persona(name: "Alexei", headTop: 20, signature: 3.0, draw: drawAlexei),
    .yuri: Persona(name: "Yuri", headTop: 17, signature: 3.4, draw: drawYuri),
    .hollyWheeler: Persona(name: "Holly Wheeler", headTop: 21, signature: 4.0, draw: drawHollyWheeler),
    .karenWheeler: Persona(name: "Karen Wheeler", weapon: .saber, headTop: 17, signature: 3.0, draw: drawKarenWheeler),
]

// MARK: - Kali

/// Kali, who was "Eight": dark curly hair pulled up and back off her face, dark smudged make-up round her eyes, a
/// black leather jacket with silver zips and studs on the shoulder over a deep red top, ripped black jeans and black
/// boots. Her illusions are a violet ribbon of sparkles from her raised hand. Signature: she raises that hand, and a
/// ghostly copy of her shimmers up beside her and fades.
private func drawKali(_ c: PixelCanvas, _ p: Pose) {
    let leather = C(0x1E1C22), leatherD = C(0x0E0C12), leatherL = C(0x3E3A46), zip = C(0xB8BCC4)
    let top = C(0x7A1E2A)
    let hair = C(0x1A1210), hairD = C(0x0C0806), hairL = C(0x3A2A24)
    let k = hawkinsSpan(p, 0.06, 0.94)
    let ghost = hawkinsEase(k, edge: 0.3)

    if ghost > 0 {
        // The illusion: a violet copy of her, behind her and a little ahead, faint enough to stay a ghost, flickering
        // as it comes and goes.
        let flick = k < 0.3 || k > 0.7 ? (Int(p.t * 12) % 3 == 0 ? 0.5 : 1) : 1
        let g = C(0xC898F0, 0.2 * ghost * flick), gd = C(0x8A58C0, 0.2 * ghost * flick)
        let gx = -12
        c.rect(18 + gx, 20, 20, 6, gd); c.rect(17 + gx, 23, 2, 8, gd)
        c.rect(18 + gx, 26, 20, 12, g)
        for lx in [19, 23, 31, 35] { c.rect(lx + gx, 38, 2, 5, g) }
        c.rect(22 + gx, 29, 2, 3, gd); c.rect(32 + gx, 29, 2, 3, gd)
    }

    drawLegs(c, Look(leg: C(0x1A1A20)), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.rect(lx, hawkinsFoot(p, i) - 4, 2, 1, C(0xC8865A)) } }
    drawBoots(c, C(0x0E0E12), step: p.step, rows: 2)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i), C(0x3A3A42)) } }

    c.oy += p.breathe
    drawBody(c, Look(arm: leather), armRight: k >= 0 ? max(p.armRaise, 5) : p.armRaise)

    // The dark make-up smudged round her eyes, out to the sides.
    c.rect(21, 28, 4, 1, C(0x2A1A26)); c.rect(31, 28, 4, 1, C(0x2A1A26)); c.px(24, 29, C(0x4A2A3A)); c.px(34, 29, C(0x4A2A3A))
    c.px(20, 29, C(0x2A1A26)); c.px(35, 29, C(0x2A1A26))
    c.rect(26, 32, 4, 1, C(0x5A1A26))

    // The leather jacket, open over the red top: lit lapels and shoulder, studs along it, the zips, the far side in
    // shade, and the cuffs.
    c.rect(18, 33, 20, 5, leather); c.rect(25, 33, 6, 5, top); c.rect(25, 37, 6, 1, C(0x5A1420))
    c.rect(24, 33, 1, 5, leatherL); c.rect(31, 33, 1, 5, leatherD); c.rect(37, 33, 1, 5, leatherD)
    c.rect(19, 33, 4, 1, leatherL); c.px(19, 33, zip); c.px(21, 33, zip); c.px(33, 33, zip); c.px(35, 33, zip)
    c.rect(21, 35, 2, 1, zip); c.rect(34, 35, 2, 1, zip)
    c.rect(18, 37, 7, 1, leatherD); c.rect(31, 37, 7, 1, leatherD)
    c.rect(15, 35, 3, 1, leatherD)

    // Dark curls pulled up and back into a knot at the back of her head, loose curls round her face.
    c.pattern(14, 18, [
        "....HHHH..............",
        "...HlHHhH.............",
        "...HHhHlH.HHHHHHHHH...",
        "....HHHHHHHlHHHlHHHHH.",
        "......HHlHHHHhHHHHhHHH",
        ".....HHHHhHHHHHHlHHHHH",
        "....HHlHHHHhHHHHHHHHHd",
        "....HHHHHHlHHHHhHHHHHd",
        "....HHHH...........HHd",
        "....HhH.............Hd",
        "....HlH.............hd",
    ], ["H": hair, "d": hairD, "h": hairD, "l": hairL])

    guard k >= 0 else { return }
    // Her raised hand glittering as the illusion takes shape.
    if ghost > 0.5 && Int(p.t * 6) % 2 == 0 {
        c.px(42, 27, C(0xE8C8FF, 0.6)); c.px(40, 25, C(0xE8C8FF, 0.4)); c.px(44, 26, C(0xE8C8FF, 0.4))
    }
}

// MARK: - Suzie

/// Suzie, Dustin's girlfriend in Utah: a big cloud of blonde curls held back by a pink headband, big purple glasses
/// and a grin full of braces, a lavender jumper with a white collar, a plaid skirt, white socks and shoes. She doesn't
/// fight. Signature: her ham radio set sits by her feet, and she lifts its microphone on its coiled cord and talks
/// into it, the signal pulsing off the aerial.
private func drawSuzie(_ c: PixelCanvas, _ p: Pose) {
    let jumper = C(0xA890D0), jumperD = C(0x8670B0), jumperL = C(0xC4B0E4), collar = C(0xF4F2EE)
    let skirt = C(0x7A3A4A), skirtL = C(0xA85A6A)
    let hair = C(0xE8C870), hairD = C(0xC4A048), hairL = C(0xF8E4A0)
    let band = C(0xE85A9A), frame = C(0x7A3A8A)
    let k = hawkinsSpan(p, 0.06, 0.94)
    let talking = k >= 0

    if talking {
        // The ham radio set on the ground in front of her: a grey box with its dial, meters and knobs, a tall aerial.
        c.rect(44, 35, 12, 8, C(0x6A6E78)); c.rect(44, 35, 12, 1, C(0x8A8E98)); c.rect(55, 36, 1, 7, C(0x4A4E58))
        c.rect(45, 37, 4, 3, C(0x1E2A22)); c.px(46, 38, C(0x6AE08A)); c.px(47, 38, C(0x6AE08A))
        c.rect(50, 37, 2, 2, C(0x2A2A30)); c.rect(53, 37, 2, 2, C(0x2A2A30)); c.rect(50, 40, 5, 1, C(0x3A3A42))
        c.rect(53, 26, 1, 9, C(0xB8BCC4)); c.px(53, 26, C(0xE8ECF0))
        if Int(p.t * 4) % 2 == 0 && k > 0.15 && k < 0.85 {
            for (dx, dy) in [(-2, -1), (-2, 0), (-2, 1), (2, -1), (2, 0), (2, 1), (-1, -2), (1, -2)] {
                c.px(53 + dx, 26 + dy, C(0xFFE07A, 0.6))
            }
        }
    }

    // Bare legs under the skirt, white socks and shoes.
    drawLegs(c, Look(leg: clawdOrange), step: p.step)
    drawBoots(c, C(0xF2F2EC), step: p.step, rows: 3)
    drawBoots(c, C(0xB8BCC4), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: jumper), armRight: talking ? 3 : 0)

    // The grin with its braces.
    c.pattern(25, 31, ["mmmmmm", "mWsWsm", ".mmmm."], ["m": C(0x5A1A1E), "W": C(0xF4F0E6), "s": C(0xA8B0BC)])

    // The jumper with its white collar, lit along the shoulders, the far side in shade; the plaid skirt over the
    // tops of her legs.
    c.rect(18, 33, 20, 4, jumper)
    c.pattern(24, 33, ["CCC..CCC", ".CC..CC."], ["C": collar])
    c.rect(19, 33, 4, 1, jumperL); c.rect(37, 33, 1, 4, jumperD); c.px(21, 35, jumperD); c.px(34, 35, jumperD)
    c.rect(18, 37, 20, 1, skirt)
    for x in stride(from: 19, to: 38, by: 4) { c.px(x, 37, skirtL) }
    if !seatedPose {
        c.rect(17, 38, 22, 1, skirt); for x in stride(from: 18, to: 39, by: 4) { c.px(x, 38, skirtL) }
    }
    c.rect(15, 35, 3, 1, jumperD)

    // The big cloud of curls, lit in round strokes, the pink headband across the top.
    c.pattern(13, 17, [
        ".......HHHHHHHHHHHHH.......",
        ".....HHlHHlHHlHHlHHHHH.....",
        "...HHlHHhHHlHHhHHlHHHhHH...",
        "..HlHHhHHHHHHHHHHHHHhHHHH..",
        "..BBBBBBBBBBBBBBBBBBBBBBB..",
        ".HHlHHHHhHHlHHHHhHHHlHHhHH.",
        "HlHHhHHlHHhHHlHHhHHlHHlHHhH",
        "HHhHlHHhHlHHhHlHHhHlHHHHlHH",
        "HlHHhHHHlHHHHlHHHHlHHhhHHH.",
        "HHlHH.................HhH..",
        "HhHHl.................HlH..",
        ".HlHh.................hH...",
        "HHhH...................H...",
        ".HH........................",
    ], ["H": hair, "h": hairD, "l": hairL, "B": band])
    // The big purple glasses.
    c.pattern(20, 27, [".FFFFF....FFFFF.", "F.....FFFF.....F", "F.....F..F.....F", ".FFFFF....FFFFF."],
              ["F": frame])

    guard talking else { return }
    // The microphone up at her mouth, its coiled cord running down to the set.
    c.rect(38, 30, 3, 3, jumper)
    c.rect(36, 27, 3, 4, C(0x2A2A30)); c.rect(36, 27, 3, 1, C(0x5A5A64)); c.rect(37, 31, 1, 2, C(0x2A2A30))
    c.rect(38, 29, 3, 2, clawdOrange)
    for i in 0..<6 { c.px(39 + i, 33 + i % 2, C(0x2A2A30)); c.px(42 + i % 3, 34 + i / 2, C(0x2A2A30)) }
}

// MARK: - Alexei

/// Alexei, the Russian scientist who helps: dark hair with a curl falling on his brow, a round, cheerful face, a long
/// pale grey-blue lab coat over a brown jumper, a red star pinned to it, dark trousers and brown shoes, and in his hand,
/// always, a cherry Slurpee. He doesn't fight. Signature: he sips the Slurpee through its straw, the red going up it.
private func drawAlexei(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0xD6DEE6), coatD = C(0xAAB4C0), coatL = C(0xEEF2F6)
    let jumper = C(0x6A4A34), jumperD = C(0x4E3624)
    let hair = C(0x2A2420), hairD = C(0x161210), hairL = C(0x4A3E36)
    let cup = C(0xD8303A), cupD = C(0xA81E28), lid = C(0xF0F0F0)
    let k = hawkinsSpan(p, 0.08, 0.92)
    let sip = hawkinsEase(k, edge: 0.2) > 0.5

    drawLegs(c, Look(leg: C(0x3A3A44)), step: p.step)
    drawBoots(c, C(0x5A3A24), step: p.step, rows: 2)
    drawBoots(c, C(0x3A2416), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: coat), armRight: sip ? 3 : 0)
    c.rect(26, 32, 4, 1, C(0x5A1A1E))
    c.rect(20, 31, 2, 1, C(0xF0906A)); c.rect(34, 31, 2, 1, C(0xF0906A))   // rosy cheeks

    // The lab coat: long, open over the jumper, lapels lit, a pocket, the red star, falling past his hips to the
    // knees, soft shadows hinting at the legs under it.
    c.rect(18, 33, 20, 5, coat); c.rect(25, 33, 6, 5, jumper); c.rect(25, 33, 6, 1, jumperD)
    c.rect(24, 33, 1, 5, coatL); c.rect(31, 33, 1, 5, coatD); c.rect(37, 33, 1, 5, coatD)
    c.rect(19, 33, 4, 1, coatL); c.rect(33, 35, 3, 1, coatD); c.px(20, 34, C(0xD8303A)); c.px(21, 35, C(0xD8303A))
    c.px(20, 35, C(0xF0C040))
    if !seatedPose {
        c.rect(17, 38, 22, 2, coat); c.rect(17, 39, 22, 1, coatD); c.rect(17, 38, 1, 2, coatL)
        for x in [22, 30, 34] { c.px(x, 38, coatD) }
        c.rect(25, 38, 6, 2, C(0x3A3A44))
    }
    c.rect(15, 35, 3, 1, coatD)

    // Dark hair, short, combed over, with a curl falling on his brow.
    c.pattern(17, 20, [
        ".....HHHHHHHHHHHH.....",
        "...HHHlllHHHHHHHHH....",
        "..HHHHHHHlllHHHHHHH...",
        ".HHlHHHHHHHHHHHHHHHd..",
        ".HHHHHHHHHHhHHHHHHHd..",
        ".HHHHHHHHHHHHHHHHHHd..",
        ".HHH.......H......Hd..",
    ], ["H": hair, "d": hairD, "h": hairD, "l": hairL])

    // The Slurpee: a red cup with a white dome lid and a straw; at his hip, or up at his mouth.
    if sip {
        c.rect(38, 30, 3, 3, coat)
        c.pattern(33, 27, [".LL.", "LLLL", "cccc", "cCcc", "cccc", ".cd."], ["L": lid, "c": cup, "C": C(0xF07A80), "d": cupD])
        c.rect(32, 23, 1, 4, C(0xF4F4F4)); c.rect(32, 25, 1, 2, cup); c.px(31, 23, C(0xF4F4F4))
        c.rect(37, 29, 2, 3, clawdOrange)
        return
    }
    c.pattern(39, 30, [".LL.", "LLLL", "cccc", "cCcc", "cccc", ".cd."], ["L": lid, "c": cup, "C": C(0xF07A80), "d": cupD])
    c.rect(41, 27, 1, 3, C(0xF4F4F4))
    c.rect(38, 33, 2, 2, clawdOrange)
}

// MARK: - Yuri

/// Yuri, the smuggler: a brown fur hat with its ear flaps down, a bushy greying beard and moustache, a heavy coat with
/// a shaggy fur collar and fur cuffs, belted, padded trousers and big boots. He doesn't fight. Signature: he takes the
/// lid off a jar of peanut butter, scoops some out on a finger and eats it, delighted.
private func drawYuri(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x5A4A3A), coatD = C(0x3E3226), coatL = C(0x7A6650)
    let fur = C(0x9A7A58), furD = C(0x6E5438), furL = C(0xC0A07A)
    let beard = C(0x7A6A5A), beardD = C(0x564838), beardL = C(0xA89A88)
    let k = hawkinsSpan(p, 0.06, 0.94)
    let eating = k >= 0
    let lick = eating && k > 0.45 && k < 0.8

    drawLegs(c, Look(leg: C(0x4A4E44)), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 4, C(0x383C32)) } }
    drawBoots(c, C(0x2A2420), step: p.step, rows: 3)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx, hawkinsFoot(p, i) - 2, C(0x4A4038)) } }

    c.oy += p.breathe
    drawBody(c, Look(arm: coat), armRight: lick ? 4 : eating ? 1 : 0)

    // The heavy coat: a size bigger than the body, belted, its fur collar shaggy in strokes, the far side and the hem
    // in shade, and a fur cuff on the far sleeve.
    c.rect(17, 33, 22, 5, coat); c.rect(17, 33, 1, 5, coatL); c.rect(38, 33, 1, 5, coatD)
    c.rect(17, 36, 22, 1, C(0x2A2018)); c.rect(27, 36, 2, 1, C(0xA88A50))
    c.rect(28, 34, 1, 2, coatD); c.rect(17, 37, 22, 1, coatD)
    c.pattern(17, 32, ["FfFlFfFlFfF..FfFlFfFlFf", ".FfFFfFFfF....FfFFfFFf.", "..fF..fF........fF..fF."],
              ["F": fur, "f": furD, "l": furL])
    c.rect(14, 34, 4, 2, fur); c.px(14, 34, furL)

    // The bushy beard and moustache, lit in strokes, covering his jaw.
    c.pattern(18, 29, [
        "BB................BB",
        "BBBb..bBBBBBBb..bBBB",
        "BBBBBBBBbmmmbBBBBBBB",
        ".BBlBBdBBBBBBBdBBlB.",
        "..BBBBBlBBBBlBBBBB..",
        "....BBBdBBBBdBBB....",
    ], ["B": beard, "b": beardL, "l": beardL, "d": beardD, "m": C(0x5A1A1E)])
    // His brow under the hat, in its shadow.
    c.rect(19, 23, 18, 3, clawdOrange); c.rect(19, 23, 18, 1, clawdShade)
    // The fur hat: a tall shaggy crown, its front flap turned up, the ear flaps down over his ears.
    c.pattern(15, 17, [
        "......FlFFlFFlFFlF......",
        "....FFlFfFFlFfFFlFFF....",
        "...FFFfFFFfFFFfFFFfFF...",
        "...FlFFFlFFFlFFFlFFFF...",
        "..FFFFFFFFFFFFFFFFFFFF..",
        "..FfFfFfFfFfFfFfFfFfFf..",
        "..FFF..............FFF..",
        "..FfF..............FfF..",
        "..FFF..............FFF..",
        "...ff...............ff..",
    ], ["F": fur, "f": furD, "l": furL])
    c.rect(17, 21, 20, 1, C(0x8A6A48))

    guard eating else { return }
    // The jar in his far hand, held up in front of him: glass, the peanut butter inside, its red lid off; his finger
    // scooping, then up at his mouth.
    c.pattern(36, 31, ["RRRR", "gPPg", "gPPg", "gPPg", ".gg."], ["R": C(0xC8302A), "g": C(0xC8D4DA), "P": C(0xC08A44)])
    if lick {
        c.rect(38, 29, 3, 3, coat); c.rect(30, 30, 3, 2, clawdOrange); c.px(30, 30, C(0xC08A44))
        hawkinsLine(c, 33, 31, 38.5, 30.5, coat, 1.0)
    } else {
        c.rect(40, 31, 2, 2, clawdOrange); c.px(39, 32, C(0xC08A44))
    }
}

// MARK: - Holly Wheeler

/// Holly Wheeler at about ten: long, straight blonde hair with a fringe, a pink striped jumper over a white collar, a
/// denim skirt, white socks and red shoes, and *A Wrinkle in Time* tucked under her arm, its dark blue cover with a
/// pale star. She's small, so she stands lower than the rest. She doesn't fight. Signature: she waves, and Mr. Whatsit,
/// a friendly man in a brown cardigan with a kind smile, is there beside her for a moment, waving back, and then gone.
private func drawHollyWheeler(_ c: PixelCanvas, _ p: Pose) {
    let jumper = C(0xF0A6C0), jumperD = C(0xCC809C), stripe = C(0xF8E8EE)
    let skirt = C(0x5A7AAA), skirtD = C(0x44608A)
    let hair = C(0xF0D480), hairD = C(0xC8A850), hairL = C(0xFFEEB4)
    let book = C(0x22325E), bookL = C(0x3A4E86)
    let k = hawkinsSpan(p, 0.06, 0.94)
    let wave = hawkinsEase(k, edge: 0.15) > 0.5
    let lower = seatedPose ? 0 : 2
    // Mr. Whatsit flickers in, stays a moment, and flickers out again.
    let flick = Int(p.t * 14) % 2 == 0
    let whatsit = k > 0.15 && k < 0.85 && !((k < 0.22 || k > 0.78) && flick)

    if whatsit {
        // Mr. Whatsit, facing her from ahead: a grown man, taller than her, brown hair neatly combed, the cardigan over a
        // cream shirt, brown trousers, a kind smile, a hand up to wave back. He stands on four legs like everyone.
        let card = C(0x8A6A4A), cardD = C(0x6A4E34), cardL = C(0xA88660), shirt = C(0xE8E0CC)
        let trousers = C(0x6A5A48), whair = C(0x6A4A30), whairD = C(0x4A321E)
        let wy = p.breathe
        for (i, lx) in [50, 53, 59, 62].enumerated() {
            c.rect(lx, 38, 2, 5, trousers); c.rect(lx, 43, 2, 1, C(0x2E2018)); if i % 2 == 0 { c.px(lx + 1, 40, C(0x4E4234)) }
        }
        c.rect(49, 17 + wy, 16, 21, clawdOrange); c.rect(49, 37, 16, 1, clawdShade); c.rect(49, 17 + wy, 1, 21, clawdShade)
        c.rect(52, 22 + wy, 2, 3, ink); c.rect(59, 22 + wy, 2, 3, ink)
        c.pattern(53, 26 + wy, ["m....m", ".mmmm."], ["m": C(0x5A1A1E)])
        c.rect(49, 29 + wy, 16, 8, card); c.rect(55, 29 + wy, 4, 4, shirt); c.rect(54, 29 + wy, 1, 8, cardL)
        c.rect(59, 29 + wy, 1, 8, cardD); c.px(58, 33 + wy, C(0xD8C8A0)); c.px(58, 35 + wy, C(0xD8C8A0))
        c.rect(49, 36 + wy, 16, 1, cardD); c.rect(60, 29 + wy, 4, 1, cardL)
        c.pattern(48, 13 + wy, [
            "...HHHHHHHHHH....",
            ".HHHHHHlllHHHHH..",
            "HHHHlllHHHHHHHHH.",
            "HHHHHHHHHHHHHHHHd",
            "Hd............HHd",
        ], ["H": whair, "d": whairD, "l": C(0x8A6644)])
        // His near hand up, waving back at her.
        let sway = Int(p.t * 5) % 2
        c.rect(45, 28 + wy, 4, 3, card); c.rect(44 - sway, 25 + wy, 3, 3, clawdOrange)
    }

    // Socks and red shoes, her bare legs under the skirt.
    drawLegs(c, Look(leg: clawdOrange), step: p.step)
    drawBoots(c, C(0xF2F2EC), step: p.step, rows: 3)
    drawBoots(c, C(0xC8302A), step: p.step, rows: 1)

    // The book under her far arm, behind her.
    c.oy += lower + p.breathe
    c.rect(12, 31, 6, 7, book); c.rect(12, 31, 6, 1, bookL); c.rect(12, 31, 1, 7, bookL)
    c.px(14, 34, C(0xF0E4B0)); c.px(15, 33, C(0xF0E4B0)); c.px(15, 35, C(0xF0E4B0)); c.px(16, 34, C(0xF0E4B0))
    c.rect(17, 32, 1, 5, C(0xE8E0CC))

    drawBody(c, Look(arm: jumper), armRight: wave ? 6 : 0)
    c.pattern(25, 32, ["m....m", ".mmmm."], ["m": C(0x5A1A1E)])

    // The jumper, pink with white stripes, its collar, the far side in shade; the denim skirt over her legs.
    c.rect(18, 33, 20, 4, jumper)
    c.rect(18, 34, 20, 1, stripe); c.rect(18, 36, 20, 1, stripe)
    c.pattern(25, 33, ["WW..WW"], ["W": C(0xFFFFFF)])
    c.rect(37, 33, 1, 4, jumperD); c.px(37, 34, C(0xD8C8CC)); c.px(37, 36, C(0xD8C8CC))
    c.rect(18, 37, 20, 1, skirt); c.rect(27, 37, 1, 1, skirtD)
    if !seatedPose { c.rect(17, 38, 22, 1, skirt); c.rect(17, 38, 1, 1, C(0x7A9ACA)); c.rect(37, 38, 2, 1, skirtD) }
    c.rect(15, 34, 3, 1, jumper); c.rect(15, 35, 3, 1, jumperD)

    // Long straight blonde hair with a fringe, combed down in long lit strokes past her shoulders.
    c.pattern(16, 20, [
        ".....HHHHHHHHHHHH.......",
        "...HHHlllHHHHHlllHH.....",
        "..HHlllHHHHHHHHHlllHH...",
        ".HHlHHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHd.",
        ".HHHHdHHHdHHHdHHHdHHHHd.",
        ".HHHH..............HHHd.",
        ".HlH................HHd.",
        ".HlH................HHd.",
        ".HlHd...............HdH.",
        ".HHHd...............HdH.",
        ".HHHd...............dHH.",
        "..HHd...............dH..",
        "..Hd....................",
    ], ["H": hair, "d": hairD, "l": hairL])

    guard wave else { return }
    // Her hand up, waving.
    let sway = Int(p.t * 5) % 2
    c.rect(39 + sway, 24, 3, 3, clawdOrange); c.px(40 + sway, 23, clawdOrange)
}

// MARK: - Karen Wheeler

/// Karen Wheeler: a big blonde perm, lit in curls, pearl earrings, a dusty-rose quilted dressing gown with a cream
/// trim, tied with its sash and falling to her knees, and fluffy pink slippers; at her side, a glass of red wine. She
/// fights as she did when the Demogorgon came into her kitchen: with a broken wine bottle, its jagged end forward.
/// Signature: she sips her wine.
private func drawKarenWheeler(_ c: PixelCanvas, _ p: Pose) {
    let gown = C(0xC48A92), gownD = C(0x9E6670), gownL = C(0xDCA8AE), trim = C(0xF2E6D6)
    let hair = C(0xEAC878), hairD = C(0xC4A050), hairL = C(0xFAE4A8)
    let k = hawkinsSpan(p, 0.1, 0.9)
    let sip = hawkinsEase(k, edge: 0.25) > 0.5 && p.melee == nil

    drawLegs(c, Look(leg: clawdOrange), step: p.step)
    drawBoots(c, C(0xF0B0C4), step: p.step, rows: 2)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx, hawkinsFoot(p, i) - 1, C(0xFAD0DC)) } }

    c.oy += p.breathe
    drawBody(c, Look(arm: gown), armRight: sip ? 3 : 0)
    c.rect(26, 32, 4, 1, C(0xA83A4A))

    // The dressing gown: quilted in short stitched lines, its cream trim down the front and round the collar, tied
    // with the sash, the far side and the hem in shade, falling over her legs to the knees with a soft shadow beside
    // each leg.
    c.rect(18, 33, 20, 5, gown)
    c.pattern(23, 33, ["T........T", ".T......T.", "..T....T..", "...T..T..."], ["T": trim])
    c.rect(18, 35, 20, 1, gownD); c.rect(26, 35, 3, 2, gownL); c.px(29, 36, gownD)
    for (x, y) in [(20, 34), (33, 34), (21, 37), (34, 37)] { c.rect(x, y, 2, 1, gownD) }
    c.rect(19, 33, 3, 1, gownL); c.rect(37, 33, 1, 5, gownD)
    if !seatedPose {
        c.rect(17, 38, 22, 2, gown); c.rect(17, 40, 22, 1, gownD); c.rect(17, 38, 1, 3, gownL)
        for x in [22, 26, 30, 34] { c.px(x, 39, gownD) }
        c.rect(26, 38, 1, 3, trim)
    }
    c.rect(15, 35, 3, 1, gownD)

    // The perm: big, round blonde curls lit on top, a pearl at her ear.
    c.pattern(14, 17, [
        "........HHHHHHHHHHH......",
        "......HHlHHlHHlHHlHHH....",
        "....HHlHHhHHlHHhHHlHHH...",
        "...HlHHhHHHHhHHHHhHHHHH..",
        "..HHHHHlHHHHHlHHHHHlHHHH.",
        "..HlHHhHHHhHHHHhHHHHhHHH.",
        ".HHHhHHHHHHHHHHHHHHHHhHHH",
        ".HlHHHHlHHHhHHHlHHHHHhHHH",
        "HHhHHHhHHlHHHHhHHHlHhHlHH",
        "HlHHh................HHhH",
        "HHhH.................HlH.",
        ".HlH.................hH..",
        ".HH......................",
    ], ["H": hair, "h": hairD, "l": hairL])
    c.px(37, 30, C(0xF4F2EC))

    if let a = p.melee {
        karenBottle(c, angle: a, trail: p.trail)
        return
    }
    if sip {
        // The glass at her lips, tipped, her hand round its stem.
        c.rect(38, 30, 3, 3, gown)
        c.pattern(30, 26, ["GGGG.", "GwwwG", ".www.", "..G..", "..G..", ".GGG."],
                  ["G": C(0xD4E0E6), "w": C(0x8A1A2E)])
        c.rect(32, 30, 3, 2, clawdOrange)
        return
    }
    // The glass held at her side.
    c.pattern(39, 28, ["G...G", "GwwwG", ".www.", "..G..", "..G..", ".GGG."], ["G": C(0xD4E0E6), "w": C(0x8A1A2E)])
    c.rect(40, 33, 3, 2, clawdOrange)
}

/// Karen's broken wine bottle along `angle` from her hand: the dark green neck in her fist, the shoulder of the
/// bottle, and the jagged broken end, glinting; a smear where a fast swing just was.
private func karenBottle(_ c: PixelCanvas, angle a: Double, trail: [Double]) {
    let h = Sprite.hand
    hawkinsSmear(c, h, trail, from: 5, to: 10, C(0xD8F0E0))
    hawkinsBar(c, h, a, from: -2, to: 4, C(0x1E4A2A), r: 0.6)
    hawkinsBar(c, h, a, from: 4, to: 8.5, C(0x2A6A3A), r: 1.5)
    hawkinsBar(c, h, a, from: 4.5, to: 8, C(0x5AA86A), r: 0.35)
    for (d, side) in [(9.6, 1.4), (10.4, 0.0), (9.4, -1.4)] {
        let b = hawkinsReach(hawkinsReach(h, a, 8.3), a + 90, side)
        let e = hawkinsReach(b, a, d - 8.3)
        hawkinsLine(c, b.x, b.y, e.x, e.y, C(0x8ADCA0), 0.4)
    }
    c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, clawdOrange)
}
