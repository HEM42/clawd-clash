import Foundation

// Villains: Sleepy Hollow and Mars Attacks! From Sleepy Hollow: the Headless Horseclawd in his black armour, Lady
// Van Tassle with her crimson witchcraft, and the Western Woods Crone. From Mars Attacks!: the Martians, a green skull
// of a face under a big pink brain in a glass dome: their Leader, the Ambassador who comes in peace, a Trooper, the
// Spy with her beehive, and the giant Martian Walker.

let burtonVillains4: [BurtonVillain: Persona] = [
    .headlessHorseclawd: Persona(name: "The Headless Horseclawd", weapon: .saber, armoured: true, bulk: 3, headTop: 20,
                                 signature: 3.6, draw: drawHorseclawd),
    .ladyVanTassle: Persona(name: "Lady Van Tassle", weapon: .lightning,
                            magic: Magic(core: C(0xFFC2C2), glow: C(0x9E1B2E), jagged: false, spell: true),
                            pivot: castingHand, headTop: 15, signature: 3.6, draw: drawLadyVanTassle),
    .westernWoodsCrone: Persona(name: "The Western Woods Crone", weapon: .lightning,
                                magic: Magic(core: C(0xF2F2A0), glow: C(0x8F9A2A), jagged: false, touch: true),
                                pivot: castingHand, headTop: 20, signature: 3.4, draw: drawCrone),
    .martianLeader: Persona(name: "The Martian Leader", weapon: .blaster, shot: martianRay, muzzle: rayMuzzle,
                            headTop: 15, signature: 3.2, callout: "Ack! Ack!", draw: drawMartianLeader),
    .martianAmbassador: Persona(name: "The Martian Ambassador", weapon: .blaster, shot: martianRay, muzzle: rayMuzzle,
                                headTop: 15, signature: 4.0, callout: "We come in peace!", draw: drawMartianAmbassador),
    .martianTrooper: Persona(name: "A Martian Trooper", weapon: .blaster, shot: martianRay, muzzle: rayMuzzle,
                             headTop: 15, signature: 3.0, draw: drawMartianTrooper),
    .martianSpy: Persona(name: "The Martian Spy", weapon: .lightning,
                         magic: Magic(core: C(0xFFE0F0), glow: C(0xF07AB8), jagged: false, rings: true),
                         pivot: spyStare, headTop: 7, signature: 3.6, draw: drawMartianSpy),
    .martianWalker: Persona(name: "The Martian Walker", weapon: .blaster, shot: martianRay, armoured: true,
                            canSit: false, muzzle: (52, 30.5), bulk: 4, headTop: 13, signature: 4.0,
                            draw: drawMartianWalker),
]

/// Every Martian ray gun fires the same green ray with a yellow core.
private let martianRay = ShotStyle.beam(core: C(0xFFF07A), glow: C(0x3AE05A))
/// The tip of a Martian ray gun held up to fire.
private let rayMuzzle = (x: 50.5, y: 30.5)
/// A witch's raised right hand: her magic leaves from there (raised by `armRaise`).
private let castingHand = (x: 42.5, y: 31.5)

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// Up between `a` and `b`, held, and back down between `c` and `d`.
private func swell(_ s: Double?, _ a: Double, _ b: Double, _ c: Double, _ d: Double) -> Double {
    guard let s else { return 0 }
    return min(ramp(s, a, b), 1 - ramp(s, c, d))
}

/// Draws `art` on a layer of its own, with the canvas's offsets, and lays it over `c` faded to `alpha` (a prop
/// appearing out of nowhere, rather than sliding in from the edge).
private func fadeIn(_ c: PixelCanvas, _ alpha: Double, _ art: (PixelCanvas) -> Void) {
    guard alpha > 0 else { return }
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    c.paste(s, alpha: alpha)
    c.ox = ox; c.oy = oy; c.baseY = by
}

/// A filled ellipse round (cx, cy).
private func hmBlob(_ c: PixelCanvas, _ cx: Double, _ cy: Double, _ rx: Double, _ ry: Double, _ col: Px) {
    for y in Int((cy - ry).rounded(.down))...Int((cy + ry).rounded(.up)) {
        for x in Int((cx - rx).rounded(.down))...Int((cx + rx).rounded(.up)) {
            let dx = (Double(x) + 0.5 - cx) / rx, dy = (Double(y) + 0.5 - cy) / ry
            if dx * dx + dy * dy <= 1 { c.px(x, y, col) }
        }
    }
}

// MARK: - The Headless Horseclawd

