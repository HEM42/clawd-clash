import Foundation

// Heroes: the Indiana Jones films. Indy and the friends he picks up along the way: Marion, Short Rounds, Willie,
// Sallaw, his father, Marcus Brodie, the Grail Knight, Mutt and Helena. Clawd in costume like the rest of the cast:
// hats, hair and clothes drawn over the blocky body, with Clawd's own orange face showing. Short Rounds is a boy: a
// smaller Clawd on short legs.

let clawdbergHeroes1: [ClawdbergHero: Persona] = [
    .indianaBones: Persona(name: "Indiana Bones", weapon: .saber, shot: .bullet, muzzle: (47, 32), headTop: 20, signature: 3.0,
                           callout: "It belongs in a museum!", draw: drawIndianaBones),
    .marion: Persona(name: "Marion Ravenwould", weapon: .saber, headTop: 20, signature: 3.4, draw: drawMarion),
    .shortRounds: Persona(name: "Short Rounds", weapon: .saber, pivot: (35, 39), headTop: 26, signature: 3.0,
                          callout: "No time for love, Dr. Jones!", draw: drawShortRounds),
    .willieScoot: Persona(name: "Willie Scoot", weapon: .none, headTop: 19, signature: 2.8, callout: "Aaaah!",
                          draw: drawWillieScoot),
    .sallaw: Persona(name: "Sallaw", weapon: .saber, bulk: 3, headTop: 19, signature: 3.6, callout: "Indy!",
                     draw: drawSallaw),
    .henryBones: Persona(name: "Henry Bones Sr.", weapon: .saber, headTop: 22, signature: 3.6, callout: "Junior!",
                         draw: drawHenryBones),
    .marcusBrodie: Persona(name: "Marcus Brodie", weapon: .none, headTop: 24, signature: 3.4,
                           callout: "Does anyone here speak English?", draw: drawMarcusBrodie),
    .grailKnight: Persona(name: "The Grail Knight", weapon: .saber, armoured: true, headTop: 22, signature: 3.6,
                          callout: "You have chosen wisely.", draw: drawGrailKnight),
    .mutt: Persona(name: "Mutt Willclawds", weapon: .saber, headTop: 19, signature: 3.0, draw: drawMutt),
    .helenaShore: Persona(name: "Helena Shore", weapon: .blaster, shot: .bullet, muzzle: (47, 32), headTop: 20,
                          signature: 3.0, draw: drawHelenaShore),
]

// MARK: - Shared bits

/// A filled disc of radius `r` round (cx, cy); the rim on its upper left in `rim`, if given (a frying pan, a halo).
private func disc(_ c: PixelCanvas, _ cx: Double, _ cy: Double, r: Int, _ col: Px, rim: Px? = nil) {
    let x0 = Int(cx.rounded()), y0 = Int(cy.rounded())
    let r2 = r * r + 1
    for dy in -r...r {
        for dx in -r...r {
            let d2 = dx * dx + dy * dy
            guard d2 <= r2 else { continue }
            let edge = d2 >= r2 - 2 * r && dx + dy < 0
            c.px(x0 + dx, y0 + dy, edge ? (rim ?? col) : col)
        }
    }
}

/// Chain mail: string art where every `M` is mail, its rings picked out in a darker grey on a regular dither.
private func chainMail(_ c: PixelCanvas, _ x: Int, _ y: Int, _ rows: [String], light: Px, dark: Px) {
    for (r, row) in rows.enumerated() {
        for (k, ch) in row.enumerated() where ch == "M" {
            let px = x + k, py = y + r
            c.px(px, py, (px + py * 2) % 4 == 0 ? dark : light)
        }
    }
}

/// A long skirt or robe hanging over the legs from the hips, `length` rows (one when seated), with a darker hem row;
/// it stops short of the feet, so all four legs still show below it.
private func hem(_ c: PixelCanvas, _ col: Px, dark: Px, length: Int, x: Int = 17, w: Int = 22) {
    let rows = seatedPose ? 1 : length
    c.rect(x, 38, w, rows, col)
    c.rect(x, 37 + rows, w, 1, dark)
}

/// A boy: a 14×9 Clawd on short legs, the body at (21, 30). The legs stand at `xs` (spread wider in a fighting
/// stance); the front one is thrown out in a kick at `kick` degrees from the hip when that's set, with the shoe on
/// its end. Applies the breathing bob and draws the body; the caller dresses it.
private func drawBoy(_ c: PixelCanvas, _ p: Pose, leg: Px, shoe: Px, xs: [Int], kick: Double?, trail: [Double]) {
    if seatedPose {
        for lx in [22, 25, 30, 33] { c.rect(lx - 1, 37, 3, 2, leg) }
    } else {
        for (i, lx) in xs.enumerated() {
            if i == 3, let k = kick {
                let hip = (x: 34.0, y: 39.5)
                clawdbergSmear(c, hip, trail.map { max(-35, min(15, $0)) }, from: 4, to: 9, C(0xE8E8F0))
                clawdbergBar(c, hip, k, from: 0, to: 7.5, leg, r: 0.9)
                let foot = clawdbergReach(hip, k, 8.5)
                c.rect(Int(foot.x.rounded()) - 1, Int(foot.y.rounded()) - 1, 3, 2, shoe)
                continue
            }
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, 39, 2, lifted ? 3 : 4, leg)
            c.rect(lx, lifted ? 41 : 42, 2, 1, shoe)
        }
    }
    c.oy += p.breathe
    c.rect(21, 30, 14, 9, clawdOrange)
    c.rect(21, 38, 14, 1, clawdShade); c.rect(34, 30, 1, 9, clawdShade)
}

// MARK: - Indiana Bones

