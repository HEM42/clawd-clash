import Foundation

// Villains: the comic side of the monsters. Ronnie Strickland, Guy Mann, the Trashman, the Tulpa, the Mothmen, the Rain
// King and the Teliko. Clawd in costume like everyone else, or Clawd underneath it (the Trashman's rubbish, the Tulpa's
// mud, the Mothmen's leaves); the episodes they come from are the funny ones, and so are they.

let filesVillains8: [FilesVillain: Persona] = [
    .ronnieStrickland: Persona(name: "Ronnie Strickland", weapon: .saber, headTop: 19, signature: 3.4,
                               callout: "Pizza's here!", draw: drawRonnie),
    .guyMann: Persona(name: "Guy Mann", weapon: .saber, headTop: 18, signature: 3.2, callout: "I'm just a guy!",
                      draw: drawGuyMann),
    .trashman: Persona(name: "The Trashman", weapon: .saber, headTop: 17, signature: 4.0, callout: "Take out the trash.",
                       draw: drawTrashman),
    .tulpa: Persona(name: "The Tulpa", weapon: .saber, canSit: false, bulk: 2, headTop: 19, signature: 3.6,
                    callout: "Mmmrrrgh.", draw: drawTulpa),
    .mothmen: Persona(name: "The Mothmen", weapon: .saber, headTop: 12, signature: 3.6, draw: drawMothmen),
    .rainKing: Persona(name: "The Rain King", weapon: .lightning, magic: Magic(core: C(0xE8F4FF), glow: C(0x3A7CFF)),
                       pivot: (44.0, 31.0), headTop: 16, signature: 3.8, callout: "Looks like rain.",
                       draw: drawRainKing),
    .teliko: Persona(name: "The Teliko", weapon: .blaster, shot: .arrow, muzzle: (50, 30), headTop: 16, signature: 3.2,
                     callout: "Shhh.", draw: drawTeliko),
]

// MARK: - Shared bits

/// 0 before `a`, 1 after `b`, a straight line between.
private func ramp(_ s: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (s - a) / (b - a))) }

/// A line of `w`×`w` dots from (x0, y0) to (x1, y1).
private func seg(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ col: Px, w: Int = 1) {
    let n = max(1, Int(max(abs(x1 - x0), abs(y1 - y0)).rounded(.up)))
    for k in 0...n {
        let f = Double(k) / Double(n)
        c.rect(Int((x0 + (x1 - x0) * f).rounded(.down)), Int((y0 + (y1 - y0) * f).rounded(.down)), w, w, col)
    }
}

/// An arm swung out at `angle` degrees from the shoulder (39, 34), `length` long: the sleeve then the hand. Returns
/// where the hand ends, for whatever it's holding.
@discardableResult
private func swingArm(_ c: PixelCanvas, angle: Double, sleeve: Px, hand: Px, length: Double = 8,
                      alpha: Double = 1) -> (x: Double, y: Double) {
    let r = angle * .pi / 180, sx = 39.0, sy = 34.0
    let ex = sx + cos(r) * length * 0.6, ey = sy + sin(r) * length * 0.6
    let hx = sx + cos(r) * length, hy = sy + sin(r) * length
    seg(c, sx, sy, ex, ey, sleeve.alpha(alpha), w: 2)
    seg(c, ex, ey, hx, hy, hand.alpha(alpha), w: 2)
    return (hx, hy)
}

/// Three claws fanning out from (x, y) at `angle` degrees.
private func claws(_ c: PixelCanvas, _ x: Double, _ y: Double, angle: Double, _ col: Px, alpha: Double = 1) {
    let r = angle * .pi / 180
    for spread in [-0.5, 0.0, 0.5] {
        seg(c, x + 0.5, y + 0.5, x + 0.5 + cos(r + spread) * 3, y + 0.5 + sin(r + spread) * 3, col.alpha(alpha))
    }
}

/// Copies `src` into `c`, each pixel read from `map(x, y)` on `src` (nil: nothing), faded by `alpha`: squashes and
/// stretches a whole drawn figure.
private func remap(_ src: PixelCanvas, into c: PixelCanvas, alpha: Double = 1, map: (Int, Int) -> (Int, Int)?) {
    for y in 0..<c.h {
        for x in 0..<c.w {
            guard let (sx, sy) = map(x, y), sx >= 0, sy >= 0, sx < src.w, sy < src.h else { continue }
            let i = (sy * src.w + sx) * 4, a = src.buf[i + 3]
            guard a > 0 else { continue }
            let m = 255 / Double(a)
            let px = Px(r: UInt8(min(255, Double(src.buf[i]) * m)), g: UInt8(min(255, Double(src.buf[i + 1]) * m)),
                        b: UInt8(min(255, Double(src.buf[i + 2]) * m)), a: a)
            c.px(x, y, px.alpha(alpha))
        }
    }
}

