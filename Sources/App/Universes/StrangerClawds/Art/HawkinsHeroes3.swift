import Foundation

// Heroes: the teenagers. Clawd in costume like the rest, with Clawd's own orange face showing. Steve wears his season
// 2 jacket rather than the Scoops Ahoy uniform, so he and Robin never look alike. Eddie, Argyle, Barb and Derek are
// stand-ins for now, in their colours; they're drawn properly with the rest of the cast.

let hawkinsHeroes3: [HawkinsHero: Persona] = [
    .steveHarringclawd: Persona(name: "Steve Harringclawd", weapon: .saber, headTop: 15, signature: 3.4,
                                draw: drawSteveHarringclawd),
    .nancyWheeler: Persona(name: "Nancy Wheeler", weapon: .blaster, shot: .bullet, muzzle: (52, 31), headTop: 20,
                           signature: 3.0, draw: drawNancyWheeler),
    .jonathanByers: Persona(name: "Jonathan Byers", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 20,
                            signature: 3.0, draw: drawJonathanByers),
    .robinBuckley: Persona(name: "Robin Buckley", headTop: 16, signature: 2.8, callout: "Ahoy!", draw: drawRobinBuckley),
    // Stand-ins until they're drawn: the engine's plain figure in their colours.
    .eddieMunclawd: Persona(name: "Eddie Munclawd", weapon: .saber,
                            draw: { c, p in drawStandIn(c, p, body: C(0x2A2A30), trim: C(0x5A6E96)) }),
    .argyle: Persona(name: "Argyle", callout: "Duuude.",
                     draw: { c, p in drawStandIn(c, p, body: C(0xD84A2A), trim: C(0xF0C838)) }),
    .barb: Persona(name: "Barb", draw: { c, p in drawStandIn(c, p, body: C(0xE8C8D0), trim: C(0x8A5A3A)) }),
    .derekTurnbow: Persona(name: "Derek Turnbow", draw: { c, p in drawStandIn(c, p, body: C(0x3A8A5A), trim: C(0xEDEDE8)) }),
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
