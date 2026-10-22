import Foundation

// Heroes: Jurassic Park. Clawd in costume like the rest of the cast: hats, hair and field clothes drawn over the blocky
// body, with Clawd's own orange face showing. The two dinosaurs on the heroes' side (Blue the raptor and the sick
// triceratops) are Clawd in a dinosaur suit, still blocky and still on four legs.

let clawdbergHeroes5: [ClawdbergHero: Persona] = [
    .alanGrand: Persona(name: "Alan Grand", weapon: .blaster, shot: .bullet, muzzle: (54, 31), headTop: 20,
                        signature: 3.4, draw: drawAlanGrand),
    .ellieSaddler: Persona(name: "Ellie Saddler", headTop: 21, signature: 3.4, draw: drawEllieSaddler),
    .ianMalclawm: Persona(name: "Ian Malclawd", weapon: .blaster, shot: .thrown(C(0xFF8A1A)), muzzle: (44, 28),
                          headTop: 20, signature: 3.0, callout: "Life, uh, finds a way", draw: drawIanMalclawm),
    .johnHammend: Persona(name: "John Hammend", headTop: 20, signature: 3.2, callout: "Spared no expense",
                          draw: drawJohnHammend),
    .muldune: Persona(name: "Muldune", weapon: .blaster, shot: .bullet, muzzle: (54, 31), headTop: 20,
                      signature: 3.2, callout: "Clever girl…", draw: drawMuldune),
    .timMurphey: Persona(name: "Tim Murphey", headTop: 21, signature: 3.2, draw: drawTimMurphey),
    .lexMurphey: Persona(name: "Lex Murphey", headTop: 20, signature: 3.0, callout: "It’s a Unix system!",
                         draw: drawLexMurphey),
    .rayArnie: Persona(name: "Ray Arnie", headTop: 22, signature: 3.0, callout: "Hold on to your butts",
                       draw: drawRayArnie),
    .owenGravy: Persona(name: "Owen Gravy", weapon: .blaster, shot: .bullet, muzzle: (58, 31), headTop: 21,
                        signature: 3.2, callout: "Eyes on me!", draw: drawOwenGravy),
    .claireDaring: Persona(name: "Claire Daring", weapon: .blaster, shot: .thrown(C(0xFF2A2A)), muzzle: (44, 28),
                           headTop: 20, signature: 3.2, draw: drawClaireDaring),
    .blue: Persona(name: "Blue", weapon: .saber, headTop: 18, signature: 2.8, draw: drawBlue),
    .trike: Persona(name: "Trike", weapon: .saber, pivot: (36, 26), bulk: 4, headTop: 13, signature: 3.4,
                    draw: drawTrike),
]

// MARK: - Shared bits

/// A pump shotgun held level at the hip in the right hand, its muzzle at (54, 31): the stock under the arm, the dark
/// receiver and barrel, the pump slide under the barrel.
private func drawShotgun(_ c: PixelCanvas, sleeve: Px, metal: Px, stock: Px) {
    c.rect(38, 33, 3, 3, sleeve)
    c.pattern(33, 31, [
        ".......MMMMMMMMMMMMMM",
        "SS.....MMMMSSSSS.....",
        "SSSSSSSMMM...........",
        ".SSSS................",
    ], ["M": metal, "S": stock])
    c.px(40, 34, clawdOrange)
}

/// A lever-action rifle held level at the hip, its muzzle at (58, 31): a long dark barrel, the wooden forestock and
/// stock, the lever loop under the receiver.
private func drawRifle(_ c: PixelCanvas, sleeve: Px) {
    let metal = C(0x2A2A2E), wood = C(0x7A4A26)
    c.rect(38, 33, 3, 3, sleeve)
    c.pattern(34, 31, [
        "......MMMMMMMMMMMMMMMMMM",
        "WW....MMMM.WWWWWWW......",
        "WWWWWWMMM...............",
        ".WWWW..MM...............",
    ], ["M": metal, "W": wood])
    c.px(40, 34, clawdOrange)
}

/// A road flare held from (`x`, `y`) out along `angle` degrees: a 5 px stick, and when `lit`, its burning tip with a
/// hot glow in `glow` and sparks spitting off it.
private func drawFlare(_ c: PixelCanvas, x: Double, y: Double, angle: Double, lit: Bool, t: Double, glow: Px,
                       stick: Px, big: Bool = false) {
    let tip = clawdbergReach((x, y), angle, 5)
    clawdbergLine(c, x, y, tip.x, tip.y, stick, 0.6)
    guard lit else { return }
    let i = Int(t * 24)
    let flick = noise(i) * 0.8
    let glowR: Double = (big ? 4.2 : 3.0) + flick
    c.glowLine(tip.x, tip.y, tip.x, tip.y, core: C(0xFFF6D0), glow: glow, coreR: 0.9, glowR: glowR)
    for k in 0..<3 {
        let sx = tip.x + (noise(i * 3 + k) - 0.5) * 7
        let sy = tip.y - noise(i * 5 + k) * 5
        c.px(Int(sx.rounded()), Int(sy.rounded()), C(0xFFE27A, 0.9))
    }
}

/// Three hooked claws fanned out from `h` along `angle`, `len` pixels long.
private func drawTalons(_ c: PixelCanvas, _ h: (x: Double, y: Double), angle: Double, len: Double, _ col: Px,
                        alpha: Double = 1) {
    for k in -1...1 {
        let a = angle + Double(k) * 28
        clawdbergBar(c, h, a, from: 0, to: len, col.alpha(alpha), r: 0.5)
    }
}

/// Clawd's short sleeves: the top row of each arm nub in the shirt, the rest bare.
private func drawShortSleeves(_ c: PixelCanvas, _ shirt: Px) {
    c.rect(15, 33, 3, 1, shirt); c.rect(38, 33, 3, 1, shirt)
}

// MARK: - Alan Grand

