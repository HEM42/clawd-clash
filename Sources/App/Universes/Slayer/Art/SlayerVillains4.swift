import Foundation

// Villains: the Big Bads, one for every season and then some. Clawd in costume like the rest of the cast: hair, suits,
// armour and hides drawn over the blocky body, Clawd's own orange face showing (the Judge's is blue, as his skin is,
// and the First Evil's beast wears a demon's brow over it). The First Evil borrows the Old Master's, the Mayor's,
// Glory's and Adam's heads in its signature, so their bits are drawn by shared helpers here.

let slayerVillains4: [SlayerVillain: Persona] = [
    .judge: Persona(name: "The Judge", weapon: .lightning,
                    magic: Magic(core: C(0xF6F4FF), glow: C(0x6C5CF0), jagged: false, thick: true),
                    armoured: true, bulk: 2, headTop: 14, signature: 3.0, draw: drawJudge),
    .mayorWilclaws: Persona(name: "Mayor Wilclaws", armoured: true, headTop: 21, signature: 3.4, callout: "Gosh!",
                            draw: drawMayorWilclaws),
    .adamm: Persona(name: "Adamm", weapon: .blaster, shot: .energy(core: C(0xEEFFD8), glow: C(0x5CE030)), armoured: true,
                    muzzle: (48, 33), handGun: false, bulk: 1, headTop: 20, signature: 3.2, draw: drawAdamm),
    .professorWalshe: Persona(name: "Professor Walshe", headTop: 20, signature: 3.0, draw: drawProfessorWalshe),
    .glorificlaws: Persona(name: "Glorificlaws", weapon: .saber, bulk: 2, headTop: 15, signature: 3.6,
                           callout: "I'm a god!", draw: drawGlorificlaws),
    .firstEvil: Persona(name: "The First Evil", motion: .hover, canSit: false, bulk: 3, headTop: 12, signature: 4.2,
                        callout: "From beneath you, it devours.", draw: drawFirstEvil),
    .preacherCalebb: Persona(name: "Preacher Calebb", weapon: .saber, armoured: true, headTop: 21, signature: 3.2,
                             draw: drawPreacherCalebb),
    .darkWillow: Persona(name: "Dark Willow", weapon: .lightning, motion: .hover,
                         magic: Magic(core: C(0x2A0810), glow: C(0xD8102C), bolts: 3),
                         headTop: 20, signature: 3.6, callout: "Bored now.", draw: drawDarkWillow),
]

// MARK: - Shared bits

/// Smoothstep: 0→1 eased at both ends.
private func smooth(_ x: Double) -> Double {
    let u = min(1, max(0, x))
    return u * u * (3 - 2 * u)
}

/// A value through a signature `s` 0…1, eased from key to key (`keys` in order of `s`), flat beyond the ends.
private func keyed(_ s: Double, _ keys: [(s: Double, v: Double)]) -> Double {
    guard let first = keys.first, let last = keys.last else { return 0 }
    if s <= first.s { return first.v }
    for (a, b) in zip(keys, keys.dropFirst()) where s < b.s {
        return a.v + (b.v - a.v) * smooth((s - a.s) / (b.s - a.s))
    }
    return last.v
}

/// A punch along `angle`: the sleeve thrown out and a solid fist on the end, with faint fists where a fast swing just
/// was. `ring`: a glint on the knuckles (Caleb's).
private func bigBadFist(_ c: PixelCanvas, angle: Double, trail: [Double], sleeve: Px, skin: Px = clawdOrange,
                        reach len: Double = 7, ring: Px? = nil) {
    for (i, a) in trail.enumerated() {
        let e = slayerReach(slayerHand, a, len)
        c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 3, 3, skin.alpha(0.2 / Double(i + 1)))
    }
    let e = slayerReach(slayerHand, angle, len)
    slayerLine(c, slayerHand.x - 2, slayerHand.y - 0.5, e.x, e.y, sleeve, 1.2)
    let fx = Int(e.x.rounded()) - 1, fy = Int(e.y.rounded()) - 1
    c.rect(fx, fy, 3, 3, skin)
    if let ring { c.px(fx + 1, fy + 1, ring) }
}

// The Mayor's neat side-parted hair, also worn by the First Evil.
private let mayorHair = [
    "....HHHHHHHHHHHH....",
    "..HHHHHHHHHHHHlHHH..",
    ".HHHHHHpHlHHHHHHHHH.",
    ".HHHHHpppHHHHHHHHHH.",
    ".HH.................",
    ".H..................",
]

/// The Mayor's head: the hair at (17, 22) and his big, wide, toothy smile.
private func mayorHead(_ c: PixelCanvas) {
    c.pattern(17, 22, mayorHair, ["H": C(0x4A3426), "l": C(0x6E5038), "p": C(0x2A1C14)])
    // Eyebrows, raised and friendly.
    c.pattern(21, 26, [".BB.", "B..B"], ["B": C(0x4A3426)]); c.pattern(31, 26, [".BB.", "B..B"], ["B": C(0x4A3426)])
    c.pattern(23, 32, ["M........M", ".MWWWWWWM.", "..MMMMMM.."], ["M": C(0x7A2A20), "W": white])
}

