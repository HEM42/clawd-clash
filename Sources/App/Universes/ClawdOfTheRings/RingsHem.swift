import Foundation

// HEM in Clawd of the Rings, as Éowyn: the Rohan helmet, which comes off in his signature to let the buns out, its white
// crest, mail, a green-and-gold cloak, a sword held low and the sun-horse shield. The Rohan kit here is Éowin's and King
// Théodone's too (Art/RingsHeroes3.swift).

let ringsHem = HemCostume(
    persona: { Persona(name: "HEM", weapon: .saber, headTop: 21, signature: 2.6, draw: $0) },
    legs: { c, p in
        ringsDrawRohanCloak(c, t: p.t, speed: p.capeSpeed)
        drawLegs(c, Look(leg: ringsRohanTrousers), step: p.step)
        if !seatedPose {
            for (i, lx) in [19, 23, 31, 35].enumerated() {
                let bottom = p.step >= 0 && i % 2 == p.step ? 42 : 43
                c.rect(lx, bottom - 2, 2, 3, ringsRohanBoot)
            }
        }
    },
    top: (ringsRohanMail, ringsRohanMailDark, ringsRohanMail, ringsRohanMail),
    chest: { c, _ in
        for y in 35...36 { for x in 17...37 where (x + y) % 2 == 0 { c.px(x, y, ringsRohanMailLight) } }
        c.rect(17, 37, 22, 1, ringsRohanTunic)
        for y in 38...39 where y + c.oy <= 43 { c.rect(17, y, 22, 1, ringsRohanTunic); c.px(27, y, ringsRohanTunicDark); c.px(38, y, ringsRohanTunicDark) }
        c.rect(17, 34, 2, 4, ringsRohanCloak); c.rect(19, 34, 1, 4, ringsRohanGold)          // the cloak over the shoulder
        c.rect(37, 34, 2, 4, ringsRohanCloak); c.rect(36, 34, 1, 4, ringsRohanGold)
        c.px(19, 34, C(0xFFE08A)); c.px(36, 34, C(0xFFE08A))                     // its clasps
    },
    prop: { c, p, _, _ in   // the sword held low, swung along `p.melee` and smeared through `p.trail`; the shield on the off arm
        if let a = p.melee {
            for (i, ta) in p.trail.enumerated() { ringsDrawRohanSword(c, angle: ta, alpha: 0.3 / Double(i + 1)) }
            ringsDrawRohanSword(c, angle: a)
        } else {
            ringsDrawRohanSword(c, angle: seatedPose ? 8 : 35)
        }
        ringsDrawRohanShield(c, cx: 14, cy: seatedPose ? 33 : 35)
    },
    overFace: { c, p, helmet in ringsDrawRohanHelmet(c, t: p.t, rise: helmet.rise, strand: helmet.buns == nil) },
    shield: { c in ringsDrawRohanShield(c, cx: 14, cy: seatedPose ? 33 : 35) },
    holdsLow: true,
    helmetOff: { rohanHelmetOff($0) })


let ringsRohanMail = C(0x8A8E98), ringsRohanMailDark = C(0x6A6E78), ringsRohanMailLight = C(0xAEB2BA)
let ringsRohanTunic = C(0x3A6A3A), ringsRohanTunicDark = C(0x2A522A), ringsRohanCloak = C(0x2E5A2E), ringsRohanGold = C(0xE8B33A)
let ringsRohanSteel = C(0xC8CCD4), ringsRohanSteelDark = C(0x9A9EA8), ringsRohanCrest = C(0xF0EEE8)
let ringsRohanTrousers = C(0x5A5E66), ringsRohanBoot = C(0x4A3420)

/// The green-and-gold cloak hanging down the back: it shows past the shoulder and between the back legs, its hem
/// swaying at `speed`, a gold trim down its edge and along the hem.
func ringsDrawRohanCloak(_ c: PixelCanvas, t: Double, speed: Double) {
    let hem = 42, last = min(hem, 43 - c.oy)
    guard last >= 27 else { return }
    for y in 27...last {
        let k = Double(y - 27) / Double(hem - 27)
        let sway = sin(t * speed + k * 2.2) * k * 1.6
        let l = Int((14.5 - k * 3.5 + sway).rounded()), r = 23 + Int((k * 2).rounded())
        c.rect(l, y, r - l + 1, 1, y == hem ? ringsRohanGold : ringsRohanCloak)
        c.px(l, y, ringsRohanGold)
    }
}

/// Éowyn's helmet `s` through her signature (nil: not doing it). `rise`: px it is lifted off her head (0: on; from
/// `rohanHelmetGone`, off the canvas top). `buns`: nil while they're tucked up in it, else how many px low they hang
/// as they tumble out. `pull`: her fist up pulling it off (px above its place by her shoulder), until the shaking starts.
/// 0–0.2 the helmet rises off the top, the fist lifting with it; from 0.2 the buns tumble out (2 px low, then 1, settled
/// at 0.3); 0.25–0.92 the fist shakes (`drawHem`); after 0.92 the helmet drops back on and the buns go back in.
private func rohanHelmetOff(_ s: Double?) -> (rise: Int, buns: Int?, pull: Int?) {
    guard let s = s, s > 0 else { return (0, nil, nil) }
    if s < 0.2 {
        let k: Double = s / 0.2
        let rise = Int((k * k * Double(rohanHelmetGone)).rounded())
        return (rise, nil, min(rohanReach, rise))
    }
    if s <= 0.25 { return (rohanHelmetGone, 2, Int(((0.25 - s) / 0.05 * Double(rohanReach)).rounded())) }
    if s < 0.3 { return (rohanHelmetGone, 1, nil) }
    if s <= 0.92 { return (rohanHelmetGone, 0, nil) }
    let k: Double = min(1, (s - 0.92) / 0.06)   // falling: slow off the top, fast onto her head
    let rise = Int(((1 - k * k) * Double(rohanHelmetGone)).rounded())
    return (rise, rise > 5 ? 0 : nil, nil)
}

