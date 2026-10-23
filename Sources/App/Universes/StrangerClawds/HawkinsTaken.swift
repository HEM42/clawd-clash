import Foundation

// Taken to the Upside Down: Stranger Clawds' compaction. When the session of one of the ones who've been there (Will,
// Eleven, Max, Holly, Nancy, Steve, Robin and Eddie; `Universe.abductees`) has its context compacted, the Christmas
// lights over their head start to flicker, the wall behind them goes soft and stretches like a membrane, and they're
// pulled backwards into it and gone. While they're away the membrane bulges where something presses on it from the
// other side, spores drifting off it, and THE UPSIDE DOWN types itself out over the spot. Then it tears and they
// stumble back out, slimy, spores in their hair, and the wall goes back to being a wall. Same session, same face. It
// runs on the engine's missing-time clock (`SessionRecord.abducted`, `missingTimeLength`), as The Clawd Files' missing
// time does.

/// Where it is, `k` 0…1 through it: how the lights flicker, how far the membrane has formed and stretched, how far
/// the taken one has been pulled back into it and how much of them shows, the press from the other side, the tear,
/// the slime and the spores, and the caption typed so far.
struct HawkinsTaken {
    let lights: Double
    let membrane: Double
    let stretch: Double
    let pulled: Double
    let alpha: Double
    let press: Double
    let tear: Double
    let slime: Double
    let spores: Double
    let caption: String?

    init(k: Double) {
        func ramp(_ x: Double, _ a: Double, _ b: Double) -> Double { max(0, min(1, (x - a) / (b - a))) }
        func ease(_ x: Double) -> Double { x * x * (3 - 2 * x) }
        // The lights flicker as it starts, and again as it gives them back.
        lights = ramp(k, 0, 0.04) * (1 - ramp(k, 0.3, 0.36)) + ramp(k, 0.54, 0.58) * (1 - ramp(k, 0.7, 0.78))
        // The wall goes soft behind them, holds while they're away, and closes up after.
        membrane = ramp(k, 0.04, 0.14) * (1 - ramp(k, 0.68, 0.8))
        // Pulled back into it: slowly, then all at once; out again, stumbling.
        let into = ease(ramp(k, 0.12, 0.3)), out = ease(ramp(k, 0.58, 0.68))
        pulled = k < 0.58 ? into : 1 - out
        alpha = k < 0.58 ? 1 - ramp(k, 0.2, 0.3) : ramp(k, 0.6, 0.66)
        stretch = k < 0.58 ? ramp(k, 0.14, 0.3) * (1 - ramp(k, 0.3, 0.38) * 0.6) : ramp(k, 0.54, 0.6) * (1 - ramp(k, 0.64, 0.72))
        // Something pressing on it from the other side, twice, while they're gone.
        let gone = ramp(k, 0.32, 0.56)
        press = gone > 0 && gone < 1 ? max(0, sin(gone * .pi * 2)) : 0
        tear = ramp(k, 0.58, 0.62) * (1 - ramp(k, 0.7, 0.8))
        // Back, and dripping: the slime fades as it dries, the spores drift off.
        slime = ramp(k, 0.62, 0.66) * (1 - ramp(k, 0.9, 1))
        spores = ramp(k, 0.1, 0.2) * (1 - ramp(k, 0.3, 0.34)) * 0.5 + ramp(k, 0.32, 0.36) * (1 - ramp(k, 0.9, 1))
        let full = "THE UPSIDE DOWN"
        if k >= 0.32 && k < 0.96 {
            let n = min(full.count, Int((k - 0.32) / 0.16 * Double(full.count)) + 1)
            caption = String(full.prefix(n))
        } else {
            caption = nil
        }
    }
}

/// Rows `hawkinsDrawTaken`'s canvas reaches above the sprite's top, for the lights over the head.
let hawkinsTakenTop = 12
/// Its width; its column `Sprite.bodyCenterX` is the body's middle, the membrane behind it (facing right; mirror it for
/// one facing left). It's `hawkinsTakenTop + Sprite.height` tall, its bottom rows lined up with the sprite's.
let hawkinsTakenWidth = 72
/// How far back (sprite pixels) the membrane's middle stands behind the body's.
private let wallBack = 9.0

