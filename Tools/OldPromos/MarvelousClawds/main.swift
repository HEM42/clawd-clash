import AppKit
import AVFoundation

// Renders the promo with the app's own sprite code: a storyboard sheet of key frames, or the video
// (1920×1080, 30 fps). Build it, then run it from the repo root (it reads Resources/AppIcon.png):
//   swiftc -O -swift-version 5 Sources/App/{Pixel,Characters,Fights,Roster,Pose,Locations,Cast,Habits,Accents,Icon}.swift \
//          Sources/App/Art/*.swift Sources/App/Places/*.swift Sources/Shared/*.swift \
//          Tools/RenderPromo/main.swift -o build/renderpromo
//   build/renderpromo storyboard promo     → storyboard.png + one PNG per key frame
//   build/renderpromo video promo          → avengers-clawd-wars-promo.mp4 (H.264 + AAC soundtrack)
//   build/renderpromo audio promo          → the soundtrack alone, as a .wav
//   build/renderpromo frame promo 9.5      → a single frame at 9.5 s

let W = 1920, H = 1080, fps = 30.0, duration = 50.2

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
    var sitting = false
    var airborne = false                  // a flyer in the air
    var k: Double { (session ? 1 : 2.0 / 3) * grow }
    var top: Double { groundY - 44 * k - lift }
    var fighter: Fighter {
        Fighter(weapon: cast.weapon, x: x, k: k, top: top, side: facing, muzzle: cast.muzzle, armoured: cast.armoured,
                pivot: cast.weaponPivot).dressed(as: cast)
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
    a.cast.draw(c, t: t, mode: a.mode, walking: a.walking, role: a.role, urgent: a.urgent, sitting: a.sitting,
                asSession: a.session, airborne: a.airborne)
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
    for (l, r) in pairs where fightFXVisible(t: t, l.cast.weapon, r.cast.weapon) { drawFightFX(c, t: t, left: l.fighter, right: r.fighter) }
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
                 ["gemini ▸ polish the shield", "✓ Done in 4m 12s", "", "> _"]]
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

let appIcon: CGImage? = NSImage(contentsOfFile: "Resources/AppIcon.png")?.cgImage(forProposedRect: nil, context: nil, hints: nil)

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
            title.append(str("  ·  " + task, 11.5, .regular, c.ai.ns))
            put(title, tx + 40 * z, ty)
            put(str(detail, 10.5, .regular, dimText), tx + 40 * z, ty - 16 * z)
            ty -= agentH
        }
    }
    return h
}

/// The "Show in Window" window: themed title bar, the cantina with the crew in it, a card per session.
func windowMode(_ ctx: CGContext, frame r: CGRect, local: Double, t: Double) {
    let loc = Location.avengersTower
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
    // the scene strip: the place at 2 px per pixel in the app, so 4 here
    let px = Double(Scenes.pixel) * z
    let stripH = 100.0 * z
    let strip = CGRect(x: r.minX, y: r.maxY - barH - stripH, width: r.width, height: stripH)
    let cw = Int((strip.width / px).rounded(.up)), ch = Int(stripH / px)
    let floorRows = Int(20 / Double(Scenes.pixel))
    let room = PixelCanvas(cw, ch); loc.drawStatic(room, floorRows: floorRows)
    let live = PixelCanvas(cw, ch); loc.drawAnimated(live, floorRows: floorRows, t: t)
    ctx.saveGState(); ctx.interpolationQuality = .none
    for c in [room, live] { if let img = c.makeImage() { ctx.draw(img, in: CGRect(x: strip.minX, y: strip.minY, width: Double(cw) * px, height: Double(ch) * px)) } }
    ctx.restoreGState()
    // the crew in the cantina (sessions at the app's Small size: 2 pt per pixel → 4 px)
    let needsYou = local > 2.5
    onStage(ctx, strip, scale: px, ground: Double(ch) - Double(floorRows) * 0.45) {
        let cap = Actor(cast: .hero(.captainAmerica), x: 140, role: .deflect)
        var skull = Actor(cast: .villain(.redSkull), x: 214, facing: -1, role: .shoot(offset: 0), ai: .codex)
        if needsYou { skull.role = .none; skull.mode = .waiting; skull.bubble = .waiting; skull.urgent = true; skull.lift = abs(sin(t * 2 * .pi * 1.6)) * 4 }
        var c2 = cap; if needsYou { c2.role = .none; c2.mode = .working }
        let spidey = Actor(cast: .hero(.spiderMan), x: 72, session: false, role: .cheer, label: "Run the tests")
        let widow = Actor(cast: .hero(.blackWidow), x: 30, session: false, role: .cheer, label: "Check git history")
        let hydra = Actor(cast: .villain(.hydraAgent), x: 290, facing: -1, session: false, ai: .codex)
        for a in [widow, spidey, c2, skull, hydra] { draw(a, ctx, t: t) }
        if !needsYou { drawFX([(cap, skull)], ctx, t: t) }
    }
    // cards
    let ticks = max(0, Int(local))
    let now = ["Now: Read Overlay.swift", "Now: Edit WindowMode.swift", "Now: Bash: swift build"][min(2, max(0, Int(local / 0.9)))]
    var top = strip.minY - 10 * cz
    let x = r.minX + 10 * cz, w = r.width - 20 * cz
    top -= drawCard(Card(who: .hero(.captainAmerica), ai: .claude, name: "Captain America", project: "idle-claude",
                         status: "WORKING · \(24 + ticks)s", statusColor: NSColor(srgbRed: 0.45, green: 0.85, blue: 0.45, alpha: 1),
                         lines: [("claude-opus-5-5", dimText), (now, bodyText), ("You: “make the shield bounce twice”", bodyText)],
                         agents: [(.hero(.spiderMan), "Spider-Man", "Run the tests", "Bash: swift test · \(34 + ticks)s · 9 tool calls"),
                                  (.hero(.blackWidow), "Black Widow", "Check git history", "Bash: git log · 1m \(21 + ticks)s · 25 tool calls")]),
                    ctx, x: x, top: top, width: w, panel: panel, z: cz) + 10 * cz
    // the Codex group divider, then its card
    let g = NSAttributedString(string: "CODEX", attributes: [.font: NSFont.systemFont(ofSize: 10.5 * cz, weight: .heavy), .kern: 1.2 * cz,
                                                             .foregroundColor: AI.codex.ns])
    let gs = g.size()
    g.draw(at: NSPoint(x: x + 2 * cz, y: top - gs.height - 2 * cz))
    ctx.setFillColor(AI.codex.ns.withAlphaComponent(0.35).cgColor)
    ctx.fill(CGRect(x: x + gs.width + 10 * cz, y: top - gs.height / 2 - 2 * cz, width: w - gs.width - 12 * cz, height: cz))
    top -= 22 * cz
    drawCard(Card(who: .villain(.redSkull), ai: .codex, name: "Red Skull", project: "website",
                  status: needsYou ? "NEEDS YOU · \(max(1, Int(local - 2.5) + 1))s" : "THINKING",
                  statusColor: needsYou ? NSColor(srgbRed: 1, green: 0.42, blue: 0.42, alpha: 1) : NSColor(white: 0.85, alpha: 1),
                  lines: [("gpt-5-codex", dimText), (needsYou ? "Wants to run: npm run deploy" : "Now: Thinking…", bodyText),
                          ("You: “make the hero section pop”", bodyText)]),
             ctx, x: x, top: top, width: w, panel: panel, z: cz)
    ctx.restoreGState()
}

// MARK: Opening (the Battle of New York, in pixels)

let fxW = W / 6, fxH = H / 6        // the opening is drawn on one 320×180 pixel canvas, 6 px per pixel

/// Draws a full-frame pixel canvas onto the screen, crisp.
func blit(_ c: PixelCanvas, _ ctx: CGContext, scale: Double = 6, dx: Double = 0, dy: Double = 0) {
    guard let img = c.makeImage() else { return }
    ctx.saveGState(); ctx.interpolationQuality = .none
    ctx.draw(img, in: CGRect(x: dx, y: Double(H) - Double(c.h) * scale - dy, width: Double(c.w) * scale, height: Double(c.h) * scale))
    ctx.restoreGState()
}

