import CoreGraphics
import Foundation

// Once More, With Feeling (`SlayerWipe.musical`): red stage curtains sweep shut, a spotlight finds Sweete's top hat,
// and the curtains open on the new place.

extension SlayerTrip {
    /// A frame `k` (0…1) of the musical number, over the whole of `r`. The pelmet drops in and the red curtains sweep
    /// shut from both sides as the stage rises under them (0–0.32); the house lights dim and a spotlight slides in from
    /// the left and finds a top hat and cane on the boards (0.3–0.54); the hat twinkles and gives a little hop
    /// (0.54–0.64); blackout, the hat is gone (0.64–0.72); the curtains open on the new place as the stage sinks and the
    /// pelmet lifts away (0.72–1). All pixel art, drawn about 180 pixels tall and scaled up without smoothing.
    func drawMusical(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let shut = Self.ease(Self.span(k, 0.02, 0.32)), open = Self.ease(Self.span(k, 0.72, 0.98))
        let close = shut * (1 - open)
        ctx.drawShot(k < 0.5 ? old : new, in: r)
        if close <= 0 && (k <= 0.02 || k >= 0.98) { return }

        let px: CGFloat = max(1, (r.height / 180).rounded())
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = Self.artCanvas(width: w, height: h, px: px, in: r) else { return }
        let pen = MusicalPen(c: art, px: px, r: r, h: h)

        // The stage floor rises with the curtains and sinks as they open; the curtains stand on it.
        let fh = max(8, h / 8), floorTop = h - Int((Double(fh) * close).rounded())
        let vh = max(10, h / 9)
        let drop = Self.ease(Self.span(k, 0, 0.12)) * (1 - Self.ease(Self.span(k, 0.9, 1)))
        let pelmetBottom = Int((Double(vh) * drop).rounded())
        if floorTop < h { musicalStage(pen, top: floorTop, w: w, h: h) }

        let half = (w + 1) / 2, pw = Int((Double(half) * close).rounded())
        if pw > 0 {
            musicalCurtain(pen, from: 0, width: pw, half: half, leftSide: true, top: pelmetBottom - 2, bottom: floorTop, k: k)
            musicalCurtain(pen, from: w - pw, width: pw, half: half, leftSide: false, top: pelmetBottom - 2, bottom: floorTop, k: k)
        }

        // The house lights: dim, a spotlight that slides in from the left and finds the hat, then blackout.
        // Bigger in a short strip, where the stage is wide and low, so the hat still reads.
        let strip = Double(w) / Double(h) > 2.4
        let hatH = max(16, strip ? h * 42 / 100 : h * 2 / 9), hatX = w / 2
        let showHat = k > 0.3 && k < 0.68
        let hop = Self.span(k, 0.57, 0.63)
        let lift = Int((sin(hop * .pi) * Double(hatH) * 0.18).rounded())
        let hatBase = floorTop + fh / 3
        let dim = Self.span(k, 0.3, 0.36) * (1 - Self.span(k, 0.7, 0.76))
        let black = Self.span(k, 0.63, 0.67) * (1 - Self.span(k, 0.69, 0.73))
        let spotIn = Self.span(k, 0.34, 0.38), spotOut = Self.span(k, 0.62, 0.66)
        let spotR = min(Double(hatH) * 1.3, Double(h) * 0.45) * spotIn * (1 - spotOut)
        let travel = Self.ease(Self.span(k, 0.36, 0.54))
        let wobble = sin(travel * .pi * 2) * Double(hatH) * 0.3 * (1 - travel)
        // It starts a little way off to the left, not out in the far wing of a wide stage.
        let start = Double(hatX) - min(Double(w) * 0.38, Double(hatH) * 2.5)
        let sx = start + (Double(hatX) - start) * travel + wobble
        let sy = Double(hatBase) - Double(hatH) * 0.55
        let spot = pen.rect(sx - spotR, sy - spotR * 1.1, spotR * 2, spotR * 2.2)
        let whole = pen.rect(0, 0, Double(w), Double(h))
        let lit = dim > 0 && spotR > 1
        if lit {
            // The beam from the gallery, faint, then the pool of light itself.
            let beam = CGMutablePath()
            let src = pen.point(Double(w) * 0.5 + (sx - Double(w) * 0.5) * 0.3, -4)
            beam.move(to: CGPoint(x: src.x - 6 * px, y: src.y)); beam.addLine(to: CGPoint(x: src.x + 6 * px, y: src.y))
            beam.addLine(to: CGPoint(x: spot.maxX, y: spot.midY)); beam.addLine(to: CGPoint(x: spot.minX, y: spot.midY))
            beam.closeSubpath()
            art.addPath(beam); art.setFillColor(MusicalInk.beam.copy(alpha: 0.1 * CGFloat(dim)) ?? MusicalInk.beam); art.fillPath()
            // On the velvet the light is a warm amber that brightens the red rather than washing it pink; only on the
            // boards does it fall pale and creamy.
            art.setFillColor(MusicalInk.poolCloth); art.fillEllipse(in: spot)
            art.saveGState()
            art.clip(to: pen.rect(0, Double(floorTop), Double(w), Double(h - floorTop)))
            art.setFillColor(MusicalInk.pool); art.fillEllipse(in: spot)
            art.restoreGState()
        }
        // Sweete's top hat and cane, centre stage, while the curtains are shut.
        if showHat { musicalHat(pen, cx: hatX, base: hatBase - lift, height: hatH) }
        if dim > 0 {
            art.saveGState()
            art.addRect(whole)
            if lit { art.addEllipse(in: spot) }
            art.setFillColor(MusicalInk.dark.copy(alpha: 0.62 * CGFloat(dim)) ?? MusicalInk.dark)
            art.fillPath(using: .evenOdd)
            if lit {
                // A ring of warm light round the pool's edge.
                art.setStrokeColor(MusicalInk.poolEdge); art.setLineWidth(px)
                art.strokeEllipse(in: spot.insetBy(dx: px / 2, dy: px / 2))
            }
            art.restoreGState()
            if black > 0 { art.setFillColor(MusicalInk.dark.copy(alpha: 0.85 * CGFloat(black)) ?? MusicalInk.dark); art.fill(whole) }
            // The twinkle on the hat's crown as the light lands.
            let tw = Self.span(k, 0.53, 0.6)
            if tw > 0 && tw < 1 && showHat {
                let n = Int((sin(tw * .pi) * Double(max(3, hatH / 5))).rounded())
                let tx = hatX - hatH / 5, ty = hatBase - lift - hatH + hatH / 6
                pen.fill(tx - n, ty, 2 * n + 1, 1, MusicalInk.twinkle)
                pen.fill(tx, ty - n, 1, 2 * n + 1, MusicalInk.twinkle)
                pen.fill(tx - 1, ty - 1, 3, 3, MusicalInk.twinkle)
            }
        }

        if pelmetBottom > 0 { musicalPelmet(pen, bottom: pelmetBottom, w: w, vh: vh) }
        Self.blit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }

