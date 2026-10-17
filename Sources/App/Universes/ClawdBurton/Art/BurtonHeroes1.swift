import Foundation

// Heroes: The Nightmare Before Christmas. Halloween Town's own: Jack Skullington, the Pumpkin King, a tall skeleton in
// a pinstripe suit; Sallee, the rag doll who keeps sewing herself back together; Zeero, Jack's ghost dog; the Mayor
// with his two faces; and from Christmas Town, Sandy Clawz. Here the blocky Clawd is bone, cloth, stitches and
// ghost-sheet as much as orange.

let burtonHeroes1: [BurtonHero: Persona] = [
    .jackSkullington: Persona(name: "Jack Skullington", weapon: .lightning,
                              magic: Magic(core: C(0xFFF0D8), glow: C(0xFF8A2A), jagged: false, waves: true, pulse: true),
                              pivot: jackMouth, headTop: 7, signature: 3.4, callout: "What's this?",
                              draw: drawJackSkullington),
    .sallee: Persona(name: "Sallee", weapon: .none, headTop: 10, signature: 3.6, draw: drawSallee),
    .zeero: Persona(name: "Zeero", weapon: .none, motion: .hover, canSit: false, headTop: 14, signature: 3.0, callout: "Arf!",
                    draw: drawZeero),
    .theMayor: Persona(name: "The Mayor", weapon: .none, bulk: 3, headTop: 0, signature: 3.2, draw: drawMayor),
    .sandyClawz: Persona(name: "Sandy Clawz", weapon: .blaster, shot: .thrown(C(0xC8202A)), muzzle: (46, 28), bulk: 3,
                         headTop: 15, signature: 3.0, callout: "Ho ho ho!", draw: drawSandyClawz),
]

/// The front of Jack's gaping mouth: his scare pulses out from there (raised by the pose's `armRaise`).
private let jackMouth = (x: 37.5, y: 21.5)

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

// MARK: - Jack Skullington

