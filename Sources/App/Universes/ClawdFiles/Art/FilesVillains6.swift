import Foundation

// Villains: monsters of the week. Leonard Betts, the Great Mutato, the Wendigo, Mr. Chuckleteeth, Eve 6 and Virgil
// Incanto. Clawd in costume where there's a person to dress up; the Wendigo is all creature, on four legs. Creepy, but
// at teatime strength: nobody bleeds, and Leonard's spare head is a joke, not a wound.

let filesVillains6: [FilesVillain: Persona] = [
    .leonardBetts: Persona(name: "Leonard Betts", weapon: .saber, headTop: 21, signature: 3.6, callout: "I'm fine. Really.",
                           draw: drawLeonardBetts),
    .greatMutato: Persona(name: "The Great Mutato", weapon: .none, headTop: 17, signature: 4.0,
                          callout: "Peanut butter sandwich?", draw: drawGreatMutato),
    .wendigo: Persona(name: "The Wendigo", weapon: .saber, canSit: false, bulk: 8, headTop: 12, signature: 3.0,
                      callout: "Hrrrooo!", draw: drawWendigo),
    .chuckleteeth: Persona(name: "Mr. Chuckleteeth", weapon: .none, headTop: 18, signature: 3.4, callout: "Hee hee hee.",
                           draw: drawChuckleteeth),
    .eve6: Persona(name: "Eve 6", weapon: .lightning, magic: Magic(core: C(0xE8FFD8), glow: C(0x4ACB5A), jagged: false),
                   pivot: (45.0, 31.0), headTop: 20, signature: 3.6, callout: "We knew you'd come.",
                   draw: drawEve6),
    .virgilIncanto: Persona(name: "Virgil Incanto", weapon: .saber, headTop: 20, signature: 3.2, callout: "Charmed.",
                            draw: drawVirgilIncanto),
]

// MARK: - Shared bits

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// A line of `w`×`w` dots from (x0, y0) to (x1, y1).
private func seg(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, w: Int = 1) {
    let n = max(1, Int(max(abs(x1 - x0), abs(y1 - y0)).rounded(.up)))
    for k in 0...n {
        let f = Double(k) / Double(n)
        c.rect(Int((x0 + (x1 - x0) * f).rounded(.down)), Int((y0 + (y1 - y0) * f).rounded(.down)), w, w, col)
    }
}

/// An arm swung out at `angle` degrees from the right shoulder, ending in a fist (and whatever `hold` draws from it).
private func swingArm(_ c: PixelCanvas, angle: Double, sleeve: Px, fist: Px, alpha: Double = 1,
                      hold: ((Double, Double, Double) -> Void)? = nil) {
    let r = angle * .pi / 180
    let sx = 39.0, sy = 34.0
    let ex = sx + cos(r) * 6, ey = sy + sin(r) * 6
    seg(c, sx, sy, ex, ey, sleeve.alpha(alpha), w: 2)
    c.rect(Int(ex.rounded(.down)), Int(ey.rounded(.down)), 3, 3, fist.alpha(alpha))
    hold?(ex + 1, ey + 1, r)
}

/// A little music note: a filled head and a stem with a flag, at (x, y) for the head's corner.
private func note(_ c: PixelCanvas, _ x: Int, _ y: Int, _ col: Px) {
    c.rect(x, y, 3, 2, col); c.rect(x + 2, y - 4, 1, 4, col); c.px(x + 3, y - 4, col); c.px(x + 4, y - 3, col)
}

// MARK: - Leonard Betts

