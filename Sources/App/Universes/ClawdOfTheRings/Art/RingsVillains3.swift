import Foundation

// Villains: the Dark Lord's servants, the king's false counsellor, the orc lieutenant of Mordor and the Dark Tower's
// herald. Clawd in costume, all three: Grep-ma's face is Clawd's orange gone pale and wan, Gothmock's is his own
// lumpy orc hide, and the Mouth of Sourun shows nothing above the grin but black iron. All three stand a Man's height;
// the Mouth's tall helmet takes him higher.

let ringsVillains3: [RingsVillain: Persona] = [
    .wormtongue: Persona(name: "Grep-ma Wormtongue", weapon: .saber, headTop: 22, signature: 3.2,
                         callout: "Psst… I grepped the logs, my lord. They whisper of you.", draw: drawWormtongue),
    .gothmog: Persona(name: "Gothmock", weapon: .saber, bulk: 1, headTop: 21, signature: 2.8,
                      callout: "The age of Men is over. The time of the Mock has come!", draw: drawGothmog),
    .mouthOfSauron: Persona(name: "The Mouth of Sourun", weapon: .saber, headTop: 11, signature: 3.0,
                            callout: "My master Sourun bids you welcome… to the review queue.", draw: drawMouthOfSauron),
]

// MARK: - Grep-ma Wormtongue

