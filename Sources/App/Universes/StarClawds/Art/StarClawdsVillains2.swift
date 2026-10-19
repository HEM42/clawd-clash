import Foundation

// Star Wars villains: the second wave, Sebulba to Bib Fortuna. Ported from Clawd Wars' `Recruits.swift` costumes and
// the weapon and quirk code that lived in its `drawLeader`.

let starWarsVillains2: [SWVillain: Persona] = [
    .sebulba: Persona(name: "Sebulbous", weapon: .blaster, shot: .fire, armoured: true, canSit: false, muzzle: (70, 31), handGun: false,
                  headTop: 19, draw: drawSebulba),
    .salacious: Persona(name: "Salacious Crumble", canSit: false, headTop: 16,
                  draw: drawSalacious),
    .grievous: Persona(name: "General Grievance", weapon: .saber, armoured: true, headTop: 14, signature: 2.2,
                  draw: drawGrievous),
    .tusken: Persona(name: "Tuskin' Raider", weapon: .saber, headTop: 19,
                  draw: drawTusken),
    .cadBane: Persona(name: "Cad Pain", weapon: .blaster, muzzle: (47, 32), headTop: 15,
                  draw: drawCadBane),
    .thrawn: Persona(name: "Admiral Thrown", weapon: .blaster, muzzle: (47, 32), headTop: 22,
                  draw: drawThrawn),
    .hammerhead: Persona(name: "Hammerhead", canSit: false, headTop: 10,
                  draw: drawHammerhead),
    .mse6: Persona(name: "Mouse-6", armoured: true, canSit: false, headTop: 35,
                  draw: drawMse6),
    .baylan: Persona(name: "Baylan Scowl", weapon: .saber, headTop: 21,
                  draw: drawBaylan),
    .shinHati: Persona(name: "Shin Haughty", weapon: .saber, headTop: 21,
                  draw: drawShinHati),
    .id9: Persona(name: "ID-10T Seeker Bot", armoured: true, canSit: false, headTop: 17,
                  draw: drawId9),
    .grandInquisitor: Persona(name: "Grand Inquisitor", weapon: .saber, headTop: 17,
                  draw: drawGrandInquisitor),
    .secondSister: Persona(name: "Second Sister", weapon: .saber, headTop: 18,
                  draw: drawSecondSister),
    .bantha: Persona(name: "Banthum", canSit: false, headTop: 15,
                  draw: drawBantha),
    .bibFortuna: Persona(name: "Bib Fortunate", canSit: false, headTop: 21,
                  draw: drawBibFortuna),
]

// MARK: - Shared

/// The idle flourish playing right now, if any (standing idle, not walking or fighting).
private func flourish(_ p: Pose) -> HabitPlay? {
    guard !p.walking, p.mode == .idle, p.resting, let h = idleHabit, h.kind == .flourish else { return nil }
    return h
}

/// Where a held pistol sits relative to its resting height. A villain's gun only moves with its recoil and the idle
/// check: it isn't raised while waiting or cheering.
private func gunOffset(_ p: Pose) -> Int { -p.recoil - (p.mode == .idle ? p.gunLift : 0) }

/// A glint of light down the front of each boot (not when sitting), lifting with the leg as it steps.
private func drawBootShine(_ c: PixelCanvas, step: Int, _ col: Px) {
    guard !seatedPose else { return }
    for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx, step >= 0 && i % 2 == step ? 40 : 41, col) }
}

/// The hilt of a saber that isn't lit, at the belt.
private func drawHilt(_ c: PixelCanvas) {
    c.rect(36, 37, 2, 5, C(0xB9BEC8)); c.rect(36, 39, 2, 1, C(0x2A2A2F))
}

/// A gown or robe from `top` to the floor, widening to the hem (drawn instead of legs).
private func drawSkirt(_ c: PixelCanvas, from top: Int = 38, _ main: Px, _ edge: Px) {
    for y in top...43 {
        let k = (y - top) / 2
        c.rect(18 - k, y, 20 + k * 2, 1, main)
        c.px(18 - k, y, edge); c.px(37 + k, y, edge)
    }
}

// MARK: - Sebulba

/// Sebulba in his pod racer: two big orange engines out front, the cockpit tub behind, hovering. The flame jet
/// he used on Anakin is its weapon (fired from the front of the near engine).
private func drawSebulba(_ c: PixelCanvas, _ p: Pose) {
    let t = p.t, lift = p.breathe
    let base = c.oy
    c.rect(10, 43, 58, 1, C(0x000000).alpha(0.22))                   // its shadow on the ground
    c.oy = base + Int((sin(t * 3) * 1.2).rounded()) - 2
    let orange = C(0xD86A1E), orangeDark = C(0xA84E14), metal = C(0x8A8F99), dark = C(0x2E2E34)
    // The far engine, up and behind, and the energy binder between the two.
    c.rect(42, 19, 24, 6, orangeDark)
    c.rect(64, 19, 3, 6, dark)
    let binder = Int(t * 12) % 2 == 0 ? C(0x9FD8FF) : C(0x6FB8FF)
    c.rect(52, 25, 1, 3, binder); c.rect(58, 25, 1, 3, binder)
    // The near engine.
    c.rect(38, 27, 30, 8, orange)
    c.rect(38, 33, 30, 2, orangeDark)
    c.rect(38, 28, 30, 1, C(0xF0904A))
    c.rect(66, 27, 3, 8, metal); c.rect(68, 28, 2, 6, dark)          // the intake
    c.rect(42, 24, 6, 3, orangeDark)                                 // its fin
    c.rect(54, 35, 4, 2, orangeDark)
    if Int(t * 15) % 2 == 0 { c.rect(35, 29, 3, 4, C(0xFF9A2A)) } else { c.rect(36, 30, 2, 2, C(0xFFE27A)) }
    // Control cables back to the cockpit.
    c.glowLine(38, 31, 30, 32, core: metal, glow: C(0, 0), coreR: 0.5, glowR: 0.6)
    c.glowLine(42, 23, 30, 30, core: metal, glow: C(0, 0), coreR: 0.5, glowR: 0.6)
    // Sebulba, a Dug, up in the cockpit: leather cap, small eyes, the big mouth.
    c.oy += lift
    c.pattern(15, 21, [
        "...LLLLLL...",
        ".LLLLLLLLLL.",
        "LSSSSSSSSSSL",
        "SSSSSSKSSSKS",
        "SSSSSSSSSSSS",
        "SSSSSMMMMMMS",
        "SSSSSSSSSSSS",
        ".SSSSSSSSSS.",
    ], ["L": C(0x5A3A22), "S": C(0xB89068), "K": ink, "M": C(0x5A2A1A)])
    c.rect(26, 28, 3, 2, C(0xB89068))                                // a hand on the controls
    c.oy -= lift
    // The cockpit tub.
    c.pattern(8, 28, [
        "......OOOOOOOOOOOOOOOOOO",
        "...OOOOOOOOOOOOOOOOOOOOO",
        ".OOOOOOOOOOOOOOOOOOOOOOO",
        "OOOOOOOOOOOOOOOOOOOOOOOO",
        "OOOOOoOOOOOOOOOOOOoOOOOO",
        "oOOOOOOOOOOOOOOOOOOOOOOo",
        ".oooOOOOOOOOOOOOOOOOOoo.",
        "...ooooooooooooooooooo..",
    ], ["O": orange, "o": orangeDark])
    c.rect(14, 31, 12, 1, dark)
    c.oy = base
}

