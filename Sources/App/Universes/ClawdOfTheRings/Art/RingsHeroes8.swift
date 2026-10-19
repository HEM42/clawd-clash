import Foundation

// Heroes: the Marshal of the Mark, the folk of the Wilderland and the hasty young Ent. Éomore and Bard the Bowmanpage
// are Clawd in costume at Clawd's full height: Éomore in the same Rohan kit as Éowin and King Théodone
// (`drawRohanCloak`, `drawRohanShield` and the `rohan…` colours in RingsHem.swift), but with a taller, gold-ridged helmet
// and its long horsetail, a spear and a leather cuirass; Bard's black longbow is held and drawn the way Leggolas holds
// and draws his. Beorn is a big Clawd, a quarter again a Man's height and half again as broad (his `headTop`, his fist
// and his `bulk` say so). Quicksort isn't Clawd at all: an Ent, half again a Man's height like B-Treebeard, but a
// slim, smooth-barked rowan, with only a warm Clawd-orange glow left in his eyes.

let ringsHeroes8: [RingsHero: Persona] = [
    .eomer: Persona(name: "Éomore", weapon: .saber, headTop: 13, signature: 3.0,
                    callout: "I am Éomore, son of Éomund, Third Marshal of the Riddermark… --More--", draw: drawEomer),
    .bard: Persona(name: "Bard the Bowmanpage", weapon: .blaster, shot: .arrow, muzzle: (46, 34), handGun: false, headTop: 20, signature: 3.4,
                   callout: "Black Arrow, I saved you for the last man page.", draw: drawBard),
    .beorn: Persona(name: "Beorn the Bearer-token", weapon: .saber, pivot: beornFist, bulk: 8, headTop: 13, signature: 3.6,
                    callout: "Authorization: Bear. Now state your business.", draw: drawBeorn),
    .quickbeam: Persona(name: "Quicksort", weapon: .saber, canSit: false, pivot: quickbeamShoulder, bulk: 4, headTop: 7, signature: 3.2,
                        callout: "Hasty? I'm O(n log n). On average.", draw: drawQuickbeam),
]

// MARK: - Éomore

/// Éomore, Marshal of the Riddermark, Éowin's brother: the Rohan kit, worn harder. A tall steel helmet, a gold ridge up
/// its front to a gold finial, a gold-riveted band and gold cheek pieces, and a long white horsetail springing from the
/// finial and hanging down his back; a short dark-gold beard; a dark leather cuirass with the gold horse of the Mark on
/// it, over mail, a mail skirt below the belt; the green-and-gold cloak, the sun-horse shield on his off arm, and a
/// tall ash spear with a leaf blade and a little green-and-white pennon, upright in his fist at rest, its butt on the
/// ground. Swung, it smears behind a fast stroke. Signature: the Marshal has more to say: he lifts the spear high,
/// and a pager's "--More--" prompt pops up over his head in reverse video, its cursor blinking, until (a key pressed)
/// it's gone and the spear comes down.
private func drawEomer(_ c: PixelCanvas, _ p: Pose) {
    let leather = C(0x5A3A24), leatherDark = C(0x3E2818), leatherLight = C(0x7A5232)
    let beard = C(0xA8823E), beardDark = C(0x7E5E28)
    drawRohanCloak(c, t: p.t, speed: p.capeSpeed)
    drawLegs(c, Look(leg: rohanTrousers), step: p.step)
    drawBoots(c, p.step, rohanBoot, rows: 3)
    c.oy += p.breathe
    drawHorsetail(c, t: p.t)
    drawBody(c, Look(arm: rohanMail))
    // The cuirass, the gold horse on it, the belt, and the mail skirt below it.
    c.rect(18, 33, 20, 4, leather); c.rect(37, 33, 1, 4, leatherDark); c.rect(18, 33, 20, 1, leatherLight)
    c.pattern(26, 34, ["..GG", ".GGG", "GG.."], ["G": rohanGold])
    c.rect(18, 37, 20, 1, leatherDark); c.rect(27, 37, 2, 1, rohanGold)
    for y in 38...39 where y + c.oy <= 43 {
        for x in 18...36 { c.px(x, y, (x + y) % 2 == 0 ? rohanMailLight : rohanMail) }
        c.px(37, y, rohanMailDark)
    }
    // The cloak over the shoulders, gold-edged, and its clasps.
    c.rect(18, 33, 2, 5, rohanCloak); c.rect(20, 33, 1, 5, rohanGold)
    c.rect(36, 33, 2, 5, rohanCloak); c.rect(35, 33, 1, 5, rohanGold)
    c.px(20, 33, C(0xFFE08A)); c.px(35, 33, C(0xFFE08A))
    // The short beard, from the sideburns under the cheek pieces round the jaw, and the moustache.
    c.rect(19, 29, 2, 3, beard); c.rect(35, 29, 2, 3, beard)
    c.pattern(19, 32, [
        "BBBBBBBBBBBBBBBBBB",
        ".BBbBBBmmmmBBBbBB.",
        "..BBBBbBBBBbBBBB..",
        "....BBBBbBBBBB....",
    ], ["B": beard, "b": beardDark, "m": beardDark])
    drawEomerHelmet(c)
    // The spear, upright in his fist at rest, its butt on the ground; swung along `p.melee`.
    let angle = p.melee ?? (seatedPose ? -60 : -84)
    for (i, a) in (p.melee == nil ? [] : p.trail).enumerated() {
        let u = unit(a), h = Sprite.hand
        c.glowLine(h.x + u.x * 4, h.y + u.y * 4, h.x + u.x * 26, h.y + u.y * 26, core: C(0xE8EEF4), glow: C(0xA8B4C0),
                   coreR: 0.5, glowR: 1.6, strength: 0.32 / Double(i + 1))
    }
    let up = Int((5 * (p.signature.map { arc($0, rise: 0.16, fall: 0.86) } ?? 0)).rounded())
    c.oy -= up                                                                // raised high in his signature
    drawSpear(c, angle: angle, t: p.t, butt: seatedPose ? 3 : 9)
    c.rect(38, 33, 2, 3 + up, rohanMail); c.rect(40, 33, 2, 3, clawdOrange); c.px(40, 35, clawdShade)   // the fist round the shaft
    c.oy += up
    drawRohanShield(c, cx: 14, cy: seatedPose ? 33 : 35)
    if let s = p.signature, s >= 0.24, s < 0.8 { drawMorePrompt(c, s) }
}

