import Foundation

// Heroes: the rest of the Scooby Gang. Clawd in costume like the rest of the cast: hair and clothes drawn over the
// blocky body, with Clawd's own orange face showing.

let slayerHeroes2: [SlayerHero: Persona] = [
    .xanderHarrows: Persona(name: "Xander Harrows", weapon: .saber, headTop: 21, signature: 3.6,
                            callout: "I laugh in the face of danger!", draw: drawXanderHarrows),
    .rupertGyles: Persona(name: "Rupert Gyles", weapon: .blaster, shot: .arrow, muzzle: (48, 32), handGun: false,
                          headTop: 21, signature: 3.8, callout: "Oh, dear Lord.", draw: drawRupertGyles),
    .cordeliaChaise: Persona(name: "Cordelia Chaise", weapon: .blaster, shot: .arrow, muzzle: (48, 32), handGun: false,
                             headTop: 19, signature: 3.0, callout: "Hel-lo?", draw: drawCordeliaChaise),
    .ozz: Persona(name: "Ozz", weapon: .saber, headTop: 17, signature: 3.0, callout: "Hey.", draw: drawOzz),
    .anyaJinkins: Persona(name: "Anya Jinkins", weapon: .saber, headTop: 20, signature: 3.4, callout: "Bunnies!",
                          draw: drawAnyaJinkins),
    .taraMaclaw: Persona(name: "Tara Maclaw", weapon: .lightning,
                         magic: Magic(core: C(0xFFFFFF), glow: C(0xB49CE8), jagged: false, touch: true),
                         headTop: 20, signature: 3.4, draw: drawTaraMaclaw),
    .spyke: Persona(name: "Spyke", weapon: .saber, headTop: 21, signature: 3.2, callout: "Bloody hell!", draw: drawSpyke),
]

// MARK: - Shared bits

/// Eyes squeezed shut: a `>` and a `<` where the eyes were.
private func squeezedEyes(_ c: PixelCanvas) {
    c.rect(22, 29, 2, 3, clawdOrange); c.rect(32, 29, 2, 3, clawdOrange)
    c.pattern(22, 29, ["X.", ".X", "X."], ["X": ink]); c.pattern(32, 29, [".X", "X.", ".X"], ["X": ink])
}

/// The bolt laid on a cocked crossbow, its point at the persona's muzzle (48, 32), red fletching at the back.
private func crossbowBolt(_ c: PixelCanvas) {
    c.rect(41, 32, 6, 1, C(0x8A6A3A)); c.px(47, 32, C(0xC8CCD4)); c.px(48, 32, C(0xE8ECF4))
    c.px(41, 31, C(0xC83A2A))
}

/// Giles's crossbow, an old wooden one from the library's cage: a long stock with a heavy butt, a brass trigger, long
/// straight dark limbs and an iron stirrup at the nose.
private func gilesCrossbow(_ c: PixelCanvas, cocked: Bool) {
    let wood = C(0x8A5A30), woodD = C(0x5E3C1E), woodL = C(0xB07A44), limb = C(0x3E2A1A)
    let brass = C(0xD8B040), iron = C(0x7A7E86), string = C(0xE0E0E8)
    c.rect(33, 32, 3, 4, woodD); c.rect(33, 32, 3, 1, wood)            // the butt
    c.rect(35, 33, 12, 2, wood); c.rect(35, 33, 12, 1, woodL); c.rect(35, 34, 12, 1, woodD)
    c.rect(38, 35, 1, 2, brass)                                          // the trigger
    slayerLine(c, 45.5, 33.5, 44, 27.5, limb, 0.6); slayerLine(c, 45.5, 33.5, 44, 39.5, limb, 0.6)
    c.px(47, 34, iron); c.px(48, 34, iron); c.px(48, 35, iron); c.px(47, 36, iron); c.px(48, 36, iron)   // the stirrup
    let back = cocked ? 41.0 : 43.5
    slayerLine(c, 44, 27.5, back, 33.5, string, 0.35); slayerLine(c, 44, 39.5, back, 33.5, string, 0.35)
    if cocked { crossbowBolt(c) }
}

/// Cordelia's crossbow, a modern pistol crossbow: a short black frame with a pistol grip under her hand, and shiny
/// silver recurved limbs with red tips curling forward, bright against her red top.
private func cordeliaCrossbow(_ c: PixelCanvas, cocked: Bool) {
    let frame = C(0x2A2228), frameD = C(0x16121A), frameL = C(0x4A4048), limb = C(0xD8DCE4), limbD = C(0x9098A8)
    let tip = C(0xE0303E), string = C(0xE0E0E8)
    c.rect(37, 33, 10, 2, frame); c.rect(37, 33, 10, 1, frameL); c.rect(37, 34, 10, 1, frameD)
    c.rect(39, 35, 2, 3, frameD); c.px(41, 35, frame)                  // the pistol grip and trigger guard
    c.pattern(42, 29, [
        "..T.",
        ".LL.",
        ".L..",
        ".DL.",
        "..DL",
        "....",
        "..DL",
        ".DL.",
        ".L..",
        ".LL.",
        "..T.",
    ], ["L": limb, "D": limbD, "T": tip])
    let back = cocked ? 40.0 : 42.5
    slayerLine(c, 44.5, 29.5, back, 33.5, string, 0.35); slayerLine(c, 44.5, 37.5, back, 33.5, string, 0.35)
    if cocked { crossbowBolt(c) }
}

/// Whether a crossbow is cocked this frame: it's empty for a moment after each shot.
private func crossbowCocked(_ p: Pose) -> Bool {
    guard let f = p.fire else { return true }
    return frac(f.t / p.firePeriod) >= 0.4
}

/// A bare-knuckle punch along `angle`: the sleeve thrown out and a fist on the end, a smear where it just was.
private func slayerPunch(_ c: PixelCanvas, angle: Double, trail: [Double], sleeve: Px, reach len: Double = 7) {
    slayerSmear(c, slayerHand, trail, from: 3, to: len + 1, C(0xF4E8D0))
    let e = slayerReach(slayerHand, angle, len)
    slayerLine(c, slayerHand.x - 2, slayerHand.y - 0.5, e.x, e.y, sleeve, 1.2)
    c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 3, 3, clawdOrange)
    c.px(Int(e.x.rounded()) + 1, Int(e.y.rounded()) - 1, clawdShade)   // the knuckles
}