// MARK: - Ronnie Strickland

/// Ronnie Strickland: the hapless pizza-delivery boy of "Bad Blood", who happens to be a vampire. Clawd in a red cap
/// with its brim turned forward, a red polo shirt with a name badge and khaki trousers; two little fangs over his lip.
/// In a fight he swings the pizza box. Signature: he holds the box out and flips the lid open on a pepperoni pizza,
/// steam rising, then gives you a big toothy grin, fangs and all.
private func drawRonnie(_ c: PixelCanvas, _ p: Pose) {
    let red = C(0xC8302A), redD = C(0x8E1E1A), khaki = C(0xB8A478), box = C(0xE8DCC0), boxD = C(0xB8A880)
    let redL = C(0xE04A3E)
    let sig = p.signature
    let offering = sig.map { $0 > 0.06 && $0 < 0.94 } ?? false
    let open = sig.map { ramp($0, 0.15, 0.3) - ramp($0, 0.82, 0.92) } ?? 0
    let grin = sig.map { $0 > 0.5 && $0 < 0.85 } ?? false

    drawLegs(c, Look(leg: khaki), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0x2A2A2E))
    c.oy += p.breathe
    drawBody(c, Look(arm: red))
    // The polo shirt, its collar and the name badge.
    c.rect(18, 34, 20, 4, red); c.rect(37, 34, 1, 4, redD); c.rect(18, 37, 20, 1, redD)
    c.pattern(25, 34, ["WW..WW", ".WWWW."], ["W": C(0xF2EEE6)])
    c.rect(20, 35, 3, 2, C(0xF2EEE6)); c.px(21, 35, red)
    c.rect(33, 34, 3, 1, redL); c.rect(34, 35, 1, 2, redD)          // a lit shoulder, a crease
    c.px(27, 35, C(0xF2EEE6)); c.px(28, 36, C(0xF2EEE6))             // the placket's buttons
    c.rect(18, 37, 19, 1, C(0x6A5A3A)); c.px(27, 37, C(0xC8C8C8))    // the belt over the khakis
    // The cap: crown over the head down to the body, the brim out in front.
    c.pattern(17, 20, [
        "......RRRLLLRRRR......",
        "....RRLLRRRRRRRRRR....",
        "...RLLRRRWWWRRRRRrR...",
        "..RRRRRRRWRWRRRRRrRR..",
        "..RRRRRRRRRRRRRRRRRRRBBBB",
        ".rrrrrrrrrrrrrrrrrrrrBBBBB",
    ], ["R": red, "r": redD, "W": C(0xF2EEE6), "B": redD, "L": redL])
    // The fangs (a grin shows the whole row).
    if grin {
        c.rect(24, 32, 8, 2, ink); for x in [24, 26, 28, 30] { c.px(x, 32, C(0xF8F8F2)) }
        c.px(25, 33, C(0xF8F8F2)); c.px(30, 33, C(0xF8F8F2))
    } else {
        // A closed mouth with a fang hanging down at each end.
        c.rect(25, 32, 6, 1, C(0x5A2418))
        c.rect(25, 32, 1, 2, C(0xF8F8F2)); c.rect(30, 32, 1, 2, C(0xF8F8F2))
    }
    c.rect(15, 33, 3, 3, red); c.rect(15, 35, 3, 1, redD)   // the short sleeve's hem

    if offering {
        // The box held out flat; the lid tips up on the pizza and its steam.
        c.rect(38, 32, 3, 3, red)
        c.rect(40, 33, 12, 2, box); c.rect(40, 35, 12, 1, boxD)
        if open > 0 {
            c.rect(41, 32, 10, 1, C(0xE8A040)); for x in [42, 45, 48] { c.px(x, 32, C(0xB8302A)) }
            let lidH = Int(open * 9)
            c.rect(40, 32 - lidH, 1, lidH, boxD); c.rect(41, 32 - lidH, 1, lidH, box)
            for i in 0..<3 {
                let k = (p.t * 0.8 + Double(i) / 3).truncatingRemainder(dividingBy: 1)
                c.px(43 + i * 3 + Int(sin(k * 6) * 1), 31 - Int(k * 8), C(0xF2F2F2, 0.6 * (1 - k)))
            }
        } else {
            c.rect(40, 32, 12, 1, boxD)
        }
        return
    }
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() {
            let h = swingArm(c, angle: ta, sleeve: red, hand: clawdOrange, alpha: 0.35 / Double(i + 1))
            c.rect(Int(h.x) - 3, Int(h.y) - 1, 7, 3, box.alpha(0.35 / Double(i + 1)))
        }
        let h = swingArm(c, angle: a, sleeve: red, hand: clawdOrange)
        c.rect(Int(h.x) - 3, Int(h.y) - 1, 7, 3, box); c.rect(Int(h.x) - 3, Int(h.y) + 2, 7, 1, boxD)
    } else {
        // The box held by his side.
        c.rect(38, 33, 3, 3, red); c.rect(40, 30, 2, 9, box); c.rect(42, 30, 1, 9, boxD)
    }
}

