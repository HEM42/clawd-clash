import Foundation

// Heroes: the First Slayer, Principal Wood, three of the Potentials, Riley and Jonathan. Clawd in costume like the
// rest of the cast: hair and clothes drawn over the blocky body, with Clawd's own orange face showing.

let slayerHeroes4: [SlayerHero: Persona] = [
    .firstSlayer: Persona(name: "The First Slayer", weapon: .saber, headTop: 17, signature: 3.4,
                          callout: "No friends. Just the kill.", draw: drawFirstSlayer),
    .robinWoode: Persona(name: "Principal Robin Woode", weapon: .saber, headTop: 24, signature: 3.0, draw: drawRobinWoode),
    .kennedie: Persona(name: "Kennedie", weapon: .saber, headTop: 20, signature: 3.4, draw: drawKennedie),
    .vy: Persona(name: "Vy", weapon: .saber, headTop: 19, signature: 3.0, draw: drawVy),
    .rhona: Persona(name: "Rhona", weapon: .saber, headTop: 14, signature: 3.0, draw: drawRhona),
    .rileyFynn: Persona(name: "Riley Fynn", weapon: .blaster, shot: .energy(core: C(0xE4F2FF), glow: C(0x2E7CFF)),
                        muzzle: (58, 32), headTop: 23, signature: 3.2, callout: "Ma'am.", draw: drawRileyFynn),
    .jonathanLevinsun: Persona(name: "Jonathan Levinsun", headTop: 21, signature: 3.4, draw: drawJonathanLevinsun),
]

// MARK: - Shared bits

/// 0…1 through the middle stretch of a signature move (`from`…`to` of it), or -1 outside it.
private func h4Span(_ p: Pose, _ from: Double, _ to: Double) -> Double {
    guard let s = p.signature, s > from, s < to else { return -1 }
    return (s - from) / (to - from)
}

/// 0 at the ends of a 0…1 stretch, 1 through its middle: eased in over the first `edge` and out over the last.
private func h4Hold(_ k: Double, edge: Double = 0.2) -> Double {
    guard k >= 0 else { return 0 }
    let u = min(1, k / edge, (1 - k) / edge)
    return u * u * (3 - 2 * u)
}

/// Whether a weapon at `angle` points back over the shoulder: then it's drawn before the body, behind the head.
private func h4Behind(_ angle: Double?) -> Bool { angle.map { cos($0 * .pi / 180) < -0.25 } ?? false }

/// How long a weapon `len` pixels out from `h` along `angle` may be drawn so it never reaches past the frame, and,
/// unless it's drawn `behind` the body, foreshortens as it swings back towards the face so it never crosses it.
private func h4Fit(_ h: (x: Double, y: Double), _ angle: Double, _ len: Double, behind: Bool = false) -> Double {
    let r = angle * .pi / 180, dx = cos(r), dy = sin(r)
    var l = len
    if dx < -0.01 { l = min(l, (h.x - (behind ? 3 : 39)) / -dx) }
    if dx > 0.01 { l = min(l, (68 - h.x) / dx) }
    if dy < -0.01 { l = min(l, (h.y - 4) / -dy) }
    if dy > 0.01 { l = min(l, (46 - h.y) / dy) }
    return max(1.5, l)
}

/// An unarmed hero's free arm: up and waving while cheering or calling you urgently.
private func h4Wave(_ c: PixelCanvas, _ p: Pose, sleeve: Px) {
    guard p.cheering || (p.ready && p.urgent) else { return }
    let up = sin(p.t * 10) > 0 ? 1 : 0
    c.rect(38, 26 - up, 3, 7 + up, sleeve); c.rect(38, 24 - up, 3, 2, clawdOrange)
}

/// A wooden stake swung along `angle`, as the kit draws it, but foreshortened when it swings back past the face.
private func h4Stake(_ c: PixelCanvas, angle: Double, trail: [Double]) {
    let h = slayerHand, len = h4Fit(h, angle, 9.5, behind: h4Behind(angle))
    slayerSmear(c, h, trail.filter { cos($0 * .pi / 180) > -0.25 }, from: 2, to: 10, C(0xF4E8D0))
    slayerBar(c, h, angle, from: -2, to: len - 1.5, slayerStakeDark, r: 1.2)
    slayerBar(c, h, angle, from: -2, to: len - 2, slayerStakeWood, r: 0.9)
    let tip = slayerReach(h, angle, len)
    c.px(Int(tip.x.rounded()), Int(tip.y.rounded()), slayerStakePoint)
    c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, clawdOrange)
}

// MARK: - The First Slayer

