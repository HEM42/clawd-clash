import Foundation

// Villains: One, the Upside Down's two monsters, and the men who hunt the kids. One, Brenner and Billy are Clawd in
// costume like everyone else, Clawd's orange face showing. The Mind Flayer and the Democlawgon are creatures: the first
// a spider of black smoke standing on four long legs, the second a faceless Clawd in grey hide whose head opens like a
// flower. Drawn eerie, never gory.

let hawkinsVillains2: [HawkinsVillain: Persona] = [
    .one: Persona(name: "One", weapon: .lightning,
                  magic: Magic(core: C(0xFFE4DC), glow: C(0xE8343E), jagged: false, rings: true),
                  headTop: 21, signature: 4.4, draw: drawOne),
    .mindFlayer: Persona(name: "The Mind Flayer", weapon: .saber, canSit: false, pivot: (44, 22), bulk: 9, headTop: 5,
                         signature: 4.0, draw: drawMindFlayer),
    .democlawgon: Persona(name: "The Democlawgon", weapon: .saber, canSit: false, pivot: (40, 30), bulk: 3, headTop: 8,
                          signature: 3.0, draw: drawDemoclawgon),
    .drBrenner: Persona(name: "Dr. Brenner", headTop: 20, signature: 3.2, callout: "Hello, Eleven.", draw: drawDrBrenner),
    .billyHargrove: Persona(name: "Billy Hargrove", weapon: .saber, headTop: 19, signature: 3.0, draw: drawBillyHargrove),
]

// MARK: - One

