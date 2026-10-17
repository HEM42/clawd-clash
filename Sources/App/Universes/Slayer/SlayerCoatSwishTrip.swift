import CoreGraphics
import Foundation

// The Coat Swish (`SlayerWipe.coatSwish`): a long black coat sweeps across the screen as someone strides past, city
// lights blurring in its folds, and the new place is behind it.

extension SlayerTrip {
    /// A frame `k` (0…1) of the coat swish, over the whole of `r`. The coat comes in from the left, close to the camera
    /// and taller than the frame, and sweeps across to the right like a wipe (0.04–0.96, quick in the middle): its front
    /// edge lags a little at the hem and its tail billows well behind, rippling. Its leather folds follow its shape, cool
    /// steel along each crest, with streaks of city light (amber and white) sliding back along them; a few dark speed
    /// lines trail it over the new place. Pixel art about 180 pixels tall, scaled up without smoothing.
    func drawCoatSwish(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let px: CGFloat = max(1, (r.height / 180).rounded())
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        let fw = Double(w), fh = Double(h)
        // The coat's shape: its body width and how far the hem lags at the front and the tail.
        let body = max(fw * 0.5, fh * 1.5), leadLag = fh * 0.22, tailLag = fh * 0.8, ripple = fh * 0.07
        let p = Self.coatTravel(Self.span(k, 0.04, 0.96))
        let start = 0.0, end = fw + body + tailLag + ripple * 2
        let lead = start + (end - start) * p
        func edges(_ y: Int) -> (tail: Double, front: Double) {
            let v = Double(y) / fh                                      // 0 at the top, 1 at the hem
            let front = lead - leadLag * v * v + sin(v * 5 + k * 18) * ripple * 0.3 * v
            let tail = lead - body - tailLag * pow(v, 1.4) + sin(v * 7 - k * 26) * ripple * (0.3 + v)
            return (tail, front)
        }

        // Where the coat has passed, the new place; ahead of it, the old one.
        if lead <= 0 { ctx.draw(old, in: r); return }
        let past = (0..<h).map { edges($0).tail }.min() ?? 0
        if past >= fw { ctx.draw(new, in: r); return }
        ctx.draw(old, in: r)
        // The new place behind the tail, row by row on the art grid.
        var rows: [CGRect] = []
        for y in 0..<h {
            let t = Int(edges(y).tail.rounded())
            if t > 0 { rows.append(CGRect(x: r.minX, y: r.minY + CGFloat(h - y - 1) * px, width: CGFloat(min(t, w)) * px, height: px)) }
        }
        if !rows.isEmpty { ctx.saveGState(); ctx.clip(to: rows); ctx.draw(new, in: r); ctx.restoreGState() }

        guard let art = Self.artCanvas(width: w, height: h, px: px, in: r) else { return }
        let pen = CoatPen(c: art, px: px, r: r, h: h)
        let folds = 7
        for y in 0..<h {
            let (tail, front) = edges(y)
            let x0 = Int(tail.rounded()), x1 = Int(front.rounded())
            guard x1 > 0, x0 < w, x1 > x0 else { continue }
            let v = Double(y) / fh
            pen.fill(x0, y, x1 - x0, 1, CoatInk.leather)
            // The folds: crests that follow the coat's shape, each lit on its near side (the light comes from ahead,
            // the city) and dropping into shadow beyond, so the leather reads as ribbed and swinging.
            var prev = x0
            for i in 1...folds {
                let f = i == folds ? 1 : Double(i) / Double(folds) + sin(v * 4 + Double(i) * 1.7 + k * 6) * 0.03
                let x = Int((tail + (front - tail) * f).rounded())
                let seg = x - prev
                if seg > 3 {
                    let litW = seg * 2 / 5, midW = seg / 5
                    pen.fill(x - litW - midW, y, midW, 1, CoatInk.leatherMid)
                    pen.fill(x - litW, y, litW, 1, CoatInk.leatherHigh)
                    pen.fill(x - max(1, litW / 3), y, max(1, litW / 3), 1, CoatInk.crestDim)
                    pen.fill(prev, y, min(2, seg), 1, CoatInk.shadow)
                }
                if i < folds { pen.fill(x - 1, y, 1, 1, i % 2 == 0 ? CoatInk.crest : CoatInk.steel) }
                prev = x
            }
            // The rims: a cool steel line down the front edge, a fainter one on the tail.
            pen.fill(x1 - 2, y, 2, 1, CoatInk.steel)
            pen.fill(x1 - 3, y, 1, 1, CoatInk.crest)
            pen.fill(x0, y, 1, 1, CoatInk.crestDim)
        }
        // The city's lights, blurred into streaks that slide back along the folds as it moves.
        let lights = max(24, h / 3)
        for n in 0..<lights {
            let fold = 1 + n % (folds - 1)
            let y = Int(noise(n * 31 + 7) * fh)
            let (tail, front) = edges(y)
            let f = Double(fold) / Double(folds) - 0.02 * noise(n * 3 + 5)
            let x = Int((tail + (front - tail) * f).rounded())
            let len = 4 + Int(noise(n * 17 + 3) * 14)
            let drift = Int((k * 40 + noise(n * 5) * 30).truncatingRemainder(dividingBy: 30))
            let ly = y + drift - 15
            guard ly >= 0, ly < h else { continue }
            let col = noise(n * 13 + 1) < 0.6 ? CoatInk.amber : noise(n * 13 + 2) < 0.5 ? CoatInk.white : CoatInk.cool
            let lx = x - len + 1
            pen.fill(lx, ly, len, 1, col.dim)
            pen.fill(lx + len / 3, ly, max(1, len / 3), 1, col.core)
        }
        // Speed lines trailing the tail over the new place.
        for n in 0..<max(4, h / 30) {
            let y = Int(noise(n * 11 + 90) * fh)
            let t = edges(y).tail
            let len = Int(fh * (0.15 + noise(n * 7 + 91) * 0.25))
            let gap = Int(fh * 0.04 + noise(n * 3 + 92) * fh * 0.1)
            pen.fill(Int(t) - gap - len, y, len, 1, CoatInk.speed)
        }
        Self.blit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }

    /// How far the coat has gone at `t` (0…1): a stride that's quickest in the middle, with a softer start than
    /// `ease` so it's moving as it comes on.
    private static func coatTravel(_ t: Double) -> Double { 0.5 * ease(t) + 0.5 * t }
}

/// Draws into a trip's art canvas in art pixels, rows counted down from the top.
private struct CoatPen {
    let c: CGContext, px: CGFloat, r: CGRect, h: Int

    func fill(_ x: Int, _ y: Int, _ w: Int, _ hh: Int, _ col: CGColor) {
        guard w > 0, hh > 0 else { return }
        c.setFillColor(col)
        c.fill(CGRect(x: r.minX + CGFloat(x) * px, y: r.minY + CGFloat(h - y - hh) * px, width: CGFloat(w) * px,
                      height: CGFloat(hh) * px))
    }
}

/// The coat's colours: black leather with cool steel crests, and the city's lights.
private enum CoatInk {
    static func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
        CGColor(red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255, alpha: a)
    }
    static let leather = rgb(0x0B0C11), leatherMid = rgb(0x0E1019), leatherHigh = rgb(0x121522), shadow = rgb(0x040408)
    static let crest = rgb(0x3A4658), crestDim = rgb(0x1C2230), steel = rgb(0x7A8CA0)
    static let speed = rgb(0x0B0C11, 0.45)
    static let amber = (dim: rgb(0xB06A20, 0.85), core: rgb(0xFFD27A))
    static let white = (dim: rgb(0x8A8C80, 0.85), core: rgb(0xFFF6DC))
    static let cool = (dim: rgb(0x3A6A8E, 0.85), core: rgb(0xBDE6FF))
}
