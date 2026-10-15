import Foundation

// Heroes: the Riders of Rohan and the ranger of Ithilien, Clawd in costume, Clawd's orange face and ink eyes under it.
// Éowin and King Théodone wear the same Rohan kit as HEM's Éowyn (`drawRohanCloak`, `drawRohanHelmet`,
// `drawRohanShield`, `drawRohanSword` and the `rohan…` colours in Hem.swift), so they read as one people; Faramirror's
// longbow is held and drawn the way Leggolas holds and draws his. All three stand Clawd's full height.

let ringsHeroes3: [LOTRHero: Persona] = [
    .theoden: Persona(name: "King Théodone", weapon: .saber, headTop: 20, callout: "Where now the build that was green?",
                      draw: drawTheoden),
    .faramir: Persona(name: "Faramirror", weapon: .blaster, shot: .arrow, muzzle: (46, 34), handGun: false, headTop: 18,
                      callout: "My brother's PRs always got approved first.", draw: drawFaramir),
    .eowyn: Persona(name: "Éowin", weapon: .saber, headTop: 20, callout: "I am no manager!", draw: drawEowyn),
]

// MARK: - Éowin

/// Éowin, the shieldmaiden: the real one, Clawd's face under HEM's Rohan kit. The steel helmet with its gold-riveted
/// band, nose guard and white horsehair crest; long golden hair falling from under it, past the cheek pieces and down
/// her back; mail over a green tunic, the green-and-gold cloak with its clasps at the shoulders; the sun-horse shield
/// on her off arm and the Rohan sword held low in her fist, swung with a smear behind a fast stroke.
private func drawEowyn(_ c: PixelCanvas, _ p: Pose) {
    let hair = C(0xE8C860), hairShade = C(0xC8A440), hairLight = C(0xF8E498)
    drawRohanCloak(c, t: p.t, speed: p.capeSpeed)
    drawLegs(c, Look(leg: rohanTrousers), step: p.step)
    drawRiderBoots(c, p.step)
    c.oy += p.breathe
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

// MARK: - King Théodone

/// King Théodone of Rohan: older and grander than Éowin, in the same colours. Long white hair to the shoulders under a
/// gold circlet with a raised peak and an emerald, white brows, and a short white beard on the chest; a mail hauberk
/// over a green royal tunic with a gold hem and belt, and the green royal mantle over his shoulders, gold-edged, with
/// the Rohan cloak hanging down his back. No shield: the Rohan sword in his fist, held low, swung with a smear behind a
/// fast stroke.
private func drawTheoden(_ c: PixelCanvas, _ p: Pose) {
    let hair = C(0xECECE6), hairShade = C(0xC4C4BE), hairLight = C(0xFFFFFC), gem = C(0x3AB86A)
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
        "....HHHHHHHlHHHHHHHH....",
        "..HHHHHlHHHHHHHHHlHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHhHHHHHHHHHHHHHHHHhHH.",
        "HHHHHHhHHHHHHHHhHHHHHHHH",
        "HHHHh..............hHHHH",
        "HHHh................hHHH",
        "HHH..................HHH",
        "HHh..................hHH",
        "HHH..................HHH",
        ".Hh..................hH.",
        ".HH..................HH.",
    ], ["H": hair, "h": hairShade, "l": hairLight])
    // The circlet: a gold band round the brow, raised to a peak at the front, an emerald in it.
    c.rect(17, 24, 22, 1, rohanGold)
    c.pattern(25, 21, ["..GG..", ".GGGG.", "GGEEGG"], ["G": rohanGold, "E": gem])
    c.px(20, 24, C(0xFFE08A)); c.px(35, 24, C(0xFFE08A))
    // White brows, sideburns and a short beard over the mail.
    c.rect(21, 28, 4, 1, hair); c.rect(31, 28, 4, 1, hair)
    c.rect(19, 30, 2, 3, hair); c.rect(35, 30, 2, 3, hair)
    let beardRows = [
        "HHHHHHHHHHHHHH",
        "HHHhHHHHHHhHHH",
        ".HHHHHhHHHHHH.",
        "..HHhHHHHhHH..",
        "...HHHHhHH....",
        "....HhHH......",
    ]
    c.pattern(21, 32, Array(beardRows.prefix(max(0, 43 - c.oy - 32 + 1))), ["H": hair, "h": hairShade])
    c.rect(25, 32, 6, 1, hairShade)                                           // the moustache's edge
    // The sword held low, swung along `p.melee`, and the fist round its grip.
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() { drawRohanSword(c, angle: ta, alpha: 0.3 / Double(i + 1)) }
        drawRohanSword(c, angle: a)
    } else {
        drawRohanSword(c, angle: seatedPose ? 8 : 35)
    }
    c.rect(38, 33, 2, 3, rohanMail); c.rect(40, 33, 2, 3, clawdOrange); c.px(40, 35, clawdShade)
}

// MARK: - Faramirror

/// Faramirror, the ranger of Ithilien: a mottled green-brown hooded cloak, the hood up and its sides down over the
/// shoulders, a fringe of short dark hair under it; a laced leather jerkin belted over dark-green sleeves, a leather
/// bracer, dark trousers and boots; a quiver on his back with grey-goose fletchings and a dark Gondorian longbow held
/// out in front of him. Shooting, he nocks an arrow and draws the string back before each shot, as Leggolas does.
private func drawFaramir(_ c: PixelCanvas, _ p: Pose) {
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
        ".....BBBdBBBBfBBBBBB......",
        "....BBfBBBBBBBBBdBBBB.....",
        "...BBBBBBdBBBBBBBBBfBB....",
        "...BdBBBBBBBfBBBBBBBBBB...",
        "..BBBBfBBBBBBBBBBdBBBBBB..",
        "..BBBBBBBBBBBBBBBBBBfBBB..",
        ".BBdBB..............BBdBB.",
        ".BBBd................BBBB.",
        ".BfBB................dBfB.",
        "BBBB..................BBBB",
        "BdBB..................BBdB",
        "BBBf..................BBBB",
        "BBBB..................fBB.",
        ".dBB..................BBd.",
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
        if y % 3 == 0 { c.px(l + 2, y, fleck) } else if y % 4 == 1 { c.px(l + 4, y, dark) }
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
