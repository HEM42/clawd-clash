import Foundation

// Heroes: the elves of Rivendell and the old ones of the Old Forest and Fangorn. Elcron, Arwen Undoable and Tom
// Bombadev are Clawd in costume: the elves' long dark hair and pointed ears, the lord's burgundy robe and circlet, the
// princess's blue-grey riding gown, cloak and Evenstar, Tom's blue jacket, yellow boots, battered hat and beard. The
// face is Clawd's own orange, and the eyes stay ink. B-Treebeard isn't Clawd at all: an Ent, half again a Man's
// height (the size is drawn on the canvas, so his `headTop`, his branch arm's shoulder and his `bulk` say so), with
// only a warm Clawd-orange glow left in his eyes.

let ringsHeroes4: [RingsHero: Persona] = [
    .elrond: Persona(name: "Elcron", weapon: .saber, headTop: 20, signature: 3.0,
                     callout: "Cast it into the fire! It's in the crontab.", draw: drawElrond),
    .arwen: Persona(name: "Arwen Undoable", weapon: .saber, headTop: 20, signature: 3.4,
                    callout: "If you want him, come and revert him!", draw: drawArwen),
    .treebeard: Persona(name: "B-Treebeard", weapon: .saber, canSit: false, pivot: treebeardShoulder, bulk: 6, headTop: 8,
                        signature: 3.6, callout: "Hrum, don't be hasty. Rebalancing takes O(log n) ages.", draw: drawTreebeard),
    .bombadil: Persona(name: "Tom Bombadev", weapon: .none, headTop: 9, signature: 2.8,
                       callout: "Hey dol! merry dol! Deploy on a Friday-o!", draw: drawBombadil),
]

// MARK: - Elcron

/// Elcron, the lord of Rivendell: a long burgundy robe to the ankles, flaring a little, trimmed in gold at the collar,
/// down the front and round the hem, with wide sleeves and a gold sash; long straight dark hair to below the shoulders,
/// a pointed ear poking out of it either side, and a thin silver circlet across the brow. His elven sword, a slender
/// curved blade with a gold guard, stands upright in his fist at rest; swung, it smears behind a fast stroke.
/// Signature: his cron job comes due: a little gold alarm clock pops up over his head and he looks up at it; its hand
/// ticks round once, a step at a time, and at the top of the hour it rings, shaking between its bells, then it's gone.
private func drawElrond(_ c: PixelCanvas, _ p: Pose) {
    defer { if let s = p.signature { drawElcronClock(c, s) } }
    let robe = C(0x6E1E2A), robeShade = C(0x501420), robeLight = C(0x8E2E3A)
    let gold = C(0xC8A040), goldDark = C(0x9A7A2A)
    let hair = C(0x2A1E1A), hairLight = C(0x46362E), silver = C(0xD0D8E0)
    drawLegs(c, Look(leg: robeShade), step: p.step)
    drawBoots(c, p.step, C(0x3A2A20), rows: 1)
    c.oy += p.breathe
    // His hair down his back, past the shoulders.
    c.pattern(14, 26, ["HHHH", "HHlH", "HHHH", "lHHH", "HHHH", "HHlH", "HHHH", ".HHH", ".HH."], ["H": hair, "l": hairLight])
    drawBody(c, Look(arm: robe))
    // The robe, the shoulders to the ankles, flaring a little, gold at the collar, down the front and round the hem.
    c.rect(18, 32, 20, 6, robe)
    c.rect(37, 32, 1, 6, robeShade)
    for y in 38...41 where y + c.oy <= 43 {
        let k = y - 38, l = 17 - (k + 1) / 2, r = 38 + (k + 1) / 2
        c.rect(l, y, r - l + 1, 1, y == 41 ? gold : robe)
        c.px(l, y, y == 41 ? goldDark : robeLight); c.px(r, y, y == 41 ? goldDark : robeShade)
    }
    c.rect(18, 32, 20, 1, gold)
    c.rect(27, 33, 2, 8, gold); c.rect(28, 33, 1, 8, goldDark)
    c.rect(18, 36, 20, 1, goldDark); c.rect(26, 36, 4, 1, gold)              // the sash and its clasp
    c.rect(21, 34, 1, 2, robeLight)
    // The wide back sleeve, hanging.
    c.rect(14, 33, 4, 4, robe); c.rect(14, 37, 4, 1, gold); c.px(14, 33, robeLight)
    // Long straight hair, parted in the middle, framing the face, and the silver circlet across the brow.
    c.pattern(16, 20, [
        ".......HHHHHHHHHH.......",
        "....HHHHHHHHHHHHHHHH....",
        "..HHHHHHHHHlHHHHHHHHHH..",
        ".HHHHHHHHHlHHHHHHHHHHHH.",
        ".HHlHHHHHHlHHHHHHHHHlHH.",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHH..................HHH",
        "HHl..................lHH",
        "HHH..................HHH",
        "HHH..................HHH",
        "HHl..................lHH",
        "HHH..................HHH",
        "HHH..................HHH",
        ".Hl..................lH.",
    ], ["H": hair, "l": hairLight])
    c.rect(17, 25, 22, 1, silver); c.px(27, 25, white); c.px(28, 25, C(0xBFE0FF))
    c.px(15, 28, clawdOrange); c.px(40, 28, clawdOrange)                      // the pointed ears
    // The sword, held upright before him at rest, as a lord stands in council.
    let angle = p.melee ?? (seatedPose ? -40 : -78)
    drawElvenSword(c, angle: angle, trail: p.melee == nil ? [] : p.trail, hilt: gold, hiltDark: goldDark)
    c.rect(38, 33, 2, 3, robe); c.rect(38, 36, 2, 1, gold)
    c.rect(40, 33, 2, 3, clawdOrange); c.px(40, 35, clawdShade)               // the fist round the grip
}

