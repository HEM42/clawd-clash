import Foundation

// Villains: E.T., Jaws and Close Encounters. Clawd in costume here too: a jacket and a ring of keys, a quarantine
// suit, an army uniform (never an insignia), a hazmat suit and gas masks over the blocky body; and the shark, which is
// Clawd zipped into a great white costume, fin, tail, jaws and all, still on four legs.

let clawdbergVillains6: [ClawdbergVillain: Persona] = [
    .keyz: Persona(name: "Keyz", weapon: .lightning, magic: Magic(core: C(0xFFF8DC), glow: C(0xF0E080), jagged: false),
                   pivot: (47.5, 33.5), headTop: 21, signature: 3.0, draw: drawKeyz),
    .spacesuitMan: Persona(name: "The Spacesuit Man", weapon: .lightning,
                           magic: Magic(core: C(0xFFF8DC), glow: C(0xF0E080), jagged: false),
                           pivot: (47.5, 33.5), headTop: 19, signature: 3.6, draw: drawSpacesuitMan),
    .bruise: Persona(name: "Bruise the Shark", weapon: .saber, canSit: false, pivot: (44, 31), bulk: 5, headTop: 16,
                     signature: 4.4, callout: "Dun-dun… dun-dun", draw: drawBruise),
    .mayorVaun: Persona(name: "Mayor Vaun", headTop: 21, signature: 3.2, callout: "Amity means friendship",
                        draw: drawMayorVaun),
    .majorMildBill: Persona(name: "Major Mild Bill", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 20,
                            signature: 3.2, draw: drawMajorMildBill),
    .gasMaskTrooper: Persona(name: "The Gas-Mask Trooper", weapon: .blaster,
                             shot: .energy(core: C(0xF0F8B0), glow: C(0xA8C83A)), muzzle: (49, 33), headTop: 20,
                             signature: 3.0, draw: drawGasMaskTrooper),
]

// MARK: - Shared bits

private let torchBody = C(0x26262C)
private let lensLit = C(0xFFF6C8)

/// A flashlight in the right hand: held out level with its lens at (47, `y`…`y + 1`) and lit (`lit`), or hanging
/// down by the side, off.
private func torch(_ c: PixelCanvas, y: Int, sleeve: Px, out: Bool, lit: Bool) {
    if out {
        c.rect(38, y, 3, 3, sleeve)
        c.rect(40, y, 5, 2, torchBody); c.rect(45, y - 1, 2, 4, torchBody); c.px(43, y, C(0x5A5A64))
        c.rect(47, y, 1, 2, lit ? lensLit : C(0x8A8A70))
    } else {
        c.rect(38, 33, 3, 3, sleeve)
        c.rect(39, 35, 2, 5, torchBody); c.rect(38, 40, 4, 2, torchBody); c.rect(39, 42, 2, 1, C(0x8A8A70))
    }
}

/// A flashlight's beam from (x, y) out along `angle` degrees: a pale cone, brighter down the middle.
private func beam(_ c: PixelCanvas, from x: Double, _ y: Double, angle: Double, length: Double = 26) {
    let r = angle * .pi / 180
    let ux = cos(r), uy = sin(r)
    for i in 0..<Int(length) {
        let d = Double(i)
        let half: Double = 0.5 + d * 0.22
        let fade: Double = 1 - d / length
        let cx = x + ux * d, cy = y + uy * d
        let steps = Int(half.rounded())
        for k in -steps...steps {
            let px = cx - uy * Double(k), py = cy + ux * Double(k)
            c.px(Int(px.rounded()), Int(py.rounded()), C(0xFFF0B0, 0.28 * fade))
        }
        c.px(Int(cx.rounded()), Int(cy.rounded()), C(0xFFF8DC, 0.45 * fade))
    }
}

