import AppKit
import AVFoundation

// The transitions between places, rendered as short clips and a sheet of key frames (Star Clawds' plain wipes, or a
// universe's own trips): Marvel's (`ComicWipe`)
// or, between two DC places, DC's (`DCComicWipe`), or between two Doctor Clawd places, its trips (`DoctorWipe`), or
// between two Clawd Files places, its own (`FilesWipe`), each clip ending on the typed caption, or between two Stevie
// Clawdberg places, its film moments (`ClawdbergWipe`), or, to a Clawd of the Rings place, its nine trips (`RingsWipe`):
// the Eye, the map journey, the Red Book, the Great Eagles, the Ring, the beacons, the Mirror, the fireworks and the palantír.
//   Tools/Transitions/build.sh && build/transitions <out folder> [from place] [to place]
//   build/transitions build/transitions-dc watchtower gotham     DC's fifteen
//   build/transitions build/transitions-doctor consoleRoom skarro   Doctor Clawd's ten
//   build/transitions build/transitions-files xFilesOffice area51    The Clawd Files' ten
//   build/transitions build/transitions-clawdberg hillValley1955 moonHill   Stevie Clawdberg's ten
//   W=1280 H=720 SHOWCASE=build/clawdberg-transitions.mp4 build/transitions   all ten back to back, one video
//   build/transitions build/transitions-rings bagEnd mountDoom   all nine of its trips
//   build/transitions build/transitions-slayer slayerLibrary slayerHellmouth   Clawd Slayer's thirteen

let args = Array(CommandLine.arguments.dropFirst())
let outDir = args.first ?? "build/transitions"
let from = Location(rawValue: args.count > 1 ? args[1] : "avengersTower") ?? .avengersTower
let to = Location(rawValue: args.count > 2 ? args[2] : "wakanda") ?? .wakanda
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

// Output size and screen pixels per art pixel; W=960 H=224 renders at about the window's scene strip.
let env = ProcessInfo.processInfo.environment
let W = Int(env["W"] ?? "") ?? 1280, H = Int(env["H"] ?? "") ?? 800, P = 4
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

// The baseline (Tools/Baseline) needs the same pictures every run: the cantina's band is otherwise picked at random.
if ProcessInfo.processInfo.environment["BASELINE"] != nil { starClawdsBandForced = false }
let full = CGRect(x: 0, y: 0, width: W, height: H)

struct Transition {
    let key: String, title: String, duration: Double
    let draw: (CGContext, CGImage, CGImage, Double) -> Void     // ctx, old, new, k 0…1
}

/// The place's typed caption (`UniverseModule.placeCaption`: The Clawd Files'), in top left `t` seconds after the trip.
func caption(_ ctx: CGContext, _ cap: PlaceCaption, t: Double) {
    let lines = cap.typed(to, t)
    let gc = NSGraphicsContext(cgContext: ctx, flipped: false)
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = gc
    var y = CGFloat(H) - 40
    for (i, line) in lines.enumerated() {
        let str = NSAttributedString(string: line, attributes: [.font: cap.font(i == 0 ? 26 : 17),
                                                                 .foregroundColor: NSColor(white: 0.92, alpha: 1)])
        y -= str.size().height
        str.draw(at: NSPoint(x: 40, y: y))
        y -= 4
    }
    NSGraphicsContext.restoreGraphicsState()
}


