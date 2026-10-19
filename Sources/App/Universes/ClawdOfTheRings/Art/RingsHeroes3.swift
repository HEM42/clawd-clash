import Foundation

// Heroes: the Riders of Rohan and the ranger of Ithilien, Clawd in costume, Clawd's orange face and ink eyes under it.
// Éowin and King Théodone wear the same Rohan kit as HEM's Éowyn (`drawRohanCloak`, `drawRohanHelmet`,
// `drawRohanShield`, `drawRohanSword` and the `rohan…` colours in Hem.swift), so they read as one people; Faramirror's
// longbow is held and drawn the way Leggolas holds and draws his. All three stand Clawd's full height.

let ringsHeroes3: [RingsHero: Persona] = [
    .theoden: Persona(name: "King Théodone", weapon: .saber, headTop: 20, signature: 3.0,
                      callout: "Where now the build that was green?", draw: drawTheoden),
    .faramir: Persona(name: "Faramirror", weapon: .blaster, shot: .arrow, muzzle: (46, 34), handGun: false, headTop: 18,
                      signature: 3.2, callout: "My brother's PRs always got approved first.", draw: drawFaramir),
    .eowyn: Persona(name: "Éowin", weapon: .saber, headTop: 20, signature: 3.4, callout: "I am no manager!", draw: drawEowyn),
]

// MARK: - Éowin

/// Éowin, the shieldmaiden: the real one, Clawd's face under HEM's Rohan kit. The steel helmet with its gold-riveted
/// band, nose guard and white horsehair crest; long golden hair falling from under it, past the cheek pieces and down
/// her back; mail over a green tunic, the green-and-gold cloak with its clasps at the shoulders; the sun-horse shield
/// on her off arm and the Rohan sword held low in her fist, swung with a smear behind a fast stroke. Signature: "I am
/// no manager!": she drives her sword point-down into the ground, reaches up and lifts her helmet off, and holds it
/// up high in her fist while her golden hair spills free, a mane of it over her head and down past her waist, lifting
/// in the wind; then the helmet goes back on over it and she takes up her sword again (`eowinMove`).
private func drawEowyn(_ c: PixelCanvas, _ p: Pose) {
    let hair = C(0xE8C860), hairShade = C(0xC8A440), hairLight = C(0xF8E498)
    let m = p.signature.map(eowinMove)
    drawRohanCloak(c, t: p.t, speed: p.capeSpeed)
    drawLegs(c, Look(leg: rohanTrousers), step: p.step)
    drawRiderBoots(c, p.step)
    let standing = c.oy
    c.oy += p.breathe
    if let m = m {
        drawEowinUnhelmed(c, p, m, standing: standing)
        return
    }
    drawBody(c, Look(arm: rohanMail))
    drawRohanMail(c)
    // The cloak over the shoulders, gold-edged, and its clasps.
    c.rect(18, 33, 2, 5, rohanCloak); c.rect(20, 33, 1, 5, rohanGold)
    c.rect(36, 33, 2, 5, rohanCloak); c.rect(35, 33, 1, 5, rohanGold)
    c.px(20, 33, C(0xFFE08A)); c.px(35, 33, C(0xFFE08A))
    // Long golden hair: down her back behind the shield, and a lock past the cheek piece on the near side.
    c.pattern(13, 26, [
        "...HHH", "..HHhH", ".HHhHH", "HHhHHH", "HhHHHl", "HHHhH.", "HhHHH.", "HHHh..", ".HhH..", ".HHH..", "..Hh..",
    ], ["H": hair, "h": hairShade, "l": hairLight])
    c.pattern(36, 26, ["HHHH", "hHHH", "HhHHl", "HlHHH", ".HHhH", ".hHHl", ".HhH.", "..HH.", "..H.."],
              ["H": hair, "h": hairShade, "l": hairLight])
    c.rect(19, 26, 3, 1, hair); c.rect(34, 26, 3, 1, hair); c.px(19, 27, hairShade); c.px(36, 27, hairShade)   // the fringe
    drawRohanHelmet(c, t: p.t, strand: false)
    // The sword held low, swung along `p.melee`; the fist round its grip; the shield on the off arm.
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() { drawRohanSword(c, angle: ta, alpha: 0.3 / Double(i + 1)) }
        drawRohanSword(c, angle: a)
    } else {
        drawRohanSword(c, angle: seatedPose ? 8 : 35)
    }
    c.rect(38, 33, 2, 3, rohanMail); c.rect(40, 33, 2, 3, clawdOrange); c.px(40, 35, clawdShade)
    drawRohanShield(c, cx: 14, cy: seatedPose ? 33 : 35)
}

