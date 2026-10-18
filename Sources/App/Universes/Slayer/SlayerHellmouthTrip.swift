import CoreGraphics
import Foundation

// The Hellmouth Opens (`SlayerWipe.hellmouth`): the floor splits, red light pours up, the old place tumbles in, and
// the new place rises out as the crack seals.

extension SlayerTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. The ground shakes and a crack runs out
    /// along the floor from the middle, glowing red (0.02–0.16); cracks climb up the picture from it, splitting the old
    /// place into slabs, and red light starts to pour up (0.1–0.18); the slabs drop away into the Hellmouth one after
    /// another from the middle out, tumbling as they go, over a cavern of red light, shafts of it streaming up and
    /// embers rising (0.18–0.6); the new place rises up out of the glow, lit red from below (0.5–0.84); and the crack
    /// across its floor narrows and seals with a last shudder, its glow dying (0.8–0.97). The places are drawn as they
    /// are; the cavern, the light, the cracks and the falling slabs are pixel art, drawn into bitmaps about 180 pixels
    /// tall and scaled up without smoothing, with a little grain.
    func drawHellmouth(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.draw(old, in: r); return }
        guard k < 1 else { ctx.draw(new, in: r); return }
        let px: CGFloat = max(1, (r.height / 180).rounded())
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let back = Self.artCanvas(width: w, height: h, px: px, in: r),
              let front = Self.artCanvas(width: w, height: h, px: px, in: r) else {
            Self.crossfade(ctx, old: old, new: new, k: k, in: r); return
        }
        for art in [back, front] {                                   // draw in the art's own pixels, from the bottom left
            art.translateBy(x: r.minX, y: r.minY); art.scaleBy(x: px, y: px); art.interpolationQuality = .none
        }
        let W = r.width / px, H = r.height / px
        let crackY = (H * 0.06).rounded()                            // the crack runs along the middle of the floor
        let spread = CGFloat(Self.ease(Self.span(k, 0.02, 0.16)))    // how far along the floor it has run
        let climb = CGFloat(Self.span(k, 0.1, 0.18))                 // how far up the picture the cracks have climbed
        let glow = CGFloat(Self.span(k, 0.06, 0.24) * (1 - Self.span(k, 0.78, 0.92)))
        let rise = CGFloat(Self.ease(Self.span(k, 0.5, 0.84)))
        let seal = CGFloat(Self.ease(Self.span(k, 0.8, 0.95)))
        let falling = k >= 0.18
        // The ground shaking: hard as it splits, a last jolt as the crack slams shut.
        let quake = Self.span(k, 0, 0.12) * (1 - Self.span(k, 0.4, 0.55)) + Self.span(k, 0.86, 0.88) * (1 - Self.span(k, 0.88, 0.94))
        let f = Int(k * 60)
        let shake = CGPoint(x: (CGFloat(noise(f * 7 + 1)) * 2 - 1) * CGFloat(quake) * 2,
                            y: (CGFloat(noise(f * 7 + 2)) * 2 - 1) * CGFloat(quake) * 1.5)
        let shakeOn = CGPoint(x: (shake.x).rounded(), y: (shake.y).rounded())

        // The slabs the old place splits into: between jagged seams climbing from the floor to the top.
        let n = max(3, Int((W / (H * 0.42)).rounded()))
        let seams: [[CGPoint]] = (0...n).map { i in
            if i == 0 { return [CGPoint(x: -4, y: -4), CGPoint(x: -4, y: H + 4)] }
            if i == n { return [CGPoint(x: W + 4, y: -4), CGPoint(x: W + 4, y: H + 4)] }
            let base = W * CGFloat(i) / CGFloat(n) + (CGFloat(noise(i * 13)) - 0.5) * W / CGFloat(n) * 0.35
            return (0...8).map { j in
                CGPoint(x: (base + (CGFloat(noise(i * 31 + j * 5)) - 0.5) * W / CGFloat(n) * 0.28).rounded(),
                        y: j == 0 ? crackY : (crackY + (H - crackY) * CGFloat(j) / 8).rounded())
            }
        }

        // The cavern behind: dark red rock round a pool of fire far below.
        if falling && rise < 1 {
            back.setFillColor(rgb(0x0E0306)); back.fill(CGRect(x: 0, y: 0, width: W + 1, height: H + 1))
            let bands: [(UInt32, CGFloat)] = [(0x220508, 1.5), (0x3A080A, 1.15), (0x5E0E0C, 0.88), (0x8C1A0E, 0.64),
                                              (0xC0300E, 0.44), (0xF0601A, 0.27), (0xFFB050, 0.13)]
            let flicker = 1 + 0.04 * CGFloat(noise(Int(k * 30) + 400))
            // Each layer of rock round the fire is a ragged ledge, not a smooth ring: drawn a column at a time, its
            // top broken by lumps and notches, so the cavern reads as rock lit from below.
            let col = max(1, (H / 90).rounded())
            for (b, (hex, rr)) in bands.enumerated() {
                let ry = H * rr * flicker, rx = max(ry * 1.4, W * rr * 0.7), cy = -H * 0.12
                var rects: [CGRect] = []
                var x = (W / 2 - rx).rounded(.down)
                while x < W / 2 + rx {
                    let dx = (x + col / 2 - W / 2) / rx
                    if abs(dx) < 1 {
                        let i = Int(x / col)
                        let lump = (CGFloat(noise(b * 997 + i / 3)) - 0.5) * ry * 0.09
                        let notch = (CGFloat(noise(b * 991 + i)) - 0.5) * ry * 0.035
                        let top = cy + ry * (1 - dx * dx).squareRoot() + lump + notch
                        if top > 0 { rects.append(CGRect(x: x, y: 0, width: col, height: top.rounded())) }
                    }
                    x += col
                }
                back.setFillColor(rgb(hex)); back.fill(rects)
            }
            // Spires of rock standing in the glow, black with their inner edges lit red, and teeth of rock hanging
            // from the roof: they give the cavern its depth.
            let unit = max(1, (H / 90).rounded())
            for (i, at) in [0.17, 0.33, 0.6, 0.71, 0.86].enumerated() {
                let x = W * CGFloat(at) + (CGFloat(noise(i * 41 + 3)) - 0.5) * W * 0.04
                let tall = H * (0.1 + 0.3 * CGFloat(noise(i * 41 + 4))), base = H * (0.04 + 0.05 * CGFloat(noise(i * 41 + 5)))
                let lean = (CGFloat(noise(i * 41 + 6)) - 0.5) * 0.5
                let lit: CGFloat = x < W / 2 ? 1 : -1
                var y: CGFloat = 0
                while y < tall {
                    // A broken crag, not a cone: it narrows only so far, leans, bulges in lumps and ends blunt.
                    let lump = (CGFloat(noise(i * 53 + Int(y / (unit * 6)))) - 0.5) * base * 0.5
                    let half = (base * (1 - 0.7 * y / tall) + lump + unit).rounded()
                    let wob = (lean * y + (CGFloat(noise(i * 59 + Int(y / unit))) - 0.5) * unit).rounded()
                    back.setFillColor(rgb(0x160406)); back.fill(CGRect(x: (x - half + wob).rounded(), y: y, width: half * 2, height: unit * 2))
                    back.setFillColor(rgb(0x7A1C0C))
                    back.fill(CGRect(x: lit > 0 ? (x + half + wob).rounded() - unit : (x - half + wob).rounded(), y: y,
                                     width: unit, height: unit * 2))
                    y += unit * 2
                }
            }
            back.setFillColor(rgb(0x0A0204))
            let teeth = max(6, Int(W / (H * 0.09)))
            for i in 0..<teeth {
                let x = W * (CGFloat(i) + CGFloat(noise(i * 29 + 1)) * 0.6) / CGFloat(teeth)
                let len = H * (0.05 + 0.14 * CGFloat(noise(i * 29 + 2))), half = H * (0.015 + 0.02 * CGFloat(noise(i * 29 + 3)))
                var y: CGFloat = 0
                while y < len {
                    let hw = (half * (1 - y / len) + 0.5).rounded()
                    back.fill(CGRect(x: (x - hw).rounded(), y: (H - y - unit).rounded(), width: max(1, hw * 2), height: unit))
                    y += unit
                }
            }
            // Jagged rock walls either side, black against the glow.
            back.setFillColor(rgb(0x0A0204))
            let step = max(2, (H / 45).rounded())
            for side in [0, 1] {
                var y: CGFloat = 0, j = 0
                while y < H {
                    // Wider towards the top, where the rock overhangs the light; ragged row by row.
                    let ledge = CGFloat(noise(side * 50 + j / 4)) * 0.05, rag = CGFloat(noise(side * 70 + j)) * 0.02
                    let reach = min(W * 0.2, H * 0.5) * (0.2 + 0.9 * y / H) + W * (ledge + rag)
                    back.fill(CGRect(x: side == 0 ? 0 : (W - reach).rounded(), y: y, width: reach.rounded(), height: step))
                    y += step; j += 1
                }
            }
            hellmouthEmbers(back, k: k, W: W, H: H, count: 24, strength: 0.6, seed: 900)
        }
        // The slabs dropping away, the middle ones first, tumbling outward and shrinking into the deep: drawn behind the
        // places, so the new place rises in front of the last of them rather than under them.
        if falling {
            // The old place brought down to the art's grid once, rather than once a slab.
            var small = old
            if let lo = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
                lo.interpolationQuality = .none
                lo.draw(old, in: CGRect(x: 0, y: 0, width: W, height: H))
                if let img = lo.makeImage() { small = img }
            }
            let smallRect = small === old ? CGRect(x: 0, y: 0, width: W, height: H)
                : CGRect(x: 0, y: 0, width: CGFloat(w), height: CGFloat(h))
            let mid = CGFloat(n - 1) / 2
            let orders = (0..<n).map { abs(CGFloat($0) - mid).rounded(.down) }
            let last = max(1, orders.max() ?? 1)
            for i in 0..<n {
                let start = 0.18 + 0.16 * Double(orders[i] / last)
                let fall = CGFloat(Self.span(k, start, start + 0.24))
                guard fall < 1 else { continue }
                let lo = seams[i], hi = seams[i + 1]
                let path = CGMutablePath()
                path.addLines(between: lo + hi.reversed()); path.closeSubpath()
                let pivot = CGPoint(x: ((lo.first?.x ?? 0) + (hi.first?.x ?? 0)) / 2, y: crackY)
                let dir: CGFloat = CGFloat(i) < mid ? -1 : (CGFloat(i) > mid ? 1 : (noise(i) < 0.5 ? -1 : 1))
                let drop = fall * fall * H * 1.25
                let scale = 1 - 0.35 * fall
                back.saveGState()
                back.translateBy(x: pivot.x + (fall > 0 ? 0 : shakeOn.x) + (W / 2 - pivot.x) * 0.25 * fall,
                                  y: pivot.y - drop + (fall > 0 ? 0 : shakeOn.y))
                back.rotate(by: dir * -0.55 * fall * fall)
                back.scaleBy(x: scale, y: scale)
                back.translateBy(x: -pivot.x, y: -pivot.y)
                back.saveGState()
                back.addPath(path); back.clip()
                back.draw(small, in: smallRect)
                // Going red as it falls into the light.
                back.setFillColor(rgb(0x8A1408, 0.55 * fall + 0.12 * glow)); back.fill(CGRect(x: 0, y: 0, width: W, height: H))
                back.restoreGState()
                if fall > 0 {
                    back.addPath(path); back.setLineWidth(2); back.setStrokeColor(rgb(0x1A0606)); back.strokePath()
                }
                back.restoreGState()
            }
        }

        if let img = back.makeImage(), falling, rise < 1 {
            ctx.saveGState(); ctx.clip(to: r); ctx.draw(img, in: CGRect(x: r.minX, y: r.minY, width: CGFloat(w) * px, height: CGFloat(h) * px))
            ctx.restoreGState()
        }

        // The places: the old one shaking until it splits, the new one rising out of the light.
        ctx.saveGState(); ctx.clip(to: r)
        if !falling {
            ctx.setFillColor(rgb(0x0E0306)); ctx.fill(r)
            ctx.draw(old, in: r.offsetBy(dx: shakeOn.x * px, dy: shakeOn.y * px))
        }
        if rise > 0 {
            let jolt = seal > 0 ? shakeOn : .zero
            ctx.draw(new, in: r.offsetBy(dx: jolt.x * px, dy: ((rise - 1) * H).rounded() * px + jolt.y * px))
        }
        ctx.restoreGState()

        // The cracks: up the picture between the slabs while they're still standing, and along the floor.
        if !falling && climb > 0 {
            for seam in seams.dropFirst().dropLast() {
                hellmouthSeam(front, seam, upTo: crackY + (H - crackY) * climb, offset: shakeOn)
            }
        }
        if !falling || seal > 0 {
            let open: CGFloat = falling ? (1 - seal) * 0.9 : spread * (0.4 + 0.6 * climb)
            hellmouthFloorCrack(front, y: crackY, spread: falling ? 1 : spread, open: open, glow: falling ? 1 - seal : 1,
                                W: W, H: H, offset: shakeOn)
        }

        // Red light pouring up: shafts from the crack, the new place lit red from below, embers on the updraught.
        let shafts = glow * (1 - rise * 0.85)
        if shafts > 0.01 {
            let base: CGFloat = falling && rise < 0.5 ? -2 : crackY
            for i in 0..<7 {
                let x = W * (0.08 + 0.84 * CGFloat(noise(i * 17 + 3))) + CGFloat(sin(k * 6 + Double(i))) * W * 0.01
                guard falling || abs(x - W / 2) < spread * W / 2 else { continue }
                let width = W * (0.025 + 0.04 * CGFloat(noise(i * 17 + 4)))
                let pulse = 0.7 + 0.3 * CGFloat(noise(Int(k * 24) * 3 + i))
                for (m, a) in [(2.2 as CGFloat, 0.07 as CGFloat), (1.3, 0.09), (0.6, 0.12)] {
                    let path = CGMutablePath()
                    path.addLines(between: [CGPoint(x: x - width * m * 0.5, y: base), CGPoint(x: x + width * m * 0.5, y: base),
                                            CGPoint(x: x + width * m * 1.4, y: H + 2), CGPoint(x: x - width * m * 1.4, y: H + 2)])
                    front.addPath(path); front.setFillColor(rgb(m < 1 ? 0xFFA050 : 0xFF3A14, a * shafts * pulse)); front.fillPath()
                }
            }
        }
        let tint = glow * (falling ? 1 - rise : 0.5)     // gone once the new place is up
        if tint > 0.01 {
            for (j, a) in [0.3, 0.2, 0.12, 0.06].enumerated() {
                front.setFillColor(rgb(0xD0280C, CGFloat(a) * tint))
                front.fill(CGRect(x: 0, y: 0, width: W + 1, height: (H * [0.12, 0.26, 0.45, 0.7][j]).rounded()))
            }
        }
        if glow > 0.01 { hellmouthEmbers(front, k: k, W: W, H: H, count: 30, strength: glow, seed: 0) }
        hellmouthGrain(front, k: k, W: W, H: H, amount: 0.5 + 0.5 * glow)
        Self.blit(front, onto: ctx, width: w, height: h, px: px, in: r)
    }
}

