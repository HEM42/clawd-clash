import AppKit
import CoreText

// The Stevie Clawdberg trailer: `REEL=clawdberg build/renderpromo video promo` → promo/stevie-clawdberg-promo.mp4.
// Drawn with RenderPromo's kit (Tools/RenderPromo/Kit: `Shot`, `brawl`, `windowShot`, `everyAI`, `Mix`…) and compiled
// only into that tool.

/// The Stevie Clawdberg trailer, as the tool asks for it.
struct ClawdbergReel: PromoReel {
    let name = "clawdberg", base = "stevie-clawdberg-promo", small = "Stevie-Clawdberg"
    let title = "STEVIE CLAWDBERG"
    let geminiTask = "gemini ▸ get it up to 88 mph"
    var shots: [Shot] { clawdbergShots }
    var beats: [(key: Double, beat: Beat)] { clawdbergBeats }
    var universe: Universe { .clawdberg }
    var brawl: BrawlCast {
        BrawlCast(claude: .hero(ClawdbergHero.indianaBones), other: .villain(ClawdbergVillain.reneBellock),
                  agent: .hero(ClawdbergHero.martyMcFry), otherAgent: .villain(ClawdbergVillain.biffTannin),
                  line: "Or roll Stevie Clawdberg.",
                  sub: "Whips, sharks, gremlins and a DeLorean: 117 characters in 23 places.")
    }
    var window: WindowCast {
        WindowCast(place: .hillValley1955, claude: .hero(ClawdbergHero.indianaBones), other: .villain(ClawdbergVillain.reneBellock),
                   agentA: .hero(ClawdbergHero.martyMcFry), agentB: .hero(ClawdbergHero.docBrawn), extra: .villain(ClawdbergVillain.strype),
                   prompt: "You: “get the DeLorean up to 88 mph”", otherPrompt: "You: “put it back in the museum”")
    }
    func sound(_ m: Mix) { clawdbergSound(m) }
}

// MARK: The Stevie Clawdberg trailer

/// The title: STEVIE over CLAWDBERG, warm gold lettering with a soft blue glow behind it, the way the big summer films
/// put their names up, with a small "universe" tucked under the right end of CLAWDBERG. `alpha` fades it.
func clawdbergTitle(_ ctx: CGContext, center: CGPoint, scale s: Double, alpha: Double = 1) {
    guard s > 0.01, alpha > 0.01 else { return }
    let font = NSFont(name: "AvenirNextCondensed-Heavy", size: 100) ?? .systemFont(ofSize: 100, weight: .black)
    let gold = NSColor(srgbRed: 1.0, green: 0.86, blue: 0.48, alpha: CGFloat(alpha))
    ctx.saveGState()
    ctx.translateBy(x: center.x, y: center.y); ctx.scaleBy(x: s, y: s)
    let ns = NSGraphicsContext(cgContext: ctx, flipped: false)
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = ns
    var right = 0.0
    for (word, size, y, kern) in [("STEVIE", 74.0, 70.0, 26.0), ("CLAWDBERG", 200.0, -120.0, 10.0)] {
        let f = NSFont(descriptor: font.fontDescriptor, size: CGFloat(size)) ?? font
        let glow = NSShadow(); glow.shadowColor = NSColor(srgbRed: 0.35, green: 0.62, blue: 1.0, alpha: 0.9 * CGFloat(alpha))
        glow.shadowBlurRadius = 36
        let a = NSAttributedString(string: word, attributes: [.font: f, .kern: kern, .foregroundColor: gold, .shadow: glow])
        a.draw(at: NSPoint(x: -a.size().width / 2, y: y))
        right = a.size().width / 2 - kern     // the last letter's right edge (the kern trails after it)
    }
    let small = NSFont(name: "AvenirNext-DemiBold", size: 40) ?? .systemFont(ofSize: 40, weight: .semibold)
    let glow = NSShadow(); glow.shadowColor = NSColor(srgbRed: 0.35, green: 0.62, blue: 1.0, alpha: 0.7 * CGFloat(alpha))
    glow.shadowBlurRadius = 14
    let u = NSAttributedString(string: "universe", attributes: [.font: small, .kern: 6, .foregroundColor: gold, .shadow: glow])
    u.draw(at: NSPoint(x: right - (u.size().width - 6), y: -106))
    NSGraphicsContext.restoreGraphicsState()
    ctx.restoreGState()
}

/// `src` as a solid silhouette in `col`: every pixel it draws, filled in one colour.
func clawdbergSilhouette(_ src: PixelCanvas, _ col: Px) -> PixelCanvas {
    let out = PixelCanvas(src.w, src.h)
    for y in 0..<src.h {
        for x in 0..<src.w where src.buf[(y * src.w + x) * 4 + 3] > 40 { out.px(x, y, col) }
    }
    return out
}

