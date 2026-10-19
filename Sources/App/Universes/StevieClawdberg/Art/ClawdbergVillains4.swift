import Foundation

// Villains: The Goonies. Clawd in costume here too: the Fratellys with their hair, coats and plain pistols, the
// Perkinses in a sweater and a suit, and One-Eyed Willy as a pirate skeleton suit over the blocky body.

let clawdbergVillains4: [ClawdbergVillain: Persona] = [
    .mamaFratelly: Persona(name: "Mama Fratelly", weapon: .blaster, shot: .bullet, muzzle: (46, 31), headTop: 20,
                           callout: "Shut up!", draw: drawMamaFratelly),
    .jakeFratelly: Persona(name: "Jake Fratelly", weapon: .blaster, shot: .bullet, muzzle: (46, 31), headTop: 19,
                           signature: 3.2, draw: drawJakeFratelly),
    .francisFratelly: Persona(name: "Francis Fratelly", weapon: .blaster, shot: .bullet, muzzle: (46, 31), headTop: 21,
                              draw: drawFrancisFratelly),
    .troyPerkins: Persona(name: "Troy Perkins", headTop: 20, draw: drawTroyPerkins),
    .elginPerkins: Persona(name: "Elgin Perkins", headTop: 22, signature: 3.0, draw: drawElginPerkins),
    .oneEyedWilly: Persona(name: "One-Eyed Willy", armoured: true, headTop: 18, signature: 3.6, draw: drawOneEyedWilly),
]

// MARK: - Shared bits

private let clear = C(0, 0)

/// Dark shoes on the four feet.
private func shoes(_ c: PixelCanvas, step: Int, _ col: Px = C(0x1E1A18)) { clawdbergBoots(c, step: step, col) }

/// A plain dark pistol in the right hand: aimed level (muzzle at (46, 31)) when shooting, waiting or checking it, or
/// held pointing down by the side.
private func pistol(_ c: PixelCanvas, _ p: Pose, sleeve: Px) {
    let gun = C(0x26262C), grip = C(0x4A3A2E)
    if p.fire != nil || p.ready || p.gunLift > 0 || p.smoke != nil {
        c.oy += p.gunY
        c.rect(38, 32, 3, 3, sleeve)
        c.pattern(40, 31, ["GGGGGG", "GGG...", "Gg....", "gg...."], ["G": gun, "g": grip])
        c.oy -= p.gunY
    } else {
        c.rect(38, 33, 3, 3, sleeve)
        c.pattern(39, 35, ["gG", "gG", ".G", ".G"], ["G": gun, "g": grip])
    }
}

/// A long coat's tails over the legs (shorter seated), leaving the four legs showing below.
private func coatTails(_ c: PixelCanvas, coat: Px, dark: Px, length: Int) {
    let tails = seatedPose ? 1 : length
    c.rect(17, 38, 22, tails, coat); c.rect(17, 37 + tails, 22, 1, dark); c.rect(28, 38, 1, tails, dark)
}

/// A two-pixel music note `k` (0…1) of the way up from (x, y).
private func note(_ c: PixelCanvas, x: Int, y: Int, k: Double, _ col: Px) {
    let yy = y - Int((k * 10).rounded()), a = 1 - k * 0.7
    c.rect(x, yy + 2, 2, 2, col.alpha(a)); c.rect(x + 1, yy, 1, 2, col.alpha(a)); c.px(x + 2, yy, col.alpha(a))
}

// MARK: - Mama Fratelly

