import Foundation

// Heroes: the brown wizard and the elf lords of the woods. Every one of them is Clawd in costume, told apart from
// the elves already in the lineup (Leggolas' green, Gladriel's white gown, Elcron's burgundy and dark hair, Arwen's
// blue-grey) by a colour and a silhouette of their own: Radagast's floppy brown hat, bird's nest and crook staff;
// Glorfind's gold hair, white-and-gold plate and glow; Haldirectory's silver-grey cloak and pale bow, a head taller
// than the rest (his legs are drawn longer, so his `headTop`, `muzzle` sit higher); Celeborne-again's silver-white
// hair, leafy circlet and slate mantle, his sword sheathed until he fights; Thrandual's crown of autumn branches,
// crimson robe and twin curved blades. The face is Clawd's own orange, and the eyes stay ink.

let ringsHeroes6: [LOTRHero: Persona] = [
    .radagast: Persona(name: "Radagast the Brownfield", weapon: .saber, pivot: radagastHand, headTop: 15,
                       callout: "The Greenwood is sick. It's gone brownfield.", draw: drawRadagast),
    .glorfindel: Persona(name: "Glorfind", weapon: .saber, armoured: true, headTop: 20,
                         callout: "find / -name Frodough: one match, very small.", draw: drawGlorfindel),
    .haldir: Persona(name: "Haldirectory", weapon: .blaster, shot: .arrow, muzzle: (46, 32), handGun: false, headTop: 18,
                     callout: "None may enter the Golden Wood without an absolute path.", draw: drawHaldir),
    .celeborn: Persona(name: "Celeborne-again", weapon: .saber, headTop: 21,
                       callout: "Three Ages in this wood, and born again in every shell.", draw: drawCeleborn),
    .thranduil: Persona(name: "Thrandual", weapon: .saber, headTop: 12, callout: "I do not duel. I dual-wield.",
                        draw: drawThranduil),
]

// MARK: - Radagast the Brownfield

/// The curl at the head of his staff, held upright.
private let radagastStaffHead: (x: Double, y: Double) = (43.5, 13.5)

/// The front fist that holds the staff, and swings it in a fight.
private let radagastHand: (x: Double, y: Double) = (43.5, 34.5)

/// The soft earthy green light in the curl of his staff.
private let radagastGlow = StaffGlow(core: C(0xE4F0B0), glow: C(0x7A9A3A))