/// A line `w` pixels thick from (x0, y0) to (x1, y1).
private func inkLine(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, w: Int = 1, _ col: Px) {
    let dx = x1 - x0, dy = y1 - y0, n = Int(max(abs(dx), abs(dy)) * 2) + 1
    for i in 0...n {
        let f = Double(i) / Double(n)
        c.rect(Int((x0 + dx * f).rounded()) - (w - 1) / 2, Int((y0 + dy * f).rounded()) - (w - 1) / 2, w, w, col)
    }
}

/// The bike's size, in pixels.
let clawdbergBikeW = 62, clawdbergBikeH = 41

/// The bike across the moon, in silhouette, its top-left at (x, y), facing right: two spoked wheels turning, the BMX
/// frame, the boy hunched over the bars in his hood, and the little alien wrapped in his blanket in the basket up
/// front, his head peeping out over the rim.
func clawdbergBike(_ c: PixelCanvas, x: Int, y: Int, t: Double, ink: Px) {
    let ox = Double(x), oy = Double(y)
    func ln(_ a: Double, _ b: Double, _ c2: Double, _ d: Double, _ w: Int = 1) { inkLine(c, ox + a, oy + b, ox + c2, oy + d, w: w, ink) }
    // The wheels: a tyre two pixels thick, six turning spokes and the hub.
    for wx in [11.0, 50.0] {
        let wy = 31.0, r = 9.0
        for s in 0..<72 {
            let a = Double(s) / 72 * 2 * .pi
            for rr in [r, r - 1] { c.px(Int((ox + wx + cos(a) * rr).rounded()), Int((oy + wy + sin(a) * rr).rounded()), ink) }
        }
        for s in 0..<3 {
            let a = t * 9 + Double(s) / 3 * .pi
            ln(wx - cos(a) * (r - 1), wy - sin(a) * (r - 1), wx + cos(a) * (r - 1), wy + sin(a) * (r - 1))
        }
        c.rect(x + Int(wx) - 1, y + Int(wy) - 1, 3, 3, ink)
    }
    // The frame: chain stays, seat tube, down tube, top tube, the fork, the stem and the bars.
    ln(11, 31, 26, 32, 2); ln(26, 32, 22, 20, 2); ln(22, 20, 11, 31, 2)
    ln(26, 32, 43, 19, 2); ln(22, 20, 43, 18, 2); ln(43, 17, 50, 31, 2)
    ln(43, 18, 42, 12, 2); ln(38, 12, 46, 11, 2)
    c.rect(x + 18, y + 18, 8, 2, ink)                                   // the saddle
    c.ellipse(x + 26, y + 32, 2, 2, ink)                                // the chainring
    // The basket on the bars, wider at the top, and the alien in it: his blanket hood and the long neck.
    for r in 0..<9 { c.rect(x + 46 - r / 3, y + 10 + r, 13 - r / 2, 1, ink) }
    c.ellipse(x + 52, y + 6, 4, 4, ink)                                 // the hooded head
    c.rect(x + 50, y + 8, 5, 3, ink)
    c.px(x + 56, y + 6, ink); c.px(x + 57, y + 7, ink)                  // the blanket's fold over his brow
    // The boy: hunched forward in his hood, arms out to the bars, one knee up on the pedal, the other leg down.
    inkLine(c, ox + 22, oy + 17, ox + 34, oy + 7, w: 5, ink)            // the back, bent over
    c.ellipse(x + 37, y + 5, 4, 4, ink); c.rect(x + 33, y + 2, 4, 4, ink)   // the hood
    ln(34, 8, 42, 12, 2); ln(33, 10, 40, 12, 2)                         // the arms
    ln(22, 18, 31, 22, 3); ln(31, 22, 29, 30, 2)                        // the near leg, knee up
    ln(22, 18, 25, 25, 3); ln(25, 25, 23, 33, 2)                        // the far leg
}

