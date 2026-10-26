import Foundation

// Villains: Pee-wee's Big Adventure, and the agent-only small fry. From Pee-wee's Big Adventure, in toy-box
// primaries: Francis Buxtun, the Bike Thief, Madam Rubee and Andee. And the small fry, only ever agents: Bob the
// shrunken head, an Oogie Bug, a Nut Squirrel and a Sea-Monkey.

let burtonVillains7: [BurtonVillain: Persona] = [
    .francisBuxtun: Persona(name: "Francis Buxtun", weapon: .blaster, shot: .thrown(C(0xF0C820)), muzzle: (44, 27),
                            bulk: 1, headTop: 18, signature: 4.0, draw: drawFrancis),
    .bikeThief: Persona(name: "The Bike Thief", weapon: .saber, headTop: 19, signature: 4.0, draw: drawBikeThief),
    .madamRubee: Persona(name: "Madam Rubee", weapon: .none, headTop: 14, signature: 3.4,
                         callout: "The basement of the Alamo!", draw: drawMadamRubee),
    .andee: Persona(name: "Andee", weapon: .saber, pivot: andeeFist, bulk: 4, headTop: 20, signature: 3.6,
                    draw: drawAndee),
    .bob: Persona(name: "Bob", weapon: .none, headTop: 28, draw: drawBob),
    .oogieBug: Persona(name: "An Oogie Bug", weapon: .none, headTop: 27, draw: drawOogieBug),
    .nutSquirrel: Persona(name: "A Nut Squirrel", weapon: .none, headTop: 17, draw: drawNutSquirrel),
    .seaMonkey: Persona(name: "A Sea-Monkey", weapon: .none, headTop: 19, draw: drawSeaMonkey),
]

/// Andee's right fist: he punches from there.
private let andeeFist = (x: 42.5, y: 33.5)

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// Draws `art` on a layer of its own, positioned like `c`, and lays it over `c` at `alpha` (props fading in and out).
private func faded(_ c: PixelCanvas, _ alpha: Double, _ art: (PixelCanvas) -> Void) {
    guard alpha > 0 else { return }
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    c.paste(s, alpha: alpha)
    c.ox = ox; c.oy = oy; c.baseY = by
}

/// A hand raised from the shoulder at (`sx`, 34) to (`hx`, `hy`): a sleeve and a 2×2 hand.
private func raisedHand(_ c: PixelCanvas, from sx: Double, _ hx: Int, _ hy: Int, sleeve: Px, hand: Px) {
    burtonLine(c, sx, 34, Double(hx) + 1, Double(hy) + 2, sleeve, 1.1)
    c.rect(hx, hy, 2, 2, hand)
}

/// Little pixel capitals, 3×5 each with a gap, in `col` from (x, y): "HEE", "AHH!".
private func shout(_ c: PixelCanvas, _ text: String, x: Int, y: Int, _ col: Px) {
    let glyphs: [Character: [String]] = [
        "H": ["H.H", "H.H", "HHH", "H.H", "H.H"], "E": ["HHH", "H..", "HH.", "H..", "HHH"],
        "A": [".H.", "H.H", "HHH", "H.H", "H.H"], "!": ["H", "H", "H", ".", "H"],
    ]
    var cx = x
    for ch in text {
        guard let g = glyphs[ch] else { cx += 4; continue }
        c.pattern(cx, y, g, ["H": col])
        cx += g[0].count + 1
    }
}

/// Dust kicked up round (x, 43) as something lands heavily, `k` 0…1 through it.
private func dust(_ c: PixelCanvas, x: Double, _ k: Double) {
    guard k > 0, k < 1 else { return }
    for s in [-1.0, 1.0] {
        let d = 2 + k * 5
        c.glowLine(x + s * d, 42.5 - k * 2, x + s * d, 42.5 - k * 2, core: C(0xD8D8D0, 0.6 * (1 - k)),
                   glow: C(0xB8B8B0, 0.4 * (1 - k)), coreR: 1, glowR: 2)
    }
}

// MARK: - Francis Buxtun

