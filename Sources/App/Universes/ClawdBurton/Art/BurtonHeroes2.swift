import Foundation

// Heroes: Beetlejuice and Beetlejuice Beetlejuice. The living Deathzes (Lydia with her camera, her stepmother Delia
// the artist, her daughter Astrid), the newly dead Maitclawds who haunt their own house, and the Afterlife's staff:
// Junoh the caseworker, Wolf Jaxon the detective and the Shrunken-Head Man. Every one of them is Clawd in costume.

let burtonHeroes2: [BurtonHero: Persona] = [
    .lydiaDeathz: Persona(name: "Lydia Deathz", weapon: .none, headTop: 15, signature: 3.4,
                          callout: "Strange and unusual.", draw: drawLydia),
    .adamMaitclawd: Persona(name: "Adam Maitclawd", weapon: .none, headTop: 22, signature: 3.2, draw: drawAdam),
    .barbaraMaitclawd: Persona(name: "Barbara Maitclawd", weapon: .none, headTop: 21, signature: 3.2, draw: drawBarbara),
    .deliaDeathz: Persona(name: "Delia Deathz", weapon: .none, headTop: 20, signature: 3.4, draw: drawDelia),
    .astridDeathz: Persona(name: "Astrid Deathz", weapon: .none, headTop: 21, signature: 3.6, draw: drawAstrid),
    .junoh: Persona(name: "Junoh", weapon: .none, headTop: 15, signature: 3.6, callout: "Read the Handbook!",
                    draw: drawJunoh),
    .wolfJaxon: Persona(name: "Wolf Jaxon", weapon: .blaster, shot: .bullet, muzzle: (48, 31.5), headTop: 22,
                        signature: 3.4, draw: drawWolfJaxon),
    .shrunkenHeadMan: Persona(name: "The Shrunken-Head Man", weapon: .none, headTop: 11, signature: 3.0,
                              draw: drawShrunkenHeadMan),
]

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

// MARK: - Lydia Deathz