/// A gas mask over the face in `rubber`: two round glass eyepieces where Clawd's eyes are and the filter at the chin.
private func gasMask(_ c: PixelCanvas, rubber: Px, dark: Px, y: Int = 26) {
    let glass = C(0x9AB4BE), glint = C(0xE8F6FA), can = C(0x5A5E52)
    c.pattern(19, y, [
        "..MMMMMMMMMMMMMMM.",
        ".MMMMMMMMMMMMMMMMM",
        "MMdLLdMMMMMMdLLdMM",
        "MMLLLLMMMMMMLLLLMd",
        "MMLwLLMMMMMMLwLLMd",
        "MMdLLdMMMMMMdLLdMd",
        ".MMMMMMMFFFFMMMMd.",
        "..MMMMMFFkkFFMMd..",
        ".......FFFFFF.....",
        "........FFFF......",
    ], ["M": rubber, "d": dark, "L": glass, "w": glint, "F": can, "k": C(0x2A2C26)])
}

/// A puff of gas: soft round blobs of yellow-green, each `alpha` strong.
private func puff(_ c: PixelCanvas, _ x: Double, _ y: Double, r: Double, alpha: Double) {
    let n = Int(r.rounded(.up))
    for dy in -n...n {
        for dx in -n...n {
            let d2 = Double(dx * dx + dy * dy)
            guard d2 <= r * r else { continue }
            c.px(Int(x.rounded()) + dx, Int(y.rounded()) + dy, C(0xC8E05A, alpha * (d2 < r * r * 0.4 ? 1 : 0.6)))
        }
    }
}

// MARK: - Keyz

/// Keyz: Clawd as the government man who hunts E.Clawd, in a dark navy jacket and grey trousers, greying hair and a
/// level stare, a great ring of keys hanging off his belt. He fights with a flashlight, its steady pale yellow beam.
/// Signature: the key ring swings and jingles at his hip, the keys glinting as they knock together.
private func drawKeyz(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x22283A), jacketD = C(0x161A28), jacketL = C(0x3A4258), trousers = C(0x5A5E66)
    let hair = C(0x5A4E44), hairG = C(0x9A948C), hairL = C(0x7A6E62), steel = C(0xC8CCD4), brass = C(0xC8A848)
    let sig = p.signature
    let casting = p.zap != nil || p.armRaise > 0

    drawLegs(c, Look(leg: trousers), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x141418), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: jacket, eye: nil))
    // A level stare under a straight brow.
    c.rect(21, 28, 4, 1, C(0x8A4A34)); c.rect(31, 28, 4, 1, C(0x8A4A34))
    c.rect(22, 29, 2, 2, ink); c.rect(32, 29, 2, 2, ink)
    // The jacket, zipped, a belt under it.
    c.rect(18, 33, 20, 4, jacket); c.rect(37, 33, 1, 4, jacketD)
    c.rect(28, 33, 1, 4, jacketL); c.rect(24, 33, 9, 1, jacketL)
    c.rect(18, 37, 20, 1, C(0x1A1410)); c.px(28, 37, brass)
    // Neat hair, lit along the top and greying at the temples.
    c.pattern(17, 21, [
        "....LLLLLHHHHHHH.....",
        "..HHHHHHHHHHHHHHHH...",
        ".HHHHHHHHHHHHHHHHHH..",
        ".gHHHHHHHHHHHHHHHHHg.",
        ".gHHHHHHHHHHHHHHHHHg.",
        ".gg...............gg.",
    ], ["H": hair, "g": hairG, "L": hairL])
    // The key ring at his right hip, still or swinging.
    var swing: Double = 0
    if let s = sig, s > 0.04, s < 0.96 {
        let env: Double = sin((s - 0.04) / 0.92 * .pi)
        swing = sin(p.t * 9) * 40 * env
    }
    let ra = (90 - swing) * .pi / 180
    let rx = 34 + cos(ra) * 3.5, ry = 37 + sin(ra) * 3.5
    for k in 0..<12 {
        let a = Double(k) / 12 * 2 * .pi
        c.px(Int((rx + cos(a) * 2).rounded()), Int((ry + sin(a) * 2).rounded()), steel)
    }
    for (i, off) in [-35.0, 0, 35].enumerated() {
        let ka = (90 - swing * 1.3 + off) * .pi / 180
        let kx = rx + cos(ka) * 2, ky = ry + sin(ka) * 2
        let ex = rx + cos(ka) * 5, ey = ry + sin(ka) * 5
        clawdbergLine(c, kx, ky, ex, ey, i == 1 ? brass : steel, 0.5)
    }
    c.px(34, 37, steel)
    if abs(swing) > 20 {
        let gx = Int(rx.rounded()) + (swing > 0 ? 4 : -4)
        c.px(gx, Int(ry.rounded()) + 2, white); c.px(gx + 1, Int(ry.rounded()) + 1, C(0xFFFFFF, 0.6))
    }

    torch(c, y: 33 - p.armRaise, sleeve: jacket, out: casting, lit: casting)
}

