import Foundation

// Heroes: Charlie and the Chocolate Factory and Alice in Wonderland. From the factory: Willy Wonky in his top hat and
// velvet coat, Charlie Buckett with the golden ticket, Grampa Joe, an Oompa-Loompah and Dr. Wilbur Wonky the dentist.
// From Underland: Alice Kingsclawd with the Vorpal sword, Tarrant Hightop the Hatter, Chessur the grinning cat, Mirana
// the White Queen, McTwisp the White Rabbit, Mally the Dormouse and Thackery Hare. The people are Clawd in costume;
// the animals keep their own shapes at Clawd's size.

let burtonHeroes5: [BurtonHero: Persona] = [
    .willyWonky: Persona(name: "Willy Wonky", weapon: .blaster, shot: .thrown(C(0x8A3ACA)), muzzle: (44, 28),
                         headTop: 11, signature: 3.6, callout: "Everything's eatable!", draw: drawWillyWonky),
    .charlieBuckett: Persona(name: "Charlie Buckett", weapon: .none, headTop: 21, signature: 3.2, draw: drawCharlie),
    .grampaJoe: Persona(name: "Grampa Joe", weapon: .none, headTop: 21, signature: 3.8, draw: drawGrampaJoe),
    .oompaLoompah: Persona(name: "An Oompa-Loompah", weapon: .none, headTop: 27, signature: 3.2,
                           draw: drawOompaLoompah),
    .drWilburWonky: Persona(name: "Dr. Wilbur Wonky", weapon: .blaster, shot: .thrown(C(0xF4F4F0)), muzzle: (44, 28),
                            headTop: 20, signature: 3.4, draw: drawWilburWonky),
    .aliceKingsclawd: Persona(name: "Alice Kingsclawd", weapon: .saber, headTop: 20, signature: 3.6,
                              callout: "Six impossible things.", draw: drawAlice),
    .tarrantHightop: Persona(name: "Tarrant Hightop", weapon: .blaster, shot: .thrown(C(0x2AB8B0)), muzzle: (45, 27),
                             headTop: 10, signature: 3.4, callout: "Fairfarren!", draw: drawTarrant),
    .chessur: Persona(name: "Chessur", weapon: .none, motion: .hover, canSit: false, headTop: 19, signature: 3.6,
                      callout: "Lost, are we?", draw: drawChessur),
    .mirana: Persona(name: "Mirana the White Queen", weapon: .none, headTop: 17, signature: 3.4, draw: drawMirana),
    .mcTwisp: Persona(name: "McTwisp", weapon: .none, headTop: 12, signature: 3.4, draw: drawMcTwisp),
    .mally: Persona(name: "Mally the Dormouse", weapon: .saber, pivot: smallHand, headTop: 25, signature: 3.0,
                    draw: drawMally),
    .thackeryHare: Persona(name: "Thackery Hare", weapon: .blaster, shot: .thrown(C(0xF4F4F0)), muzzle: (43, 27),
                           headTop: 14, signature: 3.2, draw: drawThackery),
]

/// A small Clawd's hand (the Oompa-Loompah, Mally): Mally's hatpin swings from there.
private let smallHand = (x: 36.5, y: 34.5)

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// Up, held, and back down again over a signature: 0 → 1 between `a` and `b`, 1 → 0 between `c` and `d`.
private func held(_ sig: Double?, _ a: Double, _ b: Double, _ c: Double, _ d: Double) -> Double {
    guard let s = sig else { return 0 }
    return min(ramp(s, a, b), 1 - ramp(s, c, d))
}

/// Clothes over the bottom rows of the Clawd block (y 33…37), shaded down the right and along the hem.
private func clothes(_ c: PixelCanvas, _ col: Px, _ shade: Px) {
    c.rect(18, 33, 20, 5, col); c.rect(37, 33, 1, 5, shade); c.rect(18, 37, 20, 1, shade)
}

/// Pastes `art` (drawn on its own layer) over `c` with every pixel at `alpha`.
private func fadeIn(_ c: PixelCanvas, alpha: Double, _ art: (PixelCanvas) -> Void) {
    guard alpha > 0 else { return }
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    c.paste(s, alpha: alpha)
    c.ox = ox; c.oy = oy; c.baseY = by
}

/// Draws `art` on its own layer and lays it over `c` shrunk to `k` of its size about the point between its feet.
private func shrunk(_ c: PixelCanvas, _ k: Double, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let a = (x: 28.0, y: 44.0 + Double(c.baseY))
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    defer { c.ox = ox; c.oy = oy; c.baseY = by }
    for y in 0..<c.h {
        for x in 0..<c.w {
            let sx = Int(floor(a.x + (Double(x) + 0.5 - a.x) / k)), sy = Int(floor(a.y + (Double(y) + 0.5 - a.y) / k))
            guard sx >= 0, sy >= 0, sx < s.w, sy < s.h else { continue }
            let i = (sy * s.w + sx) * 4, al = s.buf[i + 3]
            guard al > 0 else { continue }
            let m = 255 / Double(al)
            let r = UInt8(min(255, Double(s.buf[i]) * m)), g = UInt8(min(255, Double(s.buf[i + 1]) * m))
            let b = UInt8(min(255, Double(s.buf[i + 2]) * m))
            c.px(x, y, Px(r: r, g: g, b: b, a: al))
        }
    }
}

/// A small Clawd (a 14×9 block at (21, 30)) on short legs, its eyes on the block; applies the breathing bob.
private func smallClawd(_ c: PixelCanvas, _ p: Pose, body: Px, shade: Px, leg: Px, shoe: Px, step: Int? = nil) {
    let st = step ?? p.step
    if seatedPose {
        for lx in [22, 25, 30, 33] { c.rect(lx - 1, 37, 3, 2, leg) }
    } else {
        for (i, lx) in [22, 25, 30, 33].enumerated() {
            let lifted = st >= 0 && i % 2 == st
            c.rect(lx, 39, 2, lifted ? 3 : 4, leg); c.rect(lx, lifted ? 41 : 42, 2, 1, shoe)
        }
    }
    c.oy += p.breathe
    c.rect(21, 30, 14, 9, body); c.rect(21, 38, 14, 1, shade); c.rect(34, 30, 1, 9, shade)
    c.rect(24, 32, 2, 2, ink); c.rect(30, 32, 2, 2, ink)
}

// MARK: - Willy Wonky

