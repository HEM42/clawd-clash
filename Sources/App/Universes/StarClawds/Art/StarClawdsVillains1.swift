import Foundation

// Star Wars villains: the originals.

let starWarsVillains1: [SWVillain: Persona] = [
    .vader: Persona(name: "Darth Vapor", weapon: .saber, headTop: 14, signature: 2.6,
                  draw: drawVader),
    .kylo: Persona(name: "Kylo Rant", weapon: .saber, headTop: 15, signature: 1.8,
                  draw: drawKylo),
    .maul: Persona(name: "Darth Mall", weapon: .saber, headTop: 23,
                  draw: drawMaul),
    .boba: Persona(name: "Boba Feta", weapon: .blaster, armoured: true, muzzle: (52, 32), headTop: 11, signature: 2.6,
                  draw: drawBoba),
    .trooper: Persona(name: "Stormtrouper", weapon: .blaster, armoured: true, muzzle: (52, 32), headTop: 16, signature: 2.6,
                  missesEverything: true, draw: drawTrooper),
    .emperor: Persona(name: "The Emperor", weapon: .lightning, canSit: false, headTop: 19,
                  draw: drawEmperor),
    .rogr: Persona(name: "R0-DG3R", weapon: .blaster, armoured: true, muzzle: (52, 32), headTop: 15, callout: "Roger roger!",
                  draw: drawRogr),
    .dooku: Persona(name: "Count Duku", weapon: .saber, headTop: 21,
                  draw: drawDooku),
    .gamorrean: Persona(name: "Gamoink Guard", weapon: .saber, headTop: 17,
                  draw: drawGamorrean),
    .jabba: Persona(name: "Jabbo the Glutt", canSit: false, headTop: 19, signature: 2.4, callout: "Ho ho ho!",
                  draw: drawJabba),
    .ig88: Persona(name: "IG-Ate-Ate", weapon: .blaster, armoured: true, muzzle: (52, 32), headTop: 9, signature: 2.4,
                  draw: drawIg88),
    .atst: Persona(name: "Chicken Walker", weapon: .blaster, armoured: true, canSit: false, muzzle: (47, 22), handGun: false, headTop: 10,
                  draw: drawAtst),
    .atat: Persona(name: "AT-ACK", weapon: .blaster, armoured: true, canSit: false, muzzle: (64, 21), handGun: false, headTop: 11,
                  draw: drawAtat),
    .rancor: Persona(name: "Rancor", weapon: .saber, canSit: false, pivot: rancorShoulder, headTop: 8, signature: 2,
                  draw: drawRancor),
    .greedo: Persona(name: "Greedy-O", weapon: .blaster, muzzle: (47, 32), headTop: 19,
                  draw: drawGreedo),
    .royalGuard: Persona(name: "Royal Guard", weapon: .saber, canSit: false, headTop: 13, fidgets: false,
                  draw: drawRoyalGuard),
]

// MARK: - Helpers

private let clear = C(0, 0)

/// The idle habit playing now, if this pose is the one it's played in (idle, standing, not fighting).
private func idlePlay(_ p: Pose) -> HabitPlay? {
    guard !p.walking, p.mode == .idle, let h = idleHabit else { return nil }
    switch p.role { case .none, .rest: return h; default: return nil }
}

/// An axe, claw or pike's idle flourish: swung up from `from` degrees and back, instead of spun round.
private func swungUp(_ p: Pose, from: Double) -> Double? {
    guard let h = idlePlay(p), h.kind == .flourish else { return p.melee }
    return from - 70 * habitArc(h.p, hold: 0.1)
}

/// Where a held gun sits: the villains only raise it to check it (idle), not while waiting or cheering.
private func gunY(_ p: Pose) -> Int { -p.recoil - (p.mode == .idle ? p.gunLift : 0) }

/// A glint of light down the front of each boot (not when sitting), lifting with the leg as it steps.
private func drawBootShine(_ c: PixelCanvas, step: Int, _ col: Px) {
    guard !seatedPose else { return }
    for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx, step >= 0 && i % 2 == step ? 40 : 41, col) }
}

/// A plain red saber, or its hilt at the belt when it's off.
private func drawRedSaber(_ c: PixelCanvas, _ p: Pose) {
    if let a = p.melee {
        drawSaber(c, t: p.t, angle: a, core: C(0xFFE3E3), glow: C(0xFF1E2D), lit: true, trail: p.trail)
    } else {
        c.rect(36, 37, 2, 5, C(0xB9BEC8)); c.rect(36, 39, 2, 1, C(0x2A2A2F))
    }
}

/// Stormtrooper E-11: black carbine with scope, cooling holes and a side magazine.
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

/// Boba Fett's EE-3 carbine: short dark rifle with brass fittings and a scope.
private func drawEE3(_ c: PixelCanvas, x: Int, y: Int) {
    c.pattern(x, y, [
        ".....SSSSL....",
        "......B..B....",
        "BKKKKKKKKKKKKK",
        "KKKKBBKKKKKK..",
        "...KK.........",
        "...KK.........",
    ], ["S": C(0x2C2C33), "L": C(0xFF6A3A), "K": C(0x2A2A2E), "B": C(0xB08D57)])
}

/// The B1's E-5 blaster: slim tan-brown rifle with a shoulder stock.
private func drawE5(_ c: PixelCanvas, x: Int, y: Int) {
    c.pattern(x, y, [
        "..BBBBBBBBBBB",
        "BBBBBBbBb....",
        "BB...BB......",
    ], ["B": C(0x5A4A32), "b": C(0x8A7652)])
}

private func drawJetpack(_ c: PixelCanvas, t: Double, burning: Bool) {
    let pack = C(0x7D8A6E), packShade = C(0x5E6A52)
    for x in [13, 38] {
        c.rect(x, 23, 5, 11, pack)
        c.rect(x + 4, 23, 1, 11, packShade)
        c.rect(x, 23, 4, 1, C(0x9AA88A))                            // lit along the top
        c.rect(x, 29, 4, 1, packShade); c.px(x + 1, 27, packShade)  // a seam and a rivet
        c.rect(x, 34, 5, 1, C(0x4A4A52))
    }
    c.rect(13, 21, 5, 2, C(0xC8402A))   // the missile
    c.rect(14, 20, 3, 1, C(0xC8402A))
    c.rect(14, 21, 2, 1, C(0xE86A4A))
    if burning {
        for x in [14, 39] {
            let len = 3 + Int(noise(Int(t * 30) + x) * 3)
            c.rect(x, 35, 3, len, C(0xFF9A2A))
            c.rect(x + 1, 35, 1, len + 1, C(0xFFE27A))
        }
    }
}

// MARK: - Darth Vader