// MARK: - Guy Mann

/// Guy Mann: the Were-Monster, a lizard who woke up one day turned into a man and hates it. Clawd as a green lizard,
/// scaly, a ridge of spines over his head, big yellow eyes with slit pupils and a tail behind him, in a brown sports
/// jacket over a shirt and tie that he wears like a disguise. He rakes with his claws. Signature: he pulls out a phone
/// and frets at it, its screen lighting his face, then looks up in despair.
private func drawGuyMann(_ c: PixelCanvas, _ p: Pose) {
    let scale = C(0x5E9A4A), scaleD = C(0x3E7232), scaleL = C(0x86C06A), belly = C(0xC8D890)
    let jacket = C(0x8A6A42), jacketD = C(0x6A4E2E), shirt = C(0xEDEDE6), tie = C(0xC8A030)
    let sig = p.signature
    let phone = sig.map { $0 > 0.08 && $0 < 0.92 } ?? false
    let despair = sig.map { $0 > 0.62 && $0 < 0.9 } ?? false

    // The tail, curling behind him.
    let wag = Int(sin(p.t * 2.2).rounded())
    c.pattern(7, 36 + wag, ["..TT.......", ".TTTTT.....", "TTTTTTTTTT.", ".....TTTTTT"], ["T": scale])
    c.px(8, 37 + wag, scaleD)
    drawLegs(c, Look(leg: C(0x5A4A3A)), step: p.step)
    drawDressShoes(c, step: p.step, color: C(0x2E241A))
    c.oy += p.breathe
    drawBody(c, Look(body: scale, shade: scaleD, arm: jacket, eye: nil))
    // Scales: short lit arcs over the head, and a shaded run down the far side.
    for i in 0..<7 {
        let x = 19 + Int(noise(i + 300) * 15), y = 26 + Int(noise(i + 320) * 6)
        c.rect(x, y, 2, 1, scaleL); c.px(x + 2, y + 1, scale)
    }
    c.rect(22, 33, 12, 1, belly)
    // The spines over his head, down to the body.
    c.pattern(18, 20, [
        "...S.....S.....S....",
        "..SSS...SSS...SSS...",
        ".SSSSS.SSSSS.SSSSS..",
        "SSSSSSSSSSSSSSSSSSSS",
        "SSSSSSSSSSSSSSSSSSSS",
        "SSSSSSSSSSSSSSSSSSSS",
    ], ["S": scaleD])
    c.rect(18, 23, 20, 3, scale)
    // The eyes: yellow, slit pupils (wide with despair).
    for x in [21, 31] {
        c.rect(x, 27, 4, 3, C(0xF0D840)); c.rect(x + 1, 27, despair ? 2 : 1, 3, ink)
    }
    c.rect(24, 31, 8, 1, scaleD)   // the long mouth
    // The jacket, shirt and tie.
    c.rect(18, 34, 20, 4, jacket); c.rect(37, 34, 1, 4, jacketD); c.rect(18, 37, 20, 1, jacketD)
    c.pattern(24, 34, ["lSTTSl", ".lTTl.", "..TT..", "..TT.."], ["l": jacketD, "S": shirt, "T": tie])
    c.rect(18, 34, 3, 1, C(0xA6845A)); c.rect(33, 34, 3, 1, C(0xA6845A))   // lit shoulders
    c.rect(20, 35, 1, 2, jacketD); c.rect(32, 36, 3, 1, jacketD)          // a fold, a pocket flap
    c.rect(15, 33, 3, 3, jacket); c.rect(15, 35, 3, 1, shirt); c.px(15, 36, scale); c.px(17, 36, scale)

    if phone {
        // The phone up in front of his face, its screen glowing on him.
        c.rect(36, 30, 3, 4, jacket)
        c.rect(38, 26, 4, 6, C(0x1E1E24)); c.rect(39, 27, 2, 4, C(0x8AD0FF))
        c.rect(30, 26, 8, 7, C(0x8AD0FF, 0.12))
        return
    }
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() {
            let h = swingArm(c, angle: ta, sleeve: jacket, hand: scale, alpha: 0.35 / Double(i + 1))
            claws(c, h.x, h.y, angle: ta, C(0xE8E0C0), alpha: 0.35 / Double(i + 1))
        }
        let h = swingArm(c, angle: a, sleeve: jacket, hand: scale)
        claws(c, h.x, h.y, angle: a, C(0xE8E0C0))
    } else {
        c.rect(38, 33, 3, 3, jacket); c.px(38, 36, scale); c.px(40, 36, scale)
    }
}

