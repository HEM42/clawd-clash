import Foundation

// HEM in Stranger Clawds: a Hellfire Club t-shirt, black with the club's red horned emblem, a maroon cap with its peak
// forward, a walkie-talkie clipped to his belt, jeans and white sneakers, and a nail bat, Steve's, to fight with.

private let tee = C(0x1E1C22), teeDark = C(0x0E0C12), cap = C(0x8A2228), capDark = C(0x5E141A), capLight = C(0xB03A3E)
private let wood = C(0xB08850), woodDark = C(0x7E5E34), nail = C(0xC4C8D0)

let hawkinsHem = HemCostume(
    persona: { Persona(name: "HEM", weapon: .saber, headTop: 17, signature: 2.6, draw: $0) },
    legs: { c, p in   // jeans, and white sneakers with grey soles
        drawLegs(c, Look(leg: C(0x3A4E74)), step: p.step)
        drawBoots(c, C(0xE0E0DA), step: p.step, rows: 2)
        drawBoots(c, C(0xA0A0AA), step: p.step, rows: 1)
    },
    top: (tee, teeDark, tee, tee),
    chest: { c, _ in
        // The Hellfire Club's emblem beside his beard, a little red horned face with white eyes, and the club's
        // name in a red line of lettering along the hem.
        c.pattern(18, 34, ["R...R", "RwRwR", ".RRR."], ["R": C(0xD0222C), "w": C(0xF0ECE4)])
        for x in stride(from: 20, to: 36, by: 1) where x % 5 != 3 { c.px(x, 37, C(0xC8202A)) }
        // The walkie-talkie on his belt, at his hip, its aerial up over the tee.
        c.rect(34, 34, 3, 4, C(0x3A3A42)); c.rect(34, 34, 3, 1, C(0x5A5A64)); c.px(35, 36, C(0xE03A3A))
        c.rect(35, 31, 1, 3, C(0x2A2A2E))
    },
    prop: { c, p, _, _ in hawkinsHemBat(c, angle: p.melee) },
    hat: { c, _ in   // the cap: a maroon crown with a seam and a lit run, its band, and the peak forward
        c.pattern(17, 17, [
            ".....CCCCCCCCCC.......",
            "...CCLLLCCCsCCCCC.....",
            "..CCLCCCCCCsCCCCCC....",
            ".CCCCCCCCCCsCCCCCCC...",
            ".BBBBBBBBBBBBBBBBBBpppp",
            "...................PPPPP",
        ], ["C": cap, "L": capLight, "s": capDark, "B": capDark, "P": capDark, "p": capLight])
    })

/// The nail bat: swung at `angle` degrees from his hand (0 forward, -90 straight up), its nails sticking out round the
/// end; or, put away, standing upright by his side with his hand on the handle (shorter while he sits).
private func hawkinsHemBat(_ c: PixelCanvas, angle: Double?) {
    guard let a = angle else {
        let top = seatedPose ? 26 : 22
        c.rect(41, top + 6, 1, 36 - top - 6, woodDark); c.rect(40, top, 3, 6, wood); c.rect(42, top, 1, 6, woodDark)
        for (x, y) in [(39, top + 1), (43, top + 2), (39, top + 4), (43, top + 5), (41, top - 1)] { c.px(x, y, nail) }
        return
    }
    let r = a * .pi / 180, hx = Sprite.hand.x, hy = Sprite.hand.y
    c.glowLine(hx - cos(r) * 2, hy - sin(r) * 2, hx + cos(r) * 8, hy + sin(r) * 8,
               core: woodDark, glow: C(0x000000, 0), coreR: 0.7, glowR: 0.8)
    c.glowLine(hx + cos(r) * 8, hy + sin(r) * 8, hx + cos(r) * 15, hy + sin(r) * 15,
               core: wood, glow: C(0x000000, 0), coreR: 1.3, glowR: 1.4)
    // The nails, poking out either side of the barrel.
    for d in [10.0, 12.5, 15.0] {
        for side in [-1.0, 1.0] {
            c.px(Int((hx + cos(r) * d - sin(r) * 2.4 * side).rounded()), Int((hy + sin(r) * d + cos(r) * 2.4 * side).rounded()), nail)
        }
    }
}