/// Lydia Deathz: Clawd in a wide, flat-brimmed black hat over short black hair with a spiky fringe, a long black coat
/// buttoned down the front with a little gold brooch at the collar, black lace-up boots, and an old camera held in
/// both hands on its strap. She doesn't fight. Signature: she lifts the camera to her eye, the flash goes off, and she
/// lowers it again.
private func drawLydia(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x1E1C24), coatD = C(0x131118), coatL = C(0x3A3644)
    let hair = C(0x16141C), hairL = C(0x343A58), hat = C(0x121016), hatL = C(0x2C2834)
    let sig = p.signature
    let up = sig.map { min(ramp($0, 0.08, 0.28), 1 - ramp($0, 0.78, 0.94)) } ?? 0   // the camera at her eye
    let flash = sig.map { $0 >= 0.42 && $0 < 0.62 ? 1 - ramp($0, 0.42, 0.62) : 0 } ?? 0

    drawLegs(c, Look(leg: C(0x24222A)), step: p.step)
    burtonBoots(c, step: p.step, C(0x0C0B0E), height: 3)
    c.oy += p.breathe
    // The long black coat: its tails over her legs, buttoned over the bottom of Clawd, the brooch at the collar.
    let tails = seatedPose ? 1 : 3
    c.rect(17, 38, 22, tails, coat); c.rect(17, 37 + tails, 22, 1, coatD); c.rect(28, 38, 1, tails, coatD)
    drawBody(c, Look(arm: coat))
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD); c.rect(18, 37, 20, 1, coatD)
    c.rect(22, 33, 1, 4, coatL); c.rect(33, 33, 1, 4, coatL); c.px(28, 33, C(0xD8B040))
    // Short black hair over the top of Clawd, the spiky fringe coming down to her eyes.
    c.pattern(17, 23, [
        ".HHHHHHHhHHHHHHhHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHH.HH.HHH.HH.HHHHH.",
        ".HH...H...H...H....HH.",
        ".HH................HH.",
        ".H..................H.",
    ], ["H": hair, "h": hairL])
    // The wide flat-brimmed hat, its brim drooping a little at the ends.
    c.pattern(21, 15, ["...HHHHHHHH...", ".HHHHHHHHHHHH.", "HHHHHHHHHHHHHH", "HHHHHHHHHHHHHH", "HHHHHHHHHHHHHH",
                       "hhhhhhhhhhhhhh"], ["H": hat, "h": hatL])
    c.rect(11, 21, 34, 1, hat); c.rect(9, 22, 38, 1, hat); c.px(8, 23, hat); c.px(47, 23, hat)

    // The camera in both hands: at her chest, or lifted to her right eye.
    let camX = 24 + Int((up * 6).rounded()), camY = 33 - Int((up * 6).rounded())
    burtonLine(c, 16.5, 34, Double(camX), Double(camY + 3), coat, 1.2)
    burtonLine(c, 39.5, 34, Double(camX + 8), Double(camY + 3), coat, 1.2)
    c.pattern(camX, camY, ["..SS....", "KKKKKKKK", "KSKLLLKK", "KKKLGLKK", "KKKLLLKK"],
              ["S": C(0xB8BCC4), "K": C(0x101014), "L": C(0x4A4A54), "G": C(0x8AB8E0)])
    c.rect(camX - 2, camY + 2, 2, 2, clawdOrange); c.rect(camX + 8, camY + 2, 2, 2, clawdOrange)
    if flash > 0 {
        // The flash: a white burst from the top of the camera, rays shooting out.
        let fx = Double(camX) + 2.5, fy = Double(camY) - 0.5, r = 3 + (1 - flash) * 7
        c.glowLine(fx, fy, fx, fy, core: C(0xFFFFFF, flash), glow: C(0xFFF6C8, flash), coreR: 1.6, glowR: r)
        for k in 0..<8 {
            let a = Double(k) / 8 * 2 * .pi
            c.glowLine(fx + cos(a) * 2, fy + sin(a) * 2, fx + cos(a) * r * 1.4, fy + sin(a) * r * 1.4,
                       core: C(0xFFFFFF, flash), glow: C(0xFFF6C8, flash * 0.6), coreR: 0.4, glowR: 1)
        }
    }
}

// MARK: - The Maitclawds

/// Adam Maitclawd: a kind, ordinary ghost with a faint pale glow: Clawd with short brown hair, sensible glasses, a tan
/// cardigan over a pale blue shirt. He doesn't fight. Signature: he grabs his face and pulls it long, Clawd stretching
/// tall, hollow drooping eyes and a gaping mouth, then lets go and it snaps back with a wobble.
private func drawAdam(_ c: PixelCanvas, _ p: Pose) { burtonGhost(c) { drawAdamFigure($0, p) } }

