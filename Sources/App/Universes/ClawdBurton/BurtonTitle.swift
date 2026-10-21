import AppKit
import CoreGraphics

// The Clawd Burton title lockup, shared by the tools that show it: the trailer (Tools/RenderPromo), the transitions
// showcase (Tools/Transitions) and the social preview. The app itself never draws it.

/// A point of one of the title's letters, in the letter's own box (`u` across, `v` down, both 0…1).
typealias BurtonGlyph = [[(Double, Double)]]

/// Points round an ellipse in a letter's box, from `a0` to `a1` degrees (0 is right, 90 is down).
func burtonArc(_ cx: Double, _ cy: Double, _ rx: Double, _ ry: Double, _ a0: Double, _ a1: Double, _ n: Int = 10) -> [(Double, Double)] {
    (0...n).map { k in
        let a = (a0 + (a1 - a0) * Double(k) / Double(n)) * .pi / 180
        return (cx + cos(a) * rx, cy + sin(a) * ry)
    }
}

/// The title's letters, as strokes: tall, thin and a little wobbly, the C, the L and the N's tail curling at their ends.
let burtonGlyphs: [Character: BurtonGlyph] = [
    "C": [Array([(0.84, 0.24), (0.8, 0.14), (0.9, 0.08), (0.98, 0.16)].reversed()) + burtonArc(0.55, 0.5, 0.48, 0.5, -50, -310, 14)],
    "L": [[(0.2, 0), (0.2, 1), (0.94, 1), (1.0, 0.9), (0.93, 0.82), (0.86, 0.9)]],
    "A": [[(0, 1), (0.5, 0), (1, 1)], [(0.22, 0.62), (0.8, 0.6)]],
    "W": [[(0.06, 0.04), (0.24, 1), (0.5, 0.34), (0.76, 1), (0.96, 0.04)]],
    "D": [[(0.18, 0), (0.18, 1)], burtonArc(0.18, 0.5, 0.74, 0.5, -90, 90, 12)],
    "B": [[(0.15, 0), (0.15, 1)], burtonArc(0.15, 0.25, 0.64, 0.25, -90, 90, 8), burtonArc(0.15, 0.74, 0.8, 0.26, -90, 90, 8)],
    "U": [[(0.12, 0), (0.12, 0.62)] + burtonArc(0.5, 0.62, 0.38, 0.38, 180, 0, 10) + [(0.88, 0)]],
    "R": [[(0.15, 1), (0.15, 0)] + burtonArc(0.15, 0.27, 0.7, 0.27, -90, 90, 8), [(0.4, 0.54), (0.95, 1)]],
    "T": [[(0, 0.05), (1, 0)], [(0.53, 0), (0.47, 1)]],
    "N": [[(0.12, 1), (0.12, 0), (0.88, 1), (0.88, 0.04), (0.96, -0.06), (1.04, 0.0), (0.98, 0.07)]],
]

