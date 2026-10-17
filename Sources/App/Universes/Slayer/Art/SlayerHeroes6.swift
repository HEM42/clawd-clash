import Foundation

// Heroes: the last of Angel Investigations and Miss Kitty Fanclawstico. Clawd in costume like the rest of the cast:
// hair, hoods, suits and armour drawn over the blocky body, with Clawd's own orange face showing. Miss Kitty is an
// agent-only pet, drawn the way Stevie Clawdberg draws its small creatures: Clawd in a kitten suit, his face in the
// middle of it, still on his four legs.

let slayerHeroes6: [SlayerHero: Persona] = [
    .conner: Persona(name: "Conner", weapon: .saber, headTop: 19, signature: 3.0, draw: drawConner),
    .kateLockclaw: Persona(name: "Kate Lockclaw", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 20,
                           signature: 3.0, draw: drawKateLockclaw),
    .groosalug: Persona(name: "The Groosalug", weapon: .saber, headTop: 19, signature: 3.2, callout: "Princess!",
                        draw: drawGroosalug),
    .drogynn: Persona(name: "Drogynn", weapon: .saber, headTop: 20, draw: drawDrogynn),
    .missKitty: Persona(name: "Miss Kitty Fanclawstico", headTop: 21, signature: 3.6, draw: drawMissKitty),
]

// MARK: - Shared bits

/// 0…1 through the middle stretch of a signature move (`from`…`to` of it), or -1 outside it.
private func span(_ p: Pose, _ from: Double, _ to: Double) -> Double {
    guard let s = p.signature, s > from, s < to else { return -1 }
    return (s - from) / (to - from)
}

/// A melee weapon swung round behind him (a flourish passing overhead and back): drawn before the body so it passes
/// behind his head instead of across his face.
private func behind(_ p: Pose) -> Bool {
    guard let a = p.melee else { return false }
    return cos(a * .pi / 180) < -0.25
}

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// A sword along `angle` from the hand `h`: a dark edge round a bright blade, a crossguard and a grip, a smear where a
/// fast swing just was, and the fist round the grip.
private func sword(_ c: PixelCanvas, _ h: (x: Double, y: Double), angle a: Double, trail: [Double], length: Double,
                   wide: Double, edge: Px, blade: Px, guardCol: Px, grip: Px, pommel: Px, guardW: Double = 2.6) {
    slayerSmear(c, h, trail, from: 4, to: length, C(0xE4ECF8))
    slayerBar(c, h, a, from: -2.2, to: 1.5, grip, r: 0.9)
    let pm = slayerReach(h, a, -2.6)
    c.px(Int(pm.x.rounded()), Int(pm.y.rounded()), pommel)
    slayerBar(c, h, a, from: 3, to: length, edge, r: wide + 0.4)
    slayerBar(c, h, a, from: 3, to: length - 0.5, blade, r: wide)
    let g = slayerReach(h, a, 2.2)
    let g0 = slayerReach(g, a - 90, guardW), g1 = slayerReach(g, a + 90, guardW)
    slayerLine(c, g0.x, g0.y, g1.x, g1.y, guardCol, 0.65)
    c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, clawdOrange)
}

// MARK: - Conner

