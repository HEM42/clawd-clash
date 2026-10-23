import Foundation

// Heroes: the grown-ups of Hawkins. Clawd in costume like the rest, with Clawd's own orange face showing; Hopper and
// Benny drawn broader than the kids, their shirts wider than the body under them.

let hawkinsHeroes4: [HawkinsHero: Persona] = [
    .chiefHopper: Persona(name: "Chief Hopper", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 16,
                          signature: 3.4, callout: "Mornings are for coffee.", draw: drawChiefHopper),
    .joyceByers: Persona(name: "Joyce Byers", weapon: .saber, headTop: 19, signature: 3.6, draw: drawJoyceByers),
    .murrayBauman: Persona(name: "Murray Bauman", weapon: .blaster, shot: .fire, muzzle: (54, 31), headTop: 25,
                           signature: 3.2, draw: drawMurrayBauman),
    .bobNewby: Persona(name: "Bob Newby", headTop: 20, signature: 3.6, draw: drawBobNewby),
    .mrClarke: Persona(name: "Mr. Clarke", headTop: 20, signature: 4.0, draw: drawMrClarke),
    .bennyHammond: Persona(name: "Benny Hammond", headTop: 21, signature: 3.0, draw: drawBennyHammond),
    .drOwens: Persona(name: "Dr. Owens", headTop: 21, draw: drawDrOwens),
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

// MARK: - Murray Bauman

/// Murray Bauman: bald on top with a dark fringe round the back of his head, square black glasses and a day's
/// stubble, a rumpled brown corduroy blazer over a mustard shirt and a loosened tie, khakis and brown shoes. He fights
/// with the flamethrower he brought to Kamchatka: two olive fuel tanks on his back, a hose under his arm and a long
/// wand with a pilot light at its tip. Signature: he lets the wand hang and takes a swig from a bottle of vodka.
private func drawMurrayBauman(_ c: PixelCanvas, _ p: Pose) {
    let blazer = C(0x7A5838), blazerD = C(0x58402A), blazerL = C(0x9A7650)
    let shirt = C(0xD8B850), tie = C(0x7A2A26)
    let tank = C(0x5E6A3A), tankD = C(0x434C28), tankL = C(0x7E8A52)
    let hair = C(0x3A2A1E), frame = C(0x1E1E22)
    let k = hawkinsSpan(p, 0.08, 0.92)
    let swig = hawkinsEase(k, edge: 0.2) > 0.4

    // The fuel tanks on his back, behind him: two olive cylinders, lit on the left, their valves on top.
    for x in [10, 14] {
        c.rect(x, 25, 4, 12, tank); c.rect(x, 25, 1, 12, tankL); c.rect(x + 3, 25, 1, 12, tankD)
        c.rect(x + 1, 24, 2, 1, tank); c.rect(x + 1, 23, 2, 1, C(0x8A8E96)); c.rect(x, 30, 4, 1, tankD)
    }

    drawLegs(c, Look(leg: C(0x9A8A66)), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 4, C(0x7A6C4E)) } }
    drawBoots(c, C(0x5A3A24), step: p.step, rows: 2)
    drawBoots(c, C(0x3A2416), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: blazer), armRight: swig ? 4 : 0)

    // The blazer over the mustard shirt and loosened tie: lit lapels, the cord in short strokes, the tanks' strap
    // across his chest, the far side and the hem in shade.
    c.rect(18, 33, 20, 5, blazer); c.rect(25, 33, 6, 5, shirt); c.rect(27, 33, 2, 1, shirt)
    c.rect(27, 34, 2, 3, tie); c.px(27, 34, C(0x9A3A34))
    c.rect(24, 33, 1, 5, blazerL); c.rect(31, 33, 1, 5, blazerD); c.rect(37, 33, 1, 5, blazerD)
    for x in [20, 22, 34] { c.rect(x, 34, 1, 3, blazerD) }
    c.rect(18, 37, 7, 1, blazerD); c.rect(31, 37, 7, 1, blazerD)
    c.rect(19, 33, 4, 1, blazerL)
    c.rect(18, 35, 6, 1, C(0x3A3A2A)); c.rect(32, 33, 2, 1, C(0x3A3A2A))
    c.rect(15, 35, 3, 1, blazerD)

    // Bald on top, a shine on his crown, the dark fringe round the back of his head, stubble along the jaw, and
    // square black glasses.
    c.rect(20, 26, 4, 1, C(0xF4A878)); c.px(19, 27, C(0xF4A878))
    c.pattern(18, 26, ["H.", "HH", "HH", "HH", "HH", "H."], ["H": hair]); c.rect(36, 27, 2, 3, hair)
    for (x, y) in [(20, 32), (22, 32), (33, 32), (35, 32), (21, 31), (34, 31)] { c.px(x, y, clawdShade) }
    c.pattern(20, 28, ["FFFFFF....FFFFFF", "F....FFFFFF....F", "F....F....F....F", "FFFFFF....FFFFFF"],
              ["F": frame])

    if swig {
        // The bottle tipped up at his mouth: clear glass, the red label, the cap off, his hand round it.
        hawkinsLine(c, 42.5, 23.5, 34.5, 29.5, C(0xD4E0E6), 1.3)
        hawkinsLine(c, 42, 23, 37, 26.8, C(0xF4FAFC), 0.4)
        hawkinsLine(c, 39.5, 25.5, 38, 26.6, C(0xC83030), 1.2)
        hawkinsLine(c, 34.5, 29.5, 31.5, 31.5, C(0xB8C8D0), 0.6)
        c.rect(37, 28, 3, 3, clawdOrange)
        // The wand hanging from its strap, pointing down.
        hawkinsLine(c, 36, 36, 46, 40, C(0x3A3E44), 0.8); c.px(46, 40, C(0x8A8E96))
        return
    }
    // The hose from the tanks under his arm, and the wand out in front, its pilot light flickering at the tip.
    hawkinsLine(c, 15.5, 37.5, 26, 39, C(0x26262A), 0.6); hawkinsLine(c, 26, 39, 38, 36, C(0x26262A), 0.6)
    c.oy += p.gunY
    c.rect(38, 33, 3, 3, blazer)
    c.pattern(38, 30, ["......GGGGGGGGGGGl", "SSSSSSSSSSSSSSSSSS", "..KK.........KK...", "..KK.............."],
              ["G": C(0x5A5E68), "l": C(0x9A9EA8), "S": C(0x3A3E44), "K": C(0x26262A)])
    c.rect(40, 31, 3, 2, clawdOrange)
    let f = Int(p.t * 9) % 3
    c.px(56, 31, f == 0 ? C(0x5AA8F0) : C(0xF0A030)); if f != 2 { c.px(56, 30, C(0xF8D060)) }
}