/// The toy boat: a blue hull, a white sail, a yellow pennant, 7 wide from (x, y).
private func toyBoat(_ c: PixelCanvas, x: Int, y: Int) {
    c.pattern(x, y, ["...Y...", "...SS..", "...SSS.", "BBBBBBB", ".BBBBB."],
              ["Y": C(0xF0C820), "S": C(0xF8F8F4), "B": C(0x2A5AC8)])
}

/// Francis on his own: big curly hair, a smug face, the striped bathrobe; `legs` false when he's in the bath.
private func francisFigure(_ c: PixelCanvas, _ p: Pose, legs: Bool) {
    let red = C(0xD8202A), redD = C(0xA81418), white = C(0xF8F4F0), hair = C(0x5A3A22), hairL = C(0x7A5232)
    if legs {
        drawLegs(c, Look(leg: clawdOrange), step: p.step)
        burtonBoots(c, step: p.step, red, height: 2)
    }
    c.oy += p.breathe
    // The bathrobe's skirts over his legs.
    if legs { burtonStripes(c, 17, 38, 22, seatedPose ? 1 : 2, alongX: true, width: 2, light: white, dark: red) }
    // A big Clawd, a little wider than most; smug, heavy-lidded eyes, a smirk.
    c.rect(17, 25, 22, 13, clawdOrange); c.rect(38, 25, 1, 13, clawdShade); c.rect(17, 37, 22, 1, clawdShade)
    c.rect(14, 33, 3, 3, red); c.rect(39, 33, 3, 3, red)
    c.rect(22, 29, 2, 3, burtonInk); c.rect(32, 29, 2, 3, burtonInk)
    c.rect(22, 29, 2, 1, clawdShade); c.rect(32, 29, 2, 1, clawdShade); c.rect(21, 28, 4, 1, C(0x8A3A20))
    c.rect(31, 28, 4, 1, C(0x8A3A20))
    c.pattern(26, 32, ["....K", "KKKK."], ["K": C(0x5A2A1A)])
    // The striped bathrobe, belted, its white lapels.
    burtonStripes(c, 17, 33, 22, 5, alongX: true, width: 2, light: white, dark: red)
    c.rect(17, 35, 22, 1, redD); c.rect(27, 35, 2, 2, redD)
    // Big curly hair over the top of him.
    c.pattern(16, 18, [
        "......o.o.o.o.o.o.......",
        "....oHoHoHoHoHoHoHo.....",
        "..oHHHHHHHHHHHHHHHHHo...",
        ".oHHHlHHHHlHHHHlHHHHHo..",
        "oHHHHHHHHHHHHHHHHHHHHHo.",
        "HHHlHHHHlHHHHlHHHHlHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHoHoHoHoHoHoHoHoHHHHH",
        "HHH..................HHH",
        "oH....................Ho",
    ], ["H": hair, "o": hairL, "l": hairL])
}

