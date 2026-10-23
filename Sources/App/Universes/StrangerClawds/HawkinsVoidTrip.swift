import CoreGraphics
import Foundation

// The Void (`HawkinsWipe.void`): the black, endless place Eleven goes to find people, with a thin sheet of water on
// its floor. Everything goes black but the water; the new place shows in it as a reflection, and then rises out of it.

extension HawkinsTrip {
    /// A frame `k` (0…1) of the Void, over the whole of `r`. The old place goes dark in steps, a sheet of water
    /// glinting along the bottom, a drop rippling out across it (0–0.3); the new place shows in the water, upside down,
    /// squeezed into it and wavering (0.3–0.5); it rises out of the water, top first, as the water sinks away below it, ripples running
    /// out from where it breaks the surface (0.5–0.95).
    func drawVoid(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let art = HawkinsArt(r)
        let c = art.c, w = art.w, h = art.h
        let dark = Self.ease(Self.span(k, 0, 0.26))
        let rise = Self.ease(Self.span(k, 0.5, 0.95))
        let shown = Self.ease(Self.span(k, 0.3, 0.5)) * (1 - Self.span(k, 0.8, 0.95))
        let wl0 = art.wide ? h * 74 / 100 : h * 70 / 100
        let wl = wl0 + Int(Double(h - wl0) * rise)                  // the waterline, sinking as the place rises
        let top = Int(Double(wl0) * (1 - rise))                      // the new place's top edge

        // The old place going dark, the void black over it.
        ctx.drawShot(old, in: r)
        Self.wash(ctx, 0x040508, dark, in: r)
        if dark >= 1 { ctx.setFillColor(rgb(0x040508)); ctx.fill(r) }

        // The new place, up out of the water as far as it's risen.
        if rise > 0 && wl > top {
            ctx.saveGState()
            ctx.clip(to: art.frame(0, top, w, wl - top))
            ctx.drawShot(new, in: r.offsetBy(dx: 0, dy: -CGFloat(top) * art.px))
            ctx.restoreGState()
        }

        // In the water: the new place, upside down and squeezed into the sheet of water, wavering band by band.
        if shown > 0 && wl < h {
            let pool = art.frame(0, wl, w, h - wl)
            for y in stride(from: wl, to: h, by: 2) {
                let depth = Double(y - wl) / Double(max(1, h - wl0))
                let wave = sin(Double(y) * 0.9 + k * 22) * (1 + depth * 3)
                ctx.saveGState()
                ctx.clip(to: art.frame(0, y, w, 2))
                ctx.translateBy(x: CGFloat(wave.rounded()) * art.px, y: pool.minY + pool.maxY)
                ctx.scaleBy(x: 1, y: -1)
                ctx.setAlpha(CGFloat(((0.7 - depth * 0.3) * shown * 4).rounded() / 4))
                ctx.drawShot(new, in: pool)
                ctx.restoreGState()
            }
        }

        // The water: a dark sheen over the reflection, glints running along it, and ripples spreading out.
        if wl < h && dark > 0 {
            let still = dark * dark * (1 - rise * 0.3)
            c.rect(0, wl, w, h - wl, C(0x0A1020, 0.35 * still))
            c.rect(0, wl, w, 1, C(0x6A7A96, 0.7 * still))
            for i in 0..<26 {
                let y = wl + 2 + Int(pow(noise(i * 3 + 1), 1.6) * Double(h - wl))
                guard y < h else { continue }
                let len = 4 + Int(noise(i * 3 + 2) * Double(w) * 0.08)
                let x = Int((noise(i * 3) * Double(w + len) + k * Double(10 + i % 5 * 6)).truncatingRemainder(dividingBy: Double(w + len))) - len
                c.rect(x, y, len, 1, C(0x8A9AB4, 0.3 * still * (0.5 + 0.5 * sin(k * 30 + Double(i)))))
            }
            // A drop falls into the middle, and later the place breaking the surface sends ripples out.
            for (start, life) in [(0.12, 0.45), (0.25, 0.5), (0.55, 0.45), (0.7, 0.3)] where k > start && k < start + life {
                let u = (k - start) / life
                let rx = Int(u * Double(w) * 0.45), ry = max(1, Int(u * Double(h - wl0) * 0.5))
                hawkinsRipple(c, w / 2, wl + ry + 1, rx, ry, C(0xA8B8D4, 0.55 * (1 - u) * still))
            }
        }
        art.show(ctx)
    }

    /// A flat ring on the water, `rx`×`ry` round (`cx`, `cy`), a pixel thick.
    private func hawkinsRipple(_ c: PixelCanvas, _ cx: Int, _ cy: Int, _ rx: Int, _ ry: Int, _ col: Px) {
        guard rx > 1 else { return }
        var last = -1
        for x in -rx...rx {
            let v = Double(ry) * (1 - Double(x * x) / Double(rx * rx)).squareRoot()
            let dy = Int(v.rounded())
            c.px(cx + x, cy - dy, col); c.px(cx + x, cy + dy, col)
            if last >= 0 && abs(dy - last) > 1 {
                for yy in min(dy, last)...max(dy, last) { c.px(cx + x, cy - yy, col); c.px(cx + x, cy + yy, col) }
            }
            last = dy
        }
    }
}