/// The First Slayer, as she comes to them in dreams ("Restless"): Clawd with wild, thick dreadlocks sticking out every
/// way, a few clay beads in them, her face painted chalk-white across the eyes with black streaks running down from
/// them, and a hide wrap tied at one shoulder with a ragged fringe at the hem, her legs bare and her feet bound in hide.
/// She fights with a spear: a long dark shaft, a pale bone point lashed on. Signature: she sinks into a low crouch,
/// spear levelled, and sand swirls round her, then she rises.
private func drawFirstSlayer(_ c: PixelCanvas, _ p: Pose) {
    let hide = C(0x9C7448), hideD = C(0x6E4E2E), hideL = C(0xC09468)
    let dread = C(0x2C1E16), dreadL = C(0x54402E), bead = C(0xC8783A)
    let paint = C(0xEEE8DC), soot = C(0x141012)
    let crouchK = h4Span(p, 0.06, 0.94)
    let low = Int((h4Hold(crouchK, edge: 0.18) * 3).rounded())

    drawLegs(c, Look(), step: p.step)
    slayerBoots(c, step: p.step, hideD, height: 2)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.px(lx, low > 0 ? 42 : 41, hideL) } }
    c.oy += p.breathe + low
    let shaft = C(0x6A4626), shaftL = C(0x9A6E40), bone = C(0xE6DEC8), boneD = C(0xB0A68C), lash = C(0x3A2416)
    // The spear stays in front of her: a swing back over her shoulder stops just past upright, beside her hair, as
    // drawn behind her the dreadlocks hid it all and only a fist showed.
    let spear = {
        let a = h4FrontAngle(p.melee ?? 0)
        drawSpear(c, from: slayerHand, angle: a, shaft: shaft, shaftL: shaftL, bone: bone, boneD: boneD,
                  lash: lash, trail: p.trail.map(h4FrontAngle).filter { abs($0 - a) > 4 })
    }
    drawBody(c, Look(arm: clawdOrange))
    // The hide wrap: tied over one shoulder, down past her hips to a ragged fringe.
    c.rect(18, 33, 20, 5, hide); c.rect(37, 33, 1, 5, hideD); c.rect(18, 33, 20, 1, hideL)
    for i in 0..<5 { c.px(31 + i, 32 - i / 2, hide) }   // the strap over her shoulder
    c.px(20, 35, hideD); c.px(26, 36, hideD); c.px(33, 35, hideD); c.px(29, 34, hideL)
    if !seatedPose {
        c.rect(18, 38, 20, 1, hide)
        for x in 18...37 where x % 2 == 0 { c.px(x, 39, x % 4 == 0 ? hideD : hide) }
    }
    // The painted face: chalk white across the eyes, black streaks running down from them.
    c.rect(19, 28, 18, 3, paint); c.rect(20, 31, 3, 1, paint); c.rect(33, 31, 3, 1, paint)
    c.rect(22, 29, 2, 3, soot); c.rect(32, 29, 2, 3, soot)
    c.rect(22, 32, 1, 2, soot); c.rect(33, 32, 1, 2, soot); c.px(25, 32, soot); c.px(30, 32, soot)
    // Wild dreadlocks: ropes standing out round her head and hanging past her shoulders, beads here and there.
    c.pattern(13, 17, [
        ".....D..D...D...D..D...D....",
        "...D.DD.DD.DDD.DD..DD.DD.D..",
        "..DDDDDDDDDDDDDDDDDDDDDDDDD.",
        ".DDlDDlDDlDDoDDlDDlDDlDDlDDD",
        ".DDDDDDDDDDDDDDDDDDDDDDDDDDD",
        "DDlDDDDlDDDDlDDDDlDDDDlDDDDD",
        "DDDDDDDDDDDDDDDDDDDDDDDDDDDD",
        "DDDDDDlDDDDDDDDDDDDlDDDDDDDD",
        "DDDDDDlDlDDDlDDDDlDDDlDDDDD.",
        "DDDDDD.D..D...D..D..D..DDDD.",
        "DDDDD..................DDDD.",
        "DDlD...................DDlD.",
        ".DDD...................DDDD.",
        "DDDD...................DlD..",
        "DlDD...................DDDo.",
        ".DDD....................DD..",
        "DDoD....................D...",
        ".DDD........................",
        "DD.D........................",
        ".D.o........................",
    ], ["D": dread, "l": dreadL, "o": bead])

    if crouchK >= 0 {
        // Crouched, the spear levelled at whatever is out there.
        drawSpear(c, from: slayerHand, angle: -8 - 4 * sin(p.t * 2), shaft: shaft, shaftL: shaftL, bone: bone,
                  boneD: boneD, lash: lash, trail: [])
        c.oy -= p.breathe + low
        drawSand(c, p.t, h4Hold(crouchK, edge: 0.25))
        return
    }
    if p.melee != nil {
        spear()
    } else {
        // At rest: the spear upright in her fist, its butt on the ground.
        let bottom = seatedPose ? 39 : 42, top = seatedPose ? 18 : 14
        c.rect(41, top + 4, 1, bottom - top - 4, shaft); c.rect(42, top + 4, 1, bottom - top - 4, shaftL)
        c.pattern(40, top, [".BB.", ".BB.", "BBbB", "BBbB"], ["B": bone, "b": boneD])
        c.rect(41, top + 4, 2, 1, lash)
        c.rect(40, 33, 3, 3, clawdOrange)
    }
}

/// A swung weapon's angle kept in front of the face: past upright on the backswing it stops beside the head (and past
/// straight down, beside the legs), rather than sweeping across the face or hiding behind the hair.
private func h4FrontAngle(_ a: Double) -> Double {
    var n = a.truncatingRemainder(dividingBy: 360)
    if n > 180 { n -= 360 } else if n <= -180 { n += 360 }
    return max(-97, min(110, n))
}