private let skin = C(0xC9A79A), skinD = C(0x8E6A64), skinL = C(0xE6CEC2), vein = C(0x7A3A44)
private let slimeCol = C(0xB4C8A0), slimeL = C(0xE4F0D4), sporeCol = C(0xE8E4DA)

/// The lights, the membrane and the spores, on their own canvas, drawn behind the taken one. `headTop` is the head's
/// top row on the sprite.
func hawkinsDrawTaken(_ c: PixelCanvas, _ s: HawkinsTaken, headTop: Int, t: Double) {
    let top = hawkinsTakenTop
    let mid = Sprite.bodyCenterX, ground = Double(top + 43)
    let wx = mid - wallBack

    // The membrane: a tall soft oval of skin-coloured wall, lit down its left, veins branching through it, bulging
    // forward round them as they go in and pressed out from behind while they're gone.
    if s.membrane > 0 {
        let a = s.membrane
        let rx = 9.0 + 4 * s.stretch, ry = 20.0
        let cy = ground - 19
        let bulge = 5 * s.stretch + 4 * s.press
        let x0 = Int(wx - rx - 1), x1 = Int(wx + rx + bulge + 2)
        for y in Int(cy - ry)...Int(cy + ry) {
            let dy = (Double(y) - cy) / ry
            guard abs(dy) <= 1 else { continue }
            let half = rx * sqrt(1 - dy * dy)
            // Its front edge pushed forward in the middle (towards where they stood), most at chest height.
            let push = bulge * max(0, 1 - pow((Double(y) - (cy + 4)) / 11, 2))
            for x in x0...x1 {
                let dx = Double(x) - wx
                guard dx >= -half, dx <= half + push else { continue }
                let edge = dx < -half + 1.5 || dx > half + push - 1.5
                let shade = noise(x * 7 + y * 13) < 0.18
                var col = edge ? skinD : shade ? skinL : skin
                if dx < -half + 3, !edge { col = skinL }
                c.px(x, y, col.alpha(0.82 * a))
            }
        }
        // The veins: a few dark branching strokes, throbbing a little.
        let throb = 0.75 + 0.25 * sin(t * 5)
        for i in 0..<4 {
            var x = wx - 5 + Double(i) * 3.5, y = cy - ry + 4 + Double(i % 2) * 6
            for step in 0..<14 {
                x += (noise(i * 31 + step) - 0.5) * 1.6
                y += 2.2
                guard abs((y - cy) / ry) < 0.95 else { break }
                c.px(Int(x.rounded()), Int(y.rounded()), vein.alpha(0.7 * a * throb))
            }
        }
        // Where it tears: a dark ragged split down the front, slime strung across it.
        if s.tear > 0 {
            for y in Int(cy - 12)...Int(cy + 14) {
                let w = Int((2 + noise(y * 3) * 2) * s.tear)
                let x = Int(wx + rx * 0.4 + noise(y) * 1.5)
                c.rect(x, y, max(1, w), 1, C(0x2A1418, a))
                if y % 5 == 0 { c.px(x + max(1, w), y, slimeCol.alpha(a)) }
            }
        }
    }

    // The spores: pale flecks floating up off the wall (and off them, once they're back), drifting as they rise.
    if s.spores > 0 {
        for i in 0..<14 {
            let f = frac(t * 0.25 + noise(i * 17 + 3))
            let x = wx - 10 + noise(i * 29 + 1) * 34 + sin(t * 1.3 + Double(i)) * 2
            let y = ground - 6 - f * 46
            let fade = f < 0.15 ? f / 0.15 : 1 - (f - 0.15) / 0.85
            c.px(Int(x.rounded()), Int(y.rounded()), sporeCol.alpha(0.7 * s.spores * fade))
        }
    }

    // The Christmas lights: a sagging string over their head, the bulbs flickering on and off at random.
    if s.lights > 0 {
        let y0 = top + headTop - 9
        let bulbs = [C(0xE8402E), C(0x3ACB5A), C(0xF4C030), C(0x3A7AE8), C(0xE85AC8), C(0xF4C030)]
        for x in Int(mid) - 16...Int(mid) + 16 {
            let u = (Double(x) - mid) / 16
            c.px(x, y0 + Int((3 * (1 - u * u)).rounded()), C(0x2A3A2A, s.lights))
        }
        for (i, col) in bulbs.enumerated() {
            let x = Int(mid) - 14 + i * 6
            let u = (Double(x) - mid) / 16
            let y = y0 + Int((3 * (1 - u * u)).rounded()) + 1
            let on = noise(i * 13 + Int(t * 14)) > 0.45
            c.px(x, y, (on ? col : col.alpha(0.3)).alpha(s.lights))
            c.px(x, y + 1, (on ? col : col.alpha(0.3)).alpha(s.lights))
            if on { c.ellipse(x, y + 1, 2, 2, col.alpha(0.2 * s.lights)) }
        }
    }
}

