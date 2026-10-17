import Foundation

// Villains: robots, trolls, vengeance demons and a rogue Watcher. Clawd in costume like the rest of the cast: hair,
// clothes, plates and hides drawn over the blocky body, Clawd's own orange face showing (Molok's metal plates and the
// demons' faces drawn over it). Olaff is a big Clawd, a third again as tall, still on four legs; the rest are Clawd's
// own size.

let slayerVillains6: [SlayerVillain: Persona] = [
    .tedd: Persona(name: "Tedd", weapon: .saber, armoured: true, headTop: 20, signature: 3.4, callout: "Mini pizza?",
                   draw: drawTedd),
    .molok: Persona(name: "Molok", weapon: .saber, armoured: true, headTop: 17, signature: 3.6, draw: drawMolok),
    .olaffTheTroll: Persona(name: "Olaff the Troll", weapon: .saber, armoured: true, pivot: v6OlaffFist, bulk: 8,
                            headTop: 13, signature: 3.2, callout: "Ale!", draw: drawOlaffTheTroll),
    .dHoffrin: Persona(name: "D'Hoffrin", weapon: .blaster, shot: .fire, muzzle: (45, 33), handGun: false, headTop: 20,
                       signature: 3.4, draw: drawDHoffrin),
    .halfreck: Persona(name: "Halfreck", weapon: .lightning,
                       magic: Magic(core: C(0xFFFFFF), glow: C(0xFF2E9A), jagged: false, touch: true),
                       headTop: 16, signature: 3.2, callout: "Wish granted!", draw: drawHalfreck),
    .veruka: Persona(name: "Veruka", weapon: .saber, headTop: 17, signature: 3.2, draw: drawVeruka),
    .gwendolynPoste: Persona(name: "Gwendolyn Poste", weapon: .lightning,
                             magic: Magic(core: C(0xEAFBFF), glow: C(0x1E9CB4), bolts: 2),
                             headTop: 19, signature: 3.2, draw: drawGwendolynPoste),
]

// MARK: - Shared bits

/// Smoothstep: 0→1 eased at both ends.
private func v6Smooth(_ x: Double) -> Double {
    let u = min(1, max(0, x))
    return u * u * (3 - 2 * u)
}

/// A value through a signature `s` 0…1, eased from key to key (`keys` in order of `s`), flat beyond the ends.
private func v6Keyed(_ s: Double, _ keys: [(s: Double, v: Double)]) -> Double {
    guard let first = keys.first, let last = keys.last else { return 0 }
    if s <= first.s { return first.v }
    for (a, b) in zip(keys, keys.dropFirst()) where s < b.s {
        return a.v + (b.v - a.v) * v6Smooth((s - a.s) / (b.s - a.s))
    }
    return last.v
}

/// A punch along `angle`: the sleeve thrown out and a solid fist on the end, with faint fists where a fast swing just
/// was. `knuckle`: a different colour on the knuckles (Tedd's showing metal).
private func v6Fist(_ c: PixelCanvas, angle: Double, trail: [Double], sleeve: Px, skin: Px = clawdOrange,
                    reach len: Double = 7, knuckle: Px? = nil) {
    for (i, a) in trail.enumerated() {
        let e = slayerReach(slayerHand, a, len)
        c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 3, 3, skin.alpha(0.2 / Double(i + 1)))
    }
    let e = slayerReach(slayerHand, angle, len)
    slayerLine(c, slayerHand.x - 2, slayerHand.y - 0.5, e.x, e.y, sleeve, 1.2)
    let fx = Int(e.x.rounded()) - 1, fy = Int(e.y.rounded()) - 1
    c.rect(fx, fy, 3, 3, skin)
    if let knuckle { c.rect(fx + 2, fy, 1, 3, knuckle) }
}

// MARK: - Tedd