/// The First Slayer's sand, whirling round her on a flat ellipse in streaks, `k` 0…1 how strong. Drawn last, and
/// how solid each grain is depends on where it lands: over her it shows clearly, out in the air it's half there, and
/// right against her silhouette it stays faint, so her outline never goes dotted.
private func drawSand(_ c: PixelCanvas, _ t: Double, _ k: Double) {
    guard k > 0 else { return }
    let sand = C(0xEAD098), sandL = C(0xF8ECC4)
    func alphaAt(_ x: Int, _ y: Int) -> UInt8 {
        let xx = x + c.ox, yy = y + c.oy + c.baseY
        guard xx >= 0, yy >= 0, xx < c.w, yy < c.h else { return 0 }
        return c.buf[(yy * c.w + xx) * 4 + 3]
    }
    for i in 0..<30 {
        let g = Double(i) / 30 * 2 * .pi + t * 3.2
        let rx = 21.0 + noise(i) * 5, ry = 7.0 + noise(i + 40) * 3
        let y = Int((37 - Double(i % 5) * 3 + sin(g) * ry * 0.5).rounded())
        for s in 0..<3 {   // a streak: the grain and the two it trails
            let x = Int((28 + cos(g - Double(s) * 0.07) * rx).rounded())
            guard x >= 1, x <= 70, y >= 1 else { continue }
            let here = alphaAt(x, y)
            let a: Double
            if here == 255 { a = 0.6 }
            else if [alphaAt(x - 1, y), alphaAt(x + 1, y), alphaAt(x, y - 1), alphaAt(x, y + 1)].contains(255) { a = 0.18 }
            else { a = 0.65 }
            c.px(x, y, (s == 0 ? sandL : sand).alpha(a * k / Double(s + 1)))
        }
    }
}

/// The First Slayer's spear along `angle` from `h`: a dark shaft with a pale edge, the bone point lashed on.
private func drawSpear(_ c: PixelCanvas, from h: (x: Double, y: Double), angle: Double, shaft: Px, shaftL: Px,
                       bone: Px, boneD: Px, lash: Px, trail: [Double]) {
    let len = h4Fit(h, angle, 18, behind: h4Behind(angle))
    slayerSmear(c, h, trail.filter { cos($0 * .pi / 180) > -0.25 }, from: 6, to: 17, C(0xF4E8D0))
    let back = -min(4, h4Fit(h, angle + 180, 4))
    slayerBar(c, h, angle, from: back, to: len - 3, shaft, r: 0.8)
    slayerBar(c, h, angle, from: back, to: len - 3.5, shaftL, r: 0.4)
    if len > 7 {
        slayerBar(c, h, angle, from: len - 4, to: len - 1, boneD, r: 1.1)
        slayerBar(c, h, angle, from: len - 4, to: len, bone, r: 0.7)
        let l = slayerReach(h, angle, len - 4)
        c.px(Int(l.x.rounded()), Int(l.y.rounded()), lash)
    }
    c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, clawdOrange)
}

// MARK: - Principal Robin Woode

/// Principal Robin Woode: Clawd with his head shaved close (a shine on top, dark brows) and a neat moustache, his
/// mother Nikki's long cognac leather coat from the seventies, its wide lapels open over a pale blue shirt and a navy
/// tie, grey trousers and black shoes. He fights with a stake, and keeps one up his sleeve: at rest its point just shows at
/// his cuff. Signature: he flicks his wrist and the stake slides out of his sleeve into his hand, then back up it.
private func drawRobinWoode(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x7A4626), coatD = C(0x522C16), coatL = C(0xA0643A), shirt = C(0xB8CEE6), tie = C(0x263258)
    let scalp = C(0xE89272), brow = C(0x3A2418)
    let flickK = h4Span(p, 0.08, 0.9)

    drawLegs(c, Look(leg: C(0x6A6C78)), step: p.step)
    slayerBoots(c, step: p.step, C(0x18161A), height: 1)
    // The long coat's skirts, open at the front, down to his shins: the four legs show under them.
    if !seatedPose {
        c.rect(17, 38, 10, 3, coat); c.rect(29, 38, 10, 3, coat); c.rect(38, 38, 1, 3, coatD)
        c.rect(17, 40, 10, 1, coatD); c.rect(29, 40, 10, 1, coatD); c.rect(26, 38, 1, 2, coatL)
        c.rect(27, 38, 2, 2, C(0x6A6C78))
    } else {
        c.rect(17, 38, 7, 1, coat); c.rect(32, 38, 7, 1, coat)
    }
    c.oy += p.breathe
    let raise = flickK >= 0 ? 2 : 0
    let behind = flickK < 0 && h4Behind(p.melee)
    if behind, let a = p.melee { h4Stake(c, angle: a, trail: p.trail) }
    drawBody(c, Look(arm: coat), armRight: raise)
    // The coat open over the shirt and tie, big lapels and a wide collar standing at his neck.
    c.rect(18, 33, 20, 5, coat); c.rect(24, 33, 8, 5, shirt); c.rect(27, 33, 2, 5, tie); c.px(27, 33, C(0x161E3A))
    c.rect(37, 33, 1, 5, coatD); c.rect(18, 37, 6, 1, coatD); c.rect(32, 37, 6, 1, coatD)
    c.pattern(21, 32, ["LLL........LLL", ".LLL......LLL.", "..LL......LL..", "...L......L..."], ["L": coatL])
    // The shaved head: a dark, close-buzzed dome rising above the block, a hard hairline, a bright shine on top and
    // heavy dark brows. (Shading the plain block alone left him reading as Clawd with nothing on.)
    let buzz = C(0x8A4630), dot = C(0x5E2E1E), stubble = C(0xA8553C)
    c.pattern(18, 24, [
        "...BBBdBBBBBdBBBB...",
        ".BBLLLBBBdBBBBBBdBB.",
        "BBLLLLBBBBBBBdBBBBBB",
        "BdBBBBBBdBBBBBBBBdBB",
        "BB................dB",
        "B..................B",
    ], ["B": buzz, "L": scalp, "d": dot])
    c.px(18, 30, stubble); c.px(37, 30, stubble)
    c.rect(21, 28, 4, 1, brow); c.rect(31, 28, 4, 1, brow)
    // A neat moustache.
    c.rect(25, 32, 6, 1, brow); c.px(25, 31, brow); c.px(30, 31, brow)

    let cuff = (x: 40.5, y: 34.5 - Double(raise))
    if flickK >= 0 {
        // The stake slides out of his sleeve, he grips it, holds it up, and it slides back.
        let out = min(1, flickK / 0.3) * min(1, (1 - flickK) / 0.2)
        let angle = -20.0
        let len = 3 + out * 7
        slayerBar(c, cuff, angle, from: 0, to: len - 0.5, slayerStakeDark, r: 1.2)
        slayerBar(c, cuff, angle, from: 0, to: len - 1, slayerStakeWood, r: 0.9)
        let tip = slayerReach(cuff, angle, len + 0.5)
        c.px(Int(tip.x.rounded()), Int(tip.y.rounded()), slayerStakePoint)
        if flickK > 0.22 && flickK < 0.32 {
            c.px(43, 29, white.alpha(0.8)); c.px(45, 29, white.alpha(0.4)); c.px(44, 28, white.alpha(0.4))
        }
        if out > 0.95 { c.rect(41, 31, 3, 3, clawdOrange) } else { c.rect(41, 32, 2, 2, clawdOrange) }
        return
    }
    if let a = p.melee {
        if !behind { h4Stake(c, angle: a, trail: p.trail) }
    } else {
        // At rest his hand hangs loose, the stake's point just showing at his cuff.
        c.rect(41, 34, 2, 2, clawdOrange); c.px(41, 33, slayerStakeWood); c.px(42, 33, slayerStakePoint)
    }
}

