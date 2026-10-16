import Foundation

// Heroes: E.T., Jaws and Close Encounters. Clawd in costume like the rest of the cast: hoods, caps, hair and clothes
// drawn over the blocky body with Clawd's own orange face showing. E.Clawd and the Tall Visitor are Clawd in the
// alien's skin, still the same block on four legs.

let clawdbergHeroes6: [ClawdbergHero: Persona] = [
    .eClawd: Persona(name: "E.Clawd", weapon: .lightning,
                     magic: Magic(core: C(0xFFF4E4), glow: C(0xFF3A2A), jagged: false, touch: true),
                     pivot: (45.5, 33.5), headTop: 23, signature: 3.6, callout: "Phone… home", draw: drawEClawd),
    .elliclawd: Persona(name: "Elliclawd", headTop: 21, signature: 3.4, draw: drawElliclawd),
    .gurtie: Persona(name: "Gurtie", headTop: 21, signature: 3.2, callout: "Aaaah!", draw: drawGurtie),
    .chiefBroody: Persona(name: "Chief Broody", weapon: .blaster, shot: .bullet, muzzle: (53, 32), headTop: 21,
                          signature: 4.4, callout: "Smile!", draw: drawChiefBroody),
    .hoopah: Persona(name: "Hoopah", weapon: .saber, headTop: 21, signature: 3.0, draw: drawHoopah),
    .squint: Persona(name: "Squint", weapon: .blaster, shot: .arrow, muzzle: (56, 31), headTop: 21, signature: 3.2,
                     draw: drawSquint),
    .royNeery: Persona(name: "Roy Neery", weapon: .blaster, shot: .thrown(C(0x5A3E26)), muzzle: (45, 31),
                       headTop: 21, signature: 4.0, callout: "This means something", draw: drawRoyNeery),
    .jillianGeyser: Persona(name: "Jillian Geyser", headTop: 20, signature: 3.0, draw: drawJillianGeyser),
    .littleBarry: Persona(name: "Little Barry", headTop: 22, signature: 3.4, draw: drawLittleBarry),
    .clawdLacombe: Persona(name: "Clawd Lacombe", headTop: 21, signature: 4.0, draw: drawClawdLacombe),
    .tallVisitor: Persona(name: "The Tall Visitor", weapon: .lightning,
                          magic: Magic(core: C(0xFFFFFF), glow: C(0xC8DCFF), jagged: false),
                          pivot: (48.5, 31.5), headTop: 3, signature: 4.0, draw: drawTallVisitor),
]

// MARK: - Shared bits

private let tyre = C(0x1E1E22)
private let cream = C(0xF6F2E6)

/// The five notes of the visitors' tune (re, mi, do, the low do, sol): where the signing hand is held for each, and
/// the colour of the light it calls up.
private let noteY = [29, 27, 31, 36, 32]
private let noteColours = [C(0xFF5A5A), C(0xFFA83A), C(0xFFE04A), C(0x5AA8FF), C(0xC07AFF)]

/// One of the five hand signs, the hand at (`x`, `noteY[note]`) with the arm up to it from the shoulder: the hand
/// slanting up (re), flat (mi), a fist (do, and the low do), held upright (sol). `long`: thin alien fingers.
private func handSign(_ c: PixelCanvas, note: Int, x: Int, sleeve: Px, hand: Px, long: Bool = false) {
    let y = noteY[note]
    let top = min(y, 33), bottom = max(y + 2, 35)
    c.rect(38, top, 3, bottom - top + 1, sleeve)
    let f = long ? 2 : 0
    switch note {
    case 0:   // re: the flat hand slanting up
        for i in 0..<(4 + f) { c.px(x + i, y + 1 - i / 2, hand); c.px(x + i, y + 2 - i / 2, hand) }
    case 1:   // mi: flat, palm down
        c.rect(x, y, 5 + f, 2, hand)
    case 4:   // sol: upright, the palm facing in
        c.rect(x, y - 2 - f, 2, 5 + f, hand)
    default:  // do: a fist
        c.rect(x, y, 3, 3, hand); c.px(x + 2, y + 2, hand.alpha(0.6))
    }
}

/// A musical note (a quaver) floating up from a signing hand.
private func quaver(_ c: PixelCanvas, _ x: Int, _ y: Int, _ col: Px) {
    c.pattern(x, y, [".QQ", ".Q.", ".Q.", "QQ.", "QQ."], ["Q": col])
}

/// A thin wheel of radius 4 with three spokes turned `spin` radians.
private func wheel(_ c: PixelCanvas, _ cx: Double, _ cy: Double, hub: Px, spin: Double) {
    for s in 0..<28 {
        let a = Double(s) / 28 * 2 * .pi
        let x = Int((cx + cos(a) * 4).rounded()), y = Int((cy + sin(a) * 4).rounded())
        c.px(x, y, tyre)
    }
    for k in 0..<3 {
        let a = spin + Double(k) * 2.094
        let ex = cx + cos(a) * 3, ey = cy + sin(a) * 3
        cbLine(c, cx, cy, ex, ey, hub.alpha(0.6), 0.45)
    }
    c.px(Int(cx), Int(cy), hub)
}

/// Spectacles over Clawd's eyes: square frames, or `round` wire rims, a bridge between them and the arms back.
private func specs(_ c: PixelCanvas, _ col: Px, round: Bool) {
    for x0 in [21, 31] {
        c.rect(x0 + (round ? 1 : 0), 28, round ? 2 : 4, 1, col); c.rect(x0 + (round ? 1 : 0), 32, round ? 2 : 4, 1, col)
        c.rect(x0, 29, 1, 3, col); c.rect(x0 + 3, 29, 1, 3, col)
    }
    c.rect(25, 29, 6, 1, col); c.rect(35, 29, 3, 1, col); c.rect(18, 29, 3, 1, col)
}

/// Draws `rows` at (x, y) but nothing below the ground (row 43): something rising out of the earth or the water.
private func risePattern(_ c: PixelCanvas, _ x: Int, _ y: Int, _ rows: [String], _ palette: [Character: Px]) {
    for (r, row) in rows.enumerated() where y + r <= 43 { c.pattern(x, y + r, [row], palette) }
}

// MARK: - E.Clawd

