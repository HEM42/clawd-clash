import Foundation

// Villains: the Men who took the Dark Lord's side, or just their own: the mad Steward, the pirate of Umbar, the
// warriors of Harad and the East, the greedy Master of Lake-town, and the King of the Dead, who is no Man any more.
// Clawd in costume, every one of them: the robes, coats, masks and helmets drawn over (and around) the blocky body.
// The corsair's face is a darker brown, Harad's and the Easterling's are hidden behind gold, and the King of the
// Dead is a pale green ghost, see-through and glowing, a skull where the face should be, a head taller for his crown.
// The Master is round: his belly bulges out of his coat (`bulk` says how far).

let ringsVillains7: [RingsVillain: Persona] = [
    .denethor: Persona(name: "Denethrow", weapon: .blaster, shot: .fire, muzzle: (44, 22), headTop: 20, signature: 3.2,
                       callout: "Abandon your try blocks! Throw for your lives!", draw: drawDenethor),
    .kingOfTheDead: Persona(name: "The King of the Dead Code", weapon: .saber, canSit: false, headTop: 16, signature: 3.0,
                            callout: "The way is shut. It was written by dead code, and dead code keeps it.",
                            draw: drawKingOfTheDead),
    .corsair: Persona(name: "Cursor of Umbar", weapon: .saber, headTop: 21, signature: 3.0,
                      callout: "Point and click, lads! Board her!", draw: drawCorsair),
    .haradrim: Persona(name: "Harad-RAM", weapon: .blaster, shot: .arrow, muzzle: (46, 34), handGun: false, headTop: 20,
                       signature: 2.6, callout: "Charge! RAM them with all sixty-four gigs!", draw: drawHaradrim),
    .easterling: Persona(name: "The Eastereggling", weapon: .saber, armoured: true, headTop: 12, signature: 3.2,
                         callout: "Nobody ever looks behind the credits in the East.", draw: drawEasterling),
    .masterOfLaketown: Persona(name: "The Master branch of Lake-town", bulk: 3, headTop: 23, signature: 3.4,
                               callout: "Nothing merges into master without my cut.", draw: drawMasterOfLaketown),
]

// MARK: - Denethrow

/// Denethrow, the mad Steward of Gondor: a heavy black robe to the ankles with a silver collar and hem, the White Tree
/// of Gondor in white on his chest under three silver stars, a black cloak edged in silver behind him, long lank grey
/// hair to the shoulders and no beard. His face is gaunt and haunted: brows drawn up in the middle, shadows under the
/// eyes and hollow cheeks. A burning torch in his fist, held up, its flame flickering; he throws fire from it.
/// Signature: the Steward's supper while Pippin sings: his back hand brings a cherry tomato up to his mouth (…0.22),
/// he bites it with a squirt of juice and chews it noisily, mouth working open and shut, while the juice runs down his
/// chin onto his collar (…0.8); then he wipes his chin with the back of his hand and is grim again.
private func drawDenethor(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0x1E1E26), robeShade = C(0x121218), robeLight = C(0x34343E)
    let silver = C(0xC8CED8), silverDark = C(0x8A909C), tree = C(0xF2F4F8)
    let hair = C(0xA4A4A8), hairShade = C(0x7A7A80), hairLight = C(0xC4C4C8)
    drawBackCape(c, t: p.t, speed: p.capeSpeed, color: C(0x18181E), edge: silverDark, hem: 42)
    drawLegs(c, Look(leg: robeShade), step: p.step)
    drawBoots(c, p.step, C(0x0C0C10), rows: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: robe))
    // The robe, the collar to the ankles, flaring a little, a silver hem.
    c.rect(18, 33, 20, 5, robe)
    c.rect(37, 33, 1, 5, robeShade)
    for y in 38...41 where y + c.oy <= 43 {
        let k = y - 38, l = 17 - (k + 1) / 2, r = 38 + (k + 1) / 2
        c.rect(l, y, r - l + 1, 1, y == 41 ? silverDark : robe)
        if y < 41 { c.px(l, y, robeLight); c.px(r, y, robeShade); c.px(22, y, robeShade); c.px(33, y, robeShade) }
    }
    c.rect(18, 33, 20, 1, silverDark)                                         // the silver collar
    // The White Tree under three stars.
    c.pattern(24, 34, [
        "s.s.s",
        ".T.T.",
        "TTTTT",
        ".TTT.",
        "..T..",
        "..T..",
        ".T.T.",
    ], ["T": tree, "s": silver])
    // Long lank grey hair to the shoulders, receding at the temples.
    c.pattern(16, 20, [
        ".......HHHHHHHHHH.......",
        "....HHHHHHHHHHHHHHHH....",
        "..HHHHlHHHHHHHHlHHHHHH..",
        ".HHHHHHHHHhHHHHHHHHHHHH.",
        ".HHhHHHHHHhhHHHHHhHHHHH.",
        "HHHhHHHh........hHHHhHHH",
        "HHHh................hHHH",
        "HHh..................hHH",
        "HHh..................hHH",
        "HHH..................HHH",
        "HHh..................hHH",
        "HHh..................hHH",
        "HHH..................hHH",
        ".Hh..................hH.",
        ".H....................H.",
    ], ["H": hair, "h": hairShade, "l": hairLight])
    // The haunted face: brows up in the middle, shadowed eyes, hollow cheeks.
    c.pattern(21, 27, ["..h........h..", "hh..........hh"], ["h": hairShade])
    c.rect(22, 32, 2, 1, clawdShade); c.rect(32, 32, 2, 1, clawdShade)
    c.rect(20, 31, 1, 2, clawdShade); c.rect(35, 31, 1, 2, clawdShade)
    if let s = p.signature { drawDenethorSupper(c, s, sleeve: robeLight) }
    // The torch, held up in his fist, the flame on top.
    c.oy += p.gunY
    drawTorch(c, t: p.lt)
    c.rect(38, 33, 3, 3, robe); c.rect(40, 33, 1, 3, silverDark)
    c.rect(41, 33, 3, 3, clawdOrange); c.px(41, 35, clawdShade)
}

