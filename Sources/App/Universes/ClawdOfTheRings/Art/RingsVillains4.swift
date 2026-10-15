import Foundation

// Villains: the creatures. None of them is Clawd in costume except the warg's rider. The Watcher in the Water and the
// Mûmak are half again a Man's size (drawn so on the canvas, so their `headTop`, `pivot` and `bulk` say so), the
// Barrow-wight is a Man-sized ghost floating over its own shroud, and the warg rider is an orc astride a wolf as long
// as a pony, its head forward of where Clawd's front would be.

let ringsVillains4: [LOTRVillain: Persona] = [
    .watcher: Persona(name: "The Watcher in the Waterfall", weapon: .saber, canSit: false, pivot: watcherRoot, bulk: 8,
                      headTop: 6, signature: 3.2, callout: "Requirements… design… nobody gets out of the Waterfall.", draw: drawWatcher),
    .oliphaunt: Persona(name: "Oli-PHP-aunt", weapon: .saber, armoured: true, canSit: false, pivot: mumakTusks, bulk: 12,
                        headTop: 7, signature: 3.0,
                        callout: "I am the elePHPant in the room.", draw: drawOliphaunt),
    .barrowWight: Persona(name: "Barrow-write", weapon: .lightning, motion: .hover,
                          magic: Magic(core: C(0xF0FFF4), glow: C(0x8FE8B0), jagged: false), canSit: false,
                          pivot: wightHand, headTop: 19, signature: 3.4, callout: "Cold be hand and heart and disk… write once, sleep forever.",
                          draw: drawBarrowWight),
    .warg: Persona(name: "Wargh-rider", weapon: .saber, canSit: false, pivot: riderHand, bulk: 9, headTop: 17, signature: 3.0,
                   callout: "Grrr… I smell Clawd in the commit log!", draw: drawWargRider),
]

// MARK: - The Watcher in the Waterfall

/// Where the Watcher lashes from: the root of its front tentacle, at the front of its bulk just above the water.
private let watcherRoot: (x: Double, y: Double) = (39.5, 36.5)

/// The Watcher in the Water, towering half again a Man's height: a great dark green-black dome risen half out of a
/// pool of black water on a broad lumpy base, ripples spreading out round it, one cold pale eye glinting high on its
/// front under a heavy brow, a toothed maw below, and its tentacles all about it, green-black with pale suckers along
/// the inside of their curl: three reared high (the far one darker, leaning back and curling back; one off its shoulder
/// and the lasher in front, both hooking over forward), two more groping along the water before and behind. It
/// doesn't walk: the tentacles shift one way and
/// the other with `p.step`, and sway slowly when it's still. It lashes with the front one, which rears up and hooks
/// over forward at rest; swung, it follows the swing, its tip lagging behind, with a pale smear behind a fast lash.
/// Signature: up from the deep. The lashing tentacle rears up out of the pool, straight up to the top of the canvas
/// (…0.3), and gropes there, its tip curling and snatching at the air twice; then it comes crashing down forward
/// (0.55…0.62), a pale smear behind it, and slaps flat along the water: spray flies up and a ripple spreads from where
/// it hit, before it curls back up into its hook.
private func drawWatcher(_ c: PixelCanvas, _ p: Pose) {
    let hide = C(0x1E2A22), hideDark = C(0x121A15), hideLight = C(0x34463A)
    let tent = C(0x2A3E2E), tentFar = C(0x18241C), sucker = C(0xB4C4A0), suckerFar = C(0x6E7E66)
    let water = C(0x101C26), ripple = C(0x3A5A6E), foam = C(0x9AB8C4), eye = C(0xE0F0A0)
    let sway: Double = p.step >= 0 ? (p.step == 0 ? 1 : -1) : sin(p.lt * 1.3)
    // The pool, and three rings of ripples spreading out over it, a glint or two of light on the black water.
    c.ellipse(27, 41, 25, 2, water)
    for k in 0..<3 {
        let f = frac(p.lt * 0.35 + Double(k) / 3)
        ring(c, cx: 27.5, cy: 41.5, rx: 13 + f * 13, ry: 1 + f * 1.2, ripple.alpha(1 - f * 0.85))
    }
    for (k, x) in [6, 11, 46, 50].enumerated() where noise(Int(p.t * 3) + k * 7) > 0.45 { c.px(x, 41, foam.alpha(0.5)) }
    // The far tentacles: one reared high behind, leaning back and curling back at the tip, one groping off along the
    // water behind.
    drawTentacle(c, root: (18, 33), angle: -98 + 4 * sway, bend: -210, n: 17, r0: 1.7, col: tentFar, sucker: suckerFar)
    drawTentacle(c, root: (13, 41), angle: 185, bend: 50 + 15 * sway, n: 5, r0: 1.1, col: tentFar, sucker: nil)
    c.oy += p.breathe
    // The bulk, risen half out of the water: a broad lumpy base at the surface and a great dark dome above it, a
    // paler wet sheen down its back, warty knobs.
    c.ellipse(28, 38, 13, 4, hideDark)
    c.ellipse(28, 30, 9, 10, hideDark)
    c.ellipse(28, 37, 12, 4, hide)
    c.ellipse(27, 29, 9, 10, hide)
    c.ellipse(24, 24, 4, 3, hideLight)
    c.rect(20, 28, 2, 6, hideLight)
    c.px(23, 21, hideLight)
    for (x, y) in [(21, 35), (30, 34), (25, 31), (34, 36), (18, 38), (31, 22), (22, 26), (27, 36)] { c.px(x, y, hideDark) }
    // The eye, high on the front of the dome under a heavy brow: a cold pale-green almond, a slit pupil, glinting.
    let glint: Double = 0.6 + 0.4 * sin(p.lt * 2.1)
    c.glowLine(32.5, 26.5, 35.5, 26.5, core: eye, glow: C(0x9AE070), coreR: 0.5, glowR: 2.6, strength: 0.55 * glint)
    c.rect(32, 26, 4, 2, eye)
    c.px(31, 27, eye)
    c.px(36, 26, eye)
    c.rect(34, 25, 1, 3, ink)
    c.px(33, 26, white)
    c.rect(30, 24, 7, 1, hideDark)
    c.rect(31, 23, 4, 1, hideDark)
    // The maw under it, a dark slash with a few pale teeth.
    c.rect(30, 32, 6, 1, ink)
    c.px(35, 31, ink)
    for x in [31, 34] { c.px(x, 33, sucker) }
    c.oy -= p.breathe
    // The near side of the pool lapping round it, foam where it breaks.
    c.ellipse(28, 42, 15, 1, water)
    let tick = Int(p.t * 8)
    for (k, x) in [15, 17, 20, 36, 39, 41].enumerated() where noise(tick + k * 5) > 0.3 { c.px(x, 41, foam.alpha(0.8)) }
    c.oy += p.breathe
    // The near tentacles: one reared high off its shoulder and hooking over forward, one groping forward along the water.
    drawTentacle(c, root: (22, 29), angle: -90 - 4 * sway, bend: 210, n: 16, r0: 1.9, col: tent, sucker: sucker)
    drawTentacle(c, root: (37, 41), angle: -5, bend: 40 + 25 * sway, n: 4, r0: 1.1, col: tent, sucker: sucker)
    // The lashing tentacle: reared and hooked over forward at rest; swung, along the swing with the tip lagging.
    guard let a = p.melee else {
        if let s = p.signature, s > 0, s < 1 {
            drawWatcherGrab(c, p, s, sway: sway, tent: tent, sucker: sucker, foam: foam, ripple: ripple)
            return
        }
        drawTentacle(c, root: watcherRoot, angle: -80 + 4 * sway, bend: 230, n: 15, r0: 1.8, col: tent, sucker: sucker)
        return
    }
    func reach(_ a: Double) -> Double { min(70, max(-120, wrapped(a))) }
    let now = reach(a)
    for (i, ta) in p.trail.enumerated() {
        drawTentacle(c, root: watcherRoot, angle: reach(ta), bend: 50, n: 12, r0: 1.2, col: C(0x7A9A80), sucker: nil,
                     alpha: 0.32 / Double(i + 1))
    }
    let lag: Double = p.trail.first.map { reach($0) - now } ?? 0
    drawTentacle(c, root: watcherRoot, angle: now, bend: 50 + lag * 2, n: 12, r0: 1.8, col: tent, sucker: sucker)
}

