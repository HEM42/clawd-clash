import Foundation

// Villains: the Dark Lord's side, Sourun, the wizard who went over to him and the ring-wraiths. Clawd in costume, every
// one of them: the armour, robes and hoods drawn over (and around) the blocky body. Where a face shows it's Clawd's own
// orange; Sourun's helmet and the wraiths' hoods show none, which is rather the point of them.

let ringsVillains1: [LOTRVillain: Persona] = [
    .sauron: Persona(name: "Sourun", weapon: .saber, armoured: true, bulk: 2, headTop: 14, callout: "One Ring to rule them all.",
                     draw: drawSauron),
    .saruman: Persona(name: "Sarumanual", weapon: .lightning, magic: Magic(core: C(0xFFFFFF), glow: C(0xC8B8FF)),
                      pivot: sarumanCrystal, headTop: 18, callout: "Read the manual, Gandclawd.",
                      draw: drawSaruman),
    .witchKing: Persona(name: "The Twitch-king", weapon: .saber, canSit: false, headTop: 16, callout: "No Clawd can kill me!",
                        draw: drawWitchKing),
    .nazgul: Persona(name: "Nazgulp", weapon: .saber, canSit: false, headTop: 18, callout: "Bagclawds… Shire…",
                     draw: drawNazgul),
]

// MARK: - Shared bits

private let clear = C(0x000000, 0)

/// A solid pixel line (no glow), `r` its half-width.
private func line(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.7) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: clear, coreR: r, glowR: r + 0.1)
}

private func unit(_ degrees: Double) -> (x: Double, y: Double) {
    let r: Double = degrees * .pi / 180
    return (cos(r), sin(r))
}

/// The idle habit playing now, if this pose is the one it's played in (idle, standing, not fighting).
private func idlePlay(_ p: Pose) -> HabitPlay? {
    guard !p.walking, p.mode == .idle, let h = idleHabit else { return nil }
    switch p.role { case .none, .rest: return h; default: return nil }
}

/// A heavy weapon's idle flourish: heaved from `from` degrees through `by` degrees and back, instead of spun round.
private func heaved(_ p: Pose, from: Double, by: Double) -> Double? {
    guard let h = idlePlay(p), h.kind == .flourish else { return p.melee }
    return from + by * habitArc(h.p, hold: 0.2)
}

/// The angles a heavy swing smears through: from now back past `trail`'s last angle by half as far again, so the smear
/// is longer than a saber's (the weapon looks slower, heavier). Empty when it isn't being swung fast.
private func heavySmear(_ now: Double, _ trail: [Double]) -> [Double] {
    guard let last = trail.last else { return [] }
    let end: Double = last + (last - now) * 0.5
    let n = max(2, Int((abs(end - now) / 5).rounded()))
    return (1...n).map { (i: Int) -> Double in now + (end - now) * Double(i) / Double(n) }
}

/// A prop drawn pointing right from pixel (20, 20) of a scratch canvas, turned to `angle` degrees (0 forward, -90 up)
/// and placed with that point on `at`.
private func prop(_ c: PixelCanvas, at: (x: Double, y: Double), angle: Double, alpha: Double = 1, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(41, 41)
    art(s)
    let r = s.rotated(angle, about: (20.5, 20.5), into: 41, 41, at: (20.5, 20.5))
    let x0 = Int(floor(at.x - 20.5)), y0 = Int(floor(at.y - 20.5))
    for y in 0..<r.h {
        for x in 0..<r.w {
            let i = (y * r.w + x) * 4
            guard r.buf[i + 3] > 0 else { continue }
            c.px(x0 + x, y0 + y, unpremultiplied(r, i).alpha(alpha))
        }
    }
}

private func unpremultiplied(_ s: PixelCanvas, _ i: Int) -> Px {
    let a = s.buf[i + 3], m = 255 / Double(a)
    return Px(r: UInt8(min(255, Double(s.buf[i]) * m)), g: UInt8(min(255, Double(s.buf[i + 1]) * m)),
              b: UInt8(min(255, Double(s.buf[i + 2]) * m)), a: a)
}

// MARK: - Sauron

