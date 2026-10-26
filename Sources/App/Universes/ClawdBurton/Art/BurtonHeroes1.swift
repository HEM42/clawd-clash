import Foundation

// Heroes: The Nightmare Before Christmas. Halloween Town's own: Jack Skullington, the Pumpkin King, a skeleton in a
// pinstripe suit; Sallee, the rag doll who keeps sewing herself back together; Zeero, Jack's ghost dog; the Mayor
// with his two faces; and from Christmas Town, Sandy Clawdz. Each is the Clawd block in costume, tinted bone,
// stitched cloth or ghost-sheet where that's what they're made of.

let burtonHeroes1: [BurtonHero: Persona] = [
    .jackSkullington: Persona(name: "Jack Skullington", weapon: .lightning,
                              magic: Magic(core: C(0xFFF0D8), glow: C(0xFF8A2A), jagged: false, waves: true, pulse: true),
                              pivot: jackMouth, headTop: 11, signature: 3.4, callout: "What's this?",
                              draw: drawJackSkullington),
    .sallee: Persona(name: "Sallee", weapon: .none, headTop: 20, signature: 3.6, draw: drawSallee),
    .zeero: Persona(name: "Zeero", weapon: .none, motion: .hover, canSit: false, headTop: 7, signature: 3.0, callout: "Arf!",
                    draw: drawZeero),
    .theMayor: Persona(name: "The Mayor", weapon: .none, bulk: 2, headTop: 12, signature: 3.2, draw: drawMayor),
    .sandyClawdz: Persona(name: "Sandy Clawdz", weapon: .blaster, shot: .thrown(C(0xC8202A)), muzzle: (45, 29),
                          headTop: 17, signature: 3.0, callout: "Ho ho ho!", draw: drawSandyClawdz),
]

/// The front of Jack's gaping mouth: his scare pulses out from there (raised by the pose's `armRaise`).
private let jackMouth = (x: 33.5, y: 26.5)

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// The Clawd block from row `top` down to row 37, its top corners rounded off `round` pixels, in `body` with `shade`
/// down its right side; no arms or eyes.
private func roundBlock(_ c: PixelCanvas, top: Int, round: Int, _ body: Px, _ shade: Px) {
    for y in top...37 {
        let inset = max(0, round - (y - top))
        c.rect(18 + inset, y, 20 - inset * 2, 1, body); c.px(37 - inset, y, shade)
    }
}

// MARK: - Jack Skullington

