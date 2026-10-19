import Foundation

// Heroes: the Lone Gunclawds (Bytes, Frohack, Lanky) and Deep Clawt. The Gunclawds don't carry guns, whatever the name
// says: Bytes and Lanky stay out of fights, and Frohack's weapon is his camera, its flash a steady white ray. Deep
// Clawt only ever brings information.

let filesHeroes3: [FilesHero: Persona] = [
    .bytes: Persona(name: "Bytes", weapon: .none, headTop: 20, signature: 3.4, callout: "The public has a right to know.",
                    draw: drawBytes),
    .frohack: Persona(name: "Frohack", weapon: .lightning, magic: Magic(core: C(0xFFFFFF), glow: C(0xCFE6FF), jagged: false),
                      pivot: cameraLens, headTop: 20, signature: 2.8, callout: "Say cheese, G-man.",
                      draw: drawFrohack),
    .lanky: Persona(name: "Lanky", weapon: .none, headTop: 20, signature: 3.2, callout: "I'm in.",
                    draw: drawLanky),
    .deepClawt: Persona(name: "Deep Clawt", weapon: .none, headTop: 21, signature: 3.6, callout: "Trust no one.",
                        draw: drawDeepClawt),
]

/// Where Frohack's camera lens is, held up: the flash leaves from there (raised by the pose's `armRaise`).
private let cameraLens = (x: 46.0, y: 30.0)

// MARK: - Bytes