/// Sourun, the Dark Lord: black spiked plate from helmet to boots, the tall helmet crowned with spikes, and nothing of
/// him to see but the orange glow in its eye slits. The One Ring is a gold glint on his left hand. He fights with a huge
/// spiked mace, shouldered between fights; it's heavy, so a swing smears a long way behind it. No signature: he doesn't
/// do party tricks.
private func drawSauron(_ c: PixelCanvas, _ p: Pose) {
    let plate = C(0x2A2A30), deep = C(0x18181C), shine = C(0x4A4A56), glow = C(0xFF8A1E)
    drawLegs(c, Look(leg: plate), step: p.step)
    if !seatedPose {                                                           // plate greaves and sabatons
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let bottom = p.step >= 0 && i % 2 == p.step ? 42 : 43
            c.rect(lx, bottom - 1, 3, 2, deep)
            c.px(lx, bottom - 1, shine)
            c.px(lx, 38, shine)
        }
    }
    c.oy += p.breathe
    drawBody(c, Look(body: plate, shade: deep, arm: plate, eye: nil))
    c.pattern(16, 14, [
        "...........KK...........",
        ".....K.....KK.....K.....",
        ".....K....KKKK....K.....",
        "..K..KK...KKKK...KK..K..",
        "..KK.KK..KKKKKK..KK.KK..",
        "..KKKKKKKKKKKKKKKKKKKK..",
        ".KKKKKKKKKKKKKKKKKKKKKK.",
        ".KHHKKKKKKKKKKKKKKKKKKK.",
        ".KHKKKKKKKKKKKKKKKKKKKK.",
        ".KKKKKKKKKKKKKKKKKKKKKK.",
        ".KKKKKKKKKKKKKKKKKKKKKK.",
        ".KKKKKKKKKKKKKKKKKKKKKK.",
        "KKKKKKKKKKKKKKKKKKKKKKKK",
        "KKKKDDDDDDDDDDDDDDDDKKKK",
        "KKKDDDDDDDDKKDDDDDDDDKKK",
        "KKKDDOOOODDKKDDOOOODDKKK",
        "KKKDDDDDDDDKKDDDDDDDDKKK",
        ".KKDDDDDDDDKKDDDDDDDDKK.",
        ".KKKDDDDDDDKKDDDDDDDKKK.",
    ], ["K": plate, "D": deep, "H": shine, "O": glow])
    // The eye slits glow, flaring now and then.
    let flare: Double = 0.55 + 0.25 * sin(p.lt * 3.1) + (noise(Int(p.lt * 6)) > 0.85 ? 0.2 : 0)
    for sx in [21.0, 31.0] {
        c.glowLine(sx, 29.5, sx + 4, 29.5, core: C(0xFFC27A), glow: glow, coreR: 0.3, glowR: 1.6, strength: flare)
    }
    // Spiked pauldrons, a ridged breastplate, the belt.
    c.pattern(13, 30, ["..K..", ".KKK.", "KKKKK", "KHKKK"], ["K": plate, "H": shine])
    c.pattern(38, 30, ["..K..", ".KKK.", "KKKKK", "KKKKD"], ["K": plate, "D": deep])
    c.rect(18, 33, 20, 1, deep)
    c.rect(27, 34, 2, 3, shine)
    c.rect(18, 36, 20, 1, deep)
    c.rect(26, 36, 4, 1, C(0x5A5A64))
    c.px(16, 34, C(0xE8B33A))                                                  // the One Ring
    // The mace, and a long smear behind a swing.
    let angle = heaved(p, from: -72, by: 82) ?? -72        // the flourish: brought down hard in front of him
    let hand = Sprite.hand
    var trail = p.melee == nil ? [] : p.trail
    if let h = idlePlay(p), h.kind == .flourish {
        // The slam's own smear (the pose's trail follows the spin it replaces).
        let before: Double = -72 + 82 * habitArc(max(0, h.p - 0.04), hold: 0.2)
        trail = abs(before - angle) > 4 ? [before, before + (before - angle)] : []
    }
    for (i, a) in heavySmear(angle, trail).enumerated() {
        let u = unit(a), fade: Double = 0.4 * (1 - Double(i) / 12)
        guard fade > 0.03 else { break }
        c.glowLine(hand.x + u.x * 12, hand.y + u.y * 12, hand.x + u.x * 18, hand.y + u.y * 18,
                   core: C(0xD8DCE4), glow: C(0xFF8A1E, 0.5), coreR: 0.9, glowR: 1.6, strength: fade)
    }
    prop(c, at: hand, angle: angle) { s in
        let iron = C(0x3A3A40), dark = C(0x222226), bright = C(0x6A6A74)
        s.rect(17, 20, 15, 2, iron)                                            // the haft
        s.rect(17, 20, 15, 1, bright)
        s.rect(19, 19, 2, 4, dark)                                             // the grip's wrapping
        s.pattern(31, 15, [
            "..S..S..",
            "..R..R..",
            "SRRRRRRI.",
            ".RBBIIIIS",
            ".RBIIIIIIS",
            "SRIIIIIIDS",
            ".RIIIIIDD.",
            ".RIIIIDDS",
            "SIDDDDDD.",
            "..D..D..",
            "..S..S..",
        ], ["I": iron, "D": dark, "B": bright, "R": C(0x7A7A86), "S": C(0xA8A8B4)])
    }
    c.rect(38, 33, 3, 3, plate)                                                // the gauntlet round the haft
    c.px(38, 33, shine)
}

