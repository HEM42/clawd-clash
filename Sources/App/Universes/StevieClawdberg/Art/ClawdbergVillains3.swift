import Foundation

// Villains: Gremlins. The gremlins are Clawd in green scaly gremlin suits, the same blocky body on its four legs with
// huge pointed ears, red eyes and a toothy grin, each told apart by its tell (a white mohawk tuft, a fin, glasses and
// a tie, leathery wings, a crackling outline, lipstick, wide eyes). Mrs. Deegle and Dr. Clawtheter are Clawd in
// costume, orange face showing.

let clawdbergVillains3: [ClawdbergVillain: Persona] = [
    .strype: Persona(name: "Strype", weapon: .blaster, shot: .bullet, muzzle: (49, 31), headTop: 17, signature: 2.8,
                     draw: drawStrype),
    .mohawk: Persona(name: "Mohawk", weapon: .saber, bulk: 2, headTop: 15, signature: 4.0, draw: drawMohawk),
    .theBrain: Persona(name: "The Brain", headTop: 22, signature: 3.6, draw: drawTheBrain),
    .batGremlin: Persona(name: "The Bat Gremlin", weapon: .saber, motion: .fly, canSit: false, headTop: 16,
                         signature: 3.0, draw: drawBatGremlin),
    .electricGremlin: Persona(name: "The Electric Gremlin", weapon: .lightning, motion: .hover,
                              magic: Magic(core: C(0xF6FBFF), glow: C(0x7FC8FF)), canSit: false, pivot: (42, 33),
                              headTop: 21, signature: 3.4, draw: drawElectricGremlin),
    .greta: Persona(name: "Greta", headTop: 22, signature: 2.8, draw: drawGreta),
    .daffy: Persona(name: "Daffy", weapon: .saber, headTop: 22, signature: 2.8, draw: drawDaffy),
    .mrsDeegle: Persona(name: "Mrs. Deegle", headTop: 17, signature: 3.0, draw: drawMrsDeegle),
    .drClawtheter: Persona(name: "Dr. Clawtheter", headTop: 20, signature: 3.2, draw: drawDrClawtheter),
]

// MARK: - The gremlin suit

/// A gremlin suit's colours: its hide, the darker mottling and scales, highlights, and its paler belly.
private struct Hide {
    let skin: Px, dark: Px, light: Px, belly: Px
}

private let gremlinHide = Hide(skin: C(0x4E8A3A), dark: C(0x2E5A22), light: C(0x7AB050), belly: C(0xA4B878))
private let gremEyeRed = C(0xE8261A), gremEyeHot = C(0xFF9A6A), gremMouth = C(0x3A0E0E), gremTooth = C(0xF4F0DC)
private let gremEarPink = C(0xB86A5A), gremClaw = C(0xE8E0C8)

/// A gremlin's legs (clawed toes), the breath, and the suit over Clawd's body: mottled scaly hide, a paler belly, and
/// the huge pointed ears out to either side (`earLift` raises their tips). The face is left to `gremFace`.
private func gremBody(_ c: PixelCanvas, _ p: Pose, _ h: Hide, earLift: Int = 0) {
    drawLegs(c, Look(leg: h.skin), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            let y = lifted ? 42 : 43
            c.px(lx - 1, y, h.dark); c.px(lx + 2, y, h.dark)
        }
    }
    c.oy += p.breathe
    drawBody(c, Look(body: h.skin, shade: h.dark, arm: h.skin, eye: nil))
    // The hide lit in runs along the top, then its scales in short strokes that follow the shape.
    for (x, w) in [(19, 3), (24, 4), (30, 3)] { c.rect(x, 26, w, 1, h.light) }
    for (x, w) in [(21, 2), (27, 3), (33, 2)] { c.rect(x, 27, w, 1, h.dark) }
    for (x, y) in [(19, 29), (36, 30), (19, 33), (36, 34)] { c.rect(x, y, 1, 2, h.dark) }
    c.rect(19, 36, 3, 1, h.dark); c.rect(33, 36, 3, 1, h.dark)
    c.rect(23, 35, 10, 2, h.belly)
    gremEars(c, h, lift: earLift)
}

/// The huge pointed ears, out to either side of the head, pink inside.
private func gremEars(_ c: PixelCanvas, _ h: Hide, lift: Int) {
    let left = [
        "E.........",
        "EEE.......",
        ".EEEE.....",
        ".EEpEEE...",
        "..EEppEEEE",
        "...EEppEEE",
        "....EEEEEE",
        ".......EEE",
    ]
    c.pattern(8, 22 - lift, left, ["E": h.skin, "p": gremEarPink])
    c.pattern(38, 22 - lift, left.map { String($0.reversed()) }, ["E": h.skin, "p": gremEarPink])
    if lift > 0 {   // the ears' roots, filled in down to the head
        c.rect(15, 29 - lift, 3, lift, h.skin); c.rect(38, 29 - lift, 3, lift, h.skin)
    }
}