/// Jack Skullington: the Pumpkin King, tall and thin. An egg-shaped bone-white skull on a thin neck, huge black eye
/// sockets, two nose slits and a long stitched grin curling up at its ends; the spiky bat-wing collar fanned out
/// behind his head; a black pinstripe suit with a heart-shaped white shirt front and a bat for a bow tie, ragged
/// tailcoat tails, long thin arms and bony white fingers. He fights by scaring: he pulls his scary face, hands up
/// clawing, and the fright pulses out of his gaping mouth in bone-white arcs with a pumpkin glow. Signature: the
/// scary face at its biggest, the skull stretching tall, then a deep showman's bow.
private func drawJackSkullington(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x1C1A22), suitD = C(0x121016), stripe = C(0x5A5664), bone = C(0xF2EEE3), boneD = C(0xC8C2B4)
    let sig = p.signature
    let signatureScare = sig.map { $0 > 0.06 && $0 < 0.55 } ?? false
    let dueling: Bool = { if case .zap = p.role { return true } else { return false } }()
    let scaring = signatureScare || p.zap == true || dueling              // pulling the scary face
    let bowK = sig.map { $0 >= 0.6 && $0 < 0.95 ? sin(ramp($0, 0.6, 0.95) * .pi) : 0 } ?? 0
    let stretch = signatureScare ? Int((sin(ramp(sig!, 0.06, 0.55) * .pi) * 5).rounded())
                                 : scaring ? 1 + jackThrob(p.t) : 0      // in a fight, gaping wider with each burst of the scream

    // Long thin pinstriped legs and black shoes.
    drawLegs(c, Look(leg: suit), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() { c.rect(lx + 1, p.step >= 0 && i % 2 == p.step ? 36 : 37, 1, 4, stripe) }
    }
    burtonBoots(c, step: p.step, C(0x0C0B0E))
    c.oy += p.breathe
    // The bow: the whole upper body tips forward and down.
    let bow = Int((bowK * 3).rounded())
    c.ox += bow; c.oy += bow
    // The ragged tailcoat tails hanging behind, over the back legs.
    c.pattern(17, 36, ["KKKKKK", "KKKKK.", "KK.KK.", "K..K..", "K....."], ["K": suit])
    // The suit, narrower than Clawd: pinstripes, the heart-shaped shirt front and the bat bow tie.
    c.rect(20, 26, 16, 12, suit); c.rect(35, 26, 1, 12, suitD); c.rect(20, 37, 16, 1, suitD)
    for x in stride(from: 21, to: 35, by: 3) { c.rect(x, 27, 1, 11, stripe) }
    c.pattern(24, 27, ["WWW..WWW", "WWWWWWWW", "WWWWWWWW", ".WWWWWW.", "..WWWW..", "...WW..."], ["W": bone])
    c.pattern(24, 26, ["K.KKKK.K", ".KWKKWK.", "..K..K.."], ["K": burtonInk, "W": bone])
    // The spiky bat-wing collar, fanned out behind his head: three broad spikes a side.
    for (tip, b0, b1) in [((11.0, 24.0), (21.0, 27.0), (23.0, 23.0)), ((13.0, 18.0), (22.0, 25.0), (24.0, 21.0)),
                          ((17.0, 14.0), (23.0, 23.0), (25.0, 19.0))] {
        burtonTriangle(c, tip, b0, b1, burtonInk)
        burtonTriangle(c, (56 - tip.0, tip.1), (56 - b0.0, b0.1), (56 - b1.0, b1.1), burtonInk)
    }
    // The thin white neck.
    c.rect(27, 22, 2, 4, bone); c.px(28, 23, boneD)
    // The egg-shaped skull, stretched taller by `stretch` rows while he scares.
    drawJackSkull(c, top: 7 - stretch, stretch: stretch, scary: scaring, bone: bone, shade: boneD)

    if bowK > 0 {
        // Bowing: one arm sweeps across his middle, the other flung out behind him.
        c.rect(26, 33, 9, 2, suit); c.pattern(35, 32, ["B.B", "BBB"], ["B": bone])
        burtonLine(c, 19, 29, 11, 26, suit, 1.0); c.pattern(8, 24, ["B.B", ".BB", "BB."], ["B": bone])
        return
    }
    if scaring {
        // Both bony hands up beside his head, fingers spread like claws.
        burtonLine(c, 19, 29, 13, 18, suit, 1.0); burtonLine(c, 36, 29, 42, 18, suit, 1.0)
        c.pattern(11, 13, ["B.B.B", "B.B.B", ".BBB."], ["B": bone]); c.pattern(40, 13, ["B.B.B", "B.B.B", ".BBB."], ["B": bone])
        return
    }
    if p.zap != nil || p.armRaise > 0 {
        // Ready to scare: both hands half up in front of him, bony fingers curled like claws.
        burtonLine(c, 19, 29, 15, 24, suit, 1.0); burtonLine(c, 36, 29, 41, 24, suit, 1.0)
        c.pattern(13, 21, ["B.B", "B.B", ".BB"], ["B": bone]); c.pattern(40, 21, ["B.B", "B.B", "BB."], ["B": bone])
        return
    }
    // At rest: the long arms hanging, the bony fingers below the cuffs.
    c.rect(18, 29, 2, 9, suit); c.pattern(17, 38, [".B.", "BBB", "B.B"], ["B": bone])
    c.rect(36, 29, 2, 9, suit); c.pattern(36, 38, [".B.", "BBB", "B.B"], ["B": bone])
}

/// 1 while a burst of his scream is going out (`screamPeriod`), 0 between: the scary face gaping in time with it.
private func jackThrob(_ t: Double) -> Int { frac(t / screamPeriod) < 0.4 ? 2 : 0 }

