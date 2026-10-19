import Foundation

// Heroes: the rest of the Party. Clawd in costume like the others, with Clawd's own orange face showing. The kids share
// one body, so each is told apart by what's on top and round them: Lucas's flat crop and camo bandana, Will's round bowl
// cut, Max's long red hair and the skateboard at her back, and Erica, the youngest, standing lower under her two puffs.

let hawkinsHeroes2: [HawkinsHero: Persona] = [
    .lucasSinclawd: Persona(name: "Lucas Sinclawd", weapon: .blaster, shot: .thrown(C(0xA4A4AC)), muzzle: (41, 29),
                            headTop: 22, signature: 3.0, draw: drawLucasSinclawd),
    .willByers: Persona(name: "Will Byers", weapon: .lightning,
                        magic: Magic(core: C(0xF0E4FF), glow: C(0x8A4AE0), jagged: false, waves: true),
                        headTop: 20, signature: 3.2, draw: drawWillByers),
    .maxMayfield: Persona(name: "Max Mayfield", headTop: 20, signature: 4.2, draw: drawMaxMayfield),
    .ericaSinclair: Persona(name: "Erica Sinclair", headTop: 20, signature: 3.0, callout: "Nerds.", draw: drawEricaSinclair),
]

// MARK: - Lucas Sinclawd

/// Lucas Sinclawd: his hair cropped short and flat, a camo bandana tied round his forehead, its knot's tails flying out
/// behind; an olive army jacket open over a red tee, a pair of binoculars hanging on his chest, khakis and brown
/// hi-tops. He fights with his wrist-rocket, a black slingshot with amber bands, flinging stones. Signature: he lifts
/// the binoculars to his eyes and keeps watch, the lenses glinting.
private func drawLucasSinclawd(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x5E6A3A), jacketD = C(0x434C28), jacketL = C(0x7C8852)
    let tee = C(0x8E2E2A), teeD = C(0x6A1E1C)
    let khaki = C(0x9C8A62), khakiD = C(0x7A6A48)
    let hair = C(0x1E1612), hairL = C(0x3C2E26)
    let camo = C(0x5A6A34), camoD = C(0x2E3A1C), camoT = C(0xA8946A), camoB = C(0x6E4E2E)
    let bino = C(0x22222A), glass = C(0x5A7AA8), bridge = C(0x44444E)
    let looking = hawkinsSpan(p, 0.08, 0.92) >= 0

    // Khakis with a crease at each knee, and brown hi-tops on pale soles.
    drawLegs(c, Look(leg: khaki), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 4, khakiD) } }
    drawBoots(c, C(0x5A3A24), step: p.step, rows: 3)
    drawBoots(c, C(0xC8BCA4), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: jacket), armRight: looking ? 4 : 0)

    // The army jacket, open over the red tee: lit lapel and shoulders, a flapped pocket each side, the far side darker.
    c.rect(18, 33, 20, 5, jacket); c.rect(25, 33, 6, 5, tee); c.rect(25, 37, 6, 1, teeD)
    c.rect(24, 33, 1, 5, jacketL); c.rect(31, 33, 1, 5, jacketD); c.rect(37, 33, 1, 5, jacketD)
    c.rect(18, 37, 7, 1, jacketD); c.rect(31, 37, 7, 1, jacketD)
    c.rect(19, 33, 4, 1, jacketL); c.rect(20, 35, 3, 1, jacketD); c.rect(33, 35, 3, 1, jacketD)
    c.rect(15, 35, 3, 1, jacketD)   // the cuff

    // Hair cropped short and flat on top, lit in short strokes, and the bandana tied round his forehead.
    c.rect(21, 22, 14, 1, hair); c.rect(19, 23, 18, 1, hair); c.rect(18, 24, 20, 1, hair)
    for x in [21, 25, 29] { c.rect(x, 22, 2, 1, hairL) }
    for x in [20, 24, 28, 32] { c.rect(x, 23, 2, 1, hairL) }
    c.px(18, 27, hair); c.px(37, 27, hair)
    c.pattern(17, 25, ["cDDcTTcBBcDDcTcBBcDDcT", "cTcDDcBcTTcDDBcTcDDcBc"],
              ["c": camo, "D": camoD, "T": camoT, "B": camoB])
    // The knot at the back, its two tails flying out behind him.
    c.pattern(12, 24, ["...cc", ".cDcc", "cTc..", "Dc...", "c...."], ["c": camo, "D": camoD, "T": camoT])

    if looking {
        // The binoculars up at his eyes, his hand under them, the lenses catching the light now and then.
        c.pattern(21, 28, ["KKKK......KKKK", "KggK......KggK", "KggKbbbbbbKggK", "KKKK......KKKK"],
                  ["K": bino, "g": glass, "b": bridge])
        c.rect(35, 30, 3, 2, clawdOrange)
        if Int(p.t * 3) % 2 == 0 { c.px(22, 29, white); c.px(32, 29, white) }
        return
    }
    // The binoculars hanging on his chest, the strap round his neck.
    c.px(25, 33, bino); c.px(30, 33, bino)
    c.pattern(24, 34, ["KKKbbKKK", "KgK..KgK", "KKK..KKK"], ["K": bino, "g": glass, "b": bridge])

    // The wrist-rocket in his hand: a black frame, its fork up and the amber bands strung across it.
    c.oy += p.gunY
    c.rect(38, 33, 3, 3, jacket)
    let pull = p.fire.map { ($0.t / p.firePeriod).truncatingRemainder(dividingBy: 1) < 0.35 } ?? false
    c.pattern(39, 28, ["K..K", "K..K", pull ? "K..K" : "KbbK", ".KK.", ".KK.", ".KK."],
              ["K": C(0x2A2A2E), "b": C(0xD0A048)])
    c.px(39, 28, C(0x7A7A84)); c.px(42, 28, C(0x7A7A84))
    if pull { hawkinsLine(c, 39.5, 30.5, 36.5, 31.5, C(0xD0A048), 0.5); hawkinsLine(c, 42.5, 30.5, 36.5, 31.5, C(0xD0A048), 0.5) }
    c.rect(38, 33, 3, 2, clawdOrange)   // his fist round the grip
}

