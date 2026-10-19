import Foundation

// Heroes, 8 to 10 a file: each one a `Persona` in the dictionary below and a `private func draw…` further down. Read
// the clawdify guide's "Look and style" before drawing, and the header of Sources/App/Pose.swift for what a `Pose`
// gives you. Check every character with `build/preview cast out.png <name>`, and its edges with
// `build/preview edges out.txt "<Title>"` (both from Tools/Preview/build.sh).
//
// A `Persona` says how a character fights and moves (Sources/App/Persona.swift has every field):
//   weapon   .saber     up close: swords, fists, claws, bats, staffs. Deflects shots, blocks magic.
//            .blaster   at range, with `shot:` saying how it looks: .energy(core:glow:), .beam(core:glow:), .bullet,
//                       .arrow, .fire, .ice, .card, .thrown(colour), .web. `muzzle:` is where shots leave (canvas
//                       pixels, facing right); `handGun: false` when it's built in (repulsors, eyes).
//            .lightning magic and energy streams, with `magic:` saying how it looks (see HawkinsVillains1.swift).
//            .none      stays out of fights: runs, points, cheers.
//   motion   .walk (the default), .fly (takes off to travel), .hover (never quite touches the ground), .swing (a web
//            line, coloured by the module's `swingLine`).
//   armoured shots ricochet off it (robots, armour, rock).  bulk  pixels further forward than plain Clawd its body
//            reaches, so duels stand further apart.  canSit  false for what can't sit (a fish, a ghost).
//   headTop  the head's real top row, with its hat or hair: its name tag goes above it.
//   signature  2 to 4 seconds of its own move, played now and then while it's idle. The drawing reads `p.signature`
//            (0…1 through it, nil the rest of the time), starts and ends in the normal pose, and has to read at
//            desktop size.
//   callout  a line it says now and then while it leads a session.
// Research each character's real weapon, colour and way of moving: a wrong one breaks it for fans.

let hawkinsHeroes1: [HawkinsHero: Persona] = [
    .sampleHero: Persona(name: "Sample Hero", weapon: .blaster, shot: .energy(core: C(0xE8FFF0), glow: C(0x2EC46A)),
                         muzzle: (47, 32), headTop: 18, signature: 3.0, callout: "Nothing grows in a day!",
                         draw: drawSampleHero),
]

// MARK: - Sample Hero