/// The pager's "--More--" prompt over Éomore's head, `s` through his signature: popping up (a pixel high for a
/// moment), light grey with dark letters like a terminal's reverse video, a block cursor blinking after it.
private func drawMorePrompt(_ c: PixelCanvas, _ s: Double) {
    let paper = C(0xE4E4DC), letter = C(0x16161A)
    let x = 7, y = 3 + (s < 0.27 ? -1 : 0)
    c.rect(x, y, 34, 9, paper)
    c.rect(x, y + 8, 34, 1, C(0xA8A8A0))
    let glyphs: [[String]] = [
        ["..", "..", "--", "..", ".."],
        ["..", "..", "--", "..", ".."],
        ["M...M", "MM.MM", "M.M.M", "M...M", "M...M"],
        ["...", ".o.", "o.o", "o.o", ".o."],
        ["...", "r.r", "rr.", "r..", "r.."],
        ["...", ".e.", "eee", "e..", ".ee"],
        ["..", "..", "--", "..", ".."],
        ["..", "..", "--", "..", ".."],
    ]
    var gx = x + 1
    for g in glyphs {
        c.pattern(gx, y + 2, g, ["-": letter, "M": letter, "o": letter, "r": letter, "e": letter])
        gx += g[0].count + 1
    }
    if Int(s * 14) % 2 == 0 { c.rect(gx, y + 2, 2, 5, letter) }              // the cursor, blinking
}

/// Éomore's helmet: taller than Éowin's, a steel dome rising to a gold finial, a gold ridge up its front, a dark band
/// with gold rivets, gold cheek pieces and a steel nose guard.
private func drawEomerHelmet(_ c: PixelCanvas) {
    let goldDark = C(0xB8862A)
    c.pattern(17, 16, [
        ".........HGGH.........",
        ".......HHHGGHHD.......",
        "......HlHHGGHHHD......",
        ".....HlHHHGGHHHHD.....",
        "....HlHHHHGGHHHHHD....",
        "...HHHHHHHGGHHHHHHD...",
        "..HHHHHHHHGGHHHHHHHD..",
        ".HHHHHHHHHGGHHHHHHHHD.",
        "HHHHHHHHHHGGHHHHHHHHHD",
        "BBBBBBBBBBBBBBBBBBBBBB",
        "GG........NN........GG",
        "GG........NN........GG",
        "g.........NN.........g",
    ], ["H": rohanSteel, "l": white, "D": rohanSteelDark, "B": rohanSteelDark, "N": rohanSteel, "G": rohanGold, "g": goldDark])
    for x in [19, 23, 32, 36] { c.px(x, 25, rohanGold) }
    c.rect(27, 13, 2, 2, rohanGold); c.px(28, 13, C(0xFFE08A)); c.rect(26, 15, 4, 1, goldDark)   // the finial
}

/// The long white horsetail, springing up and back from the helmet's finial and hanging down his back, its lower end
/// swaying.
private func drawHorsetail(_ c: PixelCanvas, t: Double) {
    let sway: Double = sin(t * 2.2)
    let pts: [(x: Double, y: Double)] = [(27, 13), (24.5, 12.5), (21.5, 13.5), (19, 15.5), (17, 18.5), (15.5, 22), (14.5, 25.5),
                                         (13.5, 29), (12.5, 32)]
    func at(_ i: Int) -> (x: Double, y: Double) {
        let k = Double(i) / Double(pts.count - 1)
        return (pts[i].x + sway * k * k * 1.5, pts[i].y)
    }
    for i in 1..<pts.count {
        let k = Double(i) / Double(pts.count - 1), a = at(i - 1), b = at(i)
        line(c, a.x, a.y, b.x, b.y, rohanCrest, 0.9 + sin(k * .pi) * 0.9)
    }
    for i in 3..<pts.count {
        let a = at(i - 1), b = at(i)
        line(c, a.x + 0.8, a.y, b.x + 0.8, b.y, C(0xC8C6C0), 0.3)
    }
}

/// Éomore's spear in his fist at `angle`: an ash shaft running `butt` px back past the fist to an iron cap, a gold
/// collar, a long steel leaf blade, and a little green-and-white pennon below it, fluttering.
private func drawSpear(_ c: PixelCanvas, angle: Double, t: Double, butt: Double) {
    let ash = C(0x8A6A44), ashDark = C(0x6A4E2E), iron = C(0x5A5E66), steel = C(0xD0D6DE), edge = C(0x8A929C)
    let h = Sprite.hand, u = unit(angle), n = (x: -u.y, y: u.x)
    func at(_ d: Double, _ o: Double = 0) -> (x: Double, y: Double) { (h.x + u.x * d - n.x * o, h.y + u.y * d - n.y * o) }
    let b = at(-butt), s = at(21)
    line(c, b.x, b.y, s.x, s.y, ash, 0.55)
    c.px(Int(b.x.rounded(.down)), Int(b.y.rounded(.down)), iron)
    // The pennon, trailing back off the shaft below the blade.
    let flap = Int(t * 6) % 2
    for (k, len) in [(0, 4), (1, 3), (2, 2), (3, 1)] {
        for o in 1...len + (k == 0 ? flap : 0) {
            let q = at(17.5 + Double(k), Double(o))
            c.px(Int(q.x.rounded(.down)), Int(q.y.rounded(.down)), k % 2 == 0 ? rohanCloak : rohanCrest)
        }
    }
    let g = at(21)
    c.px(Int(g.x.rounded(.down)), Int(g.y.rounded(.down)), rohanGold)                     // the collar
    let b0 = at(21.5), b1 = at(27.5), m0 = at(23), m1 = at(25.5)
    line(c, b0.x, b0.y, b1.x, b1.y, steel, 0.5)
    line(c, m0.x, m0.y, m1.x, m1.y, steel, 1.1)
    let e0 = at(22.5, -0.8), e1 = at(26, -0.6)
    line(c, e0.x, e0.y, e1.x, e1.y, edge, 0.3)
    let mid = at(-butt * 0.5 + 5, -0.4)
    c.px(Int(mid.x.rounded(.down)), Int(mid.y.rounded(.down)), ashDark)
}

