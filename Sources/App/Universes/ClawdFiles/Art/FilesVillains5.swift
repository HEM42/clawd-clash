import Foundation

// Villains: more of the Syndicate and the aliens. Strughold, Follmer, Bill Clawder, the Crew-Cut Man, the Colonist, Duffy
// Haskell and Lord Kinbote. The men of the conspiracy are Clawd in costume, each with a silhouette of his own (a homburg,
// slicked hair, a father's greying fringe, a flat-top and dark glasses); the aliens are Clawd recoloured, or not Clawd at
// all.

let filesVillains5: [FilesVillain: Persona] = [
    .strughold: Persona(name: "Strughold", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                        headTop: 17, signature: 3.2, callout: "Proceed.",
                        draw: drawStrughold),
    .follmer: Persona(name: "A.D. Follmer", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                      headTop: 20, signature: 3.0, callout: "I'll take it from here.",
                      draw: drawFollmer),
    .billClawder: Persona(name: "Bill Clawder", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                          headTop: 20, signature: 3.6, callout: "Forgive me, Fox.",
                          draw: drawBillClawder),
    .crewCutMan: Persona(name: "The Crew-Cut Man", weapon: .blaster, shot: .bullet, muzzle: (51, 32),
                         headTop: 19, signature: 3.2, callout: "Wrong place, wrong time.",
                         draw: drawCrewCutMan),
    .colonist: Persona(name: "The Colonist", motion: .hover, canSit: false, headTop: 19, signature: 3.0,
                       draw: drawColonist),
    .duffyHaskell: Persona(name: "Duffy Haskell", weapon: .saber, armoured: true, headTop: 19, signature: 3.6,
                           callout: "Is that all you've got?",
                           draw: drawDuffyHaskell),
    .lordKinbote: Persona(name: "Lord Kinbote", weapon: .lightning,
                          magic: Magic(core: C(0xFFE8C8), glow: C(0xFF3A2A), jagged: false),
                          pivot: (47, 29), bulk: 2, headTop: 5, signature: 3.0, callout: "I AM LORD KINBOTE!",
                          draw: drawLordKinbote),
]

// MARK: - Shared bits

private let none = C(0, 0)
private let steel = C(0xB4BAC4), steelLight = C(0xEEF2F6), steelDark = C(0x6E7480)

/// A point `d` pixels out from the hand at `angle` degrees.
private func reach(_ angle: Double, _ d: Double) -> (x: Double, y: Double) {
    let r = angle * .pi / 180
    return (Sprite.hand.x + cos(r) * d, Sprite.hand.y + sin(r) * d)
}

/// A punch: the sleeve out from the hand at `angle`, the fist at its end (fainter for a swing's trail).
private func punch(_ c: PixelCanvas, angle: Double, sleeve: Px, alpha: Double = 1) {
    let a = reach(angle, -1.5), b = reach(angle, 3)
    c.glowLine(a.x, a.y, b.x, b.y, core: sleeve.alpha(alpha), glow: none, coreR: 1.4, glowR: 1.5)
    let f = reach(angle, 5)
    c.rect(Int(f.x) - 1, Int(f.y) - 1, 3, 3, clawdOrange.alpha(alpha))
    c.px(Int(f.x) + 1, Int(f.y) + 1, clawdShade.alpha(alpha))
}

/// The fighting arm: a fist thrown at `p.melee` with its trail, or the arm down at rest; and the other arm.
private func fists(_ c: PixelCanvas, _ p: Pose, sleeve: Px) {
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() { punch(c, angle: ta, sleeve: sleeve, alpha: 0.35 / Double(i + 1)) }
        punch(c, angle: a, sleeve: sleeve)
    } else {
        c.rect(38, 33, 3, 3, sleeve); c.rect(38, 35, 3, 1, clawdOrange)
    }
    c.rect(15, 33, 3, 3, sleeve)
}

