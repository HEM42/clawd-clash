import Foundation

// Heroes: The Goonies. Clawd in costume like the rest of the cast: the kids' hair, hoodies, jackets and sneakers drawn
// over the blocky body, with Clawd's own orange face showing; Slawth is Clawd built bigger, in a pirate hat.

let clawdbergHeroes4: [ClawdbergHero: Persona] = [
    .mikeyWaltz: Persona(name: "Mikey Waltz", headTop: 20, signature: 3.0, callout: "Goonies never say die!",
                         draw: drawMikeyWaltz),
    .brandWaltz: Persona(name: "Brand Waltz", weapon: .saber, headTop: 20, signature: 3.4, draw: drawBrandWaltz),
    .chunk: Persona(name: "Chunk", weapon: .blaster, shot: .thrown(C(0x6A3A1E)), muzzle: (46, 30), bulk: 2, headTop: 21,
                    signature: 3.2, draw: drawChunk),
    .mouth: Persona(name: "Mouth", headTop: 20, signature: 3.0, draw: drawMouth),
    .data: Persona(name: "Data", weapon: .blaster, shot: .thrown(C(0xC8CCD4)), muzzle: (47, 31), headTop: 20,
                   signature: 3.4, callout: "Booby traps!", draw: drawData),
    .andyCarmichaw: Persona(name: "Andy Carmichaw", headTop: 20, signature: 3.4, draw: drawAndyCarmichaw),
    .stefSteinclawd: Persona(name: "Stef Steinclawd", weapon: .saber, headTop: 20, signature: 2.6,
                             draw: drawStefSteinclawd),
    .slawth: Persona(name: "Slawth", weapon: .saber, bulk: 4, headTop: 13, signature: 3.4, callout: "Hey, you guys!",
                     draw: drawSlawth),
]

// MARK: - Shared bits

private let clear = C(0, 0)
private let sneakerWhite = C(0xEDEDED)

/// Sneakers on the four feet, white with a coloured stripe.
private func sneakers(_ c: PixelCanvas, step: Int, stripe: Px) {
    cbBoots(c, step: step, sneakerWhite)
    guard !seatedPose else { return }
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        let lifted = step >= 0 && i % 2 == step
        c.px(lx + 1, lifted ? 41 : 42, stripe)
    }
}

/// A two-pixel music note, its stem and flag, `k` (0…1) of the way up from (x, y).
private func note(_ c: PixelCanvas, x: Int, y: Int, k: Double, _ col: Px) {
    let yy = y - Int((k * 10).rounded()), a = 1 - k * 0.7
    c.rect(x, yy + 2, 2, 2, col.alpha(a)); c.rect(x + 1, yy, 1, 2, col.alpha(a)); c.px(x + 2, yy, col.alpha(a))
}

// MARK: - Mikey Waltz