// Glory's big blonde curls, also worn by the First Evil.
private let gloryHair = [
    "........hHHhHHhH........",
    ".....hHHHlHHHHlHHHh.....",
    "...hHHlHHHHhHHHHlHHHh...",
    "..HHHHHHhHHlHHHhHHHHHH..",
    ".hHHlHHHHHHHHHHHHHlHHHh.",
    ".HHHHHHHhHHHHHhHHHHHHHH.",
    "hHHHlHHhHHlHHhHHlHHlHHHh",
    "HHHHHHHhH.hHH.hHHHHHHHHH",
    "HhHHHhHHhHHlHHhHHhHHHhHH",
    "HHlH.h.h..h..h..h.h.HlHH",
    "hHHH................HHHh",
    "HHhH................HhHH",
    "HHHl................lHHH",
    "hHHH................HHHh",
    "HdHH................HHdH",
    ".dHd................dHd.",
    ".d.d................d.d.",
]

/// Glory's head: the curls from (16, 17) and red lips.
private func gloryHead(_ c: PixelCanvas) {
    c.pattern(16, 17, gloryHair, ["H": C(0xF0C850), "h": C(0xD0A236), "l": C(0xFFEC9C), "d": C(0xB0842A)])
    c.rect(26, 33, 4, 1, C(0xC8202E))
}

/// The Old Master's head, for the First Evil to wear: pointed ears, the ridged brow, yellow eyes, the fangs.
private func oldMasterHead(_ c: PixelCanvas) {
    let ridge = C(0x9A4A30), eye = C(0xF2D040)
    c.pattern(16, 23, ["O.", "OO", "OO"], ["O": clawdOrange]); c.pattern(38, 23, [".O", "OO", "OO"], ["O": clawdOrange])
    c.pattern(21, 27, ["RRRR......RRRR", ".RR........RR."], ["R": ridge])
    c.rect(22, 29, 2, 2, eye); c.px(23, 30, ink); c.rect(32, 29, 2, 2, eye); c.px(32, 30, ink)
    c.pattern(26, 30, ["R..R", ".RR."], ["R": ridge])
    c.rect(25, 32, 6, 1, C(0x5A2418)); c.px(26, 33, white); c.px(29, 33, white)
}

/// Adam's head: a riveted steel plate over the skull and round the back eye, and stitches across the face.
private func adamHead(_ c: PixelCanvas) {
    let steel = C(0x8A9098), steelD = C(0x5A6068), steelL = C(0xC4CAD2), rivet = C(0x3A3E44), stitch = C(0x4A2A24)
    c.rect(18, 26, 20, 2, steel); c.rect(18, 26, 20, 1, steelL); c.rect(37, 26, 1, 2, steelD)
    for x in stride(from: 20, through: 36, by: 4) { c.px(x, 27, rivet) }
    c.pattern(19, 28, ["SSSSSS", "SS..SS", "SS..SS", "SSSSSS"], ["S": steel])
    c.px(19, 28, steelL); c.px(24, 31, steelD)
    c.rect(22, 29, 2, 2, C(0x6CFF40))                                           // the back eye, a green lens
    c.pattern(26, 28, [".s.", "sss", ".s.", "sss", ".s."], ["s": stitch])          // a stitched seam down the face
    c.rect(27, 33, 5, 1, C(0x5A2A20))
}

// MARK: - The Judge