/// The cherry tomato, `s` through the signature: the back hand, its sleeve across his chest, brings it up to the mouth;
/// the bite and its squirt of juice; the chewing, loud, the juice trickling down his chin; and the wipe.
private func drawDenethorSupper(_ c: PixelCanvas, _ s: Double, sleeve: Px) {
    let red = C(0xF01A20), redLight = C(0xFF8A70), redDark = C(0xA80C14), stalk = C(0x2E8A2E), leafy = C(0x5AC04A)
    let juice = C(0xD8101A), noisy = C(0xF4F4F8, 0.85)
    // The hand: from the elbow up to the mouth and back, later up to the chin and along it, and back down.
    let rest = (x: 17.0, y: 35.0), mouth = (x: 24.0, y: 33.0)
    var hand: (x: Double, y: Double)? = nil
    func between(_ a: (x: Double, y: Double), _ b: (x: Double, y: Double), _ u: Double) -> (x: Double, y: Double) {
        (a.x + (b.x - a.x) * u, a.y + (b.y - a.y) * u)
    }
    if s > 0.02 && s < 0.42 {
        let u = s < 0.2 ? smooth((s - 0.02) / 0.18) : s < 0.3 ? 1 : 1 - smooth((s - 0.3) / 0.12)
        hand = between(rest, mouth, u)
    } else if s > 0.78 && s < 0.98 {
        let wipe = (x: 23 + 5 * smooth((s - 0.85) / 0.06), y: 34.0)
        let u = s < 0.85 ? smooth((s - 0.78) / 0.07) : s < 0.91 ? 1 : 1 - smooth((s - 0.91) / 0.07)
        hand = between(rest, wipe, u)
    }
    // The juice running down his chin from the corner of his mouth, a drop gathering at the end; wiped off.
    if s > 0.3 && s < 0.89 {
        let n = min(5, Int((s - 0.3) / 0.2 * 5) + 1)
        let a = s < 0.86 ? 1 : 1 - (s - 0.86) / 0.03
        c.rect(29, 33, 1, n, juice.alpha(a))
        if n >= 5 { c.px(29, 38, red.alpha(a)); c.px(30, 38, juice.alpha(a * 0.5)) }
    }
    // The mouth: open for the bite, then chewing, open and shut.
    if s > 0.2 && s < 0.8 {
        let open = s < 0.27 || Int((s - 0.27) / 0.05) % 2 == 1
        if open {
            c.rect(25, 31, 4, 2, ink)
            if s >= 0.27 { c.px(26, 32, red); c.px(27, 31, juice) }
        } else {
            c.rect(25, 32, 4, 1, clawdShade); c.px(24, 31, clawdShade); c.px(29, 31, clawdShade)
            // Chomp: the noise of it, out beside his head.
            for (x, y) in [(13, 25), (12, 24), (12, 29), (11, 29), (13, 33), (12, 34)] { c.px(x, y, noisy) }
        }
    }
    // The squirt as he bites into it: a splat at the mouth, and drops flying out and falling.
    if s > 0.26 && s < 0.4 {
        let k = (s - 0.26) / 0.14
        if k < 0.3 {
            c.pattern(24, 28, ["R..R..R", ".R.R.R.", "..RLR..", "RRLLLRR", "..RLR..", ".R.R.R.", "R..R..R"],
                      ["R": red.alpha(1 - k), "L": redLight.alpha(1 - k)])
        }
        let drops: [(Double, Double)] = [(-1.6, -1.6), (-0.6, -2.4), (0.7, -2.6), (1.7, -1.8), (2.5, -0.8), (-2.5, -0.7),
                                         (1.2, -1.1), (-1.1, -1.0)]
        for (i, d) in drops.enumerated() {
            let x = Int((27 + d.0 * k * 9).rounded()), y = Int((31 + d.1 * k * 9 + 16 * k * k).rounded())
            let col = (i % 2 == 0 ? red : juice).alpha(1 - k * 0.6)
            c.px(x, y, col)
            if i < 4 && k < 0.7 { c.px(x + 1, y, col); c.px(x, y + 1, redDark.alpha(1 - k * 0.6)) }
        }
    }
    guard let h = hand else { return }
    let hx = Int(h.x.rounded()), hy = Int(h.y.rounded())
    line(c, 17, 34.5, h.x, h.y + 0.5, sleeve, 0.8)                            // the sleeve, from the elbow
    // The tomato in his fingers, big and ripe, until it goes in.
    if s < 0.26 {
        c.pattern(hx, hy - 5, [".gSg.", ".RRR.", "RLRRR", "RRRRD", ".RDD."],
                  ["R": red, "L": redLight, "D": redDark, "S": stalk, "g": leafy])
    }
    c.rect(hx, hy, 2, 2, clawdOrange); c.px(hx + 1, hy + 1, clawdShade)
}

/// A torch, its wooden handle through the fist at (42, 34) and up to a pitch-wrapped head at row 25, and a flame
/// flickering over it (rows 18…24) in a warm glow.
private func drawTorch(_ c: PixelCanvas, t: Double) {
    let wood = C(0x6A4A2A), woodDark = C(0x4A321C), pitch = C(0x3A2818), pitchLight = C(0x5A4028)
    c.rect(42, 27, 2, 11, wood); c.rect(43, 28, 1, 10, woodDark)
    c.rect(41, 25, 4, 3, pitch); c.rect(41, 26, 4, 1, pitchLight)
    let i = Int(t * 12)
    c.glowLine(42.5, 22, 42.5, 22, core: clear, glow: C(0xFF8A2A, 0.45), coreR: 0, glowR: 5.5 + noise(i) * 0.8)
    // The flame: widest at the bottom, licking up to a tip that wavers from side to side.
    let widths = [4, 4, 4, 3, 3, 2, 1]
    for (k, w) in widths.enumerated() {
        let y = 24 - k
        let sway = k >= 4 ? Int((noise(i * 3 + k) * 2.99).rounded(.down)) - 1 : 0
        let l = 41 + (4 - w + 1) / 2 + sway
        c.rect(l, y, w, 1, C(0xFF6A1A))
        if w >= 3 { c.rect(l + 1, y, w - 2, 1, k < 2 ? C(0xFFF2B0) : C(0xFFC83A)) }
        else if k == 5 { c.px(l, y, C(0xFFB02A)) }
    }
    if noise(i + 41) > 0.6 { c.px(42 + Int(noise(i + 5) * 2), 16, C(0xFFB02A, 0.7)) }  // a spark
}

// MARK: - The King of the Dead Code

/// The King of the Dead, a ghost, a head taller than a Man: all of him pale green and see-through, with a glow round
/// his edges and wisps rising off him. A crown of thorny, uneven points with three green gems in its band, a skull for
/// a face (hollow sockets with a pinprick of light in each, the nose a hole, a row of teeth), long ghostly hair at his
/// sides, and a tattered spectral robe over the body, its hem in rags and more rags streaming out behind him. His
/// sword is a ghost too: a long pale blade glowing green, swung with a green smear behind a fast stroke. Signature:
/// the dead code no one can see: he fades almost all the way out (…0.25), until only the two pinpricks of light in
/// his eye sockets hang in the air, and laughs a ghostly "HA HA" that drifts up in wisps; then he fades back in,
/// his jaw still chattering with the laugh (…0.88).
private func drawKingOfTheDead(_ c: PixelCanvas, _ p: Pose) {
    let s = p.signature
    // How far gone he is: 0 there, 1 all but invisible.
    let gone: Double = s.map { $0 < 0.25 ? smooth($0 / 0.25) : $0 < 0.6 ? 1 : 1 - smooth(($0 - 0.6) / 0.25) } ?? 0
    let jaw = s.map { $0 > 0.3 && $0 < 0.88 && Int($0 * 48) % 2 == 0 } ?? false
    ghostLayer(c, alpha: 0.8 * (1 - 0.92 * gone), glow: C(0x8AFFA8, 0.24 * (1 - gone))) {
        drawKingOfTheDeadBody($0, p, jaw: jaw)
    }
    // Wisps rising off him, fading as they go.
    let oy = c.oy
    c.oy += p.breathe
    for (k, x0) in [16, 21, 34, 39].enumerated() {
        let f = frac(p.lt * 0.45 + Double(k) * 0.27)
        let x = x0 + Int((sin(f * 6 + Double(k)) * 1.5).rounded()), y = 30 - Int(f * 18)
        let fade = 1 - 0.7 * gone
        c.px(x, y, C(0xC8FFD4, 0.6 * (1 - f) * fade)); c.px(x, y + 1, C(0x8AFFA8, 0.35 * (1 - f) * fade))
    }
    if let s = s { drawDeadLaugh(c, s, gone: gone) }
    c.oy = oy
}

/// The laugh, `s` through the signature: the pinpricks in his eyes left hanging while the rest of him is gone, and
/// two ghostly "HA"s rising off him, wavering, fading as they go.
private func drawDeadLaugh(_ c: PixelCanvas, _ s: Double, gone: Double) {
    if gone > 0 {
        for x in [22, 32] {
            c.px(x, 28, C(0xF0FFB0, gone))
            for (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1)] { c.px(x + dx, 28 + dy, C(0x8AFFA8, 0.45 * gone)) }
        }
    }
    let ha = ["X.X.XXX", "X.X.X.X", "XXX.XXX", "X.X.X.X", "X.X.X.X"]
    for (i, start) in [0.3, 0.5].enumerated() where s > start && s < start + 0.36 {
        let k = (s - start) / 0.36
        let x = 41 + i * 4 + Int((sin(k * 9 + Double(i)) * 1.2).rounded()), y = 21 - i * 3 - Int(k * 12)
        let a = min(1, k * 6) * (1 - k * k)
        c.pattern(x, y, ha, ["X": C(0xC8FFD4, 0.9 * a)])
        c.px(x - 1 + Int(k * 3) % 2, y + 6, C(0x8AFFA8, 0.5 * a))           // a wisp trailing off it
    }
}

