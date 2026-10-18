import Foundation

// HEM in Clawd Slayer: a Watcher's tweed jacket over a white shirt and a dark green tie, and a wooden stake.

private let watcherTweed = C(0x8A7C5C), watcherTweedDark = C(0x665A40)

let slayerHem = HemCostume(
    persona: { Persona(name: "HEM", weapon: .saber, headTop: 21, signature: 2.6, draw: $0) },
    legs: { c, p in   // grey flannel trousers and brown brogues
        drawLegs(c, Look(leg: C(0x5E5E64)), step: p.step)
        slayerBoots(c, step: p.step, C(0x5A3A22))
    },
    top: (watcherTweed, watcherTweedDark, watcherTweed, watcherTweed),
    chest: { c, _ in   // the tweed open over a white shirt and a dark green tie, flecks in the cloth
        c.rect(24, 34, 8, 4, C(0xEEEAE0)); c.rect(27, 34, 2, 4, C(0x2E4A32)); c.px(27, 37, C(0x1E3222))
        for (x, y) in [(18, 35), (21, 36), (34, 35), (36, 37), (19, 37)] { c.px(x, y, watcherTweedDark) }
    },
    prop: { c, p, _, _ in if let a = p.melee { slayerStake(c, angle: a, trail: p.trail) } else { slayerStakeHeld(c) } })