/// A suit's lower half: jacket, shirt and tie (`tie` nil: an open collar), the jacket's darker edge and hem.
private func suit(_ c: PixelCanvas, _ jacket: Px, _ dark: Px, shirt: Px, tie: Px?) {
    c.rect(18, 34, 20, 4, jacket); c.rect(37, 34, 1, 4, dark); c.rect(18, 37, 20, 1, dark)
    if let tie {
        c.pattern(25, 34, ["lSTTSl", ".lTTl.", "..TT..", "..TT.."], ["l": dark, "S": shirt, "T": tie])
    } else {
        c.pattern(25, 34, ["lSSSSl", ".lSSl.", "..ll.."], ["l": dark, "S": shirt])
    }
}

// MARK: - Strughold

/// Strughold: the old man of the conspiracy, from its German side. Clawd under a black homburg with a grey band, steel-grey
/// hair at the temples and a pinched brow, in a long loden overcoat with a grey astrakhan collar, a pistol in his gloved
/// hand. Signature: the stern stare: his eyes narrow to slits under the brow, then a single curt nod.
private func drawStrughold(_ c: PixelCanvas, _ p: Pose) {
    let loden = C(0x3E4434), lodenD = C(0x2A2E22), lodenL = C(0x565E48), astra = C(0x76767C), astraD = C(0x56565C)
    let hat = C(0x1E1E24), band = C(0x6A6A72), hair = C(0x8E9098)
    let sig = p.signature
    let stare = sig.map { $0 > 0.08 && $0 < 0.7 } ?? false
    let nod = sig.map { $0 >= 0.72 && $0 < 0.86 } ?? false

    // The coat's long skirts over the legs.
    if !seatedPose { c.rect(17, 38, 22, 4, loden); c.rect(17, 41, 22, 1, lodenD); c.rect(28, 38, 1, 4, lodenD) }
    drawLegs(c, Look(leg: C(0x2A2A30)), step: p.step)
    drawDressShoes(c, step: p.step)
    c.oy += p.breathe
    if nod { c.oy += 1 }
    drawBody(c, Look(arm: loden, eye: nil))
    // The eyes: narrowed under a hard brow while he stares.
    if stare {
        c.rect(21, 29, 4, 1, ink); c.rect(31, 29, 4, 1, ink); c.rect(22, 30, 2, 1, ink); c.rect(32, 30, 2, 1, ink)
    } else {
        c.rect(21, 28, 4, 1, clawdShade); c.rect(31, 28, 4, 1, clawdShade)
        c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    }
    // The coat: double-breasted, the astrakhan collar standing up round the neck.
    c.rect(18, 33, 20, 5, loden); c.rect(37, 33, 1, 5, lodenD); c.rect(18, 37, 20, 1, lodenD)
    c.rect(18, 33, 20, 1, astra); c.rect(18, 34, 3, 2, astra); c.rect(35, 34, 3, 2, astra)
    for x in stride(from: 18, to: 38, by: 3) { c.px(x, 33, astraD) }
    for y in [35, 37] { c.px(25, y, lodenL); c.px(30, y, lodenL) }   // the buttons
    // Grey hair at the temples, under the homburg: a dented crown, a curled brim, the band.
    let hairL = C(0xC4C6CC)
    c.rect(18, 26, 3, 3, hair); c.rect(35, 26, 3, 3, hair)
    c.px(18, 26, hairL); c.px(19, 27, hairL); c.px(37, 26, hairL); c.px(36, 27, hairL)
    c.pattern(15, 17, [
        "........HHHHHHHHHH......",
        "......HHHHHH..HHHHHH....",
        "......HHHHHHHHHHHHHH....",
        "......HHHHHHHHHHHHHH....",
        "......HHHHHHHHHHHHHH....",
        "......BBBBBBBBBBBBBB....",
        "..bHHHHHHHHHHHHHHHHHHHb.",
        "...HHHHHHHHHHHHHHHHHHH..",
        "....HHHHHHHHHHHHHHHHH...",
    ], ["H": hat, "B": band, "b": C(0x34343C)])
    c.px(28, 18, C(0x0E0E12)); c.px(29, 18, C(0x0E0E12))   // the dent
    // Black gloves; the pistol.
    c.rect(15, 33, 3, 3, loden); c.rect(15, 35, 3, 1, C(0x1A1A1E))
    c.oy += p.gunY
    drawSidearm(c, sleeve: loden, searching: false)
    c.rect(38, 35, 3, 1, C(0x1A1A1E))
}