private func drawAdamFigure(_ c: PixelCanvas, _ p: Pose) {
    let cardi = C(0xB09A6E), cardiD = C(0x8E7A52), hair = C(0x6A4A2E), hairL = C(0x8A6440), rim = C(0x4A3A2A)
    let sig = p.signature
    let k = sig.map { min(ramp($0, 0.1, 0.4), 1 - ramp($0, 0.74, 0.78)) } ?? 0
    let wobble = sig.map { $0 >= 0.78 && $0 < 0.92 ? Int((sin(ramp($0, 0.78, 0.92) * .pi * 5) * 1.2).rounded()) : 0 } ?? 0
    let scary = k > 0.25, stretch = Int((k * 7).rounded())

    drawLegs(c, Look(leg: C(0x5A5048)), step: p.step)
    burtonBoots(c, step: p.step, C(0x2E2420), height: 1)
    c.oy += p.breathe
    c.ox += wobble
    // Clawd, pulled taller while he scares: the top of him stretched up `stretch` rows.
    drawBody(c, Look(arm: cardi, eye: scary ? nil : ink))
    if stretch > 0 { c.rect(18, 26 - stretch, 20, stretch, clawdOrange); c.rect(37, 26 - stretch, 1, stretch, clawdShade) }
    // The cardigan over the bottom of Clawd, the shirt in its V, buttons.
    c.rect(18, 33, 20, 5, cardi); c.rect(37, 33, 1, 5, cardiD); c.rect(18, 37, 20, 1, cardiD)
    c.pattern(24, 33, ["SSSSSSSS", ".SSSSSS.", "..SSSS.."], ["S": C(0xB8CCE0)]); c.px(28, 36, C(0x5A4A30))
    if scary {
        // Hollow eyes drooping down his long face, a gaping mouth, his hands pulling at his cheeks.
        c.rect(21, 27 - stretch / 2, 3, 5 + stretch / 2, ink); c.rect(32, 27 - stretch / 2, 3, 5 + stretch / 2, ink)
        c.rect(25, 30, 6, 3, ink); c.rect(26, 31, 4, 1, C(0x6A1A22))
        c.rect(15, 28, 3, 5, cardi); c.rect(16, 27, 3, 2, clawdOrange); c.rect(38, 28, 3, 5, cardi); c.rect(37, 27, 3, 2, clawdOrange)
    } else {
        // His glasses.
        c.pattern(20, 28, ["RRRRR....RRRRR", "R...RRRRRR...R", "R...R....R...R", "RRRRR....RRRRR"], ["R": rim])
    }
    // Short brown hair, parted, over the top of him.
    c.pattern(17, 22 - stretch, [
        "....HHHHHHHHHHHHHH....",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHHHhHHHHHHHHHHHHH.",
        ".HHHHHHhHHHHHHHHHHHHH.",
        ".HHHHHH.HHHHHHHHHHHHH.",
        ".HH.........HHHHHHHHH.",
        ".H..................H.",
    ], ["H": hair, "h": hairL])
}

/// Barbara Maitclawd: a ghost with a faint pale glow: Clawd with a kind auburn bob and a dusty blue dress with little
/// pink and white flowers on it. She doesn't fight. Signature: she pulls her face back into a skull, Clawd turning
/// bone-white, black sockets and bared teeth, her hair standing up, then lets go and it snaps back with a wobble.
private func drawBarbara(_ c: PixelCanvas, _ p: Pose) { burtonGhost(c) { drawBarbaraFigure($0, p) } }

