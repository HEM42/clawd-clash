import Foundation

// Heroes: Back to the Future. Clawd in costume like the rest of the cast: hair, hats and clothes from 1985, 1955 and
// 1885 drawn over the blocky body, with Clawd's own orange face showing; Einstein is Clawd in a shaggy sheepdog suit.

let clawdbergHeroes2: [ClawdbergHero: Persona] = [
    .martyMcFry: Persona(name: "Marty McFry", weapon: .lightning,
                         magic: Magic(core: C(0xFFF4D0), glow: C(0xFFB02A), jagged: false, notes: true), pivot: (28, 38),
                         headTop: 20, signature: 3.4, callout: "Nobody calls me chicken!", draw: drawMartyMcFry),
    .docBrawn: Persona(name: "Doc Brawn", weapon: .lightning, magic: Magic(core: C(0xFFE07A), glow: C(0xFF6A1A), jagged: false, rcCar: true),
                       headTop: 18, signature: 2.8, callout: "Great Scott!", draw: drawDocBrawn),
    .jenniferParka: Persona(name: "Jennifer Parka", headTop: 19, draw: drawJenniferParka),
    .georgeMcFry: Persona(name: "George McFry", weapon: .saber, headTop: 21, signature: 3.0,
                          callout: "I’m your density", draw: drawGeorgeMcFry),
    .lorraineBaynes: Persona(name: "Lorraine Baynes", headTop: 19, draw: drawLorraineBaynes),
    .einsteinDog: Persona(name: "Einstein the Dog", headTop: 14, signature: 3.2, draw: drawEinsteinDog),
    .claraClawton: Persona(name: "Clara Clawton", headTop: 18, signature: 3.4, draw: drawClaraClawton),
    .goldieWilsun: Persona(name: "Goldie Wilsun", headTop: 20, signature: 3.0, callout: "I’m gonna be mayor!",
                           draw: drawGoldieWilsun),
]

// MARK: - Shared bits

/// A skirt or a long hem hanging over the legs from row 36 down `length` rows, flaring out a pixel at the bottom;
/// shorter when seated. It stops above the feet, so all four legs still show below it.
private func bttfSkirt(_ c: PixelCanvas, _ col: Px, _ dark: Px, length: Int) {
    let rows = seatedPose ? 2 : length
    c.rect(17, 36, 22, rows, col)
    c.rect(16, 36 + rows - 2, 24, 2, col)
    c.rect(16, 36 + rows - 1, 24, 1, dark)
    c.rect(37, 36, 2, rows - 1, dark)
}

/// A little music note.
private func bttfNote(_ c: PixelCanvas, _ x: Int, _ y: Int, _ col: Px) {
    c.rect(x, y + 3, 2, 2, col); c.rect(x + 1, y, 1, 3, col); c.px(x + 2, y, col)
}

// MARK: - Marty McFry