/// Francis Buxtun: the big spoilt rich boy: a big Clawd with a mop of curly hair, smug heavy-lidded eyes and a smirk,
/// in a red-and-white striped bathrobe, his toy boat under his arm. He throws rubber bath toys: yellow ducks.
/// Signature: a bathtub appears round him and he lolls in a bubble bath with his boat, smug, then sinks out of sight
/// under the bubbles; the tub goes, and he's back.
private func drawFrancis(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature
    if let s = sig, s > 0.03, s < 0.97 {
        let tubA = min(ramp(s, 0.03, 0.15), 1 - ramp(s, 0.84, 0.95))
        let inTub = s >= 0.15 && s < 0.84
        let sink = inTub ? Int((ramp(s, 0.48, 0.66) * 17).rounded()) : 0
        let enamel = C(0xF4F4F0), enamelD = C(0xC8C8C4), gold = C(0xE0B030)
        if inTub {
            // Him, low in the water: only what's above the rim shows.
            let fig = PixelCanvas(c.w, c.h)
            fig.ox = c.ox; fig.oy = c.oy + sink; fig.baseY = c.baseY
            francisFigure(fig, p, legs: false)
            let rim = 35 + c.oy + c.baseY
            let (ox, oy, by) = (c.ox, c.oy, c.baseY)
            c.ox = 0; c.oy = 0; c.baseY = 0
            c.paste(fig.onlyRows(0..<rim))
            c.ox = ox; c.oy = oy; c.baseY = by
        } else {
            faded(c, s < 0.5 ? 1 : ramp(s, 0.84, 0.95)) { francisFigure($0, p, legs: true) }
        }
        faded(c, tubA) { t in
            // The clawfoot tub, and the bubbles heaped on it.
            t.rect(12, 35, 33, 2, enamel); t.rect(11, 35, 1, 1, enamel); t.rect(45, 35, 1, 1, enamel)
            t.rect(13, 37, 31, 3, enamel); t.rect(14, 40, 29, 1, enamel); t.rect(16, 41, 25, 1, enamelD)
            t.rect(13, 39, 31, 1, enamelD); t.rect(43, 37, 1, 3, enamelD)
            t.rect(15, 42, 3, 2, gold); t.rect(39, 42, 3, 2, gold)
            for i in 0..<9 {
                let bx = 14 + i * 3 + (i % 2), by = 34 - (i % 3 == 1 ? 1 : 0)
                t.circle(bx, by, i % 2 == 0 ? 2 : 1, C(0xFFFFFF))
            }
            toyBoat(t, x: 34, y: 29 + Int((sin(p.t * 3) * 1).rounded()))
        }
        if sink > 16, frac(p.t * 1.5) < 0.6 {
            let b = frac(p.t * 1.5) / 0.6
            c.pattern(27, 32 - Int(b * 6), [".W.", "W.W", ".W."], ["W": C(0xFFFFFF, 0.8)])
        }
        return
    }
    francisFigure(c, p, legs: true)
    if p.fire != nil || p.ready || p.gunLift > 0 {
        // A rubber duck raised to throw.
        c.oy += p.gunY
        c.rect(40, 31, 2, 2, clawdOrange)
        c.pattern(39, 25, [".YY..", "YKYO.", ".YYY.", "YYYYY", ".YYY."],
                  ["Y": C(0xF0C820), "K": burtonInk, "O": C(0xF07A1A)])
        return
    }
    toyBoat(c, x: 39, y: 30)
}

// MARK: - The Bike Thief

/// Bolt cutters held at the hand along `angle`: long red handles and steel jaws, `open` or snapped shut.
private func boltCutters(_ c: PixelCanvas, angle a: Double, open: Bool) {
    let h = Sprite.hand, side = burtonReach((0, 0), a + 90, 1)
    let j = burtonReach(h, a, 8), tip = burtonReach(h, a, 13)
    let spread = open ? 1.6 : 0.5
    for s in [-1.0, 1.0] {
        let b = burtonReach(h, a, -3)
        burtonLine(c, b.x + side.x * s * 0.8, b.y + side.y * s * 0.8, j.x + side.x * s * 0.6, j.y + side.y * s * 0.6,
                   C(0xC8202A), 0.6)
        burtonTriangle(c, (j.x + side.x * s * 0.2, j.y + side.y * s * 0.2),
                       (j.x + side.x * s * 1.6, j.y + side.y * s * 1.6),
                       (tip.x + side.x * s * spread, tip.y + side.y * s * spread), C(0xA8ACB4))
    }
}