/// Mikey Waltz: Clawd with a shaggy brown mop, a red hoodie with its hood bunched behind his neck and its drawstrings
/// hanging, jeans and white sneakers, a grin full of braces, the inhaler in his hand. He doesn't fight. Signature: he
/// puts the inhaler to his mouth, takes a puff and holds it in, eyes screwed shut.
private func drawMikeyWaltz(_ c: PixelCanvas, _ p: Pose) {
    let hoodie = C(0xC23A2E), hoodieD = C(0x8E2820)
    let hair = C(0x6A4428), hairL = C(0x8A5E38), inhaler = C(0x5A8AC8), cap = C(0xD8DCE4)
    let sig = p.signature
    let puffing = sig.map { $0 > 0.08 && $0 < 0.88 } ?? false

    drawLegs(c, Look(leg: C(0x4A6A9A)), step: p.step)
    sneakers(c, step: p.step, stripe: C(0xC23A2E))
    c.oy += p.breathe
    // The hood, bunched up behind his neck.
    c.rect(15, 28, 4, 6, hoodie); c.rect(15, 28, 1, 6, hoodieD); c.rect(16, 29, 2, 1, hoodieD)
    drawBody(c, Look(arm: puffing ? clear : hoodie))
    c.rect(15, 33, 3, 3, hoodie)
    // The hoodie, its pouch pocket and drawstrings.
    c.rect(18, 33, 20, 5, hoodie); c.rect(37, 33, 1, 5, hoodieD); c.rect(18, 37, 20, 1, hoodieD)
    c.rect(23, 35, 10, 2, hoodieD)
    c.rect(25, 33, 1, 2, white); c.rect(30, 33, 1, 2, white)
    // The grin and its braces.
    c.pattern(24, 31, ["k......k", ".kSkSkS."], ["k": ink, "S": cap])
    // The mop: shaggy all round, the fringe falling in points over his forehead.
    c.pattern(16, 20, [
        "......HHHHHHHHH.......",
        "....HHHHHhHHHHHHH.....",
        "..HHHHHHHHHHhHHHHHH...",
        ".HHHHHHhHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHhHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHH.HHH.HHHH.HHH.HHHH.",
        "HH...H...H.....H...H..",
        "HH....................",
    ], ["H": hair, "h": hairL])

    guard puffing, let k = sig else {
        // The inhaler in his hand.
        c.rect(40, 31, 2, 3, inhaler); c.px(40, 34, cap)
        return
    }
    // The inhaler at his mouth, his hand round it.
    c.rect(37, 31, 3, 4, hoodie)
    c.rect(33, 27, 2, 4, inhaler); c.rect(31, 31, 4, 1, cap)
    c.rect(35, 29, 2, 3, clawdOrange)
    if k > 0.28 && k < 0.5 {
        // The puff.
        let i = Int(k * 40)
        for j in 0..<4 {
            c.px(30 - Int(noise(i + j) * 3), 30 + Int(noise(i * 3 + j) * 3), C(0xF4F8FF, 0.7))
        }
    } else if k >= 0.5 && k < 0.8 {
        // Holding it in: eyes screwed shut.
        c.rect(22, 29, 2, 3, clawdOrange); c.rect(32, 29, 1, 3, clawdOrange)
        c.rect(21, 30, 3, 1, ink); c.rect(32, 30, 2, 1, ink)
    }
}

// MARK: - Brand Waltz

/// Brand Waltz: Clawd with feathered light brown hair and a red sweatband round his forehead, its knot trailing at the
/// back, in grey sweats and white sneakers. He fights with his fists. Signature: he pumps the chest expander, its two
/// red handles pulled wide and its springs stretching across his chest, three reps.
private func drawBrandWaltz(_ c: PixelCanvas, _ p: Pose) {
    let sweats = C(0x8C8E94), sweatsD = C(0x6A6C72), sweatsL = C(0xA8AAB0), band = C(0xD23A30)
    let hair = C(0x9A6A3A), hairL = C(0xB8864E), spring = C(0xD8DCE4), springD = C(0x8A8E96)
    let sig = p.signature
    let pumping = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: sweats), step: p.step)
    sneakers(c, step: p.step, stripe: C(0x3A5AA8))
    c.oy += p.breathe
    drawBody(c, Look(arm: pumping ? clear : sweats))
    // The sweatshirt, its ribbed collar and hem.
    c.rect(18, 33, 20, 5, sweats); c.rect(37, 33, 1, 5, sweatsD); c.rect(18, 37, 20, 1, sweatsD)
    c.rect(24, 33, 8, 1, sweatsD)
    // Light along the shoulders, the front pocket's seam and a fold either side.
    c.rect(18, 33, 6, 1, sweatsL); c.rect(32, 33, 5, 1, sweatsL)
    c.rect(24, 35, 8, 1, sweatsD); c.px(24, 36, sweatsD); c.px(31, 36, sweatsD)
    c.rect(20, 34, 1, 2, sweatsD); c.rect(34, 34, 1, 2, sweatsD)
    // Feathered hair, parted in the middle and swept back.
    c.pattern(16, 20, [
        ".......HHHHHHHH.......",
        ".....HHHhhHHhhHHH.....",
        "...HHHhhHHHHHHhhHHH...",
        "..HHhhHHHHHHHHHHhhHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHH.",
        "HH....................",
        "HH....................",
    ], ["H": hair, "h": hairL])
    // The sweatband across his forehead, its knot at the back.
    c.rect(17, 25, 21, 2, band); c.rect(17, 25, 21, 1, C(0xF0E8E0).alpha(0.4))
    c.px(15, 26, band); c.px(14, 27, band); c.px(15, 28, band)

    if pumping, let k = sig {
        // The chest expander: a handle in each fist, pulled wide and let back, three reps.
        let u = (k - 0.06) / 0.88
        let s = 0.5 - 0.5 * cos(u * 6 * .pi)
        let w = Int((s * 5).rounded())
        let lx = 13 - w, rx = 41 + w
        c.rect(lx, 32, 18 - lx, 3, sweats); c.rect(38, 32, rx - 38, 3, sweats)
        for x in (lx + 1)...(rx - 1) {
            let col = x % 2 == 0 ? spring : springD
            c.px(x, 31, col); c.px(x, 35, col)
        }
        c.rect(lx - 1, 31, 2, 5, band); c.rect(rx, 31, 2, 5, band)
        c.rect(lx, 32, 2, 3, clawdOrange); c.rect(rx - 1, 32, 2, 3, clawdOrange)
        return
    }
    if let a = p.melee {
        cbPunch(c, angle: a, trail: p.trail, arm: sweats)
    } else {
        c.rect(15, 35, 3, 1, sweatsD); c.rect(38, 35, 3, 1, sweatsD)   // the ribbed cuffs
    }
}

