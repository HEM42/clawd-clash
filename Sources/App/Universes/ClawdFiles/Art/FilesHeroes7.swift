import Foundation

// Heroes: friendly oddities and pets. Tad O'Clawley, Dr. Blockclaw, the Conundrum, Sheriff Hartwell, Queequeg and Daggoo.
// The show's comic side: a webcaster, two sideshow performers from Gibsonton, a hapless small-town sheriff, Scrawly's
// Pomeranian and Clawder's goldfish. Clawd in costume as everywhere, except the two pets, who are animals of Clawd orange.

let filesHeroes7: [FilesHero: Persona] = [
    .tadOClawley: Persona(name: "Tad O'Clawley", weapon: .none, headTop: 20, signature: 3.4, callout: "Wake up, America!",
                          draw: drawTadOClawley),
    .drBlockclaw: Persona(name: "Dr. Blockclaw", weapon: .saber, headTop: 26, signature: 3.2, callout: "Step right up!",
                          draw: drawDrBlockclaw),
    .conundrum: Persona(name: "The Conundrum", weapon: .none, headTop: 26, signature: 3.0, callout: "…",
                        draw: drawConundrum),
    .sheriffHartwell: Persona(name: "Sheriff Hartwell", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                              headTop: 16, signature: 2.6, callout: "Howdy.",
                              draw: drawSheriffHartwell),
    .queequeg: Persona(name: "Queequeg", weapon: .saber, canSit: false, headTop: 27, signature: 2.4, callout: "Yap!",
                       draw: drawQueequeg),
    .daggoo: Persona(name: "Daggoo", weapon: .none, motion: .hover, canSit: false, headTop: 22, signature: 3.0,
                     draw: drawDaggoo),
]

/// A round-ended line, for handles and legs.
private func h7Stick(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.7) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: C(0x000000, 0), coreR: r, glowR: r + 0.1)
}

/// A jigsaw edge from (x, y), `length` long, with a round tab at `tab` (a row on a vertical edge, a
/// column on a horizontal one) bulging `out` (1 right or down, -1 left or up).
private func h7Edge(_ c: PixelCanvas, x: Int, y: Int, length: Int, vertical: Bool, tab: Int, out: Int, _ col: Px) {
    for i in 0..<length {
        let at: Int = vertical ? y + i : x + i
        guard abs(at - tab) > 1 else { continue }   // the neck of the tab
        if vertical { c.px(x, at, col) } else { c.px(at, y, col) }
    }
    // The tab's round end: across the neck's ends, out two, and round.
    let ring: [(Int, Int)] = [(0, -2), (1, -2), (2, -1), (2, 0), (2, 1), (1, 2), (0, 2)]
    for (a, b) in ring {
        if vertical { c.px(x + a * out, tab + b, col) } else { c.px(tab + b, y + a * out, col) }
    }
}

// MARK: - Tad O'Clawley

