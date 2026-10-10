import AppKit
import AVFoundation

// Renders the 13-second promo with the app's own sprite code: a storyboard sheet of key frames,
// or every frame of the video (1920×1080, 30 fps).
//   swiftc -O -swift-version 5 Sources/App/Pixel.swift Sources/App/Characters.swift Sources/App/Leaders.swift \
//          Sources/App/Cast.swift Sources/App/Cantina.swift Sources/App/Locations.swift Sources/Shared/*.swift \
//          Tools/RenderPromo/main.swift -o build/renderpromo
//   build/renderpromo storyboard build/promo        → storyboard.png + one PNG per key frame
//   build/renderpromo frames build/promo/frames     → frame-000.png … frame-389.png
//   build/renderpromo video build/promo             → clawd-wars-promo.mp4 (H.264, silent)

let W = 1920, H = 1080, fps = 30.0, duration = 13.0
let S = 6.0                      // screen pixels per sprite pixel for a session; agents are 2/3 of that
let groundY = 150.0              // fx-row of the floor line (fx canvas is W/S × H/S, y down)

// MARK: Palette

let yellow = NSColor(srgbRed: 1, green: 0.91, blue: 0.12, alpha: 1)
let claudeOrange = CGColor(red: 0.85, green: 0.47, blue: 0.34, alpha: 1)
enum AI: String { case claude, codex, qwen
    var hex: UInt32 { switch self { case .claude: return 0xFFFFFF; case .codex: return 0x6FD3FF; case .qwen: return 0xC08CFF } }
    var ns: NSColor { NSColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
                              blue: CGFloat(hex & 0xFF) / 255, alpha: 1) }
}

// MARK: Easing

func clamp(_ v: Double, _ a: Double = 0, _ b: Double = 1) -> Double { min(max(v, a), b) }
func easeOut(_ v: Double) -> Double { let x = clamp(v); return 1 - pow(1 - x, 3) }
func easeIn(_ v: Double) -> Double { let x = clamp(v); return x * x * x }
func backOut(_ v: Double) -> Double { let x = clamp(v), c = 1.9; return 1 + (c + 1) * pow(x - 1, 3) + c * pow(x - 1, 2) }
func lerp(_ a: Double, _ b: Double, _ f: Double) -> Double { a + (b - a) * f }

// MARK: Actors

struct Actor {
    var cast: Cast
    var x: Double                         // body centre, fx units
    var facing: Double = 1                // +1 right, -1 left
    var session = true                    // sessions are drawn large, agents at 2/3
    var mode: VaderMode = .working
    var role: FightRole = .none
    var walking = false
    var urgent = false
    var bubble: BubbleKind? = nil
    var label: String? = nil
    var ai: AI = .claude
    var lift = 0.0                        // fx units off the floor (jumps, drop-ins)
    var alpha = 1.0
    var k: Double { session ? 1 : 2.0 / 3 }
    var top: Double { groundY - 44 * k - lift }
    var fighter: Fighter {
        Fighter(weapon: cast.weapon, x: x, k: k, top: top, side: facing, muzzle: cast.muzzle)
    }
}

