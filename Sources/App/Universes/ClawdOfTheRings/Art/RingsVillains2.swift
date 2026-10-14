import Foundation

// Villains: the monsters and the orcs. The orcs and Smeagull are Clawd underneath, the blocky body in their own skin
// (grey-green, dark brown, pale), with the helmets, armour and rags drawn over it. The Ballrog and Shellob aren't Clawd
// at all: the Ballrog is half again a Man's height (the size is drawn on the canvas, so its `headTop`, its whip hand and
// its `bulk` say so), Shellob half again as wide, low on eight legs.

let ringsVillains2: [LOTRVillain: Persona] = [
    .balrog: Persona(name: "The Ballrog", weapon: .saber, armoured: true, canSit: false, pivot: balrogHand, bulk: 8, headTop: 10,
                     draw: drawBalrog),
    .gollum: Persona(name: "Smeagull", weapon: .saber, headTop: 27, signature: 3.6, callout: "My precious!",
                     draw: drawGollum),
    .uruk: Persona(name: "Uruk-Hi", weapon: .saber, headTop: 19, callout: "Meat's back on the menu!",
                   draw: drawUruk),
    .orc: Persona(name: "Gorbage", weapon: .saber, headTop: 23, callout: "Collecting garbage!", draw: drawOrc),
    .shelob: Persona(name: "Shellob", weapon: .saber, canSit: false, pivot: shelobFangs, bulk: 8, headTop: 22, draw: drawShelob),
]

// MARK: - The Ballrog

/// Where the Ballrog's whip hand is: out in front of its chest, half again as high as a Man's.
private let balrogHand: (x: Double, y: Double) = (45.5, 29.5)

/// The Ballrog, a demon of the ancient world, half again a Man's height: dark rock-hide split by glowing cracks, two
/// black horns, fire licking up from its head and shoulders, smoky wings folded behind it, eyes and mouth like a
/// furnace door. In its fist a fire whip, coiled on the floor in front of it at rest. No signature.
private func drawBalrog(_ c: PixelCanvas, _ p: Pose) {
    let rock = C(0x3A1A10), rockDark = C(0x2A120A), rockLight = C(0x52281A), horn = C(0x1E0E0A)
    let crack = C(0xE8501E), hot = C(0xFFB03A)
    let glow: Double = 0.75 + 0.25 * sin(p.lt * 2.3)
    // Two massive legs, cloven into claws.
    for (i, lx) in [19, 30].enumerated() {
        let up = p.step >= 0 && i == p.step ? 1 : 0
        let col = i == 0 ? rockDark : rock
        c.rect(lx, 33, 7, 10 - up, col)
        c.rect(lx - 1, 42 - up, 9, 2, rockDark)
        for k in 0..<3 { c.px(lx + 1 + k * 3, 43 - up, horn) }
        c.px(lx + 3, 36, crack.alpha(glow)); c.px(lx + 2, 37, crack.alpha(glow)); c.px(lx + 3, 39, crack.alpha(glow * 0.7))
    }
    c.oy += p.breathe
    drawBalrogWings(c, p)
    // The back arm, hanging.
    c.rect(10, 19, 4, 13, rockDark)
    c.rect(9, 31, 5, 4, rockDark)
    c.px(9, 35, horn); c.px(11, 35, horn); c.px(13, 35, horn)
    // The torso: huge shoulders tapering to the waist.
    let torso: [(l: Int, r: Int)] = [
        (16, 40), (14, 41), (13, 42), (13, 42), (14, 41), (15, 40), (15, 40), (16, 39), (16, 39), (17, 38), (17, 38),
        (18, 37), (18, 37), (18, 37), (18, 37), (18, 37), (18, 37), (18, 37),
    ]
    for (i, row) in torso.enumerated() {
        let y = 17 + i
        c.rect(row.l, y, row.r - row.l + 1, 1, rock)
        c.px(row.l, y, rockLight); c.px(row.r, y, rockDark)
    }
    c.rect(19, 29, 18, 1, rockDark); c.rect(19, 32, 18, 1, rockDark)          // the belly's ridges
    // The glowing cracks.
    let cracks: [[(Int, Int)]] = [
        [(20, 19), (21, 20), (22, 21), (21, 22), (21, 23), (22, 24), (23, 25), (22, 26)],
        [(35, 18), (34, 19), (33, 20), (33, 21), (34, 22), (35, 23), (34, 24), (33, 25)],
        [(27, 21), (28, 22), (28, 23), (27, 24), (27, 25), (28, 26), (29, 27), (28, 28)],
        [(24, 30), (25, 31), (24, 33), (25, 34)],
        [(32, 30), (31, 31), (32, 33)],
    ]
    for (k, crackLine) in cracks.enumerated() {
        for (j, pt) in crackLine.enumerated() {
            let a: Double = glow * (0.8 + 0.2 * sin(p.lt * 3 + Double(k + j)))
            c.px(pt.0, pt.1, (j % 3 == 1 ? hot : crack).alpha(a))
        }
    }
    // The head, thrust forward: a heavy brow, furnace eyes, a glowing mouth full of fangs.
    c.rect(27, 10, 10, 1, rock); c.rect(26, 11, 12, 1, rock)
    c.rect(25, 12, 14, 6, rock)
    c.rect(26, 18, 12, 1, rockDark)
    c.px(25, 12, rockLight); c.px(25, 13, rockLight)
    c.rect(27, 13, 12, 1, rockDark)
    for ex in [30.0, 35.0] {
        c.glowLine(ex, 14.5, ex + 2, 14.5, core: hot, glow: crack, coreR: 0.4, glowR: 1.4, strength: glow)
    }
    c.rect(30, 16, 9, 2, C(0x1A0806))
    c.rect(31, 16, 7, 1, crack.alpha(glow * 0.8))
    for x in [31, 33, 35, 37] { c.px(x, 16, C(0xE8DCC0)) }
    for x in [32, 34, 36] { c.px(x, 17, C(0xE8DCC0)) }
    // The horns, sweeping out and up.
    c.pattern(21, 4, [
        "..H.............H...",
        ".HH.............HH..",
        ".HH..............HH.",
        "HH...............HH.",
        "HH...............HH.",
        ".HH.............HH..",
        "..HHH.........HHH...",
        "....HH......HHH.....",
    ], ["H": horn])
    drawBalrogFlames(c, p)
    // The whip arm, reaching forward, the fist and the whip.
    line(c, 39, 19, 43, 24, rock, 2)
    line(c, 43, 24, 45, 28, rock, 1.8)
    c.rect(43, 27, 5, 4, rock); c.px(47, 27, rockLight); c.rect(43, 30, 5, 1, rockDark)
    drawFireWhip(c, p)
}