// MARK: - Bob Newby

/// Bob Newby, "Bob the Brain": short brown hair neatly parted, big glasses and a kind smile, a pale blue shirt with a
/// red knit tie, a pocket protector full of pens and his shop's red name badge, khaki slacks and brown shoes. He
/// doesn't fight. Signature: he holds up a sheet of paper and draws the map of the tunnels, a wiggling line at a time.
private func drawBobNewby(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0xBCD4EA), shirtD = C(0x94AEC8), shirtL = C(0xDCEAF6), tie = C(0xA82A2A)
    let hair = C(0x6A4A30), hairD = C(0x4A321E), hairL = C(0x8A6644)
    let frame = C(0x6A5444)
    let k = hawkinsSpan(p, 0.06, 0.94)
    let drawing = k >= 0

    drawLegs(c, Look(leg: C(0xA49470)), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 4, C(0x847652)) } }
    drawBoots(c, C(0x5A3A24), step: p.step, rows: 2)
    drawBoots(c, C(0x3A2416), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: shirt), armRight: drawing ? 4 : 0)
    c.pattern(25, 31, ["m....m", ".mmmm."], ["m": C(0x5A1A1E)])   // the kind smile

    // The shirt: the collar and the red tie, a pocket protector with three pens, the name badge, a fold or two, the
    // far side in shade, tucked into a brown belt.
    c.rect(18, 33, 20, 4, shirt)
    c.pattern(25, 33, ["cc..cc", ".c..c."], ["c": shirtL]); c.rect(27, 33, 2, 4, tie); c.px(27, 33, C(0xC84040))
    c.rect(20, 34, 3, 2, C(0xF0F0F0)); c.px(20, 33, C(0x3A5AB0)); c.px(21, 33, C(0xC83030)); c.px(22, 33, C(0x2A2A2A))
    c.rect(32, 34, 3, 1, C(0xC8302A)); c.px(33, 34, C(0xF0F0F0))
    c.rect(19, 33, 1, 1, shirtL); c.rect(37, 33, 1, 4, shirtD); c.px(30, 35, shirtD); c.px(24, 36, shirtD)
    c.rect(18, 37, 20, 1, C(0x5A3A24)); c.rect(27, 37, 2, 1, C(0xC8B070))
    c.rect(15, 35, 3, 1, shirtD)

    // Short brown hair, neatly parted on the left and combed across, lit in strokes, short over the ears.
    c.pattern(17, 20, [
        ".....HHHHHHHHHHH......",
        "...HHHHdlllllHHHHH....",
        "..HHHHdHHHHlllllHHH...",
        ".HHHHHdHHHHHHHHHHHHd..",
        ".HHlHHHHHHhHHHHHhHHd..",
        ".HHHHHHhHHHHHhHHHHHd..",
        ".HHH.............HHd..",
        ".HH...............Hd..",
    ], ["H": hair, "d": hairD, "h": hairD, "l": hairL])
    // The big glasses.
    c.pattern(20, 27, [".FFFFF....FFFFF.", "F.....FFFF.....F", "F.....F..F.....F", ".FFFFF....FFFFF."],
              ["F": frame])

    guard drawing else { return }
    // The sheet of paper held up in front of him, and the map of the tunnels growing across it in pencil, branching
    // as he draws, the pencil's tip at the end of the line.
    c.rect(38, 29, 3, 3, shirt)
    c.rect(41, 19, 15, 13, C(0xF2EEE0)); c.rect(41, 19, 15, 1, C(0xFFFCF4)); c.rect(55, 20, 1, 12, C(0xCFC8B4))
    c.rect(41, 31, 15, 1, C(0xCFC8B4))
    let path: [(Int, Int)] = [(43, 29), (44, 28), (45, 28), (46, 27), (46, 26), (47, 25), (48, 25), (49, 24), (50, 24),
                              (50, 23), (51, 22), (52, 22), (53, 21), (47, 26), (48, 27), (49, 28), (50, 28), (51, 29),
                              (52, 29), (53, 28), (50, 25), (51, 26), (52, 26), (53, 25)]
    let n = min(path.count, Int(k * Double(path.count) * 1.15))
    for (x, y) in path.prefix(n) { c.px(x, y, C(0x4A4A58)) }
    if let tip = path.prefix(max(1, n)).last {
        hawkinsLine(c, Double(tip.0) + 0.5, Double(tip.1) + 0.5, Double(tip.0) - 2.5, Double(tip.1) + 4.5, C(0xE8B830), 0.5)
        c.rect(tip.0 - 4, tip.1 + 4, 3, 2, clawdOrange)
    }
}