/// Tad O'Clawley: Clawd with dark hair swept up in a glossy wave, a navy blazer over an open-collared white shirt, an
/// earpiece, and a handheld microphone he never puts down. No weapon: in a fight he shouts. Signature: he goes live, the
/// mic up to his mouth, a red LIVE light blinking over his shoulder and his voice rolling out in arcs.
private func drawTadOClawley(_ c: PixelCanvas, _ p: Pose) {
    let blazer = C(0x1E2A4A), blazerD = C(0x141C34), blazerL = C(0x34446C), shirt = C(0xF2F2EE)
    let hair = C(0x2A1C14), hairL = C(0x5A402A), mic = C(0x1A1A1E), micHead = C(0xB8BCC4)
    let sig = p.signature
    let live = (sig.map { $0 > 0.06 && $0 < 0.94 } ?? false) || p.cheering

    drawLegs(c, Look(leg: C(0x3A3E48)), step: p.step)
    filesDrawDressShoes(c, step: p.step, color: C(0x3A2416))
    c.oy += p.breathe
    drawBody(c, Look(arm: blazer))
    // The blazer, open over the shirt (no tie, collar open).
    c.rect(18, 33, 20, 5, blazer); c.rect(37, 33, 1, 5, blazerD); c.rect(18, 37, 20, 1, blazerD)
    c.pattern(24, 33, ["SS..SS", "SSSSSS", ".SSSS.", "..SS.."], ["S": shirt])
    c.rect(22, 33, 1, 4, blazerL); c.rect(33, 33, 1, 4, blazerL)
    filesDrawJacketDetail(c, dark: blazerD, light: blazerL)
    c.px(20, 34, C(0xC8A04A))   // a pin on the lapel
    // The hair: a glossy wave swept up off the forehead.
    c.pattern(17, 19, [
        "........HHHHHHH.......",
        ".....HHHHHHlllHHH.....",
        "...HHlllHHHHHHlHHHd...",
        "..HHHHHHlllHHHHHlHdd..",
        ".HHHHHHHHHHHHlllHHHdd.",
        ".HHlllHHHHHHHHHHHHHdd.",
        ".HHHHHHlllHHHHHHHHHdd.",
        ".HH...HHH..........dd.",
    ], ["H": hair, "l": hairL, "d": C(0x1A100A)])
    c.px(18, 29, C(0xD8DCE4)); c.px(18, 30, C(0x2A2A30))   // the earpiece

    c.rect(15, 33, 3, 3, blazer); filesDrawCuffs(c, blazerD, right: false)
    if live {
        // The mic up at his mouth, his voice rolling out, the LIVE light blinking.
        c.rect(36, 30, 3, 3, blazer); c.rect(35, 32, 2, 1, clawdOrange)
        c.rect(36, 31, 1, 3, mic); c.rect(35, 29, 3, 2, micHead)
        // Three arcs of his voice from the mic, lighting up one after another (never quite out, so a still shows them).
        let beat: Int = Int(p.t * 5) % 3
        for (i, r) in [4.0, 7.0, 10.0].enumerated() {
            let col = C(0xF4F0E0, i == beat ? 1 : 0.45)
            for step in -4...4 {
                let a: Double = Double(step) * 0.17
                c.px(37 + Int((cos(a) * r).rounded()), 30 + Int((sin(a) * r).rounded()), col)
            }
        }
        // The LIVE sign over his shoulder, its lamp blinking.
        let lit = Int(p.t * 3) % 2 == 0
        let red = lit ? C(0xFF4A4A) : C(0x7A2A2A)
        c.rect(44, 14, 21, 7, C(0x1A1A1E)); c.rect(44, 14, 21, 1, C(0x3A3A42))
        c.pattern(45, 15, [
            ".r..L...I.V.V.EEE",
            "rRr.L...I.V.V.E..",
            ".r..L...I.V.V.EE.",
            "....L...I.V.V.E..",
            "....LLL.I..V..EEE",
        ], ["r": red, "R": lit ? C(0xFFD0C8) : red, "L": red, "I": red, "V": red, "E": red])
        return
    }
    // At rest, the mic held down by his side.
    c.rect(38, 33, 3, 3, blazer); c.rect(38, 35, 3, 1, clawdOrange); c.rect(38, 34, 3, 1, blazerD)
    c.rect(41, 33, 1, 4, mic); c.rect(40, 31, 3, 2, micHead)
}

// MARK: - Dr. Blockclaw