/// Alan Grand: Clawd in a wide-brimmed tan hat with a brown band, dark sunglasses, a blue denim shirt with a red
/// neckerchief knotted at the throat, khaki trousers and brown boots; a pump shotgun at the hip. Signature: he takes
/// off his sunglasses and stares up, wide-eyed and open-mouthed, at something very big.
private func drawAlanGrand(_ c: PixelCanvas, _ p: Pose) {
    let denim = C(0x5A7AA8), denimD = C(0x3E5A86), scarf = C(0xC83A2A), scarfD = C(0x8E2618)
    let hat = C(0xC8AA78), hatD = C(0x9A8058), band = C(0x5A3A22), shades = C(0x1A1A20)
    let sig = p.signature
    let bare = sig.map { $0 > 0.2 && $0 < 0.84 } ?? false
    let reaching = sig.map { ($0 > 0.05 && $0 <= 0.2) || ($0 >= 0.84 && $0 < 0.95) } ?? false

    drawLegs(c, Look(leg: C(0xB8A57A)), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x5A3E26), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: denim, eye: nil))
    // The denim shirt, its placket and a pocket; the red neckerchief knotted at the throat.
    c.rect(18, 33, 20, 5, denim); c.rect(37, 33, 1, 5, denimD); c.rect(18, 37, 20, 1, denimD)
    c.rect(28, 35, 1, 2, denimD); c.rect(21, 35, 3, 1, denimD)
    c.pattern(20, 33, ["RRRRRRRRRRRRRRRR", "......RrRR......", ".......RR......."], ["R": scarf, "r": scarfD])
    // The wide-brimmed hat.
    c.pattern(14, 20, [
        "........FFFFFFFFFFFF........",
        ".......FFFFFdFFFFFFFF.......",
        ".......FFFFFFFFFFFFFF.......",
        ".......BBBBBBBBBBBBBB.......",
        "..FFFFFFFFFFFFFFFFFFFFFFFF..",
        "FFFFFFFFFFFFFFFFFFFFFFFFFFFF",
        "dd........................dd",
    ], ["F": hat, "d": hatD, "B": band])

    if bare {
        // Glasses off and down in his hand; eyes up, mouth open.
        c.rect(22, 28, 2, 2, ink); c.rect(32, 28, 2, 2, ink)
        c.px(23, 28, white); c.px(33, 28, white)
        c.rect(27, 31, 2, 1, C(0x6A2A1E))
        c.rect(38, 33, 3, 3, denim)
        c.rect(40, 36, 4, 1, shades); c.px(41, 37, shades); c.px(43, 37, shades)
        return
    }
    // The sunglasses.
    c.pattern(21, 29, ["SSSSssssssSSSS", "SgSS......SgSS", ".SS........SS."], ["S": shades, "s": shades, "g": C(0x5A6A84)])
    if reaching {
        // A hand up at the glasses.
        c.rect(38, 28, 3, 6, denim); c.rect(36, 28, 2, 2, clawdOrange)
        return
    }
    c.oy += p.gunY
    drawShotgun(c, sleeve: denim, metal: C(0x2E2E34), stock: C(0x7A4A26))
}

// MARK: - Ellie Saddler

/// Ellie Saddler: Clawd with dark-blonde hair tied back in a ponytail, a peach shirt with its sleeves rolled and its
/// tails knotted at the waist over khaki shorts, white socks and brown hiking boots. She doesn't fight. Signature: she
/// grabs the handle of a big circuit breaker and heaves it up, straining, until it clunks home with a spark and the
/// green light comes on.
private func drawEllieSaddler(_ c: PixelCanvas, _ p: Pose) {
    let peach = C(0xF8D0B0), peachD = C(0xD8A888), khaki = C(0xC4AE7E), khakiD = C(0x9E8A5E)
    let hair = C(0xD8AA52), hairD = C(0xAE8436), hairL = C(0xEEC872)
    let sig = p.signature
    let heaving = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, lifted ? 37 : 38, 2, 2, khaki)
        }
    }
    clawdbergBoots(c, step: p.step, white, height: 3)
    clawdbergBoots(c, step: p.step, C(0x6A4A2E), height: 2)
    c.oy += p.breathe
    // The ponytail, behind.
    c.pattern(12, 23, ["...HHH", "..HHHh", ".HHHH.", ".HHh..", "HHH...", "HH....", "H....."],
              ["H": hair, "h": hairD])
    c.px(17, 24, C(0x8A3A3A))
    drawBody(c, Look(arm: clawdOrange))
    drawShortSleeves(c, peach)
    // The peach shirt, the shorts' waistband below it, and the knot at the front with its two tails.
    c.rect(18, 33, 20, 3, peach); c.rect(37, 33, 1, 3, peachD)
    c.rect(18, 36, 20, 2, khaki); c.rect(18, 37, 20, 1, khakiD); c.rect(37, 36, 1, 2, khakiD)
    c.pattern(25, 34, [".PPPP.", "PPdPPP", ".PpP..", ".P..P."], ["P": peach, "d": peachD, "p": peachD])
    // Her hair, swept back to the tie.
    c.pattern(17, 21, [
        "......HHHHHHHHH......",
        "...HHHHHHHHHHHHHHH...",
        "..HHHHHlHHHHHHHHHHH..",
        ".HhHHHHHHlHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHH",
        "HHHH.HH...........HHH",
        "HH.................HH",
    ], ["H": hair, "h": hairD, "l": hairL])

    guard heaving, let s = sig else { return }
    // The breaker: a grey box on a post, its handle swinging up from down (90°) to up (-75°).
    let box = C(0x6E7468), boxD = C(0x4E544A), hazard = C(0xE8C030)
    let up = min(1, max(0, (s - 0.12) / 0.5))
    let ease = up * up * (3 - 2 * up)
    let shake = up > 0 && up < 1 ? (noise(Int(p.t * 30)) > 0.5 ? 1.0 : -1.0) : 0
    let angle = 90 - ease * 165 + shake * 3
    c.rect(46, 24, 9, 14, box); c.rect(54, 24, 1, 14, boxD); c.rect(46, 37, 9, 1, boxD)
    c.rect(50, 38, 2, 6, boxD)
    for x in stride(from: 46, to: 55, by: 2) { c.px(x, 24, hazard) }
    c.px(52, 26, up >= 1 ? C(0x5AF07A) : C(0x2E4A32))
    if up >= 1 { c.glowLine(52.5, 26.5, 52.5, 26.5, core: C(0xB8FFC8), glow: C(0x5AF07A), coreR: 0.5, glowR: 2) }
    let pivot = (x: 47.5, y: 31.5)
    let grip = clawdbergReach(pivot, angle, 7)
    clawdbergBar(c, pivot, angle, from: 0, to: 7, C(0x2A2A2E), r: 0.7)
    c.rect(Int(grip.x.rounded()) - 1, Int(grip.y.rounded()) - 1, 3, 2, C(0xC83A2A))
    // Both arms on the handle.
    clawdbergLine(c, 39.5, 33.5, grip.x - 1, grip.y + 0.5, clawdOrange, 1.1)
    clawdbergLine(c, 36.5, 34.5, grip.x - 1, grip.y + 1.5, clawdOrange, 1.0)
    c.rect(38, 33, 3, 1, peach)
    if s > 0.6 && s < 0.7 {   // the clunk
        let i = Int(p.t * 30)
        for k in 0..<3 { c.px(48 + Int(noise(i + k) * 5), 27 + Int(noise(i * 2 + k) * 4), C(0xFFF0A0)) }
    }
}

