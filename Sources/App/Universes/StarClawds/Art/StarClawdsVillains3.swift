import Foundation

// Star Wars villains: the third wave, Watto to Reva. Ported from Clawd Wars: the costumes from `Recruits.swift`, the
// capes, jetpack, sabers and blasters from `drawLeader`.

let starWarsVillains3: [SWVillain: Persona] = [
    .watto: Persona(name: "Whatto", canSit: false, headTop: 11, callout: "No credits, no bolts, no bargain!",
                  draw: drawWatto),
    .moffGideon: Persona(name: "Moff Giddyup", weapon: .saber, headTop: 22,
                  draw: drawMoffGideon),
    .deathTrooper: Persona(name: "Dearth Trooper", weapon: .blaster, armoured: true, muzzle: (52, 32), headTop: 19,
                  draw: drawDeathTrooper),
    .scoutTrooper: Persona(name: "Scoot Trooper", weapon: .blaster, armoured: true, canSit: false, muzzle: (50, 33), handGun: false,
                  headTop: 12, draw: drawScoutTrooper),
    .ventress: Persona(name: "Asaj Vengress", weapon: .saber, headTop: 22,
                  draw: drawVentress),
    .savageOpress: Persona(name: "Savage Distress", weapon: .saber, headTop: 20,
                  draw: drawSavageOpress),
    .jangoFett: Persona(name: "Django Feta", weapon: .blaster, armoured: true, muzzle: (47, 32), headTop: 19,
                  draw: drawJangoFett),
    .bossk: Persona(name: "Boss-K", weapon: .blaster, muzzle: (52, 32), headTop: 21,
                  draw: drawBossk),
    .dengar: Persona(name: "Dangar", weapon: .blaster, muzzle: (54, 32), headTop: 19,
                  draw: drawDengar),
    .droideka: Persona(name: "Rolladeka", weapon: .blaster, armoured: true, canSit: false, muzzle: (49, 31), handGun: false,
                  headTop: 18, draw: drawDroideka),
    .phasma: Persona(name: "Captain Plasma", weapon: .blaster, armoured: true, muzzle: (52, 32), headTop: 19, signature: 1.4,
                  draw: drawPhasma),
    .krennic: Persona(name: "Director Crankic", weapon: .blaster, muzzle: (47, 32), headTop: 22,
                  draw: drawKrennic),
    .tarkin: Persona(name: "Governor Tarquin", headTop: 22, callout: "Fire at will, whenever you like.",
                  draw: drawTarkin),
    .fifthBrother: Persona(name: "Fifth Brother", weapon: .saber, headTop: 22,
                  draw: drawFifthBrother),
    .reva: Persona(name: "Rava", weapon: .saber, headTop: 22,
                  draw: drawReva),
]

// MARK: - Shared

private let clear = C(0, 0)
private let redCore = C(0xFFE3E3), redGlow = C(0xFF1E2D)

/// An E-11 blaster rifle in the right hand (Clawd Wars' default villain gun); its muzzle is at (x + 15, y + 2).
private func drawE11(_ c: PixelCanvas, x: Int, y: Int) {
    c.pattern(x, y, [
        "......SSSL.....",
        ".......K.K.....",
        "KK.KKKKKKKKKKKK",
        "KKKKKKkKkKkKKK.",
        "....KK..MM.....",
        "....KK..MM.....",
    ], ["S": C(0x2C2C33), "L": C(0x7FC8FF), "K": C(0x1E1E24), "k": C(0x5A5A64), "M": C(0x3A3A42)])
}

/// A Mandalorian helmet: the T visor, with markings either side of it.
private func drawMandoHelmet(_ c: PixelCanvas, _ main: Px, _ shine: Px, marks: Px? = nil) {
    c.pattern(17, 19, [
        ".....HHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHH...",
        "..HHhhHHHHHHHHHHHHHH..",
        ".HHhHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHMMMHHHHHHHHHHHHMMMHH",
        "HHHMMKKKKKKKKKKKKMMHHH",
        "HHHHHKKKKKKKKKKKKHHHHH",
        "HHHHHHHHHKKKKHHHHHHHHH",
        "HHHHHHHHHKKKKHHHHHHHHH",
        "HHHHHHHHHKKKKHHHHHHHHH",
        ".HHHHHHHHKKKKHHHHHHHH.",
        "..HHHHHHHHHHHHHHHHHH..",
    ], ["H": main, "h": shine, "K": ink, "M": marks ?? main])
}

/// A glint of light down the front of each boot (not when sitting), lifting with the leg as it steps.
private func drawBootShine(_ c: PixelCanvas, step: Int, _ col: Px) {
    guard !seatedPose else { return }
    for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx, step >= 0 && i % 2 == step ? 40 : 41, col) }
}

/// The ring-shaped hilt of an Inquisitor's saber, 5×5 from (x, y).
private func drawInquisitorRing(_ c: PixelCanvas, x: Int, y: Int) {
    c.pattern(x, y, [".SSS.", "S...S", "S...S", "S...S", ".SSS."], ["S": C(0x9AA0AA)])
}

/// An Inquisitor's ring saber: two short red blades on the ring, lit at `p.melee`, or the ring at the belt. Its
/// flourish is a burst of rotor spin rather than the usual twirl, and it spins like a rotor while it waits or stands
/// guard.
private func drawRingSaber(_ c: PixelCanvas, _ p: Pose) {
    var angle = p.melee, trail = p.trail
    if !p.walking {
        var unengaged = false
        if case .none = p.role { unengaged = true }
        if case .rest = p.role { unengaged = true }
        if unengaged, p.mode == .idle, let h = idleHabit, h.kind == .flourish {
            angle = -60 + 900 * h.e * habitArc(h.p, hold: 0.6); trail = []
        }
        if p.mode == .waiting || p.mode == .standGuard { angle = p.t * 900; trail = [] }
    }
    if let a = angle {
        drawSaber(c, t: p.t, angle: a + 180, core: redCore, glow: redGlow, lit: true, length: 14)
        drawSaber(c, t: p.t, angle: a, core: redCore, glow: redGlow, lit: true, trail: trail, length: 14)
        drawInquisitorRing(c, x: Int(Sprite.hand.x) - 2, y: Int(Sprite.hand.y) - 2)
    } else {
        drawInquisitorRing(c, x: 35, y: 36)
    }
}