/// The Headless Horseclawd: the Hessian, come back without his head. The Clawd block is his body in black armour,
/// riveted plates and a belt, and there's no face on it at all: on top, only the dark collar of his gorget round where
/// his neck should be. A ragged black cloak hangs behind him; his boots have spiked spurs. He fights with a
/// sword; his swings take hats off, never heads. Signature: a jack-o'-lantern appears in his hand, burning; he throws
/// it high and catches it.
private func drawHorseclawd(_ c: PixelCanvas, _ p: Pose) {
    let plate = C(0x2E2E38), plateL = C(0x4E4E5C), plateD = C(0x1A1A20), cloak = C(0x121216), cloakL = C(0x26262E)
    let sig = p.signature
    let held = swell(sig, 0.04, 0.14, 0.86, 0.97)

    // The cloak behind him, ragged at the bottom, stirring.
    let flap = Int(p.t * 3) % 2
    c.oy += p.breathe
    c.rect(13, 26, 6, 13, cloak); c.rect(14, 24, 5, 2, cloak); c.rect(13, 27, 1, 10, cloakL)
    for (i, x) in (12...18).enumerated() { c.rect(x, 39, 1, (i + flap) % 3 == 0 ? 3 : 1 + (i % 2), cloak) }
    c.oy -= p.breathe
    drawLegs(c, Look(leg: C(0x24242C)), step: p.step)
    burtonBoots(c, step: p.step, C(0x0E0E12), height: 3)
    if !seatedPose {
        // The spiked rowels of his spurs at his heels.
        let y = p.step == 0 ? 41 : 42
        for lx in [19, 31] {
            c.px(lx - 1, y, C(0x6A6A76)); c.pattern(lx - 4, y - 1, ["T.T", ".T.", "T.T"], ["T": C(0x9A9AA8)])
        }
    }
    c.oy += p.breathe
    // The armoured body, no face: plates riveted across it, a belt.
    drawBody(c, Look(body: plate, shade: plateD, arm: plate, eye: nil))
    c.rect(18, 26, 19, 1, plateL); c.rect(18, 30, 20, 1, plateD); c.rect(18, 31, 19, 1, plateL)
    c.rect(27, 26, 1, 4, plateD); c.rect(28, 27, 1, 3, plateL)
    for x in stride(from: 20, through: 35, by: 3) { c.px(x, 28, plateL); c.px(x, 33, plateL) }
    c.rect(18, 35, 20, 2, C(0x3A2A1E)); c.rect(27, 35, 2, 2, C(0x8A8A96))
    c.rect(15, 33, 3, 1, plateL)
    // The gorget on top: a dark collar round nothing at all.
    c.pattern(21, 22, ["...GGGGGGGG...", ".GGgKKKKKKgGG.", "GGgKKKKKKKKgGG", "GGGgggggggggGG"],
              ["G": plateL, "g": plate, "K": C(0x060608)])
    // The sword: swinging, or held upright at his shoulder.
    let a = p.melee ?? -100
    for (i, ta) in p.trail.enumerated() {
        let s = burtonReach(Sprite.hand, ta, 4), e = burtonReach(Sprite.hand, ta, 17)
        c.glowLine(s.x, s.y, e.x, e.y, core: C(0xD8DCE6), glow: C(0xD8DCE6), coreR: 0.6, glowR: 1.6,
                   strength: 0.3 / Double(i + 1))
    }
    let side = (x: -sin(a * .pi / 180), y: cos(a * .pi / 180))
    let g = burtonReach(Sprite.hand, a, 2.5), b0 = burtonReach(Sprite.hand, a, 3), b1 = burtonReach(Sprite.hand, a, 14)
    let tip = burtonReach(Sprite.hand, a, 17)
    let pommel = burtonReach(Sprite.hand, a, -2.5)
    burtonLine(c, pommel.x, pommel.y, g.x, g.y, C(0x3A2A1E), 0.7)
    burtonLine(c, b0.x, b0.y, b1.x, b1.y, C(0xB8BCC8), 1.0)
    burtonTriangle(c, (b1.x + side.x * 1.1, b1.y + side.y * 1.1), (b1.x - side.x * 1.1, b1.y - side.y * 1.1),
                   (tip.x, tip.y), C(0xB8BCC8))
    burtonLine(c, b0.x - side.x * 0.4, b0.y - side.y * 0.4, b1.x - side.x * 0.4, b1.y - side.y * 0.4, C(0xE8ECF4), 0.4)
    burtonLine(c, g.x + side.x * 3, g.y + side.y * 3, g.x - side.x * 3, g.y - side.y * 3, C(0x6A6A76), 0.7)
    c.rect(39, 33, 3, 3, plate)
    // The jack-o'-lantern: in his left hand, then thrown high, burning, and caught again.
    if held > 0, let s = sig {
        let k = ramp(s, 0.2, 0.72)
        let h = sin(k * .pi)
        let px = 12.0, py = 27.0 - h * 21
        let up = k > 0 && k < 1 ? 0.0 : 1.0
        burtonLine(c, 17, 34, 14, 30 + (1 - up) * 2, plate, 1.2)
        fadeIn(c, held) { l in
            l.pattern(Int(px) - 3, Int(py.rounded()),
                      ["...s...", ".OOOOO.", "OYOOOYO", "OOOOOOO", "OYYYYYO", ".OOOOO."],
                      ["O": C(0xE87A1E), "Y": C(0xFFE060), "s": C(0x3A5A22)])
            for i in 0..<5 {
                let f = frac(p.t * 3 + Double(i) * 0.37), x = Double(Int(px) - 2 + i)
                let fy = py - 0.5 - f * 3.5
                l.glowLine(x + 0.5, fy, x + 0.5, fy, core: C(0xFFD040, 0.9 * (1 - f)), glow: C(0xFF6A1A, 0.6 * (1 - f)),
                           coreR: 0.5, glowR: 1.2)
            }
        }
        c.rect(12, Int(py.rounded()) + 5, 3, 2, plate)
    }
}

