import Foundation

// Villains: the orcs and the trolls. The three orcs are Clawd underneath, the blocky body in their own skin, each told
// apart from the others in the line by skin, headgear, build and weapon: Ug-lookup lean under a tall black helmet,
// Grish-NaN bald and hunched with long arms, Shagradle broad under a spiked iron one behind a big shield. Blog, son of
// Azog, is an orc too, but a head taller and broader (his legs, body and mace hand are drawn bigger). The trolls aren't
// Clawd at all: Olog-HA is a quarter again a Man's height, the Cave Troll-ing half again (like the Ballrog), the sizes
// drawn on the canvas, so their `headTop`, weapon hands and `bulk` say so.

let ringsVillains6: [LOTRVillain: Persona] = [
    .ugluk: Persona(name: "Ug-lookup", weapon: .saber, headTop: 13,
                    callout: "The prisoners are not for eating! They go in the hash map, for O(1) lookup.", draw: drawUgluk),
    .grishnakh: Persona(name: "Grish-NaN", weapon: .saber, pivot: grishnakhHand, headTop: 22,
                        callout: "Searched their pockets: NaN. Search them again, my precious little rats.",
                        draw: drawGrishnakh),
    .shagrat: Persona(name: "Shagradle", weapon: .saber, pivot: shagratHand, bulk: 2, headTop: 14,
                      callout: "Nobody leaves the Tower till the Gradle build goes green!", draw: drawShagrat),
    .ologHai: Persona(name: "Olog-HA", weapon: .saber, armoured: true, pivot: ologHand, bulk: 5, headTop: 13,
                      callout: "Olog-HA: highly available. Five nines of smash.", draw: drawOlogHai),
    .caveTroll: Persona(name: "The Cave Troll-ing", weapon: .saber, canSit: false, pivot: caveTrollHand, bulk: 8, headTop: 9,
                        callout: "Hrrr… u mad, Halfling?", draw: drawCaveTroll),
    .bolg: Persona(name: "Blog, son of Azog", weapon: .saber, pivot: bolgHand, bulk: 3, headTop: 18,
                   callout: "New on the Blog: thirteen Dwarves, ranked by taste.", draw: drawBolg),
]

// MARK: - Ug-lookup

/// Ug-lookup, an Uruk captain of Isengard: lean and upright, ruddy dark-brown skin, long black hair down his back from
/// under a tall, narrow black helmet rising to a spike, the White Hand painted tall on its front, cheek guards and a
/// nose bar. Angry brows, yellow-glinting eyes and a lean, mean grin, two fangs over the lip. Black scale armour, one
/// round pauldron on the sword shoulder, a belt and a skirt of black strips. A jagged falchion, saw-toothed along its
/// back, held forward on guard; a light smear behind a fast swing. No signature.
private func drawUgluk(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x6E4030), skinDark = C(0x522E22), hair = C(0x141216), hairSheen = C(0x34303A)
    let plate = C(0x1C1C20), plateMid = C(0x2C2C34), plateLight = C(0x484852), helm = C(0x232328), helmLight = C(0x4C4C56)
    let paint = C(0xF0EEE8), fang = C(0xE8E0C8)
    drawLegs(c, Look(leg: C(0x2A2420)), step: p.step)
    drawBoots(c, p.step, plate, rows: 3)
    c.oy += p.breathe
    // Long black hair down his back from under the helmet.
    c.pattern(15, 24, ["..HHH", ".HHsH", ".HHHH", "HHsHH", "HHHH.", "HHH..", "HsH..", "HH...", "H...."],
              ["H": hair, "s": hairSheen])
    // The lean body in his own skin, a black bracer on the off arm.
    c.rect(19, 26, 18, 12, skin)
    c.rect(36, 26, 1, 12, skinDark)
    c.rect(16, 33, 3, 3, skin); c.rect(16, 33, 3, 1, plate)
    // Angry brows, low at the nose; yellow-glinting eyes; the grin.
    c.rect(21, 26, 3, 1, skinDark); c.px(24, 27, skinDark)
    c.rect(32, 26, 3, 1, skinDark); c.px(31, 27, skinDark)
    c.rect(22, 27, 2, 2, ink); c.rect(32, 27, 2, 2, ink)
    c.px(22, 27, C(0xC89A3A)); c.px(33, 27, C(0xC89A3A))
    c.pattern(23, 30, ["K.........K", ".KWKWKWKWK.", "...W...W..."], ["K": ink, "W": fang])
    // The tall helmet, a light band round its brim, the cheek guards and the nose bar.
    c.pattern(18, 13, [
        ".........KK.........",
        ".........hK.........",
        "........KhKK........",
        "........hKKK........",
        ".......KhKKKK.......",
        ".......hKKKKK.......",
        "......KhKKKKKK......",
        ".....KhKKKKKKKK.....",
        "....KhKKKKKKKKKK....",
        "...KhKKKKKKKKKKKK...",
        "..KKKKKKKKKKKKKKKK..",
        "hhhhhhhhhhhhhhhhhhhh",
        "KKKKKKKKKKKKKKKKKKKK",
    ], ["K": helm, "h": helmLight])
    c.rect(19, 26, 2, 4, helm); c.rect(35, 26, 2, 4, helm); c.rect(27, 26, 2, 3, helm)
    // The White Hand, painted tall up the helmet's front.
    c.pattern(24, 17, [".W.W.W.", ".W.W.W.", ".W.W.W.", ".WWWWW.", "WWWWWW.", ".WWWW.."], ["W": paint])
    // Black scale armour, the belt and a skirt of strips.
    c.rect(19, 33, 18, 4, plate)
    c.rect(19, 33, 18, 1, plateMid)
    for y in [34, 35, 36] { for x in stride(from: 19 + y % 2, through: 35, by: 2) { c.px(x, y, plateMid) } }
    c.rect(19, 37, 18, 1, C(0x3A2A22)); c.rect(27, 37, 2, 1, plateLight)
    for x in stride(from: 19, through: 36, by: 2) where 38 + c.oy <= 43 {
        c.rect(x, 38, 1, 39 + c.oy <= 43 ? 2 : 1, plateMid)
    }
    c.pattern(34, 31, [".KKK.", "KHKKK", "KKKKK", ".K.K."], ["K": plate, "H": plateLight])
    // The falchion, and the fist over its grip.
    let held = swing(p, rest: 20, seated: 6, heavy: false)
    drawSmear(c, at: Sprite.hand, held.smear, from: 4, to: 19, heavy: false, core: C(0xC8CCD4), glow: C(0x7A7E86))
    drawFalchion(c, at: Sprite.hand, angle: held.angle)
    c.rect(38, 33, 2, 3, plate); c.rect(40, 33, 2, 3, skin); c.px(41, 35, skinDark)
}