/// The Bike Thief: a shadowy figure: a dark Clawd in a trench coat, its collar turned up, a hat pulled down low over
/// eyes that glint out of the shadow, and a pair of bolt cutters. He fights with the bolt cutters. Signature: he
/// tiptoes up to a chained post, snips the chain, and sneaks off a little way with a cartoon "tee-hee", then creeps
/// back.
private func drawBikeThief(_ c: PixelCanvas, _ p: Pose) {
    let shadow = C(0x3A3A46), shadowD = C(0x2A2A34), coat = C(0x2C2C36), coatD = C(0x1E1E26), coatL = C(0x44444F)
    let hat = C(0x1A1A20), band = C(0x4A4A56), glint = C(0xF0E8A0)
    let sig = p.signature
    var sneak = 0, tiptoe = false
    var cut: Double?, open = true
    if let s = sig {
        tiptoe = s > 0.04 && s < 0.92
        sneak = -Int((sin(ramp(s, 0.5, 0.9) * .pi) * 8).rounded())
        if s > 0.28 && s < 0.5 { cut = -8; open = s < 0.4 }
        // The post and its chain, fading in, cut, the ends dropping away; the post fading out again.
        let postA = min(ramp(s, 0.06, 0.2), 1 - ramp(s, 0.86, 0.96))
        faded(c, postA) { k in
            k.rect(55, 24, 3, 20, C(0x7A7E88)); k.rect(55, 24, 1, 20, C(0xA8ACB4)); k.rect(54, 23, 5, 1, C(0x5A5E68))
            let drop = s < 0.4 ? 0 : Int(ramp(s, 0.4, 0.55) * 8)
            for i in 0..<4 {
                k.rect(51 + i * 2, 31 + (i < 2 ? drop : drop / 2), 2, 2, C(0xC8CCD4))
                k.px(51 + i * 2, 31 + (i < 2 ? drop : drop / 2), C(0x6A6E78))
            }
        }
    }
    c.ox += sneak
    let step = tiptoe ? Int(p.t * 6) % 2 : p.step
    drawLegs(c, Look(leg: coatD), step: step)
    burtonBoots(c, step: step, C(0x0E0E12), height: 1)
    c.oy += p.breathe - (tiptoe ? 1 : 0)
    // The coat: its tails over his legs, the bottom of him belted, the collar turned up at his sides.
    let tails = seatedPose ? 1 : 3
    c.rect(17, 38, 22, tails, coat); c.rect(28, 38, 1, tails, coatD)
    drawBody(c, Look(body: shadow, shade: shadowD, arm: coat, eye: nil))
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD); c.rect(18, 35, 20, 1, coatD)
    c.pattern(15, 27, ["CC..................CCC", "CCC................CCC.", "CCC................CCC.",
                       "CCC................CCC.", "CCC................CCC.", ".CC................CC.."], ["C": coatL])
    // Eyes glinting out of the shadow under the hat.
    c.rect(18, 26, 20, 2, shadowD)
    c.rect(22, 29, 2, 1, glint); c.rect(32, 29, 2, 1, glint)
    // The hat pulled down low.
    c.pattern(15, 19, [
        ".......HHHHHHHHHH.......",
        "......HHHHHHHHHHHH......",
        "......HHHHHHHHHHHH......",
        "......HHHHHHHHHHHH......",
        "......BBBBBBBBBBBB......",
        ".HHHHHHHHHHHHHHHHHHHHHHH",
        "..hhhhhhhhhhhhhhhhhhhhh.",
    ], ["H": hat, "B": band, "h": C(0x0C0C10)])
    // The bolt cutters: snipping, swinging, or held down at his side.
    if let a = cut ?? p.melee {
        for (i, ta) in p.trail.enumerated() where cut == nil {
            let e = burtonReach(Sprite.hand, ta, 13)
            c.glowLine(Sprite.hand.x, Sprite.hand.y, e.x, e.y, core: C(0xC8CCD4), glow: C(0xC8CCD4), coreR: 0.4,
                       glowR: 1.4, strength: 0.25 / Double(i + 1))
        }
        boltCutters(c, angle: a, open: open)
    } else {
        boltCutters(c, angle: 82, open: false)
    }
    if let s = sig, s > 0.55, s < 0.85 {
        let a = min(ramp(s, 0.55, 0.6), 1 - ramp(s, 0.8, 0.85))
        shout(c, "HEE", x: 6, y: 11 - (Int(p.t * 6) % 2), C(0xFFFFFF, 0.85 * a))
        shout(c, "HEE", x: 18, y: 6 + (Int(p.t * 6) % 2), C(0xFFFFFF, 0.85 * a))
    }
}

// MARK: - Madam Rubee

