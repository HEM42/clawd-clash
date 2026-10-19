import AppKit
import CoreText

// The Detective Clawds trailer: `REEL=detective build/renderpromo video promo` → promo/detective-clawds-promo.mp4.
// Drawn with RenderPromo's kit (Tools/RenderPromo/Kit: `Shot`, `brawl`, `windowShot`, `everyAI`, `Mix`…) and compiled
// only into that tool.

/// The Detective Clawds trailer, as the tool asks for it.
struct DetectiveReel: PromoReel {
    let name = "detective", base = "detective-clawds-promo", small = "Detective-Clawds"
    let title = "DETECTIVE CLAWDS"
    let geminiTask = "gemini ▸ fix the clawdarang"
    var shots: [Shot] { detectiveShots }
    var beats: [(key: Double, beat: Beat)] { detectiveBeats }
    var universe: Universe { .dc }
    var brawl: BrawlCast {
        BrawlCast(claude: .hero(DetectiveHero.batman), other: .villain(DetectiveVillain.joker),
                  agent: .hero(DetectiveHero.greenArrow), otherAgent: .villain(DetectiveVillain.captainCold),
                  line: "Or pick Detective Clawds.",
                  sub: "Capes, power rings and one very serious bat: 207 characters in 43 places.")
    }
    var window: WindowCast {
        WindowCast(place: .gotham, claude: .hero(DetectiveHero.batman), other: .villain(DetectiveVillain.joker),
                   agentA: .hero(DetectiveHero.robin), agentB: .hero(DetectiveHero.nightwing), extra: .villain(DetectiveVillain.jokerGoon),
                   prompt: "You: “make the clawdarang come back”", otherPrompt: "You: “put a smile on that error page”")
    }
    func sound(_ m: Mix) { detectiveSound(m) }
}

// MARK: The Detective Clawds showcase (in its trailer, and on the promo's comic page)

/// A kaiju over Metropolis: a colossal horned beast stomps into the city, roars, and Superman flies up to meet it with
/// heat vision.

/// Fills a polygon on a pixel canvas (scanline, even-odd).
private func fillPoly(_ c: PixelCanvas, _ pts: [(Double, Double)], _ col: Px) {
    guard let y0 = pts.map({ $0.1 }).min(), let y1 = pts.map({ $0.1 }).max() else { return }
    for y in Int(y0.rounded(.down))...Int(y1.rounded(.up)) {             // rows off the canvas are clipped by rect
        let yy = Double(y) + 0.5
        var xs: [Double] = []
        for i in 0..<pts.count {
            let a = pts[i], b = pts[(i + 1) % pts.count]
            if (a.1 <= yy && b.1 > yy) || (b.1 <= yy && a.1 > yy) { xs.append(a.0 + (yy - a.1) / (b.1 - a.1) * (b.0 - a.0)) }
        }
        xs.sort()
        var i = 0
        while i + 1 < xs.count { c.rect(Int(xs[i].rounded()), y, max(1, Int(xs[i + 1].rounded()) - Int(xs[i].rounded())), 1, col); i += 2 }
    }
}

/// A filled ellipse (centre, radii) that tolerates any size.
private func blob(_ c: PixelCanvas, _ cx: Double, _ cy: Double, _ rx: Double, _ ry: Double, _ col: Px) {
    guard rx > 0, ry > 0 else { return }
    for y in Int((cy - ry).rounded(.down))...Int((cy + ry).rounded(.up)) {
        let d = (Double(y) + 0.5 - cy) / ry
        guard abs(d) <= 1 else { continue }
        let half = rx * (1 - d * d).squareRoot()
        c.rect(Int((cx - half).rounded()), y, max(1, Int((half * 2).rounded())), 1, col)
    }
}

/// A horn: a chain of shrinking circles along a curve from the root to the tip, lit along one side.
private func horn(_ c: PixelCanvas, from a: (Double, Double), bend b: (Double, Double), to e: (Double, Double), r: Double) {
    for i in 0...24 {
        let u = Double(i) / 24
        let x = (1 - u) * (1 - u) * a.0 + 2 * (1 - u) * u * b.0 + u * u * e.0
        let y = (1 - u) * (1 - u) * a.1 + 2 * (1 - u) * u * b.1 + u * u * e.1
        let rr = max(0.6, r * (1 - u * 0.9))
        blob(c, x, y, rr, rr, C(0xB8AE94))
        blob(c, x - rr * 0.3, y - rr * 0.3, rr * 0.55, rr * 0.55, C(0xECE4CC))
    }
}