/// E.Clawd: Clawd in the wrinkly brown alien's skin. A squat, pot-bellied body creased all over, the wide flat head
/// on a long ringed neck, big dark eyes under heavy lids, long thin arms and splayed feet, and the heart showing faint
/// through his chest. He fights with nothing but his glowing fingertip, a warm white light rimmed in red, pointed at whoever he's up against (who glows too). Signature: his neck
/// stretches up and up while his heart lights his chest red and pulses.
private func drawEClawd(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x8A6A4C), skinD = C(0x654A32), skinL = C(0xA88A68), eye = C(0x161E2E)
    let sig = p.signature
    let stretch: Double = sig.map { s in s < 0.15 ? s / 0.15 : s > 0.85 ? (1 - s) / 0.15 : 1 } ?? 0
    let lift: Int = 2 + Int((stretch * 7).rounded())
    let casting = p.zap != nil || p.armRaise > 0

    drawLegs(c, Look(leg: skin), step: p.step)
    if !seatedPose {   // splayed toes
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx - 1, lifted ? 42 : 43, 3, 1, skinD)
        }
    }
    c.oy += p.breathe
    // The squat body, wider at the belly, creased.
    c.rect(18, 32, 20, 6, skin); c.rect(17, 34, 22, 3, skin)
    c.rect(18, 37, 20, 1, skinD); c.rect(37, 32, 1, 5, skinD); c.rect(38, 34, 1, 3, skinD)
    for (x, y) in [(19, 33), (25, 35), (31, 33), (21, 36), (33, 35)] { c.rect(x, y, 3, 1, skinD) }
    // The heart: a dull red mark, lit up through his chest while his neck is up.
    c.rect(27, 33, 2, 2, C(0x9A3A2C))
    if stretch > 0 {
        let pulse: Double = 0.7 + 0.3 * sin(p.t * 8)
        let a: Double = pulse * stretch
        c.glowLine(27.5, 33.5, 28.5, 33.5, core: C(0xFFC0B0, a), glow: C(0xFF2A1A, a), coreR: 1.1, glowR: 4)
    }
    // The neck, ringed with creases, and the wide flat head on it.
    let hy = 25 - lift
    c.rect(22, hy + 7, 12, lift, skin); c.rect(33, hy + 7, 1, lift, skinD)
    for y in stride(from: hy + 8, to: 32, by: 2) { c.rect(23, y, 10, 1, skinD) }
    c.rect(19, hy, 18, 1, skin); c.rect(18, hy + 1, 20, 6, skin)
    c.rect(21, hy, 9, 1, skinL); c.rect(37, hy + 1, 1, 6, skinD); c.rect(18, hy + 6, 20, 1, skinD)
    // Big eyes under heavy lids, a long thin mouth.
    c.rect(20, hy + 1, 5, 1, skinD); c.rect(30, hy + 1, 5, 1, skinD)
    c.rect(21, hy + 2, 3, 3, eye); c.rect(31, hy + 2, 3, 3, eye)
    c.px(22, hy + 2, C(0x8AA4C8)); c.px(32, hy + 2, C(0x8AA4C8))
    c.rect(25, hy + 5, 6, 1, skinD)
    // Long thin arms: the left hanging, the right reaching out with the glowing finger.
    c.rect(15, 33, 2, 4, skin); c.px(14, 37, skinD); c.px(16, 37, skinD)
    if casting {
        let y = 33 - p.armRaise
        c.rect(38, y, 4, 2, skin); c.rect(42, y, 3, 1, skinL)
        c.px(45, y, C(0xFFE8D8))
    } else {
        c.rect(39, 33, 2, 4, skin); c.px(38, 37, skinD); c.px(40, 37, skinD)
    }
}

// MARK: - Elliclawd

/// Elliclawd: Clawd in a red hoodie with the hood up, his brown fringe peeking out, jeans and white trainers, astride
/// his BMX: white frame, black tyres, a basket on the handlebars with a white blanket in it. He doesn't fight.
/// Signature: he leaves a trail of sweets behind him, orange, yellow and brown, dropped one at a time from the bag.
private func drawElliclawd(_ c: PixelCanvas, _ p: Pose) {
    let hood = C(0xC8302A), hoodD = C(0x962222), hoodL = C(0xE04A3A), jeans = C(0x3A4A6A), hair = C(0x6A4428)
    let frame = C(0x9AA2AE), chrome = C(0xA8ACB4), wicker = C(0xA87A44), wickerD = C(0x7A5530)
    let sig = p.signature

    // The bike behind him (where it's parked when he sits down).
    if seatedPose { c.oy -= 4 }
    let spin: Double = p.walking ? p.t * 14 : 0.4
    wheel(c, 11, 39, hub: chrome, spin: spin)
    wheel(c, 48, 39, hub: chrome, spin: spin)
    cbLine(c, 11, 39, 28, 40, frame, 0.6)
    cbLine(c, 11, 39, 17, 31, frame, 0.6)
    cbLine(c, 28, 40, 45, 31, frame, 0.6)
    cbLine(c, 48, 39, 44, 29, chrome, 0.55)
    c.rect(14, 30, 5, 1, tyre)                                      // the saddle
    c.rect(42, 27, 1, 3, chrome); c.rect(41, 27, 2, 1, tyre)         // the handlebars
    c.pattern(44, 29, ["..ww..", "WKWKWK", "KWKWKW", "WKWKWK"], ["W": wicker, "K": wickerD, "w": cream])
    if seatedPose { c.oy += 4 }

    drawLegs(c, Look(leg: jeans), step: p.step)
    cbBoots(c, step: p.step, C(0xDADAD4), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: hood))
    // The hoodie: its pocket, the drawstrings.
    c.rect(18, 33, 20, 5, hood); c.rect(37, 33, 1, 5, hoodD); c.rect(18, 37, 20, 1, hoodD)
    c.rect(24, 35, 8, 2, hoodD); c.rect(25, 35, 6, 1, hoodL)
    // The hood, up round his face, his fringe under it.
    c.pattern(16, 21, [
        "......HHHHHHHHHH......",
        "....HHHHHHHHHHHHHH....",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHd.",
        ".HHHffffffffffffffHHd.",
        "HHHf.f..ff..f.f.f..Hd.",
        "HHH................Hd.",
        "HHd................Hd.",
        "HHd................Hd.",
        "HHd................Hd.",
        "HHd................Hd.",
        ".Hd................Hd.",
    ], ["H": hood, "d": hoodD, "f": hair])

    if let s = sig, s > 0.04, s < 0.96 {
        // The bag held out behind him, the sweets dropping out and left lying in a line as he goes.
        let k = (s - 0.04) / 0.92
        c.rect(13, 33, 3, 3, hood); c.rect(11, 31, 3, 4, C(0xE87A1A)); c.px(12, 32, C(0x6A3A1A))
        let sweets = [C(0xF07A1A), C(0xF0C81A), C(0x7A421E)]
        for i in 0..<9 {
            let age = k - Double(i) / 9
            guard age > 0 else { continue }
            let fall: Double = min(8, age * 70)
            let x = 12 - Int((age * 26).rounded()), y = 35 + Int(fall.rounded())
            guard x >= 0 else { continue }
            c.px(x, y, sweets[i % 3])
        }
    }
}

