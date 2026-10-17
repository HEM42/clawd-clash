import Foundation

// Clawd Slayer's rides (`Ride`), drawn nose to the right on the ships' `Ride.width`×`Ride.height` canvas. All three
// drive in along the ground (`Ride.drives`, in Theme.swift): the dented yellow school bus from the "Chosen" escape for
// the Scooby Gang, the Slayers and the Potentials; Spike's black DeSoto, its windows blacked out with paint and paper,
// for Spyke and the vampires; and Angel's black 1967 Plymouth GTX, top down, for Angel Investigations. Who rides what
// is `slayerTheme`'s `ride:` closure (SlayerRoster.swift).

/// The tyres in their arches, a hub cap in the middle. `whitewall`: the 1950s white ring round the hub.
private func slayerWheels(_ c: PixelCanvas, _ xs: [Int], r: Int = 4, arch: Px, hub: Px, whitewall: Bool = false) {
    for wx in xs {
        c.circle(wx, 28 - r, r + 1, arch)
        c.circle(wx, 28 - r, r, C(0x101114))
        if whitewall { c.circle(wx, 28 - r, r - 1, C(0xE8E6DC)); c.circle(wx, 28 - r, r - 2, C(0x101114)) }
        c.circle(wx, 28 - r, max(1, r - 3), hub)
        c.px(wx - 1, 27 - r, C(0xF4F6F8))                       // the glint, top left
    }
}

/// The school bus (the "Chosen" escape): a yellow body with black rub rails, a row of windows (one cracked), the
/// stubby bonnet out front and dents and scrapes down its side. Its folding door, just behind the front wheel, is
/// where whoever's taken climbs aboard (`Ride.boardingOffset` puts them there, right of centre): `ramp` 0…1 folds it
/// open on the lit steps. `lit`: headlights on and the roof lamps on, amber up front and red at the back.
func slayerSchoolBus(_ c: PixelCanvas, ramp: Double, lit: Bool) {
    let yellow = C(0xF0B21E), light = C(0xFFD65A), dark = C(0xB87810), black = C(0x1C1C20), glass = C(0x26303C)
    let shine = C(0x9AB4C8), chrome = C(0xC8CCD2), arch = C(0x141418)
    // The box: rounded at the roof's corners, lit along the roof and down its back end.
    c.rect(3, 5, 47, 19, yellow)
    c.rect(4, 4, 45, 1, yellow); c.rect(5, 3, 41, 1, light); c.rect(4, 4, 45, 1, light)
    c.rect(3, 5, 1, 18, light)
    c.rect(3, 23, 47, 1, dark); c.rect(3, 22, 47, 1, dark)
    // The bonnet, a step down in front, with its black grille and bumper.
    for x in 50...61 { let top = 13 + (x - 50) / 6; c.rect(x, top, 1, 24 - top, yellow); c.px(x, top, light) }
    c.rect(50, 22, 12, 2, dark)
    c.rect(61, 15, 2, 7, black); for y in stride(from: 16, through: 20, by: 2) { c.px(62, y, chrome) }
    c.rect(59, 22, 5, 2, black); c.rect(59, 22, 5, 1, C(0x3A3A40))
    c.rect(1, 21, 3, 2, black)                                    // the back bumper
    // The windscreen's edge on the front of the box, and the lamps on the roof.
    c.rect(48, 6, 2, 7, glass); c.px(48, 7, shine)
    let lamp = lit ? 1.0 : 0.55
    c.rect(46, 3, 2, 1, C(0xFFC23A, lamp)); c.rect(5, 3, 2, 1, C(0xE83A2A, lamp))
    // The windows: a row of panes with yellow posts between them, the third one cracked.
    for (i, x) in stride(from: 6, through: 36, by: 5).enumerated() {
        c.rect(x, 7, 4, 6, glass); c.px(x, 7, shine); c.px(x + 1, 7, shine.alpha(0.6))
        if i == 2 {   // the crack, a white star off a hit
            c.px(x + 2, 9, C(0xE8EEF2)); c.px(x + 1, 8, C(0xB8C4CC)); c.px(x + 3, 10, C(0xB8C4CC)); c.px(x + 1, 11, C(0xB8C4CC))
        }
    }
    // The black rub rails, and the bus's name in a black band under the windows.
    c.rect(3, 15, 47, 1, black); c.rect(3, 19, 47, 1, black)
    c.rect(8, 14, 1, 1, black)
    for x in stride(from: 9, through: 29, by: 2) { c.px(x, 14, black) }
    // Dents and scrapes from the escape: a caved-in panel (shadow on top, light underneath), a crumpled back corner,
    // and grey scrapes along the side.
    c.rect(20, 16, 6, 1, dark); c.rect(21, 17, 4, 1, dark); c.rect(21, 18, 4, 1, light)
    c.px(4, 5, dark); c.px(3, 6, dark); c.rect(4, 6, 2, 1, dark)
    c.px(32, 17, dark); c.px(33, 18, light)
    for (x, y) in [(10, 20), (11, 20), (12, 21), (28, 21), (29, 21), (30, 20), (31, 20)] { c.px(x, y, C(0x8A8278)) }
    // The tail light and the headlight.
    c.rect(3, 17, 1, 2, C(0xC82A2A))
    c.rect(61, 13, 1, 2, lit ? C(0xFFF6C8) : C(0xC8C8B8))
    if lit { c.rect(62, 13, 2, 2, C(0xFFF6C8, 0.5)) }
    // The folding door: two glass leaves with black frames, between the windows and the windscreen.
    let open = Int((5 * ramp).rounded())
    if ramp > 0 {
        c.rect(42, 6, 5, 17, C(0xFFE8B0, 0.85))
        for (i, y) in [21, 18].enumerated() { c.rect(42 + i, y, 5 - i, 1, C(0x7A6A50)) }   // the steps
    }
    let leaf = max(1, 5 - open)
    c.rect(42, 6, leaf, 17, black)
    if leaf > 2 { c.rect(43, 7, leaf - 2, 7, glass); c.rect(43, 15, leaf - 2, 6, glass); c.px(43, 7, shine) }
    else { c.rect(42 + leaf - 1, 6, 1, 17, C(0x3A3A40)) }
    // The wheels.
    slayerWheels(c, [13, 53], r: 4, arch: arch, hub: C(0x9AA0A8))
}

