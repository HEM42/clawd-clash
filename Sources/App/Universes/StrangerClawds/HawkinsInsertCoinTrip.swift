import CoreGraphics
import Foundation

// Insert Coin (`HawkinsWipe.insertCoin`): the Palace Arcade, Max's high scores. The picture turns into an arcade
// screen, GAME OVER comes up on the old place, the screen asks for a coin, the credit goes in, and the new place loads
// like the next level.

extension HawkinsTrip {
    /// A frame `k` (0…1) of Insert Coin, over the whole of `r`. A cabinet's black bezel closes in round the picture,
    /// rounded at the corners, and scan lines come up on it (0–0.14); the old place dims, and GAME OVER slides together
    /// over it, GAME from the left and OVER from the right, and blinks (0.3–0.46); the screen goes black, INSERT COIN
    /// blinks with a coin turning beside it and CREDIT 0 under it, till the credit goes in, CREDIT 1, with a white flash
    /// (0.47–0.69); LEVEL 2 (0.69–0.76); the new place loads a band at a time from the top, each band filling left to
    /// right in blocks behind a bright cursor (0.75–0.92); the bezel draws off and the scan lines fade (0.86–1). The
    /// lettering waits till half a second in, as Walkie Static's does.
    func drawInsertCoin(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let art = HawkinsArt(r)
        let c = art.c, w = art.w, h = art.h
        let bezel = Self.ease(Self.span(k, 0, 0.14)) * (1 - Self.ease(Self.span(k, 0.86, 1)))
        let load = Self.span(k, 0.75, 0.92)
        let blink = Int(k * 1.7 * 6) % 2 == 0                            // about three blinks a second

        // The screen underneath: the old place dimming to black, then the new one loading in blocks.
        ctx.drawShot(old, in: r)
        Self.wash(ctx, 0x000000, 0.45 * Self.span(k, 0.14, 0.3) + 0.55 * Self.span(k, 0.4, 0.46), in: r)
        let band = max(4, h / 10), bands = (h + band - 1) / band
        func loaded(_ y: Int) -> Int {
            let f = Self.clamp(load * Double(bands) - Double(y / band))
            return f >= 1 ? w : Int(f * Double(w)) / band * band
        }
        if load > 0 {
            let shown = art.runs { x, y in x < loaded(y) }
            if !shown.isEmpty {
                ctx.saveGState()
                ctx.clip(to: shown)
                ctx.drawShot(new, in: r)
                ctx.restoreGState()
            }
            // The cursor: a bright block at the end of the band that's loading.
            let y = Int(load * Double(bands)) * band
            if load < 1, y < h { c.rect(loaded(y), y, band, min(band, h - y), C(0xE8F4FF, 0.85)) }
        }

        // What the screen says.
        let p = max(2, min(6, h / 24, w * 7 / 10 / hawkinsTripTextWidth("INSERT COIN", 1)))
        let cy = h / 2 - 5 * p / 2
        let shadow = C(0x000000)
        if k >= 0.3 && k < 0.46 {
            let meet = 1 - pow(1 - Self.span(k, 0.3, 0.38), 3)
            let gap = 3 * p, gw = hawkinsTripTextWidth("GAME", p), ow = hawkinsTripTextWidth("OVER", p)
            let x0 = (w - gw - gap - ow) / 2
            let off = Int((1 - meet) * Double(w) * 0.6)
            if k < 0.39 || blink {
                hawkinsTripText(c, x0 - off, cy, "GAME", C(0xFF3A2A), p, shadow: C(0x400808))
                hawkinsTripText(c, x0 + gw + gap + off, cy, "OVER", C(0xFF3A2A), p, shadow: C(0x400808))
            }
        }
        let small = max(1, p / 2)
        if k >= 0.47 && k < 0.69 {
            let paid = k >= 0.65
            let lit = ((k - 0.47) * 1.7).truncatingRemainder(dividingBy: 0.3) < 0.2   // on 0.2 s, off 0.1 s
            if !paid && lit {
                hawkinsTripCentred(c, w / 2 + 4 * p, cy, "INSERT COIN", C(0xFFD84A), p, shadow: shadow)
            }
            if !paid {
                // The coin beside it, turning: a gold disc narrowing to its edge and back.
                let cx = w / 2 - hawkinsTripTextWidth("INSERT COIN", p) / 2 - 2 * p, rr = 5 * p / 2
                let face = abs(cos(k * 1.7 * .pi * 3))
                let rx = max(1, Int(Double(rr) * face))
                c.ellipse(cx, cy + rr, rx, rr, C(0xB8862A))
                if rx > 2 { c.ellipse(cx - 1, cy + rr - 1, max(1, rx - 2), rr - 2, C(0xFFD24A)) }
                if rx > 4 { c.rect(cx - 1, cy + rr - rr / 2, 2, rr, C(0xB8862A)) }
            }
            hawkinsTripCentred(c, w / 2, h - 7 * small - max(2, h / 12), paid ? "CREDIT 1" : "CREDIT 0", C(0xF0F4F0), small,
                               shadow: shadow)
            if paid { Self.wash(ctx, 0xFFFFFF, 0.5 * (1 - Self.span(k, 0.65, 0.68)), in: r) }
        }
        if k >= 0.69 && k < 0.76 {
            hawkinsTripCentred(c, w / 2, cy, "LEVEL 2", C(0x5AE8FF), p, shadow: C(0x0A2A40))
        }

        // The scan lines, every other row.
        if bezel > 0 {
            for y in stride(from: 1, to: h, by: 2) { c.rect(0, y, w, 1, C(0x000000, 0.22 * bezel)) }
        }

        // The bezel: black plastic round the screen, its corners rounded, a lit lip along its top and left inside edge
        // and a shaded one along the bottom and right.
        let m = Int((Double(max(4, h * 7 / 100)) * bezel).rounded())
        if m > 0 {
            let body = C(0x0E0E14), lit = C(0x34343E), shade = C(0x040406)
            let rr = m * 3 / 2
            let x0 = m, y0 = m, x1 = w - m, y1 = h - m                    // the screen, x0…x1 by y0…y1
            c.rect(0, 0, w, y0, body); c.rect(0, y1, w, h - y1, body)
            c.rect(0, y0, x0, y1 - y0, body); c.rect(x1, y0, w - x1, y1 - y0, body)
            for dy in 0..<rr {
                for dx in 0..<rr {
                    let ox = Double(rr - dx) - 0.5, oy = Double(rr - dy) - 0.5
                    guard ox * ox + oy * oy > Double(rr * rr) else { continue }
                    c.px(x0 + dx, y0 + dy, body); c.px(x1 - 1 - dx, y0 + dy, body)
                    c.px(x0 + dx, y1 - 1 - dy, body); c.px(x1 - 1 - dx, y1 - 1 - dy, body)
                }
            }
            c.rect(x0 + rr, y0 - 1, x1 - x0 - 2 * rr, 1, lit); c.rect(x0 - 1, y0 + rr, 1, y1 - y0 - 2 * rr, lit)
            c.rect(x0 + rr, y1, x1 - x0 - 2 * rr, 1, shade); c.rect(x1, y0 + rr, 1, y1 - y0 - 2 * rr, shade)
        }
        art.show(ctx)
    }
}
