import AppKit
import AVFoundation

// Comic-book transition candidates for the Marvel universe, rendered as short clips and a sheet of key frames so
// they can be compared before one goes into the app.
//   Tools/Transitions/build.sh && build/transitions <out folder> [from place] [to place]

let args = Array(CommandLine.arguments.dropFirst())
let outDir = args.first ?? "build/transitions"
let from = Location(rawValue: args.count > 1 ? args[1] : "avengersTower") ?? .avengersTower
let to = Location(rawValue: args.count > 2 ? args[2] : "wakanda") ?? .wakanda
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

let W = 1280, H = 800, P = 4                          // output size, screen pixels per art pixel
let fps = 30.0

/// A place as the screen saver shows it: the still picture plus its moving layer, scaled up crisp.
func placeImage(_ l: Location, t: Double) -> CGImage {
    let cw = W / P, ch = H / P, floor = max(8, ch / 8)
    let still = PixelCanvas(cw, ch); l.drawStatic(still, floorRows: floor)
    let moving = PixelCanvas(cw, ch); l.drawAnimated(moving, floorRows: floor, t: t)
    let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
                        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)!
    ctx.interpolationQuality = .none
    for img in [still.makeImage(), moving.makeImage()].compactMap({ $0 }) { ctx.draw(img, in: CGRect(x: 0, y: 0, width: W, height: H)) }
    return ctx.makeImage()!
}

let full = CGRect(x: 0, y: 0, width: W, height: H)
let inkCG = CGColor(red: 0.07, green: 0.06, blue: 0.08, alpha: 1)
let yellowCG = CGColor(red: 1, green: 0.86, blue: 0.16, alpha: 1)
let redCG = CGColor(red: 0.86, green: 0.12, blue: 0.14, alpha: 1)

func ease(_ k: Double) -> Double { k * k * (3 - 2 * k) }
func clamp(_ k: Double) -> Double { min(1, max(0, k)) }

/// Comic lettering, centred at `c`, tilted by `angle` radians, with a thick black outline.
func letters(_ ctx: CGContext, _ text: String, at c: CGPoint, size: CGFloat, angle: CGFloat = 0, fill: NSColor = .white) {
    let font = NSFont(name: "Futura-CondensedExtraBold", size: size) ?? .systemFont(ofSize: size, weight: .black)
    let outline = NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: NSColor.black,
                                                                .strokeColor: NSColor.black, .strokeWidth: 12])
    let face = NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: fill])
    let sz = face.size()
    ctx.saveGState()
    ctx.translateBy(x: c.x, y: c.y); ctx.rotate(by: angle)
    let gc = NSGraphicsContext(cgContext: ctx, flipped: false)
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = gc
    outline.draw(at: NSPoint(x: -sz.width / 2, y: -sz.height / 2))
    face.draw(at: NSPoint(x: -sz.width / 2, y: -sz.height / 2))
    NSGraphicsContext.restoreGraphicsState()
    ctx.restoreGState()
}

/// A jagged comic starburst path round `c`, radius `r`, with `n` points.
func starburst(_ c: CGPoint, r: CGFloat, n: Int = 18, seed: Int = 0) -> CGPath {
    let p = CGMutablePath()
    for i in 0..<(n * 2) {
        let a = CGFloat(i) / CGFloat(n * 2) * 2 * .pi + 0.1
        let k = i % 2 == 0 ? 1 : 0.62 + 0.12 * CGFloat(noise(i + seed * 31))
        let rr = r * k * (0.9 + 0.2 * CGFloat(noise(i * 7 + seed)))
        let pt = CGPoint(x: c.x + cos(a) * rr, y: c.y + sin(a) * rr)
        i == 0 ? p.move(to: pt) : p.addLine(to: pt)
    }
    p.closeSubpath()
    return p
}

struct Transition {
    let key: String, title: String, duration: Double
    let draw: (CGContext, CGImage, CGImage, Double) -> Void     // ctx, old, new, k 0…1
}