/// Ug-lookup's falchion: a leather grip, a plain iron guard and a broad single-edged blade that widens toward its
/// clipped tip, the back saw-toothed, a bright edge along the bottom.
private func drawFalchion(_ c: PixelCanvas, at: (x: Double, y: Double), angle: Double) {
    prop(c, at: at, angle: angle) { s in
        let blade = C(0x6E727A), back = C(0x4A4E56), edge = C(0xC8CCD4), grip = C(0x3A2A1E), iron = C(0x2A2A30)
        s.px(-4, 0, iron)
        s.rect(-3, 0, 5, 1, grip)
        s.rect(2, -2, 1, 5, iron)
        for x in 3...17 {
            let top: Int = x < 7 ? 0 : x < 11 ? -1 : x < 15 ? -2 : -3
            s.rect(x, top, 1, 1 - top, blade)
            s.px(x, top, back)
            s.px(x, 1, edge)
            if x >= 6, x % 3 == 0 { s.px(x, top - 1, back) }                    // the saw teeth
        }
        s.rect(18, -2, 1, 3, blade); s.px(18, 1, edge)
        s.rect(19, -1, 1, 2, blade); s.px(19, 1, edge)
        s.px(20, 1, edge)
    }
}

// MARK: - Grish-NaN

/// Where Grish-NaN's knife hand is: out in front of him on his long arm.
private let grishnakhHand: (x: Double, y: Double) = (44.5, 35.5)

/// Grish-NaN, a Mordor orc: hunched and spindly, sickly pale grey-green skin with scabs, a bald domed head thrust
/// forward with a few lank black strands, big swept-back ears, bulging yellow eyes with pinprick pupils and a wide,
/// creepy grin full of small pointed teeth. Long thin grasping arms: the back one hangs to his knees, claws spread; the
/// front one reaches out with a wicked hooked knife, held up and forward, ready to stab. A filthy rag tunic tied with a
/// rope. No signature.
private func drawGrishnakh(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x9AA07A), skinDark = C(0x767C5C), skinLight = C(0xB4BA96), scab = C(0x7A4A36), hair = C(0x221E1C)
    let rag = C(0x4E4232), ragDark = C(0x362C20), rope = C(0x8A7A54), claw = C(0x2E2A22), eye = C(0xE0D060)
    drawLegs(c, Look(leg: skinDark), step: p.step)
    drawBoots(c, p.step, ragDark, rows: 2)
    c.oy += p.breathe
    // The long back arm, hanging to his knees, claws spread.
    let low = seatedPose ? 35 : 39
    line(c, 20, 31, 16, Double(low - 1), skinDark, 0.8)
    c.rect(15, low - 1, 3, 2, skinDark)
    c.px(14, low + 1, claw); c.px(16, low + 1, claw); c.px(18, low + 1, claw)
    // Big ears swept back, the hunched body with its hump, the bald head thrust forward.
    c.pattern(18, 25, ["SS....", ".SSSS.", "..SdS."], ["S": skin, "d": skinDark])
    c.rect(19, 30, 17, 8, skin)
    c.rect(21, 28, 6, 2, skin); c.rect(19, 29, 2, 1, skin)
    c.rect(27, 24, 9, 1, skin); c.rect(25, 25, 13, 1, skin); c.rect(24, 26, 15, 6, skin)
    c.rect(38, 26, 1, 6, skinDark); c.rect(35, 32, 1, 6, skinDark)
    c.px(29, 24, skinLight); c.rect(30, 25, 2, 1, skinLight)                     // the shine on his scalp
    for (x, y) in [(33, 24), (26, 26), (36, 25), (22, 31), (20, 29)] { c.px(x, y, scab) }
    // A few lank strands: one curling up off the crown, two hanging down the back of his head.
    c.px(31, 23, hair); c.px(32, 22, hair)
    for (x, y) in [(25, 26), (24, 27), (23, 28), (23, 29), (22, 30), (26, 27), (26, 28), (25, 29)] { c.px(x, y, hair) }
    // Bulging yellow eyes under a heavy brow, and the grin.
    c.rect(29, 26, 3, 1, skinDark); c.rect(34, 26, 3, 1, skinDark)
    c.rect(30, 27, 2, 2, eye); c.px(31, 28, ink)
    c.rect(35, 27, 2, 2, eye); c.px(36, 28, ink)
    c.pattern(28, 29, ["K.........K", "KWKWKWKWKWK", ".KWKWKWKWK."], ["K": ink, "W": C(0xE8E0B8)])
    // The rag tunic, a rope round the waist, its hem in tatters.
    c.rect(19, 33, 16, 5, rag)
    c.rect(19, 35, 16, 1, rope)
    c.px(23, 34, ragDark); c.px(30, 36, ragDark); c.px(26, 37, ragDark); c.px(33, 33, ragDark)
    for x in stride(from: 19, through: 34, by: 3) where 38 + c.oy <= 43 { c.rect(x, 38, 2, 1, rag) }
    // The long front arm, a bony elbow low, reaching up to the knife; the claws round its grip.
    let held = swing(p, rest: -25, seated: -10, heavy: false)
    drawSmear(c, at: grishnakhHand, held.smear, from: 3, to: 11, heavy: false, core: C(0xDCE0E8), glow: C(0x8A9098))
    line(c, 34, 32, 39, 37, skin, 0.8); line(c, 39, 37, 43, 36, skin, 0.8)
    drawKnife(c, at: grishnakhHand, angle: held.angle)
    c.rect(43, 34, 3, 3, skin); c.px(43, 36, skinDark)
    c.px(46, 34, claw); c.px(46, 36, claw)
}

