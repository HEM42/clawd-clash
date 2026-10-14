import Foundation

// Heroes: the rest of the Fellowship and the Lady of the wood. Every one of them is Clawd in costume: the wizard's hat
// and beard, the ranger's coat, the elf's hair, the dwarf's helmet and beard, the captain's fur collar, the Lady's gown,
// drawn over and around the blocky body. The face is Clawd's own orange, and the eyes stay ink. Gimmie is drawn
// shorter than the Men and broader (`headTop` and his axe hand moved to match); the rest stand Clawd's full height.

let ringsHeroes2: [LOTRHero: Persona] = [
    .gandalf: Persona(name: "Gandclawd the Grey", weapon: .lightning, magic: Magic(core: C(0xFFFFFF), glow: C(0xBFD8FF), jagged: false),
                      pivot: gandalfStaffHead, headTop: 12, signature: 3.0, callout: "A wizard is never late.", draw: drawGandalf),
    .aragorn: Persona(name: "Arrogorn", weapon: .saber, headTop: 20, callout: "For Frodough!", draw: drawAragorn),
    .legolas: Persona(name: "Leggolas", weapon: .blaster, shot: .arrow, muzzle: (46, 34), handGun: false, headTop: 20,
                      signature: 3.0, callout: "A red sun rises.", draw: drawLegolas),
    .gimli: Persona(name: "Gimmie, son of Groan", weapon: .saber, pivot: gimliHand, headTop: 25, signature: 2.6,
                    callout: "And my axe!", draw: drawGimli),
    .boromir: Persona(name: "Boromeme", weapon: .saber, headTop: 20, signature: 3.4, callout: "One does not simply push to main.",
                      draw: drawBoromir),
    .galadriel: Persona(name: "Gladriel", weapon: .lightning, motion: .hover, magic: Magic(core: C(0xFFFFFF), glow: C(0x9FE8FF), jagged: false),
                        headTop: 19, signature: 3.0, callout: "Even the smallest Clawd can change the course of the future.",
                        draw: drawGaladriel),
]

// MARK: - Gandclawd

/// Where Gandclawd's magic leaves from: the knot at the head of his staff, which he brings round in front of him to cast.
private let gandalfStaffHead: (x: Double, y: Double) = (44.5, 15.5)

/// When the staff hits the floor in his signature.
private let gandalfImpact = 0.29

/// Gandclawd the Grey: a grey robe to the ankles, a tall crooked pointy hat with a wide brim, its tip bent back, grey
/// hair under it, bushy brows and a long white-grey beard over the chest. A gnarled wooden staff stands in his off
/// hand, always, planted on the floor; to cast he brings it round in front of him, held up in his casting hand, and
/// the magic leaves its head. Signature: "You shall not pass!": he raises the staff high in both hands (…0.25), slams
/// it down (the floor shakes, a white shock ring spreads out over it from the staff's foot and, for a frame, he flashes
/// white), and holds it there, planted, while the ring fades.
private func drawGandalf(_ c: PixelCanvas, _ p: Pose) {
    guard let s = p.signature else { drawGandalfBody(c, p, sig: nil); return }
    let ring: Double? = s >= gandalfImpact ? (s - gandalfImpact) / (1 - gandalfImpact) : nil
    if let k = ring { drawShockRing(c, k, front: false) }
    let oy = c.oy
    if s >= gandalfImpact && s < gandalfImpact + 0.025 {
        layer(c, flash: 0.75) { drawGandalfBody($0, p, sig: s) }
    } else {
        drawGandalfBody(c, p, sig: s)
    }
    c.oy = oy
    if let k = ring { drawShockRing(c, k, front: true) }
}

/// How high the staff is lifted `s` through the signature: raised (…0.2), held up, slammed down (…the impact).
private func gandalfLift(_ s: Double) -> Double {
    if s < 0.2 { return 9 * smooth(s / 0.2) }
    if s < 0.25 { return 9 }
    if s < gandalfImpact { let u = (s - 0.25) / (gandalfImpact - 0.25); return 9 * (1 - u * u) }
    return 0
}

