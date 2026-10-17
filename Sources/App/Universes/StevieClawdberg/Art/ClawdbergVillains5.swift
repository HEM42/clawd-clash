import Foundation

// Villains: Jurassic Park. The dinosaurs are Clawd in dinosaur suits, the kind with the wearer's face showing through
// a window in the chest: the blocky body in scales, a tail out behind, a big head on top and Clawd's own orange face
// peering out. The people are Clawd in costume as usual: a raincoat over a loud shirt, a lawyer's suit, a lab coat.

let clawdbergVillains5: [ClawdbergVillain: Persona] = [
    .tWrecks: Persona(name: "T. Wrecks", weapon: .saber, canSit: false, pivot: (50, 18), bulk: 10, headTop: 9,
                      signature: 3.6, callout: "ROAR!", draw: drawTWrecks),
    .cleverGirl: Persona(name: "Clever Girl", weapon: .saber, pivot: (44, 31), bulk: 3, headTop: 14, signature: 3.6,
                         draw: drawCleverGirl),
    .spitter: Persona(name: "Spitter", weapon: .blaster, shot: .thrown(C(0x3E2A18)), muzzle: (49, 20), handGun: false,
                      bulk: 2, headTop: 14, signature: 3.0, draw: drawSpitter),
    .dennisNerdry: Persona(name: "Dennis Nerdry", weapon: .blaster, shot: .thrown(C(0x8A6438)), muzzle: (44, 29),
                           bulk: 2, headTop: 21, signature: 2.8, callout: "Uh uh uh!", draw: drawDennisNerdry),
    .indominusRex: Persona(name: "Indominous Rex", weapon: .saber, canSit: false, pivot: (52, 14), bulk: 12, headTop: 4,
                           signature: 3.8, draw: drawIndominusRex),
    .gennarrow: Persona(name: "Donald Gennarrow", headTop: 22, signature: 4.0, draw: drawGennarrow),
    .drWoo: Persona(name: "Dr. Woo", headTop: 21, signature: 3.2, draw: drawDrWoo),
]

// MARK: - Shared bits

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// A dinosaur suit's four legs, in the suit's scales, each with a claw at the front of the foot.
private func dinoLegs(_ c: PixelCanvas, step: Int, _ hide: Px, _ claw: Px) {
    drawLegs(c, Look(leg: hide), step: step)
    guard !seatedPose else { return }
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        let up = step >= 0 && i % 2 == step ? 1 : 0
        c.px(lx + 1, 43 - up, claw)
    }
}

/// The suit's chest window: a dark rim round Clawd's own orange face and eyes.
private func faceWindow(_ c: PixelCanvas, rim: Px) {
    c.rect(19, 27, 18, 7, rim)
    c.rect(20, 28, 16, 5, clawdOrange)
    c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    c.px(20, 28, rim.alpha(0.6)); c.px(35, 28, rim.alpha(0.6))
}

/// A tail tapering back to the left from the body (x `root`) to its tip (x `tip`), its centre line going from
/// `rootY` to `tipY`; `sway` swings the tip up or down. `stripe` paints a dark band every few columns.
private func tail(_ c: PixelCanvas, root: Int, tip: Int, rootY: Double, tipY: Double, half: Double, sway: Double,
                  _ hide: Px, _ dark: Px, stripe: Px? = nil) {
    for x in tip...root {
        let k = Double(root - x) / Double(root - tip)
        let lift = sway * k * k
        let mid = rootY + (tipY - rootY) * k + lift
        let h = half * (1 - k) + 0.5
        let top = Int((mid - h).rounded()), bottom = Int((mid + h).rounded())
        c.rect(x, top, 1, bottom - top + 1, hide)
        c.px(x, bottom, dark)
        if let s = stripe, x % 4 == 0 { c.rect(x, top, 1, max(1, (bottom - top + 1) / 2), s) }
    }
}

/// How far a biter's jaw drops at melee angle `a`: wide on the forward strike, shut when the weapon would be up.
private func jawOpen(_ a: Double?) -> Double {
    guard let a else { return 0 }
    return max(0, 1 - abs(a - 5) / 50)
}

// MARK: - T. Wrecks