/// Grish-NaN's knife: a bone grip, a stub of an iron guard and a wicked blade that curves up to a hooked point, the
/// edge serrated.
private func drawKnife(_ c: PixelCanvas, at: (x: Double, y: Double), angle: Double) {
    prop(c, at: at, angle: angle) { s in
        let bone = C(0xC8BC98), iron = C(0x3A3A40), blade = C(0x8A9098), edge = C(0xDCE0E8)
        s.rect(-3, 0, 4, 1, bone); s.px(-3, 0, C(0x9A8E70))
        s.rect(1, -1, 1, 3, iron)
        s.pattern(2, -2, [".......BE", ".BBBBBBE.", "BBBBBBE..", "E.E.E...."], ["B": blade, "E": edge])
    }
}

// MARK: - Shagradle

/// Where Shagradle's sword hand is: a little further out than a Man's, he's that much broader.
private let shagratHand: (x: Double, y: Double) = (43.5, 34.5)

/// Shagradle, captain of the Tower of Cirith Ungol: a big, broad orc, wider than a Man, dark warm-brown skin, a rusty
/// iron helmet crowned with spikes, the Red Eye on a badge at its front and a riveted brim, a heavy brow, small eyes
/// and a jutting jaw with two tusks. A coat of grey mail to the thighs under a leather belt, a rusty pauldron on the
/// sword arm, a big iron-bound shield of black planks with a spiked boss on the other arm, and a broad, heavy sword.
/// No signature.
private func drawShagrat(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x5E3E24), skinDark = C(0x462C18), skinLight = C(0x7A5434)
    let iron = C(0x5E5852), ironDark = C(0x3C3834), ironLight = C(0x847C74), rust = C(0x7E4A2A)
    let mail = C(0x46464C), mailLight = C(0x6A6A72), leather = C(0x3A281A), tusk = C(0xE8E0C8)
    drawLegs(c, Look(leg: C(0x2E2620)), step: p.step)
    drawBoots(c, p.step, ironDark, rows: 3)
    c.oy += p.breathe
    // The broad body in his dark skin.
    c.rect(16, 26, 24, 12, skin)
    c.rect(39, 26, 1, 12, skinDark)
    // Heavy brows, small eyes, the jutting jaw with two tusks.
    c.rect(20, 27, 5, 1, skinDark); c.rect(31, 27, 5, 1, skinDark)
    c.rect(22, 28, 2, 2, ink); c.rect(33, 28, 2, 2, ink)
    c.px(22, 28, C(0xD8A030)); c.px(34, 28, C(0xD8A030))
    c.rect(24, 31, 10, 1, C(0x2A1A10)); c.rect(23, 32, 12, 1, skinLight)
    c.rect(23, 30, 1, 2, tusk); c.rect(34, 30, 1, 2, tusk)
    // The spiked helmet: a rusty dome, three spikes on top and one out at each side, a riveted brim, cheek guards.
    c.pattern(16, 19, [
        "......KKKKKKKKKKKK......",
        "....KKhhKKKKKKKKrKKK....",
        "..KKKhKKKKKKKKKKKKKKKK..",
        ".KKhKKKKKKKKKKKKKKKrKKd.",
        "KKKKKKKKKKKKKKKKKKKKKKKd",
    ], ["K": iron, "h": ironLight, "r": rust, "d": ironDark])
    for (x, top) in [(20, 17), (27, 14), (34, 17)] {
        c.rect(x, top + 1, 2, 19 - top, iron); c.px(x, top, ironLight); c.px(x, top + 1, ironLight)
    }
    c.rect(13, 23, 3, 1, iron); c.px(13, 23, ironLight); c.rect(40, 23, 3, 1, iron); c.px(42, 23, ironLight)
    c.rect(16, 24, 24, 2, ironDark)
    for x in stride(from: 17, through: 39, by: 4) { c.px(x, 24, ironLight) }
    c.rect(16, 26, 2, 4, iron); c.rect(38, 26, 2, 4, iron)
    // The Red Eye on its badge.
    c.rect(23, 20, 10, 4, ironDark)
    c.pattern(24, 21, ["..RRRR..", "RRYKKYRR", "..RRRR.."], ["R": C(0xC8301A), "Y": C(0xFFA030), "K": ink])
    // The mail coat, the belt and buckle, the mail skirt.
    c.rect(16, 33, 24, 5, mail)
    for y in 33...37 { for x in 16...39 where (x + y) % 2 == 0 { c.px(x, y, mailLight) } }
    c.rect(16, 36, 24, 1, leather); c.rect(27, 36, 3, 1, ironLight)
    if 38 + c.oy <= 43 {
        c.rect(17, 38, 22, 1, mail)
        for x in 17...38 where x % 2 == 0 { c.px(x, 38, mailLight) }
    }
    if 39 + c.oy <= 43 { for x in stride(from: 17, through: 36, by: 4) { c.rect(x, 39, 3, 1, mail) } }
    // The pauldron on the sword shoulder, the shield on the other arm.
    c.pattern(36, 30, [".PPPP.", "PhPPPP", "PPrPPd", ".Pddd."], ["P": iron, "h": ironLight, "r": rust, "d": ironDark])
    drawShield(c, x: 6, y: seatedPose ? 24 : 27)
    // The broad sword, and the fist over its grip.
    let held = swing(p, rest: 25, seated: 6, heavy: false)
    drawSmear(c, at: shagratHand, held.smear, from: 5, to: 18, heavy: false, core: C(0xC8CCD4), glow: C(0x7A7E86), width: 1)
    drawBroadsword(c, at: shagratHand, angle: held.angle)
    c.rect(40, 33, 2, 3, ironDark); c.rect(42, 33, 3, 3, skin); c.px(44, 35, skinDark)
}