private func drawGandalfBody(_ c: PixelCanvas, _ p: Pose, sig: Double?) {
    let robe = C(0x8A8C92), robeShade = C(0x5E6066), robeLight = C(0xA2A4AA)
    let hat = C(0x7A7C82), hatShade = C(0x5E6066), hatLight = C(0x96989E)
    let beard = C(0xD8D8D4), beardShade = C(0xB0B0AA), hair = C(0xC4C4C0), hairShade = C(0x9C9C98)
    // Casting (or in the signature) the staff comes round in front, in his casting hand.
    let forward = sig != nil || p.zap != nil || p.armRaise > 0
    let up = sig.map { Int(gandalfLift($0).rounded()) } ?? p.armRaise
    drawLegs(c, Look(leg: robeShade), step: p.step)
    drawBoots(c, p.step, C(0x3A3632), rows: 1)
    c.oy += p.breathe
    if let s = sig, s >= gandalfImpact, s < gandalfImpact + 0.06 { c.oy += 1 }   // the jolt of the blow
    if !forward { drawGandalfStaff(c) }
    drawBody(c, Look(arm: robe))
    // The robe, the shoulders to the ankles, flaring a little, with a fold or two.
    c.rect(18, 32, 20, 6, robe)
    c.rect(37, 32, 1, 6, robeShade)
    for y in 38...41 where y + c.oy <= 43 {
        let k = y - 38, l = 17 - (k + 1) / 2, r = 38 + (k + 1) / 2
        c.rect(l, y, r - l + 1, 1, robe)
        c.px(l, y, robeLight); c.px(r, y, robeShade)
        c.px(24, y, robeShade); if y > 38 { c.px(32, y, robeShade) }
    }
    // Grey hair falling from under the brim to the shoulders, and bushy brows.
    c.pattern(16, 26, ["HHH", "HhH", "HHH", "hHH", "HHH", ".Hh", ".H."], ["H": hair, "h": hairShade])
    c.pattern(37, 26, ["HHH", "HhH", "HHH", "HHh", "HHH", "hH.", ".H."], ["H": hair, "h": hairShade])
    c.rect(21, 28, 4, 1, beard); c.rect(31, 28, 4, 1, beard)
    // The long beard over the robe, to a point below the belt (folded on his lap when he sits).
    let beardRows: [String] = [
        ".HHHHHHHHHHHHHH.",
        "HHHhHHHHHHHHhHHH",
        "bHHHHHHhHHHHHHHb",
        ".bHHhHHHHHHhHHb.",
        "..bHHHHHHhHHHb..",
        "..bHHhHHHHHHHb..",
        "...bHHHHHhHHb...",
        "....bHHHHHHb....",
        ".....bHhHHb.....",
        "......bHHb......",
    ]
    c.pattern(20, 32, Array(beardRows.prefix(max(0, 43 - c.oy - 32 + 1))), ["H": beard, "h": beardShade, "b": C(0x9C9C96)])
    // The hat: a wide brim, a band and the tall crooked cone, its tip bent back.
    let cone: [(y: Int, l: Int, r: Int)] = [
        (12, 17, 20), (13, 19, 23), (14, 21, 25), (15, 22, 27), (16, 23, 28), (17, 23, 29), (18, 23, 30), (19, 22, 31),
        (20, 22, 32), (21, 21, 33), (22, 21, 34),
    ]
    for row in cone {
        c.rect(row.l, row.y, row.r - row.l + 1, 1, hat)
        c.px(row.l, row.y, hatLight); c.px(row.r, row.y, hatShade)
    }
    c.rect(16, 13, 2, 1, hat); c.px(16, 14, hatShade)                        // the bent tip, hanging back
    c.rect(20, 23, 16, 1, hatShade)                                           // the band
    c.rect(14, 24, 28, 1, hat); c.px(14, 24, hatLight)
    c.rect(15, 25, 26, 1, hatShade)                                           // the brim's underside
    guard forward else { return }
    // The staff in front, the casting arm up along it (both hands on it in the signature), a smear over a slam.
    if let s = sig, s > 0.25, s < gandalfImpact + 0.02 {
        let before = gandalfLift(max(0, s - 0.03))
        c.glowLine(gandalfStaffHead.x, gandalfStaffHead.y - before, gandalfStaffHead.x, gandalfStaffHead.y - Double(up),
                   core: C(0xE8ECF4, 0.5), glow: clear, coreR: 1.6, glowR: 1.7)
    }
    drawGandalfStaffForward(c, up: up)
    let reach = sig == nil ? 0 : 3                                            // the other hand, above it
    c.rect(38, 33 - up - reach, 4, 3 + up + reach, robe); c.rect(38, 35, 4, 1, robeShade)
    c.rect(42, 33 - up, 3, 3, clawdOrange); c.px(42, 35 - up, clawdShade)
    if reach > 0 { c.rect(42, 30 - up, 3, 3, clawdOrange); c.px(42, 32 - up, clawdShade) }
}

/// Gandclawd's staff in his off hand: a gnarled shaft of old wood with a knot or two, its head a twist of roots, and
/// its foot on the floor.
private func drawGandalfStaff(_ c: PixelCanvas) {
    let wood = C(0x6A4A2A), dark = C(0x4A321C), light = C(0x8A6A44)
    let bottom = 43 - c.oy
    c.pattern(10, 13, [
        ".DWW.",
        "W..WD",
        "W.W.W",
        ".WW.W",
        "...WW",
        "...W.",
    ], ["W": wood, "D": dark])
    c.px(11, 13, light); c.px(10, 14, light)
    c.rect(13, 19, 1, 8, wood)
    c.rect(14, 27, 1, max(0, bottom - 26), wood)
    c.px(13, 26, dark); c.px(14, 26, wood)
    c.px(13, 22, dark); c.px(14, 30, light); c.px(14, 38, dark); c.px(13, 23, light)
    c.rect(12, 33, 3, 3, clawdOrange); c.px(12, 35, clawdShade)               // his fist round it
}

/// The same staff brought round in front of him, lifted `up` pixels: the head turned forward, the shaft at x 43.
private func drawGandalfStaffForward(_ c: PixelCanvas, up: Int) {
    let wood = C(0x6A4A2A), dark = C(0x4A321C), light = C(0x8A6A44)
    let top = 13 - up, bottom = 43 - c.oy - up
    c.pattern(42, top, [
        ".WWD.",
        "DW..W",
        "W.W.W",
        "W.WW.",
        "WW...",
        ".W...",
    ], ["W": wood, "D": dark])
    c.px(45, top, light); c.px(46, top + 1, light)
    c.rect(43, top + 6, 1, max(0, bottom - top - 5), wood)
    c.px(43, top + 9, dark); c.px(43, top + 10, light); c.px(43, top + 17, light); c.px(43, top + 25, dark)
}

/// The shock ring of the staff's blow on the floor round its foot, `k` 0…1 through spreading out and fading. The far
/// half (`front: false`) goes behind him, the near half in front.
private func drawShockRing(_ c: PixelCanvas, _ k: Double, front: Bool) {
    let a: Double = pow(1 - k, 0.6)
    guard a > 0.03 else { return }
    let cx = 43.5, cy = 43.0
    let rx: Double = 2 + 25 * (1 - (1 - k) * (1 - k)), ry: Double = max(1, rx * 0.18)
    var prev: Int?
    for x in Int(floor(cx - rx))...Int(ceil(cx + rx)) {
        let u = (Double(x) + 0.5 - cx) / rx
        guard abs(u) <= 1 else { prev = nil; continue }
        let dy = ry * (1 - u * u).squareRoot()
        let y = Int((front ? cy + dy : cy - dy).rounded())
        let from = prev ?? y
        for yy in min(from, y)...max(from, y) where yy == y || abs(yy - y) < abs(from - y) {
            c.px(x, yy, C(0xFFFFFF, a))
            c.px(x, yy + (front ? -1 : 1), C(0xBFD8FF, a * 0.45))             // a softer edge inside
        }
        prev = y
    }
}

// MARK: - Arrogorn