/// Draws one actor (sprite, speech bubble, label) into a CG context whose units are screen pixels, y up.
func draw(_ a: Actor, _ ctx: CGContext, t: Double) {
    let c = PixelCanvas(Sprite.width, Sprite.height)
    a.cast.draw(c, t: t, mode: a.mode, walking: a.walking, role: a.role, urgent: a.urgent, asSession: a.session)
    if a.facing < 0 { c.flipHorizontally() }
    c.addOutline(C(a.ai.hex, 0.92))
    guard let img = c.makeImage() else { return }
    let px = S * a.k
    let x0 = (a.facing > 0 ? a.x - Sprite.bodyCenterX * a.k : a.x - (Double(Sprite.width) - Sprite.bodyCenterX) * a.k) * S
    let yTop = a.top * S
    ctx.saveGState(); ctx.setAlpha(CGFloat(a.alpha))
    ctx.draw(img, in: CGRect(x: x0, y: Double(H) - yTop - Double(Sprite.height) * px,
                             width: Double(Sprite.width) * px, height: Double(Sprite.height) * px))
    // Speech bubble beside the head, tail pointing back at it.
    if let kind = a.bubble {
        let bc = PixelCanvas(Bubble.width, Bubble.height)
        drawBubble(bc, kind: kind, t: t, urgent: a.urgent, tailRight: a.facing < 0)
        if let bi = bc.makeImage() {
            let headRow = a.top + Double(a.cast.headTop) * a.k
            let bx = a.facing > 0 ? a.x + 7 * a.k : a.x - 7 * a.k - Double(Bubble.width)
            let by = headRow - Double(Bubble.height) + 2
            ctx.draw(bi, in: CGRect(x: bx * S, y: Double(H) - (by + Double(Bubble.height)) * S,
                                    width: Double(Bubble.width) * S, height: Double(Bubble.height) * S))
        }
    }
    if let l = a.label {
        let headRow = a.top + Double(a.cast.headTop) * a.k
        chip(l, ctx, centerX: a.x * S, bottomY: Double(H) - headRow * S + (a.session ? 22 : 16),
             size: a.session ? 30 : 23, agent: !a.session, accent: a.ai)
    }
    ctx.restoreGState()
}

/// The overlay's label: monospaced white text in a dark rounded box (agents: navy box, blue border).
func chip(_ s: String, _ ctx: CGContext, centerX: Double, bottomY: Double, size: CGFloat, agent: Bool, accent: AI = .claude) {
    let font = NSFont.monospacedSystemFont(ofSize: size, weight: agent ? .semibold : .bold)
    let p = NSMutableParagraphStyle(); p.alignment = .center
    let text = NSAttributedString(string: s, attributes: [.font: font, .foregroundColor: NSColor.white, .paragraphStyle: p])
    let ts = text.size()
    let r = CGRect(x: centerX - ts.width / 2 - size * 0.5, y: bottomY, width: ts.width + size, height: ts.height + size * 0.4)
    let path = CGPath(roundedRect: r, cornerWidth: size * 0.3, cornerHeight: size * 0.3, transform: nil)
    ctx.addPath(path)
    ctx.setFillColor(agent ? CGColor(red: 0.07, green: 0.12, blue: 0.24, alpha: 0.92) : CGColor(red: 0.06, green: 0.06, blue: 0.08, alpha: 0.88))
    ctx.fillPath()
    ctx.addPath(path); ctx.setLineWidth(size * 0.1)
    let border = agent ? CGColor(red: 0.30, green: 0.48, blue: 0.85, alpha: 1)
                       : (accent == .claude ? CGColor(gray: 0.55, alpha: 1) : accent.ns.cgColor)
    ctx.setStrokeColor(border); ctx.strokePath()
    text.draw(in: CGRect(x: r.minX, y: r.minY + size * 0.2, width: r.width, height: ts.height))
}

/// Bolts, sparks and lightning between pairs, drawn on one fx-resolution pixel canvas over the whole frame.
func drawFX(_ pairs: [(Actor, Actor)], _ ctx: CGContext, t: Double) {
    guard !pairs.isEmpty else { return }
    let c = PixelCanvas(Int(Double(W) / S), Int(Double(H) / S))
    for (l, r) in pairs { drawFightFX(c, t: t, left: l.fighter, right: r.fighter) }
    if let img = c.makeImage() { ctx.draw(img, in: CGRect(x: 0, y: 0, width: W, height: H)) }
}

// MARK: Text

func text(_ s: String, _ ctx: CGContext, x: Double? = nil, y: Double, size: CGFloat, weight: NSFont.Weight = .heavy,
          color: NSColor = .white, alpha: Double = 1, font: NSFont? = nil, kern: CGFloat = 0) {
    let f = font ?? NSFont.systemFont(ofSize: size, weight: weight)
    let shadow = NSShadow(); shadow.shadowColor = NSColor.black.withAlphaComponent(0.6 * alpha)
    shadow.shadowBlurRadius = 12; shadow.shadowOffset = NSSize(width: 0, height: -3)
    let a = NSAttributedString(string: s, attributes: [.font: f, .foregroundColor: color.withAlphaComponent(alpha),
                                                       .kern: kern, .shadow: shadow])
    let w = a.size().width
    a.draw(at: NSPoint(x: x ?? (Double(W) - w) / 2, y: y))
}