/// A gremlin's face: heavy brows, red eyes, two nostrils and a toothy grin (`open`: a cackling open mouth).
private func gremFace(_ c: PixelCanvas, _ h: Hide, eyes: Bool = true, grin: Bool = true, open: Bool = false) {
    if eyes {
        c.rect(21, 28, 5, 1, h.dark); c.rect(31, 28, 5, 1, h.dark)
        c.px(25, 29, h.dark); c.px(31, 29, h.dark)
        c.rect(22, 29, 3, 2, gremEyeRed); c.rect(32, 29, 3, 2, gremEyeRed)
        c.px(22, 29, gremEyeHot); c.px(32, 29, gremEyeHot)
        c.px(24, 30, ink); c.px(34, 30, ink)
    }
    c.px(27, 31, h.dark); c.px(29, 31, h.dark)
    guard grin else { return }
    if open {
        c.pattern(21, 32, [
            "MMMMMMMMMMMMMM",
            "MWMWMWMWMWMWWM",
            "MRRRRRRRRRRRRM",
            "MRRRRRRRRRRRRM",
            ".MWMWMWMWMWMM.",
        ], ["M": gremMouth, "W": gremTooth, "R": C(0x8A1A1A)])
    } else {
        c.pattern(21, 32, [
            "M............M",
            "MWMWMWMWMWMWMM",
            ".MMMMMMMMMMMM.",
        ], ["M": gremMouth, "W": gremTooth])
    }
}

/// A clawed swipe: the arm out along `p.melee` with three hooked claws, a smear behind a fast one; at rest the arm by
/// its side with its claws showing.
private func gremClaws(_ c: PixelCanvas, _ p: Pose, _ h: Hide, reach len: Double = 4) {
    guard let a = p.melee else {
        c.rect(38, 33, 3, 3, h.skin); c.px(41, 34, gremClaw); c.px(41, 36, gremClaw)
        return
    }
    cbSmear(c, cbHand, p.trail, from: 3, to: len + 4, C(0xE8F0D8))
    cbBar(c, cbHand, a, from: -2, to: len, h.skin, r: 1.3)
    let tip = cbReach(cbHand, a, len)
    for d in [-30.0, 0, 30] {
        cbBar(c, tip, a + d, from: 0.8, to: 3.2, gremClaw, r: 0.5)
    }
}

// MARK: - Strype

/// Strype: the gremlin suit with the white mohawk tuft sticking up off his head, the ringleader's sneer. He fights
/// with a revolver. Signature: he throws his head back and cackles, mouth wide open, his tuft bobbing.
private func drawStrype(_ c: PixelCanvas, _ p: Pose) {
    let h = gremlinHide, steel = C(0x9AA0AA), steelD = C(0x5A6068), wood = C(0x6A4428)
    let sig = p.signature
    let cackling = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false
    if cackling { c.ox += Int(p.t * 18) % 2 }

    gremBody(c, p, h)
    gremFace(c, h, open: cackling)
    // The white mohawk tuft, bobbing as he laughs.
    let bob = cackling ? (sin(p.t * 16) > 0 ? -1 : 1) : 0
    c.pattern(20, 17 + bob, [
        "W............",
        "WW....W......",
        ".WWW..WW..W..",
        "..WWWWWWWWWW.",
        "...WWwWWwWWWW",
        "....WWWWWWWW.",
        "......WWWWW..",
        ".......WWW...",
        ".......WW....",
    ], ["W": C(0xF4F4EE), "w": C(0xC8C8C0)])
    if cackling {
        // The laugh, bursting out of him.
        let f = frac(p.t * 1.5)
        for i in 0..<2 {
            let x = 40 + i * 4, y = 24 - Int(f * 6) - i * 2
            c.rect(x, y, 1, 3, C(0xF4F4EE, 1 - f)); c.rect(x + 2, y, 1, 3, C(0xF4F4EE, 1 - f))
            c.px(x + 1, y + 1, C(0xF4F4EE, 1 - f))
        }
    }
    if p.fire != nil || p.ready || p.gunLift > 0 {
        // The revolver aimed: grip, cylinder, barrel.
        let y = 31 + p.gunY
        c.rect(38, y, 3, 3, h.skin)
        c.rect(41, y, 8, 1, steel); c.rect(42, y - 1, 3, 3, steelD); c.rect(41, y + 1, 2, 2, wood)
        c.px(48, y - 1, steel)
        return
    }
    // The revolver hanging from his hand, barrel down.
    c.rect(38, 33, 3, 3, h.skin)
    c.rect(40, 35, 2, 2, wood); c.rect(41, 36, 1, 5, steel); c.rect(40, 37, 3, 2, steelD)
}

