import Foundation

// Heroes: the rest of the Fellowship and the Lady of the wood. Every one of them is Clawd in costume: the wizard's hat
// and beard, the ranger's coat, the elf's hair, the dwarf's helmet and beard, the captain's fur collar, the Lady's gown,
// drawn over and around the blocky body. The face is Clawd's own orange, and the eyes stay ink. Gimmie is drawn
// shorter than the Men and broader (`headTop` and his axe hand moved to match); the rest stand Clawd's full height.
// Stride-r is Arrogorn again, hooded and rougher, drawn by the same function (as the White is drawn by the Grey's).

let ringsHeroes2: [RingsHero: Persona] = [
    .gandalf: Persona(name: "Gandclawd the Grey", weapon: .saber, pivot: gandalfHand, headTop: 12, signature: 3.0, callout: "A wizard is never late.", draw: drawGandalf),
    .aragorn: Persona(name: "Arrogorn", weapon: .saber, headTop: 20, signature: 3.4, callout: "For Frodough!", draw: drawAragorn),
    .legolas: Persona(name: "Leggolas", weapon: .blaster, shot: .arrow, muzzle: (46, 34), handGun: false, headTop: 20,
                      signature: 3.0, callout: "A red sun rises.", draw: drawLegolas),
    .gimli: Persona(name: "Gimmie, son of Groan", weapon: .saber, pivot: gimliHand, headTop: 25, signature: 2.6,
                    callout: "And my axe!", draw: drawGimli),
    .boromir: Persona(name: "Boromeme", weapon: .saber, headTop: 20, signature: 3.4, callout: "One does not simply push to main.",
                      draw: drawBoromir),
    .galadriel: Persona(name: "Gladriel", weapon: .saber, motion: .hover, headTop: 19, signature: 3.0, callout: "Even the smallest Clawd can change the course of the future.",
                        draw: drawGaladriel),
    .gandalfWhite: Persona(name: "Gandclawd the White", weapon: .saber, pivot: gandalfHand, headTop: 21, signature: 3.0, callout: "I come back to you now… after a hard reboot.",
                           draw: drawGandalfWhite),
    .strider: Persona(name: "Stride-r", weapon: .saber, headTop: 17, signature: 3.2, callout: "Long strides, Mr. Underhill. Cache-friendly ones.",
                      draw: drawStrider),
]

// MARK: - Gandclawd

/// The knot at the head of his staff, held upright in front of him.
private let gandalfStaffHead: (x: Double, y: Double) = (44.5, 15.5)

/// The fist he swings the staff from, in front of him (at rest it stands in his other hand, behind).
private let gandalfHand: (x: Double, y: Double) = (43.5, 34.5)

/// When the staff hits the floor in his signature.
private let gandalfImpact = 0.29

/// What tells Gandclawd the Grey from Gandclawd the White: the colours of the robe, hair, beard, boots and staff, the
/// light at the staff's head, and whether he wears the pointy hat.
private struct WizardLook {
    let robe: Px, robeShade: Px, robeLight: Px
    let beard: Px, beardShade: Px, beardEdge: Px, hair: Px, hairShade: Px
    let boots: Px
    let wood: Px, woodDark: Px, woodLight: Px
    let glow: StaffGlow
    let hat: Bool
}

private let greyWizard = WizardLook(robe: C(0x8A8C92), robeShade: C(0x5E6066), robeLight: C(0xA2A4AA),
                                    beard: C(0xD8D8D4), beardShade: C(0xB0B0AA), beardEdge: C(0x9C9C96),
                                    hair: C(0xC4C4C0), hairShade: C(0x9C9C98), boots: C(0x3A3632),
                                    wood: C(0x6A4A2A), woodDark: C(0x4A321C), woodLight: C(0x8A6A44),
                                    glow: StaffGlow(core: C(0xFFFFFF), glow: C(0xBFD8FF)), hat: true)

private let whiteWizard = WizardLook(robe: C(0xE4E8EE), robeShade: C(0xA8B0BE), robeLight: C(0xFFFFFF),
                                     beard: C(0xFFFFFC), beardShade: C(0xDCDCD8), beardEdge: C(0x9AA2B0),
                                     hair: C(0xF8F8F6), hairShade: C(0xCCCED2), boots: C(0x9A9EA6),
                                     wood: C(0xE6E0D0), woodDark: C(0x9C9484), woodLight: C(0xFFFFFF),
                                     glow: StaffGlow(core: C(0xFFFFFF), glow: C(0xFFFFFF)), hat: false)

/// Gandclawd the Grey: a grey robe to the ankles, a tall crooked pointy hat with a wide brim, its tip bent back, grey
/// hair under it, bushy brows and a long white-grey beard over the chest. A gnarled wooden staff stands in his off
/// hand, always, planted on the floor, a soft white-blue light round its head; to fight he brings it round into his
/// front hand and swings it like a sword, the light brighter and smeared along a fast stroke. Signature: "You shall not pass!": he raises the staff high in both hands (…0.25), slams
/// it down (the floor shakes, a white shock ring spreads out over it from the staff's foot and, for a frame, he flashes
/// white), and holds it there, planted, while the ring fades.
private func drawGandalf(_ c: PixelCanvas, _ p: Pose) {
    guard let s = p.signature else { drawGandalfBody(c, p, greyWizard, sig: nil); return }
    let ring: Double? = s >= gandalfImpact ? (s - gandalfImpact) / (1 - gandalfImpact) : nil
    if let k = ring { drawShockRing(c, k, front: false) }
    let oy = c.oy
    if s >= gandalfImpact && s < gandalfImpact + 0.025 {
        layer(c, flash: 0.75) { drawGandalfBody($0, p, greyWizard, sig: s) }
    } else {
        drawGandalfBody(c, p, greyWizard, sig: s)
    }
    c.oy = oy
    if let k = ring { drawShockRing(c, k, front: true) }
}

/// Gandclawd the White, come back: the Grey's drawing in white. A white robe to the ankles, pale grey shoes, no hat
/// at all: a bushy crown of white hair swept back off the brow and down to the shoulders, white brows and a long
/// white beard. His staff is white wood now, the same gnarled twist at its head, and its light is pure white.
/// Signature: "I come back to you now": he raises the staff high in both hands (…0.2), its light gathering, and it
/// bursts (0.3): a blinding white flash spreads out from its head in rays, washing him white, and fades while he holds
/// it up; he lowers it at the end.
private func drawGandalfWhite(_ c: PixelCanvas, _ p: Pose) {
    guard let s = p.signature else { drawGandalfBody(c, p, whiteWizard, sig: nil); return }
    let head = (x: gandalfStaffHead.x, y: gandalfStaffHead.y - gandalfRaise(s).rounded() + Double(p.breathe))
    let burst: Double? = s >= gandalfFlash && s < gandalfFlash + 0.4 ? (s - gandalfFlash) / 0.4 : nil
    if let k = burst { drawWhiteBurst(c, at: head, k, front: false) }
    let oy = c.oy
    if let k = burst {
        layer(c, flash: 0.95 * (1 - k) * (1 - k)) { drawGandalfBody($0, p, whiteWizard, sig: s, slam: false) }
    } else {
        drawGandalfBody(c, p, whiteWizard, sig: s, slam: false)
    }
    c.oy = oy
    if s > 0.14 && s < gandalfFlash {
        // The light gathering at the staff's head before it bursts.
        let k = (s - 0.14) / (gandalfFlash - 0.14)
        c.glowLine(head.x, head.y, head.x, head.y, core: white, glow: C(0xF4F8FF), coreR: 0.8 + k, glowR: 2.5 + 3 * k,
                   strength: 0.5 + 0.5 * k)
    }
    if let k = burst { drawWhiteBurst(c, at: head, k, front: true) }
}

/// When the White's staff bursts into light in his signature.
private let gandalfFlash = 0.3

/// How high the White lifts his staff `s` through his signature: raised (…0.2), held up, lowered (0.8…).
private func gandalfRaise(_ s: Double) -> Double {
    if s < 0.2 { return 10 * smooth(s / 0.2) }
    if s < 0.8 { return 10 }
    return 10 * (1 - smooth((s - 0.8) / 0.2))
}

/// The White's flash, `k` 0…1 through spreading out from the staff's head `at` and fading: a great soft glow behind
/// him, and in front, rays of light and the blinding core.
private func drawWhiteBurst(_ c: PixelCanvas, at: (x: Double, y: Double), _ k: Double, front: Bool) {
    let fade: Double = (1 - k) * (1 - k), grow: Double = 1 - (1 - k) * (1 - k) * (1 - k)
    guard front else {
        c.glowLine(at.x - 8, at.y + 14, at.x - 8, at.y + 14, core: C(0xFFFFFF, 0.5), glow: C(0xF0F4FF), coreR: 3 + 8 * grow,
                   glowR: 8 + 12 * grow, strength: 0.85 * fade)
        return
    }
    for i in 0..<12 {
        let u = unit(Double(i) * 30 + 15 * k), long: Double = i % 2 == 0 ? 1 : 0.6
        let r0: Double = 2 + 4 * grow, r1: Double = r0 + (5 + 16 * grow) * long
        c.glowLine(at.x + u.x * r0, at.y + u.y * r0, at.x + u.x * r1, at.y + u.y * r1, core: white, glow: C(0xE8F0FF),
                   coreR: 0.4, glowR: 1.2, strength: fade)
    }
    c.glowLine(at.x, at.y, at.x, at.y, core: white, glow: white, coreR: 2.5 * (1 - k) + 0.5, glowR: 4 + 3 * (1 - k),
               strength: 0.4 + 0.6 * fade)
}

/// How high the staff is lifted `s` through the signature: raised (…0.2), held up, slammed down (…the impact).
private func gandalfLift(_ s: Double) -> Double {
    if s < 0.2 { return 9 * smooth(s / 0.2) }
    if s < 0.25 { return 9 }
    if s < gandalfImpact { let u = (s - 0.25) / (gandalfImpact - 0.25); return 9 * (1 - u * u) }
    return 0
}

