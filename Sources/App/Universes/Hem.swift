import Foundation

// HEM: the one character in every universe, with the same face in each: big buns, wire glasses, a scowl and a
// salt-and-pepper goatee. He's the last hero of every cast (`Universe.hem`), kept out of the regular pools and turning
// up only now and then (`Universe.hemOdds`). Star Clawds: Laya's white robe and a blaster (and a word for her about
// buns, `Overlay`). Marvelous Clawds: a purple-and-gold captain with an H and its shield. Detective Clawds: Harlee's
// jacket, dyed buns and a toy wand. Doctor Clawd: a tweed jacket, a red bow tie, a fez (fezzes are cool) and a sonic
// screwdriver. The Clawd Files: a tan trench coat, an FBI lanyard and a flashlight. Stevie Clawdberg: a fedora, a
// leather jacket and a bullwhip. Clawd of the Rings: Éowyn's Rohan helmet, which comes off to let the buns out, its
// white crest, mail, a green-and-gold cloak, a sword and the sun-horse shield. Clawd Slayer: a Watcher's tweed jacket and tie, and a
// wooden stake. Signature, everywhere: he shakes his fist at you.

func hemPersona(_ u: Universe) -> Persona {
    switch u {
    case .starWars:
        return Persona(name: "HEM", weapon: .blaster, canSit: false, muzzle: (47, 32), headTop: 21, signature: 2.6,
                       draw: { drawHem($0, $1, .starWars) })
    case .marvel:
        return Persona(name: "HEM", weapon: .saber, headTop: 21, signature: 2.6, draw: { drawHem($0, $1, .marvel) })
    case .dc:
        return Persona(name: "HEM", weapon: .blaster, shot: .energy(core: C(0xFFF6C8), glow: C(0xFF7AC8)), muzzle: (52, 27),
                       headTop: 21, signature: 2.6, draw: { drawHem($0, $1, .dc) })
    case .doctor:
        return Persona(name: "HEM", weapon: .lightning, magic: Magic(core: C(0xE8FFE0), glow: C(0x4ADB5A), jagged: false),
                       pivot: hemSonicTip, headTop: 15, signature: 2.6, draw: { drawHem($0, $1, .doctor) })
    case .clawdFiles:
        return Persona(name: "HEM", weapon: .lightning, magic: Magic(core: C(0xFFFBE8), glow: C(0xFFE9A0), jagged: false),
                       pivot: hemSonicTip, headTop: 21, signature: 2.6, draw: { drawHem($0, $1, .clawdFiles) })
    case .clawdberg:
        return Persona(name: "HEM", weapon: .saber, headTop: 20, signature: 2.6, draw: { drawHem($0, $1, .clawdberg) })
    case .middleEarth:
        return Persona(name: "HEM", weapon: .saber, headTop: 21, signature: 2.6, draw: { drawHem($0, $1, .middleEarth) })
    case .slayer:
        return Persona(name: "HEM", weapon: .saber, headTop: 21, signature: 2.6, draw: { drawHem($0, $1, .slayer) })
    }
}


private let hemShade = C(0xB85F40)
private let hairMain = C(0x4A2E18), hairDark = C(0x2E1C0E), hairPart = C(0x6E4A2C)
private let wire = C(0xD5DAE2), beard = C(0x2A221C), beardGrey = C(0xA8A8A8)
private let robe = C(0xF4F4F0), robeShade = C(0xD2D4DA)
private let capPurple = C(0x5B2D8E), capPurpleDark = C(0x43206A), capGold = C(0xE8B33A)
private let harleeRed = C(0xC8202A), harleeBlue = C(0x2E5CC9)
private let tweed = C(0x7A5232), tweedDark = C(0x5A3C24), fezRed = C(0xB8202A), fezDark = C(0x7A1218)
private let trench = C(0xB89A66), trenchDark = C(0x8A7048)
private let leather = C(0x6A3E22), leatherDark = C(0x4A2A16), felt = C(0x7A5A3A), feltDark = C(0x5A402A)
private let watcherTweed = C(0x8A7C5C), watcherTweedDark = C(0x665A40)
/// Where the sonic screwdriver's tip (or the flashlight's lens) is, held out: the beam leaves from there, raised by
/// the pose's `armRaise`.
private let hemSonicTip = (x: 46.0, y: 30.0)

