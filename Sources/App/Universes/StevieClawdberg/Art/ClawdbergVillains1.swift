import Foundation

// Villains: the Indiana Jones films. Clawd in costume here too: hats, suits, uniforms (never an insignia) and robes
// over the blocky body.

let clawdbergVillains1: [ClawdbergVillain: Persona] = [
    .reneBellock: Persona(name: "René Bellock", weapon: .blaster, shot: .arrow, muzzle: (50, 31), headTop: 20,
                          signature: 3.2, callout: "Again, Dr. Jones…", draw: drawReneBellock),
]

// MARK: - René Bellock

/// René Bellock: Clawd in a cream linen suit over a pale shirt, a panama hat with a black band, and two-tone shoes.
/// He fights with a blowpipe, put to his lips to fire a dart. Signature: he holds up the golden idol in both hands,
/// turns it to the light so it glints, and admires it.
private func drawReneBellock(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0xECE6D4), suitD = C(0xC8C0A8), shirt = C(0xF6F2E6), tie = C(0x8A7A5A)
    let straw = C(0xE8D8A8), strawD = C(0xC4B080), pipe = C(0x9A7A48)
    let sig = p.signature
    let admiring = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: suit), step: p.step)
    cbBoots(c, step: p.step, C(0x6A4A2E), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    // The linen suit, its open collar and a loose tie.
    c.rect(18, 34, 20, 4, suit); c.rect(37, 34, 1, 4, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(25, 34, ["dSSSSd", ".dTTd.", "..TT.."], ["d": suitD, "S": shirt, "T": tie])
    // The panama.
    cbFedora(c, felt: straw, dark: strawD, band: C(0x1E1A16))

    if admiring {
        // The golden idol held up before his face in both hands, a glint running over it.
        let k = sig!
        let y = 26 - Int((min(1, (k - 0.06) / 0.2) * 3).rounded())
        c.rect(36, y + 6, 3, 3, suit); c.rect(15, y + 6, 3, 3, suit)
        c.pattern(39, y, [".GGG.", "GgGgG", "GGGGG", ".GGG.", ".GgG.", "GGGGG", ".G.G."],
                  ["G": C(0xE8B830), "g": C(0x8A6418)])
        let glint = Int(p.t * 3) % 6
        if glint < 3 { c.px(40 + glint, y + 1, C(0xFFF6C8)) }
        return
    }
    if p.fire != nil || p.ready {
        // The blowpipe at his lips, held out level in his right hand.
        c.rect(38, 31, 3, 3, suit)
        c.rect(36, 31, 14, 1, pipe); c.px(49, 31, C(0x6A5030))
        return
    }
    // At rest: the blowpipe held upright by his side.
    c.rect(41, 24, 1, 14, pipe); c.rect(38, 33, 3, 3, suit)
}
