import Foundation

// Star Wars heroes: Jar Jar to Admiral Ackbar. Ported from Clawd Wars' Recruits.swift.

let starWarsHeroes2: [SWHero: Persona] = [
    .jarjar: Persona(name: "J.J Blinks", headTop: 18,
                  draw: drawJarjar),
    .lando: Persona(name: "Lando Coolrissian", weapon: .blaster, muzzle: (47, 32), headTop: 22,
                  soloFire: (1.0, 0.3),
                  draw: drawLando),
    .zorii: Persona(name: "Zori Blitz", weapon: .blaster, muzzle: (47, 32), headTop: 19,
                  soloFire: (0.85, 0.6),
                  draw: drawZorii),
    .boKatan: Persona(name: "Bo-Kitan Krays", weapon: .blaster, muzzle: (47, 32), headTop: 19,
                  soloFire: (0.8, 0.1),
                  draw: drawBoKatan),
    .maz: Persona(name: "Maz Kanapé", headTop: 22, signature: 2.4,
                  draw: drawMaz),
    .wedge: Persona(name: "Wedge Antlers", weapon: .blaster, muzzle: (47, 32), headTop: 19,
                  soloFire: (0.9, 0.45),
                  draw: drawWedge),
    .l337: Persona(name: "LE-ET", headTop: 17,
                  draw: drawL337),
    .monMothma: Persona(name: "Mon Mothball", canSit: false, headTop: 22,
                  draw: drawMonMothma),
    .padme: Persona(name: "Padmé Amidrama", weapon: .blaster, muzzle: (47, 32), headTop: 22,
                  soloFire: (1.1, 0.2),
                  draw: drawPadme),
    .ackbar: Persona(name: "Admiral Snackbar", headTop: 17,
                  draw: drawAckbar),
]

// MARK: - Shared

/// Legs, then the origin raised for the upper body. Cheering, the legs stay on the ground and only the body hops,
/// as in Clawd Wars. `boots` (if any) go on the legs `rows` high, with a glint of `shine` down their fronts.
private func heroLegs(_ c: PixelCanvas, _ p: Pose, _ look: Look, boots: Px? = nil, rows: Int = 2, shine: Px? = nil) {
    let grounded = p.cheering && !p.walking
    if grounded { c.oy -= p.hop }
    drawLegs(c, look, step: p.step)
    if let boots { drawBoots(c, boots, step: p.step, rows: rows) }
    if let shine { drawBootShine(c, step: p.step, shine) }
    if grounded { c.oy += p.hop }
    c.oy += p.breathe
}

/// A glint of light on the toe of each two-row boot (not when sitting), lifting with the leg as it steps.
private func drawBootShine(_ c: PixelCanvas, step: Int, _ col: Px) {
    guard !seatedPose else { return }
    for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx, step >= 0 && i % 2 == step ? 41 : 42, col) }
}

/// A gown or robe from `top` to the floor, widening to the hem (drawn instead of legs).
private func drawSkirt(_ c: PixelCanvas, from top: Int = 38, _ main: Px, _ edge: Px) {
    for y in top...43 {
        let k = (y - top) / 2
        c.rect(18 - k, y, 20 + k * 2, 1, main)
        c.px(18 - k, y, edge); c.px(37 + k, y, edge)
    }
}

/// The pistol in the right hand, raised or kicking as the pose says; its muzzle is at (47, 32).
private func heroPistol(_ c: PixelCanvas, _ p: Pose) {
    c.oy += p.gunY
    drawPistol(c, x: 40, y: 31)
    c.oy -= p.gunY
}

/// A Mandalorian helmet: the T visor, and on Bo-Katan the Nite Owl markings either side of it.
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

// MARK: - Heroes

