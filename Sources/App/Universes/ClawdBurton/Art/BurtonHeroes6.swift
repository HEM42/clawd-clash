import Foundation

// Heroes: Frankenweenie, Pee-wee's Big Adventure, and Maggott (agent-only). From New Holland, drawn in greys like the
// film: Victor Frankenstien and his kite, Sparkie, the bull terrier he brought back with stitches and neck bolts, Elsa
// Van Helsclawd with her poodle, and Mr. Rzykrusky the science teacher. From Pee-wee's Big Adventure, in toy-box
// primaries: Pee-wee Herclawd, Dottie from the bike shop, and Large Marge, the ghost trucker. And Maggott, the worm
// who lives in Emilee's head. The people are Clawd in costume; Sparkie and Maggott keep their own shapes.

let burtonHeroes6: [BurtonHero: Persona] = [
    .victorFrankenstien: Persona(name: "Victor Frankenstien", weapon: .lightning,
                                 magic: Magic(core: C(0xFFFFFF), glow: C(0xA8A8A8)), pivot: victorHand, headTop: 24,
                                 signature: 3.8, draw: drawVictor),
    .sparkie: Persona(name: "Sparkie", weapon: .saber, pivot: sparkieMouth, headTop: 19, signature: 3.4,
                      draw: drawSparkie),
    .elsaVanHelsclawd: Persona(name: "Elsa Van Helsclawd", weapon: .none, headTop: 21, signature: 3.0, draw: drawElsa),
    .mrRzykrusky: Persona(name: "Mr. Rzykrusky", weapon: .none, headTop: 17, signature: 3.4, draw: drawRzykrusky),
    .peeweeHerclawd: Persona(name: "Pee-wee Herclawd", weapon: .blaster, shot: .thrown(C(0xD8202A)), muzzle: (45, 29),
                             headTop: 22, signature: 4.0, callout: "I know you are, but what am I?", draw: drawPeewee),
    .dottie: Persona(name: "Dottie", weapon: .none, headTop: 20, signature: 3.4, callout: "Drive-in, Saturday?",
                     draw: drawDottie),
    .largeMarge: Persona(name: "Large Marge", weapon: .none, headTop: 13, signature: 3.6,
                         callout: "Tell 'em Large Marge sent ya!", draw: drawLargeMarge),
    .maggott: Persona(name: "Maggott", weapon: .none, headTop: 20, signature: 3.0, draw: drawMaggott),
]

/// Victor's raised hand: his lightning leaves from there (raised by `armRaise`).
private let victorHand = (x: 40.5, y: 31.5)
/// The front of Sparkie's jaws: he bites from there.
private let sparkieMouth = (x: 46.5, y: 29.5)

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// Draws `art` on a layer of its own, positioned like `c`, and lays it over `c` at `alpha` (props fading in and out).
private func faded(_ c: PixelCanvas, _ alpha: Double, _ art: (PixelCanvas) -> Void) {
    guard alpha > 0 else { return }
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    c.paste(s, alpha: alpha)
    c.ox = ox; c.oy = oy; c.baseY = by
}

/// A hand raised from the shoulder at (`sx`, 34) to (`hx`, `hy`): a sleeve and a 2×2 hand.
private func raisedHand(_ c: PixelCanvas, from sx: Double, _ hx: Int, _ hy: Int, sleeve: Px, hand: Px) {
    burtonLine(c, sx, 34, Double(hx) + 1, Double(hy) + 2, sleeve, 1.1)
    c.rect(hx, hy, 2, 2, hand)
}

// MARK: - Victor Frankenstien

/// A small Clawd (a 14×9 block at (21, 30)) on short legs, its eyes on the block; applies the breathing bob. The
/// child-sized Clawd the Oompa-Loompah and Young Masbeth stand on.
private func smallClawd(_ c: PixelCanvas, _ p: Pose, body: Px, shade: Px, leg: Px, shoe: Px) {
    if seatedPose {
        for lx in [22, 25, 30, 33] { c.rect(lx - 1, 37, 3, 2, leg) }
    } else {
        for (i, lx) in [22, 25, 30, 33].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, 39, 2, lifted ? 3 : 4, leg); c.rect(lx, lifted ? 41 : 42, 2, 1, shoe)
        }
    }
    c.oy += p.breathe
    c.rect(21, 30, 14, 9, body); c.rect(21, 38, 14, 1, shade); c.rect(34, 30, 1, 9, shade)
    c.rect(24, 32, 2, 2, ink); c.rect(30, 32, 2, 2, ink)
}