/// ONLY="1,4,12" renders just those (by number or name).
let only = ProcessInfo.processInfo.environment["ONLY"]?.split(separator: ",").map(String.init)
/// Every one of the destination's universe's trips; for a universe without any (Star Clawds), every plain wipe it
/// changes places with, as the window and the screen saver draw them (`Wipe`).
let forPlace: [Transition] = to.universe.module.transitions.map { set in
    set.every(from, to).map { shown in
        Transition(key: shown.key, title: shown.title, duration: shown.trip.duration) { ctx, old, new, k in
            shown.trip.draw(ctx, old: old, new: new, k: k, in: full)
        }
    }
} ?? Wipe.Kind.allCases.enumerated().map { i, kind in
    Transition(key: "\(i + 1)-\(kind)", title: "\(kind)", duration: Wipe.duration) { ctx, old, new, k in
        ctx.draw(new, in: full)
        Wipe.drawOld(old, k, kind, in: ctx, full)
    }
}
let transitions: [Transition] = forPlace.filter { tr in
    only.map { $0.contains { tr.key.hasPrefix("\($0)-") || tr.key.hasSuffix("-\($0)") } } ?? true
}

// MARK: Rendering

func frameContext() -> CGContext {
    CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
              bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)!
}

/// An H.264 file written a frame at a time.
final class Movie {
    let url: URL, writer: AVAssetWriter, input: AVAssetWriterInput, adaptor: AVAssetWriterInputPixelBufferAdaptor
    var frames = 0

    init(_ path: String) {
        url = URL(fileURLWithPath: path)
        try? FileManager.default.removeItem(at: url)
        writer = try! AVAssetWriter(outputURL: url, fileType: .mp4)
        input = AVAssetWriterInput(mediaType: .video, outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: W, AVVideoHeightKey: H,
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 6_000_000]])
        adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA, kCVPixelBufferWidthKey as String: W,
            kCVPixelBufferHeightKey as String: H])
        writer.add(input); writer.startWriting(); writer.startSession(atSourceTime: .zero)
    }

    func append(_ img: CGImage) {
        var pb: CVPixelBuffer?
        CVPixelBufferCreate(nil, W, H, kCVPixelFormatType_32BGRA, nil, &pb)
        CVPixelBufferLockBaseAddress(pb!, [])
        let pctx = CGContext(data: CVPixelBufferGetBaseAddress(pb!), width: W, height: H, bitsPerComponent: 8,
                             bytesPerRow: CVPixelBufferGetBytesPerRow(pb!), space: CGColorSpaceCreateDeviceRGB(),
                             bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)!
        pctx.draw(img, in: full)
        CVPixelBufferUnlockBaseAddress(pb!, [])
        while !input.isReadyForMoreMediaData { usleep(1000) }
        adaptor.append(pb!, withPresentationTime: CMTime(value: CMTimeValue(frames), timescale: CMTimeScale(fps)))
        frames += 1
    }

    func finish() {
        input.markAsFinished()
        let done = DispatchSemaphore(value: 0)
        writer.finishWriting { done.signal() }
        done.wait()
        print("wrote \(url.path)")
    }
}

/// A clip: the old place for 0.6 s, the transition, the new place for 0.8 s (2.6 s, typing its caption, in The Clawd
/// Files).
func clip(_ tr: Transition) {
    let movie = Movie("\(outDir)/\(tr.key).mp4")
    let placeCaption = to.universe.module.placeCaption
    let lead = 0.6, tail = placeCaption == nil ? 0.8 : 2.6
    let total = lead + tr.duration + tail
    let frames = Int(total * fps)
    for f in 0..<frames {
        let t = Double(f) / fps
        let ctx = frameContext()
        ctx.interpolationQuality = .none
        let old = placeImage(from, t: t), new = placeImage(to, t: t)
        if t < lead { ctx.draw(old, in: full) }
        else if t > lead + tr.duration {
            ctx.draw(new, in: full)
            if let cap = placeCaption { caption(ctx, cap, t: t - lead - tr.duration) }
        }
        else { tr.draw(ctx, old, new, (t - lead) / tr.duration) }
        movie.append(ctx.makeImage()!)
    }
    movie.finish()
}

// MARK: Stevie Clawdberg's showcase