/// Everything of the King that is see-through, drawn opaque for `ghostLayer` to fade (`jaw`: dropped open, laughing).
private func drawKingOfTheDeadBody(_ c: PixelCanvas, _ p: Pose, jaw: Bool = false) {
    let ghost = C(0x8ED8A0), ghostShade = C(0x5EA878), ghostLight = C(0xC4F4CC)
    let robe = C(0x4E8A60), robeDark = C(0x356A48), robeLight = C(0x6EAA80)
    let bone = C(0xDCF8E0), boneShade = C(0xA8D8B4), socket = C(0x0C2416), spark = C(0xF0FFB0)
    let crown = C(0x6EB884), crownLight = C(0xC8F8D0), crownDark = C(0x3E7A52), gem = C(0x3AFF7A)
    // The rags streaming out behind him, in strips.
    for y in 27...41 where y + c.oy <= 43 {
        let k = Double(y - 27) / 14
        let sway = sin(p.lt * 2.6 + k * 2.4) * k * 2
        var l = Int((15.5 - k * 5 + sway).rounded())
        if y % 3 == 0 { l += 2 }
        if y > 38 && y % 2 == 0 { continue }
        c.rect(l, y, 18 - l, 1, robeDark)
        c.px(l, y, robe)
    }
    drawLegs(c, Look(leg: ghostShade), step: p.step)
    c.oy += p.breathe
    // A taller body than Clawd's (from row 23), the back arm in a ragged sleeve.
    c.rect(18, 23, 20, 15, ghost)
    c.rect(37, 23, 1, 15, ghostShade)
    c.rect(18, 23, 1, 15, ghostLight)
    c.rect(15, 33, 3, 3, robe); c.px(15, 36, robeDark)
    // The skull.
    c.pattern(19, 24, [
        "..bbbbbbbbbbbbbb..",
        ".bbbbbbbbbbbbbbbb.",
        "bbbbbbbbbbbbbbbbbb",
        "bbSSSSbbbbbbSSSSbb",
        "bbSESSbbbbbbSESSbb",
        "bbSSSSbbbbbbSSSSbb",
        "hbbSSbbbbbbbbSSbbh",
        "hbbbbbbbSSbbbbbbbh",
        ".hbbbbbbhhbbbbbbh.",
        "..hbSbSbSbSbSbSh..",
        "...hbbbbbbbbbbh...",
    ], ["b": bone, "h": boneShade, "S": socket, "E": spark])
    // Long ghostly hair at his sides, from under the crown.
    c.pattern(16, 23, ["HHh", "HHh", "HH.", "Hh.", "HH.", ".H.", "Hh.", ".H.", "H..", ".H."], ["H": ghostLight, "h": ghost])
    c.pattern(37, 23, ["hHH", "hHH", ".HH", ".hH", ".HH", ".H.", ".hH", ".H.", "..H", ".H."], ["H": ghostLight, "h": ghost])
    // The crown of thorns.
    c.pattern(17, 16, [
        "...L.....L......L.....",
        "...P..L..P...L..P..L..",
        ".L.P.LP.PP...P..P..P..",
        ".PPP.PP.PPP.LP.PP.PP.L",
        ".PPPPPPPPPPP.PPPPPPPPP",
        "PPPPPPPPPPPPPPPPPPPPPP",
        "PPgPPPPPPPgPPPPPPPgPPP",
        "dddddddddddddddddddddd",
    ], ["P": crown, "L": crownLight, "d": crownDark, "g": gem])
    // The tattered robe from under the jaw, its hem in rags, swaying.
    for y in 35...41 where y + c.oy <= 43 {
        for x in 17...38 {
            let hem = 38 + Int(noise(x * 13) * 4) + (sin(p.lt * 3 + Double(x) * 0.7) > 0.6 ? 1 : 0)
            guard y <= hem else { continue }
            let fold = x == 22 || x == 27 || x == 33
            c.px(x, y, x == 17 ? robeLight : x == 38 || fold ? robeDark : robe)
        }
    }
    c.rect(18, 35, 20, 1, robeLight)                                          // the ragged mantle's edge
    if jaw {
        // The jaw dropped open under the teeth, laughing.
        c.rect(22, 34, 12, 1, socket)
        c.rect(22, 35, 12, 1, bone); c.px(22, 35, boneShade); c.px(33, 35, boneShade)
        for x in stride(from: 24, through: 32, by: 2) { c.px(x, 35, boneShade) }
    }
    // The ghostly sword, in his bony fist.
    let hand = Sprite.hand
    let angle = p.melee ?? 20
    for (i, a) in (p.melee == nil ? [] : p.trail).enumerated() {
        let u = unit(a)
        c.glowLine(hand.x + u.x * 4, hand.y + u.y * 4, hand.x + u.x * 18, hand.y + u.y * 18, core: C(0xC8FFD0),
                   glow: C(0x5AE07A), coreR: 0.6, glowR: 1.8, strength: 0.32 / Double(i + 1))
    }
    let u = unit(angle), n = (x: -u.y, y: u.x)
    line(c, hand.x - u.x * 2.5, hand.y - u.y * 2.5, hand.x + u.x * 1.5, hand.y + u.y * 1.5, crownDark, 0.7)   // the grip
    c.glowLine(hand.x + u.x * 3, hand.y + u.y * 3, hand.x + u.x * 18, hand.y + u.y * 18, core: C(0xE4FFE8),
               glow: C(0x5AE07A), coreR: 0.6, glowR: 1.6, strength: 0.9)
    let g = (x: hand.x + u.x * 2.5, y: hand.y + u.y * 2.5)
    line(c, g.x - n.x * 2.5, g.y - n.y * 2.5, g.x + n.x * 2.5, g.y + n.y * 2.5, crown, 0.6)                    // the crossguard
    c.rect(38, 33, 2, 3, robe); c.rect(40, 33, 2, 3, ghostLight); c.px(40, 35, boneShade)
}

/// Draws `art` on a scratch canvas (same offsets as `c`) and copies it onto `c` faded to `alpha`, with a one-pixel
/// halo of `glow` round its solid edges: a ghost.
private func ghostLayer(_ c: PixelCanvas, alpha: Double, glow: Px, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    defer { c.ox = ox; c.oy = oy; c.baseY = by }
    let solid = { (x: Int, y: Int) -> Bool in
        x >= 0 && y >= 0 && x < s.w && y < s.h && s.buf[(y * s.w + x) * 4 + 3] > 120
    }
    for y in 0..<s.h {
        for x in 0..<s.w {
            let i = (y * s.w + x) * 4
            if s.buf[i + 3] > 0 {
                c.px(x, y, unpremultiplied(s, i).alpha(alpha))
            } else if solid(x - 1, y) || solid(x + 1, y) || solid(x, y - 1) || solid(x, y + 1) {
                c.px(x, y, glow)
            }
        }
    }
}

// MARK: - Cursor of Umbar

