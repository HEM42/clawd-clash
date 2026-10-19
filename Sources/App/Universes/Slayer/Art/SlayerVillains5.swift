import Foundation

// Villains: henchmen, rivals and monsters of the week, the first seven. Clawd in costume like the rest of the cast:
// hoods, helmets, coats and hats drawn over the blocky body, Clawd's own orange face showing (the Bringer's eyes are
// gone, scarred over, and the Gentlemen's face is chalk white round a huge steel grin). Each one's weapon is held at
// rest as well as in a fight, so nothing appears out of thin air.

let slayerVillains5: [SlayerVillain: Persona] = [
    .bringer: Persona(name: "A Bringer", weapon: .saber, headTop: 20, draw: drawBringer),
    .knightOfByzantium: Persona(name: "A Knight of Byzantium", weapon: .saber, armoured: true, headTop: 19,
                                signature: 3.0, draw: drawKnightOfByzantium),
    .dok: Persona(name: "Dok", weapon: .saber, headTop: 23, signature: 2.8, draw: drawDok),
    .gentlemen: Persona(name: "The Gentlemen", weapon: .saber, motion: .hover, canSit: false, headTop: 22,
                        signature: 3.2, draw: drawGentlemen),
    .andrewWellz: Persona(name: "Andrew Wellz", weapon: .blaster, shot: .ice, muzzle: (48, 31), headTop: 20,
                          signature: 3.4, draw: drawAndrewWellz),
    .ethanRaine: Persona(name: "Ethan Raine", weapon: .lightning, magic: Magic(core: C(0xFF5ADC), glow: C(0xFF8A1E)),
                         pivot: (44.0, 31.5), headTop: 21, signature: 3.4, draw: drawEthanRaine),
    .sweete: Persona(name: "Sweete", weapon: .lightning,
                     magic: Magic(core: C(0xFFE27A), glow: C(0xD0182A), jagged: false, waves: true),
                     pivot: (49.0, 29.5), headTop: 15, signature: 3.6, draw: drawSweete),
]

// MARK: - Shared bits

/// 0…1 through the middle stretch of a signature move (`from`…`to` of it), or -1 outside it.
private func v5Span(_ p: Pose, _ from: Double, _ to: Double) -> Double {
    guard let s = p.signature, s > from, s < to else { return -1 }
    return (s - from) / (to - from)
}

/// 0 at the ends of a 0…1 stretch, 1 through its middle, easing over the first and last `edge` of it.
private func v5Hold(_ k: Double, edge: Double = 0.18) -> Double {
    guard k >= 0 else { return 0 }
    let u = min(1, k / edge, (1 - k) / edge)
    return u * u * (3 - 2 * u)
}

/// A short blade swung along `angle` from the hand: a grip, a steel blade with a bright edge, a smear behind it and
/// the fist round the grip.
private func v5Blade(_ c: PixelCanvas, _ p: Pose, angle a: Double, grip: Px, steel: Px, edge: Px, length: Double,
                     guardCol: Px? = nil, fist: Px = clawdOrange) {
    let h = slayerHand
    slayerSmear(c, h, p.trail, from: 2, to: length + 1, C(0xF0F4FF))
    slayerBar(c, h, a, from: -2, to: 1, grip, r: 1)
    slayerBar(c, h, a, from: 2, to: length + 0.5, steel, r: 0.9)
    slayerBar(c, h, a, from: 2, to: length, edge, r: 0.6)
    if let guardCol {
        let g = slayerReach(h, a, 1.6)
        let g0 = slayerReach(g, a - 90, 2), g1 = slayerReach(g, a + 90, 2)
        slayerLine(c, g0.x, g0.y, g1.x, g1.y, guardCol, 0.6)
    }
    c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, fist)
}

// MARK: - A Bringer