/// Jack Skullington: the Pumpkin King, a beanpole. A narrow Clawd block (14 wide, 14 tall) on long, thin legs: the
/// top is his bone-white skull, rounded, with huge black eye sockets, two nose slits and a long stitched grin curling
/// up at its ends; the bottom the black pinstripe suit with a heart-shaped white shirt front and a bat for a bow tie,
/// ragged tails behind, the spiky bat-wing collar fanned out from his shoulders, thin sleeves, bony white fingers.
/// He fights by scaring: the skull stretches taller, the eyes turn angry, the mouth gapes full of teeth, both hands
/// come up clawing, and the fright pulses out of his mouth in bone-white arcs with a pumpkin glow. Signature: the
/// scary face at its biggest, then a deep showman's bow.
private func drawJackSkullington(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x1C1A22), stripe = C(0x5A5664), bone = C(0xF2EEE3), boneD = C(0xC8C2B4), shoe = C(0x0C0B0E)
    let sig = p.signature
    let signatureScare = sig.map { $0 > 0.06 && $0 < 0.55 } ?? false
    let dueling: Bool = { if case .zap = p.role { return true } else { return false } }()
    let scaring = signatureScare || p.zap == true || dueling              // pulling the scary face
    let bowK = sig.map { $0 >= 0.6 && $0 < 0.95 ? sin(ramp($0, 0.6, 0.95) * .pi) : 0 } ?? 0
    let stretch = signatureScare ? Int((sin(ramp(sig!, 0.06, 0.55) * .pi) * 4).rounded())
                                 : scaring ? jackThrob(p.t) : 0          // in a fight, gaping wider with each burst
    // The block spans x 21–34; standing, its bottom is row 33 (four rows up on his long legs), seated row 37.
    let x0 = 21, x1 = 34, bottom = seatedPose ? 37 : 33, suitTop = bottom - 4

    // Long, thin legs, one pixel each, and pointed black shoes.
    let legs = [21, 24, 31, 34]
    if seatedPose {
        for lx in legs { c.rect(lx - 1, 38, 3, 2, suit) }
    } else {
        for (i, lx) in legs.enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, bottom - 1, 1, 45 - bottom - (lifted ? 1 : 0), suit)
            c.rect(i < 2 ? lx : lx - 1, lifted ? 41 : 42, 2, 2, shoe)
        }
    }
    c.oy += p.breathe
    let bow = Int((bowK * 3).rounded())
    c.ox += bow; c.oy += bow
    // The ragged tailcoat tails behind, the bat-wing collar fanned out from his shoulders: three small filled spikes a side.
    c.pattern(x0 - 2, bottom, ["KK", "K.", "K."], ["K": suit])
    let dy = Double(suitTop - 34)
    for (tip, b0, b1) in [((15.0, 29.0), (22.0, 33.0), (22.0, 29.0)), ((16.0, 23.0), (22.0, 31.0), (23.0, 27.0)),
                          ((19.0, 19.0), (23.0, 28.0), (25.0, 26.0))] {
        burtonTriangle(c, (tip.0, tip.1 + dy), (b0.0, b0.1 + dy), (b1.0, b1.1 + dy), burtonInk)
        burtonTriangle(c, (56 - tip.0, tip.1 + dy), (56 - b0.0, b0.1 + dy), (56 - b1.0, b1.1 + dy), burtonInk)
    }
    // The skull: the top nine rows of the block in bone, rounded on top, stretched taller while he scares.
    let top = bottom - 13 - stretch
    for y in top..<suitTop {
        let inset = max(0, 2 - (y - top))
        c.rect(x0 + inset, y, 14 - inset * 2, 1, bone); c.px(x1 - inset, y, boneD)
    }
    let pal: [Character: Px] = ["K": burtonInk, "W": bone]
    if scaring {
        // Angry slanted sockets, and the mouth gaping open, full of teeth, down to his collar.
        c.pattern(22, top + 1, ["KK....", "KKK...", "KKKK..", "KKKK..", ".KKK.."], pal)
        c.pattern(28, top + 1, ["....KK", "...KKK", "..KKKK", "..KKKK", "..KKK."], pal)
        c.px(27, top + 6, burtonInk); c.px(28, top + 6, burtonInk)
        c.rect(24, top + 7, 9, suitTop - top - 7, burtonInk)
        c.pattern(24, top + 7, ["KWKWKWKWK"], pal); c.pattern(24, suitTop - 1, ["KWKWKWKWK"], pal)
    } else {
        // Huge oval sockets, two nose slits, the long stitched grin curling up at its ends.
        let socket = [".KK.", "KKKK", "KKKK", "KKKK", ".KK."]
        c.pattern(22, top + 1, socket, pal); c.pattern(30, top + 1, socket, pal)
        c.px(27, top + 6, burtonInk); c.px(28, top + 6, burtonInk)
        c.pattern(22, top + 6, ["K...........K", ".KKKKKKKKKKK.", "...K.K.K.K..."], pal)
    }
    // The suit over the bottom of the block: pinstripes, the heart-shaped shirt front, the bat bow tie.
    c.rect(x0, suitTop, 14, 5, suit)
    for x in stride(from: x0 + 1, to: x1, by: 3) { c.rect(x, suitTop, 1, 5, stripe) }
    c.pattern(25, suitTop, ["WWWWWW", ".WWWW.", "..WW.."], ["W": bone])
    c.pattern(25, suitTop, ["K.KK.K", ".K..K."], ["K": burtonInk])

    if bowK > 0 {
        // Bowing: one arm sweeps across his middle, the other flung out behind him.
        c.rect(26, suitTop + 2, 6, 2, suit); c.pattern(32, suitTop + 1, ["B.B", "BBB"], ["B": bone])
        burtonLine(c, Double(x0), Double(suitTop + 1), Double(x0 - 7), Double(suitTop - 3), suit, 0.6)
        c.pattern(x0 - 10, suitTop - 5, ["B.B", ".BB", "BB."], ["B": bone])
        return
    }
    if scaring {
        // Both bony hands up beside his head, fingers spread like claws.
        burtonLine(c, Double(x0 - 1), Double(suitTop + 1), Double(x0 - 5), Double(top + 4), suit, 0.6)
        burtonLine(c, Double(x1 + 2), Double(suitTop + 1), Double(x1 + 6), Double(top + 4), suit, 0.6)
        c.pattern(x0 - 7, top - 1, ["B.B.B", "B.B.B", ".BBB."], ["B": bone])
        c.pattern(x1 + 4, top - 1, ["B.B.B", "B.B.B", ".BBB."], ["B": bone])
        return
    }
    if p.zap != nil || p.armRaise > 0 {
        // Ready to scare: both hands half up in front of him, bony fingers curled like claws.
        burtonLine(c, Double(x0 - 1), Double(suitTop + 1), Double(x0 - 4), Double(suitTop - 4), suit, 0.6)
        burtonLine(c, Double(x1 + 2), Double(suitTop + 1), Double(x1 + 5), Double(suitTop - 4), suit, 0.6)
        c.pattern(x0 - 6, suitTop - 7, ["B.B", "B.B", ".BB"], ["B": bone])
        c.pattern(x1 + 4, suitTop - 7, ["B.B", "B.B", "BB."], ["B": bone])
        return
    }
    // At rest: thin sleeves hanging at his sides, the bony fingers below the cuffs.
    c.rect(x0 - 2, suitTop - 1, 2, 4, suit); c.pattern(x0 - 3, suitTop + 3, ["B.B.", ".B.B"], ["B": bone])
    c.rect(x1 + 1, suitTop - 1, 2, 4, suit); c.pattern(x1 + 1, suitTop + 3, [".B.B", "B.B."], ["B": bone])
}
/// 2 while a burst of his scream is going out (`screamPeriod`), 0 between: the scary face gaping in time with it.
private func jackThrob(_ t: Double) -> Int { frac(t / screamPeriod) < 0.4 ? 2 : 0 }