/// Where Éowin is in her signature: how far her sword has turned from her guard to point-down in the ground (`plant`,
/// 0…1) and whether her hand has let go of it, how high her fist is (`up` px), how far the helmet is lifted off her
/// head (`rise` px), and how far her hair has spilled free (`hair`, 0…1).
private struct EowinMove {
    var plant = 0.0, letGo = false, up = 0, rise = 0, hair = 0.0
    var wind = 0   // the ends of her loose hair, lifted back a pixel in a gust
}

/// How high Éowin holds her helmet up (px above her head).
private let eowinHold = 10

/// Éowin `s` through her signature: the sword planted (…0.08), the fist up to the helmet (…0.16), the helmet lifted
/// off (…0.3) and the hair spilling out (0.2…0.34), held up high (…0.78), put back on over the hair (…0.87), the fist
/// down to the sword (…0.93) and the sword taken up again.
private func eowinMove(_ s: Double) -> EowinMove {
    var m = EowinMove()
    m.plant = s < 0.08 ? smooth(s / 0.08) : s < 0.93 ? 1 : 1 - smooth((s - 0.93) / 0.07)
    m.letGo = s >= 0.08 && s < 0.93
    let lift: Double = s < 0.16 ? 0 : s < 0.3 ? smooth((s - 0.16) / 0.14) : s < 0.78 ? 1 : s < 0.87 ? 1 - smooth((s - 0.78) / 0.09) : 0
    let reach: Double = s < 0.08 ? 0 : s < 0.16 ? smooth((s - 0.08) / 0.08) : s < 0.87 ? 1 : s < 0.93 ? 1 - smooth((s - 0.87) / 0.06) : 0
    m.rise = Int((lift * Double(eowinHold)).rounded())
    m.up = Int((reach * 7).rounded()) + m.rise
    m.hair = s < 0.2 ? 0 : s < 0.34 ? smooth((s - 0.2) / 0.14) : s < 0.8 ? 1 : s < 0.86 ? 1 - smooth((s - 0.8) / 0.06) : 0
    if m.hair > 0.9 && Int(s * 17) % 2 == 0 { m.wind = -1 }
    return m
}