private func drawHem(_ c: PixelCanvas, _ p: Pose, _ u: Universe) {
    // Signature: the fist goes up by his shoulder and shakes at you while he yells. Éowyn first pulls her helmet off
    // with it (`rohanHelmetOff`), so hers starts shaking later.
    let shakeFrom = u == .middleEarth ? 0.25 : 0.08
    let shaking = p.signature.map { $0 > shakeFrom && $0 < 0.92 } ?? false
    let helmet = rohanHelmetOff(u == .middleEarth ? p.signature : nil)
    let fistUp = shaking || helmet.pull != nil
    let frame = Int(p.t * 9) % 2

    // Legs, or the robe's hem with his shoes peeking out.
    switch u {
    case .starWars:
        for y in 38...43 {
            let q = (y - 38) / 2
            c.rect(17 - q, y, 22 + q * 2, 1, robe); c.px(17 - q, y, robeShade); c.px(38 + q, y, robeShade)
            if y > 39 { c.px(24, y, robeShade); c.px(31, y, robeShade) }
        }
        let lifted = p.step >= 0 ? (p.step == 0 ? 0 : 1) : -1
        c.rect(19, lifted == 0 ? 43 : 44, 4, 1, ink); c.rect(33, lifted == 1 ? 43 : 44, 4, 1, ink)
    case .marvel:
        drawLegs(c, Look(leg: capPurple), step: p.step)
        if !seatedPose {
            for (i, lx) in [19, 23, 31, 35].enumerated() { c.rect(lx, p.step >= 0 && i % 2 == p.step ? 41 : 42, 2, 2, capGold) }
        }
    case .middleEarth:
        drawRohanCloak(c, t: p.t, speed: p.capeSpeed)
        drawLegs(c, Look(leg: rohanTrousers), step: p.step)
        if !seatedPose {
            for (i, lx) in [19, 23, 31, 35].enumerated() {
                let bottom = p.step >= 0 && i % 2 == p.step ? 42 : 43
                c.rect(lx, bottom - 2, 2, 3, rohanBoot)
            }
        }
    case .dc:
        let net = C(0x3A3A44)
        drawLegs(c, Look(leg: net), step: p.step)
        if !seatedPose {
            for (i, lx) in [19, 23, 31, 35].enumerated() {
                let top = p.step >= 0 && i % 2 == p.step ? 36 : 37
                c.px(lx, top + 3, C(0x6A6A78)); c.px(lx + 1, top + 5, C(0x6A6A78))   // fishnets
                c.rect(lx, top + 6, 2, 1, ink)
            }
        }
    case .doctor:
        drawLegs(c, Look(leg: C(0x2A2A32)), step: p.step)
        if !seatedPose {
            for (i, lx) in [19, 23, 31, 35].enumerated() { c.rect(lx, p.step >= 0 && i % 2 == p.step ? 41 : 42, 2, 2, C(0x3A2416)) }
        }
    case .clawdFiles:   // the trench coat's tails over grey trousers and black shoes
        drawLegs(c, Look(leg: C(0x4A4A54)), step: p.step)
        drawDressShoes(c, step: p.step)
        c.rect(17, 38, 22, seatedPose ? 1 : 3, trench); c.rect(28, 38, 1, seatedPose ? 1 : 3, trenchDark)
    case .clawdberg:   // khaki trousers and brown boots
        drawLegs(c, Look(leg: C(0xA89468)), step: p.step)
        cbBoots(c, step: p.step, C(0x4A2E1A), height: 3)
    case .slayer:   // grey flannel trousers and brown brogues
        drawLegs(c, Look(leg: C(0x5E5E64)), step: p.step)
        slayerBoots(c, step: p.step, C(0x5A3A22))
    }

    c.oy += p.breathe
    // The body, wider than plain Clawd's, and the top of his costume over it.
    let top: Px, topShade: Px, arm: Px, armRight: Px
    switch u {
    case .starWars: top = robe; topShade = robeShade; arm = robe; armRight = robe
    case .marvel: top = capPurple; topShade = capPurpleDark; arm = capPurple; armRight = capPurple
    case .middleEarth: top = rohanMail; topShade = rohanMailDark; arm = rohanMail; armRight = rohanMail
    case .dc: top = white; topShade = C(0xD8D8DC); arm = harleeRed; armRight = harleeBlue
    case .doctor: top = tweed; topShade = tweedDark; arm = tweed; armRight = tweed
    case .clawdFiles: top = trench; topShade = trenchDark; arm = trench; armRight = trench
    case .clawdberg: top = leather; topShade = leatherDark; arm = leather; armRight = leather
    case .slayer: top = watcherTweed; topShade = watcherTweedDark; arm = watcherTweed; armRight = watcherTweed
    }
    c.rect(17, 26, 22, 12, clawdOrange); c.rect(38, 26, 1, 12, hemShade)
    c.rect(17, 34, 22, 4, top); c.rect(38, 34, 1, 4, topShade); c.rect(20, 34, 16, 1, topShade)   // the turtleneck's roll
    switch u {
    case .starWars:
        c.rect(17, 37, 22, 1, C(0xB8BEC9)); for x in [20, 23, 32, 35] { c.px(x, 37, C(0xEEF0F4)) }
        c.rect(27, 36, 2, 2, C(0xEEF0F4))
    case .marvel:
        for x in 17...38 { c.px(x, 37, x % 2 == 0 ? capGold : white) }
        c.pattern(18, 34, ["H.H", "HHH", "H.H"], ["H": capGold])
    case .middleEarth:
        for y in 35...36 { for x in 17...37 where (x + y) % 2 == 0 { c.px(x, y, rohanMailLight) } }
        c.rect(17, 37, 22, 1, rohanTunic)
        for y in 38...39 where y + c.oy <= 43 { c.rect(17, y, 22, 1, rohanTunic); c.px(27, y, rohanTunicDark); c.px(38, y, rohanTunicDark) }
        c.rect(17, 34, 2, 4, rohanCloak); c.rect(19, 34, 1, 4, rohanGold)          // the cloak over the shoulder
        c.rect(37, 34, 2, 4, rohanCloak); c.rect(36, 34, 1, 4, rohanGold)
        c.px(19, 34, C(0xFFE08A)); c.px(36, 34, C(0xFFE08A))                     // its clasps
    case .dc:
        c.rect(17, 34, 3, 4, harleeRed); c.rect(36, 34, 3, 4, harleeBlue); c.rect(17, 37, 22, 1, C(0x2A2A32))
    case .doctor:   // the jacket open over a shirt, red braces and the bow tie
        c.rect(24, 34, 8, 4, C(0xE8E2D4)); c.rect(25, 35, 1, 3, fezRed); c.rect(30, 35, 1, 3, fezRed)
        c.pattern(25, 34, ["RRrRR", "R...R"], ["R": fezRed, "r": fezDark])
    case .clawdFiles:   // the coat open over a shirt, the lanyard and its FBI card
        c.rect(24, 34, 8, 4, C(0xE8E6E0)); c.px(25, 34, C(0x2E4A8A)); c.px(30, 34, C(0x2E4A8A))
        c.px(26, 35, C(0x2E4A8A)); c.px(29, 35, C(0x2E4A8A))
        c.pattern(26, 36, ["WWWW", "WBBW"], ["W": white, "B": C(0x2E4A8A)])
    case .clawdberg:   // the jacket open over a khaki shirt, and the satchel's strap across it
        c.rect(24, 34, 8, 4, C(0xC8B48A)); c.px(24, 34, leatherDark); c.px(31, 34, leatherDark)
        for i in 0..<4 { c.px(25 + i * 2, 34 + i, C(0x8A7A52)); c.px(26 + i * 2, 34 + i, C(0x8A7A52)) }
    case .slayer:   // the tweed open over a white shirt and a dark green tie, flecks in the cloth
        c.rect(24, 34, 8, 4, C(0xEEEAE0)); c.rect(27, 34, 2, 4, C(0x2E4A32)); c.px(27, 37, C(0x1E3222))
        for (x, y) in [(18, 35), (21, 36), (34, 35), (36, 37), (19, 37)] { c.px(x, y, watcherTweedDark) }
    }
    // Arms: hands on hips at rest, the right one forward to fight.
    let forward = !shaking && u != .middleEarth && (!p.resting || p.melee != nil)   // Éowyn holds her sword low
    c.rect(14, 33, 3, 3, arm)
    let lift = u == .doctor || u == .clawdFiles ? p.armRaise : 0
    if !fistUp { c.rect(39, (forward ? 31 : 33) - lift, 3, 3, armRight) }
    if !forward { c.px(16, 35, clawdOrange); if !fistUp { c.px(39, 35, clawdOrange) } }

    if u != .middleEarth {
        drawHemHead(c, u)
    } else if helmet.rise > 0 {   // the hair under the helmet, and the buns once they're out of it
        drawHemHead(c, u, buns: helmet.buns != nil, bunDrop: helmet.buns ?? 0)
    }
    if u == .marvel {   // the helmet: purple, the H, little white wings
        c.pattern(17, 21, ["....HHHHHHHHHHHHHH....", "..HHHHHHHHHHHHHHHHHH..", ".HHHHHHHHHHHHHHHHHHHH.", "HHHHHHHHHHHHHHHHHHHHHH",
                           "HHHHHHHHHHHHHHHHHHHHHH", "HH..................HH"], ["H": capPurple])
        c.pattern(26, 21, ["H..H", "HHHH", "H..H", "H..H"], ["H": capGold])
        c.pattern(15, 21, ["W.", "WW", ".W"], ["W": white]); c.pattern(39, 21, [".W", "WW", "W."], ["W": white])
    }
    if u == .doctor {   // the fez, a little to the back, its tassel hanging
        c.pattern(22, 15, ["...FFFFFF..", "...FFFFFFK.", "..FFFFFFFFK", "..FFFFFFFF.", ".FFFFFFFFFF", ".ffffffffff"],
                  ["F": fezRed, "f": fezDark, "K": ink])
    }
    if u == .clawdberg { cbFedora(c, felt: felt, dark: feltDark, band: C(0x3A2416)) }
    drawHemFace(c, yelling: shaking && frame == 1)
    if u == .middleEarth { drawRohanHelmet(c, t: p.t, rise: helmet.rise, strand: helmet.buns == nil) }   // over the face
    if u == .dc { c.pattern(36, 32, [".R.R", "RRRR", ".RR."], ["R": C(0xE8323A)]) }   // the little heart on his cheek

    if let lift = helmet.pull, !shaking {
        // Éowyn's arm up, her fist at the helmet's cheek piece pulling it off, then back down by her shoulder until it
        // starts to shake.
        c.rect(39, 32 - lift, 3, 2 + lift, rohanMail)
        c.pattern(39, 27 - lift, [".FFFF.", "FfFfFF", "FFFFFF", "FFFFFs", ".FFss."], ["F": clawdOrange, "f": hemShade, "s": hemShade])
        drawRohanShield(c, cx: 14, cy: seatedPose ? 33 : 35)
        return
    }

    if shaking {
        // The fist by his shoulder, a pixel up and over every other frame, with shake ticks; the anger mark.
        let fx = 39 + frame, fy = 27 - frame
        c.pattern(fx, fy, [".FFFF.", "FfFfFF", "FFFFFF", "FFFFFs", ".FFss."], ["F": clawdOrange, "f": hemShade, "s": hemShade])
        let tick = C(0xFFFFFF, 0.85)
        for (dx, dy) in (frame == 0 ? [(7, 0), (7, 3), (2, -2)] : [(-1, -2), (7, -1), (7, 2)]) {
            c.px(fx + dx, fy + dy, tick); c.px(fx + dx, fy + dy + 1, tick)
        }
        c.pattern(33, 21, [".R.R.", "RR.RR", ".....", "RR.RR", ".R.R."], ["R": C(0xE8323A)])
        if u == .marvel { drawHemShield(c, cx: 15, cy: seatedPose ? 33 : 35) }
        if u == .middleEarth { drawRohanShield(c, cx: 14, cy: seatedPose ? 33 : 35) }
        return
    }

    switch u {
    case .starWars:   // a little blaster, kicking with each shot
        c.pattern(41, 31 + p.gunY, ["KKKKKK", "KKTKK.", "KK...."], ["K": C(0x2A2A30), "T": C(0x8A8F9C)])
    case .middleEarth:   // the sword held low, swung along `p.melee` and smeared through `p.trail`; the shield on the off arm
        if let a = p.melee {
            for (i, ta) in p.trail.enumerated() { drawRohanSword(c, angle: ta, alpha: 0.3 / Double(i + 1)) }
            drawRohanSword(c, angle: a)
        } else {
            drawRohanSword(c, angle: seatedPose ? 8 : 35)
        }
        drawRohanShield(c, cx: 14, cy: seatedPose ? 33 : 35)
    case .marvel:
        if let a = p.melee {
            for (i, ta) in p.trail.enumerated() {
                let (x, y) = hemShieldAt(ta)
                drawHemShield(c, cx: x, cy: y, alpha: 0.35 / Double(i + 1))
            }
            let (x, y) = hemShieldAt(a)
            drawHemShield(c, cx: x, cy: y)
        } else {
            drawHemShield(c, cx: 44, cy: seatedPose ? 32 : 34)
        }
    case .dc:
        drawWand(c, raised: p.fire != nil || p.ready || p.cheering, gunY: p.gunY, t: p.t)
    case .doctor:
        drawHemSonic(c, out: forward || p.zap != nil, lift: lift)
    case .clawdFiles:
        drawHemFlashlight(c, out: forward || p.zap != nil, lift: lift)
    case .clawdberg:
        if let a = p.melee { cbWhip(c, angle: a, trail: p.trail, t: p.t, leather: C(0x5A3A22)) } else { cbWhipCoil(c, C(0x5A3A22)) }
    case .slayer:
        if let a = p.melee { slayerStake(c, angle: a, trail: p.trail) } else { slayerStakeHeld(c) }
    }
}