// MARK: - Xander Harrows

/// Xander Harrows: Clawd with short messy dark hair and sideburns, a loud teal Hawaiian shirt with yellow and red
/// flowers, open over a white T-shirt, and jeans. He fights with a 2×4, a nail sticking out near the end. Signature:
/// the rocket launcher from "Innocence": he lets the 2×4 topple to the ground, draws the launcher up from behind his
/// back, swings it over onto his shoulder, squints down the sight, then puts it all back the way it came.
private func drawXanderHarrows(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0x2A8C9C), shirtD = C(0x1C6874), petal = C(0xF2C838), petal2 = C(0xE2503A), leaf = C(0x86D068)
    let tee = C(0xEEEAE0), hair = C(0x3A2618), hairL = C(0x5C3E28), hairD = C(0x24160E), shirtL = C(0x4AAAB8)
    func ease(_ k: Double) -> Double { let k = min(1, max(0, k)); return k * k * (3 - 2 * k) }
    // The launcher's journey, as three numbers: how far it has risen behind him (0 hidden, 1 its muzzle over his
    // head), how far it has swung over towards his shoulder (0 upright, 1 level on it), and how far the 2×4 has
    // toppled (0 in his hand, 1 lying on the ground).
    let rise: Double, swing: Double, topple: Double
    if let s = p.signature {
        rise = ease(s < 0.5 ? (s - 0.05) / 0.17 : (0.97 - s) / 0.07)
        swing = ease(s < 0.5 ? (s - 0.22) / 0.12 : (0.9 - s) / 0.1)
        topple = ease(s < 0.5 ? (s - 0.04) / 0.08 : (0.98 - s) / 0.06)
    } else {
        rise = 0; swing = 0; topple = 0
    }
    let shouldered = swing >= 1

    // Behind him, hidden by his legs, body and hair until it clears the top of his head: the launcher, rising
    // upright, then swinging forward and down. Its middle (the sight) stays over his head; it's only drawn in front
    // once it's level on his shoulder.
    if rise > 0 && !shouldered { drawLauncherBehind(c, rise: rise, swing: swing) }
    drawLegs(c, Look(leg: C(0x4E5E7E)), step: p.step)
    slayerBoots(c, step: p.step, C(0x6A4A30), height: 1)
    if topple > 0 { drawToppledPlank(c, topple) }
    let lift = Int((swing * 5).rounded())
    c.oy += p.breathe
    drawBody(c, Look(arm: shirt), armRight: lift)
    // The Hawaiian shirt, open at the neck over the white T-shirt, its flowers scattered over it.
    c.rect(18, 34, 20, 4, shirt); c.rect(37, 34, 1, 4, shirtD); c.rect(18, 37, 20, 1, shirtD)
    c.rect(18, 34, 4, 1, shirtL); c.rect(31, 34, 4, 1, shirtL)   // light along the shoulders
    c.rect(32, 35, 1, 2, shirtD); c.rect(15, 35, 3, 1, shirtD)   // a fold, and the cuff
    c.rect(26, 34, 4, 2, tee); c.px(27, 36, tee); c.px(28, 36, tee)
    c.px(25, 34, shirtD); c.px(30, 34, shirtD)
    for (x, y, col) in [(19, 35, petal), (20, 34, leaf), (22, 36, petal2), (23, 35, leaf), (33, 35, petal),
                        (34, 34, leaf), (35, 36, petal2), (31, 36, leaf), (20, 37, petal), (24, 37, petal)] {
        c.px(x, y, col)
    }
    c.px(15, 34, petal); c.px(39, 33 - lift, petal2)   // the sleeves too
    // Short messy dark hair, a tuft or two sticking up, and sideburns: the light in short runs over the top, the far
    // side in shade.
    c.pattern(17, 20, [
        "...H...H.....H........",
        "...HH.HHHlllHHH.H.....",
        "..HHHlllHHHHlllHHHH...",
        ".HHHlHHHHHHHHHHHHHdH..",
        ".HHHHHHHHHHHHHHHHHHdH.",
        ".HHHHHHHHHHHHHHHHHHHdH",
        ".HHH.HHHH..HHHH..HHHdH",
        ".HH.................dH",
        ".Hd.................dH",
    ], ["H": hair, "l": hairL, "d": hairD])

    if shouldered {
        // On his shoulder, his hand on the grip, squinting down the sight with one eye.
        drawRocketLauncher(c, x: 14, y: 26)
        if let s = p.signature, s > 0.4, s < 0.75 { c.rect(32, 29, 2, 3, clawdOrange); c.rect(32, 30, 2, 1, ink) }
        return
    }
    if topple > 0 { return }   // his hand's free: the 2×4 is on the ground
    if let a = p.melee {
        drawPlank(c, angle: a, trail: p.trail)
    } else {
        // The 2×4 hanging from his hand by his side; shorter when he sits, so it stays above the ground.
        let len = seatedPose ? 4 : 9
        c.rect(39, 34, 3, len, C(0xC8A070)); c.rect(41, 34, 1, len, C(0x8E6A40)); c.px(38, 34 + len - 3, C(0x9AA0A8))
    }
}

/// The launcher behind Xander's back: risen `rise` of the way up (upright, its bottom hidden behind his back leg),
/// then swung `swing` of the way over towards level, turning about the sight above his head.
private func drawLauncherBehind(_ c: PixelCanvas, rise: Double, swing: Double) {
    let olive = C(0x5E6E3A), oliveD = C(0x3E4A26), band = C(0xE0C040)
    let pivot = (x: 31.5, y: 27.0 + (1 - rise) * 13)   // where the sight is; 13 px lower, the muzzle hides in his hair
    let angle = -90 + swing * 90
    let ux = cos(angle * .pi / 180), uy = sin(angle * .pi / 180)
    // The tube, from the back end to the muzzle, 3 px thick like the shouldered one. Below his body it's cut off,
    // so it never peeks out between his legs.
    for i in 0...33 {
        let d = -17 + Double(i)
        let x = pivot.x + ux * d, y = pivot.y + uy * d
        guard y < 36 else { continue }
        let onBand = abs(d - 9) < 0.5
        c.rect(Int(x.rounded()) - 1, Int(y.rounded()) - 1, 3, 3, onBand ? band : oliveD)
    }
    for i in 0...33 {   // its lit side, towards the front-left light
        let d = -17 + Double(i)
        let x = pivot.x + ux * d, y = pivot.y + uy * d
        guard y < 36, abs(d - 9) >= 0.5 else { continue }
        c.px(Int(x.rounded()), Int(y.rounded()), olive)
        c.px(Int(x.rounded()) - (uy < -0.7 ? 1 : 0), Int(y.rounded()) - (uy < -0.7 ? 0 : 1), olive)
    }
    // The flared muzzle.
    let m = (x: pivot.x + ux * 16.5, y: pivot.y + uy * 16.5)
    slayerLine(c, m.x - uy * 2, m.y + ux * 2, m.x + uy * 2, m.y - ux * 2, oliveD, 0.8)
}