/// Tedd: Joyce's too-perfect new boyfriend from "Ted", a robot built in the fifties who thinks it's still 1958. A tan
/// cardigan over a white shirt and a little bow tie, grey slacks, short brown hair neatly parted with a wave at the
/// front, and the biggest, friendliest smile. He fights with his fists, and he's metal underneath (armoured): when
/// he's hit, the skin of his cheek tears and the steel shows, a spark jumping from it. Signature: he holds out a plate
/// of little pizzas ("Mini pizza?").
private func drawTedd(_ c: PixelCanvas, _ p: Pose) {
    let cardi = C(0xC9A25E), cardiD = C(0x9C7A3C), cardiL = C(0xE2C286), shirt = C(0xF4F2EA), tie = C(0x8E2A2A)
    let hair = C(0x5E3E26), hairL = C(0x8A623E), hairD = C(0x3E2816)
    let s = p.melee == nil ? p.signature : nil
    let offer = s.map { v6Keyed($0, [(0.06, 0), (0.22, 1), (0.82, 1), (0.95, 0)]) } ?? 0

    drawLegs(c, Look(leg: C(0x8E7656)), step: p.step)
    slayerBoots(c, step: p.step, C(0x4A2E1E), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: cardi, eye: nil))
    // Bright, friendly eyes under raised brows, and the big smile.
    c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink); c.px(22, 29, white); c.px(32, 29, white)
    c.rect(21, 27, 4, 1, hairD); c.rect(31, 27, 4, 1, hairD)
    c.pattern(24, 32, ["M......M", ".MWWWWM.", "..MMMM.."], ["M": C(0x7A2A20), "W": white])
    // The cardigan, buttoned low over the white shirt and the bow tie.
    c.rect(18, 34, 20, 4, cardi); c.rect(37, 34, 1, 4, cardiD); c.rect(18, 37, 20, 1, cardiD); c.rect(18, 34, 1, 3, cardiL)
    c.pattern(25, 34, ["LSSSSL", ".LSSL.", "..LL.."], ["S": shirt, "L": cardiL])
    c.pattern(26, 34, ["TT.TT"], ["T": tie]); c.px(28, 34, C(0x6A1A1A))
    c.px(28, 37, cardiD); c.px(28, 36, C(0x5A3A1E))
    // Short neat hair, parted on the left, a wave at the front.
    c.pattern(17, 21, [
        "....HHHHHHHHHHHHH...",
        "..HHHHlHHHHHHHHHHHH.",
        ".HHHHlHHHHdHHlllHHHH",
        ".HHHHHHHHHdHHHHHlHHH",
        ".HHHHHHHHHHHHHlHHHHH",
        ".HH..............dH.",
    ], ["H": hair, "l": hairL, "d": hairD])

    if p.hit {
        // The robot underneath: the skin of his cheek torn back on bare steel, and a spark.
        c.pattern(32, 30, ["..oS", ".oSS", "oSSd", ".odS"], ["S": C(0xB8BEC6), "d": C(0x6A7078), "o": C(0xB04A1E)])
        if Int(p.t * 14) % 3 == 0 { c.px(37, 29, C(0xFFF4A0)); c.px(38, 28, C(0xFFF4A0, 0.5)) }
    }
    if let a = p.melee {
        v6Fist(c, angle: a, trail: p.trail, sleeve: cardi)
        return
    }
    guard offer > 0 else { return }
    // The plate held out on his palm, a few little pizzas on it.
    let out = Int((offer * 3).rounded()), up = Int((offer * 2).rounded())
    c.rect(38, 33 - up, 2 + out, 3, cardi)
    c.rect(40 + out, 33 - up, 3, 3, clawdOrange)
    let px = 37 + out, py = 31 - up
    c.pattern(px, py, [
        ".pR.pp.Rp..",
        "WWWWWWWWWWW",
        ".wwwwwwwww.",
    ], ["p": C(0xE8A848), "R": C(0xC83020), "W": white, "w": C(0xC8D0D8)])
    if Int(p.t * 5) % 4 == 0 { c.px(px + 10, py - 2, white.alpha(0.8)) }       // the plate's shine
}

// MARK: - Molok

/// Molok the Corruptor: the demon from "I, Robot... You, Jane", scanned into the library's computer and then into a
/// robot body of riveted steel plates, two curved metal horns on his skull and a jaw of steel teeth, Clawd's face
/// showing through between the plates. He fights with steel claws (armoured, so shots ricochet). On his chest a screen
/// where the internet he lived in still runs. Signature: green text scrolls across the screen, faster and faster.
private func drawMolok(_ c: PixelCanvas, _ p: Pose) {
    let steel = C(0x6E747E), steelD = C(0x484E58), steelL = C(0xA2AAB4), rivet = C(0x2E3238)
    let screen = C(0x0E1A12), green = C(0x5CF08A), greenD = C(0x2A8A48)
    let scroll = p.signature.map { v6Keyed($0, [(0.06, 0), (0.18, 1), (0.84, 1), (0.95, 0)]) } ?? 0

    // Steel legs, a joint at each knee.
    drawLegs(c, Look(leg: steel), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, lifted ? 38 : 39, 2, 1, steelD); c.px(lx, lifted ? 37 : 38, steelL)
        }
    }
    slayerBoots(c, step: p.step, steelD, height: 2)
    c.oy += p.breathe
    // The horns, curving up and out off the skull, pale at the tips.
    for side in [-1.0, 1.0] {
        let bx = 28 + side * 7
        let pts: [(Double, Double)] = [(bx, 24), (bx + side * 3, 21), (bx + side * 4, 18), (bx + side * 3, 15)]
        for i in 0..<3 { slayerLine(c, pts[i].0, pts[i].1, pts[i + 1].0, pts[i + 1].1, i == 2 ? steelL : steelD, [1.4, 1.0, 0.7][i]) }
    }
    // The riveted skull plate.
    c.rect(19, 23, 18, 3, steel); c.rect(21, 22, 14, 1, steel); c.rect(19, 23, 18, 1, steelL); c.rect(36, 23, 1, 3, steelD)
    c.rect(27, 22, 2, 4, steelD)
    for x in [21, 24, 32, 35] { c.px(x, 24, rivet) }
    drawBody(c, Look(arm: steel, eye: nil))
    // Plates over Clawd's face: a heavy brow, cheek guards, and a jaw of steel teeth.
    c.rect(18, 26, 20, 2, steel); c.rect(18, 26, 20, 1, steelL); c.rect(37, 26, 1, 2, steelD)
    c.pattern(20, 28, ["DDDD........DDDD"], ["D": steelD])
    c.rect(18, 28, 2, 6, steel); c.rect(36, 28, 2, 6, steelD)
    c.rect(22, 29, 2, 2, ink); c.rect(32, 29, 2, 2, ink); c.px(23, 29, C(0xFF4A2A)); c.px(33, 29, C(0xFF4A2A))
    c.rect(23, 32, 10, 2, steelD); for x in stride(from: 23, through: 32, by: 2) { c.px(x, 32, steelL) }
    // The chest: steel plates round the screen.
    c.rect(18, 34, 20, 4, steel); c.rect(18, 34, 20, 1, steelL); c.rect(37, 34, 1, 4, steelD); c.rect(18, 37, 20, 1, steelD)
    c.px(19, 35, rivet); c.px(36, 35, rivet); c.px(19, 36, steelD)
    c.rect(22, 35, 12, 3, rivet); c.rect(23, 35, 10, 2, screen)
    if scroll > 0 {
        // Lines of green text sliding along, two rows of it.
        let speed = 6 + 10 * scroll
        for row in 0..<2 {
            let shift = Int(p.t * speed) + row * 5
            for x in 0..<10 where noise((x + shift) * 3 + row * 41) > 0.42 {
                c.px(23 + x, 35 + row, noise((x + shift) * 7 + row) > 0.7 ? green : greenD)
            }
        }
        c.glowLine(28, 36, 28, 36, core: C(0x9CFFB8, 0.1), glow: green, coreR: 0.4, glowR: 3, strength: 0.3 * scroll)
    } else if Int(p.lt * 2) % 2 == 0 {
        c.px(24, 36, green)                                                   // a blinking cursor
    }
    // Steel claws.
    if let a = p.melee {
        slayerClaws(c, angle: a, trail: p.trail, sleeve: steel, nail: steelL)
    } else {
        c.rect(39, 34, 2, 2, steelD); c.px(41, 34, steelL); c.px(41, 36, steelL)
    }
}