/// His flashlight: held down by his side at rest; pointed out, its lens at `hemSonicTip` (`lift` higher). The beam
/// itself is the persona's steady stream.
private func drawHemFlashlight(_ c: PixelCanvas, out: Bool, lift: Int) {
    let body = C(0x2E2E34), rim = C(0x6A6A74), lens = C(0xFFF6D0)
    if out {
        let y = 31 - lift
        c.rect(41, y, 4, 2, body); c.rect(45, y - 1, 1, 4, rim); c.rect(46, y, 1, 2, lens)
    } else {
        c.rect(40, 34, 2, 4, body); c.rect(40, 38, 2, 1, rim)
    }
}

/// His sonic screwdriver: held up in his fist at rest; pointed out, its green tip at `hemSonicTip` (`lift` higher).
private func drawHemSonic(_ c: PixelCanvas, out: Bool, lift: Int) {
    let grip = C(0x3A3A44), steel = C(0xC8CCD4), tip = C(0x7AF08A)
    if out {
        let y = 32 - lift
        c.rect(42, y, 2, 1, grip); c.rect(44, y - 1, 2, 1, steel); c.px(46, y - 2, tip)
    } else {
        c.rect(40, 29, 1, 4, grip); c.px(40, 28, steel); c.px(40, 27, tip.alpha(0.7))
    }
}

