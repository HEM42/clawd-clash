import Foundation

// Doctor Clawd's ride: the TARDIS. Drawn with the ride kit in Rides.swift.

extension Ride {
    /// The TARDIS: it fades in and out where it stands, taller than a ship, its door 6 px left of centre.
    static let tardis = Ride(key: "tardis", arrival: .materialises, canvasHeight: 36, boardingOffset: 6) { c, ramp, engines, _, _ in
        drawTardis(c, door: ramp, lamp: engines)
    }

    /// A compacted Doctor regenerates: golden fire over the next face.
    var regeneration: (length: Double, draw: (_ c: PixelCanvas, _ k: Double, _ t: Double) -> Void)? {
        (regenerationFlare, { c, k, t in drawRegeneration(c, k: k, t: t) })
    }
}

/// The TARDIS: a blue police box standing on the bottom row, left of centre so whoever boards walks up to its doors
/// (it never flies in: the overlay fades it in and out where it stands, `Ride.materialises`). Taller than the ships'
/// canvas (`Ride.canvasHeight`), so it stands a head above whoever steps into it. The lamp on the roof, the POLICE BOX
/// sign, the frosted windows and the panelled doors; `door` 0…1 swings the right-hand door open on the lit interior,
/// `lamp` lights the roof lamp.
private func drawTardis(_ c: PixelCanvas, door: Double, lamp: Bool) {
    let blue = C(0x1C3F94), dark = C(0x15306E), edge = C(0x2E58B8), sign = C(0x101820), glass = C(0xE8F0FF)
    let x0 = 11, w = 22, top = 4, base = c.h - 2
    // The roof stack and the lamp.
    c.rect(x0 + 7, top - 1, 8, 1, blue)
    c.rect(x0 + 10, top - 3, 2, 2, lamp ? C(0xFFF6C8) : C(0xC8D0E0))
    if lamp {
        c.rect(x0 + 9, top - 4, 4, 1, C(0xFFF6C8, 0.45))
        c.px(x0 + 9, top - 2, C(0xFFF6C8, 0.4)); c.px(x0 + 12, top - 2, C(0xFFF6C8, 0.4))
    }
    c.rect(x0 - 1, top, w + 2, 2, blue); c.rect(x0 - 1, top, w + 2, 1, edge)
    // The body, its corner posts and the sign.
    c.rect(x0, top + 2, w, base - top - 2, blue)
    c.rect(x0, top + 2, 2, base - top - 2, edge); c.rect(x0 + w - 2, top + 2, 2, base - top - 2, dark)
    c.rect(x0 + 1, top + 3, w - 2, 3, sign)
    for x in stride(from: x0 + 3, to: x0 + w - 3, by: 2) { c.px(x, top + 4, glass.alpha(0.85)) }
    // The doors: windows over three panels each, split down the middle.
    let doorY = top + 7, doorH = base - doorY - 1, half = (w - 4) / 2
    for side in 0..<2 {
        let dx = x0 + 2 + side * half
        c.rect(dx + 1, doorY + 1, half - 2, 4, glass)
        c.rect(dx + half / 2, doorY + 1, 1, 4, blue); c.rect(dx + 1, doorY + 3, half - 2, 1, blue)
        let panel = (doorH - 7) / 3
        for k in 0..<3 { c.rect(dx + 1, doorY + 6 + k * (panel + 1), half - 2, panel, dark) }
    }
    c.rect(x0 + 1 + half, doorY, 2, doorH, dark)
    if door > 0 {
        // The right-hand door swings in on the warm light inside.
        let open = Int((Double(half) * door).rounded())
        c.rect(x0 + 2 + half, doorY, half, doorH, C(0xFFE8A8, 0.9))
        c.rect(x0 + 2 + half, doorY, half, 2, C(0xFFF6D8))
        c.rect(x0 + 2 + 2 * half - max(1, half - open), doorY, max(1, half - open), doorH, blue)
    }
    // The base.
    c.rect(x0 - 1, base, w + 2, 2, blue); c.rect(x0 - 1, base + 1, w + 2, 1, dark)
}