// MARK: - Sallee

/// Sallee: Dr. Finkelclawd's rag doll. The Clawd block is her pale-blue stitched cloth: big white eyes glancing to
/// one side under dark lashes, dark lips with stitched seams running out from their corners; long straight red yarn
/// hair over the top and falling down both sides past her waist; a patchwork dress of mustard, teal, lilac, black and
/// pink, cross-stitched; stitched legs. She doesn't fight. Signature: her left arm drops off at the shoulder seam and
/// lands on the floor; she looks down at it, picks it up, sews it back on with a big needle and red thread, and
/// gives it a wiggle to check it holds.
private func drawSallee(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xC8DCEA), skinD = C(0xA4BED2), thread = C(0x1E1E26), red = C(0xD8242A)
    let hair = C(0xC8303A), hairD = C(0x8A1A22), hairL = C(0xE05A5A)
    let sig = p.signature
    let dropK = sig.map { ramp($0, 0.06, 0.2) } ?? 0          // the arm falling
    let lifting = sig.map { $0 >= 0.34 && $0 < 0.45 } ?? false
    let sewing = sig.map { $0 >= 0.45 && $0 < 0.82 } ?? false
    let off = sig.map { $0 > 0.06 && $0 < 0.45 } ?? false     // the arm not on her
    let looking = sig.map { $0 > 0.2 && $0 < 0.45 } ?? false  // eyes down at the arm
    let wiggle = sig.map { $0 >= 0.82 && $0 < 0.95 ? Int((sin(ramp($0, 0.82, 0.95) * .pi * 4) * 1.5).rounded()) : 0 } ?? 0
    let frame = Int(p.t * 8) % 2

    // Stitched legs.
    drawLegs(c, Look(leg: skin), step: p.step)
    if !seatedPose { for lx in [19, 31] { c.px(lx, 41, thread); c.px(lx + 1, 41, thread) } }
    c.oy += p.breathe
    // The long red hair hanging down behind her, past her waist.
    for y in 26...40 where !(seatedPose && y > 38) {
        for x in [15, 16, 17, 38, 39, 40] where !(y > 37 && (x == 15 || x == 40)) {
            c.px(x, y, x % 3 == 0 ? hairD : (x % 5 == 1 ? hairL : hair))
        }
    }
    // The patchwork dress: over the bottom of the block and down over her knees.
    let hem = seatedPose ? 38 : 39
    roundBlock(c, top: 26, round: 0, skin, skinD)
    for y in 33...hem {
        for x in 18...37 {
            let col: Px
            switch y {
            case ..<35: col = x < 28 ? C(0xE0A830) : ((x + y) % 4 == 0 ? C(0x7A3A80) : C(0xB87AB8))
            case ..<37: col = x < 25 ? (y % 2 == 0 ? C(0x2E7A80) : C(0x4A9AA0)) : x < 31 ? C(0x1E1E22)
                                     : (y % 2 == 0 ? C(0xB86A92) : C(0xD88AB0))
            default: col = x < 24 ? ((x + y) % 3 == 0 ? C(0xB86A92) : C(0xD88AB0)) : x < 31 ? C(0xE0A830) : C(0x4A9AA0)
            }
            c.px(x, y, col)
        }
    }
    for x in stride(from: 18, through: 37, by: 2) { c.px(x, 35, thread) }
    c.px(27, 33, thread); c.px(27, 34, thread); c.px(28, 36, thread)
    // Her face on the cloth: big eyes glancing aside (down at the arm while it's off), lashes, the stitched lips.
    c.pattern(21, 28, ["K.K.......K.K.", "WWWW......WWWW", looking ? "WWWW......WWWW" : "WKKW......WKKW",
                       looking ? "WKKW......WKKW" : "WWWW......WWWW"], ["K": thread, "W": C(0xFFFFFF)])
    c.pattern(22, 32, ["K.K.LLLL.K.K", ".K........K."], ["K": thread, "L": C(0x3A1A26)])
    // The red hair over the top of her, parted at the side, a fringe sweeping across.
    c.pattern(16, 20, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHHHHhHHHHHHHH...",
        "..HHHHHHHHHHhHHHHHHHHH..",
        ".HHHHHHHHHHHHhHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHH.......HHH.",
        ".HHHHHH.............HHH.",
        ".HHH................HHH.",
    ], ["H": hair, "h": hairD])

    if off && !lifting {
        // The left arm off: falling, then lying on the floor beside her, a loose red thread trailing from it.
        let ax = 15 - Int((dropK * 7).rounded()), ay = 33 + Int((dropK * 9).rounded())
        c.rect(ax, ay, 3, 2, skin); c.px(ax + 1, ay, thread)
        burtonLine(c, 18, 33.5, Double(ax + 2), Double(ay), red.alpha(0.8), 0.35)
    } else if lifting {
        // Picking it up: her right hand brings it back up to the shoulder.
        c.rect(15, 35, 3, 2, skin); burtonLine(c, 39, 34, 18, 36, skin, 0.9)
    } else {
        c.rect(15, 33 - wiggle, 3, 3, skin); c.px(16, 33 - wiggle, thread)
    }
    if sewing {
        // Sewing it back on: her right hand at the left shoulder, the big needle stabbing in and out, red thread.
        burtonLine(c, 39, 34, 20, Double(32 + frame), skin, 0.9)
        burtonLine(c, 18, Double(31 + frame), 21, Double(27 + frame), C(0xE0E4EC), 0.5)
        burtonLine(c, 21, Double(27 + frame), 24, 25, red, 0.35)
        c.px(17, 33, red); c.px(18, 34, red)
    } else if !lifting {
        c.rect(38, 33, 3, 3, skin); c.px(39, 33, thread)
    }
}

