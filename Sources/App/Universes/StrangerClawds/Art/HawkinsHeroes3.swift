import Foundation

// Heroes: the teenagers. Clawd in costume like the rest, with Clawd's own orange face showing. Steve wears his season
// 2 jacket rather than the Scoops Ahoy uniform, so he and Robin never look alike. Derek is Holly's classmate, so he
// stands lower, as Erica does.

let hawkinsHeroes3: [HawkinsHero: Persona] = [
    .steveHarringclawd: Persona(name: "Steve Harringclawd", weapon: .saber, headTop: 15, signature: 3.4,
                                draw: drawSteveHarringclawd),
    .nancyWheeler: Persona(name: "Nancy Wheeler", weapon: .blaster, shot: .bullet, muzzle: (52, 31), headTop: 20,
                           signature: 3.0, draw: drawNancyWheeler),
    .jonathanByers: Persona(name: "Jonathan Byers", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 20,
                            signature: 3.0, draw: drawJonathanByers),
    .robinBuckley: Persona(name: "Robin Buckley", headTop: 16, signature: 2.8, callout: "Ahoy!", draw: drawRobinBuckley),
    .eddieMunclawd: Persona(name: "Eddie Munclawd", weapon: .saber, headTop: 17, signature: 3.6, draw: drawEddieMunclawd),
    .argyle: Persona(name: "Argyle", headTop: 19, signature: 3.0, callout: "Duuude.", draw: drawArgyle),
    .barb: Persona(name: "Barb", headTop: 20, signature: 2.4, draw: drawBarb),
    .derekTurnbow: Persona(name: "Derek Turnbow", headTop: 22, draw: drawDerekTurnbow),
]

// MARK: - Steve Harringclawd

/// Steve Harringclawd: the big hair, brown and swept up high off his brow and back, a maroon jacket open over a white
/// polo (season 2), jeans and white sneakers. He fights with his bat, nails driven through the end. Signature: he props
/// the bat behind him and gives his hair a spray from a pink can, the mist drifting over it.
private func drawSteveHarringclawd(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x7A2A3A), jacketD = C(0x56182A), jacketL = C(0x9E4456)
    let shirt = C(0xEEEEEA), shirtD = C(0xC8C8C4)
    let jeans = C(0x5C78A4), jeansD = C(0x445C84)
    let hair = C(0x6A4226), hairD = C(0x4A2C18), hairL = C(0x946238)
    let k = hawkinsSpan(p, 0.06, 0.94)
    let lift = Int((hawkinsEase(k, edge: 0.15) * 8).rounded())

    // While he sprays, the bat leans against his back.
    if k >= 0 { steveBat(c, angle: -76, trail: [], from: (13, 43), fist: false) }

    drawLegs(c, Look(leg: jeans), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 4, jeansD) } }
    drawBoots(c, C(0xE8E8E2), step: p.step, rows: 2)
    drawBoots(c, C(0xA8A8B0), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: jacket), armRight: k >= 0 ? lift : 0)

    // The jacket, open over the polo: lit lapels and shoulders, a slash pocket each side, the far side and the hem in
    // shade, and the polo's collar and placket.
    c.rect(18, 33, 20, 5, jacket); c.rect(25, 33, 6, 5, shirt); c.rect(25, 37, 6, 1, shirtD)
    c.pattern(24, 33, ["ss..ss", ".s..s."], ["s": shirtD]); c.rect(27, 34, 2, 2, shirtD); c.px(27, 34, shirt)
    c.rect(24, 33, 1, 5, jacketL); c.rect(31, 33, 1, 5, jacketD); c.rect(37, 33, 1, 5, jacketD)
    c.rect(18, 37, 7, 1, jacketD); c.rect(31, 37, 7, 1, jacketD)
    c.rect(19, 33, 4, 1, jacketL); c.rect(33, 33, 3, 1, jacketL)
    c.px(21, 35, jacketD); c.px(22, 36, jacketD); c.px(34, 35, jacketD); c.px(35, 36, jacketD)
    c.rect(15, 35, 3, 1, jacketD)

    // The hair: swept up high over his brow and back off it, lit in long strokes, down over his ears at the sides.
    c.pattern(16, 15, [
        "..............HHHHH.....",
        "...........HHHHlllHH....",
        ".........HHHHlllHHHHH...",
        "......HHHHHlllHHHHHHHH..",
        "....HHHHHlllHHHHHHHHHHH.",
        "...HHHHlllHHHHHHHHHHhHH.",
        "..HHHlllHHHHHHHHHHHHhHHd",
        "..HHllHHHHHHHHHHHHHHhHHd",
        ".HHHHHHHHHHHHHHHHHHHHHHd",
        ".HHHHHHHHHHHHHHHHHHHHHd.",
        ".HHHHHHhHHHHHHhHHHHHHHd.",
        ".HHHHH.............HHHd.",
        ".HHH................HHd.",
        "..HH................Hd..",
        "..dH................d...",
    ], ["H": hair, "d": hairD, "l": hairL])

    if k >= 0 {
        guard lift >= 3 else { return }
        // The pink can up by his hair, and the mist drifting back over it.
        let top = 25 - lift - 6
        c.rect(39, top + 1, 3, 5, C(0xE86AA8)); c.rect(39, top + 1, 1, 5, C(0xF49ACA)); c.rect(41, top + 1, 1, 5, C(0xB84A84))
        c.rect(39, top + 3, 3, 1, C(0xF4F0F4)); c.rect(39, top, 3, 1, C(0xE4E4EA)); c.px(38, top, C(0x8A8A94))
        if lift >= 7 {
            for i in 0..<5 {
                let f = (p.t * 2.5 + Double(i) * 0.2).truncatingRemainder(dividingBy: 1)
                let x = 37 - Int(f * 8), y = top - 1 + Int(sin(f * 6 + Double(i)) * 1.5)
                c.px(x, y, C(0xF4F4FF, 0.2)); c.px(x - 1, y + 1, C(0xF4F4FF, 0.14))
            }
        }
        return
    }
    if let a = p.melee {
        steveBat(c, angle: a, trail: p.trail)
    } else {
        steveBat(c, angle: 48, trail: [])
    }
}

