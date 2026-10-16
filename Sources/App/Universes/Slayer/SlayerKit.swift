import Foundation

// Clawd Slayer's shared drawing bits, used across its Art files (and by HEM): geometry for swung weapons, boots over
// the four feet, and the wooden stake. Everything here is prefixed `sl` so it can't clash with another universe's
// helpers in the tools that compile every universe together.

let slHand = Sprite.hand
private let slNone = C(0, 0)

/// A point `d` pixels out from `h` at `angle` degrees.
func slReach(_ h: (x: Double, y: Double), _ angle: Double, _ d: Double) -> (x: Double, y: Double) {
    let r = angle * .pi / 180
    return (h.x + cos(r) * d, h.y + sin(r) * d)
}

/// A solid straight stroke from (x0, y0) to (x1, y1), `r` pixels from its centre line.
func slLine(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.8) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: slNone, coreR: r, glowR: r + 0.1)
}

/// A solid bar along `angle` from `a` to `b` pixels out from `h` (stakes, blades, axes).
func slBar(_ c: PixelCanvas, _ h: (x: Double, y: Double), _ angle: Double, from a: Double, to b: Double, _ col: Px,
           r: Double = 0.8) {
    let p0 = slReach(h, angle, a), p1 = slReach(h, angle, b)
    slLine(c, p0.x, p0.y, p1.x, p1.y, col, r)
}

/// The fading smear a fast swing leaves behind.
func slSmear(_ c: PixelCanvas, _ h: (x: Double, y: Double), _ trail: [Double], from a: Double, to b: Double, _ col: Px) {
    for (i, angle) in trail.enumerated() {
        let p0 = slReach(h, angle, a), p1 = slReach(h, angle, b)
        c.glowLine(p0.x, p0.y, p1.x, p1.y, core: col, glow: col, coreR: 0.5, glowR: 1.6, strength: 0.3 / Double(i + 1))
    }
}

/// Boots or shoes over the bottom of the four standing legs, `height` rows tall; the lifted pair a row higher while
/// walking. Seated legs fold away under the body, so they get none.
func slBoots(_ c: PixelCanvas, step: Int, _ col: Px, height: Int = 2) {
    guard !seatedPose else { return }
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        let lifted = step >= 0 && i % 2 == step
        c.rect(lx, (lifted ? 43 : 44) - height, 2, height, col)
    }
}

let slStakeWood = C(0xD2A468), slStakeDark = C(0x8E6234), slStakePoint = C(0xF0D8A8)

/// A wooden stake held in the fist at `angle` degrees: chunky and pale so it reads at desktop size, the grain dark
/// along its lower edge, a whittled point, and the smear of a fast swing behind it. `fist: false`: in the air, thrown.
func slStake(_ c: PixelCanvas, angle: Double, trail: [Double], from h: (x: Double, y: Double) = slHand, fist: Bool = true) {
    slSmear(c, h, trail, from: 2, to: 10, C(0xF4E8D0))
    slBar(c, h, angle, from: -2, to: 8, slStakeDark, r: 1.2)
    slBar(c, h, angle, from: -2, to: 7.5, slStakeWood, r: 0.9)
    let tip = slReach(h, angle, 9.5)
    c.px(Int(tip.x.rounded()), Int(tip.y.rounded()), slStakePoint)
    if fist { c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, clawdOrange) }   // the fist round it
}

/// A clawed strike along `angle`: the sleeve thrown out, a fist on the end with long pale nails, and faint claws where
/// a fast swing just was.
func slClaws(_ c: PixelCanvas, angle: Double, trail: [Double], sleeve: Px, nail: Px = C(0xE8E0C8), reach len: Double = 7) {
    for (i, a) in trail.enumerated() {
        let e = slReach(slHand, a, len + 3)
        c.px(Int(e.x.rounded()), Int(e.y.rounded()), nail.alpha(0.4 / Double(i + 1)))
    }
    let e = slReach(slHand, angle, len)
    slLine(c, slHand.x - 2, slHand.y - 0.5, e.x, e.y, sleeve, 1.2)
    c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 3, 3, clawdOrange)
    for k in -1...1 {   // three nails, fanned
        let n0 = slReach((e.x, e.y), angle + Double(k) * 28, 1.5), n1 = slReach((e.x, e.y), angle + Double(k) * 28, 4)
        slLine(c, n0.x, n0.y, n1.x, n1.y, nail, 0.45)
    }
}

/// The stake at rest: held point down in the right hand (the arm, at (38, 33), is the caller's).
func slStakeHeld(_ c: PixelCanvas) {
    c.rect(39, 36, 2, 5, slStakeWood); c.rect(40, 36, 1, 5, slStakeDark); c.px(39, 41, slStakePoint)
}