/// Victor Frankenstien: a small, serious boy in the greys of an old horror film: a child-sized pale grey Clawd with
/// untidy black hair, a dark sweater vest over a white shirt, its collar showing in the V. He fights with jagged
/// grey-white lightning, the kind he brings things back to life with. Signature: he flies a kite up into a storm until
/// lightning strikes it, and it flashes white and drifts back down.
private func drawVictor(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xD2D2D2), skinD = C(0xA8A8A8), vest = C(0x5C5C62), vestD = C(0x44444A), vestL = C(0x7C7C84)
    let shirt = C(0xF2F2F2), hair = C(0x17171B), hairL = C(0x40404A)
    let sig = p.signature
    let kiting = sig.map { $0 > 0.03 && $0 < 0.97 } ?? false

    smallClawd(c, p, body: skin, shade: skinD, leg: C(0x3C3C42), shoe: C(0x111114))
    c.rect(26, 34, 4, 1, C(0x6A6A6E))
    // The sweater vest over the bottom of him, the shirt collar in its V, a diamond either side.
    c.rect(21, 35, 14, 4, vest); c.rect(34, 35, 1, 4, vestD); c.rect(21, 38, 14, 1, vestD)
    c.pattern(25, 35, ["WWWWWW", ".WWWW.", "..WW.."], ["W": shirt])
    c.pattern(22, 35, [".L.", "L.L", ".L."], ["L": vestL]); c.pattern(31, 35, [".L.", "L.L", ".L."], ["L": vestL])
    // Untidy black hair over the top of him, tufts sticking up.
    c.pattern(20, 24, [
        "....H.....H.....",
        "...HH..H..HH.H..",
        "..HHHHHHHHHHHHH.",
        ".HHhhhHHHHHHHHHH",
        "HHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHH",
        "HHHH.HHHH.HHHHHH",
        "HHH....H.....HHH",
    ], ["H": hair, "h": hairL])
    // His left arm; the right hand: down, up, crackling, or holding the kite's string.
    c.rect(18, 34, 3, 3, shirt)
    let raise = kiting ? 3 : p.armRaise
    if kiting || p.zap != nil || raise > 0 {
        raisedHand(c, from: 36.5, 39, 31 - raise, sleeve: shirt, hand: skin)
    } else {
        c.rect(35, 34, 3, 3, shirt)
    }
    guard kiting, let s = sig else { return }
    // The kite: up on its string into the storm, struck, flashing white, and drifting back down.
    let rise = ramp(s, 0.06, 0.4), fall = ramp(s, 0.64, 0.94)
    let kx = 41 + 12 * rise - 6 * fall, ky = 27 - 18 * rise + 10 * fall
    let struck = s > 0.44 && s < 0.62
    let alpha = min(ramp(s, 0.03, 0.12), 1 - ramp(s, 0.86, 0.97))
    faded(c, alpha) { k in
        let hx = 40.0, hy = Double(30 - raise)
        for i in 0..<10 {   // the string, sagging a little
            let f0 = Double(i) / 10, f1 = Double(i + 1) / 10
            let sag = { (f: Double) in sin(f * .pi) * 2.5 }
            k.glowLine(hx + (kx - hx) * f0, hy + (ky + 4 - hy) * f0 + sag(f0), hx + (kx - hx) * f1,
                       hy + (ky + 4 - hy) * f1 + sag(f1), core: C(0xE6E6E6, 0.55), glow: C(0, 0),
                       coreR: 0.45, glowR: 0.5)
        }
        let flash = struck && Int(p.t * 18) % 2 == 0
        let w = flash ? C(0xFFFFFF) : C(0xF0F0F0), g = flash ? C(0xFFFFFF) : C(0xB4B4B8)
        let x = Int(kx.rounded()) - 3, y = Int(ky.rounded()) - 4
        k.pattern(x, y, ["...K...", "..WKG..", ".WWKGG.", "KKKKKKK", ".WWKGG.", "..WKG..", "..WKG..", "...K..."],
                  ["W": w, "G": g, "K": flash ? C(0xE0E0E0) : C(0x6A6A70)])
        for b in 0..<3 {   // the tail of little bows, swaying
            let bx = x + 3 + Int((sin(p.t * 5 + Double(b)) * 1.2).rounded()) - b, by = y + 9 + b * 2
            k.rect(bx - 1, by, 3, 1, C(0x9A9AA0))
        }
        if struck {
            // The bolt, jagged, from the cloud down to the kite, and the flash round it.
            var px = kx + 5, py = 2.0
            let steps = 5
            for i in 1...steps {
                let f = Double(i) / Double(steps)
                let nx = i == steps ? kx : kx + 5 - 5 * f + (noise(Int(p.t * 20) * 7 + i) - 0.5) * 6
                let ny = 2 + (ky - 5 - 2) * f
                k.glowLine(px, py, nx, ny, core: C(0xFFFFFF), glow: C(0xA8A8A8), coreR: 0.6, glowR: 2.0)
                px = nx; py = ny
            }
            k.glowLine(kx, ky, kx, ky, core: C(0xFFFFFF, 0.5), glow: C(0xD8D8D8, 0.5), coreR: 4, glowR: 7)
        }
    }
}