/// Marty McFry: Clawd with a brown 1985 sweep of hair, a denim jacket under the red-orange puffer vest (quilted, open
/// at the front over a checked shirt), jeans and white trainers, his cherry-red guitar always slung across him. He
/// fights with it: he strums and the sound blasts out from its body in a heartbeat rhythm, bam!.bam!.. (`Magic.notes`).
/// Signature: the duck walk, bobbing along on bent knees and wailing out a solo while the notes fly.
private func drawMartyMcFry(_ c: PixelCanvas, _ p: Pose) {
    let vest = C(0xD2482A), vestD = C(0x9E3018), denim = C(0x5A7AAE), denimD = C(0x3E5A88)
    let check = C(0xC8C0B0), checkD = C(0x7A6A6A), jeans = C(0x3E5888)
    let hair = C(0x5E3C22), hairL = C(0x7E5430)
    let sig = p.signature
    let solo = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false

    if solo {
        // The duck walk: knees bent and bobbing forward and back across the spot.
        let k = sig!
        let sway = sin(k * .pi * 6)
        c.ox += Int((sway * 2).rounded())
        c.oy += 1
    }
    drawLegs(c, Look(leg: jeans), step: solo ? Int(p.t * 6) % 2 : p.step)
    cbBoots(c, step: solo ? Int(p.t * 6) % 2 : p.step, C(0xF2F2F2), height: 2)
    if !seatedPose {
        for lx in [19, 23, 31, 35] { c.px(lx, 43, C(0xC83A2A)) }   // the trainers' red flash
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: denim))
    // The denim jacket's collar, the checked shirt, and the puffer vest open over them.
    c.rect(18, 33, 20, 5, denim)
    c.pattern(25, 33, ["cCcCcC", "CcCcCc", "cCcCcC", "CcCcCc", "cCcCcC"], ["c": check, "C": checkD])
    c.rect(18, 33, 7, 5, vest); c.rect(31, 33, 7, 5, vest)
    c.rect(18, 35, 7, 1, vestD); c.rect(31, 35, 7, 1, vestD)       // the quilting
    c.rect(37, 33, 1, 5, vestD); c.rect(18, 37, 20, 1, vestD)
    c.rect(23, 32, 2, 1, denimD); c.rect(31, 32, 2, 1, denimD)     // the jacket collar
    // The hair: swept up and back, full at the sides.
    c.pattern(17, 20, [
        "......HHHHHHHHHH......",
        "....HHHHHHHHHHHhHH....",
        "...HHHHHHHhHHHHHHhHH..",
        "..HHHHHHHHHHHHHHHHHHH.",
        "..HHHHHHHHHHHHHHHHHHHH",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHH................H.",
        ".HH..................",
    ], ["H": hair, "h": hairL])

    if solo {
        // The guitar slung across him, his left hand up the neck, his right strumming; notes rising off it.
        let red = C(0xB01E24), redL = C(0xD8484A), wood = C(0x5A3A1E)
        cbLine(c, 30, 35, 44, 27, wood, 0.7)
        c.rect(44, 25, 2, 3, C(0x2A1A10))
        c.pattern(21, 33, [".RRRR..", "RRrRRRR", "RRRRRRR", ".RRWRR.", "..RRR.."], ["R": red, "r": redL, "W": C(0xEEE6D0)])
        c.rect(39, 28, 3, 3, denim)
        let strum = Int(p.t * 12) % 2
        c.rect(26, 33 + strum, 3, 3, denim)
        c.rect(15, 33, 3, 3, denim)
        for i in 0..<3 {
            let f = frac(p.t * 0.8 + Double(i) / 3)
            let nx = 44 + i * 5 + Int(f * 4)
            bttfNote(c, nx, 20 - Int(f * 12), (i == 1 ? C(0xFFD25A) : C(0xFFFFFF)).alpha(1 - f))
        }
        return
    }
    c.rect(15, 33, 3, 3, denim)
    // The guitar slung across him; in a fight he strums it and the sound blasts out from its body at the foe.
    let red = C(0xB01E24), redL = C(0xD8484A), wood = C(0x5A3A1E)
    let playing = p.zap != nil   // strumming
    cbLine(c, 30, 35, 44, 27, wood, 0.7)
    c.rect(44, 25, 2, 3, C(0x2A1A10))
    c.pattern(21, 33, [".RRRR..", "RRrRRRR", "RRRRRRR", ".RRWRR.", "..RRR.."], ["R": red, "r": redL, "W": C(0xEEE6D0)])
    c.rect(39, 28, 3, 3, denim)
    c.rect(26, 33 + (playing ? Int(p.t * 12) % 2 : 0), 3, 3, denim)
}

// MARK: - Doc Brawn

