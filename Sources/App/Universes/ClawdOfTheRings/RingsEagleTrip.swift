import CoreGraphics
import Foundation

// The trip between Clawd of the Rings places on a Great Eagle's back (`RingsWipe.eagles`): the Eagle sweeps the old
// place away, carries the view off through the sky, and banks away over the new one.

extension RingsTrip {
    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. A Great Eagle swoops in from the left,
    /// huge and close, a great downstroke of its wings driving a wall of cloud across the old place and sweeping it
    /// away (0–0.3); the view flies along with it through open sky, clouds and speed lines streaming past as it beats
    /// on, a cloud or two rushing by in front (0.3–0.68); then the view tips down, the Eagle banks away and dwindles
    /// into the distance below, and the new place rises from under the cloud floor to fill the frame (0.68–0.97). The
    /// places are drawn as they are; the sky, the clouds and the Eagle are pixel art: drawn into a bitmap a few screen
    /// pixels to each of its own (about 180 of them from top to bottom), in stepped bands of colour, then scaled up
    /// without smoothing. The Eagle is worked out pixel by pixel on that grid, so it stays crisp at any size and as it
    /// banks.
    func drawEagles(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let px: CGFloat = max(1, (r.height / 180).rounded())  // screen pixels per pixel of the trip's art
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = Self.eagleCanvas(width: w, height: h) else { ctx.draw(k < 0.5 ? old : new, in: r); return }
        let W = Double(w), H = Double(h)
        let unit = min(H, W * 0.56) / 64                       // art pixels to a unit of the Eagle's drawing, close up
        let bird = Self.eagleFlight(k, W: W, H: H, unit: unit)
        let down = Self.eagleEase(Self.eagleSpan(k, 0.68, 0.96))  // the view tipping down onto the new place
        let floor = down * H                                    // the cloud floor (the new place's top), from the bottom

        // The edge of the sky, sweeping across the old place just ahead of the Eagle and on past the frame.
        let sweep = Self.eagleEase(Self.eagleSpan(k, 0.06, 0.3))
        let lead = bird.x + 20 * unit * bird.size
        let front = lead + (W + 0.6 * H + 12 - lead) * sweep

        // The places: the old one until the sky has covered it, the new one rising from below once the view tips.
        ctx.saveGState()
        ctx.clip(to: r)
        if front < W + 0.6 * H { ctx.draw(old, in: r) }
        if down > 0 {
            let below = r.offsetBy(dx: 0, dy: -CGFloat(1 - down) * r.height)
            ctx.setFillColor(eagleRGB(0x000000)); ctx.fill(below); ctx.draw(new, in: below)
        }
        ctx.restoreGState()

        // The sky behind the sweep and above the cloud floor, its clouds and speed lines streaming past.
        let reach = max(0, min(front, W + 1))                   // how far across the sky has swept
        let sky = CGRect(x: 0, y: floor, width: reach, height: max(0, H + 1 - floor))
        if reach > 0 && floor < H + 1 {
            art.saveGState()
            art.clip(to: sky)
            Self.eagleSky(art, k: k, floor: floor, W: W, H: H)
            art.restoreGState()
        }
        Self.eagleCloudFloor(art, k: k, floor: floor, alpha: 1 - Self.eagleSpan(k, 0.78, 0.94), reach: reach, W: W, H: H)
        if front < W + 0.6 * H { Self.eagleCloudWall(art, x: front, k: k, H: H) }

        // The Eagle, then what rushes past in front of it.
        if bird.size * unit > 0.06 {
            Self.eagleBird(art, x: bird.x, y: bird.y, scale: bird.size * unit, bank: bird.bank, beat: bird.beat,
                           width: w, height: h)
        }
        Self.eagleForeground(art, k: k, floor: floor, alpha: 1 - Self.eagleSpan(k, 0.8, 0.92), W: W, H: H)
        Self.eagleBlit(art, onto: ctx, width: w, height: h, px: px, in: r)
    }