/// Arrogorn, the ranger: a weathered green-brown coat to mid-thigh over dark trousers and boots, a leather baldric across
/// the chest, a dark cloak, dark shaggy hair to the shoulders and two dark pixels of stubble on the jaw. His long sword
/// is slung across his back, the hilt over his shoulder; to fight he draws it, and it swings in his fist with a smear
/// behind a fast stroke. No signature.
private func drawAragorn(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x3A3A32), coatShade = C(0x2A2A24), coatLight = C(0x4E4E44)
    let hair = C(0x2A2018), hairLight = C(0x46362A), leather = C(0x5A4430)
    drawBackCape(c, t: p.t, speed: p.capeSpeed, color: C(0x262A20), edge: C(0x181A14), hem: 42)
    drawLegs(c, Look(leg: C(0x3E3428)), step: p.step)
    drawBoots(c, p.step, C(0x241A12), rows: 3)
    c.oy += p.breathe
    drawBody(c, Look(arm: coat))
    // The coat: the collar to mid-thigh, open below the belt.
    c.rect(18, 33, 20, 5, coat)
    c.rect(37, 33, 1, 5, coatShade)
    c.rect(18, 33, 20, 1, coatLight)
    for y in 38...39 where y + c.oy <= 43 {
        c.rect(18, y, 20, 1, coat); c.px(27, y, coatShade); c.px(28, y, coatShade); c.px(37, y, coatShade)
    }
    c.rect(18, 36, 20, 1, leather); c.px(26, 36, C(0x9A8A6A))               // the belt and its buckle
    for i in 0..<5 { c.rect(33 - i * 3, 33 + i, 3, 1, leather) }              // the baldric
    c.rect(15, 33, 3, 3, coat)
    // The shaggy hair, to the shoulders, framing the face: a ragged fringe on the brow, the sides outside the face.
    c.pattern(16, 20, [
        ".....H.HHH.HHHH.HH.H....",
        "...HHHHHHHHHHHHHHHHHH...",
        ".HHHHlHHHHHHHHHHlHHHHHH.",
        ".HHlHHHHHlHHHHHHHHlHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHlHHHHHHlHHHHHHHHHH",
        "HHHHl..H......H.....HHHH",
        "HHH..................HHH",
        "HHl..................lHH",
        "HH....................HH",
        "HH....................HH",
        "Hl....................lH",
        "HH....................H.",
        "..H..................H.H",
    ], ["H": hair, "l": hairLight])
    c.px(25, 32, ink); c.px(30, 32, ink)                                     // the stubble
    guard let a = p.melee else { drawBackSword(c); return }
    drawLongSword(c, angle: a, trail: p.trail)
    c.rect(38, 33, 2, 3, coat); c.rect(40, 33, 2, 3, clawdOrange); c.px(40, 35, clawdShade)   // the fist round the grip
}

/// Arrogorn's long sword drawn, in his fist at `angle`: a leather grip and steel pommel, a steel crossguard and a long
/// (16 px) blade with a darker edge, and a pale smear along `trail` behind a fast stroke.
private func drawLongSword(_ c: PixelCanvas, angle: Double, trail: [Double]) {
    let hand = Sprite.hand, steel = C(0xC8D0D8), edge = C(0x8A929C)
    for (i, a) in trail.enumerated() {
        let u = unit(a)
        c.glowLine(hand.x + u.x * 4, hand.y + u.y * 4, hand.x + u.x * 18, hand.y + u.y * 18, core: C(0xE8EEF4),
                   glow: C(0xA8B4C0), coreR: 0.5, glowR: 1.6, strength: 0.32 / Double(i + 1))
    }
    let u = unit(angle), n = (x: -u.y, y: u.x)
    line(c, hand.x - u.x * 2.5, hand.y - u.y * 2.5, hand.x + u.x * 1.5, hand.y + u.y * 1.5, C(0x3A2A1E), 0.7)   // the grip
    c.px(Int((hand.x - u.x * 3).rounded(.down)), Int((hand.y - u.y * 3).rounded(.down)), steel)                // the pommel
    line(c, hand.x + u.x * 3, hand.y + u.y * 3, hand.x + u.x * 18, hand.y + u.y * 18, steel, 0.75)
    line(c, hand.x + u.x * 3 + n.x * 0.6, hand.y + u.y * 3 + n.y * 0.6, hand.x + u.x * 17 + n.x * 0.6,
         hand.y + u.y * 17 + n.y * 0.6, edge, 0.3)
    let g = (x: hand.x + u.x * 2.5, y: hand.y + u.y * 2.5)
    line(c, g.x - n.x * 2.5, g.y - n.y * 2.5, g.x + n.x * 2.5, g.y + n.y * 2.5, C(0x8A8E96), 0.6)              // the crossguard
}

/// Arrogorn's long sword, slung on his back: the pommel and grip over his shoulder, the crossguard, and the blade sloping
/// down and back behind him.
private func drawBackSword(_ c: PixelCanvas) {
    let steel = C(0xC8D0D8), edge = C(0x8A929C)
    let u = unit(120), n = (x: -u.y, y: u.x)
    let g = (x: 15.0, y: 24.0)                                               // the crossguard's middle
    line(c, g.x - u.x * 4, g.y - u.y * 4, g.x - u.x, g.y - u.y, C(0x3A2A1E), 0.6)   // the grip
    c.px(Int(g.x - u.x * 4.5), Int(g.y - u.y * 4.5), steel)                   // the pommel
    line(c, g.x + u.x, g.y + u.y, g.x + u.x * 16, g.y + u.y * 16, steel, 0.7)
    line(c, g.x + u.x + n.x * 0.6, g.y + u.y + n.y * 0.6, g.x + u.x * 15 + n.x * 0.6, g.y + u.y * 15 + n.y * 0.6, edge, 0.3)
    line(c, g.x - n.x * 2.5, g.y - n.y * 2.5, g.x + n.x * 2.5, g.y + n.y * 2.5, C(0x8A8E96), 0.6)
}

// MARK: - Leggolas