/// Shagradle's shield, 11 × 15 from (`x`, `y`): black planks bound in rusty iron, rivets along the bands, a spiked
/// iron boss in the middle.
private func drawShield(_ c: PixelCanvas, x: Int, y: Int) {
    let wood = C(0x2E2620), woodLine = C(0x1E1814), iron = C(0x5E5852), ironDark = C(0x3C3834), light = C(0x847C74)
    let rust = C(0x7E4A2A)
    c.rect(x, y, 11, 15, ironDark)
    c.rect(x + 1, y + 1, 9, 13, wood)
    for k in [4, 7] { c.rect(x + k, y + 1, 1, 13, woodLine) }
    for r in [3, 11] {
        c.rect(x, y + r, 11, 1, iron)
        c.px(x + 2, y + r, light); c.px(x + 8, y + r, light)
    }
    c.rect(x + 4, y + 6, 3, 3, iron); c.px(x + 4, y + 6, light); c.px(x + 5, y + 7, C(0xB0A8A0)); c.px(x + 6, y + 8, ironDark)
    c.px(x + 1, y + 4, rust); c.px(x + 9, y + 12, rust); c.px(x + 3, y + 11, rust)
}

/// Shagradle's broad sword: a heavy round pommel, a leather grip, a wide iron crossguard and a broad straight blade with
/// a fuller down its middle, coming to a blunt point.
private func drawBroadsword(_ c: PixelCanvas, at: (x: Double, y: Double), angle: Double) {
    prop(c, at: at, angle: angle) { s in
        let steel = C(0x8A8E96), light = C(0xC0C4CC), fuller = C(0x5A5E66), iron = C(0x3A3632), grip = C(0x3A281A)
        s.rect(-5, -1, 2, 3, iron)
        s.rect(-3, 0, 5, 1, grip)
        s.rect(2, -3, 2, 7, iron); s.px(2, -3, C(0x6A645C))
        s.rect(4, -1, 14, 3, steel)
        s.rect(4, -1, 14, 1, light)
        s.rect(5, 0, 10, 1, fuller)
        s.px(18, 0, light)
    }
}

// MARK: - Olog-HA

/// Where Olog-HA's hammer hand is: out in front of his chest, a quarter again as high as a Man's.
private let ologHand: (x: Double, y: Double) = (46.5, 31.5)