/// Doc Brawn: Clawd with a great wild shock of white hair sticking out every way, welding goggles pushed up on his
/// forehead, a long white lab coat (its tails over his legs) over a yellow shirt and a dark tie. In a fight he puts on
/// the brainwave analyser and sends a remote-controlled DeLorean racing at the foe on two trails of fire. Signature: struck by a thought, he claps a hand to his head, eyes wide, the
/// alarm marks going off over him.
private func drawDocBrawn(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0xF0F0EA), coatD = C(0xC4C6C0), shirt = C(0xE8D890), tie = C(0x3A3A48)
    let hair = C(0xF4F4F6), hairD = C(0xB4B8C4), strap = C(0x3A3230), lens = C(0xD89A3A), rim = C(0x6A5A40)
    let sig = p.signature
    let clap = sig.map { $0 > 0.1 && $0 < 0.85 } ?? false

    drawLegs(c, Look(leg: C(0x5A5A62)), step: p.step)
    cbBoots(c, step: p.step, C(0x2A2420), height: 1)
    c.oy += p.breathe
    // The lab coat's tails over his legs.
    let tails = seatedPose ? 1 : 3
    c.rect(17, 37, 22, tails + 1, coat); c.rect(17, 37 + tails, 22, 1, coatD); c.rect(28, 38, 1, tails, coatD)
    drawBody(c, Look(arm: coat), armRight: p.armRaise)
    c.rect(18, 33, 20, 5, coat); c.rect(37, 33, 1, 5, coatD); c.rect(18, 37, 20, 1, coatD)
    c.rect(25, 33, 6, 4, shirt); c.rect(27, 33, 2, 4, tie)
    c.rect(24, 33, 1, 4, coatD); c.rect(31, 33, 1, 4, coatD)       // the lapels
    // The wild hair: a high bald brow at the front, the rest shooting up and back in tufts, out past his ears.
    c.pattern(12, 18, [
        "..H....H...H...H...........",
        ".HH...HH..HHh.HH..H........",
        "HHHH.HHHHHHHHHHH.HH........",
        ".HHHHHHHhHHHHHHHHHHH..H....",
        "HHHHHHHHHHHHHHHHHHHHHHH.H..",
        ".HHHHHhHHHHHHHHHHHHHHHHHH..",
        "HHHHHHHHHHHHHHHH.......HHH.",
        ".HHHHHH.................HHH",
        "HHHHHh..................HH.",
        ".HHHH....................HH",
        "..HH.....................H.",
    ], ["H": hair, "h": hairD])
    // The goggles pushed up on his forehead.
    c.rect(18, 26, 20, 1, strap)
    c.pattern(20, 25, ["RRRR...RRRR..", "RLLR...RLLR..", "RRRR...RRRR.."], ["R": rim, "L": lens])
    c.px(21, 26, C(0xFFE8B0)); c.px(28, 26, C(0xFFE8B0))

    if clap {
        // A hand slapped to the side of his head, eyes popping, alarm marks over him.
        c.rect(14, 26, 4, 8, coat); c.rect(14, 33, 4, 1, coatD); c.rect(16, 24, 4, 3, clawdOrange)
        c.px(19, 23, clawdOrange); c.px(17, 23, clawdOrange)
        c.rect(21, 28, 4, 5, white); c.rect(31, 28, 4, 5, white)
        c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
        let blink = Int(p.t * 6) % 2 == 0
        let mark = C(0xFFE27A)
        c.rect(39, 12, 1, 3, mark); c.px(39, 16, mark)
        if blink {
            c.rect(42, 14, 1, 3, mark); c.px(42, 18, mark)
            c.px(36, 13, mark); c.px(44, 12, mark)
        }
        return
    }
    c.rect(15, 33, 3, 3, coat)
    if p.zap != nil { drawDocGadget(c, p) }
}