/// Conner: Angel's son, raised in a hell dimension, a teenager who never takes his hood down. Clawd in a dark olive
/// hoodie with the hood up, a fringe of brown hair under its edge, drawstrings and a pouch pocket, faded jeans and
/// trainers. He fights with a stake. Signature: he springs straight up, legs tucked, and lands low in a crouch, the
/// stake up and ready, then straightens.
private func drawConner(_ c: PixelCanvas, _ p: Pose) {
    let hood = C(0x4C5646), hoodD = C(0x343B30), hoodL = C(0x6A7662), cord = C(0xA8A898)
    let hair = C(0x5E3E26), hairL = C(0x7E5636)
    let jeans = C(0x5878A6), shoe = C(0xD6D6DA)
    // The leap: how far up he is, and how deep he crouches before and after.
    var lift = 0, crouch = 0
    if let s = p.signature {
        if s > 0.06 && s < 0.18 { crouch = Int((ramp(s, 0.06, 0.12) * 2).rounded()) }
        else if s >= 0.18 && s < 0.5 { lift = Int((sin((s - 0.18) / 0.32 * .pi) * 8).rounded()) }
        else if s >= 0.5 && s < 0.8 { crouch = 3 }
        else if s >= 0.8 && s < 0.92 { crouch = Int(((1 - ramp(s, 0.8, 0.9)) * 3).rounded()) }
    }
    let leaping = lift > 0

    if crouch > 0 || leaping {
        // Legs bent under him: shorter, and drawn in place of drawLegs.
        c.oy -= lift
        for lx in [19, 23, 31, 35] {
            let top = leaping ? 36 : 36 + crouch
            let len = leaping ? 5 : 8 - crouch
            c.rect(lx, top, 2, len, jeans); c.rect(lx, top + len - 1, 2, 1, shoe)
        }
        c.oy += crouch
    } else {
        drawLegs(c, Look(leg: jeans), step: p.step)
        slayerBoots(c, step: p.step, shoe, height: 1)
        c.oy += p.breathe
    }
    let stake = {
        if let a = p.melee { slayerStake(c, angle: a, trail: p.trail) } else { slayerStakeHeld(c) }
    }
    if behind(p) { stake() }
    drawBody(c, Look(arm: hood))
    // The hoodie: a pouch pocket across the front, the drawstrings hanging from the neck.
    c.rect(18, 33, 20, 5, hood); c.rect(37, 33, 1, 5, hoodD); c.rect(18, 37, 20, 1, hoodD)
    c.rect(22, 35, 12, 2, hoodD); c.rect(22, 35, 12, 1, hoodL)
    c.rect(25, 33, 1, 3, cord); c.rect(30, 33, 1, 3, cord); c.px(25, 35, hoodD); c.px(30, 35, hoodD)
    // The hood up over his head, a ragged brown fringe under its rim.
    c.pattern(15, 19, [
        ".......BBBBBBBBBBBB.......",
        ".....BBBBBBBBBBBBBBBB.....",
        "....BBBlBBBBBBBBBBBBBB....",
        "...BBBlBBBBBBBBBBBBBBBB...",
        "...BBBBBBBBBBBBBBBBBBBBd..",
        "..BBBBhHHHHhHHHHHhHHBBBd..",
        "..BBBH.H.HH.HHHH.H.HBBBd..",
        ".BBBB.....H.........BBBd..",
        ".BBB.................BBd..",
        ".BBB.................BBd..",
        "BBBB.................BBBd.",
        "BBB...................BBd.",
        "BBB...................BBd.",
        ".BB...................Bd..",
    ], ["B": hood, "l": hoodL, "d": hoodD, "H": hair, "h": hairL])

    if crouch == 3 {
        // Landed low, the stake up and ready.
        slayerStake(c, angle: -35, trail: [])
        return
    }
    if !behind(p) { stake() }
}

// MARK: - Kate Lockclaw

/// Kate Lockclaw: the LAPD detective. Clawd with straight blonde hair to her shoulders, swept to one side, a charcoal
/// trouser suit over a white blouse, her gold badge clipped to her belt, and her service pistol in her hand. She fights
/// with the pistol. Signature: she holsters the pistol, unclips the badge and holds it up for you to see.
private func drawKateLockclaw(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x3E4454), suitD = C(0x2A2E3A), suitL = C(0x5C6476), blouse = C(0xEEEEF2), blouseD = C(0xC8CAD2)
    let hair = C(0xE0BE74), hairL = C(0xF4DCA2), hairD = C(0xB4924E)
    let gold = C(0xE8BE40), goldD = C(0xA8822A), wallet = C(0x221E1E)
    let badgeK = span(p, 0.08, 0.92)
    let show = badgeK >= 0 ? min(1, badgeK * 5) * min(1, (1 - badgeK) * 5) : 0
    let raise = Int((show * 4).rounded())

    drawLegs(c, Look(leg: C(0x666E80)), step: p.step)
    slayerBoots(c, step: p.step, C(0x18181C), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit), armRight: raise)
    // The jacket, open over the white blouse, its lapels in a V.
    c.rect(18, 33, 20, 5, suit); c.rect(25, 33, 6, 5, blouse); c.rect(25, 37, 6, 1, blouseD)
    c.rect(24, 33, 1, 4, suitL); c.rect(31, 33, 1, 4, suitD); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.px(25, 35, suitL); c.px(30, 35, suitD)
    c.rect(18, 36, 7, 1, C(0x1E1E24))   // the belt at her hip
    // Straight blonde hair to the shoulders, a side-swept fringe, a few strands loose.
    c.pattern(16, 20, [
        "...........H............",
        ".....HHHHHHHHHHHHH......",
        "...HHHHHlHHHHHHHHHHH....",
        "..HHHHHHHHHHlHHHHHHHH...",
        ".HHHHHHHHHHHHHHHHHHHHH..",
        ".HHHHHHlHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHH......HHHHHH.",
        ".HHHHH.............HHHH.",
        ".HHH................HHH.",
        ".HHl................HHH.",
        ".HHH................lHH.",
        ".HHH................HHH.",
        "HHHd................dHHH",
        ".H.d................d.H.",
    ], ["H": hair, "l": hairL, "d": hairD])

    if badgeK >= 0 {
        // The pistol in its holster on her hip.
        c.rect(19, 35, 3, 3, C(0x3A2416)); c.rect(19, 34, 3, 1, C(0x2A2A30)); c.px(20, 34, C(0x8A8F9C))
        // The badge in its black wallet, held up and out, its gold shield catching the light.
        let x = 39 + Int((show * 1).rounded()), y = 30 - raise - 2
        c.rect(38, 33 - raise, 3, 3, suit)
        c.pattern(x, y, ["KKKKK", "KGGGK", "KGgGK", "KdGdK", "KKKKK"], ["K": wallet, "G": gold, "g": white, "d": goldD])
        c.rect(38, y + 3, 2, 2, clawdOrange)
        return
    }
    // The badge clipped to her belt.
    c.rect(20, 35, 2, 2, gold); c.px(21, 36, goldD)
    c.oy += p.gunY
    c.rect(38, 33, 3, 3, suit)
    drawPistol(c, x: 40, y: 31)
}