// MARK: - Olaff the Troll

/// Where Olaff's hammer swings from: his fist, out in front of his big body.
private let v6OlaffFist: (x: Double, y: Double) = (44.5, 33.5)

/// Olaff's hammer: a long haft and a huge iron head banded with bronze, at `angle` degrees from the fist at `h`, its
/// head `len` pixels out.
private func v6OlaffHammer(_ c: PixelCanvas, from h: (x: Double, y: Double), angle: Double, len: Double,
                           butt: Double = 3) {
    let iron = C(0x66625E), ironD = C(0x3E3A38), ironL = C(0x96908A), band = C(0xA87C3A)
    let wood = C(0x7A5230), woodD = C(0x4E3218)
    let end = slayerReach(h, angle, -butt), neck = slayerReach(h, angle, len - 3)
    slayerLine(c, end.x, end.y, neck.x, neck.y, woodD, 1.1)
    slayerLine(c, end.x, end.y, neck.x, neck.y, wood, 0.6)
    let r = angle * .pi / 180, ux = cos(r), uy = sin(r)
    let ctr = slayerReach(h, angle, len)
    for y in Int(ctr.y - 8)...Int(ctr.y + 8) {
        for x in Int(ctr.x - 8)...Int(ctr.x + 8) {
            let dx = Double(x) + 0.5 - ctr.x, dy = Double(y) + 0.5 - ctr.y
            let u = dx * ux + dy * uy, v = -dx * uy + dy * ux
            guard abs(u) < 3.6, abs(v) < 5.6 else { continue }
            var col = iron
            if abs(v) > 2.2 && abs(v) < 3.3 { col = band }
            // Edges: lit where they face up and left, dark where they face down and right.
            let edgeU = abs(u) > 2.6, edgeV = abs(v) > 4.6
            if edgeU || edgeV {
                let n = edgeV ? (x: -uy * (v > 0 ? 1 : -1), y: ux * (v > 0 ? 1 : -1))
                              : (x: ux * (u > 0 ? 1 : -1), y: uy * (u > 0 ? 1 : -1))
                col = n.x + n.y < 0 ? ironL : ironD
            }
            c.px(x, y, col)
        }
    }
}