// MARK: - Bard the Bowmanpage

/// Bard the Bowmanpage, the bargeman of Lake-town: a long weathered coat of faded slate blue to the knees, open below
/// the belt, a stain or two on it, a rough leather mantle over the shoulders; long straight dark hair, parted in the
/// middle, past his shoulders, and a short dark beard; a quiver on his back, black-feathered; and a great black yew
/// longbow, taller than he is, held out in front of him. Shooting, he nocks an arrow and draws the string back before
/// each shot, as Leggolas does; the arrow on his string is the Black Arrow, black-shafted, its iron head barbed.
/// Signature: the dragon overhead: he turns the great bow up over his head, the Black Arrow on the string, draws it and
/// holds it aimed straight up at the sky, steady, a glint on its head; then eases the string and lowers the bow.
private func drawBard(_ c: PixelCanvas, _ p: Pose) {
    let coat = C(0x34424E), coatShade = C(0x26323C), coatLight = C(0x4A5A68), stain = C(0x2C3842)
    let leather = C(0x6A4A30), leatherDark = C(0x4A3220), leatherLight = C(0x86603E)
    let hair = C(0x201814), hairLight = C(0x3A2C24)
    drawLegs(c, Look(leg: C(0x3A3228)), step: p.step)
    drawBoots(c, p.step, C(0x2A1E16), rows: 3)
    c.oy += p.breathe
    // The quiver, slung over his back, black fletchings over his shoulder.
    c.pattern(10, 17, [
        "F.f.....",
        "fF.F....",
        ".fFf....",
        "..QQQ...",
        "..QQQq..",
        "...QQQq.",
        "...QQQQ.",
        "....QQQq",
        "....QQQQ",
    ], ["F": C(0x1E1E22), "f": C(0x5A5A62), "Q": leatherDark, "q": C(0x36241A)])
    drawBody(c, Look(arm: coat))
    // The long coat, the collar to the knees, split at the front below the belt.
    c.rect(18, 32, 20, 6, coat); c.rect(37, 32, 1, 6, coatShade)
    for y in 38...40 where y + c.oy <= 43 {
        let w = (y - 37) / 2, l = 18 - w, r = 37 + w
        c.rect(l, y, r - l + 1, 1, coat)
        c.px(l, y, coatLight); c.px(r, y, coatShade); c.px(27, y, coatShade); c.px(28, y, coatShade)
    }
    c.rect(22, 34, 2, 1, stain); c.px(32, 39, stain); c.px(21, 39, coatLight)                // weathered
    c.rect(18, 36, 20, 1, leatherDark); c.px(25, 36, C(0x9A8A6A))                            // the belt and its buckle
    // The leather mantle over the shoulders, ragged at its edge.
    c.pattern(16, 32, [
        "..LLLLLLLLLLLLLLLLLLLL..",
        ".LdLLLLLLLLLLLLLLLLLLdL.",
        "..d.Ld.dL.Ld.Ld.dL.dL...",
    ], ["L": leather, "d": leatherDark])
    c.rect(18, 32, 20, 1, leatherLight)
    c.rect(15, 33, 3, 3, coat)
    // Long straight dark hair, parted in the middle, past the shoulders.
    c.pattern(16, 20, [
        ".......HHHHHHHHHH.......",
        "....HHHlllHHHHHHHHHH....",
        "..HHHHHHHHHlHHHHHHHHHH..",
        ".HHHHHHHHHlHHHHHHHHHHHH.",
        ".HHlHHHHHHlHHHHHHHHlHHH.",
        "HHHHHHHHHl..HHHHHHHHHHHH",
        "HHHHH..............HHHHH",
        "HHHl................lHHH",
        "HHl..................lHH",
        "HHl..................lHH",
        "HHl..................lHH",
        "HHH..................HHH",
        "HHl..................lHH",
        "HHl..................lHH",
        ".HH..................HH.",
        ".HH..................HH.",
    ], ["H": hair, "l": hairLight])
    // The short dark beard round the jaw, and the moustache.
    c.rect(19, 31, 1, 2, hair); c.rect(36, 31, 1, 2, hair)
    c.pattern(19, 32, [
        "B....BBBBBBBB....B",
        ".BB.BBB....BBB.BB.",
        "...BBBBllBBBBB....",
        ".......BBBB.......",
    ], ["B": hair, "l": hairLight])
    // The black longbow, held out at arm's length; the Black Arrow on the string while he aims, drawn back to shoot.
    var pull = 0, nocked = p.ready
    if let f = p.fire {
        let ph = frac(f.t / p.firePeriod)
        nocked = ph >= 0.45
        if ph > 0.6 { pull = Int(((ph - 0.6) / 0.4 * 3).rounded()) }
    }
    c.oy += p.gunY + (seatedPose ? -3 : 0)
    if let s = p.signature, s > 0.02, s < 0.98 {
        drawBardAimUp(c, s, coat: coat)
        return
    }
    drawBlackLongbow(c, pull: pull)
    c.rect(38, 33, 4, 2, coat)
    c.rect(42, 33, 2, 3, clawdOrange)
    if nocked {
        let tail = 40 - pull
        c.rect(tail, 34, 47 - tail, 1, C(0x1E1E22))
        c.px(47, 33, C(0x3A3E46)); c.px(47, 35, C(0x3A3E46))                                // the barbs
        c.px(47, 34, C(0x5A5E68)); c.px(48, 34, C(0x8A8E98)); c.px(49, 34, C(0xC8CCD4))       // the iron head
        c.px(tail, 33, C(0x5A5A62)); c.px(tail, 35, C(0x5A5A62))
        c.rect(tail - 1, 34, 2, 2, clawdOrange)                                                // the hand on the string
    }
}