/// Indiana Bones: Clawd in the brown fedora, the battered leather jacket open over a khaki shirt, khaki trousers and
/// brown boots, the satchel on his hip on its strap across his chest; the bullwhip coiled at his side, cracked in a
/// fight. Signature: he cracks the whip overhead, the crack knocks his own hat off, and he snatches it out of the air
/// and claps it back on.
private func drawIndianaBones(_ c: PixelCanvas, _ p: Pose) {
    let jacket = C(0x6A4028), jacketD = C(0x4A2C1A), shirt = C(0xC8B48A), shirtD = C(0xA8946A)
    let felt = C(0x7A5A3A), feltD = C(0x5A402A), band = C(0x2E1E12), whip = C(0x5A3A22), canvas = C(0x8A7A52)
    let sig = p.signature
    let cracking = sig.map { $0 > 0.05 && $0 < 0.4 } ?? false
    let hatK = sig.map { $0 >= 0.3 && $0 < 0.75 ? ($0 - 0.3) / 0.45 : -1 } ?? -1   // 0…1 while the hat's off

    drawLegs(c, Look(leg: C(0x9A8A62)), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x4A2E1A), height: 3)
    c.oy += p.breathe
    // The satchel, hanging at his left hip.
    c.rect(13, 35, 5, 4, canvas); c.rect(13, 35, 5, 1, C(0x6A5A3A)); c.px(15, 36, C(0x5A4A2A))
    drawBody(c, Look(arm: jacket))
    // The jacket open over the shirt, and the satchel's strap across his chest.
    c.rect(18, 34, 20, 4, jacket); c.rect(37, 34, 1, 4, jacketD); c.rect(18, 37, 20, 1, jacketD)
    c.rect(24, 34, 8, 4, shirt); c.px(27, 35, shirtD); c.px(27, 37, shirtD)
    c.rect(23, 34, 1, 3, C(0x8A5A38)); c.rect(32, 34, 1, 3, C(0x8A5A38))   // the lapels
    for i in 0..<4 { c.px(33 - i * 2, 34 + i, canvas); c.px(32 - i * 2, 34 + i, canvas) }

    // The hat: on his head, or knocked up off it by the crack, tumbling, and grabbed back.
    if hatK < 0 {
        clawdbergFedora(c, felt: felt, dark: feltD, band: band)
    } else {
        let lift = Int((sin(hatK * .pi) * 9).rounded())
        clawdbergFedora(c, felt: felt, dark: feltD, band: band, lift: lift)
        // His hair, briefly bare, and his left arm up after the hat once it's coming down.
        c.pattern(18, 23, ["..HHHHHHHHHHHHHHHH..", ".HHHHHhHHHHHHhHHHHH.", "HHHHHHHHHHHHHHHHHHHH"],
                  ["H": C(0x4A2E1A), "h": C(0x6A4428)])
        if hatK > 0.45 { c.rect(15, 26 - lift, 3, 9 + lift, jacket); c.rect(15, 25 - lift, 3, 2, clawdOrange) }
    }

    if cracking {
        // The whip swung up over his head and cracked out in front.
        let k = (sig! - 0.05) / 0.35
        let a = -170 + k * 175
        c.rect(38, 30, 3, 3, jacket)
        clawdbergWhip(c, angle: a, trail: [a - 30, a - 55], t: p.t, leather: whip, from: (39.5, 31.5))
        return
    }
    if p.fire != nil, p.melee == nil {
        // His revolver, drawn for the Cairo Swordsman (`ShootsFirst`): the whip back on his hip.
        clawdbergWhipCoil(c, whip)
        c.rect(38, 33, 3, 3, jacket)
        c.oy += p.gunY
        c.pattern(40, 31, ["KKKKKKK", "KKGKK..", "KW.....", "KW....."], ["K": C(0x2A2A30), "G": C(0x6A6E78), "W": C(0x6A4A2A)])
        return
    }
    if let a = p.melee {
        clawdbergWhip(c, angle: a, trail: p.trail, t: p.t, leather: whip)
    } else {
        clawdbergWhipCoil(c, whip)
    }
}

// MARK: - Marion Ravenwould

/// Marion Ravenwould: Clawd with a dark bob and a fringe, a loose white blouse open at the neck, belted over khaki
/// trousers and brown boots. She fights with a cast-iron frying pan, swung hard. Signature: she knocks back a shot,
/// slams the empty glass down, then stands there swaying a little, cheeks flushed, the glass held up upside down:
/// still standing.
private func drawMarion(_ c: PixelCanvas, _ p: Pose) {
    let blouse = C(0xF2EEE4), blouseD = C(0xCFC8B8), trousers = C(0xB89A6A), belt = C(0x5A3A22)
    let hair = C(0x241612), hairL = C(0x3E2A20)
    let glass = C(0x9CC8DA), whisky = C(0xE0962A)
    let sig = p.signature
    let drinking = sig.map { $0 > 0.05 && $0 < 0.42 } ?? false
    let slamming = sig.map { $0 >= 0.42 && $0 < 0.58 } ?? false
    let standing = sig.map { $0 >= 0.58 && $0 < 0.95 } ?? false

    drawLegs(c, Look(leg: trousers), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x5A3A22), height: 2)
    c.oy += p.breathe
    if standing { c.ox += sin(p.t * 5) > 0 ? 1 : 0 }   // a little unsteady
    drawBody(c, Look(arm: blouse))
    // The blouse, open at the neck, soft folds gathered over the belt; the belt and its buckle.
    c.rect(18, 33, 20, 5, blouse); c.rect(37, 33, 1, 5, blouseD)
    c.pattern(25, 33, ["dOOOOd", ".dOOd."], ["d": blouseD, "O": clawdOrange])
    c.rect(21, 35, 1, 2, blouseD); c.rect(34, 35, 1, 2, blouseD); c.px(23, 36, blouseD); c.px(31, 36, blouseD)
    c.rect(18, 37, 20, 1, belt); c.rect(27, 37, 2, 1, C(0xC8A04A))
    // The bob: a straight fringe, the sides down to the jaw.
    c.pattern(16, 20, [
        "......HHHHHHHHHHH.......",
        "....HHHHlllHHHHHHHH.....",
        "...HHHllHHHHHHlllHHHH...",
        "..HHlHHHHHHHHHHHHHHHHH..",
        "..HHlHHHHHHHHHHHHHHHHH..",
        ".HHHHHHlHHHHHlHHHHlHHHH.",
        ".HHHHHHlHHHHHlHHHHlHHHH.",
        ".HlH................HHH.",
        ".HlH................HHH.",
        ".HHH................HHH.",
        ".HHH................HHH.",
        "..HH................HH..",
    ], ["H": hair, "l": hairL])

    if drinking, let s = sig {
        // The glass up at her face, the whisky going down.
        let k = (s - 0.05) / 0.37
        let left = max(0, 2 - Int(k * 3))
        c.rect(37, 29, 3, 4, blouse)
        let rows = left == 2 ? ["g.g", "gAg", "gAg", "ggg"] : left == 1 ? ["g.g", "g.g", "gAg", "ggg"]
                                                                        : ["g.g", "g.g", "g.g", "ggg"]
        c.pattern(37, 26, rows, ["g": glass, "A": whisky])
        c.rect(15, 33, 3, 3, blouse)
        return
    }
    if slamming {
        // Slammed down: the empty glass at arm's length and the jolt of it.
        c.rect(38, 33, 3, 3, blouse)
        c.pattern(41, 34, ["g.g", "g.g", "ggg"], ["g": glass])
        let jolt = C(0xFFFFFF, 0.8)
        c.px(39, 38, jolt); c.px(45, 38, jolt); c.px(40, 33, jolt); c.px(44, 33, jolt)
        c.rect(15, 33, 3, 3, blouse)
        return
    }
    if standing {
        // Cheeks flushed, the glass held up upside down: empty, and she's still on her feet.
        c.px(20, 32, C(0xE85A50)); c.px(35, 32, C(0xE85A50))
        c.rect(38, 28, 3, 6, blouse)
        c.pattern(38, 25, ["ggg", "g.g", "g.g"], ["g": glass])
        c.rect(15, 33, 3, 3, blouse)
        return
    }
    c.rect(15, 33, 3, 3, blouse); c.rect(15, 35, 3, 1, blouseD)   // the sleeve, its cuff
    drawFryingPan(c, angle: p.melee ?? 78, trail: p.trail, reach: p.melee == nil ? 7.5 : 9)
}