/// Steve's bat along `angle` from the hand `h`: the taped grip, the pale wooden barrel lit along its length, and the
/// nails sticking out of the end; a smear where a fast swing just was.
private func steveBat(_ c: PixelCanvas, angle: Double, trail: [Double], from h: (x: Double, y: Double) = Sprite.hand,
                      fist: Bool = true) {
    hawkinsSmear(c, h, trail, from: 4, to: 14, C(0xE8D8C0))
    hawkinsBar(c, h, angle, from: -2, to: 4.5, C(0x3A3A40), r: 0.7)
    hawkinsBar(c, h, angle, from: 4, to: 13.5, C(0x8E5E30), r: 1.3)
    hawkinsBar(c, h, angle, from: 4.5, to: 13, C(0xC08A50), r: 0.6)
    for (d, side) in [(8.5, 1.0), (10.0, -1.0), (11.5, 1.0), (12.8, -1.0)] {
        let base = hawkinsReach(h, angle, d)
        let tip = hawkinsReach(base, angle + 90 * side, 2.6)
        hawkinsLine(c, base.x, base.y, tip.x, tip.y, C(0xB8BCC4), 0.4)
    }
    if fist { c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, clawdOrange) }
}

// MARK: - Nancy Wheeler

/// Nancy Wheeler: shoulder-length brown hair, curled out at the ends, a short oatmeal coat belted over a pale pink
/// blouse with a frilled collar, dark trousers and brown boots. She fights with a sawn-off pump shotgun. Signature: she
/// racks it, the pump sliding back and forward, a spent red shell spinning out.
private func drawNancyWheeler(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0xD8CCB0), coatD = C(0xAEA084), coatL = C(0xEEE6D2), button = C(0x6A5A44)
    let blouse = C(0xF0D4DC), blouseD = C(0xD0AEB8)
    let hair = C(0x4A2C1C), hairD = C(0x2E1A10), hairL = C(0x6E4630)
    let k = hawkinsSpan(p, 0.08, 0.92)

    drawLegs(c, Look(leg: C(0x3A3A4A)), step: p.step)
    drawBoots(c, C(0x5A3A24), step: p.step, rows: 3)
    drawBoots(c, C(0x3A2416), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: coat))

    // The coat: short, to her hips, its collar up and lapels lit, belted with a buckle, buttons below the belt, the far
    // side in shade; the blouse's frill at the neck.
    c.rect(18, 33, 20, 5, coat)
    if !seatedPose { c.rect(17, 38, 22, 1, coatD); for x in [19, 23, 31, 35] { c.rect(x, 38, 2, 1, coat) } }
    c.rect(26, 33, 4, 2, blouse); c.pattern(25, 33, ["b....b", ".bBBb."], ["b": blouseD, "B": blouse])
    c.rect(23, 33, 2, 3, coatL); c.rect(31, 33, 2, 3, coatD)
    c.rect(18, 36, 20, 1, coatD); c.rect(27, 36, 2, 1, C(0xC8B070))
    c.px(28, 35, button); c.px(28, 37, button)
    c.rect(19, 33, 3, 1, coatL); c.rect(37, 33, 1, 5, coatD)
    c.rect(15, 35, 3, 1, coatD)

    // Brown hair to her shoulders, lit on top, the ends curled outwards.
    c.pattern(16, 20, [
        ".......HHHHHHHHHH.......",
        ".....HHHlllHHHHHHHH.....",
        "...HHHlllHHHHHlllHHHH...",
        "..HHHllHHHHHHHllHHHHHH..",
        "..HHlHHHHHHHHHHHHHHHHHd.",
        ".HHHHHHHHHHHHHHHHHHHHHd.",
        ".HHHHHHH.......HHHHHHHd.",
        ".HHHH..............HHHd.",
        ".HHH................HHd.",
        ".HlH................HHd.",
        ".HHH................HdH.",
        "HHHd................dHH.",
        "HHd..................dHH",
        "Hd....................dH",
    ], ["H": hair, "d": hairD, "l": hairL])

    // The shotgun, held at her hip: the dark receiver, the barrel and the magazine tube under it, the wooden pump.
    // Racking it, she lifts it a little and the pump slides back and forward again.
    c.oy += p.gunY
    var back = 0
    if k >= 0 {
        c.oy -= 2
        back = k > 0.2 && k < 0.35 ? 3 : k >= 0.35 && k < 0.42 ? 1 : 0
    }
    c.rect(38, 33, 3, 3, coat)
    c.pattern(40, 30, ["KKKGGGGGGGGGl", "KKKK.....TTT.", ".KK..........", ".KK.........."],
              ["K": C(0x2A2A30), "G": C(0x4A4E58), "l": C(0x8A8F9C), "T": C(0x3A3E46)])
    c.rect(41, 30, 2, 1, C(0x5A5E68))
    c.rect(44 - back, 31, 5, 1, C(0x8A5A30)); c.px(44 - back, 31, C(0xB07A44))
    c.rect(38, 33, 3, 2, clawdOrange)
    if k > 0.22 && k < 0.6 {
        // The spent shell, spinning up and back out of the port.
        let f = (k - 0.22) / 0.38
        let x = 42 - Int(f * 9), y = 29 - Int(sin(f * .pi) * 7)
        let flat = Int(f * 8) % 2 == 0
        c.rect(x, y, flat ? 2 : 1, flat ? 1 : 2, C(0xC8302A)); c.px(x + (flat ? 2 : 0), y + (flat ? 0 : 2), C(0xD8B048))
    }
}