/// Elcron's alarm clock `s` through his signature: it pops up over his head (0.04…0.14), its minute hand ticks round
/// in eight steps (…0.66), it rings, shaking, with ringing strokes either side (…0.84), and shrinks away (…0.94).
/// While it's there his eyes are turned up to it.
private func drawElcronClock(_ c: PixelCanvas, _ s: Double) {
    guard s > 0.04 && s < 0.94 else { return }
    let gold = C(0xC8A040), goldDark = C(0x9A7A2A), goldLight = C(0xF0D070), face = C(0xF4EEDC)
    // Eyes up.
    c.rect(22, 31, 2, 1, clawdOrange); c.rect(32, 31, 2, 1, clawdOrange)
    c.rect(22, 28, 2, 1, ink); c.rect(32, 28, 2, 1, ink)
    let size: Double = s < 0.14 ? (s - 0.04) / 0.1 : s > 0.84 ? 1 - (s - 0.84) / 0.1 : 1
    let ringing = s >= 0.66 && s < 0.84
    let cx = 28 + (ringing ? (Int(s * 90) % 2 == 0 ? -1 : 1) : 0), cy = 12
    let r = max(1, Int((4 * size).rounded()))
    guard r >= 3 else { c.rect(cx - r + 1, cy - r + 1, 2 * r - 1, 2 * r - 1, gold); return }
    c.ellipse(cx, cy, r, r, gold)
    c.ellipse(cx, cy, r - 1, r - 1, face)
    c.px(cx - r + 1, cy - 1, goldLight)
    guard r == 4 else { return }
    // The bells on top and the feet.
    c.pattern(cx - 4, cy - 5, ["GG.....GG", "Gg.....gG"], ["G": goldLight, "g": gold])
    c.px(cx, cy - 5, goldDark)
    c.px(cx - 3, cy + 4, goldDark); c.px(cx + 3, cy + 4, goldDark)
    for (x, y) in [(0, -3), (3, 0), (0, 3), (-3, 0)] { c.px(cx + x, cy + y, goldDark) }   // the hour marks
    // The hands: the hour hand short, at ten; the minute hand ticking round, back at the top when it rings.
    c.px(cx - 1, cy - 1, ink)
    let step = s < 0.14 ? 0 : min(8, Int((s - 0.14) / 0.52 * 8)) % 8
    let dirs = [(0, -1), (1, -1), (1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1)]
    let d = dirs[step]
    c.px(cx + d.0, cy + d.1, ink); c.px(cx + 2 * d.0, cy + 2 * d.1, ink)
    c.px(cx, cy, C(0x6E1E2A))
    guard ringing else { return }
    // Ringing: strokes either side of the bells, flickering.
    let on = Int(s * 45) % 2 == 0, col = C(0xFFF4C8, on ? 0.95 : 0.55)
    for side in [-1, 1] {
        let x = cx + side * 6
        c.px(x, cy - 5, col); c.px(x + side, cy - 6, col)
        c.px(x + side, cy - 2, col); c.px(x + 2 * side, cy - 2, col)
        if on { c.px(x, cy + 1, col); c.px(x + side, cy + 2, col) }
    }
}

// MARK: - Arwen Undoable