/// A tentacle from `root`, setting off along `angle` and turning `bend` degrees by its tip, tapering to a point; pale
/// suckers dot the inside of its curl.
private func drawTentacle(_ c: PixelCanvas, root: (x: Double, y: Double), angle: Double, bend: Double, n: Int,
                          r0: Double, col: Px, sucker: Px?, alpha: Double = 1) {
    let pts = curve(root, angle: angle, bend: bend, n: n, step: 2, power: 3)
    taper(c, pts, r0: r0, r1: 0.4, col.alpha(alpha))
    guard let sucker else { return }
    let side: Double = bend >= 0 ? 1 : -1, floor = Double(43 - c.oy) + 0.5
    for i in stride(from: 1, to: pts.count - 2, by: 2) {
        let a = pts[i], b = pts[i + 1], f = Double(i) / Double(pts.count - 1)
        let len = max(hypot(b.x - a.x, b.y - a.y), 0.01)
        let inner = (x: -(b.y - a.y) / len * side, y: (b.x - a.x) / len * side)
        let r: Double = max(0, r0 + (0.4 - r0) * f - 0.4)
        guard a.y + inner.y * r < floor else { continue }
        c.px(Int((a.x + inner.x * r).rounded(.down)), Int((a.y + inner.y * r).rounded(.down)), sucker.alpha(alpha))
    }
}

/// The lashing tentacle `s` through the Watcher's signature: its angle, bend and length in steps. From the hook at rest
/// up to straight overhead (…0.3), groping and snatching (…0.55), crashing down forward (…0.62), lying along the water,
/// and curling back up into the hook (0.8…).
private func watcherGrab(_ s: Double, sway: Double) -> (angle: Double, bend: Double, n: Double) {
    typealias Shape = (angle: Double, bend: Double, n: Double)
    let rest: Shape = (-80 + 4 * sway, 230, 15), high: Shape = (-95, -30, 17), down: Shape = (8, 25, 15)
    func mix(_ a: Shape, _ b: Shape, _ k: Double) -> Shape {
        (a.angle + (b.angle - a.angle) * k, a.bend + (b.bend - a.bend) * k, a.n + (b.n - a.n) * k)
    }
    if s < 0.3 { return mix(rest, high, smooth(s / 0.3)) }
    if s < 0.55 {
        let u = (s - 0.3) / 0.25
        return (high.angle + 4 * sin(u * 2 * .pi), high.bend + 120 * (0.5 - 0.5 * cos(u * 4 * .pi)), high.n)
    }
    if s < 0.62 { let u = (s - 0.55) / 0.07; return mix(high, down, u * u) }
    if s < 0.8 { return down }
    return mix(down, rest, smooth((s - 0.8) / 0.2))
}