/// Grep-ma Wormtongue, the king's counsellor gone bad: hunched a pixel lower than a Man stands, a hump of robe on his
/// back, Clawd's face gone pale and sickly (a wan, greyed orange with dark rings under the eyes), narrow sly eyes under
/// heavy brows and a thin smirk. Greasy black hair hangs lank either side of the face past the shoulders, a sheen on
/// it. Heavy black robes to the ankles, trimmed with dark fur at the collar and the hem. A small dagger, held low and
/// close between fights, with a faint smear behind a quick stab. Signature: "Psst…": he brings his other hand round
/// and rubs the two together, eyes darting sly from side to side and the smirk spreading (…0.45), then whispers,
/// his lips working, little wavy whisper-marks drifting off from his mouth and fading (…0.88).
private func drawWormtongue(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature.flatMap { $0 > 0.03 && $0 < 0.97 ? $0 : nil }
    let rubbing = sig.map { $0 >= 0.08 && $0 < 0.9 } ?? false
    let whispering = sig.map { $0 >= 0.45 && $0 < 0.88 } ?? false
    let pale = C(0xC4A493), paleShade = C(0xA08676), sallow = C(0x8E7A80)
    let robe = C(0x24202A), robeShade = C(0x16141A), robeLight = C(0x3A3542)
    let fur = C(0x3A322A), furLight = C(0x56493C), furDark = C(0x241E18)
    let hair = C(0x0E0E12), sheen = C(0x4E5A6E)
    drawLegs(c, Look(leg: robeShade), step: p.step)
    drawBoots(c, p.step, C(0x0C0B0E), rows: 1)
    c.oy += p.breathe + 1                                                      // hunched: a pixel lower
    // The hump of robe on his back, behind the shoulders.
    c.pattern(13, 23, ["...lll...", "..lRRRl..", ".lRlRRRR.", "lRlRRRRRR", "lRRRRRRRR", "lRRRRRRR.", "lRRRRRR..", "RRRRRR...", "RRRRR...."],
              ["R": robe, "l": robeLight])
    // The pale face, pushed forward.
    c.rect(19, 26, 20, 12, pale)
    c.rect(38, 26, 1, 12, paleShade)
    // Narrow sly eyes under heavy brows that slant down to the middle, dark rings under them, and a thin smirk.
    if let s = sig, rubbing && !whispering {
        // Darting from side to side: half-shut, the pupil to one corner, then the other.
        let look = Int(s * 3.2 * 2.5) % 2 == 0 ? 0 : 1
        c.rect(23, 30, 2, 1, paleShade); c.rect(33, 30, 2, 1, paleShade)
        c.px(23 + look, 30, ink); c.px(33 + look, 30, ink)
    } else {
        c.rect(23, 29, 2, 2, ink); c.rect(33, 29, 2, 2, ink)
    }
    c.rect(22, 28, 2, 1, hair); c.px(24, 28, hair); c.px(25, 29, hair)
    c.rect(34, 28, 2, 1, hair); c.px(33, 28, hair); c.px(32, 29, hair)
    c.rect(23, 31, 2, 1, sallow); c.rect(33, 31, 2, 1, sallow)
    if let s = sig, whispering {
        // Lips working: a little round mouth, and shut again, the smirk at the corner.
        if Int(s * 3.2 * 7) % 2 == 0 { c.rect(29, 32, 2, 2, C(0x2A1A1E)); c.px(31, 31, paleShade) }
        else { c.rect(28, 32, 3, 1, paleShade); c.px(31, 31, paleShade) }
    } else if rubbing {
        c.rect(26, 32, 5, 1, paleShade); c.px(31, 31, paleShade); c.px(25, 31, paleShade)   // the smirk spreading
    } else {
        c.rect(27, 32, 4, 1, paleShade); c.px(31, 31, paleShade)
    }
    // The heavy robe: the body to the ankles, flaring a little, fur at the hem.
    c.rect(18, 33, 21, 5, robe)
    c.rect(38, 33, 1, 5, robeShade)
    for y in 38...42 where y + c.oy <= 43 {
        let k = y - 38, l = 18 - (k + 1) / 2, r = 38 + (k + 1) / 2
        if y == 42 || y + c.oy == 43 {
            c.rect(l, y, r - l + 1, 1, fur)
            for x in stride(from: l + 1, through: r, by: 3) { c.px(x, y, furLight) }
        } else {
            c.rect(l, y, r - l + 1, 1, robe)
            c.px(l, y, robeLight); c.px(r, y, robeShade); c.px(29, y, robeShade)
        }
    }
    // Long hanging sleeves, the back one to below the belt, fur at the cuff (brought round in front to rub his hands).
    if !rubbing { c.rect(14, 33, 4, 5, robe); c.rect(14, 37, 4, 1, fur); c.px(14, 33, robeLight) }
    // The fur collar, heavy across the shoulders.
    c.pattern(16, 32, [
        "..FfFFlFFfFFFFfFFlFFfFFF.",
        ".FFFlFFfFFFlFFFFlFFFfFFFF",
        "..dFF.dFF.FdF.FdF.dFF.d..",
    ], ["F": fur, "f": furDark, "l": furLight, "d": furDark])
    // The greasy black hair, parted in the middle, hanging lank either side of the face past the shoulders.
    c.pattern(17, 21, [
        ".......HHHHHHHHH.......",
        "....HHHsssHHHsssHHH....",
        "..HHHsHHHHHHHHHHHsHHH..",
        ".HHHsHHHHHH.HHHHHHsHHH.",
        ".HHsHHHHHH...HHHHHHsHH.",
        "HHHsHHHH.......HHHHsHHH",
        "HHsHHH...........HHsHHH",
        "HHsH..............HsHHH",
        "HHsH...............sHHH",
        "HHHH................HHH",
        "HHsH................HsH",
        "HHHH................HHH",
        "HHsH................HsH",
        "HHHH................HH.",
        ".HsH................H..",
        ".HH.................H..",
    ], ["H": hair, "s": sheen])
    // The dagger in his fist: tucked low between fights, a faint smear behind a quick stab.
    let angle = p.melee ?? (seatedPose ? 15 : 70)
    drawDagger(c, angle: angle, trail: p.melee == nil ? [] : p.trail)
    c.rect(38, 33, 3, 3, robe); c.rect(40, 33, 2, 3, pale); c.px(40, 35, paleShade)
    if let s = sig, rubbing {
        // The other hand, round in front under his chin, rubbing against the first: up and down and round, its fur
        // cuff behind it. Both hands edged dark so they show against the pale face.
        let a: Double = s * 3.2 * 2 * .pi * 2.2, edge = C(0x2E1C22)
        let hx = 37 + Int((sin(a) * 1.5).rounded()), hy = 34 + Int((cos(a) * 1.2).rounded())
        c.rect(39, 32, 3, 1, edge); c.rect(39, 33, 1, 3, edge); c.rect(40, 36, 2, 1, edge)
        c.rect(hx - 1, hy - 1, 4, 5, edge)
        c.rect(hx - 3, hy, 2, 3, fur); c.px(hx - 3, hy, furLight)
        c.rect(hx, hy, 2, 3, pale); c.px(hx + 1, hy + 2, paleShade); c.px(hx, hy, C(0xE0C4B2))
        c.rect(40, 33, 2, 3, pale); c.px(40, 35, paleShade)                                 // the dagger hand
        if hx + 1 >= 40 { c.px(40, hy + 1, paleShade) }                                    // where they press together
    }
    if let s = sig, whispering {
        // The whisper: little wavy marks drifting off from the mouth, rising a little and fading.
        for i in 0..<3 {
            let k = frac((s - 0.45) * 3.2 / 0.9 + Double(i) / 3)
            let x = 34 + Int(k * 14), y = 30 - Int(k * 6)
            let mark = C(0xF0ECF8, 1 - k * 0.8)
            c.pattern(x, y, [".mm..m", "m..mm."], ["m": mark])
        }
    }
}