// MARK: - Kennedie

/// Kennedie: the cocky Potential who took charge of the drills. Clawd with sleek dark hair pulled back into a high
/// ponytail that swings out behind her, a fitted plum long-sleeved top, tan combat trousers with a pocket on each leg
/// and black boots. She fights with a quarterstaff, banded with black grips. Signature: the drill sergeant: a whistle
/// in her mouth, blown in short blasts, and her clipboard held up.
private func drawKennedie(_ c: PixelCanvas, _ p: Pose) {
    let top = C(0x7A3058), topD = C(0x582040), topL = C(0x9A4874)
    let hair = C(0x24160E), hairL = C(0x4A3020), hairD = C(0x140A06)
    let drillK = h4Span(p, 0.08, 0.92)
    let swing = Int((sin(p.t * 3) * 0.6).rounded())

    drawLegs(c, Look(leg: C(0xA89468)), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() where i % 2 == 0 {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, lifted ? 38 : 39, 2, 2, C(0x84724C))
        }
    }
    slayerBoots(c, step: p.step, C(0x1A1614), height: 2)
    c.oy += p.breathe
    let wood = C(0x7A4E2A), woodL = C(0xA87444), grip = C(0x1E1A18)
    let behind = drillK < 0 && h4Behind(p.melee)
    let staff = { (a: Double) in
        let h = slayerHand
        slayerSmear(c, h, p.trail.filter { cos($0 * .pi / 180) > -0.25 }, from: 4, to: 13, C(0xF4E8D0))
        let front = h4Fit(h, a, 13, behind: behind), back = h4Fit(h, a + 180, 8)
        slayerBar(c, h, a + 180, from: 0, to: back, wood, r: 0.8)
        slayerBar(c, h, a, from: 0, to: front, wood, r: 0.8)
        slayerBar(c, h, a, from: 0, to: front - 0.5, woodL, r: 0.35)
        for d in [front - 1.5, -back + 1.5] {
            let g = slayerReach(h, a, d)
            c.rect(Int(g.x.rounded()), Int(g.y.rounded()), 1, 1, grip)
        }
        c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, clawdOrange)
    }
    if behind, let a = p.melee { staff(a) }
    drawBody(c, Look(arm: top), armLeft: drillK >= 0 ? 4 : 0)
    // The fitted top, a belt at the waist.
    c.rect(18, 33, 20, 5, top); c.rect(37, 33, 1, 5, topD); c.rect(18, 33, 1, 4, topL)
    c.rect(18, 37, 20, 1, C(0x2A2420)); c.px(27, 37, C(0xB0A890))
    // Sleek dark hair, pulled back tight, and the high ponytail swinging out behind.
    c.pattern(11, 19 + swing, [
        "....PP....",
        "..PPPPP...",
        ".PPlPPPP..",
        "PPPPPPP...",
        "PPdPP.....",
        "PPPP......",
        ".PdP......",
        ".PP.......",
        "..P.......",
    ], ["P": hair, "l": hairL, "d": hairD])
    c.pattern(16, 20, [
        "......HHHHHHHHHHH.......",
        "....HHHHHHHHHlHHHHH.....",
        "...HHHlHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHH..",
        ".dHHHH.............HHH..",
        ".HHH................HH..",
        "..HH................dH..",
        "..dH....................",
    ], ["H": hair, "l": hairL, "d": hairD])
    c.rect(19, 21, 4, 3, hair); c.rect(19, 22, 2, 1, C(0xC83A4A))   // the band where the ponytail's tied

    if drillK >= 0 {
        // The whistle in her mouth, blown in short blasts.
        let blow = Int(p.t * 5) % 2 == 0 && drillK > 0.15 && drillK < 0.9
        c.rect(27, 32, 3, 1, C(0xC8CCD4)); c.px(29, 32, C(0x8A8F9C))
        for i in 0..<4 { c.px(28 - i, 33 + i / 2, C(0xD84A3A)) }   // the lanyard
        if blow {
            c.rect(22, 29, 2, 3, clawdOrange); c.rect(22, 30, 2, 1, ink)
            for (x, y) in [(31, 31), (33, 30), (34, 32)] { c.px(x, y, white) }
            c.px(35, 29, white.alpha(0.5)); c.px(36, 31, white.alpha(0.5))
        }
        // The clipboard held up in her other hand.
        c.rect(9, 25, 6, 8, C(0x8A5A30)); c.rect(10, 26, 4, 6, C(0xF2EEE2))
        c.rect(11, 24, 2, 2, C(0xB8BCC4))
        for y in [27, 29, 31] { c.rect(10, y, 3, 1, C(0x8A8F9C)) }
        c.rect(13, 28, 3, 3, clawdOrange)
        // The staff stands by her, upright in her fist.
        drawStaffUpright(c, wood: wood, woodL: woodL, grip: grip)
        return
    }
    if let a = p.melee {
        if !behind { staff(a) }
    } else {
        drawStaffUpright(c, wood: wood, woodL: woodL, grip: grip)
    }
}

