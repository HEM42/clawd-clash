import CoreGraphics
import Foundation

// The Title (`HawkinsWipe.title`): the opening titles, in our own lettering. The old place goes dark, red neon letters
// spelling STRANGER CLAWDS drift in out of the dark from off the edges, close up, the camera pulling back as they lock
// together, the glow swells, and the camera pushes through the gap in the D onto the new place.

extension HawkinsTrip {
    /// A frame `k` (0…1) of The Title, over the whole of `r`. The old place fades to black (0–0.12); the letters drift
    /// in from off the edges, each from its own side and in its own time, brightening out of the dark, while the camera
    /// pulls back from close up (0.1–0.6); they lock, a bar of neon over the first word and one under the last, and the
    /// glow swells and holds (0.6–0.74); the camera pushes into the D's counter, faster and faster, the new place showing
    /// through it until it fills the picture (0.74–1). The letters are hollow neon tubes, a hot core inside a red rim,
    /// dim red inside and glowing red round the outside, all worked out on the title's own pixel grid so the tubes thicken
    /// as the camera closes in. A little grain over the dark.
    func drawTitle(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let art = HawkinsArt(r)
        let c = art.c, w = art.w, h = art.h
        let dark = Self.span(k, 0, 0.12)
        let slide = Self.span(k, 0.1, 0.6), swell = Self.span(k, 0.6, 0.7), push = Self.span(k, 0.74, 1)

        // Where every letter ends up: one line on the window's strip, two on the screen saver, a bar's room above and
        // below.
        let lines = art.wide ? ["STRANGER CLAWDS"] : ["STRANGER", "CLAWDS"]
        let dots = lines.map { hawkinsTripTextWidth($0, 1) }.max()!
        let tall = lines.count * 7 + 2
        let p = max(2, min(w * 78 / 100 / dots, h * 62 / 100 / tall))
        let blockH = lines.count * 7 * p - 2 * p
        let top = (h - blockH) / 2
        var letters: [(ch: Character, x: Int, y: Int)] = []
        var lineSpans: [(x0: Int, x1: Int)] = []
        for (li, line) in lines.enumerated() {
            let x0 = (w - hawkinsTripTextWidth(line, p)) / 2
            var x = x0
            for ch in line {
                guard let g = hawkinsTripGlyphs[ch] else { x += 3 * p; continue }
                letters.append((ch, x, top + li * 7 * p))
                x += (g.count / 5 + 1) * p
            }
            lineSpans.append((x0, x - p))
        }

        // The title as it stands this frame, on its own canvas: each letter (and bar) slid back along its way in, in a
        // grey as bright as it's come out of the dark (read back as its red channel).
        let title = PixelCanvas(w, h)
        func grey(_ b: Double) -> Px { let v = UInt32(Self.clamp(b) * 255); return C(v << 16 | v << 8 | v) }
        let n = letters.count
        for (i, l) in letters.enumerated() {
            let start = noise(i * 13 + 1) * 0.42
            let e = Self.span(slide, start, start + 0.55)
            let left = i < n / 2 || (i == n / 2 && n % 2 == 1 && noise(i) < 0.5)
            let dx = (left ? -1 : 1) * Double(w) * (0.5 + 0.4 * noise(i * 7 + 3))
            let dy = (i % 2 == 0 ? -1 : 1) * Double(h) * (0.25 + 0.35 * noise(i * 11 + 5))
            let rest = pow(1 - e, 3)
            let b = Self.span(slide, start, start + 0.3)
            guard b > 0 else { continue }
            hawkinsSoftText(title, l.x + Int((dx * rest).rounded()), l.y + Int((dy * rest).rounded()), String(l.ch),
                            hawkinsTripGlyphs, grey(b), p)
        }
        for (side, span) in [(-1, lineSpans[0]), (1, lineSpans[lineSpans.count - 1])] {
            let e = Self.span(slide, 0.3, 0.95)
            guard e > 0 else { continue }
            let slip = Int((Double(side * w) * pow(1 - e, 3)).rounded())
            let y = side < 0 ? top - 2 * p : top + blockH + p
            title.rect(span.x0 + slip, y, span.x1 - span.x0, max(2, p * 2 / 3), grey(Self.span(slide, 0.3, 0.6)))
        }
        var ink = [Bool](repeating: false, count: w * h), bright = [Double](repeating: 0, count: w * h)
        for i in 0..<(w * h) where title.buf[i * 4 + 3] > 127 {
            ink[i] = true; bright[i] = Double(title.buf[i * 4]) / 255
        }
        let inside = hawkinsChamfer(ink.map { !$0 }, w, h, nil).d       // how deep into a stroke (3 a pixel)
        let (outside, near) = hawkinsChamfer(ink, w, h, bright)         // how far from one, and how bright it is

        // The camera: pulled in close at first and drawing back about the middle; then pushing into the D's counter,
        // which drifts to the middle of the picture as it comes, till the counter is wider than the whole frame.
        let d = letters.last(where: { $0.ch == "D" })!
        let hole = (x: Double(d.x + p), y: Double(d.y + p), w: Double(p), h: Double(3 * p))
        let mid = (x: Double(w) / 2, y: Double(h) / 2)
        let pivot = push > 0 ? (x: hole.x + hole.w / 2, y: hole.y + hole.h / 2) : mid
        let far = max(Double(w) / hole.w, Double(h) / hole.h) * 1.6
        let s = push > 0 ? exp(log(far) * min(1, pow(push, 1.3) * 1.12)) : 1 + 0.9 * (1 - Self.ease(slide))
        let toward = Self.ease(push)
        let anchor = (x: pivot.x + (mid.x - pivot.x) * toward, y: pivot.y + (mid.y - pivot.y) * toward)
        func seen(_ x: Int, _ y: Int) -> (u: Double, v: Double) {
            (pivot.x + (Double(x) + 0.5 - anchor.x) / s, pivot.y + (Double(y) + 0.5 - anchor.y) / s)
        }

        // The old place going dark, and through the counter, once the camera heads for it, the new one.
        ctx.drawShot(old, in: r)
        Self.wash(ctx, 0x000000, dark, in: r)
        if push > 0 {
            let through = art.runs { x, y in
                let q = seen(x, y)
                return q.u >= hole.x && q.u < hole.x + hole.w && q.v >= hole.y && q.v < hole.y + hole.h
            }
            if !through.isEmpty {
                ctx.saveGState()
                ctx.clip(to: through)
                ctx.drawShot(new, in: r)
                Self.wash(ctx, 0x000000, 0.75 * (1 - Self.span(push, 0, 0.75)), in: r)
                ctx.restoreGState()
            }
        }

        // The neon, sampled through the camera: the tube's rim red, its core hot, dim inside it, and the glow round
        // it, swelling as the letters lock and fading as the camera goes through.
        let tube = max(6, Double(p) * 1.5)                              // the tube's depth, in thirds of a pixel
        let reach = Double(p) * (4.5 + 2.4 * swell) * (1 - Self.span(push, 0.05, 0.4))
        let rim = 0xD81E1A as UInt32, hot = 0xFFC2B0 as UInt32
        for y in 0..<h {
            for x in 0..<w {
                let q = seen(x, y)
                let u = Int(q.u.rounded(.down)), v = Int(q.v.rounded(.down))
                guard u >= 0, v >= 0, u < w, v < h else { continue }
                let i = v * w + u
                if ink[i] {
                    let deep = Double(inside[i]), b = bright[i]
                    if deep <= tube {
                        let f = 1 - min(1, abs((deep - 3) / (tube - 3) - 0.5) * 2)
                        c.px(x, y, Self.mix(rim, hot, f * (0.55 + 0.45 * swell), b))
                    } else {
                        c.px(x, y, C(0x6A0C10, b))
                    }
                } else if reach > 0, Double(outside[i]) < reach * 3 {
                    let a = (1 - Double(outside[i]) / (reach * 3)) * near[i]
                    let stepped = (a * 6).rounded(.up) / 6 * (0.45 + 0.2 * swell)
                    if stepped > 0 { c.px(x, y, C(0xC0141A, stepped)) }
                }
            }
        }

        // The grain: a scatter of faint specks over the dark, changing about 24 times a second.
        let frame = Int(k * 66)
        let grain = dark * (1 - push)
        if grain > 0 {
            for y in 0..<h {
                for x in 0..<w where noise(x * 7919 + y * 104729 + frame * 15485863 & 0xFFFFFF) > 0.985 {
                    c.px(x, y, C(0x8A94A8, 0.14 * grain))
                }
            }
        }
        art.show(ctx)
    }
}

