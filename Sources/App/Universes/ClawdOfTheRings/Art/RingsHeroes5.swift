import Foundation

// Heroes: the folk of Bree. Barliman Butterbug is Clawd in costume, a Man at Clawd's full height but round: his belly
// drawn out in front of the blocky body (so `bulk` says so), the apron, the sleeves and the bald head over and around
// it. The face is Clawd's own orange, and the eyes stay ink.

let ringsHeroes5: [RingsHero: Persona] = [
    .butterbur: Persona(name: "Barliman Butterbug", weapon: .none, bulk: 3, headTop: 22, signature: 3.2,
                        callout: "I'll remember it in the morning… let me file it in the backlog.", draw: drawButterbur),
]

// MARK: - Barliman Butterbug

/// Barliman Butterbug, the landlord of the Prancing Ponytail, round and stout: a big belly bulging out in front under a
/// long white apron tied over a brown waistcoat and cream shirt, the sleeves rolled up to the elbow, dark breeches and
/// boots; a bald, shiny dome of a head with bushy grey-brown tufts over the ears, ruddy cheeks, and a checked bar rag
/// over his back arm. In his front hand a foaming tankard, held up proudly. He keeps out of fights. Signature: the
/// letter he forgot to send: one brow up, he scratches his head under a "?"; then it comes to him, a "!" pops up in
/// its place and he slaps his hand to his forehead, eyes squeezed shut, before letting it drop again.
private func drawButterbur(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0xE8E0CC), shirtShade = C(0xC0B8A4), waistcoat = C(0x6A4A2A), waistcoatDark = C(0x4E361E)
    let apron = C(0xF4F2EA), apronShade = C(0xC8C4B8)
    let tuft = C(0x8A7A6A), tuftLight = C(0xAA9A88), tuftDark = C(0x625646)
    drawLegs(c, Look(leg: C(0x4A3A2A)), step: p.step)
    drawBoots(c, p.step, C(0x2A1E16), rows: 2)
    c.oy += p.breathe
    // The back arm, the rolled sleeve over it, and his rag hanging over it.
    drawBody(c, Look())
    c.rect(15, 33, 3, 1, shirt)
    c.pattern(13, 34, ["RrRr", "rRrR", "RrRr", "rRrR", "RrR.", ".rR."], ["R": C(0xC83A3A), "r": C(0xF0E8DC)])
    // The bald dome over the head, shining, and the bushy tufts sticking out over the ears.
    c.rect(21, 25, 14, 1, clawdOrange); c.rect(23, 24, 10, 1, clawdOrange); c.rect(25, 23, 6, 1, clawdOrange)
    c.px(25, 24, C(0xF4A888)); c.px(26, 24, C(0xF4A888)); c.px(24, 25, C(0xF0A080))
    c.pattern(15, 27, [".lTT", "TllT", "TTdd", "ddT.", ".d.."], ["T": tuft, "l": tuftLight, "d": tuftDark])
    c.pattern(37, 27, ["TTl.", "TllT", "ddTT", ".Tdd", "..d."], ["T": tuft, "l": tuftLight, "d": tuftDark])
    c.rect(21, 28, 4, 1, tuftDark); c.rect(31, 28, 4, 1, tuftDark)             // bushy brows
    c.rect(20, 32, 2, 1, C(0xE8907A)); c.rect(35, 32, 2, 1, C(0xE8907A))       // ruddy cheeks
    // The waistcoat over the shirt, buttoned tight over the belly bulging out in front.
    c.rect(18, 33, 20, 5, waistcoat)
    c.rect(18, 33, 3, 5, shirt); c.rect(18, 37, 3, 1, shirtShade)
    let belly: [(y: Int, r: Int)] = [(32, 38), (33, 40), (34, 41), (35, 41), (36, 41), (37, 40), (38, 39)]
    for row in belly { c.rect(36, row.y, row.r - 35, 1, waistcoat); c.px(row.r, row.y, waistcoatDark) }
    for (x, y) in [(38, 33), (40, 34)] { c.px(x, y, C(0xC8A040)) }
    c.rect(21, 33, 14, 1, C(0x86603A)); c.px(22, 35, waistcoatDark); c.px(22, 36, waistcoatDark)   // lit shoulders, a fold
    // The long apron, tied at the waist, round over the belly and down below the knee.
    c.rect(24, 35, 18, 1, apron)
    c.rect(24, 36, 18, 1, apron); c.rect(24, 37, 17, 1, apron); c.rect(24, 38, 16, 1, apron)
    for y in 39...41 where y + c.oy <= 43 { c.rect(24, y, 16, 1, apron) }
    c.rect(24, 41, 16, 1, apronShade); c.rect(24, 35, 1, 7, apronShade)
    c.px(41, 36, apronShade); c.px(40, 37, apronShade); c.px(39, 38, apronShade)
    c.px(30, 38, apronShade); c.px(30, 39, apronShade); c.px(35, 39, apronShade); c.px(35, 40, apronShade)   // the folds
    c.rect(18, 35, 6, 1, apronShade)                                          // the strings, round the back
    // The front arm, sleeve rolled up, holding the tankard up in front of him.
    c.rect(38, 32, 3, 1, shirt); c.rect(38, 33, 3, 1, shirtShade)
    drawTankard(c, x: 39, y: 27)
    c.rect(38, 30, 3, 2, clawdOrange); c.px(40, 31, clawdShade)             // the fist round the handle
    if let s = p.signature, s > 0.04 && s < 0.92 { drawRemembering(c, s: s, t: p.t) }
}

