import Foundation

// HEM in The Clawd Files: a tan trench coat, an FBI lanyard, and a flashlight.

private let trench = C(0xB89A66), trenchDark = C(0x8A7048)

let filesHem = HemCostume(
    persona: {
        Persona(name: "HEM", weapon: .lightning, magic: Magic(core: C(0xFFFBE8), glow: C(0xFFE9A0), jagged: false),
                pivot: hemSonicTip, headTop: 21, signature: 2.6, draw: $0)
    },
    legs: { c, p in   // the trench coat's tails over grey trousers and black shoes
        drawLegs(c, Look(leg: C(0x4A4A54)), step: p.step)
        drawDressShoes(c, step: p.step)
        c.rect(17, 38, 22, seatedPose ? 1 : 3, trench); c.rect(28, 38, 1, seatedPose ? 1 : 3, trenchDark)
    },
    top: (trench, trenchDark, trench, trench),
    chest: { c, _ in   // the coat open over a shirt, the lanyard and its FBI card
        c.rect(24, 34, 8, 4, C(0xE8E6E0)); c.px(25, 34, C(0x2E4A8A)); c.px(30, 34, C(0x2E4A8A))
        c.px(26, 35, C(0x2E4A8A)); c.px(29, 35, C(0x2E4A8A))
        c.pattern(26, 36, ["WWWW", "WBBW"], ["W": white, "B": C(0x2E4A8A)])
    },
    prop: { c, _, out, lift in drawHemFlashlight(c, out: out, lift: lift) },
    raisesArm: true)

/// His flashlight: held down by his side at rest; pointed out, its lens at `hemSonicTip` (`lift` higher). The beam
/// itself is the persona's steady stream.
private func drawHemFlashlight(_ c: PixelCanvas, out: Bool, lift: Int) {
    let body = C(0x2E2E34), rim = C(0x6A6A74), lens = C(0xFFF6D0)
    if out {
        let y = 31 - lift
        c.rect(41, y, 4, 2, body); c.rect(45, y - 1, 1, 4, rim); c.rect(46, y, 1, 2, lens)
    } else {
        c.rect(40, 34, 2, 4, body); c.rect(40, 38, 2, 1, rim)
    }
}

