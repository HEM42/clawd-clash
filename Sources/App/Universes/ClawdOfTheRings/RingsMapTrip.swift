import CoreGraphics
import CoreText
import Foundation

// The map journey between Clawd of the Rings places (`RingsWipe.map`).

extension RingsTrip {
    /// A frame `k` (0…1) of the map journey from `from` to `to`, over the whole of `r`. The old place yellows and
    /// dithers into a parchment map of Middle-earth (0–0.24); a dotted line walks from where the crew was to where it's
    /// going (0.2–0.62), and the destination's name is written beside its marker (0.6–0.74); the new place opens out of
    /// the marker in a growing circle (0.65–0.97). The places are drawn as they are; the map and everything on it is
    /// pixel art, drawn into a bitmap about 180 pixels tall and scaled up without smoothing, like the Eye.
    func drawMap(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        RingsMap.draw(ctx, from: from, to: to, old: old, new: new, k: k, in: r)
    }
}

private enum RingsMap {
    // MARK: Where things are

    /// Each place on the map: x west to east, y north to south, as fractions of the frame (roughly where it is in the
    /// lore, nudged apart where places crowd).
    static let spots: [Location: CGPoint] = [
        .bagEnd: CGPoint(x: 0.170, y: 0.360),
        .greenDragon: CGPoint(x: 0.210, y: 0.400),
        .oldForest: CGPoint(x: 0.285, y: 0.395),
        .barrowDowns: CGPoint(x: 0.300, y: 0.460),
        .prancingPony: CGPoint(x: 0.345, y: 0.380),
        .weathertop: CGPoint(x: 0.410, y: 0.370),
        .rivendell: CGPoint(x: 0.500, y: 0.330),
        .goblinTown: CGPoint(x: 0.565, y: 0.250),
        .moria: CGPoint(x: 0.550, y: 0.470),
        .lothlorien: CGPoint(x: 0.615, y: 0.500),
        .fangorn: CGPoint(x: 0.585, y: 0.600),
        .isengard: CGPoint(x: 0.530, y: 0.650),
        .helmsDeep: CGPoint(x: 0.550, y: 0.730),
        .edoras: CGPoint(x: 0.610, y: 0.735),
        .minasTirith: CGPoint(x: 0.720, y: 0.790),
        .deadMarshes: CGPoint(x: 0.735, y: 0.575),
        .blackGate: CGPoint(x: 0.785, y: 0.625),
        .mountDoom: CGPoint(x: 0.870, y: 0.735),
        .dolGuldur: CGPoint(x: 0.715, y: 0.440),
        .mirkwood: CGPoint(x: 0.775, y: 0.170),
        .erebor: CGPoint(x: 0.860, y: 0.125),
        .laketown: CGPoint(x: 0.865, y: 0.220),
    ]
    static func spot(_ l: Location) -> CGPoint { spots[l] ?? CGPoint(x: 0.5, y: 0.5) }

    /// Eriador, west of the Misty Mountains: a journey from here to the east crosses them by a pass.
    static let west: Set<Location> = [.bagEnd, .greenDragon, .oldForest, .barrowDowns, .prancingPony, .weathertop, .rivendell]
    /// Places in the mountains themselves (no pass needed).
    static let passes: Set<Location> = [.goblinTown, .moria, .isengard]
    static let highPass = CGPoint(x: 0.560, y: 0.285), moriaGate = CGPoint(x: 0.550, y: 0.470)
    static let gapOfRohan = CGPoint(x: 0.500, y: 0.700), cirithUngol = CGPoint(x: 0.790, y: 0.760)

    /// The waypoints between `a` and `b`: over the mountains by the pass nearest the eastern end (the High Pass,
    /// Moria or the Gap of Rohan), and into Mordor by Cirith Ungol unless by the Black Gate.
    static func waypoints(_ a: Location, _ b: Location) -> [CGPoint] {
        var out: [CGPoint] = []
        let east: Location? = west.contains(a) && !west.contains(b) && !passes.contains(b) ? b
            : west.contains(b) && !west.contains(a) && !passes.contains(a) ? a : nil
        if let e = east {
            let y = spot(e).y
            out.append(y < 0.36 ? highPass : y < 0.56 ? moriaGate : gapOfRohan)
        }
        if b == .mountDoom && a != .blackGate { out.append(cirithUngol) }
        if a == .mountDoom && b != .blackGate { out.insert(cirithUngol, at: 0) }
        return out
    }

    // MARK: The frame