/// Bard's signature, `s` through it: the longbow turned up over his head (…0.2), the Black Arrow drawn (…0.36) and
/// held aimed straight up, a glint running over its head; the string eased (0.74…) and the bow lowered (0.8…).
private func drawBardAimUp(_ c: PixelCanvas, _ s: Double, coat: Px) {
    let raise = arc(s, rise: 0.2, fall: 0.8)
    let angle = -90 * raise
    let grip = (x: 44.5 - 3 * raise, y: 34.5 - 19 * raise)
    let draw = s < 0.22 ? 0 : s < 0.36 ? smooth((s - 0.22) / 0.14) : s < 0.72 ? 1 : 1 - smooth((s - 0.72) / 0.08)
    let pull = Int((3 * draw).rounded())
    // A point on the bow at rest, (`x`, `y`) from its grip, where it is now.
    func turned(_ x: Double, _ y: Double) -> (x: Double, y: Double) {
        let u = unit(angle)
        return (grip.x + x * u.x - y * u.y, grip.y + x * u.y + y * u.x)
    }
    let fist = turned(-1.5, 0)
    line(c, 38.5, 33.5, fist.x, fist.y, coat, 0.9)                                         // the bow arm, up
    let b = PixelCanvas(61, 61)
    b.ox = -14; b.oy = -4                                                                  // the bow's grip on (30, 30)
    drawBlackLongbow(b, pull: pull)
    b.rect(42, 33, 2, 3, clawdOrange)
    if s > 0.08 && s < 0.92 {
        let tail = 40 - pull
        b.rect(tail, 34, 47 - tail, 1, C(0x1E1E22))
        b.px(47, 33, C(0x3A3E46)); b.px(47, 35, C(0x3A3E46))
        b.px(47, 34, C(0x5A5E68)); b.px(48, 34, C(0x8A8E98)); b.px(49, 34, C(0xC8CCD4))
        b.px(tail, 33, C(0x5A5A62)); b.px(tail, 35, C(0x5A5A62))
        b.rect(tail - 1, 34, 2, 2, clawdOrange)
    }
    let r = b.rotated(angle, about: (30.5, 30.5), into: 61, 61, at: (30.5, 30.5))
    let x0 = Int(floor(grip.x - 30.5)), y0 = Int(floor(grip.y - 30.5))
    for y in 0..<r.h where y0 + y + c.oy <= 43 {                                          // never through the floor
        for x in 0..<r.w {
            let i = (y * r.w + x) * 4
            guard r.buf[i + 3] > 0 else { continue }
            let m = 255 / Double(r.buf[i + 3])
            c.px(x0 + x, y0 + y, Px(r: UInt8(min(255, Double(r.buf[i]) * m)), g: UInt8(min(255, Double(r.buf[i + 1]) * m)),
                                    b: UInt8(min(255, Double(r.buf[i + 2]) * m)), a: r.buf[i + 3]))
        }
    }
    // Held aimed at the sky: a glint on the arrowhead now and then.
    if s > 0.4 && s < 0.7 && Int(s * 20) % 3 == 0 {
        let h = turned(5, 0)
        c.glowLine(h.x - 2, h.y, h.x + 2, h.y, core: C(0xFFFFFF), glow: C(0xC8D8FF), coreR: 0.3, glowR: 1.2, strength: 0.8)
        c.glowLine(h.x, h.y - 2, h.x, h.y + 2, core: C(0xFFFFFF), glow: C(0xC8D8FF), coreR: 0.3, glowR: 1.2, strength: 0.8)
    }
}

/// Bard's great black yew longbow, gripped at (44, 34), taller than Leggolas' and thicker in the limb, a leather
/// grip, a sheen on the black; the string back at x 40, drawn back `pull` pixels more at the middle.
private func drawBlackLongbow(_ c: PixelCanvas, pull: Int = 0) {
    let limb = C(0x24242A), limbDark = C(0x121216), sheen = C(0x4E4E58), grip = C(0x7A5232), string = C(0xD8D8E0)
    for y in 22...46 where y + c.oy <= 43 {
        let d = abs(y - 34)
        let x = d <= 2 ? 45 : d <= 5 ? 44 : d <= 8 ? 43 : d <= 10 ? 42 : 41
        c.px(x, y, d <= 1 ? grip : d % 4 == 2 ? sheen : limb)
        if d <= 9 { c.px(x - 1, y, d <= 1 ? grip : limbDark) }
        if d == 12 { c.px(x + 1, y, limb) }                                                  // the recurved tips
    }
    for y in 23...45 where y + c.oy <= 43 {
        let d = Double(abs(y - 34)) / 11
        c.px(40 - Int((Double(pull) * (1 - d)).rounded()), y, string)
    }
}

// MARK: - Beorn the Bearer-token

/// Where Beorn's club swings from: his big fist, out in front of him.
private let beornFist: (x: Double, y: Double) = (45.0, 33.5)