    /// The crew goes with the old place: it fades as the wall of cloud sweeps across (0.1–0.24), stays away while
    /// the view is up in the open sky, and comes back once the new place has risen to fill the frame (0.86–0.97).
    static func eagleCrewShown(_ k: Double) -> Double {
        eagleEase(1 - eagleSpan(k, 0.1, 0.24)) + eagleEase(eagleSpan(k, 0.86, 0.97))
    }

    // MARK: The Eagle's flight

    /// Where the Eagle is at `k`, in the art's pixels from the top left (`x`, `y`), how big (`size`, 1 close up),
    /// how far it has banked (`bank`, radians, nose down) and where its wings are in their beat (`beat`, 0 up, 1 down).
    /// It swoops in from the left, big and getting nearer as it slows (0–0.3), keeps pace with the view, bobbing as it
    /// beats (0.3–0.68), then banks and dives away down to the right, dwindling to nothing (0.68–0.97).
    private static func eagleFlight(_ k: Double, W: Double, H: Double, unit: Double)
        -> (x: Double, y: Double, size: Double, bank: Double, beat: Double) {
        let swoop = 1 - pow(1 - eagleSpan(k, 0, 0.3), 2)        // fast in, slowing as the view catches it up
        let away = eagleEase(eagleSpan(k, 0.68, 0.97))
        // Three beats over the trip, a downstroke as it sweeps the old place away; held up in a glide as it banks.
        // Each stroke is quick and the wings rest spread at either end of it, where they read best.
        let phase: Double = 2.94 * k + 0.765
        let p = phase - phase.rounded(.down)
        var beat: Double = p < 0.5 ? eagleEase(eagleSpan(p, 0.15, 0.31)) : 1 - eagleEase(eagleSpan(p, 0.65, 0.81))
        beat += (0.15 - beat) * eagleEase(eagleSpan(k, 0.66, 0.78))
        let size: Double = (1.6 - 0.45 * swoop) * pow(1 - away, 1.5)
        let start = -40 * unit * 1.6                           // off the left edge, wings and all
        var x = start + (0.42 * W - start) * swoop
        var y = H * (0.3 + 0.2 * swoop)
        let cruise = eagleSpan(k, 0.3, 0.68)
        x += 0.03 * W * sin(cruise * .pi)                       // a little surge forward
        y -= 0.04 * H * (beat - 0.5) * (1 - away)              // rising on each downstroke
        x += 0.42 * W * away
        y += 0.2 * H * away
        let bank: Double = 0.5 * eagleEase(eagleSpan(k, 0.66, 0.8)) + 0.15 * away
        return (x, y, size, bank, beat)
    }

    /// The Great Eagle, facing right, its centre at (`x`, `y`) in the art's pixels from the top left, `scale` art
    /// pixels to a unit of its drawing (the ride's Eagle, about 60 units nose to tail), turned `bank` radians nose down,
    /// its wings `beat` (0 raised, 1 swept down) through their stroke. Worked out pixel by pixel: each pixel of the art
    /// it might cover is turned back into the Eagle's own units and asks `eagleColour` what's there; then it's
    /// outlined in dark brown, a pixel wide.
    private static func eagleBird(_ art: CGContext, x cx: Double, y cy: Double, scale: Double, bank: Double, beat: Double,
                                  width w: Int, height h: Int) {
        guard let data = art.data else { return }
        let stride = art.bytesPerRow / 4
        let pixels = data.bindMemory(to: UInt32.self, capacity: stride * h)
        let c = cos(bank), s = sin(bank)
        let pose = eaglePose(beat)

        // The art's pixels it might cover (a pixel more each way, for the outline).
        var x0 = Int.max, x1 = Int.min, y0 = Int.max, y1 = Int.min
        for (lx, ly) in [(-36.0, -37.0), (34.0, -37.0), (-36.0, 27.0), (34.0, 27.0)] {
            let ax = cx + (c * lx - s * ly) * scale, ay = cy + (s * lx + c * ly) * scale
            x0 = min(x0, Int(ax.rounded(.down)) - 1); x1 = max(x1, Int(ax.rounded(.up)) + 1)
            y0 = min(y0, Int(ay.rounded(.down)) - 1); y1 = max(y1, Int(ay.rounded(.up)) + 1)
        }
        x0 = max(x0, 0); y0 = max(y0, 0); x1 = min(x1, w - 1); y1 = min(y1, h - 1)
        guard x1 >= x0, y1 >= y0 else { return }
        let bw = x1 - x0 + 1, bh = y1 - y0 + 1
        var buf = [UInt32](repeating: 0, count: bw * bh)
        for j in 0..<bh {
            let dy: Double = Double(y0 + j) + 0.5 - cy
            for i in 0..<bw {
                let dx: Double = Double(x0 + i) + 0.5 - cx
                buf[j * bw + i] = eagleColour((c * dx + s * dy) / scale, (-s * dx + c * dy) / scale, pose)
            }
        }
        for j in 0..<bh {
            for i in 0..<bw {
                let v = buf[j * bw + i]
                var out = v
                if v == 0 {
                    let edge = (i > 0 && buf[j * bw + i - 1] != 0) || (i + 1 < bw && buf[j * bw + i + 1] != 0)
                        || (j > 0 && buf[(j - 1) * bw + i] != 0) || (j + 1 < bh && buf[(j + 1) * bw + i] != 0)
                    guard edge else { continue }
                    out = eagleInk
                }
                pixels[(y0 + j) * stride + x0 + i] = out
            }
        }
    }

