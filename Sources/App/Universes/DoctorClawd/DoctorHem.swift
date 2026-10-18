import Foundation

// HEM in Doctor Clawd: a tweed jacket over red braces and a bow tie, a fez (fezzes are cool), and a sonic screwdriver.

private let tweed = C(0x7A5232), tweedDark = C(0x5A3C24), fezRed = C(0xB8202A), fezDark = C(0x7A1218)

let doctorHem = HemCostume(
    persona: {
        Persona(name: "HEM", weapon: .lightning, magic: Magic(core: C(0xE8FFE0), glow: C(0x4ADB5A), jagged: false),
                pivot: hemSonicTip, headTop: 15, signature: 2.6, draw: $0)
    },
    legs: { c, p in
        drawLegs(c, Look(leg: C(0x2A2A32)), step: p.step)
        if !seatedPose {
            for (i, lx) in [19, 23, 31, 35].enumerated() { c.rect(lx, p.step >= 0 && i % 2 == p.step ? 41 : 42, 2, 2, C(0x3A2416)) }
        }
    },
    top: (tweed, tweedDark, tweed, tweed),
    chest: { c, _ in   // the jacket open over a shirt, red braces and the bow tie
        c.rect(24, 34, 8, 4, C(0xE8E2D4)); c.rect(25, 35, 1, 3, fezRed); c.rect(30, 35, 1, 3, fezRed)
        c.pattern(25, 34, ["RRrRR", "R...R"], ["R": fezRed, "r": fezDark])
    },
    prop: { c, _, out, lift in drawHemSonic(c, out: out, lift: lift) },
    hat: { c, _ in   // the fez, a little to the back, its tassel hanging
        c.pattern(22, 15, ["...FFFFFF..", "...FFFFFFK.", "..FFFFFFFFK", "..FFFFFFFF.", ".FFFFFFFFFF", ".ffffffffff"],
                  ["F": fezRed, "f": fezDark, "K": ink])
    },
    raisesArm: true)

/// His sonic screwdriver: held up in his fist at rest; pointed out, its green tip at `hemSonicTip` (`lift` higher).
private func drawHemSonic(_ c: PixelCanvas, out: Bool, lift: Int) {
    let grip = C(0x3A3A44), steel = C(0xC8CCD4), tip = C(0x7AF08A)
    if out {
        let y = 32 - lift
        c.rect(42, y, 2, 1, grip); c.rect(44, y - 1, 2, 1, steel); c.px(46, y - 2, tip)
    } else {
        c.rect(40, 29, 1, 4, grip); c.px(40, 28, steel); c.px(40, 27, tip.alpha(0.7))
    }
}