/// Beorn the Bearer-token, the skin-changer: a big Clawd, a quarter again a Man's height and half again as broad. A
/// bear-skin over his head and down his back, the bear's round ears on top and its muzzle and black nose over his
/// brow; a wild black mane spilling out from under it, heavy black brows and a great wild black beard down his chest;
/// a plain undyed wool tunic, sleeveless, roped at the waist, over his bare, heavy arms; rough leggings, fur wrapped
/// round his feet. In his fist a knobbly oak club, held low at rest; swung, it smears behind it a long way (it's heavy).
/// Signature: the skin-changer changes: brown fur rises over him from his feet to his brow, his fist a clawed paw, until
/// he's all bear under the bear's head, which comes alive, eyes burning, and growls with its jaws wide; then the fur
/// sinks away again and he's Beorn.
private func drawBeorn(_ c: PixelCanvas, _ p: Pose) {
    let skin = clawdOrange, skinShade = clawdShade, skinLight = C(0xE8906E)
    let fur = C(0x5A3A22), furDark = C(0x3E2614), furLight = C(0x7A5232), muzzle = C(0x9A7450)
    let hair = C(0x1A1614), hairDark = C(0x0A0808), hairLight = C(0x3A322E)
    let wool = C(0x8A7A5C), woolDark = C(0x6A5C44), woolLight = C(0xA8987A), rope = C(0x5A4A30)
    drawFurCloak(c, t: p.t, speed: p.capeSpeed, fur: fur, dark: furDark, light: furLight)
    drawBeornLegs(c, p.step, leg: C(0x4A3A2A), wrap: fur, wrapLight: furLight)
    c.oy += p.breathe
    // The back arm, bare and heavy, hanging, a fist at the end.
    c.rect(10, 25, 5, 10, skin); c.rect(10, 25, 1, 10, skinLight); c.rect(11, 29, 3, 1, skinShade)
    c.rect(9, 34, 6, 3, skin); c.rect(9, 36, 6, 1, skinShade)
    // The body: Clawd's block, a quarter taller and half again as broad.
    c.rect(15, 21, 26, 17, skin); c.rect(40, 21, 1, 17, skinShade); c.rect(15, 37, 26, 1, skinShade)
    // The tunic, the shoulders bare, roped at the waist, its skirt over the tops of his legs.
    c.rect(15, 31, 26, 6, wool); c.rect(40, 31, 1, 6, woolDark); c.rect(15, 31, 1, 6, woolLight)
    for y in 37...39 where y + c.oy <= 43 {
        c.rect(15, y, 26, 1, wool); c.px(15, y, woolLight); c.px(40, y, woolDark); c.px(22, y, woolDark); c.px(33, y, woolDark)
    }
    c.rect(15, 35, 26, 1, rope); c.px(18, 36, rope); c.px(18, 37, rope)
    // The wild black mane, spilling out either side from under the bear-skin.
    let mane = ["..HHHH", ".HHHHH", "HHHhHH", ".HHhHH", "HHhHHH", ".HhHHH", "HHHHH.", ".HhHH.", "HHhH..", ".HHH..",
                "HH.H..", ".H...."]
    c.pattern(11, 21, mane, ["H": hair, "h": hairLight])
    c.pattern(39, 21, mane.map { String($0.reversed()) }, ["H": hair, "h": hairLight])
    // Heavy brows, knitted, and the eyes.
    c.pattern(19, 23, ["B...", "BBBB"], ["B": hair]); c.pattern(33, 23, ["...B", "BBBB"], ["B": hair])
    c.rect(20, 25, 2, 3, ink); c.rect(34, 25, 2, 3, ink)
    // The great wild beard, from the sideburns down over his chest, a dark mouth in it.
    let beardRows = [
        "HHHH..................HHHH",
        "HHHHH..HHHHHHHHHHHH..HHHHH",
        "HHHHHHHHHHHddddHHHHHHHHHHH",
        "HHHhHHHHHHHHHHHHHHHHHHhHHH",
        ".HHhHHHhHHHHHHHHHHhHHHhHH.",
        ".HHHHHHhHHHllHHHHHhHHHHHH.",
        "..HHHHHHHHhHHHHHHhHHHHHH..",
        "..HHHHHHHHhHHHHHHhHHHHHH..",
        "...HHHhHHHHHHHHHHHHhHHH...",
        "...HH.HHHHHhHHHHHHHH.HH...",
        ".....HH.HHHHHHHHH.HH......",
        "........H.HHHHH.H.........",
    ]
    c.pattern(15, 28, Array(beardRows.prefix(max(0, 43 - c.oy - 28 + 1))), ["H": hair, "h": hairLight, "l": hairLight, "d": hairDark])
    // The bear-skin over his head: the bear's round ears, its little eyes, its muzzle and black nose over his brow.
    c.pattern(13, 12, [
        "...FFF..................FFF...",
        "..FmmF..................FmmF..",
        "..FFFFFFFFFFFFFFFFFFFFFFFFFF..",
        ".FFFFFFFllFFFFFFFFFFllFFFFFFF.",
        ".FFFFFFFFFFFFFFFFFFFFFFFFFFFF.",
        "FFFFFFFFFeFFFFFFFFFFeFFFFFFFFF",
        "FFFFFFFFFFFFmmmmmmFFFFFFFFFFFF",
        "FFFFFFFFFFFmmmNNmmmFFFFFFFFFFF",
        "FFFdFFFFFFFmmmmmmmmFFFFFFFdFFF",
        "dFF.dFdFdFdFFmmmmFFdFdFdFd.FFd",
    ], ["F": fur, "l": furLight, "d": furDark, "m": muzzle, "e": hairDark, "N": hairDark])
    // The front arm, bare and heavy, out to the fist round the club.
    line(c, 40, 27, 44, 32, skin, 1.8)
    c.px(41, 27, skinLight); c.px(42, 28, skinLight); c.px(42, 31, skinShade)
    let bear = p.signature.map { arc($0, rise: 0.3, fall: 0.72) } ?? 0
    if let s = p.signature, bear > 0.02 { drawBearShift(c, s, bear: bear, fur: fur, dark: furDark, light: furLight, muzzle: muzzle) }
    let angle = p.melee ?? (seatedPose ? 8 : 25)
    for (i, a) in heavySmear(angle, p.melee == nil ? [] : p.trail).enumerated() {
        let u = unit(a), fade: Double = 0.36 * (1 - Double(i) / 12)
        guard fade > 0.03 else { break }
        let h = beornFist
        c.glowLine(h.x + u.x * 5, h.y + u.y * 5, h.x + u.x * 16, h.y + u.y * 16, core: C(0xC8B89A), glow: C(0x8A7A5A),
                   coreR: 1, glowR: 2.2, strength: fade)
    }
    drawClub(c, angle: angle)
    c.rect(43, 32, 4, 3, skin); c.px(46, 32, skinLight); c.rect(43, 34, 4, 1, skinShade)    // the fist
    if bear > 0.6 {                                                                        // a bear's paw, clawed
        c.rect(43, 32, 4, 3, fur); c.px(46, 32, furLight); c.rect(43, 34, 4, 1, furDark)
        for y in [32, 34] { c.px(47, y, C(0xE8E0D0)) }
    }
}

