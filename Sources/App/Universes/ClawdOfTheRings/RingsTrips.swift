import CoreGraphics
import Foundation

/// The trips between Clawd of the Rings places.
enum RingsWipe: Int, CaseIterable {
    case eye        // the old place sinks into embers, a lidless Eye of fire opens, and its pupil swallows the frame
    case map        // the old place yellows into the map of Middle-earth; a dotted line walks from where the crew was to
                    // where it's going, and the new place opens out of its end (RingsMapTrip.swift)
    case redBook    // the old place becomes a page of the Red Book, which turns to the new place on the page behind,
                    // its name in red letters at the top (RingsBookTrip.swift)
    case eagles     // a Great Eagle swoops across and carries the view off to the new place (RingsEagleTrip.swift)
    case ring       // the Ring goes on: the world turns wraith-grey and smeared, and clears on the new place
                    // (RingsRingTrip.swift)
    case beacons    // the beacons of Gondor light from peak to peak, and the last one's fire opens on the new place
                    // (RingsBeaconTrip.swift)
    case mirror     // the old place ripples into the silver basin of Gladriel's Mirror, and the new one surfaces
                    // (RingsMirrorTrip.swift)
    case fireworks  // one of Gandclawd's rockets bursts into a fiery dragon, and the new place shows in the sparks
                    // (RingsFireworksTrip.swift)
    case palantir   // the view clouds into a seeing-stone, a fiery glimpse, and clears on the new place
                    // (RingsPalantirTrip.swift)

    var duration: Double {
        switch self {
        case .eye: return 1.4
        case .map: return 2.4
        case .redBook: return 2.0
        case .eagles: return 2.2
        case .ring: return 2.0
        case .beacons: return 2.4
        case .mirror: return 2.2
        case .fireworks: return 2.2
        case .palantir: return 2.0
        }
    }

    /// Who makes it likelier (on stage when the crew moves on), as in Detective Clawds' trips.
    var owners: [Cast] {
        switch self {
        case .eye: return [.villain(.sauron), .villain(.necromancer), .villain(.mouthOfSauron), .villain(.witchKing), .villain(.nazgul)]
        case .map: return [.hero(.bilbo), .hero(.frodo), .hero(.sam), .hero(.strider)]
        case .redBook: return [.hero(.bilbo), .hero(.frodo), .hero(.sam)]
        case .eagles: return [.hero(.gandalf), .hero(.gandalfWhite), .hero(.frodo), .hero(.sam), .hero(.radagast)]
        case .ring: return [.hero(.frodo), .hero(.bilbo), .villain(.gollum)]
        case .beacons: return [.hero(.pippin), .hero(.gandalfWhite), .villain(.denethor), .hero(.theoden), .hero(.aragorn)]
        case .mirror: return [.hero(.galadriel), .hero(.celeborn), .hero(.haldir)]
        case .fireworks: return [.hero(.gandalf), .hero(.bilbo)]
        case .palantir: return [.villain(.saruman), .villain(.denethor), .hero(.pippin), .hero(.aragorn)]
        }
    }

    /// Where it's likelier to go.
    var turf: [Location] {
        switch self {
        case .eye: return [.mountDoom, .blackGate, .dolGuldur]
        case .map: return [.bagEnd, .rivendell]
        case .redBook, .fireworks: return [.bagEnd, .greenDragon]
        case .eagles: return [.mountDoom, .isengard]
        case .ring: return [.bagEnd, .mountDoom]
        case .beacons: return [.minasTirith, .edoras]
        case .mirror: return [.lothlorien]
        case .palantir: return [.isengard, .minasTirith]
        }
    }
}

/// One trip's transition. Shared by the window and the screen saver, which hand over the old picture (frozen), the
/// new one (as it is right now) and how far through it is; a frame is drawn over the whole of `r`. Sizes are against
/// an 800-pixel-tall frame.
struct RingsTrip {
    let kind: RingsWipe
    /// Where the crew was and where it's going: the map draws the journey between them.
    var from: Location = .bagEnd, to: Location = .bagEnd
    var duration: Double { kind.duration }
    /// How much of the crew shows at `k` (`ComicTransition.crewShown`): only the Eagle's flight leaves the ground.
    func crewShown(_ k: Double) -> Double { kind == .eagles ? Self.eagleCrewShown(k) : 1 }

