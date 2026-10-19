import Foundation

// Heroes: the grown-ups of Hawkins. Clawd in costume like the rest, with Clawd's own orange face showing; Hopper drawn
// broader than the kids, his shirt wider than the body under it.

let hawkinsHeroes4: [HawkinsHero: Persona] = [
    .chiefHopper: Persona(name: "Chief Hopper", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 16,
                          signature: 3.4, callout: "Mornings are for coffee.", draw: drawChiefHopper),
    .joyceByers: Persona(name: "Joyce Byers", weapon: .saber, headTop: 19, signature: 3.6, draw: drawJoyceByers),
]

// MARK: - Chief Hopper

/// Chief Hopper: a broad-brimmed brown campaign hat with its peaked crown, a heavy moustache and a short beard, the tan
/// uniform shirt with epaulettes, flapped pockets and a gold star, a dark belt with his holster, brown trousers and
/// black boots. He fights with his revolver. Signature: he holsters it and sips his coffee from a white mug, the steam
/// curling up off it.
private func drawChiefHopper(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0xC4A672), shirtD = C(0x9E8452), shirtL = C(0xDCC08C)
    let hat = C(0x8A6A44), hatD = C(0x5E482C), hatL = C(0xAA8A5E), band = C(0x3A2A1A)
    let tash = C(0x5A3E28), beard = C(0x9A5A3A), gold = C(0xE8BE40), goldD = C(0xA8822A)
    let belt = C(0x2E2218)
    let k = hawkinsSpan(p, 0.08, 0.92)
    let sipping = k >= 0

    // Brown trousers, a crease at each knee, black boots.
    drawLegs(c, Look(leg: C(0x5A4A36)), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 5, C(0x423626)) } }
    drawBoots(c, C(0x221C18), step: p.step, rows: 3)
    drawBoots(c, C(0x3A322C), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: shirt), armRight: sipping ? 3 : 0)

    // The shirt, a size bigger than the others' clothes: tan, lit along the shoulders, the epaulettes, two flapped
    // pockets, the star on his chest, the open collar, the far side in shade.
    c.rect(17, 33, 22, 5, shirt)
    c.rect(18, 33, 4, 1, shirtL); c.rect(17, 33, 1, 5, shirtL)
    c.rect(19, 33, 3, 1, shirtD); c.rect(33, 33, 3, 1, shirtD)
    c.pattern(24, 33, ["dd..dd", ".d..d."], ["d": shirtD]); c.rect(26, 33, 4, 1, C(0xE8E2D0))
    c.rect(28, 34, 1, 3, shirtD)
    c.rect(20, 34, 4, 1, shirtD); c.rect(20, 35, 4, 1, shirtL)
    c.rect(32, 35, 4, 1, shirtD)
    c.pattern(32, 33, [".g.", "ggg", "g.g"], ["g": gold]); c.px(33, 35, goldD)
    c.rect(38, 33, 1, 5, shirtD)
    // The belt with its buckle, and the holster on his hip.
    c.rect(17, 37, 22, 1, belt); c.rect(27, 37, 2, 1, C(0xB8BCC4))
    c.rect(18, 36, 3, 4, C(0x4A3420)); c.px(18, 36, C(0x6A4A30))
    c.rect(15, 35, 3, 1, shirtD)

    // The face: the moustache, the short beard along his jaw, and greying hair under the brim.
    c.rect(24, 32, 8, 1, tash); c.rect(25, 31, 6, 1, tash); c.px(26, 31, C(0x7A5A40))
    c.rect(19, 31, 3, 2, beard); c.rect(34, 31, 3, 2, beard); c.rect(22, 32, 2, 1, beard); c.rect(32, 32, 2, 1, beard)
    c.rect(18, 23, 20, 3, C(0x5A4636)); c.rect(18, 23, 20, 1, C(0x3A2C22))   // in the brim's shadow
    c.rect(18, 26, 1, 2, C(0x5A4636)); c.rect(37, 26, 1, 2, C(0x5A4636)); c.px(18, 25, C(0x7A6656))
    // The campaign hat: the peaked crown with its dents, the band, and the wide flat brim, lit on top.
    c.pattern(14, 16, [
        "..........hHHHHh............",
        "........HHlHHddHHH..........",
        ".......HHlHHHddHHHH.........",
        ".......HlHHHHddHHHHH........",
        ".......BBBBBBBBBBBBBB.......",
        "..LLLLLLLLLLLLLLLLLLLLLLLL..",
        ".DDDDDDDDDDDDDDDDDDDDDDDDDD.",
    ], ["H": hat, "h": hatD, "d": hatD, "l": hatL, "B": band, "L": hatL, "D": hatD])

    if sipping {
        // The mug at his mouth, his hand round it, and the steam curling up off the coffee.
        c.rect(34, 30, 4, 2, shirt)
        c.pattern(27, 29, ["WWWW..", "WWWWHH", "WWWW.H", "WWWWHH", "dddd.."],
                  ["W": C(0xF0EEE6), "H": C(0xD8D4C8), "d": C(0xB8B4A8)])
        c.px(27, 29, C(0x4A2A18)); c.rect(28, 29, 3, 1, C(0x5A341E))
        c.rect(31, 30, 3, 2, clawdOrange)
        for i in 0..<2 {
            let f = (p.t * 1.2 + Double(i) * 0.5).truncatingRemainder(dividingBy: 1)
            let x = 28 + i * 2 + Int(sin(f * 7) * 1.2), y = 27 - Int(f * 6)
            c.px(x, y, C(0xF4F4F4, 0.22)); c.px(x, y - 1, C(0xF4F4F4, 0.14))
        }
        return
    }
    c.oy += p.gunY
    c.rect(38, 33, 3, 3, shirt)
    hawkinsRevolver(c)
}

