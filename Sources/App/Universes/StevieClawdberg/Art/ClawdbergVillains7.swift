import Foundation

// Villains: Hook (Captain Clawd, Mr. Smeeh and Bill Jukes), and the agent-only small fry, who only ever turn up small:
// a Compy, a mogwai pup, a Well of Souls snake, a biology-class frog and the Croc Clock. The pirates are Clawd in
// costume; the creatures are Clawd zipped into a suit of the creature, its head a hood over Clawd's orange face.

let clawdbergVillains7: [ClawdbergVillain: Persona] = [
    .captainClawk: Persona(name: "Captain Clawd", weapon: .saber, headTop: 13, signature: 3.6, callout: "Bad form!",
                           draw: drawCaptainClawk),
    .mrSmeeh: Persona(name: "Mr. Smeeh", headTop: 18, signature: 3.0, callout: "Captain!", draw: drawMrSmeeh),
    .billJukes: Persona(name: "Bill Jukes", weapon: .saber, headTop: 21, draw: drawBillJukes),
    .compy: Persona(name: "A Compy", weapon: .saber, headTop: 20, draw: drawCompy),
    .mogwaiPup: Persona(name: "A mogwai pup", headTop: 23, draw: drawMogwaiPup),
    .snake: Persona(name: "A Well of Souls snake", headTop: 15, draw: drawSnake),
    .frog: Persona(name: "A biology-class frog", headTop: 21, draw: drawFrog),
    .crocClock: Persona(name: "The Croc Clock", headTop: 20, draw: drawCrocClock),
]

// MARK: - Shared bits

private let steel = C(0xD8DEE6), steelD = C(0x8A92A0), gold = C(0xE8B830), goldD = C(0xA87A20)

// MARK: - Captain Clawd

/// Captain Clawd: Clawd in a long crimson coat with gold braid and a white lace jabot, its skirts hanging over the
/// tops of his legs; a huge black curly wig falling in ringlets to his shoulders under a great plumed black hat, a
/// curled black moustache; the silver hook in place of his right hand. He fights with the hook. Signature: a ticking
/// clock stands in front of him; he glares at it, raises the hook and smashes it to pieces, gears and springs flying.
private func drawCaptainClawk(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0xB0202A), coatD = C(0x7A141C), coatL = C(0xD03A3A), wig = C(0x1A1418), wigL = C(0x3A2E36)
    let lace = C(0xF4F0E6), hat = C(0x1E1A1E), plume = C(0xF0ECE4), plumeD = C(0xB8B0A4)
    let sig = p.signature
    let clocking = sig.map { $0 > 0.04 && $0 < 0.96 } ?? false

    drawLegs(c, Look(leg: C(0x2A2228)), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x1A1418), height: 3)
    if clocking { clock(c, p, s: sig!) }
    c.oy += p.breathe
    drawBody(c, Look(arm: coat))
    // The coat: braided fronts, the jabot spilling out, its skirts hanging over his legs.
    c.rect(18, 32, 20, 6, coat); c.rect(37, 32, 1, 6, coatD)
    c.rect(22, 32, 1, 6, gold); c.rect(33, 32, 1, 6, gold)
    c.pattern(26, 34, [".LL.", "LLLL", ".LL.", "LLLL"], ["L": lace])
    for y in [34, 36] { c.px(20, y, gold); c.px(35, y, gold) }
    c.rect(17, 37, 22, 3, coat); c.rect(17, 39, 22, 1, coatD); c.rect(38, 37, 1, 3, coatD)
    c.rect(22, 37, 1, 2, gold); c.rect(33, 37, 1, 2, gold)
    c.px(27, 38, coatD); c.px(28, 39, coatL)
    // The curled moustache.
    c.pattern(21, 31, ["M............M", "MM...MMMM...MM", ".MMMMMMMMMMMM.", "....MM..MM...."], ["M": wig])
    // The wig: ringlets down both sides of his face.
    c.pattern(15, 22, [
        "...WWWWWWWWWWWWWWWWWWW...",
        "..WWwWWWwWWWWWwWWWWwWWW..",
        ".WWWWWWWWWWWWWWWWWWWWWWW.",
        "WWwWWWwWWWWWWWWWWwWWWwWW.",
        "WWWW.................WWWW",
        "WwWW.................WWwW",
        "WWWW.................WWWW",
        "WWwW.................WwWW",
        "WWWW.................WWWW",
        ".WWw.................wWW.",
        "WWW...................WW.",
        "WwW...................wW.",
        ".W.....................W.",
    ], ["W": wig, "w": wigL])
    // The great hat and its plume.
    c.pattern(12, 13, [
        "...........HHHHHHHHH..........",
        ".........HHHHHHHHHHHHH........",
        "PP.....HHHHHHHHHHHHHHHH.......",
        "PPPP...HHHHHHHHHHHHHHHH....GG.",
        ".PpPPP.HHHHHHHHHHHHHHHH...GHH.",
        "..PPPpPPHHHHHHHHHHHHHHH..GHHH.",
        "G..PPPPpPPHHHHHHHHHHHHHHHHHHHG",
        "HG..PPPPPPPPHHHHHHHHHHHHHHHHHH",
        "HHGGGGGGGGGGGGGGGGGGGGGGGGGGHH",
        ".HHHHHHHHHHHHHHHHHHHHHHHHHHHH.",
    ], ["H": hat, "P": plume, "p": plumeD, "G": goldD])

    if clocking {
        let s = sig!
        var a: Double = 60
        var trail: [Double] = []
        if s > 0.2 && s < 0.5 { a = 60 - (s - 0.2) / 0.3 * 170 }          // raising it
        else if s >= 0.5 && s < 0.56 { a = -110 + (s - 0.5) / 0.06 * 165; trail = [a - 40, a - 80] }   // smash
        else if s >= 0.56 { a = 55 }
        hook(c, angle: a, trail: trail, coat: coat)
        return
    }
    if let a = p.melee { hook(c, angle: a, trail: p.trail, coat: coat) }
    else { hook(c, angle: -60, trail: [], coat: coat, reach: 0) }
}

