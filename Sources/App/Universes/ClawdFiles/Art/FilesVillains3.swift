import Foundation

// Villains: the aliens and their soldiers. The Bounty Hunter, the Black Oil, the Grey, the Faceless Rebel, Knowle Rohrer
// and Billy Miles. Clawd in costume where they pass for human (the super soldiers, the Bounty Hunter), Clawd recoloured
// where they don't (the Grey), and in the Black Oil's case no Clawd at all: just the oil.

let filesVillains3: [FilesVillain: Persona] = [
    .bountyHunter: Persona(name: "The Alien Bounty Hunter", weapon: .saber, armoured: true, headTop: 20, signature: 3.2,
                           draw: drawBountyHunter),
    .blackOil: Persona(name: "The Black Oil", weapon: .lightning, motion: .hover,
                       magic: Magic(core: C(0x2A2238), glow: C(0x6AE8D0), jagged: false),
                       canSit: false, pivot: (44, 33), headTop: 27, signature: 3.4,
                       draw: drawBlackOil),
    .grey: Persona(name: "The Grey", weapon: .lightning, magic: Magic(core: C(0xF4FFF8), glow: C(0x8AFFC4), jagged: false),
                   pivot: (44, 32), headTop: 13, signature: 2.8,
                   draw: drawGrey),
    .facelessRebel: Persona(name: "The Faceless Rebel", weapon: .lightning,
                            magic: Magic(core: C(0xFFF0A0), glow: C(0xFF6A1A)),
                            pivot: (44, 27), headTop: 19, signature: 3.0,
                            draw: drawFacelessRebel),
    .knowleRohrer: Persona(name: "Knowle Rohrer", weapon: .saber, armoured: true, headTop: 21, signature: 3.0,
                           callout: "You can't stop what's coming.",
                           draw: drawKnowleRohrer),
    .billyMiles: Persona(name: "Billy Miles", weapon: .saber, armoured: true, headTop: 20, signature: 3.4,
                         callout: "I remember everything.",
                         draw: drawBillyMiles),
]

// MARK: - Shared bits

private let hand = Sprite.hand
private let none = C(0, 0)
private let steel = C(0xB4BAC4), steelLight = C(0xEEF2F6), steelDark = C(0x6E7480)
private let alienGreen = C(0x7AF07A)

/// A point `d` pixels out from `h` at `angle` degrees.
private func reach(_ h: (x: Double, y: Double), _ angle: Double, _ d: Double) -> (x: Double, y: Double) {
    let r = angle * .pi / 180
    return (h.x + cos(r) * d, h.y + sin(r) * d)
}

/// A solid line `r` pixels thick.
private func line(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.8) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: none, coreR: r, glowR: r + 0.1)
}

/// A solid bar along `angle` from `a` to `b` pixels out from `h`.
private func bar(_ c: PixelCanvas, _ h: (x: Double, y: Double), _ angle: Double, from a: Double, to b: Double, _ col: Px,
                 r: Double = 0.8) {
    let p0 = reach(h, angle, a), p1 = reach(h, angle, b)
    line(c, p0.x, p0.y, p1.x, p1.y, col, r)
}

/// A punch: the sleeve out from the hand at `angle`, the fist at its end (fainter for a swing's trail).
private func drawPunch(_ c: PixelCanvas, angle: Double, sleeve: Px, alpha: Double = 1) {
    bar(c, hand, angle, from: -1.5, to: 3, sleeve.alpha(alpha), r: 1.4)
    let f = reach(hand, angle, 5)
    c.rect(Int(f.x) - 1, Int(f.y) - 1, 3, 3, clawdOrange.alpha(alpha))
    c.px(Int(f.x) + 1, Int(f.y) + 1, clawdShade.alpha(alpha))
}

/// The punching arm: a fist thrown at `p.melee` with its trail, or the arm down at rest in `sleeve`.
private func drawFists(_ c: PixelCanvas, _ p: Pose, sleeve: Px) {
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() { drawPunch(c, angle: ta, sleeve: sleeve, alpha: 0.35 / Double(i + 1)) }
        drawPunch(c, angle: a, sleeve: sleeve)
    } else {
        c.rect(38, 33, 3, 3, sleeve); c.rect(38, 35, 3, 1, clawdOrange)
    }
    c.rect(15, 33, 3, 3, sleeve)
}