// MARK: - Will Byers

/// Will Byers: the round brown bowl cut, its fringe straight across his brow and down over his ears; a red flannel
/// shirt checked with dark lines, open at the neck over a white tee, faded jeans and white sneakers. His power, from
/// season 5, is violet waves pulsing out of his raised hand. Signature: he holds up one of his drawings, a black crayon
/// spider of a monster under a red sky.
private func drawWillByers(_ c: PixelCanvas, _ p: Pose) {
    let flannel = C(0x9E3430), flannelD = C(0x6E1E20), check = C(0x4A1214), thread = C(0xD8B890)
    let tee = C(0xECE6D8)
    let jeans = C(0x7088AA), jeansD = C(0x52688C)
    let hair = C(0x5A3A24), hairD = C(0x3E2616), hairL = C(0x7E5836)
    let show = hawkinsSpan(p, 0.06, 0.94)
    let lift = Int((hawkinsEase(show, edge: 0.18) * 7).rounded())

    drawLegs(c, Look(leg: jeans), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx, hawkinsFoot(p, i) - 4, jeansD) } }
    drawBoots(c, C(0xE4E4DE), step: p.step, rows: 2)
    drawBoots(c, C(0x9A9AA6), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: flannel), armRight: show >= 0 ? lift : p.armRaise)

    // The flannel: red, checked with dark lines down and across, the collar open over the tee, a button placket and a
    // pocket, the far side and the hem in shade.
    c.rect(18, 33, 20, 5, flannel)
    for x in [21, 34] { c.rect(x, 33, 1, 5, check) }
    c.rect(18, 35, 20, 1, flannelD); c.px(21, 35, check); c.px(34, 35, check)
    c.rect(26, 33, 4, 2, tee)
    c.pattern(24, 33, ["dd....dd", ".dd..dd."], ["d": flannelD])
    c.rect(28, 35, 1, 3, flannelD); c.px(28, 36, thread)
    c.rect(31, 34, 2, 1, check)
    c.rect(37, 33, 1, 5, flannelD); c.rect(18, 37, 20, 1, flannelD)
    c.rect(15, 35, 3, 1, flannelD); c.px(16, 34, check)

    // The bowl cut: round on top, lit in strokes from the crown, the fringe cut straight across his brow and the sides
    // down over his ears.
    c.pattern(17, 20, [
        ".....HHHHHHHHHHHH.....",
        "...HHHlllHHHHHHHHH....",
        "..HHllHHHHlllHHHHHH...",
        ".HHlHHHHHHHHHHHHHhHH..",
        ".HlHHHHHHHHHHHHHHHhHH.",
        "HHHHHHHHHHHHHHHHHHHhHH",
        "HHHHHHHHHHHHHHHHHHHHhH",
        "HHhHHHhHHHhHHHhHHHhHhh",
        "HHh................hHH",
        "HHh................hH.",
        ".Hh................h..",
    ], ["H": hair, "h": hairD, "l": hairL])

    guard show >= 0, lift >= 2 else { return }
    // The drawing, held up in his raised hand: a black crayon spider under a red sky, on white paper.
    let top = 25 - lift
    c.pattern(38, top, [
        "WWWWWWWWWS",
        "WrrkrrkrrS",
        "WkWWkkWWkS",
        "WWkkkkkkWS",
        "WkWkkkkWkS",
        "WWkWWWWkWS",
        "WkWWWWWWkS",
        "SSSSSSSSSS",
    ], ["W": C(0xF4F0E4), "S": C(0xCCC6B4), "r": C(0xD0402E), "k": C(0x1E1E22)])
    c.rect(39, top + 8, 3, 1, clawdOrange)   // his fingers under it
}

