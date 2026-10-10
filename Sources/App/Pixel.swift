import CoreGraphics
import Foundation

struct Px {
    var r: UInt8, g: UInt8, b: UInt8, a: UInt8
    func alpha(_ m: Double) -> Px { Px(r: r, g: g, b: b, a: UInt8(max(0, min(255, Double(a) * m)))) }
}

func C(_ hex: UInt32, _ a: Double = 1) -> Px {
    Px(r: UInt8((hex >> 16) & 0xFF), g: UInt8((hex >> 8) & 0xFF), b: UInt8(hex & 0xFF),
       a: UInt8(max(0, min(255, a * 255))))
}

/// Tiny RGBA framebuffer. Sprites are drawn here at 1 unit = 1 pixel, then scaled up
/// with nearest-neighbour so everything stays crisp pixel art.
final class PixelCanvas {
    let w: Int, h: Int
    private(set) var buf: [UInt8]   // premultiplied RGBA
    var ox = 0, oy = 0               // translation applied to every draw call

    init(_ w: Int, _ h: Int) {
        self.w = w; self.h = h
        buf = [UInt8](repeating: 0, count: w * h * 4)
    }

    func px(_ x: Int, _ y: Int, _ c: Px) {
        let x = x + ox, y = y + oy
        guard x >= 0, y >= 0, x < w, y < h, c.a > 0 else { return }
        let i = (y * w + x) * 4
        let sa = Double(c.a) / 255
        let inv = 1 - sa
        buf[i]     = UInt8(min(255, Double(c.r) * sa + Double(buf[i]) * inv))
        buf[i + 1] = UInt8(min(255, Double(c.g) * sa + Double(buf[i + 1]) * inv))
        buf[i + 2] = UInt8(min(255, Double(c.b) * sa + Double(buf[i + 2]) * inv))
        buf[i + 3] = UInt8(min(255, Double(c.a) + Double(buf[i + 3]) * inv))
    }

    func rect(_ x: Int, _ y: Int, _ w: Int, _ h: Int, _ c: Px) {
        guard w > 0, h > 0 else { return }
        for yy in y..<(y + h) { for xx in x..<(x + w) { px(xx, yy, c) } }
    }

    /// Draw string art. Each character maps to a colour in `palette`; anything else is transparent.
    func pattern(_ x: Int, _ y: Int, _ rows: [String], _ palette: [Character: Px], flip: Bool = false) {
        for (r, row) in rows.enumerated() {
            let chars = Array(row)
            for (c, ch) in chars.enumerated() {
                guard let col = palette[ch] else { continue }
                px(x + (flip ? chars.count - 1 - c : c), y + r, col)
            }
        }
    }

    /// Anti-aliased-but-pixelated glowing segment (lightsaber blades, blaster bolts).
    func glowLine(_ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double,
                  core: Px, glow: Px, coreR: Double = 0.75, glowR: Double = 2.4, strength: Double = 1) {
        let minX = Int(floor(min(x0, x1) - glowR)), maxX = Int(ceil(max(x0, x1) + glowR))
        let minY = Int(floor(min(y0, y1) - glowR)), maxY = Int(ceil(max(y0, y1) + glowR))
        let dx = x1 - x0, dy = y1 - y0
        let len2 = max(dx * dx + dy * dy, 0.0001)
        for y in minY...maxY {
            for x in minX...maxX {
                let cx = Double(x) + 0.5, cy = Double(y) + 0.5
                let t = max(0, min(1, ((cx - x0) * dx + (cy - y0) * dy) / len2))
                let ex = x0 + t * dx - cx, ey = y0 + t * dy - cy
                let d = sqrt(ex * ex + ey * ey)
                if d <= coreR {
                    px(x, y, core.alpha(strength))
                } else if d <= glowR {
                    let f = 1 - (d - coreR) / (glowR - coreR)
                    // Quantise the falloff so the glow stays chunky rather than smooth.
                    let q = (f * 3).rounded(.up) / 3
                    px(x, y, glow.alpha(q * 0.85 * strength))
                }
            }
        }
    }

    /// Mirror everything drawn so far, left to right.
    func flipHorizontally() {
        var out = buf
        for y in 0..<h {
            for x in 0..<w {
                let src = (y * w + x) * 4, dst = (y * w + (w - 1 - x)) * 4
                for k in 0..<4 { out[dst + k] = buf[src + k] }
            }
        }
        buf = out
    }

    /// 1px outline around every solid pixel, so dark sprites still read on a dark desktop.
    /// Only fully opaque pixels count as solid, so saber glows and bolts don't get outlined.
    func addOutline(_ c: Px) {
        let src = buf
        let a = Double(c.a) / 255
        for y in 0..<h {
            for x in 0..<w {
                let i = (y * w + x) * 4
                guard src[i + 3] <= 60 else { continue }
                var edge = false
                for (dx, dy) in [(1, 0), (-1, 0), (0, 1), (0, -1)] {
                    let nx = x + dx, ny = y + dy
                    if nx >= 0, ny >= 0, nx < w, ny < h, src[(ny * w + nx) * 4 + 3] >= 250 { edge = true; break }
                }
                guard edge else { continue }
                buf[i] = UInt8(min(255, Double(c.r) * a + Double(src[i]) * (1 - a)))
                buf[i + 1] = UInt8(min(255, Double(c.g) * a + Double(src[i + 1]) * (1 - a)))
                buf[i + 2] = UInt8(min(255, Double(c.b) * a + Double(src[i + 2]) * (1 - a)))
                buf[i + 3] = UInt8(min(255, Double(c.a) + Double(src[i + 3]) * (1 - a)))
            }
        }
    }

    func makeImage() -> CGImage? {
        let data = Data(buf) as CFData
        guard let provider = CGDataProvider(data: data) else { return nil }
        return CGImage(width: w, height: h, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: w * 4,
                       space: CGColorSpaceCreateDeviceRGB(),
                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                       provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
    }
}
