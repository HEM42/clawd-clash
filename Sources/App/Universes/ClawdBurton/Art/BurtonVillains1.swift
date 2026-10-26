import Foundation

// Villains: Beetlejuice and Beetlejuice Beetlejuice. Beetlejooce, the ghost with the most, leads the villain side: the
// films' trickster: a pale, mouldy Clawd in a bursting lime mane and the black-and-white striped suit. With him: the
// Sandwurm of Saturn, rearing out of its hole; Delorez, his stapled-together ex; Otho, who reads from the Handbook;
// and Jeremee, the ghost boy with the bike.

let burtonVillains1: [BurtonVillain: Persona] = [
    .beetlejooce: Persona(name: "Beetlejooce", weapon: .saber, pivot: jooceHand, bulk: 7, headTop: 16, signature: 4.0,
                          callout: "It's showtime!", draw: drawBeetlejooce),
    .sandwurm: Persona(name: "The Sandwurm", weapon: .saber, canSit: false, pivot: wurmNeck, bulk: 5, headTop: 10,
                       signature: 3.2, draw: drawSandwurm),
    .delorez: Persona(name: "Delorez", weapon: .lightning, magic: Magic(core: C(0xF4F7FF), glow: C(0x8C9BB0), jagged: false),
                      pivot: delorezHand, headTop: 18, signature: 3.6, draw: drawDelorez),
    .otho: Persona(name: "Otho", weapon: .lightning,
                   magic: Magic(core: C(0xE6CCFF), glow: C(0x9A5BD6), jagged: false, rings: true), pivot: othoHand,
                   headTop: 21, signature: 3.4, draw: drawOtho),
    .jeremee: Persona(name: "Jeremee", weapon: .none, headTop: 19, signature: 3.4, draw: drawJeremee),
]

/// The end of Beetlejooce's right sleeve: his snake arm lashes out from there.
private let jooceHand = (x: 41.0, y: 34.0)

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

// MARK: - Beetlejooce

/// Beetlejooce: Clawd as the ghost with the most: the block a pale, mouldy face with dark sunken eyes and a huge sharp
/// yellow grin, a wild lime mane bursting out round the top of it, and the black-and-white striped suit with a white
/// shirt and black tie over the bottom of it, striped trousers and black boots. He fights the way a poltergeist
/// would: as he strikes, his arm turns into a black-and-white striped snake that lashes out and snaps, and slithers
/// back into the sleeve as he winds up again, his plain hand between strikes. Signature: his name bubbles
/// up over his head three times, and on the third he drops down into a black-and-white striped ring on the floor,
/// hands gripping its rim, and springs straight back up out of it.
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
    // The wild lime mane bursting out round the top of him, swaying a little.
    let cx = 28.0, cy = 28.0
    c.ellipse(Int(cx), 26, 12, 5, hair[1])
    for k in 0..<11 {
        let a = (165.0 + 210.0 * Double(k) / 10 + sin(p.t * 2 + Double(k)) * 3) * .pi / 180
        let len = 11 + noise(k + 3100) * 2.5, w = 2.6, r0 = 4.0
        let tip = (cx + cos(a) * len * 1.25, cy + sin(a) * len)
        let nx = -sin(a), ny = cos(a)
        burtonTriangle(c, tip, (cx + cos(a) * r0 + nx * w, cy + sin(a) * r0 + ny * w),
                       (cx + cos(a) * r0 - nx * w, cy + sin(a) * r0 - ny * w), hair[k % 3])
    }
    // The block: his pale mouldy face, a fringe of lime spikes over its top edge.
    drawBody(c, Look(body: skin, shade: skinD, arm: burtonBone, eye: nil))
    for (x, len) in [(21, 2), (25, 3), (29, 2), (33, 3)] {
        burtonTriangle(c, (Double(x) - 1.5, 25.5), (Double(x) + 1.5, 25.5), (Double(x), 25.5 + Double(len)), hair[0])
    }
    for (x, y) in [(19, 31), (36, 29), (30, 27)] { c.px(x, y, mould) }
    // Dark, sunken eyes: near-black rings round greyish whites and dark green irises, smudged underneath.
    for ex in [21, 31] {
        c.pattern(ex - 1, 27, [".RRRR.", "RRWGRR", "RRGKRR", ".RRRR.", "S....S"],
                  ["S": C(0x8A8690), "R": C(0x24222A), "W": C(0xD4D8CC), "G": C(0x4E8A2A), "K": burtonInk])
    }
    // The huge sharp grin: yellow teeth over a red mouth, running right across him.
    c.pattern(19, 31, ["K................K", ".KTTTTTTTTTTTTTTK.", "..KRTRTRTRTRTRTK.."],
              ["K": burtonInk, "T": C(0xF0D860), "R": C(0xB8241E)])
    // The suit over the bottom of him: broad stripes, the white shirt in a V and the black tie; striped sleeves.
    burtonStripes(c, 18, 34, 20, 4, alongX: true)
    c.pattern(24, 34, ["KWWKKWWK", ".KWKKWK.", "..KKKK..", "...KK..."], ["W": C(0xF4F2EA), "K": burtonInk])
    burtonStripes(c, 15, 33, 3, 3, alongX: false, width: 1)

    // The left arm: a striped sleeve and a grubby long-nailed hand.
    c.pattern(13, 34, ["FF", ".F", ".F"], ["F": hand])
    if !seatedPose { jooceBeetle(c, lt: p.lt) }
    burtonStripes(c, 38, 33, 3, 3, alongX: false, width: 1)
    if let a = p.melee, case let reach = jooceStrike(a), reach > 0.15 {
        // The right arm turned into a striped snake, lashing out along `a` from the sleeve, only while he strikes.
        jooceSnake(c, angle: a, trail: p.trail, t: p.t, reach: reach)
    } else {
        // Between strikes, his plain grubby hand.
        c.pattern(41, 34, ["FF", "F.", "F."], ["F": hand])
    }
}