    static func draw(_ ctx: CGContext, from: Location, to: Location, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let px: CGFloat = max(1, (r.height / 180).rounded())  // screen pixels per pixel of the map
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        let reveal = span(k, 0.06, 0.24)                       // the map dithers in over the old place
        let walk = ease(span(k, 0.2, 0.62))                    // how far the line has walked
        let open = span(k, 0.65, 0.97)                         // the iris
        let dest = snap(at(spot(to), r), px, r)
        let reach = [CGPoint(x: r.minX, y: r.minY), CGPoint(x: r.maxX, y: r.minY), CGPoint(x: r.minX, y: r.maxY),
                     CGPoint(x: r.maxX, y: r.maxY)].map { hypot($0.x - dest.x, $0.y - dest.y) }.max() ?? r.width
        let radius = (reach + px) * CGFloat(open * open)
        if open >= 1 { ctx.drawShot(new, in: r); return }

        if reveal < 1 {
            // The old place, yellowing like old paper.
            ctx.drawShot(old, in: r)
            let yellow = CGFloat(ease(span(k, 0, 0.16)))
            ctx.saveGState()
            ctx.setBlendMode(.color); ctx.setFillColor(rgb(0xB08A4C, 0.85 * yellow)); ctx.fill(r)
            ctx.setBlendMode(.multiply); ctx.setFillColor(rgb(0xF2DDA6, yellow)); ctx.fill(r)
            ctx.restoreGState()
        }

        guard let art = artCanvas(width: w, height: h, px: px, in: r) else { ctx.drawShot(k < 0.5 ? old : new, in: r); return }
        let disc = CGRect(x: dest.x - radius, y: dest.y - radius, width: radius * 2, height: radius * 2)
        let hole: [CGRect] = radius > px / 2 ? rows(of: disc, px: px, height: h, in: r) : []
        if !hole.isEmpty {
            // The new place through the iris, sepia at first, its colour coming back as it opens.
            ctx.saveGState()
            ctx.clip(to: hole)
            ctx.drawShot(new, in: r)
            let sepia = CGFloat(1 - ease(span(k, 0.66, 0.9)))
            if sepia > 0 { ctx.setBlendMode(.color); ctx.setFillColor(rgb(0xB08A4C, 0.8 * sepia)); ctx.fill(r) }
            ctx.restoreGState()
        }

        // The map, the journey on it and its two markers.
        if let map = baseMap(width: w, height: h, px: px, in: r) {
            art.draw(map, in: CGRect(x: r.minX, y: r.minY, width: CGFloat(w) * px, height: CGFloat(h) * px))
        }
        let arrived = from == to ? k >= 0.2 : walk >= 1
        if from != to {
            let path = route(from, to, in: r)
            drawTrail(art, path, walked: CGFloat(walk), px: px, in: r)
            fromMarker(art, snap(at(spot(from), r), px, r), px: px)
        }
        if k >= 0.16 { toMarker(art, dest, px: px, lit: arrived) }
        let pulse = span(k, 0.62, 0.76)
        if pulse > 0 && pulse < 1 {
            let rr = px * (5 + 9 * CGFloat(pulse))
            art.setStrokeColor(rgb(0x9E2A1C, CGFloat(1 - pulse))); art.setLineWidth(px)
            art.strokeEllipse(in: CGRect(x: dest.x - rr, y: dest.y - rr, width: rr * 2, height: rr * 2))
        }

        if !hole.isEmpty {
            // The iris's edge: a scorched brown ring, then the hole cut on the map's grid.
            art.setStrokeColor(rgb(0x9C7A44, 0.7)); art.setLineWidth(8 * px); art.strokeEllipse(in: disc)
            art.setStrokeColor(rgb(0x3A2614)); art.setLineWidth(4 * px); art.strokeEllipse(in: disc)
            art.saveGState(); art.setBlendMode(.clear); art.fill(hole); art.restoreGState()
        }
        if reveal < 1 { dither(art, width: w, height: h, keep: reveal) }
        blit(art, onto: ctx, width: w, height: h, px: px, in: r)

        // The destination's name, written in beside its marker as the line arrives.
        let write = span(k, 0.6, 0.74), fade = 1 - span(k, 0.86, 0.95)
        if write > 0 && fade > 0 { drawName(ctx, to.name, at: dest, written: write, alpha: CGFloat(fade), px: px, in: r) }
    }

    // MARK: The journey

    /// The way from `a` to `b` in `r`, as a dense polyline: through any waypoints, each leg bowed a little.
    static func route(_ a: Location, _ b: Location, in r: CGRect) -> [CGPoint] {
        let stops = ([spot(a)] + waypoints(a, b) + [spot(b)]).map { at($0, r) }
        let seed = (a.rawValue + b.rawValue).unicodeScalars.reduce(0) { $0 + Int($1.value) }
        let sign: CGFloat = seed % 2 == 0 ? 1 : -1
        var bent: [CGPoint] = [stops[0]]
        for i in 1..<stops.count {
            let p = stops[i - 1], q = stops[i]
            let dx = q.x - p.x, dy = q.y - p.y
            let bow: CGFloat = 0.12 * sign * (i % 2 == 0 ? -1 : 1)
            bent.append(CGPoint(x: (p.x + q.x) / 2 - dy * bow, y: (p.y + q.y) / 2 + dx * bow))
            bent.append(q)
        }
        // A Catmull-Rom curve through the points.
        var out: [CGPoint] = []
        let n = bent.count
        for i in 0..<(n - 1) {
            let p0 = bent[max(0, i - 1)], p1 = bent[i], p2 = bent[i + 1], p3 = bent[min(n - 1, i + 2)]
            for s in 0..<10 {
                let t = CGFloat(s) / 10, t2 = t * t, t3 = t2 * t
                func c(_ a: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat) -> CGFloat {
                    let lin: CGFloat = 2 * b + (c - a) * t
                    let quad: CGFloat = (2 * a - 5 * b + 4 * c - d) * t2
                    let cub: CGFloat = (3 * b - a - 3 * c + d) * t3
                    return 0.5 * (lin + quad + cub)
                }
                out.append(CGPoint(x: c(p0.x, p1.x, p2.x, p3.x), y: c(p0.y, p1.y, p2.y, p3.y)))
            }
        }
        out.append(bent[n - 1])
        return out
    }

