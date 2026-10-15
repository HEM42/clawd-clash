import Foundation

// Heroes: Hook. Peter Panning and the Lost Boys, Jack Banning and old Tootles. Clawd in costume like the rest of the
// cast: hair, caps and clothes over the blocky body, Clawd's own orange face showing; Tinkerbelle is Clawd too, only
// shrunk to fairy size and glowing.

let clawdbergHeroes7: [ClawdbergHero: Persona] = [
    .peterPanning: Persona(name: "Peter Panning", weapon: .saber, motion: .fly, headTop: 21, signature: 3.0,
                           callout: "Bangarang!", draw: drawPeterPanning),
    .tinkerbelle: Persona(name: "Tinkerbelle", weapon: .lightning, motion: .fly,
                          magic: Magic(core: C(0xFFF6C0), glow: C(0xFFC83A), jagged: false, spell: true),
                          canSit: false, pivot: (35, 29), headTop: 21, signature: 3.2, draw: drawTinkerbelle),
    .roofio: Persona(name: "Roofio", weapon: .saber, headTop: 14, signature: 3.4, callout: "Ru-fi-ooo!",
                     draw: drawRoofio),
    .thudButt: Persona(name: "Thud Butt", weapon: .saber, bulk: 3, headTop: 19, signature: 3.0,
                       callout: "Bangarang!", draw: drawThudButt),
    .jackBanning: Persona(name: "Jack Banning", weapon: .saber, headTop: 21, signature: 3.0, draw: drawJackBanning),
    .tootles: Persona(name: "Tootles", headTop: 22, signature: 4.0, draw: drawTootles),
]

// MARK: - Shared bits

private let steel = C(0xD8DEE6), steelD = C(0x9AA2AE), gold = C(0xE8B830)

/// Draws `art` on a fresh canvas of sprite size, its origin at (0, 0).
private func offscreen(_ art: (PixelCanvas) -> Void) -> PixelCanvas {
    let o = PixelCanvas(Sprite.width, Sprite.height)
    art(o)
    return o
}

/// The colour drawn at (`x`, `y`) on `o`, or nil where nothing is.
private func colour(_ o: PixelCanvas, _ x: Int, _ y: Int) -> Px? {
    guard x >= 0, y >= 0, x < o.w, y < o.h else { return nil }
    let i = (y * o.w + x) * 4, a = o.buf[i + 3]
    guard a > 0 else { return nil }
    let m = 255 / Double(a)
    return Px(r: UInt8(min(255, Double(o.buf[i]) * m)), g: UInt8(min(255, Double(o.buf[i + 1]) * m)),
              b: UInt8(min(255, Double(o.buf[i + 2]) * m)), a: a)
}

/// `o` drawn onto `c`, scaled by `scale` so that its point `from` lands on `to`.
private func stamp(_ c: PixelCanvas, _ o: PixelCanvas, scale: Double = 1, from: (x: Double, y: Double) = (28, 43.5),
                   to: (x: Double, y: Double)? = nil) {
    let to = to ?? from
    for y in 0..<o.h {
        for x in 0..<o.w {
            let sx = Int(floor(from.x + (Double(x) + 0.5 - to.x) / scale))
            let sy = Int(floor(from.y + (Double(y) + 0.5 - to.y) / scale))
            guard let col = colour(o, sx, sy) else { continue }
            c.px(x, y, col)
        }
    }
}

/// The whole figure turned by `degrees` about its middle (positive leans it forward, negative back).
private func tilted(_ c: PixelCanvas, _ degrees: Double, _ art: (PixelCanvas) -> Void) {
    let o = offscreen(art)
    stamp(c, o.rotated(degrees, about: (28, 34), into: o.w, o.h, at: (28, 34)))
}

/// A thin sword in the hand at `angle`: a steel blade, a gold crossguard and a dark grip, with the swing's smear.
private func sword(_ c: PixelCanvas, angle: Double, trail: [Double], length: Double = 14, blade: Px = steel,
                   guardCol: Px = gold) {
    cbSmear(c, cbHand, trail, from: 3, to: length, C(0xE8EEF4))
    cbBar(c, cbHand, angle, from: 3, to: length, blade, r: 0.6)
    cbBar(c, cbHand, angle, from: -1.5, to: 2, C(0x4A2E1A), r: 0.7)
    let g = cbReach(cbHand, angle, 2.6)
    cbBar(c, g, angle + 90, from: -2, to: 2, guardCol, r: 0.5)
}

