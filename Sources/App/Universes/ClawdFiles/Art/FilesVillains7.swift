import Foundation

// Villains: monsters of the week, and the agent-only small fry. The Chupacabra, Big Blue, Tithonus, Cecil L'ively,
// Luther Lee Boggs and Eddie Van Blundht; a killer bee, a robo-roach and a flukeworm. The people are Clawd in costume
// like the rest of the cast; the creatures are creatures, with their own shapes.

let filesVillains7: [FilesVillain: Persona] = [
    .chupacabra: Persona(name: "The Chupacabra", weapon: .saber, canSit: false, headTop: 22, signature: 2.8,
                         callout: "Skreeee!",
                         draw: drawChupacabra),
    .bigBlue: Persona(name: "Big Blue", weapon: .saber, motion: .hover, canSit: false, headTop: 12, signature: 4.0,
                      fidgets: false,
                      draw: drawBigBlue),
    .tithonus: Persona(name: "Tithonus", weapon: .lightning, magic: Magic(core: C(0xFFFFFF), glow: C(0xD8E4FF), jagged: false),
                       pivot: flashBulb, headTop: 21, signature: 3.2, callout: "Hold still.",
                       draw: drawTithonus),
    .cecilLively: Persona(name: "Cecil L'ively", weapon: .lightning, magic: Magic(core: C(0xFFF0A0), glow: C(0xFF5A1A)),
                          pivot: (43.0, 32.0), headTop: 21, signature: 3.4, callout: "It doesn't hurt.",
                          draw: drawCecilLively),
    .lutherLeeBoggs: Persona(name: "Luther Lee Boggs", headTop: 23, signature: 3.6, callout: "They speak through me.",
                             draw: drawLutherLeeBoggs),
    .eddieVanBlundht: Persona(name: "Eddie Van Blundht", headTop: 23, signature: 3.4, callout: "I'm Agent Clawder. Really.",
                              draw: drawEddieVanBlundht),
    .killerBee: Persona(name: "Killer Bee", motion: .fly, canSit: false, headTop: 28, fidgets: false,
                        draw: drawKillerBee),
    .roboRoach: Persona(name: "Robo-Roach", armoured: true, canSit: false, headTop: 34, fidgets: false,
                        draw: drawRoboRoach),
    .flukeworm: Persona(name: "Flukeworm", canSit: false, headTop: 36, fidgets: false,
                        draw: drawFlukeworm),
]

/// Where Tithonus's flashbulb is, the camera raised: the flash leaves from there.
private let flashBulb = (x: 47.0, y: 28.0)

// MARK: - Shared bits

/// A line of `w`×`w` dots from (x0, y0) to (x1, y1).
private func dots(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, w: Int = 1) {
    let n = max(1, Int(max(abs(x1 - x0), abs(y1 - y0)).rounded(.up)))
    for k in 0...n {
        let f = Double(k) / Double(n)
        c.rect(Int((x0 + (x1 - x0) * f).rounded(.down)), Int((y0 + (y1 - y0) * f).rounded(.down)), w, w, col)
    }
}

/// A little flame licking up from (x, y), `h` tall, flickering on the clock `t` (its own phase `k`).
private func drawLick(_ c: PixelCanvas, x: Int, y: Int, h: Int, t: Double, k: Int) {
    let flick = Int(t * 10 + Double(k) * 1.7) % 3
    let top = h + (flick == 0 ? 1 : 0)
    for i in 0..<top {
        let col = i < top / 3 ? C(0xFFF2A0) : i < top * 2 / 3 ? C(0xFFA02A) : C(0xE8461A, 0.85)
        c.px(x + (i == top - 1 && flick == 2 ? 1 : 0), y - i, col)
    }
}

// MARK: - The Chupacabra