/// The trailer's title: STEVIE over CLAWDBERG in warm gold with a blue glow, and a small "universe" tucked under the
/// right end of CLAWDBERG.
func clawdbergTitle(_ ctx: CGContext, center: CGPoint, scale s: Double, alpha: Double = 1) {
    let font = NSFont(name: "AvenirNextCondensed-Heavy", size: 100) ?? .systemFont(ofSize: 100, weight: .black)
    let gold = NSColor(srgbRed: 1.0, green: 0.86, blue: 0.48, alpha: CGFloat(alpha))
    ctx.saveGState()
    ctx.translateBy(x: center.x, y: center.y); ctx.scaleBy(x: s, y: s)
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
    var right = 0.0
    for (word, size, y, kern) in [("STEVIE", 74.0, 70.0, 26.0), ("CLAWDBERG", 200.0, -120.0, 10.0)] {
        let f = NSFont(descriptor: font.fontDescriptor, size: CGFloat(size)) ?? font
        let glow = NSShadow(); glow.shadowColor = NSColor(srgbRed: 0.35, green: 0.62, blue: 1.0, alpha: 0.9 * CGFloat(alpha))
        glow.shadowBlurRadius = 36
        let a = NSAttributedString(string: word, attributes: [.font: f, .kern: kern, .foregroundColor: gold, .shadow: glow])
        a.draw(at: NSPoint(x: -a.size().width / 2, y: y))
        right = a.size().width / 2 - kern
    }
    let small = NSFont(name: "AvenirNext-DemiBold", size: 40) ?? .systemFont(ofSize: 40, weight: .semibold)
    let glow = NSShadow(); glow.shadowColor = NSColor(srgbRed: 0.35, green: 0.62, blue: 1.0, alpha: 0.7 * CGFloat(alpha))
    glow.shadowBlurRadius = 14
    let u = NSAttributedString(string: "universe", attributes: [.font: small, .kern: 6, .foregroundColor: gold, .shadow: glow])
    u.draw(at: NSPoint(x: right - (u.size().width - 6), y: -106))
    NSGraphicsContext.restoreGraphicsState()
    ctx.restoreGState()
}

extension ClawdbergWipe {
    /// Its name in the showcase.
    var showcaseName: String {
        switch self {
        case .moonBike: return "The moon bike"
        case .eightyEight: return "88 mph"
        case .mapRoute: return "The map route"
        case .fin: return "The fin"
        case .flashbulb: return "The flashbulb"
        case .parkGates: return "The park gates"
        case .fiveTones: return "The five tones"
        case .boulder: return "The boulder"
        case .pixieDust: return "Pixie dust"
        case .doubloon: return "The doubloon"
        }
    }
}

/// The transition's number and name, and where it goes from and to, small in the bottom left.
func showcaseLabel(_ ctx: CGContext, n: Int, of total: Int, name: String, route: String, alpha: Double) {
    guard alpha > 0.01 else { return }
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
    let shadow = NSShadow(); shadow.shadowColor = NSColor.black.withAlphaComponent(0.8); shadow.shadowBlurRadius = 6
    let a = NSAttributedString(string: "\(n)/\(total)  \(name)", attributes: [
        .font: NSFont.systemFont(ofSize: CGFloat(H) * 0.04, weight: .heavy), .shadow: shadow,
        .foregroundColor: NSColor(srgbRed: 1.0, green: 0.86, blue: 0.48, alpha: CGFloat(alpha))])
    let b = NSAttributedString(string: route, attributes: [
        .font: NSFont.systemFont(ofSize: CGFloat(H) * 0.024, weight: .semibold), .shadow: shadow,
        .foregroundColor: NSColor(white: 0.92, alpha: CGFloat(alpha))])
    let x = CGFloat(H) * 0.04
    b.draw(at: NSPoint(x: x, y: x))
    a.draw(at: NSPoint(x: x, y: x + b.size().height + 2))
    NSGraphicsContext.restoreGraphicsState()
}