/// Willy Wonky: a pale Clawd with a glossy dark pageboy bob and a blunt fringe, a wide toothy smile, a tall black top
/// hat with a plum band, a burgundy velvet coat with long tails, purple gloves, and his cane. He throws chocolate bars
/// in purple wrappers. Signature: he twirls the cane round in his hand, then tips his hat.
private func drawWillyWonky(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x7A1E34), coatD = C(0x561424), coatL = C(0x9E3450), glove = C(0x7A4AB8), gloveD = C(0x5A3290)
    let hair = C(0x1E1618), hairL = C(0x4A3A40), pale = C(0xF2DED4), paleD = C(0xD4BCB0)
    let hat = C(0x18161C), hatL = C(0x3A3644), cane = C(0x3A2228), knob = C(0xD8DCE4)
    let sig = p.signature
    let twirl = sig.map { $0 > 0.08 && $0 < 0.5 } ?? false
    let tip = held(sig, 0.54, 0.62, 0.82, 0.9)
    let armed = sig == nil && (p.fire != nil || p.ready || p.gunLift > 0)

    drawLegs(c, Look(leg: C(0x2A2430)), step: p.step)
    burtonBoots(c, step: p.step, C(0x140F12), height: 2)
    c.oy += p.breathe
    // The velvet coat: long tails over his legs, over the bottom of Clawd, lapels open on a plum waistcoat.
    let tails = seatedPose ? 1 : 3
    c.rect(17, 38, 22, tails, coat); c.rect(17, 37 + tails, 22, 1, coatD); c.rect(28, 38, 1, tails, coatD)
    drawBody(c, Look(body: pale, shade: paleD, arm: glove))
    clothes(c, coat, coatD)
    c.rect(25, 33, 6, 4, C(0x4A2A5A)); c.pattern(23, 33, ["LL......LL", ".LL....LL.", "..L....L.."], ["L": coatL])
    c.px(28, 34, C(0xD8B040)); c.px(28, 36, C(0xD8B040))
    // The wide, toothy smile.
    c.pattern(24, 31, ["K......K", ".WWWWWW."], ["K": ink, "W": C(0xFFFFFF)])
    // The pageboy bob: a blunt fringe straight across above his eyes, the sides cut square at his jaw.
    c.pattern(16, 21, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHHHH...",
        "..HHHHHhHHHHHHHHhHHHHH..",
        ".HHHHHHhHHHHHHHHhHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHHH..............HHHH.",
    ], ["H": hair, "h": hairL])
    // The tall top hat, lifted off his head as he tips it.
    let lift = Int((tip * 3).rounded())
    c.oy -= lift
    c.rect(22, 11, 12, 8, hat); c.rect(23, 11, 1, 8, hatL); c.rect(33, 11, 1, 8, C(0x0C0A10))
    c.rect(22, 17, 12, 2, C(0x6A2A5A)); c.rect(17, 19, 22, 1, hat); c.rect(18, 20, 20, 1, C(0x0C0A10))
    c.oy += lift
    // The right hand: on the hat's brim, raising a chocolate bar to throw, twirling the cane, or leaning on it.
    let h = Sprite.hand
    if tip > 0 {
        burtonLine(c, 39.5, 34, 38.5, Double(26 - lift), coat, 1.2); c.rect(37, 20 - lift, 3, 3, glove)
    } else if armed {
        c.oy += p.gunY
        burtonLine(c, 39.5, 34, 41, 31, coat, 1.2); c.rect(40, 29, 3, 3, glove)
        c.pattern(41, 26, ["BPPP", "BPPP", "BPPP"], ["P": C(0x8A3ACA), "B": C(0x5A321E)])
        c.oy -= p.gunY
    } else if twirl {
        let a = p.t * 900
        let s = burtonReach(h, a, -5), e = burtonReach(h, a, 7)
        burtonLine(c, s.x, s.y, e.x, e.y, cane, 0.7)
        c.circle(Int(e.x.rounded()), Int(e.y.rounded()), 1, knob)
        c.rect(39, 33, 3, 3, glove); c.px(41, 34, gloveD)
    } else {
        burtonLine(c, 41.5, 34, 42.5, seatedPose ? 39.5 : 43.5, cane, 0.7)
        c.rect(40, 31, 3, 2, knob); c.px(42, 31, C(0xA8B0BC)); c.rect(39, 33, 3, 3, glove)
    }
    // The cane in his left hand while the right is busy.
    if tip > 0 || armed { burtonLine(c, 15.5, 35, 13.5, seatedPose ? 39.5 : 43.5, cane, 0.7);
        c.rect(14, 32, 3, 2, knob) }
}

// MARK: - Charlie Buckett

/// Charlie Buckett: Clawd with a mop of short brown hair, a darned oatmeal knitted jumper and a red striped scarf, its
/// end hanging down his front. He doesn't fight. Signature: he holds the golden ticket up high, and it shines.
private func drawCharlie(_ c: PixelCanvas, _ p: Pose) {
    let jumper = C(0x9A8A68), jumperD = C(0x7A6A4A), scarf = C(0xB8302A), scarfL = C(0xE8D8B0)
    let hair = C(0x5A3A22), hairL = C(0x7A5232)
    let up = held(p.signature, 0.08, 0.24, 0.82, 0.94)

    drawLegs(c, Look(leg: C(0x4A4A5A)), step: p.step)
    burtonBoots(c, step: p.step, C(0x3A2A20), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: jumper))
    clothes(c, jumper, jumperD)
    for y in [34, 36] { for x in stride(from: 19 + y % 4, to: 37, by: 4) { c.px(x, y, jumperD) } }
    c.rect(20, 35, 3, 2, C(0x7A8A6A))   // the darned patch
    // The scarf round his neck, its striped end hanging down the front.
    c.rect(18, 32, 20, 2, scarf); c.rect(37, 32, 1, 2, C(0x8E1E1A))
    for x in stride(from: 20, to: 37, by: 4) { c.rect(x, 32, 1, 2, scarfL) }
    c.pattern(31, 34, ["SS", "LL", "SS", "LL", "S.S"], ["S": scarf, "L": scarfL])
    // The short brown mop over the top of him.
    c.pattern(17, 21, [
        "......H..H...H........",
        "...HHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHhHHHHHHhHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHH.HH...HH..H.HHHHH.",
        ".HH...............HHH.",
        ".H.................H..",
    ], ["H": hair, "h": hairL])
    guard up > 0 else { return }
    // The golden ticket held up high in his right hand, glinting when it's right up.
    let ty = 33 - up * 12
    burtonLine(c, 39.5, 34, 41.5, ty + 1, jumper, 1.2); c.rect(40, Int(ty.rounded()) - 1, 3, 3, clawdOrange)
    let tx = 39, tyI = Int(ty.rounded()) - 5
    c.pattern(tx, tyI, ["GGGGGGGG", "GLLLLLLG", "GLddddLG", "GLLLLLLG", "GGGGGGGG"],
              ["G": C(0xE0A820), "L": C(0xFFE070), "d": C(0xB88010)])
    if up > 0.95 {
        let k = 0.5 + 0.5 * sin(p.t * 9), fx = Double(tx) + 6.5, fy = Double(tyI) + 0.5
        c.glowLine(fx, fy, fx, fy, core: C(0xFFFFFF, k), glow: C(0xFFE070, 0.6 * k), coreR: 0.8, glowR: 3.5)
        for a in stride(from: 0.0, to: 2 * .pi, by: .pi / 2) {
            c.glowLine(fx + cos(a) * 1.5, fy + sin(a) * 1.5, fx + cos(a) * 4.5, fy + sin(a) * 4.5,
                       core: C(0xFFFFFF, k), glow: C(0xFFE070, 0.4 * k), coreR: 0.4, glowR: 0.9)
        }
    }
}

