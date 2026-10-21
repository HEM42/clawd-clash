import CoreGraphics
import Foundation

extension BurtonTrip {
    /// Wonkavision. The old place breaks into thousands of tiny pixels, the bottom rows first, and they fly up and
    /// off over the top of the screen (0.03–0.4), uncovering a stark white television room, its walls ruled in a faint
    /// grid, and on the floor a chunky old TV set in a wooden cabinet, with two dials and a speaker grille, rabbit
    /// ears on top, its screen fizzing with snow. The pixels pour back down in a funnel into the screen, changing
    /// colour as they fall, and land as a tiny picture of the new place (0.2–0.68), which then shows on the screen
    /// clear (0.6–0.7). The camera pushes in on the set (0.7–1): the cabinet grows past the edges of the frame, its
    /// wood in ever chunkier pixels, until the screen is the whole frame and the new place is there.
    func drawWonkavision(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let (c, px) = Self.pixelCanvas(in: r)
        let W = c.w, H = c.h, fw = Double(W), fh = Double(H)
        let tick = Int(k * 2.4 * 30)

        // The set: its screen as wide as the frame's shape allows, standing on the floor in the middle.
        let wide = fw / fh > 2.4
        let hh = max(12, Int((fh * (wide ? 0.4 : 0.34)).rounded()))
        let hw = max(16, Int((Double(hh) * min(2.2, max(1.25, fw / fh))).rounded()))
        let tv = Self.wonkaSet(hw: hw, hh: hh)
        let floorY = Int(fh * 0.86)
        let tvX = W / 2 - tv.canvas.w / 2 + tv.side / 2, tvY = floorY - tv.canvas.h
        // The screen on the frame (screen points), and how big the new place shows in it (filling it).
        let hole0 = CGRect(x: r.minX + CGFloat(tvX + tv.hole.x) * px, y: r.maxY - CGFloat(tvY + tv.hole.y + hh) * px,
                           width: CGFloat(hw) * px, height: CGFloat(hh) * px)
        let fill0 = max(hole0.width / r.width, hole0.height / r.height)

        // The push in: everything grows about one point, so the screen ends centred over the frame and past its edges.
        let zEnd = 1.06 * max(r.width / hole0.width, r.height / hole0.height)
        let push = Self.ease(Self.span(k, 0.7, 1))
        let z = CGFloat(exp(log(Double(zEnd)) * push))
        let fixed = CGPoint(x: (r.midX - hole0.midX * zEnd) / (1 - zEnd), y: (r.midY - hole0.midY * zEnd) / (1 - zEnd))
        func zoomed(_ rect: CGRect) -> CGRect {
            CGRect(x: fixed.x + (rect.minX - fixed.x) * z, y: fixed.y + (rect.minY - fixed.y) * z,
                   width: rect.width * z, height: rect.height * z)
        }
        let hole = zoomed(hole0)

        // The white room.
        Self.wonkaRoom(c, floorY: floorY)
        if let img = c.makeImage() {
            ctx.draw(img, in: zoomed(CGRect(x: r.minX, y: r.maxY - CGFloat(H) * px, width: CGFloat(W) * px,
                                            height: CGFloat(H) * px)))
        }

        // The screen: snow until the picture comes through, then the new place, filling it.
        let clear = Self.span(k, 0.6, 0.7)
        ctx.saveGState()
        ctx.clip(to: hole)
        if clear < 1 {
            ctx.setFillColor(rgb(0x2A2C30)); ctx.fill(hole)
            let (snow, spx) = (PixelCanvas(hw, hh), px * z)
            for n in 0..<(hw * hh / 6) {
                let v = noise(tick * 7919 + n * 3)
                snow.px(Int(noise(tick * 31 + n * 7 + 1) * Double(hw)), Int(noise(tick * 17 + n * 5 + 2) * Double(hh)),
                        C(v < 0.5 ? 0x8A8C90 : 0xD8DAD8, 0.6))
            }
            if let img = snow.makeImage() {
                ctx.draw(img, in: CGRect(x: hole.minX, y: hole.minY, width: CGFloat(hw) * spx,
                                         height: CGFloat(hh) * spx))
            }
        }
        if clear > 0 {
            Self.picture(ctx, new, in: r, at: CGPoint(x: hole.midX, y: hole.midY), scale: min(1, fill0 * z),
                         alpha: CGFloat(clear))
        }
        // Scan lines over the glass, gone as the screen fills the frame.
        let lines = 1 - push
        if lines > 0.01 {
            ctx.setFillColor(rgb(0x000000, CGFloat(0.16 * lines)))
            let step = max(2, px * z * 2)
            var y = hole.minY
            while y < hole.maxY { ctx.fill(CGRect(x: hole.minX, y: y, width: hole.width, height: step / 2)); y += step }
        }
        ctx.restoreGState()

        // The set itself, over the edge of its screen.
        if let img = tv.canvas.makeImage() {
            ctx.draw(img, in: zoomed(CGRect(x: r.minX + CGFloat(tvX) * px, y: r.maxY - CGFloat(tvY + tv.canvas.h) * px,
                                            width: CGFloat(tv.canvas.w) * px, height: CGFloat(tv.canvas.h) * px)))
        }
        guard k < 0.7 else { return }

        // The pixels: each lifts off the old place, flies up over the top and pours down into its spot on the screen.
        let cell = max(2, Int((fw * fh / 9000).squareRoot().rounded(.up)))
        let cols = (W + cell - 1) / cell, rows = (H + cell - 1) / cell
        let from = Self.wonkaSample(old, cols: cols, rows: rows), to = Self.wonkaSample(new, cols: cols, rows: rows)
        guard !from.isEmpty, !to.isEmpty else { return }
        let fill = Double(fill0)
        let hx0 = Double(tvX + tv.hole.x), hy0 = Double(tvY + tv.hole.y)
        let hcx = hx0 + Double(hw) / 2, hcy = hy0 + Double(hh) / 2
        let small = max(1, Int((Double(cell) * fill).rounded()))
        c.clear()
        var keep: [CGRect] = []
        for j in 0..<rows {
            var run = -1
            for i in 0...cols {
                var standing = false
                if i < cols {
                    let n = j * cols + i
                    let t0 = 0.03 + 0.22 * (1 - Double(j) / Double(rows)) + 0.06 * noise(n * 7 + 11)
                    let t1 = t0 + 0.38
                    if k < t0 { standing = true } else if k < 0.7 {
                        let hx = Double(i * cell) + Double(cell) / 2, hy = Double(j * cell) + Double(cell) / 2
                        // Its spot on the screen, kept just inside the glass.
                        let dx = min(hx0 + Double(hw) - 1, max(hx0, hcx + (hx - fw / 2) * fill))
                        let dy = min(hy0 + Double(hh) - 1, max(hy0, hcy + (hy - fh / 2) * fill))
                        let u = min(1, (k - t0) / (t1 - t0)), e = u * u * (3 - 2 * u)
                        let mx = (hx + dx) / 2 + sin(Double(n) * 0.37 + u * 6) * fw * 0.08
                        let my = -fh * (0.9 + 0.3 * noise(n * 7 + 12))
                        let a = 1 - e
                        let x = a * a * hx + 2 * a * e * mx + e * e * dx, y = a * a * hy + 2 * a * e * my + e * e * dy
                        let tint = Self.span(u, 0.45, 0.85)
                        let col = tint <= 0 ? from[n] : tint >= 1 ? to[n] : Self.wonkaMix(from[n], to[n], tint)
                        let size = u < 0.55 ? cell : max(small, Int((Double(cell) * (1 - Self.span(u, 0.55, 1))
                                                                    + Double(small) * Self.span(u, 0.55, 1)).rounded()))
                        c.rect(Int(x.rounded()) - size / 2, Int(y.rounded()) - size / 2, size, size, col)
                    }
                }
                if standing && run < 0 { run = i }
                if !standing && run >= 0 {
                    keep.append(CGRect(x: r.minX + CGFloat(run * cell) * px, y: r.maxY - CGFloat((j + 1) * cell) * px,
                                       width: CGFloat((i - run) * cell) * px, height: CGFloat(cell) * px))
                    run = -1
                }
            }
        }
        if !keep.isEmpty { ctx.saveGState(); ctx.clip(to: keep); ctx.draw(old, in: r); ctx.restoreGState() }
        Self.blitCanvas(c, onto: ctx, px: px, in: r, alpha: CGFloat(1 - Self.span(k, 0.62, 0.7)))
    }

