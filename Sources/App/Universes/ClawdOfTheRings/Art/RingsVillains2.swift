import Foundation

// Villains: the monsters and the orcs. The orcs and Smeagull are Clawd underneath, the blocky body in their own skin
// (grey-green, dark brown, pale), with the helmets, armour and rags drawn over it. The Ballrog and Shellob aren't Clawd
// at all: the Ballrog is half again a Man's height (the size is drawn on the canvas, so its `headTop`, its whip hand and
// its `bulk` say so), Shellob half again as wide, low on eight legs.

let ringsVillains2: [RingsVillain: Persona] = [
    .balrog: Persona(name: "The Ballrog", weapon: .saber, armoured: true, canSit: false, pivot: balrogHand, bulk: 8, headTop: 11,
                     signature: 3.4, draw: drawBalrog),
    .gollum: Persona(name: "Smeagull", weapon: .saber, pivot: gollumShoulder, headTop: 27, signature: 3.6, callout: "My precious!",
                     draw: drawGollum),
    .uruk: Persona(name: "Uruk-Hi", weapon: .saber, headTop: 19, signature: 3.4, callout: "Meat's back on the menu!",
                   draw: drawUruk),
    .orc: Persona(name: "Gorbage", weapon: .saber, bulk: 2, headTop: 23, signature: 3.0, callout: "Collecting garbage!",
                  draw: drawOrc),
    .shelob: Persona(name: "Shellob", weapon: .saber, canSit: false, pivot: shelobFangs, bulk: 8, headTop: 22, signature: 3.6,
                     climb: shelobClimb, draw: drawShelob),
    .lurtz: Persona(name: "Lintz", weapon: .blaster, shot: .arrow, muzzle: (46, 34), handGun: false, headTop: 20,
                    signature: 3.2, callout: "Find the Halflings! Lint the others!", draw: drawLurtz),
]

// MARK: - The Ballrog

/// Where the Ballrog's whip hand is: out in front of its chest, half again as high as a Man's.
private let balrogHand: (x: Double, y: Double) = (45.5, 30.5)

/// The Ballrog, a demon of the ancient world, half again a Man's height: dark rock-hide split by glowing cracks, two
/// black horns, fire licking up from its head and shoulders, smoky wings folded behind it, eyes and mouth like a
/// furnace door. In its fist a fire whip, coiled on the floor in front of it at rest; swung, it follows the fist round
/// with a lag, the tip coming last, and sags when it slows; idle, it cracks it out in front of it. Signature: "You
/// cannot pass": it rears up to its full height, its smoky wings spreading wide either side of it, the flames leaping
/// up off its head and shoulders and the cracks in its hide blazing (…0.22); it draws the whip up overhead and cracks
/// it out in front of it in a burst of sparks (…0.52), holds it there, smouldering, then sinks back and folds its wings.
private func drawBalrog(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature.flatMap { $0 > 0.02 && $0 < 0.98 ? $0 : nil }
    let rise = sig.map(balrogRise) ?? 0
    let rock = C(0x3A1A10), rockDark = C(0x2A120A), rockLight = C(0x52281A), horn = C(0x1E0E0A)
    let crack = C(0xE8501E), hot = C(0xFFB03A)
    var glow: Double = 0.75 + 0.25 * sin(p.lt * 2.3)
    if rise > 0 { glow = min(1, glow + 0.35 * rise) }                         // blazing as it rears
    // Two massive legs, cloven into claws.
    for (i, lx) in [19, 30].enumerated() {
        let up = p.step >= 0 && i == p.step ? 1 : 0
        let col = i == 0 ? rockDark : rock
        c.rect(lx, 34, 7, 9 - up, col)
        c.rect(lx - 1, 42 - up, 9, 2, rockDark)
        for k in 0..<3 { c.px(lx + 1 + k * 3, 43 - up, horn) }
        c.px(lx + 3, 37, crack.alpha(glow)); c.px(lx + 2, 38, crack.alpha(glow)); c.px(lx + 3, 40, crack.alpha(glow * 0.7))
    }
    // All of it above the legs a pixel low (the head top on row 11), so the wings and flames keep off the canvas top.
    c.oy += p.breathe + 1 - Int((2 * rise).rounded())                          // rearing up, two pixels taller
    drawBalrogWings(c, p, spread: rise)
    // The back arm, hanging.
    c.rect(10, 19, 4, 13, rockDark)
    c.rect(9, 31, 5, 4, rockDark)
    c.px(9, 35, horn); c.px(11, 35, horn); c.px(13, 35, horn)
    // The torso: huge shoulders tapering to the waist.
    let torso: [(l: Int, r: Int)] = [
        (16, 40), (14, 41), (13, 42), (13, 42), (14, 41), (15, 40), (15, 40), (16, 39), (16, 39), (17, 38), (17, 38),
        (18, 37), (18, 37), (18, 37), (18, 37), (18, 37), (18, 37), (18, 37),
    ]
    for (i, row) in torso.enumerated() {
        let y = 17 + i
        c.rect(row.l, y, row.r - row.l + 1, 1, rock)
        c.px(row.l, y, rockLight); c.px(row.r, y, rockDark)
    }
    c.rect(19, 29, 18, 1, rockDark); c.rect(19, 32, 18, 1, rockDark)          // the belly's ridges
    // The glowing cracks.
    let cracks: [[(Int, Int)]] = [
        [(20, 19), (21, 20), (22, 21), (21, 22), (21, 23), (22, 24), (23, 25), (22, 26)],
        [(35, 18), (34, 19), (33, 20), (33, 21), (34, 22), (35, 23), (34, 24), (33, 25)],
        [(27, 21), (28, 22), (28, 23), (27, 24), (27, 25), (28, 26), (29, 27), (28, 28)],
        [(24, 30), (25, 31), (24, 33), (25, 34)],
        [(32, 30), (31, 31), (32, 33)],
    ]
    for (k, crackLine) in cracks.enumerated() {
        for (j, pt) in crackLine.enumerated() {
            let a: Double = glow * (0.8 + 0.2 * sin(p.lt * 3 + Double(k + j)))
            c.px(pt.0, pt.1, (j % 3 == 1 ? hot : crack).alpha(a))
        }
    }
    // The head, thrust forward: a heavy brow, furnace eyes, a glowing mouth full of fangs.
    c.rect(27, 10, 10, 1, rock); c.rect(26, 11, 12, 1, rock)
    c.rect(25, 12, 14, 6, rock)
    c.rect(26, 18, 12, 1, rockDark)
    c.px(25, 12, rockLight); c.px(25, 13, rockLight)
    c.rect(27, 13, 12, 1, rockDark)
    for ex in [30.0, 35.0] {
        c.glowLine(ex, 14.5, ex + 2, 14.5, core: hot, glow: crack, coreR: 0.4, glowR: 1.4, strength: glow)
    }
    c.rect(30, 16, 9, 2, C(0x1A0806))
    c.rect(31, 16, 7, 1, crack.alpha(glow * 0.8))
    for x in [31, 33, 35, 37] { c.px(x, 16, C(0xE8DCC0)) }
    for x in [32, 34, 36] { c.px(x, 17, C(0xE8DCC0)) }
    // The horns, sweeping out and up.
    c.pattern(21, 4, [
        "..H.............H...",
        ".HH.............HH..",
        ".HH..............HH.",
        "HH...............HH.",
        "HH...............HH.",
        ".HH.............HH..",
        "..HHH.........HHH...",
        "....HH......HHH.....",
    ], ["H": horn])
    drawBalrogFlames(c, p, flare: rise)
    // The whip arm, reaching forward, the fist and the whip.
    line(c, 39, 19, 43, 24, rock, 2)
    line(c, 43, 24, 45, 28, rock, 1.8)
    c.rect(43, 27, 5, 4, rock); c.px(47, 27, rockLight); c.rect(43, 30, 5, 1, rockDark)
    drawFireWhip(c, p, sig: sig.flatMap(balrogSignatureWhip), burst: sig.map { $0 >= 0.5 && $0 < 0.6 } ?? false)
}

/// How far the Ballrog has reared up `s` through its signature, 0…1: its wings spread and its fire flared with it.
private func balrogRise(_ s: Double) -> Double {
    if s < 0.22 { return smooth((s - 0.02) / 0.2) }
    if s < 0.78 { return 1 }
    return 1 - smooth((s - 0.78) / 0.17)
}

/// The whip in the Ballrog's signature: hanging from the fist, drawn slowly up overhead (…0.42), cracked out in front
/// (…0.52) and held there; let fall again at 0.76. Its angle and the swing's trail, as `whipCrack` gives them.
private func balrogSignatureWhip(_ s: Double) -> (angle: Double, trail: [Double])? {
    guard s >= 0.14 && s < 0.76 else { return nil }
    func crack(_ s: Double) -> Double {
        if s < 0.46 { return 25 - 135 * smooth((s - 0.14) / 0.28) }
        let f: Double = min(1, (s - 0.46) / 0.06)
        return -110 + 135 * (1 - pow(1 - f, 3))
    }
    let dt = 0.01, now = crack(s), prev = crack(s - dt)
    return (now, abs(now - prev) > 6 ? [prev, crack(s - 2 * dt)] : [])
}