/// Radagast the Brownfield, the scruffy brown wizard: a patched, muddy brown robe to the ankles with a ragged hem and a
/// rope belt; a battered, floppy ochre hat, its low crown dented and its tip flopped over the back, the wide brim
/// drooping; straggly grey-brown hair and bushy brows, a straggly beard streaked white with bird droppings, and a bird's
/// nest stuck in his hair behind his ear, a little blue bird sitting in it. His gnarled staff, its head a curl of wood
/// with a leaf on it and a soft earthy green light in it, stands in his front hand, always; in a fight he swings it
/// like a sword.
private func drawRadagast(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0x6E5234), robeShade = C(0x4E3A22), robeLight = C(0x8A6C46)
    let patch = C(0x5E6A34), patchDark = C(0x46502A), rope = C(0xA8945C)
    let hair = C(0x9A8E78), hairShade = C(0x766A56)
    let beard = C(0xA89C84), beardShade = C(0x857A64), beardEdge = C(0x6E6452), dropping = C(0xF6F4EC)
    let hat = C(0x8E6A3C), hatShade = C(0x6A4C28), hatLight = C(0xA8844E)
    let up = p.armRaise
    drawLegs(c, Look(leg: robeShade), step: p.step)
    drawBoots(c, p.step, C(0x3A2A1A), rows: 1)
    c.oy += p.breathe
    drawBody(c, Look(arm: robe))
    // The robe, the shoulders to the ankles, flaring a little, its hem ragged; a patch or two and a rope belt.
    c.rect(18, 32, 20, 6, robe)
    c.rect(37, 32, 1, 6, robeShade)
    for y in 38...41 where y + c.oy <= 43 {
        let k = y - 38, l = 17 - (k + 1) / 2, r = 38 + (k + 1) / 2
        for x in l...r where !(y == 41 && [16, 20, 21, 27, 33, 34, 39].contains(x)) { c.px(x, y, robe) }
        c.px(l, y, robeLight); c.px(r, y, robeShade)
        c.px(23, y, robeShade); if y > 38 { c.px(31, y, robeShade) }
    }
    if 39 + c.oy <= 43 { c.rect(29, 38, 3, 2, patch); c.px(31, 39, patchDark) }
    c.rect(19, 33, 3, 2, patch); c.px(19, 34, patchDark)
    c.rect(18, 36, 20, 1, rope); c.px(26, 37, rope); c.px(26, 38, rope); c.px(27, 39, rope)   // the rope belt, its knot
    c.rect(14, 33, 4, 4, robe); c.px(14, 36, robeShade); c.px(16, 37, robe); c.px(14, 33, robeLight)   // the back sleeve
    // Straggly hair falling from under the brim, uneven at the ends, and bushy brows.
    c.pattern(15, 26, ["HHHH", "HhHH", "HHhH", "hHHH", "H.HH", "HhH.", "H..h", ".H.."], ["H": hair, "h": hairShade])
    c.pattern(37, 26, ["HHHH", "HhHH", "HHHh", "HHh.", "hH.H", ".H..", "..H."], ["H": hair, "h": hairShade])
    c.rect(21, 28, 4, 1, beard); c.rect(31, 28, 4, 1, beard); c.px(24, 27, beard); c.px(31, 27, beard)
    // The straggly beard, streaked white where the birds have been (folded on his lap when he sits).
    let beardRows: [String] = [
        ".HHHHHHHHHHHHHH.",
        "HHhHHHHHHHHHhHHH",
        "HhHHHhHHWHhHHHhH",
        ".HHhHHHHWHHHHWH.",
        ".HHHWhHHHHhHHWH.",
        "..HhWHHHHHHHHH..",
        "..H.HHhHHHHH.H..",
        "....HH.HbH.H....",
        ".....b..H.......",
    ]
    c.pattern(20, 32, Array(beardRows.prefix(max(0, 43 - c.oy - 32 + 1))),
              ["H": beard, "h": beardShade, "b": beardEdge, "W": dropping])
    c.rect(23, 32, 10, 1, beardShade)                                         // the moustache's edge
    // The bird's nest in his hair, behind his ear, and the little blue bird sitting in it.
    c.pattern(9, 26, [
        ".yBB....",
        "..BBb...",
        "NnNBBNn.",
        "NNnNNNNn",
        ".NnNnNN.",
        "..n..n..",
    ], ["N": C(0xB89A5A), "n": C(0x7A6036), "B": C(0x4A7AC8), "b": C(0x2E5A9E), "y": C(0xE8C040)])
    c.px(11, 26, ink)
    // The hat: a low battered crown, dented, its tip flopped over the back; a band and a wide, drooping brim.
    let crown: [(y: Int, l: Int, r: Int)] = [
        (16, 24, 29), (17, 22, 31), (18, 21, 32), (19, 21, 33), (20, 20, 33), (21, 20, 34), (22, 19, 35),
    ]
    for row in crown {
        c.rect(row.l, row.y, row.r - row.l + 1, 1, hat)
        c.px(row.l, row.y, hatLight); c.px(row.r, row.y, hatShade)
    }
    line(c, 24, 16.5, 19.5, 16.5, hat, 0.6); line(c, 19.5, 16.5, 17, 19.5, hat, 0.6)   // the flopped tip
    c.px(16, 20, hatShade); c.px(17, 20, hatShade)
    c.px(27, 17, hatShade); c.px(28, 18, hatShade); c.px(28, 19, hatShade)  // the dent
    c.rect(30, 19, 2, 2, patch)                                               // a patch
    c.rect(19, 23, 17, 1, C(0x4A3A22))                                        // the band
    c.rect(14, 24, 28, 1, hat); c.px(14, 24, hatLight)
    c.rect(15, 25, 26, 1, hatShade)                                           // the brim's underside
    c.px(13, 25, hat); c.px(42, 25, hat); c.px(43, 26, hatShade)             // drooping at the ends
    c.px(33, 23, dropping); c.px(34, 24, dropping); c.px(21, 21, dropping)   // and the birds have been here too
    // The gnarled staff, planted in his front hand, its curl glowing a soft earthy green; in a fight he swings it like
    // a sword. The sleeve behind it and the fist round it.
    c.rect(38, 33 - up, 4, 3 + up, robe); c.rect(38, 35, 4, 1, robeShade)
    if let angle = p.walking || p.seated ? nil : p.melee {
        drawSwungStaff(c, hand: radagastHand, head: radagastStaffHead, angle: angle, trail: p.trail, glow: radagastGlow,
                       t: p.t) { drawRadagastStaff($0, up: 0) }
    } else {
        let head = (x: radagastStaffHead.x, y: radagastStaffHead.y - Double(up))
        drawStaffGlow(c, at: head, radagastGlow, bright: false, t: p.t)
        drawRadagastStaff(c, up: up)
        drawStaffGlow(c, at: head, radagastGlow, bright: false, t: p.t, front: true)
    }
    c.rect(42, 33 - up, 3, 3, clawdOrange); c.px(42, 35 - up, clawdShade)
}

