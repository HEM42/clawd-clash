import Foundation

// Villains: the suits. The Watchers' Council's man, Sunnydale High's principal, and Wolfram & Hart's lawyers, plus
// Jasmine, the god who walked into the Hyperion. Most of them never throw a punch, so each one is told apart by the
// colour of the suit, the hair and the thing in their hand: Travesty's grey three-piece and his scroll, Snide's brown
// suit and his ears, Lindsey's navy suit and the guitar on his back, Lilah's black suit and oxblood briefcase,
// Holland's stone-coloured suit, silver hair and glasses, and Jazzmine's white gown and golden glow.

let slayerVillains7: [SlayerVillain: Persona] = [
    .quentinTravesty: Persona(name: "Quentin Travesty", headTop: 25, signature: 3.4, draw: drawQuentinTravesty),
    .principalSnide: Persona(name: "Principal Snide", headTop: 23, signature: 3.0, callout: "Watching you.",
                             draw: drawPrincipalSnide),
    .lindseyMcDonclawd: Persona(name: "Lindsey McDonclawd", weapon: .saber, headTop: 20, signature: 3.6,
                                draw: drawLindseyMcDonclawd),
    .lilahMorgane: Persona(name: "Lilah Morgane", headTop: 20, signature: 3.0, draw: drawLilahMorgane),
    .hollandMannerly: Persona(name: "Holland Mannerly", headTop: 21, signature: 3.2, draw: drawHollandMannerly),
    .jazzmine: Persona(name: "Jazzmine", weapon: .lightning,
                       magic: Magic(core: C(0xFFFBEE), glow: C(0xF4CE6A), jagged: false, touch: true),
                       headTop: 18, signature: 3.6, callout: "Love me.", draw: drawJazzmine),
]

// MARK: - Shared bits

/// Smoothstep: 0→1 eased at both ends.
private func v7Smooth(_ x: Double) -> Double {
    let u = min(1, max(0, x))
    return u * u * (3 - 2 * u)
}

/// A value through a signature `s` 0…1, eased from key to key, flat beyond the ends.
private func v7Keyed(_ s: Double, _ keys: [(s: Double, v: Double)]) -> Double {
    guard let first = keys.first, let last = keys.last else { return 0 }
    if s <= first.s { return first.v }
    for (a, b) in zip(keys, keys.dropFirst()) where s < b.s {
        return a.v + (b.v - a.v) * v7Smooth((s - a.s) / (b.s - a.s))
    }
    return last.v
}

/// How far through the part of the signature between `from` and `to` (0…1), or -1 outside it.
private func v7Span(_ p: Pose, _ from: Double, _ to: Double) -> Double {
    guard let s = p.signature, s > from, s < to else { return -1 }
    return (s - from) / (to - from)
}

/// Cheering or calling you urgently: the free arm up and waving.
private func v7Wave(_ c: PixelCanvas, _ p: Pose, sleeve: Px) -> Bool {
    guard p.cheering || (p.ready && p.urgent) else { return false }
    let up = sin(p.t * 10) > 0 ? 1 : 0
    c.rect(38, 26 - up, 3, 7 + up, sleeve); c.rect(38, 24 - up, 3, 2, clawdOrange)
    return true
}

/// Suit trousers over the four legs: each leg a pixel wider than Clawd's, with a crease of shade down its right side
/// and a dark shoe at the foot, so the pairs read as trouser legs and not as stripes between the white outline. From
/// row `top` down (a skirt covers the rest). Seated legs fold away under the body and keep their own look.
private func v7Trousers(_ c: PixelCanvas, step: Int, _ leg: Px, _ crease: Px, shoe: Px, top: Int = 36) {
    guard !seatedPose else { return }
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        let bottom = step >= 0 && i % 2 == step ? 42 : 43
        c.rect(lx, top, 3, bottom - top + 1, leg); c.rect(lx + 2, top, 1, bottom - top + 1, crease)
        c.rect(lx, bottom, 3, 1, shoe)
    }
}