/// Gandclawd in the look `w`, the Grey or the White, `sig` through his signature: the Grey's staff slam (`slam`), or
/// the White's raised staff.
private func drawGandalfBody(_ c: PixelCanvas, _ p: Pose, _ w: WizardLook, sig: Double?, slam: Bool = true) {
    let robe = w.robe, robeShade = w.robeShade, robeLight = w.robeLight
    let beard = w.beard, beardShade = w.beardShade, hair = w.hair, hairShade = w.hairShade
    // In the signature the staff comes round in front, held up; fighting it's swung from his front hand.
    let forward = sig != nil || p.zap != nil || p.armRaise > 0
    let swing = sig == nil && !p.walking && !p.seated ? p.melee : nil
    let up = sig.map { Int((slam ? gandalfLift($0) : gandalfRaise($0)).rounded()) } ?? p.armRaise
    let blow = slam ? sig : nil                                               // the slam's jolt and smear
    // The staff passes from his off hand to the front over the move's first moments, and back over its last.
    let handover: Double = sig.map { min(1, min($0, 1 - $0) / 0.1) } ?? 1
    drawLegs(c, Look(leg: robeShade), step: p.step)
    drawBoots(c, p.step, w.boots, rows: 1)
    c.oy += p.breathe
    if let s = blow, s >= gandalfImpact, s < gandalfImpact + 0.06 { c.oy += 1 }   // the jolt of the blow
    func offHand(_ c: PixelCanvas) {
        drawStaffGlow(c, at: (12.5, 15.5), w.glow, bright: false, t: p.t)
        drawGandalfStaff(c, w)
        drawStaffGlow(c, at: (12.5, 15.5), w.glow, bright: false, t: p.t, front: true)
    }
    if !forward && swing == nil { offHand(c) } else if handover < 1 { faded(c, alpha: 1 - handover, offHand) }
    drawBody(c, Look(arm: robe))
    // The robe, the shoulders to the ankles, flaring a little, with a fold or two.
    c.rect(18, 32, 20, 6, robe)
    c.rect(37, 32, 1, 6, robeShade)
    for y in 38...41 where y + c.oy <= 43 {
        let k = y - 38, l = 17 - (k + 1) / 2, r = 38 + (k + 1) / 2
        c.rect(l, y, r - l + 1, 1, robe)
        c.px(l, y, robeLight); c.px(r, y, robeShade)
        c.px(24, y, robeShade); if y > 38 { c.px(32, y, robeShade) }
    }
    // Grey hair falling from under the brim to the shoulders, and bushy brows.
    c.pattern(16, 26, ["HHH", "HhH", "HHH", "hHH", "HHH", ".Hh", ".H."], ["H": hair, "h": hairShade])
    c.pattern(37, 26, ["HHH", "HhH", "HHH", "HHh", "HHH", "hH.", ".H."], ["H": hair, "h": hairShade])
    c.rect(21, 28, 4, 1, beard); c.rect(31, 28, 4, 1, beard)
    // The long beard over the robe, to a point below the belt (folded on his lap when he sits).
    let beardRows: [String] = [
        ".HHHHHHHHHHHHHH.",
        "HHHhHHHHHHHHhHHH",
        "bHHHHHHhHHHHHHHb",
        ".bHHhHHHHHHhHHb.",
        "..bHHHHHHhHHHb..",
        "..bHHhHHHHHHHb..",
        "...bHHHHHhHHb...",
        "....bHHHHHHb....",
        ".....bHhHHb.....",
        "......bHHb......",
    ]
    c.pattern(20, 32, Array(beardRows.prefix(max(0, 43 - c.oy - 32 + 1))), ["H": beard, "h": beardShade, "b": w.beardEdge])
    if w.hat {
        // The hat: a wide brim, a band and the tall crooked cone, its tip bent back.
        let hat = C(0x7A7C82), hatShade = C(0x5E6066), hatLight = C(0x96989E)
        let cone: [(y: Int, l: Int, r: Int)] = [
            (12, 17, 20), (13, 19, 23), (14, 21, 25), (15, 22, 27), (16, 23, 28), (17, 23, 29), (18, 23, 30), (19, 22, 31),
            (20, 22, 32), (21, 21, 33), (22, 21, 34),
        ]
        for row in cone {
            c.rect(row.l, row.y, row.r - row.l + 1, 1, hat)
            c.px(row.l, row.y, hatLight); c.px(row.r, row.y, hatShade)
        }
        c.rect(16, 13, 2, 1, hat); c.px(16, 14, hatShade)                    // the bent tip, hanging back
        c.rect(20, 23, 16, 1, hatShade)                                       // the band
        c.rect(14, 24, 28, 1, hat); c.px(14, 24, hatLight)
        c.rect(15, 25, 26, 1, hatShade)                                       // the brim's underside
    } else {
        // No hat: a bushy crown of hair over the head top, swept back off the brow into the hair at the sides.
        c.pattern(16, 21, [
            "......HHhHHHHHhHHH......",
            "...HHHHHHHHHHHHHHHHHH...",
            ".HHHhHHHHHHhHHHHHHHhHHH.",
            "HHHHHHHhHHHHHHHHhHHHHHHH",
            "HHhHHHHhHHhHHHHHhHHHHhHH",
        ], ["H": hair, "h": hairShade])
    }
    if let angle = swing {
        // Fighting: the staff swung from his front fist like a sword, the sleeve behind it and the fist over it.
        c.rect(38, 33, 4, 3, robe); c.rect(38, 35, 4, 1, robeShade)
        drawSwungStaff(c, hand: gandalfHand, head: gandalfStaffHead, angle: angle, trail: p.trail, glow: w.glow, t: p.t) {
            drawGandalfStaffForward($0, w, up: 0)
        }
        c.rect(42, 33, 3, 3, clawdOrange); c.px(42, 35, clawdShade)
        return
    }
    guard forward else { return }
    // The staff in front, the casting arm up along it (both hands on it in the signature), a smear over a slam.
    func inFront(_ c: PixelCanvas) {
        if let s = blow, s > 0.25, s < gandalfImpact + 0.02 {
            let before = gandalfLift(max(0, s - 0.03))
            c.glowLine(gandalfStaffHead.x, gandalfStaffHead.y - before, gandalfStaffHead.x, gandalfStaffHead.y - Double(up),
                       core: C(0xE8ECF4, 0.5), glow: clear, coreR: 1.6, glowR: 1.7)
        }
        let head = (x: gandalfStaffHead.x, y: gandalfStaffHead.y - Double(up))
        drawStaffGlow(c, at: head, w.glow, bright: true, t: p.t)
        drawGandalfStaffForward(c, w, up: up)
        drawStaffGlow(c, at: head, w.glow, bright: true, t: p.t, front: true)
        let reach = sig == nil ? 0 : 3                                        // the other hand, above it
        c.rect(38, 33 - up - reach, 4, 3 + up + reach, robe); c.rect(38, 35, 4, 1, robeShade)
        c.rect(42, 33 - up, 3, 3, clawdOrange); c.px(42, 35 - up, clawdShade)
        if reach > 0 { c.rect(42, 30 - up, 3, 3, clawdOrange); c.px(42, 32 - up, clawdShade) }
    }
    if handover < 1 { faded(c, alpha: handover, inFront) } else { inFront(c) }
}

/// Draws `art` on a layer of its own and lays it over `c` faded to `alpha`, as if drawn on `c` (its offsets kept).
private func faded(_ c: PixelCanvas, alpha: Double, _ art: (PixelCanvas) -> Void) {
    guard alpha > 0.02 else { return }
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    c.paste(s, x: -c.ox, y: -(c.oy + c.baseY), alpha: alpha)
}

/// Gandclawd's staff in his off hand: a gnarled shaft of old wood with a knot or two, its head a twist of roots, and
/// its foot on the floor (white wood for the White).
private func drawGandalfStaff(_ c: PixelCanvas, _ w: WizardLook) {
    let wood = w.wood, dark = w.woodDark, light = w.woodLight
    let bottom = 43 - c.oy
    c.pattern(10, 13, [
        ".DWW.",
        "W..WD",
        "W.W.W",
        ".WW.W",
        "...WW",
        "...W.",
    ], ["W": wood, "D": dark])
    c.px(11, 13, light); c.px(10, 14, light)
    c.rect(13, 19, 1, 8, wood)
    c.rect(14, 27, 1, max(0, bottom - 26), wood)
    c.px(13, 26, dark); c.px(14, 26, wood)
    c.px(13, 22, dark); c.px(14, 30, light); c.px(14, 38, dark); c.px(13, 23, light)
    c.rect(12, 33, 3, 3, clawdOrange); c.px(12, 35, clawdShade)               // his fist round it
}

/// The same staff brought round in front of him, lifted `up` pixels: the head turned forward, the shaft at x 43.
private func drawGandalfStaffForward(_ c: PixelCanvas, _ w: WizardLook, up: Int) {
    let wood = w.wood, dark = w.woodDark, light = w.woodLight
    let top = 13 - up, bottom = 43 - c.oy - up
    c.pattern(42, top, [
        ".WWD.",
        "DW..W",
        "W.W.W",
        "W.WW.",
        "WW...",
        ".W...",
    ], ["W": wood, "D": dark])
    c.px(45, top, light); c.px(46, top + 1, light)
    c.rect(43, top + 6, 1, max(0, bottom - top - 5), wood)
    c.px(43, top + 9, dark); c.px(43, top + 10, light); c.px(43, top + 17, light); c.px(43, top + 25, dark)
}

/// The shock ring of the staff's blow on the floor round its foot, `k` 0…1 through spreading out and fading. The far
/// half (`front: false`) goes behind him, the near half in front.
private func drawShockRing(_ c: PixelCanvas, _ k: Double, front: Bool) {
    let a: Double = pow(1 - k, 0.6)
    guard a > 0.03 else { return }
    let cx = 43.5, cy = 43.0
    let rx: Double = 2 + 25 * (1 - (1 - k) * (1 - k)), ry: Double = max(1, rx * 0.18)
    var prev: Int?
    for x in Int(floor(cx - rx))...Int(ceil(cx + rx)) {
        let u = (Double(x) + 0.5 - cx) / rx
        guard abs(u) <= 1 else { prev = nil; continue }
        let dy = ry * (1 - u * u).squareRoot()
        let y = Int((front ? cy + dy : cy - dy).rounded())
        let from = prev ?? y
        for yy in min(from, y)...max(from, y) where yy == y || abs(yy - y) < abs(from - y) {
            c.px(x, yy, C(0xFFFFFF, a))
            c.px(x, yy + (front ? -1 : 1), C(0xBFD8FF, a * 0.45))             // a softer edge inside
        }
        prev = y
    }
}

