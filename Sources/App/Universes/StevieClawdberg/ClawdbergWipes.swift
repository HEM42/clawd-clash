import AppKit
import CoreText

/// Stevie Clawdberg's trips between places, a different one each time, each one a moment out of one of the films: the
/// bike across the moon, the DeLorean hitting 88, the red line across the map, the fin, the camera flash the gremlins
/// hate, the park's gates, the five tones, the boulder, the fairy dust and One-Eyed Willy's doubloon. Drawn in the app's
/// pixel art (every frame is put together a cell to an art pixel and scaled up crisp), in rich blockbuster colour.
/// Whoever's on screen, and where it's going, bring their own up more often.
enum ClawdbergWipe: Int, CaseIterable {
    case moonBike     // night falls, the full moon rises, the bike flies across it, and the moon opens on the new place
    case eightyEight  // the DeLorean streaks across crackling blue, flashes out, and its two fire trails part on the new place
    case mapRoute     // an old map unrolls; the red line travels from here to there behind the plane; the map dissolves
    case fin          // the water rises, a dorsal fin cuts across with the new place behind it, and the water sinks away
    case flashbulb    // a camera flash: white-out, the flash's ring burnt into the eye, fading onto the new place
    case parkGates    // the huge wooden gates under their torches close on the old place and swing open on the new
    case fiveTones    // five coloured light panels play the five tones in turn, each one lighting up a strip of the new place
    case boulder      // the giant boulder rolls across in a cloud of dust, and the new place is in its wake
    case pixieDust    // a gold trail of fairy dust loops across, and the new place appears where it sparkles
    case doubloon     // the gold doubloon flips and grows, the old place on one face and the new on the other

    var duration: Double {
        switch self {
        case .moonBike: return 3.0
        case .eightyEight: return 2.4
        case .mapRoute: return 2.8
        case .fin: return 2.4
        case .flashbulb: return 2.0
        case .parkGates: return 2.6
        case .fiveTones: return 2.6
        case .boulder: return 2.2
        case .pixieDust: return 2.6
        case .doubloon: return 2.6
        }
    }

    /// Whose it is: with one of them on screen it comes up more often.
    func isOwned(by c: Cast) -> Bool {
        guard c.universe == .clawdberg else { return false }
        if c.isDark {
            guard let v = ClawdbergVillain(rawValue: c.index) else { return false }
            switch self {
            case .eightyEight: return v == .oldBiff
            case .fin: return v == .bruise || v == .mayorVaun
            case .flashbulb: return [.strype, .mohawk, .theBrain, .batGremlin, .electricGremlin, .greta, .daffy].contains(v)
            case .parkGates: return [.tWrecks, .cleverGirl, .spitter, .dennisNerdry, .indominusRex, .gennarrow, .drWoo,
                                     .compy].contains(v)
            case .boulder: return v == .reneBellock
            case .pixieDust: return v == .captainClawk
            case .doubloon: return [.oneEyedWilly, .mamaFratelly, .jakeFratelly, .francisFratelly].contains(v)
            default: return false
            }
        }
        guard let h = ClawdbergHero(rawValue: c.index) else { return false }
        switch self {
        case .moonBike: return [.eClawd, .elliclawd, .gurtie].contains(h)
        case .eightyEight: return [.martyMcFry, .docBrawn, .jenniferParka, .einsteinDog].contains(h)
        case .mapRoute: return [.indianaBones, .marion, .shortRounds, .willieScoot, .sallaw, .henryBones, .marcusBrodie,
                                .grailKnight, .mutt, .helenaShore].contains(h)
        case .fin: return [.chiefBroody, .hoopah, .squint].contains(h)
        case .flashbulb: return h == .kateBeringer || h == .gizmoe
        case .parkGates: return [.alanGrand, .ellieSaddler, .ianMalclawm, .johnHammend, .muldune, .timMurphey, .lexMurphey,
                                 .rayArnie, .owenGravy, .claireDaring, .blue, .trike].contains(h)
        case .fiveTones: return [.royNeery, .jillianGeyser, .littleBarry, .clawdLacombe, .tallVisitor].contains(h)
        case .boulder: return h == .indianaBones
        case .pixieDust: return [.peterPanning, .tinkerbelle, .roofio, .thudButt, .tootles].contains(h)
        case .doubloon: return [.mikeyWaltz, .brandWaltz, .chunk, .mouth, .data, .andyCarmichaw, .stefSteinclawd,
                                .slawth].contains(h)
        }
    }

    /// Its home turf: a trip there brings it up more often too.
    var turf: [Location] {
        switch self {
        case .moonBike: return [.moonHill, .elliottStreet]
        case .eightyEight: return [.hillValley1955, .biffsParadise, .hillValley1885]
        case .mapRoute: return [.idolTemple, .wellOfSouls, .templeOfDoom, .grailTemple]
        case .fin: return [.amityBeach, .orca]
        case .flashbulb: return [.kingstonFalls, .wingShop, .clampCentre]
        case .parkGates: return [.parkGates, .visitorCentre, .rexPaddock]
        case .fiveTones: return [.devilsTower]
        case .boulder: return [.idolTemple]
        case .pixieDust: return [.neverland, .pirateTown, .jollyRoger]
        case .doubloon: return [.goondocks, .inferno]
        }
    }
}

/// One trip's transition. Shared by the window and the screen saver, which hand over the old picture (frozen), the new
/// one (as it is right now) and how far through it is; a frame is drawn over the whole of `r`.
struct ClawdbergTrip {
    let kind: ClawdbergWipe
    /// Where it's coming from and going to: the map needs both to mark them.
    var from: Location? = nil
    var to: Location? = nil
    var duration: Double { kind.duration }

