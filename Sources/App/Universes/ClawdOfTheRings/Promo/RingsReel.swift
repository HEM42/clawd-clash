import AppKit
import CoreText

// The Clawd of the Rings trailer: `REEL=clawdoftherings build/renderpromo video promo` → promo/clawd-of-the-rings-promo.mp4.
// Drawn with RenderPromo's kit (Tools/RenderPromo/Kit: `Shot`, `brawl`, `windowShot`, `everyAI`, `Mix`…) and compiled
// only into that tool.

/// The Clawd of the Rings trailer, as the tool asks for it.
struct RingsReel: PromoReel {
    let name = "clawdoftherings", base = "clawd-of-the-rings-promo", small = "Clawd-of-the-Rings"
    var title: String { Universe.middleEarth.title.uppercased() }
    let geminiTask = "gemini ▸ hide the ring from the logs"
    var shots: [Shot] { ringsShots }
    var beats: [(key: Double, beat: Beat)] { ringsBeats }
    var universe: Universe { .middleEarth }
    var brawl: BrawlCast {
        BrawlCast(claude: .hero(RingsHero.legolas), other: .villain(RingsVillain.orc),
                  agent: .hero(RingsHero.gimli), otherAgent: .villain(RingsVillain.uruk),
                  line: universe.isReleased ? "Or pick Clawd of the Rings." : "Coming soon: Clawd of the Rings.",
                  sub: "Swords, staffs and one very precious ring.")
    }
    var window: WindowCast {
        WindowCast(place: .prancingPony, claude: .hero(RingsHero.aragorn), other: .villain(RingsVillain.witchKing),
                   agentA: .hero(RingsHero.legolas), agentB: .hero(RingsHero.gimli), extra: .villain(RingsVillain.orc),
                   prompt: "You: “make the sword glow when orcs are near”", otherPrompt: "You: “make the Eye watch every request”")
    }
    func sound(_ m: Mix) { ringsSound(m) }
}

// MARK: The Clawd of the Rings trailer

/// The end card's line under "Have fun. Keep track.": never a count of universes, and "coming soon" until it ships.
var ringsTagline: String { Universe.middleEarth.isReleased ? "One of many universes in Clawd Clash · free for macOS" : "Coming soon to Clawd Clash" }

/// A Clawd of the Rings character's name, as the app has it.
func ringsName(_ h: RingsHero) -> String { Cast.hero(h).name }
func ringsName(_ v: RingsVillain) -> String { Cast.villain(v).name }

/// The title's face: a tall classical serif, the first of these the Mac has, else its bold system serif.
func ringsSerif(_ size: CGFloat) -> CTFont {
    let names: [String] = ["TrajanPro3-Bold", "TrajanPro-Bold", "Baskerville-Bold", "Optima-Bold", "Didot-Bold"]
    for name in names {
        let f = CTFontCreateWithName(name as CFString, size, nil)
        if (CTFontCopyPostScriptName(f) as String) == name { return f }
    }
    let base: NSFont = NSFont.boldSystemFont(ofSize: size)
    let serif: NSFontDescriptor = base.fontDescriptor.withDesign(.serif) ?? base.fontDescriptor
    return (NSFont(descriptor: serif, size: size) ?? base) as CTFont
}

/// `s` set in `font`, letter-spaced by `track`, as a path from its baseline's left end; and its advance.
func ringsWord(_ s: String, _ font: CTFont, track: CGFloat) -> (path: CGPath, width: CGFloat) {
    let attrs: [NSAttributedString.Key: Any] = [.font: font, .kern: track]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: s, attributes: attrs))
    let path = CGMutablePath()
    for run in CTLineGetGlyphRuns(line) as! [CTRun] {
        let count = CTRunGetGlyphCount(run)
        var glyphs = [CGGlyph](repeating: 0, count: count), at = [CGPoint](repeating: .zero, count: count)
        CTRunGetGlyphs(run, CFRange(location: 0, length: count), &glyphs)
        CTRunGetPositions(run, CFRange(location: 0, length: count), &at)
        for i in 0..<count {
            let t = CGAffineTransform(translationX: at[i].x, y: at[i].y)
            if let g = CTFontCreatePathForGlyph(font, glyphs[i], nil) { path.addPath(g, transform: t) }
        }
    }
    let w: CGFloat = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil)) - track
    return (path, w)
}

/// A thin gold rule from `x0` to `x1` at height `y`, its ends drawn out to points.
func ringsRule(_ p: CGMutablePath, x0: CGFloat, x1: CGFloat, y: CGFloat, h: CGFloat) {
    let taper: CGFloat = h * 7
    p.addLines(between: [CGPoint(x: x0, y: y), CGPoint(x: x0 + taper, y: y + h / 2), CGPoint(x: x1 - taper, y: y + h / 2),
                         CGPoint(x: x1, y: y), CGPoint(x: x1 - taper, y: y - h / 2), CGPoint(x: x0 + taper, y: y - h / 2)])
    p.closeSubpath()
}

/// The title laid out as the films lay theirs: big CLAWD, a small OF over THE stacked between, big RINGS, all on one
/// baseline, a thin rule above and below; set a little tall, centred on the origin (y up).
let ringsTitlePath: CGPath = {
    let big = ringsSerif(200), small = ringsSerif(76)
    let clawd = ringsWord("CLAWD", big, track: 10), rings = ringsWord("RINGS", big, track: 10)
    let of = ringsWord("OF", small, track: 6), the = ringsWord("THE", small, track: 6)
    let capBig: CGFloat = CTFontGetCapHeight(big), capSmall: CGFloat = CTFontGetCapHeight(small)
    let gap: CGFloat = 34
    let stackW: CGFloat = max(of.width, the.width)
    let lineGap: CGFloat = capSmall * 0.3
    let stackBase: CGFloat = (capBig - (capSmall * 2 + lineGap)) / 2          // the stack centred on the capitals
    let p = CGMutablePath()
    p.addPath(clawd.path)
    let sx: CGFloat = clawd.width + gap
    p.addPath(the.path, transform: CGAffineTransform(translationX: sx + (stackW - the.width) / 2, y: stackBase))
    p.addPath(of.path, transform: CGAffineTransform(translationX: sx + (stackW - of.width) / 2, y: stackBase + capSmall + lineGap))
    let rx: CGFloat = sx + stackW + gap
    p.addPath(rings.path, transform: CGAffineTransform(translationX: rx, y: 0))
    let end: CGFloat = rx + rings.width
    ringsRule(p, x0: -30, x1: end + 30, y: capBig + 34, h: 7)
    ringsRule(p, x0: -30, x1: end + 30, y: -34, h: 7)
    let b = p.boundingBox
    var t = CGAffineTransform(translationX: -b.midX, y: -b.midY).concatenating(CGAffineTransform(scaleX: 1, y: 1.14))
    return p.copy(using: &t)!
}()

/// The title: CLAWD (OF THE) RINGS in a tall gold serif with a dark bevelled edge, in a soft warm glow.
func ringsTitle(_ ctx: CGContext, center: CGPoint, scale s: Double, alpha: Double = 1) {
    guard s > 0.01, alpha > 0 else { return }
    let k: CGFloat = 1500 / ringsTitlePath.boundingBox.width * CGFloat(s)
    var tr = CGAffineTransform(scaleX: k, y: k).concatenating(CGAffineTransform(translationX: center.x, y: center.y))
    guard let path = ringsTitlePath.copy(using: &tr) else { return }
    let b = path.boundingBox
    let edge: CGFloat = max(1.5, 5 * k)
    ctx.saveGState()
    ctx.setAlpha(CGFloat(alpha))
    ctx.beginTransparencyLayer(auxiliaryInfo: nil)
    ctx.setLineJoin(.round)
    // the warm glow behind, then the dark edge all round
    ctx.saveGState()
    ctx.setShadow(offset: .zero, blur: 70 * k, color: hexCG(0xFF8A2A, 0.9))
    ctx.addPath(path); ctx.setFillColor(hexCG(0x6A3A08)); ctx.fillPath()
    ctx.setShadow(offset: .zero, blur: 24 * k, color: hexCG(0xFFC060, 0.7))
    ctx.addPath(path); ctx.setStrokeColor(hexCG(0x3A1E04)); ctx.setLineWidth(edge * 2); ctx.strokePath()
    ctx.restoreGState()
    // the gold, bright at the top and deep at the foot, with a band of light across the middle
    ctx.saveGState()
    ctx.addPath(path); ctx.clip()
    let colors: [CGColor] = [hexCG(0xFFF4C0), hexCG(0xF0C860), hexCG(0xB07A22), hexCG(0xF6DC8A), hexCG(0xC8922E), hexCG(0x7A4A0A)]
    let stops: [CGFloat] = [0.05, 0.3, 0.48, 0.6, 0.8, 1]
    if let gold = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: stops) {
        ctx.drawLinearGradient(gold, start: CGPoint(x: 0, y: b.maxY), end: CGPoint(x: 0, y: b.minY), options: [])
    }
    // the bevel: light on the upper-left inner edge, shadow on the lower-right
    let off: CGFloat = edge * 0.6
    ctx.saveGState()
    ctx.translateBy(x: off, y: -off)
    ctx.addPath(path); ctx.setStrokeColor(hexCG(0x5A3206, 0.85)); ctx.setLineWidth(edge * 1.4); ctx.strokePath()
    ctx.restoreGState()
    ctx.saveGState()
    ctx.translateBy(x: -off, y: off)
    ctx.addPath(path); ctx.setStrokeColor(hexCG(0xFFF8D8, 0.75)); ctx.setLineWidth(edge * 1.1); ctx.strokePath()
    ctx.restoreGState()
    ctx.restoreGState()
    ctx.endTransparencyLayer()
    ctx.restoreGState()
}