// MARK: - Sparkie

/// Sparkie: Victor's bull terrier, brought back to life: a white dog the size of Clawd on its four legs, his long
/// egg of a head out in front, little pointed ears, a black button nose, stitches across his head and body, and a bolt
/// sticking out of his neck. He bites. Signature: his bolt sparks, he wags so hard his tail flies off and loops up
/// into the air, and then it's back on again.
private func drawSparkie(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0xF0F0F0), furD = C(0xC4C4C4), furDD = C(0x9A9A9E), stitch = C(0x3A3A40)
    let bolt = C(0x7A7A82), boltL = C(0xC0C0C8)
    let sig = p.signature
    let sparking = sig.map { $0 > 0.05 && $0 < 0.42 } ?? false
    let wagFast = sig.map { $0 > 0.18 && $0 < 0.46 } ?? false
    let tailK = sig.map { ramp($0, 0.46, 0.84) } ?? 0

    drawLegs(c, Look(leg: fur), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx, 43, 2, 1, furD) } }
    c.oy += p.breathe
    // The tail: wagging at his back end, or off in the air on a loop and back.
    let wag = sin(p.lt * (wagFast ? 38 : 5)) * (wagFast ? 22 : 10)
    let base: (x: Double, y: Double), spin: Double
    if tailK > 0 && tailK < 1 {
        let up = sin(tailK * .pi)
        base = (18 - 10 * up, 30.5 - 18 * up); spin = -130 + tailK * 720
    } else {
        base = (18, 30.5); spin = -140 + wag
    }
    let tip = burtonReach(base, spin, 7), side = burtonReach((0, 0), spin + 90, 1.4)
    burtonTriangle(c, (base.x + side.x, base.y + side.y), (base.x - side.x, base.y - side.y), (tip.x, tip.y), fur)
    // The body: white, a grey belly line, stitches down his side.
    c.rect(17, 28, 18, 10, fur); c.rect(17, 37, 18, 1, furD); c.rect(18, 27, 14, 1, fur)
    burtonStitches(c, 24, 29, n: 4, gap: 2, down: true, stitch)
    // The head: a long egg of a head reaching forward, small ears, eye, nose; jaws open to bite.
    let biting = p.melee.map { $0 < -25 } ?? false
    let lunge = p.melee.map { $0 > -25 ? 1 : 0 } ?? 0
    c.ox += lunge
    c.pattern(30, 19, [
        "...EE.EE.........",
        "...EEEEEE........",
        "..HHHHHHHH.......",
        ".HHHHHHHHHHH.....",
        "HHHHHHHHHHHHHH...",
        "HHHHHHHHHHHHHHH..",
        "HHHHHHHHHHHHHHHH.",
        "HHHHHHHHHHHHHHHN.",
        "HHHHHHHHHHHHHHNN.",
        "HHHHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHH...",
        "..HHHHHHHHHHd....",
        "...ddddddd.......",
    ], ["H": fur, "E": furDD, "N": burtonInk, "d": furD])
    c.rect(38, 23, 2, 2, burtonInk); c.px(38, 23, C(0x6A6A70))
    burtonStitches(c, 33, 22, n: 3, gap: 2, stitch)
    if biting {
        c.pattern(39, 27, ["KKKKKKK", "WKKKKW.", ".KKKK.."], ["K": C(0x2A1E20), "W": C(0xFFFFFF)])
        c.rect(38, 30, 6, 1, fur)
    } else {
        c.pattern(39, 28, ["....KKK", "KKKK..."], ["K": C(0x4A4A50)])
    }
    // The bolt out of his neck, and its sparks.
    c.rect(29, 26, 3, 3, bolt); c.px(29, 26, boltL); c.rect(28, 27, 1, 1, bolt)
    c.ox -= lunge
    if sparking {
        for i in 0..<3 {
            let n = Int(p.t * 16) * 5 + i
            guard noise(n) > 0.3 else { continue }
            let a = -150 + noise(n + 1) * 120, d = 2 + noise(n + 2) * 4
            let e = burtonReach((29.5, 26.5), a, d)
            c.glowLine(29.5, 26.5, e.x, e.y, core: C(0xFFFFFF, 0.95), glow: C(0xC8C8D0, 0.6), coreR: 0.4, glowR: 1.4)
        }
    }
}

// MARK: - Elsa Van Helsclawd

