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
    var baseY = 0                    // extra vertical shift under `oy`: moves a whole sprite (hovering, meditating, a Dalick's Elevate)
                                     // whose drawing code sets `oy` itself

    init(_ w: Int, _ h: Int) {
        self.w = w; self.h = h
        buf = [UInt8](repeating: 0, count: w * h * 4)
    }

    func px(_ x: Int, _ y: Int, _ c: Px) {
        let x = x + ox, y = y + oy + baseY
        guard x >= 0, y >= 0, x < w, y < h, c.a > 0 else { return }
        let i = (y * w + x) * 4
        if c.a == 255 {   // opaque: what the blend below works out to exactly, without the arithmetic
            buf[i] = c.r; buf[i + 1] = c.g; buf[i + 2] = c.b; buf[i + 3] = 255
            return
        }
        let sa = Double(c.a) / 255
        let inv = 1 - sa
        buf[i]     = UInt8(min(255, Double(c.r) * sa + Double(buf[i]) * inv))
        buf[i + 1] = UInt8(min(255, Double(c.g) * sa + Double(buf[i + 1]) * inv))
        buf[i + 2] = UInt8(min(255, Double(c.b) * sa + Double(buf[i + 2]) * inv))
        buf[i + 3] = UInt8(min(255, Double(c.a) + Double(buf[i + 3]) * inv))
    }

    func rect(_ x: Int, _ y: Int, _ w: Int, _ h: Int, _ c: Px) {
        guard w > 0, h > 0 else { return }
        guard c.a == 255 else {
            for yy in y..<(y + h) { for xx in x..<(x + w) { px(xx, yy, c) } }
            return
        }
        // Opaque: clipped to the canvas once, then filled a whole pixel (4 bytes, little-endian RGBA) at a time.
        let x0 = max(0, x + ox), x1 = min(self.w, x + ox + w)
        let y0 = max(0, y + oy + baseY), y1 = min(self.h, y + oy + baseY + h)
        guard x0 < x1, y0 < y1 else { return }
        let word = UInt32(c.r) | UInt32(c.g) << 8 | UInt32(c.b) << 16 | 0xFF00_0000
        let stride = self.w
        buf.withUnsafeMutableBytes { raw in
            let p = raw.bindMemory(to: UInt32.self)
            for yy in y0..<y1 { for xx in x0..<x1 { p[yy * stride + xx] = word } }
        }
    }

    /// Draw string art. Each character maps to a colour in `palette`; anything else is transparent.
    /// Rows of plain ASCII (nearly all) are read byte by byte through a lookup table; walking a String's Characters
    /// and hashing each into the dictionary was most of the cost of drawing a sprite.
    func pattern(_ x: Int, _ y: Int, _ rows: [String], _ palette: [Character: Px]) {
        var table = [Px?](repeating: nil, count: 128)
        var asciiPalette = true
        for (k, v) in palette {
            if let a = k.asciiValue { table[Int(a)] = v } else { asciiPalette = false }
        }
        for (r, row) in rows.enumerated() {
            if row.utf8.allSatisfy({ $0 < 128 }) && asciiPalette {
                var c = 0
                for b in row.utf8 {
                    if let col = table[Int(b)] { px(x + c, y + r, col) }
                    c += 1
                }
            } else {
                for (c, ch) in row.enumerated() {
                    guard let col = palette[ch] else { continue }
                    px(x + c, y + r, col)
                }
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

    /// The smallest rectangle containing every visible pixel (canvas coordinates, y down).
    func opaqueBounds() -> CGRect? {
        var minX = w, minY = h, maxX = -1, maxY = -1
        for y in 0..<h {
            for x in 0..<w where buf[(y * w + x) * 4 + 3] > 24 {
                minX = min(minX, x); maxX = max(maxX, x); minY = min(minY, y); maxY = max(maxY, y)
            }
        }
        return maxX < 0 ? nil : CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
    }

    /// A copy turned by `degrees` about `pivot` (negative turns anticlockwise on screen: a right-facing sprite falls on
    /// its back), with `pivot` landing on `at` in a new `w` × `h` canvas. Nearest-neighbour, so it stays pixel art.
    func rotated(_ degrees: Double, about pivot: (x: Double, y: Double), into w: Int, _ h: Int,
                 at: (x: Double, y: Double)) -> PixelCanvas {
        let out = PixelCanvas(w, h)
        let r = degrees * .pi / 180, cs = cos(r), sn = sin(r)
        for y in 0..<h {
            for x in 0..<w {
                let dx = Double(x) + 0.5 - at.x, dy = Double(y) + 0.5 - at.y
                let sx = Int(floor(pivot.x + dx * cs + dy * sn)), sy = Int(floor(pivot.y - dx * sn + dy * cs))
                guard sx >= 0, sy >= 0, sx < self.w, sy < self.h else { continue }
                let si = (sy * self.w + sx) * 4, di = (y * w + x) * 4
                for k in 0..<4 { out.buf[di + k] = buf[si + k] }
            }
        }
        return out
    }

    /// A copy of just `rows` (the rest left empty).
    func onlyRows(_ rows: Range<Int>) -> PixelCanvas {
        let out = PixelCanvas(w, h)
        let r = max(0, rows.lowerBound)..<min(h, rows.upperBound)
        guard !r.isEmpty else { return out }
        out.buf.replaceSubrange(r.lowerBound * w * 4..<r.upperBound * w * 4, with: buf[r.lowerBound * w * 4..<r.upperBound * w * 4])
        return out
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

    /// Mirror everything drawn so far about the vertical line `x` (canvas units), unless something drawn would end up
    /// off the canvas, or something solid on its edge, where its outline would be cut. Returns whether it mirrored.
    @discardableResult
    func mirror(aboutX x: Double) -> Bool {
        let axis = Int((2 * x).rounded()) - 1          // column k lands on axis - k
        for y in 0..<h {
            for k in 0..<w where buf[(y * w + k) * 4 + 3] > 0 {
                let to = axis - k
                if to < 0 || to >= w || ((to == 0 || to == w - 1) && buf[(y * w + k) * 4 + 3] >= 250) { return false }
            }
        }
        var out = [UInt8](repeating: 0, count: buf.count)
        for y in 0..<h {
            for k in 0..<w where buf[(y * w + k) * 4 + 3] > 0 {
                let src = (y * w + k) * 4, dst = (y * w + axis - k) * 4
                for n in 0..<4 { out[dst + n] = buf[src + n] }
            }
        }
        buf = out
        return true
    }

    /// Draw `other` on top, its top-left corner at (`x`, `y`) (offsets apply as for any drawing).
    func paste(_ other: PixelCanvas, x: Int = 0, y: Int = 0) {
        for yy in 0..<other.h {
            for xx in 0..<other.w {
                let i = (yy * other.w + xx) * 4, a = other.buf[i + 3]
                guard a > 0 else { continue }
                let m = 255 / Double(a)                       // back from premultiplied
                px(x + xx, y + yy, Px(r: UInt8(min(255, Double(other.buf[i]) * m)), g: UInt8(min(255, Double(other.buf[i + 1]) * m)),
                                      b: UInt8(min(255, Double(other.buf[i + 2]) * m)), a: a))
            }
        }
    }

    /// Draw `other` on top, faded to `alpha`, its top-left corner at (`x`, `y`).
    func paste(_ other: PixelCanvas, x: Int = 0, y: Int = 0, alpha: Double) {
        for yy in 0..<other.h {
            for xx in 0..<other.w {
                let i = (yy * other.w + xx) * 4, a = other.buf[i + 3]
                guard a > 0 else { continue }
                let m = 255 / Double(a)
                px(x + xx, y + yy, Px(r: UInt8(min(255, Double(other.buf[i]) * m)), g: UInt8(min(255, Double(other.buf[i + 1]) * m)),
                                      b: UInt8(min(255, Double(other.buf[i + 2]) * m)), a: UInt8(Double(a) * alpha)))
            }
        }
    }

    /// The runs of drawn pixels along row `y`, left to right, as column ranges.
    func runs(row y: Int) -> [Range<Int>] {
        var out: [Range<Int>] = [], start: Int?
        for x in 0...w {
            let on = x < w && isDrawn(x, y)
            if on, start == nil { start = x } else if !on, let s = start { out.append(s..<x); start = nil }
        }
        return out
    }

    /// Move what's drawn in `columns` × `rows` by `dy` rows, clearing where it was (what leaves the canvas is lost).
    func move(columns: Range<Int>, rows: Range<Int>, dy: Int) {
        let old = buf
        for y in rows where y >= 0 && y < h { for x in columns where x >= 0 && x < w { for n in 0..<4 { buf[(y * w + x) * 4 + n] = 0 } } }
        for y in rows where y >= 0 && y < h && y + dy >= 0 && y + dy < h {
            for x in columns where x >= 0 && x < w {
                let src = (y * w + x) * 4, dst = ((y + dy) * w + x) * 4
                guard old[src + 3] > 0 else { continue }
                for n in 0..<4 { buf[dst + n] = old[src + n] }
            }
        }
    }

    /// Copy one pixel as it is to another place (ignoring the offsets).
    func copyPixel(from a: (x: Int, y: Int), to b: (x: Int, y: Int)) {
        guard isDrawn(a.x, a.y), b.x >= 0, b.y >= 0, b.x < w, b.y < h else { return }
        for n in 0..<4 { buf[(b.y * w + b.x) * 4 + n] = buf[(a.y * w + a.x) * 4 + n] }
    }

    /// The solid pixels' bounds (the ones `addOutline` outlines), or nil if nothing solid is drawn.
    func solidBounds() -> (minX: Int, maxX: Int, minY: Int, maxY: Int)? {
        var b: (minX: Int, maxX: Int, minY: Int, maxY: Int)?
        for y in 0..<h {
            for x in 0..<w where buf[(y * w + x) * 4 + 3] >= 250 {
                if let o = b { b = (min(o.minX, x), max(o.maxX, x), o.minY, y) } else { b = (x, x, y, y) }
            }
        }
        return b
    }

    /// Whether anything is drawn at (`x`, `y`) in canvas pixels, ignoring the offsets.
    func isDrawn(_ x: Int, _ y: Int) -> Bool {
        x >= 0 && y >= 0 && x < w && y < h && buf[(y * w + x) * 4 + 3] > 0
    }

    /// Move everything drawn so far by whole pixels; what slides off the edge is lost.
    func shift(dx: Int, dy: Int) {
        guard dx != 0 || dy != 0 else { return }
        var out = [UInt8](repeating: 0, count: buf.count)
        for y in 0..<h {
            let ty = y + dy
            guard ty >= 0, ty < h else { continue }
            for x in 0..<w {
                let tx = x + dx
                guard tx >= 0, tx < w else { continue }
                let src = (y * w + x) * 4, dst = (ty * w + tx) * 4
                for n in 0..<4 { out[dst + n] = buf[src + n] }
            }
        }
        buf = out
    }

    /// 1px outline around every solid pixel, so dark sprites still read on a dark desktop.
    /// Only fully opaque pixels count as solid, so saber glows and bolts don't get outlined.
    func addOutline(_ c: Px) {
        guard w > 0, h > 0 else { return }
        let a = Double(c.a) / 255
        let cr = Double(c.r) * a, cg = Double(c.g) * a, cb = Double(c.b) * a, ca = Double(c.a), keep = 1 - a
        let (w, h) = (w, h)
        buf.withUnsafeMutableBufferPointer { b in
            // Which pixels are solid, taken before any outline is written (only the alpha matters, not a full copy).
            var solid = [Bool](repeating: false, count: w * h)
            for p in 0..<(w * h) { solid[p] = b[p * 4 + 3] >= 250 }
            for y in 0..<h {
                for x in 0..<w {
                    let p = y * w + x, i = p * 4
                    guard b[i + 3] <= 60 else { continue }
                    let edge = (x + 1 < w && solid[p + 1]) || (x > 0 && solid[p - 1])
                        || (y + 1 < h && solid[p + w]) || (y > 0 && solid[p - w])
                    guard edge else { continue }
                    b[i] = UInt8(min(255, cr + Double(b[i]) * keep))
                    b[i + 1] = UInt8(min(255, cg + Double(b[i + 1]) * keep))
                    b[i + 2] = UInt8(min(255, cb + Double(b[i + 2]) * keep))
                    b[i + 3] = UInt8(min(255, ca + Double(b[i + 3]) * keep))
                }
            }
        }
    }

    /// Wipe to transparent (and drop any translation), so one canvas can be reused frame after frame.
    func clear() {
        buf.withUnsafeMutableBytes { _ = $0.initializeMemory(as: UInt8.self, repeating: 0) }
        ox = 0; oy = 0; baseY = 0
    }

    /// The canvas as an image, in the byte order Core Animation draws from directly (BGRA: premultiplied alpha first,
    /// 32-bit little-endian). Handed RGBA, it converted every new image on the main thread before showing it, and
    /// the scene's moving layer is a new image every frame. Same colour space, same values: only the order changes.
    func makeImage() -> CGImage? {
        var data = Data(count: buf.count)
        data.withUnsafeMutableBytes { dst in
            buf.withUnsafeBytes { src in
                let s = src.bindMemory(to: UInt32.self), d = dst.bindMemory(to: UInt32.self)
                for i in 0..<s.count {   // R and B trade places; G and A stay
                    let v = s[i]
                    d[i] = (v & 0xFF00_FF00) | (v & 0xFF) << 16 | (v >> 16) & 0xFF
                }
            }
        }
        guard let provider = CGDataProvider(data: data as CFData) else { return nil }
        return CGImage(width: w, height: h, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: w * 4,
                       space: Self.deviceRGB,
                       bitmapInfo: CGBitmapInfo(rawValue: layerBitmapInfo),
                       provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
    }
    private static let deviceRGB = CGColorSpaceCreateDeviceRGB()
}

/// The pixel layout Core Animation shows without converting (BGRA: premultiplied alpha first, 32-bit little-endian),
/// for any image drawn to go on a layer. Same colours as RGBA; only the byte order differs.
let layerBitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

// Helpers the universes' art shares (each art file used to carry its own copy).

/// The colour at byte `i` of `s` (an RGBA buffer with premultiplied alpha) with the alpha divided back out, for
/// copying pixels from one canvas onto another. `i` must not be fully transparent.
func unpremultiplied(_ s: PixelCanvas, _ i: Int) -> Px {
    let a = s.buf[i + 3], m = 255 / Double(a)
    return Px(r: UInt8(min(255, Double(s.buf[i]) * m)), g: UInt8(min(255, Double(s.buf[i + 1]) * m)),
              b: UInt8(min(255, Double(s.buf[i + 2]) * m)), a: a)
}

/// A prop drawn pointing right from pixel (20, 20) of a scratch canvas, turned to `angle` degrees (0 forward, -90 up)
/// and placed with that point on `at`, at `alpha`.
func prop(_ c: PixelCanvas, at: (x: Double, y: Double), angle: Double, alpha: Double = 1, _ art: (PixelCanvas) -> Void) {
    let s = PixelCanvas(41, 41)
    art(s)
    let r = s.rotated(angle, about: (20.5, 20.5), into: 41, 41, at: (20.5, 20.5))
    let x0 = Int(floor(at.x - 20.5)), y0 = Int(floor(at.y - 20.5))
    for y in 0..<r.h {
        for x in 0..<r.w {
            let i = (y * r.w + x) * 4
            guard r.buf[i + 3] > 0 else { continue }
            c.px(x0 + x, y0 + y, unpremultiplied(r, i).alpha(alpha))
        }
    }
}

/// A colour from 0xRRGGBB, for drawing straight into a Core Graphics context (the transitions).
func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