/// Olaff the Troll: Anya's old boyfriend from "Triangle", a troll god with grey-green warty skin, a big Clawd a third
/// again as tall, a lumpy ridged brow, a shaggy mane of dirty-blond hair and a beard, a leather jerkin and a belt, and
/// no cape. He fights with a huge two-handed hammer, far bigger than any god's (armoured: he's hard to hurt). Between
/// fights it stands on its head in front of him, his fist on the haft. Signature: he swings it up over his head, shakes
/// it like a toast ("Ale!"), and brings it down again.
private func drawOlaffTheTroll(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x7E8E6A), skinD = C(0x5A684A), skinL = C(0xA2B08A), wart = C(0x4E5A3E), wartL = C(0xB6C29C)
    let hair = C(0xB89A5A), hairD = C(0x8A6E3A), hairL = C(0xDCC488)
    let jerkin = C(0x6A4A2E), jerkinD = C(0x48301C), jerkinL = C(0x8E6A44), belt = C(0x2E2018), buckle = C(0xC8A040)
    let trousers = C(0x8A7458), boot = C(0x4A3628)
    let s = p.melee == nil ? p.signature : nil
    let lift = s.map { v6Keyed($0, [(0.06, 0), (0.3, 1), (0.78, 1), (0.95, 0)]) } ?? 0

    // The back arm, hanging, a big grey-green fist.
    c.oy += p.breathe
    c.rect(11, 27, 4, 8, skin); c.rect(11, 27, 1, 8, skinL); c.rect(14, 28, 1, 7, skinD)
    c.rect(10, 34, 5, 3, skin); c.px(10, 34, skinL); c.px(12, 30, wart)
    c.oy -= p.breathe
    // Four thick legs in rough trousers and fur-wrapped boots.
    if seatedPose {
        for lx in [18, 23, 31, 36] { c.rect(lx - 1, 38, 5, 2, trousers); c.rect(lx + 2, 38, 2, 2, boot) }
    } else {
        for (i, lx) in [18, 23, 31, 36].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            let bottom = lifted ? 42 : 43
            c.rect(lx, 36, 3, bottom - 36 - 2, trousers); c.rect(lx + 2, 36, 1, bottom - 38, C(0x6A5640))
            c.rect(lx, bottom - 2, 3, 3, boot); c.px(lx, bottom - 2, C(0x6E5A48))
        }
    }
    c.oy += p.breathe
    // The body: Clawd's block, a third taller and broader, in troll skin, warts dotted over it.
    c.rect(15, 20, 26, 18, skin); c.rect(40, 20, 1, 18, skinD); c.rect(16, 19, 24, 1, skin)
    for (x, y) in [(17, 24), (37, 22), (19, 31), (36, 29), (33, 21)] { c.px(x, y, wart); c.px(x, y - 1, wartL) }
    // The leather jerkin and belt.
    c.rect(15, 31, 26, 7, jerkin); c.rect(40, 31, 1, 7, jerkinD); c.rect(15, 31, 1, 6, jerkinL)
    c.rect(15, 35, 26, 2, belt); c.rect(26, 35, 3, 2, buckle); c.px(27, 35, belt)
    for x in [18, 22, 33, 37] { c.px(x, 33, jerkinD) }                         // the lacing
    c.rect(15, 37, 26, 1, jerkinD)
    // The face: a lumpy, ridged brow over small eyes, a broad nose, a wide mouth.
    c.pattern(17, 21, [
        ".WW...W.....W....W.WW.",
        "RRRRRRRRR....RRRRRRRRR",
        ".DDDDDDDD.RR.DDDDDDDD.",
    ], ["R": skinD, "D": wart, "W": wartL])
    c.rect(21, 24, 2, 2, ink); c.px(21, 24, C(0xE8D890)); c.rect(33, 24, 2, 2, ink); c.px(33, 24, C(0xE8D890))
    c.pattern(26, 24, [".RR.", "RRRR", "RddR"], ["R": skinL, "d": skinD])
    // The beard over the mouth and down onto the jerkin, the mouth a dark gap in it.
    c.pattern(18, 27, [
        "..HH.............HH...",
        ".HHHHHH.MMMMMM.HHHHHH.",
        "HHHHlHHHHHHHHHHHHlHHHH",
        "HHHHHHHHHHlHHHHHHHHHHH",
        ".HHdHHHHHHHHHHHHHHdHH.",
        "..HH.HHdHHHHHdHH.HH...",
        "......HH.HH.HH........",
    ], ["H": hair, "l": hairL, "d": hairD, "M": C(0x3A2018)])
    // The shaggy mane, falling past his shoulders, strands breaking loose at the top and sides.
    c.pattern(12, 13, [
        "..........H...H.....H.......",
        "......H..HH..HH...HHH..H....",
        "....HHHHHHHHHHHHHHHHHHHHH...",
        "...HHHHlHHHHHlHHHHHlHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHHHHHHH.",
        "..HHHHdHHHHHHdHHHHHHdHHHHHH.",
        ".HHHH.HHdH.HHH..HHdHH.HHHHHH",
        ".HHHH.....................HH",
        "HHHH.......................H",
        ".HHH.......................H",
        "HHdH........................",
        ".HHH........................",
        "HHH.........................",
        ".HdH........................",
        "H.H.........................",
    ], ["H": hair, "l": hairL, "d": hairD])

    // The front arm and the hammer: resting on its head in front of him, swung in a fight, or raised overhead.
    if let a = p.melee {
        // Too heavy to fence with: it's either hoisted high or slammed down in front of him, and never swung back
        // over his own head or level through his opponent's face (only for a blur on the way between).
        let swing = { (a: Double) -> (angle: Double, len: Double) in
            let k = v6Smooth(((a > 180 ? a - 360 : a) + 70) / 40)
            return (-78 + 133 * k, 13 - 6 * k)
        }
        let now = swing(a)
        slayerSmear(c, v6OlaffFist, p.trail.map { swing($0).angle }, from: 6, to: 13, C(0xC8C0B0))
        v6OlaffHammer(c, from: v6OlaffFist, angle: now.angle, len: now.len)
        slayerLine(c, 40.5, 30, v6OlaffFist.x, v6OlaffFist.y, skin, 1.6)
        c.rect(43, 32, 3, 3, skin); c.px(43, 32, skinL)
        return
    }
    let hand = (x: v6OlaffFist.x - 2 * lift, y: v6OlaffFist.y - 13.5 * lift)
    let angle = 80 - 170 * lift + (lift > 0.98 ? sin(p.t * 14) * 7 : 0)
    // Sitting, he's lower: the hammer stands shorter in his fist so its head stays on the ground.
    let rest = seatedPose ? 2.5 : 7.0
    v6OlaffHammer(c, from: hand, angle: angle, len: rest + (11 - rest) * lift, butt: (seatedPose ? 9 : 5) - 2 * lift)
    slayerLine(c, 40.5, 30, hand.x, hand.y, skin, 1.6)
    c.rect(Int(hand.x.rounded()) - 1, Int(hand.y.rounded()) - 1, 3, 3, skin)
    c.px(Int(hand.x.rounded()) - 1, Int(hand.y.rounded()) - 1, skinL)
    if lift > 0.98 {
        c.rect(25, 28, 6, 2, C(0x3A2018))                                      // roaring
    }
}

// MARK: - D'Hoffrin

