import Foundation

// Heroes: The Nightmare Before Christmas. Halloween Town's own: Jack Skullington, the Pumpkin King, a tall skeleton in
// a pinstripe suit, and Sallee, the rag doll who keeps sewing herself back together. Here the blocky Clawd is bone,
// cloth and stitches instead of orange: they're a skeleton and a doll.

let burtonHeroes1: [BurtonHero: Persona] = [
    .jackSkullington: Persona(name: "Jack Skullington", weapon: .lightning,
                              magic: Magic(core: C(0xD9FFC2), glow: C(0x2FBF5A), jagged: false), pivot: jackHand,
                              headTop: 7, signature: 3.4, callout: "What's this?", draw: drawJackSkullington),
    .sallee: Persona(name: "Sallee", weapon: .none, headTop: 19, signature: 3.6, draw: drawSallee),
]

/// Where Jack holds out his bony hand: the ghost-green flame leaves from there (raised by the pose's `armRaise`).
private let jackHand = (x: 42.5, y: 33.5)

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

// MARK: - Jack Skullington

/// Jack Skullington: the Pumpkin King, tall and thin. An egg-shaped bone-white skull on a thin neck, huge black eye
/// sockets, two nose slits and a long stitched grin curling up at its ends; the spiky bat-wing collar fanned out
/// behind his head; a black pinstripe suit with a heart-shaped white shirt front and a bat for a bow tie, ragged
/// tailcoat tails, long thin arms and bony white fingers. He fights with a wavering ghost-green flame held in his
/// hand. Signature: his scary face, the skull stretching tall, the mouth gaping full of teeth, eyes angry and both bony
/// hands up clawing beside it; then a deep showman's bow.
private func drawJackSkullington(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x1C1A22), suitD = C(0x121016), stripe = C(0x5A5664), bone = C(0xF2EEE3), boneD = C(0xC8C2B4)
    let sig = p.signature
    let scaring = sig.map { $0 > 0.06 && $0 < 0.55 } ?? false
    let bowK = sig.map { $0 >= 0.6 && $0 < 0.95 ? sin(ramp($0, 0.6, 0.95) * .pi) : 0 } ?? 0
    let stretch = scaring ? Int((sin(ramp(sig!, 0.06, 0.55) * .pi) * 5).rounded()) : 0

    // Long thin pinstriped legs and black shoes.
    drawLegs(c, Look(leg: suit), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() { c.rect(lx + 1, p.step >= 0 && i % 2 == p.step ? 36 : 37, 1, 4, stripe) }
    }
    drawDressShoes(c, step: p.step, color: C(0x0C0B0E))
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
    // The left arm hanging long, the bony fingers below the cuff.
    c.rect(18, 29, 2, 9, suit); c.pattern(17, 38, [".B.", "BBB", "B.B"], ["B": bone])
    let casting = p.zap != nil || p.armRaise > 0
    let raise = p.armRaise
    if casting {
        // The right arm out, the hand open, and the flame dancing on the palm.
        burtonLine(c, 36, 29, 41, Double(33 - raise), suit, 1.0)
        c.pattern(41, 31 - raise, ["B.B.", ".BBB", "BB.."], ["B": bone])
        if p.zap != true {
            let hx = jackHand.x, hy = jackHand.y - Double(raise)
            let flick = sin(p.t * 9) * 0.6
            c.glowLine(hx, hy - 1, hx + flick, hy - 4, core: C(0xD9FFC2), glow: C(0x2FBF5A, 0.8), coreR: 0.7, glowR: 2.2)
        }
    } else {
        c.rect(36, 29, 2, 9, suit); c.pattern(36, 38, [".B.", "BBB", "B.B"], ["B": bone])
    }
}

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