/// The buns (bigger than Laya's: his are 7 across) and the centre-parted hair; Harlee's are dyed pink and blue.
/// `buns: false` leaves them tucked up (in Éowyn's helmet); `bunDrop` hangs them that many px low, tumbling out of it.
private func drawHemHead(_ c: PixelCanvas, _ u: Universe, buns: Bool = true, bunDrop: Int = 0) {
    let bun = ["..BBB..", ".BBbBB.", "BBbBBbB", "BbBBbBB", "BBbBBbB", ".BBbBB.", "..BBB.."]
    if u == .dc {
        c.pattern(10, 24, bun, ["B": C(0xF06AA8), "b": C(0xC84A86)]); c.pattern(39, 24, bun, ["B": C(0x4A8CF0), "b": C(0x2E68C8)])
        c.rect(16, 26, 1, 3, hairMain); c.rect(39, 26, 1, 3, hairMain)   // brown at the roots
    } else if buns {
        let y = 24 + bunDrop
        c.pattern(10, y, bun, ["B": hairMain, "b": hairDark]); c.pattern(39, y, bun, ["B": hairMain, "b": hairDark])
    }
    c.pattern(17, 21, [
        "....BBBBBBlBBBBBBB....",
        "..BBBBBBBBlBBBBBBBBB..",
        ".BBBBbBBBBlBBBBbBBBBB.",
        "BBBBBBB...l....BBBBBBB",
        "BBB................BBB",
    ], ["B": hairMain, "b": hairDark, "l": hairPart])
}