// MARK: - Lady Van Tassle

/// Lady Van Tassle: a pale Clawd, her black hair swept up high into a tight bun, dark painted lips, a wine-red gown
/// with black lace at the neck, its skirt over her legs. She is a witch: she casts crimson witchcraft, a twinkling
/// ribbon of red sparks. Signature: a little iron cauldron appears in front of her, and she stirs it, crimson bubbles
/// rising out of it.
private func drawLadyVanTassle(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xE6C0A6), skinD = C(0xC69E86), gown = C(0x7A1426), gownD = C(0x560C1A), gownL = C(0x9A2436)
    let hair = C(0x141216), hairL = C(0x3A3640), lace = C(0x0E0C10)
    let sig = p.signature
    let pot = swell(sig, 0.04, 0.16, 0.86, 0.97)
    let stirring = sig.map { $0 > 0.16 && $0 < 0.86 } ?? false

    fadeIn(c, pot) { l in
        // The cauldron: black iron on three stubby feet, its brew glowing crimson, bubbles popping.
        l.rect(44, 43, 2, 1, C(0x16161B)); l.rect(51, 43, 2, 1, C(0x16161B))
        hmBlob(l, 48.5, 39, 6, 4.5, C(0x26262E)); l.rect(42, 35, 13, 2, C(0x3A3A44)); l.rect(43, 35, 11, 1, C(0xB01A30))
        l.px(44, 38, C(0x4A4A56)); l.px(45, 37, C(0x4A4A56))
    }
    drawLegs(c, Look(leg: skin), step: p.step)
    burtonBoots(c, step: p.step, C(0x16161B), height: 2)
    c.oy += p.breathe
    // The gown: its skirt over her legs, the bodice over the bottom of the block, black lace at the neck.
    let tails = seatedPose ? 1 : 3
    for y in 38..<(38 + tails) { let hw = 11 + (y - 38); c.rect(28 - hw, y, hw * 2, 1, gown); c.px(27 + hw, y, gownD) }
    drawBody(c, Look(body: skin, shade: skinD, arm: gown))
    c.rect(18, 33, 20, 5, gown); c.rect(37, 33, 1, 5, gownD); c.rect(18, 37, 20, 1, gownD)
    c.pattern(24, 33, ["LLLLLLLL", ".L.L.L.L"], ["L": gownD]); c.rect(18, 36, 20, 1, lace); c.rect(19, 34, 1, 2, gownL)
    // Cold eyes under thin arched brows, and dark painted lips.
    c.pattern(21, 27, [".KK.......KK.", "K.........K.."], ["K": hair])
    c.rect(26, 32, 4, 1, C(0x5A0A18))
    // Black hair drawn tightly up, a high bun on top.
    c.pattern(23, 15, ["...HHHH...", "..HHhHHH..", "..HHHHHH..", "...HHHH..."], ["H": hair, "h": hairL])
    c.pattern(17, 19, [
        "........HHHHH.........",
        ".....HHHHHHHHHHHH.....",
        "...HHHHHhhHHHHHHHHH...",
        "..HHHHHHHHHHHHHhHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HH................HH.",
    ], ["H": hair, "h": hairL])
    // Her right hand: stirring the cauldron with a long stick, raised to cast, or at her side.
    if stirring, pot > 0.5 {
        let a = p.t * 5
        let hx = 46 + cos(a) * 2.5, hy = 31 + sin(a) * 1
        burtonLine(c, 39.5, 34, hx, hy, gown, 1.2); c.rect(Int(hx.rounded()) - 1, Int(hy.rounded()) - 1, 2, 2, skin)
        burtonLine(c, hx, hy, 48.5 + cos(a) * 1.5, 36, C(0x5A3A22), 0.5)
        for i in 0..<3 {
            let f = frac(p.t * 0.9 + Double(i) / 3)
            let x = 46 + Double(i) * 2.5 + sin(f * 6 + Double(i)) * 1.5, y = 34 - f * 12
            c.glowLine(x, y, x, y, core: C(0xFFC2C2, 0.8 * (1 - f)), glow: C(0x9E1B2E, 0.5 * (1 - f)),
                       coreR: 0.6 + f * 0.6, glowR: 1.5 + f)
        }
    } else if p.zap != nil || p.armRaise > 0 {
        let hy = 31.5 - Double(p.armRaise)
        burtonLine(c, 39.5, 34, 41.5, hy + 1, gown, 1.2); c.rect(42, Int(hy) - 1, 2, 2, skin)
    }
}

// MARK: - The Western Woods Crone