/// The hook on the end of his right arm at `angle`: the red sleeve and lace cuff, the silver shaft, the curl.
private func hook(_ c: PixelCanvas, angle a: Double, trail: [Double], coat: Px, reach: Double = 3) {
    for (i, ta) in trail.enumerated() {
        let e = clawdbergReach(clawdbergHand, ta, reach + 6)
        c.glowLine(e.x, e.y, e.x, e.y, core: steel.alpha(0.3 / Double(i + 1)), glow: steel.alpha(0.2 / Double(i + 1)),
                   coreR: 1, glowR: 2.2)
    }
    if reach > 0 { clawdbergBar(c, (39.5, 34.5), a, from: -1, to: reach, coat, r: 1.3) }
    let cuff = clawdbergReach((39.5, 34.5), a, reach + 0.5)
    clawdbergBar(c, cuff, a + 90, from: -1.6, to: 1.6, C(0xF4F0E6), r: 0.6)
    let base = clawdbergReach((39.5, 34.5), a, reach + 1.5)
    let end = clawdbergReach(base, a, 3.5)
    clawdbergLine(c, base.x, base.y, end.x, end.y, steel, 0.55)
    // The curl: round from the end of the shaft, forward and up and back to its point.
    let o = clawdbergReach(end, a - 90, 2.2)
    var prev = end
    for k in 1...7 {
        let th = (a + 90 - Double(k) * 30) * .pi / 180
        let q = (x: o.x + cos(th) * 2.2, y: o.y + sin(th) * 2.2)
        clawdbergLine(c, prev.x, prev.y, q.x, q.y, k == 7 ? white : steel, 0.5)
        prev = q
    }
    c.px(Int(o.x.rounded()), Int(o.y.rounded()), steelD.alpha(0.5))
}