/// A four-point twinkle.
private func twinkle(_ c: PixelCanvas, _ x: Int, _ y: Int, _ col: Px) {
    c.px(x, y, white.alpha(Double(col.a) / 255))
    for (dx, dy) in [(1, 0), (-1, 0), (0, 1), (0, -1)] { c.px(x + dx, y + dy, col.alpha(0.6)) }
}

/// Capital letters in a tiny 3×5 pixel font (just the ones the Lost Boys chant), the first one's top-left at (x, y).
private func tinyText(_ c: PixelCanvas, _ text: String, _ x: Int, _ y: Int, _ col: Px) {
    let glyphs: [Character: [String]] = [
        "R": ["RR.", "R.R", "RR.", "R.R", "R.R"],
        "U": ["R.R", "R.R", "R.R", "R.R", "RRR"],
        "F": ["RRR", "R..", "RR.", "R..", "R.."],
        "I": ["RRR", ".R.", ".R.", ".R.", "RRR"],
        "O": ["RRR", "R.R", "R.R", "R.R", "RRR"],
        "-": ["...", "...", "RRR", "...", "..."],
        "!": [".R.", ".R.", ".R.", "...", ".R."],
    ]
    var cx = x
    for ch in text {
        if let g = glyphs[ch] { c.pattern(cx, y, g, ["R": col]) }
        cx += 4
    }
}

// MARK: - Peter Panning

/// Peter Panning: Clawd grown up and remembering, in the green tunic with its ragged leaf hem and a brown belt, green
/// tights and soft brown boots, his hair cropped short; a thin sword with a gold crossguard at his hip, drawn to fight.
/// He flies, leaning into it. Signature: the rooster crow, hands on hips, chest out and head thrown back, the crow
/// ringing out of him.
private func drawPeterPanning(_ c: PixelCanvas, _ p: Pose) {
    if p.flying { tilted(c, 18) { peterPanning($0, p, crowing: false) }; return }
    if let s = p.signature, s > 0.08, s < 0.92 {
        let k = habitArc((s - 0.08) / 0.84, hold: 0.6)
        tilted(c, -10 * k) { peterPanning($0, p, crowing: k > 0.5) }
        if k > 0.8 {
            // The crow: arcs ringing up and out from his lifted face.
            let ring = Int(p.t * 8) % 3
            for i in 0..<3 {
                let x = 39 + i * 3, cy = 24 - i * 2, h = 2 + i
                let a = C(0xFFF6D0, i == ring ? 1 : 0.55)
                c.px(x, cy - h, a); c.px(x, cy + h, a)
                c.rect(x + 1, cy - h + 1, 1, h * 2 - 1, a)
            }
        }
        return
    }
    peterPanning(c, p, crowing: false)
}

private func peterPanning(_ c: PixelCanvas, _ p: Pose, crowing: Bool) {
    let tunic = C(0x3E8A3A), tunicD = C(0x2A6A2A), tunicL = C(0x62AE4E), tights = C(0x2E5A2A)
    let belt = C(0x6A4428), hair = C(0x6A3E22), hairL = C(0x8A5A32)
    drawLegs(c, Look(leg: tights), step: p.step)
    cbBoots(c, step: p.step, C(0x7A5232), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: tunic), armLeft: crowing ? 2 : 0, armRight: crowing ? 2 : 0)
    // The tunic from the chin down, its belt, and the leaf hem hanging over the tops of his legs.
    c.rect(18, 32, 20, 6, tunic); c.rect(37, 32, 1, 6, tunicD)
    c.pattern(25, 32, [".OOOOO.", "..OOO..", "...O..."], ["O": clawdOrange])   // the open neck
    for x in [20, 26, 31, 35] { c.px(x, 33, tunicL); c.px(x + 1, 36, tunicL) }
    c.rect(18, 35, 20, 1, belt); c.px(28, 35, gold)
    for x in stride(from: 18, through: 36, by: 3) {
        c.rect(x, 38, 2, 1, tunic); c.px(x, 39, tunicD)
    }
    if crowing {
        // Chest out: the tunic swells forward a pixel, hands planted on his hips.
        c.rect(38, 32, 1, 4, tunic)
        c.rect(15, 34, 3, 2, clawdOrange); c.rect(38, 34, 3, 2, clawdOrange)
    }
    // Hair cropped short, with a tuft at the front.
    c.pattern(18, 22, [
        "..............HH....",
        "...HHHHHHHHHHHHHHH..",
        ".HHHHhHHHHHHhHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHH",
        "HH................H.",
    ], ["H": hair, "h": hairL])

    if let a = p.melee, !crowing {
        sword(c, angle: a, trail: p.trail)
    } else {
        // Sheathed at his hip: the hilt up, the scabbard hanging behind his front legs.
        c.rect(38, 35, 1, 6, C(0x4A2E1A)); c.rect(37, 34, 3, 1, gold); c.px(38, 33, C(0x4A2E1A))
    }
}