    /// The Eagle's wings at `beat` of their stroke: raised up and back (0), swept down and back (1), and, between,
    /// spread wide and driving down towards you, so they foreshorten (shorter, pointing down) but stay broad, the
    /// primaries fanned out. They never turn edge-on: they pass through pointing back only where they're shortest.
    private static func eaglePose(_ beat: Double) -> (near: EagleWing, far: EagleWing) {
        let spread = sin(.pi * beat)                            // 1 mid-stroke, 0 at either end
        func wing(x: Double, y: Double, from a0: Double, to a1: Double, length: Double, width: Double,
                  colours: [UInt32]) -> EagleWing {
            let (angle, reach) = eagleStroke(beat, from: a0, to: a1)
            return EagleWing(x: x, y: y, angle: angle, length: length * reach, width: width * (1 + 0.15 * spread),
                             side: sin(angle) < 0 ? -1 : 1, spread: spread, colours: colours)
        }
        let near = wing(x: 8, y: -2 + 2 * beat, from: 4.08, to: 2.55, length: 33, width: 10,
                        colours: [0xB89050, 0x8A6440, 0x6A4A2A, 0x543A20, 0x3E2A16, 0x2E1E10])
        let far = wing(x: 11, y: -2 + 3 * beat, from: 4.33, to: 2.30, length: 26, width: 7.5,
                       colours: [0x7A5634, 0x6A4A2A, 0x543A20, 0x3E2A16, 0x2E1E10, 0x261808])
        return (near, far)
    }

    /// Where a wing points at `beat` of its downstroke (radians, y down) and how long it looks (1 at either end), from
    /// `a0` raised to `a1` lowered. Worked out as a wing swinging down through a half turn about the body, swept back
    /// at the top and bottom of the stroke and straight out mid-stroke, seen from a little below: its tip comes
    /// towards you and down, so it shortens, rather than swinging back along the body.
    private static func eagleStroke(_ beat: Double, from a0: Double, to a1: Double) -> (angle: Double, reach: Double) {
        let below = 0.5                                         // how far below the Eagle the view is, radians
        func tip(_ t: Double) -> (x: Double, y: Double) {
            (-(0.5 * abs(cos(t)) + 0.14), -cos(t) * cos(below) + sin(t) * sin(below))
        }
        func heading(_ p: (x: Double, y: Double)) -> Double {
            let a = atan2(p.y, p.x)
            return a < 0 ? a + 2 * .pi : a
        }
        let t = tip(.pi * beat), up = tip(0), down = tip(.pi)
        let raw = heading(t)
        let angle = raw + (a0 - heading(up)) * (1 - beat) + (a1 - heading(down)) * beat
        let reach = hypot(t.x, t.y) / hypot(up.x, up.y)
        return (angle, 0.3 + 0.7 * reach)
    }