// MARK: - Ian Malclawd

/// Ian Malclawd: Clawd in black from top to toe, a black leather jacket over a black shirt unbuttoned halfway down, his
/// dark curly hair swept back and black-framed glasses. He fights with a lit orange road flare, waved at whatever's
/// coming and thrown. Signature: he holds the burning flare up and waves it back and forth over his head.
private func drawIanMalclawm(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x1E1E26), jacketL = C(0x3A3A48), shirt = C(0x2A2A30), frame = C(0x101014)
    let hair = C(0x1A1614), hairL = C(0x3A2E26)
    let stick = C(0xC8302A), glow = C(0xFF8A1A)

    drawLegs(c, Look(leg: C(0x26262C)), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x101012), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: jacket))
    // The jacket, the shirt open to a V of chest.
    c.pattern(18, 33, [
        "llllJSS....SSJlllllJ",
        "JJJJJJSS..SSJJJJJJdJ",
        "JJlJJlSSSSSSlJJJJJdJ",
        "JJJJJlSSSSSSlJJddJJJ",
        "JJJJJJJJJJJJJJJJJJJJ",
    ], ["J": jacket, "S": shirt, "l": jacketL, "d": C(0x121218)])
    c.rect(15, 35, 3, 1, C(0x121218))                                 // the cuff
    // Curly hair, swept back.
    c.pattern(17, 20, [
        "....HH.HHH.HHH.HH.....",
        "..HHHhhHHHhhHHHhhHHH..",
        ".HHhhHHHHhhHHHhhHHHHH.",
        ".HHHHHhhHHHHHHHHHhhHH.",
        "HHhhHHHHHHHhhHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHH",
        "HHH................HHH",
        "HH..................H.",
    ], ["H": hair, "h": hairL])
    // Black-framed glasses round the eyes.
    c.pattern(18, 28, ["...FFFF......FFFF.", "FFFFggFFFFFFFFggF.", "...FggF......FggF.", "...FggF......FggF.",
                       "...FFFF......FFFF."], ["F": frame, "g": C(0x9ABCD8, 0.35)])

    if let s = p.signature, s > 0.06, s < 0.94 {
        // The flare held high and waved to and fro over his head.
        let wave = sin(s * .pi * 6) * 40
        c.rect(38, 23, 3, 11, jacket); c.rect(38, 22, 3, 2, clawdOrange)
        let a0 = -90 + wave
        for (i, back) in [12.0, 24.0].enumerated() {
            let a = a0 - back * (cos(s * .pi * 6) > 0 ? 1 : -1)
            let tip = clawdbergReach((39.5, 22), a, 5)
            c.glowLine(tip.x, tip.y, tip.x, tip.y, core: glow.alpha(0.5), glow: glow, coreR: 0.6, glowR: 1.8,
                       strength: 0.4 / Double(i + 1))
        }
        drawFlare(c, x: 39.5, y: 22, angle: a0, lit: true, t: p.t, glow: glow, stick: stick, big: true)
        return
    }
    if p.fire != nil || p.ready {
        // Lit, waved at what's coming; flung forward as he throws it.
        let a = p.recoil > 0 ? -25 : -70 + 14 * sin(p.t * 7)
        drawFlare(c, x: 40, y: 33, angle: a, lit: true, t: p.t, glow: glow, stick: stick)
        c.rect(38, 33, 3, 3, jacket); c.px(40, 33, clawdOrange)
        return
    }
    // At rest: an unlit flare in his hand.
    drawFlare(c, x: 40, y: 35, angle: 70, lit: false, t: p.t, glow: glow, stick: stick)
    c.rect(38, 33, 3, 3, jacket)
}

// MARK: - John Hammend

