import Foundation

// Villains: The Nightmare Before Christmas. Halloween Town's scary residents: Ooogie Boogie, the huge burlap sack full
// of bugs; Lok, Shok and Barrell, the trick-or-treaters in their masks; Dr. Finkelclawd in his wheelchair; the
// Wolfclawd; the Tear-Away Clown on his unicycle; and the Halloween Witch on her broom.

let burtonVillains2: [BurtonVillain: Persona] = [
    .ooogieBoogie: Persona(name: "Ooogie Boogie", weapon: .blaster, shot: .thrown(C(0xF4F2EA)), canSit: false,
                           muzzle: (50, 25), bulk: 10, headTop: 7, signature: 4.0, callout: "Well, well, well…",
                           draw: drawOoogieBoogie),
    .lok: Persona(name: "Lok", weapon: .saber, pivot: kidHand, headTop: 23, signature: 2.8, draw: drawLok),
    .shok: Persona(name: "Shok", weapon: .saber, pivot: kidHand, headTop: 15, signature: 2.8, draw: drawShok),
    .barrell: Persona(name: "Barrell", weapon: .blaster, shot: .thrown(C(0x6AD04A)), muzzle: (41, 30), headTop: 24,
                      signature: 2.8, draw: drawBarrell),
    .drFinkelclawd: Persona(name: "Dr. Finkelclawd", weapon: .blaster, shot: .thrown(C(0x6AD04A)), canSit: false,
                            muzzle: (43, 25), headTop: 20, signature: 3.2, draw: drawFinkelclawd),
    .wolfclawd: Persona(name: "The Wolfclawd", weapon: .saber, bulk: 3, headTop: 13, signature: 3.0, draw: drawWolfclawd),
    .tearAwayClown: Persona(name: "The Tear-Away Clown", weapon: .none, canSit: false, headTop: 14, signature: 3.2,
                            draw: drawTearAwayClown),
    .halloweenWitch: Persona(name: "The Halloween Witch", weapon: .lightning, motion: .fly,
                             magic: Magic(core: C(0xFFE0B0), glow: C(0xFF7A1A)), pivot: witchHand, headTop: 9,
                             signature: 3.2, callout: "Hee hee hee!", draw: drawHalloweenWitch),
]

/// The trick-or-treaters' hand: their pitchfork and broom swing from there.
private let kidHand = (x: 36.5, y: 34.5)
/// The Witch's raised hand: her lightning leaves from there (raised by `armRaise`).
private let witchHand = (x: 42.5, y: 30.5)

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

// MARK: - Ooogie Boogie

/// The bugs' colours, shell and shine: green, purple, orange, blue, yellow.
private let bugColours: [(Px, Px)] = [(C(0x3A8A1A), C(0xB8F060)), (C(0x7A3AB0), C(0xD8A8FF)), (C(0xC8581A), C(0xFFB060)),
                                      (C(0x2A5AC8), C(0x9AC8FF)), (C(0xC8A01A), C(0xFFF08A))]