/// Jar Jar Binks: a Gungan, all ears and eyestalks, arms everywhere. Unarmed (mesa no fight).
private func drawJarjar(_ c: PixelCanvas, _ p: Pose) {
    let t = p.t
    let skin = C(0xD9935A), skinDark = C(0xB0703C), cloth = C(0x6E5A3A), clothDark = C(0x54442A)
    let flail = Int(t * 5) % 2
    let look = Look(body: skin, shade: skinDark, leg: cloth, arm: skin, eye: nil)
    heroLegs(c, p, look)
    // Long ears hanging down both sides, under the arms.
    let ear = ["EE..", "EEE.", ".EE.", ".EEE", "..EE", "..EE", "..EE", "..EE", ".EEE", ".EEE", "EEE.", "EE..", "E..."]
    c.pattern(13, 26, ear, ["E": skinDark])
    c.pattern(39, 26, ear.map { String($0.reversed()) }, ["E": skinDark])
    drawBody(c, look, armLeft: flail == 0 ? 3 : 0, armRight: flail == 0 ? 0 : 3)
    // Eyes up on stalks, wobbling.
    let wob = sin(t * 7) > 0 ? 1 : 0
    c.rect(23, 21, 1, 5, skin); c.rect(32, 21, 1, 5, skin)
    for ex in [21 + wob, 30 + wob] {
        c.pattern(ex, 18, [".WWW.", "WWWkW", ".WWW."], ["W": C(0xF2E8C8), "k": ink])
    }
    c.rect(35, 30, 6, 3, skin)                  // the duck bill
    c.rect(36, 32, 5, 1, skinDark)
    c.rect(18, 34, 20, 4, cloth)
    c.rect(18, 34, 20, 1, clothDark)
}

/// Lando Calrissian: neat moustache, sky-blue shirt and a cape lined in gold.
private func drawLando(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0x8FB4D9), hair = C(0x1E1612)
    // The cape's hem is clipped at the feet by `c.oy`: a whole-sprite shift (sitting down, hopping) goes through
    // `baseY` instead, as in Clawd Wars, so the cape still reaches the floor seated. Only a cheer hop moves it.
    let shift = p.cheering && !p.walking ? 0 : p.hop
    c.oy += p.breathe - shift; c.baseY += shift
    drawCape(c, t: p.t, speed: 1.4, color: C(0x24305A), edge: C(0xE0B84A))
    c.oy -= p.breathe - shift; c.baseY -= shift
    let shirtShade = C(0x6E92B8), gold = C(0xE0B84A), goldDark = C(0xA8852E)
    let look = Look(leg: C(0x2A2E44), arm: shirt)
    let grounded = p.cheering && !p.walking
    if grounded { c.oy -= p.hop }
    drawLegs(c, look, step: p.step)
    drawBoots(c, C(0x14161E), step: p.step, rows: 2)   // tall black boots
    if grounded { c.oy += p.hop }
    c.oy += p.breathe
    drawBody(c, look)
    c.rect(15, 35, 3, 1, shirtShade); c.rect(38, 35, 3, 1, shirtShade)   // the sleeves' cuffs
    c.pattern(18, 22, [
        "...HHHHHHHHHHHHHH...",
        ".HHHHhHHHHHHHhHHHHH.",
        "HHHHHHHHHHHHHHHHHHHH",
        "HH................HH",
    ], ["H": hair, "h": C(0x3E3028)])
    c.rect(24, 32, 8, 1, hair)                  // the moustache
    // The shirt, with its high gold-trimmed collar and the trim running down the front, folds shaded.
    c.rect(18, 34, 20, 4, shirt)
    c.rect(37, 34, 1, 4, shirtShade); c.px(21, 35, shirtShade); c.px(33, 35, shirtShade)
    c.rect(18, 33, 20, 1, gold); c.rect(24, 33, 8, 1, goldDark)
    c.rect(29, 34, 1, 2, gold)
    // The cape's gold clasps on the shoulders.
    c.px(18, 33, C(0xF6DC88)); c.px(37, 33, C(0xF6DC88))
    // The belt and its buckle.
    c.rect(18, 36, 20, 1, C(0x3A2A1C))
    c.rect(27, 36, 3, 1, gold); c.px(28, 36, goldDark)
    heroPistol(c, p)
}