/// Their own picture: pulled backwards (towards the membrane) and taking on its colour as they go in; back out, slime
/// down their top edges and over their hair, and pale spores caught in it. Only ever on the sprite's solid pixels, so
/// its outline stays as it was.
func hawkinsTakenTouch(_ c: PixelCanvas, _ s: HawkinsTaken, t: Double) {
    if s.pulled > 0 { c.shift(dx: -Int((s.pulled * 11).rounded()), dy: 0) }
    func solid(_ x: Int, _ y: Int) -> Bool { x >= 0 && y >= 0 && x < c.w && y < c.h && c.buf[(y * c.w + x) * 4 + 3] == 255 }
    if s.pulled > 0.05 && s.alpha > 0 {
        // The membrane closing over them: its colour washing over the side nearest it.
        for y in 0..<c.h {
            for x in 0..<c.w where solid(x, y) && noise(x * 5 + y * 11) < s.pulled * 0.8 - Double(x - 10) / 60 {
                c.px(x, y, skin.alpha(0.55 * s.pulled))
            }
        }
    }
    guard s.slime > 0 else { return }
    // The slime: a glossy run along the top edge of everything (head, shoulders, arms), with drips hanging down here
    // and there; spores stuck in the top of the hair.
    for x in 0..<c.w {
        guard let topY = (0..<c.h).first(where: { solid(x, $0) }) else { continue }
        guard noise(x * 19 + 7) < 0.7 * s.slime else { continue }
        c.px(x, topY, noise(x * 3) < 0.35 ? slimeL : slimeCol)
        if noise(x * 23 + 1) < 0.22 {
            let len = 1 + Int(noise(x * 41) * 3 * s.slime + frac(t * 0.4 + noise(x)) * 1.5)
            for d in 1...len where solid(x, topY + d) { c.px(x, topY + d, slimeCol) }
        }
        if noise(x * 37 + 5) < 0.18, solid(x, topY + 1) { c.px(x, topY + 1, sporeCol) }
    }
}

extension HawkinsTaken: CompactionLook {
    /// The lights over their head, the membrane behind them and the spores.
    func layers(cast: Cast, x: CGFloat, y: CGFloat, lift: CGFloat, scale: CGFloat, facing: CGFloat, t: Double) -> [StageLayer] {
        guard lights > 0 || membrane > 0 || spores > 0 else { return [] }
        let fx = PixelCanvas(hawkinsTakenWidth, hawkinsTakenTop + Sprite.height)
        hawkinsDrawTaken(fx, self, headTop: cast.drawnTop(), t: t)
        guard let img = fx.makeImage() else { return [] }
        let w = CGFloat(fx.w) * scale, h = CGFloat(fx.h) * scale
        let mid = CGFloat(Sprite.bodyCenterX)
        let left = facing < 0 ? x - (CGFloat(fx.w) - mid) * scale : x - mid * scale
        return [StageLayer(image: img, rect: CGRect(x: left.rounded(), y: y + lift, width: w, height: h), mirrored: facing < 0)]
    }

    func touch(_ sprite: PixelCanvas, t: Double) { hawkinsTakenTouch(sprite, self, t: t) }
}