/// Embers drifting up through the dark and, while `burst` runs 0…1, a burst of them flung out from `from`.
func ringsEmbers(_ ctx: CGContext, t: Double, count: Int, alpha: Double, burst: Double = 0, from: CGPoint = .zero) {
    let w = Double(W), h = Double(H)
    for i in 0..<count {
        let speed: Double = 30 + noise(i * 3 + 2) * 70
        let x: Double = noise(i * 3) * w + sin(t * 0.8 + Double(i)) * 24
        let y: Double = (noise(i * 3 + 1) * h + t * speed).truncatingRemainder(dividingBy: h)
        let flick: Double = 0.5 + 0.5 * sin(t * 7 + Double(i) * 1.7)
        let s: Double = noise(i * 3 + 7) > 0.8 ? 6 : 4
        ctx.setFillColor(hexCG(0xFF8A2A, CGFloat(alpha * (0.35 + 0.5 * flick))))
        ctx.fill(CGRect(x: x, y: y, width: s, height: s))
    }
    guard burst > 0, burst < 1 else { return }
    for i in 0..<90 {
        let a: Double = noise(i * 5 + 300) * 2 * Double.pi
        let d: Double = (250 + noise(i * 5 + 301) * 650) * easeOut(burst)
        let s: Double = noise(i * 5 + 302) > 0.6 ? 8 : 5
        let col: UInt32 = noise(i * 5 + 303) > 0.5 ? 0xFFD27A : 0xFF6A1A
        let fx: Double = Double(from.x) + cos(a) * d
        let fy: Double = Double(from.y) + sin(a) * d - 120 * burst * burst
        ctx.setFillColor(hexCG(col, CGFloat(1 - burst)))
        ctx.fill(CGRect(x: fx, y: fy, width: s, height: s))
    }
}

/// How far (art pixels, + outside) the point `dx, dy` from the centre is from the ellipse `rx × ry`: a first-order
/// estimate, good near the curve, which is all the band needs.
private func ringBandDistance(_ dx: Double, _ dy: Double, rx: Double, ry: Double) -> Double {
    let u: Double = dx / rx, v: Double = dy / ry
    let e: Double = (u * u + v * v).squareRoot()
    let grad: Double = (u * u / (rx * rx) + v * v / (ry * ry)).squareRoot()
    guard grad > 1e-9 else { return -1e9 }
    return (e - 1) * e / grad
}

/// The One Ring in pixel art, like the sprites (6 screen pixels to the art pixel): a gold band `r` screen pixels round,
/// its width squashed by `squash` (a spin seen edge-on), its gold in bands, lit on its upper-left rim and shaded on the
/// inner one, with a glint; and (`glow` 0…1) fire-letters waking along it, a pixel or three each: not real letters.
private func oneRing(_ ctx: CGContext, center c: CGPoint, radius r: Double, squash: Double, glow: Double, alpha: Double) {
    let scale: Double = 6
    let R: Double = r / scale
    let rx: Double = max(0.5, R * squash), ry: Double = R * 0.94
    let band: Double = max(3.5, R * 0.26)
    let n: Int = Int((R * 1.95).rounded(.up)) * 2 + 4
    let mid: Double = Double(n) / 2
    let cv = PixelCanvas(n, n)
    let golds: [UInt32] = [0xFFF4B0, 0xF4D884, 0xE8B040, 0xB88428, 0x8A5A12, 0xB88A30, 0xF0C860, 0xB07E2A, 0x7A4A0A]
    for y in 0..<n {
        for x in 0..<n {
            let dx: Double = Double(x) + 0.5 - mid, dy: Double = Double(y) + 0.5 - mid
            if glow > 0 {                                     // a warm halo once the letters wake, in steps
                let dd: Double = (dx * dx + dy * dy).squareRoot()
                let a: Double = 0.35 * glow * (1 - (dd - R * 0.5) / (R * 1.4))
                let q: Double = (a / 0.06).rounded(.down) * 0.06
                if dd > R * 0.5 && q > 0 { cv.px(x, y, C(0xFF6A1A, q)) }
            }
            let d: Double = ringBandDistance(dx, dy, rx: rx, ry: ry)
            guard abs(d) <= band / 2 else { continue }
            guard abs(dy) <= ry + band / 2 else { continue }        // edge-on it stays the ring's own height
            let s: Double = clamp((dx / (rx + band) + dy / (ry + band)) / 4 + 0.5)
            var col: UInt32 = golds[min(golds.count - 1, Int(s * Double(golds.count)))]
            let across: Double = d / (band / 2)                // -1 the inner rim … +1 the outer
            let angle: Double = atan2(dy / ry, dx / rx)
            if across > 0.5 && dx + dy < 0 { col = 0xFFF8D0 }
            else if across < -0.5 { col = 0x6A3E08 }
            if abs(angle + 2.2) < 0.3 && abs(across) < 0.35 { col = 0xFFFFF0 }   // the glint
            cv.px(x, y, C(col))
        }
    }
    if glow > 0 {
        let count: Int = max(12, Int(2 * Double.pi * R / 3.2))
        let hot = C(0xFFE08A, glow), fire = C(0xFF7A1A, glow)
        for i in 0..<count {
            let a: Double = Double(i) / Double(count) * 2 * Double.pi
            let ix = Int((mid + cos(a) * rx).rounded(.down)), iy = Int((mid + sin(a) * ry).rounded(.down))
            let tx = Int((-sin(a)).rounded()), ty = Int(cos(a).rounded())       // along the band
            let nx = Int(cos(a).rounded()), ny = Int(sin(a).rounded())          // out across it
            let kind = Int(noise(i * 7 + 90) * 3)
            cv.px(ix, iy, hot)
            if kind == 1 { cv.px(ix + tx, iy + ty, fire); cv.px(ix + tx + nx, iy + ty + ny, fire) }
            if kind == 2 { cv.px(ix - nx, iy - ny, fire); cv.px(ix + tx + nx, iy + ty + ny, fire) }
        }
    }
    guard let img = cv.makeImage() else { return }
    let x0: Double = ((Double(c.x) - mid * scale) / scale).rounded() * scale
    let y0: Double = ((Double(c.y) - mid * scale) / scale).rounded() * scale
    ctx.saveGState()
    ctx.setAlpha(CGFloat(alpha)); ctx.interpolationQuality = .none
    ctx.draw(img, in: CGRect(x: x0, y: y0, width: Double(n) * scale, height: Double(n) * scale))
    ctx.restoreGState()
}

/// When Gandclawd walks up the lane at Bag Endpoint, shot-local seconds, and from where to where (fx units).
let ringsGandalfWalk: (from: Double, to: Double, x0: Double, x1: Double) = (0.3, 2.1, -30, 112)

/// The cold open, as the films open in the Shire: Bag Endpoint by day. Gandclawd walks up the lane from the left,
/// Frodough hops to greet him when he arrives, and Bilbyte, by the round door, holds up his contract and lets it unroll.
/// The fireworks trip that follows takes it away.
func ringsBagEnd(_ ctx: CGContext, local l: Double, t: Double) {
    blit(place(.bagEnd, floorRows: 34, t: t), ctx)
    let w = ringsGandalfWalk
    let walk: Double = clamp((l - w.from) / (w.to - w.from))
    let bilbo = Cast.hero(RingsHero.bilbo), len = bilbo.signatureLength ?? 3.4
    let crew: [Actor] = [
        Actor(cast: .hero(RingsHero.gandalf), x: lerp(w.x0, w.x1, walk), mode: .idle, walking: walk > 0 && walk < 1),
        Actor(cast: .hero(RingsHero.frodo), x: 160, facing: -1, mode: .idle, role: l > w.to - 0.2 ? .cheer : .none),
        Actor(cast: bilbo, x: 222, facing: -1, mode: .idle),
    ]
    for var a in crew {
        a.lift = 8
        // Bilbyte's contract from 0.6 s; everyone else just stands, with no habit of their own creeping in.
        forcedHabit = a.cast == bilbo && l > 0.6 ? HabitPlay(kind: .signature, e: min(l - 0.6, len), length: len)
                                                 : HabitPlay(kind: .glance, e: 0)
        draw(a, ctx, t: t)
        forcedHabit = nil
    }
}