// MARK: - Salacious Crumb

/// Salacious B. Crumb: Jabba's cackling Kowakian monkey-lizard, ears out wide and a long tail.
private func drawSalacious(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xC8A070), dark = C(0x9A7448)
    let laugh = sin(p.t * 11) > 0
    let base = c.oy
    c.rect(24, 38, 2, 5, dark); c.rect(31, 38, 2, 5, dark)
    c.rect(23, 43, 4, 1, dark); c.rect(30, 43, 4, 1, dark)
    c.glowLine(22, 36, 12, Double(30 + (laugh ? 1 : 0)), core: dark, glow: C(0, 0), coreR: 0.6, glowR: 0.7)   // tail
    c.oy = base + p.breathe + (laugh ? -1 : 0)
    c.rect(22, 29, 13, 10, skin)
    c.rect(22, 37, 13, 1, dark)
    c.rect(35, 31, 3, 2, skin)                                       // a little arm, slapping a knee
    c.pattern(18, 18, [
        "EEE................EEE",
        "EEEE..............EEEE",
        ".EEEE..SSSSSSSS..EEEE.",
        "..EEEESSSSSSSSSSEEEE..",
        "...EEESSSSSSSSSSSEE...",
        "......SSSSSSSSSSSS....",
        "......SSSKSSSSKSSS....",
        "......SSSSSSSSSSSSNNN.",
        "......SSSSSSSSSSSSNN..",
        laugh ? "......SSMMMMMMSSSS...." : "......SSSMMMMSSSSS....",
        ".......SSSSSSSSSS.....",
    ], ["E": dark, "S": skin, "K": ink, "N": dark, "M": C(0x5A1A1A)])
    c.px(27, 17, dark); c.px(29, 16, dark)                          // a tuft
    c.oy = base
}

// MARK: - General Grievous

/// General Grievous: a white bone mask with yellow eyes over a grey cyborg body, a ragged cape, and four sabers, two
/// from the front hands and two from the back ones. Signature: the famous cough.
private func drawGrievous(_ c: PixelCanvas, _ p: Pose) {
    var lift = p.breathe
    if let s = p.signature, s > 0.1, s < 0.85 {                      // hunched, jerking on every hack
        c.oy += frac(s * 2.2 * 3.2) < 0.35 ? 1 : 0
        lift = 0
    }
    drawCape(c, t: p.t, speed: p.capeSpeed * 0.7, color: C(0x3A3028), edge: C(0x5A4A3A))
    let metal = C(0x9AA0A8), metalDark = C(0x6E747C)
    drawLegs(c, Look(leg: metalDark), step: p.step)
    c.oy += lift
    drawBody(c, Look(body: metal, shade: metalDark, arm: metal, eye: nil))
    c.rect(13, 31, 3, 3, metal)                                      // the second pair of arms
    c.rect(38, 30, 3, 3, metalDark)
    c.rect(22, 31, 12, 5, C(0x5A4A3A))                               // the organ sack
    c.rect(22, 31, 12, 1, metalDark)
    c.pattern(18, 14, [
        "......BBBBBBBB......",
        "....BBBBBBBBBBBB....",
        "...BBBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBBBBB.",
        "..BBBBBBBBBBBBBBBBB.",
        "..BBBBBBBBBBBBBBBBB.",
        "..BBBBBBBBBBBBBBBBB.",
        "...BBBBBBBBBBBBBBB..",
        "...BBbbbBBBBBbbbBB..",
        "...BBbYbBBBBBbYbBB..",
        "....BBBBBBBBBBBBB...",
        ".....BBBdBdBdBBB....",
        ".....BBBBBBBBBBB....",
        "......BBBBBBBBB.....",
    ], ["B": C(0xEDE6D2), "b": C(0x2A2418), "Y": C(0xF0D040), "d": C(0x8A8270)])
    if let s = p.signature, s > 0.1, s < 0.95 {
        // The cough: a wheezing hack with a little puff out of the mask on every beat.
        let e = s * 2.2 * 3.2                                        // coughs at 3.2 a second
        c.rect(23, 27, 4, 1, C(0xEDE6D2)); c.rect(31, 27, 4, 1, C(0xEDE6D2))   // eyes squeezed shut
        if frac(e) < 0.6 {
            let f = frac(e) / 0.6
            c.rect(37 + Int(f * 6), 23 - Int(f * 3), 3, 2, C(0xE8E4DA).alpha(0.9 * (1 - f)))
            c.rect(38 + Int(f * 4), 25 - Int(f * 2), 2, 2, C(0xC8C4BA).alpha(0.7 * (1 - f)))
            if f < 0.3 { c.px(36, 24, C(0xFFFFFF)) }                 // the hack itself
        }
    }
    // Four arms, four blades: two forward, two from the back hands.
    let blue = (core: C(0xE6F4FF), glow: C(0x3D9BFF)), green = (core: C(0xEAFFEA), glow: C(0x3FE85A))
    if let angle = p.melee {
        c.ox -= 22; c.oy -= 2
        drawSaber(c, t: p.t, angle: 180 - angle * 0.6 + 40, core: blue.core, glow: blue.glow, lit: true, length: 17)
        drawSaber(c, t: p.t, angle: 180 - angle * 0.6 + 75, core: green.core, glow: green.glow, lit: true, length: 17)
        c.ox += 22; c.oy += 2
        drawSaber(c, t: p.t, angle: angle + 30, core: blue.core, glow: blue.glow, lit: true)
        drawSaber(c, t: p.t, angle: angle, core: green.core, glow: green.glow, lit: true, trail: p.trail)
    } else {
        c.rect(36, 37, 2, 5, C(0xB9BEC8)); c.rect(13, 34, 2, 5, C(0xB9BEC8))
    }
}