/// A suit jacket over the body, buttoned, with its shade down the right and along the hem.
private func v7Jacket(_ c: PixelCanvas, _ suit: Px, _ dark: Px, _ lit: Px) {
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, dark); c.rect(18, 37, 20, 1, dark)
    c.rect(18, 34, 1, 3, lit)                                                  // lit down the near side
    c.rect(21, 35, 1, 2, dark); c.rect(34, 35, 1, 2, dark)                    // folds
}

// MARK: - Quentin Travesty

/// Quentin Travesty: head of the Watchers' Council, balding, a fringe of white hair round the sides and back and
/// bushy white brows, in a warm grey three-piece suit with the Council's maroon-and-gold striped tie and a watch chain
/// across the waistcoat. He never fights. A rolled ruling, sealed in red wax, is always in his hand. Signature: he
/// holds it up, lets it unroll and reads it out, then rolls it back up.
private func drawQuentinTravesty(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x6A645C), suitD = C(0x4A4640), suitL = C(0x8C867C), waist = C(0x524C46), shirt = C(0xF0EEE6)
    let tie = C(0x6A1E2A), stripe = C(0xD0A848), hair = C(0xE4E2DC), hairD = C(0xB0ACA4)
    let paper = C(0xF0E6C8), paperD = C(0xC8B890), wax = C(0xB0202A)
    let s = p.signature ?? -1
    let up = s >= 0 ? v7Keyed(s, [(0.02, 0), (0.14, 1), (0.86, 1), (0.97, 0)]) : 0
    let open = s >= 0 ? v7Keyed(s, [(0.14, 0), (0.26, 1), (0.74, 1), (0.86, 0)]) : 0
    let raise = Int((up * 6).rounded())

    drawLegs(c, Look(leg: C(0x7A746A)), step: p.step)
    v7Trousers(c, step: p.step, C(0x7A746A), C(0x5A554E), shoe: C(0x1E1A18))
    c.oy += p.breathe
    drawBody(c, Look(arm: suit), armRight: raise)
    v7Jacket(c, suit, suitD, suitL)
    // The waistcoat in the V of the lapels, the shirt collar and the Council tie with its one gold stripe: a few
    // calm shapes under his mouth, the watch chain a single gold glint at the waistcoat's edge.
    c.pattern(24, 33, ["LSSTTSSL", ".LWTTWL.", "..LWWL.."], ["S": shirt, "T": tie, "W": waist, "L": suitL])
    c.rect(27, 34, 2, 1, stripe)                                               // the Council stripe
    c.px(26, 35, stripe)                                                       // the watch chain
    // Bald on top: Clawd's own crown, a fringe of white hair over the ears, a wisp or two, and bushy white brows.
    c.pattern(16, 25, [
        "..hH................Hh..",
        ".HHHH..h...h.......HHHH.",
        "HHHHh..............hHHHH",
        "HHHd................dHHH",
        ".HH..................HH.",
        ".d....................d.",
    ], ["H": hair, "h": hairD, "d": hairD])
    c.rect(21, 27, 4, 1, hair); c.px(20, 26, hair); c.rect(31, 27, 4, 1, hair); c.px(35, 26, hair)
    // A thin, disapproving mouth; it moves while he reads.
    let talk = open > 0.9 && Int(p.t * 7) % 2 == 0
    c.rect(26, 32, 4, 1, C(0x7A3A2A)); if talk { c.rect(27, 33, 2, 1, C(0x5A2418)) }

    if v7Wave(c, p, sleeve: suit) { return }
    let hy = 33 - raise
    c.rect(39, hy + 1, 2, 2, clawdOrange)   // his hand round it
    if open <= 0.05 {
        // Rolled up: a fat roll held upright in his fist, the end of the sheet curling round it, a ribbon round the
        // middle and the red seal hanging off it.
        c.rect(39, hy - 4, 3, 10, paper); c.rect(41, hy - 4, 1, 10, paperD); c.rect(39, hy - 4, 3, 1, paperD)
        c.px(39, hy - 3, C(0xFFF8E4)); c.px(40, hy - 4, C(0xFFF8E4))
        c.rect(39, hy + 1, 2, 2, clawdOrange)                                   // his fist, round the middle
        c.rect(39, hy + 4, 3, 1, wax); c.rect(42, hy + 4, 2, 2, wax); c.px(43, hy + 6, wax)
        return
    }
    // Unrolled: the top roller in his hand, the sheet hanging down with its lines of text, the seal at the foot.
    let len = Int((open * 9).rounded())
    c.rect(39, hy - 1, 9, 2, paperD); c.rect(39, hy - 1, 9, 1, paper)
    c.rect(40, hy + 1, 7, len, paper)
    c.rect(46, hy + 1, 1, len, paperD)
    var y = hy + 2
    while y < hy + len - 1 { c.rect(41, y, y == hy + 2 ? 3 : 5, 1, C(0x6A6050)); y += 2 }
    c.rect(40, hy + 1 + len, 7, 1, paperD)
    if len >= 7 { c.rect(42, hy + 1 + len, 3, 2, wax); c.px(43, hy + 3 + len, wax) }
}