/// The opening: a black field with embers; the One Ring falls in slow motion, spinning, lands with a bounce, its
/// fire-letters wake, and its band opens out into the burning title.
func ringsOpening(_ ctx: CGContext, local l: Double, t: Double) {
    ctx.setFillColor(CGColor(gray: 0, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    ringsEmbers(ctx, t: t, count: 70, alpha: 0.55)
    let cx = Double(W) / 2, floorY: Double = 470
    let fall: Double = clamp(l / 2.0)
    var cy: Double = lerp(Double(H) + 260, floorY, fall)
    if l > 2.0 { let b: Double = l - 2.0; cy = floorY + 46 * abs(sin(b * 9)) * exp(-b * 6) }
    let spinTotal: Double = 6 * Double.pi
    let spin: Double = spinTotal * easeOut(fall)
    let squash: Double = max(0.06, abs(cos(spin)))
    let unroll: Double = clamp((l - 3.0) / 0.8)
    if l > 1.9 {                                             // the unseen floor's glow under it
        let pool: [CGColor] = [hexCG(0xFF7A1A, CGFloat(0.18 * clamp((l - 1.9) / 0.4) * (1 - unroll))), hexCG(0xFF7A1A, 0)]
        let ps: [CGFloat] = [0, 1]
        if let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: pool as CFArray, locations: ps) {
            ctx.saveGState()
            ctx.translateBy(x: CGFloat(cx), y: CGFloat(floorY - 150)); ctx.scaleBy(x: 1, y: 0.18)
            ctx.drawRadialGradient(g, startCenter: .zero, startRadius: 0, endCenter: .zero, endRadius: 420, options: [])
            ctx.restoreGState()
        }
    }
    if unroll < 1 {
        oneRing(ctx, center: CGPoint(x: cx, y: cy), radius: 150 * (1 + unroll * 0.8), squash: squash,
                glow: clamp((l - 2.0) / 0.8), alpha: 1 - unroll)
    }
    let titleY: Double = lerp(floorY, Double(H) / 2, easeOut(unroll))
    if unroll > 0 { ringsTitle(ctx, center: CGPoint(x: cx, y: titleY), scale: lerp(0.2, 1, easeOut(unroll)), alpha: clamp(unroll * 1.6)) }
    if l > 3.8 { ringsEmbers(ctx, t: t, count: 0, alpha: 0, burst: (l - 3.8) / 0.9, from: CGPoint(x: cx, y: Double(H) / 2)) }
}

/// Draws `a` darkened towards a near-black silhouette (`dark` 0…1).
private func drawShadowed(_ a: Actor, _ ctx: CGContext, t: Double, dark: Double) {
    guard dark > 0 else { draw(a, ctx, t: t); return }
    let box = CGRect(x: (a.x - 40) * S, y: stageH - (a.top + 56) * S, width: 90 * S, height: 62 * S)
    ctx.saveGState()
    ctx.clip(to: box)
    ctx.beginTransparencyLayer(auxiliaryInfo: nil)
    draw(a, ctx, t: t)
    ctx.setBlendMode(.sourceAtop)
    ctx.setFillColor(hexCG(0x0C0A12, CGFloat(dark))); ctx.fill(box)
    ctx.endTransparencyLayer()
    ctx.restoreGState()
}

/// Gandclawd hanging from the broken edge (the deck's top row `deck`), in front of the chasm: one arm (screen-left)
/// straight up, its hand gripping the deck's top edge, the other down at his side holding his staff, all the rest of
/// him dangling under the edge, tilted towards the gripping hand, his legs kicking, swaying by `sway` (radians, about
/// that hand). Only the hand shows above the deck. `fall` 0…1: he has let go and drops through the dark under the deck
/// from that very pose, tumbling, shrinking and darkening into the glow of the deep.
func ringsHanging(_ who: Actor, _ ctx: CGContext, x: Double, deck g: Int, sway: Double, fall: Double, t: Double) {
    let top: Int = g - 11                                     // the hat's tip (its row 12) just under the deck's top
    let left: Int = Int(x) - Int(Sprite.bodyCenterX)
    let sprite = PixelCanvas(Sprite.width, Sprite.height)
    who.cast.draw(sprite, t: t, mode: .working, walking: fall == 0, role: .rest, urgent: false, sitting: false,
                  asSession: true, airborne: false)
    sprite.move(columns: 0..<14, rows: 0..<Sprite.height, dy: 1000)         // his staff, at his side, goes:
    sprite.move(columns: 14..<15, rows: 26..<Sprite.height, dy: 1000)       // it moves to the other hand
    sprite.move(columns: 14..<15, rows: 13..<19, dy: 1000)
    let fig = PixelCanvas(fxW, fxH + 20)
    fig.paste(sprite, x: left, y: top)
    let sleeve = C(0x8A8C92), sleeveShade = C(0x5E6066), hand = C(0xD97757)
    let wood = C(0x6A4A2A), woodDark = C(0x4A321C), woodLight = C(0x8A6A44)
    // the gripping arm: from just under the edge down to his shoulder (row 35), the hand over the edge
    fig.rect(left + 13, g + 2, 3, 23, sleeve); fig.rect(left + 15, g + 2, 1, 23, sleeveShade)
    fig.rect(left + 13, g - 1, 3, 3, hand)
    // the staff in his other hand, its gnarled head a little above his shoulder, hanging down past his feet
    let sx: Int = left + 43, sy: Int = top + 25
    fig.pattern(sx - 1, sy, [".WWD.", "DW..W", "W.W.W", "W.WW.", "WW...", ".W..."], ["W": wood, "D": woodDark])
    fig.px(sx + 2, sy, woodLight); fig.px(sx + 3, sy + 1, woodLight)
    fig.rect(sx, sy + 6, 1, 17, wood); fig.px(sx, sy + 12, woodLight); fig.px(sx, sy + 18, woodDark)
    fig.rect(left + 41, top + 34, 1, 2, sleeve)
    fig.rect(left + 42, top + 33, 3, 3, hand)
    fig.addOutline(C(who.ai.hex, 0.92))
    let px: CGFloat = CGFloat((Double(left) + 14.5) * S), py: CGFloat = CGFloat(stageH - Double(g) * S)
    let tilt: Double = -0.22 + sway                           // hanging from one hand, he leans in under it
    let f: Double = clamp(fall)
    let dark: Double = 0.85 * clamp((f - 0.15) / 0.6)
    ctx.saveGState()
    ctx.interpolationQuality = .none
    if f > 0 {
        let down: Double = 30 * pow(f, 1.4)                    // fx rows his middle sinks
        let shrink: Double = lerp(1, 0.15, 1 - pow(1 - f, 1.6))
        let turn: Double = -0.9 * f + 0.15 * sin(f * 9)       // a slow tumble, a wobble in it
        let cx: Double = (x - 2 * f) * S
        let cy: Double = stageH - (Double(top) + 28) * S
        ctx.clip(to: CGRect(x: 0, y: 0, width: stageW, height: stageH - Double(g - 2) * S))   // under the edge only
        ctx.setAlpha(CGFloat(1 - clamp((f - 0.7) / 0.3)))
        ctx.translateBy(x: CGFloat(cx), y: CGFloat(cy - down * S))
        ctx.rotate(by: CGFloat(turn))
        ctx.scaleBy(x: CGFloat(shrink), y: CGFloat(shrink))
        ctx.translateBy(x: CGFloat(-x * S), y: CGFloat(-cy))
    }
    ctx.translateBy(x: px, y: py); ctx.rotate(by: CGFloat(tilt)); ctx.translateBy(x: -px, y: -py)
    ctx.beginTransparencyLayer(auxiliaryInfo: nil)
    blit(fig, ctx)
    if dark > 0 {
        ctx.setBlendMode(.sourceAtop)
        ctx.setFillColor(hexCG(0x0C0A12, CGFloat(dark))); ctx.fill(CGRect(x: -W, y: -H, width: 3 * W, height: 3 * H))
    }
    ctx.endTransparencyLayer()
    ctx.restoreGState()
}

/// The Mines of Mori-ah: drums in the deep; the Fellowship sets out over the bridge; the Ballrog rises and they flee;
/// Gandclawd turns and slams his staff (YOU SHALL NOT PASS!), the span breaks, the Ballrog falls, its whip catches
/// his feet, and he hangs from the edge (Fly, you fools!), lets go and falls into the deep.
func ringsBridge(_ ctx: CGContext, local l: Double, t: Double) {
    let g = fxH - 42                                          // the bridge's top row (the camera up a little: room below)
    let gandalf = Cast.hero(RingsHero.gandalf), balrog = Cast.villain(RingsVillain.balrog)
    let sigAt: Double = 3.5, sigLength: Double = gandalf.signatureLength ?? 3.0
    let slamAt: Double = sigAt + sigLength * 0.29             // the staff strikes (his signature's impact)
    let fallAt: Double = 4.5
    let cutX = 206, cutEnd = fxW - 24                         // the span that falls, to the far abutment
    let drop: Double = l > fallAt ? 210 * easeIn((l - fallAt) / 1.3) : 0
    // the doom-drums shake the frame on every beat until the slam, and the slam shakes it hard
    var shake: Double = 0
    if l < slamAt && l.truncatingRemainder(dividingBy: 0.6) < 0.08 { shake = Int(l / 0.6) % 2 == 0 ? 3 : -3 }
    if l > slamAt && l < slamAt + 0.3 { shake = sin(l * 120) * 9 }
    ctx.saveGState()
    ctx.translateBy(x: CGFloat(shake), y: CGFloat(-shake * 0.6))
    let cave = place(.moria, floorRows: 42, t: t)
    if drop > 0 {                                             // the span gone: the chasm shows where it was
        for y in g..<cave.h {
            let k: Double = Double(y - g) / Double(max(1, cave.h - g))
            cave.rect(cutX, y, cutEnd - cutX, 1, lerp(C(0x3A1A0A), C(0x9A4214), k))
        }
    }
    if l > slamAt && l < fallAt + 0.2 {                       // the crack running along the deck under the Ballrog
        let run = Int(clamp((l - slamAt) / 0.3) * Double(cutEnd - cutX - 10))
        for i in 0..<max(0, run) { cave.px(cutX + i, g + 1 + (i / 3) % 2, C(0x1A1410)) }
        for y in g..<(g + 3) { cave.px(cutX, y, C(0x1A1410)) }
    }
    blit(cave, ctx)
    if drop > 0 && drop < 200 {                               // the broken span, falling: deck and arch
        let w = cutEnd - cutX, sh = fxH - g
        let slab = PixelCanvas(w, sh)
        let half: Double = Double(fxW - 48) / 2
        for x in 0..<w {
            let u: Double = Double(min(x + cutX - 24, cutEnd - (x + cutX))) / half
            let extra = min(sh - 3, Int(pow(1 - u, 4) * Double(sh)) + (u > 0.15 ? 1 : 2))
            slab.rect(x, 3, 1, extra, C(0x6A6056)); slab.px(x, 2 + extra, C(0x2E2620))
        }
        slab.rect(0, 0, w, 3, C(0x9A8E80)); slab.rect(0, 2, w, 1, C(0x655B52)); slab.rect(0, 0, w, 1, C(0xD8CBB4))
        blit(slab, ctx, dx: Double(cutX) * 6, dy: (Double(g) + drop) * 6)
    }
    onStage(ctx, CGRect(x: 0, y: 0, width: W, height: H), scale: 6, ground: Double(g + 2)) {
        // the Fellowship: out over the bridge, then (the Ballrog!) back the way they came, running
        let walkers: [RingsHero] = [.frodo, .sam, .pippin, .aragorn, .legolas, .gimli, .boromir]
        for (i, who) in walkers.enumerated() {
            let x0: Double = 100 - Double(i) * 28
            var a = Actor(cast: .hero(who), x: x0 + min(l, 2.0) * 30, mode: .working, role: .rest, walking: l < 2.0)
            if l > 2.25 { a.x = x0 + 60 - (l - 2.25) * 150; a.facing = -1; a.walking = true }
            if a.x > -40 { draw(a, ctx, t: t) }
        }
        // Gandclawd: at the head of them, back to mid-bridge, then he turns
        var gd = Actor(cast: gandalf, x: 132 + min(l, 2.0) * 30, mode: .working, role: .rest, walking: l < 2.0)
        if l > 2.25 && l < 3.2 { gd.x = 192 - (l - 2.25) * 28; gd.facing = -1; gd.walking = true }
        if l >= 3.2 { gd.x = 165 }
        let whipAt: Double = 4.9, pullAt: Double = 5.3, hangAt: Double = 5.9, letGoAt: Double = 6.45
        let hangX: Double = 206                               // where he hangs: on the broken edge
        if l > pullAt { gd.x = lerp(165, hangX, easeIn((l - pullAt) / (hangAt - pullAt))) }
        if l >= sigAt && l < pullAt {
            gd.mode = .idle; gd.role = .none
            forcedHabit = HabitPlay(kind: .signature, e: l - sigAt, length: sigLength)
            draw(gd, ctx, t: t)
            forcedHabit = nil
        } else if l < hangAt {
            draw(gd, ctx, t: t)
        } else if l < letGoAt + 0.8 {                          // hanging by his hands, then he lets go and falls into the deep
            let sway: Double = 0.07 * sin((min(l, letGoAt) - hangAt) * 7)   // swinging from his hands, kept as he lets go
            ringsHanging(gd, ctx, x: hangX, deck: g, sway: sway, fall: l > letGoAt ? (l - letGoAt) / 0.8 : 0, t: t)
        }
        // the Ballrog: up out of the chasm behind the bridge, the whip cracked, then down with the span
        if l > 2.0 {
            var b = Actor(cast: balrog, x: 252, facing: -1, mode: .idle)
            b.lift = l < 3.5 ? lerp(-64, 0, easeOut((l - 2.0) / 1.5)) : -drop
            ctx.saveGState()
            if l < 3.5 { ctx.clip(to: CGRect(x: 0, y: stageH - Double(g + 3) * S, width: stageW, height: Double(g + 3) * S)) }
            if l > 3.0 && l < 4.8 { forcedHabit = HabitPlay(kind: .flourish, e: l - 3.0) }
            if b.lift > -170 { draw(b, ctx, t: t) }
            forcedHabit = nil
            ctx.restoreGState()
            // its whip, snapping back up over the edge to Gandclawd's feet
            if l > whipAt && l < hangAt + 0.1 {
                let fx = PixelCanvas(fxW, fxH + 220)
                let p0: (Double, Double) = (238, Double(g) - 30 + drop), p1: (Double, Double) = (Double(cutX) + 4, Double(g) - 16)
                let p2: (Double, Double) = (gd.x + 6, Double(g) - 1)
                let reach: Double = clamp((l - whipAt) / 0.25)
                var last = p0
                for k in 1...24 {
                    let u: Double = Double(k) / 24 * reach
                    let ax: Double = (1 - u) * (1 - u) * p0.0 + 2 * (1 - u) * u * p1.0 + u * u * p2.0
                    let ay: Double = (1 - u) * (1 - u) * p0.1 + 2 * (1 - u) * u * p1.1 + u * u * p2.1
                    fx.glowLine(last.0, last.1, ax, ay, core: C(0xFFE08A), glow: C(0xE0401A), coreR: 0.6, glowR: 2.2)
                    last = (ax, ay)
                }
                blit(fx, ctx)
            }
        }
        if l > slamAt && l < 5.8 {
            let pop: Double = backOut((l - slamAt) / 0.25)
            let head = headPoint(Actor(cast: gandalf, x: 165))
            balloon("YOU SHALL NOT PASS!", ctx, center: CGPoint(x: 760, y: 900), tail: CGPoint(x: head.x - 10, y: head.y + 30),
                    size: max(4, 60 * CGFloat(pop)), width: 1100)
        }
        if l > 6.0 && l < 7.2 {                                // said as he lets go; it stays where he was, fading
            let pop: Double = backOut((l - 6.0) / 0.25)
            balloon("Fly, you fools!", ctx, center: CGPoint(x: 1000, y: 640), tail: CGPoint(x: 210 * S, y: stageH - Double(g + 10) * S),
                    size: max(4, 48 * CGFloat(pop)), width: 900, alpha: 1 - clamp((l - 6.8) / 0.4))
        }
    }
    ctx.restoreGState()
    // the flames flare as the Ballrog rises, and the white flash of the slam
    if l > 2.0 && l < 3.8 {
        let pulse: Double = sin(Double.pi * clamp((l - 2.0) / 1.8)) * (0.75 + 0.25 * sin(l * 23))
        ctx.setFillColor(hexCG(0xFF5A10, CGFloat(0.22 * pulse))); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    }
    if l > slamAt && l < slamAt + 0.1 { ctx.setFillColor(CGColor(gray: 1, alpha: 0.85)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H)) }
}