/// A cast-iron frying pan on its wooden handle, held at `angle`, the pan `reach` pixels out from the hand.
private func drawFryingPan(_ c: PixelCanvas, angle: Double, trail: [Double], reach: Double) {
    clawdbergSmear(c, clawdbergHand, trail, from: 5, to: reach + 3, C(0xC8C8D0))
    clawdbergBar(c, clawdbergHand, angle, from: -1, to: reach - 3.5, C(0x4A3020), r: 0.7)
    let m = clawdbergReach(clawdbergHand, angle, reach)
    disc(c, m.x, m.y, r: 3, C(0x2E2E34), rim: C(0x70707A))
}

// MARK: - Short Rounds

/// Short Rounds: a boy, a small Clawd on short legs, in a navy baseball cap worn with the peak forward, a pale blue
/// shirt, dark trousers and white sneakers. He fights with kicks: fists up in guard and the front leg snapping out.
/// Signature: he tugs his cap down hard, then drops into a kung-fu stance, legs wide and one hand out flat.
private func drawShortRounds(_ c: PixelCanvas, _ p: Pose) {
    let cap = C(0x1E2A4A), capL = C(0x34446A), shirt = C(0x8AB0D0), shirtD = C(0x6A90B0), shirtL = C(0xA8C8E4)
    let trousers = C(0x3A3A44), shoe = C(0xF0F0EC), hair = C(0x1A1614)
    let sig = p.signature
    let pulling = sig.map { $0 > 0.05 && $0 < 0.35 } ?? false
    let stance = sig.map { $0 >= 0.35 && $0 < 0.95 } ?? false
    var kick: Double? = nil
    if let a = p.melee, !p.walking, a > -55 { kick = max(-35, min(15, a)) }
    let guarding = p.melee != nil && !p.walking

    drawBoy(c, p, leg: trousers, shoe: shoe, xs: stance ? [20, 24, 31, 35] : [22, 25, 30, 33], kick: kick,
            trail: p.trail)
    if stance { c.oy += 1 }   // crouched low
    // The shirt.
    c.rect(21, 35, 14, 4, shirt); c.rect(34, 35, 1, 4, shirtD); c.rect(21, 38, 14, 1, shirtD)
    c.pattern(26, 35, ["dOOd", ".dd."], ["d": shirtD, "O": clawdOrange])
    // Light along the shoulders, a fold either side and the pocket.
    c.rect(21, 35, 4, 1, shirtL); c.rect(30, 35, 4, 1, shirtL)
    c.rect(23, 36, 1, 2, shirtD); c.px(32, 37, shirtD); c.rect(30, 36, 2, 1, shirtD)
    c.rect(24, 32, 2, 2, ink); c.rect(30, 32, 2, 2, ink)
    // The cap, pulled down a row while he tugs at it; black hair under it at the back.
    c.rect(21, 30, 1, 2, hair)
    let capY = pulling ? 27 : 26
    c.pattern(20, capY, [
        "...CCCCCCCC......",
        "..CllllCCwCCC....",
        ".CllCCCCCCCCCd...",
        ".CCCCCCCCCCCCdlLL",
    ], ["C": cap, "w": white, "l": capL, "L": cap, "d": C(0x141C34)])

    if pulling {
        // A hand up on the peak, tugging it down.
        c.rect(35, 30, 2, 4, shirt); c.rect(35, 29, 2, 1, clawdOrange)
        c.rect(19, 35, 2, 2, shirt)
        return
    }
    if stance {
        // One hand out flat in front, the other drawn back high.
        c.rect(35, 33, 3, 2, shirt); c.rect(38, 32, 1, 3, clawdOrange)
        c.rect(18, 32, 2, 3, shirt); c.rect(17, 31, 2, 2, clawdOrange)
        return
    }
    if guarding {
        // Fists up.
        c.rect(35, 34, 2, 2, shirt); c.rect(35, 32, 2, 2, clawdOrange)
        c.rect(19, 34, 2, 2, shirt); c.rect(19, 32, 2, 2, clawdOrange)
        return
    }
    c.rect(19, 35, 2, 2, shirt); c.rect(35, 35, 2, 2, shirt); c.px(36, 36, clawdOrange)
    c.rect(19, 36, 2, 1, shirtD)   // the cuff
}