/// The ticking clock on the deck in front of him at `s` 0…1 through his signature: whole and ticking, then smashed.
private func clock(_ c: PixelCanvas, _ p: Pose, s: Double) {
    let wood = C(0x8A5A2E), woodD = C(0x5A3A1E), face = C(0xF6F0DC)
    let cx = 51, cy = 33
    if s < 0.55 {
        let shake = Int(p.t * 2) % 2 == 0 ? 0 : 1      // tick, tock
        c.pattern(46, 26, [
            "..WWWWWWW..",
            ".WWWWWWWWW.",
            "WWFFFFFFFWW",
            "WFFFFFFFFFW",
            "WFFFFFFFFFW",
            "WFFFFFFFFFW",
            "WFFFFFFFFFW",
            "WFFFFFFFFFW",
            "WWFFFFFFFWW",
            ".WWWWWWWWW.",
            ".WDDDDDDDW.",
            ".WDDDDDDDW.",
            ".WDDDDDDDW.",
            ".WWWWWWWWW.",
            "WWWWWWWWWWW",
            "WDDDDDDDDDW",
            "WW.......WW",
            "WW.......WW",
        ], ["W": wood, "D": woodD, "F": face])
        for (dx, dy) in [(0, -3), (3, 0), (0, 3), (-3, 0)] { c.px(cx + dx, cy - 1 + dy, ink) }
        // Its hands, the second hand jumping on.
        let sec = Double(Int(p.t * 2)) * 30 * .pi / 180
        c.px(cx, cy - 1, ink); c.px(cx, cy - 2, ink)
        c.px(cx + Int((cos(sec) * 2).rounded()), cy - 1 + Int((sin(sec) * 2).rounded()), C(0xC83A3A))
        // The pendulum swinging in its case.
        c.rect(cx - 1 + (shake == 0 ? -1 : 1), 38, 2, 1, gold)
        if shake == 0 { c.px(44, 24, white.alpha(0.6)); c.px(43, 23, white.alpha(0.4)) }
        else { c.px(58, 24, white.alpha(0.6)); c.px(59, 23, white.alpha(0.4)) }
        return
    }
    // Smashed: the case split open on the deck, and gears, springs and glass flying.
    let k = min(1, (s - 0.55) / 0.3)
    c.pattern(46, 38, ["W.....W....", "WD..DDDW..W", "WWWWWWWWWWW", "WDDDDDDDDDW", "WW.......WW", "WW.......WW"],
              ["W": wood, "D": woodD])
    let bits: [(Double, Double, Px)] = [(-1.2, -2.2, gold), (0.8, -2.6, face), (1.6, -1.6, gold), (-0.4, -3, steel),
                                        (2.2, -2.2, woodD), (-1.8, -1.4, face), (0.2, -2, gold)]
    for (i, b) in bits.enumerated() {
        let x = Double(cx) + b.0 * k * 7
        let y = 34 + b.1 * k * 7 + k * k * 12
        guard y < 44 else { continue }
        if i % 3 == 0 { c.pattern(Int(x) - 1, Int(y) - 1, [".G.", "G.G", ".G."], ["G": b.2]) }
        else { c.px(Int(x), Int(y), b.2) }
    }
    if k < 1 {
        // The spring, boinging out.
        for j in 0..<4 { c.px(cx + j % 2, 34 - Int(k * 6) - j, steel) }
    }
}

// MARK: - Mr. Smeeh