/// The Cursor of Umbar, a corsair captain: a darker brown face, a black moustache and a tuft of beard, a red head-scarf
/// with pale spots knotted at the back, its ends hanging, black curls under it, and a gold hoop in his ear. A long
/// black coat with red lapels, red cuffs and a red hem over a cream shirt, a red sash round his middle, its end
/// hanging, and tall black boots. An iron hook for his back hand; in the other a curved cutlass with a gold guard,
/// held low, swung with a smear behind a fast stroke. Signature: a blinking text cursor turns up in the air over his
/// head; he eyes it, winds the cutlass up over his head (…0.42) and slashes it in two (the halves tumble away, …0.66),
/// lowers the blade, satisfied, and the cursor blinks right back where it was, until it's done.
private func drawCorsair(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x8A4A2C), skinShade = C(0x6A3420)
    let coat = C(0x1E1A20), coatShade = C(0x0E0C10), coatLight = C(0x36303C)
    let red = C(0xB82A26), redDark = C(0x7E1A18), redLight = C(0xE05A4A)
    let gold = C(0xE8B840), shirt = C(0xE0D4B4), beard = C(0x1A1210), iron = C(0xA8AEB8)
    drawLegs(c, Look(leg: C(0x3A2C28)), step: p.step)
    drawBoots(c, p.step, C(0x141010), rows: 4)
    c.oy += p.breathe
    drawBody(c, Look(body: skin, shade: skinShade, arm: coat))
    let sig = p.melee == nil ? p.signature : nil
    if let s = sig, s > 0.06, s < 0.92 {
        // Eyes up, on the cursor.
        c.rect(22, 31, 2, 1, skin); c.rect(32, 31, 2, 1, skin); c.rect(22, 28, 2, 1, ink); c.rect(32, 28, 2, 1, ink)
    }
    // Black curls under the scarf, at the back of his head.
    c.pattern(15, 26, [".BB", "BBB", "BbB", "BB.", ".B."], ["B": beard, "b": C(0x3A2A24)])
    // The coat, collar to knee, a slit up the back of the skirt and a red hem.
    c.rect(18, 33, 20, 5, coat)
    c.rect(37, 33, 1, 5, coatShade)
    for y in 38...40 where y + c.oy <= 43 {
        let l = 18 - (y - 37)
        c.rect(l, y, 38 - l, 1, y == 40 ? red : coat)
        if y < 40 { c.px(l, y, coatLight); c.px(26, y, coatShade) }
    }
    // The shirt open at the neck between red lapels, and the sash.
    c.pattern(21, 33, [
        "RRSSSSSSSSSSRR",
        ".rRRSSSSSSRRr.",
        "..rRRSSSSRRr..",
    ], ["S": shirt, "R": red, "r": redDark])
    c.rect(18, 36, 20, 2, red); c.rect(18, 37, 20, 1, redDark)
    c.pattern(20, 38, ["RR", "rR", ".r"], ["R": red, "r": redDark])      // the sash's end
    c.px(35, 34, gold); c.px(35, 39, gold)                                     // buttons
    // The moustache and the tuft of beard.
    c.rect(24, 32, 8, 1, beard); c.px(23, 33, beard); c.px(32, 33, beard)
    c.rect(27, 33, 2, 2, beard)
    // The head-scarf, knotted at the back, its ends hanging.
    c.pattern(17, 21, [
        ".....RRRRRRRRRRRR.....",
        "...RRRRRRRRRRRRRRRR...",
        "..RRRRWRRRRRRRWRRRRR..",
        ".RRRRRRRRRRWRRRRRRRRR.",
        ".RRWRRRRRRRRRRRRRWRRR.",
        "RRRRRRRRRRRRRRRRRRRRRR",
        "rrrrrrrrrrrrrrrrrrrrrr",
    ], ["R": red, "r": redDark, "W": redLight])
    c.pattern(12, 25, ["...RRR", "..RRrR", ".RRr..", "RRr...", "Rr....", ".R...."], ["R": red, "r": redDark])
    // The gold hoop in his ear.
    c.pattern(37, 29, [".G.", "G.G", "G.G", ".G."], ["G": gold])
    // The hook for a back hand.
    c.rect(15, 33, 3, 3, coat); c.rect(15, 33, 1, 3, red)
    c.pattern(12, 35, ["..I", "L.I", "I.I", ".I."], ["I": iron, "L": C(0xE0E4EC)])
    // The cutlass, held low or swung (in the signature, up over his head and down through the cursor).
    let angle = p.melee ?? sig.map(cursorSwing) ?? (seatedPose ? 8 : 35)
    let slash = sig.map { s in s > 0.42 && s < 0.54 ? [0.012, 0.024, 0.036].map { cursorSwing(s - $0) } : [] } ?? []
    for (i, a) in (p.melee == nil ? slash : p.trail).enumerated() {
        let u = unit(a)
        c.glowLine(Sprite.hand.x + u.x * 4, Sprite.hand.y + u.y * 4, Sprite.hand.x + u.x * 14, Sprite.hand.y + u.y * 14,
                   core: C(0xE8EEF4), glow: C(0xA8B4C0), coreR: 0.8, glowR: 1.9, strength: 0.32 / Double(i + 1))
    }
    drawCutlass(c, angle: angle)
    c.rect(38, 33, 2, 3, coat); c.rect(40, 33, 1, 3, red); c.rect(41, 33, 2, 3, skin); c.px(41, 35, skinShade)
    if let s = sig {
        c.oy -= p.breathe
        drawTextCursor(c, s)
    }
}

/// The cutlass's angle `s` through the signature: wound up over his head (…0.34), held there, slashed down through
/// the cursor (…0.5, it's at the cursor about 0.47), held out and back down to rest.
private func cursorSwing(_ s: Double) -> Double {
    if s < 0.12 { return 35 }
    if s < 0.34 { return 35 - 160 * smooth((s - 0.12) / 0.22) }
    if s < 0.42 { return -125 }
    if s < 0.5 { let u = (s - 0.42) / 0.08; return -125 + 145 * u * u }
    if s < 0.6 { return 20 }
    return 20 + 15 * smooth((s - 0.6) / 0.22)
}

/// The text cursor over his head, `s` through the signature: blinking (…0.47), cut in two, its halves tumbling away
/// (…0.66), then blinking back where it was (0.7…0.95).
private func drawTextCursor(_ c: PixelCanvas, _ s: Double) {
    let bar = C(0xF4F6FA), cut = 0.47
    if s > 0.04 && s < cut {
        if frac((s - 0.04) * 3 / 0.55) < 0.6 { c.rect(46, 13, 2, 11, bar) }
    } else if s >= cut && s < 0.66 {
        let k = (s - cut) / (0.66 - cut), a = 1 - k * k
        let tx = Int((k * 5).rounded()), ty = Int((-k * 4 + k * k * 9).rounded())
        c.rect(46 + tx, 13 + ty, 2, 7, bar.alpha(a))                           // the top half, flung off
        c.rect(46 - Int(k * 2), 20 + Int(k * k * 16), 2, 4, bar.alpha(a))       // the bottom half, dropping
        if k < 0.3 {
            let g = 1 - k / 0.3
            for (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1), (-2, 0), (2, 0)] { c.px(47 + dx, 19 + dy, C(0xFFF4C0, g)) }
        }
    } else if s >= 0.7 && s < 0.95 {
        if frac((s - 0.7) * 3 / 0.55) < 0.6 { c.rect(46, 13, 2, 11, bar) }
    }
}

/// A cutlass gripped at the hand: a dark grip, a gold pommel and basket guard, and a short broad blade curving up to
/// its point.
private func drawCutlass(_ c: PixelCanvas, angle: Double) {
    prop(c, at: Sprite.hand, angle: angle) { s in
        let steel = C(0xD0D4DC), edge = C(0x8A909C), gold = C(0xE8B840), goldDark = C(0xA87A22)
        s.rect(17, 20, 4, 1, C(0x3A2418)); s.px(16, 20, gold)
        s.rect(21, 18, 1, 5, gold); s.rect(17, 22, 4, 1, goldDark)
        s.rect(22, 19, 7, 2, steel); s.rect(22, 20, 7, 1, edge)
        s.rect(29, 18, 4, 2, steel); s.rect(29, 19, 4, 1, edge)
        s.rect(33, 17, 2, 2, steel); s.px(33, 18, edge); s.px(35, 16, steel)
    }
}

