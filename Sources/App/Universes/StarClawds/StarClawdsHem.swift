import Foundation

// HEM in Star Clawds: Princess Laya's white robe, its hem over his shoes, and a little blaster.

private let robe = C(0xF4F4F0), robeShade = C(0xD2D4DA)

let starClawdsHem = HemCostume(
    persona: { Persona(name: "HEM", weapon: .blaster, canSit: false, muzzle: (47, 32), headTop: 21, signature: 2.6, draw: $0) },
    legs: { c, p in   // the robe's hem, his shoes peeking out
        for y in 38...43 {
            let q = (y - 38) / 2
            c.rect(17 - q, y, 22 + q * 2, 1, robe); c.px(17 - q, y, robeShade); c.px(38 + q, y, robeShade)
            if y > 39 { c.px(24, y, robeShade); c.px(31, y, robeShade) }
        }
        let lifted = p.step >= 0 ? (p.step == 0 ? 0 : 1) : -1
        c.rect(19, lifted == 0 ? 43 : 44, 4, 1, ink); c.rect(33, lifted == 1 ? 43 : 44, 4, 1, ink)
    },
    top: (robe, robeShade, robe, robe),
    chest: { c, _ in
        c.rect(17, 37, 22, 1, C(0xB8BEC9)); for x in [20, 23, 32, 35] { c.px(x, 37, C(0xEEF0F4)) }
        c.rect(27, 36, 2, 2, C(0xEEF0F4))
    },
    prop: { c, p, _, _ in   // a little blaster, kicking with each shot
        c.pattern(41, 31 + p.gunY, ["KKKKKK", "KKTKK.", "KK...."], ["K": C(0x2A2A30), "T": C(0x8A8F9C)])
    })