// MARK: - Zeero

/// Zeero: Jack's ghost dog, a little white sheet of a dog floating off the ground: a round crown tapering into a
/// snout with his glowing pumpkin nose on its tip, long floppy ears hanging down past his jaw, two dark eyes, a
/// collar with a tiny bow tie; behind him, no hind legs, just a wispy tail curling away. Bobs gently as he hovers.
/// He doesn't fight. Signature: his nose lights up bright as a jack-o'-lantern, he loops once round in the air, and
/// barks.
private func drawZeero(_ c: PixelCanvas, _ p: Pose) {
    let sheet = C(0xF4F6F2), sheetD = C(0xC8D0D4), nose = C(0xFF6A1A)
    let sig = p.signature
    let glowing = sig.map { $0 > 0.05 && $0 < 0.9 } ?? false
    let loopK = sig.map { ramp($0, 0.25, 0.75) } ?? 0
    // Floating: a slow bob, and in the signature a loop round in the air.
    c.oy += Int((sin(p.t * 2.2) * 1.5).rounded()) - 6
    if loopK > 0 && loopK < 1 {
        let a = loopK * 2 * .pi
        c.ox += Int((sin(a) * 6).rounded()); c.oy += Int(((cos(a) - 1) * 5).rounded())
    }
    // The wispy tail, curling down and away behind him, fading at its end.
    for i in 0..<14 {
        let f = Double(i) / 13
        let x = 22 - f * 12 + sin(f * 3 + p.t * 3) * 2, y = 34 + f * 6 - sin(f * .pi) * 3
        burtonLine(c, x, y, x - 1, y, sheet.alpha(1 - f * 0.7), 2.2 - f * 1.6)
    }
    // The body: a sheet rounding up into his head.
    c.pattern(18, 24, [
        "..........SSSSSSS....",
        "........SSSSSSSSSSS..",
        "......SSSSSSSSSSSSSSS",
        "....SSSSSSSSSSSSSSSSS",
        "..SSSSSSSSSSSSSSSSSSd",
        ".SSSSSSSSSSSSSSSSSSdd",
        "SSSSSSSSSSSSSSSSSSdd.",
        "SSSSSSSSSSSSSSSSdd...",
        ".SSSSSSSSSSSSSdd.....",
        "..SS.SSS.SSdd........",
        "...S..S...S..........",
    ], ["S": sheet, "d": sheetD])
    // His long floppy ears hang from the back of his crown down past his jaw, swinging a beat behind his bob: the
    // far one, darker, peeks out behind the near one.
    let sway = sin(p.t * 2.2 - 0.9)
    func drawEar(_ rows: [(Int, Int, Int)], _ fill: Px, _ edge: Px) {
        for (y, x0, x1) in rows {
            let s = Int((sway * Double(max(0, y - 20)) / 7).rounded())
            c.rect(x0 + s, y, x1 - x0 + 1, 1, fill); c.px(x0 + s, y, edge)
        }
    }
    drawEar([(17, 23, 25), (18, 22, 24), (19, 21, 23), (20, 20, 22), (21, 20, 22), (22, 20, 22), (23, 20, 22),
             (24, 20, 22), (25, 20, 22), (26, 20, 22), (27, 20, 21), (28, 21, 21)], C(0xA4ACB6), C(0x8E96A2))
    // The head: a round crown tapering forward into a snout, the pumpkin nose at its tip; a mouth line under the
    // snout, two eyes, and the collar with its bow tie.
    c.pattern(21, 16, [
        "......SSSSSS",
        "....SSSSSSSSSS",
        "...SSSSSSSSSSSS",
        "..SSSSSSKKSSKKSSS",
        "..SSSSSSKKSSKKSSSSSS",
        "..SSSSSSSSSSSSSSSSSSS",
        "..SSSSSSSSSSSSSSmmmm",
        "...SSSSSSSSSSSdddd",
        "....SSSSSSSSdd",
    ], ["S": sheet, "d": sheetD, "m": C(0x9AA2AA), "K": C(0x1A1A22)])
    c.rect(26, 25, 8, 1, C(0x2A2A30)); c.pattern(29, 25, ["OKO", ".O."], ["O": C(0xE8701A), "K": C(0x2A2A30)])
    drawEar([(16, 25, 27), (17, 24, 26), (18, 23, 25), (19, 22, 24), (20, 22, 24), (21, 22, 24), (22, 22, 24),
             (23, 22, 24), (24, 22, 24), (25, 22, 24), (26, 22, 24), (27, 22, 24), (28, 22, 23), (29, 23, 23)],
            sheetD, C(0xA4ACB6))
    // The nose: a little pumpkin on the tip of his snout, glowing, and lit right up in his signature.
    let glow = glowing ? 1.0 : 0.55 + 0.15 * sin(p.t * 4)
    c.glowLine(42.5, 20.5, 42.5, 20.5, core: C(0xFFD27A, glow), glow: nose.alpha(glow * 0.8), coreR: glowing ? 1.4 : 0.9,
               glowR: glowing ? 4.2 : 2.6)
    c.rect(41, 20, 3, 2, nose); c.px(42, 19, C(0x3A6A1A))
}