/// Ooogie Boogie: the biggest thing in Halloween Town, a huge sack of pale burlap, its tied top flopping over like a
/// cap, stitched seams down it, two dark slanted holes for eyes and a wide dark stitched grin; stubby sack arms and
/// four stumpy feet. Bugs keep falling out of his seams, in every colour, and scuttling off. He rolls dice at you.
/// Signature: he shakes the dice in his fist and rolls them along the floor, then throws his head back laughing as a
/// seam bulges and a bug pops out.
private func drawOoogieBoogie(_ c: PixelCanvas, _ p: Pose) {
    let sack = C(0xC8B888), sackD = C(0xA0905E), sackDD = C(0x7A6C44), stitch = C(0x4A3E28), hole = C(0x1A160E)
    let sig = p.signature
    let shaking = sig.map { $0 > 0.06 && $0 < 0.4 } ?? false
    let rolling = sig.map { $0 >= 0.4 && $0 < 0.95 } ?? false
    let laughing = sig.map { $0 >= 0.62 && $0 < 0.95 } ?? false

    // Four stumpy feet.
    if !seatedPose {
        for (i, lx) in [14, 21, 33, 40].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, lifted ? 39 : 40, 4, 4, sack); c.rect(lx, lifted ? 42 : 43, 4, 1, sackDD)
        }
    }
    c.oy += p.breathe + (laughing ? (Int(p.t * 10) % 2) : 0)
    // The sack: a bell shape, wider than anyone, its burlap weave picked out.
    for y in 12...41 {
        let k = Double(y - 12) / 29
        let hw = Int((7 + 13 * sin(min(1, k * 1.25) * .pi / 2) - (y > 37 ? Double(y - 37) * 1.5 : 0)).rounded())
        for x in (28 - hw)..<(28 + hw) {
            let edge = x >= 28 + hw - 2
            c.px(x, y, edge ? sackD : ((x * 2 + y * 3) % 7 == 0 ? sackD : sack))
        }
    }
    // The tied top flopping over to one side like a cap.
    c.pattern(20, 5, ["......SSSSS....", "....SSSSSSSSS..", "...SSSSSSSSSSS.", "..SSSSSSdSSSSSS", ".SSSSSSSdSSSSSS",
                      "SSSSSSSSdSSSSS.", "....dddddddd...", "....SSSSSSSS..."], ["S": sack, "d": sackDD])
    c.pattern(33, 9, ["SSS..", ".SSSS", "..SSS", "...SS"], ["S": sackD])
    // The seams: one down his side, one across near the bottom, cross-stitched.
    for y in stride(from: 15, through: 38, by: 2) { c.px(13 + (y - 15) / 6, y, stitch); c.px(14 + (y - 15) / 6, y, stitch) }
    for x in stride(from: 12, through: 44, by: 3) { c.px(x, 37, stitch); c.px(x + 1, 36, stitch) }
    // The face: slanted hollow eyes and the wide stitched grin, gaping when he laughs.
    c.pattern(18, 18, ["HHHH.......HHHH.", ".HHHHH...HHHHH..", "..HHHH...HHHH...", "...HH.....HH...."], ["H": hole])
    if laughing {
        c.pattern(16, 25, ["HHHHHHHHHHHHHHHHHHHH", ".HHHHHHHHHHHHHHHHHH.", "..HHHHHHHHHHHHHHHH..", "....HHHHHHHHHHHH....",
                           "......HHHHHHHH......"], ["H": hole])
        for x in stride(from: 18, through: 34, by: 3) { c.rect(x, 24, 1, 3, stitch) }
    } else {
        c.pattern(16, 26, ["H..................H", ".HHHHHHHHHHHHHHHHHH.", "..HHHHHHHHHHHHHHHH..", "....HHHHHHHHHHHH...."],
                  ["H": hole])
        for x in stride(from: 18, through: 34, by: 3) { c.rect(x, 25, 1, 4, stitch) }
    }
    // Stubby arms; the dice in his right fist, shaken in the signature, raised to throw in a fight.
    c.rect(6, 27, 3, 6, sack); c.rect(5, 32, 4, 3, sack)
    let dice = { (x: Int, y: Int) in
        c.rect(x, y, 4, 4, C(0xF4F2EA)); c.px(x + 1, y + 1, hole); c.px(x + 2, y + 2, hole)
        c.rect(x + 3, y + 4, 4, 4, C(0xE4E2DA)); c.px(x + 4, y + 5, hole); c.px(x + 5, y + 6, hole); c.px(x + 4, y + 6, hole)
    }
    if shaking {
        let j = Int(p.t * 14) % 2
        c.rect(46, 20 + j, 4, 8, sack); c.rect(45, 17 + j, 6, 4, sack); dice(47, 13 + j)
    } else if rolling, let s = sig {
        c.rect(46, 26, 4, 6, sack)
        let k = ramp(s, 0.4, 0.62)
        let x = 50 + Int(k * 14), y = 34 + Int(abs(sin(k * .pi * 3)) * -6) + 4
        dice(x, y)
    } else if p.fire != nil || p.ready || p.gunLift > 0 {
        c.oy += p.gunY
        c.rect(46, 22, 4, 8, sack); dice(48, 18)
    } else {
        c.rect(46, 27, 4, 6, sack); c.rect(46, 32, 5, 3, sack)
    }
    // Bugs: one pops out of the seam as he laughs; and all the time, bugs of every colour drop out of him and scuttle off.
    if laughing, let s = sig {
        let k = ramp(s, 0.62, 0.8)
        let col = bugColours[1]
        burtonBeetle(c, x: 14 - Int(k * 6), y: 24 + Int(k * 18), step: Int(p.t * 16) % 2 == 0, left: true, shell: col.0, shine: col.1)
    }
    c.oy -= p.breathe
    for i in 0..<3 {
        let period = 3.6, k = (p.lt / period + Double(i) / 3).truncatingRemainder(dividingBy: 1)
        let n = Int(p.lt / period + Double(i) / 3) + i * 7
        let col = bugColours[n % bugColours.count], left = n % 2 == 0
        let sx = left ? 15 : 41, sy = 18 + (n * 7) % 16
        let x: Int, y: Int
        if k < 0.15 { x = sx; y = sy + Int(k / 0.15 * Double(43 - sy)) }
        else { x = sx + (left ? -1 : 1) * Int((k - 0.15) / 0.85 * 26); y = 43 }
        burtonBeetle(c, x: x, y: y, step: Int(p.t * 16) % 2 == 0, left: left, shell: col.0, shine: col.1)
    }
}