/// Bytes: Clawd with neatly combed dark hair and a full dark beard trimmed close, the most respectable of the three:
/// a grey suit, a white shirt and a tie done right up. Unarmed. Signature: he straightens his tie, then holds up a
/// pamphlet and reads it, nodding along.
private func drawBytes(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x5E626C), suitD = C(0x464A52), suitL = C(0x767A84), shirt = C(0xEDEDE8), tie = C(0x2E4A7A)
    let hair = C(0x3A2A1E), hairL = C(0x54402E), hairD = C(0x281C12), beard = C(0x3A2A1E)
    let sig = p.signature
    let tie_ = sig.map { $0 > 0.05 && $0 < 0.3 } ?? false
    let reading = sig.map { $0 >= 0.35 && $0 < 0.95 } ?? false

    drawLegs(c, Look(leg: suit), step: p.step)
    drawDressShoes(c, step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    // The suit, shirt and tie.
    c.rect(18, 34, 20, 4, suit); c.rect(37, 34, 1, 4, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(24, 34, ["lSTTSl", ".lTTl.", "..TT..", "..TT.."], ["l": suitD, "S": shirt, "T": tie])
    // Light along the shoulders, a fold, the far side in shade, a pocket square.
    c.rect(18, 34, 3, 1, suitL); c.rect(34, 34, 2, 1, suitL)
    c.rect(20, 35, 1, 2, suitD); c.rect(36, 35, 1, 2, suitD); c.rect(32, 35, 2, 1, shirt)
    // Combed hair with a neat side parting.
    c.pattern(17, 21, [
        "......HHHHhhHHHH......",
        "....HHHhhHHHHHHhHH....",
        "...HHHHhhHHHHHHHHHH...",
        "..HHHHHHHhhhHHHHHHHd..",
        ".HHhhHHHHHHHHHHhhHHdd.",
        ".HHHH............HHdd.",
        ".HHH..............Hdd.",
    ], ["H": hair, "h": hairL, "d": hairD])
    // The beard: along the jaw and round the mouth, under the eyes.
    c.pattern(18, 30, [
        "B..................d",
        "BB................dd",
        "BlB...BllBBBBB...dBd",
        "BBBllBBBBBBBBllBBdBd",
    ], ["B": beard, "l": hairL, "d": hairD])
    c.rect(26, 32, 4, 1, C(0x8E4A38))   // the mouth, in the beard

    if tie_ {
        // A hand up at the knot.
        c.rect(30, 33, 3, 3, suit); c.px(29, 34, clawdOrange)
        c.rect(15, 33, 3, 3, suit)
        return
    }
    if reading {
        // The pamphlet held up in both hands, a dark star on its cover; he nods along.
        let nod = Int(p.t * 3) % 2
        c.rect(15, 31, 3, 3, suit); c.rect(38, 31, 3, 3, suit)
        c.rect(39, 24 + nod, 7, 9, C(0xF2EEDC)); c.rect(39, 24 + nod, 1, 9, C(0xC8C2AA))
        c.rect(41, 26 + nod, 3, 1, C(0x5A5A54)); c.rect(41, 28 + nod, 4, 1, C(0x8A8676)); c.rect(41, 30 + nod, 4, 1, C(0x8A8676))
        return
    }
    c.rect(15, 33, 3, 3, suit); c.rect(38, 33, 3, 3, suit); drawCuffs(c, suitD)
}

// MARK: - Frohack

/// Frohack: Clawd with greying hair swept back to his collar and a shadow of stubble, a battered black leather jacket
/// over a dark T-shirt, and a camera always at hand. In a fight he holds it up and the flash fires off in a steady white
/// burst. Signature: he raises the camera, frames you, and snaps: the flash goes off in a starburst.
private func drawFrohack(_ c: PixelCanvas, _ p: Pose) {
    let leather = C(0x26221F), leatherL = C(0x3E3832), tee = C(0x3A3A40)
    let hair = C(0x8A8A86), hairD = C(0x5E5E5A), hairL = C(0xA8A8A4), stubble = C(0x6E4030)
    let sig = p.signature
    let framing = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false
    let snap = sig.map { $0 > 0.55 && $0 < 0.72 } ?? false

    drawLegs(c, Look(leg: C(0x2E3440)), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0x3A2A1E))
    c.oy += p.breathe
    let using = framing || p.zap != nil || p.ready || p.cheering || (!p.resting && !p.walking)
    let raise = using && !framing ? p.armRaise : 0
    drawBody(c, Look(arm: leather))
    // The jacket open over the T-shirt, its collar and zip.
    c.rect(18, 33, 20, 5, leather); c.rect(24, 33, 8, 5, tee)
    c.rect(22, 33, 2, 4, leatherL); c.rect(32, 33, 2, 4, leatherL)   // the collar
    c.rect(23, 34, 1, 4, C(0x8A8A90)); c.rect(18, 37, 20, 1, C(0x161412))
    drawJacketDetail(c, dark: C(0x161412), light: leatherL, pocket: false)
    c.rect(25, 36, 6, 1, C(0x2E2E34))   // the T-shirt's folds over his belly
    // Greying hair, swept back and long at the back.
    c.pattern(16, 21, [
        ".......HHHlllHHH........",
        ".....HHllHHHHHllHH......",
        "...HHlHHHHHHHHHHHHHh....",
        "..HHHHHHhhHHHHHHhhHhh...",
        "..HHHHHHHHHhhHHHHHHHhh..",
        ".HHHH..............Hhh..",
        "HHhh................hh..",
        "HhH.................Hh..",
        "Hh.......................",
    ], ["H": hair, "h": hairD, "l": hairL])
    // Stubble along the jaw and round the mouth: two rows, dotted, dark enough to show on the orange.
    for x in 19..<37 where (x + 31) % 2 == 0 { c.px(x, 31, stubble.alpha(0.75)) }
    for x in 19..<37 where (x + 32) % 2 == 0 { c.px(x, 32, stubble) }

    c.rect(15, 33, 3, 3, leather); drawCuffs(c, C(0x161412), right: false)
    guard using else {
        drawCuffs(c, C(0x161412), left: false)
        // The camera hanging on its strap at his chest.
        c.rect(30, 30, 1, 3, C(0x161412))
        c.rect(27, 32, 6, 4, C(0x1E1E22)); c.rect(28, 33, 2, 2, C(0x6A8AB0)); c.rect(31, 32, 2, 1, C(0xB8BCC4))
        return
    }
    // The camera held up to his eye, both hands on it, its lens at `cameraLens`.
    let y = 28 - raise
    c.rect(36, y + 2, 3, 3, leather)
    c.rect(38, y, 7, 5, C(0x1E1E22)); c.rect(38, y, 7, 1, C(0x3A3A42)); c.rect(40, y - 1, 2, 1, C(0xB8BCC4))
    c.rect(45, y + 1, 1, 3, C(0x3A3A42)); c.px(46, y + 2, C(0x8AB0E0))
    let fired = snap || p.zap == true
    c.rect(43, y - 1, 2, 1, fired ? C(0xFFFFFF) : C(0xC8CCD4))   // the flash
    if snap {
        // The starburst off the flash.
        let k = Int(p.t * 20) % 2
        for (dx, dy) in [(0, -3), (0, -4 - k), (3, -2), (4 + k, -3), (-2, -2), (-3 - k, -3), (2, -5), (-1, -5)] {
            c.px(44 + dx, y - 1 + dy, C(0xFFFFFF, 0.9))
        }
    }
}