// MARK: - Gurtie

/// Gurtie: Clawd as the little sister, blond hair with a straight fringe and two pigtails sticking out tied with pink
/// ribbons, a pale blue dress with a white collar, white socks and red shoes. She doesn't fight. Signature: she
/// screams, hands to her cheeks, and E.Clawd pops up beside her and screams right back.
private func drawGurtie(_ c: PixelCanvas, _ p: Pose) {
    let dress = C(0x8AB4E0), dressD = C(0x6A94C0), hair = C(0xF0D070), hairL = C(0xFFEAA8), hairD = C(0xC8A040)
    let ribbon = C(0xF06A9A), maw = C(0x5A1A1E)
    let sig = p.signature
    let screaming = sig.map { $0 > 0.06 && $0 < 0.8 } ?? false
    let rise: Double = sig.map { s in s < 0.2 || s > 0.95 ? 0 : s < 0.35 ? (s - 0.2) / 0.15 : s > 0.8 ? (0.95 - s) / 0.15 : 1 } ?? 0

    drawLegs(c, Look(leg: C(0xF2EEE6)), step: p.step)
    cbBoots(c, step: p.step, C(0xC02A2A), height: 2)
    c.oy += p.breathe
    // The dress's skirt over the tops of her legs.
    if !seatedPose { c.rect(17, 38, 22, 2, dress); c.rect(17, 39, 22, 1, dressD) }
    drawBody(c, Look(arm: dress), armLeft: screaming ? 4 : 0, armRight: screaming ? 4 : 0)
    c.rect(18, 33, 20, 5, dress); c.rect(37, 33, 1, 5, dressD); c.rect(18, 37, 20, 1, dressD)
    c.rect(23, 33, 10, 1, cream)
    // The hair: a straight fringe, and the pigtails out each side.
    c.pattern(18, 21, [
        "....HHHHHHHHHHHH....",
        "..HHHHHHlHHHHHHHHH..",
        ".HHHHHHHHHHHHHlHHHH.",
        "HHHHHHHHHHHHHHHHHHHH",
        "HHHdHHHHdHHHHHHdHHHH",
        "HH.H.dH.H.dH.H.dH.HH",
        "HH................HH",
    ], ["H": hair, "l": hairL, "d": hairD])
    c.pattern(11, 25, ["....RRR", "..HHHRR", ".HHHH..", "HHlH...", "HHH....", "HH.....", "H......"],
              ["H": hair, "l": hairL, "R": ribbon])
    c.pattern(38, 25, ["RRR....", "RRHHH..", "..HHHH.", "...HlHH", "....HHH", ".....HH", "......H"],
              ["H": hair, "l": hairL, "R": ribbon])

    guard let s = sig else { return }
    if screaming {
        // Mouth wide open, hands on her cheeks, the scream ringing out round her head.
        c.rect(26, 31, 4, 3, maw); c.rect(27, 33, 2, 1, C(0xC84A5A))
        c.rect(22, 28, 2, 1, white); c.rect(32, 28, 2, 1, white)
        let on = Int(p.t * 10) % 2 == 0
        let ring = C(0xFFFFFF, on ? 0.85 : 0.5)
        cbLine(c, 13, 21, 10, 18, ring, 0.5); cbLine(c, 16, 18, 15, 15, ring, 0.5)
        cbLine(c, 41, 18, 43, 15, ring, 0.5); cbLine(c, 44, 22, 47, 20, ring, 0.5)
    }
    if rise > 0 {
        // E.Clawd, up out of nowhere at her side, screaming back.
        let skin = C(0x8A6A4C), skinD = C(0x654A32)
        let top = 44 - Int((rise * 15).rounded())
        risePattern(c, 50, top, [
            "..SSSSSSSSS.",
            ".SSSSSSSSSSS",
            "SdddSSSSdddS",
            "SEEESSSSEEES",
            "SEwESSSSEwES",
            "SSSSMMMMSSSS",
            ".SSSMRRMSSS.",
            "..SSMMMMSS..",
            "....SSSS....",
            "....SdSS....",
            "....SSSS....",
            "...SSdSSS...",
            "..SSSSSSSS..",
            "..SSSSSSSS..",
            "..SSSSSSSS..",
        ], ["S": skin, "d": skinD, "E": C(0x161E2E), "w": C(0x8AA4C8), "M": maw, "R": C(0xC84A5A)])
        if rise >= 1, s < 0.8 {
            let ring = C(0xFFFFFF, Int(p.t * 10) % 2 == 0 ? 0.5 : 0.85)
            cbLine(c, 64, 27, 67, 25, ring, 0.5); cbLine(c, 64, 31, 68, 31, ring, 0.5)
        }
    }
}

// MARK: - Chief Broody

