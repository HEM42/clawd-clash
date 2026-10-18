import Foundation

// HEM in Stevie Clawdberg: a fedora, a leather jacket over a khaki shirt, the satchel's strap, and a bullwhip.

private let leather = C(0x6A3E22), leatherDark = C(0x4A2A16), felt = C(0x7A5A3A), feltDark = C(0x5A402A)

let clawdbergHem = HemCostume(
    persona: { Persona(name: "HEM", weapon: .saber, headTop: 20, signature: 2.6, draw: $0) },
    legs: { c, p in   // khaki trousers and brown boots
        drawLegs(c, Look(leg: C(0xA89468)), step: p.step)
        cbBoots(c, step: p.step, C(0x4A2E1A), height: 3)
    },
    top: (leather, leatherDark, leather, leather),
    chest: { c, _ in   // the jacket open over a khaki shirt, and the satchel's strap across it
        c.rect(24, 34, 8, 4, C(0xC8B48A)); c.px(24, 34, leatherDark); c.px(31, 34, leatherDark)
        for i in 0..<4 { c.px(25 + i * 2, 34 + i, C(0x8A7A52)); c.px(26 + i * 2, 34 + i, C(0x8A7A52)) }
    },
    prop: { c, p, _, _ in
        if let a = p.melee { cbWhip(c, angle: a, trail: p.trail, t: p.t, leather: C(0x5A3A22)) } else { cbWhipCoil(c, C(0x5A3A22)) }
    },
    hat: { c, _ in cbFedora(c, felt: felt, dark: feltDark, band: C(0x3A2416)) })
