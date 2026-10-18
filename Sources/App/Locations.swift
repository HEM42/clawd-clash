import AppKit

// Window-mode backdrops: one location per character, drawn as pixel art in code, in each universe.
// The first-spawned Claude decides where the crew is (or pick one from the Location menu).
// Every scene gets a canvas of w×h pixels whose bottom `floorRows` rows are the ground the crew stands on.
//
// Each place is a `Place` registered in a universe's scene files (Universes/*/Places): its name, the tint of the
// window's card area, the still picture and (optionally) what moves there. Each universe's `Theme` lists its places in
// order and says who lives where.

/// A place, by its key (stored in settings and the screen-saver feed). The keys are unique across universes.
struct Location: Hashable, RawRepresentable {
    let rawValue: String
    init(_ key: String) { rawValue = key }
    /// Only places that exist.
    init?(rawValue: String) {
        guard places[Location(rawValue)] != nil else { return nil }
        self.rawValue = rawValue
    }

    /// The universe it's in.
    var universe: Universe { Universe.allCases.first { Theme.of($0).places.contains(self) } ?? .fallback }

    /// Every place in `universe`, in order.
    static func all(in universe: Universe) -> [Location] { Theme.of(universe).places }

    /// Every place in every universe people can pick (`Universe.offered`), in menu order (Clawd Royale picks from all of
    /// them).
    static let everywhere: [Location] = Universe.offered.flatMap { all(in: $0) }

    var place: Place { places[self] ?? Place(name: rawValue, panel: 0x16181D, still: { _, _ in }) }

    var name: String { place.name }
    /// Whether it shows its own name where the window's top bar would write it (`Place.signed`).
    var signed: Bool { place.signed }

    /// Background tint for the card area, so the whole window feels like the place.
    var panel: NSColor {
        let hex = place.panel
        return NSColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
                       blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
    }

    /// The parts of the scene that never move (cached per window size).
    func drawStatic(_ c: PixelCanvas, floorRows f: Int) {
        guard c.w > 0, c.h > f, f >= 0 else { return }
        place.still(c, c.h - f)
    }

    /// Whether `drawAnimated` draws anything here (the rest are still pictures, with no per-frame layer).
    var hasAnimatedLayer: Bool { place.moving != nil }

    /// The moving bits, drawn every frame on a transparent canvas of the same size.
    func drawAnimated(_ c: PixelCanvas, floorRows f: Int, t: Double) {
        guard let moving = place.moving, c.w > 0, c.h > f, f >= 0 else { return }
        moving(c, c.h - f, t)
    }
}

/// One location: what it's called and how it's drawn.
struct Place {
    let name: String
    /// The window's card area under the scene, as 0xRRGGBB: a dark tint of the place.
    let panel: UInt32
    /// The still picture: canvas and ground row `g` (the crew's feet stand on row `g`; rows below are floor).
    let still: (PixelCanvas, Int) -> Void
    /// What moves there, drawn every frame on a transparent canvas the same size: canvas, ground row, clock.
    var moving: ((PixelCanvas, Int, Double) -> Void)? = nil
    /// The place carries its own name in the window's top-left corner (the Bronze's neon sign): the window's top bar
    /// leaves its name off there, so it doesn't sit over the sign.
    var signed = false
}

/// Every place in every universe, from the universes' scene files.
let places: [Location: Place] = Universe.allCases.reduce(into: [:]) { all, u in
    all.merge(u.module.places) { a, _ in assertionFailure("a place key used twice: \(a.name)"); return a }
}


/// The wipes between places where a universe has no trips of its own (Star Clawds), shared by the window and the screen
/// saver: what's left of the old picture as an edge sweeps across it, straight or slanted, or a clock hand sweeps round.
enum Wipe {
    static let duration = 1.2

    /// The films' wipes: a straight edge sweeping across one way or another, a slanted one corner to corner, or a clock
    /// hand sweeping round.
    enum Kind: CaseIterable {
        case edgeRight, edgeLeft, edgeDown, edgeUp, diagonal, clock, anticlockwise

        /// A different one from `last`, at random.
        static func next(after last: Kind?) -> Kind { allCases.filter { $0 != last }.randomElement() ?? .edgeRight }
    }