// MARK: - Chunk

/// Chunk: Clawd built round, his belly pushing out front and back, in a loud teal Hawaiian shirt covered in yellow
/// and pink flowers, khaki trousers and sneakers, short dark curls. He fights by throwing candy bars. Signature: the
/// Truffle Shuffle, the shirt hauled up over his belly and the belly wobbling as he sways from side to side.
private func drawChunk(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0x2A9AB8), shirtD = C(0x1E7290), petal = C(0xF06A9A), centre = C(0xF4D040), leaf = C(0x4AB86A)
    let hair = C(0x3A2416), hairL = C(0x56381F), choc = C(0x5A341C), wrap = C(0xD8342A)
    let sig = p.signature
    let shuffling = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: C(0xB8A47A)), step: p.step)
    sneakers(c, step: p.step, stripe: C(0x2A9AB8))
    c.oy += p.breathe

    if shuffling, let k = sig {
        // The Truffle Shuffle: the body swaying, the belly bare and wobbling, the shirt held up in both hands.
        let sway = Int(k * 12) % 2 == 0 ? -1 : 1
        let wob = Int(k * 24) % 2
        c.ox += sway
        c.rect(38, 31, 2 + wob, 6, clawdOrange); c.rect(40 + wob, 33, 1, 3, clawdOrange)
        c.rect(17 - wob, 31, 1 + wob, 6, clawdOrange)
        drawBody(c, Look(arm: clear))
        c.rect(18, 37, 22, 1, clawdShade)
        c.px(31, 35, clawdShade)                                // the belly button
        c.rect(17, 32, 23, 2, shirt); c.rect(17, 33, 23, 1, shirtD)
        for x in [19, 25, 31, 37] { c.px(x, 32, petal); c.px(x + 1, 32, centre) }
        c.rect(14, 31, 3, 3, shirt); c.rect(40, 31, 3, 3, shirt)
        c.px(16, 33, clawdOrange); c.px(40, 33, clawdOrange)
        // Wobble lines.
        c.px(43 + wob, 33, white.alpha(0.6)); c.px(43 + wob, 35, white.alpha(0.6))
        c.px(14 - wob, 34, white.alpha(0.6))
    } else {
        // The belly, front and back, under the shirt.
        c.rect(38, 30, 2, 7, shirt); c.rect(40, 32, 1, 4, shirtD); c.rect(17, 30, 1, 7, shirt)
        drawBody(c, Look(arm: shirt))
        c.rect(18, 32, 20, 6, shirt); c.rect(18, 37, 22, 1, shirtD); c.rect(37, 32, 1, 5, shirtD)
        c.pattern(25, 32, ["WW..WW", ".W..W."], ["W": C(0xF4F0E4)])   // the open collar
        // The flowers.
        for (x, y) in [(20, 33), (32, 34), (26, 36), (35, 36), (21, 36), (38, 32)] {
            c.px(x, y, centre)
            c.px(x - 1, y, petal); c.px(x + 1, y, petal); c.px(x, y - 1, petal); c.px(x, y + 1, petal)
            c.px(x + 1, y + 1, leaf)
        }
    }
    // Rosy cheeks.
    c.px(20, 31, C(0xE89A88)); c.px(34, 31, C(0xE89A88))
    // Short dark curls.
    c.pattern(17, 21, [
        "....HhHHhHHhHHhH....",
        "..HHHHHHHHHHHHHHHH..",
        ".HHhHHHhHHHHhHHHhHH.",
        "HHHHHHHHHHHHHHHHHHHH",
        "HH.HH.HHHHHH.HH.HHHH",
        "H.........H.......H.",
    ], ["H": hair, "h": hairL])
    if shuffling { return }

    if p.fire != nil || p.ready || p.gunLift > 0 || p.smoke != nil {
        // A candy bar raised to throw.
        c.oy += p.gunY
        c.rect(38, 30, 3, 3, shirt)
        c.rect(41, 29, 5, 2, choc); c.rect(41, 29, 1, 2, wrap); c.px(44, 29, C(0x7A4A2A))
        return
    }
    // A candy bar in his hand, half unwrapped and bitten.
    c.rect(40, 30, 2, 3, choc); c.rect(40, 33, 2, 2, wrap)
}