/// All ten of Stevie Clawdberg's trips back to back, each between two different places (mostly its own turf), its
/// number and name in the corner, after a title card.
func clawdbergShowcase(_ path: String) {
    let movie = Movie(path)
    // The title card.
    for f in 0..<Int(2.6 * fps) {
        let t = Double(f) / fps
        let ctx = frameContext()
        ctx.setFillColor(CGColor(red: 0.03, green: 0.04, blue: 0.10, alpha: 1)); ctx.fill(full)
        let a = min(1, t / 0.5) * min(1, (2.6 - t) / 0.4)
        clawdbergTitle(ctx, center: CGPoint(x: Double(W) / 2, y: Double(H) * 0.56), scale: Double(W) / 1920 * 0.85, alpha: a)
        NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
        let s = NSAttributedString(string: "Ten trips between places", attributes: [
            .font: NSFont.systemFont(ofSize: CGFloat(H) * 0.04, weight: .semibold),
            .foregroundColor: NSColor(white: 0.9, alpha: CGFloat(a))])
        s.draw(at: NSPoint(x: (CGFloat(W) - s.size().width) / 2, y: CGFloat(H) * 0.22))
        NSGraphicsContext.restoreGraphicsState()
        movie.append(ctx.makeImage()!)
    }
    var here: Location = .hillValley1955
    let kinds = ClawdbergWipe.allCases
    for (i, kind) in kinds.enumerated() {
        let there = kind.turf.first { $0 != here } ?? (here == .hillValley1955 ? .moonHill : .hillValley1955)
        let trip = ClawdbergTrip(kind: kind, from: here, to: there)
        let lead = 0.7, tail = 1.0, d = kind.duration
        let route = "\(here.name)  →  \(there.name)"
        for f in 0..<Int((lead + d + tail) * fps) {
            let t = Double(f) / fps
            let ctx = frameContext(); ctx.interpolationQuality = .none
            if t < lead { ctx.draw(placeImage(here, t: t), in: full) }
            else if t > lead + d { ctx.draw(placeImage(there, t: t), in: full) }
            else { trip.draw(ctx, old: placeImage(here, t: lead), new: placeImage(there, t: t), k: (t - lead) / d, in: full) }
            let a = min(1, t / 0.3) * min(1, (lead + d + tail - t) / 0.3)
            showcaseLabel(ctx, n: i + 1, of: kinds.count, name: kind.showcaseName, route: route, alpha: a)
            movie.append(ctx.makeImage()!)
        }
        here = there
    }
    movie.finish()
}

/// One sheet: a row per transition, five moments through it.
func sheet() {
    let moments = [0.15, 0.35, 0.5, 0.65, 0.85]
    let cw = 320, chh = 320 * H / W, label = 34
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

/// FRAMES="key:0.3,0.6" writes just those moments of one transition, full size, as PNGs.
if let spec = ProcessInfo.processInfo.environment["FRAMES"], let colon = spec.firstIndex(of: ":"),
   let tr = transitions.first(where: { $0.key == String(spec[..<colon]) }) {
    let old = placeImage(from, t: 1), new = placeImage(to, t: 1)
    for part in spec[spec.index(after: colon)...].split(separator: ",") { guard let k = Double(part) else { continue }
        let f = frameContext(); f.interpolationQuality = .none
        tr.draw(f, old, new, k)
        try! NSBitmapImageRep(cgImage: f.makeImage()!).representation(using: .png, properties: [:])!
            .write(to: URL(fileURLWithPath: "\(outDir)/\(tr.key)-\(part).png"))
    }
    exit(0)
}
/// SHOWCASE=<file.mp4> writes Stevie Clawdberg's ten trips back to back into one video, and nothing else.
if let path = ProcessInfo.processInfo.environment["SHOWCASE"] {
    clawdbergShowcase(path)
    exit(0)
}
sheet()
if ProcessInfo.processInfo.environment["SHEET_ONLY"] == nil { for tr in transitions { clip(tr) } }