/// Elsa Van Helsclawd: Victor's neighbour, a quiet girl in greys: a pale Clawd with a glossy black bob and a straight
/// fringe, a pale dress with a white collar; her poodle on its lead beside her, black with a white streak
/// through its topknot where the lightning went. She doesn't fight. Signature: a shy little wave.
private func drawElsa(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xE4E4E4), skinD = C(0xBABABA), dress = C(0xB4B4BC), dressD = C(0x8C8C94), collar = C(0xF8F8F8)
    let hair = C(0x141418), hairL = C(0x3E3E48)
    let wave = p.signature.map { min(ramp($0, 0.12, 0.28), 1 - ramp($0, 0.76, 0.92)) } ?? 0

    // The poodle beside her, on its lead.
    let poo = C(0x2A2A30), pooD = C(0x1A1A1E), streak = C(0xF4F4F4)
    let bob = p.step >= 0 ? p.step : 0
    c.pattern(42, 32 - (seatedPose ? 4 : 0), [
        "..........PPP...",
        ".........PPWPP..",
        ".........PPPPPPN",
        "PP.......PKPPPP.",
        "PPP.....PPPPP...",
        ".PPPPPPPPPPPP...",
        "..PPPPPPPPPPP...",
        "..PdPPPPPPPd....",
        "...P.P....P.P...",
        "...P.P....P.P...",
        "..PP.PP..PP.PP..",
    ].enumerated().map { i, r in i >= 8 && bob == 1 && !seatedPose ? String(r.dropFirst()) + "." : r },
              ["P": poo, "d": pooD, "W": streak, "K": C(0x6A6A70), "N": C(0x0A0A0C)])
    drawLegs(c, Look(leg: C(0xDADADA)), step: p.step)
    burtonBoots(c, step: p.step, C(0x101012), height: 1)
    c.oy += p.breathe
    // The dress: its skirt over her legs, the bodice over the bottom of Clawd, the round white collar.
    c.rect(17, 38, 22, seatedPose ? 1 : 2, dress); c.rect(17, 37 + (seatedPose ? 1 : 2), 22, 1, dressD)
    drawBody(c, Look(body: skin, shade: skinD, arm: dress))
    c.rect(18, 33, 20, 5, dress); c.rect(37, 33, 1, 5, dressD)
    c.rect(22, 33, 12, 1, collar); c.rect(27, 34, 2, 1, burtonInk); c.rect(18, 36, 20, 1, dressD)
    c.rect(26, 32, 4, 1, C(0x8A8A8E))
    // The glossy black bob, its straight fringe, the sides cut off at her jaw.
    c.pattern(16, 20, [
        ".....HHHHHHHHHHHHHH.....",
        "...HHHHHHHHHHHHHHHHHH...",
        "..HHHHHhHHHHHHHHhHHHHH..",
        ".HHHHHHhHHHHHHHHhHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        ".HHHH..............HHHH.",
        "..HHH..............HHH..",
    ], ["H": hair, "h": hairL])
    // The lead from her right hand to the poodle's collar.
    c.glowLine(40.5, 35, 51.5, 36.5 - (seatedPose ? 4 : 0) - Double(p.breathe), core: C(0xD8D8D8, 0.7), glow: C(0, 0),
               coreR: 0.4, glowR: 0.5)
    if wave > 0 {
        let hy = 33 - Int((wave * 8).rounded()), wig = Int((sin(p.t * 12) * 1.2).rounded())
        raisedHand(c, from: 16.5, 13 + wig, hy, sleeve: dress, hand: skin)
    }
}

// MARK: - Mr. Rzykrusky