/// How far (0…1) his snake arm is out at swing angle `a`: in the sleeve while the arm is up on guard or wound back
/// (-60 and above it, as when he walks, waits, cheers or stands guard), shooting out as the swing comes forward past
/// -60, all the way out from -40 down to straight ahead and below; back in as he winds up again.
private func jooceStrike(_ a: Double) -> Double {
    var n = a.truncatingRemainder(dividingBy: 360)
    if n > 180 { n -= 360 } else if n <= -180 { n += 360 }
    return n > 90 ? 0 : ramp(n, -60, -40)
}

/// His snake arm: a long black-and-white banded body slithering out of the sleeve along `angle` in an S that ripples
/// down its length, lagging behind a fast swing, a faint smear where it just was, and a big diamond head on the end
/// with a lime eye; when it strikes the jaws gape and a forked red tongue flicks out. Kept in front of him: it never
/// swings back over his own face. `reach` (0…1) is how far out of the sleeve it is.
private func jooceSnake(_ c: PixelCanvas, angle raw: Double, trail: [Double], t: Double, reach: Double) {
    let angle = max(-100, min(70, raw))
    for (i, a) in trail.enumerated() {
        let p0 = burtonReach(jooceHand, max(-100, min(70, a)), 5 * reach)
        let p1 = burtonReach(jooceHand, max(-100, min(70, a)), 20 * reach)
        c.glowLine(p0.x, p0.y, p1.x, p1.y, core: C(0xE8E8DC), glow: C(0xE8E8DC), coreR: 0.8, glowR: 2.2,
                   strength: 0.3 / Double(i + 1))
    }
    let lag = trail.first.map { max(-100, min(70, $0)) - angle } ?? 0
    let length = max(4, 19 * reach), step = 0.5
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

// MARK: - The Sandwurm

/// Where the Sandwurm's neck bends from: its jaws strike out from here.
private let wurmNeck = (x: 26.0, y: 31.0)

/// The Sandwurm: a lean black-and-white banded worm, Clawd-sized, its head and neck reared up out of a hole in the
/// sand, swaying; a blunt banded head with a little orange eye, and when its jaws open, a red mouth full of teeth with
/// a second, smaller mouth inside that shoots out and snaps. No legs: it travels with its hole, sand spraying. It
/// bites. Signature: it rears up tall and the inner mouth snaps out twice.
private func drawSandwurm(_ c: PixelCanvas, _ p: Pose) {
    let sand = C(0xD8A84A), sandD = C(0xA87A2A), hole = C(0x1A120A)
    let sig = p.signature
    let rear = sig.map { min(ramp($0, 0.08, 0.3), 1 - ramp($0, 0.8, 0.95)) } ?? 0
    let snap = sig.map { $0 > 0.34 && $0 < 0.76 ? max(0, sin(ramp($0, 0.34, 0.76) * .pi * 4)) : 0 } ?? 0
    // The hole stays put in the sand while the worm lunges and recoils: undo the shift the pose gives the whole
    // sprite (`p.dx`, `p.hop`) for it, its front rim and the body's base.
    let fixedX = -Double(p.dx), fixedY = -Double(p.hop)
    c.ox -= p.dx; c.oy -= p.hop
    // The hole: its dark back half behind the worm.
    c.ellipse(28, 43, 9, 2, hole)
    if p.walking {   // sand spraying up as it ploughs along
        for k in 0..<6 {
            let f = frac(p.t * 2.5 + Double(k) / 6)
            c.px(19 - Int(f * 8) + k, 42 - Int(sin(f * .pi) * 6), sand.alpha(1 - f))
        }
    }
    c.ox += p.dx; c.oy += p.hop
    c.oy += p.breathe + (p.walking ? (p.step == 0 ? 1 : 0) : 0)
    // Where the head is: swung along `p.melee` while it bites, reared up in its signature, swaying at rest.
    let raw = p.melee ?? (-58 - rear * 12 + sin(p.lt * 1.6) * 5)
    let angle = max(-100, min(-15, raw))
    let reach = 13 + rear * 5 + (p.melee != nil ? 2 : 0)
    let head = burtonReach(wurmNeck, angle, reach)
    for (i, a) in p.trail.enumerated() {
        let e = burtonReach(wurmNeck, max(-100, min(-15, a)), reach)
        c.glowLine(wurmNeck.x, wurmNeck.y, e.x, e.y, core: C(0xE8E8DC), glow: C(0xE8E8DC), coreR: 1, glowR: 3,
                   strength: 0.28 / Double(i + 1))
    }
    // The body: from the hole up through the neck to the head, an easy S, banded across.
    let base = (x: 28.0 + fixedX, y: 44.0 + fixedY)
    let c1 = (x: 28.0 + fixedX * 0.5, y: 34.0 + fixedY * 0.5)
    let c2 = (x: head.x - cos(angle * .pi / 180) * 9, y: head.y - sin(angle * .pi / 180) * 9)
    var pts: [(x: Double, y: Double)] = []
    for i in 0...40 {
        let u = Double(i) / 40, v = 1 - u
        let sway = sin(u * .pi) * sin(p.lt * 1.3) * 1.5
        pts.append((v * v * v * base.x + 3 * v * v * u * c1.x + 3 * v * u * u * c2.x + u * u * u * head.x + sway,
                    v * v * v * base.y + 3 * v * v * u * c1.y + 3 * v * u * u * c2.y + u * u * u * head.y))
    }
    var run = 0.0
    for i in 1..<pts.count {
        let d = hypot(pts[i].x - pts[i - 1].x, pts[i].y - pts[i - 1].y)
        run += d
        let r = 3.6 - 0.9 * Double(i) / Double(pts.count)
        burtonLine(c, pts[i - 1].x, pts[i - 1].y, pts[i].x, pts[i].y, Int(run / 3) % 2 == 0 ? burtonInk : burtonBone, r)
    }
    // The head: a blunt black oval along the neck's last stretch, a bone band round its back, the eye near its top.
    let dir = atan2(head.y - pts[pts.count - 4].y, head.x - pts[pts.count - 4].x)
    let ux = cos(dir), uy = sin(dir), sx = -uy, sy = ux
    let open = snap > 0 || !p.trail.isEmpty || (p.melee.map { $0 > -30 } ?? false) || rear > 0.5
    let gape = open ? 0.75 : 0
    let red = C(0xB8241E), tooth = C(0xF4F2EA), inner = C(0xE88A8A)
    for y in Int(head.y - 10)...Int(head.y + 10) {
        for x in Int(head.x - 10)...Int(head.x + 10) {
            let dx = Double(x) + 0.5 - head.x, dy = Double(y) + 0.5 - head.y
            let u = dx * ux + dy * uy, v = dx * sx + dy * sy
            guard (u / 8) * (u / 8) + (v / 5.2) * (v / 5.2) <= 1 else { continue }
            if open && u > -1 && abs(v) < (u + 1) * gape {
                // Inside the open jaws: the red mouth, teeth along both jaws.
                c.px(x, y, abs(v) > (u + 1) * gape - 1.1 && u > 0.5 ? tooth : red)
                continue
            }
            let band = u > -5 && u < -2.6          // one bone-white band round the back of the head
            c.px(x, y, band ? burtonBone : burtonInk)
        }
    }
    if open {
        // The inner mouth: a smaller pink head on a stalk, shooting out of the big one and snapping, its own teeth.
        let out = 1 + snap * 4
        let i0 = (x: head.x, y: head.y), i1 = (x: head.x + ux * (1 + out), y: head.y + uy * (1 + out))
        burtonLine(c, i0.x, i0.y, i1.x, i1.y, inner, 1.0)
        let jaw = 1.2 + snap * 1.2
        burtonTriangle(c, (i1.x - ux * 1.5 + sx * 1.6, i1.y - uy * 1.5 + sy * 1.6), (i1.x - ux * 1.5 - sx * 0.2, i1.y - uy * 1.5 - sy * 0.2),
                       (i1.x + ux * 3 + sx * jaw, i1.y + uy * 3 + sy * jaw), inner)
        burtonTriangle(c, (i1.x - ux * 1.5 - sx * 1.6, i1.y - uy * 1.5 - sy * 1.6), (i1.x - ux * 1.5 + sx * 0.2, i1.y - uy * 1.5 + sy * 0.2),
                       (i1.x + ux * 3 - sx * jaw, i1.y + uy * 3 - sy * jaw), inner)
        for side in [-1.0, 1.0] {
            let t = (x: i1.x + ux * 2 + sx * side * (jaw - 0.6), y: i1.y + uy * 2 + sy * side * (jaw - 0.6))
            c.px(Int(t.x.rounded(.down)), Int(t.y.rounded(.down)), tooth)
        }
    } else {
        burtonLine(c, head.x + ux * 1, head.y + uy * 1, head.x + ux * 7.5, head.y + uy * 7.5, C(0x7A2A26), 0.4)
    }
    let eye = (x: head.x - ux * 0.5 - sx * 3.2, y: head.y - uy * 0.5 - sy * 3.2)
    c.rect(Int(eye.x.rounded(.down)), Int(eye.y.rounded(.down)), 1, 1, C(0xFF9A2A))
    // The hole's front rim, a lip of sand heaped round the worm.
    c.oy -= p.breathe + (p.walking ? (p.step == 0 ? 1 : 0) : 0)
    c.ox -= p.dx; c.oy -= p.hop
    for x in 18...38 {
        let k = Double(x - 28) / 10, y = 43 + Int((sqrt(max(0, 1 - k * k)) * 1.5).rounded())
        c.px(x, y, sand); c.px(x, y - 1, abs(x - 28) > 6 ? sandD : sand)
    }
    c.rect(16, 43, 2, 1, sandD); c.rect(39, 43, 2, 1, sandD)
}

// MARK: - Delorez

/// Delorez's casting hand: the soul wisp is drawn out of her target towards it (raised by `armRaise`).
private let delorezHand = (x: 42.5, y: 30.5)

/// Delorez: Beetlejooce's ex, a soul-sucker who was cut to pieces and stapled herself back together: a Clawd pale as
/// the grave in a long black gown under a great mass of black hair, a seam running straight down the middle of her,
/// held shut with silver staples. She draws souls out in a pale steady wisp. Signature: she comes apart along the
/// seam, her two halves drifting off and her hair lifting away, then they come back together and the staples go in,
/// one after another.
private func drawDelorez(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature
    let apart = sig.map { min(ramp($0, 0.08, 0.28), 1 - ramp($0, 0.5, 0.66)) } ?? 0
    let clicks = sig.map { s in [0.68, 0.74, 0.8].filter { s >= $0 && s < $0 + 0.05 } } ?? []
    guard apart > 0 else {
        drawDelorezFigure(c, p)
        delorezStaples(c, clicks)
        return
    }
    // Coming apart: drawn on a layer, then laid down in pieces: the left half, the right half, the hair on top.
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    drawDelorezFigure(s, p)
    let gap = Int((apart * 4).rounded()), lift = Int((apart * 6).rounded())
    let wob = Int((sin(p.t * 3) * apart * 1.5).rounded())
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    defer { c.ox = ox; c.oy = oy; c.baseY = by }
    let top = 26 + oy + by
    for y in 0..<s.h {
        for x in 0..<s.w {
            let i = (y * s.w + x) * 4, a = s.buf[i + 3]
            guard a > 0 else { continue }
            let m = 255 / Double(a)
            let col = Px(r: UInt8(min(255, Double(s.buf[i]) * m)), g: UInt8(min(255, Double(s.buf[i + 1]) * m)),
                         b: UInt8(min(255, Double(s.buf[i + 2]) * m)), a: a)
            if y >= 38 + oy + by { c.px(x, y, col); continue }                    // the gown's skirt and her legs stay
            if y < top { c.px(x, y - lift, col); continue }                       // the hair lifts off
            let left = x < 28 + ox
            c.px(x + (left ? -gap : gap), y + (left ? wob : -wob), col)
        }
    }
}

/// Delorez without the coming apart: the gown, Clawd with the seam and staples, the hair, the arms.
private func drawDelorezFigure(_ c: PixelCanvas, _ p: Pose) {
    let gown = C(0x18161C), gownD = C(0x0E0C12), gownL = C(0x2E2A36), hair = C(0x14121A), hairL = C(0x34303E)
    let staple = C(0xC8C8D4)
    drawLegs(c, Look(leg: gownD), step: p.step)
    burtonBoots(c, step: p.step, C(0x08080A), height: 2)
    c.oy += p.breathe
    // The long black gown: its skirt flaring down over her legs, its bodice over the bottom of Clawd.
    let hem = seatedPose ? 39 : 41
    for y in 38...hem { let hw = 11 + (y - 38); c.rect(28 - hw, y, hw * 2, 1, gown); c.px(28 + hw - 1, y, gownD) }
    drawBody(c, Look(body: C(0xE4E0E8), shade: C(0xC0BAC8), arm: gown))
    c.rect(18, 33, 20, 5, gown); c.rect(37, 33, 1, 5, gownD); c.rect(20, 33, 1, 5, gownL)
    c.pattern(22, 33, ["KK..........", ".KK......KK."], ["K": gownL])
    // Dark shadow over her eyes, and the seam down the middle of her with its staples.
    c.rect(21, 28, 4, 1, C(0x8A7A9A)); c.rect(31, 28, 4, 1, C(0x8A7A9A))
    c.rect(28, 26, 1, 12, C(0x8A3A2A))
    for y in [27, 30, 34, 37] { c.rect(27, y, 3, 1, staple) }
    // The great mass of black hair, piled up on top and falling down past her shoulders.
    c.pattern(14, 18, [
        ".......HHHHHHHHHHHH.......",
        ".....HHHHHHHHhHHHHHHH.....",
        "...HHHHHHhHHHHHHHHhHHHH...",
        "..HHHHHHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHH...........HHHHHHHH",
        "HHHHH................HHHHH",
        "HHHH..................HHHH",
        "HHHH..................HHHH",
        "HHH....................HHH",
        "HHH....................HHH",
        "HHH....................HHH",
        ".HH....................HH.",
        ".HH....................HH.",
        "..H....................H..",
    ], ["H": hair, "h": hairL])
    // Her right arm raised while she draws a soul out.
    if p.zap != nil || p.armRaise > 0 {
        burtonLine(c, 39, 34, 41.5, Double(31 - p.armRaise), gown, 1.4); c.rect(41, 30 - p.armRaise, 2, 2, C(0xE4E0E8))
    }
}

/// The staple gun going in along her seam: a little white flash at each staple in turn.
private func delorezStaples(_ c: PixelCanvas, _ clicks: [Double]) {
    for s in clicks {
        let y = s == 0.68 ? 27 : s == 0.74 ? 30 : 34
        c.pattern(26, y - 2, ["..W..", ".WWW.", "WWWWW", ".WWW.", "..W.."], ["W": C(0xFFFFFF, 0.9)])
    }
}

// MARK: - Otho

/// Otho's raised hand: his séance rings ripple out from there (raised by `armRaise`).
private let othoHand = (x: 42.5, y: 27.5)

/// Otho: the paranormal expert and interior designer, theatrical: Clawd in a black turtleneck with a red scarf thrown
/// round his neck, one end hanging down his front, dark hair swept back from a widow's peak, arched brows and a dark
/// goatee. He fights with séance rings. Signature: he opens the Handbook in one hand, raises the other high and reads
/// from it, mouth wide.
private func drawOtho(_ c: PixelCanvas, _ p: Pose) {
    let knit = C(0x1C1C22), knitD = C(0x111116), knitL = C(0x34343E), red = C(0xC82030), redD = C(0x8E1420)
    let hair = C(0x1E1A1E), hairL = C(0x3A343A)
    let sig = p.signature
    let reading = sig.map { $0 > 0.1 && $0 < 0.9 } ?? false

    drawLegs(c, Look(leg: knitD), step: p.step)
    burtonBoots(c, step: p.step, C(0x08080A), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: knit))
    // The turtleneck over the bottom of Clawd, its ribbed roll collar; the red scarf round it, one end hanging.
    c.rect(18, 33, 20, 5, knit); c.rect(37, 33, 1, 5, knitD)
    c.rect(18, 33, 20, 1, knitL); for x in stride(from: 19, to: 38, by: 2) { c.px(x, 33, knit) }
    c.rect(18, 32, 20, 1, red); c.rect(20, 33, 16, 1, redD)
    c.pattern(30, 33, ["RR.", "RRR", ".RR", ".RR", "RRR", "R.R", "R.R"], ["R": red])
    // The goatee under his eyes, his mouth open in it while he reads.
    c.pattern(26, 30, ["G.M.G", ".GGG."], ["G": hair, "M": reading ? C(0x7A2A2A) : clawdOrange])
    // Dark hair swept back over the top of Clawd, the widow's peak dipping down his brow.
    c.pattern(17, 21, [
        "....HHHHHHHHHHHHHH....",
        "..HHHHHHHhhHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHH.....HHHH.....HHH.",
        ".HH.......HH.......HH.",
        ".H..................H.",
    ], ["H": hair, "h": hairL])
    // Arms: the Handbook open in his left hand and the right raised high while he reads; the right raised to cast.
    if reading {
        burtonLine(c, 16.5, 34, 14, 32, knit, 1.2); burtonHandbook(c, x: 2, y: 29, open: true)
        burtonLine(c, 39.5, 34, 42, 20, knit, 1.3); c.rect(41, 17, 3, 3, clawdOrange)
        return
    }
    if p.zap != nil || p.armRaise > 0 {
        burtonLine(c, 39.5, 34, 41.5, Double(29 - p.armRaise), knit, 1.3); c.rect(41, 26 - p.armRaise, 3, 3, clawdOrange)
    }
}