/// The Judge: the blue-skinned demon from "Surprise", taller than a man and armoured in black plate trimmed with
/// bronze, a crest of curved horns sweeping back off his skull. No weapon forged can stop him, so shots ricochet off.
/// His magic is a thick, steady white ray glowing violet-blue: the touch that burns the humanity out of people.
/// Signature: he raises one blue hand and it crackles, violet sparks jumping between the fingers, before he lowers it.
private func drawJudge(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x4A6AC0), skinD = C(0x30488E), skinL = C(0x7E9CE0)
    let plate = C(0x2C282E), plateD = C(0x17141A), plateL = C(0x4E4654), bronze = C(0xA07A3E), bone = C(0xD8D0BA)
    let sig = p.signature.map { keyed($0, [(0.08, 0), (0.25, 1), (0.8, 1), (0.95, 0)]) } ?? 0
    let raise = sig > 0 ? Int((sig * 7).rounded()) : p.armRaise

    drawLegs(c, Look(leg: plateD), step: p.step)
    slayerBoots(c, step: p.step, plate, height: 3)
    c.oy += p.breathe
    // The crest: a dome of blue skull and a row of curved horns sweeping back off it, bone at the tips.
    let horns: [(Double, Double, Double, Double, Double)] = [(21, 18, 20, 15, 18), (26, 23, 19, 20, 16),
                                                              (31, 29, 18, 26, 15), (35, 34, 19, 32, 17)]
    for (bx, mx, my, tx, ty) in horns {
        slayerLine(c, bx, 24, mx, my, skinD, 1.3)
        slayerLine(c, mx, my, tx, ty, bone, 0.7)
    }
    c.rect(20, 24, 16, 2, skin); c.rect(22, 23, 12, 1, skin); c.rect(23, 23, 8, 1, skinL); c.rect(35, 24, 1, 2, skinD)
    drawBody(c, Look(body: skin, shade: skinD, arm: plate, eye: nil), armRight: raise)
    // The blue face: a heavy ridged brow, small pale eyes deep under it, a grim mouth.
    c.rect(19, 26, 18, 1, skinL)
    c.rect(20, 28, 6, 1, skinD); c.rect(30, 28, 6, 1, skinD)
    c.rect(22, 29, 2, 2, C(0xE8E4FF)); c.px(23, 30, ink); c.rect(32, 29, 2, 2, C(0xE8E4FF)); c.px(32, 30, ink)
    c.rect(24, 32, 8, 1, skinD); c.px(27, 31, skinD); c.px(28, 31, skinD)
    // The armour: black plate on the chest and great shoulder plates, bronze rivets and trim.
    c.rect(18, 33, 20, 5, plate); c.rect(18, 33, 20, 1, bronze); c.rect(37, 34, 1, 4, plateD); c.rect(18, 37, 20, 1, plateD)
    c.rect(26, 34, 4, 3, plateL); c.rect(27, 35, 2, 1, bronze)
    for x in [20, 23, 33, 35] { c.px(x, 35, bronze) }
    c.pattern(13, 30, [".bbbb.", "bPlPPP", "PPPPPP", ".PPPP."], ["P": plate, "l": plateL, "b": bronze])
    if raise < 3 { c.pattern(37, 30, ["bbbb.", "PPlPP", "PPPPP", "PPPP."], ["P": plate, "l": plateL, "b": bronze]) }
    // Plated skirt over the tops of the legs.
    c.rect(18, 38, 20, seatedPose ? 1 : 2, plateD); for x in [21, 27, 33] { c.px(x, 38, plateL) }
    // The blue hand on the arm's end; held high and open for his signature.
    if raise >= 3 {
        c.rect(38, 34 - raise, 3, raise, plate); c.rect(37, 30, 4, 4, plate); c.rect(37, 30, 4, 1, bronze)
        c.pattern(38, 29 - raise, ["s.s.s", "sssss", ".sss.", ".sss."], ["s": skin])
    } else {
        c.rect(39, 34 - raise, 3, 2, skin); c.px(41, 33 - raise, skinL)
    }
    if sig > 0 {
        // Violet crackle jumping between the raised fingers.
        let i = Int(p.t * 22)
        for k in 0..<4 {
            let x = 37 + Int(noise(i + k * 3) * 7), y = 26 - raise + Int(noise(i * 5 + k) * 6)
            c.px(x, y, (k % 2 == 0 ? C(0xF0ECFF) : C(0x8A7CFF)).alpha(sig))
        }
        c.glowLine(40.5, 30.5 - Double(raise), 40.5, 30.5 - Double(raise), core: C(0xF6F4FF, 0.2), glow: C(0x6C5CF0),
                   coreR: 0.5, glowR: 3.2, strength: 0.5 * sig * (0.75 + 0.25 * sin(p.t * 30)))
    }
}

// MARK: - Mayor Wilclaws

/// Mayor Richard Wilclaws: a beaming small-town mayor in a grey suit, white shirt and maroon tie, his hair neatly
/// side-parted, with the widest friendliest smile in Sunnydale. He doesn't fight; after the Ascension ritual he's
/// invulnerable, so shots bounce off. Signature: out comes a packet of wet wipes and he cleans his hands, fussily,
/// finger by finger ("Gosh!"), and tucks it away.
private func drawMayorWilclaws(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x70727C), suitD = C(0x4C4E58), suitL = C(0x9496A0), shirt = C(0xF2F2EE), tie = C(0x7E2430)
    let wipeK = p.signature.map { $0 > 0.1 && $0 < 0.88 ? ($0 - 0.1) / 0.78 : -1 } ?? -1

    drawLegs(c, Look(leg: suitD), step: p.step)
    slayerBoots(c, step: p.step, C(0x1A1A1E), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit), armRight: wipeK >= 0 ? 1 : 0)
    // The suit jacket, a white shirt and the tie in the V of the lapels.
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(24, 33, ["LSSSSSSL", ".LSTTSL.", "..LTTL..", "...TT...", "...TT..."], ["S": shirt, "T": tie, "L": suitL])
    c.px(20, 35, suitL); c.rect(33, 35, 3, 1, suitD)                           // a breast pocket
    mayorHead(c)

    guard wipeK >= 0 else { return }
    // Both hands together in front of him, the wipe between them, rubbing round and round.
    let rub = Int((sin(wipeK * 26) * 1.3).rounded())
    c.rect(38, 32, 4, 3, suit)
    c.rect(41, 32 + rub, 3, 3, clawdOrange)
    c.rect(42, 31 - rub, 3, 3, white); c.px(44, 31 - rub, C(0xD8E4EC)); c.px(42, 33 - rub, C(0xD8E4EC))
    c.rect(43, 33, 3, 2, clawdOrange)
    if wipeK < 0.15 || wipeK > 0.85 {
        // The little packet, coming out of his pocket and going back.
        c.rect(44, 35, 4, 2, C(0x6EB4E8)); c.px(45, 35, white)
    }
    // A sparkle: clean as a whistle.
    if Int(p.t * 6) % 3 == 0 { c.px(47, 30, white.alpha(0.8)); c.px(46, 29, white.alpha(0.35)); c.px(48, 29, white.alpha(0.35)) }
}