/// Fire licking up off the Ballrog's head and shoulders: flickering columns, yellow at the root, red at the tips.
/// `flare` (0…1): leaping higher, up to the canvas top.
private func drawBalrogFlames(_ c: PixelCanvas, _ p: Pose, flare: Double = 0) {
    let colours: [Px] = [C(0xFFB03A), C(0xE8501E), C(0x8A1E0A)]
    let tick = Int(p.t * 10)
    let spots: [(x: Int, y: Int, h: Int)] = [
        (27, 9, 3), (28, 9, 4), (29, 9, 5), (30, 9, 4), (31, 9, 6), (32, 9, 5), (33, 9, 4), (34, 9, 5), (35, 9, 3), (36, 9, 2),
        (14, 16, 2), (15, 16, 3), (16, 16, 3), (17, 16, 2), (38, 16, 2), (39, 16, 3), (40, 16, 2),
        (24, 11, 2), (24, 12, 2),
    ]
    let extra = Int((flare * 5).rounded()), cap = flare > 0 ? c.oy + c.baseY : -3
    for (i, s) in spots.enumerated() {
        let h = min(s.y + cap, max(1, s.h - 1 + extra + Int(noise(i * 13 + tick) * 3)))  // the tips on row 5 or lower
        for k in 0..<h {
            let band = min(2, k * 3 / h)
            c.px(s.x, s.y - k, colours[band].alpha(k == h - 1 ? 0.7 : 1))
        }
    }
}

/// Smoky wings folded behind the Ballrog: two dark triangles rising over its back, their edges fraying into smoke.
/// `spread` (0…1): unfurled wide, the far one swept up over its head and out in front of it, the near one back to the
/// canvas edge, bones showing along them.
private func drawBalrogWings(_ c: PixelCanvas, _ p: Pose, spread w: Double = 0) {
    let tick = Int(p.t * 6), bone = C(0x34201A)
    func mix(_ a: (Double, Double), _ b: (Double, Double)) -> (Double, Double) { (a.0 + (b.0 - a.0) * w, a.1 + (b.1 - a.1) * w) }
    let root = mix((22, 17), (35, 15)), tip = mix((11, 3), (64, 3)), foot = mix((14, 24), (57, 20))
    triangle(c, root, tip, foot, C(0x2E1A12), fray: tick)
    triangle(c, (18, 19), mix((2, 4), (0, 3)), mix((7, 34), (0, 28)), C(0x1E0E0A), fray: tick + 3)
    let b1 = mix((4, 6), (2, 4)), b2 = mix((6, 24), (2, 19))
    line(c, 17, 20, b1.0, b1.1, bone, 0.4)
    line(c, 17, 22, b2.0, b2.1, bone, 0.4)
    if w > 0 {
        for f in [0.35, 0.7] {                                                 // the far wing's bones, fanned
            let end = (tip.0 + (foot.0 - tip.0) * f, tip.1 + (foot.1 - tip.1) * f)
            line(c, root.0, root.1, end.0, end.1, bone.alpha(w), 0.4)
        }
    }
}

/// A filled triangle; the pixels on its edge are thinned to smoke, changing on `fray`.
private func triangle(_ c: PixelCanvas, _ a: (Double, Double), _ b: (Double, Double), _ d: (Double, Double), _ col: Px, fray: Int) {
    let minX = Int(min(a.0, b.0, d.0)), maxX = Int(max(a.0, b.0, d.0))
    let minY = Int(min(a.1, b.1, d.1)), maxY = Int(max(a.1, b.1, d.1))
    func side(_ p: (Double, Double), _ q: (Double, Double), _ r: (Double, Double)) -> Double {
        (p.0 - r.0) * (q.1 - r.1) - (q.0 - r.0) * (p.1 - r.1)
    }
    for y in minY...maxY {
        for x in minX...maxX {
            let pt = (Double(x) + 0.5, Double(y) + 0.5)
            let s1 = side(pt, a, b), s2 = side(pt, b, d), s3 = side(pt, d, a)
            let inside = (s1 >= 0 && s2 >= 0 && s3 >= 0) || (s1 <= 0 && s2 <= 0 && s3 <= 0)
            guard inside else { continue }
            let inner = (s1 >= 0 && s2 >= 0 && s3 >= 0)
                ? min(s1, s2, s3) : min(-s1, -s2, -s3)
            if inner < 18 {
                if noise(x * 7 + y * 31 + fray) > 0.45 { c.px(x, y, col.alpha(0.55)) }
            } else {
                c.px(x, y, col)
            }
        }
    }
}

/// The fire whip, a line of flame with a red glow, flickering. At rest it runs from the fist down to the floor and along
/// it. Swung (`p.melee`), it leaves the fist at the swing's angle and lags behind along its length: each bit of it
/// points the way the fist pointed a moment earlier (`p.trail`, carried on past its last angle), so the tip comes last,
/// and whatever isn't moving fast sags toward the floor. A fast swing leaves the whip's last shapes smeared behind it
/// in fire, and the tip cracks. `sig`: swung as the signature has it instead; `burst`: sparks fly off the tip.
private func drawFireWhip(_ c: PixelCanvas, _ p: Pose, sig: (angle: Double, trail: [Double])? = nil, burst: Bool = false) {
    let core = C(0xFFB03A), glow = C(0xE8501E)
    let floor = Double(43 - c.oy)
    let flick: Double = 0.85 + 0.15 * noise(Int(p.t * 20))
    func draw(_ pts: [(x: Double, y: Double)], from: Int = 1, strength: Double) {
        guard pts.count > from else { return }
        for i in from..<pts.count {
            let a = pts[i - 1], b = pts[i], f = Double(i) / Double(pts.count)
            c.glowLine(a.x, min(a.y, floor), b.x, min(b.y, floor), core: core, glow: glow, coreR: 0.55 - 0.2 * f,
                       glowR: 1.5, strength: strength * (1 - f * 0.3))
        }
    }
    var swing = p.melee, trail = p.trail
    if swing != nil, let crack = whipCrack(p) { swing = crack.angle; trail = crack.trail }
    if let s = sig { swing = s.angle; trail = s.trail }
    guard let now = swing else {
        draw([(46, 31), (47, 34), (48, 37), (49.5, 40), (51.5, 42), (54.5, 43), (58, 43), (61, 42.5), (63.5, 41), (65, 41.5)],
             strength: flick)
        return
    }
    let fast = trail.count >= 2
    let lag: [Double] = fast ? [now, trail[0], trail[1], 2 * trail[1] - trail[0]] : [now]
    let pts = whipShape(lag, floor: floor, sag: fast ? 0.2 : 0.7)
    if fast {
        // The smear: the whip's last two shapes, one swing-step back each, fading.
        let back1: [Double] = [lag[1], lag[2], lag[3], 2 * lag[3] - lag[2]]
        let back2: [Double] = [lag[2], lag[3], 2 * lag[3] - lag[2], 3 * lag[3] - 2 * lag[2]]
        draw(whipShape(back2, floor: floor, sag: 0.2), from: 10, strength: 0.18)
        draw(whipShape(back1, floor: floor, sag: 0.2), from: 8, strength: 0.35)
    }
    draw(pts, strength: flick)
    if fast, let tip = pts.last {
        c.glowLine(tip.x, min(tip.y, floor), tip.x, min(tip.y, floor), core: C(0xFFF0C0), glow: core, coreR: 0.5, glowR: 1.8,
                   strength: 0.5 + 0.5 * noise(Int(p.t * 30)))
    }
    if burst, let tip = pts.last {
        // The crack: sparks flying off the tip every way, flickering.
        for k in 0..<8 {
            let u = unit(Double(k) * 45 + 20 * noise(k + Int(p.t * 20))), r: Double = 2 + 2 * noise(k * 7 + Int(p.t * 20))
            let y = min(tip.y, floor)
            c.glowLine(tip.x + u.x * r, y + u.y * r, tip.x + u.x * (r + 2), y + u.y * (r + 2), core: C(0xFFF0C0), glow: core,
                       coreR: 0.35, glowR: 1, strength: 0.8)
        }
    }
}

/// The Ballrog's idle flourish, instead of a spin: the whip drawn back up overhead and cracked out in front of it, held
/// there until it's let fall. Its angle now and the swing's trail (as `Pose.trail` has it); nil when it isn't playing.
private func whipCrack(_ p: Pose) -> (angle: Double, trail: [Double])? {
    guard let h = idlePlay(p), h.kind == .flourish else { return nil }
    func crack(_ u: Double) -> Double {
        if u < 0.4 { return -30 - 80 * (0.5 - 0.5 * cos(min(1, max(0, u / 0.4)) * .pi)) }
        let f: Double = min(1, (u - 0.4) / 0.1)
        return -110 + 135 * (1 - pow(1 - f, 3))
    }
    let dt: Double = 0.035 / h.length, now = crack(h.p), prev = crack(h.p - dt)
    return (now, abs(now - prev) > 6 ? [prev, crack(h.p - 2 * dt)] : [])
}

/// The swung whip's points, 24 one-pixel steps out of the fist. `lag`: the angles it points along, from the fist (the
/// swing's angle now) to the tip (the oldest); `sag` (0…1): how far the tip end droops toward straight down.
private func whipShape(_ lag: [Double], floor: Double, sag: Double) -> [(x: Double, y: Double)] {
    let steps = 24
    var pts: [(x: Double, y: Double)] = [(balrogHand.x, balrogHand.y - 1)]       // drawn a pixel low (see drawBalrog)
    for i in 1...steps {
        let f = Double(i) / Double(steps)
        var a: Double = lag[0]
        if lag.count > 1 {
            let x: Double = f * Double(lag.count - 1)
            let k = min(lag.count - 2, Int(x))
            a = lag[k] + (lag[k + 1] - lag[k]) * (x - Double(k))
        }
        // The turn to straight down, the forward way round unless it already hangs low behind (so a whip held up
        // overhead droops in front of it, not over its own face).
        var down: Double = (90 - a).truncatingRemainder(dividingBy: 360)
        if down <= -100 { down += 360 } else if down > 260 { down -= 360 }
        a += down * sag * f * f
        let u = unit(a), q = pts[pts.count - 1]
        pts.append((q.x + u.x, min(floor - 0.5, q.y + u.y)))
    }
    return pts
}