/// Mr. Rzykrusky: New Holland's fierce science teacher: a grey Clawd stretched into a long face, black hair slicked
/// back, heavy brows and a stern thin mouth, a dark suit and tie. He doesn't fight. Signature: he holds up a frog
/// and it twitches with a zap.
private func drawRzykrusky(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xC6C6C6), skinD = C(0x9C9C9C), suit = C(0x4A4A50), suitD = C(0x34343A), hair = C(0x18181C)
    let hairL = C(0x46464E), frogC = C(0x8A8A8E), frogD = C(0x6A6A70)
    let sig = p.signature
    let holding = sig.map { $0 > 0.08 && $0 < 0.9 } ?? false
    let zap = sig.map { ($0 > 0.36 && $0 < 0.44) || ($0 > 0.58 && $0 < 0.64) } ?? false

    drawLegs(c, Look(leg: suit), step: p.step)
    burtonBoots(c, step: p.step, C(0x101012), height: 1)
    c.oy += p.breathe
    // The long face: Clawd stretched taller, deep-set eyes under heavy brows, lines down the cheeks, a stern mouth.
    drawBody(c, Look(body: skin, shade: skinD, arm: suit, eye: nil))
    c.rect(18, 21, 20, 5, skin); c.rect(37, 21, 1, 5, skinD)
    c.rect(22, 28, 2, 3, burtonInk); c.rect(32, 28, 2, 3, burtonInk)
    c.pattern(20, 26, ["BBBBBB....BBBBBB"], ["B": hair])
    c.rect(25, 32, 6, 1, C(0x5A5A5E))
    // The dark suit over the bottom of him, a white shirt and a black tie.
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD)
    c.pattern(24, 33, ["WWWKKWWW", ".WWKKWW.", "..WKKW..", "...KK..."], ["W": C(0xF0F0F0), "K": C(0x141416)])
    // Black hair slicked straight back over the top of his long head.
    c.pattern(17, 17, [
        "....HHHHHHHHHHHHHH....",
        "..HHhhhhhhhhhhhhhhHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HH...HHHHHHHHHHHHHHH.",
        ".H..................H.",
    ], ["H": hair, "h": hairL])
    guard holding else { return }
    // The frog, held up by the scruff: limp, then kicking out as the zap goes through it.
    raisedHand(c, from: 39.5, 42, 26, sleeve: suit, hand: skin)
    let frog = zap ? ["F......F", "FF.FF.FF", ".FFFFFF.", ".FKFFKF.", "..FFFF..", ".F....F.", "F......F"]
                   : ["..FFFF..", ".FKFFKF.", ".FFFFFF.", "FFddddFF", "F.F..F.F", "..F..F.."]
    c.pattern(39, zap ? 19 : 20, frog, ["F": frogC, "d": frogD, "K": burtonInk])
    if zap {
        for i in 0..<4 {
            let a = Double(i) * 90 + p.t * 400, e = burtonReach((43, 22), a, 6)
            c.glowLine(43, 22, e.x, e.y, core: C(0xFFFFFF, 0.9), glow: C(0xB8B8C0, 0.5), coreR: 0.4, glowR: 1.3)
        }
    }
}

// MARK: - Pee-wee Herclawd

/// Pee-wee Herclawd: a pale Clawd with rosy cheeks and black hair slicked flat with a shine, in a grey suit a size too
/// small, a white shirt and a red bow tie, and white shoes. He throws joke-shop novelties: wind-up chattering teeth.
/// Signature: he kicks off his shoes, steps up into a pair of tall white platform shoes, and does his big-shoe dance on
/// the spot in them, arms swinging; then the platforms go and he's back in his own shoes.
private func drawPeewee(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xF4DCCB), skinD = C(0xD6BAA6), suit = C(0x8E8E98), suitD = C(0x6E6E78), suitL = C(0xA8A8B2)
    let red = C(0xD8202A), redD = C(0x9A141A), hair = C(0x18181C), sheen = C(0x4A4A58), shoe = C(0xF8F8F8)
    let sig = p.signature
    let shoesOff = sig.map { $0 > 0.05 && $0 < 0.93 } ?? false
    let dance = sig.map { $0 > 0.2 && $0 < 0.84 } ?? false
    let beat = Int(p.t * 4.5) % 2
    // The platform shoes: they fade in under his feet as he rises onto them, and fade as he steps back down.
    let platforms = sig.map { min(ramp($0, 0.13, 0.2), 1 - ramp($0, 0.84, 0.9)) } ?? 0
    let rise = seatedPose ? 0 : Int((Double(peeweePlatform) * platforms).rounded())

    if let s = sig, shoesOff {
        // The shoes, kicked off in two arcs, landing either side of him, fading away at the end.
        let k = ramp(s, 0.05, 0.2), up = sin(k * .pi) * 14
        faded(c, 1 - ramp(s, 0.84, 0.93)) { l in
            for (x0, x1) in [(19.0, 6.0), (35.0, 61.0)] {
                let x = Int((x0 + (x1 - x0) * k).rounded()), y = Int((42 - up).rounded())
                l.pattern(x, y, ["WWW.", "WWWW", "KKKK"], ["W": shoe, "K": C(0xC0C0C0)])
            }
        }
    }
    let sway = dance ? (beat == 0 ? -2 : 2) : 0
    c.ox += sway
    c.oy -= rise
    drawLegs(c, Look(leg: suit), step: dance ? beat : p.step)
    if !shoesOff { burtonBoots(c, step: p.step, shoe, height: 2) }
    if rise > 0 {
        faded(c, max(0.35, platforms)) { s in peeweePlatforms(s, step: dance ? beat : p.step, rise: rise) }
    }
    c.oy += dance ? -beat : p.breathe
    drawBody(c, Look(body: skin, shade: skinD, arm: suit))
    c.rect(19, 31, 2, 1, C(0xF08A9A)); c.rect(35, 31, 2, 1, C(0xF08A9A))
    c.pattern(26, 31, ["R..R", ".RR."], ["R": C(0xC84A5A)])
    // The too-small suit: short in the body, the shirt showing at the hem, the bow tie.
    c.rect(18, 33, 20, 4, suit); c.rect(37, 33, 1, 4, suitD); c.rect(18, 37, 20, 1, C(0xE8E8E8))
    c.pattern(25, 33, ["WWWWWWW", ".WWWWW.", "..WWW.."], ["W": C(0xF4F4F4)])
    c.pattern(26, 33, ["RR.RR", "RRDRR", "RR.RR"], ["R": red, "D": redD])
    c.px(22, 34, suitL); c.px(33, 34, suitL); c.px(28, 36, suitD)
    // Black hair slicked down flat, a shine along it.
    c.pattern(17, 22, [
        "....HHHHHHHHHHHHHH....",
        "..HHhhhhhhhhhhhhHHHH..",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HH..............HHHH.",
        ".H..................H.",
    ], ["H": hair, "h": sheen])
    if dance {
        // Arms swinging up and down in turn.
        raisedHand(c, from: 16.5, 13, beat == 0 ? 25 : 33, sleeve: suit, hand: skin)
        raisedHand(c, from: 39.5, 42, beat == 0 ? 33 : 25, sleeve: suit, hand: skin)
        return
    }
    if p.fire != nil || p.ready || p.gunLift > 0 {
        // Wind-up chattering teeth from the magic shop, raised to throw.
        c.oy += p.gunY
        c.rect(40, 31, 2, 2, skin)
        let chatter = Int(p.t * 12) % 2
        c.pattern(41, 27 - chatter, ["RRRRR", "WKWKW"], ["R": red, "W": C(0xFFFFFF), "K": redD])
        c.pattern(41, 29, ["WKWKW", "RRRRR"], ["R": red, "W": C(0xFFFFFF), "K": redD])
    }
}