/// T. Wrecks: Clawd in a T. rex suit, olive-brown and mottled, with a thick tail out behind, a huge boxy head on a
/// short neck (yellow eye under a heavy brow, a row of teeth), two comically tiny arms, and Clawd's face peering out of
/// the chest window. He bites: the head lunges and the jaws snap open and shut. Signature: he throws his head up and
/// roars, while the "WHEN DINOSAURS RULED THE EARTH" banner flutters down in front of him and lands on the ground.
private func drawTWrecks(_ c: PixelCanvas, _ p: Pose) {
    let hide = C(0x6E6444), hideD = C(0x4A422E), belly = C(0xA8986C), throat = C(0x9A8A60)
    let claw = C(0xE8DEC4), tooth = C(0xF4EEDC), gum = C(0x7A2A2A), eye = C(0xE8B830)
    let sig = p.signature
    let roar = sig.map { ramp($0, 0.05, 0.18) - ramp($0, 0.86, 0.97) } ?? 0
    let open = roar > 0 ? roar : jawOpen(p.melee)
    let lunge = p.melee != nil ? Int((3 * open).rounded()) : 0
    let rear = Int((roar * 3).rounded())

    dinoLegs(c, step: p.step, hide, claw)
    c.oy += p.breathe
    tail(c, root: 19, tip: 2, rootY: 31, tipY: 27, half: 4, sway: sin(p.lt * 1.6) * 1.5, hide, hideD)
    // The suit's body: mottled back, pale belly, the chest window.
    c.rect(18, 26, 20, 12, hide); c.rect(18, 35, 20, 2, belly); c.rect(18, 37, 20, 1, hideD); c.rect(37, 26, 1, 9, hideD)
    for x in stride(from: 19, through: 34, by: 5) { c.rect(x, 26, 2, 1, hideD); c.px(x + 2, 34, hideD) }
    faceWindow(c, rim: hideD)
    // The tiny arms, two claws each.
    c.rect(37, 29, 3, 1, hide); c.px(39, 30, hide); c.px(40, 30, claw); c.px(40, 31, claw)

    // The neck, stretching as the head goes up.
    c.ox += lunge
    c.rect(22, 18 - rear, 14, 9 + rear, hide)
    c.rect(34, 20 - rear, 2, 7 + rear, hideD)
    c.oy -= rear
    // The head: the upper jaw, then the lower one dropped open by `o`.
    let o = Int((5 * open).rounded())
    c.rect(36, 17, 17, o + 2, gum)
    c.pattern(24, 9, [
        "......dHHHHHHHHHd.............",
        "....dHHHHHHHHHHHHHHd..........",
        "...HHHHHHHHddddHHHHHHd........",
        "..HHHHHHHHHdYKdHHHHHHHHHd.....",
        "..HHHHHHHHHHddHHHHHHHHHHHHHd..",
        ".HHHHHHHHHHHHHHHHHHHHHHHHHHHHn",
        ".HHHHHHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHmmmmmmmmmmmmmmmmmm",
        "HHHHHHHHHHHHT.T.T.T.T.T.T.T.T.",
    ], ["H": hide, "d": hideD, "Y": eye, "K": ink, "n": ink, "m": hideD, "T": tooth])
    c.pattern(24, 18 + o, [
        "HHHHHHHHHHHH.T.T.T.T.T.T.T.T",
        "HHHHHHHHHHHHHHHHHHHHHHHHHHHH",
        ".HHHHHHHHHHHLLLLLLLLLLLLLLd.",
        "...HHHHHHHHH................",
    ], ["H": hide, "d": hideD, "L": throat, "T": tooth])
    if roar > 0.5 {
        // The roar, rolling out of the open jaws.
        let ring = Int(p.t * 6) % 3
        for i in 0..<3 {
            let col = C(0xF2ECDC, i == ring ? 0.9 : 0.4)
            let x = 55 + i * 3
            c.rect(x, 15 + i - o / 2, 1, 4 + o - i, col)
        }
    }
    c.oy += rear
    c.ox -= lunge

    // The banner, fluttering down in front of him and landing in a heap.
    if let s = sig, s > 0.12 {
        let fall = ramp(s, 0.12, 0.8)
        let calm = ramp(s, 0.65, 0.8)
        let top = 6.0 + fall * 35

        let rows = calm >= 1 ? 2 : 5
        let lean = 0.2 * (1 - calm)
        for i in 0..<26 {
            let x = 40 + i
            let wave = sin(Double(i) * 0.45 + p.t * 7) * 1.5 * (1 - calm)
            let y = Int((top + wave + Double(i) * lean).rounded()) - rows + 2
            c.px(x, y, C(0xB83A2A))
            for r in 1..<rows { c.px(x, y + r, C(0xE8D8B0)) }
            if rows == 5 && i > 1 && i < 24 && i % 4 != 3 { c.px(x, y + 2 + (i % 2), C(0x3A2A20)) }
            c.px(x, y + rows, C(0xB83A2A))
        }
    }
}

