import Foundation

// Villains: the agent-only small fry. A fledgling vampire fresh out of the grave and one of Glory's minions are Clawd
// in costume like the rest of the cast; Gachnar and Amy the rat are drawn the way Stevie Clawdberg draws its small
// creatures: Clawd in a creature suit, his own orange face in the middle of it, still on his four legs.

let slayerVillains9: [SlayerVillain: Persona] = [
    .fledgling: Persona(name: "A fledgling vampire", weapon: .saber, headTop: 19, draw: drawFledgling),
    .gloryMinion: Persona(name: "One of Glory's minions", headTop: 18, draw: drawGloryMinion),
    .gachnar: Persona(name: "Gachnar", weapon: .saber, headTop: 18, callout: "Fear me!", draw: drawGachnar),
    .amyTheRat: Persona(name: "Amy the rat", headTop: 20, draw: drawAmyTheRat),
]

// MARK: - Shared bits

/// A vampire's game face over Clawd's own: ridged brow, yellow eyes and a pair of fangs.
private func gameFace(_ c: PixelCanvas, ridge: Px = C(0x9A4A30)) {
    c.pattern(21, 27, ["RRRR......RRRR", ".RR........RR."], ["R": ridge])
    c.rect(22, 29, 2, 2, C(0xF2D040)); c.px(23, 30, ink); c.rect(32, 29, 2, 2, C(0xF2D040)); c.px(32, 30, ink)
    c.pattern(26, 30, ["R..R", ".RR."], ["R": ridge])
    c.rect(25, 32, 6, 1, C(0x5A2418)); c.px(26, 33, white); c.px(29, 33, white)
}

/// A strike swung round behind him (a flourish passing overhead and back): drawn before the body so it passes behind
/// his head instead of across his face.
private func behind(_ p: Pose) -> Bool {
    guard let a = p.melee else { return false }
    return cos(a * .pi / 180) < -0.25
}

// MARK: - A fledgling vampire

/// A fledgling vampire, just clawed his way up out of his grave: Clawd in a rumpled navy funeral suit caked with earth,
/// the white shirt half untucked, the black tie crooked, dark hair sticking up every which way with dirt in it, and
/// his game face on for good. He fights with his fists and nails.
private func drawFledgling(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x3E4660), suitD = C(0x2A3046), suitL = C(0x58628A), shirt = C(0xDAD6CA), tie = C(0x16161B)
    let dirt = C(0x7A6446), dirtD = C(0x5A4830)
    let hair = C(0x3A2A20), hairL = C(0x5A4232)

    drawLegs(c, Look(leg: C(0x5A6280)), step: p.step)
    if !seatedPose { c.px(19, 40, dirt); c.px(24, 38, dirt); c.px(31, 41, dirtD); c.px(36, 39, dirt) }
    slayerBoots(c, step: p.step, C(0x18181C), height: 1)
    c.oy += p.breathe
    let nail = C(0xE4DCC4)
    if behind(p), let a = p.melee { slayerClaws(c, angle: a, trail: p.trail, sleeve: suit, nail: nail) }
    drawBody(c, Look(arm: suit, eye: nil))
    // The suit jacket, open and rumpled, one side of the shirt hanging out, the tie askew.
    c.rect(18, 33, 20, 5, suit); c.rect(24, 33, 7, 5, shirt); c.rect(29, 37, 3, 2, shirt)
    c.rect(23, 33, 1, 5, suitL); c.rect(31, 33, 1, 5, suitD); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(26, 33, ["TT.", ".T.", ".TT", "..T"], ["T": tie])
    // Earth caked on him: on his shoulders and down the jacket.
    for (x, y) in [(18, 33), (19, 34), (35, 33), (36, 34), (21, 36), (34, 36), (20, 33)] { c.px(x, y, dirt) }
    c.px(33, 35, dirtD); c.px(19, 36, dirtD)
    // Hair sticking up every which way, clods of earth in it.
    c.pattern(16, 19, [
        "......H...H.....H.......",
        ".......H.HH...H.H..H....",
        ".....HHHHHHHHHHHHHHH....",
        "...HHHHlHHHHHlHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHH.H..........H.HHH..",
        "..H..................H..",
    ], ["H": hair, "l": hairL])
    c.px(22, 22, dirt); c.px(29, 21, dirt); c.px(33, 23, dirtD); c.px(19, 24, dirt)
    gameFace(c)

    if let a = p.melee {
        guard !behind(p) else { return }
        slayerClaws(c, angle: a, trail: p.trail, sleeve: suit, nail: nail)
    } else {
        // Hands hanging, the nails long.
        c.px(41, 36, nail); c.px(41, 34, nail)
    }
}