// MARK: - Harad-RAM

/// Harad-RAM, a chieftain of the Haradrim: a deep red turban with a gold band and a red jewel, a gold mask over the
/// face with two narrow slits for eyes and a fringe of gold coins below it, a red robe to the ankles bordered in gold,
/// a gold sash, and bare arms with gold armlets. He shoots a short recurved bow, dark red with gold tips, nocking an
/// arrow and drawing it back before each shot. Signature: a RAM charge: he lowers his head like a ram, pawing the
/// ground (…0.22), charges a few steps forward, head down, in a cloud of dust (…0.42), skids to a stop, lifts his
/// head and walks back to where he stood.
private func drawHaradrim(_ c: PixelCanvas, _ p: Pose) {
    guard let s = p.signature else { drawHaradrimBody(c, p); return }
    let m = ramCharge(s)
    let dust = C(0xC8B490)
    // Dust: kicked up behind him as he paws and charges, and in front of his feet as he skids to a stop.
    for i in 0..<4 {
        let f = frac(s * 7 + Double(i) * 0.25)
        if s > 0.06 && s < 0.44 {
            let x = 17 + m.dx - Int(f * 7) - i, y = 42 - Int(f * 4)
            c.rect(x, y, 2, 1, dust.alpha(0.7 * (1 - f))); c.px(x, y - 1, dust.alpha(0.4 * (1 - f)))
        }
        if s > 0.4 && s < 0.56 {
            let x = 38 + m.dx + Int(f * 5) + i, y = 42 - Int(f * 3)
            c.rect(x, y, 2, 1, dust.alpha(0.7 * (1 - f) * (1 - (s - 0.4) / 0.16)))
        }
    }
    c.ox += m.dx
    // Speed lines streaming off his back while he charges.
    if s > 0.26 && s < 0.44 {
        for (k, y) in [24, 29, 34].enumerated() {
            let l = 5 + Int(noise(Int(s * 60) + k * 7) * 3)
            c.rect(14 - l - k, y, l, 1, C(0xF4F4F4, 0.6))
        }
    }
    var q = p
    q.step = m.step
    if m.lean > 0 { q.breathe = 0 }
    drawHaradrimBody(c, q, lean: m.lean)
}

/// Where Harad-RAM is `s` through his charge: how far forward (`dx`), how far his head is down (`lean`, in degrees)
/// and his legs (`step`: pawing with one pair, running, walking back).
private func ramCharge(_ s: Double) -> (dx: Int, lean: Double, step: Int) {
    let lean = s < 0.18 ? 16 * smooth(s / 0.18) : s < 0.44 ? 16 : 16 * (1 - smooth((s - 0.44) / 0.1))
    if s < 0.22 { return (0, lean, s > 0.06 && Int(s * 50) % 2 == 0 ? 0 : -1) }
    if s < 0.42 { let u = (s - 0.22) / 0.2; return (Int((8 * u * u).rounded()), lean, Int(s * 45) % 2) }
    if s < 0.52 { return (8, lean, -1) }
    if s < 0.92 { return (Int((8 * (1 - smooth((s - 0.52) / 0.4))).rounded()), lean, Int(s * 22) % 2) }
    return (0, lean, -1)
}

/// Harad-RAM's legs, and the rest of him over them, leaning forward `lean` degrees from the hips.
private func drawHaradrimBody(_ c: PixelCanvas, _ p: Pose, lean: Double = 0) {
    drawLegs(c, Look(leg: C(0x7A1C1A)), step: p.step)
    drawBoots(c, p.step, C(0x4A3020), rows: 1)
    guard lean != 0 else { drawHaradrimTop(c, p); return }
    leaning(c, lean, about: (29, 39)) { drawHaradrimTop($0, p) }
}

/// Everything of Harad-RAM above the legs.
private func drawHaradrimTop(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0xA82A26), robeShade = C(0x7A1C1A), robeLight = C(0xC8443A)
    let turban = C(0x7E1A1C), turbanShade = C(0x5A1214)
    let gold = C(0xE0B040), goldDark = C(0xA87A22), goldLight = C(0xFFE07A)
    c.oy += p.breathe
    drawBody(c, Look(eye: nil))
    c.rect(16, 33, 1, 3, gold)                                                // the back armlet
    // The robe, flaring a little, a gold border down the front and round the hem.
    c.rect(18, 33, 20, 5, robe)
    c.rect(37, 33, 1, 5, robeShade)
    for y in 38...41 where y + c.oy <= 43 {
        let k = y - 38, l = 17 - (k + 1) / 2, r = 38 + (k + 1) / 2
        c.rect(l, y, r - l + 1, 1, y == 41 ? gold : robe)
        if y < 41 { c.px(l, y, robeLight); c.px(r, y, robeShade); c.px(24, y, robeShade) }
    }
    c.rect(32, 33, 1, 8, gold); c.rect(33, 33, 1, 8, goldDark)
    c.rect(18, 36, 20, 1, gold); c.px(27, 36, goldLight); c.px(28, 36, goldLight)   // the sash
    // The gold mask, eye slits, and a fringe of coins under it.
    c.rect(18, 27, 20, 6, gold)
    c.rect(18, 27, 20, 1, goldLight); c.rect(37, 27, 1, 6, goldDark)
    c.rect(21, 29, 4, 1, ink); c.rect(31, 29, 4, 1, ink)
    c.rect(21, 30, 4, 1, goldDark); c.rect(31, 30, 4, 1, goldDark)
    c.rect(27, 29, 2, 3, goldLight); c.px(28, 31, goldDark)                   // the nose ridge
    for x in stride(from: 19, through: 36, by: 2) { c.px(x, 33, x % 4 == 1 ? goldLight : goldDark) }
    // The turban.
    c.pattern(17, 20, [
        "......TTTTTTTTTT......",
        "....TTTtTTTTTTtTTT....",
        "..TTTTTTtTTTTTTTtTTT..",
        ".TTtTTTTTTtTTTTTTTTtT.",
        ".GGGGGGGGGGjGGGGGGGGG.",
        "TTTTTTTTTTTTTTTTTTTTTT",
        "TtTTTTTtTTTTTTtTTTTTtT",
    ], ["T": turban, "t": turbanShade, "G": gold, "j": C(0xE02A3A)])
    // The bow held out; an arrow on the string while he aims, drawn back before he shoots.
    var pull = 0, nocked = p.ready
    if let f = p.fire {
        let ph = frac(f.t / p.firePeriod)
        nocked = ph >= 0.45
        if ph > 0.6 { pull = Int(((ph - 0.6) / 0.4 * 3).rounded()) }
    }
    c.oy += p.gunY + (seatedPose ? -3 : 0)
    drawRecurveBow(c, pull: pull)
    c.rect(38, 33, 4, 2, clawdOrange); c.rect(39, 33, 1, 2, gold)            // the arm and its armlet
    c.rect(42, 33, 2, 3, clawdOrange)
    if nocked {
        let tail = 40 - pull
        c.rect(tail, 34, 47 - tail, 1, C(0x6A4A2A))
        c.px(47, 34, C(0xC8CCD4)); c.px(48, 34, C(0xE8ECF4))
        c.px(tail, 33, gold); c.px(tail, 35, gold)
        c.rect(tail - 1, 34, 2, 2, clawdOrange)                                // the hand on the string
    }
}