/// Olog-HA, a battle-troll of Mordor, a quarter again a Man's height: hulking, black-skinned, a small head hunched low
/// between huge shoulders under an iron skullcap, small mean red eyes under a heavy brow, a jaw with two tusks. Heavy
/// iron plates strapped on with red leather: a breastplate in two layers, spiked pauldrons, a skirt of plates and shin
/// greaves. A huge iron-headed war hammer, its head resting low in front of him; heaved up and brought down idle, and a
/// swing smears a long way behind it. No signature.
private func drawOlogHai(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x2A2930), skinDark = C(0x1A191E), skinLight = C(0x42414C)
    let iron = C(0x6C6E74), ironDark = C(0x46484E), ironLight = C(0x9A9CA2), strap = C(0x6E2A1C)
    let tusk = C(0xD8D0B8), eye = C(0xF04A2A)
    // Two pillar legs in iron greaves, broad feet.
    for (i, lx) in [18, 31].enumerated() {
        if seatedPose { c.rect(lx - 1, 38, 9, 2, skinDark); c.rect(lx + 1, 38, 5, 1, iron); continue }
        let up = p.step >= 0 && i == p.step ? 1 : 0
        c.rect(lx, 35, 7, 7 - up, i == 0 ? skinDark : skin)
        c.rect(lx, 37 - up, 7, 3, iron); c.rect(lx, 37 - up, 7, 1, ironLight); c.rect(lx + 6, 37 - up, 1, 3, ironDark)
        c.rect(lx - 1, 42 - up, 9, 2, skinDark)
    }
    c.oy += p.breathe
    // The back arm, hanging, an iron bracer, the fist.
    c.rect(10, 22, 5, 11, skinDark); c.rect(10, 27, 5, 3, ironDark)
    c.rect(9, 32, 7, 5, skinDark); c.px(9, 32, skin)
    // The huge torso, broadest at the chest.
    let torso: [(l: Int, r: Int)] = [
        (19, 37), (17, 39), (15, 41), (14, 41), (14, 41), (14, 41), (14, 41), (14, 41), (14, 41), (14, 41), (14, 41),
        (15, 40), (15, 40), (15, 40), (16, 39), (16, 39), (17, 38),
    ]
    for (i, row) in torso.enumerated() {
        let y = 20 + i
        c.rect(row.l, y, row.r - row.l + 1, 1, skin)
        c.px(row.l, y, skinLight); c.px(row.r, y, skinDark)
    }
    // The straps over his shoulders, the two-layer breastplate with its rivets, the belt and the skirt of plates.
    c.rect(21, 20, 2, 4, strap); c.rect(33, 20, 2, 4, strap)
    c.rect(17, 24, 21, 5, iron); c.rect(17, 24, 21, 1, ironLight); c.rect(37, 24, 1, 5, ironDark)
    c.rect(18, 29, 19, 4, iron); c.rect(18, 29, 19, 1, ironLight); c.rect(36, 29, 1, 4, ironDark)
    c.rect(17, 28, 21, 1, ironDark)
    for x in [19, 27, 35] { c.px(x, 26, ironDark); c.px(x, 31, ironDark) }
    c.rect(15, 33, 26, 1, strap)
    for x in stride(from: 15, through: 38, by: 4) { c.rect(x, 34, 3, 3, ironDark); c.rect(x, 34, 3, 1, iron) }
    // The front arm reaching forward under its bracer.
    line(c, 39, 22, 44, 28, skin, 2.4)
    line(c, 41, 25, 44, 29, ironDark, 2.0)
    // The spiked pauldrons.
    c.pattern(11, 17, ["..S...S..", ".SPPPPPP.", "PPhPPPPPP", "PPPPPPPPd", ".PPPPPPd."],
              ["P": iron, "h": ironLight, "d": ironDark, "S": ironLight])
    c.pattern(36, 17, ["...S...S.", ".PPPPPPPP", "PPhPPPPPd", "PPPPPPPPd", ".PPPPPPd."],
              ["P": iron, "h": ironLight, "d": ironDark, "S": ironLight])
    // The small head hunched low between them: the iron skullcap, the heavy brow, small mean eyes, the tusks.
    c.pattern(27, 13, [
        "....HHHHH....",
        "..HHHhHHHHH..",
        ".HHhHHHHHHHH.",
        "DDDDDDDDDDDDD",
        "SBBSSSSSSSBBS",
        "SSSBBSSSBBSSS",
        "SSSESSSSSESSS",
        "SSSSSSddSSSSS",
        "STSSSSSSSSSTS",
        "STMMMMMMMMMTS",
        ".SSSSSSSSSSS.",
    ], ["H": iron, "h": ironLight, "D": ironDark, "S": skin, "B": skinDark, "d": skinDark, "E": eye, "M": C(0x0E0D10),
        "T": tusk])
    // The war hammer, and the fist over its haft.
    let held = swing(p, rest: 20, seated: 0, heavy: true)
    drawSmear(c, at: ologHand, held.smear, from: 10, to: 21, heavy: true, core: C(0xB0B2B8), glow: C(0x5A5C62, 0.5),
              width: 1.6)
    drawWarHammer(c, at: ologHand, angle: held.angle)
    c.rect(44, 29, 5, 5, skin); c.rect(44, 29, 5, 1, skinLight); c.rect(48, 30, 1, 4, skinDark)
}

/// Olog-HA's war hammer: a long haft, iron-shod at the butt and bound below the head, and a massive banded iron head
/// with studs, a short spike on its face.
private func drawWarHammer(_ c: PixelCanvas, at: (x: Double, y: Double), angle: Double) {
    prop(c, at: at, angle: angle) { s in
        let wood = C(0x3E2C1E), woodDark = C(0x2A1E14), iron = C(0x5E6066), dark = C(0x3A3C42), light = C(0x8E9096)
        s.rect(-5, 0, 20, 2, wood); s.rect(-5, 1, 20, 1, woodDark)
        s.rect(-5, 0, 2, 2, dark); s.rect(11, 0, 3, 2, dark)
        s.rect(14, -4, 6, 10, iron)
        s.rect(14, -4, 6, 1, light); s.rect(14, -4, 1, 10, light)
        s.rect(19, -4, 1, 10, dark); s.rect(14, 5, 6, 1, dark)
        s.rect(15, -1, 4, 1, dark); s.rect(15, 2, 4, 1, dark)
        s.px(16, -3, light); s.px(17, 4, light)
        s.rect(20, 0, 2, 2, dark)
    }
}

// MARK: - The Cave Troll-ing

/// Where the Cave Troll-ing's club hand is: out in front of its chest, half again as high as a Man's.
private let caveTrollHand: (x: Double, y: Double) = (48.5, 29.5)