/// The 2×4 toppling from his hand to the ground at his side, `k` of the way over, turning about its bottom end.
private func drawToppledPlank(_ c: PixelCanvas, _ k: Double) {
    guard !seatedPose else { return }
    let foot = (x: 40.5, y: 42.5), angle = -90 + k * 90
    slayerBar(c, foot, angle, from: 0, to: 9, C(0x8E6A40), r: 1.2)
    slayerBar(c, foot, angle, from: 0, to: 8.5, C(0xC8A070), r: 0.8)
}

/// The 2×4 swung along `angle`: a long pale plank, its grain dark along one edge, a nail sticking out near the end.
private func drawPlank(_ c: PixelCanvas, angle: Double, trail: [Double]) {
    let h = slayerHand
    slayerSmear(c, h, trail, from: 3, to: 13, C(0xF4E8D0))
    slayerBar(c, h, angle, from: -2, to: 13, C(0x8E6A40), r: 1.5)
    slayerBar(c, h, angle, from: -2, to: 12.5, C(0xC8A070), r: 1.1)
    let n0 = slayerReach(slayerReach(h, angle, 10.5), angle - 90, 1.5)
    let n1 = slayerReach(slayerReach(h, angle, 10.5), angle - 90, 3.2)
    slayerLine(c, n0.x, n0.y, n1.x, n1.y, C(0x9AA0A8), 0.45)
    c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, clawdOrange)
}

/// The olive rocket launcher with its back end at (`x`, `y`): a long tube with a flared muzzle, a yellow band, the
/// sight on top and a grip underneath.
private func drawRocketLauncher(_ c: PixelCanvas, x: Int, y: Int) {
    let olive = C(0x5E6E3A), oliveD = C(0x3E4A26), oliveL = C(0x7E8E52), band = C(0xE0C040)
    c.rect(x, y, 32, 3, olive); c.rect(x, y, 32, 1, oliveL); c.rect(x, y + 2, 32, 1, oliveD)
    c.rect(x - 1, y - 1, 2, 5, oliveD)                                   // the back end
    c.rect(x + 31, y - 1, 3, 5, olive); c.rect(x + 33, y - 1, 1, 5, oliveD)   // the flared muzzle
    c.rect(x + 26, y, 1, 3, band)
    c.rect(x + 16, y - 2, 3, 2, oliveD); c.px(x + 17, y - 3, oliveD)     // the sight
    c.rect(x + 22, y + 3, 2, 2, oliveD)                                  // the grip
    c.rect(x + 24, y + 3, 3, 3, clawdOrange)                             // his hand on the grip
}

// MARK: - Rupert Gyles

/// Rupert Gyles: Clawd with short, neat, greying brown hair, round wire glasses, a brown tweed suit flecked with
/// oatmeal, a white shirt and a dark red tie. He shoots a wooden crossbow. Signature: he takes off his glasses and
/// polishes them with his handkerchief, squinting, then puts them back on.
private func drawRupertGyles(_ c: PixelCanvas, _ p: Pose) {
    let tweed = C(0x7A6648), tweedD = C(0x58482E), tweedL = C(0x9A8462), fleck = C(0xB09E78)
    let shirt = C(0xEEEAE0), tie = C(0x7A2A30), wire = C(0xD4D8E0)
    let hair = C(0x8A7660), hairL = C(0xB0A28E), hairD = C(0x665440)
    let polishK = p.signature.map { $0 > 0.1 && $0 < 0.88 ? ($0 - 0.1) / 0.78 : -1 } ?? -1

    drawLegs(c, Look(leg: C(0x5C5446)), step: p.step)
    slayerBoots(c, step: p.step, C(0x3A2A1E), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: tweed), armRight: polishK >= 0 ? 5 : 0)
    // The tweed jacket, its lapels open on the shirt and tie: light along the shoulders, the weave in short strokes,
    // a fold either side and a cuff.
    c.rect(18, 34, 20, 4, tweed); c.rect(37, 34, 1, 4, tweedD); c.rect(18, 37, 20, 1, tweedD)
    c.rect(18, 34, 5, 1, tweedL); c.rect(31, 34, 5, 1, tweedL)
    c.rect(26, 34, 4, 3, shirt); c.rect(27, 34, 2, 4, tie); c.px(27, 34, C(0x5A1A20))
    c.px(25, 34, tweedL); c.px(25, 35, tweedL); c.px(30, 34, tweedD); c.px(30, 35, tweedD)
    for (x, y) in [(19, 35), (21, 36), (32, 35), (34, 36)] { c.rect(x, y, 2, 1, fleck) }
    c.rect(23, 35, 1, 2, tweedD); c.rect(31, 36, 1, 1, tweedD)
    c.rect(15, 34, 2, 1, fleck); c.rect(15, 35, 3, 1, tweedD)   // the sleeve, its cuff
    c.rect(39, 34 - (polishK >= 0 ? 5 : 0), 2, 1, fleck)
    // Short neat hair, parted on the left and combed across in a soft wave, an uneven fringe, greying at the sides.
    c.pattern(17, 21, [
        "....HHHH.HHHHHH.......",
        "...HHdHlllHHHHHHHH....",
        "..HHdHHHHHHlllHHHHH...",
        ".HHHdHHHHHHHHHHHdHHH..",
        ".HHHHHHHHHHHHHHHHdHHH.",
        ".HHHHHH.H....H..HHHHH.",
        ".Hgg..............gHH.",
        ".gg................gg.",
    ], ["H": hair, "l": hairL, "d": hairD, "g": hairL])

    if polishK < 0 {
        // The round wire glasses.
        let ring = [".GG.", "G..G", "G..G", "G..G", ".GG."]
        c.pattern(21, 28, ring, ["G": wire]); c.pattern(31, 28, ring, ["G": wire])
        c.rect(25, 29, 6, 1, wire); c.px(19, 29, wire); c.px(20, 29, wire); c.px(35, 29, wire)
        let cocked = crossbowCocked(p)
        c.oy += p.gunY
        gilesCrossbow(c, cocked: cocked)
        c.rect(38, 33, 3, 3, tweed)
        return
    }
    // Without them: squinting, the glasses in his raised hand, the handkerchief going round and round a lens.
    c.rect(22, 29, 2, 3, clawdOrange); c.rect(32, 29, 2, 3, clawdOrange)
    c.rect(22, 30, 2, 1, ink); c.rect(32, 30, 2, 1, ink)
    let glass = C(0x9CC0D8)
    c.pattern(41, 25, [
        ".GG..GG.",
        "GwwGGwwG",
        "GwwG.GwG",
        ".GG..GG.",
    ], ["G": wire, "w": glass])
    // The handkerchief: a big white square bunched over one lens, a blue stripe along its hem, its loose corner
    // flapping underneath as he rubs.
    let a = p.t * 9
    let hx = 44 + Int((cos(a) * 1.4).rounded()), hy = 24 + Int((sin(a) * 1.2).rounded())
    let hanky = C(0xF6F6F2), fold = C(0xC8CCD4), stripe = C(0x5A86C8)
    c.pattern(hx, hy, [
        "WWWW.",
        "WWWWF",
        "WWFFF",
        "SSSSF",
    ], ["W": hanky, "F": fold, "S": stripe])
    let flap = Int((sin(a * 0.5) * 1.5).rounded())
    c.px(hx + 1 + flap, hy + 4, hanky); c.px(hx + 1 + flap, hy + 5, stripe)
}