/// Radagast's gnarled staff, upright in his front hand and lifted `up` pixels: its head a curl of wood with a leaf
/// sprouting from it, moss here and there down the shaft.
private func drawRadagastStaff(_ c: PixelCanvas, up: Int) {
    let wood = C(0x5A3E22), woodDark = C(0x3E2A16), woodLight = C(0x7A5A36), moss = C(0x6A8A3A)
    let top = 12 - up, bottom = 43 - c.oy - up
    c.pattern(41, top, [".WWW.", "W...W", "W..W.", ".DW..", "..W.."], ["W": wood, "D": woodDark])
    c.px(42, top, woodLight); c.px(45, top + 3, moss); c.px(46, top + 2, moss)   // a leaf sprouting from the curl
    c.rect(43, top + 5, 1, max(0, bottom - top - 4), wood)
    c.px(43, top + 9, woodDark); c.px(42, top + 11, wood); c.px(43, top + 14, moss); c.px(43, top + 17, woodLight)
    c.px(44, top + 24, woodDark); c.px(43, top + 27, moss)
}

// MARK: - Glorfind

/// Glorfind, the elf lord of the House of the Golden Flower, shining: motes of gold light twinkle round him. Gold hair
/// to the shoulders and swept back off them in a mass behind, pointed ears; white plate armour trimmed in gold, a gold
/// flower on the breastplate, gold-edged pauldrons and white greaves, a cream cape. His long straight sword has a gold
/// hilt and a faint glow on the blade; at rest he holds it low, point forward; swung, it smears behind a fast stroke.
private func drawGlorfindel(_ c: PixelCanvas, _ p: Pose) {
    let plate = C(0xF0F2F6), plateShade = C(0xC4CAD4), plateLight = C(0xFFFFFF)
    let gold = C(0xE8B830), goldDark = C(0xB08420), goldLight = C(0xFFE07A)
    let hair = C(0xF2BE2E), hairShade = C(0xC89418), hairLight = C(0xFFE07E)
    // The light about him: motes of gold twinkling round his head and shoulders, each in its own time.
    let motes: [(x: Int, y: Int)] = [(12, 19), (41, 21), (9, 30), (44, 27), (25, 15), (35, 16)]
    for (i, m) in motes.enumerated() {
        let k = frac(p.lt * 0.7 + Double(i) * 0.37)
        guard k < 0.5 else { continue }
        let col = k < 0.1 || k > 0.4 ? C(0xE8B830) : C(0xFFF2B0)
        c.px(m.x, m.y, col)
        if k >= 0.15 && k <= 0.35 {
            for (dx, dy) in [(1, 0), (-1, 0), (0, 1), (0, -1)] { c.px(m.x + dx, m.y + dy, C(0xFFD860, 0.8)) }
        }
    }
    drawBackCape(c, t: p.t, speed: p.capeSpeed, color: C(0xF4EACA), edge: C(0xD4C08A), hem: 41)
    drawLegs(c, Look(leg: plateShade), step: p.step)
    drawBoots(c, p.step, plate, rows: 3)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let top = (p.step >= 0 && i % 2 == p.step ? 42 : 43) - 3
            c.rect(lx, top, 2, 1, gold)                                       // the greaves' gold knees
        }
    }
    c.oy += p.breathe
    // His hair, swept back off his shoulders behind him.
    c.pattern(10, 22, [
        "...HHHH",
        ".HHHHhH",
        "HHlHHHH",
        "HHHHhHH",
        ".HhHHHH",
        "HHHHHlH",
        ".HHhHHH",
        "..HHHhH",
        "...HHHH",
        "....HhH",
        ".....HH",
    ], ["H": hair, "h": hairShade, "l": hairLight])
    drawBody(c, Look(arm: plate))
    // The breastplate, gold at the neck and the waist, a gold flower on the chest; plates hanging to mid-thigh.
    c.rect(18, 32, 20, 6, plate)
    c.rect(37, 32, 1, 6, plateShade)
    c.rect(18, 32, 20, 1, gold)
    c.rect(21, 33, 1, 3, plateLight)
    c.pattern(26, 33, [".G.", "GgG", ".G."], ["G": gold, "g": goldLight])
    c.rect(18, 36, 20, 1, goldDark); c.rect(26, 36, 3, 1, goldLight)
    for y in 38...39 where y + c.oy <= 43 {
        for x in 18...37 { c.px(x, y, (x - 18) % 5 == 4 ? goldDark : x == 37 ? plateShade : plate) }
    }
    if 39 + c.oy <= 43 { c.rect(18, 39, 20, 1, gold) }
    // The pauldrons, gold-edged, over his shoulders.
    c.pattern(13, 31, [".GGGG.", "GPPPPG", "GPPPPg", ".gPPg."], ["G": gold, "g": goldDark, "P": plate])
    // Gold hair over the head, to the shoulders.
    c.pattern(16, 19, [
        "........HHHHHHHH........",
        ".....HHHHHlHHHHHHHH.....",
        "...HHHHlHHHHHHHHlHHHH...",
        "..HHHHHHHHHHHHHHHHHHHH..",
        ".HHlHHHHHHHhHHHHHHHlHHH.",
        ".HHHHHHHhHHHHHHHhHHHHHH.",
        "HHHHHhh..........hhHHHHH",
        "HHHh..............hHHHH.",
        "HHh..................hH.",
        "HHH..................HH.",
        "HHh..................hH.",
        "HHH..................HH.",
        ".Hh...................H.",
        "..H.....................",
    ], ["H": hair, "h": hairShade, "l": hairLight])
    c.px(15, 28, clawdOrange); c.px(40, 28, clawdOrange)                      // the pointed ears
    let angle = p.melee ?? (seatedPose ? 5 : 20)
    drawGlorfindSword(c, angle: angle, trail: p.melee == nil ? [] : p.trail)
    c.pattern(36, 31, [".GGG.", "GPPPG", "GPPPg"], ["G": gold, "g": goldDark, "P": plate])   // the front pauldron
    c.rect(38, 34, 2, 2, plate); c.rect(40, 33, 2, 3, clawdOrange); c.px(40, 35, clawdShade)
}