/// Éowin in her signature, `m`, from the body up (`standing`: the canvas offset under the breathing, where the
/// planted sword stays).
private func drawEowinUnhelmed(_ c: PixelCanvas, _ p: Pose, _ m: EowinMove, standing: Int) {
    let hair = C(0xE8C860), hairShade = C(0xC8A440), hairLight = C(0xF8E498)
    let pal: [Character: Px] = ["H": hair, "h": hairShade, "l": hairLight]
    drawBody(c, Look(arm: rohanMail))
    drawRohanMail(c)
    c.rect(18, 33, 2, 5, rohanCloak); c.rect(20, 33, 1, 5, rohanGold)
    c.rect(36, 33, 2, 5, rohanCloak); c.rect(35, 33, 1, 5, rohanGold)
    c.px(20, 33, C(0xFFE08A)); c.px(35, 33, C(0xFFE08A))
    // Her hair down her back and the lock in front, growing longer as it spills out, its ends lifting in the wind.
    if m.hair == 0 {
        c.pattern(13, 26, [
            "...HHH", "..HHhH", ".HHhHH", "HHhHHH", "HhHHHl", "HHHhH.", "HhHHH.", "HHHh..", ".HhH..", ".HHH..", "..Hh..",
        ], pal)
        c.pattern(36, 26, ["HHHH", "hHHH", "HhHHl", "HlHHH", ".HHhH", ".hHHl", ".HhH.", "..HH.", "..H.."], pal)
    } else {
        let back = [
            "...HHH", "..HHhH", ".HHhHH", "HHhHHH", "HhHHHl", "HHHhHH", "HhHHHl", "HHHhH.", "lHhHH.", "HHHH..", "HhHH..",
            "HHlH..", "HHHh..", ".HhH..", ".HHH..", "..Hh..", "..H...",
        ]
        let rows = Array(back.prefix(11 + Int((6 * m.hair).rounded())))
        c.pattern(13, 26, Array(rows.prefix(9)), pal)
        c.pattern(13 + m.wind, 35, Array(rows.dropFirst(9)), pal)
        let front = ["HHHH", "hHHH", "HhHHl", "HlHHH", ".HHhH", ".hHHl", ".HhHH", "..HHh", "..HhH", "..HHl", "...HH", "...Hh", "...H."]
        c.pattern(36, 26, Array(front.prefix(9 + Int((4 * m.hair).rounded()))), pal)
    }
    if m.rise > 0 {
        // Out from under the helmet: a mane of gold over her head, parted, falling past her face to the shoulders.
        c.pattern(16, 20, [
            "........HHHlHHHH........",
            ".....HHHHHlHHHhHHHH.....",
            "...HHHHhHHHHHHHHHHHHH...",
            "..HHHHHHHHHhHHHHHHlHHH..",
            ".HHhHHHHHHHHhHHHHHHHHhH.",
            "HHHHHHlHHHHHHhHHHHHHHHHH",
            "HHHhHHH...........HHhHHH",
            "HHHh................hHHH",
            "HlH..................HHl",
            "HHH..................HhH",
            "HhH..................HHH",
            "HHl..................lHH",
            "HHH..................HHH",
            ".Hh..................hH.",
        ], pal)
    } else {
        c.rect(19, 26, 3, 1, hair); c.rect(34, 26, 3, 1, hair); c.px(19, 27, hairShade); c.px(36, 27, hairShade)
    }
    // The helmet, lifted off in her fist and drawn a little forward with it.
    let oxHere = c.ox
    c.ox += min(2, m.rise)
    drawRohanHelmet(c, t: p.t, rise: m.rise, strand: false)
    c.ox = oxHere
    // The sword: in her fist, turned point-down; let go, it stands in the ground where she drove it.
    let angle = 35 + 55 * m.plant
    if m.letGo {
        let oy = c.oy
        c.oy = standing
        drawPlantedSword(c, angle: angle, ground: 43 + standing)
        c.oy = oy
        c.rect(38, 33 - m.up, 2, 3 + m.up, rohanMail); c.rect(38, 33 - m.up, 1, 3 + m.up, rohanMailLight)
        c.rect(40, 33 - m.up, 2, 3, clawdOrange); c.px(40, 35 - m.up, clawdShade)
    } else {
        drawPlantedSword(c, angle: angle, ground: 43 + standing)
        c.rect(38, 33, 2, 3, rohanMail); c.rect(40, 33, 2, 3, clawdOrange); c.px(40, 35, clawdShade)
    }
    drawRohanShield(c, cx: 14, cy: 35)
}

/// The Rohan sword at `angle`, nothing of it drawn below row `ground` (the point is in the earth).
private func drawPlantedSword(_ c: PixelCanvas, angle: Double, ground: Int) {
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    drawRohanSword(s, angle: angle)
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    defer { c.ox = ox; c.oy = oy; c.baseY = by }
    for y in 0..<min(s.h, ground + by + 1) {
        for x in 0..<s.w {
            let i = (y * s.w + x) * 4
            guard s.buf[i + 3] > 0 else { continue }
            c.px(x, y, unpremultiplied(s, i))
        }
    }
}

// MARK: - King Théodone

