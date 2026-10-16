import Foundation

// Villains: Beetlejuice and Beetlejuice Beetlejuice. Beetlejooce, the ghost with the most, leads the villain side: the
// films' trickster, a grubby green-white Clawd in a black-and-white striped suit under a wild mossy mop.

let burtonVillains1: [BurtonVillain: Persona] = [
    .beetlejooce: Persona(name: "Beetlejooce", weapon: .lightning,
                          magic: Magic(core: C(0xB7E35A), glow: C(0x3F6B1A), jagged: false, spell: true),
                          pivot: jooceHand, headTop: 15, signature: 4.0, callout: "It's showtime!",
                          draw: drawBeetlejooce),
]

/// Where Beetlejooce holds up his grubby hand: the moss-green sparkles leave from there (raised by `armRaise`).
private let jooceHand = (x: 42.5, y: 33.5)

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

// MARK: - Beetlejooce

/// Beetlejooce: Clawd with a grubby green-white face, dark rings round his eyes and a crooked yellow grin, a wild
/// mop of mossy green hair sticking out every way, and the black-and-white striped suit, trousers and all. He fights
/// with moss-green sparkles. Signature: his name bubbles up over his head three times, and on the third he drops
/// down into a black-and-white striped ring on the floor and springs straight back up out of it.
private func drawBeetlejooce(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature
    let bubbles = sig.map { $0 < 0.08 ? 0 : $0 < 0.2 ? 1 : $0 < 0.32 ? 2 : $0 < 0.5 ? 3 : 0 } ?? 0
    let ringA = sig.map { min(ramp($0, 0.32, 0.4), 1 - ramp($0, 0.88, 0.98)) } ?? 0
    // How far down into the ring he is: in by 0.62, out again by 0.8, with a little spring at the top.
    let sink: Int = sig.map { s in
        if s < 0.42 || s >= 0.86 { return 0 }
        if s < 0.62 { return Int((ramp(s, 0.42, 0.62) * 26).rounded()) }
        if s < 0.7 { return 26 }
        if s < 0.8 { return Int(((1 - ramp(s, 0.7, 0.8)) * 26).rounded()) }
        return -Int((sin(ramp(s, 0.8, 0.86) * .pi) * 3).rounded())
    } ?? 0

    for i in 0..<bubbles { jooceBubble(c, i) }
    if ringA > 0 { jooceRing(c, alpha: ringA, front: false) }
    if sink > 0 {
        // Drawn on its own and cut off at the ring, so he goes down into it rather than through the floor.
        let body = PixelCanvas(c.w, c.h)
        body.oy = sink
        drawJooceFigure(body, p, casting: false)
        c.paste(body.onlyRows(0..<43))
    } else {
        let oy = c.oy
        c.oy += sink
        drawJooceFigure(c, p, casting: p.zap != nil || p.armRaise > 0)
        c.oy = oy
    }
    if ringA > 0 { jooceRing(c, alpha: ringA, front: true) }
}