/// Glorfind's sword in his fist at `angle`: a gold pommel, a white grip and a wide gold crossguard, a long straight
/// bright blade with a darker edge and a faint golden glow along it; a pale gold smear along `trail` behind a fast
/// stroke.
private func drawGlorfindSword(_ c: PixelCanvas, angle: Double, trail: [Double]) {
    let hand = Sprite.hand, steel = C(0xF2F6FC), edge = C(0xA8B2C0), gold = C(0xE8B830)
    for (i, a) in trail.enumerated() {
        let u = unit(a)
        c.glowLine(hand.x + u.x * 4, hand.y + u.y * 4, hand.x + u.x * 19, hand.y + u.y * 19, core: C(0xFFF6D8),
                   glow: C(0xE8C870), coreR: 0.5, glowR: 1.6, strength: 0.34 / Double(i + 1))
    }
    let u = unit(angle), n = (x: -u.y, y: u.x)
    c.glowLine(hand.x + u.x * 3, hand.y + u.y * 3, hand.x + u.x * 19, hand.y + u.y * 19, core: clear,
               glow: C(0xFFE07A), coreR: 0, glowR: 1.8, strength: 0.28)
    line(c, hand.x - u.x * 2.5, hand.y - u.y * 2.5, hand.x + u.x * 1.5, hand.y + u.y * 1.5, C(0xE0E2E8), 0.6)   // the grip
    c.px(Int((hand.x - u.x * 3).rounded(.down)), Int((hand.y - u.y * 3).rounded(.down)), gold)                 // the pommel
    line(c, hand.x + u.x * 3, hand.y + u.y * 3, hand.x + u.x * 19, hand.y + u.y * 19, steel, 0.75)
    line(c, hand.x + u.x * 3 + n.x * 0.6, hand.y + u.y * 3 + n.y * 0.6, hand.x + u.x * 18 + n.x * 0.6,
         hand.y + u.y * 18 + n.y * 0.6, edge, 0.3)
    let g = (x: hand.x + u.x * 2.5, y: hand.y + u.y * 2.5)
    line(c, g.x - n.x * 3, g.y - n.y * 3, g.x + n.x * 3, g.y + n.y * 3, gold, 0.6)                              // the crossguard
}

// MARK: - Haldirectory