// MARK: - A.D. Follmer

/// A.D. Follmer: the FBI's ambitious assistant director. Clawd with black hair slicked back hard and shining with gel, a
/// tailored navy pinstripe suit, a white shirt and a gold tie, a one-sided sneer at the corner of his mouth; a pistol.
/// The gel shines in two bands where the comb went through. Signature: he tugs his cuffs straight, one then the other, a cufflink glinting, and the sneer widens.
private func drawFollmer(_ c: PixelCanvas, _ p: Pose) {
    let navy = C(0x1E2A44), navyD = C(0x141C30), stripe = C(0x3A4A6A), shirt = C(0xF2F2EE), tie = C(0xD8B040)
    let hair = C(0x101014), gel = C(0x5A6478)
    let sig = p.signature
    let tugLeft = sig.map { $0 > 0.08 && $0 < 0.4 } ?? false
    let tugRight = sig.map { $0 >= 0.42 && $0 < 0.74 } ?? false
    let wide = sig.map { $0 >= 0.74 && $0 < 0.96 } ?? false

    drawLegs(c, Look(leg: navy), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0x0C0C10))
    c.oy += p.breathe
    drawBody(c, Look(arm: navy))
    suit(c, navy, navyD, shirt: shirt, tie: tie)
    for x in stride(from: 19, to: 37, by: 3) where x < 25 || x > 30 { c.rect(x, 34, 1, 3, stripe) }
    // The sneer: the mouth pulled up on one side.
    c.rect(29, 32, wide ? 5 : 3, 1, C(0x8E3A28)); c.px(wide ? 34 : 32, 31, C(0x8E3A28))
    // The hair: slicked straight back, the comb lines shining.
    c.pattern(17, 20, [
        "......HHHHHHHHHH......",
        "....HHHggggggggHHH....",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHHggggggggggHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HH................HH.",
    ], ["H": hair, "g": gel])
    if tugLeft || tugRight {
        // One hand at the other's cuff, the cufflink glinting.
        c.rect(15, 33, 3, 3, navy); c.rect(38, 33, 3, 3, navy)
        let x = tugLeft ? 16 : 39
        c.rect(x - 1, 36, 3, 1, shirt); c.px(x, 36, C(0xFFE27A))
        c.rect(tugLeft ? 19 : 34, 34, 3, 2, clawdOrange)
        return
    }
    c.rect(15, 33, 3, 3, navy)
    c.oy += p.gunY
    drawSidearm(c, sleeve: navy, searching: false)
}

// MARK: - Bill Clawder