/// Darth Vader. Signature: his gloved hand goes to the chest panel and works the switches.
private func drawVader(_ c: PixelCanvas, _ p: Pose) {
    drawCape(c, t: p.t, speed: p.capeSpeed, color: C(0x0E0E12), edge: C(0x2C2C36))
    drawLegs(c, Look(leg: C(0x2E2F36)), step: p.step)
    // Polished boots: black, a glint of light down the front of each.
    drawBoots(c, ink, step: p.step, rows: 3)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            c.px(lx, p.step >= 0 && i % 2 == p.step ? 40 : 41, C(0x5C6070))
        }
    }
    c.oy += p.breathe
    drawBody(c, Look())
    c.rect(15, 33, 1, 3, ink)
    c.rect(40, 33, 1, 3, ink)
    // The armoured shoulder bells and the collar's rim, dark grey with a highlight.
    c.rect(18, 32, 3, 1, C(0x2A2B31)); c.rect(35, 32, 3, 1, C(0x2A2B31))
    c.px(19, 32, C(0x5C6070)); c.px(36, 32, C(0x5C6070))
    c.pattern(15, 14, [
        ".........KKKKKKKK.........",
        ".......KKKKKKKKKKKK.......",
        "......KKKHHKKKKKKKKK......",
        ".....KKKHHKKKKKKKKKKK.....",
        ".....KKHHKKKKKKKKKKKK.....",
        "....KKKHKKKKKKKKKKKKKK....",
        "....KKKKKKKKKKKKKKKKKK....",
        "....KKKKKKKKKKKKKKKKKK....",
        "...KKKKKKKKKKKKKKKKKKKK...",
        "...KKKKKKKKKKKKKKKKKKKK...",
        "..KKKKKKKKKKKKKKKKKKKKKK..",
        "..KKKGGGGGGGGGGGGGGGGKKK..",
        ".KKKK................KKKK.",
        ".KKK..................KKK.",
        "KKKK..................KKKK",
        "KKK....................KKK",
        "KK......................KK",
        "K........................K",
    ], ["K": ink, "H": C(0x5C6070), "G": C(0x3A3D46)])
    c.pattern(25, 32, [".GGGG.", "GSGGSG", ".GSSG."], ["G": C(0x3A3D46), "S": C(0x9AA0AE)])
    if let s = p.signature, s > 0.12, s < 0.88 {
        // His gloved hand goes to the chest panel and works the switches; the lights flicker through.
        let lights = [C(0xE0303A), C(0x3BD15A), C(0x3A7BEA), C(0x2A2B31)]
        let k = Int(s * 20)
        c.pattern(31, 34, ["GGGGG", "G...G", "GGGGG"], ["G": C(0x3A3D46)])
        for i in 0..<3 { c.px(32 + i, 35, lights[(k + i * 3 + (k / 3)) % lights.count]) }
        c.rect(37, 33, 3, 3, C(0x0E0E12))                   // the arm swings in…
        c.rect(34, 33, 3, 2, ink)                            // …the glove on the panel's top edge
        c.rect(34, 33, 3, 1, C(0x5C6070))                    // knuckles catching the light
        c.px(34 + (k % 2), 34, C(0x5C6070))                  // a finger pressing, pressing
    } else {
        c.pattern(31, 34, ["GGGGG", "GRgBG", "GGGGG"],
                  ["G": C(0x3A3D46), "R": C(0xE0303A), "g": C(0x3BD15A), "B": C(0x3A7BEA)])
    }
    // The belt: the buckle plate, and the two control boxes either side of it with their little lights.
    c.rect(18, 37, 20, 1, C(0x2A2B31))
    c.rect(26, 37, 4, 1, C(0x9AA0AE)); c.px(26, 37, C(0xC8CCD6))
    c.rect(21, 36, 3, 2, C(0x9AA0AE)); c.px(22, 36, C(0xE0303A))
    c.rect(32, 36, 3, 2, C(0x9AA0AE)); c.px(33, 36, C(0x3A7BEA))
    drawRedSaber(c, p)
}

// MARK: - Kylo Ren

/// Kylo Ren: the unstable, cross-guarded blade. Signature: a tantrum, wild slashes at nothing.
private func drawKylo(_ c: PixelCanvas, _ p: Pose) {
    var melee = p.melee, trail = p.trail, breathe = p.breathe
    if let s = p.signature, s > 0.06, s < 0.94 {
        let t = p.t
        let slash = { (u: Double) -> Double in -150 + 200 * noise(Int(u * 7) + 11) }
        melee = slash(t); trail = saberTrail(t, pose: slash)
        c.ox += noise(Int(t * 14)) > 0.5 ? 1 : -1; c.oy += noise(Int(t * 7) + 5) > 0.7 ? -1 : 0
        breathe = 0
    }
    drawCape(c, t: p.t, speed: p.capeSpeed, color: C(0x0E0E12), edge: C(0x2C2C36))
    let black = C(0x1E1E24), silver = C(0xA9AEB8), quilt = C(0x2E2E36), fold = C(0x121216)
    drawLegs(c, Look(leg: black), step: p.step)
    drawBoots(c, ink, step: p.step, rows: 2)                        // black boots, a glint down the front
    drawBootShine(c, step: p.step, C(0x4A4C56))
    c.oy += breathe
    drawBody(c, Look(arm: black))
    c.rect(15, 35, 3, 1, ink); c.rect(38, 35, 3, 1, ink)            // the gloves
    // The hood over the helmet: a sheen down one side, the dome's silver trim catching the light.
    c.pattern(16, 15, [
        "......KKKKKKKKKKKK......",
        "....KKKhhhKKKKKKKKKK....",
        "...KKhhKKKKKKKKKKKKKK...",
        "..KKhKKKKKKKKKKKKKKKKK..",
        "..KKhKKKKKKKKKKKKKKKKK..",
        "..KKKKKKKKKKKKKKKKKKKK..",
        "..KKSlSSSSSSSSSSSSSSKK..",
        "..KhKKKKKKKSSKKKKKKKKK..",
        "..KhKKKKKKKSSKKKKKKKKK..",
        ".KKhKKKKKKKSSKKKKKKKKKK.",
        ".KKhKKKKKKKSSKKKKKKKKKK.",
        ".KKK.......SS.......KKK.",
        "KKKK................KKKK",
        "KKK..................KKK",
        "KK....................KK",
    ], ["K": C(0x16161B), "S": silver, "h": C(0x34343E), "l": C(0xDDE0E6)])
    c.rect(27, 27, 2, 4, silver)
    c.rect(21, 28, 4, 1, silver)
    c.rect(31, 28, 4, 1, silver)
    // The quilted tunic, its folds shaded, under a wide belt with its buckle.
    c.rect(18, 33, 20, 5, black)
    c.rect(25, 33, 6, 1, fold)                                      // the cowl's neck
    for x in [20, 23, 32, 35] { c.rect(x, 33, 1, 2, quilt) }
    c.rect(37, 33, 1, 5, fold); c.px(22, 37, fold); c.px(33, 37, fold)
    c.rect(18, 35, 20, 1, C(0x3A3A42))
    c.rect(27, 35, 2, 1, C(0x8A8F99)); c.px(27, 35, C(0xB8BCC6))
    if let a = melee {
        drawSaber(c, t: p.t, angle: a, core: C(0xFFD6D6), glow: C(0xFF2A1A), lit: true, trail: trail,
                  crossguard: true, unstable: true)
    } else {
        c.rect(36, 37, 2, 5, C(0x3A3A42)); c.rect(35, 38, 4, 1, C(0x3A3A42))
    }
}

// MARK: - Darth Maul

/// Darth Maul: red and black tattoos, horns, and the double-bladed saber.
private func drawMaul(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0x1A1A1F), robeHi = C(0x3A3A44), fold = C(0x0C0C10), sash = C(0x3A3A42)
    drawLegs(c, Look(leg: robe), step: p.step)
    drawBoots(c, ink, step: p.step, rows: 2)                        // black boots, a glint down the front
    drawBootShine(c, step: p.step, C(0x4A4C56))
    c.oy += p.breathe
    drawBody(c, Look(body: C(0xC0262D), shade: C(0x8E1A20), arm: robe, eye: C(0xF5D547)))
    c.rect(15, 35, 3, 1, ink); c.rect(38, 35, 3, 1, ink)            // the gloves
    let K: [Character: Px] = ["K": C(0x111114)]
    c.pattern(18, 26, ["KK...K..KKKK..K...KK", "K....KK..KK..KK....K"], K)
    c.pattern(18, 32, ["..KK....KKKK....KK..", "...KKK..KKKK..KKK..."], K)
    c.px(21, 29, C(0x111114)); c.px(34, 29, C(0x111114))
    // The horns, shaded at the root.
    c.pattern(18, 23, ["..h..h...hh...h..h..", "..H..H...HH...H..H..", "..d..d..d..d..d..d.."],
              ["H": C(0xF0E6CC), "h": C(0xFFF8E6), "d": C(0xC8BC9E)])
    // The black tunic: the neck of its wrap with lit edges, folds shaded, a sash tied at the side with a clasp.
    c.rect(18, 34, 20, 4, robe)
    c.rect(25, 34, 6, 1, fold); c.px(24, 34, robeHi); c.px(31, 34, robeHi)
    c.rect(37, 34, 1, 4, fold); c.px(22, 36, fold); c.px(33, 37, fold); c.px(28, 37, fold)
    c.rect(18, 35, 20, 1, sash)
    c.rect(20, 35, 2, 1, C(0x52525C)); c.px(21, 36, sash)          // the sash's knot and its end
    c.rect(27, 35, 2, 1, C(0x8A8F99)); c.px(27, 35, C(0xB8BCC6))
    if let a = p.melee {
        drawSaber(c, t: p.t, angle: a + 180, core: C(0xFFE3E3), glow: C(0xFF1E2D), lit: true, length: 15)
        drawSaber(c, t: p.t, angle: a, core: C(0xFFE3E3), glow: C(0xFF1E2D), lit: true, trail: p.trail, length: 15)
    } else {
        c.rect(36, 34, 2, 8, C(0x2A2A2F)); c.rect(36, 37, 2, 2, C(0xB9BEC8))
    }
}