// MARK: - Jonathan Byers

/// Jonathan Byers: dark, shaggy hair swept across his brow and down over his ears, a brown corduroy jacket over a slate
/// tee, jeans and scuffed sneakers, his camera hanging round his neck. He fights with a revolver. Signature: he lifts
/// the camera to his eye and takes a photo, the flash going off in a big white burst.
private func drawJonathanByers(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x6A4A30), jacketD = C(0x4A3220), jacketL = C(0x8A6644)
    let tee = C(0x4E6A80), teeD = C(0x3A5064)
    let jeans = C(0x384A6A), jeansD = C(0x283652)
    let hair = C(0x2E2016), hairD = C(0x1A120C), hairL = C(0x4A3828)
    let cam = C(0x1E1E24), silver = C(0xB8BCC4), lens = C(0x3A4A6A)
    let k = hawkinsSpan(p, 0.08, 0.92)
    let shooting = k >= 0

    drawLegs(c, Look(leg: jeans), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx, hawkinsFoot(p, i) - 3, jeansD) } }
    drawBoots(c, C(0xB8B4A8), step: p.step, rows: 2)
    drawBoots(c, C(0x6A665C), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: jacket), armRight: shooting ? 4 : 0)

    // The cord jacket, open over the tee: the wale in short dark strokes, lit lapels and shoulders, the far side and
    // the hem in shade.
    c.rect(18, 33, 20, 5, jacket); c.rect(25, 33, 6, 5, tee); c.rect(25, 37, 6, 1, teeD)
    for x in [20, 22, 34, 36] { c.rect(x, 34, 1, 3, jacketD) }
    c.rect(24, 33, 1, 5, jacketL); c.rect(31, 33, 1, 5, jacketD); c.rect(37, 33, 1, 5, jacketD)
    c.rect(18, 37, 7, 1, jacketD); c.rect(31, 37, 7, 1, jacketD)
    c.rect(19, 33, 4, 1, jacketL); c.rect(33, 33, 3, 1, jacketL)
    c.rect(15, 35, 3, 1, jacketD)

    // The hair: dark and shaggy, swept across his brow from the left, over his ears and down to his collar.
    c.pattern(16, 20, [
        "......HHHHHHHHHHH.......",
        "....HHHHlllHHHHHHHH.....",
        "...HHHHHHHlllHHHHHHH....",
        "..HHHhHHHHHHHlllHHHHH...",
        "..HHHHhHHHHHHHHHlllHHH..",
        ".HHHHHHHhHHHHHHHHHHHHHH.",
        ".HHHHH.......HHHHHHHHHHH",
        ".HHHH..........HhHHhHHH.",
        ".HHH...............hHHd.",
        ".HhH................HHd.",
        ".HHh................hHd.",
        "..Hh................hd..",
    ], ["H": hair, "d": hairD, "h": hairD, "l": hairL])

    if shooting {
        // The camera up at his eye, the flash on top, his fingers under it.
        c.pattern(29, 25, [
            "..FFFF....",
            "..FwwF....",
            "sssKKsss..",
            "KKKKKKKKgg",
            "KKKKKKKKgG",
            "KKKKKKKKgg",
            "KKKKKKKK..",
        ], ["F": C(0x3A3A42), "w": C(0xE8ECF4), "s": silver, "K": cam, "g": C(0x2A2A30), "G": lens])
        c.rect(30, 32, 4, 1, clawdOrange); c.rect(35, 30, 3, 2, clawdOrange)
        if k > 0.45 && k < 0.62 {
            // The flash: a white-hot burst, its rays fading out round it.
            let f = (k - 0.45) / 0.17
            let r = 3 + f * 5, a = 1 - f
            c.rect(31, 24, 4, 4, C(0xFFFFFF, a))
            for i in 0..<8 {
                let ang = Double(i) * .pi / 4
                c.glowLine(33 + cos(ang) * 2, 26 + sin(ang) * 2, 33 + cos(ang) * r, 26 + sin(ang) * r,
                           core: C(0xFFFFF0), glow: C(0xFFF4C0), coreR: 0.4, glowR: 1.2, strength: 0.22 * a)
            }
        }
        return
    }
    // The camera hanging on his chest: a silver top, the black body, the lens.
    c.px(25, 33, cam); c.px(30, 33, cam)
    c.pattern(24, 34, ["sssKKsss", "KKKggKKK", "KKgGLgKK", "KKKggKKK"],
              ["s": silver, "K": cam, "g": C(0x2A2A30), "G": lens, "L": C(0x8AA0C8)])

    c.oy += p.gunY
    c.rect(38, 33, 3, 3, jacket)
    hawkinsRevolver(c)
}