    /// How much of the old picture still shows at each point, `k` (0…1) of the way through a `kind` wipe, as a small mask
    /// to stretch over the frame (`aspect`: its width over its height). Soft along the edge, as the films' wipes are: the
    /// old picture fades into the new across a band, a tenth or so of the way across (behind the clock hand, a slice of
    /// its turn). The edge starts just outside the frame and finishes just past it, so the first and last frames are
    /// clean. `alpha`: as an alpha mask (a Core Animation layer's), else in grey (`CGContext.clip(to:mask:)`).
    static func mask(_ k: Double, _ kind: Kind, aspect: Double, alpha: Bool = false) -> CGImage? {
        let w = 160, h = max(1, Int((160 / max(0.1, aspect)).rounded()))
        let round = kind == .clock || kind == .anticlockwise
        let band = round ? 0.05 : 0.12
        let edge = -band / 2 + k * (1 + band)
        var cover = [UInt8](repeating: 0, count: w * h)
        for y in 0..<h {
            let v = (Double(y) + 0.5) / Double(h)                          // 0 at the top
            for x in 0..<w {
                let u = (Double(x) + 0.5) / Double(w)
                // How far along the wipe this point is: the edge reaches it at s = edge.
                let s: Double
                switch kind {
                case .edgeRight: s = u
                case .edgeLeft: s = 1 - u
                case .edgeDown: s = v
                case .edgeUp: s = 1 - v
                case .diagonal: s = (u + v) / 2
                case .clock, .anticlockwise:
                    let turn = atan2((u - 0.5) * aspect, 0.5 - v) / (2 * .pi)   // clockwise from twelve, -½…½
                    let t = turn < 0 ? turn + 1 : turn
                    s = kind == .clock ? t : 1 - t
                }
                let f = max(0, min(1, (s - (edge - band / 2)) / band))
                cover[y * w + x] = UInt8((f * f * (3 - 2 * f) * 255).rounded())
            }
        }
        if alpha {
            var rgba = [UInt8](repeating: 0, count: w * h * 4)
            for i in 0..<(w * h) { rgba[i * 4] = cover[i]; rgba[i * 4 + 1] = cover[i]; rgba[i * 4 + 2] = cover[i]; rgba[i * 4 + 3] = cover[i] }
            guard let ctx = CGContext(data: &rgba, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                                      space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else { return nil }
            return ctx.makeImage()
        }
        guard let ctx = CGContext(data: &cover, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w,
                                  space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue)
        else { return nil }
        return ctx.makeImage()
    }

    /// Draws the old picture over `r` as much as it still shows, `k` through a `kind` wipe (the new one is already there).
    static func drawOld(_ old: CGImage, _ k: Double, _ kind: Kind, in ctx: CGContext, _ r: CGRect) {
        guard let m = mask(k, kind, aspect: Double(r.width / max(1, r.height))) else { return }
        ctx.saveGState(); ctx.clip(to: r, mask: m)
        ctx.draw(old, in: r)
        ctx.restoreGState()
    }

    /// One picture from several stacked (the place and what moves there), to freeze for a wipe.
    static func flatten(_ images: [CGImage]) -> CGImage? {
        guard let first = images.first else { return nil }
        let w = first.width, h = first.height
        guard let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                  bitmapInfo: layerBitmapInfo) else { return nil }
        for img in images { ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h)) }
        return ctx.makeImage()
    }
}


// MARK: - Drawing helpers

func lerp(_ a: Px, _ b: Px, _ t: Double) -> Px {
    let k = max(0, min(1, t))
    func mix(_ x: UInt8, _ y: UInt8) -> UInt8 { UInt8(Double(x) + (Double(y) - Double(x)) * k) }
    return Px(r: mix(a.r, b.r), g: mix(a.g, b.g), b: mix(a.b, b.b), a: mix(a.a, b.a))
}

extension PixelCanvas {
    /// Vertical gradient from row y0 (top colour) to y1 (bottom colour), quantised into bands like old pixel art.
    func gradient(_ y0: Int, _ y1: Int, _ top: Px, _ bottom: Px, bands: Int = 6) {
        guard y1 > y0 else { return }
        for y in y0..<y1 {
            let k = (Double(y - y0) / Double(y1 - y0) * Double(bands)).rounded(.down) / Double(bands)
            rect(0, y, w, 1, lerp(top, bottom, k))
        }
    }

    func circle(_ cx: Int, _ cy: Int, _ r: Int, _ col: Px) {
        guard r > 0 else { px(cx, cy, col); return }
        for dy in -r...r {
            let half = Int((Double(r * r - dy * dy)).squareRoot().rounded())
            rect(cx - half, cy + dy, half * 2 + 1, 1, col)
        }
    }

    func ellipse(_ cx: Int, _ cy: Int, _ rx: Int, _ ry: Int, _ col: Px) {
        guard rx > 0, ry > 0 else { return }
        for dy in -ry...ry {
            let k = 1 - Double(dy * dy) / Double(ry * ry)
            let half = Int((Double(rx) * k.squareRoot()).rounded())
            rect(cx - half, cy + dy, half * 2 + 1, 1, col)
        }
    }