/// The ridge's top row at column `x` (fx units), for the Fellowship's walk at dusk.
func ringsRidge(_ x: Double) -> Double { 132 - 6 * sin(x / 50 + 0.4) - 2.5 * sin(x / 13) }

/// A ridge at dusk: the walkers march along it single file, dark against the sky, then lit, their names popping up;
/// Gladriel appears at the far end and raises her light.
func ringsFellowship(_ ctx: CGContext, local l: Double, t: Double) {
    let skyColors: [CGColor] = [hexCG(0x2A2A4A), hexCG(0x6A4A6A), hexCG(0xE8905A)]
    let skyStops: [CGFloat] = [0, 0.6, 1]
    if let sky = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: skyColors as CFArray, locations: skyStops) {
        ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: 260), options: [.drawsAfterEndLocation])
    }
    for i in 0..<110 {
        let y: Double = 520 + noise(i * 3 + 1) * Double(H - 520)
        let tw: Double = 0.6 + 0.4 * sin(t * 2.5 + Double(i))
        let a: Double = clamp((y - 520) / 400) * (noise(i * 3 + 2) > 0.85 ? 0.9 : 0.5) * tw
        let s: Double = noise(i * 3 + 2) > 0.85 ? 5 : 3
        ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: CGFloat(a)))
        ctx.fill(CGRect(x: noise(i * 3) * Double(W), y: y, width: s, height: s))
    }
    let land = PixelCanvas(fxW, fxH)
    for x in 0..<fxW {
        let fx = Double(x)
        let far = Int(112 - 10 * sin(fx / 37 + 1.3) - 4 * sin(fx / 11))
        land.rect(x, far, 1, fxH - far, C(0x3A2A44))
        let r = Int(ringsRidge(fx))
        land.rect(x, r, 1, fxH - r, C(0x14101A))
    }
    blit(land, ctx)
    let walkers: [RingsHero] = [.gandalf, .aragorn, .legolas, .gimli, .boromir, .frodo, .sam, .pippin]
    let dark: Double = 0.92 * (1 - clamp((l - 1.5) / 0.4))
    // Gladriel at the far end, and the light round her
    let gf: Double = clamp((l - 3.0) / 0.5)
    if gf > 0 {
        let gx: Double = 304
        let c = CGPoint(x: gx * S, y: stageH - (ringsRidge(gx) - 22) * S)
        let glow: [CGColor] = [CGColor(gray: 1, alpha: CGFloat(0.10 * gf)), CGColor(gray: 1, alpha: 0)]
        let gs: [CGFloat] = [0, 1]
        if let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: glow as CFArray, locations: gs) {
            ctx.drawRadialGradient(g, startCenter: c, startRadius: 0, endCenter: c, endRadius: 520, options: [])
        }
        var a = Actor(cast: .hero(RingsHero.galadriel), x: gx, facing: -1, mode: .idle)
        a.lift = groundY - ringsRidge(gx); a.alpha = gf
        forcedHabit = HabitPlay(kind: .signature, e: l - 3.0, length: Cast.hero(RingsHero.galadriel).signatureLength)
        draw(a, ctx, t: t)
        forcedHabit = nil
    }
    var tags: [(String, Double, Double)] = []
    for (i, who) in walkers.enumerated() {
        var a = Actor(cast: .hero(who), x: 36 - Double(i) * 30 + l * 48, walking: true)
        guard a.x > -30 else { continue }
        a.lift = groundY - ringsRidge(a.x)
        drawShadowed(a, ctx, t: t, dark: dark)
        let tagY: Double = stageH - (ringsRidge(a.x) - 50) * S + (i % 2 == 1 ? 60 : 0)
        if a.x >= 60 && dark == 0 { tags.append((a.cast.name, a.x * S, tagY)) }
    }
    // the name tags, every other one a row higher so neighbours don't overlap
    for (name, x, y) in tags { chip(name, ctx, centerX: x, bottomY: y, size: 22, agent: false) }
}