/// Dr. Blockclaw: a Gibsonton sideshow performer. Clawd bald and shining, blue tattoo lines winding round his arms and
/// up his cheeks, a black waistcoat over his bare chest, striped red circus trousers. He swings a big carpenter's
/// hammer. Signature: the human block's act: he sets a nail to his nose and taps it in, tink, tink, stars popping
/// (it's a trick, and he takes a bow).
private func drawDrBlockclaw(_ c: PixelCanvas, _ p: Pose) {
    let vest = C(0x1A1A1E), vestL = C(0x3A3A42), trousers = C(0xA8222A), stripe = C(0xE8D8B8), ink = C(0x2E5CA8)
    let steel = C(0xB8BCC4), handle = C(0x8A5A30)
    let sig = p.signature
    let act = sig.map { $0 > 0.06 && $0 < 0.86 } ?? false
    let bow = sig.map { $0 >= 0.86 && $0 < 0.98 } ?? false

    drawLegs(c, Look(leg: trousers), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx, p.step >= 0 && i % 2 == p.step ? 38 : 39, stripe) } }
    filesDrawDressShoes(c, step: p.step)
    if bow { c.oy += 2 }
    c.oy += p.breathe
    drawBody(c, Look(arm: clawdOrange))
    // A shine on the bald top, tattoos curling up the cheeks.
    c.rect(23, 26, 4, 1, C(0xF0A888))
    c.pattern(19, 27, ["i..", ".i.", "i.i"], ["i": ink]); c.pattern(34, 27, ["..i", ".i.", "i.i"], ["i": ink])
    // The waistcoat open over the bare chest, its buttons, a watch chain.
    c.rect(18, 33, 6, 5, vest); c.rect(32, 33, 6, 5, vest); c.rect(37, 33, 1, 5, C(0x0E0E10))
    c.px(23, 34, vestL); c.px(23, 36, vestL); c.px(32, 34, vestL); c.px(32, 36, vestL)
    c.rect(18, 33, 3, 1, vestL); c.rect(33, 33, 2, 1, vestL)                    // the waistcoat lit along the shoulders
    c.rect(20, 35, 1, 2, C(0x0E0E10)); c.rect(36, 34, 1, 3, C(0x0E0E10))      // a fold, the far side in shade
    c.rect(19, 36, 2, 1, C(0x2A2A30))                                           // its watch pocket
    c.pattern(25, 34, ["i.i.i", ".i.i."], ["i": ink])   // more ink on the chest
    c.rect(24, 36, 8, 1, C(0xD8B44A))
    // Tattooed arms.
    c.rect(15, 33, 3, 3, clawdOrange); c.px(15, 33, ink); c.px(16, 34, ink); c.px(17, 35, ink)

    if act {
        // The nail at the tip of his nose, the hammer tapping it: the stars on each tap.
        let tap = sin(p.t * 9) > 0.3
        c.rect(30, 31, 3, 1, steel); c.px(29, 31, C(0xE8E8F0))
        c.rect(38, 28, 3, 3, clawdOrange)
        let hx = tap ? 34 : 37
        h7Stick(c, 40, 30, Double(hx + 3), 26, handle, 0.8)
        c.rect(hx, 28, 2, 4, steel); c.rect(hx - 1, 29, 1, 2, steel)
        if tap { c.px(29, 28, C(0xFFE14A)); c.px(27, 30, C(0xFFE14A)); c.px(28, 33, C(0xFFE14A)) }
        return
    }
    if bow {
        c.rect(38, 33, 3, 3, clawdOrange)
        return
    }
    // The hammer: swung on its arc in a fight, otherwise resting head-down by his side.
    if let a = p.cheering ? -95 : p.melee {
        let r = a * .pi / 180, hx = Sprite.hand.x, hy = Sprite.hand.y
        let ex = hx + cos(r) * 11, ey = hy + sin(r) * 11
        h7Stick(c, hx, hy, ex, ey, handle, 0.8)
        let nx = -sin(r), ny = cos(r)   // across the handle: the head
        h7Stick(c, ex - nx * 3, ey - ny * 3, ex + nx * 3, ey + ny * 3, steel, 1.4)
        c.rect(38, 33, 3, 3, clawdOrange)
        return
    }
    c.rect(38, 33, 3, 3, clawdOrange)
    h7Stick(c, 40, 34, 42, 42, handle, 0.8)
    c.rect(40, 41, 5, 2, steel)
}