// MARK: - Boba Fett

/// Boba Fett: jetpack (firing as he shoots), the T visor and the EE-3. Signature: the rangefinder swings down and
/// blinks red.
private func drawBoba(_ c: PixelCanvas, _ p: Pose) {
    drawJetpack(c, t: p.t, burning: p.fire.map { frac($0.t / blasterPeriod) > 0.7 } ?? false)
    let armor = C(0x6B7A5E), armorShade = C(0x4E5A44), armorHi = C(0x8E9E7C), brass = C(0xB08D57)
    drawLegs(c, Look(leg: C(0x6E6A5A)), step: p.step)
    if !seatedPose {                                                // green knee plates, lit on top
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let y = p.step >= 0 && i % 2 == p.step ? 38 : 39
            c.rect(lx, y, 2, 2, armor); c.px(lx, y, armorHi)
        }
    }
    drawBoots(c, C(0x3E362A), step: p.step, rows: 2)                // worn brown boots
    drawBootShine(c, step: p.step, C(0x6E6250))
    c.oy += p.breathe
    drawBody(c, Look(body: armor, shade: armorShade, arm: C(0x9A8F72), eye: nil))
    c.rect(15, 35, 3, 1, C(0x5A4632))                               // the glove
    c.pattern(16, 17, [
        "......GGGGGGGGGGGG......",
        "....GGGGGGGGGGGGGGGG....",
        "...GGGGGRRGGGGGGGGGGG...",
        "..GGGGGGRRGGGGGGGGGGGG..",
        "..GGGGGGGGGGGGGGGGGGGG..",
        "..GGGGGGGGGGGGGGGGGGGG..",
        "..GGGGGGGGGGGGGGGGGGGG..",
        ".GGGGGGGGGGGGGGGGGGGGGG.",
        ".GGGGGGGGGGGGGGGGGGGGGG.",
    ], ["G": armor, "R": C(0xA8442E)])
    // The helmet: the light along its dome, the far side in shadow, a scrape and a dent from old fights.
    c.rect(22, 18, 4, 1, armorHi); c.rect(20, 19, 2, 1, armorHi); c.px(19, 20, armorHi)
    c.rect(36, 20, 1, 4, armorShade); c.rect(37, 24, 1, 2, armorShade)
    c.rect(31, 21, 2, 1, C(0x434E3A)); c.px(33, 22, C(0x434E3A)); c.px(21, 33, C(0x434E3A))
    c.rect(20, 28, 16, 2, ink)       // T visor
    c.rect(27, 30, 2, 5, ink)
    // Rangefinder antenna, up beside the helmet. Signature: it swings down in front of the visor and blinks red.
    let swing = p.signature.map { habitArc($0, hold: 0.5) } ?? 0
    let a = (-90 + 207 * swing) * .pi / 180, len = 8 + 3 * swing   // lowered, it ends over the visor's eye slot
    for k in 0..<Int(len) {
        c.px(38 + Int((cos(a) * Double(k)).rounded()), 18 + Int((sin(a) * Double(k)).rounded()), C(0x9AA0AE))
    }
    c.rect(37, 17, 2, 2, C(0x9AA0AE))
    if swing > 0.95, let s = p.signature {
        let end = (x: 38 + Int((cos(a) * (len - 1)).rounded()), y: 18 + Int((sin(a) * (len - 1)).rounded()))
        c.rect(end.x - 1, end.y, 2, 2, C(0x5A5E68))         // the scope
        if Int(s * 14) % 2 == 0 { c.px(end.x - 1, end.y, C(0xFF3A2A)) }
    }
    // The helmet's rim, the chest plates under it lit along their top edges with a seam between.
    c.rect(18, 35, 20, 1, armorShade)
    c.rect(19, 36, 7, 1, armorHi); c.rect(30, 36, 7, 1, armorHi); c.rect(27, 36, 2, 1, armorShade)
    // The gun belt: pouches with brass catches, the buckle.
    c.rect(18, 37, 20, 1, C(0x6B4A2B))
    c.rect(20, 37, 3, 1, C(0x4E3420)); c.rect(32, 37, 3, 1, C(0x4E3420))
    c.px(21, 37, brass); c.px(33, 37, brass)
    c.rect(27, 37, 2, 1, brass); c.px(27, 37, C(0xE0C080))
    c.oy += gunY(p)
    drawEE3(c, x: 38, y: 30)
}

// MARK: - Stormtrooper

/// A Stormtrooper. Signature: he bumps his head (on a door that isn't there): a jolt back, stars round the helmet,
/// a rub.
private func drawTrooper(_ c: PixelCanvas, _ p: Pose) {
    let armor = C(0xF2F3F5), edge = C(0x8C93A0)
    let bump = p.signature
    if let s = bump, s > 0.1, s < 0.2 { c.ox -= 1 }
    // Faint outline so the white armour still reads on a white window.
    c.rect(18, 36, 2, 1, edge)
    drawLegs(c, Look(leg: C(0xC3C9D2)), step: p.step)
    for lx in [19, 23, 31, 35] { c.rect(lx, 39, 2, 1, edge) }
    c.oy += p.breathe
    c.rect(17, 25, 22, 14, edge)
    drawBody(c, Look(body: armor, shade: C(0xC9CED6), arm: armor, eye: nil))
    c.pattern(15, 16, [
        ".......oooooooooooo.......",
        ".....ooWWWWWWWWWWWWoo.....",
        "....oWWWWWWWWWWWWWWWWo....",
        "...oWWWWWWWWWWWWWWWWWWo...",
        "..oWWWWWWWWWWWWWWWWWWWWo..",
        "..oWWWWWWWWWWWWWWWWWWWWo..",
        "..oWWWWWWWWWWWWWWWWWWWWo..",
        "..oggggggggggggggggggggo..",
        ".oWWWWWWWWWWWWWWWWWWWWWWo.",
        ".oWWWWWWWWWWWWWWWWWWWWWWo.",
    ], ["W": armor, "g": C(0x9AA0AE), "o": edge])
    let plate = C(0xDDE1E7)
    // The helmet: a soft shadow under the dome's rim, the eye lenses with a glint, the cheek tubes, the frown.
    c.rect(17, 24, 22, 1, plate)
    c.rect(21, 28, 4, 3, ink)
    c.rect(31, 28, 4, 3, ink)
    c.px(22, 28, C(0x3A4250)); c.px(32, 28, C(0x3A4250))
    c.px(24, 31, C(0x9AA0AE)); c.px(31, 31, C(0x9AA0AE))       // the cheek tubes, down to the grille
    c.rect(25, 32, 6, 2, C(0x9AA0AE))
    c.px(26, 32, ink); c.px(28, 32, ink); c.px(30, 32, ink)
    // The chest plate's edges and the ab plates under it.
    c.rect(18, 34, 20, 1, plate); c.rect(22, 35, 1, 1, edge); c.rect(33, 35, 1, 1, edge)
    c.px(27, 35, edge); c.px(28, 35, edge)
    // The belt, black with its rows of white canisters, and the thermal detonator at the back.
    c.rect(18, 36, 20, 1, ink)
    c.rect(27, 36, 2, 1, armor)
    for x in [20, 22, 32, 34] { c.px(x, 36, plate) }
    c.rect(18, 37, 2, 1, C(0x5A606C))
    if let s = bump, s > 0.15, s < 0.92 {
        for i in 0..<3 {                                   // stars circling the helmet
            let a = s * 14 + Double(i) * 2.1
            let x = 28 + Int((cos(a) * 9).rounded()), y = 13 + Int((sin(a) * 2).rounded())
            let col = (i == 1 ? C(0xFFF2A0) : C(0xFFD25A)).alpha(s > 0.8 ? (0.92 - s) / 0.12 : 1)
            c.px(x, y, col); c.px(x - 1, y, col.alpha(0.5)); c.px(x + 1, y, col.alpha(0.5))
            c.px(x, y - 1, col.alpha(0.5)); c.px(x, y + 1, col.alpha(0.5))
        }
        if s > 0.3 {                                       // a hand up to rub the side of the helmet
            let rub = Int(s * 16) % 2
            c.rect(38, 24 + rub, 3, 10 - rub, edge)        // the forearm bent up from the elbow
            c.rect(39, 25 + rub, 1, 8 - rub, armor)
        }
    }
    c.oy += gunY(p)
    drawE11(c, x: 37, y: 30)
}

