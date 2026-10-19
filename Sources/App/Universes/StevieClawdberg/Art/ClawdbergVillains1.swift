import Foundation

// Villains: the Indiana Jones films. Clawd in costume here too: hats, suits, uniforms (never an insignia) and robes
// over the blocky body. The uniforms are plain grey, and each wearer is told apart by what's on top: a peaked cap, a
// black bob, a side parting and spectacles.

let clawdbergVillains1: [ClawdbergVillain: Persona] = [
    .reneBellock: Persona(name: "René Bellock", weapon: .blaster, shot: .arrow, muzzle: (50, 31), headTop: 20,
                          signature: 3.2, callout: "Again, Dr. Jones…", draw: drawReneBellock),
    .majorTote: Persona(name: "Major Tote", weapon: .saber, headTop: 20, signature: 3.4, draw: drawMajorTote),
    .cairoSwordsman: Persona(name: "The Cairo Swordsman", weapon: .saber, headTop: 20, signature: 3.6,
                             draw: drawCairoSwordsman),
    .mechanic: Persona(name: "The Flying-Wing Mechanic", weapon: .saber, bulk: 3, headTop: 16, signature: 3.2,
                       draw: drawMechanic),
    .molaRamm: Persona(name: "Mola Ramm", weapon: .lightning,
                       magic: Magic(core: C(0xFFD8C8), glow: C(0xE0201A), jagged: false), pivot: sankaraHand,
                       headTop: 11, signature: 3.4, callout: "Kali Ma!", draw: drawMolaRamm),
    .laoChay: Persona(name: "Lao Chay", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 22, signature: 3.0,
                      draw: drawLaoChay),
    .colonelVogle: Persona(name: "Colonel Vogle", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 20,
                           signature: 3.0, draw: drawColonelVogle),
    .walterDonnervan: Persona(name: "Walter Donnervan", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 22,
                              signature: 3.0, draw: drawWalterDonnervan),
    .elsaSnyder: Persona(name: "Elsa Snyder", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 21,
                         signature: 3.4, draw: drawElsaSnyder),
    .irinaSpalco: Persona(name: "Irina Spalco", weapon: .saber, headTop: 21, signature: 3.4, draw: drawIrinaSpalco),
    .jurgenVollar: Persona(name: "Jürgen Vollar", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 23,
                           signature: 3.2, draw: drawJurgenVollar),
    .maharajah: Persona(name: "The Maharajah", weapon: .none, headTop: 17, signature: 3.2, draw: drawMaharajah),
]

/// Where Mola Ramm holds the Sankara stone out: its glow leaves from there (raised by the pose's `armRaise`).
private let sankaraHand = (x: 43.5, y: 32.5)

// MARK: - Shared bits

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// Out of the holster: firing, waiting with it up, cheering, hit, checking it, or busy with it.
private func gunOut(_ p: Pose) -> Bool {
    if p.fire != nil || p.ready || p.cheering || p.hit || p.gunLift != 0 || p.smoke != nil { return true }
    return !p.resting && !p.walking
}

/// A small black pistol held out in the right hand (the muzzle at (47, 32)), `p.gunY` up for recoil and checking.
private func pistol(_ c: PixelCanvas, _ p: Pose, sleeve: Px) {
    c.oy += p.gunY
    c.rect(38, 33, 3, 3, sleeve)
    c.pattern(40, 31, ["KKKKKKK", "KKGKK..", "KK.....", "KK....."], ["K": C(0x24242A), "G": C(0x5E626C)])
    c.oy -= p.gunY
}

/// The pistol put away in a brown holster on the right hip, its butt showing.
private func holster(_ c: PixelCanvas) {
    c.rect(36, 35, 3, 4, C(0x4A3220)); c.rect(36, 34, 2, 1, C(0x24242A))
}

/// A plain grey tunic over the body: a stand-up collar, two buttons and a black belt (no badges of any kind).
private func plainTunic(_ c: PixelCanvas, cloth: Px, dark: Px, belt: Px = C(0x1E1E22)) {
    c.rect(18, 33, 20, 5, cloth); c.rect(37, 33, 1, 5, dark); c.rect(18, 33, 20, 1, dark)
    c.px(28, 34, C(0xA8ACB0)); c.px(28, 37, C(0xA8ACB0))
    c.rect(18, 36, 20, 1, belt); c.px(28, 36, C(0x8A8E92))
}

/// Draws the figure in `draw`, faded towards stone grey by `amount` (0…1): Walter Donnervan crumbling. Drawn on a
/// scratch canvas first so only the figure's own pixels go grey, never what's behind it.
private func greyed(_ c: PixelCanvas, _ amount: Double, _ draw: (PixelCanvas) -> Void) {
    guard amount > 0 else { draw(c); return }
    let tmp = PixelCanvas(c.w, c.h)
    tmp.ox = c.ox; tmp.oy = c.oy; tmp.baseY = c.baseY
    draw(tmp)
    let ox = c.ox, oy = c.oy, by = c.baseY
    c.ox = 0; c.oy = 0; c.baseY = 0
    for y in 0..<c.h {
        for x in 0..<c.w {
            let i = (y * c.w + x) * 4
            let a = tmp.buf[i + 3]
            guard a > 0 else { continue }
            let m: Double = 255 / Double(a)
            let r: Double = Double(tmp.buf[i]) * m, g: Double = Double(tmp.buf[i + 1]) * m
            let b: Double = Double(tmp.buf[i + 2]) * m
            let lum: Double = 0.3 * r + 0.59 * g + 0.11 * b
            let stone: Double = 70 + lum * 0.55
            let k: Double = 1 - amount
            let nr = min(255, r * k + stone * amount), ng = min(255, g * k + stone * amount)
            let nb = min(255, b * k + (stone - 6) * amount)
            c.px(x, y, Px(r: UInt8(nr), g: UInt8(ng), b: UInt8(max(0, nb)), a: a))
        }
    }
    c.ox = ox; c.oy = oy; c.baseY = by
}

// MARK: - Major Tote