/// Doc's kit while he fights: the brainwave analyser on his head (a metal cap bristling with blinking bulbs and wires)
/// and the remote control in his hand, its aerial up and red light blinking, steering a little DeLorean at the foe.
private func drawDocGadget(_ c: PixelCanvas, _ p: Pose) {
    let hy = Int(Sprite.hand.y) - p.armRaise, hx = Int(Sprite.hand.x)
    let metal = C(0xA8AEB8), metalD = C(0x6E747E), wire = C(0xD04A3A)
    c.rect(17, 17, 22, 5, metal); c.rect(19, 15, 18, 2, metal); c.rect(17, 21, 22, 1, metalD)
    c.rect(23, 14, 10, 1, metalD)
    let bulbs = [(18, 16), (22, 13), (27, 12), (32, 13), (37, 16), (20, 18), (35, 18)]
    let cols = [C(0xFF5A4A), C(0x6AFF6A), C(0xFFE04A), C(0x5AB4FF)]
    for (i, b) in bulbs.enumerated() {
        c.px(b.0, b.1 + 1, metalD)
        c.px(b.0, b.1, (Int(p.t * 7) + i) % 3 != 0 ? cols[i % 4] : metalD)
    }
    for (x, y) in [(39, 20), (40, 21), (41, 22), (41, 23), (16, 20), (15, 21)] { c.px(x, y, wire) }
    let blink = Int(p.t * 8) % 2 == 0
    c.rect(hx - 1, hy - 2, 4, 5, C(0x2A2A30)); c.px(hx, hy - 1, blink ? C(0xFF3A2A) : C(0x6A2A2A))
    c.px(hx + 1, hy - 1, C(0x8A8A92))
    for i in 1...6 { c.px(hx + 2, hy - 2 - i, C(0xC8CCD4)) }
    c.px(hx + 2, hy - 9, C(0xE8E8F0))
}

// MARK: - Jennifer Parka

/// Jennifer Parka: Clawd with big 1985 feathered hair, light brown and winged back at the sides down to her shoulders,
/// a lilac top with a mint collar and stone-washed jeans with white flats. She stays out of fights.
private func drawJenniferParka(_ c: PixelCanvas, _ p: Pose) {
    let top = C(0xC6B0E2), topD = C(0x9E86C0), mint = C(0xA8E0C8)
    let hair = C(0xA8743E), hairL = C(0xC8945A), hairD = C(0x7E5428)

    drawLegs(c, Look(leg: C(0x86A2C8)), step: p.step)
    cbBoots(c, step: p.step, C(0xF0EEE8), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: top))
    c.rect(18, 33, 20, 5, top); c.rect(37, 33, 1, 5, topD); c.rect(18, 37, 20, 1, topD)
    c.rect(24, 33, 8, 1, mint); c.rect(26, 34, 4, 1, mint)
    c.px(27, 35, C(0xF4E06A))                                    // a little pendant
    // The feathered hair: lots of volume on top, winged back at the sides.
    c.pattern(14, 18, [
        "........HHHHHHHHH.........",
        "......HHHHHlHHHHHHHH......",
        "....HHHHHHHHHHHlHHHHHH....",
        "...HHHHlHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHHHlHHH.",
        ".HHHHHHHHHHlHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHlHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHdHHH.....HHHH....dHHH",
        "HHHHd.................HHHH",
        ".HHHH..................lHH",
        "HHHH...................HHH",
        ".HHd...................dHH",
        "..H.....................H.",
    ], ["H": hair, "l": hairL, "d": hairD])
    c.rect(15, 33, 3, 3, top); c.rect(38, 33, 3, 3, top)
}

// MARK: - George McFry