// MARK: - Smeagull

/// Where Smeagull grabs from: his front shoulder (his arm, not a weapon, swings).
private let gollumShoulder: (x: Double, y: Double) = (33.5, 33.5)

/// Smeagull: a skinny pale grey-green creature, crouched lower than a hobbit stands, frog-legged with his knees out by
/// his sides, long thin arms reaching down to the floor, a few lank strands of hair, big pointed ears and huge round
/// pale-blue eyes with ink pupils, in nothing but a loincloth. He grabs and bites: the front arm shoots out along the
/// swing from the shoulder, claws spread, raking three scratches through the air behind it, and the mouth opens on
/// the strike. Signature: he hugs himself, rocking, and strokes the precious he holds in his hands (it isn't there),
/// with big happy eyes (…0.45); then he turns round on himself, eyes narrowed, snarling and clawing, as Gollum
/// arguing with Smeagull (…0.75); and turns back, all smiles again.
private func drawGollum(_ c: PixelCanvas, _ p: Pose) {
    guard let s = p.signature, p.melee == nil else { drawGollumBody(c, p, mood: .plain); return }
    guard s >= 0.45 && s < 0.75 else {
        // Into his arms over the first moments of the move and back out at the end, so it starts and ends as he stands.
        drawGollumBody(c, p, mood: .precious, hug: min(1, min(s, 1 - s) / 0.08)); return
    }
    mirrored(c, aboutX: 27.5) { drawGollumBody($0, p, mood: .gollum) }
}

private enum GollumMood { case plain, precious, gollum }

/// `hug` (precious only): how far into hugging himself he is, from 0 (arms down, as he stands) to 1.
private func drawGollumBody(_ c: PixelCanvas, _ p: Pose, mood: GollumMood, hug: Double = 1) {
    let skin = C(0xB8B49A), shade = C(0x8A866E), light = C(0xD0CCB4), eye = C(0xA8D8F0)
    let cloth = C(0x6A5A3A), clothDark = C(0x4E422A), hair = C(0x7A7460), claw = C(0xE8E4D0), mouth = C(0x5A5444)
    // Crouched legs: the knees out to the sides, the feet flat and long-toed.
    if seatedPose {
        c.rect(17, 36, 4, 2, skin); c.rect(34, 36, 4, 2, skin)
        c.rect(18, 38, 5, 1, shade); c.rect(33, 38, 5, 1, shade)
        c.px(17, 38, claw); c.px(37, 38, claw)
    } else {
        let legs: [(hip: (Double, Double), knee: (Double, Double), foot: Int)] = [
            ((22, 38), (18.5, 37), 19), ((25, 38), (24.5, 40), 24), ((29, 38), (29.5, 40), 29), ((32, 38), (35.5, 37), 35),
        ]
        for (i, l) in legs.enumerated() {
            let up: Double = p.step >= 0 && i % 2 == p.step ? 1 : 0
            let ankle = (Double(l.foot) + 0.5, 42.5 - up)
            line(c, l.hip.0, l.hip.1, l.knee.0, l.knee.1 - up, skin, 0.7)
            line(c, l.knee.0, l.knee.1 - up, ankle.0, ankle.1, skin, 0.6)
            c.rect(l.foot - 1, 43 - Int(up), 3, 1, shade)
            c.px(l.foot + 2, 43 - Int(up), claw)
        }
    }
    c.oy += p.breathe
    if mood == .precious { c.ox += Int((2 * hug * sin(p.lt * 3.4)).rounded()) }  // rocking side to side, the precious in his arms
    // The thin arms, down to the floor in front of him and behind (the front one is drawn below when it's busy).
    let armsDown = mood == .plain || (mood == .precious && hug <= 0)
    if mood != .precious || armsDown { line(c, 21, 33, 18.5, 39, skin, 0.55); c.rect(17, 39, 2, 2, skin); c.px(16, 40, claw) }
    if armsDown && p.melee == nil {
        line(c, 33, 33, 37, 38, skin, 0.55)
        c.rect(37, 38, 2, 2, skin); c.px(39, 39, claw); c.px(39, 38, claw)
    }
    // The body, narrow and hunched, the spine knobbly.
    c.rect(22, 29, 11, 1, skin)
    c.rect(21, 30, 13, 9, skin)
    c.rect(33, 30, 1, 9, shade); c.rect(21, 38, 13, 1, shade)
    c.px(21, 31, shade); c.px(21, 33, shade); c.px(21, 35, shade)
    c.px(23, 29, light); c.px(24, 29, light)
    // Big pointed ears, sticking out.
    c.pattern(18, 30, ["S..", "SSS", ".SS"], ["S": skin]); c.px(18, 30, shade)
    c.pattern(34, 30, ["..S", "SSS", "SS."], ["S": skin]); c.px(36, 30, shade)
    // A few lank strands of hair.
    for (x, y) in [(24, 28), (23, 27), (27, 28), (27, 27), (30, 28), (31, 27)] { c.px(x, y, hair) }
    let palette: [Character: Px] = ["E": eye, "W": white, "K": ink, "h": shade]
    switch mood == .precious && hug < 0.5 ? .plain : mood {   // his eyes go wide halfway into the hug
    case .plain:
        // The huge round eyes, the pupils looking ahead; a thin mouth and a snaggle tooth, or open to bite.
        for ex in [22, 28] { c.pattern(ex, 30, [".EE.", "EEWE", "EEKK", "EEKK", ".EE."], palette) }
        if let a = p.melee, !p.trail.isEmpty || (-50...35).contains(wrapped(a)) {
            c.rect(25, 35, 5, 2, C(0x2A2620))
            for x in [25, 27, 29] { c.px(x, 35, claw) }
            c.px(26, 36, claw); c.px(28, 36, claw)
        } else {
            c.rect(26, 35, 3, 1, mouth); c.px(27, 35, claw)
        }
    case .precious:
        // Even bigger eyes, wide and shining, two glints in each, gazing down at what he holds; a blush under them.
        for ex in [21, 28] {
            c.pattern(ex, 28, [".EEE.", "EWEEE", "EKKWE", "EKKKE", "EKKKE", ".EEE."], palette)
        }
        c.rect(20, 35, 2, 1, C(0xD8A090)); c.rect(33, 35, 2, 1, C(0xD8A090))
    case .gollum:
        // Narrowed eyes under a scowl; a snarl, all teeth.
        for ex in [22, 28] { c.pattern(ex, 31, ["hhhh", "EEKK", ".EE."], palette) }
        c.rect(22, 30, 2, 1, ink); c.rect(24, 31, 2, 1, ink)
        c.rect(28, 31, 2, 1, ink); c.rect(30, 30, 2, 1, ink)
        c.rect(24, 35, 7, 2, C(0x2A2620))
        for x in [24, 26, 28, 30] { c.px(x, 35, claw) }
        for x in [25, 27, 29] { c.px(x, 36, claw) }
    }
    // The loincloth.
    c.rect(23, 38, 9, 1, cloth)
    c.rect(23, 37, 9, 1, clothDark)
    for x in stride(from: 23, through: 31, by: 2) where 39 + c.oy <= 43 { c.px(x, 39, cloth) }
    switch mood {
    case .precious where hug <= 0:
        break                                                                       // arms still down, drawn above
    case .precious where hug < 1:
        // On the way into the hug (or out of it): the arms swing up from the floor to cross in front of him.
        func mix(_ a: (Double, Double), _ b: (Double, Double)) -> (Double, Double) {
            (a.0 + (b.0 - a.0) * hug, a.1 + (b.1 - a.1) * hug)
        }
        for (sh, down, elbow, wrist) in [((21.0, 33.0), (18.5, 39.0), (18.0, 36.5), (24.0, 35.0)),
                                         ((33.0, 33.0), (37.5, 38.5), (37.0, 36.5), (31.0, 35.0))] {
            let e = mix(((sh.0 + down.0) / 2, (sh.1 + down.1) / 2), elbow), w = mix(down, wrist)
            line(c, sh.0, sh.1, e.0, e.1, skin, 0.55)
            line(c, e.0, e.1, w.0, w.1, skin, 0.55)
            c.rect(Int(w.0.rounded()) - 1, Int(w.1.rounded()), 2, 2, skin)
        }
    case .precious:
        // Both arms wrapped round himself, the elbows sticking out at his sides, the hands cupped together under his
        // chin, the fingers of one stroking what's in them; and over his head, the twinkle of something precious.
        let arm = C(0x6E6A56)
        for (sh, elbow, wrist) in [((22.0, 33.0), (18.0, 36.5), (24.0, 35.0)), ((33.0, 33.0), (37.0, 36.5), (31.0, 35.0))] {
            for (r, col) in [(1.1, arm), (0.5, light)] {                           // outlined, so they show over him
                line(c, sh.0, sh.1, elbow.0, elbow.1, col, r)
                line(c, elbow.0, elbow.1, wrist.0, wrist.1, col, r)
            }
        }
        // The two hands, pale, cupped together (the fingers of the near one curled over), outlined.
        c.rect(23, 33, 10, 4, arm)
        c.rect(24, 34, 8, 2, claw)
        c.rect(24, 35, 8, 1, light)
        let stroke = Int((sin(p.lt * 7) * 1.5).rounded())
        c.rect(26 + stroke, 33, 3, 1, claw)                                        // the stroking finger
        let tw: Double = 0.5 + 0.5 * sin(p.lt * 5)
        for (x, y, k) in [(26, 24, 0.0), (31, 25, 2.1), (22, 25, 4.2)] {
            let a: Double = 0.35 + 0.65 * max(0, sin(p.lt * 4 + k)) * tw
            c.px(x, y, C(0xFFF0B0, a)); c.px(x - 1, y, C(0xFFF0B0, a * 0.45)); c.px(x + 1, y, C(0xFFF0B0, a * 0.45))
            c.px(x, y - 1, C(0xFFF0B0, a * 0.45)); c.px(x, y + 1, C(0xFFF0B0, a * 0.45))
        }
    case .gollum:
        // The front arm up, claws out, at the one he's arguing with.
        line(c, 33, 33, 37, 29.5, skin, 0.55)
        c.rect(37, 28, 2, 2, skin)
        c.px(39, 27, claw); c.px(40, 28, claw); c.px(39, 30, claw)
    case .plain:
        if let a = p.melee { drawGrab(c, p, angle: a, skin: skin, claw: claw) }
    }
}