/// Kennedie's staff at rest: upright in her fist, banded at both ends.
private func drawStaffUpright(_ c: PixelCanvas, wood: Px, woodL: Px, grip: Px) {
    let bottom = seatedPose ? 39 : 42, top = seatedPose ? 21 : 17
    c.rect(41, top, 2, bottom - top + 1, wood); c.rect(41, top, 1, bottom - top + 1, woodL)
    c.rect(41, top + 1, 2, 2, grip); c.rect(41, bottom - 2, 2, 2, grip)
    c.rect(40, 33, 3, 3, clawdOrange)
}

// MARK: - Vy

/// Vy: the shy Potential. Clawd with a teal woolly hat pulled well down, a ribbed brim and a bobble on top, wisps of
/// auburn hair showing under it, big dark-rimmed glasses, a baggy mustard jumper with its sleeves over her hands, and
/// jeans. She fights with a stake. Signature: she pulls her hat down shyly, over her glasses, then peeks back out.
private func drawVy(_ c: PixelCanvas, _ p: Pose) {
    let jumper = C(0xC89A3A), jumperD = C(0x9A7426), jumperL = C(0xE0B856)
    let hat = C(0x2E8A8E), hatD = C(0x1E6266), hatL = C(0x4CAAAE), bobble = C(0xE8E4D8)
    let hair = C(0x9A4A26), rim = C(0x1E1A1E)
    let shyK = h4Span(p, 0.08, 0.92)
    let down = Int((h4Hold(shyK, edge: 0.25) * 3).rounded())   // no further: her shut eyes and blush still show

    drawLegs(c, Look(leg: C(0x5A6E9E)), step: p.step)
    slayerBoots(c, step: p.step, C(0x6A3A2A), height: 1)
    c.oy += p.breathe
    let behind = shyK < 0 && h4Behind(p.melee)
    if behind, let a = p.melee { h4Stake(c, angle: a, trail: p.trail) }
    drawBody(c, Look(arm: jumper), armRight: shyK >= 0 ? 6 : 0)
    // The baggy jumper, ribbed at the hem, its neck rolled.
    c.rect(18, 33, 20, 5, jumper); c.rect(37, 33, 1, 5, jumperD); c.rect(18, 33, 1, 4, jumperL)
    for x in stride(from: 18, through: 37, by: 2) { c.px(x, 37, jumperD) }
    c.rect(24, 33, 8, 1, jumperL)
    // Wisps of auburn hair under the hat, at her cheeks (tucked away when she pulls it down).
    if down < 2 { c.pattern(17, 25, [
        "HH................HH",
        "HHH..............HHH",
        ".HH..............HH.",
        ".H................H.",
        ".H.................H",
    ], ["H": hair]) }
    // Big dark-rimmed glasses.
    if down < 3 {
        c.pattern(20, 28, ["RRRRRR....RRRRRR", "R....R....R....R", "R....RRRRRR....R", "RRRRRR....RRRRRR"],
                  ["R": rim])
        c.px(19, 29, rim); c.px(36, 29, rim)
    } else {
        // Eyes shut tight under the brim.
        c.rect(20, 31, 6, 1, rim); c.rect(30, 31, 6, 1, rim)
    }
    // The woolly hat: a ribbed brim, the crown knitted in rows, a bobble on top.
    c.oy += down
    c.pattern(16, 18, [
        "..........BB...........",
        ".........BBBB..........",
        "......HHHHHHHHHHH......",
        "....HHHHlHHHHHHHHHH....",
        "...HHHHHHHHHHHHHHlHHH..",
        "..HHHHHHHHHHHHHHHHHHHH.",
        "..HdHdHdHdHdHdHdHdHdHd.",
        "..RRRRRRRRRRRRRRRRRRRR.",
        "..RLRLRLRLRLRLRLRLRLRR.",
        "..RRRRRRRRRRRRRRRRRRRR.",
    ], ["B": bobble, "H": hat, "l": hatL, "d": hatD, "R": hatD, "L": hat])
    c.oy -= down

    if shyK >= 0 {
        // Her hand up at the brim, tugging it down: the baggy sleeve up from her shoulder, its rolled cuff, and her
        // fingers curled over the brim's edge.
        let by = 27 + down
        c.rect(38, by - 2, 3, 30 - by + 3, jumper); c.rect(38, by - 2, 3, 1, jumperL); c.px(40, by, jumperD)
        c.rect(35, by - 1, 3, 2, clawdOrange); c.px(36, by, clawdShade); c.px(35, by - 1, clawdShade)
        if down >= 3 { c.rect(19, 32, 2, 1, C(0xF08A80)); c.rect(35, 32, 2, 1, C(0xF08A80)) }
        return
    }
    if let a = p.melee {
        if !behind { h4Stake(c, angle: a, trail: p.trail) }
        c.rect(38, 33, 2, 3, jumper)
    } else {
        // The stake held point down, her sleeve over most of her hand.
        slayerStakeHeld(c)
        c.rect(38, 33, 3, 3, jumper); c.rect(39, 36, 2, 1, jumperD)
    }
}