// MARK: - Wizards' staffs

// Shared with Sarumanual, Sharkey (RingsVillains1.swift) and Radagast (RingsHeroes6.swift): a wizard's staff throws
// no lightning, it glows at its head, and in a fight he swings it like a sword.

/// The light at the head of a wizard's staff: its colours, how strongly it shines (Sharkey's is dim), and whether it
/// sputters.
struct StaffGlow {
    let core: Px, glow: Px
    var strength = 1.0
    var sputters = false
}

/// The soft light round a staff's head at `at`, always on, `bright` while he fights or swings it. Draw it twice: behind
/// the head for the halo, then over it (`front`) for the light in its middle.
func drawStaffGlow(_ c: PixelCanvas, at: (x: Double, y: Double), _ g: StaffGlow, bright: Bool, t: Double, front: Bool = false) {
    var k: Double = g.strength * (0.88 + 0.12 * sin(t * 3.1))
    if g.sputters && noise(Int(t * 14)) < 0.35 { k *= 0.45 }                  // more often low than out
    if front {
        c.glowLine(at.x, at.y, at.x, at.y, core: g.core, glow: g.glow, coreR: 0.5, glowR: bright ? 1.6 : 1.1,
                   strength: k * (bright ? 0.6 : 0.35))
    } else {
        c.glowLine(at.x, at.y, at.x, at.y, core: g.glow, glow: g.glow, coreR: 0.8, glowR: bright ? 3.6 : 2.7,
                   strength: k * (bright ? 0.7 : 0.45))
    }
}

/// A wizard's staff swung from his fist at `hand` at `angle` (0 forward, -90 upright), its light bright and smeared
/// along `trail` behind a fast stroke. `art` draws the staff upright, held at `hand`, on a scratch canvas the size of
/// the sprite's (no offsets), and `head` is where its head is then: the drawing turns about the fist.
func drawSwungStaff(_ c: PixelCanvas, hand: (x: Double, y: Double), head: (x: Double, y: Double), angle: Double,
                    trail: [Double], glow g: StaffGlow, t: Double, _ art: (PixelCanvas) -> Void) {
    let reach = hypot(head.x - hand.x, head.y - hand.y)
    let lean: Double = atan2(head.y - hand.y, head.x - hand.x) * 180 / .pi + 90   // the head's lean off the shaft's line
    // A long staff isn't a sword. Wound back over his shoulder it stops a little past upright (further, it would go
    // through his head), and the floor stops it swung low; twirled round, it flips over from low in front to up behind.
    let low: Double = asin(min(1, (42 - hand.y) / reach)) * 180 / .pi
    let floored = { (a: Double) -> Double in
        let d = (a + 180).truncatingRemainder(dividingBy: 360)
        let n = (d < 0 ? d + 360 : d) - 180
        let held: Double
        if n > low && n < 90 { held = low }
        else if n >= 90 { held = -115 }
        else if n < -105 { held = -105 + (n + 105) * 10 / 75 }
        else { return a }
        return a - n + held
    }
    let angle = floored(angle), trail = trail.map(floored)
    // The smear: the head's light dragged round the arc it swept (from half-way up the shaft to the head).
    for (i, a) in heavySmear(angle, trail).enumerated() {
        let fade: Double = 0.34 * (1 - Double(i) / 10)
        guard fade > 0.03 else { break }
        guard floored(a) == a else { continue }
        let u = unit(a + lean)
        c.glowLine(hand.x + u.x * reach * 0.45, hand.y + u.y * reach * 0.45, hand.x + u.x * reach, hand.y + u.y * reach,
                   core: g.core, glow: g.glow, coreR: 0.5, glowR: 1.6, strength: fade * g.strength)
    }
    let u = unit(angle + lean), tip = (x: hand.x + u.x * reach, y: hand.y + u.y * reach)
    drawStaffGlow(c, at: tip, g, bright: true, t: t)
    let s = PixelCanvas(c.w, c.h)
    art(s)
    let r = s.rotated(angle + 90, about: hand, into: c.w, c.h, at: hand)
    for y in 0..<r.h {
        for x in 0..<r.w {
            let i = (y * r.w + x) * 4
            guard r.buf[i + 3] > 0 else { continue }
            c.px(x, y, unpremultiplied(r, i))
        }
    }
    drawStaffGlow(c, at: tip, g, bright: true, t: t, front: true)
}

// MARK: - Arrogorn and Stride-r

/// What tells Arrogorn from Stride-r, the same ranger in a rougher state: the colours of the coat, cloak, trousers and
/// boots, and whether the hood is up (with the pipe, the sword at his hip and the broken blade that go with it).
private struct RangerLook {
    let coat: Px, coatShade: Px, coatLight: Px
    let cloak: Px, cloakEdge: Px
    let trousers: Px, boots: Px
    let hooded: Bool
}

private let kingRanger = RangerLook(coat: C(0x3A3A32), coatShade: C(0x2A2A24), coatLight: C(0x4E4E44),
                                    cloak: C(0x262A20), cloakEdge: C(0x181A14),
                                    trousers: C(0x3E3428), boots: C(0x241A12), hooded: false)

private let breeRanger = RangerLook(coat: C(0x3C382E), coatShade: C(0x2A2720), coatLight: C(0x4C463A),
                                    cloak: C(0x4A4034), cloakEdge: C(0x2E281E),
                                    trousers: C(0x3A3026), boots: C(0x3A2C1E), hooded: true)

/// Arrogorn, the ranger: a weathered green-brown coat to mid-thigh over dark trousers and boots, a leather baldric across
/// the chest, a dark cloak, dark shaggy hair to the shoulders and two dark pixels of stubble on the jaw. His long sword
/// is slung across his back, the hilt over his shoulder; to fight he draws it, and it swings in his fist with a smear
/// behind a fast stroke. Signature: the helmet. An orc helmet lies at his feet; he draws his foot back and kicks it
/// (0.24), and it flies off spinning, out of sight. A beat, and the pain arrives: he doubles over, eyes screwed shut,
/// mouth open in a howl, the kicked foot clutched up in front of him and smarting (…0.88), and straightens up.
private func drawAragorn(_ c: PixelCanvas, _ p: Pose) {
    guard let s = p.signature else { drawRanger(c, p, kingRanger); return }
    let k = aragornKick(s)
    let (ox, oy) = (c.ox, c.oy)
    drawRanger(c, p, kingRanger, kick: k)
    c.ox = ox; c.oy = oy
    if k.leg == .held {
        // The kicked foot, clutched up in front of him, and the pain at its toe.
        let by = 39 + p.breathe + k.bend - 3
        c.rect(39, by, 3, 2, kingRanger.boots); c.px(42, by + 1, kingRanger.boots); c.px(39, by, C(0x3A2C20))
        c.rect(39, by - 1, 3, 1, clawdOrange)
        if Int(s * 3.4 * 7) % 2 == 0 {
            c.pattern(42, by - 4, ["Y.Y", ".W.", "Y.Y"], ["Y": C(0xFFD860), "W": white])
        } else {
            c.pattern(42, by - 4, [".Y.", "YWY", ".Y."], ["Y": C(0xFFD860), "W": white])
        }
    }
    if let h = orcHelmetFlight(s) {
        prop(c, at: (h.x, h.y), angle: h.angle, alpha: h.alpha) { drawOrcHelmet($0) }
    }
}

/// When Arrogorn's foot meets the helmet.
private let aragornKickAt = 0.24

/// What Arrogorn's kicking leg is doing: standing, drawn back, kicked out, or held up, smarting.
private enum KickLeg { case planted, back, out, held }

/// Arrogorn `s` through his signature: the kicking leg, how far he's doubled over (px), and whether he's howling.
private func aragornKick(_ s: Double) -> (leg: KickLeg, bend: Int, howl: Bool) {
    let leg: KickLeg = s < 0.15 ? .planted : s < aragornKickAt - 0.005 ? .back : s < 0.36 ? .out : s < 0.88 ? .held : .planted
    let k: Double = s < 0.36 ? 0 : s < 0.42 ? (s - 0.36) / 0.06 : s < 0.86 ? 1 : max(0, 1 - (s - 0.86) / 0.06)
    return (leg, Int((3 * k).rounded()), s >= 0.38 && s < 0.87)
}

/// The orc helmet `s` through Arrogorn's signature, where it is, turned, and how solid (it fades in at his feet before
/// he kicks it); nil once it's flown out of sight.
private func orcHelmetFlight(_ s: Double) -> (x: Double, y: Double, angle: Double, alpha: Double)? {
    let rest = (x: 46.5, y: 40.5)
    if s < aragornKickAt { return (rest.x, rest.y, 0, min(1, s / 0.06)) }
    let u = (s - aragornKickAt) / 0.2
    guard u < 1 else { return nil }
    return (rest.x + 34 * u, rest.y - 30 * sin(u * .pi * 0.75), -900 * u, 1)
}

/// A battered orc helmet, upright, its middle at (20.5, 20.5) of a prop canvas: a dented iron dome with a spike on top
/// and a jagged, rusty rim.
private func drawOrcHelmet(_ s: PixelCanvas) {
    s.pattern(16, 17, [
        "....S....",
        "..DDIDD..",
        ".DIIiIID.",
        "DIIiIIIID",
        "DIIIIIIDD",
        "DDIIIIDDD",
        "R.RDRDR.R",
    ],["S": C(0x9A968E), "D": C(0x3E3C3A), "I": C(0x5C5852), "i": C(0x7E7A72), "R": C(0x6A3E26)])
}

/// Stride-r, the same ranger in the corner of the Prancing Ponytail: a weathered brown travelling cloak with the hood
/// up, the face shadowed under it and wisps of his dark hair at its edges, more stubble, a pipe smouldering in the
/// corner of his mouth (smoking when he's idle), mud on the coat and boots. His sword hangs at his hip in a plain
/// scabbard, no baldric; drawn, it's the broken blade, snapped off short with a jagged end. Signature: a smoke ring.
/// His hand comes up to the pipe and he draws on it, the bowl glowing (…0.25), then blows a fat smoke ring that
/// drifts up and fades, and a little one after it that sails through the middle of the first.
private func drawStrider(_ c: PixelCanvas, _ p: Pose) {
    drawRanger(c, p, breeRanger)
}