/// Leonard Betts: Clawd as a paramedic, in a navy uniform shirt with the blue star-of-life patch on the chest and a
/// white reflective band, navy trousers and black boots, his ginger hair receding. He fights with his fists. Signature:
/// his head comes off. The old one, hair and all, lifts up and away and fades like a shed skin, while a brand-new one
/// grows in underneath, smooth and shiny, eyes shut, then blinks open as if nothing happened.
private func drawLeonardBetts(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0x2A3550), shirtD = C(0x1C2438), band = C(0xDDE4EE), patch = C(0x3A7AD8)
    let hair = C(0xB8622E), hairL = C(0xD4803E)
    let sig = p.signature
    let shed = sig.map { ramp($0, 0.15, 0.6) } ?? 0          // the old head lifting off and fading
    let grow = sig.map { ramp($0, 0.2, 0.75) } ?? 1           // the new one coming in
    let blink = sig.map { $0 > 0.15 && $0 < 0.82 } ?? false   // eyes shut while it grows

    drawLegs(c, Look(leg: shirtD), step: p.step)
    drawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: shirt, eye: nil))
    // The uniform: the shirt, its reflective band and the patch.
    c.rect(18, 34, 20, 4, shirt); c.rect(37, 34, 1, 4, shirtD); c.rect(18, 37, 20, 1, shirtD)
    c.rect(18, 35, 20, 1, band)
    c.pattern(21, 33, [".P.", "PPP", ".P."], ["P": patch])

    // The face: the new head comes in shiny and pink-tinged; eyes shut until it's done.
    if sig != nil && grow < 1 {
        c.rect(18, 26, 20, 8, C(0xF0A88A, 0.45 * (1 - grow)))
        c.px(20, 27, C(0xFFFFFF, 0.7)); c.px(21, 27, C(0xFFFFFF, 0.5))
    }
    if blink { c.rect(22, 30, 2, 1, ink); c.rect(32, 30, 2, 1, ink) } else { c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink) }
    // The hair (the new head's comes back in as it grows).
    let hairRows = [
        "......HHhHHHHhHH......",
        "....HHHHHHhHHHHHHH....",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHH..........HHHHH.",
        ".HHH..............HHH.",
    ]
    c.pattern(17, 22, hairRows, ["H": hair.alpha(sig == nil ? 1 : grow), "h": hairL.alpha(sig == nil ? 1 : grow)])
    // The old head, lifting off: hair and a shell of face, rising and fading.
    if shed > 0 && shed < 1 {
        let lift = Int((shed * 12).rounded()), fade = 1 - shed
        c.pattern(17, 22 - lift, hairRows, ["H": hair.alpha(fade), "h": hairL.alpha(fade)])
        c.rect(18, 26 - lift, 20, 6, clawdOrange.alpha(0.8 * fade))
        c.rect(22, 29 - lift, 2, 3, ink.alpha(fade)); c.rect(32, 29 - lift, 2, 3, ink.alpha(fade))
    }

    c.rect(15, 33, 3, 3, shirt)
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() {
            swingArm(c, angle: ta, sleeve: shirt, fist: clawdOrange, alpha: 0.35 / Double(i + 1))
        }
        swingArm(c, angle: a, sleeve: shirt, fist: clawdOrange)
    } else {
        c.rect(38, 33, 3, 3, shirt); c.rect(38, 36, 3, 2, clawdOrange)
    }
}

// MARK: - The Great Mutato