// MARK: - Tusken Raider

/// The Tusken Raider's gaffi stick: a metal-capped club, flared at the head.
private func drawGaffi(_ c: PixelCanvas, angle: Double) {
    let hx = Sprite.hand.x, hy = Sprite.hand.y
    let r = angle * .pi / 180, ux = cos(r), uy = sin(r), px = -uy, py = ux
    c.glowLine(hx - ux * 6, hy - uy * 6, hx + ux * 17, hy + uy * 17, core: C(0x8A7458), glow: C(0, 0), coreR: 0.7, glowR: 0.8)
    for s in [-1.0, 1.0] {
        c.glowLine(hx + ux * 15, hy + uy * 15, hx + ux * 18 + px * 3 * s, hy + uy * 18 + py * 3 * s,
                   core: C(0xA9AEB8), glow: C(0, 0), coreR: 0.7, glowR: 0.8)
    }
    c.glowLine(hx - ux * 6, hy - uy * 6, hx - ux * 8, hy - uy * 8, core: C(0xA9AEB8), glow: C(0, 0), coreR: 0.8, glowR: 0.9)
}

/// A Tusken Raider: sand-coloured wrappings, goggle tubes, the breath mask, the gaffi stick. Always angry: when it
/// isn't fighting it shakes the gaffi over its head and hops; its flourish swings it up and back.
private func drawTusken(_ c: PixelCanvas, _ p: Pose) {
    var angle = p.melee, lift = p.breathe
    if let h = flourish(p) { angle = -78 - 70 * habitArc(h.p, hold: 0.1) }
    if !p.walking, angle == nil {
        angle = -100 + 25 * sin(p.t * 9)
        c.oy = cheerHop(p.t * 0.8) + (p.seated ? 4 : 0)
        lift = 0
    }
    let wrap = C(0xC8B48A), wrapDark = C(0xA08A64), robe = C(0x7A5A3A), metal = C(0x7A7E88)
    let wrapHi = C(0xDECCA2), robeHi = C(0x94704A), robeDeep = C(0x5A4028), metalHi = C(0xA8ACB6)
    drawLegs(c, Look(leg: wrapDark), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx, 38, 2, 1, wrap); c.px(lx + 1, 40, wrap) } }   // leg wraps
    drawBoots(c, C(0x5A4230), step: p.step, rows: 1)                // wrapped hide boots
    c.oy += lift
    drawBody(c, Look(body: wrap, shade: wrapDark, arm: wrap, eye: nil))
    c.rect(15, 34, 3, 1, wrapDark); c.rect(38, 34, 3, 1, wrapDark)  // the arms wound in strips
    // The head wound in cloth: the turns catching the light along their tops, their edges in shadow.
    c.pattern(17, 19, [
        ".....WWWlllWWWWWW.....",
        "...WWllWwwWWWWwwWWW...",
        "..WlWWWWWWWWWWWWWWWW..",
        ".WWwwWWWWllWWWWWwwWWW.",
        ".WWWWWWWWWWWWWWWWWWWW.",
        "WWWWWwwWWWWllWWWWwWWWW",
        "WWWWWWWWWWWWWWWWWWWWWW",
    ], ["W": wrap, "w": wrapDark, "l": wrapHi])
    for x in [19, 24, 33] { c.rect(x, 27, 1, 5, wrapDark); c.px(x + 1, 27, wrapHi) }   // the wrappings
    for ex in [22, 31] {                                              // goggle tubes, lit along the rim
        c.rect(ex, 28, 4, 3, metal)
        c.rect(ex, 28, 4, 1, metalHi)
        c.rect(ex + 1, 29, 2, 1, ink)
    }
    c.rect(26, 32, 4, 2, metal)                                       // breath mask, its grille
    c.px(25, 33, metal); c.px(30, 33, metal)
    c.rect(26, 32, 2, 1, metalHi); c.px(27, 33, C(0x4A4E58)); c.px(29, 33, C(0x4A4E58))
    // The robe: lit at the neck, folds shaded, the strap across with a brass buckle and a pouch.
    c.rect(18, 34, 20, 4, robe)
    c.rect(18, 34, 20, 1, robeHi); c.rect(37, 34, 1, 4, robeDeep)
    c.px(21, 36, robeDeep); c.px(34, 37, robeDeep); c.px(29, 37, robeDeep)
    for i in 0..<9 { c.px(19 + i * 2, 34 + i / 3, C(0x4A3420)) }     // a strap across
    c.px(27, 35, C(0xB08D57))
    c.rect(31, 36, 2, 2, C(0x4A3420)); c.px(31, 36, robeHi)
    drawGaffi(c, angle: angle ?? -75)
}

// MARK: - Cad Bane