/// Major Tote: Clawd in a long black leather coat buttoned to the throat, its skirts over the tops of his black boots,
/// a black hat pulled low, little round spectacles and a thin, pleased smile. He fights with a poker, its tip glowing
/// orange from the fire. Signature: he reaches into his coat, brings out a folded rod of black metal and, with a
/// snap, unfolds his menacing weapon: a coat hanger, held up for you to see.
private func drawMajorTote(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x1E1E22), coatL = C(0x3A3A42), coatD = C(0x0C0C0E), wire = C(0xB8BCC4)
    let sig = p.signature

    drawLegs(c, Look(leg: C(0x2A2A2E)), step: p.step)
    clawdbergBoots(c, step: p.step, coatD, height: 3)
    c.oy += p.breathe
    drawBody(c, Look(arm: coat))
    // The coat: buttoned up, a sheen down the leather, its skirts hanging over the legs.
    c.rect(18, 34, 20, 4, coat); c.rect(37, 34, 1, 4, coatD); c.rect(20, 34, 1, 4, coatL)
    for y in [34, 36] { c.px(27, y, coatL) }
    if !seatedPose {
        c.rect(17, 38, 22, 2, coat); c.rect(17, 39, 22, 1, coatD); c.rect(27, 38, 2, 2, coatD)
    }
    // The hat, pulled low.
    clawdbergFedora(c, felt: coat, dark: coatD, band: C(0x3A3A42))
    // Little round spectacles, silver-rimmed, and the thin smile.
    let rim = C(0xB8BCC4)
    for gx in [21, 31] { c.pattern(gx, 28, [".RR.", "R..R", "R..R", "R..R", ".RR."], ["R": rim]) }
    c.rect(25, 29, 6, 1, rim)
    c.rect(26, 33, 4, 1, ink); c.px(25, 32, ink); c.px(30, 32, ink)

    if let s = sig, s > 0.06, s < 0.95 {
        if s < 0.25 {
            // A hand inside the coat.
            c.rect(32, 34, 4, 3, coat); c.rect(32, 34, 1, 3, coatD)
            return
        }
        // The arm up, holding it out before him.
        c.rect(38, 31, 3, 5, coat); c.rect(41, 30, 2, 2, coat)
        if s < 0.45 {
            // The folded rod.
            c.rect(43, 21, 1, 9, wire); c.rect(44, 22, 1, 7, C(0x8A8E96)); c.px(43, 20, wire)
            return
        }
        if s < 0.52 {
            // Snap: half open, and a flick of light.
            c.pattern(38, 22, ["....ww...", "...w..w..", "......w..", ".....w...", "....w.w..", "...w...w.",
                               "..w.....w", ".w.......", "w........"], ["w": wire])
            c.px(46, 26, C(0xFFFFFF, 0.8)); c.px(47, 25, C(0xFFFFFF, 0.6)); c.px(45, 24, C(0xFFFFFF, 0.6))
            return
        }
        // The coat hanger, held up by its bar, turned a little to the light.
        c.pattern(36, 20, [
            ".......ww......",
            "......w..w.....",
            ".........w.....",
            "........w......",
            ".......w.......",
            "......w.w......",
            "....ww...ww....",
            "..ww.......ww..",
            "ww...........ww",
            "wwwwwwwwwwwwwww",
        ], ["w": wire])
        if Int(p.t * 3) % 4 == 0 { c.px(43, 25, white) }
        return
    }

    // The poker: in a fight swung about, at rest held point down by his side, still glowing.
    let a = p.melee ?? 32
    let h = clawdbergHand
    clawdbergSmear(c, h, p.trail, from: 3, to: 14, C(0xFF9A4A))
    clawdbergBar(c, h, a, from: -2, to: 1, C(0x5A3A22), r: 0.7)
    clawdbergBar(c, h, a, from: 1, to: 11, C(0x3A3A40), r: 0.6)
    let t0 = clawdbergReach(h, a, 11), t1 = clawdbergReach(h, a, 14)
    let flick: Double = 0.8 + 0.2 * noise(Int(p.t * 12))
    c.glowLine(t0.x, t0.y, t1.x, t1.y, core: C(0xFFC060), glow: C(0xFF4A1A, 0.8), coreR: 0.6, glowR: 1.7,
               strength: flick)
    c.rect(39, 33, 3, 3, coat)
}

// MARK: - The Cairo Swordsman

/// The Cairo Swordsman: Clawd in black robes with a red sash knotted at the hip, a black headcloth wound round his
/// head and hanging down behind, and a full black beard. He fights with a broad curved scimitar; at rest it lies back
/// over his shoulder. Signature: the long, showy sword twirl, the blade whirling in front of him, up over his head and
/// back, before it settles pointing at you with a grin.
private func drawCairoSwordsman(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0x1C1A1E), robeL = C(0x34303A), sash = C(0xC0282A), sashD = C(0x86181A), beard = C(0x16121A)
    let sig = p.signature

    drawLegs(c, Look(leg: robe), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x3A2A1E), height: 2)
    c.oy += p.breathe
    // The headcloth's tail, hanging down behind.
    c.rect(15, 23, 3, 10, robe); c.rect(15, 32, 3, 1, robeL)
    drawBody(c, Look(arm: robe))
    // The robe, its hem over the legs, and the red sash knotted at the hip.
    c.rect(18, 34, 20, 4, robe); c.rect(25, 34, 1, 4, robeL)
    if !seatedPose { c.rect(17, 38, 22, 2, robe); c.rect(17, 39, 22, 1, robeL); c.rect(27, 38, 2, 2, robeL) }
    c.rect(18, 35, 20, 2, sash); c.rect(18, 36, 20, 1, sashD)
    c.rect(19, 37, 2, 3, sash); c.px(19, 39, sashD)
    // The beard, round the mouth and down the jaw.
    c.pattern(19, 31, [".b..............b.", "bbb.bbbbbbbbbb.bbb", "bbbbbbbbbbbbbbbbbb"], ["b": beard])
    // The headcloth.
    c.pattern(17, 20, [
        ".....RRRRRRRRRRRR.....",
        "...RRRRRrRRRRRRrRRR...",
        "..RRRRRRRRRRRRRRRRRR..",
        ".RRrRRRRRRRRRRRRRRrRR.",
        ".RRRRRRRRRRRRRRRRRRRR.",
        ".RRrrrrrrrrrrrrrrrrRR.",
        ".RR................RR.",
        ".RR................RR.",
    ], ["R": robe, "r": robeL])

    var h = clawdbergHand
    var a = p.melee ?? -105
    var trail = p.trail
    if let s = sig, s > 0.04, s < 0.97 {
        // The twirl: whirling at his hand, then raised over his head, then back down in front and pointed at you.
        let e = ramp(s, 0.08, 0.78)
        let ease: Double = 0.5 - 0.5 * cos(e * .pi)
        a = -90 + 360 * 6 * ease
        trail = e > 0.02 && e < 0.98 ? [a - 30, a - 60] : []
        if s > 0.32 && s < 0.56 {
            h = (x: 39.5, y: 23.5)
            c.rect(38, 24, 3, 11, robe)
        }
        if s >= 0.78 {
            a = -12
            c.rect(25, 33, 6, 1, C(0xF6F2E6))   // the grin, white teeth through the beard
        }
    }
    scimitar(c, h, a, trail: trail)
    c.rect(Int(h.x) - 3, Int(h.y) - 1, 3, 3, robe)
}