/// King Théodone of Rohan: older and grander than Éowin, in the same colours. Long white hair to the shoulders under a
/// gold circlet with a raised peak and an emerald, white brows, and a short white beard on the chest; a mail hauberk
/// over a green royal tunic with a gold hem and belt, and the green royal mantle over his shoulders, gold-edged, with
/// the Rohan cloak hanging down his back. No shield: the Rohan sword in his fist, held low, swung with a smear behind a
/// fast stroke. Signature: "Forth, Eorlingas!": he swings the sword up high over his head, the gold circlet flashing,
/// and shouts the charge, brows down hard and mouth wide in his beard, the blade shaking up there and the shout
/// ringing out in front of him; then he lowers it again.
private func drawTheoden(_ c: PixelCanvas, _ p: Pose) {
    let hair = C(0xECECE6), hairShade = C(0xC4C4BE), hairLight = C(0xFFFFFC), gem = C(0x3AB86A)
    let shout = p.signature.map { $0 > 0.17 && $0 < 0.8 } ?? false
    drawRohanCloak(c, t: p.t, speed: p.capeSpeed)
    drawLegs(c, Look(leg: rohanTrousers), step: p.step)
    drawRiderBoots(c, p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: rohanMail))
    drawRohanMail(c, hem: rohanGold)
    c.rect(18, 37, 20, 1, C(0x5A4430)); c.rect(27, 37, 2, 1, rohanGold)      // the belt and its gold buckle
    // The royal mantle over the shoulders, gold-edged, with gold brooches.
    c.rect(17, 32, 3, 6, rohanCloak); c.rect(20, 32, 1, 6, rohanGold)
    c.rect(36, 32, 2, 6, rohanCloak); c.rect(35, 32, 1, 6, rohanGold)
    c.rect(20, 32, 2, 2, C(0xFFE08A)); c.rect(34, 32, 2, 2, C(0xFFE08A))
    // Long white hair, combed back to the shoulders, the sides outside the face.
    c.pattern(16, 20, [
        ".......HHHHHHHHHH.......",
        "....HHHHHHlllHHHHHHH....",
        "..HHHHlllHHHHHHHlllHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHhHHHHHHHHHHHHHHHHhHH.",
        "HHHhHHhhHHHHHHhhHHHHhHHH",
        "HHHhh..............hhHHH",
        "HHHh................hHHH",
        "HHh..................hHH",
        "HHh..................hHH",
        "HHH..................HHH",
        ".Hh..................hH.",
        ".Hh..................hH.",
    ], ["H": hair, "h": hairShade, "l": hairLight])
    // The circlet: a gold band round the brow, raised to a peak at the front, an emerald in it.
    c.rect(17, 24, 22, 1, rohanGold)
    c.pattern(25, 21, ["..GG..", ".GGGG.", "GGEEGG"], ["G": rohanGold, "E": gem])
    c.px(20, 24, C(0xFFE08A)); c.px(35, 24, C(0xFFE08A))
    if let s = p.signature { drawCircletFlash(c, s) }
    // White brows (drawn down hard while he shouts), sideburns and a short beard over the mail.
    if shout {
        c.rect(21, 27, 2, 1, hair); c.rect(23, 28, 2, 1, hair); c.rect(31, 28, 2, 1, hair); c.rect(33, 27, 2, 1, hair)
    } else {
        c.rect(21, 28, 4, 1, hair); c.rect(31, 28, 4, 1, hair)
    }
    c.rect(19, 30, 2, 3, hair); c.rect(35, 30, 2, 3, hair)
    let beardRows = [
        "HHHHHHHHHHHHHH",
        "HHHhHHHHHHhHHH",
        ".HHhHHhHHHhHH.",
        "..HHHHhHHHHH..",
        "...HHHHhHH....",
        "....HHhH......",
    ]
    c.pattern(21, 32, Array(beardRows.prefix(max(0, 43 - c.oy - 32 + 1))), ["H": hair, "h": hairShade])
    c.rect(25, 32, 6, 1, hairShade)                                           // the moustache's edge
    if shout { c.rect(26, 33, 4, 2, C(0x4A2018)); c.rect(27, 35, 2, 1, C(0x4A2018)) }   // the mouth, wide open
    if let s = p.signature {
        drawTheodenCharge(c, s)
        return
    }
    // The sword held low, swung along `p.melee`, and the fist round its grip.
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() { drawRohanSword(c, angle: ta, alpha: 0.3 / Double(i + 1)) }
        drawRohanSword(c, angle: a)
    } else {
        drawRohanSword(c, angle: seatedPose ? 8 : 35)
    }
    c.rect(38, 33, 2, 3, rohanMail); c.rect(40, 33, 2, 3, clawdOrange); c.px(40, 35, clawdShade)
}

