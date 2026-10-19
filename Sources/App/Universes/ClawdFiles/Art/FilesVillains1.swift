import Foundation

// Villains: the Syndicate. Clawd in costume here too: a dark suit, a white shirt, and the cigarette that's never out.

let filesVillains1: [FilesVillain: Persona] = [
    .smokingClawd: Persona(name: "The Cigarette-Smoking Clawd", weapon: .blaster, shot: .bullet, muzzle: (47, 32),
                           headTop: 22, signature: 4.0, callout: "I've watched presidents die.",
                           draw: drawSmokingClawd),
]

// MARK: - The Cigarette-Smoking Clawd

/// The Cigarette-Smoking Clawd: Clawd with grey hair combed straight back, a charcoal suit, a white shirt and a dark
/// tie; a cigarette at the corner of his mouth, its ember glowing and a thread of smoke always rising off it. He fires
/// a small pistol. Signature: he lights a fresh one with his lighter, draws on it till the ember flares, and lets a
/// smoke ring drift up and away.
private func drawSmokingClawd(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x34363C), suitD = C(0x24262B), shirt = C(0xEDEDE8), tie = C(0x1E2028)
    let suitL = C(0x4A4C54), hair = C(0x9A9CA4), hairD = C(0x6E7078), hairL = C(0xC4C6CC)
    let sig = p.signature
    let lighting = sig.map { $0 > 0.05 && $0 < 0.3 } ?? false
    let drawing = sig.map { $0 >= 0.3 && $0 < 0.5 } ?? false

    drawLegs(c, Look(leg: suit), step: p.step)
    drawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    // The suit, the white shirt and the narrow dark tie.
    c.rect(18, 34, 20, 4, suit); c.rect(37, 34, 1, 4, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(25, 34, ["lSTTSl", ".lTTl.", "..TT..", "..TT.."], ["l": suitD, "S": shirt, "T": tie])
    c.rect(18, 34, 4, 1, suitL); c.rect(32, 34, 4, 1, suitL)          // lit shoulders
    c.rect(20, 35, 1, 2, suitD); c.rect(35, 35, 1, 2, suitD)          // folds
    c.rect(32, 36, 3, 1, suitD)                                       // a pocket flap
    // The hair, combed straight back off a high forehead, down to the top of the body (a gap would show the outline):
    // the comb lines in short runs, lit on top, the far side shaded.
    c.pattern(17, 22, [
        ".....HHHHllllHHHH.....",
        "...HHllllHHHHHHhhHH...",
        "..HHHHHHHhhhHHHHHHhH..",
        ".HHHhhHHHHHHHHhhHHHhH.",
        ".HH................hH.",
        ".H..................h.",
    ], ["H": hair, "h": hairD, "l": hairL])

    // The cigarette at the corner of his mouth, out past his cheek, and its ember.
    let flare = drawing ? 1.0 : 0.5 + 0.5 * sin(p.t * 1.7)
    c.px(33, 32, ink)
    c.rect(34, 32, 6, 1, C(0xF2F0EA)); c.px(34, 32, C(0xD8B47A))
    c.px(40, 32, C(0xFF5A1A).alpha(0.7 + 0.3 * flare))
    if drawing { c.px(41, 32, C(0xFFB04A, 0.7)); c.px(40, 31, C(0xFFB04A, 0.5)) }
    // The thread of smoke off the ember, wavering as it rises.
    for i in 1...9 {
        let y = 32 - i * 2
        let x = 40 + Int((sin(p.lt * 1.3 + Double(i) * 0.7) * Double(i) / 3).rounded())
        let a = 0.8 - Double(i) * 0.07
        c.px(x, y, C(0xD8DAE0, a)); c.px(x, y - 1, C(0xD8DAE0, a * 0.6))
    }

    if lighting {
        // The lighter up under the cigarette's end, its flame flickering.
        c.rect(38, 34, 3, 3, suit); c.rect(40, 33, 2, 2, C(0xB8BCC4))
        let tall = Int(p.t * 14) % 3
        c.rect(41, 30 - tall % 2, 1, 3 + tall % 2, C(0xFFD24A)); c.px(41, 32, C(0xFF8A2A))
        c.rect(15, 33, 3, 3, suit); c.rect(15, 35, 3, 1, shirt)
        return
    }
    if let s = sig, s >= 0.55, s < 0.97 {
        // The smoke ring: a little O, drifting up and to the front, growing and fading as it goes.
        let k = (s - 0.55) / 0.42
        let cx = 42 + Int(k * 10), cy = 29 - Int(k * 18), r = 1 + Int(k * 3)
        let ring = C(0xE4E6EC, 0.9 * (1 - k))
        for a in stride(from: 0.0, to: 2 * .pi, by: .pi / 6) {
            c.px(cx + Int((cos(a) * Double(r + 1)).rounded()), cy + Int((sin(a) * Double(r)).rounded()), ring)
        }
    }
    c.rect(15, 33, 3, 3, suit); c.rect(15, 35, 3, 1, shirt)   // the sleeve and its shirt cuff
    c.oy += p.gunY
    drawSidearm(c, sleeve: suit, searching: false)
}