/// Mama Fratelly: Clawd with a stiff grey bob and a scowl, her brows down hard, in a long dark coat buttoned up over
/// dark stockings and black shoes. She fights with a plain pistol. No signature: she just shouts.
private func drawMamaFratelly(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x2E2C38), coatD = C(0x1C1A24), coatL = C(0x4A4858)
    let hair = C(0x9A9AA2), hairL = C(0xC4C4CA), hairD = C(0x6E6E76)

    drawLegs(c, Look(leg: C(0x4A3E38)), step: p.step)
    shoes(c, step: p.step)
    c.oy += p.breathe
    coatTails(c, coat: coat, dark: coatD, length: 3)
    drawBody(c, Look(arm: coat))
    // The coat buttoned up to the collar.
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD); c.rect(18, 37, 20, 1, coatD)
    c.rect(23, 33, 10, 1, coatL)
    c.px(28, 34, coatL); c.px(28, 36, coatL)
    // The scowl.
    c.px(21, 27, ink); c.px(22, 27, ink); c.px(23, 28, ink)
    c.px(32, 28, ink); c.px(33, 27, ink); c.px(34, 27, ink)
    c.rect(26, 32, 4, 1, ink); c.px(25, 33, ink); c.px(30, 33, ink)
    // The grey bob, stiff as a helmet.
    c.pattern(16, 20, [
        "......lllllHHHHH......",
        "....llHHHHHHHHHHHH....",
        "..lHHHHHHHHHHHHHHHdd..",
        ".HHHHHHHHHHHHHHHHHHdd.",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHH.........HHHHHHH",
        "HHH...............HHHH",
        "HHH................HHH",
        "HHH................HHH",
        "HHH.................HH",
        "HHd.................Hd",
        "dd..................d.",
    ], ["H": hair, "l": hairL, "d": hairD])
    pistol(c, p, sleeve: coat)
}

// MARK: - Jake Fratelly

/// Jake Fratelly: Clawd with a mop of brown curls bursting out under a dark knitted escape cap, in a pale blue
/// prison-issue shirt and dark jeans. He fights with a plain pistol. Signature: he sings opera, arms flung wide, head
/// back, mouth wide open and the notes pouring out.
private func drawJakeFratelly(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0x8AA6C8), shirtD = C(0x6A86A8), cap = C(0x3A403A), capL = C(0x50584E)
    let curls = C(0x6A4428), curlsL = C(0x8A5E38)
    let sig = p.signature
    let singing = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: C(0x2E3A5A)), step: p.step)
    shoes(c, step: p.step, C(0x3A2A1E))
    c.oy += p.breathe
    // Curls at the back of his neck.
    c.pattern(14, 25, [".CC.", "CcCC", "CCcC", "CCC.", ".CCc", "CC.."], ["C": curls, "c": curlsL])
    drawBody(c, Look(arm: singing ? clear : shirt))
    // The shirt, its collar and a pocket.
    c.rect(18, 34, 20, 4, shirt); c.rect(37, 34, 1, 4, shirtD); c.rect(18, 37, 20, 1, shirtD)
    c.pattern(24, 34, ["WW..WW", ".W..W."], ["W": C(0xC8D8EC)])
    c.rect(32, 35, 3, 2, shirtD)
    // The cap, rolled at the brim, the curls springing out under it.
    c.pattern(16, 19, [
        ".......KKKKKKKK.......",
        ".....KKKKKKKKKKKK.....",
        "...KKKKKKKKKKKKKKKK...",
        "..KKKKKKKKKKKKKKKKKK..",
        ".KKKKKKKKKKKKKKKKKKKK.",
        ".RRRRRRRRRRRRRRRRRRRR.",
        "CcCCcCC.CCcC..CCcCCCC.",
        "CC.C...........C..CcC.",
    ], ["K": cap, "R": capL, "C": curls, "c": curlsL])

    if singing, let k = sig {
        // Head back and mouth wide, arms flung out.
        c.pattern(26, 31, [".kk.", "kRRk", "kRRk", ".kk."], ["k": ink, "R": C(0x6A1A1A)])
        c.rect(12, 28, 6, 3, shirt); c.rect(10, 26, 3, 3, clawdOrange)
        c.rect(38, 28, 6, 3, shirt); c.rect(43, 26, 3, 3, clawdOrange)
        for j in 0..<3 {
            let f = frac(k * 2 + Double(j) / 3)
            note(c, x: 40 + j * 5, y: 22 + j, k: f, ink)
        }
        return
    }
    pistol(c, p, sleeve: shirt)
}

