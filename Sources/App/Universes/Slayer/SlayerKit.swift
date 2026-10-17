import Foundation

// Clawd Slayer's shared drawing bits, used across its Art files (and by HEM): geometry for swung weapons, boots over
// the four feet, and the wooden stake. Everything here is prefixed `sl` so it can't clash with another universe's
// helpers in the tools that compile every universe together.

let slayerHand = Sprite.hand
private let slayerNone = C(0, 0)

/// A point `d` pixels out from `h` at `angle` degrees.
func slayerReach(_ h: (x: Double, y: Double), _ angle: Double, _ d: Double) -> (x: Double, y: Double) {
    let r = angle * .pi / 180
    return (h.x + cos(r) * d, h.y + sin(r) * d)
}

/// A solid straight stroke from (x0, y0) to (x1, y1), `r` pixels from its centre line.
func slayerLine(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.8) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: slayerNone, coreR: r, glowR: r + 0.1)
}

/// A solid bar along `angle` from `a` to `b` pixels out from `h` (stakes, blades, axes).
func slayerBar(_ c: PixelCanvas, _ h: (x: Double, y: Double), _ angle: Double, from a: Double, to b: Double, _ col: Px,
           r: Double = 0.8) {
    let p0 = slayerReach(h, angle, a), p1 = slayerReach(h, angle, b)
    slayerLine(c, p0.x, p0.y, p1.x, p1.y, col, r)
}

/// The fading smear a fast swing leaves behind.
func slayerSmear(_ c: PixelCanvas, _ h: (x: Double, y: Double), _ trail: [Double], from a: Double, to b: Double, _ col: Px) {
    for (i, angle) in trail.enumerated() {
        let p0 = slayerReach(h, angle, a), p1 = slayerReach(h, angle, b)
        c.glowLine(p0.x, p0.y, p1.x, p1.y, core: col, glow: col, coreR: 0.5, glowR: 1.6, strength: 0.3 / Double(i + 1))
    }
}

/// Boots or shoes over the bottom of the four standing legs, `height` rows tall; the lifted pair a row higher while
/// walking. Seated legs fold away under the body, so they get none.
func slayerBoots(_ c: PixelCanvas, step: Int, _ col: Px, height: Int = 2) {
    guard !seatedPose else { return }
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        let lifted = step >= 0 && i % 2 == step
        c.rect(lx, (lifted ? 43 : 44) - height, 2, height, col)
    }
}

let slayerStakeWood = C(0xD2A468), slayerStakeDark = C(0x8E6234), slayerStakePoint = C(0xF0D8A8)

/// A wooden stake held in the fist at `angle` degrees: chunky and pale so it reads at desktop size, the grain dark
/// along its lower edge, a whittled point, and the smear of a fast swing behind it. `fist: false`: in the air, thrown.
func slayerStake(_ c: PixelCanvas, angle: Double, trail: [Double], from h: (x: Double, y: Double) = slayerHand, fist: Bool = true) {
    slayerSmear(c, h, trail, from: 2, to: 10, C(0xF4E8D0))
    slayerBar(c, h, angle, from: -2, to: 8, slayerStakeDark, r: 1.2)
    slayerBar(c, h, angle, from: -2, to: 7.5, slayerStakeWood, r: 0.9)
    let tip = slayerReach(h, angle, 9.5)
    c.px(Int(tip.x.rounded()), Int(tip.y.rounded()), slayerStakePoint)
    if fist { c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, clawdOrange) }   // the fist round it
}

/// A clawed strike along `angle`: the sleeve thrown out, a fist on the end with long pale nails, and faint claws where
/// a fast swing just was.
func slayerClaws(_ c: PixelCanvas, angle: Double, trail: [Double], sleeve: Px, nail: Px = C(0xE8E0C8), reach len: Double = 7) {
    for (i, a) in trail.enumerated() {
        let e = slayerReach(slayerHand, a, len + 3)
        c.px(Int(e.x.rounded()), Int(e.y.rounded()), nail.alpha(0.4 / Double(i + 1)))
    }
    let e = slayerReach(slayerHand, angle, len)
    slayerLine(c, slayerHand.x - 2, slayerHand.y - 0.5, e.x, e.y, sleeve, 1.2)
    c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 3, 3, clawdOrange)
    for k in -1...1 {   // three nails, fanned
        let n0 = slayerReach((e.x, e.y), angle + Double(k) * 28, 1.5), n1 = slayerReach((e.x, e.y), angle + Double(k) * 28, 4)
        slayerLine(c, n0.x, n0.y, n1.x, n1.y, nail, 0.45)
    }
}

/// The stake at rest: held point down in the right hand (the arm, at (38, 33), is the caller's).
func slayerStakeHeld(_ c: PixelCanvas) {
    c.rect(39, 36, 2, 5, slayerStakeWood); c.rect(40, 36, 1, 5, slayerStakeDark); c.px(39, 41, slayerStakePoint)
}