private func drawBarbaraFigure(_ c: PixelCanvas, _ p: Pose) {
    let dress = C(0x8AAED0), dressD = C(0x6A8EB0), hair = C(0x9A5430), hairL = C(0xB86A40), hairD = C(0x6E3A20)
    let bone = C(0xF2F0E6), boneD = C(0xC8C4B8)
    let sig = p.signature
    let k = sig.map { min(ramp($0, 0.1, 0.4), 1 - ramp($0, 0.74, 0.78)) } ?? 0
    let wobble = sig.map { $0 >= 0.78 && $0 < 0.92 ? Int((sin(ramp($0, 0.78, 0.92) * .pi * 5) * 1.2).rounded()) : 0 } ?? 0
    let scary = k > 0.25

    drawLegs(c, Look(leg: clawdOrange), step: p.step)
    burtonBoots(c, step: p.step, C(0x5A7A9A), height: 1)
    c.oy += p.breathe
    c.ox += wobble
    // The dress: its skirt over the tops of her legs, the bodice over the bottom of Clawd, flowers scattered on it.
    c.rect(17, 38, 22, seatedPose ? 1 : 2, dress)
    drawBody(c, scary ? Look(body: bone, shade: boneD, arm: dress, eye: nil) : Look(arm: dress))
    c.rect(18, 33, 20, 5, dress); c.rect(37, 33, 1, 5, dressD)
    for y in 33...39 {
        for x in 17...38 where noise(x * 53 + y * 97 + 4100) < 0.1 && (y < 38 || !seatedPose) {
            c.px(x, y, noise(x * 31 + y * 7) < 0.5 ? C(0xE87AA0) : C(0xF8F4F0))
        }
    }
    c.pattern(25, 33, ["WWWWWW", ".WWWW."], ["W": C(0xF4F0E8)])
    if scary {
        // The skull: big black sockets, a nose hole, bared teeth; her hands pulling her face back.
        c.rect(20, 27, 5, 5, ink); c.rect(31, 27, 5, 5, ink); c.px(27, 31, ink); c.px(28, 31, ink)
        c.pattern(22, 32, ["KWKWKWKWKWKK"], ["K": ink, "W": bone])
        c.rect(15, 27, 3, 6, dress); c.rect(38, 27, 3, 6, dress)
    }
    // The auburn bob over the top of Clawd, its ends curling under at her jaw; blown straight up while she scares.
    if scary {
        c.pattern(17, 16, [".H..H..H...H..H..H....", ".HH.HH.HH..HH.HH.HH...", "HHHHHHHHHHHHHHHHHHHHH.",
                           "HHHHHHHHHHHHHHHHHHHHHH", ".HHHHHHHHHHHHHHHHHHHH.", ".HHHHHHHHHHHHHHHHHHHH."],
                  ["H": hair])
        // Down to the top of the skull, so no gap shows between them.
        c.rect(17, 22, 22, 4, hair)
    } else {
        c.pattern(16, 21, [
            ".....HHHHHHHHHHHHHH.....",
            "...HHHHHHHHHHHHlHHHHH...",
            "..HHHHHlHHHHHHHHHHHHHH..",
            ".HHHHHHHHHHHHHHHHHHHHHH.",
            ".HHHHHHHHH....HHHHHHHHH.",
            ".HHHH..............HHHH.",
            ".HHd................dHH.",
            ".HH..................HH.",
            ".HH..................HH.",
            ".HHd................dHH.",
            "..dH................Hd..",
        ], ["H": hair, "l": hairL, "d": hairD])
    }
    c.ox -= wobble
}

// MARK: - Delia Deathz

/// Delia Deathz: Clawd with a sharp, glossy black bob and a blunt fringe, big gold hoop earrings, and a dramatic red
/// dress with pointed padded shoulders and black zigzags at the hem. She doesn't fight. Signature: one of her pointy
/// sculptures appears beside her, and she strikes an arty pose, an arm flung up over her head.
private func drawDelia(_ c: PixelCanvas, _ p: Pose) {
    let red = C(0xC8202A), redD = C(0x8E1418), hair = C(0x111016), shine = C(0x3A3A4A), gold = C(0xE0B030)
    let sig = p.signature
    let art = sig.map { min(ramp($0, 0.05, 0.25), 1 - ramp($0, 0.85, 0.97)) } ?? 0
    let pose = sig.map { min(ramp($0, 0.22, 0.32), 1 - ramp($0, 0.8, 0.88)) } ?? 0

    if art > 0 {
        // The sculpture: black spikes jutting up from a block, a red one through the middle.
        let s = PixelCanvas(c.w, c.h)
        s.ox = c.ox; s.oy = c.oy
        s.rect(1, 39, 12, 5, C(0x2A2A30)); s.rect(1, 39, 12, 1, C(0x4A4A54))
        burtonTriangle(s, (2, 39), (7, 39), (1, 20), burtonInk)
        burtonTriangle(s, (5, 39), (10, 39), (8, 14), burtonInk)
        burtonTriangle(s, (6, 33), (9, 33), (13, 22), red)
        burtonTriangle(s, (8, 39), (12, 39), (14, 28), burtonInk)
        let (ox, oy) = (c.ox, c.oy)
        c.ox = 0; c.oy = 0
        c.paste(s, alpha: art)
        c.ox = ox; c.oy = oy
    }
    drawLegs(c, Look(leg: C(0x1A1A20)), step: p.step)
    burtonBoots(c, step: p.step, red, height: 1)
    c.oy += p.breathe
    // The red dress: its skirt flaring over her legs to a zigzag hem, the bodice over the bottom of Clawd, a black
    // belt, and the pointed padded shoulders sticking out at its sides.
    let tails = seatedPose ? 1 : 3
    for y in 38..<(38 + tails) { let hw = 11 + (y - 38); c.rect(28 - hw, y, hw * 2, 1, red) }
    for x in stride(from: 15, to: 41, by: 2) { c.px(x, 37 + tails, burtonInk) }
    drawBody(c, Look(arm: red))
    c.rect(18, 33, 20, 5, red); c.rect(37, 33, 1, 5, redD); c.rect(18, 36, 20, 1, burtonInk)
    c.pattern(25, 33, ["K....K", ".K..K.", "..KK.."], ["K": burtonInk])
    burtonTriangle(c, (13, 33), (19, 33), (18, 36), red); burtonTriangle(c, (37, 33), (43, 33), (38, 36), redD)
    // The sharp bob: a dead-straight fringe across her brow, the sides cut off square at her jaw; gold hoops below.
    c.pattern(16, 20, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHHHH...",
        "..HHHHHsHHHHHHHHsHHHHH..",
        ".HHHHHHsHHHHHHHHsHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHHH..............HHHH.",
        "..HHH..............HHH..",
    ], ["H": hair, "s": shine])
    for x in [15, 39] { c.pattern(x - 1, 31, [".G.", "G.G", "G.G", ".G."], ["G": gold]) }
    // Arms: one flung up over her head and the other on her hip in the pose; otherwise at her sides.
    if pose > 0 {
        let hy = 33 - pose * 22
        burtonLine(c, 39.5, 34, 41.5, hy, red, 1.2); c.rect(41, Int(hy.rounded()) - 2, 2, 2, clawdOrange)
    }
}