/// A Bringer: one of the First Evil's eyeless priests, in a deep brown hooded robe belted with rope, the hood's
/// shadow round a face whose eyes have been cut out and scarred over, symbols carved into the brow. Bare grey-brown
/// feet. They fight with a short curved dagger, carried point down at their side. No signature: they just wait.
private func drawBringer(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0x6E4A2C), robeD = C(0x4A301A), robeL = C(0x8E6640), rope = C(0xC8A870), shadow = C(0x2E1C10)
    let scar = C(0xE0A07A), scarD = C(0x6A2A1A), carve = C(0x8A2A1E)
    let blade = C(0xC8CCD4), bladeD = C(0x7A808A), grip = C(0x2A1A10)

    drawLegs(c, Look(leg: C(0x7A6050)), step: p.step)
    slayerBoots(c, step: p.step, C(0x5A463A), height: 1)
    // The robe's skirts, to the knees: the four legs still show below its ragged hem.
    if seatedPose {
        c.rect(17, 38, 22, 1, robeD)
    } else {
        c.rect(17, 38, 22, 1, robe); c.rect(17, 38, 1, 1, robeL); c.rect(38, 38, 1, 1, robeD)
        c.pattern(17, 39, ["RR.RRdRR.RRRdR.RRdRR.R"], ["R": robe, "d": robeD])
        c.rect(23, 38, 1, 1, robeD); c.rect(32, 38, 1, 1, robeD)
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: robe, eye: nil))
    // No eyes: two sunken hollows, smooth and dark, a pale scar slashed down through each, and symbols carved
    // into the brow.
    let hollow = C(0xA4502E)
    c.rect(21, 29, 4, 3, hollow); c.rect(31, 29, 4, 3, hollow)
    c.rect(21, 29, 4, 1, scarD); c.rect(31, 29, 4, 1, scarD)
    c.pattern(22, 28, ["S.", "S.", ".S", ".S", ".S"], ["S": scar]); c.pattern(32, 28, [".S", ".S", "S.", "S.", "S."], ["S": scar])
    c.pattern(25, 27, ["c.c..c", ".c..cc"], ["c": carve])
    c.rect(26, 33, 4, 1, C(0x5A2418))
    // The robe over the body and its rope belt.
    c.rect(18, 34, 20, 4, robe); c.rect(37, 34, 1, 4, robeD); c.rect(18, 37, 20, 1, robeD)
    c.rect(18, 36, 20, 1, rope); c.rect(21, 37, 1, 2, rope); c.px(21, 39, C(0xA88A50))
    c.pattern(24, 34, ["L......L", ".L....L."], ["L": robeL])
    // The deep hood: peaked a little, drooping round the face, its brim in shadow.
    c.pattern(15, 20, [
        "........RRRRRRR.........",
        "......RRRRRRRRRRRR......",
        "....RRRLRRRRRRRRRRRR....",
        "...RRRLRRRRRRRRRRRRRR...",
        "..RRRLRRRRRRRRRRRRRRRR..",
        "..RRRRRRRRRRRRRRRRRRRRd.",
        ".RRRRssssssssssssssRRRd.",
        ".RRRRs............sRRRd.",
        ".RRRs..............sRRd.",
        ".RRRs..............sRRd.",
        ".RRRs..............sRRd.",
        ".RRRs..............sRRd.",
        "RRRRs..............sRRRd",
        "RRRR................RRRd",
        "RRRR................RRRd",
        ".RRRR..............RRRd.",
    ], ["R": robe, "L": robeL, "d": robeD, "s": shadow])

    if let a = p.melee {
        v5Blade(c, p, angle: a, grip: grip, steel: bladeD, edge: blade, length: 7)
        let tip = slayerReach(slayerHand, a + 12, 8.2)
        c.px(Int(tip.x.rounded()), Int(tip.y.rounded()), bladeD)                 // the curve at the tip
    } else {
        // The curved dagger held low, point down, in a sleeved fist, a brass guard over the blade; seated, the
        // blade curls forward short of the ground instead of hanging past the folded legs.
        c.rect(39, 35, 3, 2, clawdOrange)
        c.rect(38, 37, 4, 1, C(0xA8884A)); c.px(40, 37, grip)
        if seatedPose {
            c.rect(39, 38, 1, 2, blade); c.rect(40, 38, 1, 2, bladeD); c.px(41, 39, blade); c.px(42, 39, bladeD)
        } else {
            c.rect(39, 38, 1, 4, blade); c.rect(40, 38, 1, 4, bladeD); c.px(40, 42, blade); c.px(41, 42, bladeD)
        }
    }
}

// MARK: - A Knight of Byzantium