let transitions: [Transition] = [
    // 1. Ben-Day dots: the old page breaks up into printed halftone dots of the new one, small to big.
    Transition(key: "1-halftone", title: "Halftone dots", duration: 1.4) { ctx, old, new, k in
        ctx.draw(old, in: full)
        let cell: CGFloat = 26
        ctx.saveGState()
        let path = CGMutablePath()
        let cols = Int(CGFloat(W) / cell) + 2, rows = Int(CGFloat(H) / cell) + 2
        for row in 0..<rows {
            for col in 0..<cols {
                let x = CGFloat(col) * cell + (row % 2 == 0 ? 0 : cell / 2), y = CGFloat(row) * cell
                // Dots start on the left and sweep right, each growing from nothing to covering its cell.
                let local = clamp(k * 1.6 - Double(x) / Double(W) * 0.6)
                let r = cell * 0.75 * CGFloat(ease(local))
                if r > 0.5 { path.addEllipse(in: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)) }
            }
        }
        ctx.addPath(path); ctx.clip()
        ctx.draw(new, in: full)
        ctx.restoreGState()
    },
    // 2. KRA-KOOM!: a starburst explodes out from the middle with a sound effect, covers the screen, and
    //    bursts away to the new place.
    Transition(key: "2-krakoom", title: "Sound-effect burst", duration: 1.6) { ctx, old, new, k in
        ctx.draw(k < 0.5 ? old : new, in: full)
        let c = CGPoint(x: W / 2, y: H / 2)
        let grow = k < 0.5 ? ease(k / 0.5) : 1 - ease((k - 0.5) / 0.5)
        let r = CGFloat(grow) * CGFloat(W) * 0.95
        guard r > 2 else { return }
        ctx.addPath(starburst(c, r: r * 1.04, seed: 3)); ctx.setFillColor(inkCG); ctx.fillPath()
        ctx.addPath(starburst(c, r: r, seed: 3)); ctx.setFillColor(yellowCG); ctx.fillPath()
        ctx.addPath(starburst(c, r: r * 0.7, seed: 5)); ctx.setFillColor(redCG); ctx.fillPath()
        let words = ["KRA-KOOM!", "THWIP!", "BAMF!", "POW!"]
        letters(ctx, words[0], at: c, size: 40 + 150 * CGFloat(grow), angle: -0.12)
    },
    // 3. Panel slam: the new place drops in as three comic panels with thick gutters, one after another.
    Transition(key: "3-panels", title: "Panels slam in", duration: 1.5) { ctx, old, new, k in
        ctx.draw(old, in: full)
        let gutter: CGFloat = 14
        let w = CGFloat(W) / 3
        for i in 0..<3 {
            let local = clamp((k - Double(i) * 0.18) / 0.46)
            guard local > 0 else { continue }
            let drop = CGFloat(1 - ease(local)) * CGFloat(H) * 1.1 * (i % 2 == 0 ? 1 : -1)
            let tilt: CGFloat = (1 - CGFloat(ease(local))) * (i == 1 ? -0.08 : 0.06)
            ctx.saveGState()
            ctx.translateBy(x: w * CGFloat(i) + w / 2, y: CGFloat(H) / 2 + drop)
            ctx.rotate(by: tilt)
            let r = CGRect(x: -w / 2, y: -CGFloat(H) / 2, width: w, height: CGFloat(H))
            ctx.setFillColor(inkCG); ctx.fill(r)
            ctx.clip(to: r.insetBy(dx: gutter / 2, dy: gutter / 2))
            ctx.draw(new, in: CGRect(x: -w / 2 - w * CGFloat(i), y: -CGFloat(H) / 2, width: CGFloat(W), height: CGFloat(H)))
            ctx.restoreGState()
        }
        // Once all three are down, the gutters close up.
        if k > 0.86 { ctx.setAlpha(CGFloat((k - 0.86) / 0.14)); ctx.draw(new, in: full); ctx.setAlpha(1) }
    },
    // 4. Speed lines: action lines rush in to the centre, everything goes white, and the new place zooms out of it.
    Transition(key: "4-speedlines", title: "Speed-line zoom", duration: 1.3) { ctx, old, new, k in
        let c = CGPoint(x: W / 2, y: H / 2)
        let img = k < 0.5 ? old : new
        let zoom: CGFloat = k < 0.5 ? 1 + CGFloat(ease(k / 0.5)) * 0.35 : 1.35 - CGFloat(ease((k - 0.5) / 0.5)) * 0.35
        ctx.saveGState()
        ctx.translateBy(x: c.x, y: c.y); ctx.scaleBy(x: zoom, y: zoom); ctx.translateBy(x: -c.x, y: -c.y)
        ctx.draw(img, in: full)
        ctx.restoreGState()
        let strength = k < 0.5 ? ease(k / 0.5) : 1 - ease((k - 0.5) / 0.5)
        let inner = CGFloat(W) * 0.62 * CGFloat(1 - strength)
        for i in 0..<90 {
            let a = CGFloat(noise(i * 3)) * 2 * .pi, wdt = 0.012 + 0.02 * CGFloat(noise(i * 3 + 1))
            let p = CGMutablePath()
            p.move(to: CGPoint(x: c.x + cos(a) * 2000, y: c.y + sin(a) * 2000))
            p.addLine(to: CGPoint(x: c.x + cos(a - wdt) * inner, y: c.y + sin(a - wdt) * inner))
            p.addLine(to: CGPoint(x: c.x + cos(a + wdt) * 2000, y: c.y + sin(a + wdt) * 2000))
            p.closeSubpath()
            ctx.addPath(p)
        }
        ctx.setFillColor(CGColor(gray: 0.05, alpha: 0.85)); ctx.fillPath()
        if strength > 0.85 { ctx.setFillColor(CGColor(gray: 1, alpha: CGFloat((strength - 0.85) / 0.15))); ctx.fill(full) }
    },
    // 5. "Meanwhile…": an iris closes to a dot, a yellowCG caption box types "MEANWHILE, IN WAKANDA…", and the iris
    //    opens on the new place.
    Transition(key: "5-meanwhile", title: "Iris and caption", duration: 2.4) { ctx, old, new, k in
        let c = CGPoint(x: W / 2, y: H / 2)
        let maxR = hypot(CGFloat(W), CGFloat(H)) / 2 + 10
        ctx.setFillColor(inkCG); ctx.fill(full)
        let closing = k < 0.32, opening = k > 0.68
        let r: CGFloat = closing ? maxR * CGFloat(1 - ease(k / 0.32)) : opening ? maxR * CGFloat(ease((k - 0.68) / 0.32)) : 0
        if r > 1 {
            ctx.saveGState()
            ctx.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)); ctx.clip()
            ctx.draw(closing ? old : new, in: full)
            ctx.restoreGState()
            ctx.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
            ctx.setStrokeColor(inkCG); ctx.setLineWidth(10); ctx.strokePath()
        }
        if k > 0.22 && k < 0.82 {
            let text = "MEANWHILE, IN \(to.name.uppercased())…"
            let shown = String(text.prefix(Int(Double(text.count) * clamp((k - 0.26) / 0.3))))
            let font = NSFont(name: "AvenirNext-HeavyItalic", size: 38) ?? .boldSystemFont(ofSize: 38)
            let a = NSAttributedString(string: shown, attributes: [.font: font, .foregroundColor: NSColor.black])
            let full = NSAttributedString(string: text, attributes: [.font: font])
            let box = CGRect(x: c.x - full.size().width / 2 - 24, y: c.y - 34, width: full.size().width + 48, height: 68)
            ctx.setFillColor(yellowCG); ctx.fill(box)
            ctx.setStrokeColor(inkCG); ctx.setLineWidth(5); ctx.stroke(box)
            let gc = NSGraphicsContext(cgContext: ctx, flipped: false)
            NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = gc
            a.draw(at: NSPoint(x: box.minX + 24, y: box.minY + 12))
            NSGraphicsContext.restoreGraphicsState()
        }
    },
]