/// Work boots: the bottom two rows of each leg.
private func drawBoots(_ c: PixelCanvas, step: Int, _ col: Px) {
    guard !seatedPose else { return }
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        let bottom = step >= 0 && i % 2 == step ? 42 : 43
        c.rect(lx, bottom - 1, 2, 2, col)
    }
}

// MARK: - The Alien Bounty Hunter

/// The Alien Bounty Hunter: Clawd in a black leather jacket over a dark roll-neck, black trousers and boots, his dark
/// hair cropped flat, a hard stare. Bullets don't stop him. He fights with the stiletto that snaps out of his fist: a
/// long thin silver spike. Signature: he shape-shifts. Shimmering bands sweep down him and for a moment he's someone
/// else (an auburn bob and a camel coat), then the bands sweep back and he's himself, a fleck of green on the spike.
private func drawBountyHunter(_ c: PixelCanvas, _ p: Pose) {
    let leather = C(0x1E1E24)
    let sig = p.signature
    // How far through the change he is: 0 himself, 1 entirely someone else.
    let shift: Double = sig.map { s in
        s < 0.1 || s > 0.9 ? 0 : s < 0.35 ? (s - 0.1) / 0.25 : s < 0.65 ? 1 : (0.9 - s) / 0.25
    } ?? 0

    if shift > 0 {
        // The change sweeps down him: above the line he's already Scrawly (red bob, camel coat), below it himself.
        let me = PixelCanvas(c.w, c.h), her = PixelCanvas(c.w, c.h)
        for t in [me, her] { t.ox = c.ox; t.oy = c.oy; t.baseY = c.baseY }
        drawBountyHunterSelf(me, p)
        v23DrawScrawlyLook(her, p)
        let line: Int = 18 + Int((shift * 28).rounded())
        v23Compose(c, top: her, bottom: me, split: line)
        if shift < 1 {
            for x in 15...41 {
                let glint = (x + Int(p.t * 30)) % 4 == 0
                c.px(x, line, C(glint ? 0xE8FFF0 : 0x8AF0C0, 0.75))
            }
        }
        c.oy += p.breathe   // as the pieces drawn on their own canvases were
    } else {
        drawBountyHunterSelf(c, p)
    }
    drawStiletto(c, p, sleeve: shift >= 0.5 ? C(0xB08A5A) : leather)
}

/// Copies `top` above row `split` and `bottom` from it down onto `c` (both drawn on blank canvases the size of `c`).
func v23Compose(_ c: PixelCanvas, top: PixelCanvas, bottom: PixelCanvas, split: Int) {
    for y in 0..<c.h {
        let src = y < split ? top : bottom
        for x in 0..<c.w {
            let i = (y * c.w + x) * 4
            let a = src.buf[i + 3]
            guard a > 0 else { continue }
            let m = 255.0 / Double(a)
            let r = UInt8(min(255, Double(src.buf[i]) * m)), g = UInt8(min(255, Double(src.buf[i + 1]) * m))
            let b = UInt8(min(255, Double(src.buf[i + 2]) * m))
            c.px(x - c.ox, y - c.oy - c.baseY, Px(r: r, g: g, b: b, a: a))
        }
    }
}

/// Dana Scrawly's look, as the Bounty Hunter takes it: the auburn bob, the camel coat over a dark suit.
func v23DrawScrawlyLook(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0xB08A5A), coatD = C(0x86683F), coatL = C(0xCCA672), suit = C(0x2E3442), shirt = C(0xE6E2DA)
    let hair = C(0xB4492E), hairL = C(0xD4643E), hairD = C(0x86321E)
    if !seatedPose { c.rect(17, 38, 22, 4, coat); c.rect(17, 41, 22, 1, coatD); c.rect(28, 38, 1, 4, coatD) }
    drawLegs(c, Look(leg: suit), step: p.step)
    drawBoots(c, step: p.step, C(0x1A1A1E))
    c.oy += p.breathe
    drawBody(c, Look(arm: coat))
    c.rect(18, 34, 20, 4, suit); c.rect(25, 34, 6, 2, shirt)
    c.rect(18, 33, 4, 5, coat); c.rect(34, 33, 4, 5, coat); c.rect(37, 33, 1, 5, coatD)
    c.rect(22, 33, 1, 3, coatL); c.rect(33, 33, 1, 3, coatL); c.rect(18, 37, 20, 1, coatD)
    c.pattern(16, 20, [
        ".......HHHHHHHHH........",
        ".....HHHHHHHHlHHHHH.....",
        "...HHHHHHHHHHHlHHHHHHH..",
        "..HHHHHlHHHHHHHHHHHHHHH.",
        "..HHHHHHHHHHHHHHHHHlHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHHH",
        ".HHHHH...HHHHH......HHHH",
        ".HHHd...............dHHH",
        ".HHH.................HHH",
        ".HHd.................dHH",
        ".HHH.................HHH",
        "..Hd.................dH.",
    ], ["H": hair, "l": hairL, "d": hairD])
    c.rect(15, 33, 3, 3, coat)
}

