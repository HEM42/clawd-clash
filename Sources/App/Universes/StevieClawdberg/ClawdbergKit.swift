import Foundation

// Stevie Clawdberg's shared drawing bits, used across its Art files: geometry for swung weapons, boots and shoes over
// the four feet, a fedora and a whip (Indy's and HEM's). Everything here is prefixed `cb` so it can't clash with
// another universe's private helpers in the tools that compile every universe together.

let clawdbergHand = Sprite.hand
private let cbNone = C(0, 0)

/// A point `d` pixels out from `h` at `angle` degrees.
func clawdbergReach(_ h: (x: Double, y: Double), _ angle: Double, _ d: Double) -> (x: Double, y: Double) {
    let r = angle * .pi / 180
    return (h.x + cos(r) * d, h.y + sin(r) * d)
}

/// A solid straight stroke from (x0, y0) to (x1, y1), `r` pixels from its centre line.
func clawdbergLine(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.8) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: cbNone, coreR: r, glowR: r + 0.1)
}

/// A solid bar along `angle` from `a` to `b` pixels out from `h` (sticks, blades, bats, harpoons).
func clawdbergBar(_ c: PixelCanvas, _ h: (x: Double, y: Double), _ angle: Double, from a: Double, to b: Double, _ col: Px,
           r: Double = 0.8) {
    let p0 = clawdbergReach(h, angle, a), p1 = clawdbergReach(h, angle, b)
    clawdbergLine(c, p0.x, p0.y, p1.x, p1.y, col, r)
}

/// The fading smear a fast swing leaves behind.
func clawdbergSmear(_ c: PixelCanvas, _ h: (x: Double, y: Double), _ trail: [Double], from a: Double, to b: Double, _ col: Px) {
    for (i, angle) in trail.enumerated() {
        let p0 = clawdbergReach(h, angle, a), p1 = clawdbergReach(h, angle, b)
        c.glowLine(p0.x, p0.y, p1.x, p1.y, core: col, glow: col, coreR: 0.5, glowR: 1.6, strength: 0.3 / Double(i + 1))
    }
}

/// Boots or shoes over the bottom of the four standing legs, `height` rows tall; the lifted pair a row higher while
/// walking. Seated legs fold away under the body, so they get none.
func clawdbergBoots(_ c: PixelCanvas, step: Int, _ col: Px, height: Int = 2) {
    guard !seatedPose else { return }
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        let lifted = step >= 0 && i % 2 == step
        c.rect(lx, (lifted ? 43 : 44) - height, 2, height, col)
    }
}

/// A punch: the arm thrown out along `angle`, a fist on the end and faint fists where a fast swing just was.
func clawdbergPunch(_ c: PixelCanvas, angle: Double, trail: [Double], arm: Px, fist: Px = clawdOrange, reach len: Double = 7) {
    for (i, a) in trail.enumerated() {
        let e = clawdbergReach(clawdbergHand, a, len)
        c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 3, 3, fist.alpha(0.35 / Double(i + 1)))
    }
    let e = clawdbergReach(clawdbergHand, angle, len)
    clawdbergLine(c, clawdbergHand.x - 2, clawdbergHand.y - 0.5, e.x, e.y, arm, 1.2)
    c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 3, 3, fist)
}

/// A bullwhip from the hand at `angle`: a short grip, then the lash, lagging behind a fast swing and curling at the
/// tip; a white crack-mark at the tip at the very end of the swing.
func clawdbergWhip(_ c: PixelCanvas, angle: Double, trail: [Double], t: Double, leather: Px, grip: Px = C(0x2A1A10),
            from h: (x: Double, y: Double) = clawdbergHand) {
    clawdbergSmear(c, h, trail, from: 3, to: 19, C(0xE8D8B8))
    clawdbergBar(c, h, angle, from: -2, to: 2.5, grip, r: 0.8)
    let lag = trail.first.map { $0 - angle } ?? 0
    var prev = clawdbergReach(h, angle, 2.5)
    let n = 10
    for i in 1...n {
        let f = Double(i) / Double(n)
        let sag = (lag == 0 ? 30 : 10) * f * f * cos(angle * .pi / 180)
        let a = (angle + lag * f * f * 0.9 + sag + sin(t * 9 - f * 5) * 8 * f) * .pi / 180
        let q = (x: prev.x + cos(a) * 1.8, y: prev.y + sin(a) * 1.8)
        clawdbergLine(c, prev.x, prev.y, q.x, q.y, i == n ? leather.alpha(0.7) : leather, i < 4 ? 0.65 : 0.5)
        prev = q
    }
    if !trail.isEmpty, abs(lag) > 25 {   // the crack
        c.px(Int(prev.x.rounded()) + 1, Int(prev.y.rounded()) - 1, C(0xFFFFFF, 0.8))
        c.px(Int(prev.x.rounded()) + 2, Int(prev.y.rounded()), C(0xFFFFFF, 0.6))
        c.px(Int(prev.x.rounded()), Int(prev.y.rounded()) - 2, C(0xFFFFFF, 0.6))
    }
}

/// The whip coiled at the right hip.
func clawdbergWhipCoil(_ c: PixelCanvas, _ leather: Px) {
    c.pattern(33, 35, [".LLL.", "L...L", "LL.LL", ".LLL."], ["L": leather])
    c.px(35, 39, leather)
}

/// A fedora with a pinched crown and a wide brim, its band; sits on Clawd's head (the body's top is row 26) with its
/// brim on row `brimY` and the crown above, up to row `brimY - 5`. `lift` raises it off the head (knocked off, doffed).
func clawdbergFedora(_ c: PixelCanvas, felt: Px, dark: Px, band: Px, brimY: Int = 25, lift: Int = 0) {
    let y = brimY - lift
    c.pattern(17, y - 5, [
        "......FFFFFFFFFF......",
        ".....FFFFFdFFFFFF.....",
        ".....FFFFFFFFFFFF.....",
        ".....BBBBBBBBBBBB.....",
        "..FFFFFFFFFFFFFFFFFF..",
        "FFFFFFFFFFFFFFFFFFFFFF",
        "dd..................dd",
    ], ["F": felt, "d": dark, "B": band])
}
