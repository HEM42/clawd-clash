import Foundation

// Heroes: the folk of Bree. Barliman Butterbug is Clawd in costume, a Man at Clawd's full height but round: his belly
// drawn out in front of the blocky body (so `bulk` says so), the apron, the sleeves and the bald head over and around
// it. The face is Clawd's own orange, and the eyes stay ink.

let ringsHeroes5: [LOTRHero: Persona] = [
    .butterbur: Persona(name: "Barliman Butterbug", weapon: .none, bulk: 3, headTop: 22,
                        callout: "I'll remember it in the morning… let me file it in the backlog.", draw: drawButterbur),
]

// MARK: - Barliman Butterbug

/// Barliman Butterbug, the landlord of the Prancing Ponytail, round and stout: a big belly bulging out in front under a
/// long white apron tied over a brown waistcoat and cream shirt, the sleeves rolled up to the elbow, dark breeches and
/// boots; a bald, shiny dome of a head with bushy grey-brown tufts over the ears, ruddy cheeks, and a checked bar rag
/// over his back arm. In his front hand a foaming tankard, held up proudly. He keeps out of fights. No signature.
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
    c.pattern(15, 27, [".TTT", "TlTT", "TTTd", "dTT.", ".d.."], ["T": tuft, "l": tuftLight, "d": tuftDark])
    c.pattern(37, 27, ["TTT.", "TTlT", "dTTT", ".TTd", "..d."], ["T": tuft, "l": tuftLight, "d": tuftDark])
    c.rect(21, 28, 4, 1, tuftDark); c.rect(31, 28, 4, 1, tuftDark)             // bushy brows
    c.rect(20, 32, 2, 1, C(0xE8907A)); c.rect(35, 32, 2, 1, C(0xE8907A))       // ruddy cheeks
    // The waistcoat over the shirt, buttoned tight over the belly bulging out in front.
    c.rect(18, 33, 20, 5, waistcoat)
    c.rect(18, 33, 3, 5, shirt); c.rect(18, 37, 3, 1, shirtShade)
    let belly: [(y: Int, r: Int)] = [(32, 38), (33, 40), (34, 41), (35, 41), (36, 41), (37, 40), (38, 39)]
    for row in belly { c.rect(36, row.y, row.r - 35, 1, waistcoat); c.px(row.r, row.y, waistcoatDark) }
    for (x, y) in [(38, 33), (40, 34)] { c.px(x, y, C(0xC8A040)) }
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