// MARK: - Mouth

/// Mouth: Clawd with dark feathered hair and an enormous grin, white teeth from ear to ear, in a stonewashed denim
/// jacket over a white T-shirt, grey trousers and sneakers. He doesn't fight. Signature: he jabbers, both hands going
/// as he talks, his mouth flapping open and shut and the words coming out of it.
private func drawMouth(_ c: PixelCanvas, _ p: Pose) {
    let denim = C(0x5B7FB0), denimD = C(0x3E5E8A), stitch = C(0x9AB8DC), tee = C(0xF2F0EA)
    let hair = C(0x2A1A12), hairL = C(0x4A3020)
    let sig = p.signature
    let jabbering = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false

    drawLegs(c, Look(leg: C(0x6E6E74)), step: p.step)
    sneakers(c, step: p.step, stripe: C(0x2A2A30))
    c.oy += p.breathe
    drawBody(c, Look(arm: jabbering ? clear : denim))
    // The jacket open over the tee, its seams and pocket flaps.
    c.rect(18, 34, 20, 4, denim); c.rect(37, 34, 1, 4, denimD); c.rect(18, 37, 20, 1, denimD)
    c.rect(25, 34, 6, 4, tee)
    c.rect(24, 34, 1, 3, stitch); c.rect(31, 34, 1, 3, stitch)
    c.rect(20, 35, 3, 1, denimD); c.rect(33, 35, 3, 1, denimD)
    // Feathered hair, flicked up at the front.
    c.pattern(16, 20, [
        "...........HH.........",
        "......HHHHHHHHHH.H....",
        "....HHHHHhHHHHHHHHH...",
        "..HHHHHHHHHhHHHHHHHH..",
        ".HHHHhHHHHHHHHHhHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHH.",
        "HHHH.HHHHH...HHHH.HH..",
        "HH..........H.........",
    ], ["H": hair, "h": hairL])

    let open = jabbering && Int(sig! * 16) % 2 == 0
    if open {
        c.pattern(23, 32, ["kWWWWWWWWk", "kRRRRRRRRk", ".kkkkkkkk."], ["k": ink, "W": white, "R": C(0x8A2A2A)])
    } else {
        c.pattern(23, 32, ["kWWWWWWWWk", ".kkkkkkkk."], ["k": ink, "W": white])
    }
    guard jabbering, let k = sig else { return }
    // Both hands going, one up as the other comes down, and the words spilling out in front.
    let a = Int(k * 10) % 2
    let la = a == 0 ? 5 : 1, ra = a == 0 ? 1 : 5
    c.rect(15, 33 - la, 3, 3 + la, denim); c.px(15, 32 - la, clawdOrange); c.px(17, 32 - la, clawdOrange)
    c.rect(38, 33 - ra, 3, 3 + ra, denim); c.px(38, 32 - ra, clawdOrange); c.px(40, 32 - ra, clawdOrange)
    let i = Int(k * 16)
    for j in 0..<3 {
        let x = 43 + j * 3, y = 30 + Int(noise(i + j) * 3) - j
        c.rect(x, y, 2, 1, ink.alpha(0.8))
    }
}