/// A short recurved bow gripped in gold at (43, 34): dark red limbs bending back towards him and flicking forward at
/// the gold tips, the string back at x 40, drawn back `pull` pixels more at the middle.
private func drawRecurveBow(_ c: PixelCanvas, pull: Int = 0) {
    let limb = C(0x5A1A16), limbLight = C(0x8A2A22), grip = C(0xE0B040), string = C(0xE8E0D0)
    for y in 26...42 where y + c.oy <= 43 {
        let d = abs(y - 34)
        let x = d <= 1 ? 44 : d <= 3 ? 43 : d <= 6 ? 42 : d == 7 ? 43 : 44
        c.px(x, y, d <= 1 ? grip : d == 8 ? grip : d % 3 == 2 ? limbLight : limb)
    }
    for y in 27...41 where y + c.oy <= 43 {
        let d = Double(abs(y - 34)) / 7
        c.px(40 + Int((2 * d * d).rounded()) - Int((Double(pull) * (1 - d)).rounded()), y, string)
    }
}

// MARK: - The Eastereggling

/// The Eastereggling, a soldier of the East: armour of small gold-bronze plates laced in rows, from the shoulders to
/// a flared skirt, with layered plates on the shoulders, over dark crimson. A tall, ornate gold helmet, its dome
/// rising to a knob and a spike, a band with a red jewel, flaps of plates hanging at the back and side, and a gold
/// mask over the whole face: narrow downturned eye slits, a straight nose, a closed mouth, no expression at all. His
/// glaive, a long shaft with a gold collar, a red tassel and a long curved blade, stands upright in his fist at rest
/// and swings with a smear behind a fast stroke. Signature: an easter egg: a little painted egg pops up out of the
/// floor behind him; he spots it ("!"), glancing back, and it hops into his back hand; he holds it up high, sparkling
/// (…0.82), then puts it back where it was, hidden again.
private func drawEasterling(_ c: PixelCanvas, _ p: Pose) {
    let bronze = C(0xB8862E), bronzeDark = C(0x6E4C16), bronzeLight = C(0xE0B04A)
    let mask = C(0xF0CC5A), maskShade = C(0xC09A34), maskLight = C(0xFFE89A)
    let cloth = C(0x4A1414), gold = C(0xE8C050)
    drawLegs(c, Look(leg: cloth), step: p.step)
    drawBoots(c, p.step, C(0x2A1A10), rows: 3)
    c.oy += p.breathe
    drawBody(c, Look(arm: bronze, eye: nil))
    // The lamellar: rows of little plates laced together, flaring into a skirt.
    for y in 33...40 where y + c.oy <= 43 {
        let flare = y >= 38 ? (y - 37) / 2 + 1 : 0
        let row = (y - 33) % 3, group = (y - 33) / 3
        for x in (18 - flare)...(37 + flare) {
            let col: Px = row == 2 ? bronzeDark : (x + group) % 3 == 0 ? bronzeDark : row == 0 ? bronzeLight : bronze
            c.px(x, y, col)
        }
    }
    c.rect(18, 38, 20, 1, cloth); c.px(27, 38, gold); c.px(28, 38, gold)      // the belt
    // Layered plates on the shoulders.
    c.pattern(14, 31, [".LLL", "BBBB", "dddd", "LLL."], ["L": bronzeLight, "B": bronze, "d": bronzeDark])
    c.pattern(35, 31, ["LLL.", "BBBB", "dddd", ".LLL"], ["L": bronzeLight, "B": bronze, "d": bronzeDark])
    // The helmet: the tall dome, its knob and spike, the band, the flaps hanging at the back and front.
    c.pattern(16, 12, [
        "...........gg...........",
        "...........GG...........",
        "..........GBBG..........",
        "...........GG...........",
        ".........BBLBBB.........",
        ".......BBBLBBBBBB.......",
        ".....BBBBLBBBBBBBBb.....",
        "....BBBBBLBBBBBBBBBb....",
        "...BBBBBBLBBBBBBBBBBb...",
        "..BBBBBBBLBBBBBBBBBBBb..",
        "..BBBBBBBBLBBBBBBBBBBb..",
        ".GGGGGGGGGGrGGGGGGGGGGG.",
        "dGGGGGGGGGGGGGGGGGGGGGGd",
    ], ["B": bronze, "b": bronzeDark, "L": bronzeLight, "G": gold, "g": C(0xFFF0B0), "d": bronzeDark, "r": C(0xD02A2A)])
    c.pattern(14, 25, ["LBB", "ddd", "LBB", "ddd", "LBB", "ddd", "LB."], ["L": bronzeLight, "B": bronze, "d": bronzeDark])
    // The mask over the face.
    c.rect(18, 25, 20, 8, mask)
    c.rect(18, 25, 20, 1, maskShade); c.rect(37, 25, 1, 8, maskShade)
    c.rect(21, 27, 4, 1, maskLight); c.rect(31, 27, 4, 1, maskLight)          // the brows
    c.rect(21, 29, 4, 1, ink); c.rect(22, 30, 2, 1, ink)
    c.rect(31, 29, 4, 1, ink); c.rect(32, 30, 2, 1, ink)
    c.rect(27, 28, 1, 4, maskLight); c.rect(28, 28, 1, 4, maskShade)          // the nose
    c.rect(25, 32, 6, 1, maskShade)                                           // the mouth
    c.px(20, 31, maskShade); c.px(35, 31, maskShade)
    if let s = p.signature, s > 0.22, s < 0.44 {
        // The eyes slide back, to the egg behind him.
        c.rect(21, 29, 4, 2, mask); c.rect(31, 29, 4, 2, mask)
        c.rect(20, 29, 4, 1, ink); c.rect(21, 30, 2, 1, ink); c.rect(30, 29, 4, 1, ink); c.rect(31, 30, 2, 1, ink)
    }
    c.pattern(38, 25, ["BL", "dd", "BL", "dd", "B."], ["L": bronzeLight, "B": bronze, "d": bronzeDark])
    // The glaive: upright at rest, swung in a fight.
    let angle = p.melee ?? -82
    for (i, a) in (p.melee == nil ? [] : p.trail).enumerated() {
        let u = unit(a)
        c.glowLine(Sprite.hand.x + u.x * 10, Sprite.hand.y + u.y * 10, Sprite.hand.x + u.x * 19, Sprite.hand.y + u.y * 19,
                   core: C(0xE8EEF4), glow: C(0xA8B4C0), coreR: 0.8, glowR: 2, strength: 0.32 / Double(i + 1))
    }
    drawGlaive(c, angle: angle)
    c.rect(38, 33, 2, 3, bronze); c.px(38, 35, bronzeDark)
    c.rect(40, 33, 3, 3, bronzeDark); c.px(40, 33, bronze)                    // the gauntlet round the shaft
    if let s = p.signature {
        drawEasterEgg(c, s, breathe: p.breathe, arm: bronze, armLight: bronzeLight, armDark: bronzeDark)
    }
}