/// The Bounty Hunter as himself, without the stiletto.
private func drawBountyHunterSelf(_ c: PixelCanvas, _ p: Pose) {
    let leather = C(0x1E1E24), leatherL = C(0x3A3A44), leatherD = C(0x101014), roll = C(0x2E2E36)
    let hair = C(0x1A1612)
    drawLegs(c, Look(leg: leather), step: p.step)
    drawBoots(c, step: p.step, C(0x0A0A0C))
    c.oy += p.breathe
    drawBody(c, Look(arm: leather, eye: nil))
    // The eyes: narrow, under a heavy brow.
    c.rect(21, 28, 4, 1, leatherD); c.rect(31, 28, 4, 1, leatherD)
    c.rect(22, 29, 2, 2, ink); c.rect(32, 29, 2, 2, ink)
    // The jacket, open over the roll-neck.
    c.rect(18, 33, 20, 5, leather); c.rect(25, 33, 6, 5, roll); c.rect(25, 33, 6, 1, C(0x40404A))
    c.rect(22, 33, 1, 4, leatherL); c.rect(33, 33, 1, 4, leatherL); c.rect(37, 33, 1, 5, leatherD)
    c.rect(18, 37, 20, 1, leatherD)
    // The hair: cropped flat on top, down to the brow.
    c.pattern(17, 21, [
        "...HHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HH................HH.",
    ], ["H": hair])
    c.rect(15, 33, 3, 3, leather)
}

/// His stiletto: out of the fist in a fight, a short point by it at rest.
private func drawStiletto(_ c: PixelCanvas, _ p: Pose, sleeve leather: Px) {
    let sig = p.signature
    if let a = p.melee {
        // The stiletto: out of the fist, long and thin, a glint running along it.
        for (i, ta) in p.trail.enumerated() { bar(c, hand, ta, from: 2, to: 11, steelLight.alpha(0.35 / Double(i + 1)), r: 0.5) }
        bar(c, hand, a, from: -1, to: 2, leather, r: 1.3)
        bar(c, hand, a, from: 2, to: 11, steel, r: 0.5)
        let tip = reach(hand, a, 11)
        c.px(Int(tip.x), Int(tip.y), steelLight)
        c.rect(15, 33, 3, 3, leather)
        return
    }
    c.rect(15, 33, 3, 3, leather)
    c.rect(38, 33, 3, 3, leather); c.rect(38, 35, 3, 1, clawdOrange)
    // The stiletto at rest: a short silver point by his fist, a green drop on it after a change.
    c.rect(41, 32, 1, 3, steel); c.px(41, 31, steelLight)
    if let s = sig, s > 0.75 { c.px(41, 33, alienGreen) }
}

// MARK: - The Black Oil