// MARK: - The Trashman

/// The Trashman of "Home Again": a man made of rubbish, glued together out of bin bags, newspaper, flattened cans and
/// takeaway boxes, a sticking plaster across the place his nose should be and two dark holes for eyes. Flies buzz round
/// him. He clubs you with a lumpy arm of junk. Signature: he slumps down into a heap of rubbish on the pavement, then
/// pulls himself back up out of it.
private func drawTrashman(_ c: PixelCanvas, _ p: Pose) {
    // Flies, always.
    for i in 0..<2 {
        let a = p.t * (3 + Double(i)) + Double(i) * 2
        c.px(28 + Int(cos(a) * Double(11 + i * 2)), 20 + Int(sin(a * 1.3) * 4), C(0x1A1A1A))
    }
    guard let s = p.signature, s > 0.05, s < 0.95 else { trashFigure(c, p); return }
    let slump = ramp(s, 0.08, 0.4) - ramp(s, 0.6, 0.9)
    let fig = PixelCanvas(c.w, c.h)
    trashFigure(fig, p)
    // Squashed down onto the ground and spread wider: a heap.
    let hf = 1 - 0.7 * slump, wf = 1 + 0.35 * slump
    remap(fig, into: c) { x, y in
        (Int(((Double(x) - 28) / wf + 28).rounded(.down)), Int(((Double(y) - 44) / hf + 44).rounded(.down)))
    }
    if slump > 0.5 {   // a can rolled off the heap
        c.rect(44 + Int(slump * 4), 41, 3, 2, C(0xB8BCC4)); c.px(44 + Int(slump * 4), 41, C(0xC8302A))
    }
}

private func trashFigure(_ c: PixelCanvas, _ p: Pose) {
    let bag = C(0x2E3238), bagL = C(0x4A5058), paper = C(0xD8D4C4), brown = C(0x8A6A42), can = C(0xB8BCC4)
    // Legs: rolled-up newspaper and bag.
    drawLegs(c, Look(leg: bag), step: p.step)
    if !seatedPose { for (i, lx) in [19, 23, 31, 35].enumerated() where i % 2 == 0 { c.rect(lx, 38, 2, 2, paper) } }
    c.oy += p.breathe
    // A lumpy body, a little wider than Clawd's: a bin bag with two knots of it on top.
    c.rect(16, 22, 24, 16, bag)
    c.pattern(16, 19, [
        "...BBB..........BBB.....",
        "..BBBBBBBBBBBBBBBBBB....",
        ".BBBBBBBBBBBBBBBBBBBBBB.",
    ], ["B": bag])
    // A few big patches that read at a glance: newspaper, a takeaway box, a can, and two folds of the bag.
    c.rect(18, 23, 6, 4, paper); for y in [24, 26] { c.rect(19, y, 4, 1, C(0x8A8676)) }
    c.rect(31, 33, 6, 4, brown); c.rect(31, 33, 6, 1, C(0xA8865A))
    c.rect(19, 33, 3, 4, can); c.rect(19, 34, 3, 1, C(0xC8302A))
    c.rect(27, 21, 8, 1, bagL); c.rect(36, 25, 1, 6, bagL)
    // The face: two holes for eyes, the plaster across where a nose would be.
    c.rect(22, 28, 3, 2, C(0x0A0A0C)); c.rect(31, 28, 3, 2, C(0x0A0A0C))
    c.rect(25, 30, 6, 2, C(0xE0B890)); c.px(27, 30, C(0xC8986E)); c.px(28, 31, C(0xC8986E))
    c.rect(24, 33, 7, 1, C(0x0A0A0C))
    // A lumpy arm of junk, swung or hanging.
    c.rect(13, 30, 3, 6, bag)
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() {
            let h = swingArm(c, angle: ta, sleeve: bag, hand: brown, length: 9, alpha: 0.35 / Double(i + 1))
            c.rect(Int(h.x) - 1, Int(h.y) - 1, 4, 4, brown.alpha(0.35 / Double(i + 1)))
        }
        let h = swingArm(c, angle: a, sleeve: bag, hand: brown, length: 9)
        c.rect(Int(h.x) - 1, Int(h.y) - 1, 4, 4, brown); c.px(Int(h.x), Int(h.y) - 1, can)
    } else {
        c.rect(40, 30, 3, 7, bag); c.rect(40, 36, 3, 2, brown)
    }
}