// MARK: - Principal Snide

/// Principal Snide: Sunnydale High's principal, a small man with a big scowl. Short dark hair, receding, big ears
/// sticking out, brows dragged down into a V and a downturned mouth; a brown suit, a beige shirt and a mustard tie.
/// He doesn't fight, he gives detention. Signature: he wags a finger at you, then levels it at you, eyes narrowed
/// ("Watching you.").
private func drawPrincipalSnide(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x7A5838), suitD = C(0x58402A), suitL = C(0x9A7650), shirt = C(0xE8D8B8), tie = C(0xC09A30)
    let hair = C(0x2E2420), hairL = C(0x4A3C34), brow = C(0x3A2C24)
    let wagK = v7Span(p, 0.06, 0.6), eyesK = v7Span(p, 0.6, 0.94)

    drawLegs(c, Look(leg: C(0x8A6848)), step: p.step)
    v7Trousers(c, step: p.step, C(0x8A6848), C(0x6A4E34), shoe: C(0x2A1C14))
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    v7Jacket(c, suit, suitD, suitL)
    c.pattern(24, 33, ["LSSTTSSL", ".LSTTSL.", "..LTTL..", "...TT...", "...TT..."],
              ["S": shirt, "T": tie, "L": suitL])
    // Short dark hair, receding at the temples, and the ears sticking out either side.
    c.pattern(17, 23, [
        "....hHHHHHHHHHHHh...",
        "..HHHHHHHlHHHHHHHH..",
        ".HHH...HHHHHHH..HHH.",
        ".HH..............HH.",
    ], ["H": hair, "h": hairL, "l": hairL])
    c.rect(15, 28, 3, 3, clawdOrange); c.px(15, 30, clawdShade)
    c.rect(38, 28, 2, 3, clawdShade); c.px(40, 29, clawdShade)
    // The scowl: brows down into a V, a turned-down mouth.
    c.pattern(20, 26, ["BB....", ".BBB..", "...B.."], ["B": brow])
    c.pattern(30, 26, ["....BB", "..BBB.", "..B..."], ["B": brow])
    c.pattern(25, 31, [".MMMM.", "M....M"], ["M": C(0x6A2A20)])

    if v7Wave(c, p, sleeve: suit) { return }
    if wagK >= 0 {
        // The finger, wagging side to side over his raised fist: the arm held well out from his head, a shirt cuff
        // at the wrist, so the hand reads as a hand and not a third ear.
        let wag = Int((sin(wagK * .pi * 8) * 1.4).rounded())
        slayerLine(c, 39, 32, 45, 28.5, suit, 1.2)
        c.rect(45, 27, 2, 2, shirt)
        c.rect(46, 25, 3, 3, clawdOrange); c.rect(48, 25, 1, 3, clawdShade)
        c.rect(47 + wag, 21, 1, 4, clawdOrange); c.px(47 + wag, 21, C(0xF4C0A0))
    } else if eyesK >= 0 {
        // Then the finger levelled at you, his eyes narrowed.
        c.rect(38, 31, 4, 3, suit); c.rect(42, 31, 3, 3, clawdOrange); c.rect(45, 31, 3, 1, clawdOrange)
        c.rect(22, 29, 2, 1, clawdOrange); c.rect(32, 29, 2, 1, clawdOrange)
    }
}

// MARK: - Lindsey McDonclawd

private let lindseyWood = C(0xD49A50), lindseyWoodD = C(0xA06A30), lindseyWoodL = C(0xF0C47E)
private let lindseyNeck = C(0x5A3A1E), lindseyHole = C(0x2A1A10)