// MARK: - Max Mayfield

/// Max Mayfield: long straight red hair swept to one side, a teal zip hoodie with its drawstrings and pocket, jeans and
/// black-and-white skate shoes, a Walkman clipped to her hip, its orange headphones round her neck, and her skateboard
/// slung at her back. She doesn't fight. Signature: she puts the headphones on, then drops the board under her feet
/// and rolls off and back, a note or two floating up.
private func drawMaxMayfield(_ c: PixelCanvas, _ p: Pose) {
    let hoodie = C(0x3A8E96), hoodieD = C(0x286870), hoodieL = C(0x5AB0B6), string = C(0xEDE8DC)
    let jeans = C(0x445C88), jeansD = C(0x30446A)
    let hair = C(0xC4482A), hairD = C(0x8E2E1A), hairL = C(0xE87048)
    let deck = C(0x2E3A86), deckL = C(0x5C6CC4), wheel = C(0xF0D04A), truck = C(0xA8ACB6)
    let pad = C(0xE8862A), padD = C(0xB45E1A), band = C(0x8A8E98)
    let k = hawkinsSpan(p, 0.04, 0.96)
    let reaching = k >= 0 && k < 0.2
    let on = k >= 0.12
    let ride = k >= 0.24 && k < 0.92 ? (k - 0.24) / 0.68 : -1

    if ride >= 0 {
        // Up on the board: everything a little higher, rolling forward and back.
        c.oy -= 3
        c.ox += Int((sin(ride * .pi) * 6).rounded())
    } else {
        // The board slung at her back, on its edge: the deck lit along one side, yellow wheels on grey trucks.
        c.rect(13, 25, 2, 18, deck); c.rect(13, 25, 1, 18, deckL); c.px(14, 24, deck); c.px(14, 43, deck)
        for wy in [27, 39] { c.px(12, wy, truck); c.px(12, wy + 1, truck); c.rect(10, wy, 2, 2, wheel) }
    }

    drawLegs(c, Look(leg: jeans), step: ride >= 0 ? -1 : p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, (ride >= 0 ? 43 : hawkinsFoot(p, i)) - 4, jeansD) } }
    drawBoots(c, C(0x26262A), step: ride >= 0 ? -1 : p.step, rows: 2)
    drawBoots(c, C(0xEDEDE8), step: ride >= 0 ? -1 : p.step, rows: 1)
    if ride >= 0 {
        // The board under her feet, its wheels turning.
        c.rect(16, 44, 26, 1, deckL); c.px(15, 43, deck); c.px(42, 43, deck); c.rect(17, 45, 24, 1, deck)
        for wx in [19, 35] { c.px(wx + 1, 45, truck); c.rect(wx, 46, 3, 1, wheel) }
    }

    c.oy += p.breathe
    drawBody(c, Look(arm: hoodie), armRight: reaching ? 8 : 0)

    // The hoodie: teal, its hood bunched behind her neck, the zip down the middle, drawstrings, the pocket, lit along
    // the shoulders, the far side and the hem in shade.
    c.rect(18, 33, 20, 5, hoodie)
    c.rect(16, 32, 4, 2, hoodieD)
    c.rect(19, 33, 5, 1, hoodieL); c.rect(31, 33, 4, 1, hoodieL)
    c.rect(28, 34, 1, 4, hoodieD); c.px(28, 34, string)
    c.rect(26, 34, 1, 2, string); c.rect(30, 34, 1, 2, string)
    c.rect(22, 36, 12, 1, hoodieD)
    c.rect(37, 33, 1, 5, hoodieD); c.rect(18, 37, 20, 1, hoodieD)
    c.rect(15, 35, 3, 1, hoodieD)
    // The Walkman clipped at her hip.
    c.rect(33, 35, 3, 3, C(0x6E7480)); c.rect(33, 35, 3, 1, C(0x9A9EA8)); c.px(34, 36, pad)

    // Long straight red hair, swept to one side over her brow and falling down her back.
    c.pattern(16, 20, [
        ".......HHHHHHHHHH.......",
        ".....HHHlllHHHHHHHH.....",
        "...HHHlllHHHHHlllHHHH...",
        "..HHHllHHHHHHlllHHHHHH..",
        "..HHlHHHHHHHHHHHHHHHHHd.",
        ".HHHHHHHHHHHHHHHHHHHHHd.",
        ".HHHHHHHHHHHHH....HHHHd.",
        ".HHHHHHHH.........HHHd..",
        ".HHH...............HHd..",
        ".HlH...............HHd..",
        ".HlH...............HHH..",
        ".HHH...............HdH..",
        ".HHH...............HdH..",
        "HHHd...............dHH..",
        "HHHd...............dHH..",
        ".HHd................dH..",
        ".dHd................d...",
        "..dd....................",
    ], ["H": hair, "d": hairD, "l": hairL])

    if !on {
        // The headphones round her neck, or on their way up in her hand.
        if reaching {
            c.rect(36, 24, 5, 1, band); c.rect(36, 25, 2, 2, pad); c.rect(40, 25, 2, 2, pad)
        } else {
            c.rect(22, 32, 12, 1, band); c.rect(21, 32, 2, 2, pad); c.rect(33, 32, 2, 2, pad); c.px(22, 33, padD); c.px(34, 33, padD)
        }
        return
    }
    // On her ears: the band over the top of her head, the orange pads either side.
    c.rect(21, 19, 14, 1, band); c.px(20, 20, band); c.px(35, 20, band)
    c.rect(17, 21, 1, 5, band); c.rect(38, 21, 1, 5, band)
    c.rect(16, 26, 2, 3, pad); c.px(16, 28, padD); c.rect(38, 26, 2, 3, pad); c.px(39, 28, padD)
    guard ride >= 0 else { return }
    // A note or two floating up off her as she rolls.
    for i in 0..<2 {
        let f = (ride * 2 + Double(i) * 0.5).truncatingRemainder(dividingBy: 1)
        let x = 42 + i * 4, y = 20 - Int(f * 8)
        c.rect(x, y, 1, 3, white); c.rect(x - 1, y + 2, 1, 1, white); c.px(x + 1, y, white)
    }
}