    /// Stars scattered over a box, or only the part of it `inside` says is open sky (a round window).
    func stars(_ y0: Int, _ y1: Int, density: Int = 40, seed: Int = 0, x0: Int = 0, x1: Int? = nil,
               inside: ((Int, Int) -> Bool)? = nil) {
        let xe = x1 ?? w
        guard y1 > y0, xe > x0 else { return }
        for i in 0..<((xe - x0) * (y1 - y0) / density) {
            let x = x0 + Int(noise(i * 3 + seed * 1000) * Double(xe - x0))
            let y = y0 + Int(noise(i * 3 + 1 + seed * 1000) * Double(y1 - y0))
            if let inside, !inside(x, y) { continue }
            px(x, y, white.alpha(noise(i * 3 + 2 + seed * 1000) > 0.8 ? 0.95 : 0.5))
        }
    }

    /// Rolling dunes or hills: fills from a wavy line down to `bottom`.
    func dunes(base: Int, amp: Double, freq: Double, phase: Double, bottom: Int, _ col: Px, shade: Px? = nil) {
        for x in 0..<w {
            let top = base - Int((sin(Double(x) * freq + phase) * 0.6 + sin(Double(x) * freq * 2.3 + phase * 1.7) * 0.4) * amp)
            if top < bottom { rect(x, top, 1, bottom - top, col) }
            if let shade, top < bottom { px(x, top, shade) }
        }
    }

    /// Ground strip with a highlighted edge and speckles.
    func ground(_ g: Int, _ col: Px, edge: Px, speck: Px, seed: Int = 0) {
        rect(0, g, w, h - g, col)
        rect(0, g, w, 1, edge)
        for i in 0..<(w * (h - g) / 6) {
            px(Int(noise(i * 11 + 3 + seed) * Double(w)), g + 1 + Int(noise(i * 11 + 4 + seed) * Double(max(1, h - g - 1))), speck)
        }
    }
}


// MARK: - Shared scene helpers

enum Scenes {
    /// Pixel size of the backdrop on screen: matches the crew's pixels at the window's Small size.
    static let pixel: CGFloat = 2
}

// The screensaver draws each place full screen, several times taller than the window's strip, which would leave the
// upper part bare. Scenes fill it with more of the same place, in the same palette, when `isTall` says so. The
// window's strip is never `tallRows` rows tall.
extension Scenes {
    static let tallRows = 140
    static func isTall(_ c: PixelCanvas) -> Bool { c.h >= tallRows }
    /// Whole-pixel size of one unit of the extras: 1, growing on very tall canvases so they keep their size on screen.
    static func unit(_ g: Int) -> Int { max(1, (g + 60) / 300) }

    /// Draws in units of `s` pixels from an origin.
    struct Pen {
        let c: PixelCanvas, x: Int, y: Int, s: Int
        init(_ c: PixelCanvas, _ x: Int, _ y: Int, _ g: Int) { self.c = c; self.x = x; self.y = y; s = Scenes.unit(g) }
        func rect(_ u: Int, _ v: Int, _ w: Int, _ h: Int, _ col: Px) { c.rect(x + u * s, y + v * s, w * s, h * s, col) }
        func ellipse(_ u: Int, _ v: Int, _ rx: Int, _ ry: Int, _ col: Px) { c.ellipse(x + u * s, y + v * s, rx * s, ry * s, col) }
        func circle(_ u: Int, _ v: Int, _ r: Int, _ col: Px) { c.circle(x + u * s, y + v * s, r * s, col) }
    }

    /// A soft fair-weather cloud: a shaded flat base under a few puffs.
    static func cloud(_ c: PixelCanvas, _ x: Int, _ y: Int, _ r: Int, seed: Int, top: Px = C(0xF6F9FC), base: Px = C(0xDDE9F3)) {
        c.ellipse(x, y + r / 2, r * 3, max(1, r / 2), base)
        for k in 0..<4 {
            let dx = Int((noise(seed * 7 + k) - 0.5) * Double(r * 4)), rr = r * (2 + k % 2) / 3 + 1
            c.ellipse(x + dx, y - rr / 3, rr * 3 / 2, rr, top)
        }
    }

    /// A thin streak of high cloud, `len` pixels long.
    static func wisp(_ c: PixelCanvas, _ x: Int, _ y: Int, _ len: Int, _ col: Px, s: Int) {
        c.rect(x - len / 2, y, len, s, col)
        c.rect(x - len / 3, y - s, len / 2, s, col.alpha(0.7))
        c.rect(x - len / 6, y + s, len / 2, s, col.alpha(0.6))
    }

    /// A flat-topped mesa with sloping flanks, `h` rows tall, standing on row `base`.
    static func mesa(_ c: PixelCanvas, x: Int, width: Int, h: Int, base: Int, _ col: Px, seed: Int) {
        let flankW = max(1, width / 5)
        for k in 0..<width {
            let flank = max(0, max(flankW - k, k - (width - flankW))) * h / (flankW * 2)
            let top = base - h + flank + Int(noise(k + seed * 31) * 2)
            if top < base { c.rect(x + k, top, 1, base - top, col) }
        }
    }

}