/// Grep-ma's dagger in his fist at `angle`: a dark grip, a small brass crossguard and pommel and a thin 8 px blade,
/// with a faint smear along `trail`.
private func drawDagger(_ c: PixelCanvas, angle: Double, trail: [Double]) {
    let h = Sprite.hand, steel = C(0xC8CCD4), brass = C(0x9A8450)
    for (i, a) in trail.enumerated() {
        let v = unit(a)
        c.glowLine(h.x + v.x * 3, h.y + v.y * 3, h.x + v.x * 10, h.y + v.y * 10, core: C(0xE8EEF4), glow: C(0xA8B4C0),
                   coreR: 0.4, glowR: 1.3, strength: 0.3 / Double(i + 1))
    }
    let u = unit(angle), n = (x: -u.y, y: u.x)
    line(c, h.x - u.x * 2, h.y - u.y * 2, h.x + u.x, h.y + u.y, C(0x2A2018), 0.55)                 // the grip
    c.px(Int((h.x - u.x * 2.5).rounded(.down)), Int((h.y - u.y * 2.5).rounded(.down)), brass)      // the pommel
    let g = (x: h.x + u.x * 1.8, y: h.y + u.y * 1.8)
    line(c, g.x - n.x * 1.6, g.y - n.y * 1.6, g.x + n.x * 1.6, g.y + n.y * 1.6, brass, 0.45)       // the crossguard
    line(c, h.x + u.x * 2.5, h.y + u.y * 2.5, h.x + u.x * 10, h.y + u.y * 10, steel, 0.5)          // the blade
}

// MARK: - Gothmock

