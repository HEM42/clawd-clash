import Foundation

// Detective Clawds's own drills (`UniverseModule.drills`): a few characters practise something only they would.

let detectiveBespokeDrills: [Cast: BespokeDrill] = [
        // The Flare: running on the spot, very, very fast.
        .hero(DetectiveHero.flash): { c, who, d, t in
            let r = setRamp(d)
            standing(c, who, t: t) { p in
                if r > 0.2 { p.step = Int(t * 16) % 2; p.breathe = 0; p.dx = Int(t * 16) % 2 }
            }
            guard r > 0.5 else { return }
            for i in 0..<4 {
                let y = 24 + Int(noise(Int(t * 12) + i * 5) * 18), len = 4 + Int(noise(Int(t * 12) + i) * 7)
                c.rect(15 - len - Int(noise(i * 3 + Int(t * 12)) * 4), y, len, 1, (i % 2 == 0 ? C(0xFFD21E) : C(0xFF3A2A)).alpha(0.8))
            }
            if noise(Int(t * 20)) > 0.6 {
                let x = 18 + Int(noise(Int(t * 20) + 3) * 20), y = 22 + Int(noise(Int(t * 20) + 5) * 20)
                c.px(x, y, C(0xFFF4A0)); c.px(x + 1, y - 1, C(0xFFD21E)); c.px(x + 2, y, C(0xFFF4A0))
            }
        },
        // Wondrous Woman: the golden lasso twirled in a loop over her head.
        .hero(DetectiveHero.wonderWoman): { c, who, d, t in
            standing(c, who, t: t)
            let r = setRamp(d)
            guard r > 0.1 else { return }
            let hand = Sprite.hand, centre = (Sprite.bodyCenterX + 4, 13.0), spin = t * 10
            let near = (centre.0 + cos(spin) * 11 * r, centre.1 + sin(spin) * 3 * r)
            c.glowLine(hand.x, hand.y - 1, near.0, near.1, core: C(0xFFD24A), glow: C(0xFFB000, 0.3), coreR: 0.4, glowR: 1)
            for i in 0..<18 {
                let a = Double(i) / 18 * 2 * .pi + spin
                c.px(Int((centre.0 + cos(a) * 11 * r).rounded()), Int((centre.1 + sin(a) * 3 * r).rounded()),
                     i % 3 == 0 ? C(0xFFF0A0) : C(0xFFC21E))
            }
        },
        // Green Lamplighter: willpower made solid, a glowing box, then a spring, then gone.
        .hero(DetectiveHero.greenLantern): { c, who, d, t in
            standing(c, who, t: t) { $0.armRaise = 3 }
            let period = 2.8, n = Int(d.e / period), f = frac(d.e / period)
            guard f < 0.8 else { return }
            let grow = min(1, f / 0.25), fade = f > 0.65 ? (0.8 - f) / 0.15 : 1
            let core = C(0xB8FFB0).alpha(fade), glow = C(0x3AE84A).alpha(0.8 * fade)
            let hand = (Sprite.hand.x, Sprite.hand.y - 3)
            c.glowLine(hand.0, hand.1, hand.0 + 8 * grow, hand.1, core: core, glow: glow, coreR: 0.3, glowR: 1)
            if n % 2 == 0 {
                let s = Int(10 * grow), x = 52, y = 44 - s
                c.rect(x, y, s, 1, core); c.rect(x, 43, s, 1, core); c.rect(x, y, 1, s, core); c.rect(x + s - 1, y, 1, s, core)
                if s > 2 { c.rect(x + 1, y + 1, s - 2, s - 2, glow.alpha(0.25 * fade)) }
            } else {
                for i in 0..<5 {
                    let y = 43 - Double(i) * 3 * grow
                    c.glowLine(52, y, 60, y - 1.5 * grow, core: core, glow: glow, coreR: 0.4, glowR: 1)
                }
                c.rect(51, Int(43 - 15 * grow), 10, 2, core)
            }
        },
]