// MARK: - Willie Scoot

/// Willie Scoot: Clawd with platinum-blonde waves pinned up off the face, a strapless gold sequinned evening gown
/// down over the knees (the sequins catch the light), a glittering necklace and gold heels. She doesn't fight.
/// Signature: a beetle lands on her arm and she leaps in the air screaming, arms flailing, mouth wide open.
private func drawWillieScoot(_ c: PixelCanvas, _ p: Pose) {
    let gown = C(0xC8962E), gownD = C(0x9A6E1E), sequin = C(0xFFEC9A), heel = C(0xE8C050)
    let hair = C(0xF2DC8A), hairL = C(0xFFF0B8), hairD = C(0xC8AE5A), bug = C(0x1E2416), gownL = C(0xE0B04A)
    let sig = p.signature
    let fright = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false
    var jump = 0
    if let s = sig, fright {
        let k = (s - 0.1) / 0.4
        if k > 0 && k < 1 { jump = Int((sin(k * .pi) * 6).rounded()) }
    }
    c.oy -= jump

    drawLegs(c, Look(), step: p.step)
    clawdbergBoots(c, step: p.step, heel, height: 1)
    c.oy += p.breathe
    let flail = fright ? (Int(p.t * 12) % 2 == 0 ? 7 : 5) : 0
    drawBody(c, Look(), armLeft: fright ? 6 : 0, armRight: flail)
    // The gown: a strapless bodice, the skirt down over the knees, sequins twinkling.
    c.rect(18, 33, 20, 5, gown); c.rect(37, 33, 1, 5, gownD)
    hem(c, gown, dark: gownD, length: 2)
    // The bodice's lit top edge, the seam at the waist and the skirt falling in folds.
    c.rect(18, 33, 19, 1, gownL); c.rect(18, 37, 19, 1, gownD)
    if !seatedPose { for fx in [21, 26, 30, 34] { c.rect(fx, 38, 1, 2, gownD) } }
    let seqs = [(20, 34), (24, 36), (29, 34), (33, 36), (22, 38), (27, 39), (31, 38), (36, 34), (19, 39), (35, 39)]
    for (i, (x, y)) in seqs.enumerated() where noise(Int(p.t * 5) * 13 + i) > 0.45 { c.px(x, y, sequin) }
    // The necklace.
    for x in stride(from: 24, through: 32, by: 2) { c.px(x, 32, C(0xF4F8FF)) }
    // Platinum waves, pinned up, a few curls down the sides.
    c.pattern(15, 19, [
        "......HHHHHHHHHHHH......",
        "....HHHlllHHHHllHHHH....",
        "...HHllHHHHHlllHHHHHH...",
        "..HHHHHHHHHHHHHHHHHHdH..",
        "..HllHHHHHHHHHHllHHHdH..",
        "..HHHHHHHHHHHHHHHHHdHH..",
        ".HHHHHHHHHHHHHHHHHHHHHH.",
        ".HHHHH.HHHHHHH...HHHHHH.",
        ".HHHd..............dHHH.",
        ".HHHH..............HHHH.",
        "..HdH..............HdH..",
        "..HHH..............HHH..",
        "...H................H...",
    ], ["H": hair, "l": hairL, "d": hairD])

    if fright {
        // The bug on her raised left arm, her mouth wide open, the scream coming off her.
        c.pattern(14, 25, [".k.k", "kkkk", ".kk."], ["k": bug])
        c.rect(26, 32, 3, 2, C(0x5A1A14)); c.rect(26, 33, 3, 1, C(0x3A0E0A))
        let i = Int(p.t * 14)
        for j in 0..<3 where noise(i + j * 3) > 0.3 {
            let y = 26 + j * 3
            c.rect(42 + (j == 1 ? 1 : 0), y, 2 + j % 2, 1, C(0xFFFFFF, 0.85))
        }
    }
}

// MARK: - Sallaw

/// Sallaw: a big Clawd, broader and taller than the rest, in a red fez with its black tassel, a great black beard over
/// the lower half of his face and a long cream robe belted with a brown sash, down over his knees. He fights with
/// his fists. Signature: he throws his arms out wide and belts out a song, mouth open in the beard, the notes
/// floating off.
private func drawSallaw(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0xEAE0C8), robeD = C(0xC8BCA0), sash = C(0x7A4A2A)
    let fez = C(0xB8262A), fezD = C(0x8A1A1E), tassel = C(0x1E1E22), beard = C(0x241814), beardL = C(0x3E2C24)
    let sig = p.signature
    let singing = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false

    drawLegs(c, Look(leg: C(0x8A7458)), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x6A4A2A), height: 1)
    c.oy += p.breathe
    // The big body.
    c.rect(16, 25, 23, 13, clawdOrange); c.rect(38, 25, 1, 13, clawdShade); c.rect(16, 37, 23, 1, clawdShade)
    c.rect(22, 27, 2, 3, ink); c.rect(32, 27, 2, 3, ink)
    // The robe, its sash, and its skirt over his knees.
    c.rect(16, 33, 23, 5, robe); c.rect(38, 33, 1, 5, robeD)
    c.rect(16, 36, 23, 1, sash)
    hem(c, robe, dark: robeD, length: 2, x: 15, w: 25)
    // The beard.
    c.pattern(18, 28, [
        "BB................BB",
        "BB................BB",
        "BBB..............BBB",
        "BBBBBBbbbbbbbbBBBBBB",
        "BBBBBBBBBBBBBBBBBBBB",
        ".BBBBbBBBBBBBBbBBBB.",
        "..BBBBBBBBBBBBBBBB..",
        "...BBBBBbBBBBBBBB...",
        ".....BBBBBBBBBB.....",
        ".......BBBBBB.......",
    ], ["B": beard, "b": beardL])
    // The fez and its tassel.
    c.pattern(21, 19, [
        "..FFFFFFFFFF..",
        "..FFFFFFFFFF..",
        ".FFFFFFFFFFFF.",
        ".FFFFFFFFFFFF.",
        "FFFFFFFFFFFFFF",
        "dddddddddddddd",
    ], ["F": fez, "d": fezD])
    c.px(27, 19, fezD)
    for (x, y) in [(26, 18), (25, 18), (24, 19), (23, 20), (22, 21), (21, 22)] { c.px(x, y, tassel) }
    c.rect(20, 23, 2, 2, tassel)

    if singing {
        // Arms flung wide, mouth open, the notes drifting up and away.
        clawdbergLine(c, 15, 33, 9, 25, robe, 1.3); c.rect(8, 23, 3, 3, clawdOrange)
        clawdbergLine(c, 40, 33, 46, 25, robe, 1.3); c.rect(45, 23, 3, 3, clawdOrange)
        c.rect(26, 33, 4, 2, C(0x5A1A14))
        for i in 0..<3 {
            let f = frac(p.t * 0.6 + Double(i) / 3)
            let wob = sin(p.t * 5 + Double(i)) > 0 ? 1 : 0
            let x = 48 + Int(f * 14), y = 24 - Int(f * 18) + wob
            c.pattern(x, y, ["..NN", "..N.", "..N.", "NNN.", "NN.."], ["N": C(0xFFF6D8, 1 - f * 0.6)])
        }
        return
    }
    c.rect(13, 32, 3, 3, robe); c.px(13, 34, clawdOrange)
    if let a = p.melee {
        clawdbergPunch(c, angle: a, trail: p.trail, arm: robe)
    } else {
        c.rect(39, 32, 3, 3, robe); c.px(41, 34, clawdOrange)
    }
}