// MARK: - Watto

/// Watto: a Toydarian junk dealer, hovering on a blur of wings. Blue-grey, pot-bellied, a trunk of a nose and a
/// little cap; one hand always out, haggling. He bobs on his own and doesn't breathe with the rest.
private func drawWatto(_ c: PixelCanvas, _ p: Pose) {
    let t = p.lt
    let base = c.oy
    c.rect(20, 43, 16, 1, C(0x000000).alpha(0.22))                  // his shadow
    c.oy = base + Int((sin(t * 3) * 1.5).rounded()) - 2
    let skin = C(0x6E8CA8), skinDark = C(0x52708A), vest = C(0x8A6A3A), skinHi = C(0x8EAAC4)
    let vestHi = C(0xA88450), vestDark = C(0x6A4E2A)
    let up = Int(t * 20) % 2 == 0
    c.ellipse(15, up ? 15 : 22, 7, up ? 4 : 2, C(0xC8D8E8).alpha(0.55))   // the wings, buzzing
    c.ellipse(19, up ? 14 : 21, 6, up ? 3 : 2, C(0xE0ECF8).alpha(0.7))
    c.rect(25, 38, 2, 4, skinDark); c.rect(30, 38, 2, 4, skinDark)  // dangling legs
    c.rect(24, 42, 3, 1, skinDark); c.rect(30, 42, 3, 1, skinDark)
    c.px(25, 39, skin); c.px(30, 39, skin)                          // knobbly knees catching the light
    c.ellipse(28, 32, 9, 7, skin)                                   // the belly
    c.ellipse(29, 34, 5, 3, C(0x86A2BC))
    c.rect(25, 29, 2, 1, skinDark); c.rect(30, 30, 2, 1, skinDark)  // creases in the belly
    // The vest: lit along the top, its far edge in shadow, a pocket either side.
    c.rect(20, 27, 3, 9, vest); c.rect(34, 27, 3, 9, vest)
    c.rect(20, 27, 3, 1, vestHi); c.rect(34, 27, 3, 1, vestHi); c.px(20, 28, vestHi)
    c.rect(36, 28, 1, 8, vestDark); c.rect(22, 29, 1, 7, vestDark)
    c.rect(20, 32, 2, 1, vestDark); c.rect(34, 31, 2, 1, vestDark)
    // The belt, its brass buckle and a pouch for the takings.
    c.rect(19, 36, 18, 1, C(0x4A3420))
    c.rect(27, 36, 2, 1, C(0xB08D57)); c.px(27, 36, C(0xE0C080))
    c.rect(20, 37, 3, 2, C(0x5A4028)); c.rect(20, 37, 3, 1, C(0x6E5236)); c.px(21, 38, C(0xB08D57))
    c.rect(16, 30, 3, 3, skin)
    let haggle = sin(t * 2) > 0.2
    c.rect(37, haggle ? 25 : 30, 3, 3, skin)                       // a hand out: how much?
    c.ellipse(29, 20, 7, 5, skin)                                   // the head
    c.rect(25, 13, 9, 3, C(0x6A5030)); c.rect(24, 15, 11, 1, C(0x4A3820))   // cap
    c.rect(26, 13, 4, 1, C(0x8A6A42)); c.rect(25, 14, 9, 1, C(0x5A4228)); c.px(32, 13, C(0x5A4228))   // its crown lit, a band
    // His head: the light along the top, brows over the eyes, creases in short strokes.
    c.rect(24, 16, 4, 1, skinHi); c.px(23, 17, skinHi); c.px(22, 19, skinHi)
    c.rect(28, 17, 3, 1, skinDark); c.rect(32, 17, 3, 1, skinDark)
    c.rect(24, 20, 2, 1, skinDark); c.rect(25, 22, 2, 1, skinDark)
    c.rect(29, 18, 2, 2, C(0xF0E0A0)); c.rect(33, 18, 2, 2, C(0xF0E0A0))
    c.px(30, 18, ink); c.px(34, 18, ink)
    c.rect(34, 20, 3, 3, skinDark); c.rect(36, 22, 2, 5, skinDark)  // the trunk
    c.px(35, 20, skin); c.px(36, 23, skin); c.px(36, 25, skin)      // its wrinkled rings
    c.px(33, 23, white)                                             // a tusk
    for (x, y) in [(26, 23), (28, 24), (30, 24), (32, 24)] { c.px(x, y, skinDark) }   // stubble
    c.oy = base
}

// MARK: - Moff Gideon

/// Moff Gideon: black Imperial uniform and cape, close-cropped hair, and the Darksaber: a black blade with a white
/// edge.
private func drawMoffGideon(_ c: PixelCanvas, _ p: Pose) {
    drawCape(c, t: p.t, speed: p.capeSpeed, color: C(0x101014), edge: C(0x2A2A33))
    let uniform = C(0x1E1E26), collar = C(0x34343E), deep = C(0x101016)
    drawLegs(c, Look(leg: C(0x1A1A20)), step: p.step)
    drawBoots(c, ink, step: p.step, rows: 3)                        // tall black boots, polished
    drawBootShine(c, step: p.step, C(0x5C6070))
    c.oy += p.breathe
    drawBody(c, Look(arm: uniform))
    c.rect(15, 35, 3, 1, ink); c.rect(38, 35, 3, 1, ink)            // black gloves
    // Close-cropped hair, a dull sheen along it.
    c.pattern(18, 23, ["..HHHHllllHHHHHHHH..", "HHllHHHHHHHHHHHHHHHH", "HH................HH"],
              ["H": C(0x1A1410), "l": C(0x3E3228)])
    // The black uniform: the high collar, the double-breasted flap, folds shaded down the side.
    c.rect(18, 33, 20, 5, uniform)
    c.rect(18, 33, 20, 1, collar)
    c.rect(25, 33, 6, 1, deep)
    c.rect(31, 34, 1, 2, collar); c.px(33, 34, collar)
    c.rect(37, 33, 1, 5, deep); c.px(20, 37, deep)
    // The rank plaque in its silver rim.
    c.rect(21, 34, 4, 1, C(0x8E9296))
    c.px(21, 35, C(0xD84A2A)); c.px(22, 35, C(0x3A6ED8)); c.px(23, 35, C(0xD84A2A)); c.px(24, 35, C(0xE0B84A))
    // The belt with its silver buckle.
    c.rect(18, 36, 20, 1, C(0x3A3A44))
    c.rect(27, 36, 2, 1, C(0xB9BEC8)); c.px(27, 36, C(0xE4E8EE))
    if let a = p.melee {
        drawSaber(c, t: p.t, angle: a, core: C(0x16161C), glow: C(0xDDE8FF), lit: true, trail: p.trail, length: 17)
    } else {
        c.rect(36, 37, 2, 5, C(0x3A3A42)); c.rect(36, 37, 2, 1, C(0xB9BEC8))
    }
}