/// Smeagull's grab: the front arm shot out from the shoulder along `angle`, the hand open and the three claws spread;
/// a fast swing rakes three claw-scratches through the air behind it.
private func drawGrab(_ c: PixelCanvas, _ p: Pose, angle: Double, skin: Px, claw: Px) {
    let sh = gollumShoulder, reach: Double = 7
    // His arm only reaches round so far: up over his head and down to the floor in front, never behind him.
    func arm(_ a: Double) -> Double { min(70, max(-105, wrapped(a))) }
    let now = arm(angle)
    if let last = p.trail.last {
        // Three scratches through the air, from the claws back along the swing, fading.
        let end: Double = arm(last + (last - angle) * 1.5)
        let n = max(2, Int((abs(end - now) / 4).rounded()))
        for i in 1...n {
            let u = unit(now + (end - now) * Double(i) / Double(n)), fade: Double = 0.7 * (1 - Double(i) / Double(n + 1))
            for r in [reach + 1.5, reach + 3.5, reach + 5.5] {
                c.px(Int((sh.x + u.x * r).rounded(.down)), Int((sh.y + u.y * r).rounded(.down)), C(0xF4F0E0, fade))
            }
        }
    }
    let u = unit(now), hand = (x: sh.x + u.x * reach, y: sh.y + u.y * reach)
    line(c, sh.x - 0.5, sh.y - 0.5, hand.x, hand.y, skin, 0.6)
    c.rect(Int(hand.x.rounded(.down)) - 1, Int(hand.y.rounded(.down)) - 1, 2, 2, skin)
    for spread in [-50.0, 0, 50] {                                              // the claws, spread
        let v = unit(now + spread)
        for d in [2.0, 3.2] { c.px(Int((hand.x + v.x * d).rounded(.down)), Int((hand.y + v.y * d).rounded(.down)), claw) }
    }
}

// MARK: - Uruk-Hi

/// Uruk-Hi, the big fighting orc: dark brown skin, a white hand print over the face (the eyes looking out between the
/// fingers), a black iron helmet with the White Hand painted on its front, black armour plates on chest and shoulders,
/// and a heavy, notched sword, held low; it is heavy, so a fast swing smears a long way behind it. Signature: "Meat's
/// back on the menu!": it brings up a roast haunch of meat in its off hand (…0.12), chomps it in three big bites, the
/// head ducking into each and the crumbs flying, down to the bare bone (…0.72), holds the bone up, and tosses it away
/// back over its shoulder.
private func drawUruk(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature.flatMap { $0 > 0.02 && $0 < 0.98 ? $0 : nil }
    let skin = C(0x4A3A2E), skinDark = C(0x3A2C22), hand = C(0xF0EEE8)
    let plate = C(0x1E1E22), plateLight = C(0x3A3A42), plateMid = C(0x2A2A30), helm = C(0x2A2A30), helmLight = C(0x46464E)
    drawLegs(c, Look(leg: C(0x2E2620)), step: p.step)
    drawBoots(c, p.step, plate, rows: 3)
    c.oy += p.breathe
    if let s = sig, urukChomp(s) != nil { c.oy += 1 }                          // ducking into a bite
    // The body, broad, in its own dark skin, and the arms in black plate.
    c.rect(17, 26, 22, 12, skin)
    c.rect(38, 26, 1, 12, skinDark)
    if sig == nil { c.rect(14, 33, 3, 3, plate) }
    // The face: the white hand over it, the eyes between the fingers.
    c.pattern(21, 26, [
        "..W..W.W..W...",
        "KKW..W.W..WKK.",
        "KK.W.W.W.W.KK.",
        "...WWWWWWW....",
        "WW.WWWWWWW....",
        ".WWWWWWWW.....",
    ], ["W": hand, "K": ink])
    c.px(21, 27, C(0xC89A3A)); c.px(32, 27, C(0xC89A3A))
    // The armour: chest plates, a skirt of plates, spiked pauldrons.
    c.rect(17, 32, 22, 6, plate)
    c.rect(17, 32, 22, 1, plateLight)
    c.rect(17, 35, 22, 1, plateMid)
    c.rect(27, 32, 1, 6, plateMid)
    for y in 38...39 where y + c.oy <= 43 {
        for x in stride(from: 17, through: 36, by: 4) { c.rect(x, y, 3, 1, y == 38 ? plateMid : plate) }
    }
    c.pattern(13, 29, ["K.K..", "KKKK.", "KKKKK", "KHKKK", ".KKK."], ["K": plate, "H": plateLight])
    c.pattern(36, 29, ["..K.K", ".KKKK", "KKKKK", "KKKHK", ".KKK."], ["K": plate, "H": plateLight])
    // The helmet, the White Hand on its front, a peak over the eyes.
    c.pattern(16, 19, [
        ".........KKKKKK.........",
        "......KKKKKKKKKKKK......",
        "....KKKKhKKKKKKKKKKK....",
        "...KKKhKKKKKKKKKKKKKK...",
        "..KKKhKKKKKKKKKKKKKKKK..",
        ".KKKKKKKKKKKKKKKKKKKKKK.",
        "KKKKKKKKKKKKKKKKKKKKKKKKKK",
    ], ["K": helm, "h": helmLight])
    c.pattern(25, 20, [".W.W.W.", ".W.W.W.", ".WWWWW.", "WWWWWW.", ".WWWW.."], ["W": hand])
    if let s = sig { drawMeat(c, p, s, plate: plate) }
    // The sword, and a long smear behind a fast swing (never through the floor). Idle, he doesn't twirl it: it's
    // heaved up overhead and chopped down in front of him.
    var sword = p.melee ?? (seatedPose ? 6 : 32)
    var trail = p.melee == nil ? [] : p.trail
    if p.melee != nil, let h = idlePlay(p), h.kind == .flourish {
        let chop = { (u: Double) -> Double in
            if u < 0.45 { return 32 - 112 * smooth((u - 0.08) / 0.37) }
            if u < 0.55 { return -80 + 105 * (1 - pow(1 - (u - 0.45) / 0.1, 3)) }
            return 25 + 7 * smooth((u - 0.55) / 0.37)
        }
        sword = chop(h.p)
        let before = chop(max(0, h.p - 0.04))
        trail = abs(before - sword) > 4 ? [before, before + (before - sword)] : []
    }
    let floor = Double(43 - c.oy)
    for (i, a) in heavySmear(sword, trail).enumerated() {
        let u = unit(a), h = Sprite.hand, fade: Double = 0.3 * (1 - Double(i) / 12)
        guard fade > 0.03 else { break }
        let out: Double = u.y > 0.05 ? min(16, (floor - 1 - h.y) / u.y) : 16
        guard out > 11 else { continue }
        c.glowLine(h.x + u.x * 11, h.y + u.y * 11, h.x + u.x * out, h.y + u.y * out, core: C(0xC8CCD4),
                   glow: C(0x7A7E86, 0.5), coreR: 0.6, glowR: 1.4, strength: fade)
    }
    drawUrukSword(c, angle: sword)
    c.rect(38, 33, 3, 3, plate); c.px(38, 33, plateLight)
}

/// The bites in Uruk-Hi's signature: when each one starts.
private let urukBites: [Double] = [0.2, 0.38, 0.56]

/// Which bite the Uruk is chomping `s` through its signature (its head ducked into it), if any.
private func urukChomp(_ s: Double) -> Int? {
    urukBites.firstIndex { s >= $0 && s < $0 + 0.06 }
}

