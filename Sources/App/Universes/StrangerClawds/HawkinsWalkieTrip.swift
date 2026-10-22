import CoreGraphics
import Foundation

// Walkie Static (`HawkinsWipe.walkie`): the Party's walkie-talkies. The picture breaks up into static the way a set
// loses its signal, a walkie-talkie crackles "DO YOU COPY?" and "OVER." through the snow, and the picture tunes back
// in on the new place.

extension HawkinsTrip {
    /// A frame `k` (0…1) of Walkie Static, over the whole of `r`. The old place tears into slipping bands, lines of
    /// static running through it (0–0.3); snow takes the whole picture, scan lines across it, and a walkie-talkie
    /// comes up in the middle of it, its light blinking as DO YOU COPY? comes through, then OVER. (0.3–0.74); the new
    /// place tunes in through the thinning snow, slipping a little and settling, a bright bar rolling down it (0.64–0.94).
    /// The lettering waits until the picture has been changing for a moment, so it never shows mirrored while the Upside
    /// Down turns back the right way up behind it.
    func drawWalkie(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let art = HawkinsArt(r)
        let c = art.c, w = art.w, h = art.h
        let frame = Int(k * 36)                       // the static changes about 24 times a second
        let breakUp = Self.span(k, 0, 0.32), tuneIn = Self.span(k, 0.64, 0.94)
        let snow = k < 0.5 ? Self.ease(Self.span(k, 0.18, 0.36)) : 1 - Self.ease(tuneIn)

        // The picture underneath, torn into bands that slip sideways: the old place losing the signal, then the new one
        // finding it.
        let picture = k < 0.55 ? old : new
        let tear = k < 0.55 ? breakUp : 1 - tuneIn
        let band = max(3, h / 14)
        for b in 0...(h / band) {
            let slip = tear * (noise(b * 31 + frame * 7) - 0.5) * Double(w) * 0.16 * (noise(b * 5 + frame) > 0.55 ? 1 : 0.25)
            let roll = k > 0.55 ? Int((1 - Self.ease(Self.span(k, 0.64, 0.8))) * Double(h) * 0.3) : 0
            let rows = art.frame(0, b * band, w, band)
            ctx.saveGState()
            ctx.clip(to: rows)
            let dx = slip.rounded() * art.px, dy = CGFloat(roll) * art.px
            ctx.drawShot(picture, in: r.offsetBy(dx: dx, dy: dy))
            if roll > 0 { ctx.drawShot(picture, in: r.offsetBy(dx: dx, dy: dy - r.height)) }
            ctx.restoreGState()
        }

        // The static: lines of it running through the picture, then snow over all of it, with scan lines.
        for y in 0..<h {
            let line = noise(y * 13 + frame * 101) < tear * 0.35
            let a = max(snow, line ? 0.85 : 0)
            guard a > 0.02 else { continue }
            let dark = y % 2 == 1
            for x in 0..<w {
                let v = noise(x * 7919 + y * 104729 + frame * 15485863 & 0xFFFFFF)
                let g = UInt32(v < 0.55 ? 0x14 + v * 90 : 0x40 + v * 120)
                let grey = (g << 16) | (g << 8) | g
                c.px(x, y, C(grey, dark ? a * 0.85 : a))
            }
        }
        // The bright bar a set rolls down the picture as it locks on.
        if tuneIn > 0 && tuneIn < 1 {
            let by = Int(tuneIn * Double(h + band * 2)) - band
            c.rect(0, by, w, band, C(0xE8F0FF, 0.16 * (1 - tuneIn)))
        }

        // The walkie-talkie and what it says, in the middle of the snow.
        let say = Self.span(k, 0.36, 0.42) * (1 - Self.span(k, 0.7, 0.74))
        if say > 0 {
            let p = 3
            let lines: [String] = k < 0.6 ? ["DO YOU COPY?"] : ["DO YOU COPY?", "OVER."]
            let textW = hawkinsTripTextWidth("DO YOU COPY?", p)
            let wh = min(h * 62 / 100, 80), ww = wh * 9 / 20
            let gap = 4 * p, groupW = ww + gap + textW
            let gx = (w - groupW) / 2, gy = (h - wh) / 2 + wh / 10
            hawkinsWalkieTalkie(c, gx, gy, ww, wh, talking: Int(k * 20) % 2 == 0)
            // A black box behind the words, like a set's captions.
            let tx = gx + ww + gap, ty = gy + wh / 2 - (lines.count * 7 * p) / 2
            c.rect(tx - 2 * p, ty - 2 * p, textW + 4 * p, lines.count * 7 * p + 2 * p, C(0x000000, 0.75))
            for (i, s) in lines.enumerated() {
                hawkinsTripText(c, tx, ty + i * 7 * p, s, i == 0 ? C(0xF0F4F0) : C(0xFFD860), p, shadow: C(0x000000))
            }
        }
        art.show(ctx)
    }