// MARK: - Mr. Clarke

/// Mr. Clarke, the Party's science teacher: brown hair combed back, a full beard, an olive knitted cardigan over a
/// checked shirt and a brown tie, grey slacks and brown shoes. He doesn't fight. Signature: a blackboard stands by
/// him and he chalks up the flea and the acrobat: a line, a little figure walking on top of it, then the same one
/// upside down underneath.
private func drawMrClarke(_ c: PixelCanvas, _ p: Pose) {
    let cardi = C(0x6A7044), cardiD = C(0x4C5230), cardiL = C(0x8A9060)
    let shirt = C(0xE0D8C4), tie = C(0x6A4428)
    let hair = C(0x5A3E28), hairD = C(0x3E2A1A), hairL = C(0x7A5A3C)
    let k = hawkinsSpan(p, 0.04, 0.96)
    let teaching = k >= 0

    if teaching {
        // The blackboard on its easel: a wooden frame round the green slate, its feet on the ground.
        c.rect(44, 15, 20, 15, C(0x7A5230)); c.rect(45, 16, 18, 13, C(0x2E4A3A)); c.rect(44, 15, 20, 1, C(0x9A6E44))
        c.rect(45, 28, 18, 1, C(0x5A3A20)); c.rect(46, 29, 6, 1, C(0xE8E8E0))
        hawkinsLine(c, 47, 30, 45, 43, C(0x6A4628), 0.6); hawkinsLine(c, 61, 30, 63, 43, C(0x6A4628), 0.6)
        let chalk = C(0xE8ECE4)
        let line = min(16, Int(k / 0.3 * 16))
        c.rect(46, 22, line, 1, chalk)
        if k > 0.35 {   // the flea walking on top of the line
            c.pattern(50, 17, [".c.", "ccc", ".c.", "c.c"], ["c": chalk])
        }
        if k > 0.6 {    // and the same, upside down underneath
            c.pattern(56, 23, ["c.c", ".c.", "ccc", ".c."], ["c": chalk])
        }
        if k > 0.45 && k < 0.6 { hawkinsLine(c, 53.5, 19.5, 57.5, 24.5, chalk.alpha(0.2), 0.5) }   // the way round
    }

    drawLegs(c, Look(leg: C(0x6A6A70)), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 4, C(0x52525A)) } }
    drawBoots(c, C(0x5A3A24), step: p.step, rows: 2)
    drawBoots(c, C(0x3A2416), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: cardi), armRight: teaching ? 6 : 0)

    // The cardigan, buttoned low over the checked shirt and tie: the knit in short strokes, buttons, pockets, the
    // far side and the hem in shade.
    c.rect(18, 33, 20, 5, cardi); c.rect(25, 33, 6, 3, shirt); c.rect(26, 36, 4, 1, shirt)
    c.px(25, 34, C(0xB8A890)); c.px(30, 34, C(0xB8A890)); c.rect(27, 33, 2, 4, tie)
    c.rect(24, 33, 1, 5, cardiL); c.rect(31, 33, 1, 5, cardiD)
    c.px(31, 35, C(0xD8C8A0)); c.px(31, 37, C(0xD8C8A0))
    c.rect(20, 35, 3, 1, cardiD); c.rect(33, 35, 3, 1, cardiD)
    c.rect(19, 33, 4, 1, cardiL); c.rect(37, 33, 1, 5, cardiD); c.rect(18, 37, 20, 1, cardiD)
    c.rect(15, 35, 3, 1, cardiD)

    // The full beard along his jaw and round his mouth, and the moustache.
    c.pattern(19, 30, ["BB..............BB", "BBB..BBBBBBB...BBB", ".BBBBBBbbbbBBBBBB.", "...BBBBBBBBBBBB..."],
              ["B": hair, "b": C(0x5A1A1E)])
    // Brown hair, combed back off his brow, lit in strokes, short at the sides.
    c.pattern(17, 20, [
        ".....HHHHHHHHHHHH.....",
        "...HHHlllllHHHHHHH....",
        "..HHHHHHHlllllHHHHH...",
        ".HHlllHHHHHHHHHlllHd..",
        ".HHHHHHHHHHHHHHHHHHHd.",
        ".HHHHHHHHHHHHHHHHHHHd.",
        ".HHH..............HHd.",
        ".HH................Hd.",
    ], ["H": hair, "d": hairD, "l": hairL])

    guard teaching else { return }
    // His arm up at the board, the chalk in his fingers.
    hawkinsLine(c, 39.5, 27.5, 44.5, 22.5, cardi, 1.1)
    c.rect(44, 21, 2, 2, clawdOrange)
}