/// Mr. Smeeh: a round-faced Clawd in a blue-and-white striped shirt and a baggy red knitted cap with a bobble, little round
/// spectacles perched on his face, a grey beard round his chin, baggy brown breeches. He doesn't fight. Signature: he
/// fusses over his captain, out of breath and bobbing, flicking a clothes brush at the captain's coat (just off to his
/// right) with a sweat drop flying.
private func drawMrSmeeh(_ c: PixelCanvas, _ p: Pose) {
    let stripeA = C(0xF2F2EE), stripeB = C(0x3A5A9A), cap = C(0xC8262A), capD = C(0x8A1A1E)
    let beard = C(0xC8C4BC), wire = C(0x5A4A30), breeches = C(0x7A5A3A)
    let sig = p.signature
    let fussing = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false
    if fussing && Int(p.t * 6) % 3 == 0 { c.oy -= 1 }

    drawLegs(c, Look(leg: breeches), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x2A2018), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: stripeA))
    // The striped shirt and its sleeves.
    for y in 32...37 { c.rect(18, y, 20, 1, y % 2 == 0 ? stripeA : stripeB) }
    c.rect(15, 34, 3, 1, stripeB); c.rect(38, 34, 3, 1, stripeB)
    c.rect(18, 37, 20, 1, breeches)
    // The beard round his chin and the little round spectacles.
    c.pattern(19, 31, ["BB..............BB", ".BBBB.BBBBBB.BBBB.", "..BBBBBBBBBBBBBB.."], ["B": beard])
    c.pattern(20, 28, [".WWWW.....WWWW.", "W....W...W....W", "W....WWWWW....W", "W....W...W....W", ".WWWW.....WWWW."],
              ["W": wire])
    c.rect(21, 29, 4, 3, C(0xE8F4FF, 0.2)); c.rect(31, 29, 4, 3, C(0xE8F4FF, 0.2))
    // The red knitted cap, its floppy top hanging off behind him with a bobble on the end.
    c.pattern(10, 18, [
        "...........KKKKKKKKK.........",
        "....KKKKKKKKKKKKKKKKKKK......",
        "..KKKKKKKKKKKKKKKKKKKKKKK....",
        ".OKKK..KKKKKKKKKKKKKKKKKKKK..",
        "OOO....KKKKKKKKKKKKKKKKKKKKK.",
        ".O.....KKKKKKKKKKKKKKKKKKKKKK",
        ".......DKDKDKDKDKDKDKDKDKDKDK",
        ".......DKDKDKDKDKDKDKDKDKDKDK",
    ], ["K": cap, "D": capD, "O": C(0xF2EEE6)])

    if fussing {
        // The clothes brush flicked at the captain, dust puffing off, a sweat drop.
        let flick = Int(p.t * 10) % 2
        let a: Double = flick == 0 ? -40 : 10
        clawdbergBar(c, clawdbergHand, a, from: -1, to: 4, C(0x8A5A2E), r: 0.7)
        let e = clawdbergReach(clawdbergHand, a, 5)
        c.rect(Int(e.x) - 1, Int(e.y) - 1, 3, 3, C(0x3A2A1E))
        for k in 0..<3 {
            let f = frac(p.t * 2 + Double(k) / 3)
            c.px(Int(e.x) + 2 + Int(f * 5), Int(e.y) - Int(f * 4) + k, C(0xD8D0C0, 1 - f))
        }
        let d = frac(p.t * 1.5)
        c.px(17 - Int(d * 3), 25 + Int(d * 4), C(0x9AD4FF, 1 - d))
        c.px(17 - Int(d * 3), 26 + Int(d * 4), C(0x9AD4FF, 0.6 * (1 - d)))
        return
    }
    if p.ready || p.hit {
        c.rect(38, 30, 3, 3, clawdOrange); c.rect(15, 30, 3, 3, clawdOrange)   // hands up, wringing
    }
}

// MARK: - Bill Jukes

/// Bill Jukes: a bare-chested Clawd tattooed all over in navy blue (anchors, stripes and swirls on his front and arms),
/// a red bandana knotted behind with its tails flying, a gold earring, a rope belt over ragged grey breeches. He fights
/// with a heavy cutlass with a brass guard. No signature.
private func drawBillJukes(_ c: PixelCanvas, _ p: Pose) {
    let ink2 = C(0x2A3A6A), bandana = C(0xB8262A), bandanaD = C(0x7A1A1E), breeches = C(0x6A6A70), rope = C(0xC8A870)
    drawLegs(c, Look(leg: breeches), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.px(lx + (lx % 2), 40, C(0x4A4A52)) } }
    clawdbergBoots(c, step: p.step, C(0x2A2018), height: 2)
    c.oy += p.breathe
    drawBody(c, Look())
    // Tattoos: an anchor in the middle of his chest, swirls and bands round it and on his arms.
    c.pattern(25, 32, ["..I..", ".III.", "..I..", "I.I.I", ".III."], ["I": ink2])
    c.pattern(19, 33, ["I.I", ".I.", "I.I"], ["I": ink2])
    c.pattern(32, 32, ["II..", "I..I", ".II."], ["I": ink2])
    c.rect(15, 34, 3, 1, ink2); c.rect(38, 34, 3, 1, ink2)
    c.px(19, 27, ink2); c.px(20, 28, ink2); c.px(35, 27, ink2); c.px(36, 28, ink2)
    c.rect(18, 36, 20, 1, rope); c.rect(18, 37, 20, 1, breeches)
    // The bandana and its tails, the earring.
    c.pattern(16, 22, [
        "......BBBBBBBBBB......",
        "....BBBBBBBBBBBBBB....",
        "..BBBBBdBBBBBBdBBBBB..",
        "..BBBBBBBBBBBBBBBBBBB.",
        "..DDDDDDDDDDDDDDDDDDD.",
    ], ["B": bandana, "d": bandanaD, "D": bandanaD])
    let flap = Int(p.lt * 3) % 2
    c.pattern(12, 25, flap == 0 ? ["BBBB", "BB.B", "B..."] : ["BBBB", ".BBB", "..B."], ["B": bandana])
    c.px(17, 31, gold); c.px(17, 32, goldD)

    if let a = p.melee {
        cutlass(c, angle: a, trail: p.trail)
    } else {
        // The cutlass stuck through his rope belt at his hip, its brass guard up and the blade down his side.
        c.rect(38, 37, 2, 5, steel); c.px(39, 42, steelD); c.rect(37, 35, 4, 1, gold); c.rect(38, 33, 1, 2, C(0x3A2A1E))
        c.px(36, 34, gold)
    }
}