/// Fire licking up off the Ballrog's head and shoulders: flickering columns, yellow at the root, red at the tips.
private func drawBalrogFlames(_ c: PixelCanvas, _ p: Pose) {
    let colours: [Px] = [C(0xFFB03A), C(0xE8501E), C(0x8A1E0A)]
    let tick = Int(p.t * 10)
    let spots: [(x: Int, y: Int, h: Int)] = [
        (27, 9, 3), (28, 9, 4), (29, 9, 5), (30, 9, 4), (31, 9, 6), (32, 9, 5), (33, 9, 4), (34, 9, 5), (35, 9, 3), (36, 9, 2),
        (14, 16, 2), (15, 16, 3), (16, 16, 3), (17, 16, 2), (38, 16, 2), (39, 16, 3), (40, 16, 2),
        (24, 11, 2), (24, 12, 2),
    ]
    for (i, s) in spots.enumerated() {
        let h = max(1, s.h - 1 + Int(noise(i * 13 + tick) * 3))
        for k in 0..<h {
            let band = min(2, k * 3 / h)
            c.px(s.x, s.y - k, colours[band].alpha(k == h - 1 ? 0.7 : 1))
        }
    }
}

/// Smoky wings folded behind the Ballrog: two dark triangles rising over its back, their edges fraying into smoke.
private func drawBalrogWings(_ c: PixelCanvas, _ p: Pose) {
    let tick = Int(p.t * 6)
    triangle(c, (22, 17), (11, 0), (14, 24), C(0x2E1A12), fray: tick)
    triangle(c, (18, 19), (2, 4), (7, 34), C(0x1E0E0A), fray: tick + 3)
    line(c, 17, 20, 4, 6, C(0x34201A), 0.4)
    line(c, 17, 22, 6, 24, C(0x34201A), 0.4)
}