/// Lindsey's acoustic guitar body: honey-coloured, a dark sound hole, from (x, y). `big`: held in front, played, lying
/// on its side with the big lower bout on the left, the waist, and the upper bout by the neck on the right.
private func lindseyGuitarBody(_ c: PixelCanvas, _ x: Int, _ y: Int, big: Bool = false) {
    let rows = big ? [
        "..lllGG..ll.",
        ".lGGGGGGlGGG",
        "lGGGGGGGGGGG",
        "GGGGGGGGOOGG",
        "GGBBGGGOOOOG",
        "GGGGGGGGOOGD",
        "DGGGGGGGGGGD",
        ".DGGGGGD.DD.",
        "..DDDDD.....",
    ] : [
        ".lGGG..",
        "lGGGGG.",
        "GGGOGGD",
        ".GOOOD.",
        "GGGOGGD",
        "GGGGGGD",
        ".GGGGD.",
    ]
    c.pattern(x, y, rows, ["G": lindseyWood, "D": lindseyWoodD, "l": lindseyWoodL, "O": lindseyHole, "B": lindseyNeck])
}

/// Lindsey McDonclawd: Wolfram & Hart's young high-flier, shaggy light-brown hair falling over his brow, a navy suit
/// with the white shirt open at the collar, no tie. His acoustic guitar, honey wood and a dark sound hole, rides on his
/// back on a leather strap across his chest. He fights with his fists. Signature: he swings the guitar round, picks
/// out a few notes, and slings it back.
private func drawLindseyMcDonclawd(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x34466E), suitD = C(0x243252), suitL = C(0x50648E), shirt = C(0xF2F2EE), strap = C(0x5A3420)
    let hair = C(0xA07448), hairL = C(0xC8986A), hairD = C(0x7A5432)
    let playK = p.melee == nil ? v7Span(p, 0.1, 0.9) : -1

    if playK < 0 {
        // The guitar on his back: its neck up behind his shoulder, the body poking out behind him.
        c.rect(8, 19, 3, 2, lindseyHole)
        slayerLine(c, 10, 21, 14, 30, lindseyNeck, 0.7)
        lindseyGuitarBody(c, 10, 29)
    }
    drawLegs(c, Look(leg: C(0x46588A)), step: p.step)
    v7Trousers(c, step: p.step, C(0x46588A), C(0x34466E), shoe: C(0x2A1E18))
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    v7Jacket(c, suit, suitD, suitL)
    // The shirt open at the neck: no tie.
    c.pattern(24, 33, ["LSSSSSSL", ".LSSSSL.", "..LSSL..", "...LL..."], ["S": shirt, "L": suitL])
    c.px(27, 33, C(0xE8C8A8)); c.px(28, 33, C(0xE8C8A8))
    if playK < 0 { slayerLine(c, 18.5, 33, 36.5, 37.5, strap, 0.55) }   // the strap across his chest
    // Shaggy hair, a long fringe swept over his brow, a few loose strands.
    c.pattern(16, 20, [
        "......h....h............",
        "....HHHHHHHHHHHHh.......",
        "...HHllHHHHllHHHHHH.....",
        "..HHHHHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHH.HHHH..",
        ".HHHHHHHHdHHd.....dHHH..",
        ".HHH..dH..d.........HHd.",
        ".dHH................dHd.",
        "..d..................d..",
    ], ["H": hair, "l": hairL, "d": hairD, "h": hairD])

    if let a = p.melee {
        slayerSmear(c, slayerHand, p.trail, from: 6, to: 9, C(0xF4E8D0))
        let e = slayerReach(slayerHand, a, 7)
        slayerLine(c, slayerHand.x - 2, slayerHand.y - 0.5, e.x, e.y, suit, 1.3)
        c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 4, 4, clawdOrange)
        c.px(Int(e.x.rounded()) + 2, Int(e.y.rounded()) + 2, clawdShade)
        return
    }
    if playK < 0 { _ = v7Wave(c, p, sleeve: suit); return }
    // Swung round in front: the body over his belly, the neck out to the right, his left hand on it, his right
    // picking at the strings; a few notes drifting up off it.
    let swing = min(1, min(playK, 1 - playK) * 8)
    if swing < 1 {
        // Halfway round: the guitar at his side.
        lindseyGuitarBody(c, 15, 30)
        return
    }
    // The neck: pale wood with a dark fretboard along it, out to a headstock with its pegs, so it reads as a
    // guitar neck and not as a stick in his hand.
    // Slung low across his hips, clear of his face.
    slayerLine(c, 28, 37.5, 44, 32.5, C(0x9A6A3A), 1.0)
    slayerLine(c, 28, 37, 44, 32, lindseyNeck, 0.5)
    c.rect(44, 30, 3, 3, lindseyNeck); c.px(44, 30, C(0x7A4E28))
    c.px(45, 29, C(0xE8E0C8)); c.px(47, 31, C(0xE8E0C8))
    lindseyGuitarBody(c, 17, 33, big: true)
    // The fretting hand gripping the neck, out at the end of his arm.
    c.rect(40, 32, 3, 3, clawdOrange); c.px(42, 34, clawdShade)
    c.rect(23, 36 + Int(p.t * 6) % 2, 2, 2, clawdOrange)                               // picking hand
    for i in 0..<2 {
        let f = frac(playK * 3 + Double(i) * 0.5)
        let x = 47 + i * 4 + Int(sin(f * 5) * 1.5), y = 28 - Int(f * 10)
        let col = C(0xA8D8FF).alpha(1 - f)
        c.rect(x, y, 2, 2, col); c.rect(x + 1, y - 3, 1, 3, col)
    }
}