// MARK: - The Conundrum

/// The Conundrum: Gibsonton's silent man. Clawd bald and tattooed all over in blue-green jigsaw lines, face included,
/// in plain black trunks. He never says a word and he'll eat anything. No weapon. Signature: he holds a goldfish up by
/// the tail, drops it into his mouth and gulps, cheeks bulging, then pats his belly.
private func drawConundrum(_ c: PixelCanvas, _ p: Pose) {
    let ink = C(0x2E8A8A), inkD = C(0x1E6A6E), trunks = C(0x1A1A1E), fish = C(0xF08A2A)
    let sig = p.signature
    let holding = sig.map { $0 > 0.05 && $0 < 0.4 } ?? false
    let gulp = sig.map { $0 >= 0.4 && $0 < 0.7 } ?? false
    let pat = sig.map { $0 >= 0.7 && $0 < 0.96 } ?? false

    drawLegs(c, Look(), step: p.step)
    if !seatedPose {   // ink on the legs too
        for (i, lx) in [19, 23, 31, 35].enumerated() { let y = p.step >= 0 && i % 2 == p.step ? 38 : 39; c.px(lx, y, ink); c.px(lx + 1, y + 2, ink) }
    }
    c.oy += p.breathe
    drawBody(c, Look(eye: nil))
    // The jigsaw: pieces outlined in blue-green, each edge with a round tab pushing into the next piece, over every
    // bit of him. The pieces take turns a shade lighter, so they read as pieces, not a grid.
    // Five big pieces, kept clear of the eyes and mouth: a line down between the eyes, one across under them, two
    // short ones below; the pieces on the diagonal a shade lighter.
    for (x, y, w, h) in [(18, 26, 10, 6), (26, 33, 5, 3)] as [(Int, Int, Int, Int)] {
        for yy in y..<(y + h) {
            for xx in x..<(x + w) where c.isDrawn(xx + c.ox, yy + c.oy + c.baseY) { c.px(xx, yy, C(0xEC8A62)) }
        }
    }
    h7Edge(c, x: 28, y: 26, length: 6, vertical: true, tab: 28, out: 1, ink)
    h7Edge(c, x: 18, y: 32, length: 10, vertical: false, tab: 21, out: 1, ink)
    h7Edge(c, x: 28, y: 32, length: 10, vertical: false, tab: 34, out: 1, ink)
    c.rect(25, 33, 1, 3, ink); c.rect(31, 33, 1, 3, ink)
    // Eyes over the ink, and a straight mouth (he never speaks).
    c.rect(22, 29, 2, 3, C(0x16161B)); c.rect(32, 29, 2, 3, C(0x16161B))
    c.rect(26, 33, 4, 1, C(0x8A3A2A))
    // The trunks.
    c.rect(18, 36, 20, 2, trunks)
    c.rect(15, 33, 3, 3, clawdOrange); c.px(16, 34, ink)

    if holding {
        // A goldfish held up by the tail, wriggling, over his open mouth.
        c.rect(38, 26, 3, 7, clawdOrange); c.px(39, 27, ink)
        let w = Int(p.t * 8) % 2
        c.pattern(33 + w, 22, ["..T.", ".FFF", "FFFF", ".FF."], ["T": C(0xFFC86A), "F": fish])
        c.rect(26, 32, 4, 2, C(0x5A1A14))
        return
    }
    if gulp {
        // Cheeks bulging, a little tail flicking at the corner of his mouth on the way down.
        c.rect(24, 31, 8, 3, C(0xE8896A)); c.rect(26, 33, 4, 1, C(0x8A3A2A))
        if (sig! - 0.4) < 0.12 { c.px(30, 33, fish); c.px(31, 32, C(0xFFC86A)) }
        c.rect(38, 33, 3, 3, clawdOrange)
        return
    }
    if pat {
        // A satisfied pat on the belly.
        c.rect(28, 34, 3, 3, clawdOrange); c.px(29, 35, ink)
        if Int(p.t * 4) % 2 == 0 { c.px(31, 33, white) }
        return
    }
    c.rect(38, 33, 3, 3, clawdOrange); c.px(39, 34, ink)
}

