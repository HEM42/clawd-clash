import Foundation

// Villains: the people who hunt the kids. Grigori, the Russians' hitman; Jason Carver, the jock who blames the
// Party; Mayor Kline; and the government's: Dr. Kay and Lieutenant Colonel Sullivan of the army, and Connie Frazier of
// the Department of Energy. Clawd in costume like everyone else, Clawd's orange face showing; most of them shoot.

let hawkinsVillains3: [HawkinsVillain: Persona] = [
    .grigori: Persona(name: "Grigori", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 21, draw: drawGrigori),
    .jasonCarver: Persona(name: "Jason Carver", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 19,
                          draw: drawJasonCarver),
    .mayorKline: Persona(name: "Mayor Kline", headTop: 20, signature: 3.0, draw: drawMayorKline),
    .drKay: Persona(name: "Dr. Kay", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 20, draw: drawDrKay),
    .colonelSullivan: Persona(name: "Lt. Col. Sullivan", weapon: .blaster, shot: .bullet, muzzle: (59, 33), headTop: 19,
                              draw: drawColonelSullivan),
    .connieFrazier: Persona(name: "Connie Frazier", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 20,
                            draw: drawConnieFrazier),
]

/// A black pistol in the right hand (the arm, at (38, 33), is the caller's): the slide lit along the top, the frame
/// and trigger guard, the grip; its muzzle at (47, 32), as the personas have it.
private func menPistol(_ c: PixelCanvas, x: Int = 40, y: Int = 31) {
    c.pattern(x, y, ["SSSSSSS", "KKKKKKK", "KK.K...", "KK....."],
                ["S": C(0x3A3C44), "K": C(0x1E1E24)])
    c.rect(x, y, 6, 1, C(0x5A5E68))
}

// MARK: - Grigori

/// Grigori, the Russians' hitman: a blond crew cut, a heavy moustache and a cold, flat mouth, a long black leather
/// coat buttoned over a black roll-neck, black gloves, dark trousers and black boots. He fights with a pistol, and has
/// no signature move: he just keeps coming.
private func drawGrigori(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x24222A), coatD = C(0x121016), coatL = C(0x464252)
    let hair = C(0xD8C080), hairD = C(0xA88E50), glove = C(0x18181C)

    drawLegs(c, Look(leg: C(0x2A2A32)), step: p.step)
    drawBoots(c, C(0x101014), step: p.step, rows: 3)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 1, C(0x3A3A42)) } }

    c.oy += p.breathe
    drawBody(c, Look(arm: coat))
    // Cold eyes under a heavy brow, the moustache, the flat mouth.
    c.rect(21, 28, 4, 1, clawdShade); c.rect(31, 28, 4, 1, clawdShade)
    c.rect(24, 31, 8, 1, C(0xB89A58)); c.rect(25, 32, 6, 1, C(0x5A2A1E))

    // The leather coat, belted and buttoned to a roll-neck: lit along the shoulders and the left edge where the
    // leather catches the light, its seams, the far side in shade, falling past his hips over the legs.
    c.rect(18, 33, 20, 5, coat); c.rect(25, 33, 6, 1, C(0x18161C))
    c.rect(18, 33, 1, 5, coatL); c.rect(19, 33, 4, 1, coatL); c.rect(33, 33, 3, 1, coatL)
    c.rect(28, 34, 1, 4, coatD); c.px(26, 35, C(0x5A5A62)); c.px(26, 37, C(0x5A5A62))
    c.rect(18, 36, 20, 1, coatD); c.rect(27, 36, 2, 1, C(0x8A8E96))
    c.rect(37, 33, 1, 5, coatD); c.rect(22, 34, 1, 2, coatD)
    if !seatedPose {
        c.rect(17, 38, 22, 2, coat); c.rect(17, 39, 22, 1, coatD); c.rect(17, 38, 1, 2, coatL)
        for x in [22, 30, 34] { c.px(x, 38, coatD) }
        c.rect(28, 38, 1, 2, coatD)
    }
    c.rect(15, 35, 3, 1, glove)

    // The blond crew cut: short, flat on top, lit in short strokes.
    c.pattern(18, 22, [
        "...HHHHHHHHHHHHH....",
        ".HHlHHlHHlHHlHHHH...",
        "HHhHHhHHhHHhHHhHHH..",
        "HHHHlHHHHHHlHHHHHHd.",
    ], ["H": hair, "h": hairD, "l": C(0xF0DCA0), "d": hairD])

    c.oy += p.gunY
    c.rect(38, 33, 3, 3, coat); c.rect(39, 34, 2, 1, glove)
    menPistol(c)
}