/// The Black Oil: no Clawd, only the oil. A slick black mass that creeps along the floor, its top heaving, with a
/// glossy sheen across it and oil-film colours (teal, violet, green) sliding over the surface, and two faint points of
/// light deep inside where you'd expect eyes. It reaches for you with a dark tendril. Signature: it draws itself up
/// into a tall column, quivers, and slumps back down into a puddle.
private func drawBlackOil(_ c: PixelCanvas, _ p: Pose) {
    let oil = C(0x0C0C12), oilL = C(0x24242E), sheen = C(0xC8D8F0)
    let sig = p.signature
    // How tall it stands: a low heap, or drawn up into a column in the signature.
    let rise: Double = sig.map { s in s < 0.1 ? s / 0.1 * 0.3 : s < 0.35 ? 0.3 + (s - 0.1) / 0.25 * 0.7
                                       : s < 0.7 ? 1 : max(0, 1 - (s - 0.7) / 0.25) } ?? 0
    let reaching = p.zap != nil || p.ready || (!p.resting && !p.walking)

    // The mass: column by column, a heaving top over a spreading base.
    for x in 14...42 {
        let dx = Double(x - 28)
        let width = 14.0 - rise * 4
        guard abs(dx) <= width else { continue }
        let k = 1 - (dx * dx) / (width * width)
        let wave = sin(p.t * 3 + Double(x) * 0.6) * 1.2
        let height = 6 + k * (8 + rise * 18) + wave * (0.5 + k)
        let top = 43 - Int(height.rounded())
        c.rect(x, top, 1, 44 - top, oil)
        c.px(x, top, oilL)
    }
    // The puddle it sits in, wider than the heap.
    c.rect(12, 43, 33, 1, oil)
    c.rect(10, 43, 2, 1, oil.alpha(0.7)); c.rect(45, 43, 2, 1, oil.alpha(0.7))
    // The sheen: a curved highlight down its front, and the oil-film colours sliding about.
    let topY = 43 - Int(6 + 8 + rise * 18)
    for i in 0..<4 {
        let y = topY + 3 + i * 2, x = 22 + i
        if y < 41 { c.px(x, y, sheen.alpha(0.85 - Double(i) * 0.15)) }
    }
    let film = [C(0x6AE8D0), C(0xA87AFF), C(0x8AF07A), C(0x5AA8FF)]
    for i in 0..<7 {
        let a = p.t * 0.9 + Double(i) * 0.9
        let x = 28 + Int(sin(a) * 9), y = 40 - Int(abs(cos(a * 0.7)) * (6 + rise * 14))
        c.px(x, y, film[i % film.count].alpha(0.75))
    }
    // Two faint lights deep inside it, blinking out together now and then.
    if Int(p.t * 2.3) % 5 != 0 {
        let ey = 37 - Int(rise * 10)
        c.px(30, ey, C(0x8AFFE8, 0.6)); c.px(34, ey, C(0x8AFFE8, 0.6))
    }
    // The tendril, curling forward toward whoever it's after.
    if reaching {
        let lift = Double(p.armRaise)
        for i in 0...10 {
            let x = 40 + i / 2 + (i > 5 ? i - 5 : 0)
            let y = 38 - Int(Double(i) * 0.5 + lift * Double(i) / 10 + sin(p.t * 6 + Double(i) * 0.8) * 0.8)
            c.rect(x, y, 2, 2, oil)
        }
        c.px(45, 33 - p.armRaise, sheen.alpha(0.7))
    }
    if p.hit {   // it splashes: droplets thrown up off it
        for i in 0..<5 { c.px(16 + i * 6, topY - 2 - (i % 2) * 2, oil) }
    }
}

// MARK: - The Grey