/// Sample Hero: a warden of the meadow. Clawd in a field cap with its peak forward, short tousled brown hair under it,
/// an olive field jacket open over a red neckerchief, a belt with a brass buckle and a pouch, olive trousers and brown
/// boots. Fights with a seed-pod pistol that fires green bolts. Signature: tips the cap, lifting it off by the peak
/// and putting it back.
///
/// Drawn step by step, in the order every character is: the legs, the breath, the body, the costume over it from the
/// back to the front, the hair and the hat, then what's in the hand.
private func drawSampleHero(_ c: PixelCanvas, _ p: Pose) {
    // Two or three tones to a material: a base, a shade and a highlight. The light comes from the front left, so tops
    // and left edges catch it and the right side and the underside fall in shade.
    let jacket = C(0x6A7240), jacketD = C(0x4C5230), jacketL = C(0x868E56)
    let cap = C(0x7A7E48), capD = C(0x585C32), capL = C(0x969A5E)
    let hair = C(0x5A3A22), hairD = C(0x3E2614), hairL = C(0x7A5232)
    let scarf = C(0xB8342A), scarfD = C(0x86221C), brass = C(0xD8B048), leather = C(0x5E3E24)
    // The signature, 0…1 through tipping the cap: up off his head by the middle of it and back on before the end, so
    // it starts and ends in the normal pose. -1: not tipping.
    let tip = p.signature.map { $0 > 0.1 && $0 < 0.9 ? ($0 - 0.1) / 0.8 : -1 } ?? -1
    let lift = tip >= 0 ? Int((sin(tip * .pi) * 4).rounded()) : 0

    // 1. The legs, before the breath, so a 1-pixel bob never opens a gap: olive trousers, and boots a shade apart from
    //    them, their toes lit. `drawLegs` folds them up by itself when he sits.
    drawLegs(c, Look(leg: C(0x5A5E36)), step: p.step)
    drawBoots(c, C(0x4A3020), step: p.step, rows: 2)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() where !(p.step >= 0 && i % 2 == p.step) { c.px(lx, 42, C(0x6A4830)) }
    }

    // 2. Everything above the legs breathes: one pixel up and down.
    c.oy += p.breathe

    // 3. Clawd's own body: the orange block, its eyes and arm nubs. His right arm (the near one, on the right) rises
    //    to his cap while he tips it.
    drawBody(c, Look(arm: jacket), armRight: tip >= 0 ? 7 + lift : 0)

    // 4. The jacket over the body, back to front: its base, the far side and the hem in shade, the collar lit, open
    //    down the front over the neckerchief, a fold either side, the belt and its buckle, a pouch, the cuffs.
    c.rect(18, 33, 20, 5, jacket)
    c.rect(37, 33, 1, 5, jacketD); c.rect(18, 37, 20, 1, jacketD)
    c.rect(19, 33, 4, 1, jacketL); c.rect(32, 33, 4, 1, jacketL); c.px(18, 33, jacketL)
    c.rect(24, 33, 8, 2, scarf); c.rect(24, 34, 8, 1, scarfD); c.rect(26, 35, 3, 1, scarf); c.px(27, 36, scarfD)
    c.rect(23, 34, 1, 3, jacketL); c.rect(32, 34, 1, 3, jacketD)
    c.px(20, 35, jacketD); c.px(35, 35, jacketD)
    c.rect(18, 36, 20, 1, leather); c.rect(26, 36, 3, 1, brass); c.px(27, 36, leather)
    c.rect(19, 35, 3, 2, leather); c.px(19, 35, C(0x7A5634))
    c.rect(15, 35, 3, 1, jacketD)
    if tip < 0 { c.rect(38, 35, 3, 1, jacketD) }

    // 5. The face is Clawd's own: here only a lit cheek and the brows, a pixel over each eye.
    c.rect(22, 28, 2, 1, hairD); c.rect(32, 28, 2, 1, hairD)

    // 6. The hair, short and tousled: short strokes that follow its shape with a lit run along the top, never
    //    scattered single pixels (specks read as dirt). It shows under the cap's edge and in front of the ears.
    //    It runs from under the cap down to the top of his face, with no gap: a see-through row between them would
    //    get an outline of its own and read as a white line across his forehead.
    c.pattern(17, 23, [
        ".HHlHHHHlHHHHHlHHHHHH.",
        ".HHHHhHHHHHhHHHHHhHHH.",
        ".HHhHHhHHhHHHhHHhHHhH.",
        ".HH................HH.",
        ".Hh................hH.",
    ], ["H": hair, "h": hairD, "l": hairL])

    // 7. The cap: a crown with its seam, a band, and the peak out over his eyes towards the way he faces. While he
    //    tips it, it rises `lift` pixels in his hand; the hair under it shows meanwhile.
    let cy = 18 - lift
    c.pattern(18, cy, [
        "...CCCCCCCCCCCCC......",
        "..CCLLLCCCsCCCCCC.....",
        ".CCLCCCCCCsCCCCCCC....",
        ".CCCCCCCCCsCCCCCCCPPP.",
        ".BBBBBBBBBBBBBBBBBPPPP",
    ], ["C": cap, "L": capL, "s": capD, "B": capD, "P": C(0x4A4E28)])
    if tip >= 0 {
        // His hand at the peak, holding it up, the sleeve down to his raised arm.
        c.rect(38, cy + 6, 3, 2, jacket); c.px(40, cy + 7, jacketD)
        c.rect(38, cy + 4, 3, 2, clawdOrange); c.px(40, cy + 5, clawdShade)
        return   // the pistol stays holstered while he tips his cap
    }

    // 8. What's in the hand, last, so it's in front of everything. A held gun goes `p.gunY` up or down from where it
    //    rests (recoil, or raised to check it); `muzzle` in the persona is where its shots leave, (47, 32) here.
    c.oy += p.gunY
    c.pattern(40, 31, [
        "KKKKKKG",
        "KKTKKK.",
        "WW.....",
        "WW.....",
    ], ["K": C(0x2E3A2A), "T": C(0x7AD08A), "G": C(0x4AE07A), "W": C(0x6A4428)])
}