/// The haunch of meat in the Uruk's off hand, `s` through its signature: brought up from its side to its mouth, bitten
/// down to the bone (a bite gone at each chomp, the red showing, crumbs flying), held up bare, then tossed back over
/// its shoulder, end over end, and the arm let down again.
private func drawMeat(_ c: PixelCanvas, _ p: Pose, _ s: Double, plate: Px) {
    let crust = C(0x8A4420), meat = C(0xB45E2C), roast = C(0xD88A48), red = C(0xD8505A)
    let bone = C(0xE8E0CC), boneShade = C(0xB8AE98)
    let bites = urukBites.filter { s >= $0 + 0.03 }.count
    // The arm: from the back shoulder, up to the mouth (lowered at the start and the end).
    let up: Double = s < 0.12 ? smooth(s / 0.12) : s < 0.86 ? 1 : 1 - smooth((s - 0.86) / 0.08)
    let hand = (x: 15 + 7 * up, y: 34 - 3 * up)
    line(c, 15.5, 33.5, hand.x, hand.y, plate, 1.2)
    if s < 0.86 {
        let hx = Int(hand.x.rounded()), hy = Int(hand.y.rounded())
        // The bone in the fist, its knob sticking out behind; the meat on its end at the mouth.
        c.rect(hx - 3, hy - 1, 2, 3, bone); c.px(hx - 3, hy, boneShade)
        c.rect(hx, hy, 9, 1, bone)
        let meatArt: [[String]] = [
            ["..MMMMM..", ".MhhhmmM.", "MhhmmmmmM", "MmmmmmmmM", ".MmmmmmM.", "..MMMMM.."],
            ["..MMMr...", ".Mhhhr...", "Mhhmmr...", "Mmmmmr...", ".Mmmr....", "..MMr...."],
            ["..Mr.....", ".Mhr.....", "Mhr......", "Mmr......", ".Mr......", "..r......"],
            [],
        ]
        c.pattern(hx + 3, hy - 3, meatArt[bites], ["M": crust, "m": meat, "h": roast, "r": red])
        if bites == 3 { c.rect(hx + 8, hy - 1, 2, 3, bone); c.px(hx + 9, hy + 1, boneShade) }   // the bare bone's far knob
        c.rect(hx - 1, hy - 1, 3, 3, plate)                                    // the fist
    }
    // Crumbs flying off each bite, out and down.
    for b in urukBites where s >= b + 0.03 && s < b + 0.15 {
        let k = (s - b - 0.03) / 0.12
        for (i, v) in [(1.0, -0.6), (1.4, 0.2), (0.6, -1.1), (1.2, 0.9)].enumerated() {
            let x = 30 + v.0 * 9 * k, y = 30 + v.1 * 6 * k + 10 * k * k
            c.px(Int(x.rounded()), Int(y.rounded()), (i % 2 == 0 ? meat : roast).alpha(1 - k * 0.6))
        }
    }
    // Tossed: the bone flies back over its shoulder, end over end, off the canvas.
    if s >= 0.86 {
        let k = (s - 0.86) / 0.12
        let x = 22 - 26 * k, y = 30 - 22 * k + 18 * k * k
        let spin = unit(k * 540)
        line(c, x - spin.x * 3, y - spin.y * 3, x + spin.x * 3, y + spin.y * 3, bone, 0.6)
        c.rect(Int((x - spin.x * 3).rounded()) - 1, Int((y - spin.y * 3).rounded()) - 1, 2, 2, bone)
        c.rect(Int((x + spin.x * 3).rounded()) - 1, Int((y + spin.y * 3).rounded()) - 1, 2, 2, bone)
    }
}

/// The Uruk's heavy sword: a crude broad blade, notched along the edge and flaring to a clipped point, a heavy iron
/// crossguard and a leather-wrapped grip.
private func drawUrukSword(_ c: PixelCanvas, angle: Double) {
    let h = Sprite.hand, u = unit(angle), n = (x: -u.y, y: u.x)                 // n: toward the edge
    let blade = C(0x7A7E86), edge = C(0xA8ACB4), dark = C(0x3A3E46)
    func at(_ d: Double, _ o: Double = 0) -> (x: Double, y: Double) { (h.x + u.x * d + n.x * o, h.y + u.y * d + n.y * o) }
    let g0 = at(-2.5), g1 = at(1.5)
    line(c, g0.x, g0.y, g1.x, g1.y, C(0x3A2A1E), 0.6)                            // the grip
    let pm = at(-3); c.px(Int(pm.x), Int(pm.y), dark)                             // the pommel
    let b0 = at(3), b1 = at(14), t0 = at(14, 0.6), t1 = at(17, 0.3)
    line(c, b0.x, b0.y, b1.x, b1.y, blade, 1.2)
    line(c, b1.x, b1.y, t0.x, t0.y, blade, 1.5)
    line(c, t0.x, t0.y, t1.x, t1.y, blade, 0.9)
    let e0 = at(3, 1), e1 = at(16, 1.2)
    line(c, e0.x, e0.y, e1.x, e1.y, edge, 0.35)
    for d in [6.0, 9.5, 12.5] { let q = at(d, 1.3); c.px(Int(q.x), Int(q.y), dark) }   // the notches
    let q0 = at(2.2, -3), q1 = at(2.2, 3)
    line(c, q0.x, q0.y, q1.x, q1.y, C(0x2A2A30), 0.75)                           // the crossguard
}

// MARK: - Lintz

/// Lintz, the first Uruk captain: as big as Uruk-Hi but bareheaded, bald, his dark skin bare from the crown to the
/// belt, and the White Hand painted across his face, the palm over his mouth and the fingers spread up over his brow
/// and his scalp, his yellow eyes looking out either side. Black armour pieces strapped on over the bare chest: one
/// spiked pauldron on the front shoulder, a strap across the chest, a black belt and a skirt of plates, a black bracer,
/// and a quiver of dark-fletched arrows on his back. A black recurved longbow held out in front of him; shooting, he
/// nocks an arrow and draws the string back before each shot, as Leggolas does. Signature: he nocks three arrows at
/// once, fanned out on the string (…0.12), draws them back (…0.4) and roars, mouth wide under the painted palm, shaking
/// with it (…0.75); then lets all three fly off the canvas together, the string twanging.
private func drawLurtz(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature.flatMap { $0 > 0.03 && $0 < 0.97 ? $0 : nil }
    let roaring = sig.map { $0 >= 0.42 && $0 < 0.75 } ?? false
    let skin = C(0x3A2A22), skinDark = C(0x2A1E18), skinLight = C(0x56412F), paint = C(0xF0EEE8)
    let plate = C(0x1E1E22), plateLight = C(0x3A3A42), plateMid = C(0x2A2A30)
    drawLegs(c, Look(leg: C(0x2E2620)), step: p.step)
    drawBoots(c, p.step, plate, rows: 3)
    c.oy += p.breathe
    if roaring, let s = sig { c.ox += Int(s * 3.2 * 18) % 2 == 0 ? 0 : 1 }       // shaking with the roar
    // The quiver, slung over his back, the dark fletchings over his shoulder.
    c.pattern(11, 18, [
        "F.F.....",
        ".F.F....",
        "..QQQ...",
        "..QQQq..",
        "...QQQq.",
        "...QQQQ.",
        "....QQQq",
        "....QQQQ",
        ".....QQq",
    ], ["F": C(0x6A6A72), "Q": C(0x4A3424), "q": C(0x33241A)])
    // The broad body in his bare dark skin, and the bald dome of his head with a sheen on the crown.
    c.rect(17, 26, 22, 12, skin)
    c.rect(38, 26, 1, 12, skinDark)
    c.pattern(17, 20, [
        "......SSSSSSSSSS......",
        "...SSSSlllSSSSSSSSS...",
        "..SSSlllSSSSSSSSSSSS..",
        ".SSSllSSSSSSSSSSSSSSd.",
        "SSSSSSSSSSSSSSSSSSSSSd",
        "SSSSSSSSSSSSSSSSSSSSSd",
    ], ["S": skin, "l": skinLight, "d": skinDark])
    c.rect(14, 33, 3, 3, skin); c.rect(14, 33, 3, 1, plate)
    // The White Hand: the palm over the mouth, the fingers up over the brow onto the scalp, the eyes either side.
    c.pattern(19, 21, [
        ".......W.W........",
        ".....W.W.W.W......",
        ".....W.W.W.W......",
        ".....W.W.W.W......",
        ".....W.W.W.W......",
        ".....W.W.W.W......",
        ".....W.W.W.W......",
        ".....WWWWWWWW.....",
        ".....WWWWWWWW.....",
        "...WWWWWWWWWW.....",
        "....WWWWWWWW......",
    ], ["W": paint])
    c.rect(21, 27, 2, 2, ink); c.rect(33, 27, 2, 2, ink)
    c.px(21, 27, C(0xC89A3A)); c.px(34, 27, C(0xC89A3A))
    // The bare chest, a strap across it, the belt and a skirt of plates.
    c.rect(20, 34, 6, 1, skinDark); c.rect(29, 34, 6, 1, skinDark); c.px(27, 35, skinDark)
    for i in 0..<4 { c.rect(33 - i * 3, 32 + i, 3, 1, plate) }
    c.rect(17, 36, 22, 2, plate); c.rect(17, 36, 22, 1, plateMid); c.px(27, 36, plateLight)
    // The bare skin shaded: lit down the near side and across the near pec, the far side falling into shadow; an
    // iron buckle on the belt.
    c.rect(17, 27, 1, 6, skinLight); c.rect(20, 33, 5, 1, skinLight)
    c.rect(37, 28, 1, 6, skinDark)
    c.rect(26, 36, 3, 2, plateLight); c.px(27, 37, plate)
    for y in 38...39 where y + c.oy <= 43 {
        for x in stride(from: 17, through: 36, by: 4) { c.rect(x, y, 3, 1, y == 38 ? plateMid : plate) }
    }
    // The one spiked pauldron, on the front shoulder.
    c.pattern(35, 28, ["..K.K", ".KKKK", "KKKKK", "KKKHK", ".KKK."], ["K": plate, "H": plateLight])
    if roaring {
        // The roar: the mouth wide open under the painted palm, fangs top and bottom, and the noise of it.
        c.rect(24, 30, 7, 4, C(0x1A0C0A)); c.rect(25, 32, 5, 1, C(0x6A1E1A))
        for x in [24, 26, 28, 30] { c.px(x, 30, paint) }
        c.px(25, 33, paint); c.px(29, 33, paint)
        for a in [-40.0, -15, 10] {
            let u = unit(a)
            line(c, 45 + u.x * 3, 27 + u.y * 3, 45 + u.x * 9, 27 + u.y * 9, C(0xF0EEE8, 0.9), 0.5)
        }
    }
    if let s = sig {
        drawThreeArrows(c, p, s, skin: skin, plate: plate)
        return
    }
    // The black bow held out; an arrow on the string while he aims, drawn back before he shoots.
    var pull = 0, nocked = p.ready
    if let f = p.fire {
        let ph = frac(f.t / p.firePeriod)
        nocked = ph >= 0.45
        if ph > 0.6 { pull = Int(((ph - 0.6) / 0.4 * 3).rounded()) }
    }
    c.oy += p.gunY + (seatedPose ? -3 : 0)
    drawBlackBow(c, pull: pull)
    c.rect(38, 33, 4, 2, skin); c.rect(38, 33, 2, 2, plate)
    c.rect(42, 33, 2, 3, skin)
    if nocked {
        let tail = 40 - pull
        c.rect(tail, 34, 47 - tail, 1, C(0x4A3424))
        c.px(47, 34, C(0x8A8E98)); c.px(48, 34, C(0xC8CCD4))
        c.px(tail, 33, C(0x6A6A72)); c.px(tail, 35, C(0x6A6A72))
        c.rect(tail - 1, 34, 2, 2, skin)                                       // the hand on the string
    }
}