// MARK: - Cordelia Chaise

/// Cordelia Chaise: Clawd with long, full, glossy brown hair, the red Sunnydale cheerleader top with a black chevron
/// and white trim, a pleated red-and-black skirt and white sneakers. She shoots a crossbow. Signature: a vision hits:
/// she clutches her head with both hands, eyes squeezed shut, and a white flash bursts round her.
private func drawCordeliaChaise(_ c: PixelCanvas, _ p: Pose) {
    let top = C(0xC8202E), topD = C(0x961420), black = C(0x1C161A), trim = C(0xF4F0EA)
    let hair = C(0x4C2C1A), hairL = C(0x74462A), hairD = C(0x301A10)
    let visionK = p.signature.map { $0 > 0.1 && $0 < 0.85 ? ($0 - 0.1) / 0.75 : -1 } ?? -1

    drawLegs(c, Look(leg: clawdOrange), step: p.step)
    slayerBoots(c, step: p.step, C(0xF0F0F0), height: 2)
    // The pleated skirt, red and black, short: all four legs still show below it.
    if seatedPose {
        c.rect(17, 38, 22, 1, top)
    } else {
        for x in 17...38 { c.rect(x, 38, 1, 2, (x / 2) % 2 == 0 ? top : black) }
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: top), armLeft: visionK >= 0 ? 7 : 0, armRight: visionK >= 0 ? 7 : 0)
    // The cheerleader top: red, a black chevron with a white edge across the front.
    c.rect(18, 34, 20, 4, top); c.rect(37, 34, 1, 4, topD); c.rect(18, 37, 20, 1, topD)
    c.pattern(19, 34, [
        "WBB..............BBW",
        ".WBBB..........BBBW.",
        "...WBBB......BBBW...",
        ".....WBBBBBBBBW.....",
    ], ["B": black, "W": trim])
    // Long, full brown hair, swept off her forehead in a big glossy wave, falling well past her shoulders in loose
    // waves, the ends flicking out.
    c.pattern(15, 19, [
        ".......HHHHHHHHHHH........",
        ".....HHHHHlHHHHHHHHH......",
        "...HHHHHlHHHHHdHHHlHHH....",
        "..HHHHHlHHHHHdHHHHHlHHHH..",
        ".HHHHHlHHHHHdHHHHHHHlHHHH.",
        ".HHHHHHHHHHdHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHH................HHH",
        "HHlH...................HdH",
        ".HdHH..................HHl",
        "HHlH...................dHH",
        "lHdH...................HlH.",
        "HHHl...................HdHH",
        ".HdHd..................dHH",
        "dHHd...................dHl",
        ".HdH...................HdH",
        "dHHH...................HHdd",
        "dd.d...................d..d",
    ], ["H": hair, "l": hairL, "d": hairD])

    guard visionK >= 0 else {
        let cocked = crossbowCocked(p)
        c.oy += p.gunY
        cordeliaCrossbow(c, cocked: cocked)
        c.rect(38, 33, 3, 3, top)
        return
    }
    // Both hands to her temples, eyes screwed shut.
    squeezedEyes(c)
    c.rect(15, 26, 3, 3, clawdOrange); c.rect(38, 26, 3, 3, clawdOrange)
    // The flash: a burst of solid rays round her head, long and bright at first, then shrinking and flickering out,
    // with sparks winking on and off round it. All solid, so nothing half-see-through sits on her outline.
    let flash = visionK < 0.2 ? 1 : max(0, 1 - (visionK - 0.2) / 0.8) * (0.6 + 0.4 * sin(p.t * 30))
    guard flash > 0.1 else { return }
    let centre = (x: 28.0, y: 26.0), pale = C(0xFFF4C8)
    for k in 0..<9 {
        let ang = -195 + Double(k) * 26 + 6 * sin(p.t * 3)   // a fan over her head and out to the sides
        let r0 = 14.5, r1 = 15 + 4 * flash + Double(k % 2) * 2
        let p0 = slayerReach(centre, ang, r0), p1 = slayerReach(centre, ang, r1)
        slayerLine(c, p0.x, p0.y, p1.x, p1.y, k % 2 == 0 ? white : pale, 0.6)
    }
    let tick = Int(p.t * 10)
    for k in 0..<4 where (tick + k) % 3 != 0 {
        let s = slayerReach(centre, -150 + Double(k) * 40, 12.5)
        let x = Int(s.x.rounded()), y = Int(s.y.rounded())
        c.px(x, y, white); c.px(x - 1, y, pale); c.px(x + 1, y, pale); c.px(x, y - 1, pale); c.px(x, y + 1, pale)
    }
}