/// A heavy cutlass: a broad blade curving at its point, a brass knuckle guard.
private func cutlass(_ c: PixelCanvas, angle a: Double, trail: [Double]) {
    clawdbergSmear(c, clawdbergHand, trail, from: 3, to: 13, C(0xE8EEF4))
    clawdbergBar(c, clawdbergHand, a, from: 3, to: 10, steel, r: 0.9)
    let bend = clawdbergReach(clawdbergHand, a, 10)
    clawdbergBar(c, bend, a - 18, from: 0, to: 3.5, steel, r: 0.7)
    clawdbergBar(c, clawdbergHand, a, from: 3, to: 10, steelD, r: 0.3)
    clawdbergBar(c, clawdbergHand, a, from: -1.5, to: 2, C(0x3A2A1E), r: 0.7)
    let g = clawdbergReach(clawdbergHand, a, 2.6)
    clawdbergBar(c, g, a + 90, from: -2.2, to: 1.5, gold, r: 0.55)
    c.rect(39, 33, 3, 3, clawdOrange)
}

// MARK: - The small fry

/// A Compy: a small Clawd in a green compsognathus suit, its dinosaur head a hood over his orange face, the snout
/// jutting out in front over his eyes, a long tail out behind, a paler belly and claws on its little arms. It bites:
/// the snout lunges forward and the jaws snap.
private func drawCompy(_ c: PixelCanvas, _ p: Pose) {
    let green = C(0x6A9A3A), greenD = C(0x4A7228), greenL = C(0x9AC25A), belly = C(0xD8D49A)
    drawLegs(c, Look(leg: green), step: p.step)
    clawdbergBoots(c, step: p.step, greenD, height: 1)
    c.oy += p.breathe
    // The tail, out behind and swishing.
    let swish = Int(p.lt * 3) % 2
    c.pattern(4, 28 + swish, ["..........GGGG", ".....GGGGGGGGG", "GGGGGGGGGGGd..", "dd............"],
              ["G": green, "d": greenD])
    drawBody(c, Look(body: green, shade: greenD, arm: green))
    // The face window and the belly.
    c.rect(20, 27, 16, 6, clawdOrange); c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    c.rect(22, 34, 12, 3, belly)
    c.px(41, 35, white); c.px(41, 33, white)   // claws
    // The hood's head and snout, with the jaw dropping open to bite.
    var open = 0, lunge = 0
    if let a = p.melee, !p.walking {
        if a < -40 { open = 2 } else { lunge = 3 }
    }
    if p.ready { open = Int(p.t * 4) % 2 == 0 ? 2 : 0 }
    c.ox += lunge
    c.pattern(17, 20, [
        "....GGGGGGGGGGG.........",
        "..GGGGGGGGGGGGGGGGG.....",
        ".GGGGGGGGGGGGGGEGGGGGG..",
        "GGGGGGGGGGGGGGGGGGGGGGGG",
        "GGLLLLLLLLLLLLLLLLLLGGGG",
        "GG.................wwwww",
    ], ["G": green, "L": greenL, "E": ink, "w": white])
    if open > 0 { c.rect(36, 25, 5, open, C(0x8A2A2A)) }
    c.pattern(35, 25 + open, ["wwwww", "GGGGGG", ".GGGG."], ["w": white, "G": greenD])
    c.ox -= lunge
}

