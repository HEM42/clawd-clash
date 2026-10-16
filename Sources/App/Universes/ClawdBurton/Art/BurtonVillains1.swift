import Foundation

// Villains: Beetlejuice and Beetlejuice Beetlejuice. Beetlejooce, the ghost with the most, leads the villain side: the
// films' trickster: a pale, mouldy face in a bursting lime mane, and the black-and-white striped suit.

let burtonVillains1: [BurtonVillain: Persona] = [
    .beetlejooce: Persona(name: "Beetlejooce", weapon: .saber, pivot: jooceHand, bulk: 7, headTop: 10, signature: 4.0,
                          callout: "It's showtime!", draw: drawBeetlejooce),
]

/// The end of Beetlejooce's right sleeve: his snake arm lashes out from there.
private let jooceHand = (x: 41.0, y: 34.0)

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

// MARK: - Beetlejooce

/// Beetlejooce: a tall pale face with mould on it, dark sunken eyes and a huge sharp yellow grin, a wild lime mane
/// bursting out round it, and the black-and-white striped suit with a white shirt and black tie, trousers and all,
/// and black boots. He fights the way a poltergeist would: his arm turns into a black-and-white striped snake that
/// lashes out and snaps. Signature: his name bubbles up over his head three times, and on the third he drops down
/// into a black-and-white striped ring on the floor, hands gripping its rim, and springs straight back up out of it.
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
        drawJooceFigure(body, p)
        c.paste(body.onlyRows(0..<43))
    } else {
        let oy = c.oy
        c.oy += sink
        drawJooceFigure(c, p)
        c.oy = oy
    }
    if ringA > 0 { jooceRing(c, alpha: ringA, front: true, grip: sink > 12) }
}

/// Beetlejooce himself, everything but the ring and the bubbles.
private func drawJooceFigure(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xF2F4EC), skinD = C(0xCED2C6), hand = C(0xC4E0B0), mould = C(0x9ACB4A)
    let hair = [C(0x9ADB2E), C(0x5E9A1A), C(0xC8F060)]

    // Striped trousers (each leg half black, half bone) and black boots.
    drawLegs(c, Look(leg: burtonBone), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, 36, 1, lifted ? 7 : 8, burtonInk)
            c.rect(lx, lifted ? 41 : 42, 2, 2, C(0x141418))
        }
    }
    c.oy += p.breathe
    // The suit: broad stripes, the white shirt in a V and the black tie; striped sleeves.
    drawBody(c, Look(body: burtonBone, shade: burtonBone, arm: burtonBone, eye: nil))
    burtonStripes(c, 18, 26, 20, 12, alongX: true)
    burtonStripes(c, 15, 33, 3, 3, alongX: false, width: 1)
    c.pattern(23, 32, ["KWWWKKWWWK", ".KWWKKWWK.", "..KWKKWK..", "...KKKK...", "....KK...."], ["W": C(0xF4F2EA), "K": burtonInk])
    // The wild lime mane bursting out round his face, swaying a little.
    let cx = 28.0, cy = 22.0
    c.ellipse(Int(cx), Int(cy), 11, 10, hair[1])
    for k in 0..<13 {
        let a = (150.0 + 240.0 * Double(k) / 12 + sin(p.t * 2 + Double(k)) * 3) * .pi / 180
        let len = 15 + noise(k + 3100) * 3, w = 3.2, r0 = len * 0.4
        let tip = (cx + cos(a) * len, cy + sin(a) * len)
        let nx = -sin(a), ny = cos(a)
        burtonTriangle(c, tip, (cx + cos(a) * r0 + nx * w, cy + sin(a) * r0 + ny * w),
                       (cx + cos(a) * r0 - nx * w, cy + sin(a) * r0 - ny * w), hair[k % 3])
    }
    // The tall pale face, a fringe of spikes over the forehead, and mould on it.
    for (r, h) in [6, 8, 9, 9, 9, 9, 9, 9, 9, 9, 8, 8, 7].enumerated() {
        c.rect(28 - h, 19 + r, h * 2, 1, skin); c.px(28 + h - 1, 19 + r, skinD)
    }
    for (x, len) in [(22, 3), (26, 4), (30, 3), (34, 2)] {
        burtonTriangle(c, (Double(x) - 1.5, 18.5), (Double(x) + 1.5, 18.5), (Double(x), 18.5 + Double(len)), hair[0])
    }
    for (x, y) in [(20, 27), (35, 28), (30, 21)] { c.px(x, y, mould) }
    // Dark, sunken eyes: thick near-black rings smudged round greyish whites and dark green irises.
    for ex in [20, 30] {
        c.pattern(ex - 1, 20, ["..RRRR..", ".RRWWRR.", "RRWGGWRR", "RRWGKWRR", ".RRWWRR.", "S.RRRR.S", ".SSSSSS."],
                  ["S": C(0x6A6670), "R": C(0x24222A), "W": C(0xD4D8CC), "G": C(0x4E8A2A), "K": burtonInk])
    }
    // The huge sharp grin: yellow teeth over a red mouth.
    c.pattern(20, 28, ["K..............K", "KKTTTTTTTTTTTTKK", ".KRTRTRTRTRTRTK.", "..KKKKKKKKKKKK.."],
              ["K": burtonInk, "T": C(0xF0D860), "R": C(0xB8241E)])

    // The left arm: a striped sleeve and a grubby long-nailed hand.
    c.pattern(13, 34, ["FF", ".F", ".F"], ["F": hand])
    if !seatedPose { jooceBeetle(c, lt: p.lt) }
    if let a = p.melee {
        // The right arm turned into a striped snake, lashing out along `a` from the sleeve.
        burtonStripes(c, 38, 33, 3, 3, alongX: false, width: 1)
        jooceSnake(c, angle: a, trail: p.trail, t: p.t)
    } else {
        burtonStripes(c, 38, 33, 3, 3, alongX: false, width: 1)
        c.pattern(41, 34, ["FF", "F.", "F."], ["F": hand])
    }
}