    /// The colour of each square of `img` on a `cols` × `rows` grid (rows from the top), one sample each.
    private static func wonkaSample(_ img: CGImage, cols: Int, rows: Int) -> [Px] {
        guard cols > 0, rows > 0, let g = CGContext(data: nil, width: cols, height: rows, bitsPerComponent: 8,
                                                    bytesPerRow: cols * 4, space: CGColorSpaceCreateDeviceRGB(),
                                                    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue),
              let data = g.data else { return [] }
        g.interpolationQuality = .none
        g.draw(img, in: CGRect(x: 0, y: 0, width: cols, height: rows))
        let bytes = data.bindMemory(to: UInt8.self, capacity: cols * rows * 4)
        return (0..<(cols * rows)).map { n in Px(r: bytes[n * 4], g: bytes[n * 4 + 1], b: bytes[n * 4 + 2], a: 255) }
    }

    /// Between two colours, `f` of the way.
    private static func wonkaMix(_ a: Px, _ b: Px, _ f: Double) -> Px {
        func m(_ x: UInt8, _ y: UInt8) -> UInt8 { UInt8(Double(x) + (Double(y) - Double(x)) * f) }
        return Px(r: m(a.r, b.r), g: m(a.g, b.g), b: m(a.b, b.b), a: 255)
    }