/// Cad Bane: wide-brimmed hat, blue Duros skin and red eyes, the high-collared coat; a blaster pistol.
private func drawCadBane(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x5A8A9A), coat = C(0x6A4A32), coatDark = C(0x4A3222), hat = C(0x7A5A3A), coatHi = C(0x86603E)
    let tube = C(0x8A8F99)
    drawLegs(c, Look(leg: C(0x3A3A40)), step: p.step)
    drawBoots(c, C(0x241C16), step: p.step, rows: 2)                // dark leather boots
    drawBootShine(c, step: p.step, C(0x5A5048))
    c.oy += p.breathe
    drawBody(c, Look(body: skin, shade: C(0x467080), arm: coat, eye: nil))
    c.rect(19, 23, 18, 3, skin)
    c.rect(19, 23, 18, 1, C(0x467080))                              // the brim's shadow on his brow
    c.pattern(10, 15, [
        "...........HHHHHHHHHHHHHH...........",
        "...........HHHHHHHHHHHHHH...........",
        "...........HHHHHHHHHHHHHH...........",
        "...........hhhhhhhhhhhhhh...........",
        "..BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB..",
        "....BBBBBBBBBBBBBBBBBBBBBBBBBBBB....",
    ], ["H": hat, "h": C(0x3A2A1A), "B": C(0x5A4028)])
    // The hat: light along the crown, its far side and the brim's underside in shadow, a stud on the band.
    c.rect(22, 15, 5, 1, C(0x9A7A52)); c.rect(21, 16, 2, 1, C(0x9A7A52))
    c.rect(34, 15, 1, 3, C(0x5E4430))
    c.rect(14, 20, 28, 1, C(0x45301E)); c.rect(12, 19, 8, 1, C(0x6E5236))
    c.px(23, 18, C(0xB08D57))
    c.rect(22, 28, 3, 2, C(0xE0302A)); c.rect(31, 28, 3, 2, C(0xE0302A))
    c.px(22, 28, C(0xFF7A6A)); c.px(31, 28, C(0xFF7A6A))
    // His breathing tubes, one on each cheek, lit on top.
    c.rect(35, 30, 2, 3, tube); c.rect(19, 30, 2, 3, tube)
    c.px(35, 30, C(0xC4C8D0)); c.px(19, 30, C(0xC4C8D0))
    // The high collar, lit along its turned-up rim.
    c.rect(18, 31, 20, 2, coatDark)
    c.rect(18, 31, 5, 1, coatHi); c.rect(33, 31, 5, 1, coatHi)
    // The coat: lapels either side of the dark vest, folds shaded, cuffs.
    c.rect(18, 33, 20, 5, coat)
    c.rect(27, 33, 2, 3, C(0x3A3030)); c.rect(26, 33, 1, 2, coatHi); c.rect(29, 33, 1, 2, coatHi)
    c.rect(37, 33, 1, 5, coatDark); c.px(21, 34, coatDark); c.px(34, 37, coatDark)
    c.rect(15, 35, 3, 1, coatDark); c.rect(38, 35, 3, 1, coatDark)
    // The gun belt, its brass buckle and the holster at his hip.
    c.rect(18, 36, 20, 1, coatDark)
    c.rect(27, 36, 2, 1, C(0xB08D57)); c.px(27, 36, C(0xE0C080))
    c.rect(33, 36, 2, 2, C(0x2A1E16))
    c.oy += gunOffset(p)
    drawPistol(c, x: 40, y: 31)
}

// MARK: - Admiral Thrawn

/// Grand Admiral Thrawn: blue skin, glowing red eyes, slicked black hair, the white uniform; a blaster pistol.
private func drawThrawn(_ c: PixelCanvas, _ p: Pose) {
    let uniform = C(0xF2F2EC), shade = C(0xC8C8C0), gold = C(0xE0B84A), goldDark = C(0xA8842A)
    drawLegs(c, Look(leg: C(0xE0E0D8)), step: p.step)
    drawBoots(c, ink, step: p.step, rows: 3)                        // tall black boots, polished
    drawBootShine(c, step: p.step, C(0x5C6070))
    c.oy += p.breathe
    drawBody(c, Look(body: C(0x4A6AC0), shade: C(0x3A56A0), arm: uniform, eye: C(0xFF3A3A)))
    c.rect(15, 35, 3, 1, shade); c.rect(38, 35, 3, 1, shade)        // the tunic's cuffs
    // Slicked-back blue-black hair, the light running along it.
    c.pattern(18, 22, ["...KKKKKllllKKKKK...", ".KKKllllKKKKKKKKKKK.", "KKKKKKKKKKKKKKKKKKKK", "KK................KK"],
              ["K": C(0x14141C), "l": C(0x34426C)])
    // The white tunic: the high collar, the double-breasted flap, folds shaded down the side.
    c.rect(18, 33, 20, 5, uniform)
    c.rect(18, 33, 20, 1, shade)
    c.rect(25, 33, 6, 1, C(0xB0B0A8))
    c.rect(31, 34, 1, 3, shade); c.rect(37, 33, 1, 5, shade)
    c.px(33, 34, C(0xB0B0A8)); c.px(33, 36, C(0xB0B0A8))           // the flap's buttons
    // The rank plaque in its silver rim, with its code cylinders above.
    c.rect(21, 34, 4, 1, C(0x8E9296))
    c.px(21, 35, C(0xD84A2A)); c.px(22, 35, C(0x3A6ED8)); c.px(23, 35, gold); c.px(24, 35, C(0xD84A2A))
    // The gold epaulettes, shaded underneath.
    c.rect(15, 32, 3, 1, gold); c.rect(38, 32, 3, 1, gold)
    c.px(15, 33, goldDark); c.px(17, 33, goldDark); c.px(38, 33, goldDark); c.px(40, 33, goldDark)
    // A white belt with its gold buckle.
    c.rect(18, 37, 20, 1, shade)
    c.rect(27, 37, 2, 1, gold)
    c.oy += gunOffset(p)
    drawPistol(c, x: 40, y: 31)
}

// MARK: - Hammerhead

