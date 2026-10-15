import Foundation

// Villains: monsters of the week. Tooms, the Flukeman, the Pusher and the Jersey Devil. Clawd in costume like everyone
// else (the Flukeman's pale suit covers him head to foot); creepy, but no worse than the show at teatime.

let filesVillains4: [FilesVillain: Persona] = [
    .tooms: Persona(name: "Eugene Clawms", weapon: .saber, headTop: 21, signature: 3.8, callout: "Back in thirty years.",
                    draw: drawTooms),
    .flukeman: Persona(name: "The Flukeman", weapon: .saber, canSit: false, headTop: 17, signature: 3.6, callout: "Glrrbl.",
                       draw: drawFlukeman),
    .pusher: Persona(name: "The Pusher", weapon: .lightning,
                     magic: Magic(core: C(0xF4E8FF), glow: C(0x9A5AE8), jagged: false),
                     pivot: (45.0, 31.0), headTop: 21, signature: 3.2, callout: "You will step aside.",
                     draw: drawPusher),
    .jerseyDevil: Persona(name: "The Jersey Devil", weapon: .saber, headTop: 15, signature: 2.6, callout: "Grrraah!",
                          draw: drawJerseyDevil),
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

/// A clawed arm swung out at `angle` degrees from the shoulder: the sleeve, the hand and three nails fanning out.
private func drawClawArm(_ c: PixelCanvas, angle: Double, sleeve: Px, hand: Px, nail: Px, alpha: Double = 1) {
    let r = angle * .pi / 180
    let sx = 39.0, sy = 34.0
    let ex = sx + cos(r) * 5, ey = sy + sin(r) * 5, hx = ex + cos(r) * 3, hy = ey + sin(r) * 3
    seg(c, sx, sy, ex, ey, sleeve.alpha(alpha), w: 2)
    seg(c, ex, ey, hx, hy, hand.alpha(alpha), w: 2)
    for spread in [-0.5, 0.0, 0.5] {
        let a = r + spread
        seg(c, hx + 0.5, hy + 0.5, hx + 0.5 + cos(a) * 3, hy + 0.5 + sin(a) * 3, nail.alpha(alpha))
    }
}

/// Copies what's drawn on `src` into `c`, each pixel `c` gets read from `map(x, y)` on `src` (nil: nothing), faded by
/// `alpha`. Used to squash, stretch and shift a whole drawn figure.
private func blit(_ src: PixelCanvas, into c: PixelCanvas, alpha: Double = 1, clipBelow: Int? = nil,
                  map: (Int, Int) -> (Int, Int)) {
    for y in 0..<c.h {
        if let clip = clipBelow, y > clip { break }
        for x in 0..<c.w {
            let (sx, sy) = map(x, y)
            guard sx >= 0, sy >= 0, sx < src.w, sy < src.h else { continue }
            let i = (sy * src.w + sx) * 4, a = src.buf[i + 3]
            guard a > 0 else { continue }
            let m = 255 / Double(a)
            let px = Px(r: UInt8(min(255, Double(src.buf[i]) * m)), g: UInt8(min(255, Double(src.buf[i + 1]) * m)),
                        b: UInt8(min(255, Double(src.buf[i + 2]) * m)), a: a)
            c.px(x, y, px.alpha(alpha))
        }
    }
}

// MARK: - Eugene Clawms

/// Eugene Clawms: Clawd in an animal-control uniform (a khaki work shirt with a badge on the chest, brown trousers),
/// dark hair combed flat, and yellow eyes that don't blink. His fingers are long and end in yellowed nails, and he
/// fights with them, raking. Signature: he squeezes himself thin, taller and narrower, slides sideways into a vent grate
/// at his feet and is gone, then squeezes back out again.
private func drawTooms(_ c: PixelCanvas, _ p: Pose) {
    guard let s = p.signature, s > 0.05, s < 0.95 else { toomsFigure(c, p); return }
    let narrow = ramp(s, 0.05, 0.3) - ramp(s, 0.78, 0.95)
    let slide = ramp(s, 0.3, 0.5) - ramp(s, 0.62, 0.78)
    // The vent he goes into, low on the wall to his right.
    let vent = ramp(s, 0.05, 0.15) - ramp(s, 0.85, 0.95)
    c.rect(43, 35, 13, 8, C(0x6A6E76, vent)); c.rect(44, 36, 11, 6, C(0x16161A, vent))
    for y in stride(from: 37, to: 42, by: 2) { c.rect(44, y, 11, 1, C(0x8A8E96, vent)) }
    guard slide < 0.98 else { return }
    let fig = PixelCanvas(c.w, c.h)
    toomsFigure(fig, p)
    let wf = 1 - 0.68 * narrow, hf = 1 + 0.18 * narrow, dx = slide * 21
    blit(fig, into: c, alpha: 1 - slide * 0.85) { x, y in
        (Int(((Double(x) - 28 - dx) / wf + 28).rounded(.down)), Int(((Double(y) - 44) / hf + 44).rounded(.down)))
    }
}

private func toomsFigure(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0x8A7E52), shirtD = C(0x6A6040), trousers = C(0x4E4636), hair = C(0x241C14), nail = C(0xE6DCA8)
    drawLegs(c, Look(leg: trousers), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0x2A2018))
    c.oy += p.breathe
    drawBody(c, Look(arm: shirt, eye: nil))
    // The work shirt, its collar and the badge.
    c.rect(18, 34, 20, 4, shirt); c.rect(37, 34, 1, 4, shirtD); c.rect(18, 37, 20, 1, shirtD)
    c.pattern(24, 34, ["SSS..SSS", ".SS..SS."], ["S": shirtD])
    c.rect(20, 35, 2, 2, C(0xC8A04A))
    // Hair combed flat to the scalp.
    c.pattern(17, 22, [
        ".....HHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HH................HH.",
    ], ["H": hair])
    // The yellow eyes.
    for x in [22, 32] { c.rect(x, 29, 2, 3, C(0xF2D43A)); c.px(x + 1, 30, ink) }
    // Arms: long fingers hanging at rest, raking when he fights.
    c.rect(15, 33, 3, 3, shirt); c.rect(15, 36, 1, 3, clawdOrange); c.rect(17, 36, 1, 3, clawdOrange)
    c.px(15, 39, nail); c.px(17, 39, nail)
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() {
            drawClawArm(c, angle: ta, sleeve: shirt, hand: clawdOrange, nail: nail, alpha: 0.35 / Double(i + 1))
        }
        drawClawArm(c, angle: a, sleeve: shirt, hand: clawdOrange, nail: nail)
    } else {
        c.rect(38, 33, 3, 3, shirt); c.rect(38, 36, 1, 3, clawdOrange); c.rect(40, 36, 1, 3, clawdOrange)
        c.px(38, 39, nail); c.px(40, 39, nail)
    }
}