/// Zorii Bliss: the bronze helmet with its dark visor and an orange glint, maroon flight suit.
private func drawZorii(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x5A2A3A), suitDark = C(0x44202C), suitHi = C(0x74384A)
    let look = Look(body: suit, shade: suitDark, leg: C(0x3A2A30), arm: suit, eye: nil)
    let grounded = p.cheering && !p.walking
    if grounded { c.oy -= p.hop }
    drawLegs(c, look, step: p.step)
    drawBoots(c, C(0x1E1418), step: p.step, rows: 3)   // tall black flight boots
    if grounded { c.oy += p.hop }
    c.oy += p.breathe
    drawBody(c, look)
    c.rect(15, 35, 3, 1, suitDark); c.rect(38, 35, 3, 1, suitDark)   // the gloves' cuffs
    // The helmet: the seam round the dome, the visor's bolts, the grille's slots.
    c.pattern(17, 19, [
        ".....BBBBBBBBBBBB.....",
        "...BBBBBBBBBBBBBBBB...",
        "..BBhhBBBBBBBBBBBBBB..",
        ".BBhBBBBBBBBBBBBBBBBB.",
        ".BBBBBBBBBBBBBBBBBBBB.",
        "BBBBBBBBBBBBBBBBBBBBBB",
        "BBBBBBBBBBBBBBBBBBBBBB",
        "BBBBBBBBBBBBBBBBBBBBBs",
        "ssssssssssssssssssssss",
        "BoVVVVVVVVVVVVVVVVVVoB",
        "BBvvvvvvvvvvvvvvvvvvBB",
        "BBBBBBBBBBBBBBBBBBBBBs",
        ".BBBBBBBBGgGgBBBBBBBs.",
        "..ssssssssssssssssss..",
    ], ["B": C(0xB8923E), "h": C(0xE8C870), "V": C(0x1A1410), "v": C(0xD86A2A), "G": C(0x5A4420),
        "g": C(0x2E2210), "s": C(0x8E6E2C), "o": C(0x5A4420)])
    // The flight suit: a quilted chest, the light on one shoulder, a fold down the side.
    c.rect(19, 33, 2, 1, suitHi); c.rect(34, 33, 2, 1, suitHi)
    for x in [21, 24, 31, 34] { c.px(x, 34, suitDark) }
    c.rect(37, 33, 1, 4, suitDark)
    // The belt, its bronze buckle, the holster strap hanging off it.
    c.rect(18, 36, 20, 1, C(0x2A1A1E))
    c.rect(27, 36, 2, 1, C(0xB8923E)); c.px(27, 36, C(0xE8C870))
    c.rect(33, 37, 2, 1, C(0x2A1A1E))
    heroPistol(c, p)
}

/// Bo-Katan Kryze: blue Mandalorian armour, the Nite Owl helmet, a blaster in hand.
private func drawBoKatan(_ c: PixelCanvas, _ p: Pose) {
    let blue = C(0x4A6EA8), suit = C(0x3A3E48), blueHi = C(0x7A9AD0), blueDark = C(0x34507E)
    let look = Look(body: suit, shade: C(0x2C2F38), leg: C(0x2C2F38), arm: blue, eye: nil)
    let grounded = p.cheering && !p.walking
    if grounded { c.oy -= p.hop }
    drawLegs(c, look, step: p.step)
    if !seatedPose {                                                // blue knee plates, lit on top
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let y = p.step >= 0 && i % 2 == p.step ? 38 : 39
            c.rect(lx, y, 2, 2, blue); c.px(lx, y, blueHi)
        }
    }
    drawBoots(c, blueDark, step: p.step, rows: 2)                   // armoured blue boots
    drawBootShine(c, step: p.step, C(0x5A7AB0))
    if grounded { c.oy += p.hop }
    c.oy += p.breathe
    drawBody(c, look)
    c.rect(15, 33, 3, 1, blueHi); c.rect(38, 33, 3, 1, blueHi)     // the pauldrons lit on top
    c.rect(15, 35, 3, 1, suit); c.rect(38, 35, 3, 1, suit)          // dark gloves
    drawMandoHelmet(c, C(0x5A7AB0), C(0x9AB4E0), marks: C(0x24345A))
    c.rect(37, 24, 1, 7, C(0x4A68A0)); c.rect(21, 32, 15, 1, C(0x4A68A0))   // the helmet's far side and rim in shadow
    c.rect(20, 20, 3, 1, C(0x9AB4E0))                               // the light along the dome
    // The chest plates, lit along the top, a seam down the middle and a rivet either side.
    c.rect(19, 33, 18, 3, blue)
    c.rect(19, 33, 18, 1, blueHi)
    c.rect(28, 34, 1, 2, blueDark); c.px(21, 34, blueDark); c.px(34, 34, blueDark); c.rect(36, 34, 1, 2, blueDark)
    // The belt: a silver buckle, pouches at the hip.
    c.rect(18, 36, 20, 1, C(0x5A4A3A))
    c.rect(27, 36, 2, 1, C(0xB8BCC4)); c.px(27, 36, C(0xE4E8EE))
    c.rect(20, 36, 2, 2, C(0x3E3024)); c.rect(33, 36, 2, 2, C(0x3E3024))
    heroPistol(c, p)
}