/// Chief Broody: Clawd as the police chief in a tan uniform shirt with a gold badge, dark trousers, short dark hair and
/// square black-rimmed glasses. He fights with a rifle, carried upright at rest. Signature: he ladles chum off the
/// stern from a bucket, flinging it out; the shark's jaws heave up out of the water right in front of him and he leaps
/// back, then edges forward again once it's gone.
private func drawChiefBroody(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0xC8B07A), shirtD = C(0xA08A58), slacks = C(0x4A4436), hair = C(0x3A2A1E), rims = C(0x5A4636)
    let wood = C(0x7A4A28), metal = C(0x3A3C42), chum = C(0x8A2A22), pail = C(0x9AA0A8)
    let sig = p.signature
    let ladling = sig.map { $0 > 0.04 && $0 < 0.48 } ?? false
    let jaws: Double = sig.map { s in s > 0.44 && s < 0.84 ? (s - 0.44) / 0.4 : -1 } ?? -1
    let jumpK: Double = sig.map { s in s > 0.5 && s < 0.96 ? (s - 0.5) / 0.46 : -1 } ?? -1
    var back = 0, up = 0
    if jumpK >= 0 {
        let b: Double = jumpK < 0.2 ? jumpK / 0.2 : (1 - jumpK) / 0.8
        back = Int((b * 6).rounded())
        if jumpK < 0.2 { up = Int((sin(jumpK / 0.2 * .pi) * 3).rounded()) }
    }
    let ox = c.ox, oy = c.oy

    // The chum bucket, at his feet, while he's at it.
    if sig != nil, ladling || jaws >= 0 {
        c.pattern(42, 38, ["PPPPPPP", "PcccccP", ".PPPPP.", ".PPPPP.", ".PPPPP.", "..PPP.."], ["P": pail, "c": chum])
    }
    c.ox -= back; c.oy -= up
    drawLegs(c, Look(leg: slacks), step: p.step)
    cbBoots(c, step: p.step, C(0x18181C), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: shirt))
    // The uniform shirt: its placket, pockets and the badge.
    c.rect(18, 33, 20, 5, shirt); c.rect(37, 33, 1, 5, shirtD); c.rect(18, 37, 20, 1, slacks)
    c.rect(27, 33, 1, 4, shirtD); c.rect(21, 34, 4, 1, shirtD); c.rect(30, 34, 4, 1, shirtD)
    c.rect(31, 35, 2, 2, C(0xE8C04A)); c.px(32, 35, C(0xFFF0A0))
    // Short dark hair, and the glasses.
    c.pattern(18, 22, [
        "...HHHHHHHHHHHHH....",
        ".HHHHHHHHHhHHHHHHH..",
        "HHHHHHHHHHhHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHH",
        "HHH..............HHH",
    ], ["H": hair, "h": C(0x5A4430)])
    specs(c, rims, round: false)
    if jumpK >= 0 && jumpK < 0.6 { c.rect(22, 29, 2, 1, white); c.rect(32, 29, 2, 1, white) }   // wide-eyed

    if ladling {
        // Scooping chum out of the bucket and flinging it out over the water.
        let k = frac(((sig! - 0.04) / 0.44) * 2)
        let flung = k > 0.45
        let hand: (x: Double, y: Double) = flung ? (40, 30) : (40, 35)
        let angle: Double = flung ? -55 : 55
        c.rect(38, Int(hand.y) - 1, 3, 3, shirt)
        let bowl = cbReach(hand, angle, 7)
        cbLine(c, hand.x, hand.y, bowl.x, bowl.y, C(0x8A8E96), 0.5)
        c.rect(Int(bowl.x) - 1, Int(bowl.y), 3, 2, C(0x8A8E96))
        if flung {
            let f: Double = (k - 0.45) / 0.55
            for i in 0..<4 {
                let g: Double = f - Double(i) * 0.06
                guard g > 0 else { continue }
                let x = bowl.x + g * 18, y = bowl.y - sin(g * .pi) * 7 + g * 12
                c.rect(Int(x), Int(y), 2, 1, chum)
            }
        }
        c.ox = ox; c.oy = oy
        return
    }
    if sig != nil, jaws >= 0 || jumpK >= 0 {
        // Arms flung up as he jumps back.
        c.rect(15, 28, 3, 3, shirt); c.rect(38, 28, 3, 3, shirt)
        c.ox = ox; c.oy = oy
        if jaws >= 0 {
            let r: Double = jaws < 0.3 ? jaws / 0.3 : jaws > 0.7 ? (1 - jaws) / 0.3 : 1
            let top = 44 - Int((r * 17).rounded())
            let grey = C(0x7A8896), belly = C(0xE8ECEE), maw = C(0x3A0E14), tooth = C(0xFAFAF4), gum = C(0x9A2A34)
            risePattern(c, 49, top, [
                "........GG......",
                ".......GGGG.....",
                "......GGGGGG....",
                ".....GGGGGGGG...",
                "....GGeGGGGGGG..",
                "...GGGGGGGGGGGG.",
                "..gTgTgTGGGGGGGG",
                "..MMMMMMMGGGGGGG",
                ".MMMMMMMMMGGGGGG",
                ".MMMMMMMMMWWWWWW",
                "..gTgTgTgWWWWWWW",
                "...WWWWWWWWWWWWW",
                "....WWWWWWWWWWWW",
                ".....WWWWWWWWWW.",
                ".....WWWWWWWWWW.",
                ".....WWWWWWWWWW.",
                ".....WWWWWWWWWW.",
            ], ["G": grey, "W": belly, "M": maw, "T": tooth, "g": gum, "e": C(0x0A0A0E)])
            for i in 0..<5 {   // spray
                let x = 48 + i * 4 + Int(noise(i + Int(p.t * 6)) * 3), y = 43 - Int(r * Double(3 + i % 3))
                c.px(x, y, C(0xE8F4FF, 0.85))
            }
        }
        return
    }
    if p.fire != nil || p.ready {
        // The rifle levelled at the shoulder.
        c.oy += p.gunY
        c.rect(34, 32, 8, 2, wood); c.rect(33, 33, 3, 2, wood)
        c.rect(42, 32, 11, 1, metal); c.rect(42, 33, 6, 1, wood); c.px(51, 31, metal)
        c.rect(38, 32, 3, 3, shirt); c.rect(40, 33, 2, 2, clawdOrange)
        c.ox = ox; c.oy = oy
        return
    }
    // At rest: the rifle upright at his side.
    c.rect(41, 21, 1, 10, metal); c.rect(40, 29, 2, 9, wood); c.rect(38, 33, 3, 3, shirt)
    c.ox = ox; c.oy = oy
}

// MARK: - Hoopah