/// Madam Rubee: the phoney fortune-teller: an orange Clawd in a red silk turban with a gold jewel and a white plume,
/// blue eye shadow, red lips, gold hoop earrings, strings of coloured beads over a blue shawl with a gold fringe; her
/// crystal ball on its draped stand beside her while she stands, carried in her hands while she walks. She doesn't
/// fight. Signature: she waves her hand over the crystal ball, the other at her temple, and the ball glows.
private func drawMadamRubee(_ c: PixelCanvas, _ p: Pose) {
    let turban = C(0xC8202A), turbanD = C(0x981418), turbanL = C(0xE84A4A), gold = C(0xE8B830), shawl = C(0x2A4AB0)
    let shawlD = C(0x1E3488), cloth = C(0x6A2A9A), clothD = C(0x4A1A70)
    let sig = p.signature
    let k = sig.map { min(ramp($0, 0.08, 0.2), 1 - ramp($0, 0.82, 0.94)) } ?? 0

    // Standing still, the crystal ball on its draped stand beside her (walking, she carries the ball: below). The
    // stand stays put on the floor when she hops or sits.
    let standY = -p.hop
    if !p.walking {
        c.pattern(42, 36 + standY, [".CCCCCCCCC.", "CCCCCCCCCCC", "CcCcCcCcCcC", ".C.......C.",
                                    ".C.......C.", ".C.......C.",
                                    ".D.......D.", "DD.......DD"], ["C": cloth, "c": clothD, "D": C(0x3A1A10)])
        c.rect(45, 34 + standY, 5, 2, gold)
        rubeeBall(c, 47, 30 + standY, r: 4)
    }
    if k > 0 {
        let g = k * (0.7 + 0.3 * sin(p.t * 6))
        c.glowLine(47.5, 30.5 + Double(standY), 47.5, 30.5 + Double(standY), core: C(0xFFFFFF, g),
                   glow: C(0xB070FF, g * 0.8), coreR: 2.5, glowR: 4 + 3 * g)
    }
    drawLegs(c, Look(leg: clawdOrange), step: p.step)
    burtonBoots(c, step: p.step, gold, height: 1)
    c.oy += p.breathe
    // The shawl over the bottom of her and over her legs, its gold fringe.
    let tails = seatedPose ? 1 : 2
    c.rect(17, 38, 22, tails, shawl)
    for x in stride(from: 17, to: 39, by: 2) { c.px(x, 38 + tails, gold) }
    drawBody(c, Look(arm: shawl))
    c.rect(22, 28, 2, 1, C(0x4A7AE8)); c.rect(32, 28, 2, 1, C(0x4A7AE8))
    c.pattern(26, 31, ["RRRR", ".RR."], ["R": C(0xC0202A)])
    c.rect(18, 33, 20, 5, shawl); c.rect(37, 33, 1, 5, shawlD)
    // Strings of beads in every colour.
    let beads = [C(0xD8202A), C(0xF0C820), C(0x2AA84A), C(0xF8F8F8)]
    for (i, x) in stride(from: 21, through: 35, by: 2).enumerated() {
        let y = 33 + (x < 25 || x > 31 ? 0 : 1) + (x == 27 || x == 29 ? 1 : 0)
        c.px(x, y, beads[i % 4]); c.px(x + 1, y + 2 - (x > 27 ? 1 : 0), beads[(i + 2) % 4])
    }
    // Gold hoops; the turban, its jewel and plume.
    for x in [15, 39] { c.pattern(x - 1, 30, [".G.", "G.G", "G.G", ".G."], ["G": gold]) }
    c.pattern(16, 17, [
        ".......TTTTTTTTTT.......",
        ".....TTTTTTTTTTTTTT.....",
        "...TTTTlllTTTTTTTTTTT...",
        "..TTTTTTTTlllTTTTTTTTT..",
        ".TTTTTTTTTTTTTlllTTTTTT.",
        ".TTTlllTTTTTTTTTTTlllTT.",
        "TTTTTTTlllTTTTTTTTTTTTTT",
        "TTTTTTTTTTTlllTTTTTTTTTd",
        ".dddddddddddddddddddddd.",
    ], ["T": turban, "l": turbanL, "d": turbanD])
    c.pattern(26, 19, [".GGG.", "GGBGG", ".GGG."], ["G": gold, "B": C(0x2A6AE8)])
    c.pattern(28, 13, [".W", "WW", "W.", "W."], ["W": C(0xF4F0E8)])
    // Hands: one circling over the ball, the other at her temple.
    if k > 0 {
        let hx = 45 + Int((cos(p.t * 5) * 3).rounded()), hy = 22 + standY + Int((sin(p.t * 5) * 1.5).rounded())
        raisedHand(c, from: 39.5, hx, hy, sleeve: shawl, hand: clawdOrange)
        raisedHand(c, from: 16.5, 14, 25, sleeve: shawl, hand: clawdOrange)
    }
    // Walking, she carries the ball in front of her, cupped in both hands.
    if p.walking {
        rubeeBall(c, 42, 29, r: 3)
        c.rect(38, 33, 1, 2, shawl); c.rect(39, 33, 2, 2, clawdOrange); c.rect(43, 33, 2, 2, clawdOrange)
        c.rect(41, 33, 2, 1, clawdOrange)
    }
}