/// The ranger in the look `r`: Arrogorn, or Stride-r with the hood up; `kick`: Arrogorn's signature.
private func drawRanger(_ c: PixelCanvas, _ p: Pose, _ r: RangerLook,
                        kick: (leg: KickLeg, bend: Int, howl: Bool)? = nil) {
    let coat = r.coat, coatShade = r.coatShade, coatLight = r.coatLight
    let hair = C(0x2A2018), hairLight = C(0x46362A), leather = C(0x5A4430)
    drawBackCape(c, t: p.t, speed: p.capeSpeed, color: r.cloak, edge: r.cloakEdge, hem: 42)
    if let k = kick {
        drawKickLegs(c, r, k.leg)
    } else {
        drawLegs(c, Look(leg: r.trousers), step: p.step)
        drawBoots(c, p.step, r.boots, rows: 3)
    }
    if r.hooded { drawMud(c, p.step) }
    c.oy += p.breathe
    if let k = kick { c.oy += k.bend; c.ox += k.bend > 1 ? 1 : 0 }           // doubled over
    drawBody(c, Look(arm: coat, eye: kick?.howl == true ? nil : ink))
    // The coat: the collar to mid-thigh, open below the belt.
    c.rect(18, 33, 20, 5, coat)
    c.rect(37, 33, 1, 5, coatShade)
    c.rect(18, 33, 20, 1, coatLight)
    for y in 38...39 where y + c.oy <= 43 {
        c.rect(18, y, 20, 1, coat); c.px(27, y, coatShade); c.px(28, y, coatShade); c.px(37, y, coatShade)
    }
    c.rect(18, 36, 20, 1, leather); c.px(26, 36, C(0x9A8A6A))               // the belt and its buckle
    if r.hooded {
        drawStriderHood(c, r)
        drawPipe(c, p, puff: p.signature)
    } else {
        for i in 0..<5 { c.rect(33 - i * 3, 33 + i, 3, 1, leather) }          // the baldric
        c.rect(15, 33, 3, 3, coat)
        // The shaggy hair, to the shoulders, framing the face: a ragged fringe on the brow, the sides outside the face.
        c.pattern(16, 20, [
            ".....H.HHH.HHHH.HH.H....",
            "...HHHHHHHHHHHHHHHHHH...",
            ".HHHHlHHHHHHHHHHlHHHHHH.",
            ".HHlHHHHHlHHHHHHHHlHHHH.",
            ".HHHHHHHHHHHHHHHHHHHHHH.",
            "HHHHHHlHHHHHHlHHHHHHHHHH",
            "HHHHl..H......H.....HHHH",
            "HHH..................HHH",
            "HHl..................lHH",
            "HH....................HH",
            "HH....................HH",
            "Hl....................lH",
            "HH....................H.",
            "..H..................H.H",
        ], ["H": hair, "l": hairLight])
        c.px(25, 32, ink); c.px(30, 32, ink)                                 // the stubble
        if kick?.howl == true {
            // Howling: the eyes screwed shut, the mouth wide open.
            c.pattern(22, 29, ["X.........X.", ".X.......X..", "X.........X."], ["X": ink])
            c.rect(27, 32, 2, 2, C(0x3A1418)); c.px(27, 32, ink)
        }
    }
    guard let a = p.melee else { if r.hooded { drawHipSword(c) } else { drawBackSword(c) }; return }
    drawLongSword(c, angle: a, trail: p.trail, broken: r.hooded)
    c.rect(38, 33, 2, 3, coat); c.rect(40, 33, 2, 3, clawdOrange); c.px(40, 35, clawdShade)   // the fist round the grip
}

/// Stride-r's hood, up: rounded over the head with its peak sagging back, falling to the shoulders and framing the
/// face, which it shadows down to the eyes; strands of hair escape at its edges, and his stubble is thicker.
private func drawStriderHood(_ c: PixelCanvas, _ r: RangerLook) {
    let hood = r.cloak, shade = r.cloakEdge, light = C(0x5E5444), lining = C(0x1E1A14)
    let hair = C(0x2A2018)
    // Each row: the hood's extent, and the opening the face shows through (none above the brow).
    let rows: [(y: Int, l: Int, r: Int, open: (Int, Int)?)] = [
        (17, 22, 28, nil), (18, 20, 32, nil), (19, 18, 35, nil), (20, 17, 37, nil), (21, 16, 38, nil),
        (22, 15, 39, nil), (23, 15, 40, nil), (24, 15, 40, nil), (25, 15, 40, nil), (26, 15, 40, (21, 34)),
        (27, 15, 40, (20, 35)), (28, 15, 40, (20, 35)), (29, 15, 40, (20, 35)), (30, 15, 40, (20, 35)),
        (31, 15, 39, (20, 35)), (32, 15, 39, (20, 35)),
    ]
    for row in rows {
        guard let (ol, or) = row.open else {
            c.rect(row.l, row.y, row.r - row.l + 1, 1, hood)
            c.px(row.l, row.y, shade); c.px(row.r, row.y, shade)
            continue
        }
        // Either side of the face, the dark lining showing at the opening's edge.
        c.rect(row.l, row.y, ol - row.l, 1, hood)
        c.rect(or + 1, row.y, row.r - or, 1, hood)
        c.px(row.l, row.y, shade); c.px(row.r, row.y, shade)
        c.px(ol - 1, row.y, lining); c.px(or + 1, row.y, lining)
    }
    c.rect(21, 25, 14, 1, lining)                                             // the brim's dark underside
    // Light along the crown, and a fold down the back.
    for (x, y) in [(23, 18), (24, 18), (25, 18), (26, 19), (27, 19), (28, 19), (29, 20), (30, 20), (31, 21), (32, 22)] {
        c.px(x, y, light)
    }
    for y in 20...32 { c.px(17 + (y - 20) / 6, y, shade) }
    // The shadow the brim throws down to the eyes.
    c.rect(21, 26, 14, 1, C(0x000000, 0.6))
    c.rect(20, 27, 16, 1, C(0x000000, 0.45))
    c.rect(20, 28, 16, 1, C(0x000000, 0.25))
    for y in 27...30 { c.px(20, y, hair) }                                    // strands of hair at the hood's edges
    for y in 27...29 { c.px(35, y, hair) }
    c.px(21, 27, hair); c.px(34, 27, hair)
    for (x, y) in [(24, 32), (25, 32), (26, 32), (30, 32), (31, 32), (25, 31)] { c.px(x, y, C(0x6A3A28)) }   // the stubble
    c.rect(15, 33, 3, 3, r.coat)                                              // his off arm, under the hood
    for x in [15, 17, 19, 36, 38] { c.px(x, 33, hood) }                       // the hood's ragged edge on the shoulders
}

/// Stride-r's pipe, in the corner of his mouth: the stem slanting down to the bowl, its ember glowing, and (idle) a
/// thread of smoke rising and drifting back; `puff` through his signature, the smoke rings as well.
private func drawPipe(_ c: PixelCanvas, _ p: Pose, puff: Double?) {
    let stem = C(0x6A4A2A), bowl = C(0x7A5230), bowlShade = C(0x4A3018)
    for x in 28...31 { c.px(x, 32, stem) }
    c.px(32, 33, stem); c.px(33, 33, stem)
    c.rect(34, 32, 2, 3, bowl); c.px(35, 33, bowlShade); c.px(35, 34, bowlShade)
    let glow: Double = 0.7 + 0.3 * noise(Int(p.lt * 5))
    c.px(34, 32, C(0xFF8A3A, glow)); c.px(35, 32, C(0x2A1A10))
    if let s = puff { drawSmokeRings(c, s) }
    guard p.resting || p.mode == .thinking else { return }
    // The thread of smoke (thinned out while he blows his rings).
    let m: Double = puff.map { max(0, 1 - $0 / 0.08, ($0 - 0.92) / 0.08) } ?? 1
    for k in 0..<3 {
        let f = frac(p.lt * 0.45 + Double(k) / 3)
        let x = 34.5 - f * 3 + sin(p.lt * 2 + Double(k) * 2) * 1.2, y = 30 - f * 11
        c.px(Int(x.rounded()), Int(y.rounded()), C(0xC8C4BC, 0.55 * (1 - f) * m))
        if f > 0.4 { c.px(Int(x.rounded()) - 1, Int(y.rounded()), C(0xC8C4BC, 0.35 * (1 - f) * m)) }
    }
}

/// Stride-r `s` through his signature: his hand up at the bowl while he draws on the pipe, its ember flaring (…0.3),
/// then a fat smoke ring blown out (0.26) that drifts up, swells and fades, and a little one after it (0.44), quicker,
/// that sails up through the middle of the first.
private func drawSmokeRings(_ c: PixelCanvas, _ s: Double) {
    if s > 0.04 && s < 0.3 {
        let k: Double = min(1, (s - 0.04) / 0.06) * min(1, (0.3 - s) / 0.04)
        c.glowLine(34.5, 32.5, 34.5, 32.5, core: C(0xFFC870), glow: C(0xFF7A2A), coreR: 0.6, glowR: 2.2,
                   strength: k * (0.75 + 0.25 * sin(s * 60)))
        c.rect(38, 31, 3, 3, breeRanger.coat); c.rect(36, 32, 2, 2, clawdOrange); c.px(36, 33, clawdShade)   // the hand
    }
    if s > 0.22 && s < 0.34 {
        // The breath, puffed out ahead of the ring.
        let k = (s - 0.22) / 0.12
        for (dx, dy) in [(0, 0), (1, -1), (2, 0), (1, 1)] {
            c.px(37 + dx + Int(k * 2), 30 + dy, C(0xD8D4CC, 0.5 * (1 - k)))
        }
    }
    let u1 = (s - 0.26) / 0.74, u2 = (s - 0.44) / 0.5
    if u1 > 0 && u1 < 1 {
        smokeRing(c, x: 38 + 6 * u1, y: 30 - 22 * u1, r: 2 + 3.5 * u1, alpha: 0.85 * min(1, u1 / 0.06) * pow(1 - u1, 0.8))
    }
    if u2 > 0 && u2 < 1 {
        smokeRing(c, x: 38 + 7 * u2, y: 30 - 30 * u2, r: 0.9 + 0.5 * u2, alpha: 0.8 * min(1, u2 / 0.08) * pow(1 - u2, 0.9))
    }
}