/// A broad curved blade on a dark grip with a brass crossguard, at `angle` from `h`, its tip curving up and back.
private func scimitar(_ c: PixelCanvas, _ h: (x: Double, y: Double), _ angle: Double, trail: [Double]) {
    let steel = C(0xD8DCE4), edge = C(0xF6F8FC), brass = C(0xC8A040)
    clawdbergSmear(c, h, trail, from: 3, to: 15, C(0xE8ECF4))
    clawdbergBar(c, h, angle, from: -2.5, to: 1.5, C(0x4A2E1A), r: 0.7)
    let r = angle * .pi / 180
    let ux = cos(r), uy = sin(r)
    let nx = uy, ny = -ux            // the back of the blade: up, when it's held out level
    let g = clawdbergReach(h, angle, 2)
    clawdbergLine(c, g.x + nx * 2, g.y + ny * 2, g.x - nx * 2, g.y - ny * 2, brass, 0.6)
    var prev = clawdbergReach(h, angle, 2.5)
    for i in 1...6 {
        let f = Double(i) / 6
        let d: Double = 2.5 + Double(i) * 2.4
        let off: Double = f * f * 3.2
        let q = (x: h.x + ux * d + nx * off, y: h.y + uy * d + ny * off)
        let w: Double = i < 5 ? 0.9 : 0.6
        clawdbergLine(c, prev.x, prev.y, q.x, q.y, steel, w)
        prev = q
    }
    c.px(Int(prev.x.rounded()), Int(prev.y.rounded()), edge)
}

// MARK: - The Flying-Wing Mechanic

/// The Flying-Wing Mechanic: an enormous Clawd, a head and a half taller and wider than anyone else, bald and shining, in a
/// grubby white vest, khaki trousers and work boots, with arms like hams. He fights with his fists. Signature: he
/// squares up, rolling one shoulder then the other, then brings both fists up.
private func drawMechanic(_ c: PixelCanvas, _ p: Pose) {
    let skin = clawdOrange, shade = clawdShade, vest = C(0xE8E2D2), vestD = C(0xC4BCA8), khaki = C(0x7A6A4A)
    let fist = C(0xC8684A)
    let sig = p.signature

    drawLegs(c, Look(leg: khaki), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x3A2818), height: 2)
    c.oy += p.breathe

    var rollL = 0, rollR = 0, guardUp = false
    if let s = sig, s > 0.05, s < 0.95 {
        if s < 0.65 {
            let k = ramp(s, 0.05, 0.65)
            rollL = Int((sin(k * 4 * .pi) * 2).rounded())
            rollR = Int((sin(k * 4 * .pi + .pi) * 2).rounded())
            c.ox += Int((sin(k * 4 * .pi) * 1).rounded())
        } else {
            guardUp = true
        }
    }

    // The huge body: wider and a head and a half taller than plain Clawd, on the same four legs.
    c.rect(15, 16, 26, 22, skin)
    c.rect(15, 37, 26, 1, shade); c.rect(40, 16, 1, 22, shade)
    c.rect(21, 17, 5, 1, C(0xF2A888)); c.px(20, 18, C(0xF2A888))   // the shine on his bald head
    // Small mean eyes under a heavy brow, and a flat scowl.
    c.rect(21, 21, 2, 3, ink); c.rect(33, 21, 2, 3, ink)
    c.rect(20, 20, 4, 1, shade); c.rect(32, 20, 4, 1, shade)
    c.rect(25, 25, 6, 1, shade)
    // The vest: two straps over his shoulders, a scooped neck, grubby down one side; then the trousers' belt.
    c.rect(16, 29, 24, 7, vest); c.rect(19, 26, 2, 3, vest); c.rect(35, 26, 2, 3, vest)
    c.rect(22, 29, 12, 1, skin); c.rect(24, 30, 8, 1, skin)
    c.rect(18, 32, 2, 1, vestD); c.rect(19, 33, 2, 1, vestD)        // a grease smear
    c.rect(28, 34, 4, 1, vestD); c.rect(39, 29, 1, 7, vestD)        // the vest sagging over his belly
    c.rect(15, 36, 26, 1, C(0x3A2818)); c.rect(15, 37, 26, 1, khaki)
    c.rect(27, 36, 2, 1, C(0x9A8A5A))                               // the belt buckle

    // The left arm, hanging by his side (up in a guard at the end of the signature).
    if guardUp {
        c.rect(11, 20, 4, 10, skin); c.rect(11, 18, 4, 3, fist)
    } else {
        c.rect(11, 24 - rollL, 4, 11, skin); c.rect(11, 33 - rollL, 4, 3, fist); c.rect(11, 24 - rollL, 1, 9, shade)
    }
    if guardUp {
        c.rect(41, 21, 4, 9, skin); c.rect(41, 19, 4, 3, fist)
        return
    }
    if let a = p.melee {
        c.rect(41, 25, 3, 8, skin)
        clawdbergPunch(c, angle: a, trail: p.trail, arm: skin, fist: fist, reach: 8)
        return
    }
    c.rect(41, 24 - rollR, 4, 11, skin); c.rect(41, 33 - rollR, 4, 3, fist); c.rect(44, 24 - rollR, 1, 9, shade)
}