/// The Western Woods Crone: a hunched old witch, a grey Clawd with milky, blind-looking eyes and a toothless mouth,
/// long stringy grey hair, and grey-brown rags heaped on her bent back and hanging in tatters over her legs; she
/// leans on a gnarled stick. She casts a sickly charm: a sallow glow at her fingertip and round whoever she points
/// at. Signature: she leans forward on her stick and peers, one milky eye wide.
private func drawCrone(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x98A086), skinD = C(0x727A62), rag = C(0x5A4C3C), ragD = C(0x3C3226), ragL = C(0x76684E)
    let hair = C(0xE2E2DA), hairD = C(0xAEAEA6), milk = C(0xE6EEEC), milkD = C(0xB4C2C4), stick = C(0x5A4028)
    let lean = swell(p.signature, 0.06, 0.2, 0.84, 0.96)
    let peering = lean > 0.6

    drawLegs(c, Look(leg: skinD), step: p.step)
    burtonBoots(c, step: p.step, C(0x2A241E), height: 1)
    let lx = Int((lean * 2).rounded())
    c.ox += lx
    c.oy += p.breathe + (lean > 0.5 ? 1 : 0)
    // The rags: tattered over her legs, wrapped over the bottom of her, heaped up on her bent back.
    if !seatedPose {
        c.pattern(17, 38, ["RRRRRRRRRRRRRRRRRRRRRR", "R.RR.RRR..RR.RRR.R.RR.", "R..R..R....R..R...R.R."], ["R": rag])
    }
    drawBody(c, Look(body: skin, shade: skinD, arm: rag, eye: nil))
    c.rect(18, 33, 20, 5, rag); c.rect(37, 33, 1, 5, ragD)
    c.pattern(18, 33, ["L..L...L..L...L..L..", ".L...L...L...L...L.."], ["L": ragL])
    c.pattern(14, 21, ["...RRRRR....", ".RRRRRRRRR..", "RRRRRrRRRRR.", "RRRRRRRRRRRR", "RRRrRRRRRR..", "RRRRRRR.....",
                       "RRRR........", "RRRR........", "RRrR........",
                       "RRRR........", "RrRR........", "RRRR........"], ["R": rag, "r": ragD])
    // Stringy grey hair from under the rags, down her sides.
    c.pattern(18, 24, ["..HHHHHHHHHHHHHHHHH.", "HHHHHHHHHHHHHHHHHHHH", "HH.H............H.HH", "H..H............H..H",
                       "H..d............d..H", "H...................",
                       "d...................H", "....................d"],
              ["H": hair, "d": hairD])
    // The milky eyes, one wide while she peers; wrinkles, a hooked nose and a sunken mouth.
    if peering {
        c.rect(21, 29, 3, 2, milk); c.rect(21, 30, 3, 1, milkD); c.rect(20, 28, 5, 1, skinD)
        c.rect(31, 27, 4, 5, milk); c.rect(31, 31, 4, 1, milkD); c.px(32, 28, C(0xFFFFFF))
    } else {
        for ex in [22, 32] { c.rect(ex, 29, 2, 3, milk); c.rect(ex, 31, 2, 1, milkD); c.rect(ex - 1, 28, 4, 1, skinD) }
    }
    c.pattern(26, 29, [".NN", "NNN", ".NN"], ["N": skinD])
    c.pattern(25, 33 - 1, ["KKKKK"], ["K": C(0x3A3A32)])
    c.ox -= lx
    // The stick: in her left hand at her side, or out in front with both hands on it as she leans.
    if peering {
        c.rect(44, 26, 2, 18, stick); c.rect(43, 25, 4, 2, stick); c.px(45, 31, C(0x3A2A18)); c.px(44, 37, C(0x3A2A18))
        burtonLine(c, Double(40 + lx), 34, 43, 28, rag, 1.2); c.rect(42, 27, 2, 2, skin)
        burtonLine(c, Double(17 + lx), 34, 42, 30, rag, 1.1)
        return
    }
    c.rect(12, 25, 2, 19, stick); c.rect(11, 24, 4, 2, stick); c.px(12, 30, C(0x3A2A18)); c.px(13, 36, C(0x3A2A18))
    c.rect(13, 33, 3, 3, rag)
    if p.zap != nil || p.armRaise > 0 {
        let hy = 31.5 - Double(p.armRaise)
        burtonLine(c, 39.5, 34, 41.5, hy + 1, rag, 1.2); c.rect(42, Int(hy) - 1, 2, 2, skin)
    }
}

// MARK: - The Martians

private let martianGreen = C(0xA8CC6A), martianShade = C(0x7EA24A)