// MARK: - Henry Bones Sr.

/// Henry Bones Sr.: Clawd with neat grey hair and a short grey beard, little round wire glasses, a tweed jacket over a
/// white shirt with a red bow tie, and grey-brown trousers. He fights with his black umbrella, furled, crook handle
/// and all; at rest he leans on it like a cane. Signature: he raises the umbrella and snaps it open over his head,
/// flapping it up and down, and the seagulls burst up off the ground and scatter.
private func drawHenryBones(_ c: PixelCanvas, _ p: Pose) {
    let tweed = C(0x8C7A58), tweedD = C(0x6A5A3E), fleck = C(0xA8966E), shirt = C(0xF0ECE2), bow = C(0xA82A2A)
    let hair = C(0xD8D4CC), hairD = C(0xA8A49C), frame = C(0x3A2A1A)
    let brolly = C(0x1E1E24), brollyL = C(0x3A3A44), wood = C(0x6A4A2A), shaft = C(0x5A5A62)
    let sig = p.signature
    let opening = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false

    drawLegs(c, Look(leg: C(0x7A6A58)), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x4A3020), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: tweed))
    // The tweed jacket, flecked, over the shirt and bow tie.
    c.rect(18, 34, 20, 4, tweed); c.rect(37, 34, 1, 4, tweedD); c.rect(18, 37, 20, 1, tweedD)
    for (x, y) in [(19, 35), (21, 37), (34, 35), (36, 36), (20, 36), (35, 37)] { c.px(x, y, fleck) }
    c.pattern(24, 34, ["tSBbBSt", ".tSSSt.", "..tSt.."], ["t": tweedD, "S": shirt, "B": bow, "b": C(0x7A1A1A)])
    // The grey hair and the short beard.
    c.pattern(17, 22, [
        "......hHHHHHHHh.......",
        "....HHHHHHHHHHHHHH....",
        "..HHHHHHHHHHHHHHHHHH..",
        ".HHHHHH..........HHHH.",
        ".HHH..............HHH.",
        ".HH................HH.",
    ], ["H": hair, "h": hairD])
    c.pattern(19, 30, [
        "BB..............BB",
        "BBB............BBB",
        ".BBBBBBBBBBBBBBBB.",
        "...BBBbBBBBbBBB...",
    ], ["B": hair, "b": hairD])
    // The round glasses.
    for gx in [21, 31] {
        c.pattern(gx, 28, [".FF.", "F..F", "F..F", "F..F", ".FF."], ["F": frame])
        c.rect(gx + 1, 29, 2, 3, C(0xDFF0FF, 0.22))
    }
    c.rect(25, 29, 6, 1, frame); c.rect(19, 29, 2, 1, frame); c.rect(35, 29, 2, 1, frame)
    c.rect(15, 33, 3, 3, tweed)

    if opening, let s = sig {
        // The umbrella up over his head, opening, then flapped up and down; the gulls burst off and scatter.
        let k = min(1, (s - 0.05) / 0.2)
        let rx = 2 + Int(k * 7)
        let bob = k >= 1 && sin(p.t * 14) > 0 ? -1 : 0
        let top = 16 + bob
        c.rect(38, 29, 3, 5, tweed)
        c.rect(41, top, 1, 33 - top, shaft)
        c.rect(41, 32, 1, 2, wood)
        for dx in -rx...rx {
            let f = Double(dx) / Double(rx + 1)
            let h = Int((sqrt(1 - f * f) * 4).rounded())
            c.rect(41 + dx, top + 4 - h, 1, h + 1, abs(dx) % 3 == 0 ? brollyL : brolly)
        }
        c.px(41, top - 1, C(0xC8CCD4))
        guard s > 0.25 else { return }
        let g = (s - 0.25) / 0.7
        let flap = Int(p.t * 10) % 2 == 0
        let fade = max(0, 1 - g * 0.6)
        for i in 0..<5 {
            let gi = Double(i)
            let x = 43 + i * 7 + Int(g * (4 + gi * 3))
            let y = 41 - (i % 3) * 5 - Int(g * (24 + gi * 3))
            let up = (i % 2 == 0) == flap
            c.pattern(x, y, up ? ["G.....G", ".w...w.", "..wWw.."] : ["..wWw..", ".w...w.", "G.....G"],
                      ["G": C(0x8A8C94, fade), "w": C(0xF4F4F0, fade), "W": C(0xFFFFFF, fade)])
        }
        return
    }
    if let a = p.melee {
        // The furled umbrella swung by the crook.
        clawdbergSmear(c, clawdbergHand, p.trail, from: 3, to: 15, C(0xB8B8C8))
        clawdbergBar(c, clawdbergHand, a, from: -3, to: 1, wood, r: 0.7)
        let back = clawdbergReach(clawdbergHand, a, -3)
        c.px(Int(back.x.rounded()), Int(back.y.rounded()) + 1, wood)
        clawdbergBar(c, clawdbergHand, a, from: 1, to: 15, shaft, r: 0.5)
        clawdbergBar(c, clawdbergHand, a, from: 4, to: 13, brolly, r: 1.3)
        clawdbergBar(c, clawdbergHand, a, from: 15, to: 16.5, C(0xC8CCD4), r: 0.5)
        return
    }
    // At rest: leaning on it like a cane, the crook under his hand.
    c.rect(42, 34, 1, 10, shaft); c.rect(41, 36, 3, 6, brolly); c.px(42, 41, brollyL)
    c.pattern(40, 31, [".WW.", "W..W", "...W"], ["W": wood])
    c.rect(38, 33, 3, 3, tweed)
}