/// Arwen Undoable, the elf princess: a deep blue-grey riding gown to mid-calf over dark riding boots, a darker riding
/// cloak hanging down her back, long sleeves, a thin silver girdle, long dark hair falling in front of her shoulders and
/// down her back to the waist, pointed ears, and the Evenstar on a silver chain at her throat, a little white star. Her
/// sword is in her hand, held low, point forward, a slender curved elven blade with a silver guard; swung, it smears
/// behind a fast stroke. She walks (Gladriel, in white and gold, hovers). Signature: "Flow, Bruinen!": she raises her
/// sword high, and the flood of the Bruinen rises round her feet, white crests rearing out of it like galloping horses'
/// heads and racing past her; then the river sinks away and she lowers the sword (`drawBruinen`).
private func drawArwen(_ c: PixelCanvas, _ p: Pose) {
    let gown = C(0x4A5870), gownShade = C(0x343E52), gownLight = C(0x62728C)
    let hair = C(0x1E1614), hairLight = C(0x3E2E2A), silver = C(0xC8D4E0)
    drawBackCape(c, t: p.t, speed: p.capeSpeed, color: C(0x2C3442), edge: C(0x1E2430), hem: 41)
    drawLegs(c, Look(leg: C(0x2A2A30)), step: p.step)
    drawBoots(c, p.step, C(0x2A2018), rows: 3)
    let standing = c.oy
    c.oy += p.breathe
    // Her hair down her back, to the waist, over the cloak.
    c.pattern(14, 25, [
        "HHHH", "HlHH", "HHlH", "HHHH", "lHHH", "HHlH", "HHHH", "HlHH", "HHHH", ".HHH", ".HlH", "..HH",
    ], ["H": hair, "l": hairLight])
    drawBody(c, Look(arm: gown))
    // The bodice and the riding skirt, flaring a little to mid-calf, a fold or two in it.
    c.rect(18, 33, 20, 5, gown)
    c.rect(37, 33, 1, 5, gownShade)
    for y in 38...40 where y + c.oy <= 43 {
        let k = y - 37, l = 18 - k / 2 - (k == 3 ? 1 : 0), r = 37 + k / 2 + (k == 3 ? 1 : 0)
        c.rect(l, y, r - l + 1, 1, gown)
        c.px(l, y, gownLight); c.px(r, y, gownShade); c.px(23, y, gownShade); c.px(32, y, gownShade)
        if y == 40 { c.rect(l, y, r - l + 1, 1, gownShade) }
    }
    c.rect(19, 36, 18, 1, silver); c.px(28, 37, silver)                      // the girdle
    c.rect(21, 34, 1, 2, gownLight)
    // The long back sleeve.
    c.rect(14, 33, 4, 4, gown); c.rect(14, 36, 3, 2, gownShade); c.px(14, 33, gownLight)
    // Long dark hair over the head and down in front of her shoulders.
    c.pattern(16, 20, [
        ".......HHHHHHHHHH.......",
        "....HHHHHHHHHHlHHHHH....",
        "..HHHHHHHHHlHHHHHHHHHH..",
        ".HHHHHHHHHlHHHHHHHlHHHH.",
        ".HHlHHHHHHHHHHHHHHHHHHH.",
        "HHHHHHHHHH....HHHHHHHHHH",
        "HHHl................lHHH",
        "HHl..................lHH",
        "HHH..................HHH",
        "HHH..................HHH",
        "HHl..................lHH",
        "HHH..................HHH",
        "HHH..................HHH",
        ".HH..................HH.",
        ".Hl..................lH.",
        ".HH..................HH.",
        "..H..................H..",
    ], ["H": hair, "l": hairLight])
    c.px(15, 28, clawdOrange); c.px(40, 28, clawdOrange)                      // the pointed ears
    // The Evenstar: a silver chain from the neck to a little white star at her throat.
    c.px(24, 33, silver); c.px(25, 34, silver); c.px(31, 33, silver); c.px(30, 34, silver)
    c.pattern(26, 34, [".s..", "sWWs", ".WW.", "..s."], ["W": white, "s": C(0xBFD8F0)])
    if let s = p.signature {
        // The sword raised high, the arm up under it; then the flood at her feet.
        let k: Double = s < 0.15 ? smooth(s / 0.15) : s < 0.84 ? 1 : 1 - smooth((s - 0.84) / 0.14)
        let up = Int((8 * k).rounded()), oy = c.oy
        c.oy -= up
        drawElvenSword(c, angle: 38 - 120 * k, trail: [], hilt: silver, hiltDark: C(0x8A96A4), length: 16)
        c.oy = oy
        c.rect(38, 33 - up, 2, 3 + up, gown); c.rect(38, 33 - up, 1, 3 + up, gownLight)
        c.rect(40, 33 - up, 2, 3, clawdOrange); c.px(40, 35 - up, clawdShade)
        c.oy = standing
        drawBruinen(c, s)
        return
    }
    // The sword, held low in front of her.
    let angle = p.melee ?? (seatedPose ? 10 : 38)
    drawElvenSword(c, angle: angle, trail: p.melee == nil ? [] : p.trail, hilt: silver, hiltDark: C(0x8A96A4), length: 16)
    c.rect(38, 33, 2, 3, gown); c.rect(40, 33, 2, 3, clawdOrange); c.px(40, 35, clawdShade)
}

/// The flood of the Bruinen `s` through Arwen Undoable's signature: from 0.18 the river rises round her feet (…0.38),
/// its surface rolling in white foam, white crests rearing out of it like galloping horses' heads that race past her,
/// and from 0.72 it sinks away again (…0.92).
private func drawBruinen(_ c: PixelCanvas, _ s: Double) {
    let level: Double = s < 0.18 ? 0 : s < 0.38 ? 7 * smooth((s - 0.18) / 0.2) : s < 0.72 ? 7 : 7 * (1 - smooth((s - 0.72) / 0.2))
    guard level > 0.3 else { return }
    let foam = C(0xF4F8FC), spray = C(0xD8E8F8, 0.7), light = C(0x8AB4DC, 0.92), deep = C(0x3E6E9E, 0.9)
    let streak = C(0x6A9ACA, 0.9)
    let flow = s * 3.4 * 7
    var surface = [Int](repeating: 44, count: 72)
    for x in 2...69 {
        let e = (Double(x) - 36) / 34
        let h = level * (1 - e * e * e * e) + 0.8 * sin(Double(x) * 0.55 - flow) * min(1, level / 3)
        let top = 44 - Int(h.rounded())
        surface[x] = top
        guard top <= 43 else { continue }
        for y in top...43 {
            let col = y == top ? foam : y == top + 1 ? light : (x + y * 3 + Int(flow * 2)) % 9 == 0 ? streak : deep
            c.px(x, y, col)
        }
    }
    // The horses: white crests rearing out of the water, racing past.
    guard level >= 4 else { return }
    let crest = ["..sWW...", ".ssWWWW.", "ssWWWWWW", ".sWWW..W", "..WWW...", "..WWWW.."]
    for i in 0..<3 {
        let x = 6 + Int(frac(s * 1.8 + Double(i) / 3) * 54)
        let a = min(1, (level - 4) / 2.5)
        c.pattern(x, surface[min(69, x + 3)] - 5, crest, ["W": foam.alpha(a), "s": spray.alpha(a)])
    }
}