// MARK: - Jeremee

/// Jeremee: a ghost boy with a faint pale glow and a too-charming smile: a pale, ghost-blue Clawd with a brown quiff,
/// a maroon varsity sweater with cream bands and a big cream J, jeans and white sneakers. He doesn't fight. Signature:
/// his bicycle appears beside him; he leans on its handlebars, winks, and his smile twinkles.
private func drawJeremee(_ c: PixelCanvas, _ p: Pose) { burtonGhost(c) { drawJeremeeFigure($0, p) } }

private func drawJeremeeFigure(_ c: PixelCanvas, _ p: Pose) {
    let sweater = C(0x7A1E2A), sweaterD = C(0x561420), cream = C(0xF0E4C8), skin = C(0xD0DCEC), skinD = C(0xA8B8CC)
    let hair = C(0x6A4A2A), hairL = C(0x8A6A3E)
    let sig = p.signature
    let bike = sig.map { min(ramp($0, 0.05, 0.25), 1 - ramp($0, 0.85, 0.98)) } ?? 0
    let leaning = bike > 0.95
    let wink = sig.map { $0 > 0.45 && $0 < 0.6 } ?? false
    let twinkle = sig.map { $0 >= 0.55 && $0 < 0.75 ? sin(ramp($0, 0.55, 0.75) * .pi) : 0 } ?? 0

    if bike > 0 {
        // The bike, fading in beside him: two wheels, a red frame, the handlebars by his left hand.
        let b = PixelCanvas(c.w, c.h)
        b.ox = c.ox + 3; b.oy = c.oy; b.baseY = c.baseY
        let tyre = C(0x2A2A30), frame = C(0xC8202A)
        for wx in [3, 15] {   // tyres as rings, a hub in the middle
            for y in 34...44 {
                for x in (wx - 5)...(wx + 5) {
                    let d = hypot(Double(x) + 0.5 - Double(wx) - 0.5, Double(y) + 0.5 - 39.5)
                    if d > 3.3 && d <= 4.6 { b.px(x, y, tyre) }
                }
            }
            b.px(wx, 39, C(0x9A9AA8))
        }
        for (p0, p1) in [((3.5, 39.5), (9.5, 39.5)), ((9.5, 39.5), (7.5, 32.5)), ((7.5, 33.0), (13.5, 33.0)),
                         ((9.5, 39.5), (13.5, 33.0)), ((3.5, 39.5), (7.5, 33.0)), ((13.5, 33.0), (15.5, 39.5))] {
            burtonLine(b, p0.0, p0.1, p1.0, p1.1, frame, 0.6)
        }
        burtonLine(b, 13.5, 33, 14.5, 29, C(0x9A9AA8), 0.45); b.rect(13, 28, 4, 1, tyre); b.rect(5, 31, 4, 1, tyre)
        let (ox, oy, by) = (c.ox, c.oy, c.baseY)
        c.ox = 0; c.oy = 0; c.baseY = 0
        c.paste(b, alpha: bike)
        c.ox = ox; c.oy = oy; c.baseY = by
    }
    drawLegs(c, Look(leg: C(0x3A4A6A)), step: p.step)
    burtonBoots(c, step: p.step, C(0xF0F0F0), height: 2)
    c.oy += p.breathe
    // The ghost-blue Clawd, his wink, the too-charming smile.
    drawBody(c, Look(body: skin, shade: skinD, arm: sweater, eye: nil))
    c.rect(22, 29, 2, 3, ink)
    if wink { c.rect(32, 30, 2, 1, ink) } else { c.rect(32, 29, 2, 3, ink) }
    c.pattern(24, 31, ["K......K", ".KWWWWK."], ["K": ink, "W": C(0xFFFFFF)])
    if twinkle > 0.2 { c.pattern(29, 29, ["..W..", ".WWW.", "WWWWW", ".WWW.", "..W.."], ["W": C(0xFFFFFF, twinkle)]) }
    // The varsity sweater over the bottom of Clawd: a cream band at its hem, cream cuffs, the big letter J.
    c.rect(18, 33, 20, 5, sweater); c.rect(37, 33, 1, 5, sweaterD); c.rect(18, 37, 20, 1, cream)
    c.pattern(31, 33, ["JJJ", "..J", "J.J", ".J."], ["J": cream])
    c.px(15, 35, cream); c.px(40, 35, cream)
    // The brown quiff over the top of him.
    c.pattern(17, 19, [
        "........hhhh..........",
        "......hhhhhhh.........",
        "...HHHHHHHHHHHHHHH....",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHH..............HHH.",
        ".HH................HH.",
    ], ["H": hair, "h": hairL])
    // His left hand on the handlebars while he leans.
    if leaning { burtonLine(c, 16.5, 34, 17.5, 29.5, sweater, 1.1); c.rect(17, 27, 2, 2, skin) }
}