// MARK: - Rhona

/// Rhona: the outspoken Potential. Clawd with her braids pulled back off her face under a white headband and gathered
/// in a thick bunch behind her head, a royal-blue zip-up sports top with white stripes down the sleeves, grey joggers
/// and white trainers. She fights with a woodcutter's axe. Signature: "this is so unfair": she rolls her eyes and
/// throws both arms out.
private func drawRhona(_ c: PixelCanvas, _ p: Pose) {
    let top = C(0x2A56C8), topD = C(0x1C3C96), stripe = C(0xF2F4F8)
    let hair = C(0x1C1210), braid = C(0x3E2A20), band = C(0xF2F4F8)
    let rollK = h4Span(p, 0.08, 0.92)
    let out = h4Hold(rollK, edge: 0.18)

    drawLegs(c, Look(leg: C(0x8E909C)), step: p.step)
    slayerBoots(c, step: p.step, C(0xF2F2F2), height: 2)
    c.oy += p.breathe
    let arms = Int((out * 5).rounded())
    let haft = C(0x9A6A3C), haftD = C(0x6A4424), steel = C(0x9AA2AE), edge = C(0xE4E8EE)
    let behind = rollK < 0 && h4Behind(p.melee)
    let axe = { (a: Double) in
        let h = slayerHand, len = h4Fit(h, a, 12, behind: behind)
        slayerSmear(c, h, p.trail.filter { cos($0 * .pi / 180) > -0.25 }, from: 6, to: 12, C(0xF4E8D0))
        slayerBar(c, h, a, from: -2, to: len, haftD, r: 0.9)
        slayerBar(c, h, a, from: -2, to: len - 0.5, haft, r: 0.5)
        if len > 7 {
            let head0 = slayerReach(h, a, len - 3), head1 = slayerReach(h, a, len)
            let side = a + 90
            let e0 = slayerReach(head0, side, 3.5), e1 = slayerReach(head1, side, 4)
            slayerLine(c, head0.x, head0.y, e0.x, e0.y, steel, 1)
            slayerLine(c, head1.x, head1.y, e1.x, e1.y, steel, 1)
            slayerLine(c, e0.x, e0.y, e1.x, e1.y, edge, 0.7)
        }
        c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, clawdOrange)
    }
    if behind, let a = p.melee { axe(a) }
    drawBody(c, Look(arm: top), armLeft: arms, armRight: arms)
    // The sports top: a white zip down the middle, stripes on the shoulders.
    c.rect(18, 33, 20, 5, top); c.rect(37, 33, 1, 5, topD); c.rect(18, 37, 20, 1, topD)
    c.rect(27, 33, 1, 5, C(0x6E92EC)); c.rect(25, 33, 2, 1, topD); c.rect(28, 33, 2, 1, topD)
    c.rect(18, 33, 2, 1, stripe); c.rect(36, 33, 2, 1, stripe)
    // Braids pulled back over her head under a white headband, and wound up into a big round bun on her crown, tied
    // in blue: a round top-knot, where Kennedie's sleek ponytail streams out behind.
    c.pattern(16, 20, [
        "......HHbHHHbHHHbH......",
        "...HHbHHbHHHbHHHbHHb....",
        "..HHbHHHbHHHbHHHbHHHbH..",
        "..WWWWWWWWWWWWWWWWWWWW..",
        ".HHbHHHbHHHbHHHbHHHbHH..",
        ".HbH..............HbH...",
        "..bH...............b....",
    ], ["H": hair, "b": braid, "W": band])
    c.pattern(17, 14, [
        "...HHHHH...",
        "..HbbHbbH..",
        ".HbHHbHHbH.",
        ".HbHbbbHbH.",
        ".HbHHbHHbH.",
        "..HbbHbbH..",
        "...TTTTT...",
    ], ["H": hair, "b": braid, "T": top])

    if rollK >= 0 {
        // Eyes rolled up, arms thrown out, palms up; the axe still in her fist.
        c.rect(22, 29, 2, 3, white); c.rect(32, 29, 2, 3, white)
        c.rect(22, 29, 2, 1, ink); c.rect(32, 29, 2, 1, ink)
        c.rect(25, 32, 6, 1, C(0x9A4A36))
        if arms > 1 {
            // Arms flung wide, elbows up and out, palms turned up to the sky: a big "so unfair".
            let wide = arms - 1, y = 33 - arms
            c.rect(14 - wide, y, 4 + wide, 3, top); c.rect(14 - wide, y, 4 + wide, 1, stripe)
            c.rect(38, y, 3 + wide, 3, top); c.rect(38, y, 3 + wide, 1, stripe)
            c.rect(11 - wide, y - 1, 3, 2, clawdOrange); c.px(11 - wide, y - 2, clawdOrange)
            c.rect(41 + wide, y - 1, 3, 2, clawdOrange); c.px(43 + wide, y - 2, clawdOrange)
            // The axe dangling from her hand, head down.
            let hx = 42 + wide, hy = 34 - arms
            c.rect(hx, hy, 1, 7, haft); c.rect(hx + 1, hy, 1, 7, haftD)
            c.rect(hx + 2, hy + 5, 3, 3, steel); c.rect(hx + 4, hy + 5, 1, 3, edge)
        }
        return
    }
    if let a = p.melee {
        if !behind { axe(a) }
    } else {
        // The axe held by the neck, its head down by her leg.
        let len = seatedPose ? 3 : 6
        c.rect(39, 34, 1, len + 1, haft); c.rect(40, 34, 1, len + 1, haftD)
        c.rect(41, 34 + len - 2, 3, 3, steel); c.rect(43, 34 + len - 2, 1, 3, edge)
        c.rect(38, 33, 3, 3, clawdOrange)
    }
}