// MARK: - Data

/// Data: Clawd with spiky black hair and big gadget goggles pushed up on his forehead, in a long olive trench coat
/// stuffed with gadgets (silver bits, wires, a red light) over a white shirt and a little red tie. He fights with
/// silver gadgets, fired from a contraption in his hand. Signature: the Pinchers of Peril, a scissor arm shooting out
/// of his chest, snapping its pincers, and folding back in.
private func drawData(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x7A7660), coatD = C(0x58553F), coatL = C(0x96927A)
    let metal = C(0xC8CCD4), metalD = C(0x7A7E88), glass = C(0x5AB8E8), hair = C(0x16161B), hairL = C(0x34343C)
    let sig = p.signature
    let pinching = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: C(0x3A3A44)), step: p.step)
    cbBoots(c, step: p.step, C(0x24242A))
    c.oy += p.breathe
    // The coat tails over the legs.
    let tails = seatedPose ? 1 : 3
    c.rect(17, 38, 22, tails, coat); c.rect(17, 37 + tails, 22, 1, coatD); c.rect(28, 38, 1, tails, coatD)
    drawBody(c, Look(arm: coat))
    // The shirt and tie, the coat open over them, its pockets bristling with gadgets.
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD); c.rect(18, 37, 20, 1, coatD)
    c.rect(25, 33, 6, 4, white); c.rect(27, 33, 2, 4, C(0xC8342A))
    c.rect(24, 33, 1, 4, coatL); c.rect(31, 33, 1, 4, coatL)
    c.px(20, 34, metal); c.px(21, 34, metalD); c.px(20, 35, C(0xFF3A3A)); c.px(34, 34, metal)
    c.px(35, 35, C(0xF4D040)); c.px(34, 36, metalD); c.px(22, 36, C(0xF4D040))
    // Spiky black hair.
    c.pattern(16, 20, [
        ".....H..H...H..H......",
        "....HHHHHHHHHHHHH.....",
        "..HHHHHHhHHHHhHHHHH...",
        ".HHHHHHHHHHHHHHHHHHH..",
        "HHHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHH..",
        "HH....................",
    ], ["H": hair, "h": hairL])
    // The goggles, pushed up on his forehead.
    c.rect(16, 25, 22, 1, C(0x2A2A30))
    c.pattern(20, 23, [".MMM....MMM..", "MGGGM..MGGGM.", "MGgGMMMMGgGM.", ".MMM....MMM.."],
              ["M": metal, "G": glass, "g": C(0xC8EEFF)])

    if pinching, let k = sig {
        // The Pinchers of Peril: a scissor arm out of the chest, the pincers snapping, then folding back in.
        var ext = 1.0
        if k < 0.32 { ext = (k - 0.06) / 0.26 } else if k > 0.72 { ext = max(0, (0.94 - k) / 0.22) }
        let len = Int((ext * 21).rounded())
        c.rect(36, 31, 4, 3, C(0xC8342A))
        var i = 0
        while i + 3 <= len {
            let xa = Double(39 + i), xb = Double(42 + i)
            cbLine(c, xa, 30, xb, 34, metal, 0.5); cbLine(c, xa, 34, xb, 30, metalD, 0.5)
            i += 3
        }
        let tip = Double(39 + i)
        let open = k > 0.32 && k < 0.72 && Int(k * 24) % 2 == 0
        let spread = open ? 3.0 : 0.5
        cbLine(c, tip, 31, tip + 4, 32 - spread, metal, 0.5); cbLine(c, tip + 4, 32 - spread, tip + 6, 32, metal, 0.5)
        cbLine(c, tip, 33, tip + 4, 32 + spread, metal, 0.5); cbLine(c, tip + 4, 32 + spread, tip + 6, 32, metal, 0.5)
        return
    }
    if p.fire != nil || p.ready || p.gunLift > 0 || p.smoke != nil {
        // The gadget launcher, aimed.
        c.oy += p.gunY
        c.rect(38, 32, 3, 3, coat)
        c.pattern(39, 30, ["..MMMMMM", "MMMMMMMm", "MRMM....", "mm......"],
                  ["M": metal, "m": metalD, "R": C(0xFF3A3A)])
        return
    }
    // The launcher held down at his side.
    c.pattern(39, 35, ["MM", "MR", "MM", "mm"], ["M": metal, "m": metalD, "R": C(0xFF3A3A)])
}