/// One, Henry Creel as the lab's orderly: neat blond hair combed back, short-sleeved whites with a V neck, a pen in the
/// pocket and a name tag, white trousers and shoes. His telekinesis is red rings rippling out of his hand, as Vecna's
/// are. Signature: his raised fingers twitch and a ghostly grandfather clock chimes behind him; then for a moment the
/// whites flicker into Mr. Whatsit's brown cardigan and kind smile, and back.
private func drawOne(_ c: PixelCanvas, _ p: Pose) {
    let whites = C(0xF2F2EE), whitesD = C(0xC8CCD0), whitesL = C(0xFFFFFF)
    let hair = C(0xE2C67A), hairD = C(0xB89A4E), hairL = C(0xF6E2A4)
    let cardigan = C(0x8A6A4A), cardiganD = C(0x6A4E34), cardiganL = C(0xA88660), shirt = C(0xE8E0CC)
    let k = hawkinsSpan(p, 0.04, 0.96)
    let twitch = k >= 0 && k < 0.46
    let flicker = (k > 0.5 && k < 0.55) || (k > 0.76 && k < 0.81)
    let whatsit = k > 0.5 && k < 0.81 && !(flicker && Int(p.t * 14) % 2 == 0)

    if twitch {
        // The clock behind him, faint as a ghost: its tall case, the face, the pendulum swinging; and as it chimes,
        // rings going out from its face.
        let g = C(0xD8D0C8, 0.18), gd = C(0x8A7A70, 0.16)
        c.rect(4, 6, 9, 1, g); c.rect(4, 7, 1, 20, g); c.rect(12, 7, 1, 20, g); c.rect(4, 26, 9, 1, g)
        for (dx, dy) in [(0, -3), (2, -2), (3, 0), (2, 2), (0, 3), (-2, 2), (-3, 0), (-2, -2)] { c.px(8 + dx, 10 + dy, g) }
        c.px(8, 10, gd); c.px(8, 9, gd); c.px(9, 10, gd)
        let sw = Int((sin(p.t * 4) * 2).rounded())
        hawkinsLine(c, 8, 14, 8 + Double(sw), 21, gd, 0.4); c.rect(7 + sw, 21, 3, 2, g)
        if k > 0.18 {
            let r = (k - 0.18) / 0.28 * 7
            for i in 0..<12 {
                let a = Double(i) * .pi / 6
                c.px(8 + Int((cos(a) * r).rounded()), 10 + Int((sin(a) * r).rounded()), C(0xE8343E, 0.2))
            }
        }
    }

    // White trousers (brown, as Mr. Whatsit), a crease at each knee, and shoes.
    drawLegs(c, Look(leg: whatsit ? C(0x6A5A48) : C(0xE6E6E2)), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 4, whatsit ? C(0x4E4234) : whitesD) }
    }
    drawBoots(c, whatsit ? C(0x4A3424) : C(0xD8D8D4), step: p.step, rows: 2)
    drawBoots(c, whatsit ? C(0x2E2018) : C(0xA8A8AC), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: whatsit ? cardigan : whites), armRight: twitch ? 5 : p.armRaise)

    if whatsit {
        // Mr. Whatsit: the cardigan over a cream shirt, its buttons, the knit in short strokes, and a kind smile.
        c.rect(18, 33, 20, 5, cardigan); c.rect(25, 33, 6, 2, shirt); c.rect(26, 35, 4, 1, shirt)
        c.rect(24, 33, 1, 5, cardiganL); c.rect(31, 33, 1, 5, cardiganD)
        c.px(31, 35, C(0xD8C8A0)); c.px(31, 37, C(0xD8C8A0))
        for (x, y) in [(20, 35), (34, 34), (21, 37), (35, 36)] { c.rect(x, y, 2, 1, cardiganD) }
        c.rect(19, 33, 4, 1, cardiganL); c.rect(37, 33, 1, 5, cardiganD); c.rect(18, 37, 20, 1, cardiganD)
        c.rect(15, 35, 3, 1, cardiganD)
        c.pattern(25, 31, ["m....m", ".mmmm."], ["m": C(0x5A1A1E)])
    } else {
        // The orderly's whites: the V neck, a fold or two, the pocket with its pen, the name tag, lit shoulders.
        c.rect(18, 33, 20, 5, whites)
        c.rect(26, 33, 4, 1, clawdOrange); c.rect(27, 34, 2, 1, clawdOrange)
        for (x, y) in [(25, 33), (30, 33), (26, 34), (29, 34), (27, 35), (28, 35)] { c.px(x, y, whitesD) }
        c.rect(19, 33, 4, 1, whitesL); c.rect(31, 35, 3, 1, whitesD); c.px(32, 34, C(0x3A6AB0))
        c.rect(20, 35, 3, 1, C(0x8A8F9C)); c.px(22, 36, whitesD); c.px(35, 36, whitesD)
        c.rect(37, 33, 1, 5, whitesD); c.rect(18, 37, 20, 1, whitesD)
        c.rect(15, 35, 3, 1, whitesD)
        c.rect(26, 32, 4, 1, C(0x8A3A2E))   // the thin, flat mouth
    }

    // The blond hair, short and combed straight back, lit in strokes along the comb lines.
    c.pattern(17, 21, [
        ".....HHHHHHHHHHHH.....",
        "...HHlllllHHHHHHHH....",
        "..HHHHHHHlllllHHHHH...",
        ".HHlllHHHHHHHHlllHHd..",
        ".HHHHHHHHHHHHHHHHHHHd.",
        ".HHH.............HHHd.",
        ".HH...............Hd..",
    ], ["H": hair, "d": hairD, "l": hairL])

    guard twitch else { return }
    // The raised hand, its fingers twitching.
    let f = Int(p.t * 10) % 3
    c.px(38, 27 - (f == 0 ? 1 : 0), clawdOrange); c.px(40, 27 - (f == 1 ? 1 : 0), clawdOrange); c.px(42, 28 - (f == 2 ? 1 : 0), clawdOrange)
}

// MARK: - The Mind Flayer