// MARK: - Death Trooper

/// A death trooper: black armour, the black helmet with its dark green-glinting visor, an E-11.
private func drawDeathTrooper(_ c: PixelCanvas, _ p: Pose) {
    let black = C(0x1C1C22), plate = C(0x24242C), plateHi = C(0x3A3C46), deep = C(0x0E0E12)
    drawLegs(c, Look(leg: C(0x1A1A20)), step: p.step)
    if !seatedPose {                                                // knee plates, lit on top
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let y = p.step >= 0 && i % 2 == p.step ? 38 : 39
            c.rect(lx, y, 2, 2, plate); c.px(lx, y, plateHi)
        }
    }
    drawBoots(c, deep, step: p.step, rows: 2)                       // black boots, a glint down the front
    drawBootShine(c, step: p.step, C(0x4A4C58))
    c.oy += p.breathe
    drawBody(c, Look(body: black, shade: C(0x101014), arm: black, eye: nil))
    c.rect(15, 35, 3, 1, deep); c.rect(38, 35, 3, 1, deep)          // the gloves
    // The helmet: the light along its dome, the far side in shadow, rims under the visor and the grille's slots.
    c.pattern(17, 19, [
        ".....HHHhhhhHHHHH.....",
        "...HHHhhHHHHHHHHHHH...",
        "..HHhhHHHHHHHHHHHHdH..",
        ".HHhHHHHHHHHHHHHHHHdH.",
        ".HHHHHHHHHHHHHHHHHHdH.",
        "HHHHHHHHHHHHHHHHHHHHdH",
        "HHVVVVVHHHHHHHHVVVVVdH",
        "HHHVVgVHHHHHHHHVVgVHdH",
        "HHrrrrrHHHHHHHHrrrrrHH",
        "HHHHHHHHGGGGGGHHHHHHHH",
        "HHHHHHHHGsGsGsHHHHHHHH",
        ".HHHHHHHGGGGGGHHHHHHH.",
        "..HHHHHHHHHHHHHHHHHH..",
    ], ["H": C(0x16161C), "h": C(0x4A4C58), "V": C(0x22332C), "g": C(0x7AE0A0), "G": C(0x2E2E36), "s": C(0x6A6E78),
        "d": deep, "r": C(0x2A2A32)])
    // The chest armour: plates lit along their tops, a seam down the middle with rivets, folds shaded.
    c.rect(18, 33, 20, 4, plate)
    c.rect(19, 33, 8, 1, plateHi); c.rect(29, 33, 8, 1, plateHi); c.rect(27, 33, 2, 3, deep)
    c.rect(22, 34, 3, 1, C(0x4A4C58)); c.rect(31, 34, 3, 1, C(0x4A4C58))
    c.px(20, 35, C(0x5A5E68)); c.px(35, 35, C(0x5A5E68)); c.rect(37, 33, 1, 4, deep)
    // The belt: pouches either side and a dull buckle.
    c.rect(18, 36, 20, 1, C(0x3A3A44))
    c.rect(20, 36, 3, 2, C(0x2A2A32)); c.rect(32, 36, 3, 2, C(0x2A2A32))
    c.rect(27, 36, 2, 1, C(0x6A6E78)); c.px(27, 36, C(0x9A9EA8))
    c.oy += p.gunY
    drawE11(c, x: 37, y: 30)
}

// MARK: - Scout Trooper

/// A scout trooper on a 74-Z speeder bike, hovering: the long body, the steering vanes out on their rods, the
/// cannon underneath (its weapon), and the trooper hunched over the handlebars.
private func drawScoutTrooper(_ c: PixelCanvas, _ p: Pose) {
    let t = p.t
    let base = c.oy
    c.rect(8, 43, 58, 1, C(0x000000).alpha(0.22))                   // its shadow
    c.oy = base + Int((sin(t * 3) * 1.0).rounded()) - 3
    let hull = C(0x7A7A6A), hullLight = C(0x9A9A88), dark = C(0x3A3A36), white = C(0xEEEEEA)
    c.rect(40, 31, 20, 1, C(0x4A4A50)); c.rect(40, 34, 20, 1, C(0x4A4A50))   // the rods…
    c.rect(59, 28, 2, 10, dark); c.rect(61, 29, 3, 8, C(0x5A5A52)) // …and the steering vanes
    c.rect(40, 36, 8, 1, dark)                                     // the cannon
    c.rect(8, 29, 6, 8, dark)                                      // engine
    c.rect(7, 31, 1, 4, Int(t * 15) % 2 == 0 ? C(0xFF9A2A) : C(0xFFE27A))
    c.pattern(12, 29, [
        "..HHHHHHHHHHHHHHHHHHHHHHHHH..",
        ".HLLLLLLLLLLLLLLLLLLLLLLLLLHH",
        "HHHHHHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHHHHHH...",
        ".HHHHHHHHHHHHHHHHHHHHHHH.....",
        "...dddddddddddddddddd........",
    ], ["H": hull, "L": hullLight, "d": dark])
    // The bike: panel seams with rivets, the engine's intake slots, a small red running light.
    let seam = C(0x5E5E52)
    for x in [19, 28, 36] { c.rect(x, 31, 1, 3, seam); c.px(x + 1, 32, hullLight) }
    c.rect(15, 33, 8, 1, seam)
    c.rect(9, 30, 4, 1, C(0x26261F)); c.rect(9, 32, 4, 1, C(0x26261F)); c.rect(9, 34, 4, 1, C(0x26261F))
    c.px(13, 30, C(0x5A5A52)); c.px(38, 31, C(0xE0402A))
    c.oy += p.breathe
    let shade = C(0xC8C8C2)
    // His leg along the bike: a knee plate shaded underneath, the black boot with a glint.
    c.rect(26, 27, 8, 3, white); c.rect(32, 30, 3, 3, ink)
    c.rect(26, 29, 6, 1, shade); c.px(30, 28, C(0x2A2A30)); c.px(33, 30, C(0x5A5E68))
    // The armour: a seam down the chest plate, its far side shaded, the black belt with a buckle and a pouch.
    c.rect(22, 19, 12, 9, white)
    c.rect(27, 20, 1, 4, shade); c.rect(33, 19, 1, 6, shade); c.rect(22, 24, 11, 1, shade)
    c.rect(22, 25, 12, 1, ink)
    c.px(27, 25, C(0x8A8F99)); c.rect(23, 26, 2, 1, C(0x2A2A30))
    // Arms forward to the handlebars: the black suit at the elbow, a shadow under the arm, black gloves.
    c.rect(33, 22, 6, 2, white); c.rect(38, 23, 2, 2, ink)
    c.rect(33, 23, 5, 1, shade); c.px(35, 22, C(0x2A2A30))
    c.pattern(21, 11, [
        "....WWWWWW....",
        "..WWWWWWWWWW..",
        ".WWWWWWWWWWWW.",
        "WWWWWWWWWWWWWW",
        "WWKKKKKKKKKKKW",
        "WWWWWWWWWWKKWW",
        "WWWWWWWWWKKKKW",
        ".WWWWWWWWWKKK.",
    ], ["W": white, "K": ink])
    // The helmet: a ridge over the dome, the brow shaded over the visor, the lower dome in shadow.
    c.rect(27, 11, 1, 2, shade); c.rect(23, 14, 10, 1, shade); c.rect(22, 18, 8, 1, shade)
    c.oy = base
}