/// A smoke ring round (`x`, `y`), `r` across, seen a little from below: its near (lower) half the brighter.
private func smokeRing(_ c: PixelCanvas, x: Double, y: Double, r: Double, alpha: Double) {
    let n = max(10, Int(r * 9))
    var done = Set<Int>()
    for i in 0..<n {
        let a: Double = Double(i) / Double(n) * 2 * .pi
        let px = Int((x + cos(a) * r).rounded(.down)), py = Int((y + sin(a) * r * 0.8).rounded(.down))
        guard done.insert((px + 100) * 1000 + py + 100).inserted else { continue }
        c.px(px, py, C(0xDEDAD2, alpha * (sin(a) > 0 ? 1 : 0.65)))
    }
}

/// Arrogorn's legs in his signature: three standing, the front one `leg`.
private func drawKickLegs(_ c: PixelCanvas, _ r: RangerLook, _ leg: KickLeg) {
    for lx in [19, 23, 31] { c.rect(lx, 36, 2, 8, r.trousers); c.rect(lx, 41, 2, 3, r.boots) }
    switch leg {
    case .planted:
        c.rect(35, 36, 2, 8, r.trousers); c.rect(35, 41, 2, 3, r.boots)
    case .back:
        // Drawn back for the kick, the foot off the floor behind the knee.
        c.rect(35, 36, 2, 3, r.trousers); c.rect(34, 38, 2, 2, r.trousers)
        c.rect(32, 39, 3, 3, r.boots)
    case .out:
        // Kicked out straight in front, the toe up.
        line(c, 36, 37.5, 40.5, 40.5, r.trousers, 1.0)
        c.rect(40, 39, 3, 2, r.boots); c.px(43, 39, r.boots)
    case .held:
        c.rect(35, 36, 2, 3, r.trousers)                                     // the rest is clutched up in front
    }
}

/// Mud splashed on Stride-r's boots and up the backs of his legs.
private func drawMud(_ c: PixelCanvas, _ step: Int) {
    guard !seatedPose else { return }
    let mud = C(0x5A4630)
    for (i, lx) in [19, 23, 31, 35].enumerated() {
        let bottom = step >= 0 && i % 2 == step ? 42 : 43
        c.px(lx, bottom - 3, mud); c.px(lx + 1, bottom - 1, mud)
        if i % 2 == 0 { c.px(lx + 1, bottom - 4, mud) }
    }
}

/// Arrogorn's long sword drawn, in his fist at `angle`: a leather grip and steel pommel, a steel crossguard and a long
/// (16 px) blade with a darker edge, and a pale smear along `trail` behind a fast stroke. `broken`: Stride-r's blade,
/// snapped off at 8 px with a jagged end (the smear is shorter too).
private func drawLongSword(_ c: PixelCanvas, angle: Double, trail: [Double], broken: Bool = false) {
    let hand = Sprite.hand, steel = C(0xC8D0D8), edge = C(0x8A929C)
    let tip: Double = broken ? 11 : 18
    for (i, a) in trail.enumerated() {
        let u = unit(a)
        c.glowLine(hand.x + u.x * 4, hand.y + u.y * 4, hand.x + u.x * tip, hand.y + u.y * tip, core: C(0xE8EEF4),
                   glow: C(0xA8B4C0), coreR: 0.5, glowR: 1.6, strength: 0.32 / Double(i + 1))
    }
    let u = unit(angle), n = (x: -u.y, y: u.x)
    line(c, hand.x - u.x * 2.5, hand.y - u.y * 2.5, hand.x + u.x * 1.5, hand.y + u.y * 1.5, C(0x3A2A1E), 0.7)   // the grip
    c.px(Int((hand.x - u.x * 3).rounded(.down)), Int((hand.y - u.y * 3).rounded(.down)), steel)                // the pommel
    line(c, hand.x + u.x * 3, hand.y + u.y * 3, hand.x + u.x * tip, hand.y + u.y * tip, steel, 0.75)
    line(c, hand.x + u.x * 3 + n.x * 0.6, hand.y + u.y * 3 + n.y * 0.6, hand.x + u.x * (tip - 1) + n.x * 0.6,
         hand.y + u.y * (tip - 1) + n.y * 0.6, edge, 0.3)
    if broken {
        // The jagged break: one shard standing proud on the edge side.
        let b = (x: hand.x + u.x * (tip + 1.2) + n.x * 0.7, y: hand.y + u.y * (tip + 1.2) + n.y * 0.7)
        c.px(Int(b.x.rounded(.down)), Int(b.y.rounded(.down)), edge)
    }
    let g = (x: hand.x + u.x * 2.5, y: hand.y + u.y * 2.5)
    line(c, g.x - n.x * 2.5, g.y - n.y * 2.5, g.x + n.x * 2.5, g.y + n.y * 2.5, C(0x8A8E96), 0.6)              // the crossguard
}

/// Stride-r's sword, sheathed at his hip: the scabbard sloping down and back behind his legs, the hilt forward of it.
private func drawHipSword(_ c: PixelCanvas) {
    let u = unit(150), n = (x: -u.y, y: u.x)
    let g = (x: 19.5, y: 35.5)                                               // the crossguard's middle
    line(c, g.x + u.x, g.y + u.y, g.x + u.x * 11, g.y + u.y * 11, C(0x2E241A), 0.8)   // the scabbard
    c.px(Int(g.x + u.x * 11.5), Int(g.y + u.y * 11.5), C(0x8A8E96))          // its chape
    line(c, g.x - u.x, g.y - u.y, g.x - u.x * 4, g.y - u.y * 4, C(0x3A2A1E), 0.6)   // the grip
    c.px(Int(g.x - u.x * 4.5), Int(g.y - u.y * 4.5), C(0xC8D0D8))             // the pommel
    line(c, g.x - n.x * 2, g.y - n.y * 2, g.x + n.x * 2, g.y + n.y * 2, C(0x8A8E96), 0.6)
}

/// Arrogorn's long sword, slung on his back: the pommel and grip over his shoulder, the crossguard, and the blade sloping
/// down and back behind him.
private func drawBackSword(_ c: PixelCanvas) {
    let steel = C(0xC8D0D8), edge = C(0x8A929C)
    let u = unit(120), n = (x: -u.y, y: u.x)
    let g = (x: 15.0, y: 24.0)                                               // the crossguard's middle
    line(c, g.x - u.x * 4, g.y - u.y * 4, g.x - u.x, g.y - u.y, C(0x3A2A1E), 0.6)   // the grip
    c.px(Int(g.x - u.x * 4.5), Int(g.y - u.y * 4.5), steel)                   // the pommel
    line(c, g.x + u.x, g.y + u.y, g.x + u.x * 16, g.y + u.y * 16, steel, 0.7)
    line(c, g.x + u.x + n.x * 0.6, g.y + u.y + n.y * 0.6, g.x + u.x * 15 + n.x * 0.6, g.y + u.y * 15 + n.y * 0.6, edge, 0.3)
    line(c, g.x - n.x * 2.5, g.y - n.y * 2.5, g.x + n.x * 2.5, g.y + n.y * 2.5, C(0x8A8E96), 0.6)
}

// MARK: - Leggolas

/// Leggolas, the elf: a green tunic, a light-grey cloak, soft boots, long straight blond hair to the shoulders with a
/// pointed ear poking out of it either side, a quiver of arrows on his back and a longbow in his hand, held out in
/// front of him. Shooting, he nocks an arrow and draws the string back before each shot. Signature: he surfs on a
/// shield: hops up onto it (…0.15), rides it sideways, arms out, sliding back and forth with a little bob, and hops
/// off again at the end.
private func drawLegolas(_ c: PixelCanvas, _ p: Pose) {
    let tunic = C(0x5E7A3A), tunicShade = C(0x46602A), tunicLight = C(0x7A9650)
    let hair = C(0xF0E0A0), hairShade = C(0xD0BC78)
    let surf = p.signature.map(legolasSurf)
    let ground = (x: c.ox, y: c.oy)
    if let s = surf { c.ox += s.dx; c.oy -= s.lift }
    drawBackCape(c, t: p.t, speed: p.capeSpeed, color: C(0xA8ACB0), edge: C(0x8A8E94), hem: 41)
    drawLegs(c, Look(leg: C(0x4A4A3A)), step: p.step)
    drawBoots(c, p.step, C(0x6A5232), rows: 3)
    if let s = surf {
        // The shield on the floor, sliding along under him.
        let (ox, oy) = (c.ox, c.oy)
        c.ox = ground.x + s.board; c.oy = ground.y
        drawSurfShield(c, alpha: s.shield)
        c.ox = ox; c.oy = oy
    }
    c.oy += p.breathe
    // The quiver, slung over his back, the fletchings over his shoulder.
    c.pattern(11, 18, [
        "W.G.....",
        "GW.W....",
        ".GWG....",
        "..QQQ...",
        "..QQQq..",
        "...QQQq.",
        "...QQQQ.",
        "....QQQq",
        "....QQQQ",
        ".....QQq",
        ".....QQQ",
    ], ["G": C(0x8AC86A), "W": C(0xE8E0D0), "Q": C(0x6A4A2A), "q": C(0x4E3420)])
    drawBody(c, Look(arm: tunic))
    c.rect(18, 32, 20, 6, tunic)
    c.rect(37, 32, 1, 6, tunicShade)
    c.rect(18, 32, 20, 1, tunicLight)
    for y in 38...39 where y + c.oy <= 43 { c.rect(18, y, 20, 1, tunic); c.px(37, y, tunicShade) }
    c.rect(18, 36, 20, 1, C(0x6A4A2A)); c.px(27, 36, C(0xC8D0D8))           // the belt
    for i in 0..<5 { c.rect(21 + i * 3, 37 - i, 3, 1, C(0x6A4A2A)) }          // the quiver strap
    if surf?.armsOut == true {
        c.rect(11, 31, 6, 2, tunic); c.rect(10, 31, 1, 2, clawdOrange)          // the back arm out, for balance
    } else {
        c.rect(15, 33, 3, 3, tunic)
    }
    // Long straight hair, parted in the middle, to the shoulders.
    c.pattern(16, 20, [
        ".......HHHHHHHHHH.......",
        "....HHHHHHHHHHHHHHHH....",
        "..HHHHHHHHHhHHHHHHHHHH..",
        ".HHHHHHHHHhhHHHHHHHHHHH.",
        ".HHhHHHHHHhHHHHHHHHHhHH.",
        "HHHhHHHHHh...hHHHHHHhHHH",
        "HHHhh..............hhHHH",
        "HHhH................HhHH",
        "HHh..................hHH",
        "HHh..................hHH",
        "HHh..................hHH",
        "HHh..................hHH",
        "HHh..................hHH",
        "HHh..................hHH",
        ".Hh..................hH.",
    ], ["H": hair, "h": hairShade])
    // The pointed ears, a pixel of skin past the hair.
    c.px(15, 28, clawdOrange); c.px(40, 28, clawdOrange)
    // The longbow, held out at arm's length; an arrow on the string while he aims, drawn back before he shoots.
    var pull = 0, nocked = p.ready
    if let f = p.fire {
        let ph = frac(f.t / p.firePeriod)
        nocked = ph >= 0.45
        if ph > 0.6 { pull = Int(((ph - 0.6) / 0.4 * 3).rounded()) }
    }
    let raise = seatedPose ? -3 : surf?.armsOut == true ? -2 : 0
    c.oy += p.gunY + raise
    drawLongbow(c, pull: pull)
    c.rect(38, 33, 4, 2, tunic)
    c.rect(42, 33, 2, 3, clawdOrange)
    if nocked {
        let tail = 40 - pull
        c.rect(tail, 34, 47 - tail, 1, C(0x6A4A2A))
        c.px(47, 34, C(0xC8CCD4)); c.px(48, 34, C(0xE8ECF4))
        c.px(tail, 33, C(0xC83A2A)); c.px(tail, 35, C(0xC83A2A))
        c.rect(tail - 1, 34, 2, 2, clawdOrange)                                // the hand on the string
    }
}