// MARK: - Mohawk

/// Mohawk: the meanest gremlin of the Clamp Centre, a darker, browner suit bulked out wide at the shoulders, a tall
/// spiny purple fin of a mohawk from brow to nape, and big hooked claws he fights with. Signature: he gulps down the
/// spider serum from a vial, shudders, and long hairy spider legs burst out of his sides (his own four stay planted),
/// then draw back in.
private func drawMohawk(_ c: PixelCanvas, _ p: Pose) {
    let h = Hide(skin: C(0x5A6E34), dark: C(0x34421C), light: C(0x86964E), belly: C(0xA8A070))
    let fin = C(0x4A2A4A), finL = C(0x8A4A7A), spider = C(0x2E2018), spiderL = C(0x6A4A2E)
    let sig = p.signature ?? -1
    let gulping = sig > 0.05 && sig < 0.32
    let shudder = sig >= 0.32 && sig < 0.46
    // How far the spider legs are out: 0 none, 1 fully.
    let grow: Double = sig < 0.46 ? 0 : sig < 0.6 ? (sig - 0.46) / 0.14 : sig < 0.86 ? 1 : max(0, (0.96 - sig) / 0.1)
    if shudder { c.ox += Int(p.t * 30) % 2 == 0 ? 1 : -1 }

    if grow > 0 {
        // The spider legs: three a side, up to a knee and down to the ground.
        let g = grow
        for i in 0..<3 {
            let fi = Double(i)
            let y0 = 29 + fi * 3
            let kneeX = 17 - (5 + fi * 2) * g, kneeY = y0 - (6 - fi) * g
            let footX = 17 - (9 + fi * 3) * g, footY = y0 + (14 - fi * 3) * g
            cbLine(c, 18, y0, kneeX, kneeY, spider, 0.7); cbLine(c, kneeX, kneeY, footX, footY, spider, 0.6)
            c.px(Int(kneeX.rounded()), Int(kneeY.rounded()), spiderL)
            let rKneeX = 39 + (5 + fi * 2) * g, rFootX = 39 + (9 + fi * 3) * g
            cbLine(c, 38, y0, rKneeX, kneeY, spider, 0.7); cbLine(c, rKneeX, kneeY, rFootX, footY, spider, 0.6)
            c.px(Int(rKneeX.rounded()), Int(kneeY.rounded()), spiderL)
        }
    }
    gremBody(c, p, h)
    // Bulked out: broad shoulders over the body's edges.
    c.rect(16, 27, 2, 9, h.skin); c.rect(38, 27, 2, 8, h.dark); c.rect(18, 25, 20, 1, h.skin)
    c.rect(16, 30, 1, 2, h.dark); c.rect(17, 33, 1, 2, h.dark)     // scales on the broad shoulder
    gremFace(c, h, open: shudder)
    // The fin of a mohawk, spines and all.
    c.pattern(18, 15, [
        "F.....F.....F.......",
        "FF....FF....FF......",
        ".FF....FF....FF.....",
        ".FFF...FFF...FFF..F.",
        "..FFF...FFF...FFF.FF",
        "..FFFF..FFFF..FFFFF.",
        "...FFFFFfFFFFfFFFFF.",
        "...FFfFFFFFFFFFfFFF.",
        "....FFFFFFFFFFFFFF..",
        "....ffffffffffffff..",
        "....ffffffffffffff..",
    ], ["F": fin, "f": finL])

    if gulping {
        // The serum vial tipped up at his mouth, green and glowing.
        let k = (sig - 0.05) / 0.27
        c.rect(36, 30, 3, 4, h.skin)
        c.rect(33, 27, 3, 6, C(0xD8E8E0, 0.8)); c.rect(33, 27 + Int(k * 4), 3, 6 - Int(k * 4), C(0x6AF04A))
        c.rect(33, 26, 3, 1, C(0x6A4A2A))
        return
    }
    gremClaws(c, p, h, reach: 5)
}

// MARK: - The Brain