/// How many pixels Pee-wee's platform shoes lift him by.
private let peeweePlatform = 4

/// The tall white platform shoes under Pee-wee's four feet, `rise` rows of sole each under the foot of its leg (drawn
/// with the body lifted by `rise`): chunky, a pixel wider than the leg on its outer side, a white upper over the foot,
/// a grey welt, thick off-white soles shaded on one side, and a dark bottom edge. `step` as in `drawLegs`, so a lifted
/// foot's shoe lifts with it.
private func peeweePlatforms(_ c: PixelCanvas, step: Int, rise: Int) {
    let white = C(0xF4F4F4), sole = C(0xD4D4DC), shade = C(0xACACB8), welt = C(0x8A8A96), bottom = C(0x56565F)
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        let foot = step >= 0 && i % 2 == step ? 42 : 43
        let x0 = i % 2 == 0 ? lx - 1 : lx
        for r in 0...rise {
            let row = r == rise ? bottom : r == 1 && rise >= 3 ? welt : nil
            c.rect(x0, foot + r, 2, 1, row ?? (r == 0 ? white : sole)); c.px(x0 + 2, foot + r, row ?? shade)
        }
    }
}

// MARK: - Dottie

/// Dottie: from the bike shop: an orange Clawd with short tousled fair hair, blue overalls over a red shirt, a
/// spanner sticking out of the bib pocket. She doesn't fight. Signature: she rings a bike bell and gives a hopeful
/// little wave.
private func drawDottie(_ c: PixelCanvas, _ p: Pose) {
    let hair = C(0xD8A040), hairD = C(0xB07E28), hairL = C(0xF0C468), blue = C(0x2A5AC8), blueD = C(0x1E44A0)
    let shirt = C(0xD8302A), steel = C(0xB8BCC4), steelD = C(0x7A7E88)
    let sig = p.signature
    let bell = sig.map { $0 > 0.08 && $0 < 0.5 } ?? false
    let wave = sig.map { min(ramp($0, 0.52, 0.62), 1 - ramp($0, 0.84, 0.94)) } ?? 0

    drawLegs(c, Look(leg: blue), step: p.step)
    burtonBoots(c, step: p.step, C(0x4A2E1A), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: shirt))
    c.pattern(26, 31, ["K..K", ".KK."], ["K": C(0x5A2A1A)])
    // The overalls: the red shirt at her sides, the blue bib and its straps, a spanner in the pocket, its head
    // sticking up out of it.
    c.rect(18, 33, 20, 5, shirt); c.rect(18, 35, 20, 3, blue); c.rect(37, 35, 1, 3, blueD)
    c.rect(22, 33, 12, 2, blue); c.rect(21, 32, 2, 1, blue); c.rect(33, 32, 2, 1, blue)
    c.px(23, 33, C(0xE8C040)); c.px(32, 33, C(0xE8C040))
    c.pattern(29, 33, ["S.S", "SSS"], ["S": steel]); c.rect(29, 35, 5, 2, blueD); c.px(30, 35, steelD)
    // Short tousled hair over the top of her.
    c.pattern(17, 20, [
        "....h..hh...h..h......",
        "..hHHhHHHhhHHhHHHh....",
        ".HHHHHHHHHHHHHHHHHHH..",
        ".HHHHlHHHHHHHHHlHHHHH.",
        "HHHHHHHHHHHHHHHHHHHHHH",
        ".HHH.HHH..HH.HHH.HHHH.",
        ".HH...H....H.....HHH..",
        ".H..................H.",
    ], ["H": hair, "h": hairD, "l": hairL])
    if bell {
        // The bike bell held up in her right hand, rung with her thumb.
        raisedHand(c, from: 39.5, 41, 28, sleeve: shirt, hand: clawdOrange)
        c.pattern(40, 24, ["..S..", ".SSS.", "SSSSS", "DDDDD"], ["S": steel, "D": steelD])
        if frac(p.t * 3) < 0.5 {
            c.pattern(46, 22, ["W..", ".W.", "...", "WW.", "...", ".W.", "W.."], ["W": C(0xFFFFFF, 0.9)])
        }
    }
    if wave > 0 {
        let hy = 33 - Int((wave * 8).rounded()), wig = Int((sin(p.t * 12) * 1.2).rounded())
        raisedHand(c, from: 16.5, 13 + wig, hy, sleeve: shirt, hand: clawdOrange)
    }
}