/// A Knight of Byzantium: one of the order sworn to destroy the Key, who came after Dawn on the road in "Spiral". A
/// rounded steel helm over a mail coif framing Clawd's face, a hauberk of chain mail on the arms and legs, a crimson
/// tabard with a gold cross, a kite shield on his back arm and a long sword held point down. Armoured, so shots
/// ricochet. Signature: he raises his shield high, a gleam runs across it, and he lowers it again.
private func drawKnightOfByzantium(_ c: PixelCanvas, _ p: Pose) {
    let mail = C(0x9AA0AA), mailD = C(0x6A707A), mailL = C(0xC4CAD2)
    let steel = C(0xA8AEB8), steelD = C(0x6E747E), steelL = C(0xE0E4EA)
    let tabard = C(0xA01C26), tabardD = C(0x6E1018), gold = C(0xE0B040), goldD = C(0xA87A20)
    let raise = Int((v5Hold(v5Span(p, 0.08, 0.92)) * 9).rounded())

    // Mail leggings: light grey links, so the legs read as metal, not stripes.
    drawLegs(c, Look(leg: mail), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            for y in stride(from: 37, through: lifted ? 39 : 40, by: 2) { c.px(lx + (y / 2) % 2, y, mailD) }
        }
    }
    slayerBoots(c, step: p.step, steelD, height: 2)
    // The kite shield on the back arm: crimson, a gold boss and rim. Raised high for the signature.
    c.oy += p.breathe - raise
    c.rect(15, 33, 3, 3, mail)
    c.pattern(9, 28, [
        "gggggggg",
        "gTTTTTTg",
        "gTTTTTdg",
        "gTTggTdg",
        "gTTggTdg",
        "gTTTTTdg",
        "gTTTTddg",
        ".gTTTdg.",
        ".gTTddg.",
        "..gTdg..",
        "...gg...",
    ], ["g": gold, "T": tabard, "d": tabardD])
    c.px(10, 29, C(0xD03A44)); c.px(12, 31, steelL)
    if raise > 6, let s = p.signature {
        // A gleam sliding down across the raised shield.
        let y = 28 + Int(((s - 0.3) / 0.4 * 10).rounded())
        if (28...37).contains(y) { c.rect(10, y, 6, 1, C(0xFFF4D0)) }
    }
    c.oy -= p.breathe - raise
    c.oy += p.breathe
    drawBody(c, Look(arm: mail))
    // The hauberk on the shoulders and sides, the tabard over it with a gold cross, a belt.
    c.rect(18, 34, 20, 4, mail); c.rect(37, 34, 1, 4, mailD)
    for x in stride(from: 18, through: 36, by: 2) { c.px(x + 1, 35, mailD); c.px(x, 36, mailD) }
    c.rect(21, 34, 14, 4, tabard); c.rect(34, 34, 1, 4, tabardD)
    c.rect(27, 34, 2, 4, gold); c.rect(24, 35, 8, 1, gold); c.px(28, 34, C(0xFFE08A)); c.rect(31, 35, 1, 1, goldD)
    c.rect(18, 37, 20, 1, C(0x3A2416)); c.px(28, 37, gold)
    // The tabard's skirt hanging over the tops of the legs.
    c.oy -= p.breathe
    c.rect(21, 38, 14, seatedPose ? 1 : 3, tabard); c.rect(34, 38, 1, seatedPose ? 1 : 3, tabardD)
    if !seatedPose { c.rect(21, 40, 14, 1, tabardD); c.rect(27, 38, 2, 2, goldD) }
    c.oy += p.breathe
    // The helm, rounded, with a brow band; the mail coif under it framing the face down to the shoulders.
    c.pattern(17, 19, [
        ".......SSSSSSSS.......",
        ".....SSlSSSSSSSSS.....",
        "....SSlSSSSSSSSSSS....",
        "...SSlSSSSSSSSSSSSd...",
        "...SSSSSSSSSSSSSSSd...",
        "..bbbbbbbbbbbbbbbbbb..",
        "..mMmMmMmMmMmMmMmMmm..",
        ".mmMm............mMmm.",
        ".mMm..............mMm.",
        ".mmM..............Mmm.",
        ".mMm..............mMm.",
        ".mmM..............Mmm.",
        ".mMm..............mMm.",
        ".mmMm............mMmm.",
        "..mmMmm........mmMmm..",
    ], ["S": steel, "l": steelL, "d": steelD, "b": steelD, "m": mail, "M": mailD])
    c.px(27, 24, gold); c.px(28, 24, gold)
    c.rect(21, 28, 4, 1, C(0x8A3A22)); c.rect(31, 28, 4, 1, C(0x8A3A22))       // a stern brow
    c.rect(26, 33, 4, 1, C(0x6A2418))

    if let a = p.melee {
        // The long sword: a broad steel blade, a gold crossguard.
        v5Blade(c, p, angle: a, grip: C(0x3A2416), steel: steelD, edge: steelL, length: 15, guardCol: gold)
    } else {
        // Held point down by his side: the blade to the ground, the gold crossguard under his fist.
        c.rect(39, 36, 2, 1, C(0x3A2416)); c.px(40, 35, gold)
        c.rect(38, 37, 5, 1, gold)
        let len = seatedPose ? 3 : 6
        c.rect(40, 38, 1, len, steelL); c.rect(41, 38, 1, len - 1, steelD)
        c.rect(39, 34, 3, 2, clawdOrange)
    }
}

// MARK: - Dok