/// George McFry: Clawd with neat dark slicked hair parted at the side, big black-rimmed glasses, a mustard argyle
/// sweater vest over a white shirt, and grey slacks. He fights with the one punch. Signature: he winds it up, the arm
/// windmilling round behind him, and lets fly.
private func drawGeorgeMcFry(_ c: PixelCanvas, _ p: Pose) {
    let vest = C(0xC8A040), vestD = C(0x9A7A28), argyle = C(0x6A5A9A), shirt = C(0xF0EEE6)
    let hair = C(0x2A2420), hairL = C(0x4A3E36), rim = C(0x16161B)
    let sig = p.signature

    drawLegs(c, Look(leg: C(0x8A8A86)), step: p.step)
    cbBoots(c, step: p.step, C(0x3A2A1E), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: shirt))
    // The sweater vest, its argyle diamonds, the shirt collar.
    c.rect(18, 33, 20, 5, vest); c.rect(37, 33, 1, 5, vestD); c.rect(18, 37, 20, 1, vestD)
    c.pattern(20, 34, ["..a.....a.....a.", ".a.a...a.a...a.a", "..a.....a.....a."], ["a": argyle])
    c.rect(25, 33, 6, 1, shirt); c.px(27, 34, shirt); c.px(28, 34, shirt)
    // The hair: short, combed flat with a side parting.
    c.pattern(17, 21, [
        ".....HHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHhHH...",
        "..HHHHHHH.HHHHHHHHHH..",
        ".HHHHHHH.HHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HH................HH.",
    ], ["H": hair, "h": hairL])
    // The glasses: two big black frames and the bridge.
    c.pattern(20, 28, ["RRRRRR...RRRRRR", "R....R...R....R", "R....RRRRR....R", "R....R...R....R",
                       "RRRRRR...RRRRRR"], ["R": rim])
    c.rect(21, 29, 4, 1, C(0xDCEAF2, 0.5)); c.rect(30, 29, 4, 1, C(0xDCEAF2, 0.5))

    c.rect(15, 33, 3, 3, shirt)
    if let s = sig, s > 0.05, s < 0.95 {
        // The wind-up: the arm windmills round twice, then the punch goes in.
        let k = (s - 0.05) / 0.9
        if k < 0.65 {
            let a = -90 - k / 0.65 * 720
            let prev = a + 40
            cbPunch(c, angle: a, trail: [prev, prev + 30], arm: shirt, reach: 6)
        } else {
            let f = min(1, (k - 0.65) / 0.1)
            cbPunch(c, angle: -20 + 20 * f, trail: f < 1 ? [-60, -90] : [], arm: shirt, reach: 6 + 3 * f)
            if f >= 1 {
                c.px(52, 31, white); c.px(53, 33, white); c.px(52, 36, white)
            }
        }
        return
    }
    if let a = p.melee {
        cbPunch(c, angle: a, trail: p.trail, arm: shirt)
    } else {
        c.rect(38, 33, 3, 3, shirt)
    }
}

// MARK: - Lorraine Baynes

/// Lorraine Baynes: Clawd in 1955 pink, a full-skirted dress with a white Peter Pan collar, her dark auburn hair
/// curled on top and pulled back into a ponytail tied with a pink ribbon, and saddle shoes. She stays out of fights.
private func drawLorraineBaynes(_ c: PixelCanvas, _ p: Pose) {
    let dress = C(0xF2A2BE), dressD = C(0xD07A9A), collar = C(0xFAF6F0), ribbon = C(0xE85A8A)
    let hair = C(0x6A3420), hairL = C(0x8A4A2E)

    drawLegs(c, Look(), step: p.step)
    if !seatedPose {
        cbBoots(c, step: p.step, C(0xF4F0E8), height: 2)
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.px(lx, lifted ? 41 : 42, C(0x2A2420))                // the saddle
        }
    }
    c.oy += p.breathe
    // The ponytail, hanging down behind.
    c.pattern(12, 21, ["..RR..", ".HHHH.", "HHHHH.", "HHHH..", "HHHH..", ".HHH..", ".HHl..", "..HH..", "..H..."],
              ["H": hair, "l": hairL, "R": ribbon])
    bttfSkirt(c, dress, dressD, length: 5)
    drawBody(c, Look(arm: dress))
    c.rect(18, 33, 20, 4, dress); c.rect(37, 33, 1, 4, dressD)
    c.rect(18, 36, 21, 1, dressD)                                  // the waistline
    c.rect(18, 32, 20, 1, dress)
    c.pattern(23, 33, ["CCC....CCC", ".CCC..CCC."], ["C": collar])
    // The hair: curled on top, swept back to the ponytail.
    c.pattern(16, 20, [
        "......HHHHHHHHHH......",
        "....HHHHlHHHHHHHHH....",
        "...HHHHHHHHHlHHHHHH...",
        "..HHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHlHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHH",
        ".HHH..............HHH.",
        ".HH................H..",
    ], ["H": hair, "l": hairL])
    c.rect(16, 21, 2, 2, ribbon)
    c.rect(15, 33, 3, 3, dress); c.rect(38, 33, 3, 3, dress)
}