/// Haldirectory, the march-warden of Lothlórien: a head taller than the other elves (long legs, everything else 2 px
/// higher) and sterner, his brows drawn down. A silver-grey elven cloak over his shoulders and down his back, covering
/// his back arm, pinned at the throat with a green leaf brooch, over a long dark-green tunic belted in grey, grey-green
/// trousers and soft grey boots; long straight ash-blond hair to below the shoulders; a quiver with white fletchings and
/// a pale Galadhrim longbow, its tips curving forward, held out in front of him. Shooting, he nocks an arrow and draws
/// the string back before each shot, as Leggolas does.
private func drawHaldir(_ c: PixelCanvas, _ p: Pose) {
    let tunic = C(0x2E4A2C), tunicShade = C(0x203820), tunicLight = C(0x3E5E3A)
    let cloak = C(0xA8AEB4), cloakShade = C(0x80868E), cloakLight = C(0xC8CED4)
    let hair = C(0xD8BE78), hairShade = C(0xB09656), brow = C(0x8A7440)
    let lift = seatedPose ? 0 : 2
    // The cloak down his back, to the floor.
    c.oy -= lift
    drawBackCape(c, t: p.t, speed: p.capeSpeed, color: cloak, edge: cloakShade, hem: 43 + lift)
    c.oy += lift
    // Long legs: two rows more than the others'.
    let trousers = C(0x4A5244), boot = C(0x6E7068)
    if seatedPose {
        drawLegs(c, Look(leg: trousers), step: p.step)
    } else {
        for (i, lx) in [19, 23, 31, 35].enumerated() {
            let lifted = p.step >= 0 && i % 2 == p.step
            c.rect(lx, 34, 2, lifted ? 9 : 10, trousers)
        }
    }
    drawBoots(c, p.step, boot, rows: 4)
    c.oy += p.breathe - lift
    // The quiver, slung over his back, white fletchings over his shoulder.
    c.pattern(11, 18, [
        "W.W.....",
        "wW.W....",
        ".wWw....",
        "..QQQ...",
        "..QQQq..",
        "...QQQq.",
        "...QQQQ.",
        "....QQQq",
        "....QQQQ",
        ".....QQq",
    ], ["W": C(0xF0F0F0), "w": C(0xB8BCC4), "Q": C(0x5A4A3A), "q": C(0x3E3226)])
    drawBody(c, Look(arm: tunic))
    // The long tunic, to the knee.
    c.rect(18, 32, 20, 6, tunic)
    c.rect(37, 32, 1, 6, tunicShade)
    c.rect(18, 32, 20, 1, tunicLight)
    for y in 38...40 where y + c.oy <= 43 { c.rect(18, y, 20, 1, tunic); c.px(37, y, tunicShade); c.px(28, y, tunicShade) }
    c.rect(18, 36, 20, 1, C(0x5E6268)); c.px(30, 36, C(0xD0D6DE))           // the belt
    // The cloak: over the shoulders, hanging behind the body and over the back arm, the brooch at the throat.
    c.rect(14, 31, 8, 2, cloak); c.rect(14, 31, 8, 1, cloakLight)
    c.rect(14, 33, 5, 6, cloak); c.rect(14, 33, 1, 6, cloakLight); c.rect(18, 33, 1, 6, cloakShade)
    c.rect(19, 33, 3, 8, cloak); c.rect(21, 33, 1, 8, cloakShade)
    c.rect(22, 31, 14, 1, cloak); c.rect(36, 31, 2, 1, cloakShade)
    c.px(23, 32, C(0x6AA04A)); c.px(24, 32, C(0x9AD07A)); c.px(24, 33, C(0xD0D6DE))   // the leaf brooch
    // Long straight hair, parted in the middle, to below the shoulders.
    c.pattern(16, 20, [
        ".......HHHHHHHHHH.......",
        "....HHHHHHHHHHHHHHHH....",
        "..HHHHHHHHHhHHHHHHHHHH..",
        ".HHHHHHHHHhhHHHHHHHHHHH.",
        ".HHhHHHHHHhHHHHHHHHHhHH.",
        "HHHhHHHHHh...hHHHHHHhHHH",
        "HHHh................hHHH",
        "HHh..................hHH",
        "HHh..................hHH",
        "HHh..................hHH",
        "HHh..................hHH",
        "HHh..................hHH",
        ".Hh..................hH.",
        ".Hh..................hH.",
        "..h...................h.",
    ], ["H": hair, "h": hairShade])
    c.px(15, 28, clawdOrange); c.px(40, 28, clawdOrange)                      // the pointed ears
    // Stern brows, drawn down toward the middle.
    c.px(20, 27, brow); c.px(21, 27, brow); c.px(22, 28, brow); c.px(23, 28, brow)
    c.px(32, 28, brow); c.px(33, 28, brow); c.px(34, 27, brow); c.px(35, 27, brow)
    // The longbow held out; an arrow on the string while he aims, drawn back before he shoots.
    var pull = 0, nocked = p.ready
    if let f = p.fire {
        let ph = frac(f.t / p.firePeriod)
        nocked = ph >= 0.45
        if ph > 0.6 { pull = Int(((ph - 0.6) / 0.4 * 3).rounded()) }
    }
    c.oy += p.gunY + (seatedPose ? -3 : 0)
    drawGaladhrimBow(c, pull: pull)
    c.rect(38, 33, 4, 2, tunic)
    c.rect(42, 33, 2, 3, clawdOrange)
    if nocked {
        let tail = 40 - pull
        c.rect(tail, 34, 47 - tail, 1, C(0x6A5A44))
        c.px(47, 34, C(0xC8CCD4)); c.px(48, 34, C(0xE8ECF4))
        c.px(tail, 33, C(0xF0F0F0)); c.px(tail, 35, C(0xF0F0F0))
        c.rect(tail - 1, 34, 2, 2, clawdOrange)                                // the hand on the string
    }
}

/// A pale Galadhrim longbow gripped at (43, 34), wrapped green at the grip, its tips curving forward; the string back at
/// x 40, drawn back `pull` pixels more at the middle.
private func drawGaladhrimBow(_ c: PixelCanvas, pull: Int = 0) {
    let limb = C(0xC8C2AC), limbDark = C(0x9A947E), grip = C(0x3E5A34), string = C(0xE8E8F0)
    for y in 24...44 where y + c.oy <= 43 {
        let d = abs(y - 34)
        let x = d <= 2 ? 44 : d <= 5 ? 43 : d <= 8 ? 42 : d == 9 ? 41 : 42
        c.px(x, y, d <= 1 ? grip : d % 3 == 0 ? limbDark : limb)
    }
    for y in 25...43 where y + c.oy <= 43 {
        let d = Double(abs(y - 34)) / 9
        c.px(40 - Int((Double(pull) * (1 - d)).rounded()), y, string)
    }
}