/// Butterbug's signature at `s` (0.04…0.92): puzzling (…0.4), one brow up and his back hand scratching his head under
/// a "?"; then the "!" pops up, and his hand comes over to slap his forehead (0.5), his eyes squeezed shut, until it
/// drops back down (0.8…).
private func drawRemembering(_ c: PixelCanvas, s: Double, t: Double) {
    let bang = C(0xFFE14A), shade = clawdShade, palm = C(0xF2A482)
    let puzzled = s < 0.4
    // The hand: scratching above the tuft, over to the forehead, held there, then back down behind him.
    let scratch = (x: 17.0 + (Int(t * 12) % 2 == 0 ? 0 : 1), y: 24.0), brow = (x: 24.0, y: 26.0)
    var hand: (x: Double, y: Double)?
    if s < 0.1 {
        let u = smooth((s - 0.04) / 0.06)
        hand = (16 + (scratch.x - 16) * u, 33 + (scratch.y - 33) * u)
    } else if puzzled {
        hand = scratch
    } else if s < 0.5 {
        let u = smooth((s - 0.4) / 0.1)
        hand = (scratch.x + (brow.x - scratch.x) * u, scratch.y + (brow.y - scratch.y) * u)
    } else if s < 0.8 {
        hand = brow
    } else if s < 0.88 {
        let u = smooth((s - 0.8) / 0.08)
        hand = (brow.x + (16 - brow.x) * u, brow.y + (33 - brow.y) * u)
    }
    if puzzled {
        c.rect(31, 28, 4, 1, clawdOrange); c.rect(31, 27, 4, 1, C(0x625646))   // one brow up
        c.pattern(27, 13 + (Int(t * 3) % 2), [".QQ.", "Q..Q", "..Q.", "..Q.", "....", "..Q."], ["Q": C(0xE8F0FF)])
    } else {
        if s > 0.48 && s < 0.82 {                                             // eyes squeezed shut
            c.rect(22, 29, 2, 3, clawdOrange); c.rect(32, 29, 2, 3, clawdOrange)
            c.rect(21, 30, 3, 1, ink); c.rect(32, 30, 3, 1, ink)
        }
        let pop = s < 0.44 ? 1 : 0
        c.rect(28, 14 - pop, 2, 4, bang); c.rect(28, 19 - pop, 2, 1, bang)
    }
    guard let h = hand else { return }
    // The bare forearm (the sleeve's rolled up) from the back shoulder, and the hand, outlined against his face.
    c.glowLine(16.5, 33.5, h.x + 1, h.y + 1.5, core: shade, glow: C(0, 0), coreR: 1.3, glowR: 1.4)
    c.glowLine(16.5, 33.5, h.x + 1, h.y + 1.5, core: palm, glow: C(0, 0), coreR: 0.6, glowR: 0.7)
    let hx = Int(h.x.rounded()), hy = Int(h.y.rounded())
    c.pattern(hx - 1, hy - 1, [".SSS.", "SOOOS", "SOOOS", ".SSS."], ["S": shade, "O": palm])
    if s > 0.5 && s < 0.58 {                                                  // smack!
        let a: Double = 1 - (s - 0.5) / 0.08
        for (x, y) in [(hx - 3, hy - 2), (hx - 4, hy - 3), (hx + 2, hy - 3), (hx + 3, hy - 4), (hx + 5, hy), (hx + 6, hy)] {
            c.px(x, y, C(0xFFFFFF, a))
        }
    }
}

/// A pewter tankard, `x`, `y` its top left: a head of white foam spilling over the rim, a pewter body with a band round
/// it, and a big handle on the side nearest the fist.
private func drawTankard(_ c: PixelCanvas, x: Int, y: Int) {
    let pewter = C(0x9AA0A8), dark = C(0x6A7078), light = C(0xC8CED6), foam = C(0xFAF6EC)
    c.pattern(x, y, [
        "...FFFF.",
        "..FFFFfF",
        "hhhPLPPd",
        "h..PLPPd",
        "h..ddddd",
        "hhhPLPPd",
        "...PLPPd",
        "...dddd.",
    ], ["F": foam, "f": C(0xE8E0CC), "P": pewter, "L": light, "d": dark, "h": dark])
    c.px(x + 7, y + 2, foam)                                                  // a drip down the side
}

// MARK: - Shared helpers

/// Smoothstep: 0→1 eased at both ends.
private func smooth(_ x: Double) -> Double {
    let u = min(1, max(0, x))
    return u * u * (3 - 2 * u)
}

/// Boots over the bottom `rows` of each leg (a bit of the folded foot when sitting).
private func drawBoots(_ c: PixelCanvas, _ step: Int, _ col: Px, rows: Int = 2) {
    if seatedPose {
        for lx in [19, 23, 31, 35] { c.rect(lx + 1, 38, 2, 2, col) }
        return
    }
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        let bottom = step >= 0 && i % 2 == step ? 42 : 43
        c.rect(lx, bottom - rows + 1, 2, rows, col)
    }
}