    /// Red ink dots along `path` as far as `walked` (0…1 of its length), with a darker one at the walking end.
    static func drawTrail(_ c: CGContext, _ path: [CGPoint], walked: CGFloat, px: CGFloat, in r: CGRect) {
        guard path.count > 1, walked > 0 else { return }
        var lengths: [CGFloat] = [0]
        for i in 1..<path.count { lengths.append(lengths[i - 1] + hypot(path[i].x - path[i - 1].x, path[i].y - path[i - 1].y)) }
        let total = lengths[lengths.count - 1], end = total * walked
        func point(_ d: CGFloat, from i: inout Int) -> CGPoint {
            while i + 1 < lengths.count - 1 && lengths[i + 1] < d { i += 1 }
            let seg = max(0.0001, lengths[i + 1] - lengths[i]), f = min(1, max(0, (d - lengths[i]) / seg))
            return CGPoint(x: path[i].x + (path[i + 1].x - path[i].x) * f, y: path[i].y + (path[i + 1].y - path[i].y) * f)
        }
        let gap = 5 * px, dot = 2 * px
        var d: CGFloat = 0, i = 0
        c.setFillColor(rgb(0x9E2A1C))
        while d <= end {
            let p = snap(point(d, from: &i), px, r)
            c.fill(CGRect(x: p.x - px, y: p.y - px, width: dot, height: dot))
            d += gap
        }
        if walked < 1 {
            var j = 0
            let p = snap(point(end, from: &j), px, r)
            c.setFillColor(rgb(0x5A1008)); c.fill(CGRect(x: p.x - 2 * px, y: p.y - 2 * px, width: 4 * px, height: 4 * px))
            c.setFillColor(rgb(0xD8503A)); c.fill(CGRect(x: p.x - px, y: p.y, width: px, height: px))
        }
    }

    /// Where the crew was: a small ink ring.
    static func fromMarker(_ c: CGContext, _ p: CGPoint, px: CGFloat) {
        c.setFillColor(rgb(0x3A2614)); c.fill(CGRect(x: p.x - 2 * px, y: p.y - 3 * px, width: 4 * px, height: 6 * px))
        c.fill(CGRect(x: p.x - 3 * px, y: p.y - 2 * px, width: 6 * px, height: 4 * px))
        c.setFillColor(rgb(0xEEDBA8)); c.fill(CGRect(x: p.x - px, y: p.y - 2 * px, width: 2 * px, height: 4 * px))
        c.fill(CGRect(x: p.x - 2 * px, y: p.y - px, width: 4 * px, height: 2 * px))
    }

    /// Where it's going: a red target ringed in ink, faint until the line gets there.
    static func toMarker(_ c: CGContext, _ p: CGPoint, px: CGFloat, lit: Bool) {
        func disc(_ rr: CGFloat, _ hex: UInt32) {
            c.setFillColor(rgb(hex, lit ? 1 : 0.55))
            c.fillEllipse(in: CGRect(x: p.x - rr, y: p.y - rr, width: rr * 2, height: rr * 2))
        }
        disc(5 * px, 0x3A2614); disc(4 * px, 0xB8301E); disc(2.5 * px, 0xEEDBA8); disc(1.5 * px, 0xB8301E)
    }

    /// The name in a map-maker's italic on a little inked cartouche above the marker (below, if there's no room), its
    /// first `written` (0…1) letters showing: drawn in a bitmap of its own at half the map's pixel size, unsmoothed.
    static func drawName(_ ctx: CGContext, _ name: String, at p: CGPoint, written: Double, alpha: CGFloat, px: CGFloat, in r: CGRect) {
        let lpx: CGFloat = max(1, (px / 2).rounded())
        let size = max(13, r.height * 0.042)
        let font = CTFontCreateWithName("Palatino-BoldItalic" as CFString, size, nil)
        func line(_ s: String) -> CTLine {
            CTLineCreateWithAttributedString(NSAttributedString(string: s, attributes: [
                NSAttributedString.Key(kCTFontAttributeName as String): font,
                NSAttributedString.Key(kCTForegroundColorFromContextAttributeName as String): true]))
        }
        var ascent: CGFloat = 0, descent: CGFloat = 0, leading: CGFloat = 0
        let textWidth = CGFloat(CTLineGetTypographicBounds(line(name), &ascent, &descent, &leading))
        let padX = 3 * px, padY = 1.5 * px
        let lw = ((textWidth + padX * 2) / px).rounded(.up) * px, lh = ((ascent + descent + padY * 2) / px).rounded(.up) * px
        let gap = 7 * px, margin = 6 * px
        var x = p.x - lw / 2, y = p.y + gap
        if y + lh > r.maxY - margin { y = p.y - gap - lh }
        x = min(max(x, r.minX + margin), r.maxX - margin - lw); y = min(max(y, r.minY + margin), r.maxY - margin - lh)
        let box = CGRect(x: r.minX + ((x - r.minX) / px).rounded() * px, y: r.minY + ((y - r.minY) / px).rounded() * px,
                         width: lw, height: lh)
        let shown = Int((Double(name.count) * written).rounded(.up))
        guard shown > 0, let c = artCanvas(width: Int(lw / lpx), height: Int(lh / lpx), px: lpx, in: box) else { return }
        c.setShouldSmoothFonts(false); c.setAllowsFontSmoothing(false)
        let text = line(String(name.prefix(shown)))
        c.setFillColor(rgb(0x4A2A12)); c.fill(box)
        c.setFillColor(rgb(0xF2E2B4)); c.fill(box.insetBy(dx: px, dy: px))
        c.setFillColor(rgb(0xD8BE86)); c.fill(CGRect(x: box.minX + px, y: box.minY + px, width: lw - 2 * px, height: lpx))
        c.saveGState(); c.setBlendMode(.clear)
        for corner in [CGPoint(x: box.minX, y: box.minY), CGPoint(x: box.maxX - px, y: box.minY),
                       CGPoint(x: box.minX, y: box.maxY - px), CGPoint(x: box.maxX - px, y: box.maxY - px)] {
            c.fill(CGRect(origin: corner, size: CGSize(width: px, height: px)))
        }
        c.restoreGState()
        let origin = CGPoint(x: box.minX + ((lw - textWidth) / 2 / lpx).rounded() * lpx,
                             y: box.minY + ((lh - ascent - descent) / 2 / lpx).rounded() * lpx + descent)
        c.setTextDrawingMode(.fill); c.setFillColor(rgb(0x4A2A12)); c.textPosition = origin; CTLineDraw(text, c)
        ctx.saveGState(); ctx.setAlpha(alpha)
        blit(c, onto: ctx, width: Int(lw / lpx), height: Int(lh / lpx), px: lpx, in: box)
        ctx.restoreGState()
    }