// MARK: - Saruman

/// Where Sarumanual's magic leaves from: the white crystal in his staff's claw.
private let sarumanCrystal: (x: Double, y: Double) = (41.5, 17.5)

/// Sarumanual the White: white robes, long white hair falling past his shoulders and a beard to his belt, Clawd's
/// orange face between. In his off hand, always open, the manual (he has read it; you haven't). His black staff ends
/// in a claw clutching a white crystal, and that's where his magic comes from: lifted, it crackles, and in a fight the
/// stream leaves the crystal. No signature.
private func drawSaruman(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0xE4E4E0), robeShade = C(0xB4B4AE), fold = C(0xCACAC4), hair = C(0xF0F0EC), hairShade = C(0xC4C4BE)
    drawLegs(c, Look(leg: robeShade), step: p.step)
    if !seatedPose {                                                           // grey shoes under the hem
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let bottom = p.step >= 0 && i % 2 == p.step ? 42 : 43
            c.rect(lx, bottom, 2, 1, C(0x7A7A76))
        }
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: robe))
    // The robe: shoulders to below the knees, flaring a little.
    c.rect(18, 33, 20, 5, robe)
    for y in 38...40 where y + c.oy <= 43 {
        let k = y - 38
        c.rect(17 - k / 2, y, 22 + k, 1, robe)
        c.px(17 - k / 2, y, robeShade); c.px(38 + k - k / 2, y, robeShade)
    }
    c.rect(37, 33, 1, 5, robeShade)
    c.rect(18, 37, 20, 1, fold)
    // Hair: swept back off the brow and down either side of the face to the shoulders.
    c.pattern(16, 20, [
        "........HHHHHHHH........",
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHHHH...",
        "..HHHhHHHHHHHHHHHHhHHH..",
        ".HHhHHHHHHHHHHHHHHHhHHH.",
        ".HHHHHHH........HHHHHHH.",
        "HHHH................HHHH",
        "HHH..................HHH",
        "HHh..................hHH",
        "HHH..................HHH",
        "HH....................HH",
        "HH....................HH",
        "Hh....................hH",
        "HH....................HH",
    ], ["H": hair, "h": hairShade])
    // The long beard, over the robe, tapering to a point (folded up on his lap when he sits).
    let beard: [String] = [
        "..bHHHHHHHHHHb..",
        ".bHHHHHHHHHHHHb.",
        ".bHHhHHHHHHhHHb.",
        "..bHHHHhHHHHHb..",
        "..bHHHhHHHHHHb..",
        "...bHHHHHhHHb...",
        "...bHHhHHHHHb...",
        "....bHHHHHHb....",
        ".....bHHhHb.....",
        "......bHHb......",
    ]
    c.pattern(21, 32, Array(beard.prefix(max(0, 43 - c.oy - 32 + 1))), ["H": hair, "h": hairShade, "b": C(0xA4A49E)])
    c.rect(24, 32, 8, 1, hair)                                                 // the moustache
    // The manual, open in his left hand.
    c.pattern(8, 31, [
        ".PPPKPPP.",
        "PpppKpppP",
        "PPPPKPPPP",
        "PpppKppPP",
        "CCCCCCCCC",
    ], ["P": C(0xE8E0C8), "p": C(0x8A8270), "K": C(0x4A3A22), "C": C(0x6A4A2A)])
    c.rect(15, 33, 3, 3, robe); c.px(15, 33, robeShade)
    // The staff, lifted as he casts.
    let up = p.armRaise
    let sx = Int(sarumanCrystal.x), top = Int(sarumanCrystal.y) - up
    c.rect(sx, top + 2, 1, 43 - c.oy - up - (top + 2) + 1, C(0x2A2A30))
    c.rect(sx, top + 2, 1, 1, C(0x4A4A54))
    c.pattern(sx - 2, top - 2, [
        "K...K",
        "K.W.K",
        "KWWWK",
        "KWwWK",
        ".KWK.",
        "..K..",
    ], ["K": C(0x2A2A30), "W": white, "w": C(0xD8E2EC)])
    if p.zap != nil {
        let pulse: Double = 0.5 + 0.5 * sin(p.t * 9)
        let y: Double = sarumanCrystal.y - Double(up)
        c.glowLine(sarumanCrystal.x, y, sarumanCrystal.x, y, core: white, glow: C(0xC8B8FF), coreR: 0.4, glowR: 2.2,
                   strength: 0.4 + 0.4 * pulse)
    }
    c.rect(38, 33 - up, 4, 3, robe)                                            // sleeve and fist round the staff
    c.rect(38, 35 - up, 4, 1, robeShade)
}