// MARK: - The trick-or-treaters

/// A kid: a 14×9 Clawd on short legs, the body at (21, 30), dressed in `body`; applies the breathing bob.
private func kid(_ c: PixelCanvas, _ p: Pose, body: Px, shade: Px, leg: Px, shoe: Px) {
    if seatedPose {
        for lx in [22, 25, 30, 33] { c.rect(lx - 1, 37, 3, 2, leg) }
    } else {
        for (i, lx) in [22, 25, 30, 33].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, 39, 2, lifted ? 3 : 4, leg); c.rect(lx, lifted ? 41 : 42, 2, 1, shoe)
        }
    }
    c.oy += p.breathe
    c.rect(21, 30, 14, 9, body); c.rect(21, 38, 14, 1, shade); c.rect(34, 30, 1, 9, shade)
}

/// A kid's mask on its stick, over the face (`up` 0) or pushed up off it (`up` up to 1).
private func kidMask(_ c: PixelCanvas, _ rows: [String], _ pal: [Character: Px], up: Double) {
    c.pattern(21, 30 - rows.count + 6 - Int(up * 8), rows, pal)
}

/// How far the mask is pushed up in a kid's signature: up, held, back down.
private func maskUp(_ sig: Double?) -> Double {
    guard let s = sig else { return 0 }
    return min(ramp(s, 0.06, 0.22), 1 - ramp(s, 0.78, 0.94))
}

/// A melee prop along `angle` from the kid's hand: a shaft and whatever's on its end.
private func kidPole(_ c: PixelCanvas, angle: Double, trail: [Double], shaft: Px, length: Double) -> (x: Double, y: Double) {
    for (i, a) in trail.enumerated() {
        let e = burtonReach(kidHand, a, length)
        c.glowLine(kidHand.x, kidHand.y, e.x, e.y, core: C(0xE8E8DC), glow: C(0xE8E8DC), coreR: 0.4, glowR: 1.4, strength: 0.25 / Double(i + 1))
    }
    let s = burtonReach(kidHand, angle, -2), e = burtonReach(kidHand, angle, length)
    burtonLine(c, s.x, s.y, e.x, e.y, shaft, 0.55)
    return e
}

/// Lok: the little devil, in a red suit with a pointy tail, his red devil mask with horns and yellow eyes over his
/// face, and a pitchfork. Signature: he pushes the mask up on its stick and grins a wicked grin underneath.
private func drawLok(_ c: PixelCanvas, _ p: Pose) {
    let red = C(0xC8262A), redD = C(0x8E1418), skin = C(0xF0C8A8)
    let up = maskUp(p.signature)
    kid(c, p, body: red, shade: redD, leg: red, shoe: C(0x1A1A1E))
    c.pattern(14, 35, ["T......", ".TT....", "..TTTTT", "TT....."], ["T": redD])   // the tail, its arrow tip
    // His face under the mask: a wicked grin.
    c.rect(23, 31, 10, 5, skin); c.rect(24, 32, 2, 1, C(0x1A1A22)); c.rect(30, 32, 2, 1, C(0x1A1A22))
    c.pattern(24, 34, ["K......K", ".KKKKKK."], ["K": C(0x5A1A1A)])
    kidMask(c, ["H............H", "HH..........HH", ".HMMMMMMMMMMH.", "MMMMMMMMMMMMMM", "MMYYMMMMMMYYMM", "MMMYMMMMMMYMMM",
                "MMMMMMMMMMMMMM", "MMMKKKKKKKKMMM", ".MMMMMMMMMMMM."], ["H": C(0x5A1A1A), "M": C(0xA81E22), "Y": C(0xF0D040),
                "K": C(0x3A0A0A)], up: up)
    if let a = p.melee {
        let e = kidPole(c, angle: a, trail: p.trail, shaft: C(0x5A3A22), length: 13)
        let side = (x: -sin(a * .pi / 180), y: cos(a * .pi / 180))
        for o in [-2.0, 0, 2] {
            let b = (x: e.x + side.x * o, y: e.y + side.y * o), t = burtonReach(b, a, 3)
            burtonLine(c, b.x, b.y, t.x, t.y, C(0x9A9AA8), 0.45)
        }
        burtonLine(c, e.x + side.x * 2, e.y + side.y * 2, e.x - side.x * 2, e.y - side.y * 2, C(0x9A9AA8), 0.45)
    } else {
        c.rect(36, 22, 1, 17, C(0x5A3A22)); c.pattern(34, 19, ["S.S.S", "S.S.S", "SSSSS"], ["S": C(0x9A9AA8)])
    }
}