/// The kaiju, facing left, on a 120×128 canvas: hulking and upright, slate-green hide with a pale plated belly, a row of
/// bone spines down its back, two great curved horns, burning orange eyes, a jaw that drops open to roar.
private let kaijuW = 120, kaijuH = 128                // 18 rows of headroom over the 110-row body for the horns
private func drawKaiju(_ c: PixelCanvas, t: Double, roar: Double, step: Double) {
    let hide = C(0x3E4A44), dark = C(0x232B28), lite = C(0x5E6E64), belly = C(0x8C8E70), bellyDark = C(0x6A6C54)
    c.oy = 18; defer { c.oy = 0 }
    let breathe = sin(t * 2.2) * 1.2, lift = -abs(sin(step * .pi)) * 2
    // the tail sweeping out behind, then the far leg
    for i in 0..<10 {
        let u = Double(i) / 9
        blob(c, 86 + u * 28, 92 - u * 16 + sin(t * 1.5 + u * 3) * 2, 11 - u * 8, 9 - u * 6, i % 2 == 0 ? hide : dark)
    }
    blob(c, 74, 90 + lift, 11, 15, dark)
    // the spines down the back
    for i in 0..<8 {
        let u = Double(i) / 7, x = 62 + u * 26, y = 26 + u * 46
        fillPoly(c, [(x - 4, y + 2), (x + 9 - u * 3, y - 10 + u * 3), (x + 4, y + 5)], C(0xD8D0B8))
        fillPoly(c, [(x - 1, y + 3), (x + 6 - u * 3, y - 6 + u * 3), (x + 4, y + 5)], C(0x9A927C))
    }
    // the body, the belly plates
    blob(c, 62, 60 + breathe * 0.5, 28, 32 + breathe, hide)
    blob(c, 70, 58, 18, 26, lite.alpha(0.35))
    blob(c, 54, 64 + breathe * 0.5, 15, 24, belly)
    for k in 0..<7 { c.rect(42, 46 + k * 6 + Int(breathe * 0.5), 26, 1, bellyDark) }
    // the near leg and its claws
    blob(c, 48, 92 + lift, 13, 15, hide)
    blob(c, 44, 104 + lift, 14, 5, dark)
    for k in 0..<3 { fillPoly(c, [(32 + Double(k) * 7, 103 + lift), (29 + Double(k) * 7, 108 + lift), (36 + Double(k) * 7, 106 + lift)], C(0xE8E0C8)) }
    // the arms reaching forward, claws out
    let sway = sin(t * 1.8) * 2
    for (k, (sx, sy)) in [(44.0, 46.0), (52.0, 50.0)].enumerated() {
        let hx = 18.0 + Double(k) * 6, hy = 56 + sway * (k == 0 ? 1 : -1)
        for i in 0...6 { let u = Double(i) / 6; blob(c, sx + (hx - sx) * u, sy + (hy - sy) * u, 7 - u * 2, 6 - u * 2, k == 0 ? hide : dark) }
        for j in 0..<3 { fillPoly(c, [(hx - 2, hy - 3 + Double(j) * 3), (hx - 9, hy - 2 + Double(j) * 3.5), (hx - 2, hy + Double(j) * 3)], C(0xE8E0C8)) }
    }
    // the head: heavy brow, long snout, a jaw that drops open
    let jaw = roar * 9
    let hx = 36.0, hy = 26.0 + breathe * 0.3
    blob(c, hx + 8, hy + 4, 16, 13, hide)                                         // skull
    fillPoly(c, [(hx - 2, hy - 6), (hx - 20, hy + 1), (hx - 18, hy + 6), (hx + 2, hy + 6)], hide)   // snout
    fillPoly(c, [(hx + 2, hy + 6 + jaw * 0.2), (hx - 18, hy + 8 + jaw), (hx - 14, hy + 13 + jaw), (hx + 12, hy + 14)], dark)   // lower jaw
    if roar > 0.1 {                                                               // the open mouth and its teeth
        fillPoly(c, [(hx - 17, hy + 6), (hx + 4, hy + 6), (hx + 4, hy + 7 + jaw * 0.8), (hx - 16, hy + 8 + jaw)], C(0x5A1A14))
        for k in 0..<5 {
            let x = hx - 15 + Double(k) * 4
            fillPoly(c, [(x, hy + 6), (x + 2, hy + 6), (x + 1, hy + 9)], C(0xF0E8D4))
            fillPoly(c, [(x, hy + 8 + jaw * (1 - Double(k) * 0.15)), (x + 2, hy + 8 + jaw * (1 - Double(k) * 0.15)), (x + 1, hy + 5 + jaw * (1 - Double(k) * 0.15))], C(0xF0E8D4))
        }
    }
    c.rect(Int(hx - 12), Int(hy - 6), 22, 3, dark)                                 // the brow ridge
    let glow = 0.75 + 0.25 * sin(t * 7)
    for ex in [hx - 4, hx + 6] {                                                   // burning eyes
        blob(c, ex, hy - 2, 3.2, 2.2, C(0xFF8A1E, 0.5 * glow))
        blob(c, ex, hy - 2, 2, 1.3, C(0xFFE08A, glow))
    }
    // the horns, sweeping up and back from the brow
    horn(c, from: (hx + 4, hy - 8), bend: (hx + 2, hy - 30), to: (hx + 26, hy - 34), r: 4.5)
    horn(c, from: (hx - 6, hy - 8), bend: (hx - 16, hy - 26), to: (hx - 4, hy - 38), r: 4)
}

