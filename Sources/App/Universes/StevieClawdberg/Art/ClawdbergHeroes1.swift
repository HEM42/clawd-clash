import Foundation

// Heroes: the Indiana Jones films. Clawd in costume like the rest of the cast: hats, hair and clothes drawn over the
// blocky body, with Clawd's own orange face showing.

let clawdbergHeroes1: [ClawdbergHero: Persona] = [
    .indianaBones: Persona(name: "Indiana Bones", weapon: .saber, headTop: 20, signature: 3.0,
                           callout: "It belongs in a museum!", draw: drawIndianaBones),
]

// MARK: - Indiana Bones

/// Indiana Bones: Clawd in the brown fedora, the battered leather jacket open over a khaki shirt, khaki trousers and
/// brown boots, the satchel on his hip on its strap across his chest; the bullwhip coiled at his side, cracked in a
/// fight. Signature: he cracks the whip overhead, the crack knocks his own hat off, and he snatches it out of the air
/// and claps it back on.
private func drawIndianaBones(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x6A4028), jacketD = C(0x4A2C1A), shirt = C(0xC8B48A), shirtD = C(0xA8946A)
    let felt = C(0x7A5A3A), feltD = C(0x5A402A), band = C(0x2E1E12), whip = C(0x5A3A22), canvas = C(0x8A7A52)
    let sig = p.signature
    let cracking = sig.map { $0 > 0.05 && $0 < 0.4 } ?? false
    let hatK = sig.map { $0 >= 0.3 && $0 < 0.75 ? ($0 - 0.3) / 0.45 : -1 } ?? -1   // 0…1 while the hat's off

    drawLegs(c, Look(leg: C(0x9A8A62)), step: p.step)
    cbBoots(c, step: p.step, C(0x4A2E1A), height: 3)
    c.oy += p.breathe
    // The satchel, hanging at his left hip.
    c.rect(13, 35, 5, 4, canvas); c.rect(13, 35, 5, 1, C(0x6A5A3A)); c.px(15, 36, C(0x5A4A2A))
    drawBody(c, Look(arm: jacket))
    // The jacket open over the shirt, and the satchel's strap across his chest.
    c.rect(18, 34, 20, 4, jacket); c.rect(37, 34, 1, 4, jacketD); c.rect(18, 37, 20, 1, jacketD)
    c.rect(24, 34, 8, 4, shirt); c.px(27, 35, shirtD); c.px(27, 37, shirtD)
    c.rect(23, 34, 1, 3, C(0x8A5A38)); c.rect(32, 34, 1, 3, C(0x8A5A38))   // the lapels
    for i in 0..<4 { c.px(33 - i * 2, 34 + i, canvas); c.px(32 - i * 2, 34 + i, canvas) }

    // The hat: on his head, or knocked up off it by the crack, tumbling, and grabbed back.
    if hatK < 0 {
        cbFedora(c, felt: felt, dark: feltD, band: band)
    } else {
        let lift = Int((sin(hatK * .pi) * 9).rounded())
        cbFedora(c, felt: felt, dark: feltD, band: band, lift: lift)
        // His hair, briefly bare, and his left arm up after the hat once it's coming down.
        c.pattern(18, 23, ["..HHHHHHHHHHHHHHHH..", ".HHHHHhHHHHHHhHHHHH.", "HHHHHHHHHHHHHHHHHHHH"],
                  ["H": C(0x4A2E1A), "h": C(0x6A4428)])
        if hatK > 0.45 { c.rect(15, 26 - lift, 3, 9 + lift, jacket); c.rect(15, 25 - lift, 3, 2, clawdOrange) }
    }

    if cracking {
        // The whip swung up over his head and cracked out in front.
        let k = (sig! - 0.05) / 0.35
        let a = -170 + k * 175
        c.rect(38, 30, 3, 3, jacket)
        cbWhip(c, angle: a, trail: [a - 30, a - 55], t: p.t, leather: whip, from: (39.5, 31.5))
        return
    }
    if let a = p.melee {
        cbWhip(c, angle: a, trail: p.trail, t: p.t, leather: whip)
    } else {
        cbWhipCoil(c, whip)
    }
}