    /// Any transition but the last one, those of whoever's on screen and of the place it's going to weighted up.
    static func pick(after last: ClawdbergWipe?, cast: [Cast], from: Location?, to place: Location) -> ClawdbergTrip {
        var kinds: [ClawdbergWipe] = []
        for kind in ClawdbergWipe.allCases where kind != last {
            kinds.append(kind)
            if cast.contains(where: kind.isOwned) { kinds += [kind, kind, kind] }
            if kind.turf.contains(place) { kinds += [kind, kind] }
        }
        return ClawdbergTrip(kind: kinds.randomElement() ?? .moonBike, from: from, to: place)
    }

    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`: put together at one cell per art
    /// pixel, then scaled up without smoothing.
    func draw(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        // While the window changes universe (`ComicTransition.snapshotQuality`), the pictures are the window itself, its
        // text among them: the frame is put together at their own resolution, so the text isn't cut into cells, or as
        // near it as about half a million pixels a frame allows (a big Retina window, at every other pixel).
        let cell = ComicTransition.snapshotQuality != nil ? max(1, (r.width * r.height / 500_000).squareRoot().rounded(.up))
            : max(1, (max(r.height / CGFloat(max(1, old.height)), r.height / 200)).rounded(.down))
        let w = max(8, Int((r.width / cell).rounded())), h = max(8, Int((r.height / cell).rounded()))
        guard let lo = CBLo(w, h) else { ctx.drawShot(k < 0.5 ? old : new, in: r); return }
        let k = min(1, max(0, k))
        switch kind {
        case .moonBike: drawMoonRide(lo, old: old, new: new, k: k)
        case .eightyEight: drawEightyEight(lo, old: old, new: new, k: k)
        case .mapRoute: drawMapRoute(lo, old: old, new: new, k: k)
        case .fin: drawFin(lo, old: old, new: new, k: k)
        case .flashbulb: drawFlashbulb(lo, old: old, new: new, k: k)
        case .parkGates: drawParkGates(lo, old: old, new: new, k: k)
        case .fiveTones: drawFiveTones(lo, old: old, new: new, k: k)
        case .boulder: drawBoulder(lo, old: old, new: new, k: k)
        case .pixieDust: drawPixieDust(lo, old: old, new: new, k: k)
        case .doubloon: drawDoubloon(lo, old: old, new: new, k: k)
        }
        guard let img = lo.ctx.makeImage() else { return }
        ctx.saveGState()
        ctx.interpolationQuality = .none
        ctx.draw(img, in: r)
        ctx.restoreGState()
    }

    // MARK: Timing

    private static func ease(_ k: Double) -> Double { k * k * (3 - 2 * k) }
    private static func clamp(_ k: Double) -> Double { min(1, max(0, k)) }
    /// How far `k` is through `a…b`: 0 before, 1 after.
    private static func span(_ k: Double, _ a: Double, _ b: Double) -> Double { clamp((k - a) / (b - a)) }
    /// Up over `a…b`, down over `c…d`.
    private static func bump(_ k: Double, _ a: Double, _ b: Double, _ c: Double, _ d: Double) -> Double {
        span(k, a, b) * (1 - span(k, c, d))
    }

    /// How far it is from `c` to the frame's furthest corner.
    private static func farthest(_ lo: CBLo, from c: CGPoint) -> CGFloat {
        let dx = max(c.x, CGFloat(lo.w) - c.x), dy = max(c.y, CGFloat(lo.h) - c.y)
        return hypot(dx, dy)
    }

    /// One of the rides' pictures (66×29, nose to the right), or all one colour.
    private static func ride(_ paint: (PixelCanvas) -> Void, silhouette: UInt32? = nil) -> CGImage? {
        let c = PixelCanvas(66, 29)
        paint(c)
        guard let img = c.makeImage() else { return nil }
        guard let silhouette, let lo = CBLo(66, 29) else { return img }
        lo.image(img)
        lo.ctx.setBlendMode(.sourceIn)
        lo.fill(silhouette)
        return lo.ctx.makeImage()
    }

    /// A character's sprite, running.
    private static func sprite(_ who: Cast, t: Double) -> CGImage? {
        let c = PixelCanvas(Sprite.width, Sprite.height)
        who.draw(c, t: t, mode: .working, walking: true, role: .none, asSession: false)
        return c.makeImage()
    }

    // MARK: The moon bike

    /// The old place sinks into a blue night and the stars come out; a huge full moon rises behind it, and the boy on
    /// his bike, the little alien in the basket, flies across its face in silhouette. Then the moon swells into a round
    /// iris and its light gives way to the new place.
    private func drawMoonRide(_ lo: CBLo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        lo.image(old)
        let dusk = Self.ease(Self.span(k, 0, 0.22))
        lo.night(dusk)
        Self.stars(lo, amount: dusk, k: k)
        let r0 = (h * 0.3).rounded()
        let rest = CGPoint(x: (w * 0.6).rounded(), y: (h * 0.56).rounded())
        let rise = Self.ease(Self.span(k, 0.05, 0.4))
        let low = -r0 - 6
        let my = (low + (rest.y - low) * CGFloat(rise)).rounded()
        let c = CGPoint(x: rest.x, y: my)
        let open = Self.span(k, 0.68, 0.97)
        let far = Self.farthest(lo, from: c) + 2
        let r = (r0 + (far - r0) * CGFloat(Self.ease(open))).rounded()
        // Inside the iris, the new place; the moon's face pales off it as it opens.
        if open > 0 {
            lo.ctx.saveGState()
            lo.ctx.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)); lo.ctx.clip()
            lo.image(new)
            lo.ctx.restoreGState()
        }
        let face = 1 - Self.span(open, 0.05, 0.5)
        let horizon = open == 0 ? Int(h / 8) : 0   // it rises from behind the ground
        Self.moon(lo, at: c, radius: r, face: face, halo: 1 - Self.span(open, 0.5, 1), above: horizon)
        // The bike, across the moon.
        let fly = Self.span(k, 0.27, 0.7)
        if fly > 0, fly < 1, let bike = Self.ride({ drawMoonBike($0, ramp: 0, lit: true) }, silhouette: 0x06070D) {
            let sc = max(1, (h / 180).rounded(.down))
            let bw = 66 * sc, bh = 29 * sc
            let bx = (-bw + (w + bw) * CGFloat(fly)).rounded()
            let lift = (bx + bw / 2 - rest.x) * 0.3
            let bob = CGFloat(sin(fly * 14)) * sc
            let by = (rest.y - bh * 0.45 + lift + bob).rounded()
            lo.image(bike, CGRect(x: bx, y: by, width: bw, height: bh))
        }
    }

    /// The night's stars, twinkling, over the top two thirds.
    private static func stars(_ lo: CBLo, amount: Double, k: Double) {
        guard amount > 0.01 else { return }
        let w = Double(lo.w), h = Double(lo.h)
        for i in 0..<70 {
            let x = Int(noise(i * 3 + 11) * w), y = Int(h * (0.34 + noise(i * 3 + 12) * 0.66))
            let tw = 0.55 + 0.45 * sin(k * 24 + Double(i) * 1.7)
            lo.put(x, y, i % 9 == 0 ? 0xFFF4D0 : 0xE8EEFF, amount * tw)
            if i % 13 == 0 {
                let a = amount * tw * 0.5
                lo.put(x - 1, y, 0xC8D4FF, a); lo.put(x + 1, y, 0xC8D4FF, a)
                lo.put(x, y - 1, 0xC8D4FF, a); lo.put(x, y + 1, 0xC8D4FF, a)
            }
        }
    }

    /// The full moon: a pale disc with its seas, darker toward its rim, in a soft blue halo. `face` 1 the whole moon …
    /// 0 none (only the halo round where it is). Nothing of it below row `above`.
    private static func moon(_ lo: CBLo, at c: CGPoint, radius r: CGFloat, face: Double, halo: Double, above: Int = 0) {
        let reach = r * 1.3
        let x0 = max(0, Int(c.x - reach)), x1 = min(lo.w - 1, Int(c.x + reach))
        let y0 = max(above, Int(c.y - reach)), y1 = min(lo.h - 1, Int(c.y + reach))
        guard x0 <= x1, y0 <= y1 else { return }
        let rd = Double(r)
        for y in y0...y1 {
            for x in x0...x1 {
                let dx = Double(x) + 0.5 - Double(c.x), dy = Double(y) + 0.5 - Double(c.y)
                let d = (dx * dx + dy * dy).squareRoot() / rd
                if d > 1 {
                    guard halo > 0.01, d < 1.3 else { continue }
                    let fall = 1 - (d - 1) / 0.3
                    if d > 1.15, (x + y) % 2 == 0 { continue }
                    lo.put(x, y, 0xB8CCFF, halo * 0.3 * fall * fall)
                    continue
                }
                guard face > 0.01 else { continue }
                let u = dx / rd * 2.6, v = dy / rd * 2.6
                let sea = cbNoise(u + 7.3, v + 2.1) * 0.7 + cbNoise(u * 2.3 + 1, v * 2.3 + 5) * 0.3
                var col: UInt32 = 0xFBF8E8
                if sea > 0.62 { col = 0xD9D5C0 } else if sea > 0.55 { col = 0xE8E4D0 }
                if d > 0.9 { col = cbLerp(col, 0xCFCAB4, 0.6) } else if d > 0.8 { col = cbLerp(col, 0xDEDAC6, 0.4) }
                lo.put(x, y, col, face)
            }
        }
    }

    // MARK: 88 miles per hour

    /// The DeLorean comes tearing in along the ground, faster and faster, blue sparks crackling over it; at 88 it's
    /// gone in a white flash, and the two lines of fire it leaves behind part, one up and one down, on the new place.
    private func drawEightyEight(_ lo: CBLo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        lo.image(old)
        let ground = (h * 0.08).rounded()
        let vanish = 0.44
        let part = Self.ease(Self.span(k, 0.52, 0.95))
        let upper = (ground + 2 + (h + 6 - ground) * CGFloat(part)).rounded()
        let lower = (ground - (ground + 6) * CGFloat(part)).rounded()
        if part > 0 {
            lo.ctx.saveGState()
            lo.ctx.clip(to: CGRect(x: 0, y: lower, width: w, height: upper - lower))
            lo.image(new)
            lo.ctx.restoreGState()
        }
        // Where the car is: off on the left, then faster and faster to where it goes.
        let drive = Self.span(k, 0.02, vanish)
        let endX = (w * 0.84).rounded()
        let carX = (-70 + (endX + 70) * CGFloat(drive * drive)).rounded()
        let tail = k < vanish ? carX + 8 : endX + 8 + (w - endX) * CGFloat(Self.ease(Self.span(k, vanish, 0.54)))
        let burn = 1 - Self.span(k, 0.86, 1)
        let start = (w * -0.02)
        if tail > 0 {
            Self.fire(lo, y: upper, from: start, to: tail, seed: Int(k * 50), alpha: burn)
            Self.fire(lo, y: lower, from: start, to: tail, seed: Int(k * 50) + 7, alpha: burn)
        }
        if k < vanish, let car = Self.ride({ drawDelorean($0, ramp: 0, lit: true) }) {
            let speed = drive * drive
            // Streaks of light off the back of it, longer the faster it goes.
            for i in 0..<7 {
                let sy = ground + 6 + CGFloat(noise(i * 5 + 40) * 18).rounded()
                let len = CGFloat(10 + 60 * speed) * CGFloat(0.5 + noise(i * 5 + 41))
                lo.fill(0xBFD8FF, CGFloat(0.25 + 0.4 * speed), CGRect(x: carX + 6 - len, y: sy, width: len, height: 1))
            }
            lo.ctx.setFillColor(cbRGB(0x6AA8FF, CGFloat(0.12 + 0.3 * speed)))
            lo.ctx.fillEllipse(in: CGRect(x: carX - 4, y: ground - 4, width: 74, height: 34))
            lo.image(car, CGRect(x: carX, y: ground - 4, width: 66, height: 29))
            Self.arcs(lo, around: CGRect(x: carX + 4, y: ground + 2, width: 58, height: 20), count: 2 + Int(speed * 9),
                      seed: Int(k * 70))
        }
        // The flash where it went.
        let fl = Self.bump(k, vanish - 0.03, vanish, vanish + 0.02, 0.6)
        if fl > 0 {
            let fc = CGPoint(x: endX + 50, y: ground + 12)
            for (rr, a) in [(1.0, 0.25), (0.6, 0.5), (0.3, 0.9)] as [(CGFloat, CGFloat)] {
                let rad = h * 0.9 * rr * CGFloat(0.4 + fl)
                lo.ctx.setFillColor(cbRGB(0xE8F2FF, a * CGFloat(fl)))
                lo.ctx.fillEllipse(in: CGRect(x: fc.x - rad, y: fc.y - rad, width: rad * 2, height: rad * 2))
            }
            lo.fill(0xF6FAFF, CGFloat(Self.bump(k, vanish - 0.02, vanish + 0.01, vanish + 0.04, 0.58)))
        }
    }

    /// A line of fire along row `y`, `x0` to `x1`, flames licking up off it.
    private static func fire(_ lo: CBLo, y: CGFloat, from x0: CGFloat, to x1: CGFloat, seed: Int, alpha: Double) {
        guard alpha > 0.01 else { return }
        let yy = Int(y), a = Int(max(0, x0)), b = Int(min(CGFloat(lo.w), x1))
        guard a < b else { return }
        for x in a..<b {
            let n = cbHash(x, seed, 5) % 100
            let tall = 1 + n % 4
            // Fainter toward the far end, where it's freshest.
            let fade = min(1, Double(b - x) / 6 + 0.3)
            let al = alpha * fade
            lo.put(x, yy - 1, 0xFF6A1A, al * 0.5)
            lo.put(x, yy, n < 50 ? 0xFFF4B0 : 0xFFE060, al)
            for t in 1...tall {
                let col: UInt32 = t == 1 ? 0xFFB02A : t == 2 ? 0xFF7A1A : 0xD8401A
                lo.put(x, yy + t, col, al * (1 - Double(t) * 0.18))
            }
        }
    }

    /// Blue time-travel sparks: jagged little arcs jumping off `body`.
    private static func arcs(_ lo: CBLo, around body: CGRect, count: Int, seed: Int) {
        let ctx = lo.ctx
        for i in 0..<count {
            let s = seed * 31 + i * 7
            var p = CGPoint(x: body.minX + CGFloat(noise(s)) * body.width, y: body.minY + CGFloat(noise(s + 1)) * body.height)
            let path = CGMutablePath()
            path.move(to: p)
            let dir = noise(s + 2) * 2 * .pi
            for j in 0..<4 {
                let a = dir + (noise(s + 3 + j) - 0.5) * 1.6
                let step = CGFloat(3 + noise(s + 8 + j) * 4)
                p = CGPoint(x: p.x + CGFloat(cos(a)) * step, y: p.y + CGFloat(sin(a)) * step)
                path.addLine(to: p)
            }
            ctx.addPath(path); ctx.setStrokeColor(cbRGB(0x3A7AFF, 0.7)); ctx.setLineWidth(2); ctx.strokePath()
            ctx.addPath(path); ctx.setStrokeColor(cbRGB(0xEAF4FF)); ctx.setLineWidth(1); ctx.strokePath()
        }
    }

    // MARK: The map route

    /// An old parchment map unrolls over the old place; a red line travels across it from where the trip is coming
    /// from to where it's going, the little plane flying along it; then the map dissolves into the new place.
    private func drawMapRoute(_ lo: CBLo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        lo.image(old)
        guard let map = CBLo(lo.w, lo.h) else { return }
        Self.parchment(map)
        let a = Self.spot(from, seed: 1, in: map), b0 = Self.spot(to, seed: 2, in: map)
        var b = b0
        if hypot(b.x - a.x, b.y - a.y) < w * 0.35 { b = CGPoint(x: w - a.x, y: h - a.y) }
        let along = Self.ease(Self.span(k, 0.2, 0.7))
        Self.route(map, from: a, to: b, along: along)
        let unroll = Self.ease(Self.span(k, 0, 0.18))
        guard let paper = map.ctx.makeImage() else { return }
        if unroll < 1 {
            let half = (w / 2 * CGFloat(unroll)).rounded()
            let clip = CGRect(x: w / 2 - half, y: 0, width: half * 2, height: h)
            lo.ctx.saveGState(); lo.ctx.clip(to: clip); lo.image(paper); lo.ctx.restoreGState()
            // The rolls at either side, still wound up.
            for x in [clip.minX - 4, clip.maxX - 1] {
                lo.fill(0xA8884E, 1, CGRect(x: x, y: 0, width: 5, height: h))
                lo.fill(0xD8BC82, 1, CGRect(x: x + 1, y: 0, width: 2, height: h))
                lo.fill(0x6A4E26, 1, CGRect(x: x + 4, y: 0, width: 1, height: h))
            }
        } else {
            lo.image(paper)
        }
        let melt = Self.span(k, 0.74, 0.97)
        if melt > 0, let next = CBLo(lo.w, lo.h) {
            next.image(new)
            lo.scatter(from: next, amount: melt, block: 2, seed: 17)
        }
    }

    /// Where a place is on the map: somewhere of its own, from its name.
    private static func spot(_ l: Location?, seed: Int, in lo: CBLo) -> CGPoint {
        var v: UInt32 = 2166136261 &+ UInt32(seed)
        for u in (l?.rawValue ?? "nowhere").unicodeScalars { v = (v ^ u.value) &* 16777619 }
        let u = 0.14 + Double(v % 1000) / 999 * 0.72
        let t = 0.22 + Double((v / 1000) % 1000) / 999 * 0.56
        return CGPoint(x: (CGFloat(u) * CGFloat(lo.w)).rounded(), y: (CGFloat(t) * CGFloat(lo.h)).rounded())
    }

    /// Old yellowed parchment: blotched and stained, burnt dark at the edges, with inked coastlines, hatched seas, little
    /// mountains, faint lines of longitude and a compass rose.
    private static func parchment(_ lo: CBLo) {
        let w = lo.w, h = lo.h
        for y in 0..<h {
            for x in 0..<w {
                let fx = Double(x), fy = Double(y)
                let blot = cbNoise(fx * 0.05, fy * 0.05) * 0.6 + cbNoise(fx * 0.17 + 3, fy * 0.17) * 0.4
                var col = cbLerp(0xEEDCAA, 0xD2B880, blot)
                let land = cbNoise(fx * 0.017 + 3.5, fy * 0.026 + 11) * 0.8 + cbNoise(fx * 0.06, fy * 0.06 + 4) * 0.2
                if land > 0.56 { col = cbLerp(col, 0xC8A86C, 0.35) }
                if abs(land - 0.56) < 0.011 { col = 0x6A4A26 }
                if land < 0.5, (x + y * 3) % 9 == 0, cbHash(x / 9, y / 3, 4) % 3 == 0 { col = cbLerp(col, 0x8A6A3A, 0.5) }
                if x % 40 == 20, y % 3 != 0 { col = cbLerp(col, 0xA88A58, 0.4) }
                if y % 40 == 20, x % 3 != 0 { col = cbLerp(col, 0xA88A58, 0.4) }
                let edge = Double(min(min(x, w - 1 - x), min(y, h - 1 - y)))
                let burn = edge + cbNoise(fx * 0.2, fy * 0.2) * 5
                if burn < 4 { col = 0x4A3216 } else if burn < 8 { col = cbLerp(col, 0x7A5A2E, 0.6) }
                else if burn < 14 { col = cbLerp(col, 0x9A7A46, 0.3) }
                lo.put(x, y, col, 1)
            }
        }
        // Mountains, on the land.
        for i in 0..<26 {
            let x = Int(noise(i * 4 + 70) * Double(w - 30)) + 15, y = Int(noise(i * 4 + 71) * Double(h - 30)) + 15
            let land = cbNoise(Double(x) * 0.017 + 3.5, Double(y) * 0.026 + 11) * 0.8
                + cbNoise(Double(x) * 0.06, Double(y) * 0.06 + 4) * 0.2
            guard land > 0.62 else { continue }
            for d in 0..<4 { lo.put(x - d, y - d, 0x5A3E1E, 0.9); lo.put(x + d, y - d, 0x5A3E1E, 0.9) }
            lo.put(x + 1, y - 2, 0x8A6A3A, 0.6)
        }
        // The compass rose.
        let cx = Int(Double(w) * 0.12), cy = Int(Double(h) * 0.2)
        lo.ctx.setStrokeColor(cbRGB(0x6A4A26, 0.85)); lo.ctx.setLineWidth(1)
        lo.ctx.strokeEllipse(in: CGRect(x: cx - 8, y: cy - 8, width: 17, height: 17))
        for d in -12...12 {
            let a = 1 - Double(abs(d)) / 13
            lo.put(cx + d, cy, 0x6A4A26, a); lo.put(cx, cy + d, 0x6A4A26, a)
        }
        for d in -5...5 { lo.put(cx + d, cy + d, 0x8A6A3A, 0.7); lo.put(cx + d, cy - d, 0x8A6A3A, 0.7) }
        lo.put(cx, cy + 13, 0xA0201A); lo.put(cx - 1, cy + 12, 0xA0201A); lo.put(cx + 1, cy + 12, 0xA0201A)
    }

    /// The red line from `a`, `along` of the way to `b` on a gentle curve, the plane at its head; both places marked.
    private static func route(_ lo: CBLo, from a: CGPoint, to b: CGPoint, along: Double) {
        let mid = CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
        let dx = b.x - a.x, dy = b.y - a.y
        let bend = CGPoint(x: mid.x - dy * 0.25, y: mid.y + dx * 0.25)
        func at(_ s: Double) -> CGPoint {
            let t = CGFloat(s), u = 1 - t
            let x = u * u * a.x + 2 * u * t * bend.x + t * t * b.x
            let y = u * u * a.y + 2 * u * t * bend.y + t * t * b.y
            return CGPoint(x: x, y: y)
        }
        for p in [a, b] {   // the dots, ringed
            lo.ctx.setFillColor(cbRGB(0x4A1A10)); lo.ctx.fillEllipse(in: CGRect(x: p.x - 4, y: p.y - 4, width: 9, height: 9))
            lo.ctx.setFillColor(cbRGB(0xC8281C)); lo.ctx.fillEllipse(in: CGRect(x: p.x - 3, y: p.y - 3, width: 7, height: 7))
            lo.put(Int(p.x) - 1, Int(p.y) + 1, 0xF07060)
        }
        guard along > 0 else { return }
        let steps = 160
        let last = Int(Double(steps) * along)
        for i in 0...last {
            let p = at(Double(i) / Double(steps))
            lo.fill(0x9A1810, 1, CGRect(x: p.x.rounded() - 1, y: p.y.rounded() - 2, width: 3, height: 3))
            lo.fill(0xD8301E, 1, CGRect(x: p.x.rounded() - 1, y: p.y.rounded() - 1, width: 2, height: 2))
        }
        guard along < 0.995 else { return }
        let head = at(along), ahead = at(min(1, along + 0.01))
        let heading = atan2(ahead.y - head.y, ahead.x - head.x)
        lo.ctx.saveGState()
        lo.ctx.translateBy(x: head.x.rounded(), y: head.y.rounded())
        lo.ctx.rotate(by: heading)
        let plane = CGMutablePath()   // seen from above: fuselage, wings, tailplane
        plane.addRect(CGRect(x: -8, y: -1.5, width: 16, height: 3))
        plane.addRect(CGRect(x: 0, y: -9, width: 4, height: 18))
        plane.addRect(CGRect(x: -8, y: -4, width: 3, height: 8))
        lo.ctx.addPath(plane); lo.ctx.setFillColor(cbRGB(0x2A2016)); lo.ctx.fillPath()
        lo.ctx.setFillColor(cbRGB(0x5A4A36)); lo.ctx.fill(CGRect(x: 1, y: -8, width: 1, height: 16))
        lo.ctx.restoreGState()
    }

    // MARK: The fin

    /// The water comes up over the bottom of the old place; a grey dorsal fin cuts across it, the new place behind it
    /// wherever it's been, foam peeling off it; then the water goes back down.
    private func drawFin(_ lo: CBLo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        let up = Self.ease(Self.span(k, 0, 0.24)), down = Self.ease(Self.span(k, 0.76, 1))
        let top = h * 0.42
        let level = (-8 + (top + 8) * CGFloat(up * (1 - down))).rounded()
        let cross = Self.span(k, 0.2, 0.8)
        let fw = (h * 0.3).rounded(), fh = (h * 0.3).rounded()
        let fx = (w + fw - (w + fw * 2) * CGFloat(cross)).rounded()
        let seam = fx + fw * 0.3
        lo.image(old)
        if cross > 0 {
            lo.ctx.saveGState()
            lo.ctx.clip(to: CGRect(x: seam, y: 0, width: w - seam + 1, height: h))
            lo.image(new)
            lo.ctx.restoreGState()
        }
        let bob = CGFloat(sin(k * 22)) * 0.8
        if cross > 0, cross < 1 { Self.dorsal(lo, base: CGPoint(x: fx, y: level - fh * 0.12 + bob), width: fw, height: fh) }
        Self.water(lo, level: level, k: k)
        if cross > 0, cross < 1, level > 0 { Self.wake(lo, fin: fx, width: fw, level: level, k: k) }
    }

    /// The fin, its base centred on `base`, swept back to the right (it swims to the left).
    private static func dorsal(_ lo: CBLo, base: CGPoint, width fw: CGFloat, height fh: CGFloat) {
        let ctx = lo.ctx
        let front = CGPoint(x: base.x - fw * 0.5, y: base.y)
        let tip = CGPoint(x: base.x + fw * 0.22, y: base.y + fh)
        let back = CGPoint(x: base.x + fw * 0.38, y: base.y)
        let lead = CGPoint(x: base.x - fw * 0.15, y: base.y + fh * 0.8)
        let trail = CGPoint(x: base.x + fw * 0.12, y: base.y + fh * 0.38)
        let fin = CGMutablePath()
        fin.move(to: front); fin.addQuadCurve(to: tip, control: lead); fin.addQuadCurve(to: back, control: trail)
        fin.closeSubpath()
        ctx.addPath(fin); ctx.setFillColor(cbRGB(0x58626E)); ctx.fillPath()
        // A paler flank toward the front, the shadow along the back edge.
        ctx.saveGState()
        ctx.addPath(fin); ctx.clip()
        let flank = CGMutablePath()
        flank.move(to: CGPoint(x: front.x - 2, y: front.y))
        flank.addQuadCurve(to: CGPoint(x: tip.x - 3, y: tip.y), control: CGPoint(x: lead.x - 2, y: lead.y))
        flank.addLine(to: CGPoint(x: base.x - fw * 0.05, y: base.y)); flank.closeSubpath()
        ctx.addPath(flank); ctx.setFillColor(cbRGB(0x7A8692)); ctx.fillPath()
        ctx.restoreGState()
        let edge = CGMutablePath()
        edge.move(to: front); edge.addQuadCurve(to: tip, control: lead)
        ctx.addPath(edge); ctx.setStrokeColor(cbRGB(0xB0BCC8)); ctx.setLineWidth(1); ctx.strokePath()
        let rear = CGMutablePath()
        rear.move(to: tip); rear.addQuadCurve(to: back, control: trail)
        ctx.addPath(rear); ctx.setStrokeColor(cbRGB(0x2A3038)); ctx.setLineWidth(1); ctx.strokePath()
    }

    /// The sea up to `level`: deep blue below, a rolling foam line on top, glints of light on it.
    private static func water(_ lo: CBLo, level: CGFloat, k: Double) {
        guard level > -4 else { return }
        let lv = Double(level), depth = max(8, Double(lo.h) * 0.42)
        for x in 0..<lo.w {
            let fx = Double(x)
            let wave = sin(fx * 0.14 + k * 12) * 1.2 + sin(fx * 0.05 - k * 6) * 0.9
            let s = Int((lv + wave).rounded())
            guard s >= 0 else { continue }
            for y in 0...min(lo.h - 1, s) {
                let d = Double(s - y) / depth
                var col = cbLerp(0x2E8AC4, 0x0A2E58, min(1, d * 1.3))
                if (y + Int(k * 30)) % 7 == 0, cbHash(x / 6, y, Int(k * 12)) % 5 == 0 { col = cbLerp(col, 0x6AC0E8, 0.5) }
                let top = s - y
                if top == 0 { col = 0xEAF6FF } else if top == 1 { col = 0x9AD4F0 } else if top == 2 { col = 0x4AA2D4 }
                lo.put(x, y, col, top < 2 ? 1 : 0.9)
            }
        }
    }

    /// Foam peeling off the fin: spray at its front, a white wake fanning out behind it.
    private static func wake(_ lo: CBLo, fin fx: CGFloat, width fw: CGFloat, level: CGFloat, k: Double) {
        let y = Int(level)
        for i in 0..<36 {
            let along = Double(i) / 36
            let x = Int(fx + fw * 0.3) + Int(along * Double(fw) * 2.4)
            let spread = Int(along * 5)
            let a = (1 - along) * 0.9
            guard cbHash(i, Int(k * 30), 3) % 3 != 0 else { continue }
            lo.put(x, y + 1 + spread / 2, 0xF4FAFF, a)
            lo.put(x, y - spread, 0xDDEEFA, a * 0.8)
        }
        for i in 0..<10 {   // the spray at the front
            let x = Int(fx - fw * 0.5) - Int(noise(i * 3 + Int(k * 40)) * 6)
            let yy = y + 1 + Int(noise(i * 3 + 1 + Int(k * 40)) * 4)
            lo.put(x, yy, 0xF4FAFF, 0.85)
        }
    }

    // MARK: The flashbulb

    /// A camera goes off in your face: a starburst, a white-out, then the bright ring of the flash burnt into the eye,
    /// drifting and turning colour as it fades, over the new place coming back up out of the white.
    private func drawFlashbulb(_ lo: CBLo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        let c = CGPoint(x: w / 2, y: h * 0.55)
        lo.image(k < 0.12 ? old : new)
        let pop = Self.span(k, 0, 0.1)
        if k < 0.12 {
            Self.starburst(lo, at: c, size: h * CGFloat(0.15 + 1.2 * pop * pop), alpha: 0.4 + 0.6 * pop)
            lo.fill(0xFFFFF4, CGFloat(pow(pop, 2.5)))
            return
        }
        let white = 1 - Self.ease(Self.span(k, 0.16, 0.8))
        lo.fill(0xFFFFF6, CGFloat(white))
        let after = Self.bump(k, 0.12, 0.22, 0.5, 0.96)
        guard after > 0.01 else { return }
        let t = Self.span(k, 0.14, 0.9)
        let col = t < 0.5 ? cbLerp(0xE8FFFF, 0xFF6AD8, t * 2) : cbLerp(0xFF6AD8, 0x6AFF9A, t * 2 - 1)
        let drift = CGPoint(x: c.x + CGFloat(sin(k * 4)) * 6 - CGFloat(t) * 10, y: c.y + CGFloat(cos(k * 3)) * 4)
        Self.afterimage(lo, at: drift, radius: h * CGFloat(0.2 + 0.06 * t), colour: col, alpha: after)
    }

    /// A flash's glint: long rays out of a hot white middle.
    private static func starburst(_ lo: CBLo, at c: CGPoint, size s: CGFloat, alpha: Double) {
        let ctx = lo.ctx
        for i in 0..<8 {
            let a = Double(i) * .pi / 4
            let long = i % 2 == 0 ? s : s * 0.45
            let ex = c.x + CGFloat(cos(a)) * long, ey = c.y + CGFloat(sin(a)) * long
            ctx.move(to: c); ctx.addLine(to: CGPoint(x: ex, y: ey))
            ctx.setStrokeColor(cbRGB(0xFFF8D8, CGFloat(alpha))); ctx.setLineWidth(i % 2 == 0 ? 3 : 1); ctx.strokePath()
        }
        for (r, a) in [(0.35, 0.3), (0.2, 0.6), (0.08, 1.0)] as [(CGFloat, CGFloat)] {
            let rad = s * r
            ctx.setFillColor(cbRGB(0xFFFFF0, a * CGFloat(alpha)))
            ctx.fillEllipse(in: CGRect(x: c.x - rad, y: c.y - rad, width: rad * 2, height: rad * 2))
        }
    }

    /// The flash's ring, burnt in: a bright band, brighter in its segments, round a dim dark spot.
    private static func afterimage(_ lo: CBLo, at c: CGPoint, radius r: CGFloat, colour: UInt32, alpha: Double) {
        let reach = Int(r) + 6
        let rd = Double(r)
        for y in max(0, Int(c.y) - reach)...min(lo.h - 1, Int(c.y) + reach) {
            for x in max(0, Int(c.x) - reach)...min(lo.w - 1, Int(c.x) + reach) {
                let dx = Double(x) - Double(c.x), dy = Double(y) - Double(c.y)
                let d = (dx * dx + dy * dy).squareRoot()
                let off = abs(d - rd)
                if off < 4 {
                    let ang = atan2(dy, dx)
                    let seg = 0.7 + 0.3 * cos(ang * 10)
                    let a = alpha * seg * (1 - off / 4.5)
                    if a < 0.3, (x + y) % 2 == 0 { continue }
                    lo.put(x, y, off < 1.2 ? cbLerp(colour, 0xFFFFFF, 0.5) : colour, a)
                } else if d < rd - 4 {
                    if (x + y) % 2 == 0 { lo.put(x, y, 0x3A1A5A, alpha * 0.22) }
                }
            }
        }
    }

    // MARK: The park gates

    /// The camera pulls back from the park's great wooden gates, torches burning on their posts; they swing shut on the
    /// old place, and open again on the new one as the camera drives on through.
    private func drawParkGates(_ lo: CBLo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        lo.image(k < 0.5 ? old : new)
        let shut = Self.ease(Self.span(k, 0.14, 0.42))
        let open = Self.ease(Self.span(k, 0.56, 0.84))
        let swing = (1 - shut) + open
        let angle = Double.pi / 2 * 0.9 * swing
        let back = Self.ease(Self.span(k, 0, 0.24))
        let on = pow(Self.span(k, 0.64, 1), 1.5)
        let z = k < 0.5 ? CGFloat(2.7 - 1.7 * back) : CGFloat(1 + 1.9 * on)
        guard let gate = CBLo(lo.w, lo.h) else { return }
        let slam = Self.bump(k, 0.41, 0.42, 0.44, 0.5)
        Self.gate(gate, angle: angle, k: k)
        guard let img = gate.ctx.makeImage() else { return }
        let fy = h * 0.4
        let shake = CGFloat(sin(k * 300) * 2 * slam).rounded()
        let rect = CGRect(x: w / 2 - w / 2 * z, y: fy - fy * z + shake, width: w * z, height: h * z)
        lo.image(img, rect)
    }

    /// The gates, full size: two posts of lashed logs with a torch on each, the beam across them with its sign, and
    /// the two doors turned `angle` away from shut (0) toward open (a right angle).
    private static func gate(_ lo: CBLo, angle: Double, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        let pw = (w * 0.11).rounded(), px = (w * 0.03).rounded()
        let postTop = (h * 0.76).rounded()
        let beamY = (h * 0.62).rounded(), beamH = (h * 0.09).rounded()
        let doorH = beamY - 1
        // The doors, behind the posts and the beam.
        let hinge = px + pw
        let dw = w / 2 - hinge
        door(lo, hinge: hinge, width: dw, height: doorH, angle: angle, mirrored: false)
        door(lo, hinge: w - hinge, width: dw, height: doorH, angle: angle, mirrored: true)
        // The posts.
        for x0 in [px, w - px - pw] {
            post(lo, x: x0, width: pw, height: postTop)
            torch(lo, x: x0 + pw / 2, y: postTop, size: pw, k: k + Double(x0) * 0.01)
        }
        // The beam across the top, and the sign.
        lo.fill(0x26180C, 1, CGRect(x: px - 3, y: beamY, width: w - px * 2 + 6, height: beamH))
        lo.fill(0x4E321A, 1, CGRect(x: px - 3, y: beamY + 1, width: w - px * 2 + 6, height: beamH - 2))
        lo.fill(0x6E4A26, 1, CGRect(x: px - 3, y: beamY + beamH - 2, width: w - px * 2 + 6, height: 1))
        for i in 0..<Int((w - px * 2) / 9) {
            lo.fill(0x3A2412, 1, CGRect(x: px + CGFloat(i * 9) + 4, y: beamY + 2, width: 1, height: beamH - 4))
        }
        let sw = (w * 0.44).rounded(), sh = (h * 0.11).rounded()
        let sx = (w / 2 - sw / 2).rounded(), sy = beamY + beamH - 3
        lo.fill(0x1A0E06, 1, CGRect(x: sx - 1, y: sy - 1, width: sw + 2, height: sh + 2))
        lo.fill(0x3A2412, 1, CGRect(x: sx, y: sy, width: sw, height: sh))
        lo.fill(0x52361C, 1, CGRect(x: sx, y: sy + sh - 2, width: sw, height: 1))
        let size = (sh * 0.72).rounded()
        let text = "JURASSIC PARK"
        let tw = lo.textWidth(text, size: size)
        let tp = CGPoint(x: (w / 2 - tw / 2).rounded(), y: (sy + sh * 0.2).rounded())
        for (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1), (1, -1)] as [(CGFloat, CGFloat)] {
            lo.text(text, size: size, at: CGPoint(x: tp.x + dx, y: tp.y + dy), colour: 0xA81E12)
        }
        lo.text(text, size: size, at: tp, colour: 0xF6C42E)
    }

    /// A post of three lashed logs, `height` tall, from the ground.
    private static func post(_ lo: CBLo, x: CGFloat, width pw: CGFloat, height: CGFloat) {
        let logs = 3, lw = pw / CGFloat(logs)
        for i in 0..<Int(pw) {
            let u = (CGFloat(i).truncatingRemainder(dividingBy: lw)) / lw
            let round = sin(Double(u) * .pi)
            let col: UInt32 = round > 0.8 ? 0x7A5228 : round > 0.5 ? 0x5E3E1E : round > 0.2 ? 0x462C14 : 0x2A1A0C
            lo.fill(col, 1, CGRect(x: x + CGFloat(i), y: 0, width: 1, height: height))
        }
        for f in [0.18, 0.5, 0.8] {   // the lashings
            let y = (height * CGFloat(f)).rounded()
            lo.fill(0x8A7048, 1, CGRect(x: x - 1, y: y, width: pw + 2, height: 3))
            lo.fill(0x5A4628, 1, CGRect(x: x - 1, y: y, width: pw + 2, height: 1))
        }
        lo.fill(0x1A0E06, 1, CGRect(x: x, y: height - 1, width: pw, height: 2))
    }

    /// A torch on a post: an iron bowl and a flickering flame, a glow round it.
    private static func torch(_ lo: CBLo, x cx: CGFloat, y: CGFloat, size s: CGFloat, k: Double) {
        let bw = (s * 0.8).rounded(), bh = (s * 0.28).rounded()
        let fh = (s * 0.7).rounded()
        let tick = Int(k * 40)
        for row in 0..<Int(fh) {
            let v = Double(row) / Double(fh)
            let jitter = (noise(row * 3 + tick * 17) - 0.5) * 3
            let half = Double(bw) * 0.45 * (1 - v * v) + 1
            let x0 = Double(cx) - half + jitter * v
            let col: UInt32 = v < 0.35 ? 0xFFE27A : v < 0.65 ? 0xFF9A2A : 0xE0501A
            lo.fill(col, 1, CGRect(x: CGFloat(x0).rounded(), y: y + bh + CGFloat(row), width: CGFloat(half * 2).rounded(), height: 1))
            if v < 0.5 {
                let core = half * 0.4
                lo.fill(0xFFF6C8, 1, CGRect(x: CGFloat(Double(cx) - core + jitter * v).rounded(), y: y + bh + CGFloat(row),
                                            width: CGFloat(core * 2).rounded(), height: 1))
            }
        }
        lo.fill(0x1A120A, 1, CGRect(x: cx - bw / 2, y: y, width: bw, height: bh))
        lo.fill(0x5A4028, 1, CGRect(x: cx - bw / 2, y: y + bh - 1, width: bw, height: 1))
    }

    /// One door of planks and beams, hung at `hinge`, `width` wide shut, swung `angle` in toward the park and drawn
    /// in perspective: narrower, its far edge shorter, darker as it turns.
    private static func door(_ lo: CBLo, hinge: CGFloat, width dw: CGFloat, height dh: CGFloat, angle: Double,
                             mirrored: Bool) {
        let cosA = cos(angle), sinA = sin(angle)
        let seen = Int((Double(dw) * cosA).rounded())
        guard seen > 0 else { return }
        let horizon = Double(lo.h) * 0.4
        let shade = 1 - 0.5 * sinA
        let plank = 7.0
        for i in 0..<seen {
            let u = (Double(i) + 0.5) / Double(seen)
            let scale = 1 - 0.24 * sinA * u
            let bottom = horizon - horizon * scale
            let top = horizon + (Double(dh) - horizon) * scale
            let x = mirrored ? Int(hinge) - 1 - i : Int(hinge) + i
            let along = u * Double(dw)
            let p = Int(along / plank)
            let notch = p % 2 == 0 ? 0.0 : 3.0
            let edge = along.truncatingRemainder(dividingBy: plank) < 1
            let y0 = Int(bottom.rounded()), y1 = Int((top - notch * scale).rounded())
            guard y0 < y1 else { continue }
            for y in y0..<y1 {
                let v = (Double(y) - bottom) / (top - bottom)
                var col: UInt32 = p % 3 == 0 ? 0x6E4826 : p % 3 == 1 ? 0x5E3C1E : 0x664222
                if edge { col = 0x2E1C0C }
                let brace = abs(v - (0.24 + 0.46 * u)) < 0.035
                let beam = (v > 0.16 && v < 0.24) || (v > 0.7 && v < 0.78)
                if beam || brace { col = (v > 0.2 && v < 0.22) || (v > 0.74 && v < 0.76) ? 0x7E5630 : 0x4A2E16 }
                if beam, u < 0.12 { col = 0x2A2A2E }
                if beam, u < 0.12, (y + i) % 4 == 0 { col = 0x8A8A90 }
                lo.put(x, y, cbScale(col, shade), 1)
            }
            if !mirrored, i == seen - 1, angle < 0.05 { lo.fill(0x140C06, 1, CGRect(x: x, y: y0, width: 1, height: y1 - y0)) }
        }
    }

    // MARK: The five tones

    /// The light board's five panels, each the colour of one of the mothership's lamps, play the five tones in their
    /// order (re, mi, do, the low do, sol; the panels in order of pitch): each one blazes up and leaves its strip of the
    /// new place behind, until it's all there.
    private func drawFiveTones(_ lo: CBLo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        lo.image(old)
        let board = Self.span(k, 0, 0.1) * (1 - Self.span(k, 0.86, 1))
        lo.dim(0.55 * Self.span(k, 0, 0.1))
        let colours: [UInt32] = [0xE8406A, 0xF0982E, 0xF2DE48, 0x4AD89A, 0x6A7CF8]
        let order = [2, 3, 1, 0, 4]
        let sw = w / 5
        let cell = max(3, (h / 40).rounded())
        for pos in 0..<5 {
            let seq = Double(order.firstIndex(of: pos) ?? pos)
            let t0 = 0.12 + seq * 0.15
            let strip = CGRect(x: (CGFloat(pos) * sw).rounded(), y: 0, width: sw.rounded() + 1, height: h)
            if k >= t0 + 0.03 {
                lo.ctx.saveGState(); lo.ctx.clip(to: strip); lo.image(new); lo.ctx.restoreGState()
            }
            let glow = Self.span(k, t0, t0 + 0.03) * (1 - Self.span(k, t0 + 0.05, t0 + 0.19))
            let idle = k < t0 ? 0.13 * board : 0
            if glow > 0.01 { lo.fill(colours[pos], CGFloat(glow * 0.12)) }
            let a = max(glow, idle)
            guard a > 0.01 else { continue }
            Self.panel(lo, strip, cell: cell, colour: colours[pos], alpha: a, lit: glow > 0.01)
        }
        if board > 0.01 {
            for pos in 1..<5 {
                lo.fill(0x05060A, CGFloat(0.85 * board), CGRect(x: (CGFloat(pos) * sw).rounded(), y: 0, width: 1, height: h))
            }
        }
    }

    /// One panel of the light board: a grid of square lamps in its colour, the brightest whitening in the middle.
    private static func panel(_ lo: CBLo, _ r: CGRect, cell: CGFloat, colour: UInt32, alpha: Double, lit: Bool) {
        let cols = Int(r.width / cell), rows = Int(r.height / cell)
        let ox = r.minX + (r.width - CGFloat(cols) * cell) / 2
        let hot = cbLerp(colour, 0xFFFFFF, 0.55)
        for j in 0..<rows {
            for i in 0..<cols {
                let x = (ox + CGFloat(i) * cell).rounded(), y = CGFloat(j) * cell
                lo.fill(colour, CGFloat(alpha), CGRect(x: x, y: y, width: cell - 1, height: cell - 1))
                if lit { lo.fill(hot, CGFloat(alpha * 0.8), CGRect(x: x + 1, y: y + 1, width: cell - 3, height: cell - 3)) }
            }
        }
    }

    // MARK: The boulder

    /// The giant stone ball comes rolling across in a cloud of dust, Indy legging it in front, the ground shaking; the
    /// new place is in its wake.
    private func drawBoulder(_ lo: CBLo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        let r = (h * 0.46).rounded()
        let roll = Self.span(k, 0.04, 0.9)
        let startX = -r * 1.4, run = w + r * 2.8
        let bx = (startX + run * CGFloat(roll)).rounded()
        let by = r + (h * 0.02).rounded()
        let quake = Self.bump(k, 0.02, 0.1, 0.85, 0.95)
        let sx = CGFloat(sin(k * 97) * 2 * quake).rounded(), sy = CGFloat(cos(k * 131) * 1.5 * quake).rounded()
        let full = CGRect(x: sx, y: sy, width: w, height: h)
        lo.fill(0x1A140E)
        lo.image(old, full)
        lo.ctx.saveGState(); lo.ctx.clip(to: CGRect(x: 0, y: 0, width: max(0, bx), height: h)); lo.image(new, full)
        lo.ctx.restoreGState()
        // Indy, running for it.
        if roll > 0, roll < 1, let indy = Self.sprite(.hero(.indianaBones), t: k * 3) {
            let ix = (bx + r * 0.95 + CGFloat(sin(k * 30)) * 2).rounded()
            lo.image(indy, CGRect(x: ix, y: (h * 0.02).rounded() + sy, width: CGFloat(Sprite.width), height: CGFloat(Sprite.height)))
        }
        // The dust it raises, billowing up behind it: one cloud, shaded, laid over at once.
        guard let dust = CBLo(lo.w, lo.h) else { return }
        for i in 0..<30 {
            let born = Double(i) / 30
            guard born < roll else { break }
            let age = roll - born
            let fade = 0.6 * (1 - age * 2.4)
            guard fade > 0.02 else { continue }
            let px = startX + run * CGFloat(born) - r * 0.3 - CGFloat(age) * r * 0.9
            let py = h * 0.04 + r * 0.25 + CGFloat(age) * r * 0.9 + CGFloat(noise(i * 3 + 9)) * r * 0.4
            let pr = r * 0.22 + CGFloat(age) * r * 1.3
            let col = cbLerp(0xC8B088, 0x9A845E, noise(i * 3 + 10))
            let a = CGFloat(min(1, fade * 1.8))
            dust.ctx.setFillColor(cbRGB(col, a))
            dust.ctx.fillEllipse(in: CGRect(x: px - pr, y: py - pr, width: pr * 2, height: pr * 2))
            dust.ctx.setFillColor(cbRGB(0xE2D0A8, a))
            dust.ctx.fillEllipse(in: CGRect(x: px - pr * 0.7, y: py - pr * 0.4, width: pr * 1.3, height: pr * 1.3))
        }
        if let cloud = dust.ctx.makeImage() { lo.image(cloud, alpha: 0.85) }
        guard bx > -r - 2, bx < w + r + 2 else { return }
        lo.ctx.setFillColor(cbRGB(0x0A0806, 0.45))
        lo.ctx.fillEllipse(in: CGRect(x: bx - r * 0.9, y: sy - 3, width: r * 1.8, height: 8))
        Self.stone(lo, at: CGPoint(x: bx, y: by + sy), radius: r, turn: -Double(bx) / Double(r))
    }

    /// The boulder: a ball of rough stone, lit from up on the left, its pits and cracks turned `turn` as it rolls.
    private static func stone(_ lo: CBLo, at c: CGPoint, radius r: CGFloat, turn: Double) {
        let palette: [UInt32] = [0x2A221A, 0x463A2C, 0x685844, 0x8E7C62, 0xB4A284]
        let rd = Double(r), ct = cos(turn), st = sin(turn)
        let x0 = max(0, Int(c.x - r)), x1 = min(lo.w - 1, Int(c.x + r))
        let y0 = max(0, Int(c.y - r)), y1 = min(lo.h - 1, Int(c.y + r))
        guard x0 <= x1, y0 <= y1 else { return }
        for y in y0...y1 {
            for x in x0...x1 {
                let dx = (Double(x) + 0.5 - Double(c.x)) / rd, dy = (Double(y) + 0.5 - Double(c.y)) / rd
                let d2 = dx * dx + dy * dy
                guard d2 <= 1 else { continue }
                let nz = (1 - d2).squareRoot()
                let light = max(0, -dx * 0.5 + dy * 0.55 + nz * 0.67)
                let rx = dx * ct - dy * st, ry = dx * st + dy * ct
                let grain = cbNoise(rx * 4 + 10, ry * 4 + 10) * 0.6 + cbNoise(rx * 10 + 3, ry * 10) * 0.4
                let crack = abs(cbNoise(rx * 2.6 + 5, ry * 2.6 + 1) - 0.5) < 0.025
                var level = light * 0.85 + (grain - 0.5) * 0.5
                if d2 > 0.9 { level -= 0.2 }
                var i = Int(max(0, min(4.99, level * 5)))
                if crack { i = max(0, i - 2) }
                lo.put(x, y, palette[i], 1)
            }
        }
    }

    // MARK: Fairy dust

    /// Tinkerbelle zips across in loops, a trail of gold dust sparkling behind her, and wherever it falls the new
    /// place shows through, spreading, until it's all there.
    private func drawPixieDust(_ lo: CBLo, old: CGImage, new: CGImage, k: Double) {
        let w = Double(lo.w), h = Double(lo.h)
        func at(_ s: Double) -> CGPoint {
            let loop = s * 2 * .pi * 3.5
            let base = w * (-0.1 + 1.2 * s)
            let cy = h * (0.5 + 0.16 * sin(s * 2 * .pi * 1.3 + 0.5))
            let rl = h * 0.22
            return CGPoint(x: base + rl * sin(loop) * 0.9, y: cy + rl * cos(loop))
        }
        let head = Self.ease(Self.span(k, 0.03, 0.82))
        let fill = Self.ease(Self.span(k, 0.76, 0.97))
        lo.image(old)
        guard let shown = CBLo(lo.w, lo.h) else { return }
        let samples = 150
        for j in 0...samples {
            let s = Double(j) / Double(samples)
            guard s <= head else { break }
            let age = head - s
            let rad = CGFloat(1.5 + age * h * 0.9 + fill * h * 0.9)
            let p = at(s)
            shown.ctx.setFillColor(cbRGB(0xFFFFFF))
            shown.ctx.fillEllipse(in: CGRect(x: p.x - rad, y: p.y - rad, width: rad * 2, height: rad * 2))
        }
        shown.ctx.setBlendMode(.sourceIn)
        shown.image(new)
        if let img = shown.ctx.makeImage() { lo.image(img) }
        // The dust: gold sparkles along the newest part of the trail, drifting down and twinkling out.
        let tick = Int(k * 40)
        let gold: [UInt32] = [0xFFE070, 0xFFF6C8, 0xF0A830, 0xFFD040]
        for j in 0...samples {
            let s = Double(j) / Double(samples)
            guard s <= head else { break }
            let age = (head - s) * 3
            guard age < 1 else { continue }
            let p = at(s)
            for m in 0..<5 {
                let n = j * 5 + m
                guard cbHash(n, tick, 9) % 3 != 0 else { continue }
                let x = Int(Double(p.x) + (noise(n * 2 + 5) - 0.5) * 22)
                let y = Int(Double(p.y) + (noise(n * 2 + 6) - 0.5) * 16 - age * h * 0.12)
                let a = (1 - age) * (1 - fill)
                let col = gold[n % 4]
                lo.put(x, y, col, a)
                if n % 5 == 0 {
                    lo.put(x - 1, y, col, a * 0.6); lo.put(x + 1, y, col, a * 0.6)
                    lo.put(x, y - 1, col, a * 0.6); lo.put(x, y + 1, col, a * 0.6)
                }
            }
        }
        // Tinkerbelle herself: a point of light with a glow, her wings flickering.
        guard head < 1 else { return }
        let t = at(head)
        for (r, col, a) in [(8.0, UInt32(0xFFE89A), 0.18), (4.5, UInt32(0xFFE89A), 0.4), (2.0, UInt32(0xFFFFFF), 1.0)] {
            lo.ctx.setFillColor(cbRGB(col, CGFloat(a)))
            lo.ctx.fillEllipse(in: CGRect(x: t.x - CGFloat(r), y: t.y - CGFloat(r), width: CGFloat(r * 2), height: CGFloat(r * 2)))
        }
        if tick % 2 == 0 {
            lo.put(Int(t.x) - 3, Int(t.y) + 3, 0xCFF4FF, 0.9); lo.put(Int(t.x) + 3, Int(t.y) + 3, 0xCFF4FF, 0.9)
            lo.put(Int(t.x) - 2, Int(t.y) + 2, 0xCFF4FF, 0.7); lo.put(Int(t.x) + 2, Int(t.y) + 2, 0xCFF4FF, 0.7)
        }
    }

    // MARK: The doubloon

    /// One-Eyed Willy's doubloon, the skull stamped on it, spins up out of the dark at the middle and grows as it
    /// flips: the old place on one face, the new on the other. It lands new face up, fills the screen, and its gold
    /// dissolves off the new place.
    private func drawDoubloon(_ lo: CBLo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        let c = CGPoint(x: (w / 2).rounded(), y: (h / 2).rounded())
        lo.image(old)
        lo.dim(0.7 * Self.span(k, 0, 0.14))
        let r0 = h * 0.13, rEnd = Self.farthest(lo, from: c) * 1.04
        let grow = Self.ease(Self.span(k, 0.06, 0.84))
        let r = (r0 * CGFloat(pow(Double(rEnd / r0), grow))).rounded()
        let flip = Self.span(k, 0.04, 0.8)
        let a = 5 * Double.pi * (1 - (1 - flip) * (1 - flip))
        let cosA = cos(a)
        let sx = CGFloat(max(0.04, abs(cosA)))
        let melt = Self.span(k, 0.85, 1)
        // The milled edge, showing as it turns.
        let thick = r * 0.09 * CGFloat(abs(sin(a)))
        if thick >= 1 {
            let ex = r * sx + thick
            lo.ctx.setFillColor(cbRGB(0x7A5410))
            lo.ctx.fillEllipse(in: CGRect(x: c.x - ex, y: c.y - r, width: ex * 2, height: r * 2))
            lo.ctx.setFillColor(cbRGB(0xB8861E))
            lo.ctx.fillEllipse(in: CGRect(x: c.x - ex + 1, y: c.y - r + 1, width: ex * 2 - 2, height: r * 2 - 2))
        }
        guard let face = Self.coin(cosA >= 0 ? old : new, w: lo.w, h: lo.h, centre: c, radius: r) else { return }
        let rect = CGRect(x: c.x - c.x * sx, y: 0, width: w * sx, height: h)
        lo.image(face, rect)
        // A glint off the gold while it's face on.
        let glint = Self.bump(k, 0.02, 0.08, 0.14, 0.22)
        if glint > 0 {
            let gp = CGPoint(x: c.x - r * 0.6 * sx, y: c.y + r * 0.6)
            Self.starburst(lo, at: gp, size: r * 0.7, alpha: glint)
        }
        if melt > 0, let next = CBLo(lo.w, lo.h) {
            next.image(new)
            lo.scatter(from: next, amount: melt, block: 2, seed: 23)
        }
    }

    /// A face of the coin, `radius` across at `centre` on a frame the size of the screen: the place on it washed in
    /// gold (small, it's shrunk to fit; big, it's the place as it is on screen), a milled rim, a ring of dots and the
    /// skull struck in the middle.
    private static func coin(_ img: CGImage, w: Int, h: Int, centre c: CGPoint, radius r: CGFloat) -> CGImage? {
        guard let f = CBLo(w, h) else { return nil }
        let disc = CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)
        let ctx = f.ctx
        ctx.saveGState()
        ctx.addEllipse(in: disc); ctx.clip()
        f.fill(0x3A2808)
        let ph = min(CGFloat(h), r * 2.2), pw = ph * CGFloat(w) / CGFloat(h)
        f.image(img, CGRect(x: c.x - pw / 2, y: c.y - ph / 2, width: pw, height: ph))
        ctx.setBlendMode(.multiply); f.fill(0xF6C850, 0.75); ctx.setBlendMode(.normal)
        f.fill(0xE0A830, 0.2)
        // The rim: a band of gold, notched, between dark lines.
        let ring = CGMutablePath()
        ring.addEllipse(in: disc)
        ring.addEllipse(in: disc.insetBy(dx: r * 0.13, dy: r * 0.13))
        ctx.addPath(ring); ctx.setFillColor(cbRGB(0xE2B23C)); ctx.fillPath(using: .evenOdd)
        let notches = 40
        for i in 0..<notches {
            let ang = Double(i) / Double(notches) * 2 * .pi
            let px = c.x + CGFloat(cos(ang)) * r * 0.935, py = c.y + CGFloat(sin(ang)) * r * 0.935
            let s = max(1, (r * 0.04).rounded())
            f.fill(0x9A6E16, 1, CGRect(x: (px - s / 2).rounded(), y: (py - s / 2).rounded(), width: s, height: s))
        }
        ctx.setStrokeColor(cbRGB(0x5A3C08)); ctx.setLineWidth(max(1, (r * 0.02).rounded()))
        ctx.strokeEllipse(in: disc.insetBy(dx: 0.5, dy: 0.5))
        ctx.strokeEllipse(in: disc.insetBy(dx: r * 0.13, dy: r * 0.13))
        ctx.setStrokeColor(cbRGB(0xFFE68A)); ctx.setLineWidth(1)
        ctx.strokeEllipse(in: disc.insetBy(dx: r * 0.13 + 1, dy: r * 0.13 + 1))
        for i in 0..<28 {   // the ring of dots
            let ang = Double(i) / 28 * 2 * .pi
            let px = c.x + CGFloat(cos(ang)) * r * 0.78, py = c.y + CGFloat(sin(ang)) * r * 0.78
            let s = max(1, (r * 0.035).rounded())
            f.fill(0xFFE68A, 1, CGRect(x: px.rounded(), y: py.rounded(), width: s, height: s))
        }
        skull(f, at: c, cell: max(1, (r * 0.042).rounded(.down)))
        ctx.restoreGState()
        return ctx.makeImage()
    }

    /// The skull and crossbones, struck in gold: raised, so lit on its top left and shadowed under its bottom right.
    private static func skull(_ lo: CBLo, at c: CGPoint, cell s: CGFloat) {
        let rows = [
            "XX.....XXXXX.....XX",
            "XXX..XXXXXXXXX..XXX",
            ".XXXXXXXXXXXXXXXXX.",
            "...XXXXXXXXXXXXX...",
            "...XXX...X...XXX...",
            "...XXX...X...XXX...",
            "...XXXX.XXX.XXXX...",
            "....XXXXX.XXXXX....",
            ".....XXXXXXXXX.....",
            ".XXXXX.X.X.X.XXXXX.",
            "XXX..XXXXXXXXX..XXX",
            "XX...............XX",
        ]
        let gw = CGFloat(rows[0].count), gh = CGFloat(rows.count)
        let ox = (c.x - gw * s / 2).rounded(), oy = (c.y + gh * s / 2).rounded()
        let shift = max(1, (s / 2).rounded())
        for (pass, col) in [(0, UInt32(0x5A3C08)), (1, UInt32(0xFFEFA8)), (2, UInt32(0xD8A434))] {
            let d: CGFloat = pass == 0 ? shift : pass == 1 ? -shift : 0
            for (j, row) in rows.enumerated() {
                for (i, ch) in row.enumerated() where ch == "X" {
                    let x = ox + CGFloat(i) * s + d, y = oy - CGFloat(j + 1) * s - d
                    lo.fill(col, 1, CGRect(x: x, y: y, width: s, height: s))
                }
            }
        }
    }
}

// MARK: - The frame

/// A frame at one cell per art pixel: drawn into with Core Graphics (no smoothing), its pixels read and written too.
private final class CBLo {
    let w: Int, h: Int, ctx: CGContext
    var rect: CGRect { CGRect(x: 0, y: 0, width: w, height: h) }

    init?(_ w: Int, _ h: Int) {
        guard let c = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                                space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              c.data != nil
        else { return nil }
        self.w = w; self.h = h; ctx = c
        c.interpolationQuality = .none
        c.setShouldAntialias(false)
    }

    /// RGBA, premultiplied, the top row first.
    fileprivate var bytes: UnsafeMutablePointer<UInt8> { ctx.data!.assumingMemoryBound(to: UInt8.self) }

    func fill(_ hex: UInt32, _ a: CGFloat = 1, _ r: CGRect? = nil) {
        ctx.setFillColor(cbRGB(hex, a)); ctx.fill(r ?? rect)
    }

    func image(_ img: CGImage, _ r: CGRect? = nil, alpha: CGFloat = 1) {
        guard alpha > 0.005 else { return }
        ctx.saveGState(); ctx.setAlpha(alpha); ctx.draw(img, in: r ?? rect); ctx.restoreGState()
    }

    /// One pixel, `x` and `y` from the bottom left as Core Graphics has them, laid over at `a`.
    func put(_ x: Int, _ y: Int, _ hex: UInt32, _ a: Double = 1) {
        guard x >= 0, y >= 0, x < w, y < h, a > 0.003 else { return }
        let i = ((h - 1 - y) * w + x) * 4
        let p = bytes, al = min(1, a), inv = 1 - al
        let r = Double(hex >> 16 & 0xFF), g = Double(hex >> 8 & 0xFF), b = Double(hex & 0xFF)
        p[i] = UInt8(min(255, r * al + Double(p[i]) * inv))
        p[i + 1] = UInt8(min(255, g * al + Double(p[i + 1]) * inv))
        p[i + 2] = UInt8(min(255, b * al + Double(p[i + 2]) * inv))
        p[i + 3] = UInt8(min(255, 255 * al + Double(p[i + 3]) * inv))
    }

    /// Every pixel through `f` (red, green, blue, premultiplied, 0…255).
    private func each(_ f: (inout Double, inout Double, inout Double) -> Void) {
        let p = bytes
        for i in stride(from: 0, to: w * h * 4, by: 4) {
            var r = Double(p[i]), g = Double(p[i + 1]), b = Double(p[i + 2])
            f(&r, &g, &b)
            let a = Double(p[i + 3])
            p[i] = UInt8(max(0, min(a, r))); p[i + 1] = UInt8(max(0, min(a, g))); p[i + 2] = UInt8(max(0, min(a, b)))
        }
    }

    /// Moonlight: the colour drained to a deep blue night, `amount` of the way.
    func night(_ amount: Double) {
        guard amount > 0.01 else { return }
        each { r, g, b in
            let l = 0.3 * r + 0.59 * g + 0.11 * b
            r += (l * 0.2 - r) * amount; g += (l * 0.3 + 4 - g) * amount; b += (l * 0.58 + 18 - b) * amount
        }
    }

    /// Darker, `amount` of the way to black, a little warm.
    func dim(_ amount: Double) {
        guard amount > 0.01 else { return }
        each { r, g, b in
            r *= 1 - amount * 0.9; g *= 1 - amount * 0.93; b *= 1 - amount * 0.96
        }
    }

    /// `other`'s pixels over these, a scatter of `block`-sized squares at a time, `amount` 0 none … 1 all of them.
    func scatter(from other: CBLo, amount: Double, block: Int, seed: Int) {
        guard other.w == w, other.h == h else { return }
        let p = bytes, s = other.bytes
        let limit = Int(amount * 1000)
        for y in 0..<h {
            for x in 0..<w where cbHash(x / block, y / block, seed) % 1000 < limit {
                let i = (y * w + x) * 4
                p[i] = s[i]; p[i + 1] = s[i + 1]; p[i + 2] = s[i + 2]; p[i + 3] = s[i + 3]
            }
        }
    }

    private func line(_ s: String, size: CGFloat, colour: UInt32) -> CTLine {
        let font = CTFontCreateWithName("Impact" as CFString, size, nil)
        let attrs: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(kCTFontAttributeName as String): font,
            NSAttributedString.Key(kCTForegroundColorAttributeName as String): cbRGB(colour),
        ]
        return CTLineCreateWithAttributedString(NSAttributedString(string: s, attributes: attrs))
    }

    func textWidth(_ s: String, size: CGFloat) -> CGFloat {
        CGFloat(CTLineGetTypographicBounds(line(s, size: size, colour: 0), nil, nil, nil))
    }

    /// Poster lettering, its baseline at `p`, unsmoothed so it stays in pixels.
    func text(_ s: String, size: CGFloat, at p: CGPoint, colour: UInt32) {
        ctx.saveGState()
        ctx.setShouldSmoothFonts(false); ctx.setAllowsFontSmoothing(false)
        ctx.textMatrix = .identity
        ctx.textPosition = p
        CTLineDraw(line(s, size: size, colour: colour), ctx)
        ctx.restoreGState()
    }
}

/// Smooth noise in 0…1 over the plane.
fileprivate func cbNoise(_ x: Double, _ y: Double) -> Double {
    let xi = Int(floor(x)), yi = Int(floor(y))
    let fx = x - floor(x), fy = y - floor(y)
    let ux = fx * fx * (3 - 2 * fx), uy = fy * fy * (3 - 2 * fy)
    func corner(_ i: Int, _ j: Int) -> Double { Double(cbHash(i, j, 77) % 1000) / 999 }
    let top = corner(xi, yi) + (corner(xi + 1, yi) - corner(xi, yi)) * ux
    let bottom = corner(xi, yi + 1) + (corner(xi + 1, yi + 1) - corner(xi, yi + 1)) * ux
    return top + (bottom - top) * uy
}

/// A quick integer hash, never negative.
fileprivate func cbHash(_ x: Int, _ y: Int, _ s: Int) -> Int {
    var v = UInt32(truncatingIfNeeded: x &* 374_761_393 &+ y &* 668_265_263 &+ s &* 1_274_126_177)
    v = (v ^ (v >> 13)) &* 1_274_126_177
    return Int(v ^ (v >> 16))
}

/// Between two colours, 0xRRGGBB.
fileprivate func cbLerp(_ a: UInt32, _ b: UInt32, _ t: Double) -> UInt32 {
    let t = min(1, max(0, t))
    func ch(_ s: UInt32) -> UInt32 {
        let x = Double(a >> s & 0xFF), y = Double(b >> s & 0xFF)
        return UInt32(x + (y - x) * t) << s
    }
    return ch(16) | ch(8) | ch(0)
}

/// A colour, 0xRRGGBB, darkened (or lightened) by `m`.
fileprivate func cbScale(_ c: UInt32, _ m: Double) -> UInt32 {
    func ch(_ s: UInt32) -> UInt32 { UInt32(min(255, Double(c >> s & 0xFF) * m)) << s }
    return ch(16) | ch(8) | ch(0)
}

/// A colour from 0xRRGGBB.
fileprivate func cbRGB(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}

extension ClawdbergTrip: Trip {}
