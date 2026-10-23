import CoreGraphics
import Foundation

// Joyce's Christmas lights, the finishing touch of every Stranger Clawds trip: a piece of the Byers' khaki wallpaper
// drops in over the new place, Joyce's alphabet painted on it in black house paint with a Christmas bulb on a sagging
// string over every letter, and the bulbs light one at a time to spell where the crew has got to, the way Will talks
// to Joyce from the Upside Down. As each one lights, its letter is painted on the line under the alphabet, so the
// whole name stands there to read; the bulbs it took flash together twice, and the wallpaper lifts away.

extension HawkinsTrip {
    /// The colours of the bulbs, round and round the string, as on the Byers' wall: red, green, blue, orange, yellow,
    /// pink. Unlit they're dull glass.
    private static let bulbs: [(dim: UInt32, lit: UInt32)] = [
        (0x6A2A26, 0xFF5A48), (0x2A5A32, 0x6AF07A), (0x2A3A6A, 0x6A9AFF), (0x7A4A22, 0xFFA040),
        (0x7A6A2A, 0xFFE860), (0x6A2E52, 0xFF80C8),
    ]

    /// The lights, `t` seconds into them (0…`lights`), over the whole of `r`. The wallpaper drops in (0–0.18 s); the
    /// bulbs spell the name a letter at a time (0.18–0.96 s), however long it is; the name's bulbs flash together
    /// twice (to 1.28 s); the wallpaper lifts away (to the end). In the window's strip the alphabet runs in one line
    /// across the top of the picture; on the screen saver it's in Joyce's three rows, A to H, I to Q and R to Z, a
    /// little way down, clear of the place name and clock in the corners.
    func drawLights(_ ctx: CGContext, t: Double, in r: CGRect) {
        let art = HawkinsArt(r)
        let c = art.c, w = art.w, h = art.h
        let name = to.name.uppercased()
        let p = 2, cell = 6 * p, m = 3 * p
        let oneRow = 26 * cell + 2 * m <= w * 96 / 100
        let rows = oneRow ? ["ABCDEFGHIJKLMNOPQRSTUVWXYZ"] : ["ABCDEFGH", "IJKLMNOPQ", "RSTUVWXYZ"]
        let alphaW = rows.map(\.count).max()! * cell
        var np = 3
        while np > 1 && hawkinsTripTextWidth(name, np) + 2 * m > w * 96 / 100 { np -= 1 }
        let nameW = hawkinsTripTextWidth(name, np)
        let pw = min(w, max(alphaW, nameW) + 2 * m)
        let rowH = 4 * p + 5 * p + 2 * p
        let ph = p + rows.count * rowH + p + 5 * np + m
        let rest = art.wide ? 0 : h * 15 / 100
        let drop = Self.ease(Self.span(t, 0, 0.18)), lift = Self.ease(Self.span(t, 1.28, Self.lights))
        let y0 = rest - Int((1 - drop + lift) * Double(rest + ph + 3))
        let x0 = (w - pw) / 2

        // The wallpaper: khaki in faint stripes with a small figure between them, its edges a shade darker, the wood
        // of a chair rail along the bottom and a soft shadow under it.
        let paper = C(0x8E7C5E), paperD = C(0x84724F), paperL = C(0x9A8868), edge = C(0x6A5A40)
        c.rect(x0, y0, pw, ph, paper)
        for x in stride(from: x0 + 3, to: x0 + pw, by: 8) {
            c.rect(x, y0, 1, ph, paperD)
            for y in stride(from: y0 + 3 + (x / 8) % 2 * 4, to: y0 + ph - 2, by: 8) { c.px(x + 4, y, paperL) }
        }
        c.rect(x0, y0, pw, 1, edge); c.rect(x0, y0, 1, ph, edge); c.rect(x0 + pw - 1, y0, 1, ph, edge)
        c.rect(x0, y0 + ph, pw, 1, C(0x9A7250)); c.rect(x0, y0 + ph + 1, pw, 2, C(0x7A563A)); c.rect(x0, y0 + ph + 3, pw, 1, C(0x4A3220))
        c.rect(x0, y0 + ph + 4, pw, 2, C(0x000000, 0.3))

        // Which letter each bulb is, and where.
        var spots: [Character: (x: Int, y: Int, n: Int)] = [:]
        var n = 0
        for (ri, row) in rows.enumerated() {
            let ry = y0 + p + ri * rowH
            let rx = x0 + (pw - row.count * cell) / 2
            for (i, ch) in row.enumerated() {
                spots[ch] = (rx + i * cell + cell / 2, ry, n)
                n += 1
            }
        }

        // The spelling: one bulb at a time, each a moment, the last ones still fading as the next lights.
        let letters = Array(name.filter { spots[$0] != nil })
        let spell = 0.78, start = 0.18
        let step = spell / Double(max(1, letters.count))
        let at = (t - start) / step
        var glow: [Character: Double] = [:]
        if t >= start + spell && t < 1.28 {
            let on = t < 1.06 || t >= 1.12
            for ch in letters { glow[ch] = on ? 1 : 0.15 }
        } else if t >= start {
            for (i, ch) in letters.enumerated() where Double(i) <= at {
                let since = at - Double(i)
                glow[ch] = max(glow[ch] ?? 0, since < 1 ? 1 : max(0, 1 - (since - 1) / 1.6))
            }
        }

        // The string and the bulbs: the cord sags between bulbs, each hanging from it over its letter.
        let cord = C(0x1E3A22)
        for (ri, row) in rows.enumerated() {
            let ry = y0 + p + ri * rowH
            let rx = x0 + (pw - row.count * cell) / 2
            for x in (rx - cell / 2)..<(rx + row.count * cell + cell / 2) {
                let u = Double((x - rx + cell * 10) % cell) / Double(cell)
                c.px(x, ry + Int((sin(u * .pi) * Double(p)).rounded()), cord)
            }
            for (i, ch) in row.enumerated() {
                let bx = rx + i * cell + cell / 2, b = Self.bulbs[(i + ri * 3) % Self.bulbs.count]
                let lit = glow[ch] ?? 0
                if lit > 0.3 {
                    // Its light: a wide soft halo round the bulb, a brighter one close in, a warm pool on the paper.
                    c.circle(bx, ry + 3 * p, 5 * p, C(b.lit, 0.12 * lit))
                    c.circle(bx, ry + 3 * p, 3 * p, C(b.lit, 0.22 * lit))
                    c.circle(bx, ry + 3 * p, 2 * p, C(b.lit, 0.35 * lit))
                }
                c.rect(bx - 1, ry, 2, p, cord)
                c.rect(bx - 2, ry + p, p + 2, p + 3, lit > 0.3 ? Self.mix(b.dim, b.lit, lit) : C(b.dim))
                c.rect(bx - 1, ry + p + p + 3, p, 1, lit > 0.3 ? Self.mix(b.dim, b.lit, lit) : C(b.dim))
                if lit > 0.3 { c.rect(bx - 1, ry + p + 1, 2, 2, C(0xFFFBEA, lit)) } else { c.px(bx - 1, ry + p + 1, C(0xFFFFFF, 0.2)) }
            }
        }

        // The alphabet, in black house paint, each letter a little off the line as Joyce painted it.
        let paint = C(0x1A1410)
        for (ch, s) in spots {
            let gw = (hawkinsTripGlyphs[ch]?.count ?? 15) / 5 * p
            let wob = noise(s.n * 17 + 3) > 0.6 ? 1 : 0
            hawkinsSoftText(c, s.x - gw / 2, s.y + 4 * p + 1 + wob, String(ch), hawkinsTripGlyphs, paint, p)
        }

        // The name, painted a letter at a time under the alphabet as the bulbs spell it.
        let shown: Int = {
            guard t >= start else { return 0 }
            var count = 0, used = 0
            for ch in name {
                if spots[ch] != nil {
                    if Double(used) > at { break }
                    used += 1
                }
                count += 1
            }
            return count
        }()
        if shown > 0 {
            let ny = y0 + p + rows.count * rowH + p
            let nx = (w - nameW) / 2
            hawkinsTripText(c, nx, ny, String(name.prefix(shown)), paint, np)
        }
        art.show(ctx)
    }
}