/// Spike's DeSoto: a rounded black 1950s four-door with fat chrome bumpers, the toothy grille, whitewall tyres and
/// windows blacked out with paint and taped-up paper so a vampire can drive by day. Its rear door is the ramp
/// (`ramp` 0…1 swings it open on a dim, smoky red inside); `lit`: headlights on.
func slayerDeSoto(_ c: PixelCanvas, ramp: Double, lit: Bool) {
    let body = C(0x24242C), light = C(0x50505E), dark = C(0x101014), chrome = C(0xC8CCD2), chromeDark = C(0x7A8088)
    let paint = C(0x0A0A0C), paper = C(0xD8CCA8), paperDark = C(0xA89A78), tape = C(0x8A7A5A), arch = C(0x08080A)
    // The body: a long tub, the round back fender, the bonnet sloping down to the grille.
    c.rect(4, 16, 58, 8, body)
    for x in 2...13 { let top = 15 + abs(x - 8) / 3; c.rect(x, top, 1, 23 - top, body); c.px(x, top, light) }   // rear fender
    for x in 44...62 { let top = 15 + max(0, x - 54) / 3; c.rect(x, top, 1, 24 - top, body); c.px(x, top, light) }
    c.rect(14, 16, 30, 1, light)
    c.rect(4, 23, 58, 1, dark); c.rect(4, 22, 58, 1, dark)
    c.rect(2, 16, 1, 6, light)                                    // the back end, catching the light
    // The cabin: a tall rounded roof, its back sloping into the boot in a long curve, the windscreen steeper.
    for x in 14...46 {
        let top: Int
        if x < 24 { let f = Double(24 - x) / 10; top = 8 + Int((f * f * 7).rounded()) }
        else if x > 38 { let f = Double(x - 38) / 8; top = 8 + Int((f * f * 7).rounded()) }
        else { top = 8 }
        c.rect(x, top, 1, 16 - top, body); c.px(x, top, light)
    }
    // The windows, painted out black with streaky brush strokes, newspaper taped over the gaps.
    for x in 17...44 {
        let top: Int
        if x < 25 { let f = Double(25 - x) / 9; top = 10 + Int((f * f * 5).rounded()) }
        else if x > 37 { let f = Double(x - 37) / 8; top = 10 + Int((f * f * 5).rounded()) }
        else { top = 10 }
        guard x != 31 && x != 32, top < 15 else { continue }
        c.rect(x, top, 1, 15 - top, paint)
        if (x + top) % 4 == 0 { c.px(x, top + 1, C(0x26262E)) }      // a brush streak
    }
    c.rect(23, 11, 4, 3, paper); c.rect(23, 13, 4, 1, paperDark); c.px(23, 11, tape); c.px(26, 11, tape)
    for x in stride(from: 24, through: 25, by: 1) { c.px(x, 12, paperDark) }      // the newsprint
    c.rect(36, 12, 3, 3, paper); c.rect(36, 14, 3, 1, paperDark); c.px(38, 12, tape)
    c.px(41, 11, C(0x3A4250)); c.px(34, 14, C(0x3A4250))           // pinholes of sky where the paint missed
    c.rect(31, 9, 2, 7, body)                                       // the pillar between the doors
    // Chrome: the spear along the side, the door handles, the fat bumpers and the toothy grille.
    c.rect(14, 19, 44, 1, chrome); c.rect(14, 20, 44, 1, chromeDark.alpha(0.6))
    c.rect(32, 17, 1, 7, dark); c.rect(19, 17, 1, 7, dark)          // the doors' seams
    c.rect(28, 18, 2, 1, chrome); c.rect(41, 18, 2, 1, chrome)
    c.rect(0, 20, 4, 3, chrome); c.rect(0, 22, 4, 1, chromeDark)
    c.rect(61, 20, 5, 3, chrome); c.rect(61, 22, 5, 1, chromeDark)
    c.rect(61, 17, 3, 3, dark); for y in 17...19 { c.px(62, y, chrome) }; c.px(63, 18, chrome)
    // The lights: the round headlight in the front fender, the tail fin's red lamp.
    c.rect(60, 16, 2, 2, lit ? C(0xFFF6C8) : C(0xC8C8B8))
    if lit { c.rect(62, 15, 2, 3, C(0xFFF6C8, 0.55)) }
    c.rect(2, 17, 1, 2, C(0xC82A2A))
    // The wheels: whitewalls, half under the fenders' skirts.
    slayerWheels(c, [13, 51], r: 4, arch: arch, hub: chrome, whitewall: true)
    c.rect(14, 19, 44, 1, chrome)                                    // the spear, over the arches' tops
    // The rear door swinging open on the dim red inside, a curl of cigarette smoke.
    if ramp > 0 {
        let w = 12, open = Int((Double(w) * ramp).rounded())
        c.rect(20, 10, w, 14, C(0x6A1E1E, 0.9)); c.rect(20, 10, w, 1, C(0x8A3A2A))
        c.px(24, 9, C(0xB8B8C0, 0.5 * ramp)); c.px(25, 8, C(0xB8B8C0, 0.35 * ramp)); c.px(24, 7, C(0xB8B8C0, 0.25 * ramp))
        let lw = max(1, w - open)
        c.rect(20, 9, lw, 15, body); c.rect(20, 9, lw, 1, light)
        if lw > 3 { c.rect(21, 11, lw - 2, 4, paint) }
    }
}

