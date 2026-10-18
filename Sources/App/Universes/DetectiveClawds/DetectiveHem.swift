import Foundation

// HEM in Detective Clawds: Harlee's jacket, red and blue, over fishnets, his buns dyed pink and blue, a little heart on
// his cheek and a toy wand.

private let harleeRed = C(0xC8202A), harleeBlue = C(0x2E5CC9)

let detectiveHem = HemCostume(
    persona: {
        Persona(name: "HEM", weapon: .blaster, shot: .energy(core: C(0xFFF6C8), glow: C(0xFF7AC8)), muzzle: (52, 27),
                headTop: 21, signature: 2.6, draw: $0)
    },
    legs: { c, p in
        let net = C(0x3A3A44)
        drawLegs(c, Look(leg: net), step: p.step)
        if !seatedPose {
            for (i, lx) in [19, 23, 31, 35].enumerated() {
                let top = p.step >= 0 && i % 2 == p.step ? 36 : 37
                c.px(lx, top + 3, C(0x6A6A78)); c.px(lx + 1, top + 5, C(0x6A6A78))   // fishnets
                c.rect(lx, top + 6, 2, 1, ink)
            }
        }
    },
    top: (white, C(0xD8D8DC), harleeRed, harleeBlue),
    chest: { c, _ in c.rect(17, 34, 3, 4, harleeRed); c.rect(36, 34, 3, 4, harleeBlue); c.rect(17, 37, 22, 1, C(0x2A2A32)) },
    prop: { c, p, _, _ in drawWand(c, raised: p.fire != nil || p.ready || p.cheering, gunY: p.gunY, t: p.t) },
    dyedBuns: (left: (C(0xF06AA8), C(0xC84A86)), right: (C(0x4A8CF0), C(0x2E68C8))),
    overFace: { c, _, _ in c.pattern(36, 32, [".R.R", "RRRR", ".RR."], ["R": C(0xE8323A)]) })   // the little heart on his cheek

/// A pink toy wand with a yellow star, glitter turning round it; tipped forward when he uses it (the star at the
/// persona's muzzle, (52, 27)).
private func drawWand(_ c: PixelCanvas, raised: Bool, gunY: Int, t: Double) {
    let stick = C(0xF7A8D0), star = C(0xFFE14A), starShade = C(0xF2B620)
    let x = 41, y = (raised ? 32 : 35) + gunY
    if raised { for i in 0..<7 { c.px(x + i, y - i / 2, stick) } } else { c.rect(x, y - 6, 1, 7, stick) }
    let sx = raised ? x + 7 : x - 2, sy = raised ? y - 7 : y - 11
    c.pattern(sx, sy, ["..Y..", ".YYY.", "YYyYY", ".YYY.", ".Y.Y."], ["Y": star, "y": starShade])
    if raised { c.px(x + 3, y - 1, C(0x7AD0FF)); c.px(x + 4, y - 2, C(0xC88CFF)) }   // ribbons
    let glitter = [C(0xFF7AC8), C(0x7AD0FF), C(0xFFE14A), white, C(0xC88CFF)]
    let k = Int(t * 6)
    for i in 0..<5 {
        let a = Double(i) * 1.3 + t * 5.4
        c.px(sx + 2 + Int(cos(a) * 5), sy + 2 + Int(sin(a) * 4), glitter[(i + k) % glitter.count])
    }
}