    private static let eagleInk = eaglePack(0x24180C)
    private static let eagleBody = eaglePack(0x6A4A2A), eagleBodyLight = eaglePack(0x8A6440)
    private static let eagleBodyDark = eaglePack(0x4A321C), eagleBodyShade = eaglePack(0x5A3E22)
    private static let eagleHead = eaglePack(0xC8A060), eagleHeadLight = eaglePack(0xE2C488)
    private static let eagleHeadDark = eaglePack(0x9A7A44)
    private static let eagleTail = eaglePack(0x543A20), eagleTailStripe = eaglePack(0x5C4024)
    private static let eagleTailTip = eaglePack(0x3E2A16)
    private static let eagleBeak = eaglePack(0xE8C860), eagleBeakDark = eaglePack(0x8A6A2A)
    private static let eagleEye = eaglePack(0x1A120A), eagleGlint = eaglePack(0xFFF0C0)
    private static let eagleBeakShape = ["BBBB....", "BBBBBB..", "BBBBBBBB", "DDDDB.BB", "DDD....D"].map { Array($0) }

    /// What colour the Eagle is at (`x`, `y`) in its own units (y down, the body's centre at 0, 0, facing right), or 0
    /// where it isn't: the near wing, the hooked beak, the eye, the golden head and neck, the brown body, the fanned
    /// tail and the far wing behind, nearest first. Laid out as the ride's Eagle is (Rides.swift), only drawn big.
    private static func eagleColour(_ x: Double, _ y: Double, _ pose: (near: EagleWing, far: EagleWing)) -> UInt32 {
        let near = pose.near.colour(x, y)
        if near != 0 { return near }
        // The beak, hooked down at its tip, and the eye under its brow.
        if x >= 22, x < 30, y >= -8, y < -3 {
            switch eagleBeakShape[Int(y + 8)][Int(x - 22)] {
            case "B": return eagleBeak
            case "D": return eagleBeakDark
            default: break
            }
        }
        if x >= 20, x < 22, y >= -7, y < -5 { return x >= 21 && y < -6 ? eagleGlint : eagleEye }
        if x >= 19, x < 22, y >= -8, y < -7 { return eagleHeadDark }
        // The head, lit on top, its cheek shadowed; the neck below it, streaked with hackles.
        let hx = x - 18, hy = y + 6
        if hx * hx + hy * hy <= 25 {
            if hy < -(25 - hx * hx).squareRoot() + 1.2 { return eagleHeadLight }
            return hy > 3 && hx < 2 ? eagleHeadDark : eagleHead
        }
        let nx = (x - 13) / 5, ny = (y + 2) / 4
        if nx * nx + ny * ny <= 1 {
            let streak = x * 0.7 + y * 0.3
            return y > 1 || streak - streak.rounded(.down) < 0.25 ? eagleHeadDark : eagleHead
        }
        // The body: lit along the back, darker under the belly, its feathers in rows of scallops.
        let bx = x / 14, by = y / 6
        if bx * bx + by * by <= 1 {
            let depth = 6 * (1 - bx * bx).squareRoot()
            if y < -depth + 1.2 { return eagleBodyLight }
            if y > depth - 1.6 { return eagleBodyDark }
            let row = ((y + 6) / 2.2).rounded(.down)
            let along = (x + (Int(row) % 2 == 0 ? 0 : 1.2)) / 2.4
            return y > -2 && along - along.rounded(.down) < 0.22 ? eagleBodyShade : eagleBody
        }
        // The tail, fanned out behind, each feather's end rounded.
        if x >= -27, x < -11 {
            let f = (-11 - x) / 16, half = 1.8 + f * 3.6, mid = -0.5, top = mid - half
            if abs(y - mid) <= half {
                let feather = (y - top) / 2.4, part = feather - feather.rounded(.down)
                if x >= -27 + 2.4 * abs(part - 0.5) {
                    if y - top < 1 { return eagleBodyLight }
                    if x < -23.5 { return eagleTailTip }
                    return Int(((y - top) / 1.2).rounded(.down)) % 2 == 0 ? eagleTail : eagleTailStripe
                }
            }
        }
        return pose.far.colour(x, y)
    }