/// Lintz's bow in his signature, `s` through it: three arrows fanned on the string (from 0.12), drawn back three pixels
/// (…0.4) and held; loosed at 0.75, all three flying off together while the string twangs.
private func drawThreeArrows(_ c: PixelCanvas, _ p: Pose, _ s: Double, skin: Px, plate: Px) {
    let shaft = C(0x4A3424), head = C(0xC8CCD4), headDark = C(0x8A8E98), fletch = C(0x6A6A72)
    let pull: Int
    if s < 0.12 { pull = 0 } else if s < 0.4 { pull = Int((3 * smooth((s - 0.12) / 0.28)).rounded()) }
    else if s < 0.75 { pull = 3 } else if s < 0.87 { pull = Int(s * 3.2 * 30) % 2 == 0 ? -1 : 1 }   // the twang
    else { pull = 0 }
    c.oy += p.gunY
    drawBlackBow(c, pull: pull)
    c.rect(38, 33, 4, 2, skin); c.rect(38, 33, 2, 2, plate)
    c.rect(42, 33, 2, 3, skin)
    let fly: Double = s < 0.75 ? 0 : (s - 0.75) / 0.12 * 40
    guard s >= 0.06, fly < 40 else { return }
    let tail = Double(40 - (s < 0.75 ? pull : 0))
    for d in [-1.0, 0, 1] {
        // Each arrow from its nock on the string out past the bow, the three fanned a little apart.
        let y0 = 34.5 + d, slope: Double = d * 0.3
        let x0 = tail + fly, x1 = x0 + 8
        line(c, x0, y0 + slope * fly, x1, y0 + slope * (fly + 8), shaft, 0.45)
        let tip = (x: x1, y: y0 + slope * (fly + 8))
        c.px(Int(tip.x), Int(tip.y), headDark); c.px(Int(tip.x) + 1, Int(tip.y), head)
        c.px(Int(x0), Int(y0 + slope * fly) - (d < 0 ? 1 : 0), fletch)
    }
    if s < 0.75 { c.rect(Int(tail) - 1, 33, 2, 3, skin) }                       // the hand on the string
}

/// Lintz's longbow: black limbs gripped in leather at (43, 34), the tips curling forward, the string back at x 40,
/// drawn back `pull` pixels more at the middle.
private func drawBlackBow(_ c: PixelCanvas, pull: Int = 0) {
    let limb = C(0x1E1E22), limbLight = C(0x46464E), grip = C(0x5A3A26), string = C(0xC8C8D0)
    for y in 24...44 where y + c.oy <= 43 {
        let d = abs(y - 34)
        let x = d <= 2 ? 44 : d <= 5 ? 43 : d <= 8 ? 42 : 41
        c.px(x, y, d <= 1 ? grip : d % 4 == 2 ? limbLight : limb)
        if d == 10 { c.px(x + 1, y, limb) }                                    // the recurved tips
    }
    for y in 25...43 where y + c.oy <= 43 {
        let d = Double(abs(y - 34)) / 9
        c.px(40 - Int((Double(pull) * (1 - d)).rounded()), y, string)
    }
}

// MARK: - Gorbage

/// Gorbage, an orc of the rank and file: hunched, his head pushed forward, mottled green-grey skin, big pointed ears,
/// tusks, a crooked dented iron helmet, a ragged leather jerkin, and for a shield a dented bin lid with its handle
/// (he collects the garbage). A scimitar, held low between fights, a smear behind a fast swing. Signature: "Collecting
/// garbage!": he swings the bin lid round in front of him like a drum (…0.1), the scimitar up on end in his fist, and
/// bangs out a beat on it with the pommel, ba-dum, ba-dum-dum… CRASH (…0.8), the lid jumping and ringing with each
/// one, then slings it back on his arm.
private func drawOrc(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature.flatMap { $0 > 0.02 && $0 < 0.98 ? $0 : nil }
    let skin = C(0x5A6A4A), skinDark = C(0x46543A), skinLight = C(0x6E7E5C)
    let iron = C(0x5A5E66), ironDark = C(0x3E4248), ironLight = C(0x7A7E86)
    let jerkin = C(0x6A4A2E), jerkinDark = C(0x4E3420)
    drawLegs(c, Look(leg: C(0x3A3428)), step: p.step)
    drawBoots(c, p.step, C(0x5A4A36), rows: 2)
    c.oy += p.breathe
    // The hunched body: the head pushed forward, a hump behind the shoulders.
    c.rect(18, 31, 20, 7, skin)
    c.rect(20, 28, 19, 3, skin)
    c.rect(18, 29, 2, 2, skin); c.px(18, 29, skinLight)
    c.rect(38, 28, 1, 3, skinDark); c.rect(37, 31, 1, 7, skinDark)
    for (x, y) in [(22, 30), (35, 29), (24, 35), (31, 33), (20, 33), (29, 29)] { c.px(x, y, skinDark) }
    for (x, y) in [(26, 29), (33, 32), (21, 31)] { c.px(x, y, skinLight) }
    c.rect(14, 33, 4, 3, skin)
    // Big pointed ears, swept back.
    c.pattern(15, 28, ["SS...", ".SSS.", "..SS."], ["S": skin]); c.px(15, 28, skinDark)
    // The face: small mean eyes, a jutting jaw with two tusks.
    c.rect(26, 30, 2, 2, ink); c.rect(34, 30, 2, 2, ink)
    c.px(26, 30, C(0xC8A03A)); c.px(34, 30, C(0xC8A03A))
    c.rect(28, 33, 9, 1, C(0x2E3424))
    c.px(29, 32, C(0xE8E0C8)); c.px(35, 32, C(0xE8E0C8))
    // The ragged jerkin.
    c.rect(18, 34, 20, 4, jerkin)
    c.rect(37, 34, 1, 4, jerkinDark)
    c.rect(18, 36, 20, 1, C(0x3A2A1A))
    for x in stride(from: 18, through: 37, by: 2) where 38 + c.oy <= 43 { c.px(x, 38, jerkin); if x % 4 == 0 { c.px(x, 39, jerkinDark) } }
    c.px(22, 35, jerkinDark); c.px(32, 34, jerkinDark); c.px(25, 37, jerkinDark)
    // The crooked helmet, dented, tipped down at the back.
    c.pattern(19, 23, [
        "...........III......",
        "........IIIIIIII....",
        ".....IIIIhIIIIIIII..",
        "...IIIhIIIIIdIIIIIi.",
        ".IIIIIIIIIIIIIIIIIi.",
        "IIIiIIIIIIIIIIIIIi..",
        "III.................",
    ], ["I": iron, "h": ironLight, "i": ironDark, "d": ironDark])
    // The bin lid on his off arm, the scimitar in his fist.
    if let s = sig {
        drawBinDrum(c, p, s, skin: skin, skinDark: skinDark)
        return
    }
    drawBinLid(c, cx: 13, cy: seatedPose ? 33 : 34)
    let blade = p.melee ?? (seatedPose ? 4 : 30)
    for (i, a) in (p.melee == nil ? [] : p.trail).enumerated() {
        let u = unit(a), h = Sprite.hand
        c.glowLine(h.x + u.x * 4, h.y + u.y * 4, h.x + u.x * 15, h.y + u.y * 15, core: C(0xD8DCE4), glow: C(0x8A8E98),
                   coreR: 0.5, glowR: 1.6, strength: 0.3 / Double(i + 1))
    }
    drawScimitar(c, angle: blade)
    c.rect(38, 33, 3, 3, skin); c.px(40, 35, skinDark)
}