// MARK: - The Flukeman

/// The Flukeman: a pale, rubbery worm of a man, head to foot in ridged white-grey flesh (Clawd's in there somewhere),
/// a domed head, two slits for eyes and a round sucker of a mouth ringed with little teeth that opens and closes. He
/// lashes out with a soft, heavy arm. Signature: he sinks down into the sewer pipe at his feet, bubbles rising where he
/// was, then rises back up out of it.
private func drawFlukeman(_ c: PixelCanvas, _ p: Pose) {
    guard let s = p.signature, s > 0.03, s < 0.97 else { flukeFigure(c, p); return }
    let sink = ramp(s, 0.06, 0.28) - ramp(s, 0.6, 0.88)
    let pipe = ramp(s, 0.03, 0.08) - ramp(s, 0.9, 0.97)
    // The pipe's dark mouth, open in the ground at his feet.
    c.ellipse(28, 43, 13, 3, C(0x4A5448, pipe)); c.ellipse(28, 43, 11, 2, C(0x0E120E, pipe))
    let fig = PixelCanvas(c.w, c.h)
    flukeFigure(fig, p)
    let dy = Int(sink * 30)
    blit(fig, into: c, clipBelow: 42) { x, y in (x, y - dy) }
    // The pipe's front lip over him, and bubbles while he's under.
    c.rect(16, 44, 25, 1, C(0x6A7468, pipe)); c.rect(17, 45, 23, 1, C(0x3A4238, pipe))
    if sink > 0.9 {
        for i in 0..<3 {
            let k = (p.t * 0.9 + Double(i) / 3).truncatingRemainder(dividingBy: 1)
            c.px(24 + i * 4, 42 - Int(k * 8), C(0xC8D8C0, 0.8 * (1 - k)))
        }
    }
}