/// The Grey: Clawd gone grey all over, with a huge bald head domed up over the body, two great black almond eyes
/// slanting down to a tiny mouth, and long thin arms. It raises a long-fingered hand and light pours from the palm.
/// Signature: it tilts its head one way, then the other, studying you, a light pulsing at its chest.
private func drawGrey(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x9AA2A8), skinL = C(0xBEC6CC), skinD = C(0x6E767C), eye = C(0x08080C), shine = C(0x8A9AA8)
    let sig = p.signature
    let tilt: Int = sig.map { s in s < 0.15 || s > 0.9 ? 0 : s < 0.5 ? 1 : -1 } ?? 0
    let casting = p.zap != nil || p.ready || p.cheering || (!p.resting && !p.walking)

    // Thin legs, a narrow body.
    if seatedPose {
        for lx in [21, 33] { c.rect(lx - 1, 38, 4, 2, skin) }
    } else {
        for (i, lx) in [22, 33].enumerated() {
            let lifted = p.step >= 0 && i == p.step
            c.rect(lx, 36, 2, lifted ? 7 : 8, skin)
            c.rect(lx - 1, lifted ? 42 : 43, 4, 1, skinD)
        }
    }
    c.oy += p.breathe
    c.rect(21, 30, 14, 8, skin); c.rect(34, 30, 1, 8, skinD); c.rect(21, 37, 14, 1, skinD)
    if let s = sig, s > 0.15, s < 0.9 {   // the light at its chest
        c.px(27, 33, C(0xC8FFE0, 0.5 + 0.5 * sin(p.t * 9))); c.px(28, 33, C(0xC8FFE0, 0.5 + 0.5 * sin(p.t * 9)))
    }
    // The head: a great dome, wider at the top, narrowing to the chin; tilted, the top leans furthest.
    let hx = 17
    /// How far row `r` of the head (0 the top) shifts when tilted.
    func lean(_ r: Int) -> Int { Int((Double(tilt * (17 - r)) / 5.5).rounded()) }
    let head = [
        "......LLLLLLLLL.......",
        "....LLLLLLLLLLLLL.....",
        "...LLSSSSSSSSSSSSL....",
        "..LSSSSSSSSSSSSSSSS...",
        ".LSSSSSSSSSSSSSSSSSD..",
        ".SSSSSSSSSSSSSSSSSSSD.",
        "SSSSSSSSSSSSSSSSSSSSD.",
        "SSSSSSSSSSSSSSSSSSSSSD",
        "SSSSSSSSSSSSSSSSSSSSSD",
        "SSSSSSSSSSSSSSSSSSSSSD",
        "SSSSSSSSSSSSSSSSSSSSSD",
        ".SSSSSSSSSSSSSSSSSSSD.",
        ".SSSSSSSSSSSSSSSSSSSD.",
        "..SSSSSSSSSSSSSSSSSD..",
        "...SSSSSSSSSSSSSSSD...",
        "....SSSSSSSSSSSSSD....",
        ".....SSSSSSSSSSSD.....",
        "......SSSSSSSSSD......",
    ]
    for (r, row) in head.enumerated() { c.pattern(hx + lean(r), 12 + r, [row], ["L": skinL, "S": skin, "D": skinD]) }
    // The eyes: big black almonds slanting down toward the middle, a shine on each.
    let eyes = tilt == 0 ? [
        "EEEE......EEEE",
        "EEEEE....EEEEE",
        ".EEEEE..EEEEE.",
        "..EEEE..EEEE..",
        "...EE....EE...",
    ] : tilt > 0 ? [
        "EEEE.......EEE",
        "EEEEE....EEEEE",
        ".EEEEE..EEEEE.",
        "..EEEE..EEEE..",
        "...EE....EE...",
    ] : [
        "EEE.......EEEE",
        "EEEEE....EEEEE",
        ".EEEEE..EEEEE.",
        "..EEEE..EEEE..",
        "...EE....EE...",
    ]
    for (r, row) in eyes.enumerated() { c.pattern(hx + 4 + lean(8 + r), 20 + r, [row], ["E": eye]) }
    c.px(hx + 5 + lean(8), 20, shine); c.px(hx + 15 + lean(8), 20, shine)
    c.px(hx + 10 + lean(15), 27, skinD); c.px(hx + 11 + lean(15), 27, skinD)   // the tiny mouth

    // The arms: long and thin; the right raised to cast, the palm glowing.
    c.rect(18, 31, 3, 1, skin); c.rect(17, 32, 1, 5, skin); c.px(16, 37, skinD); c.px(18, 37, skinD)
    if casting {
        let lift = p.armRaise
        c.rect(35, 31 - lift, 8, 1, skin); c.rect(35, 32 - lift, 7, 1, skinD)
        c.pattern(43, 29 - lift, ["F.", "FF", ".F", "FF", "F."], ["F": skin])   // the long fingers, spread
        if p.zap == true { c.px(44, 31 - lift, C(0xE8FFF0)) }
    } else {
        c.rect(35, 31, 1, 1, skin); c.rect(36, 32, 1, 5, skin); c.px(35, 37, skinD); c.px(37, 37, skinD)
    }
}

// MARK: - The Faceless Rebel