// MARK: - Large Marge

/// Large Marge: the ghost trucker, with a faint pale glow round her: a pale Clawd with a big teased-up beehive of
/// hair, a sweet red-lipped grin and a blue work shirt with a pocket and pearl snaps, jeans and boots. She doesn't
/// fight. Signature: her face stretches into the claymation scare, the eyes popping out on stalks and the jaw
/// dropping right down, then it snaps back to the sweet grin with a wobble.
private func drawLargeMarge(_ c: PixelCanvas, _ p: Pose) { burtonGhost(c) { drawLargeMargeFigure($0, p) } }

private func drawLargeMargeFigure(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0xF0D4C0), skinD = C(0xD0B29C), shirt = C(0x5A84B8), shirtD = C(0x3E6896), shirtL = C(0x7AA0D0)
    let hair = C(0xB88A4A), hairD = C(0x8E6630), hairL = C(0xD8AA68), lips = C(0xC8303A)
    let sig = p.signature
    let k = sig.map { min(ramp($0, 0.12, 0.32), 1 - ramp($0, 0.72, 0.76)) } ?? 0
    let wobble = sig.map { $0 >= 0.76 && $0 < 0.9 ? Int((sin(ramp($0, 0.76, 0.9) * .pi * 5) * 1.2).rounded()) : 0 } ?? 0
    let scary = k > 0.15

    drawLegs(c, Look(leg: C(0x3A4A72)), step: p.step)
    burtonBoots(c, step: p.step, C(0x5A3A22), height: 2)
    c.oy += p.breathe
    c.ox += wobble
    drawBody(c, Look(body: skin, shade: skinD, arm: shirt, eye: scary ? nil : burtonInk))
    // The work shirt: a collar, a pocket, a row of pearl snaps.
    c.rect(18, 33, 20, 5, shirt); c.rect(37, 33, 1, 5, shirtD)
    c.pattern(23, 33, ["LLL....LLL", ".LL....LL."], ["L": shirtL])
    c.rect(31, 35, 4, 2, shirtD); for y in [34, 36] { c.px(28, y, C(0xF4F0E8)) }
    // The big teased-up beehive of hair.
    c.pattern(15, 12, [
        ".........hhhhhhhhh........",
        ".......hHHHHHHHHHHHh......",
        ".....hHHHHHlHHHHHHHHHh....",
        "....HHHHHHlHHHHHHlHHHHH...",
        "...HHHHHHHHHHHHHHlHHHHHH..",
        "..HHHHHlHHHHHHHHHHHHHHHHH.",
        "..HHHHHlHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHlHHHHHHHHHH",
        ".HHHHHHHHHHHHHHlHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHHHHHHHHHHHHHHHHHHHHHHHh",
        ".HHHHHHHHHHHHHHHHHHHHHHHh.",
        ".HHHHHHHHHHHHHHHHHHHHHHHh.",
        ".HHHHH..............HHHHh.",
        ".HHHH................HHh..",
        "..HHH................HHh..",
        "..HHh................Hh...",
        "...h.................h....",
    ], ["H": hair, "h": hairD, "l": hairL])
    if !scary {
        // The sweet grin, red lips.
        c.pattern(24, 31, ["L......L", ".LWWWWL.", "..LLLL.."], ["L": lips, "W": C(0xFFFFFF)])
        c.ox -= wobble
        return
    }
    // The scare: the jaw dropping down over her shirt, a gaping mouth full of teeth.
    let jaw = Int((k * 9).rounded())
    c.rect(20, 31, 16, 3 + jaw, skin); c.rect(35, 31, 1, 3 + jaw, skinD)
    c.rect(22, 31, 12, 1 + jaw, C(0x2A0A10)); c.rect(23, 32, 10, max(0, jaw - 2), C(0x5A1420))
    c.pattern(22, 31, ["WKWKWKWKWKWK"], ["W": C(0xFFFFFF), "K": C(0x2A0A10)])
    c.rect(22, 31 + jaw, 12, 1, lips); c.rect(21, 30, 14, 1, lips)
    // The eyes, popped out of their sockets on stalks, staring.
    for (ex, dir) in [(23.0, -118.0), (33.0, -62.0)] {
        c.rect(Int(ex) - 2, 28, 3, 3, C(0x2A0A10))
        let len = 2 + 13 * k, e = burtonReach((ex - 0.5, 29.5), dir, len)
        burtonLine(c, ex - 0.5, 29.5, e.x, e.y, skinD, 0.9)
        c.circle(Int(e.x.rounded()), Int(e.y.rounded()), 2, C(0xFFFFFF))
        c.rect(Int(e.x.rounded()) - (dir < -90 ? 1 : 0), Int(e.y.rounded()) - 1, 2, 2, burtonInk)
    }
    c.ox -= wobble
}