// MARK: - Einstein the Dog

/// Einstein the Dog: Clawd as a big shaggy Old English sheepdog, still blocky on his four legs. White fur at the front
/// and a grey saddle over his back and haunch, ragged fur hanging over the tops of his legs, and a big round shaggy
/// white head out in front: a fringe hanging down over his eyes (just peeking through), a long snout with a black nose
/// on the end, and a floppy grey ear. A shaggy tail wagging behind, and a red collar with a gold pocket watch hanging
/// from it. Signature: he lifts the watch up in a paw and checks it, the hand ticking round (the first time
/// traveller, one minute ahead).
private func drawEinsteinDog(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0xF0ECE4), furD = C(0xC4BEB4), strand = C(0xB0AAA0), grey = C(0x8A8682), greyD = C(0x5E5A56)
    let collar = C(0xD02A2A), gold = C(0xE8B830), goldD = C(0x9A7418), nose = C(0x141214), face = C(0xFFFBEA)
    let sig = p.signature
    let checking = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false

    drawLegs(c, Look(leg: fur), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            let foot = lifted ? 42 : 43
            c.rect(lx, foot, 2, 1, furD)                      // the paws
            c.px(lx - 1, foot, fur)                           // shaggy fur round the feet
        }
    }
    c.oy += p.breathe
    // The tail: a shaggy tuft at the back, always wagging (faster when he's happy).
    let speed = (checking || p.cheering || p.ready) ? 12.0 : 5.0
    let wag = Int(p.t * speed) % 2
    if wag == 0 {
        c.pattern(12, 24, ["g..", "gg.", "Ggg", ".GG"], ["g": grey, "G": greyD])
    } else {
        c.pattern(11, 27, ["...", "Ggg", "gGgg", ".gg"], ["g": grey, "G": greyD])
    }
    // The body: white fur, the grey saddle over the back and haunch, ragged at the edges.
    drawBody(c, Look(body: fur, shade: furD, arm: fur, eye: nil))
    c.rect(17, 26, 13, 8, grey); c.rect(17, 34, 6, 2, grey); c.rect(30, 26, 2, 3, grey)
    c.rect(17, 27, 1, 8, greyD)
    c.pattern(17, 25, ["g.g.g.g.g.g.g", ".............."], ["g": grey])
    // Ragged fur hanging over the tops of the legs.
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx - 1, 38, i < 2 ? grey : furD) }
    }
    // The big shaggy head out in front: a fringe over the eyes, the snout and its black nose, a floppy ear.
    c.pattern(27, 14, [
        "....W..W..W...........",
        "...WWW.WWW.WW.........",
        "..WWWWWWWWWWWWW.......",
        ".GWWWWWWWWWWWWWW......",
        "GgWWWWWWWWWWWWWWW.....",
        "GgWWWWWWWWWWWWWWWW....",
        "GgWWWsWWsWWWsWWsWW....",
        "GgWWsWsWWsWsWsWWsWW...",
        "GgWsWWKKsWWsKKsWWWW...",
        "GgWWsWKKWWWWKKWWWWWWNN",
        "GggWWWWWWWWWWWWWWWWNNN",
        "GGgWWWWWWWWWWWWWWWWWNN",
        ".GgWWWWWWWWWWWWWssssss",
        ".GgWWWWWWWWWWWWWWWWWW.",
        ".GG.WWWWWWWWWWWWWWW...",
        "..G.W.WWWWWWWWW.W.W...",
    ], ["W": fur, "s": strand, "g": grey, "G": greyD, "K": ink, "N": nose])
    c.px(47, 23, C(0x6A6468))                                 // the shine on his nose
    // The red collar round his neck, under his chin.
    c.rect(30, 30, 11, 1, collar); c.px(33, 30, fur); c.px(38, 30, fur)

    if checking {
        // The watch lifted up in a paw in front of him, its hand ticking round; he peers down at it.
        let k = sig!
        let up = Int((min(1, (k - 0.08) / 0.15) * 2).rounded())
        let wx = 44, wy = 29 - up
        c.rect(38, 31, 3, 4, fur); c.rect(41, wy + 2, 3, 3, fur); c.rect(40, 31, 2, 2, fur)
        c.pattern(wx, wy - 1, [".GG.", "GwwG", "GwwG", ".GG."], ["G": gold, "w": face])
        c.px(wx + 1, wy - 2, goldD)
        let tick = Int(p.t * 2) % 4
        let hand = [(1, 0), (2, 1), (2, 2), (1, 1)][tick]
        c.px(wx + hand.0, wy + hand.1, ink)
        cbLine(c, 35, 31, Double(wx), Double(wy + 2), gold.alpha(0.8), 0.35)   // the chain
        return
    }
    // The watch hanging from the collar on a short chain.
    c.px(35, 31, goldD)
    c.pattern(34, 32, [".G.", "GwG", ".G."], ["G": gold, "w": face])
}