// MARK: - Tinkerbelle

/// Tinkerbelle: a tiny Clawd, a third of everyone else's height, hanging in the air in a golden glow: her blonde hair
/// up in a bun, a green leaf dress and slippers, and gauzy wings buzzing on her back. She fights with fairy dust, a
/// twinkling golden stream. Signature: she loops through the air, sprinkling fairy dust that drifts down behind her.
private func drawTinkerbelle(_ c: PixelCanvas, _ p: Pose) {
    let bobS = sin(p.lt * 3)
    var dx = 0.0
    var lift = 10.0 + (bobS > 0.3 ? 1 : (bobS < -0.3 ? -1 : 0))
    var sprinkling = false
    if let s = p.signature, s > 0.05, s < 0.95 {
        let k = (s - 0.05) / 0.9
        let ang = k * 2 * .pi
        dx = sin(ang) * 9
        lift += (1 - cos(ang)) * 4
        sprinkling = true
    }
    let cx = 28 + dx, feet = 43.5 - lift
    // The glow round her.
    c.glowLine(cx, feet - 6, cx, feet - 6, core: C(0xFFF0A0, 0.3), glow: C(0xFFC83A, 0.45), coreR: 4, glowR: 9)
    let o = offscreen { tinkerbelle($0, p) }
    stamp(c, o, scale: 0.5, to: (cx, feet))
    // Fairy dust: a few motes always drifting down, a whole trail of it while she loops.
    let motes = sprinkling ? 12 : 3
    for k in 0..<motes {
        let f = frac(p.lt * 0.6 + Double(k) / Double(motes))
        var x = cx - 2 + noise(k * 13) * 5
        if sprinkling { x = 28 + sin((p.signature ?? 0) * 2 * .pi - f * 1.5) * 9 }
        let y = feet - 4 + f * 14
        let a = (1 - f) * (0.5 + 0.5 * noise(Int(p.t * 12) + k))
        if (k + Int(p.t * 6)) % 4 == 0 { twinkle(c, Int(x), Int(y), C(0xFFD860, a)) }
        else { c.px(Int(x), Int(y), C(0xFFE890, a)) }
    }
}

private func tinkerbelle(_ c: PixelCanvas, _ p: Pose) {
    let leaf = C(0x58B848), leafD = C(0x3A8A32), hair = C(0xF4D460), hairD = C(0xD4A830)
    // Wings behind her, buzzing.
    let flap = Int(p.t * 20) % 2 == 0
    let film = C(0xDCF4FF, 0.7), vein = C(0xA8DCF4, 0.9)
    let tipA: (Double, Double) = flap ? (4, 8) : (6, 14)
    let tipB: (Double, Double) = flap ? (6, 30) : (4, 24)
    c.glowLine(19, 28, tipA.0, tipA.1, core: film, glow: vein, coreR: 3.2, glowR: 4.2)
    c.glowLine(19, 31, tipB.0, tipB.1, core: film, glow: vein, coreR: 2.4, glowR: 3.4)
    drawLegs(c, Look(leg: clawdOrange), step: p.step)
    cbBoots(c, step: p.step, leafD, height: 2)
    c.oy += p.breathe
    drawBody(c, Look())
    // The leaf dress, pointed petals over the tops of her legs.
    c.rect(18, 32, 20, 6, leaf); c.rect(37, 32, 1, 6, leafD)
    for x in stride(from: 18, through: 36, by: 4) { c.rect(x, 38, 3, 1, leaf); c.px(x + 1, 39, leafD) }
    c.px(22, 32, leafD); c.px(28, 34, leafD); c.px(33, 32, leafD)
    // Blonde hair swept up into a bun.
    c.pattern(17, 16, [
        "........BBBB..........",
        ".......BBBbBB.........",
        "........BBBB..........",
        "....HHHHHHHHHHHHHH....",
        "..HHHHHHHHHHHHhHHHHH..",
        ".HHHHhHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHH..............HHH.",
        ".HH................HH.",
        "..H.................H.",
    ], ["H": hair, "h": hairD, "B": hair, "b": hairD])
}