// MARK: - One of Glory's minions

/// One of Glory's minions: a scabby little demon in a ragged brown monk's robe, the hood up and pointed, a rope belt,
/// his face crusted with scabs, wearing a grovelling, toothy grin, his scaly grey-green hands wringing in front of
/// him. The robe hangs to his knees and his four scaly legs show below it. Every few seconds he bows and scrapes. He
/// doesn't fight: he'd only get blamed for it.
private func drawGloryMinion(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0x7A5A3C), robeD = C(0x553E28), robeL = C(0x9A7854), rope = C(0xCCAE70)
    let skin = C(0x7E8E6A), skinD = C(0x5E6E4E), scab = C(0xA05A3C), scabD = C(0x6E3424)
    // The bow: a little dip and lean forward every few seconds.
    let b = frac(p.lt / 3.4)
    let bowing = !p.walking && !p.seated && b > 0.7 && b < 0.92
    let dip = bowing ? 1 : 0

    drawLegs(c, Look(leg: skin), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.px(lx + 1, 42, skinD) } }
    c.oy += p.breathe + dip
    c.ox += dip
    drawBody(c, Look(arm: robe, eye: nil))
    // The robe to his knees, hanging in folds over the tops of his legs, a rope belt.
    c.rect(18, 33, 20, 5, robe); c.rect(37, 33, 1, 5, robeD)
    c.rect(17, 38, 22, seatedPose ? 1 : 2, robe)
    if !seatedPose {
        for x in stride(from: 18, through: 37, by: 4) { c.rect(x, 38, 1, 2, robeD) }
        c.rect(17, 38, 1, 2, robeL)
    }
    c.rect(18, 35, 20, 1, rope); c.rect(21, 36, 1, 2, rope)
    // The pointed hood.
    c.pattern(15, 18, [
        "............BB............",
        "..........BBBBB...........",
        "........BBBBlBBBB.........",
        "......BBBBBBBBBBBBB.......",
        "....BBBBlBBBBBBBBBBBB.....",
        "...BBBBBBBBBBBBBBBBBBBd...",
        "..BBBBBBBBBBBBBBBBBBBBBd..",
        "..BBBBBBBBBBBBBBBBBBBBBd..",
        ".BBBB................BBd..",
        ".BBB..................Bd..",
        ".BBB..................Bd..",
        "BBBB..................BBd.",
        "BBB....................Bd.",
        "BBB....................Bd.",
        ".BB....................B..",
    ], ["B": robe, "l": robeL, "d": robeD])
    // Scabs crusted over his face, small eager eyes, and the grovelling grin.
    for (x, y, k) in [(20, 27, 0), (21, 27, 1), (34, 27, 0), (20, 31, 1), (35, 31, 0), (34, 32, 1), (27, 27, 0)] {
        c.px(x, y, k == 0 ? scab : scabD)
    }
    c.rect(22, 29, 2, 2, ink); c.rect(32, 29, 2, 2, ink)
    c.rect(23, 32, 10, 1, C(0x4A1E16))
    for x in stride(from: 24, through: 31, by: 2) { c.px(x, 32, C(0xF0E8C8)) }
    // Scaly hands, wringing.
    let wring = Int(p.lt * 4) % 2
    c.rect(37, 33, 3, 3, robe)
    c.rect(38 + wring, 34, 2, 2, skin); c.rect(40 - wring, 35, 2, 1, skinD)
}

// MARK: - Gachnar

