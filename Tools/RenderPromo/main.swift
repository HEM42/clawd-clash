import AppKit
import AVFoundation

// Renders the promo with the app's own sprite code: a storyboard sheet of key frames, or the video
// (1920×1080, 30 fps). Build it, then run it from the repo root (it reads docs/icon.png):
//   swiftc -O -swift-version 5 Sources/App/Pixel.swift Sources/App/Characters.swift Sources/App/Leaders.swift \
//          Sources/App/Cast.swift Sources/App/Cantina.swift Sources/App/Locations.swift Sources/Shared/*.swift \
//          Tools/RenderPromo/main.swift -o /tmp/renderpromo
//   /tmp/renderpromo storyboard promo     → storyboard.png + one PNG per key frame
//   /tmp/renderpromo video promo          → clawd-wars-promo.mp4 (H.264, silent)
//   /tmp/renderpromo frame promo 9.5      → a single frame at 9.5 s

let W = 1920, H = 1080, fps = 30.0, duration = 30.2

// The stage the crew stands on. The whole frame by default; window mode narrows it to the scene strip.
var S = 6.0                      // screen pixels per sprite pixel for a session; agents are 2/3 of that
var groundY = 150.0              // fx-row of the floor line (the fx canvas is stageW/S × stageH/S, y down)
var stageW = Double(W), stageH = Double(H)

/// Runs `body` with the stage moved into `rect` (screen coordinates, y up), at `scale`, floor on fx-row `ground`.
func onStage(_ ctx: CGContext, _ rect: CGRect, scale: Double, ground: Double, _ body: () -> Void) {
    let saved = (S, groundY, stageW, stageH)
    ctx.saveGState()
    ctx.translateBy(x: rect.minX, y: rect.minY)
    ctx.clip(to: CGRect(origin: .zero, size: rect.size))
    (S, groundY, stageW, stageH) = (scale, ground, Double(rect.width), Double(rect.height))
    body()
    (S, groundY, stageW, stageH) = saved
    ctx.restoreGState()
}

// MARK: Palette

let yellow = NSColor(srgbRed: 1, green: 0.91, blue: 0.12, alpha: 1)
let claudeOrange = CGColor(red: 0.85, green: 0.47, blue: 0.34, alpha: 1)
func hexColor(_ h: UInt32) -> NSColor {
    NSColor(srgbRed: CGFloat((h >> 16) & 0xFF) / 255, green: CGFloat((h >> 8) & 0xFF) / 255, blue: CGFloat(h & 0xFF) / 255, alpha: 1)
}

/// Every AI Clawd Wars supports, with its outline colour from `AIStyle`.
enum AI: CaseIterable { case claude, desktop, codex, qwen, gemini, copilot
    var hex: UInt32 {
        switch self {
        case .claude: return 0xFFFFFF; case .desktop: return 0xFF9E7A; case .codex: return 0x6FD3FF
        case .qwen: return 0xC08CFF; case .gemini: return 0xFFD166; case .copilot: return 0x7CF5A4
        }
    }
    var ns: NSColor { hexColor(hex) }
    var name: String {
        switch self {
        case .claude: return "Claude Code"; case .desktop: return "Claude Desktop"; case .codex: return "OpenAI Codex"
        case .qwen: return "Qwen Code"; case .gemini: return "Gemini CLI"; case .copilot: return "GitHub Copilot CLI"
        }
    }
    var tag: String {
        switch self {
        case .claude: return "CLAUDE"; case .desktop: return "DESKTOP"; case .codex: return "CODEX"
        case .qwen: return "QWEN"; case .gemini: return "GEMINI"; case .copilot: return "GITHUB\nCOPILOT CLI"
        }
    }
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
    var labelSize: CGFloat? = nil
    var ai: AI = .claude
    var lift = 0.0                        // fx units off the floor (jumps, drop-ins)
    var alpha = 1.0
    var grow = 1.0                        // extra size (Claude stands a head taller in the line-up)
    var k: Double { (session ? 1 : 2.0 / 3) * grow }
    var top: Double { groundY - 44 * k - lift }
    var fighter: Fighter {
        Fighter(weapon: cast.weapon, x: x, k: k, top: top, side: facing, muzzle: cast.muzzle)
    }
}