/// The Watcher's signature, its lashing tentacle `s` through the grab (`watcherGrab`): a pale smear behind it as it
/// crashes down, then spray and a spreading ripple where it slaps the water.
private func drawWatcherGrab(_ c: PixelCanvas, _ p: Pose, _ s: Double, sway: Double, tent: Px, sucker: Px, foam: Px,
                             ripple: Px) {
    if s > 0.55, s < 0.66 {
        for i in 1...3 {
            let g = watcherGrab(max(0.55, s - 0.012 * Double(i)), sway: sway)
            drawTentacle(c, root: watcherRoot, angle: g.angle, bend: g.bend, n: Int(g.n.rounded()), r0: 1.2,
                         col: C(0x7A9A80), sucker: nil, alpha: 0.32 / Double(i))
        }
    }
    let g = watcherGrab(s, sway: sway)
    drawTentacle(c, root: watcherRoot, angle: g.angle, bend: g.bend, n: Int(g.n.rounded()), r0: 1.8, col: tent, sucker: sucker)
    // The splash where it lands: a ripple spreading over the floor, drops of spray flying up and falling back.
    guard s >= 0.62, s < 0.9 else { return }
    let k = (s - 0.62) / 0.28, oy = c.oy
    c.oy -= p.breathe
    defer { c.oy = oy }
    ring(c, cx: 58.5, cy: 42.5, rx: 2 + k * 9, ry: 0.6 + k, ripple.alpha(1 - k))
    if k < 0.2 { for x in [54, 57, 60, 63] { c.px(x, 41, foam) } }
    for i in 0..<8 {
        let vx: Double = (Double(i) - 3.5) * 3.2, lift: Double = 9 + 7 * noise(i * 11 + 5)
        let x = 58.5 + vx * k * 1.6, y = 42 - lift * 4 * k * (1 - k)
        c.px(Int(x.rounded(.down)), Int(y.rounded(.down)), (i % 3 == 0 ? white : foam).alpha(1 - k * k))
    }
}

/// An ellipse's outline, one pixel thick (ripples on water).
private func ring(_ c: PixelCanvas, cx: Double, cy: Double, rx: Double, ry: Double, _ col: Px) {
    var seen = Set<Int>()
    let n = max(16, Int(rx * 6))
    for k in 0..<n {
        let a = Double(k) / Double(n) * 2 * .pi
        let x = Int((cx + cos(a) * rx).rounded(.down)), y = Int((cy + sin(a) * ry).rounded(.down))
        guard seen.insert(x * 100 + y).inserted else { continue }
        c.px(x, y, col)
    }
}

// MARK: - Oli-PHP-aunt

/// Where the Mûmak sweeps from: the roots of its tusks, under its eye.
private let mumakTusks: (x: Double, y: Double) = (49.5, 31.5)

/// Oli-PHP-aunt, a Mûmak of the Harad, half again as tall and as wide as a Man: a huge grey-brown war-elephant on four
/// pillar legs (the far pair darker, lifting two and two as it walks), a great ear, a gold plate on its brow and red
/// war paint under its eye, a trunk hanging to the floor and curling forward, and four ivory tusks, the near pair over
/// the far. Over its back a red war blanket trimmed and tasselled in gold, and on top a small wooden howdah under a
/// red canopy with a tiny rider peering out. It sweeps with its tusks: the head tosses up on the wind-up and down on
/// the strike, the tusks turning with it and a pale smear behind a fast sweep. Signature: the elePHPant in the room
/// makes itself heard. It rears up on its hind legs (…0.22), front feet off the floor and its trunk swinging up and
/// curling back, and trumpets: blasts of sound ringing out of the trunk's tip and a little "PHP" puffing out of it,
/// then it comes back down with a thump (0.82) that kicks up dust under its front feet.
private func drawOliphaunt(_ c: PixelCanvas, _ p: Pose) {
    guard let s = p.signature, s > 0, s < 1 else { drawOliphauntBody(c, p, trunkUp: nil); return }
    let far = C(0x62584F), hide = C(0x7A6E64)
    let rear: Double = s < 0.22 ? smooth(s / 0.22) : s < 0.72 ? 1 : s < 0.82 ? 1 - pow((s - 0.72) / 0.1, 2) : 0
    let trunkUp: Double = s < 0.05 ? 0 : s < 0.25 ? smooth((s - 0.05) / 0.2) : s < 0.72 ? 1 : 1 - smooth((s - 0.72) / 0.23)
    let tilt = -12 * rear + (s > 0.22 && s < 0.72 ? 1.2 * sin((s - 0.22) * 6 * .pi) : 0)
    let hind: (x: Double, y: Double) = (11, 43.5)
    // The hind legs stay planted; everything else turns up about the hind feet.
    drawMumakLeg(c, 13, far, up: 0)
    if s >= 0.82, s < 0.86 { c.oy += 1 }                                          // the thump of landing
    turned(c, about: hind, degrees: tilt) { drawOliphauntBody($0, p, trunkUp: trunkUp) }
    drawMumakLeg(c, 7, hide, up: 0)
    // The trumpeting: rings of sound out of the trunk's tip, and a "PHP" puffing up out of it.
    if s > 0.25, s < 0.74 {
        let k = (s - 0.25) / 0.49
        let tip = turn(curve((51.5, 28.5), angle: -30, bend: -90, n: 7, step: 2).last!, about: hind, tilt)
        for j in 0..<3 {
            let f = frac(k * 5 + Double(j) / 3)
            for a in stride(from: -150.0, through: -60, by: 10) {
                let u = unit(a), r = 2 + f * 7
                c.px(Int((tip.x + u.x * r).rounded(.down)), Int((tip.y + u.y * r).rounded(.down)), C(0xF0F4FF, 0.85 * (1 - f)))
            }
        }
        let php = C(0x8892BF, min(1, 3 * (1 - k))), ry = Int((tip.y - 2 - 6 * k).rounded(.down))
        c.pattern(Int(tip.x) + 3, ry, ["PP..P.P.PP.", "P.P.P.P.P.P", "PP..PPP.PP.", "P...P.P.P..", "P...P.P.P.."], ["P": php])
    }
    // Dust kicked up under its front feet as they land.
    if s >= 0.82, s < 0.98 {
        let k = (s - 0.82) / 0.16
        for (i, x) in [28.0, 33, 38, 43].enumerated() {
            let d = (Double(i) - 1.5) * 2 * k
            c.px(Int(x + d), 42 - Int(3 * k), C(0xB0A08A, 0.7 * (1 - k)))
            c.px(Int(x + d) + 1, 43 - Int(2 * k), C(0xB0A08A, 0.5 * (1 - k)))
        }
    }
}

