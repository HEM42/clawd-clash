import Foundation

// Heroes: Charlie and the Chocolate Factory. From the factory: Willy Wonky in his top hat and velvet coat, Charlie
// Buckett with the golden ticket, Grampa Joe, an Oompa-Loompah and Dr. Wilbur Wonky the dentist. Each is Clawd in
// costume.

let burtonHeroes5: [BurtonHero: Persona] = [
    .willyWonky: Persona(name: "Willy Wonky", weapon: .blaster, shot: .thrown(C(0x8A3ACA)), muzzle: (44, 28),
                         headTop: 11, signature: 3.6, callout: "Everything's eatable!", draw: drawWillyWonky),
    .charlieBuckett: Persona(name: "Charlie Buckett", weapon: .none, headTop: 21, signature: 3.2, draw: drawCharlie),
    .grampaJoe: Persona(name: "Grampa Joe", weapon: .none, headTop: 21, signature: 3.8, draw: drawGrampaJoe),
    .oompaLoompah: Persona(name: "An Oompa-Loompah", weapon: .none, headTop: 27, signature: 3.2,
                           draw: drawOompaLoompah),
    .drWilburWonky: Persona(name: "Dr. Wilbur Wonky", weapon: .blaster, shot: .thrown(C(0xF4F4F0)), muzzle: (44, 28),
                            headTop: 20, signature: 3.4, draw: drawWilburWonky),
]

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