// MARK: - Mola Ramm

/// Mola Ramm: Clawd as the high priest, in red-and-black robes, red paint across his brow, under a towering
/// headdress: a red hood, a bleached skull on his forehead and two great curving horns. He fights with the Sankara
/// stone held out in his hand, its steady red glow. Signature: he lifts the stone high over his head, blazing.
private func drawMolaRamm(_ c: PixelCanvas, _ p: Pose) {
    let red = C(0x8E1A1A), redD = C(0x5A0E10), black = C(0x1A1214), bone = C(0xE2D6B4), boneD = C(0xA8987A)
    let sig = p.signature
    let raising = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: black), step: p.step)
    clawdbergBoots(c, step: p.step, redD, height: 1)
    c.oy += p.breathe
    // The hood's sides, hanging down behind the body.
    c.rect(16, 22, 3, 13, red); c.rect(16, 34, 3, 1, redD)
    drawBody(c, Look(arm: red))
    // The robes: black, red-bordered down the front, the hem over the legs.
    c.rect(18, 34, 20, 4, black); c.rect(26, 34, 4, 4, red); c.rect(27, 34, 2, 4, redD)
    if !seatedPose { c.rect(17, 38, 22, 2, black); c.rect(17, 39, 22, 1, red); c.rect(27, 38, 2, 2, red) }
    // Red paint across the brow, and a grim mouth.
    c.rect(19, 27, 18, 1, C(0xB02020)); c.rect(26, 33, 4, 1, ink)
    // The horns, curving up and out.
    let hornL: [(Double, Double)] = [(22, 23), (17, 20), (14, 16), (15, 11)]
    let hornR: [(Double, Double)] = [(34, 23), (39, 20), (42, 16), (41, 11)]
    for horn in [hornL, hornR] {
        for i in 1..<horn.count {
            let w: Double = 1.3 - Double(i) * 0.25
            clawdbergLine(c, horn[i - 1].0, horn[i - 1].1, horn[i].0, horn[i].1, i == 3 ? boneD : bone, w)
        }
    }
    // The hood across the head, and the skull on his forehead.
    c.rect(18, 22, 20, 4, red); c.rect(18, 25, 20, 1, redD)
    c.pattern(24, 18, [".BBBBBB.", "BBBBBBBB", "BkkBBkkB", "BkkBBkkB", "BBBkkBBB", ".BBBBBB.", ".BdBdBd."],
              ["B": bone, "k": C(0x2A1A16), "d": boneD])

    let stone = C(0xFF3A2A), pulse: Double = 0.75 + 0.25 * sin(p.t * 6)
    if raising {
        // The stone lifted high, blazing, and light spilling down on him.
        let s = sig!
        let up = Int((ramp(s, 0.06, 0.25) * 12).rounded())
        c.rect(38, 33 - up, 3, 3 + up, red)
        let sx = 40.0, sy = Double(31 - up)
        let big: Double = 2.6 + 1.6 * ramp(s, 0.2, 0.4) * pulse
        c.glowLine(sx, sy, sx, sy, core: C(0xFFD8C8), glow: stone.alpha(0.85), coreR: 1.3, glowR: big)
        if s > 0.3 {
            for k in 0..<6 {
                let ang: Double = Double(k) / 6 * 2 * .pi + p.t * 1.5
                let rx = sx + cos(ang) * (big + 2), ry = sy + sin(ang) * (big + 2)
                c.px(Int(rx.rounded()), Int(ry.rounded()), stone.alpha(0.6 * pulse))
            }
        }
        return
    }
    // The stone in his outstretched hand, its glow steady.
    let raise = p.armRaise
    let hx = sankaraHand.x, hy = sankaraHand.y - Double(raise)
    c.rect(38, 33 - raise, 4, 3, red)
    c.glowLine(hx, hy, hx, hy, core: C(0xFFB0A0), glow: stone.alpha(0.7 * pulse), coreR: 1.1, glowR: 2.4)
}

// MARK: - Lao Chay

/// Lao Chay: Clawd in a white dinner jacket with a black bow tie and a red carnation, black trousers and patent shoes,
/// his black hair slicked flat and shining, a pencil moustache. He fires a small pistol. Signature: he holds up the
/// little blue vial of antidote and dangles it on its chain, swinging it just out of reach, smirking.
private func drawLaoChay(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0xF2F0E8), jacketD = C(0xCAC4B2), hair = C(0x141218), shine = C(0x5A6070)
    let sig = p.signature
    let dangling = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: C(0x1A1A1E)), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x08080A), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: jacket))
    // The dinner jacket, its black bow tie and the carnation in his buttonhole.
    c.rect(18, 34, 20, 4, jacket); c.rect(37, 34, 1, 4, jacketD); c.rect(18, 37, 20, 1, jacketD)
    c.rect(24, 34, 1, 4, jacketD); c.rect(31, 34, 1, 4, jacketD)
    c.pattern(26, 34, ["KK.KK", "KKKKK"], ["K": ink])
    c.px(33, 35, C(0xD02030)); c.px(34, 35, C(0xA01828))
    // Hair slicked flat to the head, a shine along it.
    c.pattern(18, 23, [
        "...HHHHHHHHHHHHHH...",
        ".HHHHHHhhhhhhhHHHHH.",
        "HHHHHHHHHHHHHHHHHHHH",
        "HHH..............HHH",
        "HH................HH",
    ], ["H": hair, "h": shine])
    // The pencil moustache, and the smirk while he teases.
    c.rect(25, 32, 2, 1, hair); c.rect(29, 32, 2, 1, hair)
    if dangling {
        c.rect(26, 33, 4, 1, ink); c.px(30, 32, ink); c.px(31, 32, ink)
    }

    if dangling {
        // The hand up, the vial swinging below it on its chain.
        clawdbergLine(c, 39, 34, 43, 28, jacket, 1.1)
        c.rect(43, 26, 2, 2, clawdOrange)
        let swing: Double = sin(p.t * 4) * 0.45
        let hx = 44.0, hy = 28.0
        let vx = hx + sin(swing) * 7, vy = hy + cos(swing) * 7
        clawdbergLine(c, hx, hy, vx, vy - 1, C(0xC8B060), 0.45)
        c.rect(Int(vx.rounded()) - 1, Int(vy.rounded()), 2, 3, C(0x3A9AE8))
        c.px(Int(vx.rounded()) - 1, Int(vy.rounded()) - 1, C(0x8A6A3A))
        c.px(Int(vx.rounded()), Int(vy.rounded()) + 1, C(0xBFE6FF))
        return
    }
    if gunOut(p) { pistol(c, p, sleeve: jacket) } else { holster(c) }
}