/// Jack's skull, 18 across from x 19, its top on row `top`: round above, narrowing to the chin. `stretch` extra rows
/// open between the eyes and the mouth; `scary`: angry eyes and a huge gaping mouth full of teeth.
private func drawJackSkull(_ c: PixelCanvas, top: Int, stretch: Int, scary: Bool, bone: Px, shade: Px) {
    let pal: [Character: Px] = ["B": bone, "b": shade, "K": burtonInk, "W": bone]
    c.pattern(19, top, [
        "......BBBBBB......",
        "....BBBBBBBBBB....",
        "..BBBBBBBBBBBBBB..",
        ".BBBBBBBBBBBBBBBb.",
    ] + (scary ? [
        ".BBBKKBBBBBBKKBBb.",
        "BBKKKKKBBBBKKKKKbb",
        "BBKKKKKBBBBKKKKKBb",
        "BBBKKKKBBBBKKKKBBb",
        "BBBBKKBBBBBBKKBBBb",
    ] : [
        ".BBKKKBBBBBBKKKBb.",
        "BBKKKKKBBBBKKKKKbb",
        "BBKKKKKBBBBKKKKKBb",
        "BBKKKKKBBBBKKKKKBb",
        "BBBKKKBBBBBBKKKBBb",
    ]), pal)
    let lower = top + 9
    if scary {
        c.pattern(19, lower, ["BBBBBBBBKBKBBBBBBb", ".BKKKKKKKKKKKKKKb.", ".BKWKWKWKWKWKWKKb."], pal)
        for r in 0..<(stretch + 1) { c.pattern(19, lower + 3 + r, [".BKKKKKKKKKKKKKKb."], pal) }
        c.pattern(19, lower + 4 + stretch, [".BKWKWKWKWKWKWKKb.", "..BKKKKKKKKKKKKb..", "...BBBBBBBBBBBb...", ".....BBBBBBBb....."],
                  pal)
    } else {
        c.pattern(19, lower, [
            "BBBBBBBBKBKBBBBBBb",
            ".BKBBBBBBBBBBBBKb.",
            ".BBKKKKKKKKKKKKBb.",
            "..BBKBKBKBKBKBBb..",
            "...BBBBBBBBBBBb...",
            ".....BBBBBBBb.....",
            ".......bbbb.......",
        ], pal)
    }
}

// MARK: - Sallee