// MARK: - Asajj Ventress

/// Asajj Ventress: bald and pale with dark markings over the head, pale blue eyes, dark robes; twin red sabers, the
/// second from her other hand.
private func drawVentress(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xE4DCD8), robe = C(0x2A2630), mark = C(0x5A4A5A), robeHi = C(0x4A4250), deep = C(0x18161C)
    let skinShade = C(0xC0B6B2)
    drawLegs(c, Look(leg: robe), step: p.step)
    drawBoots(c, ink, step: p.step, rows: 2)                        // black boots, a glint down the front
    drawBootShine(c, step: p.step, C(0x4A4C56))
    c.oy += p.breathe
    drawBody(c, Look(body: skin, shade: skinShade, arm: robe, eye: nil))
    c.rect(15, 35, 3, 1, robeHi); c.rect(38, 35, 3, 1, robeHi)      // wrapped cuffs
    // Her bald head, the light along its crown and the far side in shadow.
    c.pattern(19, 22, ["...SSlllSSSSSSS...", ".SllSSSSSSSSSSSSs.", "SSSSSSSSSSSSSSSSSs"],
              ["S": skin, "l": C(0xFAF6F4), "s": skinShade])
    c.rect(23, 23, 1, 4, mark); c.rect(28, 22, 1, 5, mark); c.rect(33, 23, 1, 4, mark)
    c.rect(22, 29, 2, 3, C(0x3A5A8A)); c.rect(32, 29, 2, 3, C(0x3A5A8A))
    c.px(22, 29, C(0x8AB0E0)); c.px(32, 29, C(0x8AB0E0))
    // The dark robes: the collar, the wrap crossing at the chest, folds shaded, a sash with its clasp.
    c.rect(18, 33, 20, 5, robe)
    c.rect(18, 33, 20, 1, robeHi)
    c.rect(26, 33, 4, 1, deep)
    c.px(25, 34, robeHi); c.px(26, 35, robeHi); c.px(30, 34, robeHi); c.px(29, 35, robeHi)
    c.rect(37, 33, 1, 5, deep); c.px(21, 34, deep); c.px(33, 37, deep)
    c.rect(18, 36, 20, 1, C(0x5A4A3A))
    c.rect(27, 36, 2, 1, C(0x8A8F99)); c.px(28, 37, C(0x5A4A3A))
    if let a = p.melee {
        c.ox -= 24; c.oy += 1
        drawSaber(c, t: p.t, angle: 180 - a * 0.6 + 40, core: redCore, glow: redGlow, lit: true, length: 15)
        c.ox += 24; c.oy -= 1
        drawSaber(c, t: p.t, angle: a, core: redCore, glow: redGlow, lit: true, trail: p.trail, length: 17)
    } else {
        c.rect(36, 37, 2, 5, C(0xB9BEC8)); c.rect(14, 36, 2, 5, C(0xB9BEC8))
    }
}

// MARK: - Savage Opress

/// Savage Opress: a huge Zabrak, yellow skin striped with black, a crown of horns, armour on the shoulders, and a
/// double-bladed red saber like his brother's.
private func drawSavageOpress(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xD8B04A), stripe = C(0x1A1410), horn = C(0xE8DCC0)
    let armour = C(0x3A3A44), armourHi = C(0x6A6E78), deep = C(0x24242C)
    drawLegs(c, Look(leg: C(0x2A2028)), step: p.step)
    drawBoots(c, ink, step: p.step, rows: 2)                        // black boots, a glint down the front
    drawBootShine(c, step: p.step, C(0x5A5048))
    c.oy += p.breathe
    drawBody(c, Look(body: skin, shade: C(0xB08A30), arm: skin, eye: nil))
    c.rect(15, 35, 3, 1, armour); c.rect(38, 35, 3, 1, armour)      // armoured bracers
    for (x, h) in [(19, 3), (23, 5), (27, 6), (31, 5), (35, 3)] {    // the horns, shaded down one side
        c.rect(x, 26 - h, 2, h, horn); c.px(x, 26 - h, C(0xC8BCA0))
        c.rect(x + 1, 27 - h, 1, h - 1, C(0xC4B898))
    }
    for x in [19, 36] { c.rect(x, 26, 1, 7, stripe) }
    c.rect(27, 26, 2, 3, stripe)                                      // down the brow
    c.px(21, 28, stripe); c.px(34, 28, stripe); c.rect(25, 32, 6, 1, stripe)
    c.rect(22, 29, 2, 2, C(0xF0D040)); c.rect(32, 29, 2, 2, C(0xF0D040))
    // The armour: lit along the collar, plate seams with rivets, folds shaded, a belt and buckle.
    c.rect(18, 33, 20, 5, armour)
    c.rect(18, 33, 20, 1, armourHi)
    c.rect(27, 34, 2, 2, deep); c.rect(22, 34, 1, 2, deep); c.rect(33, 34, 1, 2, deep)
    c.px(20, 34, armourHi); c.px(35, 34, armourHi)
    c.rect(37, 34, 1, 4, deep)
    c.rect(18, 36, 20, 1, deep)
    c.rect(27, 36, 2, 1, C(0x8A8F99)); c.px(27, 36, C(0xB8BCC6))
    // The pauldrons, lit along the top and dark underneath, a rivet in each.
    c.rect(14, 31, 4, 3, armourHi); c.rect(38, 31, 4, 3, armourHi)
    c.rect(14, 31, 4, 1, C(0x9A9EA8)); c.rect(38, 31, 4, 1, C(0x9A9EA8))
    c.rect(14, 33, 4, 1, C(0x4A4E58)); c.rect(38, 33, 4, 1, C(0x4A4E58))
    c.px(15, 32, deep); c.px(40, 32, deep)
    if let a = p.melee {
        drawSaber(c, t: p.t, angle: a + 180, core: redCore, glow: redGlow, lit: true, length: 15)
        drawSaber(c, t: p.t, angle: a, core: redCore, glow: redGlow, lit: true, trail: p.trail, length: 15)
    } else {
        c.rect(36, 34, 2, 8, C(0x2A2A2F)); c.rect(36, 37, 2, 2, C(0xB9BEC8))
    }
}