    /// One curtain: velvet folds that bunch up towards the wings as it opens, darker high and low, a lit fold at its
    /// leading edge and a gold-braided hem.
    private func musicalCurtain(_ pen: MusicalPen, from x0: Int, width pw: Int, half: Int, leftSide: Bool, top: Int, bottom: Int,
                         k: Double) {
        let top = max(0, top), tall = bottom - top
        guard tall > 0 else { return }
        let period = max(8.0, Double(pen.h) / 9)
        let sway = sin(k * 9) * 0.6
        for i in 0..<pw {
            // Where this column is on the cloth: measured from the wing, stretched across the half it covers.
            let fromWing = leftSide ? i : pw - 1 - i
            let t = Double(fromWing) * Double(half) / Double(max(1, pw))
            let s = sin(t / period * 2 * .pi + sway)
            let shade = s > 0.6 ? 3 : s > 0 ? 2 : s > -0.6 ? 1 : 0
            let x = x0 + i
            pen.fill(x, top, 1, tall, MusicalInk.velvet[shade])
            // Shadow under the pelmet and down by the boards.
            pen.fill(x, top, 1, max(2, tall / 10), MusicalInk.velvet[max(0, shade - 1)])
            pen.fill(x, bottom - max(2, tall / 14), 1, max(2, tall / 14), MusicalInk.velvet[max(0, shade - 1)])
        }
        // The leading edge: a bright fold, then a dark seam; the hem's gold braid.
        let lead = leftSide ? x0 + pw - 1 : x0
        pen.fill(lead, top, 1, tall, MusicalInk.velvetDeep)
        pen.fill(leftSide ? lead - 2 : lead + 1, top, 2, tall, MusicalInk.velvet[3])
        let braid = max(2, pen.h / 60)
        pen.fill(x0, bottom - braid * 2, pw, braid, MusicalInk.gold)
        pen.fill(x0, bottom - braid, pw, braid, MusicalInk.goldDark)
        for x in stride(from: x0 + (leftSide ? 0 : pw % 4), to: x0 + pw, by: 4) { pen.fill(x, bottom - braid * 2, 1, braid, MusicalInk.goldLight) }
    }