    /// A walkie-talkie standing upright, `ww`×`wh` from its body's top-left (the aerial rises above it): a black plastic
    /// body lit along its left edge, the speaker grille in slits, a red push-to-talk button on the side, a tan label,
    /// the channel knob and the light that blinks red while it talks.
    private func hawkinsWalkieTalkie(_ c: PixelCanvas, _ x: Int, _ y: Int, _ ww: Int, _ wh: Int, talking: Bool) {
        let body = C(0x2A2A30), lit = C(0x4E4E58), shade = C(0x18181C), slit = C(0x0C0C0E)
        // The aerial: up from the top left, a knob on the end.
        let ah = wh * 6 / 10
        c.rect(x + ww / 5, y - ah, 2, ah, C(0x9A9EA8)); c.rect(x + ww / 5, y - ah, 1, ah, C(0xC8CCD4))
        c.rect(x + ww / 5 - 1, y - ah - 2, 4, 3, C(0x2A2A30))
        c.rect(x + ww / 5 - 2, y - 4, 6, 4, shade)
        // The knob and the light on top.
        c.rect(x + ww * 6 / 10, y - 3, ww / 5, 3, C(0x3A3A42)); c.rect(x + ww * 6 / 10, y - 3, ww / 5, 1, lit)
        c.rect(x + ww - 5, y - 2, 3, 2, talking ? C(0xFF3A2A) : C(0x5A1A14))
        if talking { c.circle(x + ww - 4, y - 2, 3, C(0xFF3A2A, 0.3)) }
        // The body, rounded at the corners, lit on the left and shaded on the right.
        c.rect(x + 1, y, ww - 2, wh, body); c.rect(x, y + 1, ww, wh - 2, body)
        c.rect(x, y + 1, 2, wh - 2, lit); c.rect(x + 1, y, ww - 3, 1, lit)
        c.rect(x + ww - 2, y + 1, 2, wh - 2, shade); c.rect(x + 1, y + wh - 1, ww - 2, 1, shade)
        // The grille: slits across the top half.
        let gx = x + ww / 6, gw = ww * 2 / 3
        for sy in stride(from: y + wh / 8, to: y + wh / 2, by: 3) {
            c.rect(gx, sy, gw, 1, slit); c.rect(gx, sy + 1, gw, 1, C(0x3A3A42))
        }
        // The label under it, with a stripe of red, and the push-to-talk button on the side.
        let ly = y + wh * 6 / 10
        c.rect(gx, ly, gw, wh / 6, C(0xB8A070)); c.rect(gx, ly, gw, 1, C(0xD8C090)); c.rect(gx, ly + wh / 12, gw, 2, C(0xA83A2A))
        c.rect(x - 2, y + wh / 4, 2, wh / 5, talking ? C(0xC8382A) : C(0x8A2A20))
        // A belt clip's shadow down the right, and the screws.
        c.px(x + 3, y + 3, C(0x6A6A72)); c.px(x + ww - 4, y + 3, C(0x6A6A72))
        c.px(x + 3, y + wh - 4, C(0x6A6A72)); c.px(x + ww - 4, y + wh - 4, C(0x6A6A72))
    }
}