/// Shok: the little witch, in a purple dress, her pale witch mask with a long nose under a tall crooked black hat,
/// and a broom. Signature: she pushes the mask up, cackling, and twirls the broom.
private func drawShok(_ c: PixelCanvas, _ p: Pose) {
    let purple = C(0x6A3A8A), purpleD = C(0x4A2466), skin = C(0xF0C8A8), hat = C(0x16141C)
    let up = maskUp(p.signature)
    kid(c, p, body: purple, shade: purpleD, leg: C(0x2A2A30), shoe: C(0x1A1A1E))
    c.rect(23, 31, 10, 5, skin); c.rect(24, 32, 2, 1, C(0x1A1A22)); c.rect(30, 32, 2, 1, C(0x1A1A22))
    c.pattern(25, 34, up > 0.5 ? ["KKKKKK", ".KKKK."] : [".KKKK."], ["K": C(0x5A1A1A)])
    // The hat stays on: tall, crooked, its tip bent over; under it, the mask.
    c.pattern(19, 15, ["..........H...", ".........HH...", "........HHH...", ".......HHHH...", "......HHHH....",
                       ".....HHHHH....", "....HHHHHH....", "....HHHHHHH...", "...HHHHHHHH...", "...HHHHHHHHH..",
                       "..HHHHHHHHHH..", "..HHHHHHHHHHH.", "HHHHHHHHHHHHHHHH"], ["H": hat])
    kidMask(c, ["..MMMMMMMMMM..", ".MMMMMMMMMMMM.", "MMKKMMMMMMKKMM", "MMMMMMNNMMMMMM", "MMMMMMMNNNMMMM", "MMMKKKKKKKKMMM",
                ".MMMMMMMMMMMM."], ["M": C(0xC8D8B8), "K": C(0x2A2A30), "N": C(0xA8B898)], up: up)
    let twirl = p.signature.map { $0 > 0.25 && $0 < 0.75 } ?? false
    let a = twirl ? p.t * 720 : p.melee
    if let a {
        let e = kidPole(c, angle: a, trail: twirl ? [] : p.trail, shaft: C(0x8A6A3A), length: 12)
        let b = burtonReach(e, a, 4), side = (x: -sin(a * .pi / 180), y: cos(a * .pi / 180))
        burtonTriangle(c, (e.x + side.x, e.y + side.y), (e.x - side.x, e.y - side.y), (b.x + side.x * 2.5, b.y + side.y * 2.5), C(0xC8A04A))
        burtonTriangle(c, (e.x + side.x, e.y + side.y), (b.x - side.x * 2.5, b.y - side.y * 2.5), (b.x + side.x * 2.5, b.y + side.y * 2.5), C(0xC8A04A))
    } else {
        c.rect(37, 24, 1, 15, C(0x8A6A3A)); c.pattern(35, 38, [".BBB.", "BBBBB", "B.B.B"], ["B": C(0xC8A04A)])
    }
}