/// Where the kaiju is (fx units, its feet), how big, and how far through a step, at shot-local time `l`.
private func kaijuAt(_ l: Double) -> (x: Double, y: Double, k: Double, step: Double) {
    let f = clamp((l - 0.8) / 5.6), e = f * f * (3 - 2 * f)
    return (lerp(330, 210, e), lerp(150, 190, e), lerp(0.5, 1.45, e), (l - 0.8) / 0.9)
}

private func kaijuRoar(_ l: Double) -> Double {
    func pulse(_ at: Double, _ len: Double) -> Double { let u = (l - at) / len; return u > 0 && u < 1 ? sin(u * .pi) : 0 }
    return max(pulse(2.8, 1.6), pulse(6.0, 1.8))
}

func detectiveShowcase(_ ctx: CGContext, local l: Double, t: Double) {
    // every footfall shakes the frame, harder as it gets closer
    let k = kaijuAt(l)
    let fall = frac(max(0, k.step)), shake = l > 0.8 && l < 6.6 ? max(0, 1 - fall * 4) * 10 * k.k : 0
    ctx.saveGState()
    ctx.translateBy(x: sin(t * 90) * shake, y: cos(t * 77) * shake * 0.6)
    blit(place(.metropolis, floorRows: 14, t: t), ctx)
    // the kaiju, its feet on the street, growing as it comes
    let kc = PixelCanvas(kaijuW, kaijuH)
    drawKaiju(kc, t: t, roar: kaijuRoar(l), step: k.step)
    kc.addOutline(C(AI.codex.hex, 0.92))
    if let img = kc.makeImage() {
        let s = 6 * k.k
        ctx.saveGState(); ctx.interpolationQuality = .none
        ctx.draw(img, in: CGRect(x: k.x * 6 - Double(kaijuW) * s * 0.45, y: Double(H) - k.y * 6, width: Double(kaijuW) * s, height: Double(kaijuH) * s))
        ctx.restoreGState()
    }
    ctx.restoreGState()
    // Superman rockets up from the street and hits it with heat vision
    if l > 3.8 {
        let f = easeOut((l - 3.8) / 1.4)
        onStage(ctx, CGRect(x: 0, y: 0, width: W, height: H), scale: 6, ground: Double(fxH) + 10) {
            var sup = Actor(cast: .hero(DetectiveHero.superman), x: lerp(-20, 70, f), facing: 1)
            sup.airborne = true
            sup.lift = lerp(10, 96, f)
            draw(sup, ctx, t: t)
            if l > 5.0 {
                let eyes = sup.fighter.point(sup.cast.muzzle.x, sup.cast.muzzle.y)
                let target = (k.x - 4 * k.k + sin(t * 9) * 2, k.y - 58 * k.k)       // its chest
                let beams = PixelCanvas(fxW, fxH + 10)
                beams.glowLine(eyes.x, eyes.y, target.0, target.1, core: C(0xFFF4D0), glow: C(0xFF3A1E), coreR: 0.8, glowR: 2.4)
                drawSparks(beams, x: target.0, y: target.1, t: t, size: 5)
                if let img = beams.makeImage() {
                    ctx.saveGState(); ctx.interpolationQuality = .none
                    ctx.draw(img, in: CGRect(x: 0, y: Double(H) - Double(beams.h) * 6, width: Double(beams.w) * 6, height: Double(beams.h) * 6))
                    ctx.restoreGState()
                }
            }
        }
    }
}

// MARK: The Detective Clawds openers (from the old Justice League trailer)

