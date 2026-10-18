import Foundation

// Marvelous Clawds's own drills (`UniverseModule.drills`): a few characters practise something only they would.

let marvelousBespokeDrills: [Cast: BespokeDrill] = [
        // Spider-Clawd: a web yo-yo, down to the ground and back up into the hand.
        .hero(MarvelHero.spiderMan): { c, who, d, t in
            standing(c, who, t: t)
            let hand = (who.muzzle.x + 1, who.muzzle.y)
            let k = 0.5 - 0.5 * cos(d.e * 2 * .pi / 1.2)
            let end = (hand.0 + 4, hand.1 + 2 + 7 * k * setRamp(d))
            c.glowLine(hand.0, hand.1, end.0, end.1, core: C(0xF4F4F8, 0.9), glow: C(0xFFFFFF, 0), coreR: 0.35, glowR: 0.4)
            c.rect(Int(end.0) - 1, Int(end.1), 3, 3, C(0xF4F4F8))
            c.px(Int(end.0), Int(end.1) + 1, C(0xB8BCC8))
        },
        // Hawk-I: target practice at a straw boss on a stand, the arrows staying in it.
        .hero(MarvelHero.hawkeye): { c, who, d, t in
            let period = 1.6
            standing(c, who, t: t) { $0.fire = (d.e, false); $0.firePeriod = period }
            let tx = 64
            c.rect(tx + 2, 36, 1, 8, C(0x6A4A2A)); c.rect(tx + 4, 36, 1, 8, C(0x6A4A2A))      // the stand
            c.rect(tx, 25, 7, 13, C(0xE8DCC0))
            c.rect(tx + 1, 27, 5, 9, C(0xD83A2A)); c.rect(tx + 2, 29, 3, 5, C(0xE8DCC0)); c.rect(tx + 3, 30, 1, 3, C(0xD83A2A))
            let shots = Int(d.e / period), f = frac(d.e / period)
            for n in 0..<min(4, shots) {
                let y = 28 + Int(noise(d.seed &+ n * 7) * 7)
                for k in 1...4 { c.px(tx - k, y, k == 4 ? C(0xC83A2A) : C(0x6A4A2A)) }
            }
            if f < 0.3, shots < 4 {
                let y = 28 + noise(d.seed &+ shots * 7) * 7
                let from = (who.muzzle.x + 2, who.muzzle.y)
                let k = f / 0.3
                drawProjectile(c, .arrow, from: from, head: (from.0 + k * (Double(tx) - from.0), from.1 + k * (y - from.1)), t: t)
            }
        },
        // Thanoz: the gems glowing one by one round the gauntlet, then the snap.
        .villain(MarvelVillain.thanos): { c, who, d, t in
            standing(c, who, t: t) { $0.armRaise = 3 }
            let period = 3.2, f = frac(d.e / period)
            let hand = (who.weaponPivot.x, who.weaponPivot.y - 3)
            let gems = [C(0xFFE04A), C(0xFF3A3A), C(0x4A8AFF), C(0xB04AFF), C(0x3AE87A), C(0xFF9A2A)]
            if f < 0.7 {
                for (i, g) in gems.enumerated() where f > Double(i) * 0.1 {
                    let a = Double(i) / 6 * 2 * .pi + t * 2
                    c.rect(Int((hand.0 + cos(a) * 6).rounded()), Int((hand.1 + sin(a) * 6).rounded()), 2, 2, g)
                }
            } else if f < 0.78 {
                let r = (f - 0.7) / 0.08 * 10
                for i in 0..<16 {
                    let a = Double(i) / 16 * 2 * .pi
                    c.px(Int(hand.0 + cos(a) * r), Int(hand.1 + sin(a) * r), white)
                    c.px(Int(hand.0 + cos(a) * r * 0.6), Int(hand.1 + sin(a) * r * 0.6), C(0xF4E0FF, 0.7))
                }
            } else {
                let k = (f - 0.78) / 0.22
                for i in 0..<8 {
                    let x = hand.0 + 2 + k * 14 + noise(i * 3) * 4, y = hand.1 - 2 - k * 6 + noise(i * 5) * 6
                    c.px(Int(x), Int(y), C(0x8A7A6A).alpha(1 - k))
                }
            }
        },
        // Lokee: an illusion of himself beside him, flickering in and out.
        .villain(MarvelVillain.loki): { c, who, d, t in
            let period = 2.6, f = frac(d.e / period)
            if f > 0.15, f < 0.85, setRamp(d) > 0.9, noise(Int(t * 14)) > 0.12 {
                let ghost = PixelCanvas(c.w, c.h)
                standing(ghost, who, t: t + 0.9)
                c.paste(ghost, x: 17, alpha: 0.4)
                for i in 0..<3 {
                    let y = 20 + Int(noise(Int(t * 10) + i) * 24)
                    c.px(17 + 20 + Int(noise(Int(t * 10) + i * 4) * 20), y, C(0x3AD06A, 0.7))
                }
            }
            standing(c, who, t: t)
        },
        // The Bulk: leaps a little and smashes the ground, dust and cracks flying.
        .hero(MarvelHero.hulk): { c, who, d, t in
            let period = 2.2, f = frac(d.e / period)
            standing(c, who, t: t) { p in if f > 0.45, f < 0.6 { p.melee = 40 } }
            guard setRamp(d) > 0.9 else { return }
            if f > 0.2, f < 0.45 { c.shift(dx: 0, dy: -Int((sin((f - 0.2) / 0.25 * .pi) * 5).rounded())) }
            if f > 0.45, f < 0.55 { c.shift(dx: noise(Int(t * 30)) > 0.5 ? 1 : -1, dy: 0) }
            if f > 0.45 {
                let k = (f - 0.45) / 0.55
                for i in 0..<6 {
                    let side = i % 2 == 0 ? 1.0 : -1.0
                    let x = Sprite.bodyCenterX + side * (12 + k * 14 + Double(i) * 1.5), y = 43 - k * 5 - Double(i % 3)
                    c.rect(Int(x), Int(y), 3, 2, C(0xA89880).alpha(0.8 * (1 - k)))
                }
                let crack = C(0x2A2420).alpha(1 - k)
                c.px(44, 44, crack); c.px(45, 45, crack); c.px(47, 45, crack); c.px(48, 44, crack); c.px(12, 45, crack); c.px(14, 44, crack)
            }
        },
        // Iron Clawd: testing the boot thrusters, wobbling a few pixels off the ground.
        .hero(MarvelHero.ironMan): { c, who, d, t in
            standing(c, who, t: t)
            let r = setRamp(d)
            let lift = Int((r * (4 + 2 * sin(d.e * 2.3))).rounded())
            let wobble = r > 0.8 && sin(d.e * 5.3) > 0.85 ? (sin(d.e * 11) > 0 ? 1 : -1) : 0
            c.shift(dx: wobble, dy: -lift)
            guard r > 0.15 else { return }
            for x in [20, 33] {
                let len = 2 + Int(noise(Int(t * 30) + x) * 3) + lift / 2
                let top = 44 - lift
                c.rect(x + wobble, top, 3, len, C(0x6FD8FF, 0.7))
                c.rect(x + 1 + wobble, top, 1, max(1, len - 1), C(0xF4FCFF))
            }
        },
]