// MARK: - The Emperor

/// The Emperor: hooded robe, no legs showing, lightning from his raised hand.
private func drawEmperor(_ c: PixelCanvas, _ p: Pose) {
    drawCape(c, t: p.t, speed: p.capeSpeed * 0.6, color: C(0x111116), edge: C(0x2A2A33), extra: 1.5)
    let robe = C(0x1A1A20), robeEdge = C(0x2E2E38), robeDeep = C(0x0C0C10), skinShade = C(0xA86A50)
    // The robe, to the floor: folds catching the light down its length, a shadow either side of each of the four
    // legs as the cloth falls over them, and a frayed hem.
    for y in 36...43 {
        let k = (y - 36) / 2
        c.rect(17 - k, y, 22 + k * 2, 1, robe)
        c.px(17 - k, y, robeEdge); c.px(38 + k, y, robeEdge)
    }
    for x in [21, 25, 30, 34] { c.rect(x, 38, 1, 5, robeEdge) }
    for x in [18, 22, 33, 37] { c.rect(x, 40, 1, 3, robeDeep) }
    c.rect(16, 43, 24, 1, robeDeep)
    for x in [19, 24, 28, 32, 36] { c.px(x, 43, robeEdge) }
    c.oy += p.breathe
    var look = Look(body: C(0xD08A6C), shade: skinShade, arm: robe, eye: C(0xF5D547))
    look.legs = false
    // Waiting for you, the lightning crackles in his hand without his raising it.
    let raise = p.mode == .waiting && !p.walking ? 0 : p.armRaise
    drawBody(c, look, armRight: raise)
    c.rect(15, 35, 3, 1, robeEdge); c.rect(38, 35 - raise, 3, 1, robeEdge)   // the wide sleeves' turned cuffs
    drawHood(c, robe, robeEdge)
    // The hood's deep shadow round his face, a fold down its crown.
    c.rect(18, 26, 1, 7, robeDeep); c.rect(37, 26, 1, 7, robeDeep)
    c.rect(27, 20, 2, 1, robeEdge); c.px(28, 21, robeEdge)
    // His face: the bags under the yellow eyes.
    c.rect(22, 32, 2, 1, skinShade); c.rect(32, 32, 2, 1, skinShade)
    // The robe over his chest: its overlapping front edge and a cord belt.
    c.rect(18, 33, 20, 5, robe)
    c.rect(26, 33, 4, 1, skinShade)
    c.rect(29, 34, 1, 4, robeEdge); c.rect(30, 34, 1, 4, robeDeep)
    c.rect(18, 36, 20, 1, C(0x26262E)); c.rect(23, 37, 1, 1, C(0x26262E))
}

// MARK: - R0-GR

/// R0-GR, a B1 battle droid: tan, skinny-limbed, with the long forward-pointing snout head.
private func drawRogr(_ c: PixelCanvas, _ p: Pose) {
    let tan = C(0xD4C08F), tanShade = C(0xA8946A), dark = C(0x6E5E3E)
    let look = Look(body: tan, shade: tanShade, leg: C(0xC2AE7E), arm: tan, eye: nil)
    // Thin droid legs: draw them, then carve them narrower.
    drawLegs(c, look, step: p.step)
    for lx in [19, 23, 31, 35] { c.rect(lx, 38, 1, 4, dark) }
    let tanLight = C(0xE8D8AC), rivet = C(0x8A7A56)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.px(lx + 1, 39, tanShade) } }   // knee joints
    c.oy += p.breathe
    drawBody(c, look)
    c.rect(18, 26, 19, 1, tanLight)          // the shell lit along its top
    c.rect(20, 28, 16, 1, tanShade)          // chest plates
    c.rect(20, 31, 16, 1, tanShade)
    c.rect(26, 27, 4, 8, C(0xC7B282))
    for (x, y) in [(19, 27), (35, 27), (19, 30), (35, 30), (19, 33), (35, 33)] { c.px(x, y, rivet) }   // rivets
    c.px(32, 32, tanShade); c.px(33, 33, tanShade); c.px(21, 35, tanShade)   // scuffs from the battlefield
    c.px(15, 33, tanLight); c.px(38, 33, tanLight)                          // lit shoulders of the arms
    c.rect(24, 34, 8, 2, dark)               // backpack strap / power unit
    c.rect(24, 34, 8, 1, rivet); c.px(26, 35, C(0x4A3E28)); c.px(29, 35, C(0x4A3E28))   // its lit lip and vents
    c.rect(27, 22, 2, 4, dark)               // neck
    c.px(27, 23, tanShade); c.px(27, 25, tanShade)                          // its joints
    c.pattern(21, 15, [
        "....HHHHHH......",
        "..HHHHHHHHHHH...",
        ".HHEEHHHHHHHHHHH",
        ".HHEEHHHHHHHHHHs",
        "..HHHHHHHHHHHss.",
        "....hhhhhhhh....",
        ".....hhhhh......",
    ], ["H": tan, "h": tanShade, "s": tanShade, "E": C(0x2A2418)])
    // The head lit along its crown, a seam where the snout joins, a glint in the photoreceptor.
    c.rect(25, 15, 6, 1, tanLight); c.rect(23, 16, 4, 1, tanLight)
    c.rect(31, 16, 1, 3, tanShade)
    c.px(25, 17, C(0x6A5A3A))
    c.oy += gunY(p)
    drawE5(c, x: 39, y: 31)
}

// MARK: - Count Dooku

/// Count Dooku: brown cape, white hair and pointed beard, a red saber.
private func drawDooku(_ c: PixelCanvas, _ p: Pose) {
    drawCape(c, t: p.t, speed: p.capeSpeed, color: C(0x2A1A14), edge: C(0x4A3024))
    let robe = C(0x2A1A14), robeHi = C(0x4A3024), robeDeep = C(0x180E0A)
    drawLegs(c, Look(leg: C(0x1E1410)), step: p.step)
    drawBoots(c, ink, step: p.step, rows: 3)                        // tall black riding boots, polished
    drawBootShine(c, step: p.step, C(0x5A5048))
    c.oy += p.breathe
    drawBody(c, Look(arm: robe))
    c.rect(15, 35, 3, 1, robeDeep); c.rect(38, 35, 3, 1, robeDeep)   // the sleeves' cuffs
    // Swept-back white hair, the light running along it and grey at the temples.
    let W = C(0xDCDCDC), w = C(0xB4B4B4), l = C(0xF6F6F6)
    c.pattern(18, 22, ["....WWWlllWWWWWW....", "..WWwWWWWWWlllWwWW..", ".Ww..............wW.", "Ww................wW"],
              ["W": W, "w": w, "l": l])
    let beard: [Character: Px] = ["W": W, "w": w, "l": l]
    c.pattern(24, 32, ["WW....WW", ".WlWWWw.", "..WlWw..", "...Ww..."], beard)   // pointed beard
    // The dark tunic: the high collar, a lit edge down the front and folds shaded.
    c.rect(18, 33, 20, 5, robe)
    c.rect(19, 33, 4, 1, robeHi); c.rect(33, 33, 4, 1, robeHi)
    c.rect(23, 34, 1, 4, robeHi); c.rect(37, 33, 1, 5, robeDeep)
    c.px(20, 35, robeDeep); c.px(34, 34, robeDeep); c.px(21, 37, robeDeep); c.px(33, 37, robeDeep)
    c.pattern(24, 32, ["WW....WW", ".WlWWWw.", "..WlWw..", "...Ww..."], beard)
    // The belt with its curved buckle, and the cape's clasp chain, its ends catching the light.
    c.rect(18, 36, 20, 1, C(0x8A6A3A))
    c.rect(27, 36, 3, 1, C(0xC9A44A)); c.px(28, 36, C(0x5A4220))
    c.rect(26, 35, 4, 1, C(0xC9A44A))   // cape clasp chain
    c.px(25, 35, C(0xF0D47A)); c.px(30, 35, C(0xF0D47A))
    drawRedSaber(c, p)
}

// MARK: - Gamorrean Guard