/// A filled triangle; the pixels on its edge are thinned to smoke, changing on `fray`.
private func triangle(_ c: PixelCanvas, _ a: (Double, Double), _ b: (Double, Double), _ d: (Double, Double), _ col: Px, fray: Int) {
    let minX = Int(min(a.0, b.0, d.0)), maxX = Int(max(a.0, b.0, d.0))
    let minY = Int(min(a.1, b.1, d.1)), maxY = Int(max(a.1, b.1, d.1))
    func side(_ p: (Double, Double), _ q: (Double, Double), _ r: (Double, Double)) -> Double {
        (p.0 - r.0) * (q.1 - r.1) - (q.0 - r.0) * (p.1 - r.1)
    }
    for y in minY...maxY {
        for x in minX...maxX {
            let pt = (Double(x) + 0.5, Double(y) + 0.5)
            let s1 = side(pt, a, b), s2 = side(pt, b, d), s3 = side(pt, d, a)
            let inside = (s1 >= 0 && s2 >= 0 && s3 >= 0) || (s1 <= 0 && s2 <= 0 && s3 <= 0)
            guard inside else { continue }
            let inner = (s1 >= 0 && s2 >= 0 && s3 >= 0)
                ? min(s1, s2, s3) : min(-s1, -s2, -s3)
            if inner < 18 {
                if noise(x * 7 + y * 31 + fray) > 0.45 { c.px(x, y, col.alpha(0.55)) }
            } else {
                c.px(x, y, col)
            }
        }
    }
}

/// The fire whip at rest: from the fist down to the floor and along it, a line of flame with a red glow, flickering.
private func drawFireWhip(_ c: PixelCanvas, _ p: Pose) {
    let floor = Double(43 - c.oy)
    let pts: [(Double, Double)] = [(46, 31), (47, 34), (48, 37), (49.5, 40), (51.5, 42), (54.5, 43), (58, 43), (61, 42.5),
                                   (63.5, 41), (65, 41.5)]
    let flick: Double = 0.85 + 0.15 * noise(Int(p.t * 20))
    for i in 1..<pts.count {
        let a = pts[i - 1], b = pts[i]
        c.glowLine(a.0, min(a.1, floor), b.0, min(b.1, floor), core: C(0xFFB03A), glow: C(0xE8501E), coreR: 0.45, glowR: 1.5,
                   strength: flick * (1 - Double(i) / Double(pts.count) * 0.3))
    }
}

// MARK: - Smeagull