/// Hoopah: Clawd as the shark expert with a full brown beard, round wire-rimmed glasses, a pale khaki baseball cap and
/// a navy rain jacket over jeans. He fights with the spear from the shark cage, a long steel pole with its charge on
/// the end, stood upright at rest. Signature: he crushes a polystyrene cup in his fist, eyes narrowed, mocking Squint
/// and his beer can.
private func drawHoopah(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x2E3E5E), jacketD = C(0x1E2A44), jacketL = C(0x4A5E84), beard = C(0x6A4A2C), beardL = C(0x86603A)
    let cap = C(0xD8CCA8), capD = C(0xACA07A), wire = C(0xC8CCD4), jeans = C(0x4A5A78)
    let steel = C(0xC0C4CC), steelD = C(0x6A6E78)
    let sig = p.signature

    drawLegs(c, Look(leg: jeans), step: p.step)
    cbBoots(c, step: p.step, C(0x8A6A44), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: jacket))
    // The rain jacket, zipped, its collar up.
    c.rect(18, 33, 20, 5, jacket); c.rect(37, 33, 1, 5, jacketD); c.rect(18, 37, 20, 1, jacketD)
    c.rect(28, 33, 1, 5, jacketL); c.rect(19, 35, 4, 1, jacketD); c.rect(33, 35, 4, 1, jacketD)
    // The beard round his jaw, the moustache, and the cap.
    c.pattern(18, 27, [
        "BB................BB",
        "BB................BB",
        "BBB..............BBB",
        "BBBB...bbbbbb...BBBB",
        "BBBBBBBBBbBBBBBBBBBB",
        "BBBBBBbBBBBBBBbBBBBB",
    ], ["B": beard, "b": beardL])
    c.pattern(18, 21, [
        ".....CCCCCCCCC......",
        "...CCCCCCCCCCCCC....",
        "..CCCCCCCCCCCCCCC...",
        ".CCCCCCCCCCCCCCCCC..",
        "dddddddddddddddddddddddd",
        "BB................BB",
    ], ["C": cap, "d": capD, "B": beard])
    specs(c, wire, round: true)

    if let s = sig, s > 0.06, s < 0.94 {
        // The cup held up and crushed in his fist, eyes narrowed; the spear leant against his left side.
        let crush: Double = min(1, max(0, (s - 0.35) / 0.25))
        let h = 4 - Int((crush * 3).rounded()), w = 3 + Int(crush.rounded())
        c.rect(13, 14, 1, 24, steel); c.rect(13, 12, 1, 2, steelD)
        c.rect(38, 29, 3, 4, jacket)
        c.rect(40, 31 - h, w, h, cream); c.rect(40, 31 - h, w, 1, C(0xD8D4C8))
        c.rect(39, 30, 2, 2, clawdOrange)
        c.rect(22, 29, 2, 1, clawdOrange); c.rect(32, 29, 2, 1, clawdOrange)
        return
    }
    if let a = p.melee {
        cbSmear(c, cbHand, p.trail, from: 2, to: 18, C(0xE8ECF0))
        cbBar(c, cbHand, a, from: -6, to: 15, steel, r: 0.55)
        cbBar(c, cbHand, a, from: 15, to: 18, steelD, r: 0.95)
        let tip = cbReach(cbHand, a, 19.5)
        c.px(Int(tip.x.rounded()), Int(tip.y.rounded()), steel)
        c.rect(38, 33, 3, 3, jacket)
        return
    }
    // At rest: the spear upright in his hand.
    c.rect(41, 16, 1, 22, steel); c.rect(41, 13, 1, 3, steelD); c.px(41, 12, steel)
    c.rect(38, 33, 3, 3, jacket)
}

// MARK: - Squint

/// Squint: Clawd as the weathered old shark hunter, his face tanned, stubbled and screwed up against the glare, a dark
/// navy fisherman's cap, an olive work jacket, and a yellow barrel slung on his back on its rope. He fights with the
/// harpoon, raised to throw. Signature: he finishes a can of beer and crushes it in one hand, then tosses it over his
/// shoulder.
private func drawSquint(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xC86A48), jacket = C(0x524C34), jacketD = C(0x3A3522), shirt = C(0x8A8A82), cap = C(0x23283A)
    let capD = C(0x161A28), stubble = C(0x7A4A34), grey = C(0x9A9690), barrel = C(0xE8C020), barrelD = C(0xB08A10)
    let wood = C(0x8A6A44), iron = C(0x5A5E66)
    let sig = p.signature

    drawLegs(c, Look(leg: C(0x3E3A32)), step: p.step)
    cbBoots(c, step: p.step, C(0x2A2420), height: 3)
    c.oy += p.breathe
    // The barrel slung on his back, and its rope.
    c.pattern(11, 26, [".YYYYY.", "YYYYYYY", "BBBBBBB", "YYYYYYY", "YYYYYYY", "BBBBBBB", "YYYYYYY", ".YYYYY."],
              ["Y": barrel, "B": barrelD])
    drawBody(c, Look(body: skin, shade: C(0xA85A3A), arm: jacket, eye: nil))
    // Eyes screwed up under a heavy brow, crow's feet, the stubble.
    c.rect(21, 28, 4, 1, C(0x6A3A26)); c.rect(31, 28, 4, 1, C(0x6A3A26))
    c.rect(22, 30, 2, 2, ink); c.rect(32, 30, 2, 2, ink)
    c.px(20, 30, C(0x9A5236)); c.px(35, 30, C(0x9A5236))
    for (x, y) in [(20, 32), (23, 33), (26, 32), (29, 33), (31, 32), (34, 33), (36, 32), (25, 34)] { c.px(x, y, stubble) }
    // The jacket over a grey shirt.
    c.rect(18, 34, 20, 4, jacket); c.rect(37, 34, 1, 4, jacketD); c.rect(18, 37, 20, 1, jacketD)
    c.rect(25, 34, 6, 2, shirt); c.rect(24, 34, 1, 3, C(0x6A6448)); c.rect(31, 34, 1, 3, C(0x6A6448))
    // Grey hair at the sides, the cap.
    c.pattern(17, 21, [
        "....CCCCCCCCCCCC.....",
        "..CCCCCCCCCCCCCCCC...",
        ".CCCCCCCCCCCCCCCCCC..",
        ".CCCCCCCCCCCCCCCCCCC.",
        ".dddddddddddddddddddddd",
        ".gg................gg",
        ".g..................g",
    ], ["C": cap, "d": capD, "g": grey])

    if let s = sig, s > 0.06, s < 0.94 {
        // The can held up and crushed flat in his fist, then tossed back over his shoulder.
        let tin = C(0xD8DCE2), band = C(0xC8302A)
        c.rect(15, 33, 3, 3, jacket)
        if s < 0.62 {
            let crush: Double = min(1, max(0, (s - 0.3) / 0.22))
            let h = 5 - Int((crush * 3).rounded())
            c.rect(38, 29, 3, 4, jacket)
            c.rect(40, 31 - h, 3, h, tin); c.rect(40, 32 - h + h / 2, 3, 1, band)
            c.rect(39, 30, 2, 2, skin)
            if crush > 0.5 { c.px(43, 29, tin); c.px(39, 28, tin) }
        } else {
            let k: Double = (s - 0.62) / 0.32
            c.rect(38, 27, 3, 6, jacket); c.rect(38, 26, 3, 2, skin)
            let x = 40 - k * 36, y = 26 - sin(k * .pi) * 10
            c.rect(Int(x), Int(y), 3, 2, tin); c.px(Int(x) + 1, Int(y), band)
        }
        c.rect(41, 14, 1, 24, wood); c.rect(41, 11, 1, 3, iron)
        return
    }
    if p.fire != nil || p.ready {
        // The harpoon raised level, ready to throw.
        c.oy += p.gunY
        c.rect(32, 31, 20, 1, wood); c.rect(52, 31, 3, 1, iron)
        c.px(55, 31, C(0xC8CCD4)); c.px(53, 30, iron); c.px(53, 32, iron)
        c.rect(38, 31, 3, 3, jacket); c.rect(40, 31, 2, 2, skin)
        return
    }
    // At rest: the harpoon upright.
    c.rect(41, 14, 1, 24, wood); c.rect(41, 11, 1, 3, iron); c.px(40, 12, iron); c.px(42, 12, iron)
    c.rect(38, 33, 3, 3, jacket)
}