/// Gothmock, the orc lieutenant: pale, mottled, blotchy orc hide, a bald scalp all lumps with a few lank strands at the
/// back, the face deformed: a swollen lump closing one eye to a slit, the other huge, bulging and bloodshot, and a
/// crooked jaw with snaggle teeth. Badly hunched, a great hump on his back plated in battered, rusted black iron, with
/// dented plate over the chest and a ragged plate skirt. A heavy flanged mace held low in front of him; idle he heaves
/// it up and brings it down, and a swing smears a long way behind it. Signature: "You!": he levels the mace straight
/// out in front of him at you (…0.2), jabbing it twice, and his one good eye bulges bigger and bigger, red veins
/// throbbing round it, the pupil shrinking to a pinpoint (…0.8); then it shrinks back and the mace comes down.
private func drawGothmog(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature.flatMap { $0 > 0.02 && $0 < 0.98 ? $0 : nil }
    let skin = C(0xB4A68E), skinDark = C(0x8C7C66), skinLight = C(0xCCC0A8), blotch = C(0x9A6A58)
    let iron = C(0x34322E), ironDark = C(0x22201E), ironLight = C(0x56524C), rust = C(0x6A4430)
    drawLegs(c, Look(leg: C(0x2E2A26)), step: p.step)
    drawBoots(c, p.step, ironDark, rows: 3)
    c.oy += p.breathe
    // The hump on his back, plated in battered iron, riveted and rusting.
    c.pattern(12, 21, [
        "....PPPP....",
        "..PPPhPPPP..",
        ".PPhPPPPPPP.",
        "PPhPPPrPPPPP",
        "PPPPPPPPPPPd",
        "PoPPPPPoPPPd",
        "PPPPrPPPPPPP",
        "PPPPPPPPPPPP",
        ".PPPPPPPPPPP",
        ".PPPPoPPPPPP",
        "..PPPPPPPPPP",
        "...PPPPPPPPP",
    ],["P": iron, "h": ironLight, "r": rust, "d": ironDark, "o": ironLight])
    // The head and body, pushed forward, in blotchy pale hide; the lumpy bald scalp.
    c.rect(19, 26, 20, 12, skin)
    c.rect(38, 26, 1, 12, skinDark)
    c.pattern(20, 22, [
        "......LL..LLL.....",
        "...LLLlLLLLLlLL...",
        ".LLlLLLLdLLLLLLLL.",
        "LLLLLLLLLLLLLLLLLL",
    ], ["L": skin, "l": skinLight, "d": skinDark])
    for (x, y) in [(23, 24), (29, 23), (34, 25), (27, 28), (36, 33), (21, 34)] { c.px(x, y, blotch) }
    for (x, y) in [(25, 23), (31, 24), (22, 26)] { c.px(x, y, skinDark) }
    c.pattern(19, 23, ["H..", "HH.", ".H.", ".H.", "H..", "H.."], ["H": C(0x4A4642)])   // lank strands at the back
    // The swollen lump over one eye, closing it to a slit.
    c.pattern(20, 27, [".llll.", "lLLLLl", "LLLLLd", "dkkkd."], ["l": skinLight, "L": skin, "d": skinDark, "k": ink])
    // The other eye, huge, bulging, bloodshot, the pupil wandering.
    if let s = sig, s >= 0.22 && s < 0.86 { drawBulgingEye(c, s, skinDark: skinDark) } else { c.pattern(30, 25, [
        "..ddd..",
        ".dEEEd.",
        "dEEErEd",
        "dEEPPEd",
        "dErPPEd",
        ".dEEEd.",
        "..ddd..",
    ], ["d": skinDark, "E": C(0xE8DCA0), "P": ink, "r": C(0xC0503A)]) }
    // The crooked jaw and snaggle teeth.
    c.rect(25, 33, 4, 1, C(0x3A2A22)); c.rect(29, 32, 7, 1, C(0x3A2A22))
    c.px(26, 32, C(0xE8E0C8)); c.px(31, 33, C(0xE8E0C8)); c.px(34, 31, C(0xE8E0C8))
    // Dented, rusted plate over the chest, a ragged skirt below it.
    c.rect(19, 34, 20, 4, iron)
    c.rect(19, 34, 20, 1, ironLight)
    c.rect(38, 34, 1, 4, ironDark)
    for (x, y) in [(23, 35), (30, 36), (35, 35)] { c.px(x, y, ironLight) }
    for (x, y) in [(26, 36), (33, 35), (21, 37)] { c.px(x, y, rust) }
    c.px(28, 35, ironDark); c.px(29, 36, ironDark)                                // a crack
    for x in stride(from: 19, through: 37, by: 3) where 38 + c.oy <= 43 {
        c.rect(x, 38, 2, 1, iron); if x % 2 == 1, 39 + c.oy <= 43 { c.px(x, 39, ironDark) }
    }
    c.rect(15, 33, 4, 3, skin); c.rect(15, 33, 4, 1, iron)
    // A dented pauldron on the front shoulder.
    c.pattern(35, 31, [".PPP.", "PhPPP", "PPrPd", ".Pdd."], ["P": iron, "h": ironLight, "r": rust, "d": ironDark])
    // The mace: held low, heaved up and brought down for the idle flourish, a long smear behind a swing; levelled at
    // you in the signature.
    let angle = sig.map(gothmogPoint) ?? heaved(p, from: 15, by: -105) ?? 15
    var trail = p.melee == nil ? [] : p.trail
    if let h = idlePlay(p), h.kind == .flourish {
        let before: Double = 15 - 105 * habitArc(max(0, h.p - 0.04), hold: 0.2)
        trail = abs(before - angle) > 4 ? [before, before + (before - angle)] : []
    }
    let hand = Sprite.hand
    for (i, a) in heavySmear(angle, trail).enumerated() {
        let u = unit(a), fade: Double = 0.4 * (1 - Double(i) / 12)
        guard fade > 0.03 else { break }
        c.glowLine(hand.x + u.x * 9, hand.y + u.y * 9, hand.x + u.x * 15, hand.y + u.y * 15,
                   core: C(0xC8C4BC), glow: C(0x6A6660, 0.5), coreR: 0.9, glowR: 1.6, strength: fade)
    }
    drawFlangedMace(c, angle: seatedPose && p.melee == nil ? -20 : angle)
    c.rect(38, 33, 3, 3, iron); c.rect(40, 33, 2, 3, skin); c.px(40, 35, skinDark)
}