    // MARK: The sky

    /// The open sky above the cloud floor at `floor` (the art's pixels from the bottom): stepped bands from pale at
    /// the floor to deep blue above, clouds streaming past right to left and trailing streaks, and speed lines.
    private static func eagleSky(_ art: CGContext, k: Double, floor: Double, W: Double, H: Double) {
        let bands: [UInt32] = [0xD8ECF8, 0xB8DAF2, 0x98C6EA, 0x7AB0E0, 0x5E98D4, 0x4880C8]
        for (j, hex) in bands.enumerated() {
            art.setFillColor(eagleRGB(hex))
            art.fill(CGRect(x: 0, y: floor + H * Double(j) / 6, width: W + 1, height: H / 6 + 1))
        }
        for i in 0..<7 {
            let size = H * (0.05 + 0.05 * noise(i * 11 + 3))
            let speed = 1.4 + 0.9 * noise(i * 11 + 4)               // frame-widths over the trip
            let span = W + size * 8
            let along = noise(i * 11 + 1) + k * speed * W / span
            let x = W + size * 2 - (along - along.rounded(.down)) * span
            let y = floor + H * (0.18 + 0.75 * noise(i * 11 + 2))
            eaglePuff(art, x: x, y: y, size: size, trail: 3.5)
        }
        art.setFillColor(eagleRGB(0xFFFFFF, 0.6))
        for i in 0..<16 {
            let length = W * (0.08 + 0.16 * noise(i * 5 + 7))
            let span = W + length
            let along = noise(i * 5 + 6) + k * (3 + 2 * noise(i * 5 + 8)) * W / span
            let x = W - (along - along.rounded(.down)) * span
            art.fill(CGRect(x: x.rounded(), y: (floor + H * noise(i * 5 + 9)).rounded(), width: length.rounded(), height: 1))
        }
    }

    /// The floor of cloud the Eagle flies over, its tops along `floor`, scrolling by; at `alpha`, and only where the
    /// sky has swept (left of `reach`) while the old place is still being swept away.
    private static func eagleCloudFloor(_ art: CGContext, k: Double, floor: Double, alpha: Double, reach: Double,
                                        W: Double, H: Double) {
        guard alpha > 0, reach > 0 else { return }
        art.saveGState(); defer { art.restoreGState() }
        art.clip(to: CGRect(x: 0, y: -H, width: reach, height: 3 * H))
        art.setAlpha(CGFloat(alpha))
        art.beginTransparencyLayer(auxiliaryInfo: nil)
        let gap = H * 0.2
        let count = Int(W / gap) + 3
        let scroll = k * 1.6 * W
        let loop = Double(count) * gap
        for i in 0..<count {
            var along = (Double(i) * gap - scroll).truncatingRemainder(dividingBy: loop)
            if along < 0 { along += loop }
            let x = along - gap
            let size = H * (0.11 + 0.06 * noise(i * 3 + 40))
            eaglePuff(art, x: x, y: floor - size * 0.15 + H * 0.03 * noise(i * 3 + 41), size: size, trail: 0)
        }
        art.endTransparencyLayer()
    }

    /// The wall of cloud the Eagle's wings drive across the old place, its leading edge at `x`, billowing.
    private static func eagleCloudWall(_ art: CGContext, x: Double, k: Double, H: Double) {
        let size = H * 0.13
        var y = -size
        var i = 0
        while y < H + size {
            let s = size * (0.7 + 0.7 * noise(i * 7 + 50))
            let jitter = s * 1.2 * (noise(i * 7 + 51) - 0.5) + s * 0.15 * sin(k * 40 + Double(i))
            eaglePuff(art, x: x - s * 1.1 + jitter, y: y, size: s, trail: 0, stretch: 1)
            y += size * 0.9
            i += 1
        }
    }