/// How high Théodone's sword arm is up `s` through his signature, 0…1: swung up (…0.15), held, lowered (0.82…0.96).
private func theodenRaise(_ s: Double) -> Double {
    if s < 0.15 { return smooth(s / 0.15) }
    if s < 0.82 { return 1 }
    return 1 - smooth((s - 0.82) / 0.14)
}

/// Théodone's sword arm `s` through his signature: the sword swung up from his guard to high over his head, a smear
/// behind it on the way up, shaken while he shouts, a glint at its point as it gets there; the shout ringing out in
/// front of him in three strokes that pulse outward.
private func drawTheodenCharge(_ c: PixelCanvas, _ s: Double) {
    let k = theodenRaise(s), up = Int((9 * k).rounded())
    let shout = s > 0.17 && s < 0.8
    var angle = 35 - 120 * k
    if shout { angle += 5 * sin((s - 0.17) * 60) }
    let oy = c.oy
    c.oy -= up
    if s > 0.03 && s < 0.15 {
        for (i, d) in [0.025, 0.05].enumerated() {
            let back = theodenRaise(s - d)
            drawRohanSword(c, angle: 35 - 120 * back, alpha: 0.3 / Double(i + 1))
        }
    }
    drawRohanSword(c, angle: angle)
    c.oy = oy
    c.rect(38, 33 - up, 2, 3 + up, rohanMail); c.rect(38, 33 - up, 1, 3 + up, rohanMailLight)
    c.rect(40, 33 - up, 2, 3, clawdOrange); c.px(40, 35 - up, clawdShade)
    // The glint at the sword's point as it gets to the top.
    let tip = (x: Sprite.hand.x + cos(angle * .pi / 180) * 15, y: Sprite.hand.y - Double(up) + sin(angle * .pi / 180) * 15)
    drawGlint(c, Int(tip.x), Int(tip.y), bump(s, at: 0.17, width: 0.07))
    guard shout else { return }
    let beat = Int((s - 0.17) * 20) % 2, a: Double = s > 0.72 ? (0.8 - s) / 0.08 : 1
    let col = C(0xFFFFFF, 0.85 * a)
    for (x0, y0, dx, dy) in [(44, 27, 1, -1), (45, 31, 1, 0), (44, 35, 1, 1)] {
        let x = x0 + beat * dx, y = y0 + beat * dy
        c.px(x, y, col); c.px(x + dx, y + dy, col)
        if dy == 0 { c.px(x + 2, y, col.alpha(0.6)) } else { c.px(x + 2 * dx, y + 2 * dy, col.alpha(0.6)) }
    }
}

/// The flash of Théodone's gold circlet `s` through his signature: a glint off the peak as the sword goes up, the
/// band catching the light, and again as he shouts.
private func drawCircletFlash(_ c: PixelCanvas, _ s: Double) {
    let k = max(bump(s, at: 0.2, width: 0.09), bump(s, at: 0.5, width: 0.07))
    guard k > 0.05 else { return }
    c.rect(17, 24, 22, 1, C(0xFFE08A, k))
    c.pattern(25, 21, ["..GG..", ".G..G.", "G....G"], ["G": C(0xFFF4C8, k)])
    drawGlint(c, 27, 21, k)
}

/// A four-pointed glint at (`x`, `y`), `k` 0…1 how bright, its points longer the brighter it is.
private func drawGlint(_ c: PixelCanvas, _ x: Int, _ y: Int, _ k: Double) {
    guard k > 0.05 else { return }
    let reach = 1 + Int((k * 2.5).rounded())
    for d in 1...reach {
        let a = k * (1 - Double(d - 1) / Double(reach + 1))
        let col = C(0xFFF4C8, a)
        c.px(x + d, y, col); c.px(x - d, y, col); c.px(x, y + d, col); c.px(x, y - d, col)
    }
    c.px(x, y, C(0xFFFFFF, min(1, k * 1.3)))
}

/// 1 at `at`, falling to 0 `width` either side of it.
private func bump(_ s: Double, at: Double, width: Double) -> Double {
    max(0, 1 - abs(s - at) / width)
}

// MARK: - Faramirror