// MARK: - Robin Buckley

/// Robin Buckley in her Scoops Ahoy uniform: a white sailor's cap with a navy band on her dark-blonde bob, a blue and
/// white striped top with a navy sailor collar trimmed in white and a red neckerchief, navy shorts, white socks and
/// sneakers. She doesn't fight. Signature: she snaps a salute to the brim of her cap ("Ahoy!").
private func drawRobinBuckley(_ c: PixelCanvas, _ p: Pose) {
    let stripe = C(0xF0F2F6), stripeB = C(0x7AA8D8), stripeD = C(0x5A86B8)
    let navy = C(0x24386E), navyD = C(0x18264E), trim = C(0xF4F4F4), scarf = C(0xD8302E), scarfD = C(0xA81E1E)
    let hat = C(0xF4F4F0), hatD = C(0xC8CCD0)
    let hair = C(0xA27A44), hairD = C(0x7A5A30), hairL = C(0xC49A5E)
    let k = hawkinsSpan(p, 0.08, 0.92)
    let salute = hawkinsEase(k, edge: 0.15) > 0.6

    // Bare legs under navy shorts, white socks and sneakers.
    drawLegs(c, Look(leg: clawdOrange), step: p.step)
    drawBoots(c, C(0xF0F0EC), step: p.step, rows: 3)
    drawBoots(c, C(0xB8BCC4), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: stripe), armRight: salute ? 7 : 0)

    // The striped top, the shorts' waistband under it and the shorts over the tops of her legs.
    c.rect(18, 33, 20, 5, stripe)
    for y in [34, 36] { c.rect(18, y, 20, 1, stripeB) }
    c.rect(37, 33, 1, 5, C(0xC8CCD4)); c.px(37, 34, stripeD); c.px(37, 36, stripeD)
    c.rect(18, 37, 20, 1, navy)
    if !seatedPose { for x in [19, 23, 31, 35] { c.rect(x, 38, 2, 1, navy); c.px(x + 1, 38, navyD) } }
    c.px(15, 34, stripeB); c.px(16, 34, stripeB); c.px(17, 34, stripeB)
    // The sailor collar in a V, its white trim, and the red neckerchief knotted at the front.
    c.pattern(22, 33, ["wNNNNSSNNNNw", ".wNNNSSNNNw.", "..wNSSSSNw..", ".....SS....."],
              ["N": navy, "w": trim, "S": scarf])
    c.px(28, 35, scarfD); c.px(27, 36, scarfD)

    // The dark-blonde bob under the cap: a fringe, lit on top, down to her jaw.
    c.pattern(16, 20, [
        "....HHHHH........HHHH...",
        "...HHHHHHHHHHHHHHHHHH...",
        "..HHllHHHHHHHHllHHHHHH..",
        "..HHHHHHHHHHHHHHHHHHHHd.",
        ".HHHHHHHHHHHHHHHHHHHHHd.",
        ".HHHHHHHHHHHHHHHHHHHHHd.",
        ".HHHH..............HHHd.",
        ".HHH................HHd.",
        ".HHH................HHd.",
        ".HlH................HdH.",
        ".HHH................HdH.",
        ".HHd................dHH.",
        "..dd................dd..",
    ], ["H": hair, "d": hairD, "l": hairL])
    // The cap: a white crown, the navy band, the brim turned up all round.
    c.pattern(20, 16, [
        "...hhhhhhhhh...",
        "..hHHHHHHHHHh..",
        ".BBBBBBBBBBBBB.",
        "WWWWWWWWWWWWWWW",
        ".ddddddddddddd.",
    ], ["h": hatD, "H": hat, "B": navy, "W": hat, "d": hatD])
    c.rect(23, 16, 4, 1, hat)

    guard salute else { return }
    // The salute: her forearm up across to the brim, the hand flat against it.
    hawkinsLine(c, 39.5, 27.5, 36.5, 22.5, stripe, 1.1)
    c.rect(32, 21, 5, 2, clawdOrange); c.rect(32, 22, 5, 1, clawdShade)
}

// MARK: - Eddie Munclawd