/// The Faceless Rebel: Clawd in a long dark coat with its hood up, the face under it sealed shut (no eyes, no mouth,
/// only the puckered seams where they were), holding up a burning torch. It fights with the fire: flame thrown from
/// the torch. Signature: it lifts the torch high and sweeps it slowly side to side, the flame roaring up.
private func drawFacelessRebel(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x3A2E26), coatD = C(0x241C16), coatL = C(0x54443A), seam = C(0xA8503A), seamL = C(0xE8906A)
    let sig = p.signature
    let raising = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false
    let casting = p.zap != nil || p.ready || p.cheering || (!p.resting && !p.walking)

    // The coat, long to the ankles.
    drawLegs(c, Look(leg: C(0x2A221C)), step: p.step)
    drawBoots(c, step: p.step, C(0x14100C))
    c.rect(17, 38, 22, seatedPose ? 1 : 4, coat); c.rect(28, 38, 1, seatedPose ? 1 : 4, coatD)
    c.oy += p.breathe
    drawBody(c, Look(arm: coat, eye: nil))
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD); c.rect(27, 33, 1, 5, coatD)
    c.rect(18, 37, 20, 1, coatD)
    // The face: sealed over, the seams where the eyes and mouth were.
    c.rect(21, 30, 4, 1, seam); c.px(22, 29, seamL); c.px(23, 31, seamL)
    c.rect(31, 30, 4, 1, seam); c.px(32, 29, seamL); c.px(33, 31, seamL)
    c.rect(25, 32, 6, 1, seam); c.px(27, 33, seamL)
    // The shadow inside the hood, over the brow; then the hood, framing the face.
    c.rect(19, 24, 18, 2, coatD)
    c.pattern(16, 19, [
        ".......HHHHHHHH.......",
        ".....HHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHH...",
        "..HHHlHHHHHHHHHHHHHH..",
        ".HHHlHHHHHHHHHHHHHHHH.",
        ".HHH..............HHHH",
        "HHH................HHH",
        "HHH................HHH",
        "HHH................HHH",
        "HH..................HH",
        "HH..................HH",
        "HH..................HH",
        "HH..................HH",
        "HH..................HH",
    ], ["H": coat, "l": coatL])

    c.rect(15, 33, 3, 3, coat)
    // The torch: a wooden haft with a rag-wrapped head and its flame.
    let flicker = Int(p.t * 12) % 3
    if raising {
        let sway = Int((sin((sig! - 0.08) * 2 * .pi * 1.5) * 2).rounded())
        c.rect(38, 22, 3, 11, coat)
        c.rect(39 + sway, 12, 1, 11, C(0x6A4628)); c.rect(38 + sway, 11, 3, 2, C(0x8A7A6A))
        drawFlame(c, x: 39 + sway, y: 10, size: 5, flicker: flicker)
    } else if casting {
        let lift = p.armRaise
        c.rect(38, 31 - lift, 3, 3, coat)
        c.rect(41, 27 - lift, 1, 6, C(0x6A4628)); c.rect(40, 26 - lift, 3, 2, C(0x8A7A6A))
        drawFlame(c, x: 41, y: 25 - lift, size: 3, flicker: flicker)
    } else {
        c.rect(38, 33, 3, 3, coat)
        c.rect(41, 29, 1, 7, C(0x6A4628)); c.rect(40, 28, 3, 2, C(0x8A7A6A))
        drawFlame(c, x: 41, y: 27, size: 3, flicker: flicker)
    }
}

/// A torch flame centred on `x`, its base at `y`, `size` rows tall, flickering.
private func drawFlame(_ c: PixelCanvas, x: Int, y: Int, size: Int, flicker: Int) {
    for i in 0..<size {
        let half = max(0, (size - i) / 2 - (i == 0 ? 0 : flicker % 2))
        c.rect(x - half, y - i, half * 2 + 1, 1, i < size / 2 ? C(0xFF7A1A) : C(0xFFC84A))
    }
    c.px(x, y - size - flicker % 2, C(0xFFF0A0))
    c.px(x + (flicker == 1 ? 1 : -1), y - 1, C(0xFFF0A0))
}

// MARK: - Knowle Rohrer

