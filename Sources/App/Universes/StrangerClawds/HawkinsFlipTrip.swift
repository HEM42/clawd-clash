import CoreGraphics
import Foundation

// The Flip (`HawkinsWipe.flip`): the old place turns into its own Upside Down. Its colour drains to the cold
// blue-grey, vines creep in over it from the edges, spores rise through the air, and then it splits down the middle
// like a membrane, strands stretching across the gap and snapping, onto the new place. (Nothing to do with the Upside
// Down's own surprise: this is a trip into a place, any place.)

extension HawkinsTrip {
    /// A frame `k` (0…1) of the Flip, over the whole of `r`. The old place drains to blue-grey and darkens (0–0.35);
    /// vines creep in from the edges, branching, and spores drift up (0.1–0.6); it tears down the middle along a
    /// wavering seam, the two halves pulling apart with a raw rim along each edge and strands of membrane across the
    /// gap that stretch and snap one by one, the new place behind (0.55–1). The vines, spores, rims and strands are
    /// pixel art; the place itself is drawn as it is, tinted.
    func drawFlip(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let art = HawkinsArt(r)
        let w = art.w, h = art.h
        let drain = Self.ease(Self.span(k, 0, 0.35))
        let creep = Self.ease(Self.span(k, 0.1, 0.6))
        let split = Self.span(k, 0.55, 1)
        let gap = Int((pow(split, 1.7) * Double(w) * 1.08).rounded())

        // The old place as the Upside Down would have it, its vines on it, as one sheet to tear.
        let vines = HawkinsArt(r)
        hawkinsFlipVines(vines.c, creep: creep, k: k)
        let sheet = CGContext(data: nil, width: Int(r.width), height: Int(r.height), bitsPerComponent: 8, bytesPerRow: 0,
                              space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        let local = CGRect(x: 0, y: 0, width: r.width, height: r.height)
        sheet?.interpolationQuality = .none
        sheet?.drawShot(old, in: local)
        if drain > 0, let s = sheet {
            let d = CGFloat((drain * 6).rounded() / 6)
            s.setBlendMode(.color); s.setFillColor(rgb(0x5A6A82, d)); s.fill(local)
            s.setBlendMode(.multiply); s.setFillColor(rgb(0x5E6A82, d * 0.85)); s.fill(local)
            s.setBlendMode(.normal)
        }
        if let img = vines.c.makeImage() {
            sheet?.draw(img, in: CGRect(x: 0, y: local.maxY - CGFloat(vines.h) * vines.px, width: CGFloat(vines.w) * vines.px,
                                        height: CGFloat(vines.h) * vines.px))
        }
        guard let torn = sheet?.makeImage() else { ctx.drawShot(old, in: r); return }

        // The seam it tears along: wavering down the middle.
        let cx = Double(w) / 2
        let seam = (0..<h).map { y in Int((cx + sin(Double(y) * 0.13 + 1.7) * 4 + (noise(y * 7 + 3) - 0.5) * 2).rounded()) }
        let c = art.c
        if gap <= 0 {
            ctx.draw(torn, in: r)
        } else {
            ctx.drawShot(new, in: r)
            let half = gap / 2, other = gap - half
            for (side, shift) in [(-1, -half), (1, other)] {
                let keep = art.runs { x, y in side < 0 ? x < seam[y] + shift : x >= seam[y] + shift }
                guard !keep.isEmpty else { continue }
                ctx.saveGState()
                ctx.clip(to: keep)
                ctx.draw(torn, in: r.offsetBy(dx: CGFloat(shift) * art.px, dy: 0))
                ctx.restoreGState()
            }
            // Each torn edge: a raw, wet rim, dark outside, pink-grey and lit along it.
            let rimDark = C(0x3A2230), rim = C(0x9A7484), rimLit = C(0xC8A0AC)
            for y in 0..<h {
                let l = seam[y] - half, rr = seam[y] + other
                c.px(l, y, rimDark); c.px(l - 1, y, rim); c.px(l - 2, y, rimLit.alpha(0.8)); c.px(l - 3, y, rim.alpha(0.5))
                c.px(rr - 1, y, rimDark); c.px(rr, y, rim); c.px(rr + 1, y, rimLit.alpha(0.8)); c.px(rr + 2, y, rim.alpha(0.5))
            }
            // Strands of membrane across the gap, sagging as they stretch; each snaps at its own width and the two
            // ends spring back.
            let strand = C(0xB08894), strandD = C(0x6A4454)
            for i in 0..<9 {
                let y = Int(Double(h) * (0.08 + 0.84 * (Double(i) + noise(i * 11) * 0.6) / 9))
                let snap = Double(w) * (0.05 + 0.2 * noise(i * 11 + 5))
                let l = seam[y] - half, rr = seam[y] + other
                if Double(gap) < snap {
                    let sag = Double(gap) * 0.18
                    for x in l...rr {
                        let u = Double(x - l) / Double(max(1, rr - l))
                        let yy = y + Int((sin(u * .pi) * sag).rounded())
                        c.px(x, yy, strand); c.px(x, yy + 1, strandD)
                    }
                } else {
                    let back = Int(max(1, 6 - (Double(gap) - snap) * 0.2))
                    for d in 0..<back {
                        c.px(l + d, y + d / 2, strand); c.px(rr - d, y + d / 2, strand)
                    }
                }
            }
        }

        // Spores, rising through all of it.
        let spores = Self.span(k, 0.12, 0.3) * (1 - Self.span(k, 0.85, 1))
        if spores > 0 {
            for i in 0..<70 {
                let speed = 0.4 + noise(i * 7 + 1) * 0.8
                let up = (noise(i * 7 + 2) + k * speed).truncatingRemainder(dividingBy: 1)
                let x = Int(noise(i * 7 + 3) * Double(w) + sin(k * 6 + Double(i)) * 3)
                let y = h - Int(up * Double(h + 4))
                let big = noise(i * 7 + 4) > 0.8
                let col = C(i % 4 == 0 ? 0xF4F6FA : 0xC8D0E0, spores * (0.6 + 0.4 * noise(i * 7 + 5)))
                c.px(x, y, col)
                if big { c.rect(x - 1, y - 1, 3, 3, col.alpha(0.25)); c.px(x + 1, y, col); c.px(x, y + 1, col.alpha(0.7)) }
            }
        }
        art.show(ctx)
    }

    /// The Upside Down's vines creeping in from the edges, `creep` (0…1) of the way, onto a clear canvas: thick dark
    /// runners that wander in, lit along their tops, thinning towards their tips, with short tendrils off them.
    private func hawkinsFlipVines(_ c: PixelCanvas, creep: Double, k: Double) {
        guard creep > 0 else { return }
        let w = c.w, h = c.h
        let vine = C(0x2A2028), vineL = C(0x4E4250), vineD = C(0x161016)
        let reach = Double(min(w, h * 3)) * 0.42
        for i in 0..<16 {
            // Where it starts: along the bottom, the sides or the top, and which way it heads in.
            var x: Double, y: Double, a: Double
            switch i % 4 {
            case 0: x = noise(i * 13) * Double(w); y = Double(h); a = -.pi / 2
            case 1: x = 0; y = noise(i * 13) * Double(h); a = 0
            case 2: x = Double(w); y = noise(i * 13) * Double(h); a = .pi
            default: x = noise(i * 13) * Double(w); y = 0; a = .pi / 2
            }
            a += (noise(i * 13 + 1) - 0.5) * 0.9
            let len = reach * (0.5 + 0.5 * noise(i * 13 + 2)) * creep
            let thick = (i % 3 == 0 ? 3 : 2) + (h > 140 ? 1 : 0)
            var d = 0.0
            while d < len {
                a += (noise(i * 977 + Int(d)) - 0.5) * 0.35
                x += cos(a); y += sin(a)
                let t = d / max(1, reach)
                let th = t < 0.45 ? thick : t < 0.8 ? max(1, thick - 1) : 1
                let ix = Int(x.rounded()), iy = Int(y.rounded())
                c.rect(ix, iy, th, th, vine)
                c.px(ix, iy - 1, vineL)
                if th > 1 { c.px(ix + th - 1, iy + th, vineD) }
                // A short tendril now and then, curling off to one side.
                if Int(d) % 9 == 4 && d + 6 < len {
                    let s = noise(i * 31 + Int(d)) > 0.5 ? 1.0 : -1.0
                    for e in 1...4 { c.px(ix + Int((cos(a + s * 1.2) * Double(e)).rounded()), iy + Int((sin(a + s * 1.2) * Double(e)).rounded()), vine) }
                }
                d += 1
            }
        }
    }
}