/// A crack climbing up `seam` (from the floor up) as far as `top`: dark rock edges round a red-hot core.
private func hellmouthSeam(_ art: CGContext, _ seam: [CGPoint], upTo top: CGFloat, offset: CGPoint) {
    var pts: [CGPoint] = []
    for (a, b) in zip(seam, seam.dropFirst()) {
        if pts.isEmpty { pts.append(a) }
        if b.y <= top { pts.append(b); continue }
        let t = (top - a.y) / max(1, b.y - a.y)
        pts.append(CGPoint(x: (a.x + (b.x - a.x) * t).rounded(), y: top.rounded()))
        break
    }
    guard pts.count > 1 else { return }
    art.saveGState(); defer { art.restoreGState() }
    art.translateBy(x: offset.x, y: offset.y)
    for (width, hex) in [(3 as CGFloat, 0x1A0404 as UInt32), (1, 0xFF6A1A)] {
        art.addLines(between: pts); art.setLineWidth(width); art.setStrokeColor(rgb(hex)); art.strokePath()
    }
}

/// The crack along the floor at `y`, run out `spread` of the way from the middle to either edge and gaping `open`
/// (0 a hairline, 1 a jagged gap a few pixels wide), its fire `glow` bright.
private func hellmouthFloorCrack(_ art: CGContext, y: CGFloat, spread: CGFloat, open: CGFloat, glow: CGFloat,
                                 W: CGFloat, H: CGFloat, offset: CGPoint) {
    guard spread > 0, glow > 0.01 else { return }
    let half = spread * (W / 2 + 4)
    let x0 = Int((W / 2 - half).rounded(.down)), x1 = Int((W / 2 + half).rounded(.up))
    let seg = max(3, H / 40)
    let unit = max(1, (H / 90).rounded())
    var dark: [CGRect] = [], hot: [CGRect] = [], core: [CGRect] = [], halo: [CGRect] = []
    for x in x0...x1 {
        let fx = CGFloat(x) / seg, i = Int(fx.rounded(.down)), t = fx - CGFloat(i)
        let jag = (CGFloat(noise(i + 7000)) * (1 - t) + CGFloat(noise(i + 7001)) * t - 0.5) * H * 0.025
        let toEnd = min(1, abs(CGFloat(x) - W / 2 - (CGFloat(x) < W / 2 ? -half : half)) / (W * 0.08))
        let gap = ((1 + 4 * open * toEnd * (0.6 + 0.4 * CGFloat(noise(i + 7100)))) * unit).rounded()
        let cy = (y + jag + offset.y).rounded(), cx = CGFloat(x) + offset.x
        dark.append(CGRect(x: cx, y: cy - gap / 2 - unit, width: 1, height: gap + 2 * unit))
        hot.append(CGRect(x: cx, y: cy - gap / 2, width: 1, height: gap))
        if gap > 2 * unit { core.append(CGRect(x: cx, y: cy - gap / 2 + unit, width: 1, height: gap - 2 * unit)) }
        halo.append(CGRect(x: cx, y: cy + gap / 2 + unit, width: 1, height: (3 * unit * (0.5 + open)).rounded()))
    }
    art.setFillColor(rgb(0xFF3A14, 0.3 * glow)); art.fill(halo)
    art.setFillColor(rgb(0x140404)); art.fill(dark)
    art.setFillColor(rgb(0xE8401A, glow)); art.fill(hot)
    art.setFillColor(rgb(0xFFD890, glow)); art.fill(core)
}