/// Leggolas, the elf: a green tunic, a light-grey cloak, soft boots, long straight blond hair to the shoulders with a
/// pointed ear poking out of it either side, a quiver of arrows on his back and a longbow in his hand, held out in
/// front of him. Shooting, he nocks an arrow and draws the string back before each shot. Signature: he surfs on a
/// shield: hops up onto it (…0.15), rides it sideways, arms out, sliding back and forth with a little bob, and hops
/// off again at the end.
private func drawLegolas(_ c: PixelCanvas, _ p: Pose) {
    let tunic = C(0x5E7A3A), tunicShade = C(0x46602A), tunicLight = C(0x7A9650)
    let hair = C(0xF0E0A0), hairShade = C(0xD0BC78)
    let surf = p.signature.map(legolasSurf)
    let ground = (x: c.ox, y: c.oy)
    if let s = surf { c.ox += s.dx; c.oy -= s.lift }
    drawBackCape(c, t: p.t, speed: p.capeSpeed, color: C(0xA8ACB0), edge: C(0x8A8E94), hem: 41)
    drawLegs(c, Look(leg: C(0x4A4A3A)), step: p.step)
    drawBoots(c, p.step, C(0x6A5232), rows: 3)
    if let s = surf {
        // The shield on the floor, sliding along under him.
        let (ox, oy) = (c.ox, c.oy)
        c.ox = ground.x + s.board; c.oy = ground.y
        drawSurfShield(c, alpha: s.shield)
        c.ox = ox; c.oy = oy
    }
    c.oy += p.breathe
    // The quiver, slung over his back, the fletchings over his shoulder.
    c.pattern(11, 18, [
        "W.G.....",
        "GW.W....",
        ".GWG....",
        "..QQQ...",
        "..QQQq..",
        "...QQQq.",
        "...QQQQ.",
        "....QQQq",
        "....QQQQ",
        ".....QQq",
        ".....QQQ",
    ], ["G": C(0x8AC86A), "W": C(0xE8E0D0), "Q": C(0x6A4A2A), "q": C(0x4E3420)])
    drawBody(c, Look(arm: tunic))
    c.rect(18, 32, 20, 6, tunic)
    c.rect(37, 32, 1, 6, tunicShade)
    c.rect(18, 32, 20, 1, tunicLight)
    for y in 38...39 where y + c.oy <= 43 { c.rect(18, y, 20, 1, tunic); c.px(37, y, tunicShade) }
    c.rect(18, 36, 20, 1, C(0x6A4A2A)); c.px(27, 36, C(0xC8D0D8))           // the belt
    for i in 0..<5 { c.rect(21 + i * 3, 37 - i, 3, 1, C(0x6A4A2A)) }          // the quiver strap
    if surf?.armsOut == true {
        c.rect(11, 31, 6, 2, tunic); c.rect(10, 31, 1, 2, clawdOrange)          // the back arm out, for balance
    } else {
        c.rect(15, 33, 3, 3, tunic)
    }
    // Long straight hair, parted in the middle, to the shoulders.
    c.pattern(16, 20, [
        ".......HHHHHHHHHH.......",
        "....HHHHHHHHHHHHHHHH....",
        "..HHHHHHHHHhHHHHHHHHHH..",
        ".HHHHHHHHHhhHHHHHHHHHHH.",
        ".HHhHHHHHHhHHHHHHHHHhHH.",
        "HHHhHHHHHh...hHHHHHHhHHH",
        "HHHhh..............hhHHH",
        "HHhH................HhHH",
        "HHh..................hHH",
        "HHh..................hHH",
        "HHh..................hHH",
        "HHh..................hHH",
        "HHh..................hHH",
        "HHh..................hHH",
        ".Hh..................hH.",
    ], ["H": hair, "h": hairShade])
    // The pointed ears, a pixel of skin past the hair.
    c.px(15, 28, clawdOrange); c.px(40, 28, clawdOrange)
    // The longbow, held out at arm's length; an arrow on the string while he aims, drawn back before he shoots.
    var pull = 0, nocked = p.ready
    if let f = p.fire {
        let ph = frac(f.t / p.firePeriod)
        nocked = ph >= 0.45
        if ph > 0.6 { pull = Int(((ph - 0.6) / 0.4 * 3).rounded()) }
    }
    let raise = seatedPose ? -3 : surf?.armsOut == true ? -2 : 0
    c.oy += p.gunY + raise
    drawLongbow(c, pull: pull)
    c.rect(38, 33, 4, 2, tunic)
    c.rect(42, 33, 2, 3, clawdOrange)
    if nocked {
        let tail = 40 - pull
        c.rect(tail, 34, 47 - tail, 1, C(0x6A4A2A))
        c.px(47, 34, C(0xC8CCD4)); c.px(48, 34, C(0xE8ECF4))
        c.px(tail, 33, C(0xC83A2A)); c.px(tail, 35, C(0xC83A2A))
        c.rect(tail - 1, 34, 2, 2, clawdOrange)                                // the hand on the string
    }
}

/// A tall wooden longbow gripped at (43, 34), the string back at x 40, drawn back `pull` pixels more at the middle.
private func drawLongbow(_ c: PixelCanvas, pull: Int = 0) {
    let limb = C(0x8A6A3A), limbDark = C(0x6A4E28), grip = C(0x4A3420), string = C(0xE0E0E8)
    for y in 24...44 where y + c.oy <= 43 {
        let d = abs(y - 34)
        let x = d <= 2 ? 44 : d <= 5 ? 43 : d <= 8 ? 42 : 41
        c.px(x, y, d <= 1 ? grip : d % 3 == 0 ? limbDark : limb)
        if d == 10 { c.px(x - 1, y, limb) }
    }
    for y in 25...43 where y + c.oy <= 43 {
        let d = Double(abs(y - 34)) / 9
        c.px(40 - Int((Double(pull) * (1 - d)).rounded()), y, string)
    }
}

/// Where Leggolas is `s` through his surf: shifted `dx` and lifted `lift` (on the shield, 3 px up), the shield shifted
/// `board` and faded to `shield`, and whether his arms are out for balance.
private func legolasSurf(_ s: Double) -> (dx: Int, lift: Int, board: Int, shield: Double, armsOut: Bool) {
    if s < 0.15 {
        let u = s / 0.15
        let lift: Double = 3 * smooth(u) + 5 * sin(u * .pi)
        return (0, Int(lift.rounded()), 0, min(1, s / 0.04), u > 0.3)
    }
    if s < 0.85 {
        let u = (s - 0.15) / 0.7
        let tau: Double = 2 * .pi
        let dx = Int((6 * sin(u * tau)).rounded())
        let bob = sin(u * tau * 5) > 0.4 ? 1 : 0
        return (dx, 3 + bob, dx, 1, true)
    }
    let u = (s - 0.85) / 0.15
    let lift: Double = 3 * (1 - smooth(u)) + 4 * sin(u * .pi)
    return (0, Int(lift.rounded()), 0, 1 - smooth(u), u < 0.7)
}