// MARK: - Celeborne-again

/// Celeborne-again, the Lord of the Golden Wood, calm and stately: a pale silver-grey robe to the ankles, silver
/// embroidery down the front and round the hem, under a slate-grey mantle across his shoulders and down his back,
/// clasped in silver; long straight silver-white hair to the waist, pointed ears, level silver brows, and a silver
/// circlet of three little leaves. His slender sword hangs sheathed at his hip, his hand resting on the hilt; to fight
/// he draws it, and it smears behind a fast stroke.
private func drawCeleborn(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0xB4BCC8), robeShade = C(0x8C96A4), robeLight = C(0xD4DAE2)
    let mantle = C(0x5E6878), mantleShade = C(0x465062), mantleLight = C(0x76808E)
    let silver = C(0xE0E6EE), silverDark = C(0x9AA4B2)
    let hair = C(0xE8ECF2), hairShade = C(0xA8B2C0), hairLight = white
    drawBackCape(c, t: p.t, speed: p.capeSpeed, color: mantle, edge: mantleShade, hem: 43)
    drawLegs(c, Look(leg: robeShade), step: p.step)
    drawBoots(c, p.step, silverDark, rows: 1)
    c.oy += p.breathe
    // His hair down his back, to the waist.
    c.pattern(13, 26, ["HHHH", "HhHH", "HHHH", "HHhH", "hHHH", "HHHH", "HHhH", ".HHH", ".HhH", "..HH"],
              ["H": hair, "h": hairShade])
    drawBody(c, Look(arm: robe))
    // The robe, the shoulders to the ankles, flaring a little, silver down the front and round the hem.
    c.rect(18, 32, 20, 6, robe)
    c.rect(37, 32, 1, 6, robeShade)
    for y in 38...41 where y + c.oy <= 43 {
        let k = y - 38, l = 17 - (k + 1) / 2, r = 38 + (k + 1) / 2
        c.rect(l, y, r - l + 1, 1, y == 41 ? silver : robe)
        c.px(l, y, y == 41 ? silverDark : robeLight); c.px(r, y, y == 41 ? silverDark : robeShade)
    }
    c.rect(28, 33, 1, 8, silver); c.px(27, 35, silverDark); c.px(27, 38, silverDark)
    c.rect(18, 36, 20, 1, silverDark)                                         // the girdle
    // The mantle across his shoulders, clasped at the throat, and over the back arm.
    c.rect(18, 32, 20, 2, mantle); c.rect(18, 32, 20, 1, mantleLight); c.rect(37, 32, 1, 2, mantleShade)
    c.rect(14, 32, 4, 6, mantle); c.px(14, 32, mantleLight); c.rect(14, 37, 4, 1, silverDark)
    c.rect(27, 33, 2, 1, silver); c.px(28, 34, silver)                       // the clasp
    // Long straight silver-white hair, framing the face, past the shoulders.
    c.pattern(16, 20, [
        ".......HHHHHHHHHH.......",
        "....HHHHHHlHHhHHHHHH....",
        "..HHHHHHlHHhhHHHHHHHHH..",
        ".HHhHHHHHHhHHhHHlHHHhHH.",
        ".HHhHHHHHhHHHHhHHHHHhHH.",
        "HHHhHHHHh......hHHHHhHHH",
        "HHHh................hHHH",
        "HHh..................hHH",
        "HHH..................HHH",
        "HHh..................hHH",
        "HHH..................HHH",
        "HHh..................hHH",
        "HHH..................HHH",
        ".Hh..................hH.",
    ], ["H": hair, "h": hairShade, "l": hairLight])
    // The circlet: three little silver leaves over a band across the brow.
    c.rect(17, 24, 22, 1, silverDark)
    c.px(21, 23, silver); c.px(27, 22, silver); c.px(28, 22, silver); c.px(27, 23, silver); c.px(28, 23, silver)
    c.px(34, 23, silver); c.px(27, 24, silver); c.px(28, 24, silver)
    c.rect(21, 28, 3, 1, hairShade); c.rect(32, 28, 3, 1, hairShade)          // level brows
    c.px(15, 28, clawdOrange); c.px(40, 28, clawdOrange)                      // the pointed ears
    guard let a = p.melee else {
        // Sheathed at his hip, the hilt forward, his hand on it.
        line(c, 37.5, 36.5, 26.5, 41.5, silverDark, 0.6)                       // the scabbard
        c.px(27, 41, silver)
        line(c, 38, 36, 41, 34.5, C(0x2E3440), 0.5)                            // the grip
        line(c, 37, 34.5, 38.5, 37.5, silver, 0.4)                             // the guard
        c.px(41, 34, silver)                                                    // the pommel
        c.rect(38, 33, 2, 3, robe); c.rect(40, 33, 2, 2, clawdOrange); c.px(40, 34, clawdShade)
        return
    }
    drawSlenderSword(c, angle: a, trail: p.trail)
    c.rect(38, 33, 2, 3, robe); c.rect(40, 33, 2, 3, clawdOrange); c.px(40, 35, clawdShade)
}