// MARK: - The Tulpa

/// The Tulpa of "Arcadia": a thing of mud and muck wished into being, hunched and dripping, its long arms hanging to
/// the ground, little bits of rubbish stuck in it (an eggshell, an orange peel, a bottle cap) and two pinprick red eyes
/// deep in its head. No legs to speak of: it oozes along. It swipes with a long muddy arm. Signature: it sinks into a
/// puddle of mud and wells back up out of it, summoned again.
private func drawTulpa(_ c: PixelCanvas, _ p: Pose) {
    guard let s = p.signature, s > 0.04, s < 0.96 else { tulpaFigure(c, p); return }
    let sink = ramp(s, 0.06, 0.35) - ramp(s, 0.6, 0.92)
    let mud = C(0x3A2A1C)
    c.ellipse(28, 43, 13, 2, mud); c.ellipse(28, 43, 10, 1, C(0x5A4430))
    guard sink < 0.98 else { return }
    let fig = PixelCanvas(c.w, c.h)
    tulpaFigure(fig, p)
    // Sinking: the figure slides down and is cut off at the puddle's surface.
    let drop = Int((sink * 24).rounded())
    remap(fig, into: c) { x, y in y <= 42 ? (x, y - drop) : nil }
    if sink > 0.1 { for i in 0..<3 { c.px(20 + i * 8 + Int(sin(p.t * 5 + Double(i)) * 2), 41, C(0x6A5440)) } }
}

private func tulpaFigure(_ c: PixelCanvas, _ p: Pose) {
    let mud = C(0x4A3624), mudD = C(0x2E2016), mudL = C(0x6A5038)
    c.oy += p.breathe
    // The hunched creature: a hump of a back, the head pushed forward low on the right, a narrow waist, long arms
    // hanging to fists at its knees, and the bottom oozing out into the ground. Swiping, the right arm is off swinging.
    var rows = [
        "..........MMMMM...............",
        "........MMMMMMMMM.............",
        "......MMMMMMMMMMMMM...........",
        ".....MMMMMMMMMMMMMMMM...MMMM..",
        "....MMMMMMMMMMMMMMMMMMMMMMMMM.",
        "...MMMMMMMMMMMMMMMMMMMMMMMMMMM",
        "...MMMMMMMMMMMMMMMMMMMMMMMMMMM",
        "..MMMMMMMMMMMMMMMMMMMMMMMMMMMM",
        "..MMMMMMMMMMMMMMMMMMMMMMMMMMM.",
        ".MMMMMMMMMMMMMMMMMMMMMMMMMMM..",
        ".MMM.MMMMMMMMMMMMMMMMMMM.MMM..",
        "MMM..MMMMMMMMMMMMMMMMMMM..MMM.",
        "MMM...MMMMMMMMMMMMMMMMM...MMM.",
        "MM....MMMMMMMMMMMMMMMMM....MM.",
        "MM....MMMMMMMMMMMMMMMMM....MM.",
        "MM.....MMMMMMMMMMMMMMM.....MM.",
        "MM.....MMMMMMMMMMMMMMM.....MM.",
        "MMM....MMMMMMMMMMMMMMM.....MMM",
        "MMM.....MMMMMMMMMMMMM......MMM",
        ".MM.....MMMMMMMMMMMMM......MM.",
        ".MMM....MMMMMMMMMMMMM.....MMM.",
        "MMMM...MMMMMMMMMMMMMMM....MMMM",
        "MMMM..MMMMMMMMMMMMMMMMM...MMMM",
        ".MM..MMMMMMMMMMMMMMMMMMM...MM.",
        ".....MMMMMMMMMMMMMMMMMMMM.....",
        "....MMMMMMMMMMMMMMMMMMMMMM....",
        "...MMMMMMMMMMMMMMMMMMMMMMMM...",
        "..MMMM.MMMMMMM.MMMMM.MMMMMMM..",
        "...M....MM.M.....MM...M..M....",
    ]
    if p.melee != nil {
        for r in 10...23 { rows[r] = String(rows[r].prefix(24)) + "......" }
    }
    c.pattern(10, 15, rows, ["M": mud])
    // The muck's streaks: short runs dripping down it, lit ones on the hump, dark ones lower.
    for i in 0..<9 {
        let x = 15 + Int(noise(i + 500) * 20), y = 18 + Int(noise(i + 520) * 20)
        c.rect(x, y, 1, 2 + i % 2, y < 27 ? mudL : mudD)
    }
    c.rect(19, 17, 4, 1, mudL); c.rect(17, 19, 2, 1, mudL)   // the hump catching the light
    // Rubbish stuck in it: an eggshell, an orange peel, a blue bottle cap.
    c.rect(18, 21, 3, 2, C(0xF2EEDC)); c.rect(25, 30, 3, 2, C(0xE8902A)); c.rect(21, 38, 2, 2, C(0x3A6AC8))
    // The pinprick red eyes in the head, low on the front.
    c.px(33, 21, C(0xFF3A2A)); c.px(36, 21, C(0xFF3A2A)); c.rect(32, 24, 5, 1, mudD)
    // Drips falling off it.
    for i in 0..<3 {
        let k = (p.t * 0.7 + Double(i) * 0.37).truncatingRemainder(dividingBy: 1)
        c.px([11, 24, 38][i], 38 + Int(k * 5), mud.alpha(1 - k))   // off the fists and the belly
    }
    // The long right arm swipes out from the shoulder.
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() {
            swingArm(c, angle: ta, sleeve: mud, hand: mudD, length: 11, alpha: 0.35 / Double(i + 1))
        }
        let h = swingArm(c, angle: a, sleeve: mud, hand: mudD, length: 11)
        c.rect(Int(h.x) - 1, Int(h.y) - 1, 3, 3, mudD)
    }
}