// MARK: - Ozz

/// Ozz: Clawd with short spiky hair dyed electric blue, a charcoal band T-shirt with a yellow-and-red logo, brown cords,
/// and a guitar slung on his back, its neck up past his head. He fights with a stake, as he did on patrol in the show.
/// Signature: he wolfs out for a second: grey-tan fur, ears, a long snout with fangs and yellow eyes, werewolf claws
/// in place of the stake, then he's back. On a full-moon night (`slayerFullMoon`) he's the wolf all night, and his
/// signature is a howl instead.
private func drawOzz(_ c: PixelCanvas, _ p: Pose) {
    let tee = C(0x34343E), teeD = C(0x24242C), teeL = C(0x4A4A56), logo = C(0xF0C838), logo2 = C(0xD8402E)
    let hair = C(0x3C78D8), hairL = C(0x74A8F4), hairD = C(0x2850A8)
    let fur = C(0x9C8C72), furD = C(0x6E604C), furL = C(0xC8B89A)
    let moon = slayerFullMoon
    // 0 human, 1 halfway (ears and fur), 2 full wolf.
    let wolf: Int = moon ? 2 : p.signature.map { s in
        s < 0.15 || s > 0.78 ? 0 : s < 0.24 || s > 0.69 ? 1 : 2
    } ?? 0

    // The guitar on his back: its body behind his left side, the neck up past his head.
    let wood = C(0x9A4A1E), woodL = C(0xD08A3A), woodD = C(0x6A2E12), neck = C(0x4A2E1A)
    c.oy += p.breathe
    slayerLine(c, 15, 30, 11.5, 15.5, neck, 0.7)
    c.rect(10, 13, 3, 3, C(0x2A1A10)); c.px(9, 14, C(0xC8CCD4)); c.px(13, 13, C(0xC8CCD4))
    c.pattern(10, 28, [
        "..WWW..",
        ".WLLLW.",
        ".WLLLW.",
        "..WLW..",
        ".WLLLW.",
        "WLLoLLW",
        "WLLLLLW",
        "WLLLLLD",
        ".WWWWD.",
    ], ["W": wood, "L": woodL, "o": C(0x2A1A10), "D": woodD])
    c.oy -= p.breathe

    drawLegs(c, Look(leg: wolf == 2 ? fur : C(0x6A5638)), step: p.step)
    slayerBoots(c, step: p.step, wolf == 2 ? furD : C(0x2A2420), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: wolf > 0 ? fur : tee))
    // The band T-shirt, with the strap of the guitar across it.
    c.rect(18, 34, 20, 4, tee); c.rect(37, 34, 1, 4, teeD); c.rect(18, 37, 20, 1, teeD)
    c.rect(31, 34, 5, 1, teeL); c.rect(33, 35, 1, 2, teeD); c.rect(15, 35, 3, 1, teeD)   // lit shoulder, a fold, the cuff
    c.pattern(25, 34, [".YYYY.", "YRRYRY", ".YYYY."], ["Y": logo, "R": logo2])
    for i in 0..<6 { c.px(19 + i, 33 + i / 2, C(0x5A3A22)) }

    if wolf == 0 {
        // Short spiky hair, dyed blue: each spike lit in a short run down from its tip, the far side in shade.
        c.pattern(16, 17, [
            "....H....H....H...H.....",
            "....lH..lHH..lH..lH..H..",
            "...HlHHHlHHHHlHHHlHHHH..",
            "..HHllHHHllHHHllHHHHdH..",
            "..HHHHHHHHHHHHHHHHHHHdH.",
            ".HHHHHHHHHHHHHHHHHHHHdH.",
            ".HHHHHHHHHHHHHHHHHHHHdH.",
            "..HHHHHHHHHHHHHHHHHHdH..",
            "..HHHHHHHHHHHHHHHHHHdH..",
            "..HdH.HHdH..HdH..HdHHH..",
        ], ["H": hair, "l": hairL, "d": hairD])
    } else {
        // Wolfing out: shaggy fur over his head, tall narrow ears laid back (a wolf's, not a cat's: dark inside,
        // leaning back), ragged tufts between them and at his cheeks, yellow eyes. Halfway, the ears are only half up.
        let ears = [
            ".FF.............FF......",
            ".FFF............FFF.....",
            "..FdFF...........FdFF...",
            "..FddFF.F..F.F...FddFF..",
        ]
        c.pattern(16, wolf == 2 ? 16 : 18, wolf == 2 ? ears : Array(ears.dropFirst(2)), ["F": fur, "d": furD])
        c.pattern(16, 20, [
            "..FFFFFFFFFFFFFFFFFFFF..",
            ".FFFFFFFFLFFFFFFFLFFFFF.",
            ".FFFFFFFFFFFFFFFFFFFFFF.",
            "FFdFFFFFFFFdFFFFFFFFdFFF",
            ".FFFFFFFFFFFFFFFFFFFFFF.",
            ".FFFFFFFFFFFFFFFFFFFFFF.",
            "..FFdF.F.F.....F.F.FFF..",   // a ragged fringe of fur over his brow
        ], ["F": fur, "d": furD, "L": furL])
        c.rect(18, 26, 3, 8, fur); c.rect(35, 26, 3, 8, fur)
        for y in 26...33 { c.px(17, y, y % 2 == 0 ? fur : furD) }
        for y in [27, 29, 31] { c.px(16, y + 1, fur); c.px(38, y, fur) }   // the shaggy cheeks
        c.px(21, 27, furD); c.px(21, 31, furD); c.px(34, 28, furD); c.px(36, 30, furD)
        c.rect(22, 29, 2, 3, ink); c.rect(22, 29, 2, 2, C(0xF2D040)); c.px(23, 30, ink)
        c.rect(32, 29, 2, 3, ink); c.rect(32, 29, 2, 2, C(0xF2D040)); c.px(32, 30, ink)
        c.rect(21, 28, 3, 1, furD); c.rect(31, 28, 3, 1, furD)
        let mouth = C(0x4A2A22)
        if wolf == 1 {
            // Halfway: a short muzzle already pushing out past his face, a fang showing.
            c.pattern(27, 31, [
                "..LLLLLLLLNN",
                "LLLLLLLLLLLN",
                "MMMMMMMMMMM.",
                ".wLLLLLLw...",
            ], ["L": furL, "N": ink, "M": mouth, "w": white])
        } else {
            // The full snout, long and pushed well out past his face, a ridge up between the eyes, the black nose
            // on its tip, fangs over the jaw.
            c.pattern(26, 30, [
                ".LLLL................",
                "LLLLLLLLLLLLLLLLLLNN.",
                "LLLLLLLLLLLLLLLLLLNNN",
                "MwMMMMMwMMMMMMMMMwM..",
                ".LLLLLLLLLLLLLLLLL...",
                "..LLLLLLLLLLLLL......",
            ], ["L": furL, "N": ink, "M": mouth, "w": white])
            c.rect(18, 33, 8, 1, fur)   // the fur's ruff at his collar
            c.px(19, 34, furD); c.px(23, 34, fur); c.px(33, 35, fur)
            if moon, let s = p.signature, s > 0.1, s < 0.9 {
                // Full moon: his signature is a howl, solid arcs rolling off the end of the snout, thinning out as
                // they spread.
                let k = frac(p.t * 1.2), ring = C(0xDCE6FF)
                for i in 0..<2 {
                    let f = frac(k + Double(i) / 2), r = 4 + f * 10
                    let gap = f < 0.55 ? 1 : 2   // an unbroken ")" close in, dotted further out
                    var n = 0
                    for a in stride(from: -0.9, through: 0.9, by: 1 / r) {
                        defer { n += 1 }
                        guard n % gap == 0 else { continue }
                        c.px(Int((47 + cos(a) * r).rounded()), Int((31 + sin(a) * r).rounded()), ring)
                    }
                }
            }
        }
    }

    // As himself he fights with a stake, as he did on patrol; with the wolf out, with claws.
    if let a = p.melee {
        if wolf > 0 { slayerClaws(c, angle: a, trail: p.trail, sleeve: fur, nail: C(0xE8E0C8)) }
        else { slayerStake(c, angle: a, trail: p.trail) }
    } else if wolf == 0 {
        if seatedPose {   // shorter when he sits, so its point stays above the ground
            c.rect(39, 36, 2, 2, slayerStakeWood); c.rect(40, 36, 1, 2, slayerStakeDark); c.px(39, 38, slayerStakePoint)
        } else {
            slayerStakeHeld(c)
        }
    }
}