// MARK: - Jango Fett

/// Jango Fett: silver-blue armour over a dark blue suit, the T-visor helmet, a silver-blue jetpack that fires up
/// between his shots, a Westar pistol.
private func drawJangoFett(_ c: PixelCanvas, _ p: Pose) {
    let pack = C(0x9AA8BC), packShade = C(0x6E7C92)
    for x in [13, 38] {
        c.rect(x, 23, 5, 11, pack)
        c.rect(x + 4, 23, 1, 11, packShade)
        c.rect(x, 23, 4, 1, C(0xC8D0DC))                            // lit along the top
        c.rect(x, 29, 4, 1, packShade); c.px(x + 1, 27, packShade)  // a seam and a rivet
        c.rect(x, 34, 5, 1, C(0x4A4A52))
    }
    c.rect(13, 21, 5, 2, C(0xC8402A))   // the missile
    c.rect(14, 20, 3, 1, C(0xC8402A))
    c.rect(14, 21, 2, 1, C(0xE86A4A))
    if let fire = p.fire, frac(fire.t / blasterPeriod) > 0.7 {
        for x in [14, 39] {
            let len = 3 + Int(noise(Int(p.t * 30) + x) * 3)
            c.rect(x, 35, 3, len, C(0xFF9A2A))
            c.rect(x + 1, 35, 1, len + 1, C(0xFFE27A))
        }
    }
    let suit = C(0x3A4A6A), silver = C(0x9AA8BC), silverHi = C(0xC8D0DC), silverDark = C(0x6E7C92)
    drawLegs(c, Look(leg: suit), step: p.step)
    if !seatedPose {                                                // silver knee plates, lit on top
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let y = p.step >= 0 && i % 2 == p.step ? 38 : 39
            c.rect(lx, y, 2, 2, silver); c.px(lx, y, silverHi)
        }
    }
    drawBoots(c, C(0x1E2434), step: p.step, rows: 2)                // dark blue boots
    drawBootShine(c, step: p.step, silverDark)
    c.oy += p.breathe
    drawBody(c, Look(body: suit, shade: C(0x2C3A56), arm: suit, eye: nil))
    c.rect(15, 34, 3, 2, silver); c.rect(15, 34, 3, 1, silverHi)   // the gauntlet
    drawMandoHelmet(c, C(0xA8B4C6), C(0xD8E0EC), marks: C(0x3A5A9A))
    c.rect(37, 24, 1, 7, C(0x8A96A8)); c.rect(21, 32, 15, 1, C(0x8A96A8))   // the helmet's far side and rim in shadow
    // The chest plates, lit along the top, a seam down the middle and a rivet either side.
    c.rect(19, 33, 18, 3, silver)
    c.rect(19, 33, 18, 1, silverHi)
    c.rect(28, 34, 1, 2, silverDark); c.px(21, 34, silverDark); c.px(34, 34, silverDark)
    // The belt: silver buckle, pouches at the hip.
    c.rect(18, 36, 20, 1, C(0x5A4A3A))
    c.rect(27, 36, 2, 1, silverHi)
    c.rect(20, 36, 2, 2, C(0x3E3024)); c.rect(33, 36, 2, 2, C(0x3E3024))
    c.oy += p.gunY
    drawPistol(c, x: 40, y: 31, body: C(0x3A3A42), trim: C(0xB8BCC4))
}

// MARK: - Bossk