/// A mogwai pup: a small Clawd in a furry mogwai suit, brown on top with a little tuft, cream fur below, two huge ears
/// sticking out sideways with pink insides; Clawd's orange face in the middle with big round dark eyes. No headband.
private func drawMogwaiPup(_ c: PixelCanvas, _ p: Pose) {
    let brown = C(0x7A5232), brownL = C(0x9A6E44), cream = C(0xF0E6D0), creamD = C(0xCCC0A8), pink = C(0xE89A9A)
    drawLegs(c, Look(leg: cream), step: p.step)
    clawdbergBoots(c, step: p.step, brown, height: 1)
    c.oy += p.breathe
    // The ears, twitching now and then.
    let twitch = Int(p.lt * 1.3) % 4 == 0 ? -1 : 0
    c.pattern(8, 24 + twitch, ["..BBBB....", ".BPPPPBB..", "BPPPPPPBBB", "BPPPPPPBBB", ".BBPPPBBBB", "...BBBBB.."],
              ["B": brown, "P": pink])
    c.pattern(38, 24 + twitch, ["....BBBB..", "..BBPPPPB.", "BBBPPPPPPB", "BBBPPPPPPB", "BBBBPPPBB.", "..BBBBB..."],
              ["B": brown, "P": pink])
    drawBody(c, Look(body: cream, shade: creamD, arm: cream, eye: nil))
    // Brown fur over the top of the head and down the back, a tuft on top.
    c.rect(18, 24, 20, 4, brown); c.rect(18, 28, 3, 4, brown); c.rect(35, 28, 3, 4, brown)
    c.pattern(25, 22, [".B..B", "BbBbB"], ["B": brown, "b": brownL])
    c.rect(24, 26, 8, 1, brownL)
    // The face: orange, with big dark eyes and a glint in each.
    c.rect(21, 28, 14, 6, clawdOrange)
    c.rect(22, 28, 4, 4, ink); c.rect(30, 28, 4, 4, ink)
    c.px(23, 29, white); c.px(31, 29, white)
    c.px(27, 32, C(0x8A4A3A)); c.px(28, 32, C(0x8A4A3A))
    c.rect(18, 36, 20, 1, creamD)
    c.rect(38, 33, 3, 3, brown); c.rect(15, 33, 3, 3, brown)
}

/// A Well of Souls snake: a small Clawd in a brown snake suit, its coils wound round and round his body in banded
/// loops (his orange face peering out over the top coil), the snake's head reared up over him on its neck, forked
/// tongue flicking. Still on his four legs, in brown scaly stockings.
private func drawSnake(_ c: PixelCanvas, _ p: Pose) {
    let scale = C(0x7A5A32), scaleD = C(0x5A3E22), scaleL = C(0xA8844A), belly = C(0xC8B07A)
    drawLegs(c, Look(leg: scaleD), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.px(lx, 39, scale); c.px(lx + 1, 41, scale) } }
    c.oy += p.breathe
    drawBody(c, Look(body: scale, shade: scaleD, arm: scale))
    c.rect(20, 27, 16, 6, clawdOrange); c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    // The coils: three fat banded loops wound round him, overhanging his sides.
    for (i, y) in [31, 34, 37].enumerated() {
        let x0 = 15 + (i % 2) * 2, w = 25 - (i % 2) * 2
        c.rect(x0 + 1, y, w - 2, 1, scaleL)
        c.rect(x0, y + 1, w, 1, scale)
        c.rect(x0 + 1, y + 2, w - 2, 1, scaleD)
        for x in stride(from: x0 + 2 + i * 2, to: x0 + w - 2, by: 5) {
            c.px(x, y + 1, belly); c.px(x + 1, y + 1, scaleD); c.px(x, y, scale)
        }
    }
    // The neck rising from the top coil behind his head, swaying, and the head reared up.
    let sway = sin(p.lt * 2.2) > 0 ? 1 : 0
    c.pattern(14, 15 + sway, [
        "......SSSS....",
        ".....SSSESS...",
        "....SSSSSSSS..",
        "...SSS.SSLL...",
        "..SSS.........",
        ".SSS..........",
        ".SS...........",
        "SSS...........",
        "SS............",
        "SS............",
        "SS............",
        "SSS...........",
        ".SSS..........",
        "..SSS.........",
        "...SSS........",
    ], ["S": scale, "E": C(0xE8C83A), "L": scaleL])
    c.px(15, 20 + sway, scaleL); c.px(14, 23 + sway, scaleL); c.px(14, 26 + sway, scaleL)
    if Int(p.lt * 3) % 3 != 0 {   // the tongue
        c.pattern(22, 17 + sway, ["RR.R", "..R.", "...R"], ["R": C(0xD83A3A)])
    }
}