// MARK: - The Spacesuit Man

/// The Spacesuit Man: Clawd sealed in a white quarantine suit, a rounded helmet with a wide tinted visor that shows
/// his face behind the glass, grey gloves and boots, an air hose running from the pack on his back. He fights with a
/// flashlight's steady pale yellow beam. Signature: he searches the dark, sweeping the flashlight slowly from side to
/// side.
private func drawSpacesuitMan(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0xEEF0F2), suitD = C(0xC4C8D0), suitL = C(0xFFFFFF), glove = C(0x8A8E96), hose = C(0xA8ACB4)
    let sig = p.signature
    let casting = p.zap != nil || p.armRaise > 0

    drawLegs(c, Look(leg: suit), step: p.step)
    clawdbergBoots(c, step: p.step, glove, height: 3)
    c.oy += p.breathe
    // The air pack on his back, and its hose looping down.
    c.rect(13, 27, 5, 9, suitD); c.rect(13, 27, 5, 1, suit)
    clawdbergLine(c, 14, 36, 12, 40, hose, 0.6); clawdbergLine(c, 12, 40, 16, 42, hose, 0.6)
    drawBody(c, Look(body: suit, shade: suitD, arm: suit, eye: ink))
    // The helmet: a rounded white dome, a collar ring, the visor over his face with Clawd behind the glass.
    c.pattern(17, 19, [
        ".....SSSSSSSSSS.....",
        "...SSSSSSSSSSSSSSS..",
        "..SSSSlSSSSSSSSSSSSd",
        ".SSSSSSSSSSSSSSSSSSd",
        ".SSSSSSSSSSSSSSSSSSd",
        "SSSSSSSSSSSSSSSSSSSd",
        "SSSSSSSSSSSSSSSSSSSd",
        "SS...............SSd",
    ], ["S": suit, "l": suitL, "d": suitD])
    c.rect(19, 27, 1, 6, suit)
    c.rect(20, 27, 16, 6, clawdOrange)
    c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    c.rect(20, 27, 16, 6, C(0x2A3A4A, 0.45))
    c.rect(20, 26, 16, 1, suitD); c.rect(20, 33, 16, 1, suitD)
    c.px(33, 27, C(0xFFFFFF, 0.7)); c.px(34, 28, C(0xFFFFFF, 0.5)); c.px(35, 27, C(0xFFFFFF, 0.5))
    c.rect(36, 26, 2, 8, suit); c.rect(37, 26, 1, 8, suitD)
    // The suit's zip and seams.
    c.rect(27, 34, 1, 4, suitD); c.rect(18, 36, 20, 1, suitD)
    c.rect(15, 35, 3, 1, glove)

    if let s = sig, s > 0.04, s < 0.96 {
        // Sweeping the flashlight slowly across the dark.
        let k = (s - 0.04) / 0.92
        let angle: Double = -35 + 50 * (0.5 - 0.5 * cos(k * 2 * .pi * 1.5))
        let y = 32 + Int((angle / 25).rounded())
        torch(c, y: y, sleeve: suit, out: true, lit: true)
        beam(c, from: 48, Double(y) + 0.5, angle: angle)
        return
    }
    torch(c, y: 33 - p.armRaise, sleeve: suit, out: casting, lit: casting)
    if casting { c.rect(39, 35 - p.armRaise, 2, 1, glove) } else { c.rect(38, 35, 3, 1, glove) }
}

// MARK: - Bruise the Shark