// MARK: - Benny Hammond

/// Benny Hammond of Benny's Burgers: a big man with a bushy dark beard and short dark hair, a white t-shirt with the
/// sleeves rolled, a long white apron with a grease mark or two tied over dark trousers, and black work shoes. He
/// doesn't fight. Signature: he holds out a plate of fries, hot from the fryer, the steam curling up off them.
private func drawBennyHammond(_ c: PixelCanvas, _ p: Pose) {
    let tee = C(0xF0EEE8), teeD = C(0xCCC8C0), apron = C(0xF4F2EC), apronD = C(0xD0CCC4)
    let beard = C(0x3A2A1E), beardL = C(0x5A4230), hair = C(0x2E2018)
    let k = hawkinsSpan(p, 0.08, 0.92)
    let out = Int((hawkinsEase(k, edge: 0.2) * 5).rounded())

    drawLegs(c, Look(leg: C(0x3A3A44)), step: p.step)
    drawBoots(c, C(0x18181C), step: p.step, rows: 2)

    c.oy += p.breathe
    drawBody(c, Look(arm: tee), armRight: out > 0 ? 1 : 0)

    // The tee, a size bigger than the body under it, its rolled sleeves; the long apron over it, tied at the back,
    // falling over the tops of his legs, a grease mark or two, soft shadows hinting at the legs under it.
    c.rect(17, 33, 22, 5, tee); c.rect(17, 33, 1, 5, C(0xFAFAF6)); c.rect(38, 33, 1, 5, teeD)
    c.rect(15, 33, 3, 1, teeD)
    c.rect(21, 34, 14, 4, apron); c.rect(23, 33, 1, 1, apronD); c.rect(32, 33, 1, 1, apronD)
    c.rect(18, 35, 3, 1, apronD); c.rect(35, 35, 3, 1, apronD)
    if !seatedPose {
        c.rect(20, 38, 16, 2, apron); c.rect(20, 39, 16, 1, apronD)
        for x in [22, 32] { c.px(x, 38, apronD) }
    }
    c.px(25, 36, C(0xC8A070)); c.px(26, 36, C(0xC8A070)); c.px(31, 35, C(0xC85A3A))

    // The bushy beard over his jaw and chin, lit in strokes; short dark hair on top.
    c.pattern(18, 29, [
        "BB................BB",
        "BBBb...........bBBBB",
        "BBBBBBb.mmmm.bBBBBBB",
        ".BBlBBBBBBBBBBBBlBB.",
        "..BBBBBlBBBBlBBBBB..",
        "....BBBBBBBBBBBB....",
    ], ["B": beard, "b": beardL, "l": beardL, "m": C(0x5A1A1E)])
    c.pattern(18, 21, [
        "....HHHHHHHHHHH.....",
        "..HHHHHHHHHHHHHHH...",
        ".HHHHlHHHHlHHHHHHH..",
        "HHHHHHHHHHHHHHHHHHH.",
        "HHHHHlHHHHHHlHHHHHHH",
        "HHH..............HHH",
    ], ["H": hair, "l": C(0x4A3628)])

    guard out > 0 else { return }
    // The plate held out: white, heaped with golden fries, the steam curling up off them.
    let x = 38 + out
    c.rect(38, 32, out + 1, 3, tee)
    c.rect(x - 1, 32, 3, 2, clawdOrange)
    c.pattern(x - 3, 27, [
        "...f.ff....",
        "..fFfFfF...",
        ".fFfFfFff..",
        "PPPPPPPPPPP",
        ".ppppppppp.",
    ], ["f": C(0xF2C040), "F": C(0xD8A030), "P": C(0xF4F4F0), "p": C(0xC8C8CC)])
    if out >= 5 {
        for i in 0..<2 {
            let f = (p.t * 1.2 + Double(i) * 0.5).truncatingRemainder(dividingBy: 1)
            let sx = x - 1 + i * 3 + Int(sin(f * 7) * 1.2), sy = 25 - Int(f * 6)
            c.px(sx, sy, C(0xF4F4F4, 0.22)); c.px(sx, sy - 1, C(0xF4F4F4, 0.14))
        }
    }
}

