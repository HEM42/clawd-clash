import AppKit

// One frame of the reel on show: the shot, its transition, the overlays and the fades.
// Part of RenderPromo's kit: declarations only. main.swift picks the reel and runs it; its header has the build
// command.

// MARK: Frame

let feather = 220.0

/// Greyscale mask that is white (keep the outgoing shot) to the right of `edge`, ramping softly across `feather`.
func wipeMask(edge: Double) -> CGImage {
    var row = [UInt8](repeating: 0, count: W)
    for x in 0..<W { row[x] = UInt8(clamp((Double(x) - edge) / feather + 0.5) * 255) }
    let provider = CGDataProvider(data: Data(row) as CFData)!
    return CGImage(width: W, height: 1, bitsPerComponent: 8, bitsPerPixel: 8, bytesPerRow: W,
                   space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGBitmapInfo(rawValue: 0),
                   provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)!
}

func renderShot(_ s: Shot, at t: Double, into ctx: CGContext) {
    ctx.saveGState(); s.render(ctx, t - s.start, t); ctx.restoreGState()
}

let fullRect = CGRect(x: 0, y: 0, width: W, height: H)

/// The shot whose incoming transition is running at `t`, and how far through it (0…1).
func transition(at t: Double) -> (index: Int, k: Double)? {
    for j in shots.indices.dropFirst() {
        let d = shots[j].into.duration
        guard d > 0 else { continue }
        let k = (t - shots[j].start + d / 2) / d
        if k > 0 && k < 1 { return (j, k) }
    }
    return nil
}

func frame(_ t: Double) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let gc = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = gc
    let ctx = gc.cgContext
    ctx.interpolationQuality = .none
    if t < 0.5 / fps {                                   // the very first frame is the poster GitHub shows before play
        let s = shots.first { $0.name == poster.shot }!
        renderShot(s, at: s.start + poster.at, into: ctx)
        NSGraphicsContext.current = nil
        return rep
    }
    if let (j, k) = transition(at: t) {
        let cur = shots[j], prev = shots[j - 1]
        switch cur.into {
        case .wipe:
            renderShot(cur, at: t, into: ctx)
            ctx.saveGState()
            ctx.clip(to: fullRect, mask: wipeMask(edge: lerp(-feather / 2, Double(W) + feather / 2, k)))
            ctx.interpolationQuality = .none
            renderShot(prev, at: t, into: ctx)
            ctx.restoreGState()
        case .starWars(let clock):
            let r = cur.inWindow ? windowRect : fullRect
            renderShot(cur, at: t, into: ctx)
            ctx.saveGState()
            if let m = Wipe.mask(k, clock ? .clock : .edgeRight, aspect: Double(r.width / r.height)) { ctx.clip(to: r, mask: m) }
            renderShot(prev, at: t, into: ctx)
            ctx.restoreGState()
        case .marvel, .dc, .middleEarth, .trip:
            let old = shotImage { renderShot(prev, at: t, into: $0) }, new = shotImage { renderShot(cur, at: t, into: $0) }
            let r = cur.inWindow ? windowRect : fullRect
            if cur.inWindow { renderShot(cur, at: t, into: ctx) }
            if var o = old, var n = new {
                if cur.inWindow {                                    // just the window, as the app does it
                    let crop = CGRect(x: r.minX, y: CGFloat(H) - r.maxY, width: r.width, height: r.height)
                    o = o.cropping(to: crop) ?? o; n = n.cropping(to: crop) ?? n
                    ctx.saveGState()
                    ctx.addPath(CGPath(roundedRect: r, cornerWidth: 22, cornerHeight: 22, transform: nil)); ctx.clip()
                }
                if case .marvel(let trip) = cur.into { trip.draw(ctx, old: o, new: n, k: k, in: r) }
                if case .dc(let trip) = cur.into { trip.draw(ctx, old: o, new: n, k: k, in: r) }
                if case .middleEarth(let trip) = cur.into { trip.draw(ctx, old: o, new: n, k: k, in: r) }
                if case .trip(let trip) = cur.into { trip.draw(ctx, old: o, new: n, k: k, in: r) }
                if cur.inWindow { ctx.restoreGState() }
            }
        case .cut:
            renderShot(cur, at: t, into: ctx)
        }
    } else {
        renderShot(shots[shots.lastIndex(where: { t >= $0.start }) ?? 0], at: t, into: ctx)
    }
    for o in overlays where t >= o.start && t < o.end {
        ctx.saveGState(); o.draw(ctx, t - o.start); ctx.restoreGState()
    }
    // fade in from and out to black
    let black = max(1 - t / 0.2, (t - (duration - 0.3)) / 0.3, 0)
    if black > 0 { ctx.setFillColor(CGColor(gray: 0, alpha: black)); ctx.fill(fullRect) }
    NSGraphicsContext.current = nil
    return rep
}

func save(_ rep: NSBitmapImageRep, _ path: String) {
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}