// MARK: - Grampa Joe

/// Grampa Joe: an old Clawd in striped blue pyjamas under a brown cardigan, white tufts of hair at his sides, wrinkles,
/// and a tweed flat cap, its peak jutting out in front. He doesn't fight. Signature: his old bed appears beside him,
/// he hops out of it with his arms up, and does a little jig.
private func drawGrampaJoe(_ c: PixelCanvas, _ p: Pose) {
    let pj = C(0xC8D4E8), pjD = C(0x8AA0C8), cardi = C(0x8A5A3A), cardiD = C(0x6A4028), cap = C(0x7A7262)
    let capD = C(0x5A5446), hairW = C(0xF0F0EC)
    let sig = p.signature
    let bed = held(sig, 0.04, 0.16, 0.86, 0.98)
    let hopK = sig.map { $0 > 0.16 && $0 < 0.34 ? sin(ramp($0, 0.16, 0.34) * .pi) : 0 } ?? 0
    let jig = sig.map { $0 >= 0.36 && $0 < 0.86 } ?? false
    let beat = Int(p.t * 6) % 2

    if bed > 0 {
        // The old bed: a wooden headboard, a lumpy patchwork blanket thrown back.
        fadeIn(c, alpha: bed) { b in
            b.rect(2, 29, 3, 15, C(0x6A4A2E)); b.rect(2, 29, 3, 1, C(0x8A6440)); b.rect(13, 38, 2, 6, C(0x6A4A2E))
            b.rect(5, 36, 10, 3, C(0xEEEAE0)); b.rect(5, 35, 4, 2, C(0xFAF8F2))
            b.pattern(8, 34, [".PPRRPP", "PPRRPPGG", "RRPPGGRR"], ["P": C(0x8A6AA0), "R": C(0xB8483A),
                "G": C(0x6A8A5A)])
        }
    }
    let hop = -Int((hopK * 5).rounded()) + (jig ? -beat : 0)
    c.oy += hop
    drawLegs(c, Look(leg: pj), step: jig ? beat : p.step)
    burtonBoots(c, step: jig ? beat : p.step, C(0x6A4A30), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: cardi))
    // The cardigan open over the striped pyjama top; wrinkles under his eyes.
    clothes(c, cardi, cardiD)
    c.pattern(24, 33, ["pppppppp", ".PPPPPP.", "..pppp..", "...PP..."], ["P": pj, "p": pjD])
    c.px(21, 32, clawdShade); c.px(34, 32, clawdShade); c.rect(26, 31, 4, 1, clawdShade)
    for y in [38, 40] where !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx, y, 2, 1, pjD) } }
    // White tufts at his sides, and the flat cap with its peak out in front.
    c.pattern(16, 25, ["WW", "WWW", "WW.", "W.."], ["W": hairW]);
    c.pattern(37, 25, ["WW", "WWW", ".WW", "..W"], ["W": hairW])
    c.pattern(17, 21, [
        "....CCCCCCCCCCCC......",
        "..CCCCCCCCCCCCCCCC....",
        ".CCCcCCCCcCCCCcCCCC...",
        ".CCCCCCCCCCCCCCCCCCCCCC",
        "..dddddddddddddddddddddd",
    ], ["C": cap, "c": capD, "d": capD])
    // Arms: flung up as he hops out, swinging in turn as he jigs, otherwise down.
    if hopK > 0.2 {
        burtonLine(c, 16.5, 34, 13.5, 27, cardi, 1.1); burtonLine(c, 39.5, 34, 42.5, 27, cardi, 1.1)
        c.rect(12, 25, 2, 2, clawdOrange); c.rect(42, 25, 2, 2, clawdOrange)
    } else if jig {
        let ly = beat == 0 ? 27.0 : 33, ry = beat == 0 ? 33.0 : 27
        burtonLine(c, 16.5, 34, 13.5, ly, cardi, 1.1); burtonLine(c, 39.5, 34, 42.5, ry, cardi, 1.1)
        c.rect(12, Int(ly) - 2, 2, 2, clawdOrange); c.rect(42, Int(ry) - 2, 2, 2, clawdOrange)
    }
}

// MARK: - An Oompa-Loompah

/// An Oompa-Loompah: a small Clawd in a neat red jumpsuit with a zip down its front, his black hair combed neat and
/// flat with a side parting, a little smile. He doesn't fight. Signature: a little drum appears in his hands and he
/// dances, stepping side to side and beating out the rhythm on it.
private func drawOompaLoompah(_ c: PixelCanvas, _ p: Pose) {
    let red = C(0xC8282A), redD = C(0x961A1C), hair = C(0x1A1820), hairL = C(0x464452), skin = clawdOrange
    let sig = p.signature
    let drum = held(sig, 0.04, 0.14, 0.86, 0.96)
    let dancing = sig.map { $0 > 0.14 && $0 < 0.86 } ?? false
    let ph = frac(p.t * 2.5), beat = ph < 0.25
    let side = Int(p.t * 1.25) % 2 == 0 ? -1 : 1

    if dancing { c.ox += side; c.oy += beat ? -1 : 0 }
    smallClawd(c, p, body: skin, shade: clawdShade, leg: red, shoe: C(0x1A1A1E),
               step: dancing ? (Int(p.t * 2.5) % 2) : nil)
    // The jumpsuit over the bottom of him, its zip, a white collar.
    c.rect(21, 35, 14, 4, red); c.rect(34, 35, 1, 4, redD); c.rect(21, 38, 14, 1, redD)
    c.rect(27, 35, 1, 3, redD); c.px(27, 35, C(0xD8C8A0))
    c.pattern(26, 34, ["K..K", ".KK."], ["K": C(0x7A2A1A)])
    // The neat flat hair, its side parting.
    c.pattern(20, 27, [
        "...HHHHHHHHHH...",
        ".HHHHhhhhHHHHHH.",
        "HHHHH.HHHHHHHHHH",
        "HHH..........HHH",
        "HH............HH",
    ], ["H": hair, "h": hairL])
    c.rect(18, 35, 3, 2, red)
    guard drum > 0 else { c.rect(35, 35, 3, 2, red); return }
    // The drum in front of him, and the stick beating on it, little beats springing off it.
    fadeIn(c, alpha: drum) { d in
        d.pattern(36, 33, ["SSSSSSS", "WWWWWWW", "RYRRRYR", "RRYRYRR", "RRRYRRR", "WWWWWWW"],
                  ["S": C(0xF4E8C8), "W": C(0xF4F0E8), "R": C(0x3A6AC8), "Y": C(0xE8C040)])
        d.rect(35, 35, 2, 2, red)
        let stick = beat ? (x: 39.0, y: 33.0) : (x: 40.0, y: 29.0)
        burtonLine(d, 36, 34, stick.x, stick.y, C(0xC8A060), 0.5)
    }
    if dancing && beat {
        c.pattern(43, 30, ["W.W", ".W.", "W.W"], ["W": C(0xFFFFFF, 0.8 * (1 - ph * 4))])
    }
}