// MARK: - Clever Girl

/// Clever Girl: Clawd in a velociraptor suit, tan with dark brown stripes over the back and down the long stiff tail,
/// a narrow snouted head up on an S of a neck with a cold yellow eye, dark claws on her feet, and Clawd's
/// face in the chest window. She slashes with the claws of her hand. Signature: a door appears in front of her; she
/// reaches out, works the lever handle down, and the door creaks open.
private func drawCleverGirl(_ c: PixelCanvas, _ p: Pose) {
    let tan = C(0xC09A62), tanD = C(0x8E6C40), stripe = C(0x5E3E22), belly = C(0xE0C898)
    let claw = C(0x2E2218), tooth = C(0xF4EEDC), gum = C(0x7A2A2A), eye = C(0xE8C030)
    let sig = p.signature
    let door = sig.map { ramp($0, 0.0, 0.08) - ramp($0, 0.92, 1.0) } ?? 0
    let reach = sig.map { ramp($0, 0.1, 0.32) - ramp($0, 0.82, 0.92) } ?? 0
    let press = sig.map { ramp($0, 0.36, 0.5) } ?? 0
    let swing = sig.map { ramp($0, 0.5, 0.82) } ?? 0
    let open = jawOpen(p.melee)

    dinoLegs(c, step: p.step, tan, claw)
    c.oy += p.breathe
    tail(c, root: 19, tip: 1, rootY: 29.5, tipY: 27, half: 2.6, sway: sin(p.lt * 2.2) * 1.2, tan, tanD, stripe: stripe)
    // The body: stripes over the back, a pale belly, the chest window.
    c.rect(18, 26, 20, 12, tan); c.rect(18, 35, 20, 2, belly); c.rect(18, 37, 20, 1, tanD); c.rect(37, 26, 1, 9, tanD)
    for x in stride(from: 19, through: 35, by: 4) { c.rect(x, 26, 2, 1, stripe); c.px(x + 1, 34, stripe) }
    faceWindow(c, rim: tanD)

    // The neck curving up from the front of the body, and the head.
    let lean = Int((reach * 2).rounded())
    c.ox += lean
    c.rect(30, 22, 8, 5, tan); c.rect(33, 19, 6, 4, tan); c.rect(31, 22, 1, 4, stripe); c.rect(35, 20, 1, 2, stripe)
    let o = Int((3 * open).rounded())
    c.rect(41, 19, 8, o + 1, gum)
    c.pattern(33, 14, [
        "...dTTTTd........",
        ".TTTTTTTTTTd.....",
        "TTTTdYKTTTTTTTd..",
        "TTsTTTTTTTTTTTTTn",
        "TTsTTTTTmmmmmmmmm",
        "TTTTTTTTT.T.T.T..",
    ], ["T": tan, "d": tanD, "Y": eye, "K": ink, "n": ink, "m": tanD, "s": stripe])
    c.pattern(33, 20 + o, [
        "TTTTTTTTT.T.T.T",
        ".TTTTTLLLLLLLd.",
    ], ["T": tan, "d": tanD, "L": belly])
    for x in stride(from: 42, through: 48, by: 2) { c.px(x, 19, tooth); c.px(x + 1, 20 + o, tooth) }
    c.ox -= lean

    // The door: its frame and edge, swinging open at the end.
    if door > 0 {
        let wood = C(0xC8C0AC, door), woodD = C(0x8A8474, door), lever = C(0xD8DCE2, door)
        let gap = Int((swing * 5).rounded())
        if gap > 0 { c.rect(56, 10, gap, 34, C(0x0E0E12, door)) }
        c.rect(56 + gap, 10, 6, 34, wood); c.rect(56 + gap, 10, 1, 34, woodD)
        c.rect(62, 8, 3, 36, woodD)
        let drop = press * 3
        cbLine(c, Double(57 + gap), 27, Double(52 + gap), 27 + drop, lever, 0.7)
        c.rect(56 + gap, 26, 2, 3, lever)
    }
    // Her hand: reaching for the handle, slashing, or held up in front with the claws hanging.
    let shoulder = (x: 38.5, y: 30.5)
    if reach > 0 {
        let target = (x: 53.0 + swing * 5, y: 26.0 + press * 3)
        let hx = shoulder.x + (target.x - shoulder.x) * reach, hy = shoulder.y + (target.y - shoulder.y) * reach
        cbLine(c, shoulder.x, shoulder.y, hx, hy, tan, 1.0)
        c.px(Int(hx.rounded()), Int(hy.rounded()) - 1, claw); c.px(Int(hx.rounded()) + 1, Int(hy.rounded()), claw)
    } else if let a = p.melee, !p.walking {
        cbSmear(c, shoulder, p.trail, from: 3, to: 9, C(0xF0E8D8))
        cbBar(c, shoulder, a, from: 0, to: 6, tan, r: 1.0)
        for d in [-35.0, 0, 35] {
            let q = cbReach(cbReach(shoulder, a, 6), a + d, 2.5)
            c.px(Int(q.x.rounded()), Int(q.y.rounded()), claw)
        }
    } else {
        c.rect(38, 30, 3, 2, tan); c.px(41, 31, claw); c.px(41, 32, claw); c.px(40, 32, claw)
    }
}