// MARK: - Lilah Morgane

/// Lilah Morgane: Wolfram & Hart's sharpest lawyer. Long dark brown hair with a side parting, red lips, a black skirt
/// suit over a plum silk blouse, black heels. She never lets go of her oxblood leather briefcase. Signature: she lifts it,
/// flicks it open on a contract, and snaps it shut.
private func drawLilahMorgane(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x1E1C24), suitD = C(0x0E0D12), suitL = C(0x3E3A48), blouse = C(0x6E3A58)
    let hair = C(0x3A2218), hairL = C(0x5E3A28), hairD = C(0x22140E)
    let caseC = C(0x7A2228), caseD = C(0x521418), caseL = C(0xA0383E), brass = C(0xE0B850)
    let s = p.signature ?? -1
    let lift = s >= 0 ? v7Keyed(s, [(0.04, 0), (0.18, 1), (0.84, 1), (0.96, 0)]) : 0
    let open = s >= 0 ? v7Keyed(s, [(0.2, 0), (0.3, 1), (0.6, 1), (0.66, 0)]) : 0
    let snap = s > 0.66 && s < 0.76

    drawLegs(c, Look(), step: p.step)
    v7Trousers(c, step: p.step, clawdOrange, clawdShade, shoe: C(0x141216))
    // The pencil skirt, to the knee: the four legs show below it.
    if seatedPose { c.rect(17, 37, 22, 2, suit) } else {
        c.rect(18, 37, 20, 4, suit); c.rect(18, 40, 20, 1, suitD); c.rect(37, 37, 1, 4, suitD)
    }
    c.oy += p.breathe
    let raise = Int((lift * 3).rounded())
    drawBody(c, Look(arm: suit), armRight: raise)
    v7Jacket(c, suit, suitD, suitL)
    // The plum silk blouse in a deep V between the lapels, a sheen down one side.
    c.pattern(23, 33, ["LBBBBBBBBL", ".LBbBBBBL.", "..LBbBBL..", "...LBBL...", "....LL...."],
              ["B": blouse, "b": C(0x9A5A80), "L": suitL])
    c.rect(26, 32, 4, 1, C(0xE02A3A))                                          // red lips
    // Long dark hair, side-parted, falling past her shoulders, a strand or two loose.
    c.pattern(16, 19, [
        "........h.......h.......",
        "......HHHHHHHHHHHHH.....",
        "....HHHlllHHHHHHHHHH....",
        "...HHlHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHH.....HHHHHHHHHHH.",
        ".HHHH..............HHHH.",
        ".HHH................HHH.",
        ".HHl................HHH.",
        "HHHl................HHH.",
        ".HHH................lHH.",
        ".HHH................HHH.",
        "HHHd................dHH.",
        ".HHd................dHHH",
        ".dHd................dHd.",
        "..d..................d..",
    ], ["H": hair, "l": hairL, "d": hairD, "h": hairD])

    if v7Wave(c, p, sleeve: suit) {
        // Cheering: the briefcase stays in her other hand.
        c.rect(12, 36, 7, 5, caseC); c.rect(12, 36, 7, 1, caseL); c.rect(14, 35, 3, 1, caseD); c.px(15, 38, brass)
        return
    }
    if lift < 0.5 {
        // Hanging from her hand at her side.
        c.rect(39, 35, 2, 2, clawdOrange)
        c.rect(38, 37, 3, 1, caseD)
        c.rect(36, 38, 8, 5, caseC); c.rect(36, 38, 8, 1, caseL); c.rect(43, 38, 1, 5, caseD); c.rect(36, 42, 8, 1, caseD)
        c.px(38, 39, brass); c.px(41, 39, brass)
        return
    }
    // Held up flat in front of her: the lid swings up on a contract, then slams shut.
    let hy = 33 - raise
    c.rect(39, hy + 1, 2, 2, clawdOrange)
    let bx = 40, by = hy + 1
    c.rect(bx, by, 9, 4, caseC); c.rect(bx, by + 3, 9, 1, caseD); c.rect(bx + 8, by, 1, 4, caseD)
    if open > 0.3 {
        // The lid up behind, the contract in it, its red signature line.
        let lh = Int((open * 6).rounded())
        c.rect(bx, by - lh, 9, lh, caseC); c.rect(bx, by - lh, 9, 1, caseL); c.rect(bx + 8, by - lh, 1, lh, caseD)
        c.rect(bx + 1, by - 1, 7, 2, C(0xF6F2E6))
        if lh >= 5 { c.rect(bx + 2, by - lh + 2, 5, max(1, lh - 3), C(0xF6F2E6)); c.rect(bx + 3, by - 2, 3, 1, C(0xC0202E)) }
    } else {
        c.rect(bx, by, 9, 1, caseL)
        c.px(bx + 2, by + 1, brass); c.px(bx + 6, by + 1, brass)
    }
    if snap {
        // Snap: a little burst off the shut case.
        for (dx, dy) in [(-1, -2), (4, -3), (9, -2), (10, 0)] { c.px(bx + dx, by + dy, white.alpha(0.85)) }
    }
}

