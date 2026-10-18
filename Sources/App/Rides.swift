import Foundation

// The ride kit: what every universe's rides (`Ride`, declared in each universe's folder: the Falcon in
// StarClawdsRides.swift, the TARDIS in DoctorRides.swift…) share. Drawn nose to the right on a `Ride.width`×
// `Ride.height` canvas, sitting on its bottom row when landed; a ship's boarding ramp comes down to the left of
// centre, its foot about 14 px left of the middle (`rideRamp`), its landing gear under it (`rideGear`), its hull a
// filled outline between a top and a bottom profile (`rideHull`).

extension Ride {
    static let width = 66, height = 29
}

/// `ramp` 0…1 lowers the boarding ramp, `engines` lights the thrusters, `gear`: landing gear down. `t`: the clock in
/// seconds, for what beats in time (the Eagle's wings); nil: the system clock (the app), a value: a render's own clock.
func drawRide(_ c: PixelCanvas, _ ride: Ride, ramp: Double, engines: Bool, gear: Bool, t: Double? = nil) {
    ride.draw(c, ramp, engines, gear, t ?? ProcessInfo.processInfo.systemUptime)
}

/// The hull's outline at column `x`, read off a polyline of (x, y) points (straight between them).
func rideProfile(_ x: Int, _ pts: [(Double, Double)]) -> Int {
    let fx = Double(x)
    for i in 1..<pts.count where fx <= pts[i].0 {
        let (a, b) = (pts[i - 1], pts[i])
        return Int((a.1 + (b.1 - a.1) * (fx - a.0) / (b.0 - a.0)).rounded())
    }
    return Int(pts[pts.count - 1].1.rounded())
}

/// A hull filled column by column between the `top` and `bottom` outlines, lit along its spine and shaded
/// along its belly.
func rideHull(_ c: PixelCanvas, x0: Int, x1: Int, top: [(Double, Double)], bottom: [(Double, Double)],
                  body: Px, light: Px, dark: Px) {
    for x in x0...x1 {
        let t = rideProfile(x, top), b = rideProfile(x, bottom)
        guard b >= t else { continue }
        c.rect(x, t, 1, b - t + 1, body)
        c.px(x, t, light)
        c.px(x, b, dark)
        if b - t > 4 { c.px(x, b - 1, dark) }
    }
}

/// The boarding ramp, hinged under the hull at (`hx`, `hy`) and swinging down to its foot on the ground about 14 px
/// left of centre; a warm light spills from the hold behind it.
func rideRamp(_ c: PixelCanvas, ramp: Double, hx: Double, hy: Double, plate: Px, edge: Px) {
    guard ramp > 0 else { return }
    let foot = (x: 19.0, y: 27.5)
    let closed = atan2(0.0, -1.0), open = atan2(foot.y - hy, foot.x - hx)
    let a = closed + (open - closed) * ramp, len = hypot(foot.x - hx, foot.y - hy)
    let tip = (x: hx + cos(a) * len, y: hy + sin(a) * len)
    c.rect(Int(tip.x) + 1, Int(hy) - 3, Int(hx - tip.x) - 1, 3, C(0xFFD890, 0.35 + 0.5 * ramp))   // the lit hold
    c.glowLine(hx, hy, tip.x, tip.y, core: plate, glow: C(0x000000, 0), coreR: 1, glowR: 1.1)
    c.glowLine(hx, hy - 0.6, tip.x, tip.y - 0.6, core: edge, glow: C(0x000000, 0), coreR: 0.35, glowR: 0.4)
}

/// Landing legs with wide feet, standing on the bottom row.
func rideGear(_ c: PixelCanvas, xs: [Int], from y: Int, strut: Px, foot: Px) {
    for x in xs {
        c.rect(x, y, 1, 27 - y, strut)
        c.rect(x - 1, 27, 3, 1, foot); c.rect(x - 2, 28, 5, 1, foot)
    }
}