/// Four quick comic panels, one signature move each.
func ringsMoves(_ ctx: CGContext, local l: Double, t: Double) {
    ctx.setFillColor(CGColor(gray: 0, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    let panels: [(Location, Cast, Double, Double)] = [(.bagEnd, .hero(RingsHero.frodo), 0.2, 1), (.prancingPony, .hero(RingsHero.boromir), 0.45, -1),
                                                      (.moria, .villain(RingsVillain.gollum), 0.7, 1), (.prancingPony, .hero(RingsHero.legolas), 0.95, -1)]
    let pw = Double(W) / 2, ph = Double(H) / 2
    for (i, (loc, who, at, facing)) in panels.enumerated() {
        let r = CGRect(x: Double(i % 2) * pw, y: i < 2 ? ph : 0, width: pw, height: ph)
        // The backdrop at 240×135, 4 px a pixel (a canvas under the places' "tall" size, so the strip layout); the crew at
        // 3 px a pixel, so session size for a half-size frame.
        let ground: Double = loc == .moria ? 147.5 : 152
        onStage(ctx, r, scale: 3, ground: ground) {
            blit(place(loc, floorRows: 26, t: t, w: 240, h: 135), ctx, scale: 4, dy: Double(H) - ph)
            let e: Double = max(0, l - at)
            let len: Double = who.signatureLength ?? 3.0
            let a = Actor(cast: who, x: 160, facing: facing, mode: .idle)
            forcedHabit = HabitPlay(kind: .signature, e: e, length: len)
            draw(a, ctx, t: t)
            forcedHabit = nil
            if who == .hero(RingsHero.boromir) && e / len >= 0.2 {
                let pop: Double = backOut((e / len - 0.2) * len / 0.25)
                balloon("One does not simply push to main.", ctx, center: CGPoint(x: 560, y: 420), tail: headPoint(a),
                        size: max(4, 26 * CGFloat(pop)), width: 380)
            }
        }
    }
    ctx.setStrokeColor(CGColor(gray: 0, alpha: 1)); ctx.setLineWidth(12)
    ctx.move(to: CGPoint(x: pw, y: 0)); ctx.addLine(to: CGPoint(x: pw, y: Double(H)))
    ctx.move(to: CGPoint(x: 0, y: ph)); ctx.addLine(to: CGPoint(x: Double(W), y: ph))
    ctx.strokePath()
    ctx.setLineWidth(24); ctx.stroke(CGRect(x: 0, y: 0, width: W, height: H))
    let mid = CGPoint(x: pw, y: ph)
    let second: Double = 5.0 * 0.55
    if l > 0.1 && l < second {
        captionBox("EVERYONE GETS A SIGNATURE MOVE.", ctx, center: mid, size: max(4, 40 * CGFloat(backOut((l - 0.1) / 0.25))))
    }
    if l >= second {
        captionBox("SOME ARE MORE PRECIOUS THAN OTHERS.", ctx, center: mid, size: max(4, 40 * CGFloat(backOut((l - second) / 0.25))))
    }
}

/// Subagents walking in; then the Great Eagle swoops down and carries the leftmost one, Samwise, home.
func ringsAgents(_ ctx: CGContext, local l: Double, t: Double) {
    let crew: [Cast] = [.hero(RingsHero.pippin), .hero(RingsHero.gimli), .hero(RingsHero.legolas), .hero(RingsHero.sam)]
    let pickupAt: Double = 1.4, grabAt: Double = 2.2, goneAt: Double = 3.6
    let picking = l > pickupAt && l < goneAt
    agentsOf(ctx, local: l, t: t, guardCast: .hero(RingsHero.gandalf), crew: l > pickupAt ? Array(crew.prefix(3)) : crew,
             line: "Every subagent joins the Fellowship. Some fly home.", badgeText: Universe.middleEarth.title.uppercased())
    guard picking else { return }
    // the talons' path, screen pixels: down from the top right to the agent's shoulders, then away up to the left
    let stand = Actor(cast: crew[3], x: 40, session: false)
    let shoulders: Double = stand.top + 30 * stand.k
    let grabX: Double = 40 * S, grabY: Double = stageH - shoulders * S
    var tx: Double, ty: Double
    if l < grabAt {
        let u: Double = (l - pickupAt) / (grabAt - pickupAt)
        tx = lerp(Double(W) + 200, grabX, easeOut(u)); ty = lerp(Double(H) + 150, grabY, easeOut(u * 1.2))
    } else {
        let v: Double = (l - grabAt) / (goneAt - grabAt)
        tx = lerp(grabX, -500, easeIn(v)); ty = lerp(grabY, Double(H) + 300, easeIn(v * 0.9))
    }
    var a = stand
    a.label = "Plan the refactor"
    if l >= grabAt { a.x = tx / S; a.lift = shoulders - (stageH - ty) / S }
    draw(a, ctx, t: t)
    let ec = PixelCanvas(Ride.width, Ride.height)
    drawRide(ec, .eagle, ramp: 0, engines: true, gear: true, t: t)
    ec.flipHorizontally()
    ec.addOutline(C(0xFFFFFF, 0.92))
    if let img = ec.makeImage() {
        let px: Double = 6.0 * 2 / 3
        let w: Double = Double(Ride.width) * px, h: Double = Double(Ride.height) * px
        ctx.saveGState(); ctx.interpolationQuality = .none
        ctx.draw(img, in: CGRect(x: tx - Double(Ride.width - 34) * px, y: ty - (h - 27 * px), width: w, height: h))
        ctx.restoreGState()
    }
}

/// The end card: Mount Doomscroll under the Eye, the Great Eagle flying across, the crew, the title, the strip.
func ringsEndcard(_ ctx: CGContext, local: Double, t: Double) {
    blit(place(.mountDoom, floorRows: 34, t: t), ctx)
    ctx.setFillColor(CGColor(gray: 0, alpha: 0.3)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    let fp: Double = local / 1.2
    if fp > 0 && fp < 1 {
        let bc = PixelCanvas(Ride.width, Ride.height)
        drawRide(bc, .eagle, ramp: 0, engines: true, gear: false, t: t); bc.addOutline(C(0xFFFFFF, 0.92))
        if let img = bc.makeImage() {
            let x: Double = lerp(-600, Double(W) + 100, easeIn(fp) * 0.6 + fp * 0.4)
            ctx.saveGState(); ctx.interpolationQuality = .none
            ctx.draw(img, in: CGRect(x: x, y: 600 + 200 * fp, width: Double(Ride.width) * 6, height: Double(Ride.height) * 6))
            ctx.restoreGState()
        }
    }
    let duel = fightRoles(Cast.hero(RingsHero.aragorn).weapon, Cast.villain(RingsVillain.witchKing).weapon)
    let crew: [(Cast, FightRole, AI)] = [(.hero(RingsHero.gandalf), .cheer, .desktop), (.hero(RingsHero.aragorn), duel.0, .claude),
                                         (.villain(RingsVillain.witchKing), duel.1, .codex), (.villain(RingsVillain.shelob), .none, .copilot),
                                         (.villain(RingsVillain.saruman), .cheer, .qwen), (.villain(RingsVillain.gollum), .none, .gemini)]
    let xs: [Double] = [28, 84, 156, 206, 252, 296]
    var placed: [Actor] = []
    for (i, (who, role, ai)) in crew.enumerated() {
        var a = Actor(cast: who, x: xs[i], facing: i < 2 ? 1 : -1, role: role, ai: ai)
        a.lift = 8
        a.alpha = clamp((local - 0.15 - Double(i) * 0.05) / 0.2)
        // Late in the card Shellob climbs her thread up out of sight, and stays gone (her move held where she's gone; a
        // signature only plays idle).
        let len = who.signatureLength ?? 3.6
        if who == .villain(RingsVillain.shelob), local > 2.8 {
            a.mode = .idle
            forcedHabit = HabitPlay(kind: .signature, e: min(local - 2.8, 0.19 * len), length: len)
        }
        draw(a, ctx, t: t)
        forcedHabit = nil
        placed.append(a)
    }
    if local > 0.5 { drawFX([(placed[1], placed[2])], ctx, t: t) }
    if local > 0.35 { ringsTitle(ctx, center: CGPoint(x: Double(W) / 2, y: 760), scale: backOut((local - 0.35) / 0.4) * 0.8) }
    caption("Have fun. Keep track.", ctx, local: local, start: 0.6, y: 520, size: 56)
    caption(ringsTagline, ctx, local: local, start: 0.8, y: 462, size: 34, color: NSColor(white: 0.85, alpha: 1), weight: .bold)
    let ff: Double = easeOut((local - 0.9) / 0.3)
    if ff > 0, let icon = appIcon {
        ctx.setFillColor(CGColor(red: 0.04, green: 0.05, blue: 0.09, alpha: CGFloat(0.8 * ff))); ctx.fill(CGRect(x: 0, y: 0, width: W, height: 170))
        ctx.saveGState(); ctx.setAlpha(CGFloat(ff)); ctx.interpolationQuality = .high
        ctx.draw(icon, in: CGRect(x: 580, y: 20, width: 130, height: 130))
        ctx.restoreGState()
        text("github.com/rodclemen/clawd-clash", ctx, x: 740, y: 60, size: 44, weight: .bold, alpha: ff)
    }
}

let ringsShots: [Shot] = [
    Shot(name: "meanwhile", start: 0, end: 3.5, into: .cut) { ctx, local, t in
        ctx.setFillColor(CGColor(gray: 0, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let line = "MEANWHILE, AT \(Location.bagEnd.name.uppercased())..."
        let n = Int(clamp((local - 0.3) / 1.6) * Double(line.count))
        let a: Double = 1 - clamp((local - 3.0) / 0.4)
        if n > 0 { captionBox(String(line.prefix(n)), ctx, center: CGPoint(x: Double(W) / 2, y: Double(H) / 2), size: 54, alpha: a) }
    },
    // Bag Endpoint, as the films open in the Shire: Gandclawd arrives, Bilbyte and Frodough by the round door.
    Shot(name: "bagend", start: 3.5, end: 8.0, into: .cut) { ctx, local, t in ringsBagEnd(ctx, local: local, t: t) },
    // One of Gandclawd's rockets (the app's fireworks trip) bursts into a dragon, and in its sparks the One Ring falls,
    // lands, its letters burn, and it opens out into the title.
    Shot(name: "ring", start: 8.0, end: 13.5, into: .middleEarth(RingsTrip(kind: .fireworks))) { ctx, local, t in ringsOpening(ctx, local: local, t: t) },
    // The Mines of Mori-ah: the bridge, the Ballrog, YOU SHALL NOT PASS!
    Shot(name: "bridge", start: 13.5, end: 22.0, into: .cut) { ctx, local, t in ringsBridge(ctx, local: local, t: t) },
    // The ridge at dusk: the Fellowship walks, Gladriel at the end.
    Shot(name: "fellowship", start: 22.0, end: 27.0, into: .middleEarth(RingsTrip(kind: .eye))) { ctx, local, t in
        ringsFellowship(ctx, local: local, t: t)
    },
    // Four panels, four signature moves.
    Shot(name: "moves", start: 27.0, end: 32.0, into: .cut) { ctx, local, t in ringsMoves(ctx, local: local, t: t) },
    Shot(name: "hook", start: 32.0, end: 36.0) { ctx, local, t in
        let zoom: Double = 1 + 0.03 * local
        ctx.saveGState()
        ctx.translateBy(x: Double(W) / 2, y: Double(H) / 2); ctx.scaleBy(x: zoom, y: zoom); ctx.translateBy(x: -Double(W) / 2, y: -Double(H) / 2)
        desktop(ctx, dim: 0)
        ctx.restoreGState()
        caption("Three AIs. Nine agents. One very confused hobbit.", ctx, local: local, start: 0.05, y: 860, size: 60)
        caption("Sound familiar?", ctx, local: local, start: 0.7, y: 120, size: 76, color: yellow)
    },
    Shot(name: "desktop", start: 36.0, end: 40.6) { ctx, local, t in
        brawl(ctx, .middleEarth, local: local, t: t, drop: true, chrome: false)
        badge("DESKTOP MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Now they're a pixel-art \(Universe.middleEarth.title) battle", ctx, local: local, start: 0.35, y: 900)
        caption("along the bottom of your screen. They fight while they work.", ctx, local: local, start: 0.6, y: 830, size: 40, color: yellow, weight: .bold)
    },
    Shot(name: "status", start: 40.6, end: 44.8) { ctx, local, t in
        let cast: [Cast] = [.hero(RingsHero.frodo), .villain(RingsVillain.gollum), .villain(RingsVillain.saruman), .hero(RingsHero.pippin)]
        statusOf(ctx, local: local, t: t, cast: cast, badgeText: Universe.middleEarth.title.uppercased(),
                 aside: "(\(cast[3].name): second breakfast, then a nap.)")
    },
    Shot(name: "agents", start: 44.8, end: 48.8) { ctx, local, t in ringsAgents(ctx, local: local, t: t) },
    Shot(name: "window", start: 48.8, end: 53.6) { ctx, local, t in
        windowShot(ctx, .middleEarth, local: local, t: t, rise: true, needsAt: 2.5, at: .prancingPony)
        badge("WINDOW MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Prefer a window? Step into \(Location.prancingPony.name).", ctx, local: local, start: 0.1, y: 955, size: 56)
        caption("A live card per session: what it's doing, your last prompt, every agent.", ctx, local: local, start: 0.4, y: 890, size: 32, color: yellow, weight: .bold)
    },
    Shot(name: "ais", start: 53.6, end: 58.0) { ctx, local, t in
        let cast: [Cast] = [.hero(RingsHero.gandalf), .hero(RingsHero.aragorn), .villain(RingsVillain.sauron), .villain(RingsVillain.saruman),
                            .villain(RingsVillain.witchKing), .villain(RingsVillain.shelob), .villain(RingsVillain.orc)]
        everyAI(ctx, local: local, t: t, cast: cast)
    },
    // The end card: Mount Doomscroll, the Great Eagle flies through, the title lands.
    Shot(name: "endcard", start: 58.0, end: 62.5) { ctx, local, t in ringsEndcard(ctx, local: local, t: t) },
]

let ringsBeats: [(key: Double, beat: Beat)] = [
    (2.4, ("MEANWHILE...", "Black screen. A yellow comic caption types itself out.",
           "“MEANWHILE, AT \(Location.bagEnd.name.uppercased())...”", "typewriter keys, a bell")),
    (5.7, ("BAG ENDPOINT", "\(Location.bagEnd.name), as the films open in the Shire: \(ringsName(RingsHero.gandalf)) walks up the lane; \(ringsName(RingsHero.frodo)) hops to greet him, \(ringsName(RingsHero.bilbo)) by the round door unrolls his contract.",
           "(none)", "birdsong, the Shire tune on a whistle, footsteps")),
    (8.0, ("FIREWORKS", "The app's fireworks trip: the Shire dims to night, one of \(ringsName(RingsHero.gandalf))'s rockets shoots up and bursts into a fiery dragon that sweeps the place away.",
           "(none)", "a rising whistle, the bang, crackling sparks")),
    (11.7, ("THE RING", "In the falling sparks, embers in the dark. The One Ring falls in slow motion, spinning, and lands with a chime; fire-letters wake along its band, which opens out into the burning title.",
           "CLAWD OF THE RINGS", "a low drone, a chime, a fire whoosh, the big hit, the tune begins")),
    (18.0, ("THE BRIDGE", "\(Location.moria.name), drums in the deep: \(ringsName(RingsVillain.balrog)) rises and the Fellowship runs. \(ringsName(RingsHero.gandalf)) slams his staff, the span falls, the whip drags him to the edge; he hangs, then drops.",
            "“YOU SHALL NOT PASS!”  ·  “Fly, you fools!”", "doom-drums, a roar, the staff's boom, stone cracking, a falling sweep")),
    (25.5, ("THE FELLOWSHIP", "Through the Eye: a ridge at dusk. Eight walkers march single file, dark against the sky, then lit, each name popping up as they pass; \(ringsName(RingsHero.galadriel)) appears at the far end and raises her light.",
            "the walkers' name tags", "a heroic swell, footsteps, the tune again")),
    (29.1, ("SIGNATURE MOVES", "Four comic panels: \(ringsName(RingsHero.frodo)) vanishes; \(ringsName(RingsHero.boromir)) holds forth; \(ringsName(RingsVillain.gollum)) argues with himself; \(ringsName(RingsHero.legolas)) surfs a shield.",
            "“Everyone gets a signature move.”  →  “Some are more precious than others.”  ·  “One does not simply push to main.”", "a shimmer, a hiss, a whoosh")),
    (33.5, ("THE HOOK", "Three busy terminals, slow push-in.", "“Three AIs. Nine agents. One very confused hobbit.”  →  “Sound familiar?”", "keyboard clicks")),
    (38.3, ("DESKTOP MODE", "\(ringsName(RingsHero.legolas)) against \(ringsName(RingsVillain.orc)), \(ringsName(RingsHero.gimli)) against \(ringsName(RingsVillain.uruk)).",
            "DESKTOP MODE  ·  “Now they're a pixel-art \(Universe.middleEarth.title) battle along the bottom of your screen. They fight while they work.”", "clangs, arrows")),
    (42.9, ("AT A GLANCE", "\(ringsName(RingsHero.frodo)) working, \(ringsName(RingsVillain.gollum)) thinking, \(ringsName(RingsVillain.saruman))'s jumping NEEDS YOU, \(ringsName(RingsHero.pippin)) sat down napping.",
            "“All fun and games, and you still see everything.”  ·  “(\(ringsName(RingsHero.pippin)): second breakfast, then a nap.)”", "blips, alert beeps")),
    (47.1, ("SUBAGENTS", "\(ringsName(RingsHero.gandalf)) stands guard; \(ringsName(RingsHero.pippin)), \(ringsName(RingsHero.gimli)), \(ringsName(RingsHero.legolas)) and \(ringsName(RingsHero.sam)) arrive with their jobs on their labels; the Great Eagle swoops down and carries \(ringsName(RingsHero.sam)) home.",
            "“Every subagent joins the Fellowship. Some fly home.”", "footsteps, an eagle's cry")),
    (51.7, ("WINDOW MODE", "The window in \(Location.prancingPony.name): \(ringsName(RingsHero.aragorn)) against \(ringsName(RingsVillain.witchKing)), live cards tick, then the Codex card flips to NEEDS YOU.",
            "WINDOW MODE  ·  “Prefer a window? Step into \(Location.prancingPony.name).”", "clashes, a ping")),
    (56.0, ("EVERY AI", "Seven sessions, one per AI outline: \(ringsName(RingsHero.gandalf)) (Claude Code, a head taller) and \(ringsName(RingsHero.aragorn)) against \(ringsName(RingsVillain.sauron)), \(ringsName(RingsVillain.saruman)), \(ringsName(RingsVillain.witchKing)) and \(ringsName(RingsVillain.shelob)); \(ringsName(RingsVillain.orc)) in pi's pink.",
            "BRING YOUR OWN AI*  ·  “One AI plays everyone. Run two and they pick sides.”  ·  *README for the full list", "magic crackle")),
    (61.0, ("END CARD", "\(Location.mountDoom.name) under the Eye: the Great Eagle flies across, the crew lines up, CLAWD OF THE RINGS lands, then the icon and the URL; \(ringsName(RingsVillain.shelob)) climbs her thread up out of sight.",
            "CLAWD OF THE RINGS  ·  “Have fun. Keep track.”  ·  “\(ringsTagline)”  ·  github.com/rodclemen/clawd-clash", "an eagle's cry, the closing chord")),
]

/// The Shire tune: an original jig-like line in D major, 3/4, on a tin-whistle triangle, with a light square
/// countermelody an octave down. `bars` of its 8.
private func shireTune(_ m: Mix, at t0: Double, bars: Int, vol: Double = 0.05) {
    let beat: Double = 0.2
    let tune: [[(Int, Double)]] = [[(74, 1), (78, 1), (76, 1)], [(74, 2), (69, 1)], [(71, 1), (74, 1), (76, 1)], [(78, 2), (76, 1)],
                                   [(79, 1), (78, 1), (76, 1)], [(74, 1), (71, 1), (69, 1)], [(71, 1), (76, 1), (73, 1)], [(74, 3)]]
    let counter: [Int] = [62, 66, 67, 66, 71, 62, 64, 62]
    for b in 0..<min(bars, tune.count) {
        var tt: Double = t0 + Double(b) * 3 * beat
        m.tone(tt, 3 * beat * 0.95, midi(counter[b]), wave: .square(0.25), vol: vol * 0.4, attack: 0.02, release: 0.06)
        for (n, d) in tune[b] {
            m.tone(tt, d * beat * 0.9, midi(n), wave: .triangle, vol: vol, attack: 0.01, release: 0.04, vibrato: 0.008)
            tt += d * beat
        }
    }
}

// Clawd of the Rings sound effects
extension Mix {
    func eagleCry(_ t: Double, vol: Double = 0.12) {               // the Great Eagle: a squeal down, then up
        tone(t, 0.35, 2400, to: 1600, wave: .square(0.25), vol: vol, attack: 0.02, release: 0.05, vibrato: 0.02)
        tone(t + 0.35, 0.25, 1600, to: 2000, wave: .square(0.25), vol: vol * 0.8, attack: 0.01, release: 0.12, vibrato: 0.02)
        noise(t, 0.6, vol: vol * 0.25, cutoff: 0.8, attack: 0.02, release: 0.2, highpass: true, seed: Int(t * 53))
    }
    func crack(_ t: Double, vol: Double = 0.2) {                   // stone giving way
        noise(t, 0.18, vol: vol, cutoff: 0.6, decay: 0.05, seed: Int(t * 71))
        noise(t + 0.06, 0.12, vol: vol * 0.7, cutoff: 0.9, decay: 0.03, highpass: true, seed: Int(t * 73))
        boom(t, vol: vol * 0.8)
    }
}

/// The Clawd of the Rings trailer's score and effects.
func ringsSound(_ m: Mix) {
    let mw = start("meanwhile")
    let keys = "MEANWHILE, AT \(Location.bagEnd.name.uppercased())...".count
    for i in 0..<keys { m.type(mw + 0.3 + Double(i) / Double(keys) * 1.6 + noise(i) * 0.02, vol: 0.18 + noise(i + 50) * 0.08) }
    m.ding(mw + 2.0)
    m.tone(mw + 0.2, 3.0, midi(33), wave: .sine, vol: 0.05, attack: 1.0, release: 0.8)
    // Bag Endpoint: birdsong, the Shire tune on a whistle, Gandclawd's footsteps up the lane
    let be = start("bagend")
    for i in 0..<9 {
        let c: Double = be + 0.2 + Double(i) * 0.37 + noise(i + 70) * 0.12
        m.tone(c, 0.07, 2500 + noise(i) * 700, to: 3300 + noise(i + 9) * 600, wave: .sine, vol: 0.02, release: 0.03)
        if i % 3 == 0 { m.tone(c + 0.1, 0.06, 3100, to: 2700, wave: .sine, vol: 0.015, release: 0.03) }
    }
    shireTune(m, at: be + 0.3, bars: 4, vol: 0.035)
    for k in 0..<7 { m.step(be + ringsGandalfWalk.from + Double(k) * 0.26, vol: 0.05) }
    // the ring: a low drone, the chime as it lands, a fire whoosh as the letters burn, the hit on the title
    let rg = start("ring")
    m.tone(rg, 5.6, midi(33), wave: .sine, vol: 0.12, attack: 0.8, release: 0.8)
    m.tone(rg, 5.6, midi(40), wave: .saw, vol: 0.018, attack: 1.5, release: 0.8)
    m.ding(rg + 2.0, vol: 0.14); m.ding(rg + 2.14, vol: 0.05)
    m.whoosh(rg + 2.5, 1.0, vol: 0.14)
    m.boom(rg + 3.4, vol: 0.5); m.noise(rg + 3.4, 1.4, vol: 0.1, cutoff: 0.9, decay: 0.5, highpass: true, seed: 21)
    for n in [50, 57, 62, 66] { m.tone(rg + 3.4, 1.1, midi(n), wave: .saw, vol: 0.04, release: 0.5, decay: 0.7) }
    shireTune(m, at: rg + 2.0, bars: 4, vol: 0.04)
    // the bridge: doom-drums, a low drone, the Ballrog's roar, the staff, the stone giving way, the fall
    let br = start("bridge")
    let slam: Double = br + 3.5 + (Cast.hero(RingsHero.gandalf).signatureLength ?? 3.0) * 0.29
    var d: Double = 0
    while br + d < slam { m.boom(br + d, vol: 0.3); m.snare(br + d + 0.3, vol: 0.05); d += 0.6 }
    m.tone(br, 8.6, midi(26), wave: .saw, vol: 0.03, attack: 1.0, release: 1.0)
    m.tone(br, 8.6, midi(33), wave: .saw, vol: 0.02, attack: 1.0, release: 1.0)
    m.roar(br + 2.0, 1.8, vol: 0.3)
    m.crackle(br + 2.0, 2.4, vol: 0.03)
    m.boom(slam, vol: 0.6); m.noise(slam, 1.2, vol: 0.18, cutoff: 1.0, decay: 0.35, seed: 31)
    m.crack(br + 4.5, vol: 0.25); m.crack(br + 4.75, vol: 0.15)
    m.tone(br + 4.6, 1.6, 400, to: 60, wave: .saw, vol: 0.06, release: 0.4)
    m.roar(br + 4.8, 1.4, vol: 0.16)
    m.whoosh(br + 5.0, 0.35, vol: 0.12)
    m.tone(br + 8.0, 0.5, 300, to: 90, wave: .sine, vol: 0.06, release: 0.2)
    // the Fellowship: a heroic swell of stacked fifths, footsteps, the tune again, Gladriel's light
    let fs = start("fellowship")
    let swell: [(Double, [Int])] = [(0.0, [50, 57]), (1.25, [55, 62]), (2.5, [57, 64]), (3.75, [50, 57, 62])]
    for (s, chord) in swell {
        for n in chord { m.tone(fs + s, 1.4, midi(n), wave: .saw, vol: 0.03, attack: 0.5, release: 0.4) }
        m.tone(fs + s, 1.4, midi(chord[0] - 12), wave: .sine, vol: 0.12, attack: 0.3, release: 0.4)
    }
    shireTune(m, at: fs + 0.2, bars: 8)
    var st: Double = 0
    while st < 5.0 { m.step(fs + st, vol: 0.05); st += 0.26 }
    m.shimmer(fs + 3.0, 1.8, vol: 0.025)
    // the moves: the panels slam in, then a shimmer, a hiss and a whoosh
    let mv = start("moves")
    m.boom(mv + 0.02, vol: 0.2); m.snare(mv + 0.02, vol: 0.1)
    m.shimmer(mv + 0.3, 1.5, vol: 0.035)
    m.noise(mv + 0.8, 0.9, vol: 0.06, cutoff: 0.9, attack: 0.05, release: 0.3, highpass: true, seed: 61)
    m.whoosh(mv + 1.5, 0.9, vol: 0.16)
    m.pop(mv + 0.1, step: 0); m.pop(mv + 2.75, step: 2)
    // the app shots: the shared groove, and each shot's effects
    groove(m, from: start("hook"), to: end("ais"), fadeIn: 0.5)
    let hook = start("hook")
    for i in 0..<26 { m.click(hook + 0.2 + Double(i) * 0.13 + noise(i) * 0.06) }
    let desk = start("desktop"), deskEnd = end("desktop") + 1.3
    for (i, dt) in [0.0, 0.12, 0.24, 0.32].enumerated() { m.step(desk + dt + 0.3, vol: 0.1 + Double(i % 2) * 0.03) }
    for t in clashTimes(desk + 0.45, deskEnd) { m.clang(t, vol: 0.08) }
    for t in shotTimes(desk + 0.45, deskEnd, offset: 0) { m.thwip(t, vol: 0.05); m.clang(t + boltArrival * blasterPeriod, vol: 0.05) }
    let sts = start("status")
    for i in 0..<4 { m.pop(sts + 0.1 + Double(i) * 0.22, step: i) }
    for k in 0..<5 { m.tone(sts + 1.2 + Double(k) * 0.62, 0.08, 1568, wave: .square(0.5), vol: 0.035, release: 0.03) }
    let ag = start("agents")
    for k in 0..<14 { m.step(ag + Double(k) * 0.125, vol: 0.06) }
    m.whoosh(ag + 1.9, 0.6, vol: 0.1)
    m.eagleCry(ag + 2.2)
    let wi = start("window")
    for t in clashTimes(wi, wi + 2.5) { m.clang(t, vol: 0.06) }
    for k in [0.9, 1.8] { m.click(wi + k, vol: 0.06) }
    m.ping(wi + 2.5)
    let ais = start("ais")
    for i in 0..<6 { m.pop(ais + 0.15 + Double(i) * 0.1, step: i % 4) }
    m.crackle(ais + 0.4, end("ais") + 1.3 - ais - 0.4, vol: 0.045)
    for s in shots { transitionSound(m, s) }
    // the end card: the Eagle's cry as it flies over, and a closing cadence home to D
    let ec = start("endcard")
    m.eagleCry(ec + 0.4, vol: 0.1)
    let cadence: [(Double, Double, [Int], Int)] = [(0.0, 0.7, [55, 59, 62, 67], 83), (0.7, 0.7, [57, 61, 64, 69], 85), (1.4, 2.8, [50, 54, 57, 62], 86)]
    for (s, dur, chord, lead) in cadence {
        let rel: Double = dur > 1 ? 1.0 : 0.1
        for n in chord { m.tone(ec + s, dur, midi(n), wave: .saw, vol: 0.045, attack: 0.02, release: rel) }
        m.tone(ec + s, dur, midi(lead), wave: .square(0.5), vol: 0.06, release: rel, vibrato: 0.006)
        m.tone(ec + s, dur, midi(chord[0] - 12), wave: .sine, vol: 0.2, release: rel)
    }
    m.boom(ec + 0.35, vol: 0.45)
    m.boom(ec + 1.4, vol: 0.3)
    m.crackle(ec + 0.5, duration - ec - 0.5, vol: 0.02)
}