/// The easter egg, `s` through the signature: popping up out of the floor behind him with a bounce (…0.25), a "!"
/// over his helmet as his eyes go to it, hopping into his back hand (…0.48), held up high in it among sparkles
/// (…0.82), lowered, and hopping back down to sink out of sight again, hidden for the next one to find.
private func drawEasterEgg(_ c: PixelCanvas, _ s: Double, breathe: Int, arm: Px, armLight: Px, armDark: Px) {
    let oy = c.oy
    c.oy -= breathe
    defer { c.oy = oy }
    let spot = (x: 9.0, y: 37.0)                         // sitting on the floor behind him, rows 37…43
    let raise = s < 0.48 ? 0 : s < 0.6 ? 10 * smooth((s - 0.48) / 0.12)
        : s < 0.82 ? 10 : 10 * (1 - smooth((s - 0.82) / 0.08))
    let lift = Int(raise.rounded())
    let hand = { (r: Int) -> (x: Double, y: Double) in (14, Double(26 - r + breathe)) }
    func hop(_ a: (x: Double, y: Double), _ b: (x: Double, y: Double), _ k: Double) -> (x: Double, y: Double) {
        (a.x + (b.x - a.x) * k, a.y + (b.y - a.y) * k - 6 * sin(k * .pi))
    }
    var egg: (x: Double, y: Double)? = nil
    if s > 0.08 && s < 0.38 {
        let off = s < 0.2 ? 8 - 10 * smooth((s - 0.08) / 0.12) : s < 0.25 ? -2 + 2 * smooth((s - 0.2) / 0.05) : 0
        egg = (spot.x, spot.y + off)
    } else if s >= 0.38 && s < 0.48 {
        egg = hop(spot, hand(0), smooth((s - 0.38) / 0.1))
    } else if s >= 0.48 && s < 0.9 {
        egg = hand(lift)
    } else if s >= 0.9 && s < 0.96 {
        egg = hop(hand(0), spot, smooth((s - 0.9) / 0.06))
    } else if s >= 0.96 {
        egg = (spot.x, spot.y + 8 * smooth((s - 0.96) / 0.04))
    }
    // The back arm, raised with the egg in its gauntlet.
    if lift > 0 {
        let top = 33 - lift + breathe
        c.rect(15, top, 3, lift + 3, arm); c.rect(15, top, 1, lift + 3, armLight)
        c.rect(15, top, 3, 2, armDark); c.px(15, top, arm)
    }
    // "!": he's spotted it.
    if s > 0.24 && s < 0.42 {
        let y = s < 0.27 ? 7 : 6
        c.rect(16, y, 2, 5, C(0xFFF0B0)); c.rect(16, y + 6, 2, 2, C(0xFFF0B0))
    }
    guard let e = egg else { return }
    let shell: [Character: Px] = ["P": C(0xF4A6C8), "W": C(0xFFFFFF), "Y": C(0xFFE066), "B": C(0x6AB4F0), "G": C(0x6AD08A)]
    let rows = [".PWP.", "PPPPP", "YBYBY", "BYBYB", "PPPPP", "GPGPG", ".PPP."]
    let ex = Int(e.x.rounded()), ey = Int(e.y.rounded())
    for (r, row) in rows.enumerated() where ey + r <= 43 {
        for (k, ch) in row.enumerated() { if let col = shell[ch] { c.px(ex + k, ey + r, col) } }
    }
    // Sparkles round it, held up high.
    if s > 0.56 && s < 0.86 {
        for (i, d) in [(-3, 1), (7, -1), (-2, 6), (7, 5), (2, -3)].enumerated() {
            let a = max(0, sin(s * 40 + Double(i) * 1.9))
            guard a > 0.2 else { continue }
            let x = ex + d.0, y = ey + d.1
            c.px(x, y, C(0xFFFFFF, a))
            for (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1)] { c.px(x + dx, y + dy, C(0xFFF0B0, 0.6 * a)) }
        }
    }
}

/// A glaive gripped at the hand: a butt-cap, a dark wooden shaft with gold rings, a gold collar with a red tassel, and
/// a long single-edged blade curving up to its point.
private func drawGlaive(_ c: PixelCanvas, angle: Double) {
    prop(c, at: Sprite.hand, angle: angle) { s in
        let wood = C(0x8A6234), gold = C(0xE8C050), steel = C(0xD0D4DC), steelLight = C(0xF0F4F8), edge = C(0x8A909C)
        let tassel = C(0xC82A2A)
        s.rect(12, 20, 16, 1, wood); s.px(11, 20, gold); s.px(15, 20, gold); s.px(24, 20, gold)
        s.rect(28, 19, 2, 3, gold)
        s.px(28, 22, tassel); s.px(29, 23, tassel); s.px(28, 23, tassel)
        s.rect(30, 19, 7, 2, steel); s.rect(30, 19, 7, 1, steelLight); s.rect(30, 21, 6, 1, edge)
        s.rect(37, 18, 2, 2, steel); s.px(37, 20, edge); s.px(39, 17, steel)
    }
}

// MARK: - The Master branch of Lake-town

/// The Master of Lake-town, round and stout: a bald orange dome with a few greasy strands combed over it from the
/// side, tufts over the ears, small smug half-shut eyes, rosy cheeks and a double chin. A purple coat trimmed with
/// cream fur at the collar, down the open front and round the hem, a wine-red waistcoat straining over the big belly
/// that bulges out of it, a heavy gold chain of office with blue stones and a ruby medallion, and short legs. A gold
/// goblet of wine in his hand. He doesn't fight: he hides behind others. Signature: counting his cut: a pile of gold
/// coins in his back hand, a coin flipped up off it and caught on top, one after another, his eyes gleaming gold
/// (…0.46); then a long greedy swig, the goblet tipped up to his lips and his eyes shut in bliss (…0.9), and the
/// coins pocketed.
private func drawMasterOfLaketown(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x6A2A7E), coatShade = C(0x4A1A5C), coatLight = C(0x8A44A2)
    let fur = C(0xE6DAC0), furShade = C(0xB8AA8C), speck = C(0x2A2420)
    let vest = C(0x8A2A3A), vestShade = C(0x641A28)
    let gold = C(0xE8C04A), goldDark = C(0xA8822A), ruby = C(0xD82A3A), sapphire = C(0x3A6AE0)
    let grease = C(0x3A2C1C), shine = C(0x7A6A4C), blush = C(0xE88A70)
    drawLegs(c, Look(leg: C(0x3A2A3A)), step: p.step)
    drawBoots(c, p.step, C(0x2A1A12), rows: 2)
    c.oy += p.breathe
    // The head, a rounded dome over Clawd's face.
    for (y, l, r) in [(24, 21, 34), (25, 19, 36)] + (26...32).map({ ($0, 18, 37) }) {
        c.rect(l, y, r - l + 1, 1, clawdOrange); c.px(r, y, clawdShade)
    }
    // The coat over the round belly, bulging front and back.
    let spans: [(l: Int, r: Int)] = [(17, 38), (16, 39), (15, 40), (15, 40), (15, 40), (16, 39), (16, 39), (17, 38)]
    for (k, s) in spans.enumerated() where 33 + k + c.oy <= 43 {
        let y = 33 + k
        c.rect(s.l, y, s.r - s.l + 1, 1, y == 40 ? fur : coat)
        if y < 40 { c.px(s.l, y, coatLight); c.px(s.r, y, coatShade) }
    }
    // The waistcoat over the belly, its buttons straining, between the fur edges of the coat.
    for (k, s) in [(24, 33), (23, 35), (23, 36), (23, 36), (24, 35), (25, 34)].enumerated() where 34 + k + c.oy <= 43 {
        c.rect(s.0, 34 + k, s.1 - s.0 + 1, 1, vest); c.px(s.1, 34 + k, vestShade)
        c.px(s.0 - 1, 34 + k, fur); c.px(s.1 + 1, 34 + k, furShade)
    }
    for y in [35, 37, 39] where y + c.oy <= 43 { c.px(30, y, goldDark) }
    // The fur collar across the shoulders, specked.
    c.pattern(16, 33, ["FFFfFFsFFFfFFFFfFFsFFfFF"], ["F": fur, "f": furShade, "s": speck])
    // The back arm in a fur-cuffed sleeve.
    c.rect(12, 33, 3, 3, coat); c.rect(12, 33, 1, 3, fur)
    // The chain of office and its medallion.
    for (x, y) in [(20, 34), (21, 35), (23, 35), (24, 36), (25, 37), (35, 34), (34, 35), (32, 35), (31, 36), (30, 37)] {
        c.px(x, y, gold)
    }
    c.px(22, 35, sapphire); c.px(33, 35, sapphire)
    c.rect(26, 37, 4, 3, gold); c.rect(27, 38, 2, 1, ruby); c.rect(26, 39, 4, 1, goldDark)
    // The face: the double chin, smug half-shut eyes, rosy cheeks.
    c.rect(23, 32, 10, 1, clawdShade)
    c.rect(22, 30, 2, 2, ink); c.rect(22, 29, 2, 1, clawdShade)
    c.rect(32, 30, 2, 2, ink); c.rect(32, 29, 2, 1, clawdShade)
    c.rect(20, 31, 2, 1, blush); c.rect(34, 31, 2, 1, blush)
    let sig = p.signature
    if let s = sig, s > 0.04, s < 0.5 {
        // Eyes gleaming gold at the coins.
        for x in [22, 32] { c.rect(x, 30, 2, 2, gold); c.px(x, 30, C(0xFFF8D0)) }
    } else if let s = sig, s > 0.58, s < 0.84 {
        // Eyes shut in bliss, cheeks full of wine.
        c.rect(22, 30, 2, 1, clawdShade); c.rect(32, 30, 2, 1, clawdShade)
        c.rect(19, 30, 3, 2, blush); c.rect(34, 30, 3, 2, blush)
    }
    // The comb-over, and the tufts over his ears.
    c.pattern(17, 23, [
        "......gsggggg.........",
        "...gggg.gg..g.g.......",
        ".gg..g...g...g........",
        "gg...................g",
        "gg..................gg",
        "g...................gg",
        "g....................g",
    ], ["g": grease, "s": shine])
    if let s = sig { drawMasterCoins(c, s, gold: gold, goldDark: goldDark) }
    // The goblet, in the hand of his front arm.
    if let s = sig, masterSwig(s) > 0 {
        drawMasterGoblet(c, masterSwig(s), coat: coat, fur: fur, gold: gold, goldDark: goldDark, ruby: ruby)
        return
    }
    c.rect(41, 33, 2, 3, coat); c.rect(43, 33, 1, 3, fur)
    c.pattern(43, 28, ["GRRRG", "GgGGG", ".GGG.", "..G..", "..G.."], ["G": gold, "g": C(0xFFE89A), "R": C(0x6A0A1A)])
    c.rect(44, 33, 3, 3, clawdOrange); c.px(44, 35, clawdShade); c.px(46, 34, ruby)   // a ring on his finger
    c.rect(44, 36, 3, 1, goldDark)
}