// MARK: - Adamm

/// Adamm: Professor Walshe's creation, a patchwork of demon, human and machine. Grey-green demon hide stitched to
/// Clawd's orange and bolted to steel plates, a riveted plate over the skull with a green lens for the back eye, and
/// a gun built into his right arm that fires bright uranium-green bolts. Armoured, so shots ricochet. Signature: the
/// plates of his chest swing open on the glowing core that powers him, then close.
private func drawAdamm(_ c: PixelCanvas, _ p: Pose) {
    let hide = C(0x6E7A5C), hideD = C(0x525C44), steel = C(0x8A9098), steelD = C(0x5A6068), steelL = C(0xC4CAD2)
    let stitch = C(0x3A2622), core = C(0x8CFF50)
    let open = p.signature.map { keyed($0, [(0.1, 0), (0.3, 1), (0.75, 1), (0.92, 0)]) } ?? 0

    drawLegs(c, Look(leg: hide), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {                         // steel knee plates
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, lifted ? 39 : 40, 2, 1, steel)
        }
    }
    slayerBoots(c, step: p.step, steelD, height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: steel, eye: ink))
    // Patches: grey-green hide on the shoulder and the chest, stitched on.
    c.rect(18, 32, 6, 6, hide); c.rect(18, 37, 6, 1, hideD)
    c.rect(32, 33, 6, 5, steel); c.rect(32, 33, 6, 1, steelL); c.rect(37, 33, 1, 5, steelD)
    for y in stride(from: 32, through: 37, by: 2) { c.px(24, y, stitch) }
    for x in stride(from: 19, through: 23, by: 2) { c.px(x, 31, stitch) }
    c.px(33, 34, steelD); c.px(36, 36, steelD)
    // The chest panel, its two doors parting on the core.
    let gap = Int((open * 3).rounded())
    if open > 0 {
        let pulse = 0.75 + 0.25 * sin(p.t * 9)
        c.rect(26, 33, 6, 5, C(0x1A2A12))
        c.rect(27, 34, 4, 3, core.alpha(pulse)); c.rect(28, 35, 2, 1, C(0xF0FFE0))
        c.glowLine(28.5, 35, 28.5, 35, core: C(0xF0FFE0, 0.3), glow: C(0x5CE030), coreR: 0.5, glowR: 2 + 2.5 * open,
                   strength: 0.5 * open * pulse)
    }
    c.rect(26 - gap, 33, 3, 5, steel); c.rect(29 + gap, 33, 3, 5, steel)
    c.px(26 - gap, 33, steelL); c.px(31 + gap, 37, steelD); c.px(27 - gap, 35, steelD); c.px(30 + gap, 35, steelD)
    // A demon's horned ridge over the skull plate.
    c.pattern(22, 23, ["..h....h....h..", ".hh...hh...hh..", "hhhhhhhhhhhhhh."], ["h": hideD])
    adamHead(c)
    // The arm gun, built in: a riveted barrel with a green glow at the muzzle.
    c.oy += p.gunY
    c.rect(38, 32, 5, 4, steel); c.rect(38, 32, 5, 1, steelL); c.rect(38, 35, 5, 1, steelD)
    c.rect(43, 32, 4, 3, steelD); c.rect(43, 32, 4, 1, steel)
    c.px(40, 34, C(0x3A3E44))
    c.px(47, 33, core)
    c.oy -= p.gunY
}

// MARK: - Professor Walshe