/// The opening, after the film's own: night over the hills, the full moon rising huge over the treeline, and the bike
/// with the little alien in its basket sailing across its face in silhouette. Then the title swells up gold out of
/// the moonlight, and the camera plunges into the white.
func clawdbergIntro(_ ctx: CGContext, local l: Double, t: Double) {
    let c = PixelCanvas(fxW, fxH)
    c.gradient(0, fxH, C(0x060A1E), C(0x1C2A52), bands: 9)
    c.stars(0, fxH * 2 / 3, density: 26, seed: 41)
    // The moon rises and grows, then the bike crosses it.
    let rise = easeOut(l / 3.0)
    let r: Double = 44 + 6 * l
    let cx: Double = Double(fxW) * 0.56
    let cy: Double = Double(fxH) + 40 - (Double(fxH) * 0.5 + 40) * rise
    let ri = Int(r)
    c.circle(Int(cx), Int(cy), ri + 6, C(0xF6EFC4, 0.10))
    c.circle(Int(cx), Int(cy), ri + 3, C(0xF6EFC4, 0.18))
    c.circle(Int(cx), Int(cy), ri, C(0xF6EFC4))
    for (dx, dy, cr) in [(-0.35, -0.2, 0.22), (0.2, 0.25, 0.16), (0.3, -0.35, 0.12), (-0.1, 0.4, 0.1)] {
        let mx: Double = cx + dx * r, my: Double = cy + dy * r
        c.circle(Int(mx), Int(my), Int(cr * r), C(0xE2D79E))
    }
    // The treeline in front.
    for x in 0..<fxW {
        let h: Double = 14 + 6 * sin(Double(x) * 0.09) + 5 * noise(x / 3)
        c.rect(x, fxH - Int(h), 1, Int(h), C(0x05070F))
    }
    // The bike, from the left across the moon, a black cut-out against it, drawn a pixel to a pixel like the moon.
    let ride = (l - 2.4) / 3.2
    if ride > 0 && ride < 1.2 {
        let bx = -Double(clawdbergBikeW) + (cx + Double(clawdbergBikeW) / 2 + 30) * ride
        let by = cy - 24 - 14 * ride + sin(l * 3) * 1.2
        clawdbergBike(c, x: Int(bx.rounded()), y: Int(by.rounded()), t: t, ink: C(0x04050A))
    }
    blit(c, ctx)
    // The title out of the moonlight, then into the white.
    if l > 5.4 {
        let k = easeOut((l - 5.4) / 1.2)
        let out = clamp((l - 8.5) / 0.4)
        ctx.setFillColor(CGColor(red: 0.02, green: 0.03, blue: 0.08, alpha: 0.62 * k)); ctx.fill(fullRect)   // the night closes in
        clawdbergTitle(ctx, center: CGPoint(x: Double(W) / 2, y: Double(H) * 0.5), scale: 0.85 + 0.15 * k + 0.6 * out,
                       alpha: k * (1 - out))
    }
    let white = clamp((l - 8.3) / 0.6)
    if white > 0 { ctx.setFillColor(CGColor(gray: 1, alpha: white)); ctx.fill(fullRect) }
}

/// The set piece's timings (shot-local seconds): Marty walks up, the DeLorean comes in at 88 mph and pulls up beside
/// him, the gull-wing door lifts, he hops in, it shuts, the car tears off and is gone in a flash.
private let hvGround = 158.0, martyX = 150.0, docX = 52.0, carIn = 2.2, carStop = 3.0, doorUp = 3.1, hopIn = 3.5, doorDown = 4.0,
    carGo = 4.4, vanishAt = 5.6, biffIn = 7.2
/// The DeLorean is drawn at twice the cast's pixel size, so Marty fits in it.
private let carScale = 2.0
/// Where the DeLorean's canvas starts (fx columns): parked with its door at Marty, and where it vanishes.
private let carParked = martyX - 33 * carScale, carVanish = carParked + 90
/// The fire trails: from where the car hit 88 to where it vanished (its front wheel); the plate lands past them.
private let trailFrom = carParked + 40 * carScale, trailTo = carVanish + 50 * carScale

/// The DeLorean's left edge (fx columns) and how fast it's going (0…1) at shot time `l`; nil when it's not there.
private func deloreanAt(_ l: Double) -> (x: Double, speed: Double)? {
    switch l {
    case ..<carIn: return nil
    case ..<carStop:
        let f = (l - carIn) / (carStop - carIn)
        return (lerp(-Double(Ride.width) * carScale - 10, carParked, easeOut(f)), pow(1 - f, 2))
    case ..<carGo: return (carParked, 0)
    case ..<vanishAt:
        let f = (l - carGo) / (vanishAt - carGo)
        return (carParked + (carVanish - carParked) * f * f, f)
    default: return nil
    }
}

/// The DeLorean on the stage at `carScale`, its wheels on the floor, `door` 0…1 lifting the gull-wing, `lit` crackling.
func clawdbergDelorean(_ ctx: CGContext, left: Double, door: Double, lit: Bool) {
    let fc = PixelCanvas(Ride.width, Ride.height)
    clawdbergDrawDelorean(fc, ramp: door, lit: lit)
    fc.addOutline(C(0xFFFFFF, 0.92))
    guard let img = fc.makeImage() else { return }
    ctx.saveGState(); ctx.interpolationQuality = .none
    ctx.draw(img, in: CGRect(x: left * S, y: stageH - groundY * S, width: Double(Ride.width) * S * carScale,
                             height: Double(Ride.height) * S * carScale))
    ctx.restoreGState()
}