/// An elven sword in the fist at `angle`: a dark grip, a pommel and a guard whose quillons sweep forward toward the
/// blade, and a slender blade, `length` px, curving gently back toward the tip, with a darker edge; a pale smear along
/// `trail` behind a fast stroke.
private func drawElvenSword(_ c: PixelCanvas, angle: Double, trail: [Double], hilt: Px, hiltDark: Px, length: Double = 15) {
    let hand = Sprite.hand, steel = C(0xDCE4EE), edge = C(0x98A4B4)
    for (i, a) in trail.enumerated() {
        let u = unit(a)
        c.glowLine(hand.x + u.x * 4, hand.y + u.y * 4, hand.x + u.x * (3 + length), hand.y + u.y * (3 + length),
                   core: C(0xEEF4FA), glow: C(0xAAB8C8), coreR: 0.5, glowR: 1.6, strength: 0.32 / Double(i + 1))
    }
    let u = unit(angle), n = (x: -u.y, y: u.x)
    // A point `d` along the blade, bent back (away from the edge) toward the tip.
    func at(_ d: Double, _ o: Double = 0) -> (x: Double, y: Double) {
        let k = max(0, d - 3) / length, bend = -1.6 * k * k + o
        return (hand.x + u.x * d + n.x * bend, hand.y + u.y * d + n.y * bend)
    }
    line(c, hand.x - u.x * 2.5, hand.y - u.y * 2.5, hand.x + u.x * 1.5, hand.y + u.y * 1.5, C(0x2A1E16), 0.6)   // the grip
    c.px(Int((hand.x - u.x * 3).rounded(.down)), Int((hand.y - u.y * 3).rounded(.down)), hilt)                // the pommel
    var d = 3.0
    while d < 3 + length {
        let a = at(d), b = at(min(d + 2, 3 + length))
        line(c, a.x, a.y, b.x, b.y, steel, d + 2 >= 3 + length ? 0.5 : 0.7)
        let e0 = at(d, 0.6), e1 = at(min(d + 2, 2 + length), 0.6)
        line(c, e0.x, e0.y, e1.x, e1.y, edge, 0.3)
        d += 2
    }
    // The guard: quillons sweeping forward from the blade's root.
    let g = (x: hand.x + u.x * 2.5, y: hand.y + u.y * 2.5)
    line(c, g.x - n.x * 2.5 + u.x, g.y - n.y * 2.5 + u.y, g.x, g.y, hilt, 0.5)
    line(c, g.x, g.y, g.x + n.x * 2.5 + u.x, g.y + n.y * 2.5 + u.y, hiltDark, 0.5)
}

// MARK: - B-Treebeard

/// Where B-Treebeard's branch arm swings from: his front shoulder, half again as high as a Man's hand.
private let treebeardShoulder: (x: Double, y: Double) = (38.5, 21.5)