// MARK: - Clara Clawton

/// Clara Clawton: Clawd in 1885, a high-necked white blouse with a cameo at the throat and puffed sleeves, a long
/// teal skirt down over her legs, button boots below, and her auburn hair pinned up in a bun. She stays out of
/// fights. Signature: she raises her brass telescope to her eye and looks up at the stars, which twinkle.
private func drawClaraClawton(_ c: PixelCanvas, _ p: Pose) {
    let blouse = C(0xF6F2E8), blouseD = C(0xD6D0C2), skirt = C(0x2E6A72), skirtD = C(0x1E4A52)
    let hair = C(0x8A3E22), hairL = C(0xAA5430), brass = C(0xD4A848), brassD = C(0x8A6A28)
    let sig = p.signature
    let looking = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: C(0x3A2A2E)), step: p.step)
    cbBoots(c, step: p.step, C(0x1E1A1C), height: 2)
    c.oy += p.breathe
    bttfSkirt(c, skirt, skirtD, length: 5)
    drawBody(c, Look(arm: blouse))
    // The blouse: high collar, cameo, a skirt waistband.
    c.rect(18, 33, 20, 3, blouse); c.rect(37, 33, 1, 3, blouseD)
    c.rect(25, 32, 6, 1, blouse); c.rect(27, 33, 2, 2, C(0xE8A8A0)); c.px(27, 33, brassD)
    c.rect(18, 36, 21, 1, skirtD)
    // Puffed sleeves.
    c.rect(14, 32, 4, 4, blouse); c.rect(38, 32, 4, 4, blouse)
    c.rect(14, 35, 4, 1, blouseD); c.rect(38, 35, 4, 1, blouseD)
    // The hair, pinned up in a bun at the back.
    c.pattern(15, 18, [
        "..HHHH..................",
        ".HHlHHH.................",
        ".HHHHHHHHHHHHHHHH.......",
        "..HHHHHHHHHHHlHHHHHH....",
        "...HHHHHHlHHHHHHHHHHHH..",
        "...HHHHHHHHHHHHHHHHHHH..",
        "...HHHHHHHHHHHHHHHHHHHH.",
        "...HHHHHHHHHHHHHHHHHHH..",
        "...HHH..............HH..",
        "...HH...............H...",
    ], ["H": hair, "l": hairL])

    if looking {
        // The telescope up to her right eye, angled up at the sky; the stars it finds twinkling.
        let k = sig!
        let rise = min(1, (k - 0.06) / 0.15)
        let tipX = 36 + 12 * rise, tipY = 30 - 12 * rise
        cbLine(c, 33, 30, tipX, tipY, brass, 1.1)
        cbLine(c, 33, 30, 33 + (tipX - 33) * 0.4, 30 + (tipY - 30) * 0.4, brassD, 1.0)
        c.rect(36, 29, 4, 4, blouse); c.rect(38, 26, 3, 3, blouse)
        if rise >= 1 {
            for i in 0..<3 {
                let tw = 0.5 + 0.5 * sin(p.t * 7 + Double(i) * 2.1)
                let sx = 52 + i * 6, sy = 6 + (i % 2) * 5
                c.px(sx, sy, C(0xFFF6C8).alpha(tw))
                if tw > 0.6 { c.px(sx - 1, sy, C(0xFFE27A, 0.6)); c.px(sx + 1, sy, C(0xFFE27A, 0.6)) }
            }
        }
        return
    }
    // At rest: the telescope folded up in her hand.
    c.rect(41, 32, 2, 5, brass); c.px(41, 32, brassD)
}