/// John Hammend: Clawd in an ivory suit over a pale blue shirt, a cream panama with a brown band, white tufts of hair,
/// bushy white brows and a full white beard, leaning on a cane topped with a lump of amber. He doesn't fight.
/// Signature: he lifts the cane and holds its amber up to the light, the trapped mosquito dark inside it, a glint
/// running over it.
private func drawJohnHammend(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0xEEE8D6), suitD = C(0xC8C0A6), shirt = C(0xBCD4E8), beard = C(0xFFFFFF), beardD = C(0xB8B8B4)
    let cane = C(0x5A3A22), amber = C(0xE89A28), amberL = C(0xFFC85A), bug = C(0x3A1A0E)
    let sig = p.signature
    let raised = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false

    drawLegs(c, Look(leg: suit), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x9A6A3E), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    // The suit and its lapels, the shirt between.
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.rect(25, 33, 6, 4, shirt)
    c.rect(24, 33, 1, 4, suitD); c.rect(31, 33, 1, 4, suitD)
    // White hair at the sides, brows, and the beard (mouth and moustache in it).
    c.rect(18, 26, 2, 4, beard); c.rect(36, 26, 2, 4, beard)
    c.rect(21, 27, 4, 1, beard); c.rect(31, 27, 4, 1, beard)
    c.pattern(20, 31, [
        "WW............WW",
        "dWW.WWWWWWWW.WWd",
        ".WWWWWmmmmWWWWW.",
        ".dWWWWWWWWWWWWd.",
        "..dWWWWWWWWWWd..",
        "....dWWWWWWd....",
    ], ["W": beard, "d": beardD, "m": C(0x8A4A3A)])
    clawdbergFedora(c, felt: C(0xF4ECD0), dark: C(0xCFC29C), band: C(0x7A4A2A))

    if raised, let s = sig {
        // The cane lifted, its amber held up to the light and glinting.
        let k = min(1, (s - 0.08) / 0.15)
        let y = Int((10 - k * 6).rounded())
        c.rect(38, 25 + y / 2, 3, 9 - y / 2, suit)
        c.rect(42, 18 + y, 1, 12, cane)
        c.rect(40, 24 + y / 2, 3, 2, clawdOrange)
        c.pattern(40, 13 + y, [".AAA.", "AALAA", "AAbAA", "AAAAA", ".AAA."], ["A": amber, "L": amberL, "b": bug])
        if k >= 1 {
            c.glowLine(42.5, 15.5 + Double(y), 42.5, 15.5 + Double(y), core: C(0xFFE8A0, 0), glow: C(0xFFC85A),
                       coreR: 0, glowR: 4, strength: 0.5)
            let g = Int(p.t * 4) % 5
            if g < 3 { c.px(41 + g, 14 + y, white) }
        }
        return
    }
    // Leaning on the cane.
    c.rect(42, 33, 1, 11, cane)
    c.pattern(41, 30, [".AA.", "AALA", "AbAA", ".AA."], ["A": amber, "L": amberL, "b": bug])
    c.rect(38, 33, 3, 3, suit); c.rect(41, 33, 2, 2, clawdOrange)
}

// MARK: - Muldune

/// Muldune: Clawd the game warden in a sweat-stained khaki bush hat with one side of the brim pinned up and a leopard
/// band, a khaki safari vest full of pockets over an olive shirt, khaki trousers and boots; a black combat shotgun.
/// Signature: he drops into a crouch and sights down the shotgun, one eye shut.
private func drawMuldune(_ c: PixelCanvas, _ p: Pose) {
    let vest = C(0xB49E6A), vestD = C(0x8E7A4E), shirt = C(0x6E6A46), shirtD = C(0x54502F)
    let hat = C(0x8A7448), hatD = C(0x664E2E), band = C(0xD8B060), spot = C(0x3A2818)
    let sig = p.signature
    let crouch = sig.map { habitArc($0, hold: 0.7) } ?? 0
    let aiming = crouch > 0.6

    drawLegs(c, Look(leg: C(0x9A8A5E)), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x4A3420), height: 3)
    c.oy += p.breathe + Int((crouch * 2).rounded())
    drawBody(c, Look(arm: shirt, eye: nil))
    if aiming {
        c.rect(22, 29, 2, 3, ink); c.rect(32, 30, 2, 1, ink); c.px(31, 29, clawdShade)
    } else {
        c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    }
    // The olive shirt, the vest over it with its pockets.
    c.rect(18, 33, 20, 5, shirt); c.rect(37, 33, 1, 5, shirtD)
    c.pattern(18, 33, [
        "VVVVVVV......VVVVVVV",
        "VppVVVV......VVVppVV",
        "VppVVVV......VVVppVV",
        "VVVVVVVp....pVVVVVVV",
        "dddddddd....dddddddd",
    ], ["V": vest, "p": vestD, "d": vestD])
    // The bush hat, its left brim pinned up against the crown.
    c.pattern(14, 19, [
        "...HH.......................",
        "...hH...HHHHHHHHHHHH........",
        "...hHH.HHHHHHhHHHHHHH.......",
        "...hHHHHHHHHHHHHHHHHH.......",
        "...hHHHBBsBBBsBBBsBBB.......",
        "...hHHHHHHHHHHHHHHHHHHHHHHH.",
        "....HHHHHHHHHHHHHHHHHHHHHHHH",
        "..........................dd",
    ], ["H": hat, "h": hatD, "B": band, "s": spot])

    if aiming {
        // Sighting: the shotgun up at his cheek.
        c.oy -= 3
        drawShotgun(c, sleeve: shirt, metal: C(0x1E1E22), stock: C(0x2A2A2E))
        return
    }
    c.oy += p.gunY
    drawShotgun(c, sleeve: shirt, metal: C(0x1E1E22), stock: C(0x2A2A2E))
}

// MARK: - Tim Murphey

/// Tim Murphey: Clawd as a kid in a navy baseball cap, a light blue dinosaur T-shirt with a little green T. rex on the
/// front, jeans and white trainers. He doesn't fight. Signature: the night-vision goggles strapped to his cap flip down
/// over his eyes, the lenses glowing green, and flip back up.
private func drawTimMurphey(_ c: PixelCanvas, _ p: Pose) {
    let tee = C(0x9AC2DA), teeD = C(0x7AA0BA), dino = C(0x2E6A2A), cap = C(0x2A3A6A), capD = C(0x1A264A)
    let hair = C(0x8A5A2E), goggle = C(0x34343A), goggleD = C(0x1E1E22), green = C(0x5AF07A)
    let sig = p.signature
    let flipping = sig.map { ($0 > 0.05 && $0 <= 0.18) || ($0 >= 0.88 && $0 < 0.95) } ?? false
    let down = sig.map { $0 > 0.18 && $0 < 0.88 } ?? false

    drawLegs(c, Look(leg: C(0x34507E)), step: p.step)
    clawdbergBoots(c, step: p.step, C(0xEAEAEA), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: clawdOrange, eye: down ? nil : ink))
    drawShortSleeves(c, tee)
    // The T-shirt and its dinosaur.
    c.rect(18, 33, 20, 5, tee); c.rect(37, 33, 1, 5, teeD); c.rect(18, 37, 20, 1, teeD)
    c.pattern(24, 34, ["....DD.", "D.DDDDD", ".DDDD..", "..D.D.."], ["D": dino])
    // Hair at the back, the cap and its peak.
    c.rect(18, 25, 3, 3, hair)
    c.pattern(18, 21, [
        ".....CCCCCCCCC......",
        "...CCCCCCCCCCCCC....",
        "..CCCCCCCCcCCCCCC...",
        ".CCCCCCCCCCCCCCCCC..",
        "CCCCCCCCCCCCCCCCCCCC",
    ], ["C": cap, "c": C(0xE8E8E8)])
    c.rect(36, 25, 7, 1, capD)

    if down {
        // The goggles over his eyes, lenses glowing.
        c.rect(18, 28, 3, 1, goggleD)
        c.pattern(20, 27, ["..GGGGG...GGGGG.", "GGGGGGGGGGGGGGGG", "GGGLLGGGGGGGLLGG", "GGGLLGGGGGGGLLGG", "..GGGGG...GGGGG."],
                  ["G": goggle, "L": green])
        c.rect(36, 29, 3, 2, goggleD)
        let pulse = 0.8 + 0.2 * sin(p.t * 9)
        for x in [23.5, 33.5] {
            c.glowLine(x, 30, x, 30, core: C(0xC8FFD4), glow: green, coreR: 0.6, glowR: 2.6, strength: pulse)
        }
        return
    }
    if flipping {
        // Halfway: the goggles tipped forward off the cap's front.
        c.pattern(22, 24, ["GGGGGGGGGGGGG", ".GLGGGGGGLG.."], ["G": goggle, "L": C(0x2E5A36)])
        return
    }
}