// MARK: - Sheriff Hartwell

/// Sheriff Hartwell of Cumberland County: Clawd under a big cream cowboy hat, two buck teeth showing, a khaki sheriff's
/// shirt with a star on the chest and a brown tie, brown trousers and boots, a revolver from his holster. Signature: he
/// tips his hat with a toothy grin.
private func drawSheriffHartwell(_ c: PixelCanvas, _ p: Pose) {
    let hat = C(0xE8DCB8), hatD = C(0xB8A880), band = C(0x6A4A2A), shirt = C(0xB8A272), shirtD = C(0x8E7A50)
    let trousers = C(0x5A4028), star = C(0xE8C04A)
    let sig = p.signature
    let tipping = sig.map { $0 > 0.1 && $0 < 0.85 } ?? false

    drawLegs(c, Look(leg: trousers), step: p.step)
    filesDrawDressShoes(c, step: p.step, color: C(0x3A2416))
    c.oy += p.breathe
    drawBody(c, Look(arm: shirt))
    // The shirt, its pockets, the star and the tie.
    c.rect(18, 33, 20, 5, shirt); c.rect(37, 33, 1, 5, shirtD); c.rect(18, 37, 20, 1, shirtD)
    c.rect(20, 34, 4, 2, shirtD); c.rect(32, 34, 4, 2, shirtD)
    c.rect(20, 35, 4, 1, shirt); c.rect(32, 35, 4, 1, shirt); c.px(34, 34, C(0xD8C8A0))   // pocket flaps, a button
    c.pattern(21, 33, [".S.", "SSS", ".S."], ["S": star]); c.px(21, 33, C(0xFFF0A0))       // the star, catching the light
    c.rect(18, 33, 2, 1, C(0xD0BC8C)); c.rect(36, 34, 1, 3, shirtD)                        // a lit shoulder, the far side
    c.rect(27, 33, 2, 4, C(0x5A3A22))
    // The gun belt, its buckle, the holster at his hip.
    c.rect(18, 37, 20, 1, C(0x4A3018)); c.rect(27, 37, 2, 1, C(0xD8C080)); c.rect(35, 37, 2, 2, C(0x3A2412))
    // The buck teeth, under a grin.
    c.rect(26, 32, 4, 1, C(0x8A3A2A)); c.rect(27, 33, 1, 2, white); c.rect(28, 33, 1, 2, white)
    // The hat: its crown and band, the brim wide over the eyes, down to the top of the body. Lifted when he tips it.
    let lift = tipping ? (sig! < 0.3 || sig! > 0.7 ? 1 : 3) : 0
    c.pattern(13, 17 - lift, [
        "........HHLLLLHHHH........",
        ".......HHLHdHHdHHHd.......",
        ".......HHHHHHHHHHdd.......",
        ".......HHHHHHHHHHHd.......",
        ".......BBBBBBBBBBBB.......",
        "..H....HHHHHHHHHHHH....H..",
        ".HHHHHHHHHHHHHHHHHHHHHHHH.",
        "HHHHddddddddddddddddddHHHH",
        "..dddddddddddddddddddddd..",
    ], ["H": hat, "d": hatD, "B": band, "L": C(0xF6EED6)])
    if lift > 0 { c.rect(18, 26 - lift, 20, lift, clawdOrange) }   // the gap under a lifted hat shows his forehead
    if tipping {
        c.rect(38, 22 - lift, 3, 11, shirt); c.rect(38, 21 - lift, 3, 2, clawdOrange)
        c.rect(15, 33, 3, 3, shirt); filesDrawCuffs(c, shirtD, right: false)
        return
    }
    c.rect(15, 33, 3, 3, shirt); filesDrawCuffs(c, shirtD, right: false)
    c.oy += p.gunY
    c.rect(38, 33, 3, 3, shirt); filesDrawCuffs(c, shirtD, left: false)
    c.pattern(40, 31, ["KKKKKKK", "KKCCKK.", "KW.....", "KW....."], ["K": C(0x2A2A30), "C": C(0x6A6E78), "W": C(0x6A4428)])
}