/// A character's sprite with its AI's outline, for portraits.
func portrait(_ who: Cast, ai: AI, t: Double = 0.4) -> CGImage? {
    let c = PixelCanvas(Sprite.width, Sprite.height)
    who.draw(c, t: t, mode: .working, walking: false, role: .none, asSession: true)
    c.addOutline(C(ai.hex, 0.92))
    guard let b = c.opaqueBounds() else { return nil }
    return c.makeImage()?.cropping(to: b)
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
    ctx.draw(img, in: CGRect(x: x0, y: stageH - yTop - Double(Sprite.height) * px,
                             width: Double(Sprite.width) * px, height: Double(Sprite.height) * px))
    // Speech bubble beside the head, tail pointing back at it.
    if let kind = a.bubble {
        let bc = PixelCanvas(Bubble.width, Bubble.height)
        drawBubble(bc, kind: kind, t: t, urgent: a.urgent, tailRight: a.facing < 0)
        if let bi = bc.makeImage() {
            let headRow = a.top + Double(a.cast.headTop) * a.k
            let bx = a.facing > 0 ? a.x + 7 * a.k : a.x - 7 * a.k - Double(Bubble.width)
            let by = headRow - Double(Bubble.height) + 2
            ctx.draw(bi, in: CGRect(x: bx * S, y: stageH - (by + Double(Bubble.height)) * S,
                                    width: Double(Bubble.width) * S, height: Double(Bubble.height) * S))
        }
    }
    if let l = a.label {
        let headRow = a.top + Double(a.cast.headTop) * a.k
        let z = S / 6
        chip(l, ctx, centerX: a.x * S, bottomY: stageH - headRow * S + (a.session ? 22 : 16) * z,
             size: a.labelSize ?? max(15, (a.session ? 30 : 23) * z), agent: !a.session, accent: a.ai)
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

/// Bolts, sparks and lightning between pairs, drawn on one fx-resolution pixel canvas over the whole stage.
func drawFX(_ pairs: [(Actor, Actor)], _ ctx: CGContext, t: Double) {
    guard !pairs.isEmpty else { return }
    let c = PixelCanvas(Int(stageW / S) + 1, Int(stageH / S) + 1)
    for (l, r) in pairs { drawFightFX(c, t: t, left: l.fighter, right: r.fighter) }
    if let img = c.makeImage() {
        ctx.draw(img, in: CGRect(x: 0, y: stageH - Double(c.h) * S, width: Double(c.w) * S, height: Double(c.h) * S))
    }
}

// MARK: Text

func attributed(_ s: String, size: CGFloat, weight: NSFont.Weight = .heavy, color: NSColor = .white, alpha: Double = 1,
                font: NSFont? = nil, kern: CGFloat = 0) -> NSAttributedString {
    let shadow = NSShadow(); shadow.shadowColor = NSColor.black.withAlphaComponent(0.6 * alpha)
    shadow.shadowBlurRadius = 12; shadow.shadowOffset = NSSize(width: 0, height: -3)
    return NSAttributedString(string: s, attributes: [.font: font ?? NSFont.systemFont(ofSize: size, weight: weight),
                                                      .foregroundColor: color.withAlphaComponent(alpha), .kern: kern, .shadow: shadow])
}

func text(_ s: String, _ ctx: CGContext, x: Double? = nil, y: Double, size: CGFloat, weight: NSFont.Weight = .heavy,
          color: NSColor = .white, alpha: Double = 1, font: NSFont? = nil, kern: CGFloat = 0) {
    let a = attributed(s, size: size, weight: weight, color: color, alpha: alpha, font: font, kern: kern)
    a.draw(at: NSPoint(x: x ?? (Double(W) - a.size().width) / 2, y: y))
}

/// A caption that slides up and fades in at `start` (shot-local seconds).
func caption(_ s: String, _ ctx: CGContext, local: Double, start: Double = 0.1, y: Double = 900, size: CGFloat = 64,
             color: NSColor = .white, weight: NSFont.Weight = .heavy) {
    let f = easeOut((local - start) / 0.35)
    guard f > 0 else { return }
    text(s, ctx, y: y - 30 * (1 - f), size: size, weight: weight, color: color, alpha: f)
}

/// A small pill naming the mode on show ("DESKTOP MODE", "WINDOW MODE"), top-left.
func modeBadge(_ s: String, _ ctx: CGContext, local: Double) {
    let f = easeOut((local - 0.2) / 0.3)
    guard f > 0 else { return }
    let a = NSAttributedString(string: s, attributes: [.font: NSFont.monospacedSystemFont(ofSize: 26, weight: .heavy),
                                                       .foregroundColor: NSColor.black, .kern: 3])
    let sz = a.size()
    let r = CGRect(x: 60 - 40 * (1 - f), y: 980, width: sz.width + 36, height: sz.height + 16)
    ctx.saveGState(); ctx.setAlpha(CGFloat(f))
    ctx.addPath(CGPath(roundedRect: r, cornerWidth: r.height / 2, cornerHeight: r.height / 2, transform: nil))
    ctx.setFillColor(yellow.cgColor); ctx.fillPath()
    a.draw(at: NSPoint(x: r.minX + 18, y: r.minY + 8))
    ctx.restoreGState()
}

// MARK: Backgrounds

/// The user's desktop: a dusky wallpaper with three terminal windows (dimmed once the battle starts).
func desktop(_ ctx: CGContext, dim: Double, floor: Bool = true) {
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                       colors: [CGColor(red: 0.20, green: 0.21, blue: 0.29, alpha: 1),
                                CGColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: 0), options: [])
    // menu bar
    ctx.setFillColor(CGColor(gray: 0, alpha: 0.35)); ctx.fill(CGRect(x: 0, y: H - 34, width: W, height: 34))
    let lines = [["claude ▸ refactor the hook installer", "● Reading HookInstaller.swift", "● Editing 3 files…", "✻ Thinking…"],
                 ["codex ▸ write the changelog", "● Bash(git log --oneline)", "", "Allow this command?  ❯ Yes   No"],
                 ["gemini ▸ add a tauntaun", "✓ Done in 4m 12s", "", "> _"]]
    for i in 0..<3 {
        let r = CGRect(x: 110 + Double(i) * 580, y: 330 + Double(i % 2) * 70, width: 540, height: 360)
        ctx.saveGState(); ctx.setAlpha(CGFloat(1 - dim * 0.75))
        ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 30, color: CGColor(gray: 0, alpha: 0.5))
        ctx.addPath(CGPath(roundedRect: r, cornerWidth: 14, cornerHeight: 14, transform: nil))
        ctx.setFillColor(CGColor(red: 0.09, green: 0.09, blue: 0.11, alpha: 1)); ctx.fillPath()
        ctx.setShadow(offset: .zero, blur: 0)
        trafficLights(ctx, x: r.minX + 18, y: r.maxY - 30)
        for (j, l) in lines[i].enumerated() {
            let col: NSColor = j > 0 ? NSColor(white: 0.8, alpha: 1) : (i == 0 ? NSColor(cgColor: claudeOrange)! : [AI.codex, .gemini][i - 1].ns)
            NSAttributedString(string: l, attributes: [.font: NSFont.monospacedSystemFont(ofSize: 21, weight: .medium),
                                                       .foregroundColor: col])
                .draw(at: NSPoint(x: r.minX + 24, y: r.maxY - 90 - Double(j) * 44))
        }
        ctx.restoreGState()
    }
    // the dark floor band the battle stands on
    if floor {
        ctx.setFillColor(CGColor(red: 0.10, green: 0.10, blue: 0.14, alpha: dim * 0.55))
        ctx.fill(CGRect(x: 0, y: 0, width: W, height: Int(Double(H) - groundY * S + 6)))
    }
}