/// The shield he surfs on, lying on the floor under his feet: a wooden oval with a gold rim.
private func drawSurfShield(_ c: PixelCanvas, alpha: Double) {
    let wood = C(0x8A6A3A, alpha), dark = C(0x6A4E28, alpha), rim = C(0xC8A040, alpha), rimDark = C(0x9A7A2A, alpha)
    c.rect(19, 41, 18, 1, rim)
    c.rect(17, 42, 22, 1, wood); c.px(17, 42, rim); c.px(38, 42, rim)
    c.rect(22, 42, 1, 1, dark); c.rect(33, 42, 1, 1, dark); c.rect(27, 42, 2, 1, C(0xC8D0D8, alpha))   // boards, boss
    c.rect(19, 43, 18, 1, rimDark)
}

// MARK: - Gimmie

/// Where Gimmie's hand holds the axe: lower than a Man's, he's shorter.
private let gimliHand: (x: Double, y: Double) = (42.5, 36.5)

/// Gimmie, son of Groan, the dwarf: shorter than the Men (his helmet's top is where their brows are) and broader, short
/// thick legs in heavy boots, chain mail over everything, an iron helmet with cheek guards, and a huge braided red beard
/// down to the belt. His double-bladed axe stands in his fist, its head up by his shoulder; it's heavy, so a swing
/// smears a long way behind it. Signature: "Nobody tosses a dwarf!": the axe leant against his back, he crosses his
/// arms and shakes his head (…0.3), holds one hand up to stop you (…0.7) and stamps his foot.
private func drawGimli(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature.flatMap { $0 > 0.03 && $0 < 0.97 ? $0 : nil }
    let crossed = sig.map { $0 < 0.3 } ?? false, stop = sig.map { $0 >= 0.3 && $0 < 0.7 } ?? false
    let lifted = sig.map { $0 >= 0.7 && $0 < 0.8 } ?? false, stamped = sig.map { $0 >= 0.8 && $0 < 0.9 } ?? false
    if let s = sig, crossed, s > 0.05 { c.ox += Int(s * 2.6 * 9) % 2 == 0 ? 1 : -1 }   // shaking his head
    if lifted { c.oy -= 1 }
    let helm = C(0x8A8C92), helmDark = C(0x6A6C72), helmLight = C(0xAEB0B6)
    let beard = C(0xB8501E), beardDark = C(0x8A3A16), beardLight = C(0xD8703A), tie = C(0xC8A040)
    let mail = C(0x6A6E78), mailDark = C(0x4E525A), mailLight = C(0x8A8E98)
    let trousers = C(0x4A3A2A), boot = C(0x3A2A1A), leather = C(0x5A3A1E)
    // Short thick legs in heavy boots, the toes forward.
    if seatedPose {
        for lx in [19, 23, 32, 36] { c.rect(lx - 1, 39, 4, 1, boot); c.px(lx + 2, 39, C(0x4E3A26)) }
    } else {
        for (i, lx) in [19, 23, 32, 36].enumerated() {
            let bottom = lifted && i == 3 ? 40 : p.step >= 0 && i % 2 == p.step ? 42 : 43
            c.rect(lx, 37, 3, bottom - 38, trousers)
            c.rect(lx, bottom - 1, 3, 2, boot); c.px(lx + 3, bottom, boot)
            c.px(lx, bottom - 1, C(0x4E3A26))
        }
        if stamped {
            // Dust kicked up round the stamped foot.
            for (dx, dy) in [(-2, 0), (4, 0), (-1, -1), (5, -1), (6, 0)] { c.px(36 + dx, 43 + dy - c.oy, C(0xC8B89A, 0.6)) }
        }
    }
    c.oy += p.breathe
    if sig != nil { drawGimliAxe(c, at: (14.5, 38.5 - Double(c.oy)), angle: -100) }   // leant against his back
    // The body: broader than Clawd's and lower down, the arms in mail.
    c.rect(17, 28, 22, 11, clawdOrange)
    c.rect(38, 28, 1, 11, clawdShade)
    if !crossed { c.rect(14, 35, 3, 3, mail); c.px(14, 37, mailDark) }
    c.rect(22, 30, 2, 3, ink); c.rect(32, 30, 2, 3, ink)
    // Chain mail from the chin down.
    for y in 33...38 {
        for x in 17...38 { c.px(x, y, x == 38 || y == 38 ? mailDark : (x + y) % 2 == 0 ? mailLight : mail) }
    }
    // The helmet: an iron dome, a riveted rim and cheek guards.
    c.pattern(17, 25, [
        "....HHHHHHHHHHHHHH....",
        "..HHHHlHHHHHHHHHHHHH..",
        ".HHlHHHHHHHHHHHHHHHHD.",
        "DDDDDDDDDDDDDDDDDDDDDD",
        "HHH................HHH",
        "HlH................HHD",
        "HHH................HHD",
        ".HH................HD.",
    ], ["H": helm, "l": helmLight, "D": helmDark])
    for x in stride(from: 18, through: 38, by: 4) { c.px(x, 28, helmLight) }
    // The beard: sideburns down the cheeks, then a great red bush to the belt, two braids hanging below it.
    c.rect(20, 31, 1, 2, beard); c.rect(35, 31, 1, 2, beard)
    c.pattern(19, 33, [
        ".HHHHHHHHHHHHHHHH.",
        "HHHlHHHHHHHHHHlHHH",
        "HHHHHHdHHHHdHHHHHH",
        "HdHHHlHHHHHHlHHHdH",
        ".HHHdHHHHHHHHdHHH.",
        "..HHHHHdHHdHHHHH..",
        "....TT......TT....",
        "....HH......HH....",
        "....Hd......dH....",
    ], ["H": beard, "d": beardDark, "l": beardLight, "T": tie])
    c.rect(24, 33, 8, 1, beardDark)                                           // the moustache's edge
    if crossed {
        // Arms folded over the beard: the far forearm on top, the near one under it, the fists tucked in.
        c.pattern(14, 36, [
            "mMMMMMMMMMMMMMMMGG.......",
            ".......GGmMMMMMMMMMMMMMMm",
        ], ["M": mail, "m": mailDark, "G": leather, "g": C(0x3E2812)])
        return
    }
    if stop {
        // One gloved hand held up, palm out: stop right there.
        c.rect(39, 29, 3, 9, mail); c.rect(41, 29, 1, 9, mailDark)
        c.pattern(39, 24, ["O.O.O", "OOOOO", "OOOOO", "OOOOs", ".OOs."], ["O": clawdOrange, "s": clawdShade])
        return
    }
    if sig != nil { c.rect(39, 35, 3, 3, mail); return }
    // The axe, upright in his fist, swung with a long smear behind it; the floor stops a low stroke (his hand is low).
    let angle = min(5, p.melee ?? -65)
    for (i, a) in heavySmear(angle, p.melee == nil ? [] : p.trail.map { min(5, $0) }).enumerated() {
        let u = unit(a), n = (x: -u.y, y: u.x), fade: Double = 0.38 * (1 - Double(i) / 12)
        guard fade > 0.03 else { break }
        let m = (x: gimliHand.x + u.x * 10, y: gimliHand.y + u.y * 10)
        c.glowLine(m.x - n.x * 6, m.y - n.y * 6, m.x + n.x * 6, m.y + n.y * 6, core: C(0xD8E0E8), glow: C(0x9AA4B0),
                   coreR: 0.6, glowR: 1.4, strength: fade)
    }
    drawGimliAxe(c, angle: angle)
    c.rect(40, 35, 3, 3, leather); c.px(40, 37, C(0x3E2812))                  // the glove round the haft
}