/// Bruise the Shark: Clawd zipped into a great white costume, the same block on four legs but dark grey on top and
/// white underneath, a tall dorsal fin, a crescent tail behind, a side fin, and a pointed snout over a mouthful of
/// teeth. He glides low and never sits. He fights with his jaws, gaping wide on the wind-up and snapping shut on the
/// strike. Signature: in the water up to his belly, only his back and fin showing, he circles one way and then the
/// other; then he heaves up out of it with his jaws wide open.
private func drawBruise(_ c: PixelCanvas, _ p: Pose) {
    let grey = C(0x7A8896), greyD = C(0x56626E), greyL = C(0x98A6B2), belly = C(0xE8ECEE), bellyD = C(0xC4CCD2)
    let maw = C(0x3A0E14), gum = C(0x9A2A34), tooth = C(0xFAFAF4)
    let sig = p.signature
    let circling: Double = sig.map { s in s > 0.03 && s < 0.6 ? (s - 0.03) / 0.57 : -1 } ?? -1
    let surfacing: Double = sig.map { s in s >= 0.6 && s < 0.97 ? (s - 0.6) / 0.37 : -1 } ?? -1
    let inWater = circling >= 0 || surfacing >= 0

    var open = 0
    if let a = p.melee {
        let o: Double = min(1, max(0, (-a - 10) / 80))
        open = Int((o * 4).rounded())
    } else if p.ready || p.cheering {
        open = 2
    }
    var sway = 0, sink = 2
    if circling >= 0 {
        sway = Int((sin(circling * 2 * .pi * 1.5) * 6).rounded())
        sink = 4
    }
    if surfacing >= 0 {
        let r: Double = sin(surfacing * .pi)
        open = Int((r * 6).rounded())
        sink = 4 - Int((r * 7).rounded())
    }
    let ox = c.ox, oy = c.oy

    c.ox += sway
    drawLegs(c, Look(leg: greyD), step: p.step)
    c.oy += p.breathe + sink
    // The tail, its upper lobe tall; a little flick to it.
    let flick = p.walking ? (p.step == 0 ? -1 : 1) : (sin(p.lt * 3) > 0.6 ? 1 : 0)
    c.pattern(7, 19 + flick, [
        "G.........",
        "GG........",
        ".GG.......",
        ".GGG......",
        "..GGG.....",
        "..GGGG....",
        "...GGGG...",
        "...GGGGG..",
        "....GGGGGG",
        "....GGGGGG",
        "....GGGGGG",
        "...GGGGGGG",
        "..GGGG....",
        ".GGG......",
        "GGG.......",
    ], ["G": greyD])
    // The body: grey back, white belly with a ragged line between.
    c.rect(18, 26, 20, 12, grey); c.rect(18, 26, 20, 1, greyD); c.rect(19, 27, 14, 1, greyL)
    c.rect(18, 33, 20, 5, belly); c.rect(18, 37, 20, 1, bellyD)
    for x in stride(from: 18, to: 38, by: 3) { c.px(x, 32, belly); c.px(x + 1, 33, grey) }
    // The side fin.
    c.pattern(24, 32, ["GGGGGG", ".GGGGG", "..GGGG", "...GGG", "....GG"], ["G": greyD])
    // The dorsal fin.
    c.pattern(24, 16, [
        "GG.........",
        "GGG........",
        "GGGG.......",
        ".GGGG......",
        ".GGGGG.....",
        "..GGGGG....",
        "..GGGGGG...",
        "..GGGGGGG..",
        "..GGGGGGGG.",
        ".GGGGGGGGGG",
    ], ["G": grey])
    c.rect(24, 16, 1, 3, greyL)
    // Clawd's eyes, and the gill slits behind the jaw.
    c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    for x in [27, 29] { c.rect(x, 28, 1, 3, greyD) }
    // The snout, out over the jaws.
    c.pattern(38, 26, [
        "GGGG.....",
        "GGGGGG...",
        "GGGGGGGG.",
        "GGGGGGGGG",
        "GGGGGGGG.",
        "GGGGGGG..",
    ], ["G": grey])
    c.px(43, 28, greyD)
    // The mouth: a toothy line when shut, gaping open to the gums when not.
    if open > 0 {
        c.rect(33, 32, 12, open, maw)
        c.rect(33, 32, 12, 1, gum)
        for x in stride(from: 34, to: 45, by: 2) { c.px(x, 32, tooth); c.px(x, 33, tooth) }
        c.rect(33, 32 + open, 11, 1, gum)
        for x in stride(from: 35, to: 44, by: 2) { c.px(x, 31 + open, tooth); c.px(x, 32 + open, tooth) }
        c.pattern(37, 33 + open, ["WWWWWW", "WWWWW.", "WWWW.."], ["W": belly])
    } else {
        c.rect(33, 32, 11, 1, maw)
        for x in stride(from: 34, to: 44, by: 2) { c.px(x, 32, tooth) }
        c.pattern(38, 33, ["WWWWW", "WWWW.", "WWW.."], ["W": belly])
    }
    if !p.trail.isEmpty, open == 0 {   // the snap
        c.px(47, 30, C(0xFFFFFF, 0.8)); c.px(48, 32, C(0xFFFFFF, 0.8)); c.px(47, 34, C(0xFFFFFF, 0.8))
    }

    guard inWater else { c.ox = ox; c.oy = oy; return }
    // The water he's in, up to his belly, rippling.
    c.ox = ox; c.oy = oy
    for x in 2..<70 {
        let wave: Double = sin(Double(x) * 0.55 + p.t * 5)
        let top = 35 + (wave > 0.3 ? 0 : 1)
        c.rect(x, top, 1, 6, C(0x2A6A9A, 0.72))
        c.px(x, top, C(0xD8ECF8, wave > 0.7 ? 0.9 : 0.5))
    }
    if surfacing >= 0 {
        for i in 0..<6 {   // spray
            let x = 26 + i * 4 + Int(noise(i + Int(p.t * 6)) * 3) + sway
            let y = 33 - Int(sin(surfacing * .pi) * Double(2 + i % 3) * 2)
            c.px(x, y, C(0xE8F4FF, 0.85))
        }
    }
}