/// His snake arm: a long black-and-white banded body slithering out of the sleeve along `angle` in an S that ripples
/// down its length, lagging behind a fast swing, a faint smear where it just was, and a big diamond head on the end
/// with a lime eye; when it strikes the jaws gape and a forked red tongue flicks out. Kept in front of him: it never
/// swings back over his own face.
private func jooceSnake(_ c: PixelCanvas, angle raw: Double, trail: [Double], t: Double) {
    let angle = max(-100, min(70, raw))
    for (i, a) in trail.enumerated() {
        let p0 = burtonReach(jooceHand, max(-100, min(70, a)), 5), p1 = burtonReach(jooceHand, max(-100, min(70, a)), 20)
        c.glowLine(p0.x, p0.y, p1.x, p1.y, core: C(0xE8E8DC), glow: C(0xE8E8DC), coreR: 0.8, glowR: 2.2, strength: 0.3 / Double(i + 1))
    }
    let lag = trail.first.map { max(-100, min(70, $0)) - angle } ?? 0
    let length = 19.0, step = 0.5
    var pts: [(x: Double, y: Double)] = []
    for i in 0...Int(length / step) {
        let s = Double(i) * step, f = s / length
        let a = (angle + lag * f * f * 0.7) * .pi / 180
        let wave = sin(s / 7.5 * 2 * .pi - t * 9) * 2.6 * min(1, s / 4)
        pts.append((jooceHand.x + cos(a) * s - sin(a) * wave, jooceHand.y + sin(a) * s + cos(a) * wave))
    }
    // The body, banded across, thick at the sleeve and thinner towards the head.
    for i in 1..<pts.count {
        let s = Double(i) * step, r = 1.7 - 0.6 * s / length
        let col = Int(s / 2.2) % 2 == 0 ? burtonInk : burtonBone
        burtonLine(c, pts[i - 1].x, pts[i - 1].y, pts[i].x, pts[i].y, col, r)
    }
    // The head, along the body's last stretch.
    let neck = pts[pts.count - 3], end = pts[pts.count - 1]
    let dir = atan2(end.y - neck.y, end.x - neck.x)
    let ux = cos(dir), uy = sin(dir), sx = -uy, sy = ux
    let striking = !trail.isEmpty || raw > 20
    let back = (x: end.x - ux * 1, y: end.y - uy * 1), nose = (x: end.x + ux * 5, y: end.y + uy * 5)
    if striking {
        // Jaws gaping: the upper and lower jaw apart, the red mouth between and the forked tongue out.
        let gape = 2.6
        burtonTriangle(c, (back.x + sx * 2.4, back.y + sy * 2.4), (back.x - sx * 0.4, back.y - sy * 0.4),
                       (nose.x + sx * gape, nose.y + sy * gape), burtonInk)
        burtonTriangle(c, (back.x - sx * 2.4, back.y - sy * 2.4), (back.x + sx * 0.4, back.y + sy * 0.4),
                       (nose.x - sx * gape, nose.y - sy * gape), burtonInk)
        burtonTriangle(c, (back.x + ux * 1.5, back.y + uy * 1.5), (nose.x + sx * 1.6, nose.y + sy * 1.6),
                       (nose.x - sx * 1.6, nose.y - sy * 1.6), C(0xB8241E))
        let tip = (x: nose.x + ux * 3, y: nose.y + uy * 3)
        burtonLine(c, nose.x - ux, nose.y - uy, tip.x, tip.y, C(0xFF3A3A), 0.45)
        burtonLine(c, tip.x, tip.y, tip.x + ux * 1.4 + sx * 1.2, tip.y + uy * 1.4 + sy * 1.2, C(0xFF3A3A), 0.4)
        burtonLine(c, tip.x, tip.y, tip.x + ux * 1.4 - sx * 1.2, tip.y + uy * 1.4 - sy * 1.2, C(0xFF3A3A), 0.4)
    } else {
        // Closed: a diamond head with a bone stripe down it.
        let mid = (x: end.x + ux * 2, y: end.y + uy * 2)
        burtonTriangle(c, (back.x, back.y), (mid.x + sx * 2.6, mid.y + sy * 2.6), (mid.x - sx * 2.6, mid.y - sy * 2.6), burtonInk)
        burtonTriangle(c, (nose.x, nose.y), (mid.x + sx * 2.6, mid.y + sy * 2.6), (mid.x - sx * 2.6, mid.y - sy * 2.6), burtonInk)
        burtonLine(c, back.x + ux, back.y + uy, nose.x - ux * 1.5, nose.y - uy * 1.5, burtonBone, 0.45)
    }
    let eye = (x: end.x + ux * 1.6 - sx * 1.4, y: end.y + uy * 1.6 - sy * 1.4)
    c.rect(Int(eye.x.rounded()), Int(eye.y.rounded()), 1, 1, C(0xC8F060))
}