// MARK: - Jason Carver

/// Jason Carver, the basketball team's star: feathered blond hair swept back, a smug set to his mouth, the green
/// letterman's jacket with cream sleeves, ribbed cuffs and a big gold "H" on the chest, a white polo collar, jeans
/// and white sneakers. He fights with a pistol, and has no signature move.
private func drawJasonCarver(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x1E5A3A), jacketD = C(0x123E26), jacketL = C(0x2E7A50)
    let sleeve = C(0xEEE6D2), sleeveD = C(0xC8BEA6), gold = C(0xE8BE40), goldD = C(0xA8822A)
    let hair = C(0xE0C070), hairD = C(0xB8984A), hairL = C(0xF6E0A0)

    drawLegs(c, Look(leg: C(0x4E6A96)), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 4, C(0x3A5278)) } }
    drawBoots(c, C(0xF2F2EC), step: p.step, rows: 2)
    drawBoots(c, C(0xB8BCC4), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: sleeve))
    c.rect(26, 32, 4, 1, C(0x5A1A1E)); c.px(30, 31, C(0x5A1A1E))   // a smirk

    // The letterman's jacket: green wool, cream leather sleeves, the striped rib at the collar, cuffs and hem, the
    // snaps down the front, the big chenille "H".
    c.rect(18, 33, 20, 5, jacket)
    c.rect(18, 33, 3, 5, sleeve); c.rect(35, 33, 3, 5, sleeveD); c.rect(18, 33, 1, 5, C(0xFAF6EA))
    c.rect(25, 33, 6, 1, C(0xF4F4F0)); c.pattern(24, 33, ["s......s"], ["s": jacketD])
    c.rect(18, 37, 20, 1, jacketD); for x in stride(from: 18, to: 38, by: 3) { c.px(x, 37, gold) }
    c.rect(28, 34, 1, 3, jacketD); c.px(28, 34, C(0xC8C8CC)); c.px(28, 36, C(0xC8C8CC))
    c.pattern(21, 34, ["G.G", "GGG", "G.g"], ["G": gold, "g": goldD])
    c.rect(22, 33, 2, 1, jacketL); c.rect(31, 34, 3, 1, jacketL)
    c.rect(15, 35, 3, 1, sleeveD)

    // Feathered blond hair, swept up and back, lit in long strokes, covering the tops of his ears.
    c.pattern(16, 19, [
        "........HHHHHHHH........",
        ".....HHHHlllHHHHHHH.....",
        "...HHHHlllHHHHlllHHHH...",
        "..HHHlllHHHHHHHHlllHHH..",
        "..HHHHHHHHHHHHHHHHHHHHd.",
        ".HHHHHHHhHHHHHhHHHHHHHd.",
        ".HHHHHHHHHHHHHHHHHHHHHd.",
        ".HHHH..............HHHd.",
        ".HHH................HHd.",
    ], ["H": hair, "h": hairD, "d": hairD, "l": hairL])

    c.oy += p.gunY
    c.rect(38, 33, 3, 3, sleeve); c.rect(38, 35, 3, 1, gold)
    menPistol(c)
}

// MARK: - Mayor Kline