/// Eddie Munclawd: a big mane of long dark curls down past his shoulders, the Hellfire Club t-shirt (black, the club's
/// red-horned white skull on the chest) under a denim vest with a couple of pins, black jeans with a chain at the hip and
/// black boots. He fights as he did in the Upside Down: a spear with a knife lashed to the end, and a dustbin lid for a
/// shield, nails driven through it, on his other arm. Signature: he swaps them for his guitar and plays a solo, his
/// head banging, the notes flying off it.
private func drawEddieMunclawd(_ c: PixelCanvas, _ p: Pose) {
    let tee = C(0x1A181E), teeD = C(0x0E0C12)
    let denim = C(0x4A6A9A), denimD = C(0x34507A), denimL = C(0x6E8EBE)
    let jeans = C(0x26262E), jeansD = C(0x16161C)
    let hair = C(0x3A2618), hairD = C(0x22160E), hairL = C(0x5E422C)
    let k = hawkinsSpan(p, 0.06, 0.94)
    let solo = k >= 0
    let bang = solo && k > 0.2 && k < 0.85 && Int(p.t * 4) % 2 == 0 ? 1 : 0

    // The dustbin-lid shield on his far arm, behind him: dull grey metal, a ring pressed into it, the handle's
    // rivet in the middle, and the nails sticking out all round.
    if !solo {
        let sc = (x: 11.0, y: 33.0)
        for i in 0..<10 {
            let a = Double(i) * 36 + 18
            let b = hawkinsReach(sc, a, 4.5), e = hawkinsReach(sc, a, 6.6)
            hawkinsLine(c, b.x, b.y, e.x, e.y, C(0xB8BCC4), 0.4)
        }
        for y in -5...5 {
            for x in -5...5 where x * x + y * y <= 22 {
                let d = x * x + y * y
                let col = d >= 15 ? C(0x5A5E66) : d >= 8 && d <= 11 ? C(0x6E727A) : x + y < -2 ? C(0xA4A8B0) : C(0x8A8E96)
                c.px(11 + x, 33 + y, col)
            }
        }
        c.px(11, 33, C(0x3A3E46)); c.px(9, 30, C(0xC8CCD4)); c.px(13, 36, C(0x6A5A4A))
    }

    // Black jeans, the knees worn pale, and black boots with a lit toe.
    drawLegs(c, Look(leg: jeans), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx, hawkinsFoot(p, i) - 4, C(0x3E3E48)) } }
    drawBoots(c, C(0x141418), step: p.step, rows: 2)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 1, C(0x3A3A42)) } }

    c.oy += p.breathe
    drawBody(c, Look(arm: tee), armRight: solo ? 4 : 0)

    // The Hellfire tee between the open vest, the club's red-horned white skull on it.
    c.rect(18, 33, 20, 5, tee); c.rect(24, 37, 8, 1, teeD)
    c.pattern(25, 34, ["R....R", ".WWWW.", ".WkWk.", "..WW.."], ["R": C(0xD0222C), "W": C(0xE8E4DC), "k": tee])
    // The denim vest: its edges lit, a seam down each side, a red and a white pin, the far side and the hem darker.
    c.rect(18, 33, 6, 5, denim); c.rect(32, 33, 6, 5, denim)
    c.rect(18, 33, 1, 5, denimL); c.rect(19, 33, 4, 1, denimL); c.rect(23, 33, 1, 5, denimL)
    c.rect(32, 33, 1, 5, denimD); c.rect(37, 33, 1, 5, denimD); c.rect(18, 37, 6, 1, denimD); c.rect(32, 37, 6, 1, denimD)
    c.rect(21, 34, 1, 3, denimD); c.rect(34, 34, 1, 3, denimD)
    c.px(20, 35, C(0xD83A3A)); c.px(35, 35, C(0xE8E8E0))
    c.rect(15, 35, 3, 1, teeD)
    // The wallet chain looping from his belt round to his back pocket.
    c.pattern(18, 38, ["s.s.s", ".s.s."], ["s": C(0xB8BCC4)])

    // The mane: long dark curls, lit in little round strokes, falling over his far shoulder and down past his collar,
    // a lock hanging forward over his near shoulder. It bangs a row lower on the beat of the solo.
    c.pattern(14, 17 + bang, [
        "..........HHHHHHH..........",
        ".......HHHlHHlHHHHHH.......",
        ".....HHlHHhHlHHhHlHHHH.....",
        "....HlHHhHHHHhHHHhHHHhH....",
        "...HHHhHHlHHhHHlHHhHHHhH...",
        "..HlHHHHHhHHHHHhHHHHHlHHH..",
        "..HHhHlHHHHHlHHHHHlHHHhHH..",
        ".HlHHhHHHhHHHHhHHHHhHHHHhH.",
        ".HHhHHHHHHhHHHHHHhHHHhHlHH.",
        "HlHHhH...............HhHHH.",
        "HHhHlH................HlHH.",
        "HlHHhH................HhHH.",
        "HHhlHH................hHlH.",
        "HlHHhH................HHhH.",
        "HHhHHl................hHH..",
        "HlHHhH................Hh...",
        "HHlHhH....................",
        ".HHhHH.....................",
        "HlHhHl.....................",
        ".HhHH......................",
        "..Hh.......................",
    ], ["H": hair, "h": hairD, "l": hairL])

    if solo {
        // The guitar slung across him: a red, pointed body with a black edge and two pickups, the dark neck rising to
        // his fretting hand and a spiked headstock; his picking hand jumping over the strings.
        c.pattern(19, 32, [
            "KR..........",
            ".KRRRRRRK...",
            "..RRwRwRRR..",
            "..RRRRRRRR..",
            ".KRRRRRRK...",
            "KR..........",
        ], ["R": C(0xC8202E), "K": C(0x1A1A1E), "w": C(0xE8E8E0)])
        c.rect(22, 33, 4, 1, C(0xE8505A))
        hawkinsLine(c, 29.5, 34.5, 45.5, 26.5, C(0x2A1A10), 0.75)
        hawkinsLine(c, 30.5, 34, 45, 26.8, C(0x6A4A30), 0.3)
        c.pattern(45, 23, ["K.K.", ".KKK", "KKK.", "..K."], ["K": C(0x1A1A1E)])
        c.rect(38, 28, 3, 3, clawdOrange)
        let pick = Int(p.t * 8) % 2
        c.rect(26, 34 + pick, 2, 2, clawdOrange)
        // The notes flying off it, solid little quavers rising and drifting.
        for i in 0..<2 {
            let f = (k * 3 + Double(i) * 0.5).truncatingRemainder(dividingBy: 1)
            guard k > 0.1 && k < 0.9 else { break }
            let x = 49 + i * 5 + Int(f * 4), y = 26 - Int(f * 10)
            c.rect(x, y, 2, 1, C(0xF4F0E0)); c.rect(x + 1, y - 3, 1, 3, C(0xF4F0E0)); c.px(x + 2, y - 3, C(0xF4F0E0))
        }
        return
    }
    if let a = p.melee {
        eddieSpear(c, angle: a, trail: p.trail)
    } else {
        eddieSpear(c, angle: -80, trail: [])
    }
}

