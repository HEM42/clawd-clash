import Foundation

// Villains, 8 to 10 a file, drawn the same way as the heroes (HawkinsHeroes1.swift has the Persona fields and the
// order every drawing goes in).
//
// Magic (`weapon: .lightning`): `magic:` says how the stream looks, and the engine draws it from `pivot` (the casting
// hand, raised `p.armRaise` pixels: draw the arm raised as much). Its families:
//   Magic(core:glow:)                      forked lightning (the default)
//   jagged: false                          a steady, wavering ray (a sonic screwdriver, a flashlight beam)
//   jagged: false, spell: true             a twinkling ribbon of sparkles (sorcery)
//   jagged: false, rings: true             rings rippling out along a faint ray (mind powers)
//   jagged: false, waves: true             arcs pulsing out (sound, force)
//   notes: true, touch: true, rcCar: true  music, a glowing fingertip, a remote-controlled car
// Don't set `magic.variant` yourself: the engine numbers every magic user in order through all the universes
// (`magicVariants`), so no two anywhere look exactly alike, and a new universe only adds to the end.

let hawkinsVillains1: [HawkinsVillain: Persona] = [
    .sampleVillain: Persona(name: "Sample Villain", weapon: .lightning,
                            magic: Magic(core: C(0xF6E2FF), glow: C(0x9A3ADC), jagged: false, spell: true),
                            headTop: 18, signature: 3.2, callout: "Weeds always win.", draw: drawSampleVillain),
]

// MARK: - Sample Villain

/// Sample Villain: a thistle witch. Clawd in a plum hood with a pointed tip and a long plum robe to the ground, a
/// thistle-green sash, a purple amulet, and the toes of her black shoes under the hem. Her magic is a ribbon of violet
/// sparkles. Signature: she lifts both hands and a ring of thistle-down sparks gathers and whirls over her hood, then
/// fizzles out.
private func drawSampleVillain(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0x5A2E5E), robeD = C(0x3E1E42), robeL = C(0x7A4680)
    let sash = C(0x5E8A3A), sashD = C(0x42662A), amulet = C(0xC67AF0), shoe = C(0x1E161E)
    // The signature, 0…1 while the sparks are up: from a tenth of the way in to nine tenths, back to normal after.
    let spell = p.signature.map { $0 > 0.1 && $0 < 0.9 ? ($0 - 0.1) / 0.8 : -1 } ?? -1

    // 1. The legs, under the robe: drawn first all the same, for sitting and walking; the robe goes over them after
    //    the breath. Then the shoes' toes on the ground row, under where the hem will stop.
    drawLegs(c, Look(leg: robeD), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, lifted ? 42 : 43, 2, 1, shoe)
        }
    }

    // 2. The breath.
    c.oy += p.breathe

    // 3. Clawd's body. Her casting hand (the near one) rises `p.armRaise` pixels, which is where the engine starts
    //    the stream from; both hands go up for the signature.
    let raise = spell >= 0 ? 4 : p.armRaise
    drawBody(c, Look(arm: robe), armLeft: spell >= 0 ? 4 : 0, armRight: raise)

    // 4. The robe, long to the ground, as a robe should stay: never shortened to show the legs. It falls from the
    //    shoulders and flares a little; a soft shadow either side of each leg hints at the four legs under the cloth,
    //    and the hem stops a row above the ground so the toes peep out. It's the far side and the hem that are in
    //    shade, the left edge that's lit.
    c.rect(18, 33, 20, 5, robe)
    for y in 38...42 where y + c.oy <= 42 {
        let flare = (y - 38) / 2
        c.rect(17 - flare, y, 22 + 2 * flare, 1, robe)
        c.px(17 - flare, y, robeL); c.px(38 + flare, y, robeD)
        if y >= 39 { for x in [22, 26, 30, 34] { c.px(x, y, robeD) } }   // between the legs
    }
    c.rect(37, 33, 1, 5, robeD)
    c.rect(18, 33, 1, 5, robeL)
    // The sash, tied on the left with its ends hanging, and the amulet at her throat.
    c.rect(18, 36, 20, 1, sash); c.rect(18, 37, 20, 1, sashD)
    c.rect(20, 37, 1, 3, sash); c.rect(21, 37, 1, 2, sashD)
    c.pattern(27, 33, [".A.", "AaA", ".A."], ["A": amulet, "a": C(0xF4D8FF)])
    c.rect(25, 33, 2, 1, C(0x9A9AA6)); c.rect(30, 33, 2, 1, C(0x9A9AA6))   // its chain

    // 5. The hood: the engine's `drawHood` shape round her face, then its pointed tip leaning back, a lit run along the
    //    top and a seam down the middle, so it isn't a flat block of colour.
    drawHood(c, robe, robeD)
    c.rect(19, 25, 18, 1, robeD)   // the hood's shadow over her brow, so no see-through row is left above her face
    c.pattern(18, 15, [
        "......RRR..........",
        ".......RRRR........",
        "........RRRRR......",
        "..........RRR......",
    ], ["R": robe])
    c.rect(21, 20, 6, 1, robeL); c.rect(19, 21, 3, 1, robeL); c.px(17, 23, robeL)
    c.rect(28, 19, 1, 3, robeD)
    // Her brows, knitted.
    c.pattern(21, 27, ["dd.......dd", "..d.....d.."], ["d": C(0x2A1A2A)])

    // 6. The signature: a ring of thistle-down sparks over her hood, whirling, brightest in the middle of it. It stays
    //    above row 3 and inside the frame's sides, and it's see-through (a glow), so it gets no outline.
    if spell >= 0 {
        let strength = sin(spell * .pi)
        for k in 0..<8 {
            let a = Double(k) / 8 * 2 * .pi + spell * 9
            let x = 28 + Int((cos(a) * 9).rounded()), y = 10 + Int((sin(a) * 3).rounded())
            c.px(x, y, C(0xE8C8FF, strength)); c.px(x + 1, y, C(0x9A3ADC, strength * 0.6))
        }
    }
}