// MARK: - Roy Neery

/// Roy Neery: Clawd as the power-company lineman in grey-green work overalls over a light blue shirt, a tool belt,
/// brown work boots and messy dark hair, the right half of his face burnt red by the light from the sky. He fights
/// by throwing clods of earth. Signature: he sculpts the mountain out of mashed potato, a heap that he pats and
/// shapes into a flat-topped, ridged tower.
private func drawRoyNeery(_ c: PixelCanvas, _ p: Pose) {
    let overalls = C(0x6A7458), overallsD = C(0x4E563F), shirt = C(0xA8C0D8), shirtD = C(0x86A0BC)
    let hair = C(0x3E2A1C), burn = C(0xE24A3A), peel = C(0xF4A08A), dirt = C(0x5A3E26), dirtL = C(0x7A5838)
    let mash = C(0xF2E8C4), mashD = C(0xD4C49A), plate = C(0xE8ECEE)
    let sig = p.signature

    drawLegs(c, Look(leg: overalls), step: p.step)
    cbBoots(c, step: p.step, C(0x5A3A22), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: shirt))
    // The sunburn down the right half of his face, peeling a little.
    c.rect(28, 26, 9, 7, burn); c.rect(37, 26, 1, 7, C(0xB83A2C))
    c.px(30, 27, peel); c.px(35, 32, peel); c.px(29, 31, peel)
    c.rect(32, 29, 2, 3, ink)
    // The overalls' bib and straps over the shirt; the tool belt.
    c.rect(18, 33, 20, 5, shirt); c.rect(37, 33, 1, 5, shirtD)
    c.rect(21, 33, 14, 5, overalls); c.rect(21, 33, 2, 1, overallsD); c.rect(33, 33, 2, 1, overallsD)
    c.rect(25, 34, 6, 2, overallsD)
    c.rect(18, 37, 20, 1, C(0x5A3A22)); c.px(20, 37, C(0xC8CCD4)); c.px(34, 37, C(0xC8A848))
    // Messy dark hair.
    c.pattern(17, 21, [
        "....H..HH.H..H.......",
        "...HHHHHHHHHHHHHHH...",
        ".HHHHHHHHHhHHHHHHHH..",
        "HHHHHhHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHhHHHH",
        ".HH.H..........H..HH.",
    ], ["H": hair, "h": C(0x5A4430)])

    if let s = sig, s > 0.04, s < 0.96 {
        // The mashed potato on its plate in front of him, heaped up, then patted and shaped into the tower.
        let k = (s - 0.04) / 0.92
        c.rect(42, 43, 15, 1, plate); c.rect(43, 42, 13, 1, plate)
        if k < 0.45 {
            let rows = 1 + Int((k / 0.45 * 6).rounded())
            for r in 0..<rows {
                let half = max(1, 6 - (rows - 1 - r) * 6 / max(rows, 1))
                c.rect(49 - half, 41 - r, half * 2 + 1, 1, r == rows - 1 ? mash : (r % 2 == 0 ? mash : mashD))
            }
        } else {
            c.pattern(43, 33, [
                "....MMMMM....",
                "....MdMdM....",
                "...MMdMdMM...",
                "...MdMdMdM...",
                "..MMdMdMdMM..",
                "..MdMdMdMdM..",
                ".MMdMdMdMdMM.",
                "MMMMMMMMMMMMM",
                "MMMMMMMMMMMMM",
            ], ["M": mash, "d": mashD])
        }
        // His hand at it, patting.
        let pat = Int(p.t * 6) % 2
        let hy = k < 0.45 ? 37 + pat : 31 + pat * 2
        c.rect(38, min(33, hy), 3, abs(33 - hy) + 3, shirt)
        c.rect(41, hy, 3, 2, clawdOrange)
        return
    }
    if p.fire != nil || p.ready {
        // Arm forward with a clod in the hand; empty as it's thrown.
        c.oy += p.gunY
        c.rect(38, 31, 4, 3, shirt)
        if p.recoil == 0 { c.pattern(41, 29, [".dD.", "dDDd", "DDdD", ".DD."], ["D": dirt, "d": dirtL]) }
        else { c.rect(42, 31, 2, 2, clawdOrange) }
        return
    }
    c.rect(38, 33, 3, 3, shirt)
    c.pattern(39, 36, [".dD", "DDd", "dD."], ["D": dirt, "d": dirtL])
}

// MARK: - Jillian Geyser