/// Sallee: Dr. Finkelclawd's rag doll. A tall pale-blue face on a thin stitched neck, big white eyes glancing to one
/// side under dark lashes, dark lips and black stitched seams running out from the corners of her mouth; long
/// straight red yarn hair parted at the side and falling past her waist; a patchwork dress of mustard, teal, lilac,
/// black and pink, cross-stitched at the seams; long thin stitched arms and legs. She doesn't fight. Signature: her
/// left arm drops off at the shoulder seam and lands on the floor; she looks down at it, picks it up, sews it back
/// on with a big needle and red thread, and gives it a wiggle to check it holds.
private func drawSallee(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xC8DCEA), skinD = C(0xA4BED2), thread = C(0x1E1E26), red = C(0xD8242A)
    let hair = C(0xC8303A), hairD = C(0x8A1A22), hairL = C(0xE05A5A)
    let sig = p.signature
    let dropK = sig.map { ramp($0, 0.06, 0.2) } ?? 0          // the arm falling
    let lifting = sig.map { $0 >= 0.34 && $0 < 0.45 } ?? false
    let sewing = sig.map { $0 >= 0.45 && $0 < 0.82 } ?? false
    let off = sig.map { $0 > 0.06 && $0 < 0.45 } ?? false     // the arm not on her
    let looking = sig.map { $0 > 0.2 && $0 < 0.45 } ?? false  // eyes down at the arm
    let wiggle = sig.map { $0 >= 0.82 && $0 < 0.95 ? sin(ramp($0, 0.82, 0.95) * .pi * 4) * 25 : 0 } ?? 0
    let frame = Int(p.t * 8) % 2

    // Long thin stitched legs.
    drawLegs(c, Look(leg: skin), step: p.step)
    if !seatedPose { for lx in [19, 31] { c.px(lx, 41, thread); c.px(lx + 1, 41, thread) } }
    c.oy += p.breathe
    // The long red hair hanging down behind her, in strands.
    for y in 9...38 {
        let top = y - 9
        let x0 = top < 4 ? 22 - top * 2 : 17, x1 = top < 4 ? 33 + top * 2 : 38
        for x in x0...x1 {
            if y > 33, x > 21, x < 34 { continue }                       // the ends hang at her sides
            if y > 35, (x + y) % 3 == 0 { continue }                     // ragged ends
            c.px(x, y, x % 3 == 0 ? hairD : (x % 5 == 1 ? hairL : hair))
        }
    }
    // The patchwork dress: a narrow bodice flaring to a hem over her knees.
    let hem = seatedPose ? 38 : 40
    for y in 28...hem {
        let flare = (y - 28) / 4
        for x in (21 - flare)...(34 + flare) {
            let col: Px
            switch y {
            case ..<33: col = x < 28 ? C(0xE0A830) : ((x + y) % 4 == 0 ? C(0x7A3A80) : C(0xB87AB8))
            case ..<37: col = x < 26 ? (y % 2 == 0 ? C(0x2E7A80) : C(0x4A9AA0)) : x < 31 ? C(0x1E1E22)
                                     : (y % 2 == 0 ? C(0xB86A92) : C(0xD88AB0))
            default: col = x < 25 ? ((x + y) % 3 == 0 ? C(0xB86A92) : C(0xD88AB0)) : x < 30 ? C(0xE0A830) : C(0x4A9AA0)
            }
            c.px(x, y, col)
        }
    }
    for y in stride(from: 28, through: 32, by: 2) { c.px(27, y, thread); c.px(28, y, thread) }   // cross-stitched seams
    for x in stride(from: 20, through: 35, by: 2) { c.px(x, 33, thread); c.px(x, 37, thread) }
    // The thin stitched neck.
    c.rect(27, 25, 2, 4, skin); c.px(27, 27, thread); c.px(28, 26, thread)
    // The tall pale face: big eyes with lashes, dark lips, and the stitched seams from her mouth.
    c.pattern(21, 12, [
        "....FFFFFF....",
        "..FFFFFFFFFF..",
        ".FFFFFFFFFFFf.",
        "FFFFFFFFFFFFFf",
        "FKKWWFFFFWWKKf",
        "FKWWWWFFWWWWKf",
        looking ? "FFWWWWFFWWWWFf" : "FFWWKWFFWWKWFf",
        looking ? "FFFKWFFFFKWFFf" : "FFFWWFFFFWWFFf",
        "FFFFFFFFFFFFFf",
        "FFKFFFFFFFFKFf",
        "FKFKFLLLLFKFKf",
        ".FKFFFLLFFFKf.",
        "..FFFFFFFFFf..",
        "....FFFFFf....",
    ], ["F": skin, "f": skinD, "W": C(0xFFFFFF), "K": thread, "L": C(0x3A1A26)])
    // The side-parted fringe sweeping across her forehead.
    c.pattern(20, 10, ["..HHHHHHhHHHH...", ".HHHHHHHHhHHHHH.", "HHHHHHHHHHhH....", "HHHH.HHH........"],
                      ["H": hair, "h": hairD])

    // The arms: long and thin, a stitch at each elbow.
    func arm(_ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double) {
        burtonLine(c, x0, y0, x1, y1, skin, 0.9)
        c.px(Int(((x0 + x1) / 2).rounded()), Int(((y0 + y1) / 2).rounded()), thread)
        c.rect(Int(x1.rounded()) - 1, Int(y1.rounded()), 2, 2, skin)
    }
    if off && !lifting {
        // The left arm off: falling, then lying on the floor beside her, a loose thread trailing from it.
        let ax = 19.5 - 9.5 * dropK, ay = 29.0 + 13 * dropK
        arm(ax, ay, ax - 2 * (1 - dropK) + 8 * dropK, ay + 8 * (1 - dropK))
        burtonLine(c, 20, 29.5, ax, ay, red.alpha(0.8), 0.35)
    } else if lifting {
        // Picking it up: her right hand brings it back up to the shoulder.
        arm(19.5, 29, 16, 35); arm(36, 29, 19, 33)
    } else {
        let a = wiggle * .pi / 180
        arm(19.5, 29, 19.5 - sin(a + 0.25) * 8.3, 29 + cos(a + 0.25) * 8.3)
    }
    if sewing {
        // Sewing it back on: her right hand at the left shoulder, the big needle stabbing in and out, red thread.
        arm(36, 29, 22, 28 + Double(frame))
        burtonLine(c, 21, Double(26 + frame), 23, Double(23 + frame), C(0xE0E4EC), 0.5)
        burtonLine(c, 23, Double(23 + frame), 26, 21, red, 0.35)
        c.px(20, 29, red); c.px(21, 30, red)
    } else if !lifting {
        arm(36, 29, 38, 37)
    }
}

