import AppKit
import CoreText

// Words on screen: captions, the universe's pill, comic caption boxes and speech balloons.
// Part of RenderPromo's kit: declarations only. main.swift picks the reel and runs it; its header has the build
// command.

// MARK: Text

func attributed(_ s: String, size: CGFloat, weight: NSFont.Weight = .heavy, color: NSColor = .white, alpha: Double = 1,
                font: NSFont? = nil, kern: CGFloat = 0) -> NSAttributedString {
    let shadow = NSShadow(); shadow.shadowColor = NSColor.black.withAlphaComponent(0.6 * alpha)
    shadow.shadowBlurRadius = 12; shadow.shadowOffset = NSSize(width: 0, height: -3)
    return NSAttributedString(string: s, attributes: [.font: font ?? NSFont.systemFont(ofSize: size, weight: weight),
                                                      .foregroundColor: color.withAlphaComponent(alpha), .kern: kern, .shadow: shadow])
}

func text(_ s: String, _ ctx: CGContext, x: Double? = nil, y: Double, size: CGFloat, weight: NSFont.Weight = .heavy,
          color: NSColor = .white, alpha: Double = 1, font: NSFont? = nil, kern: CGFloat = 0) {
    let a = attributed(s, size: size, weight: weight, color: color, alpha: alpha, font: font, kern: kern)
    a.draw(at: NSPoint(x: x ?? (Double(W) - a.size().width) / 2, y: y))
}

/// A caption that slides up and fades in at `start` (shot-local seconds).
func caption(_ s: String, _ ctx: CGContext, local: Double, start: Double = 0.1, y: Double = 900, size: CGFloat = 64,
             color: NSColor = .white, weight: NSFont.Weight = .heavy) {
    let f = easeOut((local - start) / 0.35)
    guard f > 0 else { return }
    text(s, ctx, y: y - 30 * (1 - f), size: size, weight: weight, color: color, alpha: f)
}

/// A small pill naming the mode on show ("DESKTOP MODE", "WINDOW MODE"), top-left.
func modeBadge(_ s: String, _ ctx: CGContext, local: Double) {
    let f = easeOut((local - 0.2) / 0.3)
    guard f > 0 else { return }
    let a = NSAttributedString(string: s, attributes: [.font: NSFont.monospacedSystemFont(ofSize: 26, weight: .heavy),
                                                       .foregroundColor: NSColor.black, .kern: 3])
    let sz = a.size()
    let r = CGRect(x: 60 - 40 * (1 - f), y: 980, width: sz.width + 36, height: sz.height + 16)
    ctx.saveGState(); ctx.setAlpha(CGFloat(f))
    ctx.addPath(CGPath(roundedRect: r, cornerWidth: r.height / 2, cornerHeight: r.height / 2, transform: nil))
    ctx.setFillColor(yellow.cgColor); ctx.fillPath()
    a.draw(at: NSPoint(x: r.minX + 18, y: r.minY + 8))
    ctx.restoreGState()
}

/// The universe on show, top left, in a yellow pill.
func badge(_ s: String, _ ctx: CGContext, alpha: Double) {
    let a = inked(s, [.font: NSFont.monospacedSystemFont(ofSize: 26, weight: .heavy), .kern: 3], color: .black, alpha: 1)
    let sz = a.size()
    let r = CGRect(x: 60, y: 980, width: sz.width + 36, height: sz.height + 16)
    ctx.saveGState(); ctx.setAlpha(CGFloat(alpha))
    ctx.addPath(CGPath(roundedRect: r, cornerWidth: r.height / 2, cornerHeight: r.height / 2, transform: nil))
    ctx.setFillColor(yellow.cgColor); ctx.fillPath()
    a.draw(at: NSPoint(x: r.minX + 18, y: r.minY + 8))
    ctx.restoreGState()
}

/// `s` in `color`; in "DETECTIVE CLAWDS" only the D and the C at full strength, the rest faded, so it reads DC.
func inked(_ s: String, _ attrs: [NSAttributedString.Key: Any], color: NSColor, alpha: Double) -> NSAttributedString {
    var a = attrs; a[.foregroundColor] = color.withAlphaComponent(alpha)
    let out = NSMutableAttributedString(string: s, attributes: a)
    if s.uppercased() == Universe.dc.title.uppercased() {
        out.addAttribute(.foregroundColor, value: color.withAlphaComponent(alpha * 0.32), range: NSRange(location: 0, length: out.length))
        for i in [0, (s as NSString).range(of: " ").location + 1] {
            out.addAttribute(.foregroundColor, value: color.withAlphaComponent(alpha), range: NSRange(location: i, length: 1))
        }
    }
    return out
}