/// The Great Mutato: a gentle, lumpy giant of a creature, Clawd under a rough brown hooded cloak, his face swollen into
/// lumps, one eye big and low and the other small and high, a lopsided, hopeful smile. He wants a friend more than a
/// fight, and only cheers from the side. Signature: he holds up a peanut-butter sandwich and sings, little notes floating
/// up from him as his head sways along.
private func drawGreatMutato(_ c: PixelCanvas, _ p: Pose) {
    let cloak = C(0x6A4E34), cloakD = C(0x4A3624), cloakL = C(0x84644A)
    let skin = C(0xD8B48A), lump = C(0xC09A72), lumpL = C(0xE8CCA4)
    let sig = p.signature
    let singing = sig.map { $0 > 0.1 && $0 < 0.92 } ?? false
    let sway = singing ? Int((sin(p.t * 4) * 1).rounded()) : 0

    drawLegs(c, Look(leg: cloakD), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0x2E2018))
    c.oy += p.breathe
    // The cloak, wider than the body, hanging in folds.
    c.rect(16, 30, 24, 8, cloak); c.rect(39, 30, 1, 8, cloakD); c.rect(16, 37, 24, 1, cloakD)
    for x in [20, 25, 31, 36] { c.rect(x, 32, 1, 6, cloakD) }
    c.rect(14, 33, 3, 3, cloak)
    // The head: the face swollen into lumps, bigger than plain Clawd's, under the hood.
    c.ox += sway
    c.rect(18, 22, 20, 12, skin)
    for (x, y, r) in [(20, 23, 3), (34, 22, 3), (30, 32, 2), (17, 28, 2), (38, 27, 2), (26, 21, 2)] {
        c.ellipse(x, y, r, r, lump); c.px(x - 1, y - 1, lumpL)
    }
    // The hood, round the top and down the sides.
    c.pattern(15, 16, [
        "......HHHHHHHHHHHH........",
        "....HHHHHHHHHHHHHHHHH.....",
        "..HHHHhHHHHHHHHHHhHHHHH...",
        ".HHHHHHHHHHHHHHHHHHHHHHH..",
        ".HHHHH.............HHHHHH.",
        "HHHH.................HHHH.",
        "HHH...................HHH.",
        "HHH...................HHH.",
        "HHH...................HHH.",
        "HHH...................HHH.",
        "HHHH.................HHHH.",
        ".HHH.................HHH..",
        ".HHH.................HHH..",
        ".HHHH...............HHHH..",
        "..HHH...............HHH...",
    ], ["H": cloak, "h": cloakL])
    // The eyes, mismatched: a big low one, a small high one; the lopsided smile (open while he sings).
    c.rect(21, 28, 3, 3, ink); c.px(22, 28, C(0xFFFFFF, 0.8))
    c.rect(32, 26, 2, 2, ink)
    if singing && Int(p.t * 3) % 2 == 0 {
        c.rect(25, 31, 5, 2, C(0x5A2A20)); c.rect(25, 31, 5, 1, C(0x3A1A14))
    } else {
        c.rect(24, 32, 6, 1, C(0x5A2A20)); c.px(30, 31, C(0x5A2A20))
    }
    c.ox -= sway

    if let s = sig, singing {
        // The sandwich held up proudly, and the notes floating off it.
        c.rect(38, 28, 3, 6, cloak)
        c.pattern(39, 23, ["BBBBBB", "pppppp", "BBBBBB"], ["B": C(0xE8C890), "p": C(0xB8742E)])
        for i in 0..<3 {
            let k = (s * 2 + Double(i) / 3).truncatingRemainder(dividingBy: 1)
            let x = 46 + i * 5 + Int((sin(k * 6 + Double(i)) * 2).rounded())
            note(c, x, 21 - Int(k * 14), C(0xFFF4D0, 1 - k * 0.8))
        }
        return
    }
    c.rect(38, 33, 3, 3, cloak)
}

// MARK: - The Wendigo