/// The glass dome on top of a Martian, `rx` wide each side of `cx` and `ry` tall from row `base`, with the big pink
/// brain filling it, a shine on the glass and a silver collar round its base.
private func martianDome(_ c: PixelCanvas, cx: Double = 28, base: Int = 26, rx: Double = 11, ry: Double = 11) {
    let glass = C(0xC8EEF4), pink = C(0xF2A2B8), pinkD = C(0xC86E8E), pinkL = C(0xFFD0DC)
    let by = Double(base)
    for y in (base - Int(ry))..<base {
        for x in Int(cx - rx - 1)...Int(cx + rx + 1) {
            let dx = (Double(x) + 0.5 - cx) / rx, dy = (Double(y) + 0.5 - by) / ry
            let d = dx * dx + dy * dy
            guard d <= 1 else { continue }
            c.px(x, y, d > 0.8 ? glass : glass.alpha(0.18))
        }
    }
    // The brain: two pink lobes, folds wandering over them, the split down the middle.
    let bcx = cx, bcy = by - ry * 0.45, brx = rx * 0.78, bry = ry * 0.5
    for y in Int(bcy - bry)...Int(bcy + bry + 1) {
        for x in Int(bcx - brx - 1)...Int(bcx + brx + 1) {
            let dx = (Double(x) + 0.5 - bcx) / brx, dy = (Double(y) + 0.5 - bcy) / bry
            guard dx * dx + dy * dy <= 1 else { continue }
            let fold = sin(Double(x) * 1.3 + sin(Double(y) * 1.7) * 2.2) + cos(Double(y) * 1.9 + Double(x) * 0.4)
            var col = fold > 1.1 ? pinkD : pink
            if dx < -0.2 && dy < -0.3 && fold < 0.2 { col = pinkL }
            if abs(Double(x) + 0.5 - bcx) < 0.6 && dy < 0.6 { col = pinkD }
            c.px(x, y, col)
        }
    }
    // A shine on the glass, top left, and the silver collar.
    for k in 0..<5 {
        let a = Double.pi * (1.12 + Double(k) * 0.07)
        c.px(Int(cx + cos(a) * rx * 0.72), Int(by + sin(a) * ry * 0.72), C(0xFFFFFF))
    }
    c.rect(Int(cx - rx), base - 1, Int(rx * 2), 2, C(0xB8BCC6)); c.rect(Int(cx - rx), base, Int(rx * 2), 1, C(0x8A8E9A))
}

/// A Martian's face on the block: green, a skull's huge black eyes, cheekbones, two nose holes and a lipless grin
/// of long teeth, the mouth gaping open when `ack`.
private func martianFace(_ c: PixelCanvas, ack: Bool = false) {
    c.pattern(19, 27, [".KKKK.......KKKK.", "KKKKKK.....KKKKKK", "KWKKKK.....KWKKKK", "KKKKKK.....KKKKKK",
                       ".KKKK.......KKKK.", "..s...........s.."], ["K": ink, "W": C(0xFFFFFF), "s": martianShade])
    c.px(27, 31, martianShade); c.px(29, 31, martianShade)
    if ack {
        c.pattern(22, 32, ["KTKTKTKTKTKK", "KKKKKKKKKKKK", "KTKTKTKTKTKK"], ["K": C(0x2A0A10), "T": burtonBone])
    } else {
        c.pattern(22, 32, ["KTTTTTTTTTTK", ".KTKTKTKTKK."], ["K": C(0x2A0A10), "T": burtonBone])
    }
}

/// A Martian: legs, the green block with its skull face, the dome and brain on top; the costume goes on the bottom
/// rows after. Applies the breathing bob.
private func martian(_ c: PixelCanvas, _ p: Pose, suit: Px, leg: Px, boot: Px, ack: Bool = false) {
    drawLegs(c, Look(leg: leg), step: p.step)
    burtonBoots(c, step: p.step, boot, height: 2)
    c.oy += p.breathe
    drawBody(c, Look(body: martianGreen, shade: martianShade, arm: suit, eye: nil))
    martianFace(c, ack: ack)
    martianDome(c)
}

/// A Martian ray gun: silver, red rings round the barrel, the green emitter at its tip; raised to fire, or held
/// pointing down at its side.
private func martianGun(_ c: PixelCanvas, _ p: Pose, sleeve: Px, hand: Px = martianGreen) {
    let pal: [Character: Px] = ["S": C(0xC8CCD6), "s": C(0x8A8E9A), "R": C(0xD8302A), "G": C(0x9AF07A),
                                "F": C(0xD8302A)]
    if p.fire != nil || p.ready || p.gunLift > 0 {
        c.oy += p.gunY
        c.rect(38, 31, 3, 3, sleeve); c.rect(40, 31, 2, 2, hand)
        c.pattern(41, 28, ["..FF......", "SSSSRSRSGG", "SsSSRSRSGG", "Ss........", "ss........"], pal)
        c.oy -= p.gunY
        return
    }
    c.rect(38, 33, 3, 3, sleeve)
    c.pattern(39, 35, ["SS.", "sSF", "SS.", "RR.", "SS.", "RR.", "GG."], pal)
}

/// The Martian Leader: a Martian in a high-collared red cape over a dark green tunic with a gold emblem. He fires a
/// ray gun. Signature: he raises a fist and shakes it, his mouth gaping: "Ack! Ack!"
private func drawMartianLeader(_ c: PixelCanvas, _ p: Pose) {
    let cape = C(0xC0202A), capeD = C(0x8A1018), tunic = C(0x2A3A2A), tunicD = C(0x1A261A), gold = C(0xE0B040)
    let fist = swell(p.signature, 0.06, 0.18, 0.86, 0.96)
    let ack = fist > 0.5 && frac(p.t * 4) < 0.5
    // The cape behind him, its high collar standing up round the dome.
    c.oy += p.breathe
    c.rect(14, 26, 5, 15, cape); c.rect(14, 26, 1, 15, capeD); c.rect(15, 41, 3, 1, capeD)
    burtonTriangle(c, (14, 31), (19, 31), (13, 20), cape); burtonTriangle(c, (37, 31), (42, 31), (43, 20), capeD)
    c.oy -= p.breathe
    martian(c, p, suit: tunic, leg: tunicD, boot: C(0x16161B), ack: ack)
    c.rect(18, 34, 20, 4, tunic); c.rect(37, 34, 1, 4, tunicD); c.rect(18, 37, 20, 1, tunicD)
    c.pattern(26, 34, [".GG.", "GKKG", ".GG."], ["G": gold, "K": cape])
    if fist > 0 {
        let h = 34 - fist * 12 + (fist > 0.9 ? sin(p.t * 22) : 0)
        burtonLine(c, 17, 34, 14, h + 2, tunic, 1.2); c.rect(12, Int(h.rounded()) - 1, 4, 4, martianGreen)
    } else {
        c.rect(15, 33, 3, 3, tunic)
    }
    martianGun(c, p, sleeve: tunic)
}