// MARK: - Anya Jinkins

/// Anya Jinkins: Clawd with a peachy-blonde bob and a straight fringe, a pink cardigan with the green Magic Box apron
/// over it, dark tights and little shoes. She fights with a sword, as in "Chosen". Signature: she counts the takings,
/// delighted: notes flicking through her raised hand, eyes crinkled up, dollar signs floating up over her head.
private func drawAnyaJinkins(_ c: PixelCanvas, _ p: Pose) {
    let cardi = C(0xE88EAE), cardiD = C(0xBE6A8A), apron = C(0x3E7A4E), apronD = C(0x2A5A38), apronL = C(0x5A9A68)
    let hair = C(0xF2CC70), hairL = C(0xFFE8A8), hairD = C(0xC89A40)
    let countK = p.signature.map { $0 > 0.08 && $0 < 0.92 ? ($0 - 0.08) / 0.84 : -1 } ?? -1

    drawLegs(c, Look(leg: C(0x4A3A48)), step: p.step)
    slayerBoots(c, step: p.step, C(0x8A2E3E), height: 1)
    // The apron hangs down over the tops of her legs; the four feet still show below it.
    if seatedPose {
        c.rect(22, 38, 13, 1, apron)
    } else {
        c.rect(22, 38, 13, 3, apron); c.rect(34, 38, 1, 3, apronD); c.rect(22, 40, 13, 1, apronD)
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: cardi), armRight: countK >= 0 ? 2 : 0)
    // The cardigan, and the apron's bib over it, with its pocket.
    c.rect(18, 34, 20, 4, cardi); c.rect(37, 34, 1, 4, cardiD); c.rect(18, 37, 20, 1, cardiD)
    c.rect(18, 34, 4, 1, C(0xF8B4CC)); c.rect(35, 34, 2, 1, C(0xF8B4CC)); c.rect(15, 35, 3, 1, cardiD)   // shoulders, cuff
    c.rect(22, 34, 13, 4, apron); c.rect(34, 34, 1, 4, apronD); c.rect(22, 34, 13, 1, apronL)
    c.rect(25, 36, 7, 2, apronD); c.rect(25, 36, 7, 1, apronL)
    c.px(22, 33, apron); c.px(34, 33, apron)   // the neck strap
    // The bob, short and bright yellow-blonde: a straight fringe, the sides stopping at her jaw and flaring out as
    // they curl under, well clear of her shoulders (Tara's hair is darker, honey-brown, and long).
    c.pattern(16, 20, [
        "......HHHHHHHHHHHH......",
        "....HHHHlllHHHHHHHHH....",
        "...HHHllHHHHHHlllHHHH...",
        "..HHlHHHHHHHHHHHHHHHdH..",
        "..HHHHHHHHHHHHHHHHHHdH..",
        ".HHHHHHHHHHHHHHHHHHHHdH.",
        ".HHHHHHHHHHHHHHHHHHHHdH.",
        ".HHHdHdHHdHHHdHHdHHdHHH.",
        ".HlH................HdH.",
        ".HlH................HdH.",
        ".HHl................lHH.",
        "HHHHH..............HHHHH",
        ".ddHd..............dHdd.",
    ], ["H": hair, "l": hairL, "d": hairD])

    if countK >= 0 {
        // Eyes crinkled up with joy.
        c.rect(22, 29, 2, 3, clawdOrange); c.rect(32, 29, 2, 3, clawdOrange)
        c.pattern(21, 29, [".XX.", "X..X"], ["X": ink]); c.pattern(31, 29, [".XX.", "X..X"], ["X": ink])
        // The wad of notes in her hand, and one flicking over the top.
        let note = C(0x8AC47A), noteD = C(0x4E8A44)
        c.rect(40, 29, 5, 3, note); c.rect(40, 31, 5, 1, noteD); c.px(42, 30, noteD)
        let f = frac(p.t * 3)
        let ang = -10 - f * 160
        let e = slayerReach((41.5, 30.5), ang, 4)
        slayerLine(c, 41.5, 30.5, e.x, e.y, note, 0.7)
        // Dollar signs floating up.
        for k in 0..<2 {
            let u = frac(countK * 2.5 + Double(k) * 0.5)
            let y = 18 - Int(u * 8), x = 38 + k * 6
            c.pattern(x, y, [".X.", "XXX", "X..", "XXX", "..X", "XXX", ".X."], ["X": C(0xE8B830)])
        }
        return
    }
    if let a = p.melee {
        drawAnyaSword(c, angle: a, trail: p.trail)
    } else {
        // The sword, point down by her side; shorter when she sits, so it stays above the ground.
        let blade = seatedPose ? 2 : 6
        c.rect(39, 34, 2, 2, C(0x5A3A22)); c.rect(38, 36, 4, 1, C(0xC09A40))
        c.rect(39, 37, 2, blade, C(0xD8DCE4)); c.rect(40, 37, 1, blade, C(0x9098A8))
    }
}