/// B-Treebeard, the oldest of the Ents, half again a Man's height: a tall stooping trunk of bark, its grain running
/// down it in dark furrows, moss on the shoulders; two thick trunk legs on spreading root feet; a broad bark head thrust
/// a little forward, a heavy brow over deep-set eyes glowing a warm Clawd orange, a knobbly nose, and a great mossy
/// green-grey beard of twigs and leaves down to his middle. Twigs and leaves sprout from his crown. His back arm hangs,
/// a long branch with twig fingers; the front one is his weapon: at rest it hangs forward beside him, and to fight he swats
/// with it, the whole branch swinging round from the shoulder, smeared behind it a long way (it's heavy and slow).
/// Signature: "Hrum, don't be hasty": a very, very slow hrum: his lids droop shut over the glow and open again, his
/// mouth opens in his beard and the hrum rumbles out of it in slow rings; then, one by one, new leaves sprout on his
/// branches and his crown, and a blossom, before they drop off and drift down (`drawTreebeardSprouts`).
private func drawTreebeard(_ c: PixelCanvas, _ p: Pose) {
    let bark = C(0x6A4A30), barkDark = C(0x4A3220), barkLight = C(0x8A6A48), furrow = C(0x3A2618)
    let moss = C(0x7A8A62), mossDark = C(0x5A6A46), mossLight = C(0x9AA882)
    let leaf = C(0x5A8A3A), leafLight = C(0x7AAA4A)
    // Two thick trunk legs on spreading root feet.
    for (i, lx) in [20, 30].enumerated() {
        let up = p.step >= 0 && i == p.step ? 1 : 0
        let col = i == 0 ? barkDark : bark
        c.rect(lx, 33, 7, 9 - up, col)
        c.px(lx + 2, 35, furrow); c.px(lx + 2, 36, furrow); c.px(lx + 4, 38, furrow); c.px(lx + 4, 39, furrow)
        c.px(lx, 34, i == 0 ? bark : barkLight)
        c.pattern(lx - 2, 41 - up, ["..RRRRRRR..", ".RRRRRRRRR.", "RR.RR.RR.RR"], ["R": i == 0 ? furrow : barkDark])
    }
    c.oy += p.breathe
    // The back arm: a long branch hanging from the shoulder, twig fingers at its end.
    line(c, 20, 21, 15, 34, barkDark, 1.8)
    line(c, 15, 34, 12, 38, furrow, 0.5); line(c, 15, 34, 14, 39, furrow, 0.5); line(c, 15.5, 34, 17, 38, furrow, 0.5)
    c.px(12, 39, leaf); c.px(17, 39, leaf)
    // The trunk: broad shoulders, the bark's grain running down it in furrows.
    let trunk: [(l: Int, r: Int)] = [
        (20, 38), (18, 40), (18, 40), (18, 39), (18, 39), (18, 39), (18, 39), (18, 39), (18, 38), (18, 38), (18, 38),
        (19, 38), (19, 38), (19, 38), (19, 37), (19, 37),
    ]
    for (i, row) in trunk.enumerated() {
        let y = 19 + i
        c.rect(row.l, y, row.r - row.l + 1, 1, bark)
        c.px(row.l, y, barkLight); c.px(row.r, y, barkDark)
        for (fx, gap) in [(22, 3), (26, 5), (31, 4), (35, 6)] where (y + fx) % 7 != gap { c.px(fx, y, furrow) }
    }
    c.rect(19, 34, 19, 1, barkDark)
    // Moss on the shoulders.
    c.pattern(18, 19, ["..MmMMl", "MMMlMm.", "mM.m..."], ["M": moss, "m": mossDark, "l": mossLight])
    // The head, thrust a little forward: a rounded crown, a heavy brow, deep-set glowing eyes and a knobbly nose.
    let head: [(l: Int, r: Int)] = [(28, 37), (26, 39), (25, 40), (24, 41), (24, 41), (24, 41), (24, 41), (24, 41), (24, 41),
                                    (24, 41), (25, 41)]
    for (i, row) in head.enumerated() {
        let y = 8 + i
        c.rect(row.l, y, row.r - row.l + 1, 1, bark)
        c.px(row.l, y, barkLight); c.px(row.r, y, barkDark)
    }
    c.px(27, 10, furrow); c.px(27, 11, furrow); c.px(33, 9, furrow); c.px(33, 10, furrow); c.px(26, 15, furrow)
    c.rect(28, 12, 13, 1, barkLight); c.rect(28, 13, 13, 1, furrow)           // the brow
    let glow: Double = 0.8 + 0.2 * sin(p.lt * 1.3)
    for ex in [29, 35] {
        c.rect(ex, 14, 4, 2, furrow)
        c.px(ex + 1, 14, C(0xFFC070).alpha(glow)); c.px(ex + 2, 14, clawdOrange.alpha(glow))
        c.px(ex + 1, 15, clawdShade.alpha(glow * 0.8))
    }
    if let s = p.signature { drawTreebeardLids(c, s, bark: bark, furrow: furrow) }
    c.pattern(40, 14, ["BB.", "BBB", "Bbb", ".b."], ["B": bark, "b": barkDark])    // the nose
    // Twigs and leaves sprouting from his crown.
    c.pattern(24, 3, [
        "...L.........LL...",
        "..LlT....L..lLT...",
        "...T.L..lL...T..L.",
        "...T..T..T..T..lL.",
        "....T.T..T.T..T...",
    ], ["T": barkDark, "L": leaf, "l": leafLight])
    // The beard: long and stringy, mossy twigs and leaves hanging from under the nose to his middle, a mouth in it.
    c.pattern(26, 17, [
        "....MmM..MmMM...",
        "..MMMMMTTTMMMMl.",
        ".MMlMMMMMMMMMMMM",
        "MMMMMTMMMlMMTMMm",
        "MmMMMMLMMMMMMMM.",
        ".MMMTMMMMMTMMMM.",
        ".mMMMMMMMMMMlMM.",
        "..MMMlMTMMMMMMm.",
        "..MmM.MMMMLMMM..",
        "..MM..MMTMM.MM..",
        "..mM..MMMMM..M..",
        "...M..mMMlM..m..",
        "......MMMMM.....",
        "......mMTM......",
        ".......MM.......",
        ".......m........",
    ], ["M": moss, "m": mossDark, "l": mossLight, "T": furrow, "L": leafLight])
    // The front arm, his weapon: a heavy branch from the shoulder, hanging forward at rest, swatting in a fight, a
    // long smear behind a swing.
    let angle = min(80, p.melee ?? 62)
    for (i, a) in heavySmear(angle, p.melee == nil ? [] : p.trail.map { min(80, $0) }).enumerated() {
        let u = unit(a), fade: Double = 0.36 * (1 - Double(i) / 12)
        guard fade > 0.03 else { break }
        let s = treebeardShoulder
        c.glowLine(s.x + u.x * 6, s.y + u.y * 6, s.x + u.x * 20, s.y + u.y * 20, core: C(0xC8B89A), glow: C(0x8A7A5A),
                   coreR: 0.8, glowR: 2, strength: fade)
    }
    drawBranchArm(c, angle: angle, bark: bark, dark: barkDark, furrow: furrow, leaf: leaf, leafLight: leafLight)
    if let s = p.signature { drawTreebeardSprouts(c, s, furrow: furrow, leaf: leaf, leafLight: leafLight) }
}