/// Faramirror, the ranger of Ithilien: a mottled green-brown hooded cloak, the hood up and its sides down over the
/// shoulders, a fringe of short dark hair under it; a laced leather jerkin belted over dark-green sleeves, a leather
/// bracer, dark trousers and boots; a quiver on his back with grey-goose fletchings and a dark Gondorian longbow held
/// out in front of him. Shooting, he nocks an arrow and draws the string back before each shot, as Leggolas does.
/// Signature: Faramirror's mirror: a silvery reflection of him shimmers into being just in front of him, facing him, a
/// light sweeping across it as if off glass; he hops, and it hops, then he raises his bow, nocks and draws, and it does
/// the same, always a beat behind (a mirror that's lagging its sync); then it fades.
private func drawFaramir(_ c: PixelCanvas, _ p: Pose) {
    guard let s = p.signature else { drawFaramirBody(c, p, nil); return }
    let shown = faramirTwin(s)
    if shown > 0 { drawFaramirTwin(c, p, faramirMove(max(0, s - 0.07)), shown: shown, s: s) }
    drawFaramirBody(c, p, faramirMove(s))
}

/// What Faramirror (and his reflection) are doing in the signature: a hop (`hop` px up), the bow raised `lift` px,
/// an arrow on the string (`nocked`), drawn back `pull` px.
private struct FaramirMove {
    var hop = 0, lift = 0, pull = 0, nocked = false
}

/// Faramirror `s` through his signature: a hop (0.26…0.4), then the bow up (0.46…0.52), an arrow nocked and drawn
/// (…0.62), held, eased off and the bow lowered (0.7…0.78).
private func faramirMove(_ s: Double) -> FaramirMove {
    var m = FaramirMove()
    if s > 0.26 && s < 0.4 { m.hop = Int((2.4 * sin((s - 0.26) / 0.14 * .pi)).rounded()) }
    let bow: Double = s < 0.46 ? 0 : s < 0.52 ? (s - 0.46) / 0.06 : s < 0.7 ? 1 : s < 0.78 ? 1 - (s - 0.7) / 0.08 : 0
    m.lift = Int((3 * bow).rounded())
    m.nocked = s > 0.5 && s < 0.72
    if m.nocked { m.pull = Int((3 * min(1, max(0, (s - 0.53) / 0.09))).rounded()) }
    return m
}

/// How strongly the reflection shows `s` through the signature, 0…1: shimmering in (0.06…0.2), there, fading
/// (0.84…0.97).
private func faramirTwin(_ s: Double) -> Double {
    if s < 0.06 || s > 0.97 { return 0 }
    if s < 0.2 { return smooth((s - 0.06) / 0.14) }
    if s > 0.84 { return 1 - smooth((s - 0.84) / 0.13) }
    return 1
}

/// The reflection: Faramirror in the move `m` (a beat behind his own), mirrored about x = 41 so it stands just in
/// front of him facing him, washed silvery-blue and see-through (`shown` 0…1); a bright band sweeps across it as it
/// appears, like light off a pane of glass.
private func drawFaramirTwin(_ c: PixelCanvas, _ p: Pose, _ m: FaramirMove, shown: Double, s: Double) {
    let t = PixelCanvas(c.w, c.h)
    t.ox = c.ox; t.oy = c.oy; t.baseY = c.baseY
    drawFaramirBody(t, p, m)
    let axis = 81 + 2 * c.ox
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    defer { c.ox = ox; c.oy = oy; c.baseY = by }
    let sweep: Double? = s < 0.28 ? 30 + (s - 0.06) / 0.22 * 70 : nil
    for y in 0..<t.h {
        for x in 0..<t.w {
            let i = (y * t.w + x) * 4
            guard t.buf[i + 3] > 0 else { continue }
            var col = unpremultiplied(t, i)
            var silver = 0.45
            if let b = sweep, abs(Double(axis - x) + Double(y) * 0.6 - b) < 2 { silver = 0.85 }
            col.r = UInt8(Double(col.r) + (200 - Double(col.r)) * silver)
            col.g = UInt8(Double(col.g) + (220 - Double(col.g)) * silver)
            col.b = UInt8(Double(col.b) + (240 - Double(col.b)) * silver)
            c.px(axis - x, y, col.alpha(0.6 * shown))
        }
    }
}