/// A caption that slides up and fades in at `start` (shot-local seconds).
func caption(_ s: String, _ ctx: CGContext, local: Double, start: Double = 0.1, y: Double = 900, size: CGFloat = 64,
             color: NSColor = .white) {
    let f = easeOut((local - start) / 0.35)
    guard f > 0 else { return }
    text(s, ctx, y: y - 30 * (1 - f), size: size, color: color, alpha: f)
}

// MARK: Backgrounds

/// The user's desktop: a dusky wallpaper with three terminal windows (dimmed once the battle starts).
func desktop(_ ctx: CGContext, dim: Double, statusDots: Bool = false, t: Double = 0) {
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                       colors: [CGColor(red: 0.20, green: 0.21, blue: 0.29, alpha: 1),
                                CGColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: 0), options: [])
    // menu bar
    ctx.setFillColor(CGColor(gray: 0, alpha: 0.35)); ctx.fill(CGRect(x: 0, y: H - 34, width: W, height: 34))
    let lines = [["claude ▸ refactor the hook installer", "● Reading HookInstaller.swift", "● Editing 3 files…", "✻ Thinking…"],
                 ["claude ▸ write the changelog", "● Bash(git log --oneline)", "", "Allow this command?  ❯ Yes   No"],
                 ["claude ▸ add a tauntaun", "✓ Done in 4m 12s", "", "> _"]]
    for i in 0..<3 {
        let r = CGRect(x: 110 + Double(i) * 580, y: 330 + Double(i % 2) * 70, width: 540, height: 360)
        ctx.saveGState(); ctx.setAlpha(CGFloat(1 - dim * 0.75))
        ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 30, color: CGColor(gray: 0, alpha: 0.5))
        ctx.addPath(CGPath(roundedRect: r, cornerWidth: 14, cornerHeight: 14, transform: nil))
        ctx.setFillColor(CGColor(red: 0.09, green: 0.09, blue: 0.11, alpha: 1)); ctx.fillPath()
        ctx.setShadow(offset: .zero, blur: 0)
        for (j, col) in [CGColor(red: 1, green: 0.37, blue: 0.34, alpha: 1), CGColor(red: 1, green: 0.74, blue: 0.18, alpha: 1),
                         CGColor(red: 0.16, green: 0.79, blue: 0.25, alpha: 1)].enumerated() {
            ctx.setFillColor(col); ctx.fillEllipse(in: CGRect(x: r.minX + 18 + Double(j) * 24, y: r.maxY - 30, width: 14, height: 14))
        }
        for (j, l) in lines[i].enumerated() {
            let col: NSColor = j == 0 ? NSColor(srgbRed: 0.85, green: 0.47, blue: 0.34, alpha: 1) : NSColor(white: 0.8, alpha: 1)
            NSAttributedString(string: l, attributes: [.font: NSFont.monospacedSystemFont(ofSize: 21, weight: .medium),
                                                       .foregroundColor: col]).draw(at: NSPoint(x: r.minX + 24, y: r.maxY - 90 - Double(j) * 44))
        }
        ctx.restoreGState()
    }
    // the dark floor band the battle stands on
    ctx.setFillColor(CGColor(red: 0.10, green: 0.10, blue: 0.14, alpha: dim * 0.55))
    ctx.fill(CGRect(x: 0, y: 0, width: W, height: Int(Double(H) - groundY * S + 6)))
}

func space(_ ctx: CGContext, t: Double) {
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                       colors: [CGColor(red: 0.16, green: 0.10, blue: 0.30, alpha: 1),
                                CGColor(red: 0.03, green: 0.04, blue: 0.10, alpha: 1)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: 0), options: [])
    for i in 0..<220 {
        let big = noise(i * 3 + 2) > 0.85
        let tw = 0.6 + 0.4 * sin(t * 3 + Double(i))
        ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: (big ? 0.9 : 0.45) * tw))
        let s = big ? 6.0 : 3.0
        let x = (noise(i * 3) * Double(W) - t * (big ? 40 : 20)).truncatingRemainder(dividingBy: Double(W))
        ctx.fill(CGRect(x: x < 0 ? x + Double(W) : x, y: 250 + noise(i * 3 + 1) * Double(H - 250), width: s, height: s))
    }
    ctx.setFillColor(CGColor(red: 0.10, green: 0.10, blue: 0.16, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: 240))
    ctx.setFillColor(claudeOrange); ctx.fill(CGRect(x: 0, y: 236, width: W, height: 6))
}