// MARK: - Queequeg

/// Queequeg: Scrawly's Pomeranian. A small, round ball of Clawd-orange fluff, his round face ringed in a paler ruff, little
/// ears, a short muzzle and a black button nose and a plume of a tail curled over his back, on four little legs. He bites (in a fight he lunges,
/// jaws open). Signature: he yaps, bouncing on the spot with each yap.
private func drawQueequeg(_ c: PixelCanvas, _ p: Pose) {
    let fur = clawdOrange, furL = C(0xF0A07A), furD = clawdShade
    let sig = p.signature
    let yapping = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false
    let yap = yapping && sin(p.t * 14) > 0
    let open: Double = max(p.melee.map { a in max(0, 1 - abs(a - 5) / 45) } ?? 0, yap ? 0.7 : 0)
    let lunge = p.melee != nil ? Int((3 * open).rounded()) : 0
    if yap { c.oy -= 1 }
    // Four little legs, half hidden in the fluff.
    for (i, lx) in [22, 25, 31, 34].enumerated() {
        let lifted = p.step >= 0 && i % 2 == p.step
        c.rect(lx + lunge, 39, 2, lifted ? 3 : 4, furD)
        c.rect(lx + lunge, lifted ? 41 : 42, 2, 1, furL)
    }
    c.oy += p.breathe
    c.ox += lunge
    // The tail: a plume curled up over the back.
    c.pattern(16, 25, ["..LLLL..", ".LFFFFL.", "LFFLFFFL", "LFF..FFL", ".LF...F.", "..F....."], ["F": fur, "L": furL])
    // The body: a round puff of fluff.
    c.pattern(19, 29, [
        "...FFFFFFFFFFF....",
        ".FFFFFFFFFFFFFFR..",
        "FFFFFFFFFFFFFFFRR.",
        "FFFFFFFFFFFFFFFRRR",
        "FFFFFFFFFFFFFFFRRR",
        "FFFFFFFFFFFFFFRRR.",
        ".FFFFFFFFFFFFFRR..",
        "..DDDDDDDDDDDDD...",
        "...DDDDDDDDDDD....",
    ], ["F": fur, "R": furL, "D": furD])
    // The head: round, ringed in a ruff of paler fluff, little ears, a short muzzle and the button nose.
    c.pattern(31, 21, [
        "..E.....E...",
        ".EEF...FEE..",
        "RFFFFFFFFFR.",
        "RFFkFFFFkFFR",
        "RFFFFFFFFFFN",
        "RFFFFFLLLLF.",
        ".RRFFFFFFFR.",
        "..RRRRRRRR..",
        "...RRRRRR...",
    ], ["E": furD, "F": fur, "k": C(0x16161B), "N": C(0x16161B), "L": furL, "R": furL])
    let o = Int((3 * open).rounded())
    if o > 0 {
        c.rect(37, 27, 5, o, C(0x7A1A22)); c.px(41, 27, white)
        c.rect(36, 27 + o, 6, 1, furL)
    }
    c.ox -= lunge
    if yap {
        // The yap: little bark lines in front of his nose.
        c.px(46, 25, white); c.px(47, 24, white); c.px(46, 28, white); c.px(48, 28, white); c.px(47, 31, white)
    }
}

// MARK: - Daggoo