// MARK: - Lex Murphey

/// Lex Murphey: Clawd with long, straight, pale blonde hair falling past her shoulders, a pink top, light jeans and
/// pink trainers. She doesn't fight. Signature: she holds up a spoonful of green jelly and watches it wobble.
private func drawLexMurphey(_ c: PixelCanvas, _ p: Pose) {
    let hair = C(0xF0D890), hairD = C(0xC8AA62), hairL = C(0xFFF0C0), top = C(0xE87AAA), topD = C(0xC05A88)
    let topL = C(0xF49AC0)
    let sig = p.signature
    let jelly = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false

    drawLegs(c, Look(leg: C(0xA8BCD4)), step: p.step)
    clawdbergBoots(c, step: p.step, C(0xF08AB8), height: 1)
    c.oy += p.breathe
    // Her hair down her back.
    c.rect(15, 26, 4, 11, hair); c.rect(15, 36, 4, 1, hairD); c.rect(16, 29, 1, 4, hairD)
    drawBody(c, Look(arm: clawdOrange))
    drawShortSleeves(c, top)
    // The pink top.
    c.rect(18, 33, 20, 5, top); c.rect(37, 33, 1, 5, topD); c.rect(18, 37, 20, 1, topD)
    c.rect(25, 33, 6, 1, C(0xF6A6C8))
    // Light along the shoulders and the top's soft folds.
    c.rect(18, 33, 5, 1, topL); c.rect(32, 33, 5, 1, topL)
    c.rect(21, 35, 1, 2, topD); c.rect(33, 35, 1, 2, topD); c.px(28, 36, topD)
    // The hair: long and straight, parted, a lock falling down in front.
    c.pattern(15, 20, [
        "......HHHHHHHHHHHH.......",
        "....HHHlllHHHhHHHHHH.....",
        "...HHllHHHHHHhHHlllHHH...",
        "..HHHHHHHHHHHhHHHHHHHHH..",
        "..HHHhhHHHHHHHHHHHHHHhHH.",
        ".HHHHHHHHHHHHHHHHHHHHhHH.",
        ".HHHHHHHH..........HHHHH.",
        "HHHHH...............HHHH.",
        "HhHH.................HhH.",
        "HhHH.................HhH.",
        "HHHH.................HHH.",
        "HHHH.................HHH.",
        "HHHH..................HH.",
        "HHHH..................H..",
    ], ["H": hair, "h": hairD, "l": hairL])

    guard jelly else { return }
    // The spoon held up, the jelly on it wobbling.
    c.rect(38, 30, 3, 3, clawdOrange); c.rect(38, 33, 3, 1, top)
    clawdbergLine(c, 40.5, 30.5, 45, 28.5, C(0xC8CCD4), 0.5)
    c.rect(45, 28, 4, 1, C(0xC8CCD4))
    let w = Int(p.t * 10) % 2
    let green = C(0x6AD84A), greenD = C(0x3EA82E), greenL = C(0xC8FFB0)
    if w == 0 {
        c.pattern(45, 24, [".GG.", "GLGG", "GGGG", "GGGd"], ["G": green, "L": greenL, "d": greenD])
    } else {
        c.pattern(44, 24, ["...GG", "..GLGG", ".GGGG", ".GGGd"], ["G": green, "L": greenL, "d": greenD])
    }
}

// MARK: - Ray Arnie