/// A Gamorrean guard: green, horned leather cap, snout and tusks, and a vibro-axe shouldered at rest.
private func drawGamorrean(_ c: PixelCanvas, _ p: Pose) {
    let green = C(0x6E8B3D), greenDark = C(0x55702C), leather = C(0x5A3A22), greenHi = C(0x88A452)
    let leatherDark = C(0x3E2814), fur = C(0x6A4A2A)
    drawLegs(c, Look(leg: greenDark), step: p.step)
    drawBoots(c, C(0x3A2A1C), step: p.step, rows: 2)                // crude hide boots, scuffed at the toe
    drawBootShine(c, step: p.step, C(0x6A5040))
    c.oy += p.breathe
    drawBody(c, Look(body: green, shade: greenDark, arm: green, eye: nil))
    c.rect(15, 35, 3, 1, leather); c.rect(38, 35, 3, 1, leather)    // leather bracers
    // The leather cap: its crown lit, the far side in shadow, studs round the band; the horns darker at the root.
    c.pattern(17, 18, ["H..................H", "HH..LLLlllLLLLLL..HH", ".hLLllLLLLLLLLLLLLh.", "..LLLLLLLLLLLLLLLd..",
                       ".LLLLLLLLLLLLLLLLLd.", "LLsLLLLsLLLLsLLLLsLd", "LL................Ld"],
              ["L": leather, "H": C(0xE8DCC0), "h": C(0xC8BC9E), "l": C(0x7A5434), "d": leatherDark, "s": C(0x9A9EA4)])
    // His hide: a heavy brow over the piggy eyes, warts and creases in short strokes.
    c.rect(22, 27, 3, 1, greenDark); c.rect(31, 27, 3, 1, greenDark)
    c.rect(23, 28, 2, 2, C(0x1A1A10)); c.rect(32, 28, 2, 2, C(0x1A1A10))   // small piggy eyes
    c.rect(20, 30, 1, 2, greenDark); c.px(20, 29, greenHi); c.rect(35, 31, 2, 1, greenDark); c.px(19, 26, greenHi)
    c.pattern(25, 30, [".PlPPP.", "PPkPkPP", ".PPPPP."], ["P": C(0x9AB070), "k": C(0x2A2A18), "l": C(0xBCD094)])   // snout
    c.px(23, 34, C(0xF4EEDC)); c.px(33, 34, C(0xF4EEDC))      // tusks
    c.px(23, 33, greenDark); c.px(33, 33, greenDark)
    // The belt with its iron buckle, the fur loincloth under it in short strokes.
    c.rect(18, 35, 20, 3, fur)
    c.rect(18, 35, 20, 1, leatherDark)
    c.rect(27, 35, 2, 1, C(0x8A8F99)); c.px(27, 35, C(0xB8BCC6))
    for x in stride(from: 20, to: 37, by: 3) { c.px(x, 36, C(0x86603A)) }
    for x in stride(from: 19, to: 38, by: 3) { c.px(x, 37, C(0x4A3020)) }
    c.rect(37, 36, 1, 2, C(0x4A3020))
    drawAxe(c, angle: swungUp(p, from: -78) ?? -75)            // resting: axe shouldered, not through the floor
}

/// The Gamorrean guard's vibro-axe: a long haft with a heavy blade at the end.
private func drawAxe(_ c: PixelCanvas, angle: Double) {
    let hx = Sprite.hand.x, hy = Sprite.hand.y
    let r = angle * .pi / 180, ux = cos(r), uy = sin(r)
    c.glowLine(hx - ux * 3, hy - uy * 3, hx + ux * 17, hy + uy * 17, core: C(0x5A3A22), glow: clear, coreR: 0.8, glowR: 0.9)
    // Blade: a wedge on one side of the haft near the end
    let px = -uy, py = ux
    for i in 0..<6 {
        let along = 12.0 + Double(i)
        let width = 4.5 - abs(Double(i) - 2.5) * 0.6
        c.glowLine(hx + ux * along, hy + uy * along, hx + ux * along + px * width, hy + uy * along + py * width,
                   core: C(0xA9AEB8), glow: clear, coreR: 0.7, glowR: 0.8)
    }
    c.glowLine(hx + ux * 12 + px * 4.5, hy + uy * 12 + py * 4.5, hx + ux * 17 + px * 4.5, hy + uy * 17 + py * 4.5,
               core: C(0xE4E8EE), glow: clear, coreR: 0.6, glowR: 0.7)
}

// MARK: - Jabba the Hutt

/// Jabba: the big slug, laughing. Signature: his eyes narrow and the fat tongue slides out and licks his lips.
private func drawJabba(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x8E8B4E), dark = C(0x6E6B38), belly = C(0xB0A86A)
    let laugh = sin(p.t * 9) > 0 ? -1 : 0
    // Tail curling off behind, then the big slug body (no legs).
    c.pattern(4, 36, ["......SSSS", "...SSSSSSS", ".SSSSSSSSS", "SSSSSSSSSS", "SS........"], ["S": dark])
    c.rect(10, 36, 4, 1, skin); c.rect(7, 37, 3, 1, skin); c.px(5, 38, skin)   // the tail lit along its top
    // the belly stays planted on the floor; only the upper body bobs as he laughs
    for y in 40...43 {
        let hw = 10 + Double(y - 22) / 21 * 7
        let l = Int((Sprite.bodyCenterX - hw).rounded()), r = Int((Sprite.bodyCenterX + hw).rounded())
        c.rect(l, y, r - l, 1, skin)
    }
    c.oy += p.breathe + laugh
    for y in 22...43 {
        let k = Double(y - 22) / 21
        let hw = 10 + k * 7
        let l = Int((Sprite.bodyCenterX - hw).rounded()), r = Int((Sprite.bodyCenterX + hw).rounded())
        c.rect(l, y, r - l, 1, skin)
        c.px(l, y, dark); c.px(r - 1, y, dark)
    }
    // His hide: lit along the crown, the far side in shadow, warts and wrinkles in short strokes.
    let light = C(0xA8A464), deep = C(0x5C5A2E)
    c.rect(21, 22, 15, 1, light); c.rect(19, 23, 3, 1, light)
    for y in 24...43 {
        let r = Int((Sprite.bodyCenterX + 10 + Double(y - 22) / 21 * 7).rounded())
        c.px(r - 2, y, dark)
    }
    for (x, y) in [(25, 24), (32, 23), (19, 27), (35, 28), (17, 33), (39, 37), (18, 39)] { c.rect(x, y, 2, 1, light) }
    for (x, y) in [(27, 23), (34, 25), (20, 30), (37, 30), (17, 36), (39, 40)] { c.rect(x, y, 2, 1, dark) }
    c.rect(20, 34, 18, 9, belly)
    for y in stride(from: 35, to: 43, by: 2) { c.rect(21, y, 16, 1, C(0x9A925A)) }
    for (i, y) in stride(from: 34, to: 43, by: 2).enumerated() { c.rect(22 + i % 2 * 2, y, 4, 1, C(0xC4BC80)) }   // light on each roll
    c.rect(36, 34, 1, 9, C(0x9A925A))
    c.rect(21, 25, 3, 1, dark); c.rect(29, 25, 3, 1, dark)      // heavy brows
    c.pattern(21, 26, ["OOO.....OOO", "OKO.....OKO"], ["O": C(0xE08A2A), "K": C(0x2A1A0A)])   // slit eyes
    c.px(23, 26, C(0xFFC47A)); c.px(31, 26, C(0xFFC47A))      // a wet glint in each
    c.rect(21, 28, 3, 1, deep); c.rect(29, 28, 3, 1, deep)      // the bags under them
    c.px(25, 29, deep); c.px(27, 29, deep)                      // nostril slits
    c.rect(19, 31, 20, 1, C(0x4A4626))                          // the enormous mouth
    c.rect(20, 32, 18, 1, laugh < 0 ? C(0x7A3A3A) : dark)
    c.rect(21, 33, 16, 1, light)                                // the lower lip catching the light
    c.rect(38, 33, 4, 2, skin)                                  // tiny arm
    c.px(41, 34, deep); c.rect(38, 33, 2, 1, light)
    if let s = p.signature, s > 0.1, s < 0.9 {
        let k = (s - 0.1) / 0.8
        c.rect(21, 26, 3, 1, skin); c.rect(29, 26, 3, 1, skin)  // heavy lids
        c.rect(20, 31, 18, 2, C(0x4A2A26))                      // mouth open
        let tx = 21 + Int((0.5 - 0.5 * cos(k * 2 * .pi)) * 12)
        c.rect(tx, 32, 5, 2, C(0xC86A72)); c.rect(tx + 1, 34, 3, 1, C(0xC86A72))
        c.px(tx + 2, 32, C(0xA84A54))
        if frac(k * 3) < 0.5 { c.px(tx + 4, 35, C(0xD8E8F0).alpha(0.8)) }   // a drip
    }
}