// MARK: - Andy Carmichaw

/// Andy Carmichaw: Clawd with long blonde hair down past her shoulders, in a red cheerleader jacket with white sleeves
/// and trim and a letter patch, a pleated red and white skirt and white sneakers. She doesn't fight. Signature: she
/// plays the bone organ, its pipes made of bones, her hands on the keys and the notes rising out of it.
private func drawAndyCarmichaw(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0xB02A3A), jacketD = C(0x7E1C2A), sleeve = C(0xF0ECE4), sleeveD = C(0xC8C2B6)
    let hair = C(0xE8C860), hairL = C(0xF6E09A), hairD = C(0xC09A3A)
    let bone = C(0xEEE6D0), boneD = C(0xB8AE94), wood = C(0x4A2E1E)
    let sig = p.signature
    let playing = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(), step: p.step)
    sneakers(c, step: p.step, stripe: jacket)
    c.oy += p.breathe
    // Long hair down her back.
    c.rect(15, 26, 4, 9, hair); c.rect(15, 34, 3, 1, hairD); c.px(16, 28, hairL)
    // The pleated skirt over the tops of the legs.
    if !seatedPose {
        for x in 17...38 { c.rect(x, 38, 1, 2, x % 3 == 0 ? white : jacket) }
    }
    drawBody(c, Look(arm: playing ? clear : sleeve))
    // The jacket, white trim at the hem and a letter patch.
    c.rect(18, 33, 20, 5, jacket); c.rect(37, 33, 1, 5, jacketD); c.rect(18, 37, 20, 1, white)
    c.rect(24, 33, 8, 1, white)
    c.pattern(21, 34, [".W.", "WWW", "W.W"], ["W": white])
    // The hair on top, a long lock down the front of her face's side.
    c.pattern(16, 20, [
        "......HHHHHHHHHH......",
        "....HHHHHHlHHHHHHH....",
        "..HHHHHlHHHHHHHlHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHH.HHHH.........HHHHH",
        "HH...H.............HHH",
        "HH..................HH",
        "HH..................HH",
        "HH..................dH",
        "HH...................d",
    ], ["H": hair, "l": hairL, "d": hairD])

    guard playing, let k = sig else { return }
    // The bone organ in front of her: bone pipes standing over a little keyboard.
    let tops = [25, 21, 18, 20, 24]
    for (i, top) in tops.enumerated() {
        let x = 45 + i * 3
        c.rect(x, top + 1, 1, 34 - top, bone); c.px(x + 1, top + 2, boneD)
        c.px(x - 1, top, bone); c.px(x + 1, top, bone); c.px(x, top, boneD)
    }
    c.rect(42, 34, 18, 5, wood); c.rect(42, 34, 18, 1, C(0x6A4A30))
    for x in stride(from: 43, to: 59, by: 2) { c.px(x, 35, bone) }
    c.rect(43, 39, 2, 4, wood); c.rect(57, 39, 2, 4, wood)
    // Her hands on the keys, one pressing down and then the other.
    let press = Int(k * 12) % 2
    c.rect(38, 32, 5, 2, sleeve); c.rect(43, 33 + press, 2, 1, clawdOrange)
    c.rect(15, 33, 3, 3, sleeve); c.rect(15, 35, 3, 1, sleeveD)
    // The notes rising.
    for j in 0..<3 {
        let f = frac(k * 2.5 + Double(j) / 3)
        note(c, x: 47 + j * 4, y: 15, k: f, ink)
    }
}