// MARK: - Spitter

/// Spitter: Clawd in a dilophosaurus suit, yellow-green with dark spots, a small head with two red crests running back
/// over it, the frill folded flat behind the jaw, and Clawd's face in the chest window. It spits dark brown venom, the
/// yellow-and-red frill flaring out as it does. Signature: it fans the frill right out and rattles it, head shaking.
private func drawSpitter(_ c: PixelCanvas, _ p: Pose) {
    let hide = C(0x9AA84A), hideD = C(0x6A7830), spot = C(0x46562A), belly = C(0xD8D890)
    let crest = C(0xD8502A), frillY = C(0xF0C830), frillR = C(0xD83A20), frillD = C(0x6A2A1A)
    let tooth = C(0xF4EEDC), gum = C(0x7A2A2A), eye = C(0x2A2018)
    let sig = p.signature
    let fanSig = sig.map { ramp($0, 0.05, 0.25) - ramp($0, 0.85, 0.98) } ?? 0
    let fanFire: Double = p.fire != nil ? 0.75 : (p.ready ? 0.5 : 0)
    let fan = max(fanSig, fanFire)
    let rattle = fanSig > 0.9 ? (Int(p.t * 22) % 2 == 0 ? 1 : -1) : 0

    dinoLegs(c, step: p.step, hide, hideD)
    c.oy += p.breathe
    tail(c, root: 19, tip: 4, rootY: 31, tipY: 29, half: 2.8, sway: sin(p.lt * 2) * 1.5, hide, hideD)
    c.rect(18, 26, 20, 12, hide); c.rect(18, 35, 20, 2, belly); c.rect(18, 37, 20, 1, hideD); c.rect(37, 26, 1, 9, hideD)
    for (x, y) in [(20, 26), (26, 26), (31, 26), (35, 34), (24, 34), (29, 35)] { c.px(x, y, spot); c.px(x + 1, y, spot) }
    faceWindow(c, rim: hideD)
    c.rect(38, 30, 2, 2, hide); c.px(40, 31, hideD)

    // The neck, and the frill round it: folded flat, or fanned out in a ring.
    c.rect(31, 21, 7, 6, hide); c.rect(33, 19, 5, 3, hide)
    let head = (x: 37 + rattle, y: 15 + p.gunY)
    if fan > 0.05 {
        let r = Int((3 + 6 * fan).rounded())
        let cx = 37 + rattle, cy = 21 + p.gunY
        c.ellipse(cx, cy, r + 1, r + 1, frillR)
        c.ellipse(cx, cy, r, r, frillY)
        if r > 4 {
            for k in 0..<8 {
                let ang = Double(k) * .pi / 4 + 0.3
                let dx = cos(ang) * Double(r - 2), dy = sin(ang) * Double(r - 2)
                c.px(cx + Int(dx.rounded()), cy + Int(dy.rounded()), frillD)
            }
            c.ellipse(cx, cy, 2, 2, frillR)
        }
    } else {
        c.rect(33, 19 + p.gunY, 6, 3, hide)
        c.pattern(33, 18 + p.gunY, ["RYR", "YRY", "RYR", ".YR"], ["R": frillR, "Y": frillY])
    }
    if fan > 0.05 { c.rect(33, 19 + p.gunY, 6, 3, hide) }
    // The head: two crests along the top, the jaw dropping as it spits.
    let o = p.fire != nil ? 1 + p.recoil * 2 : 0
    c.rect(head.x + 4, head.y + 4, 6, o + 1, gum)
    c.pattern(head.x - 1, head.y - 2, [
        "..CCCCCC.....",
        ".C.CCCCCC....",
        "HHHHHHHHH....",
        "HHHYYHHHHHH..",
        "HHHHHHHHHHHHn",
        "HHHHHmmmmmmmm",
        "HHHHHT.T.T...",
    ], ["H": hide, "C": crest, "Y": eye, "n": ink, "m": hideD, "T": tooth])
    c.pattern(head.x - 1, head.y + 5 + o, [
        "HHHHHHHHHHH.",
        ".HHHLLLLLd..",
    ], ["H": hide, "L": belly, "d": hideD])
}