/// Celeborne-again's sword drawn, at `angle`: a dark grip, a silver pommel and a narrow silver guard, a slender straight
/// blade tapering to a fine point; a pale smear along `trail` behind a fast stroke.
private func drawSlenderSword(_ c: PixelCanvas, angle: Double, trail: [Double]) {
    let hand = Sprite.hand, steel = C(0xE4EAF2), silver = C(0xD0D8E2)
    for (i, a) in trail.enumerated() {
        let u = unit(a)
        c.glowLine(hand.x + u.x * 4, hand.y + u.y * 4, hand.x + u.x * 19, hand.y + u.y * 19, core: C(0xEEF4FA),
                   glow: C(0xAAB8C8), coreR: 0.4, glowR: 1.4, strength: 0.3 / Double(i + 1))
    }
    let u = unit(angle), n = (x: -u.y, y: u.x)
    line(c, hand.x - u.x * 2.5, hand.y - u.y * 2.5, hand.x + u.x * 1.5, hand.y + u.y * 1.5, C(0x2E3440), 0.5)   // the grip
    c.px(Int((hand.x - u.x * 3).rounded(.down)), Int((hand.y - u.y * 3).rounded(.down)), silver)               // the pommel
    line(c, hand.x + u.x * 3, hand.y + u.y * 3, hand.x + u.x * 16, hand.y + u.y * 16, steel, 0.55)
    line(c, hand.x + u.x * 16, hand.y + u.y * 16, hand.x + u.x * 19, hand.y + u.y * 19, steel, 0.35)
    let g = (x: hand.x + u.x * 2.5, y: hand.y + u.y * 2.5)
    line(c, g.x - n.x * 2, g.y - n.y * 2, g.x + n.x * 2, g.y + n.y * 2, silver, 0.45)                          // the guard
}

// MARK: - Thrandual

/// Thrandual, the proud elvenking of Mirkwood: a tall crown of bare autumn branches, red berries and a few orange and
/// gold leaves on its twigs, on long straight pale-blond hair to the waist; arched brows. A crimson robe to the ankles
/// worked in silver at the collar, down the front and round the hem, a silver brocade on the chest, and a darker crimson
/// cloak lined in silver down his back. A curved elven blade in each hand: at rest both held low, the front one point
/// forward, the back one point back; fighting, the back one fans out opposite the front one's stroke.
private func drawThranduil(_ c: PixelCanvas, _ p: Pose) {
    let robe = C(0xA01E2A), robeShade = C(0x741520), robeLight = C(0xC0343E)
    let silver = C(0xD4DAE2), silverDark = C(0x9AA4B2)
    let hair = C(0xF4EED2), hairShade = C(0xD2C9A2), brow = C(0xB8AC80)
    let a = p.melee ?? (seatedPose ? 10 : 30)
    // The back blade, behind him in his other hand, mirroring the front one.
    drawCurvedBlade(c, at: (16.0, 34.5 + Double(p.breathe)), angle: 180 - a, trail: [])
    drawBackCape(c, t: p.t, speed: p.capeSpeed, color: C(0x6A1018), edge: silver, hem: 42)
    drawLegs(c, Look(leg: robeShade), step: p.step)
    drawBoots(c, p.step, C(0x3A2A2A), rows: 1)
    c.oy += p.breathe
    // His hair down his back, to the waist.
    c.pattern(13, 26, ["HHHH", "HhHH", "HHHH", "HHhH", "hHHH", "HHHH", "HHhH", ".HHH", ".HhH", "..HH"],
              ["H": hair, "h": hairShade])
    drawBody(c, Look(arm: robe))
    // The robe, the shoulders to the ankles, flaring a little, silver at the collar, down the front and round the hem.
    c.rect(18, 32, 20, 6, robe)
    c.rect(37, 32, 1, 6, robeShade)
    for y in 38...41 where y + c.oy <= 43 {
        let k = y - 38, l = 17 - (k + 1) / 2, r = 38 + (k + 1) / 2
        c.rect(l, y, r - l + 1, 1, y == 41 ? silver : robe)
        c.px(l, y, y == 41 ? silverDark : robeLight); c.px(r, y, y == 41 ? silverDark : robeShade)
    }
    c.rect(18, 32, 20, 1, silver)
    c.rect(29, 33, 1, 8, silver)
    c.pattern(21, 33, ["s.s.s", ".s.s.", "s.s.s"], ["s": silverDark])           // the brocade
    c.rect(18, 36, 20, 1, silverDark); c.rect(28, 36, 3, 1, silver)          // the girdle and its clasp
    c.rect(14, 33, 4, 4, robe); c.rect(14, 36, 4, 1, silver); c.px(14, 33, robeLight)   // the back sleeve
    c.rect(15, 34, 2, 2, clawdOrange)                                          // the back fist on its hilt
    // Long straight pale hair, parted in the middle, framing the face, past the shoulders.
    c.pattern(16, 20, [
        ".......HHHHHHHHHH.......",
        "....HHHHHHHHHHHHHHHH....",
        "..HHHHHHHHHhHHHHHHHHHH..",
        ".HHHHHHHHHhhHHHHHHHHHHH.",
        ".HHhHHHHHHhHHHHHHHHHhHH.",
        "HHHhHHHHHh...hHHHHHHhHHH",
        "HHHh................hHHH",
        "HHh..................hHH",
        "HHH..................HHH",
        "HHh..................hHH",
        "HHH..................HHH",
        "HHh..................hHH",
        "HHH..................HHH",
        ".Hh..................hH.",
    ], ["H": hair, "h": hairShade])
    c.px(15, 28, clawdOrange); c.px(40, 28, clawdOrange)                      // the pointed ears
    c.px(21, 28, brow); c.px(22, 27, brow); c.px(23, 27, brow)                // arched brows
    c.px(32, 27, brow); c.px(33, 27, brow); c.px(34, 28, brow)
    // The crown: bare branches rising from a band, berries and autumn leaves on the twigs.
    c.pattern(17, 12, [
        "..........RR..........",
        "...R.....lbbl.....R...",
        "...b..R...bb...R..b...",
        "R.Lb...b..bb..b...bL.R",
        "b..bb..bl.bb.lb..bb..b",
        ".b..b.Lb..bb..bL.b..b.",
        ".bb.bb..b.bb.b..bb.bb.",
        "..b..bb.bbbbbb.bb..b..",
        "..bbb.bbb.bb.bbb.bbb..",
        "...BBBBBBBBBBBBBBBB...",
    ], ["b": C(0x6A4424), "B": C(0x4E321A), "R": C(0xD8202A), "L": C(0xD8782A), "l": C(0xE8B440)])
    c.px(23, 21, C(0xE8B440)); c.px(28, 21, C(0xD8202A)); c.px(33, 21, C(0xE8B440))   // set in the band
    drawCurvedBlade(c, at: Sprite.hand, angle: a, trail: p.melee == nil ? [] : p.trail)
    c.rect(38, 33, 2, 3, robe); c.rect(38, 36, 2, 1, silver)
    c.rect(40, 33, 2, 3, clawdOrange); c.px(40, 35, clawdShade)               // the fist round the grip
}