// MARK: - Colonel Vogle

/// Colonel Vogle: Clawd in a plain grey uniform buttoned to the collar, jodhpurs and tall black jackboots, a grey
/// peaked cap with a black band and visor (no badge on it, or anywhere), and a cruel downturned brow. He fires a
/// pistol. Signature: he takes off his black leather gloves and slaps them into his palm, again and again.
private func drawColonelVogle(_ c: PixelCanvas, _ p: Pose) {
    let cloth = C(0x6E7276), clothD = C(0x4E5256), clothL = C(0x8A8E92), black = C(0x141416)
    let sig = p.signature
    let slapping = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false

    drawLegs(c, Look(leg: cloth), step: p.step)
    clawdbergBoots(c, step: p.step, black, height: 4)
    c.oy += p.breathe
    drawBody(c, Look(arm: cloth))
    plainTunic(c, cloth: cloth, dark: clothD)
    // The brow, drawn down hard over his eyes, and a thin straight mouth.
    c.px(21, 27, ink); c.px(22, 27, ink); c.px(23, 28, ink); c.px(24, 28, ink)
    c.px(31, 28, ink); c.px(32, 28, ink); c.px(33, 27, ink); c.px(34, 27, ink)
    c.rect(26, 33, 4, 1, ink)
    // The peaked cap.
    c.pattern(16, 20, [
        "....GGGGGGGGGGGGGGG.....",
        "..GGGGGGGGGGGGGGGGGGGG..",
        ".GGGGLGGGGGGGGGGGGLGGGG.",
        "..dddddddddddddddddddd..",
        "...BBBBBBBBBBBBBBBBBB...",
        "..............VVVVVVVVV.",
    ], ["G": cloth, "L": clothL, "d": clothD, "B": black, "V": C(0x0A0A0C)])

    if slapping {
        // His left hand brought round in front, palm up, and the gloves in his right, slapped down into it.
        let s = sig!
        let f = (s - 0.05) / 0.9 * 3
        let cyc = f - floor(f)
        let lift: Int = cyc < 0.75 ? Int((cyc / 0.75 * 5).rounded()) : Int(((1 - cyc) / 0.25 * 5).rounded())
        c.rect(38, 36, 2, 2, cloth); c.rect(40, 37, 5, 1, clawdOrange)
        c.rect(38, 31 - lift, 3, 3, cloth)
        c.pattern(41, 32 - lift, ["GGGG", "GGGG", "G.G.", "G.G."], ["G": black])
        if lift == 0 {
            c.px(40, 34, C(0xFFFFFF, 0.8)); c.px(46, 34, C(0xFFFFFF, 0.8)); c.px(43, 31, C(0xFFFFFF, 0.6))
        }
        return
    }
    if gunOut(p) { pistol(c, p, sleeve: cloth) } else { holster(c) }
}

// MARK: - Walter Donnervan

/// Walter Donnervan: Clawd with silver hair combed back from a side parting, in a smart blue-grey suit with a
/// waistcoat and a wine-red tie. He fires a pistol. Signature: he drinks from the wrong cup, a gaudy jewelled gold
/// one, and goes grey and dusty all over, slumping as the dust trickles off him; then he shakes it all off in a puff
/// and he's himself again (it's only ever cartoonish, and short).
private func drawWalterDonnervan(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature
    var grey: Double = 0
    var shaking = false
    if let s = sig {
        grey = s < 0.5 ? ramp(s, 0.3, 0.42) : 1 - ramp(s, 0.74, 0.82)
        shaking = s > 0.64 && s < 0.82
    }
    if shaking { c.ox += Int(p.t * 30) % 2 == 0 ? 1 : -1 }
    let slump = grey >= 1 && !shaking ? 1 : 0
    greyed(c, grey) { k in walterFigure(k, p, slump: slump) }

    guard let s = sig else { return }
    if grey > 0.3 && !shaking {
        // Dust trickling off him.
        for i in 0..<7 {
            let fx: Double = 18 + noise(i * 13) * 20
            let fy: Double = 28 + (p.t * 0.9 + noise(i * 7 + 3)).truncatingRemainder(dividingBy: 1) * 16
            c.px(Int(fx), Int(fy), C(0xA8A49A, 0.8 * grey))
        }
    }
    if s > 0.66 && s < 0.9 {
        // The puff of dust as he shakes it off, blowing outwards.
        let k = ramp(s, 0.66, 0.9)
        for i in 0..<14 {
            let ang: Double = Double(i) / 14 * 2 * .pi
            let r: Double = 11 + k * 7
            let x: Double = 28 + cos(ang) * r, y: Double = 31 + sin(ang) * r * 0.7
            c.px(Int(x.rounded()), Int(y.rounded()), C(0xBAB6AC, 0.7 * (1 - k)))
        }
    }
}