/// Dok: the sweet, doddering old man who runs a little shop of magical knick-knacks and serves Glory. Bald on top,
/// tufts of wispy white hair at the sides, bushy white brows, a mild little smile; a mossy knitted cardigan with
/// buttons over a white shirt and a tiny maroon bow tie, brown trousers. He fights with a long kitchen knife, which
/// he carries even at rest. Signature: something not quite human: a long forked lizard tongue flicks out of his
/// mouth, once, twice, and back in.
private func drawDok(_ c: PixelCanvas, _ p: Pose) {
    let knit = C(0x7A8650), knitD = C(0x58623A), knitL = C(0x9AA670), shirt = C(0xF0EEE6), bow = C(0x7A1E2A)
    let wisp = C(0xF2F0EA), wispD = C(0xC8C4BC), tongue = C(0x8A3A6A), tongueL = C(0xB85A8E)
    let knife = C(0xD8DEE8), knifeD = C(0x8A94A4), grip = C(0x4A2E1A)
    // The tongue: how far out, flicking in and out twice.
    let k = v5Span(p, 0.15, 0.85)
    var reach = 0
    if k >= 0 {
        let f = frac(k * 2)
        reach = Int((sin(min(1, f / 0.8) * .pi) * 14).rounded())
    }

    drawLegs(c, Look(leg: C(0x8A6E50)), step: p.step)
    slayerBoots(c, step: p.step, C(0x4A3020), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: knit, eye: nil))
    // The bald dome rising over the brow, a shine on it.
    c.rect(20, 25, 16, 1, clawdOrange); c.rect(22, 24, 12, 1, clawdOrange); c.px(24, 24, C(0xF4A880))
    c.px(23, 25, C(0xF4A880))
    // Wispy white tufts over the ears, a few strands sticking out.
    c.pattern(15, 25, [
        "..ww",
        ".wWw",
        "wWWW",
        ".wWW",
        "w.WW",
        "..wW",
    ], ["w": wispD, "W": wisp])
    c.pattern(37, 25, [
        "ww..",
        "wWw.",
        "WWWw",
        "WWw.",
        "WW.w",
        "Ww..",
    ], ["w": wispD, "W": wisp])
    // Big bushy white brows, drooping kindly at the outer ends; small twinkling eyes, rosy cheeks, a mild smile
    // (or the mouth open on the tongue).
    c.pattern(20, 27, [".WWWW", "WWWWw", "W...."], ["W": wisp, "w": wispD])
    c.pattern(31, 27, ["WWWW.", "wWWWW", "....W"], ["W": wisp, "w": wispD])
    c.rect(22, 30, 2, 2, ink); c.rect(32, 30, 2, 2, ink); c.px(22, 30, C(0x5A5A66)); c.px(32, 30, C(0x5A5A66))
    c.rect(19, 31, 2, 1, C(0xE88A70)); c.rect(35, 31, 2, 1, C(0xE88A70))
    if reach > 0 {
        c.rect(27, 32, 4, 2, C(0x3A1418))
    } else {
        c.pattern(26, 32, ["M....M", ".MMMM."], ["M": C(0x7A3420)])
    }
    // The cardigan, buttoned, the white shirt and bow tie in its V.
    c.rect(18, 34, 20, 4, knit); c.rect(37, 34, 1, 4, knitD); c.rect(18, 37, 20, 1, knitD)
    for x in [20, 34] { c.rect(x, 34, 1, 3, knitL); c.rect(x + 1, 34, 1, 3, knitD) }   // cable-knit ribs
    c.pattern(24, 34, ["LssbbssL", ".LsbbsL.", "..LssL..", "...LL..."], ["s": shirt, "b": bow, "L": knitL])
    c.px(28, 36, C(0xE8D8A0)); c.px(27, 37, C(0xE8D8A0))                   // big buttons
    c.rect(31, 36, 3, 1, knitD)                                              // a pocket

    if let a = p.melee {
        v5Blade(c, p, angle: a, grip: grip, steel: knifeD, edge: knife, length: 8)
    } else {
        // The big kitchen knife held up, blade to the sky, sweetly, as if showing you what he'd been carving with:
        // a straight spine, the bright edge running up to the point, the wooden handle in his fist.
        c.rect(41, 31, 2, 3, grip); c.px(41, 31, C(0x6A4428))
        c.pattern(41, 23, [".E", "SE", "SE", "SE", "SE", "SE", "SE", "SE"], ["S": knifeD, "E": knife])
        c.rect(40, 33, 3, 3, clawdOrange); c.px(42, 35, C(0xB05A3C))
    }
    if reach > 0 {
        // The lizard tongue: long, thin, forked at the tip, flicking out past the knife in his hand.
        let x1 = 30 + reach
        c.rect(30, 32, reach, 1, tongue); c.rect(30, 32, min(reach, 3), 1, tongueL)
        c.px(x1, 31, tongue); c.px(x1, 33, tongue)
    }
}

// MARK: - The Gentlemen