/// The Chupacabra: a hunched grey-green beast on bent hind legs, a long back bristling with dark quills, a thin tail,
/// a narrow head thrust forward with big red eyes and fangs, and long arms ending in hooked claws that rake when it
/// fights. Signature: it rears up and rattles its quills, mouth wide, then drops back into its crouch.
private func drawChupacabra(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x6E7A5E), skinD = C(0x4A5440), skinL = C(0x8E9A7A), quill = C(0x2A2620), quillTip = C(0x8A1E1E)
    let eye = C(0xFF2A2A), fang = C(0xF2EEDC), claw = C(0xE8E0C8)
    let sig = p.signature
    let rear = sig.map { s -> Double in s < 0.2 ? s / 0.2 : s > 0.8 ? (1 - s) / 0.2 : 1 } ?? 0
    let rattle = rear > 0.9 && Int(p.t * 14) % 2 == 0
    let lift = Int((rear * 5).rounded())
    let stride = p.step >= 0 ? (p.step == 0 ? 1 : -1) : 0

    // The hind legs: thighs bent forward, shins back, splayed toes.
    for (i, hx) in [21, 31].enumerated() {
        let s = i == 0 ? stride : -stride
        dots(c, Double(hx), 37, Double(hx + 3 + s), 40, skinD, w: 2)
        dots(c, Double(hx + 3 + s), 40, Double(hx + s), 43, skinD, w: 2)
        c.rect(hx - 1 + s, 43, 4, 1, claw)
    }
    // The tail, whipping a little.
    let swish = sin(p.lt * 2.2) * 2
    dots(c, 18, 35, 11, 37 + swish, skinD, w: 1); dots(c, 11, 37 + swish, 7, 34 + swish, skinD, w: 1)
    c.oy += p.breathe - lift
    // The hunched back and belly: a long arched body, lower at the tail end.
    c.pattern(16, 27, [
        "......SSSSSSSSSSS.......",
        "....SSSSSSSSSSSSSSSS....",
        "..SSSSSSSSSSSSSSSSSSSS..",
        ".SSSSSSSSSSSSSSSSSSSSSS.",
        "SSSSSSSSSSSSSSSSSSSSSSSS",
        "SSSSSSSSSSSSSSSSSSSSSSSL",
        "SSSSSSSSSSSSSSSSSSSSSLL.",
        ".SSSSSSSSSSSSSSSSSSLLL..",
        "..DDDDDDDDDDDDDDDDDD....",
        "....DDDDDDDDDDDDDD......",
    ], ["S": skin, "L": skinL, "D": skinD])
    // The quills along the spine, standing taller (and shaking) as it rears.
    for (i, qx) in [19, 22, 25, 28, 31, 34].enumerated() {
        let h = 3 + (i % 2) + Int(rear * 2)
        let dx = rattle ? (i % 2 == 0 ? 1 : -1) : 0
        let base = 27 + (i == 0 || i == 5 ? 1 : 0)
        for k in 0..<h { c.px(qx + (k > 1 ? dx : 0), base - k, k == h - 1 ? quillTip : quill) }
    }
    // The head, thrust forward: a long snout, red eyes, fangs (the mouth open wide while it shrieks).
    let shriek = rear > 0.5
    c.pattern(36, 26, [
        "..HHHHH....",
        ".HHHHHHHHH.",
        "HHHHHHHHHHH",
        "HHHHHHHHHHH",
        ".HHHHHHHHH.",
        "..hhhhhhh..",
    ], ["H": skin, "h": skinD])
    c.rect(39, 27, 2, 2, eye); c.px(40, 27, C(0xFFB0A0))
    if shriek {
        c.rect(41, 31, 6, 2, C(0x3A0E0E)); c.px(42, 31, fang); c.px(45, 31, fang); c.px(43, 32, fang)
    } else {
        c.px(44, 30, fang); c.px(46, 30, fang)
    }
    // The arms: long and thin, the claws hooked; raking out when it fights.
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() { chupaArm(c, angle: ta, skin: skinD.alpha(0.35 / Double(i + 1)), claw: claw.alpha(0.35 / Double(i + 1))) }
        chupaArm(c, angle: a, skin: skinD, claw: claw)
    } else {
        dots(c, 34, 33, 37, 38, skinD, w: 2); c.px(37, 40, claw); c.px(39, 40, claw); c.px(38, 40, claw)
    }
    dots(c, 22, 33, 20, 38, skinD, w: 2); c.px(19, 40, claw); c.px(21, 40, claw)
}

/// The Chupacabra's raking arm out at `angle` degrees, its three claws fanned.
private func chupaArm(_ c: PixelCanvas, angle: Double, skin: Px, claw: Px) {
    let r = angle * .pi / 180
    let sx = 35.0, sy = 33.0, hx = sx + cos(r) * 8, hy = sy + sin(r) * 8
    dots(c, sx, sy, hx, hy, skin, w: 2)
    for spread in [-0.45, 0.0, 0.45] {
        dots(c, hx, hy, hx + cos(r + spread) * 3, hy + sin(r + spread) * 3, claw)
    }
}