/// The Mind Flayer: a towering spider of black smoke. Its body is a dark, roiling mass high up, lit faintly along the
/// top, a broken rim of dull red underneath from the storm, with faint wisps drifting off it. It stands on four long
/// legs, their knees high above it and their feet on the ground. It lashes out with a tendril. Signature: two more legs
/// unfold out of its back and spread wide across the top of the frame, red lightning flickering inside it, and fold
/// away again.
private func drawMindFlayer(_ c: PixelCanvas, _ p: Pose) {
    let smoke = C(0x16141C), smokeL = C(0x34303E), smokeR = C(0x4E1A24)
    let k = hawkinsSpan(p, 0.06, 0.94)
    let spread = hawkinsEase(k, edge: 0.3)
    let t = p.t
    let by = Double(p.breathe)

    // The four legs it stands on, back to front: each from its hip under the body, up to a knee high above, and down
    // to its foot on the ground. A lifted pair steps a row higher.
    let legs: [(hx: Double, hy: Double, kx: Double, ky: Double, fx: Double)] = [
        (24, 21, 10, 9, 4), (28, 24, 18, 15, 16), (38, 24, 47, 15, 49), (42, 21, 56, 9, 63),
    ]
    for (i, l) in legs.enumerated() {
        let lifted = p.step >= 0 && i % 2 == p.step
        let fy = lifted ? 41.0 : 43.0
        let ky = l.ky + sin(t * 1.3 + Double(i)) * 0.6 - (lifted ? 1 : 0)
        hawkinsLine(c, l.hx, l.hy + by, l.kx, ky, smoke, 1.4)
        hawkinsLine(c, l.kx, ky, (l.kx + l.fx) / 2, (ky + fy) / 2, smoke, 1.0)
        hawkinsLine(c, (l.kx + l.fx) / 2, (ky + fy) / 2, l.fx, fy, smoke, 0.7)
        hawkinsLine(c, l.hx, l.hy + by - 1, l.kx, ky - 1, smokeL, 0.3)
    }

    // The two sky legs, unfolding out of its back in the signature and flung wide across the top of the frame.
    for side in [-1.0, 1.0] where spread > 0.05 {
        let hx = 32 + side * 5, hy = 12 + by
        let kx = 32 + side * (5 + spread * 19), ky = 12 - spread * 9 + sin(t * 1.1 + side) * 0.5
        let tx = 32 + side * (5 + spread * 25), ty = 12 - spread * 1
        hawkinsLine(c, hx, hy, kx, ky, smoke, 0.9)
        hawkinsLine(c, kx, ky, tx, ty, smoke, 0.6)
    }

    // The body: a dark mass of smoke whose edge churns slowly, lit along the top, red along the underside.
    let cx = 33.0, cy = 16.0 + by, rx = 13.0, ry = 9.0
    for y in 5...28 {
        for x in 17...49 {
            let dx = (Double(x) + 0.5 - cx) / rx, dy = (Double(y) + 0.5 - cy) / ry
            let ang = atan2(dy, dx)
            let edge = 1 + 0.12 * sin(ang * 5 + t * 1.5) + 0.06 * sin(ang * 9 - t * 2.3)
            let d = dx * dx + dy * dy
            guard d <= edge * edge else { continue }
            var col = smoke
            if dy < -0.55 && d > 0.45 * edge * edge { col = smokeL }
            if dy > 0.75 && d > 0.7 * edge * edge && (x + Int(t * 3)) % 4 != 0 { col = smokeR }
            c.px(x, y, col)
        }
    }
    // Swirls of paler smoke turning inside it.
    for i in 0..<3 {
        let a0 = t * 0.6 + Double(i) * 2.1
        for s in 0..<5 {
            let a = a0 + Double(s) * 0.3, r = 3.0 + Double(i) * 2
            c.px(Int((cx + cos(a) * r).rounded()), Int((cy + sin(a) * r * 0.7).rounded()), C(0x2A2632))
        }
    }
    // Wisps drifting off its edge, faint enough to stay soft.
    for i in 0..<7 {
        let a = Double(i) * 0.9 + t * 0.35
        let x = Int((cx + cos(a) * rx * 1.18).rounded()), y = Int((cy + sin(a) * ry * 1.22).rounded())
        c.rect(x, y, 2, 2, C(0x3A3446, 0.16))
    }
    if spread > 0.75 && Int(t * 8) % 3 == 0 {
        // Red lightning flickering inside it.
        let o = Int(t * 8) % 2 == 0 ? 0 : 3
        c.pattern(26 + o, 12, ["R...", ".R..", "RR..", "..R.", "..RR", "...R"], ["R": C(0xC8303A)])
    }

    // The tendril it lashes out with, waving, from the front of its body.
    if let a = p.melee {
        let pv = (x: 44.0, y: 22.0 + by)
        for (i, ta) in p.trail.enumerated() {
            let e = hawkinsReach(pv, ta, 15)
            c.glowLine(pv.x, pv.y, e.x, e.y, core: C(0x3A3446), glow: C(0x3A3446), coreR: 0.4, glowR: 1.4,
                       strength: 0.22 / Double(i + 1))
        }
        var prev = pv
        for d in stride(from: 1.0, through: 16, by: 1) {
            let b = hawkinsReach(pv, a, d), w = sin(d * 0.55 + t * 6) * 1.3 * d / 16
            let pt = hawkinsReach(b, a + 90, w)
            hawkinsLine(c, prev.x, prev.y, pt.x, pt.y, d > 13 ? smokeR : smoke, 1.0 - d / 32)
            prev = pt
        }
    } else {
        // At rest, a short tendril curls down from under the front of it.
        var prev = (x: 41.0, y: 23.0 + by)
        for d in 1...8 {
            let pt = (x: 41 + Double(d) * 0.5 + sin(t * 2 + Double(d) * 0.7) * 1.2, y: 23 + by + Double(d))
            hawkinsLine(c, prev.x, prev.y, pt.x, pt.y, smoke, 0.6)
            prev = pt
        }
    }
}