// MARK: - Francis Fratelly

/// Francis Fratelly: Clawd with slicked-back black hair and a thick black moustache, in a long belted tan trench coat
/// with its collar turned up, dark trousers and shoes. He fights with a plain pistol. No signature.
private func drawFrancisFratelly(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0xA88A5A), coatD = C(0x7E663E), coatL = C(0xC4A672), belt = C(0x5A4428)
    let hair = C(0x1A1614), hairL = C(0x3A3430)

    drawLegs(c, Look(leg: C(0x34343C)), step: p.step)
    shoes(c, step: p.step)
    c.oy += p.breathe
    coatTails(c, coat: coat, dark: coatD, length: 4)
    drawBody(c, Look(arm: coat))
    // The trench coat, belted, its collar up at the neck.
    c.rect(18, 34, 20, 4, coat); c.rect(37, 34, 1, 4, coatD); c.rect(18, 37, 20, 1, coatD)
    c.rect(18, 36, 20, 1, belt); c.rect(27, 36, 2, 1, C(0xC8B060))
    c.pattern(18, 32, ["CC................CC", "CCCLL..........LLCCC"], ["C": coat, "L": coatL])
    c.rect(23, 34, 1, 2, coatL); c.rect(32, 34, 1, 2, coatL)
    // The moustache.
    c.pattern(23, 32, ["kkkkkkkkkk", ".kkk..kkk."], ["k": hair])
    // Slicked-back hair.
    c.pattern(17, 21, [
        "......HHHHHHHHHH....",
        "...HHHHHHHHHHHHHHH..",
        ".HHHHHHhhhhhhHHHHHH.",
        "HHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHH..",
        "HHH.................",
        "HH..................",
    ], ["H": hair, "h": hairL])
    pistol(c, p, sleeve: coat)
}

// MARK: - Troy Perkins

/// Troy Perkins: Clawd with swept blond hair and a smirk, in a preppy pale yellow sweater with a blue argyle pattern
/// over a white collared shirt, khaki trousers and brown loafers. He doesn't fight. No signature.
private func drawTroyPerkins(_ c: PixelCanvas, _ p: Pose) {
    let sweater = C(0xE8D890), sweaterD = C(0xC4B46A), argyle = C(0x4A6AB0), hair = C(0xE0C070), hairL = C(0xF4DC96)

    drawLegs(c, Look(leg: C(0xC8B48A)), step: p.step)
    shoes(c, step: p.step, C(0x6A3E22))
    c.oy += p.breathe
    drawBody(c, Look(arm: sweater))
    // The sweater, its argyle diamonds and the shirt collar.
    c.rect(18, 33, 20, 5, sweater); c.rect(37, 33, 1, 5, sweaterD); c.rect(18, 37, 20, 1, sweaterD)
    for x in [20, 26, 32] {
        c.px(x + 1, 34, argyle); c.px(x, 35, argyle); c.px(x + 2, 35, argyle); c.px(x + 1, 36, argyle)
    }
    c.pattern(25, 33, ["WWWWWW", ".W..W."], ["W": white])
    // The smirk.
    c.rect(27, 32, 3, 1, ink); c.px(30, 31, ink)
    // Blond hair swept up and over to one side.
    c.pattern(16, 20, [
        "........llllHHHHH.....",
        ".....HHllllHHHHHHHHH..",
        "...HHHHHHHHHllllHHHHHH",
        "..HHHHHHHHHHHHHHHHHlll",
        ".HHHHHHHHHHHHHHHHHHH..",
        "HHHHHHHHHHHHHHHHHH....",
        "HHH...................",
        "HH....................",
    ], ["H": hair, "l": hairL])
}

