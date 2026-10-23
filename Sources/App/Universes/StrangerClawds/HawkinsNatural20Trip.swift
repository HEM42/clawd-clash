import CoreGraphics
import Foundation

// Natural 20 (`HawkinsWipe.natural20`): the Party's dice, and Hellfire's. A giant red d20 tumbles in across the old
// place, bouncing, slows and stops with 20 facing up at you, flashes, and the new place is there in the flash.

extension HawkinsTrip {
    /// A frame `k` (0…1) of Natural 20, over the whole of `r`. The die tumbles in from the left, bouncing lower each
    /// time, its shadow on the floor under it (0–0.56); it rocks to a stop on 20 and the number glows gold (0.56–0.7);
    /// it flashes white, rays bursting out of it, and the new place comes up out of the flash (0.7–1). The die is a
    /// real icosahedron turned in 3D and drawn face by face in pixel art: flat faces in stepped shades of red, lit from
    /// the top left, with dark edges.
    func drawNatural20(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let art = HawkinsArt(r)
        let c = art.c, w = art.w, h = art.h
        let roll = Self.span(k, 0, 0.6)
        let glow = Self.span(k, 0.58, 0.7)
        let flash = Self.span(k, 0.7, 0.8), clear = Self.span(k, 0.8, 1)

        // Where it is: in from the left, slowing, bouncing lower each time, settling in the middle.
        let D = Double(h) * (art.wide ? 0.36 : 0.3)                   // its radius on screen
        let ground = Double(h) * (art.wide ? 0.56 : 0.58)
        let along = 1 - pow(1 - roll, 2.4)
        let x = -D + (Double(w) / 2 + D) * along
        let bounce = abs(sin(roll * .pi * 3.2)) * (1 - roll) * Double(h) * 0.32
        let y = ground - bounce
        // How it's turned: spinning about a slanted axis, slower and slower, ending with 20 straight at you.
        let spin = pow(1 - min(1, roll / 0.96), 2) * 14
        let pose = hawkinsD20Turn(axis: (0.55, 0.75, 0.35), angle: spin)

        ctx.drawShot(clear > 0 ? new : old, in: r)
        if clear <= 0 { Self.wash(ctx, 0x000000, 0.35 * Self.span(k, 0, 0.2), in: r) }
        // The flash, whiting everything out, then fading off the new place.
        Self.wash(ctx, 0xFFF8E8, clear > 0 ? 1 - Self.ease(clear) : flash, in: r)
        if clear > 0 { return }

        // Its shadow on the floor, smaller and fainter the higher it bounces.
        let lift = bounce / (Double(h) * 0.32)
        c.ellipse(Int(x), Int(ground + D * 0.92), Int(D * (0.9 - lift * 0.3)), max(1, Int(D * 0.16)), C(0x000000, 0.45 * (1 - lift * 0.6) * (1 - flash)))

        // The die, face by face, back to front.
        let faces = hawkinsD20Faces.enumerated().map { i, f -> (pts: [(Double, Double)], z: Double, n: (Double, Double, Double), front: Bool) in
            let p = f.map { pose($0) }
            let n = hawkinsD20Normal(p)
            return (p.map { (x + $0.0 * D / 1.902, y - $0.1 * D / 1.902) }, (p[0].2 + p[1].2 + p[2].2) / 3, n, i == 0)
        }.filter { $0.n.2 > 0 }.sorted { $0.z < $1.z }
        let shades: [UInt32] = [0x3E0A10, 0x6A141C, 0x961E26, 0xC23238, 0xE8585A]
        let L = (-0.45, 0.6, 0.66)
        for f in faces {
            let lit = max(0, f.n.0 * L.0 + f.n.1 * L.1 + f.n.2 * L.2)
            let band = min(shades.count - 1, Int(lit * Double(shades.count - 1) + 0.35))
            hawkinsFillTriangle(c, f.pts, C(shades[band]))
        }
        for f in faces {
            for i in 0..<3 {
                let a = f.pts[i], b = f.pts[(i + 1) % 3]
                hawkinsLine(c, a.0, a.1, b.0, b.1, C(0x2A060A), 0.55)
            }
        }
        // The numbers: once it's slowed enough to read, 20 on the face towards you, gold as it glows.
        if roll > 0.9, let top = faces.last(where: { $0.front }) {
            let cx = (top.pts[0].0 + top.pts[1].0 + top.pts[2].0) / 3, cy = (top.pts[0].1 + top.pts[1].1 + top.pts[2].1) / 3
            let p = max(1, Int(D / 15))
            let ink = glow > 0 ? Self.mix(0xF4F0E8, 0xFFD24A, glow) : C(0xF4F0E8)
            if glow > 0 { hawkinsFillTriangle(c, top.pts, C(0xFF9A3A, 0.35 * glow)) }
            hawkinsTripCentred(c, Int(cx.rounded()), Int(cy) - 5 * p / 2 + p / 2, "20", ink, p, shadow: C(0x2A060A))
        }
        // The flash: rays bursting out from the die.
        if flash > 0 {
            for i in 0..<14 {
                let a = Double(i) / 14 * 2 * .pi + 0.2
                let len = D * (1.2 + flash * 4) * (i % 2 == 0 ? 1 : 0.6)
                hawkinsLine(c, x + cos(a) * D * 1.15, y + sin(a) * D * 1.15, x + cos(a) * len, y + sin(a) * len, C(0xFFF2C0, 0.9), 1.2)
            }
        }
        art.show(ctx)
    }
}

// MARK: The icosahedron

private let hawkinsPhi = (1 + 5.0.squareRoot()) / 2