// MARK: - The Mayor

/// The Mayor: his block is a cone of a head, narrow at the top and widest at his collar, the hat perched on top: a
/// little brim and a tall, thin, slightly crooked stovepipe. Under it a fat grey coat flaring out like a bell, a white
/// collar with a black spider for a bow tie and a red rosette on his chest; short pinstriped legs; his megaphone.
/// His head has two faces: the happy one, tan, with spiral eyes and a big toothy grin, and the worried one, pale,
/// with droopy eyes and a zigzag frown, which he wears whenever his session needs you. Signature: his head spins
/// round from one face to the other and back.
private func drawMayor(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x6A6E78), coatD = C(0x4A4E58), coatL = C(0x8A8E98), ink = C(0x16161B), red = C(0xC8202A)
    let sig = p.signature
    let worriedNow = p.ready || p.urgent
    // The spin: the head turns one full round, the other face coming past at the halfway point.
    let turn = sig.map { ramp($0, 0.08, 0.92) * 2 * .pi } ?? 0
    let squash = abs(cos(turn)), backFace = cos(turn) < 0
    let worried = backFace != worriedNow

    // Short pinstriped legs.
    drawLegs(c, Look(leg: C(0x24242C)), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, p.step >= 0 && i % 2 == p.step ? 39 : 40, coatL) }
    }
    burtonBoots(c, step: p.step, ink, height: 1)
    c.oy += p.breathe
    // The bell of a coat: over the bottom of him and flaring out wide over his legs.
    for y in 33...(seatedPose ? 38 : 39) {
        let hw = 10 + (y - 33) * 2 / 3
        c.rect(28 - hw, y, hw * 2, 1, coat); c.px(28 - hw, y, coatL); c.px(28 + hw - 1, y, coatD)
    }
    for y in 35...39 { c.px(29 + (y - 35) / 2, y, coatD) }
    // The cone of a head: narrow on top, widest at his collar; squashed sideways while it spins.
    let skin = worried ? C(0xD8E2EA) : C(0xE8B888), skinD = worried ? C(0xA8B8C8) : C(0xC8946A)
    for r in 0..<11 {
        let hw = max(1, Int((Double(5 + r * 5 / 10) * max(0.2, squash)).rounded()))
        c.rect(28 - hw, 22 + r, hw * 2, 1, skin); c.px(28 + hw - 1, 22 + r, skinD)
    }
    if squash > 0.55 {
        func fx(_ dx: Int) -> Int { 28 + Int((Double(dx) * squash).rounded()) }
        if worried {   // droopy, half-shut eyes and a zigzag frown
            for ex in [-5, 3] { c.rect(fx(ex), 27, 3, 1, C(0x4A5A6A)); c.rect(fx(ex), 28, 3, 1, ink) }
            c.rect(fx(-5), 30, 11, 2, ink); c.pattern(fx(-4), 30, ["W.W.W.W.W", ".W.W.W.W."], ["W": C(0xF0ECE0)])
        } else {       // spiral eyes and a big toothy grin
            for ex in [-5, 3] { c.pattern(fx(ex), 26, ["KKK", "K.K", "KK."], ["K": ink]) }
            c.rect(fx(-6), 30, 13, 2, ink); c.rect(fx(-5), 30, 11, 1, C(0xF0ECE0)); c.px(fx(-7), 29, ink); c.px(fx(6), 29, ink)
        }
    }
    // The white collar, the spider bow tie, the rosette.
    c.pattern(22, 33, ["WWWWWWWWWWWW", "..WWWWWWWW.."], ["W": C(0xF0ECE0)])
    c.pattern(26, 33, ["K...K", ".KKK.", "KKKKK", ".KKK.", "K...K"], ["K": ink])
    c.pattern(19, 34, [".R.", "RWR", ".R.", "R.R"], ["R": red, "W": C(0xF0ECE0)])
    // The hat perched on top: a little brim and the tall, thin, crooked stovepipe with a pale band.
    c.rect(24, 21, 8, 1, C(0x1E1E26))
    c.rect(27, 18, 3, 3, C(0x8A8E98))
    for y in 9..<18 { c.rect(27 + (18 - y) / 4 - 1, y, 3, 1, y % 4 == 0 ? C(0x2A2A34) : C(0x1E1E26)) }
    // Short arms in grey sleeves, and the megaphone in his right hand.
    c.rect(14, 33, 4, 3, coat); c.px(14, 36, C(0xE8B888))
    c.rect(38, 33, 3, 3, coat)
    c.pattern(41, 30, ["......M", "....MMM", "..MMMMM", "HMMMMMM", "..MMMMM", "....MMM", "......M"],
              ["M": C(0xB8BCC4), "H": C(0x6A6A74)])
}