// MARK: - The Groosalug

/// The Groosalug: Pylea's champion. Clawd with long wavy light-brown hair down past his shoulders, bronze Pylean
/// armour with a ridged breastplate and round pauldrons, leather sleeves and breeches, and a great broadsword with a
/// bronze guard. He fights with the sword, and rests with its tip on the ground. Signature: a heroic stance, the sword
/// thrust straight up over his head, a glint running up the blade ("Princess!").
private func drawGroosalug(_ c: PixelCanvas, _ p: Pose) {
    let bronze = C(0xB8863A), bronzeD = C(0x87601F), bronzeL = C(0xE2B462), leather = C(0x6A4A2C), leatherD = C(0x4A321C)
    let hair = C(0xA6784A), hairL = C(0xC89C66), hairD = C(0x7A5432)
    let edge = C(0x7E8898), blade = C(0xDCE2EC)
    let heroK = span(p, 0.06, 0.94)
    let up = heroK >= 0 ? min(1, heroK * 5) * min(1, (1 - heroK) * 5) : 0
    let raise = Int((up * 6).rounded())

    drawLegs(c, Look(leg: C(0x8A6844)), step: p.step)
    slayerBoots(c, step: p.step, C(0x3E2A1A), height: 3)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.px(lx, 39, bronze) } }   // bronze knee guards
    c.oy += p.breathe
    let guardCol = C(0xC89040), grip = C(0x3A2416), pommel = C(0xE2B462)
    let blade0 = {
        sword(c, slayerHand, angle: p.melee ?? 64, trail: p.trail, length: p.melee == nil ? 11 : 14, wide: 0.9,
              edge: edge, blade: blade, guardCol: guardCol, grip: grip, pommel: pommel, guardW: 3)
    }
    if behind(p) && heroK < 0 { blade0() }
    drawBody(c, Look(arm: leather), armRight: raise)
    // The breastplate: bronze, ridged across, a leather skirt of straps at the waist.
    c.rect(18, 33, 20, 5, bronze); c.rect(18, 33, 20, 1, bronzeL); c.rect(18, 35, 20, 1, bronzeD)
    c.rect(37, 33, 1, 4, bronzeD); c.rect(27, 33, 2, 3, bronzeL)
    for x in stride(from: 18, through: 36, by: 3) { c.rect(x, 37, 2, 1, leather) }
    c.rect(18, 36, 20, 1, leatherD)
    // Round pauldrons on both shoulders.
    c.pattern(15, 31, [".LLL", "LBBB", "BBBd"], ["L": bronzeL, "B": bronze, "d": bronzeD])
    c.pattern(37, 31, ["LLL.", "BBBB", "BBBd"].map { String($0) }, ["L": bronzeL, "B": bronze, "d": bronzeD])
    // Long wavy hair, swept back off his face, falling past his shoulders behind, strands loose.
    c.pattern(15, 19, [
        "...........H..H...........",
        ".......HHHHHHHHHHHH.......",
        ".....HHHHlHHHHHHHlHHH.....",
        "...HHHHHHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHlHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHH...............HHHH..",
        ".HHH.................HHH..",
        "HHHl.................lHHH.",
        ".HHH..................HH..",
        "HHHd..................dH..",
        ".HHd......................",
        "HH.d......................",
        ".d........................",
    ], ["H": hair, "l": hairL, "d": hairD])

    if heroK >= 0 {
        // Sword straight up over his head, and a glint running up the blade.
        let h = (x: slayerHand.x, y: slayerHand.y - Double(raise))
        let a = -90 + (1 - up) * 150
        sword(c, h, angle: a, trail: [], length: 14, wide: 0.9, edge: edge, blade: blade, guardCol: guardCol,
              grip: grip, pommel: pommel, guardW: 3)
        if up > 0.99 {
            let gk = ramp(heroK, 0.3, 0.7)
            if gk > 0 && gk < 1 {
                let gy = Int((h.y - 4 - gk * 9).rounded()), gx = Int(h.x.rounded())
                c.px(gx, gy, white); c.px(gx - 1, gy, C(0xFFF4C0)); c.px(gx + 1, gy, C(0xFFF4C0))
            }
        }
        return
    }
    // In a fight, swung; at rest, its tip on the ground in front of him.
    if !behind(p) { blade0() }
}