/// The twelve corners of a d20 (an icosahedron with edges 2 long).
private let hawkinsD20Corners: [(Double, Double, Double)] = {
    var v: [(Double, Double, Double)] = []
    for a in [-1.0, 1.0] {
        for b in [-hawkinsPhi, hawkinsPhi] { v += [(0, a, b), (a, b, 0), (b, 0, a)] }
    }
    return v
}()

/// Its twenty faces, as corner triples, wound so each normal points outward.
private let hawkinsD20FaceCorners: [[(Double, Double, Double)]] = {
    let v = hawkinsD20Corners
    func d(_ a: (Double, Double, Double), _ b: (Double, Double, Double)) -> Double {
        ((a.0 - b.0) * (a.0 - b.0) + (a.1 - b.1) * (a.1 - b.1) + (a.2 - b.2) * (a.2 - b.2)).squareRoot()
    }
    var out: [[(Double, Double, Double)]] = []
    for i in 0..<12 { for j in (i + 1)..<12 { for k in (j + 1)..<12 where abs(d(v[i], v[j]) - 2) < 0.01 && abs(d(v[j], v[k]) - 2) < 0.01 && abs(d(v[i], v[k]) - 2) < 0.01 {
        var f = [v[i], v[j], v[k]]
        let n = hawkinsD20Normal(f), m = ((f[0].0 + f[1].0 + f[2].0), (f[0].1 + f[1].1 + f[2].1), (f[0].2 + f[1].2 + f[2].2))
        if n.0 * m.0 + n.1 * m.1 + n.2 * m.2 < 0 { f.swapAt(1, 2) }
        out.append(f)
    } } }
    return out
}()

/// The faces turned so the first one (the 20) faces the viewer squarely with a corner pointing up: the die at rest.
private let hawkinsD20Faces: [[(Double, Double, Double)]] = {
    let f0 = hawkinsD20FaceCorners[0]
    let m = ((f0[0].0 + f0[1].0 + f0[2].0) / 3, (f0[0].1 + f0[1].1 + f0[2].1) / 3, (f0[0].2 + f0[1].2 + f0[2].2) / 3)
    func norm(_ a: (Double, Double, Double)) -> (Double, Double, Double) {
        let l = (a.0 * a.0 + a.1 * a.1 + a.2 * a.2).squareRoot(); return (a.0 / l, a.1 / l, a.2 / l)
    }
    let z = norm(m), up = norm((f0[0].0 - m.0, f0[0].1 - m.1, f0[0].2 - m.2))
    let x = (up.1 * z.2 - up.2 * z.1, up.2 * z.0 - up.0 * z.2, up.0 * z.1 - up.1 * z.0)
    func turn(_ p: (Double, Double, Double)) -> (Double, Double, Double) {
        (x.0 * p.0 + x.1 * p.1 + x.2 * p.2, up.0 * p.0 + up.1 * p.1 + up.2 * p.2, z.0 * p.0 + z.1 * p.1 + z.2 * p.2)
    }
    return hawkinsD20FaceCorners.map { $0.map(turn) }
}()

/// The unit normal of a triangle, by its winding.
private func hawkinsD20Normal(_ f: [(Double, Double, Double)]) -> (Double, Double, Double) {
    let a = (f[1].0 - f[0].0, f[1].1 - f[0].1, f[1].2 - f[0].2), b = (f[2].0 - f[0].0, f[2].1 - f[0].1, f[2].2 - f[0].2)
    let n = (a.1 * b.2 - a.2 * b.1, a.2 * b.0 - a.0 * b.2, a.0 * b.1 - a.1 * b.0)
    let l = max(1e-9, (n.0 * n.0 + n.1 * n.1 + n.2 * n.2).squareRoot())
    return (n.0 / l, n.1 / l, n.2 / l)
}

/// A turn by `angle` radians about `axis` (Rodrigues' formula), as a function on points.
private func hawkinsD20Turn(axis: (Double, Double, Double), angle: Double) -> ((Double, Double, Double)) -> (Double, Double, Double) {
    let l = (axis.0 * axis.0 + axis.1 * axis.1 + axis.2 * axis.2).squareRoot()
    let u = (axis.0 / l, axis.1 / l, axis.2 / l), cs = cos(angle), sn = sin(angle)
    return { p in
        let d = u.0 * p.0 + u.1 * p.1 + u.2 * p.2
        let cr = (u.1 * p.2 - u.2 * p.1, u.2 * p.0 - u.0 * p.2, u.0 * p.1 - u.1 * p.0)
        return (p.0 * cs + cr.0 * sn + u.0 * d * (1 - cs), p.1 * cs + cr.1 * sn + u.1 * d * (1 - cs), p.2 * cs + cr.2 * sn + u.2 * d * (1 - cs))
    }
}

/// A solid triangle on the pixel grid: every pixel whose centre falls inside it.
func hawkinsFillTriangle(_ c: PixelCanvas, _ p: [(Double, Double)], _ col: Px) {
    let minY = Int(floor(p.map(\.1).min()!)), maxY = Int(ceil(p.map(\.1).max()!))
    for y in max(0, minY)...min(c.h - 1, max(0, maxY)) {
        let sy = Double(y) + 0.5
        var xs: [Double] = []
        for i in 0..<3 {
            let a = p[i], b = p[(i + 1) % 3]
            if (a.1 <= sy && b.1 > sy) || (b.1 <= sy && a.1 > sy) { xs.append(a.0 + (sy - a.1) / (b.1 - a.1) * (b.0 - a.0)) }
        }
        guard xs.count >= 2 else { continue }
        let x0 = Int((xs.min()! - 0.5).rounded(.up)), x1 = Int((xs.max()! - 0.5).rounded(.down))
        if x1 >= x0 { c.rect(x0, y, x1 - x0 + 1, 1, col) }
    }
}