// MARK: - Astrid Deathz

/// Astrid Deathz: Clawd with long straight dark hair falling down both sides, brows lowered in a scowl, a navy school
/// blazer with a gold crest over a grey hoodie. She doesn't fight. Signature: she rolls her eyes, then pulls the
/// hood up over her head and folds her arms.
private func drawAstrid(_ c: PixelCanvas, _ p: Pose) {
    let blazer = C(0x283050), blazerD = C(0x1A2038), hood = C(0x8A8C94), hoodD = C(0x6A6C74)
    let hair = C(0x2E2220), hairL = C(0x4A3632)
    let sig = p.signature
    let rolling = sig.map { $0 > 0.08 && $0 < 0.4 } ?? false
    let hoodUp = sig.map { $0 >= 0.45 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: C(0x3A3A44)), step: p.step)
    burtonBoots(c, step: p.step, C(0x16161B), height: 2)
    c.oy += p.breathe
    // Clawd, eyes rolled up to show their whites while she rolls them.
    drawBody(c, Look(arm: blazer, eye: rolling ? nil : ink))
    if rolling { for ex in [22, 32] { c.rect(ex, 29, 2, 3, C(0xF4F4F0)); c.rect(ex, 29, 2, 1, ink) } }
    // The scowl: brows slanting down towards her nose.
    c.pattern(21, 27, ["KK........KK", "..K......K.."], ["K": hairL])
    // The blazer over the bottom of Clawd, open on the grey hoodie, the gold crest on its pocket.
    c.rect(18, 33, 20, 5, blazer); c.rect(37, 33, 1, 5, blazerD); c.rect(18, 37, 20, 1, blazerD)
    c.rect(25, 33, 6, 5, hood); c.rect(25, 33, 6, 1, hoodD)
    c.pattern(33, 34, ["YYY", "YRY", ".Y."], ["Y": C(0xD8B040), "R": C(0x8E1418)])
    if hoodUp {
        // The hood up over her head and down her sides, and her arms folded across the front.
        c.pattern(16, 20, [
            "......GGGGGGGGGGGG......",
            "...GGGGGGGGGGGGGGGGGG...",
            "..GGGGGGGGGGGGGGGGGGGG..",
            ".GGGGGGGGGGGGGGGGGGGGGg.",
            ".GGGGgggggggggggggGGGGg.",
            ".GGGg..............gGGg.",
        ] + Array(repeating: ".GGg................gGg.", count: 6) + [
            ".GGGg..............gGgg.",
        ], ["G": hood, "g": hoodD])
        c.rect(17, 34, 22, 3, blazer); c.rect(17, 36, 22, 1, blazerD); c.px(21, 35, clawdOrange); c.px(34, 35, clawdOrange)
        return
    }
    // Long straight dark hair over the top of Clawd and falling down past her shoulders.
    c.pattern(16, 21, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHlHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHH......HHHHH.",
        ".HHHH..............HHHH.",
    ] + Array(repeating: ".HHH................HHH.", count: 8) + [
        ".HHH................HHH.",
        "..H..................H..",
    ], ["H": hair, "l": hairL])
}