/// The Cave Troll-ing, the troll of Moria, half again a Man's height: a hulking grey-green brute, warty all over, a pot
/// belly, short thick legs with broad toed feet, the back arm hanging past its knee. A small head hunched forward
/// between the shoulders, the brow pulled down in a dim scowl over tiny eyes, a big lumpy nose and an underbite with
/// two teeth jutting up. An iron collar of chain round its neck, the rest of the chain trailing behind it to the
/// floor; a ragged leather loincloth. A huge knobbly wooden club, held low at rest; heaved up and brought down idle,
/// and a swing smears a long way behind it. Doesn't sit. No signature.
private func drawCaveTroll(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x748680), skinDark = C(0x56665F), skinLight = C(0x90A29A), belly = C(0x82948D)
    let wart = C(0x5A6A62), wartLight = C(0xA4B4AC)
    let cloth = C(0x5C4632), clothDark = C(0x3E2E1E), chain = C(0x8A8C92), chainDark = C(0x4C4E54)
    let nail = C(0xC8BC98), mouth = C(0x2A1C18), tooth = C(0xDCD2B0)
    // Short thick legs, broad feet with toenails.
    for (i, lx) in [16, 31].enumerated() {
        let up = p.step >= 0 && i == p.step ? 1 : 0
        let col = i == 0 ? skinDark : skin
        c.rect(lx, 33, 9, 8 - up, col)
        c.rect(lx - 1, 41 - up, 11, 3, col)
        for k in 0..<3 { c.px(lx + 4 + k * 2, 43 - up, nail) }
    }
    c.oy += p.breathe
    // The back arm, hanging past its knee, the fist by its foot.
    c.rect(7, 18, 7, 7, skinDark)
    c.rect(6, 24, 7, 11, skinDark)
    c.rect(5, 34, 8, 6, skinDark); c.rect(5, 34, 1, 5, skin); c.px(12, 39, wart)
    // The chain from the collar, down over the arm and trailing behind it to the floor, swaying a little.
    let sway: Double = sin(p.lt * 1.7) * 1.2
    for k in 0..<16 {
        let f = Double(k) / 15
        let x = Int((15 - 13 * f + sway * f * (1 - f) * 4).rounded()), y = 20 + Int((22 * f).rounded())
        if k % 2 == 0 { c.rect(x, y, 2, 1, chain) } else { c.rect(x, y, 1, 2, chainDark) }
    }
    // The hulking body and pot belly.
    let torso: [(l: Int, r: Int)] = [
        (18, 36), (15, 39), (13, 41), (12, 42), (11, 43), (11, 43), (11, 43), (11, 44), (11, 44), (11, 45), (11, 45),
        (11, 45), (11, 45), (11, 45), (11, 44), (12, 44), (12, 43), (13, 42), (14, 41), (15, 40), (16, 39),
    ]
    for (i, row) in torso.enumerated() {
        let y = 15 + i
        c.rect(row.l, y, row.r - row.l + 1, 1, skin)
        c.px(row.l, y, skinLight); c.px(row.r, y, skinDark)
    }
    c.ellipse(33, 27, 9, 5, belly)
    c.px(34, 29, skinDark)
    c.rect(16, 22, 9, 1, skinDark); c.rect(28, 22, 7, 1, skinDark)                 // the slack chest
    for (x, y) in [(14, 19), (19, 25), (13, 29), (24, 18), (40, 21), (43, 31), (29, 25), (38, 26), (17, 33), (41, 35)] {
        c.px(x, y, wart); c.px(x - 1, y - 1, wartLight)
    }
    // The loincloth: a belt, a ragged flap in front, a scrap behind.
    c.rect(12, 31, 33, 2, clothDark)
    c.rect(22, 33, 13, 5, cloth); c.rect(34, 33, 1, 5, clothDark)
    for x in stride(from: 22, through: 33, by: 3) { c.rect(x, 38, 2, 1, cloth) }
    c.rect(12, 33, 5, 3, cloth); c.px(13, 36, cloth)
    // The collar of chain round its neck, the shackle where the chain hangs from it.
    for x in stride(from: 16, through: 30, by: 2) { c.rect(x, 18, 2, 1, chain); c.px(x, 19, chainDark) }
    c.rect(14, 18, 3, 3, chainDark); c.px(15, 19, chain)
    // The front arm reaching forward, under the head.
    line(c, 40, 19, 46, 26, skin, 2.8)
    // The small head, hunched forward: a dim scowl, tiny eyes, a lumpy nose, the underbite.
    c.pattern(28, 9, [
        ".....SSSSSS.....",
        "...SSSSSSSSSS...",
        "..SSSSSSSSSSSSS.",
        ".SSSSSSSSSSSSSSS",
        ".SSBBSSSSSSBBSSS",
        ".SSSSBBSSBBSSSSS",
        ".SSSKKSNNSKKSSSS",
        ".SSSSSNNNNSSSSSS",
        "SSSSSSNdNdSSSSSS",
        "SSSMTMMMMMMTMSSS",
        "SSSSTSSSSSSTSSSS",
        ".SSSSSSSSSSSSSS.",
        "..SSSSSSSSSSSS..",
    ], ["S": skin, "B": C(0x34403C), "K": ink, "N": skinLight, "d": skinDark, "M": mouth, "T": tooth])
    c.rect(43, 12, 1, 9, skinDark)
    c.px(31, 11, wart); c.px(30, 10, wartLight); c.px(40, 18, wart)
    // The club, and the fist over its grip.
    let held = swing(p, rest: 32, seated: 32, heavy: true)
    drawSmear(c, at: caveTrollHand, held.smear, from: 10, to: 20, heavy: true, core: C(0x9A7A54), glow: C(0x5A4430, 0.5),
              width: 2)
    drawClub(c, at: caveTrollHand, angle: held.angle)
    c.rect(45, 26, 7, 7, skin); c.rect(45, 26, 7, 1, skinLight); c.rect(51, 27, 1, 6, skinDark); c.rect(45, 32, 7, 1, skinDark)
}

/// The Cave Troll-ing's club: a length of tree, thin at the grip and swelling to a great knobbly head, a few iron
/// spikes driven through it.
private func drawClub(_ c: PixelCanvas, at: (x: Double, y: Double), angle: Double) {
    prop(c, at: at, angle: angle) { s in
        let wood = C(0x6A4A2E), dark = C(0x4A321E), light = C(0x8A6440), spike = C(0x9A9CA2)
        for x in -4...17 {
            let r: Int = x < 4 ? 1 : min(4, 1 + (x - 2) / 5)
            s.rect(x, -r, 1, 2 * r + 1, wood)
            s.px(x, -r, light); s.px(x, r, dark)
        }
        s.rect(18, -3, 1, 7, wood); s.px(18, 3, dark)
        s.rect(19, -2, 1, 5, dark)
        for (x, y) in [(8, 0), (12, -1), (15, 2), (11, 2)] { s.px(x, y, dark) }       // knots
        for (x, y) in [(11, -4), (14, -5), (17, 5), (13, 4)] { s.px(x, y, spike) }
    }
}