/// Maz Kanata: small and orange, with the big round goggles that see right through you.
private func drawMaz(_ c: PixelCanvas, _ p: Pose) {
    let t = p.t
    let skin = C(0xD98E4A), skinDark = C(0xB06E34)
    let look = Look(body: skin, shade: skinDark, leg: C(0x5A4430), arm: skin, eye: nil)
    heroLegs(c, p, look, boots: C(0x3A2A1E), shine: C(0x6A5440))  // soft dark boots
    drawBody(c, look)
    c.px(15, 34, C(0xD8B040)); c.px(39, 34, C(0xD8B040))            // a bangle on each wrist
    // The wrap round her head: a band across it, the light running along the folds.
    c.pattern(18, 22, [
        "...WWWwwwWWWWwwWW...",
        ".WWWWwWWWWWWWWwWWWW.",
        "bbbbbbbbbbbbbbbbbbbb",
    ], ["W": C(0x6A4A32), "w": C(0x8A6A4A), "b": C(0x4E3422)])
    c.px(20, 24, C(0xD8B040)); c.px(35, 24, C(0xD8B040))            // beads on the band
    // A thousand years of wrinkles: lines under the goggles and at the mouth.
    c.rect(19, 32, 2, 1, skinDark); c.rect(35, 32, 2, 1, skinDark); c.rect(26, 32, 4, 1, skinDark)
    // The goggles: brass rims, dark lenses, eyes swimming behind them (they focus now and then).
    // Signature: she reaches up and twists the rims, and her eyes swim up huge behind the lenses: she sees you.
    let adjust = p.signature.flatMap { $0 > 0.1 && $0 < 0.9 ? ($0 - 0.1) / 0.8 : nil }
    let zoom = adjust.map { $0 > 0.3 } ?? false
    let focus = !zoom && sin(t * 0.9) > 0.85
    for ex in [23, 33] {
        c.circle(ex, 30, zoom ? 4 : 3, C(0x8A6A3A))
        c.circle(ex, 30, zoom ? 3 : 2, C(0x2A3A4A))
        if zoom {                                                    // magnified eyes
            c.circle(ex, 30, 2, C(0xF4ECD8)); c.rect(ex - 1, 29, 2, 3, C(0x1A1008)); c.px(ex - 1, 29, C(0x6A4A2A))
        } else {
            c.rect(ex, 30, focus ? 1 : 2, focus ? 1 : 2, C(0x1A1008))
        }
        c.px(ex - (zoom ? 2 : 1), zoom ? 28 : 29, C(0xBFE0F0))
    }
    c.rect(26, 30, 4, 1, C(0x8A6A3A))
    if let k = adjust {
        let a = k * 8                                                // the rim turning: a bright notch going round
        c.px(33 + Int((cos(a) * (zoom ? 4 : 3)).rounded()), 30 + Int((sin(a) * (zoom ? 4 : 3)).rounded()), C(0xF0D080))
        c.rect(37, 32, 3, 4, skin); c.rect(36, 31, 2, 2, skin)       // her fingers on the rim
    }
    // The layered tunic: a darker vest over it, folds shaded, the beads strung across with a dark bead every so
    // often, a sash at the waist.
    c.rect(18, 34, 20, 4, C(0x8A6A4A))
    c.rect(18, 34, 3, 4, C(0x6A4A32)); c.rect(35, 34, 3, 4, C(0x6A4A32))
    c.rect(37, 34, 1, 4, C(0x4E3422)); c.px(25, 36, C(0x74563A)); c.px(30, 37, C(0x74563A))
    c.rect(22, 34, 12, 1, C(0xD8B040))           // beads
    for x in [24, 28, 32] { c.px(x, 34, C(0x8A4A2A)) }
    c.rect(18, 37, 20, 1, C(0x5A3E28)); c.px(27, 37, C(0xD8B040))
}