/// A Mûmak's leg: a pillar with toenails, a dark crease down its back edge; `up` 1 while it's lifted.
private func drawMumakLeg(_ c: PixelCanvas, _ x: Int, _ col: Px, up: Int) {
    c.rect(x, 33, 7, 11 - up, col)
    c.rect(x, 36, 1, 6 - up, C(0x5A5048))
    for k in 0..<3 { c.px(x + 1 + k * 2, 43 - up, C(0xBCAE90)) }
}

/// Oli-PHP-aunt; `trunkUp` (in the signature) how far its trunk is swung up, 0…1, its hind legs left for the caller.
private func drawOliphauntBody(_ c: PixelCanvas, _ p: Pose, trunkUp: Double?) {
    let hide = C(0x7A6E64), hideDark = C(0x5A5048), hideLight = C(0x968A7E), far = C(0x62584F)
    let red = C(0xA82A24), redDark = C(0x7A1A16), gold = C(0xD8A83A), goldLight = C(0xF4D47A)
    let ivory = C(0xECE2C8), ivoryShade = C(0xBCAE90), wood = C(0x6A4A2A), woodDark = C(0x4A321C)
    // The legs: pillars with toenails; a diagonal pair lifts at each step.
    func leg(_ x: Int, _ col: Px, group: Int) {
        if trunkUp != nil, x == 7 || x == 13 { return }
        drawMumakLeg(c, x, col, up: p.step >= 0 && group == p.step ? 1 : 0)
    }
    leg(13, far, group: 1); leg(35, far, group: 0)
    c.oy += p.breathe
    // The tail, with a dark tuft.
    line(c, 6.5, 25, 3.5, 33, hideDark, 0.5)
    c.rect(2, 33, 2, 3, woodDark)
    // The body: a great barrel, darker underneath.
    c.ellipse(25, 28, 19, 9, hideDark)
    c.ellipse(25, 27, 19, 9, hide)
    for (x, y) in [(9, 30), (12, 33), (40, 31), (38, 34)] { c.px(x, y, hideDark) }
    c.oy -= p.breathe
    leg(7, hide, group: 0); leg(29, hide, group: 1)
    c.oy += p.breathe
    // The war blanket over its back: red, edged in gold, gold studs, and gold tassels along its hem.
    c.ellipse(24, 26, 13, 8, gold)
    c.ellipse(24, 26, 12, 7, red)
    c.ellipse(24, 29, 9, 2, redDark)
    c.ellipse(24, 28, 9, 2, red)
    for (x, y) in [(18, 28), (24, 30), (30, 28), (24, 25), (15, 25), (33, 25)] { c.px(x, y, goldLight) }
    for x in [14, 19, 24, 29, 34] {
        let dx = Double(x - 24) / 13
        let hem = 26 + Int((8 * (1 - dx * dx).squareRoot()).rounded())
        c.px(x, hem + 1, gold); c.px(x, hem + 2, goldLight)
    }
    // The howdah: a wooden platform and rail, a red canopy fringed in gold, and the tiny rider's head between.
    c.rect(16, 16, 17, 3, wood)
    c.rect(16, 18, 17, 1, woodDark)
    c.rect(16, 14, 17, 1, wood)
    c.rect(17, 15, 15, 1, redDark)
    for x in [19, 23, 27] { c.px(x, 15, gold) }
    c.rect(17, 11, 1, 5, woodDark); c.rect(31, 11, 1, 5, woodDark)
    c.rect(22, 12, 3, 2, C(0x6A4030))
    c.rect(22, 11, 3, 1, red)
    c.px(24, 12, ink)
    c.pattern(16, 7, [
        "........G........",
        "......RRRRR......",
        "...RRRRRRRRRRR...",
        "rRRRRRRRRRRRRRRRr",
        "G.G.G.G.G.G.G.G.G",
    ], ["R": red, "r": redDark, "G": gold])
    // The head, tossing with a sweep (up on the wind-up, down on the strike).
    let toss: Double = p.melee.map { min(1, max(-1, (wrapped($0) + 20) / 70)) } ?? 0
    let hd = Int((toss * 1.5).rounded())
    c.oy += hd
    for k in [1, 0] { drawTusks(c, turn: toss * 25, far: k == 1, ivory: ivory, shade: ivoryShade) }
    c.ellipse(45, 25, 8, 8, hide)
    c.ellipse(46, 20, 4, 2, hideLight)
    c.rect(44, 18, 6, 3, gold); c.rect(44, 18, 6, 1, goldLight); c.px(46, 19, red)
    c.px(48, 24, ink); c.px(47, 23, hideDark)
    c.rect(46, 26, 4, 1, red)
    // The great ear, hanging over where the head meets the body.
    c.ellipse(39, 26, 5, 7, hideDark)
    c.ellipse(39, 26, 4, 6, far)
    c.rect(39, 21, 1, 9, hideDark)
    // The trunk, ridged, hanging to the floor and curling forward, swinging a little.
    let swing: Double = p.walking ? (p.step == 0 ? 6 : -6) : 4 * sin(p.lt * 1.1)
    var trunk = curve((51.5, 28.5), angle: 82 + swing * 0.5, bend: -80 + swing, n: 7, step: 2)
    if let up = trunkUp {                                                          // swung up and curling back
        trunk = curve((51.5, 28.5), angle: 82 + swing * 0.5 + (-30 - 82 - swing * 0.5) * up,
                      bend: -80 + swing + (-90 + 80 - swing) * up, n: 7, step: 2)
    }
    taper(c, trunk, r0: 2.2, r1: 1.0, hide)
    for q in trunk.dropFirst().dropLast() where q.y + Double(c.oy) < 43 { c.px(Int(q.x.rounded(.down)) - 1, Int(q.y), hideDark) }
    // The near tusks, and a smear behind a fast sweep.
    for (i, ta) in p.trail.enumerated() {
        let t: Double = min(1, max(-1, (wrapped(ta) + 20) / 70)) * 25
        drawTusks(c, turn: t, far: false, ivory: C(0xF4EEDC), shade: C(0xF4EEDC), alpha: 0.32 / Double(i + 1))
    }
    drawTusks(c, turn: toss * 25, far: false, ivory: ivory, shade: ivoryShade)
}