// MARK: - Blog, son of Azog

/// Where Blog's mace hand is: a little further out than a Man's, he's that much bigger.
private let bolgHand: (x: Double, y: Double) = (43.5, 34.5)

/// Blog, son of Azog: a huge orc, a head taller than a Man and broader, ashen grey skin, his skull and face bolted
/// with iron: a riveted plate over the crown, a smaller one over his brow, a jaw-plate with jagged teeth showing over
/// it. Small red-glinting eyes, a scar down one cheek. Bare to the waist, his grey torso criss-crossed with pale
/// stitched scars, a hide war-skirt; iron bracers. A spiked mace, held low; heaved up and brought down idle, and a swing
/// smears a long way behind it. No signature.
private func drawBolg(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x8E928E), skinDark = C(0x6C706C), skinLight = C(0xA8ACA8), scar = C(0xC8B0AC), stitch = C(0x4E4246)
    let iron = C(0x4A4C52), ironDark = C(0x30323A), ironLight = C(0x7A7C84), bolt = C(0xD0D4DC)
    let hide = C(0x4A3A2C), hideDark = C(0x33281E), tooth = C(0xE0D8C0)
    // Big legs, iron-shod.
    for (i, lx) in [18, 22, 31, 35].enumerated() {
        if seatedPose { c.rect(lx - 1, 38, 4, 2, skinDark); continue }
        let lifted = p.step >= 0 && i % 2 == p.step
        c.rect(lx, 36, 3, lifted ? 7 : 8, skinDark)
        c.rect(lx, lifted ? 40 : 41, 3, 3, ironDark)
    }
    c.oy += p.breathe
    // The big body in his grey skin, a bracer on the off arm.
    c.rect(13, 32, 3, 4, skin); c.rect(13, 32, 3, 2, ironDark)
    c.rect(16, 22, 24, 16, skin)
    c.rect(39, 22, 1, 16, skinDark)
    // The riveted plate bolted over his crown.
    c.pattern(17, 18, [
        ".......PPPPPPPP.......",
        "....PPPhPPPPPPPPPP....",
        "..PPhPPPPPPPPPPPPPPP..",
        ".PPPPPPPPPPPPPPPPPPPd.",
        "PPbPPPPbPPPPPbPPPPPbPd",
        "..PP.......PPP........",
    ], ["P": iron, "h": ironLight, "d": ironDark, "b": bolt])
    // The eyes, the back brow, the plate bolted over the front one, a scar down the cheek.
    c.rect(21, 25, 3, 1, skinDark)
    c.rect(31, 24, 6, 2, iron); c.rect(31, 24, 6, 1, ironLight); c.px(32, 25, bolt); c.px(35, 25, bolt)
    c.rect(22, 26, 2, 2, ink); c.rect(33, 26, 2, 2, ink)
    c.px(22, 26, C(0xE04A2A)); c.px(34, 26, C(0xE04A2A))
    for (x, y) in [(18, 24), (19, 25), (19, 26), (20, 27), (20, 28)] { c.px(x, y, scar) }
    // The jaw-plate, jagged teeth over it.
    c.rect(27, 29, 12, 1, C(0x1E1A1A))
    for x in [27, 29, 31, 34, 36, 38] { c.px(x, 29, tooth) }
    c.rect(26, 30, 14, 3, iron); c.rect(26, 30, 14, 1, ironLight); c.rect(26, 32, 14, 1, ironDark)
    for x in [27, 32, 37] { c.px(x, 31, bolt) }
    // The bare chest: the muscles, pale stitched scars across it.
    c.rect(18, 34, 8, 1, skinDark); c.rect(29, 34, 8, 1, skinDark); c.px(27, 35, skinDark); c.px(27, 36, skinDark)
    c.rect(17, 33, 9, 1, skinLight)
    for (x, y) in [(19, 33), (20, 34), (21, 35), (22, 36), (31, 33), (32, 33), (33, 34), (34, 34), (35, 35)] { c.px(x, y, scar) }
    for (x, y) in [(20, 33), (22, 35), (32, 32), (34, 33)] { c.px(x, y, stitch) }
    // The hide war-skirt.
    c.rect(16, 37, 24, 1, hideDark)
    for x in stride(from: 16, through: 38, by: 3) where 38 + c.oy <= 43 {
        c.rect(x, 38, 2, 39 + c.oy <= 43 ? 2 : 1, hide)
    }
    // The spiked mace, and the fist over its haft.
    let held = swing(p, rest: 10, seated: 0, heavy: true)
    drawSmear(c, at: bolgHand, held.smear, from: 10, to: 19, heavy: true, core: C(0xB8BCC4), glow: C(0x5A5C62, 0.5), width: 1.4)
    drawSpikedMace(c, at: bolgHand, angle: held.angle)
    c.rect(40, 32, 2, 4, ironDark); c.rect(42, 33, 3, 3, skin); c.px(44, 35, skinDark)
}