/// Beorn turning bear, `bear` of the way (0…1), `s` through his signature: everything drawn of him from his feet up to
/// a ragged line rising with `bear` to his brow is shaggy fur; fully bear, the bear's head on top comes alive, its eyes
/// burning and its jaws open wide in a growl, growl lines shaking off it.
private func drawBearShift(_ c: PixelCanvas, _ s: Double, bear: Double, fur: Px, dark: Px, light: Px, muzzle: Px) {
    let level = 43.5 - bear * 22.5                                                         // up to row 21, under the skin
    for x in 6...48 {
        let top = Int((level + Double((x * 5) % 3) - 1).rounded(.down))
        guard max(21, top) <= 43 else { continue }
        for y in max(21, top)...43 where c.isDrawn(x + c.ox, y + c.oy + c.baseY) {
            let n = (x * 7 + y * 13) % 11
            c.px(x, y, y == top ? dark : n == 0 ? light : n == 5 || n == 8 ? dark : fur)
        }
    }
    guard s > 0.36 && s < 0.68 else { return }
    // The growl: the jaw drops open under the muzzle, fangs white, eyes burning, lines shaking off it.
    let shake = Int(s * 40) % 2
    c.pattern(23 + shake, 20, [
        ".mmmmmmmm.",
        "mWkkkkkkWm",
        "mkkrrrrkkm",
        "mkWkkkkWkm",
        ".mmmmmmmm.",
    ], ["m": muzzle, "k": C(0x2A0E0A), "r": C(0x8A2A2A), "W": C(0xF4F0E4)])
    for ex in [22, 33] { c.px(ex, 17, C(0xFFB040)); c.px(ex + 1, 17, C(0xFF7A2A).alpha(0.6)) }
    if Int(s * 20) % 2 == 0 {
        for (i, y) in [15.0, 19.0, 23.0].enumerated() {
            let x = 46.0 + Double(i % 2)
            c.glowLine(x, y, x + 4, y - 1 + Double(i), core: C(0xF4F0E4), glow: C(0xF4F0E4, 0), coreR: 0.4, glowR: 0.5)
        }
    }
}

/// Beorn's four big legs in rough leggings, fur wrapped round the feet (folded forward when he sits).
private func drawBeornLegs(_ c: PixelCanvas, _ step: Int, leg: Px, wrap: Px, wrapLight: Px) {
    let xs = [16, 22, 32, 38]
    if seatedPose {
        for lx in xs { c.rect(lx - 1, 38, 5, 2, leg); c.rect(lx + 2, 38, 2, 2, wrap) }
        return
    }
    for (i, lx) in xs.enumerated() {
        let bottom = step >= 0 && i % 2 == step ? 42 : 43
        c.rect(lx, 36, 3, bottom - 35, leg)
        c.rect(lx, bottom - 2, 3, 3, wrap); c.px(lx, bottom - 2, wrapLight); c.px(lx + 2, bottom - 1, wrapLight)
    }
}

/// The bear-skin hanging down his back, seen from the side: shaggy brown fur past the shoulder and between the back
/// legs, flecked lighter and darker, its hem swaying at `speed`.
private func drawFurCloak(_ c: PixelCanvas, t: Double, speed: Double, fur: Px, dark: Px, light: Px) {
    let top = 22, hem = 42, last = min(hem, 43 - c.oy)
    guard last >= top else { return }
    for y in top...last {
        let k = Double(y - top) / Double(hem - top)
        let sway = sin(t * speed + k * 2.2) * k * 1.6
        let l = Int((12.5 - k * 4 + sway).rounded())
        c.rect(l, y, 24 - l, 1, fur)
        c.px(l, y, dark)
        if y % 4 == 1 { c.px(l - 1, y, dark) }                                                 // shaggy edge
        if y % 3 == 0 { c.px(l + 2, y, light) } else if y % 5 == 2 { c.px(l + 3, y, dark) }
        if y == last { for x in stride(from: l + 1, to: 24, by: 2) { c.px(x, y, dark) } }
    }
}

/// Beorn's club in his fist at `angle`: a dark grip, and a knobbly oak cudgel thickening toward its head, a lighter
/// grain along one side and knots standing out of it.
private func drawClub(_ c: PixelCanvas, angle: Double) {
    let wood = C(0x6A4A2A), dark = C(0x4A3220), light = C(0x8E6E44)
    let h = beornFist, u = unit(angle), n = (x: -u.y, y: u.x)
    line(c, h.x - u.x * 3, h.y - u.y * 3, h.x + u.x * 4, h.y + u.y * 4, dark, 0.8)
    var d = 3.5
    while d < 15 {
        let r = 0.9 + (d - 3.5) / 11.5 * 1.4
        line(c, h.x + u.x * d, h.y + u.y * d, h.x + u.x * (d + 1.5), h.y + u.y * (d + 1.5), wood, r)
        d += 1.5
    }
    line(c, h.x + u.x * 6 + n.x * 0.9, h.y + u.y * 6 + n.y * 0.9, h.x + u.x * 14 + n.x * 1.7, h.y + u.y * 14 + n.y * 1.7,
         light, 0.35)
    for (kd, side) in [(8.5, -1.0), (12.5, 1.0), (15.5, -0.5)] {
        let r = 0.9 + (kd - 3.5) / 11.5 * 1.4 + 0.8
        c.px(Int((h.x + u.x * kd + n.x * side * r).rounded(.down)), Int((h.y + u.y * kd + n.y * side * r).rounded(.down)), dark)
    }
}

// MARK: - Quicksort

/// Where Quicksort's branch arm swings from: his front shoulder, half again as high as a Man's hand.
private let quickbeamShoulder: (x: Double, y: Double) = (35.5, 20.5)