/// Ray Arnie: Clawd with close-cropped black hair, a moustache, gold wire-rimmed glasses and a cigarette on the go, a
/// pale short-sleeved shirt with a pen in the pocket, dark trousers. He doesn't fight. Signature: the park's computer
/// is in front of him and he hammers at the keyboard, both hands going, lines of green text scrolling up the screen.
private func drawRayArnie(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0xE6E2D0), shirtD = C(0xBEB8A4), hair = C(0x1A1A1E), wire = C(0xD8B04A)
    let sig = p.signature
    let typing = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false

    drawLegs(c, Look(leg: C(0x4A4A52)), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x18181C), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: clawdOrange))
    drawShortSleeves(c, shirt)
    // The shirt: collar points, a pocket with a pen in it.
    c.rect(18, 33, 20, 5, shirt); c.rect(37, 33, 1, 5, shirtD); c.rect(18, 37, 20, 1, shirtD)
    c.pattern(24, 33, ["SS....SS", ".S....S."], ["S": white])
    c.rect(28, 34, 1, 3, shirtD)
    c.rect(31, 35, 3, 2, shirtD); c.px(32, 34, C(0x2A4A9A))
    // Cropped hair.
    c.pattern(18, 22, [
        "...HHHHHHHHHHHHH....",
        ".HHHHHHHHHHHHHHHHH..",
        "HHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHH",
        "HH................HH",
    ], ["H": hair])
    // Glasses, moustache and the cigarette.
    c.pattern(21, 28, ["GGGG......GGGG", "G..GGGGGGGG..G", "G..G......G..G", "GGGG......GGGG"], ["G": wire])
    c.rect(25, 32, 6, 1, hair)
    c.rect(31, 32, 4, 1, white); c.px(35, 32, C(0xFF6A2A))
    if Int(p.lt * 2) % 3 == 0 { c.px(36, 30, C(0xC8C8D0, 0.6)) } else { c.px(35, 29, C(0xC8C8D0, 0.5)) }

    guard typing else { return }
    // The control-room terminal: a beige monitor scrolling green text, the keyboard under his hands.
    let beige = C(0xD8D0B8), beigeD = C(0xA8A088), screen = C(0x10201A), text = C(0x5AF07A)
    c.rect(45, 21, 13, 11, beige); c.rect(57, 21, 1, 11, beigeD); c.rect(47, 23, 9, 7, screen)
    c.rect(49, 32, 5, 2, beigeD)
    let scroll = Int(p.t * 6)
    for row in 0..<3 {
        let len = 2 + Int(noise(scroll + row) * 6)
        c.rect(48, 24 + row * 2, len, 1, text)
    }
    c.rect(40, 35, 16, 2, C(0x8A8676)); c.rect(40, 35, 16, 1, C(0xB8B4A4))
    let beat = Int(p.t * 12) % 2
    c.rect(38, 33, 3, 2, clawdOrange)
    c.rect(42, 33 + (beat == 0 ? 0 : 1), 2, 2, clawdOrange)
    c.rect(47, 33 + (beat == 0 ? 1 : 0), 2, 2, clawdOrange)
    clawdbergLine(c, 40, 34, 47, 33.5 + Double(beat == 0 ? 1 : 0), clawdOrange, 0.6)
    c.px(43 + beat * 5, 35, white)
}

// MARK: - Owen Gravy

/// Owen Gravy: Clawd the raptor trainer with short brown hair swept up and a bit of stubble, a brown leather vest over a
/// grey-green henley, olive cargo trousers and boots; a lever-action rifle. Signature: rifle slung, he holds out one
/// open palm, steady, the way he calms his raptors.
private func drawOwenGravy(_ c: PixelCanvas, _ p: Pose) {
    let vest = C(0x6A4628), vestD = C(0x4A301A), vestL = C(0x8A5E38), henley = C(0xA4AC92), henleyD = C(0x6A7260)
    let hair = C(0x6A4A2A), hairL = C(0x8A6438), stubble = C(0xB06448)
    let sig = p.signature
    let palm = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false

    drawLegs(c, Look(leg: C(0x6A6A50)), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x3A2818), height: 3)
    c.oy += p.breathe
    if palm { clawdbergLine(c, 15, 26, 33, 41, C(0x2A2A2E), 0.6) }   // the rifle slung across his back
    drawBody(c, Look(arm: henley))
    // The henley with its buttons, the leather vest open over it.
    c.rect(18, 33, 20, 5, henley); c.rect(37, 33, 1, 5, henleyD)
    c.pattern(18, 33, [
        "VVVVVVl......lVVVVVV",
        "VVVVVVl..b...lVVVVVV",
        "VVVVVVl......lVVVVVd",
        "VVVVVVl..b...lVVVVVd",
        "dddddddd....dddddddd",
    ], ["V": vest, "d": vestD, "l": vestL, "b": henleyD])
    c.rect(24, 33, 8, 1, henleyD)
    for (x, y) in [(22, 32), (25, 32), (29, 32), (32, 32), (34, 31)] { c.px(x, y, stubble) }
    // Short hair swept up at the front.
    c.pattern(18, 21, [
        "..........HHHHH.....",
        "....HHHHHHHHHHHHHH..",
        "..HHHHHHhHHHHHHhHHH.",
        ".HHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHH",
        "HHH...............HH",
    ], ["H": hair, "h": hairL])

    if palm {
        // The arm out straight, palm open and fingers up: easy, easy.
        clawdbergLine(c, 39, 34, 45, 33.5, henley, 1.2)
        c.pattern(45, 29, [".O.O", "OOOO", "OOOO", "OOO.", "OOO.", ".OO."], ["O": clawdOrange])
        c.px(44, 31, clawdOrange)
        return
    }
    c.oy += p.gunY
    drawRifle(c, sleeve: henley)
}

// MARK: - Claire Daring

/// Claire Daring: Clawd with a sleek red bob parted at the side, the park manager's white blouse and white pencil skirt
/// (her legs in four below it) and nude heels. In a fight she lights a red flare, waves it and throws it. Signature: she
/// holds a burning red flare up high over her head, lighting the way.
private func drawClaireDaring(_ c: PixelCanvas, _ p: Pose) {
    let blouse = C(0xF6F6F2), blouseD = C(0xD2D2CC), hair = C(0xC8402A), hairL = C(0xE8603E), hairD = C(0x8E2A1A)
    let heel = C(0xD8B494), heelD = C(0x9A7458), red = C(0xFF2A2A), stick = C(0xB01A1A)

    drawLegs(c, Look(), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let y = p.step >= 0 && i % 2 == p.step ? 42 : 43
            c.rect(lx, y, 2, 1, heel); c.px(lx, y - 1, heelD)
        }
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: blouse))
    // The blouse and its collar.
    c.rect(18, 33, 20, 5, blouse); c.rect(37, 33, 1, 5, blouseD)
    c.pattern(25, 33, ["d....d", ".d..d.", "..dd.."], ["d": blouseD])
    c.rect(21, 34, 1, 2, blouseD); c.rect(34, 34, 1, 3, blouseD)        // soft folds
    // The pencil skirt, hanging over the tops of the legs.
    let skirt = seatedPose ? 1 : 2
    c.rect(18, 37, 20, skirt + 1, blouse); c.rect(18, 37 + skirt, 20, 1, blouseD); c.rect(37, 37, 1, skirt + 1, blouseD)
    c.rect(18, 37, 20, 1, blouseD.alpha(0.6))
    if !seatedPose { c.px(23, 38, blouseD); c.px(32, 38, blouseD) }      // the skirt's creases
    // The bob: side parting, the fringe swept across, down to the jaw.
    c.pattern(16, 20, [
        "......HHHHHHHHHH........",
        "....HHHlllHHHHHHHHH.....",
        "..HHHllHHHHHHllllHHHH...",
        ".HHHHHHHHHHHHHHHHHHHhH..",
        ".HHHHHHHHHHHHHHHHHHHhHH.",
        "HHHHHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHH..",
        "HHHHHHHHHHHH........HHH.",
        "HHHH.................HHH",
        "HHHh.................HHH",
        "HHHH.................HHH",
        "HHHH.................hHH",
        "dHHH..................Hd",
        ".dd....................d",
    ], ["H": hair, "l": hairL, "h": hairD, "d": hairD])

    if let s = p.signature, s > 0.08, s < 0.92 {
        // The flare held high over her head, glaring red.
        c.rect(38, 20, 3, 14, blouse); c.rect(38, 18, 3, 2, clawdOrange)
        drawFlare(c, x: 39.5, y: 18, angle: -88, lit: true, t: p.t, glow: red, stick: stick, big: true)
        let drift = frac(p.t * 0.7)
        c.px(41 + Int(drift * 4), 10 - Int(drift * 8), C(0xD8D0D0, 0.5 * (1 - drift)))
        return
    }
    if p.fire != nil || p.ready {
        let a = p.recoil > 0 ? -25 : -70 + 12 * sin(p.t * 6)
        drawFlare(c, x: 40, y: 33, angle: a, lit: true, t: p.t, glow: red, stick: stick)
        c.rect(38, 33, 3, 3, blouse); c.px(40, 33, clawdOrange)
    }
}