/// Barrell: the round little skeleton, in green, his bone-white skull mask over his face, always with a lollipop. He
/// throws lollipops. Signature: he pushes the mask up and licks his lollipop.
private func drawBarrell(_ c: PixelCanvas, _ p: Pose) {
    let green = C(0x4A8A3A), greenD = C(0x2E6A26), skin = C(0xF0C8A8), bone = C(0xF0ECE0)
    let up = maskUp(p.signature)
    let licking = up > 0.6
    kid(c, p, body: green, shade: greenD, leg: green, shoe: C(0x1A1A1E))
    c.rect(20, 33, 16, 5, green)   // round
    c.rect(23, 31, 10, 5, skin); c.rect(24, 32, 2, 1, C(0x1A1A22)); c.rect(30, 32, 2, 1, C(0x1A1A22))
    c.pattern(26, 34, licking ? ["KPPK", ".PP."] : ["KKKK"], ["K": C(0x5A1A1A), "P": C(0xE87A8A)])
    c.pattern(22, 25, ["..HH..HHH..H", ".HHHHHHHHHHH", "HHHHHHHHHHHHH"], ["H": C(0x1E1E22)])   // a mop of dark hair
    kidMask(c, ["..BBBBBBBBBB..", ".BBBBBBBBBBBB.", "BBKKKBBBBKKKBB", "BBKKKBBBBKKKBB", "BBBBBBKKBBBBBB", "BKBKBKBKBKBKBB",
                ".BBBBBBBBBBBB."], ["B": bone, "K": C(0x1E1E22)], up: up)
    // The lollipop: licked, held, or raised to throw.
    let lolly = { (x: Double, y: Double) in
        burtonLine(c, x, y + 1.5, x, y + 6, C(0xF0ECE0), 0.45)
        burtonSpiralDisc(c, x, y, r: 2.6, C(0x6AD04A), C(0xF0F0E0), turn: 0)
    }
    if licking { lolly(31, 30); return }
    if p.fire != nil || p.ready || p.gunLift > 0 {
        c.oy += p.gunY
        c.rect(35, 30, 3, 3, green); lolly(39, 27)
        return
    }
    c.rect(35, 33, 3, 3, green); lolly(38, 31)
}

// MARK: - Dr. Finkelclawd

/// Dr. Finkelclawd: the mad scientist in his wheelchair, a white lab coat, round black goggles and a flat beak of a
/// mouth, the top of his head a lid on a hinge. He throws potion bottles. Signature: he flips the lid of his skull
/// open and scratches his brain.
private func drawFinkelclawd(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0xE8E8E0), coatD = C(0xC4C4BC), skin = C(0xE0DCD0), skinD = C(0xB8B4A8), metal = C(0x6A6E78)
    let sig = p.signature
    let lidK = sig.map { min(ramp($0, 0.08, 0.25), 1 - ramp($0, 0.8, 0.95)) } ?? 0
    let scratching = sig.map { $0 > 0.25 && $0 < 0.8 } ?? false
    // The wheelchair: a big spoked wheel, the seat, the footrest and the push handles.
    let wheel = (x: 24, y: 37)
    c.circle(wheel.x, wheel.y, 7, metal); c.circle(wheel.x, wheel.y, 6, C(0, 0))
    for k in 0..<56 {
        let a = Double(k) / 56 * 2 * .pi
        c.px(wheel.x + Int((cos(a) * 6.5).rounded()), wheel.y + Int((sin(a) * 6.5).rounded()), C(0x2A2A30))
    }
    for k in 0..<4 {
        let a = Double(k) / 4 * .pi + p.t * 0.5
        burtonLine(c, Double(wheel.x) - cos(a) * 6, Double(wheel.y) - sin(a) * 6, Double(wheel.x) + cos(a) * 6,
                   Double(wheel.y) + sin(a) * 6, metal, 0.35)
    }
    c.rect(18, 33, 20, 2, metal); c.rect(36, 35, 2, 6, metal); c.rect(35, 41, 6, 1, metal); c.circle(37, 43, 1, C(0x2A2A30))
    c.rect(15, 20, 2, 14, metal); c.rect(13, 20, 4, 1, metal)
    c.oy += p.breathe
    // Him: the coat over his body, sitting; goggles, the beak, and the lid of his head.
    c.rect(18, 22, 18, 12, skin); c.rect(35, 22, 1, 12, skinD)
    c.rect(18, 28, 18, 6, coat); c.rect(35, 28, 1, 6, coatD); c.pattern(24, 28, ["C....C", ".C..C."], ["C": coatD])
    c.pattern(20, 24, [".GG....GG.", "GKKG..GKKG", "GKKGGGGKKG", ".GG....GG."], ["G": metal, "K": C(0x101014)])
    c.pattern(33, 27, ["BBBBBBB", "bbbbbb."], ["B": C(0xD8C8A0), "b": C(0xB8A880)])
    // The lid: on, or hinged open at the back, the pink brain showing.
    if lidK > 0 {
        let lift = Int((lidK * 5).rounded())
        c.rect(19, 21, 16, 2, C(0xE8A0A8)); c.pattern(20, 21, [".b.b..b.b.b.", "b.b.bb.b..b."], ["b": C(0xC87888)])
        burtonLine(c, 19, 21, 19 + 9 * cos(Double(lift) / 5 * 1.3), 21 - 9 * sin(Double(lift) / 5 * 1.3), skin, 1.4)
    } else {
        c.rect(19, 20, 16, 2, skin); c.rect(19, 21, 16, 1, skinD)
    }
    // Arms: scratching his brain, a potion raised to throw, or hands in his lap.
    if scratching {
        let j = Int(p.t * 10) % 2
        burtonLine(c, 35, 29, 30, Double(20 + j), coat, 0.9); c.rect(28, 19 + j, 3, 2, skin)
        return
    }
    if p.fire != nil || p.ready || p.gunLift > 0 {
        c.oy += p.gunY
        c.rect(36, 26, 3, 3, coat)
        c.pattern(39, 21, [".K.", ".G.", "GGG", "GGG", "GGG"], ["K": C(0x5A3A22), "G": C(0x6AD04A)])
        return
    }
    c.rect(30, 31, 5, 2, coat); c.rect(29, 31, 2, 2, skin)
}