/// The mace's angle `s` through Gothmock's signature: levelled out in front (…0.2), jabbed at you twice, held, and
/// lowered again from 0.84.
private func gothmogPoint(_ s: Double) -> Double {
    let level: Double = -6
    if s < 0.2 { return 15 + (level - 15) * smooth(s / 0.2) }
    if s >= 0.84 { return level + (15 - level) * smooth((s - 0.84) / 0.12) }
    for j in [0.3, 0.42] where s >= j && s < j + 0.06 { return level + 7 * sin((s - j) / 0.06 * .pi) }
    return level
}

/// Gothmock's good eye in his signature, `s` through it: bulging out of his head, two pixels bigger all round at the
/// most, bloodshot, red veins throbbing round it, the pupil shrunk to a pinpoint that quivers; shrinking back at the end.
private func drawBulgingEye(_ c: PixelCanvas, _ s: Double, skinDark: Px) {
    let white = C(0xE8DCA0), vein = C(0xC0503A)
    let grow = s < 0.3 ? (s - 0.22) / 0.08 : s < 0.5 ? 1 + (s - 0.3) / 0.2 : s < 0.78 ? 2 : 2 - (s - 0.78) / 0.08 * 2
    let r = 3 + Int(grow.rounded()), cx = 33, cy = 28 - Int((grow / 2).rounded())
    c.ellipse(cx, cy, r + 1, r + 1, skinDark)
    c.ellipse(cx, cy, r, r, white)
    // Bloodshot: veins running in from the rim, longer as it swells.
    for (k, a) in [20.0, 115, 200, 290].enumerated() {
        let u = unit(a), len = Double(r) * (0.4 + 0.15 * Double(k % 2)) + grow * 0.3
        for d in stride(from: Double(r) - 0.5, to: Double(r) - 0.5 - len, by: -1) {
            c.px(cx + Int((u.x * d).rounded()), cy + Int((u.y * d).rounded()), vein)
        }
    }
    let quiver = Int(s * 2.8 * 24) % 2
    if grow > 1.5 {
        c.rect(cx + 1 + quiver, cy, 1, 1, ink)                                       // a pinpoint, quivering
        // Throbbing: a red pulse round the rim.
        if Int(s * 2.8 * 6) % 2 == 0 {
            for a in stride(from: 0.0, to: 360, by: 30) {
                let u = unit(a)
                c.px(cx + Int((u.x * Double(r + 2)).rounded()), cy + Int((u.y * Double(r + 2)).rounded()), vein.alpha(0.7))
            }
        }
    } else {
        c.rect(cx + 1, cy, 2, 2, ink)
    }
}