/// Wedge Antilles: an X-wing pilot, orange flight suit and white helmet with red flashes.
private func drawWedge(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0xE0782A), white = C(0xEDEDED), suitShade = C(0xB85E1E), strap = C(0xC8C8CC)
    let look = Look(leg: suit, arm: suit)
    let grounded = p.cheering && !p.walking
    if grounded { c.oy -= p.hop }
    drawLegs(c, look, step: p.step)
    drawBoots(c, C(0x1E1E24), step: p.step, rows: 2)   // black flight boots
    if grounded { c.oy += p.hop }
    c.oy += p.breathe
    drawBody(c, look)
    c.rect(15, 35, 3, 1, C(0x2A2A30)); c.rect(38, 35, 3, 1, C(0x2A2A30))   // black gloves
    // The helmet: a shine on the dome, its right side in shadow, the visor's rim catching the light.
    c.pattern(17, 19, [
        ".....WWWWWWWWWWWW.....",
        "...WWWlWWWWWWWWWWWS...",
        "..WWRRRWWWWWWWWRRRSW..",
        ".WWWWWWWWWWWWWWWWWWSW.",
        ".WWWWWWWWWWWWWWWWWWSW.",
        "WWGGgGGGGGGGGGGGGGGGWW",
        "WW..................SW",
        "WW..................SW",
        "W....................W",
    ], ["W": white, "R": C(0xD84A2A), "G": C(0x5A5A64), "g": C(0x9AA0AE), "l": C(0xFFFFFF), "S": strap])
    // The flight suit, folds shaded down the side and under the harness.
    c.rect(18, 33, 20, 5, suit)
    c.rect(37, 33, 1, 5, suitShade); c.px(24, 36, suitShade); c.px(31, 36, suitShade)
    c.rect(18, 37, 20, 1, suitShade)
    // The white flak vest's harness, its buckles where the straps cross.
    c.rect(21, 33, 2, 5, white); c.rect(33, 33, 2, 5, white)    // harness
    c.rect(18, 35, 20, 1, white)
    c.rect(22, 33, 1, 5, strap); c.rect(34, 33, 1, 5, strap)
    c.rect(21, 35, 2, 1, C(0x9AA0AE)); c.rect(33, 35, 2, 1, C(0x9AA0AE))
    // The chest box, its switches lit.
    c.rect(25, 33, 6, 2, C(0x6A6E78))
    c.rect(25, 34, 6, 1, C(0x4E525C))
    c.px(26, 33, C(0xD84A2A)); c.px(28, 33, C(0x3A7BEA)); c.px(29, 33, C(0x9AA0AE))
    heroPistol(c, p)
}