// MARK: - The Wolfclawd

/// The Wolfclawd: a werewolf in a tattered brown suit, grey-brown fur, pointed ears, a long snout with a black nose
/// and teeth, yellow eyes; claws. Signature: he throws his head back and howls at the moon.
private func drawWolfclawd(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0x7A6A5A), furD = C(0x5A4A3A), furL = C(0x9A8A78), suit = C(0x5A4430), suitD = C(0x3E2E20)
    let howling = p.signature.map { $0 > 0.1 && $0 < 0.9 } ?? false
    drawLegs(c, Look(leg: fur), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.px(lx, 43, C(0xE8E0D0)); c.px(lx + 1, 43, C(0xE8E0D0)) } }   // claws
    c.oy += p.breathe
    drawBody(c, Look(body: fur, shade: furD, arm: fur, eye: nil))
    // The tattered suit, ragged at the hem.
    c.rect(18, 31, 20, 6, suit); c.rect(37, 31, 1, 6, suitD)
    c.pattern(18, 37, ["SS.SSS.SS..SSS.SS.SS", "S...S...S...S...S..."], ["S": suit])
    c.pattern(25, 31, ["WW..WW", ".W..W."], ["W": furL])
    // The head: up, ears back and muzzle to the sky, when he howls; otherwise the snout out in front.
    if howling {
        c.pattern(20, 16, ["......EE.....", ".....EEE.....", "....FFFFFFF..", "...FFFFFFFFF.", "..FFFYFFFFFFF", "..FFFFFFFFFFF",
                           ".FFFFFFFFFFF.", "FFFFFFFFFFF..", "FFFFFFFFFF...", "FFFFFFFFFF..."], ["E": furD, "F": fur, "Y": C(0xF0D040)])
        c.pattern(29, 10, ["...N", "..FF", ".FFF", "FFFF", "FTFF", "FKKF", "FFF."], ["N": C(0x141418), "F": fur, "T": C(0xF0ECE0), "K": C(0x3A1A1A)])
        for k in 0..<3 {
            let f = (p.t * 1.2 + Double(k) / 3).truncatingRemainder(dividingBy: 1)
            let r = 2 + f * 6
            for s in -3...3 {
                let a = -1.2 + Double(s) * 0.18
                c.px(33 + Int((cos(a) * r).rounded()), 10 + Int((sin(a) * r).rounded()), C(0xF0ECE0, 1 - f))
            }
        }
    } else {
        c.pattern(18, 17, ["..EE......EE....", ".EEEE....EEEE...", ".FFFFFFFFFFFFF..", "FFFFFFFFFFFFFFF.", "FFFYFFFFFFYFFFF.",
                           "FFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFF", "FFFFFFFFFFFFFFFF", ".FFFFFFFFFFFFFF."],
                  ["E": furD, "F": fur, "Y": C(0xF0D040)])
        c.pattern(33, 21, ["FFFFFFFN", "FFFFFFFN", "TFTFTF..", "KKKKK..."], ["F": furL, "N": C(0x141418), "T": C(0xF0ECE0), "K": C(0x3A1A1A)])
    }
    // Claws: the arm swung along `p.melee`, three white claws at the end and their slashes.
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() {
            for o in [-1.5, 0, 1.5] {
                let s = burtonReach(Sprite.hand, ta, 6), e = burtonReach(Sprite.hand, ta + o * 6, 11)
                c.glowLine(s.x, s.y, e.x, e.y, core: C(0xF0ECE0), glow: C(0xF0ECE0), coreR: 0.3, glowR: 1, strength: 0.35 / Double(i + 1))
            }
        }
        let h = burtonReach(Sprite.hand, a, 5)
        burtonLine(c, Sprite.hand.x - 2, Sprite.hand.y, h.x, h.y, fur, 1.2)
        for o in [-1.0, 0, 1] {
            let e = burtonReach(h, a + o * 18, 3)
            burtonLine(c, h.x, h.y, e.x, e.y, C(0xF0ECE0), 0.45)
        }
    }
}