// MARK: - Mayor Vaun

/// Mayor Vaun: Clawd as the mayor in his cream blazer printed all over with little navy anchors, a white shirt and a
/// maroon tie, grey trousers, slicked dark hair and a big toothy grin. He doesn't fight. Signature: he waves everyone
/// into the water, his arm sweeping out towards the waves, grinning harder than ever.
private func drawMayorVaun(_ c: PixelCanvas, _ p: Pose) {
    let blazer = C(0xE6DEC6), blazerD = C(0xBEB496), anchor = C(0x2A3A6A), shirt = C(0xF6F4EE), tie = C(0x8A2A3A)
    let slacks = C(0x6A6A70), hair = C(0x2E2622), hairL = C(0x4A3E36)
    let sig = p.signature

    drawLegs(c, Look(leg: slacks), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x3A2418), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: blazer))
    // The grin.
    c.rect(24, 31, 8, 1, white); c.rect(25, 32, 6, 1, C(0xE0DCD4)); c.px(23, 30, C(0xA85A40)); c.px(32, 30, C(0xA85A40))
    // The blazer over the shirt and tie, anchors all over it.
    c.rect(18, 33, 20, 5, blazer); c.rect(37, 33, 1, 5, blazerD); c.rect(18, 37, 20, 1, blazerD)
    c.pattern(25, 33, ["SSSSSS", ".STTS.", "..TT..", "..TT.."], ["S": shirt, "T": tie])
    c.rect(24, 33, 1, 4, blazerD); c.rect(31, 33, 1, 4, blazerD)
    for (x, y) in [(19, 34), (33, 34), (21, 36)] {
        c.pattern(x, y, [".a.", "aaa", "a.a"], ["a": anchor])
    }
    c.px(16, 34, anchor); c.px(39, 34, anchor)
    // Slicked dark hair, a side parting.
    c.pattern(17, 21, [
        ".....HHHHHHHHHHH.....",
        "...HHHHHHlllHHHHHH...",
        "..HHHHHHHHHHlllHHHHH.",
        ".HHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH",
        ".HH...............HH.",
    ], ["H": hair, "l": hairL])

    if let s = sig, s > 0.04, s < 0.96 {
        // Waving them in: the arm sweeping out and up, over and over; the waves lapping in front of him.
        let k = (s - 0.04) / 0.92
        let a: Double = -55 + 60 * (0.5 + 0.5 * sin(k * 2 * .pi * 3))
        let h: (x: Double, y: Double) = (39, 33.5)
        let e = clawdbergReach(h, a, 6)
        clawdbergLine(c, h.x - 1, h.y, e.x, e.y, blazer, 1.2)
        c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 3, 3, clawdOrange)
        c.rect(23, 31, 10, 2, white); c.rect(24, 32, 8, 1, C(0xE0DCD4))
        for x in 46..<70 {
            let wave: Double = sin(Double(x) * 0.7 + p.t * 4)
            c.px(x, 43, C(0x3A8AC8, 0.8)); if wave > 0.4 { c.px(x, 42, C(0xD8F0FF, 0.9)) }
        }
        return
    }
    c.rect(38, 33, 3, 3, blazer)
}