/// Jillian Geyser: Clawd with dark hair to her shoulders, a cream knit jumper and brown trousers, her sketch pad tucked
/// under her arm. She doesn't fight. Signature: she holds the pad up, open on her charcoal drawing of the flat-topped
/// mountain she can't stop seeing.
private func drawJillianGeyser(_ c: PixelCanvas, _ p: Pose) {
    let jumper = C(0xE0D0A8), jumperD = C(0xBCA87E), trousers = C(0x5A3E2E), hair = C(0x2A1C16), hairL = C(0x4A3426)
    let cover = C(0x8A5A3A), page = C(0xF6F2E6), charcoal = C(0x3A3A40)
    let sig = p.signature

    drawLegs(c, Look(leg: trousers), step: p.step)
    cbBoots(c, step: p.step, C(0x2A1E16), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: jumper))
    c.rect(18, 33, 20, 5, jumper); c.rect(37, 33, 1, 5, jumperD); c.rect(18, 37, 20, 1, jumperD)
    c.rect(24, 33, 8, 1, jumperD)
    for x in stride(from: 20, to: 37, by: 3) { c.px(x, 35, jumperD) }
    // Dark hair falling to her shoulders.
    c.pattern(16, 20, [
        "......HHHHHHHHHH........",
        "....HHHHHHHHlHHHHHH.....",
        "..HHHHHHHHHHHHlHHHHHHH..",
        ".HHHHHHlHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHlHHH.",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHH....HHH.......HHHHH",
        "HHH.................HHH.",
        "HHH.................HHH.",
        "HHH.................HHH.",
        "HHH.................HHH.",
        "HHH..................HH.",
        "HHH..................HH.",
        ".H....................H.",
    ], ["H": hair, "l": hairL])

    if let s = sig, s > 0.06, s < 0.94 {
        // The pad held up open in both hands: the mountain, flat on top, scored with lines.
        let y = 22 - Int((min(1, (s - 0.06) / 0.15) * 2).rounded())
        c.rect(15, 30, 3, 5, jumper); c.rect(38, 30, 3, 5, jumper)
        c.rect(38, y, 14, 12, cover); c.rect(39, y + 1, 12, 10, page)
        c.pattern(40, y + 3, [
            "...CCCC...",
            "...CcCc...",
            "..CCcCcC..",
            "..CcCcCc..",
            ".CCCcCcCC.",
            "CCCCCCCCCC",
        ], ["C": charcoal, "c": C(0x6A6A72)])
        c.rect(39, y + 10, 3, 2, clawdOrange); c.rect(48, y + 10, 3, 2, clawdOrange)
        return
    }
    // The pad tucked under her right arm.
    c.rect(37, 30, 3, 8, cover); c.rect(37, 31, 1, 6, page)
    c.rect(38, 33, 3, 3, jumper)
}

// MARK: - Little Barry

/// Little Barry: Clawd as the toddler, small and delighted, with a wisp of blond hair, round shining eyes and pink
/// cheeks, a striped jumper under red dungarees and little white shoes. He doesn't fight. Signature: his toys come to
/// life and whir round him, the cymbal monkey clashing away in front of him and a toy car racing in circles round his
/// feet, and he beams.
private func drawLittleBarry(_ c: PixelCanvas, _ p: Pose) {
    let dungarees = C(0xC83A30), dungareesD = C(0x9A2A22), jumper = C(0xF0E6C8), stripe = C(0x4A7AB8)
    let hair = C(0xF0D488), hairD = C(0xC8A858), cheek = C(0xF09080)
    let sig = p.signature
    let playing = sig.map { $0 > 0.04 && $0 < 0.96 } ?? false
    let ang: Double = (sig ?? 0) * 4 * .pi
    let carX = 28 + Int((cos(ang) * 24).rounded()), carY = 43 + Int((sin(ang) * 1.5).rounded())
    let carBehind = sin(ang) < 0

    /// The toy car, a little red racer.
    func car() {
        c.pattern(carX - 3, carY - 3, [".BBB..", "BBbBBB", ".k..k."], ["B": C(0x3A8AE0), "b": C(0xBFE4FF), "k": tyre])
    }
    if playing && carBehind { car() }
    drawLegs(c, Look(leg: dungarees), step: p.step)
    cbBoots(c, step: p.step, cream, height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: jumper, eye: nil))
    // Round eyes with a shine, or screwed up with glee; pink cheeks.
    if playing {
        c.pattern(21, 29, [".EE.", "E..E"], ["E": ink]); c.pattern(31, 29, [".EE.", "E..E"], ["E": ink])
        c.rect(26, 31, 3, 2, C(0x5A1A1E))
    } else {
        c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
        c.px(22, 29, white); c.px(32, 29, white)
    }
    c.px(20, 32, cheek); c.px(21, 32, cheek); c.px(35, 32, cheek); c.px(36, 32, cheek)
    // The striped jumper, the dungarees' bib and straps over it.
    c.rect(18, 33, 20, 5, jumper)
    for y in [34, 36] { c.rect(18, y, 20, 1, stripe) }
    c.rect(22, 34, 12, 4, dungarees); c.rect(22, 33, 2, 1, dungarees); c.rect(32, 33, 2, 1, dungarees)
    c.rect(26, 35, 4, 1, dungareesD); c.rect(18, 37, 20, 1, dungareesD)
    c.rect(15, 34, 3, 1, stripe); c.rect(38, 34, 3, 1, stripe)
    // A wisp of fine blond hair.
    c.pattern(19, 22, [
        "........h.h.......",
        ".....HHHHHHH......",
        "...HHHHHHHHHHHH...",
        "..HHHHdHHHHdHHHH..",
        "...H..H....H...H..",
    ], ["H": hair, "h": hairD, "d": hairD])

    guard playing else { return }
    // The cymbal monkey, clashing.
    let shut = Int(p.t * 8) % 2 == 0
    let fur = C(0x6A4428), face = C(0xE8C8A0), vest = C(0xC8302A), brass = C(0xE8C040)
    c.pattern(46, 32, shut ? [
        "...BBBB...",
        "..BffffB..",
        "..BfkkfB..",
        "...ffff...",
        "....CC....",
        "..BRCCRB..",
        "...RRRR...",
        "...BBBB...",
        "...B..B...",
        "...B..B...",
        "..BB..BB..",
    ] : [
        "...BBBB...",
        "..BffffB..",
        "..BfkkfB..",
        "...ffff...",
        "CC......CC",
        "CBBRRRRBBC",
        "...RRRR...",
        "...BBBB...",
        "...B..B...",
        "...B..B...",
        "..BB..BB..",
    ], ["B": fur, "f": face, "k": ink, "R": vest, "C": brass])
    if shut { c.px(50, 30, C(0xFFF6C8)); c.px(48, 31, C(0xFFF6C8, 0.6)); c.px(53, 31, C(0xFFF6C8, 0.6)) }
    if !carBehind { car() }
}

// MARK: - Clawd Lacombe

