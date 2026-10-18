import Foundation

// Stevie Clawdberg's own solo practice (`UniverseModule.drills`): Indy cracking his whip at a bottle on a post, Squint
// harpooning a yellow barrel bobbing on the swell, Data testing a spring-loaded gadget, Roofio fencing the air with a
// lunge and a recovery, and Marty running through his guitar solo. Nobody in this universe floats cross-legged in
// meditation (`Cast.meditates`).

let clawdbergBespokeDrills: [Cast: BespokeDrill] = [
    .hero(ClawdbergHero.indianaBones): drawWhipTarget,
    .hero(ClawdbergHero.squint): drawHarpoonBarrel,
    .hero(ClawdbergHero.data): drawGadgetTest,
    .hero(ClawdbergHero.roofio): drawFencing,
    .hero(ClawdbergHero.martyMcFry): drawGuitarSolo,
]

/// Indy's whip practice: a bottle on a post out in front, his whip swinging; on every crack the bottle jumps off the
/// post and is back on it for the next one.
private func drawWhipTarget(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    drawPersona(c, who, t: t, mode: .working, walking: false, role: .none)
    let r = setRamp(d)
    guard r > 0.2 else { return }
    let post = C(0x6A4A2A, r), glass = C(0x5AA86A, r), shine = C(0xC8F0D0, r)
    let x0 = 63
    c.rect(x0, 34, 2, 10, post); c.rect(x0 - 1, 33, 4, 1, post)
    let beat = frac(d.e / 1.2)
    let jump = beat < 0.35 ? Int((sin(beat / 0.35 * .pi) * 6).rounded()) : 0
    c.rect(x0, 28 - jump, 2, 5, glass); c.rect(x0, 26 - jump, 1, 2, glass); c.px(x0, 29 - jump, shine)
    if beat < 0.08 {   // the crack
        c.px(x0 - 2, 27, C(0xFFFFFF, r)); c.px(x0 - 3, 25, C(0xFFFFFF, 0.7 * r)); c.px(x0 - 3, 29, C(0xFFFFFF, 0.7 * r))
    }
}

/// Squint's harpoon practice: a yellow barrel bobbing on the swell out in front, a harpoon flying at it every few
/// seconds and the barrel ducking under with the hit.
private func drawHarpoonBarrel(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    drawPersona(c, who, t: t, mode: .working, walking: false, role: .none)
    let r = setRamp(d)
    guard r > 0.2 else { return }
    let barrel = C(0xF2C82A, r), band = C(0xB8901A, r), sea = C(0x3A6A9A, 0.5 * r)
    let beat = frac(d.e / 2.4)
    let bob = Int((sin(d.e * 2.6) * 1.5).rounded()) + (beat > 0.45 && beat < 0.6 ? 2 : 0)
    c.rect(56, 42, 14, 2, sea)
    c.rect(61, 35 + bob, 6, 7, barrel); c.rect(61, 37 + bob, 6, 1, band); c.rect(61, 40 + bob, 6, 1, band)
    if beat > 0.15 && beat < 0.45 {   // the harpoon in flight, its line trailing back
        let k = (beat - 0.15) / 0.3
        let hx = 46 + k * 15, hy = 31 + k * 5
        cbLine(c, hx - 5, hy - 1, hx, hy, C(0xC8CCD4, r), 0.5)
        cbLine(c, 44, 33, hx - 5, hy - 1, C(0xE8E0C8, 0.6 * r), 0.3)
    }
}

/// Data testing a gadget: a boxing glove on a zigzag spring shoots out of his coat and snaps back, over and over.
private func drawGadgetTest(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    standing(c, who, t: t)
    let r = setRamp(d)
    guard r > 0.3 else { return }
    let beat = frac(d.e / 1.6)
    let out = beat < 0.3 ? sin(beat / 0.3 * .pi) : 0
    let reach = 4 + Int((out * 14).rounded())
    let spring = C(0xC8CCD4, r)
    for i in 0..<reach { c.px(40 + i, i % 2 == 0 ? 31 : 33, spring); c.px(40 + i, 32, spring) }
    c.rect(40 + reach, 29, 4, 5, C(0xC82A2A, r)); c.rect(40 + reach, 29, 4, 1, C(0xE85A4A, r))
}

/// Roofio fencing the air: lunging forward with his sword and recovering, a beat at a time.
private func drawFencing(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    let r = setRamp(d)
    drawPersona(c, who, t: t, mode: .working, walking: false, role: .none)
    guard r > 0.5 else { return }
    let beat = frac(d.e / 1.4)
    if beat < 0.4 { c.shift(dx: Int((sin(beat / 0.4 * .pi) * 4).rounded()), dy: 0) }
}

/// Marty's guitar solo: the cherry-red guitar slung across him, hopping along in a little duck walk, notes floating
/// up off it.
private func drawGuitarSolo(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    let r = setRamp(d)
    standing(c, who, t: t)
    guard r > 0.3 else { return }
    let red = C(0xB8202A), dark = C(0x6A1016), neck = C(0x5A3A22)
    // The body of the guitar at his hip, the neck up and out in front.
    c.ellipse(32, 36, 5, 3, red); c.rect(30, 35, 3, 2, dark); c.px(28, 37, C(0xE8E0D0))
    cbLine(c, 36, 35, 47, 29, neck, 0.6); c.rect(47, 28, 2, 2, C(0x2A1A10))
    // The duck walk: a hop every beat.
    let beat = frac(d.e / 0.6)
    if beat < 0.5 { c.shift(dx: 0, dy: -1) }
    // Notes rising off it.
    for i in 0..<3 {
        let k = frac(d.e * 0.5 + Double(i) / 3)
        let x = 44 + i * 4 + Int((sin(k * 7 + Double(i)) * 2).rounded()), y = 26 - Int(k * 18)
        let note = C(0xFFF0A0, r * (1 - k))
        c.rect(x, y, 1, 3, note); c.px(x - 1, y + 3, note); c.px(x + 1, y, note)
    }
}