// MARK: - Drogynn

/// Drogynn the Battlebrand: the ageless keeper of the Deeper Well, who cannot tell a lie. Clawd with grey hair swept
/// back to his collar and a short grey beard, worn brown leather armour with a strap across it and studs at the
/// shoulders, and a longsword with a dark iron guard and a red stone in its pommel. He fights with the sword and keeps
/// it upright before him at rest, as a gatekeeper does. No signature: he just stands his watch.
private func drawDrogynn(_ c: PixelCanvas, _ p: Pose) {
    let leather = C(0x5E4028), leatherD = C(0x3E2A18), leatherL = C(0x7E5A3A), stud = C(0xB8B09A)
    let hair = C(0xA6A6AA), hairL = C(0xD2D2D6), hairD = C(0x76767C)

    drawLegs(c, Look(leg: C(0x6E6650)), step: p.step)
    slayerBoots(c, step: p.step, C(0x2A1E16), height: 3)
    c.oy += p.breathe
    // The Battlebrand: swung in a fight, upright before him at rest.
    let brand = {
        sword(c, slayerHand, angle: p.melee ?? -84, trail: p.trail, length: 13, wide: 0.6, edge: C(0x6A7280),
              blade: C(0xC8D0DA), guardCol: C(0x4A4A52), grip: C(0x1E1A18), pommel: C(0xC8282E), guardW: 2.4)
    }
    if behind(p) { brand() }
    drawBody(c, Look(arm: leatherL))
    // Leather armour: a jerkin with a strap from shoulder to hip, studs at the shoulders, a belt.
    c.rect(18, 33, 20, 5, leather); c.rect(37, 33, 1, 5, leatherD); c.rect(18, 37, 20, 1, leatherD)
    for i in 0..<5 { c.rect(20 + i * 3, 33 + i, 3, 1, leatherD) }
    c.rect(18, 36, 20, 1, C(0x2A1C10)); c.px(28, 36, stud)
    for x in [18, 20, 34, 36] { c.px(x, 33, stud) }
    // A short grey beard round his chin, his mouth a line in it.
    c.pattern(21, 31, ["B............B", "BBBBBmmmmBBBBB", ".BBBBBBBBBBBB.", "...BBBBBBBB..."],
              ["B": hair, "m": C(0x8A4A34)])
    c.rect(23, 33, 10, 1, hairD)
    // Grey hair, swept back off the brow and down to the collar, a few strands loose.
    c.pattern(16, 20, [
        "..........H..H..........",
        "......HHHHHHHHHHH.......",
        "....HHHHlHHHHlHHHHH.....",
        "...HHHHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHHlHHHHHHHHHHlHHHHH..",
        ".HHHH..............HHHH.",
        ".HHH................HHH.",
        ".HHH................HHd.",
        ".HHd................Hd..",
        "HHd.................d...",
        ".d......................",
    ], ["H": hair, "l": hairL, "d": hairD])
    // Brows, heavy and grey.
    c.rect(21, 28, 3, 1, hairD); c.rect(32, 28, 3, 1, hairD)

    if !behind(p) { brand() }
}

// MARK: - Miss Kitty Fanclawstico

