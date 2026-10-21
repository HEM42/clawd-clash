import CoreGraphics
import Foundation

// The Model Town Flyover (`BurtonWipe.flyover`): dusk over a hill town, a spider walks into view, enormous; it's the
// model on the attic table, and the camera dives in through the model house's front door into the new place.

extension BurtonTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. Dusk clouds roll in over the old place
    /// from both sides and close (0–0.09); they part on Winter River at dusk, and the camera glides low over its
    /// rooftops and steeple, across the river by the red covered bridge and up the lane to the white house on its
    /// hill (0.09–0.5). A spider walks into view from the right, enormous, and as its body passes over the camera
    /// (0.33–0.5) we're in the attic: the camera pulls back off it and it's a little spider on Adam's model of the
    /// town, picking its way across the table (0.5–0.7). Then the camera dives at the model house's lit front door,
    /// the new place glowing small inside it (0.7–0.92), and the door opens out into the whole of it (0.9–0.99). The
    /// town and the attic are the places' own pixel art, seen through the camera; the clouds and the spider are
    /// pixel art too.
    func drawFlyover(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.draw(old, in: r); return }
        guard k < 1, let art = Self.flyoverArt else { ctx.draw(k < 1 ? old : new, in: r); return }
        let t = k * duration
        ctx.saveGState(); ctx.clip(to: r)
        defer { ctx.restoreGState() }
        let fit = max(r.width / CGFloat(art.size.w), r.height / CGFloat(art.size.h))
        let bigW = max(r.width * 1.4, r.height * 3.2)
        let cut = 0.5
        if k < cut {
            flyoverTown(ctx, old: old, k: k, art: art, fit: fit, in: r)
            // The spider walking in from the right, close to the camera, its body over the middle at the cut, its
            // shadow darkening everything as it passes.
            if k > 0.33 {
                let walk = Self.span(k, 0.33, cut), from = r.maxX + bigW * 0.42
                let p = CGPoint(x: from + (r.midX - from) * walk, y: r.midY)
                ctx.setFillColor(rgb(0x000000, 0.45 * Self.span(k, 0.42, cut))); ctx.fill(r)
                Self.flyoverSpider(ctx, at: p, width: bigW, t: t, alpha: 1)
            }
            return
        }
        // The attic: off the spider and back until the model shows, then in at the model house's door.
        let sW = 22.0, pull = 1 - pow(1 - Self.span(k, cut, 0.7), 3), dive = Self.span(k, 0.7, 0.92)
        let spider = (x: 300.0 - (k - cut) * duration * 26, y: 92.0)
        let zoom0 = Double(bigW / fit) / sW, settled = (x: 215.0, y: 100.0), rest = 1.12
        var zoom = exp(log(zoom0) + (log(rest) - log(zoom0)) * pull)
        // The spider slides steadily from the middle of the screen to where it is on the pulled-back view.
        let landed = Self.flyoverMap(spider, in: r, fit: fit, focus: settled, zoom: rest, size: art.size)
        let seen = (x: Double(r.midX + (landed.x - r.midX) * CGFloat(pull)),
                    y: Double(r.midY + (landed.y - r.midY) * CGFloat(pull)))
        var focus = (x: spider.x - (seen.x - Double(r.midX)) / (Double(fit) * zoom),
                     y: spider.y + (seen.y - Double(r.midY)) / (Double(fit) * zoom))
        let door = art.door
        if dive > 0 {
            // The door's place on screen moves steadily to the middle while the camera closes in on it.
            let doorZoom = Double(r.height / fit) / door.h * 0.72
            zoom = exp(log(rest) + (log(doorZoom) - log(rest)) * pow(dive, 1.3))
            let from = Self.flyoverMap((door.x, door.y), in: r, fit: fit, focus: settled, zoom: rest, size: art.size)
            let e = Self.ease(dive), sc = Double(fit) * zoom
            let at = (x: Double(from.x + (r.midX - from.x) * e), y: Double(from.y + (r.midY - from.y) * e))
            focus = (x: door.x - (at.x - Double(r.midX)) / sc, y: door.y + (at.y - Double(r.midY)) / sc)
        }
        focus = Self.flyoverShoot(ctx, art.model, in: r, fit: fit, focus: focus, zoom: zoom)
        let shadow = 0.45 * (1 - Self.span(k, cut, 0.56))
        if shadow > 0 { ctx.setFillColor(rgb(0x000000, shadow)); ctx.fill(r) }
        if dive < 0.3 {
            let p = Self.flyoverMap(spider, in: r, fit: fit, focus: focus, zoom: zoom, size: art.size)
            let w = CGFloat(sW * Double(fit) * zoom)
            Self.flyoverSpider(ctx, at: p, width: w, t: t, alpha: 1 - Self.span(dive, 0, 0.3))
        }
        // The door, lamplit, the new place small inside it; then it opens out over everything.
        let sc = CGFloat(Double(fit) * zoom)
        let d = Self.flyoverMap((door.x, door.y), in: r, fit: fit, focus: focus, zoom: zoom, size: art.size)
        let doorRect = CGRect(x: d.x - CGFloat(door.w) / 2 * sc, y: d.y - CGFloat(door.h) / 2 * sc,
                              width: CGFloat(door.w) * sc, height: CGFloat(door.h) * sc)
        let open = CGFloat(Self.ease(Self.span(k, 0.9, 0.99))), wide = r.insetBy(dx: -2, dy: -2)
        let portal = CGRect(x: doorRect.minX + (wide.minX - doorRect.minX) * open,
                            y: doorRect.minY + (wide.minY - doorRect.minY) * open,
                            width: doorRect.width + (wide.width - doorRect.width) * open,
                            height: doorRect.height + (wide.height - doorRect.height) * open)
        let s = min(1, max(portal.width / r.width, portal.height / r.height))
        let nw = r.width * s, nh = r.height * s
        let ncx = min(max(portal.midX, r.minX + nw / 2), r.maxX - nw / 2)
        let ncy = min(max(portal.midY, r.minY + nh / 2), r.maxY - nh / 2)
        ctx.saveGState(); ctx.clip(to: portal)
        ctx.draw(new, in: CGRect(x: ncx - nw / 2, y: ncy - nh / 2, width: nw, height: nh))
        ctx.setFillColor(rgb(0xFFC860, 0.5 * (1 - 0.6 * dive) * Double(1 - open))); ctx.fill(portal)
        ctx.restoreGState()
    }

    /// The first half: the old place under the closing dusk clouds, then the camera gliding over the town at dusk as
    /// they part.
    private func flyoverTown(_ ctx: CGContext, old: CGImage, k: Double, art: FlyoverArt, fit: CGFloat, in r: CGRect) {
        let close = Self.ease(Self.span(k, 0, 0.09)), part = Self.ease(Self.span(k, 0.09, 0.22))
        if k < 0.09 {
            ctx.draw(old, in: r)
            ctx.setFillColor(rgb(0x3A1A5A, 0.45 * close)); ctx.fill(r)
        } else {
            // Along a curve from the rooftops and the steeple, down over the river by the bridge, up to the house.
            let glide = Self.ease(Self.span(k, 0.07, 0.52)), u = 1 - glide
            let a = (x: 80.0, y: 96.0), b = (x: 20.0, y: 150.0), c = (x: 222.0, y: 112.0)
            let focus = (x: u * u * a.x + 2 * u * glide * b.x + glide * glide * c.x,
                         y: u * u * a.y + 2 * u * glide * b.y + glide * glide * c.y)
            let zoom = 1.5 + 0.4 * glide
            Self.flyoverShoot(ctx, art.town, in: r, fit: fit, focus: focus, zoom: zoom)
            let life = PixelCanvas(Int(art.size.w), Int(art.size.h))
            Location.maitlandHouse.drawAnimated(life, floorRows: Self.flyoverFloor, t: k * duration)
            if let img = life.makeImage() { Self.flyoverShoot(ctx, img, in: r, fit: fit, focus: focus, zoom: zoom) }
            ctx.setFillColor(rgb(0x3A1A5A, 0.42)); ctx.fill(r)
            ctx.setFillColor(rgb(0xFF8A3A, 0.12))
            ctx.fill(CGRect(x: r.minX, y: r.minY, width: r.width, height: r.height / 2))
        }
        Self.flyoverClouds(ctx, cover: close * (1 - part), k: k, in: r)
    }

    /// The rows under the places' pictures the crew stands on, in the camera's pictures.
    private static let flyoverFloor = 18

    /// The camera's two pictures, the town and the attic; the model house's front door on the attic's (its middle and
    /// size, in the picture's pixels, y down); and the pictures' size.
    private typealias FlyoverArt = (town: CGImage, model: CGImage, door: (x: Double, y: Double, w: Double, h: Double),
                                    size: (w: Double, h: Double))

    /// The town and the attic, drawn once as one fixed, screen-saver-sized picture each for the camera to look over;
    /// a lamplit front door added to the model house.
    private static let flyoverArt: FlyoverArt? = {
        let w = 400, h = 225, g = h - flyoverFloor
        let town = PixelCanvas(w, h), model = PixelCanvas(w, h)
        Location.maitlandHouse.drawStatic(town, floorRows: flyoverFloor)
        Location.modelWinterRiver.drawStatic(model, floorRows: flyoverFloor)
        let f = Scenes.mtFrame(model, g), hp = Scenes.mtAt(f, 0.86, 0.06), u = f.k
        model.rect(hp.x - 2 * u - 1, hp.y - 7 * u - 1, u + 2, 2 * u + 1, C(0xC8C8C0))
        model.rect(hp.x - 2 * u, hp.y - 7 * u, u, 2 * u, C(0xFFD27A))
        guard let a = town.makeImage(), let b = model.makeImage() else { return nil }
        let door = (x: Double(hp.x - 2 * u) + Double(u) / 2, y: Double(hp.y - 7 * u) + Double(u),
                    w: Double(u), h: Double(2 * u))
        return (a, b, door, (Double(w), Double(h)))
    }()

    /// A picture seen through the camera over `r`: `zoom` times the size that covers `r`, its point `focus` (pixels,
    /// y down) in the middle, kept from showing past the picture's edges. Gives back the focus it used.
    @discardableResult
    private static func flyoverShoot(_ ctx: CGContext, _ img: CGImage, in r: CGRect, fit: CGFloat,
                                     focus: (x: Double, y: Double), zoom: Double) -> (x: Double, y: Double) {
        let sc = Double(fit) * zoom, iw = Double(img.width), ih = Double(img.height)
        let vw = Double(r.width) / sc / 2, vh = Double(r.height) / sc / 2
        let f = (x: min(max(focus.x, vw), iw - vw), y: min(max(focus.y, vh), ih - vh))
        ctx.saveGState(); ctx.interpolationQuality = .none
        ctx.draw(img, in: CGRect(x: Double(r.midX) - f.x * sc, y: Double(r.midY) + f.y * sc - ih * sc,
                                 width: iw * sc, height: ih * sc))
        ctx.restoreGState()
        return f
    }

    /// Where a point on the camera's picture (pixels, y down) lands on screen.
    private static func flyoverMap(_ p: (x: Double, y: Double), in r: CGRect, fit: CGFloat,
                                   focus: (x: Double, y: Double), zoom: Double,
                                   size: (w: Double, h: Double)) -> CGPoint {
        let sc = Double(fit) * zoom
        let vw = Double(r.width) / sc / 2, vh = Double(r.height) / sc / 2
        let f = (x: min(max(focus.x, vw), size.w - vw), y: min(max(focus.y, vh), size.h - vh))
        return CGPoint(x: Double(r.midX) + (p.x - f.x) * sc, y: Double(r.midY) - (p.y - f.y) * sc)
    }

    /// Dusk clouds, banks of them in from both sides, `cover` 0 gone, 1 met in the middle: three layers of billows,
    /// darkest at the back, the leading ones catching the last of the light along their rims.
    private static func flyoverClouds(_ ctx: CGContext, cover: Double, k: Double, in r: CGRect) {
        guard cover > 0.001 else { return }
        let (c, px) = pixelCanvas(in: r)
        let W = Double(c.w), H = Double(c.h)
        let layers: [(back: Double, size: Double, body: Px, rim: Px)] = [
            (0, 0.17, C(0x4A3068), C(0x8A6AB0)), (0.7, 0.23, C(0x3A2456), C(0x5A3E7E)),
            (1.5, 0.3, C(0x2A1840), C(0x3A2456)),
        ]
        let warm = C(0xE08A4A)
        for side in [0, 1] {
            let reach = -W * 0.25 + (W * 0.56 + W * 0.25) * cover
            for (i, layer) in layers.enumerated() {
                let bulge = max(4, H * layer.size)
                for y in 0..<c.h {
                    // Billows: round lumps down the edge, drifting down.
                    let yy = Double(y) + Double(side * 3 + i) * bulge * 0.37 + k * H * (0.5 - Double(i) * 0.12)
                    let m = yy.truncatingRemainder(dividingBy: bulge * 2) - bulge
                    let lump = bulge * (1 - m * m / (bulge * bulge)).squareRoot() * 0.8
                    let edge = reach + lump - bulge * (0.35 + layer.back)
                    let n = Int(edge.rounded())
                    guard n > 0 else { continue }
                    c.rect(side == 0 ? 0 : c.w - n, y, n, 1, layer.body)
                    let tip = side == 0 ? n - 1 : c.w - n
                    c.px(tip, y, Double(y) > H * 0.55 && i == 0 ? warm : layer.rim)
                    if i == 0 { c.px(side == 0 ? tip - 1 : tip + 1, y, layer.rim.alpha(0.5)) }
                }
            }
        }
        blitCanvas(c, onto: ctx, px: px, in: r)
    }

    /// The giant spider, seen from above and walking left: a black body with a glint of red eyes, eight jointed legs
    /// stepping in turn. `width` screen points across, centred on `p`.
    private static func flyoverSpider(_ ctx: CGContext, at p: CGPoint, width: CGFloat, t: Double, alpha: Double) {
        guard width > 2, alpha > 0.01 else { return }
        let c = PixelCanvas(44, 30), ink = C(0x0C0A08), sheen = C(0x2A2620)
        for side in [-1.0, 1.0] {
            for leg in 0..<4 {
                let phase = sin(t * 9 + Double(leg) * 1.6 + (side > 0 ? .pi : 0)), spread = Double(leg) - 1.5
                let hip = (x: 18.0 + Double(leg) * 2.5, y: 15.0)
                let knee = (x: hip.x + spread * 5 + phase * 1.5, y: hip.y + side * (6 + abs(spread)))
                let foot = (x: knee.x + spread * 4 + phase * 2, y: hip.y + side * (13 - abs(spread) * 0.8))
                burtonLine(c, hip.x, hip.y, knee.x, knee.y, ink, 0.9)
                burtonLine(c, knee.x, knee.y, foot.x, foot.y, ink, 0.7)
            }
        }
        c.ellipse(26, 15, 8, 6, ink); c.ellipse(25, 13, 4, 2, sheen)
        c.circle(15, 15, 4, ink); c.px(12, 14, C(0xC8202A)); c.px(12, 16, C(0xC8202A))
        c.addOutline(C(0xFFFFFF, 0.25))
        guard let img = c.makeImage() else { return }
        let h = width * 30 / 44
        ctx.saveGState(); ctx.setAlpha(CGFloat(alpha)); ctx.interpolationQuality = .none
        ctx.draw(img, in: CGRect(x: p.x - width / 2, y: p.y - h / 2, width: width, height: h))
        ctx.restoreGState()
    }
}
