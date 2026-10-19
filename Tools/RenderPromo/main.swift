import AppKit
import AVFoundation
import CoreText

// Renders Clawd Clash's promo videos with the app's own sprites, places and transitions: the promo (one universe at a
// time, as in the app), the blooper reel (where the universes get mixed up), or both back to back, the Clawd Royale
// teaser, and each universe's own trailer. Each comes with its own synthesized soundtrack. This file has the owner's
// reels, the ones that mix universes; the shared parts are in Tools/RenderPromo/Kit/, and each universe's trailer is in
// its folder, `Promo/<Prefix>Reel.swift`, behind `PromoReel` (Kit/Reel.swift). Build it, then run it from the repo root
// (it reads Resources/AppIcon.png):
//   source Tools/universes.sh && swiftc -O -swift-version 5 Sources/App/{Pixel,Characters,Fights,Persona,Theme,Pose,Locations,Cast,Habits,Drills,Icon,Rides}.swift \
//          $UNIVERSE_APP $UNIVERSE_PROMO Sources/Shared/*.swift Tools/RenderPromo/Kit/*.swift Tools/RenderPromo/main.swift -o build/renderpromo
//   build/renderpromo storyboard promo           → promo/storyboard-promo.png (REEL=bloopers: storyboard-bloopers.png)
//   build/renderpromo video promo                → promo/clawd-clash-promo.mp4 (H.264 + AAC)
//   REEL=bloopers build/renderpromo video promo  → promo/clawd-clash-bloopers.mp4
//   REEL=full build/renderpromo video promo      → promo/clawd-clash-full.mp4: the promo, then the bloopers
//   REEL=starclawds build/renderpromo video promo → promo/star-clawds-promo.mp4: the Star Clawds trailer
//   REEL=marvelous build/renderpromo video promo  → promo/marvelous-clawds-promo.mp4: the Marvelous Clawds trailer
//   REEL=detective build/renderpromo video promo  → promo/detective-clawds-promo.mp4: the Detective Clawds trailer
//   REEL=doctor build/renderpromo video promo     → promo/doctor-clawd-promo.mp4: the Doctor Clawd trailer
//   REEL=files build/renderpromo video promo      → promo/the-clawd-files-promo.mp4: The Clawd Files trailer
//   REEL=clawdberg build/renderpromo video promo  → promo/stevie-clawdberg-promo.mp4: the Stevie Clawdberg trailer
//   REEL=royale build/renderpromo video promo     → promo/clawd-royale-promo.mp4: the Clawd Royale teaser
//   REEL=royale build/renderpromo 720p promo      → promo/720p/Clawd-Royale.mp4 (storyboard: storyboard-clawd-royale.png)
//   REEL=clawdoftherings build/renderpromo video promo → promo/clawd-of-the-rings-promo.mp4: the Clawd of the Rings trailer
//   REEL=slayer build/renderpromo video promo     → promo/clawd-slayer-promo.mp4: the Clawd Slayer trailer
//   build/renderpromo audio promo                → the soundtrack alone, as a .wav
//   build/renderpromo frame promo 9.5            → a single frame at 9.5 s
//   REEL=full build/renderpromo check            → renders every frame once (prints how far it got)
//   REEL=full build/renderpromo 720p promo       → promo/720p/Clawd-Clash-Full.mp4: the copy under 10 MB for GitHub
// clawdify_guide.md's "Promo: the universe's trailer" section has the whole routine (reels, music, wiring a new one).

// MARK: The cover: three slanted panels and CLAWD CLASH, as on the icon

/// Panel `i` (0 Star Clawds, 1 Marvelous Clawds, 2 Detective Clawds) at frame size.
func coverPanel(_ i: Int) -> CGPath {
    let cuts: [CGFloat] = [-400, 700, 1240, 2400], tilt: CGFloat = 110
    let p = CGMutablePath()
    p.addLines(between: [CGPoint(x: cuts[i] - tilt, y: 0), CGPoint(x: cuts[i + 1] - tilt, y: 0),
                         CGPoint(x: cuts[i + 1] + tilt, y: CGFloat(H)), CGPoint(x: cuts[i] + tilt, y: CGFloat(H))])
    p.closeSubpath()
    return p
}


/// A word of the name, block-extruded and ink-outlined, its face coloured by whichever panel each part is in.
func coverWord(_ ctx: CGContext, _ s: String, at c: CGPoint, width: CGFloat, height: CGFloat, angle: CGFloat, depth: Int, scale: CGFloat) {
    let faces: [(UInt32, UInt32)] = [(0xFFFFFF, 0xFF8A8A), (0xFFFFFF, 0x8FB8FF), (0xFFF3B0, 0xFFC21A)]
    var path = letters(s)
    let k = min(width / path.boundingBox.width, height / path.boundingBox.height) * scale
    var t = CGAffineTransform(scaleX: k, y: k).concatenating(CGAffineTransform(rotationAngle: angle))
        .concatenating(CGAffineTransform(translationX: c.x, y: c.y))
    path = path.copy(using: &t)!
    let b = path.boundingBox, step = b.height / 80, line = b.height * 0.15
    ctx.saveGState()
    ctx.setLineJoin(.round)
    for i in stride(from: depth, through: 1, by: -1) {
        ctx.saveGState()
        ctx.translateBy(x: CGFloat(i) * step * 0.6, y: -CGFloat(i) * step)
        ctx.addPath(path); ctx.setStrokeColor(inkColor); ctx.setLineWidth(line); ctx.strokePath()
        ctx.addPath(path); ctx.setFillColor(inkColor); ctx.fillPath()
        ctx.restoreGState()
    }
    ctx.addPath(path); ctx.setStrokeColor(inkColor); ctx.setLineWidth(line); ctx.strokePath()
    for i in 0..<3 {
        ctx.saveGState()
        ctx.addPath(coverPanel(i)); ctx.clip()
        ctx.addPath(path); ctx.clip()
        let face = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [hexCG(faces[i].0), hexCG(faces[i].1)] as CFArray, locations: [0.2, 1])!
        ctx.drawLinearGradient(face, start: CGPoint(x: 0, y: b.maxY), end: CGPoint(x: 0, y: b.minY), options: [])
        ctx.setFillColor(hexCG(0xFFFFFF, 0.3)); ctx.fill(CGRect(x: b.minX, y: b.midY + b.height * 0.1, width: b.width, height: b.height * 0.09))
        ctx.restoreGState()
    }
    ctx.restoreGState()
}

/// The gutters between the panels, white on ink.
func coverGutters(_ ctx: CGContext) {
    for x in [700.0, 1240.0] as [CGFloat] {
        ctx.move(to: CGPoint(x: x - 110, y: 0)); ctx.addLine(to: CGPoint(x: x + 110, y: CGFloat(H)))
        ctx.setStrokeColor(inkColor); ctx.setLineWidth(30); ctx.strokePath()
        ctx.move(to: CGPoint(x: x - 110, y: 0)); ctx.addLine(to: CGPoint(x: x + 110, y: CGFloat(H)))
        ctx.setStrokeColor(hexCG(0xFFFFFF)); ctx.setLineWidth(16); ctx.strokePath()
    }
}

/// The three worlds side by side: each panel its universe's place, tinted like the icon, with its arch-enemies
/// fighting in it.
func coverPanels(_ ctx: CGContext, t: Double, fighters: Bool = true, dim: Double = 0) {
    let worlds: [(Location, UInt32, UInt32)] = [(.deathStar, 0x6E0C1A, 0x1A0610), (.titan, 0xB81A2A, 0x0E2A6E), (.gotham, 0x2B3F7A, 0x0A1028)]
    for (i, (loc, top, bottom)) in worlds.enumerated() {
        ctx.saveGState()
        ctx.addPath(coverPanel(i)); ctx.clip()
        blit(place(loc, floorRows: 30, t: t), ctx)
        let sky = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [hexCG(top, 0.45), hexCG(bottom, 0.25)] as CFArray, locations: [0, 1])!
        ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: 0), options: [])
        if fighters {
            let pairs: [(Actor, Actor)] = [
                (Actor(cast: .hero(SWHero.luke), x: 30, role: .duel), Actor(cast: .villain(SWVillain.vader), x: 87, facing: -1, role: .duel)),
                (Actor(cast: .hero(MarvelHero.captainAmerica), x: 132, role: .block), Actor(cast: .villain(MarvelVillain.thanos), x: 196, facing: -1, role: .zap)),
                (Actor(cast: .hero(DCHero.batman), x: 236, role: .deflect), Actor(cast: .villain(DCVillain.joker), x: 296, facing: -1, role: .shoot(offset: 0))),
            ]
            let (a, b) = pairs[i]
            draw(a, ctx, t: t); draw(b, ctx, t: t)
            drawFX([(a, b)], ctx, t: t)
        }
        ctx.restoreGState()
    }
    if dim > 0 { ctx.setFillColor(CGColor(gray: 0, alpha: dim)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H)) }
    coverGutters(ctx)
}

// MARK: The clapperboard

/// A film slate, `w` wide, centred on `c`: the board with its writing, and the striped clapper, `open` 0…1.
func clapper(_ ctx: CGContext, center c: CGPoint, width w: CGFloat, open: Double, take: String, title: String = "CLAWD CLASH") {
    let h = w * 0.62, arm = w * 0.17
    let board = CGRect(x: c.x - w / 2, y: c.y - h / 2, width: w, height: h - arm)
    ctx.saveGState()
    ctx.setFillColor(inkColor); ctx.fill(board)
    ctx.setStrokeColor(CGColor(gray: 1, alpha: 0.9)); ctx.setLineWidth(w * 0.006)
    ctx.stroke(board.insetBy(dx: w * 0.03, dy: w * 0.03))
    for y in [0.36, 0.62] as [CGFloat] { ctx.move(to: CGPoint(x: board.minX + w * 0.03, y: board.minY + board.height * y)); ctx.addLine(to: CGPoint(x: board.maxX - w * 0.03, y: board.minY + board.height * y)) }
    ctx.strokePath()
    let tf = NSFont(name: "Futura-CondensedExtraBold", size: w * 0.15) ?? .systemFont(ofSize: w * 0.15, weight: .black)
    let big = NSAttributedString(string: title, attributes: [.font: tf, .foregroundColor: NSColor.white, .kern: w * 0.01])
    big.draw(at: NSPoint(x: c.x - big.size().width / 2, y: board.minY + board.height * 0.64))
    let small = NSFont.monospacedSystemFont(ofSize: w * 0.05, weight: .bold)
    for (i, s) in ["SCENE  CLASH", "TAKE  \(take)", "ROLL  3"].enumerated() {
        NSAttributedString(string: s, attributes: [.font: small, .foregroundColor: NSColor.white])
            .draw(at: NSPoint(x: board.minX + w * [0.06, 0.45, 0.74][i], y: board.minY + board.height * 0.43))
    }
    NSAttributedString(string: "DIRECTOR  CLAWD", attributes: [.font: small, .foregroundColor: NSColor(white: 0.75, alpha: 1)])
        .draw(at: NSPoint(x: board.minX + w * 0.06, y: board.minY + board.height * 0.12))
    // the clapper: a striped bar hinged at the top left, swinging up to `open`
    func stripes(_ r: CGRect) {
        ctx.setFillColor(CGColor(gray: 0.97, alpha: 1)); ctx.fill(r)
        ctx.saveGState(); ctx.clip(to: r)
        ctx.setFillColor(inkColor)
        var x = r.minX - r.height
        while x < r.maxX { let p = CGMutablePath(); p.addLines(between: [CGPoint(x: x, y: r.minY), CGPoint(x: x + r.height * 0.9, y: r.minY), CGPoint(x: x + r.height * 1.9, y: r.maxY), CGPoint(x: x + r.height, y: r.maxY)]); ctx.addPath(p); ctx.fillPath(); x += r.height * 2 }
        ctx.restoreGState()
        ctx.setStrokeColor(inkColor); ctx.setLineWidth(w * 0.008); ctx.stroke(r)
    }
    stripes(CGRect(x: board.minX, y: board.maxY, width: w, height: arm * 0.55))           // the fixed bar
    ctx.translateBy(x: board.minX, y: board.maxY + arm * 0.55)
    ctx.rotate(by: CGFloat(open) * 0.45)
    stripes(CGRect(x: 0, y: 0, width: w, height: arm * 0.55))                               // the clapstick
    ctx.restoreGState()
}

/// A take ending: "CUT!" shouted from off screen at the right, then a small slate snapping shut with the take number.
func cutAndSlate(_ ctx: CGContext, local l: Double, at: Double, take: String, wrap: Bool = false) {
    let u = l - at
    guard u > 0 else { return }
    let pop = backOut(u / 0.25)
    if wrap {
        balloon("CUT! THAT'S A WRAP!", ctx, center: CGPoint(x: Double(W) / 2, y: 900), tail: CGPoint(x: Double(W) / 2 + 300, y: Double(H) + 40),
                size: 70 * pop, width: 1500, color: NSColor(srgbRed: 0.85, green: 0.1, blue: 0.1, alpha: 1))
    } else {
        balloon("CUT!", ctx, center: CGPoint(x: Double(W) - 260, y: 820), tail: CGPoint(x: Double(W) + 60, y: 900), size: 90 * pop,
                width: 500, color: NSColor(srgbRed: 0.85, green: 0.1, blue: 0.1, alpha: 1))
    }
    if u > 0.45 {
        let s = u - 0.45
        let slide = easeOut(s / 0.2)
        clapper(ctx, center: CGPoint(x: 250 - 300 * (1 - slide), y: 860), width: 380, open: max(0, 1 - s / 0.25), take: take)
    }
}

// MARK: The promo

/// The status line-up in one universe: working, thinking, needs you, napping.
func statusLineup(_ ctx: CGContext, local: Double, t: Double) {
    desktop(ctx, dim: 1)
    let cast: [(Cast, AI, VaderMode, BubbleKind?, String, NSColor, Bool)] = [
        (.hero(MarvelHero.thor), .claude, .working, nil, "WORKING", green, false),
        (.villain(MarvelVillain.loki), .qwen, .thinking, .thinking, "THINKING…", NSColor(white: 0.9, alpha: 1), false),
        (.villain(MarvelVillain.ultron), .gemini, .waiting, .waiting, "NEEDS YOU!", red, false),
        (.villain(MarvelVillain.thanos), .copilot, .idle, .sleeping, "NAPPING", NSColor(srgbRed: 0.6, green: 0.55, blue: 1, alpha: 1), true),
    ]
    for (i, (who, ai, mode, bubble, word, col, sits)) in cast.enumerated() {
        let d = 0.1 + Double(i) * 0.22
        let f = backOut((local - d) / 0.35)
        guard local > d else { continue }
        var a = Actor(cast: who, x: 48 + Double(i) * 75, mode: mode, bubble: bubble, ai: ai)
        a.sitting = sits
        a.urgent = mode == .waiting
        if a.urgent { a.lift = abs(sin(t * 2 * .pi * 1.6)) * 6 }
        a.lift += (1 - f) * -8
        a.alpha = clamp(f)
        draw(a, ctx, t: t)
        let w = NSAttributedString(string: word, attributes: [.font: NSFont.systemFont(ofSize: 40, weight: .black), .kern: 2]).size().width
        text(word, ctx, x: a.x * S - w / 2, y: 70, size: 40, weight: .black, color: col, alpha: clamp(f), kern: 2)
    }
    badge(Universe.marvel.title.uppercased(), ctx, alpha: 1)
    caption("All fun and games, and you still see everything.", ctx, local: local, start: 0.05, y: 900, size: 58)
    caption("(Thanoz sits down when the job's done. Relatable.)", ctx, local: local, start: 0.9, y: 835, size: 36, color: yellow, weight: .bold)
}

/// Subagents arriving with their jobs on their labels.
func agentsArrive(_ ctx: CGContext, local: Double, t: Double) {
    desktop(ctx, dim: 1)
    draw(Actor(cast: .hero(DCHero.wonderWoman), x: 262, facing: -1, mode: .standGuard, label: "idle-claude"), ctx, t: t)
    let crew: [(DCHero, String, Double)] = [(.robin, "Find hook events", 190), (.nightwing, "Write changelog", 140),
                                            (.cyborg, "Check git history", 90), (.krypto, "Plan the refactor", 40)]
    for (i, (who, task, stop)) in crew.enumerated() {
        let f = easeOut((local - Double(i) * 0.18) / 0.75)
        draw(Actor(cast: .hero(who), x: lerp(-30, stop, f), session: false, walking: f < 0.98, label: task), ctx, t: t)
    }
    badge(Universe.dc.title.uppercased(), ctx, alpha: 1)
    caption("Every subagent reports for duty.", ctx, local: local, start: 0.1, y: 900)
    caption("Its job is right there on its label. No more guessing.", ctx, local: local, start: 0.45, y: 835, size: 40, color: yellow, weight: .bold)
}

// MARK: The Detective Clawds showcase (in its trailer, and on the promo's comic page)

/// A kaiju over Metropolis: a colossal horned beast stomps into the city, roars, and Superman flies up to meet it with
/// heat vision.