let appIcon: CGImage? = NSImage(contentsOfFile: "docs/icon.png")?.cgImage(forProposedRect: nil, context: nil, hints: nil)

// MARK: Shots

struct Shot { let name: String; let start: Double; let end: Double; let render: (CGContext, Double, Double) -> Void }

let shots: [Shot] = [
    // 1 · The hook: three busy terminals — which one needs you?
    Shot(name: "hook", start: 0, end: 2.0) { ctx, local, t in
        let zoom = 1 + 0.03 * local
        ctx.saveGState()
        ctx.translateBy(x: Double(W) / 2, y: Double(H) / 2); ctx.scaleBy(x: zoom, y: zoom)
        ctx.translateBy(x: -Double(W) / 2, y: -Double(H) / 2)
        desktop(ctx, dim: 0)
        ctx.restoreGState()
        caption("Three AI sessions running.", ctx, local: local, start: 0.05, y: 860)
        caption("Which one needs you?", ctx, local: local, start: 0.6, y: 120, size: 76, color: yellow)
    },
    // 2 · The reveal: they're a Star Wars battle along the bottom of the screen.
    Shot(name: "battle", start: 2.0, end: 4.6) { ctx, local, t in
        desktop(ctx, dim: easeOut(local / 0.4))
        let drop = { (d: Double) -> Double in max(0, 40 * (1 - easeIn((local - d) / 0.3))) }
        var vader = Actor(cast: .villain(.vader), x: 62, mode: .working, role: .duel, label: "idle-claude")
        var kylo = Actor(cast: .villain(.kylo), x: 119, facing: -1, mode: .working, role: .duel, label: "website")
        var han = Actor(cast: .hero(.han), x: 190, session: false, role: .shoot(offset: 0), label: "Run the test suite")
        var yoda = Actor(cast: .hero(.yoda), x: 246, facing: -1, session: false, role: .deflect, label: "Review Overlay.swift")
        vader.lift = drop(0); kylo.lift = drop(0.12); han.lift = drop(0.24); yoda.lift = drop(0.32)
        for a in [vader, kylo, han, yoda] where a.lift < 40 { draw(a, ctx, t: t) }
        if local > 0.45 { drawFX([(vader, kylo), (han, yoda)], ctx, t: t) }
        caption("…are a pixel-art Star Wars battle", ctx, local: local, start: 0.35, y: 900)
        caption("on your desktop.", ctx, local: local, start: 0.55, y: 815)
    },
    // 3 · Status at a glance: working, thinking, needs you, done.
    Shot(name: "status", start: 4.6, end: 7.0) { ctx, local, t in
        desktop(ctx, dim: 1)
        let cast: [(Cast, VaderMode, BubbleKind?, String, NSColor)] = [
            (.villain(.vader), .working, nil, "WORKING", NSColor(srgbRed: 0.45, green: 0.85, blue: 0.45, alpha: 1)),
            (.villain(.emperor), .thinking, .thinking, "THINKING", NSColor(white: 0.9, alpha: 1)),
            (.villain(.boba), .waiting, .waiting, "NEEDS YOU", NSColor(srgbRed: 1, green: 0.4, blue: 0.4, alpha: 1)),
            (.villain(.jabba), .idle, .sleeping, "DONE · ASLEEP", NSColor(srgbRed: 0.6, green: 0.55, blue: 1, alpha: 1)),
        ]
        for (i, (who, mode, bubble, word, col)) in cast.enumerated() {
            let d = 0.1 + Double(i) * 0.22
            let f = backOut((local - d) / 0.35)
            guard local > d else { continue }
            var a = Actor(cast: who, x: 48 + Double(i) * 75, mode: mode, bubble: bubble)
            a.urgent = mode == .waiting
            if a.urgent { a.lift = abs(sin(t * 2 * .pi * 1.6)) * 6 }      // ignored for a minute: it jumps
            a.lift += (1 - f) * -8
            a.alpha = clamp(f)
            draw(a, ctx, t: t)
            let w = NSAttributedString(string: word, attributes: [.font: NSFont.systemFont(ofSize: 40, weight: .black), .kern: 2]).size().width
            text(word, ctx, x: a.x * S - w / 2, y: 70, size: 40, weight: .black, color: col, alpha: clamp(f), kern: 2)
        }
        caption("Know what every session is doing — at a glance.", ctx, local: local, start: 0.05, y: 900, size: 58)
    },
    // 4 · Subagents march in, each labelled with its task.
    Shot(name: "agents", start: 7.0, end: 9.0) { ctx, local, t in
        desktop(ctx, dim: 1)
        draw(Actor(cast: .villain(.vader), x: 262, facing: -1, mode: .standGuard, label: "idle-claude"), ctx, t: t)
        let crew: [(Companion, String, Double)] = [(.luke, "Find hook events", 190), (.leia, "Write changelog", 140),
                                                   (.chewie, "Check git history", 90), (.r2d2, "Plan the refactor", 40)]
        for (i, (who, task, stop)) in crew.enumerated() {
            let d = Double(i) * 0.18
            let f = easeOut((local - d) / 0.75)
            let x = lerp(-30, stop, f)
            draw(Actor(cast: .hero(who), x: x, session: false, walking: f < 0.98, label: task), ctx, t: t)
        }
        caption("Every subagent joins the fight.", ctx, local: local, start: 0.1, y: 900)
    },
    // 5 · Claude vs Codex vs Qwen: each AI takes a side and gets its own outline.
    Shot(name: "versus", start: 9.0, end: 10.8) { ctx, local, t in
        desktop(ctx, dim: 1)
        let vader = Actor(cast: .villain(.vader), x: 92, role: .duel, label: "CLAUDE", ai: .claude)
        let luke = Actor(cast: .hero(.luke), x: 149, facing: -1, role: .duel, label: "CODEX", ai: .codex)
        let push = easeOut(local / 0.3)
        var v = vader, l = luke
        v.x -= 30 * (1 - push); l.x += 30 * (1 - push)
        var qwen = Actor(cast: .hero(.yoda), x: 236, facing: -1, role: .cheer, label: "QWEN", ai: .qwen)
        qwen.alpha = clamp((local - 0.3) / 0.2)
        for a in [v, l, qwen] { draw(a, ctx, t: t) }
        if push > 0.99 { drawFX([(v, l)], ctx, t: t) }
        caption("Claude vs Codex vs Qwen Code.", ctx, local: local, start: 0.05, y: 900)
        caption("Light side vs dark side — literally.", ctx, local: local, start: 0.35, y: 820, size: 48, color: yellow)
    },
    // 6 · End card: the Falcon flies through, the title lands.
    Shot(name: "endcard", start: 10.8, end: 13.0) { ctx, local, t in
        space(ctx, t: local)
        // the Falcon streaks across the sky
        let fp = local / 0.9
        if fp < 1 {
            let fc = PixelCanvas(66, 29)
            drawFalcon(fc, ramp: 0, engines: true, gear: false)
            fc.addOutline(C(0xFFFFFF, 0.92))
            if let img = fc.makeImage() {
                let x = lerp(-500, Double(W) + 100, easeIn(fp) * 0.6 + fp * 0.4)
                ctx.draw(img, in: CGRect(x: x, y: 560 + 200 * fp, width: 66 * 6, height: 29 * 6))
            }
        }
        // the crew on the horizon
        let crew: [(Cast, FightRole, AI)] = [(.villain(.boba), .shoot(offset: 0), .claude), (.villain(.vader), .duel, .claude),
                                             (.hero(.luke), .duel, .codex), (.hero(.han), .none, .codex),
                                             (.hero(.yoda), .cheer, .qwen), (.hero(.leia), .none, .qwen)]
        for (i, (who, role, ai)) in crew.enumerated() {
            var a = Actor(cast: who, x: 30 + Double(i) * 52, facing: i < 2 ? 1 : -1, role: role, ai: ai)
            a.lift = groundY - (Double(H) - 242) / S        // feet on the orange horizon
            a.alpha = clamp((local - 0.15 - Double(i) * 0.05) / 0.2)
            draw(a, ctx, t: t)
        }
        let f = backOut((local - 0.35) / 0.4)
        if local > 0.35 {
            let tf = NSFont(name: "Futura-CondensedExtraBold", size: 190) ?? .systemFont(ofSize: 170, weight: .black)
            ctx.saveGState()
            ctx.translateBy(x: Double(W) / 2, y: 690); ctx.scaleBy(x: f, y: f); ctx.translateBy(x: -Double(W) / 2, y: -690)
            text("CLAWD WARS", ctx, y: 600, size: 190, color: yellow, font: tf, kern: 14)
            ctx.restoreGState()
        }
        caption("Free for macOS · Claude Code · Codex · Qwen Code", ctx, local: local, start: 0.6, y: 510, size: 40,
                color: NSColor(white: 0.9, alpha: 1))
        // the app icon and where to get it, in the floor band
        let ff = easeOut((local - 0.7) / 0.3)
        if ff > 0, let icon = appIcon {
            ctx.saveGState(); ctx.setAlpha(CGFloat(ff)); ctx.interpolationQuality = .high
            ctx.draw(icon, in: CGRect(x: 640, y: 50, width: 140, height: 140))
            ctx.restoreGState()
            text("github.com/rodclemen/clawd-wars", ctx, x: 810, y: 92, size: 44, weight: .bold, alpha: ff)
        }
    },
]