/// Anya's sword along `angle`: a short gleaming blade with a brass crossguard.
private func drawAnyaSword(_ c: PixelCanvas, angle: Double, trail: [Double]) {
    let h = slayerHand
    slayerSmear(c, h, trail, from: 4, to: 15, C(0xE8F0FF))
    slayerBar(c, h, angle, from: 3, to: 15, C(0x9098A8), r: 1.1)
    slayerBar(c, h, angle, from: 3, to: 14.5, C(0xD8DCE4), r: 0.7)
    let g0 = slayerReach(slayerReach(h, angle, 2.5), angle - 90, 2.2)
    let g1 = slayerReach(slayerReach(h, angle, 2.5), angle + 90, 2.2)
    slayerLine(c, g0.x, g0.y, g1.x, g1.y, C(0xC09A40), 0.6)
    c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, clawdOrange)
}

// MARK: - Tara Maclaw

/// Tara Maclaw: Clawd with long wavy honey-fair hair and a side fringe, a dusky rose cardigan over a cream top, and a
/// long dark-blue floral skirt down to her ankles. Her magic is a gentle touch, white and lavender. Signature: she
/// cups her hands, and a little ball of lavender light rises out of them and floats up.
private func drawTaraMaclaw(_ c: PixelCanvas, _ p: Pose) {
    let cardi = C(0x9A4A5E), cardiD = C(0x743446), cardiL = C(0xBA6A7E), cream = C(0xF0E4CC)
    let skirt = C(0x34467A), skirtD = C(0x24325A), bloom = C(0xE89AB8), bloom2 = C(0xF0D070)
    let hair = C(0xB07A44), hairL = C(0xD09A5E), hairD = C(0x86582E)
    let cupK = p.signature.map { $0 > 0.08 && $0 < 0.92 ? ($0 - 0.08) / 0.84 : -1 } ?? -1

    drawLegs(c, Look(leg: C(0x6A5444)), step: p.step)
    slayerBoots(c, step: p.step, C(0x4A3426), height: 1)
    // The long skirt, down to the ankles, flowers dotted over it: the four feet show under its hem.
    if seatedPose {
        c.rect(16, 38, 24, 2, skirt); c.px(20, 38, bloom); c.px(29, 39, bloom2); c.px(36, 38, bloom)
    } else {
        c.rect(17, 38, 22, 4, skirt); c.rect(16, 40, 24, 2, skirt); c.rect(16, 41, 24, 1, skirtD); c.rect(38, 38, 1, 3, skirtD)
        for x in [22, 27, 34] { c.rect(x, 39, 1, 2, skirtD) }   // soft folds down to the hem
        for (x, y, col) in [(19, 39, bloom), (24, 38, bloom2), (28, 40, bloom), (33, 39, bloom2), (36, 41, bloom),
                            (21, 41, bloom2), (31, 38, bloom)] {
            c.px(x, y, col)
        }
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: cardi), armLeft: 0, armRight: cupK >= 0 ? 1 : p.armRaise)
    // The cardigan open over a cream top.
    c.rect(18, 34, 20, 4, cardi); c.rect(37, 34, 1, 4, cardiD); c.rect(18, 37, 20, 1, cardiD)
    c.rect(25, 34, 6, 4, cream); c.rect(24, 34, 1, 4, cardiL); c.rect(31, 34, 1, 4, cardiD)
    c.rect(20, 34, 3, 1, cardiL); c.rect(33, 34, 2, 1, cardiL); c.rect(22, 35, 1, 2, cardiD)   // lit shoulders, a fold
    c.rect(15, 35, 3, 1, cardiD)   // the cuff
    // Long wavy hair, a side parting and a fringe swept across.
    c.pattern(16, 20, [
        ".....HHHHHHHHHHHHH......",
        "....HHHHHHHlllHHHHHH....",
        "...HHllHHHHHHHHHlllHH...",
        "..HHlHHHHHHHHHHHHHHHdH..",
        "..HHHHHHHHHHHHHHHHHHHdH.",
        ".HHHHHHHHHHHHHHHHHHHHdH.",
        ".HHHHHHHHHHHHH.....HHdH.",
        ".HlHHHHH...........HHdH.",
        "HHlH................HdHH",
        ".HlH................HdH.",
        "HHHl.................HdH",
        ".HHH................lHH.",
        "HHHH.................HHH",
        ".HHd................dHH.",
        "HHHd.................dHH",
        ".dHH................HHd.",
        "HHHd................dHHH",
        ".dHd................dHd.",
        "..d..................d..",
    ], ["H": hair, "l": hairL, "d": hairD])

    guard cupK >= 0 else { return }
    // Both hands cupped in front of her.
    c.rect(38, 32, 3, 3, clawdOrange); c.rect(41, 33, 3, 2, clawdOrange); c.px(43, 32, clawdOrange)
    // The little light, rising from her hands and fading as it goes.
    let rise = min(1, cupK / 0.85)
    let fade = cupK < 0.85 ? 1 : 1 - (cupK - 0.85) / 0.15
    let lx = 41.5 + sin(p.t * 3) * 1.5, ly = 30 - rise * 14
    let lav = C(0xB49CE8), lavL = C(0xD8CCF8), core = C(0xF6F0FF)
    let cx = Int(lx.rounded()), cy = Int(ly.rounded())
    // A soft halo round it (faint, so it stays a glow), then the ball itself, solid so it reads at desktop size:
    // a white heart in a lavender shell, shrinking as it fades, and four motes circling it.
    for y in -4...4 { for x in -4...4 where abs(x) + abs(y) <= 4 && abs(x) + abs(y) > 2 {
        c.px(cx + x, cy + y, lav.alpha(0.2 * fade))
    } }
    let size = fade > 0.6 ? 2 : fade > 0.25 ? 1 : 0
    for y in -size...size { for x in -size...size where abs(x) + abs(y) <= size {
        c.px(cx + x, cy + y, abs(x) + abs(y) == size && size > 0 ? lavL : core)
    } }
    if size == 2 { c.px(cx - 1, cy - 1, white) }
    guard fade > 0.4 else { return }
    for k in 0..<4 {
        let g = Double(k) * .pi / 2 + p.t * 2.5
        c.px(Int((lx + cos(g) * 4.5).rounded()), Int((ly + sin(g) * 3.5).rounded()), lav)
    }
}