// MARK: - Dennis Nerdry

/// Dennis Nerdry: Clawd heavy-set, his belly bulging out at both sides, in a loud blue Hawaiian shirt with pink and
/// yellow flowers under an open yellow raincoat, round glasses and a mop of dark curls. He throws sticks ("Fetch!"),
/// and keeps one in his hand. Signature: he raises a finger and wags it, side to side.
private func drawDennisNerdry(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0xF0C420), coatD = C(0xC09410), shirt = C(0x2E8EC8), flower = C(0xF06A9A), petal = C(0xFFF0F4)
    let leaf = C(0x3AA060), hair = C(0x2E2018), hairL = C(0x4A3426), stick = C(0x8A6438), glass = C(0x1E1E24)
    let sig = p.signature
    let wagging = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false

    drawLegs(c, Look(leg: C(0x4A4A50)), step: p.step)
    cbBoots(c, step: p.step, C(0x2A2420), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: coat, eye: nil))
    // The belly, wider than the body, in the loud shirt; the raincoat open over it, its hem over the tops of the legs.
    c.rect(16, 33, 24, 6, shirt)
    for (x, y) in [(18, 34), (23, 36), (28, 34), (33, 36), (37, 34), (20, 37)] {
        c.px(x, y, flower); c.px(x + 1, y, petal); c.px(x, y + 1, petal); c.px(x + 1, y + 1, leaf)
    }
    c.rect(16, 32, 5, 8, coat); c.rect(35, 32, 5, 8, coat)
    c.rect(20, 32, 1, 8, coatD); c.rect(35, 32, 1, 8, coatD); c.rect(16, 39, 5, 1, coatD); c.rect(35, 39, 5, 1, coatD)
    c.rect(21, 32, 3, 2, coatD); c.rect(32, 32, 3, 2, coatD)   // the collar
    // His face: round glasses and the curls.
    c.rect(21, 28, 5, 5, glass); c.rect(30, 28, 5, 5, glass); c.rect(26, 29, 4, 1, glass)
    c.rect(22, 29, 3, 3, C(0xBCD8E8)); c.rect(31, 29, 3, 3, C(0xBCD8E8))
    c.rect(23, 30, 1, 2, ink); c.rect(32, 30, 1, 2, ink)
    c.pattern(17, 21, [
        "...HhHHhHHhHHhHHh...",
        ".HHHHHHHHHHHHHHHHHH.",
        "HHhHHHhHHHHhHHHhHHHH",
        "HHHHHHHHHHHHHHHHHHHH",
        "HH.H..H...H...H..HHH",
        "H..................H",
    ], ["H": hair, "h": hairL])
    c.rect(13, 33, 4, 3, coat)

    if wagging {
        // The arm up, one finger raised and wagging.
        let w = sin(p.t * 14) > 0 ? 1 : -1
        c.rect(38, 28, 3, 6, coat); c.rect(38, 24, 3, 4, clawdOrange)
        c.rect(39, 22, 1, 2, clawdOrange); c.px(39 + w, 21, clawdOrange); c.px(39 + w * 2, 20, clawdOrange)
        return
    }
    if p.fire != nil {
        // The throwing arm out in front, the stick just gone.
        c.rect(38, 30 + p.gunY / 2, 5, 3, coat); c.rect(42, 29 + p.gunY / 2, 3, 3, clawdOrange)
        return
    }
    if p.ready {
        // A stick held up, waved at you.
        c.rect(38, 29, 3, 5, coat); c.rect(38, 27, 3, 3, clawdOrange)
        cbLine(c, 37.5, 23, 42.5, 29, stick, 0.6)
        return
    }
    // At rest: the stick in his hand, pointing down.
    c.rect(38, 33, 3, 3, coat); c.rect(39, 36, 3, 2, clawdOrange)
    cbLine(c, 41, 37, 44, 42, stick, 0.6)
}