/// A Mûmak's pair of tusks on one side, an upper long one and a lower shorter one, curving forward and up from under
/// its eye, turned `turn` degrees (down on the strike). The far pair sits a little back and up, in the shade colour.
private func drawTusks(_ c: PixelCanvas, turn: Double, far: Bool, ivory: Px, shade: Px, alpha: Double = 1) {
    let off: (x: Double, y: Double) = far ? (-2, -1) : (0, 0)
    let col = (far ? shade : ivory).alpha(alpha)
    let upper = curve((mumakTusks.x + off.x, mumakTusks.y + off.y), angle: 15 + turn, bend: -80, n: 6, step: 2)
    let lower = curve((mumakTusks.x - 1 + off.x, mumakTusks.y + 2 + off.y), angle: 35 + turn, bend: -70, n: 5, step: 2)
    taper(c, upper, r0: 1.2, r1: 0.5, col)
    taper(c, lower, r0: 1.0, r1: 0.45, col)
    if !far, alpha == 1 {
        for pts in [upper, lower] { let q = pts[1]; c.px(Int(q.x.rounded(.down)), Int(q.y.rounded(.down)) + 1, shade) }
    }
}

// MARK: - Barrow-write

/// Where the Barrow-wight's cold magic leaves: its outstretched, ringed hand.
private let wightHand: (x: Double, y: Double) = (42.5, 33.5)

/// Barrow-write, a Barrow-wight: Clawd's block turned pale and see-through, blue-white, fading into wisps below the
/// waist where the legs should be (it floats), with cold glowing pale-green eyes. A tattered grey shroud over its head
/// and down its sides, its rags trailing and stirring; a gold torc at its throat, gold rings on its bony fingers. It
/// casts from its outstretched hand, a cold pale-green ray. Signature: "Cold be hand and heart and disk…". It chants,
/// its eyes flaring and cold notes drifting up out of its hood, while its ringed hand lets go of the sleeve, drops to
/// the floor (…0.1) and crawls off along it on its fingertips, stops to drum its fingers (0.45…0.55), crawls back
/// and leaps up onto the wrist again (0.85…0.95).
private func drawBarrowWight(_ c: PixelCanvas, _ p: Pose) {
    let ghost = C(0xC8DCF0, 0.72), ghostShade = C(0x96B0CC, 0.72), bone = C(0xDCEAF8, 0.9)
    let shroud = C(0x7A7E86), shroudDark = C(0x585C64), shroudLight = C(0x9498A0)
    let gold = C(0xD8A83A), goldLight = C(0xF4D47A)
    let eye = C(0xE8FFF0), eyeGlow = C(0x7FE8A8)
    let tick = Int(p.t * 6)
    let sig = p.signature.flatMap { $0 > 0 && $0 < 1 ? $0 : nil }
    c.oy += p.breathe
    // The body, pale and see-through, fading into wisps below the waist.
    c.rect(18, 26, 19, 11, ghost)
    c.rect(37, 26, 1, 11, ghostShade)
    for y in 37...42 where y + c.oy <= 43 {
        let k = Double(y - 37) / 6
        for x in 18...37 where noise(x * 7 + y * 13 + tick) > 0.25 + k * 0.6 {
            c.px(x, y, C(0xC8DCF0, 0.6 * (1 - k)))
        }
    }
    // The cold eyes, glowing.
    let pulse: Double = 0.5 + 0.5 * sin(p.lt * 2.6)
    let flare: Double = sig.map { 0.35 * habitArc($0, hold: 0.8) } ?? 0             // chanting
    for ex in [23.0, 33.0] {
        c.glowLine(ex, 30.5, ex, 30.5, core: eye, glow: eyeGlow, coreR: 0.4, glowR: 2.4 + flare * 2,
                   strength: 0.45 + 0.35 * pulse + flare)
    }
    c.rect(22, 29, 2, 3, eye); c.rect(32, 29, 2, 3, eye)
    // The gold torc round its throat, a heavy collar knobbed at the ends.
    c.pattern(19, 34, [
        "oGGGGGGGGGGGGGGGGo",
        "oLGGGGGGGGGGGGGGLo",
        ".dddddddddddddddd.",
    ], ["G": gold, "L": goldLight, "o": goldLight, "d": C(0x9A7020)])
    // The tattered shroud: a hood, falling down both sides, its rags trailing below and stirring.
    c.pattern(15, 19, [
        ".......SSSSSSSSSSSS.......",
        ".....SSSSSSSSSSSSSSSS.....",
        "....SSSSlSSSSSSSSSSSSS....",
        "...SSSlSSSSSSSSSSSSSSSS...",
        "..SSSSSSSSSSSSSSSSSSSSSd..",
        "..SSSSSSSSSSSSSSSSSSSSSd..",
        ".SSSSSdd..........ddSSSSd.",
        ".SSSd................dSSd.",
        ".SSS..................SSd.",
        "SSSd..................dSSd",
        "SSS....................SSd",
        "SlS....................SSd",
        "SSd....................SSd",
        "SSS....................dSd",
        "SSS....................SSd",
        "SdS....................SSd",
        "SSS....................SSd",
        ".SS....................Sd.",
    ], ["S": shroud, "d": shroudDark, "l": shroudLight])
    for (k, x) in [15, 16, 17, 38, 39, 40].enumerated() {
        let n = 2 + Int(noise(x * 5 + tick / 2 + k) * 4)
        for j in 0..<n where 37 + j + c.oy <= 43 {
            let rag = (k + j) % 3 == 0 ? shroudDark : shroud
            c.px(x + (j > 1 && noise(tick + x + j) > 0.6 ? 1 : 0), 37 + j, rag.alpha(1 - Double(j) / Double(n + 1)))
        }
    }
    // A bony hand reaching out of the shroud behind it, a ring on it.
    c.rect(12, 34, 3, 2, bone); c.px(11, 35, bone); c.px(13, 34, gold)
    // The casting arm: a ragged sleeve and a bony hand, clawed, rings on its fingers, raised as it casts.
    let up = p.armRaise
    c.rect(37, 32 - up, 3, 3, shroud); c.px(37, 34 - up, shroudDark)
    guard let s = sig, s > 0.02, s < 0.95 else {
        c.rect(40, 33 - up, 3, 2, bone)
        c.px(43, 32 - up, bone); c.px(43, 35 - up, bone)
        c.px(41, 33 - up, gold); c.px(42, 34 - up, goldLight)
        return
    }
    // The signature: the chant drifting up out of the hood, and the hand off on its own along the floor.
    c.px(40, 33, ghostShade); c.px(40, 34, ghost.alpha(0.5))                     // the bare wrist
    for i in 0..<3 {
        let f = frac(s * 2.5 + Double(i) / 3), x = Int((39 + f * 6 + 2 * sin(f * 9)).rounded()), y = Int((22 - f * 14).rounded())
        let col = eyeGlow.alpha(0.9 * (1 - f) * habitArc(s, hold: 0.8))
        c.rect(x, y, 2, 1, col); c.rect(x + 1, y - 3, 1, 3, col); c.px(x + 2, y - 3, col)
    }
    c.oy -= p.breathe
    drawCrawlingHand(c, s, bone: bone, gold: gold)
}