/// B-Treebeard's lids `s` through his signature: very slowly drooping half shut (0.06), shut (0.16…0.4), half open
/// again (…0.5), the glow of his eyes going out behind them: pale bark lids, shut in a dark sleepy curve.
private func drawTreebeardLids(_ c: PixelCanvas, _ s: Double, bark: Px, furrow: Px) {
    let shut = s < 0.06 ? 0 : s < 0.16 ? 1 : s < 0.4 ? 2 : s < 0.5 ? 1 : 0
    guard shut > 0 else { return }
    let lid = C(0x9A7A54), lash = C(0x1E140C)
    for ex in [29, 35] {
        c.rect(ex - 1, 14, 6, shut, lid)
        if shut == 2 {
            c.px(ex - 1, 15, lash); c.rect(ex, 16, 4, 1, lash); c.px(ex + 4, 15, lash)
        } else {
            c.rect(ex - 1, 15, 6, 1, lash)
        }
    }
}

/// The rest of B-Treebeard's signature, `s` through it: his mouth open in his beard while he hrums (0.1…0.46), the
/// hrum rolling out in front of him in slow rings, then new leaves sprouting one by one on his branches and crown
/// (0.5…0.78), a blossom last, all dropping off and drifting down at the end (0.88…).
private func drawTreebeardSprouts(_ c: PixelCanvas, _ s: Double, furrow: Px, leaf: Px, leafLight: Px) {
    if s > 0.1 && s < 0.46 {
        let wide = s > 0.16 && s < 0.4 ? 1 : 0
        c.rect(32, 18, 5, 2 + wide, C(0x2A1A10)); c.rect(31, 18, 1, 2 + wide, furrow); c.rect(37, 18, 1, 2 + wide, furrow)
        // The hrum: bold rings rolling out of his mouth one after another, growing and fading.
        for i in 0..<4 {
            let k = (s - 0.12 - Double(i) * 0.07) / 0.22
            guard k > 0 && k < 1 else { continue }
            let r: Double = 9 + k * 14, a: Double = 0.95 * (1 - k * k)
            var seen = Set<Int>()
            for w in [0.0, 1.0] where w == 0 || k < 0.6 {
                let n = Int((r + w) * 1.6)
                for j in 0...n {
                    let u = unit(-48 + 96 * Double(j) / Double(n))
                    let x = Int((34 + u.x * (r + w)).rounded(.down)), y = Int((19 + u.y * (r + w) * 0.8).rounded(.down))
                    guard seen.insert(y * 1000 + x).inserted else { continue }
                    c.px(x, y, C(0xF0E2C0, w == 0 ? a : a * 0.6))
                }
            }
        }
    }
    guard s > 0.5 else { return }
    let shoulder = treebeardShoulder, u = unit(62)
    var spots: [(x: Int, y: Int)] = [6.0, 11, 15].map { d in
        (Int(shoulder.x + u.x * d + 1.8), Int(shoulder.y + u.y * d - 0.9))
    }
    spots += [(16, 25), (21, 3), (14, 30), (36, 3), (19, 17), (43, 6), (28, 3)]   // a row clear of the canvas top
    let fall = s > 0.88 ? (s - 0.88) / 0.12 : 0
    let drop = Int((fall * 5).rounded()), a = 1 - fall
    for (i, p) in spots.enumerated() {
        let age = s - (0.5 + Double(i) * 0.025)
        guard age > 0 else { continue }
        let y = p.y + drop + (i % 2 == 0 ? 0 : drop / 2)
        if age < 0.03 { c.px(p.x, y, leafLight.alpha(a)); continue }
        c.pattern(p.x, y - 1, ["lL", "L."], ["L": leaf.alpha(a), "l": leafLight.alpha(a)])
    }
    // The blossom on his crown, last of all.
    if s > 0.78 {
        c.pattern(31, 2 + drop, [".f.", "fyf", ".f."], ["f": C(0xF4C8D8, a), "y": C(0xF0D060, a)])
    }
}

/// B-Treebeard's front arm at `angle` from his shoulder: a heavy branch, thick at the shoulder and tapering, a knot
/// at the elbow, and three twig fingers and a leaf or two at its end. Raised near upright, the forearm is drawn up to
/// 2.5 px shorter, so the twigs and leaves keep clear of the canvas top.
private func drawBranchArm(_ c: PixelCanvas, angle: Double, bark: Px, dark: Px, furrow: Px, leaf: Px, leafLight: Px) {
    let s = treebeardShoulder, u = unit(angle), n = (x: -u.y, y: u.x)
    let reach = 16 - 2.5 * max(0, (-u.y - 0.7) / 0.3)
    line(c, s.x, s.y, s.x + u.x * 9, s.y + u.y * 9, bark, 2)
    line(c, s.x + u.x * 9, s.y + u.y * 9, s.x + u.x * reach, s.y + u.y * reach, bark, 1.4)
    line(c, s.x + u.x * 2 + n.x * 1.2, s.y + u.y * 2 + n.y * 1.2, s.x + u.x * (reach - 2) + n.x * 0.8,
         s.y + u.y * (reach - 2) + n.y * 0.8, dark, 0.4)
    c.px(Int(s.x + u.x * 9), Int(s.y + u.y * 9), furrow)                      // the knot
    let tip = (x: s.x + u.x * reach, y: s.y + u.y * reach)
    for spread in [-35.0, 0, 35] {
        let f = unit(angle + spread)
        line(c, tip.x, tip.y, tip.x + f.x * 4.5, tip.y + f.y * 4.5, furrow, 0.5)
    }
    let l1 = unit(angle - 35), l2 = unit(angle + 35)
    c.px(Int(tip.x + l1.x * 5), Int(tip.y + l1.y * 5), leafLight)
    c.px(Int(tip.x + l2.x * 5), Int(tip.y + l2.y * 5), leaf)
}