/// Brows sloping in, wire glasses over squinting eyes, the mustache turned down into the frown and the goatee.
private func drawHemFace(_ c: PixelCanvas, yelling: Bool) {
    for (x, y) in [(20, 26), (21, 26), (22, 27), (23, 27), (24, 27), (35, 26), (34, 26), (33, 27), (32, 27), (31, 27)] { c.px(x, y, beard) }
    c.px(27, 27, hemShade); c.px(28, 27, hemShade)
    for x0 in [20, 30] {
        c.rect(x0, 28, 6, 1, wire); c.rect(x0, 31, 6, 1, wire); c.rect(x0, 28, 1, 4, wire); c.rect(x0 + 5, 28, 1, 4, wire)
        c.rect(x0 + 1, 29, 4, 2, C(0xF2E0D4))
    }
    c.rect(26, 29, 4, 1, wire); c.px(19, 29, wire); c.px(36, 29, wire)
    c.rect(22, 30, 2, 1, ink); c.rect(32, 30, 2, 1, ink)
    c.pattern(22, 32, [
        "..MMMMMMMM..",
        ".MMMMMMMMMM.",
        yelling ? ".MMppppppMM." : ".MM.pppp.MM.",
        yelling ? "..MpppppMM.." : "..MgMMMgMM..",
        "..gMMgMMgM..",
        "...MgMMgM...",
        "....gMMg....",
    ], ["M": beard, "g": beardGrey, "p": yelling ? C(0x5A2418) : C(0x8E4A38)])
}