/// The Wendigo: a starved thing of the north woods on four long, bony legs, its grey-brown hide stretched over its
/// ribs, a long neck and a skull of a head, bone-white, with deep sockets lit by two pale eyes and great antlers
/// branching up off it. It strikes with a clawed foreleg. Signature: it rears up on its hind legs, throws its head back
/// and howls, its breath steaming in the cold.
private func drawWendigo(_ c: PixelCanvas, _ p: Pose) {
    let hide = C(0x4A443C), hideD = C(0x2E2A24), rib = C(0x6E665A), bone = C(0xE8E2D2), boneD = C(0xB8AE98)
    let antler = C(0xC8BCA0), eye = C(0xCFF4FF)
    let sig = p.signature
    let rear = sig.map { ramp($0, 0.05, 0.3) - ramp($0, 0.8, 0.95) } ?? 0
    let howl = sig.map { $0 > 0.3 && $0 < 0.8 } ?? false

    // Hind legs: long, bent back at the hock, hooves on the ground.
    let step = p.step
    for (i, lx) in [16, 21].enumerated() {
        let up = step >= 0 && i % 2 == step ? 1 : 0
        seg(c, Double(lx + 2), 34, Double(lx), 39, hide, w: 2)
        seg(c, Double(lx), 39, Double(lx + 1), Double(43 - up), hide, w: 2)
        c.rect(lx + 1, 43 - up, 2, 1, hideD)
    }
    c.oy += p.breathe
    // The body tips up as it rears: everything forward of the hips rises.
    let lift = Int((rear * 7).rounded())
    // The torso: long and lean, sagging between hips and shoulders, the ribs showing. Rearing, the back stays level
    // over the hips and the chest comes up steeply, the way a deer rears.
    func rise(_ x: Int) -> Int {
        let k: Double = max(0, Double(x - 26) / 14)
        return Int((k * Double(lift)).rounded())
    }
    for x in 16...40 {
        let top: Int = 29 - rise(x) + (x > 20 && x < 36 && lift == 0 ? 1 : 0)
        c.rect(x, top, 1, 6 + rise(x) / 2, hide)
        c.px(x, top + 5 + rise(x) / 2, hideD)
    }
    for x in stride(from: 24, through: 36, by: 3) {
        c.rect(x, 29 - rise(x) + 2, 1, 3, rib)
    }
    // Forelegs (lifted and clawing the air when it rears or fights).
    let shoulderY = 31.0 - Double(lift)
    if p.melee != nil {
        seg(c, 35, shoulderY + 2, 34, 43, hide, w: 2); c.rect(34, 43, 2, 1, hideD)   // the striking one comes last
    } else if lift > 3 {
        // Both forelegs bent at the knee and tucked up in front of the chest, the claws hooked.
        for (i, dx) in [0.0, -4.0].enumerated() {
            let sx: Double = 38 + dx, sy: Double = shoulderY + 3 + Double(i)
            let kx: Double = sx + 4, ky: Double = sy + 4
            let px: Double = kx + 3, py: Double = ky - 3
            seg(c, sx, sy, kx, ky, i == 0 ? hide : hideD, w: 2)
            seg(c, kx, ky, px, py, i == 0 ? hide : hideD, w: 2)
            let cx = Int(px.rounded()), cy = Int(py.rounded())
            c.px(cx + 2, cy - 1, bone); c.px(cx + 2, cy + 1, bone); c.px(cx + 3, cy, boneD)
        }
    } else {
        for (i, lx) in [34, 39].enumerated() {
            let up = step >= 0 && i % 2 != step ? 1 : 0
            seg(c, Double(lx), shoulderY + 3, Double(lx), Double(43 - up), hide, w: 2)
            c.rect(lx, 43 - up, 2, 1, hideD)
        }
    }
    // The neck and the skull of a head, held forward, or thrown back to howl.
    let hx = 44, hy = 22 - lift - (howl ? 3 : 0)
    seg(c, 39, Double(30 - lift), Double(hx), Double(hy + 4), hide, w: 3)
    c.pattern(hx - 1, hy, howl ? [
        ".BBBBB..",
        "BBBBBBB.",
        "BEBBBBBB",
        "BBBBBBBB",
        ".BBb.bBB",
        "..bb..bb",
        "......b.",
    ] : [
        ".BBBBB...",
        "BBBBBBBB.",
        "BEBBBBBBB",
        "BBBBBBBBB",
        ".BBBbbbbB",
        "..b.b.b..",
    ], ["B": bone, "b": boneD, "E": C(0x16161A)])
    c.px(hx, hy + 2, eye)
    // The antlers: two branching tines going up and back.
    for (bx, lean) in [(hx + 1, -1), (hx + 4, 1)] {
        seg(c, Double(bx), Double(hy), Double(bx + lean * 2), Double(hy - 8), antler)
        seg(c, Double(bx + lean), Double(hy - 4), Double(bx + lean * 4), Double(hy - 7), antler)
        seg(c, Double(bx + lean * 2), Double(hy - 8), Double(bx + lean * 4), Double(hy - 11), antler)
        seg(c, Double(bx + lean * 2), Double(hy - 8), Double(bx), Double(hy - 11), antler)
    }
    // The striking foreleg, over the neck so the swing shows: long, pale at the joints, bone claws raking.
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() {
            let r = ta * .pi / 180
            seg(c, 39, shoulderY, 39 + cos(r) * 11, shoulderY + sin(r) * 11, boneD.alpha(0.4 / Double(i + 1)), w: 2)
        }
        let r = a * .pi / 180
        let fx: Double = 39 + cos(r) * 11, fy: Double = shoulderY + sin(r) * 11
        seg(c, 39, shoulderY, fx, fy, rib, w: 2)
        c.px(Int((39 + cos(r) * 6).rounded()), Int((shoulderY + sin(r) * 6).rounded()), boneD)
        for sp in [-0.6, 0.0, 0.6] {
            seg(c, fx + 0.5, fy + 0.5, fx + 0.5 + cos(r + sp) * 4, fy + 0.5 + sin(r + sp) * 4, bone)
        }
    }
    if howl {
        // Breath steaming up out of the open jaw.
        let k = (p.t * 0.9).truncatingRemainder(dividingBy: 1)
        for i in 0..<3 {
            let kk = (k + Double(i) / 3).truncatingRemainder(dividingBy: 1)
            c.rect(hx + 6 + Int(kk * 4), hy - 1 - Int(kk * 8), 2, 1, C(0xE8EEF4, 0.6 * (1 - kk)))
        }
    }
}