// MARK: - Big Blue

/// Big Blue: the lake monster. Only what's above the water shows: a ring of ripples where it breaks the surface, two
/// dark humps of its back behind, and a long blue-grey neck curving up to a small head with a pale eye and a wide
/// mouth. It sways as it waits and lunges with its head when it fights. Signature: it sinks under, the ripples
/// spreading where it went, and surfaces again.
private func drawBigBlue(_ c: PixelCanvas, _ p: Pose) {
    let hide = C(0x3E5E78), hideD = C(0x26405A), hideL = C(0x6A8CA8), belly = C(0x9AB4C4)
    let water = C(0x1E3A5A), foam = C(0xD8EAF4)
    let sig = p.signature
    let under = sig.map { s -> Double in s < 0.15 ? 0 : s < 0.35 ? (s - 0.15) / 0.2 : s < 0.6 ? 1 : max(0, 1 - (s - 0.6) / 0.25) } ?? 0
    let sink = Int((under * 30).rounded())
    // The water: a dark pool with rings spreading out from the neck.
    c.ellipse(28, 42, 17, 2, water)
    let ring = frac(p.t / 2.4)
    let rw = 6 + Int(ring * 12)
    for x in stride(from: 28 - rw, through: 28 + rw, by: 2) { c.px(x, 41 + (x % 4 == 0 ? 1 : 0), foam.alpha(0.8 * (1 - ring))) }
    c.rect(25, 41, 7, 1, foam.alpha(0.9))
    guard sink < 28 else { return }
    // Everything above the water is drawn on its own canvas, moved down as it sinks, and cut off at the waterline.
    let below = PixelCanvas(c.w, c.h)
    below.oy = sink
    let sway = Int((sin(p.lt * 1.1) * 1.5).rounded())
    let lunge = p.melee.map { a in Int(((a + 90) / 30).rounded()) } ?? 0
    // The humps behind.
    below.ellipse(15, 40, 5, 3, hideD); below.ellipse(15, 39, 4, 2, hide)
    below.ellipse(41, 40, 4, 2, hideD); below.ellipse(41, 39, 3, 1, hide)
    // The neck: a thick curve up from the water to the head.
    let hx = 32 + sway + max(0, lunge), hy = 15 + (lunge > 0 ? 2 : 0)
    for i in 0...24 {
        let f = Double(i) / 24
        let x = 26.0 + (Double(hx) - 26) * f + sin(f * .pi) * -4
        let y = 41.0 - (41 - Double(hy + 4)) * f
        let w = 5 - Int(f * 2)
        below.rect(Int(x) - w / 2, Int(y), w, 1, hide)
        below.px(Int(x) - w / 2, Int(y), hideL)
        below.px(Int(x) + w / 2 - (w % 2 == 0 ? 1 : 0), Int(y), belly)
    }
    // The head: a blunt reptile head, a pale eye, a long mouth line (open when it lunges).
    below.pattern(hx - 3, hy - 1, [
        "..HHHHHH...",
        ".HHHHHHHHH.",
        "HHHHHHHHHHH",
        "HHHHHHHHHHH",
        ".DDDDDDDDD.",
    ], ["H": hide, "D": hideD])
    below.px(hx + 2, hy, C(0xE8F4C8)); below.px(hx + 3, hy, ink)
    if p.melee != nil { below.rect(hx + 3, hy + 3, 5, 1, C(0x4A1A1A)) } else { below.rect(hx + 4, hy + 2, 4, 1, hideD) }
    c.paste(below.onlyRows(0..<41))
}

// MARK: - Tithonus