/// The shield's centre held out at `angle` degrees from the hand.
private func hemShieldAt(_ angle: Double) -> (Int, Int) {
    let r = angle * .pi / 180
    return (Int((Sprite.hand.x + cos(r) * 5).rounded(.down)), Int((Sprite.hand.y + sin(r) * 5).rounded(.down)))
}

/// The round shield: gold, white, purple, with a gold H in the middle.
private func drawHemShield(_ c: PixelCanvas, cx: Int, cy: Int, alpha: Double = 1) {
    for (r, col) in [(5, capGold), (4, white), (2, capPurple)] { c.ellipse(cx, cy, r, r, col.alpha(alpha)) }
    c.pattern(cx - 1, cy - 1, ["H.H", "HHH", "H.H"], ["H": capGold.alpha(alpha)])
}

/// A pink toy wand with a yellow star, glitter turning round it; tipped forward when he uses it (the star at the
/// persona's muzzle, (52, 27)).
private func drawWand(_ c: PixelCanvas, raised: Bool, gunY: Int, t: Double) {
    let stick = C(0xF7A8D0), star = C(0xFFE14A), starShade = C(0xF2B620)
    let x = 41, y = (raised ? 32 : 35) + gunY
    if raised { for i in 0..<7 { c.px(x + i, y - i / 2, stick) } } else { c.rect(x, y - 6, 1, 7, stick) }
    let sx = raised ? x + 7 : x - 2, sy = raised ? y - 7 : y - 11
    c.pattern(sx, sy, ["..Y..", ".YYY.", "YYyYY", ".YYY.", ".Y.Y."], ["Y": star, "y": starShade])
    if raised { c.px(x + 3, y - 1, C(0x7AD0FF)); c.px(x + 4, y - 2, C(0xC88CFF)) }   // ribbons
    let glitter = [C(0xFF7AC8), C(0x7AD0FF), C(0xFFE14A), white, C(0xC88CFF)]
    let k = Int(t * 6)
    for i in 0..<5 {
        let a = Double(i) * 1.3 + t * 5.4
        c.px(sx + 2 + Int(cos(a) * 5), sy + 2 + Int(sin(a) * 4), glitter[(i + k) % glitter.count])
    }
}