// MARK: - Holland Mannerly

/// Holland Mannerly: the senior partner's man in the Special Projects division, all perfect manners. Neat silver
/// hair, side-parted, dark-rimmed glasses, a stone-coloured suit, a burgundy tie and a white pocket square. He never
/// fights. Signature: he steps up and offers you his hand, with a little bow and a warm, terrible smile.
private func drawHollandMannerly(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0xA89C86), suitD = C(0x7E7462), suitL = C(0xC8BEA8), shirt = C(0xF4F2EC), tie = C(0x6E1E34)
    let hair = C(0xC8CACE), hairL = C(0xEEF0F2), hairD = C(0x8E9096), rim = C(0x4A4650), lens = C(0xCFE0EA)
    let shakeK = v7Span(p, 0.1, 0.9)
    let reach = shakeK >= 0 ? min(1, min(shakeK, 1 - shakeK) * 6) : 0
    if reach > 0.5 { c.ox += 1 }

    drawLegs(c, Look(leg: C(0x8E846E)), step: p.step)
    v7Trousers(c, step: p.step, C(0x8E846E), C(0x6E6654), shoe: C(0x4A3020))
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    v7Jacket(c, suit, suitD, suitL)
    c.pattern(24, 33, ["LSSTTSSL", ".LSTTSL.", "..LTTL..", "...TT...", "...TT..."],
              ["S": shirt, "T": tie, "L": suitL])
    c.rect(33, 34, 2, 1, shirt); c.px(34, 33, shirt)                              // the pocket square
    // The bow: his head dips a row.
    let bow = shakeK > 0.3 && shakeK < 0.6 ? 1 : 0
    c.oy += bow
    // Neat silver hair, side-parted, combed smooth with a strand lifting at the crown.
    c.pattern(17, 21, [
        "........h...h.......",
        "....HHHHHHHHHHHH....",
        "..HHHlHHHHHHHHHHHH..",
        ".HHlHHHdHHHHHHHHHHH.",
        ".HHHHHdHHHHHHHHHHHH.",
        ".HH.dd..........HHH.",
        ".HH..............dH.",
        ".d................d.",
    ], ["H": hair, "l": hairL, "d": hairD, "h": hairD])
    // The glasses: dark rims round both eyes, a bridge between them, a glint when he smiles at you.
    c.pattern(20, 28, ["RRRRRR....RRRRRR", "RLLLLRRRRRRLLLLR", "RL..LR....RL..LR", "RL..LR....RL..LR", "RRRRRR....RRRRRR"],
              ["R": rim, "L": lens])
    c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    if reach > 0.5 && Int(p.t * 4) % 3 == 0 { c.px(21, 29, white); c.px(31, 29, white) }
    // A smile: polite at rest, warmer when he offers his hand.
    if reach > 0.5 {
        c.pattern(25, 32, ["M....M", ".MWWM."], ["M": C(0x7A2A20), "W": white])
    } else {
        c.pattern(25, 32, ["M....M", ".MMMM."], ["M": C(0x7A2A20)])
    }
    c.oy -= bow

    if v7Wave(c, p, sleeve: suit) { return }
    guard reach > 0 else { return }
    // His hand out: the sleeve forward, narrowing from the shoulder to the wrist, a white cuff, and the hand held
    // upright for a handshake, fingers forward and the thumb standing up off it.
    let len = Int((reach * 5).rounded())
    c.rect(38, 34, 3 + len, 2, suit); c.rect(38, 35, 3 + len, 1, suitD)
    c.rect(41 + len, 33, 1, 3, shirt)
    c.rect(42 + len, 33, 3, 3, clawdOrange); c.rect(42 + len, 35, 3, 1, clawdShade)
    c.rect(42 + len, 31, 1, 2, clawdOrange); c.px(42 + len, 31, C(0xF4B090))
}