/// Quicksort, the hasty young Ent, half again a Man's height: a rowan, tall, slim and straight, his bark smooth and
/// silver-grey with the rowan's little horizontal marks on it (no furrows, no moss, no beard); two slender trunk legs on
/// small root feet; an oval head held up and forward, wide bright eyes glowing a warm Clawd orange under arched brows,
/// a twig of a nose and a ruddy grin; a crown of bright green rowan leaves swept back off his head as if he's been
/// running, red berry clusters in it. His back arm is a slim branch hanging from the shoulder with a sprig and berries
/// at its end; the front one is his weapon: at rest it hangs forward beside him, and to fight he swats with it, quick,
/// a short green smear behind it. Signature: a hasty quicksort: swaying fast from side to side, he sets out his rowan
/// berries in front of him as five little stacks, jumbled, then flicks them into order round a bright pivot stack, and
/// once they stand in a neat row, short to tall, he stops, pleased, and they fade.
private func drawQuickbeam(_ c: PixelCanvas, _ p: Pose) {
    let bark = C(0x8A7C6C), barkDark = C(0x66594C), barkLight = C(0xA49684), mark = C(0x74685A)
    let leaf = C(0x4CB83A), leafLight = C(0x8AE05A), leafDark = C(0x2E8A2A)
    let berry = C(0xE0321E), berryDark = C(0xA0200E)
    // Two slender trunk legs on small root feet.
    for (i, lx) in [23, 30].enumerated() {
        let up = p.step >= 0 && i == p.step ? 1 : 0
        c.rect(lx, 32, 4, 10 - up, i == 0 ? barkDark : bark)
        c.rect(lx, 32, 1, 9 - up, i == 0 ? bark : barkLight)
        c.rect(lx + 1, 35, 2, 1, mark); c.rect(lx + 2, 38, 2, 1, mark)
        c.pattern(lx - 2, 41 - up, ["..RRRR..", ".RRRRRR.", "R.R..R.R"], ["R": i == 0 ? mark : barkDark])
    }
    // In his signature he sways fast from side to side above the legs, sorting.
    let sway = p.signature.map { s in Int((2 * sin(s * .pi * 16) * arc(s, rise: 0.05, fall: 0.6)).rounded()) } ?? 0
    c.ox += sway
    c.oy += p.breathe
    // The back arm: a slim branch hanging from the shoulder, twig fingers, a sprig and berries at its end.
    line(c, 23, 20, 17, 31, barkDark, 1)
    line(c, 17, 31, 14, 35, mark, 0.45); line(c, 17, 31, 16, 36, mark, 0.45); line(c, 17.5, 31, 19, 35, mark, 0.45)
    c.pattern(12, 34, ["L.l.", ".L.L", "LdL."], ["L": leaf, "l": leafLight, "d": leafDark])
    c.pattern(18, 32, [".R", "Rr"], ["R": berry, "r": berryDark])
    // The trunk: tall, slim and straight, smooth silver-grey bark with the rowan's little horizontal marks.
    let trunk: [(l: Int, r: Int)] = [
        (22, 36), (21, 36), (21, 36), (21, 35), (22, 35), (22, 35), (22, 34), (22, 34), (23, 34), (23, 34), (23, 34),
        (23, 34), (23, 34), (23, 34), (23, 34), (23, 34),
    ]
    for (i, row) in trunk.enumerated() {
        let y = 18 + i
        c.rect(row.l, y, row.r - row.l + 1, 1, bark)
        c.px(row.l, y, barkLight); c.px(row.l + 1, y, barkLight); c.px(row.r, y, barkDark)
    }
    for (x, y) in [(25, 21), (30, 22), (27, 25), (31, 27), (25, 29), (29, 31)] { c.rect(x, y, 2, 1, mark) }
    // A few leaves sprouting at the shoulders.
    c.pattern(20, 16, ["..l.", ".LL.", "Ld.L"], ["L": leaf, "l": leafLight, "d": leafDark])
    // The neck and the head, held up and forward: an oval of smooth bark.
    c.rect(27, 16, 5, 3, bark); c.rect(31, 16, 1, 3, barkDark)
    let head: [(l: Int, r: Int)] = [(29, 35), (27, 37), (26, 38), (26, 38), (26, 38), (26, 38), (26, 38), (26, 38), (27, 37),
                                    (28, 36)]
    for (i, row) in head.enumerated() {
        let y = 7 + i
        c.rect(row.l, y, row.r - row.l + 1, 1, bark)
        c.px(row.l, y, barkLight); c.px(row.r, y, barkDark)
    }
    // Arched brows, wide bright eyes, a twig of a nose and a ruddy grin.
    c.pattern(27, 9, [".BB...BB.", "B..B.B..B"], ["B": barkDark])
    let glow: Double = 0.85 + 0.15 * sin(p.lt * 2.1)
    for ex in [28, 33] {
        c.rect(ex, 11, 3, 3, C(0x3A362E))
        c.rect(ex + 1, 11, 2, 2, C(0xFFC070).alpha(glow)); c.px(ex + 2, 12, clawdOrange.alpha(glow))
        c.px(ex + 1, 11, C(0xFFF0C8).alpha(glow))
    }
    c.rect(38, 12, 2, 1, bark); c.px(39, 11, barkDark); c.px(38, 13, barkDark)
    c.px(30, 14, C(0x8A2A1A)); c.rect(31, 15, 3, 1, C(0xC8503A)); c.px(34, 14, C(0x8A2A1A))
    // The crown of bright rowan leaves, swept back off his head, red berries in it.
    c.pattern(17, 2, [
        "........LL.LlL.LL......",
        ".....LLlLLLRLLLLlLL....",
        "..LdLLLLLRRrLLLLdLLLL..",
        "LLLlLLdLLLRLLLLLRRLlLL.",
        ".LLLLRLLLdLLLLLRrRLLLLL",
        "...LRrRLLLLlLLdLRLLLLL.",
        "LLLLLRLLLL.LLLLLL..LLL.",
        ".LLL......L....L.......",
        "..L....................",
    ], ["L": leaf, "l": leafLight, "d": leafDark, "R": berry, "r": berryDark])
    // The front arm, his weapon: a slim branch from the shoulder, hanging forward at rest, swatting in a fight, quick.
    let flick = p.signature.map { s in s < 0.1 || s > 0.62 ? 0 : 26 * abs(sin(s * .pi * 12)) * arc(s, rise: 0.12, fall: 0.55) } ?? 0
    let angle = p.melee ?? 64 - flick
    for (i, a) in (p.melee == nil ? [] : p.trail).enumerated() {
        let u = unit(a), s = quickbeamShoulder
        c.glowLine(s.x + u.x * 5, s.y + u.y * 5, s.x + u.x * 18, s.y + u.y * 18, core: C(0xD8F4C0), glow: C(0x6AC84A),
                   coreR: 0.6, glowR: 1.8, strength: 0.34 / Double(i + 1))
    }
    drawRowanArm(c, angle: angle, bark: bark, light: barkLight, dark: barkDark, leaf: leaf, leafLight: leafLight,
                 berry: berry, berryDark: berryDark)
    c.ox -= sway; c.oy -= p.breathe                                          // the berries stand on the floor
    if let s = p.signature { drawBerrySort(c, s, berry: berry, berryDark: berryDark) }
}