/// Speed lines streaming off the car, and once it's gone the two fire trails burning on the road where it hit 88,
/// the OUTATIME plate spinning flat on the ground at their end.
func clawdbergRoadFX(_ l: Double, t: Double) -> PixelCanvas {
    let c = PixelCanvas(fxW, fxH)
    let g = Int(hvGround)
    if let car = deloreanAt(l), car.speed > 0.15 {
        for i in 0..<7 {
            let row = g - 6 - Int(noise(i * 7 + Int(t * 20)) * 36)
            let len = Int(14 + 60 * car.speed * noise(i * 3 + Int(t * 24)))
            c.rect(Int(car.x) + 2 - len, row, len, 1, C(0xE8F4FF, 0.35 + 0.4 * car.speed))
        }
    }
    if l > vanishAt {
        let burn = 1 - clamp((l - vanishAt - 1.8) / 2.0) * 0.85
        let run = clamp((l - vanishAt) / 0.12)                          // laid back from the vanishing point in a blink
        let a = trailTo - (trailTo - trailFrom) * run
        for (i, row) in [g - 1, g - 2, g - 5, g - 6].enumerated() {
            for x in Int(a)..<Int(trailTo) {
                let flick = noise(x * 5 + i * 41 + Int(t * 18)) * 0.35
                let col = noise(x * 3 + i + Int(t * 12)) > 0.6 ? C(0xFFE45A) : C(0xFF6A1A)
                c.px(x, row, col.alpha(burn * (0.7 + flick)))
                let tall = i % 2 == 0 ? 0 : Int(noise(x * 11 + i * 7 + Int(t * 14)) * 5 * burn)
                for h in 0..<tall { c.px(x, row - 1 - h, (h == 0 ? C(0xFF9A2A) : C(0xFFD25A)).alpha(burn * (0.7 - Double(h) * 0.15))) }
            }
        }
        // The plate, spinning flat on the road and slowing.
        let spin = abs(cos((l - vanishAt) * 7 * max(0.15, 1 - (l - vanishAt) / 3)))
        let pw = max(1, Int(11 * spin)), px0 = Int(trailTo) + 8 - pw / 2
        c.rect(px0, g - 4, pw, 4, C(0xF2F2EA)); c.rect(px0, g - 4, pw, 1, C(0x2A4A9A))
    }
    return c
}