/// Gothmock's mace: a wooden haft with a wrapped grip and a round iron head ringed with flanges, rust on it.
private func drawFlangedMace(_ c: PixelCanvas, angle: Double) {
    prop(c, at: Sprite.hand, angle: angle) { s in
        let wood = C(0x4A3624), woodDark = C(0x33251A), iron = C(0x4A4642), dark = C(0x2A2826), light = C(0x6E6A64)
        let rust = C(0x7A4A2E)
        s.rect(17, 20, 13, 2, wood); s.rect(17, 21, 13, 1, woodDark)        // the haft
        s.rect(18, 19, 3, 4, dark)                                         // the grip's wrapping
        s.pattern(28, 16, [
            "....F....",
            "..FIIIF..",
            ".IILIIIR.",
            "FILIIIIIF",
            "FIIIIRIIF",
            "FIIIIIIDF",
            ".IIIIIDD.",
            "..FDDDF..",
            "....F....",
        ], ["F": light, "I": iron, "L": C(0x8A867E), "D": dark, "R": rust])
    }
}

// MARK: - The Mouth of Sourun

/// The Mouth of Sourun, the Dark Tower's herald: a tall, tapering black-iron helmet, etched with red runes, comes down
/// over the whole upper face, no eyes to be seen; below its rim, cheek guards either side, a huge grin, lips peeled
/// back over two rows of far too many yellowed teeth, with Clawd's orange showing round it. Black robes to the ankles
/// with a red collar, a red panel down the front and red trim at the hem. A long blackened sword with a pale edge, held
/// low between fights, swung with a smear behind a fast stroke. Signature: the grin stretches, a pixel at a time,
/// wider and wider, out past the cheek guards, the corners curling up, the teeth growing longer and more of them
/// showing (…0.72), quivers at its widest, and snaps shut back to its usual size with a jolt and a clack.
private func drawMouthOfSauron(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature.flatMap { $0 > 0.03 && $0 < 0.97 ? $0 : nil }
    let robe = C(0x1A1618), robeShade = C(0x100C0E), robeLight = C(0x2C2628), red = C(0x8A1C1C), redDark = C(0x5E1212)
    let helm = C(0x26262C), helmDark = C(0x16161A), helmLight = C(0x484852), rune = C(0x9A2018)
    let lip = C(0x6A2A22), tooth = C(0xE6DCB8), toothShade = C(0xB0A27C), gap = C(0x1A0A0A)
    drawLegs(c, Look(leg: robeShade), step: p.step)
    c.oy += p.breathe
    if let s = sig, s >= 0.76 && s < 0.84 { c.oy += 1 }                        // the jolt as the grin snaps shut
    drawBody(c, Look(arm: robe, eye: nil))
    // The robe, the collar to the ankles: a red collar, a red panel down the front, flaring to a red-trimmed hem.
    c.rect(18, 36, 20, 2, robe)
    c.rect(17, 36, 22, 1, red)
    for y in 38...42 where y + c.oy <= 43 {
        let k = y - 38, l = 18 - (k + 1) / 2, r = 37 + (k + 1) / 2
        let hem = y == 42 || y + c.oy == 43
        c.rect(l, y, r - l + 1, 1, hem ? red : robe)
        if !hem { c.px(l, y, robeLight); c.px(r, y, robeShade) }
    }
    c.rect(27, 37, 2, max(0, min(5, 43 - c.oy - 37)), redDark)
    c.rect(14, 33, 4, 4, robe); c.rect(14, 36, 4, 1, red)                     // the back sleeve
    // The helmet: a tall black spire, a ridge up the middle, red runes etched round it, the rim and cheek guards.
    c.pattern(16, 11, [
        "...........KK...........",
        "...........KK...........",
        "..........KKKK..........",
        "..........KHKK..........",
        ".........KKHKKK.........",
        ".........KKHKKK.........",
        "........KKKHKKKK........",
        "........KKKHKKKK........",
        ".......KKKKHKKKKK.......",
        ".......KKKKHKKKKK.......",
        "......KKKKKHKKKKKK......",
        "......KKKKKHKKKKKK......",
        ".....KKKKKKHKKKKKKK.....",
        "....KKKKKKKHKKKKKKKK....",
        "...KKKKKKKKHKKKKKKKKK...",
        "..KKKKKKKKKHKKKKKKKKKK..",
        ".KKKKKKKKKKKKKKKKKKKKKK.",
        ".KKKKKKKKKKKKKKKKKKKKKKK",
        ".DDDDDDDDDDDDDDDDDDDDDDD",
        ".DD.................DDD.",
        ".DD.................DD..",
    ], ["K": helm, "H": helmLight, "D": helmDark])
    c.pattern(20, 21, [
        "...R.......R....",
        "..R.R.....R.R...",
        "...R.......R....",
        "...R.......R....",
        "................",
        "R.R.R.R..R.R.R.R",
    ], ["R": rune])
    // The grin: lips peeled back, corners up, two rows of too many teeth.
    if let s = sig {
        drawStretchedGrin(c, s, lip: lip, tooth: tooth, toothShade: toothShade, gap: gap)
    } else { c.pattern(20, 30, [
        "L..............L",
        "LLLLLLLLLLLLLLLL",
        "LTsTsTsTsTsTsTTL",
        "LggggggggggggggL",
        "LTsTsTsTsTsTsTTL",
        ".LLLLLLLLLLLLLL.",
    ], ["L": lip, "T": tooth, "s": toothShade, "g": gap]) }
    // The sword, a smear behind a fast stroke.
    let angle = p.melee ?? (seatedPose ? 8 : 32)
    for (i, a) in (p.melee == nil ? [] : p.trail).enumerated() {
        let u = unit(a)
        c.glowLine(Sprite.hand.x + u.x * 4, Sprite.hand.y + u.y * 4, Sprite.hand.x + u.x * 17, Sprite.hand.y + u.y * 17,
                   core: C(0xD8C8C8), glow: C(0x8A2A2A), coreR: 0.6, glowR: 1.8, strength: 0.32 / Double(i + 1))
    }
    drawBlackSword(c, angle: angle, red: red)
    c.rect(38, 33, 3, 3, robe); c.rect(40, 33, 2, 3, clawdOrange); c.px(40, 35, clawdShade)
}