/// Bill Clawder: Fox Clawder's father, who signed on with the Syndicate long ago and has never forgiven himself. Clawd with
/// his son's dark fringe gone thin and grey at the sides, a brown tweed jacket over a fawn sweater-vest and a knitted
/// tie, a pistol. Signature: he can't meet your eye: his gaze slides away and down, his shoulders sag, and his free hand
/// goes up to his brow.
private func drawBillClawder(_ c: PixelCanvas, _ p: Pose) {
    let tweed = C(0x6A4E34), tweedD = C(0x4A3624), fleck = C(0x8A6A4A), vest = C(0xB8A07A), shirt = C(0xEAE6DA)
    let tie = C(0x3A2A2A), hair = C(0x4A3A2E), grey = C(0x9A9A9E)
    let sig = p.signature
    let away = sig.map { $0 > 0.08 && $0 < 0.94 } ?? false
    let brow = sig.map { $0 > 0.35 && $0 < 0.85 } ?? false

    drawLegs(c, Look(leg: C(0x4A4440)), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0x2A1E16))
    c.oy += p.breathe
    drawBody(c, Look(arm: tweed, eye: nil))
    // The eyes: on you, or slid away to the side and down.
    if away {
        c.rect(20, 30, 2, 2, ink); c.rect(30, 30, 2, 2, ink)
        c.rect(20, 29, 3, 1, clawdShade); c.rect(30, 29, 3, 1, clawdShade)
    } else {
        c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    }
    // The tweed jacket open over the sweater-vest and tie.
    c.rect(18, 34, 20, 4, tweed); c.rect(37, 34, 1, 4, tweedD); c.rect(18, 37, 20, 1, tweedD)
    for (x, y) in [(19, 35), (22, 36), (35, 35), (33, 37), (20, 37)] { c.px(x, y, fleck) }
    c.pattern(23, 34, ["lVSTTSVl", ".lVTTVl.", "..VTTV..", "..VVVV.."], ["l": tweedD, "V": vest, "S": shirt, "T": tie])
    // The hair: Fox's fringe, thinner, greying at the sides.
    c.pattern(17, 20, [
        "........HHHHHH........",
        ".....HHHHHHHHHHHH.....",
        "...gHHHHHHHHHHHHHHg...",
        "..ggHHHHHHHHHHHHHHgg..",
        "..ggHHHHHHHHHHHHHHgg..",
        ".gggHHHHHHHHHHHHHHggg.",
        ".ggg...HHHH.......ggg.",
        ".gg................gg.",
    ], ["H": hair, "g": grey])
    if away { c.oy += 1 }   // the shoulders sag
    if brow {
        c.rect(15, 33, 3, 3, tweed); c.rect(18, 28, 3, 3, clawdOrange); c.rect(17, 30, 2, 3, tweed)
        c.rect(38, 33, 3, 3, tweed); c.rect(38, 35, 3, 1, clawdOrange)
        return
    }
    c.rect(15, 33, 3, 3, tweed)
    c.oy += p.gunY
    drawSidearm(c, sleeve: tweed, searching: false)
}

// MARK: - The Crew-Cut Man

/// The Crew-Cut Man: the Syndicate's cleaner. Clawd with a flat-top as square as a brick, dark glasses, a belted grey
/// raincoat with the collar up over a dark turtleneck, and a pistol with a long silencer. Signature: he screws the silencer on, turn by turn,
/// then looks left and right over his glasses.
private func drawCrewCutMan(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x6E7076), coatD = C(0x4E5056), coatL = C(0x8A8C92), hair = C(0x5A4A3A), shades = C(0x0E0E12)
    let sig = p.signature
    let screwing = sig.map { $0 > 0.06 && $0 < 0.5 } ?? false
    let look: Int = sig.map { s in s < 0.55 || s > 0.94 ? 0 : s < 0.75 ? -1 : 1 } ?? 0

    if !seatedPose { c.rect(17, 38, 22, 2, coat); c.rect(17, 39, 22, 1, coatD); c.rect(28, 38, 1, 2, coatD) }
    drawLegs(c, Look(leg: C(0x2E2E34)), step: p.step)
    drawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: coat, eye: nil))
    // The dark glasses; looking over them in the signature.
    if look != 0 {
        c.rect(20, 30, 6, 2, shades); c.rect(30, 30, 6, 2, shades); c.rect(26, 30, 4, 1, shades)
        c.rect(look < 0 ? 21 : 23, 28, 2, 2, ink); c.rect(look < 0 ? 31 : 33, 28, 2, 2, ink)
    } else {
        c.rect(20, 29, 6, 3, shades); c.rect(30, 29, 6, 3, shades); c.rect(26, 29, 4, 1, shades)
        c.px(21, 29, C(0x6A7A8A)); c.px(31, 29, C(0x6A7A8A))
    }
    // The raincoat: collar up, belted.
    // The turtleneck rolled right round the neck, the coat open over it in a V, its collar standing up at the sides.
    let turtle = C(0x2A2A30)
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD); c.rect(18, 36, 20, 1, coatD); c.rect(27, 36, 2, 1, coatL)
    c.rect(18, 32, 20, 2, turtle); c.rect(18, 32, 20, 1, C(0x3A3A42))
    c.rect(26, 34, 4, 1, turtle); c.rect(25, 34, 1, 1, coatL); c.rect(30, 34, 1, 1, coatL)
    c.rect(18, 31, 2, 3, coatL); c.rect(36, 31, 2, 3, coatL); c.rect(19, 32, 1, 2, coatD); c.rect(36, 32, 1, 2, coatD)
    // The flat-top: a square block, the sides cut to nothing.
    c.pattern(17, 19, [
        "..HHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HH................HH.",
    ], ["H": hair])
    for x in stride(from: 20, to: 37, by: 2) { c.px(x, 19, C(0x7A6A58)) }
    if screwing {
        // The pistol held up, the silencer in his other hand, turning onto the barrel.
        let turn = Int(p.t * 8) % 2
        c.rect(15, 31, 3, 3, coat); c.rect(38, 31, 3, 3, coat)
        c.pattern(40, 29, ["KKKKK", "KK...", "KK..."], ["K": C(0x24242A)])
        c.rect(45, 29, 4, 1, turn == 0 ? C(0x4A4C54) : C(0x6A6C74)); c.rect(45, 28, 1, 1, C(0x8A8C94))
        return
    }
    c.rect(15, 33, 3, 3, coat)
    c.oy += p.gunY
    drawSidearm(c, sleeve: coat, searching: false)
    c.rect(47, 31, 4, 1, C(0x4A4C54)); c.rect(47, 32, 4, 1, C(0x34363C))   // the silencer
}