// MARK: - IG-88

/// IG-88: the tall cylindrical sensor head. Signature: the sensor bands light up and spin round it, scanning.
private func drawIg88(_ c: PixelCanvas, _ p: Pose) {
    let metal = C(0x6F747C), metalDark = C(0x4C5058), metalLight = C(0x9AA0A8)
    drawLegs(c, Look(leg: metalDark), step: p.step)
    for lx in [19, 23, 31, 35] { c.rect(lx, 39, 2, 1, metalLight) }
    drawBoots(c, C(0x3A3D44), step: p.step, rows: 1)                       // flat metal feet
    if !seatedPose { for lx in [19, 23, 31, 35] { c.px(lx + 1, 37, metalLight) } }   // a lit edge on each strut
    c.oy += p.breathe
    drawBody(c, Look(body: metal, shade: metalDark, arm: metalDark, eye: nil))
    c.rect(18, 26, 19, 1, metalLight)                                      // the casing lit along its top
    c.rect(20, 28, 16, 2, metalDark); c.rect(22, 31, 12, 4, metalDark)    // chest plating
    c.rect(20, 28, 16, 1, C(0x5E636B)); c.rect(22, 31, 12, 1, C(0x5E636B))   // the plates' lit rims
    c.rect(24, 32, 2, 2, C(0xE0303A)); c.rect(30, 32, 2, 2, C(0xE0303A))
    c.px(24, 32, C(0xFF8A80)); c.px(30, 32, C(0xFF8A80))                  // the lights' hot centres
    c.rect(27, 33, 2, 1, C(0x3A3D44))                                     // a vent slot between them
    for (x, y) in [(19, 27), (36, 27), (19, 31), (19, 35), (35, 35)] { c.px(x, y, metalDark) }   // rivets
    c.px(20, 33, metalLight); c.px(21, 34, metalLight); c.px(34, 30, metalLight)   // scratches through the paint
    c.px(15, 33, metal); c.px(38, 33, metal)                              // the arms' lit joints
    c.rect(27, 22, 2, 4, metalDark)                                       // neck
    c.px(27, 23, metalLight); c.px(28, 25, metalLight)                    // its ribbed joints
    // Tall cylindrical sensor head
    c.pattern(23, 9, ["..MMMMMM..", ".MMLMMMMM.", "MMLMMMMMMM", "MMLMMMMMMM", "RRRRRRRRRR", "MMLMMMMMMM",
                      "MMLMMMMMMM", "MMLMMMMMMM", "RRRRRRRRRR", "MMLMMMMMMM", "MMMMMMMMMM", ".MMMMMMMM.", "..MMMMMM.."],
              ["M": metal, "L": metalLight, "R": C(0xC0392B)])
    // The head's far side in shadow, a seam round its middle and a glint on the crown.
    c.rect(32, 11, 1, 2, metalDark); c.rect(32, 14, 1, 3, metalDark); c.rect(32, 18, 1, 2, metalDark)
    c.px(31, 20, metalDark)
    c.rect(24, 15, 8, 1, C(0x5E636B))
    c.px(26, 9, metalLight); c.px(26, 10, C(0xC4C8D0))
    if let s = p.signature, s > 0.08, s < 0.92 {
        for (row, phase) in [(13, 0), (17, 5)] {
            c.rect(23, row, 10, 1, C(0x5A1A14))                      // the band dims…
            let k = Int(s * 46) + phase
            for j in 0..<4 {                                         // …and a bright segment runs round it
                let x = 23 + (k + j) % 10
                c.px(x, row, j == 1 || j == 2 ? C(0xFFF0E8) : C(0xFF4A30))
                c.px(x, row - 1, C(0xFF6A50).alpha(0.5)); c.px(x, row + 1, C(0xFF6A50).alpha(0.5))   // glow
            }
        }
    }
    c.oy += gunY(p)
    drawE11(c, x: 37, y: 30)
}

// MARK: - AT-ST

/// AT-ST: a grey cockpit Clawd on two long jointed legs, chin guns forward.
private func drawAtst(_ c: PixelCanvas, _ p: Pose) {
    let metal = C(0x8A8F9C), dark = C(0x5C616C), light = C(0xB4BAC6)
    // Legs: hip, backward knee, ankle, wide foot. The lifted leg steps up a pixel.
    for (i, hx) in [22, 32].enumerated() {
        let up = p.step >= 0 && i == p.step ? 1 : 0
        c.rect(hx, 24, 3, 8 - up, dark)                    // thigh
        c.rect(hx - 3, 31 - up, 4, 2, metal)               // knee joint (bends back)
        c.rect(hx - 2, 32 - up, 3, 10, metal)              // shin
        c.rect(hx - 5, 42 - up, 10, 2, dark)               // foot
        c.rect(hx - 5, 42 - up, 2, 1, light)
        c.rect(hx - 2, 33 - up, 1, 8, light)               // the shin lit down its front edge
        c.px(hx, 35 - up, dark); c.px(hx, 39 - up, dark)   // the shin's rivets
        c.px(hx - 2, 31 - up, light)                       // the knee joint's lit rim
        c.px(hx + 1, 26, metal)                            // a piston line down the thigh
        c.px(hx + 1, 42 - up, C(0x3A3D46)); c.px(hx + 4, 42 - up, light)   // the foot's plate seam and toe
    }
    c.oy += p.breathe
    // The cockpit: Clawd-shaped head with a viewport slit, side guns and chin cannons.
    c.rect(18, 12, 20, 12, metal)
    c.rect(18, 12, 20, 2, light)
    c.rect(37, 12, 1, 12, dark)
    // The hatch on top, a panel seam with rivets, the lower hull in shadow, a little wear.
    c.rect(24, 12, 7, 1, C(0xD4D9E2)); c.px(23, 12, dark); c.px(31, 12, dark)
    c.rect(18, 21, 19, 1, dark); c.rect(18, 22, 19, 2, C(0x787D8A))
    for x in [20, 26, 32] { c.px(x, 22, light) }
    c.rect(28, 18, 1, 3, dark)
    c.px(33, 19, C(0x787D8A)); c.px(34, 20, C(0x787D8A))   // a scrape
    c.rect(22, 15, 13, 1, C(0xC8CED8))                     // the viewport's lit brow
    c.rect(22, 16, 13, 2, C(0x1A1C21))                     // viewport
    c.px(24, 16, C(0xE0303A))
    c.px(30, 16, C(0x3A4A5A)); c.px(34, 17, C(0x2A3440))   // glare on the glass
    for y in stride(from: 19, to: 21, by: 1) { c.px(23, y, C(0x5C616C)); c.px(25, y, C(0x5C616C)) }   // a vent grille
    c.rect(16, 15, 2, 6, dark); c.rect(38, 17, 3, 3, dark) // side pods
    c.px(16, 15, metal); c.px(16, 18, C(0x3A3D46)); c.px(38, 17, metal)
    c.rect(38, 21, 9, 1, C(0x3A3D46)); c.rect(38, 23, 7, 1, C(0x3A3D46))   // chin guns
    c.px(46, 21, C(0x6A6F7A)); c.px(44, 23, C(0x6A6F7A))   // the muzzles' rims
    c.rect(24, 24, 8, 2, dark)                             // hip block
    c.rect(24, 24, 8, 1, metal); c.px(27, 25, C(0x3A3D46)) // its lit top and pivot
}

// MARK: - AT-AT