    /// Clouds and speed lines rushing past in front of the Eagle while the view flies along with it: two big puffs,
    /// low and high, then a few bright streaks; at `alpha`.
    private static func eagleForeground(_ art: CGContext, k: Double, floor: Double, alpha: Double, W: Double, H: Double) {
        guard alpha > 0 else { return }
        art.saveGState(); defer { art.restoreGState() }
        art.setAlpha(CGFloat(alpha))
        for (i, (start, height)) in [(0.36, 0.02), (0.5, 0.97)].enumerated() {
            let pass = eagleSpan(k, start, start + 0.16)
            guard pass > 0, pass < 1 else { continue }
            let size = H * 0.2
            let x = W + size * 3 - pass * (W + size * 9)
            art.beginTransparencyLayer(auxiliaryInfo: nil)
            eaglePuff(art, x: x, y: floor + H * height + size * 0.1 * Double(i), size: size, trail: 2.5)
            art.endTransparencyLayer()
        }
        guard k > 0.3 else { return }
        art.setFillColor(eagleRGB(0xFFFFFF, 0.75))
        for i in 0..<5 {
            let length = W * (0.15 + 0.2 * noise(i * 9 + 60))
            let span = W + length
            let along = noise(i * 9 + 61) + k * 5 * W / span
            let x = W - (along - along.rounded(.down)) * span
            let y = floor + H * (0.1 + 0.8 * noise(i * 9 + 62))
            art.fill(CGRect(x: x.rounded(), y: y.rounded(), width: length.rounded(), height: 1))
        }
    }

    /// A puff of cloud, its lumps `stretch` times as wide as they're tall (stretched long as it streams past, round as
    /// it billows), centred at (`x`, `y`) in the art's pixels from the bottom left: grey-blue underneath, white on top,
    /// and, `trail` sizes long, a thin streak blown off behind it.
    private static func eaglePuff(_ art: CGContext, x: Double, y: Double, size: Double, trail: Double,
                                  stretch: Double = 1.5) {
        let lumps: [(Double, Double, Double)] = [(-1.1, -0.15, 0.75), (0, 0, 1), (1.05, -0.2, 0.7), (0.45, 0.35, 0.6)]
        for (shade, lift) in [(0xC4D6E8 as UInt32, -0.22), (0xF2F8FC, 0.0), (0xFFFFFF, 0.12)] {
            art.setFillColor(eagleRGB(shade))
            for (dx, dy, rr) in lumps {
                let rad = size * rr * (shade == 0xFFFFFF ? 0.6 : 1)
                art.fillEllipse(in: CGRect(x: (x + dx * size * (stretch < 1.2 ? 1 : 1.4) - rad * stretch).rounded(),
                                           y: (y + (dy + lift) * size - rad).rounded(),
                                           width: (rad * 2 * stretch).rounded(), height: (rad * 2).rounded()))
            }
        }
        guard trail > 0 else { return }
        art.setFillColor(eagleRGB(0xFFFFFF, 0.55))
        art.fill(CGRect(x: (x + size * 2.4).rounded(), y: (y - size * 0.2).rounded(),
                        width: (size * trail).rounded(), height: max(1, (size * 0.18).rounded())))
    }

    // MARK: Helpers

    private static func eagleEase(_ k: Double) -> Double { k * k * (3 - 2 * k) }
    /// How far `k` is through `a…b`: 0 before, 1 after.
    private static func eagleSpan(_ k: Double, _ a: Double, _ b: Double) -> Double { min(1, max(0, (k - a) / (b - a))) }

    /// A clear bitmap `width`×`height`, drawn into in its own pixels (y up), unsmoothed.
    private static func eagleCanvas(width w: Int, height h: Int) -> CGContext? {
        guard w > 0, h > 0, let c = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                                              space: CGColorSpaceCreateDeviceRGB(),
                                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        c.setShouldAntialias(false)
        c.interpolationQuality = .none
        return c
    }