/// Gachnar, the fear demon, who turns out to be about a foot tall: a small Clawd in a brick-red demon suit, two horns
/// curling up off his head, a crest of black spikes down his back, a pale belly, a little barbed tail, and a huge
/// toothy grin under Clawd's orange face, scowling under angry brows. He fights with his little claws ("Fear me!").
private func drawGachnar(_ c: PixelCanvas, _ p: Pose) {
    let hide = C(0x9A3E2C), hideD = C(0x6A2618), hideL = C(0xC0583E), belly = C(0xD49A62)
    let horn = C(0xE4D6B4), hornD = C(0xA89878), spike = C(0x3A1610)

    drawLegs(c, Look(leg: hide), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.px(lx + 2, lifted ? 42 : 43, horn)   // a claw on each foot
        }
    }
    c.oy += p.breathe
    // The barbed tail, flicking behind.
    let flick = Int(p.lt * 2.5) % 2
    c.pattern(9, 33 + flick, ["S.......", "SSS.....", ".SHHHHHH", "S..HHHHH"].map { String($0) },
              ["S": spike, "H": hide])
    if behind(p), let a = p.melee { slayerClaws(c, angle: a, trail: p.trail, sleeve: hide, nail: horn, reach: 6) }
    drawBody(c, Look(body: hide, shade: hideD, arm: hide, eye: nil))
    c.rect(22, 34, 12, 3, belly); c.rect(22, 36, 12, 1, C(0xB07A48))
    // The crest of black spikes from his brow back over his head and down his back.
    c.pattern(23, 22, ["S...S...S", "SS.SS.SSS"], ["S": spike])
    c.pattern(14, 25, ["..SS", "SSSS", "..SS", "...S", "..SS", "SSSS", "..SS", "...S", "..SS", "SSSS", "..SS"],
              ["S": spike])
    c.rect(17, 24, 1, 9, hideD)
    // The horns, curling up and out.
    c.pattern(16, 17, [
        "hH..................h.",
        "hH...................H",
        ".hH.................HH",
        "..HH...............HH.",
        "...HH.............HH..",
        "....HH...........HH...",
        "......HH.......HH.....",
    ].map { String($0) }, ["H": horn, "h": hornD])
    c.rect(19, 23, 18, 3, hide); c.rect(19, 23, 18, 1, hideL)
    // Clawd's face, scowling, and the huge grin of needle teeth under it.
    c.rect(20, 27, 16, 5, clawdOrange)
    c.rect(22, 29, 2, 2, ink); c.rect(32, 29, 2, 2, ink)
    c.pattern(21, 27, ["KK.........KK.", "..K.......K..."].map { String($0) }, ["K": ink])
    c.rect(20, 32, 16, 2, C(0x3A0E0A))
    c.pattern(20, 32, ["W.W.W.W.W.W.W.W.", ".W.W.W.W.W.W.W.W"], ["W": C(0xF4F0DC)])

    if let a = p.melee {
        guard !behind(p) else { return }
        slayerClaws(c, angle: a, trail: p.trail, sleeve: hide, nail: horn, reach: 6)
    } else {
        c.px(41, 33, horn); c.px(41, 35, horn)   // claws
    }
}

// MARK: - Amy the rat

/// Amy the rat: the witch Amy Madison, who turned herself into a rat and spent three years in a cage in Willow's room.
/// A small Clawd in a white rat suit: round pink-lined ears on top, a pointed snout jutting out with a pink nose and
/// whiskers, pink feet, and a long bare pink tail curling along the ground behind. Clawd's orange face in the middle,
/// with beady eyes. Now and then her nose twitches. She doesn't fight.
private func drawAmyTheRat(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0xECE6DA), furD = C(0xC4BCAE), furL = C(0xFFFCF4), pink = C(0xF0A2AE), pinkD = C(0xCC7888)
    let twitch = !p.walking && Int(p.lt * 6) % 7 == 0 ? 1 : 0

    drawLegs(c, Look(leg: fur), step: p.step)
    slayerBoots(c, step: p.step, pink, height: 1)
    // The long bare tail, curving back along the ground and up at the tip.
    slayerLine(c, 17.5, 36.5, 12.5, 40.5, pink, 0.8)
    slayerLine(c, 12.5, 40.5, 6.5, 41.5, pink, 0.6)
    slayerLine(c, 6.5, 41.5, 3.5, 38.5, pinkD, 0.5)
    c.oy += p.breathe
    drawBody(c, Look(body: fur, shade: furD, arm: fur, eye: nil))
    c.rect(18, 26, 20, 1, furL); c.rect(18, 26, 1, 10, furL)
    // Round ears, pink inside.
    c.pattern(17, 20, [".FFFF.", "FPPPPF", "FPPPPF", "FPPPPF", ".FPPF.", "..FF.."], ["F": fur, "P": pink])
    c.pattern(31, 20, [".FFFF.", "FPPPPF", "FPPPPF", "FPPPPF", ".FPPF.", "..FF.."], ["F": fur, "P": pink])
    // Clawd's face, with beady eyes.
    c.rect(20, 28, 15, 5, clawdOrange)
    c.rect(22, 29, 2, 2, ink); c.rect(31, 29, 2, 2, ink); c.px(22, 29, white); c.px(31, 29, white)
    // The snout jutting out to the right, the pink nose on the end, whiskers either side of it.
    c.pattern(35, 29, ["FFF...", "FFFFF.", "FFFFFN", "ddd..."].map { String($0) },
              ["F": fur, "N": pink, "d": furD])
    c.px(41, 30 - twitch, pink); c.px(40 + twitch, 31, pink)
    c.rect(37, 28 - twitch, 4, 1, furD); c.rect(38, 33 + twitch, 4, 1, furD)
    c.rect(22, 34, 12, 3, furL)
}