// MARK: - Dr. Wilbur Wonky

/// Dr. Wilbur Wonky: the stern dentist, Clawd with grey hair swept back, frowning brows, and a dentist's round head
/// mirror strapped to his brow, in a white dentist's coat buttoned up the side. He throws toothbrushes. Signature: he
/// holds up a set of chattering teeth and peers at them, his head mirror glinting.
private func drawWilburWonky(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0xEEF0F0), coatD = C(0xC4C8CC), grey = C(0xB4B4BC), greyD = C(0x8A8A94), metal = C(0xD8E0E8)
    let sig = p.signature
    let up = held(sig, 0.06, 0.2, 0.84, 0.94)
    let glint = sig.map { $0 > 0.3 && $0 < 0.8 ? max(0, sin(ramp($0, 0.3, 0.8) * .pi * 3)) : 0 } ?? 0
    let armed = sig == nil && (p.fire != nil || p.ready || p.gunLift > 0)

    drawLegs(c, Look(leg: C(0x3A3A44)), step: p.step)
    burtonBoots(c, step: p.step, C(0x16161B), height: 1)
    c.oy += p.breathe
    // The coat: its skirt over his legs, buttoned up the side over the bottom of Clawd, a high collar.
    c.rect(17, 38, 22, seatedPose ? 1 : 2, coat); c.rect(17, seatedPose ? 38 : 39, 22, 1, coatD)
    drawBody(c, Look(arm: coat))
    clothes(c, coat, coatD)
    c.rect(18, 33, 20, 1, coatD); c.rect(31, 34, 1, 3, coatD); c.px(33, 34, C(0x9AA0A8)); c.px(33, 36, C(0x9AA0A8))
    // Stern brows, a straight mouth.
    c.pattern(21, 27, ["GGGG......GGGG", "...G......G..."], ["G": greyD]); c.rect(26, 32, 4, 1, C(0x8A3A2A))
    // Grey hair swept back over the top of him.
    c.pattern(17, 21, [
        "....GGGGGGGGGGGGGG....",
        "..GGGGGGGGGGGGGGGGGG..",
        ".GGggggggggggggGGGGGG.",
        ".GGGGGGGGGGGGGGGGGGGG.",
        ".GGG..............GGG.",
        ".GG................GG.",
    ], ["G": grey, "g": greyD])
    // The head mirror on its band: a silver disc with a hole in the middle.
    c.rect(18, 25, 20, 1, C(0x2A2A30))
    c.circle(28, 23, 3, metal); c.rect(28, 22, 2, 1, C(0xFFFFFF)); c.px(28, 23, C(0x4A4A54)); c.px(31, 24, C(0x9AA0A8))
    if glint > 0.3 {
        c.glowLine(29.5, 22.5, 29.5, 22.5, core: C(0xFFFFFF, glint), glow: C(0xFFF6C8, 0.6 * glint), coreR: 1,
            glowR: 3.5)
    }
    // The right hand: holding up the chattering teeth, a toothbrush to throw, or at his side.
    if up > 0 {
        let ty = 33 - up * 7
        burtonLine(c, 39.5, 34, 41.5, ty + 1, coat, 1.2); c.rect(40, Int(ty.rounded()), 3, 2, clawdOrange)
        let open = glint > 0 && Int(p.t * 10) % 2 == 0 ? 1 : 0
        let y0 = Int(ty.rounded()) - 4
        let gums: [Character: Px] = ["P": C(0xE87A8A), "W": C(0xFAFAF4), "g": C(0xB8B8B0)]
        c.pattern(39, y0 - open, [".PPPPPP.", "PWgWgWgP"], gums)
        c.pattern(39, y0 + 2, ["PWgWgWgP", ".PPPPPP."], gums)
    } else if armed {
        c.oy += p.gunY
        burtonLine(c, 39.5, 34, 41, 31, coat, 1.2); c.rect(40, 29, 3, 3, clawdOrange)
        c.pattern(42, 24, ["B", "B", "W", "W", "W", "W"], ["B": C(0x5AA8E8), "W": C(0xF4F4F0)])
        c.oy -= p.gunY
    }
}

// MARK: - Alice Kingsclawd

/// Alice Kingsclawd: Clawd with long straight blonde hair falling down her sides, in a pale blue dress; when she
/// fights, silver armour, and the Vorpal sword, a long bright blade with a gold crossguard. Signature: she drinks from
/// a tiny bottle and shrinks, sparkling, to half her size for a moment, then grows back.
private func drawAlice(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature
    let k = sig.map { min(ramp($0, 0.32, 0.42), 1 - ramp($0, 0.66, 0.78)) } ?? 0
    let drinking = sig.map { $0 > 0.06 && $0 < 0.34 } ?? false
    if k > 0 {
        shrunk(c, 1 - k * 0.5) { aliceFigure($0, p, drinking: false) }
        if k < 0.99 || Int(p.t * 8) % 3 == 0 {
            for i in 0..<5 {
                let a = Double(i) / 5 * 2 * .pi + p.t * 3, r = 6 + (1 - k) * 6
                let x = 28 + Int((cos(a) * r).rounded()), y = 36 + Int((sin(a) * r * 0.7).rounded())
                c.pattern(x - 1, y - 1, [".W.", "WWW", ".W."], ["W": C(0xFFF4C0, 0.6)])
            }
        }
        return
    }
    aliceFigure(c, p, drinking: drinking)
}