/// The beats Gorbage bangs out on his bin lid: when each lands, the last one the big crash.
private let orcBeats: [Double] = [0.18, 0.28, 0.42, 0.5, 0.58, 0.74]

/// Gorbage's drum, `s` through his signature: the bin lid swung round in front of his belly, and the scimitar held up
/// on end, its pommel brought down on the lid for each beat (raised high just before), the lid jumping a pixel and
/// ringing as it's struck, three rings round it for the crash.
private func drawBinDrum(_ c: PixelCanvas, _ p: Pose, _ s: Double, skin: Px, skinDark: Px) {
    let held: Double = s < 0.1 ? smooth(s / 0.1) : s < 0.88 ? 1 : 1 - smooth((s - 0.88) / 0.08)
    let struck = orcBeats.lastIndex { s >= $0 && s < $0 + 0.05 }
    let windup = orcBeats.contains { s >= $0 - 0.05 && s < $0 }
    let cx = Int((13 + 25 * held).rounded()), cy = 34 + Int((3 * held).rounded()) + (struck != nil ? 1 : 0)
    drawBinLid(c, cx: cx, cy: cy)
    if let b = struck {
        // The ring of it: short strokes off the lid's edge, more for the crash.
        let crash = b == orcBeats.count - 1
        for a in crash ? [-75.0, -40, -5, 30, 160, 200] : [-40.0, -5, 30] {
            let u = unit(a), r0: Double = 6.5, r1: Double = crash ? 11 : 9.5
            line(c, Double(cx) + 0.5 + u.x * r0, Double(cy) + 0.5 + u.y * r0, Double(cx) + 0.5 + u.x * r1,
                 Double(cy) + 0.5 + u.y * r1, C(0xFFF4C0), 0.5)
        }
    }
    // The fist: raised high before a beat, down on the lid as it lands, in between otherwise; low at either end.
    let beat: (x: Double, y: Double) = struck != nil ? (40.5, 32.5) : windup ? (43.5, 25.5) : (41.5, 30.5)
    let hand = (x: 41.5 + (beat.x - 41.5) * held, y: 34.5 + (beat.y - 34.5) * held)
    drawScimitar(c, angle: 30 - 112 * held, at: hand)
    line(c, 37.5, 33.5, hand.x, hand.y, skin, 0.6)
    c.rect(Int(hand.x) - 3, Int(hand.y) - 1, 3, 3, skin); c.px(Int(hand.x) - 1, Int(hand.y) + 1, skinDark)
}

/// A dented bin lid used as a shield: a tin disk with a rolled rim, a ridge ring, dents, and the handle in the middle.
private func drawBinLid(_ c: PixelCanvas, cx: Int, cy: Int) {
    let tin = C(0x8A8E98), rim = C(0x6A6E78), light = C(0xB0B4BC), dent = C(0x6E727C)
    c.ellipse(cx, cy, 5, 5, rim)
    c.ellipse(cx, cy, 4, 4, tin)
    c.ellipse(cx, cy, 2, 2, light)
    c.ellipse(cx, cy, 1, 1, tin)
    c.rect(cx - 1, cy - 1, 3, 1, C(0x4A4E58)); c.px(cx - 1, cy, C(0x4A4E58)); c.px(cx + 1, cy, C(0x4A4E58))   // the handle
    for (dx, dy) in [(-3, -2), (2, 3), (3, -1)] { c.px(cx + dx, cy + dy, dent) }
    c.px(cx - 2, cy + 3, light); c.px(cx + 5, cy, C(0x4A4E58))
}

/// Gorbage's scimitar: a short grip, a plain crossguard and a curved blade that widens toward the tip and sweeps back.
private func drawScimitar(_ c: PixelCanvas, angle: Double, at h: (x: Double, y: Double) = Sprite.hand) {
    let u = unit(angle), n = (x: u.y, y: -u.x)                                  // n: toward the back of the blade
    let blade = C(0xA8ACB4), edge = C(0x6E727C)
    func at(_ d: Double, _ o: Double = 0) -> (x: Double, y: Double) { (h.x + u.x * d + n.x * o, h.y + u.y * d + n.y * o) }
    let g0 = at(-2), g1 = at(1.5)
    line(c, g0.x, g0.y, g1.x, g1.y, C(0x3A2A1E), 0.6)
    var prev = at(2.5)
    for i in 1...6 {
        let f = Double(i) / 6
        let q = at(2.5 + f * 12, f * f * 3.5)
        line(c, prev.x, prev.y, q.x, q.y, blade, 0.7 + f * 0.4)
        let e0 = (prev.x - n.x * 0.8, prev.y - n.y * 0.8), e1 = (q.x - n.x * (0.8 + f * 0.4), q.y - n.y * (0.8 + f * 0.4))
        line(c, e0.0, e0.1, e1.0, e1.1, edge, 0.3)
        prev = q
    }
    let q0 = at(2, -2.2), q1 = at(2, 2.2)
    line(c, q0.x, q0.y, q1.x, q1.y, C(0x4A4E58), 0.55)
}

// MARK: - Shellob

/// Where Shellob bites: the fangs, under the eyes at the front.
private let shelobFangs: (x: Double, y: Double) = (45.5, 38.5)

/// Shellob, the great spider: an ink-black bulbous body with a pale mark on its back, low on eight long jointed legs
/// (the far four paler), a cluster of glinting yellow eyes at the front and two curved fangs under them. Walking, the
/// legs step four and four. She bites: in a fight she rears her two front legs up in front of her, their tips stabbing
/// with the swing, and the fangs flex with it, spread wide on the wind-up and snapping shut on the strike, a faint
/// ghost of them behind a fast one. Signature: a thread shoots up to the top of the screen and she scuttles up it,
/// fading out on the way (…0.12); a moment later she drops back down it, fading in, bouncing on the end of it, fangs
/// spread wide (…0.36), and dangles there, bobbing, legs curled and twitching; climbs a little way back up, and lets
/// herself down onto her feet again, reeling the thread in (`shelobClimb`).
private func drawShelob(_ c: PixelCanvas, _ p: Pose) {
    let body = C(0x2A221E), dark = C(0x1A1412), light = C(0x40362F), far = C(0x4A3E36), mark = C(0xC8C0A8)
    let eye = C(0xFFE08A), bristle = C(0x5E5048)
    // On her thread (the signature), whoever places her lifts her, fades her and draws the thread (`shelobClimb`);
    // here she only curls her legs and spreads her fangs.
    let hang = p.signature.flatMap { $0 > 0.02 && $0 < 0.98 ? shelobHang($0, lt: p.lt) : nil }
    let curl = hang?.curl ?? 0
    // The near legs arch high over the body; the far ones bend behind it, only their feet showing between.
    typealias Leg = (a: (Double, Double), k: (Double, Double), t: (Double, Double))
    let nearLegs: [Leg] = [
        ((38, 34), (50, 24), (59, 43)), ((36, 34), (42, 20), (51, 43)), ((33, 34), (26, 19), (21, 43)), ((31, 35), (13, 19), (2, 43)),
    ]
    let farLegs: [Leg] = [
        ((38, 35), (48, 29), (55, 43)), ((35, 35), (40, 28), (46, 43)), ((32, 36), (27, 31), (29, 43)), ((30, 36), (16, 28), (10, 43)),
    ]
    func leg(_ l: Leg, _ i: Int, near: Bool) {
        let lifted = p.step >= 0 && (i + (near ? 0 : 1)) % 2 == p.step
        let knee = (l.k.0, l.k.1 - (lifted ? 1 : 0))
        var tip = (l.t.0 + (lifted ? 1 : 0), l.t.1 - (lifted ? 2 : 0))
        if curl > 0 {
            // Hanging, the legs curl in under her, the tips drawn back toward the knees, twitching.
            let twitch: Double = sin(p.lt * 9 + Double(i) * 1.7 + (near ? 0 : 0.9))
            let tucked = (knee.0 + (tip.0 - knee.0) * 0.35, knee.1 + 6 + twitch)
            tip = (tip.0 + (tucked.0 - tip.0) * curl, tip.1 + (tucked.1 - tip.1) * curl)
        }
        let col = near ? body : far
        line(c, l.a.0, l.a.1, knee.0, knee.1, col, 1.3)
        line(c, knee.0, knee.1, tip.0, tip.1, col, 0.95)
        c.px(Int(knee.0), Int(knee.1), near ? light : C(0x5E5048))
    }
    // Fighting (not walking), the front pair rear up over her head, their tips following the swing but kept over her
    // own fangs (x 46 at most), clear of whoever she fights: the 75% hobbits stand only a few pixels further on.
    let rearing = p.walking ? nil : p.melee
    func reared(_ a: Double, near: Bool) -> Leg {
        let dir: Double = min(60, max(-70, 20 + 0.6 * wrapped(a)))
        let knee: (Double, Double) = near ? (42, 22) : (40, 25)
        let u = unit(dir), len: Double = near ? 6 : 5
        return (near ? (38, 34) : (38, 35), knee, (min(46, knee.0 + u.x * len), knee.1 + u.y * len))
    }
    for (i, l) in farLegs.enumerated() { leg(i == 0 ? rearing.map { reared($0, near: false) } ?? l : l, i, near: false) }
    c.oy += p.breathe
    // The abdomen: a great bulb, shaded, with the pale mark on its back and a few bristles.
    c.ellipse(16, 31, 13, 9, dark)
    c.ellipse(15, 30, 12, 8, body)
    c.ellipse(11, 26, 5, 2, light)
    c.pattern(9, 24, [
        ".MMMMMMM.",
        "..MMMMM..",
        "...MMM...",
        "....M....",
        "...MMM...",
        "..MMMMM..",
        ".MMMMMMM.",
    ], ["M": mark])
    // Lit along the top of the bulb, and coarse bristles in short strokes swept back along its curve.
    c.rect(15, 23, 6, 1, far); c.rect(21, 24, 2, 1, far)
    for (x, y, dx, dy) in [(4, 27, -1, 1), (3, 32, -1, 0), (5, 36, -1, 1), (25, 25, 1, -1), (19, 22, 1, -1), (7, 24, -1, 0)] {
        c.px(x, y, bristle); c.px(x + dx, y + dy, bristle)
    }
    // The front body; the near legs on it; then the head over their roots.
    c.ellipse(34, 34, 7, 5, body)
    c.rect(29, 31, 8, 1, light)
    c.oy -= p.breathe
    for (i, l) in nearLegs.enumerated() { leg(i == 0 ? rearing.map { reared($0, near: true) } ?? l : l, i, near: true) }
    if rearing != nil {
        for (i, ta) in p.trail.enumerated() {                                   // the forelegs' smear
            let r = reared(ta, near: true)
            line(c, r.k.0, r.k.1, r.t.0, r.t.1, C(0x6A5E56, 0.35 / Double(i + 1)), 0.7)
        }
    }
    c.oy += p.breathe
    c.ellipse(41, 34, 4, 4, body)
    // The fangs, curved, pale at the tips; flexing with a swing.
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() { drawFangs(c, spread: fangSpread(ta), alpha: 0.35 / Double(i + 1)) }
        drawFangs(c, spread: fangSpread(a))
        if let prev = p.trail.first, fangSpread(prev) > fangSpread(a) + 0.2 {     // snapping shut: a flash of the bite
            line(c, 47, 38, 49, 37.5, C(0xF4F0E0, 0.5), 0.35); line(c, 47, 40, 49, 40.5, C(0xF4F0E0, 0.5), 0.35)
        }
    } else if let f = hang?.fangs, f > 0 {
        drawFangs(c, spread: f)
    } else {
        c.pattern(41, 37, [".F..F", "F..F.", "F..F.", "M..M."], ["F": C(0x5A4A40), "M": mark])
    }
    // The eyes: two big ones and a cluster of small, glinting.
    let glint: Double = 0.7 + 0.3 * sin(p.lt * 2.7)
    c.rect(40, 31, 2, 2, eye); c.rect(43, 31, 2, 2, eye)
    for (x, y) in [(39, 33), (42, 30), (45, 33), (42, 33), (38, 31)] { c.px(x, y, eye.alpha(0.85)) }
    c.px(40, 31, white.alpha(glint)); c.px(43, 31, white.alpha(glint))
}