private func flukeFigure(_ c: PixelCanvas, _ p: Pose) {
    let pale = C(0xD6D2C0), paleD = C(0xA8A490), paleL = C(0xEEECE2)
    drawLegs(c, Look(leg: pale), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.px(lx, p.step >= 0 && [19, 31].contains(lx) == (p.step == 0) ? 42 : 43, paleD) } }
    c.oy += p.breathe
    drawBody(c, Look(body: pale, shade: paleD, arm: pale, eye: nil))
    // The domed head and the ridges round him.
    c.pattern(17, 17, [
        "......PPPPPPPPPP......",
        "....PPPPPPLLPPPPPP....",
        "...PPPPPPLLPPPPPPPP...",
        "..RRRRRRRRRRRRRRRRRR..",
        ".PPPPPPPPPPPPPPPPPPPP.",
        "PPPPPPPPPPPPPPPPPPPPPP",
        "RRRRRRRRRRRRRRRRRRRRRR",
        "PPPPPPPPPPPPPPPPPPPPPP",
        "PPPPPPPPPPPPPPPPPPPPPP",
    ], ["P": pale, "L": paleL, "R": paleD])
    for y in [34, 37] { c.rect(18, y, 20, 1, paleD) }
    // Slits for eyes, and the sucker mouth, opening and closing.
    c.rect(22, 28, 3, 1, ink); c.rect(31, 28, 3, 1, ink)
    let open = sin(p.t * 3.1) > 0
    c.pattern(26, 29, open ? [".MMMMM.", "MTiiiTM", "MiiiiiM", "MTiiiTM", ".MMMMM."]
                           : ["..MMM..", ".MTiTM.", ".MiiiM.", ".MTiTM.", "..MMM.."],
              ["M": C(0x9A4A52), "i": C(0x3A1418), "T": C(0xF2EEDC)])
    c.rect(15, 33, 3, 3, pale)
    if let a = p.melee {
        let r = a * .pi / 180
        for (i, ta) in p.trail.enumerated() {
            let tr = ta * .pi / 180
            seg(c, 39, 34, 39 + cos(tr) * 9, 34 + sin(tr) * 9, pale.alpha(0.35 / Double(i + 1)), w: 3)
        }
        seg(c, 39, 34, 39 + cos(r) * 9, 34 + sin(r) * 9, pale, w: 3)
        c.px(Int(40 + cos(r) * 9), Int(35 + sin(r) * 9), C(0x9A4A52))
    } else {
        c.rect(38, 33, 3, 4, pale); c.px(39, 36, paleD)
    }
}

// MARK: - The Pusher

/// The Pusher: nobody you'd look at twice. Clawd with a short sandy crop going thin on top, a tan windbreaker open over
/// a white T-shirt, and jeans. He fights by will alone, a finger pointed and a steady violet push leaving its tip,
/// little rings tightening round it. Signature: "you will…": two fingers to his temple, eyes narrowed, and rings of will
/// spreading out from his head.
private func drawPusher(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x8E7E5A), jacketD = C(0x6E6044), shirt = C(0xEDEDE8), jeans = C(0x3E4E6A), hair = C(0x9A7A46)
    let will = C(0xB88AF4)
    let sig = p.signature
    let pushing = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: jeans), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0x3A2A1E))
    c.oy += p.breathe
    drawBody(c, Look(arm: jacket, eye: pushing ? nil : ink))
    // The windbreaker open over the T-shirt, its zip and collar.
    c.rect(18, 34, 20, 4, jacket); c.rect(37, 34, 1, 4, jacketD); c.rect(18, 37, 20, 1, jacketD)
    c.rect(25, 34, 6, 4, shirt); c.rect(24, 34, 1, 4, jacketD); c.rect(31, 34, 1, 4, jacketD)
    // The crop, thin on top.
    c.pattern(17, 22, [
        "......HhHHHHhHHH......",
        "....HHHhHHHHHhHHHH....",
        "...HHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HH................HH.",
    ], ["H": hair, "h": C(0xC89A62)])

    if pushing, let s = sig {
        // Eyes narrowed to slits, two fingers to the temple, rings of will going out from his head.
        c.rect(22, 30, 2, 1, ink); c.rect(32, 30, 2, 1, ink)
        c.rect(38, 27, 3, 6, jacket); c.rect(37, 26, 2, 1, clawdOrange); c.rect(37, 28, 2, 1, clawdOrange)
        for i in 0..<3 {
            let k = (s * 3 + Double(i) / 3).truncatingRemainder(dividingBy: 1)
            let r = 6 + k * 16
            for a in stride(from: 0.0, to: 2 * .pi, by: .pi / 12) {
                c.px(28 + Int((cos(a) * r).rounded()), 27 + Int((sin(a) * r * 0.7).rounded()), will.alpha(0.7 * (1 - k)))
            }
        }
        c.rect(15, 33, 3, 3, jacket)
        return
    }
    c.rect(15, 33, 3, 3, jacket)
    let using = p.zap != nil || p.ready
    if using {
        // The pointing finger, its tip at `pivot`; rings tighten round it while he pushes.
        let raise = p.armRaise
        c.rect(38, 31 - raise, 3, 3, jacket); c.rect(41, 32 - raise, 4, 1, clawdOrange)
        if p.zap == true {
            let k = (p.t * 2).truncatingRemainder(dividingBy: 1)
            let r = 4 - k * 3
            for a in stride(from: 0.0, to: 2 * .pi, by: .pi / 4) {
                c.px(45 + Int((cos(a) * r).rounded()), 31 - raise + Int((sin(a) * r).rounded()), will.alpha(0.4 + 0.6 * k))
            }
        }
    } else {
        c.rect(38, 33, 3, 3, jacket)
    }
}

// MARK: - The Jersey Devil