// MARK: - The Democlawgon

/// The Democlawgon: a faceless Clawd in pale grey-brown hide, slick and ridged, standing tall on its four clawed feet,
/// a long arm hanging at its back and the other reaching forward with long black claws. Its head is a closed bud on a
/// thin neck that opens like a flower: five petals peeling back round rings of small teeth. It fights with its claws,
/// its face opening as it strikes. Signature: its face opens wide, and shuts.
private func drawDemoclawgon(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x8E7E72), skinD = C(0x5E5048), skinL = C(0xB4A494), slime = C(0xDCD2C2)
    let flesh = C(0xB83A4A), fleshD = C(0x6A1A26), tooth = C(0xF0E8DA)
    let claw = C(0x2E2824), clawL = C(0x5A504A)
    let k = hawkinsSpan(p, 0.08, 0.92)
    var open = k >= 0 ? hawkinsEase(k, edge: 0.3) : 0
    if p.melee != nil { open = max(open, 0.7) }

    // The four legs in its hide, a dark ridge down each, a black claw at the toe.
    drawLegs(c, Look(leg: skin), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let f = hawkinsFoot(p, i)
            c.rect(lx + 1, f - 5, 1, 3, skinD); c.px(lx, f - 6, skinL)
            c.px(lx + 2, f, claw); c.px(lx + 2, f - 1, clawL)
        }
    }

    c.oy += p.breathe
    // The back arm, long, hanging down behind it, its claws reaching nearly to the ground.
    c.rect(13, 28, 3, 9, skin); c.rect(13, 28, 1, 9, skinL); c.rect(15, 30, 1, 7, skinD)
    for x in [13, 15] { c.rect(x, 37, 1, 3, claw); c.px(x, 37, clawL) }
    drawBody(c, Look(body: skin, shade: skinD, arm: skin, eye: nil))
    // The hide: lit down its left, ridged in short strokes that follow the body, with a slick shine here and there.
    c.rect(18, 26, 1, 11, skinL); c.rect(19, 26, 6, 1, skinL)
    for (x, y, w) in [(21, 29, 3), (29, 28, 4), (24, 32, 4), (31, 33, 3), (20, 35, 4), (27, 36, 5)] { c.rect(x, y, w, 1, skinD) }
    for (x, y) in [(22, 28), (30, 27), (25, 31), (33, 32)] { c.px(x, y, slime) }
    c.rect(15, 35, 3, 1, skinD)

    // The neck, thin and ridged.
    c.rect(26, 21, 5, 5, skin); c.rect(26, 21, 1, 5, skinL); c.rect(30, 21, 1, 5, skinD); c.px(28, 23, skinD)

    let hc = (x: 28.5, y: 15.5)
    if open < 0.15 {
        // The head shut: a smooth bud, the seams of its petals running up it, lit on the left.
        c.pattern(22, 9, [
            ".....SSS.....",
            "....SSSSS....",
            "...SLSdSSS...",
            "..SLSSdSSdS..",
            "..SLSdSSSdS..",
            ".SLSSdSSSdSS.",
            ".SLSSdSSdSSS.",
            ".SLSSSdSdSSD.",
            ".SSSSSdSdSSD.",
            "..SSSSdSdSD..",
            "..SSSSSdSSD..",
            "...SSSSSSD...",
            "....SSSSD....",
        ], ["S": skin, "L": skinL, "d": skinD, "D": skinD])
    } else {
        // The head open: five petals peeling back, pink inside, round the dark mouth and its rings of small teeth.
        let r = 2 + open * 2
        for i in 0..<5 {
            let a = -90 + Double(i) * 72 + sin(p.t * 3 + Double(i)) * 4
            hawkinsBar(c, hc, a, from: r - 0.5, to: r + 2 + open * 4, skin, r: 1.6)
            hawkinsBar(c, hc, a, from: r, to: r + 1.5 + open * 3, flesh, r: 0.6)
            let tip = hawkinsReach(hc, a, r + 2 + open * 4)
            c.px(Int(tip.x.rounded()), Int(tip.y.rounded()), skinL)
        }
        for y in -4...4 {
            for x in -4...4 where Double(x * x + y * y) <= r * r {
                c.px(Int(hc.x) + x, Int(hc.y) + y, Double(x * x + y * y) <= (r - 1.4) * (r - 1.4) ? fleshD : flesh)
            }
        }
        for i in 0..<10 {
            let a = Double(i) * .pi / 5
            c.px(Int((hc.x + cos(a) * (r - 0.8)).rounded()), Int((hc.y + sin(a) * (r - 0.8)).rounded()), tooth)
        }
    }

    // The front arm and its claws: reaching out in a strike, or hanging forward, ready.
    if let a = p.melee {
        let pv = (x: 40.0, y: 30.0)
        for (i, ta) in p.trail.enumerated() {
            let e = hawkinsReach(pv, ta, 10)
            c.px(Int(e.x.rounded()), Int(e.y.rounded()), C(0xE8E0D8, 0.4 / Double(i + 1)))
        }
        hawkinsBar(c, pv, a, from: -1, to: 7, skin, r: 1.3)
        let e = hawkinsReach(pv, a, 7)
        c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 3, 3, skin)
        for d in [-28.0, 0, 28] {
            let n0 = hawkinsReach(e, a + d, 1.5), n1 = hawkinsReach(e, a + d, 5)
            hawkinsLine(c, n0.x, n0.y, n1.x, n1.y, claw, 0.45)
        }
    } else {
        hawkinsLine(c, 38.5, 29.5, 44, 34, skin, 1.3); hawkinsLine(c, 38.5, 28.5, 43.5, 33, skinL, 0.4)
        c.rect(43, 33, 3, 3, skin)
        hawkinsLine(c, 46, 34.5, 49, 37.5, claw, 0.45); hawkinsLine(c, 46, 35.5, 49, 39.5, claw, 0.45)
        hawkinsLine(c, 45, 36.5, 46.5, 40, claw, 0.45)
    }
}