/// A curved elven blade in a fist at `hand`, at `angle`: a dark grip, a silver pommel and a short leaf-shaped guard, and
/// a 14 px blade curving well back toward the tip, with a darker edge; a pale smear along `trail` behind a fast stroke.
private func drawCurvedBlade(_ c: PixelCanvas, at hand: (x: Double, y: Double), angle: Double, trail: [Double]) {
    let length = 14.0, steel = C(0xE4EAF2), edge = C(0x9AA6B6), silver = C(0xD4DAE2)
    for (i, a) in trail.enumerated() {
        let u = unit(a)
        c.glowLine(hand.x + u.x * 4, hand.y + u.y * 4, hand.x + u.x * (3 + length), hand.y + u.y * (3 + length),
                   core: C(0xEEF4FA), glow: C(0xAAB8C8), coreR: 0.5, glowR: 1.6, strength: 0.32 / Double(i + 1))
    }
    let u = unit(angle), n = (x: -u.y, y: u.x)
    // A point `d` along the blade, bent back (away from the edge) toward the tip.
    func at(_ d: Double, _ o: Double = 0) -> (x: Double, y: Double) {
        let k = max(0, d - 3) / length, bend: Double = -3.2 * k * k + o
        return (hand.x + u.x * d + n.x * bend, hand.y + u.y * d + n.y * bend)
    }
    line(c, hand.x - u.x * 2.5, hand.y - u.y * 2.5, hand.x + u.x * 1.5, hand.y + u.y * 1.5, C(0x3A1418), 0.6)   // the grip
    c.px(Int((hand.x - u.x * 3).rounded(.down)), Int((hand.y - u.y * 3).rounded(.down)), silver)               // the pommel
    var d = 3.0
    while d < 3 + length {
        let p0 = at(d), p1 = at(min(d + 2, 3 + length))
        line(c, p0.x, p0.y, p1.x, p1.y, steel, d + 2 >= 3 + length ? 0.5 : 0.75)
        let e0 = at(d, 0.7), e1 = at(min(d + 2, 2 + length), 0.7)
        line(c, e0.x, e0.y, e1.x, e1.y, edge, 0.3)
        d += 2
    }
    let g = (x: hand.x + u.x * 2.5, y: hand.y + u.y * 2.5)
    line(c, g.x - n.x * 2, g.y - n.y * 2, g.x + n.x * 2, g.y + n.y * 2, silver, 0.5)                            // the guard
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
