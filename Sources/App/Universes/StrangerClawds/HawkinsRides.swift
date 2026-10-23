import Foundation

// Stranger Clawds' ride (`Ride`): the Party's BMX bikes, drawn nose to the right on the rides' `Ride.width`×`Ride.height`
// canvas. Two of the Party race in along the ground (`Ride.drives`), Mike on a red bike at the back and Dustin on a
// blue one in front, a walkie-talkie strapped to each set of handlebars with its aerial up and a headlamp lit; they
// skid to a stop in a puff of dust, a foot down, and whoever's going hops on the back pegs of the rear bike before
// they pedal off again. Who rides is `hawkinsTheme`'s `ride:` closure (HawkinsRoster.swift): the Party.

extension Ride {
    /// The Party's bikes: they drive in, and whoever's leaving boards at the rear bike's back pegs.
    static let hawkinsBikes = Ride(key: "hawkinsBikes", arrival: .drives, canvasHeight: Ride.height + 2,
                                   boardingOffset: 14) { c, ramp, engines, _, t in
        // Two rows taller than a ship's canvas, everything drawn two rows down: Dustin's cap peak would otherwise sit
        // on the top row, where its outline is cut off.
        c.oy += 2
        defer { c.oy -= 2 }
        hawkinsDrawBikes(c, ramp: ramp, moving: engines, t: t)
    }
}

/// Where the bikes' wheels sit: their centres on this row, their tyres down to the canvas's bottom row (28).
private let hub = 23

/// The two bikes and their riders. `moving`: pedalling, the wheels spinning and the headlamps lit; `ramp` 0…1 is the
/// stop, a foot put down once they've stopped (with a skid of dust while they stop and set off).
func hawkinsDrawBikes(_ c: PixelCanvas, ramp: Double, moving: Bool, t: Double) {
    let stopped = ramp > 0.5 && !moving
    // The skid: a puff of dust kicked up behind each back wheel while they pull up (or push off).
    if ramp > 0, ramp < 1 {
        let k = ramp
        for cx in [16, 48] {
            for i in 0..<5 {
                let x = cx - 13 - i * 2 - Int(k * 3), y = 27 - (i % 3) - Int(k * 2)
                c.px(x, y, C(0xC8B89A, 0.55 * (1 - Double(i) / 6)))
            }
        }
    }
    let crank = moving ? t * 9 : 0.6
    hawkinsBike(c, cx: 16, frame: C(0xD8342E), frameD: C(0x9A2220), crank: crank + 1.3, spin: moving ? t * 14 : 0)
    hawkinsBikeRider(c, cx: 16, rider: .mike, crank: crank + 1.3, footDown: stopped)
    hawkinsBike(c, cx: 48, frame: C(0x3A78D8), frameD: C(0x22508E), crank: crank, spin: moving ? t * 14 + 0.5 : 0)
    hawkinsBikeRider(c, cx: 48, rider: .dustin, crank: crank, footDown: stopped)
    hawkinsBikeKit(c, cx: 16, lit: moving)
    hawkinsBikeKit(c, cx: 48, lit: moving)
}