/// Professor Maggie Walshe: the psychology lecturer who runs the Initiative, in a long white lab coat over a dark
/// blouse, her auburn hair in a short neat bob, a clipboard always in hand. She doesn't fight. Signature: she taps
/// notes on her clipboard with her pen, ticking off line after line.
private func drawProfessorWalshe(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0xEEF0F2), coatD = C(0xC2C6CE), blouse = C(0x3E4A66), hair = C(0x8A4E2E), hairL = C(0xB06E44)
    let hairD = C(0x63361E)
    let noteK = p.signature.map { $0 > 0.08 && $0 < 0.9 ? ($0 - 0.08) / 0.82 : -1 } ?? -1

    drawLegs(c, Look(leg: C(0x2E3040)), step: p.step)
    slayerBoots(c, step: p.step, C(0x1A1A20), height: 1)
    // The lab coat's skirts, hanging down to the knees: the legs still show beneath.
    c.rect(17, 37, 22, seatedPose ? 2 : 4, coat); c.rect(17, seatedPose ? 38 : 40, 22, 1, coatD); c.px(27, 39, coatD)
    c.oy += p.breathe
    drawBody(c, Look(arm: coat))
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD)
    c.pattern(24, 33, ["dBBBBBBd", ".dBBBBd.", "..dBBd..", "...dd..."], ["B": blouse, "d": coatD])
    c.rect(33, 35, 3, 1, coatD); c.px(34, 34, C(0x3A6AD0)); c.px(35, 34, C(0xC03030))       // a pocket of pens
    // The bob: short and neat, a side fringe.
    c.pattern(16, 20, [
        "......HHHHHHHHHHH.......",
        "....HHHHlHHHHHHHHHH.....",
        "...HHHlHHHHHHHHHHHHH....",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHdHH..",
        ".HHHHHHHHHHHHHHHdd.HHH..",
        ".HHH...........d....HHH.",
        ".HHH.................HH.",
        ".HHl.................HH.",
        ".HHH.................HH.",
        ".dHH.................Hd.",
        "..dd.................dd.",
    ], ["H": hair, "l": hairL, "d": hairD])
    c.rect(26, 33, 4, 1, C(0x8A3A2E))                                          // a thin, cool smile
    // The clipboard, held up in front of her.
    let board = C(0x9A6A3A), boardD = C(0x6E4824), paper = C(0xF6F4EA), clip = C(0xB0B6C0)
    c.rect(41, 28, 6, 8, board); c.rect(46, 28, 1, 8, boardD)
    c.rect(42, 29, 4, 6, paper); c.rect(42, 27, 4, 1, clip); c.rect(43, 26, 2, 1, clip)
    let lines = noteK >= 0 ? Int(noteK * 4.99) : 3
    for k in 0..<3 { c.rect(42, 30 + k * 2, k < lines ? 3 : 1, 1, C(0x5A6070)) }
    if noteK >= 0 && lines > 3 { c.px(45, 34, C(0x2A8A40)) }                   // and a tick
    if noteK >= 0 {
        // The pen, tapping down the page.
        let tap = Int(p.t * 7) % 2
        let row = 30 + min(2, lines) * 2
        c.rect(45, row - 4 - tap, 1, 4, C(0x2A2A30)); c.px(45, row - tap, C(0xC0C4CC))
        c.rect(46, row - 2 - tap, 2, 2, clawdOrange)
    }
    c.rect(38, 33, 4, 3, coat); c.rect(40, 33, 2, 2, clawdOrange)            // her hand on the board
}

// MARK: - Glorificlaws

/// Glorificlaws: Glory, the hell-god in a mortal body, all big blonde curls, a short red dress, red lips and red
/// heels. She fights with her fists, and hits like a god. Signature: she turns a foot to admire her shoes, and for a
/// moment flickers into Ben, the young doctor she shares a body with (short brown hair, blue scrubs), then back
/// ("I'm a god!").
private func drawGlorificlaws(_ c: PixelCanvas, _ p: Pose) {
    let s = p.melee == nil ? p.signature : nil
    // Ben for two blinks in the middle of the move.
    if let s, (0.52..<0.56).contains(s) || (0.6..<0.63).contains(s) { drawBen(c, p); return }
    let dress = C(0xC8202E), dressD = C(0x8E1420), dressL = C(0xE8505A), shoe = C(0xB01828)
    let admire = s.map { keyed($0, [(0.06, 0), (0.18, 1), (0.44, 1), (0.5, 0)]) } ?? 0

    if admire > 0, !seatedPose {
        // The front foot turned out and lifted, the red heel catching the light.
        let up = Int((admire * 2).rounded())
        for lx in [19, 23, 31] { c.rect(lx, 36, 2, 8, clawdOrange); c.rect(lx, 43, 2, 1, shoe) }
        c.rect(35, 36, 2, 7 - up, clawdOrange)
        c.rect(35, 42 - up, 3, 1, shoe); c.px(37, 41 - up, shoe)
        if Int(p.t * 8) % 2 == 0 { c.px(38, 39 - up, white.alpha(0.8)) }
    } else {
        drawLegs(c, Look(), step: p.step)
        slayerBoots(c, step: p.step, shoe, height: 1)
    }
    // The skirt of the red dress.
    c.rect(17, 38, 22, seatedPose ? 1 : 2, dress); c.rect(17, seatedPose ? 38 : 39, 22, 1, dressD)
    c.oy += p.breathe
    drawBody(c, Look(eye: admire > 0.5 ? nil : ink))
    if admire > 0.5 {
        c.rect(22, 30, 2, 2, ink); c.rect(32, 30, 2, 2, ink)                   // looking down at her feet
    }
    // The dress: thin straps, a fitted bodice.
    c.rect(18, 34, 20, 4, dress); c.rect(37, 34, 1, 4, dressD); c.rect(18, 37, 20, 1, dressD)
    c.rect(19, 34, 18, 1, dressL); c.px(22, 33, dress); c.px(33, 33, dress)
    gloryHead(c)
    if let a = p.melee {
        bigBadFist(c, angle: a, trail: p.trail, sleeve: clawdOrange)
    }
}