/// Mayor Kline: dark hair slicked back and shining, a big toothy grin, a cream suit with wide lapels over a pink shirt
/// and a wide striped tie, a red-white-and-blue campaign button, and two-tone shoes. He doesn't fight. Signature: he
/// waves to the crowd, his grin wider than ever.
private func drawMayorKline(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0xE2D6B8), suitD = C(0xBCAE8E), suitL = C(0xF2EAD4), shirt = C(0xF0B4C0)
    let hair = C(0x2A1E18), hairL = C(0x6A5A50)
    let k = hawkinsSpan(p, 0.08, 0.92)
    let waving = hawkinsEase(k, edge: 0.15) > 0.5

    drawLegs(c, Look(leg: suit), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 4, suitD) } }
    drawBoots(c, C(0xF0F0EA), step: p.step, rows: 2)
    drawBoots(c, C(0x5A3A24), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: suit), armRight: waving ? 7 : 0)
    // The big grin, all teeth; wider while he waves.
    if waving {
        c.pattern(23, 31, ["mmmmmmmmmm", "mWWWWWWWWm", ".mmmmmmmm."], ["m": C(0x5A1A1E), "W": C(0xFAF8F0)])
    } else {
        c.pattern(24, 31, ["mmmmmmmm", "mWWWWWWm", ".mmmmmm."], ["m": C(0x5A1A1E), "W": C(0xFAF8F0)])
    }

    // The cream suit: wide lapels lit and shaded, the pink shirt and striped tie in the V, a pocket square, the
    // campaign button, the far side and the hem in shade.
    c.rect(18, 33, 20, 5, suit)
    c.pattern(24, 33, ["LSSSSSSd", "LLSTTSdd", ".LLTTdd.", "...TT..."], ["S": shirt, "T": C(0x2A4A8A), "L": suitL, "d": suitD])
    c.px(27, 34, C(0xC8302A)); c.px(28, 36, C(0xC8302A))
    c.rect(20, 34, 2, 2, C(0xF4F4F4)); c.px(20, 34, C(0xC8302A)); c.px(21, 35, C(0x2A4A8A))
    c.rect(33, 35, 2, 1, suitD); c.rect(19, 33, 4, 1, suitL); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.rect(15, 35, 3, 1, suitD)

    // The slicked-back hair, shining with oil in long lit strokes, short at the sides.
    c.pattern(17, 20, [
        ".....HHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHH...",
        "..HHlllllHHHHlllllHH..",
        ".HHHHHHHHlllllHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHH..............HHH.",
    ], ["H": hair, "l": hairL])

    guard waving else { return }
    // His hand up high, waving side to side to the crowd.
    let sway = Int(p.t * 5) % 2
    c.rect(38 + sway, 22, 3, 3, clawdOrange); c.px(39 + sway, 21, clawdOrange); c.px(41 + sway, 22, clawdOrange)
}

// MARK: - Dr. Kay

/// Dr. Kay, who runs the army's hunt in season 5: short grey-blonde hair swept back, a hard stare, an army officer's
/// dark green service jacket with brass buttons, a row of ribbons and a gold leaf on each shoulder, over a tan shirt
/// and black tie, dark green trousers and polished black shoes. She fights with a pistol, and has no signature move.
private func drawDrKay(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x3A4632), jacketD = C(0x283222), jacketL = C(0x56644A), brass = C(0xD8B048)
    let hair = C(0xC8C0AC), hairD = C(0x9A927E), hairL = C(0xE8E2D2)

    drawLegs(c, Look(leg: C(0x343E2C)), step: p.step)
    drawBoots(c, C(0x101014), step: p.step, rows: 2)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx, hawkinsFoot(p, i) - 1, C(0x4A4A54)) } }

    c.oy += p.breathe
    drawBody(c, Look(arm: jacket))
    c.rect(21, 28, 3, 1, clawdShade); c.rect(32, 28, 3, 1, clawdShade)   // the hard stare
    c.rect(25, 32, 6, 1, C(0x8A3A2E))

    // The service jacket: lapels over the tan shirt and black tie, brass buttons, the ribbons, the shoulder boards
    // with their gold leaves, pockets, the far side and the hem in shade.
    c.rect(18, 33, 20, 5, jacket)
    c.pattern(25, 33, ["SSSSSS", ".STTS.", "..TT.."], ["S": C(0xC8B48A), "T": C(0x141418)])
    c.rect(24, 33, 1, 3, jacketL); c.rect(31, 33, 1, 3, jacketD)
    c.px(28, 36, brass); c.px(28, 37, brass)
    c.pattern(32, 34, ["rbgy", "yrbr"], ["r": C(0xC8302A), "b": C(0x3A5AB0), "g": C(0x3A8A4A), "y": brass])
    c.rect(19, 33, 3, 1, jacketL); c.px(20, 33, brass); c.rect(20, 35, 3, 1, jacketD)
    c.rect(37, 33, 1, 5, jacketD); c.rect(18, 37, 20, 1, jacketD)
    c.rect(15, 35, 3, 1, jacketD)

    // Short grey-blonde hair, swept back from her brow, lit in strokes, cut short over the ears.
    c.pattern(17, 20, [
        "......HHHHHHHHHHH.....",
        "...HHHlllllHHHHHHH....",
        "..HHHHHHHHlllllHHHH...",
        ".HHlllHHHHHHHHHHHHHd..",
        ".HHHHHHHHHHHhHHHHHHHd.",
        ".HHHHHlHHHHHHHHHHHHHd.",
        ".HHH.............HHHd.",
        ".HHd..............Hd..",
    ], ["H": hair, "h": hairD, "d": hairD, "l": hairL])

    c.oy += p.gunY
    c.rect(38, 33, 3, 3, jacket)
    menPistol(c)
}