// MARK: - Roofio

/// Roofio: Clawd with a tall spiked mohawk striped red and black, the sides shaved dark, red war paint under his eyes;
/// a black sleeveless vest with red trim over his bare orange front, chains slung across it, black trousers patched in
/// red. He fights with a sword. Signature: fists pumping in the air while the Lost Boys chant his name, the letters
/// popping up over his head.
private func drawRoofio(_ c: PixelCanvas, _ p: Pose) {
    let vest = C(0x1E1A20), red = C(0xC8262A), redD = C(0x8A1A1E), chain = C(0xB4BAC4), chainD = C(0x6E7480)
    let sig = p.signature
    let chanting = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false
    let pump = chanting && Int(p.t * 4) % 2 == 0

    drawLegs(c, Look(leg: vest), step: p.step)
    if !seatedPose { c.rect(19, 39, 2, 2, red); c.rect(35, 38, 2, 2, red) }   // patches on the knees
    cbBoots(c, step: p.step, C(0x3A2A1E), height: 2)
    c.oy += p.breathe
    let up = chanting ? (pump ? 7 : 5) : 0
    drawBody(c, Look(arm: clawdOrange), armLeft: chanting ? (pump ? 5 : 7) : 0, armRight: up)
    // The open vest and its trim, chains across his chest.
    c.rect(18, 32, 5, 6, vest); c.rect(32, 32, 6, 6, vest)
    c.rect(22, 32, 1, 6, red); c.rect(32, 32, 1, 6, red)
    c.rect(18, 37, 20, 1, vest); c.rect(18, 36, 20, 1, redD)
    for i in 0..<10 { c.px(22 + i, 33 + i / 3, i % 2 == 0 ? chain : chainD) }
    for i in 0..<8 { c.px(23 + i, 35 - i / 4, i % 2 == 0 ? chainD : chain) }
    // War paint, shaved sides and the mohawk: spikes of red and black.
    c.rect(21, 32, 3, 1, red); c.rect(31, 32, 3, 1, red)
    c.rect(18, 26, 5, 2, C(0x3A2A24)); c.rect(33, 26, 5, 2, C(0x3A2A24))
    c.pattern(22, 14, [
        "...R.....R..",
        "..RR..K.RR..",
        ".RRR.KK.RRR.",
        ".RRRKKKRRRR.",
        "KRRRKKKRRRK.",
        "KKRRKKKRRKK.",
        "KKKRRKKRRKKK",
        "RKKRRKKRRKKR",
        "RRKKRRKRKKRR",
        "RRKKRRRRKKRR",
        "RRRKKRRKKRRR",
        "KRRRKKKKRRRK",
        "KKRRRRRRRRKK",
    ], ["R": red, "K": vest])

    if chanting {
        // Both fists up, and the chant over his head: RU… FI… OOO!
        let k = (sig! - 0.06) / 0.88
        let words = ["RU-", "FI-", "OOO!"]
        let i = min(2, Int(k * 3))
        let w = words[i]
        let x = 28 - (w.count * 4 - 1) / 2
        tinyText(c, w, x, 6 - (pump ? 1 : 0), C(0xFFE27A))
        return
    }
    if let a = p.melee { sword(c, angle: a, trail: p.trail, length: 13, guardCol: chainD) }
    else { c.rect(16, 35, 1, 7, chainD); c.rect(15, 34, 3, 1, chain) }   // sword hanging at his left hip
}

// MARK: - Thud Butt