// MARK: - Tom Bombadev

/// Tom Bombadev, the merry master of the Old Forest: a bright blue jacket with brass buttons and a broad belt, brown
/// breeches tucked into big yellow boots, a great bushy brown beard over his chest, brown hair under a tall battered
/// hat, its crown dented and leaning, with a long blue feather stuck in the band, sweeping up behind. He carries
/// nothing (he stays out of fights). Signature: a jig: he hops from foot to foot, his front hand up and waving, singing
/// (his mouth open in his beard, notes floating up from it), his hat's feather bouncing with every hop.
private func drawBombadil(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x2A66D0), coatShade = C(0x1E4CA0), coatLight = C(0x4A86E8), brass = C(0xE8C860)
    let boot = C(0xF0C828), bootShade = C(0xC8A018)
    let beard = C(0x7A4A24), beardDark = C(0x5A3418), beardLight = C(0x9A6434)
    let hat = C(0x6A5A44), hatDark = C(0x4A3E2E), hatLight = C(0x86745A)
    let feather = C(0x2A6AE0), featherLight = C(0x8AB8FF)
    let jig = p.signature.map(bombadilJig)
    let (ox, oy) = (c.ox, c.oy), step = jig?.step ?? p.step, arm = jig?.arm ?? 0
    if let j = jig { c.ox += j.sway; c.oy -= j.hop }
    drawLegs(c, Look(leg: C(0x7A5A34)), step: step)
    drawBoots(c, step, boot, rows: 4)
    if !seatedPose {
        // The boots' turned-down tops.
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let top = (step >= 0 && i % 2 == step ? 42 : 43) - 3
            c.rect(lx, top, 2, 1, bootShade)
        }
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: coat), armRight: arm)
    // The jacket, the collar to the hips, its tails below the belt.
    c.rect(18, 32, 20, 6, coat)
    c.rect(37, 32, 1, 6, coatShade)
    c.rect(18, 32, 20, 1, coatLight)
    for y in 38...39 where y + c.oy <= 43 {
        c.rect(18, y, 20, 1, coat); c.px(27, y, coatShade); c.px(28, y, coatShade); c.px(37, y, coatShade)
    }
    c.rect(18, 36, 20, 1, C(0x5A3A1E)); c.rect(26, 36, 3, 1, brass)          // the belt and its buckle
    c.px(20, 34, brass); c.px(35, 34, brass); c.px(20, 38, brass); c.px(35, 38, brass)
    c.rect(14, 33, 4, 3, coat); c.px(14, 33, coatLight); c.rect(14, 36, 2, 1, clawdOrange)   // the back sleeve, a hand
    c.rect(41, 33 - arm, 1, 2, clawdOrange)                                  // the front hand
    // Brown hair under the hat, over the ears.
    c.pattern(16, 26, ["BBB", "BbB", "BBB", ".Bb"], ["B": beard, "b": beardDark])
    c.pattern(37, 26, ["BBB", "BbB", "BBB", "bB."], ["B": beard, "b": beardDark])
    // The great bushy beard over his chest, and the moustache.
    c.pattern(19, 31, [
        "..BBBBBBBBBBBBBB..",
        ".BBBlBBBBBBBBlBBB.",
        "BBBBBBdBBBBdBBBBBB",
        "BdBBlBBBBBBBBlBBdB",
        "BBBBBBBdBBdBBBBBBB",
        ".BBdBBBBBBBBBBdBB.",
        "..BBBBlBBBBlBBBB..",
        "...BBBBBdBBBBBB...",
        ".....BBBBBBBB.....",
    ], ["B": beard, "d": beardDark, "l": beardLight])
    c.rect(23, 31, 10, 1, beardDark)
    c.pattern(23, 30, ["BBBB..BBBB"], ["B": beardLight])
    if let j = jig, j.singing { c.rect(27, 32, 2, j.mouth, C(0x3A1A10)) }      // singing
    // The tall battered hat: a dented crown leaning back, a band, and a wide drooping brim.
    let crown: [(y: Int, l: Int, r: Int)] = [
        (9, 21, 24), (9, 29, 31), (10, 21, 31), (11, 21, 31), (12, 21, 31), (13, 21, 32), (14, 21, 32), (15, 21, 32),
        (16, 21, 32), (17, 21, 33), (18, 21, 33), (19, 21, 33), (20, 20, 33), (21, 20, 34),
    ]
    for row in crown {
        c.rect(row.l, row.y, row.r - row.l + 1, 1, hat)
        c.px(row.l, row.y, hatLight); c.px(row.r, row.y, hatDark)
    }
    c.rect(25, 10, 4, 1, hatDark); c.px(26, 14, hatDark); c.px(27, 15, hatDark); c.px(30, 18, hatLight)   // dents and creases
    c.rect(20, 22, 15, 1, C(0x2A4A8A))                                        // the band
    c.rect(15, 23, 26, 1, hat); c.px(15, 23, hatLight)
    c.rect(14, 24, 3, 1, hatDark); c.rect(17, 24, 22, 1, hatDark); c.rect(39, 24, 3, 1, hatDark)   // the drooping brim
    c.px(13, 25, hatDark); c.px(42, 25, hatDark)
    // The long blue feather, stuck in the band and sweeping up behind.
    let fx = Double(jig?.feather.x ?? 0), fy = Double(jig?.feather.y ?? 0)
    line(c, 21, 22, 17 + fx / 2, 15 + fy / 2, feather, 0.9)
    line(c, 17 + fx / 2, 15 + fy / 2, 15 + fx, 6 + fy, feather, 0.8)
    line(c, 20, 21, 15 + fx, 7 + fy, featherLight, 0.3)
    c.px(14 + Int(fx), 5 + Int(fy), feather); c.px(15 + Int(fx), 4 + Int(fy), featherLight)
    if let s = p.signature {
        c.ox = ox; c.oy = oy
        drawSongNotes(c, s)
    }
}