// MARK: - Lanky

/// Lanky: Clawd with long straight blond hair hanging down past his shoulders, black-framed glasses, a black band
/// T-shirt with a white logo, jeans and trainers. Unarmed: a laptop is his weapon of choice. Signature: he flips the
/// laptop open and types furiously, green code scrolling up off the screen.
private func drawLanky(_ c: PixelCanvas, _ p: Pose) {
    let tee = C(0x1C1C20), logo = C(0xEDEDE8), jeans = C(0x3E5A8A)
    let hair = C(0xE8CC6A), hairD = C(0xC4A848), hairL = C(0xF6E2A0), frame = C(0x16161B)
    let sig = p.signature
    let typing = sig.map { $0 > 0.08 && $0 < 0.95 } ?? false

    drawLegs(c, Look(leg: jeans), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0xEDEDE8))
    c.oy += p.breathe
    drawBody(c, Look(arm: tee))
    // The band T-shirt and its logo: a grey alien's head, big black eyes, in white.
    c.rect(18, 33, 20, 5, tee); c.rect(18, 37, 20, 1, C(0x0E0E10))
    c.pattern(24, 33, [".WWWWW.", "WKKWKKW", "WWKWKWW", ".WWWWW.", "..WWW.."], ["W": logo, "K": C(0x060608)])
    // Light catching the shoulders, a crease, the far side in shade.
    c.rect(18, 33, 3, 1, C(0x34343C)); c.rect(34, 33, 2, 1, C(0x34343C))
    c.rect(20, 35, 1, 2, C(0x0E0E10)); c.rect(36, 34, 1, 3, C(0x0E0E10))
    // Long blond hair, a centre parting, falling straight down both sides past the shoulders.
    c.pattern(16, 21, [
        ".......HHHlllHHHH.......",
        ".....HHlllHHdHHlllH.....",
        "...HHlHHHHHHdHHHHHlHH...",
        "..HHlHHHHHHHdHHHHHHHdH..",
        ".HHlHHHHHHHHdHHHHHHHdHH.",
        ".HlHHH............HHdHH.",
        "HlHHd..............dHdHH",
        "HlHH................HdHH",
        "HlHd................dHdH",
        "HHH..................HdH",
        "HlHd................dHdH",
        "HlH..................HdH",
        "HHHd................dHdH",
        "HlH..................HdH",
        "HH....................dH",
        "HH....................HH",
    ], ["H": hair, "d": hairD, "l": hairL])
    // The glasses.
    c.pattern(20, 28, ["FFFFFF....FFFFFF", "F....FFFFFF....F", "F....F....F....F", "FFFFFF....FFFFFF"], ["F": frame])

    guard typing else {
        c.rect(15, 33, 3, 3, tee); c.rect(38, 33, 3, 3, tee)
        return
    }
    // The laptop held out in front, screen up, green code scrolling off it; his fingers going.
    c.rect(38, 34, 9, 2, C(0x3A3A42)); c.rect(38, 34, 9, 1, C(0x6A6A74))
    c.rect(44, 27, 2, 7, C(0x3A3A42)); c.rect(45, 28, 1, 5, C(0x2A6A3A))
    let tick = Int(p.t * 8)
    for i in 0..<4 {
        let y = 25 - ((tick + i * 3) % 10)
        c.rect(47 + (i % 2), y, 1 + (i + tick) % 3, 1, C(0x6AFF8A, 0.75 - Double((tick + i * 3) % 10) * 0.06))
    }
    c.rect(38, 33 - tick % 2, 3, 2, tee); c.rect(15, 33, 3, 3, tee)
}