// MARK: - Mr. Chuckleteeth

/// Mr. Chuckleteeth: Clawd in drab grey-green coveralls with his face behind a cracked old clown mask, chalk white with
/// a red bulb nose, blue diamonds round painted eyes, tufts of orange hair either side and a huge grin of teeth that
/// never changes. No weapon: he only watches, and cheers from the back. Signature: his head tilts, slowly, all the way
/// over, and the eyes behind the mask glint red.
private func drawChuckleteeth(_ c: PixelCanvas, _ p: Pose) {
    let overall = C(0x5A6450), overallD = C(0x424A3A), mask = C(0xF0EEE6), maskD = C(0xC8C4B8)
    let tuft = C(0xE8682A), tuftD = C(0xB8481E), nose = C(0xD82A2A), diamond = C(0x3A6AD8)
    let sig = p.signature
    let tilt = sig.map { ramp($0, 0.1, 0.45) - ramp($0, 0.75, 0.95) } ?? 0
    let glint = sig.map { $0 > 0.45 && $0 < 0.75 } ?? false

    drawLegs(c, Look(leg: overall), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0x2A2A24))
    c.oy += p.breathe
    drawBody(c, Look(arm: overall, eye: nil))
    // The coveralls: zip, pocket, buttoned straps.
    c.rect(18, 33, 20, 5, overall); c.rect(37, 33, 1, 5, overallD); c.rect(18, 37, 20, 1, overallD)
    c.rect(28, 33, 1, 5, overallD); c.rect(21, 35, 4, 2, overallD)

    // The mask's head, tilted over in the signature (the whole thing shifts a step at a time and leans).
    let lean = Int((tilt * 3).rounded())
    let mx = 18 + lean, my = 21 + lean / 2
    // Where the tilt uncovers the side of his head, the coveralls' hood shows, not Clawd.
    if lean > 0 { c.rect(18, 26, lean, 8, overallD); c.rect(18, 26, 1, 8, C(0x343A2E)) }
    // Hair tufts out from either side.
    c.pattern(mx - 4, my + 2, ["TTt.", "TTTt", ".TTt", "TTt."], ["T": tuft, "t": tuftD])
    c.pattern(mx + 20, my + 2 - lean, [".tTT", "tTTT", "tTT.", ".tTT"], ["T": tuft, "t": tuftD])
    // The mask: chalk white, cracked, diamonds round the eyes, red nose, and the grin.
    c.rect(mx, my, 20, 12, mask); c.rect(mx + 19, my, 1, 12, maskD)
    c.px(mx + 3, my + 1, maskD); c.px(mx + 4, my + 2, maskD); c.px(mx + 4, my + 3, maskD)   // a crack
    for ex in [mx + 4, mx + 14] {
        c.pattern(ex - 1, my + 4, [".D.", "DED", ".D."], ["D": diamond, "E": glint && Int(p.t * 6) % 2 == 0 ? C(0xFF3A3A) : ink])
    }
    c.rect(mx + 9, my + 7, 2, 2, nose); c.px(mx + 9, my + 7, C(0xFF8A8A))
    c.pattern(mx + 3, my + 9, [
        "R..............R",
        ".RWWWWWWWWWWWWR.",
        "..RWkWkWkWkWkR..",
        "...RRRRRRRRRR...",
    ], ["R": C(0xB8202A), "W": C(0xFFFFFF), "k": C(0x8A8A8A)])

    // Arms hang loose; up and waving slowly when he cheers.
    c.rect(15, 33, 3, 3, overall)
    if p.cheering {
        c.rect(38, 27 + Int(sin(p.t * 3) * 1), 3, 6, overall)
    } else {
        c.rect(38, 33, 3, 3, overall); c.rect(38, 36, 3, 1, mask)
    }
}