/// Miss Kitty Fanclawstico: Willow and Tara's grey kitten. A small Clawd in a grey tabby kitten suit, pointed ears
/// with pink insides on top, darker stripes over the head and sides, a pale belly, white paws, whiskers, and a tail
/// held up and swishing behind; Clawd's orange face in the middle with big eyes and a pink nose. She doesn't fight.
/// Signature: a ball of red wool rolls up, she crouches, wiggles, pounces on it, and bats it away again.
private func drawMissKitty(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0x8E9099), furD = C(0x686A74), furL = C(0xB2B4BC), stripe = C(0x5A5C66), belly = C(0xD6D6DC)
    let pink = C(0xF0A0B2), paw = C(0xEEEEF2), whisker = C(0xE2E2E8)
    // The chase: where the ball is, how low she crouches, how far she has pounced.
    var ball: Double? = nil, crouch = 0, pounce = 0.0, hopUp = 0, batting = false
    if let s = p.signature, s > 0.05, s < 0.92 {
        if s < 0.3 { ball = 60 - ramp(s, 0.05, 0.3) * 13 }
        else if s < 0.5 { ball = 47; crouch = 1 }
        else if s < 0.64 {
            ball = 47
            let k = ramp(s, 0.5, 0.64)
            pounce = k * 4; hopUp = Int((sin(k * .pi) * 4).rounded())
        } else if s < 0.84 {
            let k = ramp(s, 0.64, 0.84)
            ball = 47 + k * 13; pounce = 4; batting = k < 0.4
        } else {
            pounce = 4 * (1 - ramp(s, 0.84, 0.92))
        }
    }
    let wiggle = crouch > 0 && Int(p.t * 10) % 2 == 0

    // The ball of wool, rolling along the ground, a loose strand trailing.
    if let bx = ball {
        let x = Int(bx.rounded()), spin = Int(bx) % 2
        c.pattern(x - 2, 39, [".RRR.", "RLRRR", "RRDRR", "RDRRd", ".RRd."],
                  ["R": C(0xD8405E), "L": C(0xF48AA2), "D": C(0xA82A46), "d": C(0x8E2038)])
        c.rect(x + 3, 42 + spin, 2, 1, C(0xD8405E))
    }
    c.ox += Int(pounce.rounded()); c.oy -= hopUp
    drawLegs(c, Look(leg: fur), step: hopUp > 0 ? 0 : p.step)
    slayerBoots(c, step: hopUp > 0 ? 0 : p.step, paw, height: 1)
    c.oy += crouch > 0 ? 1 : p.breathe
    // The tail, held up behind and swishing (quick and low while she wiggles).
    let sway = crouch > 0 ? (wiggle ? 1.0 : -1.0) : sin(p.lt * 2.4) * 1.5
    let tipX = 11 + sway, tipY = crouch > 0 ? 31.0 : 25.0
    slayerLine(c, 17.5, 35.5, 12.5, 33.5, fur, 0.9)
    slayerLine(c, 12.5, 33.5, tipX, tipY, fur, 0.9)
    c.px(Int(tipX.rounded()), Int(tipY.rounded()), stripe); c.px(12, 31, stripe); c.px(13, 34, stripe)
    let reach = batting ? 3 : hopUp > 0 ? 2 : 0
    drawBody(c, Look(body: fur, shade: furD, arm: fur, eye: nil), armRight: reach)
    c.rect(38, 35 - reach, 3, 1, paw)
    // Pointed ears, pink inside, and the top of the head between them.
    c.pattern(18, 21, ["G..................G", "GG................GG", "GPG..............GPG", "GPPG............GPPG",
                       "GGGGGGGGGGGGGGGGGGGG"], ["G": fur, "P": pink])
    // Tabby stripes over the head and down the sides.
    c.pattern(24, 26, ["S.S.S.S", ".S...S."], ["S": stripe])
    for y in [29, 32, 35] { c.rect(18, y, 2, 1, stripe); c.rect(36, y, 1, 1, stripe) }
    // The face: orange, big round eyes with a glint (narrowed while she crouches), a pink nose.
    c.rect(20, 28, 16, 6, clawdOrange)
    if crouch > 0 {
        c.rect(22, 30, 3, 1, ink); c.rect(31, 30, 3, 1, ink)
    } else {
        c.rect(22, 29, 3, 3, ink); c.rect(31, 29, 3, 3, ink); c.px(22, 29, white); c.px(31, 29, white)
    }
    c.rect(27, 32, 2, 1, pink)
    c.rect(22, 34, 12, 3, belly)
    // Whiskers out both sides.
    c.rect(14, 30, 4, 1, whisker); c.rect(15, 32, 3, 1, whisker)
    c.rect(38, 30, 4, 1, whisker); c.rect(38, 32, 3, 1, whisker)
}