/// Hammerhead (Momaw Nadon, of the cantina): an Ithorian, the long T-shaped head on a tall neck, in robes.
private func drawHammerhead(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x8A6A4A), skinDark = C(0x6A4E34), robe = C(0x8A3A2A), robeDark = C(0x6A2A1E)
    let skinHi = C(0xA6865E), robeHi = C(0xA44A36), robeDeep = C(0x501E14)
    drawSkirt(c, from: 36, robe, robeDark)
    // The robe falls to the floor: folds catching the light down it, a shadow either side of each of the four legs
    // under the cloth, and a hem in shadow.
    for x in [21, 25, 30, 34] { c.rect(x, 38, 1, 5, robeHi) }
    for x in [18, 22, 33, 37] { c.rect(x, 40, 1, 3, robeDeep) }
    c.rect(16, 43, 24, 1, robeDeep)
    c.oy += p.breathe
    var look = Look(body: robe, shade: robeDark, arm: skin, eye: nil)
    look.legs = false
    drawBody(c, look)
    c.pattern(12, 10, [
        ".SSS..........................SSS.",
        "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS",
        "SWWSSSSSSSSSSSSSSSSSSSSSSSSSSSSWWS",
        "SWESSSSSSSSSSSSSSSSSSSSSSSSSSSSEWS",
        ".sSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSs.",
        "...ssSSSSSSSSSSSSSSSSSSSSSSSSss...",
        ".........SSSSSSSSSSSSSSSS.........",
        "............SSSSSSSSSS............",
        "............SSSSSSSSSs............",
        "............SSSSSSSSSs............",
        "............SSSSSSSSSs............",
        "............SSSSSSSSSs............",
        "............SSSSSSMMSs............",
        "............SSSSSSSSSs............",
        "............SSSSSSSSSs............",
        "............SSSSSSSSSs............",
        "...........SSSSSSSSSSSS...........",
    ], ["S": skin, "s": skinDark, "E": ink, "W": C(0xF0E2B0), "M": skinDark])
    // His hide: the light along the top of the head and down the neck, wrinkles in short strokes.
    c.rect(16, 11, 26, 1, skinHi); c.rect(24, 17, 1, 9, skinHi)
    c.rect(19, 13, 2, 1, skinDark); c.rect(27, 12, 3, 1, skinDark); c.rect(36, 13, 2, 1, skinDark)
    c.rect(26, 19, 2, 1, skinDark); c.rect(29, 21, 2, 1, skinDark); c.rect(26, 24, 2, 1, skinDark)
    // The robe: lit over the shoulders, its front edge and folds, a dark belt with a bronze clasp, the sleeves.
    c.rect(18, 26, 5, 1, robeHi); c.rect(35, 26, 2, 1, robeHi)
    c.rect(29, 27, 1, 6, robeDark); c.px(30, 27, robeHi)
    c.px(21, 29, robeDark); c.px(34, 30, robeDark); c.px(23, 35, robeDark)
    c.rect(18, 33, 20, 1, robeDark)
    c.rect(27, 33, 2, 1, C(0xB08D57)); c.px(27, 33, C(0xE0C080))
    c.rect(15, 33, 3, 1, robe); c.rect(38, 33, 3, 1, robe)          // the sleeves over his hands
}

// MARK: - MSE-6

/// An MSE-6 "mouse" droid: a little black box on wheels, scurrying back and forth.
private func drawMse6(_ c: PixelCanvas, _ p: Pose) {
    let t = p.t
    let run = sin(t * 1.3)
    c.ox += Int((run * 6).rounded())
    let black = C(0x1E1E22)
    c.rect(20, 42, 4, 2, C(0x3A3A42)); c.rect(33, 42, 4, 2, C(0x3A3A42))
    c.rect(18, 36, 22, 6, black)
    c.rect(19, 35, 20, 1, C(0x3A3A42))
    c.rect(22, 37, 6, 2, C(0x6A6E78)); c.rect(30, 37, 6, 2, C(0x6A6E78))
    c.px(39, 38, Int(t * 4) % 2 == 0 ? C(0xFF3A3A) : C(0x7A2A20))
}

// MARK: - Baylan Skoll

/// Baylan Skoll: long grey hair and beard over a dark cloak, an orange saber. When he isn't fighting he strokes his
/// beard.
private func drawBaylan(_ c: PixelCanvas, _ p: Pose) {
    drawCape(c, t: p.t, speed: p.capeSpeed * 0.6, color: C(0x2A2420), edge: C(0x4A3A2E), extra: 1)
    let robe = C(0x3A302A), robeHi = C(0x52443A), robeDeep = C(0x2A221E)
    let grey = C(0xB8B4AC), greyDark = C(0x8E8A84), greyHi = C(0xDAD6CE)
    drawLegs(c, Look(leg: C(0x2A2622)), step: p.step)
    drawBoots(c, ink, step: p.step, rows: 2)                        // black boots, a glint down the front
    drawBootShine(c, step: p.step, C(0x5A5048))
    c.oy += p.breathe
    let stroke = p.melee == nil && !p.walking && sin(p.lt * 0.6) > 0.3
    drawBody(c, Look(arm: robe), armRight: stroke ? 4 : 0)
    c.rect(15, 35, 3, 1, robeDeep); c.rect(38, stroke ? 31 : 35, 3, 1, robeDeep)   // the sleeves' cuffs
    // Long grey hair swept back, the light running along it, darker strands falling at the sides.
    c.pattern(17, 21, [
        ".....GGGlllGGGGGG.....",
        "...GGGllGGGGGlllGGG...",
        "..GGGgGGGGGGGGGGgGGG..",
        ".GGlGGGGGGGGGGGGGGgGG.",
        ".GlG..............GgG.",
        "GlG................GgG",
        "Gl..................gG",
        "Gl..................gG",
    ], ["G": grey, "g": greyDark, "l": greyHi])
    // The dark robe: its lit edges down the front, folds shaded, a belt with a bronze buckle.
    c.rect(18, 34, 20, 4, robe)
    c.rect(37, 34, 1, 4, robeDeep)
    c.rect(18, 34, 1, 3, robeHi); c.rect(36, 34, 1, 3, robeHi)
    c.rect(18, 37, 20, 1, C(0x4E3E2E)); c.rect(27, 37, 2, 1, C(0xB08D57))
    // The pauldron on his far shoulder, lit along the top, a rivet in it.
    c.rect(15, 33, 4, 2, C(0x5A4A3A))
    c.rect(15, 33, 4, 1, C(0x7A6650)); c.px(17, 34, C(0xA89070))
    // The beard: strands catching the light, the moustache shaded.
    c.pattern(19, 31, [
        "GG..............GG",
        "GGG...gggggg...GGG",
        "GGGlGGGGGGGGGGlGGG",
        ".GGGlGGGgGGGGlGGG.",
        "...GGlGGGGGGgGG...",
        ".....GGlGGgGG.....",
    ], ["G": grey, "g": greyDark, "l": greyHi])
    if let angle = p.melee {
        drawSaber(c, t: p.t, angle: angle, core: C(0xFFF0D8), glow: C(0xFF8A1E), lit: true, trail: p.trail, length: 20)
    } else {
        drawHilt(c)
    }
}