/// The Martian Ambassador: a Martian in a long white robe, a translator box hung on his chest, its little light
/// blinking. He fires a ray gun. Signature: he lets a white dove go from his hand, and as it flutters up, zaps it
/// into a puff of feathers: "We come in peace!"
private func drawMartianAmbassador(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0xF0EEE6), robeD = C(0xC8C4B8), box = C(0x5A5E68), boxD = C(0x3A3E46)
    let sig = p.signature
    let holding = sig.map { $0 > 0.06 && $0 < 0.3 } ?? false
    let flying = sig.map { $0 >= 0.3 && $0 < 0.62 } ?? false
    let aim = swell(sig, 0.48, 0.55, 0.7, 0.78)
    let zap = sig.map { $0 >= 0.6 && $0 < 0.64 } ?? false
    let puff = sig.map { $0 >= 0.62 && $0 < 0.95 ? ramp($0, 0.62, 0.95) : 0 } ?? 0

    martian(c, p, suit: robe, leg: robeD, boot: C(0xB8B4A8))
    c.rect(17, 38, 22, seatedPose ? 1 : 2, robe)
    c.rect(18, 34, 20, 4, robe); c.rect(37, 34, 1, 4, robeD); c.rect(18, 37, 20, 1, robeD)
    // The translator box on his chest, its grille and blinking light.
    c.rect(24, 34, 8, 4, box); c.rect(31, 34, 1, 4, boxD)
    c.pattern(25, 35, ["K.K.K", ".K.K."], ["K": boxD]); c.px(30, 35, frac(p.t * 1.5) < 0.5 ? C(0x5AF06A) : C(0xD8302A))
    // The dove: on his raised left hand, flying up, or a puff of feathers.
    let dove = { (x: Int, y: Int, up: Bool) in
        c.pattern(x, y, up ? ["W...W.", "WW.WW.", ".WWWWO", "..WW.."] : ["......", "..WW..", "WWWWWO", "..WW.."],
                  ["W": C(0xFAFAF6), "O": C(0xE0A040)])
    }
    var target = (x: 52.0, y: 12.0)
    if holding {
        burtonLine(c, 17, 34, 14, 28, robe, 1.2); c.rect(13, 27, 3, 2, martianGreen); dove(12, 23, frac(p.t * 6) < 0.5)
    } else {
        c.rect(15, 33, 3, 3, robe)
    }
    if flying, let s = sig {
        let k = ramp(s, 0.3, 0.6)
        target = (14 + k * 38, 23 - k * 13 - sin(k * 9) * 1.5)
        dove(Int(target.x.rounded()), Int(target.y.rounded()), frac(p.t * 6) < 0.5)
    }
    if puff > 0 {
        // Feathers drifting down where it was.
        for i in 0..<9 {
            let a = Double(i) / 9 * 2 * .pi
            let r = 1.5 + puff * 5, x = 54 + cos(a) * r, y = 13 + sin(a) * r * 0.7 + puff * puff * 8
            c.px(Int(x.rounded()), Int(y.rounded()), C(0xFAFAF6, 0.95 * (1 - puff)))
        }
    }
    if aim > 0 {
        let lift = Int((aim * 6).rounded())
        c.rect(38, 31 - lift, 3, 3, robe); c.rect(40, 31 - lift, 2, 2, martianGreen)
        c.pattern(41, 28 - lift, ["SSSSRSRSGG", "SsSSRSRSGG", "Ss........"],
                  ["S": C(0xC8CCD6), "s": C(0x8A8E9A), "R": C(0xD8302A), "G": C(0x9AF07A)])
        if zap {
            c.glowLine(51, Double(29 - lift), 54, 13, core: C(0xFFF07A), glow: C(0x3AE05A), coreR: 0.6, glowR: 2.2)
        }
        return
    }
    martianGun(c, p, sleeve: robe)
}