/// Beetlejooce himself, everything but the ring and the bubbles.
private func drawJooceFigure(_ c: PixelCanvas, _ p: Pose, casting: Bool) {
    let face = C(0xDCE2C4), faceD = C(0xB4BC98), grime = C(0x9AA670), ringD = C(0x4E4A38)
    let moss = C(0x7A8C42), mossD = C(0x55642A), mossL = C(0xA8BC66)
    let teeth = C(0xD8C870)

    // The striped trousers: each leg half black, half white.
    drawLegs(c, Look(leg: burtonBone), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() { c.rect(lx, 36, 1, p.step >= 0 && i % 2 == p.step ? 7 : 8, burtonInk) }
    }
    c.oy += p.breathe
    drawBody(c, Look(body: face, shade: faceD, arm: burtonBone, eye: nil))
    // The striped suit jacket over his middle and down his arms.
    burtonStripes(c, 18, 32, 20, 6, alongX: true)
    c.rect(37, 32, 1, 6, C(0x0A0A0E, 0.4))
    burtonStripes(c, 15, 33, 3, 3, alongX: false, width: 1)
    // A grubby face: dark-ringed eyes, mould on his cheeks, and the crooked yellow grin.
    c.rect(21, 28, 4, 5, ringD); c.rect(31, 28, 4, 5, ringD)
    c.rect(22, 29, 2, 3, burtonInk); c.rect(32, 29, 2, 3, burtonInk)
    for (x, y) in [(19, 27), (20, 31), (35, 27), (36, 30), (27, 27), (29, 29)] { c.px(x, y, grime) }
    c.pattern(24, 30, ["K......K", ".KTKTTK.", "..KKKK.."], ["K": burtonInk, "T": teeth])
    // The wild mossy mop, sticking out every way.
    c.pattern(13, 15, [
        "....M..........m....M.....",
        ".....MM...M...MM...MM.....",
        "..M..MMM.MMM.MMMM.MMM..M..",
        "...MMMMMMMMMMMMMMMMMMMMM..",
        ".MMMMMlMMMMMMMlMMMMMMlMMMM",
        "..MMMMMMMMMdMMMMMMMMMMMMM.",
        "MMMMMdMMMMMMMMMMdMMMMMMMMM",
        ".MMMMMMMMMMMMMMMMMMMMMMMM.",
        "..MMMMdMMMMlMMMMMMMdMMMMM.",
        ".MMMMM..M.MMM..M..M.MMMMMM",
        "MMMd..................MdMM",
        ".MM....................MM.",
        "MM......................M.",
    ], ["M": moss, "d": mossD, "l": mossL, "m": mossL])

    if casting {
        // The right hand up, crooked fingers spread, sparkles fizzing off them.
        let raise = p.armRaise
        burtonStripes(c, 38, 32 - raise, 3, 3, alongX: false, width: 1)
        c.pattern(41, 31 - raise, ["F.F", "FFF", "FF."], ["F": face])
        if p.zap != true {
            for k in 0..<3 {
                let a = p.t * 7 + Double(k) * 2.1
                c.px(Int((jooceHand.x + cos(a) * 2.5).rounded()), Int((jooceHand.y - Double(raise) - 2 + sin(a) * 2).rounded()),
                     C(0xB7E35A, 0.8))
            }
        }
    } else {
        burtonStripes(c, 38, 33, 3, 3, alongX: false, width: 1)
        c.px(41, 35, face)
    }
}

/// One of the three speech bubbles his name rises in: the first on the left, the third on the right, each with a
/// big pixel B and a tail pointing down at him.
private func jooceBubble(_ c: PixelCanvas, _ i: Int) {
    let x = [8, 24, 40][i], y = [8, 2, 8][i]
    c.pattern(x, y, [
        ".WWWWWWWWWWW.",
        "WWWWKKKKWWWWW",
        "WWWWKWWWKWWWW",
        "WWWWKKKKWWWWW",
        "WWWWKWWWKWWWW",
        "WWWWKKKKWWWWW",
        ".WWWWWWWWWWW.",
        i == 0 ? "........WW..." : i == 1 ? ".....WW......" : "...WW........",
        i == 0 ? ".........W..." : i == 1 ? "......W......" : "...W.........",
    ], ["W": burtonBone, "K": burtonInk])
}

/// The black-and-white striped ring on the floor he drops into: its dark hole and back half behind him (`front`
/// false), its front half over him.
private func jooceRing(_ c: PixelCanvas, alpha: Double, front: Bool) {
    let cx = 28.0, cy = 43.0, rx = 14.0, ry = 3.5
    if !front { c.ellipse(Int(cx), Int(cy), Int(rx) - 2, Int(ry) - 1, C(0x050507, alpha)) }
    for k in 0..<120 {
        let a = Double(k) / 120 * 2 * .pi
        let inFront = sin(a) > 0
        guard inFront == front else { continue }
        let x = Int((cx + cos(a) * rx).rounded()), y = Int((cy + sin(a) * ry).rounded())
        let col = (k / 8) % 2 == 0 ? burtonBone : burtonInk
        c.px(x, y, col.alpha(alpha)); c.px(x, y + 1, col.alpha(alpha))
    }
}
