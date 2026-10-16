import Foundation

// Heroes: the Scooby Gang. Clawd in costume like the rest of the cast: hair and clothes drawn over the blocky body,
// with Clawd's own orange face showing.

let slayerHeroes1: [SlayerHero: Persona] = [
    .buffyClawmers: Persona(name: "Buffy Clawmers", weapon: .saber, headTop: 20, signature: 3.0,
                            callout: "Beep me if the apocalypse comes.", draw: drawBuffyClawmers),
    .willowRosenclaw: Persona(name: "Willow Rosenclaw", weapon: .lightning,
                              magic: Magic(core: C(0xDCFFC0), glow: C(0x34C060), jagged: false, spell: true),
                              headTop: 20, signature: 3.2, callout: "Resolve face!", draw: drawWillowRosenclaw),
]

// MARK: - Buffy Clawmers

/// Buffy Clawmers: Clawd with long blonde hair past her shoulders, a short black leather jacket open over a red top,
/// the silver cross Angel gave her at her throat, dark jeans and boots. She fights with a wooden stake. Signature: she
/// flips the stake up, it turns over twice in the air, and she catches it without looking.
private func drawBuffyClawmers(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x2A2226), jacketD = C(0x18131A), jacketL = C(0x463A40), top = C(0xC0304A), silver = C(0xE0E4EC)
    let hair = C(0xE8C46A), hairL = C(0xF8E2A0), hairD = C(0xC09A44)
    let flipK = p.signature.map { $0 > 0.12 && $0 < 0.82 ? ($0 - 0.12) / 0.7 : -1 } ?? -1   // 0…1 while it's in the air

    drawLegs(c, Look(leg: C(0x2E3550)), step: p.step)
    slBoots(c, step: p.step, C(0x1A1618), height: 3)
    c.oy += p.breathe
    drawBody(c, Look(arm: jacket), armRight: flipK >= 0 ? 2 : 0)
    // The jacket, short and open over the red top, with a highlight down its front edges.
    c.rect(18, 34, 20, 4, jacket); c.rect(37, 34, 1, 4, jacketD); c.rect(18, 37, 20, 1, jacketD)
    c.rect(24, 34, 8, 4, top); c.rect(24, 37, 8, 1, C(0x96223A))
    c.rect(23, 34, 1, 3, jacketL); c.rect(32, 34, 1, 3, jacketL)
    // The cross at her throat.
    c.pattern(27, 33, [".X", "XXX", ".X", ".X"], ["X": silver])
    // Long blonde hair, swept off her face, falling past her shoulders.
    c.pattern(16, 20, [
        "......HHHHHHHHHHHH......",
        "....HHHHHHlHHHHHHHHH....",
        "...HHHHHlHHHHHHHlHHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHH...........HHHHHH.",
        ".HHHH..............HHHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHl................lHH.",
        ".HHH................HHH.",
        ".HHd................dHH.",
        ".HHd................dHH.",
        ".dHd................dHd.",
        "..dd................dd..",
    ], ["H": hair, "l": hairL, "d": hairD])

    if flipK >= 0 {
        // Up it goes off her raised hand, turning over twice, and back down into it.
        let h = sin(flipK * .pi) * 13
        let angle = -90 + flipK * 720
        slStake(c, angle: angle, trail: [], from: (slHand.x, slHand.y - 2 - h), fist: false)
        return
    }
    if let a = p.melee {
        slStake(c, angle: a, trail: p.trail)
    } else {
        slStakeHeld(c)
    }
}

// MARK: - Willow Rosenclaw

/// Willow Rosenclaw: Clawd with long straight red hair parted in the middle, a fuzzy lilac jumper, a short green skirt
/// over dark tights and Mary Janes. Her magic is a ribbon of leaf-green sparkles. Signature: the pencil from
/// "Doppelgangland": she lifts a hand and a pencil floats up off it and spins in the air, a little green glow round
/// it, then drops back into her palm.
private func drawWillowRosenclaw(_ c: PixelCanvas, _ p: Pose) {
    let jumper = C(0xB48AD4), jumperD = C(0x8E66B0), fuzz = C(0xD6B8EE), skirt = C(0x4E6E3A), skirtD = C(0x384E2A)
    let hair = C(0xB4401E), hairL = C(0xD8642E), hairD = C(0x8A2E14), part = C(0x6E2210)
    let spinK = p.signature.map { $0 > 0.1 && $0 < 0.9 ? ($0 - 0.1) / 0.8 : -1 } ?? -1

    drawLegs(c, Look(leg: C(0x3E3046)), step: p.step)
    slBoots(c, step: p.step, C(0x141216), height: 1)
    // The skirt, short, over the tights: all four legs still show below it.
    c.rect(17, 38, 22, seatedPose ? 1 : 2, skirt); c.rect(17, seatedPose ? 38 : 39, 22, 1, skirtD)
    c.oy += p.breathe
    drawBody(c, Look(arm: jumper), armRight: spinK >= 0 ? 3 : p.armRaise)
    // The jumper, its fuzz picked out in pale flecks, a round neck.
    c.rect(18, 34, 20, 4, jumper); c.rect(37, 34, 1, 4, jumperD); c.rect(18, 37, 20, 1, jumperD)
    for (x, y) in [(19, 35), (22, 36), (25, 35), (30, 36), (33, 35), (35, 37), (20, 37), (28, 37)] { c.px(x, y, fuzz) }
    c.rect(25, 34, 6, 1, jumperD)
    // Long straight red hair, parted in the middle, down past her shoulders.
    c.pattern(16, 20, [
        ".....HHHHHHpHHHHHH......",
        "....HHHHHHHpHHHHHHH.....",
        "...HHHlHHHHpHHHHHlHH....",
        "..HHHHHHHHHpHHHHHHHHH...",
        "..HHHHHHHHHpHHHHHHHHHH..",
        ".HHHHHHHHHHpHHHHHHHHHHH.",
        ".HHHHHHHH......HHHHHHHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHl................HHH.",
        ".HHH................lHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHd................dHH.",
        ".HHd................dHH.",
        ".dHd................dHd.",
        ".dd..................dd.",
    ], ["H": hair, "l": hairL, "d": hairD, "p": part])

    guard spinK >= 0 else { return }
    // The pencil, floating over her raised palm and turning end over end.
    let cx = 40.0, cy = 23.0 - sin(spinK * .pi) * 2
    let a = spinK * 4 * .pi
    let ux = cos(a), uy = sin(a)
    for k in -2...2 {
        let col = k == 2 ? C(0x2A2A2A) : k == -2 ? C(0xE88AA0) : C(0xF0C838)
        c.px(Int((cx + ux * Double(k)).rounded()), Int((cy + uy * Double(k)).rounded()), col)
    }
    let glow = C(0x9CF0A0)
    for k in 0..<4 {
        let g = Double(k) * .pi / 2 + p.t * 3
        c.px(Int((cx + cos(g) * 4).rounded()), Int((cy + sin(g) * 3).rounded()), glow.alpha(0.5 + 0.5 * sin(p.t * 9 + Double(k))))
    }
}