/// The Gentlemen, from "Hush": tall, bald, chalk-white fairy-tale ghouls who float an inch off the floor, in black
/// Victorian frock coats with long tails, high white collars and white gloves, and a huge fixed grin of steel teeth.
/// Nobody can scream while they're about. They fight with a surgeon's scalpel, held delicately in one gloved hand.
/// Signature: a silent, polite golf clap, the gloved hands patting together without a sound.
private func drawGentlemen(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xEAE8E2), skinD = C(0xC2BEB8), skinL = C(0xFAF8F4), socket = C(0x9A94A0)
    let coat = C(0x18181E), coatD = C(0x0C0C10), coatL = C(0x3A3A46), glove = C(0xF6F6F2), gloveD = C(0xC8C8C4)
    let lip = C(0x2A1E24), tooth = C(0xD4DAE4), toothL = C(0xFFFFFF), gap = C(0x5A606C)
    let blade = C(0xE0E6F0), handle = C(0x9AA2AE)
    let clapK = v5Span(p, 0.1, 0.9)

    // Pinstriped grey trousers, light enough to read under the black coat.
    drawLegs(c, Look(leg: C(0x6A6874)), step: p.step)
    slayerBoots(c, step: p.step, C(0x101014), height: 1)
    c.oy += p.breathe
    // The long tails of the frock coat, hanging behind.
    if !seatedPose { c.rect(14, 34, 4, 8, coat); c.rect(14, 34, 1, 8, coatL); c.rect(15, 41, 3, 1, coatD) }
    drawBody(c, Look(body: skin, shade: skinD, arm: coat, eye: nil), armLeft: clapK >= 0 ? 1 : 0,
             armRight: clapK >= 0 ? 1 : 0)
    // The tall bald skull, rising into a dome, ears a little pointed.
    c.rect(19, 25, 18, 1, skin); c.rect(21, 24, 14, 1, skin); c.rect(24, 23, 8, 1, skin)
    c.rect(22, 24, 3, 1, skinL); c.px(25, 23, skinL); c.rect(36, 25, 1, 1, skinD); c.px(34, 24, skinD)
    c.pattern(16, 28, [".s", "ss", "ss"], ["s": skinD]); c.pattern(38, 28, ["s.", "ss", "ss"], ["s": skinD])
    // Sunken eye sockets with tiny black eyes, a sharp nose ridge.
    c.rect(21, 27, 4, 3, socket); c.rect(31, 27, 4, 3, socket)
    c.px(23, 28, ink); c.px(32, 28, ink)
    c.px(28, 28, skinD); c.px(28, 29, skinD)
    // The grin: ear to ear, upturned at the corners, two rows of big steel teeth with dark gaps between them, so it
    // reads even at agent size (the Silents have no mouth at all).
    c.pattern(18, 29, [
        "LL................LL",
        ".LL..............LL.",
        ".LTTgTTgTTgTTgTTgTL.",
        "..LTTgTTgTTgTTgTTL..",
        "...LLLLLLLLLLLLLL...",
    ], ["L": lip, "T": tooth, "g": gap])
    for x in [20, 23, 26, 29, 32, 35] { c.px(x, 31, toothL) }
    // The frock coat: black, buttoned high, the white wing collar and a black cravat at the throat.
    c.rect(18, 36, 20, 2, coat); c.rect(37, 36, 1, 2, coatD)
    c.pattern(18, 35, ["CCCCCwwwwCCwwwwCCCCC"], ["C": coat, "w": glove])
    c.rect(27, 35, 2, 2, coatD); c.px(23, 37, coatL); c.px(32, 37, coatL)
    // The coat's front skirts over the legs.
    c.oy -= p.breathe
    c.rect(18, 38, 20, seatedPose ? 1 : 3, coat); c.rect(37, 38, 1, seatedPose ? 1 : 3, coatD)
    if !seatedPose { c.rect(27, 38, 1, 3, coatL); c.rect(18, 40, 20, 1, coatD) }
    c.oy += p.breathe

    if clapK >= 0 {
        // Both white gloves out in front of him, past the coat, the back one reaching round to pat the front one,
        // politely, the gap opening and closing; a faint stir of air each time they meet, and no sound.
        let gap = Int((sin(clapK * .pi * 10) + 1).rounded())
        c.rect(38, 33, 6, 3, coat); c.rect(38, 35, 6, 1, coatD)                       // the front sleeve
        c.rect(44, 31, 3, 5, glove); c.rect(46, 32, 1, 4, gloveD)                     // the front glove
        c.rect(30, 36, 9, 1, coatL)                                                   // the back arm, across
        c.rect(41 - gap, 31, 3, 5, glove); c.px(41 - gap, 35, gloveD)                // the back glove
        if gap == 0 {
            for dy in [0, 2, 4] { c.px(48, 31 + dy, white.alpha(0.2)) }
        }
        return
    }
    // The back hand, gloved.
    c.rect(14, 34, 2, 2, glove)
    if let a = p.melee {
        let h = slayerHand
        slayerSmear(c, h, p.trail, from: 2, to: 7, C(0xF0F4FF))
        slayerBar(c, h, a, from: -1, to: 2, handle, r: 0.6)
        slayerBar(c, h, a, from: 2.5, to: 6, blade, r: 0.6)
        c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, glove)
    } else {
        // The scalpel held up delicately between finger and thumb, blade to the sky.
        // A long steel handle and a broad, bright leaf-shaped blade, so it reads at agent size.
        c.rect(41, 28, 1, 5, handle); c.px(42, 28, C(0x6A727E))
        c.pattern(41, 24, [".b", "bB", "bB", "bb"], ["b": blade, "B": C(0xFFFFFF)])
        c.rect(40, 32, 3, 3, glove); c.px(42, 34, gloveD)
    }
}