    // MARK: The map

    /// The last map drawn, kept for the next frame (it's the same for every frame of a size).
    private final class Cache {
        let lock = NSLock()
        var key: [Int] = []
        var image: CGImage?
    }
    private static let cache = Cache()

    static func baseMap(width w: Int, height h: Int, px: CGFloat, in r: CGRect) -> CGImage? {
        let key = [w, h, Int(px), Int(r.width.rounded()), Int(r.height.rounded())]
        cache.lock.lock(); defer { cache.lock.unlock() }
        if cache.key == key, let img = cache.image { return img }
        guard let c = artCanvas(width: w, height: h, px: px, in: r) else { return nil }
        paintMap(c, width: w, height: h, px: px, in: r)
        cache.key = key; cache.image = c.makeImage()
        return cache.image
    }

    static let ink: UInt32 = 0x5A3E22, water: UInt32 = 0x6F8E92, parchment: UInt32 = 0xEAD4A2

    /// Middle-earth on parchment: the sea and its coast, Mordor's shadow, the forests, rivers, hills and mountains, and
    /// a double border.
    static func paintMap(_ c: CGContext, width w: Int, height h: Int, px: CGFloat, in r: CGRect) {
        func m(_ x: CGFloat, _ y: CGFloat) -> CGPoint { snap(at(CGPoint(x: x, y: y), r), px, r) }
        let unit = r.height

        // Parchment, browner towards the corners, in stepped bands, flecked.
        c.setFillColor(rgb(0xC4A468)); c.fill(r)
        for (scale, hex) in [(1.28, 0xD3B57A), (1.16, 0xDEC48E), (1.04, parchment)] as [(CGFloat, UInt32)] {
            let rx = r.width / 2 * scale, ry = r.height / 2 * scale
            c.setFillColor(rgb(hex)); c.fillEllipse(in: CGRect(x: r.midX - rx, y: r.midY - ry, width: rx * 2, height: ry * 2))
        }
        c.setFillColor(rgb(0xC9AC72, 0.7))
        for i in 0..<(w * h / 70) {
            let x = r.minX + CGFloat(noise(i * 3 + 1)) * r.width, y = r.minY + CGFloat(noise(i * 3 + 2)) * r.height
            let p = snap(CGPoint(x: x, y: y), px, r)
            c.fill(CGRect(x: p.x, y: p.y, width: px * (noise(i * 3 + 3) > 0.8 ? 2 : 1), height: px))
        }

        // The sea, west and south, with ripples along the coast and a few waves out in it.
        let coast: [CGPoint] = [m(0.11, -0.02), m(0.095, 0.08), m(0.10, 0.17), m(0.085, 0.25), m(0.13, 0.30), m(0.09, 0.345),
                                m(0.075, 0.45), m(0.10, 0.56), m(0.13, 0.64), m(0.19, 0.72), m(0.24, 0.78), m(0.32, 0.82),
                                m(0.40, 0.86), m(0.47, 0.90), m(0.53, 0.885), m(0.60, 0.91), m(0.65, 0.96), m(0.70, 1.02)]
        let shore = smooth(coast)
        let sea = CGMutablePath(); sea.addPath(shore)
        sea.addLine(to: CGPoint(x: r.minX - px, y: r.minY - px)); sea.addLine(to: CGPoint(x: r.minX - px, y: r.maxY + px))
        sea.closeSubpath()
        c.saveGState()
        c.addPath(sea); c.clip()
        c.setFillColor(rgb(0xCFCBA4)); c.fill(r)
        c.addPath(shore); c.setStrokeColor(rgb(0xA9B09A)); c.setLineWidth(9 * px); c.strokePath()
        c.addPath(shore); c.setStrokeColor(rgb(0xCFCBA4)); c.setLineWidth(6 * px); c.strokePath()
        c.addPath(shore); c.setStrokeColor(rgb(0xB4B9A0)); c.setLineWidth(3 * px); c.strokePath()
        c.restoreGState()
        c.addPath(shore); c.setStrokeColor(rgb(ink)); c.setLineWidth(px); c.strokePath()
        c.setStrokeColor(rgb(0x8A9688)); c.setLineWidth(px)
        for (x, y) in [(0.035, 0.16), (0.03, 0.40), (0.05, 0.62), (0.21, 0.86), (0.37, 0.94), (0.53, 0.965)] as [(CGFloat, CGFloat)] {
            let p = m(x, y), s = 2 * px
            c.move(to: CGPoint(x: p.x - 2 * s, y: p.y))
            c.addQuadCurve(to: CGPoint(x: p.x, y: p.y), control: CGPoint(x: p.x - s, y: p.y + s))
            c.addQuadCurve(to: CGPoint(x: p.x + 2 * s, y: p.y), control: CGPoint(x: p.x + s, y: p.y - s))
            c.strokePath()
        }
        compass(c, m(0.075, 0.87), size: max(5 * px, unit * 0.06), px: px)

        // Mordor's shadow.
        c.setFillColor(rgb(0xCDAE7C))
        c.addPath(smooth([m(0.785, 0.615), m(0.88, 0.605), m(0.985, 0.61), m(0.985, 0.92), m(0.88, 0.915), m(0.79, 0.92)], closed: true))
        c.fillPath()

        // The rivers and the Long Lake.
        let rivers: [([CGPoint], CGFloat)] = [
            ([m(0.665, 0.03), m(0.66, 0.2), m(0.665, 0.32), m(0.655, 0.44), m(0.66, 0.55), m(0.69, 0.65), m(0.71, 0.72),
              m(0.745, 0.79), m(0.73, 0.86), m(0.69, 0.92), m(0.655, 0.955)], 2),                        // the Anduin
            ([m(0.25, 0.22), m(0.245, 0.32), m(0.255, 0.42), m(0.265, 0.55), m(0.25, 0.68), m(0.215, 0.755)], 1),  // Brandywine
            ([m(0.86, 0.13), m(0.865, 0.2), m(0.875, 0.27), m(0.9, 0.36), m(0.94, 0.5)], 1),            // the Running
            ([m(0.775, 0.17), m(0.82, 0.21), m(0.857, 0.22)], 1),                                       // Forest River
            ([m(0.53, 0.66), m(0.52, 0.70), m(0.49, 0.76), m(0.44, 0.84)], 1),                           // the Isen
        ]
        c.setStrokeColor(rgb(water)); c.setLineCap(.square)
        for (points, width) in rivers { c.addPath(smooth(points)); c.setLineWidth(width * px); c.strokePath() }
        let lake = CGRect(origin: m(0.853, 0.265), size: .zero).union(CGRect(origin: m(0.877, 0.175), size: .zero))
        c.setFillColor(rgb(0x9FB3A6)); c.fillEllipse(in: lake)
        c.setStrokeColor(rgb(ink)); c.setLineWidth(px); c.strokeEllipse(in: lake)

        // The forests: a green wash, then trees from north to south.
        let forests: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (0.755, 0.300, 0.065, 0.190),   // Mirkwood
            (0.285, 0.400, 0.028, 0.036),   // the Old Forest
            (0.585, 0.600, 0.032, 0.046),   // Fangorn
            (0.615, 0.500, 0.022, 0.032),   // Lórien
        ]
        let tree = max(1.5 * px, unit * 0.014)
        var trees: [(CGPoint, Int)] = []
        for (n, f) in forests.enumerated() {
            let centre = at(CGPoint(x: f.0, y: f.1), r), rx = f.2 * r.width, ry = f.3 * r.height
            c.setFillColor(rgb(0xCEC68C))
            c.fillEllipse(in: CGRect(x: centre.x - rx - tree, y: centre.y - ry - tree, width: (rx + tree) * 2, height: (ry + tree) * 2))
            let sx = tree * 2.1, sy = tree * 1.6
            var row = 0
            var y = centre.y - ry
            while y <= centre.y + ry {
                var x = centre.x - rx + (row % 2 == 0 ? 0 : sx / 2)
                while x <= centre.x + rx {
                    let i = n * 10_000 + row * 100 + Int((x - centre.x + rx) / sx)
                    let jx = CGFloat(noise(i * 5 + 1) - 0.5) * tree * 0.8, jy = CGFloat(noise(i * 5 + 2) - 0.5) * tree * 0.6
                    let dx = (x - centre.x) / rx, dy = (y - centre.y) / ry
                    if dx * dx + dy * dy < 1 - 0.2 * CGFloat(noise(i * 5 + 3)) {
                        trees.append((CGPoint(x: x + jx, y: y + jy), i))
                    }
                    x += sx
                }
                y += sy; row += 1
            }
        }
        for (p, i) in trees.sorted(by: { $0.0.y > $1.0.y }) { drawTree(c, snap(p, px, r), size: tree, dark: noise(i * 5 + 4) < 0.3, px: px) }

