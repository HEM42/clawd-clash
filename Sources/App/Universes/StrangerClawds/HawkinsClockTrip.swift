import CoreGraphics
import Foundation

// Vecna's Clock (`HawkinsWipe.clock`): the grandfather clock his victims see before he takes them. It looms up over
// the old place until it fills the picture, chimes four times, its glass cracking more with each chime, and on the
// fourth the glass, and the picture with it, shatters into pieces that fall away onto the new place.

extension HawkinsTrip {
    /// A frame `k` (0…1) of Vecna's Clock, over the whole of `r`. The old place darkens to Vecna's red and the clock
    /// looms up out of it (0–0.2); it chimes four times (0.24, 0.41, 0.58, 0.75), each chime a red ring rolling out
    /// from the dial, a jolt, the minute hand stepping on and more cracks across the glass; on the fourth the picture
    /// shatters from where the cracks began, the pieces flying out and falling, turning, onto the new place (0.8–1).
    /// The clock, the cracks and the rings are pixel art; the pieces are cut on the art's grid.
    func drawClock(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let art = HawkinsArt(r)
        let c = art.c, w = art.w, h = art.h
        let loom = Self.ease(Self.span(k, 0, 0.2))
        let chimes = [0.24, 0.41, 0.58, 0.75]
        let rung = chimes.filter { k >= $0 }.count
        let since = rung > 0 ? k - chimes[rung - 1] : 1
        let shatter = Self.span(k, 0.8, 1)
        let R = Double(h) * 0.37                                       // the dial's radius
        let cx = Double(w) / 2, cy = Double(h) * 0.44
        let hit = (x: cx + R * 0.32, y: cy - R * 0.28)                 // where the glass first cracks

        // The clock and everything round it, drawn once into its own canvas.
        hawkinsClockFace(c, cx: cx, cy: cy, R: R, minute: 50 + Double(rung) * 2.5 + (since < 0.03 ? 0.6 : 0))
        hawkinsClockCracks(c, hit: hit, centre: (cx, cy), R: R, cracks: rung)
        // A red ring rolling out from the dial at each chime.
        if rung > 0 && since < 0.14 && shatter <= 0 {
            let u = since / 0.14
            let rr = Int(R * (1 + u * 1.6))
            for a in stride(from: 0.0, to: 2 * Double.pi, by: 0.6 / Double(rr)) {
                let x = Int((cx + cos(a) * Double(rr)).rounded()), y = Int((cy + sin(a) * Double(rr)).rounded())
                c.px(x, y, C(0xFF3A3A, 0.7 * (1 - u))); c.px(x, y + 1, C(0x8A0A10, 0.5 * (1 - u)))
            }
        }

        // The jolt as it chimes: the whole picture knocked a pixel or two.
        let jolt = rung > 0 && since < 0.025 ? CGFloat(rung % 2 == 0 ? 2 : -2) * art.px : 0

        // Before it shatters: the old place gone red and dark behind, the clock looming up out of it.
        func scene(_ into: CGContext, _ rect: CGRect) {
            into.drawShot(old, in: rect)
            Self.wash(into, 0x3A0408, 0.55 + 0.3 * loom, in: rect)
            Self.wash(into, 0x000000, 0.35 * loom, in: rect)
            guard let img = c.makeImage() else { return }
            let s = CGFloat(0.35 + 0.65 * loom)
            let full = art.frame(0, 0, w, h)
            let mid = CGPoint(x: rect.minX + CGFloat(cx) * art.px, y: rect.maxY - CGFloat(cy) * art.px)
            into.saveGState()
            into.interpolationQuality = .none
            into.translateBy(x: mid.x, y: mid.y); into.scaleBy(x: s, y: s); into.translateBy(x: -mid.x, y: -mid.y)
            into.setAlpha(CGFloat((loom * 4).rounded(.up) / 4))
            into.draw(img, in: full)
            into.restoreGState()
        }
        if shatter <= 0 {
            if jolt != 0 { scene(ctx, r) }       // under the knocked picture, so no edge shows bare
            ctx.saveGState()
            ctx.translateBy(x: jolt, y: 0)
            scene(ctx, r)
            ctx.restoreGState()
            return
        }

        // The shatter: the picture as it stood, in pieces round the first crack, flying out and falling away.
        guard let frozen = CGContext(data: nil, width: Int(r.width), height: Int(r.height), bitsPerComponent: 8, bytesPerRow: 0,
                                     space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { ctx.drawShot(new, in: r); return }
        let local = CGRect(x: 0, y: 0, width: r.width, height: r.height)
        frozen.interpolationQuality = .none
        scene(frozen, local)
        guard let picture = frozen.makeImage() else { ctx.drawShot(new, in: r); return }
        ctx.drawShot(new, in: r)
        let P = CGPoint(x: r.minX + CGFloat(hit.x) * art.px, y: r.maxY - CGFloat(hit.y) * art.px)
        let far = (r.width + r.height) * 1.2, near = CGFloat(R) * art.px * 0.7
        let n = 11
        let fly = CGFloat(Self.ease(shatter) * 0.6 + shatter * 0.4)
        for i in 0..<n {
            let a0 = (Double(i) + noise(i * 3) * 0.5) / Double(n) * 2 * .pi
            let a1 = (Double(i + 1) + noise((i + 1) % n * 3) * 0.5) / Double(n) * 2 * .pi
            for ring in 0..<2 {
                let r0 = ring == 0 ? 0 : near * CGFloat(0.9 + noise(i * 5) * 0.3), r1 = ring == 0 ? near * CGFloat(0.9 + noise(i * 5) * 0.3) : far
                let path = CGMutablePath()
                func at(_ a: Double, _ d: CGFloat) -> CGPoint { CGPoint(x: P.x + CGFloat(cos(a)) * d, y: P.y + CGFloat(sin(a)) * d) }
                path.move(to: at(a0, r0)); path.addLine(to: at(a1, r0)); path.addLine(to: at(a1, r1)); path.addLine(to: at(a0, r1))
                path.closeSubpath()
                // Out from the crack, faster near it, and down as it falls, turning a little.
                let mid = (a0 + a1) / 2, speed = (ring == 0 ? 1.3 : 0.8) * (0.7 + noise(i * 7 + ring) * 0.6)
                let out = fly * r.height * CGFloat(speed) * 0.6
                let dx = CGFloat(cos(mid)) * out, dy = CGFloat(sin(mid)) * out - fly * fly * r.height * 3
                let turn = CGFloat((noise(i * 11 + ring) - 0.5) * 1.2) * fly
                let centre = at(mid, (r0 + min(r1, near * 3)) / 2)
                ctx.saveGState()
                ctx.translateBy(x: centre.x + dx, y: centre.y + dy)
                ctx.rotate(by: turn)
                ctx.translateBy(x: -centre.x, y: -centre.y)
                ctx.addPath(path); ctx.clip()
                ctx.draw(picture, in: r)
                // A bright edge where the glass broke, only near the break: further out it's the picture that split.
                ctx.addEllipse(in: CGRect(x: P.x - near * 1.6, y: P.y - near * 1.6, width: near * 3.2, height: near * 3.2)); ctx.clip()
                ctx.addPath(path); ctx.setStrokeColor(rgb(0xE8ECF4, 0.7)); ctx.setLineWidth(art.px); ctx.strokePath()
                ctx.restoreGState()
            }
        }
    }

    /// The grandfather clock's hood, filling the picture: dark mahogany lit red from the left, turned columns either
    /// side of the dial, a broken-arch top with its finial, and the dial itself, cream gone yellow with age, its
    /// chapter ring, hour marks and minute dots, black spade hands and a glint across the glass.
    private func hawkinsClockFace(_ c: PixelCanvas, cx: Double, cy: Double, R: Double, minute: Double) {
        let wood = C(0x3E1C12), woodL = C(0x5E2C1A), woodD = C(0x24100A), redLit = C(0x8A2A20)
        let x0 = Int(cx - R * 1.45), x1 = Int(cx + R * 1.45), top = Int(cy - R * 1.5)
        // The case, from above the dial down past the bottom of the picture, with a waist below the hood.
        c.rect(x0, top, x1 - x0, c.h - top, wood)
        c.rect(x0, top, 2, c.h - top, redLit); c.rect(x1 - 2, top, 2, c.h - top, woodD)
        let waist = Int(cy + R * 1.25)
        c.rect(x0 - 2, waist, x1 - x0 + 4, 3, woodL); c.rect(x0 - 2, waist + 3, x1 - x0 + 4, 1, woodD)
        c.rect(x0 + Int(R * 0.25), waist + 4, x1 - x0 - Int(R * 0.5), c.h, woodD)
        c.rect(x0 + Int(R * 0.25) + 2, waist + 4, x1 - x0 - Int(R * 0.5) - 4, c.h, wood)
        // The broken-arch top: two scrolls rising to either side of a finial.
        for side in [-1.0, 1.0] {
            for i in 0..<Int(R * 0.9) {
                let u = Double(i) / (R * 0.9)
                let x = Int(cx + side * (R * 1.45 - Double(i)))
                let y = top - Int(sin(u * .pi * 0.8) * R * 0.35)
                c.rect(x, y, 1, top - y + 2, wood); c.px(x, y, woodL)
            }
        }
        c.rect(Int(cx) - 2, top - Int(R * 0.45), 5, Int(R * 0.45), woodL); c.rect(Int(cx) - 1, top - Int(R * 0.55), 3, 3, C(0xB8903A))
        // Turned columns either side of the dial, with gold capitals.
        for x in [Int(cx - R * 1.28), Int(cx + R * 1.12)] {
            c.rect(x, top + 4, Int(R * 0.16), Int(R * 2.6), woodL)
            c.rect(x + 1, top + 4, 1, Int(R * 2.6), C(0x7E4028))
            c.rect(x - 1, top + 2, Int(R * 0.16) + 2, 3, C(0xB8903A))
            c.rect(x - 1, top + 4 + Int(R * 2.6), Int(R * 0.16) + 2, 3, C(0xB8903A))
        }
        // The dial: a brass bezel, the face, the chapter ring, the marks.
        let ir = Int(R)
        c.circle(Int(cx), Int(cy), ir + 3, C(0x8A6A28)); c.circle(Int(cx), Int(cy), ir + 2, C(0xC8A048))
        c.circle(Int(cx), Int(cy), ir, C(0xD8CBA4))
        for i in 0..<14 {   // the face's age: a few faint stains
            let a = noise(i * 9) * 2 * .pi, d = noise(i * 9 + 1) * R * 0.8
            c.circle(Int(cx + cos(a) * d), Int(cy + sin(a) * d), 1 + Int(noise(i * 9 + 2) * 2), C(0xB8A880, 0.5))
        }
        for a in stride(from: 0.0, to: 2 * Double.pi, by: 0.5 / R) {
            for d in [0.78, 0.92] { c.px(Int((cx + cos(a) * R * d).rounded()), Int((cy + sin(a) * R * d).rounded()), C(0x2A1E14)) }
        }
        for m in 0..<60 {
            let a = Double(m) / 60 * 2 * .pi - .pi / 2
            if m % 5 == 0 {
                for d in stride(from: R * 0.79, to: R * 0.92, by: 0.5) { c.rect(Int((cx + cos(a) * d).rounded()), Int((cy + sin(a) * d).rounded()), 2, 2, C(0x1A120C)) }
            } else {
                c.px(Int((cx + cos(a) * R * 0.85).rounded()), Int((cy + sin(a) * R * 0.85).rounded()), C(0x3A2E20))
            }
        }
        // The hands: hour and minute, black, with spade tips, and the pin.
        let hourA = (minute / 60 + 10) / 12 * 2 * .pi - .pi / 2, minA = minute / 60 * 2 * .pi - .pi / 2
        for (a, len, th) in [(hourA, 0.5, 1.6), (minA, 0.76, 1.1)] {
            hawkinsLine(c, cx, cy, cx + cos(a) * R * len, cy + sin(a) * R * len, C(0x0E0A08), th)
            c.circle(Int(cx + cos(a) * R * len * 0.82), Int(cy + sin(a) * R * len * 0.82), Int(th + 1.5), C(0x0E0A08))
        }
        c.circle(Int(cx), Int(cy), 2, C(0xC8A048))
        // A glint across the glass, top left.
        for i in 0..<Int(R * 0.5) {
            c.px(Int(cx - R * 0.6) + i, Int(cy - R * 0.25) - i, C(0xFFFFFF, 0.35))
            c.px(Int(cx - R * 0.6) + i + 2, Int(cy - R * 0.25) - i, C(0xFFFFFF, 0.18))
        }
    }

    /// Cracks across the dial's glass from `hit`, more with each chime: long ones running out to the bezel and short
    /// ones between, white with a dark line beside each, and a ring of them once three chimes have sounded. Only on
    /// the glass, inside the bezel.
    private func hawkinsClockCracks(_ c: PixelCanvas, hit: (x: Double, y: Double), centre: (x: Double, y: Double), R: Double, cracks: Int) {
        guard cracks > 0 else { return }
        let glass = C(0xF0F4FA), shadow = C(0x2A2A34, 0.7)
        let lines = [3, 6, 10, 15][min(3, cracks - 1)]
        for i in 0..<lines {
            var a = Double(i) / Double(lines) * 2 * .pi + noise(i * 13) * 0.5
            var x = hit.x, y = hit.y
            let len = R * (0.5 + noise(i * 13 + 1) * 1.1) * (i < 3 ? 1.4 : 1)
            var d = 0.0
            while d < len {
                a += (noise(i * 131 + Int(d)) - 0.5) * 0.5
                x += cos(a); y += sin(a); d += 1
                if (x - centre.x) * (x - centre.x) + (y - centre.y) * (y - centre.y) > (R - 1) * (R - 1) { break }
                c.px(Int(x.rounded()) + 1, Int(y.rounded()) + 1, shadow)
                c.px(Int(x.rounded()), Int(y.rounded()), glass)
            }
        }
        if cracks >= 3 {
            let rr = R * 0.35
            for a in stride(from: 0.0, to: 2 * Double.pi, by: 0.8 / rr) where noise(Int(a * 40)) > 0.25 {
                let wob = 1 + (noise(Int(a * 9)) - 0.5) * 0.4
                c.px(Int((hit.x + cos(a) * rr * wob).rounded()), Int((hit.y + sin(a) * rr * wob).rounded()), glass)
            }
        }
        // The point where it struck: a small star of white.
        c.rect(Int(hit.x) - 1, Int(hit.y) - 1, 3, 3, glass)
    }
}