// MARK: - Major Mild Bill

/// Major Mild Bill: Clawd as the army officer in charge at the mountain, in olive service dress with a brown belt,
/// a peaked olive cap with a black visor and a plain brass cord (no badge), a gas-mask bag at his left hip. He
/// fights with a pistol. Signature: he pulls the gas mask up out of its bag and on over his face.
private func drawMajorMildBill(_ c: PixelCanvas, _ p: Pose) {
    let olive = C(0x5C6242), oliveD = C(0x434830), oliveL = C(0x767C58), belt = C(0x5A3E26), brass = C(0xC8A848)
    let mask = C(0x4E5446), maskD = C(0x363A30), bag = C(0x6A6E58)
    let sig = p.signature
    let lifting: Double = sig.map { s in s > 0.04 && s < 0.32 ? (s - 0.04) / 0.28 : -1 } ?? -1
    let masked = sig.map { $0 >= 0.32 && $0 < 0.96 } ?? false

    drawLegs(c, Look(leg: olive), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x2A1E16), height: 3)
    c.oy += p.breathe
    // The mask bag at his left hip.
    c.rect(13, 34, 5, 5, bag); c.rect(13, 34, 5, 1, oliveD); c.px(15, 36, brass)
    drawBody(c, Look(arm: olive, eye: nil))
    c.rect(21, 28, 4, 1, C(0x8A4A34)); c.rect(31, 28, 4, 1, C(0x8A4A34))
    c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    c.rect(26, 32, 4, 1, C(0xA85A40))
    // The tunic: collar, pockets, belt and buckle.
    c.rect(18, 33, 20, 5, olive); c.rect(37, 33, 1, 5, oliveD); c.rect(18, 37, 20, 1, oliveD)
    c.pattern(24, 33, ["LLssLL", ".LssL."], ["L": oliveL, "s": C(0xD8D0B8)])
    c.rect(20, 34, 3, 2, oliveD); c.rect(33, 34, 3, 2, oliveD)
    c.rect(18, 36, 20, 1, belt); c.px(27, 36, brass); c.px(28, 36, brass)
    // The peaked cap: a wide crown, the band with its brass cord, and the black visor.
    c.pattern(16, 20, [
        "..CCCCCCCCCCCCCCCCC.....",
        ".CCCCCCCCCCCCCCCCCCC....",
        "CCCCCCCCCCCCCCCCCCCCC...",
        ".CCCCCCCCCCCCCCCCCCC....",
        ".bbbbbbbbbbbbbbbbbbb....",
        "..BBBBBBBBBBBBBBkkkkkkkk",
    ], ["C": olive, "B": oliveD, "b": brass, "k": C(0x141416)])

    if lifting >= 0 || masked {
        if lifting >= 0 {
            // The mask out of the bag and up to his face in his left hand.
            let y = 36 - Int((lifting * 8).rounded())
            c.rect(15, y, 3, 37 - y, olive)
            c.pattern(15, y - 4, [".MMM.", "MLMLM", "MMMMM", ".MFM."],
                      ["M": mask, "L": C(0x9AB4BE), "F": C(0x5A5E52)])
        } else if masked {
            gasMask(c, rubber: mask, dark: maskD)
            c.rect(15, 33, 3, 3, olive)
        }
        c.rect(38, 33, 3, 3, olive); c.rect(39, 36, 3, 2, C(0x24242A))
        return
    }
    // The pistol.
    c.oy += p.gunY
    c.rect(38, 33, 3, 3, olive)
    c.pattern(40, 31, ["KKKKKKK", "KKGKK..", "KK.....", "KK....."], ["K": C(0x24242A), "G": C(0x5E626C)])
}