// MARK: - Zeero

/// Zeero: Jack's ghost dog, a little white sheet of a dog floating off the ground, floppy ears, two dark eyes, a
/// collar with a tiny bow tie, and his glowing pumpkin nose; behind him, no hind legs, just a wispy tail curling
/// away. Bobs gently as he hovers. He doesn't fight. Signature: his nose lights up bright as a jack-o'-lantern, he
/// loops once round in the air, and barks.
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
    // The head, ears flopping, the eyes and the collar.
    c.pattern(24, 17, [
        ".....SSSSSSSSS....",
        "...SSSSSSSSSSSSS..",
        "EEESSSSSSSSSSSSSS.",
        "EEESSKKSSSSKKSSSS.",
        "EEESSKKSSSSKKSSSSS",
        "EE.SSSSSSSSSSSSSSS",
        "EE..SSSSSSSSSSSSSS",
        "EE...SSSSSSSSSSS..",
        ".E................",
    ], ["S": sheet, "E": sheetD, "K": C(0x1A1A22)])
    c.rect(29, 25, 9, 1, C(0x2A2A30)); c.pattern(32, 25, ["OKO", ".O."], ["O": C(0xE8701A), "K": C(0x2A2A30)])
    // The nose: a little pumpkin, glowing, and lit right up in his signature.
    let glow = glowing ? 1.0 : 0.55 + 0.15 * sin(p.t * 4)
    c.glowLine(41.5, 22.5, 41.5, 22.5, core: C(0xFFD27A, glow), glow: nose.alpha(glow * 0.8), coreR: glowing ? 1.4 : 0.9,
               glowR: glowing ? 4.2 : 2.6)
    c.rect(40, 22, 3, 2, nose); c.px(41, 21, C(0x3A6A1A))
}

// MARK: - The Mayor