// MARK: - Dr. Brenner

/// Dr. Brenner, "Papa": thick white hair combed back, a charcoal suit buttoned over a white shirt and a dark tie, a
/// pocket square and the lab's ID clipped to his lapel, grey trousers and polished black shoes. He doesn't fight.
/// Signature: he holds out his hand, palm up, and beckons ("Hello, Eleven.").
private func drawDrBrenner(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x5A5E68), suitD = C(0x3E424A), suitL = C(0x7A7E8A)
    let shirt = C(0xF0F0EC), tie = C(0x1E2A44)
    let hair = C(0xE8E8E4), hairD = C(0xB4B4B4), hairL = C(0xFFFFFF)
    let k = hawkinsSpan(p, 0.08, 0.92)
    let reach = hawkinsEase(k, edge: 0.2)
    let ext = Int((reach * 6).rounded())

    drawLegs(c, Look(leg: suit), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx + 1, hawkinsFoot(p, i) - 4, suitD) } }
    drawBoots(c, C(0x18181C), step: p.step, rows: 2)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() { c.px(lx, hawkinsFoot(p, i) - 1, C(0x4A4A54)) } }

    c.oy += p.breathe
    drawBody(c, Look(arm: suit))

    // The suit: buttoned, its lapels lit and shaded, the shirt and tie in the V, a white pocket square, the lab's ID on
    // his lapel, two buttons, the far side and the hem in shade.
    c.rect(18, 33, 20, 5, suit)
    c.pattern(25, 33, ["SSSSSS", ".STTS.", "..TT.."], ["S": shirt, "T": tie])
    c.rect(27, 36, 2, 1, tie)
    c.rect(24, 33, 1, 3, suitL); c.px(25, 35, suitL); c.rect(31, 33, 1, 3, suitD); c.px(30, 35, suitD)
    c.px(29, 36, C(0x26262C)); c.px(29, 37, C(0x26262C))
    c.rect(33, 34, 2, 1, shirt)
    c.rect(20, 34, 2, 3, C(0xF0F0F0)); c.px(20, 35, C(0x3A6AB0)); c.px(21, 36, C(0x8A8F9C))
    c.rect(19, 33, 4, 1, suitL); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.rect(15, 35, 3, 1, suitD)
    c.rect(26, 32, 4, 1, C(0x8A3A2E)); c.px(30, 31, C(0x8A3A2E))   // a thin, patient smile

    // The white hair, thick and combed back, lit in strokes, short at the sides.
    c.pattern(17, 20, [
        "....HHHHHHHHHHHHH.....",
        "..HHHlllllHHHHHHHH....",
        ".HHlllHHHHHlllHHHHH...",
        ".HHHHHHHHHHHHHHHHHHHd.",
        ".HHHHHdHHHHdHHHHHHHHd.",
        ".HHH..............HHd.",
        ".HH................Hd.",
        ".Hd................d..",
    ], ["H": hair, "d": hairD, "l": hairL])

    guard ext > 0 else { return }
    // The hand held out, palm up, the white cuff showing, its fingers curling to beckon.
    c.rect(38, 32, 3 + ext, 3, suit); c.rect(38, 32, 3 + ext, 1, suitL); c.rect(38, 34, 3 + ext, 1, suitD)
    c.rect(41 + ext, 32, 1, 3, shirt)
    c.rect(42 + ext, 32, 3, 2, clawdOrange); c.rect(42 + ext, 33, 3, 1, clawdShade)
    c.px(43 + ext, 31, clawdOrange)
    let curl = reach >= 1 && Int(p.t * 3) % 2 == 0
    c.px(45 + ext, curl ? 31 : 32, clawdOrange)
}