// MARK: - Jazzmine

/// Jazzmine: the god who came to Los Angeles to make everyone love her. A great cloud of dark curls, a flowing white
/// gown to the ankles with a gold neckline, and a smile that glows. Her magic is a touch, cream and warm gold: whoever
/// she reaches for adores her. Signature: she opens her arms wide, the gold light swells round her and bows down
/// before her in rays ("Love me.").
private func drawJazzmine(_ c: PixelCanvas, _ p: Pose) {
    let gown = C(0xF6F2EA), gownD = C(0xD6CCBA), gownL = C(0xFFFFFF), gold = C(0xE8BE58), goldD = C(0xB88E30)
    let hair = C(0x2A1C18), hairL = C(0x4E3428), hairD = C(0x160E0A)
    let glowC = C(0xF4CE6A)
    let armsK = v7Span(p, 0.06, 0.94)
    let wide = armsK >= 0 ? min(1, min(armsK, 1 - armsK) * 5) : 0

    // Her glow, faint behind her while she casts or opens her arms.
    let aura = max(wide, p.zap != nil ? 0.6 : 0)
    if aura > 0 {
        let pulse = 0.8 + 0.2 * sin(p.t * 5)
        c.glowLine(28, 30, 28, 30, core: glowC.alpha(0.12 * aura * pulse), glow: glowC.alpha(0.16 * aura * pulse),
                   coreR: 8, glowR: 15)
    }
    drawLegs(c, Look(), step: p.step)
    slayerBoots(c, step: p.step, gold, height: 1)
    // The gown, flowing to her ankles: the four feet show below its hem.
    if seatedPose {
        c.rect(16, 37, 24, 3, gown); c.rect(16, 39, 24, 1, gownD)
    } else {
        c.rect(17, 37, 22, 3, gown); c.rect(16, 40, 24, 2, gown); c.rect(16, 41, 24, 1, gownD)
        c.rect(38, 37, 1, 4, gownD); c.px(22, 40, gownD); c.px(29, 39, gownD); c.px(33, 41, gownL)
    }
    c.oy += p.breathe
    let open = Int((wide * 6).rounded())
    let raise = wide > 0 ? 0 : p.armRaise
    drawBody(c, Look(arm: gown), armRight: raise)
    c.rect(18, 33, 20, 5, gown); c.rect(37, 33, 1, 5, gownD); c.rect(18, 37, 20, 1, gownD)
    // The gold neckline and a fold or two in the white.
    c.pattern(23, 33, ["G........G", ".GG....GG.", "...GGGG..."], ["G": gold])
    c.px(21, 35, gownD); c.px(34, 36, gownD)
    // Casting: her hand out at the end of the white sleeve, reaching for whoever she touches.
    if wide == 0 && (p.zap != nil || raise > 0) { c.rect(41, 33 - raise, 2, 3, clawdOrange); c.px(42, 35 - raise, clawdShade) }
    // Open arms: hands out at the ends of her sleeves.
    if wide > 0 {
        // Both arms flung up and out, the white sleeves falling from them.
        let lx = 16.0 - Double(open) * 0.8, rx = 40.0 + Double(open) * 0.8, hy = 34.0 - Double(open) * 1.1
        slayerLine(c, 17, 34, lx, hy, gown, 1.2); slayerLine(c, 38, 34, rx, hy, gown, 1.2)
        c.rect(Int(lx.rounded()) - 1, Int(hy.rounded()) - 2, 2, 2, clawdOrange)
        c.rect(Int(rx.rounded()), Int(hy.rounded()) - 2, 2, 2, clawdOrange)
    }
    // The smile that glows.
    c.pattern(24, 31, ["M......M", ".MWWWWM."], ["M": C(0x9A3A2A), "W": C(0xFFF6DC)])
    if aura > 0 || Int(p.lt * 0.5) % 4 == 0 {
        c.glowLine(26.5, 32.5, 29.5, 32.5, core: C(0xFFF6DC, 0), glow: glowC.alpha(0.3), coreR: 0.4, glowR: 2.2)
    }
    // A great cloud of dark curls round her face and over her shoulders.
    c.pattern(15, 18, [
        "......h.HHhH.Hh.h.......",
        "....hHHHhHHHHhHHHHh.....",
        "...HHhHHHlHHhHHHlHHHh...",
        "..hHHHhHHHHHHhHHHHHHHh..",
        ".HHlHHHHhHHlHHHHhHHHlHH.",
        ".HHHHhHHHHHHHHHHHHHhHHH.",
        "hHHhHH..hHH..hHH..HHHHHh",
        "HHHHh..............hHHHH",
        "hHlH................HHHh",
        "HHHH................HlHH",
        ".HhH................HHH.",
        "HHHH................hHHH",
        "hHdH................HHdh",
        ".HHd................dHH.",
        "HdHH................HHdH",
        ".dHd................dHd.",
        "..d..................d..",
    ], ["H": hair, "l": hairL, "d": hairD, "h": hairD])
    // A gold band in her hair.
    c.rect(20, 21, 2, 1, goldD); c.rect(22, 20, 10, 1, gold); c.rect(32, 21, 2, 1, goldD)

    guard wide > 0 else { return }
    // The light pours off her in rays, and motes of gold float down round her like a blessing. The rays are bright
    // gold cores in a warm glow, nearly solid so they hold up on a dark desktop, but still light: no outline.
    let pulse = 0.85 + 0.15 * sin(p.t * 6)
    for k in 0..<7 {
        let a = -150.0 + Double(k) * 20
        let r0 = 15.0, r1 = 15 + 5 * wide
        let p0 = slayerReach((28, 28), a, r0), p1 = slayerReach((28, 28), a, r1)
        c.glowLine(p0.x, p0.y, p1.x, p1.y, core: C(0xFFE27A).alpha(0.9 * wide * pulse), glow: glowC.alpha(0.5 * wide),
                   coreR: 0.7, glowR: 1.6)
    }
    for i in 0..<4 {
        let f = frac(p.t * 0.5 + Double(i) * 0.25)
        let x = 10 + i * 15 + Int(sin(f * 6 + Double(i)) * 1.5), y = 14 + Int(f * 20)
        c.px(x, y, C(0xFFF0C0).alpha(0.6 * wide * (1 - f)))
    }
}