/// L3-37: Lando's self-made droid, patched together from parts, fist up for droid rights.
private func drawL337(_ c: PixelCanvas, _ p: Pose) {
    let tan = C(0xCBB89A), tanDark = C(0x9E8C70), grey = C(0x5A5C64)
    let protest = !p.walking && Int(p.t * 0.8) % 2 == 0
    let look = Look(body: tan, shade: tanDark, leg: grey, arm: grey, eye: nil)
    heroLegs(c, p, look)
    drawBody(c, look, armRight: protest ? 6 : 0)
    c.rect(18, 30, 20, 1, tanDark)
    c.rect(20, 32, 5, 4, C(0xB06A3A))           // a rusty patch
    c.rect(30, 33, 4, 3, C(0x7A7E88))
    c.rect(24, 24, 2, 2, grey); c.rect(30, 24, 2, 2, grey)     // neck struts
    c.pattern(21, 16, [
        "...TTTTTTTT...",
        ".TTTTTTTTTTTT.",
        "TTTTTTTTTTTTTT",
        "TTTTTTTTTBBBTT",
        "TTTTTTTTBbbbBT",
        "TTTTTTTTBbbbBT",
        "TTTTTTTTTBBBTT",
        ".TTTTTTTTTTTT.",
    ], ["T": C(0xE8DCC4), "B": C(0x3A3A44), "b": C(0x6FC8FF)])
}

/// Mon Mothma: white robes to the floor, short auburn hair, a silver medallion.
private func drawMonMothma(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0xF0EEE6), robeShade = C(0xD2D0C8), fold = C(0xE2E0D8), silver = C(0xC8CCD4)
    // Pale slippers: only their toes peep out under the robe's hem, one pair lifting as she walks.
    drawLegs(c, Look(leg: C(0xDCDAD2)), step: p.step)
    drawBoots(c, C(0xB8B6AE), step: p.step, rows: 1)
    c.oy += p.breathe
    // The robe, to the floor: long folds falling its length, a shadow either side of each leg as the cloth falls
    // over it, and a hem shaded underneath.
    for y in 38...42 {
        let k = (y - 38) / 2
        c.rect(18 - k, y, 20 + k * 2, 1, robe)
        c.px(18 - k, y, robeShade); c.px(37 + k, y, robeShade)
    }
    for x in [22, 27, 32] { c.rect(x, 38, 1, 4, fold) }
    for x in [21, 25, 30, 34] { c.rect(x, 40, 1, 2, robeShade) }
    c.rect(16, 42, 24, 1, robeShade)
    var look = Look(arm: robe)
    look.legs = false
    drawBody(c, look)
    c.rect(15, 35, 3, 1, robeShade); c.rect(38, 35, 3, 1, robeShade)   // the wide sleeves' folds
    c.pattern(18, 22, [
        "...HHHHHHHHHHHHHH...",
        ".HHHHlHHHHHHHlHHHHH.",
        "HHHHHHHHHHHHHHHHHHHH",
        "HHH..............HHH",
        "HH................HH",
    ], ["H": C(0x9A5A30), "l": C(0xC07A44)])
    // The cowl-necked robe: the collar draped round the neck, a fold down each side.
    c.rect(18, 33, 20, 5, robe)
    c.rect(37, 33, 1, 5, robeShade)
    c.rect(19, 33, 18, 1, fold); c.px(18, 33, robeShade)
    c.rect(20, 35, 1, 3, fold); c.rect(35, 35, 1, 3, fold)
    // The silver medallion on its chain, a glint in the corner.
    c.px(24, 33, C(0x9EA4AE)); c.px(31, 33, C(0x9EA4AE)); c.px(25, 34, C(0x9EA4AE)); c.px(30, 34, C(0x9EA4AE))
    c.rect(26, 34, 4, 2, silver)
    c.rect(26, 35, 4, 1, C(0x9EA4AE)); c.px(26, 34, C(0xF2F4F8))
}