/// Madam Rubee's crystal ball, centred on (`x`, `y`): pale blue glass, a white shine up on the left, a darker crescent
/// down its right side.
private func rubeeBall(_ c: PixelCanvas, _ x: Int, _ y: Int, r: Int) {
    c.circle(x, y, r, C(0xA8C8F0))
    c.circle(x - 1, y - 1, 1, C(0xE8F4FF)); c.px(x - 2, y - 2, C(0xFFFFFF))
    for dy in -(r / 2)...(r / 2) { c.px(x + r - 1 - abs(dy) / 2, y + 1 + dy, C(0x7AA0D8)) }
}

// MARK: - Andee

/// Andee: Dottie's enormous, short-tempered boyfriend: a Clawd a size bigger than most, a flat crew cut, angry brows
/// and a scowl, a red plaid shirt over a white T-shirt, jeans, and big fists. He punches. Signature: he cracks his
/// knuckles, then stomps forward after someone, the ground shaking, and back.
private func drawAndee(_ c: PixelCanvas, _ p: Pose) {
    let hair = C(0x3A2A1E), hairL = C(0x5A4430), red = C(0xC8202A), redD = C(0x7A0E14), line = C(0x2A0A0E)
    let sig = p.signature
    let cracking = sig.map { $0 > 0.06 && $0 < 0.42 } ?? false
    let stomp = sig.map { $0 >= 0.46 && $0 < 0.92 } ?? false
    var landed = -1.0, step = p.step
    if stomp, let s = sig {
        let k = ramp(s, 0.46, 0.92), ph = k * 6, f = ph - floor(ph)
        c.ox += Int((sin(k * .pi) * 4).rounded())
        step = Int(ph) % 2
        if f < 0.35 { landed = f / 0.35; c.ox += Int(p.t * 30) % 2 == 0 ? 1 : 0 }
    }
    drawLegs(c, Look(leg: C(0x3A4A7A)), step: step)
    burtonBoots(c, step: step, C(0x2A1E14), height: 2)
    if landed >= 0 { dust(c, x: 20, landed); dust(c, x: 36, landed) }
    c.oy += p.breathe
    // The big block, his scowl.
    c.rect(16, 23, 24, 15, clawdOrange); c.rect(39, 23, 1, 15, clawdShade); c.rect(16, 37, 24, 1, clawdShade)
    c.rect(21, 27, 2, 3, burtonInk); c.rect(33, 27, 2, 3, burtonInk)
    c.pattern(19, 25, ["KK..............KK", "..KKK........KKK..", "....K........K...."], ["K": C(0x5A2A1A)])
    c.pattern(24, 31, ["..KKKKKK..", ".K......K.", "K........K"], ["K": C(0x5A2A1A)])
    // The plaid shirt over the bottom of him, open on a white T-shirt.
    for y in 33...37 {
        for x in 16...39 {
            let v = (x - 16) % 4 == 3, h = y == 35
            c.px(x, y, v && h ? line : (v || h ? redD : red))
        }
    }
    c.pattern(25, 33, ["WWWWWW", ".WWWW.", "..WW.."], ["W": C(0xF4F4F0)])
    // The crew cut: short and flat across the top.
    c.pattern(16, 20, [
        "...HHHHHHHHHHHHHHHHHH...",
        ".HHhHHhHHhHHhHHhHHhHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HH....................HH",
    ], ["H": hair, "h": hairL])
    // Fists: cracking his knuckles, punching, or at his sides.
    let fist = { (x: Int, y: Int) in c.rect(x, y, 4, 4, clawdOrange); c.rect(x, y + 3, 4, 1, clawdShade) }
    if cracking {
        burtonLine(c, 14, 34, 38, 31, red, 1.3); burtonLine(c, 40, 34, 41, 31, red, 1.3)
        let j = Int(p.t * 8) % 2
        fist(37 + j, 29); fist(41, 29)
        if j == 0 { c.pattern(43, 24, ["W.W", ".W.", "W.W"], ["W": C(0xFFFFFF, 0.85)]) }
        return
    }
    c.rect(12, 32, 4, 4, red); fist(11, 33)
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() {
            let e = burtonReach(andeeFist, ta, 4)
            c.glowLine(e.x, e.y, e.x, e.y, core: clawdOrange, glow: clawdOrange, coreR: 1.5, glowR: 2.5,
                       strength: 0.3 / Double(i + 1))
        }
        let e = burtonReach(andeeFist, a, 4)
        burtonLine(c, 40, 34, e.x, e.y, red, 1.4)
        fist(Int(e.x.rounded()) - 2, Int(e.y.rounded()) - 2)
    } else {
        c.rect(40, 32, 3, 4, red); fist(40, 33)
    }
}