// MARK: - Marcus Brodie

/// Marcus Brodie: Clawd going bald, a fringe of grey hair round the sides and a few strands combed over, a bushy grey
/// moustache, a grey three-piece suit with a white shirt and a dark red tie. He doesn't fight. Signature: he unfolds
/// a map, peers at it, turns it round and peers again, hopelessly lost, a question mark bobbing over his head.
private func drawMarcusBrodie(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x8A8E96), suitD = C(0x6A6E76), suitL = C(0xA4A8B0), shirt = C(0xF0EEE8), tie = C(0x7A2230)
    let hair = C(0xD4D0C8), hairD = C(0xA8A49C)
    let paper = C(0xE8D8A8), paperD = C(0xC4B080)
    let sig = p.signature
    let reading = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false

    drawLegs(c, Look(leg: suit), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x2A2420), height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: suit))
    // The suit, its waistcoat, the shirt and tie.
    c.rect(18, 34, 20, 4, suit); c.rect(37, 34, 1, 4, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(24, 34, ["lSTTSl", ".lTTl.", ".dTTd."], ["l": suitL, "S": shirt, "T": tie, "d": suitD])
    // Light along the shoulders, a pocket flap either side and a crease down the far side.
    c.rect(18, 34, 5, 1, suitL); c.rect(31, 34, 6, 1, suitL)
    c.rect(19, 36, 3, 1, suitD); c.rect(33, 36, 3, 1, suitD); c.px(35, 35, suitD)
    // The fringe of grey hair and the combed-over strands, and the moustache.
    c.pattern(17, 24, [
        "....h.h..h.h.h......",
        "..HHHHHHHHHHHHHHHH..",
        ".HH..............HH.",
        ".HH..............HH.",
        ".H................H.",
    ], ["H": hair, "h": hairD])
    c.pattern(24, 32, [".MMMMMMM.", "MM.....MM"], ["M": hair])

    guard reading, let s = sig else {
        c.rect(15, 33, 3, 3, suit); c.rect(38, 33, 3, 3, suit)
        c.rect(15, 35, 3, 1, suitD); c.rect(38, 35, 3, 1, suitD)   // the cuffs
        return
    }
    // The map held up in front of him, turned round half way through.
    c.rect(15, 32, 3, 3, suit); c.rect(38, 32, 3, 3, suit)
    let map = [
        "PPPPPPPPPPPP",
        "PggPPPPPPbbP",
        "PgggPrrPPbbP",
        "PPgPrPPrPPPP",
        "PPPrPPPPrPxP",
        "PPrPPPPPPrPP",
        "PdPPPPPPPPdP",
    ]
    let pal: [Character: Px] = ["P": paper, "d": paperD, "g": C(0x7A9A5A), "b": C(0x6A8AB0), "r": C(0xB83A2A),
                                "x": C(0x1E1E22)]
    if s < 0.38 {
        c.pattern(37, 29, map, pal)
    } else if s < 0.52 {
        let turn = abs(cos((s - 0.38) / 0.14 * .pi))
        let w = max(1, Int((turn * 12).rounded()))
        c.rect(43 - w / 2, 29, w, 7, paper); c.rect(43 - w / 2, 35, w, 1, paperD)
    } else {
        c.pattern(37, 29, map.reversed().map { String($0.reversed()) }, pal)
        let bob = sin(p.t * 4) > 0 ? -1 : 0
        c.pattern(27, 15 + bob, ["QQQ", "..Q", ".QQ", ".Q.", "...", ".Q."], ["Q": C(0xFFF2C8)])
    }
}

// MARK: - The Grail Knight