/// The Battle of New York backdrop from the app, at frame size: the portal over Stark Tower, smoke, the Leviathans.
func newYork(_ t: Double, floorRows: Int = 14) -> PixelCanvas {
    let c = PixelCanvas(fxW, fxH)
    Location.battleOfNewYork.drawStatic(c, floorRows: floorRows)
    Location.battleOfNewYork.drawAnimated(c, floorRows: floorRows, t: t)
    return c
}

/// A comic caption box: yellow, a thick black border, black italic capitals.
func captionBox(_ s: String, _ ctx: CGContext, center: CGPoint, size: CGFloat, alpha: Double = 1) {
    let font = NSFontManager.shared.convert(NSFont.systemFont(ofSize: size, weight: .black), toHaveTrait: .italicFontMask)
    let a = NSAttributedString(string: s, attributes: [.font: font, .foregroundColor: NSColor.black.withAlphaComponent(alpha)])
    let sz = a.size()
    let r = CGRect(x: center.x - sz.width / 2 - size * 0.7, y: center.y - sz.height / 2 - size * 0.45,
                   width: sz.width + size * 1.4, height: sz.height + size * 0.9)
    ctx.saveGState(); ctx.setAlpha(CGFloat(alpha))
    ctx.setFillColor(CGColor(gray: 0, alpha: 1)); ctx.fill(r.offsetBy(dx: 10, dy: -10))          // drop shadow
    ctx.setFillColor(CGColor(red: 1, green: 0.88, blue: 0.29, alpha: 1)); ctx.fill(r)
    ctx.setStrokeColor(CGColor(gray: 0, alpha: 1)); ctx.setLineWidth(6); ctx.stroke(r)
    ctx.restoreGState()
    a.draw(at: NSPoint(x: r.minX + size * 0.7, y: r.minY + size * 0.45))
}

/// Halftone dots over a flat colour, like an old comic panel.
func halftone(_ ctx: CGContext, _ r: CGRect, base: CGColor, dot: CGColor, step: Double = 18) {
    ctx.setFillColor(base); ctx.fill(r)
    ctx.setFillColor(dot)
    var y = r.minY, row = 0
    while y < r.maxY {
        var x = r.minX + (row % 2 == 0 ? 0 : step / 2)
        while x < r.maxX {
            let d = step * 0.42 * (0.4 + 0.6 * (y - r.minY) / r.height)
            ctx.fillEllipse(in: CGRect(x: x - d / 2, y: y - d / 2, width: d, height: d))
            x += step
        }
        y += step * 0.87; row += 1
    }
}

/// A burst behind the title: a jagged star.
func starburst(_ ctx: CGContext, center c: CGPoint, inner: Double, outer: Double, spikes: Int, color: CGColor, spin: Double) {
    let path = CGMutablePath()
    for i in 0..<(spikes * 2) {
        let a = Double(i) / Double(spikes * 2) * 2 * .pi + spin
        let r = i % 2 == 0 ? outer * (0.85 + 0.15 * noise(i)) : inner
        let p = CGPoint(x: c.x + cos(a) * r, y: c.y + sin(a) * r)
        i == 0 ? path.move(to: p) : path.addLine(to: p)
    }
    path.closeSubpath()
    ctx.addPath(path); ctx.setFillColor(color); ctx.fillPath()
    ctx.addPath(path); ctx.setStrokeColor(CGColor(gray: 0, alpha: 1)); ctx.setLineWidth(8); ctx.strokePath()
}

/// The title: AVENGERS over CLAWD WARS, comic lettering with a heavy black outline.
func title(_ ctx: CGContext, center: CGPoint, scale s: Double, alpha: Double = 1) {
    let tf = NSFont(name: "Futura-CondensedExtraBold", size: 200) ?? .systemFont(ofSize: 190, weight: .black)
    ctx.saveGState()
    ctx.translateBy(x: center.x, y: center.y); ctx.scaleBy(x: s, y: s)
    for (i, (word, col, size)) in [("AVENGERS", NSColor(srgbRed: 0.93, green: 0.16, blue: 0.16, alpha: alpha), 0.62),
                                   ("CLAWD WARS", yellow.withAlphaComponent(alpha), 1.0)].enumerated() {
        let f = NSFont(descriptor: tf.fontDescriptor, size: 200 * size) ?? tf
        let base: [NSAttributedString.Key: Any] = [.font: f, .kern: 10 * size]
        var outlined = base; outlined[.foregroundColor] = NSColor.black.withAlphaComponent(alpha)
        var filled = base; filled[.foregroundColor] = col
        let sz = NSAttributedString(string: word, attributes: base).size()
        let p = NSPoint(x: -sz.width / 2, y: i == 0 ? 40 : -sz.height + 40)
        let ink = NSAttributedString(string: word, attributes: outlined), r = 12 * size
        for k in 0..<16 {                                   // a thick, round outline: the word stamped in black all round
            let a = Double(k) / 16 * 2 * .pi
            ink.draw(at: NSPoint(x: p.x + cos(a) * r, y: p.y + sin(a) * r))
        }
        NSAttributedString(string: word, attributes: filled).draw(at: p)
    }
    ctx.restoreGState()
}

/// Where the giant Leviathan's tail is (fx units) and how big it is, at shot-local time `l`: it noses out of the
/// portal small, then swells and dives toward us until it fills the frame.
func leviathan(_ l: Double) -> (x: Double, y: Double, k: Double) {
    let f = clamp((l - 2.6) / 5.0)
    let e = f * f
    return (lerp(150, -120, e), lerp(14, 70, e), lerp(1, 9, e))
}

func openingInvasion(_ ctx: CGContext, local l: Double, t: Double) {
    // the city, slowly pushing in
    let zoom = 1 + 0.06 * clamp(l / 8)
    ctx.saveGState()
    ctx.translateBy(x: Double(W) / 2, y: Double(H) * 0.7); ctx.scaleBy(x: zoom, y: zoom)
    ctx.translateBy(x: -Double(W) / 2, y: -Double(H) * 0.7)
    blit(newYork(t), ctx)
    ctx.restoreGState()
    // the giant Leviathan, out of the portal and at us
    if l > 2.6 {
        let p = leviathan(l)
        let k = max(1, Int(p.k.rounded()))
        let c = PixelCanvas(60 * k + 40, 30 * k + 40)
        Scenes.battleOfNewYorkLeviathan(c, x: 20, y: 12 + 6 * k, k: k, flip: false)
        c.addOutline(C(0xFFFFFF, 0.92))
        let s = 6 * p.k / Double(k)
        blit(c, ctx, scale: s, dx: p.x * 6 - 20 * s, dy: p.y * 6 - (12 + 6 * Double(k)) * s)
    }
    // Iron Man rockets up from the street to meet it, firing repulsors
    if l > 4.2 {
        let f = easeOut((l - 4.2) / 1.6)
        onStage(ctx, CGRect(x: 0, y: 0, width: W, height: H), scale: 6, ground: Double(fxH) + 10) {
            var im = Actor(cast: .hero(.ironMan), x: lerp(300, 236, f), facing: -1, role: .shoot(offset: 0))
            im.airborne = true
            im.lift = lerp(0, 110, f)
            draw(im, ctx, t: t)
            // repulsor blasts streaking up-left toward the beast
            let c = PixelCanvas(fxW, fxH + 10)
            for i in 0..<10 {
                let born = 4.9 + Double(i) * 0.3, age = l - born
                guard age > 0, age < 0.35 else { continue }
                let from = (im.x - 10, im.top + 30), to = (leviathan(born).x + 120, leviathan(born).y + 20)
                let g = age / 0.35
                let x = lerp(from.0, to.0, g), y = lerp(from.1, to.1, g)
                c.glowLine(x - (to.0 - from.0) * 0.04, y - (to.1 - from.1) * 0.04, x, y,
                           core: C(0xF4FCFF), glow: C(0x6FD8FF), coreR: 0.7, glowR: 2)
            }
            if let img = c.makeImage() { ctx.draw(img, in: CGRect(x: 0, y: Double(H) - Double(c.h) * 6, width: Double(c.w) * 6, height: Double(c.h) * 6)) }
        }
    }
}