/// A tall wooden longbow gripped at (43, 34), the string back at x 40, drawn back `pull` pixels more at the middle.
private func drawLongbow(_ c: PixelCanvas, pull: Int = 0) {
    let limb = C(0x8A6A3A), limbDark = C(0x6A4E28), grip = C(0x4A3420), string = C(0xE0E0E8)
    for y in 24...44 where y + c.oy <= 43 {
        let d = abs(y - 34)
        let x = d <= 2 ? 44 : d <= 5 ? 43 : d <= 8 ? 42 : 41
        c.px(x, y, d <= 1 ? grip : d % 3 == 0 ? limbDark : limb)
        if d == 10 { c.px(x - 1, y, limb) }
    }
    for y in 25...43 where y + c.oy <= 43 {
        let d = Double(abs(y - 34)) / 9
        c.px(40 - Int((Double(pull) * (1 - d)).rounded()), y, string)
    }
}

/// Where Leggolas is `s` through his surf: shifted `dx` and lifted `lift` (on the shield, 3 px up), the shield shifted
/// `board` and faded to `shield`, and whether his arms are out for balance.
private func legolasSurf(_ s: Double) -> (dx: Int, lift: Int, board: Int, shield: Double, armsOut: Bool) {
    if s < 0.15 {
        let u = s / 0.15
        let lift: Double = 3 * smooth(u) + 5 * sin(u * .pi)
        return (0, Int(lift.rounded()), 0, min(1, s / 0.04), u > 0.3)
    }
    if s < 0.85 {
        let u = (s - 0.15) / 0.7
        let tau: Double = 2 * .pi
        let dx = Int((6 * sin(u * tau)).rounded())
        let bob = sin(u * tau * 5) > 0.4 ? 1 : 0
        return (dx, 3 + bob, dx, 1, true)
    }
    let u = (s - 0.85) / 0.15
    let lift: Double = 3 * (1 - smooth(u)) + 4 * sin(u * .pi)
    return (0, Int(lift.rounded()), 0, 1 - smooth(u), u < 0.7)
}

/// The shield he surfs on, lying on the floor under his feet: a wooden oval with a gold rim.
private func drawSurfShield(_ c: PixelCanvas, alpha: Double) {
    let wood = C(0x8A6A3A, alpha), dark = C(0x6A4E28, alpha), rim = C(0xC8A040, alpha), rimDark = C(0x9A7A2A, alpha)
    c.rect(19, 41, 18, 1, rim)
    c.rect(17, 42, 22, 1, wood); c.px(17, 42, rim); c.px(38, 42, rim)
    c.rect(22, 42, 1, 1, dark); c.rect(33, 42, 1, 1, dark); c.rect(27, 42, 2, 1, C(0xC8D0D8, alpha))   // boards, boss
    c.rect(19, 43, 18, 1, rimDark)
}

// MARK: - Gimmie

/// Where Gimmie's hand holds the axe: lower than a Man's, he's shorter.
private let gimliHand: (x: Double, y: Double) = (42.5, 36.5)

/// Gimmie, son of Groan, the dwarf: shorter than the Men (his helmet's top is where their brows are) and broader, short
/// thick legs in heavy boots, chain mail over everything, an iron helmet with cheek guards, and a huge braided red beard
/// down to the belt. His double-bladed axe stands in his fist, its head up by his shoulder; it's heavy, so a swing
/// smears a long way behind it. Signature: "Nobody tosses a dwarf!": the axe leant against his back, he crosses his
/// arms and shakes his head (…0.3), holds one hand up to stop you (…0.7) and stamps his foot.
private func drawGimli(_ c: PixelCanvas, _ p: Pose) {
    let sig = p.signature.flatMap { $0 > 0.03 && $0 < 0.97 ? $0 : nil }
    let crossed = sig.map { $0 < 0.3 } ?? false, stop = sig.map { $0 >= 0.3 && $0 < 0.7 } ?? false
    let lifted = sig.map { $0 >= 0.7 && $0 < 0.8 } ?? false, stamped = sig.map { $0 >= 0.8 && $0 < 0.9 } ?? false
    if let s = sig, crossed, s > 0.05 { c.ox += Int(s * 2.6 * 9) % 2 == 0 ? 1 : -1 }   // shaking his head
    if lifted { c.oy -= 1 }
    let helm = C(0x8A8C92), helmDark = C(0x6A6C72), helmLight = C(0xAEB0B6)
    let beard = C(0xB8501E), beardDark = C(0x8A3A16), beardLight = C(0xD8703A), tie = C(0xC8A040)
    let mail = C(0x6A6E78), mailDark = C(0x4E525A), mailLight = C(0x8A8E98)
    let trousers = C(0x4A3A2A), boot = C(0x3A2A1A), leather = C(0x5A3A1E)
    // Short thick legs in heavy boots, the toes forward.
    if seatedPose {
        for lx in [19, 23, 32, 36] { c.rect(lx - 1, 39, 4, 1, boot); c.px(lx + 2, 39, C(0x4E3A26)) }
    } else {
        for (i, lx) in [19, 23, 32, 36].enumerated() {
            let bottom = lifted && i == 3 ? 40 : p.step >= 0 && i % 2 == p.step ? 42 : 43
            c.rect(lx, 37, 3, bottom - 38, trousers)
            c.rect(lx, bottom - 1, 3, 2, boot); c.px(lx + 3, bottom, boot)
            c.px(lx, bottom - 1, C(0x4E3A26))
        }
        if stamped {
            // Dust kicked up round the stamped foot.
            for (dx, dy) in [(-2, 0), (4, 0), (-1, -1), (5, -1), (6, 0)] { c.px(36 + dx, 43 + dy - c.oy, C(0xC8B89A, 0.6)) }
        }
    }
    c.oy += p.breathe
    if sig != nil { drawGimliAxe(c, at: (14.5, 38.5 - Double(c.oy)), angle: -100) }   // leant against his back
    // The body: broader than Clawd's and lower down, the arms in mail.
    c.rect(17, 28, 22, 11, clawdOrange)
    c.rect(38, 28, 1, 11, clawdShade)
    if !crossed { c.rect(14, 35, 3, 3, mail); c.px(14, 37, mailDark) }
    c.rect(22, 30, 2, 3, ink); c.rect(32, 30, 2, 3, ink)
    // Chain mail from the chin down.
    for y in 33...38 {
        for x in 17...38 { c.px(x, y, x == 38 || y == 38 ? mailDark : (x + y) % 2 == 0 ? mailLight : mail) }
    }
    // The helmet: an iron dome, a riveted rim and cheek guards.
    c.pattern(17, 25, [
        "....HHHHHHHHHHHHHH....",
        "..HHHHlHHHHHHHHHHHHH..",
        ".HHlHHHHHHHHHHHHHHHHD.",
        "DDDDDDDDDDDDDDDDDDDDDD",
        "HHH................HHH",
        "HlH................HHD",
        "HHH................HHD",
        ".HH................HD.",
    ], ["H": helm, "l": helmLight, "D": helmDark])
    for x in stride(from: 18, through: 38, by: 4) { c.px(x, 28, helmLight) }
    // The beard: sideburns down the cheeks, then a great red bush to the belt, two braids hanging below it.
    c.rect(20, 31, 1, 2, beard); c.rect(35, 31, 1, 2, beard)
    c.pattern(19, 33, [
        ".HHHHHHHHHHHHHHHH.",
        "HHHlHHHHHHHHHHlHHH",
        "HHHHHHdHHHHdHHHHHH",
        "HdHHHlHHHHHHlHHHdH",
        ".HHHdHHHHHHHHdHHH.",
        "..HHHHHdHHdHHHHH..",
        "....TT......TT....",
        "....HH......HH....",
        "....Hd......dH....",
    ], ["H": beard, "d": beardDark, "l": beardLight, "T": tie])
    c.rect(24, 33, 8, 1, beardDark)                                           // the moustache's edge
    if crossed {
        // Arms folded over the beard: the far forearm on top, the near one under it, the fists tucked in.
        c.pattern(14, 36, [
            "mMMMMMMMMMMMMMMMGG.......",
            ".......GGmMMMMMMMMMMMMMMm",
        ], ["M": mail, "m": mailDark, "G": leather, "g": C(0x3E2812)])
        return
    }
    if stop {
        // One gloved hand held up, palm out: stop right there.
        c.rect(39, 29, 3, 9, mail); c.rect(41, 29, 1, 9, mailDark)
        c.pattern(39, 24, ["O.O.O", "OOOOO", "OOOOO", "OOOOs", ".OOs."], ["O": clawdOrange, "s": clawdShade])
        return
    }
    if sig != nil { c.rect(39, 35, 3, 3, mail); return }
    // The axe, upright in his fist, swung with a long smear behind it; the floor stops a low stroke (his hand is low).
    let angle = min(5, p.melee ?? -65)
    for (i, a) in heavySmear(angle, p.melee == nil ? [] : p.trail.map { min(5, $0) }).enumerated() {
        let u = unit(a), n = (x: -u.y, y: u.x), fade: Double = 0.38 * (1 - Double(i) / 12)
        guard fade > 0.03 else { break }
        let m = (x: gimliHand.x + u.x * 10, y: gimliHand.y + u.y * 10)
        c.glowLine(m.x - n.x * 6, m.y - n.y * 6, m.x + n.x * 6, m.y + n.y * 6, core: C(0xD8E0E8), glow: C(0x9AA4B0),
                   coreR: 0.6, glowR: 1.4, strength: fade)
    }
    drawGimliAxe(c, angle: angle)
    c.rect(40, 35, 3, 3, leather); c.px(40, 37, C(0x3E2812))                  // the glove round the haft
}