// MARK: - The Mothmen

/// The Mothmen of "Detour": something in the woods, covered so completely in bark, moss and leaves that you'd walk past
/// it, until its two red eyes open. Clawd under all of it, a ragged leafy fringe all round him. He rakes with twiggy
/// claws. Signature: he fades into the undergrowth until only his eyes are left, glowing, then steps back out.
private func drawMothmen(_ c: PixelCanvas, _ p: Pose) {
    let hide = p.signature.map { ramp($0, 0.08, 0.35) - ramp($0, 0.68, 0.92) } ?? 0
    if hide > 0.02 {
        let fig = PixelCanvas(c.w, c.h)
        mothFigure(fig, p)
        remap(fig, into: c, alpha: 1 - hide * 0.92) { x, y in (x, y) }
        // The eyes stay, glowing brighter.
        c.oy += p.breathe
        for x in [22, 32] { c.rect(x, 28, 2, 2, C(0xFF2A1A)); c.rect(x - 1, 27, 4, 4, C(0xFF2A1A, 0.25 * hide)) }
        return
    }
    mothFigure(c, p)
}

private func mothFigure(_ c: PixelCanvas, _ p: Pose) {
    let moss = C(0x3E5A2A), mossD = C(0x283E1A), bark = C(0x5A4430), leaf = C(0x6A8A32), leafD = C(0x8A6A2A)
    drawLegs(c, Look(leg: bark), step: p.step)
    c.oy += p.breathe
    drawBody(c, Look(body: moss, shade: mossD, arm: bark, eye: nil))
    // Bark and leaves all over, and a ragged fringe of leaves round the edge, head included.
    for i in 0..<14 {
        let x = 18 + Int(noise(i + 600) * 19), y = 26 + Int(noise(i + 640) * 11)
        c.rect(x, y, 1, 2, [bark, leaf, mossD, leafD][i % 4])   // hanging strips, not specks
    }
    // A rounded hood of moss and leaves over his head and shoulders, like a ghillie suit: tufts sticking up from it,
    // its ragged edge hanging down past the eyes at the sides.
    for y in 12...25 {
        let d: Double = Double(25 - y) / 13.5
        let hw: Int = Int((12.5 * (1 - d * d).squareRoot()).rounded())
        guard hw > 0 else { continue }
        for x in (28 - hw)..<(28 + hw) {
            let n: Double = noise(x * 31 + y * 7 + 900)
            c.px(x, y, n < 0.14 ? leafD : n < 0.32 ? moss : leaf)
        }
    }
    for i in 0..<8 {
        let x: Int = 17 + Int(noise(i + 950) * 22)
        let u: Double = (Double(x) + 0.5 - 28) / 12.5
        let edge: Int = 25 - Int((13.5 * (1 - u * u).squareRoot()).rounded())
        c.px(x, edge - 1, i % 3 == 0 ? leafD : leaf)
        if i % 2 == 0 { c.px(x, edge - 2, leaf) }
    }
    c.rect(16, 26, 3, 1, leaf); c.rect(16, 27, 2, 2, leaf); c.px(16, 28, leafD)
    c.rect(37, 26, 3, 1, leaf); c.rect(38, 27, 2, 2, leaf); c.px(39, 28, leafD)
    // Leaf strips hanging down his sides and over his legs, stirring a little.
    let stir = Int(p.t * 1.5) % 2
    for (k, y) in stride(from: 31, through: 41, by: 2).enumerated() {
        c.px(15 - (k + stir) % 2, y, leaf); c.px(15, y + 1, leafD)
        c.px(40 + (k + stir) % 2, y, leaf); c.px(40, y + 1, leafD)
    }
    for x in [21, 27, 33] { c.rect(x, 38, 1, 3, leafD); c.px(x, 41, leaf) }
    // Two red eyes in the leaves.
    for x in [22, 32] { c.rect(x, 28, 2, 2, C(0xD82A1A)) }
    c.rect(15, 33, 3, 3, bark)
    if let a = p.melee {
        for (i, ta) in p.trail.enumerated() {
            let h = swingArm(c, angle: ta, sleeve: bark, hand: bark, alpha: 0.35 / Double(i + 1))
            claws(c, h.x, h.y, angle: ta, leafD, alpha: 0.35 / Double(i + 1))
        }
        let h = swingArm(c, angle: a, sleeve: bark, hand: bark)
        claws(c, h.x, h.y, angle: a, C(0x3A2A1A))
    } else {
        c.rect(38, 33, 3, 3, bark); c.px(41, 33, C(0x3A2A1A)); c.px(41, 35, C(0x3A2A1A))
    }
}