/// Thud Butt: a big, round Clawd, the body wider and softer at the corners, in a patched brown shirt (a red patch, a
/// blue patch, a rope belt) and a shaggy fur cap, on his four short legs. He fights by rolling up into a cannonball
/// and bowling into them, four little feet tucked underneath. Signature: he rolls up into a ball, trundles forward and
/// back, and unrolls.
private func drawThudButt(_ c: PixelCanvas, _ p: Pose) {
    var ball = false
    var roll = 0.0, forward = 0.0
    if let a0 = p.melee, !p.ready, !p.walking {
        var a = a0.truncatingRemainder(dividingBy: 360)
        if a > 180 { a -= 360 }
        if a < -180 { a += 360 }
        if a > -50 && a < 70 { ball = true; roll = (a + 50) * 4; forward = 3 }
    }
    if let s = p.signature, s > 0.1, s < 0.9 {
        let k = (s - 0.1) / 0.8
        ball = true
        forward = sin(k * 2 * .pi) * 7
        roll = forward * 40
    }
    if ball { thudBall(c, p, roll: roll, dx: forward); return }

    let shirt = C(0x8A5A32), shirtD = C(0x6A4224), fur = C(0x5A4232), furL = C(0x7A5A42), rope = C(0xC8A870)
    drawLegs(c, Look(leg: C(0x5A4A3A)), step: p.step)
    cbBoots(c, step: p.step, C(0x3A2A1E), height: 2)
    c.oy += p.breathe
    // The big round body.
    c.rect(15, 25, 26, 13, clawdOrange)
    c.rect(14, 27, 1, 9, clawdOrange); c.rect(41, 27, 1, 9, clawdShade)
    c.rect(15, 37, 26, 1, clawdShade); c.rect(40, 26, 1, 12, clawdShade)
    c.px(15, 25, C(0, 0)); c.px(40, 25, C(0, 0))
    c.rect(11, 32, 3, 3, shirt); c.rect(42, 32, 3, 3, shirt)
    c.rect(11, 35, 3, 1, clawdOrange); c.rect(42, 35, 3, 1, clawdOrange)
    c.rect(21, 29, 2, 3, ink); c.rect(33, 29, 2, 3, ink)
    // The patched shirt over his belly, the rope belt.
    c.rect(15, 32, 26, 6, shirt); c.rect(14, 32, 1, 4, shirt); c.rect(41, 32, 1, 4, shirtD); c.rect(40, 32, 1, 6, shirtD)
    c.rect(18, 33, 3, 3, C(0xB8343A)); c.rect(32, 34, 4, 3, C(0x3A5A9A))
    c.rect(15, 36, 26, 1, rope)
    c.pattern(25, 32, [".OOOOO.", "..OOO.."], ["O": clawdOrange])
    // The shaggy fur cap.
    c.pattern(14, 19, [
        "......FFFfFFFFFFfF......",
        "...FFFFFFFFfFFFFFFFFF...",
        "..FFfFFFFFFFFFFFFFfFFF..",
        ".FFFFFFFFFfFFFFFFFFFFFF.",
        "FFFFfFFFFFFFFFFFFfFFFFFF",
        "FfFFFFFFFFFFFFFFFFFFFFfF",
        ".F.F.F.F.F.F.F.F.F.F.F..",
    ], ["F": fur, "f": furL])
    if p.ready || p.cheering {
        c.rect(42, 28, 3, 4, shirt); c.rect(42, 27, 3, 2, clawdOrange)   // a fist up
    }
}

/// Thud Butt rolled up into a cannonball, `roll` degrees round, `dx` along: patches turning, four feet tucked under.
private func thudBall(_ c: PixelCanvas, _ p: Pose, roll: Double, dx: Double) {
    let shirt = C(0x8A5A32), shirtD = C(0x6A4224), fur = C(0x5A4232)
    let x0 = Int(dx.rounded())
    c.ox += x0
    // Four little feet, tucked under the ball (they still touch the ground).
    for lx in [21, 25, 30, 34] { c.rect(lx, 41, 2, 3, C(0x5A4A3A)); c.rect(lx, 43, 2, 1, C(0x3A2A1E)) }
    let cx = 28.0, cy = 33.0
    c.glowLine(cx, cy, cx, cy, core: shirt, glow: C(0, 0), coreR: 9.6, glowR: 9.7)
    c.glowLine(cx + 3, cy + 3, cx + 3, cy + 3, core: shirtD, glow: C(0, 0), coreR: 5, glowR: 5.1)
    c.glowLine(cx - 1, cy - 1, cx - 1, cy - 1, core: shirt, glow: C(0, 0), coreR: 5.5, glowR: 5.6)
    // Patches and his face going round as he rolls.
    let items: [(Double, Px)] = [(0, clawdOrange), (120, fur), (200, C(0xB8343A)), (290, C(0x3A5A9A))]
    for (base, col) in items {
        let r = (base + roll) * .pi / 180
        let px = cx + cos(r) * 5.5, py = cy + sin(r) * 5.5
        c.rect(Int(px.rounded()) - 1, Int(py.rounded()) - 1, 3, 3, col)
    }
    // Speed lines behind him.
    if abs(dx) > 1 || roll != 0 {
        for (i, y) in [28, 33, 38].enumerated() {
            c.rect(12 - i, y, 4, 1, white.alpha(0.45))
        }
    }
    c.ox -= x0
}