/// A BMX bike, its bottom bracket at (`cx`, the hub row): small fat-tyred wheels with spokes turning by `spin`, a
/// low frame lit along the top tube, high-rise bars, a padded seat and the back pegs.
private func hawkinsBike(_ c: PixelCanvas, cx: Int, frame: Px, frameD: Px, crank: Double, spin: Double) {
    let tyre = C(0x18181C), rim = C(0xB8BCC4), spoke = C(0x8A8E98)
    for wx in [cx - 10, cx + 10] {
        c.circle(wx, hub, 5, tyre)
        c.circle(wx, hub, 4, C(0x2E2E34))
        c.circle(wx, hub, 3, rim)
        c.circle(wx, hub, 2, C(0x3A3A42))
        for k in 0..<3 {   // three spokes, turning
            let a = spin + Double(k) * 2.094
            c.px(wx + Int((cos(a) * 2).rounded()), hub + Int((sin(a) * 2).rounded()), spoke)
        }
        c.px(wx, hub, C(0xE0E2E8))
        c.px(wx - 3, hub - 4, C(0x5A5A62)); c.px(wx - 2, hub - 5, C(0x5A5A62))   // the tread's glint, top left
    }
    let bb = (x: Double(cx), y: Double(hub))
    let seat = (x: Double(cx - 4), y: 18.5), head = (x: Double(cx + 6), y: 18.5)
    func tube(_ a: (x: Double, y: Double), _ b: (x: Double, y: Double), _ col: Px, _ r: Double = 0.85) {
        c.glowLine(a.x, a.y, b.x, b.y, core: col, glow: C(0, 0), coreR: r, glowR: r + 0.1)
    }
    tube((Double(cx - 10), Double(hub)), bb, frameD)                // the chain stay
    tube((Double(cx - 10), Double(hub)), seat, frameD)              // the seat stay
    tube(bb, seat, frame)                                           // the seat tube
    tube(bb, head, frame)                                           // the down tube
    tube((seat.x, seat.y + 0.5), head, frame)                       // the top tube
    tube(head, (Double(cx + 10), Double(hub)), C(0xB8BCC4))         // the fork
    tube(head, (Double(cx + 7), 15.5), C(0x9A9EA8))                 // the stem
    tube((Double(cx + 7), 15.5), (Double(cx + 10), 13.5), C(0x2A2A30), 0.55)   // the high-rise bars
    c.rect(cx - 6, 17, 4, 1, C(0x26262C)); c.px(cx - 6, 17, C(0x4A4A52))   // the padded seat
    c.rect(cx - 11, hub - 1, 3, 1, C(0xC8CCD4))                     // the back peg
    // The cranks, turning, with a pedal at each end.
    let a = crank, px0 = Int((Double(cx) + cos(a) * 2.5).rounded()), py0 = Int((Double(hub) + sin(a) * 2.5).rounded())
    let px1 = 2 * cx - px0, py1 = 2 * hub - py0
    c.px(cx, hub, C(0x5A5E68))
    c.rect(px0 - 1, py0, 2, 1, C(0x3A3A40)); c.rect(px1 - 1, py1, 2, 1, C(0x3A3A40))
}

private enum Rider { case mike, dustin }