    /// The art, scaled up onto `r` without smoothing.
    private static func eagleBlit(_ art: CGContext, onto ctx: CGContext, width w: Int, height h: Int, px: CGFloat, in r: CGRect) {
        guard let img = art.makeImage() else { return }
        ctx.saveGState()
        ctx.clip(to: r)
        ctx.interpolationQuality = .none
        ctx.draw(img, in: CGRect(x: r.minX, y: r.minY, width: CGFloat(w) * px, height: CGFloat(h) * px))
        ctx.restoreGState()
    }
}

/// One of the Eagle's wings, in its own units (y down): from the shoulder at (`x`, `y`) out along `angle` (radians)
/// for `length`, a broad plank of feathers `width` deep, its trailing edge clockwise of the wing's direction (`side`
/// +1) or anticlockwise (-1). A pale golden leading edge, two rows of coverts, then the flight feathers, each with a
/// rounded end along the trailing edge; and past two-thirds of the way out, the primaries part into five fingers,
/// fanning out wider and further apart as the wing is `spread` (0…1) mid-stroke.
private struct EagleWing {
    let x, y, dx, dy, nx, ny, length, width, spread: Double
    /// Packed colours: the leading edge, the coverts and their edges, the flight feathers, the lines between them and
    /// the dark ends.
    let cover, covert, covertEdge, feather, stripe, tip: UInt32

    init(x: Double, y: Double, angle: Double, length: Double, width: Double, side: Double, spread: Double = 0,
         colours: [UInt32]) {
        self.x = x; self.y = y; self.length = length; self.width = width; self.spread = spread
        dx = cos(angle); dy = sin(angle); nx = -dy * side; ny = dx * side
        let c = colours.map(eaglePack)
        cover = c[0]; covert = c[1]; covertEdge = c[2]; feather = c[3]; stripe = c[4]; tip = c[5]
    }

    /// The wing's colour at (`px`, `py`), or 0 where it isn't.
    func colour(_ px: Double, _ py: Double) -> UInt32 {
        let qx = px - x, qy = py - y
        let a = qx * dx + qy * dy, b = qx * nx + qy * ny      // along the wing, and across it toward the trailing edge
        guard a >= 0, b >= -1.6, a <= length * 1.08 else { return 0 }
        let f = a / length
        let fan = spread * width * 0.6 * max(0, f - 0.62) / 0.4    // the hand opening out
        let half = width * (1 - 0.3 * min(1, f)) + fan
        guard b <= half else { return 0 }
        if f > 0.66 {
            // The primaries: five fingers, the middle ones longest, each with a rounded end and slots between.
            let q = (b + 1.6) / (half + 1.6) * 5, n = q.rounded(.down), part = q - n
            let reach = length * (0.9 + 0.16 * sin(.pi * (n + 0.5) / 5)) - 2.8 * abs(part - 0.45)
            guard a <= reach else { return 0 }
            if part > 0.8 - 0.12 * spread && f > 0.74 - 0.04 * spread { return 0 }
            if b < 0.4 && f < 0.78 { return cover }
            if part < 0.18 { return stripe }
            return f > 0.84 ? tip : feather
        }
        let along = a / 2.3, part = along - along.rounded(.down)
        guard b <= half - 2 * abs(part - 0.5) else { return 0 }    // the feathers' rounded ends
        if b < 0.4 { return cover }
        if b < 2.8 {
            let c = a / 1.7 + (b < 1.6 ? 0 : 0.5), edge = c - c.rounded(.down)
            return edge < 0.25 ? covertEdge : covert
        }
        if part < 0.16 { return stripe }
        return b > half - 2.2 ? tip : feather
    }
}

/// A colour from 0xRRGGBB, packed as a pixel of the art (red in the low byte, opaque).
private func eaglePack(_ hex: UInt32) -> UInt32 {
    0xFF00_0000 | (hex & 0xFF) << 16 | (hex & 0xFF00) | (hex >> 16 & 0xFF)
}

/// A colour from 0xRRGGBB.
private func eagleRGB(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