// MARK: - The Colonist

/// The Colonist: one of the alien colonisers, passing badly for a man. Clawd gone a waxy grey-green, with blank white eyes
/// that have no pupils, in a long dark coat that doesn't reach the ground: it hangs in the air, the hem fading into
/// nothing where its feet should be. It doesn't fight; it watches. Signature: it leans in towards you, head on one side,
/// the white eyes brightening.
private func drawColonist(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xB4C0AE), skinD = C(0x8C9888), coat = C(0x2A322C), coatL = C(0x46504A), coatD = C(0x181C19)
    let sig = p.signature
    let lean: Int = sig.map { s in s < 0.12 || s > 0.9 ? 0 : s < 0.3 ? Int((s - 0.12) / 0.18 * 3) : 3 } ?? 0
    let bright = lean >= 2
    let drift = Int((sin(p.lt * 1.6) * 1).rounded())

    c.oy += drift
    // Legs in dark trousers under the long coat, fading out only at the feet, where it should touch the ground.
    let fades: [Double] = [1, 1, 1, 1, 0.55, 0.25]
    for (i, a) in fades.enumerated() {
        for lx in [19, 23, 31, 35] { c.rect(lx, 38 + i, 2, 1, C(0x5A625C).alpha(a)); c.px(lx + 1, 38 + i, C(0x3E4640).alpha(a)) }
    }
    c.rect(18, 32, 20, 7, coat); c.rect(37, 32, 1, 7, coatL); c.rect(27, 36, 1, 3, coatD)
    c.rect(18, 38, 20, 1, coatD)
    c.ox += lean
    // The body: waxy skin, the coat buttoned to the neck, lapels and a white collar.
    c.rect(18, 26, 20, 6, skin); c.rect(37, 26, 1, 6, skinD)
    c.rect(18, 32, 20, 4, coat); c.rect(37, 32, 1, 4, coatL)
    c.rect(26, 32, 4, 1, C(0xD8DCD4))
    c.px(25, 33, coatL); c.px(24, 34, coatL); c.px(30, 33, coatL); c.px(31, 34, coatL)
    c.px(27, 35, coatL); c.px(28, 38, coatL)   // the buttons
    // Long sleeves, the hands pale at their ends.
    c.rect(15, 32, 3, 6, coat); c.rect(38, 32, 3, 6, coat); c.px(17, 32, coatL); c.px(38, 32, coatL)
    c.rect(15, 38, 3, 1, skin); c.rect(38, 38, 3, 1, skin)
    // The blank eyes, brighter as it leans in; a faint glow round them.
    let eye = bright ? C(0xFFFFFF) : C(0xE8ECE4)
    c.rect(22, 28, 3, 3, eye); c.rect(31, 28, 3, 3, eye)
    if bright {
        for (x, y) in [(21, 28), (25, 28), (21, 30), (25, 30), (30, 28), (34, 28), (30, 30), (34, 30)] {
            c.px(x, y, C(0xE8FFF0, 0.45))
        }
    }
    // Short, flat, colourless hair.
    c.pattern(17, 21, [
        "....HHHHHHHHHHHHHH....",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HH................HH.",
    ], ["H": C(0x6E7468)])
    c.ox -= lean
}

