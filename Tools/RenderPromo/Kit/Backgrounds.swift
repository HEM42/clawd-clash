import AppKit

// What the shots stand on: the desktop, space, the app's places at frame size, halftone and bursts.
// Part of RenderPromo's kit: declarations only. main.swift picks the reel and runs it; its header has the build
// command.

// MARK: Backgrounds

/// The user's desktop: a dusky wallpaper with three terminal windows (dimmed once the battle starts).
func desktop(_ ctx: CGContext, dim: Double, floor: Bool = true) {
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                       colors: [CGColor(red: 0.20, green: 0.21, blue: 0.29, alpha: 1),
                                CGColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: 0), options: [])
    // menu bar
    ctx.setFillColor(CGColor(gray: 0, alpha: 0.35)); ctx.fill(CGRect(x: 0, y: H - 34, width: W, height: 34))
    let lines = [["claude ▸ refactor the hook installer", "● Reading HookInstaller.swift", "● Editing 3 files…", "✻ Thinking…"],
                 ["codex ▸ write the changelog", "● Bash(git log --oneline)", "", "Allow this command?  ❯ Yes   No"],
                 [geminiTask, "✓ Done in 4m 12s", "", "> _"]]
    for i in 0..<3 {
        let r = CGRect(x: 110 + Double(i) * 580, y: 330 + Double(i % 2) * 70, width: 540, height: 360)
        ctx.saveGState(); ctx.setAlpha(CGFloat(1 - dim * 0.75))
        ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 30, color: CGColor(gray: 0, alpha: 0.5))
        ctx.addPath(CGPath(roundedRect: r, cornerWidth: 14, cornerHeight: 14, transform: nil))
        ctx.setFillColor(CGColor(red: 0.09, green: 0.09, blue: 0.11, alpha: 1)); ctx.fillPath()
        ctx.setShadow(offset: .zero, blur: 0)
        trafficLights(ctx, x: r.minX + 18, y: r.maxY - 30)
        for (j, l) in lines[i].enumerated() {
            let col: NSColor = j > 0 ? NSColor(white: 0.8, alpha: 1) : (i == 0 ? NSColor(cgColor: claudeOrange)! : [AI.codex, .gemini][i - 1].ns)
            NSAttributedString(string: l, attributes: [.font: NSFont.monospacedSystemFont(ofSize: 21, weight: .medium),
                                                       .foregroundColor: col])
                .draw(at: NSPoint(x: r.minX + 24, y: r.maxY - 90 - Double(j) * 44))
        }
        ctx.restoreGState()
    }
    // the dark floor band the battle stands on
    if floor {
        ctx.setFillColor(CGColor(red: 0.10, green: 0.10, blue: 0.14, alpha: dim * 0.55))
        ctx.fill(CGRect(x: 0, y: 0, width: W, height: Int(Double(H) - groundY * S + 6)))
    }
}

func trafficLights(_ ctx: CGContext, x: Double, y: Double, d: Double = 14) {
    for (j, col) in [CGColor(red: 1, green: 0.37, blue: 0.34, alpha: 1), CGColor(red: 1, green: 0.74, blue: 0.18, alpha: 1),
                     CGColor(red: 0.16, green: 0.79, blue: 0.25, alpha: 1)].enumerated() {
        ctx.setFillColor(col); ctx.fillEllipse(in: CGRect(x: x + Double(j) * d * 1.7, y: y, width: d, height: d))
    }
}

func space(_ ctx: CGContext, t: Double) {
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                       colors: [CGColor(red: 0.16, green: 0.10, blue: 0.30, alpha: 1),
                                CGColor(red: 0.03, green: 0.04, blue: 0.10, alpha: 1)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: 0), options: [])
    for i in 0..<220 {
        let big = noise(i * 3 + 2) > 0.85
        let tw = 0.6 + 0.4 * sin(t * 3 + Double(i))
        ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: (big ? 0.9 : 0.45) * tw))
        let s = big ? 6.0 : 3.0
        let x = (noise(i * 3) * Double(W) - t * (big ? 40 : 20)).truncatingRemainder(dividingBy: Double(W))
        ctx.fill(CGRect(x: x < 0 ? x + Double(W) : x, y: 250 + noise(i * 3 + 1) * Double(H - 250), width: s, height: s))
    }
    ctx.setFillColor(CGColor(red: 0.10, green: 0.10, blue: 0.16, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: 240))
    ctx.setFillColor(claudeOrange); ctx.fill(CGRect(x: 0, y: 236, width: W, height: 6))
}