// MARK: - Junoh

/// Junoh: the Afterlife caseworker, an old woman: Clawd with grey hair pulled up into a bun, little glasses, a dull
/// green cardigan and a dark skirt. She holds the Handbook for the Recently Deceased. She doesn't fight. Signature:
/// she taps the Handbook, once, twice, three times, and a puff of smoke curls out of her collar.
private func drawJunoh(_ c: PixelCanvas, _ p: Pose) {
    let cardi = C(0x6A7A62), cardiD = C(0x4E5C48), skirt = C(0x3A3640), grey = C(0xC8C8CC), greyD = C(0x9A9AA2)
    let sig = p.signature
    let tapping = sig.map { $0 > 0.08 && $0 < 0.5 } ?? false
    let tap = tapping && frac(p.t * 2.5) < 0.5
    let smoke = sig.map { ramp($0, 0.45, 0.95) } ?? 0

    drawLegs(c, Look(leg: C(0x9A9488)), step: p.step)
    burtonBoots(c, step: p.step, C(0x2A2420), height: 1)
    c.oy += p.breathe
    // The skirt over the tops of her legs, the cardigan over the bottom of Clawd.
    c.rect(18, 38, 20, seatedPose ? 1 : 2, skirt)
    drawBody(c, Look(arm: cardi))
    c.rect(18, 33, 20, 5, cardi); c.rect(37, 33, 1, 5, cardiD); c.rect(18, 37, 20, 1, cardiD)
    c.pattern(25, 33, ["WWWWWW", ".WWWW."], ["W": C(0xE8E4DC)]); c.px(28, 36, C(0x2E3A28))
    // Little glasses over her eyes, and the lines under them.
    c.pattern(21, 28, ["PPPP......PPPP", "P..PPPPPPPP..P", "P..P......P..P", "PPPP......PPPP"], ["P": C(0x8A7A5A)])
    c.px(21, 32, clawdShade); c.px(34, 32, clawdShade)
    // The grey hair over the top of Clawd, and the bun on top.
    c.pattern(25, 15, ["..GGG..", ".GGGGG.", "GGGgGGG", "GGGGGgG", ".GGGGG.", "ggggggg"], ["G": grey, "g": greyD])
    c.pattern(17, 21, [
        "......GGGGGGGGGG......",
        "...GGGGGGGGGGGGGGGG...",
        "..GGGGgGGGGGGGGgGGGG..",
        ".GGGGGGGGGGGGGGGGGGGG.",
        ".GGGGGGGGGGGGGGGGGGGG.",
        ".GGG..............GGG.",
        ".GG................GG.",
        ".G..................G.",
    ], ["G": grey, "g": greyD])
    // The Handbook held up in her right hand; her left hand tapping it, the arm across under her chin with a dark
    // underside so it reads against the cardigan.
    c.rect(38, 33, 3, 3, cardi)
    burtonHandbook(c, x: 39, y: 27)
    if tapping {
        let hand = tap ? 32.0 : 30.0
        c.rect(15, 33, 3, 3, cardi); burtonLine(c, 18, 34, 36, hand + 2, cardi, 1.0)
        burtonLine(c, 18, 35.5, 36, hand + 3.5, cardiD, 0.5)
        c.rect(37, Int(hand), 2, 2, clawdOrange)
    } else {
        c.rect(15, 33, 3, 3, cardi)
    }
    if smoke > 0 {
        // A puff of smoke curling up out of her collar, thinning as it rises.
        for i in 0..<12 {
            let f = Double(i) / 11
            guard f <= smoke * 1.3 else { break }
            let x = 31 + f * 5 + sin(f * 7 + p.t * 3) * 2, y = 33 - f * 22
            c.glowLine(x, y, x, y, core: C(0xEEF0F4, 0.95 * (1 - f * 0.5)), glow: C(0xC8CCD4, 0.7 * (1 - f * 0.7)),
                       coreR: 1.1 + f, glowR: 2.2 + f * 1.5)
        }
    }
}