// MARK: - Duffy Haskell

/// Duffy Haskell: a super soldier who looks like nobody in particular. Clawd in a dark green knit cap with ginger hair
/// showing under it, a mid-blue denim work jacket open over a grey hoodie, jeans and tan work boots; bullets glance off
/// him and he fights with his fists. Signature: he takes a fall and comes apart, his top half slumping off to one side
/// and his cap knocked the other way, steel showing at the breaks, then he clicks back together and shrugs.
private func drawDuffyHaskell(_ c: PixelCanvas, _ p: Pose) {
    let denim = C(0x4A6A9A), denimD = C(0x34507A), hood = C(0x8A8C92), hoodD = C(0x6A6C72), jeans = C(0x2E3C58)
    let cap = C(0x2E4A3A), capL = C(0x46685A), hair = C(0xC86A2E)
    let sig = p.signature
    // How far apart he is: 0 whole, up to 4.
    let apart: Int = sig.map { s in
        let k = s < 0.1 || s > 0.82 ? 0.0 : s < 0.2 ? (s - 0.1) / 0.1 : s < 0.6 ? 1 : (0.82 - s) / 0.22
        return Int((k * 4).rounded())
    } ?? 0

    drawLegs(c, Look(leg: jeans), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            c.rect(lx, p.step >= 0 && i % 2 == p.step ? 41 : 42, 2, 2, C(0xA87A44))
        }
    }
    c.oy += p.breathe
    // The lower half: the jacket's hem over the hoodie.
    c.rect(18, 34, 20, 4, denim); c.rect(37, 34, 1, 4, denimD); c.rect(18, 37, 20, 1, denimD)
    c.rect(26, 34, 4, 4, hood); c.px(26, 34, hoodD); c.px(29, 34, hoodD)
    c.px(27, 35, C(0xD8D8DC)); c.px(28, 36, C(0xD8D8DC))   // the hoodie's drawstrings
    // The top half: slumped off to the left and down while he's apart.
    c.ox -= apart; c.oy += apart / 2
    c.rect(18, 26, 20, 8, clawdOrange); c.rect(37, 26, 1, 8, clawdShade)
    c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    c.rect(18, 32, 20, 2, denim); c.rect(26, 32, 4, 2, hood); c.px(26, 32, hoodD); c.px(29, 32, hoodD)
    // The knit cap pulled low, ginger hair showing under it; knocked the other way when he's apart.
    c.ox += apart * 2
    c.pattern(17, 19, [
        "........HHHH..........",
        "....HHHHHHHHHHHHHH....",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".RRRRRRRRRRRRRRRRRRRR.",
        ".RRRRRRRRRRRRRRRRRRRR.",
        ".g..................g.",
    ], ["H": cap, "R": capL, "g": hair])
    c.ox -= apart; c.oy -= apart / 2
    if apart > 0 {
        // Steel at the breaks, glinting; the arms hanging loose.
        for x in stride(from: 19, to: 37, by: 3) { c.rect(x, 34 - 1, 1, 1 + apart / 2, steelDark) }
        c.px(20 + Int(p.t * 18) % 16, 33, steelLight)
        c.rect(20 + apart, 25, 16, 1, steel)
        c.rect(15 - apart, 33, 3, 3, denim); c.rect(38 + apart, 34, 3, 3, denim)
        return
    }
    fists(c, p, sleeve: denim)
}

// MARK: - Lord Kinbote