        // Hills: the Shire's, the Barrow-downs and Weathertop.
        let hill = max(2 * px, unit * 0.016)
        for (x, y) in [(0.13, 0.405), (0.19, 0.315), (0.235, 0.35), (0.155, 0.45), (0.115, 0.355), (0.285, 0.495),
                       (0.325, 0.475), (0.315, 0.43), (0.395, 0.33), (0.43, 0.325), (0.41, 0.385)] as [(CGFloat, CGFloat)] {
            let p = m(x, y)
            c.setFillColor(rgb(0xD9BE88))
            c.addArc(center: p, radius: hill, startAngle: 0, endAngle: .pi, clockwise: false); c.fillPath()
            c.setStrokeColor(rgb(ink)); c.setLineWidth(px)
            c.addArc(center: p, radius: hill, startAngle: 0, endAngle: .pi, clockwise: false); c.strokePath()
        }

        // The mountains: the Misty Mountains, the Blue Mountains, the White Mountains and the ring round Mordor, and the
        // Lonely Mountain and Mount Doom on their own, drawn north to south so the nearer ones overlap. A chain is a
        // crowd of peaks of every height, close enough to overlap, scattered either side of its line; the tallest of
        // the snowy ranges' peaks are capped with snow.
        let peak = max(5 * px, unit * 0.055)
        var peaks: [MapPeak] = []
        let chains: [([CGPoint], CGFloat, Bool)] = [
            ([m(0.555, 0.09), m(0.572, 0.18), m(0.566, 0.30), m(0.552, 0.42), m(0.546, 0.52), m(0.536, 0.62)], 1, true),
            ([m(0.14, 0.10), m(0.15, 0.20), m(0.14, 0.27)], 0.75, true),
            ([m(0.115, 0.40), m(0.125, 0.48)], 0.75, true),
            ([m(0.48, 0.80), m(0.56, 0.775), m(0.64, 0.785), m(0.70, 0.81)], 0.95, true),
            ([m(0.80, 0.615), m(0.97, 0.605)], 0.85, false),
            ([m(0.785, 0.65), m(0.788, 0.90)], 0.85, false),
            ([m(0.81, 0.915), m(0.96, 0.91)], 0.8, false),
        ]
        var seq = 0
        for (points, scale, snowy) in chains {
            let size = peak * scale
            var carry: CGFloat = 0
            for j in 1..<points.count {
                let a = points[j - 1], b = points[j]
                let len = hypot(b.x - a.x, b.y - a.y)
                var d = carry
                while d <= len {
                    seq += 1
                    let f = d / len
                    let side: CGFloat = CGFloat(noise(seq * 7 + 1) - 0.5) * size * 0.7
                    let nx = -(b.y - a.y) / len, ny = (b.x - a.x) / len
                    let tall = noise(seq * 7 + 2)
                    let s = size * CGFloat(0.55 + 0.75 * tall * tall)
                    let at = CGPoint(x: a.x + (b.x - a.x) * f + nx * side, y: a.y + (b.y - a.y) * f + ny * side * 0.5)
                    peaks.append(MapPeak(base: at, height: s, seed: seq, snow: snowy && s > size * 0.95, cap: nil))
                    d += size * CGFloat(0.32 + 0.22 * noise(seq * 7 + 3))
                }
                carry = d - len
            }
        }
        peaks.append(MapPeak(base: m(0.86, 0.125), height: peak * 1.45, seed: 901, snow: true, cap: nil))     // the Lonely Mountain
        peaks.append(MapPeak(base: m(0.87, 0.722), height: peak * 1.25, seed: 0, snow: false, cap: 0xC0401E)) // Mount Doom, glowing
        for p in peaks.sorted(by: { $0.base.y > $1.base.y }) { drawPeak(c, p, at: snap(p.base, px, r), px: px) }