// MARK: - Lieutenant Colonel Sullivan

/// Lieutenant Colonel Sullivan, who hunts Eleven in season 4: short grey hair under a patrol cap, a hard jaw, woodland
/// camouflage fatigues with a dark load-bearing vest over them, its pouches and straps, and black combat boots. He
/// fights with an assault rifle, and has no signature move.
private func drawColonelSullivan(_ c: PixelCanvas, _ p: Pose) {
    let camo = C(0x6A7448), camoG = C(0x3E4A2A), camoB = C(0x6A4E32), camoK = C(0x22261A)
    let vest = C(0x3A3E2C), vestD = C(0x262A1C), vestL = C(0x50563E)
    let hair = C(0xA8A49C)

    drawLegs(c, Look(leg: camo), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let f = hawkinsFoot(p, i)
            c.px(lx, f - 6, camoG); c.px(lx + 1, f - 5, camoB); c.px(lx, f - 4, camoK)
        }
    }
    drawBoots(c, C(0x141418), step: p.step, rows: 3)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx, hawkinsFoot(p, i) - 2, C(0x3A3A42)) } }

    c.oy += p.breathe
    drawBody(c, Look(arm: camo))
    c.rect(21, 28, 3, 1, clawdShade); c.rect(32, 28, 3, 1, clawdShade)
    c.rect(25, 32, 6, 1, C(0x7A3A2E))

    // The fatigues, blotched green, brown and black, and the vest over them: its straps, pouches lit along the top,
    // a buckle, the far side in shade.
    c.rect(18, 33, 20, 5, camo)
    for (x, y, w, col) in [(18, 33, 3, camoG), (21, 35, 2, camoB), (19, 36, 2, camoK), (35, 34, 2, camoG), (36, 36, 2, camoB)] {
        c.rect(x, y, w, 1, col)
    }
    c.rect(22, 33, 12, 5, vest); c.rect(22, 33, 12, 1, vestL)
    c.rect(23, 35, 3, 2, vestL); c.rect(23, 36, 3, 1, vestD); c.rect(30, 35, 3, 2, vestL); c.rect(30, 36, 3, 1, vestD)
    c.rect(27, 34, 2, 4, vestD); c.rect(22, 37, 12, 1, vestD); c.px(27, 36, C(0x8A8E96))
    c.rect(37, 33, 1, 5, camoK)
    c.rect(15, 35, 3, 1, camoG)

    // Grey hair cut short at the sides under the patrol cap: its flat crown, blotched like the fatigues, and its peak.
    c.rect(18, 25, 20, 1, clawdOrange); c.rect(18, 25, 2, 4, hair); c.rect(36, 25, 2, 3, hair)
    c.pattern(17, 19, [
        "..CCCCCCCCCCCCCCCC....",
        ".CCgCCbCCCgCCkCCCbC...",
        ".CCCCkCCgCCCCbCCCCC...",
        ".CgCCCCCCbCCCgCCCCCk..",
        ".CCCbCCgCCCCCCkCCCCC..",
        ".DDDDDDDDDDDDDDDDDDDPPPP",
        "....................PPPP",
    ], ["C": camo, "g": camoG, "b": camoB, "k": camoK, "D": C(0x4E5636), "P": C(0x4A5232)])

    // The rifle held at the ready across him: the black stock at his shoulder, the receiver and its carry handle, the
    // long barrel and the magazine.
    c.oy += p.gunY
    c.rect(38, 33, 3, 3, camo)
    c.pattern(33, 31, [
        ".........KKK..............",
        "SSSKKKKKKKKKKKKGGGGGGGGGGl",
        "SSSKKKKKKKKKKKKK..........",
        "SS......KK.MM.............",
        "........KK.MM.............",
        "...........MM.............",
    ], ["S": C(0x2A2A30), "K": C(0x1E1E24), "G": C(0x3A3C44), "l": C(0x6A6E78), "M": C(0x2A2A30)])
    c.rect(36, 32, 12, 1, C(0x3A3C44))
    c.rect(39, 33, 3, 2, clawdOrange)
}