/// Knowle Rohrer: Clawd as a government man, a dark suit and tie, his hair cut short and square, a jaw like a block.
/// He's a super soldier: bullets glance off, and when he's hit the suit tears at his back to show the metal spine
/// underneath. He fights with his fists. Signature: he rolls his neck, and a line of steel vertebrae glints down his
/// back through the cloth.
private func drawKnowleRohrer(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x262A34), suitD = C(0x181B22), shirt = C(0xE6E6E0), tie = C(0x5A1E26), hair = C(0x3A2A1E)
    let sig = p.signature
    let showSpine = p.hit || (sig.map { $0 > 0.3 && $0 < 0.85 } ?? false)
    let roll: Int = sig.map { s in s > 0.05 && s < 0.3 ? (Int(s * 30) % 2 == 0 ? 1 : -1) : 0 } ?? 0

    drawLegs(c, Look(leg: suit), step: p.step)
    drawBoots(c, step: p.step, C(0x0E0E10))
    c.oy += p.breathe
    drawBody(c, Look(arm: suit, eye: nil))
    c.rect(21 + roll, 29, 3, 2, ink); c.rect(32 + roll, 29, 3, 2, ink)
    c.rect(21 + roll, 28, 3, 1, hair); c.rect(32 + roll, 28, 3, 1, hair)   // straight, heavy brows
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(25, 33, ["lSTTSl", ".lTTl.", "..TT..", "..TT.."], ["l": suitD, "S": shirt, "T": tie])
    // The hair: short and squared off.
    c.pattern(17, 22, [
        ".HHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HH..................HH",
    ], ["H": hair])
    if showSpine {
        // The suit torn at his back, and the spine under it: steel vertebrae down the line of it.
        c.rect(17, 26, 3, 12, C(0x101216))
        for y in stride(from: 27, to: 37, by: 2) { c.rect(18, y, 2, 1, steel); c.px(18, y + 1, steelDark) }
        if !p.hit { c.px(18, 27 + Int(p.t * 12) % 10, steelLight) }   // the glint running down it
        if p.hit { c.px(16, 30, C(0xFFE8A0)); c.px(15, 33, C(0xFFE8A0)) }   // sparks
    }
    drawFists(c, p, sleeve: suit)
}

// MARK: - Billy Miles

/// Billy Miles: Clawd as an Oregon farm boy turned super soldier, messy brown hair, a red plaid flannel shirt over a
/// white T-shirt, jeans and work boots. Bullets don't stop him. He fights with his fists. Signature: he comes apart
/// (his head and shoulders lift away, his arms drift off, a metal glint in each gap) and pulls himself back together.
private func drawBillyMiles(_ c: PixelCanvas, _ p: Pose) {
    let plaid = C(0xA8282A), plaidD = C(0x6A161A), check = C(0x2A1414), tee = C(0xEDEDE6)
    let jeans = C(0x3A4E72), hair = C(0x5A3A20), hairL = C(0x7A5230)
    let sig = p.signature
    // How far apart he is: 0 whole, up to 4 pixels between the pieces.
    let gap: Int = sig.map { s in
        let k = s < 0.1 || s > 0.85 ? 0 : s < 0.35 ? (s - 0.1) / 0.25 : s < 0.55 ? 1 : (0.85 - s) / 0.3
        return Int((k * 4).rounded())
    } ?? 0

    drawLegs(c, Look(leg: jeans), step: p.step)
    drawBoots(c, step: p.step, C(0x5A3A22))
    c.oy += p.breathe
    // The lower half: shirt tails and belt.
    c.rect(18, 34, 20, 4, plaid); c.rect(37, 34, 1, 4, plaidD); c.rect(18, 37, 20, 1, C(0x3A2414))
    for x in stride(from: 19, to: 37, by: 4) { c.rect(x, 34, 1, 3, check) }
    c.rect(26, 34, 4, 3, tee)
    // The upper half, lifted away by `gap` while he's in pieces.
    c.oy -= gap
    c.rect(18, 26, 20, 8, clawdOrange); c.rect(37, 26, 1, 8, clawdShade)
    c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    c.rect(18, 32, 20, 2, plaid); c.rect(26, 32, 4, 2, tee)
    for x in stride(from: 19, to: 37, by: 4) { c.px(x, 32, check) }
    c.pattern(17, 20, [
        "......H.HHHH.H........",
        "....HHHHHHHHHHHHHH....",
        "..HHHHHhHHHHHhHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHhHH.HHHHHH.HHhHHH.",
        ".HH..H..........H..HH.",
        ".H..................H.",
    ], ["H": hair, "h": hairL])
    c.oy += gap
    if gap > 0 {
        // The seam between the halves: a shadow across it (too faint to be outlined, so no white lines), the metal
        // struts showing through, glinting.
        c.rect(18, 34 - gap, 20, gap, C(0x14161A, 0.5))
        for x in stride(from: 19, to: 37, by: 3) { c.rect(x, 34 - gap, 1, gap, steelDark) }
        c.px(20 + Int(p.t * 20) % 16, 34 - (gap + 1) / 2, steelLight)
        // The arms drift off to the sides.
        c.rect(15 - gap, 32, 3, 3, plaid); c.rect(38 + gap, 32, 3, 3, plaid)
        c.rect(38 + gap, 34, 3, 1, clawdOrange); c.rect(15 - gap, 34, 3, 1, clawdOrange)
        return
    }
    drawFists(c, p, sleeve: plaid)
}