/// Gimmie's axe: a long wooden haft with an iron butt, and a double-bladed iron head, each blade flaring to a wide edge.
private func drawGimliAxe(_ c: PixelCanvas, at: (x: Double, y: Double) = gimliHand, angle: Double) {
    prop(c, at: at, angle: angle) { s in
        let haft = C(0x5A3A1E), haftLight = C(0x7A5230), iron = C(0x9AA4B0), ironDark = C(0x6A727E), edge = C(0xD8E0E8)
        s.rect(17, 20, 15, 1, haft); s.rect(17, 21, 15, 1, C(0x40280E))
        s.rect(20, 20, 9, 1, haftLight)
        s.rect(16, 20, 1, 2, ironDark)
        s.pattern(27, 13, [
            "EEEEEE",
            "BBBBBB",
            ".BBBBb",
            ".BBBb.",
            "..BBb.",
            "..BB..",
            "..SSS.",
            "..SSSS",
            "..SSS.",
            "..BB..",
            "..BBb.",
            ".BBBb.",
            ".BBBBb",
            "BBBBBB",
            "EEEEEE",
        ], ["B": iron, "b": ironDark, "S": ironDark, "E": edge])
    }
}

// MARK: - Boromeme

/// Boromeme, captain of Gondor: a red-brown tunic belted over dark trousers and boots, a thick fur collar across the
/// shoulders, chestnut hair to the shoulders and the horn of Gondor, ivory with silver bands, hanging at his hip. A
/// round wooden shield on his off arm, a broad sword held low in his hand, swung with a smear behind a fast stroke.
/// Signature: the meme. He sticks the sword in the ground in front of him and lifts one hand to his shoulder, finger
/// and thumb in a ring ("One does not simply…", …0.2), holds it there with a little wobble every quarter of a second,
/// and lowers it at the end.
private func drawBoromir(_ c: PixelCanvas, _ p: Pose) {
    let tunic = C(0x7A2A2A), tunicShade = C(0x5A1E1E), tunicLight = C(0x9A3A36)
    let fur = C(0x6A5A4A), furDark = C(0x4E4236), furLight = C(0x8A7A68)
    let hair = C(0x6A3A1E), hairDark = C(0x4A2812), hairLight = C(0x8A5230)
    drawLegs(c, Look(leg: C(0x3A2C24)), step: p.step)
    drawBoots(c, p.step, C(0x2A1E16), rows: 3)
    c.oy += p.breathe
    drawBody(c, Look(arm: tunic))
    c.rect(18, 33, 20, 5, tunic)
    c.rect(37, 33, 1, 5, tunicShade)
    for y in 38...39 where y + c.oy <= 43 { c.rect(18, y, 20, 1, tunic); c.px(27, y, tunicShade); c.px(37, y, tunicShade) }
    c.rect(21, 34, 1, 2, tunicLight)
    c.rect(18, 36, 20, 1, C(0x3A2A1E)); c.px(27, 36, C(0xC8A040))           // the belt and its buckle
    // The fur collar, heavy across the shoulders.
    c.pattern(15, 33, [
        "..FfFFlFFfFFFFfFFlFFfFF...",
        ".FFFlFFfFFFlFFFFlFFFfFFFF.",
        "..dFF.dFF.FdF.FdF.dFF.d...",
    ], ["F": fur, "f": furDark, "l": furLight, "d": furDark])
    // Chestnut hair to the shoulders.
    c.pattern(16, 20, [
        ".......HHHHHHHHHH.......",
        "....HHHHHHHHHHHHHHHH....",
        "..HHHHlHHHHHHHHHHlHHHH..",
        ".HHHHHHHHHlHHHHHHHHHHHH.",
        ".HHlHHHHHHHHHHHHHHlHHHH.",
        "HHHHHHHHdHHHHHdHHHHHHHHH",
        "HHHHHd............dHHHHH",
        "HHHd................dHHH",
        "HHH..................HHH",
        "HHd..................dHH",
        "HHH..................HHH",
        ".Hd..................dH.",
    ], ["H": hair, "d": hairDark, "l": hairLight])
    // The horn of Gondor at his hip, its mouth forward.
    c.pattern(31, 36, [
        "Hh.......",
        ".HHs.....",
        "..HHHsHH.",
        "...hHHsHHH",
        "......HHH.",
    ], ["H": C(0xE8E0C8), "h": C(0xB8B098), "s": C(0xC8D0D8)])
    c.px(30, 36, C(0x3A2A1E))
    // The shield on his off arm, the sword held low.
    drawRoundShield(c, cx: 14, cy: seatedPose ? 33 : 34)
    if let s = p.signature, s > 0.03, s < 0.97 {
        drawBroadsword(c, at: (50.5, 28.5 - Double(c.oy)), angle: 90)                // stuck in the ground
        let k: Double = s < 0.2 ? smooth(s / 0.2) : s < 0.9 ? 1 : 1 - smooth((s - 0.9) / 0.1)
        let wobble = s >= 0.2 && s < 0.9 && Int(s * 3.4 / 0.25) % 2 == 1 ? 1 : 0
        let up = Int((4 * k).rounded())
        c.rect(38, 33 - up, 3, 3 + up, tunic); c.rect(38, 35, 3, 1, tunicShade)
        // The hand: finger and thumb in a ring, the other fingers up.
        c.pattern(40 + wobble, 29 - up, ["..O.O", ".OOOO", "O.OOO", ".OOOs", "..Os."], ["O": clawdOrange, "s": clawdShade])
        return
    }
    let angle = p.melee ?? (seatedPose ? 8 : 32)
    for (i, a) in (p.melee == nil ? [] : p.trail).enumerated() {
        let u = unit(a)
        c.glowLine(Sprite.hand.x + u.x * 4, Sprite.hand.y + u.y * 4, Sprite.hand.x + u.x * 15, Sprite.hand.y + u.y * 15,
                   core: C(0xE8EEF4), glow: C(0xA8B4C0), coreR: 0.8, glowR: 1.9, strength: 0.32 / Double(i + 1))
    }
    drawBroadsword(c, angle: angle)
    c.rect(38, 33, 3, 3, tunic); c.rect(40, 33, 2, 3, clawdOrange)
}