/// Hill Valley, 1955, in the storm. Marty walks up to the courthouse, where Doc is waiting; the DeLorean comes in at
/// 88 mph and pulls up beside him. The gull-wing door lifts, Marty hops in, it shuts, and the car tears off, sparks
/// over it, and is gone in a white flash, two lines of fire burning on the road where it went and the OUTATIME plate
/// spinning at their end. Doc: “Great Scott!” Then Biff walks in.
func clawdbergHillValley(_ ctx: CGContext, local l: Double, t: Double) {
    blit(place(.hillValley1955, floorRows: 22, t: t), ctx)
    onStage(ctx, fullRect, scale: 6, ground: hvGround) {
        blit(clawdbergRoadFX(l, t: t), ctx)
        let walk = easeOut((l - 0.3) / 1.7)
        var marty = Actor(cast: .hero(ClawdbergHero.martyMcFry), x: lerp(-24, martyX, walk), facing: 1, mode: .idle)
        marty.walking = l > 0.3 && l < 1.95
        if l > carStop { marty.facing = -1 }                                    // he turns to the car…
        if l > hopIn {                                                          // …and hops in
            let h = clamp((l - hopIn) / 0.45)
            marty.lift = 8 * sin(h * .pi * 0.8)
            marty.x = martyX - 2 * h
            marty.alpha = 1 - clamp((h - 0.45) / 0.5)
        }
        var doc = Actor(cast: .hero(ClawdbergHero.docBrawn), x: docX, facing: 1, mode: .idle)
        if l > vanishAt && l < vanishAt + 0.5 { doc.lift = 4 * sin((l - vanishAt) / 0.5 * .pi) }   // he jumps
        draw(doc, ctx, t: t)
        if let car = deloreanAt(l) {
            let door = l < doorUp ? 0 : l < hopIn ? easeOut((l - doorUp) / 0.35) : l < doorDown ? 1 : 1 - clamp((l - doorDown) / 0.3)
            let lit = car.speed > 0.35
            if l < hopIn + 0.2 { clawdbergDelorean(ctx, left: car.x, door: door, lit: lit) }   // Marty in front of it…
            if marty.alpha > 0.02 { draw(marty, ctx, t: t) }
            if l >= hopIn + 0.2 { clawdbergDelorean(ctx, left: car.x, door: door, lit: lit) }  // …then inside it
        } else if l < carIn {
            draw(marty, ctx, t: t)
        }
        if l > biffIn {
            let k = easeOut((l - biffIn) / 1.4)
            var biff = Actor(cast: .villain(ClawdbergVillain.biffTannin), x: lerp(fxW.d + 30, 296, k), facing: -1, mode: .idle)
            biff.walking = k < 0.98
            draw(biff, ctx, t: t)
        }
    }
    // The flash as it goes: a burst of white from where it vanished, washing over the screen.
    if l > vanishAt - 0.05 && l < vanishAt + 0.6 {
        let f = l < vanishAt ? (l - vanishAt + 0.05) / 0.05 : 1 - (l - vanishAt) / 0.6
        let cx = (carVanish + 33 * carScale) * 6, cy = Double(H) - (hvGround - 12) * 6
        for (r, a) in [(900.0, 0.35), (420.0, 0.6), (160.0, 0.9)] {
            ctx.setFillColor(CGColor(gray: 1, alpha: a * f))
            ctx.fillEllipse(in: CGRect(x: cx - r, y: cy - r * 0.7, width: r * 2, height: r * 1.4))
        }
        ctx.setFillColor(CGColor(red: 0.85, green: 0.92, blue: 1, alpha: 0.5 * f)); ctx.fill(fullRect)
    }
    // OUTATIME types itself out over the spinning plate, and fades as Biff comes in.
    let plateText = 1 - clamp((l - biffIn - 0.2) / 0.5)
    if l > vanishAt + 0.7 && plateText > 0 {
        let font = NSFont.monospacedSystemFont(ofSize: 52, weight: .heavy), full = "OUTATIME"
        let n = min(full.count, Int((l - vanishAt - 0.7) / 0.08) + 1)
        let a = NSAttributedString(string: String(full.prefix(n)), attributes: [.font: font,
                                                                                 .foregroundColor: NSColor(srgbRed: 1, green: 0.85, blue: 0.4, alpha: plateText)])
        let w = NSAttributedString(string: full, attributes: [.font: font]).size().width
        a.draw(at: NSPoint(x: min((trailTo + 8) * 6 - w / 2, Double(W) - w - 40), y: Double(H) - (hvGround - 26) * 6))
    }
    caption("“Great Scott!”", ctx, local: l, start: vanishAt + 0.5, y: 860, size: 60)
    caption("“Hello? McFly?”", ctx, local: l, start: biffIn + 1.0, y: 780, size: 52, color: yellow)
    // in from the white of the titles
    let white = 1 - clamp(l / 0.6)
    if white > 0 { ctx.setFillColor(CGColor(gray: 1, alpha: white)); ctx.fill(fullRect) }
}

