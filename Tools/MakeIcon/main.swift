import AppKit
import CoreText

// Renders Resources/AppIcon.png (1024²): Captain Americlawd, big, standing on CLAWD CLASH, the name stacked on two
// lines, in front of a white comic burst over a starburst of colour wedges (speed lines in
// each, halftone between them). Drawn with the app's own sprite code. Simple on purpose, so it still reads at the
// 16 and 32 px Finder and the Dock use, and it doesn't need changing when a universe is added. build.sh turns it into
// AppIcon.icns.
//   source Tools/universes.sh && swiftc Sources/App/{Pixel,Characters,Fights,Persona,Theme,Pose,Locations,Cast,Habits,Drills,Icon,Rides}.swift \
//          $UNIVERSE_APP Sources/Shared/*.swift Tools/MakeIcon/main.swift -o build/makeicon \
//          && build/makeicon Resources/AppIcon.png

let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1024, pixelsHigh: 1024, bitsPerSample: 8, samplesPerPixel: 4,
                           hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!.cgContext
ctx.interpolationQuality = .none

func hex(_ h: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(h >> 16 & 0xFF) / 255, green: CGFloat(h >> 8 & 0xFF) / 255, blue: CGFloat(h & 0xFF) / 255, alpha: a)
}
func rnd(_ i: Int) -> CGFloat { CGFloat(noise(i)) }
let inkColor = hex(0x111018)

// macOS icon grid: an 824² rounded square, centred.
let tile = CGRect(x: 100, y: 100, width: 824, height: 824)
let shape = CGPath(roundedRect: tile, cornerWidth: 185, cornerHeight: 185, transform: nil)

/// Halftone dots over `r`, `cell` apart, each `dot(at)` of its cell across.
func halftone(_ r: CGRect, color: CGColor, cell: CGFloat, dot: (CGPoint) -> CGFloat) {
    var y = r.minY, row = 0
    while y < r.maxY + cell {
        var x = r.minX + (row % 2 == 0 ? 0 : cell / 2)
        while x < r.maxX + cell {
            let d = dot(CGPoint(x: x, y: y)) * cell
            if d > 0.5 { ctx.addEllipse(in: CGRect(x: x - d / 2, y: y - d / 2, width: d, height: d)) }
            x += cell
        }
        y += cell; row += 1
    }
    ctx.setFillColor(color); ctx.fillPath()
}

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

/// A word of the name centred on `c`, as big as fits `width`×`height`, tilted by `angle`: a deep block extrusion, a
/// thick ink outline, a yellow face with a shine.
func word(_ s: String, at c: CGPoint, width: CGFloat, height: CGFloat, angle: CGFloat, depth: Int) {
    var path = letters(s)
    let k = min(width / path.boundingBox.width, height / path.boundingBox.height)
    var t = CGAffineTransform(scaleX: k, y: k).concatenating(CGAffineTransform(rotationAngle: angle))
        .concatenating(CGAffineTransform(translationX: c.x, y: c.y))
    path = path.copy(using: &t)!
    let b = path.boundingBox, step = b.height / 80, line = b.height * 0.16
    ctx.saveGState(); ctx.setLineJoin(.round)
    for i in stride(from: depth, through: 1, by: -1) {
        ctx.saveGState(); ctx.translateBy(x: CGFloat(i) * step * 0.6, y: -CGFloat(i) * step)
        ctx.addPath(path); ctx.setStrokeColor(inkColor); ctx.setLineWidth(line); ctx.strokePath()
        ctx.addPath(path); ctx.setFillColor(inkColor); ctx.fillPath()
        ctx.restoreGState()
    }
    ctx.addPath(path); ctx.setStrokeColor(inkColor); ctx.setLineWidth(line); ctx.strokePath()
    ctx.saveGState(); ctx.addPath(path); ctx.clip()
    let face = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [hex(0xFFF3B0), hex(0xFFC21A)] as CFArray, locations: [0.2, 1])!
    ctx.drawLinearGradient(face, start: CGPoint(x: 0, y: b.maxY), end: CGPoint(x: 0, y: b.minY), options: [])
    ctx.setFillColor(hex(0xFFFFFF, 0.3)); ctx.fill(CGRect(x: b.minX, y: b.midY + b.height * 0.1, width: b.width, height: b.height * 0.09))
    ctx.restoreGState(); ctx.restoreGState()
}