/// How far the Master's goblet is raised to his lips `s` through the signature (0 in his hand, 1 tipped up).
private func masterSwig(_ s: Double) -> Double {
    s < 0.5 ? 0 : s < 0.6 ? smooth((s - 0.5) / 0.1) : s < 0.8 ? 1 : 1 - smooth((s - 0.8) / 0.1)
}

/// The Master's gold, `s` through the signature: a pile of coins in his back hand, a coin flipped up off it and
/// caught on top, one after another (…0.46), his eyes gleaming gold as he counts; the pile kept while he drinks, and
/// pocketed, a coin at a time, at the end.
private func drawMasterCoins(_ c: PixelCanvas, _ s: Double, gold: Px, goldDark: Px) {
    guard s > 0.04 else { return }
    let goldLight = C(0xFFE89A), glint = C(0xFFF8D0)
    let lands = [0.16, 0.26, 0.36, 0.46]
    var n = 1 + lands.filter { s >= $0 }.count
    if s > 0.9 { n = max(0, n - Int((s - 0.9) / 0.016)) }   // all five pocketed by 0.98, the palm with them
    guard n > 0 else { return }
    c.rect(11, 33, 4, 1, clawdOrange); c.px(14, 33, clawdShade)              // the palm
    for i in 0..<n {
        c.rect(11, 32 - i, 4, 1, i == n - 1 ? goldLight : gold); c.px(14, 32 - i, goldDark)
    }
    // The coin in the air, spinning, and a glint as it lands.
    if let land = lands.first(where: { s < $0 && s >= $0 - 0.09 }) {
        let k = (land - s) / 0.09, y = 32 - n - Int((9 * sin(k * .pi)).rounded())
        if Int(k * 9) % 2 == 0 { c.rect(11, y, 3, 1, gold); c.px(12, y - 1, goldLight); c.px(12, y + 1, goldDark) }
        else { c.px(12, y, goldLight); c.px(12, y - 1, gold); c.px(12, y + 1, goldDark) }
    }
    if let land = lands.last(where: { s >= $0 && s < $0 + 0.04 }) {
        let a = 1 - (s - land) / 0.04, y = 32 - n
        for (dx, dy) in [(-1, 0), (1, 0), (0, -1), (-2, 0), (2, 0)] { c.px(15 + dx, y + dy, glint.alpha(a)) }
    }
}

/// The goblet in his hand, raised `u` of the way to his lips and tipped up: the hand at (`hx`, `hy`) and the sleeve
/// up to it.
private func drawMasterGoblet(_ c: PixelCanvas, _ u: Double, coat: Px, fur: Px, gold: Px, goldDark: Px, ruby: Px) {
    let hx = Int((44 - 3 * u).rounded()), hy = Int((33 - 5 * u).rounded())
    line(c, 41.5, 34.5, Double(hx) - 0.5, Double(hy) + 1.5, coat, 1.2)
    c.rect(hx - 1, hy, 1, 3, fur)
    prop(c, at: (Double(hx) + 1.5, Double(hy) + 0.5), angle: -58 * u) { s in
        s.pattern(18, 15, ["GRRRG", "GgGGG", ".GGG.", "..G..", "..G.."], ["G": gold, "g": C(0xFFE89A), "R": C(0x6A0A1A)])
        s.rect(19, 23, 3, 1, goldDark)
    }
    c.rect(hx, hy, 3, 3, clawdOrange); c.px(hx, hy + 2, clawdShade); c.px(hx + 2, hy + 1, ruby)
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

/// Draws `art` on a scratch canvas (same offsets as `c`) and copies it onto `c` leaning forward `degrees`: each row
/// above `pivot` slid forward by how far above it it is (a shear, so the rows stay straight), the whole of it a pixel
/// lower for every 8 degrees, and nothing pushed down below the floor.
private func leaning(_ c: PixelCanvas, _ degrees: Double, about pivot: (x: Double, y: Double),
                     _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let top = pivot.y + Double(c.oy + c.baseY), floorRow = 43 + c.oy + c.baseY
    let k = tan(degrees * .pi / 180), drop = Int((degrees / 8).rounded())
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    defer { c.ox = ox; c.oy = oy; c.baseY = by }
    for y in 0..<s.h where y + drop <= floorRow {
        let dx = Int((max(0, top - Double(y)) * k).rounded())
        for x in 0..<s.w {
            let i = (y * s.w + x) * 4
            if s.buf[i + 3] > 0 { c.px(x + dx, y + drop, unpremultiplied(s, i)) }
        }
    }
}

/// An easing curve from 0 to 1, slow at both ends.
private func smooth(_ x: Double) -> Double {
    let x = min(1, max(0, x))
    return x * x * (3 - 2 * x)
}

/// A prop drawn pointing right from pixel (20, 20) of a scratch canvas, turned to `angle` degrees (0 forward, -90 up)
/// and placed with that point on `at`.
private func prop(_ c: PixelCanvas, at: (x: Double, y: Double), angle: Double, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(41, 41)
    art(s)
    let r = s.rotated(angle, about: (20.5, 20.5), into: 41, 41, at: (20.5, 20.5))
    let x0 = Int(floor(at.x - 20.5)), y0 = Int(floor(at.y - 20.5))
    for y in 0..<r.h {
        for x in 0..<r.w {
            let i = (y * r.w + x) * 4
            guard r.buf[i + 3] > 0 else { continue }
            c.px(x0 + x, y0 + y, unpremultiplied(r, i))
        }
    }
}

private func unpremultiplied(_ s: PixelCanvas, _ i: Int) -> Px {
    let a = s.buf[i + 3], m = 255 / Double(a)
    return Px(r: UInt8(min(255, Double(s.buf[i]) * m)), g: UInt8(min(255, Double(s.buf[i + 1]) * m)),
              b: UInt8(min(255, Double(s.buf[i + 2]) * m)), a: a)
}