// MARK: - Wolf Jaxon

/// Wolf Jaxon: the Afterlife's detective, an ex-action-movie star: Clawd with black hair slicked straight back with a
/// sheen, stubble, and a tan trench coat belted at the waist, its collar turned up. He shoots a pistol. Signature: he
/// flashes his gold badge, then strikes a movie-hero pose, the pistol up beside his face.
private func drawWolfJaxon(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0xB8986A), coatD = C(0x8E7448), coatL = C(0xD4B888)
    let hair = C(0x16161C), hairL = C(0x4A4A5A), gun = C(0x2A2A30), gunL = C(0x5A5A66)
    let sig = p.signature
    let badge = sig.map { min(ramp($0, 0.08, 0.16), 1 - ramp($0, 0.44, 0.5)) } ?? 0
    let hero = sig.map { $0 >= 0.52 && $0 < 0.92 } ?? false

    drawLegs(c, Look(leg: C(0x3A3640)), step: p.step)
    burtonBoots(c, step: p.step, C(0x141418), height: 1)
    c.oy += p.breathe
    // The trench coat: its tails over his legs, belted over the bottom of Clawd, the collar turned up at his sides.
    let tails = seatedPose ? 1 : 3
    c.rect(17, 38, 22, tails, coat); c.rect(17, 37 + tails, 22, 1, coatD); c.rect(28, 38, 1, tails, coatD)
    drawBody(c, Look(arm: coat))
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD)
    c.rect(18, 35, 20, 1, coatD); c.rect(27, 35, 3, 1, C(0x5A4428))
    c.pattern(23, 33, ["LL......LL", ".LL....LL.", "..L....L.."], ["L": coatL])
    c.pattern(16, 29, ["CC..................CC", "CCC................CCC", "CCC................CCC", "CCC................CCC"],
              ["C": coat])
    // Stubble along the bottom of his face.
    for x in stride(from: 21, to: 36, by: 2) { c.px(x, 32, clawdShade) }
    // Slicked-back hair: flat over the top of Clawd, a shine along it, swept back at the sides.
    c.pattern(17, 22, [
        "...HHHHHHHHHHHHHHHH...",
        ".HHHhhhhhhhhhhhhhHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHH",
        ".HHH..............HHHH",
        "..H................HH.",
    ], ["H": hair, "h": hairL])
    // The left hand: holding the badge up, or at his side.
    if badge > 0 {
        let by = 33 - Int((badge * 5).rounded())
        burtonLine(c, 17, 34, 20, Double(by + 2), coat, 1.2)
        c.pattern(19, by - 2, [".YYY.", "YYWYY", "YWYWY", "YYWYY", ".YYY."], ["Y": C(0xE0B030), "W": C(0xFFF4C0)])
        if badge > 0.9 && frac(p.t * 3) < 0.5 {
            c.pattern(23, by - 6, ["..W..", "..W..", "WWWWW", "..W..", "..W.."], ["W": C(0xFFFFFF, 0.9)])
        }
    }
    // The pistol: up beside his face in the pose, raised to fire, or held down at his side.
    if hero {
        burtonLine(c, 39.5, 34, 40, 28, coat, 1.2); c.rect(39, 26, 3, 2, clawdOrange)
        c.pattern(40, 16, ["K", "K", "K", "K", "K", "K", "KL", "KK", "KK", "KK"], ["K": gun, "L": gunL])
    } else if p.fire != nil || p.ready || p.gunLift > 0 {
        c.oy += p.gunY
        c.rect(40, 32, 2, 2, clawdOrange)
        c.pattern(41, 30, ["KKKKKKK", "KLKKKKK", "KK.....", "KK....."], ["K": gun, "L": gunL])
    } else {
        c.pattern(39, 36, ["KK", "KL", "K.", "K."], ["K": gun, "L": gunL])
    }
}