// MARK: - Clawd of the Rings: Éowyn

let rohanMail = C(0x8A8E98), rohanMailDark = C(0x6A6E78), rohanMailLight = C(0xAEB2BA)
let rohanTunic = C(0x3A6A3A), rohanTunicDark = C(0x2A522A), rohanCloak = C(0x2E5A2E), rohanGold = C(0xE8B33A)
let rohanSteel = C(0xC8CCD4), rohanSteelDark = C(0x9A9EA8), rohanCrest = C(0xF0EEE8)
let rohanTrousers = C(0x5A5E66), rohanBoot = C(0x4A3420)

/// The green-and-gold cloak hanging down the back: it shows past the shoulder and between the back legs, its hem
/// swaying at `speed`, a gold trim down its edge and along the hem.
func drawRohanCloak(_ c: PixelCanvas, t: Double, speed: Double) {
    let hem = 42, last = min(hem, 43 - c.oy)
    guard last >= 27 else { return }
    for y in 27...last {
        let k = Double(y - 27) / Double(hem - 27)
        let sway = sin(t * speed + k * 2.2) * k * 1.6
        let l = Int((14.5 - k * 3.5 + sway).rounded()), r = 23 + Int((k * 2).rounded())
        c.rect(l, y, r - l + 1, 1, y == hem ? rohanGold : rohanCloak)
        c.px(l, y, rohanGold)
    }
}

/// Éowyn's helmet `s` through her signature (nil: not doing it). `rise`: px it is lifted off her head (0: on; from
/// `rohanHelmetGone`, off the canvas top). `buns`: nil while they're tucked up in it, else how many px low they hang
/// as they tumble out. `pull`: her fist up pulling it off (px above its place by her shoulder), until the shaking starts.
/// 0–0.2 the helmet rises off the top, the fist lifting with it; from 0.2 the buns tumble out (2 px low, then 1, settled
/// at 0.3); 0.25–0.92 the fist shakes (`drawHem`); after 0.92 the helmet drops back on and the buns go back in.
private func rohanHelmetOff(_ s: Double?) -> (rise: Int, buns: Int?, pull: Int?) {
    guard let s = s, s > 0 else { return (0, nil, nil) }
    if s < 0.2 {
        let k: Double = s / 0.2
        let rise = Int((k * k * Double(rohanHelmetGone)).rounded())
        return (rise, nil, min(rohanReach, rise))
    }
    if s <= 0.25 { return (rohanHelmetGone, 2, Int(((0.25 - s) / 0.05 * Double(rohanReach)).rounded())) }
    if s < 0.3 { return (rohanHelmetGone, 1, nil) }
    if s <= 0.92 { return (rohanHelmetGone, 0, nil) }
    let k: Double = min(1, (s - 0.92) / 0.06)   // falling: slow off the top, fast onto her head
    let rise = Int(((1 - k * k) * Double(rohanHelmetGone)).rounded())
    return (rise, rise > 5 ? 0 : nil, nil)
}

/// How far the helmet rises to leave the canvas top (its crest starts at row 18), and how far up her fist goes with it.
private let rohanHelmetGone = 34, rohanReach = 5