// MARK: Frame

/// A Star Wars wipe between shots: a soft, feathered edge travels across the frame at a constant speed,
/// uncovering the next shot behind it while both shots keep playing. Centred on each cut.
let wipe = 1.2, feather = 220.0

/// Greyscale mask that is white (keep the outgoing shot) to the right of `edge`, ramping softly across `feather`.
func wipeMask(edge: Double) -> CGImage {
    var row = [UInt8](repeating: 0, count: W)
    for x in 0..<W { row[x] = UInt8(clamp((Double(x) - edge) / feather + 0.5) * 255) }
    let provider = CGDataProvider(data: Data(row) as CFData)!
    return CGImage(width: W, height: 1, bitsPerComponent: 8, bitsPerPixel: 8, bytesPerRow: W,
                   space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGBitmapInfo(rawValue: 0),
                   provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)!
}

func renderShot(_ s: Shot, at t: Double, into ctx: CGContext) {
    ctx.saveGState(); s.render(ctx, t - s.start, t); ctx.restoreGState()
}

func frame(_ t: Double) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let gc = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = gc
    let ctx = gc.cgContext
    ctx.interpolationQuality = .none
    if let j = shots.indices.dropFirst().first(where: { abs(t - shots[$0].start) < wipe / 2 }) {
        // Mid-wipe: the incoming shot underneath, the outgoing one on top, masked to the right of the edge.
        let p = (t - shots[j].start + wipe / 2) / wipe
        let edge = lerp(-feather / 2, Double(W) + feather / 2, p)
        renderShot(shots[j], at: t, into: ctx)
        ctx.saveGState()
        ctx.clip(to: CGRect(x: 0, y: 0, width: W, height: H), mask: wipeMask(edge: edge))
        ctx.interpolationQuality = .none
        renderShot(shots[j - 1], at: t, into: ctx)
        ctx.restoreGState()
    } else {
        renderShot(shots[shots.lastIndex(where: { t >= $0.start }) ?? 0], at: t, into: ctx)
    }
    // fade in from / out to black
    let black = max(1 - t / 0.2, 0)
    if black > 0 { ctx.setFillColor(CGColor(gray: 0, alpha: black)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H)) }
    NSGraphicsContext.current = nil
    return rep
}