    /// Any trip but the last one's kind, likelier with one of its owners on stage or going to its turf, from `from`
    /// (the Shire, when it isn't known or is in another universe, as in Clawd Royale) to `place`.
    static func pick(after last: RingsWipe?, cast: [Cast], from: Location?, to place: Location) -> RingsTrip {
        let here = Set(cast)
        var kinds: [RingsWipe] = []
        for kind in RingsWipe.allCases where kind != last {
            kinds.append(kind)
            if kind.owners.contains(where: here.contains) { kinds += [kind, kind, kind] }
            if kind.turf.contains(place) { kinds += [kind, kind] }
        }
        let start = from.flatMap { $0.universe == .middleEarth ? $0 : nil } ?? .bagEnd
        return RingsTrip(kind: kinds.randomElement() ?? .eye, from: start, to: place)
    }

    // MARK: Drawing

    private static func ease(_ k: Double) -> Double { k * k * (3 - 2 * k) }
    private static func clamp(_ k: Double) -> Double { min(1, max(0, k)) }
    /// How far `k` is through `a…b`: 0 before, 1 after.
    private static func span(_ k: Double, _ a: Double, _ b: Double) -> Double { clamp((k - a) / (b - a)) }

    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`.
    func draw(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        ctx.saveGState(); defer { ctx.restoreGState() }
        ctx.interpolationQuality = .none
        switch kind {
        case .eye: drawEye(ctx, old: old, new: new, k: k, in: r)
        case .map: drawMap(ctx, old: old, new: new, k: k, in: r)
        case .redBook: drawBook(ctx, old: old, new: new, k: k, in: r)
        case .eagles: drawEagles(ctx, old: old, new: new, k: k, in: r)
        case .ring: drawRing(ctx, old: old, new: new, k: k, in: r)
        case .beacons: drawBeacons(ctx, old: old, new: new, k: k, in: r)
        case .mirror: drawMirror(ctx, old: old, new: new, k: k, in: r)
        case .fireworks: drawFireworks(ctx, old: old, new: new, k: k, in: r)
        case .palantir: drawPalantir(ctx, old: old, new: new, k: k, in: r)
        }
    }

    /// The old place darkens to embers (0–0.3); the Eye opens across the middle, fire with a slit pupil (0.3–0.55);
    /// the pupil widens past the frame with the new place inside it (0.55–0.85); the Eye's burning rim peels outward
    /// and fades over the new place (0.85–1). The places are drawn as they are; everything of the Eye's own (the
    /// darkening, embers, fire, veins, pupil and rim) is drawn as pixel art: into a bitmap about 180 pixels tall, in
    /// stepped bands of colour, then scaled up without smoothing. The pupil that lets the new place through is cut on
    /// that same grid.
    private func drawEye(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let s = r.height / 800
        let px: CGFloat = max(1, (r.height / 180).rounded())  // screen pixels per pixel of the Eye's art
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = Self.artCanvas(width: w, height: h, px: px, in: r) else { return }
        let centre = CGPoint(x: r.midX, y: r.midY)
        let halfWidth = r.width * 0.46, fullHalfHeight = r.height * 0.35
        let open = Self.ease(Self.span(k, 0.3, 0.55))
        let widen = Self.span(k, 0.55, 0.85)
        let peel = Self.ease(Self.span(k, 0.85, 1))
        let halfHeight = fullHalfHeight * CGFloat(open)

        if k >= 0.85 {
            // The new place everywhere, the Eye's rim peeling outward, thicker and fainter.
            ctx.setFillColor(rgb(0x000000)); ctx.fill(r); ctx.drawShot(new, in: r)
            let grow = 1 + CGFloat(peel) * 0.6
            let rim = Self.almond(centre, halfWidth: halfWidth * grow, halfHeight: fullHalfHeight * grow)
            let fade = CGFloat(1 - peel)
            Self.burn(art, rim, width: (8 + 60 * CGFloat(peel)) * s, core: (3 + 18 * CGFloat(peel)) * s,
                      glow: (18 + 30 * CGFloat(peel)) * s, alpha: fade, px: px)
            Self.blit(art, onto: ctx, width: w, height: h, px: px, in: r)
            return
        }

        // The old place, darkening, embers rising off it.
        ctx.drawShot(old, in: r)
        let dark = Self.clamp(k / 0.3)
        art.setFillColor(rgb(0x000000, CGFloat(dark * 0.7))); art.fill(r)
        drawEmbers(art, k: k, strength: min(1, dark * 2), in: r)

        // The pupil, worked out on the art's grid: a slit while the Eye opens, then widening past the frame.
        let slitWidth = r.width * 0.04 * CGFloat(Self.ease(Self.span(k, 0.36, 0.5)))
        let slitHalfHeight = halfHeight * 0.88
        let grow = CGFloat(pow(widen, 2.5))
        let pupilHalfWidth = slitWidth / 2 + (r.width * 0.75 - slitWidth / 2) * grow
        let pupilHalfHeight = slitHalfHeight + (r.height * 0.75 - slitHalfHeight) * grow
        let pupil = CGRect(x: centre.x - pupilHalfWidth, y: centre.y - pupilHalfHeight,
                           width: pupilHalfWidth * 2, height: pupilHalfHeight * 2)
        let hole: [CGRect] = widen > 0 ? Self.rows(of: pupil, px: px, height: h, in: r) : []
        if !hole.isEmpty {
            // The new place, through the pupil, out of the dark.
            ctx.saveGState()
            ctx.clip(to: hole)
            ctx.setFillColor(rgb(0x000000)); ctx.fill(r); ctx.drawShot(new, in: r)
            ctx.setFillColor(rgb(0x000000, CGFloat(1 - Self.ease(Self.span(k, 0.55, 0.72))))); ctx.fill(r)
            ctx.restoreGState()
        }

        if k >= 0.3 {
            // A glow of fire around the Eye.
            let glow: [Stop] = [Stop(0, 0xFF8A1E, CGFloat(0.45 * open)), Stop(0.5, 0x8A1E0A, CGFloat(0.25 * open)), Stop(1, 0x8A1E0A, 0)]
            Self.bands(art, centre: centre, radius: halfWidth * 1.25, stops: glow, count: 6, beyond: nil)

            // The Eye: an almond of fire, veined, with the pupil in it. Once the pupil starts to widen, the fire floods
            // out over the rest of the frame too, so that what the pupil doesn't cover burns.
            let lid = Self.almond(centre, halfWidth: halfWidth, halfHeight: max(halfHeight, 1.5 * s))
            let fire: [Stop] = [Stop(0, 0xFFE08A, 1), Stop(0.4, 0xFF8A1E, 1), Stop(1, 0x8A1E0A, 1)]
            let flood = CGFloat(Self.ease(Self.span(k, 0.55, 0.75)))
            if flood > 0 {
                art.saveGState()
                art.setAlpha(flood)
                Self.bands(art, centre: centre, radius: halfWidth * 1.1, stops: fire, count: 7, beyond: r)
                art.restoreGState()
            }
            art.saveGState()
            art.addPath(lid); art.clip()
            Self.bands(art, centre: centre, radius: halfWidth * 0.85, stops: fire, count: 7, beyond: r)
            drawVeins(art, centre: centre, reach: halfWidth, k: k, s: s, px: px)
            if hole.isEmpty && pupilHalfWidth > 0.5 {             // the slit, black, kept inside the Eye
                art.setFillColor(rgb(0x000000)); art.fillEllipse(in: pupil)
            }
            art.restoreGState()

            if !hole.isEmpty {
                // The pupil's edge burns: black, with fire bleeding out of it.
                art.saveGState()
                art.setBlendMode(.clear); art.fill(hole)
                art.restoreGState()
                art.addEllipse(in: pupil); art.setStrokeColor(rgb(0xFF8A1E, 0.3)); art.setLineWidth(40 * s); art.strokePath()
                art.addEllipse(in: pupil); art.setStrokeColor(rgb(0xFF8A1E, 0.5)); art.setLineWidth(22 * s); art.strokePath()
                art.addEllipse(in: pupil); art.setStrokeColor(rgb(0x120604)); art.setLineWidth(max(px, 10 * s)); art.strokePath()
            }

            // The lid's burning rim, over everything.
            Self.burn(art, lid, width: 8 * s, core: 3 * s, glow: 18 * s, alpha: 1, px: px)
        }
        Self.blit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }

    /// One stop of a stepped gradient: at `at` (0…1 of the radius), colour `hex` at `alpha`.
    private struct Stop {
        let at: CGFloat, hex: UInt32, alpha: CGFloat
        init(_ at: CGFloat, _ hex: UInt32, _ alpha: CGFloat) { self.at = at; self.hex = hex; self.alpha = alpha }
    }

    /// The colour `u` (0…1) of the way along `stops`.
    private static func colour(at u: CGFloat, _ stops: [Stop]) -> CGColor {
        guard let last = stops.last else { return rgb(0x000000, 0) }
        var i = 0
        while i + 1 < stops.count && stops[i + 1].at < u { i += 1 }
        guard i + 1 < stops.count, u > stops[i].at else { return u <= stops[0].at ? rgb(stops[0].hex, stops[0].alpha) : rgb(last.hex, last.alpha) }
        let a = stops[i], b = stops[i + 1]
        let f: CGFloat = (u - a.at) / max(0.0001, b.at - a.at)
        func mix(_ shift: UInt32) -> CGFloat {
            let x = CGFloat(a.hex >> shift & 0xFF), y = CGFloat(b.hex >> shift & 0xFF)
            return (x + (y - x) * f) / 255
        }
        return CGColor(red: mix(16), green: mix(8), blue: mix(0), alpha: a.alpha + (b.alpha - a.alpha) * f)
    }

    /// A radial gradient in `count` solid rings, and `beyond` (if given) filled with its last colour. Drawn as discs,
    /// outermost first, each replacing what's under it in a layer of its own, so no pixel is painted twice.
    private static func bands(_ ctx: CGContext, centre: CGPoint, radius: CGFloat, stops: [Stop], count n: Int, beyond: CGRect?) {
        func circle(_ rr: CGFloat) -> CGRect { CGRect(x: centre.x - rr, y: centre.y - rr, width: rr * 2, height: rr * 2) }
        ctx.saveGState(); defer { ctx.restoreGState() }
        ctx.beginTransparencyLayer(auxiliaryInfo: nil)
        ctx.setBlendMode(.copy)
        if let out = beyond { ctx.setFillColor(colour(at: 1, stops)); ctx.fill(out) }
        for i in stride(from: n - 1, through: 0, by: -1) {
            ctx.setFillColor(colour(at: CGFloat(i) / CGFloat(n), stops))
            ctx.fillEllipse(in: circle(radius * CGFloat(i + 1) / CGFloat(n)))
        }
        ctx.endTransparencyLayer()
    }

    /// A burning rim along `path`: steps of orange glow out to `glow` either side, an orange band `width` wide and a
    /// yellow core `core` wide, all at `alpha`.
    private static func burn(_ ctx: CGContext, _ path: CGPath, width: CGFloat, core: CGFloat, glow: CGFloat, alpha: CGFloat, px: CGFloat) {
        guard alpha > 0 else { return }
        let steps: [(CGFloat, UInt32, CGFloat)] = [(width + glow * 2, 0xFF8A1E, 0.18), (width + glow, 0xFF8A1E, 0.3),
                                                   (max(px, width), 0xFF8A1E, 0.9), (max(px, core), 0xFFE08A, 0.8)]
        for (lineWidth, hex, a) in steps {
            ctx.addPath(path); ctx.setStrokeColor(rgb(hex, a * alpha)); ctx.setLineWidth(lineWidth); ctx.strokePath()
        }
    }

    /// The rows of the art's grid that fall inside `oval`: one rectangle per row, its ends on the grid, in `r`'s units.
    private static func rows(of oval: CGRect, px: CGFloat, height h: Int, in r: CGRect) -> [CGRect] {
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
    private static func artCanvas(width w: Int, height h: Int, px: CGFloat, in r: CGRect) -> CGContext? {
        guard w > 0, h > 0, let c = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                                              space: CGColorSpaceCreateDeviceRGB(),
                                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        c.setShouldAntialias(false)
        c.scaleBy(x: 1 / px, y: 1 / px)
        c.translateBy(x: -r.minX, y: -r.minY)
        return c
    }

    /// The art, scaled up onto `r` without smoothing.
    private static func blit(_ art: CGContext, onto ctx: CGContext, width w: Int, height h: Int, px: CGFloat, in r: CGRect) {
        guard let img = art.makeImage() else { return }
        ctx.saveGState()
        ctx.clip(to: r)
        ctx.interpolationQuality = .none
        ctx.draw(img, in: CGRect(x: r.minX, y: r.minY, width: CGFloat(w) * px, height: CGFloat(h) * px))
        ctx.restoreGState()
    }

    /// Orange and yellow embers, square like the art's pixels, drifting up from the bottom of the frame.
    private func drawEmbers(_ ctx: CGContext, k: Double, strength: Double, in r: CGRect) {
        guard strength > 0 else { return }
        let s = r.height / 800, px = 4 * s
        let colours: [Int] = [0xFF8A1E, 0xFFE08A, 0xFF5A14]
        for i in 0..<44 {
            let speed: Double = 0.5 + 0.8 * noise(i * 7 + 2)
            let rise: Double = noise(i * 7 + 3) + k * speed * 1.4
            let up: Double = rise - floor(rise)
            let sway: Double = sin(k * 9 + Double(i) * 1.7) * 14
            let x = r.minX + CGFloat(noise(i * 7 + 1)) * r.width + CGFloat(sway) * s
            let y = r.minY + CGFloat(up) * r.height
            let size = px * CGFloat(1 + Int(noise(i * 7 + 4) * 2.99))
            let flicker: Double = 0.75 + 0.25 * noise(i * 13 + Int(k * 30))
            let alpha = CGFloat(strength * min(1, (1 - up) / 0.3) * flicker)
            guard alpha > 0.02 else { continue }
            ctx.setFillColor(rgb(UInt32(colours[i % colours.count]), alpha))
            ctx.fill(CGRect(x: (x / px).rounded() * px, y: (y / px).rounded() * px, width: size, height: size))
        }
    }

    /// Streaks of brighter and darker fire radiating from the pupil, flickering; at least a pixel of the art wide.
    private func drawVeins(_ ctx: CGContext, centre: CGPoint, reach: CGFloat, k: Double, s: CGFloat, px: CGFloat) {
        let flick = Int(k * 24)
        let full: Double = 2 * .pi
        for i in 0..<28 {
            let a: Double = full * (Double(i) + noise(i * 5 + 1) * 0.6) / 28
            let inner = reach * CGFloat(0.06 + 0.06 * noise(i * 5 + 2))
            let outer = reach * CGFloat(0.55 + 0.4 * noise(i * 5 + 3 + flick))
            let bright = i % 2 == 0
            ctx.setStrokeColor(bright ? rgb(0xFFE08A, 0.35) : rgb(0x5A1006, 0.35))
            ctx.setLineWidth(bright ? max(px, 3 * s) : max(px * 2, 5 * s))
            ctx.move(to: CGPoint(x: centre.x + inner * CGFloat(cos(a)), y: centre.y + inner * CGFloat(sin(a))))
            ctx.addLine(to: CGPoint(x: centre.x + outer * CGFloat(cos(a)), y: centre.y + outer * CGFloat(sin(a))))
            ctx.strokePath()
        }
    }

    /// An almond (two circular arcs meeting at points left and right of `c`), `halfHeight` above and below it.
    private static func almond(_ c: CGPoint, halfWidth a: CGFloat, halfHeight hh: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let radius = (a * a + hh * hh) / (2 * hh)
        let theta = CGFloat(atan2(Double(radius - hh), Double(a)))
        let half: CGFloat = .pi
        // The upper arc, its circle's centre below the eye: from the right point over the top to the left one.
        path.addArc(center: CGPoint(x: c.x, y: c.y + hh - radius), radius: radius,
                    startAngle: theta, endAngle: half - theta, clockwise: false)
        // The lower arc, its circle's centre above: from the left point under the bottom back to the right one.
        path.addArc(center: CGPoint(x: c.x, y: c.y - hh + radius), radius: radius,
                    startAngle: half + theta, endAngle: 2 * half - theta, clockwise: false)
        path.closeSubpath()
        return path
    }
}

extension RingsTrip: Trip {}