// MARK: - The Rain King

/// The Rain King: a small-town man who makes the weather, whether he means to or not. Clawd in a yellow rain slicker
/// buttoned up and a yellow sou'wester hat, rubber boots. He throws blue lightning from his hand. Signature: a little
/// rain cloud gathers over his head and pours on him, and a frog drops out of it and hops away.
private func drawRainKing(_ c: PixelCanvas, _ p: Pose) {
    let slicker = C(0xF2C81E), slickerD = C(0xC89A10), boot = C(0x2E4A3A), slickerL = C(0xFFE468)
    let sig = p.signature
    let cloud = sig.map { ramp($0, 0.05, 0.2) - ramp($0, 0.85, 0.97) } ?? 0

    drawLegs(c, Look(leg: C(0x4A4A54)), step: p.step)
    if !seatedPose {
        for (i, lx) in [19, 23, 31, 35].enumerated() { c.rect(lx, p.step >= 0 && i % 2 == p.step ? 39 : 40, 2, 3, boot) }
    }
    c.oy += p.breathe
    drawBody(c, Look(arm: slicker))
    // The slicker: long, buttoned, over the legs.
    c.rect(18, 33, 20, 5, slicker); c.rect(37, 33, 1, 5, slickerD)
    c.rect(17, 38, 22, seatedPose ? 1 : 2, slicker); c.rect(17, 39 + (seatedPose ? -1 : 1), 22, 1, slickerD)
    c.rect(28, 33, 1, 6, slickerD); for y in [34, 36] { c.px(27, y, C(0x8A6A10)) }
    c.rect(18, 33, 3, 1, slickerL); c.rect(33, 33, 3, 1, slickerL)   // the shine across the shoulders
    c.rect(21, 34, 1, 3, slickerD); c.rect(34, 34, 1, 3, slickerD)   // creases in the oilskin
    // The sou'wester: a brim all round, longer at the back, down to the body.
    c.pattern(15, 18, [
        ".......SSSLLLSS.........",
        ".....SSLLSSSSSSSs.......",
        "....SLLSSSsSSSSSSs......",
        "....SSSSSSsSSSSSSSs.....",
        "...SSSSSSSsSSSSSSSSs....",
        "ssssssssssssssssssssssss",
        "sss...................ss",
        "ss.....................s",
    ], ["S": slicker, "s": slickerD, "L": slickerL])
    c.rect(18, 24, 20, 2, slicker)
    c.rect(15, 33, 3, 3, slicker); c.rect(15, 35, 3, 1, slickerD)   // the sleeve's cuff

    if cloud > 0, let s = sig {
        // The cloud over his head, raining on him, and the frog dropping out and hopping off.
        let a = cloud
        c.ellipse(28, 9, 10, 3, C(0x6A7484, a)); c.ellipse(23, 8, 5, 3, C(0x7A8494, a)); c.ellipse(33, 7, 6, 3, C(0x8A94A4, a))
        for i in 0..<7 {
            let k = (p.t * 2.5 + Double(i) * 0.31).truncatingRemainder(dividingBy: 1)
            c.px(20 + i * 3, 12 + Int(k * 6), C(0x8AB8FF, 0.8 * a))
        }
        let f = ramp(s, 0.3, 0.8)
        if f > 0 && f < 1 {
            let fx = 30 + Int(f * 14), fy = f < 0.3 ? 12 + Int(f / 0.3 * 28) : 40 - Int(abs(sin((f - 0.3) * 14)) * 4)
            c.pattern(fx, fy, [".G.G.", "GGGGG", "G...G"], ["G": C(0x5AC83A)])
        }
    }
    if p.zap != nil || p.ready {
        let raise = p.armRaise
        c.rect(38, 31 - raise, 3, 3, slicker); c.rect(41, 31 - raise, 3, 2, clawdOrange)
        if p.zap == false { c.px(44, 30 - raise, C(0x8AB8FF)); c.px(43, 29 - raise, C(0x8AB8FF)) }
    } else {
        c.rect(38, 33, 3, 3, slicker)
    }
}