/// The heroes' ring: six of them back to back on the street, the camera circling round them.
func openingAssemble(_ ctx: CGContext, local l: Double, t: Double) {
    blit(newYork(t, floorRows: 26), ctx)
    let heroes: [Companion] = [.captainAmerica, .ironMan, .thor, .hulk, .blackWidow, .hawkeye]
    let spin = -l * 0.55
    var ring: [(Actor, Double)] = []
    for (i, h) in heroes.enumerated() {
        let a = spin + Double(i) / Double(heroes.count) * 2 * .pi
        let depth = sin(a)                                   // +1 nearest us, -1 furthest
        var who = Actor(cast: .hero(h), x: 160 + cos(a) * 92, facing: cos(a) >= 0 ? 1 : -1, mode: .idle)
        who.grow = 1.05 + 0.3 * depth
        who.lift = -12 * depth - 14                          // nearer is lower on screen
        ring.append((who, depth))
    }
    for (a, _) in ring.sorted(by: { $0.1 < $1.1 }) { draw(a, ctx, t: t) }
}

// MARK: Shots

struct Shot {
    let name: String; let start: Double; let end: Double
    var cut = false                                   // comes in on a hard cut instead of a wipe
    let render: (CGContext, Double, Double) -> Void
}

let shots: [Shot] = [
    // 0a · A comic caption, typed out on black.
    Shot(name: "meanwhile", start: 0, end: 3.5) { ctx, local, t in
        ctx.setFillColor(CGColor(gray: 0, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let line = "MEANWHILE, IN A TERMINAL NEAR YOU..."
        let n = Int(clamp((local - 0.3) / 1.6) * Double(line.count))
        let a = 1 - clamp((local - 3.0) / 0.4)
        if n > 0 { captionBox(String(line.prefix(n)), ctx, center: CGPoint(x: Double(W) / 2, y: Double(H) / 2), size: 54, alpha: a) }
    },
    // 0b · Comic panels of the cast flip past, then the title slams in on a burst.
    Shot(name: "panels", start: 3.5, end: 7.0, cut: true) { ctx, local, t in
        let cast: [Cast] = [.hero(.ironMan), .villain(.thanos), .hero(.captainAmerica), .villain(.loki), .hero(.thor),
                            .villain(.ultron), .hero(.hulk), .villain(.redSkull), .hero(.spiderMan), .villain(.greenGoblin),
                            .hero(.blackPanther), .villain(.doctorDoom), .hero(.doctorStrange), .villain(.venom), .hero(.groot)]
        let colours: [(CGColor, CGColor)] = [(CGColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 1), CGColor(red: 1, green: 0.4, blue: 0.3, alpha: 1)),
                                             (CGColor(red: 0.15, green: 0.35, blue: 0.85, alpha: 1), CGColor(red: 0.4, green: 0.6, blue: 1, alpha: 1)),
                                             (CGColor(red: 1, green: 0.8, blue: 0.1, alpha: 1), CGColor(red: 1, green: 0.95, blue: 0.5, alpha: 1)),
                                             (CGColor(red: 0.45, green: 0.2, blue: 0.7, alpha: 1), CGColor(red: 0.7, green: 0.45, blue: 0.95, alpha: 1))]
        ctx.setFillColor(CGColor(gray: 0, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let flip = Int(local / 0.11)
        let settle = clamp((local - 1.7) / 0.4)
        // a 3×2 grid of panels, each flipping to another character every beat
        for i in 0..<6 {
            let col = i % 3, row = i / 3
            let r = CGRect(x: 40 + Double(col) * 620, y: 40 + Double(row) * 510, width: 600, height: 490)
            let pick = (flip * 6 + i) % cast.count, tone = colours[(flip + i) % colours.count]
            ctx.saveGState(); ctx.setAlpha(CGFloat(1 - settle * 0.7))
            halftone(ctx, r, base: tone.0, dot: tone.1)
            if let img = portrait(cast[pick], ai: .claude, t: local) {
                let k = (min(r.width * 0.7 / Double(img.width), r.height * 0.75 / Double(img.height))).rounded(.down)
                ctx.interpolationQuality = .none
                ctx.draw(img, in: CGRect(x: r.midX - Double(img.width) * k / 2, y: r.minY + 30, width: Double(img.width) * k, height: Double(img.height) * k))
            }
            ctx.setStrokeColor(CGColor(gray: 0, alpha: 1)); ctx.setLineWidth(10); ctx.stroke(r)
            ctx.restoreGState()
        }
        // the title on its burst
        if local > 1.7 {
            let f = backOut((local - 1.7) / 0.35)
            starburst(ctx, center: CGPoint(x: Double(W) / 2, y: Double(H) / 2), inner: 330 * f, outer: 560 * f, spikes: 16,
                      color: CGColor(red: 1, green: 0.88, blue: 0.29, alpha: 1), spin: local * 0.15)
            starburst(ctx, center: CGPoint(x: Double(W) / 2, y: Double(H) / 2), inner: 250 * f, outer: 420 * f, spikes: 12,
                      color: CGColor(red: 0.93, green: 0.2, blue: 0.16, alpha: 1), spin: -local * 0.2)
            title(ctx, center: CGPoint(x: Double(W) / 2, y: Double(H) / 2 - 20), scale: f * 0.95)
        }
    },
    // 0c · The Battle of New York: the portal, a Leviathan diving at us, Iron Man rocketing up to meet it.
    Shot(name: "invasion", start: 7.0, end: 15.5, cut: true) { ctx, local, t in
        openingInvasion(ctx, local: local, t: t)
    },
    // 0d · The heroes' ring on the street, the camera circling them.
    Shot(name: "assemble", start: 15.5, end: 20.0, cut: true) { ctx, local, t in
        openingAssemble(ctx, local: local, t: t)
    },
    // 1 · The hook: three AIs at work in three terminals, and one overwhelmed human.
    Shot(name: "hook", start: 20.0, end: 24.0) { ctx, local, t in
        let zoom = 1 + 0.03 * local
        ctx.saveGState()
        ctx.translateBy(x: Double(W) / 2, y: Double(H) / 2); ctx.scaleBy(x: zoom, y: zoom)
        ctx.translateBy(x: -Double(W) / 2, y: -Double(H) / 2)
        desktop(ctx, dim: 0)
        ctx.restoreGState()
        caption("Three AIs. Nine agents. One very confused human.", ctx, local: local, start: 0.05, y: 860, size: 60)
        caption("Sound familiar?", ctx, local: local, start: 0.7, y: 120, size: 76, color: yellow)
    },
    // 2 · Desktop mode: they become a Marvel brawl along the bottom of the screen.
    Shot(name: "desktop", start: 24.0, end: 28.6) { ctx, local, t in
        desktop(ctx, dim: easeOut(local / 0.4))
        let drop = { (d: Double) -> Double in max(0, 40 * (1 - easeIn((local - d) / 0.3))) }
        var cap = Actor(cast: .hero(.captainAmerica), x: 56, mode: .working, role: .deflect, label: "idle-claude")
        var skull = Actor(cast: .villain(.redSkull), x: 128, facing: -1, mode: .working, role: .shoot(offset: 0), label: "website", ai: .codex)
        var spidey = Actor(cast: .hero(.spiderMan), x: 196, session: false, role: .shoot(offset: 0), label: "Run the test suite")
        var goblin = Actor(cast: .villain(.greenGoblin), x: 258, facing: -1, session: false, role: .shoot(offset: blasterPeriod / 2),
                           label: "Review Overlay.swift", ai: .codex)
        cap.lift = drop(0); skull.lift = drop(0.12); spidey.lift = drop(0.24); goblin.lift = drop(0.32)
        for a in [cap, skull, spidey, goblin] where a.lift < 40 { draw(a, ctx, t: t) }
        if local > 0.45 { drawFX([(cap, skull), (spidey, goblin)], ctx, t: t) }
        modeBadge("DESKTOP MODE", ctx, local: local)
        caption("Now they're a pixel-art Marvel brawl", ctx, local: local, start: 0.35, y: 900)
        caption("along the bottom of your screen. They fight while they work.", ctx, local: local, start: 0.6, y: 830,
                size: 40, color: yellow, weight: .bold)
    },
    // 3 · Status at a glance: working, thinking, needs you, napping.
    Shot(name: "status", start: 28.6, end: 32.8) { ctx, local, t in
        desktop(ctx, dim: 1)
        let cast: [(Cast, AI, VaderMode, BubbleKind?, String, NSColor, Bool)] = [
            (.hero(.thor), .claude, .working, nil, "WORKING", NSColor(srgbRed: 0.45, green: 0.85, blue: 0.45, alpha: 1), false),
            (.villain(.loki), .qwen, .thinking, .thinking, "THINKING…", NSColor(white: 0.9, alpha: 1), false),
            (.villain(.ultron), .gemini, .waiting, .waiting, "NEEDS YOU!", NSColor(srgbRed: 1, green: 0.4, blue: 0.4, alpha: 1), false),
            (.villain(.thanos), .copilot, .idle, .sleeping, "NAPPING", NSColor(srgbRed: 0.6, green: 0.55, blue: 1, alpha: 1), true),
        ]
        for (i, (who, ai, mode, bubble, word, col, sits)) in cast.enumerated() {
            let d = 0.1 + Double(i) * 0.22
            let f = backOut((local - d) / 0.35)
            guard local > d else { continue }
            var a = Actor(cast: who, x: 48 + Double(i) * 75, mode: mode, bubble: bubble, ai: ai)
            a.sitting = sits
            a.urgent = mode == .waiting
            if a.urgent { a.lift = abs(sin(t * 2 * .pi * 1.6)) * 6 }      // ignored for a minute: it jumps
            a.lift += (1 - f) * -8
            a.alpha = clamp(f)
            draw(a, ctx, t: t)
            let w = NSAttributedString(string: word, attributes: [.font: NSFont.systemFont(ofSize: 40, weight: .black), .kern: 2]).size().width
            text(word, ctx, x: a.x * S - w / 2, y: 70, size: 40, weight: .black, color: col, alpha: clamp(f), kern: 2)
        }
        caption("All fun and games, and you still see everything.", ctx, local: local, start: 0.05, y: 900, size: 58)
        caption("(Thanos sits down when the job's done. Relatable.)", ctx, local: local, start: 0.9, y: 835, size: 36,
                color: yellow, weight: .bold)
    },
    // 4 · Subagents march in, each labelled with its task.
    Shot(name: "agents", start: 32.8, end: 36.8) { ctx, local, t in
        desktop(ctx, dim: 1)
        draw(Actor(cast: .hero(.ironMan), x: 262, facing: -1, mode: .standGuard, label: "idle-claude"), ctx, t: t)
        let crew: [(Companion, String, Double)] = [(.spiderMan, "Find hook events", 190), (.blackWidow, "Write changelog", 140),
                                                   (.groot, "Check git history", 90), (.rocket, "Plan the refactor", 40)]
        for (i, (who, task, stop)) in crew.enumerated() {
            let d = Double(i) * 0.18
            let f = easeOut((local - d) / 0.75)
            let x = lerp(-30, stop, f)
            draw(Actor(cast: .hero(who), x: x, session: false, walking: f < 0.98, label: task), ctx, t: t)
        }
        caption("Every subagent suits up.", ctx, local: local, start: 0.1, y: 900)
        caption("Its job is right there on its label. No more guessing.", ctx, local: local, start: 0.45, y: 835, size: 40,
                color: yellow, weight: .bold)
    },
    // 5 · Window mode: the crew at Avengers Tower, a live card for every session.
    Shot(name: "window", start: 36.8, end: 41.6) { ctx, local, t in
        desktop(ctx, dim: 1, floor: false)
        let f = easeOut(local / 0.6), s = 0.94 + 0.06 * f
        let base = CGRect(x: 300, y: 20, width: 1320, height: 800)
        let r = CGRect(x: base.midX - base.width * s / 2, y: base.minY + 20 * (1 - f), width: base.width * s, height: base.height * s)
        windowMode(ctx, frame: r, local: local, t: t)
        modeBadge("WINDOW MODE", ctx, local: local)
        caption("Prefer a window? Grab some shawarma.", ctx, local: local, start: 0.1, y: 955, size: 56)
        caption("A live card per session: what it's doing, your last prompt, every agent.", ctx, local: local, start: 0.4,
                y: 890, size: 32, color: yellow, weight: .bold)
    },
    // 6 · Every AI it supports, Claude first and biggest, each with its own outline. Claude plays the heroes.
    Shot(name: "ais", start: 41.6, end: 46.0) { ctx, local, t in
        desktop(ctx, dim: 1)
        let lineup: [(Cast, AI, Double, Double, FightRole)] = [
            (.hero(.ironMan), .desktop, 34, 1, .cheer), (.hero(.captainAmerica), .claude, 100, 1, .block),
            (.villain(.thanos), .codex, 172, -1, .zap), (.villain(.loki), .qwen, 220, -1, .cheer),
            (.villain(.ultron), .gemini, 260, -1, .cheer), (.villain(.greenGoblin), .copilot, 298, -1, .cheer),
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
        caption("Claude plays the heroes. Everyone else gets to be the villain.", ctx, local: local, start: 0.7, y: 640, size: 40,
                color: yellow, weight: .bold)
    },
    // 7 · End card: Avengers Tower at night, the Quinjet flies through, the title lands.
    Shot(name: "endcard", start: 46.0, end: 50.2) { ctx, local, t in
        let sky = PixelCanvas(fxW, fxH)
        Location.avengersTower.drawStatic(sky, floorRows: 34)
        Location.avengersTower.drawAnimated(sky, floorRows: 34, t: t)
        blit(sky, ctx)
        ctx.setFillColor(CGColor(gray: 0, alpha: 0.35)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        // the Quinjet streaks across the sky
        let fp = local / 1.2
        if fp > 0 && fp < 1 {
            let qc = PixelCanvas(Ride.width, Ride.height)
            drawRide(qc, .quinjet, ramp: 0, engines: true, gear: false)
            qc.addOutline(C(0xFFFFFF, 0.92))
            if let img = qc.makeImage() {
                let x = lerp(-600, Double(W) + 100, easeIn(fp) * 0.6 + fp * 0.4)
                ctx.saveGState(); ctx.interpolationQuality = .none
                ctx.draw(img, in: CGRect(x: x, y: 600 + 200 * fp, width: Double(Ride.width) * 6, height: Double(Ride.height) * 6))
                ctx.restoreGState()
            }
        }
        // the crew on the street, one of every AI's colours
        let crew: [(Cast, FightRole, AI)] = [(.hero(.ironMan), .cheer, .desktop), (.hero(.captainAmerica), .block, .claude),
                                             (.villain(.thanos), .zap, .codex), (.villain(.greenGoblin), .none, .copilot),
                                             (.villain(.loki), .cheer, .qwen), (.villain(.ultron), .none, .gemini)]
        var placed: [Actor] = []
        for (i, (who, role, ai)) in crew.enumerated() {
            var a = Actor(cast: who, x: [28.0, 84, 156, 206, 252, 296][i], facing: i < 2 ? 1 : -1, role: role, ai: ai)
            a.lift = 8
            a.alpha = clamp((local - 0.15 - Double(i) * 0.05) / 0.2)
            draw(a, ctx, t: t)
            placed.append(a)
        }
        if local > 0.5 { drawFX([(placed[1], placed[2])], ctx, t: t) }
        if local > 0.35 { title(ctx, center: CGPoint(x: Double(W) / 2, y: 760), scale: backOut((local - 0.35) / 0.4) * 0.8) }
        caption("Have fun. Keep track.", ctx, local: local, start: 0.6, y: 520, size: 56)
        caption("Free for macOS", ctx, local: local, start: 0.8, y: 462, size: 34, color: NSColor(white: 0.85, alpha: 1), weight: .bold)
        // the app icon and where to get it, on a dark band along the bottom
        let ff = easeOut((local - 0.9) / 0.3)
        if ff > 0, let icon = appIcon {
            ctx.setFillColor(CGColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 0.8 * ff)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: 170))
            ctx.saveGState(); ctx.setAlpha(CGFloat(ff)); ctx.interpolationQuality = .high
            ctx.draw(icon, in: CGRect(x: 520, y: 20, width: 130, height: 130))
            ctx.restoreGState()
            text("github.com/rodclemen/avengers-clawd-wars", ctx, x: 680, y: 60, size: 44, weight: .bold, alpha: ff)
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
    if let j = shots.indices.dropFirst().first(where: { !shots[$0].cut && abs(t - shots[$0].start) < wipe / 2 }) {
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
    ("MEANWHILE...", "Black screen. A yellow comic caption box types itself out, letter by letter.",
     "“MEANWHILE, IN A TERMINAL NEAR YOU...”", "typewriter clicks"),
    ("THE PANELS", "Hard cut. Six comic panels on halftone colours flip through the cast every beat (Iron Man, Thanos, Cap, Loki, Thor, Ultron...). Then they fade back and the title slams in on a yellow and red burst.",
     "AVENGERS / CLAWD WARS", "page flips, then a big hit"),
    ("THE INVASION", "Hard cut to the app's Battle of New York: the portal above Stark Tower, smoke, Chitauri. A Leviathan noses out of the portal, then swells and dives at us until it fills the frame, while Iron Man rockets up from the street firing repulsors.",
     "no text", "portal hum, Leviathan roar, repulsor blasts, a rumble"),
    ("THE RING", "On the street below, Cap, Iron Man, Thor, Hulk, Black Widow and Hawkeye stand back to back while the camera circles them.",
     "no text", "heroic chord swell"),
    ("THE HOOK", "Three busy terminals (Claude, Codex, Gemini) on a dusky Mac desktop, slow push-in. One thinking, one waiting on a permission prompt, one long done.",
     "“Three AIs. Nine agents. One very confused human.”  →  “Sound familiar?”", "keyboard clicks"),
    ("DESKTOP MODE", "Desktop dims; Claude's Captain America and Codex's Red Skull drop onto the bottom edge: Red Skull fires, Cap's shield knocks every shot aside. Agent Spider-Man trades webs for the Green Goblin's pumpkin bombs.",
     "DESKTOP MODE badge  ·  “Now they're a pixel-art Marvel brawl along the bottom of your screen. They fight while they work.”", "shield clangs, blasts, web thwips"),
    ("AT A GLANCE", "Four sessions pop in, each in its AI's outline: Thor fights, Loki's bubble fills with dots, Ultron's red ! jumps, Thanos sits down and snoozes with zZz.",
     "“All fun and games, and you still see everything.”  ·  “(Thanos sits down when the job's done. Relatable.)”", "one 8-bit blip per pop"),
    ("SUBAGENTS", "Iron Man stands guard. Rocket, Groot, Black Widow and Spider-Man march in one after another, each with its task label.",
     "“Every subagent suits up.”  ·  “Its job is right there on its label. No more guessing.”", "footsteps, a Groot rumble"),
    ("WINDOW MODE", "The app window slides up on Avengers Tower: Cap's shield blocks Red Skull, agents cheer; below, live cards whose timers tick. Then Red Skull stops, jumps with a red ! and his Codex card flips to NEEDS YOU.",
     "WINDOW MODE badge  ·  “Prefer a window? Grab some shawarma.”  ·  “A live card per session...”", "city ambience, notification ping"),
    ("EVERY AI", "Six sessions pop in, one per AI outline. Claude's Cap stands a head taller, holding his shield into Thanos' gauntlet blast; Iron Man (Claude Desktop) and the villains of the other AIs cheer.",
     "CLAUDE CODE (huge)  ·  + Claude Desktop · OpenAI Codex · Qwen Code · Gemini CLI · GitHub Copilot CLI  ·  “Claude plays the heroes. Everyone else gets to be the villain.”", "shield blocking the beam"),
    ("END CARD", "Avengers Tower at night. The Quinjet streaks across; the crew lines up on the street in all six colours; the title lands.",
     "AVENGERS / CLAWD WARS  ·  “Have fun. Keep track.”  ·  Free for macOS  ·  github.com/rodclemen/avengers-clawd-wars", "Quinjet flyby, final sting"),
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
    NSAttributedString(string: "AVENGERS: CLAWD WARS", attributes: [.font: tf, .foregroundColor: yellow, .kern: 5])
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
        put(String(format: "%.1f - %.1f s", s.start, s.end), x + pw - 170, ty + 2, 26, .semibold, dim)
        put(b.action, x, ty - 14, 21, .regular, body, width: pw)
        put("ON SCREEN  " + b.onScreen, x, ty - 100, 20, .semibold, NSColor(srgbRed: 0.75, green: 0.85, blue: 1, alpha: 1), width: pw)
        put("SOUND  " + b.sound, x, ty - 180, 20, .semibold, dim, width: pw)
    }
    NSGraphicsContext.current = nil
    return rep
}

// MARK: Soundtrack (all synthesized here: an original chiptune score and retro sound effects)

let sampleRate = 44100.0
func hashNoise(_ i: Int) -> Double { noise(i) }   // the sprites' noise, reachable from inside Mix

/// A mono mix bus the whole soundtrack is written into.
final class Mix {
    var buf: [Float]
    init(seconds: Double) { buf = [Float](repeating: 0, count: Int(seconds * sampleRate) + 1) }

    enum Wave { case square(Double), saw, triangle, sine }

    /// One note or sweep: `freq` slides to `to`, with an attack/release envelope and optional vibrato.
    func tone(_ start: Double, _ dur: Double, _ freq: Double, to: Double? = nil, wave: Wave = .square(0.5), vol: Double,
              attack: Double = 0.005, release: Double = 0.05, decay: Double = 0, vibrato: Double = 0) {
        guard start < Double(buf.count) / sampleRate, dur > 0 else { return }
        let n = Int(dur * sampleRate), s0 = Int(max(0, start) * sampleRate)
        var phase = 0.0
        for i in 0..<n {
            let idx = s0 + i
            guard idx < buf.count else { break }
            let tt = Double(i) / sampleRate, p = tt / dur
            var f = to.map { freq * pow($0 / freq, p) } ?? freq
            if vibrato > 0 { f *= 1 + vibrato * sin(tt * 2 * .pi * 5.5) }
            phase += f / sampleRate
            let ph = phase - floor(phase)
            let v: Double
            switch wave {
            case .square(let duty): v = ph < duty ? 1 : -1
            case .saw: v = 2 * ph - 1
            case .triangle: v = ph < 0.5 ? 4 * ph - 1 : 3 - 4 * ph
            case .sine: v = sin(2 * .pi * ph)
            }
            var env = min(1, tt / attack) * min(1, (dur - tt) / release)
            if decay > 0 { env *= exp(-tt / decay) }
            buf[idx] += Float(v * env * vol)
        }
    }

    /// Filtered noise: `cutoff` (0…1, one-pole low-pass amount) slides to `cutoffTo`; `highpass` keeps only the hiss.
    func noise(_ start: Double, _ dur: Double, vol: Double, cutoff: Double = 1, cutoffTo: Double? = nil,
               attack: Double = 0.002, release: Double = 0.05, decay: Double = 0, highpass: Bool = false, seed: Int = 1) {
        let n = Int(dur * sampleRate), s0 = Int(max(0, start) * sampleRate)
        var lp = 0.0, rng = UInt64(seed &* 2654435761 &+ 12345)
        for i in 0..<n {
            let idx = s0 + i
            guard idx < buf.count else { break }
            rng = rng &* 6364136223846793005 &+ 1442695040888963407
            let white = Double(Int64(bitPattern: rng >> 11) % 2_000_000) / 1_000_000 - 1
            let tt = Double(i) / sampleRate, p = tt / dur
            let a = cutoffTo.map { cutoff + ($0 - cutoff) * p } ?? cutoff
            lp += (white - lp) * a
            let v = highpass ? white - lp : lp
            var env = min(1, tt / attack) * min(1, max(0, dur - tt) / release)
            if decay > 0 { env *= exp(-tt / decay) }
            buf[idx] += Float(v * env * vol)
        }
    }

    // Sound effects
    func pew(_ t: Double, vol: Double = 0.16) {                       // hand blaster
        tone(t, 0.2, 1900, to: 220, wave: .square(0.5), vol: vol, release: 0.08, decay: 0.09)
        noise(t, 0.05, vol: vol * 0.5, cutoff: 0.6, decay: 0.02)
    }
    func turbolaser(_ t: Double, pitch: Double, vol: Double = 0.1) {
        tone(t, 0.32, 900 * pitch, to: 110 * pitch, wave: .saw, vol: vol, release: 0.1, decay: 0.14)
        noise(t, 0.12, vol: vol * 0.6, cutoff: 0.25, decay: 0.05, seed: Int(t * 100))
    }
    func clash(_ t: Double, vol: Double = 0.2) {                      // sabers meeting
        noise(t, 0.22, vol: vol, cutoff: 0.9, decay: 0.06, highpass: true, seed: Int(t * 77))
        tone(t, 0.18, 1400, to: 500, wave: .square(0.3), vol: vol * 0.35, decay: 0.05)
        tone(t, 0.25, 180, to: 120, wave: .saw, vol: vol * 0.4, decay: 0.1)
    }
    func ignite(_ t: Double, vol: Double = 0.14) {
        tone(t, 0.5, 70, to: 120, wave: .saw, vol: vol, attack: 0.02, release: 0.2)
        noise(t, 0.3, vol: vol * 0.5, cutoff: 0.05, cutoffTo: 0.4, decay: 0.15, seed: 9)
    }
    func hum(_ t: Double, _ dur: Double, vol: Double = 0.035) {        // saber hum while blades are out
        tone(t, dur, 92, wave: .saw, vol: vol, attack: 0.3, release: 0.4, vibrato: 0.01)
        tone(t, dur, 94.5, wave: .saw, vol: vol, attack: 0.3, release: 0.4)
    }
    func boom(_ t: Double, vol: Double = 0.45) {
        tone(t, 1.2, 90, to: 32, wave: .sine, vol: vol, release: 0.4, decay: 0.45)
        noise(t, 0.8, vol: vol * 0.5, cutoff: 0.08, cutoffTo: 0.01, decay: 0.3, seed: Int(t * 13))
    }
    func whoosh(_ center: Double, _ dur: Double, vol: Double = 0.12) {
        noise(center - dur / 2, dur, vol: vol, cutoff: 0.01, cutoffTo: 0.25, attack: dur * 0.5, release: dur * 0.5, seed: Int(center * 31))
    }
    func pop(_ t: Double, step: Int, vol: Double = 0.1) {
        let f = 520 * pow(2, Double(step) * 4 / 12)
        tone(t, 0.09, f, to: f * 1.6, wave: .square(0.25), vol: vol, release: 0.03)
    }
    func ping(_ t: Double, vol: Double = 0.16) {                      // notification
        tone(t, 0.25, 1318.5, wave: .sine, vol: vol, release: 0.2, decay: 0.15)
        tone(t + 0.12, 0.45, 1760, wave: .sine, vol: vol, release: 0.35, decay: 0.2)
    }
    func step(_ t: Double, vol: Double = 0.05) { noise(t, 0.04, vol: vol, cutoff: 0.15, decay: 0.012, seed: Int(t * 997)) }
    func click(_ t: Double, vol: Double = 0.1) {                      // a laptop key
        noise(t, 0.025, vol: vol, cutoff: 0.3, decay: 0.008, highpass: true, seed: Int(t * 541))
        noise(t, 0.03, vol: vol * 0.5, cutoff: 0.15, decay: 0.01, seed: Int(t * 613))
    }
    func r2(_ t: Double, vol: Double = 0.07) {                       // a little droid chirp
        for k in 0..<10 {
            let f = 1100 + hashNoise(Int(t * 10) + k * 3) * 1700
            tone(t + Double(k) * 0.045, 0.05, f, to: f * (hashNoise(k + 4) > 0.5 ? 1.3 : 0.8), wave: .sine, vol: vol, release: 0.01)
        }
    }
    // Drums
    func kick(_ t: Double, vol: Double = 0.3) { tone(t, 0.16, 150, to: 45, wave: .sine, vol: vol, release: 0.05, decay: 0.08) }
    func snare(_ t: Double, vol: Double = 0.12) {
        noise(t, 0.14, vol: vol, cutoff: 0.7, decay: 0.05, seed: Int(t * 61))
        tone(t, 0.08, 220, to: 160, wave: .triangle, vol: vol * 0.5, decay: 0.04)
    }
    func hat(_ t: Double, vol: Double = 0.035) { noise(t, 0.04, vol: vol, cutoff: 0.95, decay: 0.012, highpass: true, seed: Int(t * 173)) }
}

func midi(_ n: Int) -> Double { 440 * pow(2, Double(n - 69) / 12) }

/// Writes 16-bit mono PCM as a WAV file.
func writeWAV(_ samples: [Float], to path: String) {
    var d = Data()
    func u32(_ v: UInt32) { var x = v.littleEndian; d.append(Data(bytes: &x, count: 4)) }
    func u16(_ v: UInt16) { var x = v.littleEndian; d.append(Data(bytes: &x, count: 2)) }
    d.append("RIFF".data(using: .ascii)!); u32(UInt32(36 + samples.count * 2)); d.append("WAVEfmt ".data(using: .ascii)!)
    u32(16); u16(1); u16(1); u32(UInt32(sampleRate)); u32(UInt32(sampleRate) * 2); u16(2); u16(16)
    d.append("data".data(using: .ascii)!); u32(UInt32(samples.count * 2))
    var pcm = [Int16](repeating: 0, count: samples.count)
    for i in samples.indices { pcm[i] = Int16(max(-1, min(1, samples[i])) * 32000) }
    pcm.withUnsafeBufferPointer { d.append(Data(buffer: $0)) }
    try! d.write(to: URL(fileURLWithPath: path))
}

func shotStart(_ name: String) -> Double { shots.first { $0.name == name }!.start }

/// Every time the duelling blades meet (the same clock the sparks use) between `a` and `b`.
func clashTimes(_ a: Double, _ b: Double) -> [Double] {
    var out: [Double] = [], was = false
    var t = a
    while t < b {
        let c = duelPose(t).clash
        if c && !was { out.append(t) }
        was = c; t += 1 / 120
    }
    return out
}

/// When a blaster with `offset` fires between `a` and `b` (a bolt leaves at each whole period).
func shotTimes(_ a: Double, _ b: Double, offset: Double) -> [Double] {
    var out: [Double] = []
    var k = ceil((a + offset) / blasterPeriod)
    while k * blasterPeriod - offset < b { out.append(k * blasterPeriod - offset); k += 1 }
    return out
}

// Marvel sound effects
extension Mix {
    func type(_ t: Double, vol: Double = 0.22) {                     // a typewriter key: the strike, then the thunk
        noise(t, 0.04, vol: vol, cutoff: 0.25, decay: 0.012, highpass: true, seed: Int(t * 733))
        noise(t, 0.06, vol: vol * 0.8, cutoff: 0.12, decay: 0.02, seed: Int(t * 977))
        tone(t, 0.05, 150, to: 90, wave: .triangle, vol: vol * 0.7, decay: 0.018)
    }
    func ding(_ t: Double, vol: Double = 0.12) {                     // the bell at the end of the line
        tone(t, 0.9, 2093, wave: .sine, vol: vol, release: 0.6, decay: 0.35)
        tone(t, 0.6, 4186, wave: .sine, vol: vol * 0.3, release: 0.4, decay: 0.2)
    }
    func flip(_ t: Double, vol: Double = 0.06) {                     // a comic page turning
        noise(t, 0.09, vol: vol, cutoff: 0.05, cutoffTo: 0.5, attack: 0.03, release: 0.04, seed: Int(t * 389))
    }
    func clang(_ t: Double, vol: Double = 0.12) {                    // a shot off Cap's shield
        for (f, d) in [(1250.0, 0.35), (1870.0, 0.25), (2930.0, 0.18)] { tone(t, d, f, wave: .sine, vol: vol / 2, release: 0.1, decay: d / 3) }
        noise(t, 0.03, vol: vol * 0.7, cutoff: 0.9, decay: 0.01, highpass: true, seed: Int(t * 91))
    }
    func repulsor(_ t: Double, vol: Double = 0.1) {                  // Iron Man's palm blast
        tone(t, 0.28, 2400, to: 700, wave: .sine, vol: vol, release: 0.1, decay: 0.12)
        noise(t, 0.2, vol: vol * 0.7, cutoff: 0.5, cutoffTo: 0.05, decay: 0.08, seed: Int(t * 57))
    }
    func thwip(_ t: Double, vol: Double = 0.1) {                     // a web shot
        noise(t, 0.12, vol: vol, cutoff: 0.1, cutoffTo: 0.9, attack: 0.01, release: 0.05, seed: Int(t * 211))
        tone(t, 0.1, 600, to: 1600, wave: .triangle, vol: vol * 0.4, release: 0.04)
    }
    func bomb(_ t: Double, vol: Double = 0.1) {                      // a pumpkin bomb: lobbed, then a pop
        tone(t, 0.18, 400, to: 900, wave: .square(0.3), vol: vol * 0.4, release: 0.05)
        noise(t + 0.36, 0.25, vol: vol, cutoff: 0.3, cutoffTo: 0.03, decay: 0.09, seed: Int(t * 17))
    }
    func roar(_ t: Double, _ dur: Double, vol: Double = 0.2) {       // a Leviathan bellowing
        tone(t, dur, 75, to: 48, wave: .saw, vol: vol, attack: 0.15, release: dur * 0.4, vibrato: 0.06)
        tone(t, dur, 112, to: 70, wave: .saw, vol: vol * 0.6, attack: 0.2, release: dur * 0.4, vibrato: 0.08)
        noise(t, dur, vol: vol * 0.7, cutoff: 0.04, cutoffTo: 0.015, attack: 0.15, release: dur * 0.4, seed: Int(t * 3))
    }
    func crackle(_ t: Double, _ dur: Double, vol: Double = 0.05) {   // a magic beam, Thanos' gauntlet
        tone(t, dur, 160, wave: .saw, vol: vol, attack: 0.1, release: 0.2, vibrato: 0.04)
        noise(t, dur, vol: vol * 0.8, cutoff: 0.6, attack: 0.1, release: 0.2, highpass: true, seed: Int(t * 29))
    }
    func groot(_ t: Double, vol: Double = 0.08) {                    // a low, friendly rumble, three notes
        for (k, n) in [43, 45, 40].enumerated() {
            tone(t + Double(k) * 0.22, 0.24, midi(n), wave: .triangle, vol: vol, attack: 0.03, release: 0.08, vibrato: 0.02)
        }
    }
    func jet(_ t: Double, _ dur: Double, vol: Double = 0.06) {       // the Quinjet going by
        tone(t, dur, 700, to: 1100, wave: .saw, vol: vol * 0.4, attack: dur * 0.4, release: dur * 0.5)
        noise(t, dur, vol: vol * 2, cutoff: 0.02, cutoffTo: 0.3, attack: dur * 0.45, release: dur * 0.5, seed: 77)
    }
}

/// When a ranged fighter with `offset` lets a shot go between `a` and `b`.
func fireTimes(_ a: Double, _ b: Double, offset: Double) -> [Double] { shotTimes(a, b, offset: offset) }

func soundtrack() -> [Float] {
    let m = Mix(seconds: duration)
    let half = wipe / 2

    // ── Opening ────────────────────────────────────────────────────────────────
    // "Meanwhile…": a key for every letter as the caption types itself out.
    let mw = shotStart("meanwhile")
    let line = 35.0
    for i in 0..<35 { m.type(mw + 0.3 + Double(i) / line * 1.6 + noise(i) * 0.02, vol: 0.18 + noise(i + 50) * 0.08) }
    m.ding(mw + 2.0)
    m.tone(mw + 0.2, 3.0, midi(33), wave: .sine, vol: 0.05, attack: 1.0, release: 0.8)          // a low drone

    // The panels: pages flipping, then the title hits with an original fanfare.
    let pn = shotStart("panels")
    for i in 0..<16 { m.flip(pn + Double(i) * 0.11, vol: 0.04 + Double(i) * 0.003) }
    let hit = pn + 1.7
    m.boom(hit, vol: 0.55)
    m.noise(hit, 1.6, vol: 0.12, cutoff: 0.9, decay: 0.5, highpass: true, seed: 3)
    for n in [48, 55, 60, 64, 67] { m.tone(hit, 1.0, midi(n), wave: .saw, vol: 0.05, release: 0.5, decay: 0.6) }
    for (s, d, n) in [(0.25, 0.22, 67), (0.5, 0.22, 72), (0.75, 0.5, 76), (1.3, 0.5, 74)] as [(Double, Double, Int)] {
        m.tone(hit + s, d, midi(n + 12), wave: .square(0.5), vol: 0.07, release: 0.08, vibrato: 0.006)
        m.tone(hit + s, d, midi(n), wave: .saw, vol: 0.045, release: 0.08)
    }

    // The invasion: the portal humming, a dark pulse, the Leviathan's roars, the rumble as it fills the sky,
    // Iron Man's thrusters and repulsors.
    let inv = shotStart("invasion")
    m.tone(inv, 8.5 + half, 110, wave: .sine, vol: 0.05, attack: 1, release: 1.5, vibrato: 0.03)          // the portal
    for i in 0..<Int((8.5 + half) / 0.25) {
        let grow = min(1, Double(i) / 30)
        m.tone(inv + Double(i) * 0.25, 0.22, midi(i % 8 == 7 ? 37 : 36), wave: .square(0.25), vol: 0.04 + 0.06 * grow, release: 0.04)
    }
    for (s, chord) in [(0.0, [48, 51, 55]), (2.0, [44, 48, 51]), (4.0, [46, 50, 53]), (6.0, [48, 51, 55]), (7.0, [43, 47, 50])] {
        for n in chord { m.tone(inv + s, 1.8, midi(n), wave: .saw, vol: 0.035, attack: 0.05, release: 0.6) }
    }
    m.roar(inv + 2.6, 1.6, vol: 0.22)                                                                         // it noses out
    m.roar(inv + 5.6, 2.2, vol: 0.3)                                                                          // and dives
    m.noise(inv + 3.0, 6.5, vol: 0.3, cutoff: 0.004, cutoffTo: 0.03, attack: 3.0, release: 1.5, seed: 5)      // the rumble
    m.tone(inv + 3.0, 6.5, 41, wave: .sine, vol: 0.16, attack: 3.0, release: 1.5)
    m.noise(inv + 4.2, 4.0, vol: 0.1, cutoff: 0.05, cutoffTo: 0.2, attack: 0.6, release: 1.2, seed: 12)       // thrusters
    for i in 0..<10 { let b = inv + 4.9 + Double(i) * 0.3; if b < inv + 8.5 { m.repulsor(b, vol: 0.08) } }

    // The ring: a heroic swell, an original horn line over C F G C.
    let ring = shotStart("assemble")
    for k in 0..<10 { m.tone(ring - 0.5 + Double(k) * 0.05, 0.08, 70, to: 55, wave: .sine, vol: 0.05 + Double(k) * 0.012, decay: 0.05) }
    for (s, d, chord) in [(0.0, 1.1, [48, 52, 55, 60]), (1.1, 1.1, [41, 45, 48, 53]), (2.2, 1.1, [43, 47, 50, 55]), (3.3, 1.6, [48, 52, 55, 60])] {
        for n in chord { m.tone(ring + s, d, midi(n), wave: .saw, vol: 0.035, attack: 0.15, release: 0.4) }
        m.tone(ring + s, d, midi(chord[0] - 12), wave: .sine, vol: 0.16, attack: 0.05, release: 0.4)
    }
    for (s, d, n) in [(0.2, 0.4, 67), (0.6, 0.5, 72), (1.1, 0.9, 74), (2.2, 0.4, 71), (2.6, 0.5, 74), (3.3, 1.4, 79)] as [(Double, Double, Int)] {
        m.tone(ring + s, d, midi(n), wave: .square(0.5), vol: 0.06, attack: 0.02, release: 0.12, vibrato: 0.006)
    }

    // ── The promo: an original chiptune groove, Am F C G ────────────────────────
    let g0 = shotStart("hook"), beat = 0.5, bar = 2.0
    let roots = [45, 41, 48, 43]
    let triads = [[69, 72, 76], [65, 69, 72], [67, 72, 76], [67, 71, 74]]
    let melodyA: [[(Int, Double)]] = [[(76, 1), (81, 1), (84, 0.5), (83, 0.5), (81, 1)], [(84, 1), (81, 1), (77, 0.5), (79, 0.5), (81, 1)],
                                      [(79, 1), (76, 0.5), (79, 0.5), (84, 1), (83, 1)], [(86, 1), (83, 1), (79, 2)]]
    let melodyB: [[(Int, Double)]] = [[(81, 0.5), (84, 0.5), (88, 1), (86, 0.5), (84, 0.5), (83, 1)], [(81, 1.5), (84, 0.5), (81, 1), (77, 1)],
                                      [(79, 0.5), (81, 0.5), (79, 0.5), (76, 0.5), (79, 1), (84, 1)], [(83, 1), (86, 1), (91, 2)]]
    let grooveBars = Int(((shotStart("endcard") - g0) / bar).rounded())
    for b in 0..<grooveBars {
        let t0 = g0 + Double(b) * bar, c = b % 4
        let full = b >= 2
        for e in 0..<8 {
            m.tone(t0 + Double(e) * beat / 2, beat / 2 * 0.9, midi(roots[c] - 12 + (e % 2) * 12), wave: .square(0.25),
                   vol: full ? 0.075 : 0.05, release: 0.02)
            m.hat(t0 + Double(e) * beat / 2, vol: e % 2 == 1 ? 0.04 : 0.025)
        }
        m.kick(t0)
        if full {
            m.kick(t0 + 2 * beat); m.kick(t0 + 2.5 * beat, vol: 0.18)
            m.snare(t0 + beat); m.snare(t0 + 3 * beat)
            for s in 0..<16 {
                m.tone(t0 + Double(s) * beat / 4, beat / 4 * 0.8, midi(triads[c][s % 3] - 12 + (s / 3 % 2) * 12),
                       wave: .triangle, vol: 0.03, release: 0.02)
            }
            let phrase = (b - 2) / 4 % 2 == 0 ? melodyA : melodyB
            var tt = t0
            for (n, d) in phrase[c] {
                m.tone(tt, d * beat * 0.92, midi(n), wave: .square(0.5), vol: 0.055, release: 0.04, vibrato: 0.004)
                tt += d * beat
            }
        }
        if b == grooveBars - 1 {
            for k in 0..<8 { m.snare(t0 + 2 * beat + Double(k) * beat / 4, vol: 0.06 + Double(k) * 0.01) }
        }
    }

    // ── End card: a heroic cadence, F G A ────────────────────────────────────────
    let end = shotStart("endcard")
    for (s, d, chord, lead) in [(0.0, 0.7, [53, 57, 60, 65], 81), (0.7, 0.7, [55, 59, 62, 67], 83), (1.4, 2.8, [57, 61, 64, 69], 85)] {
        for n in chord { m.tone(end + s, d, midi(n), wave: .saw, vol: 0.045, attack: 0.02, release: d > 1 ? 1.6 : 0.1) }
        m.tone(end + s, d, midi(lead), wave: .square(0.5), vol: 0.06, release: d > 1 ? 1.6 : 0.1, vibrato: 0.006)
        m.tone(end + s, d, midi(chord[0] - 24), wave: .sine, vol: 0.2, release: d > 1 ? 1.6 : 0.1)
    }
    m.boom(end + 0.35, vol: 0.45)
    m.noise(end + 1.4, 2.5, vol: 0.08, cutoff: 0.9, decay: 0.8, highpass: true, seed: 8)
    m.jet(end, 1.2, vol: 0.08)                                                               // the Quinjet goes by
    m.crackle(end + 0.5, duration - end - 0.5, vol: 0.025)                                  // Thanos still at it

    // ── Sound effects in the promo ──────────────────────────────────────────────
    for s in shots.dropFirst() where !s.cut { m.whoosh(s.start, wipe, vol: 0.07) }

    let hook = shotStart("hook")
    for i in 0..<26 { m.click(hook + 0.2 + Double(i) * 0.13 + noise(i) * 0.06) }

    let desk = shotStart("desktop")                       // drop-ins; Red Skull shoots, Cap's shield clangs; webs and bombs
    for (i, d) in [0.0, 0.12, 0.24, 0.32].enumerated() { m.step(desk + d + 0.3, vol: 0.1 + Double(i % 2) * 0.03) }
    let deskEnd = shotStart("status") + half
    for t in fireTimes(desk + 0.45, deskEnd, offset: 0) { m.pew(t, vol: 0.1); m.clang(t + boltArrival * blasterPeriod) }
    for t in fireTimes(desk + 0.45, deskEnd, offset: 0) { m.thwip(t + 0.02, vol: 0.07) }
    for t in fireTimes(desk + 0.45, deskEnd, offset: blasterPeriod / 2) { m.bomb(t, vol: 0.08) }

    let status = shotStart("status")
    for i in 0..<4 { m.pop(status + 0.1 + Double(i) * 0.22, step: i) }
    for k in 0..<5 { m.tone(status + 1.2 + Double(k) * 0.62, 0.08, 1568, wave: .square(0.5), vol: 0.035, release: 0.03) }

    let agents = shotStart("agents")
    for k in 0..<14 { m.step(agents + Double(k) * 0.125, vol: 0.06) }
    m.groot(agents + 1.4)

    let win = shotStart("window")                         // the strip: Red Skull firing at Cap, the cards, the ping
    for t in fireTimes(win, win + 2.5, offset: 0) { m.pew(t, vol: 0.05); m.clang(t + boltArrival * blasterPeriod, vol: 0.05) }
    for k in [0.9, 1.8] { m.click(win + k, vol: 0.06) }
    m.ping(win + 2.5)

    let ais = shotStart("ais")                            // six pop in; Thanos' beam on Cap's shield
    for i in 0..<6 { m.pop(ais + 0.15 + Double(i) * 0.1, step: i % 4) }
    m.crackle(ais + 0.4, shotStart("endcard") + half - ais - 0.4, vol: 0.045)

    // Master: gentle saturation, normalise, fade out.
    var peak: Float = 0
    for i in m.buf.indices { m.buf[i] = Float(tanh(Double(m.buf[i]) * 1.2)); peak = max(peak, abs(m.buf[i])) }
    let gain = peak > 0 ? 0.89 / peak : 1
    let fadeFrom = Int((duration - 1.2) * sampleRate)
    for i in m.buf.indices {
        m.buf[i] *= gain
        if i > fadeFrom { m.buf[i] *= Float(max(0, 1 - Double(i - fadeFrom) / (1.2 * sampleRate))) }
    }
    return m.buf
}

/// Puts the soundtrack under the silent video: WAV → AAC with afconvert, then a passthrough export.
func mux(video: String, audio: String, to out: String) {
    let m4a = audio.replacingOccurrences(of: ".wav", with: ".m4a")
    try? FileManager.default.removeItem(atPath: m4a)
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/usr/bin/afconvert")
    p.arguments = ["-f", "m4af", "-d", "aac", "-b", "192000", audio, m4a]
    try! p.run(); p.waitUntilExit()

    let comp = AVMutableComposition()
    let v = AVURLAsset(url: URL(fileURLWithPath: video)), a = AVURLAsset(url: URL(fileURLWithPath: m4a))
    let range = CMTimeRange(start: .zero, duration: CMTime(seconds: duration, preferredTimescale: 600))
    let vt = comp.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
    try! vt.insertTimeRange(range, of: v.tracks(withMediaType: .video)[0], at: .zero)
    let at = comp.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
    let aRange = CMTimeRange(start: .zero, duration: min(range.duration, a.duration))
    try! at.insertTimeRange(aRange, of: a.tracks(withMediaType: .audio)[0], at: .zero)
    try? FileManager.default.removeItem(atPath: out)
    let ex = AVAssetExportSession(asset: comp, presetName: AVAssetExportPresetPassthrough)!
    ex.outputURL = URL(fileURLWithPath: out); ex.outputFileType = .mp4
    let done = DispatchSemaphore(value: 0)
    ex.exportAsynchronously { done.signal() }
    done.wait()
    if ex.status != .completed { print("mux failed: \(String(describing: ex.error))"); exit(1) }
    print("wrote \(out)")
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
    let tmp = NSTemporaryDirectory()
    writeVideo(to: tmp + "clawd-wars-silent.mp4")
    writeWAV(soundtrack(), to: tmp + "clawd-wars.wav")
    mux(video: tmp + "clawd-wars-silent.mp4", audio: tmp + "clawd-wars.wav", to: "\(out)/clawd-wars-promo.mp4")
} else if cmd == "audio" {
    writeWAV(soundtrack(), to: "\(out)/clawd-wars-promo.wav"); print("wrote \(out)/clawd-wars-promo.wav")
} else if cmd == "frames" {
    let n = Int(duration * fps)
    for f in 0..<n { autoreleasepool { save(frame(Double(f) / fps), "\(out)/frame-\(String(format: "%03d", f)).png") } }
    print("wrote \(n) frames to \(out)")
} else if cmd == "frame" {
    let t = Double(args[3]) ?? 0
    save(frame(t), "\(out)/t\(args[3]).png"); print("wrote \(out)/t\(args[3]).png")
} else {
    let keys: [Double] = [2.4, 5.6, 13.0, 18.0, 21.4, 26.3, 30.9, 35.0, 39.6, 44.0, 49.0]
    let frames = keys.map(frame)
    for (i, f) in frames.enumerated() { save(f, "\(out)/key-\(i + 1).png") }
    save(storyboard(frames), "\(out)/storyboard.png")
    print("wrote \(keys.count) key frames and storyboard.png to \(out)")
}