// MARK: - Riley Fynn

/// Riley Fynn: the tall farm boy turned Initiative commando. Clawd with a short sandy crew cut, a few tufts standing up,
/// in grey-green camouflage fatigues under a black tactical vest with pouches, the Initiative's blue patch on his
/// arm, and black boots. He shoots a taser rifle, a chunky grey gun with a blue-lit coil. Signature: he stands to
/// attention, rifle grounded at his side, and salutes: "Ma'am."
private func drawRileyFynn(_ c: PixelCanvas, _ p: Pose) {
    let camo = C(0x667058), camoD = C(0x434C38), camoL = C(0x8A9474)
    let vest = C(0x26282C), vestL = C(0x3E4248)
    let hair = C(0xC8A264), hairL = C(0xE4C68A), hairD = C(0x9A7A44)
    let saluteK = h4Span(p, 0.1, 0.9)
    let salute = h4Hold(saluteK, edge: 0.2) > 0.6

    drawLegs(c, Look(leg: camo), step: p.step)
    if !seatedPose {
        // Camouflage in blotches across the whole width of each leg: single dots down one side read as stripes.
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            c.rect(lx, 37 + i % 2 * 2, 2, 1, camoD); c.px(lx + (i + 1) % 2, 38 + i % 2 * 2, camoD)
            c.px(lx + i % 2, 40 - i % 2 * 3, camoL)
        }
    }
    slayerBoots(c, step: p.step, C(0x141416), height: 3)
    c.oy += p.breathe
    drawBody(c, Look(arm: camo), armRight: salute ? 6 : 0)
    // The fatigues, and the black vest over them with its pouches.
    c.rect(18, 33, 20, 5, camo)
    for (x, y) in [(18, 34), (19, 36), (36, 33), (37, 35)] { c.px(x, y, camoD) }
    c.rect(20, 33, 16, 5, vest); c.rect(20, 33, 16, 1, vestL)
    c.rect(21, 35, 3, 2, vestL); c.rect(25, 35, 3, 2, vestL); c.rect(32, 35, 3, 2, vestL)
    c.rect(18, 37, 20, 1, C(0x1A1A1C))
    c.px(16, 33, C(0x3A7ACC)); c.px(16, 34, C(0x3A7ACC))   // the patch on his sleeve
    // A short sandy crew cut: bristles standing up off a thin layer close to his scalp, a ragged top edge and the
    // hairline cut short and high at the temples, so it reads as hair and not a cap.
    c.pattern(18, 23, [
        "..l.H.l.H.lH.H.l.H..",
        ".HlHHlHHlHHlHHlHHlH.",
        "HHHHHHHHHHHHHHHHHHHH",
        "HHd..............dHH",
        "Hd................dH",
    ], ["H": hair, "l": hairL, "d": hairD])

    if saluteK >= 0 {
        // The rifle grounded upright by his left side, held at the muzzle.
        let gun = C(0x3A3E44), gunD = C(0x26282C)
        c.rect(12, 24, 2, 19, gun); c.rect(13, 24, 1, 19, gunD); c.rect(11, 30, 1, 4, C(0x3A8CFF))
        c.rect(14, 32, 2, 3, clawdOrange)
        if salute {
            // The salute: his arm bent up from the shoulder, the forearm angled in, and the hand a flat blade at his
            // brow, fingers to the hairline; eyes front, chin up.
            c.rect(38, 27, 3, 4, camo); c.rect(37, 25, 3, 2, camo); c.px(40, 27, camoD)
            c.rect(32, 24, 6, 2, clawdOrange); c.rect(32, 25, 6, 1, clawdShade); c.px(31, 24, clawdOrange)
        }
        return
    }
    c.oy += p.gunY
    // The taser rifle, held level at the hip: a long grey stock, a raised sight rail, the blue-lit coil in its housing
    // and a twin-pronged muzzle.
    let lit = p.fire.map { frac($0.t / p.firePeriod) < 0.3 } ?? false
    c.rect(38, 33, 3, 3, camo)
    c.pattern(34, 29, [
        "..........KKKK..........",
        "........KKKKKKKKKKK.....",
        "SSSSSS.KKbBbBbBbKKKKKKKN",
        "SSSSSSKKKKKKKKKKKKKKKKK.",
        "LSSSS..KKK..KK.........N",
        ".SS......K..............",
    ], ["K": C(0x34383E), "S": C(0x4A4E56), "L": C(0x5E636C), "b": lit ? C(0xBEE0FF) : C(0x2E6CC8),
        "B": lit ? white : C(0x8ABEFF), "N": C(0x9AA4B0)])
    c.rect(40, 32, 2, 3, clawdOrange)
}