// MARK: - Stef Steinclawd

/// Stef Steinclawd: Clawd with a bushy dark bob and enormous round glasses, thick dark frames over both eyes, in a
/// purple turtleneck sweater, jeans and sneakers. She fights with a punch. Signature: the glasses slide down
/// her nose and she pushes them back up with one finger, and they glint.
private func drawStefSteinclawd(_ c: PixelCanvas, _ p: Pose) {
    let sweater = C(0x6A4A8A), sweaterD = C(0x4C3266), sweaterL = C(0x8466A4), frame = C(0x2A1E2A), lens = C(0xCFE6F0, 0.35)
    let hair = C(0x2E1E14), hairL = C(0x4A3222)
    let sig = p.signature
    let pushing = sig.map { $0 > 0.3 && $0 < 0.75 } ?? false
    var gy = 0
    if let k = sig, k > 0.06 && k < 0.45 { gy = 1 }

    drawLegs(c, Look(leg: C(0x4A6A9A)), step: p.step)
    sneakers(c, step: p.step, stripe: sweater)
    c.oy += p.breathe
    // The bob, bushy at the back.
    c.rect(15, 25, 4, 9, hair); c.rect(16, 29, 1, 3, hairL)
    drawBody(c, Look(arm: pushing ? clear : sweater))
    c.rect(15, 33, 3, 3, sweater); c.rect(15, 35, 3, 1, sweaterD)
    // The sweater and its white collar.
    c.rect(18, 34, 20, 4, sweater); c.rect(37, 34, 1, 4, sweaterD); c.rect(18, 37, 20, 1, sweaterD)
    c.rect(24, 34, 8, 1, C(0x8A6AAA))   // the turtleneck's roll
    // Light on the shoulders and the knit's folds.
    c.rect(18, 34, 5, 1, sweaterL); c.rect(33, 34, 4, 1, sweaterL)
    c.rect(21, 35, 1, 2, sweaterD); c.rect(34, 35, 1, 2, sweaterD); c.px(27, 36, sweaterD)
    c.pattern(16, 20, [
        ".....HHHHHHHHHHH......",
        "...HHHhhhHHHHHHHHH....",
        "..HHhhHHHHHHhhhHHHHH..",
        ".HHHHHHHHHHHHHHHHHhhH.",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHHH.HHHHHHHHHHHH.HHHH",
        "HHH.....H....H......HH",
    ], ["H": hair, "h": hairL])
    // The glasses: two big round frames, the bridge between, the arm back over her ear.
    let ring = [".FFFF.", "FLLLLF", "FLLLLF", "FLLLLF", "FLLLLF", "FLLLLF", ".FFFF."]
    c.pattern(20, 27 + gy, ring, ["F": frame, "L": lens])
    c.pattern(30, 27 + gy, ring, ["F": frame, "L": lens])
    c.rect(26, 29 + gy, 4, 1, frame); c.rect(17, 29 + gy, 3, 1, frame)

    if pushing, let k = sig {
        // A finger on the bridge, pushing them home; then a glint.
        c.rect(36, 31, 3, 4, sweater)
        cbLine(c, 36, 31.5, 30, 30.5, sweater, 1)
        c.rect(27, 29, 2, 2, clawdOrange)
        if k > 0.55 { c.px(31, 28, white); c.px(21, 28, white) }
        return
    }
    if let a = p.melee {
        cbPunch(c, angle: a, trail: p.trail, arm: sweater)
    }
}

// MARK: - Slawth