// MARK: - The ring-wraiths

private enum WraithWeapon { case flail, sword }

/// The Twitch-king, lord of the wraiths: a tall black hood with nothing inside it, a spiked iron crown over the hood,
/// a ragged robe to the ground and no legs to be seen. He fights with a flail, the spiked ball whirling on its chain
/// behind the swing. No signature.
private func drawWitchKing(_ c: PixelCanvas, _ p: Pose) {
    drawWraith(c, p, crown: true, weapon: .flail)
}

/// Nazgulp, a ring-wraith: the same tall black hood and ragged robe, no crown, and deep in the hood two faint pale
/// points where eyes ought to be. He carries a long sword, held low between fights. No signature.
private func drawNazgul(_ c: PixelCanvas, _ p: Pose) {
    drawWraith(c, p, crown: false, weapon: .sword)
}

/// A ring-wraith: the hood (crowned for the Twitch-king), the ragged robe hiding the legs, and its weapon.
private func drawWraith(_ c: PixelCanvas, _ p: Pose, crown: Bool, weapon: WraithWeapon) {
    let robe = C(0x1E1E24), robeDark = C(0x101014), rim = C(0x34343E), void = C(0x000000)
    // The robe, shoulders to the ground, its hem in tatters that stir as it moves.
    let stir = p.walking ? p.step : Int(p.lt * 2) % 2
    for y in 30...43 where y + c.oy <= 43 {
        let k = Double(y - 30) / 13
        let hw: Double = 11.5 + k * 3.5
        let sway: Double = p.walking ? k * 1.2 : sin(p.lt * 1.4 + k * 2) * k * 0.8
        let l = Int((28 - hw - sway).rounded()), r = Int((28 + hw - sway).rounded()) - 1
        if y >= 42 {
            // The last two rows dithered into rags.
            for x in l...r where (x + y + stir) % 2 == 0 || (y == 42 && x % 3 != 0) { c.px(x, y, y == 43 ? robeDark : robe) }
        } else {
            c.rect(l, y, r - l + 1, 1, robe)
            c.px(l, y, rim); c.px(r, y, robeDark)
            let folds: [(x: Int, from: Int)] = [(l + 6, 37), (Int((28 - sway).rounded()), 36), (r - 6, 38)]
            for f in folds where y >= f.from { c.px(f.x, y, robeDark) }
        }
    }
    c.oy += p.breathe
    // The hood: taller than a monk's and peaked, falling to the shoulders, the opening pure black with nothing in it.
    let outer: [Int] = [3, 4, 5, 6, 7, 8, 9, 10, 10, 11, 11, 11, 11, 11, 11, 12, 12]        // rows 18…34
    let opening: [Int] = [0, 0, 0, 0, 0, 0, 4, 5, 6, 7, 7, 7, 7, 7, 7, 6, 4]
    for (i, hw) in outer.enumerated() {
        let y = 18 + i
        c.rect(28 - hw, y, hw * 2, 1, robe)
        c.px(28 - hw, y, rim); c.px(27 + hw, y, robeDark)
        if (2...6).contains(i) { c.px(30 - hw + 1, y, rim) }                       // light catching the hood
        let ow = opening[i]
        if ow > 0 {
            c.rect(27 - ow, y, ow * 2 + 2, 1, rim)
            c.rect(28 - ow, y, ow * 2, 1, void)
        }
    }
    c.rect(24, 23, 8, 1, rim)
    c.rect(24, 35, 8, 1, rim)
    if crown {
        // A spiked iron crown over the hood.
        c.pattern(21, 16, [
            ".h...h..h...h.",
            ".I..hI..Ih..I.",
            "II..II..II..II",
            "IIIIIIIIIIIIII",
            "IhIIhIIIIhIIhI",
        ], ["I": C(0x6A6E78), "h": C(0x9AA0AA)])
    } else {
        // Two faint pale points, deep in the hood.
        let a: Double = 0.75 + 0.25 * sin(p.lt * 1.7)
        c.px(24, 29, C(0x9AA4B0, a)); c.px(31, 29, C(0x9AA4B0, a))
    }
    switch weapon {
    case .flail: drawFlail(c, p)
    case .sword: drawWraithSword(c, p)
    }
    c.rect(38, 32, 3, 5, robe); c.px(40, 36, robeDark)                         // the sleeve, an iron gauntlet out of it
    c.rect(41, 33, 2, 3, C(0x4A4E58))
    c.px(41, 33, C(0x6A6E78))
}