/// Now and then a beetle drops out of his left sleeve, lands, and scuttles off along the floor behind him, on his own
/// clock (`lt`), once every seven seconds.
private func jooceBeetle(_ c: PixelCanvas, lt: Double) {
    let k = (lt + 3).truncatingRemainder(dividingBy: 7) / 7
    guard k < 0.4 else { return }
    let x: Int, y: Int
    if k < 0.08 {   // falling from the cuff, tumbling
        x = 14; y = 37 + Int((k / 0.08 * 6).rounded())
    } else {        // scuttling away
        x = 14 - Int(((k - 0.08) / 0.32 * 18).rounded()); y = 43
    }
    burtonBeetle(c, x: x, y: y, step: Int(lt * 16) % 2 == 0, left: true)
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
/// false), its thick front rim over him; `grip`: his two hands holding on to the rim as he goes under.
private func jooceRing(_ c: PixelCanvas, alpha: Double, front: Bool, grip: Bool = false) {
    let cx = 28.0, cy = 43.0, rx = 16.0, ry = 4.5
    if !front { c.ellipse(Int(cx), Int(cy), Int(rx) - 2, Int(ry) - 1, C(0x050507, alpha)) }
    for k in 0..<160 {
        let a = Double(k) / 160 * 2 * .pi
        guard (sin(a) > 0) == front else { continue }
        let x = Int((cx + cos(a) * rx).rounded()), y = Int((cy + sin(a) * ry).rounded())
        let col = ((k / 10) % 2 == 0 ? burtonBone : burtonInk).alpha(alpha)
        c.rect(x, y - (front ? 0 : 1), 1, 2, col); c.px(x, y + (front ? 2 : -2), col.alpha(0.6))
    }
    guard front, grip else { return }
    for (x, mirror) in [(15, false), (38, true)] {
        c.pattern(x, 40, mirror ? [".FF", "FFF", "F.F"] : ["FF.", "FFF", "F.F"], ["F": C(0xE4E6D8, alpha)])
    }
}