/// The Mayor: a fat grey tailcoat flaring out wide at the bottom like a bell, short pinstriped legs under it, a white
/// collar with a black spider for a bow tie and a red rosette on his chest; and on top his cone of a head, pointed at
/// the top and widest at his collar, the hat perched on the point: a little brim and a very tall, thin, slightly
/// crooked stovepipe. He carries his megaphone. His head has two faces: the happy one, tan, with spiral eyes and a big
/// toothy grin, and the worried one, pale, with droopy eyes and a zigzag frown, which he wears whenever his session
/// needs you. Signature: his head spins round from one face to the other and back.
private func drawMayor(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x6A6E78), coatD = C(0x4A4E58), coatL = C(0x8A8E98), ink = C(0x16161B), red = C(0xC8202A)
    let sig = p.signature
    let worriedNow = p.ready || p.urgent
    // The spin: the head turns one full round, the other face coming past at the halfway point.
    let turn = sig.map { ramp($0, 0.08, 0.92) * 2 * .pi } ?? 0
    let squash = abs(cos(turn)), backFace = cos(turn) < 0
    let worried = backFace != worriedNow

    // Short pinstriped legs and little black feet.
    if !seatedPose {
        for (i, lx) in [21, 25, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, 38, 2, lifted ? 4 : 5, C(0x24242C)); c.px(lx, 39, C(0x8A8E98)); c.px(lx, 41, C(0x8A8E98))
            c.rect(lx - 1, lifted ? 41 : 42, 3, 1, ink)
        }
    } else {
        for lx in [21, 25, 31, 35] { c.rect(lx - 1, 38, 4, 2, C(0x24242C)) }
    }
    c.oy += p.breathe
    // The coat: narrow at the shoulders, flaring out to a wide bell at the bottom, open at the front.
    for y in 25...38 {
        let hw = 9 + (y - 25) * 6 / 13
        c.rect(28 - hw, y, hw * 2, 1, coat); c.px(28 - hw, y, coatL); c.px(28 + hw - 1, y, coatD)
    }
    for y in 32...38 { c.px(28 + (y - 32) / 3, y, coatD) }   // the opening of the coat
    c.rect(19, 38, 18, 1, coatD)
    // The white collar, the spider bow tie, and the rosette.
    c.pattern(23, 25, ["WWWWWWWWWW", ".WWWWWWWW.", "..WWWWWW.."], ["W": C(0xF0ECE0)])
    c.pattern(25, 25, ["K..K..", ".KKK..", "KKKKK.", ".KKK..", "K..K.."].map { String($0.prefix(5)) }, ["K": ink])
    c.pattern(19, 28, [".RRR.", "RWWWR", "RWWWR", "RWWWR", ".RRR.", ".R.R.", "R...R"], ["R": red, "W": C(0xF0ECE0)])
    // Short arms in grey sleeves, and the megaphone in his right hand.
    c.rect(14, 30, 4, 3, coat); c.px(14, 33, C(0xE8B888))
    c.rect(38, 29, 4, 3, coat)
    c.pattern(42, 26, ["......M", "....MMM", "..MMMMM", "HMMMMMM", "..MMMMM", "....MMM", "......M"],
              ["M": C(0xB8BCC4), "H": C(0x6A6A74)])
    // The cone of a head: a point at the top, widest at his collar; squashed sideways while it spins.
    let skin = worried ? C(0xD8E2EA) : C(0xE8B888), skinD = worried ? C(0xA8B8C8) : C(0xC8946A)
    for r in 0..<13 {
        let w = 2 + r * 14 / 12
        let hw = max(1, Int((Double(w) / 2 * max(0.2, squash)).rounded()))
        c.rect(28 - hw, 13 + r, hw * 2, 1, skin); c.px(28 + hw - 1, 13 + r, skinD)
    }
    if squash > 0.55 {
        func fx(_ dx: Int) -> Int { 28 + Int((Double(dx) * squash).rounded()) }
        if worried {   // droopy, half-shut eyes and a zigzag frown
            for ex in [-3, 2] { c.rect(fx(ex), 18, 2, 1, C(0x4A5A6A)); c.rect(fx(ex), 19, 2, 1, ink) }
            c.rect(fx(-4), 22, 9, 3, ink)
            c.pattern(fx(-3), 23, ["W.W.W.W", ".W.W.W."], ["W": C(0xF0ECE0)])
        } else {       // spiral eyes and a big toothy grin
            for ex in [-4, 2] { c.pattern(fx(ex), 17, ["KKK", "K.K", "KK."], ["K": ink]) }
            c.px(fx(0), 20, C(0x6A4A2A))
            c.rect(fx(-5), 22, 11, 3, ink); c.rect(fx(-4), 23, 9, 1, C(0xF0ECE0))
            c.px(fx(-6), 21, ink); c.px(fx(5), 21, ink)
        }
    }
    // The hat on the point: a little brim and a tall, thin, slightly crooked stovepipe with a pale band.
    c.rect(23, 13, 10, 1, C(0x1E1E26)); c.rect(24, 12, 8, 1, C(0x1E1E26))
    c.rect(27, 9, 3, 3, C(0x8A8E98))
    for y in 0..<9 { c.rect(27 + (9 - y) / 5 - (y < 3 ? 1 : 0), y, 3, 1, y % 4 == 0 ? C(0x2A2A34) : C(0x1E1E26)) }
}

// MARK: - Sandy Clawz