// MARK: - Joyce Byers

/// Joyce Byers: messy brown hair falling to her shoulders, strands loose, a brown coat over a mauve jumper, jeans
/// and boots, and a string of Christmas lights wound round her, from her shoulder across to her hip. She fights with an
/// axe. Signature: the lights blink, one bulb after another, the way Will talks to her through them.
private func drawJoyceByers(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x7A5236), coatD = C(0x56381E), coatL = C(0x9A6E48)
    let jumper = C(0xA07890), jumperD = C(0x7E5A70)
    let hair = C(0x4A3020), hairD = C(0x2E1C12), hairL = C(0x6E4A32)
    let wire = C(0x2E4A2A)
    let k = hawkinsSpan(p, 0.04, 0.96)

    drawLegs(c, Look(leg: C(0x4A5A7A)), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 4, C(0x36445E)) } }
    drawBoots(c, C(0x4A3426), step: p.step, rows: 3)
    drawBoots(c, C(0x2E2018), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: coat))

    // The coat, open over the jumper: lit lapels and shoulders, a pocket each side, the far side and the hem in shade.
    c.rect(18, 33, 20, 5, coat); c.rect(24, 33, 8, 5, jumper); c.rect(24, 37, 8, 1, jumperD)
    c.rect(25, 33, 6, 1, jumperD)
    c.rect(23, 33, 1, 5, coatL); c.rect(32, 33, 1, 5, coatD); c.rect(37, 33, 1, 5, coatD)
    c.rect(18, 37, 6, 1, coatD); c.rect(32, 37, 6, 1, coatD)
    c.rect(19, 33, 3, 1, coatL); c.rect(19, 36, 3, 1, coatD); c.rect(34, 36, 3, 1, coatD)
    c.rect(15, 35, 3, 1, coatD)

    // The messy hair: brown, falling to her shoulders, lit in strokes, with a few strands loose at the sides.
    c.pattern(15, 19, [
        "..........................",
        ".......HHHHHHHHHHHH.......",
        "....HHHHlllHHHHlllHHHH....",
        "...HHHHlllHHHHlllHHHHHHH..",
        "...HHHHHHHHHHHHHHHHHHHHH..",
        "..HHHHhHHHHHhHHHHHhHHHHHd.",
        ".HHHHHHHhHHHHHHHhHHHHHHHd.",
        "HHHHHHH...........HHHHHHHd",
        ".HHHHH..............HHHHd.",
        "HHHH.................HHHd.",
        ".HHH.................HHH..",
        ".HlH.................HdH..",
        ".HHH.................HdH..",
        "HHHd.................dHH..",
        "HHHd.................dHHH.",
        ".HdH.................dHd..",
        "..d...................d...",
    ], ["H": hair, "d": hairD, "l": hairL])

    // The Christmas lights: a dark green wire from her shoulder across to her hip, a bulb on it every few pixels. At
    // rest they glow softly; in her signature they light up one after another, each with a halo.
    let bulbs: [Px] = [C(0xE83A3A), C(0x3AC85A), C(0x3A7AE8), C(0xF0C838), C(0xE87A2A)]
    var spots: [(x: Int, y: Int)] = []
    for i in 0..<21 {
        let x = 17 + i, y = 32 + i * 5 / 20
        c.px(x, y, wire)
        if i % 3 == 1 { spots.append((x, y + 1)) }
    }
    let lit = k >= 0 ? Int(k * 18) % (spots.count + 2) : -1
    for (i, s) in spots.enumerated() {
        let col = bulbs[i % bulbs.count]
        let on = lit < 0 || i == lit || i == lit - 1
        c.px(s.x, s.y, on ? col : col.mixDim())
        c.px(s.x, s.y + 1, on ? col : col.mixDim())
        if k >= 0 && i == lit {
            for (dx, dy) in [(-1, 0), (1, 0), (0, -1), (-1, 1), (1, 1), (0, 2)] { c.px(s.x + dx, s.y + dy, col.alpha(0.22)) }
        }
    }

    if let a = p.melee {
        joyceAxe(c, angle: a, trail: p.trail)
    } else {
        joyceAxe(c, angle: -80, trail: [])
    }
}