/// Tithonus: a gaunt, ageless newspaper photographer, Clawd with thin grey hair combed flat, a brown cardigan over a
/// shirt and tie, and an old press camera with a big round flash reflector. Its flash is his weapon: a burst of white.
/// Signature: he raises the camera, the bulb pops, and a fresh print slides out and develops in his other hand.
private func drawTithonus(_ c: PixelCanvas, _ p: Pose) {
    let cardigan = C(0x6A5038), cardiganD = C(0x4E3A28), shirt = C(0xE6E2D6), tie = C(0x3A3A44)
    let hair = C(0xA8AAB0), hairD = C(0x7E8088), trousers = C(0x4A4A50)
    let sig = p.signature
    let shooting = (sig.map { $0 > 0.08 && $0 < 0.5 } ?? false) || p.zap != nil || p.ready || (!p.resting && !p.walking)
    let pop = sig.map { $0 > 0.28 && $0 < 0.38 } ?? false
    let print = sig.map { $0 >= 0.45 && $0 < 0.95 } ?? false
    drawLegs(c, Look(leg: trousers), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0x3A2416))
    c.oy += p.breathe
    drawBody(c, Look(arm: cardigan))
    c.rect(18, 34, 20, 4, cardigan); c.rect(37, 34, 1, 4, cardiganD); c.rect(18, 37, 20, 1, cardiganD)
    c.pattern(25, 34, ["SSTTSS", ".STTS.", "..TT.."], ["S": shirt, "T": tie])
    for y in [35, 37] { c.px(23, y, C(0xC8B48A)) }   // the cardigan's buttons
    // Thin grey hair, combed flat over the top.
    c.pattern(17, 22, [
        ".....HHHHHHHHHHHH.....",
        "...HHhHHHHHhHHHHHHH...",
        "..HHHHHHHHHHHHHhHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HH................HH.",
    ], ["H": hair, "h": hairD])
    // Sunken eyes: a shadow under each.
    c.rect(22, 32, 2, 1, C(0xB85F40)); c.rect(32, 32, 2, 1, C(0xB85F40))
    c.rect(15, 33, 3, 3, cardigan)
    if print {
        // The print in his left hand, its picture coming up out of the white.
        let k = min(1, ((sig ?? 0) - 0.45) / 0.3)
        c.rect(10, 31, 6, 5, C(0xF4F2EA)); c.rect(11, 32, 4, 3, C(0x2A2A30, k * 0.8))
        c.px(13, 33, C(0xE8E4D8, k * 0.6))
    }
    if shooting {
        // The camera up to his eye: the body, the lens, the round reflector with its bulb at `flashBulb`.
        c.rect(38, 30, 3, 4, cardigan)
        c.rect(39, 28, 6, 5, C(0x24242A)); c.rect(40, 29, 2, 2, C(0x6A6E78)); c.rect(45, 29, 2, 3, C(0x3A3A42))
        c.pattern(44, 24, [".RRR.", "RRWRR", "RWBWR", "RRWRR", ".RRR."], ["R": C(0xC8CCD4), "W": C(0xEEF2F6), "B": C(0xFFF6D0)])
        if pop || p.zap == true {
            c.circle(46, 26, 4, C(0xFFFFFF, 0.55)); c.circle(46, 26, 2, C(0xFFFFFF, 0.9))
        }
    } else {
        // The camera hanging on its strap at his chest.
        c.rect(38, 33, 3, 3, cardigan)
        c.rect(26, 33, 6, 4, C(0x24242A)); c.rect(28, 34, 2, 2, C(0x6A6E78)); c.px(25, 33, C(0x3A3A42)); c.px(32, 33, C(0x3A3A42))
    }
}

// MARK: - Cecil L'ively