// MARK: - Spyke

/// Spyke: Clawd with slicked-back platinum hair and a dark brow, a long black leather duster hanging to his shins over
/// a red shirt and a black T-shirt, black jeans and Doc Martens. He fights with his fists. Signature: he lunges and
/// throws a punch, the chip in his head zaps him with a crackle of blue sparks, and he clutches his head.
private func drawSpyke(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x231E22), coatD = C(0x110E12), coatL = C(0x463C42), fold = C(0x3A3238), red = C(0xA8202C)
    let tee = C(0x141216), hair = C(0xE6DFC0), hairL = C(0xFFFCEC), hairD = C(0xA89E7A)
    let s = p.signature ?? -1
    let lunge = s >= 0 && s < 0.3, zap = s >= 0.3 && s < 0.5, clutch = s >= 0.5 && s < 0.92
    if lunge { c.ox += Int((sin(min(1, s / 0.3) * .pi) * 2).rounded()) }
    if zap { c.ox += Int(p.t * 40) % 2 }

    // The duster's long back flaring out behind his legs in one sweep, longer at the back, its folds picked out in
    // long lighter lines; it swings a pixel as he walks.
    if !seatedPose {
        c.pattern(p.step == 1 ? 11 : 12, 35, [
            ".....CC",
            "....CFC",
            "...CFCC",
            "...FCCF",
            "..FCCFC",
            "..CCFCC",
            ".CCFCCC",
            ".DDDDDD",
        ], ["C": coat, "F": fold, "D": coatD])
    } else {
        c.rect(15, 36, 4, 4, coat); c.rect(16, 37, 1, 3, fold)
    }
    drawLegs(c, Look(leg: C(0x24222A)), step: p.step)
    slayerBoots(c, step: p.step, C(0x0E0C0E), height: 3)
    // The front of the duster, hanging open to his shins over the tops of his legs: the back panel sloping down to
    // join the tail, the front edge with its lighter facing. The four legs still show below it.
    if !seatedPose {
        c.pattern(16, 38, [
            "CCFCCC",
            "CCFCC.",
            "DDDD..",
        ], ["C": coat, "F": fold, "D": coatD])
        c.pattern(33, 38, [
            "LCCFCD",
            "LCCFCD",
            "LDDDD.",
        ], ["C": coat, "F": fold, "D": coatD, "L": coatL])
    }
    c.oy += p.breathe
    let up = clutch ? 7 : 0
    drawBody(c, Look(arm: coat), armLeft: up, armRight: up)
    // The duster's body and its wide lapels, the red shirt and black T-shirt between them.
    c.rect(18, 34, 20, 4, coat); c.rect(37, 34, 1, 4, coatD); c.rect(18, 37, 20, 1, coatD)
    c.rect(25, 34, 6, 4, red); c.rect(27, 34, 2, 4, tee)
    c.px(24, 34, coatL); c.px(24, 35, coatL); c.px(23, 34, coatL); c.px(31, 34, coatL); c.px(32, 34, coatL)
    // Slicked-back platinum hair, short at the sides: combed straight back in dark grooves from a little quiff at
    // the front, a bright shine along the top.
    c.pattern(17, 21, [
        ".....HHHHHHHHHHlH.....",
        "..HHHHlllllHHHHHlH....",
        ".HddddHHHHHHdddHHHH...",
        ".HHHHHHlllHHHHHHHlHHH.",
        ".dddHHHHHdddddHHHHHHH.",
        ".dHHd...........HHHHd.",
        ".d...............dHd..",
    ], ["H": hair, "l": hairL, "d": hairD])
    // The dark brow, a little cocky.
    c.rect(21, 28, 3, 1, C(0x5A4A3A)); c.rect(31, 27, 3, 1, C(0x5A4A3A))

    if s >= 0 && s < 0.92 {
        if lunge {
            slayerPunch(c, angle: -5, trail: s > 0.12 ? [10, 25] : [], sleeve: coat, reach: 3 + min(1, s / 0.15) * 5)
        } else if zap {
            // The chip goes off: blue sparks crackling round his head, eyes wide.
            c.rect(22, 29, 2, 3, white); c.px(23, 30, ink); c.rect(32, 29, 2, 3, white); c.px(32, 30, ink)
            let i = Int(p.t * 24)
            for k in 0..<4 {
                let ang = -160 + Double(k) * 45 + noise(i + k) * 20
                var pt = slayerReach((28, 24), ang, 8)
                for j in 0..<3 {
                    let nx = slayerReach(pt, ang + (noise(i * 3 + k * 5 + j) - 0.5) * 80, 3)
                    c.glowLine(pt.x, pt.y, nx.x, nx.y, core: C(0xE8F4FF), glow: C(0x5AA8FF), coreR: 0.4, glowR: 1.4,
                               strength: 0.6)
                    pt = nx
                }
            }
            c.rect(38, 33, 3, 3, clawdOrange)
        } else {
            // Clutching his head, eyes screwed shut, a last spark or two.
            squeezedEyes(c)
            c.rect(15, 26, 3, 3, clawdOrange); c.rect(38, 26, 3, 3, clawdOrange)
            if Int(p.t * 6) % 3 == 0 { c.px(27, 17, C(0x8AC8FF)); c.px(30, 15, C(0xE8F4FF)) }
        }
        return
    }
    if let a = p.melee {
        slayerPunch(c, angle: a, trail: p.trail, sleeve: coat)
    } else {
        c.rect(38, 33, 3, 3, coat); c.rect(41, 34, 2, 2, clawdOrange)   // a fist at his side
    }
}