    /// The pelmet: a swagged red band with a gold fringe, hanging over the top of the stage.
    private func musicalPelmet(_ pen: MusicalPen, bottom: Int, w: Int, vh: Int) {
        let scallop = max(12, vh * 2)
        pen.fill(0, 0, w, max(1, bottom - vh / 3), MusicalInk.velvet[1])
        pen.fill(0, max(0, bottom - vh), w, 2, MusicalInk.velvet[3])
        for x in 0..<w {
            let u = Double(x % scallop) / Double(scallop) - 0.5
            let sag = Int((Double(vh / 3) * (1 - 4 * u * u)).rounded())
            let y0 = max(0, bottom - vh / 3)
            pen.fill(x, y0, 1, sag, MusicalInk.velvet[2])
            pen.fill(x, y0 + sag, 1, 2, x % 2 == 0 ? MusicalInk.gold : MusicalInk.goldDark)
        }
        // A tassel where each swag meets the next.
        for x in stride(from: 0, to: w + scallop, by: scallop) {
            let y = max(0, bottom - vh / 3)
            pen.fill(x - 1, y, 3, max(3, vh / 3), MusicalInk.goldDark)
            pen.fill(x - 1, y, 1, max(3, vh / 3), MusicalInk.gold)
        }
    }

    /// The boards of the stage, footlights glowing along the front.
    private func musicalStage(_ pen: MusicalPen, top: Int, w: Int, h: Int) {
        let rows = h - top
        pen.fill(0, top, w, rows, MusicalInk.board)
        for y in stride(from: top + 3, to: h, by: 4) { pen.fill(0, y, w, 1, MusicalInk.boardDark) }
        for (n, x) in stride(from: 0, to: w, by: 23).enumerated() {
            let y = top + 3 + (n % 3) * 4
            if y < h { pen.fill(x, y - 3, 1, 3, MusicalInk.boardDark) }
        }
        pen.fill(0, top, w, 1, MusicalInk.boardLight)
        // Footlights: little hoods along the lip, each with a warm glow above.
        if rows > 4 {
            for x in stride(from: 6, to: w, by: 18) {
                pen.fill(x - 2, top - 1, 5, 1, MusicalInk.foot)
                pen.fill(x - 1, top - 2, 3, 1, MusicalInk.footGlow)
            }
        }
    }