// MARK: - The Tear-Away Clown

/// The Tear-Away Clown: a pale clown riding a unicycle on the spot, a dark purple shirt with orange pom-poms, red tufts
/// of hair, a red nose and a little hat. He doesn't fight. Signature: he grabs his face and tears it right off, leaving
/// a dark hole where it was, holds it out, then claps it back on.
private func drawTearAwayClown(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0x4A2A5A), shirtD = C(0x341C42), face = C(0xF4F2EA), faceD = C(0xD4D2CA), red = C(0xD8242A)
    let sig = p.signature
    let tornK = sig.map { min(ramp($0, 0.12, 0.3), 1 - ramp($0, 0.75, 0.9)) } ?? 0
    // The unicycle: a spoked wheel turning, the post up to his seat, one pedal going round.
    let wheel = (x: 28, y: 39), spin = p.t * 4
    c.circle(wheel.x, wheel.y, 5, C(0x2A2A30)); c.circle(wheel.x, wheel.y, 3, C(0, 0))
    for k in 0..<36 {
        let a = Double(k) / 36 * 2 * .pi
        c.px(wheel.x + Int((cos(a) * 4).rounded()), wheel.y + Int((sin(a) * 4).rounded()), C(0x9A9AA8))
    }
    for k in 0..<3 {
        let a = spin + Double(k) / 3 * 2 * .pi
        burtonLine(c, Double(wheel.x), Double(wheel.y), Double(wheel.x) + cos(a) * 4, Double(wheel.y) + sin(a) * 4, C(0x9A9AA8), 0.3)
    }
    c.rect(27, 30, 2, 9, C(0x6A6E78))
    let pedal = (x: Double(wheel.x) + cos(spin) * 3, y: Double(wheel.y) + sin(spin) * 3)
    burtonLine(c, 26, 34, pedal.x, pedal.y, shirt, 0.9)
    let bob = Int((sin(spin * 2) * 0.6).rounded())
    c.oy += p.breathe + bob
    // His body on the seat: the purple shirt with pom-poms, his arms.
    c.rect(19, 22, 18, 11, shirt); c.rect(36, 22, 1, 11, shirtD)
    for y in [24, 27, 30] { c.rect(27, y, 2, 2, C(0xFF8A2A)) }
    c.rect(19, 32, 18, 1, C(0xFF8A2A))
    // The face, or where it was: a dark hole, the face held out in his hand.
    let hold = (x: 40 + Int(tornK * 6), y: 18 - Int(tornK * 2))
    if tornK > 0.2 {
        c.ellipse(28, 17, 6, 5, C(0x08080C))
        c.rect(37, 24, 3, 2, shirt); burtonLine(c, 37, 24, Double(hold.x), Double(hold.y + 4), shirt, 0.9)
    }
    let fx = tornK > 0.2 ? hold.x - 6 : 22, fy = tornK > 0.2 ? hold.y - 4 : 12
    c.pattern(fx, fy, ["...FFFFFF...", ".FFFFFFFFFF.", "FFFFFFFFFFFf", "FKKFFFFFKKFf", "FFFFFRRFFFFf", "FFFFRRRRFFFf",
                       "FFFFFRRFFFFf", "FKFFFFFFFKFf", ".FKKKKKKKKf.", "...FFFFFf..."],
              ["F": face, "f": faceD, "K": C(0x1A1A22), "R": red])
    // His hair tufts and little hat stay on his head.
    c.pattern(18, 13, ["RR...........RR..", "RRR.........RRRR.", ".RR..........RR.."], ["R": red])
    c.pattern(24, 8, ["...HH...", "..HHHH..", ".HHHHHH.", "HHHHHHHH"], ["H": C(0x1E1E26)])
    if tornK <= 0.2 { c.rect(37, 25, 3, 3, shirt); c.rect(16, 25, 3, 3, shirt) }
}