    /// The stark white television room: bone walls ruled in a faint grid, a pale floor from `floorY` with a shadow
    /// line where it meets the wall.
    private static func wonkaRoom(_ c: PixelCanvas, floorY: Int) {
        let grid = max(8, c.h / 6)
        c.rect(0, 0, c.w, floorY, C(0xF2EEE3))
        for x in stride(from: grid / 2, to: c.w, by: grid) { c.rect(x, 0, 1, floorY, C(0xE2DDD0)) }
        for y in stride(from: grid / 2, to: floorY, by: grid) { c.rect(0, y, c.w, 1, C(0xE2DDD0)) }
        c.rect(0, floorY, c.w, c.h - floorY, C(0xDCD7CA))
        c.rect(0, floorY, c.w, 1, C(0xB8B2A4))
        for y in stride(from: floorY + 3, to: c.h, by: 4) { c.rect(0, y, c.w, 1, C(0xD2CCBE)) }
    }

    /// The TV set for a screen `hw` × `hh`, on a canvas of its own: a chunky wooden cabinet with an ink edge, a dark
    /// bezel with rounded corners round the screen (left open), a side panel with two dials over a speaker grille,
    /// splayed legs and rabbit-ear aerials. Returns where the screen is and how wide the side panel is.
    private static func wonkaSet(hw: Int, hh: Int) -> (canvas: PixelCanvas, hole: (x: Int, y: Int), side: Int) {
        let bezel = max(2, hh / 9), frame = max(3, hh / 8), side = max(8, hh * 9 / 20)
        let legs = max(3, hh / 6), ears = max(6, hh * 2 / 5)
        let bw = hw + 2 * bezel + 3 * frame + side, bh = hh + 2 * bezel + 2 * frame
        let c = PixelCanvas(bw + 2, bh + legs + ears + 2)
        let ink = C(0x16161B)
        let x0 = 1, y0 = 1 + ears
        // Rabbit ears.
        let ex = Double(x0 + frame + bezel + hw / 2), ey = Double(y0)
        for (dx, tip) in [(-1.0, C(0xC8C4BC)), (1.0, C(0xC8C4BC))] {
            let tx = ex + dx * Double(ears) * 0.9, ty = ey - Double(ears) + 1
            c.glowLine(ex, ey, tx, ty, core: C(0x2A2A30), glow: C(0, 0), coreR: 0.5, glowR: 0.55)
            c.rect(Int(tx) - 1, Int(ty) - 1, 2, 2, tip)
        }
        c.rect(Int(ex) - 3, y0 - 2, 6, 2, ink)
        // Legs, splayed.
        for (lx, dir) in [(x0 + frame * 2, -1), (x0 + bw - frame * 2, 1)] {
            for q in 0..<legs { c.rect(lx + dir * q / 2 - 1, y0 + bh + q, 2, 1, C(0x3A2412)) }
        }
        // Everything round the screen is painted around it, so the screen itself stays open.
        let sx = x0 + frame + bezel, sy = y0 + frame + bezel
        func paint(_ x: Int, _ y: Int, _ w: Int, _ h: Int, _ col: Px) {
            let top = min(y + h, sy), bottom = max(y, sy + hh)
            if top > y { c.rect(x, y, w, top - y, col) }
            if y + h > bottom { c.rect(x, bottom, w, y + h - bottom, col) }
            let a = max(y, sy), b = min(y + h, sy + hh)
            guard b > a else { return }
            if sx > x { c.rect(x, a, min(w, sx - x), b - a, col) }
            if x + w > sx + hw { let l = max(x, sx + hw); c.rect(l, a, x + w - l, b - a, col) }
        }
        // The cabinet, its corners rounded, grain along it, lit along the top.
        paint(x0 - 1, y0, bw + 2, bh, ink); paint(x0, y0 - 1, bw, bh + 2, ink)
        paint(x0, y0, bw, bh, C(0x7A4A26))
        for gy in stride(from: y0 + 2, to: y0 + bh - 1, by: 3) {
            var gx = x0 + Int(noise(gy * 13) * 6)
            while gx < x0 + bw - 2 {
                let run = 3 + Int(noise(gx * 7 + gy) * Double(max(4, bw / 6)))
                paint(gx, gy, min(run, x0 + bw - 1 - gx), 1, C(0x643A1C))
                gx += run + 2 + Int(noise(gx + gy * 5) * 5)
            }
        }
        c.rect(x0, y0, bw, 1, C(0xA86E3E)); c.rect(x0, y0 + bh - 1, bw, 1, C(0x4E2C14))
        for (cx, cy) in [(x0, y0), (x0 + bw - 1, y0), (x0, y0 + bh - 1), (x0 + bw - 1, y0 + bh - 1)] {
            c.px(cx, cy, ink)
        }
        // The bezel, its inner corners rounded.
        paint(sx - bezel, sy - bezel, hw + 2 * bezel, hh + 2 * bezel, C(0x2A2622))
        c.rect(sx - bezel, sy - bezel, hw + 2 * bezel, 1, C(0x16120E))
        paint(sx - 1, sy - 1, hw + 2, hh + 2, C(0x4A443C))
        let round = max(1, hh / 14)
        for q in 0..<round {
            for (cx, cy, dx, dy) in [(sx, sy, 1, 1), (sx + hw - 1, sy, -1, 1), (sx, sy + hh - 1, 1, -1),
                                     (sx + hw - 1, sy + hh - 1, -1, -1)] {
                c.rect(dx > 0 ? cx : cx - (round - q) + 1, cy + dy * q, round - q, 1, C(0x4A443C))
            }
        }
        // The side panel: two dials over a speaker grille.
        let px0 = sx + hw + bezel + frame, pw = side
        c.rect(px0, sy - bezel, pw, hh + 2 * bezel, C(0x5C3418))
        c.rect(px0, sy - bezel, pw, 1, C(0x3A2412))
        let dr = max(2, pw / 4)
        for (q, dy) in [(0, sy - bezel + dr + 2), (1, sy - bezel + 3 * dr + 5)] {
            let cx = px0 + pw / 2
            c.circle(cx, dy, dr, ink); c.circle(cx, dy, dr - 1, C(0xC8B48A))
            let a = q == 0 ? -2.2 : -0.6
            c.glowLine(Double(cx) + 0.5, Double(dy) + 0.5, Double(cx) + 0.5 + cos(a) * Double(dr - 1),
                       Double(dy) + 0.5 + sin(a) * Double(dr - 1), core: ink, glow: C(0, 0), coreR: 0.5, glowR: 0.55)
        }
        let grille = sy - bezel + 4 * dr + 8
        for gy in stride(from: grille, to: sy + hh + bezel - 2, by: 2) { c.rect(px0 + 2, gy, pw - 4, 1, C(0x2E1C0C)) }
        return (c, (sx, sy), side)
    }
}