/// Slawth: Clawd built big, a head taller and wider all round, a lopsided face with one droopy eye and a snaggle
/// tooth, a battered brown pirate hat with a red and white plume, a ragged brown shirt hanging open over a blue
/// Superman T-shirt, and big boots. He fights with his huge fists. Signature: he grabs his shirt and rips it open, the
/// rags flying off, and stands with his arms wide to show the Superman logo.
private func drawSlawth(_ c: PixelCanvas, _ p: Pose) {
    let body = clawdOrange, shade = clawdShade
    let tee = C(0x2A4CA8), shirt = C(0x7A5232), shirtD = C(0x553820), red = C(0xD8302A), gold = C(0xF4D040)
    let hat = C(0x4A3020), hatD = C(0x2E1C12)
    let sig = p.signature
    let k = sig ?? 0
    let ripping = sig != nil && k > 0.06 && k < 0.94
    let torn = ripping && k > 0.32

    drawLegs(c, Look(leg: C(0x4A3A30)), step: p.step)
    cbBoots(c, step: p.step, C(0x2A1E16), height: 3)
    c.oy += p.breathe
    // The big body, a lump on the head.
    c.rect(15, 22, 26, 16, body); c.rect(15, 37, 26, 1, shade); c.rect(40, 22, 1, 16, shade)
    // The lopsided face: one droopy eye low under a heavy lid, the other round; a crooked mouth and a snaggle tooth.
    c.rect(20, 29, 3, 2, ink); c.rect(19, 28, 5, 1, shade)
    c.rect(33, 26, 2, 3, ink)
    c.pattern(25, 30, ["k.....", ".kkkkk", "..W..."], ["k": ink, "W": white])
    // The Superman T-shirt.
    c.rect(15, 32, 26, 6, tee); c.rect(15, 37, 26, 1, C(0x1E3880))
    c.pattern(24, 32, [
        "RRRRRRRRR",
        "RYRRRRYYR",
        ".RYYYYRR.",
        "..RRYYR..",
        "...RYR...",
        "....R....",
    ], ["R": red, "Y": gold])
    // The ragged shirt over it: hanging open, or torn away.
    if !torn {
        c.rect(15, 32, 10, 6, shirt); c.rect(31, 32, 10, 6, shirt)
        c.rect(24, 32, 1, 6, shirtD); c.rect(31, 32, 1, 6, shirtD)
        c.px(19, 37, shirtD); c.px(34, 37, shirtD); c.px(38, 37, shirtD)
    } else if k < 0.55 {
        // The rags flying off.
        let f = (k - 0.32) / 0.23
        let d = Int((f * 10).rounded()), up = Int((sin(f * .pi) * 6).rounded())
        c.rect(10 - d, 30 - up, 5, 4, shirt); c.rect(44 + d, 30 - up, 5, 4, shirt)
        c.px(11 - d, 33 - up, shirtD); c.px(47 + d, 33 - up, shirtD)
    }
    // The hat, cocked, with its plume.
    c.pattern(12, 13, [
        "..rr.........................",
        ".rWrr........................",
        "rWWr.....HHHHHHHHH...........",
        "rWr....HHHHHHHHHHHHH.........",
        "rr....HHHHHHHHHHHHHHH........",
        ".....HHHHHHHHHHHHHHHHH.......",
        "...ddddHHHHHHHHHHHHHHHddd....",
        ".ddddddddddddddddddddddddddd.",
        "..dd.....................dd..",
    ], ["H": hat, "d": hatD, "r": red, "W": white])

    let big = C(0xD97757)
    if ripping {
        if !torn {
            // Fists gripping the collar.
            c.rect(22, 30, 4, 3, big); c.rect(30, 30, 4, 3, big)
            c.rect(13, 31, 9, 3, shirt); c.rect(34, 31, 9, 3, shirt)
        } else {
            // Arms wide, the logo out.
            c.rect(9, 26, 6, 3, tee); c.rect(41, 26, 6, 3, tee)
            c.rect(6, 23, 4, 4, big); c.rect(46, 23, 4, 4, big)
            if Int(k * 10) % 2 == 0 { c.px(26, 33, white); c.px(27, 33, white) }
        }
        return
    }
    c.rect(11, 31, 4, 5, shirt); c.rect(11, 35, 4, 2, big)
    if let a = p.melee {
        cbPunch(c, angle: a, trail: p.trail, arm: shirt, reach: 8)
        let e = cbReach(cbHand, a, 8)
        c.rect(Int(e.x.rounded()) - 2, Int(e.y.rounded()) - 2, 4, 4, big)
    } else {
        c.rect(41, 31, 4, 5, shirt); c.rect(41, 35, 4, 2, big)
    }
}