// MARK: - Eve 6

/// Eve 6: one of the Eve clones, grown up and kept locked away, Clawd with long straight dark-blonde hair parted in the
/// middle, in a plain pale institutional dress with a name tag. Her weapon is poison: a steady green stream from her
/// hand. Signature: her twin is suddenly standing beside her, faint and the same in every way, and they finish each
/// other's sentence, one mouth after the other, before the twin fades again.
private func drawEve6(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature
    let twin = sig.map { ramp($0, 0.05, 0.2) - ramp($0, 0.8, 0.95) } ?? 0
    if twin > 0, let s = sig {
        // The twin, a step behind her, faint; she speaks on the off beats.
        let other = PixelCanvas(c.w, c.h)
        eveFigure(other, p, talking: s > 0.5 && s < 0.75 && Int(p.t * 6) % 2 == 0, holdingOut: false)
        c.paste(other, x: -12, y: 0, alpha: 0.45 * twin)
    }
    eveFigure(c, p, talking: (sig.map { $0 > 0.25 && $0 < 0.5 } ?? false) && Int(p.t * 6) % 2 == 0,
              holdingOut: p.zap != nil || p.ready)
}

private func eveFigure(_ c: PixelCanvas, _ p: Pose, talking: Bool, holdingOut: Bool) {
    let dress = C(0xD4DCD4), dressD = C(0xA8B4A8), hair = C(0xC8A866), hairD = C(0x9A7E44), poison = C(0x6AE87A)
    drawLegs(c, Look(leg: clawdOrange), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0xE8E8E2))
    c.oy += p.breathe
    drawBody(c, Look(arm: dress))
    // The plain dress and its name tag.
    c.rect(18, 33, 20, 6, dress); c.rect(37, 33, 1, 6, dressD); c.rect(18, 38, 20, 1, dressD)
    c.rect(21, 34, 4, 2, C(0xFFFFFF)); c.rect(22, 35, 2, 1, C(0x5A6A5A))
    // Long straight hair, parted in the middle, down past her shoulders.
    // Long straight hair, parted in the middle: curtains swept off the forehead, falling behind her shoulders, the
    // ends uneven, a strand over each cheek.
    c.pattern(16, 20, [
        "......HHHHHdHHHHHH......",
        "....HHHlHHHdHHHlHHHH....",
        "...HHlHHHHHdHHHHHlHHH...",
        "..HHHHHHHHHdHHHHHHHHHH..",
        ".HHHHHHHHHdHHdHHHHHHHHH.",
        ".HHHHHHHHdHHHHdHHHHHHHH.",
        "HHHHdH............HdHHHH",
        "HHHd................dHHH",
        "HHd..................dHH",
        "HHH..................HHH",
        "HHd..................dHH",
        "HH....................HH",
        "HHd..................dHH",
        "HH....................HH",
        "dH....................Hd",
        "HH....................HH",
        "Hd....................dH",
        ".d.....................d",
    ], ["H": hair, "l": C(0xE0C888), "d": hairD])
    if talking { c.rect(26, 33, 3, 1, C(0x5A2A20)) }
    c.rect(15, 33, 3, 3, dress)
    if holdingOut {
        let raise = p.armRaise
        c.rect(38, 31 - raise, 3, 3, dress); c.rect(41, 31 - raise, 3, 2, clawdOrange)
        if p.zap == false { c.px(44, 30 - raise, poison.alpha(0.6)); c.px(45, 32 - raise, poison.alpha(0.4)) }
    } else {
        c.rect(38, 33, 3, 3, dress)
    }
}