// MARK: - The Gas-Mask Trooper

/// The Gas-Mask Trooper: Clawd in a dull yellow-olive hazmat suit with its hood up, a black rubber gas mask over his
/// face, rubber gloves and boots, a gas tank on his back. He fights with sleeping gas, puffs of yellow-green from the
/// sprayer wand on its hose. Signature: he lifts the wand and lets off a great billowing puff of gas.
private func drawGasMaskTrooper(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0xB4AA5A), suitD = C(0x8A8040), suitL = C(0xCCC276), rubber = C(0x1E2022), rubberD = C(0x0E0F10)
    let tank = C(0x5A6048), tankD = C(0x3E4430), metal = C(0x8A8E96), hose = C(0x2A2C2E)
    let sig = p.signature

    drawLegs(c, Look(leg: suit), step: p.step)
    clawdbergBoots(c, step: p.step, rubber, height: 3)
    c.oy += p.breathe
    // The tank on his back.
    c.pattern(11, 25, [".TTTT.", "TTTTTT", "TtTTTT", "TtTTTT", "TtTTTT", "TtTTTT", "TtTTTT", "TTTTTT", "DDDDDD", ".DDDD."],
              ["T": tank, "t": C(0x767C60), "D": tankD])
    c.rect(13, 23, 2, 2, metal)
    drawBody(c, Look(body: suit, shade: suitD, arm: suit, eye: nil))
    // The hood, close round the mask, and the mask itself.
    c.pattern(17, 20, [
        "....SSSSSSSSSSSS....",
        "..SSSSlSSSSSSSSSSS..",
        ".SSSSSSSSSSSSSSSSSSd",
        "SSSSSSSSSSSSSSSSSSSd",
        "SSSSSSSSSSSSSSSSSSSd",
        "SSSSSSSSSSSSSSSSSSSd",
    ], ["S": suit, "l": suitL, "d": suitD])
    gasMask(c, rubber: rubber, dark: rubberD)
    // The suit's seams and the cuffs.
    c.rect(18, 36, 20, 1, suitD); c.rect(27, 34, 1, 2, suitD)
    c.rect(15, 35, 3, 1, rubber)
    // The hose from the tank round to the wand.
    clawdbergLine(c, 15, 34, 17, 40, hose, 0.55); clawdbergLine(c, 17, 40, 37, 38, hose, 0.55)

    if let s = sig, s > 0.04, s < 0.96 {
        // The wand lifted, a great puff of gas billowing out of it.
        let k = (s - 0.04) / 0.92
        c.rect(38, 30, 3, 4, suit); c.rect(38, 33, 3, 1, rubber)
        clawdbergLine(c, 40, 31, 48, 27, metal, 0.6); c.rect(48, 26, 2, 2, C(0x3A3C40))
        for i in 0..<6 {
            let f: Double = k * 1.3 - Double(i) * 0.08
            guard f > 0, f < 1 else { continue }
            let x = 51 + f * 14 + Double(i % 2) * 2, y = 25 - f * 6 + Double(i % 3)
            puff(c, x, y, r: 1.5 + f * 4, alpha: 0.55 * (1 - f))
        }
        return
    }
    // The sprayer wand, levelled.
    c.oy += p.gunY
    c.rect(38, 33, 3, 3, suit); c.rect(38, 35, 3, 1, rubber)
    c.rect(40, 33, 8, 1, metal); c.rect(41, 34, 2, 2, C(0x3A3C40)); c.rect(47, 32, 2, 3, C(0x3A3C40))
    if p.fire == nil, !p.ready, Int(p.lt * 2) % 5 == 0 { puff(c, 50, 33, r: 1, alpha: 0.35) }
}