// MARK: - Erica Sinclair

/// Erica Sinclair, Lucas's little sister: the youngest, so she stands lower than the rest, her hair up in two round
/// puffs tied with yellow bobbles, a purple sweatshirt with a yellow and a pink stripe across it, dark leggings and
/// white sneakers, her eyelids half down and a smirk: unimpressed. She doesn't fight. Signature: she crosses her arms
/// and taps her foot ("Nerds.").
private func drawEricaSinclair(_ c: PixelCanvas, _ p: Pose) {
    let top = C(0x6A3E9E), topD = C(0x4C2A76), topL = C(0x8A5EBE), yellow = C(0xF0C838), pink = C(0xE85A9A)
    let hair = C(0x1E1410), hairD = C(0x0E0A08), hairL = C(0x3E2E24)
    let mouth = C(0x5A1A1E)
    let k = hawkinsSpan(p, 0.06, 0.94)
    let crossed = k > 0.06 && k < 0.94
    let tap = crossed && k > 0.35 && Int(p.t * 4) % 2 == 0
    let lower = seatedPose ? 0 : 2

    drawLegs(c, Look(leg: C(0x2E3A58)), step: tap ? 1 : p.step)
    drawBoots(c, C(0xEDEDE8), step: tap ? 1 : p.step, rows: 1)

    // Shorter than the others: the whole of her above the legs sits two rows lower.
    c.oy += lower + p.breathe
    drawBody(c, Look(arm: top))
    // Half-closed eyes and a smirk.
    c.rect(22, 29, 2, 1, clawdShade); c.rect(32, 29, 2, 1, clawdShade)
    c.rect(26, 32, 4, 1, mouth); c.px(30, 31, mouth)

    // The sweatshirt: purple, a yellow and a pink stripe across the chest and round the sleeves, a ribbed neck, lit
    // along the shoulders, the far side and the hem in shade.
    c.rect(18, 33, 20, 5, top)
    c.rect(18, 34, 20, 1, yellow); c.rect(18, 35, 20, 1, pink)
    c.rect(19, 33, 4, 1, topL); c.rect(25, 33, 6, 1, topD)
    c.rect(37, 33, 1, 5, topD); c.px(37, 34, C(0xB89A2A)); c.px(37, 35, C(0xB04274))
    c.rect(18, 37, 20, 1, topD)
    c.px(15, 34, yellow); c.px(16, 34, yellow); c.px(17, 34, yellow); c.rect(15, 35, 3, 1, topD)

    // Her hair up in two round puffs, each tied with a yellow bobble, combed back from her brow.
    c.pattern(16, 18, [
        "..PPPP............PPPP..",
        ".PPlPPP..........PPlPPP.",
        ".PlPPPP..........PlPPPP.",
        ".PPPPPd..........PPPPPd.",
        "..PPdd............PPdd..",
        "...TT..............TT...",
        "...HHHHHHHHHHHHHHHHHH...",
        "..HHlHHHHHHHHHHHHlHHHH..",
        "..HHHHHHHHhHHHHHHHHHHd..",
        ".HHH................HHH.",
        ".HH..................HH.",
    ], ["P": hair, "H": hair, "d": hairD, "l": hairL, "T": yellow])
    c.px(20, 24, hairL); c.px(28, 24, hairL)

    guard crossed else { return }
    // Arms crossed tight over her chest, a hand tucked in at each end.
    c.rect(17, 34, 21, 3, top); c.rect(17, 34, 21, 1, topL); c.rect(17, 36, 21, 1, topD)
    c.rect(19, 34, 2, 2, clawdOrange); c.rect(34, 35, 2, 2, clawdOrange)
    c.rect(15, 34, 3, 3, top); c.rect(38, 34, 3, 3, top); c.px(15, 36, topD); c.px(40, 36, topD)
}