/// Where the Barrow-wight's hand is `s` through its signature, and which way it faces: dropping from the wrist to the
/// floor, crawling out, drumming its fingers, crawling back and leaping up onto the wrist again. Drawn as a big,
/// pale bony hand on its fingertips, a glinting gold ring on one finger, its fingers stepping and its knuckles bobbing
/// as it goes.
private func drawCrawlingHand(_ c: PixelCanvas, _ s: Double, bone: Px, gold: Px) {
    let floorY = 38.0
    var x = 40.0, y = floorY, back = false, gait = 0
    if s < 0.1 {
        let u = s / 0.1
        x = 40 + 2 * u; y = 33 + (floorY - 33) * u * u
    } else if s < 0.45 {
        let u = (s - 0.1) / 0.35
        x = 42 + 16 * u; gait = Int(u * 16) % 2
    } else if s < 0.55 {
        x = 58; gait = Int((s - 0.45) * 60) % 2
    } else if s < 0.85 {
        let u = (s - 0.55) / 0.3
        x = 58 - 16 * u; back = true; gait = Int(u * 14) % 2
    } else {
        let u = min(1, (s - 0.85) / 0.1)
        x = 42 - 2 * u; y = floorY - 10 * u * (1 - u) * 1.2 + (33 - floorY) * u * u; back = true
    }
    let rows: [String] = gait == 0
        ? ["...PPPPP...", "wPPPPPPPPP.", "wDDDPPDPPDP", ".F..F.GG.F.", "F...F..g..F", "F..F...F..F"]
        : ["....PPPPP..", "wPPPPPPPPP.", "wDDDPPDPPDP", "..F..F.GG.F", "..F..F.g.F.", ".F...F..F.."]
    let ix = Int(x.rounded(.down)), iy = Int(y.rounded(.down))
    let pale = C(0xF6FAFF), shade = C(0x8C9CB8), ring = Int(s * 40) % 5 == 0 ? C(0xFFF4C0) : C(0xF4D47A)
    c.pattern(ix, iy, back ? rows.map { String($0.reversed()) } : rows,
              ["P": pale, "D": shade, "F": C(0xC4D2E6), "w": C(0xC8DCF0, 0.6), "g": gold, "G": ring])
}

// MARK: - Wargh-rider

/// Where the rider's blade swings from: his fist, up over the warg's shoulders.
private let riderHand: (x: Double, y: Double) = (37.5, 26.5)