// MARK: - Andrew Wellz

/// Andrew Wellz: the Trio's youngest, later the self-appointed documentarian of "Storyteller". Floppy blond hair
/// with a fringe, a striped mustard-and-brown jumper, khaki trousers. He fights with his
/// home-made freeze ray, a chrome raygun with blue fins and an icy tip. Signature: he slips the ray into his
/// waistband and films the scene with his camcorder held out at arm's length, the red light blinking.
private func drawAndrewWellz(_ c: PixelCanvas, _ p: Pose) {
    let jumper = C(0xC89A3A), jumperD = C(0x9A7426), band = C(0x6E4A2A)
    let hair = C(0xF0D278), hairL = C(0xFFEEA8), hairD = C(0xC8A44A)
    let chrome = C(0xC8D0DA), chromeD = C(0x7E8896), fin = C(0x3A7ADA), ice = C(0xC8F4FF)
    let filmK = v5Span(p, 0.08, 0.92)

    drawLegs(c, Look(leg: C(0xB0A078)), step: p.step)
    slayerBoots(c, step: p.step, C(0x5A3E26), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: jumper), armRight: filmK >= 0 ? 3 : 0)
    // The jumper: mustard with brown bands, a crew neck.
    c.rect(18, 33, 20, 5, jumper); c.rect(37, 33, 1, 5, jumperD); c.rect(18, 37, 20, 1, jumperD)
    c.rect(18, 35, 20, 1, band); c.rect(18, 37, 20, 1, band)
    c.rect(25, 33, 6, 1, jumperD)
    c.rect(18, 33, 1, 2, C(0xE0B85A)); c.px(18, 36, C(0xE0B85A))              // lit down the near side
    c.rect(22, 33, 1, 2, jumperD); c.rect(34, 33, 1, 2, jumperD)              // folds
    c.rect(26, 32, 4, 1, C(0x8A3A24))                                         // an eager grin
    c.px(25, 31, C(0x8A3A24)); c.px(30, 31, C(0x8A3A24))
    // Floppy blond hair with a side-swept fringe, a few strands loose.
    c.pattern(16, 20, [
        ".......HH.HHHHH.........",
        ".....HHHHHHlllHHHH......",
        "...HHlllHHHHHHHHHHHH....",
        "..HHHHHHHHHHHHHHHHHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHdddHHHHHHHH.",
        ".HHH..HHHHHd.....HHHHH..",
        ".HHH....dd........HHH...",
        "..Hd...............HH...",
        "..d.................d...",
    ], ["H": hair, "l": hairL, "d": hairD])

    if filmK >= 0 {
        // The ray tucked into his waistband, the camcorder held out in front, its screen flipped open.
        c.rect(33, 36, 3, 2, chromeD); c.px(34, 36, fin)
        let bob = Int((sin(filmK * .pi * 3) * 1).rounded())
        c.oy += bob
        c.rect(38, 29, 3, 4, jumper)
        c.pattern(39, 25, [
            "SSKKKKKKK.",
            "SSKKKKKKKL",
            "SSKKKKKKKL",
            "SSKKkkKKK.",
            ".rKKKKKK..",
        ], ["K": C(0x2A2A30), "k": C(0x4A4A54), "S": C(0x6AA0D8), "L": C(0x8ACCF0), "r": C(0x2A2A30)])
        if Int(p.t * 3) % 2 == 0 { c.px(46, 25, C(0xFF3030)) }                 // REC
        c.rect(40, 29, 2, 2, clawdOrange)
        c.oy -= bob
        return
    }
    // The freeze ray in his hand: chrome barrel, blue fins, an icy glow at the tip.
    c.oy += p.gunY
    c.rect(38, 33, 3, 3, jumper)
    c.pattern(39, 29, [
        "..f.f....",
        "SSSSSSSSI",
        "SDDDDDDI.",
        "GG.......",
        "GG.......",
    ], ["S": chrome, "D": chromeD, "f": fin, "I": ice, "G": C(0x2A2A30)])
    c.rect(41, 30, 1, 2, fin)
    c.rect(39, 32, 2, 2, clawdOrange)
    c.oy -= p.gunY
}

// MARK: - Ethan Raine