/// The Clawd Burton title, at pixel-art size: CLAWD over BURTON in tall, thin, wobbly bone-white strokes with an
/// ink-black edge and a moonlit violet glow, BURTON's O a full moon, its underline curling off the left end into a spiral.
let burtonTitleArt: CGImage? = {
    let c = PixelCanvas(232, 64)
    var strokes: [[(x: Double, y: Double)]] = []
    func word(_ w: String, x0: Double, y0: Double, h: Double, wide: Double, gap: Double, seed: Int) -> Double {
        var x = x0
        for (i, ch) in w.enumerated() {
            if ch == "O" { x += h + gap; continue }
            let wide = ch == "W" ? wide * 1.45 : wide
            for line in burtonGlyphs[ch] ?? [] {
                strokes.append(line.enumerated().map { k, p in
                    let wob = (noise(seed + i * 31 + k * 7) - 0.5) * 0.8
                    return (x + p.0 * wide + (1 - p.1) * h * 0.1 + wob, y0 + p.1 * h + (noise(seed + i * 31 + k * 7 + 3) - 0.5) * 0.6)
                })
            }
            x += wide + gap
        }
        return x - gap
    }
    _ = word("CLAWD", x0: 84, y0: 4, h: 12, wide: 9, gap: 3, seed: 900)
    let burtonStart = 56.0, burtonEnd = word("BURTON", x0: burtonStart, y0: 22, h: 24, wide: 14, gap: 4, seed: 940)
    // The underline, right to left, curling off into a spiral.
    var under: [(x: Double, y: Double)] = [(burtonEnd + 2, 51), (burtonStart + 8, 51.5)]
    for k in 0...26 {
        let f = Double(k) / 26, a = (90 + f * 600) * .pi / 180, r = 6 * (1 - f * 0.8)
        under.append((burtonStart - 2 + cos(a) * r, 45.5 + sin(a) * r))
    }
    strokes.append(under)
    let violet = C(0x6B5BD6), ink = C(0x16161B), bone = C(0xF2EEE3)
    for pass in 0..<3 {
        for s in strokes {
            for i in 1..<s.count {
                let a = s[i - 1], b = s[i]
                switch pass {
                case 0: c.glowLine(a.x, a.y, b.x, b.y, core: violet.alpha(0.35), glow: violet.alpha(0.3), coreR: 1.6, glowR: 3.8)
                case 1: c.glowLine(a.x, a.y, b.x, b.y, core: ink, glow: C(0, 0), coreR: 1.3, glowR: 1.35)
                default: c.glowLine(a.x, a.y, b.x, b.y, core: bone, glow: C(0, 0), coreR: 0.6, glowR: 0.65)
                }
            }
        }
    }
    // BURTON's O: a full moon with an ink edge, a violet halo, craters, a fleck of pumpkin orange in its shading.
    let mx = Int(burtonStart + 4 * 18 + 12), my = 34
    c.circle(mx, my, 16, violet.alpha(0.18)); c.circle(mx, my, 14, violet.alpha(0.22))
    c.circle(mx, my, 12, ink); c.circle(mx, my, 11, C(0xF2EEE3)); c.circle(mx + 2, my + 2, 8, C(0xE4DCC8))
    c.circle(mx - 4, my - 3, 2, C(0xD0C8B4)); c.circle(mx + 4, my + 4, 3, C(0xD8CCB0)); c.circle(mx + 5, my - 5, 1, C(0xD0C8B4))
    c.rect(mx + 6, my + 7, 2, 1, C(0xF0A030)); c.px(mx + 8, my + 6, C(0xF0A030))
    return c.makeImage()
}()

/// The title lockup: the pixel art blown up 6×`scale`, centred on `center`, and a small "universe" in a thin spidery
/// hand tucked under the right end of BURTON. `alpha` fades it.
func burtonTitle(_ ctx: CGContext, center: CGPoint, scale s: Double, alpha: Double = 1) {
    guard s > 0.01, alpha > 0.01, let art = burtonTitleArt else { return }
    let w = Double(art.width) * 6 * s, h = Double(art.height) * 6 * s
    let r = CGRect(x: center.x - w / 2, y: center.y - h / 2, width: w, height: h)
    // a dark violet glow behind it, so it reads over a busy scene
    ctx.saveGState(); ctx.setAlpha(CGFloat(alpha))
    ctx.setShadow(offset: .zero, blur: 90 * s, color: CGColor(red: 0.04, green: 0.024, blue: 0.08, alpha: 0.95))
    ctx.setFillColor(CGColor(red: 0.078, green: 0.047, blue: 0.14, alpha: 0.6)); ctx.fillEllipse(in: r.insetBy(dx: w * 0.08, dy: h * 0.12))
    ctx.restoreGState()
    ctx.saveGState(); ctx.setAlpha(CGFloat(alpha)); ctx.interpolationQuality = .none
    ctx.draw(art, in: r)
    ctx.restoreGState()
    let font = NSFont(name: "SnellRoundhand-Bold", size: 60 * s) ?? .systemFont(ofSize: 50 * s, weight: .semibold)
    let shadow = NSShadow(); shadow.shadowColor = NSColor(srgbRed: 0.42, green: 0.36, blue: 0.84, alpha: alpha)
    shadow.shadowBlurRadius = 14 * s
    let u = NSAttributedString(string: "universe", attributes: [.font: font, .shadow: shadow,
                               .foregroundColor: NSColor(srgbRed: 0.95, green: 0.93, blue: 0.89, alpha: alpha)])
    let ux: Double = r.minX + 900 * s, uy: Double = r.maxY - 384 * s - Double(u.size().height) * 0.55
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
    u.draw(at: NSPoint(x: ux, y: uy))
    NSGraphicsContext.restoreGraphicsState()
}