/// Bossk: a Trandoshan bounty hunter, green and scaly, slit eyes, a toothy jaw, his yellow flight suit, an E-11.
private func drawBossk(_ c: PixelCanvas, _ p: Pose) {
    let scales = C(0x6A8A4A), scalesDark = C(0x4E6A36), suit = C(0xD8C060), scalesHi = C(0x88A862)
    let suitHi = C(0xF0DC84), suitShade = C(0xB8A040), suitDeep = C(0x9A8434)
    drawLegs(c, Look(leg: suit), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx + 1, 38, 1, 3, suitShade) } }   // the suit's creases
    drawBoots(c, scalesDark, step: p.step, rows: 1)                 // bare clawed feet
    c.oy += p.breathe
    drawBody(c, Look(body: scales, shade: scalesDark, arm: suit, eye: nil))
    c.rect(15, 34, 3, 1, suitShade); c.rect(38, 34, 3, 1, suitShade)   // the sleeves' cuffs…
    c.rect(15, 35, 3, 1, scales); c.rect(38, 35, 3, 1, scales)         // …and his clawed hands
    // His scaly head: the light along the crown, the far side in shadow, scales in short lit strokes.
    c.pattern(19, 21, ["...SSlllSSSSSSS...", ".SllSsSSSSSsSSSSd.", "SSSSSSSSSSSSSSSSSd", "SSsSSSSSSsSSSSSsSd"],
              ["S": scales, "s": scalesDark, "l": scalesHi, "d": scalesDark])
    for (x, y) in [(20, 27), (26, 27), (34, 27), (29, 31), (19, 31), (34, 32)] {
        c.rect(x, y, 2, 1, scalesDark); c.px(x, y - 1, scalesHi)
    }
    // The heavy brow over his slit eyes, a glint in each.
    c.rect(21, 28, 4, 1, scalesDark); c.rect(31, 28, 4, 1, scalesDark)
    c.rect(22, 29, 3, 2, C(0xE07A2A)); c.rect(32, 29, 3, 2, C(0xE07A2A))
    c.rect(23, 29, 1, 2, ink); c.rect(33, 29, 1, 2, ink)
    c.px(22, 29, C(0xFFB46A)); c.px(32, 29, C(0xFFB46A))
    c.pattern(24, 32, ["KWKWKWKW"], ["K": ink, "W": white])
    // The flight suit: the neck of its collar, a zip with its pull, folds shaded down the side.
    c.rect(18, 33, 20, 5, suit)
    c.rect(18, 33, 20, 1, suitShade)
    c.rect(25, 33, 6, 1, suitDeep); c.px(24, 33, suitHi); c.px(31, 33, suitHi)
    c.rect(28, 34, 1, 2, suitShade); c.px(28, 34, C(0xB9BEC8))
    c.rect(37, 33, 1, 5, suitDeep); c.px(21, 35, suitShade); c.px(33, 37, suitShade)
    c.rect(19, 34, 1, 2, suitHi)
    // The belt: a pouch either side, a buckle.
    c.rect(18, 36, 20, 1, C(0x5A4A3A))
    c.rect(20, 36, 3, 2, C(0x4A3A2E)); c.rect(32, 36, 3, 2, C(0x4A3A2E)); c.px(21, 36, C(0xB08D57)); c.px(33, 36, C(0xB08D57))
    c.rect(27, 36, 2, 1, C(0x8A8F99)); c.px(27, 36, C(0xB8BCC6))
    c.oy += p.gunY
    drawE11(c, x: 37, y: 30)
}

// MARK: - Dengar

/// Dengar: his head wrapped in grey-white bandages, padded armour, a long blaster rifle with a wooden stock.
private func drawDengar(_ c: PixelCanvas, _ p: Pose) {
    let pad = C(0x6A6A5E), padHi = C(0x84846F), padDark = C(0x4E4E44)
    drawLegs(c, Look(leg: C(0x5A5A50)), step: p.step)
    drawBoots(c, C(0x2E2E2A), step: p.step, rows: 3)                // heavy dark boots
    drawBootShine(c, step: p.step, C(0x6A6A62))
    c.oy += p.breathe
    drawBody(c, Look(arm: pad))
    c.rect(15, 33, 3, 1, padHi); c.rect(38, 33, 3, 1, padHi)       // the shoulder pads, lit on top
    c.rect(15, 35, 3, 1, C(0x3A3A34)); c.rect(38, 35, 3, 1, C(0x3A3A34))   // gloves
    // The bandages wound round his head: each turn's edge in shadow, the light along the top turn.
    c.pattern(17, 19, [
        ".....WWWlllWWWWWW.....",
        "...WWWWwwwWWWWWWWWW...",
        "..WWWWWWWWwwwWWWWWWW..",
        ".WwwWWWWWWWWWwwwWWWWW.",
        ".WWWwwWWWWWWWWWWwwwWW.",
        "WWWWWWwwwWWWWWWWWWWwWW",
        "WWWWWWWWWwwwWWWWWWWWWW",
        "WW..................WW",
        "Ww..................wW",
    ], ["W": C(0xD8D2C4), "w": C(0xA8A294), "l": C(0xF0EBE0)])
    // The padded armour: quilted, lit along the top, folds shaded down the side.
    c.rect(18, 33, 20, 5, pad)
    c.rect(18, 33, 20, 1, padHi)
    for x in [21, 24, 31, 34] { c.px(x, 34, padDark); c.px(x, 36, padDark) }
    c.rect(37, 33, 1, 5, padDark)
    // The belt, its buckle and a pouch.
    c.rect(18, 35, 20, 1, padDark)
    c.rect(27, 35, 2, 1, C(0x8A8F99)); c.px(27, 35, C(0xB8BCC6))
    c.rect(20, 36, 3, 2, C(0x5A4A32)); c.px(21, 36, C(0x7A6648))
    c.oy += p.gunY
    c.pattern(37, 30, ["......SSS........", ".......K.........", "KKKKKKKKKKKKKKKKK", "KKKKWW...........", "..KK............."],
              ["K": C(0x2E2E32), "S": C(0x5A5A64), "W": C(0x6A4A2A)])
}

// MARK: - Droideka

/// A droideka: rolls in as a bronze wheel, then unfolds on three legs, head down, both gun arms forward, and (while
/// it's fighting) its shield shimmering around it.
private func drawDroideka(_ c: PixelCanvas, _ p: Pose) {
    let t = p.t
    let bronze = C(0xA8804A), bronzeLight = C(0xC8A06A), dark = C(0x6A5030), metal = C(0x8A8070)
    if p.walking {
        c.circle(28, 35, 8, bronze); c.circle(28, 35, 6, dark); c.circle(28, 35, 4, bronze)
        for k in 0..<3 {
            let a = t * 12 + Double(k) * 2.094
            c.glowLine(28, 35, 28 + cos(a) * 7, 35 + sin(a) * 7, core: bronzeLight, glow: clear, coreR: 0.6, glowR: 0.7)
        }
        return
    }
    c.oy += p.breathe
    c.glowLine(22, 30, 14, 43, core: metal, glow: clear, coreR: 0.8, glowR: 0.9)      // legs
    c.glowLine(31, 32, 38, 43, core: metal, glow: clear, coreR: 0.8, glowR: 0.9)
    c.glowLine(27, 32, 27, 43, core: dark, glow: clear, coreR: 0.8, glowR: 0.9)
    c.ellipse(25, 25, 8, 6, bronze)                                  // the curved back
    c.ellipse(24, 23, 6, 3, bronzeLight)
    c.ellipse(34, 30, 5, 3, bronze)                                  // the head, down at the front
    c.px(37, 30, C(0xFF4A3A)); c.px(36, 31, ink)
    c.rect(30, 26, 12, 2, dark)                                      // the gun arms
    c.rect(42, 26, 3, 2, metal)
    c.rect(42, 30, 6, 1, dark); c.rect(42, 32, 6, 1, dark)
    c.oy -= p.breathe
    if p.mode == .working {
        for k in 0..<48 {
            let a = Double(k) / 48 * 2 * .pi
            let x = 28 + cos(a) * 17, y = 30 + sin(a) * 14
            guard y <= 43 else { continue }
            c.px(Int(x.rounded()), Int(y.rounded()), C(0x7FC8FF).alpha(0.35 + 0.25 * sin(t * 6 + Double(k) * 0.7)))
        }
    }
}