/// Walter Donnervan himself, on `c`: everything but the dust.
private func walterFigure(_ c: PixelCanvas, _ p: Pose, slump: Int) {
    let suit = C(0x6A7280), suitD = C(0x4C5260), vest = C(0x535A66), shirt = C(0xF0EEE6), tie = C(0x7A1E2A)
    let hair = C(0xC8CACE), hairD = C(0x9A9CA4), hairL = C(0xE4E6EA), gold = C(0xE8B830), goldD = C(0x9A7418)
    let sig = p.signature

    drawLegs(c, Look(leg: suit), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x1E1A16), height: 1)
    c.oy += p.breathe + slump
    drawBody(c, Look(arm: suit))
    // The suit, the waistcoat under it, the white shirt and the tie.
    c.rect(18, 34, 20, 4, suit); c.rect(37, 34, 1, 4, suitD); c.rect(18, 37, 20, 1, suitD)
    c.rect(24, 34, 8, 4, vest)
    c.pattern(25, 34, ["dSTTSd", ".STTS.", "..TT..", "..TT.."], ["d": suitD, "S": shirt, "T": tie])
    // Silver hair combed back from a side parting.
    c.pattern(18, 22, [
        "....LLLLHHHLLLLHH...",
        "..HHHHhhHHHHHHHhhH..",
        ".HHHHHH.hhHHHHHHHHH.",
        "HHHHHHH..HHHHHHHHHHH",
        "HH................HH",
    ], ["H": hair, "h": hairD, "L": hairL])
    c.rect(26, 33, 4, 1, ink)

    if let s = sig {
        if s > 0.04 && s < 0.32 {
            // The jewelled cup tipped up to his mouth.
            c.rect(36, 32, 3, 3, suit); c.rect(31, 33, 5, 2, suit)
            c.pattern(25, 28, ["GGGGGG", "GrGGbG", ".GGGG.", "..GG..", ".GGGG."], ["G": gold, "r": C(0xD02030), "b": C(0x2A6AE8)])
            c.px(26, 28, goldD)
            return
        }
        if s >= 0.32 && s < 0.82 {
            // Stiff, arms at his sides, dazed (two blank dots for eyes).
            c.rect(22, 29, 2, 3, C(0xD97757)); c.rect(32, 29, 2, 3, C(0xD97757))
            c.px(22, 30, ink); c.px(33, 30, ink)
            holster(c)
            return
        }
    }
    if gunOut(p) { pistol(c, p, sleeve: suit) } else { holster(c) }
}

// MARK: - Elsa Snyder

/// Elsa Snyder: Clawd with wavy blonde hair to the shoulders, in a smart pale-grey suit over a white blouse, red
/// lipstick and low heels. She fires a pistol. Signature: she leans out and reaches for the grail lying just beyond
/// her fingertips, straining for it, before she draws back.
private func drawElsaSnyder(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x9C9EA2), suitD = C(0x7A7C82), blouse = C(0xF6F4EE), hair = C(0xE8C870), hairD = C(0xC09A48)
    let hairL = C(0xF6E09A)
    let sig = p.signature
    let reaching = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false

    if reaching {
        // The grail lying on its side at the edge of a crack, out of reach.
        c.rect(46, 43, 14, 1, C(0x5A4A3A)); c.rect(50, 43, 3, 1, C(0x1A1410))
        c.pattern(53, 39, ["WWW.", "WwWW", "WWW.", ".W..", "WWW."], ["W": C(0x9A7A50), "w": C(0x6A4E30)])
    }
    drawLegs(c, Look(leg: suit), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x2A1E1A), height: 1)
    c.oy += p.breathe
    var lean = 0
    if let s = sig, reaching { lean = Int((ramp(s, 0.05, 0.25) * 2 * (1 - ramp(s, 0.82, 0.95))).rounded()) }
    c.ox += lean
    drawBody(c, Look(arm: suit))
    // The suit and the blouse's white collar.
    c.rect(18, 34, 20, 4, suit); c.rect(37, 34, 1, 4, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(25, 34, ["BBSSBB", ".BSSB.", "..SS.."], ["B": blouse, "S": suitD])
    c.rect(27, 33, 2, 1, C(0xB0303A))
    // Wavy blonde hair, parted, down to her shoulders.
    c.pattern(16, 21, [
        ".....LLLLHHHHLLLL.......",
        "...HHhhHHHHHHHhhHHH.....",
        "..HHHHHhhHHHHHHHhhHHH...",
        ".HhhHHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHhhHHHHHHHHH.",
        "HHHH................HHH.",
        "HHH..................HH.",
        "HHHH.................HH.",
        "HHH..................HHH",
        "HhHH.................HhH",
        "HhHH.................HhH",
        ".HHHH................HHH",
        "..HH..................H.",
    ], ["H": hair, "h": hairD, "L": hairL])

    if let s = sig, reaching {
        // Her arm stretched out towards it, fingers straining.
        let strain = s > 0.25 && s < 0.82 ? (Int(p.t * 10) % 2) : 0
        let reach = Double(lean) + ramp(s, 0.08, 0.25) * 9 + Double(strain)
        clawdbergLine(c, 39, 34.5, 39 + reach, 37.5, suit, 1.1)
        c.rect(Int(39 + reach), 37, 2, 2, clawdOrange)
        return
    }
    if gunOut(p) { pistol(c, p, sleeve: suit) } else { holster(c) }
}

// MARK: - Irina Spalco