ctx.saveGState(); ctx.addPath(shape); ctx.clip()

// The starburst: white, halftone, and five wedges of colour, speed lines running out in each.
let centre = CGPoint(x: 512, y: 640)
let wedges: [(UInt32, UInt32)] = [(0xE8322E, 0xFF7A70), (0x2EA8E8, 0x8AD8FF), (0xFFD62E, 0xFFF08A), (0xA65AE8, 0xD2A8FF), (0x7CC84A, 0xB8EC88)]
ctx.setFillColor(hex(0xFFFFFF)); ctx.fill(tile)
halftone(tile, color: hex(0xB8B8C0), cell: 15) { _ in 0.42 }
for (i, w) in wedges.enumerated() {
    let n = CGFloat(wedges.count), gap: CGFloat = 0.08
    let a0 = .pi / 2 + CGFloat(i) / n * 2 * .pi + gap / 2, a1 = .pi / 2 + CGFloat(i + 1) / n * 2 * .pi - gap / 2
    let wedge = CGMutablePath()
    wedge.move(to: centre)
    wedge.addLine(to: CGPoint(x: centre.x + cos(a0) * 1400, y: centre.y + sin(a0) * 1400))
    wedge.addLine(to: CGPoint(x: centre.x + cos(a1) * 1400, y: centre.y + sin(a1) * 1400))
    wedge.closeSubpath()
    ctx.saveGState(); ctx.addPath(wedge); ctx.clip()
    ctx.setFillColor(hex(w.0)); ctx.fill(tile)
    for k in 0..<40 {
        let a = a0 + (a1 - a0) * rnd(k * 7 + i * 13), r0 = 120 + rnd(k * 7 + 1) * 160
        ctx.move(to: CGPoint(x: centre.x + cos(a) * r0, y: centre.y + sin(a) * r0))
        ctx.addLine(to: CGPoint(x: centre.x + cos(a) * 1400, y: centre.y + sin(a) * 1400))
    }
    ctx.setStrokeColor(hex(w.1, 0.6)); ctx.setLineWidth(5); ctx.strokePath()
    ctx.restoreGState()
    ctx.addPath(wedge); ctx.setStrokeColor(inkColor); ctx.setLineWidth(5); ctx.strokePath()
}

// The white comic burst behind him.
let burst = CGMutablePath(), spikes = 14
for k in 0..<(spikes * 2) {
    let a = CGFloat(k) / CGFloat(spikes * 2) * 2 * .pi, rr: CGFloat = k % 2 == 0 ? 1 : 0.78
    let pt = CGPoint(x: centre.x + cos(a) * 330 * rr * (0.92 + 0.16 * rnd(k)), y: centre.y + sin(a) * 300 * rr * (0.92 + 0.16 * rnd(k + 40)))
    if k == 0 { burst.move(to: pt) } else { burst.addLine(to: pt) }
}
burst.closeSubpath()
ctx.addPath(burst); ctx.setFillColor(hex(0xFFFFFF)); ctx.fillPath()
ctx.addPath(burst); ctx.setStrokeColor(inkColor); ctx.setLineWidth(10); ctx.setLineJoin(.round); ctx.strokePath()

// Captain Americlawd, shield up, standing on the name. Drawn as an agent: a session working alone would be doing its
// solo practice (Drills.swift) instead of posing.
let cap = PixelCanvas(72, 52)
Cast.hero(MarvelousHero.captainAmerica).draw(cap, t: 0.42, mode: .working, walking: false, role: .none, asSession: false)
cap.addOutline(C(0xFFFFFF, 0.95))
let p: CGFloat = 13   // icon pixels a sprite pixel; the body's centre is 28 columns in, the feet 8 rows up
ctx.draw(cap.makeImage()!, in: CGRect(x: 512 - 28 * p, y: 488 - 8 * p, width: 72 * p, height: 52 * p))

// The name, stacked big.
word("CLAWD", at: CGPoint(x: 505, y: 405), width: 760, height: 205, angle: 0.05, depth: 12)
word("CLASH", at: CGPoint(x: 520, y: 210), width: 800, height: 215, angle: 0.05, depth: 12)
ctx.restoreGState()

// A subtle rim.
ctx.addPath(shape); ctx.setStrokeColor(hex(0xFFFFFF, 0.14)); ctx.setLineWidth(4); ctx.strokePath()

NSGraphicsContext.current = nil
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
