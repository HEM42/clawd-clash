import CoreGraphics
import Foundation

// The Sandworm (`BurtonWipe.sandworm`): the floor ripples, the striped sandworm bursts up and swallows the picture,
// then dives, and the new place is left in its wake under settling sand.

extension BurtonTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. Something swims under the floor of
    /// the old place: a hump of pale Saturn sand runs in from the right, its striped back breaking the surface for a
    /// moment, and the picture shudders (0–0.24); the sandworm bursts up out of a hole in the middle of the floor in
    /// a spray of sand, its black-and-white banded body rearing in an S, its blunt black head up (0.2–0.36); it
    /// lunges at us, its jaws opening on a red mouth ringed with teeth and the pink inner mouth shooting out, until
    /// its throat fills the screen (0.34–0.52); in the dark it turns, and as the dark lifts it is diving head first
    /// out of the top of the new place into the hole, the bands sliding down past, its tail last (0.52–0.8); sand
    /// bursts up where it went in and drifts down over the new place, and the hole fills in (0.62–0.97). All of it
    /// pixel art on the art's own grid.
    func drawSandworm(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.draw(old, in: r); return }
        guard k < 1 else { ctx.draw(new, in: r); return }
        let (c, px) = Self.pixelCanvas(in: r)
        let W = Double(c.w), H = Double(c.h)
        let hx = (W * 0.5).rounded(), hy = (H * 0.92).rounded(), rh = max(6, H * 0.13)
        let swallowed = k >= 0.52

        // The picture: the old place shuddering as the worm comes, the new one once it has been swallowed.
        let quake = Self.span(k, 0.04, 0.2) * (1 - Self.span(k, 0.36, 0.46))
            + 0.6 * Self.span(k, 0.6, 0.63) * (1 - Self.span(k, 0.63, 0.74))
        let f = Int(k * 2.4 * 30)
        let shake = CGPoint(x: ((noise(f * 5 + 11) * 2 - 1) * quake * 1.6).rounded() * px,
                            y: ((noise(f * 5 + 12) * 2 - 1) * quake * 1.2).rounded() * px)
        ctx.saveGState(); ctx.clip(to: r)
        ctx.setFillColor(rgb(0x1A120A)); ctx.fill(r)
        ctx.draw(swallowed ? new : old, in: r.offsetBy(dx: shake.x, dy: shake.y))
        // The sand haze settling over the new place.
        let haze = Self.span(k, 0.6, 0.66) * (1 - Self.ease(Self.span(k, 0.68, 0.95)))
        if haze > 0.01 { ctx.setFillColor(rgb(0xE3C98A, CGFloat(0.42 * haze))); ctx.fill(r) }
        ctx.restoreGState()

        let sandLit = C(0xF0DCA4), sand = C(0xE3C98A), sandShade = C(0xC4A060), hole = C(0x1A120A)
        let dy = Double(shake.y / px), dx = Double(shake.x / px)

        // The hump running in under the floor, the sand rippling out round it in rings it leaves behind.
        let run = Self.ease(Self.span(k, 0.0, 0.22))
        if k < 0.26 {
            let bx = W + rh * 2 - (W + rh * 2 - hx) * run, grow = Self.span(k, 0, 0.06) * (1 - Self.span(k, 0.2, 0.26))
            let fy = H * 0.9 + dy
            for i in 0..<5 {                            // ripples: rings left where the hump was, spreading
                let age = frac(k * 9 + Double(i) / 5), at = bx + age * (W + rh * 2 - hx) * 0.12
                let rx = rh * (0.9 + 2.2 * age), ry = rh * (0.25 + 0.3 * age)
                sandwormRipple(c, x: at + dx, y: fy, rx: rx, ry: ry, lit: sandLit.alpha((1 - age) * grow),
                               dark: C(0x8A6A34).alpha((1 - age) * grow * 0.8))
            }
            if grow > 0.05 {
                let rx = rh * 1.3, ry = rh * 0.5 * grow
                sandwormMound(c, x: bx + dx, y: fy + 1, rx: rx + 1, ry: ry + 1, C(0x8A6A34), ridge: C(0x8A6A34))
                sandwormMound(c, x: bx + dx, y: fy, rx: rx, ry: ry, sand, ridge: sandLit)
                sandwormMound(c, x: bx + dx - rx * 0.25, y: fy - ry * 0.35, rx: rx * 0.45, ry: ry * 0.5, sandLit,
                              ridge: sandLit)
                // The worm's striped back breaking the surface for a moment and going under again.
                let peek = sin(Self.span(k, 0.05, 0.19) * .pi)
                if peek > 0.05 {
                    for j in 0..<9 {
                        let a0 = .pi * Double(j) / 9, a1 = .pi * Double(j + 1) / 9
                        let p0 = (bx + dx + cos(a0) * rx * 0.6, fy - ry * 0.6 - sin(a0) * rh * 0.6 * peek)
                        let p1 = (bx + dx + cos(a1) * rx * 0.6, fy - ry * 0.6 - sin(a1) * rh * 0.6 * peek)
                        burtonLine(c, p0.0, p0.1, p1.0, p1.1, j % 2 == 0 ? burtonInk : burtonBone, max(1, rh * 0.2))
                    }
                    sandwormMound(c, x: bx + dx, y: fy + 1, rx: rx * 0.9, ry: ry * 0.45, sand, ridge: sandLit)
                }
            }
            for i in 0..<14 where grow > 0.3 {          // grains spitting off the hump
                let age = frac(noise(i * 7 + 300) + k * 6)
                let x = bx + (noise(i * 7 + 301) - 0.3) * rh * 2, y = fy - rh * 0.5 - sin(age * .pi) * rh * 0.7
                c.rect(Int(x + dx), Int(y), 1, 1, (i % 2 == 0 ? sandLit : sandShade).alpha(1 - age))
            }
        }

        // The worm. Rearing: from the hole up to its head; lunging: the head coming at us; diving: from the top down.
        let rise = Self.ease(Self.span(k, 0.19, 0.34)), lunge = Self.span(k, 0.34, 0.52)
        let dive = Self.span(k, 0.54, 0.74), tail = Self.span(k, 0.62, 0.82)
        let holeOpen = Self.span(k, 0.18, 0.22) * (1 - Self.span(k, 0.82, 0.94))
        if holeOpen > 0 {
            c.ellipse(Int(hx + dx), Int(hy + dy), Int(rh * 1.5 * holeOpen), max(1, Int(rh * 0.3 * holeOpen)), hole)
        }
        if k >= 0.19 && k < 0.52 {
            let g = lunge * lunge
            let headR = rh * pow(sandwormHuge(W, H) / rh, g)
            let headY = hy + rh * 1.2 - (hy + rh * 1.2 - H * 0.4) * rise + (H * 0.5 - H * 0.4) * g
            let headX = hx + sin(k * 14) * rh * 0.15 * (1 - g)
            let open = min(1, 0.15 + 0.85 * Self.ease(Self.span(k, 0.33, 0.47)))
            if g < 0.6 {
                sandwormBody(c, x: headX + dx, from: headY, to: hy + dy, width: headR * 1.5, bandH: headR * 0.6,
                             phase: -rise * rh * 4, bend: rh * (0.8 * sin(k * 11) - 0.5) * (1 - g))
            }
            sandwormHead(c, x: headX + dx, y: headY + dy, r: headR, open: open, shoot: Self.span(k, 0.4, 0.5))
        } else if k >= 0.52 && k < 0.84 {
            let headY = -rh * 2 + (hy + rh * 3) * Self.ease(dive) * 1.05
            let tailY = -rh * 1.5 + (hy + rh * 1.5) * Self.ease(tail)
            if headY > -rh * 1.5 && tailY < hy {
                sandwormBody(c, x: hx + dx, from: tailY, to: min(headY, hy) + dy, width: rh * 1.5, bandH: rh * 0.6,
                             phase: headY, taper: true)
            }
            if headY < hy { sandwormHeadDown(c, x: hx + dx, y: headY + dy, r: rh) }
        }
        // The front lip of the hole, heaped round the worm.
        if holeOpen > 0 {
            sandwormMound(c, x: hx + dx, y: hy + rh * 0.12 + dy, rx: rh * 1.7 * holeOpen, ry: rh * 0.32 * holeOpen,
                          sand, ridge: sandLit, under: true)
        }

        // Sand flung up: as it bursts out, and as it plunges back in.
        for (start, count, seed) in [(0.19, 60, 0), (0.6, 80, 500)] {
            let t = k - start
            guard t > 0 && t < 0.3 else { continue }
            for i in 0..<count {
                let s = seed + i * 5
                let vx = (noise(s) - 0.5) * W * 0.9, vy = H * (0.9 + 1.4 * noise(s + 1))
                let tt = t * (0.8 + 0.6 * noise(s + 2))
                let x = hx + (noise(s + 3) - 0.5) * rh * 2 + vx * tt, y = hy - vy * tt + H * 4.5 * tt * tt
                guard y < hy + 2 else { continue }
                let col = [sandLit, sand, sandShade][i % 3]
                let size = noise(s + 4) < 0.3 ? 2 : 1
                c.rect(Int(x + dx), Int(y + dy), size, size, col.alpha(1 - Self.span(t, 0.18, 0.3)))
            }
        }

        // The sand settling: grains drifting down over the new place, thinning.
        let settle = Self.span(k, 0.62, 0.68) * (1 - Self.span(k, 0.8, 0.97))
        if settle > 0.01 {
            let n = Int(W * H / 70 * settle)
            for i in 0..<n {
                let fall = frac(noise(i * 3 + 900) + (k - 0.6) * (0.9 + noise(i * 3 + 901)) * 1.5)
                let x = noise(i * 3 + 902) * W + sin(k * 9 + Double(i)) * 1.5, y = fall * H
                c.rect(Int(x), Int(y), 1, 1, (i % 2 == 0 ? sand : sandLit).alpha(settle * 0.9))
            }
        }

        // Swallowed: the dark of its throat over everything, lifting as it turns to dive.
        let dark = Self.span(k, 0.49, 0.52) * (1 - Self.ease(Self.span(k, 0.54, 0.62)))
        Self.blitCanvas(c, onto: ctx, px: px, in: r)
        if dark > 0.01 {
            ctx.saveGState(); ctx.clip(to: r)
            ctx.setFillColor(rgb(0x2A0608, CGFloat(dark))); ctx.fill(r)
            ctx.restoreGState()
        }
    }

    /// A head big enough that its throat covers a `W`×`H` canvas when it reaches us.
    private func sandwormHuge(_ W: Double, _ H: Double) -> Double { (W * W + H * H).squareRoot() * 3.4 }

    /// A low heap of sand centred on (`x`, `y`): its top half (or, `under`, a heap whose top runs along `y` and spills
    /// below it), a lit ridge along the crest.
    private func sandwormMound(_ c: PixelCanvas, x: Double, y: Double, rx: Double, ry: Double, _ col: Px, ridge: Px,
                               under: Bool = false) {
        guard rx >= 1, ry >= 0.5 else { return }
        let x0 = Int((x - rx).rounded(.down)), x1 = Int((x + rx).rounded(.up))
        for xx in x0...x1 {
            let u = (Double(xx) + 0.5 - x) / rx
            guard abs(u) <= 1 else { continue }
            let hgt = ry * (1 - u * u).squareRoot()
            let top = Int((y - (under ? hgt * 0.5 : hgt)).rounded())
            let bottom = Int((under ? y + hgt * 1.4 : y).rounded())
            c.rect(xx, top, 1, max(1, bottom - top), col)
            c.px(xx, top, ridge)
        }
    }

    /// A ripple in the sand: the top of a ring round (`x`, `y`), `rx` by `ry`, a lit crest over a dark trough.
    private func sandwormRipple(_ c: PixelCanvas, x: Double, y: Double, rx: Double, ry: Double, lit: Px, dark: Px) {
        guard rx >= 1, ry >= 0.5, lit.a > 3 else { return }
        for xx in Int((x - rx).rounded(.down))...Int((x + rx).rounded(.up)) {
            let u = (Double(xx) + 0.5 - x) / rx
            guard abs(u) <= 1 else { continue }
            let top = Int((y - ry * (1 - u * u).squareRoot()).rounded())
            c.px(xx, top, lit); c.px(xx, top + 1, dark)
        }
    }

    /// The worm's body as a column centred on `x` from row `top` down to row `bottom`, `width` across, banded black and
    /// bone white every `bandH` rows (`phase` slides the bands along it); `taper` narrows its top into the tail.
    private func sandwormBody(_ c: PixelCanvas, x: Double, from top: Double, to bottom: Double, width: Double,
                              bandH: Double, phase: Double, taper: Bool = false, bend: Double = 0) {
        let y0 = max(0, Int(top.rounded(.down))), y1 = min(c.h, Int(bottom.rounded(.up)))
        guard y1 > y0, bandH > 0 else { return }
        for y in y0..<y1 {
            let along = Double(y) - top
            var half = width / 2
            if taper { half *= min(1, 0.3 + (along / (width * 0.8)).squareRoot() * 0.7) }
            let sway = sin((Double(y) - phase) / max(4, width * 2)) * width * 0.08
                + bend * sin(.pi * (Double(y) - top) / max(1, bottom - top))
            let band = Int(((Double(y) - phase) / bandH).rounded(.down)) & 1 == 0
            let x0 = Int((x + sway - half).rounded()), w = max(1, Int((half * 2).rounded()))
            c.rect(x0, y, w, 1, band ? burtonInk : burtonBone)
            c.px(x0, y, burtonInk); c.px(x0 + w - 1, y, burtonInk)
            if !band { c.rect(x0 + w - max(1, w / 6), y, max(1, w / 6), 1, C(0xC8C2B2)) }   // its shaded side
        }
    }

    /// The worm's blunt black head, seen from in front, centred on (`x`, `y`), radius `r`: its jaws `open` (0…1) on a
    /// red mouth ringed with teeth, the pink inner mouth inside shooting out (`shoot`) with its own teeth, and its
    /// dark throat; a bone band round its neck, two small orange eyes above the mouth.
    private func sandwormHead(_ c: PixelCanvas, x: Double, y: Double, r: Double, open: Double, shoot: Double) {
        let cx = Int(x.rounded()), cy = Int(y.rounded())
        sandwormDisc(c, x, y + r * 0.35, r * 0.92, burtonBone)                  // the bone band behind the head
        sandwormDisc(c, x, y + r * 0.42, r * 0.8, burtonInk)
        sandwormDisc(c, x, y, r, burtonInk)
        let rm = r * 0.8 * open, my = y + r * 0.08
        if rm >= 1 {
            sandwormDisc(c, x, my, rm, C(0xB8241E))
            sandwormDisc(c, x, my, rm * 0.86, C(0x8E1A16))
            sandwormTeeth(c, x, my, outer: rm, length: rm * 0.24, count: 14, C(0xF4F2EA), turn: 0)
            let ri = rm * (0.42 + 0.22 * Self.ease(shoot))
            sandwormDisc(c, x, my, ri, C(0xE88A8A))
            sandwormTeeth(c, x, my, outer: ri, length: ri * 0.3, count: 9, C(0xF4F2EA), turn: 0.5)
            sandwormDisc(c, x, my, ri * 0.5, C(0x3A0A0C))
        } else {
            c.rect(cx - Int(r * 0.4), cy + Int(r * 0.1), max(1, Int(r * 0.8)), 1, C(0x7A2A26))
        }
        if r < 60 {
            let ex = max(1, Int(r * 0.45)), ey = Int(y - r * (0.35 + 0.35 * open)), e = max(1, Int(r * 0.1))
            c.rect(cx - ex - e / 2, ey, e, e, C(0xFF9A2A)); c.rect(cx + ex - e / 2, ey, e, e, C(0xFF9A2A))
        }
    }

    /// The head from above as it dives: a blunt black snout pointing down, a bone band round the back, an orange eye
    /// either side, its jaws shut on a red seam.
    private func sandwormHeadDown(_ c: PixelCanvas, x: Double, y: Double, r: Double) {
        let w = r * 0.78
        for yy in Int((y - r * 1.3).rounded())...Int((y + r * 0.9).rounded()) {
            let v = Double(yy) - y
            let half = v < 0 ? w : w * (1 - v * v / (r * r * 0.81)).squareRoot()
            guard half > 0.5 else { continue }
            let band = v > -r * 1.1 && v < -r * 0.7
            c.rect(Int((x - half).rounded()), yy, max(1, Int((half * 2).rounded())), 1, band ? burtonBone : burtonInk)
        }
        c.rect(Int(x.rounded()), Int((y + r * 0.1).rounded()), 1, max(1, Int(r * 0.75)), C(0x7A2A26))
        let e = max(1, Int(r * 0.12))
        for side in [-1.0, 1.0] {
            c.rect(Int((x + side * w * 0.62).rounded()) - e / 2, Int((y - r * 0.3).rounded()), e, e, C(0xFF9A2A))
        }
    }

    /// A filled disc, clipped to the canvas first so a huge one costs no more than the canvas.
    private func sandwormDisc(_ c: PixelCanvas, _ x: Double, _ y: Double, _ r: Double, _ col: Px) {
        guard r > 0 else { return }
        let y0 = max(0, Int((y - r).rounded(.down))), y1 = min(c.h - 1, Int((y + r).rounded(.up)))
        guard y0 <= y1 else { return }
        for yy in y0...y1 {
            let d = Double(yy) + 0.5 - y
            guard abs(d) <= r else { continue }
            let half = (r * r - d * d).squareRoot()
            let x0 = max(-1, Int((x - half).rounded())), x1 = min(c.w + 1, Int((x + half).rounded()))
            if x1 > x0 { c.rect(x0, yy, x1 - x0, 1, col) }
        }
    }

    /// A ring of `count` teeth round the inside of a mouth of radius `outer`, each `length` long, pointing in.
    private func sandwormTeeth(_ c: PixelCanvas, _ x: Double, _ y: Double, outer: Double, length: Double, count: Int,
                               _ col: Px, turn: Double) {
        guard length >= 1 else { return }
        for i in 0..<count {
            let a = (Double(i) + turn) / Double(count) * 2 * .pi, half = .pi / Double(count) * 0.8
            let p1 = (x + cos(a - half) * outer, y + sin(a - half) * outer)
            let p2 = (x + cos(a + half) * outer, y + sin(a + half) * outer)
            let tip = (x + cos(a) * (outer - length), y + sin(a) * (outer - length))
            sandwormTriangle(c, p1, p2, tip, col)
        }
    }

    /// A filled triangle, a row at a time between its edges, clipped to the canvas (a huge one costs a canvas at most).
    private func sandwormTriangle(_ c: PixelCanvas, _ a: (Double, Double), _ b: (Double, Double), _ d: (Double, Double),
                                  _ col: Px) {
        let y0 = max(0, Int(min(a.1, b.1, d.1).rounded(.down))), y1 = min(c.h - 1, Int(max(a.1, b.1, d.1).rounded(.up)))
        guard y0 <= y1 else { return }
        let edges = [(a, b), (b, d), (d, a)]
        for y in y0...y1 {
            let yc = Double(y) + 0.5
            var lo = Double.infinity, hi = -Double.infinity
            for (p, q) in edges where (p.1 <= yc) != (q.1 <= yc) {
                let x = p.0 + (yc - p.1) / (q.1 - p.1) * (q.0 - p.0)
                lo = min(lo, x); hi = max(hi, x)
            }
            guard hi > lo else { continue }
            let x0 = max(-1, Int(lo.rounded())), x1 = min(c.w + 1, Int(hi.rounded()))
            if x1 > x0 { c.rect(x0, y, x1 - x0, 1, col) }
        }
    }
}
