import AppKit

// The storyboard sheet: a frame per beat with what happens, what's on screen and what you hear.
// Part of RenderPromo's kit: declarations only. main.swift picks the reel and runs it; its header has the build
// command.

// MARK: Storyboard sheets

typealias Beat = (title: String, action: String, onScreen: String, sound: String)

/// "a, b, c and d".
func listed(_ items: [String]) -> String { items.count < 2 ? items.joined() : items.dropLast().joined(separator: ", ") + " and " + items.last! }

func storyboard(_ title: String, _ beats: [(key: Double, beat: Beat)], shift: Double = 0) -> NSBitmapImageRep {
    let frames = beats.map { frame($0.key + shift) }
    let cols = 2, pw = 900.0, ph = pw * 9 / 16, textH = 270.0, gap = 60.0, margin = 70.0, headH = 200.0
    let rows = (frames.count + cols - 1) / cols
    let sw = Int(margin * 2 + pw * Double(cols) + gap * Double(cols - 1))
    let sh = Int(headH + Double(rows) * (ph + textH) + Double(rows - 1) * gap * 0.5 + margin)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: sw, pixelsHigh: sh, bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let gc = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = gc
    let ctx = gc.cgContext
    ctx.setFillColor(CGColor(red: 0.07, green: 0.075, blue: 0.11, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: sw, height: sh))
    func put(_ s: String, _ x: Double, _ y: Double, _ size: CGFloat, _ weight: NSFont.Weight, _ col: NSColor, width: Double = 0) {
        let a = NSAttributedString(string: s, attributes: [.font: NSFont.systemFont(ofSize: size, weight: weight), .foregroundColor: col])
        if width > 0 { a.draw(with: NSRect(x: x, y: y - 200, width: width, height: 200), options: [.usesLineFragmentOrigin]) }
        else { a.draw(at: NSPoint(x: x, y: y)) }
    }
    let tf = NSFont(name: "Futura-CondensedExtraBold", size: 64) ?? .systemFont(ofSize: 60, weight: .black)
    NSAttributedString(string: title, attributes: [.font: tf, .foregroundColor: yellow, .kern: 5]).draw(at: NSPoint(x: margin, y: Double(sh) - 110))
    put(String(format: "%.0f seconds · storyboard · 1920×1080 · 30 fps · every sprite, place and transition drawn by the app's own code", duration),
        margin, Double(sh) - 150, 26, .medium, NSColor(white: 0.75, alpha: 1))
    let dim = NSColor(white: 0.62, alpha: 1), body = NSColor(white: 0.92, alpha: 1)
    for (i, f) in frames.enumerated() {
        let b = beats[i].beat
        let x = margin + Double(i % cols) * (pw + gap)
        let top = Double(sh) - headH - Double(i / cols) * (ph + textH + gap * 0.5)
        let r = CGRect(x: x, y: top - ph, width: pw, height: ph)
        ctx.saveGState(); ctx.interpolationQuality = .high; ctx.draw(f.cgImage!, in: r); ctx.restoreGState()
        ctx.setStrokeColor(CGColor(gray: 1, alpha: 0.25)); ctx.setLineWidth(2); ctx.stroke(r)
        let ty = top - ph - 44
        put("\(i + 1)  \(b.title)", x, ty, 30, .heavy, yellow)
        put(String(format: "%.1f s", beats[i].key), x + pw - 110, ty + 2, 26, .semibold, dim)
        put(b.action, x, ty - 14, 21, .regular, body, width: pw)
        put("ON SCREEN  " + b.onScreen, x, ty - 110, 20, .semibold, NSColor(srgbRed: 0.75, green: 0.85, blue: 1, alpha: 1), width: pw)
        put("SOUND  " + b.sound, x, ty - 190, 20, .semibold, dim, width: pw)
    }
    NSGraphicsContext.current = nil
    return rep
}