/// Ben, for the frame Glory flickers into him: short brown hair and blue hospital scrubs.
private func drawBen(_ c: PixelCanvas, _ p: Pose) {
    let scrubs = C(0x5A8ACC), scrubsD = C(0x3E6AA6), hair = C(0x5A3A24), hairL = C(0x7A5234)
    drawLegs(c, Look(leg: scrubsD), step: p.step)
    slayerBoots(c, step: p.step, C(0xE8E8EC), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: scrubs))
    c.rect(18, 34, 20, 4, scrubs); c.rect(37, 34, 1, 4, scrubsD); c.rect(18, 37, 20, 1, scrubsD)
    c.pattern(25, 34, ["V....V", ".V..V.", "..VV.."], ["V": scrubsD])
    c.pattern(17, 23, [
        "....HHHHHHHHHHHH....",
        "..HHHHlHHHHHlHHHHH..",
        ".HHHHHHHHHHHHHHHHHH.",
        ".HH..............HH.",
    ], ["H": hair, "l": hairL])
    // A shimmer: the god pushing through.
    for k in 0..<3 { c.px(20 + k * 7, 25 + (Int(p.t * 30) + k) % 8, C(0xFFE89A, 0.6)) }
}

// MARK: - The First Evil

/// The First Evil in its true form: a huge black horned beast, hunched under a mantle of black hide, great curved
/// horns, a demon's brow over Clawd's face, burning red eyes and fangs, claws on the ends of its long arms. It never
/// quite touches the ground. Signature: as in "Lessons", its face flickers through the Big Bads before it, the Old
/// Master, the Mayor, Glory and Adam, each a moment, and back to itself ("From beneath you, it devours."). Its habit,
/// now and then outside the signature (`slayerFirstEvilGuise`): it becomes one of them whole for a few seconds, their
/// own self drawn by their own art, flickering in and out of it, still floating, still trailing its dark haze.
private func drawFirstEvil(_ c: PixelCanvas, _ p: Pose) {
    guard let guise = slayerFirstEvilGuise(p) else { return drawFirstEvilSelf(c, p) }
    // In and out with a flicker: the beast showing through for a frame here and there at either end.
    let edge = guise.k < 0.14 || guise.k > 0.86
    if edge && noise(Int(p.t * 18) * 7 + 3) < 0.5 { return drawFirstEvilSelf(c, p) }
    let (ox, oy, baseY) = (c.ox, c.oy, c.baseY)
    guise.who.persona.draw(c, p)
    c.ox = ox; c.oy = oy; c.baseY = baseY
    // The tells: a faint dark haze under the borrowed feet, and a red-orange shimmer at its edges as it settles.
    for k in 0..<5 {
        let x = 18 + k * 4 + Int(noise(Int(p.lt * 4) + k) * 3)
        c.px(x, 45 + k % 2, C(0x3A1020, 0.2))
    }
    if edge || Int(p.t * 3) % 4 == 0 {
        for k in 0..<4 { c.px(18 + k * 6, 22 + (Int(p.t * 24) + k * 5) % 16, C(0xFF6A3A, 0.45)) }
    }
}