/// The title: DETECTIVE over CLAWDS, the D and the C at full strength and the rest faded, so it reads DC. `ink` draws it
/// as a plain silhouette (as the Night Beacon shows it).
func detectiveTitle(_ ctx: CGContext, center: CGPoint, scale s: Double, alpha: Double = 1, ink: NSColor? = nil) {
    let tf = NSFont(name: "Futura-CondensedExtraBold", size: 200) ?? .systemFont(ofSize: 190, weight: .black)
    ctx.saveGState()
    ctx.translateBy(x: center.x, y: center.y); ctx.scaleBy(x: s, y: s)
    for (i, (word, col, size)) in [("DETECTIVE", NSColor(srgbRed: 0.22, green: 0.48, blue: 0.95, alpha: alpha), 0.7),
                                   ("CLAWDS", yellow.withAlphaComponent(alpha), 1.0)].enumerated() {
        let f = NSFont(descriptor: tf.fontDescriptor, size: 200 * size) ?? tf
        let base: [NSAttributedString.Key: Any] = [.font: f, .kern: 10 * size]
        let sz = NSAttributedString(string: word, attributes: base).size()
        let p = NSPoint(x: -sz.width / 2, y: i == 0 ? 40 : -sz.height + 40)
        // the word, its first letter full strength and the rest faded
        func lettered(_ col: NSColor, faded: Double) -> NSAttributedString {
            var a = base; a[.foregroundColor] = col.withAlphaComponent(alpha * faded)
            let w = NSMutableAttributedString(string: word, attributes: a)
            w.addAttribute(.foregroundColor, value: col.withAlphaComponent(alpha), range: NSRange(location: 0, length: 1))
            return w
        }
        if let ink { lettered(ink, faded: 0.45).draw(at: p); continue }
        var outlined = base; outlined[.foregroundColor] = NSColor.black.withAlphaComponent(alpha)
        var filled = base; filled[.foregroundColor] = col
        let stamp = NSAttributedString(string: word, attributes: outlined), r = 12 * size
        for k in 0..<16 {                                   // a thick, round outline
            let a = Double(k) / 16 * 2 * .pi
            stamp.draw(at: NSPoint(x: p.x + cos(a) * r, y: p.y + sin(a) * r))
        }
        _ = filled
        lettered(col, faded: 0.45).draw(at: p)
    }
    ctx.restoreGState()
}

/// Gothamburg at night, two screens tall: the camera tilts up the searchlight's beam to the Night Beacon on the clouds,
/// pushes in, and the beacon switches from the cowl mask to the title.
func detectiveSignal(_ ctx: CGContext, local l: Double, t: Double) {
    let tallH = 300
    let city = place(.gotham, floorRows: 22, t: t, h: tallH)
    let sig = Scenes.gothamSignal(city, tallH - 22)               // the signal's centre, canvas pixels
    let tilt = clamp(l / 2.2), te = tilt * tilt * (3 - 2 * tilt)
    let off = Double(tallH - fxH) * (1 - te)                     // canvas rows above the top of the frame
    let push = clamp((l - 2.0) / 1.2), pe = push * push * (3 - 2 * push)
    let z = 1 + 2.2 * pe
    // where the signal sits on screen, and the push that brings it to the centre (y up, as CG has it)
    let sx = Double(sig.x) * 6 + 18, sy = Double(H) + off * 6 - Double(sig.y) * 6
    let cx = Double(W) / 2, cy = Double(H) / 2 + 60
    let s = 1 - pe + pe * z
    ctx.saveGState()
    ctx.translateBy(x: pe * (cx - sx * z), y: pe * (cy - sy * z))
    ctx.scaleBy(x: s, y: s)
    blit(city, ctx, dy: -off * 6)
    ctx.restoreGState()
    // the signal clicks over from the bat to the title
    if l > 3.0 {
        let on = clamp((l - 3.0) / 0.25) * (sin(l * 60) > -0.6 || l > 3.5 ? 1 : 0.4)
        ctx.saveGState()
        for (rx, ry, a) in [(760.0, 430.0, 0.10), (640.0, 360.0, 0.16), (560.0, 315.0, 0.95)] {
            ctx.setFillColor(CGColor(red: 0.96, green: 0.93, blue: 0.72, alpha: a * on))
            ctx.fillEllipse(in: CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2))
        }
        ctx.restoreGState()
        detectiveTitle(ctx, center: CGPoint(x: cx, y: cy - 20), scale: 0.66, alpha: on, ink: NSColor(srgbRed: 0.08, green: 0.08, blue: 0.11, alpha: 1))
    }
}