// MARK: - Maggott

/// Maggott: the green worm who lives in Emilee's head, on Clawd's four legs: a pale green Clawd with segment rings
/// round its bottom, droopy heavy-lidded eyes and a sly mouth, under a little dark green worm hood. He doesn't fight.
/// Signature: he pops up out of the top of his hood, wriggles about, and slides back down.
private func drawMaggott(_ c: PixelCanvas, _ p: Pose) {
    let green = C(0x9AC05A), greenD = C(0x74983A), greenL = C(0xBCDC84), hood = C(0x4E7030), hoodD = C(0x3A5622)
    let sig = p.signature
    let k = sig.map { min(ramp($0, 0.08, 0.28), 1 - ramp($0, 0.76, 0.94)) } ?? 0

    drawLegs(c, Look(leg: green), step: p.step)
    if !seatedPose { for lx in [19, 23, 31, 35] { c.rect(lx, 43, 2, 1, greenD) } }
    c.oy += p.breathe
    drawBody(c, Look(body: green, shade: greenD, arm: green, eye: burtonInk))
    c.rect(22, 29, 2, 1, greenD); c.rect(32, 29, 2, 1, greenD)
    if k > 0.4 { c.rect(22, 30, 2, 2, green); c.rect(32, 30, 2, 2, green); c.rect(22, 29, 2, 1, burtonInk) }
    c.pattern(24, 32, [".KKKKKKK.", "K.......K"], ["K": C(0x3A4A22)])
    for y in [34, 36] { c.rect(18, y, 20, 1, greenD) }
    // The little worm hood over the top of him and down his sides, ribbed like a worm.
    c.pattern(16, 20, [
        "......GGGGGGGGGGGG......",
        "...GGGgGGGgGGGgGGGgGG...",
        "..GGGGgGGGgGGGgGGGgGGG..",
        ".GGGGGgGGGgGGGgGGGgGGGg.",
        ".GGGGgggggggggggggGGGGg.",
        ".GGGg..............gGGg.",
        ".GGg................gGg.",
        ".GGg................gGg.",
        ".GGg................gGg.",
        ".GGGg..............gGgg.",
    ], ["G": hood, "g": hoodD])
    // The worm popping up out of the top of the hood and wriggling.
    if k > 0 { c.rect(25, 20, 6, 2, C(0x1E2A12)) }
    if k > 0 {
        let n = Int((k * 7).rounded())
        for i in 0..<n {
            let x = 28 + sin(p.t * 7 - Double(i) * 0.9) * min(Double(i), 3) * 0.8
            let y = 23 - Double(i) * 2
            c.circle(Int(x.rounded()), Int(y.rounded()), 2, i % 2 == 0 ? green : greenL)
        }
        if n > 0 {
            let hx = Int((28 + sin(p.t * 7 - Double(n) * 0.9) * min(Double(n), 3) * 0.8).rounded())
            let hy = 23 - n * 2
            c.circle(hx, hy, 3, green)
            c.pattern(hx - 2, hy - 1, ["K...K", ".....", ".KKK."], ["K": burtonInk])
        }
    }
}
