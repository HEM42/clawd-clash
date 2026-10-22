import Foundation

// Villains: the Big Bads, one for every season and then some. Clawd in costume like the rest of the cast: hair, suits,
// armour and hides drawn over the blocky body, Clawd's own orange face showing (the Judge's is blue, as his skin is,
// and the First Evil's beast wears a demon's brow over it). The First Evil borrows the Old Master's, the Mayor's,
// Glory's and Adam's heads in its signature, so their bits are drawn by shared helpers here.

let slayerVillains4: [SlayerVillain: Persona] = [
    .judge: Persona(name: "The Judge", weapon: .lightning,
                    magic: Magic(core: C(0xF6F4FF), glow: C(0x6C5CF0), jagged: false, thick: true),
                    armoured: true, bulk: 2, headTop: 14, signature: 3.0, draw: drawJudge),
    .mayorWilclaws: Persona(name: "Mayor Wilclawds", armoured: true, headTop: 21, signature: 3.4, callout: "Gosh!",
                            draw: drawMayorWilclaws),
    .adamm: Persona(name: "Adamm", weapon: .blaster, shot: .energy(core: C(0xEEFFD8), glow: C(0x5CE030)), armoured: true,
                    muzzle: (48, 33), handGun: false, bulk: 1, headTop: 20, signature: 3.2, draw: drawAdamm),
    .professorWalshe: Persona(name: "Professor Walshe", headTop: 20, signature: 3.0, draw: drawProfessorWalshe),
    .glorificlaws: Persona(name: "Glorificlawds", weapon: .saber, bulk: 2, headTop: 15, signature: 3.6,
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
    "..HHlllHHHHHHHHHHH..",
    ".HHHHHHpHllHHHHHHHH.",
    ".HHHHHpppHHHHHHHHHH.",
    ".HH.................",
    ".H..................",
]

/// The Mayor's head: the hair at (17, 22) and his big, wide, toothy smile.
private func mayorHead(_ c: PixelCanvas) {
    c.pattern(17, 22, mayorHair, ["H": C(0x4A3426), "l": C(0x6E5038), "p": C(0x2A1C14)])
    // Eyebrows, high, arched and friendly: bold dark arcs.
    let brow = [".BBB.", "B...B"]
    c.pattern(20, 26, brow, ["B": C(0x2E2018)]); c.pattern(31, 26, brow, ["B": C(0x2E2018)])
    c.pattern(23, 32, ["M........M", ".MWWWWWWM.", "..MMMMMM.."], ["M": C(0x7A2A20), "W": white])
}

// Glory's big blonde curls, also worn by the First Evil.
// Lit from the front-left, a few big curls marked by their shadows rather than a speckle of light and dark.
private let gloryHair = [
    "........HHlllHHH........",
    ".....HHlllHHHHHHHh......",
    "...HHllHHHHHHHHHHHHh....",
    "..HllHHHHhHHHHHhHHHHh...",
    ".HllHHHhhHHHHHhhHHHHhh..",
    ".HlHHHhhHHHHHhhHHHHhhHh.",
    "HHHHHhhHHHHHhhHHHHhhHHhh",
    "HlHHHHHHH.HHH.HHHHHHHHHh",
    "HlHHhhHHhhHHhhHHhhHHHhHh",
    "HHHH.h.h..h..h..h.h.HHhh",
    "HlHH................HHhh",
    "HlHh................HHHh",
    "HHHH................hHHh",
    "HHhH................HHhh",
    "HHHh................HhHd",
    ".hHd................dHh.",
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
    for x in [21, 29, 35] { c.px(x, 27, rivet) }
    c.pattern(19, 28, ["SSSSSS", "SS..SS", "SS..SS", "SSSSSS"], ["S": steel])
    c.px(19, 28, steelL); c.px(24, 31, steelD)
    c.rect(22, 29, 2, 2, C(0x6CFF40))                                           // the back eye, a green lens
    c.rect(27, 28, 1, 5, stitch); c.rect(26, 29, 3, 1, stitch); c.rect(26, 31, 3, 1, stitch)  // a stitched seam
    c.rect(29, 33, 4, 1, C(0x5A2A20))
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
    // The crest: a dome of blue skull and two great ridged horns of bone, rising off the brow and sweeping back
    // like an ibex's, thick at the root and tapering, dark rings round them; the far one smaller, behind.
    let boneD = C(0x8E8470)
    let horns: [(pts: [(Double, Double)], r: Double)] = [([(22, 24), (19.5, 20.5), (16, 19), (12.5, 19.5)], 0.85),
                                                          ([(31, 24), (29, 18), (24.5, 14.5), (19.5, 14.5)], 1.05)]
    for h in horns {
        let rs = [h.r + 0.6, h.r + 0.2, h.r - 0.3]
        for i in 0..<3 {
            slayerLine(c, h.pts[i].0, h.pts[i].1, h.pts[i + 1].0, h.pts[i + 1].1, i == 0 ? boneD : bone, rs[i])
        }
        // The rings: a dark notch across the horn at each joint.
        for i in 1..<3 { c.px(Int(h.pts[i].0.rounded()), Int(h.pts[i].1.rounded()), boneD) }
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

// MARK: - Mayor Wilclawds

/// Mayor Richard Wilclawds: a beaming small-town mayor in a grey suit, white shirt and maroon tie, his hair neatly
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
    c.rect(18, 34, 1, 3, suitL); c.rect(22, 35, 1, 2, suitD)                   // lit down the near side, a fold
    mayorHead(c)

    guard wipeK >= 0 else { return }
    // Both hands held up in front of him, the big white wipe between them, rubbing up and down in turn.
    let rub = Int((sin(wipeK * 26) * 1.5).rounded())
    let crease = C(0xB8C8D4)
    c.rect(38, 31, 3, 4, suit); c.px(40, 34, shirt)                              // the sleeve and its cuff
    c.rect(41, 30 + rub, 3, 4, clawdOrange)                                     // the near hand
    c.rect(44, 29, 4, 6, white); c.rect(44, 31, 4, 1, crease); c.px(47, 29, crease); c.px(44, 34, crease)
    c.rect(47, 30 - rub, 3, 4, clawdOrange); c.px(49, 33 - rub, C(0xB05A3C))     // the far hand, over the other side
    if wipeK < 0.15 || wipeK > 0.85 {
        // The little packet, coming out of his pocket and going back.
        c.rect(43, 35, 5, 3, C(0x6EB4E8)); c.rect(44, 36, 3, 1, white)
    }
    // A sparkle: clean as a whistle.
    if Int(p.t * 6) % 3 == 0 {
        c.px(51, 28, white)
        for (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1)] { c.px(51 + dx, 28 + dy, white.alpha(0.22)) }
    }
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
    // Patches: grey-green hide on the shoulder and the chest, a plain steel plate on the other side, a single
    // stitched seam where the hide meets Clawd.
    c.rect(18, 32, 6, 6, hide); c.rect(18, 37, 6, 1, hideD)
    c.rect(32, 33, 6, 5, steel); c.rect(32, 33, 6, 1, steelL); c.rect(37, 33, 1, 5, steelD)
    c.rect(24, 32, 1, 6, stitch)
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
    // A demon's ridge over the skull plate: three blunt horns on a band of hide.
    c.pattern(22, 23, [".h.....h.....h.", "hh....hh....hh.", "hhhhhhhhhhhhhh."], ["h": hideD])
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
    // The lab coat's skirts, split at the front: short over the legs, so all four show at full length, and long at
    // the sides, its edges hanging down past the knees either side of them.
    c.rect(17, 37, 22, 2, coat); c.rect(17, 38, 22, 1, coatD); c.rect(27, 37, 1, 2, coatD)
    if !seatedPose { c.rect(17, 39, 2, 3, coat); c.rect(37, 39, 2, 3, coatD); c.px(18, 41, coatD) }
    c.oy += p.breathe
    drawBody(c, Look(arm: coat))
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD)
    c.pattern(24, 33, ["dBBBBBBd", ".dBBBBd.", "..dBBd..", "...dd..."], ["B": blouse, "d": coatD])
    c.rect(33, 35, 3, 1, coatD); c.px(34, 34, C(0x3A6AD0)); c.px(35, 34, C(0xC03030))       // a pocket of pens
    c.rect(21, 35, 1, 2, coatD); c.px(31, 36, coatD)                                          // folds
    // The bob: short and neat, a side fringe.
    c.pattern(16, 20, [
        "......HHHHHHHHHHH.......",
        "....HHHHlllHHHHHHHH.....",
        "...HHlHHHHHHHHHHHHHH....",
        "..HHHHHHHHHHHHHHHHHHHH..",
        "..HHHHHHHHHHHHHHHHHdHH..",
        ".HHHHHHHHHHHHHHHdd.HHH..",
        ".HHH...........d....HHH.",
        ".HHl.................HH.",
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
    let lines = noteK >= 0 ? Int(noteK * 3.99) : 3
    for k in 0..<3 { c.rect(42, 30 + k * 2, k < lines ? 3 : 1, 1, C(0x5A6070)) }
    if noteK >= 0 {
        // A green tick by each line she's done with.
        for k in 0..<min(3, lines) { c.px(45, 30 + k * 2, C(0x2AA048)); c.px(44, 29 + k * 2, C(0x2AA048)) }
        // The pen in her other hand, reaching over from the right, tapping down the page: a blue barrel, a red cap.
        let lift = Int(p.t * 7) % 2 * 2
        let row = 30 + min(2, lines) * 2
        let nx = 44.5, ny = Double(row - lift) + 0.5
        slayerLine(c, nx, ny, nx + 5, ny - 5, C(0x2A3A8A), 0.6)
        c.px(Int(nx + 5), Int(ny - 5), C(0xC03030)); c.px(Int(nx), Int(ny), C(0xC0C4CC))
        c.rect(Int(nx) + 2, Int(ny) - 3, 3, 3, clawdOrange)
    }
    c.rect(38, 33, 4, 3, coat); c.rect(40, 33, 2, 2, clawdOrange)            // her hand on the board
}

// MARK: - Glorificlawds

/// Glorificlawds: Glory, the hell-god in a mortal body, all big blonde curls, a short red dress, red lips and red
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
        // The front leg kicked up and forward, toe pointed, so she can admire the red heel; it catches the light.
        for lx in [19, 23, 31] { c.rect(lx, 36, 2, 8, clawdOrange); c.rect(lx, 43, 2, 1, shoe) }
        let fx = 36 + 6 * admire, fy = 42.5 - 2.5 * admire
        slayerLine(c, 36, 37, fx, fy, clawdOrange, 0.9)
        let sx = Int(fx.rounded()), sy = Int(fy.rounded())
        c.rect(sx - 1, sy - 1, 3, 1, shoe); c.rect(sx - 1, sy, 5, 1, shoe); c.px(sx - 1, sy + 1, shoe)  // shoe, heel
        c.px(sx, sy - 1, dressL)
        if admire > 0.9 && Int(p.t * 6) % 2 == 0 {
            c.px(sx + 4, sy - 3, white)
            for (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1)] { c.px(sx + 4 + dx, sy - 3 + dy, white.alpha(0.2)) }
        }
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
    // The mantle of hide hunched over its back and draped round its shoulders, close to the body, hanging in
    // ragged strands over the tops of its legs.
    c.pattern(13, 28, [
        "...HHHH...................",
        "..HHHlHH..................",
        ".HHHlHHH..................",
        ".HHlHHHH..................",
        "HHHHHHHH..................",
        "HHHHHHHH..................",
        "HHHHHHHHHHHHHHHHHHHHHHHHHH",
        ".HdHHHHHHHHHHHHHHHHHHHHHdH",
        ".HHdHHHHHHHHHHHHHHHHHHHdHH",
        "..H.HdHH.HdH.HHdHH.HdH.Hd.",
        "..d..H....d...H.....H..d..",
    ], ["H": hide, "l": hideL, "d": hideD])
    c.rect(19, 34, 19, 1, hideL)

    // The horns, whatever face it wears: thick at the skull, curving up and out, paler at the tips.
    for side in [-1.0, 1.0] {
        let bx = 28 + side * 8
        let pts: [(Double, Double)] = [(bx, 26), (bx + side * 3, 21), (bx + side * 4, 16), (bx + side * 2, 12)]
        let r: [Double] = [1.8, 1.4, 0.9]
        for i in 0..<3 {
            slayerLine(c, pts[i].0, pts[i].1, pts[i + 1].0, pts[i + 1].1, i == 2 ? hornL : horn, r[i])
        }
    }

    switch face {
    case 0: oldMasterHead(c)
    case 1: c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink); mayorHead(c)
    case 2: c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink); gloryHead(c)
    case 3: c.rect(32, 29, 2, 3, ink); adamHead(c)
    default:
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
        // The forearm raised in front of him, elbow bent, fist up: the black sleeve rolls down off it, the white
        // shirt cuff turning over in a thick band, and the bare forearm (shaded on its far side) shows above it.
        let fist = 35 - Int((out * 9).rounded())                               // the top of the fist
        let skinD = C(0xB05A3C), cuffD = C(0x8E8E8A)
        c.rect(38, 33, 5, 3, suit)                                              // the upper arm, out to the elbow
        c.rect(42, fist + 3, 3, 36 - fist - 3, suit); c.rect(44, fist + 3, 1, 36 - fist - 3, suitD)
        let bare = min(36 - fist - 6, Int((roll * 4).rounded()))
        if bare > 0 { c.rect(42, fist + 3, 2, bare, clawdOrange); c.rect(44, fist + 3, 1, bare, skinD) }
        if fist + 3 + bare + 1 < 36 {
            // The rolled cuff: a band of white shirt, its turned-over fold in grey shadow under it.
            c.rect(41, fist + 3 + bare, 5, 1, C(0xE6E4DC)); c.rect(41, fist + 4 + bare, 5, 1, cuffD)
            c.px(45, fist + 3 + bare, cuffD)
        }
        // The fist, bigger than the wrist, knuckles forward, the gold ring on them.
        c.rect(41, fist - 1, 5, 4, clawdOrange); c.rect(45, fist - 1, 1, 4, skinD); c.rect(41, fist + 2, 5, 1, skinD)
        c.px(44, fist, gold)
        if roll > 0.99, let s, s > 0.6, s < 0.85, Int(s * 40) % 3 == 0 {
            c.px(47, fist - 2, white); c.px(48, fist - 3, white.alpha(0.2))     // a crack of the knuckles
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
    let hair = C(0x1A1420), hairL = C(0x4A3A5C), hairD = C(0x08060A), part = C(0x2E2238)
    let vein = C(0x9A0A26), veinHot = C(0xE81838)
    let bookK = p.signature.map { $0 > 0.06 && $0 < 0.92 ? ($0 - 0.06) / 0.86 : -1 } ?? -1

    drawLegs(c, Look(leg: C(0x1A181E)), step: p.step)
    slayerBoots(c, step: p.step, C(0x0A080C), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: top, eye: nil), armRight: bookK >= 0 ? 1 : p.armRaise)
    // Black eyes, a red glint in them, and the veins: few and bold, crimson strokes forking out from the eyes,
    // burning brighter while she reads.
    c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink); c.px(23, 29, C(0xD8102C)); c.px(33, 29, C(0xD8102C))
    let hot = bookK >= 0 && Int(p.t * 5) % 2 == 0
    let v = hot ? veinHot : vein
    c.pattern(19, 27, [
        "vv..............vv",
        ".vv............vv.",
        "..................",
        "..................",
        "..................",
        "..vv..........vv..",
        ".vv............vv.",
    ], ["v": v])
    // The long black top, high at the neck.
    c.rect(18, 34, 20, 4, top); c.rect(37, 34, 1, 4, topD); c.rect(18, 37, 20, 1, topD); c.rect(25, 34, 6, 1, topL)
    // The same hair as Willow's, gone black with a plum sheen, falling close at the sides so the face shows.
    c.pattern(16, 20, [
        ".....HHHHHHpHHHHHH......",
        "....HHlllHHpHHHHHHH.....",
        "...HHlHHHHHpHHHHHlHH....",
        "..HHlHHHHHHpHHHHHHlHH...",
        "..HlHHHHHHHpHHHHHHHHHH..",
        ".HHHHHHHHHHpHHHHHHHHHHH.",
        ".HHHHHHH........HHHHHHH.",
        ".HH..................HH.",
        ".HH..................HH.",
        ".Hl..................HH.",
        ".Hl..................HH.",
        ".HH..................lH.",
        ".HH..................HH.",
        ".Hd..................dH.",
        ".Hd..................dH.",
        ".dHd................dHd.",
        ".dd..................dd.",
    ], ["H": hair, "l": hairL, "d": hairD, "p": part])

    guard bookK >= 0 else {
        c.rect(39, 34 - p.armRaise, 2, 2, clawdOrange); c.px(39, 34 - p.armRaise, vein)
        return
    }
    // The open book held out in front of her: big pale pages, lines of black text, a blood-red cover.
    let cover = C(0x6A1A22), coverD = C(0x3E0C12), page = C(0xF0E6CC), pageD = C(0xC8BCA0), text = C(0x2A1A1E)
    c.pattern(39, 30, [
        ".PPPPP.PPPPP",
        "PPPPPPsPPPPD",
        "PPPPPPsPPPPD",
        "PPPPPPsPPPPD",
        "PPPPPPsPPPPD",
        "CCCCCCCCCCCC",
        ".cccccccccc.",
    ], ["P": page, "D": pageD, "s": C(0x8A7A60), "C": cover, "c": coverD])
    let left = bookK > 0.85 ? 0 : 4 - Int(bookK * 4.2)                          // the text going as the letters leave
    for k in 0..<max(0, left) {
        c.rect(40, 31 + k, k % 2 == 0 ? 4 : 3, 1, text); c.rect(46, 31 + k, k % 2 == 0 ? 3 : 4, 1, text)
    }
    c.rect(38, 34, 2, 2, clawdOrange); c.px(38, 34, vein)
    // Letters lifting off the page in a red glow and arcing back into her arm.
    guard bookK < 0.95 else { return }
    for k in 0..<4 {
        let f = frac(p.t * 0.8 + Double(k) / 4)
        let x = 46 - f * 7, y = 29 - sin(f * .pi) * 7 + f * 3
        let fade = f < 0.12 ? f / 0.12 : f > 0.8 ? (1 - f) / 0.2 : 1
        let xi = Int(x.rounded()), yi = Int(y.rounded())
        c.glowLine(Double(xi) + 1, Double(yi) + 1.5, Double(xi) + 1, Double(yi) + 1.5, core: C(0xFF3A50, 0),
                   glow: C(0xD8102C), coreR: 0.1, glowR: 2.4, strength: 0.3 * fade)
        let col = (k % 2 == 0 ? C(0xFF4A5E) : C(0xF0E6CC)).alpha(fade < 1 ? fade * 0.2 : 1)
        switch k {
        case 0: c.pattern(xi, yi, ["LL", "L.", "LL"], ["L": col])
        case 1: c.pattern(xi, yi, ["L.L", ".L.", "L.L"], ["L": col])
        case 2: c.pattern(xi, yi, [".L", "LL", ".L"], ["L": col])
        default: c.pattern(xi, yi, ["LLL", ".L.", ".L."], ["L": col])
        }
    }
}