/// Tom Bombadev's jig at one moment: which feet are up (`step`), how high he's hopped and how far he's stepped to the
/// side, how high his front arm waves, his mouth open singing (`mouth` px), and how far his feather's tip has bounced.
private struct BombadilJig {
    var step = -1, hop = 0, sway = 0, arm = 0, singing = false, mouth = 1
    var feather = (x: 0, y: 0)
}

/// Tom's jig `s` through his signature: eight hops (0.06…0.94), from one foot to the other, side to side, the front
/// arm up and waving, the feather's tip lagging each hop (down as he goes up, flicked up as he lands).
private func bombadilJig(_ s: Double) -> BombadilJig {
    var j = BombadilJig()
    guard s > 0.06 && s < 0.94 else { return j }
    let beat = (s - 0.06) / 0.88 * 8, n = Int(beat), u = frac(beat)
    j.step = n % 2
    j.hop = Int((2 * sin(u * .pi)).rounded())
    j.sway = [0, 1, 0, -1][n % 4]
    j.arm = n % 2 == 0 ? 3 : 1
    j.singing = true
    j.mouth = u < 0.5 ? 2 : 1
    j.feather = (Int((1.5 * sin(u * .pi)).rounded()) * (n % 2 == 0 ? 1 : -1), Int((2 * cos(u * .pi)).rounded()))
    j.feather.y = max(j.feather.y, j.hop - 2)                                 // its tip kept under the canvas top
    return j
}

/// The notes of Tom's song `s` through his signature: four of them, one after another, floating up and away from
/// in front of his face, wobbling, fading in and out.
private func drawSongNotes(_ c: PixelCanvas, _ s: Double) {
    let eighth = ["..N..", "..NN.", "..N.N", "..N..", "NNN..", "NN..."]
    let pair = ["..NNNNN", "..N...N", "..N...N", "NNN.NNN", "NN..NN."]
    for i in 0..<4 {
        let k = (s - 0.08 - Double(i) * 0.19) / 0.32
        guard k > 0 && k < 1 else { continue }
        let x = 43 + Int((k * 12 + sin(k * 9 + Double(i)) * 1.5).rounded()), y = 27 - Int(k * 20)
        let a = k < 0.15 ? k / 0.15 : k > 0.7 ? (1 - k) / 0.3 : 1
        c.pattern(x, y, i % 2 == 0 ? eighth : pair, ["N": (i % 2 == 0 ? C(0xFFF4D0) : C(0xBFD8FF)).alpha(a)])
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

/// A cape hanging down the back, seen from the side: it shows past the shoulder blade and between the back legs, so
/// the legs still read in front of it. Its hem sways at `speed` and ends on row `hem`.
private func drawBackCape(_ c: PixelCanvas, t: Double, speed: Double, color: Px, edge: Px, hem: Int = 43) {
    let last = min(hem, 43 - c.oy)
    guard last >= 27 else { return }
    for y in 27...last {
        let k = Double(y - 27) / Double(max(1, hem - 27))
        let sway = sin(t * speed + k * 2.2) * k * 1.6
        let l = Int((15.5 - k * 3.5 + sway).rounded())
        let r = 24 + Int((k * 2).rounded())
        c.rect(l, y, r - l + 1, 1, color)
        c.px(l, y, edge)
    }
}

/// The angles a heavy swing smears through: from now back past `trail`'s last angle by half as far again, so the smear
/// is longer than a sword's (the weapon looks slower, heavier). Empty when it isn't being swung fast.
private func heavySmear(_ now: Double, _ trail: [Double]) -> [Double] {
    guard let last = trail.last else { return [] }
    let end: Double = last + (last - now) * 0.5
    let n = max(2, Int((abs(end - now) / 5).rounded()))
    return (1...n).map { (i: Int) -> Double in now + (end - now) * Double(i) / Double(n) }
}

/// Smoothstep: 0→1 eased at both ends.
private func smooth(_ x: Double) -> Double {
    let u = min(1, max(0, x))
    return u * u * (3 - 2 * u)
}