// MARK: - The small fry

/// A small fry's four short legs under a 14×9 body at (21, 30), the size of Halloween Town's trick-or-treaters, and
/// the breathing bob.
private func smallLegs(_ c: PixelCanvas, _ p: Pose, _ leg: Px, foot: Px? = nil) {
    if seatedPose {
        for lx in [22, 25, 30, 33] { c.rect(lx - 1, 37, 3, 2, leg) }
    } else {
        for (i, lx) in [22, 25, 30, 33].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, 39, 2, lifted ? 3 : 4, leg)
            if let foot { c.rect(lx, lifted ? 41 : 42, 2, 1, foot) }
        }
    }
    c.oy += p.breathe
}

/// Bob: one of Beetlejooce's shrunken-head workers. The small fry's block is his shrunken head: dark, wrinkled
/// leathery brown, black hair combed flat over its top, wide staring eyes and a tiny mouth stitched shut with pale
/// thread; over its bottom rows, a dark suit collar with a white shirt and a thin black tie, suit sleeves at his sides
/// and suit trousers down to black shoes.
private func drawBob(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x2E2E3A), suitD = C(0x20202A), head = C(0x5A4232), headD = C(0x3E2C20)
    smallLegs(c, p, suit, foot: C(0x101012))
    c.pattern(21, 28, [
        "...HHHHHHHH...",
        ".HHHHHHHHHHHH.",
        "HHHHHhHHHHHHHH",
        "SwwSSSSSSSwwSd",
        "SSWWWSSSSWWWSd",
        "SSWKWSnnSWKWSd",
        "SwSSSSSSSSSSwd",
        "SSSSKTKTKSSSSd",
        "SSwSSSSSSSSwSd",
        "UUUUWWKWWUUUUD",
        "DDDDDWKWDDDDDD",
    ], ["H": C(0x16161A), "h": C(0x34343E), "S": head, "d": headD, "w": headD, "n": headD, "W": C(0xF4F0E0),
        "K": burtonInk, "T": C(0xC8B890), "U": suit, "D": suitD])
    c.rect(19, 36, 2, 2, suit); c.rect(35, 36, 2, 2, suit)
}

/// An Oogie Bug: a beetle fallen out of Ooogie Boogie's seams, grown to a small fry's size: a dark green shell with a
/// lime shine, a black head with white eyes and two feelers, six scuttling legs.
private func drawOogieBug(_ c: PixelCanvas, _ p: Pose) {
    let shell = C(0x1E2A16), shellM = C(0x2E4224), shine = C(0x9ADB2E), leg = C(0x101410)
    let scuttle = p.step >= 0 ? p.step : (p.walking ? Int(p.t * 8) % 2 : 0)
    if !seatedPose {
        for (i, lx) in [22, 27, 32].enumerated() {
            let up = (i + scuttle) % 2 == 0 ? 0 : 1
            c.rect(lx, 38, 2, 4 - up, leg); c.rect(lx + 1, 41 - up, 2, 1, leg)
        }
    }
    c.oy += p.breathe
    c.pattern(20, 30, [
        "...SSSSSSSSS...",
        ".SSSMMMMMMMSSS.",
        "SSGGSSSSSSSSSSS",
        "SGGSSSSSSSSSSSS",
        "SSSSSSSSSSSSSSS",
        "SMMMMMMMMMMMMMS",
        ".SSSSSSSSSSSSS.",
        "...SSSSSSSSS...",
    ], ["S": shell, "M": shellM, "G": shine])
    c.rect(27, 30, 1, 8, C(0x0E140A))
    c.pattern(35, 32, ["..HHH", ".HHHH", "HHWHH", "HHHHH", ".HHH."], ["H": leg, "W": C(0xFFFFFF)])
    c.rect(38, 29, 1, 3, leg); c.rect(39, 28, 2, 1, leg); c.rect(36, 30, 1, 2, leg); c.rect(36, 29, 2, 1, leg)
}