/// Cecil L'ively: Clawd with slicked-back black hair, a white vest and dark trousers, small flames always dancing at
/// his fingertips. He throws fire. Signature: he sets himself alight, flames climbing all over him while he stands
/// there perfectly calm, then they die back to his fingers.
private func drawCecilLively(_ c: PixelCanvas, _ p: Pose) {
    let vest = C(0xEEEEE8), vestD = C(0xC8C8C0), trousers = C(0x2A2A30), hair = C(0x16141A), hairL = C(0x3A3640)
    let sig = p.signature
    let ablaze = sig.map { s -> Double in s < 0.15 ? s / 0.15 : s > 0.8 ? (1 - s) / 0.2 : 1 } ?? 0
    drawLegs(c, Look(leg: trousers), step: p.step)
    drawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: clawdOrange))
    // The vest: a white singlet, straps over the shoulders.
    c.rect(19, 35, 18, 3, vest); c.rect(36, 35, 1, 3, vestD); c.rect(19, 37, 18, 1, vestD)
    c.rect(22, 34, 3, 1, vest); c.rect(31, 34, 3, 1, vest)       // the scoop neck, Clawd showing in it
    c.rect(22, 33, 1, 1, vest); c.rect(33, 33, 1, 1, vest)       // the straps
    // Slicked-back black hair with a shine.
    c.pattern(17, 22, [
        "....HHHHHHHHHHHHHH....",
        "..HHHHHlllHHHHHHHHHH..",
        ".HHHHHHHHHlllHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HH..................HH",
    ], ["H": hair, "l": hairL])
    // A calm, heavy-lidded look.
    c.rect(22, 29, 2, 1, C(0xB85F40)); c.rect(32, 29, 2, 1, C(0xB85F40))
    let casting = p.zap != nil || p.ready || (!p.resting && !p.walking)
    c.rect(15, 33, 3, 3, clawdOrange)
    if casting {
        c.rect(38, 31 - p.armRaise, 4, 3, clawdOrange)
        for i in 0..<3 { drawLick(c, x: 41 + i, y: 30 - p.armRaise, h: 3 + i % 2, t: p.t, k: i) }
    } else {
        c.rect(38, 33, 3, 3, clawdOrange)
        for i in 0..<3 { drawLick(c, x: 38 + i, y: 32, h: 2 + i % 2, t: p.t, k: i + 3) }
    }
    for i in 0..<3 { drawLick(c, x: 15 + i, y: 32, h: 2, t: p.t, k: i + 6) }
    // Alight all over: flames up his body and over his head, and he doesn't so much as blink.
    if ablaze > 0 {
        for i in 0..<12 {
            let x = 17 + i * 2, h = Int(Double(4 + Int(noise(i + 40) * 6)) * ablaze)
            if h > 0 { drawLick(c, x: x, y: 26 + (i % 3) * 4, h: h, t: p.t, k: i) }
        }
        c.rect(17, 24, 22, 14, C(0xFF8A2A, 0.18 * ablaze))
    }
}

// MARK: - Luther Lee Boggs

/// Luther Lee Boggs: Clawd in an orange prison jumpsuit with a number stencilled on it, his head shaved to dark stubble,
/// his wrists in cuffs on a short chain. He doesn't fight. Signature: he channels the dead: his eyes roll back white,
/// his head tips back, and pale wisps of faces drift up and around him, then fade.
private func drawLutherLeeBoggs(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0xE8701E), suitD = C(0xB8501A), stubble = C(0x3A2E26), steel = C(0xC8CCD4)
    let sig = p.signature
    let channel = sig.map { s -> Double in s < 0.15 ? s / 0.15 : s > 0.85 ? (1 - s) / 0.15 : 1 } ?? 0
    drawLegs(c, Look(leg: suit), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() { c.rect(lx, p.step >= 0 && i % 2 == p.step ? 41 : 42, 2, 2, C(0xEEEEE8)) }
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: suit, eye: channel > 0.5 ? nil : ink))
    // The jumpsuit and its stencilled number.
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(25, 33, ["V....V", ".V..V.", "..VV.."], ["V": suitD])
    c.pattern(30, 35, ["W.W.W", "WWWW."], ["W": C(0xF4E8D8)])
    // The shaved head: a speckle of stubble across the top, meeting the body.
    for y in 23...25 {
        for x in stride(from: 19 + (y == 23 ? 3 : 0), through: 36 - (y == 23 ? 3 : 0), by: 1) where (x + y) % 2 == 0 {
            c.px(x, y, stubble)
        }
    }
    c.rect(18, 25, 20, 1, stubble.alpha(0.6))
    if channel > 0.5 {
        // The eyes rolled back: white, a sliver of iris at the top.
        for x in [22, 32] { c.rect(x, 29, 2, 3, C(0xF4F4EE)); c.rect(x, 29, 2, 1, C(0x5A6A7A)) }
        c.rect(26, 33, 4, 1, C(0x5A2418))   // the mouth hanging open
    }
    // Hands in front, cuffed, the short chain between.
    c.rect(15, 33, 3, 3, suit); c.rect(38, 33, 3, 3, suit)
    c.rect(17, 36, 2, 1, steel); c.rect(37, 36, 2, 1, steel)
    for x in stride(from: 19, to: 37, by: 2) { c.px(x, 37, steel) }
    // The dead: pale faces drifting up round him.
    if channel > 0 {
        for i in 0..<4 {
            let a = p.t * 1.3 + Double(i) * 1.57
            let x = 28 + Int(cos(a) * 14), y = 20 - i * 3 + Int(sin(a) * 3)
            let ghost = C(0xD8E8F4, 0.55 * channel)
            c.pattern(x - 2, y, [".GGG.", "GDGDG", "GGGGG", "G.G.G"], ["G": ghost, "D": C(0x2A3A4A, 0.6 * channel)])
        }
    }
}

