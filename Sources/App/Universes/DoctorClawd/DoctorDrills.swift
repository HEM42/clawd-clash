import Foundation

// Doctor Clawd's own drills (`UniverseModule.drills`): a few characters practise something only they would.

let doctorBespokeDrills: [Cast: BespokeDrill] = [
        // Dalicks: "Elevate!" Up off the ground a step's height, held, and back down, the thrusters glowing under it.
        .villain(DoctorVillain.dalick): drawElevate,
        .villain(DoctorVillain.supremeDalick): drawElevate,
        // Cyberpersons: marching on the spot, stamping in step on the shared clock.
        .villain(DoctorVillain.cyberperson): drawMarch,
        .villain(DoctorVillain.mondasianCyberperson): drawMarch,
        // Sontaron: drill, marching on the spot, a hop on every fourth beat ("Sontar-ha!").
        .villain(DoctorVillain.sontaron): { c, who, d, t in
            drawPersona(c, who, t: t, mode: .idle, walking: true, role: .none)
            let beat = d.e / 0.5
            if Int(beat) % 4 == 3 { c.shift(dx: 0, dy: -Int((3 * sin(frac(beat) * .pi)).rounded())) }
        },
        // Doctor Four: tossing a jelly baby up and catching it, a different colour each time.
        .hero(DoctorHero.doctorFour): { c, who, d, t in
            standing(c, who, t: t)
            let period = 1.1, n = Int(floor(d.e / period)), k = frac(d.e / period)
            guard setRamp(d) > 0.5 else { return }
            let hand = who.persona.pivot
            let x = Int((hand.x + 1 + 2 * sin(k * .pi)).rounded()), y = Int((hand.y - 1 - 14 * sin(k * .pi)).rounded())
            let col = [C(0xE83A3A), C(0x3AC85A), C(0xF0C83A), C(0xE87AC8), C(0xF08A3A)][n % 5]
            c.rect(x, y, 2, 3, col); c.px(x, y, col.alpha(0.6))
        },
        // Doctor Twelve: the guitar riff, over and over, the notes drifting up off it.
        .hero(DoctorHero.doctorTwelve): { c, who, d, t in
            let length = who.signatureLength ?? 2.6
            idleHabit = HabitPlay(kind: .signature, e: min(length * 0.5, d.e.truncatingRemainder(dividingBy: length)), length: length)
            standing(c, who, t: t)
            idleHabit = nil
            for i in 0..<3 {
                let f = frac(d.e / 1.8 + Double(i) / 3)
                let x = Int((42 + f * 10 + sin(f * 9) * 2).rounded()), y = Int((32 - f * 20).rounded())
                let col = C(0xF4F4F8).alpha(1 - f)
                c.rect(x, y, 1, 3, col); c.px(x - 1, y + 2, col); c.px(x + 1, y, col)
            }
        },
        // K-Canine: fetch. A ball bowls out ahead, he glides after it, and brings it back.
        .hero(DoctorHero.kCanine): { c, who, d, t in
            let period = 3.2, k = frac(d.e / period), r = setRamp(d)
            let out = k < 0.35 ? k / 0.35 : (k < 0.5 ? 1 : max(0, 1 - (k - 0.5) / 0.4))
            let chase = k < 0.2 ? 0 : (k < 0.5 ? (k - 0.2) / 0.3 : out)
            let dx = Int((10 * chase * r).rounded())
            drawPersona(c, who, t: t, mode: .idle, walking: chase > 0 && chase < 1 && k < 0.5 || (k > 0.5 && out > 0), role: .none)
            c.shift(dx: dx, dy: 0)
            let bx = k < 0.5 ? 44 + Int((20 * out * r).rounded()) : 44 + dx
            c.rect(bx, 41, 2, 2, C(0xE83A3A)); c.px(bx, 41, C(0xFF8A8A))
        },
]

/// A Dalick's "Elevate!": up 8 px over 1.2 s, held with a little bob, and down again; a glow under its skirt.
private func drawElevate(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    let r = setRamp(d, rise: 1.2)
    let lift = Int((8 * r + (r > 0.95 ? sin(d.e * 2.4) : 0)).rounded())
    c.baseY = -lift
    standing(c, who, t: t)
    c.baseY = 0
    guard lift > 1 else { return }
    let glow = C(0xFFB84A, 0.35 + 0.2 * noise(Int(t * 20)))
    c.rect(18, 44 - lift, 21, 1, glow)
    c.rect(22, 45 - lift, 13, 1, glow.alpha(0.5))
}

/// Cyber marching: walking on the spot, everyone on the same beat.
private func drawMarch(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    drawPersona(c, who, t: t, mode: .idle, walking: true, role: .none)
}
