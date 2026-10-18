import CoreGraphics
import Foundation

// The Lift at Wolfram & Hart (`SlayerWipe.lift`): steel lift doors close on the old place, the floor numbers count, a
// soft ding, and they open on the new place.

extension SlayerTrip {
    /// A frame `k` (0…1) of the lift ride, over the whole of `r`. The lift's black-glass header with its gold trim and
    /// row of floor numbers drops in as the brushed-steel doors slide shut from both sides (0–0.28); the lit number
    /// steps floor by floor as an arrow glows and bands of light slide down the doors (0.3–0.66); the ding: the arrow
    /// flashes and DING lights up beside the numbers (0.66–0.74); the doors part on the new place (0.72–0.95) and the
    /// header lifts away (0.9–1). Icy glass and gold, like the firm's lobby. Pixel art about 180 pixels tall, scaled up
    /// without smoothing.
    func drawLift(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let shut = Self.ease(Self.span(k, 0.04, 0.28)), open = Self.ease(Self.span(k, 0.72, 0.95))
        let close = shut * (1 - open)
        let drop = Self.ease(Self.span(k, 0, 0.12)) * (1 - Self.ease(Self.span(k, 0.9, 1)))
        ctx.draw(k < 0.5 ? old : new, in: r)
        if close <= 0 && drop <= 0 { return }

        let px: CGFloat = max(1, (r.height / 180).rounded())
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = Self.artCanvas(width: w, height: h, px: px, in: r) else { return }
        let pen = LiftPen(c: art, px: px, r: r, h: h)
        let hb = max(20, Double(w) / Double(h) > 2.4 ? h * 22 / 100 : h / 7)     // taller in a short strip, so the numbers read
        let headerBottom = Int((Double(hb) * drop).rounded())

        // The ride: which floors, which way, and where it is.
        let seed = (from.rawValue + to.rawValue).unicodeScalars.reduce(0) { $0 &* 31 &+ Int($1.value) } & 0xFFFF
        var a = 1 + seed % 3, b = a + 4 + (seed / 3) % 3
        if (seed / 9) % 2 == 1 { swap(&a, &b) }
        let ride = Self.ease(Self.span(k, 0.3, 0.66)), steps = abs(b - a)
        let floor = a + (b > a ? 1 : -1) * min(steps, Int(ride * Double(steps) + 0.15))
        let ding = Self.span(k, 0.66, 0.74)

        // The doors.
        let half = (w + 1) / 2, dw = Int((Double(half) * close).rounded())
        if dw > 0 {
            liftDoor(pen, x: 0, width: dw, origin: dw - half, top: headerBottom, half: half, leftSide: true)
            liftDoor(pen, x: w - dw, width: dw, origin: w - dw, top: headerBottom, half: half, leftSide: false)
            liftSheen(pen, w: w, h: h, top: headerBottom, spans: [(0, dw), (w - dw, w)], k: k, ride: ride, steps: steps)
        }
        if headerBottom > 0 { liftHeader(pen, w: w, hb: hb, bottom: headerBottom, a: a, b: b, floor: floor, k: k, ding: ding) }
        Self.blit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }

    /// One brushed-steel door, `width` of it showing from `x`; `origin` is where its own left edge is (offscreen as it
    /// slides), so its grain and panel ride with it.
    private func liftDoor(_ pen: LiftPen, x: Int, width dw: Int, origin: Int, top: Int, half: Int, leftSide: Bool) {
        let tall = pen.h - top
        guard tall > 0 else { return }
        for i in 0..<dw {
            let local = x + i - origin
            let n = noise(local * 7 + (leftSide ? 0 : 5000))
            let col = n < 0.3 ? LiftInk.steel[0] : n < 0.75 ? LiftInk.steel[1] : LiftInk.steel[2]
            pen.fill(x + i, top, 1, tall, col)
        }
        // Darker at the head, a kick plate at the foot.
        pen.fill(x, top, dw, max(2, tall / 24), LiftInk.steelDark)
        let kick = max(4, tall / 9)
        pen.fill(x, pen.h - kick, dw, kick, LiftInk.steelDark)
        pen.fill(x, pen.h - kick, dw, 1, LiftInk.gold)
        // The inset panel, lit from above: a dark line along its top and outer side, a pale one below and inside.
        // A wide door (the window's strip) gets a row of panels, so each stays about as wide as it's tall.
        let m = max(5, pen.h / 14), py0 = top + m, py1 = pen.h - kick - m
        let panels = max(1, Int((Double(half - m) / Double(max(1, (py1 - py0) * 6 / 5))).rounded()))
        let pitch = (half - m) / panels
        func clipFill(_ x0: Int, _ y: Int, _ ww: Int, _ hh: Int, _ col: CGColor) {
            let a = max(x0, x), b = min(x0 + ww, x + dw)
            if b > a { pen.fill(a, y, b - a, hh, col) }
        }
        for p in 0..<panels where py1 > py0 + 4 {
            let px0 = origin + m + p * pitch, px1 = px0 + pitch - m
            clipFill(px0, py0, px1 - px0, 1, LiftInk.line)
            clipFill(px0, py0, 1, py1 - py0, LiftInk.line)
            clipFill(px0, py1, px1 - px0 + 1, 1, LiftInk.pale)
            clipFill(px1, py0, 1, py1 - py0, LiftInk.pale)
            // A gold rail across the panel, and above it a sunburst etched into the steel, in the deco style of the
            // firm's lobby: rays fanning up from the rail's middle to the panel's top.
            let rail = py0 + (py1 - py0) / 3
            clipFill(px0 + 2, rail, px1 - px0 - 3, 1, LiftInk.gold)
            clipFill(px0 + 2, rail + 1, px1 - px0 - 3, 1, LiftInk.goldDark)
            let cx = (px0 + px1) / 2, reach = rail - py0 - 3
            if reach > 4 {
                for ray in 0..<9 {
                    let ang = Double.pi * (0.12 + 0.76 * Double(ray) / 8)
                    let len = Double(reach) * (ray % 2 == 0 ? 1 : 0.7)
                    for d in stride(from: Double(reach) * 0.22, to: len, by: 1) {
                        clipFill(cx + Int((cos(ang) * d * 1.3).rounded()), rail - 1 - Int((sin(ang) * d).rounded()), 1, 1, LiftInk.etch)
                    }
                }
                clipFill(cx - 1, rail - 2, 3, 2, LiftInk.goldDark)
            }
        }
        // Gold pinstripes down the meeting edge.
        pen.fill(leftSide ? x + dw - 4 : x + 3, top, 1, tall, LiftInk.goldDark)
        // The meeting edge: a dark seam with a bright bevel beside it.
        let edge = leftSide ? x + dw - 1 : x
        pen.fill(edge, top, 1, tall, LiftInk.seam)
        pen.fill(leftSide ? edge - 1 : edge + 1, top, 1, tall, LiftInk.pale)
    }

    /// The light on the doors: two icy diagonal reflections that stay put as the doors slide under them, and, while the
    /// lift moves, a soft band of light sliding down them once a floor.
    private func liftSheen(_ pen: LiftPen, w: Int, h: Int, top: Int, spans: [(Int, Int)], k: Double, ride: Double,
                           steps: Int) {
        func across(_ y: Int, _ x0: Int, _ x1: Int, _ col: CGColor) {
            for (a, b) in spans {
                let lo = max(a, x0), hi = min(b, x1)
                if hi > lo { pen.fill(lo, y, hi - lo, 1, col) }
            }
        }
        let band = max(6, h / 6)
        for y in top..<h {
            let slant = (h - y) / 2
            for (start, width) in [(w / 5, band), (w / 5 + band * 2, band / 3)] {
                let x0 = start + slant - h / 2
                across(y, x0, x0 + width, LiftInk.sheen)
                across(y, x0 + width / 2, x0 + width / 2 + 1, LiftInk.sheenCore)
            }
        }
        if ride > 0 && ride < 1 && steps > 0 {
            let u = (ride * Double(steps)).truncatingRemainder(dividingBy: 1)
            let y0 = top + Int(u * Double(h - top + band)) - band
            for y in max(top, y0)..<min(h, y0 + band) { across(y, 0, w, LiftInk.pass) }
        }
    }