/// The Brain: the gremlin suit at its most civilised, round black-rimmed glasses over his red eyes, a narrow smug
/// grin, a white shirt collar and a red tie under a grey jacket. He doesn't fight; he talks. Signature: he conducts
/// the gremlins' big song-and-dance number, baton up and beating time, notes rising round him.
private func drawTheBrain(_ c: PixelCanvas, _ p: Pose) {
    let h = Hide(skin: C(0x5A8E3E), dark: C(0x34602A), light: C(0x80B05A), belly: C(0xA4B878))
    let jacket = C(0x6A6A74), jacketD = C(0x4A4A54), shirt = C(0xF2F0E8), tie = C(0xB02030), frame = C(0x16161B)
    let sig = p.signature
    let conducting = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false

    gremBody(c, p, h)
    // The jacket, collar and tie.
    c.rect(18, 34, 20, 4, jacket); c.rect(37, 34, 1, 4, jacketD)
    c.pattern(23, 34, ["SSSSSSSSSS", ".SSSSTSSS.", "..SSSTSS..", "...SSTS..."], ["S": shirt, "T": tie])
    c.px(28, 34, tie)
    gremFace(c, h, grin: false)
    // A narrow smug grin.
    c.pattern(23, 32, ["M........M", ".MWMWMWMM."], ["M": gremMouth, "W": gremTooth])
    // The glasses: round black rims and a bridge.
    c.pattern(20, 27, [
        ".KKKKK....KKKKK.",
        "K.....K..K.....K",
        "K.....KKKK.....K",
        ".KKKKK....KKKKK.",
    ], ["K": frame])
    c.rect(21, 28, 5, 2, C(0xC8E4F0, 0.25)); c.rect(31, 28, 5, 2, C(0xC8E4F0, 0.25))

    if conducting {
        // Both arms up, the baton beating time, the notes rising.
        let beat = sin(p.t * 9)
        let a = -60 + beat * 30
        c.rect(14, 28 + Int((beat * 2).rounded()), 3, 3, jacket)
        c.rect(38, 26, 3, 8, jacket); c.rect(40, 24, 3, 3, h.skin)
        cbBar(c, (42, 24.5), a, from: 0, to: 10, white, r: 0.5)
        let f = frac(p.t * 0.8)
        for i in 0..<3 {
            let ff = frac(f + Double(i) / 3)
            let x = 50 + i * 5 - Int(ff * 3), y = 24 - Int(ff * 14)
            let col = C(0xF4F4EE, 1 - ff * 0.6)
            c.rect(x, y, 1, 3, col); c.px(x - 1, y + 2, col); c.px(x + 1, y, col)
        }
        return
    }
    c.rect(38, 33, 3, 3, jacket); c.rect(15, 33, 3, 3, jacket)
}

// MARK: - The Bat Gremlin

/// The Bat Gremlin: a greyer gremlin suit with big leathery bat wings off its back, bony fingers through a brown
/// membrane, half folded at its back on the ground and beating in flight; its ears taller still. It fights with its claws.
/// Signature: it spreads its wings and swoops round in a loop.
private func drawBatGremlin(_ c: PixelCanvas, _ p: Pose) {
    let h = Hide(skin: C(0x5E7046), dark: C(0x384428), light: C(0x86966A), belly: C(0x9AA07A))
    let membrane = C(0x6A4434), membraneD = C(0x4A2E24), bone = C(0x2A1C14)
    let sig = p.signature
    let looping = sig.map { $0 > 0.04 && $0 < 0.96 } ?? false
    if let k = sig, looping {
        let th = (k - 0.04) / 0.92 * 2 * .pi
        // Forward, up and over, and back down into place: the loop swings forward so the wings stay in the frame.
        c.ox += Int((sin(th) * 3 + (1 - cos(th)) * 3).rounded())
        c.oy += Int((-(1 - cos(th)) * 7).rounded())
    }
    let spread = p.flying || looping
    let flap = spread ? sin(p.t * 14) : 0

    // The wings, behind it: the far one darker, then the near one.
    for (w, col) in [(1, membraneD), (0, membrane)] {
        let wd = Double(w)
        let sx = 21.0 + wd * 5, sy = 28.0 + Double(p.breathe)
        let root = (x: sx - 1, y: sy + 6)
        // The arm bone up to the wrist, then three long fingers fanning out from it.
        let elbowA: Double = spread ? -140 + flap * 15 - wd * 10 : -150 - wd * 12
        let elbowL: Double = spread ? 9 : 8
        let wrist = cbReach((sx, sy), elbowA, elbowL)
        let fingerA: [Double] = spread ? [-165, 160, 125] : [-178, 145, 112]
        let fingerL: [Double] = spread ? [10, 11, 9] : [9, 10, 8]
        var tips: [(x: Double, y: Double)] = []
        for i in 0..<3 { tips.append(cbReach(wrist, fingerA[i] + (spread ? flap * 9 : 0), fingerL[i])) }
        // The membrane, scalloped between the fingertips, down to its root on the body.
        let edge = tips + [root]
        for seg in 0..<3 {
            let a = edge[seg], b = edge[seg + 1]
            for s in 0...8 {
                let f = Double(s) / 8
                let pull = sin(f * .pi) * 0.28
                let mx0 = a.x + (b.x - a.x) * f, my0 = a.y + (b.y - a.y) * f
                let mx = mx0 + (wrist.x - mx0) * pull, my = my0 + (wrist.y - my0) * pull
                cbLine(c, wrist.x, wrist.y, mx, my, col, 1.0)
            }
        }
        cbLine(c, sx, sy, wrist.x, wrist.y, col, 1.2)
        cbLine(c, root.x, root.y, wrist.x, wrist.y, col, 1.2)
        cbLine(c, sx, sy, wrist.x, wrist.y, bone, 0.6)
        for tip in tips { cbLine(c, wrist.x, wrist.y, tip.x, tip.y, bone, 0.4) }
        c.px(Int(wrist.x.rounded()), Int(wrist.y.rounded()) - 1, gremClaw)
    }
    gremBody(c, p, h, earLift: 2)
    gremFace(c, h, open: looping)
    gremClaws(c, p, h)
}