let clawdbergShots: [Shot] = [
    // The moon, the bike, the title.
    Shot(name: "intro", start: 0, end: 9.0, into: .cut) { ctx, local, t in clawdbergIntro(ctx, local: local, t: t) },
    // Hill Valley: 88 mph, OUTATIME, Biff.
    Shot(name: "hillvalley", start: 9.0, end: 18.5, into: .cut) { ctx, local, t in clawdbergHillValley(ctx, local: local, t: t) },
    Shot(name: "hook", start: 18.5, end: 22.5) { ctx, local, t in
        let zoom = 1 + 0.03 * local
        ctx.saveGState()
        ctx.translateBy(x: Double(W) / 2, y: Double(H) / 2); ctx.scaleBy(x: zoom, y: zoom); ctx.translateBy(x: -Double(W) / 2, y: -Double(H) / 2)
        desktop(ctx, dim: 0)
        ctx.restoreGState()
        caption("Three AIs. Nine agents. One very confused human.", ctx, local: local, start: 0.05, y: 860, size: 60)
        caption("Sound familiar?", ctx, local: local, start: 0.7, y: 120, size: 76, color: yellow)
    },
    Shot(name: "desktop", start: 22.5, end: 27.1) { ctx, local, t in
        brawl(ctx, .clawdberg, local: local, t: t, drop: true, chrome: false)
        badge("DESKTOP MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Now they're a pixel-art blockbuster", ctx, local: local, start: 0.35, y: 900)
        caption("along the bottom of your screen. They fight while they work.", ctx, local: local, start: 0.6, y: 830, size: 40, color: yellow, weight: .bold)
    },
    Shot(name: "status", start: 27.1, end: 31.3) { ctx, local, t in
        let cast: [Cast] = [.hero(ClawdbergHero.indianaBones), .villain(ClawdbergVillain.tWrecks), .villain(ClawdbergVillain.strype),
                            .hero(ClawdbergHero.chunk)]
        statusOf(ctx, local: local, t: t, cast: cast, badgeText: "STEVIE CLAWDBERG", aside: "(\(cast[3].name), napping. Goonies never say die. They do nap.)")
    },
    Shot(name: "agents", start: 31.3, end: 35.3) { ctx, local, t in
        agentsOf(ctx, local: local, t: t, guardCast: .hero(ClawdbergHero.mikeyWaltz),
                 crew: [.hero(ClawdbergHero.data), .hero(ClawdbergHero.mouth), .hero(ClawdbergHero.stefSteinclawd), .hero(ClawdbergHero.einsteinDog)],
                 line: "Every subagent gets to be a Goonie.", badgeText: "STEVIE CLAWDBERG")
    },
    Shot(name: "window", start: 35.3, end: 40.1) { ctx, local, t in
        windowShot(ctx, .clawdberg, local: local, t: t, rise: true, needsAt: 2.5, at: .hillValley1955)
        badge("WINDOW MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Prefer a window? Roads? Where we're going…", ctx, local: local, start: 0.1, y: 955, size: 56)
        caption("A live card per session: what it's doing, your last prompt, every agent.", ctx, local: local, start: 0.4, y: 890, size: 32, color: yellow, weight: .bold)
    },
    Shot(name: "ais", start: 40.1, end: 44.5) { ctx, local, t in
        everyAI(ctx, local: local, t: t, cast: [.hero(ClawdbergHero.indianaBones), .hero(ClawdbergHero.martyMcFry),
                                                .villain(ClawdbergVillain.reneBellock), .villain(ClawdbergVillain.tWrecks),
                                                .villain(ClawdbergVillain.strype), .villain(ClawdbergVillain.captainClawk),
                                                .villain(ClawdbergVillain.bruise)])
    },
    // The end card: Hill Valley, the crew lines up, the title lands.
    Shot(name: "endcard", start: 44.5, end: 48.7) { ctx, local, t in
        blit(place(.hillValley1955, floorRows: 34, t: t), ctx)
        ctx.setFillColor(CGColor(gray: 0, alpha: 0.45)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let crew: [(Cast, FightRole, AI)] = [(.hero(ClawdbergHero.eClawd), .cheer, .desktop), (.hero(ClawdbergHero.indianaBones), .none, .claude),
                                             (.villain(ClawdbergVillain.reneBellock), .none, .codex), (.villain(ClawdbergVillain.biffTannin), .none, .copilot),
                                             (.villain(ClawdbergVillain.strype), .cheer, .qwen), (.villain(ClawdbergVillain.captainClawk), .none, .gemini)]
        let (ra, rb) = fightRoles(crew[1].0.weapon, crew[2].0.weapon)
        var placed: [Actor] = []
        for (i, (who, role, ai)) in crew.enumerated() {
            let r: FightRole = i == 1 ? ra : (i == 2 ? rb : role)
            var a = Actor(cast: who, x: [28.0, 84, 156, 206, 252, 296][i], facing: i < 2 ? 1 : -1, role: r, ai: ai)
            a.lift = 8
            a.alpha = clamp((local - 0.15 - Double(i) * 0.05) / 0.2)
            draw(a, ctx, t: t)
            placed.append(a)
        }
        if local > 0.5 { drawFX([(placed[1], placed[2])], ctx, t: t) }
        if local > 0.35 {
            clawdbergTitle(ctx, center: CGPoint(x: Double(W) / 2, y: 740), scale: backOut((local - 0.35) / 0.4) * 0.55)
        }
        caption("Have fun. Keep track.", ctx, local: local, start: 0.6, y: 520, size: 56)
        caption("One of many universes in Clawd Clash · free for macOS", ctx, local: local, start: 0.8, y: 462, size: 34,
                color: NSColor(white: 0.85, alpha: 1), weight: .bold)
        let ff = easeOut((local - 0.9) / 0.3)
        if ff > 0, let icon = appIcon {
            ctx.setFillColor(CGColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 0.8 * ff)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: 170))
            ctx.saveGState(); ctx.setAlpha(CGFloat(ff)); ctx.interpolationQuality = .high
            ctx.draw(icon, in: CGRect(x: 580, y: 20, width: 130, height: 130))
            ctx.restoreGState()
            text("github.com/rodclemen/clawd-clash", ctx, x: 740, y: 60, size: 44, weight: .bold, alpha: ff)
        }
    },
]