func trafficLights(_ ctx: CGContext, x: Double, y: Double, d: Double = 14) {
    for (j, col) in [CGColor(red: 1, green: 0.37, blue: 0.34, alpha: 1), CGColor(red: 1, green: 0.74, blue: 0.18, alpha: 1),
                     CGColor(red: 0.16, green: 0.79, blue: 0.25, alpha: 1)].enumerated() {
        ctx.setFillColor(col); ctx.fillEllipse(in: CGRect(x: x + Double(j) * d * 1.7, y: y, width: d, height: d))
    }
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

// MARK: Window mode

/// One card in the window, as the app draws it: portrait, name · project, status pill, a few lines, agents.
struct Card {
    var who: Cast; var ai: AI; var name: String; var project: String
    var status: String; var statusColor: NSColor
    var lines: [(String, NSColor)]
    var agents: [(Cast, String, String, String)] = []   // portrait, name, task, detail
}

let dimText = NSColor(white: 0.62, alpha: 1), bodyText = NSColor(white: 0.9, alpha: 1)

/// Draws a card with its top-left at (x, top); returns its height. `z` scales the app's point sizes.
@discardableResult
func drawCard(_ c: Card, _ ctx: CGContext, x: Double, top: Double, width: Double, panel: NSColor, z: Double) -> Double {
    let pad = 14 * z, lineH = 19 * z, agentH = 36 * z
    let h = pad * 2 + 22 * z + Double(c.lines.count) * lineH + (c.agents.isEmpty ? 0 : 6 * z + Double(c.agents.count) * agentH)
    let r = CGRect(x: x, y: top - h, width: width, height: h)
    let box = CGPath(roundedRect: r, cornerWidth: 8 * z, cornerHeight: 8 * z, transform: nil)
    ctx.addPath(box); ctx.setFillColor((panel.blended(withFraction: 0.35, of: .black) ?? panel).withAlphaComponent(0.94).cgColor); ctx.fillPath()
    ctx.addPath(box); ctx.setStrokeColor(c.ai.ns.withAlphaComponent(0.55).cgColor); ctx.setLineWidth(1.5 * z); ctx.strokePath()

    func put(_ s: NSAttributedString, _ px: Double, _ py: Double) { s.draw(at: NSPoint(x: px, y: py)) }
    func str(_ s: String, _ size: Double, _ w: NSFont.Weight, _ col: NSColor, mono: Bool = false) -> NSAttributedString {
        NSAttributedString(string: s, attributes: [.font: mono ? NSFont.monospacedSystemFont(ofSize: size * z, weight: w)
                                                                : NSFont.systemFont(ofSize: size * z, weight: w), .foregroundColor: col])
    }
    // portrait, pixel-crisp, bottom-centred in a 96×80 (app points) box
    if let img = portrait(c.who, ai: c.ai) {
        let k = (min(96 * z / Double(img.width), 80 * z / Double(img.height), 2 * z)).rounded(.down)
        let w = Double(img.width) * k, ih = Double(img.height) * k
        ctx.saveGState(); ctx.interpolationQuality = .none
        ctx.draw(img, in: CGRect(x: r.minX + 10 * z + (96 * z - w) / 2, y: r.maxY - pad - 80 * z, width: w, height: ih))
        ctx.restoreGState()
    }
    let tx = r.minX + 26 * z + 96 * z
    var ty = r.maxY - pad - 18 * z
    let status = str(c.status, 11, .bold, c.statusColor, mono: true)
    let sw = status.size().width
    let pill = CGRect(x: r.maxX - 12 * z - sw - 14 * z, y: ty - 3 * z, width: sw + 14 * z, height: 19 * z)
    ctx.addPath(CGPath(roundedRect: pill, cornerWidth: 9.5 * z, cornerHeight: 9.5 * z, transform: nil))
    ctx.setFillColor(c.statusColor.withAlphaComponent(0.16).cgColor); ctx.fillPath()
    put(status, pill.minX + 7 * z, pill.minY + 2 * z)
    let header = NSMutableAttributedString(attributedString: str(c.name, 14, .bold, .white))
    header.append(str("  ·  " + c.project, 13, .semibold, c.ai.ns))
    put(header, tx, ty)
    ty -= 22 * z
    for (l, col) in c.lines { put(str(l, 11.5, .regular, col), tx, ty); ty -= lineH }
    if !c.agents.isEmpty {
        ty -= 6 * z
        for (who, name, task, detail) in c.agents {
            if let img = portrait(who, ai: c.ai) {
                let k = (min(36 * z / Double(img.width), 30 * z / Double(img.height))).rounded(.down)
                ctx.saveGState(); ctx.interpolationQuality = .none
                ctx.draw(img, in: CGRect(x: tx - 4 * z, y: ty - 14 * z, width: Double(img.width) * k, height: Double(img.height) * k))
                ctx.restoreGState()
            }
            let title = NSMutableAttributedString(attributedString: str(name, 11.5, .semibold, .white))
            title.append(str("  —  " + task, 11.5, .regular, c.ai.ns))
            put(title, tx + 40 * z, ty)
            put(str(detail, 10.5, .regular, dimText), tx + 40 * z, ty - 16 * z)
            ty -= agentH
        }
    }
    return h
}

/// The "Show in Window" window: themed title bar, the cantina with the crew in it, a card per session.
func windowMode(_ ctx: CGContext, frame r: CGRect, local: Double, t: Double) {
    let loc = Location.cantina
    let panel = loc.panel
    let z = 2.0, cz = 1.5                         // app points → screen pixels (window chrome, cards)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -20), blur: 60, color: CGColor(gray: 0, alpha: 0.6))
    let outline = CGPath(roundedRect: r, cornerWidth: 22, cornerHeight: 22, transform: nil)
    ctx.addPath(outline); ctx.setFillColor((panel.blended(withFraction: 0.45, of: .black) ?? panel).cgColor); ctx.fillPath()
    ctx.restoreGState()
    ctx.saveGState()
    ctx.addPath(outline); ctx.clip()
    // title bar
    let barH = 30 * z
    trafficLights(ctx, x: r.minX + 20, y: r.maxY - barH / 2 - 7, d: 15)
    let where_ = NSAttributedString(string: loc.name.uppercased(), attributes: [
        .font: NSFont.systemFont(ofSize: 10.5 * z, weight: .semibold), .foregroundColor: NSColor(white: 0.78, alpha: 1), .kern: 1.2 * z])
    where_.draw(at: NSPoint(x: r.maxX - where_.size().width - 28, y: r.maxY - barH / 2 - where_.size().height / 2))
    // the scene strip: the cantina at 2 px per pixel in the app, so 4 here
    let px = Double(Cantina.pixel) * z
    let stripH = 100.0 * z
    let strip = CGRect(x: r.minX, y: r.maxY - barH - stripH, width: r.width, height: stripH)
    let cw = Int((strip.width / px).rounded(.up)), ch = Int(stripH / px)
    let floorRows = Int(20 / Double(Cantina.pixel))
    let room = PixelCanvas(cw, ch); loc.drawStatic(room, floorRows: floorRows)
    let live = PixelCanvas(cw, ch); loc.drawAnimated(live, floorRows: floorRows, t: t)
    ctx.saveGState(); ctx.interpolationQuality = .none
    for c in [room, live] { if let img = c.makeImage() { ctx.draw(img, in: CGRect(x: strip.minX, y: strip.minY, width: Double(cw) * px, height: Double(ch) * px)) } }
    ctx.restoreGState()
    // the crew in the cantina (sessions at the app's Small size: 2 pt per pixel → 4 px)
    let needsYou = local > 2.5
    onStage(ctx, strip, scale: px, ground: Double(ch) - Double(floorRows) * 0.45) {
        let vader = Actor(cast: .villain(.vader), x: 200, facing: -1, role: .duel)
        var luke = Actor(cast: .hero(.luke), x: 143, role: .duel, ai: .codex)
        if needsYou { luke.role = .none; luke.mode = .waiting; luke.bubble = .waiting; luke.urgent = true; luke.lift = abs(sin(t * 2 * .pi * 1.6)) * 4 }
        var v = vader; if needsYou { v.role = .none }
        let han = Actor(cast: .hero(.han), x: 260, facing: -1, session: false, role: .cheer, label: "Run the tests")
        let chewie = Actor(cast: .hero(.chewie), x: 300, facing: -1, session: false, role: .cheer, label: "Check git history")
        let r2 = Actor(cast: .hero(.r2d2), x: 95, facing: 1, session: false, ai: .codex)
        for a in [r2, luke, v, han, chewie] { draw(a, ctx, t: t) }
        if !needsYou { drawFX([(luke, vader)], ctx, t: t) }
    }
    // cards
    let ticks = max(0, Int(local))
    let now = ["Now: Read Overlay.swift", "Now: Edit WindowMode.swift", "Now: Bash: swift build"][min(2, max(0, Int(local / 0.9)))]
    var top = strip.minY - 10 * cz
    let x = r.minX + 10 * cz, w = r.width - 20 * cz
    top -= drawCard(Card(who: .villain(.vader), ai: .claude, name: "Darth Vader", project: "idle-claude",
                         status: "WORKING · \(24 + ticks)s", statusColor: NSColor(srgbRed: 0.45, green: 0.85, blue: 0.45, alpha: 1),
                         lines: [("claude-opus-5-5", dimText), (now, bodyText), ("You: “add a tauntaun”", bodyText)],
                         agents: [(.hero(.han), "Han Solo", "Run the tests", "Bash: swift test · \(34 + ticks)s · 9 tool calls"),
                                  (.hero(.chewie), "Chewbacca", "Check git history", "Bash: git log · 1m \(21 + ticks)s · 25 tool calls")]),
                    ctx, x: x, top: top, width: w, panel: panel, z: cz) + 10 * cz
    // the Codex group divider, then its card
    let g = NSAttributedString(string: "CODEX", attributes: [.font: NSFont.systemFont(ofSize: 10.5 * cz, weight: .heavy), .kern: 1.2 * cz,
                                                             .foregroundColor: AI.codex.ns])
    let gs = g.size()
    g.draw(at: NSPoint(x: x + 2 * cz, y: top - gs.height - 2 * cz))
    ctx.setFillColor(AI.codex.ns.withAlphaComponent(0.35).cgColor)
    ctx.fill(CGRect(x: x + gs.width + 10 * cz, y: top - gs.height / 2 - 2 * cz, width: w - gs.width - 12 * cz, height: cz))
    top -= 22 * cz
    drawCard(Card(who: .hero(.luke), ai: .codex, name: "Luke Skywalker", project: "website",
                  status: needsYou ? "NEEDS YOU · \(max(1, Int(local - 2.5) + 1))s" : "THINKING",
                  statusColor: needsYou ? NSColor(srgbRed: 1, green: 0.42, blue: 0.42, alpha: 1) : NSColor(white: 0.85, alpha: 1),
                  lines: [("gpt-5-codex", dimText), (needsYou ? "Wants to run: npm run deploy" : "Now: Thinking…", bodyText),
                          ("You: “make the hero section pop”", bodyText)]),
             ctx, x: x, top: top, width: w, panel: panel, z: cz)
    ctx.restoreGState()
}

// MARK: Shots

struct Shot { let name: String; let start: Double; let end: Double; let render: (CGContext, Double, Double) -> Void }

let shots: [Shot] = [
    // 1 · The hook: three AIs at work in three terminals, and one overwhelmed human.
    Shot(name: "hook", start: 0, end: 4.0) { ctx, local, t in
        let zoom = 1 + 0.03 * local
        ctx.saveGState()
        ctx.translateBy(x: Double(W) / 2, y: Double(H) / 2); ctx.scaleBy(x: zoom, y: zoom)
        ctx.translateBy(x: -Double(W) / 2, y: -Double(H) / 2)
        desktop(ctx, dim: 0)
        ctx.restoreGState()
        caption("Three AIs. Nine agents. One very confused human.", ctx, local: local, start: 0.05, y: 860, size: 60)
        caption("Sound familiar?", ctx, local: local, start: 0.7, y: 120, size: 76, color: yellow)
    },
    // 2 · Desktop mode: they become a Star Wars brawl along the bottom of the screen.
    Shot(name: "desktop", start: 4.0, end: 8.6) { ctx, local, t in
        desktop(ctx, dim: easeOut(local / 0.4))
        let drop = { (d: Double) -> Double in max(0, 40 * (1 - easeIn((local - d) / 0.3))) }
        var vader = Actor(cast: .villain(.vader), x: 62, mode: .working, role: .duel, label: "idle-claude")
        var luke = Actor(cast: .hero(.luke), x: 119, facing: -1, mode: .working, role: .duel, label: "website", ai: .codex)
        var han = Actor(cast: .hero(.han), x: 190, session: false, role: .shoot(offset: 0), label: "Run the test suite")
        var trooper = Actor(cast: .villain(.trooper), x: 246, facing: -1, session: false, role: .shoot(offset: blasterPeriod / 2),
                            label: "Review Overlay.swift", ai: .codex)
        vader.lift = drop(0); luke.lift = drop(0.12); han.lift = drop(0.24); trooper.lift = drop(0.32)
        for a in [vader, luke, han, trooper] where a.lift < 40 { draw(a, ctx, t: t) }
        if local > 0.45 { drawFX([(vader, luke), (han, trooper)], ctx, t: t) }
        modeBadge("DESKTOP MODE", ctx, local: local)
        caption("Now they're a pixel-art Star Wars brawl", ctx, local: local, start: 0.35, y: 900)
        caption("along the bottom of your screen. They fight while they work.", ctx, local: local, start: 0.6, y: 830,
                size: 40, color: yellow, weight: .bold)
    },
    // 3 · Status at a glance: working, thinking, needs you, napping.
    Shot(name: "status", start: 8.6, end: 12.8) { ctx, local, t in
        desktop(ctx, dim: 1)
        let cast: [(Cast, AI, VaderMode, BubbleKind?, String, NSColor)] = [
            (.villain(.vader), .claude, .working, nil, "WORKING", NSColor(srgbRed: 0.45, green: 0.85, blue: 0.45, alpha: 1)),
            (.villain(.emperor), .qwen, .thinking, .thinking, "THINKING…", NSColor(white: 0.9, alpha: 1)),
            (.villain(.boba), .gemini, .waiting, .waiting, "NEEDS YOU!", NSColor(srgbRed: 1, green: 0.4, blue: 0.4, alpha: 1)),
            (.villain(.jabba), .copilot, .idle, .sleeping, "NAPPING", NSColor(srgbRed: 0.6, green: 0.55, blue: 1, alpha: 1)),
        ]
        for (i, (who, ai, mode, bubble, word, col)) in cast.enumerated() {
            let d = 0.1 + Double(i) * 0.22
            let f = backOut((local - d) / 0.35)
            guard local > d else { continue }
            var a = Actor(cast: who, x: 48 + Double(i) * 75, mode: mode, bubble: bubble, ai: ai)
            a.urgent = mode == .waiting
            if a.urgent { a.lift = abs(sin(t * 2 * .pi * 1.6)) * 6 }      // ignored for a minute: it jumps
            a.lift += (1 - f) * -8
            a.alpha = clamp(f)
            draw(a, ctx, t: t)
            let w = NSAttributedString(string: word, attributes: [.font: NSFont.systemFont(ofSize: 40, weight: .black), .kern: 2]).size().width
            text(word, ctx, x: a.x * S - w / 2, y: 70, size: 40, weight: .black, color: col, alpha: clamp(f), kern: 2)
        }
        caption("All fun and games — and you still see everything.", ctx, local: local, start: 0.05, y: 900, size: 58)
        caption("(Leave Boba waiting and he starts jumping.)", ctx, local: local, start: 0.9, y: 835, size: 36,
                color: yellow, weight: .bold)
    },
    // 4 · Subagents march in, each labelled with its task.
    Shot(name: "agents", start: 12.8, end: 16.8) { ctx, local, t in
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
        caption("Every subagent reports for duty.", ctx, local: local, start: 0.1, y: 900)
        caption("Its job is right there on its label. No more guessing.", ctx, local: local, start: 0.45, y: 835, size: 40,
                color: yellow, weight: .bold)
    },
    // 5 · Window mode: the crew in the cantina, a live card for every session.
    Shot(name: "window", start: 16.8, end: 21.6) { ctx, local, t in
        desktop(ctx, dim: 1, floor: false)
        let f = easeOut(local / 0.6), s = 0.94 + 0.06 * f
        let base = CGRect(x: 300, y: 20, width: 1320, height: 800)
        let r = CGRect(x: base.midX - base.width * s / 2, y: base.minY + 20 * (1 - f), width: base.width * s, height: base.height * s)
        windowMode(ctx, frame: r, local: local, t: t)
        modeBadge("WINDOW MODE", ctx, local: local)
        caption("Prefer a window? Grab the popcorn.", ctx, local: local, start: 0.1, y: 955, size: 56)
        caption("A live card per session: what it's doing, your last prompt, every agent.", ctx, local: local, start: 0.4,
                y: 890, size: 32, color: yellow, weight: .bold)
    },
    // 6 · Every AI it supports, Claude first and biggest, each with its own outline.
    Shot(name: "ais", start: 21.6, end: 26.0) { ctx, local, t in
        desktop(ctx, dim: 1)
        // the line-up: Claude a head taller, duelling Codex; everyone else cheering
        let lineup: [(Cast, AI, Double, Double, FightRole)] = [
            (.villain(.kylo), .desktop, 36, -1, .cheer), (.villain(.vader), .claude, 104, 1, .duel), (.hero(.luke), .codex, 165, -1, .duel),
            (.hero(.yoda), .qwen, 216, -1, .cheer), (.hero(.leia), .gemini, 258, -1, .cheer), (.hero(.r2d2), .copilot, 298, -1, .cheer),
        ]
        var actors: [Actor] = []
        for (i, (who, ai, x, facing, role)) in lineup.enumerated() {
            let d = 0.15 + Double(i) * 0.1
            guard local > d else { continue }
            let f = backOut((local - d) / 0.3)
            var a = Actor(cast: who, x: x, facing: facing, role: role, label: ai.tag, ai: ai)
            if ai == .claude { a.grow = 1.25; a.labelSize = 36 } else { a.labelSize = 22 }
            a.lift = (1 - f) * -10; a.alpha = clamp(f)
            actors.append(a)
            draw(a, ctx, t: t)
        }
        if actors.count >= 3 { drawFX([(actors[1], actors[2])], ctx, t: t) }
        // the names: Claude Code biggest, the rest in their own colours
        let fc = easeOut((local - 0.05) / 0.35)
        if fc > 0 {
            let tf = NSFont(name: "Futura-CondensedExtraBold", size: 140) ?? .systemFont(ofSize: 130, weight: .black)
            text("CLAUDE CODE", ctx, y: 790 - 30 * (1 - fc), size: 140, alpha: fc, font: tf, kern: 8)
        }
        let fr = easeOut((local - 0.35) / 0.35)
        if fr > 0 {
            let row = NSMutableAttributedString(attributedString: attributed("+  ", size: 40, weight: .heavy, color: dimText, alpha: fr))
            for (i, ai) in AI.allCases.dropFirst().enumerated() {
                if i > 0 { row.append(attributed("  ·  ", size: 40, weight: .heavy, color: dimText, alpha: fr)) }
                row.append(attributed(ai.name, size: 40, weight: .heavy, color: ai.ns, alpha: fr))
            }
            row.draw(at: NSPoint(x: (Double(W) - row.size().width) / 2, y: 720 - 20 * (1 - fr)))
        }
        caption("Everyone picks a side. Nobody plays nice.", ctx, local: local, start: 0.7, y: 640, size: 40, color: yellow, weight: .bold)
    },
    // 7 · End card: the Falcon flies through, the title lands.
    Shot(name: "endcard", start: 26.0, end: 30.2) { ctx, local, t in
        space(ctx, t: local)
        // the Falcon streaks across the sky
        let fp = local / 1.1
        if fp > 0 && fp < 1 {
            let fc = PixelCanvas(66, 29)
            drawFalcon(fc, ramp: 0, engines: true, gear: false)
            fc.addOutline(C(0xFFFFFF, 0.92))
            if let img = fc.makeImage() {
                let x = lerp(-500, Double(W) + 100, easeIn(fp) * 0.6 + fp * 0.4)
                ctx.draw(img, in: CGRect(x: x, y: 560 + 200 * fp, width: 66 * 6, height: 29 * 6))
            }
        }
        // the crew on the horizon, one of every AI's colours
        let crew: [(Cast, FightRole, AI)] = [(.villain(.kylo), .cheer, .desktop), (.villain(.vader), .duel, .claude),
                                             (.hero(.luke), .duel, .codex), (.hero(.r2d2), .none, .copilot),
                                             (.hero(.yoda), .cheer, .qwen), (.hero(.leia), .none, .gemini)]
        var placed: [Actor] = []
        for (i, (who, role, ai)) in crew.enumerated() {
            var a = Actor(cast: who, x: [28.0, 80, 137, 190, 240, 290][i], facing: i < 2 ? 1 : -1, role: role, ai: ai)
            a.lift = groundY - (Double(H) - 242) / S        // feet on the orange horizon
            a.alpha = clamp((local - 0.15 - Double(i) * 0.05) / 0.2)
            draw(a, ctx, t: t)
            placed.append(a)
        }
        if local > 0.5 { drawFX([(placed[1], placed[2])], ctx, t: t) }
        let f = backOut((local - 0.35) / 0.4)
        if local > 0.35 {
            let tf = NSFont(name: "Futura-CondensedExtraBold", size: 190) ?? .systemFont(ofSize: 170, weight: .black)
            ctx.saveGState()
            ctx.translateBy(x: Double(W) / 2, y: 700); ctx.scaleBy(x: f, y: f); ctx.translateBy(x: -Double(W) / 2, y: -700)
            text("CLAWD WARS", ctx, y: 620, size: 190, color: yellow, font: tf, kern: 14)
            ctx.restoreGState()
        }
        caption("Have fun. Keep track.", ctx, local: local, start: 0.6, y: 540, size: 56)
        caption("Free for macOS", ctx, local: local, start: 0.8, y: 480, size: 34, color: NSColor(white: 0.8, alpha: 1), weight: .bold)
        // the app icon and where to get it, in the floor band
        let ff = easeOut((local - 0.9) / 0.3)
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
let wipe = 2.7, feather = 220.0

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
    let black = max(1 - t / 0.2, (t - (duration - 0.3)) / 0.3, 0)
    if black > 0 { ctx.setFillColor(CGColor(gray: 0, alpha: black)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H)) }
    NSGraphicsContext.current = nil
    return rep
}

func save(_ rep: NSBitmapImageRep, _ path: String) {
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}

// MARK: Storyboard sheet

let beats: [(title: String, action: String, onScreen: String, sound: String)] = [
    ("THE HOOK", "Three busy terminals (Claude, Codex, Gemini) on a dusky Mac desktop, slow push-in. One thinking, one waiting on a permission prompt, one long done.",
     "“Three AIs. Nine agents. One very confused human.”  →  “Sound familiar?”", "low synth hum, keyboard clicks"),
    ("DESKTOP MODE", "Desktop dims; Claude's Vader and Codex's Luke drop onto the bottom edge and duel. Agent Han trades shots with a Codex Stormtrooper. Project names and agent tasks on the labels.",
     "DESKTOP MODE badge  ·  “Now they're a pixel-art Star Wars brawl along the bottom of your screen. They fight while they work.”", "saber ignite + clash, blaster pew"),
    ("AT A GLANCE", "Four sessions pop in, each in its AI's outline: Vader swings his kata, the Emperor's bubble fills with dots, Boba's red ! jumps, Jabba snoozes with zZz.",
     "“All fun and games — and you still see everything.”  ·  WORKING · THINKING… · NEEDS YOU! · NAPPING", "one 8-bit blip per pop"),
    ("SUBAGENTS", "Vader stands guard. R2-D2, Chewie, Leia and Luke march in one after another, each with its task label, and fall into line.",
     "“Every subagent reports for duty.”  ·  “Its job is right there on its label. No more guessing.”", "marching footsteps, R2 beep"),
    ("WINDOW MODE", "The app window slides up: the cantina with its band, Vader duelling Codex's Luke, agents cheering; below, live cards whose timers tick and whose “Now:” line changes. Then Luke stops, jumps with a red ! and his card flips to NEEDS YOU.",
     "WINDOW MODE badge  ·  “Prefer a window? Grab the popcorn.”  ·  “A live card per session…”", "cantina band, notification ping"),
    ("EVERY AI", "Six sessions pop in, one per AI outline (GitHub Copilot CLI gets R2-D2). Claude's Vader stands a head taller and duels Codex's Luke; the rest cheer.",
     "CLAUDE CODE (huge)  ·  + Claude Desktop · OpenAI Codex · Qwen Code · Gemini CLI · GitHub Copilot CLI  ·  “Everyone picks a side. Nobody plays nice.”", "big saber clash"),
    ("END CARD", "Wipe to space. The Millennium Falcon streaks across; the crew lines up on the horizon in all six colours; the title punches in, then the tagline, icon and link.",
     "CLAWD WARS  ·  “Have fun. Keep track.”  ·  Free for macOS  ·  github.com/rodclemen/clawd-wars", "Falcon flyby whoosh, final sting"),
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
    put(String(format: "%.0f-second promo · storyboard", duration) + " · 1920×1080 · 30 fps · every sprite drawn by the app's own code",
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
    let keys: [Double] = [1.5, 6.3, 10.9, 15.0, 19.6, 24.0, 29.0]
    let frames = keys.map(frame)
    for (i, f) in frames.enumerated() { save(f, "\(out)/key-\(i + 1).png") }
    save(storyboard(frames), "\(out)/storyboard.png")
    print("wrote \(keys.count) key frames and storyboard.png to \(out)")
}