/// The First Evil as itself (or, in its signature, wearing a borrowed face).
private func drawFirstEvilSelf(_ c: PixelCanvas, _ p: Pose) {
    let hide = C(0x18141C), hideD = C(0x0A080C), hideL = C(0x34303C), horn = C(0x2E2830), hornL = C(0x5E5462)
    let claw = C(0xC8BEB0), eye = C(0xFF3A1E)
    // Which past face it wears, if any: four in turn, with a flicker of its own between them.
    var face = -1
    if let s = p.signature, s > 0.1, s < 0.86 {
        let u = (s - 0.1) / 0.76 * 4
        let k = Int(u), f = u - Double(k)
        let flick = f < 0.12 && Int(p.t * 30) % 2 == 0
        face = flick ? -1 : min(3, k)
    }

    // The four legs, black and furred, with pale claws.
    drawLegs(c, Look(leg: hide), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.px(lx + 1, lifted ? 42 : 43, claw); c.px(lx, 37, hideL)
        }
    }
    // A dark haze under it as it floats: faint, so the outline still closes under the feet.
    for k in 0..<5 {
        let x = 18 + k * 4 + Int(noise(Int(p.lt * 4) + k) * 3)
        c.px(x, 45 + k % 2, C(0x3A1020, 0.2))
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: hide, eye: nil))
    // The mantle of hide over its hunched shoulders and back, ragged at the edge.
    c.pattern(12, 30, [
        "....HHHHHH..........................",
        "..HHHHHHHHl.........................",
        ".HHHHHHHHHH.........................",
        "HHHHHHHHHHH.........................",
        "HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH...",
        ".HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH.",
        ".HdHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHdH.",
        "..H.dHH.HHd.HHHdHHH.HHd.HHHHd.HH.d..",
        "...........H.....H.....H....H.......",
    ], ["H": hide, "l": hideL, "d": hideD])
    c.rect(18, 34, 20, 1, hideL)

    switch face {
    case 0: oldMasterHead(c)
    case 1: c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink); mayorHead(c)
    case 2: c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink); gloryHead(c)
    case 3: c.rect(32, 29, 2, 3, ink); adamHead(c)
    default:
        // The horns: thick at the skull, curving up and out, paler at the tips.
        for side in [-1.0, 1.0] {
            let bx = 28 + side * 8
            let pts: [(Double, Double)] = [(bx, 26), (bx + side * 3, 21), (bx + side * 4, 16), (bx + side * 2, 12)]
            let r: [Double] = [1.8, 1.4, 0.9]
            for i in 0..<3 {
                slayerLine(c, pts[i].0, pts[i].1, pts[i + 1].0, pts[i + 1].1, i == 2 ? hornL : horn, r[i])
            }
        }
        c.rect(17, 25, 22, 1, hideD); c.rect(19, 24, 18, 1, hideD)
        // The demon's brow, the burning eyes, the snout and the fangs.
        c.pattern(19, 26, ["BB..............BB", ".BBBB........BBBB.", "...BBB......BBB...",
                           "........BB........"], ["B": hide])
        c.rect(22, 29, 3, 2, eye); c.px(22, 29, C(0xFFC060)); c.rect(31, 29, 3, 2, eye); c.px(33, 29, C(0xFFC060))
        c.glowLine(23, 30, 33, 30, core: C(0xFF5A2A, 0.15), glow: C(0xFF2A1A), coreR: 0.4, glowR: 2.2,
                   strength: 0.25 + 0.1 * sin(p.lt * 3))
        c.rect(25, 31, 6, 1, hideD)
        c.rect(24, 32, 8, 2, C(0x2A0A0E)); c.px(25, 33, white); c.px(30, 33, white); c.px(25, 32, white); c.px(30, 32, white)
    }
    if face >= 0 {
        // The borrowed face shimmering at its edges.
        for k in 0..<4 { c.px(19 + k * 5, 26 + (Int(p.t * 24) + k * 3) % 8, C(0xFF6A3A, 0.5)) }
    }
    // The clawed hand.
    c.rect(39, 34, 2, 2, hideL); c.px(41, 36, claw); c.px(40, 36, claw)
}

// MARK: - Preacher Calebb

/// Preacher Calebb: the First's right hand, a soft-spoken preacher in a black suit and black shirt with a white
/// collar tab, a flat-brimmed black hat and a thin, unkind smile. He fights with his fists, a gold ring on one
/// finger, and he's as strong as he is hard to hurt (armoured). Signature: he rolls up his sleeve, slowly, then
/// cracks his knuckles.
private func drawPreacherCalebb(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x1E1C22), suitD = C(0x0E0D10), suitL = C(0x3C3842), collar = C(0xF4F4F0), gold = C(0xE8B840)
    let s = p.melee == nil ? p.signature : nil
    let roll = s.map { keyed($0, [(0.08, 0), (0.45, 1), (0.85, 1), (0.95, 0)]) } ?? 0
    let out = s.map { keyed($0, [(0.04, 0), (0.12, 1), (0.88, 1), (0.96, 0)]) } ?? 0

    drawLegs(c, Look(leg: suit), step: p.step)
    slayerBoots(c, step: p.step, C(0x0A0A0C), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit, eye: nil))
    // Narrowed eyes under a hard brow, and the thin smile.
    c.rect(22, 30, 2, 2, ink); c.rect(32, 30, 2, 2, ink)
    c.rect(21, 29, 4, 1, C(0x8A3A22)); c.rect(31, 29, 4, 1, C(0x8A3A22))
    c.pattern(26, 32, [".....M", "MMMMM."], ["M": C(0x6A2418)])
    // The black suit and shirt, the white collar tab at the throat.
    c.rect(18, 34, 20, 4, suit); c.rect(37, 34, 1, 4, suitD); c.rect(18, 37, 20, 1, suitD)
    c.rect(24, 34, 1, 3, suitL); c.rect(31, 34, 1, 3, suitL)
    c.rect(25, 34, 6, 1, collar)
    // The flat-brimmed preacher's hat.
    c.pattern(14, 21, [
        "........HHHHHHHHHHHH........",
        "........HHHHHHHHHHHH........",
        "........bbbbbbbbbbbb........",
        "HHHHHHHHHHHHHHHHHHHHHHHHHHHH",
        ".dddddddddddddddddddddddddd.",
    ], ["H": suit, "b": suitL, "d": suitD])
    c.rect(23, 21, 1, 2, suitL)

    if out > 0 {
        // The arm held out in front, the sleeve rolled back off the forearm, the cuff turning over.
        let len = Int((out * 4).rounded())
        let back = Int((roll * 4).rounded())
        c.rect(38, 33, 2 + len, 3, suit)
        if back > 0 { c.rect(44 - back, 33, back, 3, clawdOrange) }
        c.rect(max(38, 43 - back), 33, 1, 3, collar)
        c.rect(40 + len, 33, 3, 3, clawdOrange); c.px(41 + len, 34, gold)
        if roll > 0.99, let s, s > 0.6, s < 0.85, Int(s * 40) % 3 == 0 {
            c.px(44 + len, 32, white.alpha(0.7))                                 // a crack of the knuckles
        }
        return
    }
    if let a = p.melee {
        bigBadFist(c, angle: a, trail: p.trail, sleeve: suit, ring: gold)
    } else {
        c.rect(39, 35, 2, 2, clawdOrange); c.px(40, 35, gold)
    }
}