// MARK: - The Shrunken-Head Man

/// The Shrunken-Head Man: Clawd as a big body in a khaki safari suit, patch pockets and a brown belt, and on top of it,
/// instead of his own face, a tiny shrunken head, dark and wrinkled, white pinprick eyes, its lips stitched shut,
/// long black hair straggling down; over it, a huge white pith helmet. He doesn't fight. Signature: his tiny head
/// bobs up and down under the helmet and squeaks.
private func drawShrunkenHeadMan(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0xC8B080), suitD = C(0xA08A5A), helmet = C(0xEDE6D2), helmetD = C(0xC8BEA4), head = C(0x5A4232)
    let sig = p.signature
    let bobbing = sig.map { $0 > 0.08 && $0 < 0.9 } ?? false
    let bob = bobbing ? Int((sin(p.t * 14) * 1.5).rounded()) : 0
    let squeak = bobbing && frac(p.t * 2.3) < 0.35

    drawLegs(c, Look(leg: suit), step: p.step)
    burtonBoots(c, step: p.step, C(0x5A3E24), height: 3)
    c.oy += p.breathe
    // The whole of Clawd in the safari suit, no face on it: a collar, patch pockets, a brown belt.
    drawBody(c, Look(body: suit, shade: suitD, arm: suit, eye: nil))
    c.pattern(24, 26, ["DDDDDDDD", ".DD..DD.", "..D..D.."], ["D": suitD])
    c.pattern(20, 29, ["PPPP", "PSSP", "PPPP"], ["P": suitD, "S": suit]); c.pattern(32, 29, ["PPPP", "PSSP", "PPPP"], ["P": suitD, "S": suit])
    c.rect(18, 34, 20, 2, C(0x6A4A2A)); c.rect(27, 34, 2, 2, C(0xC8A040))
    c.px(15, 35, C(0x8A6A4A)); c.px(40, 35, C(0x8A6A4A))
    // The tiny shrunken head on top, hair straggling down behind it, bobbing.
    c.oy += bob
    for x in [24, 25, 31, 32] { c.rect(x, 20, 1, 6 - (x % 2), burtonInk) }
    c.pattern(25, 19, [".HHHHH.", "HHHHHHH", "HWHHHWH", "HHHhHHH", "HKKKKKH", "HSKSKSH", ".HHHHH."],
              ["H": head, "h": C(0x3E2C20), "W": C(0xF4F0E0), "K": C(0x2A1A14), "S": C(0xC8B890)])
    // The huge pith helmet sitting on it: its band, its wide brim.
    c.pattern(18, 11, [
        "......HHHHHHHH......",
        "....HHHHHHHHHHHH....",
        "...HHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHd..",
        "..BBBBBBBBBBBBBBBB..",
        "..HHHHHHHHHHHHHHHd..",
        "HHHHHHHHHHHHHHHHHHHd",
        ".ddddddddddddddddd..",
    ], ["H": helmet, "d": helmetD, "B": C(0x8A7A5A)])
    if squeak {   // little squeak marks beside his head
        c.pattern(34, 19, ["W..", ".W.", "...", "WW.", "...", ".W.", "W.."], ["W": C(0xFFFFFF, 0.9)])
    }
}