let appIcon: CGImage? = NSImage(contentsOfFile: "Resources/AppIcon.png")?.cgImage(forProposedRect: nil, context: nil, hints: nil)

// MARK: Pixel places and helpers

let fxW = W / 6, fxH = H / 6

/// A pixel canvas onto the screen, crisp, `scale` screen pixels a pixel, `dy` lifting it.
func blit(_ c: PixelCanvas, _ ctx: CGContext, scale: Double = 6, dx: Double = 0, dy: Double = 0) {
    guard let img = c.makeImage() else { return }
    ctx.saveGState(); ctx.interpolationQuality = .none
    ctx.draw(img, in: CGRect(x: dx, y: Double(H) - Double(c.h) * scale - dy, width: Double(c.w) * scale, height: Double(c.h) * scale))
    ctx.restoreGState()
}

/// One of the app's places at frame size, still art plus what moves (`frozen` stops the moving layer at that time).
func place(_ l: Location, floorRows: Int, t: Double, w: Int = fxW, h: Int = fxH) -> PixelCanvas {
    let c = PixelCanvas(w, h)
    l.drawStatic(c, floorRows: floorRows)
    l.drawAnimated(c, floorRows: floorRows, t: t)
    return c
}

/// A take's backdrop: a place at frame size, its floor where the cast stands.
func set(_ ctx: CGContext, _ l: Location, t: Double, frozen: Double? = nil) {
    blit(place(l, floorRows: Int(Double(fxH) - stageGroundRow + 4), t: frozen ?? t), ctx)
}

/// The floor row a take's cast stands on, at frame size.
let stageGroundRow = 150.0

/// A picture drawn at the frame's pixel-art size (`fxW`×`fxH`, y up), to be blown up 6× without smoothing.
func lowRes(_ draw: (CGContext) -> Void) -> CGImage? {
    guard let g = CGContext(data: nil, width: fxW, height: fxH, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
    g.setShouldAntialias(false)
    draw(g)
    return g.makeImage()
}

/// Renders `draw` into its own full-frame image (for transitions played inside a shot).
func shotImage(_ draw: (CGContext) -> Void) -> CGImage? {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let saved = NSGraphicsContext.current
    let gc = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = gc
    gc.cgContext.interpolationQuality = .none
    draw(gc.cgContext)
    NSGraphicsContext.current = saved
    return rep.cgImage
}

/// A comic-panel backdrop: flat colour under halftone dots.
func halftone(_ ctx: CGContext, _ r: CGRect, base: CGColor, dot: CGColor, step: Double = 18) {
    ctx.setFillColor(base); ctx.fill(r)
    ctx.setFillColor(dot)
    var y = r.minY, row = 0
    while y < r.maxY {
        var x = r.minX + (row % 2 == 0 ? 0 : step / 2)
        while x < r.maxX {
            let d = step * 0.42 * (0.4 + 0.6 * (y - r.minY) / r.height)
            ctx.fillEllipse(in: CGRect(x: x - d / 2, y: y - d / 2, width: d, height: d))
            x += step
        }
        y += step * 0.87; row += 1
    }
}

/// A burst behind the title: a jagged star.
func starburst(_ ctx: CGContext, center c: CGPoint, inner: Double, outer: Double, spikes: Int, color: CGColor, spin: Double) {
    let path = CGMutablePath()
    for i in 0..<(spikes * 2) {
        let a = Double(i) / Double(spikes * 2) * 2 * .pi + spin
        let r = i % 2 == 0 ? outer * (0.85 + 0.15 * noise(i)) : inner
        let p = CGPoint(x: c.x + cos(a) * r, y: c.y + sin(a) * r)
        i == 0 ? path.move(to: p) : path.addLine(to: p)
    }
    path.closeSubpath()
    ctx.addPath(path); ctx.setFillColor(color); ctx.fillPath()
    ctx.addPath(path); ctx.setStrokeColor(CGColor(gray: 0, alpha: 1)); ctx.setLineWidth(8); ctx.strokePath()
}