/// Quicksort's berries, `s` through his signature: five stacks set out jumbled one by one (0.08…), partitioned round
/// the pivot, which shines (0.4), sorted short to tall (0.54), a sparkle running along the neat row (0.6…), and gone
/// (0.82…).
private func drawBerrySort(_ c: PixelCanvas, _ s: Double, berry: Px, berryDark: Px) {
    guard s >= 0.08, s < 0.97 else { return }
    let jumbled = [3, 1, 5, 2, 4], partitioned = [2, 1, 3, 5, 4], sorted = [1, 2, 3, 4, 5]
    let row = s < 0.4 ? jumbled : s < 0.54 ? partitioned : sorted
    let fade = s > 0.82 ? 1 - (s - 0.82) / 0.15 : 1
    let shine = C(0xFF8A6A)
    for (i, h) in row.enumerated() {
        guard s >= 0.08 + 0.05 * Double(i) else { continue }                 // set out one at a time
        let pivot = h == 3 && s >= 0.36 && s < 0.6
        let moved = (s >= 0.4 && s < 0.44 && partitioned[i] != jumbled[i]) || (s >= 0.54 && s < 0.58 && sorted[i] != partitioned[i])
        let x = 46 + 3 * i, hop = moved ? 1 : 0
        for j in 0..<h {
            c.pattern(x, 42 - 2 * j - hop, [".R", "Rr"], ["R": (pivot ? shine : berry).alpha(fade), "r": berryDark.alpha(fade)])
        }
    }
    if s >= 0.6 && s < 0.78 {                                                // done: a sparkle runs along the row
        let k = (s - 0.6) / 0.18, x = 46 + 14 * k, y = 41 - 9 * k
        c.glowLine(x - 1.5, y, x + 1.5, y, core: C(0xFFFFFF), glow: C(0xFFE8A0), coreR: 0.3, glowR: 1.2, strength: 0.9)
        c.glowLine(x, y - 1.5, x, y + 1.5, core: C(0xFFFFFF), glow: C(0xFFE8A0), coreR: 0.3, glowR: 1.2, strength: 0.9)
    }
}

/// Quicksort's front arm at `angle` from his shoulder: a slim branch, a little thicker at the shoulder, a sprig of
/// rowan leaves and a berry cluster near its end, and three twig fingers.
private func drawRowanArm(_ c: PixelCanvas, angle: Double, bark: Px, light: Px, dark: Px, leaf: Px, leafLight: Px,
                          berry: Px, berryDark: Px) {
    let s = quickbeamShoulder, u = unit(angle), n = (x: -u.y, y: u.x)
    func at(_ d: Double, _ o: Double = 0) -> (x: Double, y: Double) { (s.x + u.x * d + n.x * o, s.y + u.y * d + n.y * o) }
    func dot(_ q: (x: Double, y: Double), _ col: Px) { c.px(Int(q.x.rounded(.down)), Int(q.y.rounded(.down)), col) }
    let a = at(0), b = at(8), e = at(15)
    line(c, a.x, a.y, b.x, b.y, bark, 1.2)
    line(c, b.x, b.y, e.x, e.y, bark, 0.8)
    let h0 = at(1, -0.8), h1 = at(12, -0.6)
    line(c, h0.x, h0.y, h1.x, h1.y, light, 0.3)
    for spread in [-30.0, 0, 30] {
        let f = unit(angle + spread)
        line(c, e.x, e.y, e.x + f.x * 3.5, e.y + f.y * 3.5, dark, 0.45)
    }
    // A sprig of leaves off the arm, and a berry cluster.
    for k in 0..<4 {
        dot(at(9 + Double(k), -1.5 - Double(k % 2)), k % 2 == 0 ? leaf : leafLight)
        dot(at(9.5 + Double(k), 1.5 + Double(k % 2)), k % 2 == 0 ? leafLight : leaf)
    }
    dot(at(6, 1.8), berry); dot(at(6.8, 2.6), berryDark); dot(at(5.6, 2.8), berry)
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

/// Smoothstep: 0→1 eased at both ends (clamped).
private func smooth(_ x: Double) -> Double {
    let k = min(1, max(0, x))
    return k * k * (3 - 2 * k)
}

/// A signature's envelope `s` through it: eased up from 0 to 1 by `rise`, held, and eased back to 0 from `fall` to the
/// end, so the move starts and ends in the idle look.
private func arc(_ s: Double, rise: Double, fall: Double) -> Double {
    s < rise ? smooth(s / rise) : s < fall ? 1 : 1 - smooth((s - fall) / (1 - fall))
}

private func unit(_ degrees: Double) -> (x: Double, y: Double) {
    let r: Double = degrees * .pi / 180
    return (cos(r), sin(r))
}

/// The angles a heavy swing smears through: from now back past `trail`'s last angle by half as far again, so the smear
/// is longer than a sword's (the weapon looks slower, heavier). Empty when it isn't being swung fast.
private func heavySmear(_ now: Double, _ trail: [Double]) -> [Double] {
    guard let last = trail.last else { return [] }
    let end: Double = last + (last - now) * 0.5
    let n = max(2, Int((abs(end - now) / 5).rounded()))
    return (1...n).map { (i: Int) -> Double in now + (end - now) * Double(i) / Double(n) }
}