/// A Martian Trooper: a Martian in a silver spacesuit, a dark belt and shoulder pads, silver boots. He fires a ray
/// gun. Signature: he spins the ray gun round his finger like a gunslinger.
private func drawMartianTrooper(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0xC0C4CE), suitD = C(0x8A8E9A), suitL = C(0xE4E8F0), belt = C(0x2A2E36)
    let spin = p.signature.map { $0 > 0.1 && $0 < 0.9 } ?? false
    martian(c, p, suit: suit, leg: suitD, boot: suitL)
    c.rect(18, 34, 20, 4, suit); c.rect(37, 34, 1, 4, suitD); c.rect(18, 37, 20, 1, suitD)
    c.rect(18, 34, 20, 1, suitL); c.rect(18, 36, 20, 1, belt); c.rect(27, 36, 2, 1, C(0x5AF06A))
    c.rect(16, 32, 4, 2, suitL); c.rect(36, 32, 4, 2, suitD)
    c.rect(15, 33, 3, 3, suit)
    guard spin, let s = p.signature else { martianGun(c, p, sleeve: suit); return }
    // The gun twirling round his finger, his arm held out so it spins clear of his face.
    c.rect(38, 31, 3, 3, suit); c.rect(41, 31, 3, 2, suit); c.rect(44, 31, 2, 2, martianGreen)
    let g = PixelCanvas(c.w, c.h)
    g.pattern(41, 30, ["SSSSRSRSGG", "SsSSRSRSGG", "Ss........", "ss........"],
              ["S": C(0xC8CCD6), "s": C(0x8A8E9A), "R": C(0xD8302A), "G": C(0x9AF07A)])
    let angle = -ramp(s, 0.1, 0.9) * 360 * 3
    c.paste(g.rotated(angle, about: (43.5, 31.5), into: c.w, c.h, at: (45.5, 31.5)))
}

/// Two rows under the Martian Spy's right eye: her hypnotic stare leaves from the eye itself (the stream starts
/// `armRaise`, 2, above this).
private let spyStare = (x: 32.5, y: 31.5)

/// The Martian Spy: disguised as a woman, a pale-green Martian face with huge unblinking black eyes, sharp painted
/// brows and red lips, chewing gum; a towering black beehive of hair hides her brain; a tight black dress with white
/// swirls, long red nails. She walks stiffly, with no bob. She carries no gun: she fights with her hypnotic stare, a
/// soft pink ray rippling with rings out of her right eye, her eyes glinting pink while she does. Signature: she
/// blows a big pink bubble of gum, it pops, and she stares on without blinking.
private func drawMartianSpy(_ c: PixelCanvas, _ p: Pose) {
    let face = C(0xD6E6C4), faceD = C(0xAEC49C), dress = C(0x16161B), dressD = C(0x0C0C10), swirl = C(0xE8E8F0)
    let hair = C(0x121216), hairL = C(0x34343E), lips = C(0xD8202A)
    let sig = p.signature
    let bubble = sig.map { $0 > 0.15 && $0 < 0.55 ? ramp($0, 0.15, 0.55) : 0 } ?? 0
    let popped = sig.map { $0 >= 0.55 && $0 < 0.65 } ?? false

    drawLegs(c, Look(leg: face), step: p.step)
    burtonBoots(c, step: p.step, C(0xD8202A), height: 2)
    // The tight black dress, down over the tops of her legs; swirls on it.
    c.rect(18, 38, 20, seatedPose ? 1 : 2, dress)
    drawBody(c, Look(body: face, shade: faceD, arm: dress, eye: nil))
    c.rect(18, 33, 20, 5, dress); c.rect(37, 33, 1, 5, dressD); c.rect(18, 37, 20, 1, dressD)
    c.pattern(19, 33, [".SS.....SS....SS..", "S..S...S..S..S..S.", "..S.......S.....S.", ".S......SS...SS..."],
              ["S": swirl])
    // Huge staring eyes with long lashes, sharp brows, the red lips chewing; glinting pink while she stares someone
    // down.
    let staring = p.zap != nil
    c.pattern(20, 26, ["KK.........KK...", "..KK.....KK.....", "LKKKL...LKKKL...", ".KKKK....KKKK...",
                       staring ? ".KWPK....KWPK..." : ".KWKK....KWKK...",
                       ".KKKK....KKKK..."],
              ["K": ink, "L": ink, "W": staring ? C(0xFFC2E2) : C(0xFFFFFF), "P": C(0xF07AB8)])
    let chew = !(bubble > 0) && Int(p.lt * 3) % 2 == 0
    c.pattern(26, 32, chew ? [".LL.", "LLLL"] : ["LLLL", ".LL."], ["L": lips])
    // The towering beehive.
    c.rect(20, 25, 16, 1, face)   // her brow under the hairline, so the beehive sits on her with no gap
    c.pattern(18, 7, [
        "......HHHHHHHH......",
        "....HHHHHHHHHHHH....",
        "...HHHHhhHHHHHHHH...",
        "..HHHHhHHHHHHHHHHH..",
        "..HHHhHHHHHHHHHHHH..",
        "..HHHhHHHHHHHHHHHH..",
        ".HHHHhHHHHHHHHHHHHH.",
        ".HHHHhHHHHHHHHHHHHH.",
        ".HHHHHhHHHHHHHHHHHH.",
        ".HHHHHHhHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHH.",
        "..HHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHH",
        "HH................HH",
        "H..................H",
    ], ["H": hair, "h": hairL])
    if bubble > 0 {
        let r = 1 + bubble * 4.5
        hmBlob(c, 28, 32.5 + r * 0.2, r, r, C(0xFF8AC0)); c.px(Int(28 - r * 0.5), Int(32.5 - r * 0.4), C(0xFFD8EA))
    } else if popped {
        c.pattern(23, 31, ["P.....P", ".P...P.", "..PPP..", ".P...P."], ["P": C(0xFF8AC0)])
    }
    // Both arms down at her sides, black sleeves and pale-green hands with long red nails.
    for x in [15, 38] {
        c.rect(x, 33, 3, 3, dress)
        c.pattern(x == 15 ? 15 : 39, 36, ["FF", "NN"], ["F": face, "N": lips])
    }
}