// MARK: - The Teliko

/// The Teliko: a figure out of West African folklore in the show, a man drained of all colour, chalk-white from head to
/// foot, taller and thinner than anyone round him, in a dark suit. He shoots darts from a slim blowpipe. Signature: he
/// lifts the blowpipe to his lips, cheeks puffing, and a cloud of chalk-white dust blows out across the stage.
private func drawTeliko(_ c: PixelCanvas, _ p: Pose) {
    let chalk = C(0xEAE8E2), chalkD = C(0xC4C2BC), suit = C(0x24242A), suitD = C(0x16161A), pipe = C(0x8A6A42)
    let sig = p.signature
    let blowing = sig.map { $0 > 0.15 && $0 < 0.85 } ?? false

    drawLegs(c, Look(leg: suit), step: p.step)
    drawDressShoes(c, step: p.step, color: suitD)
    c.oy += p.breathe
    // Taller than Clawd: the chalk-white head rises six rows higher.
    c.rect(19, 18, 18, 8, chalk); c.rect(36, 18, 1, 8, chalkD); c.rect(20, 17, 16, 1, chalk)
    drawBody(c, Look(body: chalk, shade: chalkD, arm: suit, eye: nil))
    // Black eyes, set deep; a thin mouth.
    c.rect(22, 25, 2, 3, ink); c.rect(32, 25, 2, 3, ink)
    c.rect(21, 24, 4, 1, chalkD); c.rect(31, 24, 4, 1, chalkD)
    c.rect(25, 30, 6, 1, chalkD)
    // The dark suit, buttoned to the top.
    c.rect(18, 32, 20, 6, suit); c.rect(37, 32, 1, 6, suitD); c.rect(27, 32, 2, 3, chalk)
    let suitL = C(0x3A3A44)
    c.rect(18, 32, 4, 1, suitL); c.rect(32, 32, 4, 1, suitL)         // lit shoulders
    c.rect(26, 33, 1, 4, suitD); c.rect(29, 33, 1, 4, suitL)         // the jacket's front edges
    c.px(28, 35, suitL); c.px(28, 37, suitL)                         // its buttons
    c.rect(20, 34, 1, 3, suitD); c.rect(35, 34, 1, 3, suitD)         // folds
    c.rect(15, 33, 3, 3, suit); c.rect(15, 35, 3, 1, chalk)          // the sleeve, a chalk-white wrist

    if blowing, let s = sig {
        // The blowpipe up to his lips, cheeks out, the dust blowing across.
        c.rect(33, 29, 3, 2, chalk)
        c.rect(36, 29, 3, 3, suit); seg(c, 31, 30, 50, 28, pipe)
        // The chalk dust puffs out of the end in a spreading cloud.
        let k = ramp(s, 0.25, 0.85)
        guard k > 0 else { return }
        for i in 0..<18 {
            let d = 2 + k * 20 * (0.35 + noise(i + 700) * 0.65)
            let r = 1 + Int(k * 2 * noise(i + 760))
            c.circle(51 + Int(d), 28 + Int((noise(i + 730) - 0.5) * d * 0.7), r, C(0xF2F0EA, 0.95 * (1 - k * 0.8)))
        }
        return
    }
    if p.fire != nil || p.ready {
        // Aiming: the pipe to his mouth, its end at the muzzle.
        c.rect(36, 30 + p.gunY, 3, 3, suit); seg(c, 31, Double(30 + p.gunY), 50, Double(30 + p.gunY), pipe)
    } else {
        // At rest: the pipe held upright beside him.
        c.rect(38, 33, 3, 3, suit); c.rect(40, 22, 1, 18, pipe)
    }
}