// MARK: - Connie Frazier

/// Connie Frazier of the Department of Energy: a neat blonde bob with a fringe, a cold little smile, a grey skirt suit
/// with sharp shoulders over a white blouse, her pass clipped to the lapel, dark tights and black court shoes. She
/// fights with a pistol, and has no signature move.
private func drawConnieFrazier(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x6A6E78), suitD = C(0x4C5058), suitL = C(0x8A8E98)
    let hair = C(0xD8B870), hairD = C(0xAA8C48), hairL = C(0xF0D898)

    drawLegs(c, Look(leg: C(0x3A3438)), step: p.step)
    drawBoots(c, C(0x101014), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    c.rect(26, 32, 4, 1, C(0xA83A4A)); c.px(30, 31, C(0xA83A4A))   // the cold little smile

    // The suit jacket: sharp shoulders lit along the top, lapels over the white blouse, buttons, the pass, the far
    // side in shade; the skirt over the tops of her legs.
    c.rect(18, 33, 20, 5, suit)
    c.pattern(25, 33, ["WWWWWW", ".WWWW.", "..WW.."], ["W": C(0xF4F2EE)])
    c.rect(24, 33, 1, 3, suitL); c.rect(31, 33, 1, 3, suitD)
    c.px(28, 36, C(0x2A2A30)); c.px(28, 37, C(0x2A2A30))
    c.rect(20, 34, 2, 3, C(0xF4F4F4)); c.px(20, 35, C(0x3A6AB0)); c.px(21, 36, C(0x8A8F9C))
    c.rect(18, 33, 5, 1, suitL); c.rect(33, 33, 4, 1, suitL); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    if !seatedPose { c.rect(18, 38, 20, 1, suit); c.rect(18, 39, 20, 1, suitD); for x in [22, 30] { c.px(x, 38, suitD) } }
    c.rect(15, 35, 3, 1, suitD)

    // The blonde bob: a fringe across her brow, smooth to the jaw, lit in strokes, its ends turned under.
    c.pattern(16, 20, [
        "......HHHHHHHHHHH.......",
        "....HHHlllHHHHHHHHH.....",
        "...HHlllHHHHHHlllHHH....",
        "..HHHHHHHHHHHHHHHHHHHd..",
        "..HHHHHHHHHHHHHHHHHHHHd.",
        ".HHHHHHhHHHHHhHHHHHHHHd.",
        ".HHHH..............HHHd.",
        ".HHH................HHd.",
        ".HlH................HHd.",
        ".HHH................HHd.",
        ".HHd................dHd.",
        "..dd................dd..",
    ], ["H": hair, "h": hairD, "d": hairD, "l": hairL])

    c.oy += p.gunY
    c.rect(38, 33, 3, 3, suit)
    menPistol(c)
}