let clawdbergBeats: [(key: Double, beat: Beat)] = [
    (2.0, ("THE MOON", "Night over the hills. A huge full moon rises over the treeline, growing as it climbs.", "no text", "a hushed string pad, a high shimmer; our own notes, in the manner of the big adventure scores")),
    (4.6, ("THE BIKE", "The bike, the little alien in its basket, sails across the face of the moon in silhouette.", "no text", "the strings swell, a rising harp-like arpeggio")),
    (7.0, ("THE TITLE", "STEVIE CLAWDBERG rises gold out of the moonlight with a blue glow behind it, then the camera plunges into the white.", "STEVIE CLAWDBERG", "a big brass-like chord, cymbal swell")),
    (10.5, ("HILL VALLEY", "The courthouse square in the storm, the clock stopped at 10:04. Marty walks up; Doc waits on the left.", "no text", "rain, thunder")),
    (12.0, ("THE DELOREAN", "The DeLorean comes in at 88 mph, speed lines streaming, and pulls up beside Marty; the gull-wing lifts, he hops in, it shuts.", "no text", "a whoosh, brakes, the door's hiss, a clunk")),
    (14.2, ("88 MPH", "It tears off crackling blue and is gone in a white flash; two lines of fire burn on the road and the OUTATIME plate spins at their end.", "“Great Scott!”  ·  OUTATIME (typed)", "a rising whine, a boom, the fire")),
    (17.5, ("McFLY?", "Biff walks in from the right, looking for someone who isn't there.", "“Hello? McFly?”", "footsteps")),
    (20.0, ("THE HOOK", "Three busy terminals, slow push-in.", "“Three AIs. Nine agents. One very confused human.”  →  “Sound familiar?”", "keyboard clicks")),
    (24.8, ("DESKTOP MODE", "Indiana Bones against René Bellock; Marty trades shots with Biff.", "DESKTOP MODE  ·  “Now they're a pixel-art blockbuster along the bottom of your screen. They fight while they work.”", "whip cracks, shots")),
    (29.4, ("AT A GLANCE", "Indy working, T. Wrecks thinking, Strype's jumping NEEDS YOU, Chunk sat down napping.", "“(Chunk, napping. Goonies never say die. They do nap.)”", "blips, alert beeps")),
    (33.5, ("SUBAGENTS", "Mikey stands guard; Data, Mouth, Stef and Einstein the Dog arrive with their jobs on their labels.", "“Every subagent gets to be a Goonie.”", "footsteps")),
    (38.1, ("WINDOW MODE", "The window in Hill Valley: live cards tick, then a Codex card flips to NEEDS YOU.", "WINDOW MODE  ·  “Prefer a window? Roads? Where we're going…”", "a ping")),
    (42.5, ("EVERY AI", "Seven sessions, one per AI outline; Claude's Indy a head taller.", "BRING YOUR OWN AI*  ·  “One AI plays everyone. Run two and they pick sides.”  ·  *README for the full list", "shots")),
    (47.5, ("END CARD", "Hill Valley: the crew lines up, STEVIE CLAWDBERG lands in gold.", "STEVIE CLAWDBERG  ·  “Have fun. Keep track.”  ·  “One of many universes in Clawd Clash · free for macOS”  ·  github.com/rodclemen/clawd-clash", "the big chord")),
]

/// The opening's score, in the manner of the big adventure films (their sound, not their melodies): a soft string
/// pad, a shimmer, a rising arpeggio as the bike crosses the moon, and a broad major chord for the title. Our own notes.
func clawdbergTune(_ m: Mix, from t0: Double) {
    let chords: [[Int]] = [[60, 64, 67], [57, 60, 64], [53, 57, 60], [55, 59, 62]]   // C Am F G
    for (b, ch) in chords.enumerated() {
        let s = t0 + Double(b) * 1.4
        for n in ch { m.tone(s, 1.6, midi(n), wave: .saw, vol: 0.018, attack: 0.5, release: 0.6) }
        m.tone(s, 1.6, midi(ch[0] - 24), wave: .sine, vol: 0.12, attack: 0.3, release: 0.6)
    }
    // the shimmer, then the arpeggio climbing as the bike flies
    for i in 0..<16 { m.tone(t0 + 0.2 + Double(i) * 0.3, 0.25, midi(84 + (i % 3) * 3), wave: .sine, vol: 0.012, attack: 0.02, release: 0.2) }
    let up = [60, 64, 67, 72, 76, 79, 84, 88]
    for (i, n) in up.enumerated() { m.tone(t0 + 2.6 + Double(i) * 0.22, 0.5, midi(n), wave: .triangle, vol: 0.05, attack: 0.01, release: 0.3, decay: 0.3) }
    // the title chord
    let title = t0 + 5.4
    for n in [48, 55, 60, 64, 67, 72] { m.tone(title, 3.2, midi(n), wave: .saw, vol: 0.028, attack: 0.25, release: 1.2) }
    m.tone(title, 3.2, midi(36), wave: .sine, vol: 0.22, attack: 0.2, release: 1.2)
    m.noise(title - 0.6, 1.0, vol: 0.06, cutoff: 0.9, cutoffTo: 0.2, attack: 0.8, release: 0.2, highpass: true, seed: 51)   // the cymbal swell
}