func save(_ rep: NSBitmapImageRep, _ path: String) {
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}

// MARK: Storyboard sheet

let beats: [(title: String, action: String, onScreen: String, sound: String)] = [
    ("THE HOOK", "Three busy terminals on a dusky Mac desktop, slow push-in. One thinking, one waiting on a permission prompt, one long done.",
     "“Three AI sessions running.”  →  “Which one needs you?”", "low synth hum, keyboard clicks"),
    ("THE REVEAL", "Star Wars wipe. Desktop dims; Vader and Kylo drop onto the bottom edge and duel (sparks where blades meet). Agent Han fires at Yoda, who deflects every bolt. Real labels: project names and agent tasks.",
     "“…are a pixel-art Star Wars battle on your desktop.”", "saber ignite + clash, blaster pew"),
    ("AT A GLANCE", "Four Claudes pop in left to right: Vader swings his kata, the Emperor's bubble fills with dots, Boba's red ! jumps (ignored for a minute), Jabba snoozes with zZz.",
     "“Know what every session is doing — at a glance.”  ·  WORKING · THINKING · NEEDS YOU · DONE", "one 8-bit blip per pop"),
    ("SUBAGENTS", "Vader stands guard on the right. R2-D2, Chewie, Leia and Luke march in from the left one after another, each with its task label, and fall into line.",
     "“Every subagent joins the fight.”", "marching footsteps, R2 beep"),
    ("PICK A SIDE", "Claude's Vader (white outline) and Codex's Luke (cyan outline) slide in and lock sabers; Qwen's Yoda (lavender) fades in cheering with sparkles.",
     "“Claude vs Codex vs Qwen Code.”  ·  “Light side vs dark side — literally.”", "big saber clash"),
    ("END CARD", "Wipe to space. The Millennium Falcon streaks across; the crew lines up on the orange horizon; the title punches in, then the icon and link.",
     "CLAWD WARS  ·  Free for macOS · Claude Code · Codex · Qwen Code  ·  github.com/rodclemen/clawd-wars", "Falcon flyby whoosh, final sting"),
]