        // A double border.
        c.setStrokeColor(rgb(ink)); c.setLineWidth(px)
        c.stroke(r.insetBy(dx: 2.5 * px, dy: 2.5 * px))
        c.setStrokeColor(rgb(ink, 0.5))
        c.stroke(r.insetBy(dx: 4.5 * px, dy: 4.5 * px))
    }

    /// One mountain of a chain: where its foot is, how tall, `seed` for its shape, and whether it's snow-capped or
    /// (Mount Doom) has a coloured `cap`.
    struct MapPeak {
        let base: CGPoint, height: CGFloat, seed: Int, snow: Bool, cap: UInt32?
    }

    /// A mountain as the old maps draw them: a jagged peak, its summit leaning a little one way, a shoulder or a
    /// lesser summit on its flanks; lit on the west, its east side shaded and hatched in ink; snow on its top if it's
    /// tall enough (or `cap`, glowing, and a wisp of smoke); inked along its skyline but not its foot, so a chain of
    /// them overlaps into one range.
    static func drawPeak(_ c: CGContext, _ p: MapPeak, at base: CGPoint, px: CGFloat) {
        func g(_ v: CGFloat) -> CGFloat { (v / px).rounded() * px }
        func n(_ i: Int) -> CGFloat { p.cap == nil ? CGFloat(noise(p.seed * 13 + i)) : 0.5 }
        let top = g(p.height), half = g(p.height * (0.7 + 0.3 * n(1)))
        let lean = g((n(2) - 0.5) * half * 0.6)
        let left = CGPoint(x: base.x - half, y: base.y), right = CGPoint(x: base.x + half, y: base.y)
        let summit = CGPoint(x: base.x + lean, y: base.y + top)
        // A point `u` of the way down from the summit to `foot`, pushed out (`bulge` > 0) or in.
        func flank(_ foot: CGPoint, _ u: CGFloat, _ bulge: CGFloat) -> CGPoint {
            let dir: CGFloat = foot.x < summit.x ? -1 : 1
            return CGPoint(x: g(summit.x + (foot.x - summit.x) * u + dir * bulge * half),
                           y: g(summit.y + (foot.y - summit.y) * u + bulge * top * 0.5))
        }
        var west = [left, flank(left, 0.55 + 0.15 * n(3), 0.1 * n(4) - 0.03)]
        var east = [flank(right, 0.3, -0.05 - 0.07 * n(5))]
        if n(6) > 0.45 { east.append(flank(right, 0.5, 0.06 + 0.06 * n(7))) }    // a lesser summit to the east
        else { west.insert(flank(left, 0.8, 0.07 * n(7)), at: 1) }                // or a shoulder to the west
        east.append(right)
        if p.cap != nil { west = [left]; east = [right] }
        let skyline = west + [summit] + east
        let ridgeFoot = CGPoint(x: g(base.x + lean * 0.3 + half * (0.05 + 0.2 * n(8))), y: base.y)
        let shade = [summit] + east + [ridgeFoot]

        c.setFillColor(rgb(0xE0C48C)); c.addLines(between: skyline); c.closePath(); c.fillPath()
        c.setFillColor(rgb(0xC4A066)); c.addLines(between: shade); c.closePath(); c.fillPath()
        // The hatching on the shaded side: strokes down along the eastern slope, three pixels apart.
        c.saveGState()
        c.addLines(between: shade); c.closePath(); c.clip()
        c.setStrokeColor(rgb(0x7E5E36)); c.setLineWidth(px)
        let slope = CGPoint(x: right.x - summit.x, y: right.y - summit.y)
        var x = summit.x - half
        while x < right.x + half {
            c.move(to: CGPoint(x: x, y: summit.y + px)); c.addLine(to: CGPoint(x: x + slope.x * 1.2, y: summit.y + px + slope.y * 1.2))
            x += 3 * px
        }
        c.strokePath()
        c.restoreGState()

        if let cap = p.cap {
            let t = top * 0.3
            c.setFillColor(rgb(cap))
            c.addLines(between: [summit, CGPoint(x: base.x - t * 0.65, y: base.y + top - t), CGPoint(x: base.x + t * 0.65, y: base.y + top - t)])
            c.closePath(); c.fillPath()
            c.setFillColor(rgb(0x6A5A50, 0.6))
            c.fill(CGRect(x: base.x - px, y: base.y + top + px, width: 2 * px, height: 2 * px))
            c.fill(CGRect(x: base.x + px, y: base.y + top + 3 * px, width: 2 * px, height: 2 * px))
        } else if p.snow {
            // Snow down from the summit to a ragged edge, greyer on the shaded side.
            let depth = top * 0.32
            let a = CGPoint(x: summit.x - half, y: g(summit.y - depth)), b = CGPoint(x: summit.x + half, y: g(summit.y - depth))
            var snow = [a]
            let teeth = 3
            for i in 1..<teeth {
                let f = CGFloat(i) / CGFloat(teeth)
                let lift: CGFloat = i % 2 == 1 ? 0.45 : -0.1
                snow.append(CGPoint(x: g(a.x + (b.x - a.x) * f), y: g(a.y + (b.y - a.y) * f + depth * lift)))
            }
            snow += [b, summit]
            c.saveGState()
            c.addLines(between: skyline); c.closePath(); c.clip()
            c.setFillColor(rgb(0xFFFAEC)); c.addLines(between: snow); c.closePath(); c.fillPath()
            c.addLines(between: shade); c.closePath(); c.clip()
            c.setFillColor(rgb(0xCFC6B0)); c.addLines(between: snow); c.closePath(); c.fillPath()
            c.restoreGState()
            c.saveGState()
            c.addLines(between: skyline); c.closePath(); c.clip()
            c.setStrokeColor(rgb(0x9A8C74)); c.setLineWidth(px)
            c.addLines(between: Array(snow.dropLast())); c.strokePath()            // its ragged edge
            c.restoreGState()
        }
        c.setStrokeColor(rgb(ink)); c.setLineWidth(px); c.setLineJoin(.miter)
        c.addLines(between: skyline); c.strokePath()
        // The ridge running down from the summit.
        c.move(to: summit); c.addLine(to: CGPoint(x: g(summit.x + (ridgeFoot.x - summit.x) * 0.45), y: g(summit.y - top * 0.45)))
        c.strokePath()
    }

    /// A round tree on a stub of trunk, inked.
    static func drawTree(_ c: CGContext, _ p: CGPoint, size: CGFloat, dark: Bool, px: CGFloat) {
        c.setFillColor(rgb(ink)); c.fill(CGRect(x: p.x, y: p.y - size - px, width: px, height: 2 * px))
        let crown = CGRect(x: p.x - size, y: p.y - size * 0.6, width: size * 2, height: size * 2)
        c.fillEllipse(in: crown.insetBy(dx: -px * 0.5, dy: -px * 0.5))
        c.setFillColor(rgb(dark ? 0x5E6E34 : 0x7C8C46)); c.fillEllipse(in: crown.insetBy(dx: px * 0.5, dy: px * 0.5))
        c.setFillColor(rgb(0xA8B468)); c.fill(CGRect(x: p.x - px, y: p.y + size * 0.6, width: px, height: px))
    }

    /// A four-pointed compass star, its north arm longest.
    static func compass(_ c: CGContext, _ p: CGPoint, size s: CGFloat, px: CGFloat) {
        let arms: [(CGFloat, CGFloat, CGFloat)] = [(0, 1, 1.3), (1, 0, 1), (0, -1, 1), (-1, 0, 1)]
        let inner = s * 0.22
        for (dx, dy, len) in arms {
            let tip = CGPoint(x: p.x + dx * s * len, y: p.y + dy * s * len)
            let sideA = CGPoint(x: p.x - dy * inner, y: p.y + dx * inner), sideB = CGPoint(x: p.x + dy * inner, y: p.y - dx * inner)
            c.setFillColor(rgb(0xE6CE98)); c.addLines(between: [p, tip, sideA]); c.closePath(); c.fillPath()
            c.setFillColor(rgb(ink)); c.addLines(between: [p, tip, sideB]); c.closePath(); c.fillPath()
            c.setStrokeColor(rgb(ink)); c.setLineWidth(px); c.addLines(between: [sideA, tip, sideB]); c.strokePath()
        }
        c.setFillColor(rgb(0x9E2A1C)); c.fill(CGRect(x: p.x - px, y: p.y + s * 1.3, width: 2 * px, height: 2 * px))
    }

    // MARK: Helpers

    /// A map point (0…1, y downwards) in `r`.
    static func at(_ m: CGPoint, _ r: CGRect) -> CGPoint { CGPoint(x: r.minX + m.x * r.width, y: r.maxY - m.y * r.height) }
    /// `p` moved onto the centre-ish of a pixel of the map's grid.
    static func snap(_ p: CGPoint, _ px: CGFloat, _ r: CGRect) -> CGPoint {
        CGPoint(x: r.minX + ((p.x - r.minX) / px).rounded() * px, y: r.minY + ((p.y - r.minY) / px).rounded() * px)
    }
    /// A smooth curve through `points` (quadratic curves between their midpoints).
    static func smooth(_ points: [CGPoint], closed: Bool = false) -> CGPath {
        let path = CGMutablePath()
        guard points.count > 2 else { path.addLines(between: points); return path }
        path.move(to: points[0])
        for i in 1..<(points.count - 1) {
            let mid = CGPoint(x: (points[i].x + points[i + 1].x) / 2, y: (points[i].y + points[i + 1].y) / 2)
            path.addQuadCurve(to: i == points.count - 2 ? points[i + 1] : mid, control: points[i])
        }
        if closed { path.closeSubpath() }
        return path
    }

    static func ease(_ k: Double) -> Double { k * k * (3 - 2 * k) }
    static func clamp(_ k: Double) -> Double { min(1, max(0, k)) }
    /// How far `k` is through `a…b`: 0 before, 1 after.
    static func span(_ k: Double, _ a: Double, _ b: Double) -> Double { clamp((k - a) / (b - a)) }

    /// An ordered dither: keeps `keep` (0…1) of the art's pixels in a 4×4 Bayer pattern and clears the rest.
    static func dither(_ c: CGContext, width w: Int, height h: Int, keep: Double) {
        guard let data = c.data else { return }
        let bayer: [Int] = [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]
        let level = Int(keep * 16), stride = c.bytesPerRow / 4
        let p = data.bindMemory(to: UInt32.self, capacity: stride * h)
        for y in 0..<h {
            let row = (y & 3) * 4
            for x in 0..<w where bayer[row + (x & 3)] >= level { p[y * stride + x] = 0 }
        }
    }

    /// The rows of the art's grid that fall inside `oval`: one rectangle per row, its ends on the grid, in `r`'s units.
    static func rows(of oval: CGRect, px: CGFloat, height h: Int, in r: CGRect) -> [CGRect] {
        let cx = oval.midX, cy = oval.midY, a = oval.width / 2, b = oval.height / 2
        guard a > 0, b > 0 else { return [] }
        var out: [CGRect] = []
        for j in 0..<h {
            let y: CGFloat = r.minY + (CGFloat(j) + 0.5) * px
            let d: CGFloat = (y - cy) / b
            guard abs(d) < 1 else { continue }
            let half: CGFloat = a * (1 - d * d).squareRoot()
            let x0: CGFloat = max(0, ((cx - half - r.minX) / px).rounded())
            let x1: CGFloat = min((r.width / px).rounded(.up), ((cx + half - r.minX) / px).rounded())
            if x1 > x0 { out.append(CGRect(x: r.minX + x0 * px, y: r.minY + CGFloat(j) * px, width: (x1 - x0) * px, height: px)) }
        }
        return out
    }

    /// A clear bitmap `width`×`height`, set up so that drawing into it in `r`'s units lands on its grid, unsmoothed.
    static func artCanvas(width w: Int, height h: Int, px: CGFloat, in r: CGRect) -> CGContext? {
        guard w > 0, h > 0, let c = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                                              space: CGColorSpaceCreateDeviceRGB(),
                                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        c.setShouldAntialias(false)
        c.scaleBy(x: 1 / px, y: 1 / px)
        c.translateBy(x: -r.minX, y: -r.minY)
        return c
    }

    /// The art, scaled up onto `r` without smoothing.
    static func blit(_ art: CGContext, onto ctx: CGContext, width w: Int, height h: Int, px: CGFloat, in r: CGRect) {
        guard let img = art.makeImage() else { return }
        ctx.saveGState()
        ctx.clip(to: r)
        ctx.interpolationQuality = .none
        ctx.draw(img, in: CGRect(x: r.minX, y: r.minY, width: CGFloat(w) * px, height: CGFloat(h) * px))
        ctx.restoreGState()
    }
}