// MARK: - Elgin Perkins

/// Elgin Perkins: Clawd with a balding grey fringe and little rectangular glasses, in a grey-brown suit, white shirt
/// and red tie, a briefcase in his hand. He doesn't fight. Signature: he sets the briefcase down and waves the
/// foreclosure papers over his head.
private func drawElginPerkins(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x5A5048), suitD = C(0x3E3630), tie = C(0xB02A2A), hair = C(0xB4B4B8), hairD = C(0x8A8A90)
    let case_ = C(0x5A3A22), caseD = C(0x3A2416), paper = C(0xF6F4EC), line = C(0x9A9AA4)
    let sig = p.signature
    let waving = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false

    drawLegs(c, Look(leg: suit), step: p.step)
    shoes(c, step: p.step)
    if waving {
        // The briefcase set down on the ground beside him.
        c.rect(41, 38, 8, 6, case_); c.rect(41, 38, 8, 1, caseD); c.rect(43, 37, 4, 1, caseD); c.px(45, 40, C(0xC8B060))
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: waving ? clear : suit))
    c.rect(15, 33, 3, 3, suit)
    // The suit, its lapels, the shirt and tie.
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(24, 33, ["dWTTWd", ".dTTd.", "..TT..", "..TT.."], ["d": suitD, "W": white, "T": tie])
    // The glasses.
    c.pattern(20, 28, ["FFFFFF....FFFFFF", "F....FFFFFF....F", "FFFFFF....FFFFFF"], ["F": C(0x3A3A40)])
    // What's left of his hair: a grey fringe round the sides, a few strands combed over.
    c.pattern(16, 23, [
        ".........hhhhh.......",
        "..HHH.hh......hh.HHH.",
        "HHHHH...........HHHHH",
        "HHHH.............HHH.",
        "HHH..............HH..",
        "HH...................",
    ], ["H": hair, "h": hairD])

    guard waving, let k = sig else {
        // The briefcase in his hand.
        c.rect(38, 34, 3, 3, suit)
        c.rect(38, 37, 8, 5, case_); c.rect(38, 37, 8, 1, caseD); c.rect(40, 36, 4, 1, caseD); c.px(42, 39, C(0xC8B060))
        return
    }
    // His arm up over his head, the papers flapping in his hand.
    let flap = Int(k * 16) % 2
    c.rect(38, 24, 3, 11, suit); c.rect(38, 22, 3, 2, clawdOrange)
    c.pattern(36 + flap, 15 - flap, ["PPPPPP", "PllllP", "PPPPPP", "PlllPP", "PPPPPR", "PllPRR"],
              ["P": paper, "l": line, "R": C(0xD83A3A)])
}

// MARK: - One-Eyed Willy