/// Daggoo: Clawder's goldfish, in a round glass bowl that floats along on its own (it can't sit). A Clawd-orange fish
/// with a fan tail, swimming back and forth past the weed and the pebbles. No weapon. Signature: he swims up to the
/// surface and blows a bubble that floats up out of the bowl and pops.
private func drawDaggoo(_ c: PixelCanvas, _ p: Pose) {
    let glass = C(0xC8F0FF, 0.55), rim = C(0xE8FAFF), water = C(0x3A8ACA, 0.45), weed = C(0x3A8A4A)
    let sig = p.signature
    c.oy += p.breathe
    let cx = 28, cy = 33, r = 10
    // The water, a little below the rim, and the glass round it.
    for y in (cy - r)...(cy + r) {
        let dy = Double(y - cy), hw = Int((Double(r * r) - dy * dy).squareRoot().rounded())
        if y >= cy - r + 4 { c.rect(cx - hw, y, hw * 2 + 1, 1, water) }
        c.px(cx - hw, y, glass); c.px(cx + hw, y, glass)
    }
    c.rect(cx - 6, cy - r, 13, 1, rim); c.rect(cx - 7, cy - r + 1, 1, 1, rim); c.rect(cx + 7, cy - r + 1, 1, 1, rim)
    c.rect(cx - 7, cy + r - 1, 15, 1, C(0x8AB8D0, 0.8)); c.rect(cx - 5, cy + r, 11, 1, C(0x8AB8D0, 0.8))
    c.px(cx - 6, cy - 4, C(0xFFFFFF, 0.8)); c.px(cx - 6, cy - 3, C(0xFFFFFF, 0.6))   // a glint on the glass
    // Pebbles and a frond of weed.
    for (i, x) in [cx - 6, cx - 3, cx, cx + 3, cx + 5].enumerated() { c.rect(x, cy + r - 2, 2, 1, [C(0xD8B47A), C(0x8A8E98), C(0xC86A4A)][i % 3]) }
    for k in 0..<5 { c.px(cx - 4 + Int(sin(p.t * 1.5 + Double(k)) * 0.8), cy + r - 3 - k, weed) }
    // The fish: back and forth, or up at the surface in his signature.
    let surfacing = sig.map { $0 > 0.05 && $0 < 0.9 } ?? false
    let swim = sin(p.lt * 0.9)
    let fx = surfacing ? cx + 1 : cx + Int((swim * 3).rounded())
    let fy = surfacing ? cy - r + 7 : cy + Int(sin(p.lt * 1.7))
    let facing = surfacing || cos(p.lt * 0.9) >= 0
    // A proper goldfish, big enough to read through the glass: fan tail, fins, a pale belly, an eye.
    let right = [
        "....dFd....",
        "TT.FFFFFw..",
        "TTTFFFFFFk.",
        "TTTFFFFLFFF",
        "TT.FFLLLF..",
        ".....dd....",
    ]
    let body = facing ? right : right.map { String($0.reversed()) }
    c.pattern(fx - 5, fy - 3, body, ["F": clawdOrange, "T": C(0xF0A07A), "d": clawdShade, "L": C(0xF8C8A0),
                                     "w": C(0xFFFFFF, 0.9), "k": C(0x16161B)])
    // Bubbles: a few always, and the big one in the signature, rising out of the bowl and popping.
    for i in 0..<2 {
        let f = frac(p.lt * 0.35 + Double(i) * 0.5)
        c.px(fx + (facing ? 5 : -5) - i, fy - 2 - Int(f * 10), C(0xE8FAFF, 0.7 * (1 - f)))
    }
    if let s = sig, s > 0.3, s < 0.92 {
        let k = (s - 0.3) / 0.62, by = cy - r + 4 - Int(k * 16)
        if k < 0.85 {
            c.circle(cx + 2, by, 2, C(0xE8FAFF, 0.35)); c.px(cx + 1, by - 1, C(0xFFFFFF, 0.9))
        } else {
            for (dx, dy) in [(-2, 0), (2, 0), (0, -2), (0, 2), (-1, -1), (1, 1)] { c.px(cx + 2 + dx, by + dy, C(0xFFFFFF, 0.8)) }
        }
    }
}