/// Ethan Raine: Giles's old friend from his Ripper days, a chaos mage who worships Janus. Short swept-back dark hair
/// going grey at the temples, a sly smirk, a black leather jacket over a burgundy shirt, its sleeve pushed back on
/// the Mark of Eyghon tattooed on his forearm. His magic is chaos: jagged magenta lightning with an orange glow.
/// Signature: he holds up the two-faced bust of Janus from "Halloween", and it glows.
private func drawEthanRaine(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x1E1C22), jacketD = C(0x0E0D12), jacketL = C(0x46424E), shirt = C(0x7A1E34), shirtD = C(0x561424)
    let hair = C(0x3A2C24), hairL = C(0x8A847C), grey = C(0xBEBAB2), mark = C(0x4A0618)
    let stone = C(0xE2DCCC), stoneD = C(0xA8A090), stoneL = C(0xFAF6EA)
    let bustK = v5Span(p, 0.08, 0.92)
    let lift = Int((v5Hold(bustK, edge: 0.2) * 7).rounded())

    drawLegs(c, Look(leg: C(0x4A5670)), step: p.step)
    slayerBoots(c, step: p.step, C(0x18161A), height: 2)
    c.oy += p.breathe
    let casting = p.zap != nil || p.ready
    drawBody(c, Look(arm: jacket), armRight: bustK >= 0 ? lift : casting ? 2 + p.armRaise : 0)
    // The smirk, higher on one side.
    c.pattern(26, 32, [".....M", "MMMMM."], ["M": C(0x7A3020)])
    // The leather jacket, open over the burgundy shirt, its collar turned up.
    c.rect(18, 33, 20, 5, jacket); c.rect(37, 33, 1, 5, jacketD); c.rect(18, 37, 20, 1, jacketD)
    c.rect(24, 33, 8, 5, shirt); c.rect(24, 37, 8, 1, shirtD); c.rect(31, 33, 1, 5, shirtD)
    c.rect(23, 33, 1, 5, jacketL); c.rect(32, 33, 1, 5, jacketD)
    c.px(22, 33, jacketL); c.px(33, 33, jacketL)
    // Swept-back salt-and-pepper hair: dark on top, silver streaks combed back through it, and broad silver wings
    // at the temples (Wesley's is dark all over), a widow's peak, a strand out of place.
    c.pattern(17, 21, [
        "......HHHHHHH.H.....",
        "...HHHHsssHHHHHHH...",
        "..HHHHHHHHsssHHHHHH.",
        ".HsssHHHHHHHHsssHHg.",
        ".gHHHHHHHHHHHHHHHggg",
        ".ggg.....H.......ggg",
        ".gg...............gg",
    ], ["H": hair, "s": hairL, "g": grey])
    // The sly brows: the near one level, the far one cocked up.
    c.rect(21, 28, 3, 1, hair); c.rect(32, 27, 3, 1, hair); c.px(31, 28, hair)

    if bustK >= 0 {
        // The forearm up, bared, the Mark on it, and the Janus bust held high on his palm: two bearded faces back
        // to back, one looking each way, their noses jutting out either side, the near face lit and the far one in
        // shade, a seam where the two heads meet.
        let top = 33 - lift
        c.rect(41, top - 2, 3, 6, clawdOrange); c.rect(43, top - 2, 1, 6, C(0xB05A3C))
        c.pattern(41, top + 1, ["m.m", ".m.", "mmm"], ["m": mark])               // the Mark of Eyghon
        c.rect(38, top + 1, 4, 3, jacket)                                         // the sleeve, pushed back
        let y = top - 14
        c.pattern(37, y, [
            "...hhhhh...",
            "..hLLsSSh..",
            ".hLLLsSSSh.",
            ".hkLLsSSkh.",
            "NLLLLsSSSSN",
            "NLLLLsSSSSN",
            ".kkLLsSSkk.",
            ".bbbLsSbbb.",
            "..bbbsbbb..",
            "...bbsbb...",
            ".BBBBBBBBB.",
            "BBBBBBBBBBB",
        ], ["L": stoneL, "S": stone, "s": stoneD, "h": stoneD, "N": C(0x8A8070), "k": C(0x3A342C),
            "b": C(0xA8A090), "B": C(0x7A6A50)])
        if lift > 5 {
            // Chaos stirring round it: a few magenta and orange sparks.
            let i = Int(p.t * 12)
            for k in 0..<3 {
                c.px(35 + Int(noise(i + k * 5) * 14), y - 2 + Int(noise(i * 7 + k) * 9),
                     (k % 2 == 0 ? C(0xFF5ADC) : C(0xFF8A1E)).alpha(0.22))
            }
        }
        return
    }
    if casting {
        // The casting hand out in front, forearm bared on the Mark, crackling.
        let r = 2 + p.armRaise
        c.rect(40, 32 - r, 3, 3, clawdOrange); c.pattern(40, 32 - r, ["m.m", ".m.", "mmm"], ["m": mark])
        c.rect(43, 31 - r, 2, 2, clawdOrange)
        if p.zap == false {
            let i = Int(p.t * 20)
            for k in 0..<3 {
                c.px(42 + Int(noise(i + k) * 4), 28 - r + Int(noise(i * 3 + k) * 4),
                     (k % 2 == 0 ? C(0xFF5ADC) : C(0xFF8A1E)).alpha(0.8))
            }
        }
        return
    }
    // The hand at rest, the sleeve pushed back off a bare forearm with the Mark on it.
    c.rect(40, 33, 4, 3, clawdOrange); c.rect(40, 35, 4, 1, C(0xB05A3C))
    c.pattern(40, 33, ["m.m", ".m.", "mmm"], ["m": mark])
    c.rect(39, 33, 1, 3, jacketL)                                                 // the pushed-back cuff
}