/// Smeagull: a skinny pale grey-green creature, crouched lower than a hobbit stands, frog-legged with his knees out by
/// his sides, long thin arms reaching down to the floor, a few lank strands of hair, big pointed ears and huge round
/// pale-blue eyes with ink pupils, in nothing but a loincloth. He grabs and bites (claws out on the swing, later).
/// Signature (later): Smeagull and Gollum argue.
private func drawGollum(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xB8B49A), shade = C(0x8A866E), light = C(0xD0CCB4), eye = C(0xA8D8F0)
    let cloth = C(0x6A5A3A), clothDark = C(0x4E422A), hair = C(0x7A7460), claw = C(0xE8E4D0)
    // Crouched legs: the knees out to the sides, the feet flat and long-toed.
    if seatedPose {
        c.rect(17, 36, 4, 2, skin); c.rect(34, 36, 4, 2, skin)
        c.rect(18, 38, 5, 1, shade); c.rect(33, 38, 5, 1, shade)
        c.px(17, 38, claw); c.px(37, 38, claw)
    } else {
        let legs: [(hip: (Double, Double), knee: (Double, Double), foot: Int)] = [
            ((22, 38), (18.5, 37), 19), ((25, 38), (24.5, 40), 24), ((29, 38), (29.5, 40), 29), ((32, 38), (35.5, 37), 35),
        ]
        for (i, l) in legs.enumerated() {
            let up: Double = p.step >= 0 && i % 2 == p.step ? 1 : 0
            let ankle = (Double(l.foot) + 0.5, 42.5 - up)
            line(c, l.hip.0, l.hip.1, l.knee.0, l.knee.1 - up, skin, 0.7)
            line(c, l.knee.0, l.knee.1 - up, ankle.0, ankle.1, skin, 0.6)
            c.rect(l.foot - 1, 43 - Int(up), 3, 1, shade)
            c.px(l.foot + 2, 43 - Int(up), claw)
        }
    }
    c.oy += p.breathe
    // The thin arms, down to the floor in front of him and behind.
    line(c, 21, 33, 18.5, 39, skin, 0.55)
    c.rect(17, 39, 2, 2, skin); c.px(16, 40, claw)
    line(c, 33, 33, 37, 38, skin, 0.55)
    c.rect(37, 38, 2, 2, skin); c.px(39, 39, claw); c.px(39, 38, claw)
    // The body, narrow and hunched, the spine knobbly.
    c.rect(22, 29, 11, 1, skin)
    c.rect(21, 30, 13, 9, skin)
    c.rect(33, 30, 1, 9, shade); c.rect(21, 38, 13, 1, shade)
    c.px(21, 31, shade); c.px(21, 33, shade); c.px(21, 35, shade)
    c.px(23, 29, light); c.px(24, 29, light)
    // Big pointed ears, sticking out.
    c.pattern(18, 30, ["S..", "SSS", ".SS"], ["S": skin]); c.px(18, 30, shade)
    c.pattern(34, 30, ["..S", "SSS", "SS."], ["S": skin]); c.px(36, 30, shade)
    // A few lank strands of hair.
    for (x, y) in [(24, 28), (23, 27), (27, 28), (27, 27), (30, 28), (31, 27)] { c.px(x, y, hair) }
    // The huge round eyes, the pupils looking ahead.
    for ex in [22, 28] {
        c.pattern(ex, 30, [".EE.", "EEWE", "EEKK", "EEKK", ".EE."], ["E": eye, "W": white, "K": ink])
    }
    // The mouth: a thin line and a snaggle tooth.
    c.rect(26, 35, 3, 1, C(0x5A5444)); c.px(27, 35, claw)
    // The loincloth.
    c.rect(23, 38, 9, 1, cloth)
    c.rect(23, 37, 9, 1, clothDark)
    for x in stride(from: 23, through: 31, by: 2) where 39 + c.oy <= 43 { c.px(x, 39, cloth) }
}

// MARK: - Uruk-Hi

/// Uruk-Hi, the big fighting orc: dark brown skin, a white hand print over the face (the eyes looking out between the
/// fingers), a black iron helmet with the White Hand painted on its front, black armour plates on chest and shoulders,
/// and a heavy, notched sword, held low. No signature.
private func drawUruk(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x4A3A2E), skinDark = C(0x3A2C22), hand = C(0xF0EEE8)
    let plate = C(0x1E1E22), plateLight = C(0x3A3A42), plateMid = C(0x2A2A30), helm = C(0x2A2A30), helmLight = C(0x46464E)
    drawLegs(c, Look(leg: C(0x2E2620)), step: p.step)
    drawBoots(c, p.step, plate, rows: 3)
    c.oy += p.breathe
    // The body, broad, in its own dark skin, and the arms in black plate.
    c.rect(17, 26, 22, 12, skin)
    c.rect(38, 26, 1, 12, skinDark)
    c.rect(14, 33, 3, 3, plate)
    // The face: the white hand over it, the eyes between the fingers.
    c.pattern(21, 26, [
        "..W..W.W..W...",
        "KKW..W.W..WKK.",
        "KK.W.W.W.W.KK.",
        "...WWWWWWW....",
        "WW.WWWWWWW....",
        ".WWWWWWWW.....",
    ], ["W": hand, "K": ink])
    c.px(21, 27, C(0xC89A3A)); c.px(32, 27, C(0xC89A3A))
    // The armour: chest plates, a skirt of plates, spiked pauldrons.
    c.rect(17, 32, 22, 6, plate)
    c.rect(17, 32, 22, 1, plateLight)
    c.rect(17, 35, 22, 1, plateMid)
    c.rect(27, 32, 1, 6, plateMid)
    for y in 38...39 where y + c.oy <= 43 {
        for x in stride(from: 17, through: 36, by: 4) { c.rect(x, y, 3, 1, y == 38 ? plateMid : plate) }
    }
    c.pattern(13, 29, ["K.K..", "KKKK.", "KKKKK", "KHKKK", ".KKK."], ["K": plate, "H": plateLight])
    c.pattern(36, 29, ["..K.K", ".KKKK", "KKKKK", "KKKHK", ".KKK."], ["K": plate, "H": plateLight])
    // The helmet, the White Hand on its front, a peak over the eyes.
    c.pattern(16, 19, [
        ".........KKKKKK.........",
        "......KKKKKKKKKKKK......",
        "....KKKKhKKKKKKKKKKK....",
        "...KKKhKKKKKKKKKKKKKK...",
        "..KKKhKKKKKKKKKKKKKKKK..",
        ".KKKKKKKKKKKKKKKKKKKKKK.",
        "KKKKKKKKKKKKKKKKKKKKKKKKKK",
    ], ["K": helm, "h": helmLight])
    c.pattern(25, 20, [".W.W.W.", ".W.W.W.", ".WWWWW.", "WWWWWW.", ".WWWW.."], ["W": hand])
    drawUrukSword(c, angle: seatedPose ? 6 : 32)
    c.rect(38, 33, 3, 3, plate); c.px(38, 33, plateLight)
}