// MARK: - Shin Hati

/// Shin Hati: short platinum hair with a braid at the back, dark armoured robes, an orange saber. She can't keep
/// still: now and then she lights it and runs through a few moves.
private func drawShinHati(_ c: PixelCanvas, _ p: Pose) {
    var angle = p.melee, trail = p.trail
    if !p.walking, angle == nil, frac(p.lt / 7) < 0.3 {
        angle = kataPose(p.lt).angle; trail = saberTrail(p.lt)
    }
    let suit = C(0x2E2E36), plate = C(0x4A4A56), hair = C(0xE8DCB0), hairDark = C(0xC2B488)
    let plateHi = C(0x6E6E7C), hairHi = C(0xFFF6DC), deep = C(0x1C1C22)
    drawLegs(c, Look(leg: C(0x26262C)), step: p.step)
    drawBoots(c, ink, step: p.step, rows: 2)                        // black boots, a glint down the front
    drawBootShine(c, step: p.step, C(0x4A4C56))
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    c.rect(15, 35, 3, 1, deep); c.rect(38, 35, 3, 1, deep)          // the gloves
    c.rect(15, 33, 3, 1, plate); c.rect(38, 33, 3, 1, plate)        // plates over the shoulders
    // Short platinum hair, the light running along it, the far side in shadow.
    c.pattern(18, 21, [
        "......BBBhhhBB......",
        "...BBBhhBBBBBBBBB...",
        ".BBhBbBBBBBBBBBBBbB.",
        "BBBBBBBBBBBBBBBBBbBB",
        "BBb..............bBB",
        "BB................BB",
    ], ["B": hair, "b": hairDark, "h": hairHi])
    // The braid, lit on alternate twists, tied off at the end.
    c.pattern(16, 24, ["Bh", "bB", "Bh", "bB", ".K"], ["B": hair, "b": hairDark, "h": hairHi, "K": plate])
    // The armoured robe: the neck of its collar, plates lit along the top with a rivet in each, folds shaded.
    c.rect(18, 33, 20, 5, suit)
    c.rect(18, 33, 20, 1, plate)
    c.rect(25, 33, 6, 1, deep)
    c.rect(20, 34, 5, 2, plate); c.rect(31, 34, 5, 2, plate)        // armour plates
    c.rect(20, 34, 5, 1, plateHi); c.rect(31, 34, 5, 1, plateHi)
    c.px(22, 35, deep); c.px(33, 35, deep)
    c.rect(37, 33, 1, 5, deep); c.px(27, 37, deep)
    // The belt, its brass buckle.
    c.rect(18, 36, 20, 1, C(0x6A4A2E))
    c.rect(27, 36, 2, 1, C(0xC9A44A)); c.px(27, 36, C(0xF0D47A))
    if let angle {
        drawSaber(c, t: p.t, angle: angle, core: C(0xFFF0D8), glow: C(0xFF8A1E), lit: true, trail: trail, length: 18)
    } else {
        drawHilt(c)
    }
}

// MARK: - ID9 Seeker Droid

/// An ID9 seeker droid: a black ball with one red eye, hovering, five spindly legs dangling under it; now and
/// then it sweeps the ground ahead with a red scan.
private func drawId9(_ c: PixelCanvas, _ p: Pose) {
    let t = p.t
    let base = c.oy
    c.rect(21, 43, 14, 1, C(0x000000).alpha(0.22))                  // its shadow
    c.oy = base + Int((sin(t * 2.4) * 1.5).rounded()) - 3
    let shell = C(0x2E3036), dark = C(0x16171B), light = C(0x6A6E78), red = C(0xFF2A2A)
    for (i, lx) in [21.0, 24.5, 28, 31.5, 35].enumerated() {
        let sway = sin(t * 3 + Double(i) * 1.3) * 1.2
        let knee = (x: 28 + (lx - 28) * 1.3, y: 36.0)
        c.glowLine(28 + (lx - 28) * 0.6, 31, knee.x, knee.y, core: dark, glow: C(0, 0), coreR: 0.5, glowR: 0.6)
        c.glowLine(knee.x, knee.y, knee.x + sway, 42, core: dark, glow: C(0, 0), coreR: 0.5, glowR: 0.6)
    }
    c.circle(28, 27, 7, shell)
    c.rect(21, 28, 15, 1, dark)
    c.px(25, 22, light); c.px(24, 23, light); c.px(26, 21, light)  // a glint on top
    let look = Int((sin(t * 1.1) * 2).rounded())
    c.circle(31 + look, 26, 2, C(0x3A0A0A))
    c.px(31 + look, 26, red); c.px(32 + look, 26, red); c.px(31 + look, 25, C(0xFFB0A0))
    let f = (t / 3).truncatingRemainder(dividingBy: 1)
    if f < 0.35 {                                                   // the scan, sweeping the ground ahead
        let k = f / 0.35
        c.glowLine(33, 26, 40 + k * 14, 43, core: red.alpha(0.5), glow: red, coreR: 0.4, glowR: 1.2, strength: 0.35)
    }
    c.oy = base
}

// MARK: - The Inquisitors

/// The ring-shaped hilt of an Inquisitor's saber, 5×5 from (x, y).
private func drawInquisitorRing(_ c: PixelCanvas, x: Int, y: Int) {
    c.pattern(x, y, [".SSS.", "S...S", "S...S", "S...S", ".SSS."], ["S": C(0x9AA0AA)])
}

/// An Inquisitor's double red blade on its ring hilt. It spins like a rotor while they wait or stand guard, and their
/// flourish is a burst of that spin; put away, the ring hangs at the belt.
private func drawRingSaber(_ c: PixelCanvas, _ p: Pose) {
    var angle = p.melee, trail = p.trail
    if let h = flourish(p) { angle = -60 + 900 * h.e * habitArc(h.p, hold: 0.6); trail = [] }
    if !p.walking, p.mode == .waiting || p.mode == .standGuard { angle = p.t * 900; trail = [] }
    if let angle {
        drawSaber(c, t: p.t, angle: angle + 180, core: C(0xFFE3E3), glow: C(0xFF1E2D), lit: true, length: 14)
        drawSaber(c, t: p.t, angle: angle, core: C(0xFFE3E3), glow: C(0xFF1E2D), lit: true, trail: trail, length: 14)
        drawInquisitorRing(c, x: Int(Sprite.hand.x) - 2, y: Int(Sprite.hand.y) - 2)
    } else {
        drawInquisitorRing(c, x: 35, y: 36)
    }
}