/// The Twitch-king's flail: a short iron haft along `p.melee`, the chain and the spiked ball. The ball lags behind a
/// fast swing (with a smear) and hangs down when it isn't swinging.
private func drawFlail(_ c: PixelCanvas, _ p: Pose) {
    let iron = C(0x6A6E78), ball = C(0x4A4E58), bright = C(0x9AA0AA)
    let hand = Sprite.hand
    let angle = p.melee ?? -20
    let u = unit(angle)
    let end = (x: hand.x + u.x * 4, y: hand.y + u.y * 4)
    line(c, hand.x - u.x, hand.y - u.y, end.x, end.y, iron, 0.7)
    // The chain: out along a fast swing, lagging a little behind it; otherwise hanging down (swaying when held up).
    var chainAngle: Double = 90 + 14 * sin(p.lt * 3)
    if p.melee != nil, let prev = p.trail.first {
        chainAngle = angle + (prev - angle) * 0.6
        let smear = heavySmear(chainAngle, p.trail)
        for (i, a) in smear.enumerated() {
            let v = unit(a), fade: Double = 0.4 * (1 - Double(i) / Double(smear.count))
            c.glowLine(end.x + v.x * 7, end.y + v.y * 7, end.x + v.x * 7, end.y + v.y * 7, core: C(0xD8DCE4),
                       glow: C(0x9AA4B0), coreR: 1.6, glowR: 2.4, strength: fade)
        }
    }
    let v = unit(chainAngle)
    for k in 1...4 {
        let x = Int((end.x + v.x * Double(k)).rounded(.down)), y = Int((end.y + v.y * Double(k)).rounded(.down))
        c.px(x, y, k % 2 == 0 ? bright : iron)
    }
    // The ball: round, four spikes, a glint.
    let b = (x: Int((end.x + v.x * 7).rounded(.down)), y: min(40 - c.oy, Int((end.y + v.y * 7).rounded(.down))))   // the floor stops it
    c.pattern(b.x - 3, b.y - 3, [
        "...S...",
        "..BBB..",
        ".BBBBB.",
        "SBBBBBS",
        ".BBBBB.",
        "..BBB..",
        "...S...",
    ], ["B": ball, "S": iron])
    c.px(b.x - 1, b.y - 1, bright); c.px(b.x - 2, b.y, bright)
}

/// Nazgulp's long sword: steel with a darker edge, an iron crossguard, a smear behind a fast swing; held low and
/// forward when it isn't in use.
private func drawWraithSword(_ c: PixelCanvas, _ p: Pose) {
    let hand = Sprite.hand
    let angle = p.melee ?? 25
    for (i, a) in (p.melee == nil ? [] : p.trail).enumerated() {
        let u = unit(a)
        c.glowLine(hand.x + u.x * 4, hand.y + u.y * 4, hand.x + u.x * 18, hand.y + u.y * 18, core: C(0xD8E0E8),
                   glow: C(0x9AA4B0), coreR: 0.5, glowR: 1.6, strength: 0.3 / Double(i + 1))
    }
    let u = unit(angle), n = (x: -u.y, y: u.x)
    line(c, hand.x - u.x * 2, hand.y - u.y * 2, hand.x + u.x * 2, hand.y + u.y * 2, C(0x2A2A30), 0.8)   // the grip
    c.px(Int(hand.x - u.x * 2.5), Int(hand.y - u.y * 2.5), C(0x6A6E78))                                   // the pommel
    line(c, hand.x + u.x * 4, hand.y + u.y * 4, hand.x + u.x * 18, hand.y + u.y * 18, C(0xC8CCD4), 0.8)
    line(c, hand.x + u.x * 4 + n.x * 0.5, hand.y + u.y * 4 + n.y * 0.5, hand.x + u.x * 17 + n.x * 0.5,
         hand.y + u.y * 17 + n.y * 0.5, C(0x9AA4B0), 0.35)
    let g = (x: hand.x + u.x * 3, y: hand.y + u.y * 3)
    line(c, g.x - n.x * 2.5, g.y - n.y * 2.5, g.x + n.x * 2.5, g.y + n.y * 2.5, C(0x4A4E58), 0.6)          // the crossguard
}