// MARK: - Dark Willow

/// Dark Willow: Willow after Tara's death, gone over to black magic. The same long straight hair, parted in the
/// middle, gone black; black eyes; a few bold black veins spreading from them; black clothes; and she floats a
/// little off the floor. Her magic is jagged lightning, red-black bolts. Signature: from "Villains": an open book
/// in her hands, and its letters lift off the page and stream up into her arms ("Bored now.").
private func drawDarkWillow(_ c: PixelCanvas, _ p: Pose) {
    let top = C(0x1E1A22), topD = C(0x0E0C12), topL = C(0x3A3442)
    let hair = C(0x16121A), hairL = C(0x3A3048), hairD = C(0x08060A), part = C(0x2A2034)
    let vein = C(0x1E0418), veinHot = C(0x9A0A26)
    let bookK = p.signature.map { $0 > 0.06 && $0 < 0.92 ? ($0 - 0.06) / 0.86 : -1 } ?? -1

    drawLegs(c, Look(leg: C(0x1A181E)), step: p.step)
    slayerBoots(c, step: p.step, C(0x0A080C), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: top, eye: nil), armRight: bookK >= 0 ? 1 : p.armRaise)
    // Black eyes, a red glint in them, and the veins: few and bold.
    c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink); c.px(23, 29, C(0x8A0A24)); c.px(33, 29, C(0x8A0A24))
    let hot = bookK >= 0 && Int(p.t * 5) % 2 == 0
    let v = hot ? veinHot : vein
    c.pattern(20, 27, [
        "v..............v",
        ".v............v.",
        "................",
        "................",
        "................",
        ".v.v........v.v.",
        "v..v........v..v",
    ], ["v": v])
    // The long black top, high at the neck.
    c.rect(18, 34, 20, 4, top); c.rect(37, 34, 1, 4, topD); c.rect(18, 37, 20, 1, topD); c.rect(25, 34, 6, 1, topL)
    // The same hair as Willow's, gone black.
    c.pattern(16, 20, [
        ".....HHHHHHpHHHHHH......",
        "....HHHHHHHpHHHHHHH.....",
        "...HHHlHHHHpHHHHHlHH....",
        "..HHHHHHHHHpHHHHHHHHH...",
        "..HHHHHHHHHpHHHHHHHHHH..",
        ".HHHHHHHHHHpHHHHHHHHHHH.",
        ".HHHHHHHH......HHHHHHHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHl................HHH.",
        ".HHH................lHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHd................dHH.",
        ".HHd................dHH.",
        ".dHd................dHd.",
        ".dd..................dd.",
    ], ["H": hair, "l": hairL, "d": hairD, "p": part])

    guard bookK >= 0 else {
        c.rect(39, 34 - p.armRaise, 2, 2, clawdOrange); c.px(39, 34 - p.armRaise, vein)
        return
    }
    // The open book held out in front of her.
    let cover = C(0x5A1A1E), page = C(0xEAE0C8), text = C(0x3A3030)
    c.pattern(39, 32, [
        "PPPP.PPPP",
        "PPPPsPPPP",
        "PPPPsPPPP",
        "CCCCCCCCC",
        ".CCCCCCC.",
    ], ["P": page, "s": C(0x3A1012), "C": cover])
    let left = bookK > 0.85 ? 1 : 3 - Int(bookK * 3)                             // the text going as the letters leave
    for k in 0..<left { c.rect(40 + k % 2, 32 + k, 2, 1, text); c.rect(45 + k % 2, 32 + k, 2, 1, text) }
    c.rect(38, 34, 2, 2, clawdOrange); c.px(38, 34, vein)
    // Letters lifting off the page and arcing back into her arms.
    guard bookK < 0.95 else { return }
    for k in 0..<5 {
        let f = frac(p.t * 0.8 + Double(k) / 5)
        let x = 44 - f * 9, y = 33 - sin(f * .pi) * 9 - f * 1
        let col = (k % 2 == 0 ? C(0x14080A) : C(0x2A0810)).alpha(f > 0.85 ? (1 - f) / 0.15 * 0.2 : 1)
        let xi = Int(x.rounded()), yi = Int(y.rounded())
        if k % 3 == 0 { c.rect(xi, yi, 2, 1, col); c.px(xi, yi + 1, col) }
        else if k % 3 == 1 { c.px(xi, yi, col); c.px(xi + 1, yi + 1, col); c.px(xi, yi + 1, col) }
        else { c.rect(xi, yi, 1, 2, col); c.px(xi + 1, yi, col) }
        c.px(xi - 1, yi, C(0xD8102C, 0.2))
    }
}