private func aliceFigure(_ c: PixelCanvas, _ p: Pose, drinking: Bool) {
    let dress = C(0x7AA8E0), dressD = C(0x5A86C0), hair = C(0xF0D070), hairL = C(0xFFF0A8), hairD = C(0xC8A040)
    let steel = C(0xA8B0BC), steelD = C(0x6A7280), steelL = C(0xDCE2EA)
    let armour = p.mode == .working

    drawLegs(c, Look(leg: armour ? steelD : clawdOrange), step: p.step)
    burtonBoots(c, step: p.step, armour ? steel : C(0x3A3040), height: armour ? 3 : 1)
    c.oy += p.breathe
    if armour {
        drawBody(c, Look(arm: steel))
        clothes(c, steel, steelD)
        c.rect(18, 33, 20, 1, steelL); c.rect(27, 34, 2, 3, steelL); c.rect(18, 36, 20, 1, steelD)
        c.rect(14, 32, 4, 2, steelL); c.rect(38, 32, 4, 2, steel)
    } else {
        // The dress: its skirt over her legs, the bodice over the bottom of Clawd, a white collar.
        c.rect(17, 38, 22, seatedPose ? 1 : 2, dress); c.rect(17, seatedPose ? 38 : 39, 22, 1, dressD)
        drawBody(c, Look(arm: dress))
        clothes(c, dress, dressD)
        c.pattern(24, 33, ["WWWWWWWW", ".WW..WW."], ["W": C(0xF4F4F8)])
    }
    // Long straight blonde hair over the top of her and down her sides.
    c.pattern(16, 20, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHlHHHHHHHHHH....",
        "..HHHHHlHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHH.....HHHHHHHH.",
        ".HHHH..............HHHH.",
    ] + Array(repeating: ".HHd................dHH.", count: 7) + [
        "..Hd................dH..",
    ], ["H": hair, "l": hairL, "d": hairD])
    if drinking {
        // The tiny bottle tipped up to her lips.
        burtonLine(c, 39.5, 34, 35.5, 31.5, armour ? steel : dress, 1.1); c.rect(33, 30, 3, 3, clawdOrange)
        c.pattern(29, 29, [".CC.", "BBBB", "BLBB", "BBBB"], ["C": C(0xC8A070), "B": C(0x5AB0E8), "L": C(0xF4F0E0)])
        return
    }
    if let a = p.melee {
        // The Vorpal sword along its swing, a faint silver smear behind a fast one.
        let h = Sprite.hand
        for (i, ta) in p.trail.enumerated() {
            let e = burtonReach(h, ta, 15)
            c.glowLine(h.x, h.y, e.x, e.y, core: steelL, glow: steelL, coreR: 0.4, glowR: 1.6,
                strength: 0.3 / Double(i + 1))
        }
        let g0 = burtonReach(h, a + 90, 2), g1 = burtonReach(h, a - 90, 2)
        let b0 = burtonReach(h, a, 2), b1 = burtonReach(h, a, 14), tip = burtonReach(h, a, 16.5)
        let s0 = burtonReach(h, a, -2.5)
        burtonLine(c, s0.x, s0.y, h.x, h.y, C(0x5A3A2A), 0.6)
        burtonLine(c, b0.x, b0.y, b1.x, b1.y, steelL, 0.8)
        burtonTriangle(c, (b1.x + cos((a + 90) * .pi / 180), b1.y + sin((a + 90) * .pi / 180)),
                       (b1.x - cos((a + 90) * .pi / 180), b1.y - sin((a + 90) * .pi / 180)), (tip.x, tip.y), steelL)
        burtonLine(c, g0.x, g0.y, g1.x, g1.y, C(0xD8B040), 0.6)
        c.rect(40, 33, 3, 3, clawdOrange)
    } else if armour {
        c.pattern(38, 36, ["G", "GG", ".S", ".S", ".S"], ["G": C(0xD8B040), "S": steelD])
    }
}

// MARK: - Tarrant Hightop

/// Tarrant Hightop: the Hatter, a chalk-white Clawd with wild green eyes ringed in pink, a gap-toothed grin, frizzy
/// orange hair bursting out at his sides and, on top, his tall patched hat with a peach ribbon, pins and the 10/6
/// card in its band; a plum coat and a big floppy bow. He throws hats. Signature: the Futterwacken, a wild little jig,
/// jerking side to side, legs flying and arms flailing.
private func drawTarrant(_ c: PixelCanvas, _ p: Pose) {
    let face = C(0xF4F2EC), faceD = C(0xD4D0C8), frizz = C(0xE8702A), frizzL = C(0xFFA050), frizzD = C(0xB84A18)
    let coat = C(0x5A3A5A), coatD = C(0x3E2840), hat = C(0x5E4E42), hatL = C(0x7E6C5A), hatD = C(0x3E322A)
    let sig = p.signature
    let jig = sig.map { $0 > 0.08 && $0 < 0.9 } ?? false
    let beat = Int(p.t * 10) % 2
    let armed = sig == nil && (p.fire != nil || p.ready || p.gunLift > 0)

    if jig { c.ox += beat == 0 ? -1 : 1; c.oy -= Int((abs(sin(p.t * 5 * .pi)) * 2).rounded()) }
    drawLegs(c, Look(leg: C(0x6A4A7A)), step: jig ? beat : p.step)
    burtonBoots(c, step: jig ? beat : p.step, C(0x7A4A2A), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(body: face, shade: faceD, arm: coat, eye: nil))
    clothes(c, coat, coatD)
    // The big floppy bow at his neck.
    c.pattern(22, 33, ["BBB....BBB", "BBBBKKBBBB", "BBB....BBB"], ["B": C(0xE88A6A), "K": C(0xC8604A)])
    // Wild green eyes ringed in pink, and the gap-toothed grin.
    for ex in [21, 31] {
        c.rect(ex, 28, 4, 1, C(0xE87AA0)); c.rect(ex, 29, 4, 3, C(0x4AC070)); c.rect(ex + 1, 29, 2, 2, ink)
    }
    let grin = jig ? ["K........K", ".WWWW.WWW.", "..KKKKKK.."] : ["K........K", ".WWWW.WWW."]
    c.pattern(23, 31, grin, ["K": ink, "W": C(0xFFFFFF)])
    // The frizzy orange hair bursting out at his sides under the hat.
    c.pattern(12, 23, [
        "..FFFFFFFFFFFFFFFFFFFFFFFFFFF..",
        ".FFLFFF..................FFLFF.",
        "FFFFFF....................FFFFF",
        ".FLFF......................FLFF",
        "FFFDF......................FDFF",
        ".FFFF......................FFF.",
        "FFDF........................FDF",
        ".FFF........................FF.",
        "..FF........................F..",
        "...F...........................",
    ], ["F": frizz, "L": frizzL, "D": frizzD])
    // The tall patched hat, leaning a little and widening towards its top; the ribbon, the 10/6 card, pins.
    for y in 10...23 {
        let w = 12 + (23 - y) * 6 / 13 / 2 * 2, x0 = 28 - w / 2 + (23 - y) / 7
        c.rect(x0, y, w, 1, hat); c.px(x0 + 1, y, hatL); c.px(x0 + w - 1, y, hatD)
    }
    c.rect(22, 19, 13, 3, C(0xF0A07A)); c.rect(22, 21, 13, 1, C(0xC8785A))
    c.pattern(30, 15, ["WWWW", "WKKW", "WWWW"], ["W": C(0xF4F0E0), "K": C(0x4A3A2A)])
    c.rect(24, 12, 3, 3, C(0x6A5A8A)); c.rect(32, 11, 2, 2, C(0x8A6A3A)); c.px(26, 17, C(0xE84040));
    c.px(25, 16, C(0x40C0E8))
    c.rect(16, 24, 25, 1, hat); c.rect(17, 25, 23, 1, hatD)
    // Arms: flailing in the jig, a spare teal hat raised to throw, or down.
    if jig {
        let ly = beat == 0 ? 26.0 : 37, ry = beat == 0 ? 37.0 : 26
        burtonLine(c, 16.5, 34, 12.5, ly, coat, 1.1); burtonLine(c, 39.5, 34, 43.5, ry, coat, 1.1)
        c.rect(11, Int(ly) - 1, 2, 2, face); c.rect(43, Int(ry) - 1, 2, 2, face)
    } else if armed {
        c.oy += p.gunY
        burtonLine(c, 39.5, 34, 41, 31, coat, 1.2); c.rect(40, 30, 3, 2, face)
        c.pattern(39, 25, [".TTT.", ".TTT.", ".tTT.", "TTTTT"], ["T": C(0x2AB8B0), "t": C(0x7AE0D8)])
        c.oy -= p.gunY
    }
}