    /// Sweete's top hat, `height` tall, its brim's centre at `cx` and its bottom on row `base`, with his cane leant
    /// against it.
    private func musicalHat(_ pen: MusicalPen, cx: Int, base: Int, height hh: Int) {
        let crownW = hh / 2, brimW = hh, brimH = max(3, hh / 8), band = max(3, hh / 6)
        let crownH = hh - brimH
        // Its shadow on the boards.
        pen.fill(cx - brimW / 2 - 2, base, brimW + 4, max(1, hh / 16), MusicalInk.boardDark)
        // The cane, leaning against the hat's right side: black shaft, a silver ferrule and a gold knob.
        let caneH = hh * 13 / 10, footX = cx + brimW / 2 + hh / 3, topX = cx + crownW / 2 + 1
        for i in 0..<caneH {
            let y = base - 1 - i, x = footX + (topX - footX) * i / caneH
            pen.fill(x, y, 2, 1, i < 3 ? MusicalInk.hatSheen : MusicalInk.hatBlack)
            pen.fill(x + 1, y, 1, 1, i < 3 ? MusicalInk.twinkle : MusicalInk.hatSheen)
        }
        pen.fill(topX - 2, base - caneH - 3, 5, 4, MusicalInk.gold)
        pen.fill(topX - 1, base - caneH - 4, 3, 1, MusicalInk.goldLight)
        pen.fill(topX + 2, base - caneH - 2, 1, 2, MusicalInk.goldDark)
        // The crown, a touch wider at the top, with a sheen down its left.
        let cTopY = base - hh
        for y in 0..<crownH {
            let ww = crownW + (y < crownH / 3 ? 2 : 0)
            pen.fill(cx - ww / 2, cTopY + y, ww, 1, MusicalInk.hatBlack)
            pen.fill(cx - ww / 2 + max(1, hh / 12), cTopY + y, max(1, hh / 16), 1, MusicalInk.hatSheen)
        }
        pen.fill(cx - crownW / 2 - 1, cTopY, crownW + 2, 1, MusicalInk.hatSheen)
        // The red band, the colour of his suit.
        let bandY = base - brimH - band
        pen.fill(cx - crownW / 2, bandY, crownW, band, MusicalInk.hatBand)
        pen.fill(cx - crownW / 2, bandY, crownW, 1, MusicalInk.hatBandLight)
        // The brim, curled up at both ends.
        pen.fill(cx - brimW / 2 + 1, base - brimH, brimW - 2, brimH, MusicalInk.hatBlack)
        pen.fill(cx - brimW / 2, base - brimH - 2, 2, 2, MusicalInk.hatBlack)
        pen.fill(cx + brimW / 2 - 2, base - brimH - 2, 2, 2, MusicalInk.hatBlack)
        pen.fill(cx - brimW / 2 + 2, base - brimH, brimW - 4, 1, MusicalInk.hatSheen)
    }
}

/// Draws into a trip's art canvas in art pixels, rows counted down from the top.
private struct MusicalPen {
    let c: CGContext, px: CGFloat, r: CGRect, h: Int

    func rect(_ x: Double, _ y: Double, _ w: Double, _ hh: Double) -> CGRect {
        CGRect(x: r.minX + CGFloat(x) * px, y: r.minY + CGFloat(Double(h) - y - hh) * px,
               width: CGFloat(w) * px, height: CGFloat(hh) * px)
    }
    func point(_ x: Double, _ y: Double) -> CGPoint {
        CGPoint(x: r.minX + CGFloat(x) * px, y: r.minY + CGFloat(Double(h) - y) * px)
    }
    func fill(_ x: Int, _ y: Int, _ w: Int, _ hh: Int, _ col: CGColor) {
        guard w > 0, hh > 0 else { return }
        c.setFillColor(col)
        c.fill(rect(Double(x), Double(y), Double(w), Double(hh)))
    }
}

/// The theatre's colours: velvet from shadow to lit fold, gold braid, the boards and the hat.
private enum MusicalInk {
    static func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
        CGColor(red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255, alpha: a)
    }
    static let velvet = [rgb(0x4A0810), rgb(0x7A111C), rgb(0xA81C28), rgb(0xD03A44)]
    static let velvetDeep = rgb(0x2A0408)
    static let gold = rgb(0xE0B040), goldDark = rgb(0x9A6E1C), goldLight = rgb(0xFFE088)
    static let board = rgb(0x5A3A22), boardDark = rgb(0x3A2414), boardLight = rgb(0x8A6038)
    static let foot = rgb(0x2A1A10), footGlow = rgb(0xFFD070)
    static let hatBlack = rgb(0x121014), hatSheen = rgb(0x4A4652), hatBand = rgb(0xB01824), hatBandLight = rgb(0xE04450)
    static let dark = rgb(0x06040C)
    static let beam = rgb(0xFFF0C8, 0.10), pool = rgb(0xFFF0C8, 0.16), poolCloth = rgb(0xFF9A3A, 0.14)
    static let poolEdge = rgb(0xFFB860, 0.3)
    static let twinkle = rgb(0xFFFBE8)
}