// MARK: - Sweete

/// Sweete: the dancing demon of "Once More, With Feeling", summoned to make Sunnydale sing. A crimson pinstripe
/// suit, a white shirt and a black bow tie, a black top hat with a crimson band, two-tone spats, a gold tooth in a
/// showman's grin and a black cane topped with gold. His magic is the songs: gold waves pulsing out from the tip of
/// his cane. Signature: a little soft-shoe, feet tapping in turn and the cane tapping the floor with them.
private func drawSweete(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0xB0202C), suitD = C(0x761420), suitL = C(0xD84A54), stripe = C(0x8A1822)
    let hat = C(0x1C1A20), hatL = C(0x3E3A44), cane = C(0x1E1C22), knob = C(0xE8C04A), spat = C(0xF0EEE6)
    let danceK = v5Span(p, 0.08, 0.92)
    let tap = danceK >= 0 ? Int(danceK * 8) % 2 : -1
    let step = tap >= 0 ? tap : p.step

    // Crimson trousers with a pinstripe, black shoes under white spats.
    drawLegs(c, Look(leg: suit), step: step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = step >= 0 && i % 2 == step
            c.rect(lx, 36, 1, lifted ? 5 : 6, stripe)
            c.rect(lx, lifted ? 41 : 42, 2, 1, spat)
        }
    }
    slayerBoots(c, step: step, C(0x141216), height: 1)
    if tap >= 0 { c.oy += 1 - tap }                                              // a bounce in his step
    c.oy += p.breathe
    let casting = p.zap != nil || p.ready
    drawBody(c, Look(arm: suit), armRight: casting ? 2 : 0)
    // The showman's grin with its gold tooth.
    c.pattern(25, 31, ["M.....M", ".MWWYM.", "..MMM.."], ["M": C(0x6A1E1A), "W": white, "Y": knob])
    // The suit jacket with pinstripes, a white shirt, a black bow tie, a gold watch chain.
    c.rect(18, 34, 20, 4, suit); c.rect(37, 34, 1, 4, suitD); c.rect(18, 37, 20, 1, suitD)
    for x in [20, 22, 34, 36] { c.rect(x, 34, 1, 3, stripe) }
    c.pattern(24, 34, ["LwbbbbwL", ".LwwwwL.", "..LwwL.."], ["L": suitL, "w": white, "b": hat])
    c.rect(32, 36, 3, 1, knob)
    // The top hat, tall, a crimson band and a wide brim.
    c.pattern(17, 16, [
        ".....HHHHHHHHHHH......",
        ".....HlHHHHHHHHH......",
        ".....HlHHHHHHHHH......",
        ".....HlHHHHHHHHH......",
        ".....HlHHHHHHHHH......",
        ".....rrrrrrrrrrr......",
        ".....rrrrrrrrrrr......",
        ".....HHHHHHHHHHH......",
        "..HHHHHHHHHHHHHHHHH...",
        "HHHHHHHHHHHHHHHHHHHHHH",
    ], ["H": hat, "l": hatL, "r": suit])
    c.rect(17, 26, 21, 1, C(0x8A2A20))                                         // the hat's shadow on the brow

    if casting {
        // The cane held out like a baton, its gold tip pointing where the song goes.
        c.rect(39, 31, 2, 2, clawdOrange)
        slayerLine(c, 38.5, 33, 48.5, 29.5, cane, 0.6)
        c.rect(48, 29, 2, 1, knob)
        return
    }
    // The cane in his hand, its tip on the floor; it taps as he dances.
    let up = tap == 1 ? 2 : 0
    c.oy -= p.breathe
    c.rect(41, 33 - up, 1, seatedPose ? 6 : 10, cane); c.rect(41, 32 - up, 2, 2, knob)
    c.oy += p.breathe
    c.rect(39, 34, 3, 2, clawdOrange)
}