/// The Mouth's grin `s` through his signature. At its usual size it's the grin he always wears: corners, a top lip, a
/// row of teeth, the dark gap, a row of teeth and the bottom lip, 16 wide from x 20. Stretched (…0.72) it widens a
/// pixel each side at a time to 24, the corners curl two pixels higher, and the teeth grow to two pixels long; it
/// quivers at its widest, then snaps back (0.76), the head jolting down a pixel and a clack flashing off the corners.
private func drawStretchedGrin(_ c: PixelCanvas, _ s: Double, lip: Px, tooth: Px, toothShade: Px, gap: Px) {
    var k: Double = s < 0.1 ? 0 : s < 0.72 ? smooth((s - 0.1) / 0.62) : s < 0.76 ? 1 : 0
    if s >= 0.66 && s < 0.76 && Int(s * 3 * 20) % 2 == 0 { k -= 0.12 }          // quivering, straining
    let snap = s >= 0.76 && s < 0.84
    let half = 8 + Int((4 * k).rounded()), rise = 1 + Int((2 * k).rounded()), teeth = 1 + Int(k.rounded())
    let l = 28 - half, r = 27 + half
    var y = 30
    for j in 0..<rise { c.px(l, y - j, lip); c.px(r, y - j, lip) }               // the corners, curling up
    if rise > 1 { c.px(l + 1, y - rise + 1, lip); c.px(r - 1, y - rise + 1, lip) }
    y += 1
    c.rect(l, y, r - l + 1, 1, lip); y += 1                                    // the top lip
    func row() {
        c.px(l, y, lip); c.px(r, y, lip)
        for x in (l + 1)..<r { c.px(x, y, x == r - 1 || (x - l) % 2 == 1 ? tooth : toothShade) }
        y += 1
    }
    for _ in 0..<teeth { row() }
    c.px(l, y, lip); c.px(r, y, lip); c.rect(l + 1, y, r - l - 1, 1, gap); y += 1
    for _ in 0..<teeth { row() }
    c.rect(l + 1, y, r - l - 1, 1, lip)                                        // the bottom lip
    if snap {
        // The clack: short white strokes flashing off the corners.
        for (x, dir) in [(l - 1, -1), (r + 1, 1)] {
            c.px(x, 31, C(0xFFFFFF, 0.8)); c.px(x + dir, 30, C(0xFFFFFF, 0.6)); c.px(x + dir, 33, C(0xFFFFFF, 0.6))
        }
    }
}