// MARK: - Blue

/// Blue: Clawd in a velociraptor suit, grey-green hide with a blue stripe running from the snout through the eye and
/// down her side to the tail, a long toothy snout, a yellow eye, a ridge of bumps over the head and a stiff tail held
/// out behind; dark claws on all four feet. She fights with the claws on her little arms. Signature: she cocks her head
/// to one side and chirps.
private func drawBlue(_ c: PixelCanvas, _ p: Pose) {
    let hide = C(0x8A8E76), hideD = C(0x646852), hideL = C(0xA8AC92), stripe = C(0x3A6AC8), belly = C(0xC6C2A4)
    let claw = C(0x2A2622), tooth = C(0xF2EEE0), mouth = C(0x5A2228)
    let cock = p.signature.map { habitArc($0, hold: 0.6) } ?? 0
    let tilt = Int((cock * 2).rounded())
    var gape = 0
    if let a = p.melee, a > -40 { gape = 2 }
    if cock > 0.5, Int(p.lt * 8) % 3 == 0 { gape = 1 }

    drawLegs(c, Look(leg: hide), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let y = p.step >= 0 && i % 2 == p.step ? 42 : 43
            c.px(lx + 2, y, claw); c.px(lx - 1, y - 2, claw)
        }
    }
    c.oy += p.breathe
    // The tail, held out stiffly behind, the stripe running along it.
    for x in 6...18 {
        let f = Double(18 - x) / 12
        let sway = sin(p.lt * 1.4 + f * 2) * f
        let mid = 31 - f * 4 + sway
        let half = 3.0 - f * 2.3
        let top = Int((mid - half).rounded()), bottom = Int((mid + half).rounded())
        c.rect(x, top, 1, bottom - top + 1, hide)
        c.px(x, bottom, hideD)
        c.px(x, Int(mid.rounded()), stripe)
    }
    drawBody(c, Look(body: hide, shade: hideD, arm: hide, eye: nil))
    c.rect(20, 34, 17, 3, belly); c.rect(20, 36, 17, 1, C(0xA8A486))
    for (x, y) in [(20, 28), (25, 27), (28, 32), (21, 31), (34, 33)] { c.px(x, y, hideL) }
    // The ridge of bumps along the back.
    for x in stride(from: 19, to: 30, by: 3) { c.rect(x, 25, 2, 1, hideD) }
    // The head held up on its neck over the front of the body (cocked up when she tilts it): the long snout, its
    // teeth and the stripe along the jaw, and the lower jaw (dropped open to bite or chirp).
    let sy = 19 - tilt
    c.rect(30, sy + 4, 8, 27 - sy - 4, hide)
    c.pattern(30, sy, [
        "...sSSSs..........",
        ".sSSSSSSSSs.......",
        "SSSSSSSSSSSSSSSs..",
        "SSSSSSSSSSSSSSSSSn",
        "SSSSSSBBBBBBBBBBBS",
        "SSSSSSTtTtTtTtTtT.",
    ], ["S": hide, "s": hideD, "n": ink, "B": stripe, "T": tooth, "t": hide])
    if gape > 0 { c.rect(36, sy + 6, 11, gape, mouth) }
    c.pattern(30, sy + 6 + gape, ["SSSSSStTtTtTtTt...", "SSSSSSSSSSSSSSs...", "SSSSSBBBBBB......."],
              ["S": hide, "s": hideD, "t": tooth, "T": hide, "B": belly])
    // The eye: yellow, a black slit, under a dark brow.
    c.rect(36, sy + 2, 3, 2, C(0xF0C82A)); c.px(37, sy + 2, ink); c.px(37, sy + 3, ink)
    c.rect(35, sy + 1, 5, 1, hideD)
    // The stripe, from the eye down the neck and along her side.
    clawdbergLine(c, 35, Double(sy) + 4.5, 29, 29.5, stripe, 0.6)
    clawdbergLine(c, 29, 29.5, 18, 32.5, stripe, 0.6)
    if cock > 0.5 {
        // The chirp.
        let n = Int(p.lt * 10) % 3
        for i in 0..<3 where (i + n) % 3 != 0 {
            let x = 50 + i * 2
            c.px(x, sy + 2 - i, C(0xFFFFFF, 0.75)); c.px(x + 1, sy + 3 - i, C(0xFFFFFF, 0.75))
            c.px(x, sy + 4 - i, C(0xFFFFFF, 0.75))
        }
    }
    // The little clawed arm.
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() {
            let e = clawdbergReach(clawdbergHand, ta, 4)
            drawTalons(c, e, angle: ta, len: 4, C(0xE8E0C8), alpha: 0.35 / Double(i + 1))
        }
        clawdbergBar(c, (38, 34), a, from: 0, to: 4, hide, r: 1.1)
        let e = clawdbergReach(clawdbergHand, a, 4)
        drawTalons(c, e, angle: a, len: 3.5, claw)
    } else {
        c.rect(38, 33, 3, 2, hide)
        drawTalons(c, (40.5, 34.5), angle: 80, len: 2.5, claw)
    }
}