/// Sallee: the rag doll, Clawd in pale blue cloth with stitches across her cheek and round her neck, long red yarn
/// hair falling past her shoulders, red lips, and a patchwork dress of mismatched squares sewn together. She doesn't
/// fight. Signature: her left arm comes loose and drops to the ground; she picks it up and sews it back on, needle
/// flashing, then gives it a little shake to check it holds.
private func drawSallee(_ c: PixelCanvas, _ p: Pose) {
    let cloth = C(0xA8C2E2), clothD = C(0x8AA2C6), thread = C(0x2E3448)
    let hair = C(0xB8252A), hairD = C(0x7E1418), hairL = C(0xD8423E)
    let patches = [C(0x6A8AA8), C(0xC8A048), C(0x8A6A9A), C(0x5A8A5A)]
    let sig = p.signature
    let fallK = sig.map { ramp($0, 0.08, 0.28) } ?? 0          // the arm dropping
    let sewK = sig.map { ramp($0, 0.38, 0.82) } ?? 0           // sewn back up to the shoulder
    let loose = sig.map { $0 > 0.08 && $0 < 0.82 } ?? false
    let sewing = sig.map { $0 >= 0.38 && $0 < 0.82 } ?? false
    let frame = Int(p.t * 8) % 2

    drawLegs(c, Look(leg: cloth), step: p.step)
    if !seatedPose { for lx in [19, 31] { c.px(lx, 40, thread) } }
    c.oy += p.breathe
    // Her body, without its left arm while that's off.
    c.rect(18, 26, 20, 12, cloth); c.rect(18, 37, 20, 1, clothD); c.rect(37, 26, 1, 12, clothD)
    c.rect(38, 33, 3, 3, cloth)
    if !loose { c.rect(15, 33, 3, 3, cloth) }
    // Big eyes with lashes, red lips, the stitched seam across her cheek and round her neck.
    c.rect(22, 29, 2, 3, burtonInk); c.rect(32, 29, 2, 3, burtonInk)
    c.px(21, 28, burtonInk); c.px(34, 28, burtonInk)
    c.rect(26, 32, 4, 1, C(0xC8202A))
    burtonStitches(c, 33, 31, n: 2, gap: 2, down: false, thread)
    // The patchwork dress: squares of different cloth, stitched together, its hem over her knees.
    let hemRows = seatedPose ? 1 : 3
    for y in 34..<(38 + hemRows) {
        for x in 17...38 {
            let k = (x - 17) / 6 + (y - 34) / 3
            let seam = (x - 17) % 6 == 5 && y % 2 == 0
            c.px(x, y, seam ? thread : patches[k % patches.count])
        }
    }
    // The long red yarn hair: a fringe, and strands falling past her shoulders on both sides.
    c.pattern(15, 19, [
        ".....HHHHHHHHHHHHHHH......",
        "...HHHHHlHHHHHHHHlHHHH....",
        "..HHHHHHHHHHHHHHHHHHHHHH..",
        ".HHHHlHHHHHHHHHHHHHlHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHdHHHHHHHHdHHHHHHHH",
        "HHHHHHddHHHHHHHHHHddHHHHHH",
        "HHHH..................HHHH",
        "HHHH..................HHHH",
        "HHdH..................HdHH",
        "HHHH..................HHHH",
        ".HdH..................HdH.",
        ".HHH..................HHH.",
        ".HdH..................HdH.",
        ".HH....................HH.",
        ".Hd....................dH.",
        "..H....................H..",
    ], ["H": hair, "d": hairD, "l": hairL])

    guard loose else { return }
    // The arm off: down on the ground, then lifted back to the shoulder as she sews, the thread joining them.
    let ay = sewing ? Int((41 - 8 * sewK).rounded()) : 33 + Int((8 * fallK).rounded())
    let ax = sewing ? 15 : 14 - Int((2 * fallK).rounded())
    c.rect(ax, ay, 3, 3, cloth); c.px(ax, ay + 2, clothD)
    burtonLine(c, 17.5, 34.5, Double(ax) + 1.5, Double(ay) + 1, thread, 0.4)
    if sewing {
        // Her right hand reaches across with the needle, stitching up and down.
        c.rect(19, 31 + frame, 3, 2, cloth)
        c.px(18, 30 + frame, C(0xD8DCE4)); c.px(17, 29 + frame, C(0xD8DCE4))
    }
}