/// Shellob on her thread `s` through her signature: how many pixels she's lifted off the floor (50 is out of sight
/// above the canvas), how far her legs are curled in (0…1) and her fangs spread (0…1).
private func shelobHang(_ s: Double, lt: Double) -> (lift: Double, curl: Double, fangs: Double, alpha: Double, thread: Double) {
    let dangle = 12.0
    var lift: Double, curl: Double = 1, fangs: Double = 0, alpha: Double = 1
    // The thread shoots up to the top of the screen first, and is reeled in at the very end.
    let thread = min(1, max(0, s / 0.03)) * (1 - smooth(max(0, (s - 0.94) / 0.06)))
    switch s {
    case ..<0.02:
        lift = 0; curl = 0
    case ..<0.12:                                                               // up the thread, fading out on the way
        let k = (s - 0.02) / 0.1
        lift = 50 * k * k; curl = min(1, k * 3); alpha = 1 - smooth(min(1, k * 1.6))
    case ..<0.2:
        lift = 50; alpha = 0                                                    // gone, the thread still hanging there
    case ..<0.27:                                                               // dropping from above, fading back in
        let k = (s - 0.2) / 0.07
        lift = 50 - (50 - dangle + 5) * k * k
        fangs = 1; alpha = smooth(min(1, k * 2))
    case ..<0.36:                                                               // bouncing on the end of the thread
        let k = (s - 0.27) / 0.09
        lift = dangle - 5 * cos(k * .pi * 1.5) * (1 - k)
        fangs = 1
    case ..<0.62:                                                               // dangling, bobbing
        lift = dangle + sin(lt * 2.4)
        fangs = s < 0.45 ? 1 - (s - 0.36) / 0.09 : 0
    case ..<0.72:                                                               // climbing a little way back up, pull by pull
        let k = (s - 0.62) / 0.1
        lift = dangle + 2 * (k * 4).rounded(.down) + 2 * smooth(frac(k * 4) * 2)
    default:                                                                    // let down to the floor, legs reaching out
        let k = min(1, (s - 0.72) / 0.22)
        lift = (dangle + 8) * (1 - smooth(k)); curl = 1 - smooth((k - 0.4) / 0.6)
    }
    return (lift, curl, fangs, alpha, thread)
}

/// Shellob's signature as whoever places her draws it (`Persona.climb`): risen on her thread from the top of her back,
/// faded out on the way up and back in on the way down, the thread up to the top of the screen. The bobbing runs on
/// the move's own clock (`s` × its length).
private let shelobClimb = Climb(
    from: (16, 22),
    rise: { s in shelobHang(s, lt: s * 3.6).lift },
    alpha: { s in shelobHang(s, lt: s * 3.6).alpha },
    thread: { s in shelobHang(s, lt: s * 3.6).thread })

/// How far Shellob's fangs are spread at swing angle `a`: 1 wide open (the weapon raised, winding up), 0 at rest,
/// -1 snapped shut (the strike, forward and down).
private func fangSpread(_ a: Double) -> Double {
    let open: Double = min(1, max(0, (-wrapped(a) - 10) / 90))
    return open * 2 - 1
}

/// Shellob's two fangs, curving down from under her eyes to pale tips, `spread` (-1…1) apart: at 0 as they hang at
/// rest, at 1 curled out wide, at -1 the tips crossed together.
private func drawFangs(_ c: PixelCanvas, spread s: Double, alpha: Double = 1) {
    let fang = C(0x5A4A40, alpha), tip = C(0xC8C0A8, alpha)
    for (root, out) in [(42.0, -1.0), (45.0, 1.0)] {
        let mid: Double = root - 1 + out * s, end: Double = root - 1 + out * 1.5 * s
        c.px(Int(root), 37, fang)
        c.px(Int(mid.rounded()), 38, fang)
        c.px(Int(((mid + end) / 2).rounded()), 39, fang)
        c.px(Int(end.rounded()), 40, tip)
    }
}

/// An angle in degrees brought into -180…180 (the kata's twirl runs past a full turn).
private func wrapped(_ a: Double) -> Double {
    var w: Double = a.truncatingRemainder(dividingBy: 360)
    if w > 180 { w -= 360 } else if w <= -180 { w += 360 }
    return w
}

// MARK: - Shared helpers

/// The angles a heavy swing smears through: from now back past `trail`'s last angle by half as far again, so the smear
/// is longer than a light blade's (the weapon looks slower, heavier). Empty when it isn't being swung fast.
private func heavySmear(_ now: Double, _ trail: [Double]) -> [Double] {
    guard let last = trail.last else { return [] }
    let end: Double = last + (last - now) * 0.5
    let n = max(2, Int((abs(end - now) / 5).rounded()))
    return (1...n).map { (i: Int) -> Double in now + (end - now) * Double(i) / Double(n) }
}

/// The idle habit playing now, if this pose is the one it's played in (idle, standing, not fighting).
private func idlePlay(_ p: Pose) -> HabitPlay? {
    guard !p.walking, p.mode == .idle, let h = idleHabit else { return nil }
    switch p.role { case .none, .rest: return h; default: return nil }
}

/// Smoothstep: 0→1 eased at both ends.
private func smooth(_ x: Double) -> Double {
    let u = min(1, max(0, x))
    return u * u * (3 - 2 * u)
}

/// Draws `art` on a scratch canvas (same offsets as `c`), mirrors it about the column line `aboutX` (canvas units)
/// with `flipHorizontally` and a shift, and copies it onto `c`: the character turned round to face the other way.
private func mirrored(_ c: PixelCanvas, aboutX: Double, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    s.flipHorizontally()                                                         // column k lands on w - 1 - k
    s.shift(dx: Int((2 * aboutX).rounded()) - c.w, dy: 0)                        // … and then on 2 aboutX - 1 - k
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    defer { c.ox = ox; c.oy = oy; c.baseY = by }
    c.paste(s)
}

private let clear = C(0x000000, 0)

/// Boots (or wraps) over the bottom `rows` of each leg, and a bit of the folded foot when sitting.
private func drawBoots(_ c: PixelCanvas, _ step: Int, _ col: Px, rows: Int = 2) {
    if seatedPose {
        for lx in [19, 23, 31, 35] { c.rect(lx + 1, 38, 2, 2, col) }
        return
    }
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        let bottom = step >= 0 && i % 2 == step ? 42 : 43
        c.rect(lx, bottom - rows + 1, 2, rows, col)
    }
}

private func unit(_ degrees: Double) -> (x: Double, y: Double) {
    let r: Double = degrees * .pi / 180
    return (cos(r), sin(r))
}

/// A solid pixel line (no glow), `r` its half-width.
private func line(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.7) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: clear, coreR: r, glowR: r + 0.1)
}