// MARK: - Chessur

/// Chessur: the Cheshire cat, his own shape at Clawd's size: a round grey-blue block with dark teal stripes, pointed
/// ears, glowing yellow-green eyes and an enormous white grin, floating off the ground on stubby striped legs, his
/// striped tail curling up behind. He doesn't fight. Signature: he fades away until only the grin is left hanging in
/// the air, then comes back.
private func drawChessur(_ c: PixelCanvas, _ p: Pose) {
    let fade = held(p.signature, 0.08, 0.34, 0.64, 0.86)
    fadeIn(c, alpha: 1 - fade) { chessurBody($0, p) }
    // The grin, which never fades.
    c.oy += p.breathe
    c.pattern(19, 31, [
        "W.................W",
        "WWWWWWWWWWWWWWWWWWW",
        ".WWgWWgWWgWWgWWgWW.",
        "..WWWWWWWWWWWWWWW..",
        "....WWWWWWWWWWW....",
    ], ["W": C(0xFAFAF4), "g": C(0xA8B0C0)])
    c.oy -= p.breathe
}

private func chessurBody(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0x7A8CAC), furL = C(0x9AACCB), stripe = C(0x3A6A80), eye = C(0xD8F04A)
    // The tail curling up behind him, striped, swaying.
    for i in 0..<16 {
        let f = Double(i) / 15
        let x = 18 - f * 11 + sin(f * 2.5 + p.t * 2) * 1.5, y = 34 - f * 12 + sin(f * .pi) * -2
        burtonLine(c, x, y, x, y, i % 4 < 2 ? fur : stripe, 1.2)
    }
    // Stubby striped legs, dangling as he floats.
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        let lifted = p.step >= 0 && i % 2 == p.step
        c.rect(lx, 38, 2, lifted ? 3 : 4, fur); c.rect(lx, 39, 2, 1, stripe)
    }
    c.oy += p.breathe
    // Pointed ears.
    burtonTriangle(c, (18, 28), (25, 28), (19, 19), fur); burtonTriangle(c, (20, 27), (23, 27), (20.5, 22), C(0xC890A8))
    burtonTriangle(c, (31, 28), (38, 28), (37, 19), fur); burtonTriangle(c, (33, 27), (36, 27), (36.5, 22), C(0xC890A8))
    // The round striped block.
    for y in 25...37 {
        let inset = y == 25 ? 2 : y == 26 ? 1 : 0
        c.rect(18 + inset, y, 20 - inset * 2, 1, fur)
    }
    c.rect(19, 26, 8, 1, furL)
    for x in stride(from: 20, to: 37, by: 4) {
        c.rect(x, 25 + (x % 3), 2, 3, stripe); c.rect(x - 1, 35, 2, 3, stripe)
    }
    c.rect(37, 27, 1, 11, C(0x5A6C8A)); c.rect(15, 32, 3, 3, fur); c.rect(38, 32, 3, 3, fur)
    // Glowing eyes with slit pupils.
    for ex in [21, 31] {
        c.glowLine(Double(ex) + 1.5, 29.5, Double(ex) + 1.5, 29.5, core: eye, glow: eye.alpha(0.3), coreR: 0.5,
                   glowR: 3)
        c.rect(ex, 28, 4, 3, eye); c.rect(ex + 1, 28, 1, 3, ink)
    }
    c.pattern(26, 30, ["PPP", ".P."], ["P": C(0xE87AA0)])
}

// MARK: - Mirana