// MARK: - The Electric Gremlin

/// The Electric Gremlin: a gremlin made of electricity, the suit gone pale crackling blue with white-hot eyes and a
/// jagged blue-white outline flickering all round it, sparks jumping off; it hovers and throws forked lightning.
/// Signature: it flickers out into a phone line, zips up the cable and along the wire as a spark, and flickers back.
private func drawElectricGremlin(_ c: PixelCanvas, _ p: Pose) {
    let h = Hide(skin: C(0x3E86C8), dark: C(0x1E4E8A), light: C(0xA8DCFF), belly: C(0x7EC0F0))
    let arc = C(0xF6FBFF), arcB = C(0x7FC8FF), wire = C(0x8A8A94)
    let sig = p.signature ?? -1
    let tick = Int(p.t * 20)

    if sig > 0.04 && sig < 0.96 {
        // The phone line: a wire across the top and a cable down to it.
        c.rect(0, 9, 72, 1, wire); c.rect(44, 10, 1, 16, wire); c.rect(43, 26, 3, 2, C(0x5A5A64))
        // The spark: up the cable, along the wire and back, then down.
        let k = sig
        if k > 0.28 && k < 0.72 {
            let f = (k - 0.28) / 0.44
            var sx = 44.0, sy = 9.0
            if f < 0.2 { sy = 26 - f / 0.2 * 17 }
            else if f < 0.8 { sx = 44 + sin((f - 0.2) / 0.6 * 2 * .pi) * 24 }
            else { sy = 9 + (f - 0.8) / 0.2 * 17 }
            c.glowLine(sx, sy, sx, sy, core: arc, glow: arcB, coreR: 1, glowR: 3)
            c.px(Int(sx) + Int(noise(tick) * 5) - 2, Int(sy) + Int(noise(tick + 1) * 5) - 2, arc)
        }
        // Flickering out, gone, flickering back.
        let show: Bool
        if k < 0.3 { show = noise(tick) > (k - 0.04) / 0.26 * 0.6 }
        else if k < 0.7 { show = false }
        else { show = noise(tick) < 0.4 + (k - 0.7) / 0.26 * 0.6 }
        guard show else { return }
    }

    gremBody(c, p, h)
    // White-hot eyes and a crackling grin.
    c.rect(21, 28, 5, 1, h.dark); c.rect(31, 28, 5, 1, h.dark)
    c.rect(22, 29, 3, 2, white); c.rect(32, 29, 3, 2, white)
    c.glowLine(23, 30, 23, 30, core: white, glow: arcB, coreR: 0.5, glowR: 2)
    c.glowLine(33, 30, 33, 30, core: white, glow: arcB, coreR: 0.5, glowR: 2)
    c.pattern(21, 32, ["M............M", "MWMWMWMWMWMWMM", ".MMMMMMMMMMMM."], ["M": C(0x1A4A8A), "W": white])
    // The casting hand, raised.
    c.rect(38, 33 - p.armRaise, 3, 3, h.skin)

    // The crackling outline: round the body and ears, flickering.
    var edge: [(Int, Int)] = []
    for x in 17...38 { edge.append((x, 25)); edge.append((x, 38)) }
    for y in 26...37 { edge.append((17, y)); edge.append((38, y)) }
    for x in 8...16 { edge.append((x, 21 + (x - 8) / 2)); edge.append((x + 32, 29 - (x - 8) / 2)) }
    for (i, e) in edge.enumerated() {
        let n = noise(tick * 97 + i)
        if n > 0.45 { c.px(e.0, e.1, n > 0.8 ? arc : arcB.alpha(0.9)) }
    }
    // Sparks jumping off it.
    for s in 0..<2 {
        let e = edge[Int(noise(tick * 13 + s) * Double(edge.count)) % edge.count]
        let dx = Double(e.0) - 28, dy = Double(e.1) - 31
        let len = max(1, sqrt(dx * dx + dy * dy))
        let mx = Double(e.0) + dx / len * 2 + (noise(tick + s * 7) - 0.5) * 3
        let my = Double(e.1) + dy / len * 2
        let ex = Double(e.0) + dx / len * 5, ey = Double(e.1) + dy / len * 5
        cbLine(c, Double(e.0), Double(e.1), mx, my, arc, 0.4)
        cbLine(c, mx, my, ex, ey, arcB, 0.4)
    }
}