/// Boromeme's round shield on the off arm: wooden boards, an iron rim and a boss.
private func drawRoundShield(_ c: PixelCanvas, cx: Int, cy: Int) {
    let wood = C(0x8A6A3A), dark = C(0x6A4E28), rim = C(0x5A4428)
    c.ellipse(cx, cy, 5, 5, rim)
    c.ellipse(cx, cy, 4, 4, wood)
    for dx in [-2, 1, 3] { c.rect(cx + dx, cy - 3, 1, 7, dark) }
    c.rect(cx - 1, cy - 1, 3, 3, C(0x8A8E96)); c.px(cx - 1, cy - 1, C(0xC8CCD4))
    for (dx, dy) in [(-4, 0), (4, 0), (0, -4), (0, 4)] { c.px(cx + dx, cy + dy, C(0xA8ACB4)) }
}

/// A broad sword gripped at the hand: a leather grip, an iron pommel and crossguard, a wide steel blade with a fuller.
private func drawBroadsword(_ c: PixelCanvas, at: (x: Double, y: Double) = Sprite.hand, angle: Double) {
    prop(c, at: at, angle: angle) { s in
        let blade = C(0xC8CCD4), edge = C(0x8A8F9C), fuller = C(0xA8AEB8)
        s.rect(17, 20, 4, 1, C(0x4A3420)); s.px(16, 20, C(0x8A8E96))
        s.rect(21, 17, 1, 7, C(0x8A8E96)); s.px(21, 17, C(0xB8BCC4))
        s.rect(22, 19, 13, 3, blade)
        s.rect(22, 21, 13, 1, edge)
        s.rect(23, 20, 10, 1, fuller)
        s.px(35, 20, blade); s.px(35, 21, edge)
    }
}

// MARK: - Gladriel

/// Gladriel, the Lady of the wood: a long white gown that hides her legs and sweeps the ground (she hovers just above
/// it; the hem sways), long sleeves, long gold hair to the waist and a silver circlet with a pale gem. She casts from
/// her raised hand. Signature: she raises the Phial: her hand rises up past her face (…0.2), a star of light shines out
/// of it, pulsing (…0.8), and dims as she lowers it.
private func drawGaladriel(_ c: PixelCanvas, _ p: Pose) {
    let gown = C(0xE8ECF2), gownShade = C(0xB8C2CE), fold = C(0xD2D8E2)
    let hair = C(0xF4E0A0), hairShade = C(0xD4BC74), hairLight = C(0xFFF2C8), silver = C(0xC8D0D8)
    // The skirt, from the waist to the ground, flaring and swaying.
    for y in 36...43 where y + c.oy <= 43 {
        let k = Double(y - 36) / 7
        let hw: Double = 10.5 + k * 3
        let sway: Double = p.walking ? (p.step == 0 ? 1 : -1) * k : sin(p.lt * 1.6 + k * 2) * k * 1.2
        let l = Int((28 - hw - sway).rounded()), r = Int((28 + hw - sway).rounded()) - 1
        c.rect(l, y, r - l + 1, 1, gown)
        c.px(l, y, fold); c.px(r, y, gownShade)
        for f in [l + 5, Int((28 - sway).rounded()), r - 4] where y >= 38 { c.px(f, y, fold) }
        if y == 43 { c.rect(l, y, r - l + 1, 1, fold) }
    }
    c.oy += p.breathe
    // Her hair down her back, to the waist.
    c.pattern(14, 25, [
        "HHHH", "HhHH", "HHhH", "HHHH", "hHHH", "HHhH", "HHHH", "HhHH", "HHHH", "HHhH", ".HHH", ".HhH", "..HH",
    ], ["H": hair, "h": hairShade])
    let sig = p.signature
    let lift: Double = sig.map { s in s < 0.2 ? smooth(s / 0.2) : s < 0.8 ? 1 : 1 - smooth((s - 0.8) / 0.2) } ?? 0
    let phial = Int((7 * lift).rounded())
    drawBody(c, Look(arm: gown), armRight: max(p.armRaise, min(phial, 2)))
    // The bodice, a square neckline trimmed in silver, and a silver girdle.
    c.rect(18, 34, 20, 4, gown)
    c.rect(37, 34, 1, 4, gownShade)
    c.rect(20, 34, 16, 1, silver)
    c.rect(18, 33, 3, 1, gown); c.rect(35, 33, 3, 1, gown)
    c.rect(19, 36, 18, 1, silver); c.px(27, 37, silver); c.px(28, 37, silver)
    // Long sleeves: the back one hanging, the front one lifted with the hand.
    c.rect(14, 33, 4, 4, gown); c.rect(14, 36, 3, 2, gownShade); c.px(14, 33, fold)
    let a = p.armRaise
    c.rect(38, 33 - a, 3, 3, gown); c.rect(38, 36 - a, 3, 2, gownShade)
    c.rect(41, 33 - a, 1, 2, clawdOrange)
    // The hair over the head, down either side of the face, and the circlet.
    c.pattern(16, 19, [
        ".......HHHHHHHHHH.......",
        "....HHHHHHHlHHHHHHHH....",
        "..HHHHHHHlHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHlHHHHHH.",
        ".HHhHHHHHHHHHHHHHHHHhHH.",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHh................hHHH",
        "HHh..................hHH",
        "HHH..................HHH",
        "HHh..................hHH",
        "HHH..................HHH",
        "HHh..................hHH",
        "HHH..................HHH",
        ".HH..................HH.",
        ".Hh..................hH.",
        ".HH..................HH.",
        "..Hh................hH..",
        "..HH................HH..",
        "..H..................H..",
    ], ["H": hair, "h": hairShade, "l": hairLight])
    c.rect(17, 24, 22, 1, silver)
    c.px(27, 24, white); c.px(28, 24, C(0xBFEFFF))
    guard let s = sig, phial > 0 else { return }
    // The arm raised past her hair, the long sleeve falling from it, and the Phial in her hand.
    c.rect(39, 33 - phial, 3, phial + 3, gown); c.rect(41, 34 - phial, 1, phial + 2, gownShade); c.px(39, 33 - phial, fold)
    c.rect(41, 31 - phial, 2, 2, clawdOrange)
    let at = (x: 42.0, y: 30.5 - Double(phial))
    let shine: Double = s < 0.2 ? 0 : s < 0.26 ? (s - 0.2) / 0.06 : s < 0.8 ? 1 : 1 - (s - 0.8) / 0.2
    guard shine > 0.02 else { c.px(42, 30 - phial, C(0xE8F4FF)); return }
    let e: Double = s * 3.0, tau: Double = 2 * .pi
    let pulse: Double = 0.5 + 0.5 * sin(e * tau * 1.3)
    let r: Double = 4 + 2 * pulse
    c.glowLine(at.x, at.y, at.x, at.y, core: white, glow: C(0xBFEFFF, 0.7), coreR: 1.2, glowR: r, strength: shine)
    for (dx, dy) in [(1.0, 0.0), (-1.0, 0.0), (0.0, 1.0), (0.0, -1.0)] {            // the star's four points
        c.glowLine(at.x + dx * 1.5, at.y + dy * 1.5, at.x + dx * (r + 1), at.y + dy * (r + 1), core: C(0xF4FCFF),
                   glow: clear, coreR: 0.35, glowR: 0.4, strength: shine * (0.55 + 0.35 * pulse))
    }
}