/// Faramirror in the move `m` (nil: none, the pose as it comes).
private func drawFaramirBody(_ c: PixelCanvas, _ p: Pose, _ m: FaramirMove?) {
    if let m = m { c.oy -= m.hop }
    let mottle = C(0x5A6238), mottleDark = C(0x3E4628), mottleBrown = C(0x6E5A3A)
    let sleeve = C(0x3A4A2E), leather = C(0x7A5232), leatherDark = C(0x5A3C24), leatherLight = C(0x96693E)
    let hair = C(0x2A1E16), hairLight = C(0x46342A)
    drawRangerCape(c, t: p.t, speed: p.capeSpeed, color: mottle, dark: mottleDark, fleck: mottleBrown)
    drawLegs(c, Look(leg: C(0x3A3226)), step: p.step)
    drawBoots3(c, p.step, C(0x241A12))
    c.oy += p.breathe
    // The quiver, slung over his back, grey fletchings over his shoulder.
    c.pattern(10, 17, [
        "W.G.....",
        "GW.W....",
        ".GWG....",
        "..QQQ...",
        "..QQQq..",
        "...QQQq.",
        "...QQQQ.",
        "....QQQq",
        "....QQQQ",
    ], ["G": C(0x8A8A80), "W": C(0xE0DCD0), "Q": C(0x4E3420), "q": C(0x36241A)])
    drawBody(c, Look(arm: sleeve))
    // The leather jerkin, laced up the front, to mid-thigh, and its belt.
    c.rect(18, 32, 20, 6, leather)
    c.rect(37, 32, 1, 6, leatherDark)
    c.rect(18, 32, 20, 1, leatherLight)
    for y in 38...39 where y + c.oy <= 43 { c.rect(18, y, 20, 1, leather); c.px(28, y, leatherDark); c.px(37, y, leatherDark) }
    for y in [33, 35] { c.px(27, y, leatherLight); c.px(29, y, leatherLight) }
    c.px(28, 34, leatherLight)                                                 // the lacing
    c.rect(18, 36, 20, 1, C(0x2E2018)); c.px(24, 36, C(0x9A8A6A))            // the belt and its buckle
    c.rect(15, 33, 3, 3, sleeve)
    // The hood, up, mottled green and brown, its sides falling to the shoulders; short dark hair under its brim.
    c.pattern(15, 18, [
        ".......BBBBBBBBBBB........",
        ".....BBddBBBBffBBBBB......",
        "....BffBBBBBBBBddBBBB.....",
        "...BBBBBddBBBBBBBBffBB....",
        "...BddBBBBBBffBBBBBBBBB...",
        "..BBBffBBBBBBBBBBddBBBBB..",
        "..BBBBBBBBBBBBBBBBBffBBB..",
        ".BddBB..............BddBB.",
        ".BBBB................BBBB.",
        ".BffB................ddBB.",
        "BBBB..................BBBB",
        "BddB..................BddB",
        "BBff..................BBBB",
        "BBBB..................ffB.",
        ".ddB..................Bdd.",
    ], ["B": mottle, "d": mottleDark, "f": mottleBrown])
    c.rect(21, 25, 14, 1, hair); c.px(24, 25, hairLight); c.px(30, 25, hairLight)
    c.rect(19, 26, 2, 1, hair); c.rect(35, 26, 2, 1, hair)
    // The longbow, held out at arm's length; an arrow on the string while he aims, drawn back before he shoots.
    var pull = 0, nocked = p.ready
    if let f = p.fire {
        let ph = frac(f.t / p.firePeriod)
        nocked = ph >= 0.45
        if ph > 0.6 { pull = Int(((ph - 0.6) / 0.4 * 3).rounded()) }
    }
    if let m = m { pull = m.pull; nocked = m.nocked; c.oy -= m.lift }
    c.oy += p.gunY + (seatedPose ? -3 : 0)
    drawRangerBow(c, pull: pull)
    c.rect(38, 33, 2, 2, sleeve); c.rect(40, 33, 2, 2, leatherDark)           // the sleeve and the bracer
    c.rect(42, 33, 2, 3, clawdOrange)
    if nocked {
        let tail = 40 - pull
        c.rect(tail, 34, 47 - tail, 1, C(0x5A4430))
        c.px(47, 34, C(0xC8CCD4)); c.px(48, 34, C(0xE8ECF4))
        c.px(tail, 33, C(0xE0DCD0)); c.px(tail, 35, C(0x8A8A80))
        c.rect(tail - 1, 34, 2, 2, clawdOrange)                                // the hand on the string
    }
}