// MARK: - Captain Phasma

/// Captain Phasma: chrome armour head to foot, a black cape lined in red, a chrome blaster. Signature: a gleam of
/// light runs across the chrome (she does keep it polished).
private func drawPhasma(_ c: PixelCanvas, _ p: Pose) {
    drawCape(c, t: p.t, speed: p.capeSpeed, color: C(0x16161A), edge: C(0x8A1A1A))
    let chrome = C(0xC8CCD4), light = C(0xF0F2F6), dark = C(0x8A8E98), seam = C(0x6A6E78)
    drawLegs(c, Look(leg: dark), step: p.step)
    // Chrome greaves: a lit edge down each shin, a knee plate, dark boots.
    drawBoots(c, C(0x5A5E68), step: p.step, rows: 2)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lift = p.step >= 0 && i % 2 == p.step ? 1 : 0
            c.rect(lx, 38 - lift, 2, 1, chrome); c.px(lx, 39 - lift, chrome)
        }
    }
    c.oy += p.breathe
    drawBody(c, Look(body: chrome, shade: dark, arm: chrome, eye: nil))
    c.rect(15, 35, 3, 1, C(0x2A2A30)); c.rect(38, 35, 3, 1, C(0x2A2A30))   // black gloves
    c.px(15, 33, light); c.px(38, 33, light)                         // the shoulder plates' shine
    // The helmet: a seam over the dome, the brow ridge, the breathing slots.
    c.pattern(17, 19, [
        ".....CCCCCCCCCCCC.....",
        "...CCCCCCCCCCCCCCCC...",
        "..CCllCCCCCCCCCCCCCC..",
        ".CClCCCCCCsCCCCCCCCCd.",
        ".CClCCCCCCsCCCCCCCCCd.",
        "CCCKKKKKKKCCKKKKKKKCCd",
        "CCCCKKKKKKCCKKKKKKCCCd",
        "CCCCCCCCCKllKCCCCCCCCd",
        "CCCCCCCCCCCCCCCCCCCCCd",
        "CCCCCCdCdCdCdCdCCCCCCd",
        ".CCCCCCCCCCCCCCCCCCCd.",
        "..ssssssssssssssssss..",
    ], ["C": chrome, "l": light, "K": ink, "d": dark, "s": seam])
    // The chest plate, its seams and a rivet either side, over the belt and its buckle.
    c.rect(19, 33, 18, 3, light)
    c.rect(28, 33, 1, 2, chrome); c.px(21, 34, chrome); c.px(34, 34, chrome)
    c.rect(19, 35, 18, 1, dark)
    c.rect(18, 36, 20, 1, C(0x2A2A30))
    c.rect(27, 36, 2, 1, chrome); c.px(27, 36, light)
    c.rect(18, 37, 20, 1, seam)
    if let s = p.signature { drawGlint(c, p: s, maxX: 39) }
    c.oy += p.gunY
    c.pattern(37, 30, ["......SSSL.....", ".......K.K.....", "KK.KKKKKKKKKKKK", "KKKKKKkKkKkKKK.", "....KK..MM.....", "....KK..MM....."],
              ["S": C(0x8A8E98), "L": C(0x7FC8FF), "K": C(0xC8CCD4), "k": C(0x8A8E98), "M": C(0xA8ACB4)])
}

// MARK: - Director Krennic

/// Director Krennic: the white uniform and white cape, grey-blond hair, a pistol.
private func drawKrennic(_ c: PixelCanvas, _ p: Pose) {
    drawCape(c, t: p.t, speed: p.capeSpeed, color: C(0xE6E6DE), edge: C(0xC0C0B8))
    let uniform = C(0xF2F2EC), shade = C(0xC8C8C0)
    drawLegs(c, Look(leg: C(0xE0E0D8)), step: p.step)
    drawBoots(c, ink, step: p.step, rows: 2)                        // black boots, polished
    drawBootShine(c, step: p.step, C(0x5C6070))
    c.oy += p.breathe
    drawBody(c, Look(arm: uniform))
    c.rect(15, 34, 3, 2, ink); c.rect(38, 34, 3, 2, ink)            // black gloves
    // Grey-blond hair, swept back, the light running along it.
    c.pattern(18, 22, ["...HHHHHlllHHHHHH...", ".HHHllllHHHHHhHHHHH.", "HHHHHHHHHHHHHHHHHHhH", "HH................HH"],
              ["H": C(0xB8AC90), "l": C(0xD8CEB4), "h": C(0x96896C)])
    // The white tunic: the high collar, the double-breasted flap, folds shaded down the side.
    c.rect(18, 33, 20, 5, uniform)
    c.rect(18, 33, 20, 1, shade)
    c.rect(25, 33, 6, 1, C(0xB0B0A8))
    c.rect(31, 34, 1, 2, shade); c.rect(37, 33, 1, 3, shade)
    // The rank plaque in its silver rim.
    c.rect(21, 34, 4, 1, C(0x8E9296))
    c.px(21, 35, C(0xD84A2A)); c.px(22, 35, C(0x3A6ED8)); c.px(23, 35, C(0xE0B84A)); c.px(24, 35, C(0x3A6ED8))
    // The black belt, its silver buckle, the holster on his hip.
    c.rect(18, 36, 20, 1, C(0x2A2A30))
    c.rect(27, 36, 2, 1, C(0xB8BCC4))
    c.rect(33, 36, 2, 2, C(0x2A2A30))
    c.px(21, 37, shade); c.px(25, 37, shade)
    c.oy += p.gunY
    drawPistol(c, x: 40, y: 31)
}

// MARK: - Governor Tarkin

