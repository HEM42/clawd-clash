import Foundation

// Villains: the Dark Lord's side, Sourun, the wizard who went over to him and the ring-wraiths. Clawd in costume, every
// one of them: the armour, robes and hoods drawn over (and around) the blocky body. Where a face shows it's Clawd's own
// orange; Sourun's helmet and the wraiths' hoods show none, which is rather the point of them.
// Sharkey is Sarumanual fallen low, drawn by the same function; the Necro-maintainer is Sourun with no body at all.

let ringsVillains1: [LOTRVillain: Persona] = [
    .sauron: Persona(name: "Sourun", weapon: .saber, armoured: true, bulk: 2, headTop: 14, signature: 3.2,
                     callout: "One Ring to rule them all.", draw: drawSauron),
    .saruman: Persona(name: "Sarumanual", weapon: .saber, pivot: sarumanHand, headTop: 18, signature: 3.0,
                      callout: "Read the manual, Gandclawd.", draw: drawSaruman),
    .witchKing: Persona(name: "The Twitch-king", weapon: .saber, canSit: false, headTop: 16, signature: 3.0,
                        callout: "No Clawd can kill me!", draw: drawWitchKing),
    .nazgul: Persona(name: "Nazgulp", weapon: .saber, canSit: false, headTop: 18, signature: 3.2, callout: "Bagclawds… Shire…",
                     draw: drawNazgul),
    .sharkey: Persona(name: "Sharkey", weapon: .saber, pivot: sarumanHand, headTop: 18, signature: 2.6,
                      callout: "Fine. Then I'll leave a nitpick on every line.", draw: drawSharkey),
    .necromancer: Persona(name: "The Necro-maintainer", weapon: .lightning, motion: .hover,
                          magic: Magic(core: C(0xFFB050), glow: C(0x8A1A30)), canSit: false, pivot: necroHand, headTop: 14,
                          signature: 3.6, callout: "Nothing is ever deleted. Only deprecated.", draw: drawNecromancer),
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

/// Smoothstep: 0→1 eased at both ends.
private func smooth(_ x: Double) -> Double {
    let u = min(1, max(0, x))
    return u * u * (3 - 2 * u)
}

/// A value through a signature `s` 0…1, eased from key to key (`keys` in order of `s`), flat beyond the ends.
private func keyed(_ s: Double, _ keys: [(s: Double, v: Double)]) -> Double {
    guard let first = keys.first, let last = keys.last else { return 0 }
    if s <= first.s { return first.v }
    for (a, b) in zip(keys, keys.dropFirst()) where s < b.s {
        return a.v + (b.v - a.v) * smooth((s - a.s) / (b.s - a.s))
    }
    return last.v
}

/// Colour `a` turned `k` (0…1) of the way to `b`.
private func mix(_ a: Px, _ b: Px, _ k: Double) -> Px {
    let f = { (x: UInt8, y: UInt8) -> UInt8 in UInt8((Double(x) + (Double(y) - Double(x)) * min(1, max(0, k))).rounded()) }
    return Px(r: f(a.r, b.r), g: f(a.g, b.g), b: f(a.b, b.b), a: f(a.a, b.a))
}

/// The Eye: a lidless almond of fire `w` pixels either side of `at` and up to `h` above and below it, open `open` (0…1;
/// nearly shut, it's a slit of flame), its black pupil a cat's slit `look` pixels off the middle, flames licking off
/// its edges and a red glow round it.
private func drawEye(_ c: PixelCanvas, at: (x: Double, y: Double), w: Double, h: Double, open: Double, look: Double = 0,
                     t: Double) {
    guard open > 0.03 else { return }
    let half = max(0.5, h * open)
    c.glowLine(at.x - w * 0.7, at.y, at.x + w * 0.7, at.y, core: C(0xFF3A10, 0.25), glow: C(0xE0280C), coreR: 0.5,
               glowR: half + 2.5, strength: 0.45 * min(1, open * 2))
    let flicker = Int(t * 14)
    for x in Int(floor(at.x - w))...Int(ceil(at.x + w)) {
        let u = (Double(x) + 0.5 - at.x) / w
        guard abs(u) < 1 else { continue }
        let hh: Double = max(0.5, half * (1 - u * u))
        let top = Int((at.y - hh).rounded()), bottom = max(top, Int((at.y + hh).rounded()) - 1)
        for y in top...bottom {
            let v = (Double(y) + 0.5 - at.y) / max(1, half)
            let r = (u * u + v * v).squareRoot()
            let col = y == top || y == bottom ? C(0x9A1C10) : r > 0.75 ? C(0xE04A14) : r > 0.45 ? C(0xFF8A24) : C(0xFFD060)
            c.px(x, y, col)
        }
        if abs(Double(x) + 0.5 - (at.x + look)) < 0.6 && half > 1 {
            c.rect(x, top + 1, 1, bottom - top - 1, C(0x140406))                 // the pupil, a slit
        }
        // Flames licking up off the top edge (and a few below).
        if noise(x * 7 + flicker * 13) > 0.55 { c.px(x, top - 1, C(0xFF6A1A, 0.75 * open)) }
        if noise(x * 11 + flicker * 5) > 0.8 { c.px(x, top - 2, C(0xFFB040, 0.55 * open)) }
        if noise(x * 5 + flicker * 17) > 0.8 { c.px(x, bottom + 1, C(0xFF6A1A, 0.5 * open)) }
    }
}

// MARK: - Sauron

/// Sourun, the Dark Lord: black spiked plate from helmet to boots, the tall helmet crowned with spikes, and nothing of
/// him to see but the orange glow in its eye slits. The One Ring is a gold glint on his left hand. He fights with a huge
/// spiked mace, shouldered between fights; it's heavy, so a swing smears a long way behind it. Signature: "I see you":
/// he raises the fist with the Ring on it (…0.2) and the Ring flares gold; above his helm the Eye flickers open, wreathed
/// in fire, and its slit pupil darts back and then forward, looking for whoever has it (…0.7); it closes, the Ring dims
/// and the fist comes down.
private func drawSauron(_ c: PixelCanvas, _ p: Pose) {
    let plate = C(0x2A2A30), deep = C(0x18181C), shine = C(0x4A4A56), glow = C(0xFF8A1E)
    let sig = p.melee == nil ? p.signature : nil
    let lift = sig.map { Int((6 * habitArc($0, hold: 0.6)).rounded()) } ?? 0      // the Ring's fist, raised
    let ringFlare = sig.map { keyed($0, [(0.1, 0), (0.22, 1), (0.75, 1), (0.88, 0)]) } ?? 0
    let eye = sig.map { keyed($0, [(0.24, 0), (0.28, 0.45), (0.31, 0.1), (0.37, 1), (0.7, 1), (0.8, 0)]) } ?? 0
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
    drawBody(c, Look(body: plate, shade: deep, arm: plate, eye: nil), armLeft: lift)
    c.pattern(16, 14, sauronHelm, ["K": plate, "D": deep, "H": shine, "O": glow])
    // The eye slits glow, flaring now and then.
    let flare: Double = 0.55 + 0.25 * sin(p.lt * 3.1) + (noise(Int(p.lt * 6)) > 0.85 ? 0.2 : 0)
    for sx in [21.0, 31.0] {
        c.glowLine(sx, 29.5, sx + 4, 29.5, core: C(0xFFC27A), glow: glow, coreR: 0.3, glowR: 1.6, strength: flare + 0.35 * eye)
    }
    // Spiked pauldrons, a ridged breastplate, the belt.
    c.pattern(13, 30, ["..K..", ".KKK.", "KKKKK", "KHKKK"], ["K": plate, "H": shine])
    c.pattern(38, 30, ["..K..", ".KKK.", "KKKKK", "KKKKD"], ["K": plate, "D": deep])
    c.rect(18, 33, 20, 1, deep)
    c.rect(27, 34, 2, 3, shine)
    c.rect(18, 36, 20, 1, deep)
    c.rect(26, 36, 4, 1, C(0x5A5A64))
    c.px(16, 34 - lift, C(0xE8B33A))                                           // the One Ring
    if ringFlare > 0 {
        // The Ring flaring on the raised fist: a gold blaze, glinting.
        let pulse: Double = ringFlare * (0.8 + 0.2 * sin(p.lt * 9))
        c.glowLine(16.5, 34.5 - Double(lift), 16.5, 34.5 - Double(lift), core: C(0xFFF4C0), glow: C(0xFFB030), coreR: 0.6,
                   glowR: 1.5 + 2.2 * ringFlare, strength: pulse)
        for (dx, dy) in [(-2, 0), (2, 0), (0, -2), (0, 2)] { c.px(16 + dx, 34 - lift + dy, C(0xFFF0B0, 0.7 * pulse)) }
    }
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
    if let s = sig {
        // The Eye over the helm, its pupil looking back, then forward.
        let look = keyed(s, [(0.42, 0), (0.46, -3), (0.53, -3), (0.57, 3), (0.65, 3), (0.69, 0)])
        drawEye(c, at: (28, 7.5), w: 9, h: 3.6, open: eye, look: look, t: p.lt)
    }
}

/// Sourun's helmet, the spikes of its crown down to the eye slits (`O`): K plate, D deep, H shine. The
/// Necro-maintainer's crown is its top rows, half-seen through his smoke.
private let sauronHelm: [String] = [
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
]

// MARK: - Sarumanual and Sharkey

/// The white crystal in his staff's claw, held upright.
private let sarumanCrystal: (x: Double, y: Double) = (41.5, 17.5)

/// The fist (in his sleeve) that holds the staff, and swings it in a fight.
private let sarumanHand: (x: Double, y: Double) = Sprite.hand

/// What tells Sarumanual from Sharkey, the same wizard fallen low: the colours of the robe, hair, shoes and staff, the
/// light in its crystal, and whether he's gone to seed (a ragged robe, a tangled mane and beard, a sneer, a bent staff
/// and a tattered manual).
private struct WizardRobes {
    let robe: Px, robeShade: Px, fold: Px
    let hair: Px, hairShade: Px, beardEdge: Px
    let shoes: Px, staff: Px, staffLight: Px
    let glow: StaffGlow
    let fallen: Bool
}

private let whiteRobes = WizardRobes(robe: C(0xE4E4E0), robeShade: C(0xB4B4AE), fold: C(0xCACAC4),
                                     hair: C(0xF0F0EC), hairShade: C(0xC4C4BE), beardEdge: C(0xA4A49E),
                                     shoes: C(0x7A7A76), staff: C(0x2A2A30), staffLight: C(0x4A4A54),
                                     glow: StaffGlow(core: C(0xF4F0FF), glow: C(0xC8B8FF)), fallen: false)

private let shabbyRobes = WizardRobes(robe: C(0x857D70), robeShade: C(0x5E574C), fold: C(0x726B5F),
                                      hair: C(0xB8B3A6), hairShade: C(0x8A857A), beardEdge: C(0x6E695F),
                                      shoes: C(0x3E342A), staff: C(0x4A4036), staffLight: C(0x6A5E50),
                                      glow: StaffGlow(core: C(0xD8D4B0), glow: C(0x9A9468), strength: 0.6, sputters: true),
                                      fallen: true)

/// Sarumanual the White: white robes, long white hair falling past his shoulders and a beard to his belt, Clawd's
/// orange face between. In his off hand, always open, the manual (he has read it; you haven't). His black staff ends
/// in a claw clutching a white crystal that glows a pale violet, always, and brighter in a fight, where he swings the
/// staff like a sword. Signature: the palantír: he tucks the manual under his arm and holds up the dark seeing-stone
/// (…0.15), his eyes on it, a light swirling in it that turns from his own violet to fire, until the Eye itself looks
/// back out of it and lights his face orange (…0.75); then the stone goes dark and the manual comes back out.
private func drawSaruman(_ c: PixelCanvas, _ p: Pose) {
    drawWizard(c, p, whiteRobes, sig: p.signature)
}

/// Sharkey, Sarumanual fallen low in the Shire: the same wizard in a dirty grey-brown robe, patched, stained and
/// ragged at the hem, his hair and beard grown into a tangled, dingy mess, his brows knotted and his mouth in a sneer.
/// The manual is still in his hand, dog-eared and torn; his staff is bent and splintered, the claw broken, the crystal
/// cracked and clouded, its light a dim, sickly, sputtering glimmer; he still swings it in a fight. Signature: a
/// tantrum: he stamps his feet one after the other, kicking up dust, shaking the broken staff up and down so the cracked
/// crystal sputters sparks, shouting, an anger mark popping on his head; then he sulks back into his sneer.
private func drawSharkey(_ c: PixelCanvas, _ p: Pose) {
    drawWizard(c, p, shabbyRobes, sig: p.signature)
}

/// The wizard in the robes `w`: Sarumanual, or Sharkey, `sig` through his signature (the palantír, or the tantrum).
private func drawWizard(_ c: PixelCanvas, _ p: Pose, _ w: WizardRobes, sig: Double? = nil) {
    let robe = w.robe, robeShade = w.robeShade, fold = w.fold, hair = w.hair, hairShade = w.hairShade
    let sig = p.melee == nil ? sig : nil
    var p = p
    // Sharkey's tantrum: a stamp a beat, the body jolting with it and the staff shaken up and down.
    var beat: (n: Int, k: Double)?
    if w.fallen, let s = sig, s > 0.06, s < 0.9 {
        let b: Double = (s - 0.06) * 2.6 * 7
        beat = (Int(b), b - floor(b))
        p.step = Int(b) % 2
        p.breathe = Int(b) % 2 == 0 ? -1 : 0
        p.armRaise = [1, 4, 2, 5][Int(b) % 4]
    }
    // Sarumanual's gaze into the palantír, held up in his off hand `raise` pixels.
    let gaze: Double = w.fallen ? 0 : sig.map { habitArc($0, hold: 0.7) } ?? 0
    let raise = Int((9 * gaze).rounded())
    drawLegs(c, Look(leg: robeShade), step: p.step)
    if !seatedPose {                                                           // shoes under the hem
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let bottom = p.step >= 0 && i % 2 == p.step ? 42 : 43
            c.rect(lx, bottom, 2, 1, w.shoes)
            if let b = beat, i % 2 != p.step {
                // The dust a stamp kicks up round the foot that came down.
                let a: Double = 0.7 * (1 - b.k), d = Int(b.k * 2)
                for (dx, dy) in [(-1 - d, 0), (2 + d, 0), (-2 - d, -1), (3 + d, -1)] { c.px(lx + dx, 43 + dy, C(0x9A8E78, a)) }
            }
        }
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: robe), armLeft: raise)
    // The robe: shoulders to below the knees, flaring a little.
    c.rect(18, 33, 20, 5, robe)
    for y in 38...40 where y + c.oy <= 43 {
        let k = y - 38
        if w.fallen && y == 40 {
            // Sharkey's hem, in tatters.
            for x in (17 - k / 2)...(38 + k - k / 2) where (x * 7 + 3) % 5 > 1 { c.px(x, y, robe) }
            continue
        }
        c.rect(17 - k / 2, y, 22 + k, 1, robe)
        c.px(17 - k / 2, y, robeShade); c.px(38 + k - k / 2, y, robeShade)
    }
    c.rect(37, 33, 1, 5, robeShade)
    c.rect(18, 37, 20, 1, fold)
    if w.fallen {
        // A patch sewn on with big stitches, and stains.
        c.rect(19, 34, 3, 3, C(0x6A6050)); c.px(19, 34, C(0x4A4236)); c.px(21, 36, C(0x4A4236))
        let stain = C(0x5A4E3C, 0.7)
        for (x, y) in [(33, 35), (34, 35), (34, 36), (24, 38), (25, 39), (36, 39), (20, 39)] { c.px(x, y, stain) }
    }
    // Hair: swept back off the brow and down either side of the face to the shoulders (Sharkey's tangled, tufts sticking
    // out every way).
    c.pattern(16, w.fallen ? 19 : 20, w.fallen ? [
        "....H....H..H.....H.....",
        "........HHhHHHhH...H....",
        "....hHHHHHHHHHHHHHH.....",
        "..HHHHHhHHHHHHHHHHHhH...",
        "..HHhHHHHHHhHHHHHHhHHHH.",
        "HHHhHHHHHHHHHHHHHHHHhHHH",
        "HHHHHHH.H......H.HHHHHHH",
        "HHHH................HHHH",
        "hHH..................HHh",
        "HHh..................hHH",
        "HHH..................HHH",
        "hH....................H.",
        "HH....................HH",
        "Hh....................h.",
        "H.H..................H.H",
    ] : [
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
    // The long beard, over the robe, tapering to a point (folded up on his lap when he sits); Sharkey's straggles
    // into ragged forks.
    let beard: [String] = w.fallen ? [
        ".bHHHHHHHHHHHHb.",
        "bHHhHHHHHHHhHHHb",
        ".bHHHHhHHHHHHHb.",
        "..bHHhHHHHhHHb..",
        "..bHHHHHHHHHhHb.",
        "...bHhHHHHHHb...",
        "...bHHHb.bHHb...",
        "....bHHb..bHb...",
        ".....bH....b....",
        "......b.........",
    ] : [
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
    c.pattern(21, 32, Array(beard.prefix(max(0, 43 - c.oy - 32 + 1))), ["H": hair, "h": hairShade, "b": w.beardEdge])
    c.rect(24, 32, 8, 1, hair)                                                 // the moustache
    if w.fallen {
        // Knotted brows and a sneer, curling up at one corner.
        for (x, y) in [(21, 27), (22, 27), (23, 28), (34, 27), (33, 27), (32, 28)] { c.px(x, y, ink) }
        for x in 26...29 { c.px(x, 33, ink) }
        c.px(30, 32, ink); c.px(31, 32, C(0x8A3A2A))
        if let b = beat, b.n % 2 == 0 { c.rect(26, 33, 5, 2, C(0x3A1410)); c.rect(27, 33, 3, 1, C(0xD8D0B8)) }   // shouting
    }
    if raise > 0 {
        // The palantír held up in his off hand, the manual tucked under that arm, his eyes turned up to the stone.
        c.pattern(13, 33, ["CP", "CP", "CP", "CP"], ["C": C(0x6A4A2A), "P": C(0xE8E0C8)])
        c.rect(15, 33 - raise, 3, raise + 3, robe); c.px(15, 33 - raise, robeShade)
        c.rect(15, 32 - raise, 3, 2, clawdOrange)
        if let s = sig, gaze > 0.6 {
            c.rect(22, 29, 2, 3, clawdOrange); c.rect(32, 29, 2, 3, clawdOrange)
            c.rect(21, 28, 2, 3, ink); c.rect(31, 28, 2, 3, ink)
            drawPalantir(c, x: 12, y: 25 - raise, k: s, t: p.lt)
        } else {
            drawPalantir(c, x: 12, y: 25 - raise, k: 0, t: p.lt)
        }
    } else {
        drawManual(c, tattered: w.fallen)
        c.rect(15, 33, 3, 3, robe); c.px(15, 33, robeShade)
    }
    if let angle = p.walking || p.seated ? nil : p.melee {
        // Fighting: the staff swung like a sword from his fist, the crystal's light bright and smeared behind it.
        drawSwungStaff(c, hand: sarumanHand, head: sarumanCrystal, angle: angle, trail: p.trail, glow: w.glow, t: p.t) {
            drawSarumanStaff($0, w, up: 0)
        }
    } else {
        // The staff upright in his hand, the crystal glowing softly (Sharkey's bent halfway down, and splintered).
        let up = p.armRaise
        let crystal = (x: sarumanCrystal.x, y: sarumanCrystal.y - Double(up))
        drawStaffGlow(c, at: crystal, w.glow, bright: false, t: p.t)
        drawSarumanStaff(c, w, up: up)
        drawStaffGlow(c, at: crystal, w.glow, bright: false, t: p.t, front: true)
    }
    c.rect(38, 33 - p.armRaise, 4, 3, robe)                                    // sleeve and fist round the staff
    c.rect(38, 35 - p.armRaise, 4, 1, robeShade)
    guard let b = beat else { return }
    // The tantrum's sparks, sputtering off the cracked crystal with each shake, and the anger mark on his head.
    let crystal = (x: sarumanCrystal.x, y: sarumanCrystal.y - Double(p.armRaise))
    for j in 0..<4 {
        let a: Double = noise(b.n * 7 + j * 3) * 2 * .pi, d: Double = 1.5 + 4.5 * b.k
        let x = crystal.x + cos(a) * d, y = crystal.y + sin(a) * d + 3 * b.k * b.k
        c.px(Int(x.rounded(.down)), Int(y.rounded(.down)), C(j % 2 == 0 ? 0xF0E8A0 : 0xFF9A3A, 0.9 * (1 - b.k)))
    }
    c.pattern(b.n % 2 == 0 ? 14 : 15, b.n % 2 == 0 ? 13 : 14, b.n % 2 == 0 ? [
        ".R.R.",
        "RR.RR",
        ".....",
        "RR.RR",
        ".R.R.",
    ] : [
        "R.R",
        "...",
        "R.R",
    ], ["R": C(0xE8302A)])
}

/// The palantír, its top-left at (`x`, `y`): a ball of dark glass. `k`, through his gaze, lights it: a light swirling
/// round inside it, his own pale violet turning to fire, until (0.45…0.7) the Eye looks back out of it, and its glow
/// lights his face.
private func drawPalantir(_ c: PixelCanvas, x: Int, y: Int, k: Double, t: Double) {
    let mid = (x: Double(x) + 3.5, y: Double(y) + 3.5)
    let lit = keyed(k, [(0.1, 0), (0.25, 1), (0.8, 1), (0.9, 0)]), fire = keyed(k, [(0.25, 0), (0.45, 1), (0.7, 1), (0.85, 0)])
    let light = mix(C(0xC8B8FF), C(0xFF7A24), fire)
    if lit > 0 {
        c.glowLine(mid.x, mid.y, mid.x, mid.y, core: light.alpha(0.2), glow: light, coreR: 0.5, glowR: 5.5,
                   strength: lit * (0.35 + 0.25 * fire))
    }
    c.pattern(x, y, [
        "..RRR..",
        ".RGGGR.",
        "RGGGGGR",
        "RGGGGGR",
        "RGGGGGR",
        ".RGGGR.",
        "..RRR..",
    ], ["G": C(0x1C1A2A), "R": C(0x3A3650)])
    c.px(x + 2, y + 2, C(0x8A86A8))                                             // a glint on the glass
    guard lit > 0 else { return }
    // The light swirling round inside it, a mote and its tail, and the glow it throws on his face.
    for i in 0..<3 {
        let a: Double = k * 3 * 5 + Double(i) * 2.09 + t
        for (back, alpha) in [(0.0, 1.0), (0.7, 0.5)] {
            let px = mid.x + 1.6 * cos(a - back), py = mid.y + 1.6 * sin(a - back)
            c.px(Int(px.rounded(.down)), Int(py.rounded(.down)), light.alpha(lit * alpha))
        }
    }
    if fire > 0.6 {
        c.pattern(x + 2, y + 2, [".o.", "OKO", ".o."], ["O": C(0xFF8A24), "o": C(0xFFD060), "K": C(0x140406)])
    }
    for (fx, fy) in [(19, 27), (19, 28), (20, 28), (19, 29), (20, 29), (19, 30), (20, 31)] {
        c.px(fx, fy, light.alpha(0.35 * lit))
    }
}

/// Sarumanual's black staff, upright in his hand and lifted `up` pixels: a claw at its head clutching the white
/// crystal. Sharkey's is bent halfway down and splintered, the claw broken and the crystal cracked and clouded.
private func drawSarumanStaff(_ c: PixelCanvas, _ w: WizardRobes, up: Int) {
    let sx = Int(sarumanCrystal.x), top = Int(sarumanCrystal.y) - up
    let foot = 43 - c.oy - up
    if w.fallen {
        let kink = top + 9
        c.rect(sx, top + 2, 1, kink - (top + 2), w.staff)
        c.rect(sx + 1, kink, 1, 4, w.staff); c.px(sx, kink, w.staffLight)
        c.rect(sx, kink + 4, 1, foot - (kink + 4) + 1, w.staff)
        c.px(sx - 1, kink + 2, w.staff); c.px(sx, top + 5, w.staffLight); c.px(sx, kink + 8, w.staffLight)
        c.pattern(sx - 2, top - 2, [
            "K....",
            "K.W..",
            "KWdWK",
            "KWwWK",
            ".KWK.",
            "..K..",
        ], ["K": w.staff, "W": C(0xB8B8B0), "w": C(0x9A9A94), "d": C(0x4A4A44)])
    } else {
        c.rect(sx, top + 2, 1, foot - (top + 2) + 1, w.staff)
        c.rect(sx, top + 2, 1, 1, w.staffLight)
        c.pattern(sx - 2, top - 2, [
            "K...K",
            "K.W.K",
            "KWWWK",
            "KWwWK",
            ".KWK.",
            "..K..",
        ], ["K": w.staff, "W": white, "w": C(0xD8E2EC)])
    }
}

/// The manual, open in his left hand; `tattered`: Sharkey's, dog-eared, stained, a page torn out and hanging loose.
private func drawManual(_ c: PixelCanvas, tattered: Bool) {
    c.pattern(8, 31, tattered ? [
        "..PPKPP..",
        "P.ppKppPP",
        "PPPPKPsPP",
        "PpppKppP.",
        "CCCCCCCCC",
    ] : [
        ".PPPKPPP.",
        "PpppKpppP",
        "PPPPKPPPP",
        "PpppKppPP",
        "CCCCCCCCC",
    ], ["P": tattered ? C(0xC8BC9C) : C(0xE8E0C8), "p": C(0x8A8270), "K": C(0x4A3A22), "C": C(0x6A4A2A),
        "s": C(0x8A6A3A)])
    if tattered { c.pattern(7, 36, ["PP", ".P"], ["P": C(0xC8BC9C)]) }        // the loose page
}

// MARK: - The ring-wraiths

private enum WraithWeapon { case flail, sword }

/// The Twitch-king, lord of the wraiths: a tall black hood with nothing inside it, a spiked iron crown over the hood,
/// a ragged robe to the ground and no legs to be seen. He fights with a flail, the spiked ball whirling on its chain
/// behind the swing. Signature: the shriek: he rears up, twitching, and screams, rings of sound pulsing out of the
/// empty hood one after another, his crown flaring a cold, ghostly white-green; then the last ring fades and he settles.
private func drawWitchKing(_ c: PixelCanvas, _ p: Pose) {
    drawWraith(c, p, crown: true, weapon: .flail, sig: p.signature)
}

/// Nazgulp, a ring-wraith: the same tall black hood and ragged robe, no crown, and deep in the hood two faint pale
/// points where eyes ought to be. He carries a long sword, held low between fights. Signature: "Bagclawds… Shire…":
/// the hood tips well forward and sniffs the air, three quick sniffs drawing curling wisps of scent into it
/// (…0.5), then leans further still as the pale points in it flare (he has the scent), and straightens up again.
private func drawNazgul(_ c: PixelCanvas, _ p: Pose) {
    drawWraith(c, p, crown: false, weapon: .sword, sig: p.signature)
}

/// A ring-wraith: the hood (crowned for the Twitch-king), the ragged robe hiding the legs, and its weapon. `sig` is how
/// far through its signature it is: the Twitch-king's shriek, or Nazgulp's sniffing.
private func drawWraith(_ c: PixelCanvas, _ p: Pose, crown: Bool, weapon: WraithWeapon, sig: Double? = nil) {
    let robe = C(0x1E1E24), robeDark = C(0x101014), rim = C(0x34343E), void = C(0x000000)
    let sig = p.melee == nil ? sig : nil
    // The shriek: how loud (0…1), the whole wraith twitching while it screams.
    let shriek: Double = crown ? sig.map { keyed($0, [(0.08, 0), (0.18, 1), (0.78, 1), (0.9, 0)]) } ?? 0 : 0
    if shriek > 0.5, let s = sig { c.ox += noise(Int(s * 90)) > 0.5 ? 1 : 0 }
    // The sniffing: how far the hood leans forward (its peak furthest), a jab for each sniff, and the scent found.
    var lean: Double = 0, found: Double = 0
    if !crown, let s = sig {
        lean = keyed(s, [(0, 0), (0.18, 7), (0.55, 7), (0.62, 12), (0.8, 12), (0.95, 0)])
        for at in [0.24, 0.34, 0.44] where s > at && s < at + 0.05 { lean += 2.5 }
        found = keyed(s, [(0.58, 0), (0.64, 1), (0.8, 1), (0.88, 0)])
    }
    let tilt = { (i: Int) -> Int in Int((lean * Double(16 - i) / 16).rounded()) }   // how far row i of the hood leans
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
    if shriek > 0.5 { c.oy -= 1 }                                              // reared up to scream
    // The hood: taller than a monk's and peaked, falling to the shoulders, the opening pure black with nothing in it.
    let outer: [Int] = [3, 4, 5, 6, 7, 8, 9, 10, 10, 11, 11, 11, 11, 11, 11, 12, 12]        // rows 18…34
    let opening: [Int] = [0, 0, 0, 0, 0, 0, 4, 5, 6, 7, 7, 7, 7, 7, 7, 6, 4]
    for (i, hw) in outer.enumerated() {
        let y = 18 + i
        c.ox += tilt(i)
        defer { c.ox -= tilt(i) }
        c.rect(28 - hw, y, hw * 2, 1, robe)
        c.px(28 - hw, y, rim); c.px(27 + hw, y, robeDark)
        if (2...6).contains(i) { c.px(30 - hw + 1, y, rim) }                       // light catching the hood
        let ow = opening[i]
        if ow > 0 {
            c.rect(27 - ow, y, ow * 2 + 2, 1, rim)
            c.rect(28 - ow, y, ow * 2, 1, void)
        }
    }
    c.ox += tilt(5); c.rect(24, 23, 8, 1, rim); c.ox -= tilt(5)
    c.rect(24, 35, 8, 1, rim)
    if crown {
        // A spiked iron crown over the hood (flaring as he shrieks).
        c.pattern(21, 16, [
            ".h...h..h...h.",
            ".I..hI..Ih..I.",
            "II..II..II..II",
            "IIIIIIIIIIIIII",
            "IhIIhIIIIhIIhI",
        ], ["I": mix(C(0x6A6E78), C(0xB8D8D0), shriek), "h": mix(C(0x9AA0AA), C(0xF0FFF8), shriek)])
        if shriek > 0 {
            let k: Double = shriek * (0.75 + 0.25 * sin(p.lt * 11))
            for sx in [22.5, 26.5, 29.5, 33.5] {
                c.glowLine(sx, 16.5, sx, 17.5, core: C(0xF0FFF8), glow: C(0x8AF0C8), coreR: 0.4, glowR: 1.8, strength: 0.6 * k)
            }
        }
    } else {
        // Two faint pale points, deep in the hood (flaring when he has the scent).
        let a: Double = 0.75 + 0.25 * sin(p.lt * 1.7)
        c.ox += tilt(11)
        c.px(24, 29, C(0x9AA4B0, a)); c.px(31, 29, C(0x9AA4B0, a))
        if found > 0 {
            for ex in [24.5, 31.5] {
                c.glowLine(ex, 29.5, ex, 29.5, core: C(0xE8F4FF), glow: C(0x9AB8D0), coreR: 0.5, glowR: 1.6, strength: found)
            }
        }
        c.ox -= tilt(11)
    }
    switch weapon {
    case .flail: drawFlail(c, p)
    case .sword: drawWraithSword(c, p)
    }
    c.rect(38, 32, 3, 5, robe); c.px(40, 36, robeDark)                         // the sleeve, an iron gauntlet out of it
    c.rect(41, 33, 2, 3, C(0x4A4E58))
    c.px(41, 33, C(0x6A6E78))
    guard let s = sig else { return }
    if crown {
        // The shriek's rings of sound, pulsing out of the hood one after another to either side, fading as they spread.
        for k in 0..<4 {
            let f = (s - 0.16 - Double(k) * 0.14) / 0.4
            guard f > 0, f < 1 else { continue }
            let r: Double = 5 + 26 * f, a: Double = 0.8 * (1 - f)
            var seen = Set<Int>()
            for side in [0.0, 180.0] {
                let n = Int(r * 2)
                for i in 0...n {
                    let u = unit(side - 50 + 100 * Double(i) / Double(n))
                    let x = Int((28 + u.x * r).rounded(.down)), y = Int((29 + u.y * r * 0.85).rounded(.down))
                    guard seen.insert(y * 1000 + x).inserted else { continue }
                    c.px(x, y, C(0xD8F0E8, side == 0 ? a : a * 0.6))
                }
            }
        }
    } else if s > 0.18 && s < 0.56 {
        // Wisps of scent drawn in from ahead, curling, into the hood.
        let mouth = (x: 33.0 + Double(tilt(11)), y: 29.0)
        for j in 0..<3 {
            let f = frac((s - 0.18) * 4 + Double(j) / 3)
            let x0: Double = mouth.x + 1 + 20 * (1 - f), y0: Double = mouth.y + Double(j - 1) * 4 * (1 - f)
            let fade: Double = min(1, (s - 0.18) / 0.05) * min(1, (0.56 - s) / 0.05) * min(1, sin(f * .pi) * 2)
            for d in 0..<8 {
                let x = x0 + Double(d), y = y0 + sin(x * 0.55 + Double(j) * 2) * 1.3
                c.px(Int(x), Int(y.rounded()), C(0xDCEAD0, 0.95 * fade * (1 - Double(d) / 9)))
            }
        }
    }
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

// MARK: - The Necro-maintainer

/// Where the Necro-maintainer's magic leaves from: the claws of his iron gauntlet, reaching out of the smoke.
private let necroHand: (x: Double, y: Double) = (43.5, 32.5)

/// The Necro-maintainer, Sourun before he had a body again, haunting Dol Guldur: a tall hood of dark purple smoke with
/// nothing solid in it, the spikes of his helm half-seen through the murk on top, two eyes burning orange in the black
/// of the hood, and below the waist no legs at all, only smoke thinning into wisps that trail out behind him, embers
/// drifting up off it. He floats. One iron gauntlet reaches out of the smoke, and his magic is a dark fire that leaves
/// its claws. Signature: he comes apart (…0.35), every wisp of him drawn off into a whirl of smoke and embers that
/// gathers round one spot, where the Eye opens, wreathed in flame, and looks about (…0.65); it shuts, and the smoke
/// streams back into the hooded shape.
private func drawNecromancer(_ c: PixelCanvas, _ p: Pose) {
    guard let s = p.signature, p.melee == nil else { drawNecroBody(c, p); return }
    // How far gone into smoke he is; each pixel of him leaves at its own moment (`n`), the last shortly after the first.
    let gone = keyed(s, [(0.04, 0), (0.35, 1), (0.65, 1), (0.96, 0)])
    guard gone > 0 else { drawNecroBody(c, p); return }
    let body = PixelCanvas(c.w, c.h)
    body.ox = c.ox; body.oy = c.oy; body.baseY = c.baseY
    drawNecroBody(body, p)
    let mid = (x: 28.0 + Double(c.ox), y: 27.0 + Double(c.oy + c.baseY))     // the Eye's spot, in canvas pixels
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    let spin: Double = s * 3.6 * 2.4
    let smoke = C(0x7A6496), ember = C(0xFF7A2A)
    for y in 0..<body.h {
        for x in 0..<body.w {
            let i = (y * body.w + x) * 4
            guard body.buf[i + 3] > 0 else { continue }
            let col = unpremultiplied(body, i)
            let n = noise(x * 31 + y * 57)
            let g = smooth(gone * 1.6 - n * 0.6)
            guard g > 0 else { c.px(x, y, col); continue }
            // Off into the whirl: an ellipse round the Eye's spot, each wisp at its own place on it. Most of him thins
            // to nothing on the way; the rest is the whirl's smoke, and a few embers.
            let a: Double = n * 2 * .pi * 13 + spin, r: Double = 13 + n * 6
            let to = (x: mid.x + cos(a) * r, y: mid.y + sin(a) * r * 0.55)
            let px = Double(x) + (to.x - Double(x)) * g, py = Double(y) + (to.y - Double(y)) * g
            let keep: Double = n < 0.3 ? 1 : 1 - g
            let tint = n < 0.06 ? ember : smoke
            c.px(Int(px.rounded(.down)), Int(py.rounded(.down)),
                 mix(col, tint, g).alpha(keep * (n < 0.06 ? 1 : 1 - 0.4 * g)))
        }
    }
    c.ox = ox; c.oy = oy; c.baseY = by
    let open = keyed(s, [(0.34, 0), (0.42, 1), (0.58, 1), (0.66, 0)])
    let look = keyed(s, [(0.43, 0), (0.46, -2), (0.5, -2), (0.53, 2), (0.56, 2), (0.6, 0)])
    drawEye(c, at: (28, 27), w: 10, h: 4.2, open: open, look: look, t: p.lt)
}

/// The Necro-maintainer himself, as he is when he isn't coming apart.
private func drawNecroBody(_ c: PixelCanvas, _ p: Pose) {
    let smoke = C(0x2A2034), rim = C(0x5E4C72), deep = C(0x140E18), void = C(0x07050A)
    let wisp = C(0x6E5C86)
    // The wisps trailing out behind, under everything else.
    for k in 0..<3 {
        let sx: Double = 21 - Double(k) * 2, sy: Double = 35 + Double(k) * 3
        for i in 0..<12 {
            let f = Double(i) / 12
            let x = sx - Double(i) * (p.walking ? 1.5 : 1.2)
            let y = sy + sin(p.lt * 2.2 + Double(i) * 0.55 + Double(k) * 2.1) * 1.4 + Double(i) * (k == 0 ? -0.25 : 0.2)
            c.px(Int(x.rounded()), Int(y.rounded()), wisp.alpha(0.6 * (1 - f)))
            if i < 6 { c.px(Int(x.rounded()), Int(y.rounded()) + 1, smoke.alpha(0.5 * (1 - f))) }
        }
    }
    c.oy += p.breathe
    // The faint helm under the hood's crown (drawn first: the smoke half covers it).
    c.pattern(16, 14, Array(sauronHelm.prefix(7)), ["K": C(0x4E4660, 0.95), "H": C(0x8E82A6)])
    // The smoke, row by row: the hood, the shoulders, then thinning out below the waist and drifting back.
    let widths: [Double] = [2, 4, 5.5, 6.5, 7.5, 8.5, 9.5, 10, 10.5, 11, 11, 11.5, 11.5,     // rows 18…30, the hood
                            12, 12.5, 13, 13, 12.5, 12,                                        // 31…36, the shoulders
                            11, 9.5, 8, 6.5, 5, 3.5, 2]                                        // 37…43, thinning out
    for (i, hw) in widths.enumerated() {
        let y = 18 + i
        let k: Double = max(0, Double(y - 33)) / 10
        let drift: Double = k * (p.walking ? 6 : 4) + sin(p.lt * 1.6 + Double(y) * 0.4) * (0.3 + k * 1.2)
        let cx: Double = 28 - drift
        let l = Int((cx - hw).rounded()), r = Int((cx + hw).rounded()) - 1
        guard r >= l else { continue }
        if y >= 40 {
            // The last rows only a dithered haze.
            for x in l...r where (x + y + Int(p.lt * 3)) % 2 == 0 { c.px(x, y, smoke.alpha(0.8 - Double(y - 40) * 0.18)) }
            continue
        }
        c.rect(l, y, r - l + 1, 1, smoke)
        c.px(l, y, rim); c.px(r, y, deep)
        // The edges never quite still: a pixel of thinner smoke flickering on either side.
        let n = Int(p.lt * 7) + y * 13
        if noise(n) > 0.4 { c.px(l - 1, y, wisp.alpha(0.5)) }
        if noise(n + 5) > 0.5 { c.px(r + 1, y, smoke.alpha(0.6)) }
        if (19...24).contains(y) { c.px(l + 1, y, rim) }                       // light catching the hood
    }
    // The murk over the crown: a veil drifting across the helm's spikes.
    for x in 16...39 {
        let a: Double = 0.15 + 0.25 * noise(x * 7 + Int(p.lt * 4))
        c.px(x, 17 + Int(noise(x + Int(p.lt * 3)) * 3), wisp.alpha(a))
    }
    // The hood's opening, black, and the two eyes burning in it.
    let opening: [Int] = [3, 5, 6, 6, 7, 7, 7, 7, 6, 4]                                   // rows 24…33
    for (i, ow) in opening.enumerated() {
        c.rect(27 - ow, 24 + i, ow * 2 + 2, 1, rim)
        c.rect(28 - ow, 24 + i, ow * 2, 1, void)
    }
    let burn: Double = 0.7 + 0.2 * sin(p.lt * 2.7) + (noise(Int(p.lt * 9)) > 0.8 ? 0.15 : 0)
    for ex in [23.0, 30.0] {
        c.glowLine(ex, 28.5, ex + 2, 28.5, core: C(0xFFD27A), glow: C(0xFF4A1E), coreR: 0.4, glowR: 1.5, strength: burn)
    }
    // Embers rising off the smoke.
    for k in 0..<3 {
        let f = frac(p.lt * 0.35 + Double(k) * 0.37)
        let x = 16 + Double(k) * 9 + sin(p.lt * 3 + Double(k)) * 1.5, y = 38 - f * 22
        c.px(Int(x.rounded()), Int(y.rounded()), C(0xFF7A2A, 0.8 * (1 - f)))
    }
    // The sleeve of smoke and the iron gauntlet out of it, lifted as he casts.
    let up = p.armRaise
    c.rect(36, 31 - up, 5, 4, smoke); c.px(36, 34 - up, deep); c.rect(37, 35 - up, 3, 1, smoke.alpha(0.6))
    c.pattern(40, 30 - up, [
        "....c",
        "..GGc",
        ".GGGGc",
        "GGgGG.",
        ".GGc.c",
    ], ["G": C(0x3A3A42), "g": C(0x5E5E6A), "c": C(0x6A6A76)])
    if p.zap != nil {
        let pulse: Double = 0.5 + 0.5 * sin(p.t * 8)
        c.glowLine(necroHand.x, necroHand.y - Double(up), necroHand.x, necroHand.y - Double(up), core: C(0xFFB050),
                   glow: C(0x8A1A30), coreR: 0.4, glowR: 2, strength: 0.4 + 0.4 * pulse)
    }
}