// MARK: - Billy Hargrove

/// Billy Hargrove as the pool's lifeguard: a dark-blond mullet, feathered on top and long at the back, aviator
/// sunglasses, a red lifeguard's tank and red shorts, a whistle on a white cord, bare arms and black flip-flops. He
/// fights with his fists. Signature: he lowers his sunglasses to look over them, an eyebrow up, and pushes them back.
private func drawBillyHargrove(_ c: PixelCanvas, _ p: Pose) {
    let tank = C(0xC8302A), tankD = C(0x941E1C), tankL = C(0xE85048), trim = C(0xF4F0E8)
    let shorts = C(0xA82420), shortsD = C(0x7E1A18)
    let hair = C(0xC8A050), hairD = C(0x9A7832), hairL = C(0xE8C878)
    let k = hawkinsSpan(p, 0.08, 0.92)
    let down = hawkinsEase(k, edge: 0.25)
    let drop = Int((down * 2).rounded())

    drawLegs(c, Look(leg: clawdOrange), step: p.step)
    drawBoots(c, C(0x2A2A30), step: p.step, rows: 1)

    c.oy += p.breathe
    drawBody(c, Look(arm: clawdOrange), armRight: k >= 0 ? 5 : 0)

    // The red shorts, over the tops of his legs, a darker seam on each.
    c.rect(18, 37, 20, 1, shorts)
    if !seatedPose { for x in [19, 23, 31, 35] { c.rect(x, 38, 2, 2, shorts); c.px(x + 1, 39, shortsD) } }
    // The tank: red, lit along its left, its straps over his bare shoulders, white piping round the armholes, the far
    // side in shade.
    c.rect(19, 34, 18, 3, tank); c.rect(21, 33, 3, 1, tank); c.rect(32, 33, 3, 1, tank)
    c.rect(19, 34, 1, 3, tankL); c.rect(21, 33, 1, 1, tankL); c.rect(36, 34, 1, 3, tankD)
    c.px(20, 33, trim); c.px(35, 33, trim); c.rect(24, 34, 8, 1, tankD)
    c.rect(19, 36, 18, 1, tankD)
    // The whistle on its cord.
    hawkinsLine(c, 23.5, 33.5, 27, 35.5, trim, 0.35); hawkinsLine(c, 32.5, 33.5, 29.5, 35.5, trim, 0.35)
    c.rect(27, 35, 3, 2, C(0xB8BCC4)); c.px(29, 36, C(0x7A7E88))
    c.rect(27, 32, 3, 1, C(0x5A1A1E)); c.px(30, 31, C(0x5A1A1E))   // a smirk

    // The mullet: feathered high on top, lit in sweeping strokes, short at the front and long down the back of his neck.
    c.pattern(14, 19, [
        "........HHHHHHHHHH........",
        "......HHlllHHHHlllHH......",
        ".....HHlHHHHHlllHHHHH.....",
        "....HHHHHHlllHHHHHHHHH....",
        "...HHHlHHHHHHHHHHHHHHHH...",
        "...HHHHHHHHHhHHHHHHhHHHd..",
        "..HHHHHHHHHHHHHHHHHHHHHd..",
        "..HHHHHH.............HHd..",
        ".HHHHH...............Hd...",
        ".HHHH.....................",
        "HHHHd.....................",
        "HHHd......................",
        "HHHd......................",
        ".HHd......................",
        ".Hd.......................",
        "..d.......................",
    ], ["H": hair, "d": hairD, "l": hairL])

    // The aviators, a gold frame round dark lenses; lowered in the signature, with a raised brow over them.
    if drop >= 2 { c.rect(31, 27, 4, 1, hairD) }
    c.pattern(20, 28 + drop, ["FFFFFFbbbbFFFFFF", "LlLLLL....LlLLLL", ".LLLL......LLLL."],
              ["F": C(0xD8B048), "b": C(0xD8B048), "L": C(0x1A1A22), "l": C(0x6A7A9A)])
    if k >= 0 { c.rect(36, 29 + drop, 2, 1, clawdOrange) }   // a finger on the frame

    // His fist: thrown out along the swing, or held at his side.
    if let a = p.melee {
        let sh = (x: 39.5, y: 34.0)
        for (i, ta) in p.trail.enumerated() {
            let e = hawkinsReach(sh, ta, 7)
            c.glowLine(sh.x, sh.y, e.x, e.y, core: C(0xF0C0A0), glow: C(0xF0C0A0), coreR: 0.5, glowR: 1.5,
                       strength: 0.28 / Double(i + 1))
        }
        hawkinsBar(c, sh, a, from: 0, to: 6, clawdOrange, r: 1.2)
        let e = hawkinsReach(sh, a, 7)
        c.rect(Int(e.x.rounded()) - 1, Int(e.y.rounded()) - 1, 3, 3, clawdOrange)
        c.px(Int(e.x.rounded()) + 1, Int(e.y.rounded()) - 1, clawdShade)
    }
}