/// Clawd Lacombe: Clawd as the kindly French scientist in a grey suit, white shirt and dark blue tie, his dark hair
/// receding and greying at the temples, a gentle look. He doesn't fight. Signature: he signs the five notes of the
/// visitors' tune with his hand, re, mi, do, the low do, sol, a coloured note lighting up for each.
private func drawClawdLacombe(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x5E6270), suitD = C(0x464A56), suitL = C(0x7A7E8C), tie = C(0x2A3A6A)
    let hair = C(0x3A302A), hairG = C(0x9A948C)
    let sig = p.signature

    drawLegs(c, Look(leg: suit), step: p.step)
    cbBoots(c, step: p.step, C(0x18181C), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit, eye: nil))
    // Kind eyes under soft brows, a small smile.
    c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    c.rect(21, 27, 3, 1, hairG); c.rect(32, 27, 3, 1, hairG)
    c.rect(26, 32, 4, 1, C(0xA85A40)); c.px(25, 31, C(0xA85A40)); c.px(30, 31, C(0xA85A40))
    // The suit, the shirt and tie, the lapels.
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(24, 33, ["lSTTSl", ".lTTl.", "..TT..", "..TT.."], ["l": suitL, "S": cream, "T": tie])
    // Receding hair, grey at the temples.
    c.pattern(17, 22, [
        ".....HHHHHHHHHH.......",
        "...HHHHHHHHHHHHHHH....",
        "..HHHHHHHHHHHHHHHHH...",
        ".HHHHHHHHHHHHHHHHHHH..",
        ".gHHH..........HHHHg..",
        ".gH..............HHg..",
        ".g.................g..",
    ], ["H": hair, "g": hairG])

    if let s = sig, s > 0.04, s < 0.96 {
        let k = (s - 0.04) / 0.92
        let note = min(4, Int(k * 5))
        handSign(c, note: note, x: 41, sleeve: suit, hand: clawdOrange)
        let f: Double = k * 5 - Double(note)
        quaver(c, 46, noteY[note] - 6 - Int(f * 5), noteColours[note].alpha(1 - f * 0.6))
        return
    }
    c.rect(38, 33, 3, 3, suit)
}

// MARK: - The Tall Visitor

/// Half-widths of the Tall Visitor's head, row by row from its crown (row 3) down to its narrow chin.
private let visitorHead = [4, 6, 7, 8, 8, 9, 9, 9, 9, 9, 9, 9, 8, 7, 6, 5, 4, 3, 2]

/// The Tall Visitor: Clawd glowing white as the tall, thin alien from the mothership. A huge bald head, wide at the
/// crown and narrowing to a small pointed chin, two great dark almond eyes slanting up and out, a thin neck, a narrow
/// ribbed chest, long thin arms with long fingers, and four long thin pale legs, a soft halo round all of it. It
/// fights with a steady white glow from its outstretched fingers. Signature: it answers Lacombe's hand signs, its
/// own long hand signing the five notes back, then smiles.
private func drawTallVisitor(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xF4F6FF), shade = C(0xC8D4F0), leg = C(0xDCE4F6), eye = C(0x14182A), glint = C(0x5A6A9A)
    let clear = C(0, 0)
    let sig = p.signature
    let casting = p.zap != nil || p.armRaise > 0
    let pulse: Double = 0.85 + 0.15 * sin(p.lt * 3)

    // The halo, round the head and down the body.
    c.glowLine(28, 11, 28, 27, core: clear, glow: C(0xD8E6FF, 0.4 * pulse), coreR: 0, glowR: 13)
    // Four long thin legs, well apart, a pale toe forward on each (folded under it when it sits).
    if seatedPose {
        for lx in [20, 25, 30, 35] { c.rect(lx - 1, 38, 3, 2, leg) }
    } else {
        for (i, lx) in [20, 25, 30, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            let foot = lifted ? 42 : 43
            c.rect(lx, 32, 1, foot - 31, leg)
            c.px(lx + 1, foot, leg)
            c.px(lx, 38, shade)                        // the knee
        }
    }
    c.oy += p.breathe
    // The narrow chest, faintly ribbed, tapering to a thin waist over a narrow pelvis the legs hang from.
    c.rect(23, 23, 10, 6, skin); c.rect(24, 29, 8, 2, skin); c.rect(20, 31, 16, 2, skin)
    c.rect(32, 23, 1, 6, shade); c.rect(31, 29, 1, 2, shade); c.rect(20, 32, 16, 1, shade)
    for y in [25, 27] { c.rect(24, y, 3, 1, leg); c.rect(29, y, 3, 1, leg) }
    // The thin neck.
    c.rect(27, 21, 2, 2, skin); c.px(28, 22, shade)
    // The great bald head: a wide crown narrowing to the chin.
    for (r, half) in visitorHead.enumerated() {
        c.rect(28 - half, 3 + r, half * 2, 1, skin)
        c.px(27 + half, 3 + r, shade)
    }
    c.rect(23, 5, 3, 1, white); c.rect(22, 6, 2, 1, white)
    // Huge dark almond eyes slanting up and out.
    c.pattern(20, 11, ["EE....", "EEEEE.", ".EEEEE", "...EEE"], ["E": eye])
    c.pattern(30, 11, ["....EE", ".EEEEE", "EEEEE.", "EEE..."], ["E": eye])
    c.px(21, 12, glint); c.px(34, 12, glint)
    // A tiny mouth over the chin.
    c.rect(27, 18, 2, 1, shade)
    // The left arm, long and thin, hanging past its hip with long fingers.
    cbLine(c, 23, 24, 18, 30, skin, 0.5); cbLine(c, 18, 30, 17, 37, skin, 0.5)
    c.px(16, 38, shade); c.px(17, 39, shade); c.px(18, 38, shade)

    if let s = sig, s > 0.04, s < 0.96 {
        let k = (s - 0.04) / 0.92
        if k < 0.7 {
            let note = min(4, Int(k / 0.7 * 5))
            let hy = Double(noteY[note]) + 1
            cbLine(c, 32, 24, 37, 28, skin, 0.5); cbLine(c, 37, 28, 41, hy, skin, 0.5)
            handSign(c, note: note, x: 41, sleeve: clear, hand: white, long: true)
            let f: Double = k / 0.7 * 5 - Double(note)
            quaver(c, 47, noteY[note] - 6 - Int(f * 5), noteColours[note].alpha(1 - f * 0.6))
        } else {
            cbLine(c, 32, 24, 37, 30, skin, 0.5); cbLine(c, 37, 30, 38, 37, skin, 0.5)
            // The smile.
            c.pattern(25, 17, ["S....S", ".SSSS."], ["S": C(0x8A96B8)])
        }
        return
    }
    if casting {
        // The arm reaching out, long fingers spread towards its target.
        let y = Double(31 - p.armRaise)
        cbLine(c, 32, 24, 38, y + 0.5, skin, 0.5); cbLine(c, 38, y + 0.5, 44, y + 0.5, skin, 0.5)
        let iy = Int(y)
        c.rect(44, iy - 1, 4, 1, skin); c.rect(44, iy + 1, 4, 1, skin); c.rect(44, iy, 5, 1, white)
        return
    }
    cbLine(c, 32, 24, 37, 30, skin, 0.5); cbLine(c, 37, 30, 38, 37, skin, 0.5)
    c.px(37, 38, shade); c.px(38, 39, shade); c.px(39, 38, shade)
}