// MARK: - Trike

/// Trike: Clawd in a triceratops suit, olive-green and big: a great scalloped bony frill fanned up behind the head,
/// two long ivory brow horns sweeping forward over the face and a short one on the beaked snout, Clawd's face
/// showing through the opening. She fights by lowering her horns and charging. Signature: she lies down for a pat,
/// eyes shut, while a hand reaches down to stroke her nose.
private func drawTrike(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x7E8A58), suitD = C(0x5A6640), frill = C(0x9CA86C), frillD = C(0x76824C), edge = C(0xEDE0BC)
    let horn = C(0xF0E6C8), hornD = C(0xC4B48E), beak = C(0x4A4A36)
    let sig = p.signature
    let lying = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false
    var hornA = -22.0
    if let m = p.melee { hornA = max(-40, min(12, -20 + (m + 60) * 0.4)) }
    let charging = (p.melee ?? -90) > -25

    if lying {
        // Legs folded under her, four stubby knees showing.
        for lx in [19, 23, 31, 35] { c.rect(lx - 1, 42, 3, 2, suit); c.px(lx - 1, 43, suitD) }
        c.oy += 4
    } else {
        drawLegs(c, Look(leg: suit), step: p.step)
        if !seatedPose {
            for (i, lx) in [19, 23, 31, 35].enumerated() {
                let lifted = p.step >= 0 && i % 2 == p.step
                c.rect(lx, lifted ? 42 : 43, 2, 1, suitD)
            }
        }
        c.oy += p.breathe
        if charging { c.ox += 2 }
    }
    // The frill, fanned up and back behind the head: a tall bony shield, a russet band inside its rim, mottled, with
    // knobs round the edge.
    c.pattern(7, 6, [
        ".........e.e.e........",
        ".......eRRRRRRRe......",
        "......eRFFFFFFFRRe....",
        ".....eRFFFFFFFFFFRe...",
        "....eRFFFFdFFFFFFFRe..",
        "....RFFFFFFFFFdFFFFR..",
        "...eRFFFFdFFFFFFFFFRe.",
        "...RFFFFFFFFFFFFFFFFR.",
        "..eRFFFFFFFFdFFFFFFFR.",
        "..RFFFFdFFFFFFFFFFFFR.",
        ".eRFFFFFFFFFFFFdFFFFR.",
        ".RFFFFFFFFFFFFFFFFFR..",
        "eRFFFFFFdFFFFFFFFFR...",
        "RFFFFFFFFFFFFFFFFFR...",
        "eRFFFFFFFFFFFFFFFR....",
        ".RRFFFFFFFFFFFFFR.....",
        "..eRRFFFFFFFFFFR......",
        "....RRFFFFFFFFR.......",
    ], ["F": frill, "d": frillD, "R": C(0xA0583A), "e": edge])
    // A big body: the suit a size up all round.
    c.rect(16, 24, 23, 14, suit); c.rect(16, 37, 23, 1, suitD); c.rect(38, 24, 1, 14, suitD)
    c.rect(16, 24, 23, 1, C(0x96A26A))
    // The face through the opening, and the beaked snout with its little horn.
    c.rect(20, 27, 17, 7, clawdOrange)
    if lying {
        c.pattern(22, 30, [".KK.", "K..K"], ["K": ink]); c.pattern(32, 30, [".KK.", "K..K"], ["K": ink])
    } else {
        c.rect(22, 29, 2, 3, ink); c.rect(32, 29, 2, 3, ink)
    }
    c.pattern(37, 29, ["SSS..", "SSSSb", "SSSbb", "SSbb.", "Sbb.."], ["S": suit, "b": beak])
    c.pattern(39, 26, ["..h", ".hH", "hHH"], ["h": hornD, "H": horn])
    // Front arms.
    c.rect(13, 33, 3, 4, suit)
    c.rect(39, 34, 3, 3, suit)
    // The brow horns, sweeping forward (lowered for a charge).
    let base1 = (x: 34.0, y: 26.0), base2 = (x: 28.0, y: 25.0)
    if !p.trail.isEmpty && !lying {
        for tr in p.trail {
            let ta = max(-40, min(12, -20 + (tr + 60) * 0.4))
            clawdbergSmear(c, base1, [ta], from: 2, to: 15, C(0xF0E6C8))
        }
    }
    let a = lying ? -15 : hornA
    let t1 = clawdbergReach(base1, a, 15), t2 = clawdbergReach(base2, a - 6, 14)
    let m1 = clawdbergReach(base1, a, 6), m2 = clawdbergReach(base2, a - 6, 6)
    clawdbergLine(c, base2.x, base2.y, m2.x, m2.y, hornD, 1.0)
    clawdbergLine(c, m2.x, m2.y, t2.x, t2.y, hornD, 0.6)
    clawdbergLine(c, base1.x, base1.y, m1.x, m1.y, horn, 1.1)
    clawdbergLine(c, m1.x, m1.y, t1.x, t1.y, horn, 0.6)

    if lying {
        // A hand comes down and strokes her nose; a little heart pops up.
        let k = sig!
        let stroke = Int((sin(k * 6 * .pi) * 1.5).rounded())
        let y = 20 + stroke
        c.rect(40, y - 9, 4, 11, C(0xC8B48A)); c.rect(40, y - 9, 1, 11, C(0xA8946A)); c.rect(40, y, 4, 2, C(0xA8946A))
        c.rect(39, y + 2, 5, 3, clawdOrange); c.px(39, y + 5, clawdOrange)
        if k > 0.35 {
            let f = frac(p.t * 0.7)
            let hy = 16 - Int(f * 8)
            let h = C(0xFF6A8A, 1 - f * 0.7)
            c.pattern(30, hy, ["H.H", "HHH", ".H."], ["H": h])
        }
    }
}