/// Grand Moff Tarkin: the olive-grey uniform with its rank plaque, slicked grey hair, gaunt cheeks. Unarmed: he
/// gives the order.
private func drawTarkin(_ c: PixelCanvas, _ p: Pose) {
    let uniform = C(0x6A6E5E), dark = C(0x4E5244)
    drawLegs(c, Look(leg: C(0x3A3A34)), step: p.step)
    drawBoots(c, ink, step: p.step, rows: 3)                     // tall black jackboots
    c.oy += p.breathe
    drawBody(c, Look(arm: uniform))
    c.rect(15, 35, 3, 1, dark); c.rect(38, 35, 3, 1, dark)     // the tunic's cuffs
    c.pattern(18, 22, ["....HHHHHHHHHHHH....", ".HHHHlllHHHHHHHHHH.", "HHHlHHHHHHHHHHHHHHHH", "HH................HH"],
              ["H": C(0xA8A8A0), "l": C(0xD0D0C8)])                   // slicked back, the comb lines catching the light
    c.rect(21, 32, 1, 1, clawdShade); c.rect(34, 32, 1, 1, clawdShade)   // hollow cheeks
    // The tunic: the high collar, the double-breasted flap across the chest, a fold down the side.
    c.rect(18, 33, 20, 5, uniform)
    c.rect(18, 33, 20, 1, dark)
    c.rect(25, 33, 6, 1, C(0x3A3E32))
    c.rect(31, 34, 1, 3, dark); c.rect(37, 34, 1, 4, dark)
    for (i, col) in [C(0xD84A2A), C(0x3A6ED8), C(0xD84A2A), C(0xE0B84A)].enumerated() {
        c.px(21 + i, 35, col); c.px(21 + i, 36, i % 2 == 0 ? C(0x3A6ED8) : C(0xD84A2A))
    }
    c.rect(21, 34, 4, 1, C(0x8E9296))                            // the plaque's silver rim
    // The black belt and its silver disc buckle.
    c.rect(18, 37, 20, 1, ink)
    c.rect(27, 37, 2, 1, C(0xB8BCC4))
}

// MARK: - Fifth Brother

/// The Fifth Brother: a big grey-skinned Inquisitor, bald, a heavy brow over yellow eyes, black armour, a ring saber.
private func drawFifthBrother(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x9A9C98), skinDark = C(0x7A7C78), skinHi = C(0xB8BAB6), armour = C(0x1E1E24), plate = C(0x3A3A44)
    drawLegs(c, Look(leg: C(0x1A1A20)), step: p.step)
    drawBoots(c, ink, step: p.step, rows: 2)
    drawBootShine(c, step: p.step, C(0x5C6070))
    c.oy += p.breathe
    drawBody(c, Look(body: skin, shade: skinDark, arm: armour, eye: nil))
    // The bald dome, the light along its crown, the ridges over the brow.
    c.pattern(19, 22, ["...SSSSllllSSSS...", ".SSSllSSSSSSSSSSs.", "SSSSSSSSSSSSSSSSss"], ["S": skin, "l": skinHi, "s": skinDark])
    c.rect(21, 28, 14, 1, skinDark)
    c.rect(24, 27, 2, 1, skinDark); c.rect(30, 27, 2, 1, skinDark)
    c.rect(22, 29, 2, 2, C(0xF0C030)); c.rect(32, 29, 2, 2, C(0xF0C030))
    c.rect(24, 32, 8, 1, skinDark)
    // The black armour: the collar, ribbed plates down the chest, a belt and its buckle.
    c.rect(18, 33, 20, 5, armour)
    c.rect(18, 33, 20, 1, plate)
    for x in [21, 24, 31, 34] { c.rect(x, 34, 1, 2, C(0x2E2E36)) }
    c.rect(37, 34, 1, 4, C(0x121216))
    c.rect(18, 36, 20, 1, C(0x2E2E36))
    c.rect(27, 36, 2, 1, C(0x8A8F99)); c.px(27, 36, C(0xC8CCD6))
    // The heavy pauldrons, lit along the top, the plates' edge and a rivet.
    c.rect(14, 31, 5, 3, plate); c.rect(37, 31, 5, 3, plate)
    c.rect(14, 31, 5, 1, C(0x5A5A66)); c.rect(37, 31, 5, 1, C(0x5A5A66))
    c.rect(14, 33, 5, 1, C(0x2A2A32)); c.rect(37, 33, 5, 1, C(0x2A2A32))
    c.px(16, 32, C(0x8A8F99)); c.px(39, 32, C(0x8A8F99))
    c.rect(15, 35, 3, 1, C(0x121216)); c.rect(38, 35, 3, 1, C(0x121216))   // the gloves' cuffs
    drawRingSaber(c, p)
}

// MARK: - Reva

/// Reva, the Third Sister: dark hair pulled back into a bun, the black Inquisitor suit, a spinning ring saber.
private func drawReva(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x1E1E26), suitDark = C(0x121218), hair = C(0x14100E), hairHi = C(0x3A2C24)
    drawLegs(c, Look(leg: C(0x1A1A20)), step: p.step)
    drawBoots(c, ink, step: p.step, rows: 2)
    drawBootShine(c, step: p.step, C(0x5C6070))
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    c.rect(15, 35, 3, 1, suitDark); c.rect(38, 35, 3, 1, suitDark)   // the gloves' cuffs
    // Her hair pulled tight back, the light running along it to the bun, a band round the bun.
    c.pattern(18, 22, ["...HHHHHHHHHHHHHH...", ".HlllHHHHHHlllHHHHH.", "HHHHHllllHHHHHHHHHHH", "HH................HH"],
              ["H": hair, "l": hairHi])
    c.pattern(14, 22, [".HlH.", "HHbHH", ".HbH."], ["H": hair, "l": hairHi, "b": C(0x6A6E78)])
    // The suit: a lit collar, the crossed straps of the armour, folds shaded, a silver belt and buckle.
    c.rect(18, 33, 20, 5, suit)
    c.rect(18, 33, 20, 1, C(0x3A3A44))
    c.px(22, 34, C(0x34343E)); c.px(23, 35, C(0x34343E)); c.px(33, 34, C(0x34343E)); c.px(32, 35, C(0x34343E))
    c.rect(37, 34, 1, 4, suitDark)
    c.rect(18, 36, 20, 1, C(0x8A8F99))
    c.rect(27, 36, 2, 1, C(0xC8CCD6)); c.px(28, 36, C(0x5C6070))
    c.rect(18, 37, 20, 1, suitDark)
    drawRingSaber(c, p)
}