/// A comic caption box: yellow, a thick black border, black italic capitals.
func captionBox(_ s: String, _ ctx: CGContext, center: CGPoint, size: CGFloat, alpha: Double = 1) {
    let font = NSFontManager.shared.convert(NSFont.systemFont(ofSize: size, weight: .black), toHaveTrait: .italicFontMask)
    let a = inked(s, [.font: font], color: .black, alpha: alpha)
    let sz = a.size()
    let r = CGRect(x: center.x - sz.width / 2 - size * 0.7, y: center.y - sz.height / 2 - size * 0.45,
                   width: sz.width + size * 1.4, height: sz.height + size * 0.9)
    ctx.saveGState(); ctx.setAlpha(CGFloat(alpha))
    ctx.setFillColor(CGColor(gray: 0, alpha: 1)); ctx.fill(r.offsetBy(dx: 10, dy: -10))
    ctx.setFillColor(CGColor(red: 1, green: 0.88, blue: 0.29, alpha: 1)); ctx.fill(r)
    ctx.setStrokeColor(CGColor(gray: 0, alpha: 1)); ctx.setLineWidth(6); ctx.stroke(r)
    ctx.restoreGState()
    a.draw(at: NSPoint(x: r.minX + size * 0.7, y: r.minY + size * 0.45))
}

/// A comic speech balloon around `s`, centred on `c`, its tail pointing at `tail` (screen pixels, y up).
func balloon(_ s: String, _ ctx: CGContext, center c: CGPoint, tail: CGPoint, size: CGFloat = 40, width: CGFloat = 640,
             color: NSColor = .black, alpha: Double = 1) {
    guard alpha > 0 else { return }
    let p = NSMutableParagraphStyle(); p.alignment = .center
    let a = NSAttributedString(string: s, attributes: [.font: NSFont.systemFont(ofSize: size, weight: .heavy),
                                                       .foregroundColor: color.withAlphaComponent(alpha), .paragraphStyle: p])
    let box = a.boundingRect(with: NSSize(width: width, height: 800), options: [.usesLineFragmentOrigin])
    let rx = box.width / 2 + size * 1.0, ry = box.height / 2 + size * 0.7
    let oval = CGRect(x: c.x - rx, y: c.y - ry, width: rx * 2, height: ry * 2)
    // the tail: a wedge from under the balloon to the speaker
    let ang = atan2(tail.y - c.y, tail.x - c.x), spread = 0.22
    let base1 = CGPoint(x: c.x + cos(ang - spread) * rx * 0.7, y: c.y + sin(ang - spread) * ry * 0.7)
    let base2 = CGPoint(x: c.x + cos(ang + spread) * rx * 0.7, y: c.y + sin(ang + spread) * ry * 0.7)
    let tailPath = CGMutablePath(); tailPath.addLines(between: [base1, tail, base2]); tailPath.closeSubpath()
    ctx.saveGState(); ctx.setAlpha(CGFloat(alpha))
    ctx.setLineWidth(7); ctx.setLineJoin(.round); ctx.setStrokeColor(CGColor(gray: 0, alpha: 1))
    ctx.addPath(tailPath); ctx.strokePath()
    ctx.addEllipse(in: oval); ctx.strokePath()
    ctx.setFillColor(CGColor(gray: 1, alpha: 1))
    ctx.addPath(tailPath); ctx.fillPath()
    ctx.fillEllipse(in: oval)
    ctx.restoreGState()
    a.draw(with: NSRect(x: c.x - box.width / 2, y: c.y - box.height / 2, width: box.width, height: box.height), options: [.usesLineFragmentOrigin])
}

/// Where a character's head is on screen (for balloon tails), at the frame's own stage.
func headPoint(_ a: Actor) -> CGPoint { CGPoint(x: a.x * S, y: stageH - (a.top + Double(a.cast.headTop) * a.k) * S) }

/// The outline of `s` in Futura Condensed ExtraBold, centred on the origin.
func letters(_ s: String) -> CGPath {
    let font = CTFontCreateWithName("Futura-CondensedExtraBold" as CFString, 200, nil)
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: s, attributes: [.font: font]))
    let path = CGMutablePath()
    for run in CTLineGetGlyphRuns(line) as! [CTRun] {
        let count = CTRunGetGlyphCount(run)
        var glyphs = [CGGlyph](repeating: 0, count: count), at = [CGPoint](repeating: .zero, count: count)
        CTRunGetGlyphs(run, CFRange(location: 0, length: count), &glyphs)
        CTRunGetPositions(run, CFRange(location: 0, length: count), &at)
        for i in 0..<count {
            if let g = CTFontCreatePathForGlyph(font, glyphs[i], nil) { path.addPath(g, transform: CGAffineTransform(translationX: at[i].x, y: at[i].y)) }
        }
    }
    let b = path.boundingBox
    var t = CGAffineTransform(translationX: -b.midX, y: -b.midY)
    return path.copy(using: &t)!
}