/// The Jersey Devil: a wild woman of the Pine Barrens, a great mane of matted brown hair hanging to her knees, mud on
/// her, Clawd's face peering out of it with yellow eyes and bared teeth. She crouches low and rakes with clawed hands.
/// Signature: a crouch, then a huge leap straight up, and a landing in a puff of dust.
private func drawJerseyDevil(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0x4A3220), furD = C(0x2E1E12), furL = C(0x6A4A30), nail = C(0x2A2018)
    var crouch = 1, lift = 0.0, dust = 0.0
    if let s = p.signature {
        if s < 0.18 { crouch = 1 + Int(ramp(s, 0, 0.12) * 2) }
        else if s < 0.78 { lift = sin((s - 0.18) / 0.6 * .pi) * 13; crouch = 0 }
        else { dust = ramp(s, 0.78, 1); crouch = 1 + (s < 0.86 ? 1 : 0) }
    }
    // Her shadow stays on the ground while she's up.
    if lift > 0 { c.ellipse(28, 44, Int(10 - lift / 3), 1, C(0x000000, 0.25)) }
    if dust > 0 {
        for (i, dx) in [-14, -9, 9, 14].enumerated() {
            let r = Int(1 + dust * 3)
            c.circle(28 + dx + (dx < 0 ? -1 : 1) * Int(dust * 3), 43 - i % 2, r, C(0xB8A88A, 0.6 * (1 - dust)))
        }
    }
    c.oy += crouch - Int(lift.rounded())
    drawLegs(c, Look(leg: fur), step: lift > 0 ? -1 : p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.px(lx, 43, nail); c.px(lx + 1, 43, nail) } }
    c.oy += p.breathe
    drawBody(c, Look(body: clawdOrange, arm: fur, eye: nil))
    // The mane: wild over her head, hanging down both sides of her face and over her body to the knees.
    c.pattern(15, 15, [
        "....F.FFF..FF.F.F.......",
        "..FFFFFFFFFFFFFFFFFF.F..",
        ".FFFFLFFFFFFFLFFFFFFFF..",
        "FFFFFFFFFFLFFFFFFFFFFFF.",
        "FFFFFFFFFFFFFFFFFFLFFFFF",
        "FFFLFFFFFFFFFFFFFFFFFFFF",
        "FFFFFFFFFFFFFFFFFFFFFFFF",
        "FFFFFFFFFFFFFFFFFFFFFFFF",
        "FFFFFFFFFFFFFFFFFFFFFFFF",
        "FFFFFFFFFFFFFFFFFFFFFFFF",
        "FFFFLFFFFFFFFFFFFFFLFFFF",
        "FFFFFFF..........FFFFFFF",
        "FFFFFF............FFFFFF",
        "FFFFFF............FFFFFF",
        "FFFFFFF..........FFFFFFF",
        "FFFFFFFFFFFFFFFFFFFFFFFF",
        "FFFFFFFFFFFFFFFFFFFFFFFF",
        "FFFFFFFFFFLFFFFFFFFFFFFF",
        "FFFFFFFFFFFFFFFFFFFFFFFF",
        "FFFFFFFFFFFFFFFFFFFFFFFF",
        "FFLFFFFFFFFFFFFFFLFFFFFF",
        ".FFFF.FFFFF.FFFFF.FFFF..",
        "..F...F.F....F.F...F....",
    ], ["F": fur, "L": furL])
    for i in 0..<10 { c.px(16 + Int(noise(i + 40) * 22), 31 + Int(noise(i + 60) * 6), furD) }   // matted, muddy
    // Ragged edges: strands sticking out of the mane, swaying a little.
    let sway = Int(p.t * 2) % 2
    for (y, side) in [(19, -1), (22, 1), (24, -1), (27, 1), (30, -1), (33, 1), (35, -1)] {
        let x = side < 0 ? 14 - (y % 2) * sway : 39 + (y % 2) * sway
        c.px(x, y, fur); c.px(x + side, y + 1, furL)
    }
    // Yellow eyes and bared teeth.
    for x in [22, 32] { c.rect(x, 27, 2, 2, C(0xE8D040)); c.px(x + 1, 28, ink) }
    c.rect(25, 29, 6, 1, ink); for x in [25, 27, 29] { c.px(x, 29, C(0xF2EEDC)) }
    // Claws: forward when she rakes, otherwise held up at her chest ready.
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() {
            drawClawArm(c, angle: ta, sleeve: fur, hand: clawdOrange, nail: nail, alpha: 0.35 / Double(i + 1))
        }
        drawClawArm(c, angle: a, sleeve: fur, hand: clawdOrange, nail: nail)
    } else {
        c.rect(38, 31, 3, 3, fur); c.rect(40, 30, 2, 2, clawdOrange); c.px(42, 30, nail); c.px(42, 31, nail)
    }
}