// MARK: - Virgil Incanto

/// Virgil Incanto: Clawd as a smooth talker in black, a black turtleneck under a long black coat, dark hair slicked back
/// to a widow's peak and a neat little beard, and a single red rose. He's all charm: in a fight the long-stemmed rose is
/// what he swings. Signature: he offers you the rose with a slow, smouldering look, and a little heart floats up.
private func drawVirgilIncanto(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x1A1A20), coatL = C(0x34343E), turtle = C(0x101014), hair = C(0x16121A), hairL = C(0x3A2E44)
    let stem = C(0x2E7A3A), rose = C(0xD01E3A), roseD = C(0x8A1024)
    let sig = p.signature
    let offering = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false

    // The coat's long tails behind the legs.
    if !seatedPose { c.rect(17, 36, 22, 5, coat); c.rect(28, 37, 1, 4, coatL) }
    drawLegs(c, Look(leg: coat), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0x0A0A0C))
    c.oy += p.breathe
    drawBody(c, Look(arm: coat, eye: nil))
    // The turtleneck up to the chin, the coat open over it.
    c.rect(18, 33, 20, 5, coat); c.rect(24, 33, 8, 5, turtle); c.rect(18, 37, 20, 1, coatL)
    c.rect(23, 33, 1, 4, coatL); c.rect(32, 33, 1, 4, coatL)
    // Hair slicked back to a widow's peak, down to the top of the face.
    c.pattern(17, 21, [
        "......HHHHHHHHHH......",
        "....HHHHhHHHHhHHHH....",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HH.......HH.......HH.",
    ], ["H": hair, "h": hairL])
    // The eyes: heavy-lidded, half shut while he smoulders; the little beard.
    if offering {
        c.rect(22, 30, 2, 2, ink); c.rect(32, 30, 2, 2, ink); c.rect(21, 29, 4, 1, C(0x9A4A30)); c.rect(31, 29, 4, 1, C(0x9A4A30))
    } else {
        c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    }
    c.pattern(26, 32, ["HHHH", ".HH."], ["H": hair])

    c.rect(15, 33, 3, 3, coat)
    let roseAt: (Double, Double, Double) -> Void = { x, y, r in
        let tx = x + cos(r) * 9, ty = y + sin(r) * 9
        seg(c, x, y, tx, ty, stem)
        c.px(Int((x + cos(r) * 4).rounded()), Int((y + sin(r) * 4).rounded()) - 1, C(0x4AA05A))
        c.rect(Int(tx.rounded()) - 1, Int(ty.rounded()) - 1, 3, 3, rose); c.px(Int(tx.rounded()), Int(ty.rounded()), roseD)
    }
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() {
            swingArm(c, angle: ta, sleeve: coat, fist: clawdOrange, alpha: 0.35 / Double(i + 1))
        }
        swingArm(c, angle: a, sleeve: coat, fist: clawdOrange, hold: roseAt)
        return
    }
    if let s = sig, offering {
        // The rose held out, and a little heart drifting up off it.
        c.rect(38, 31, 3, 3, coat); c.rect(41, 32, 2, 2, clawdOrange)
        seg(c, 43, 32, 48, 27, stem); c.rect(47, 25, 3, 3, rose); c.px(48, 26, roseD)
        let k = ramp(s, 0.3, 0.9)
        if k > 0 && k < 1 {
            c.pattern(49 + Int(k * 3), 22 - Int(k * 10), [".R.R.", "RRRRR", ".RRR.", "..R.."], ["R": C(0xFF5A7A, 1 - k)])
        }
        return
    }
    // At rest the rose hangs from his hand.
    c.rect(38, 33, 3, 3, coat); c.rect(38, 36, 2, 2, clawdOrange)
    seg(c, 39, 38, 41, 43, stem); c.rect(40, 43, 3, 3, rose); c.px(41, 44, roseD)
}