// MARK: Rendering

func frameContext() -> CGContext {
    CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
              bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)!
}

/// A clip: the old place for 0.6 s, the transition, the new place for 0.8 s.
func clip(_ tr: Transition) {
    let url = URL(fileURLWithPath: "\(outDir)/\(tr.key).mp4")
    try? FileManager.default.removeItem(at: url)
    let writer = try! AVAssetWriter(outputURL: url, fileType: .mp4)
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
        AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: W, AVVideoHeightKey: H,
        AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 6_000_000]])
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA, kCVPixelBufferWidthKey as String: W,
        kCVPixelBufferHeightKey as String: H])
    writer.add(input); writer.startWriting(); writer.startSession(atSourceTime: .zero)
    let lead = 0.6, tail = 0.8
    let total = lead + tr.duration + tail
    let frames = Int(total * fps)
    for f in 0..<frames {
        let t = Double(f) / fps
        let ctx = frameContext()
        ctx.interpolationQuality = .none
        let old = placeImage(from, t: t), new = placeImage(to, t: t)
        if t < lead { ctx.draw(old, in: full) }
        else if t > lead + tr.duration { ctx.draw(new, in: full) }
        else { tr.draw(ctx, old, new, (t - lead) / tr.duration) }
        let img = ctx.makeImage()!
        var pb: CVPixelBuffer?
        CVPixelBufferCreate(nil, W, H, kCVPixelFormatType_32BGRA, nil, &pb)
        CVPixelBufferLockBaseAddress(pb!, [])
        let pctx = CGContext(data: CVPixelBufferGetBaseAddress(pb!), width: W, height: H, bitsPerComponent: 8,
                             bytesPerRow: CVPixelBufferGetBytesPerRow(pb!), space: CGColorSpaceCreateDeviceRGB(),
                             bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)!
        pctx.draw(img, in: full)
        CVPixelBufferUnlockBaseAddress(pb!, [])
        while !input.isReadyForMoreMediaData { usleep(1000) }
        adaptor.append(pb!, withPresentationTime: CMTime(value: CMTimeValue(f), timescale: CMTimeScale(fps)))
    }
    input.markAsFinished()
    let done = DispatchSemaphore(value: 0)
    writer.finishWriting { done.signal() }
    done.wait()
    print("wrote \(url.path)")
}