// MARK: - Dr. Owens

/// Dr. Owens: dark hair thinning and going grey at the temples, wire glasses and a wry smile, a navy suit over a white
/// shirt and a red tie, his Department of Energy pass clipped to the pocket, grey trousers and black shoes. He neither
/// fights nor has a signature move.
private func drawDrOwens(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x2E3A5A), suitD = C(0x1E2840), suitL = C(0x4A5A80)
    let shirt = C(0xF0F0EC), tie = C(0xB02A2E)
    let hair = C(0x4A3A30), hairG = C(0x9A948C), hairD = C(0x2E241E)

    drawLegs(c, Look(leg: C(0x4A4E58)), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 4, C(0x383C46)) } }
    drawBoots(c, C(0x18181C), step: p.step, rows: 2)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx, hawkinsFoot(p, i) - 1, C(0x4A4A54)) } }

    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    c.rect(25, 32, 5, 1, C(0x5A1A1E)); c.px(30, 31, C(0x5A1A1E))   // a wry half-smile

    // The navy suit: lapels lit and shaded, the white shirt and red tie in the V, the pass on its clip, two buttons,
    // the far side and the hem in shade.
    c.rect(18, 33, 20, 5, suit)
    c.pattern(25, 33, ["SSSSSS", ".STTS.", "..TT.."], ["S": shirt, "T": tie]); c.rect(27, 36, 2, 1, tie)
    c.rect(24, 33, 1, 3, suitL); c.px(25, 35, suitL); c.rect(31, 33, 1, 3, suitD); c.px(30, 35, suitD)
    c.px(29, 36, C(0x141A2A)); c.px(29, 37, C(0x141A2A))
    c.rect(33, 34, 3, 3, C(0xF0F0EC)); c.rect(33, 34, 3, 1, C(0x3A6AB0)); c.px(34, 36, C(0x8A8F9C))
    c.rect(19, 33, 4, 1, suitL); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.rect(15, 35, 3, 1, suitD)

    // Dark hair, thin on top and receding, grey at the temples, combed back.
    c.pattern(17, 21, [
        "......HHHHHHHHH.......",
        "...HHHHHHHHHHHHHH.....",
        "..HHHdHHHHHdHHHHHH....",
        ".GHHSSSSSSSSSHHHHHG...",
        ".GGHSSSSSSSSSSSSSSGG..",
        ".GG................G..",
        ".Gd...................",
    ], ["H": hair, "d": hairD, "G": hairG, "S": clawdOrange])
    // Wire glasses.
    c.pattern(21, 28, ["FFFF......FFFF", "F..FFFFFFFF..F", "FFFF......FFFF"], ["F": C(0xA8A8B0)])
}