/// The Grand Inquisitor: a Pau'an, grey skin and a tall ridged skull, red lines on the face, yellow eyes, black
/// Imperial armour.
private func drawGrandInquisitor(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xC8C4BE), skinDark = C(0xA09C96), armour = C(0x1E1E24), red = C(0xB02A2A)
    drawLegs(c, Look(leg: C(0x1A1A20)), step: p.step)
    drawBoots(c, ink, step: p.step, rows: 2)
    drawBootShine(c, step: p.step, C(0x5C6070))
    c.oy += p.breathe
    drawBody(c, Look(body: skin, shade: skinDark, arm: armour, eye: nil))
    c.pattern(19, 17, [
        "....SSSSSSSSSS....",
        "..SSSSSSSSSSSSSS..",
        ".SSSsSSSsSSsSSSSS.",
        "SSSSsSSSsSSsSSSSSS",
        "SSSSsSSSsSSsSSSSSS",
        "SSSSSSSSSSSSSSSSSS",
        "SSSSSSSSSSSSSSSSSS",
        "SSSSSSSSSSSSSSSSSS",
        "SSSSSSSSSSSSSSSSSS",
    ], ["S": skin, "s": skinDark])
    c.rect(21, 28, 4, 1, skinDark); c.rect(31, 28, 4, 1, skinDark)  // the heavy brow
    c.rect(22, 29, 3, 2, C(0xF0C030)); c.rect(32, 29, 3, 2, C(0xF0C030))
    c.px(23, 29, red); c.px(33, 29, red)
    c.rect(20, 27, 1, 5, red); c.rect(36, 27, 1, 5, red)            // the red lines down the face
    c.rect(28, 25, 1, 3, red)
    c.rect(24, 32, 8, 1, C(0x5A5650))                               // the thin grin
    // The black armour: the collar's rim, ribbed plates down the chest, folds shaded at the side.
    c.rect(18, 33, 20, 5, armour)
    c.rect(18, 33, 20, 1, C(0x4A4A54))
    for x in [20, 23, 32, 35] { c.rect(x, 34, 1, 2, C(0x34343E)) }
    c.rect(37, 34, 1, 4, C(0x121216))
    // The belt, its silver buckle with a red light in it.
    c.rect(18, 36, 20, 1, C(0x2E2E36))
    c.rect(26, 35, 4, 1, C(0x8A8F99))
    c.rect(26, 36, 4, 1, C(0x8A8F99)); c.px(27, 36, C(0xD03030))
    // The pauldrons, lit along the top, a rivet in each.
    c.rect(14, 32, 4, 2, C(0x3A3A44)); c.rect(38, 32, 4, 2, C(0x3A3A44))
    c.rect(14, 32, 4, 1, C(0x5A5A66)); c.rect(38, 32, 4, 1, C(0x5A5A66))
    c.px(15, 33, C(0x8A8F99)); c.px(40, 33, C(0x8A8F99))
    c.rect(15, 35, 3, 1, C(0x121216)); c.rect(38, 35, 3, 1, C(0x121216))   // the gloves' cuffs
    drawRingSaber(c, p)
}

/// The Second Sister: the black Inquisitor helmet with its grey faceplate and dark eye slits, black armour.
private func drawSecondSister(_ c: PixelCanvas, _ p: Pose) {
    let black = C(0x1E1E26), blackDark = C(0x121218)
    drawLegs(c, Look(leg: C(0x1A1A20)), step: p.step)
    drawBoots(c, ink, step: p.step, rows: 2)
    drawBootShine(c, step: p.step, C(0x5C6070))
    c.oy += p.breathe
    drawBody(c, Look(body: black, shade: blackDark, arm: black, eye: nil))
    c.pattern(17, 18, [
        ".....HHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHH...",
        "..HHhhHHHHHHHHHHHHHH..",
        ".HHhHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHHfffffffffffffffFHHH",
        "HHfVVVVVVFFFFVVVVVVFHH",
        "HHfFVVVVFFlFFFVVVVFFHH",
        "HHfFFFFFFFlFFFFFFFFFHH",
        "HHHfFFFFFFRRFFFFFFFHHH",
        "HHHHfFFFFFFFFFFFFFHHHH",
        ".HHHHfFFFFFFFFFFFHHHH.",
        "..HHHHHHHHHHHHHHHHHH..",
        "...HHHHHHHHHHHHHHHH...",
    ], ["H": C(0x16161C), "h": C(0x4A4A58), "F": C(0x6A6C76), "V": C(0x0A0A0E), "R": C(0xC02A2A),
        "f": C(0x50525C), "l": C(0x8A8C96)])
    c.rect(15, 35, 3, 1, blackDark); c.rect(38, 35, 3, 1, blackDark)   // the gloves' cuffs
    c.rect(15, 33, 3, 1, C(0x34343E)); c.rect(38, 33, 3, 1, C(0x34343E))   // the shoulder plates, lit on top
    // The armoured suit: plates down the chest with seams between, folds shaded at the side.
    c.rect(18, 33, 20, 5, C(0x24242C))
    c.rect(18, 33, 20, 1, C(0x30303A))
    c.rect(22, 34, 1, 2, blackDark); c.rect(33, 34, 1, 2, blackDark); c.rect(37, 33, 1, 5, blackDark)
    // The silver belt and its buckle, the red badge over it.
    c.rect(18, 36, 20, 1, C(0x8A8F99))
    c.rect(27, 36, 2, 1, C(0xC8CCD6)); c.px(28, 36, C(0x5C6070))
    c.rect(26, 34, 4, 1, C(0xA02020)); c.px(26, 34, C(0xD84848))
    c.rect(18, 37, 20, 1, blackDark)
    drawRingSaber(c, p)
}