/// Blog's mace: a dark wooden haft and a heavy iron ball bristling with long spikes.
private func drawSpikedMace(_ c: PixelCanvas, at: (x: Double, y: Double), angle: Double) {
    prop(c, at: at, angle: angle) { s in
        let wood = C(0x3A2A1E), woodDark = C(0x281C14), iron = C(0x3E4048), dark = C(0x26282E), light = C(0x6E7078)
        let spike = C(0xA8ACB4)
        s.rect(-4, 0, 15, 2, wood); s.rect(-4, 1, 15, 1, woodDark)
        s.pattern(10, -3, [
            "..IIIII..",
            ".IILIIII.",
            "IILIIIIII",
            "IIIIIIIID",
            "IIIIIIIID",
            "IIIIIIIDD",
            ".IIIIIDD.",
            "..DDDDD..",
        ], ["I": iron, "L": light, "D": dark])
        for (x, y) in [(14, -5), (14, -4), (14, 5), (14, 6), (19, 0), (20, 0), (19, 1), (20, 1), (10, -4), (18, -4),
                       (10, 5), (18, 5), (9, -1)] {
            s.px(x, y, spike)
        }
    }
}

// MARK: - Shared helpers

private let clear = C(0x000000, 0)

/// Where a melee weapon points this frame, and the angles to smear behind it: `p.melee`, or `rest` when it's put away
/// (`seated` when sitting). A heavy weapon is heaved up and brought down for the idle flourish instead of twirled, and
/// its smear runs a long way behind it.
private func swing(_ p: Pose, rest: Double, seated: Double, heavy: Bool) -> (angle: Double, smear: [Double]) {
    let restAngle = seatedPose ? seated : rest
    if heavy, let h = idlePlay(p), h.kind == .flourish {
        let at = { (u: Double) -> Double in restAngle - 115 * habitArc(u, hold: 0.2) }
        let now = at(h.p), before = at(max(0, h.p - 0.04))
        return (now, heavySmear(now, abs(before - now) > 4 ? [before, before + (before - now)] : []))
    }
    guard let a = p.melee else { return (restAngle, []) }
    return (a, heavy ? heavySmear(a, p.trail) : p.trail)
}

/// The smear behind a swung weapon, between `inner` and `outer` pixels out from the hand `h` along each angle, fading
/// behind; kept off the floor.
private func drawSmear(_ c: PixelCanvas, at h: (x: Double, y: Double), _ angles: [Double], from inner: Double,
                       to outer: Double, heavy: Bool, core: Px, glow: Px, width: Double = 0.6) {
    let floor = Double(43 - c.oy)
    for (i, a) in angles.enumerated() {
        let fade: Double = heavy ? 0.35 * (1 - Double(i) / 12) : 0.3 / Double(i + 1)
        guard fade > 0.03 else { break }
        let u = unit(a)
        let out: Double = u.y > 0.05 ? min(outer, (floor - 1 - h.y) / u.y) : outer
        guard out > inner else { continue }
        c.glowLine(h.x + u.x * inner, h.y + u.y * inner, h.x + u.x * out, h.y + u.y * out, core: core, glow: glow,
                   coreR: width, glowR: width + 1, strength: fade)
    }
}

/// The idle habit playing now, if this pose is the one it's played in (idle, standing, not fighting).
private func idlePlay(_ p: Pose) -> HabitPlay? {
    guard !p.walking, p.mode == .idle, let h = idleHabit else { return nil }
    switch p.role { case .none, .rest: return h; default: return nil }
}

/// The angles a heavy swing smears through: from now back past `trail`'s last angle by half as far again, so the smear
/// is longer than a light blade's (the weapon looks slower, heavier). Empty when it isn't being swung fast.
private func heavySmear(_ now: Double, _ trail: [Double]) -> [Double] {
    guard let last = trail.last else { return [] }
    let end: Double = last + (last - now) * 0.5
    let n = max(2, Int((abs(end - now) / 5).rounded()))
    return (1...n).map { (i: Int) -> Double in now + (end - now) * Double(i) / Double(n) }
}

/// Boots (or wraps) over the bottom `rows` of each leg, and a bit of the folded foot when sitting.
private func drawBoots(_ c: PixelCanvas, _ step: Int, _ col: Px, rows: Int = 2) {
    if seatedPose {
        for lx in [19, 23, 31, 35] { c.rect(lx + 1, 38, 2, 2, col) }
        return
    }
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        let bottom = step >= 0 && i % 2 == step ? 42 : 43
        c.rect(lx, bottom - rows + 1, 2, rows, col)
    }
}

private func unit(_ degrees: Double) -> (x: Double, y: Double) {
    let r: Double = degrees * .pi / 180
    return (cos(r), sin(r))
}

/// A solid pixel line (no glow), `r` its half-width.
private func line(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.7) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: clear, coreR: r, glowR: r + 0.1)
}

/// A prop drawn pointing right from the hand at pixel (0, 0) of a scratch canvas (it reaches 30 pixels every way),
/// turned to `angle` degrees (0 forward, -90 up) and placed with the hand on `at`.
private func prop(_ c: PixelCanvas, at: (x: Double, y: Double), angle: Double, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(61, 61)
    s.ox = 30; s.oy = 30
    art(s)
    let r = s.rotated(angle, about: (30.5, 30.5), into: 61, 61, at: (30.5, 30.5))
    let x0 = Int(floor(at.x - 30.5)), y0 = Int(floor(at.y - 30.5))
    for y in 0..<r.h {
        for x in 0..<r.w {
            let i = (y * r.w + x) * 4
            guard r.buf[i + 3] > 0 else { continue }
            c.px(x0 + x, y0 + y, unpremultiplied(r, i))
        }
    }
}

private func unpremultiplied(_ s: PixelCanvas, _ i: Int) -> Px {
    let a = s.buf[i + 3], m = 255 / Double(a)
    return Px(r: UInt8(min(255, Double(s.buf[i]) * m)), g: UInt8(min(255, Double(s.buf[i + 1]) * m)),
              b: UInt8(min(255, Double(s.buf[i + 2]) * m)), a: a)
}