// MARK: - Indominous Rex

/// The Indominous Rex: Clawd in a huge white rex suit, bigger than T. Wrecks in every way: a hump of a back with dark
/// quills along it, grey stripes, a long head with horny ridges over a red eye, long arms with three hooked claws,
/// and Clawd's face in the chest window. She slashes with the claws and bites. Signature: camouflage. She fades out
/// until only a faint shimmer and the red eye are left, then fades back in.
private func drawIndominusRex(_ c: PixelCanvas, _ p: Pose) {
    let fade = p.signature.map { ramp($0, 0.08, 0.32) - ramp($0, 0.7, 0.92) } ?? 0
    guard fade > 0 else { indominusSuit(c, p); return }
    let layer = PixelCanvas(c.w, c.h)
    indominusSuit(layer, p)
    c.paste(layer, alpha: 1 - 0.9 * fade)
    // The eye stays, glinting.
    c.oy += p.breathe
    c.px(34, 8, C(0xE83020, 0.4 + 0.5 * fade))
    c.oy -= p.breathe
}

/// The Indominous Rex's suit, drawn at full strength (the signature fades it as a whole).
private func indominusSuit(_ c: PixelCanvas, _ p: Pose) {
    let hide = C(0xE8E8E2), hideD = C(0xA8ACA8), stripe = C(0x7A7E80), throat = C(0xD0D0C8)
    let claw = C(0x2E3032), quill = C(0x5A5E62), tooth = C(0xFFFFF4), gum = C(0x6A1E22), eye = C(0xE83020)
    let open = jawOpen(p.melee)
    let lunge = p.melee != nil ? Int((3 * open).rounded()) : 0

    dinoLegs(c, step: p.step, hide, claw)
    c.oy += p.breathe
    tail(c, root: 19, tip: 1, rootY: 29, tipY: 22, half: 4.5, sway: sin(p.lt * 1.4) * 2, hide, hideD, stripe: stripe)
    // The hump of a back with its quills, the body, and the chest window.
    c.rect(14, 21, 18, 6, hide); c.rect(15, 20, 14, 1, hide)
    for x in stride(from: 15, through: 27, by: 3) { c.px(x, 19, quill); c.px(x + 1, 18, quill); c.px(x + 1, 19, quill) }
    for x in stride(from: 16, through: 28, by: 4) { c.rect(x, 21, 1, 3, stripe) }
    c.rect(18, 26, 20, 12, hide); c.rect(18, 35, 20, 2, throat); c.rect(18, 37, 20, 1, hideD); c.rect(37, 26, 1, 9, hideD)
    faceWindow(c, rim: hideD)

    // The neck and the long head, lunging as she bites.
    c.ox += lunge
    c.rect(25, 15, 10, 12, hide); c.rect(33, 17, 2, 9, hideD)
    let o = Int((5 * open).rounded())
    c.rect(22, 13, 13, o + 2, hide)
    c.rect(35, 13, 21, o + 2, gum)
    c.pattern(22, 4, [
        "........dHHHHHHHHHHd..............",
        "......dHHHHHqHHqHHHHHd............",
        "....dHHHHHHqqqqqqHHHHHHd..........",
        "...HHHHHHHHddddddHHHHHHHHHd.......",
        "..HHHHHHHHHHdRKdHHHHHHHHHHHHd.....",
        "..HHHHHHHHHHHddHHHHHHHHHHHHHHHd...",
        ".HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHd.",
        ".HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHn",
        "HHHHHHHHHHHHHmmmmmmmmmmmmmmmmmmmmm",
        "HHHHHHHHHHHHHT.T.T.T.T.T.T.T.T.T.T",
    ], ["H": hide, "d": hideD, "q": quill, "R": eye, "K": ink, "n": ink, "m": hideD, "T": tooth])
    c.pattern(22, 14 + o, [
        "HHHHHHHHHHHHH.T.T.T.T.T.T.T.T.T.",
        "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH",
        ".HHHHHHHHHHHHLLLLLLLLLLLLLLLLLd.",
        "...HHHHHHHHHH...................",
    ], ["H": hide, "d": hideD, "L": throat, "T": tooth])
    c.ox -= lunge

    // The long arms: slashing, or held out in front with the claws hooked.
    let shoulder = (x: 37.5, y: 29.5)
    let a = p.melee ?? 55
    if p.melee != nil { cbSmear(c, shoulder, p.trail, from: 4, to: 11, C(0xF0F0EA)) }
    cbBar(c, shoulder, a, from: 0, to: 8, hide, r: 1.1)
    let hand = cbReach(shoulder, a, 8)
    for d in [-40.0, 0, 40] {
        let q = cbReach(hand, a + d, 2.5)
        c.px(Int(q.x.rounded()), Int(q.y.rounded()), claw)
    }
}