/// Irina Spalco: Clawd with a severe black bob, cut straight across in a blunt fringe, in a plain olive-grey
/// uniform (no badge on it) with a high collar, a belt and tall black boots. She fights with a silver rapier, worn at
/// her hip when it's put away. Signature: she holds up the crystal skull and its empty eyes glow.
private func drawIrinaSpalco(_ c: PixelCanvas, _ p: Pose) {
    let cloth = C(0x7C8076), clothD = C(0x5A5E56), hair = C(0x101014), hairL = C(0x34343E)
    let sig = p.signature
    let holding = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: cloth), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x101012), height: 4)
    c.oy += p.breathe
    if p.melee == nil {
        // The rapier at her hip in its scabbard, slanting back.
        clawdbergLine(c, 18, 36, 9, 42, C(0x2A2A2E), 0.6); c.rect(17, 35, 2, 2, C(0xB8BCC4))
    }
    drawBody(c, Look(arm: cloth))
    plainTunic(c, cloth: cloth, dark: clothD)
    c.rect(26, 33, 4, 1, ink)
    // The black bob, its blunt fringe down to her eyes.
    c.pattern(17, 21, [
        "....HHHHHHHHHHHHHH....",
        "..HHHHHHHHhHHHHHHHHH..",
        ".HHHHhHHHHHHHHHHHhHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHH..............HHH.",
        ".HHH...............HH.",
        ".HHH...............HH.",
        ".HHH..............HHH.",
        ".HHHH............HHHH.",
    ], ["H": hair, "h": hairL])

    if let s = sig, holding {
        // The crystal skull held up beside her face, its eye sockets glowing brighter as she stares into it.
        let up = Int((ramp(s, 0.06, 0.2) * 5).rounded())
        c.rect(38, 33 - up, 3, 3 + up, cloth)
        let x = 39, y = 25 - up
        let crys = C(0xCDEFFF, 0.9), crysD = C(0x8FC8E8)
        c.pattern(x, y, [".CCCCC.", "CCCCCCC", "CeeCeeC", "CeeCeeC", "CCCdCCC", ".CCCCC.", ".CdCdC."],
                  ["C": crys, "e": C(0x5AA8D8), "d": crysD])
        let glow: Double = ramp(s, 0.25, 0.5) * (0.75 + 0.25 * sin(p.t * 8))
        if glow > 0 {
            for ex in [41.0, 44.0] {
                c.glowLine(ex + 0.5, Double(y) + 3, ex + 0.5, Double(y) + 3, core: C(0xE8FFFF).alpha(glow),
                           glow: C(0x3AD8FF).alpha(glow), coreR: 0.8, glowR: 2.2)
            }
        }
        return
    }
    if let a = p.melee {
        rapier(c, clawdbergHand, a, trail: p.trail)
        c.rect(38, 33, 3, 3, cloth)
    }
}

/// A slender silver rapier with a cup guard, at `angle` from `h`.
private func rapier(_ c: PixelCanvas, _ h: (x: Double, y: Double), _ angle: Double, trail: [Double]) {
    clawdbergSmear(c, h, trail, from: 3, to: 19, C(0xE8ECF4))
    clawdbergBar(c, h, angle, from: -2, to: 1.5, C(0x2A2A2E), r: 0.6)
    let g = clawdbergReach(h, angle, 2)
    c.rect(Int(g.x.rounded()) - 1, Int(g.y.rounded()) - 1, 3, 3, C(0xB8BCC4))
    clawdbergBar(c, h, angle, from: 3, to: 19, C(0xDCE0E8), r: 0.5)
}

// MARK: - Jürgen Vollar

/// Jürgen Vollar: Clawd with neat dark hair side-parted, rectangular wire spectacles and a plain charcoal-grey
/// uniform (no badge on it) with a leather cross strap. He fires a pistol. Signature: he takes out the Dial, a worn
/// bronze disc of gears, and checks it closely, its wheels turning, his spectacles flashing.
private func drawJurgenVollar(_ c: PixelCanvas, _ p: Pose) {
    let cloth = C(0x55585E), clothD = C(0x3E4146), hair = C(0x3A2A1C), hairL = C(0x5A4430), frame = C(0x2A2A2E)
    let sig = p.signature
    let checking = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: cloth), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x141416), height: 3)
    c.oy += p.breathe
    drawBody(c, Look(arm: cloth))
    plainTunic(c, cloth: cloth, dark: clothD)
    for i in 0..<4 { c.px(33 - i * 2, 33 + i, C(0x5A3A22)); c.px(32 - i * 2, 33 + i, C(0x5A3A22)) }
    c.rect(26, 33, 3, 1, ink)
    // Neat dark hair, parted on the left.
    c.pattern(18, 23, [
        "...HHHHHHHHHHHHHH...",
        ".HHHHHhHHHHHHHHHHHH.",
        "HHHHH.hhHHHHHHHHHHHH",
        "HH................HH",
    ], ["H": hair, "h": hairL])
    // Rectangular wire spectacles.
    for gx in [21, 31] { c.pattern(gx, 28, ["FFFF", "F..F", "F..F", "F..F", "FFFF"], ["F": frame]) }
    c.rect(25, 29, 6, 1, frame); c.rect(18, 29, 3, 1, frame); c.rect(35, 29, 3, 1, frame)

    if let s = sig, checking {
        // The Dial held up before him, its gear wheels turning, and a flash off his lenses.
        let up = Int((ramp(s, 0.06, 0.2) * 3).rounded())
        c.rect(38, 32 - up, 3, 4 + up, cloth)
        let cx = 43, cy = 30 - up
        let bronze = C(0xB08A48), bronzeD = C(0x7A5A2A), bronzeL = C(0xE0C080)
        c.pattern(cx - 3, cy - 3, [".BBBBB.", "BBdBBdB", "BBBBBBB", "BdBBBdB", "BBBBBBB", "BBdBBdB", ".BBBBB."],
                  ["B": bronze, "d": bronzeD])
        let ang: Double = p.t * 2.5
        let rx = Double(cx) + 0.5 + cos(ang) * 2, ry = Double(cy) + 0.5 + sin(ang) * 2
        clawdbergLine(c, Double(cx) + 0.5, Double(cy) + 0.5, rx, ry, bronzeL, 0.5)
        c.px(cx, cy, bronzeD)
        if Int(p.t * 2) % 3 == 0 { c.px(23, 29, white); c.px(33, 29, white) }
        return
    }
    if gunOut(p) { pistol(c, p, sleeve: cloth) } else { holster(c) }
}

// MARK: - The Maharajah