/// The Grail Knight: a very old Clawd in a chain-mail coif round his face, mail on his arms and legs, a long white
/// beard and bushy white eyebrows, and a white tabard with a red cross, belted, down over his knees. He fights with a
/// long silver sword; at rest he stands with it point down before him, hands on the pommel. Signature: he lifts the
/// plain clay cup high over his head in both hands, and it glows.
private func drawGrailKnight(_ c: PixelCanvas, _ p: Pose) {
    let mail = C(0x9AA0A8), mailD = C(0x6E747C), tabard = C(0xEEEAE0), tabardD = C(0xC8C2B4), cross = C(0xB02428)
    let beard = C(0xF4F2EC), beardD = C(0xA8A6A0), steel = C(0xD8DCE4), hilt = C(0xA88A4A), grip = C(0x5A3A22)
    let sig = p.signature
    let raising = sig.map { $0 > 0.05 && $0 < 0.95 } ?? false

    drawLegs(c, Look(leg: mail), step: p.step)
    if !seatedPose {
        // Rings picked out on the mail leggings.
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            for y in stride(from: lifted ? 39 : 40, to: lifted ? 42 : 43, by: 2) { c.px(lx + (y / 2) % 2, y, mailD) }
        }
    }
    clawdbergBoots(c, step: p.step, mailD, height: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: mail))
    // The tabard, belted, hanging over his knees, with its cross.
    c.rect(18, 33, 20, 5, tabard); c.rect(37, 33, 1, 5, tabardD)
    hem(c, tabard, dark: tabardD, length: 2, x: 18, w: 20)
    c.rect(18, 37, 20, 1, C(0x6A4A2A))
    c.rect(27, 34, 2, seatedPose ? 5 : 6, cross); c.rect(24, 35, 8, 2, cross)
    // The coif round his face.
    chainMail(c, 17, 22, [
        ".....MMMMMMMMMMMM.....",
        "...MMMMMMMMMMMMMMMM...",
        "..MMMMMMMMMMMMMMMMMM..",
        ".MMMMMMMMMMMMMMMMMMMM.",
        ".MMMMMMMMMMMMMMMMMMMM.",
        ".MMM..............MMM.",
        ".MMM..............MMM.",
        ".MMM..............MMM.",
        ".MMM..............MMM.",
        ".MMMM............MMMM.",
        ".MMMMM..........MMMMM.",
        "MMMMMMM........MMMMMMM",
    ], light: mail, dark: mailD)
    // Bushy white eyebrows and the long beard.
    c.rect(21, 28, 4, 1, beard); c.rect(31, 28, 4, 1, beard)
    c.pattern(20, 31, [
        "dBB..........BBd",
        "dBBBBBBBBBBBBBBd",
        ".dBBBBbBBBbBBBd.",
        "..ddBBBBBBBBdd..",
        "....ddBBBBdd....",
    ], ["B": beard, "b": beardD, "d": beardD])

    if raising, let s = sig {
        // The cup lifted high in both hands, glowing.
        let up = min(1, (s - 0.05) / 0.2, (0.95 - s) / 0.15)
        let cy = 30 - Int((up * 14).rounded())
        clawdbergLine(c, 16, 33, 23, Double(cy + 3), mailD, 1.0)
        clawdbergLine(c, 39, 33, 33, Double(cy + 3), mailD, 1.0)
        c.rect(23, cy + 1, 2, 2, clawdOrange); c.rect(31, cy + 1, 2, 2, clawdOrange)
        if up >= 1 {
            disc(c, 28, Double(cy + 1), r: 5, C(0xFFE89A, 0.18))
            disc(c, 28, Double(cy + 1), r: 3, C(0xFFF2C8, 0.25))
            let tw = Int(p.t * 6) % 4
            c.px(22 + tw * 3, cy - 3 + tw % 2, C(0xFFF6D0))
        }
        c.pattern(26, cy - 1, ["CCCCC", "cCCCc", ".cCc.", "..c..", ".ccc."], ["C": C(0x9A7A4E), "c": C(0x6A5034)])
        return
    }
    c.rect(15, 33, 3, 3, mail)
    if let a = p.melee {
        // The sword: grip, crossguard, the long blade.
        clawdbergSmear(c, clawdbergHand, p.trail, from: 4, to: 17, C(0xE8ECF4))
        clawdbergBar(c, clawdbergHand, a, from: -2.5, to: 1, grip, r: 0.7)
        let g = clawdbergReach(clawdbergHand, a, 1.5)
        let g0 = clawdbergReach(g, a + 90, 2.5), g1 = clawdbergReach(g, a - 90, 2.5)
        clawdbergLine(c, g0.x, g0.y, g1.x, g1.y, hilt, 0.6)
        clawdbergBar(c, clawdbergHand, a, from: 2, to: 16, steel, r: 0.8)
        clawdbergBar(c, clawdbergHand, a, from: 3, to: 15, C(0xFFFFFF, 0.6), r: 0.3)
        return
    }
    // At rest: the sword point down before him, both hands on the pommel.
    c.rect(43, 31, 1, 13, steel); c.rect(44, 31, 1, 11, C(0xA8ACB4))
    c.rect(41, 30, 6, 1, hilt); c.rect(43, 27, 2, 3, grip); c.rect(43, 26, 2, 1, hilt)
    c.rect(38, 29, 3, 3, mail); c.rect(41, 28, 2, 2, mail)
}

// MARK: - Mutt Willclawds