// MARK: - Eddie Van Blundht

/// Eddie Van Blundht: Clawd as a sad-sack small-town guy, thinning brown hair over a big forehead, a checked flannel
/// shirt and jeans, and a little curly tail poking out at the back. He doesn't fight. Signature: he shifts into Fox
/// Clawder (the fringe, the grey suit and the loud tie) with a shimmer, grins, and shifts back.
private func drawEddieVanBlundht(_ c: PixelCanvas, _ p: Pose) {
    let flannel = C(0x8A5A3A), flannelL = C(0xB07A4E), jeans = C(0x3E5A86), hair = C(0x6A4A2E)
    let sig = p.signature
    let shift = sig.map { s -> Double in s < 0.15 ? 0 : s < 0.3 ? (s - 0.15) / 0.15 : s < 0.75 ? 1 : max(0, 1 - (s - 0.75) / 0.15) } ?? 0
    let asClawder = shift > 0.5
    let shimmer = shift > 0.05 && shift < 0.95
    // The tail, behind him, curling.
    let curl = Int(p.lt * 3) % 2
    c.pattern(13, 33 + curl, [".TT", "T..", "T.T", ".T."], ["T": C(0xC8866A)])
    drawLegs(c, Look(leg: asClawder ? C(0x3A3C44) : jeans), step: p.step)
    drawDressShoes(c, step: p.step, color: asClawder ? C(0x18181C) : C(0x6A4A30))
    c.oy += p.breathe
    if asClawder {
        // Clawder: the grey suit, the loud tie and the dark fringe.
        drawBody(c, Look(arm: C(0x4A4740)))
        c.rect(18, 34, 20, 4, C(0x6C707A)); c.rect(37, 34, 1, 4, C(0x52565E))
        c.pattern(24, 34, ["lSTTSl", ".lTTl.", "..TT..", "..tT.."],
                  ["l": C(0x52565E), "S": C(0xEDEDE8), "T": C(0x8A2A3A), "t": C(0xC8A04A)])
        c.rect(18, 33, 4, 5, C(0x4A4740)); c.rect(34, 33, 4, 5, C(0x4A4740))
        c.pattern(17, 20, [
            ".......HHHHHHHH.......",
            "....HHHHHHHHHHHHHH....",
            "...HHHHHHHHHHhHHHHH...",
            "..HHHHHHHHHHHHhHHHHH..",
            "..HHHHHHHHHHHHHHhHHHH.",
            ".HHHHHHHHHHHHHHHHHHHH.",
            ".HHH...HHHHH......HHH.",
            ".HH.....HH.........HH.",
        ], ["H": C(0x3A2618), "h": C(0x56391F)])
        c.rect(26, 33, 4, 1, C(0x8E4A38))   // the grin
        c.rect(15, 33, 3, 3, C(0x4A4740)); c.rect(38, 33, 3, 3, C(0x4A4740))
    } else {
        drawBody(c, Look(arm: flannel))
        // The flannel shirt: checks.
        c.rect(18, 33, 20, 5, flannel)
        for y in 33...37 { for x in 18...37 where (x / 2 + y / 2) % 2 == 0 { c.px(x, y, flannelL) } }
        c.rect(27, 33, 2, 5, C(0x5A3A26))
        // Thin hair, the forehead showing: a wisp on top and the sides.
        c.pattern(17, 22, [
            "........HHHHH.........",
            "......HH..HHHHH.......",
            "..HHHH..........HHHH..",
            ".HHHH............HHHH.",
            ".HHH..............HHH.",
        ], ["H": hair])
        c.rect(19, 25, 18, 1, clawdOrange)   // the high forehead, filled to the body so no outline line shows
        c.rect(15, 33, 3, 3, flannel); c.rect(38, 33, 3, 3, flannel)
    }
    if shimmer {
        let k = Int(p.t * 12)
        for y in stride(from: 20 + k % 3, to: 43, by: 3) { c.rect(16, y, 24, 1, C(0xE8F0FF, 0.35)) }
    }
}

// MARK: - The small fry