/// Padmé Amidala, as at Geonosis: white suit, dark hair in a bun, a pistol.
private func drawPadme(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0xF2F0EA), suitShade = C(0xD4D2CC), hair = C(0x4A2A1A), hairHi = C(0x6A4028)
    let look = Look(leg: suit, arm: suit)
    let grounded = p.cheering && !p.walking
    if grounded { c.oy -= p.hop }
    drawLegs(c, look, step: p.step)
    drawBoots(c, C(0xC4C0B6), step: p.step, rows: 2)   // pale boots
    if grounded { c.oy += p.hop }
    c.oy += p.breathe
    drawBody(c, look)
    c.rect(15, 35, 3, 1, suitShade); c.rect(38, 35, 3, 1, suitShade)   // the sleeves' cuffs
    c.pattern(18, 22, ["...HHHHHlHHHHHH...", ".HHHHHHHHHHHlHHHH.", "HHHlHHHHHHHHHHHHHH", "HH..............HH"],
              ["H": hair, "l": hairHi])
    // The bun at the back, a band wound round it.
    c.pattern(13, 22, [".HlH.", "HlHHH", "bbbbb", ".HHH."], ["H": hair, "l": hairHi, "b": C(0x2E1A10)])
    // The suit: a round neck, folds shaded at the sides.
    c.rect(18, 33, 20, 5, suit)
    c.rect(25, 33, 6, 1, C(0xE2E0D8))
    c.rect(37, 33, 1, 5, suitShade)
    c.px(21, 34, suitShade); c.px(33, 34, suitShade); c.px(22, 37, suitShade); c.px(32, 37, suitShade)
    // The belt, its clasp, and the holster on her hip.
    c.rect(18, 36, 20, 1, C(0x6A5A4A))
    c.rect(27, 36, 2, 1, C(0xB8BCC4))
    c.rect(34, 36, 2, 2, C(0x4A3A2E))
    heroPistol(c, p)
}

/// Admiral Ackbar: a Mon Calamari, salmon dome and big side eyes, in his white admiral's uniform.
private func drawAckbar(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xC9724A), shade = C(0xA0583A), uniform = C(0xEDECE6)
    let look = Look(body: skin, shade: shade, leg: C(0xD8D6CE), arm: uniform, eye: nil)
    heroLegs(c, p, look, boots: C(0xB8B6AE))                        // pale grey boots
    drawBody(c, look)
    c.rect(15, 35, 3, 1, C(0xC8C6BE)); c.rect(38, 35, 3, 1, C(0xC8C6BE))   // the sleeves' cuffs
    // The dome: the light running back over it, mottled in short darker strokes, shaded down the far side.
    c.pattern(17, 17, [
        ".......SSSllSSS.......",
        ".....SSSlllSSSSSS.....",
        "....SSllSSSSSSSmmS....",
        "...SSlSsSSSSSSSSSSd...",
        "...SSSSSSSSmmSSSSSd...",
        "..SSmmSSSSSSSSSSSSSd..",
        "..SSSSSSSSSSSSmmSSSd..",
        ".SSSSSSmmSSSSSSSSSSdd.",
        ".SSSSSSSSSSSSSSSSSSdd.",
    ], ["S": skin, "s": C(0xE0946A), "l": C(0xE0946A), "d": shade, "m": C(0xB4623F)])
    let look2 = sin(p.t * 1.3) > 0.7 ? 1 : 2                   // the eyes swivel
    for ex in [15, 36] {
        // The big side eyes: lit along the top, shaded underneath, a glint by the pupil.
        c.pattern(ex, 25, [".lll.", "EEEEE", "EEEEE", "EEEEE", ".eee."], ["E": C(0xE0962E), "l": C(0xF0B45A), "e": C(0xB8742A)])
        c.px(ex + look2 + 1, 27, C(0x2A1A10))
    }
    // The whiskers hanging from his chin, in short tendrils.
    c.rect(24, 31, 8, 1, shade)
    c.px(24, 32, shade); c.px(27, 32, shade); c.px(31, 32, shade)
    // The admiral's uniform: the high collar, the vest's edges, folds shaded down the side, a belt and buckle,
    // and the rank plaque in its silver rim.
    c.rect(18, 33, 20, 5, uniform)
    c.rect(18, 33, 20, 1, C(0xC8C6BE))
    c.rect(26, 34, 1, 3, C(0xD8D6CE)); c.rect(37, 33, 1, 5, C(0xD8D6CE)); c.px(33, 35, C(0xD8D6CE))
    c.rect(20, 34, 5, 1, C(0x9EA4AE))
    c.px(21, 35, C(0xD84A2A)); c.px(22, 35, C(0x3A6ED8)); c.px(23, 35, C(0xE0B84A))
    c.rect(18, 37, 20, 1, C(0xB8B6AE)); c.rect(27, 37, 2, 1, C(0xC8CCD4)); c.px(27, 37, C(0xF2F4F8))
}