// MARK: - Deep Clawt

/// Deep Clawt: Clawd with thinning silver hair, a long dark raincoat over a grey suit and a sober tie: a man who has
/// been inside too long. He carries nothing but what he knows. Signature: the shadows close round him and he holds out
/// a plain envelope, the only bright thing about him, then tucks it away again.
private func drawDeepClawt(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x3A3A36), coatD = C(0x262622), coatL = C(0x55554E)
    let suit = C(0x6A6E76), shirt = C(0xE6E4DC), tie = C(0x4A3A2E)
    let hair = C(0xC8CACE), hairD = C(0x9A9CA4)
    let sig = p.signature
    let shadow = sig.map { s -> Double in s < 0.15 ? s / 0.15 : s > 0.85 ? (1 - s) / 0.15 : 1 } ?? 0
    let offering = sig.map { $0 > 0.2 && $0 < 0.8 } ?? false

    drawLegs(c, Look(leg: suit), step: p.step)
    drawDressShoes(c, step: p.step)
    c.oy += p.breathe
    // The coat's tails, over the tops of the legs.
    if !seatedPose {
        c.rect(17, 38, 22, 3, coat); c.rect(17, 40, 22, 1, coatD); c.rect(28, 38, 1, 3, coatD)
        c.rect(22, 38, 1, 2, coatD); c.rect(34, 38, 1, 2, coatD)   // folds in the tails
    }
    drawBody(c, Look(arm: coat))
    // The suit and tie under the open coat.
    c.rect(18, 33, 20, 5, coat); c.rect(23, 33, 10, 5, suit)
    c.pattern(25, 33, ["SSTTSS", ".STTS.", "..TT..", "..TT..", "..TT.."], ["S": shirt, "T": tie])
    c.rect(22, 33, 1, 4, coatL); c.rect(33, 33, 1, 4, coatL); c.rect(18, 37, 20, 1, coatD); c.rect(37, 33, 1, 5, coatD)
    drawJacketDetail(c, dark: coatD, light: coatL, pocket: false)
    c.rect(18, 36, 4, 1, coatD); c.rect(34, 36, 3, 1, coatD)   // the coat's belt, loose at the sides
    // Thinning silver hair, a high forehead, grey at the sides.
    c.pattern(17, 21, [
        ".......hHHllHHh.......",
        "....HHllHHHHHHllHh....",
        "..hHHHHSSSSSSSSHHHhh..",
        ".HllHSSSSSSSSSSSSHHhh.",
        ".HHHSSSSSSSSSSSSSSHhh.",
        ".HH................hh.",
    ], ["H": hair, "h": hairD, "S": clawdOrange, "l": C(0xE4E6EA)])
    c.rect(21, 28, 3, 1, hairD); c.rect(31, 28, 3, 1, hairD)   // heavy brows

    if shadow > 0 {
        // The shadows close in on him: a dark wash over his face and coat (only where he's drawn, so no box round him),
        // his eyes catching what light there is.
        c.rect(18, 26, 20, 12, C(0x0A0A0E, 0.5 * shadow)); c.rect(15, 33, 3, 3, C(0x0A0A0E, 0.5 * shadow))
        c.rect(21, 23, 14, 3, C(0x0A0A0E, 0.5 * shadow))   // the forehead too
        c.px(23, 29, C(0xFFFFFF, 0.6 * shadow)); c.px(33, 29, C(0xFFFFFF, 0.6 * shadow))
    }
    if offering {
        // The envelope held out at arm's length, bright against the dark.
        c.rect(38, 31, 3, 3, coat)
        c.rect(41, 29, 7, 5, C(0xF2EEDC)); c.rect(41, 33, 7, 1, C(0xC8C2AA))
        c.pattern(41, 29, ["E.....E", ".E...E.", "..EEE.."], ["E": C(0xB8B2A0)])
        c.rect(15, 33, 3, 3, coat); drawCuffs(c, coatD, right: false)
        return
    }
    c.rect(15, 33, 3, 3, coat); c.rect(38, 33, 3, 3, coat); drawCuffs(c, coatD)
}