/// Sandy Clawz: round and red, the fur-trimmed coat with a black belt and a gold buckle, black boots, a big white
/// beard over rosy cheeks, the red hat with its fur band and a bobble drooping over one side, and his sack of
/// presents over his shoulder. He throws wrapped presents. Signature: he pats his round tummy, which bounces, and
/// laughs.
private func drawSandyClawz(_ c: PixelCanvas, _ p: Pose) {
    let red = C(0xC8202A), redD = C(0x8E1418), fur = C(0xF4F4F0), furD = C(0xD0D4D8), skin = C(0xF0C8B0)
    let sig = p.signature
    let patting = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false
    let bounce = patting ? (Int(p.t * 6) % 2) : 0

    drawLegs(c, Look(leg: red), step: p.step)
    burtonBoots(c, step: p.step, C(0x141418), height: 3)
    c.oy += p.breathe
    // The sack over his left shoulder, behind him.
    c.pattern(9, 20, ["...BBB...", ".BBBBBBB.", "BBBBBBBBB", "BBBbBBBBB", "BBBBBBbBB", "BBBBBBBBB", ".BBBBBBB.",
                      "..BBBBB..", "...BBB..."], ["B": C(0x8A6A3A), "b": C(0x6A4E2A)])
    // The round red coat, its fur trim, the belt and buckle; the tummy bouncing as he pats it.
    for y in 26...37 {
        let k = Double(y - 32) / 6, hw = Int((11.5 * (1 - k * k * 0.3)).rounded()) + (y > 30 ? bounce : 0)
        c.rect(28 - hw, y, hw * 2, 1, red); c.px(28 + hw - 1, y, redD)
    }
    c.rect(18, 36, 20, 2, fur); c.rect(27, 26, 2, 10, fur)
    c.rect(17, 33, 22, 2, C(0x141418)); c.pattern(26, 33, ["GGGG", "G..G"].map { $0 }, ["G": C(0xE8B830)])
    // Rosy face, the big white beard, and the hat with its fur band and drooping bobble.
    c.rect(21, 24, 14, 4, skin); c.px(22, 26, C(0xE88A8A)); c.px(33, 26, C(0xE88A8A))
    c.rect(23, 25, 2, 2, C(0x1A1A22)); c.rect(31, 25, 2, 2, C(0x1A1A22)); c.rect(27, 26, 2, 2, C(0xE09A88))
    c.pattern(19, 27, [
        ".BBBBBBBBBBBBBBBB.",
        "BBBBBBB....BBBBBBB",
        "BBBBBBBBBBBBBBBBBB",
        ".BBBBBBBBBBBBBBBB.",
        "..BBBbBBBBBbBBBB..",
        "...BBBBBBBBBBBB...",
        ".....BBBBBBBB.....",
    ], ["B": fur, "b": furD])
    c.pattern(18, 15, [
        "..........RRR.......",
        "........RRRRRRR.....",
        "......RRRRRRRRRR....",
        "....RRRRRRRRRRRRR...",
        "..RRRRRRRRRRRRRRRRR.",
        ".RRRRRRRRRRRRRRRRRR.",
        "FFFFFFFFFFFFFFFFFFFF",
        "FFFFFFFFFFFFFFFFFFFF",
        "FFFfFFFFFFFFFFfFFFFF",
    ], ["R": red, "F": fur, "f": furD])
    c.pattern(13, 15, ["..RRR..", ".RR....", "RR.....", "FFF....", "FFF...."], ["R": red, "F": fur])   // the tip, drooping behind
    // Arms: patting the tummy, a present raised to throw, or mittens at his sides.
    let mitt = C(0x141418)
    if patting {
        c.rect(15, 32, 3, 3, red); c.rect(20 + bounce * 2, 31, 3, 3, mitt)
        c.rect(38, 32, 3, 3, red); c.rect(34 - bounce * 2, 32, 3, 3, mitt)
        return
    }
    c.rect(15, 32, 3, 3, red); c.rect(14, 35, 3, 2, mitt)
    if p.fire != nil || p.ready || p.gunLift > 0 {
        c.oy += p.gunY
        c.rect(38, 29, 3, 3, red)
        c.pattern(41, 25, ["RRYRR", "RRYRR", "YYYYY", "RRYRR", "RRYRR"], ["R": red, "Y": C(0xF0D040)])
        return
    }
    c.rect(38, 32, 3, 3, red); c.rect(39, 35, 3, 2, mitt)
}