/// Gimmie's axe: a long wooden haft with an iron butt, and a double-bladed iron head, each blade flaring to a wide edge.
private func drawGimliAxe(_ c: PixelCanvas, at: (x: Double, y: Double) = gimliHand, angle: Double) {
    prop(c, at: at, angle: angle) { s in
        let haft = C(0x5A3A1E), haftLight = C(0x7A5230), iron = C(0x9AA4B0), ironDark = C(0x6A727E), edge = C(0xD8E0E8)
        s.rect(17, 20, 15, 1, haft); s.rect(17, 21, 15, 1, C(0x40280E))
        s.rect(20, 20, 9, 1, haftLight)
        s.rect(16, 20, 1, 2, ironDark)
        s.pattern(27, 13, [
            "EEEEEE",
            "BBBBBB",
            ".BBBBb",
            ".BBBb.",
            "..BBb.",
            "..BB..",
            "..SSS.",
            "..SSSS",
            "..SSS.",
            "..BB..",
            "..BBb.",
            ".BBBb.",
            ".BBBBb",
            "BBBBBB",
            "EEEEEE",
        ], ["B": iron, "b": ironDark, "S": ironDark, "E": edge])
    }
}

// MARK: - Boromeme

/// Boromeme, captain of Gondor: a red-brown tunic belted over dark trousers and boots, a thick fur collar across the
/// shoulders, chestnut hair to the shoulders and the horn of Gondor, ivory with silver bands, hanging at his hip. A
/// round wooden shield on his off arm, a broad sword held low in his hand, swung with a smear behind a fast stroke.
/// Signature: the meme. He sticks the sword in the ground in front of him and lifts one hand to his shoulder, finger
/// and thumb in a ring ("One does not simply…", …0.2), holds it there with a little wobble every quarter of a second,
/// and lowers it at the end.
private func drawBoromir(_ c: PixelCanvas, _ p: Pose) {
    let tunic = C(0x7A2A2A), tunicShade = C(0x5A1E1E), tunicLight = C(0x9A3A36)
    let fur = C(0x6A5A4A), furDark = C(0x4E4236), furLight = C(0x8A7A68)
    let hair = C(0x6A3A1E), hairDark = C(0x4A2812), hairLight = C(0x8A5230)
    drawLegs(c, Look(leg: C(0x3A2C24)), step: p.step)
    drawBoots(c, p.step, C(0x2A1E16), rows: 3)
    c.oy += p.breathe
    drawBody(c, Look(arm: tunic))
    c.rect(18, 33, 20, 5, tunic)
    c.rect(37, 33, 1, 5, tunicShade)
    for y in 38...39 where y + c.oy <= 43 { c.rect(18, y, 20, 1, tunic); c.px(27, y, tunicShade); c.px(37, y, tunicShade) }
    c.rect(21, 34, 1, 2, tunicLight)
    c.rect(18, 36, 20, 1, C(0x3A2A1E)); c.px(27, 36, C(0xC8A040))           // the belt and its buckle
    // The fur collar, heavy across the shoulders.
    c.pattern(15, 33, [
        "..FfFFlFFfFFFFfFFlFFfFF...",
        ".FFFlFFfFFFlFFFFlFFFfFFFF.",
        "..dFF.dFF.FdF.FdF.dFF.d...",
    ], ["F": fur, "f": furDark, "l": furLight, "d": furDark])
    // Chestnut hair to the shoulders.
    c.pattern(16, 20, [
        ".......HHHHHHHHHH.......",
        "....HHHHHHHHHHHHHHHH....",
        "..HHHHlHHHHHHHHHHlHHHH..",
        ".HHHHHHHHHlHHHHHHHHHHHH.",
        ".HHlHHHHHHHHHHHHHHlHHHH.",
        "HHHHHHHHdHHHHHdHHHHHHHHH",
        "HHHHHd............dHHHHH",
        "HHHd................dHHH",
        "HHH..................HHH",
        "HHd..................dHH",
        "HHH..................HHH",
        ".Hd..................dH.",
    ], ["H": hair, "d": hairDark, "l": hairLight])
    // The horn of Gondor at his hip, its mouth forward.
    c.pattern(31, 36, [
        "Hh.......",
        ".HHs.....",
        "..HHHsHH.",
        "...hHHsHHH",
        "......HHH.",
    ], ["H": C(0xE8E0C8), "h": C(0xB8B098), "s": C(0xC8D0D8)])
    c.px(30, 36, C(0x3A2A1E))
    // The shield on his off arm, the sword held low.
    drawRoundShield(c, cx: 14, cy: seatedPose ? 33 : 34)
    if let s = p.signature, s > 0.03, s < 0.97 {
        drawBroadsword(c, at: (50.5, 28.5 - Double(c.oy)), angle: 90)                // stuck in the ground
        let k: Double = s < 0.2 ? smooth(s / 0.2) : s < 0.9 ? 1 : 1 - smooth((s - 0.9) / 0.1)
        let wobble = s >= 0.2 && s < 0.9 && Int(s * 3.4 / 0.25) % 2 == 1 ? 1 : 0
        let up = Int((4 * k).rounded())
        c.rect(38, 33 - up, 3, 3 + up, tunic); c.rect(38, 35, 3, 1, tunicShade)
        // The hand: finger and thumb in a ring, the other fingers up.
        c.pattern(40 + wobble, 29 - up, ["..O.O", ".OOOO", "O.OOO", ".OOOs", "..Os."], ["O": clawdOrange, "s": clawdShade])
        return
    }
    let angle = p.melee ?? (seatedPose ? 8 : 32)
    for (i, a) in (p.melee == nil ? [] : p.trail).enumerated() {
        let u = unit(a)
        c.glowLine(Sprite.hand.x + u.x * 4, Sprite.hand.y + u.y * 4, Sprite.hand.x + u.x * 15, Sprite.hand.y + u.y * 15,
                   core: C(0xE8EEF4), glow: C(0xA8B4C0), coreR: 0.8, glowR: 1.9, strength: 0.32 / Double(i + 1))
    }
    drawBroadsword(c, angle: angle)
    c.rect(38, 33, 3, 3, tunic); c.rect(40, 33, 2, 3, clawdOrange)
}

/// Boromeme's round shield on the off arm: wooden boards, an iron rim and a boss.
private func drawRoundShield(_ c: PixelCanvas, cx: Int, cy: Int) {
    let wood = C(0x8A6A3A), dark = C(0x6A4E28), rim = C(0x5A4428)
    c.ellipse(cx, cy, 5, 5, rim)
    c.ellipse(cx, cy, 4, 4, wood)
    for dx in [-2, 1, 3] { c.rect(cx + dx, cy - 3, 1, 7, dark) }
    c.rect(cx - 1, cy - 1, 3, 3, C(0x8A8E96)); c.px(cx - 1, cy - 1, C(0xC8CCD4))
    for (dx, dy) in [(-4, 0), (4, 0), (0, -4), (0, 4)] { c.px(cx + dx, cy + dy, C(0xA8ACB4)) }
}

/// A broad sword gripped at the hand: a leather grip, an iron pommel and crossguard, a wide steel blade with a fuller.
private func drawBroadsword(_ c: PixelCanvas, at: (x: Double, y: Double) = Sprite.hand, angle: Double) {
    prop(c, at: at, angle: angle) { s in
        let blade = C(0xC8CCD4), edge = C(0x8A8F9C), fuller = C(0xA8AEB8)
        s.rect(17, 20, 4, 1, C(0x4A3420)); s.px(16, 20, C(0x8A8E96))
        s.rect(21, 17, 1, 7, C(0x8A8E96)); s.px(21, 17, C(0xB8BCC4))
        s.rect(22, 19, 13, 3, blade)
        s.rect(22, 21, 13, 1, edge)
        s.rect(23, 20, 10, 1, fuller)
        s.px(35, 20, blade); s.px(35, 21, edge)
    }
}

// MARK: - Gladriel