/// D'Hoffrin: the lord of the vengeance demons, who makes the offers. Long burgundy robes trimmed in gold with a high
/// standing collar, and a bald, deeply wrinkled demon face: fleshy ridges over the dome, folds down the cheeks and a
/// heavy fold under the chin. He throws fire from his bare hand. Signature: he holds out his talisman on its chain,
/// a gold disc with a red stone, and lets it swing.
private func drawDHoffrin(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0x7A1E2A), robeD = C(0x541420), robeL = C(0x9E3440), gold = C(0xD8A848), goldD = C(0xA87A2A)
    let fold = C(0xA8481E), foldL = C(0xF0A06A)
    let s = p.melee == nil && p.fire == nil ? p.signature : nil
    let offer = s.map { v6Keyed($0, [(0.06, 0), (0.22, 1), (0.84, 1), (0.95, 0)]) } ?? 0

    drawLegs(c, Look(leg: C(0x3A2A2A)), step: p.step)
    slayerBoots(c, step: p.step, C(0x2A1A1A), height: 2)
    // The robes, down to the ankles: the four feet show under the hem.
    if seatedPose {
        c.rect(16, 37, 24, 2, robe); c.rect(16, 38, 24, 1, robeD)
    } else {
        c.rect(17, 37, 22, 3, robe); c.rect(16, 39, 24, 2, robe); c.rect(16, 40, 24, 1, gold); c.rect(38, 37, 1, 3, robeD)
        c.px(21, 38, robeD); c.px(27, 39, robeD); c.px(33, 38, robeD)
    }
    c.oy += p.breathe
    // The high standing collar behind his head.
    c.pattern(15, 25, ["GG................GG...", "GRR..............RRG...", "GRR..............RRG..."],
              ["G": gold, "R": robeD])
    drawBody(c, Look(arm: robe, eye: nil))
    // The bald dome, ridged with fleshy folds.
    c.rect(20, 22, 16, 4, clawdOrange); c.rect(22, 21, 12, 1, clawdOrange); c.rect(35, 22, 1, 4, clawdShade)
    c.pattern(20, 21, [
        "...Lf.Lf.Lf.Lf..",
        "..Lf.Lf..Lf..Lf.",
        ".Lf..Lf..Lf...Lf",
        ".Lf..Lf..Lf...Lf",
        "Lf...Lf..Lf....f",
    ], ["f": fold, "L": foldL])
    // The wrinkled face: deep lines on the brow, small eyes in pouches, folds down the cheeks.
    c.pattern(19, 26, [
        "ffff.ffffffff.fff.",
        ".LLf..f....f..fLL.",
        "..fff........fff..",
        "...f..........f...",
        ".f..f........f..f.",
        ".f..ff......ff..f.",
        "..f..ffffffff..f..",
        "...f..........f...",
    ], ["f": fold, "L": foldL])
    c.rect(22, 29, 2, 2, ink); c.rect(32, 29, 2, 2, ink); c.px(22, 29, C(0xF0C840)); c.px(33, 29, C(0xF0C840))
    c.rect(25, 32, 6, 1, C(0x4A1410))
    // The robe over the chest, its gold-trimmed front, the fold of the chin hanging over the collar.
    c.rect(18, 34, 20, 4, robe); c.rect(37, 34, 1, 4, robeD); c.rect(18, 37, 20, 1, robeD); c.rect(18, 34, 1, 3, robeL)
    c.pattern(23, 34, ["G........G", ".G......G.", "..GGGGGG..", "..g....g.."], ["G": gold, "g": goldD])
    c.rect(24, 34, 8, 1, fold); c.rect(25, 35, 6, 1, clawdOrange)
    // The sleeve and the bare hand: a flame in the palm when he throws.
    c.rect(38, 32, 3, 4, robe); c.rect(38, 35, 3, 1, gold)
    if offer > 0 {
        // The arm out, the talisman hanging from it on its chain, swinging.
        let out = Int((offer * 4).rounded()), up = Int((offer * 2).rounded())
        c.rect(38, 32 - up, 3 + out, 4, robe); c.rect(38 + out, 35 - up, 3, 1, gold)
        let hx = 41 + out, hy = 32 - up
        c.rect(hx, hy, 3, 3, clawdOrange)
        let swing = sin(p.t * 4.5) * 1.6 * offer
        let bx = Double(hx) + 1.5 + swing, by = Double(hy) + 7
        slayerLine(c, Double(hx) + 1.5, Double(hy) + 2.5, bx, by - 1.5, goldD, 0.4)
        let ix = Int(bx.rounded()) - 1, iy = Int(by.rounded()) - 1
        c.pattern(ix, iy, [".G.", "GrG", ".g."], ["G": gold, "g": goldD, "r": C(0xD81E2A)])
        if Int(p.t * 6) % 4 == 0 { c.px(ix + 3, iy - 1, white.alpha(0.8)) }
        return
    }
    c.rect(41, 33, 2, 2, clawdOrange)
    if let f = p.fire, frac(f.t / p.firePeriod) < 0.4 {
        c.px(43, 32, C(0xFFD040)); c.px(42, 31, C(0xFF8A20)); c.px(43, 33, C(0xFF6A10))
        c.glowLine(43, 32, 43, 32, core: C(0xFFE080, 0.2), glow: C(0xFF6A10), coreR: 0.5, glowR: 2.4, strength: 0.5)
    }
}

// MARK: - Halfreck