/// Eddie's spear along `angle` from his hand: a pale wooden shaft, a twist of black tape, and a kitchen knife lashed to
/// the end, lit along its edge; a smear where a fast thrust just was.
private func eddieSpear(_ c: PixelCanvas, angle a: Double, trail: [Double]) {
    let h = Sprite.hand
    hawkinsSmear(c, h, trail, from: 12, to: 18, C(0xE4ECF4))
    hawkinsBar(c, h, a, from: -3, to: 15, C(0x8A6440), r: 0.7)
    hawkinsBar(c, h, a, from: -3, to: 14, C(0xB08858), r: 0.25)
    hawkinsBar(c, h, a, from: 13, to: 15.5, C(0x2A2A30), r: 0.85)
    hawkinsBar(c, h, a, from: 15.5, to: 18.5, C(0xA8ACB6), r: 0.85)
    hawkinsBar(c, h, a, from: 18.5, to: 20, C(0xD8DCE4), r: 0.45)
    let e0 = hawkinsReach(hawkinsReach(h, a, 15.8), a - 90, 0.6), e1 = hawkinsReach(hawkinsReach(h, a, 18.6), a - 90, 0.6)
    hawkinsLine(c, e0.x, e0.y, e1.x, e1.y, C(0xEEF2F8), 0.3)
    c.rect(Int(h.x.rounded()) - 1, Int(h.y.rounded()) - 1, 3, 3, clawdOrange)
}

// MARK: - Argyle