/// The Lookout: the Justice Clawds arrive one by one and line up in front of the Earth.
func detectiveLineup(_ ctx: CGContext, local l: Double, t: Double) {
    blit(place(.watchtower, floorRows: 30, t: t), ctx)
    let league: [(DetectiveHero, Double, String)] = [(.aquaman, 32, "walk"), (.greenLantern, 74, "fly"), (.wonderWoman, 116, "fly"),
                                                 (.superman, 160, "fly"), (.batman, 204, "rope"), (.flash, 246, "zip"),
                                                 (.cyborg, 288, "walk")]
    onStage(ctx, CGRect(x: 0, y: 0, width: W, height: H), scale: 6, ground: 158) {
        for (i, (who, x, how)) in league.enumerated() {
            let order = [3, 4, 2, 0, 1, 5, 6][i]                       // Superman first, then Batman, Wonder Woman…
            let d = 0.2 + Double(order) * 0.38, f = clamp((l - d) / 0.55)
            guard l > d else { continue }
            var a = Actor(cast: .hero(who), x: x, facing: x < 160 ? 1 : -1, mode: .idle)
            a.grow = 1.15
            switch how {
            case "fly": a.lift = 140 * (1 - easeOut(f)); a.airborne = f < 1
            case "rope": a.lift = 150 * (1 - easeOut(f))
            case "zip": a.x = lerp(-60, x, easeOut(f * 1.6))
            default: a.x = lerp(x < 160 ? -30 : 350, x, easeOut(f)); a.walking = f < 1
            }
            if how == "rope" && f < 1 {                                   // Batman's grapnel line
                let c = PixelCanvas(fxW, fxH + 20)
                c.rect(Int(a.x) + 4, 0, 1, Int(a.top) + 22, C(0x9AA0AE))
                if let img = c.makeImage() { ctx.draw(img, in: CGRect(x: 0, y: Double(H) - Double(c.h) * 6, width: Double(c.w) * 6, height: Double(c.h) * 6)) }
            }
            if how == "zip" && f < 0.62 {                                  // the Flash's streak
                let c = PixelCanvas(fxW, fxH + 20)
                c.glowLine(0, a.top + 30, a.x - 8, a.top + 30, core: C(0xFFF0A0), glow: C(0xE02A1E), coreR: 1, glowR: 3)
                if let img = c.makeImage() { ctx.draw(img, in: CGRect(x: 0, y: Double(H) - Double(c.h) * 6, width: Double(c.w) * 6, height: Double(c.h) * 6)) }
            }
            draw(a, ctx, t: t)
        }
    }
}

// MARK: The Detective Clawds trailer (the old Justice League trailer, rebuilt on Clawd Clash)