// MARK: - Bantha

/// A bantha: a huge shaggy beast of Tatooine, dark brown fur to the knees, great spiral horns. It chews and swishes
/// its tail.
private func drawBantha(_ c: PixelCanvas, _ p: Pose) {
    let t = p.lt
    let base = c.oy
    let fur = C(0x5A4636), furDark = C(0x3E3024), furLight = C(0x76604C), horn = C(0xCDB892), hornDark = C(0x9A8462)
    for (i, lx) in [15, 22, 38, 45].enumerated() {
        let up = p.step >= 0 && i % 2 == p.step ? 1 : 0
        c.rect(lx, 33, 5, 10 - up, furDark)
        c.rect(lx, 42 - up, 5, 1, C(0x221A14))                      // hooves
    }
    c.oy = base + p.breathe
    let sway = sin(t * 1.5) * 1.5
    c.glowLine(10, 23, 6 + sway, 33, core: furDark, glow: C(0, 0), coreR: 1.0, glowR: 1.1)
    c.ellipse(30, 25, 21, 10, fur)
    for x in 10...50 {                                              // the long fringe hanging off its sides
        c.rect(x, 31, 1, 4 + Int(noise(x * 7) * 4), x % 3 == 0 ? furDark : fur)
    }
    for (x, y) in [(16, 20), (22, 18), (30, 17), (38, 19), (44, 22), (19, 26), (27, 24), (35, 25), (41, 28)] {
        c.rect(x, y, 1, 3, furLight)
    }
    c.ellipse(53, 28, 7, 7, fur)                                    // the head
    for x in 48...58 { c.rect(x, 34, 1, 2 + Int(noise(x * 5 + 1) * 3), furDark) }   // beard
    c.ellipse(57, 31, 4, 3, furDark)                                // muzzle
    let chew = Int(t * 3) % 2
    c.rect(56, 33 + chew, 4, 1, C(0x221A14))
    c.rect(55, 26, 2, 1, ink)
    c.pattern(45, 18, [                                             // a great curled horn
        "..HHHHH..",
        ".HHhhhHH.",
        "HHh...hHH",
        "HH.....HH",
        "HH...hHHH",
        ".HH..HHH.",
        "..H.HH...",
        "....H....",
    ], ["H": horn, "h": hornDark])
    c.oy = base
}

// MARK: - Bib Fortuna

/// Bib Fortuna, Jabba's majordomo: a pale Twi'lek, a long head-tail down his back and one over his shoulder, red
/// eyes, pointed teeth, dark robes to the floor.
private func drawBibFortuna(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xE6D8C8), skinDark = C(0xBFAE9C), robe = C(0x2E2420), robeEdge = C(0x4A3A30)
    let robeDeep = C(0x1C1612), gold = C(0xC9A44A)
    drawSkirt(c, from: 36, robe, robeEdge)
    // The robes fall to the floor: folds catching the light down them, a shadow either side of each of the four legs
    // under the cloth, and a hem in shadow.
    for x in [21, 25, 30, 34] { c.rect(x, 38, 1, 5, robeEdge) }
    for x in [18, 22, 33, 37] { c.rect(x, 40, 1, 3, robeDeep) }
    c.rect(16, 43, 24, 1, robeDeep)
    c.oy += p.breathe
    let sway = sin(p.lt * 1.2)
    for (r, col) in [(1.9, skinDark), (1.1, skin)] {               // the long lekku down his back
        c.glowLine(19, 24, 14, 31, core: col, glow: C(0, 0), coreR: r, glowR: r + 0.1)
        c.glowLine(14, 31, 13 + sway, 41, core: col, glow: C(0, 0), coreR: r, glowR: r + 0.1)
    }
    var look = Look(body: skin, shade: skinDark, arm: robe, eye: nil)
    look.legs = false
    drawBody(c, look)
    // His head: the light along the crown, the far side in shadow, furrows across the brow.
    c.pattern(19, 21, [
        "....SSSsssSSSS....",
        "..SSssSSSSSSSSSS..",
        ".SSsSsSSSSSSSSSdS.",
        "SSSSSSSSSSSSSSSSdS",
        "SSSSSSSSSSSSSSSSdS",
    ], ["S": skin, "s": C(0xF4EAE0), "d": skinDark])
    c.rect(24, 25, 3, 1, skinDark); c.rect(30, 25, 2, 1, skinDark); c.rect(26, 26, 4, 1, skinDark)
    c.rect(21, 28, 4, 1, skinDark); c.rect(31, 28, 4, 1, skinDark)
    c.rect(22, 29, 2, 2, C(0xA82A2A)); c.rect(32, 29, 2, 2, C(0xA82A2A))
    c.px(22, 29, C(0xE06A5A)); c.px(32, 29, C(0xE06A5A))
    c.rect(22, 31, 2, 1, skinDark); c.rect(32, 31, 2, 1, skinDark)  // the shadows under his eyes
    c.pattern(24, 32, ["KKKKKKKK", "KWKWKWKK"], ["K": ink, "W": white])   // the grin
    // The dark robes: the front's overlapping edge, folds shaded, the collar lit along its rim with a gold clasp.
    c.rect(18, 34, 20, 4, robe)
    c.rect(37, 34, 1, 4, robeEdge)
    c.rect(29, 35, 1, 3, robeEdge); c.rect(30, 35, 1, 3, robeDeep)
    c.px(21, 36, robeDeep); c.px(25, 37, robeDeep); c.px(34, 36, robeDeep)
    c.rect(22, 34, 12, 1, C(0x9A8A6A))                              // the collar
    c.rect(23, 34, 4, 1, C(0xBCAC88)); c.px(22, 34, C(0x7A6A50)); c.px(33, 34, C(0x7A6A50))
    c.rect(28, 34, 2, 1, gold); c.px(28, 34, C(0xF0D47A))
    c.rect(15, 35, 3, 1, robeEdge); c.rect(38, 35, 3, 1, robeEdge)  // the sleeves' cuffs
    for (r, col) in [(1.5, skinDark), (0.8, skin)] {               // the other lekku, over his shoulder
        c.glowLine(35, 25, 36, 36, core: col, glow: C(0, 0), coreR: r, glowR: r + 0.1)
    }
}