func storyboard(_ frames: [NSBitmapImageRep]) -> NSBitmapImageRep {
    let cols = 2, pw = 900.0, ph = pw * 9 / 16, textH = 260.0, gap = 60.0, margin = 70.0, headH = 200.0
    let rows = (frames.count + cols - 1) / cols
    let sw = Int(margin * 2 + pw * Double(cols) + gap * Double(cols - 1))
    let sh = Int(headH + Double(rows) * (ph + textH) + Double(rows - 1) * gap * 0.5 + margin)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: sw, pixelsHigh: sh, bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let gc = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = gc
    let ctx = gc.cgContext
    ctx.setFillColor(CGColor(red: 0.07, green: 0.075, blue: 0.11, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: sw, height: sh))
    func put(_ s: String, _ x: Double, _ y: Double, _ size: CGFloat, _ weight: NSFont.Weight, _ col: NSColor, width: Double = 0) {
        let a = NSAttributedString(string: s, attributes: [.font: NSFont.systemFont(ofSize: size, weight: weight), .foregroundColor: col])
        if width > 0 { a.draw(with: NSRect(x: x, y: y - 200, width: width, height: 200), options: [.usesLineFragmentOrigin]) }   // y = top edge
        else { a.draw(at: NSPoint(x: x, y: y)) }
    }
    let tf = NSFont(name: "Futura-CondensedExtraBold", size: 64) ?? .systemFont(ofSize: 60, weight: .black)
    NSAttributedString(string: "CLAWD WARS", attributes: [.font: tf, .foregroundColor: yellow, .kern: 5])
        .draw(at: NSPoint(x: margin, y: Double(sh) - 110))
    put("13-second promo · storyboard · 1920×1080 · 30 fps · every sprite drawn by the app's own code",
        margin, Double(sh) - 150, 26, .medium, NSColor(white: 0.75, alpha: 1))
    let dim = NSColor(white: 0.62, alpha: 1), body = NSColor(white: 0.92, alpha: 1)
    for (i, f) in frames.enumerated() {
        let s = shots[i], b = beats[i]
        let x = margin + Double(i % cols) * (pw + gap)
        let top = Double(sh) - headH - Double(i / cols) * (ph + textH + gap * 0.5)
        let r = CGRect(x: x, y: top - ph, width: pw, height: ph)
        ctx.saveGState(); ctx.interpolationQuality = .high
        ctx.draw(f.cgImage!, in: r)
        ctx.restoreGState()
        ctx.setStrokeColor(CGColor(gray: 1, alpha: 0.25)); ctx.setLineWidth(2); ctx.stroke(r)
        let ty = top - ph - 44
        put("\(i + 1)  \(b.title)", x, ty, 30, .heavy, yellow)
        put(String(format: "%.1f – %.1f s", s.start, s.end), x + pw - 170, ty + 2, 26, .semibold, dim)
        put(b.action, x, ty - 14, 21, .regular, body, width: pw)
        put("ON SCREEN  " + b.onScreen, x, ty - 100, 20, .semibold, NSColor(srgbRed: 0.75, green: 0.85, blue: 1, alpha: 1), width: pw)
        put("SOUND  " + b.sound, x, ty - 180, 20, .semibold, dim, width: pw)
    }
    NSGraphicsContext.current = nil
    return rep
}