/// Gladriel, the Lady of the wood: a long white gown that hides her legs and sweeps the ground (she hovers just above
/// it; the hem sways), long sleeves, long gold hair to the waist and a silver circlet with a pale gem. She fights with a
/// slender elven longsword, held low in her hand at rest and swung with a pale smear behind a fast stroke.
/// Signature: she raises the Phial: the sword goes to her girdle, her hand rises up past her face (…0.2), a star of
/// light shines out of it, pulsing (…0.8), and dims as she lowers it.
private func drawGaladriel(_ c: PixelCanvas, _ p: Pose) {
    let gown = C(0xE8ECF2), gownShade = C(0xB8C2CE), fold = C(0xD2D8E2)
    let hair = C(0xF4E0A0), hairShade = C(0xD4BC74), hairLight = C(0xFFF2C8), silver = C(0xC8D0D8)
    // The skirt, from the waist to the ground, flaring and swaying.
    for y in 36...43 where y + c.oy <= 43 {
        let k = Double(y - 36) / 7
        let hw: Double = 10.5 + k * 3
        let sway: Double = p.walking ? (p.step == 0 ? 1 : -1) * k : sin(p.lt * 1.6 + k * 2) * k * 1.2
        let l = Int((28 - hw - sway).rounded()), r = Int((28 + hw - sway).rounded()) - 1
        c.rect(l, y, r - l + 1, 1, gown)
        c.px(l, y, fold); c.px(r, y, gownShade)
        for f in [l + 5, Int((28 - sway).rounded()), r - 4] where y >= 38 { c.px(f, y, fold) }
        if y == 43 { c.rect(l, y, r - l + 1, 1, fold) }
    }
    c.oy += p.breathe
    // Her hair down her back, to the waist.
    c.pattern(14, 25, [
        "HHHH", "HhHH", "HHhH", "HHHH", "hHHH", "HHhH", "HHHH", "HhHH", "HHHH", "HHhH", ".HHH", ".HhH", "..HH",
    ], ["H": hair, "h": hairShade])
    let sig = p.signature
    let lift: Double = sig.map { s in s < 0.2 ? smooth(s / 0.2) : s < 0.8 ? 1 : 1 - smooth((s - 0.8) / 0.2) } ?? 0
    let phial = Int((7 * lift).rounded())
    drawBody(c, Look(arm: gown), armRight: max(p.armRaise, min(phial, 2)))
    // The bodice, a square neckline trimmed in silver, and a silver girdle.
    c.rect(18, 34, 20, 4, gown)
    c.rect(37, 34, 1, 4, gownShade)
    c.rect(20, 34, 16, 1, silver)
    c.rect(18, 33, 3, 1, gown); c.rect(35, 33, 3, 1, gown)
    c.rect(19, 36, 18, 1, silver); c.px(27, 37, silver); c.px(28, 37, silver)
    // Long sleeves: the back one hanging, the front one lifted with the hand.
    c.rect(14, 33, 4, 4, gown); c.rect(14, 36, 3, 2, gownShade); c.px(14, 33, fold)
    let a = p.armRaise
    c.rect(38, 33 - a, 3, 3, gown); c.rect(38, 36 - a, 3, 2, gownShade)
    c.rect(41, 33 - a, 1, 2, clawdOrange)
    // The hair over the head, down either side of the face, and the circlet.
    c.pattern(16, 19, [
        ".......HHHHHHHHHH.......",
        "....HHHHHHHlHHHHHHHH....",
        "..HHHHHHHlHHHHHHHHHHHH..",
        ".HHHHHHHHHHHHHHHlHHHHHH.",
        ".HHhHHHHHHHHHHHHHHHHhHH.",
        "HHHHHHHHHHHHHHHHHHHHHHHH",
        "HHHh................hHHH",
        "HHh..................hHH",
        "HHH..................HHH",
        "HHh..................hHH",
        "HHH..................HHH",
        "HHh..................hHH",
        "HHH..................HHH",
        ".HH..................HH.",
        ".Hh..................hH.",
        ".HH..................HH.",
        "..Hh................hH..",
        "..HH................HH..",
        "..H..................H..",
    ], ["H": hair, "h": hairShade, "l": hairLight])
    c.rect(17, 24, 22, 1, silver)
    c.px(27, 24, white); c.px(28, 24, C(0xBFEFFF))
    guard let s = sig, phial > 0 else {
        // The sword in her hand: held low at rest, swung in a fight; the hand closed over the grip.
        drawElvenSword(c, angle: p.melee ?? (seatedPose ? 8 : 35), trail: p.melee == nil ? [] : p.trail)
        c.rect(41, 33 - a, 1, 2, clawdOrange); c.px(42, 34 - a, clawdShade)
        return
    }
    drawGirdleSword(c)
    // The arm raised past her hair, the long sleeve falling from it, and the Phial in her hand.
    c.rect(39, 33 - phial, 3, phial + 3, gown); c.rect(41, 34 - phial, 1, phial + 2, gownShade); c.px(39, 33 - phial, fold)
    c.rect(41, 31 - phial, 2, 2, clawdOrange)
    let at = (x: 42.0, y: 30.5 - Double(phial))
    let shine: Double = s < 0.2 ? 0 : s < 0.26 ? (s - 0.2) / 0.06 : s < 0.8 ? 1 : 1 - (s - 0.8) / 0.2
    guard shine > 0.02 else { c.px(42, 30 - phial, C(0xE8F4FF)); return }
    let e: Double = s * 3.0, tau: Double = 2 * .pi
    let pulse: Double = 0.5 + 0.5 * sin(e * tau * 1.3)
    let r: Double = 4 + 2 * pulse
    c.glowLine(at.x, at.y, at.x, at.y, core: white, glow: C(0xBFEFFF, 0.7), coreR: 1.2, glowR: r, strength: shine)
    for (dx, dy) in [(1.0, 0.0), (-1.0, 0.0), (0.0, 1.0), (0.0, -1.0)] {            // the star's four points
        c.glowLine(at.x + dx * 1.5, at.y + dy * 1.5, at.x + dx * (r + 1), at.y + dy * (r + 1), core: C(0xF4FCFF),
                   glow: clear, coreR: 0.35, glowR: 0.4, strength: shine * (0.55 + 0.35 * pulse))
    }
}

private let elfSilver = C(0xE4EAF2), elfEdge = C(0x9AA6B4), elfGold = C(0xE0B840), elfGoldLight = C(0xFFE89A)

/// Gladriel's elven longsword in her hand at `angle`: a pale grip and a gold pommel, a gold guard shaped like a leaf
/// (its two points swept forward), and a long, slender (15 px) pale-silver blade with a darker edge, tapering to a fine
/// point; a pale smear along `trail` behind a fast stroke.
private func drawElvenSword(_ c: PixelCanvas, angle: Double, trail: [Double]) {
    let hand = Sprite.hand, tip: Double = 18
    for (i, a) in trail.enumerated() {
        let u = unit(a)
        c.glowLine(hand.x + u.x * 4, hand.y + u.y * 4, hand.x + u.x * tip, hand.y + u.y * tip, core: C(0xF4F8FF),
                   glow: C(0xB8CCE0), coreR: 0.45, glowR: 1.5, strength: 0.32 / Double(i + 1))
    }
    let u = unit(angle), n = (x: -u.y, y: u.x)
    line(c, hand.x - u.x * 2.5, hand.y - u.y * 2.5, hand.x + u.x * 1.5, hand.y + u.y * 1.5, C(0xD8CCB0), 0.6)   // the grip
    c.px(Int((hand.x - u.x * 3).rounded(.down)), Int((hand.y - u.y * 3).rounded(.down)), elfGold)              // the pommel
    line(c, hand.x + u.x * 3, hand.y + u.y * 3, hand.x + u.x * (tip - 3), hand.y + u.y * (tip - 3), elfSilver, 0.6)
    line(c, hand.x + u.x * (tip - 3), hand.y + u.y * (tip - 3), hand.x + u.x * tip, hand.y + u.y * tip, elfSilver, 0.35)
    line(c, hand.x + u.x * 3 + n.x * 0.5, hand.y + u.y * 3 + n.y * 0.5, hand.x + u.x * (tip - 3) + n.x * 0.5,
         hand.y + u.y * (tip - 3) + n.y * 0.5, elfEdge, 0.25)
    drawLeafGuard(c, at: (hand.x + u.x * 2.5, hand.y + u.y * 2.5), u: u)
}

/// The gold leaf guard across a blade running along `u`: widest in the middle, its two points swept forward.
private func drawLeafGuard(_ c: PixelCanvas, at g: (x: Double, y: Double), u: (x: Double, y: Double)) {
    let n = (x: -u.y, y: u.x)
    line(c, g.x - n.x * 2, g.y - n.y * 2, g.x + n.x * 2, g.y + n.y * 2, elfGold, 0.55)
    for s in [-1.0, 1.0] {
        c.px(Int((g.x + n.x * s * 2.6 + u.x).rounded(.down)), Int((g.y + n.y * s * 2.6 + u.y).rounded(.down)), elfGold)
    }
    c.px(Int(g.x.rounded(.down)), Int(g.y.rounded(.down)), elfGoldLight)
}

/// Gladriel's sword at her girdle while she lifts the Phial: the hilt forward at her hip, the blade sloping down and
/// back across her gown.
private func drawGirdleSword(_ c: PixelCanvas) {
    let u = unit(165), g = (x: 35.5, y: 36.5)
    line(c, g.x + u.x, g.y + u.y, g.x + u.x * 13, g.y + u.y * 13, elfEdge, 0.5)
    line(c, g.x - u.x, g.y - u.y, g.x - u.x * 3.5, g.y - u.y * 3.5, C(0xD8CCB0), 0.5)   // the grip
    c.px(Int(g.x - u.x * 4), Int(g.y - u.y * 4), elfGold)                         // the pommel
    drawLeafGuard(c, at: g, u: u)
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
private func prop(_ c: PixelCanvas, at: (x: Double, y: Double), angle: Double, alpha: Double = 1, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(41, 41)
    art(s)
    let r = s.rotated(angle, about: (20.5, 20.5), into: 41, 41, at: (20.5, 20.5))
    let x0 = Int(floor(at.x - 20.5)), y0 = Int(floor(at.y - 20.5))
    for y in 0..<r.h {
        for x in 0..<r.w {
            let i = (y * r.w + x) * 4
            guard r.buf[i + 3] > 0 else { continue }
            c.px(x0 + x, y0 + y, unpremultiplied(r, i).alpha(alpha))
        }
    }
}

private func unpremultiplied(_ s: PixelCanvas, _ i: Int) -> Px {
    let a = s.buf[i + 3], m = 255 / Double(a)
    return Px(r: UInt8(min(255, Double(s.buf[i]) * m)), g: UInt8(min(255, Double(s.buf[i + 1]) * m)),
              b: UInt8(min(255, Double(s.buf[i + 2]) * m)), a: a)
}

/// Smoothstep: 0→1 eased at both ends.
private func smooth(_ x: Double) -> Double {
    let u = min(1, max(0, x))
    return u * u * (3 - 2 * u)
}

/// Draws `art` on a scratch canvas (same offsets as `c`) and copies it onto `c`, washed toward white by `flash` (0…1).
private func layer(_ c: PixelCanvas, flash: Double = 0, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    defer { c.ox = ox; c.oy = oy; c.baseY = by }
    let f = min(1, max(0, flash))
    for y in 0..<s.h {
        for x in 0..<s.w {
            let i = (y * s.w + x) * 4
            guard s.buf[i + 3] > 0 else { continue }
            var col = unpremultiplied(s, i)
            if f > 0 {
                col.r = UInt8(Double(col.r) + (255 - Double(col.r)) * f)
                col.g = UInt8(Double(col.g) + (255 - Double(col.g)) * f)
                col.b = UInt8(Double(col.b) + (255 - Double(col.b)) * f)
            }
            c.px(x, y, col)
        }
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