/// Halfreck: the vengeance demon of wronged children, Anya's old friend. Dark brown hair pinned up in a soft bun, ringlets
/// falling at either side, a pretty coral party dress with a white lace collar and a full skirt. Her magic is a touch,
/// white and hot pink: wishes granted. When she grants one her demon face comes out, dark veined ridges round the eyes.
/// Signature: the demon face, a flourish of her hand and a burst of pink sparkles ("Wish granted!"), then herself again.
private func drawHalfreck(_ c: PixelCanvas, _ p: Pose) {
    let dress = C(0x86AEE0), dressD = C(0x5E86BC), dressL = C(0xB4D0F4), lace = C(0xFBF7F2)
    let hair = C(0x4A2A1E), hairL = C(0x704430), hairD = C(0x2E1810)
    let pink = C(0xFF2E9A)
    let sig = p.signature.map { v6Keyed($0, [(0.08, 0), (0.22, 1), (0.8, 1), (0.92, 0)]) } ?? 0
    let demon = sig > 0.5 || p.zap == true

    drawLegs(c, Look(), step: p.step)
    slayerBoots(c, step: p.step, C(0x8A2440), height: 1)
    // The full skirt, flaring out to just above the ankles.
    if seatedPose {
        c.rect(15, 37, 26, 2, dress); c.rect(15, 38, 26, 1, dressD)
    } else {
        c.rect(17, 37, 22, 2, dress); c.rect(16, 39, 24, 2, dress); c.rect(15, 41, 26, 1, dress)
        c.rect(15, 41, 26, 1, lace); c.rect(38, 37, 1, 4, dressD); c.rect(39, 39, 1, 2, dressD)
        c.px(21, 39, dressD); c.px(27, 40, dressD); c.px(33, 39, dressD); c.px(18, 40, dressL)
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: dress, eye: nil), armRight: sig > 0 ? Int((sig * 4).rounded()) : p.armRaise)
    c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    if demon {
        // The vengeance face: dark veined ridges spreading round the eyes, the eyes gone pale.
        let vein = C(0x6A2440), veinL = C(0x9A3A5E)
        c.pattern(19, 27, [
            "v.vvvv....vvvv.v",
            ".vV..........Vv.",
            "vV............Vv",
            ".v............v.",
            "v.vV........Vv.v",
            "...v........v...",
        ], ["v": vein, "V": veinL])
        c.px(22, 29, C(0xF4E4F0)); c.px(33, 29, C(0xF4E4F0))
        c.rect(26, 33, 4, 1, C(0x5A1A2A))
    } else {
        c.px(21, 29, ink); c.px(34, 29, ink)                                    // lashes
        c.rect(26, 33, 4, 1, C(0xC8304A))
    }
    // The dress's bodice and the lace collar.
    c.rect(18, 34, 20, 4, dress); c.rect(37, 34, 1, 4, dressD); c.rect(18, 37, 20, 1, dressD); c.rect(19, 35, 1, 2, dressL)
    c.pattern(23, 34, ["L........L", ".LLLLLLLL."], ["L": lace])
    // The hair: pinned up in a soft bun, ringlets falling either side, a few strands loose.
    c.rect(19, 24, 18, 2, clawdOrange); c.rect(36, 24, 1, 2, clawdShade)
    c.pattern(16, 16, [
        "..........HHH...........",
        "........HHlHHHH.........",
        ".......HHHHHHHHH...H....",
        "....H..HHHHdHHHH..H.....",
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHlHHHHHHHHlHHH....",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHH..",
        ".HHHHH.dHHHHHHHd.HHHHHH.",
        ".HHH................HHH.",
        "HlH..................HlH",
        "HHd..................dHH",
        ".HH..................HH.",
        "Hl....................lH",
        "HH....................HH",
        ".d....................d.",
    ], ["H": hair, "l": hairL, "d": hairD])

    guard sig > 0 else { return }
    // The flourish: a hand up, pink sparkles bursting from the fingertips.
    let raise = Int((sig * 4).rounded())
    c.rect(41, 33 - raise, 2, 2, clawdOrange)
    guard sig > 0.6 else { return }
    let hx = 42.0, hy = 33.0 - Double(raise)
    c.glowLine(hx, hy, hx, hy, core: C(0xFFFFFF, 0.2), glow: pink, coreR: 0.5, glowR: 4, strength: 0.6 * sig)
    for k in 0..<6 {
        let f = frac(p.t * 1.2 + Double(k) / 6)
        let a = Double(k) * 1.05 - 1.6
        let x = Int((hx + cos(a) * (3 + f * 7)).rounded()), y = Int((hy + sin(a) * (3 + f * 7)).rounded())
        let col = k % 2 == 0 ? white : C(0xFF6ABE), al = sig * (f < 0.7 ? 1 : (1 - f) / 0.3)
        // A little four-pointed star.
        c.px(x, y, col.alpha(al))
        for (dx, dy) in [(1, 0), (-1, 0), (0, 1), (0, -1)] { c.px(x + dx, y + dy, pink.alpha(0.5 * al)) }
    }
}

// MARK: - Veruka