/// Argyle in his Surfer Boy Pizza uniform: long, straight black hair parted in the middle and falling past his
/// shoulders, sleepy, half-shut eyes and a grin, a loud short-sleeved shirt open over the pizza place's white tee (its
/// orange sunset and yellow wave on the chest), a name tag, baggy blue trousers and white hi-tops. He doesn't fight.
/// Signature: he holds out a slice of pizza, pineapple and ham, the cheese stretching ("Duuude.").
private func drawArgyle(_ c: PixelCanvas, _ p: Pose) {
    let shirt = C(0x2A9A9A), shirtD = C(0x1E7276), shirtL = C(0x4ABCB8), pink = C(0xE0488E), yellow = C(0xF2D040)
    let tee = C(0xF2F0EA), teeD = C(0xCFCBC2)
    let pants = C(0x3A4E9A), pantsD = C(0x2A3A78)
    let hair = C(0x1A1614), hairD = C(0x0C0A08), hairL = C(0x3A3230)
    let k = hawkinsSpan(p, 0.08, 0.92)
    let out = Int((hawkinsEase(k, edge: 0.2) * 5).rounded())

    drawLegs(c, Look(leg: pants), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 4, pantsD) } }
    drawBoots(c, C(0xEEEEE8), step: p.step, rows: 3)
    drawBoots(c, C(0xB0B0B8), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: shirt))
    // Sleepy eyes: the lids half down.
    c.rect(22, 29, 2, 1, clawdShade); c.rect(32, 29, 2, 1, clawdShade)
    c.pattern(25, 32, ["m.....m", ".mmmmm."], ["m": C(0x5A1A1E)])

    // The loud shirt, open over the tee: teal, with pink zigzags and yellow dots, lit along its edges, the far side
    // and the hem darker; the tee's logo in the gap, and the name tag.
    c.rect(18, 33, 20, 5, shirt)
    c.rect(24, 33, 8, 5, tee); c.rect(24, 37, 8, 1, teeD)
    c.pattern(25, 34, [".oooo.", "yyyyyy"], ["o": C(0xF08A30), "y": yellow]); c.rect(26, 33, 4, 1, teeD)
    c.rect(18, 33, 1, 5, shirtL); c.rect(23, 33, 1, 5, shirtL); c.rect(32, 33, 1, 5, shirtD); c.rect(37, 33, 1, 5, shirtD)
    c.pattern(19, 34, ["p.p.", ".p.p", "y..y"], ["p": pink, "y": yellow])
    c.pattern(33, 35, ["p.p.", ".p.y"], ["p": pink, "y": yellow])
    c.rect(33, 33, 3, 2, C(0xF4F4F0)); c.rect(33, 34, 3, 1, C(0xC8302A))
    c.rect(18, 37, 6, 1, shirtD); c.rect(32, 37, 6, 1, shirtD)
    c.rect(15, 35, 3, 1, shirtD)

    // The hair: long, straight and black, parted in the middle, combed down in long strokes past his shoulders.
    c.pattern(15, 19, [
        ".......HHHHHHHHHHHHHH.....",
        ".....HHHHlHHHHHHlHHHHHH...",
        "....HHHlHHHHHdHHHHlHHHHH..",
        "...HHHlHHHHHHdHHHHHlHHHHH.",
        "...HHlHHHHHHHdHHHHHHlHHHH.",
        "..HHHHHHHHHHddHHHHHHHHHHH.",
        "..HHHHHHHHHHdHHHHHHHHHHHH.",
        "..HHHH................HHH.",
        "..HlH.................HHd.",
        "..HlH.................HHd.",
        "..HHd.................HHd.",
        ".HHHd.................HHd.",
        ".HlHd.................HdH.",
        ".HlHd.................HdH.",
        ".HHHd.................dHH.",
        ".HHd..................dH..",
    ], ["H": hair, "d": hairD, "l": hairL])

    guard out > 0 else { return }
    // The slice held out on his palm: the crust nearest him, the cheese and its pineapple and ham, the tip forward.
    c.rect(38, 32, 2 + out, 3, shirt); c.rect(38, 32, 2 + out, 1, shirtL)
    let x = 40 + out
    c.rect(x, 33, 3, 2, clawdOrange)
    c.pattern(x - 1, 27, [
        "BB......",
        "BCCC....",
        "BCyCpC..",
        "BCCCCCCC",
        "BbCpCy..",
        "Bb......",
    ], ["B": C(0xC88A44), "b": C(0x9A6430), "C": C(0xF4D060), "y": C(0xF8E890), "p": C(0xE07A80)])
    if out >= 5 && Int(p.t * 3) % 2 == 0 { c.px(x + 4, 33, C(0xF4D060)) }   // a string of cheese
}

// MARK: - Barb

/// Barb: short auburn hair in soft curls, big round glasses, a pale pink blouse with a big white frilled collar, a
/// frill down the front and puffed sleeves, high-waisted jeans with a brown belt and white sneakers. She doesn't fight.
/// Signature: she pushes her glasses back up her nose with one finger.
private func drawBarb(_ c: PixelCanvas, _ p: Pose) {
    let blouse = C(0xEEC4CC), blouseD = C(0xCC9CA8), blouseL = C(0xFADCE2), frill = C(0xFAF8F4), frillD = C(0xD8D2CC)
    let jeans = C(0x5A7AAA), jeansD = C(0x44608A)
    let hair = C(0xA04A28), hairD = C(0x74321A), hairL = C(0xC86A3C)
    let frame = C(0x9A7A70), glint = C(0xE8F0FA)
    let k = hawkinsSpan(p, 0.1, 0.9)
    let push = hawkinsEase(k, edge: 0.25) > 0.5
    let up = push && k > 0.4 && k < 0.65 ? 1 : 0

    drawLegs(c, Look(leg: jeans), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 4, jeansD) } }
    drawBoots(c, C(0xF0F0EA), step: p.step, rows: 2)
    drawBoots(c, C(0xB4B4BC), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: blouse), armRight: push ? 3 : 0)

    // The blouse: pale pink, lit along the shoulders, the far side in shade, tucked into the
    // jeans' high waist with its belt.
    c.rect(18, 33, 20, 4, blouse)
    c.rect(19, 33, 4, 1, blouseL); c.rect(37, 33, 1, 4, blouseD); c.px(21, 35, blouseD); c.px(34, 35, blouseD)
    c.rect(18, 37, 20, 1, jeans); c.rect(18, 36, 20, 1, C(0x6A4428)); c.rect(27, 36, 2, 1, C(0xC8B070))
    // The big frilled collar, ruffled, falling in a V from her shoulders to the frill at the front.
    c.pattern(22, 33, ["fFf......fFf", ".fFf....fFf.", "..fFf..fFf..", "...fFffFf..."], ["f": frill, "F": frillD])
    // Puffed sleeves.
    c.rect(15, 33, 3, 2, blouseL); c.px(17, 35, blouseD); c.rect(15, 35, 3, 1, blouseD)

    // Soft auburn curls: short, round on top, lit in curling strokes, down to her jaw.
    c.pattern(16, 20, [
        "......HHHHHHHHHH........",
        "....HHlHHlHHHlHHHH......",
        "..HHHlHHhHlHHhHlHHHH....",
        ".HHlHHhHHHHhHHHHhHHHH...",
        ".HHHHhHlHHHHlHHHHhHHHd..",
        "HHlHHHHHHhHHHHHhHHHHHd..",
        "HHHhH.............HHhHd.",
        "HlHHd..............HHHd.",
        "HHhH................HhH.",
        ".HlHd...............dHd.",
        ".HHh................dH..",
        "..Hd....................",
    ], ["H": hair, "d": hairD, "h": hairD, "l": hairL])

    // The big round glasses, their frames round her eyes, a bridge between, a glint in each lens.
    c.pattern(20, 27 - up, [
        ".FFFFF....FFFFF.",
        "F.....FFFF.....F",
        "Fg....F..F.g...F",
        "F.....F..F.....F",
        ".FFFFF....FFFFF.",
    ], ["F": frame, "g": glint])

    guard push else { return }
    // Her forearm up across her front, one finger on the bridge of her glasses.
    hawkinsLine(c, 39.5, 30.5, 31, 29.5, blouse, 1.0)
    c.rect(28, 28 - up, 3, 2, clawdOrange); c.px(28, 27 - up, clawdOrange)
}