// MARK: - Shared helpers

private let clear = C(0x000000, 0)

/// Boots over the bottom `rows` of each leg (a bit of the folded foot when sitting).
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

/// A solid pixel line (no glow), `r` its half-width.
private func line(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.7) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: clear, coreR: r, glowR: r + 0.1)
}

private func unit(_ degrees: Double) -> (x: Double, y: Double) {
    let r: Double = degrees * .pi / 180
    return (cos(r), sin(r))
}

/// A cape hanging down the back, seen from the side: it shows past the shoulder blade and between the back legs, so
/// the legs still read in front of it. Its hem sways at `speed` and ends on row `hem`.
private func drawBackCape(_ c: PixelCanvas, t: Double, speed: Double, color: Px, edge: Px, hem: Int = 43) {
    let last = min(hem, 43 - c.oy)
    guard last >= 27 else { return }
    for y in 27...last {
        let k = Double(y - 27) / Double(max(1, hem - 27))
        let sway = sin(t * speed + k * 2.2) * k * 1.6
        let l = Int((15.5 - k * 3.5 + sway).rounded())
        let r = 24 + Int((k * 2).rounded())
        c.rect(l, y, r - l + 1, 1, color)
        c.px(l, y, edge)
    }
}

/// A prop drawn pointing right from pixel (20, 20) of a scratch canvas, turned to `angle` degrees (0 forward, -90 up)
/// and placed with that point on `at`.
private func prop(_ c: PixelCanvas, at: (x: Double, y: Double), angle: Double, alpha: Double = 1, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(41, 41)
    art(s)
    let r = s.rotated(angle, about: (20.5, 20.5), into: 41, 41, at: (20.5, 20.5))
    let x0 = Int(floor(at.x - 20.5)), y0 = Int(floor(at.y - 20.5))
    for y in 0..<r.h {
        for x in 0..<r.w {
            let i = (y * r.w + x) * 4
            guard r.buf[i + 3] > 0 else { continue }
            c.px(x0 + x, y0 + y, unpremultiplied(r, i).alpha(alpha))
        }
    }
}

private func unpremultiplied(_ s: PixelCanvas, _ i: Int) -> Px {
    let a = s.buf[i + 3], m = 255 / Double(a)
    return Px(r: UInt8(min(255, Double(s.buf[i]) * m)), g: UInt8(min(255, Double(s.buf[i + 1]) * m)),
              b: UInt8(min(255, Double(s.buf[i + 2]) * m)), a: a)
}

/// Smoothstep: 0→1 eased at both ends.
private func smooth(_ x: Double) -> Double {
    let u = min(1, max(0, x))
    return u * u * (3 - 2 * u)
}

/// Draws `art` on a scratch canvas (same offsets as `c`) and copies it onto `c`, washed toward white by `flash` (0…1).
private func layer(_ c: PixelCanvas, flash: Double = 0, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    defer { c.ox = ox; c.oy = oy; c.baseY = by }
    let f = min(1, max(0, flash))
    for y in 0..<s.h {
        for x in 0..<s.w {
            let i = (y * s.w + x) * 4
            guard s.buf[i + 3] > 0 else { continue }
            var col = unpremultiplied(s, i)
            if f > 0 {
                col.r = UInt8(Double(col.r) + (255 - Double(col.r)) * f)
                col.g = UInt8(Double(col.g) + (255 - Double(col.g)) * f)
                col.b = UInt8(Double(col.b) + (255 - Double(col.b)) * f)
            }
            c.px(x, y, col)
        }
    }
}

/// The angles a heavy swing smears through: from now back past `trail`'s last angle by half as far again, so the smear
/// is longer than a sword's (the weapon looks slower, heavier). Empty when it isn't being swung fast.
private func heavySmear(_ now: Double, _ trail: [Double]) -> [Double] {
    guard let last = trail.last else { return [] }
    let end: Double = last + (last - now) * 0.5
    let n = max(2, Int((abs(end - now) / 5).rounded()))
    return (1...n).map { (i: Int) -> Double in now + (end - now) * Double(i) / Double(n) }
}
