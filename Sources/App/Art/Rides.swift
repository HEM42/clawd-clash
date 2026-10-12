import Foundation

// The ships that come to pick someone up when their agent is done (`Cast.ride`): the Quinjet for the Avengers,
// the Milano for the Guardians. Drawn nose to the right on a `Ride.width`×`Ride.height` canvas, sitting on its bottom
// row when landed; the boarding ramp comes down to the left of centre, its foot about 14 px left of the middle.

extension Ride {
    static let width = 66, height = 29
}

/// `ramp` 0…1 lowers the boarding ramp, `engines` lights the thrusters, `gear`: landing gear down.
func drawRide(_ c: PixelCanvas, _ ride: Ride, ramp: Double, engines: Bool, gear: Bool) {
    switch ride {
    case .quinjet: drawQuinjet(c, ramp: ramp, engines: engines, gear: gear)
    case .milano: drawMilano(c, ramp: ramp, engines: engines, gear: gear)
    }
}

/// The Avengers' Quinjet: a dark grey wedge with swept wings and twin tail fins.
private func drawQuinjet(_ c: PixelCanvas, ramp: Double, engines: Bool, gear: Bool) {
    let hull = C(0x4A4E58), light = C(0x6A707C), dark = C(0x2E3038)
    if gear { for gx in [20, 44] { c.rect(gx, 24, 1, 3, dark); c.rect(gx - 1, 27, 3, 1, dark) } }
    if ramp > 0 { let len = Int((ramp * 9).rounded()); for k in 0..<len { c.rect(31 - k, 24 + k / 3, 2, 1, dark) } }
    c.rect(10, 16, 48, 8, hull); c.rect(14, 14, 40, 2, light)
    c.pattern(56, 15, ["XX....", "XXXX..", "XXXXXX", "XXXX..", "XX...."], ["X": hull])
    c.rect(46, 14, 8, 2, C(0x8AC8F0))
    c.rect(6, 8, 6, 8, dark); c.rect(12, 10, 4, 6, dark)
    c.rect(22, 20, 24, 2, dark)
    if engines { c.rect(3, 17, 3, 6, C(0x6FB8FF)); c.rect(2, 18, 1, 4, C(0xBFE0FF)) }
}

/// The Guardians' Milano: blue and orange, a long nose and swept-back wings.
private func drawMilano(_ c: PixelCanvas, ramp: Double, engines: Bool, gear: Bool) {
    let hull = C(0x3A5A9A), light = C(0x5A7ABA), trim = C(0xE87A2A), dark = C(0x24324A)
    if gear { for gx in [20, 44] { c.rect(gx, 24, 1, 3, dark); c.rect(gx - 1, 27, 3, 1, dark) } }
    if ramp > 0 { let len = Int((ramp * 9).rounded()); for k in 0..<len { c.rect(31 - k, 24 + k / 3, 2, 1, dark) } }
    c.rect(12, 16, 44, 8, hull); c.rect(14, 14, 36, 2, light)
    c.pattern(56, 16, ["XXXX....", "XXXXXXX.", "XXXXXXXX", "XXXXX..."], ["X": hull])
    c.rect(48, 14, 8, 2, C(0xF0C870))
    c.rect(18, 22, 30, 2, trim); c.rect(8, 10, 10, 6, hull); c.rect(8, 10, 10, 1, trim)
    if engines { c.rect(5, 17, 3, 6, C(0xFF9A4A)); c.rect(4, 18, 1, 4, C(0xFFE0A0)) }
}