/// Mutt Willclawds: Clawd in a black leather biker jacket over a white T-shirt, jeans and black boots, a black biker
/// cap pushed back on his head and a slick dark quiff rising in front of it. He fights with a switchblade, flicked
/// open. Signature: out comes a comb instead, flicked like the blade, and he runs it through the quiff, which shines.
private func drawMutt(_ c: PixelCanvas, _ p: Pose) {
    let leather = C(0x1E1E24), leatherL = C(0x3A3A44), tee = C(0xF0EEE8), jeans = C(0x3A4C70)
    let quiff = C(0x2A1A12), quiffL = C(0x4A3020), chrome = C(0xC8CCD4), comb = C(0xE8DCC0)
    let sig = p.signature
    let flicking = sig.map { $0 > 0.05 && $0 < 0.18 } ?? false
    let combing = sig.map { $0 >= 0.18 && $0 < 0.92 } ?? false

    drawLegs(c, Look(leg: jeans), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x141416), height: 2)
    c.oy += p.breathe
    drawBody(c, Look(arm: leather))
    // The jacket open over the T-shirt, its collar and zip.
    c.rect(18, 33, 20, 5, leather); c.rect(18, 37, 20, 1, C(0x121216))
    c.rect(25, 33, 6, 5, tee); c.rect(26, 37, 4, 1, C(0xD0CEC8))
    c.rect(23, 33, 2, 2, leatherL); c.rect(31, 33, 2, 2, leatherL)
    c.rect(24, 35, 1, 3, chrome); c.px(20, 36, chrome)
    // The leather catching the light along the shoulders and down a crease, a seam on each side.
    c.rect(18, 33, 4, 1, leatherL); c.rect(33, 33, 4, 1, leatherL)
    c.rect(21, 35, 1, 2, leatherL); c.rect(34, 34, 1, 3, C(0x121216))
    // Sideburns, the cap pushed back, and the quiff in front of it.
    c.rect(18, 26, 2, 3, quiff)
    c.pattern(16, 20, [
        "...KKKKKKKKKK..",
        "..KKKKKKlKKKKK.",
        ".KKKKKKKKKKKKKK",
        ".KKKKKKKKKKKKKK",
        ".SSSSSSSSSSSSSS",
        "KKKKKKKKKKKKKKK",
    ], ["K": leather, "l": leatherL, "S": chrome])
    c.pattern(30, 19, [
        "...QQ...",
        "..QqqQ..",
        ".QqqQQQ.",
        "QQQQqqQQ",
        "QQQQQQQ.",
        "QQQQQ...",
        "QQQ.....",
    ], ["Q": quiff, "q": quiffL])
    c.rect(15, 33, 3, 3, leather); c.rect(15, 35, 3, 1, C(0x121216))

    if flicking {
        // The comb flicked out at his hip.
        c.rect(38, 33, 3, 3, leather)
        c.pattern(41, 32, ["KKKKK", "K.K.K"], ["K": comb])
        return
    }
    if combing, let s = sig {
        // The comb run back through the quiff, and the quiff shining.
        let sweep = Int((sin((s - 0.18) * 14) * 2.5).rounded())
        let cx = 33 + sweep
        clawdbergLine(c, 39, 33, Double(cx + 3), 21, leather, 1.2)
        c.pattern(cx, 18, ["KKKKK", "K.K.K"], ["K": comb])
        if Int(p.t * 8) % 3 == 0 { c.px(33, 21, C(0xFFFFFF, 0.9)); c.px(35, 22, C(0xFFFFFF, 0.6)) }
        return
    }
    c.rect(38, 33, 3, 3, leather)
    guard let a = p.melee else { return }
    // The switchblade.
    clawdbergSmear(c, clawdbergHand, p.trail, from: 2, to: 8, C(0xE8ECF4))
    clawdbergBar(c, clawdbergHand, a, from: -2, to: 1.5, C(0x141416), r: 0.8)
    clawdbergBar(c, clawdbergHand, a, from: 2, to: 8, chrome, r: 0.5)
}

// MARK: - Helena Shore

/// Helena Shore: Clawd with auburn hair swept back into a high ponytail, a 1969 trouser suit in teal with wide lapels
/// over a white blouse with a big pointed collar, and brown ankle boots. She fires a pistol. Signature: she flips
/// the half of the Dial, a bronze half-disc, spinning up into the air, catches it and holds it up so it glints.
private func drawHelenaShore(_ c: PixelCanvas, _ p: Pose) {
    let suit = C(0x3E7480), suitD = C(0x2C5660), suitL = C(0x5A909A), blouse = C(0xF4F0E8)
    let hair = C(0x8A3E22), hairL = C(0xB4582E), hairD = C(0x5E2A16)
    let bronze = C(0xB08A3A), bronzeD = C(0x6A5020), patina = C(0x5A8A6A)
    let sig = p.signature
    let flipping = sig.map { $0 > 0.08 && $0 < 0.95 } ?? false

    drawLegs(c, Look(leg: suit), step: p.step)
    clawdbergBoots(c, step: p.step, C(0x6A4428), height: 2)
    c.oy += p.breathe
    // The ponytail, behind her head, swinging as she walks.
    let swing = p.walking && p.step == 0 ? 1 : 0
    c.pattern(12 + swing, 21, [
        "...TT",
        ".HHHT",
        "HHHH.",
        "HHlH.",
        "HHH..",
        "HHH..",
        ".HH..",
        ".Hd..",
        "..H..",
    ], ["H": hair, "l": hairL, "d": hairD, "T": hairD])
    drawBody(c, Look(arm: suit))
    // The trouser suit, its wide lapels and the blouse's pointed collar.
    c.rect(18, 33, 20, 5, suit); c.rect(37, 33, 1, 5, suitD); c.rect(18, 37, 20, 1, suitD)
    c.pattern(22, 33, ["lllBBBBlll.", ".llBBBBBll.", "..lBBBBl...", "...BBBB...."], ["l": suitL, "B": blouse])
    // The hair, swept back off the face.
    c.pattern(17, 20, [
        ".....HHHHHHHHHHH......",
        "...HHHHHlHHHHHHHHH....",
        "..HHHHHHHHlHHHHHHHHH..",
        ".HHHHHHHHHHHHHHlHHHHH.",
        ".HHHHHHHHHHHHHHHHHHHH.",
        ".HHHHHHHHHHHHHHHHHHH..",
        ".HHd................d.",
        ".HH...................",
    ], ["H": hair, "l": hairL, "d": hairD])
    c.rect(15, 33, 3, 3, suit)

    if flipping, let s = sig {
        // The half-disc spinning up and caught, then held up, glinting.
        let face = ["..BBB..", ".BgBdB.", "BBdBBpB", "BBBBBBB"]
        let pal: [Character: Px] = ["B": bronze, "g": bronzeD, "d": bronzeD, "p": patina]
        if s < 0.6 {
            let k = (s - 0.08) / 0.52
            let y = 29 - Int((sin(k * .pi) * 14).rounded())
            c.rect(38, 31, 3, 3, suit)
            switch Int(p.t * 12) % 4 {
            case 0: c.pattern(39, y, face, pal)
            case 2: c.pattern(39, y, Array(face.reversed()), pal)
            default: c.rect(39, y + 2, 7, 1, bronze)
            }
        } else {
            c.rect(38, 28, 3, 6, suit)
            c.pattern(38, 24, face, pal)
            let glint = Int(p.t * 4) % 5
            if glint < 3 { c.px(40 + glint, 25, C(0xFFF2C0)) }
        }
        return
    }
    // The pistol.
    c.rect(38, 33, 3, 3, suit)
    c.oy += p.gunY
    c.pattern(40, 31, ["KKKKKKK", "KKGKK..", "KK.....", "KK....."], ["K": C(0x24242A), "G": C(0x5E626C)])
}