/// Veruka: the rocker werewolf from "Wild at Heart", singer of Shy. Long dark hair with loose strands, smoky eyes, a
/// plum jacket with a shaggy cream fur collar and cuffs over a black top, dark plum trousers and black boots. She
/// fights with her claws, long dark nails even when she's herself. Signature: she throws her head back and howls,
/// and for a second she's a dark-brown wolf, snout up to the moon (not Ozz's grey-tan), then she's back.
private func drawVeruka(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x7A2E44), jacketD = C(0x561E30), jacketL = C(0x9A4A60), trim = C(0xDCCDAE), trimD = C(0xB4A486)
    let hair = C(0x2E1E1A), hairL = C(0x523628), hairD = C(0x180E0A), nail = C(0x5A1424)
    let fur = C(0x5A3A24), furD = C(0x3A2414), furL = C(0x8A6040), eye = C(0xF0A020)
    let s = p.melee == nil ? p.signature : nil
    // 0 herself, 1 halfway (fur and ears), 2 full wolf, howling.
    let wolf: Int = s.map { s in s < 0.15 || s > 0.8 ? 0 : s < 0.25 || s > 0.7 ? 1 : 2 } ?? 0

    drawLegs(c, Look(leg: wolf == 2 ? fur : C(0x6A4A62)), step: p.step)
    slayerBoots(c, step: p.step, wolf == 2 ? furD : C(0x1A1418), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: wolf > 0 ? fur : jacket, eye: nil))
    // The jacket open over a black top, the fur collar.
    c.rect(18, 34, 20, 4, jacket); c.rect(37, 34, 1, 4, jacketD); c.rect(18, 37, 20, 1, jacketD); c.rect(18, 34, 1, 3, jacketL)
    c.pattern(26, 35, ["TTTT", ".TT."], ["T": C(0x2A2230)])
    c.pattern(18, 34, ["tTttTtTttTttTtTttTtt"], ["t": trim, "T": trimD])
    c.px(19, 35, trimD); c.px(36, 35, trimD)
    if wolf == 0 { c.rect(38, 35, 3, 1, trim) }                               // the cuff

    if wolf == 0 {
        // Smoky eyes, dark lips.
        c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
        c.rect(21, 28, 3, 1, C(0x4A2A3A)); c.rect(32, 28, 3, 1, C(0x4A2A3A))
        c.rect(26, 33, 4, 1, C(0x6A1A2A))
        // Long dark hair, a middle parting, strands breaking loose, falling past her shoulders.
        c.rect(19, 24, 18, 2, clawdOrange); c.rect(36, 24, 1, 2, clawdShade)
        c.pattern(15, 17, [
            "........H......H.........",
            ".....H..HHHHHHHHHH.H.....",
            "......HHHHHHHHHHHHHH.....",
            "....HHHHlHHHHdHHHHlHHH...",
            "...HHHHHHHHHHdHHHHHHHHH..",
            "..HHHHHHHHHHHdHHHHHHHHHH.",
            "..HHHHHHHHHHdHHHHHHHHHHH.",
            "..HHHHHHHH......HHHHHHHH.",
            ".HHHH................HHHH",
            "..HHl................HHH.",
            ".HHHH................lHHH",
            "..HHH.................HH.",
            ".HHHH................HHHH",
            "HHHd.................dHH.",
            ".HHHd................dHHH",
            "HHdH..................HdH",
            ".H.d..................d.H",
            "...d....................d",
        ], ["H": hair, "l": hairL, "d": hairD])
    } else {
        // The wolf coming through: dark-brown fur over her head, pointed ears laid back, amber eyes.
        c.pattern(16, 17, [
            "..F...........F.......",
            ".FFF.........FFF......",
            ".FdFF.......FFdF......",
            "FFFFFFFFFFFFFFFFFFF...",
            "FFFFFLFFFFFFFLFFFFFF..",
            "FFFFFFFFFFFFFFFFFFFFF.",
            "FFdFFFFFFFFFFFFFFFdFF.",
            "FFFFFFFFFFFFFFFFFFFFFF",
            ".FFFFFFFFFFFFFFFFFFFFF",
            ".FFF.............FFFFF",
        ], ["F": fur, "d": furD, "L": furL])
        c.rect(18, 26, 3, 8, fur); c.rect(35, 26, 3, 8, fur); c.px(19, 29, furD); c.px(36, 31, furD)
        c.rect(22, 29, 2, 2, eye); c.px(23, 30, ink); c.rect(32, 29, 2, 2, eye); c.px(32, 30, ink)
        c.rect(21, 28, 3, 1, furD); c.rect(31, 28, 3, 1, furD)
        c.rect(25, 31, 6, 2, furL)
        if wolf == 2 {
            // The snout thrown up at the moon, jaws open, howling.
            // Head thrown back: the eyes shut, the snout raised off the top of the face, clear of it.
            c.rect(22, 29, 2, 2, fur); c.rect(32, 29, 2, 2, fur); c.rect(22, 30, 2, 1, furD); c.rect(32, 30, 2, 1, furD)
            c.pattern(33, 13, [
                "..........NNN",
                ".........LLNN",
                "........LLLLw",
                ".......LLLLLM",
                "......LLLLLMw",
                ".....LLLLLMM.",
                "....FLLLLMMw.",
                "...FFLLLMM...",
                "..FFFLLMMw...",
                ".FFFFLMM.....",
                "FFFFFMM......",
                "FFFFM........",
                "FFF..........",
            ],["L": furL, "F": fur, "N": ink, "M": C(0x5A1A1E), "w": white])
            c.rect(18, 33, 20, 1, fur); c.px(20, 34, furD); c.px(24, 34, fur); c.px(32, 34, fur); c.px(35, 34, furD)
            // The howl: faint arcs rising off the snout.
            let k = frac(p.t * 1.5)
            for i in 0..<2 {
                let f = frac(k + Double(i) * 0.5), r = 2 + f * 5
                for a in stride(from: -2.4, through: -0.6, by: 0.45) {
                    c.px(Int((46 + cos(a) * r).rounded()), Int((12 + sin(a) * r).rounded()), white.alpha(0.22 * (1 - f)))
                }
            }
        }
    }
    // Claws: long dark nails as herself, a wolf's claws with the wolf out.
    if let a = p.melee {
        slayerClaws(c, angle: a, trail: p.trail, sleeve: jacket, nail: nail)
    } else if wolf > 0 {
        c.rect(39, 34, 2, 2, fur); c.px(41, 34, C(0xE8E0C8)); c.px(41, 36, C(0xE8E0C8))
    } else {
        c.rect(39, 34, 2, 2, clawdOrange); c.px(41, 34, nail); c.px(41, 35, nail)
    }
}