/// Mirana the White Queen: a pale white Clawd with dark arched brows and black lips, long flowing white hair and a
/// little silver crown, in a white gown with silver trim, sweeping wide over her legs. She harms no living thing, so
/// she doesn't fight. Signature: she floats both hands up into a graceful pose, little sparkles at her fingertips.
private func drawMirana(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xF6ECEA), skinD = C(0xD8CCCC), gown = C(0xE6E4F2), gownD = C(0xB4B0CC), trim = C(0x9A9AB8)
    let hair = C(0xFCFCFE), hairD = C(0xC0C0D6), lips = C(0x1A1418)
    let lift = held(p.signature, 0.08, 0.36, 0.76, 0.94)

    drawLegs(c, Look(leg: skinD), step: p.step)
    burtonBoots(c, step: p.step, trim, height: 1)
    c.oy += p.breathe
    // The gown sweeping wide over her legs.
    let skirt = seatedPose ? 1 : 3
    for y in 38..<(38 + skirt) { let hw = 11 + (y - 38); c.rect(28 - hw, y, hw * 2, 1, y == 37 + skirt ? gownD : gown) }
    drawBody(c, Look(body: skin, shade: skinD, arm: gown))
    clothes(c, gown, gownD)
    c.rect(18, 33, 20, 1, trim); c.pattern(25, 34, ["T....T", ".TTTT."], ["T": trim])
    // Dark arched brows, black lips.
    c.pattern(21, 27, ["KKK.......KKK"], ["K": C(0x3A3040)])
    c.pattern(26, 31, ["KKKK", ".KK."], ["K": lips])
    // Long flowing white hair and the little silver crown.
    c.pattern(16, 20, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        ".HHHHHdHHHHHHHHHHdHHHHH.",
        ".HHHHHHHH......HHHHHHHH.",
        ".HHHH..............HHHH.",
    ] + Array(repeating: ".HHd................dHH.", count: 6) + [
        ".HHd................dHH.",
        "..Hd................dH..",
    ], ["H": hair, "d": hairD])
    c.pattern(24, 17, ["S..S..S", "SSSSSSS", ".SSBSS."], ["S": C(0xC8CCDC), "B": C(0x8AB8E8)])
    guard lift > 0 else { return }
    // Hands floating up and out, wrists bent; sparkles twinkling at her fingertips.
    let ly = 34 - lift * 10, lx = 16.5 - lift * 4, rx = 39.5 + lift * 4
    burtonLine(c, 16.5, 34, lx, ly, gown, 1.0); burtonLine(c, 39.5, 34, rx, ly, gown, 1.0)
    c.rect(Int(lx.rounded()) - 2, Int(ly.rounded()) - 1, 2, 2, skin);
    c.rect(Int(rx.rounded()) + 1, Int(ly.rounded()) - 1, 2, 2, skin)
    if lift > 0.9 {
        for (i, sx) in [lx - 3, rx + 3].enumerated() {
            let k = 0.5 + 0.5 * sin(p.t * 6 + Double(i) * 2)
            let x = Int(sx.rounded()), y = Int(ly.rounded()) - 4
            c.pattern(x - 1, y - 1, [".W.", "WWW", ".W."], ["W": C(0xFFFFFF, k * 0.9)])
        }
    }
}

// MARK: - McTwisp

/// McTwisp: the White Rabbit, his own shape at Clawd's size: a white furry block for a head, tall ears with pink
/// insides standing up on top, a pink nose and whiskers, a red waistcoat with gold buttons and the chain of his pocket
/// watch, on four white legs. He doesn't fight. Signature: he pulls out the pocket watch and checks it, then hops
/// anxiously on the spot.
private func drawMcTwisp(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0xF6F4F0), furD = C(0xD6D0C8), pink = C(0xF0A8B0), vest = C(0xA8282A), vestD = C(0x7A1A1C)
    let gold = C(0xE0B030)
    let sig = p.signature
    let watch = held(sig, 0.06, 0.16, 0.4, 0.48)
    let hopping = sig.map { $0 > 0.48 && $0 < 0.92 } ?? false
    let hop = hopping ? -Int((abs(sin(ramp(sig ?? 0, 0.48, 0.92) * .pi * 3)) * 3).rounded()) : 0

    c.oy += hop
    drawLegs(c, Look(leg: fur), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx, 43, 2, 1, furD) } }
    c.oy += p.breathe
    // The tall ears, standing up; flicking back while he hops.
    let flick = hopping && hop < -1 ? 1 : 0
    c.rect(20 - flick, 13 + flick, 4, 14, fur); c.rect(21 - flick, 15 + flick, 2, 10, pink)
    c.rect(31, 12 + flick, 4, 15, fur); c.rect(32, 14 + flick, 2, 11, pink); c.rect(34, 12 + flick, 1, 15, furD)
    drawBody(c, Look(body: fur, shade: furD, arm: fur))
    // The nose, whiskers and buck teeth.
    c.rect(27, 31, 2, 1, C(0xE8788A)); c.rect(27, 32, 2, 1, C(0xFFFFFF))
    c.pattern(23, 30, ["GG........GG", "..G......G.."], ["G": C(0xA8A8B0)])
    // The waistcoat and the watch chain.
    clothes(c, vest, vestD)
    c.pattern(25, 33, ["WWWWWW", ".WWWW."], ["W": C(0xF4F4F8)]); c.px(28, 35, gold); c.px(28, 37, gold)
    c.pattern(29, 35, ["GG..", "..GG"], ["G": gold])
    guard watch > 0 else { return }
    // The pocket watch held up to his face, its hand ticking round.
    let wy = 34 - watch * 6
    burtonLine(c, 39.5, 34, 41, wy + 1, fur, 1.1)
    let cx = 42, cy = Int(wy.rounded()) - 2
    c.circle(cx, cy, 3, gold); c.circle(cx, cy, 2, C(0xFAF8F0)); c.px(cx, cy - 4, gold)
    let a = p.t * 4
    c.px(cx, cy, ink); c.px(cx + Int((cos(a) * 1.6).rounded()), cy + Int((sin(a) * 1.6).rounded()), ink)
}

// MARK: - Mally the Dormouse