/// Faramirror's longbow, dark Gondorian wood, gripped at (43, 34), the string back at x 40 and drawn back `pull`
/// pixels more at the middle: the same bow shape as Leggolas', darker.
private func drawRangerBow(_ c: PixelCanvas, pull: Int = 0) {
    let limb = C(0x4E3A28), limbDark = C(0x36281C), grip = C(0x8A6A44), string = C(0xE0E0E8)
    for y in 24...44 where y + c.oy <= 43 {
        let d = abs(y - 34)
        let x = d <= 2 ? 44 : d <= 5 ? 43 : d <= 8 ? 42 : 41
        c.px(x, y, d <= 1 ? grip : d % 3 == 0 ? limbDark : limb)
        if d == 10 { c.px(x - 1, y, limb) }
    }
    for y in 25...43 where y + c.oy <= 43 {
        let d = Double(abs(y - 34)) / 9
        c.px(40 - Int((Double(pull) * (1 - d)).rounded()), y, string)
    }
}

/// The ranger's cloak hanging down his back, seen from the side, mottled with darker and brown flecks; its hem sways at
/// `speed`.
private func drawRangerCape(_ c: PixelCanvas, t: Double, speed: Double, color: Px, dark: Px, fleck: Px) {
    let hem = 42, last = min(hem, 43 - c.oy)
    guard last >= 27 else { return }
    for y in 27...last {
        let k = Double(y - 27) / Double(hem - 27)
        let sway = sin(t * speed + k * 2.2) * k * 1.6
        let l = Int((15.5 - k * 3.5 + sway).rounded()), r = 24 + Int((k * 2).rounded())
        c.rect(l, y, r - l + 1, 1, color)
        c.px(l, y, dark)
        if y % 3 == 0 { c.rect(l + 2, y, 2, 1, fleck) } else if y % 4 == 1 { c.rect(l + 4, y, 2, 1, dark) }
    }
}

// MARK: - Shared helpers

/// Mail from the shoulders to the waist (the body's top rows 34–36, checked light), and a green tunic below it to
/// mid-thigh; `hem`: a trim colour along its bottom row.
private func drawRohanMail(_ c: PixelCanvas, hem: Px? = nil) {
    c.rect(18, 33, 20, 4, rohanMail); c.rect(37, 33, 1, 4, rohanMailDark)
    for y in 34...36 { for x in 18...36 where (x + y) % 2 == 0 { c.px(x, y, rohanMailLight) } }
    c.rect(18, 37, 20, 1, rohanTunic)
    for y in 38...39 where y + c.oy <= 43 {
        c.rect(18, y, 20, 1, y == 39 ? hem ?? rohanTunic : rohanTunic); c.px(27, y, rohanTunicDark); c.px(37, y, rohanTunicDark)
    }
}

/// Rohan's riding boots over the bottom three rows of each leg, as HEM's Éowyn wears them.
private func drawRiderBoots(_ c: PixelCanvas, _ step: Int) {
    drawBoots3(c, step, rohanBoot)
}

/// Boots over the bottom three rows of each leg (a bit of the folded foot when sitting).
private func drawBoots3(_ c: PixelCanvas, _ step: Int, _ col: Px) {
    if seatedPose {
        for lx in [19, 23, 31, 35] { c.rect(lx + 1, 38, 2, 2, col) }
        return
    }
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        let bottom = step >= 0 && i % 2 == step ? 42 : 43
        c.rect(lx, bottom - 2, 2, 3, col)
    }
}

/// Smoothstep: 0→1 eased at both ends.
private func smooth(_ x: Double) -> Double {
    let u = min(1, max(0, x))
    return u * u * (3 - 2 * u)
}