/// Embers on the updraught: sparks rising and swaying, `strength` bright.
private func hellmouthEmbers(_ art: CGContext, k: Double, W: CGFloat, H: CGFloat, count: Int, strength: CGFloat, seed: Int) {
    let size = max(1, (H / 100).rounded())
    for i in 0..<count {
        let s = seed + i * 11
        let up = CGFloat(noise(s + 1)) + CGFloat(k) * (1.2 + CGFloat(noise(s + 2)))
        let y = (up - up.rounded(.down)) * (H + 10) - 5
        let x = W * CGFloat(noise(s)) + CGFloat(sin(k * 14 + Double(i))) * H * 0.02
        let hex: UInt32 = i % 3 == 0 ? 0xFFD890 : (i % 3 == 1 ? 0xFF8A2A : 0xE8401A)
        art.setFillColor(rgb(hex, strength * (1 - y / (H + 10)) * 0.9 + 0.1 * strength))
        art.fill(CGRect(x: x.rounded(), y: y.rounded(), width: size, height: size))
    }
}

/// A little film grain over the night, changing every frame or two.
private func hellmouthGrain(_ art: CGContext, k: Double, W: CGFloat, H: CGFloat, amount: CGFloat) {
    let seed = Int(k * 40) * 977
    let count = Int(W * H / 110)
    var light: [CGRect] = [], dark: [CGRect] = []
    for i in 0..<count {
        let rect = CGRect(x: (CGFloat(noise(seed + i * 3)) * W).rounded(.down), y: (CGFloat(noise(seed + i * 3 + 1)) * H).rounded(.down),
                          width: 1, height: 1)
        if i % 2 == 0 { light.append(rect) } else { dark.append(rect) }
    }
    art.setFillColor(rgb(0xFFFFFF, 0.07 * amount)); art.fill(light)
    art.setFillColor(rgb(0x000000, 0.12 * amount)); art.fill(dark)
}