/// AT-AT: Clawd as the walker's body (it already has four legs), with the neck, the head and chin cannons.
private func drawAtat(_ c: PixelCanvas, _ p: Pose) {
    let metal = C(0x9A9EA8), dark = C(0x6A6F7A), light = C(0xC4C8D0)
    for (i, lx) in [16, 22, 34, 40].enumerated() {
        let up = p.step >= 0 && i % 2 == p.step ? 1 : 0
        c.rect(lx, 26, 3, 7 - up, metal)                   // upper leg
        c.rect(lx - 1, 32 - up, 5, 2, dark)                // knee
        c.rect(lx, 34 - up, 3, 8, metal)                   // lower leg
        c.rect(lx - 1, 42 - up, 5, 2, dark)                // round foot
        c.rect(lx, 34 - up, 1, 8, light)                   // the lower leg lit down one edge
        c.px(lx + 2, 27, dark); c.px(lx + 2, 30 - up, dark) // a seam down the upper leg
        c.px(lx, 32 - up, metal); c.px(lx + 2, 32 - up, metal)   // the knee's rivets
        c.rect(lx - 1, 42 - up, 5, 1, C(0x80858F))         // the foot's lit rim
    }
    c.oy += p.breathe
    // Body
    c.rect(13, 14, 32, 12, metal)
    c.rect(13, 14, 32, 2, light)
    c.rect(13, 24, 32, 2, dark)
    for x in stride(from: 17, to: 44, by: 6) {
        c.rect(x, 17, 1, 6, dark)                          // armour plates…
        c.rect(x + 1, 17, 1, 6, light)                     // …each lit along its edge, riveted at the foot
        c.px(x - 2, 22, C(0x80858F))
    }
    c.rect(13, 16, 32, 1, C(0x80858F))                     // the seam under the roof plates
    c.rect(44, 14, 1, 10, dark)                            // the far end in shadow
    c.px(20, 20, light); c.px(21, 21, light); c.px(38, 19, C(0x80858F))   // a scrape and a scorch mark
    // Neck and head
    c.rect(45, 17, 4, 4, dark)
    c.px(46, 17, metal); c.px(46, 19, metal); c.px(48, 18, metal)   // the neck's ribbed joints
    c.rect(49, 13, 13, 9, metal)
    c.rect(49, 13, 13, 2, light)
    c.rect(61, 15, 1, 7, dark)                             // the head's far side in shadow
    c.rect(49, 20, 12, 1, C(0x80858F))                     // its lower plate's seam
    c.rect(52, 15, 6, 1, light)                            // the viewport's lit brow
    c.rect(52, 16, 6, 2, C(0x1A1C21))                      // viewport
    c.px(56, 16, C(0x3A4A5A))                              // glare on the glass
    c.px(50, 16, dark); c.px(50, 19, dark); c.px(59, 19, dark)   // rivets
    c.rect(62, 15, 2, 5, dark)                             // snout
    c.px(62, 15, metal); c.px(63, 17, C(0x3A3D46))
    c.rect(56, 21, 8, 1, C(0x3A3D46)); c.rect(58, 22, 4, 1, C(0x3A3D46))  // chin cannons
    c.px(63, 21, C(0x6A6F7A))
}

// MARK: - Rancor

/// The Rancor's shoulder, below the jaw: its claw arm pivots here (the fight effects need it too).
private let rancorShoulder = (x: 35.0, y: 25.0)

/// The rancor: a towering, hunched reptile that stands upright on two short, stubby legs, with a flat face
/// that's mostly fanged mouth, tiny eyes, spines over its back and shoulders, and very long arms.
/// Signature: it throws its head up and roars, jaws gaping, the air shaking in front of it.
private func drawRancor(_ c: PixelCanvas, _ p: Pose) {
    let hide = C(0x8A7A62), shade = C(0x6A5C48), light = C(0xA89878), spine = C(0x4A3E30), claw = C(0xE8DCC0)
    for (i, lx) in [21, 31].enumerated() {                          // two short, stubby legs
        let up = p.step >= 0 && i == p.step ? 1 : 0
        c.rect(lx, 35, 6, 8 - up, shade)
        c.rect(lx - 1, 42 - up, 8, 2, C(0x54483A))
        for k in 0..<3 { c.px(lx - 1 + k * 3, 43 - up, claw) }      // three toes
        c.px(lx - 1, 42 - up, C(0xFFF8EC))                           // a glint on the claw
        c.rect(lx + 1, 37, 2, 1, C(0x54483A)); c.rect(lx + 3, 40 - up, 2, 1, C(0x54483A))   // wrinkled hide
        c.rect(lx, 35, 2, 1, hide)
    }
    c.oy += p.signature == nil ? p.breathe : 0                      // it holds still to roar
    // tall torso, hunched forward (shoulders lean right)
    for y in 14...36 {
        let lean = (36 - y) / 4                                     // top leans toward the head
        c.rect(19 + lean, y, 18, 1, hide)
        c.px(19 + lean, y, shade)
    }
    c.rect(21, 33, 16, 3, shade)                                    // belly fold
    for (x, y) in [(24, 20), (29, 25), (23, 29), (32, 18), (27, 31), (33, 28)] { c.rect(x, y, 2, 1, light) }   // scales
    // the light along the hunched shoulders, scales in shadow between the lit ones, the far side shaded
    c.rect(25, 15, 9, 1, light); c.rect(23, 17, 3, 1, light)
    for (x, y) in [(27, 22), (32, 23), (22, 25), (30, 30), (25, 27), (35, 20)] { c.rect(x, y, 2, 1, shade) }
    for y in 23...32 { c.px(36 + (36 - y) / 4, y, shade) }
    c.rect(23, 34, 3, 1, C(0x54483A)); c.rect(30, 34, 3, 1, C(0x54483A))   // creases in the belly fold
    for k in 0..<5 { c.px(21 + k * 3 + (5 - k) / 2, 13 - k % 2, spine); c.px(21 + k * 3 + (5 - k) / 2, 14, spine) }  // back spines
    for k in [1, 3] { c.px(21 + k * 3 + (5 - k) / 2, 13 - k % 2, C(0x6E604E)) }   // tips catching the light
    // the near arm hangs almost to the ground: they're long
    c.rect(16, 19, 4, 20, shade)
    c.rect(16, 19, 1, 18, hide)                                     // lit down its front
    c.rect(15, 38, 6, 2, shade)
    for k in 0..<3 { c.px(15 + k * 2, 40, claw) }
    c.px(15, 40, C(0xFFF8EC))
    c.px(17, 22, spine); c.px(17, 26, spine)
    c.rect(18, 30, 2, 1, C(0x54483A)); c.rect(17, 34, 2, 1, C(0x54483A))   // wrinkles at the elbow and wrist
    // flat face dominated by the mouth, thrust forward on the hunch
    c.rect(34, 9, 13, 14, hide)
    c.rect(34, 9, 13, 2, light)
    c.rect(46, 11, 1, 4, shade)                                     // the face's far side
    c.px(37, 11, spine); c.px(41, 10, spine)                        // brow ridges
    c.rect(38, 11, 2, 1, shade); c.rect(43, 11, 2, 1, shade)        // heavy brows over the eyes
    c.rect(40, 13, 2, 1, shade); c.px(36, 13, shade); c.px(45, 14, shade)   // wrinkles round the snout
    c.px(38, 12, C(0xFFD23D)); c.px(43, 12, C(0xFFD23D))            // tiny eyes
    c.px(39, 12, C(0x2A1E14)); c.px(44, 12, C(0x2A1E14))
    let roar = p.signature.map { habitArc($0, hold: 0.55) } ?? 0
    let gape = Int((roar * 4).rounded())
    if gape > 0 { c.rect(34, 22, 13, gape, hide) }                  // the jaw drops
    c.rect(35, 15, 12, 7 + gape, C(0x3A1A12))                       // the mouth
    for k in 0..<6 { c.px(35 + k * 2, 15, claw); c.px(36 + k * 2, 21 + gape, claw) }   // fangs top and bottom
    c.px(37, 15, C(0xFFFFFF)); c.px(43, 15, C(0xFFFFFF))            // glints on two of them
    c.rect(36, 16, 10, 1, C(0x2A100A))                              // the gums' shadow under the top row
    c.rect(35, 22 + gape, 12, 1, shade)                             // jaw
    if roar > 0.9, let s = p.signature {
        for i in 0..<3 {                                             // the roar: arcs pushing out from the mouth
            let f = frac(s * 4 + Double(i) / 3), x = 49 + Int(f * 10), col = C(0xF4EEE0).alpha(0.8 * (1 - f))
            for dy in -2 - i...(2 + i) where abs(dy) > 0 || i == 0 { c.px(x + abs(dy) / 2, 18 + gape / 2 + dy, col) }
        }
        if frac(s * 14) < 0.5 { c.px(41, 12, C(0xFFF07A)) }         // a mad glint
    }
    drawClaw(c, angle: swungUp(p, from: 30) ?? 30)                  // resting: arm hangs forward, claws above the floor
}