/// A biology-class frog: a small Clawd in a green frog suit, two big bulging eyes on top of the hood, Clawd's orange
/// face under them, a pale yellow belly, wide webbed feet. Now and then it hops.
private func drawFrog(_ c: PixelCanvas, _ p: Pose) {
    let green = C(0x4AA03A), greenD = C(0x2E7226), greenL = C(0x7AC85A), belly = C(0xE8E49A)
    // The hop: up and down every couple of seconds, legs stretched under it.
    let h = frac(p.lt / 1.8)
    let hopping = !p.seated && h < 0.25
    let up = hopping ? Int((sin(h / 0.25 * .pi) * 5).rounded()) : 0
    c.oy -= up
    drawLegs(c, Look(leg: green), step: p.step)
    if !seatedPose {
        // Webbed feet, splayed.
        for lx in [19, 23, 31, 35] { c.rect(lx - 1, 43, 4, 1, greenD) }
    }
    c.oy += p.breathe
    drawBody(c, Look(body: green, shade: greenD, arm: green))
    c.rect(20, 28, 16, 5, clawdOrange); c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    c.rect(21, 34, 14, 3, belly)
    c.px(20, 27, greenL); c.px(34, 33, greenL); c.px(19, 35, greenD)
    // The bulging eyes on top.
    for x in [18, 30] {
        c.pattern(x, 21, ["..GGGG..", ".GWWWWG.", "GWWKKWWG", "GWWKKWWG", "GGGGGGGG"],
                  ["G": green, "W": C(0xF4F0C8), "K": ink])
    }
    c.rect(40, 35, 2, 1, greenD); c.rect(14, 35, 2, 1, greenD)   // webbed hands
}

/// The Croc Clock: a small Clawd in the stuffed crocodile from Pirate Town's clock tower, dark green and knobbly, its
/// long toothy snout over his orange face like a hood, a stubby tail behind, and a clock face set into its belly whose
/// hand ticks round, the whole croc giving a little jolt with every tick.
private func drawCrocClock(_ c: PixelCanvas, _ p: Pose) {
    let green = C(0x3A6A3A), greenD = C(0x264A28), greenL = C(0x5A8A4A), face = C(0xF6F0DC), brass = C(0xC89A3A)
    let tick = Int(p.t * 2)
    let jolt = frac(p.t * 2) < 0.12 ? 1 : 0
    drawLegs(c, Look(leg: green), step: p.step)
    clawdbergBoots(c, step: p.step, greenD, height: 1)
    c.oy += p.breathe
    c.ox += jolt
    // The stubby tail.
    c.pattern(8, 32, ["......GGGG", "...GGGGGGG", "GGGGGGGGGd", ".d.d..dd.."], ["G": green, "d": greenD])
    drawBody(c, Look(body: green, shade: greenD, arm: green))
    for x in stride(from: 19, through: 36, by: 3) { c.px(x, 27, greenL) }
    c.rect(20, 27, 16, 4, clawdOrange); c.rect(22, 28, 2, 3, ink); c.rect(32, 28, 2, 3, ink)
    // The snout over his head, teeth along the edge, a beady croc eye on top.
    c.pattern(17, 20, [
        "...GG.....GG..............",
        "..GGEG...GEGG.............",
        ".GGGGGGGGGGGGGGGGGGGGGGG..",
        "GGGGGGGGgGGGGGGgGGGGGGGGGG",
        "GGGGGGGGGGGGGGGGGGGGGGGGGG",
        "GGwGwGwGwGwGwGwGwGwGwGwGwG",
    ], ["G": green, "g": greenL, "E": C(0xE8C83A), "w": white])
    // The clock face in its belly, the hand ticking round.
    c.pattern(23, 31, [".BBBBBBBB.", "BFFFFFFFFB", "BFFFFFFFFB", "BFFFFFFFFB", "BFFFFFFFFB", "BFFFFFFFFB", ".BBBBBBBB."],
              ["B": brass, "F": face])
    c.px(27, 32, ink); c.px(27, 36, ink); c.px(24, 34, ink); c.px(31, 34, ink)
    let ang = Double(tick % 12) * 30 * .pi / 180 - .pi / 2
    let hx = 27.5 + cos(ang) * 2, hy = 34 + sin(ang) * 2
    clawdbergLine(c, 27.5, 34, hx, hy, ink, 0.45)
    c.rect(27, 33, 1, 2, C(0xC83A3A))
    if jolt == 1 { c.px(38, 24, white.alpha(0.7)); c.px(40, 23, white.alpha(0.5)) }
    c.ox -= jolt
}