// MARK: - Sandy Clawdz

/// Sandy Clawdz: Clawd in the red hat with its white fur band, its tip and bobble drooping behind, a big white beard
/// over the bottom of him with rosy cheeks above it, the red coat with a black belt and gold buckle, fur at its hem,
/// black boots, and his sack of presents over his shoulder. He throws wrapped presents. Signature: he pats his round
/// tummy, which bounces, and laughs.
private func drawSandyClawdz(_ c: PixelCanvas, _ p: Pose) {
    let red = C(0xC8202A), redD = C(0x8E1418), fur = C(0xF4F4F0), furD = C(0xD0D4D8), mitt = C(0x141418)
    let sig = p.signature
    let patting = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false
    let bounce = patting ? (Int(p.t * 6) % 2) : 0

    drawLegs(c, Look(leg: red), step: p.step)
    burtonBoots(c, step: p.step, mitt, height: 3)
    c.oy += p.breathe
    // The sack over his left shoulder, behind him.
    c.pattern(8, 24, ["...BBB...", ".BBBBBBB.", "BBBBBBBBB", "BBBbBBBBB", "BBBBBBbBB", "BBBBBBBBB", ".BBBBBBB.", "..BBBBB.."],
              ["B": C(0x8A6A3A), "b": C(0x6A4E2A)])
    // The coat's skirt over his legs, fur at its hem; the coat over the bottom of him, the tummy bouncing as he pats it.
    c.rect(17 - bounce, 38, 22 + bounce * 2, seatedPose ? 1 : 2, red); c.rect(17 - bounce, seatedPose ? 38 : 39, 22 + bounce * 2, 1, fur)
    drawBody(c, Look(arm: red))
    c.rect(18 - bounce, 33, 20 + bounce * 2, 5, red); c.rect(37 + bounce, 33, 1, 5, redD)
    c.rect(18 - bounce, 36, 20 + bounce * 2, 1, mitt); c.pattern(26, 36, ["GGGG"], ["G": C(0xE8B830)])
    // Rosy cheeks, and the big white beard over the bottom of his face.
    c.px(20, 31, C(0xE88A8A)); c.px(35, 31, C(0xE88A8A))
    c.pattern(18, 32, ["BB................BB", "BBBBBBBB....BBBBBBBB", ".BBBBBBBBBBBBBBBBBB.", "..BBBBbBBBBBBbBBBB..",
                       "....BBBBBBBBBBBB....", "......BBBBBBBB......"], ["B": fur, "b": furD])
    // The hat: red over the top of him, its fur band at his brow, the tip and bobble drooping behind.
    c.pattern(17, 19, [
        "........RRRRRR........",
        "......RRRRRRRRRR......",
        "...RRRRRRRRRRRRRRRR...",
        "..RRRRRRRRRRRRRRRRRR..",
        "FFFFFFFFFFFFFFFFFFFFFF",
        "FFFFFFFFFFFFFFFFFFFFFF",
        "FFFfFFFFFFFFFFFfFFFFFF",
    ], ["R": red, "F": fur, "f": furD])
    c.pattern(12, 19, ["..RRRR", ".RR...", "RR....", "FFF...", "FFF..."], ["R": red, "F": fur])
    // Arms: patting the tummy, a present raised to throw, or mittens at his sides.
    if patting {
        c.rect(20 - bounce, 35, 3, 3, mitt); c.rect(33 + bounce, 35, 3, 3, mitt)
        return
    }
    c.rect(15, 36, 3, 2, mitt)
    if p.fire != nil || p.ready || p.gunLift > 0 {
        c.oy += p.gunY
        c.rect(38, 30, 3, 3, red)
        c.pattern(41, 26, ["RRYRR", "RRYRR", "YYYYY", "RRYRR", "RRYRR"], ["R": red, "Y": C(0xF0D040)])
        return
    }
    c.rect(39, 36, 3, 2, mitt)
}