// MARK: - Goldie Wilsun

/// Goldie Wilsun: Clawd as the 1955 soda-shop waiter, a white paper cap on his short black hair, a white shirt with a
/// black bow tie and a long white apron over grey trousers, his broom to hand. He stays out of fights (he's going to
/// be mayor). Signature: he sweeps the floor in front of him, the broom swishing back and forth and the dust flying.
private func drawGoldieWilsun(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0xB8CCE4), shirtD = C(0x8AA0C0), apron = C(0xFAFAF6), apronD = C(0xD8D8D2)
    let hair = C(0x1A1614), cap = C(0xF6F6F2), capD = C(0xC8C8C4), handle = C(0xA87A44), straw = C(0xD8B860)
    let sig = p.signature
    let sweeping = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false

    drawLegs(c, Look(leg: C(0x6A6A70)), step: p.step)
    cbBoots(c, step: p.step, C(0x1E1A18), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: shirt))
    c.rect(18, 33, 20, 5, shirt); c.rect(37, 33, 1, 5, shirtD); c.rect(18, 37, 20, 1, shirtD)
    // The bow tie and the long apron, tied at the waist and hanging over his legs.
    c.pattern(25, 32, ["BB.BB", "BBBBB", "BB.BB"], ["B": C(0x1A1A1E)])
    c.rect(19, 35, 18, 1, apronD)
    let hang = seatedPose ? 1 : 3
    c.rect(21, 36, 14, 2 + hang, apron); c.rect(21, 37 + hang, 14, 1, apronD); c.rect(34, 36, 1, 2 + hang, apronD)
    // Short black hair under the paper soda-jerk cap.
    c.pattern(17, 20, [
        ".......CCCCCCCC.......",
        ".....CCCCCCCCCCCC.....",
        "....cCCCCCCCCCCCCc....",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HH................HH.",
    ], ["C": cap, "c": capD, "H": hair])
    c.rect(24, 21, 8, 1, C(0xC8303A))                             // the cap's red stripe

    c.rect(15, 33, 3, 3, shirt)
    if sweeping {
        // Both hands on the broom, its head swishing back and forth along the floor; dust kicking up.
        let swish = sin(p.t * 9)
        let hx = 41.0, hy = 31.0
        let bx = 48 + swish * 4, by = 42.0
        cbLine(c, hx, hy, bx, by, handle, 0.6)
        c.rect(38, 30, 3, 3, shirt); c.rect(41, 34, 3, 3, shirt)
        c.rect(Int(bx.rounded()) - 2, 41, 5, 3, straw); c.rect(Int(bx.rounded()) - 2, 41, 5, 1, C(0x8A3A2A))
        for i in 0..<3 {
            let f = frac(p.t * 1.6 + Double(i) / 3)
            let dx = Int(bx.rounded()) + 3 + Int(f * 6) + i, dy = 42 - Int(f * 4)
            c.px(dx, dy, C(0xC8B89A, 0.7 * (1 - f)))
        }
        return
    }
    // The broom held upright at his side.
    c.rect(38, 33, 3, 3, shirt)
    c.rect(41, 22, 1, 18, handle)
    c.rect(39, 40, 5, 4, straw); c.rect(39, 40, 5, 1, C(0x8A3A2A))
}