// MARK: - The Halloween Witch

/// The Halloween Witch: a green face with a long nose and chin, a tall crooked black hat with a buckle, a black dress,
/// and her broom. She flies about on it, and fights with forked orange lightning. Signature: she sits on the broom
/// and loops round in the air, cackling.
private func drawHalloweenWitch(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x7ABA5A), skinD = C(0x5A9A3A), dress = C(0x1E1A24), dressD = C(0x14101A), hat = C(0x16141C)
    let sig = p.signature
    let looping = sig.map { $0 > 0.1 && $0 < 0.9 } ?? false
    let riding = p.flying || looping
    if looping, let s = sig {
        let a = ramp(s, 0.1, 0.9) * 2 * .pi
        c.ox += Int((sin(a) * 8).rounded()); c.oy += Int(((cos(a) - 1) * 6).rounded())
    }
    if riding {
        // On the broom: its handle along under her, the bristles out behind.
        c.oy -= 2
        burtonLine(c, 8, 38, 48, 36, C(0x8A6A3A), 0.7)
        c.pattern(3, 34, ["BB.....", "BBBBBBB", "BBBBBBB", "BBBBBBB", "BB....."], ["B": C(0xC8A04A)])
        c.rect(20, 37, 3, 4, dress); c.rect(32, 37, 3, 4, dress); c.rect(20, 41, 4, 1, C(0x0A0A0E)); c.rect(32, 41, 4, 1, C(0x0A0A0E))
    } else {
        drawLegs(c, Look(leg: C(0x2A2A30)), step: p.step)
        burtonBoots(c, step: p.step, C(0x0A0A0E))
    }
    c.oy += p.breathe
    // The black dress, flaring a little.
    for y in 26...38 {
        let w = 20 + (y - 26) / 3 * 2
        c.rect(28 - w / 2, y, w, 1, dress); c.px(28 + w / 2 - 1, y, dressD)
    }
    // The green face: a long hooked nose, a pointed chin, a cackling mouth.
    let cackle = looping || p.zap == true
    c.pattern(20, 18, [
        "..FFFFFFFFFF.....",
        ".FFFFFFFFFFFF....",
        "FFFKFFFFFKFFFf...",
        "FFFFFFFFFFFFFNNN.",
        "FFFFFFFFFFFFNNNNN",
        cackle ? "FFFFKKKKKFFFf..N." : "FFFFFKKKFFFFf....",
        cackle ? ".FFFKKKKKFFf....." : ".FFFFFFFFFFf.....",
        "..FFFFFFFFf......",
        "....FFFFFf.......",
        ".....FFf.........",
    ], ["F": skin, "f": skinD, "K": C(0x1A1A22), "N": skinD])
    // Stringy dark hair, and the tall crooked hat with its buckle.
    c.pattern(17, 18, ["HH", "HHH", "HH.", "H..", "H.."].map { $0 }, ["H": C(0x2A2A30)])
    c.pattern(16, 3, [
        "................HH..",
        "..............HHHH..",
        ".............HHHH...",
        "............HHHH....",
        "...........HHHHH....",
        "..........HHHHHH....",
        ".........HHHHHHH....",
        "........HHHHHHHH....",
        ".......HHHHHHHHH....",
        "......HHHHHHHHHH....",
        ".....HHHHHHHHHHH....",
        ".....HHHHGGGHHHH....",
        ".....HHHHG.GHHHH....",
        ".....HHHHGGGHHHH....",
        "HHHHHHHHHHHHHHHHHHHH",
    ], ["H": hat, "G": C(0xD8B030)])
    // Her arms: the right hand raised, crackling with lightning, or holding the broom upright beside her.
    let raise = p.armRaise
    if p.zap != nil || raise > 0 {
        c.rect(37, 30 - raise, 3, 3, dress); c.pattern(40, 29 - raise, ["F.F", "FFF"], ["F": skin])
    } else if !riding {
        c.rect(37, 30, 3, 3, dress); c.rect(40, 18, 1, 22, C(0x8A6A3A))
        c.pattern(38, 39, [".BBB.", "BBBBB", "B.B.B"], ["B": C(0xC8A04A)])
    } else {
        c.rect(37, 33, 3, 3, dress)
    }
    c.rect(15, 31, 3, 3, dress)
}