/// How far the helmet rises to leave the canvas top (its crest starts at row 18), and how far up her fist goes with it.
private let rohanHelmetGone = 34, rohanReach = 5

/// The Rohan helmet over the face, `rise` px up off the head: a steel dome with a gold-riveted band, cheek pieces and a
/// nose guard, and the white horsehair crest streaming back off the top. It hides the buns; one strand of hair
/// escapes at the back (`strand`, which stays on the head).
func ringsDrawRohanHelmet(_ c: PixelCanvas, t: Double, rise: Int = 0, strand: Bool = true) {
    if strand { for (x, y) in [(16, 26), (16, 27), (16, 28), (17, 29)] { c.px(x, y, hemHair) } }   // the one strand of hair
    guard rise < rohanHelmetGone else { return }
    let oy = c.oy
    c.oy -= rise
    defer { c.oy = oy }
    let sway = sin(t * 2.2) > 0 ? 1 : 0
    let crest: [(y: Int, l: Int, r: Int)] = [(18, 25, 30), (19, 21, 31), (20, 15, 23), (21, 12, 20), (22, 10, 17), (23, 9, 15),
                                             (24, 9, 13), (25, 9, 11), (26, 10, 10)]
    for (i, row) in crest.enumerated() {
        let dy = i >= 4 ? sway : 0
        c.rect(row.l, row.y + dy, row.r - row.l + 1, 1, ringsRohanCrest)
        if i >= 2 { c.px(row.l, row.y + dy + 1, C(0xC8C6C0)) }
    }
    c.pattern(17, 20, [
        ".......HHHHHHHH.......",
        ".....HHHHHHHHHHHH.....",
        "...HHHlHHHHHHHHHHHH...",
        "..HHlHHHHHHHHHHHHHHD..",
        ".HHHHHHHHHHHHHHHHHHHD.",
        "BBBBBBBBBBBBBBBBBBBBBB",
        "HH........NN........HH",
        "H.........NN.........H",
        "..........NN..........",
    ], ["H": ringsRohanSteel, "l": white, "D": ringsRohanSteelDark, "B": ringsRohanSteelDark, "N": ringsRohanSteel])
    for x in [19, 23, 32, 36] { c.px(x, 25, ringsRohanGold) }
}

/// Éowyn's round shield: green, a gold rim, and the gold sun-horse of Rohan in the middle.
func ringsDrawRohanShield(_ c: PixelCanvas, cx: Int, cy: Int) {
    c.ellipse(cx, cy, 5, 5, ringsRohanGold)
    c.ellipse(cx, cy, 4, 4, ringsRohanCloak)
    c.rect(cx - 1, cy - 1, 3, 3, ringsRohanGold)                                   // the horse's body
    c.px(cx + 2, cy - 2, ringsRohanGold); c.px(cx + 1, cy - 2, ringsRohanGold)          // its head and mane
    c.px(cx, cy - 3, ringsRohanGold); c.px(cx + 2, cy - 3, ringsRohanGold)
    c.px(cx - 1, cy + 2, ringsRohanGold); c.px(cx + 1, cy + 2, ringsRohanGold)          // its legs
}

/// Éowyn's sword, gripped at the hand: a leather grip, a gold crossguard and pommel, a straight steel blade.
/// `alpha` < 1: a ghost of it, for the smear of a swing.
func ringsDrawRohanSword(_ c: PixelCanvas, angle: Double, alpha: Double = 1) {
    let h = Sprite.hand, r: Double = angle * .pi / 180
    let u = (x: cos(r), y: sin(r)), n = (x: -sin(r), y: cos(r))
    let clear = C(0x000000, 0)
    c.glowLine(h.x - u.x * 2, h.y - u.y * 2, h.x + u.x * 1.5, h.y + u.y * 1.5, core: C(0x4A3420).alpha(alpha), glow: clear,
               coreR: 0.6, glowR: 0.7)
    c.px(Int(h.x - u.x * 2.5), Int(h.y - u.y * 2.5), ringsRohanGold.alpha(alpha))
    let g = (x: h.x + u.x * 2.2, y: h.y + u.y * 2.2)
    c.glowLine(g.x - n.x * 2.2, g.y - n.y * 2.2, g.x + n.x * 2.2, g.y + n.y * 2.2, core: ringsRohanGold.alpha(alpha), glow: clear,
               coreR: 0.55, glowR: 0.6)
    c.glowLine(h.x + u.x * 3, h.y + u.y * 3, h.x + u.x * 15, h.y + u.y * 15, core: ringsRohanSteel.alpha(alpha), glow: clear,
               coreR: 0.75, glowR: 0.8)
    c.glowLine(h.x + u.x * 3 + n.x * 0.6, h.y + u.y * 3 + n.y * 0.6, h.x + u.x * 14 + n.x * 0.6, h.y + u.y * 14 + n.y * 0.6,
               core: C(0x8A8F9C).alpha(alpha), glow: clear, coreR: 0.3, glowR: 0.35)
}