/// A rider standing on the pedals, Clawd in costume like everyone else: the body over the bike, both arms forward to
/// the bars, and four legs down to the pedals, the pairs taking turns with the cranks (one pair put down on the ground
/// once they've stopped).
private func hawkinsBikeRider(_ c: PixelCanvas, cx: Int, rider: Rider, crank: Double, footDown: Bool) {
    let legCol: Px, legD: Px, shoe: Px
    switch rider {
    case .mike: legCol = C(0x3E5680); legD = C(0x2C3E60); shoe = C(0xE4E4DE)
    case .dustin: legCol = C(0x7E6040); legD = C(0x5E4630); shoe = C(0x3A6AB0)
    }
    // The body's left edge (art column 18 of a standing sprite) at `bx`, its top (row 26) at row 6.
    let bx = cx - 11, top = 6
    // Four legs from under the body to the pedals: the front pair and the back pair push in turn.
    let push = sin(crank)
    for (i, col) in [1, 5, 13, 17].enumerated() {
        let x = bx + col
        let pair = i % 2 == 0 ? push : -push
        var bottom = 22 + Int((pair * 1.2).rounded())
        if footDown && i == 3 { bottom = 28 }                       // a foot down on the ground, steadying the bike
        c.rect(x, top + 12, 2, bottom - top - 12, legCol)
        c.px(x + 1, top + 13, legD)
        c.rect(x, bottom - 1, 2, 1, shoe)
    }
    // The body, leaning on the bars: Clawd's block, its arm out to the grips.
    let ox = c.ox, oy = c.oy
    c.ox = bx - 18; c.oy = top - 26
    defer { c.ox = ox; c.oy = oy }
    switch rider {
    case .mike:
        // Mike: the cream shirt with its red and navy stripes, and his dark mop of hair down to his brows.
        let shirt = C(0xE6DCC6), shirtD = C(0xC4B89E), red = C(0xB03C34), navy = C(0x2C3C66)
        let hair = C(0x241A16), hairD = C(0x120C0A), hairL = C(0x4A3A30)
        drawBody(c, Look(arm: shirt), armRight: 1)
        c.rect(18, 33, 20, 5, shirt); c.rect(18, 34, 20, 1, red); c.rect(18, 36, 20, 1, navy)
        c.rect(37, 33, 1, 5, shirtD); c.rect(38, 33, 3, 1, red)
        c.pattern(17, 21, [
            "....HHHHHHHHHHHHH.....",
            "..HHHlHHlHHHlHHHHH....",
            ".HHlHHHHHHHHHHHhHHH...",
            "HHHHHHHHHHHHHHHHhHHd..",
            "HHHH.HHHH.HHHH.HHHHd..",
            "HHd...........hd.HHd..",
            "Hd.................d..",
        ], ["H": hair, "d": hairD, "l": hairL, "h": hairD])
    case .dustin:
        // Dustin: the white raglan tee with navy sleeves, the curls out under his trucker cap, its peak forward.
        let tee = C(0xEEEAE0), teeD = C(0xCCC6B8), navy = C(0x2A3A6A)
        let hair = C(0x6A4428), hairD = C(0x4A2E18), cap = C(0x2A3E78), capD = C(0x1C2A56), front = C(0xF0ECE2)
        drawBody(c, Look(arm: navy), armRight: 1)
        c.rect(18, 33, 20, 5, tee); c.rect(18, 33, 4, 1, navy); c.rect(34, 33, 4, 1, navy)
        c.rect(37, 35, 1, 3, teeD); c.rect(18, 37, 20, 1, teeD)
        c.pattern(15, 25, ["HhHHhHHh............hHH.", ".HhH..................h."], ["H": hair, "h": hairD])
        c.pattern(17, 20, [
            ".....NNNNNNNNN........",
            "...NNNFFFFFFFNNN......",
            "..NNFFFrrbbFFFFNN.....",
            ".NNNFFFFFFFFFFFNNN....",
            ".BBBBBBBBBBBBBBBBBBppp",
        ], ["N": cap, "F": front, "r": C(0xD03A2A), "b": C(0x3A6AB0), "B": capD, "p": C(0x4058A0)])
    }
    // The hand round the grip.
    c.rect(39, 31, 2, 2, clawdOrange)
}

/// What's strapped to the front of the bars: a walkie-talkie with its aerial up, and the headlamp, `lit` while they ride,
/// throwing a short pool of light ahead.
private func hawkinsBikeKit(_ c: PixelCanvas, cx: Int, lit: Bool) {
    let x = cx + 12
    // The walkie-talkie: a dark box on the bars, its grille and a red light, the aerial straight up.
    c.rect(x, 12, 2, 4, C(0x2A2A30)); c.px(x, 13, C(0x5A5E68)); c.px(x + 1, 12, C(0xD03A2A))
    c.rect(x + 1, 3, 1, 9, C(0x3A3A40)); c.px(x + 1, 3, C(0x9A9EA8))
    // The headlamp, on the fork's crown.
    c.rect(cx + 9, 17, 2, 2, C(0x9A9EA8)); c.px(cx + 10, 17, lit ? C(0xFFF4C8) : C(0xC8C8B8))
    guard lit else { return }
    for i in 0..<4 {
        let bx = cx + 11 + i
        guard bx < c.w - 1 else { break }
        c.rect(bx, 17 - i / 2, 1, 2 + i, C(0xFFF4C8, 0.22 - Double(i) * 0.035))
    }
}