// MARK: - Jack Banning

/// Jack Banning: Clawd in his baseball uniform, white with navy pinstripes and a red number, a navy cap with its bill
/// out front, white trousers to the knee and navy socks. He fights with his wooden bat. Signature: the home run, bat
/// wound back, swung clean through, and the ball sailing up and out of sight.
private func drawJackBanning(_ c: PixelCanvas, _ p: Pose) {
    let uni = C(0xF2F2EE), uniD = C(0xC8CCD4), pin = C(0x3A4A7A), navy = C(0x22305A), red = C(0xC83A3A)
    let wood = C(0xC89A5A), woodD = C(0x8A6438)
    drawLegs(c, Look(leg: uni), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, lifted ? 39 : 40, 2, 3, navy)
        }
    }
    cbBoots(c, step: p.step, C(0x1A1A1E), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: uni))
    // The jersey: pinstripes, piping and a number.
    c.rect(18, 32, 20, 6, uni); c.rect(37, 32, 1, 6, uniD)
    for x in stride(from: 19, through: 36, by: 3) { c.rect(x, 32, 1, 6, pin.alpha(0.55)) }
    c.rect(27, 32, 1, 6, navy)
    c.pattern(30, 33, ["RR", ".R", ".R", ".R"], ["R": red])
    c.rect(18, 37, 20, 1, navy)
    // The cap, its bill out front.
    c.pattern(18, 21, [
        "....NNNNNNNNNNN.....",
        "..NNNNNNNNNNNNNNN...",
        ".NNNNNNNWNNNNNNNNN..",
        "NNNNNNNNNNNNNNNNNNNN",
        "NNNNNNNNNNNNNNNNNNNNNNNNN",
    ], ["N": navy, "W": white])

    let sig = p.signature
    if let s = sig, s > 0.05, s < 0.95 {
        // Wind up, swing through, follow over the shoulder; then the ball's gone.
        var a: Double
        if s < 0.35 { a = -150 + 5 * sin(s * 40) }
        else if s < 0.45 { a = -150 + (s - 0.35) / 0.1 * 170 }
        else if s < 0.6 { a = 20 - (s - 0.45) / 0.15 * 200 }
        else { a = -180 }
        let swinging = s >= 0.35 && s < 0.5
        bat(c, angle: a, trail: swinging ? [a - 35, a - 70] : [], wood: wood, dark: woodD)
        if s < 0.42 {
            // The pitch coming in.
            let k = s / 0.42
            let bx = 70 - k * 22, by = 26 + k * 6
            c.rect(Int(bx), Int(by), 2, 2, white)
        } else if s < 0.85 {
            // Going, going, gone.
            let k = (s - 0.42) / 0.43
            let bx = 46 + k * 26, by = 32 - k * 36
            c.glowLine(bx - 4, by + 5, bx, by, core: white.alpha(0.5), glow: C(0, 0), coreR: 0.4, glowR: 0.5)
            c.rect(Int(bx), Int(by), 2, 2, white); c.px(Int(bx), Int(by), red)
        }
        return
    }
    if let a = p.melee { bat(c, angle: a, trail: p.trail, wood: wood, dark: woodD) }
    else {
        // Resting: the bat upended beside him, its barrel on the ground and his hand on the knob.
        c.rect(41, 30, 1, 1, C(0x2A2A30)); c.rect(41, 31, 1, 4, C(0x2A2A30)); c.rect(41, 35, 1, 3, wood)
        c.rect(40, 38, 3, 6, wood); c.rect(42, 38, 1, 6, woodD); c.rect(39, 32, 3, 3, uni)
    }
}