/// Lord Kinbote: the towering red alien who carries off the abductors in Jose Chung's book. Clawd made huge and red: a
/// great domed head with a heavy brow and deep black eyes rising high over the body, thick red limbs, the hide ridged
/// down the chest. A steady red-hot ray from his outstretched hand. Signature: he draws himself up even taller, spreads
/// his arms wide and roars.
private func drawLordKinbote(_ c: PixelCanvas, _ p: Pose) {
    let hide = C(0xC8302A), hideD = C(0x8E1E1A), hideL = C(0xE85A44), eye = C(0x0A0608)
    let sig = p.signature
    let roar = sig.map { $0 > 0.15 && $0 < 0.9 } ?? false
    let casting = p.zap != nil || p.ready || p.cheering || (!p.resting && !p.walking)

    // Thick legs and broad feet.
    if seatedPose {
        for lx in [18, 32] { c.rect(lx - 1, 38, 7, 2, hide) }
    } else {
        for (i, lx) in [19, 32].enumerated() {
            let lifted = p.step >= 0 && i == p.step
            c.rect(lx, 36, 5, lifted ? 6 : 7, hide); c.rect(lx + 4, 36, 1, lifted ? 6 : 7, hideD)
            c.rect(lx - 1, lifted ? 42 : 43, 7, 1, hideD)
        }
    }
    c.oy += p.breathe
    if roar { c.oy -= 2 }
    // The body: broad, the hide ridged down the chest.
    c.rect(16, 24, 24, 14, hide); c.rect(39, 24, 1, 14, hideD); c.rect(16, 37, 24, 1, hideD)
    for y in stride(from: 26, to: 37, by: 3) { c.rect(24, y, 8, 1, hideD); c.rect(25, y + 1, 6, 1, hideL) }
    // The great head: a dome rising high, the brow overhanging the eyes.
    c.pattern(15, 5, [
        "........HHHHHHHHHH........",
        "......HHHHHHLLHHHHHH......",
        ".....HHHHHHHHHHHHHHHHH....",
        "....HHHHHHHHHHHHHHHHHHH...",
        "...HHHHHHHHHHHHHHHHHHHHH..",
        "...HHHHHHHHHHHHHHHHHHHHD..",
        "..HHHHHHHHHHHHHHHHHHHHHHD.",
        "..HHHHHHHHHHHHHHHHHHHHHHD.",
        "..HHHHHHHHHHHHHHHHHHHHHHD.",
        "..DDDDDDDDDDHHDDDDDDDDDDD.",
        "..HHEEEEEHHHHHHHEEEEEHHHD.",
        "..HHEEEEEHHHHHHHEEEEEHHHD.",
        "..HHHEEEHHHHHHHHHEEEHHHHD.",
        "...HHHHHHHHHHHHHHHHHHHHD..",
        "...HHHHHHHHDDDDHHHHHHHHD..",
        "....HHHHHHHHHHHHHHHHHHD...",
        "....HHHHHHHHHHHHHHHHHHD...",
        ".....HHHHHHHHHHHHHHHHD....",
        "......HHHHHHHHHHHHHHD.....",
    ], ["H": hide, "L": hideL, "D": hideD, "E": eye])
    if roar {
        c.rect(25, 19, 6, 3, C(0x2A0A0A)); c.rect(25, 19, 6, 1, C(0xF0E8D8))   // the mouth wide, teeth showing
        // Both arms flung wide.
        c.rect(8, 22, 8, 4, hide); c.rect(6, 19, 4, 4, hide); c.rect(40, 22, 8, 4, hide); c.rect(46, 19, 4, 4, hide)
        return
    }
    // The arms: the left hanging; the right thrust out to cast.
    c.rect(12, 26, 4, 9, hide); c.rect(12, 34, 4, 2, hideD)
    if casting {
        let lift = p.armRaise
        c.rect(40, 28 - lift, 6, 4, hide); c.rect(45, 27 - lift, 2, 6, hideL)
        if p.zap == true { c.px(47, 29 - lift, C(0xFFE8C8)) }
    } else {
        c.rect(40, 26, 4, 9, hide); c.rect(40, 34, 4, 2, hideD)
    }
}