/// Joyce's axe along `angle` from her hand: the wooden haft, and the steel head at the far end, its edge facing out
/// from the haft's forward side, lit along the cutting edge; a smear where a fast swing just was.
private func joyceAxe(_ c: PixelCanvas, angle a: Double, trail: [Double]) {
    let h = Sprite.hand
    hawkinsSmear(c, h, trail, from: 8, to: 13, C(0xE4ECF4))
    hawkinsBar(c, h, a, from: -2, to: 12.5, C(0x7A5230), r: 0.75)
    hawkinsBar(c, h, a, from: 0, to: 12, C(0xA87A48), r: 0.3)
    for d in stride(from: 9.5, through: 12.5, by: 0.5) {
        let b = hawkinsReach(h, a, d), e = hawkinsReach(b, a + 90, 3.2 + (d - 9.5) * 0.35)
        hawkinsLine(c, b.x, b.y, e.x, e.y, C(0x8A929E), 0.45)
    }
    let e0 = hawkinsReach(hawkinsReach(h, a, 9.2), a + 90, 3.4), e1 = hawkinsReach(hawkinsReach(h, a, 12.8), a + 90, 4.4)
    hawkinsLine(c, e0.x, e0.y, e1.x, e1.y, C(0xE4E8F0), 0.5)
    let poll = hawkinsReach(hawkinsReach(h, a, 11), a - 90, 1.6)
    hawkinsLine(c, hawkinsReach(h, a, 11).x, hawkinsReach(h, a, 11).y, poll.x, poll.y, C(0x4A4E58), 0.7)
    c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, clawdOrange)
}

private extension Px {
    /// The same bulb unlit: its colour pulled most of the way to the dark green of the wire.
    func mixDim() -> Px {
        Px(r: UInt8((Int(r) + 46 * 2) / 3), g: UInt8((Int(g) + 74 * 2) / 3), b: UInt8((Int(b) + 42 * 2) / 3), a: a)
    }
}