// MARK: - Jonathan Levinsun

/// Jonathan Levinsun, "Superstar": short Clawd with a mop of tight brown curls, in a black tuxedo with satin lapels, a
/// white shirt and a black bow tie, black trousers with a satin stripe and shiny shoes. He doesn't fight. Signature:
/// the Class Protector award he gave Buffy at the prom: he lifts the little gold umbrella up high, it pops open and
/// glints, and he beams.
private func drawJonathanLevinsun(_ c: PixelCanvas, _ p: Pose) {
    let tux = C(0x1E1E28), tuxD = C(0x121218), satin = C(0x4A4A5E), shirt = C(0xF4F2EE)
    let hair = C(0x5A3A24), hairL = C(0x7E5636), hairD = C(0x3A2416)
    let k = h4Span(p, 0.06, 0.94)
    let lift = h4Hold(k, edge: 0.22)

    drawLegs(c, Look(leg: C(0x4C4C62)), step: p.step)
    if !seatedPose {
        // The satin stripe down the outside seam of each trouser leg only (the outer leg of each pair), not one down
        // every leg, which striped the four legs like a zebra.
        for (i, lx) in [19, 36].enumerated() {
            let lifted = p.step >= 0 && (i == 0 ? 0 : 1) == p.step
            c.rect(lx, lifted ? 36 : 37, 1, 5, C(0x66667E))
        }
    }
    slayerBoots(c, step: p.step, C(0x0C0C10), height: 1)
    if !seatedPose { for lx in [20, 24, 32, 36] { c.px(lx, 43, C(0x8A8A9A)) } }
    c.oy += p.breathe
    let raise = Int((lift * 9).rounded())
    drawBody(c, Look(arm: tux), armRight: raise)
    // The tuxedo jacket, satin lapels, the shirt front and the bow tie.
    c.rect(18, 33, 20, 5, tux); c.rect(37, 33, 1, 5, tuxD); c.rect(18, 37, 20, 1, tuxD)
    c.rect(25, 33, 6, 5, shirt); c.px(28, 35, tuxD); c.px(28, 37, tuxD)
    c.pattern(23, 33, ["SS......SS", ".SS....SS.", "..S....S.."], ["S": satin])
    c.pattern(26, 33, ["BB.BB", ".BBB."], ["B": C(0x0A0A0E)])
    // A mop of tight brown curls, sitting low.
    c.pattern(16, 21, [
        ".....H.lH.H.HlH.H.......",
        "...HlHHHlHHHlHHHlHH.....",
        "..HHlHHHHHlHHHHHlHHHH...",
        ".HlHHHlHHHHHlHHHHHlHHH..",
        ".HHHlHHHlHHHHHlHHHHHlH..",
        ".HdH.dHH..dHH..HHd.HdH..",
        "..dH...............Hd...",
    ], ["H": hair, "l": hairL, "d": hairD])

    if k >= 0 {
        // Beaming, eyes crinkled.
        if lift > 0.6 {
            c.rect(22, 29, 2, 3, clawdOrange); c.rect(32, 29, 2, 3, clawdOrange)
            c.pattern(21, 29, [".XX.", "X..X"], ["X": ink]); c.pattern(31, 29, [".XX.", "X..X"], ["X": ink])
        }
        // The little gold umbrella in his fist: furled as he lifts it, popping open up high.
        let gold = C(0xE8B830), goldL = C(0xFFE07A), goldD = C(0xB08418)
        let hx = 40, hy = 33 - raise
        c.rect(hx - 1, hy, 3, 3, clawdOrange)
        c.rect(hx, hy - 6, 1, 6, goldD); c.px(hx - 1, hy + 3, goldD); c.px(hx, hy + 3, goldD)
        if lift > 0.75 {
            c.pattern(hx - 5, hy - 10, [
                ".....P.....",
                "...GGLGG...",
                ".GGGGLGGGG.",
                "GGGGGLGGGGG",
                "D.D.D.D.D.D",
            ], ["P": goldD, "G": gold, "L": goldL, "D": goldD])
            if Int(p.t * 4) % 3 == 0 {
                c.px(hx + 4, hy - 13, white); c.px(hx + 3, hy - 12, goldL.alpha(0.5)); c.px(hx + 5, hy - 12, goldL.alpha(0.5))
            }
        } else {
            c.rect(hx - 1, hy - 9, 3, 4, gold); c.rect(hx - 1, hy - 9, 1, 4, goldL); c.px(hx, hy - 10, goldD)
        }
        return
    }
    h4Wave(c, p, sleeve: tux)
}