/// Angel's convertible: a long, low black 1967 Plymouth GTX with the top down, twin bonnet scoops, chrome bumpers and
/// mag wheels; the seats and the folded top show over its sides. The driver's door swings open for boarding (`ramp`
/// 0…1); `lit`: headlights on.
func slayerGTX(_ c: PixelCanvas, ramp: Double, lit: Bool) {
    let body = C(0x22242A), light = C(0x545866), dark = C(0x0E0F12), chrome = C(0xD0D4DA), chromeDark = C(0x7A8088)
    let seat = C(0x3A3434), seatLight = C(0x6E6462), top = C(0x3A3C42), glass = C(0x5A7A92), arch = C(0x08080A)
    // The folded top, stacked low behind the back seat, and the seats' backs showing over the sides.
    c.rect(8, 14, 9, 2, top); c.rect(9, 13, 7, 1, top); c.rect(9, 13, 6, 1, C(0x5E626C)); c.px(8, 14, C(0x5E626C))
    let seats: [Character: Px] = ["L": seatLight, "S": seat, "D": C(0x1A1616)]
    c.pattern(17, 12, ["LLL..", "SSSS.", "SSSSS", "SSSSD"], seats)                              // the back bench
    c.pattern(27, 9, [".LL..", ".SS..", "LSSS.", "SSSS.", "SSSSS", "SSSSD", "SSSSD"], seats)   // the front bucket
    c.rect(33, 12, 1, 4, C(0x1A1A1E)); c.px(34, 12, C(0x1A1A1E)); c.px(32, 13, C(0x1A1A1E))   // the steering wheel
    // The windscreen, raked back, in a chrome frame.
    for y in 9..<16 {
        let x = 35 + (y - 9) / 2
        c.px(x, y, chrome); c.px(x + 1, y, glass); c.px(x + 2, y, glass.alpha(0.6))
    }
    c.px(37, 11, C(0xD8E8F4))
    // The body: long and low, the boot and bonnet level with the sill, a crease along the side.
    c.rect(4, 16, 58, 8, body)
    c.rect(4, 15, 13, 1, body)                                     // the rear deck, kicked up over the back wheel
    c.rect(4, 15, 13, 1, light); c.rect(17, 16, 45, 1, light); c.rect(3, 16, 1, 6, light)
    c.rect(4, 17, 58, 1, C(0x30333C))                              // the sheen under the waistline
    c.rect(4, 23, 58, 1, dark); c.rect(4, 22, 58, 1, dark)
    c.rect(5, 19, 56, 1, dark.alpha(0.7))                          // the crease down the flank
    // The twin bonnet scoops, and the GTX's chrome badge on the front fender.
    c.rect(44, 15, 3, 1, body); c.px(44, 15, light); c.rect(49, 15, 3, 1, body); c.px(49, 15, light)
    c.rect(52, 18, 3, 1, chrome)
    // The bumpers, the grille, the lights.
    c.rect(1, 20, 3, 2, chrome); c.rect(1, 21, 3, 1, chromeDark)
    c.rect(62, 17, 2, 5, dark); c.px(63, 18, chrome); c.px(63, 20, chrome)
    c.rect(62, 21, 3, 2, chrome); c.rect(62, 22, 3, 1, chromeDark)
    c.rect(61, 17, 1, 2, lit ? C(0xFFF6C8) : C(0xC8C8B8))
    if lit { c.rect(62, 17, 2, 2, C(0xFFF6C8, 0.55)) }
    c.rect(3, 17, 1, 2, C(0xC82A2A))
    // The door's seam and handle.
    c.rect(22, 17, 1, 6, dark); c.rect(36, 16, 1, 7, dark); c.rect(33, 18, 2, 1, chrome)
    // The wheels: chrome mags.
    slayerWheels(c, [13, 52], r: 4, arch: arch, hub: chrome)
    for wx in [13, 52] { c.px(wx, 24, chromeDark); c.px(wx - 1, 23, C(0xF4F6F8)) }
    // The door swinging open: the red-lit footwell behind it.
    if ramp > 0 {
        let w = 14, open = Int((Double(w) * ramp).rounded())
        c.rect(23, 16, w - 1, 7, C(0xFFE8B0, 0.75)); c.rect(23, 21, w - 1, 2, seat)
        let lw = max(1, w - open)
        c.rect(23, 15, lw, 8, body); c.rect(23, 15, lw, 1, light)
    }
}