/// Fills a polygon on a pixel canvas (scanline, even-odd).
func fillPoly(_ c: PixelCanvas, _ pts: [(Double, Double)], _ col: Px) {
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
func blob(_ c: PixelCanvas, _ cx: Double, _ cy: Double, _ rx: Double, _ ry: Double, _ col: Px) {
    guard rx > 0, ry > 0 else { return }
    for y in Int((cy - ry).rounded(.down))...Int((cy + ry).rounded(.up)) {
        let d = (Double(y) + 0.5 - cy) / ry
        guard abs(d) <= 1 else { continue }
        let half = rx * (1 - d * d).squareRoot()
        c.rect(Int((cx - half).rounded()), y, max(1, Int((half * 2).rounded())), 1, col)
    }
}

/// A horn: a chain of shrinking circles along a curve from the root to the tip, lit along one side.
func horn(_ c: PixelCanvas, from a: (Double, Double), bend b: (Double, Double), to e: (Double, Double), r: Double) {
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
let kaijuW = 120, kaijuH = 128                // 18 rows of headroom over the 110-row body for the horns
func drawKaiju(_ c: PixelCanvas, t: Double, roar: Double, step: Double) {
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
func kaijuAt(_ l: Double) -> (x: Double, y: Double, k: Double, step: Double) {
    let f = clamp((l - 0.8) / 5.6), e = f * f * (3 - 2 * f)
    return (lerp(330, 210, e), lerp(150, 190, e), lerp(0.5, 1.45, e), (l - 0.8) / 0.9)
}

func kaijuRoar(_ l: Double) -> Double {
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
            var sup = Actor(cast: .hero(DCHero.superman), x: lerp(-20, 70, f), facing: 1)
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

// MARK: Pick your universe: the pop-art page (as on the social preview), a panel per universe round a centre panel

/// Each universe's face-off on the page, its sound word, and its panel's pop-art colours (base, pattern).
func pickVerse(_ u: Universe) -> (hero: Cast, villain: Cast, sound: String, pop: (UInt32, UInt32)) {
    switch u {
    case .starWars: return (.hero(SWHero.luke), .villain(SWVillain.vader), "VWOOM!", (0xFFD62E, 0xFFF08A))
    case .marvel: return (.hero(MarvelHero.thor), .villain(MarvelVillain.loki), "KRAKOOM!", (0xE8322E, 0xFF7A70))
    case .dc: return (.hero(DCHero.batman), .villain(DCVillain.joker), "BLAM!", (0x2EA8E8, 0x8AD8FF))
    case .doctor: return (.hero(DoctorHero.doctorTen), .villain(DoctorVillain.dalick), "VWORP!", (0x7CC84A, 0xB8EC88))
    case .clawdFiles: return (.hero(FilesHero.foxClawder), .villain(FilesVillain.grey), "ZZZT!", (0xFF7A1E, 0xFFC27A))
    case .clawdberg: return (.hero(ClawdbergHero.indianaBones), .villain(ClawdbergVillain.reneBellock), "CRACK!", (0xA65AE8, 0xD2A8FF))
    case .middleEarth: return (.hero(RingsHero.gandalf), .villain(RingsVillain.balrog), "KA-THOOM!", (0x1EB8A8, 0x8AE8DC))
    case .slayer: return (.hero(SlayerHero.buffyClawmers), .villain(SlayerVillain.oldMaster), "THWACK!", (0x2ED8D0, 0xA0F6F0))
    default: preconditionFailure("no promo data for \(u.title) here yet: the universe-modules plan moves it into its folder")
    }
}

/// A pop-art fill over `r`: 0 diagonal stripes, 1 halftone dots, 2 a sunburst, 3 swirling rays, 4 dots fading up.
func pickFill(_ ctx: CGContext, _ r: CGRect, kind: Int, pair: (UInt32, UInt32), spin: Double = 0) {
    ctx.setFillColor(hexCG(pair.0)); ctx.fill(r)
    let light = hexCG(pair.1)
    func dots(_ cell: Double, _ size: (Double) -> Double) {
        var y = r.minY, row = 0
        while y < r.maxY + cell {
            var x = r.minX + (row % 2 == 0 ? 0 : cell / 2)
            while x < r.maxX + cell {
                let d = size((y - r.minY) / r.height) * cell
                if d > 0.5 { ctx.addEllipse(in: CGRect(x: x - d / 2, y: y - d / 2, width: d, height: d)) }
                x += cell
            }
            y += cell; row += 1
        }
        ctx.setFillColor(light); ctx.fillPath()
    }
    switch kind {
    case 0:
        var x = r.minX - r.height
        while x < r.maxX { ctx.move(to: CGPoint(x: x, y: r.minY)); ctx.addLine(to: CGPoint(x: x + r.height, y: r.maxY)); x += 45 }
        ctx.setStrokeColor(light); ctx.setLineWidth(18); ctx.strokePath()
    case 1: dots(18) { _ in 0.55 }
    case 2, 3:
        let f = CGPoint(x: r.midX, y: r.midY), far = hypot(r.width, r.height)
        for k in 0..<40 where k % 2 == 0 {
            let a0 = Double(k) / 40 * 2 * .pi + spin, a1 = Double(k + 1) / 40 * 2 * .pi + spin
            if kind == 2 {
                ctx.move(to: f); ctx.addLine(to: CGPoint(x: f.x + cos(a0) * far, y: f.y + sin(a0) * far))
                ctx.addLine(to: CGPoint(x: f.x + cos(a1) * far, y: f.y + sin(a1) * far)); ctx.closePath()
            } else {
                ctx.move(to: f)
                ctx.addQuadCurve(to: CGPoint(x: f.x + cos(a0 + 0.6) * far, y: f.y + sin(a0 + 0.6) * far),
                                 control: CGPoint(x: f.x + cos(a0) * far * 0.5, y: f.y + sin(a0) * far * 0.5))
                ctx.addLine(to: CGPoint(x: f.x + cos(a1 + 0.6) * far, y: f.y + sin(a1 + 0.6) * far))
                ctx.addQuadCurve(to: f, control: CGPoint(x: f.x + cos(a1) * far * 0.5, y: f.y + sin(a1) * far * 0.5))
            }
        }
        ctx.setFillColor(light); ctx.fillPath()
    default: dots(15) { q in 0.15 + 0.6 * q }
    }
}

/// The page's panels: one per universe, and the centre one. The layout grows with the universes: two flank the
/// centre panel, the rest split between a row above and a row below, the gutters leaning alternately.
let pickLayout: (slots: [CGPath], centre: CGPath) = {
    let n = Universe.offered.count, edge = 26.0, gut = 18.0, lean = 27.0, w = Double(W)
    struct Band { let b0, b1, t0, t1: Double
        func bottom(_ x: Double) -> Double { b0 + (b1 - b0) * x / Double(W) }
        func top(_ x: Double) -> Double { t0 + (t1 - t0) * x / Double(W) } }
    func split(_ band: Band, _ weights: [Double]) -> [CGPath] {
        let total = weights.reduce(0, +), free = w - edge * 2 - gut * Double(weights.count - 1)
        var x = edge, out: [CGPath] = []
        for (k, wt) in weights.enumerated() {
            let wpx = free * wt / total
            let l = k == 0 ? 0 : (k % 2 == 0 ? lean : -lean), r = k == weights.count - 1 ? 0 : ((k + 1) % 2 == 0 ? lean : -lean)
            let x0b = x - l, x0t = x + l, x1b = x + wpx - r, x1t = x + wpx + r
            let p = CGMutablePath()
            p.addLines(between: [CGPoint(x: x0b, y: band.bottom(x0b)), CGPoint(x: x1b, y: band.bottom(x1b)),
                                 CGPoint(x: x1t, y: band.top(x1t)), CGPoint(x: x0t, y: band.top(x0t))])
            p.closeSubpath(); out.append(p)
            x += wpx + gut
        }
        return out
    }
    let flanks = n >= 3 ? 2 : 0, rest = n - flanks, topN = (rest + 1) / 2, botN = rest - topN
    let top = Band(b0: 742, b1: 790, t0: Double(H) - edge, t1: Double(H) - edge)
    let mid = Band(b0: 380, b1: 428, t0: 722, t1: 770)
    let bot = Band(b0: edge, b1: edge, t0: 360, t1: 408)
    var slots: [CGPath] = []
    if topN > 0 { slots = split(top, (0..<topN).map { [0.8, 1.3, 1.0][$0 % 3] }) }
    let middle = split(mid, flanks == 2 ? [0.8, 2.0, 0.8] : [1])
    if flanks == 2 { slots += [middle[0], middle[2]] }
    if botN > 0 { slots += split(bot, (0..<botN).map { [1.2, 0.9, 1.0][$0 % 3] }) }
    return (slots, flanks == 2 ? middle[1] : middle[0])
}()

func pickYourUniverse(_ ctx: CGContext, local l: Double, t: Double) {
    ctx.setFillColor(hexCG(0xFDFCF6)); ctx.fill(fullRect)
    let all = Universe.offered, step = min(0.45, 2.4 / Double(all.count))
    let lands = all.indices.map { 0.5 + Double($0) * step }
    // The centre panel first: a turning red sunburst, ONE APP. and PICK YOUR UNIVERSE.
    let cp = pickLayout.centre, cb = cp.boundingBox
    ctx.saveGState(); ctx.addPath(cp); ctx.clip()
    pickFill(ctx, cb, kind: 2, pair: (0xE8322E, 0xFF6A5A), spin: t * 0.08)
    ctx.restoreGState()
    ctx.addPath(cp); ctx.setStrokeColor(inkColor); ctx.setLineWidth(8); ctx.strokePath()
    let head = backOut((l - 0.05) / 0.35)
    if l > 0.05 {
        ctx.saveGState()
        ctx.translateBy(x: cb.midX, y: cb.midY - 20); ctx.rotate(by: 0.05); ctx.scaleBy(x: CGFloat(head), y: CGFloat(head))
        inkLettered("ONE APP.", CGPoint(x: 0, y: 92), size: 60, color: .white, kern: 4)
        inkLettered("PICK YOUR UNIVERSE", CGPoint(x: 0, y: 0), size: 104, color: yellow, kern: 4)
        ctx.restoreGState()
    }
    for (i, u) in all.enumerated() where i < pickLayout.slots.count {
        let at = lands[i]
        guard l > at else { continue }
        let v = pickVerse(u), path = pickLayout.slots[i], r = path.boundingBox
        let f = backOut((l - at) / 0.35)
        ctx.saveGState()
        ctx.translateBy(x: r.midX, y: r.midY)
        ctx.rotate(by: CGFloat((1 - f) * (i % 2 == 0 ? 0.12 : -0.12)))
        ctx.scaleBy(x: CGFloat(1.5 - 0.5 * f), y: CGFloat(1.5 - 0.5 * f))
        ctx.translateBy(x: -r.midX, y: -r.midY)
        ctx.setAlpha(CGFloat(clamp((l - at) / 0.12)))
        ctx.saveGState(); ctx.addPath(path); ctx.clip()
        pickFill(ctx, r, kind: i % 5, pair: v.pop)
        // the face-off, as the app draws it: the hero on the left, the villain on the right, the fight between them
        let scale = min(7.0, r.height * 0.62 / 44)
        onStage(ctx, r, scale: scale, ground: (r.height - 34) / scale) {
            let mid = stageW / S / 2
            var (h, vl) = versus(v.hero, mid - 22, v.villain, mid + 22)
            h.label = nil; vl.label = nil
            draw(h, ctx, t: t); draw(vl, ctx, t: t)
            drawFX([(h, vl)], ctx, t: t)
        }
        ctx.restoreGState()
        ctx.addPath(path); ctx.setStrokeColor(inkColor); ctx.setLineWidth(8); ctx.strokePath()
        captionBox(u.title.uppercased(), ctx, center: CGPoint(x: r.minX + 70 + Double(u.title.count) * 10, y: r.maxY - 48), size: 24)
        ctx.restoreGState()
        // its sound word, popping over the border and fading
        let w = l - at
        if w < 0.9 {
            let p = backOut(w / 0.2), fade = 1 - clamp((w - 0.6) / 0.3)
            let c = CGPoint(x: r.maxX - 125, y: r.midY + 30)
            ctx.saveGState(); ctx.setAlpha(CGFloat(fade))
            starburst(ctx, center: c, inner: 55 * p, outer: 95 * p, spikes: 12, color: hexCG(v.pop.1), spin: Double(i))
            ctx.restoreGState()
            inkLettered(v.sound, c, size: CGFloat(44 * p), color: NSColor(srgbRed: 0.85, green: 0.12, blue: 0.12, alpha: 1), alpha: fade, kern: 2)
        }
    }
}

/// A showcase's title card: the universe's name in a caption box and a line about it.
func showcaseTitle(_ ctx: CGContext, _ u: Universe, _ line: String, local l: Double) {
    let f = backOut((l - 0.4) / 0.35), fade = 1 - clamp((l - 4.2) / 0.5)
    guard l > 0.4, fade > 0 else { return }
    ctx.saveGState(); ctx.setAlpha(CGFloat(fade))
    ctx.translateBy(x: 960, y: 990); ctx.scaleBy(x: CGFloat(f), y: CGFloat(f)); ctx.translateBy(x: -960, y: -990)
    captionBox(u.title.uppercased(), ctx, center: CGPoint(x: 960, y: 990), size: 54)
    ctx.restoreGState()
    let sub = attributed(line, size: 40, weight: .bold, color: .white, alpha: fade * clamp((l - 0.7) / 0.3))
    sub.draw(at: NSPoint(x: (Double(W) - sub.size().width) / 2, y: 885))
}

/// The promo's opening, in the style of Doctor Clawd's title sequence: down the time vortex, with the police box and
/// every universe's legend tumbling up out of it and past us, then CLAWD CLASH flying up out of the eye of it and landing
/// with a bang in the middle of the screen. They come out in waves of two from opposite sides, the second a beat
/// later, on its own curve and at its own speed, so a new universe adds to a wave instead of making the intro longer.
var introTumblers: [Cast?] { [nil] + Universe.offered.map { Theme.of($0).legend } }
let introPerWave = 2, introWave = 1.25, introFly = 2.7

/// When tumbler `i` sets off and how long it takes to fly past.
func introTiming(_ i: Int) -> (start: Double, fly: Double) {
    let wave = i / introPerWave, j = i % introPerWave
    return (0.3 + Double(wave) * introWave + Double(j) * 0.35, introFly + Double(j) * 0.35)
}
var introSlam: Double {
    let last = introTumblers.indices.map { introTiming($0).start + introTiming($0).fly }.max() ?? 0
    return last + 0.4
}

func clashIntro(_ ctx: CGContext, local l: Double, t: Double) {
    let c = CGPoint(x: Double(fxW) / 2 + sin(l * 0.7) * 14, y: Double(fxH) / 2 + cos(l * 0.5) * 6)
    let slam = introSlam, since = l - slam, shake = since > 0 && since < 0.3 ? (0.3 - since) * 60 : 0
    ctx.saveGState(); ctx.translateBy(x: sin(t * 80) * shake, y: cos(t * 70) * shake)
    if let img = lowRes({ g in
        vortexTunnel(g, t: l + 2, glow: clamp(l / 0.5), centre: c)
        if l > 0.1 && l < 0.4 { vortexLightning(g, seed: 11, to: c, alpha: 1 - (l - 0.1) / 0.3) }
    }) { ctx.saveGState(); ctx.interpolationQuality = .none; ctx.draw(img, in: fullRect.insetBy(dx: -40, dy: -40)); ctx.restoreGState() }
    let eye = CGPoint(x: c.x * 6, y: c.y * 6), lamp = Int(l * 5) % 2 == 0
    for (i, who) in introTumblers.enumerated() {
        let (start, fly) = introTiming(i), f = (l - start) / fly
        guard f > 0, f < 1 else { continue }
        let wave = i / introPerWave, j = i % introPerWave
        // opposite sides of the wave, but not a mirror: its own curl, reach and spin
        let z = pow(f, 2.4)
        let a = Double(wave) * 2.1 + 0.6 + Double(j) * (2 * .pi / Double(introPerWave) + 0.35) + z * (j == 0 ? 0.7 : -0.45)
        let p = CGPoint(x: eye.x + cos(a) * z * (1100 - Double(j) * 120), y: eye.y + sin(a) * z * (700 + Double(j) * 90))
        let h = 20 + z * (1000 - Double(j) * 140), turn = sin(l * (0.9 + 0.4 * Double(j)) + Double(i)) * (0.6 - 0.25 * Double(j)) + Double(i) * 0.4
        guard let who else { drawBox(ctx, at: p, height: h, turn: 0.5 * sin(l * 1.5), lamp: lamp, alpha: clamp(f * 8)); continue }
        let pc = PixelCanvas(Sprite.width, Sprite.height)
        who.draw(pc, t: l, mode: .working, walking: false, role: .none, asSession: false)   // posed, not practising
        pc.addOutline(C(AI.claude.hex, 0.92))
        guard let b = pc.opaqueBounds(), let img = pc.makeImage()?.cropping(to: b) else { continue }
        let w = h * Double(img.width) / Double(img.height)
        ctx.saveGState(); ctx.interpolationQuality = .none
        ctx.translateBy(x: p.x, y: p.y); ctx.rotate(by: CGFloat(turn)); ctx.setAlpha(CGFloat(clamp(f * 8)))
        ctx.draw(img, in: CGRect(x: -w / 2, y: -h / 2, width: w, height: h))
        ctx.restoreGState()
    }
    // CLAWD CLASH flies up out of the eye, faster and faster, and lands with a bang
    if l > slam - 1.1 {
        let fly = easeIn((l - (slam - 1.1)) / 1.1)
        let s = since < 0 ? CGFloat(0.04 + 0.96 * fly) : CGFloat(1 + 0.12 * sin(min(1, since / 0.35) * .pi) * max(0, 1 - since / 0.35))
        let pull = since < 0 ? 1 - fly : 0
        if since > 0 { ctx.setFillColor(CGColor(gray: 0, alpha: 0.18 * clamp(since / 0.2))); ctx.fill(fullRect) }
        coverWord(ctx, "CLAWD", at: CGPoint(x: lerp(960, eye.x, pull), y: lerp(675, eye.y + 40, pull)), width: 1560, height: 270, angle: 0.05, depth: 14, scale: s)
        coverWord(ctx, "CLASH", at: CGPoint(x: lerp(960, eye.x, pull), y: lerp(415, eye.y - 40, pull)), width: 1680, height: 290, angle: 0.05, depth: 16, scale: s)
    }
    ctx.restoreGState()
    if since > 0 && since < 0.3 { ctx.setFillColor(CGColor(gray: 1, alpha: 0.85 * (1 - since / 0.3))); ctx.fill(fullRect) }   // the flash
}

/// How many universes, in words: "SEVEN", or "Seven" with `capital`.
func universeCount(capital: Bool = false) -> String {
    let n = Universe.offered.count
    let w = ["ZERO", "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "TEN", "ELEVEN", "TWELVE"]
    let s = n < w.count ? w[n] : "\(n)"
    return capital ? s.prefix(1) + s.dropFirst().lowercased() : s
}

/// Choose your universe, read as a comic: characters from every universe run along the desktop under the title, a
/// page with a panel per universe slams down over them, and the camera reads it panel by panel, each its universe's big
/// moment, then pulls back to the whole page. The layout and the reading grow with the universe list.
var chooseRunners: [Cast] {
    Universe.offered.flatMap { u -> [Cast] in
        let lead = Theme.of(u).legend
        return (0..<3).map { Cast(universe: u, isDark: false, index: $0) }.filter { $0 != lead }.prefix(2).map { $0 }
    }
}

/// Each universe's big moment, from its own trailer, and its sound word.
func setPiece(_ u: Universe) -> (word: String, draw: (CGContext, Double, Double) -> Void) {
    switch u {
    case .starWars: return ("VWOOM!", { starClawsShowcase($0, local: 1.6 + $1, t: $2) })
    case .marvel: return ("KAPOW!", { clawvelShowcase($0, local: 3.2 + $1, t: $2) })
    case .dc: return ("KRAK!", { detectiveShowcase($0, local: 2.2 + $1, t: $2) })
    case .doctor: return ("VWORP!", { doctorInvasion($0, local: 3.3 + $1, t: $2) })
    case .clawdFiles: return ("HMMMM!", { filesWoods($0, local: 3.2 + $1, t: $2) })
    case .clawdberg: return ("88 MPH!", { clawdbergHillValley($0, local: 3.0 + $1, t: $2) })
    case .middleEarth: return ("DOOM!", { ringsBridge($0, local: 2.8 + $1, t: $2) })
    case .slayer: return ("THWACK!", { slayerHomecoming($0, local: homeCut + homeFight - 0.6 + $1, t: $2) })
    default: preconditionFailure("no promo data for \(u.title) here yet: the universe-modules plan moves it into its folder")
    }
}

/// The pages, in page units (y up), screen-shaped: up to six panels each, the universes shared out evenly between as
/// many pages as that takes. On each page two rows split by a slanted divider, each row split by slanted gutters that
/// never line up with the other row's.
let pageW = 3200.0, pageH = 1800.0
struct PagePanel { let u: Universe; let corners: [CGPoint]
    var path: CGPath { let p = CGMutablePath(); p.addLines(between: corners); p.closeSubpath(); return p }
    var rect: CGRect { path.boundingBoxOfPath }
}

/// Where two lines (each a point and a direction) cross.
func crossing(_ p: CGPoint, _ d: CGVector, _ q: CGPoint, _ e: CGVector) -> CGPoint {
    let den = d.dx * e.dy - d.dy * e.dx
    let t = ((q.x - p.x) * e.dy - (q.y - p.y) * e.dx) / den
    return CGPoint(x: p.x + d.dx * t, y: p.y + d.dy * t)
}

/// One page's panels, for `shown`, its divider rising (`page` even) or falling, so facing pages differ.
func pageLayout(_ shown: [Universe], page: Int) -> [PagePanel] {
    let n = shown.count, top = (n + 1) / 2, rows = [top, n - top]
    let m = 70.0, gap = 46.0
    let mid = CGPoint(x: pageW / 2, y: pageH / 2), slope = CGVector(dx: 1, dy: page % 2 == 0 ? 0.05 : -0.045)
    let lean = page % 2 == 0 ? [CGVector(dx: 0.2, dy: 1), CGVector(dx: 0.16, dy: 1)] : [CGVector(dx: -0.17, dy: 1), CGVector(dx: 0.21, dy: 1)]
    let weights = page % 2 == 0 ? [[1.0, 1.3, 0.9], [1.25, 0.85, 1.15]] : [[1.3, 0.9, 1.1], [0.85, 1.2, 1.0]]
    var panels: [PagePanel] = [], k = 0
    for (r, count) in rows.enumerated() where count > 0 {
        let full = rows[1] == 0                                                     // one row: the whole page
        let topEdge = r == 0 ? (CGPoint(x: 0, y: pageH - m), CGVector(dx: 1, dy: 0)) : (CGPoint(x: mid.x, y: mid.y - gap / 2), slope)
        let botEdge = r == 0 && !full ? (CGPoint(x: mid.x, y: mid.y + gap / 2), slope) : (CGPoint(x: 0, y: m), CGVector(dx: 1, dy: 0))
        let ws = (0..<count).map { weights[r][$0 % weights[r].count] }, sum = ws.reduce(0, +)
        let rowMid = r == 0 ? (full ? pageH / 2 : (pageH - m + mid.y) / 2) : (mid.y + m) / 2
        var cuts = [m - gap / 2], x = m
        for c in 0..<count { x += (pageW - 2 * m) * ws[c] / sum; cuts.append(c == count - 1 ? pageW - m + gap / 2 : x) }
        for c in 0..<count {
            let left = c == 0 ? (CGPoint(x: m, y: 0), CGVector(dx: 0, dy: 1)) : (CGPoint(x: cuts[c] + gap / 2, y: rowMid), lean[r])
            let right = c == count - 1 ? (CGPoint(x: pageW - m, y: 0), CGVector(dx: 0, dy: 1)) : (CGPoint(x: cuts[c + 1] - gap / 2, y: rowMid), lean[r])
            let corners = [crossing(left.0, left.1, topEdge.0, topEdge.1), crossing(right.0, right.1, topEdge.0, topEdge.1),
                           crossing(right.0, right.1, botEdge.0, botEdge.1), crossing(left.0, left.1, botEdge.0, botEdge.1)]
            panels.append(PagePanel(u: shown[k], corners: corners)); k += 1
        }
    }
    return panels
}

let comicPages: [[PagePanel]] = {
    let shown = Universe.offered, count = (shown.count + 5) / 6, per = (shown.count + count - 1) / count
    return stride(from: 0, to: shown.count, by: per).enumerated().map { p, s in pageLayout(Array(shown[s..<min(shown.count, s + per)]), page: p) }
}()

/// What the camera looks at: a whole page, or one panel on it.
enum PageView { case whole(Int), panel(Int, Int) }
/// The camera's stops in order: each held from `from` to `to`; between two stops it moves, or, into a new page, the
/// page turns.
struct PageKey { let view: PageView; let from: Double; let to: Double; let turn: Bool }
let pageDrop = 2.4, pageHold = 0.95, pageMove = 0.4, pageTurn = 0.95
let pageKeys: [PageKey] = {
    var keys: [PageKey] = [], t = pageDrop + 0.5
    for (p, page) in comicPages.enumerated() {
        let look = p == 0 ? 0.5 : 0.35
        keys.append(PageKey(view: .whole(p), from: t, to: t + look, turn: p > 0)); t += look + pageMove
        for j in page.indices { keys.append(PageKey(view: .panel(p, j), from: t, to: t + pageHold, turn: false)); t += pageHold + pageMove }
        let last = p == comicPages.count - 1
        keys.append(PageKey(view: .whole(p), from: t, to: t + (last ? 2.6 : 0.3), turn: false)); t += last ? 2.6 : 0.3 + pageTurn
    }
    return keys
}()
/// When the camera gets to universe `i`'s panel, and when it's back on the last page as a whole.
func pageArrive(_ i: Int) -> Double {
    var k = 0
    for key in pageKeys { if case .panel = key.view { if k == i { return key.from }; k += 1 } }
    return 0
}
var pageBack: Double { pageKeys.last!.from }
var chooseLength: Double { pageKeys.last!.to }
/// When the pages turn.
var pageTurns: [Double] { pageKeys.filter(\.turn).map { $0.from - pageTurn } }

typealias Camera = (c: CGPoint, s: Double, turn: Double)
func camera(_ v: PageView) -> Camera {
    switch v {
    case .whole: return (CGPoint(x: pageW / 2, y: pageH / 2), Double(W) / pageW * 0.97, 0)
    case .panel(let p, let j):
        let r = comicPages[p][j].rect
        return (CGPoint(x: r.midX, y: r.midY), min(Double(W) * 0.9 / r.width, Double(H) * 0.9 / r.height), 0)
    }
}
func blend(_ a: Camera, _ b: Camera, _ f: Double) -> Camera {
    let e = f * f * (3 - 2 * f)
    // zooming feels even in log scale; a little pull back and a lean mid-move, like a camera finding the next panel
    let s = exp(lerp(log(a.s), log(b.s), e)) * (1 - 0.12 * sin(.pi * f))
    let lean = (b.c.x > a.c.x ? -1.0 : 1.0) * 0.05 * sin(.pi * f)
    return (CGPoint(x: lerp(a.c.x, b.c.x, e), y: lerp(a.c.y, b.c.y, e)), s, lerp(a.turn, b.turn, e) + lean)
}
func page(of v: PageView) -> Int { switch v { case .whole(let p), .panel(let p, _): return p } }

/// One page through the camera: the paper, its border, and every panel playing its universe's big moment.
func drawPage(_ ctx: CGContext, _ p: Int, cam: Camera, zoom: Double = 1, tilt: Double = 0, l: Double, t: Double) {
    ctx.saveGState()
    ctx.translateBy(x: 960, y: 540); ctx.rotate(by: CGFloat(cam.turn + tilt))
    ctx.scaleBy(x: CGFloat(cam.s * zoom), y: CGFloat(cam.s * zoom)); ctx.translateBy(x: -cam.c.x, y: -cam.c.y)
    let sheet = CGRect(x: 0, y: 0, width: pageW, height: pageH)
    ctx.setFillColor(CGColor(gray: 0, alpha: 0.5)); ctx.fill(sheet.offsetBy(dx: 24, dy: -24))
    ctx.setFillColor(CGColor(gray: 0.96, alpha: 1)); ctx.fill(sheet)
    ctx.setStrokeColor(inkColor); ctx.setLineWidth(14); ctx.stroke(sheet.insetBy(dx: 30, dy: 30))
    let first = comicPages.prefix(p).map(\.count).reduce(0, +)
    let view = CGRect(x: cam.c.x - 960 / (cam.s * zoom), y: cam.c.y - 540 / (cam.s * zoom), width: 1920 / (cam.s * zoom), height: 1080 / (cam.s * zoom))
    for (j, panel) in comicPages[p].enumerated() {
        let i = first + j, piece = setPiece(panel.u), r = panel.rect, shape = panel.path
        ctx.saveGState(); ctx.translateBy(x: 16, y: -16); ctx.addPath(shape); ctx.setFillColor(CGColor(gray: 0, alpha: 1)); ctx.fillPath(); ctx.restoreGState()
        // only the panels in view get their scene drawn; before the camera gets there it holds a moment of the action
        if r.insetBy(dx: -300, dy: -300).intersects(view), let full = shotImage({ piece.draw($0, max(0.8, l - pageArrive(i) + 0.6), t) }) {
            let h = min(Double(H), Double(W) * Double(r.height) / Double(r.width)), w = h * Double(r.width) / Double(r.height)
            if let img = full.cropping(to: CGRect(x: (Double(W) - w) / 2, y: (Double(H) - h) / 2, width: w, height: h)) {
                ctx.saveGState(); ctx.addPath(shape); ctx.clip()
                ctx.interpolationQuality = cam.s * zoom > 0.9 ? .none : .high; ctx.draw(img, in: r)
                ctx.restoreGState()
            }
        }
        ctx.addPath(shape); ctx.setStrokeColor(inkColor); ctx.setLineWidth(16); ctx.strokePath()
        let label = NSAttributedString(string: panel.u.title.uppercased(), attributes: [.font: NSFont.systemFont(ofSize: 40, weight: .heavy)]).size().width
        captionBox(panel.u.title.uppercased(), ctx, center: CGPoint(x: max(panel.corners[0].x, panel.corners[3].x) + 60 + label / 2,
                                                                     y: min(panel.corners[0].y, panel.corners[1].y) - 50), size: 40)
        // the sound word pops as the camera gets there
        let w = l - pageArrive(i) + 0.1
        if w > 0 && w < pageHold + pageMove {
            let pop = backOut(w / 0.2), a = 1 - clamp((w - pageHold) / 0.3)
            ctx.saveGState()
            ctx.translateBy(x: r.maxX - r.width * 0.24, y: r.minY + r.height * 0.2); ctx.rotate(by: i % 2 == 0 ? 0.12 : -0.12)
            ctx.scaleBy(x: CGFloat(pop), y: CGFloat(pop))
            inkLettered(piece.word, .zero, size: CGFloat(min(170, r.height * 0.22)), color: yellow, alpha: a, kern: 6)
            ctx.restoreGState()
        }
    }
    ctx.restoreGState()
}

/// The part of polygon `poly` on the side of the line through `a` (direction `u`) where `keepLeft` says.
func clipPolygon(_ poly: [CGPoint], _ a: CGPoint, _ u: CGVector, keepLeft: Bool) -> [CGPoint] {
    let side = { (p: CGPoint) -> Double in let s = Double(u.dx * (p.y - a.y) - u.dy * (p.x - a.x)); return keepLeft ? s : -s }
    var out: [CGPoint] = []
    for i in poly.indices {
        let p = poly[i], q = poly[(i + 1) % poly.count], sp = side(p), sq = side(q)
        if sp >= 0 { out.append(p) }
        if (sp >= 0) != (sq >= 0) {
            let f = sp / (sp - sq)
            out.append(CGPoint(x: p.x + (q.x - p.x) * f, y: p.y + (q.y - p.y) * f))
        }
    }
    return out
}

/// `p` mirrored across the line through `a` with unit direction `u`.
func mirrored(_ p: CGPoint, _ a: CGPoint, _ u: CGVector) -> CGPoint {
    let dx = p.x - a.x, dy = p.y - a.y, d = dx * u.dx + dy * u.dy
    return CGPoint(x: a.x + 2 * d * u.dx - dx, y: a.y + 2 * d * u.dy - dy)
}

/// A page turning over, right to left, `k` 0…1, curling back from its right edge: the fold sweeps across at a slant,
/// the new page shows behind it with the curl's shadow on it, and the curled-over flap is the paper back of the old one.
func turnPage(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double) {
    let e = k * k * (3 - 2 * k), lean = 0.28
    let len = sqrt(1 + lean * lean), u = CGVector(dx: lean / len, dy: 1 / len)          // the fold, leaning right at the top
    let a = CGPoint(x: lerp(Double(W) + 60, -Double(H) * lean - 120, e), y: 0)
    let sheet = [CGPoint(x: 0, y: 0), CGPoint(x: W, y: 0), CGPoint(x: W, y: H), CGPoint(x: 0, y: H)]
    func path(_ pts: [CGPoint]) -> CGPath { let p = CGMutablePath(); if !pts.isEmpty { p.addLines(between: pts); p.closeSubpath() }; return p }
    ctx.draw(new, in: fullRect)
    // the old page, what's left of it on this side of the fold
    let stays = clipPolygon(sheet, a, u, keepLeft: true)
    if stays.count > 2 { ctx.saveGState(); ctx.addPath(path(stays)); ctx.clip(); ctx.draw(old, in: fullRect); ctx.restoreGState() }
    // the curl's shadow on the new page, just past the fold
    let n = CGVector(dx: u.dy, dy: -u.dx)                                                     // pointing right, away from the old page
    let shadow = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [CGColor(gray: 0, alpha: 0.5), CGColor(gray: 0, alpha: 0)] as CFArray, locations: [0, 1])!
    let turned = clipPolygon(sheet, a, u, keepLeft: false)
    if turned.count > 2 {   // (clipping to nothing would clip nothing away)
        ctx.saveGState(); ctx.addPath(path(turned)); ctx.clip()
        ctx.drawLinearGradient(shadow, start: a, end: CGPoint(x: a.x + n.dx * 140, y: a.y + n.dy * 140), options: [.drawsBeforeStartLocation])
        ctx.restoreGState()
    }
    // the flap: the turned part, mirrored over the fold, its paper back lit at the fold and shaded at its edge
    let flap = turned.map { mirrored($0, a, u) }
    guard flap.count > 2 else { return }
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: -10, height: -6), blur: 30, color: CGColor(gray: 0, alpha: 0.5))
    ctx.addPath(path(flap)); ctx.setFillColor(CGColor(gray: 0.86, alpha: 1)); ctx.fillPath()
    ctx.restoreGState()
    ctx.saveGState(); ctx.addPath(path(flap)); ctx.clip()
    let paper = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [CGColor(gray: 1, alpha: 0.9), CGColor(gray: 0.7, alpha: 0.9)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(paper, start: a, end: CGPoint(x: a.x - n.dx * 700, y: a.y - n.dy * 700), options: [.drawsAfterEndLocation])
    ctx.restoreGState()
    ctx.addPath(path(flap)); ctx.setStrokeColor(CGColor(gray: 0.55, alpha: 1)); ctx.setLineWidth(3); ctx.strokePath()
}

func chooseUniverse(_ ctx: CGContext, local l: Double, t: Double) {
    // the runners, along the bottom of the desktop, under the title
    if l < pageDrop + 0.5 {
        desktop(ctx, dim: 1)
        for (i, who) in chooseRunners.enumerated() {
            let x = -40 + (l - Double(i) * 0.15) * 170
            guard x > -40, x < 360 else { continue }
            draw(Actor(cast: who, x: x, mode: .idle, walking: true), ctx, t: t * 1.6 + Double(i) * 0.2)
        }
        let f = backOut((l - 0.15) / 0.4)
        if f > 0 {
            ctx.saveGState(); ctx.translateBy(x: 960, y: 640); ctx.scaleBy(x: CGFloat(f), y: CGFloat(f)); ctx.rotate(by: 0.035)
            inkLettered("CHOOSE YOUR", CGPoint(x: 0, y: 110), size: 120, color: yellow, kern: 8)
            inkLettered("UNIVERSE", CGPoint(x: 0, y: -40), size: 190, color: yellow, kern: 10)
            ctx.restoreGState()
        }
    }
    guard l > pageDrop else { return }
    if l > pageDrop + 0.5 { halftone(ctx, fullRect, base: CGColor(red: 0.06, green: 0.06, blue: 0.09, alpha: 1), dot: CGColor(red: 0.13, green: 0.13, blue: 0.18, alpha: 1), step: 22) }
    let since = l - pageDrop, shake = since > 0.3 && since < 0.55 ? (0.55 - since) * 50 : 0
    ctx.saveGState(); ctx.translateBy(x: sin(t * 80) * shake, y: cos(t * 70) * shake)
    // where the camera is: on a stop, moving between two, or turning the page
    let next = pageKeys.firstIndex { $0.to > l } ?? pageKeys.count - 1, key = pageKeys[next]
    if l < pageKeys[0].from {                                  // the first page slamming down
        let drop = backOut(since / 0.4)
        ctx.setAlpha(CGFloat(clamp(since / 0.12)))
        drawPage(ctx, 0, cam: camera(.whole(0)), zoom: 1.5 - 0.5 * drop, tilt: (1 - drop) * 0.08, l: l, t: t)
    } else if l >= key.from {
        drawPage(ctx, page(of: key.view), cam: camera(key.view), l: l, t: t)
    } else {
        let prev = pageKeys[next - 1], f = (l - prev.to) / (key.from - prev.to)
        if key.turn,
           let old = shotImage({ drawPage($0, page(of: prev.view), cam: camera(prev.view), l: l, t: t) }),
           let new = shotImage({ drawPage($0, page(of: key.view), cam: camera(key.view), l: l, t: t) }) {
            turnPage(ctx, old: old, new: new, k: f)
        } else {
            drawPage(ctx, page(of: key.view), cam: blend(camera(prev.view), camera(key.view), f), l: l, t: t)
        }
    }
    ctx.restoreGState()
    // and the line, once it's back on the last page as a whole
    let f = backOut((l - pageBack - 0.2) / 0.35)
    if f > 0 {
        ctx.saveGState(); ctx.translateBy(x: 960, y: 60); ctx.scaleBy(x: CGFloat(f), y: CGFloat(f)); ctx.translateBy(x: -960, y: -60)
        captionBox("ONE APP. \(universeCount()) UNIVERSES. PICK YOURS.", ctx, center: CGPoint(x: 960, y: 60), size: 46)
        ctx.restoreGState()
    }
}

/// Where the comic page ends: everything after it moves with the number of universes.
var afterChoose: Double { 16.5 + chooseLength }

let promoShots: [Shot] = [
    Shot(name: "meanwhile", start: 0, end: 3.0, into: .cut) { ctx, local, t in
        ctx.setFillColor(CGColor(gray: 0, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let line = "MEANWHILE, IN A TERMINAL NEAR YOU..."
        let n = Int(clamp((local - 0.3) / 1.6) * Double(line.count))
        let a = 1 - clamp((local - 2.6) / 0.35)
        if n > 0 { captionBox(String(line.prefix(n)), ctx, center: CGPoint(x: Double(W) / 2, y: Double(H) / 2), size: 54, alpha: a) }
    },
    // Down the time vortex: a character from every universe tumbles past, and CLAWD CLASH lands with a bang.
    Shot(name: "worlds", start: 3.0, end: 12.5, into: .cut) { ctx, local, t in clashIntro(ctx, local: local, t: t) },
    Shot(name: "hook", start: 12.5, end: 16.5) { ctx, local, t in
        let zoom = 1 + 0.03 * local
        ctx.saveGState()
        ctx.translateBy(x: Double(W) / 2, y: Double(H) / 2); ctx.scaleBy(x: zoom, y: zoom)
        ctx.translateBy(x: -Double(W) / 2, y: -Double(H) / 2)
        desktop(ctx, dim: 0)
        ctx.restoreGState()
        caption("Three AIs. Nine agents. One very confused human.", ctx, local: local, start: 0.05, y: 860, size: 60)
        caption("Sound familiar?", ctx, local: local, start: 0.7, y: 120, size: 76, color: yellow)
    },
    // Choose your universe: everyone runs past, a comic page slams down, and the camera reads it panel by panel.
    Shot(name: "choose", start: 16.5, end: afterChoose) { ctx, local, t in chooseUniverse(ctx, local: local, t: t) },
    // The features, one each in the newest universes, as their own trailers show them.
    Shot(name: "status", start: afterChoose, end: afterChoose + 4.5, into: .trip(ComicTransition(FilesTrip(kind: .classifiedFile)))) { ctx, local, t in
        filesShots.first { $0.name == "status" }!.render(ctx, local, t)
    },
    Shot(name: "agents", start: afterChoose + 4.5, end: afterChoose + 9.0, into: .trip(ComicTransition(ClawdbergTrip(kind: .mapRoute)))) { ctx, local, t in
        clawdbergShots.first { $0.name == "agents" }!.render(ctx, local, t)
    },
    Shot(name: "window", start: afterChoose + 9.0, end: afterChoose + 14.5, into: .middleEarth(RingsTrip(kind: .map))) { ctx, local, t in
        ringsShots.first { $0.name == "window" }!.render(ctx, local, t)
    },
    // Random: the whole window changes universe on its own, each time with that universe's transition.
    Shot(name: "random1", start: afterChoose + 14.5, end: afterChoose + 16.6) { ctx, local, t in windowShot(ctx, .middleEarth, local: local + 3, t: t, rise: false, at: .prancingPony) },
    Shot(name: "random2", start: afterChoose + 16.6, end: afterChoose + 18.9, into: .trip(ComicTransition(DoctorTrip(kind: .vortex))), inWindow: true) { ctx, local, t in
        windowShot(ctx, .doctor, local: local + 3, t: t, rise: false, at: .consoleRoom)
    },
    Shot(name: "random3", start: afterChoose + 18.9, end: afterChoose + 21.0, into: .starWars(clock: false), inWindow: true) { ctx, local, t in
        windowShot(ctx, .starWars, local: local + 3, t: t, rise: false)
    },
    // Clawd Royale: the emblems collide, then everyone at once, each as themselves.
    Shot(name: "royale", start: afterChoose + 21.0, end: afterChoose + 24.0, into: .cut) { ctx, local, t in royaleCollide(ctx, local: local, t: t) },
    Shot(name: "crossover", start: afterChoose + 24.0, end: afterChoose + 28.5, into: .marvel(ComicTrip(kind: .burst, sound: .thwip))) { ctx, local, t in
        let (fox, dalick) = versus(.hero(FilesHero.foxClawder), 30, .villain(DoctorVillain.dalick), 96)
        let (bat, vapor) = versus(.hero(DCHero.batman), 150, .villain(SWVillain.vader), 207)
        let (gandclawd, thanoz) = versus(.hero(RingsHero.gandalf), 250, .villain(MarvelVillain.thanos), 306)
        let swing = webSwing(local, start: 0.7)
        royaleScene(ctx, .cantina, t: t, fights: [(fox, dalick), (bat, vapor), (gandclawd, thanoz)], also: swing.map { [$0.actor] } ?? [])
        let bf = (local - 1.2) / 2.4                                // E.Clawd's bike, flying the other way over everyone
        if bf > 0 && bf < 1 {
            let c = PixelCanvas(Ride.width, Ride.moonBike.canvasHeight)
            drawRide(c, .moonBike, ramp: 0, engines: true, gear: false); c.flipHorizontally(); c.addOutline(C(0xFFFFFF, 0.92))
            if let img = c.makeImage() {
                ctx.saveGState(); ctx.interpolationQuality = .none
                ctx.draw(img, in: CGRect(x: lerp(Double(W) + 60, -Double(Ride.width) * 6 - 60, bf), y: 560 + sin(bf * .pi) * 60,
                                         width: Double(Ride.width) * 6, height: Double(c.h) * 6))
                ctx.restoreGState()
            }
        }
        if let s = swing {                                          // his web line, from the raised hand up out of the frame
            let web = PixelCanvas(fxW, fxH), hand = s.actor.fighter.point(41, 22)
            web.glowLine(hand.x, hand.y, s.anchor.x, s.anchor.y, core: C(0xF4F4F8, 0.9), glow: C(0xFFFFFF, 0), coreR: 0.35, glowR: 0.4)
            blit(web, ctx)
        }
        badge("CLAWD ROYALE", ctx, alpha: clamp(local / 0.3))
        caption("Nobody asked who'd win. We're answering anyway.", ctx, local: local, start: 0.8, y: 905, size: 58)
        caption("Settings → Universe → Clawd Royale. A new place every ten minutes.", ctx, local: local, start: 1.6, y: 840, size: 38, color: yellow, weight: .bold)
    },
    Shot(name: "endcard", start: afterChoose + 28.5, end: afterChoose + 33.5) { ctx, local, t in
        coverPanels(ctx, t: t, fighters: false, dim: 0.45)
        let f = backOut((local - 0.2) / 0.5)
        if let icon = appIcon, local > 0.2 {
            let s = 500 * f
            ctx.saveGState(); ctx.interpolationQuality = .high
            ctx.draw(icon, in: CGRect(x: 960 - s / 2, y: 660 - s / 2, width: s, height: s))
            ctx.restoreGState()
        }
        let shown = Universe.offered
        for (i, u) in shown.enumerated() {
            let e = backOut((local - 0.5 - Double(i) * 0.08) / 0.35)
            if e > 0 { emblem(u, ctx, center: CGPoint(x: 960 + (Double(i) - Double(shown.count - 1) / 2) * 170, y: 335), px: 4 * e) }
        }
        caption("Have fun. Keep track.", ctx, local: local, start: 0.8, y: 190, size: 64)
        caption("Pick a universe, or let them collide · free for macOS · github.com/rodclemen/clawd-clash", ctx, local: local, start: 1.1, y: 120, size: 34,
                color: NSColor(white: 0.88, alpha: 1), weight: .bold)
    },
]

let promoOverlays: [Overlay] = [
    Overlay(start: afterChoose + 14.5, end: afterChoose + 21.0) { ctx, l in
        badge("RANDOM · EVERY 5 MIN", ctx, alpha: 1)
        caption("Can't decide? Random switches the whole window", ctx, local: l, start: 0.2, y: 950, size: 50)
        caption("to a new universe every few minutes.", ctx, local: l, start: 0.4, y: 885, size: 40, color: yellow, weight: .bold)
    },
]

// MARK: The blooper reel


/// Thorr's hammer, on its own, `k` sprite pixels a pixel: a stone head and a wrapped handle.
func hammer(_ ctx: CGContext, x: Double, y: Double, k: Double, tilt: Double) {
    let c = PixelCanvas(16, 18)
    c.rect(1, 1, 14, 7, C(0x8A8C92)); c.rect(1, 1, 14, 2, C(0xB8BAC0)); c.rect(1, 7, 14, 1, C(0x5A5C62))
    c.rect(7, 8, 3, 9, C(0x6A4428)); for y in stride(from: 9, to: 17, by: 2) { c.rect(7, y, 3, 1, C(0x8A6038)) }
    c.addOutline(C(0xFFFFFF, 0.92))
    guard let img = c.makeImage() else { return }
    ctx.saveGState(); ctx.interpolationQuality = .none
    ctx.translateBy(x: x * 6, y: Double(H) - y * 6); ctx.rotate(by: CGFloat(tilt))
    ctx.draw(img, in: CGRect(x: -8 * k * 6, y: -9 * k * 6, width: 16 * k * 6, height: 18 * k * 6))
    ctx.restoreGState()
}

/// The TARDIS standing at `x` (fx units) with its foot on `ground`, `door` 0…1 open, its lamp lit or not.
func standingTardis(_ ctx: CGContext, x: Double, ground: Double, alpha: Double, door: Double, lamp: Bool) {
    guard alpha > 0.01 else { return }
    let c = PixelCanvas(Ride.width, Ride.tardis.canvasHeight)
    drawRide(c, .tardis, ramp: door, engines: lamp, gear: true)
    c.addOutline(C(0xFFFFFF, 0.92))
    guard let img = c.makeImage() else { return }
    ctx.saveGState(); ctx.interpolationQuality = .none; ctx.setAlpha(CGFloat(alpha))
    ctx.draw(img, in: CGRect(x: (x - Double(Ride.width) / 2) * S, y: stageH - ground * S - S, width: Double(Ride.width) * S, height: Double(c.h) * S))
    ctx.restoreGState()
}

/// How solid the TARDIS is `k` (0…1) of the way through wheezing into being: in and out, getting stronger.
func wheezePulse(_ k: Double) -> Double { min(1, max(0, k * (0.75 + 0.25 * sin(k * 7 * .pi)))) }

/// An actor drawn upside down, flipped about the middle of its sprite.
func drawUpsideDown(_ a: Actor, _ ctx: CGContext, t: Double) {
    let mid = stageH - (a.top + 22 * a.k) * S
    ctx.saveGState(); ctx.translateBy(x: 0, y: 2 * mid); ctx.scaleBy(x: 1, y: -1)
    draw(a, ctx, t: t)
    ctx.restoreGState()
}

let blooperShots: [Shot] = [
    // The clapperboard slams in: BLOOPERS.
    Shot(name: "clapper", start: 0, end: 3.0, into: .cut) { ctx, local, t in
        ctx.setFillColor(CGColor(red: 0.08, green: 0.07, blue: 0.1, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        halftone(ctx, CGRect(x: 0, y: 0, width: W, height: H), base: CGColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 1),
                 dot: CGColor(red: 1, green: 0.4, blue: 0.3, alpha: 1), step: 28)
        let drop = easeOut(local / 0.35)
        let open = local < 1.0 ? 1.0 : max(0, 1 - (local - 1.0) / 0.12)
        clapper(ctx, center: CGPoint(x: 960, y: 540 + 700 * (1 - drop)), width: 1100, open: open, take: "1", title: "BLOOPERS")
    },
    // Take 7: the TARDIS lands in the Mos Easy Cantina, in the wrong universe, and then won't take off again.
    Shot(name: "take7", start: 3.0, end: 12.4, into: .cut) { ctx, l, t in
        set(ctx, .cantina, t: t)
        let lamp = Int(l * 5) % 2 == 0
        var alpha = wheezePulse(clamp(l / 1.6)), lit = l < 1.6 && lamp
        if l > 5.4 && l < 6.8 { alpha = 0.55 + 0.45 * abs(cos((l - 5.4) / 1.4 * 3 * .pi)); lit = lamp }     // tries to go, and can't
        let door = min(1, clamp((l - 1.9) / 0.25) * (1 - clamp((l - 5.0) / 0.25)) + clamp((l - 7.0) / 0.25))
        standingTardis(ctx, x: 66, ground: groundY, alpha: alpha, door: door, lamp: lit)
        let vapor = Actor(cast: .villain(SWVillain.vader), x: 240, facing: l > 1.2 ? -1 : 1, mode: .idle)
        draw(vapor, ctx, t: t)
        // the Doctor: out, back in, and out again
        let x = l < 4.6 ? lerp(70, 112, easeOut((l - 2.1) / 0.6)) : l < 7.2 ? lerp(112, 70, easeIn((l - 4.6) / 0.5)) : lerp(70, 104, easeOut((l - 7.2) / 0.5))
        let walking = (l > 2.1 && l < 2.7) || (l > 4.6 && l < 5.1) || (l > 7.2 && l < 7.7)
        var doc = Actor(cast: .hero(DoctorHero.doctorTen), x: x, facing: l > 4.6 && l < 7.2 ? -1 : 1, mode: .idle, walking: walking)
        doc.alpha = (l > 2.05 && l < 5.15) || l > 7.15 ? 1 : 0
        draw(doc, ctx, t: t)
        if l > 2.9 && l < 4.5 { balloon("Ah. Wrong universe.", ctx, center: CGPoint(x: 700, y: 820), tail: headPoint(doc), size: 46) }
        if l > 3.6 && l < 5.3 { balloon("…Is that a phone box?", ctx, center: CGPoint(x: 1300, y: 760), tail: headPoint(vapor), size: 44) }
        if l > 7.7 { balloon("…Handbrake.", ctx, center: CGPoint(x: 700, y: 800), tail: headPoint(doc), size: 46) }
        cutAndSlate(ctx, local: l, at: 8.2, take: "7")
    },
    // Take 12: the Night Beacon over the Doom Moon; the Stormtroupers open fire and miss every shot.
    Shot(name: "take12", start: 12.4, end: 17.6, into: .cut) { ctx, l, t in
        set(ctx, .deathStar, t: t)
        let on = clamp(l / 0.25)
        let sig = CGPoint(x: 1300, y: 860)
        ctx.setFillColor(CGColor(red: 1, green: 0.89, blue: 0.42, alpha: 0.2 * on)); ctx.fillEllipse(in: CGRect(x: sig.x - 260, y: sig.y - 170, width: 520, height: 340))
        ctx.setFillColor(CGColor(red: 1, green: 0.89, blue: 0.42, alpha: 0.9 * on)); ctx.fillEllipse(in: CGRect(x: sig.x - 200, y: sig.y - 130, width: 400, height: 260))
        ctx.addPath(cowlMaskPath(sig, width: 330))                 // the cowl mask in the beacon, as on the icon
        ctx.setFillColor(inkColor.copy(alpha: on) ?? inkColor); ctx.fillPath(using: .evenOdd)
        let bat = Actor(cast: .hero(DCHero.batman), x: 40, mode: .idle)
        draw(bat, ctx, t: t)
        let troopers = [Actor(cast: .villain(SWVillain.trooper), x: 150, mode: .idle, role: .none), Actor(cast: .villain(SWVillain.trooper), x: 200, mode: .idle, role: .none)]
        for tr in troopers { draw(tr, ctx, t: t) }
        let fx = PixelCanvas(fxW, fxH)
        for i in 0..<12 {                                           // wild shots, all wide of the mark
            let born = 0.5 + Double(i) * 0.22, age = l - born
            guard age > 0, age < 0.6 else { continue }
            let from = (troopers[i % 2].x + 18, stageGroundRow - 22), miss = (noise(i * 5) > 0.5 ? 1.0 : -1.0) * (40 + noise(i * 5 + 1) * 40)
            let to = (Double(sig.x) / 6 + miss, -10.0)
            let g = age / 0.6, x = lerp(from.0, to.0, g), y = lerp(from.1, to.1, g)
            fx.glowLine(x - (to.0 - from.0) * 0.05, y - (to.1 - from.1) * 0.05, x, y, core: C(0xFFE0E0), glow: C(0xFF2A2A), coreR: 0.6, glowR: 1.8)
        }
        blit(fx, ctx)
        if l > 2.2 { balloon("You know it's a light, right?", ctx, center: CGPoint(x: 600, y: 640), tail: headPoint(bat), size: 40, width: 700) }
        cutAndSlate(ctx, local: l, at: 4.0, take: "12")
    },
    // Take 15: the Jester Card flips over and Thanoz is on the back.
    Shot(name: "take15", start: 17.6, end: 21.8, into: .cut) { ctx, l, t in
        let jester = Actor(cast: .villain(DCVillain.joker), x: 150, mode: .idle)
        func front() -> CGImage? { shotImage { c in set(c, .gotham, t: t); draw(jester, c, t: t) } }
        func back() -> CGImage? {
            shotImage { c in
                set(c, .titan, t: t)
                draw(Actor(cast: .villain(MarvelVillain.thanos), x: 160, facing: -1, mode: .idle), c, t: t)
                var j = Actor(cast: .villain(DCVillain.joker), x: 50, mode: .idle, bubble: .unknown); j.grow = 0.9
                if l > 2.6 { draw(j, c, t: t) }
            }
        }
        let k = clamp((l - 0.3) / (DCComicWipe.jokerCard.duration * 1.2))
        if let a = front(), let b = back() {
            if k <= 0 { ctx.draw(a, in: CGRect(x: 0, y: 0, width: W, height: H)) }
            else if k >= 1 { ctx.draw(b, in: CGRect(x: 0, y: 0, width: W, height: H)) }
            else { DCComicTrip(kind: .jokerCard).draw(ctx, old: a, new: b, k: k, in: CGRect(x: 0, y: 0, width: W, height: H)) }
        }
        cutAndSlate(ctx, local: l, at: 3.4, take: "15")
    },
    // Take 21: Yodle lifts Thorr's hammer. Thorr stares.
    Shot(name: "take21", start: 21.8, end: 28.0, into: .cut) { ctx, l, t in
        set(ctx, .asgard, t: t)
        let yodle = Actor(cast: .hero(SWHero.yoda), x: 90, mode: .idle)
        let thorr = Actor(cast: .hero(MarvelHero.thor), x: 220, facing: -1, mode: .idle)
        draw(yodle, ctx, t: t); draw(thorr, ctx, t: t)
        let rise = easeOut((l - 0.5) / 1.4)
        hammer(ctx, x: 128, y: stageGroundRow - 4 - rise * 34 + sin(t * 4) * rise * 1.5, k: 1.6, tilt: sin(t * 2) * 0.1 * rise)
        if l > 0.5 {                                                // the Force, twinkling round it
            let sp = PixelCanvas(fxW, fxH), hy = stageGroundRow - 4 - rise * 34
            for i in 0..<8 where sin(t * 5 + Double(i) * 1.7) > 0 {
                sp.px(128 + Int((noise(i * 3) - 0.5) * 30), Int(hy) + Int((noise(i * 3 + 1) - 0.5) * 24), C(0xBFF0FF))
            }
            blit(sp, ctx)
        }
        if l > 1.9 { balloon("…", ctx, center: CGPoint(x: 1500, y: 700), tail: headPoint(thorr), size: 60, width: 200) }
        if l > 3.0 { balloon("Worthy, hmm. Heavy, it is not.", ctx, center: CGPoint(x: 520, y: 760), tail: headPoint(yodle), size: 40, width: 700) }
        cutAndSlate(ctx, local: l, at: 5.4, take: "21")
    },
    // Take 22: Superb-Man tries to keep up with the jump to hyperspace.
    Shot(name: "take22", start: 28.0, end: 33.0, into: .cut) { ctx, l, t in
        ctx.setFillColor(CGColor(red: 0.01, green: 0.02, blue: 0.06, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let jump = clamp((l - 0.8) / 0.6), centre = CGPoint(x: 1300, y: 600)
        for i in 0..<160 {                                           // stars, stretching into streaks
            let a = noise(i * 3) * 2 * .pi, r0 = 40 + noise(i * 3 + 1) * 1100
            let r = r0 * (1 + jump * 0.25), len = 2 + jump * jump * (60 + r0 * 0.4)
            let p = CGPoint(x: centre.x + cos(a) * r, y: centre.y + sin(a) * r * 0.6)
            ctx.move(to: p); ctx.addLine(to: CGPoint(x: p.x + cos(a) * len, y: p.y + sin(a) * len * 0.6))
            ctx.setStrokeColor(CGColor(red: 0.85, green: 0.92, blue: 1, alpha: 0.4 + 0.6 * noise(i * 3 + 2))); ctx.setLineWidth(3); ctx.strokePath()
        }
        let go = clamp((l - 0.9) / 0.4)
        if go < 1 {                                                 // the Millennial Falcon, gone in a blink
            let fc = PixelCanvas(Ride.width, Ride.height)
            drawRide(fc, .falcon, ramp: 0, engines: true, gear: false); fc.addOutline(C(0xFFFFFF, 0.92))
            if let img = fc.makeImage() {
                let s = 7 * (1 - go * 0.95)
                ctx.saveGState(); ctx.interpolationQuality = .none
                ctx.draw(img, in: CGRect(x: lerp(900, centre.x, go) - Double(Ride.width) * s / 2, y: lerp(560, centre.y, go) - Double(Ride.height) * s / 2,
                                         width: Double(Ride.width) * s, height: Double(Ride.height) * s))
                ctx.restoreGState()
            }
        }
        var sup = Actor(cast: .hero(DCHero.superman), x: lerp(-20, 70, easeOut(l / 1.0)) - max(0, l - 1.6) * 6, mode: .idle)
        sup.airborne = true; sup.lift = 70
        draw(sup, ctx, t: t)
        if l > 1.8 { balloon("Hey! Wait up!", ctx, center: CGPoint(x: 700, y: 780), tail: headPoint(sup), size: 46, width: 600) }
        cutAndSlate(ctx, local: l, at: 4.0, take: "22")
    },
    // The final take: everyone in one frame, Deadpond in front, and a wrap.
    Shot(name: "wrap", start: 33.0, end: 41.9, into: .cut) { ctx, l, t in
        set(ctx, .avengersTower, t: t)
        let wave = l > 5.6
        let back: [(Cast, Double)] = [(.villain(SWVillain.vader), 22), (.hero(SWHero.luke), 58), (.villain(MarvelVillain.thanos), 100),
                                      (.hero(MarvelHero.thor), 146), (.villain(DoctorVillain.dalick), 190), (.villain(DCVillain.joker), 232),
                                      (.hero(SWHero.han), 270), (.hero(DoctorHero.rose), 306)]
        for (i, (who, x)) in back.enumerated() {
            var a = Actor(cast: who, x: x, facing: i % 2 == 0 ? 1 : -1, mode: .idle, role: wave ? .cheer : .none)
            a.grow = 0.85; a.lift = 18
            draw(a, ctx, t: t + Double(i) * 0.3)
        }
        // the dancers moonwalk until the wrap is called
        let moon = { (who: Cast, offset: Double) in
            if !wave && who.persona.fidgets { forcedHabit = HabitPlay(kind: .moonwalk, e: (l + offset).truncatingRemainder(dividingBy: IdleHabit.moonwalk.length)) }
        }
        let front: [(Cast, Double)] = [(.hero(MarvelHero.starLord), 36), (.hero(DoctorHero.doctorTen), 88), (.hero(DCHero.batman), 236), (.hero(MarvelHero.howardTheDuck), 288)]
        for (i, (who, x)) in front.enumerated() {
            var a = Actor(cast: who, x: x, facing: x < 160 ? 1 : -1, mode: .idle, role: wave ? .cheer : .none)
            a.grow = 1.05
            if who.universe.module.moonwalkers.contains(who) { moon(who, Double(i) * 0.9) }
            draw(a, ctx, t: t + Double(i) * 0.5)
            forcedHabit = nil
        }
        var dp = Actor(cast: .hero(MarvelHero.deadpool), x: 162, mode: .idle, role: wave ? .cheer : .none)
        dp.grow = 1.7; dp.lift = -18
        moon(dp.cast, 1.8)
        draw(dp, ctx, t: t)
        forcedHabit = nil
        // Spider-Clawd swings across, upside down, as Superb-Man flies the other way
        let u = (l - 0.3) / 0.6
        if u > 0 && u < 4 {
            let reach = 58.0, i = floor(u), th = -swingAngle * cos(.pi * (u - i)), step = 2 * reach * sin(swingAngle)
            let anchor = (x: -20 + step * i, y: -10.0), feet = (x: anchor.x + reach * sin(th), y: anchor.y + reach * cos(th))
            var spidey = Actor(cast: .hero(MarvelHero.spiderMan), x: feet.x, mode: .idle)
            spidey.lift = groundY - 44 - feet.y
            drawUpsideDown(spidey, ctx, t: t)
            let web = PixelCanvas(fxW, fxH)
            web.glowLine(feet.x, feet.y + 2, anchor.x, anchor.y, core: C(0xF4F4F8, 0.9), glow: C(0xFFFFFF, 0), coreR: 0.35, glowR: 0.4)
            blit(web, ctx)
        }
        let fl = (l - 0.7) / 2.0
        if fl > 0 && fl < 1 {
            var sup = Actor(cast: .hero(DCHero.superman), x: lerp(370, -50, fl), facing: -1, mode: .idle)
            sup.airborne = true; sup.lift = 64 + sin(fl * .pi) * 8
            draw(sup, ctx, t: t)
        }
        if l > 2.7 && l < 5.6 {
            balloon("Separate universes, they said. Totally under control.", ctx, center: CGPoint(x: 960, y: 880), tail: headPoint(dp), size: 44, width: 1100)
        }
        cutAndSlate(ctx, local: l, at: 5.6, take: "99", wrap: true)
        let fade = clamp((l - 8.1) / 0.6)
        if fade > 0 { ctx.setFillColor(CGColor(gray: 0, alpha: fade)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H)) }
    },
]

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
    let league: [(DCHero, Double, String)] = [(.aquaman, 32, "walk"), (.greenLantern, 74, "fly"), (.wonderWoman, 116, "fly"),
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

/// The Detective Clawds trailer, as the tool asks for it.
struct DetectiveReel: PromoReel {
    let name = "detective", base = "detective-clawds-promo", small = "Detective-Clawds"
    let title = "DETECTIVE CLAWDS"
    let geminiTask = "gemini ▸ fix the clawdarang"
    var shots: [Shot] { detectiveShots }
    var beats: [(key: Double, beat: Beat)] { detectiveBeats }
    func sound(_ m: Mix) { detectiveSound(m) }
}

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
        let cast: [Cast] = [.hero(DCHero.superman), .villain(DCVillain.riddler), .villain(DCVillain.harleyQuinn), .villain(DCVillain.solomonGrundy)]
        statusOf(ctx, local: local, t: t, cast: cast, badgeText: "DETECTIVE CLAWDS", aside: "(\(cast[3].name): born on a Monday, napping by Thursday.)")
    },
    Shot(name: "agents", start: 33.8, end: 37.8) { ctx, local, t in
        agentsOf(ctx, local: local, t: t, guardCast: .hero(DCHero.wonderWoman),
                 crew: [.hero(DCHero.robin), .hero(DCHero.nightwing), .hero(DCHero.cyborg), .hero(DCHero.krypto)],
                 line: "Every subagent answers the beacon.", badgeText: "DETECTIVE CLAWDS")
    },
    Shot(name: "window", start: 37.8, end: 42.6) { ctx, local, t in
        windowShot(ctx, .dc, local: local, t: t, rise: true, needsAt: 2.5, at: .batcave)
        badge("WINDOW MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Prefer a window? Step into \(Location.batcave.name).", ctx, local: local, start: 0.1, y: 955, size: 56)
        caption("A live card per session: what it's doing, your last prompt, every agent.", ctx, local: local, start: 0.4, y: 890, size: 32, color: yellow, weight: .bold)
    },
    Shot(name: "ais", start: 42.6, end: 47.0) { ctx, local, t in
        everyAI(ctx, local: local, t: t, cast: [.hero(DCHero.superman), .hero(DCHero.wonderWoman), .villain(DCVillain.lexLuthor),
                                                .villain(DCVillain.sinestro), .villain(DCVillain.cheetah), .villain(DCVillain.blackManta),
                                                .villain(DCVillain.jokerGoon)])
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
        let crew: [(Cast, FightRole, AI)] = [(.hero(DCHero.wonderWoman), .cheer, .desktop), (.hero(DCHero.superman), .shoot(offset: 0), .claude),
                                             (.villain(DCVillain.lexLuthor), .shoot(offset: blasterPeriod / 2), .codex), (.villain(DCVillain.blackManta), .none, .copilot),
                                             (.villain(DCVillain.sinestro), .cheer, .qwen), (.villain(DCVillain.cheetah), .none, .gemini)]
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

// MARK: The Doctor Clawd trailer

/// The Doctor Clawd trailer, as the tool asks for it.
struct DoctorReel: PromoReel {
    let name = "doctor", base = "doctor-clawd-promo", small = "Doctor-Clawd"
    let title = "DOCTOR CLAWD"
    let geminiTask = "gemini ▸ reverse the polarity"
    var shots: [Shot] { doctorShots }
    var beats: [(key: Double, beat: Beat)] { doctorBeats }
    func sound(_ m: Mix) { doctorSound(m) }
}

/// The vortex's palette, darkest first, and the 4×4 ordered dither between its bands.
let vortexBlues: [UInt32] = [0x060A1E, 0x0E1A4A, 0x1A3290, 0x2C56CC, 0x5A86F0, 0x9CBCFF, 0xD8E6FF]
let vortexBayer: [Double] = [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5].map { Double($0) / 15 }

/// The time vortex of the title sequence, at the frame's pixel size: a tunnel of blue cloud with streams of orange and violet
/// fire twisting through it, spiralling down to a bright eye in the middle, streaks of light flying past. `glow` 0…1 fades it
/// up from the dark.
func vortexTunnel(_ g: CGContext, t: Double, glow: Double, centre c: CGPoint) {
    let w = fxW, h = fxH
    guard let data = g.data else { return }
    let px = data.bindMemory(to: UInt8.self, capacity: g.bytesPerRow * h)
    let far = hypot(Double(w), Double(h)) / 2
    for y in 0..<h {
        for x in 0..<w {
            let dx = Double(x) - c.x, dy = (Double(h - 1 - y) - c.y) / 0.8
            let d = max(0.004, hypot(dx, dy) / far), depth = 1 / (d + 0.06)
            let a = atan2(dy, dx) + depth * 0.42 + t * 0.9                      // the twist, deeper is turned further
            let flow = depth * 1.1 - t * 3.2                                    // rushing towards us
            var cloud = 0.5 + 0.3 * sin(a * 3 + flow) + 0.2 * sin(a * 7 - flow * 1.7 + sin(flow * 0.6) * 2)
            cloud += 0.12 * sin(a * 13 + flow * 2.3)
            cloud = clamp(cloud)
            let fire = clamp((sin(a * 2 - flow * 0.8 + 1.3) - 0.55) * 2.6) * clamp(cloud * 1.6 - 0.4)
            let edge = min(1, d * 5), eye = exp(-d * 14)
            // shaded in hard bands from a small palette, with a little ordered dither between them, like the sprites
            let dither = (vortexBayer[(y % 4) * 4 + x % 4] - 0.5) * 0.18
            let lit = pow(cloud, 1.6) * edge + eye * 1.6 + dither
            var col = vortexBlues[min(vortexBlues.count - 1, max(0, Int(lit * Double(vortexBlues.count))))]
            let violet = clamp((sin(a * 2 - flow * 0.9 + 4.2) - 0.6) * 2.8) * clamp(cloud * 1.6 - 0.3)
            if violet + dither > 0.3 && eye < 0.5 { col = violet + dither > 0.75 ? 0xC48CFF : violet + dither > 0.5 ? 0x8A4ADC : 0x50248E }
            if fire + dither > 0.35 && eye < 0.5 { col = fire + dither > 0.7 ? 0xFFB15A : 0xE0782E }
            let r = Double((col >> 16) & 0xFF) / 255, gg = Double((col >> 8) & 0xFF) / 255, b = Double(col & 0xFF) / 255
            let o = y * g.bytesPerRow + x * 4
            px[o] = UInt8(clamp(r * glow) * 255); px[o + 1] = UInt8(clamp(gg * glow) * 255)
            px[o + 2] = UInt8(clamp(b * glow) * 255); px[o + 3] = 255
        }
    }
    for i in 0..<30 {                                                              // streaks flying out
        let a = noise(i * 7 + 400) * 2 * .pi + t * 0.8, d = (noise(i * 7 + 401) + t * 0.9).truncatingRemainder(dividingBy: 1)
        let r0 = d * d * far, r1 = r0 + d * far * 0.22
        g.move(to: CGPoint(x: c.x + cos(a) * r0, y: c.y + sin(a) * r0 * 0.8))
        g.addLine(to: CGPoint(x: c.x + cos(a) * r1, y: c.y + sin(a) * r1 * 0.8))
        g.setStrokeColor(hexColor(0xE8F0FF, 0.6 * glow * d)); g.setLineWidth(1); g.strokePath()
    }
}

/// A fork of lightning from the top of the frame down into the vortex's eye (pixel-size coordinates).
func vortexLightning(_ g: CGContext, seed: Int, to c: CGPoint, alpha: Double) {
    var p = CGPoint(x: c.x + (noise(seed) - 0.5) * 160, y: Double(fxH) + 4)
    g.move(to: p)
    for k in 1...9 {
        let f = Double(k) / 9
        p = CGPoint(x: lerp(p.x, c.x, f) + (noise(seed + k) - 0.5) * 26 * (1 - f), y: lerp(Double(fxH) + 4, c.y, f))
        g.addLine(to: p)
    }
    g.setStrokeColor(hexColor(0x9AC0FF, alpha * 0.6)); g.setLineWidth(3); g.strokePath()
    g.move(to: CGPoint(x: c.x + (noise(seed) - 0.5) * 160, y: Double(fxH) + 4))
    p = CGPoint(x: c.x + (noise(seed) - 0.5) * 160, y: Double(fxH) + 4)
    for k in 1...9 {
        let f = Double(k) / 9
        p = CGPoint(x: lerp(p.x, c.x, f) + (noise(seed + k) - 0.5) * 26 * (1 - f), y: lerp(Double(fxH) + 4, c.y, f))
        g.addLine(to: p)
    }
    g.setStrokeColor(hexColor(0xFFFFFF, alpha)); g.setLineWidth(1); g.strokePath()
}

/// The police box on its own, outlined, its lamp lit or not: for tumbling through the vortex.
func tumblingBox(lamp: Bool) -> CGImage? {
    let c = PixelCanvas(28, 26)
    drawPoliceBoxIcon(c)
    if !lamp { c.rect(12, 2, 4, 2, C(0x8A94A8)) }
    c.addOutline(C(0xFFFFFF, 0.85))
    return c.makeImage()
}

/// The box drawn `height` tall, centred on `p`, turned `turn` radians.
func drawBox(_ ctx: CGContext, at p: CGPoint, height h: Double, turn: Double, lamp: Bool, alpha: Double = 1) {
    guard h > 2, alpha > 0.01, let box = tumblingBox(lamp: lamp) else { return }
    ctx.saveGState(); ctx.interpolationQuality = .none
    ctx.translateBy(x: p.x, y: p.y); ctx.rotate(by: CGFloat(turn)); ctx.setAlpha(CGFloat(alpha))
    ctx.draw(box, in: CGRect(x: -h * 28 / 26 / 2, y: -h / 2, width: h * 28 / 26, height: h))
    ctx.restoreGState()
}

/// The title: DOCTOR over CLAWD in glowing silver, on a blue lozenge, in the spirit of the show's logos.
func doctorTitle(_ ctx: CGContext, center: CGPoint, scale s: Double, alpha: Double = 1) {
    guard s > 0.01, alpha > 0.01 else { return }
    ctx.saveGState()
    ctx.translateBy(x: center.x, y: center.y); ctx.scaleBy(x: s, y: s)
    ctx.setAlpha(CGFloat(alpha))
    let lozenge = CGMutablePath()
    lozenge.addLines(between: [CGPoint(x: -600, y: 0), CGPoint(x: -470, y: 165), CGPoint(x: 470, y: 165), CGPoint(x: 600, y: 0),
                               CGPoint(x: 470, y: -165), CGPoint(x: -470, y: -165)])
    lozenge.closeSubpath()
    ctx.setShadow(offset: .zero, blur: 60, color: hexColor(0x4A8CFF, 0.9))
    ctx.addPath(lozenge); ctx.setFillColor(hexColor(0x0A1A4A, 0.88)); ctx.fillPath()
    ctx.setShadow(offset: .zero, blur: 0, color: nil)
    ctx.addPath(lozenge); ctx.setStrokeColor(hexColor(0x9AC4FF)); ctx.setLineWidth(10); ctx.strokePath()
    var inner = CGAffineTransform(scaleX: 0.95, y: 0.88)
    ctx.addPath(lozenge.copy(using: &inner)!)
    ctx.setStrokeColor(hexColor(0x4A7ADA, 0.8)); ctx.setLineWidth(4); ctx.strokePath()
    let font = NSFont(name: "AvenirNextCondensed-Heavy", size: 100) ?? .systemFont(ofSize: 100, weight: .black)
    for (word, size, y, kern) in [("DOCTOR", 92.0, 38.0, 26.0), ("CLAWD", 176.0, -150.0, 14.0)] {
        let f = NSFont(descriptor: font.fontDescriptor, size: size) ?? font
        let base: [NSAttributedString.Key: Any] = [.font: f, .kern: kern]
        let sz = NSAttributedString(string: word, attributes: base).size()
        let p = NSPoint(x: -sz.width / 2 + kern / 2, y: y)
        var dark = base; dark[.foregroundColor] = NSColor(srgbRed: 0.03, green: 0.08, blue: 0.25, alpha: 1)
        let stamp = NSAttributedString(string: word, attributes: dark), r = size * 0.06
        for k in 0..<16 { let a = Double(k) / 16 * 2 * .pi; stamp.draw(at: NSPoint(x: p.x + cos(a) * r, y: p.y + sin(a) * r)) }
        var silver = base; silver[.foregroundColor] = NSColor(srgbRed: 0.80, green: 0.85, blue: 0.93, alpha: 1)
        NSAttributedString(string: word, attributes: silver).draw(at: p)
        // the shine across the top half of the letters
        ctx.saveGState()
        ctx.clip(to: CGRect(x: p.x - 20, y: p.y + sz.height * 0.48, width: sz.width + 40, height: sz.height))
        var shine = base; shine[.foregroundColor] = NSColor(srgbRed: 0.97, green: 0.98, blue: 1, alpha: 1)
        NSAttributedString(string: word, attributes: shine).draw(at: p)
        ctx.restoreGState()
    }
    ctx.restoreGState()
}

/// The title sequence: lightning, then down the time vortex with the police box tumbling past, the title swelling out
/// of the eye of it, the box diving away into the depths, and the camera plunging into the title.
func doctorIntro(_ ctx: CGContext, local l: Double, t: Double) {
    let c = CGPoint(x: Double(fxW) / 2 + sin(l * 0.7) * 14, y: Double(fxH) / 2 + cos(l * 0.5) * 6)
    let bolts: [(Double, Int)] = [(0.25, 11), (0.95, 23), (4.35, 37)]
    if let img = lowRes({ g in
        vortexTunnel(g, t: l, glow: clamp(l / 0.9) * (1 - clamp((l - 8.4) / 0.4)), centre: c)
        for (at, seed) in bolts where l > at && l < at + 0.3 { vortexLightning(g, seed: seed, to: c, alpha: 1 - (l - at) / 0.3) }
    }) { ctx.saveGState(); ctx.interpolationQuality = .none; ctx.draw(img, in: fullRect); ctx.restoreGState() }
    for (at, _) in bolts where l > at && l < at + 0.18 {                            // each bolt lights up the whole frame
        ctx.setFillColor(hexColor(0xDDE8FF, 0.5 * (1 - (l - at) / 0.18))); ctx.fill(fullRect)
    }
    let eye = CGPoint(x: c.x * 6, y: c.y * 6), lamp = Int(l * 5) % 2 == 0
    // the box comes up out of the depths, tumbling, and flies past us to the right
    if l > 0.8 && l < 4.9 {
        let f = (l - 0.8) / 4.1, z = pow(f, 2.6)
        drawBox(ctx, at: CGPoint(x: eye.x + z * 760 + sin(l * 1.4) * 30, y: eye.y + z * 160 + cos(l * 1.2) * 24),
                height: 24 + z * 1300, turn: 0.5 * sin(l * 1.5) - 0.1, lamp: lamp, alpha: clamp(f * 8))
    }
    // ...and comes back past us from behind, diving away into the eye of the vortex, behind the title
    if l > 6.0 && l < 8.0 {
        let f = (l - 6.0) / 2.0, z = pow(1 - f, 2.4)
        drawBox(ctx, at: CGPoint(x: eye.x - z * 700, y: eye.y - z * 220), height: 18 + z * 1100, turn: -l * 1.1, lamp: lamp,
                alpha: 1 - clamp((f - 0.8) / 0.2))
    }
    // the title swells out of the eye, settles, then rushes at us
    if l > 4.4 {
        let grow = backOut((l - 4.4) / 1.4), dive = easeIn((l - 7.9) / 1.0)
        doctorTitle(ctx, center: CGPoint(x: lerp(eye.x, Double(W) / 2, clamp((l - 4.4) / 1.4)), y: lerp(eye.y, Double(H) / 2, clamp((l - 4.4) / 1.4))),
                    scale: grow * 0.72 + dive * 5, alpha: clamp((l - 4.4) / 0.4))
    }
    // and it all goes white
    let white = clamp((l - 8.35) / 0.5)
    if white > 0 { ctx.setFillColor(CGColor(gray: 1, alpha: white)); ctx.fill(fullRect) }
}

/// The invasion's timings (shot-local seconds).
let dalickXs = [178.0, 216.0, 254.0, 292.0], dalickHover = [34.0, 58.0, 40.0, 64.0]
let invGround = 160.0, tardisX = 62.0
let boxIn = 3.6, doorOpen = 5.5, zapFrom = 6.5, zapEach = 0.45

/// Each Dalick: how far it has come down, whether the Doctor's sonic is on it, and how far it has fled.
func dalickState(_ i: Int, _ l: Double) -> (down: Double, zapped: Bool, fled: Double) {
    let down = easeOut((l - 0.3 - Double(i) * 0.32) / 1.3)
    let z0 = zapFrom + Double(i) * zapEach
    return (down, l > z0 && l < z0 + zapEach, easeIn((l - z0 - zapEach * 0.7) / 1.1))
}

/// London on a winter's night: a squadron of Dalicks drops out of the sky, shrieks EXTERMINATE! and rakes the street;
/// the TARDIS wheezes into being under their fire, Doctor Ten strolls out, and his sonic sends them spinning away.
func doctorInvasion(_ ctx: CGContext, local l: Double, t: Double) {
    blit(place(.christmasLondon, floorRows: 30, t: t), ctx)
    let lamp = Int(l * 5) % 2 == 0
    onStage(ctx, fullRect, scale: 6, ground: invGround) {
        let fx = PixelCanvas(fxW, fxH)
        // the TARDIS fades in and out of being, its lamp flashing, then holds; the door swings open for the Doctor
        if l > boxIn {
            let k = clamp((l - boxIn) / 1.8)
            let alpha = k >= 1 ? 1 : min(1, max(0, k * (0.75 + 0.25 * sin(k * 7 * .pi))))
            let door = clamp((l - doorOpen) / 0.25) * (1 - clamp((l - 6.3) / 0.25))
            let c = PixelCanvas(Ride.width, Ride.tardis.canvasHeight)
            drawRide(c, .tardis, ramp: door, engines: k < 1 ? lamp : true, gear: true)
            c.addOutline(C(0xFFFFFF, 0.92))
            if let img = c.makeImage() {
                ctx.saveGState(); ctx.interpolationQuality = .none; ctx.setAlpha(CGFloat(alpha))
                ctx.draw(img, in: CGRect(x: (tardisX - Double(Ride.width) / 2) * 6, y: Double(H) - invGround * 6 - 6,
                                         width: Double(Ride.width) * 6, height: Double(Ride.tardis.canvasHeight) * 6))
                ctx.restoreGState()
            }
        }
        // the Doctor steps out and strolls up to them
        var doc = Actor(cast: .hero(DoctorHero.doctorTen), x: lerp(tardisX + 4, 104, easeOut((l - 5.75) / 0.8)), facing: 1, mode: .idle)
        doc.walking = l < 6.5
        doc.alpha = clamp((l - 5.65) / 0.15)
        // the Dalicks
        var dalicks: [Actor] = []
        for i in dalickXs.indices {
            let s = dalickState(i, l)
            var d = Actor(cast: .villain(DoctorVillain.dalick), x: dalickXs[i] + s.fled * 60, facing: -1, mode: .idle)
            d.airborne = true
            d.lift = lerp(170, dalickHover[i], s.down) + s.fled * 160 + (s.zapped ? sin(t * 70) * 1.5 : 0)
            d.role = s.zapped ? .hit : .none
            d.alpha = 1 - clamp((s.fled - 0.85) / 0.15)
            dalicks.append(d)
        }
        // their fire: raking the street, then at the box as it lands
        if l > 2.7 && l < 5.4 {
            for (i, d) in dalicks.enumerated() where Int(t * 6 + Double(i) * 1.7) % 3 != 0 {
                let m = d.fighter.point(d.cast.muzzle.x, d.cast.muzzle.y)
                let atBox = l > 4.1
                let tx = atBox ? tardisX + 6 + (noise(i + Int(t * 6)) - 0.5) * 18 : 40 + frac(l * 0.45 + Double(i) * 0.23) * 220
                let ty = atBox ? invGround - 12 - noise(i * 3 + Int(t * 6)) * 18 : invGround
                fx.glowLine(m.x, m.y, tx, ty, core: C(0xF0FAFF), glow: C(0x4AB8FF), coreR: 0.6, glowR: 1.8)
                drawSparks(fx, x: tx, y: ty, t: t + Double(i), size: 3)
            }
        }
        for d in dalicks { draw(d, ctx, t: t) }
        if doc.alpha > 0 {
            // the sonic, on each Dalick in turn
            if let i = dalickXs.indices.first(where: { dalickState($0, l).zapped }) {
                doc.role = .zap
                drawFX([(doc, dalicks[i])], ctx, t: t)
            }
            draw(doc, ctx, t: t)
        }
        if let img = fx.makeImage() { ctx.saveGState(); ctx.interpolationQuality = .none; ctx.draw(img, in: fullRect); ctx.restoreGState() }
    }
    // EXTERMINATE!, shrieked
    if l > 2.2 && l < 4.0 {
        let f = easeOut((l - 2.2) / 0.15), a = 1 - clamp((l - 3.7) / 0.3)
        ctx.saveGState(); ctx.translateBy(x: sin(t * 80) * 6, y: cos(t * 67) * 4)
        text("EXTERMINATE!", ctx, y: 860, size: CGFloat(100 + 20 * (1 - f)), weight: .black,
             color: NSColor(srgbRed: 1, green: 0.32, blue: 0.24, alpha: 1), alpha: f * a, kern: 8)
        ctx.restoreGState()
    }
    // out of the white of the title sequence
    let white = 1 - clamp(l / 0.6)
    if white > 0 { ctx.setFillColor(CGColor(gray: 1, alpha: white)); ctx.fill(fullRect) }
}

let doctorShots: [Shot] = [
    // The title sequence: down the time vortex with the box, to the title.
    Shot(name: "intro", start: 0, end: 9.0, into: .cut) { ctx, local, t in doctorIntro(ctx, local: local, t: t) },
    // London at Christmas: the Dalicks invade, the TARDIS lands under fire, the Doctor sees them off.
    Shot(name: "invasion", start: 9.0, end: 18.5, into: .cut) { ctx, local, t in doctorInvasion(ctx, local: local, t: t) },
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
        brawl(ctx, .doctor, local: local, t: t, drop: true, chrome: false)
        badge("DESKTOP MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Now they're a pixel-art Doctor Clawd brawl", ctx, local: local, start: 0.35, y: 900)
        caption("along the bottom of your screen. They fight while they work.", ctx, local: local, start: 0.6, y: 830, size: 40, color: yellow, weight: .bold)
    },
    Shot(name: "status", start: 27.1, end: 31.3) { ctx, local, t in
        let cast: [Cast] = [.hero(DoctorHero.doctorEleven), .villain(DoctorVillain.master), .villain(DoctorVillain.missy), .hero(DoctorHero.donna)]
        statusOf(ctx, local: local, t: t, cast: cast, badgeText: "DOCTOR CLAWD", aside: "(\(cast[3].name), napping. Nobody wake her. Seriously.)")
    },
    Shot(name: "agents", start: 31.3, end: 35.3) { ctx, local, t in
        agentsOf(ctx, local: local, t: t, guardCast: .hero(DoctorHero.brigadier),
                 crew: [.hero(DoctorHero.rose), .hero(DoctorHero.jack), .hero(DoctorHero.kCanine), .hero(DoctorHero.martha)],
                 line: "Every subagent gets to be a companion.", badgeText: "DOCTOR CLAWD")
    },
    Shot(name: "window", start: 35.3, end: 40.1) { ctx, local, t in
        windowShot(ctx, .doctor, local: local, t: t, rise: true, needsAt: 2.5, at: .consoleRoom)
        badge("WINDOW MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Prefer a window? It's bigger on the inside.", ctx, local: local, start: 0.1, y: 955, size: 56)
        caption("A live card per session: what it's doing, your last prompt, every agent.", ctx, local: local, start: 0.4, y: 890, size: 32, color: yellow, weight: .bold)
    },
    Shot(name: "ais", start: 40.1, end: 44.5) { ctx, local, t in
        everyAI(ctx, local: local, t: t, cast: [.hero(DoctorHero.doctorTen), .hero(DoctorHero.doctorThirteen), .villain(DoctorVillain.dalick),
                                                .villain(DoctorVillain.cyberperson), .villain(DoctorVillain.weepingAngle), .villain(DoctorVillain.master),
                                                .villain(DoctorVillain.sontaron)])
    },
    // The end card: the console room, the crew lines up, the title lands.
    Shot(name: "endcard", start: 44.5, end: 48.7) { ctx, local, t in
        blit(place(.consoleRoom, floorRows: 34, t: t), ctx)
        ctx.setFillColor(CGColor(gray: 0, alpha: 0.3)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let crew: [(Cast, FightRole, AI)] = [(.hero(DoctorHero.rose), .cheer, .desktop), (.hero(DoctorHero.doctorTen), .zap, .claude),
                                             (.villain(DoctorVillain.dalick), .hit, .codex), (.villain(DoctorVillain.cyberperson), .none, .copilot),
                                             (.villain(DoctorVillain.master), .cheer, .qwen), (.villain(DoctorVillain.weepingAngle), .none, .gemini)]
        var placed: [Actor] = []
        for (i, (who, role, ai)) in crew.enumerated() {
            var a = Actor(cast: who, x: [28.0, 84, 156, 206, 252, 296][i], facing: i < 2 ? 1 : -1, role: role, ai: ai)
            a.lift = 8
            a.alpha = clamp((local - 0.15 - Double(i) * 0.05) / 0.2)
            draw(a, ctx, t: t)
            placed.append(a)
        }
        if local > 0.5 { drawFX([(placed[1], placed[2])], ctx, t: t) }
        if local > 0.35 { doctorTitle(ctx, center: CGPoint(x: Double(W) / 2, y: 760), scale: backOut((local - 0.35) / 0.4) * 0.62) }
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

let doctorBeats: [(key: Double, beat: Beat)] = [
    (2.2, ("THE TITLE SEQUENCE", "Lightning cracks into the dark, and we fall down the time vortex, a tunnel of blue and orange cloud spiralling round a bright eye. The police box comes tumbling up out of the depths, lamp flashing, and sweeps past us.", "no text", "a plucked galloping bass, swells of wind and a wobbly swooping lead, in the sound of the old electronic theme but our own notes; thunder")),
    (6.6, ("THE TITLE", "A last bolt, and DOCTOR / CLAWD swells out of the eye of the vortex in glowing silver on a blue lozenge. The box flies back past us and dives away into the depths behind it; then the camera plunges into the title and everything goes white.", "DOCTOR CLAWD", "the theme's big hit, a rising sweep into the white")),
    (12.0, ("THE INVASION", "Out of the white into London on a winter's night: four Dalicks drop out of the sky in formation, shriek EXTERMINATE! and rake the street with their beams.", "EXTERMINATE!", "a pulsing drone, the robot shriek, Dalick beams")),
    (14.0, ("THE TARDIS LANDS", "The TARDIS wheezes into being right under their fire, its lamp flashing, beams sparking off it.", "no text", "the grinding wheeze, sparks")),
    (16.4, ("ALLONS-Y", "The door swings open, Doctor Ten strolls out, raises his sonic screwdriver and zaps each Dalick in turn; they spin away into the sky.", "no text", "footsteps, the sonic's warble, each Dalick whirring off")),
    (20.0, ("THE HOOK", "Three busy terminals, slow push-in.", "“Three AIs. Nine agents. One very confused human.”  →  “Sound familiar?”", "keyboard clicks")),
    (24.8, ("DESKTOP MODE", "Doctor Ten's sonic on a Dalick; River Tune trades shots with a Sontaron.", "DESKTOP MODE  ·  “Now they're a pixel-art Doctor Clawd brawl along the bottom of your screen. They fight while they work.”", "the sonic, shots")),
    (29.4, ("AT A GLANCE", "Doctor Eleven working, the Master thinking, Missy's jumping NEEDS YOU, Donna Nobble sat down napping.", "“All fun and games, and you still see everything.”  ·  “(Donna Nobble, napping. Nobody wake her. Seriously.)”", "blips, alert beeps")),
    (33.5, ("SUBAGENTS", "The Brigadier stands guard; Rose, Captain Jack, K-Canine and Martha arrive with their jobs on their labels.", "“Every subagent gets to be a companion.”", "footsteps")),
    (38.1, ("WINDOW MODE", "The window in the Console Room: Doctor Ten against a Dalick, live cards tick, then the Dalick's Codex card flips to NEEDS YOU.", "WINDOW MODE  ·  “Prefer a window? It's bigger on the inside.”", "a ping")),
    (42.5, ("EVERY AI", "Six sessions, one per AI outline; Claude's Doctor Ten a head taller, his sonic on Codex's Dalick.", "BRING YOUR OWN AI*  ·  “One AI plays everyone. Run two and they pick sides.”  ·  *README for the full list", "the sonic")),
    (47.5, ("END CARD", "The console room: the crew lines up, DOCTOR CLAWD lands.", "DOCTOR CLAWD  ·  “Have fun. Keep track.”  ·  “One of many universes in Clawd Clash · free for macOS”  ·  github.com/rodclemen/clawd-clash", "the wheeze, the final sting")),
]

extension Mix {

    /// The sonic screwdriver's warble.
    func sonic(_ t: Double, _ dur: Double, vol: Double = 0.05) {
        tone(t, dur, 2100, to: 2350, wave: .sine, vol: vol, attack: 0.03, release: 0.06, vibrato: 0.05)
        tone(t, dur, 1050, to: 1175, wave: .triangle, vol: vol * 0.4, attack: 0.03, release: 0.06, vibrato: 0.05)
    }
    /// A Dalick's beam.
    func dalickBeam(_ t: Double, vol: Double = 0.06) {
        tone(t, 0.22, 1400, to: 500, wave: .saw, vol: vol, release: 0.08)
        noise(t, 0.2, vol: vol * 0.6, cutoff: 0.5, decay: 0.08, highpass: true, seed: Int(t * 311))
    }
    /// EX-TER-MI-NATE!, in a grating robot shriek.
    func exterminate(_ t: Double, vol: Double = 0.09) {
        for (s, d, f) in [(0.0, 0.16, 330.0), (0.2, 0.16, 370.0), (0.4, 0.16, 415.0), (0.6, 0.55, 520.0)] {
            tone(t + s, d, f, to: f * 1.04, wave: .saw, vol: vol, attack: 0.01, release: 0.05, vibrato: 0.09)
            tone(t + s, d, f * 1.5, wave: .square(0.3), vol: vol * 0.5, attack: 0.01, release: 0.05, vibrato: 0.11)
        }
    }
}

/// The title sequence's tune, in the manner of the old electronic theme (its sounds, not its melody): a plucked,
/// galloping bass ostinato, swells of filtered "wind" every couple of bars, and a wobbly sine lead that swoops up into
/// long notes and slides between them, with the odd "oo-ee" glissando. The notes are our own.
func doctorTune(_ m: Mix, from t0: Double, bars: Int) {
    let bar = 1.6, sx = bar / 16
    let roots = [40, 40, 43, 38, 40, 45, 47, 40]                       // E E G D E A B E, low
    for b in 0..<bars {
        let r = roots[b % roots.count], s = t0 + Double(b) * bar
        for beat in 0..<4 {                                            // dum-da-da, dum-da-da, each note plucked
            for (o, d) in [(0, 2), (2, 1), (3, 1)] {
                let at = s + Double(beat * 4 + o) * sx, f = midi(r + (o == 0 ? 0 : 12)), len = Double(d) * sx * 0.95
                m.tone(at, len, f * 1.06, to: f, wave: .triangle, vol: o == 0 ? 0.14 : 0.1, attack: 0.002, release: 0.02, decay: 0.09)
                m.tone(at, len, f * 1.06, to: f, wave: .square(0.18), vol: 0.025, attack: 0.002, release: 0.02, decay: 0.05)
                if o == 0 { m.tone(at, len, midi(r - 12), wave: .sine, vol: 0.18, release: 0.03, decay: 0.16) }
            }
        }
        if b % 2 == 0 {                                                // the wind, swelling up and dying away
            m.noise(s, bar, vol: 0.07, cutoff: 0.005, cutoffTo: 0.09, attack: bar * 0.8, release: 0.1, seed: 60 + b)
            m.noise(s + bar, bar, vol: 0.07, cutoff: 0.09, cutoffTo: 0.005, attack: 0.1, release: bar * 0.8, seed: 61 + b)
        }
    }
    // the lead: (start, length, from, to): swoops up into a note, holds it wobbling, or slides down to the next
    let lead: [(Double, Double, Int, Int)] = [
        (1.6, 0.3, 64, 71), (1.9, 1.3, 71, 71), (3.2, 0.3, 71, 76), (3.5, 1.1, 76, 76), (4.6, 0.4, 74, 74), (5.0, 0.4, 72, 71),
        (5.4, 0.3, 71, 79), (5.7, 1.4, 79, 79), (7.1, 0.5, 79, 76), (7.6, 0.6, 76, 76)]
    for (s, d, from, to) in lead where s < Double(bars) * bar {
        let held = from == to
        for (detune, vol) in [(1.0, 0.085), (1.004, 0.04)] {          // two sines a hair apart, for the wobble
            m.tone(t0 + s, d, midi(from) * detune, to: midi(to) * detune, wave: .sine, vol: vol,
                   attack: held ? 0.02 : 0.06, release: held ? 0.12 : 0.02, vibrato: held ? 0.018 : 0.004)
        }
        m.tone(t0 + s, d, midi(from + 12), to: midi(to + 12), wave: .triangle, vol: 0.012, attack: 0.05, release: 0.1, vibrato: 0.018)
    }
    for at in [0.6, 4.4] {                                             // oo-ee: a sine sweeping up an octave and back
        m.tone(t0 + at, 0.45, midi(76), to: midi(88), wave: .sine, vol: 0.035, attack: 0.15, release: 0.05, vibrato: 0.01)
        m.tone(t0 + at + 0.45, 0.5, midi(88), to: midi(76), wave: .sine, vol: 0.035, attack: 0.02, release: 0.3, vibrato: 0.01)
    }
}

/// The Doctor Clawd trailer's score and effects.
func doctorSound(_ m: Mix) {
    let i0 = start("intro")
    for at in [0.25, 0.95, 4.35] {                                     // the lightning: a crack, then thunder
        m.noise(i0 + at, 0.25, vol: 0.22, cutoff: 0.9, decay: 0.06, highpass: true, seed: Int(at * 100))
        m.boom(i0 + at + 0.05, vol: 0.3)
    }
    m.noise(i0 + 0.2, 8.6, vol: 0.05, cutoff: 0.01, cutoffTo: 0.05, attack: 1.0, release: 0.6, seed: 3)   // the vortex's roar
    doctorTune(m, from: i0 + 0.5, bars: 5)
    m.whoosh(i0 + 4.3, 1.2, vol: 0.16)                                 // the box sweeping past
    let logo = i0 + 4.6
    m.boom(logo, vol: 0.4)
    for n in [40, 47, 52, 55, 59] { m.tone(logo, 1.8, midi(n), wave: .saw, vol: 0.04, attack: 0.02, release: 1.0) }
    m.whoosh(i0 + 7.0, 1.4, vol: 0.12)                                 // the box diving away
    m.tone(i0 + 7.6, 1.2, 200, to: 3200, wave: .saw, vol: 0.05, attack: 0.3, release: 0.1)
    m.noise(i0 + 7.8, 1.2, vol: 0.12, cutoff: 0.05, cutoffTo: 0.9, attack: 0.6, release: 0.3, seed: 9)
    let inv = start("invasion")
    for i in 0..<Int(9.5 / 0.4) { m.tone(inv + Double(i) * 0.4, 0.3, midi(i % 4 == 3 ? 31 : 28), wave: .saw, vol: 0.06 + 0.04 * min(1, Double(i) / 10), release: 0.1); m.kick(inv + Double(i) * 0.4, vol: 0.12 + 0.1 * min(1, Double(i) / 8)) }
    for i in 0..<4 { m.tone(inv + 0.3 + Double(i) * 0.32, 1.2, 140, to: 90, wave: .sine, vol: 0.06, attack: 0.2, release: 0.4) }   // the Dalicks coming down
    m.exterminate(inv + 2.2, vol: 0.13)
    for (s, chord) in [(0.0, [40, 43, 47]), (3.2, [41, 44, 48]), (6.4, [40, 44, 47])] {
        for n in chord { m.tone(inv + s, 3.2, midi(n), wave: .saw, vol: 0.03, attack: 0.4, release: 0.6) }
    }
    var b = inv + 2.8
    while b < inv + 5.4 { m.dalickBeam(b, vol: 0.07); b += 0.17 }
    m.wheeze(inv + boxIn, cycles: 3, vol: 0.18)
    m.clunk(inv + doorOpen, vol: 0.1)
    for k in 0..<5 { m.step(inv + 5.8 + Double(k) * 0.16, vol: 0.07) }
    for i in 0..<4 {
        let z = inv + zapFrom + Double(i) * zapEach
        m.sonic(z, zapEach * 0.95, vol: 0.08)
        m.tone(z + zapEach * 0.7, 0.9, 600, to: 1500, wave: .square(0.3), vol: 0.03, release: 0.3)   // whirring off
    }
    groove(m, from: start("hook"), to: start("endcard"), fadeIn: 1.2)
    let hook = start("hook")
    for i in 0..<26 { m.click(hook + 0.2 + Double(i) * 0.13 + noise(i) * 0.06) }
    let desk = start("desktop"), deskEnd = end("desktop") + 1.3
    for (i, d) in [0.0, 0.12, 0.24, 0.32].enumerated() { m.step(desk + d + 0.3, vol: 0.1 + Double(i % 2) * 0.03) }
    m.sonic(desk + 0.6, deskEnd - desk - 0.6, vol: 0.025)
    for t in shotTimes(desk + 0.45, deskEnd, offset: 0) { m.pew(t, vol: 0.08) }
    for t in shotTimes(desk + 0.45, deskEnd, offset: blasterPeriod / 2) { m.pew(t, vol: 0.06) }
    let st = start("status")
    for i in 0..<4 { m.pop(st + 0.1 + Double(i) * 0.22, step: i) }
    for k in 0..<5 { m.tone(st + 1.2 + Double(k) * 0.62, 0.08, 1568, wave: .square(0.5), vol: 0.035, release: 0.03) }
    let ag = start("agents")
    for k in 0..<14 { m.step(ag + Double(k) * 0.125, vol: 0.06) }
    let wi = start("window")
    m.sonic(wi + 0.3, 2.2, vol: 0.02)
    for k in [0.9, 1.8] { m.click(wi + k, vol: 0.06) }
    m.ping(wi + 2.5)
    let ais = start("ais")
    for i in 0..<6 { m.pop(ais + 0.15 + Double(i) * 0.1, step: i % 4) }
    m.sonic(ais + 0.4, end("ais") + 1.0 - ais - 0.4, vol: 0.02)
    for s in shots { transitionSound(m, s) }
    let ec = start("endcard")
    m.wheeze(ec - 0.4, cycles: 2, vol: 0.07)
    for (s, d, chord, lead) in [(0.0, 0.7, [52, 55, 59, 64], 79), (0.7, 0.7, [50, 54, 57, 62], 78), (1.4, 2.8, [52, 56, 59, 64], 83)] {
        for n in chord { m.tone(ec + s, d, midi(n), wave: .saw, vol: 0.045, attack: 0.02, release: d > 1 ? 1.6 : 0.1) }
        m.tone(ec + s, d, midi(lead), wave: .sine, vol: 0.08, release: d > 1 ? 1.6 : 0.1, vibrato: 0.012)
        m.tone(ec + s, d, midi(chord[0] - 24), wave: .sine, vol: 0.2, release: d > 1 ? 1.6 : 0.1)
    }
    m.boom(ec + 0.35, vol: 0.45)
    m.noise(ec + 1.4, 2.5, vol: 0.08, cutoff: 0.9, decay: 0.8, highpass: true, seed: 8)
}

// MARK: The Clawd Files trailer

/// The Clawd Files trailer, as the tool asks for it.
struct FilesReel: PromoReel {
    let name = "files", base = "the-clawd-files-promo", small = "The-Clawd-Files"
    let title = "THE CLAWD FILES"
    let geminiTask = "gemini ▸ declassify the logs"
    var shots: [Shot] { filesShots }
    var beats: [(key: Double, beat: Beat)] { filesBeats }
    func sound(_ m: Mix) { filesSound(m) }
}

/// A black picture at the frame's pixel-art size: what the opening titles come out of and go back into.
let filesDark: CGImage = {
    let c = PixelCanvas(fxW, fxH)
    c.rect(0, 0, fxW, fxH, C(0x020302))
    return c.makeImage()!
}()

/// The title: THE over CLAWD FILES in the show's eerie green, glowing on the dark. `warp` 0…1 slides its rows out of
/// line and stretches them, the way the title flickers into place in the opening.
func filesTitle(_ ctx: CGContext, center: CGPoint, scale s: Double, warp: Double, t: Double, alpha: Double = 1) {
    guard s > 0.01, alpha > 0.01 else { return }
    let tw = 1500, th = 420
    guard let g = CGContext(data: nil, width: tw, height: th, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return }
    let ns = NSGraphicsContext(cgContext: g, flipped: false)
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = ns
    let font = NSFont(name: "AvenirNextCondensed-Heavy", size: 100) ?? .systemFont(ofSize: 100, weight: .black)
    let green = NSColor(srgbRed: 0.62, green: 0.96, blue: 0.70, alpha: 1)
    for (word, size, y, kern) in [("THE", 70.0, 290.0, 30.0), ("CLAWD FILES", 190.0, 50.0, 18.0)] {
        let f = NSFont(descriptor: font.fontDescriptor, size: CGFloat(size)) ?? font
        let shadow = NSShadow(); shadow.shadowColor = NSColor(srgbRed: 0.16, green: 0.82, blue: 0.42, alpha: 0.9)
        shadow.shadowBlurRadius = 28
        let a = NSAttributedString(string: word, attributes: [.font: f, .kern: kern, .foregroundColor: green, .shadow: shadow])
        a.draw(at: NSPoint(x: (Double(tw) - a.size().width) / 2, y: y))
    }
    NSGraphicsContext.restoreGraphicsState()
    guard let img = g.makeImage() else { return }
    // Drawn in strips, each slid sideways (and the whole stretched) by the warp.
    ctx.saveGState()
    ctx.translateBy(x: center.x, y: center.y); ctx.scaleBy(x: s, y: s)
    ctx.setAlpha(CGFloat(alpha)); ctx.interpolationQuality = .high
    let strip = 12
    for y in stride(from: 0, to: th, by: strip) {
        let band: Int = y / strip
        let wobble: Double = sin(Double(band) * 0.7 + t * 23) * 0.6 + (noise(band * 7 + Int(t * 14)) - 0.5)
        let dx: Double = wobble * 160 * warp
        let stretch: Double = 1 + 0.5 * warp * sin(Double(band) * 0.3 + t * 9)
        guard let part = img.cropping(to: CGRect(x: 0, y: th - y - strip, width: tw, height: strip)) else { continue }
        let w: Double = Double(tw) * stretch
        ctx.draw(part, in: CGRect(x: -w / 2 + dx, y: Double(y) - Double(th) / 2, width: w, height: Double(strip)))
    }
    ctx.restoreGState()
}

/// The opening titles, the show's own way: the montage (the saucer, the eye, the warped face, the ghost in the corridor,
/// the hand in red light, racing clouds and THE TRUTH IS OUT THERE), the clouds parting on the dark, and the title
/// flickering into place out of it, warped, steadying, then breaking up again.
func filesIntro(_ ctx: CGContext, local l: Double, t: Double) {
    let montage = 6.2
    if l < montage {
        FilesTrip(kind: .montage).draw(ctx, old: filesDark, new: filesDark, k: l / montage, in: fullRect)
    } else {
        ctx.setFillColor(hexColor(0x020302)); ctx.fill(fullRect)
    }
    if l > montage - 0.1 {
        let settle = 1 - easeOut((l - montage) / 1.3), breakUp = easeIn((l - 8.3) / 0.6)
        let flicker = l < montage + 0.5 && noise(Int(l * 30)) < 0.35 ? 0.3 : 1.0
        filesTitle(ctx, center: CGPoint(x: Double(W) / 2, y: Double(H) / 2), scale: 0.95 + 0.04 * (l - montage),
                   warp: max(settle, breakUp) + 0.04, t: t, alpha: clamp((l - montage + 0.1) / 0.3) * flicker * (1 - clamp((l - 8.75) / 0.25)))
    }
}

/// The set piece's timings (shot-local seconds).
let woodsGround = 160.0, foxX = 132.0, saucerIn = 3.0, takenAt = 4.0, takenFor = 4.2, smokerIn = 7.3

/// A flashlight's beam on the fx canvas: from `a` towards `b`, widening, faint.
func flashlightBeam(_ fx: PixelCanvas, from a: (x: Double, y: Double), to b: (x: Double, y: Double), alpha: Double) {
    let steps = 60
    for i in 0...steps {
        let f: Double = Double(i) / Double(steps)
        let x: Double = a.x + (b.x - a.x) * f, y: Double = a.y + (b.y - a.y) * f
        let half: Int = Int(1 + f * 9)
        let fade: Double = alpha * (1 - f * 0.7)
        fx.rect(Int(x), Int(y) - half, 1, half * 2 + 1, C(0xFFF0B8, 0.13 * fade))
        fx.px(Int(x), Int(y), C(0xFFF8DC, 0.25 * fade))
    }
}

/// Bellefleur Woods at night. The place types itself in. Clawder and Scrawly come through the trees, flashlights
/// sweeping; a saucer slides over, its beam comes down on Clawder and he's taken up into it, then set back down as
/// MISSING TIME types itself out over him. Scrawly wants to know what time it is; in the trees, the Cigarette-Smoking
/// Clawd lights up.
func filesWoods(_ ctx: CGContext, local l: Double, t: Double) {
    blit(place(.bellefleurWoods, floorRows: 30, t: t), ctx)
    ctx.setFillColor(hexColor(0x020608, 0.2)); ctx.fill(fullRect)
    let missing = l > takenAt ? MissingTime(k: min(1, (l - takenAt) / takenFor)) : nil
    var foxTop = 0.0
    onStage(ctx, fullRect, scale: 6, ground: woodsGround) {
        let fx = PixelCanvas(fxW, fxH)
        let walk = easeOut((l - 0.4) / 2.3)
        var fox = Actor(cast: .hero(FilesHero.foxClawder), x: lerp(-24, foxX, walk), facing: 1, mode: .idle)
        var dana = Actor(cast: .hero(FilesHero.danaScrawly), x: lerp(-56, foxX - 38, walk), facing: 1, mode: .idle)
        fox.walking = l > 0.4 && l < 2.6; dana.walking = fox.walking
        // Their flashlights, sweeping the trees; Clawder's goes up at the light, Scrawly's follows him.
        let lookUp = easeOut((l - saucerIn) / 0.6)
        for (i, a) in [fox, dana].enumerated() {
            guard a.alpha > 0.1, !(i == 0 && (missing?.alpha ?? 1) < 0.5) else { continue }
            let hand = a.fighter.point(46, 34)
            let sweep: Double = sin(l * 1.6 + Double(i) * 1.9) * 26
            let aimX: Double = hand.x + 70 - lookUp * 40, aimY: Double = woodsGround - 30 + sweep * (1 - lookUp) - lookUp * 90
            flashlightBeam(fx, from: (hand.x, hand.y), to: (aimX, aimY), alpha: clamp((l - 0.3) / 0.4))
        }
        // The saucer slides in over the trees and hangs over Clawder.
        let arrive = easeOut((l - saucerIn) / 1.0), leave = easeIn((l - takenAt - takenFor + 0.4) / 1.0)
        let sx: Double = lerp(fxW.d + 60, foxX, arrive) + leave * 260, sy: Double = 12 + 6 * sin(t * 1.3) - leave * 40
        if l > saucerIn && leave < 1 {
            if let m = missing, m.beam > 0 {
                let beam = PixelCanvas(30, Int(woodsGround - sy - 14))
                drawAbductionBeam(beam, strength: m.beam, t: t)
                fx.paste(beam, x: Int(foxX) - 15, y: Int(sy) + 14)
            }
            let ship = PixelCanvas(66, 29)
            drawSaucer(ship, ramp: 0, engines: true)
            ship.addOutline(C(0xFFFFFF, 0.92))
            fx.paste(ship, x: Int(sx) - 33, y: Int(sy) - 6)
        }
        // Clawder, taken up and set back down.
        if let m = missing { fox.lift = m.lift; fox.alpha = m.alpha }
        if let img = fx.makeImage() { ctx.saveGState(); ctx.interpolationQuality = .none; ctx.draw(img, in: fullRect); ctx.restoreGState() }
        draw(dana, ctx, t: t)
        if fox.alpha > 0.02 { draw(fox, ctx, t: t) }
        foxTop = fox.top
        // The Cigarette-Smoking Clawd, in the trees on the right, lighting up.
        if l > smokerIn {
            var smoker = Actor(cast: .villain(FilesVillain.smokingClawd), x: 282, facing: -1, mode: .idle)
            smoker.alpha = clamp((l - smokerIn) / 0.5) * 0.92
            draw(smoker, ctx, t: t)
            let glow = PixelCanvas(fxW, fxH)
            let lit = l > smokerIn + 0.6
            glow.rect(268, Int(woodsGround) - 12, 2, 1, C(lit ? 0xFF8A3A : 0xFFE08A, smoker.alpha))
            if l > smokerIn + 0.5 && l < smokerIn + 0.75 { glow.rect(266, Int(woodsGround) - 15, 4, 4, C(0xFFD27A, 0.7)) }   // the match
            for i in 0..<6 where lit {
                let f: Double = frac(t * 0.4 + Double(i) / 6)
                glow.px(268 + Int(sin(f * 9 + Double(i)) * 3), Int(woodsGround) - 14 - Int(f * 30), C(0xB8BCB8, 0.5 * (1 - f) * smoker.alpha))
            }
            if let img = glow.makeImage() { ctx.saveGState(); ctx.interpolationQuality = .none; ctx.draw(img, in: fullRect); ctx.restoreGState() }
        }
    }
    // The place, typed in at the top-left corner.
    var y = 975.0
    for (i, line) in FilesCaption.typed(.bellefleurWoods, after: max(0, l - 0.6)).enumerated() {
        let a = NSAttributedString(string: line, attributes: [.font: FilesCaption.font(i == 0 ? 46 : 32), .foregroundColor: NSColor(white: 0.93, alpha: 1)])
        a.draw(at: NSPoint(x: 80, y: y)); y -= 52
    }
    // MISSING TIME over Clawder, as it types.
    if let caption = missing?.caption {
        let a = NSAttributedString(string: caption, attributes: [.font: FilesCaption.font(44), .foregroundColor: NSColor(srgbRed: 0.8, green: 1, blue: 0.85, alpha: 1)])
        a.draw(at: NSPoint(x: foxX * 6 - a.size().width / 2 + 40, y: Double(H) - (foxTop - 4) * 6))
    }
    caption("“Clawder? Clawder! What time is it?”", ctx, local: l, start: 7.0, y: 760, size: 52)
    // in from the dark of the titles
    let dark = 1 - clamp(l / 0.6)
    if dark > 0 { ctx.setFillColor(CGColor(gray: 0, alpha: dark)); ctx.fill(fullRect) }
}


let filesShots: [Shot] = [
    // The opening titles, to the title.
    Shot(name: "intro", start: 0, end: 9.0, into: .cut) { ctx, local, t in filesIntro(ctx, local: local, t: t) },
    // Bellefleur Woods: the flashlights, the saucer, missing time, the Smoking Clawd.
    Shot(name: "woods", start: 9.0, end: 18.5, into: .cut) { ctx, local, t in filesWoods(ctx, local: local, t: t) },
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
        brawl(ctx, .clawdFiles, local: local, t: t, drop: true, chrome: false)
        badge("DESKTOP MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Now they're a pixel-art paranormal brawl", ctx, local: local, start: 0.35, y: 900)
        caption("along the bottom of your screen. They fight while they work.", ctx, local: local, start: 0.6, y: 830, size: 40, color: yellow, weight: .bold)
    },
    Shot(name: "status", start: 27.1, end: 31.3) { ctx, local, t in
        let cast: [Cast] = [.hero(FilesHero.foxClawder), .villain(FilesVillain.grey), .villain(FilesVillain.flukeman), .hero(FilesHero.skinnard)]
        statusOf(ctx, local: local, t: t, cast: cast, badgeText: "THE CLAWD FILES", aside: "(\(cast[3].name), napping. Nobody tell the Director.)")
    },
    Shot(name: "agents", start: 31.3, end: 35.3) { ctx, local, t in
        agentsOf(ctx, local: local, t: t, guardCast: .hero(FilesHero.skinnard),
                 crew: [.hero(FilesHero.bytes), .hero(FilesHero.frohack), .hero(FilesHero.lanky), .hero(FilesHero.queequeg)],
                 line: "Every subagent gets to be a special agent.", badgeText: "THE CLAWD FILES")
    },
    Shot(name: "window", start: 35.3, end: 40.1) { ctx, local, t in
        windowShot(ctx, .clawdFiles, local: local, t: t, rise: true, needsAt: 2.5, at: .xFilesOffice)
        badge("WINDOW MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Prefer a window? The truth is in there.", ctx, local: local, start: 0.1, y: 955, size: 56)
        caption("A live card per session: what it's doing, your last prompt, every agent.", ctx, local: local, start: 0.4, y: 890, size: 32, color: yellow, weight: .bold)
    },
    Shot(name: "ais", start: 40.1, end: 44.5) { ctx, local, t in
        everyAI(ctx, local: local, t: t, cast: [.hero(FilesHero.foxClawder), .hero(FilesHero.danaScrawly), .villain(FilesVillain.smokingClawd),
                                                .villain(FilesVillain.grey), .villain(FilesVillain.flukeman), .villain(FilesVillain.bountyHunter),
                                                .villain(FilesVillain.tooms)])
    },
    // The end card: the X-Files office, the crew lines up, the title lands.
    Shot(name: "endcard", start: 44.5, end: 48.7) { ctx, local, t in
        blit(place(.xFilesOffice, floorRows: 34, t: t), ctx)
        ctx.setFillColor(CGColor(gray: 0, alpha: 0.45)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let crew: [(Cast, FightRole, AI)] = [(.hero(FilesHero.danaScrawly), .cheer, .desktop), (.hero(FilesHero.foxClawder), .none, .claude),
                                             (.villain(FilesVillain.smokingClawd), .none, .codex), (.villain(FilesVillain.grey), .none, .copilot),
                                             (.villain(FilesVillain.flukeman), .cheer, .qwen), (.villain(FilesVillain.bountyHunter), .none, .gemini)]
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
            filesTitle(ctx, center: CGPoint(x: Double(W) / 2, y: 760), scale: backOut((local - 0.35) / 0.4) * 0.55,
                       warp: 0.6 * (1 - clamp((local - 0.35) / 0.5)), t: t)
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

let filesBeats: [(key: Double, beat: Beat)] = [
    (2.4, ("THE OPENING TITLES", "The show's title sequence, in pixel art: a saucer over the treeline, a staring eye, a warped face, a ghost at the end of a corridor, a hand in red light, all in cold green with grain and flashes on the cuts.", "no text", "a slow echoing whistle over a rippling synth figure and a deep pad, in the manner of the show's theme but our own notes; low booms on the cuts")),
    (5.0, ("THE TRUTH", "Time-lapse clouds race past; THE TRUTH IS OUT THERE fades up in white, and the clouds part on the dark.", "THE TRUTH IS OUT THERE", "the whistle's long note, wind")),
    (7.4, ("THE TITLE", "THE CLAWD FILES flickers into place out of the dark in glowing green, its rows sliding out of line and settling, then breaks up again.", "THE CLAWD FILES", "a static crackle, the theme's chord")),
    (11.0, ("BELLEFLEUR WOODS", "Night in the woods. BELLEFLEUR WOODS / BELLEFLEUR, OREGON types itself in at the corner. Clawder and Scrawly come through the trees, flashlights sweeping.", "BELLEFLEUR WOODS / BELLEFLEUR, OREGON (typed)", "crickets, typewriter keys, footsteps in leaves")),
    (13.4, ("THE LIGHT", "A saucer slides over the treeline and hangs over Clawder; both flashlights swing up to it. Its beam comes down on him and he rises up into the light and out of sight.", "no text", "a low hum, rising; the beam's whoosh")),
    (16.0, ("MISSING TIME", "He's set back down where he stood, and MISSING TIME types itself out over his head as the saucer slips away. Scrawly: “Clawder? Clawder! What time is it?” In the trees, the Cigarette-Smoking Clawd strikes a match and lights up.", "MISSING TIME (typed)  ·  “Clawder? Clawder! What time is it?”", "typewriter keys, a match struck")),
    (20.0, ("THE HOOK", "Three busy terminals, slow push-in.", "“Three AIs. Nine agents. One very confused human.”  →  “Sound familiar?”", "keyboard clicks")),
    (24.8, ("DESKTOP MODE", "Fox Clawder against the Cigarette-Smoking Clawd; Scrawly trades shots with the Bounty Hunter.", "DESKTOP MODE  ·  “Now they're a pixel-art paranormal brawl along the bottom of your screen. They fight while they work.”", "shots")),
    (29.4, ("AT A GLANCE", "Fox Clawder working, the Grey thinking, the Flukeman's jumping NEEDS YOU, Skinnard sat down napping.", "“All fun and games, and you still see everything.”  ·  “(A.D. Walter Skinnard, napping. Nobody tell the Director.)”", "blips, alert beeps")),
    (33.5, ("SUBAGENTS", "Skinnard stands guard; the Lone Gunclawds and Queequeg arrive with their jobs on their labels.", "“Every subagent gets to be a special agent.”", "footsteps")),
    (38.1, ("WINDOW MODE", "The window in the X-Files office: Clawder against the Smoking Clawd, live cards tick, then a Codex card flips to NEEDS YOU.", "WINDOW MODE  ·  “Prefer a window? The truth is in there.”", "a ping")),
    (42.5, ("EVERY AI", "Seven sessions, one per AI outline; Claude's Fox Clawder a head taller against Codex's Smoking Clawd; Tooms in pi's pink.", "BRING YOUR OWN AI*  ·  “One AI plays everyone. Run two and they pick sides.”  ·  *README for the full list", "shots")),
    (47.5, ("END CARD", "The X-Files office: the crew lines up, THE CLAWD FILES flickers in and steadies.", "THE CLAWD FILES  ·  “Have fun. Keep track.”  ·  “One of many universes in Clawd Clash · free for macOS”  ·  github.com/rodclemen/clawd-clash", "the whistle, the final chord")),
]

extension Mix {
    /// A whistle: a pure tone sliding into `to`, a slow wobble on it, and its echo coming back softer, twice.
    func whistle(_ t: Double, _ dur: Double, _ from: Int, _ to: Int, vol: Double = 0.07) {
        for (k, (delay, v)) in [(0.0, 1.0), (0.42, 0.4), (0.84, 0.18)].enumerated() {
            tone(t + delay, dur, midi(from), to: midi(to), wave: .sine, vol: vol * v, attack: 0.08, release: 0.35, vibrato: 0.02 + 0.004 * Double(k))
        }
    }
    /// The saucer's hum: two low tones beating against each other.
    func saucerHum(_ t: Double, _ dur: Double, vol: Double = 0.06) {
        tone(t, dur, 55, wave: .sine, vol: vol, attack: 0.6, release: 0.6)
        tone(t, dur, 55.8, wave: .sine, vol: vol, attack: 0.6, release: 0.6)
        tone(t, dur, 220, to: 330, wave: .triangle, vol: vol * 0.25, attack: 0.8, release: 0.5, vibrato: 0.03)
    }

}

/// The opening's tune, in the manner of the show's theme (its sounds, not its melody): a rippling, echoing synth
/// figure in the minor, a deep pad underneath, and a slow whistle over the top with an echo behind it. Our own notes.
func filesTune(_ m: Mix, from t0: Double, bars: Int) {
    let bar = 2.0, step = bar / 8
    let chords: [[Int]] = [[57, 60, 64, 69], [53, 57, 60, 65], [55, 59, 62, 67], [52, 55, 59, 64]]   // Am F G Em
    for b in 0..<bars {
        let ch = chords[b % chords.count], s = t0 + Double(b) * bar
        for n in ch.prefix(3) { m.tone(s, bar, midi(n - 12), wave: .saw, vol: 0.022, attack: 0.5, release: 0.6) }   // the pad
        m.tone(s, bar, midi(ch[0] - 24), wave: .sine, vol: 0.14, attack: 0.2, release: 0.5)
        let order = [0, 2, 1, 3, 2, 1, 3, 2]                                       // the rippling figure, and its echo
        for (i, o) in order.enumerated() {
            let at = s + Double(i) * step, f = midi(ch[o] + 12)
            m.tone(at, step * 0.9, f, wave: .triangle, vol: 0.05, attack: 0.003, release: 0.04, decay: 0.12)
            m.tone(at + step * 1.5, step * 0.9, f, wave: .triangle, vol: 0.018, attack: 0.003, release: 0.04, decay: 0.12)
        }
    }
    // the whistle: (start, length, from, to) in midi notes, sliding in and holding
    let lead: [(Double, Double, Int, Int)] = [(0.8, 1.4, 76, 81), (2.4, 0.9, 79, 77), (3.3, 1.6, 77, 76), (5.2, 1.0, 74, 79),
                                              (6.3, 0.6, 79, 81), (6.9, 1.6, 84, 83)]
    for (s, d, from, to) in lead where s < Double(bars) * bar { m.whistle(t0 + s, d, from, to) }
}

/// The Clawd Files trailer's score and effects.
func filesSound(_ m: Mix) {
    let i0 = start("intro")
    m.noise(i0, 6.2, vol: 0.04, cutoff: 0.01, cutoffTo: 0.04, attack: 1.2, release: 0.6, seed: 31)       // the wind under it all
    filesTune(m, from: i0 + 0.2, bars: 4)
    for cut in [0.06, 0.2, 0.32, 0.44, 0.56, 0.66, 0.9] { m.boom(i0 + cut * 6.2, vol: 0.18) }
    let title = i0 + 6.2
    m.noise(title, 0.9, vol: 0.09, cutoff: 0.9, decay: 0.3, highpass: true, seed: 33)                     // the static crackle
    for n in [45, 52, 57, 60, 64] { m.tone(title + 0.1, 2.6, midi(n), wave: .saw, vol: 0.035, attack: 0.3, release: 1.2) }
    m.whistle(title + 0.4, 1.8, 81, 84, vol: 0.08)
    m.noise(i0 + 8.3, 0.7, vol: 0.1, cutoff: 0.9, highpass: true, seed: 34)
    let w = start("woods")
    for i in 0..<38 { m.tone(w + Double(i) * 0.25 + noise(i) * 0.05, 0.04, 4200 + noise(i * 3) * 600, wave: .sine, vol: 0.012, release: 0.02) }   // crickets
    m.typewriter(w + 0.6, 34, gap: FilesCaption.letter)
    for k in 0..<12 { m.step(w + 0.5 + Double(k) * 0.18, vol: 0.05) }
    for (s, ch) in [(0.0, [45, 52, 57]), (3.0, [41, 48, 53]), (6.0, [43, 50, 55])] {
        for n in ch { m.tone(w + s, 3.0, midi(n), wave: .saw, vol: 0.02, attack: 0.6, release: 0.6) }
    }
    m.saucerHum(w + saucerIn - 0.2, takenFor + 1.4)
    m.whoosh(w + takenAt + 0.6, 1.2, vol: 0.14)
    m.whoosh(w + takenAt + 2.3, 1.0, vol: 0.1)
    m.typewriter(w + takenAt + 0.72 * takenFor, 12, gap: 0.12 * takenFor / 12, vol: 0.1, bell: true)
    m.whistle(w + 6.2, 1.6, 76, 72, vol: 0.05)
    m.noise(w + smokerIn + 0.5, 0.25, vol: 0.12, cutoff: 0.5, decay: 0.1, highpass: true, seed: 35)        // the match
    groove(m, from: start("hook"), to: start("endcard"), fadeIn: 1.2)
    let hook = start("hook")
    for i in 0..<26 { m.click(hook + 0.2 + Double(i) * 0.13 + noise(i) * 0.06) }
    let desk = start("desktop"), deskEnd = end("desktop") + 1.3
    for (i, d) in [0.0, 0.12, 0.24, 0.32].enumerated() { m.step(desk + d + 0.3, vol: 0.1 + Double(i % 2) * 0.03) }
    for t in shotTimes(desk + 0.45, deskEnd, offset: 0) { m.pew(t, vol: 0.08) }
    for t in shotTimes(desk + 0.45, deskEnd, offset: blasterPeriod / 2) { m.pew(t, vol: 0.06) }
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
    m.noise(ec + 0.3, 0.5, vol: 0.06, cutoff: 0.9, decay: 0.2, highpass: true, seed: 36)
    for (s, d, chord) in [(0.0, 0.7, [57, 60, 64]), (0.7, 0.7, [53, 57, 60]), (1.4, 2.8, [52, 56, 59, 64])] {
        for n in chord { m.tone(ec + s, d, midi(n), wave: .saw, vol: 0.04, attack: 0.02, release: d > 1 ? 1.6 : 0.1) }
        m.tone(ec + s, d, midi(chord[0] - 24), wave: .sine, vol: 0.2, release: d > 1 ? 1.6 : 0.1)
    }
    m.whistle(ec + 1.4, 2.2, 76, 81, vol: 0.07)
    m.boom(ec + 0.35, vol: 0.4)
}

// MARK: The Stevie Clawdberg trailer

/// The Stevie Clawdberg trailer, as the tool asks for it.
struct ClawdbergReel: PromoReel {
    let name = "clawdberg", base = "stevie-clawdberg-promo", small = "Stevie-Clawdberg"
    let title = "STEVIE CLAWDBERG"
    let geminiTask = "gemini ▸ get it up to 88 mph"
    var shots: [Shot] { clawdbergShots }
    var beats: [(key: Double, beat: Beat)] { clawdbergBeats }
    func sound(_ m: Mix) { clawdbergSound(m) }
}

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
func inkLine(_ c: PixelCanvas, _ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, w: Int = 1, _ col: Px) {
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
let hvGround = 158.0, martyX = 150.0, docX = 52.0, carIn = 2.2, carStop = 3.0, doorUp = 3.1, hopIn = 3.5, doorDown = 4.0,
    carGo = 4.4, vanishAt = 5.6, biffIn = 7.2
/// The DeLorean is drawn at twice the cast's pixel size, so Marty fits in it.
let carScale = 2.0
/// Where the DeLorean's canvas starts (fx columns): parked with its door at Marty, and where it vanishes.
let carParked = martyX - 33 * carScale, carVanish = carParked + 90
/// The fire trails: from where the car hit 88 to where it vanished (its front wheel); the plate lands past them.
let trailFrom = carParked + 40 * carScale, trailTo = carVanish + 50 * carScale

/// The DeLorean's left edge (fx columns) and how fast it's going (0…1) at shot time `l`; nil when it's not there.
func deloreanAt(_ l: Double) -> (x: Double, speed: Double)? {
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
    drawDelorean(fc, ramp: door, lit: lit)
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

// MARK: The Clawd Royale teaser (every universe's cast in one scene)

/// `s` in Futura Condensed ExtraBold at `size`, centred on `c`: `color` inside a thick, round ink outline.
func inkLettered(_ s: String, _ c: CGPoint, size: CGFloat, color: NSColor, alpha: Double = 1, kern: CGFloat = 0) {
    let f = NSFont(name: "Futura-CondensedExtraBold", size: size) ?? .systemFont(ofSize: size, weight: .black)
    let base: [NSAttributedString.Key: Any] = [.font: f, .kern: kern]
    let sz = NSAttributedString(string: s, attributes: base).size()
    let p = NSPoint(x: c.x - sz.width / 2, y: c.y - sz.height / 2)
    var ink = base; ink[.foregroundColor] = NSColor(cgColor: inkColor)!.withAlphaComponent(alpha)
    var fill = base; fill[.foregroundColor] = color.withAlphaComponent(alpha)
    let stamp = NSAttributedString(string: s, attributes: ink), r = Double(size) * 0.06
    for k in 0..<16 {
        let a = Double(k) / 16 * 2 * .pi
        stamp.draw(at: NSPoint(x: p.x + cos(a) * r, y: p.y + sin(a) * r))
    }
    NSAttributedString(string: s, attributes: fill).draw(at: p)
}

/// CLAWD over ROYALE: yellow comic lettering with a heavy ink outline, set a little askew, like a stamp.
func royaleTitle(_ ctx: CGContext, center: CGPoint, scale s: Double, alpha: Double = 1) {
    ctx.saveGState()
    ctx.translateBy(x: center.x, y: center.y); ctx.scaleBy(x: s, y: s); ctx.rotate(by: 0.035)
    inkLettered("CLAWD", CGPoint(x: 0, y: 118), size: 130, color: yellow, alpha: alpha, kern: 8)
    inkLettered("ROYALE", CGPoint(x: 0, y: -38), size: 210, color: yellow, alpha: alpha, kern: 10)
    ctx.restoreGState()
}

/// A universe's menu bar emblem (`Theme.menuIcon`: Vader's helmet, the round shield, the C-shield), `px` screen pixels
/// a pixel, centred on `c` and turned by `angle`; ringed in ink, then white, so it reads on anything.
func emblem(_ u: Universe, _ ctx: CGContext, center c: CGPoint, px: Double, angle: Double = 0, alpha: Double = 1) {
    let icon = PixelCanvas(28, 26)
    Theme.of(u).menuIcon(icon, false)
    let e = PixelCanvas(32, 30)                     // room for the two rings
    let b = icon.buf
    for y in 0..<icon.h {
        for x in 0..<icon.w {
            let i = (y * icon.w + x) * 4, a = Double(b[i + 3])
            guard a > 0 else { continue }
            let un = { (v: UInt8) -> UInt8 in UInt8(min(255, Double(v) * 255 / a)) }   // the buffer is premultiplied
            e.px(x + 2, y + 2, Px(r: un(b[i]), g: un(b[i + 1]), b: un(b[i + 2]), a: b[i + 3]))
        }
    }
    e.addOutline(C(0x111018)); e.addOutline(C(0xFFFFFF))
    guard let img = e.makeImage() else { return }
    let w = Double(e.w) * px, h = Double(e.h) * px
    ctx.saveGState(); ctx.interpolationQuality = .none; ctx.setAlpha(CGFloat(alpha))
    ctx.translateBy(x: c.x, y: c.y); ctx.rotate(by: CGFloat(angle))
    ctx.draw(img, in: CGRect(x: -w / 2, y: -h / 2, width: w, height: h))
    ctx.restoreGState()
}

/// When the emblems slam together, and when the title stamps in (shot seconds into the collision).
let royaleSlam = 0.6, royaleStamp = 1.05

/// The three menu bar emblems fly in from three sides and slam together (KRA-KOOM!), and CLAWD ROYALE stamps in.
func royaleCollide(_ ctx: CGContext, local l: Double, t: Double) {
    let since = l - royaleSlam
    let shake = since > 0 && since < 0.35 ? (0.35 - since) * 70 : 0
    let mid = CGPoint(x: Double(W) / 2, y: Double(H) / 2)
    ctx.saveGState()
    ctx.translateBy(x: sin(t * 80) * shake, y: cos(t * 70) * shake)
    halftone(ctx, fullRect.insetBy(dx: -40, dy: -40), base: hexCG(0x1B2257), dot: hexCG(0x2E3C8C), step: 26)
    // the slam's burst, staying behind the title
    if since > 0 {
        let f = backOut(since / 0.3)
        starburst(ctx, center: mid, inner: 300 * f, outer: 540 * f, spikes: 18, color: hexCG(0xFFE04A), spin: l * 0.12)
        starburst(ctx, center: mid, inner: 230 * f, outer: 400 * f, spikes: 14, color: hexCG(0xE8332A), spin: -l * 0.16)
    }
    // the emblems: in from all round the frame, spinning, then knocked out to a row over the title
    let shown = Universe.offered, n = Double(shown.count), gap = min(320, 1500 / max(1, n - 1))
    let from = shown.indices.map { i -> (x: Double, y: Double, turn: Double) in
        let a = -Double.pi / 2 + 2 * .pi * Double(i) / n
        return (960 + cos(a) * 1500, 540 + sin(a) * 950, (i % 2 == 0 ? -1 : 1) * (0.8 + Double(i % 3) * 0.3))
    }
    let meet = shown.indices.map { i -> (x: Double, y: Double) in
        let a = -Double.pi / 2 + 2 * .pi * Double(i) / n
        return (960 + cos(a) * 190, 560 + sin(a) * 150)
    }
    let rest = shown.indices.map { i -> (x: Double, y: Double) in
        let k = Double(i) - (n - 1) / 2
        return (960 + k * gap, 975 - abs(k) * 14)
    }
    for (i, u) in shown.enumerated() {
        if since < 0 {
            let f = easeIn((l - 0.05) / (royaleSlam - 0.05))
            emblem(u, ctx, center: CGPoint(x: lerp(from[i].x, meet[i].x, f), y: lerp(from[i].y, meet[i].y, f)), px: 11,
                   angle: from[i].turn * (1 - f))
        } else {
            let f = backOut((since - 0.05) / 0.4)
            emblem(u, ctx, center: CGPoint(x: lerp(meet[i].x, rest[i].x, f), y: lerp(meet[i].y, rest[i].y, f)),
                   px: lerp(11, n > 5 ? 4.2 : 5, clamp(f)), angle: sin(since * 9) * 0.25 * max(0, 1 - since / 0.6))
        }
    }
    // the sound word, popping on the slam and gone as the title lands
    if since > 0 && l < royaleStamp + 0.15 {
        let p = backOut(since / 0.18), fade = 1 - clamp((l - royaleStamp + 0.05) / 0.2)
        inkLettered("KRA-KOOM!", mid, size: CGFloat(170 * p), color: NSColor(srgbRed: 0.88, green: 0.12, blue: 0.12, alpha: 1),
                    alpha: fade, kern: 6)
    }
    ctx.restoreGState()
    if since > 0 && since < 0.3 { ctx.setFillColor(CGColor(gray: 1, alpha: 0.9 * (1 - since / 0.3))); ctx.fill(fullRect) }   // the flash, unshaken
    // CLAWD ROYALE stamps down from big to its size, then the line under it
    if l > royaleStamp {
        let s = 1 + 1.4 * (1 - backOut((l - royaleStamp) / 0.3))
        royaleTitle(ctx, center: CGPoint(x: mid.x, y: mid.y - 20), scale: s * 0.95, alpha: clamp((l - royaleStamp) / 0.08))
    }
    let sub = royaleStamp + 0.35
    if l > sub {
        let f = backOut((l - sub) / 0.3), c = CGPoint(x: mid.x, y: 130)
        ctx.saveGState()
        ctx.translateBy(x: c.x, y: c.y); ctx.scaleBy(x: CGFloat(f), y: CGFloat(f)); ctx.translateBy(x: -c.x, y: -c.y)
        captionBox("UNIVERSES COLLIDE.", ctx, center: c, size: 46)
        ctx.restoreGState()
    }
}

/// A hero at `hx` against a villain at `vx` (fx units), facing each other in the roles their weapons give them, each
/// with its own name on its label.
func versus(_ hero: Cast, _ hx: Double, _ villain: Cast, _ vx: Double) -> (Actor, Actor) {
    let (rh, rv) = fightRoles(hero.weapon, villain.weapon)
    let side: Double = hx < vx ? 1 : -1
    let h = Actor(cast: hero, x: hx, facing: side, role: rh, label: hero.name, labelSize: 24)
    let v = Actor(cast: villain, x: vx, facing: -side, role: rv, label: villain.name, labelSize: 24)
    return (h, v)
}

/// Spider-Clawd swinging over everyone's heads on his web, from off the left at `start` (shot seconds), arc after arc,
/// to off the right: his actor and where his line is stuck (fx units), or nil when he's out of the frame.
let swingArc = 0.55, swingReach = 80.0, swingAngle = 55.0 * Double.pi / 180
func webSwing(_ l: Double, start: Double) -> (actor: Actor, anchor: (x: Double, y: Double))? {
    let u = (l - start) / swingArc
    guard u > 0, u < 3 else { return nil }
    let i = floor(u), th: Double = -swingAngle * cos(.pi * (u - i))
    let step = 2 * swingReach * sin(swingAngle)                 // so each arc ends where the next one starts
    let anchor = (x: 45 + step * i, y: -10.0)
    let hand = (x: anchor.x + swingReach * sin(th), y: anchor.y + swingReach * cos(th))
    let who = Cast.hero(MarvelHero.spiderMan)
    var a = Actor(cast: who, x: hand.x - 13, walking: true, label: who.name, labelSize: 24)   // the raised hand: (41, 22)
    a.lift = groundY - 44 - (hand.y - 22)
    return (a, anchor)
}

/// The crew in one of the app's places: heroes against villains from every universe, each as itself, `fights` going at
/// it (`also`: the rest), and the place's name in a caption box along the bottom; the top shaded for the captions.
func royaleScene(_ ctx: CGContext, _ loc: Location, t: Double, fights: [(Actor, Actor)], also: [Actor] = []) {
    set(ctx, loc, t: t)
    let shade = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [CGColor(gray: 0, alpha: 0.55), CGColor(gray: 0, alpha: 0)] as CFArray,
                           locations: [0, 1])!                  // so the captions read on a bright place
    ctx.drawLinearGradient(shade, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: Double(H) - 330), options: [])
    for (a, b) in fights { draw(a, ctx, t: t); draw(b, ctx, t: t) }
    for a in also { draw(a, ctx, t: t) }
    drawFX(fights, ctx, t: t)
    captionBox(loc.name.uppercased(), ctx, center: CGPoint(x: Double(W) / 2, y: 70), size: 30)
}

let royaleShots: [Shot] = [
    Shot(name: "meanwhile", start: 0, end: 3.0, into: .cut) { ctx, local, t in
        ctx.setFillColor(CGColor(gray: 0, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let line = "MEANWHILE, ACROSS THE UNIVERSES…"
        let n = Int(clamp((local - 0.3) / 1.6) * Double(line.count))
        let a = 1 - clamp((local - 2.6) / 0.35)
        if n > 0 { captionBox(String(line.prefix(n)), ctx, center: CGPoint(x: Double(W) / 2, y: Double(H) / 2), size: 54, alpha: a) }
    },
    // Every universe's menu bar emblem collides: KRA-KOOM!, and CLAWD ROYALE stamps in. Never a count of universes:
    // which ones take part may become a choice.
    Shot(name: "collide", start: 3.0, end: 6.5, into: .cut) { ctx, local, t in royaleCollide(ctx, local: local, t: t) },
    // The Mos Easy Cantina, a crew from every universe: Gandclawd duels Darth Vapor, Fox Clawder and a Dalick shoot it
    // out, Spider-Clawd swings over everyone.
    Shot(name: "crossover", start: 6.5, end: 11.0, into: .marvel(ComicTrip(kind: .burst, sound: .thwip))) { ctx, local, t in
        let (fox, dalick) = versus(.hero(FilesHero.foxClawder), 34, .villain(DoctorVillain.dalick), 104)
        let (gand, vapor) = versus(.hero(RingsHero.gandalf), 196, .villain(SWVillain.vader), 253)
        let swing = webSwing(local, start: 0.9)
        royaleScene(ctx, .cantina, t: t, fights: [(fox, dalick), (gand, vapor)], also: swing.map { [$0.actor] } ?? [])
        if let s = swing {                                          // his web line, from the raised hand up out of the frame
            let web = PixelCanvas(fxW, fxH), hand = s.actor.fighter.point(41, 22)
            web.glowLine(hand.x, hand.y, s.anchor.x, s.anchor.y, core: C(0xF4F4F8, 0.9), glow: C(0xFFFFFF, 0), coreR: 0.35, glowR: 0.4)
            blit(web, ctx)
        }
        caption("Nobody asked who'd win. We're answering anyway.", ctx, local: local, start: 1.0, y: 900, size: 58)
    },
    // A new place, Clawdvengers Tower: the same crew, and Thanoz drops in on Spider-Clawd.
    Shot(name: "hopMarvel", start: 11.0, end: 13.5, into: .marvel(ComicTrip(kind: .speedLines))) { ctx, local, t in
        let land = clamp((local - 0.4) / 0.5), since = local - 0.9
        if since > 0 && since < 0.3 { let sh = (0.3 - since) * 40; ctx.translateBy(x: sin(t * 90) * sh, y: cos(t * 80) * sh) }   // the landing
        let (fox, dalick) = versus(.hero(FilesHero.foxClawder), 26, .villain(DoctorVillain.dalick), 92)
        let (gand, vapor) = versus(.hero(RingsHero.gandalf), 150, .villain(SWVillain.vader), 207)
        var (spidey, thanoz) = versus(.hero(MarvelHero.spiderMan), 246, .villain(MarvelVillain.thanos), 304)
        thanoz.lift = 150 * (1 - easeIn(land))
        if land < 1 { spidey.role = .none; thanoz.role = .none }
        royaleScene(ctx, .avengersTower, t: t, fights: land < 1 ? [(fox, dalick), (gand, vapor)] : [(fox, dalick), (gand, vapor), (spidey, thanoz)],
                    also: land < 1 ? [spidey, thanoz] : [])
    },
    // And Gothamburg, by the Night Beacon: new match-ups, Han Yolo on the Dalick, Batclawd on Darth Vapor, Indiana Bones
    // on Thanoz.
    Shot(name: "hopDC", start: 13.5, end: 16.0,
         into: .dc(DCComicTrip(kind: .batSignal, caption: "MEANWHILE, IN \(Location.gotham.name.uppercased())…"))) { ctx, local, t in
        let (han, dalick) = versus(.hero(SWHero.han), 26, .villain(DoctorVillain.dalick), 92)
        let (bat, vapor) = versus(.hero(DCHero.batman), 150, .villain(SWVillain.vader), 207)
        let (indy, thanoz) = versus(.hero(ClawdbergHero.indianaBones), 246, .villain(MarvelVillain.thanos), 304)
        royaleScene(ctx, .gotham, t: t, fights: [(han, dalick), (bat, vapor), (indy, thanoz)])
    },
    // The end card: the icon's three panels, a crew from every universe lined up, the emblems and CLAWD ROYALE.
    Shot(name: "endcard", start: 16.0, end: 20.5) { ctx, local, t in
        coverPanels(ctx, t: t, fighters: false, dim: 0.45)
        let crew: [(Cast, FightRole, AI)] = [(.hero(ClawdbergHero.indianaBones), .cheer, .desktop), (.hero(RingsHero.gandalf), .cheer, .qwen),
                                             (.hero(DCHero.batman), .duel, .claude), (.villain(SWVillain.vader), .duel, .codex),
                                             (.villain(DoctorVillain.dalick), .cheer, .copilot), (.villain(MarvelVillain.thanos), .cheer, .gemini)]
        var placed: [Actor] = []
        for (i, (who, role, ai)) in crew.enumerated() {
            var a = Actor(cast: who, x: [28.0, 84, 140, 197, 252, 300][i], facing: i < 3 ? 1 : -1, role: role, ai: ai)
            a.lift = 8
            a.alpha = clamp((local - 0.15 - Double(i) * 0.05) / 0.2)
            draw(a, ctx, t: t + Double(i) * 0.3)
            placed.append(a)
        }
        if local > 0.5 { drawFX([(placed[2], placed[3])], ctx, t: t) }
        // One emblem per universe, the row centred however many there are (closer together if they'd run off the frame).
        let offered = Universe.offered, gap = min(200, Double(W - 160) / Double(offered.count))
        for (i, u) in offered.enumerated() {
            let f = backOut((local - 0.25 - Double(i) * 0.08) / 0.35)
            let x = Double(W) / 2 + (Double(i) - Double(offered.count - 1) / 2) * gap
            if f > 0 { emblem(u, ctx, center: CGPoint(x: x, y: 990), px: 4 * f) }
        }
        if local > 0.35 { royaleTitle(ctx, center: CGPoint(x: Double(W) / 2, y: 750), scale: backOut((local - 0.35) / 0.4) * 0.72) }
        caption("New in Clawd Clash", ctx, local: local, start: 0.6, y: 500, size: 56)
        let ff = easeOut((local - 0.9) / 0.3)
        if ff > 0, let icon = appIcon {
            let line = attributed("Free for macOS · github.com/rodclemen/clawd-clash", size: 44, weight: .bold, alpha: ff)
            let x = (Double(W) - 160 - line.size().width) / 2                 // the icon and the line, centred together
            ctx.setFillColor(CGColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 0.8 * ff)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: 170))
            ctx.saveGState(); ctx.setAlpha(CGFloat(ff)); ctx.interpolationQuality = .high
            ctx.draw(icon, in: CGRect(x: x, y: 20, width: 130, height: 130))
            ctx.restoreGState()
            line.draw(at: NSPoint(x: x + 160, y: 60))
        }
    },
]

let royaleOverlays: [Overlay] = [
    Overlay(start: 11.0, end: 16.0) { ctx, l in
        badge("CLAWD ROYALE · EVERY 10 MIN", ctx, alpha: clamp(l / 0.3))
        caption("A new place every ten minutes…", ctx, local: l, start: 0.2, y: 905, size: 54)
        caption("…from any universe.", ctx, local: l, start: 2.5, y: 840, size: 44, color: yellow, weight: .bold)
    },
]

let royaleBeats: [(key: Double, beat: Beat)] = [
    (1.8, ("MEANWHILE...", "Black screen. A yellow comic caption types itself out over a building drum roll.", "“MEANWHILE, ACROSS THE UNIVERSES…”", "typewriter keys, a snare roll")),
    (4.9, ("THE COLLISION", "Halftone blue. Every universe's menu bar emblem flies in from round the frame and they slam together: KRA-KOOM!, a white flash, a yellow and red burst; they bounce out to a row and CLAWD ROYALE stamps in.", "KRA-KOOM!  ·  CLAWD ROYALE  ·  “UNIVERSES COLLIDE.”", "whooshes, the big hit, a fanfare")),
    (8.4, ("THE CROSSOVER", "A FWIP! web burst into the Mos Easy Cantina: Gandclawd duels Darth Vapor, Fox Clawder and a Dalick shoot it out, Spider-Clawd swings over everyone on his web. Each has its name on its label.", "“Nobody asked who'd win. We're answering anyway.”", "the groove kicks in, sabers, blasters, web thwips")),
    (11.9, ("A NEW PLACE", "Speed lines into Clawdvengers Tower: the same crew, and Thanoz drops in on Spider-Clawd.", "CLAWD ROYALE · EVERY 10 MIN  ·  “A new place every ten minutes…”", "a whoosh, a thud, the gauntlet's crackle")),
    (15.1, ("FROM ANY UNIVERSE", "The Night Beacon transition into Gothamburg: new match-ups, Han Yolo against the Dalick, Batclawd against Darth Vapor, Indiana Bones against Thanoz.", "“…from any universe.”", "the clunk and the boom of the beacon")),
    (19.0, ("END CARD", "The icon's three panels, dimmed: a crew from every universe lines up, Batclawd duelling Darth Vapor, every universe's emblem pops in and CLAWD ROYALE lands.", "CLAWD ROYALE  ·  “New in Clawd Clash”  ·  “Free for macOS · github.com/rodclemen/clawd-clash”", "the closing chord")),
]

/// The Clawd Royale teaser's score and effects.
func royaleSound(_ m: Mix) {
    // the caption types itself out over a snare roll that builds to the slam
    let mw = start("meanwhile"), cl = start("collide"), slam = cl + royaleSlam
    for i in 0..<38 { m.type(mw + 0.3 + Double(i) / 38 * 1.6 + noise(i) * 0.02, vol: 0.16 + noise(i + 50) * 0.08) }
    m.tone(mw + 0.2, 3.4, midi(33), wave: .sine, vol: 0.05, attack: 1.0, release: 0.4)
    var r = mw + 0.5
    while r < slam - 0.03 {
        let f = (r - mw) / (slam - mw)
        m.snare(r, vol: 0.015 + 0.1 * f * f)
        r += f > 0.75 ? 1.0 / 24 : 1.0 / 14
    }
    // the emblems fly in, slam (a big hit), and the title stamps down to a fanfare
    for k in 0..<3 { m.whoosh(cl + 0.35 + Double(k) * 0.04, 0.6, vol: 0.12) }
    m.boom(slam, vol: 0.65); m.noise(slam, 1.8, vol: 0.14, cutoff: 0.9, decay: 0.55, highpass: true, seed: 3)
    m.snare(slam, vol: 0.2); m.kick(slam, vol: 0.4)
    for n in [48, 55, 60, 64, 67] { m.tone(slam, 1.4, midi(n), wave: .saw, vol: 0.05, release: 0.6, decay: 0.8) }
    let stamp = cl + royaleStamp
    m.clunk(stamp, vol: 0.3); m.boom(stamp, vol: 0.3)
    for (s, d, n) in [(0.0, 0.22, 67), (0.25, 0.22, 72), (0.5, 0.5, 76), (1.05, 0.22, 74), (1.3, 0.22, 76), (1.55, 0.9, 79)] as [(Double, Double, Int)] {
        m.tone(stamp + s, d, midi(n + 12), wave: .square(0.5), vol: 0.07, release: 0.08, vibrato: 0.006)
        m.tone(stamp + s, d, midi(n), wave: .saw, vol: 0.045, release: 0.08)
    }
    // the groove, from the web burst to the end card
    groove(m, from: start("crossover") - 0.5, to: start("endcard"), fadeIn: 1.0)
    // the fights: the saber duel and the shoot-out run through all three places, Spider-Clawd's web lines, Thanoz' gauntlet
    let cr = start("crossover"), hm = start("hopMarvel"), hd = start("hopDC"), se = start("endcard")
    m.hum(cr, hd - cr, vol: 0.022)
    for t in clashTimes(cr, hd) { m.clash(t, vol: 0.1) }
    for t in shotTimes(cr, se, offset: 0) { m.pew(t, vol: 0.07) }
    for t in shotTimes(cr, se, offset: blasterPeriod / 2) { m.pew(t, vol: 0.05) }
    for k in 0..<3 { m.thwip(cr + 0.9 + Double(k) * swingArc, vol: 0.12) }
    m.boom(hm + 0.9, vol: 0.3)
    m.crackle(hm + 0.9, se - hm - 0.9, vol: 0.035)
    for t in shotTimes(hd, se, offset: 0) { m.thwip(t, vol: 0.06); m.clash(t + boltArrival * blasterPeriod, vol: 0.06) }
    for s in shots { transitionSound(m, s) }
    // the end card: the closing chord
    let ec = start("endcard")
    for (s, d, chord, lead) in [(0.0, 0.7, [53, 57, 60, 65], 81), (0.7, 0.7, [55, 59, 62, 67], 83), (1.4, 2.8, [57, 61, 64, 69], 85)] {
        for n in chord { m.tone(ec + s, d, midi(n), wave: .saw, vol: 0.045, attack: 0.02, release: d > 1 ? 1.6 : 0.1) }
        m.tone(ec + s, d, midi(lead), wave: .square(0.5), vol: 0.06, release: d > 1 ? 1.6 : 0.1, vibrato: 0.006)
        m.tone(ec + s, d, midi(chord[0] - 24), wave: .sine, vol: 0.2, release: d > 1 ? 1.6 : 0.1)
    }
    m.boom(ec + 0.35, vol: 0.45)
    m.noise(ec + 1.4, 2.5, vol: 0.08, cutoff: 0.9, decay: 0.8, highpass: true, seed: 8)
    for t in clashTimes(ec + 0.5, duration) { m.clash(t, vol: 0.08) }
}

// MARK: The Clawd of the Rings trailer

/// The Clawd of the Rings trailer, as the tool asks for it.
struct RingsReel: PromoReel {
    let name = "clawdoftherings", base = "clawd-of-the-rings-promo", small = "Clawd-of-the-Rings"
    var title: String { Universe.middleEarth.title.uppercased() }
    let geminiTask = "gemini ▸ hide the ring from the logs"
    var shots: [Shot] { ringsShots }
    var beats: [(key: Double, beat: Beat)] { ringsBeats }
    func sound(_ m: Mix) { ringsSound(m) }
}

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
func ringBandDistance(_ dx: Double, _ dy: Double, rx: Double, ry: Double) -> Double {
    let u: Double = dx / rx, v: Double = dy / ry
    let e: Double = (u * u + v * v).squareRoot()
    let grad: Double = (u * u / (rx * rx) + v * v / (ry * ry)).squareRoot()
    guard grad > 1e-9 else { return -1e9 }
    return (e - 1) * e / grad
}

/// The One Ring in pixel art, like the sprites (6 screen pixels to the art pixel): a gold band `r` screen pixels round,
/// its width squashed by `squash` (a spin seen edge-on), its gold in bands, lit on its upper-left rim and shaded on the
/// inner one, with a glint; and (`glow` 0…1) fire-letters waking along it, a pixel or three each: not real letters.
func oneRing(_ ctx: CGContext, center c: CGPoint, radius r: Double, squash: Double, glow: Double, alpha: Double) {
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
func drawShadowed(_ a: Actor, _ ctx: CGContext, t: Double, dark: Double) {
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
func shireTune(_ m: Mix, at t0: Double, bars: Int, vol: Double = 0.05) {
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

// MARK: The Clawd Slayer trailer

/// The Clawd Slayer trailer, as the tool asks for it.
struct SlayerReel: PromoReel {
    let name = "slayer", base = "clawd-slayer-promo", small = "Clawd-Slayer"
    var title: String { Universe.slayer.title.uppercased() }
    let geminiTask = "gemini ▸ stake the flaky test"
    var shots: [Shot] { slayerShots }
    var beats: [(key: Double, beat: Beat)] { slayerBeats }
    func sound(_ m: Mix) { slayerSound(m) }
}

/// The end card's line under "Have fun. Keep track.": never a count of universes.
let slayerTagline = "One of many universes in Clawd Clash · free for macOS"

/// A Clawd Slayer character's name, as the app has it.
func slayerName(_ h: SlayerHero) -> String { Cast.hero(h).name }
func slayerName(_ v: SlayerVillain) -> String { Cast.villain(v).name }

/// The title's letters, as the opening titles brush them: each a width and its strokes, in units of a letter 8.2 tall.
let slayerTitleGlyphs: [Character: (w: Double, strokes: [[(Double, Double)]])] = [
    "C": (5, [[(5, 6.8), (3.4, 8), (1.4, 7.4), (0.2, 5), (0.2, 3), (1.3, 0.6), (3.3, 0), (5.2, 1)]]),
    "L": (4.6, [[(0.6, 8.2), (0.6, 0)], [(0.2, 0.2), (4.8, 0)]]),
    "A": (5.4, [[(0, 0), (2.7, 8.2)], [(2.5, 8.2), (5.4, 0)], [(1.0, 3.0), (4.2, 3.4)]]),
    "W": (6.6, [[(0, 8.2), (1.5, 0)], [(1.4, 0.2), (3.3, 5.6)], [(3.3, 5.6), (5.0, 0)], [(5.0, 0.2), (6.6, 8.2)]]),
    "D": (5.2, [[(0.6, 8.2), (0.6, 0)], [(0.2, 8), (3.1, 7.7), (4.8, 5.6), (4.9, 2.6), (3.2, 0.4), (0.2, 0)]]),
    "S": (5, [[(5, 7), (3.3, 8.1), (1.0, 7.5), (0.6, 5.3), (2.6, 4.2), (4.5, 3.1), (4.5, 1.0), (2.5, 0), (0, 0.9)]]),
    "Y": (5.4, [[(0, 8.2), (2.7, 4)], [(5.4, 8.2), (2.6, 4)], [(2.7, 4.2), (2.7, 0)]]),
    "E": (4.8, [[(0.6, 8.2), (0.6, 0)], [(0.2, 8), (4.8, 8.2)], [(0.6, 4.2), (3.9, 4.4)], [(0.2, 0), (5.0, 0.2)]]),
    "R": (5.4, [[(0.6, 0), (0.6, 8.2)], [(0.2, 8), (3.4, 8.1), (4.9, 6.9), (4.8, 5.1), (3.3, 4.2), (0.6, 4.2)], [(1.6, 4.4), (3.6, 2.0), (5.6, -0.2)]]),
]

/// The title laid out as the opening titles lay it on a screen: CLAWD smaller over SLAYER, slanted a little and tilted
/// 20° up to the right, every stroke a list of points in pixels of a `slayerTitleW`×`slayerTitleH` canvas (y up);
/// SLAYER's L has a stake for a stem, laid out upright and drawn through `tilt`.
let slayerTitleW = 150, slayerTitleH = 100
struct SlayerTitleLayout {
    var strokes: [(points: [CGPoint], width: Double)] = []
    var footStroke = -1
    var stake: (x: Double, top: Double, bottom: Double, width: Double) = (0, 0, 0, 0)
    var tilt = CGAffineTransform.identity
    var u = 1.0

    init() {
        let W = Double(slayerTitleW), H = Double(slayerTitleH), gap = 1.3, small = 0.72
        func width(_ s: String) -> Double { s.reduce(0) { $0 + (slayerTitleGlyphs[$1]?.w ?? 3) } + gap * Double(s.count - 1) }
        let top = width("CLAWD"), bottom = width("SLAYER")
        u = min(W * 0.84 / bottom, H * 0.7 / (8.2 * (1 + small) + 2.4))
        let block = 8.2 * (1 + small) * u + 2.4 * u, yb = (H - block) / 2
        place("CLAWD", x: (W - top * u * small) / 2, y: yb + (8.2 + 2.4) * u, u: u * small, gap: gap, stakeL: false)
        place("SLAYER", x: (W - bottom * u) / 2, y: yb, u: u, gap: gap, stakeL: true)
        // Tilted 20° up to the right about the middle, and shrunk to fit (as the opening titles do).
        let a = 20 * Double.pi / 180, mid = CGPoint(x: W / 2, y: H / 2)
        let turn = CGAffineTransform(translationX: mid.x, y: mid.y).rotated(by: a).translatedBy(x: -mid.x, y: -mid.y)
        let st = stake
        let all = (strokes.flatMap { $0.points } + [CGPoint(x: st.x - st.width / 2, y: st.top), CGPoint(x: st.x + st.width / 2, y: st.top),
                                                     CGPoint(x: st.x, y: st.bottom)]).map { $0.applying(turn) }
        let x0 = all.map(\.x).min()!, x1 = all.map(\.x).max()!, y0 = all.map(\.y).min()!, y1 = all.map(\.y).max()!
        let s = min(1, W * 0.9 / Double(x1 - x0), H * 0.9 / Double(y1 - y0))
        tilt = turn.concatenating(CGAffineTransform(translationX: -(x0 + x1) / 2, y: -(y0 + y1) / 2))
            .concatenating(CGAffineTransform(scaleX: s, y: s)).concatenating(CGAffineTransform(translationX: mid.x, y: mid.y))
        strokes = strokes.map { ($0.points.map { $0.applying(tilt) }, $0.width * s) }
        u *= s
    }

    private mutating func place(_ word: String, x: Double, y: Double, u: Double, gap: Double, stakeL: Bool) {
        var cx = x
        let slant = 0.16
        for (n, ch) in word.enumerated() {
            guard let g = slayerTitleGlyphs[ch] else { continue }
            let jitter = (noise(n * 19 + word.count) - 0.5) * 0.5
            for (si, s) in g.strokes.enumerated() {
                if stakeL && ch == "L" && si == 0 {
                    stake = (x: cx + (0.6 + 4.1 * slant) * u, top: y + 9.6 * u, bottom: y - 1.6 * u, width: u * 1.6)
                    footStroke = strokes.count
                    continue
                }
                let pts = s.map { p in CGPoint(x: cx + (p.0 + p.1 * slant) * u, y: y + (p.1 + jitter * (p.0 / max(1, g.w))) * u) }
                strokes.append((pts, u * 1.15))
            }
            cx += (g.w + gap) * u
        }
    }
}
let slayerTitleLayout = SlayerTitleLayout()

/// One brush stroke along `pts`, dragged on as far as `p` (0…1) of its length: dabs under a pixel apart, ragged in
/// width and tapering at both ends.
func slayerBrush(_ c: CGContext, _ pts: [CGPoint], width: Double, upTo p: Double, seed: Int, color: CGColor) {
    guard pts.count > 1 else { return }
    var lens: [Double] = [0]
    for i in 1..<pts.count { lens.append(lens[i - 1] + hypot(Double(pts[i].x - pts[i - 1].x), Double(pts[i].y - pts[i - 1].y))) }
    let total = lens.last ?? 0
    guard total > 0 else { return }
    c.setFillColor(color)
    var seg = 1, d = 0.0, i = 0
    while d <= total * p {
        while seg < pts.count - 1 && lens[seg] < d { seg += 1 }
        let a = pts[seg - 1], b = pts[seg]
        let f = lens[seg] - lens[seg - 1] > 0 ? (d - lens[seg - 1]) / (lens[seg] - lens[seg - 1]) : 0
        let x = Double(a.x) + Double(b.x - a.x) * f, y = Double(a.y) + Double(b.y - a.y) * f
        let k = d / total
        let taper = min(1, 0.55 + k * 4) * (k > 0.8 ? 1 - (k - 0.8) * 2.2 : 1)
        let hw = width / 2 * taper * (0.82 + 0.36 * noise(seed * 131 + i))
        c.fill(CGRect(x: floor(x - hw), y: floor(y - hw + (noise(seed * 77 + i) - 0.5) * 1.2), width: max(1, (hw * 2).rounded()),
                      height: max(1, (hw * 2).rounded())))
        d += 0.7; i += 1
    }
}

/// The title as pixel art: CLAWD SLAYER brushed on in bone-white over a red under-stroke, `write` (0…1) of the strokes
/// down, and the whittled stake falling point first into place as SLAYER's L as `stake` goes 0…1.
func slayerTitleImage(write: Double, stake: Double) -> CGImage? {
    guard let g = CGContext(data: nil, width: slayerTitleW, height: slayerTitleH, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
    g.setShouldAntialias(false)
    let L = slayerTitleLayout, total = L.strokes.count
    for pass in 0..<2 {
        let off = pass == 0 ? L.u * 0.22 : 0
        let col = hexCG(pass == 0 ? 0x9E1424 : 0xEDE8DC)
        for (i, s) in L.strokes.enumerated() {
            var p = clamp(write * Double(total) * 1.15 - Double(i))
            if i == L.footStroke { p = min(p, clamp(stake * 4 - 3)) }      // the L's foot only once its stem has landed
            guard p > 0 else { continue }
            slayerBrush(g, s.points.map { CGPoint(x: $0.x + off, y: $0.y - off) }, width: s.width, upTo: p, seed: i * 37 + 5, color: col)
        }
    }
    if stake > 0 {
        g.saveGState(); defer { g.restoreGState() }
        g.concatenate(L.tilt)
        let pivot = CGPoint(x: L.stake.x, y: (L.stake.top + L.stake.bottom) / 2)    // leaning as the letters do
        g.translateBy(x: pivot.x, y: pivot.y); g.rotate(by: -atan(0.16)); g.translateBy(x: -pivot.x, y: -pivot.y)
        let st = L.stake, fall = (1 - stake * stake) * Double(slayerTitleH) * 1.1
        let x = st.x, top = st.top + fall, bottom = st.bottom + fall, wd = st.width
        func shape(_ dx: Double, _ dy: Double, _ hex: UInt32, inset: Double = 0) {
            g.setFillColor(hexColor(hex))
            g.beginPath()
            g.move(to: CGPoint(x: x - wd / 2 + dx + inset, y: top + dy - inset))
            g.addLine(to: CGPoint(x: x + wd / 2 + dx - inset, y: top + dy - inset))
            g.addLine(to: CGPoint(x: x + wd * 0.42 + dx - inset, y: bottom + wd * 2.2 + dy))
            g.addLine(to: CGPoint(x: x + dx, y: bottom + dy + inset))
            g.addLine(to: CGPoint(x: x - wd * 0.42 + dx + inset, y: bottom + wd * 2.2 + dy))
            g.closePath(); g.fillPath()
        }
        shape(L.u * 0.22, -L.u * 0.22, 0x9E1424)
        shape(0, 0, 0x2A1606)
        shape(0, 0, 0xB07A44, inset: 1)
        g.setFillColor(hexColor(0xD8A868))
        g.fill(CGRect(x: floor(x - wd / 2 + 1), y: floor(bottom + wd * 2.2), width: max(1, floor(wd * 0.25)), height: floor(top - bottom - wd * 2.2 - 1)))
        g.setFillColor(hexColor(0xF0D8A8))
        g.fill(CGRect(x: floor(x - 1), y: floor(bottom + 1), width: 2, height: max(2, floor(wd * 1.2))))
    }
    return g.makeImage()
}

/// The title drawn `px` screen pixels to a pixel, centred on `center`, with a dark smudge behind it so it reads on a place.
func slayerTitle(_ ctx: CGContext, center: CGPoint, px: Double, alpha: Double = 1, write: Double = 1, stake: Double = 1) {
    guard alpha > 0.01, let img = slayerTitleImage(write: write, stake: stake) else { return }
    let w = Double(slayerTitleW) * px, h = Double(slayerTitleH) * px
    let r = CGRect(x: (center.x - w / 2).rounded(), y: (center.y - h / 2).rounded(), width: w, height: h)
    ctx.saveGState(); ctx.setAlpha(CGFloat(alpha))
    ctx.setShadow(offset: .zero, blur: 50, color: CGColor(gray: 0, alpha: 0.85))
    ctx.setFillColor(CGColor(gray: 0, alpha: 0.35)); ctx.fillEllipse(in: r.insetBy(dx: w * 0.12, dy: h * 0.2))
    ctx.setShadow(offset: .zero, blur: 0, color: nil)
    ctx.interpolationQuality = .none
    ctx.draw(img, in: r)
    ctx.restoreGState()
}

/// The opening titles, played over the whole intro: the trip's art, slowed to the shot, from black to the town sign.
let slayerTitlesTrip = SlayerTrip(kind: .titles, from: .slayerLibrary, to: .slayerTownSign)
/// The intro's length, and where in it the trip's beats land (shot-local seconds).
let slayerIntroLength = 9.0
func slayerIntroAt(_ k: Double) -> Double { k * slayerIntroLength }
/// What the titles open from (black) and clear onto (the set piece's first frame), made the first time they're needed
/// (a `static let`, since the frame's globals further down aren't set up yet when this file's globals are).
enum SlayerStills {
    static let black: CGImage? = shotImage { $0.setFillColor(CGColor(gray: 0, alpha: 1)); $0.fill(fullRect) }
    static let sign: CGImage? = shotImage { slayerHomecoming($0, local: 0, t: slayerIntroLength) }
}

/// The opening titles: an organ chord over a night sky and a swelling moon; then hard cuts, punk-fast (a vampire in
/// game face, a gravestone in the fog, an old book flaring open); the four leads slam in as silhouettes against the
/// moon; CLAWD SLAYER is brushed on, its stake slamming down; and the black is swept off onto the town sign.
func slayerIntro(_ ctx: CGContext, local l: Double, t: Double) {
    guard let old = SlayerStills.black, let new = SlayerStills.sign else { return }
    slayerTitlesTrip.draw(ctx, old: old, new: new, k: clamp(l / slayerIntroLength), in: fullRect)
}

/// The set piece's timings (shot-local seconds): the DeSoto at the sign, then Restfield.
let homeCarIn = 0.4, homeCarStop = 1.75, homeDoor = 1.85, homeSpyke = 2.0, homeCut = 4.0
let homeGround = 150.0, homeCarScale = 2.0, homeCarFrom = -150.0, homeCarTo = 172.0
/// In the cemetery (seconds after the cut): the fledglings rise, the bus pulls up, the gang gets off and fights,
/// dawn breaks and the vampires go up in dust.
let homeRise: [Double] = [0.1, 0.3, 0.5], homeRiseLength = 0.8
let homeBusIn = 0.6, homeBusStop = 1.4, homeBusDoor = 1.5, homeOff: [Double] = [1.6, 1.75, 1.9]
let homeFlip = 2.2, homeFight = 2.85, homeDawn = 3.2, homeDust: [Double] = [3.5, 3.7, 3.9]
let homeFledglingXs: [Double] = [217, 256, 296], homeHeroXs: [Double] = [150, 118, 86]
let homeBusLeft = -50.0

/// The DeSoto's left edge (fx columns) at shot time `l`, and how fast it's going (0…1).
func deSotoAt(_ l: Double) -> (x: Double, speed: Double) {
    guard l > homeCarIn else { return (homeCarFrom, 1) }
    let f = clamp((l - homeCarIn) / (homeCarStop - homeCarIn))
    return (lerp(homeCarFrom, homeCarTo, easeOut(f)), 1 - f)
}

/// The sign's board and posts in the town sign's frame-sized canvas, and the moment the car's nose reaches the first post.
let homeSignFrame = Scenes.slayerTownSignFrame(PixelCanvas(fxW, fxH), fxH - 30)
let homeSignBox: (x: Int, y: Int, w: Int, h: Int) = {
    let b = homeSignFrame.board
    return (b.x - 2, b.y - 2, b.w + 4, fxH - 30 - b.y + 2)
}()
let homeCrash: Double = {
    let post = Double(homeSignFrame.board.x + homeSignFrame.board.w / 6)
    var l = homeCarIn
    while l < homeCarStop && deSotoAt(l).x + 62 * homeCarScale < post { l += 0.005 }
    return l
}()

/// The town sign with the sign itself painted out: the same place drawn four times as wide (so the board and the
/// lamp are far off to the right), its pixels under the board copied over the board.
let homeSignGone: PixelCanvas = {
    let wide = PixelCanvas(fxW * 4, fxH)
    Location.slayerTownSign.drawStatic(wide, floorRows: 30)
    return wide
}()
/// The board and its posts, cut out of the place to be smashed off it: just the pixels that differ from the place
/// without them.
let homeBoard: CGImage? = {
    let c = PixelCanvas(fxW, fxH); Location.slayerTownSign.drawStatic(c, floorRows: 30)
    let b = homeSignBox, out = PixelCanvas(b.w, b.h), gone = homeSignGone
    for y in 0..<b.h {
        for x in 0..<b.w {
            let i = ((b.y + y) * c.w + b.x + x) * 4, j = ((b.y + y) * gone.w + b.x + x) * 4
            if (0..<3).allSatisfy({ c.buf[i + $0] == gone.buf[j + $0] }) { continue }
            out.px(x, y, Px(r: c.buf[i], g: c.buf[i + 1], b: c.buf[i + 2], a: c.buf[i + 3]))
        }
    }
    return out.makeImage()
}()

/// Pixel dust: a puff of grey-gold specks blowing up and away from (x, y), `k` 0…1 through it (fx units).
func slayerDustPuff(_ c: PixelCanvas, x: Double, y: Double, k: Double, seed: Int, count: Int = 60, spread: Double = 12) {
    guard k > 0, k < 1 else { return }
    for i in 0..<count {
        let a = noise(seed + i * 3) * 2 * .pi, sp = 0.3 + noise(seed + i * 3 + 1) * 0.7
        let dx = cos(a) * spread * sp * easeOut(k) + k * 22 * noise(seed + i * 3 + 2)    // the wind takes it to the right
        let dy = sin(a) * spread * 0.7 * sp * easeOut(k) - k * 14 * sp
        let col = [C(0xB8A890), C(0x8A8070), C(0xE0C890), C(0x6A6458)][i % 4]
        c.px(Int(x + dx), Int(y + dy), col.alpha(1 - k * k))
    }
}

/// "Home sweet home." Night at the Welcome to Sunnydale sign: Spyke's DeSoto tears in and smashes straight through it,
/// skids to a stop and he steps out. Then Restfield: fledglings claw up out of their graves, the yellow school bus
/// pulls up, Buffy flips her stake, Willow's green spell lights the graves, Giles fires his crossbow, and as dawn
/// breaks the vampires go up in dust.
func slayerHomecoming(_ ctx: CGContext, local l: Double, t: Double) {
    if l < homeCut { slayerSignCrash(ctx, local: l, t: t) } else { slayerRestfield(ctx, local: l - homeCut, t: t) }
}

func slayerSignCrash(_ ctx: CGContext, local l: Double, t: Double) {
    let since = l - homeCrash
    if since > 0 && since < 0.45 { let sh = (0.45 - since) * 36; ctx.translateBy(x: sin(t * 90) * sh, y: cos(t * 77) * sh) }
    let sign = place(.slayerTownSign, floorRows: 30, t: l + 0.5)
    if since > 0 {
        let b = homeSignBox
        for y in b.y..<(b.y + b.h) {
            for x in b.x..<(b.x + b.w) {
                let i = (y * homeSignGone.w + x) * 4, g = homeSignGone.buf
                sign.px(x, y, Px(r: g[i], g: g[i + 1], b: g[i + 2], a: 255))
            }
        }
        // Splintered stumps left of the two posts.
        let bd = homeSignFrame.board
        for px in [bd.x + bd.w / 6, bd.x + bd.w * 5 / 6 - 3] {
            let g = fxH - 30
            sign.rect(px, g - 5, 4, 5, C(0x4A3020)); sign.rect(px, g - 5, 1, 5, C(0x6A4A30))
            sign.px(px + 1, g - 6, C(0x6A4A30)); sign.px(px + 3, g - 7, C(0x4A3020))
        }
    }
    blit(sign, ctx)
    onStage(ctx, fullRect, scale: 6, ground: homeGround) {
        let fx = PixelCanvas(fxW, fxH)
        let car = deSotoAt(l)
        // Headlight beams ahead of the car, and the skid's dust under its wheels.
        if l > homeCarIn - 0.3 {
            let nose = car.x + 63 * homeCarScale, beam = homeGround - 15 * homeCarScale
            for k in 0..<3 { fx.rect(Int(nose), Int(beam) - k, 70 - k * 18, 1 + 2 * k, C(0xFFF4D0, 0.10)) }
        }
        if car.speed < 0.6 && l < homeCarStop + 0.6 {
            for w in [12.0, 52.0] { slayerDustPuff(fx, x: car.x + w * homeCarScale, y: homeGround - 2, k: clamp((l - homeCrash) / 1.6), seed: Int(w), count: 30, spread: 8) }
        }
        // The board and posts, smashed off and flung tumbling up and over the car.
        if since > 0, let board = homeBoard {
            let b = homeSignBox
            let pieces = 3, pw = b.w / pieces
            for i in 0..<pieces {
                guard let part = board.cropping(to: CGRect(x: i * pw, y: 0, width: i == pieces - 1 ? b.w - i * pw : pw, height: b.h)) else { continue }
                let vx = 70.0 + Double(i) * 34, vy = 90.0 - Double(i) * 14, spin = (i % 2 == 0 ? 1.0 : -1.0) * (5 + Double(i) * 2)
                let cx = Double(b.x + i * pw) + Double(pw) / 2 + vx * since, cy = Double(b.y) + Double(b.h) / 2 - vy * since + 160 * since * since
                ctx.saveGState(); ctx.interpolationQuality = .none
                ctx.translateBy(x: cx * 6, y: Double(H) - cy * 6); ctx.rotate(by: CGFloat(spin * since))
                ctx.draw(part, in: CGRect(x: -Double(part.width) * 3, y: -Double(b.h) * 3, width: Double(part.width) * 6, height: Double(b.h) * 6))
                ctx.restoreGState()
            }
            // Splinters and dust where it hit.
            let hit = Double(homeSignFrame.board.x + homeSignFrame.board.w / 6)
            slayerDustPuff(fx, x: hit, y: homeGround - 14, k: since / 1.2, seed: 500, count: 90, spread: 26)
            for i in 0..<26 where since < 1.4 {
                let a = 0.3 + noise(i + 600) * 2.4, sp = 40 + noise(i + 601) * 90
                let x = hit + cos(a) * sp * since + 30 * since, y = homeGround - 18 - sin(a) * sp * since + 120 * since * since
                if y < homeGround { fx.rect(Int(x), Int(y), 2, 1, [C(0xC8B080), C(0x6A4A30), C(0xEDE4C8)][i % 3]) }
            }
        }
        // The DeSoto, lit, its back door swinging open; Spyke steps out and looks the town over.
        let door = clamp((l - homeDoor) / 0.25)
        let rc = PixelCanvas(Ride.width, Ride.height)
        drawRide(rc, .deSoto, ramp: door, engines: true, gear: true)
        rc.addOutline(C(0xFFFFFF, 0.92))
        if let img = rc.makeImage() {
            ctx.saveGState(); ctx.interpolationQuality = .none
            let bob = car.speed > 0.05 ? (Int(t * 20) % 2 == 0 ? 0.0 : 1.0) : 0
            ctx.draw(img, in: CGRect(x: car.x * S, y: stageH - homeGround * S + bob * S, width: Double(Ride.width) * S * homeCarScale,
                                     height: Double(Ride.height) * S * homeCarScale))
            ctx.restoreGState()
        }
        if l > homeSpyke {
            let k = easeOut((l - homeSpyke) / 0.6)
            var spyke = Actor(cast: .hero(SlayerHero.spyke), x: lerp(homeCarTo + 30, homeCarTo - 14, k), facing: -1, mode: .idle)
            spyke.walking = k < 0.97
            spyke.alpha = clamp((l - homeSpyke) / 0.12)
            draw(spyke, ctx, t: t)
            if l > homeSpyke + 0.45 {
                let pop = backOut((l - homeSpyke - 0.45) / 0.25)
                balloon("Home sweet home.", ctx, center: CGPoint(x: 820, y: 640), tail: headPoint(spyke), size: max(4, 44 * CGFloat(pop)), width: 520)
            }
        }
        if let img = fx.makeImage() { ctx.saveGState(); ctx.interpolationQuality = .none; ctx.draw(img, in: fullRect); ctx.restoreGState() }
    }
    if since > 0 && since < 0.12 { ctx.setFillColor(CGColor(red: 1, green: 0.95, blue: 0.85, alpha: 0.5 * (1 - since / 0.12))); ctx.fill(fullRect) }
}

func slayerRestfield(_ ctx: CGContext, local c: Double, t: Double) {
    blit(place(.slayerCemetery, floorRows: 30, t: t), ctx)
    let dawn = easeOut((c - homeDawn) / 1.3)
    // Dawn: the sky blushes from the horizon up, a line of light coming up behind the hills.
    if dawn > 0 {
        let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                           colors: [hexColor(0xFF9A4A, 0.55 * dawn), hexColor(0xFF6A5A, 0.3 * dawn), hexColor(0x6A4A8A, 0.0)] as CFArray,
                           locations: [0, 0.4, 1])!
        ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: Double(H) - 100 * 6), end: CGPoint(x: 0, y: Double(H)), options: [])
        ctx.setFillColor(hexColor(0xFFE0A0, 0.5 * dawn)); ctx.fill(CGRect(x: 0, y: Double(H) - 101 * 6, width: Double(W), height: 6))
    }
    let floorY = stageH - homeGround * 6
    onStage(ctx, fullRect, scale: 6, ground: homeGround) {
        let fx = PixelCanvas(fxW, fxH)
        // The fledglings: first a hand, then the rest, clawing up out of the earth, a mound of dirt heaped round them.
        var vamps: [Actor] = []
        for (i, at) in homeRise.enumerated() {
            let x = homeFledglingXs[i]
            fx.ellipse(Int(x), Int(homeGround) - 1, 13, 3, C(0x2A1E16)); fx.ellipse(Int(x) - 2, Int(homeGround) - 2, 9, 2, C(0x3E2C1E))
            let r = clamp((c - at) / homeRiseLength)
            guard r > 0 else { continue }
            if r < 1 { for k in 0..<5 { fx.px(Int(x) - 6 + Int(noise(k + i * 9 + Int(t * 14)) * 12), Int(homeGround) - 3 - Int(noise(k + i * 5 + Int(t * 10)) * 6), C(0x4A3624)) } }
            let chase = easeOut((c - homeFight + 0.5) / 0.6)
            var v = Actor(cast: .villain(SlayerVillain.fledgling), x: x - (i == 0 ? 10 * chase : 0), facing: -1, mode: .idle)
            v.lift = -(1 - easeOut(r)) * 46
            vamps.append(v)
        }
        // The bus, pulling up and folding its door open.
        let bk = clamp((c - homeBusIn) / (homeBusStop - homeBusIn))
        let busX = lerp(-140, homeBusLeft, easeOut(bk))
        if c > homeBusIn {
            let bc = PixelCanvas(Ride.width, Ride.height)
            drawRide(bc, .schoolBus, ramp: clamp((c - homeBusDoor) / 0.2), engines: true, gear: true)
            bc.addOutline(C(0xFFFFFF, 0.92))
            if let img = bc.makeImage() {
                ctx.saveGState(); ctx.interpolationQuality = .none
                ctx.draw(img, in: CGRect(x: busX * S, y: stageH - homeGround * S, width: Double(Ride.width) * S * homeCarScale,
                                         height: Double(Ride.height) * S * homeCarScale))
                ctx.restoreGState()
            }
        }
        // The gang gets off and goes to it.
        let gang: [Cast] = [.hero(SlayerHero.buffyClawmers), .hero(SlayerHero.willowRosenclaw), .hero(SlayerHero.rupertGyles)]
        var heroes: [Actor] = []
        for (i, who) in gang.enumerated() where c > homeOff[i] {
            let k = easeOut((c - homeOff[i]) / 0.55), doorX = homeBusLeft + 44.5 * homeCarScale
            var a = Actor(cast: who, x: lerp(doorX, homeHeroXs[i], k), facing: 1, mode: .idle)
            a.walking = k < 0.97
            a.alpha = clamp((c - homeOff[i]) / 0.1)
            heroes.append(a)
        }
        // Who's dust, and how far through it.
        func dusted(_ i: Int) -> Double { clamp((c - homeDust[i]) / 0.7) }
        // The fight: Buffy's stake on the first, Willow's spell on the second, Giles's crossbow on the third.
        var pairs: [(Actor, Actor)] = []
        if c > homeFight {
            for i in 0..<min(heroes.count, vamps.count) {
                if dusted(i) > 0.3 { heroes[i].role = .cheer; continue }     // theirs is dust: a little cheer
                guard dusted(i) == 0 else { continue }
                let (rh, rv) = fightRoles(heroes[i].cast.weapon, vamps[i].cast.weapon)
                heroes[i].role = rh; vamps[i].role = rv
                pairs.append((heroes[i], vamps[i]))
            }
        }
        // Willow's green light on the graves.
        if heroes.count > 1, c > homeFight - 0.2, c < homeDust[1] + 0.3 {
            let w = heroes[1], glow = clamp((c - homeFight + 0.2) / 0.3) * (1 - clamp((c - homeDust[1]) / 0.3))
            fx.rect(0, 0, fxW, fxH, C(0x3CFF6A, 0.06 * glow))
            fx.ellipse(Int(w.x) + 50, Int(homeGround) - 2, 90, 7, C(0x5CFF7A, 0.2 * glow))
            fx.circle(Int(w.x) + 8, Int(homeGround) - 26, 26, C(0x5CFF7A, 0.1 * glow))
            fx.circle(Int(w.x) + 8, Int(homeGround) - 26, 12, C(0x8CFFA0, 0.14 * glow))
        }
        // Clipped to above the ground, so the fledglings come up out of it.
        ctx.saveGState(); ctx.clip(to: CGRect(x: 0, y: floorY - 6, width: Double(W), height: Double(H)))
        for (i, v) in vamps.enumerated() {
            let d = dusted(i)
            guard d < 0.25 else { continue }
            var vv = pairs.first(where: { $0.1.x == v.x })?.1 ?? v
            vv.alpha = 1 - d * 4
            draw(vv, ctx, t: t)
        }
        ctx.restoreGState()
        for (i, h) in heroes.enumerated() {
            if i == 0 && c > homeFlip && c < homeFight {      // Buffy flips her stake
                let len = h.cast.signatureLength ?? 2.0
                forcedHabit = HabitPlay(kind: .signature, e: (c - homeFlip) / (homeFight - homeFlip) * len, length: len)
                draw(h, ctx, t: t)
                forcedHabit = nil
            } else {
                draw(pairs.first(where: { $0.0.x == h.x })?.0 ?? h, ctx, t: t)
            }
        }
        drawFX(pairs, ctx, t: t)
        for i in vamps.indices { slayerDustPuff(fx, x: vamps[i].x, y: homeGround - 16, k: dusted(i), seed: 900 + i * 101, count: 110, spread: 14) }
        if let img = fx.makeImage() { ctx.saveGState(); ctx.interpolationQuality = .none; ctx.draw(img, in: fullRect); ctx.restoreGState() }
    }
    caption("In every terminal, a Clawd is chosen.", ctx, local: c, start: homeDust[0] - 0.2, y: 930, size: 60)
}

/// The end card: the library, the crew lined up, the title brushed on and its stake slamming down.
func slayerEndcard(_ ctx: CGContext, local: Double, t: Double) {
    let since = local - 1.05
    if since > 0 && since < 0.3 { let sh = (0.3 - since) * 30; ctx.translateBy(x: sin(t * 90) * sh, y: cos(t * 77) * sh) }
    blit(place(.slayerLibrary, floorRows: 34, t: t), ctx)
    ctx.setFillColor(CGColor(gray: 0, alpha: 0.35)); ctx.fill(CGRect(x: -40, y: -40, width: W + 80, height: H + 80))
    let crew: [(Cast, FightRole, AI)] = [(.hero(SlayerHero.rupertGyles), .cheer, .desktop), (.hero(SlayerHero.buffyClawmers), .none, .claude),
                                         (.villain(SlayerVillain.oldMaster), .none, .codex), (.villain(SlayerVillain.drusillah), .none, .copilot),
                                         (.hero(SlayerHero.spyke), .cheer, .qwen), (.hero(SlayerHero.willowRosenclaw), .none, .gemini)]
    var placed: [Actor] = []
    let (ra, rb) = fightRoles(crew[1].0.weapon, crew[2].0.weapon)
    for (i, (who, role, ai)) in crew.enumerated() {
        var a = Actor(cast: who, x: [28.0, 84, 140, 206, 252, 296][i], facing: i < 2 ? 1 : -1, role: i == 1 ? ra : i == 2 ? rb : role, ai: ai)
        a.lift = 8
        a.alpha = clamp((local - 0.15 - Double(i) * 0.05) / 0.2)
        draw(a, ctx, t: t)
        placed.append(a)
    }
    if local > 0.5 { drawFX([(placed[1], placed[2])], ctx, t: t) }
    if local > 0.3 {
        slayerTitle(ctx, center: CGPoint(x: Double(W) / 2, y: 770), px: 5, write: clamp((local - 0.3) / 0.6), stake: clamp((local - 0.9) / 0.15))
    }
    if since > 0 && since < 0.1 { ctx.setFillColor(CGColor(red: 1, green: 0.95, blue: 0.86, alpha: 0.45 * (1 - since / 0.1))); ctx.fill(fullRect) }
    caption("Have fun. Keep track.", ctx, local: local, start: 1.2, y: 470, size: 56)
    caption(slayerTagline, ctx, local: local, start: 1.4, y: 412, size: 34, color: NSColor(white: 0.85, alpha: 1), weight: .bold)
    let ff = easeOut((local - 1.5) / 0.3)
    if ff > 0, let icon = appIcon {
        ctx.setFillColor(CGColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 0.8 * ff)); ctx.fill(CGRect(x: -40, y: -40, width: W + 80, height: 210))
        ctx.saveGState(); ctx.setAlpha(CGFloat(ff)); ctx.interpolationQuality = .high
        ctx.draw(icon, in: CGRect(x: 580, y: 20, width: 130, height: 130))
        ctx.restoreGState()
        text("github.com/rodclemen/clawd-clash", ctx, x: 740, y: 60, size: 44, weight: .bold, alpha: ff)
    }
}

let slayerShots: [Shot] = [
    // The opening titles: the organ, the moon, the fast cuts, the leads, the title, onto the town sign.
    Shot(name: "intro", start: 0, end: 9.0, into: .cut) { ctx, local, t in slayerIntro(ctx, local: local, t: t) },
    // "Home sweet home": the DeSoto through the sign, the fledglings rising, the bus, the gang, dust at dawn.
    Shot(name: "homecoming", start: 9.0, end: 18.5, into: .cut) { ctx, local, t in slayerHomecoming(ctx, local: local, t: t) },
    Shot(name: "hook", start: 18.5, end: 22.5, into: .trip(ComicTransition(SlayerTrip(kind: .dusting, from: .slayerCemetery, to: .slayerLibrary)))) { ctx, local, t in
        let zoom = 1 + 0.03 * local
        ctx.saveGState()
        ctx.translateBy(x: Double(W) / 2, y: Double(H) / 2); ctx.scaleBy(x: zoom, y: zoom); ctx.translateBy(x: -Double(W) / 2, y: -Double(H) / 2)
        desktop(ctx, dim: 0)
        ctx.restoreGState()
        caption("Three AIs. Nine agents. One very confused Watcher.", ctx, local: local, start: 0.05, y: 860, size: 60)
        caption("Sound familiar?", ctx, local: local, start: 0.7, y: 120, size: 76, color: yellow)
    },
    Shot(name: "desktop", start: 22.5, end: 27.1) { ctx, local, t in
        brawl(ctx, .slayer, local: local, t: t, drop: true, chrome: false)
        badge("DESKTOP MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Patrolling your desktop.", ctx, local: local, start: 0.35, y: 900)
        caption("A pixel-art \(Universe.slayer.title) brawl along the bottom of your screen. They fight while they work.", ctx, local: local,
                start: 0.6, y: 830, size: 40, color: yellow, weight: .bold)
    },
    Shot(name: "status", start: 27.1, end: 31.3) { ctx, local, t in
        let cast: [Cast] = [.hero(SlayerHero.buffyClawmers), .hero(SlayerHero.willowRosenclaw), .hero(SlayerHero.spyke), .hero(SlayerHero.rupertGyles)]
        statusOf(ctx, local: local, t: t, cast: cast, badgeText: Universe.slayer.title.uppercased(),
                 aside: "(\(cast[2].name) needs you: “Bloody hell!” \(cast[3].name) has gone for a lie-down.)")
    },
    Shot(name: "agents", start: 31.3, end: 35.3) { ctx, local, t in
        agentsOf(ctx, local: local, t: t, guardCast: .hero(SlayerHero.rupertGyles),
                 crew: [.hero(SlayerHero.xanderHarrows), .hero(SlayerHero.cordeliaChaise), .hero(SlayerHero.ozz), .hero(SlayerHero.anyaJinkins)],
                 line: "Every subagent gets to be part of the Scoobies.", badgeText: Universe.slayer.title.uppercased())
    },
    Shot(name: "window", start: 35.3, end: 40.1, into: .trip(ComicTransition(SlayerTrip(kind: .hellmouth, from: .slayerLibrary, to: .slayerLibrary)))) { ctx, local, t in
        windowShot(ctx, .slayer, local: local, t: t, rise: true, needsAt: 2.5, at: .slayerLibrary)
        badge("WINDOW MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Prefer a window? Welcome to the Hellmouth.", ctx, local: local, start: 0.1, y: 955, size: 56)
        caption("A live card per session: what it's doing, your last prompt, every agent.", ctx, local: local, start: 0.4, y: 890, size: 32, color: yellow, weight: .bold)
    },
    Shot(name: "ais", start: 40.1, end: 44.5) { ctx, local, t in
        everyAI(ctx, local: local, t: t, cast: [.hero(SlayerHero.buffyClawmers), .hero(SlayerHero.faithLehayne), .villain(SlayerVillain.oldMaster),
                                                .villain(SlayerVillain.drusillah), .villain(SlayerVillain.glorificlaws), .villain(SlayerVillain.mayorWilclaws),
                                                .villain(SlayerVillain.fledgling)])
    },
    // The end card: the library, the crew lines up, the title is brushed on.
    Shot(name: "endcard", start: 44.5, end: 48.7) { ctx, local, t in slayerEndcard(ctx, local: local, t: t) },
]

let slayerBeats: [(key: Double, beat: Beat)] = [
    (1.6, ("THE OPENING TITLES", "Out of the black, a night sky in navy bands, stars and a full moon swelling over the graveyard's black skyline; clouds and a bat cross its face.",
           "no text", "one long, low church-organ chord, the wind")),
    (3.2, ("THE CUTS", "Then hard cuts, punk-fast, each on a flash: a vampire in game face lunging at us, a gravestone in the fog, an old book slamming open in a flare of gold light.",
           "no text", "the band crashes in: fast, crunchy punk power chords and pounding drums, our own notes; a cymbal crash on every cut")),
    (5.5, ("THE LEADS", "\(slayerName(SlayerHero.buffyClawmers)) with her stake, \(slayerName(SlayerHero.rupertGyles)) with his crossbow, \(slayerName(SlayerHero.willowRosenclaw)) with a spell glowing green, \(slayerName(SlayerHero.xanderHarrows)) with a rocket launcher: four black silhouettes slamming in against the moon, one after another.",
           "no text", "a hit on each slam")),
    (7.5, ("THE TITLE", "CLAWD SLAYER brushed on in jagged bone-white strokes over red, a whittled stake slamming down as SLAYER's L; then the black is torn away in ragged strokes onto the Welcome to Sunnydale sign.",
           "CLAWD SLAYER", "the big hit as the stake lands, a ringing chord, a sweep")),
    (10.0, ("HOME SWEET HOME", "Night at the \(Location.slayerTownSign.name) sign. Spyke's black DeSoto, its windows painted over, tears in with its headlights on and smashes straight through the sign: the board flies off in three pieces, splinters and dust everywhere.",
            "no text", "an engine roaring in, the crash, wood splintering")),
    (12.2, ("SPYKE", "The car skids to a stop, its back door swings open and \(slayerName(SlayerHero.spyke)) steps out to look the town over.",
            "“Home sweet home.”", "a skid, the door, boots on the road")),
    (15.0, ("RESTFIELD", "\(Location.slayerCemetery.name): three fledglings claw up out of their graves. The yellow school bus pulls up and folds its door open; \(slayerName(SlayerHero.buffyClawmers)), \(slayerName(SlayerHero.willowRosenclaw)) and \(slayerName(SlayerHero.rupertGyles)) get off. \(slayerName(SlayerHero.buffyClawmers)) flips her stake.",
            "no text", "earth crumbling, the bus's engine and brakes, the door")),
    (17.0, ("DUST AT DAWN", "The fight: the stake, Willow's spell lighting the graves green, Giles's crossbow. The sky blushes, dawn breaks behind the hills and the fledglings go up in dust, one, two, three.",
            "“In every terminal, a Clawd is chosen.”", "stake thuds, a spell, a crossbow bolt; a rising dawn chord, three puffs of dust")),
    (18.3, ("DUSTING", "The app's Dusting trip: a stake strikes and the cemetery bursts into dust that blows away onto the desktop.", "(none)", "a thud, a rush of dust")),
    (20.0, ("THE HOOK", "Three busy terminals, slow push-in.", "“Three AIs. Nine agents. One very confused Watcher.”  →  “Sound familiar?”", "keyboard clicks")),
    (24.8, ("DESKTOP MODE", "\(slayerName(SlayerHero.buffyClawmers)) against \(slayerName(SlayerVillain.oldMaster)); \(slayerName(SlayerHero.willowRosenclaw)) against \(slayerName(SlayerVillain.lukewarm)).",
            "DESKTOP MODE  ·  “Patrolling your desktop.”  ·  “A pixel-art \(Universe.slayer.title) brawl along the bottom of your screen. They fight while they work.”", "stake thuds, spells")),
    (29.4, ("AT A GLANCE", "\(slayerName(SlayerHero.buffyClawmers)) working, \(slayerName(SlayerHero.willowRosenclaw)) thinking, \(slayerName(SlayerHero.spyke))'s jumping NEEDS YOU, \(slayerName(SlayerHero.rupertGyles)) sat down napping.",
            "“All fun and games, and you still see everything.”  ·  “(\(slayerName(SlayerHero.spyke)) needs you: “Bloody hell!” \(slayerName(SlayerHero.rupertGyles)) has gone for a lie-down.)”", "blips, alert beeps")),
    (33.5, ("SUBAGENTS", "\(slayerName(SlayerHero.rupertGyles)) stands guard; \(slayerName(SlayerHero.xanderHarrows)), \(slayerName(SlayerHero.cordeliaChaise)), \(slayerName(SlayerHero.ozz)) and \(slayerName(SlayerHero.anyaJinkins)) arrive with their jobs on their labels.",
            "“Every subagent gets to be part of the Scoobies.”", "footsteps")),
    (38.1, ("WINDOW MODE", "In through the app's Hellmouth trip: the window in the \(Location.slayerLibrary.name), \(slayerName(SlayerHero.buffyClawmers)) against \(slayerName(SlayerVillain.oldMaster)), live cards tick, then the Codex card flips to NEEDS YOU.",
            "WINDOW MODE  ·  “Prefer a window? Welcome to the Hellmouth.”", "a rumble, a ping")),
    (42.5, ("EVERY AI", "Seven sessions, one per AI outline: \(slayerName(SlayerHero.buffyClawmers)) (Claude Code, a head taller) and \(slayerName(SlayerHero.faithLehayne)) against \(slayerName(SlayerVillain.oldMaster)), \(slayerName(SlayerVillain.drusillah)), \(slayerName(SlayerVillain.glorificlaws)) and \(slayerName(SlayerVillain.mayorWilclaws)); a fledgling in pi's pink.",
            "BRING YOUR OWN AI*  ·  “One AI plays everyone. Run two and they pick sides.”  ·  *README for the full list", "stake thuds")),
    (47.5, ("END CARD", "The \(Location.slayerLibrary.name): the crew lines up, CLAWD SLAYER is brushed on and its stake slams down, then the icon and the URL.",
            "CLAWD SLAYER  ·  “Have fun. Keep track.”  ·  “\(slayerTagline)”  ·  github.com/rodclemen/clawd-clash", "the organ chord, a last punk stab and crash")),
]

// Clawd Slayer sound effects
extension Mix {
    /// A church organ chord: each note on a few drawbars (sines an octave and a twelfth apart), a slow swell and a
    /// little tremolo.
    func organ(_ t: Double, _ dur: Double, _ notes: [Int], vol: Double = 0.05) {
        for n in notes {
            for (mul, v) in [(0.5, 0.6), (1.0, 1.0), (1.5, 0.35), (2.0, 0.45), (4.0, 0.12)] {
                tone(t, dur, midi(n) * mul, wave: .sine, vol: vol * v, attack: 0.25, release: 0.6, vibrato: 0.002)
            }
            tone(t, dur, midi(n), wave: .square(0.5), vol: vol * 0.08, attack: 0.3, release: 0.6)
        }
    }
    /// One crunchy power-chord chug on `root` (root, fifth, octave on detuned saws and a square), `len` long; `mute`
    /// palm-mutes it to a short thud.
    func chug(_ t: Double, root: Int, len: Double, mute: Bool, vol: Double = 0.05) {
        let d: Double = mute ? 0.05 : 0
        for (n, v) in [(root, 1.0), (root + 7, 0.8), (root + 12, 0.55)] {
            tone(t, len, midi(n) * 0.997, wave: .saw, vol: vol * v, attack: 0.002, release: 0.02, decay: d)
            tone(t, len, midi(n) * 1.004, wave: .saw, vol: vol * v, attack: 0.002, release: 0.02, decay: d)
            tone(t, len, midi(n), wave: .square(0.3), vol: vol * v * 0.5, attack: 0.002, release: 0.02, decay: d)
        }
        noise(t, min(len, 0.05), vol: vol * 0.5, cutoff: 0.6, decay: 0.015, seed: Int(t * 389))      // the pick
    }
    /// A crash cymbal.
    func crash(_ t: Double, vol: Double = 0.1) { noise(t, 1.4, vol: vol, cutoff: 0.95, decay: 0.45, highpass: true, seed: Int(t * 211)) }
    /// A car engine revving past: a low growl that climbs.
    func engine(_ t: Double, _ dur: Double, from: Double, to: Double, vol: Double = 0.06) {
        tone(t, dur, from, to: to, wave: .saw, vol: vol, attack: 0.2, release: 0.15)
        tone(t, dur, from * 0.5, to: to * 0.5, wave: .square(0.3), vol: vol * 0.7, attack: 0.2, release: 0.15)
        noise(t, dur, vol: vol * 0.6, cutoff: 0.05, cutoffTo: 0.12, attack: 0.2, release: 0.15, seed: Int(t * 97))
    }
    /// A puff of dust: a soft hiss blowing away.
    func dust(_ t: Double, vol: Double = 0.08) {
        noise(t, 0.6, vol: vol, cutoff: 0.5, cutoffTo: 0.08, attack: 0.01, release: 0.4, seed: Int(t * 131))
        tone(t, 0.25, 220, to: 90, wave: .sine, vol: vol * 0.6, release: 0.1)
    }
}

/// The opening titles' band, in the sound of the show's theme (an organ chord, then fast, crunchy punk guitar and
/// drums) but our own notes: no melody, just a driving riff of power chords, eight chugs a bar at a punk tempo, with
/// kick and snare pounding under it. `bars` of it from `t0`.
func slayerBand(_ m: Mix, from t0: Double, bars: Int, beat: Double = 0.3) {
    let roots = [38, 38, 41, 36, 43, 41, 38, 45]                        // D D F C G F D A, low; our own run
    for b in 0..<bars {
        let s = t0 + Double(b) * 4 * beat, r = roots[b % roots.count]
        for e in 0..<8 {
            let at = s + Double(e) * beat / 2, open = e == 0 || e == 3 || e == 6
            m.chug(at, root: r + (e == 7 ? 2 : 0), len: beat / 2 * (open ? 0.95 : 0.7), mute: !open, vol: open ? 0.055 : 0.04)
            m.hat(at, vol: e % 2 == 0 ? 0.05 : 0.03)
        }
        for k in [0.0, 1.5, 2.0] { m.kick(s + k * beat, vol: 0.32) }
        for k in [1.0, 3.0] { m.snare(s + k * beat, vol: 0.14) }
        m.tone(s, 4 * beat * 0.98, midi(r - 12), wave: .triangle, vol: 0.09, release: 0.05)  // the bass, under it
    }
}

/// The Clawd Slayer trailer's score and effects.
func slayerSound(_ m: Mix) {
    let i0 = start("intro"), at = { (k: Double) -> Double in i0 + slayerIntroAt(k) }
    // the night: wind, then the organ chord as the moon swells
    m.noise(i0 + 0.1, at(0.26) - i0, vol: 0.04, cutoff: 0.01, cutoffTo: 0.04, attack: 0.8, release: 0.3, seed: 5)
    m.organ(at(0.06), at(0.26) - at(0.06) + 0.3, [38, 50, 53, 57, 62], vol: 0.045)
    // the band crashes in on the first cut and drives through to the title
    let band0 = at(0.26), beat = 0.3
    let bars = Int(((at(0.88) - band0) / (4 * beat)).rounded(.down))
    slayerBand(m, from: band0, bars: bars, beat: beat)
    for k in [0.26, 0.33, 0.39] { m.crash(at(k), vol: 0.12); m.boom(at(k), vol: 0.3) }
    for k in [0.47, 0.508, 0.546, 0.584] { m.boom(at(k), vol: 0.35); m.snare(at(k), vol: 0.12) }
    let stake = at(0.712)
    m.boom(stake, vol: 0.6); m.crash(stake, vol: 0.16)
    m.chug(stake, root: 38, len: 1.2, mute: false, vol: 0.07)
    let fill = band0 + Double(bars) * 4 * beat
    for k in 0..<8 { m.snare(fill + Double(k) * beat / 4, vol: 0.07 + Double(k) * 0.012) }
    m.whoosh(at(0.93), 1.0, vol: 0.14)
    m.chug(at(0.88), root: 38, len: 1.6, mute: false, vol: 0.06); m.crash(at(0.88), vol: 0.12)
    // the sign: the DeSoto roaring in, the crash, the skid, the door, the boots
    let hc = start("homecoming")
    m.engine(hc + homeCarIn - 0.4, homeCrash - homeCarIn + 0.4, from: 70, to: 140, vol: 0.07)
    m.engine(hc + homeCrash, homeCarStop - homeCrash + 0.2, from: 140, to: 60, vol: 0.05)
    let crash = hc + homeCrash
    m.boom(crash, vol: 0.6); m.crash(crash, vol: 0.18)
    m.noise(crash, 0.5, vol: 0.25, cutoff: 0.7, decay: 0.12, seed: 77)
    for k in 0..<6 { m.noise(crash + 0.05 + Double(k) * 0.07, 0.05, vol: 0.1, cutoff: 0.9, decay: 0.02, highpass: true, seed: 80 + k) }
    m.chug(crash, root: 38, len: 0.9, mute: false, vol: 0.06)
    m.noise(crash + 0.1, homeCarStop - homeCrash, vol: 0.06, cutoff: 0.6, cutoffTo: 0.3, attack: 0.05, release: 0.2, highpass: true, seed: 88)
    m.clunk(hc + homeDoor, vol: 0.1)
    for k in 0..<4 { m.step(hc + homeSpyke + Double(k) * 0.16, vol: 0.08) }
    // Restfield: a low drone, earth crumbling, the bus's engine and brakes, the door, the fight, the dawn, the dust
    let rf = hc + homeCut
    m.tone(rf, 6.0, midi(26), wave: .saw, vol: 0.035, attack: 0.5, release: 1.0)
    m.tone(rf, 6.0, midi(33), wave: .saw, vol: 0.02, attack: 0.5, release: 1.0)
    for k in 0..<Int(4.2 / beat) where k % 2 == 0 { m.kick(rf + Double(k) * beat, vol: 0.18) }
    for (i, r) in homeRise.enumerated() { m.noise(rf + r, homeRiseLength, vol: 0.07, cutoff: 0.08, decay: 0.4, seed: 120 + i) }
    m.engine(rf + homeBusIn - 0.2, homeBusStop - homeBusIn + 0.2, from: 90, to: 55, vol: 0.06)
    m.noise(rf + homeBusStop - 0.1, 0.5, vol: 0.08, cutoff: 0.9, attack: 0.02, release: 0.3, highpass: true, seed: 131)   // the brakes' hiss
    m.clunk(rf + homeBusDoor, vol: 0.08)
    for i in homeOff.indices { for k in 0..<3 { m.step(rf + homeOff[i] + Double(k) * 0.15, vol: 0.06) } }
    m.whoosh(rf + homeFlip + 0.3, 0.4, vol: 0.08)
    m.ding(rf + homeFight - 0.05, vol: 0.05)
    slayerBand(m, from: rf + homeFight, bars: 1, beat: beat)
    m.shimmer(rf + homeFight - 0.2, homeDust[1] - homeFight + 0.4, vol: 0.03)
    for k in 0..<3 { m.thwip(rf + homeFight + 0.2 + Double(k) * 0.35, vol: 0.06); m.snare(rf + homeFight + 0.1 + Double(k) * 0.3, vol: 0.06) }
    m.organ(rf + homeDawn, 2.0, [50, 57, 62, 66], vol: 0.03)
    for d in homeDust { m.dust(rf + d, vol: 0.1) }
    // the app shots: the shared groove, and each shot's effects
    groove(m, from: start("hook"), to: start("endcard"), fadeIn: 1.2)
    let hook = start("hook")
    m.dust(hook - 0.6, vol: 0.12); m.boom(hook - 0.75, vol: 0.2)
    for i in 0..<26 { m.click(hook + 0.2 + Double(i) * 0.13 + noise(i) * 0.06) }
    let desk = start("desktop"), deskEnd = end("desktop") + 1.3
    for (i, d) in [0.0, 0.12, 0.24, 0.32].enumerated() { m.step(desk + d + 0.3, vol: 0.1 + Double(i % 2) * 0.03) }
    for t in clashTimes(desk + 0.45, deskEnd) { m.clang(t, vol: 0.07) }
    m.crackle(desk + 0.5, deskEnd - desk - 0.5, vol: 0.02)
    let st = start("status")
    for i in 0..<4 { m.pop(st + 0.1 + Double(i) * 0.22, step: i) }
    for k in 0..<5 { m.tone(st + 1.2 + Double(k) * 0.62, 0.08, 1568, wave: .square(0.5), vol: 0.035, release: 0.03) }
    let ag = start("agents")
    for k in 0..<14 { m.step(ag + Double(k) * 0.125, vol: 0.06) }
    let wi = start("window")
    m.tone(wi - 1.0, 1.4, 60, to: 40, wave: .saw, vol: 0.06, attack: 0.2, release: 0.4); m.boom(wi - 0.3, vol: 0.2)   // the Hellmouth
    for t in clashTimes(wi, wi + 2.5) { m.clang(t, vol: 0.05) }
    for k in [0.9, 1.8] { m.click(wi + k, vol: 0.06) }
    m.ping(wi + 2.5)
    let ais = start("ais")
    for i in 0..<6 { m.pop(ais + 0.15 + Double(i) * 0.1, step: i % 4) }
    for t in clashTimes(ais + 0.4, end("ais") + 1.0) { m.clang(t, vol: 0.04) }
    for s in shots { transitionSound(m, s) }
    // the end card: the organ chord, the band's last bar, then the stake slamming down on a big ringing chord
    let ec = start("endcard")
    m.organ(ec, 1.2, [38, 50, 53, 57], vol: 0.035)
    for k in 0..<4 { m.chug(ec + 0.45 + Double(k) * beat / 2, root: 41 - (k / 2) * 3, len: beat / 2 * 0.7, mute: true); m.kick(ec + 0.45 + Double(k) * beat / 2, vol: 0.2) }
    let slam = ec + 1.05
    m.boom(slam, vol: 0.6); m.crash(slam, vol: 0.18)
    m.chug(slam, root: 38, len: 2.6, mute: false, vol: 0.07)
    m.organ(slam, 2.8, [50, 57, 62, 65], vol: 0.03)
    m.boom(slam + 1.2, vol: 0.25)
}

// MARK: Which video

/// promo, bloopers, full (the promo, then the bloopers, as one), royale, or a universe's own trailer by its REEL name.
let reel = ProcessInfo.processInfo.environment["REEL"] ?? "promo"
/// The universes' own trailers: those in their folders, and those still here until they move.
let universeReels: [PromoReel] = registeredReels + [DetectiveReel(), DoctorReel(), FilesReel(), ClawdbergReel(), RingsReel(), SlayerReel()]
/// The universe's trailer REEL names, if it's one of theirs.
let universeReel = universeReels.first { $0.name == reel }
let promoLength = promoShots.last!.end
if let r = universeReel {
    softWipe = r.softWipe; poster = r.poster; geminiTask = r.geminiTask
} else if reel == "bloopers" {
    poster = ("clapper", 2.0)
} else if reel == "royale" {
    poster = ("collide", 2.2)
}
shots = universeReel?.shots ?? {
    switch reel {
    case "bloopers": return blooperShots
    case "full": return promoShots + blooperShots.map { $0.shifted(promoLength) }
    case "royale": return royaleShots
    default: return promoShots
    }
}()
overlays = reel == "promo" || reel == "full" ? promoOverlays : reel == "royale" ? royaleOverlays : []

// MARK: Storyboard beats

var legendNames: String { listed(Universe.offered.map { Theme.of($0).legend.name }) }

var promoBeats: [(key: Double, beat: Beat)] { [
    (2.4, ("COLD OPEN", "Black screen. A yellow comic caption types itself out.", "“MEANWHILE, IN A TERMINAL NEAR YOU...”", "typewriter keys, a bell")),
    (5.6, ("DOWN THE VORTEX", "Lightning, then down Doctor Clawd's time vortex. The police box and every universe's legend tumble out two at a time, from opposite sides, on their own curves and spins: \(legendNames).", "no text", "thunder, the title-sequence tune, whooshes")),
    (11.0, ("CLAWD CLASH", "CLAWD CLASH flies up out of the eye of the vortex, faster and faster, and lands with a bang in the middle of the screen: a flash, the frame shakes.", "CLAWD CLASH", "a rising sweep, the big hit and the fanfare")),
    (14.5, ("THE HOOK", "Three busy terminals (Claude, Codex, Gemini), slow push-in.", "“Three AIs. Nine agents. One very confused human.”  →  “Sound familiar?”", "keyboard clicks")),
    (18.2, ("CHOOSE YOUR UNIVERSE", "Two heroes from every universe run along the bottom of the desktop, and CHOOSE YOUR UNIVERSE pops up over them.", "CHOOSE YOUR UNIVERSE", "running feet, a hit")),
    (16.5 + pageArrive(0) + 0.5, ("READING THE PAGE", "A comic page slams down over them, its panels split by slanted gutters that never line up. The camera swoops into the first panel and reads them one by one, straightening each up as it fills the screen with that universe's big moment.", "the universe's name on each panel  ·  \(Universe.offered.map { setPiece($0).word }.joined(separator: "  "))", "a whoosh and a hit per panel, a taste of each set piece")),
    (16.5 + (pageTurns.first ?? pageArrive(3)) + pageTurn * 0.3, ("PANEL BY PANEL", "On through the page in reading order, each with its sound word popping as the camera arrives. Back on the whole page, it curls over like a comic book's onto the next: \(listed(comicPages.map { listed($0.map(\.u.title)) }.map { "(\($0))" })).", "the panel's name and sound word", "each universe's own sound")),
    (16.5 + pageBack + 1.0, ("PICK YOURS", "The camera pulls back to the whole page, every universe's moment still playing in its panel.", "“ONE APP. \(universeCount()) UNIVERSES. PICK YOURS.”", "a ping")),
    (afterChoose + 2.5, ("AT A GLANCE (THE CLAWD FILES)", "A case file opens on the status line-up: \(Cast.hero(FilesHero.foxClawder).name) working, a Grey thinking, the Flukeman's jumping NEEDS YOU, \(Cast.hero(FilesHero.skinnard).name) sat down napping.", "“All fun and games, and you still see everything.”", "blips, alert beeps")),
    (afterChoose + 7.0, ("SUBAGENTS (STEVIE CLAWDBERG)", "The treasure map routes us in: \(Cast.hero(ClawdbergHero.mikeyWaltz).name) stands guard, the Goonies walk in with their jobs on their labels.", "“Every subagent gets to be a Goonie.”", "footsteps")),
    (afterChoose + 12.3, ("WINDOW (CLAWD OF THE RINGS)", "The map of Middle-earth walks us to the window in \(Location.prancingPony.name): live cards tick, then a Codex card flips to NEEDS YOU.", "“Prefer a window? Step into \(Location.prancingPony.name).”", "a ping")),
    (afterChoose + 18.2, ("RANDOM", "The window changes universe on its own, twice, each with that universe's transition, inside the window only: down the vortex into Doctor Clawd, then a Star Clawds wipe.", "RANDOM · EVERY 5 MIN  ·  “Can't decide? Random switches the whole window to a new universe every few minutes.”", "the transitions' own sounds")),
    (afterChoose + 23.0, ("CLAWD ROYALE", "Halftone blue: every universe's menu bar emblem flies in from round the frame and they slam together, KRA-KOOM!, and CLAWD ROYALE stamps in.", "KRA-KOOM!  ·  CLAWD ROYALE  ·  “UNIVERSES COLLIDE.”", "whooshes, the big hit, a fanfare")),
    (afterChoose + 26.4, ("THE CROSSOVER", "A FWIP! web burst into \(Location.cantina.name): \(Cast.hero(FilesHero.foxClawder).name) against a Dalick, Batclawd duelling Darth Vapor, \(Cast.hero(RingsHero.gandalf).name) holding off Thanoz' gauntlet; Spider-Clawd swings over everyone as E.Clawd's bike flies the other way.", "CLAWD ROYALE  ·  “Nobody asked who'd win. We're answering anyway.”  ·  “Settings → Universe → Clawd Royale. A new place every ten minutes.”", "sabers, blasters, web thwips, a whoosh")),
    (afterChoose + 31.5, ("END CARD", "The icon lands over its dimmed panels, and every universe's emblem pops in under it.", "“Have fun. Keep track.”  ·  “Pick a universe, or let them collide · free for macOS · github.com/rodclemen/clawd-clash”", "a heroic cadence")),
] }


let blooperBeats: [(key: Double, beat: Beat)] = [
    (1.8, ("BLOOPERS", "A record scratch; a clapperboard slams down over red halftone: BLOOPERS, take 1, and snaps.", "BLOOPERS", "record scratch, slate clack, a goofier tune starts")),
    (6.9, ("TAKE 7", "The TARDIS wheezes into the Mos Easy Cantina and Doctor Ten steps out, face to face with Darth Vapor. He ducks back in, the box tries to leave, sputters and stays put; he steps out again, sheepish.", "“Ah. Wrong universe.”  ·  “…Is that a phone box?”  ·  “…Handbrake.”", "the wheeze, a sputter and a clunk, then CUT!")),
    (14.8, ("TAKE 12", "Batclawd lights the Night Beacon over the Doom Moon. Two Stormtroupers open fire on it and miss every shot.", "“You know it's a light, right?”", "blasters, all missing")),
    (20.6, ("TAKE 15", "The Jester Card transition spins in and flips: Thanoz is on the back, on Titan. The Jester peeks into the shot with a ?.", "no text", "the card flip, a slide whistle")),
    (25.6, ("TAKE 21", "Yodle calmly floats Thorr's hammer up off the floor. Thorr stares.", "“…”  ·  “Worthy, hmm. Heavy, it is not.”", "a shimmer, then CUT!")),
    (30.4, ("TAKE 22", "The Millennial Falcon jumps to hyperspace in a blink; Superb-Man is left behind in the star streaks.", "“Hey! Wait up!”", "the jump, a whoosh")),
    (34.6, ("THAT'S A WRAP", "Everyone crammed into one frame at Clawdvengers Tower, Doctor Ten, Rose Tiler and a Dalick among them. Spider-Clawd swings across upside down as Superb-Man flies the other way; Deadpond, Star-Laird and Harold the Duck moonwalk. Then the whole cast waves.", "“Separate universes, they said. Totally under control.”  ·  “CUT! THAT'S A WRAP!”", "web thwips, a whoosh, a final sting and applause")),
]

// MARK: Soundtrack

/// The promo's score and effects, `o` seconds in.
func promoSound(_ m: Mix) {
    // cold open: a key for every letter, a bell, a low drone
    let mw = start("meanwhile")
    for i in 0..<35 { m.type(mw + 0.3 + Double(i) / 35 * 1.6 + noise(i) * 0.02, vol: 0.18 + noise(i + 50) * 0.08) }
    m.ding(mw + 2.0)
    m.tone(mw + 0.2, 2.8, midi(33), wave: .sine, vol: 0.05, attack: 1.0, release: 0.8)

    // the vortex: lightning, the title-sequence tune, everyone whooshing past, then CLAWD CLASH hits with an original fanfare
    let w = start("worlds"), hit = w + introSlam
    m.noise(w + 0.1, 0.25, vol: 0.22, cutoff: 0.9, decay: 0.06, highpass: true, seed: 10); m.boom(w + 0.15, vol: 0.3)
    m.noise(w, hit - w, vol: 0.05, cutoff: 0.01, cutoffTo: 0.05, attack: 0.5, release: 0.2, seed: 3)
    doctorTune(m, from: hit - 8.0, bars: 5)
    for i in introTumblers.indices { let (s0, fly) = introTiming(i); m.whoosh(w + s0 + fly * 0.85, 0.9, vol: 0.11) }
    m.tone(hit - 1.1, 1.1, 200, to: 2400, wave: .saw, vol: 0.05, attack: 0.5, release: 0.05)
    m.boom(hit, vol: 0.6); m.noise(hit, 1.8, vol: 0.13, cutoff: 0.9, decay: 0.55, highpass: true, seed: 3)
    for n in [48, 55, 60, 64, 67] { m.tone(hit, 1.4, midi(n), wave: .saw, vol: 0.05, release: 0.6, decay: 0.8) }
    for (s, d, n) in [(0.3, 0.25, 67), (0.6, 0.25, 72), (0.9, 0.6, 76), (1.6, 0.25, 74), (1.9, 0.25, 72), (2.2, 1.2, 79)] as [(Double, Double, Int)] {
        m.tone(hit + s, d, midi(n + 12), wave: .square(0.5), vol: 0.07, release: 0.08, vibrato: 0.006)
        m.tone(hit + s, d, midi(n), wave: .saw, vol: 0.045, release: 0.08)
    }

    // the groove, from the hook to the end card
    groove(m, from: start("hook"), to: start("endcard"), fadeIn: 1.2)
    let hook = start("hook")
    for i in 0..<26 { m.click(hook + 0.2 + Double(i) * 0.13 + noise(i) * 0.06) }

    // choose your universe: running feet, the page slamming down, and for every panel a whoosh as the camera moves, a hit
    // as it lands and a taste of its big moment, then a ping for the line
    let chs = start("choose")
    for k in 0..<26 { m.step(chs + 0.2 + Double(k) * 0.08, vol: 0.05 + noise(k) * 0.03) }
    m.boom(chs + 0.2, vol: 0.18); m.snare(chs + 0.2, vol: 0.1)
    m.whoosh(chs + pageDrop + 0.1, 0.4, vol: 0.14); m.boom(chs + pageDrop + 0.35, vol: 0.3); m.snare(chs + pageDrop + 0.35, vol: 0.12)
    for (i, p) in comicPages.flatMap({ $0 }).enumerated() {
        let at = chs + pageArrive(i)
        m.whoosh(at - pageMove / 2, pageMove + 0.1, vol: 0.12); m.boom(at, vol: 0.18); m.pop(at + 0.05, step: i % 4)
        switch p.u {
        case .starWars: for k in 0..<5 { m.turbolaser(at + 0.1 + Double(k) * 0.18, pitch: k % 2 == 0 ? 1 : 0.8, vol: 0.05) }
        case .marvel: m.roar(at + 0.1, 1.0, vol: 0.16)
        case .dc: m.boom(at + 0.2, vol: 0.2); m.roar(at + 0.4, 0.8, vol: 0.14)
        case .doctor: m.wheeze(at, cycles: 2, vol: 0.08)
        case .clawdFiles: m.tone(at, 1.0, 220, to: 330, wave: .sine, vol: 0.05, attack: 0.3, release: 0.3)
        case .clawdberg: m.tone(at, 0.4, 300, to: 1800, wave: .saw, vol: 0.04, release: 0.05); m.boom(at + 0.45, vol: 0.2)
        case .middleEarth: for k in 0..<4 { m.kick(at + Double(k) * 0.24, vol: 0.25) }
        case .slayer: m.chug(at, root: 38, len: 0.5, mute: false); m.crash(at, vol: 0.08)
        default: break   // no sound of its own
        }
    }
    for at in pageTurns { m.flip(chs + at + 0.1, vol: 0.14); m.whoosh(chs + at + pageTurn / 2, pageTurn, vol: 0.1) }
    m.ping(chs + pageBack + 0.3)

    // the features
    let st = start("status")
    for i in 0..<4 { m.pop(st + 0.1 + Double(i) * 0.22, step: i) }
    for k in 0..<5 { m.tone(st + 1.2 + Double(k) * 0.62, 0.08, 1568, wave: .square(0.5), vol: 0.035, release: 0.03) }
    let ag = start("agents")
    for k in 0..<14 { m.step(ag + Double(k) * 0.125, vol: 0.06) }
    m.bark(ag + 1.4)
    let wi = start("window")
    m.hum(wi, 2.5, vol: 0.02)
    for k in [0.9, 1.8] { m.click(wi + k, vol: 0.06) }
    m.ping(wi + 2.5)

    // Clawd Royale: the emblems fly in and slam, the title stamps down to a fanfare, then everyone at once
    let ro = start("royale"), slam = ro + royaleSlam
    var r = ro
    while r < slam - 0.03 { m.snare(r, vol: 0.03 + 0.1 * (r - ro) / royaleSlam); r += 1.0 / 20 }
    for k in Universe.offered.indices { m.whoosh(ro + 0.3 + Double(k) * 0.03, 0.6, vol: 0.09) }
    m.boom(slam, vol: 0.65); m.noise(slam, 1.8, vol: 0.14, cutoff: 0.9, decay: 0.55, highpass: true, seed: 3)
    m.snare(slam, vol: 0.2); m.kick(slam, vol: 0.4)
    for n in [48, 55, 60, 64, 67] { m.tone(slam, 1.4, midi(n), wave: .saw, vol: 0.05, release: 0.6, decay: 0.8) }
    let stamp = ro + royaleStamp
    m.clunk(stamp, vol: 0.3); m.boom(stamp, vol: 0.3)
    for (s, d, n) in [(0.0, 0.22, 67), (0.25, 0.22, 72), (0.5, 0.5, 76), (1.05, 0.22, 74), (1.3, 0.22, 76), (1.55, 0.9, 79)] as [(Double, Double, Int)] {
        m.tone(stamp + s, d, midi(n + 12), wave: .square(0.5), vol: 0.07, release: 0.08, vibrato: 0.006)
        m.tone(stamp + s, d, midi(n), wave: .saw, vol: 0.045, release: 0.08)
    }
    let cr = start("crossover"), ce = end("crossover")
    m.hum(cr, ce - cr, vol: 0.022)
    for t in clashTimes(cr, ce) { m.clash(t, vol: 0.1) }
    for t in shotTimes(cr, ce, offset: 0) { m.pew(t, vol: 0.07) }
    for t in shotTimes(cr, ce, offset: blasterPeriod / 2) { m.pew(t, vol: 0.05) }
    for k in 0..<3 { m.thwip(cr + 0.7 + Double(k) * swingArc, vol: 0.12) }
    m.crackle(cr + 0.3, ce - cr - 0.3, vol: 0.03)
    m.whoosh(cr + 2.4, 2.0, vol: 0.1)                                             // the bike going over
    for s in shots { transitionSound(m, s) }

    // end card: a heroic cadence and the icon landing
    let ec = start("endcard")
    for (s, d, chord, lead) in [(0.0, 0.7, [53, 57, 60, 65], 81), (0.7, 0.7, [55, 59, 62, 67], 83), (1.4, 3.4, [57, 61, 64, 69], 85)] {
        for n in chord { m.tone(ec + s, d, midi(n), wave: .saw, vol: 0.045, attack: 0.02, release: d > 1 ? 1.8 : 0.1) }
        m.tone(ec + s, d, midi(lead), wave: .square(0.5), vol: 0.06, release: d > 1 ? 1.8 : 0.1, vibrato: 0.006)
        m.tone(ec + s, d, midi(chord[0] - 24), wave: .sine, vol: 0.2, release: d > 1 ? 1.8 : 0.1)
    }
    m.boom(ec + 0.3, vol: 0.45)
    for k in 0..<Universe.offered.count { m.pop(ec + 0.5 + Double(k) * 0.08, step: k % 4) }
}

/// The blooper reel's goofy tune and gags.
func bloopersSound(_ m: Mix) {
    let cl = start("clapper")
    m.scratch(cl + 0.05)
    m.clack(cl + 1.0, vol: 0.4)
    // an oom-pah tune in F, kazoo lead: from the slate to the end, quiet under the takes
    let beat = 60.0 / 140, t0 = cl + 1.1, stopA = -1.0, stopB = -1.0
    let roots = [41, 46, 48, 41], chords = [[65, 69, 72], [65, 70, 74], [64, 67, 72], [65, 69, 72]]
    let tune: [(Int, Double)] = [(72, 1), (74, 0.5), (76, 0.5), (77, 1), (72, 1), (74, 0.5), (72, 0.5), (70, 1), (69, 2),
                                 (69, 1), (70, 0.5), (72, 0.5), (74, 1), (70, 1), (72, 0.5), (70, 0.5), (69, 1), (65, 2)]
    var b = 0
    var bt = t0
    while bt < end("wrap") - 1.2 {
        let c = (b / 4) % 4
        if !(bt > stopA && bt < stopB) {
            m.tone(bt, beat * 0.5, midi(roots[c] - 12 + (b % 2 == 0 ? 0 : 7)), wave: .square(0.5), vol: 0.06, release: 0.03)   // oom
            for n in chords[c] { m.tone(bt + beat * 0.5, beat * 0.35, midi(n - 12), wave: .square(0.125), vol: 0.022, release: 0.02) }   // pah
        }
        b += 1; bt += beat
    }
    var lt = t0, i = 0
    while lt < end("wrap") - 1.4 {
        let (n, d) = tune[i % tune.count]
        if !(lt > stopA && lt < stopB) { m.tone(lt, d * beat * 0.9, midi(n), wave: .saw, vol: 0.035, attack: 0.02, release: 0.05, vibrato: 0.02) }
        lt += d * beat; i += 1
    }
    // every take ends on CUT! and a slate
    for (name, at) in [("take7", 8.2), ("take12", 4.0), ("take15", 3.4), ("take21", 5.4), ("take22", 4.0)] {
        let s = start(name)
        m.tone(s + at, 0.18, 300, to: 220, wave: .square(0.5), vol: 0.08, release: 0.05)   // a honk for the CUT!
        m.clack(s + at + 0.7)
    }
    let t7 = start("take7")
    m.wheeze(t7, cycles: 3, vol: 0.14)
    m.clunk(t7 + 1.9, vol: 0.1); m.clunk(t7 + 5.0, vol: 0.1); m.clunk(t7 + 7.0, vol: 0.1)
    for k in 0..<4 { m.step(t7 + 2.15 + Double(k) * 0.15, vol: 0.08); m.step(t7 + 4.65 + Double(k) * 0.12, vol: 0.08) }
    for n in [43, 46, 50] { m.tone(t7 + 1.3, 0.9, midi(n), wave: .saw, vol: 0.05, release: 0.4) }               // Vapor turns
    m.wheeze(t7 + 5.4, cycles: 2, vol: 0.12)                                                                     // it tries to go…
    m.tone(t7 + 6.6, 0.3, 160, to: 60, wave: .saw, vol: 0.08, release: 0.1); m.clunk(t7 + 6.8, vol: 0.25)       // …and can't
    m.wahWah(t7 + 7.7)
    let t12 = start("take12")
    m.clunk(t12)
    for i in 0..<12 { m.pew(t12 + 0.5 + Double(i) * 0.22, vol: 0.07) }
    let t15 = start("take15")
    m.flip(t15 + 0.5, vol: 0.1); m.slideWhistle(t15 + 1.4, up: false)
    m.shimmer(start("take21") + 0.5, 1.5)
    let t22 = start("take22")
    m.tone(t22 + 0.6, 0.4, 200, to: 2400, wave: .saw, vol: 0.06, release: 0.1); m.boom(t22 + 0.95, vol: 0.3); m.whoosh(t22 + 1.6, 1.2, vol: 0.12)
    let wr = start("wrap")
    for k in 0..<4 { m.thwip(wr + 0.3 + Double(k) * 0.6, vol: 0.1) }
    m.whoosh(wr + 1.7, 1.6, vol: 0.14)
    for n in [53, 57, 60, 65, 69] { m.tone(wr + 5.6, 1.8, midi(n), wave: .saw, vol: 0.045, release: 1.0) }
    m.boom(wr + 5.6, vol: 0.35)
    m.applause(wr + 5.7, 2.6)
}

/// The reel's score and effects.
func score(_ m: Mix) {
    if let r = universeReel { r.sound(m); return }
    switch reel {
    case "royale": royaleSound(m)
    default:
        if reel != "bloopers" { promoSound(m) }
        if reel != "promo" { bloopersSound(m) }
    }
}

// MARK: Main

// The baseline (Tools/Baseline) needs the same pictures every run: the cantina's band is otherwise picked at random.
if ProcessInfo.processInfo.environment["BASELINE"] != nil { starClawdsBandForced = false }
let args = CommandLine.arguments
let cmd = args.count > 1 ? args[1] : "storyboard"
let out = args.count > 2 ? args[2] : "promo"
try? FileManager.default.createDirectory(atPath: out, withIntermediateDirectories: true)
let base = universeReel?.base ?? ["promo": "clawd-clash-promo", "bloopers": "clawd-clash-bloopers", "full": "clawd-clash-full",
                                  "royale": "clawd-royale-promo"][reel] ?? "clawd-clash-promo"

switch cmd {
case "video":
    let tmp = NSTemporaryDirectory()
    writeVideo(to: tmp + "\(base)-silent.mp4")
    writeWAV(soundtrack(score), to: tmp + "\(base).wav")
    mux(video: tmp + "\(base)-silent.mp4", audio: tmp + "\(base).wav", to: "\(out)/\(base).mp4")
case "check":                                                   // render every frame once, saying where it got to
    for f in 0..<Int(duration * fps) {
        let t = Double(f) / fps
        FileHandle.standardError.write("\(t)\n".data(using: .utf8)!)
        autoreleasepool { _ = frame(t) }
    }
    print("all \(Int(duration * fps)) frames render")
case "720p":                                                    // the GitHub-sized copy of a reel already rendered
    let small = universeReel?.small ?? ["promo": "Clawd-Clash", "bloopers": "Bloopers", "full": "Clawd-Clash-Full",
                                        "royale": "Clawd-Royale"][reel] ?? "Clawd-Clash"
    write720p(from: "\(out)/\(base).mp4", to: "\(out)/720p/\(small).mp4")
case "audio":
    writeWAV(soundtrack(score), to: "\(out)/\(base).wav"); print("wrote \(out)/\(base).wav")
case "frame":
    let t = Double(args[3]) ?? 0
    save(frame(t), "\(out)/t\(args[3]).png"); print("wrote \(out)/t\(args[3]).png")
default:
    if let r = universeReel { save(storyboard(r.title, r.beats), "\(out)/\(r.storyboardFile)") }
    else if reel == "bloopers" { save(storyboard("CLAWD CLASH: BLOOPERS", blooperBeats), "\(out)/storyboard-bloopers.png") }
    else if reel == "royale" { save(storyboard("CLAWD ROYALE", royaleBeats), "\(out)/storyboard-clawd-royale.png") }
    else { save(storyboard("CLAWD CLASH", promoBeats), "\(out)/storyboard-promo.png") }
    print("wrote the \(reel) storyboard to \(out)")
}