let detectiveShots: [Shot] = [
    Shot(name: "meanwhile", start: 0, end: 3.5, into: .cut) { ctx, local, t in
        ctx.setFillColor(CGColor(gray: 0, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let line = "MEANWHILE, AT THE \(Location("hallOfJustice").name.uppercased())..."
        let n = Int(clamp((local - 0.3) / 1.6) * Double(line.count))
        let a = 1 - clamp((local - 3.0) / 0.4)
        if n > 0 { captionBox(String(line.prefix(n)), ctx, center: CGPoint(x: Double(W) / 2, y: Double(H) / 2), size: 54, alpha: a) }
    },
    // Up the searchlight's beam to the Night Beacon, which clicks over to the title.
    Shot(name: "signal", start: 3.5, end: 8.0, into: .cut) { ctx, local, t in detectiveSignal(ctx, local: local, t: t) },
    // Megalopolis: the horned kaiju stomps in and roars; Superb-Man meets it with heat vision.
    Shot(name: "invasion", start: 8.0, end: 16.5, into: .cut) { ctx, local, t in detectiveShowcase(ctx, local: local, t: t) },
    // The Lookout: the Justice Clawds arrive and line up.
    Shot(name: "league", start: 16.5, end: 21.0, into: .cut) { ctx, local, t in detectiveLineup(ctx, local: local, t: t) },
    Shot(name: "hook", start: 21.0, end: 25.0) { ctx, local, t in
        let zoom = 1 + 0.03 * local
        ctx.saveGState()
        ctx.translateBy(x: Double(W) / 2, y: Double(H) / 2); ctx.scaleBy(x: zoom, y: zoom); ctx.translateBy(x: -Double(W) / 2, y: -Double(H) / 2)
        desktop(ctx, dim: 0)
        ctx.restoreGState()
        caption("Three AIs. Nine agents. One very confused human.", ctx, local: local, start: 0.05, y: 860, size: 60)
        caption("Sound familiar?", ctx, local: local, start: 0.7, y: 120, size: 76, color: yellow)
    },
    Shot(name: "desktop", start: 25.0, end: 29.6) { ctx, local, t in
        brawl(ctx, .dc, local: local, t: t, drop: true, chrome: false)
        badge("DESKTOP MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Now they're a pixel-art Detective Clawds brawl", ctx, local: local, start: 0.35, y: 900)
        caption("along the bottom of your screen. They fight while they work.", ctx, local: local, start: 0.6, y: 830, size: 40, color: yellow, weight: .bold)
    },
    Shot(name: "status", start: 29.6, end: 33.8) { ctx, local, t in
        let cast: [Cast] = [.hero(DetectiveHero.superman), .villain(DetectiveVillain.riddler), .villain(DetectiveVillain.harleyQuinn), .villain(DetectiveVillain.solomonGrundy)]
        statusOf(ctx, local: local, t: t, cast: cast, badgeText: "DETECTIVE CLAWDS", aside: "(\(cast[3].name): born on a Monday, napping by Thursday.)")
    },
    Shot(name: "agents", start: 33.8, end: 37.8) { ctx, local, t in
        agentsOf(ctx, local: local, t: t, guardCast: .hero(DetectiveHero.wonderWoman),
                 crew: [.hero(DetectiveHero.robin), .hero(DetectiveHero.nightwing), .hero(DetectiveHero.cyborg), .hero(DetectiveHero.krypto)],
                 line: "Every subagent answers the beacon.", badgeText: "DETECTIVE CLAWDS")
    },
    Shot(name: "window", start: 37.8, end: 42.6) { ctx, local, t in
        windowShot(ctx, .dc, local: local, t: t, rise: true, needsAt: 2.5, at: .batcave)
        badge("WINDOW MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Prefer a window? Step into \(Location.batcave.name).", ctx, local: local, start: 0.1, y: 955, size: 56)
        caption("A live card per session: what it's doing, your last prompt, every agent.", ctx, local: local, start: 0.4, y: 890, size: 32, color: yellow, weight: .bold)
    },
    Shot(name: "ais", start: 42.6, end: 47.0) { ctx, local, t in
        everyAI(ctx, local: local, t: t, cast: [.hero(DetectiveHero.superman), .hero(DetectiveHero.wonderWoman), .villain(DetectiveVillain.lexLuthor),
                                                .villain(DetectiveVillain.sinestro), .villain(DetectiveVillain.cheetah), .villain(DetectiveVillain.blackManta),
                                                .villain(DetectiveVillain.jokerGoon)])
    },
    // The end card: Gothamburg's rooftop under the beacon, the Clawdwing flies through, the title lands.
    Shot(name: "endcard", start: 47.0, end: 51.2) { ctx, local, t in
        blit(place(.gotham, floorRows: 34, t: t), ctx)
        ctx.setFillColor(CGColor(gray: 0, alpha: 0.3)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let fp = local / 1.2
        if fp > 0 && fp < 1 {
            let bc = PixelCanvas(Ride.width, Ride.height)
            drawRide(bc, .batwing, ramp: 0, engines: true, gear: false); bc.addOutline(C(0xFFFFFF, 0.92))
            if let img = bc.makeImage() {
                let x = lerp(-600, Double(W) + 100, easeIn(fp) * 0.6 + fp * 0.4)
                ctx.saveGState(); ctx.interpolationQuality = .none
                ctx.draw(img, in: CGRect(x: x, y: 600 + 200 * fp, width: Double(Ride.width) * 6, height: Double(Ride.height) * 6))
                ctx.restoreGState()
            }
        }
        let crew: [(Cast, FightRole, AI)] = [(.hero(DetectiveHero.wonderWoman), .cheer, .desktop), (.hero(DetectiveHero.superman), .shoot(offset: 0), .claude),
                                             (.villain(DetectiveVillain.lexLuthor), .shoot(offset: blasterPeriod / 2), .codex), (.villain(DetectiveVillain.blackManta), .none, .copilot),
                                             (.villain(DetectiveVillain.sinestro), .cheer, .qwen), (.villain(DetectiveVillain.cheetah), .none, .gemini)]
        var placed: [Actor] = []
        for (i, (who, role, ai)) in crew.enumerated() {
            var a = Actor(cast: who, x: [28.0, 84, 156, 206, 252, 296][i], facing: i < 2 ? 1 : -1, role: role, ai: ai)
            a.lift = 8
            a.alpha = clamp((local - 0.15 - Double(i) * 0.05) / 0.2)
            draw(a, ctx, t: t)
            placed.append(a)
        }
        if local > 0.5 { drawFX([(placed[1], placed[2])], ctx, t: t) }
        if local > 0.35 { detectiveTitle(ctx, center: CGPoint(x: Double(W) / 2, y: 760), scale: backOut((local - 0.35) / 0.4) * 0.8) }
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

let detectiveBeats: [(key: Double, beat: Beat)] = [
    (2.4, ("MEANWHILE...", "Black screen. A yellow comic caption types itself out, in the spirit of the old cartoons' narrator.", "“MEANWHILE, AT THE HALL OF CLAWDS...”", "typewriter keys, a bell")),
    (7.0, ("THE BEACON", "Gothamburg at night, rain falling. The camera climbs the searchlight's beam to the Night Beacon and pushes in; with a clunk the cowl mask switches to the title, its D and C at full strength.", "DETECTIVE / CLAWDS, as the beacon", "rain, far thunder, a rising line, the clunk and the big hit")),
    (14.5, ("THE KAIJU", "Megalopolis by day: a colossal horned kaiju stomps in, every step shaking the frame, and roars; Superb-Man rockets up and hits it with heat vision.", "no text", "stomps, two roars, heat vision")),
    (19.0, ("THE LINE-UP", "The Lookout over the Earth: Superb-Man flies down, Batclawd drops on his grapnel line, Wondrous Woman and the Green Lamplighter land, the Flare zips in, Aquamarine and Cyb-Org walk up.", "no text", "a heroic swell, whooshes, a zip")),
    (22.4, ("THE HOOK", "Three busy terminals, slow push-in.", "“Three AIs. Nine agents. One very confused human.”  →  “Sound familiar?”", "keyboard clicks")),
    (27.3, ("DESKTOP MODE", "Batclawd knocks away the Jester's shots; the Emerald Archer trades arrows for Captain Chill's ice.", "DESKTOP MODE  ·  “Now they're a pixel-art Detective Clawds brawl along the bottom of your screen. They fight while they work.”", "shots, whacks, arrows, ice")),
    (31.9, ("AT A GLANCE", "Superb-Man working, the Puzzler thinking, Harlee Quinn's jumping NEEDS YOU, Solomon Grundy sat down napping.", "“All fun and games, and you still see everything.”  ·  “(Solomon Grundy: born on a Monday, napping by Thursday.)”", "blips, alert beeps")),
    (36.0, ("SUBAGENTS", "Wondrous Woman stands guard; Wren, Nightglider, Cyb-Org and Kryptro arrive with their jobs on their labels.", "“Every subagent answers the beacon.”", "footsteps, a bark")),
    (40.6, ("WINDOW MODE", "The window in the Night Grotto: Batclawd against the Jester, live cards tick, then the Jester's Codex card flips to NEEDS YOU.", "WINDOW MODE  ·  “Prefer a window? Step into The Night Grotto.”", "a ping")),
    (45.0, ("EVERY AI", "Six sessions, one per AI outline; Claude's Superb-Man a head taller, trading heat vision with Codex's Lex Lugar.", "BRING YOUR OWN AI*  ·  “One AI plays everyone. Run two and they pick sides.”  ·  *README for the full list", "heat vision crackle")),
    (50.0, ("END CARD", "Gothamburg's rooftop under the beacon: the Clawdwing streaks across, the crew lines up, DETECTIVE CLAWDS lands.", "DETECTIVE CLAWDS  ·  “Have fun. Keep track.”  ·  “One of many universes in Clawd Clash · free for macOS”  ·  github.com/rodclemen/clawd-clash", "a flyby, the final sting")),
]

/// The Detective Clawds trailer's score and effects.
func detectiveSound(_ m: Mix) {
    let mw = start("meanwhile")
    for i in 0..<38 { m.type(mw + 0.3 + Double(i) / 38 * 1.6 + noise(i) * 0.02, vol: 0.18 + noise(i + 50) * 0.08) }
    m.ding(mw + 2.0)
    m.tone(mw + 0.2, 3.0, midi(33), wave: .sine, vol: 0.05, attack: 1.0, release: 0.8)
    let sg = start("signal")
    m.rain(sg, 4.5 + 1.0); m.boom(sg + 0.4, vol: 0.12)
    for (k, n) in [45, 48, 52, 55, 57].enumerated() { m.tone(sg + 0.3 + Double(k) * 0.5, 0.9, midi(n), wave: .triangle, vol: 0.05, attack: 0.1, release: 0.4) }
    let hit = sg + 3.0
    m.clunk(hit - 0.12); m.boom(hit, vol: 0.55); m.noise(hit, 1.6, vol: 0.12, cutoff: 0.9, decay: 0.5, highpass: true, seed: 3)
    for n in [45, 52, 57, 60, 64] { m.tone(hit, 1.2, midi(n), wave: .saw, vol: 0.05, release: 0.6, decay: 0.7) }
    for (s, d, n) in [(0.25, 0.22, 64), (0.5, 0.22, 69), (0.75, 0.5, 72), (1.3, 0.6, 71)] as [(Double, Double, Int)] {
        m.tone(hit + s, d, midi(n + 12), wave: .square(0.5), vol: 0.07, release: 0.08, vibrato: 0.006)
        m.tone(hit + s, d, midi(n), wave: .saw, vol: 0.045, release: 0.08)
    }
    let inv = start("invasion")
    for i in 0..<Int(9.5 / 0.25) { m.tone(inv + Double(i) * 0.25, 0.22, midi(i % 8 == 7 ? 37 : 36), wave: .square(0.25), vol: 0.04 + 0.06 * min(1, Double(i) / 30), release: 0.04) }
    for (s, chord) in [(0.0, [48, 51, 55]), (2.0, [44, 48, 51]), (4.0, [46, 50, 53]), (6.0, [48, 51, 55]), (7.0, [43, 47, 50])] {
        for n in chord { m.tone(inv + s, 1.8, midi(n), wave: .saw, vol: 0.035, attack: 0.05, release: 0.6) }
    }
    var step = 0.8
    while step < 6.6 { m.boom(inv + step, vol: 0.14 + (step / 6.6) * 0.22); step += 0.9 }
    m.roar(inv + 2.8, 1.6, vol: 0.26); m.roar(inv + 6.0, 1.8, vol: 0.32)
    m.noise(inv + 3.0, 6.5, vol: 0.28, cutoff: 0.004, cutoffTo: 0.03, attack: 3.0, release: 1.5, seed: 5)
    m.tone(inv + 3.0, 6.5, 41, wave: .sine, vol: 0.16, attack: 3.0, release: 1.5)
    m.whoosh(inv + 4.4, 1.4, vol: 0.18); m.crackle(inv + 5.0, 3.5 + 1.0, vol: 0.06)
    let lg = start("league")
    for k in 0..<10 { m.tone(lg - 0.5 + Double(k) * 0.05, 0.08, 70, to: 55, wave: .sine, vol: 0.05 + Double(k) * 0.012, decay: 0.05) }
    for (s, d, chord) in [(0.0, 1.1, [48, 52, 55, 60]), (1.1, 1.1, [41, 45, 48, 53]), (2.2, 1.1, [43, 47, 50, 55]), (3.3, 1.6, [48, 52, 55, 60])] {
        for n in chord { m.tone(lg + s, d, midi(n), wave: .saw, vol: 0.035, attack: 0.15, release: 0.4) }
        m.tone(lg + s, d, midi(chord[0] - 12), wave: .sine, vol: 0.16, attack: 0.05, release: 0.4)
    }
    for (s, d, n) in [(0.2, 0.4, 67), (0.6, 0.5, 72), (1.1, 0.9, 74), (2.2, 0.4, 71), (2.6, 0.5, 74), (3.3, 1.4, 79)] as [(Double, Double, Int)] {
        m.tone(lg + s, d, midi(n), wave: .square(0.5), vol: 0.06, attack: 0.02, release: 0.12, vibrato: 0.006)
    }
    for order in 0..<7 { m.whoosh(lg + 0.2 + Double(order) * 0.38 + 0.3, 0.5, vol: 0.08) }
    m.tone(lg + 0.2 + 5 * 0.38, 0.3, 300, to: 2400, wave: .saw, vol: 0.05, release: 0.1)
    groove(m, from: start("hook"), to: start("endcard"), fadeIn: 1.2)
    let hook = start("hook")
    for i in 0..<26 { m.click(hook + 0.2 + Double(i) * 0.13 + noise(i) * 0.06) }
    let desk = start("desktop"), deskEnd = end("desktop") + 1.3
    for (i, d) in [0.0, 0.12, 0.24, 0.32].enumerated() { m.step(desk + d + 0.3, vol: 0.1 + Double(i % 2) * 0.03) }
    for t in shotTimes(desk + 0.45, deskEnd, offset: 0) { m.pew(t, vol: 0.1); m.clang(t + boltArrival * blasterPeriod, vol: 0.08); m.thwip(t + 0.02, vol: 0.06) }
    for t in shotTimes(desk + 0.45, deskEnd, offset: blasterPeriod / 2) { m.ice(t, vol: 0.07) }
    let st = start("status")
    for i in 0..<4 { m.pop(st + 0.1 + Double(i) * 0.22, step: i) }
    for k in 0..<5 { m.tone(st + 1.2 + Double(k) * 0.62, 0.08, 1568, wave: .square(0.5), vol: 0.035, release: 0.03) }
    let ag = start("agents")
    for k in 0..<14 { m.step(ag + Double(k) * 0.125, vol: 0.06) }
    m.bark(ag + 1.4)
    let wi = start("window")
    for t in shotTimes(wi, wi + 2.5, offset: 0) { m.pew(t, vol: 0.05); m.clang(t + boltArrival * blasterPeriod, vol: 0.05) }
    for k in [0.9, 1.8] { m.click(wi + k, vol: 0.06) }
    m.ping(wi + 2.5)
    let ais = start("ais")
    for i in 0..<6 { m.pop(ais + 0.15 + Double(i) * 0.1, step: i % 4) }
    m.crackle(ais + 0.4, end("ais") + 1.3 - ais - 0.4, vol: 0.045)
    for s in shots { transitionSound(m, s) }
    let ec = start("endcard")
    for (s, d, chord, lead) in [(0.0, 0.7, [53, 57, 60, 65], 81), (0.7, 0.7, [55, 59, 62, 67], 83), (1.4, 2.8, [57, 61, 64, 69], 85)] {
        for n in chord { m.tone(ec + s, d, midi(n), wave: .saw, vol: 0.045, attack: 0.02, release: d > 1 ? 1.6 : 0.1) }
        m.tone(ec + s, d, midi(lead), wave: .square(0.5), vol: 0.06, release: d > 1 ? 1.6 : 0.1, vibrato: 0.006)
        m.tone(ec + s, d, midi(chord[0] - 24), wave: .sine, vol: 0.2, release: d > 1 ? 1.6 : 0.1)
    }
    m.boom(ec + 0.35, vol: 0.45)
    m.noise(ec + 1.4, 2.5, vol: 0.08, cutoff: 0.9, decay: 0.8, highpass: true, seed: 8)
    m.jet(ec, 1.2, vol: 0.08)
    m.crackle(ec + 0.5, duration - ec - 0.5, vol: 0.025)
}