/// The Maharajah: a small boy, a short little Clawd under a towering ivory turban with a ruby on its front and a white
/// plume, in a gold brocade coat studded with jewels, a necklace of pearls, white trousers and curled gold slippers.
/// He doesn't fight. Signature: he holds up a tiny voodoo doll in a fedora and jabs a long pin into it, twice,
/// grinning.
private func drawMaharajah(_ c: PixelCanvas, _ p: Pose) {
    let skin = clawdOrange, shade = clawdShade, silk = C(0xF2E6C2), silkD = C(0xCDBE94), gold = C(0xD8A830)
    let goldD = C(0x9A7418), ruby = C(0xD0203A), emerald = C(0x2AA868), pearl = C(0xF6F4EE)
    let sig = p.signature
    let pinning = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: C(0xF0ECE0)), step: p.step)
    clawdbergBoots(c, step: p.step, gold, height: 1)
    c.oy += p.breathe
    // A short little body: three rows lower than anyone else's, on the same four legs.
    c.rect(19, 29, 18, 9, skin); c.rect(19, 37, 18, 1, shade); c.rect(36, 29, 1, 9, shade)
    c.rect(16, 34, 3, 3, gold); c.rect(37, 34, 3, 3, gold)
    c.rect(23, 31, 2, 2, ink); c.rect(31, 31, 2, 2, ink)
    c.rect(26, 33, 4, 1, pinning ? ink : shade)
    if pinning { c.px(25, 32, ink); c.px(30, 32, ink) }
    // The gold brocade coat, a row of jewels, and the pearls at his neck.
    c.rect(19, 34, 18, 4, gold); c.rect(19, 37, 18, 1, goldD); c.rect(36, 34, 1, 4, goldD)
    for x in stride(from: 20, to: 36, by: 2) { c.px(x, 34, pearl) }
    c.px(23, 36, ruby); c.px(28, 36, emerald); c.px(33, 36, ruby)
    // The turban, its ruby and its plume.
    c.rect(29, 17, 2, 5, white); c.px(31, 17, white); c.px(30, 21, gold)
    c.pattern(17, 21, [
        ".....TTTTTTTTTT.....",
        "...ttttTTTTTTTTTT...",
        "..TTTTttttTTTTTTTT..",
        ".TTTTTTTTttGGGGTTTT.",
        ".ttTTTTTTTTGRRGtttT.",
        "TTTttttTTTTGRRGTTTTT",
        "TTTTTTTttttTGGTTTTtt",
        ".tttttttttttttttttt.",
    ], ["T": silk, "t": silkD, "R": ruby, "G": gold])

    guard let s = sig, pinning else { return }
    // The voodoo doll held up in one hand (a little Clawd in a little fedora), the pin jabbed in with the other.
    c.rect(37, 31, 3, 6, gold)
    c.pattern(38, 24, ["..fff..", ".fffff.", "fffffff", "OOOOOOO", "OkOOOkO", "OOOOOOO", "O.O.O.O"],
              ["f": C(0x6A4A2A), "O": C(0xC8A070), "k": ink])
    let f = ramp(s, 0.15, 0.85) * 2
    let cyc = f - floor(f)
    let jab: Double = cyc < 0.3 ? cyc / 0.3 : max(0, 1 - (cyc - 0.3) / 0.4)
    let px0: Double = 51 - jab * 4, py0: Double = 23 + jab * 3
    clawdbergLine(c, px0, py0, px0 - 6, py0 + 4.5, C(0xD8DCE4), 0.45)
    c.rect(Int(px0.rounded()), Int(py0.rounded()) - 1, 2, 2, ruby)
    c.rect(Int(px0.rounded()) + 1, Int(py0.rounded()), 2, 2, gold)
    if jab > 0.9 {
        c.px(43, 26, C(0xFFE27A)); c.px(45, 28, C(0xFFE27A)); c.px(41, 29, C(0xFFE27A))
    }
}

// MARK: - René Bellock

/// René Bellock: Clawd in a cream linen suit over a pale shirt, a panama hat with a black band, and two-tone shoes.
/// He fights with a blowpipe, put to his lips to fire a dart. Signature: he holds up the golden idol in both hands,
/// turns it to the light so it glints, and admires it.
private func drawReneBellock(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0xECE6D4), suitD = C(0xC8C0A8), shirt = C(0xF6F2E6), tie = C(0x8A7A5A)
    let straw = C(0xE8D8A8), strawD = C(0xC4B080), pipe = C(0x9A7A48)
    let sig = p.signature
    let admiring = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: suit), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x6A4A2E), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    // The linen suit, its open collar and a loose tie.
    c.rect(18, 34, 20, 4, suit); c.rect(37, 34, 1, 4, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(25, 34, ["dSSSSd", ".dTTd.", "..TT.."], ["d": suitD, "S": shirt, "T": tie])
    // The panama.
    clawdbergFedora(c, felt: straw, dark: strawD, band: C(0x1E1A16))

    if admiring {
        // The golden idol held up before his face in both hands, a glint running over it.
        let k = sig!
        let y = 26 - Int((min(1, (k - 0.06) / 0.2) * 3).rounded())
        c.rect(36, y + 6, 3, 3, suit); c.rect(15, y + 6, 3, 3, suit)
        c.pattern(39, y, [".GGG.", "GgGgG", "GGGGG", ".GGG.", ".GgG.", "GGGGG", ".G.G."],
                  ["G": C(0xE8B830), "g": C(0x8A6418)])
        let glint = Int(p.t * 3) % 6
        if glint < 3 { c.px(40 + glint, y + 1, C(0xFFF6C8)) }
        return
    }
    if p.fire != nil || p.ready {
        // The blowpipe at his lips, held out level in his right hand.
        c.rect(38, 31, 3, 3, suit)
        c.rect(36, 31, 14, 1, pipe); c.px(49, 31, C(0x6A5030))
        return
    }
    // At rest: the blowpipe held upright by his side.
    c.rect(41, 24, 1, 14, pipe); c.rect(38, 33, 3, 3, suit)
}
