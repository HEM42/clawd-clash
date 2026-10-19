#if CLAWD_TEMPLATE   // only in TEMPLATE=1 builds; Tools/new-universe.sh takes this line and the file's last one out
import Foundation

// HEM in this universe. He's the same rare face in every universe (the last hero, `Universe.hem`): his face, buns,
// body and fist-shaking signature are the engine's (Sources/App/Universes/Hem.swift). The costume is yours, drawn at
// fixed moments of him in this order: `legs`, then after the breath his body in `top`'s colours and `chest` over it,
// `hat` over his hair, his face, and `prop` in his hand. Dress him as someone from the franchise, or as a fan of it.
//
// Here: a long moss-green coat over a cream shirt, a straw hat with a red band, and a walking stick he fights with.

private let coat = C(0x4E7A3A), coatDark = C(0x365628), coatLight = C(0x6A9A4E)
private let straw = C(0xE2C47A), strawDark = C(0xB8984E), band = C(0xB83A2E)
private let stick = C(0x8A5A32), stickDark = C(0x5E3A1E)

let templateHem = HemCostume(
    // His persona: weapon (and shot or magic), muzzle or pivot, the top of his head with the hat on, and a signature
    // length (the engine's fist-shaking runs 0…1 through it).
    persona: { Persona(name: "HEM", weapon: .saber, headTop: 15, signature: 2.6, draw: $0) },
    legs: { c, p in   // brown corduroys and boots a shade darker, before the breath so they stay on the ground
        drawLegs(c, Look(leg: C(0x6A4E34)), step: p.step)
        drawBoots(c, C(0x3A2818), step: p.step, rows: 2)
    },
    top: (coat, coatDark, coat, coat),
    chest: { c, _ in   // the coat open over a cream shirt, its lapels lit on the left edge, two buttons
        c.rect(25, 34, 6, 4, C(0xEEE6D0)); c.rect(25, 34, 6, 1, C(0xD4CAB0))
        c.rect(24, 34, 1, 4, coatLight); c.rect(31, 34, 1, 4, coatDark)
        c.px(22, 35, C(0xC8B888)); c.px(22, 37, C(0xC8B888))
    },
    prop: { c, p, _, _ in templateHemStick(c, angle: p.melee) },
    hat: { c, _ in   // the straw hat: a wide brim, a red band, the weave picked out in a few darker strokes
        c.pattern(18, 15, [
            "....SSSSSSSSSSSS....",
            "....SSsSSSSsSSSS....",
            "....SSSSSsSSSSsS....",
            "....RRRRRRRRRRRR....",
            "SSSSSSSSSSSSSSSSSSSS",
            ".ssssssssssssssssss.",
        ], ["S": straw, "s": strawDark, "R": band])
    })

/// His walking stick: swung at `angle` degrees from his hand (0 forward, -90 straight up), or, put away, standing
/// upright beside him with his hand on its knob (shorter while he sits, so it stops at the ground).
private func templateHemStick(_ c: PixelCanvas, angle: Double?) {
    guard let a = angle else {
        let h = seatedPose ? 10 : 14
        c.rect(41, 30, 2, h, stick); c.rect(42, 30, 1, h, stickDark); c.rect(40, 29, 4, 2, stickDark)
        return
    }
    let r = a * .pi / 180, hx = Sprite.hand.x, hy = Sprite.hand.y
    c.glowLine(hx - cos(r) * 2, hy - sin(r) * 2, hx + cos(r) * 15, hy + sin(r) * 15,
               core: stick, glow: C(0x000000, 0), coreR: 0.9, glowR: 1.0)
    c.px(Int(hx + cos(r) * 15), Int(hy + sin(r) * 15), stickDark)
}
#endif   // CLAWD_TEMPLATE