/// The Martian Walker: a giant Martian robot a size up from Clawd, a riveted silver block on four thick mechanical
/// legs, two green lamps for eyes and a grille for a mouth, its ray cannon for a right arm; on top, a glass dome with
/// a little Martian in it, steering. It fires a green ray and shots bounce off it. Signature: it stomps, one big foot
/// after another, the ground shaking; then its dome swivels round, the little Martian looking this way and that.
private func drawMartianWalker(_ c: PixelCanvas, _ p: Pose) {
    let metal = C(0xB8BCC6), metalD = C(0x8A8E9A), metalDD = C(0x5E626E), metalL = C(0xDCE0E8), lamp = C(0x7AF06A)
    let sig = p.signature
    let stomping = sig.map { $0 > 0.06 && $0 < 0.6 } ?? false
    let swivel = sig.map { $0 >= 0.6 && $0 < 0.95 ? sin(ramp($0, 0.6, 0.95) * 2 * .pi) : 0 } ?? 0
    var step = p.step
    var shake = 0
    if stomping, let s = sig {
        let k = frac(ramp(s, 0.06, 0.6) * 3)
        step = Int(ramp(s, 0.06, 0.6) * 3) % 2
        if k > 0.7 { step = -1; shake = k < 0.8 ? 1 : 0 }
    }
    // Four thick mechanical legs, knees and wide feet.
    for (i, lx) in [17, 23, 30, 36].enumerated() {
        let up = step >= 0 && i % 2 == step ? (stomping ? 3 : 1) : 0
        c.rect(lx, 38 - up, 3, 5, metalD); c.rect(lx, 40 - up, 3, 1, metalDD); c.px(lx, 38 - up, metalL)
        c.rect(lx - 1, 43 - up, 5, 1, metalDD)
    }
    if shake > 0 {
        for x in [14, 42] { c.pattern(x, 42, [".D.D", "D.D."], ["D": C(0xC8B8A0, 0.6)]) }
    }
    c.oy += p.breathe + shake
    // The block, a size up: riveted silver, panel lines, lamp eyes, the mouth grille.
    c.rect(16, 23, 24, 15, metal); c.rect(39, 23, 1, 15, metalD); c.rect(16, 37, 24, 1, metalD)
    c.rect(16, 23, 24, 1, metalL); c.rect(16, 33, 24, 1, metalDD)
    for x in stride(from: 18, through: 37, by: 4) { c.px(x, 25, metalD); c.px(x, 35, metalD) }
    c.pattern(20, 27, [".DDD......DDD.", "DLLLD....DLLLD", "DLWLD....DLWLD", "DLLLD....DLLLD", ".DDD......DDD."],
              ["D": metalDD, "L": lamp, "W": C(0xE8FFE0)])
    c.pattern(24, 33, ["........", "KMKMKMKM", "KMKMKMKM"], ["K": metalDD, "M": metalD])
    c.rect(26, 37, 4, 1, C(0x2A2E36))
    // Its left arm, a stubby claw; its right arm, the ray cannon.
    c.rect(12, 30, 4, 5, metalD); c.pattern(11, 35, ["C..C", "CC.C"], ["C": metalDD])
    let lift = (p.fire != nil || p.ready || p.gunLift > 0) ? p.gunY : 0
    c.rect(40, 29 + lift, 4, 5, metalD)
    c.pattern(43, 29 + lift, ["MMMMMMRRG", "MMMMMMRRG", "DDDDDDRRG"],
              ["M": metal, "D": metalD, "R": C(0xD8302A), "G": lamp])
    // The dome on top, swivelling, with a little Martian at the controls.
    let dome = (cx: 28.0, base: 23)
    for y in 13..<dome.base {
        for x in 20...35 {
            let dx = (Double(x) + 0.5 - dome.cx) / 7, dy = (Double(y) + 0.5 - Double(dome.base)) / 10
            let d = dx * dx + dy * dy
            if d <= 1 { c.px(x, y, d > 0.78 ? C(0xC8EEF4) : C(0xC8EEF4, 0.18)) }
        }
    }
    let mx = 25 + Int((swivel * 2).rounded())
    c.pattern(mx, 14, [".PPPP.", "PPpPPP", "PPPPpP", "GGGGGG", "KKGGKK", "KWGGKW", "GTTTTG", ".GGGG."],
              ["P": C(0xF2A2B8), "p": C(0xC86E8E), "G": martianGreen, "K": ink, "W": C(0xFFFFFF), "T": burtonBone])
    c.px(23, 16, C(0xFFFFFF)); c.px(22, 18, C(0xFFFFFF))
    c.rect(20, 21, 16, 2, metalD); c.rect(20, 21, 16, 1, metalL)
}