    /// The header above the doors: black glass in gold trim, an arrow lantern, the floor numbers with the current one
    /// lit, and DING when it arrives.
    private func liftHeader(_ pen: LiftPen, w: Int, hb: Int, bottom: Int, a: Int, b: Int, floor: Int, k: Double, ding: Double) {
        let y0 = bottom - hb
        pen.fill(0, y0, w, hb, LiftInk.glass)
        pen.fill(0, y0 + hb / 3, w, 1, LiftInk.glassLine)
        pen.fill(0, bottom - 3, w, 2, LiftInk.gold)
        pen.fill(0, bottom - 1, w, 1, LiftInk.goldDark)
        // The numbers 1 to 9, centred, in a recessed strip.
        let sc = max(1, (hb - 10) / 7), cell = 5 * sc, glyphH = 5 * sc
        let rowW = 9 * cell - 2 * sc, gy = y0 + (hb - 3 - glyphH) / 2
        let x0 = (w - rowW) / 2
        pen.fill(x0 - 3 * sc, gy - 2 * sc, rowW + 6 * sc, glyphH + 4 * sc, LiftInk.recess)
        pen.fill(x0 - 3 * sc, gy + glyphH + 2 * sc, rowW + 6 * sc, 1, LiftInk.goldDark)
        for n in 1...9 {
            let x = x0 + (n - 1) * cell, here = n == floor
            if here { pen.fill(x - sc, gy - sc, 5 * sc, glyphH + 2 * sc, LiftInk.glow) }
            liftGlyph(pen, Character("\(n)"), x, gy, sc, here ? LiftInk.lit : LiftInk.unlit)
        }
        // The arrow lantern, left of the numbers: lit while it rides, flashing at the ding.
        let up = b > a, ax = x0 - 9 * sc, ay = gy
        let riding = k > 0.29 && ding <= 0
        let flash = ding > 0 && Int(ding * 6) % 2 == 0
        let arrow = riding || flash || ding >= 1 ? LiftInk.lit : LiftInk.unlit
        let head = (glyphH * 3 + 4) / 5, mid = ax + 2 * sc
        for row in 0..<glyphH {
            let fromTip = up ? row : glyphH - 1 - row
            let half = fromTip < head ? fromTip * 2 * sc / max(1, head - 1) : max(0, sc / 2)
            pen.fill(mid - half, ay + row, 2 * half + 1, 1, arrow)
        }
        // DING, right of the numbers, with little rays as it sounds.
        if ding > 0 {
            let dx = x0 + rowW + 6 * sc
            for (i, ch) in "DING".enumerated() { liftGlyph(pen, ch, dx + i * 4 * sc, gy, sc, LiftInk.ding) }
            if ding < 1 {
                let ray = 1 + Int(ding * 3) * sc
                let cx = dx + 8 * sc - sc, cy = gy + glyphH / 2
                pen.fill(cx - 9 * sc - ray, cy, ray, 1, LiftInk.ding)
                pen.fill(cx + 9 * sc, cy, ray, 1, LiftInk.ding)
            }
        }
    }

    /// A 3×5 glyph, `sc` pixels a dot, from its top-left corner.
    private func liftGlyph(_ pen: LiftPen, _ ch: Character, _ x: Int, _ y: Int, _ sc: Int, _ col: CGColor) {
        guard let bits = LiftInk.glyphs[ch] else { return }
        for (i, bit) in bits.enumerated() where bit == "1" { pen.fill(x + (i % 3) * sc, y + (i / 3) * sc, sc, sc, col) }
    }
}

/// Draws into a trip's art canvas in art pixels, rows counted down from the top.
private struct LiftPen {
    let c: CGContext, px: CGFloat, r: CGRect, h: Int

    func fill(_ x: Int, _ y: Int, _ w: Int, _ hh: Int, _ col: CGColor) {
        guard w > 0, hh > 0 else { return }
        c.setFillColor(col)
        c.fill(CGRect(x: r.minX + CGFloat(x) * px, y: r.minY + CGFloat(h - y - hh) * px, width: CGFloat(w) * px,
                      height: CGFloat(hh) * px))
    }
}

/// The lift's colours: brushed steel, icy glass, gold trim and amber numbers.
private enum LiftInk {
    static func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
        CGColor(red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255, alpha: a)
    }
    static let steel = [rgb(0x8E98A2), rgb(0x949EA8), rgb(0x9CA6B0)]
    static let steelDark = rgb(0x6A747E), line = rgb(0x5A626C), pale = rgb(0xC8D2DA), seam = rgb(0x1A1E24)
    static let etch = rgb(0x646E7A)
    static let gold = rgb(0xD8B050), goldDark = rgb(0x8A6A28)
    static let sheen = rgb(0xE8F6FF, 0.12), sheenCore = rgb(0xF4FBFF, 0.3), pass = rgb(0xFFF2D0, 0.12)
    static let glass = rgb(0x0A0E16), glassLine = rgb(0x2A3A4C), recess = rgb(0x040608)
    static let lit = rgb(0xFFC860), glow = rgb(0x5A3A10), unlit = rgb(0x3A3020), ding = rgb(0xFFE8A8)
    static let glyphs: [Character: String] = [
        "1": "010110010010111", "2": "111001111100111", "3": "111001011001111", "4": "101101111001001",
        "5": "111100111001111", "6": "111100111101111", "7": "111001001010010", "8": "111101111101111",
        "9": "111101111001111", "D": "110101101101110", "I": "111010010010111", "N": "110101101101101",
        "G": "011100101101011",
    ]
}