// MARK: - Derek Turnbow

/// Derek Turnbow, Holly's classmate, about ten: a kid, so he stands lower than the teenagers, his brown hair neatly
/// combed with a side parting and a stiff quiff, a sneer, and what he wears in season 5: a sweater striped in bright
/// bands (red, yellow, blue, green) under a beige vest lined with flannel, its edges showing the red check, jeans
/// and white sneakers. He doesn't fight, and has no signature move.
private func drawDerekTurnbow(_ c: PixelCanvas, _ p: Pose) {
    let bands = [C(0xC8382E), C(0xE8B830), C(0x3A6AB8), C(0x3E9A5A)]
    let vest = C(0xC8B48A), vestD = C(0xA08E66), vestL = C(0xE0D0AA), lining = C(0xA8302A), liningL = C(0xD8C8B0)
    let jeans = C(0x5A74A0), jeansD = C(0x42587E)
    let hair = C(0x6A4628), hairD = C(0x48301A), hairL = C(0x8E643C)
    let lower = seatedPose ? 0 : 2

    drawLegs(c, Look(leg: jeans), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 3, jeansD) } }
    drawBoots(c, C(0xEEEEE8), step: p.step, rows: 2)
    drawBoots(c, C(0xA8ACB4), step: p.step, rows: 1)

    // Shorter than the teenagers: the whole of him above the legs sits two rows lower.
    c.oy += lower + p.breathe
    drawBody(c, Look(arm: bands[0]))
    // The sneer: one brow pulled down, the lip curled up at one side.
    c.rect(31, 28, 3, 1, clawdShade)
    c.pattern(25, 32, ["mmmm.", "....m"], ["m": C(0x5A1A1E)]); c.px(29, 31, C(0x5A1A1E))

    // The striped sweater: a band of colour a row, across his front and down each sleeve, the crew neck ribbed.
    for row in 0..<5 { c.rect(18, 33 + row, 20, 1, bands[row % 4]) }
    for row in 0..<3 { c.rect(15, 33 + row, 3, 1, bands[(row + 1) % 4]); c.rect(38, 33 + row, 3, 1, bands[(row + 1) % 4]) }
    c.rect(25, 33, 6, 1, C(0x9E2A24))
    // The vest over it, open down the front: beige, lit along the shoulders, its flannel lining showing red check at
    // the front edges, a pocket flap each side, the far side and the hem in shade.
    c.rect(18, 33, 7, 5, vest); c.rect(31, 33, 7, 5, vest)
    c.rect(19, 33, 4, 1, vestL); c.rect(32, 33, 3, 1, vestL); c.rect(18, 33, 1, 5, vestL)
    for y in 33...37 { c.px(24, y, y % 2 == 0 ? lining : liningL); c.px(31, y, y % 2 == 0 ? liningL : lining) }
    c.rect(20, 35, 3, 1, vestD); c.rect(33, 35, 3, 1, vestD)
    c.rect(37, 33, 1, 5, vestD); c.rect(18, 37, 6, 1, vestD); c.rect(32, 37, 6, 1, vestD)

    // Neatly combed brown hair: a side parting, a stiff quiff at the front, short at the sides.
    c.pattern(17, 20, [
        "..........HHHHHH......",
        ".....HHHHHlllHHHHH....",
        "...HHHHlllHHHHHHlHHH..",
        "..HHlHHHHHHdHHHHHHHHH.",
        ".HHHHHHHHHHdHHHHHHHHHd",
        ".HHHHHHHhHHdHHHHhHHHHd",
        ".HHH..............HHHd",
        ".HH................HH.",
    ], ["H": hair, "d": hairD, "h": hairD, "l": hairL])
}