/// Wargh-rider: an orc astride a warg. The warg, a big shaggy grey-black wolf, runs along the bottom of the canvas,
/// its head forward: shaggy mane and ruff, a bushy tail, pointed ears laid back, a yellow eye under a scowl and its jaws
/// open on bared white teeth (wider as the rider strikes); its legs lift a diagonal pair at a time. The rider, Clawd in
/// mottled green orc skin with a crooked iron helmet, little tusks and a ragged leather jerkin, sits up on its back,
/// reins in one hand and a curved blade in the other, held up ready, a smear behind a fast swing. Signature: the warg
/// throws its head back and howls (…0.15), jaws wide, rings of sound rolling up off its muzzle, while the rider
/// whoops and waves his blade round over his head; then the head comes down again (0.75…0.9).
private func drawWargRider(_ c: PixelCanvas, _ p: Pose) {
    let fur = C(0x48484E), furDark = C(0x2A2A2E), furLight = C(0x6E6E76), farFur = C(0x343438)
    let tooth = C(0xF0ECE0), gum = C(0x5A1A1A), wolfEye = C(0xF0C040)
    let skin = C(0x5A6A4A), skinDark = C(0x46543A), skinLight = C(0x6E7E5C)
    let iron = C(0x5A5E66), ironDark = C(0x3E4248), ironLight = C(0x7A7E86)
    let leather = C(0x6A4A2E), leatherDark = C(0x4E3420)
    let sig = p.signature.flatMap { $0 > 0 && $0 < 1 ? $0 : nil }
    let howl: Double = sig.map { $0 < 0.15 ? smooth($0 / 0.15) : $0 < 0.75 ? 1 : 1 - smooth(($0 - 0.75) / 0.15) } ?? 0
    // The warg's legs: a thick upper leg, a thin shin, a paw; a diagonal pair lifts at each step.
    func leg(_ x: Int, _ col: Px, group: Int) {
        let up = p.step >= 0 && group == p.step ? 1 : 0
        c.rect(x, 34, 4, 4, col)
        c.rect(x + 1, 38, 2, 5 - up, col)
        c.rect(x + 1, 43 - up, 3, 1, col); c.px(x + 4, 43 - up, furLight)
    }
    leg(19, farFur, group: 1); leg(37, farFur, group: 0)
    c.oy += p.breathe
    // The bushy tail, flicking with its stride.
    let flick: Double = p.step >= 0 ? (p.step == 0 ? 1.5 : -1.5) : sin(p.lt * 2)
    line(c, 14, 31, 8, 27 + flick, fur, 1.5)
    line(c, 8, 27 + flick, 4, 29 + flick * 1.5, furDark, 1.0)
    // The body: long and shaggy, darker underneath, with a fringe along the belly and the mane along its back.
    c.ellipse(26, 33, 13, 5, furDark)
    c.ellipse(26, 32, 13, 5, fur)
    c.ellipse(17, 32, 5, 5, fur)
    c.ellipse(37, 32, 4, 5, fur)
    for x in stride(from: 16, through: 36, by: 3) { c.px(x, 38, furDark); c.px(x + 1, 37, furDark) }
    for (x, y) in [(12, 30), (20, 30), (24, 33), (30, 31), (14, 34), (33, 34)] { c.px(x, y, furLight) }
    for x in stride(from: 14, through: 40, by: 2) {
        let top = 27 - (x > 32 ? (x - 32) / 3 : 0)
        c.px(x, top, furDark); if x % 4 == 0 { c.px(x, top - 1, furDark) }
    }
    // The ruff round its neck, then the head: ears laid back, a scowl, jaws open on bared teeth.
    c.ellipse(40, 29, 3, 5, furDark)
    func head(_ c: PixelCanvas) {
        c.ellipse(43, 28, 4, 4, fur)
        c.pattern(39, 21, ["F...", "FF..", "FFF.", "FFFF"], ["F": fur])
        c.px(40, 23, gum)
        c.rect(46, 27, 5, 2, fur); c.rect(46, 27, 4, 1, furLight)
        c.px(50, 27, ink); c.px(47, 27, furDark)
        c.px(45, 26, wolfEye); c.px(44, 26, ink)
        c.rect(43, 25, 3, 1, furDark)
        let gape = howl > 0.5 || (p.melee != nil && !p.trail.isEmpty) ? 2 : 1
        c.rect(44, 29, 6, gape + 1, gum)
        for x in [45, 47, 49] { c.px(x, 29, tooth) }
        for x in [46, 48] { c.px(x, 29 + gape, tooth) }
        c.rect(43, 30 + gape, 6, 2, fur); c.rect(43, 31 + gape, 6, 1, furDark)
    }
    // Howling, the head is thrown back, and rings of sound roll up off the muzzle.
    if howl > 0 {
        let neck: (x: Double, y: Double) = (41, 29.5)
        turned(c, about: neck, degrees: -45 * howl, head)
        if let s = sig, s > 0.15, s < 0.8 {
            let tip = turn((50.5, 29.5), about: neck, -45 * howl)
            for j in 0..<3 {
                let f = frac((s - 0.15) * 4 + Double(j) / 3)
                for a in stride(from: -85.0, through: -5, by: 10) {
                    let u = unit(a - 45 * howl + 45), r = 2 + f * 9
                    c.px(Int((tip.x + u.x * r).rounded(.down)), Int((tip.y + u.y * r).rounded(.down)), C(0xD8DCE8, 0.85 * (1 - f)))
                }
            }
        }
    } else {
        head(c)
    }
    c.oy -= p.breathe
    leg(14, fur, group: 0); leg(33, fur, group: 1)
    c.oy += p.breathe
    // The rider: Clawd in orc skin, astride, a leg down the warg's side.
    c.rect(26, 31, 3, 4, leather); c.rect(26, 35, 4, 2, leatherDark)
    c.rect(18, 20, 16, 11, skin)
    c.rect(33, 20, 1, 11, skinDark)
    for (x, y) in [(20, 22), (31, 21), (25, 23)] { c.px(x, y, skinLight) }
    c.pattern(15, 21, ["SS..", ".SSS", "..SS"], ["S": skin]); c.px(15, 21, skinDark)
    c.rect(22, 23, 2, 2, ink); c.rect(29, 23, 2, 2, ink)
    c.px(22, 23, C(0xC8A03A)); c.px(29, 23, C(0xC8A03A))
    c.rect(23, 26, 7, 1, C(0x2E3424))
    if howl > 0.5 { c.rect(24, 26, 5, 2, C(0x2E3424)); c.rect(25, 27, 3, 1, gum) }    // whooping
    c.px(24, 25, tooth); c.px(29, 25, tooth)
    c.rect(18, 27, 16, 4, leather)
    c.rect(18, 29, 16, 1, leatherDark)
    c.px(21, 28, leatherDark); c.px(30, 27, leatherDark)
    // The crooked iron helmet, a spike on top.
    c.pattern(17, 16, [
        "..........I.......",
        ".......IIIII......",
        "....IIIhIIIIIIi...",
        "..IIIhIIIIIIdIIIi.",
        "IIIIIIIIIIIIIIIIIi",
    ], ["I": iron, "h": ironLight, "i": ironDark, "d": ironDark])
    // The reins, from his fist down to the warg's jaws.
    line(c, 33, 29, 44, 30, leatherDark, 0.3)
    // The blade, held up ready; swung, a smear behind it; then his fist round the grip.
    var blade = p.melee ?? -50
    if let s = sig { blade += howl * (-45 + 35 * sin((s - 0.1) * 6 * .pi)) }   // waved round over his head
    for (i, a) in (p.melee == nil ? [] : p.trail).enumerated() {
        let u = unit(a), h = riderHand
        c.glowLine(h.x + u.x * 4, h.y + u.y * 4, h.x + u.x * 15, h.y + u.y * 15, core: C(0xD8DCE4), glow: C(0x8A8E98),
                   coreR: 0.5, glowR: 1.6, strength: 0.3 / Double(i + 1))
    }
    drawRiderScimitar(c, angle: blade)
    c.rect(34, 26, 2, 2, leather)
    c.rect(36, 25, 3, 3, skin); c.px(38, 27, skinDark)
}