// MARK: - Greta

/// Greta: the gremlin suit in a paler, yellower green, done up: red lipstick, long lashes, a beauty spot and gold
/// hoop earrings swinging from her ears. She doesn't fight. Signature: she puckers up, kisses her claw and blows the
/// kiss, a little red heart floating away.
private func drawGreta(_ c: PixelCanvas, _ p: Pose) {
    let h = Hide(skin: C(0x74A244), dark: C(0x4A7228), light: C(0x9CC468), belly: C(0xC4CC8A))
    let lips = C(0xE0203A), lipsD = C(0xA0102A), gold = C(0xF0C040)
    let sig = p.signature
    let kissing = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    gremBody(c, p, h)
    gremFace(c, h, grin: false)
    // Lashes and a beauty spot.
    c.px(21, 27, ink); c.px(23, 27, ink); c.px(33, 27, ink); c.px(35, 27, ink)
    c.px(33, 33, ink)
    // The hoop earrings.
    let swing = sin(p.t * 4) > 0 ? 1 : 0
    c.pattern(15 + swing, 29, [".G.", "G.G", "G.G", ".G."], ["G": gold])
    c.pattern(39 + swing, 29, [".G.", "G.G", "G.G", ".G."], ["G": gold])

    let pucker = kissing && sig! < 0.55
    if pucker {
        // Puckered up, her claw at her lips.
        c.pattern(26, 32, [".RR.", "RDDR", ".RR."], ["R": lips, "D": lipsD])
        c.rect(32, 31, 6, 3, h.skin); c.px(31, 32, gremClaw)
    } else {
        // Painted lips round a toothy smile.
        c.pattern(22, 32, [".RRRR..RRRR.", "RRWWWWWWWWRR", ".RRRRRRRRRR."], ["R": lips, "W": gremTooth])
    }
    if kissing && !pucker {
        // The kiss blown: the arm flung out, a heart drifting off.
        let f = (sig! - 0.55) / 0.39
        c.rect(38, 30, 4, 3, h.skin); c.px(42, 30, gremClaw)
        let x = 44 + Int(f * 14), y = 28 - Int(f * 10)
        c.pattern(x, y, ["HH.HH", "HHHHH", ".HHH.", "..H.."], ["H": lips.alpha(1 - f * 0.5)])
        return
    }
    if !pucker { c.rect(38, 33, 3, 3, h.skin) }
}

// MARK: - Daffy