/// A killer bee: a fat little yellow-and-black bee with a stinger, its wings a buzzing blur; it bobs about in the air.
private func drawKillerBee(_ c: PixelCanvas, _ p: Pose) {
    let yellow = C(0xF2C21E), black = C(0x1A1814)
    let bob = Int((sin(p.t * 5) * 2).rounded()), drift = Int((sin(p.t * 1.7) * 3).rounded())
    c.ox += drift; c.oy += bob - (p.flying ? 0 : 4)
    c.pattern(23, 30, [
        "..YYKKYYKK...",
        ".YYYKKYYKKY..",
        "YYYYKKYYKKYYH",
        "YYYYKKYYKKYYH",
        ".YYYKKYYKKY..",
        "..YYKKYYKK...",
    ], ["Y": yellow, "K": black, "H": black])
    c.px(36, 31, white); c.px(35, 31, ink)                  // the eye
    c.px(22, 32, black); c.px(21, 32, C(0x6A6A70))          // the stinger
    c.px(36, 28, black); c.px(37, 27, black)                // a feeler
    let buzz = Int(p.t * 24) % 2 == 0
    c.pattern(25, buzz ? 26 : 27, [".WWW..WWW.", "WWWWWWWWWW"], ["W": C(0xE8F4FF, 0.6)])
    c.px(25, 36, black); c.px(28, 36, black); c.px(31, 36, black)
}

/// A robo-roach: a big glossy brown cockroach that's really a little machine, rivets on its shell, steel legs and a
/// red light for an eye; it scuttles back and forth, feelers twitching.
private func drawRoboRoach(_ c: PixelCanvas, _ p: Pose) {
    let shell = C(0x6A3A1E), shellL = C(0xA0602E), shine = C(0xE8B88A), steel = C(0x9AA0AA), steelD = C(0x5A6068)
    let run = sin(p.t * 1.6)
    c.ox += Int((run * 6).rounded())
    let scurry = Int(p.t * 14) % 2
    for (i, x) in [23, 28, 33].enumerated() {
        let a = (i + scurry) % 2
        c.px(x - a, 42, steelD); c.px(x - 1 - a, 43, steel); c.px(x + 1 + a, 42, steelD); c.px(x + 2 + a, 43, steel)
    }
    c.pattern(20, 36, [
        "....SSSSSSSSSS....",
        "..SSSlSSSSSSlSSS..",
        ".SSSSSSSSSSSSSSSS.",
        "SSSSSSSSSSSSSSSSSS",
        ".DDDDDDDDDDDDDDDD.",
    ], ["S": shell, "l": shine, "D": steelD])
    c.rect(28, 36, 1, 4, shellL.alpha(0.8))                              // the seam down its back
    for x in [24, 32] { c.px(x, 38, steel) }                             // rivets
    c.rect(38, 37, 3, 3, steelD); c.px(40, 38, Int(p.t * 5) % 2 == 0 ? C(0xFF2A2A) : C(0x8A1A1A))
    let tw = Int(p.t * 7) % 2
    c.px(41, 36, steel); c.px(42, 35 - tw, steel); c.px(43, 34 - tw, steel); c.px(44, 34, steel)
    c.px(41, 37, steel); c.px(43, 37 + tw, steel); c.px(45, 37, steel)
}

/// A flukeworm: a pale, ringed little worm with a round toothy sucker, inching along the floor and rearing its head.
private func drawFlukeworm(_ c: PixelCanvas, _ p: Pose) {
    let flesh = C(0xE4E0D2), ring = C(0xB8B2A0), mouth = C(0x6A2A2A)
    let inch = sin(p.t * 3)
    c.ox += Int((sin(p.t * 0.8) * 5).rounded())
    let hump = Int((max(0, inch) * 3).rounded())
    for i in 0..<14 {
        let x = 22 + i
        let y = 41 - (i > 3 && i < 10 ? Int(Double(hump) * sin(Double(i - 3) / 6 * .pi)) : 0)
        c.rect(x, y, 1, 3, flesh); if i % 2 == 0 { c.px(x, y + 1, ring) }
    }
    // The head, reared up a little, and its sucker.
    let rear = inch < -0.5 ? 1 : 0
    c.rect(36, 39 - rear, 3, 4, flesh); c.px(38, 39 - rear, ring)
    c.rect(39, 40 - rear, 1, 2, mouth); c.px(39, 39 - rear, C(0xF4F0E4)); c.px(39, 42 - rear, C(0xF4F0E4))
}