/// The rider's scimitar: a short grip, a plain crossguard and a curved blade that widens toward the tip and sweeps back.
private func drawRiderScimitar(_ c: PixelCanvas, angle: Double) {
    let h = riderHand, u = unit(angle), n = (x: u.y, y: -u.x)                   // n: toward the back of the blade
    let blade = C(0xA8ACB4), edge = C(0x6E727C)
    func at(_ d: Double, _ o: Double = 0) -> (x: Double, y: Double) { (h.x + u.x * d + n.x * o, h.y + u.y * d + n.y * o) }
    let g0 = at(-2), g1 = at(1.5)
    line(c, g0.x, g0.y, g1.x, g1.y, C(0x3A2A1E), 0.6)
    var prev = at(2.5)
    for i in 1...6 {
        let f = Double(i) / 6
        let q = at(2.5 + f * 12, f * f * 3.5)
        line(c, prev.x, prev.y, q.x, q.y, blade, 0.7 + f * 0.4)
        let e0 = (prev.x - n.x * 0.8, prev.y - n.y * 0.8), e1 = (q.x - n.x * (0.8 + f * 0.4), q.y - n.y * (0.8 + f * 0.4))
        line(c, e0.0, e0.1, e1.0, e1.1, edge, 0.3)
        prev = q
    }
    let q0 = at(2, -2.2), q1 = at(2, 2.2)
    line(c, q0.x, q0.y, q1.x, q1.y, C(0x4A4E58), 0.55)
}

// MARK: - Shared helpers

/// The points along a curving limb (a tentacle, a tusk, a trunk): from `root`, setting off along `angle` (degrees, 0
/// forward, -90 up) and turning `bend` degrees more by its tip, the turn tightening toward the tip; `n` steps of `step`.
private func curve(_ root: (x: Double, y: Double), angle: Double, bend: Double, n: Int, step: Double, power: Double = 2) -> [(x: Double, y: Double)] {
    var pts = [root]
    for i in 1...n {
        let f = Double(i) / Double(n)
        let u = unit(angle + bend * pow(f, power)), q = pts[pts.count - 1]
        pts.append((q.x + u.x * step, q.y + u.y * step))
    }
    return pts
}

/// Draws `pts` as a limb tapering from half-width `r0` at the root to `r1` at the tip, never through the floor.
private func taper(_ c: PixelCanvas, _ pts: [(x: Double, y: Double)], r0: Double, r1: Double, _ col: Px) {
    let floor = Double(43 - c.oy) + 0.5
    for i in 1..<pts.count {
        let a = pts[i - 1], b = pts[i], f = Double(i) / Double(pts.count - 1)
        line(c, a.x, min(a.y, floor), b.x, min(b.y, floor), col, r0 + (r1 - r0) * f)
    }
}

/// An angle in degrees brought into -180…180.
private func wrapped(_ a: Double) -> Double {
    var w: Double = a.truncatingRemainder(dividingBy: 360)
    if w > 180 { w -= 360 } else if w <= -180 { w += 360 }
    return w
}

private func unit(_ degrees: Double) -> (x: Double, y: Double) {
    let r: Double = degrees * .pi / 180
    return (cos(r), sin(r))
}

private let clear = C(0x000000, 0)

/// Smoothstep: 0→1 eased at both ends.
private func smooth(_ x: Double) -> Double {
    let u = min(1, max(0, x))
    return u * u * (3 - 2 * u)
}

/// The point `q` turned `degrees` about `o` (negative: the front lifts).
private func turn(_ q: (x: Double, y: Double), about o: (x: Double, y: Double), _ degrees: Double) -> (x: Double, y: Double) {
    let r: Double = degrees * .pi / 180, dx = q.x - o.x, dy = q.y - o.y
    return (o.x + dx * cos(r) - dy * sin(r), o.y + dx * sin(r) + dy * cos(r))
}

/// Draws `art` on a scratch canvas (same offsets as `c`) and copies it onto `c` turned `degrees` about `pivot`
/// (negative: the front lifts), pixel by nearest pixel: a Mûmak rearing, a warg throwing its head back.
private func turned(_ c: PixelCanvas, about pivot: (x: Double, y: Double), degrees: Double, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(c.w, c.h)
    s.ox = c.ox; s.oy = c.oy; s.baseY = c.baseY
    art(s)
    let o = (x: pivot.x + Double(c.ox), y: pivot.y + Double(c.oy + c.baseY))
    let (ox, oy, by) = (c.ox, c.oy, c.baseY)
    c.ox = 0; c.oy = 0; c.baseY = 0
    defer { c.ox = ox; c.oy = oy; c.baseY = by }
    for y in 0..<c.h {
        for x in 0..<c.w {
            let from = turn((Double(x) + 0.5, Double(y) + 0.5), about: o, -degrees)
            let sx = Int(from.x.rounded(.down)), sy = Int(from.y.rounded(.down))
            guard sx >= 0, sy >= 0, sx < s.w, sy < s.h else { continue }
            let i = (sy * s.w + sx) * 4, a = s.buf[i + 3]
            guard a > 0 else { continue }
            let m = 255 / Double(a)
            c.px(x, y, Px(r: UInt8(min(255, Double(s.buf[i]) * m)), g: UInt8(min(255, Double(s.buf[i + 1]) * m)),
                          b: UInt8(min(255, Double(s.buf[i + 2]) * m)), a: a))
        }
    }
}

/// A solid pixel line (no glow), `r` its half-width.
private func line(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, _ r: Double = 0.7) {
    c.glowLine(x0, y0, x1, y1, core: col, glow: clear, coreR: r, glowR: r + 0.1)
}