/// One sheet: a row per transition, five moments through it.
func sheet() {
    let moments = [0.15, 0.35, 0.5, 0.65, 0.85]
    let cw = 320, chh = 200, label = 34
    let ctx = CGContext(data: nil, width: cw * moments.count, height: (chh + label) * transitions.count,
                        bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
                        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)!
    ctx.setFillColor(CGColor(red: 0.12, green: 0.12, blue: 0.16, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: ctx.width, height: ctx.height))
    let old = placeImage(from, t: 1), new = placeImage(to, t: 1)
    for (row, tr) in transitions.enumerated() {
        let y = ctx.height - (row + 1) * (chh + label)
        let gc = NSGraphicsContext(cgContext: ctx, flipped: false)
        NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = gc
        NSAttributedString(string: "\(row + 1). \(tr.title)", attributes: [.font: NSFont.systemFont(ofSize: 18, weight: .bold),
                                                                         .foregroundColor: NSColor.white])
            .draw(at: NSPoint(x: 8, y: y + chh + 6))
        NSGraphicsContext.restoreGraphicsState()
        for (i, k) in moments.enumerated() {
            let f = frameContext(); f.interpolationQuality = .none
            tr.draw(f, old, new, k)
            ctx.draw(f.makeImage()!, in: CGRect(x: i * cw, y: y, width: cw - 4, height: chh))
        }
    }
    let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(outDir)/transitions.png"))
    print("wrote \(outDir)/transitions.png")
}

sheet()
for tr in transitions { clip(tr) }