/// The wooden bat at `angle`: the taped grip, the barrel thickening to its end.
private func bat(_ c: PixelCanvas, angle: Double, trail: [Double], wood: Px, dark: Px) {
    cbSmear(c, cbHand, trail, from: 2, to: 14, C(0xF0E0C0))
    cbBar(c, cbHand, angle, from: -1.5, to: 3, C(0x2A2A30), r: 0.6)
    cbBar(c, cbHand, angle, from: 3, to: 8, wood, r: 0.7)
    cbBar(c, cbHand, angle, from: 8, to: 14, wood, r: 1.2)
    let e = cbReach(cbHand, angle, 14)
    c.px(Int(e.x.rounded()), Int(e.y.rounded()), dark)
    c.rect(39, 33, 3, 3, C(0xF2F2EE))
}

// MARK: - Tootles

/// Tootles: old Clawd, bald on top with white tufts over his ears and big white eyebrows, in a brown cardigan over a
/// shirt and a red bow tie, grey trousers and slippers, leaning on a walking stick, his little blue bag of marbles at
/// his side. He doesn't fight. Signature: he finds his marbles; the bag glows, he peers in, and then, light as a
/// feather, he floats up into the air, turns a happy circle and drifts back down.
private func drawTootles(_ c: PixelCanvas, _ p: Pose) {
    let cardigan = C(0x8A6A4A), cardiganD = C(0x6A4E34), shirt = C(0xEEE8DC), tufts = C(0xF2F2F2)
    let bag = C(0x3A5AAA), bagD = C(0x263E7A), stick = C(0x6A4428)
    let sig = p.signature
    var float = 0.0
    var glowing = false
    if let s = sig, s > 0.05, s < 0.95 {
        glowing = s < 0.45
        if s > 0.35 { float = habitArc((s - 0.35) / 0.6, hold: 0.5) * 12 }
    }
    let up = Int(float.rounded())
    c.oy -= up
    if up > 1 {
        // Floating: a sprinkle of fairy dust falling away under him.
        for k in 0..<5 {
            let f = frac(p.lt * 0.8 + Double(k) / 5)
            c.px(20 + k * 4, 44 + Int(f * 8) - up / 2, C(0xFFE27A, 1 - f))
        }
    }
    drawLegs(c, Look(leg: C(0x8A8A90)), step: p.step)
    cbBoots(c, step: p.step, C(0x7A2E2E), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: cardigan))
    // The cardigan open over his shirt, the bow tie.
    c.rect(18, 32, 20, 6, cardigan); c.rect(37, 32, 1, 6, cardiganD)
    c.rect(25, 32, 6, 6, shirt); c.px(27, 34, cardiganD); c.px(27, 36, cardiganD)
    c.pattern(25, 32, ["RR.RR", "..R..", ], ["R": C(0xC83A3A)])
    c.rect(18, 37, 20, 1, cardiganD)
    // White tufts round the bald top, bushy eyebrows.
    c.pattern(15, 25, ["..TTT", ".TTTT", "TTTTT", "TTTT.", ".TT..", "..T.."], ["T": tufts])
    c.pattern(35, 25, ["TTT..", "TTTT.", "TTTTT", ".TTTT", "..TT.", "..T.."], ["T": tufts])
    c.rect(21, 27, 4, 1, tufts); c.rect(20, 26, 2, 1, tufts); c.rect(31, 27, 4, 1, tufts); c.rect(34, 26, 1, 1, tufts)
    c.rect(22, 26, 12, 1, clawdShade.alpha(0.35))   // the shine of his head
    // The bag of marbles hanging from his left hand.
    c.pattern(13, 35, [".DD.", "BBBB", "BBBB", ".BB."], ["B": bag, "D": bagD])
    if glowing {
        // It's found: a glow from the bag and marbles winking out of it.
        c.glowLine(15, 37, 15, 37, core: C(0xFFF6C0, 0.6), glow: C(0xFFC83A, 0.5), coreR: 1.5, glowR: 4)
        let i = Int(p.t * 5) % 3
        c.px(13 + i, 33 - i, [C(0xE84A4A), C(0x4AE84A), C(0xE8E84A)][i])
    }
    // The walking stick in his right hand.
    if up < 2 {
        c.rect(41, 33, 1, 11, stick); c.rect(39, 32, 3, 1, stick)
    } else {
        c.rect(41, 30, 1, 8, stick); c.rect(39, 29, 3, 1, stick)   // waved about in the air
    }
}
