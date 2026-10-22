import Foundation

// HEM in Clawd Burton: a crooked black top hat with a spiral band, a black-and-white striped scarf and a big spiral
// lollipop he swings like a club.

private let burtonCoat = C(0x2A2633), burtonCoatDark = C(0x1C1824)

let burtonHem = HemCostume(
    persona: { Persona(name: "HEM", weapon: .saber, headTop: 12, signature: 2.6, draw: $0) },
    legs: { c, p in   // charcoal trousers and black shoes
        drawLegs(c, Look(leg: C(0x34303C)), step: p.step)
        burtonBoots(c, step: p.step, C(0x18181C))
    },
    top: (burtonCoat, burtonCoatDark, burtonCoat, burtonCoat),
    chest: { c, _ in   // the striped scarf round his neck, one end hanging down his front
        burtonStripes(c, 17, 34, 22, 1, alongX: true)
        burtonStripes(c, 22, 35, 3, 3, alongX: false, width: 1)
    },
    prop: { c, p, _, _ in
        if let a = p.melee { burtonLollipop(c, angle: a, trail: p.trail) } else { burtonLollipop(c, angle: -78, trail: [], from: (40, 35)) }
    },
    hat: { c, _ in burtonTopHat(c) })