/// The Stevie Clawdberg trailer's score and effects.
func clawdbergSound(_ m: Mix) {
    let i0 = start("intro")
    clawdbergTune(m, from: i0 + 0.1)
    m.boom(i0 + 5.4, vol: 0.3)
    m.whoosh(i0 + 8.6, 0.8, vol: 0.12)
    let hv = start("hillvalley")
    m.rain(hv, 9.5, vol: 0.05)
    for k in [0.6, 7.6] { m.boom(hv + k, vol: 0.2) }                                                   // thunder
    for k in 0..<8 { m.step(hv + 0.3 + Double(k) * 0.2, vol: 0.05) }
    m.whoosh(hv + carIn + 0.3, 0.7, vol: 0.18)                                                         // in at 88…
    m.tone(hv + carIn, 0.8, 900, to: 300, wave: .saw, vol: 0.025, attack: 0.05, release: 0.2)
    m.noise(hv + carStop - 0.35, 0.4, vol: 0.05, cutoff: 0.8, cutoffTo: 0.4, release: 0.1, highpass: true, seed: 61)   // …brakes
    m.noise(hv + doorUp, 0.35, vol: 0.04, cutoff: 0.5, release: 0.1, highpass: true, seed: 62)          // the door's hiss
    m.click(hv + doorDown + 0.3, vol: 0.12)                                                            // shut
    m.tone(hv + carGo, vanishAt - carGo, 120, to: 1600, wave: .saw, vol: 0.03, attack: 0.2, release: 0.05)   // the whine
    m.crackle(hv + carGo + 0.5, vanishAt - carGo - 0.5, vol: 0.04)
    m.boom(hv + vanishAt, vol: 0.45)
    m.whoosh(hv + vanishAt + 0.05, 0.6, vol: 0.16)
    m.noise(hv + vanishAt, 3.4, vol: 0.03, cutoff: 0.35, attack: 0.05, release: 1.2, seed: 63)          // the fire
    m.typewriter(hv + vanishAt + 0.7, 8, gap: 0.08, vol: 0.08)
    for k in 0..<8 { m.step(hv + biffIn + Double(k) * 0.18, vol: 0.06) }
    groove(m, from: start("hook"), to: start("endcard"), fadeIn: 1.2)
    let hook = start("hook")
    for i in 0..<26 { m.click(hook + 0.2 + Double(i) * 0.13 + noise(i) * 0.06) }
    let desk = start("desktop"), deskEnd = end("desktop") + 1.3
    for (i, d) in [0.0, 0.12, 0.24, 0.32].enumerated() { m.step(desk + d + 0.3, vol: 0.1 + Double(i % 2) * 0.03) }
    for t in shotTimes(desk + 0.45, deskEnd, offset: 0) { m.pew(t, vol: 0.08) }
    let st = start("status")
    for i in 0..<4 { m.pop(st + 0.1 + Double(i) * 0.22, step: i) }
    for k in 0..<5 { m.tone(st + 1.2 + Double(k) * 0.62, 0.08, 1568, wave: .square(0.5), vol: 0.035, release: 0.03) }
    let ag = start("agents")
    for k in 0..<14 { m.step(ag + Double(k) * 0.125, vol: 0.06) }
    let wi = start("window")
    for k in [0.9, 1.8] { m.click(wi + k, vol: 0.06) }
    m.ping(wi + 2.5)
    let ais = start("ais")
    for i in 0..<7 { m.pop(ais + 0.15 + Double(i) * 0.1, step: i % 4) }
    for t in shotTimes(ais + 0.45, end("ais") + 1.0, offset: 0) { m.pew(t, vol: 0.05) }
    for s in shots { transitionSound(m, s) }
    let ec = start("endcard")
    for (s, d, chord) in [(0.0, 0.7, [60, 64, 67]), (0.7, 0.7, [65, 69, 72]), (1.4, 2.8, [67, 71, 74, 79])] {
        for n in chord { m.tone(ec + s, d, midi(n), wave: .saw, vol: 0.04, attack: 0.02, release: d > 1 ? 1.6 : 0.1) }
        m.tone(ec + s, d, midi(chord[0] - 24), wave: .sine, vol: 0.2, release: d > 1 ? 1.6 : 0.1)
    }
    m.boom(ec + 0.35, vol: 0.4)
}