/// The Rohan helmet over the face, `rise` px up off the head: a steel dome with a gold-riveted band, cheek pieces and a
/// nose guard, and the white horsehair crest streaming back off the top. It hides the buns; one strand of hair
/// escapes at the back (`strand`, which stays on the head).
func drawRohanHelmet(_ c: PixelCanvas, t: Double, rise: Int = 0, strand: Bool = true) {
    if strand { for (x, y) in [(16, 26), (16, 27), (16, 28), (17, 29)] { c.px(x, y, hairMain) } }   // the one strand of hair
    guard rise < rohanHelmetGone else { return }
    let oy = c.oy
    c.oy -= rise
    defer { c.oy = oy }
    let sway = sin(t * 2.2) > 0 ? 1 : 0
    let crest: [(y: Int, l: Int, r: Int)] = [(18, 25, 30), (19, 21, 31), (20, 15, 23), (21, 12, 20), (22, 10, 17), (23, 9, 15),
                                             (24, 9, 13), (25, 9, 11), (26, 10, 10)]
    for (i, row) in crest.enumerated() {
        let dy = i >= 4 ? sway : 0
        c.rect(row.l, row.y + dy, row.r - row.l + 1, 1, rohanCrest)
        if i >= 2 { c.px(row.l, row.y + dy + 1, C(0xC8C6C0)) }
    }
    c.pattern(17, 20, [
        ".......HHHHHHHH.......",
        ".....HHHHHHHHHHHH.....",
        "...HHHlHHHHHHHHHHHH...",
        "..HHlHHHHHHHHHHHHHHD..",
        ".HHHHHHHHHHHHHHHHHHHD.",
        "BBBBBBBBBBBBBBBBBBBBBB",
        "HH........NN........HH",
        "H.........NN.........H",
        "..........NN..........",
    ], ["H": rohanSteel, "l": white, "D": rohanSteelDark, "B": rohanSteelDark, "N": rohanSteel])
    for x in [19, 23, 32, 36] { c.px(x, 25, rohanGold) }
}

/// Éowyn's round shield: green, a gold rim, and the gold sun-horse of Rohan in the middle.
func drawRohanShield(_ c: PixelCanvas, cx: Int, cy: Int) {
    c.ellipse(cx, cy, 5, 5, rohanGold)
    c.ellipse(cx, cy, 4, 4, rohanCloak)
    c.rect(cx - 1, cy - 1, 3, 3, rohanGold)                                   // the horse's body
    c.px(cx + 2, cy - 2, rohanGold); c.px(cx + 1, cy - 2, rohanGold)          // its head and mane
    c.px(cx, cy - 3, rohanGold); c.px(cx + 2, cy - 3, rohanGold)
    c.px(cx - 1, cy + 2, rohanGold); c.px(cx + 1, cy + 2, rohanGold)          // its legs
}

/// Éowyn's sword, gripped at the hand: a leather grip, a gold crossguard and pommel, a straight steel blade.
/// `alpha` < 1: a ghost of it, for the smear of a swing.
func drawRohanSword(_ c: PixelCanvas, angle: Double, alpha: Double = 1) {
    let h = Sprite.hand, r: Double = angle * .pi / 180
    let u = (x: cos(r), y: sin(r)), n = (x: -sin(r), y: cos(r))
    let clear = C(0x000000, 0)
    c.glowLine(h.x - u.x * 2, h.y - u.y * 2, h.x + u.x * 1.5, h.y + u.y * 1.5, core: C(0x4A3420).alpha(alpha), glow: clear,
               coreR: 0.6, glowR: 0.7)
    c.px(Int(h.x - u.x * 2.5), Int(h.y - u.y * 2.5), rohanGold.alpha(alpha))
    let g = (x: h.x + u.x * 2.2, y: h.y + u.y * 2.2)
    c.glowLine(g.x - n.x * 2.2, g.y - n.y * 2.2, g.x + n.x * 2.2, g.y + n.y * 2.2, core: rohanGold.alpha(alpha), glow: clear,
               coreR: 0.55, glowR: 0.6)
    c.glowLine(h.x + u.x * 3, h.y + u.y * 3, h.x + u.x * 15, h.y + u.y * 15, core: rohanSteel.alpha(alpha), glow: clear,
               coreR: 0.75, glowR: 0.8)
    c.glowLine(h.x + u.x * 3 + n.x * 0.6, h.y + u.y * 3 + n.y * 0.6, h.x + u.x * 14 + n.x * 0.6, h.y + u.y * 14 + n.y * 0.6,
               core: C(0x8A8F9C).alpha(alpha), glow: clear, coreR: 0.3, glowR: 0.35)
}