// MARK: - Donald Gennarrow

/// Donald Gennarrow: Clawd as the park's lawyer, in a grey suit, white shirt and red tie, his dark hair gone from the
/// top, a briefcase in his hand. He doesn't fight. Signature: he panics. A wooden toilet hut appears beside him, he
/// bolts into it and slams the door, the hut quivers while he hides (two eyes peeping out of the crescent-moon window),
/// then he creeps back out.
private func drawGennarrow(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x7A808A), suitD = C(0x5A606A), shirt = C(0xF4F4F0), tie = C(0xA82A2A)
    let hair = C(0x3A2A20), leather = C(0x6A4428), leatherD = C(0x4A2E1A)
    let sig = p.signature
    let hut = sig.map { ramp($0, 0.0, 0.1) - ramp($0, 0.92, 1.0) } ?? 0
    let out = sig.map { ramp($0, 0.12, 0.4) - ramp($0, 0.8, 0.94) } ?? 0      // how far he's run
    let hidden = sig.map { $0 >= 0.4 && $0 < 0.8 } ?? false
    let peeping = sig.map { $0 > 0.6 && $0 < 0.78 } ?? false

    if hut > 0 {
        // The toilet hut: plank walls, a pitched roof, a door with a crescent moon cut in it.
        let wood = C(0x9A7448, hut), woodD = C(0x6A4E2E, hut), roof = C(0x5A4A3A, hut)
        let shake = hidden && !peeping ? (Int(p.t * 18) % 2) : 0
        let hx = 44 + shake
        c.rect(hx, 18, 20, 26, wood)
        for x in stride(from: hx + 2, through: hx + 18, by: 3) { c.rect(x, 18, 1, 26, woodD) }
        c.pattern(hx - 2, 12, [
            "..........RR..........",
            "......RRRRRRRRRR......",
            "..RRRRRRRRRRRRRRRRRR..",
            "RRRRRRRRRRRRRRRRRRRRRR",
            "RRRRRRRRRRRRRRRRRRRRRR",
            "......................",
        ], ["R": roof])
        let doorOpen = !hidden && out > 0.6
        if doorOpen {
            c.rect(hx + 4, 21, 12, 23, C(0x16120E, hut))
        } else {
            c.rect(hx + 4, 21, 12, 23, C(0xA88252, hut)); c.rect(hx + 4, 21, 12, 1, woodD); c.rect(hx + 15, 21, 1, 23, woodD)
            c.pattern(hx + 8, 24, [".MM.", "MM..", "MM..", ".MM."], ["M": C(0x16120E, hut)])
            c.px(hx + 6, 33, C(0xD8C8A0, hut))
            if peeping { c.px(hx + 9, 25, white); c.px(hx + 9, 26, white) }
        }
    }
    if hidden { return }

    let dx = Int((out * 16).rounded())
    c.ox += dx
    let step = out > 0 && out < 1 ? Int(p.t * 12) % 2 : p.step
    drawLegs(c, Look(leg: suitD), step: step)
    drawDressShoes(c, step: step)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit, eye: nil))
    c.rect(18, 34, 20, 4, suit); c.rect(37, 34, 1, 4, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(25, 34, ["dSSSSd", ".dSSd.", "..TT..", "..TT.."], ["d": suitD, "S": shirt, "T": tie])
    c.rect(23, 34, 1, 3, suitD); c.rect(32, 34, 1, 3, suitD)
    // His face: wide eyes when he runs, and hair only round the back and sides.
    if sig != nil && out > 0 {
        c.rect(22, 28, 2, 4, white); c.rect(32, 28, 2, 4, white); c.rect(23, 29, 1, 2, ink); c.rect(33, 29, 1, 2, ink)
        c.px(36, 27, C(0x9AD0F0)); c.px(36, 28, C(0x9AD0F0))
    } else {
        c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    }
    c.pattern(18, 26, [
        "HHH...............HH",
        "HHH................H",
        "HH.................H",
        "HH..................",
        "H...................",
    ], ["H": hair])
    c.px(27, 27, C(0xF0A080)); c.px(28, 27, C(0xF0A080))   // the shine on his bald top
    // The briefcase: held at his side, or clutched to his chest as he runs.
    if sig != nil && out > 0 {
        c.rect(36, 30, 6, 5, leather); c.rect(36, 34, 6, 1, leatherD); c.rect(38, 29, 2, 1, leatherD)
    } else {
        c.rect(38, 33, 3, 3, suit)
        c.rect(38, 37, 7, 5, leather); c.rect(38, 41, 7, 1, leatherD); c.rect(40, 36, 3, 1, leatherD)
        c.px(41, 39, C(0xD8B850))
    }
    c.ox -= dx
}