// MARK: Main

let args = CommandLine.arguments
let cmd = args.count > 1 ? args[1] : "storyboard"
let out = args.count > 2 ? args[2] : "build/promo"
try? FileManager.default.createDirectory(atPath: out, withIntermediateDirectories: true)

/// Encodes every frame straight into an H.264 MP4 with AVAssetWriter (no ffmpeg needed).
func writeVideo(to path: String) {
    let url = URL(fileURLWithPath: path)
    try? FileManager.default.removeItem(at: url)
    let writer = try! AVAssetWriter(outputURL: url, fileType: .mp4)
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
        AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: W, AVVideoHeightKey: H,
        AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: 16_000_000, AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel],
    ])
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB, kCVPixelBufferWidthKey as String: W,
        kCVPixelBufferHeightKey as String: H,
    ])
    writer.add(input)
    writer.startWriting(); writer.startSession(atSourceTime: .zero)
    let n = Int(duration * fps)
    for f in 0..<n {
        autoreleasepool {
            while !input.isReadyForMoreMediaData { Thread.sleep(forTimeInterval: 0.005) }
            var pb: CVPixelBuffer?
            CVPixelBufferPoolCreatePixelBuffer(nil, adaptor.pixelBufferPool!, &pb)
            let buf = pb!
            CVPixelBufferLockBaseAddress(buf, [])
            let ctx = CGContext(data: CVPixelBufferGetBaseAddress(buf), width: W, height: H, bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buf), space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)!
            ctx.draw(frame(Double(f) / fps).cgImage!, in: CGRect(x: 0, y: 0, width: W, height: H))
            CVPixelBufferUnlockBaseAddress(buf, [])
            adaptor.append(buf, withPresentationTime: CMTime(value: CMTimeValue(f), timescale: CMTimeScale(fps)))
        }
    }
    input.markAsFinished()
    let done = DispatchSemaphore(value: 0)
    writer.finishWriting { done.signal() }
    done.wait()
    if writer.status != .completed { print("video failed: \(String(describing: writer.error))"); exit(1) }
    print("wrote \(path)")
}

if cmd == "video" {
    writeVideo(to: "\(out)/clawd-wars-promo.mp4")
} else if cmd == "frames" {
    let n = Int(duration * fps)
    for f in 0..<n { autoreleasepool { save(frame(Double(f) / fps), "\(out)/frame-\(String(format: "%03d", f)).png") } }
    print("wrote \(n) frames to \(out)")
} else if cmd == "frame" {
    let t = Double(args[3]) ?? 0
    save(frame(t), "\(out)/t\(args[3]).png"); print("wrote \(out)/t\(args[3]).png")
} else {
    let keys: [Double] = [1.2, 3.6, 6.1, 8.2, 9.95, 12.6]
    let frames = keys.map(frame)
    for (i, f) in frames.enumerated() { save(f, "\(out)/key-\(i + 1).png") }
    save(storyboard(frames), "\(out)/storyboard.png")
    print("wrote \(keys.count) key frames and storyboard.png to \(out)")
}