/// Mally the Dormouse: a small Clawd as a dormouse, sandy fur, big round ears with pink insides, a pink nose and
/// whiskers, a red tunic with a belt, and her hatpin for a sword, a long silver pin with a pearl on its end. Fierce.
/// Signature: she brandishes the hatpin, high, thrust, thrust, high again.
private func drawMally(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0xD8C4A0), furD = C(0xB09A78), pink = C(0xF0A0A8), tunic = C(0xB8282A), tunicD = C(0x8A1A1C)
    let sig = p.signature
    var angle = p.melee
    if let s = sig, s > 0.06 && s < 0.92 {
        let keys: [(Double, Double)] = [(0.06, -60), (0.22, -95), (0.36, 0), (0.46, -30), (0.58, 0), (0.7, -100),
                                        (0.92, -60)]
        for i in 0..<(keys.count - 1) where s >= keys[i].0 && s < keys[i + 1].0 {
            let f = (s - keys[i].0) / (keys[i + 1].0 - keys[i].0), e = f * f * (3 - 2 * f)
            angle = keys[i].1 + (keys[i + 1].1 - keys[i].1) * e
        }
    }
    // The tail curling behind her.
    burtonLine(c, 20, 37, 16, 35, pink, 0.5); burtonLine(c, 16, 35, 15, 32, pink, 0.5)
    c.circle(23, 28, 3, fur); c.rect(22, 27, 2, 2, pink); c.circle(32, 28, 3, fur); c.rect(32, 27, 2, 2, pink)
    smallClawd(c, p, body: fur, shade: furD, leg: fur, shoe: furD)
    // The snout, nose and whiskers.
    c.rect(35, 33, 2, 2, fur); c.px(36, 33, pink)
    c.pattern(33, 32, ["...GG", ".....", "...GG"], ["G": C(0x8A7A6A)])
    // The tunic and its belt.
    c.rect(21, 35, 14, 4, tunic); c.rect(34, 35, 1, 4, tunicD); c.rect(21, 37, 14, 1, C(0x5A3A22))
    c.px(27, 37, C(0xD8B040)); c.rect(18, 35, 3, 2, fur)
    // The hatpin: swung along its angle, or tucked in her belt.
    if let a = angle {
        let h = smallHand
        for (i, ta) in p.trail.enumerated() {
            let e = burtonReach(h, ta, 13)
            c.glowLine(h.x, h.y, e.x, e.y, core: C(0xE8ECF4), glow: C(0xE8ECF4), coreR: 0.4, glowR: 1.4,
                       strength: 0.25 / Double(i + 1))
        }
        let s0 = burtonReach(h, a, -2), e = burtonReach(h, a, 13)
        burtonLine(c, h.x, h.y, e.x, e.y, C(0xD8DCE4), 0.55)
        c.circle(Int(s0.x.rounded()), Int(s0.y.rounded()), 1, C(0xF8F4F0))
        c.rect(35, 34, 3, 2, fur)
    } else {
        c.rect(35, 35, 3, 2, fur)
        burtonLine(c, 22, 39, 33, 35, C(0xD8DCE4), 0.5); c.circle(21, 39, 1, C(0xF8F4F0))
    }
}

// MARK: - Thackery Hare

/// Thackery Hare: the March Hare, his own shape at Clawd's size: a ragged tan furry block for a head, long tatty ears
/// (one bent over), wild staring eyes that don't match, buck teeth, a frayed olive jacket, and a teapot always in his
/// hand. He twitches. He throws teacups. Signature: he flings a teacup over his shoulder without looking, and it sails
/// away behind him and smashes.
private func drawThackery(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0xB0926A), furD = C(0x7E6444), furL = C(0xCCB088), jacket = C(0x6A6A3E), jacketD = C(0x4A4A2A)
    let china = C(0xF4F4F0), blue = C(0x5A7AC8)
    let sig = p.signature
    let fling = sig.map { ramp($0, 0.12, 0.34) } ?? 0
    let flying = sig.map { ramp($0, 0.3, 0.72) } ?? 0
    let armed = sig == nil && (p.fire != nil || p.ready || p.gunLift > 0)
    let twitch = noise(Int(p.lt * 5)) > 0.82

    if let s = sig, s >= 0.72 && s < 0.9 {
        let k = ramp(s, 0.72, 0.9)
        for i in 0..<5 {
            let dx = (Double(i) - 2) * (1 + k * 2), x = 9 + Int(dx.rounded()),
                y = 42 - Int((sin(k * .pi) * Double(3 - abs(i - 2))).rounded())
            c.px(x, y, china.alpha(1 - k)); if i % 2 == 0 { c.px(x, y - 1, blue.alpha(1 - k)) }
        }
    }
    if twitch && sig == nil { c.ox += 1 }
    drawLegs(c, Look(leg: fur), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx, 43, 2, 1, furD) } }
    c.oy += p.breathe
    // Long tatty ears: one upright, one bent over at the top; a notch out of it.
    c.rect(20, 14, 4, 13, fur); c.rect(21, 16, 2, 9, C(0xD89090)); c.px(20, 18, C(0, 0))
    c.rect(31, 18, 4, 9, fur); c.rect(32, 20, 2, 6, C(0xD89090))
    c.pattern(31, 14, ["FFFFFF.", "FFFFFFF", "...PPFF", ".....FF"], ["F": fur, "P": C(0xD89090)])
    if twitch { c.rect(31, 14, 4, 4, fur); c.rect(32, 15, 2, 3, C(0xD89090)) }
    // The ragged block, tufts sticking out at its edges.
    drawBody(c, Look(body: fur, shade: furD, arm: fur, eye: nil))
    for y in stride(from: 26, through: 32, by: 3) { c.px(17, y, fur); c.px(38, y + 1, furD) }
    c.pattern(20, 26, ["L.L..L...L.L..L.L"], ["L": furL])
    // Wild mismatched eyes, buck teeth.
    c.rect(21, 28, 4, 4, C(0xFAF6E8)); c.rect(23, 29, 1, 1, ink)
    c.rect(31, 29, 3, 3, C(0xFAF6E8)); c.px(31, 30, ink)
    c.rect(26, 32, 4, 1, C(0x5A3A2A)); c.rect(27, 33, 2, 1, C(0xFFFFFF))
    // The frayed jacket.
    clothes(c, jacket, jacketD)
    c.rect(27, 33, 2, 1, C(0xFFFFFF)); c.rect(21, 34, 3, 2, C(0x8A5A3A))
    c.pattern(18, 38, ["J.JJ.J..JJ.J.JJ..J.J"], ["J": jacket])
    // The right hand: the arm flinging back over his head, a teacup raised to throw, or holding the teapot.
    if fling > 0 && fling < 1 {
        let a = -10 - fling * 160, e = burtonReach((39.5, 33.0), a, 9)
        burtonLine(c, 39.5, 33, e.x, e.y, jacket, 1.1);
        c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 3, 3, fur)
    } else if armed {
        c.oy += p.gunY
        burtonLine(c, 39.5, 34, 41, 31, jacket, 1.1); c.rect(40, 29, 3, 3, fur)
        c.pattern(41, 25, ["WWWW", "WBBWW", "WWWW.", ".WW.."], ["W": china, "B": blue])
        c.oy -= p.gunY
    } else {
        c.rect(38, 33, 3, 3, fur)
        c.pattern(39, 34, ["..WW...", ".WWWW..", "WWBBWWW", "WBWWBW.", "WWWWWW.", ".WWWW.."], ["W": china, "B": blue])
    }
    // The teacup sailing over his shoulder behind him, spinning, before it smashes.
    if flying > 0 && flying < 1 {
        let x = 36 - flying * 27, y = 22 - sin(flying * .pi) * 10 + flying * flying * 18
        let cup = Int(p.t * 12) % 2 == 0 ? ["WWWW.", "WBBWW", ".WW.."] : [".WW..", "WBBWW", "WWWW."]
        c.pattern(Int(x.rounded()) - 2, Int(y.rounded()) - 1, cup, ["W": china, "B": blue])
    }
}