/// One-Eyed Willy: Clawd in a pirate skeleton suit, bones painted over the orange body (a skull face with a dark
/// socket where the eye glints gold and a row of teeth, a ribcage and spine, bone legs), an eye patch over the other
/// eye, a black tricorn trimmed in gold, a tattered red coat with gold buttons hanging open, a gold chain and a gold
/// earring, black boots. He doesn't fight (his traps do), and shots bounce off his bones. Signature: he sits on his
/// heap of treasure, gold coins and a jewelled cup glinting.
private func drawOneEyedWilly(_ c: PixelCanvas, _ p: Pose) {
    let bone = C(0xEEE6D0), boneD = C(0xB8AE94), socket = C(0x3A2018), coat = C(0x8A2A2A), coatD = C(0x5E1A1A)
    let gold = C(0xF0C040), goldD = C(0xB08420), hat = C(0x1E1A1E)
    let sig = p.signature
    let throne = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false
    let wasSeated = seatedPose

    if throne, let k = sig {
        // The treasure heap he sits on: gold coins piled up, a jewelled cup on top, glints running over it.
        c.pattern(12, 36, [
            "..........GGgGGGGgGGGG..........",
            ".......GGGGgGGGGGGGgGGGGGG......",
            ".....GGgGGGGGGgGGGGGGGGgGGGGG...",
            "...GGGGGGGgGGGGGGGgGGGGGGGgGGGG.",
            "..GGgGGGGGGGGGgGGGGGGGgGGGGGGGGG",
            ".GGGGGGgGGGGGGGGGGGGGGGGGGGgGGGG",
            "GGGGGGGGGGGGgGGGGGGGGgGGGGGGGGGG",
            "GGGgGGGGGGGGGGGGGGGGGGGGGGGgGGGG",
        ], ["G": gold, "g": goldD])
        c.pattern(39, 30, ["RRRRR", ".GRG.", "..G..", ".GGG."], ["R": C(0xD8302A), "G": gold])
        let i = Int(k * 12) % 5
        c.px(16 + i * 6, 39 + i % 3, white); c.px(40, 30, white.alpha(Double(i % 2)))
        seatedPose = true
        c.oy -= 4
    }
    drawLegs(c, Look(leg: bone), step: p.step)
    if !seatedPose {
        // Knee joints, and the boots.
        for lx in [19, 23, 31, 35] { c.rect(lx, 39, 2, 1, boneD) }
        clawdbergBoots(c, step: p.step, C(0x1E1A18), height: 2)
    } else {
        // Folded bone legs, a dark joint between each pair so all four read.
        for x in [21, 33] { c.rect(x, 38, 1, 2, boneD) }
        for x in [18, 22, 30, 34] { c.px(x, 39, boneD) }
    }
    seatedPose = wasSeated
    c.oy += p.breathe
    // The coat's tattered tails at the back.
    c.pattern(15, 31, ["CC", "CC", "CC", "CC", "CC", "Cc", "C."], ["C": coat, "c": coatD])
    drawBody(c, Look(arm: coat, eye: nil))
    // The skull: a dark socket with a gold glint, the eye patch and its strap, the nose and the teeth.
    c.rect(21, 28, 4, 4, socket); c.px(22, 29, gold)
    c.rect(31, 28, 4, 4, ink); clawdbergLine(c, 18, 26, 31, 29, ink, 0.45); c.px(35, 28, ink); c.px(36, 27, ink)
    c.px(27, 31, socket); c.px(28, 31, socket)
    c.pattern(23, 32, ["WkWkWkWkW", "kkkkkkkkk"], ["W": bone, "k": ink])
    // The ribcage and spine, the coat hanging open either side with its gold buttons.
    c.rect(27, 34, 2, 4, bone)
    for y in [34, 36] { c.rect(22, y, 12, 1, bone); c.px(21, y + 1, bone); c.px(34, y + 1, bone) }
    c.rect(18, 33, 3, 5, coat); c.rect(35, 33, 3, 5, coat); c.rect(37, 33, 1, 5, coatD)
    c.px(20, 34, gold); c.px(20, 36, gold); c.px(35, 34, gold); c.px(35, 36, gold)
    // The gold chain and the earring.
    for x in stride(from: 22, to: 34, by: 2) { c.px(x, 33, gold); c.px(x + 1, 33, goldD) }
    c.px(18, 30, gold); c.px(18, 31, goldD)
    // The tricorn, trimmed in gold.
    c.pattern(15, 18, [
        "...........KKKK...........",
        ".........KKKKKKKK.........",
        "G.......KKKKKKKKKK.......G",
        "GK......KKKKKKKKKK......KG",
        ".GKK....KKKKKKKKKK....KKG.",
        "..GKKKKKKKKKKKKKKKKKKKKG..",
        "...GGGGGGGGGGGGGGGGGGGG...",
    ], ["K": hat, "G": gold])
    // Bony hands.
    c.rect(15, 35, 3, 1, bone); c.rect(38, 35, 3, 1, bone)
}