// MARK: - Dr. Woo

/// Dr. Woo: Clawd as the park's geneticist, a long white lab coat (down over the tops of his legs) open over a navy
/// shirt and tie, an ID badge on the pocket, neat black hair with a side parting, and a clipboard. He doesn't fight.
/// Signature: he holds up a vial of amber DNA to the light, a little double helix glinting inside, and turns it.
private func drawDrWoo(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0xF2F4F6), coatD = C(0xC4CAD2), shirt = C(0x2A3A5A), tie = C(0x8A9AB8), hair = C(0x16161C)
    let board = C(0xA88458), paper = C(0xF8F6EE)
    let sig = p.signature
    let showing = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: C(0x3A3A44)), step: p.step)
    drawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: coat))
    // The lab coat, open over the shirt and tie, its tails over the tops of the legs; the badge.
    c.rect(18, 34, 20, 6, coat); c.rect(37, 34, 1, 6, coatD); c.rect(18, 39, 20, 1, coatD)
    c.rect(24, 34, 8, 4, shirt); c.rect(27, 34, 2, 4, tie)
    c.rect(23, 34, 1, 6, coatD); c.rect(32, 34, 1, 6, coatD)
    c.rect(34, 35, 2, 2, C(0x3A7AC8)); c.px(34, 35, white)
    // Neat black hair, parted on the left.
    c.pattern(17, 22, [
        "....HHHHHHHHHHHHHH..",
        "..HHHHH.HHHHHHHHHHH.",
        ".HHHHH.HHHHHHHHHHHHH",
        "HHHH..............HH",
        "HH.................H",
    ], ["H": hair])
    c.rect(15, 33, 3, 3, coat)

    if showing {
        // The vial held up at eye level, turned in the light.
        let k = sig!
        let y = 30 - Int((ramp(k, 0.06, 0.2) * 7).rounded())
        c.rect(38, y + 3, 3, 33 - y, coat); c.rect(38, y + 2, 3, 2, clawdOrange)
        c.rect(40, y - 5, 3, 1, C(0x5A5A66))
        c.rect(40, y - 4, 3, 7, C(0xDCEAF0, 0.85))
        c.rect(40, y - 1, 3, 4, C(0xE8A030))
        let turn = Int(p.t * 4) % 3
        c.px(40 + turn, y - 1, C(0xFFF2B0)); c.px(42 - turn, y + 1, C(0xFFF2B0))
        if Int(p.t * 3) % 4 == 0 { c.px(43, y - 4, white); c.px(44, y - 5, C(0xFFFFFF, 0.6)) }
        return
    }
    // The clipboard under his arm.
    c.rect(38, 33, 3, 3, coat)
    c.rect(39, 30, 6, 8, board); c.rect(40, 31, 4, 6, paper); c.rect(41, 30, 2, 1, C(0x8A8A90))
    for y in [32, 34, 36] { c.rect(40, y, 3, 1, C(0x8A8A96)) }
}