// MARK: - Gwendolyn Poste

/// Gwendolyn Poste: the rogue Watcher from "Revelations", all prim propriety. Auburn hair scraped back into a tight
/// bun, a few strands escaping it, a grey-green tweed skirt suit buttoned over a white blouse with a ruffle at the
/// throat, and on her right arm the Glove of Myhnegon: long, black, banded in silver, a teal stone set in the back of
/// the hand. Her magic is jagged lightning, icy white and teal, and it comes only from the gloved hand. Signature: she
/// raises the gloved hand and tugs the cuff tight, the fingers flex, and the glove crackles.
private func drawGwendolynPoste(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x5E7062), suitD = C(0x405044), suitL = C(0x7E9282), blouse = C(0xF2EEE4), blouseD = C(0xD4CEC0)
    let hair = C(0x6A3424), hairL = C(0x8E4E34), hairD = C(0x44201A)
    let glove = C(0x2A2A34), gloveL = C(0x4E4E5C), silver = C(0xC8CCD4), gem = C(0x30D8D0)
    let sig = p.signature.map { v6Keyed($0, [(0.06, 0), (0.2, 1), (0.84, 1), (0.95, 0)]) } ?? 0
    let raise = sig > 0 ? Int((sig * 6).rounded()) : p.armRaise

    drawLegs(c, Look(leg: C(0xA88A76)), step: p.step)
    slayerBoots(c, step: p.step, C(0x2A1E1E), height: 1)
    // The tweed skirt, to just below the knee.
    if seatedPose {
        c.rect(17, 37, 22, 2, suit); c.rect(17, 38, 22, 1, suitD)
    } else {
        c.rect(17, 37, 22, 3, suit); c.rect(17, 39, 22, 1, suitD); c.rect(38, 37, 1, 2, suitD); c.px(27, 38, suitD)
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: suit, eye: nil), armRight: raise)
    // Narrow, appraising eyes, a thin prim mouth.
    c.rect(22, 30, 2, 2, ink); c.rect(32, 30, 2, 2, ink)
    c.rect(21, 29, 3, 1, hairD); c.rect(32, 29, 3, 1, hairD)
    c.rect(26, 33, 4, 1, C(0x8A3A30))
    // The suit jacket, buttoned, the white ruffle at the throat.
    c.rect(18, 34, 20, 4, suit); c.rect(37, 34, 1, 4, suitD); c.rect(18, 37, 20, 1, suitD); c.rect(18, 34, 1, 3, suitL)
    c.pattern(24, 34, ["LBBBBBBL", ".LbBBbL.", "..L..L.."], ["B": blouse, "b": blouseD, "L": suitL])
    c.px(28, 36, suitD); c.px(28, 37, C(0x2A2A2A))
    // The hair scraped back into a bun at the back of her head, a few loose strands.
    c.rect(19, 25, 18, 1, clawdOrange); c.px(36, 25, clawdShade)
    c.pattern(13, 19, [
        "...........H.....H.......",
        "........HHHHHHHHHHHH.....",
        ".BBB..HHHHlHHHHHHHHHH....",
        "BBlBBHHHHHHHHHHHlHHHHH...",
        "BBBBBHHHHHHHHHHHHHHHHHH..",
        ".BdBHHHHHHHHHHHHHHHHHHHH.",
        "..d.HHHHH..........HHHHH.",
        "....HHH.............dHHH.",
        "....HH...............HH..",
        "....d................d...",
    ], ["H": hair, "l": hairL, "d": hairD, "B": hair])
    // The Glove of Myhnegon over the front arm, from the elbow, a silver band at the cuff and the teal stone.
    let ay = 33 - raise
    let tug = sig > 0.3 && sig < 0.99 ? (Int(p.t * 5) % 2) : 0
    c.rect(38, ay, 4, 3, glove); c.rect(38, ay, 4, 1, gloveL)
    c.rect(37 + tug, ay, 1, 3, silver)
    c.px(40, ay + 1, gem)
    // The fingers: flexing in the signature.
    let flex = sig > 0.3 && Int(p.t * 6) % 2 == 0
    if flex {
        c.px(42, ay - 1, glove); c.px(43, ay - 1, glove); c.px(42, ay, glove); c.px(42, ay + 2, glove)
    } else {
        c.rect(42, ay, 1, 3, glove); c.px(42, ay, gloveL)
    }
    if p.zap != nil || sig > 0.4 {
        // The stone glowing.
        let k = sig > 0.4 ? sig : 0.6
        c.glowLine(40.5, Double(ay) + 1.5, 40.5, Double(ay) + 1.5, core: C(0xEAFBFF, 0.2), glow: C(0x1E9CB4), coreR: 0.4,
                   glowR: 2.2, strength: 0.4 * k)
    }
    guard sig > 0.4 else { return }
    // Teal crackle jumping between the fingers.
    let i = Int(p.t * 20)
    for k in 0..<3 {
        let x0 = 39.5 + noise(i + k * 5) * 4, y0 = Double(ay) - 1 + noise(i * 3 + k) * 4
        let x1 = x0 + (noise(i * 7 + k) - 0.5) * 6, y1 = y0 - 1 - noise(i * 11 + k) * 3
        c.glowLine(x0, y0, x1, y1, core: C(0xEAFBFF), glow: C(0x1E9CB4), coreR: 0.4, glowR: 1.4, strength: 0.8 * sig)
    }
}