/// Daffy: the gremlin suit, brighter green, with huge goggling white eyes, tiny red pupils rolling round in them,
/// and a gaping grin that never closes. He flails at people with his claws. Signature: a fit of the giggles, arms
/// flailing every which way.
private func drawDaffy(_ c: PixelCanvas, _ p: Pose) {
    let h = Hide(skin: C(0x5CA03A), dark: C(0x386A22), light: C(0x88C45E), belly: C(0xB4CC80))
    let sig = p.signature
    let giggling = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false
    if giggling { c.oy += Int(p.t * 16) % 2 == 0 ? -1 : 0 }

    gremBody(c, p, h, earLift: 1)
    gremFace(c, h, eyes: false, open: true)
    // The goggling eyes, pupils rolling.
    c.rect(20, 27, 5, 5, white); c.rect(31, 27, 5, 5, white)
    c.rect(20, 27, 5, 1, C(0xD8D8D0)); c.rect(31, 27, 5, 1, C(0xD8D8D0))
    let roll = Int(p.t * (giggling ? 9 : 2)) % 4
    let off = [(1, 1), (3, 1), (3, 3), (1, 3)][roll]
    c.px(20 + off.0, 27 + off.1, gremEyeRed); c.px(31 + 4 - off.0, 27 + off.1, gremEyeRed)

    if giggling {
        // Both arms flailing, and the giggles bubbling up.
        let a = sin(p.t * 17), b = sin(p.t * 13 + 1.5)
        let ly = 27 + Int((a * 5).rounded()), ry = 27 + Int((b * 5).rounded())
        c.rect(15, min(ly, 32), 3, abs(32 - ly) + 2, h.skin); c.rect(12, ly - 1, 3, 3, h.skin); c.px(11, ly - 2, gremClaw)
        c.rect(38, min(ry, 32), 3, abs(32 - ry) + 2, h.skin); c.rect(41, ry - 1, 3, 3, h.skin); c.px(44, ry - 2, gremClaw)
        let f = frac(p.t * 2)
        c.px(42 + Int(f * 4), 24 - Int(f * 6), C(0xF4F4EE, 1 - f))
        c.px(45 + Int(f * 3), 26 - Int(f * 8), C(0xF4F4EE, 1 - f))
        c.px(12 - Int(f * 3), 25 - Int(f * 6), C(0xF4F4EE, 1 - f))
        return
    }
    gremClaws(c, p, h)
}

// MARK: - Mrs. Deegle

/// Mrs. Deegle: Clawd as the town's meanest old lady, grey hair scraped up into a tight bun, a sour downturned mouth
/// and pinched brows, a black coat buttoned to the throat down over the tops of her legs, a brooch; two of her cats
/// sit at her feet. She doesn't fight. Signature: her souped-up stair-lift chair whisks under her and launches her
/// sky-high, cartoon-style, and she pops back down into place.
private func drawMrsDeegle(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x1E1E24), coatL = C(0x3A3A44), hair = C(0xB4B4B4), hairD = C(0x8A8A8E), stockings = C(0x5A5A62)
    let sig = p.signature ?? -1
    let lifting = sig > 0.04 && sig < 0.96

    // The cats at her feet (they stay put whatever she does).
    if !seatedPose {
        let ox = c.ox, oy = c.oy
        c.oy -= p.hop
        c.pattern(3, 36, ["G...G.", "GG.GG.", "GyGyG.", "GGGGG.", ".GGG..", ".GGGG.", "GGGGGG", "GGGGGGG"],
                  ["G": C(0xD08A3A), "y": C(0x3A2A1A)])
        c.pattern(9, 37, ["K...K", "KK.KK", "KyKyK", "KKKKK", ".KKK.", "KKKKK", "KKKKKK"],
                  ["K": C(0x4A4A52), "y": C(0xE8D84A)])
        c.ox = ox; c.oy = oy
    }
    // How high the stair-lift has flung her.
    var up = 0.0
    if lifting {
        let k = sig
        if k < 0.18 { up = 0 }
        else if k < 0.45 { up = (k - 0.18) / 0.27 * 15 }
        else if k < 0.6 { up = 15 }
        else if k < 0.78 { up = 15 - (k - 0.6) / 0.18 * 15 }

        else if k < 0.86 { up = sin((k - 0.78) / 0.08 * .pi) * 3 }
        if k > 0.08 {
            // The stair-lift chair, rising up its rail with her.
            let ch = Int((min(up, 8)).rounded())
            c.oy -= p.breathe
            c.rect(14, 38 - ch, 26, 2, C(0x9A8A6A)); c.rect(14, 28 - ch, 3, 10, C(0x9A8A6A))
            c.rect(14, 40 - ch, 2, 4, C(0x6A6A74))
            c.oy += p.breathe
        }
    }
    c.oy -= Int(up.rounded())
    if up > 4 {
        // Speed lines under her as she goes.
        for x in [22, 28, 34] { c.rect(x, 46, 1, 4, C(0xF4F4EE, 0.5)) }
    }

    drawLegs(c, Look(leg: stockings), step: p.step)
    cbBoots(c, step: p.step, C(0x101012), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: coat))
    // The black coat, buttoned to the throat, down over the tops of her legs; a brooch.
    c.rect(18, 33, 20, 7, coat); c.rect(18, 39, 20, 1, coatL); c.rect(18, 33, 20, 1, coatL)
    for y in [35, 37] { c.px(28, y, coatL) }
    c.rect(26, 33, 2, 2, C(0xC8A040))
    // Pinched brows, a sour mouth.
    c.rect(21, 28, 3, 1, hairD); c.rect(32, 28, 3, 1, hairD); c.px(24, 28, hairD); c.px(31, 28, hairD)
    if up > 4 {
        c.rect(26, 31, 4, 2, ink)   // a shriek
    } else {
        c.pattern(25, 32, [".MMMM.", "M....M"], ["M": C(0x5A2A2A)])
    }
    // The grey hair scraped up into a tight bun.
    c.pattern(18, 17, [
        "....oooo............",
        "...oBBBBo...........",
        "...oBbBBo...........",
        "...oBBBBo...........",
        "....oooo............",
        "...HHHHHHHHHHHHH....",
        ".HHhHHHhHHHHhHHHHH..",
        "HHHHHHHHHHHHHHHHHHH.",
        "HHH.........HHHHHHHH",
        "HH...............HHH",
    ], ["B": hair, "b": hairD, "H": hair, "h": hairD, "o": hairD])
    if up > 4 {
        // Arms flung up.
        c.rect(14, 27, 3, 6, coat); c.rect(39, 27, 3, 6, coat)
        return
    }
    c.rect(15, 33, 3, 3, coat); c.rect(38, 33, 3, 3, coat)
}