/// How far every pixel of a `w`×`h` grid is from the nearest `seed` one, in thirds of a pixel (3 straight across, 4
/// on the diagonal, so the distances come out roughly round), and, if `value` is given, that nearest seed's value.
private func hawkinsChamfer(_ seed: [Bool], _ w: Int, _ h: Int, _ value: [Double]?) -> (d: [Int], v: [Double]) {
    let far = Int.max / 4
    var d = seed.map { $0 ? 0 : far }
    var v = value ?? []
    func step(_ i: Int, _ x: Int, _ y: Int, _ cost: Int) {
        guard x >= 0, y >= 0, x < w, y < h else { return }
        let j = y * w + x
        if d[j] + cost < d[i] { d[i] = d[j] + cost; if value != nil { v[i] = v[j] } }
    }
    for y in 0..<h {
        for x in 0..<w {
            let i = y * w + x
            step(i, x - 1, y, 3); step(i, x - 1, y - 1, 4); step(i, x, y - 1, 3); step(i, x + 1, y - 1, 4)
        }
    }
    for y in stride(from: h - 1, through: 0, by: -1) {
        for x in stride(from: w - 1, through: 0, by: -1) {
            let i = y * w + x
            step(i, x + 1, y, 3); step(i, x + 1, y + 1, 4); step(i, x, y + 1, 3); step(i, x - 1, y + 1, 4)
        }
    }
    return (d, v)
}