/// The Uruk's heavy sword: a crude broad blade, notched along the edge and flaring to a clipped point, a heavy iron
/// crossguard and a leather-wrapped grip.
private func drawUrukSword(_ c: PixelCanvas, angle: Double) {
    let h = Sprite.hand, u = unit(angle), n = (x: -u.y, y: u.x)                 // n: toward the edge
    let blade = C(0x7A7E86), edge = C(0xA8ACB4), dark = C(0x3A3E46)
    func at(_ d: Double, _ o: Double = 0) -> (x: Double, y: Double) { (h.x + u.x * d + n.x * o, h.y + u.y * d + n.y * o) }
    let g0 = at(-2.5), g1 = at(1.5)
    line(c, g0.x, g0.y, g1.x, g1.y, C(0x3A2A1E), 0.6)                            // the grip
    let pm = at(-3); c.px(Int(pm.x), Int(pm.y), dark)                             // the pommel
    let b0 = at(3), b1 = at(14), t0 = at(14, 0.6), t1 = at(17, 0.3)
    line(c, b0.x, b0.y, b1.x, b1.y, blade, 1.2)
    line(c, b1.x, b1.y, t0.x, t0.y, blade, 1.5)
    line(c, t0.x, t0.y, t1.x, t1.y, blade, 0.9)
    let e0 = at(3, 1), e1 = at(16, 1.2)
    line(c, e0.x, e0.y, e1.x, e1.y, edge, 0.35)
    for d in [6.0, 9.5, 12.5] { let q = at(d, 1.3); c.px(Int(q.x), Int(q.y), dark) }   // the notches
    let q0 = at(2.2, -3), q1 = at(2.2, 3)
    line(c, q0.x, q0.y, q1.x, q1.y, C(0x2A2A30), 0.75)                           // the crossguard
}

// MARK: - Gorbage