/// The rancor's reaching arm: very long, thick, ending in three claws. Raised overhead it bends at the elbow, up to
/// 4 pixels shorter straight up, so the claws stay inside the frame.
private func drawClaw(_ c: PixelCanvas, angle: Double) {
    let (hx, hy) = rancorShoulder
    let r = angle * .pi / 180, ux = cos(r), uy = sin(r)
    let len = 20 - 4 * max(0, -uy)
    c.glowLine(hx, hy, hx + ux * len, hy + uy * len, core: C(0x7A6A54), glow: clear, coreR: 1.8, glowR: 1.9)
    let tx = hx + ux * len, ty = hy + uy * len

    for k in -1...1 {
        let a = r + Double(k) * 0.35
        c.glowLine(tx, ty, tx + cos(a) * 5, ty + sin(a) * 5, core: C(0xE8DCC0), glow: clear, coreR: 0.6, glowR: 0.7)
    }
}

// MARK: - Greedo

/// Greedo: a green Rodian Clawd: huge glossy black eyes, a tapir snout, spines on top, a vest and a pistol.
private func drawGreedo(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x5E9A4A), skinShade = C(0x467A36), skinLight = C(0x7AB860)
    let vest = C(0x3A3A2E), vestHi = C(0x56564A), tunic = C(0xC8BCA0), tunicShade = C(0xA89C80)
    drawLegs(c, Look(leg: C(0x4A4A52)), step: p.step)
    drawBoots(c, C(0x2A2A30), step: p.step, rows: 2)                // dark boots, a glint down the front
    drawBootShine(c, step: p.step, C(0x5A5E68))
    c.oy += p.breathe
    drawBody(c, Look(body: skin, shade: skinShade, arm: skin, eye: nil))
    // head spines, their tips lit, and the little ear fans with their ridges
    c.pattern(19, 21, ["...l..l..S...S..S...", "..SSS.SS.SS..SS.SSS.", ".SSSSSSSSSSSSSSSSSS."], ["S": skinShade, "l": skinLight])
    c.pattern(14, 27, ["EE", "EEe", "EE"], ["E": skinLight, "e": skinShade]); c.pattern(39, 27, [".EE", "eEE", ".EE"], ["E": skinLight, "e": skinShade])
    // his skin: short lit strokes, the far side shaded
    for (x, y) in [(19, 26), (34, 26), (25, 35)] { c.rect(x, y, 2, 1, skinLight) }
    c.px(31, 34, skinLight); c.rect(36, 27, 1, 6, skinShade)
    // the big multifaceted eyes
    for ex in [20, 31] {
        c.rect(ex, 27, 5, 5, C(0x0A0C10)); c.rect(ex + 1, 26, 3, 7, C(0x0A0C10))
        c.px(ex + 1, 28, C(0x6A8AB0)); c.px(ex + 2, 27, C(0xBFD8F0))
    }
    // tapir snout, lit along the top
    c.rect(26, 31, 4, 3, skinShade); c.rect(27, 34, 2, 2, skinShade); c.px(27, 35, C(0x2A3A20))
    c.rect(26, 31, 4, 1, skinLight)
    // The vest over a pale tunic: the tunic's neck and folds, the vest's lit edges and pockets, a belt and buckle.
    c.rect(18, 33, 20, 5, tunic)
    c.rect(25, 33, 6, 1, tunicShade); c.px(24, 35, tunicShade); c.px(30, 36, tunicShade)
    c.rect(18, 33, 5, 5, vest); c.rect(33, 33, 5, 5, vest)
    c.rect(22, 33, 1, 4, vestHi); c.rect(33, 33, 1, 4, vestHi); c.rect(18, 33, 4, 1, vestHi); c.rect(34, 33, 4, 1, vestHi)
    c.rect(19, 35, 2, 1, C(0x26261E)); c.rect(35, 35, 2, 1, C(0x26261E)); c.rect(37, 34, 1, 3, C(0x26261E))
    c.rect(18, 37, 20, 1, C(0x5A4A32))
    c.rect(27, 37, 2, 1, C(0xB08D57)); c.px(27, 37, C(0xE0C080))
    c.oy += gunY(p)
    c.pattern(40, 31, [".KKKKK", "KKKKSK", "KK....", "KK...."], ["K": C(0x2A2A30), "S": C(0x8A8F9C)])
}

// MARK: - Royal Guard

/// The Emperor's Royal Guard: crimson from head to foot, a floor-length robe over a smooth, tall helmet with a
/// black T-shaped visor slit, and a force pike held upright.
private func drawRoyalGuard(_ c: PixelCanvas, _ p: Pose) {
    drawCape(c, t: p.t, speed: p.capeSpeed * 0.5, color: C(0x6E0C10), edge: C(0x8E1418), extra: 0.5)
    let red = C(0xB3161B), dark = C(0x7E0E12), shine = C(0xE0484C), lit = C(0xC8262B), deep = C(0x5E0A0E)
    // The robe, to the floor: folds catching the light down its length, a shadow either side of each of the four
    // legs as the cloth falls over them, and a hem in shadow.
    for y in 36...43 {
        let k = (y - 36) / 2
        c.rect(17 - k, y, 22 + k * 2, 1, red)
        c.px(17 - k, y, dark); c.px(38 + k, y, dark)
    }
    for x in [21, 25, 30, 34] { c.rect(x, 38, 1, 5, lit) }
    for x in [18, 22, 33, 37] { c.rect(x, 40, 1, 3, dark) }
    c.rect(15, 43, 26, 1, deep)
    c.oy += p.breathe
    var look = Look(body: red, shade: dark, arm: red, eye: nil)
    look.legs = false
    drawBody(c, look)
    c.pattern(16, 13, [
        ".........RRRRRR.........",
        ".......RRRRRRRRRR.......",
        "......RRSSRRRRRRRR......",
        "......RSSRRRRRRRRRD.....",
        ".....RRSRRRRRRRRRRRD....",
        ".....RSSRRRRRRRRRRRD....",
        ".....RSRRRRRRRRRRRRD....",
        ".....RSRRRRRRRRRRRRD....",
        "....RRRRRRRRRRRRRRRRD...",
        "....RRRRRRRRRRRRRRRRD...",
        "...RRRRRRRRRRRRRRRRRRD..",
        "..RRRRRRRRRRRRRRRRRRRRD.",
        ".RRRRRRRRRRRRRRRRRRRRRRD",
        "DDDDDDDDDDDDDDDDDDDDDDDD",
    ], ["R": red, "S": shine, "D": dark])
    // The helmet's flare lit along its top, the faceplate lit down one side and shaded down the other.
    c.rect(18, 24, 6, 1, lit); c.rect(19, 27, 1, 7, lit); c.rect(36, 27, 1, 7, dark)
    c.rect(21, 29, 14, 1, ink)          // the visor: a narrow slit across…
    c.rect(27, 29, 2, 4, ink)           // …and down the middle
    c.rect(21, 30, 6, 1, dark); c.rect(29, 30, 6, 1, dark)          // the slit's lower lip in shadow
    // Where the robe falls from the shoulders: its front edges meet down the middle, the sleeves' cuffs.
    c.rect(18, 35, 20, 1, dark)
    c.rect(28, 36, 1, 7, dark); c.px(27, 36, lit)
    c.rect(15, 35, 3, 1, dark); c.rect(38, 35, 3, 1, dark)
    drawPike(c, angle: swungUp(p, from: -78) ?? -84)   // resting: held upright at its side, as they stand guard
}

/// The Royal Guard's force pike: a long dark staff with a silver head, the tip crackling when it's swung.
private func drawPike(_ c: PixelCanvas, angle: Double) {
    let hx = Sprite.hand.x, hy = Sprite.hand.y
    let r = angle * .pi / 180, ux = cos(r), uy = sin(r)
    c.glowLine(hx - ux * 7, hy - uy * 7, hx + ux * 17, hy + uy * 17, core: C(0x8A8E99), glow: clear, coreR: 0.7, glowR: 0.8)
    c.glowLine(hx + ux * 17, hy + uy * 17, hx + ux * 21, hy + uy * 21, core: C(0xC9CED8), glow: clear, coreR: 0.8, glowR: 0.9)
    c.glowLine(hx + ux * 21, hy + uy * 21, hx + ux * 22.5, hy + uy * 22.5, core: C(0xFFF2C0), glow: clear, coreR: 0.6, glowR: 0.7)
}
