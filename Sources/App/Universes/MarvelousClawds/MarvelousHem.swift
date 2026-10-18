import Foundation

// HEM in Marvelous Clawds: a purple-and-gold captain, an H on his chest and his winged helmet, and the round shield.

private let capPurple = C(0x5B2D8E), capPurpleDark = C(0x43206A), capGold = C(0xE8B33A)

let marvelousHem = HemCostume(
    persona: { Persona(name: "HEM", weapon: .saber, headTop: 21, signature: 2.6, draw: $0) },
    legs: { c, p in
        drawLegs(c, Look(leg: capPurple), step: p.step)
        if !seatedPose {
            for (i, lx) in [19, 23, 31, 35].enumerated() { c.rect(lx, p.step >= 0 && i % 2 == p.step ? 41 : 42, 2, 2, capGold) }
        }
    },
    top: (capPurple, capPurpleDark, capPurple, capPurple),
    chest: { c, _ in
        for x in 17...38 { c.px(x, 37, x % 2 == 0 ? capGold : white) }
        c.pattern(18, 34, ["H.H", "HHH", "H.H"], ["H": capGold])
    },
    prop: { c, p, _, _ in
        if let a = p.melee {
            for (i, ta) in p.trail.enumerated() {
                let (x, y) = hemShieldAt(ta)
                drawHemShield(c, cx: x, cy: y, alpha: 0.35 / Double(i + 1))
            }
            let (x, y) = hemShieldAt(a)
            drawHemShield(c, cx: x, cy: y)
        } else {
            drawHemShield(c, cx: 44, cy: seatedPose ? 32 : 34)
        }
    },
    hat: { c, _ in   // the helmet: purple, the H, little white wings
        c.pattern(17, 21, ["....HHHHHHHHHHHHHH....", "..HHHHHHHHHHHHHHHHHH..", ".HHHHHHHHHHHHHHHHHHHH.", "HHHHHHHHHHHHHHHHHHHHHH",
                           "HHHHHHHHHHHHHHHHHHHHHH", "HH..................HH"], ["H": capPurple])
        c.pattern(26, 21, ["H..H", "HHHH", "H..H", "H..H"], ["H": capGold])
        c.pattern(15, 21, ["W.", "WW", ".W"], ["W": white]); c.pattern(39, 21, [".W", "WW", "W."], ["W": white])
    },
    shield: { c in drawHemShield(c, cx: 15, cy: seatedPose ? 33 : 35) })

/// The shield's centre held out at `angle` degrees from the hand.
private func hemShieldAt(_ angle: Double) -> (Int, Int) {
    let r = angle * .pi / 180
    return (Int((Sprite.hand.x + cos(r) * 5).rounded(.down)), Int((Sprite.hand.y + sin(r) * 5).rounded(.down)))
}

/// The round shield: gold, white, purple, with a gold H in the middle.
private func drawHemShield(_ c: PixelCanvas, cx: Int, cy: Int, alpha: Double = 1) {
    for (r, col) in [(5, capGold), (4, white), (2, capPurple)] { c.ellipse(cx, cy, r, r, col.alpha(alpha)) }
    c.pattern(cx - 1, cy - 1, ["H.H", "HHH", "H.H"], ["H": capGold.alpha(alpha)])
}