/// Gorbage, an orc of the rank and file: hunched, his head pushed forward, mottled green-grey skin, big pointed ears,
/// tusks, a crooked dented iron helmet, a ragged leather jerkin, and for a shield a dented bin lid with its handle
/// (he collects the garbage). A scimitar, held low. No signature.
private func drawOrc(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x5A6A4A), skinDark = C(0x46543A), skinLight = C(0x6E7E5C)
    let iron = C(0x5A5E66), ironDark = C(0x3E4248), ironLight = C(0x7A7E86)
    let jerkin = C(0x6A4A2E), jerkinDark = C(0x4E3420)
    drawLegs(c, Look(leg: C(0x3A3428)), step: p.step)
    drawBoots(c, p.step, C(0x5A4A36), rows: 2)
    c.oy += p.breathe
    // The hunched body: the head pushed forward, a hump behind the shoulders.
    c.rect(18, 31, 20, 7, skin)
    c.rect(20, 28, 19, 3, skin)
    c.rect(18, 29, 2, 2, skin); c.px(18, 29, skinLight)
    c.rect(38, 28, 1, 3, skinDark); c.rect(37, 31, 1, 7, skinDark)
    for (x, y) in [(22, 30), (35, 29), (24, 35), (31, 33), (20, 33), (29, 29)] { c.px(x, y, skinDark) }
    for (x, y) in [(26, 29), (33, 32), (21, 31)] { c.px(x, y, skinLight) }
    c.rect(14, 33, 4, 3, skin)
    // Big pointed ears, swept back.
    c.pattern(15, 28, ["SS...", ".SSS.", "..SS."], ["S": skin]); c.px(15, 28, skinDark)
    // The face: small mean eyes, a jutting jaw with two tusks.
    c.rect(26, 30, 2, 2, ink); c.rect(34, 30, 2, 2, ink)
    c.px(26, 30, C(0xC8A03A)); c.px(34, 30, C(0xC8A03A))
    c.rect(28, 33, 9, 1, C(0x2E3424))
    c.px(29, 32, C(0xE8E0C8)); c.px(35, 32, C(0xE8E0C8))
    // The ragged jerkin.
    c.rect(18, 34, 20, 4, jerkin)
    c.rect(37, 34, 1, 4, jerkinDark)
    c.rect(18, 36, 20, 1, C(0x3A2A1A))
    for x in stride(from: 18, through: 37, by: 2) where 38 + c.oy <= 43 { c.px(x, 38, jerkin); if x % 4 == 0 { c.px(x, 39, jerkinDark) } }
    c.px(22, 35, jerkinDark); c.px(32, 34, jerkinDark); c.px(25, 37, jerkinDark)
    // The crooked helmet, dented, tipped down at the back.
    c.pattern(19, 23, [
        "...........III......",
        "........IIIIIIII....",
        ".....IIIIhIIIIIIII..",
        "...IIIhIIIIIdIIIIIi.",
        ".IIIIIIIIIIIIIIIIIi.",
        "IIIiIIIIIIIIIIIIIi..",
        "III.................",
    ], ["I": iron, "h": ironLight, "i": ironDark, "d": ironDark])
    // The bin lid on his off arm, the scimitar in his fist.
    drawBinLid(c, cx: 13, cy: seatedPose ? 33 : 34)
    drawScimitar(c, angle: seatedPose ? 4 : 30)
    c.rect(38, 33, 3, 3, skin); c.px(40, 35, skinDark)
}

/// A dented bin lid used as a shield: a tin disk with a rolled rim, a ridge ring, dents, and the handle in the middle.
private func drawBinLid(_ c: PixelCanvas, cx: Int, cy: Int) {
    let tin = C(0x8A8E98), rim = C(0x6A6E78), light = C(0xB0B4BC), dent = C(0x6E727C)
    c.ellipse(cx, cy, 5, 5, rim)
    c.ellipse(cx, cy, 4, 4, tin)
    c.ellipse(cx, cy, 2, 2, light)
    c.ellipse(cx, cy, 1, 1, tin)
    c.rect(cx - 1, cy - 1, 3, 1, C(0x4A4E58)); c.px(cx - 1, cy, C(0x4A4E58)); c.px(cx + 1, cy, C(0x4A4E58))   // the handle
    for (dx, dy) in [(-3, -2), (2, 3), (3, -1)] { c.px(cx + dx, cy + dy, dent) }
    c.px(cx - 2, cy + 3, light); c.px(cx + 5, cy, C(0x4A4E58))
}

/// Gorbage's scimitar: a short grip, a plain crossguard and a curved blade that widens toward the tip and sweeps back.
private func drawScimitar(_ c: PixelCanvas, angle: Double) {
    let h = Sprite.hand, u = unit(angle), n = (x: u.y, y: -u.x)                  // n: toward the back of the blade
    let blade = C(0xA8ACB4), edge = C(0x6E727C)
    func at(_ d: Double, _ o: Double = 0) -> (x: Double, y: Double) { (h.x + u.x * d + n.x * o, h.y + u.y * d + n.y * o) }
    let g0 = at(-2), g1 = at(1.5)
    line(c, g0.x, g0.y, g1.x, g1.y, C(0x3A2A1E), 0.6)
    var prev = at(2.5)
    for i in 1...6 {
        let f = Double(i) / 6
        let q = at(2.5 + f * 12, f * f * 3.5)
        line(c, prev.x, prev.y, q.x, q.y, blade, 0.7 + f * 0.4)
        let e0 = (prev.x - n.x * 0.8, prev.y - n.y * 0.8), e1 = (q.x - n.x * (0.8 + f * 0.4), q.y - n.y * (0.8 + f * 0.4))
        line(c, e0.0, e0.1, e1.0, e1.1, edge, 0.3)
        prev = q
    }
    let q0 = at(2, -2.2), q1 = at(2, 2.2)
    line(c, q0.x, q0.y, q1.x, q1.y, C(0x4A4E58), 0.55)
}