// MARK: - Dr. Clawtheter

/// Dr. Clawtheter: Clawd as the Clamp Centre's mad geneticist, silver hair swept back, a doctor's head mirror on a
/// band, a long white lab coat (down over the tops of his legs) over a dark tie, coloured serum vials in its breast
/// pocket and black rubber gloves. He doesn't fight. Signature: he holds a glowing serum vial up to the light and
/// gazes up at it, a glint running over the glass.
private func drawDrClawtheter(_ c: PixelCanvas, _ p: Pose) {
    let lab = C(0xF2F2EE), labD = C(0xC8CCD0), hair = C(0xC8CCD4), hairD = C(0x9AA0AA), glove = C(0x1E1E22)
    let mirror = C(0xD8E0EA), serum = C(0x6AF04A)
    let sig = p.signature
    let gazing = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: C(0x3A3A44)), step: p.step)
    cbBoots(c, step: p.step, C(0x16161B), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: lab, eye: gazing ? nil : ink))
    if gazing { c.rect(23, 28, 2, 3, ink); c.rect(33, 28, 2, 3, ink) }   // eyes up at the vial
    // The lab coat, open over a dark tie, down over the tops of his legs; vials in the pocket.
    c.rect(18, 33, 20, 7, lab); c.rect(37, 33, 1, 7, labD); c.rect(18, 39, 20, 1, labD)
    c.rect(26, 33, 4, 5, C(0x3A4A6A)); c.rect(27, 33, 2, 5, C(0x1E1E24))
    c.rect(25, 33, 1, 6, labD); c.rect(30, 33, 1, 6, labD)
    c.rect(20, 35, 4, 2, labD)
    c.px(20, 33, C(0xE04A3A)); c.px(21, 34, serum); c.px(22, 33, C(0x4A8AF0))
    c.px(20, 34, C(0xE04A3A)); c.px(22, 34, C(0x4A8AF0))
    // Silver hair swept back, the head mirror on its band.
    c.pattern(17, 21, [
        "......HHHHHHHHHH......",
        "...HHHHHhHHHHhHHHH....",
        ".HHHHHHHHHHHHHHHHHHHH.",
        "HHhHHHHHHHHHHHHHHHHHHH",
        "HH.....KKKKKKKKKKKK.HH",
        "H...................H.",
    ], ["H": hair, "h": hairD, "K": C(0x2A2A30)])
    c.pattern(30, 20, [".MMM.", "MMwMM", "MMMMM", ".MMM."], ["M": mirror, "w": white])

    if gazing {
        // The vial held high to the light.
        let k = sig!
        let rise = Int((min(1, (k - 0.06) / 0.15) * 6).rounded())
        c.rect(38, 33 - rise, 3, 3 + rise, lab); c.rect(38, 30 - rise, 3, 2, glove)
        c.rect(39, 22 - rise, 3, 8, C(0xE8F4F0, 0.85)); c.rect(39, 25 - rise, 3, 5, serum)
        c.rect(39, 21 - rise, 3, 1, C(0x6A4A2A))
        c.glowLine(40.5, Double(27 - rise), 40.5, Double(27 - rise), core: serum, glow: C(0x6AF04A, 0.5), coreR: 0.5, glowR: 3)
        let g = Int(p.t * 4) % 5
        if g < 3 { c.px(39 + g % 3, 23 - rise + g, white) }
        c.rect(15, 33, 3, 3, lab); c.rect(15, 35, 3, 1, glove)
        return
    }
    c.rect(38, 33, 3, 3, lab); c.rect(38, 35, 3, 1, glove)
    c.rect(15, 33, 3, 3, lab); c.rect(15, 35, 3, 1, glove)
}
