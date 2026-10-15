import Foundation

// Villains: the Men who took the Dark Lord's side, or just their own: the mad Steward, the pirate of Umbar, the
// warriors of Harad and the East, the greedy Master of Lake-town, and the King of the Dead, who is no Man any more.
// Clawd in costume, every one of them: the robes, coats, masks and helmets drawn over (and around) the blocky body.
// The corsair's face is a darker brown, Harad's and the Easterling's are hidden behind gold, and the King of the
// Dead is a pale green ghost, see-through and glowing, a skull where the face should be, a head taller for his crown.
// The Master is round: his belly bulges out of his coat (`bulk` says how far).

let ringsVillains7: [LOTRVillain: Persona] = [
    .denethor: Persona(name: "Denethrow", weapon: .blaster, shot: .fire, muzzle: (44, 22), headTop: 20,
                       callout: "Abandon your try blocks! Throw for your lives!", draw: drawDenethor),
    .kingOfTheDead: Persona(name: "The King of the Dead Code", weapon: .saber, canSit: false, headTop: 16,
                            callout: "The way is shut. It was written by dead code, and dead code keeps it.",
                            draw: drawKingOfTheDead),
    .corsair: Persona(name: "Cursor of Umbar", weapon: .saber, headTop: 21, callout: "Point and click, lads! Board her!",
                      draw: drawCorsair),
    .haradrim: Persona(name: "Harad-RAM", weapon: .blaster, shot: .arrow, muzzle: (46, 34), handGun: false, headTop: 20,
                       callout: "Charge! RAM them with all sixty-four gigs!", draw: drawHaradrim),
    .easterling: Persona(name: "The Eastereggling", weapon: .saber, armoured: true, headTop: 12,
                         callout: "Nobody ever looks behind the credits in the East.", draw: drawEasterling),
    .masterOfLaketown: Persona(name: "The Master branch of Lake-town", bulk: 3, headTop: 23,
                               callout: "Nothing merges into master without my cut.", draw: drawMasterOfLaketown),
]

// MARK: - Denethrow

/// Denethrow, the mad Steward of Gondor: a heavy black robe to the ankles with a silver collar and hem, the White Tree
/// of Gondor in white on his chest under three silver stars, a black cloak edged in silver behind him, long lank grey
/// hair to the shoulders and no beard. His face is gaunt and haunted: brows drawn up in the middle, shadows under the
/// eyes and hollow cheeks. A burning torch in his fist, held up, its flame flickering; he throws fire from it.
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
    // The torch, held up in his fist, the flame on top.
    c.oy += p.gunY
    drawTorch(c, t: p.lt)
    c.rect(38, 33, 3, 3, robe); c.rect(40, 33, 1, 3, silverDark)
    c.rect(41, 33, 3, 3, clawdOrange); c.px(41, 35, clawdShade)
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
/// sword is a ghost too: a long pale blade glowing green, swung with a green smear behind a fast stroke.
private func drawKingOfTheDead(_ c: PixelCanvas, _ p: Pose) {
    ghostLayer(c, alpha: 0.8, glow: C(0x8AFFA8, 0.24)) { drawKingOfTheDeadBody($0, p) }
    // Wisps rising off him, fading as they go.
    let oy = c.oy
    c.oy += p.breathe
    for (k, x0) in [16, 21, 34, 39].enumerated() {
        let f = frac(p.lt * 0.45 + Double(k) * 0.27)
        let x = x0 + Int((sin(f * 6 + Double(k)) * 1.5).rounded()), y = 30 - Int(f * 18)
        c.px(x, y, C(0xC8FFD4, 0.6 * (1 - f))); c.px(x, y + 1, C(0x8AFFA8, 0.35 * (1 - f)))
    }
    c.oy = oy
}

/// Everything of the King that is see-through, drawn opaque for `ghostLayer` to fade.
private func drawKingOfTheDeadBody(_ c: PixelCanvas, _ p: Pose) {
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
/// held low, swung with a smear behind a fast stroke.
private func drawCorsair(_ c: PixelCanvas, _ p: Pose) {
    let skin = C(0x8A4A2C), skinShade = C(0x6A3420)
    let coat = C(0x1E1A20), coatShade = C(0x0E0C10), coatLight = C(0x36303C)
    let red = C(0xB82A26), redDark = C(0x7E1A18), redLight = C(0xE05A4A)
    let gold = C(0xE8B840), shirt = C(0xE0D4B4), beard = C(0x1A1210), iron = C(0xA8AEB8)
    drawLegs(c, Look(leg: C(0x3A2C28)), step: p.step)
    drawBoots(c, p.step, C(0x141010), rows: 4)
    c.oy += p.breathe
    drawBody(c, Look(body: skin, shade: skinShade, arm: coat))
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
    // The cutlass, held low or swung.
    let angle = p.melee ?? (seatedPose ? 8 : 35)
    for (i, a) in (p.melee == nil ? [] : p.trail).enumerated() {
        let u = unit(a)
        c.glowLine(Sprite.hand.x + u.x * 4, Sprite.hand.y + u.y * 4, Sprite.hand.x + u.x * 14, Sprite.hand.y + u.y * 14,
                   core: C(0xE8EEF4), glow: C(0xA8B4C0), coreR: 0.8, glowR: 1.9, strength: 0.32 / Double(i + 1))
    }
    drawCutlass(c, angle: angle)
    c.rect(38, 33, 2, 3, coat); c.rect(40, 33, 1, 3, red); c.rect(41, 33, 2, 3, skin); c.px(41, 35, skinShade)
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
/// arrow and drawing it back before each shot.
private func drawHaradrim(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0xA82A26), robeShade = C(0x7A1C1A), robeLight = C(0xC8443A)
    let turban = C(0x7E1A1C), turbanShade = C(0x5A1214)
    let gold = C(0xE0B040), goldDark = C(0xA87A22), goldLight = C(0xFFE07A)
    drawLegs(c, Look(leg: robeShade), step: p.step)
    drawBoots(c, p.step, C(0x4A3020), rows: 1)
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
/// and swings with a smear behind a fast stroke.
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
/// goblet of wine in his hand. He doesn't fight: he hides behind others.
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
    // The goblet, in the hand of his front arm.
    c.rect(41, 33, 2, 3, coat); c.rect(43, 33, 1, 3, fur)
    c.pattern(43, 28, ["GRRRG", "GgGGG", ".GGG.", "..G..", "..G.."], ["G": gold, "g": C(0xFFE89A), "R": C(0x6A0A1A)])
    c.rect(44, 33, 3, 3, clawdOrange); c.px(44, 35, clawdShade); c.px(46, 34, ruby)   // a ring on his finger
    c.rect(44, 36, 3, 1, goldDark)
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
