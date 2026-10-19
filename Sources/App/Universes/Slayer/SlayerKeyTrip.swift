import CoreGraphics
import Foundation

// The Key (`SlayerWipe.key`): green energy coils in, the tower's portal tears open in green-white light, and the new
// place is seen through it before it closes.

extension SlayerTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. A storm-green gloom settles on the old
    /// place as three ribbons of the Key's green energy spiral in from the edges to a point above the middle (0–0.32);
    /// there the portal tears open, a thin slit splitting into a tall lens of green-white light like the one over Glory's
    /// tower, bolts crackling off it (0.26–0.46); the light at its heart clears and the new place is seen through it
    /// (0.36–0.52); the tear widens past the edges of the frame, so the view goes through (0.5–0.8); and behind it the
    /// last of the portal, a bright slit, snaps shut with a flash (0.8–0.96). The places are drawn as they are; the
    /// energy, the light and the tear's ragged edge are pixel art, drawn into a bitmap about 180 pixels tall and scaled
    /// up without smoothing, with a little grain.
    func drawKey(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.drawShot(old, in: r); return }
        guard k < 1 else { ctx.drawShot(new, in: r); return }
        let px: CGFloat = max(1, (r.height / 180).rounded())
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = Self.artCanvas(width: w, height: h, px: px, in: r) else {
            Self.crossfade(ctx, old: old, new: new, k: k, in: r); return
        }
        art.translateBy(x: r.minX, y: r.minY); art.scaleBy(x: px, y: px)  // the art's own pixels, from the bottom left
        let W = r.width / px, H = r.height / px
        let cx = (W / 2).rounded(), cy = (H * 0.56).rounded()
        let unit = max(1, (H / 90).rounded())
        let open = CGFloat(Self.ease(Self.span(k, 0.28, 0.46)))
        let reveal = CGFloat(Self.ease(Self.span(k, 0.38, 0.54)))
        let widen = CGFloat(pow(Self.ease(Self.span(k, 0.5, 0.8)), 1.6))
        let storm = CGFloat(Self.span(k, 0, 0.25)) * (1 - widen)
        let through = k >= 0.8                                       // the tear is past the edges: all new place

        // The tear: a slit splitting into a pointed lens, then widening past the frame. Its edge is ragged, flickering.
        // Widening, the lens keeps its tall pointed shape and grows as a whole, just far enough that its sides clear
        // the frame's edges, so in a short strip it doesn't squash into a wide oval.
        let a = W / 2 / (H * 0.114) + 1, b = max(cy, H - cy) / (H * 0.36)
        let grow = 1 + ((a + (a * a + 4 * b * b).squareRoot()) / 2 * 1.08 - 1) * widen
        let rx = (H * 0.004 + H * 0.11 * open) * grow
        let ry = (H * 0.03 * CGFloat(Self.span(k, 0.24, 0.3)) + H * 0.33 * open) * grow
        var rows: [(y: CGFloat, x0: CGFloat, x1: CGFloat)] = []
        if !through && ry > 0.5 {
            let f = Int(k * 24) * 131
            for j in 0..<h {
                let y = CGFloat(j) + 0.5
                let d = (y - cy) / ry
                guard abs(d) < 1 else { continue }
                let rag = (CGFloat(noise(j / 2 * 7 + f)) - 0.5) * 3 * unit * min(1, rx / (6 * unit))
                let half = (rx * (1 - d * d) + rag).rounded()
                guard half >= 1 else { continue }
                rows.append((CGFloat(j), cx - half, cx + half))
            }
        }

        // The places: the old one round the tear, the new one through it.
        ctx.drawShot(through ? new : old, in: r)
        if !through && reveal > 0 && !rows.isEmpty {
            ctx.saveGState()
            ctx.clip(to: rows.map { CGRect(x: r.minX + $0.x0 * px, y: r.minY + $0.y * px, width: ($0.x1 - $0.x0) * px, height: px) })
            ctx.drawShot(new, in: r)
            ctx.restoreGState()
        }

        // The storm gloom on the old place, and the tear's glow spilling round it.
        if !through {
            if storm > 0 {
                art.setFillColor(rgb(0x061408, 0.5 * storm)); art.fill(CGRect(x: 0, y: 0, width: W + 1, height: H + 1))
            }
            let halo = open * (1 - widen)
            if halo > 0 {
                for (m, a) in [(3.2 as CGFloat, 0.1 as CGFloat), (2.2, 0.14), (1.5, 0.18)] {
                    art.setFillColor(rgb(0xA8FF8A, a * halo))
                    art.fillEllipse(in: CGRect(x: (cx - rx * m - 6 * unit).rounded(), y: (cy - ry - 8 * unit * m).rounded(),
                                               width: (2 * rx * m + 12 * unit).rounded(), height: (2 * ry + 16 * unit * m).rounded()))
                }
            }
            // The hole itself cleared of all that, then filled with light that fades as the new place shows through.
            art.saveGState()
            art.setBlendMode(.clear)
            art.fill(rows.map { CGRect(x: $0.x0, y: $0.y, width: $0.x1 - $0.x0, height: 1) })
            art.restoreGState()
            if reveal < 1 {
                art.setFillColor(rgb(0xF0FFE8, 1 - reveal))
                art.fill(rows.map { CGRect(x: $0.x0, y: $0.y, width: $0.x1 - $0.x0, height: 1) })
            }
            // Its edge: white, green, a darker green rim, and green light glowing in from the edge on the new place.
            let inner = max(1, ((3 + 4 * (1 - reveal)) * unit).rounded())
            var lip: [CGRect] = [], white: [CGRect] = [], green: [CGRect] = [], rim: [CGRect] = []
            for row in rows {
                let span = row.x1 - row.x0
                let i = min(inner, span / 2)
                lip += [CGRect(x: row.x0, y: row.y, width: i, height: 1), CGRect(x: row.x1 - i, y: row.y, width: i, height: 1)]
                white += [CGRect(x: row.x0 - unit, y: row.y, width: unit, height: 1), CGRect(x: row.x1, y: row.y, width: unit, height: 1)]
                green += [CGRect(x: row.x0 - 3 * unit, y: row.y, width: 2 * unit, height: 1),
                          CGRect(x: row.x1 + unit, y: row.y, width: 2 * unit, height: 1)]
                rim += [CGRect(x: row.x0 - 4 * unit, y: row.y, width: unit, height: 1), CGRect(x: row.x1 + 3 * unit, y: row.y, width: unit, height: 1)]
            }
            art.setFillColor(rgb(0xC8FFB0, 0.55)); art.fill(lip)
            art.setFillColor(rgb(0xF0FFE8)); art.fill(white)
            art.setFillColor(rgb(0x9AF07A)); art.fill(green)
            art.setFillColor(rgb(0x3A9A2A, 0.8)); art.fill(rim)
            // Its two points, sharp white sparks above and below.
            if open > 0 && widen < 0.3 {
                art.setFillColor(rgb(0xF0FFE8, 1 - widen / 0.3))
                art.fill(CGRect(x: cx - unit / 2, y: (cy + ry).rounded(), width: unit, height: (4 * unit * open).rounded()))
                art.fill(CGRect(x: cx - unit / 2, y: (cy - ry - 4 * unit * open).rounded(), width: unit, height: (4 * unit * open).rounded()))
            }
        }

        // The Key's energy spiralling in: three ribbons of sparks, white at the head, green along the tail.
        let coil = CGFloat(Self.span(k, 0, 0.12)) * (1 - CGFloat(Self.span(k, 0.4, 0.56)))
        if coil > 0 {
            let reach = (W * W + H * H).squareRoot() * 0.55
            let head = CGFloat(Self.span(k, 0, 0.34)) * 1.25
            let f = Int(k * 30)
            for arm in 0..<3 {
                for i in 0..<48 {
                    let u = head - CGFloat(i) * 0.011 - CGFloat(arm) * 0.03
                    guard u > 0, u < 1 else { continue }
                    let rad = reach * pow(1 - u, 1.35) + rx * 1.2
                    let a = Double(arm) * 2 * .pi / 3 + 6.5 * Double(u) + k * 3
                    let jitter = (CGFloat(noise(arm * 300 + i * 3 + f * 17)) - 0.5) * 2 * unit
                    let x = cx + rad * CGFloat(cos(a)) + jitter, y = cy + rad * CGFloat(sin(a)) * 0.8 + jitter
                    let hex: UInt32 = i < 3 ? 0xFFFFFF : (i < 12 ? 0xE8FFD8 : (i < 28 ? 0x9AF07A : 0x4ABA3A))
                    let s = (i < 3 ? 3 : (i < 16 ? 2 : 1)) * unit
                    art.setFillColor(rgb(0x9AF07A, 0.25 * coil * (1 - CGFloat(i) / 48)))
                    art.fill(CGRect(x: (x - s).rounded(), y: (y - s).rounded(), width: 3 * s, height: 3 * s))
                    art.setFillColor(rgb(hex, coil * (1 - CGFloat(i) / 60)))
                    art.fill(CGRect(x: (x - s / 2).rounded(), y: (y - s / 2).rounded(), width: s, height: s))
                }
            }
        }

        // Bolts forking off the tear while it's open, and lightning flickering over the storm.
        let crackle = CGFloat(Self.span(k, 0.22, 0.3)) * (1 - CGFloat(Self.span(k, 0.66, 0.8)))
        if crackle > 0 && !rows.isEmpty {
            let f = Int(k * 20)
            art.setLineWidth(unit); art.setLineCap(.square)
            for b in 0..<4 {
                let seed = f * 41 + b * 97
                let side: CGFloat = noise(seed) < 0.5 ? -1 : 1
                let along = (CGFloat(noise(seed + 1)) - 0.5) * 1.4
                let d = along
                var x = cx + side * rx * (1 - d * d) * 0.95, y = cy + d * ry
                let ang = Double(side > 0 ? 0 : CGFloat.pi) + (noise(seed + 2) - 0.5) * 1.6
                var pts = [CGPoint(x: x, y: y)]
                let reach = H * 0.012 + ry * 0.1
                for q in 0..<5 {
                    x += CGFloat(cos(ang)) * reach + (CGFloat(noise(seed + q + 3)) - 0.5) * reach * 1.2
                    y += CGFloat(sin(ang)) * reach + (CGFloat(noise(seed + q + 11)) - 0.5) * reach * 1.2
                    pts.append(CGPoint(x: x.rounded(), y: y.rounded()))
                }
                art.setStrokeColor(rgb(0x9AF07A, 0.5 * crackle)); art.setLineWidth(3 * unit)
                art.addLines(between: pts); art.strokePath()
                art.setStrokeColor(rgb(0xF0FFE8, 0.95 * crackle)); art.setLineWidth(unit)
                art.addLines(between: pts); art.strokePath()
            }
        }
        if storm > 0, Self.span(k, 0.14, 0.17) > 0, Self.span(k, 0.14, 0.17) < 1 {
            art.setFillColor(rgb(0xE8FFE0, 0.12)); art.fill(CGRect(x: 0, y: 0, width: W + 1, height: H + 1))
        }

        // Through: the last of the portal, a slit of green-white light hanging high in the air over the new place, like
        // the one over Glory's tower and clear of the crew's heads, snaps shut with a flash.
        if through {
            let cy = (H * 0.8).rounded()
            let shut = CGFloat(Self.ease(Self.span(k, 0.8, 0.94)))
            let flash = CGFloat(1 - Self.span(k, 0.8, 0.9))
            art.setFillColor(rgb(0xE8FFD8, 0.5 * flash * flash)); art.fill(CGRect(x: 0, y: 0, width: W + 1, height: H + 1))
            let sh = H * 0.3 * (1 - shut), sw = max(unit, (H * 0.05 * (1 - shut) * (1 - shut)).rounded())
            if sh > 1 {
                for (m, hex, a) in [(5 as CGFloat, 0x9AF07A as UInt32, 0.25 as CGFloat), (2.5, 0xA8FF8A, 0.5), (1, 0xF0FFE8, 1)] {
                    art.setFillColor(rgb(hex, a))
                    art.fillEllipse(in: CGRect(x: (cx - sw * m / 2).rounded(), y: (cy - sh / 2).rounded(), width: (sw * m).rounded(), height: sh.rounded()))
                }
            }
            // Sparks flung off as it closes, fading.
            let fly = CGFloat(Self.span(k, 0.84, 1))
            if fly > 0 && fly < 1 {
                for i in 0..<16 {
                    let a = Double(i) / 16 * 2 * .pi + noise(i + 500)
                    let dist = H * (0.08 + 0.4 * fly) * (0.6 + 0.6 * CGFloat(noise(i + 520)))
                    art.setFillColor(rgb(i % 2 == 0 ? 0xF0FFE8 : 0x9AF07A, 1 - fly))
                    art.fill(CGRect(x: (cx + CGFloat(cos(a)) * dist).rounded(), y: (cy + CGFloat(sin(a)) * dist * 0.7).rounded(),
                                    width: unit, height: unit))
                }
            }
        }
        keyGrain(art, k: k, W: W, H: H, amount: through ? 1 - CGFloat(Self.span(k, 0.85, 1)) : 1)
        Self.blit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }
}

/// A little film grain over the night, changing every frame or two.
private func keyGrain(_ art: CGContext, k: Double, W: CGFloat, H: CGFloat, amount: CGFloat) {
    guard amount > 0 else { return }
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