// MARK: - Shellob

/// Where Shellob bites: the fangs, under the eyes at the front.
private let shelobFangs: (x: Double, y: Double) = (45.5, 38.5)

/// Shellob, the great spider: an ink-black bulbous body with a pale mark on its back, low on eight long jointed legs
/// (the far four paler), a cluster of glinting yellow eyes at the front and two curved fangs under them. Walking, the
/// legs step four and four. No signature.
private func drawShelob(_ c: PixelCanvas, _ p: Pose) {
    let body = C(0x2A221E), dark = C(0x1A1412), light = C(0x40362F), far = C(0x4A3E36), mark = C(0xC8C0A8)
    let eye = C(0xFFE08A)
    // The near legs arch high over the body; the far ones bend behind it, only their feet showing between.
    typealias Leg = (a: (Double, Double), k: (Double, Double), t: (Double, Double))
    let nearLegs: [Leg] = [
        ((38, 34), (50, 24), (59, 43)), ((36, 34), (42, 20), (51, 43)), ((33, 34), (26, 19), (21, 43)), ((31, 35), (13, 19), (2, 43)),
    ]
    let farLegs: [Leg] = [
        ((38, 35), (48, 29), (55, 43)), ((35, 35), (40, 28), (46, 43)), ((32, 36), (27, 31), (29, 43)), ((30, 36), (16, 28), (10, 43)),
    ]
    func leg(_ l: Leg, _ i: Int, near: Bool) {
        let lifted = p.step >= 0 && (i + (near ? 0 : 1)) % 2 == p.step
        let knee = (l.k.0, l.k.1 - (lifted ? 1 : 0))
        let tip = (l.t.0 + (lifted ? 1 : 0), l.t.1 - (lifted ? 2 : 0))
        let col = near ? body : far
        line(c, l.a.0, l.a.1, knee.0, knee.1, col, 1.3)
        line(c, knee.0, knee.1, tip.0, tip.1, col, 0.95)
        c.px(Int(knee.0), Int(knee.1), near ? light : C(0x5E5048))
    }
    for (i, l) in farLegs.enumerated() { leg(l, i, near: false) }
    c.oy += p.breathe
    // The abdomen: a great bulb, shaded, with the pale mark on its back and a few bristles.
    c.ellipse(16, 31, 13, 9, dark)
    c.ellipse(15, 30, 12, 8, body)
    c.ellipse(11, 26, 5, 2, light)
    c.pattern(9, 24, [
        ".MMMMMMM.",
        "..MMMMM..",
        "...MMM...",
        "....M....",
        "...MMM...",
        "..MMMMM..",
        ".MMMMMMM.",
    ], ["M": mark])
    for (x, y) in [(4, 27), (3, 32), (6, 37), (27, 24), (22, 22), (8, 23)] { c.px(x, y, far) }
    // The front body; the near legs on it; then the head over their roots.
    c.ellipse(34, 34, 7, 5, body)
    c.rect(29, 31, 8, 1, light)
    c.oy -= p.breathe
    for (i, l) in nearLegs.enumerated() { leg(l, i, near: true) }
    c.oy += p.breathe
    c.ellipse(41, 34, 4, 4, body)
    // The fangs, curved, pale at the tips.
    c.pattern(41, 37, [".F..F", "F..F.", "F..F.", "M..M."], ["F": C(0x5A4A40), "M": mark])
    // The eyes: two big ones and a cluster of small, glinting.
    let glint: Double = 0.7 + 0.3 * sin(p.lt * 2.7)
    c.rect(40, 31, 2, 2, eye); c.rect(43, 31, 2, 2, eye)
    for (x, y) in [(39, 33), (42, 30), (45, 33), (42, 33), (38, 31)] { c.px(x, y, eye.alpha(0.85)) }
    c.px(40, 31, white.alpha(glint)); c.px(43, 31, white.alpha(glint))
}

// MARK: - Shared helpers

private let clear = C(0x000000, 0)

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