/// A Nut Squirrel: one of the squirrels who sort nuts in Wonka's factory: a little brown squirrel with a cream belly,
/// tufted ears and a huge bushy tail curling up behind it, a walnut held in its paws.
private func drawNutSquirrel(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0xA8683A), furD = C(0x7E4A26), furL = C(0xC88A54), belly = C(0xF0D8B0), nut = C(0xC8A070)
    let nutD = C(0x8A6A40)
    smallLegs(c, p, fur)
    // The bushy tail curling up behind it.
    c.pattern(12, 17, [
        "...TTTT....",
        ".TTTTTTTT..",
        "TTTLLTTTTT.",
        "TTL...TTTT.",
        "TT.....TTT.",
        "........TTT",
        "........TTT",
        "........TTT",
        ".......TTTT",
        "......TTTTT",
        ".....TTTTTT",
        "....TTTTTTT",
        "...TTTTTTTT",
        "....TTTTTTT",
        "......TTTTT",
    ], ["T": furD, "L": furL])
    c.rect(21, 30, 14, 9, fur); c.rect(34, 30, 1, 9, furD); c.rect(26, 32, 7, 6, belly)
    // The head, its ears, eyes and nose.
    c.pattern(25, 22, ["E.....E.", "EE...EE.", "FFFFFFF.", "FKFFFKFF", "FFFFFFFN", ".FFFFFF."],
              ["E": furD, "F": fur, "K": burtonInk, "N": C(0x3A2010)])
    c.rect(26, 28, 7, 2, fur)
    // The walnut in its paws.
    c.pattern(33, 30, [".NNN.", "NnNnN", "NNnNN", ".NNN."], ["N": nut, "n": nutD])
    c.rect(31, 33, 2, 1, fur); c.rect(37, 33, 2, 1, fur)
}

/// A Sea-Monkey: one of Frankenweenie's brine shrimp, grown monstrous, in greys: a little grey creature with a big
/// round head, a finned crest and fin-ears, huge round eyes and a wide toothy grin, a small pale belly and a fish's
/// tail.
private func drawSeaMonkey(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x9A9AA0), skinD = C(0x76767C), skinL = C(0xBCBCC2), belly = C(0xD0D0D4), fin = C(0x5E5E66)
    smallLegs(c, p, skinD)
    burtonTriangle(c, (22, 34), (22, 38), (15, 32), fin); burtonTriangle(c, (22, 34), (22, 38), (16, 40), fin)
    c.rect(22, 32, 12, 7, skin); c.rect(33, 32, 1, 7, skinD); c.rect(25, 33, 6, 5, belly)
    c.rect(20, 34, 2, 2, skin); c.rect(34, 34, 2, 2, skin)
    // The fins: a crest on top and an ear-fin either side.
    for (k, x) in [24, 28, 32].enumerated() {
        burtonTriangle(c, (Double(x) - 1.5, 23), (Double(x) + 1.5, 23), (Double(x) - 1, Double(k == 1 ? 18 : 19)), fin)
    }
    burtonTriangle(c, (21, 25), (21, 29), (16, 24), fin); burtonTriangle(c, (35, 25), (35, 29), (40, 24), fin)
    // The big round head: huge eyes and a wide grin full of little teeth.
    c.ellipse(28, 27, 7, 5, skin); c.rect(23, 23, 6, 1, skinL)
    c.pattern(23, 24, ["WWW..WWW.", "WKW..WKW.", "WWW..WWW."], ["W": C(0xF8F8F8), "K": burtonInk])
    c.rect(32, 24, 1, 3, skin)
    c.pattern(23, 28, ["KKKKKKKKKK", "KWKWKWKWKK", ".KKKKKKKK."], ["K": C(0x2A2A30), "W": C(0xF8F8F8)])
}