/// The Mouth's long sword: a black grip with a red pommel stone, a black crossguard tipped in red, and a long
/// blackened blade with a pale edge and a clipped point.
private func drawBlackSword(_ c: PixelCanvas, angle: Double, red: Px) {
    prop(c, at: Sprite.hand, angle: angle) { s in
        let blade = C(0x4A4E58), edge = C(0xB8BCC6), guardIron = C(0x2A2A30)
        s.rect(17, 20, 4, 1, C(0x1E1618)); s.px(16, 20, red)                  // the grip and pommel
        s.rect(21, 18, 1, 5, guardIron); s.px(21, 18, red); s.px(21, 22, red)  // the crossguard
        s.rect(22, 19, 14, 2, blade)
        s.rect(22, 21, 13, 1, edge)
        s.px(36, 20, blade); s.px(35, 21, edge); s.px(36, 21, edge)
    }
}

// MARK: - Shared helpers

private let clear = C(0x000000, 0)

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

/// A solid pixel line (no glow), `r` its half-width.
private func line(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.7) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: clear, coreR: r, glowR: r + 0.1)
}

private func unit(_ degrees: Double) -> (x: Double, y: Double) {
    let r: Double = degrees * .pi / 180
    return (cos(r), sin(r))
}

/// The idle habit playing now, if this pose is the one it's played in (idle, standing, not fighting).
private func idlePlay(_ p: Pose) -> HabitPlay? {
    guard !p.walking, p.mode == .idle, let h = idleHabit else { return nil }
    switch p.role { case .none, .rest: return h; default: return nil }
}

/// A heavy weapon's idle flourish: heaved from `from` degrees through `by` degrees and back, instead of spun round.
private func heaved(_ p: Pose, from: Double, by: Double) -> Double? {
    guard let h = idlePlay(p), h.kind == .flourish else { return p.melee }
    return from + by * habitArc(h.p, hold: 0.2)
}

/// The angles a heavy swing smears through: from now back past `trail`'s last angle by half as far again, so the smear
/// is longer than a sword's (the weapon looks slower, heavier). Empty when it isn't being swung fast.
private func heavySmear(_ now: Double, _ trail: [Double]) -> [Double] {
    guard let last = trail.last else { return [] }
    let end: Double = last + (last - now) * 0.5
    let n = max(2, Int((abs(end - now) / 5).rounded()))
    return (1...n).map { (i: Int) -> Double in now + (end - now) * Double(i) / Double(n) }
}

/// A prop drawn pointing right from pixel (20, 20) of a scratch canvas, turned to `angle` degrees (0 forward, -90 up)
/// and placed with that point on `at`.
private func prop(_ c: PixelCanvas, at: (x: Double, y: Double), angle: Double, alpha: Double = 1, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(41, 41)
    art(s)
    let r = s.rotated(angle, about: (20.5, 20.5), into: 41, 41, at: (20.5, 20.5))
    let x0 = Int(floor(at.x - 20.5)), y0 = Int(floor(at.y - 20.5))
    for y in 0..<r.h {
        for x in 0..<r.w {
            let i = (y * r.w + x) * 4
            guard r.buf[i + 3] > 0 else { continue }
            c.px(x0 + x, y0 + y, unpremultiplied(r, i).alpha(alpha))
        }
    }
}

private func unpremultiplied(_ s: PixelCanvas, _ i: Int) -> Px {
    let a = s.buf[i + 3], m = 255 / Double(a)
    return Px(r: UInt8(min(255, Double(s.buf[i]) * m)), g: UInt8(min(255, Double(s.buf[i + 1]) * m)),
              b: UInt8(min(255, Double(s.buf[i + 2]) * m)), a: a)
}

/// Smoothstep: 0→1 eased at both ends.
private func smooth(_ x: Double) -> Double {
    let u = min(1, max(0, x))
    return u * u * (3 - 2 * u)
}
