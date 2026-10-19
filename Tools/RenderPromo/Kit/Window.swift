import AppKit

// The app's "Show in Window" window, in any universe, and the shot that puts it over the desktop.
// Part of RenderPromo's kit: declarations only. main.swift picks the reel and runs it; its header has the build
// command.

// MARK: Window mode

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


// MARK: Window mode, in any universe

/// What one window shows: its place, the crew in the scene strip, and the cards below.
struct WindowSpec {
    let place: Location
    let crew: (_ local: Double, _ t: Double) -> (actors: [Actor], fights: [(Actor, Actor)])
    let cards: (_ local: Double) -> [(group: AI?, card: Card)]
}

/// The "Show in Window" window: themed title bar, the place with the crew in it, a card per session.
func windowMode(_ ctx: CGContext, frame r: CGRect, local: Double, t: Double, spec: WindowSpec) {
    let loc = spec.place
    let panel = loc.panel
    let z = 2.0, cz = 1.3                         // app points → screen pixels (window chrome, cards)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -20), blur: 60, color: CGColor(gray: 0, alpha: 0.6))
    let outline = CGPath(roundedRect: r, cornerWidth: 22, cornerHeight: 22, transform: nil)
    ctx.addPath(outline); ctx.setFillColor((panel.blended(withFraction: 0.45, of: .black) ?? panel).cgColor); ctx.fillPath()
    ctx.restoreGState()
    ctx.saveGState()
    ctx.addPath(outline); ctx.clip()
    let barH = 30 * z
    trafficLights(ctx, x: r.minX + 20, y: r.maxY - barH / 2 - 7, d: 15)
    let where_ = NSAttributedString(string: loc.name.uppercased(), attributes: [
        .font: NSFont.systemFont(ofSize: 10.5 * z, weight: .semibold), .foregroundColor: NSColor(white: 0.78, alpha: 1), .kern: 1.2 * z])
    where_.draw(at: NSPoint(x: r.maxX - where_.size().width - 28, y: r.maxY - barH / 2 - where_.size().height / 2))
    // the scene strip: the place at 2 px per pixel in the app, so 4 here
    let px = Double(Scenes.pixel) * z
    let stripH = 150.0 * z                        // the app's strip: 75 rows of art at 2 pt a row
    let strip = CGRect(x: r.minX, y: r.maxY - barH - stripH, width: r.width, height: stripH)
    let cw = Int((strip.width / px).rounded(.up)), ch = Int(stripH / px)
    let floorRows = Int(20 / Double(Scenes.pixel))
    let room = PixelCanvas(cw, ch); loc.drawStatic(room, floorRows: floorRows)
    let live = PixelCanvas(cw, ch); loc.drawAnimated(live, floorRows: floorRows, t: t)
    ctx.saveGState(); ctx.interpolationQuality = .none
    for c in [room, live] { if let img = c.makeImage() { ctx.draw(img, in: CGRect(x: strip.minX, y: strip.minY, width: Double(cw) * px, height: Double(ch) * px)) } }
    ctx.restoreGState()
    onStage(ctx, strip, scale: px, ground: Double(ch) - Double(floorRows) * 0.45) {
        let crew = spec.crew(local, t)
        for a in crew.actors { draw(a, ctx, t: t) }
        drawFX(crew.fights, ctx, t: t)
    }
    // the cards, grouped by AI
    var top = strip.minY - 10 * cz
    let x = r.minX + 10 * cz, w = r.width - 20 * cz
    for (group, card) in spec.cards(local) {
        if let g = group {
            let label = NSAttributedString(string: g.name.uppercased(), attributes: [.font: NSFont.systemFont(ofSize: 10.5 * cz, weight: .heavy),
                                                                                      .kern: 1.2 * cz, .foregroundColor: g.ns])
            let gs = label.size()
            label.draw(at: NSPoint(x: x + 2 * cz, y: top - gs.height - 2 * cz))
            ctx.setFillColor(g.ns.withAlphaComponent(0.35).cgColor)
            ctx.fill(CGRect(x: x + gs.width + 10 * cz, y: top - gs.height / 2 - 2 * cz, width: w - gs.width - 12 * cz, height: cz))
            top -= 22 * cz
        }
        top -= drawCard(card, ctx, x: x, top: top, width: w, panel: panel, z: cz) + 10 * cz
    }
    ctx.restoreGState()
}

let green = NSColor(srgbRed: 0.45, green: 0.85, blue: 0.45, alpha: 1), red = NSColor(srgbRed: 1, green: 0.42, blue: 0.42, alpha: 1)

/// A window in `u`: a Claude session fighting another AI's, two Claude agents cheering, and its cards. After `needsAt`
/// the other AI's session stops and asks for you.
func windowSpec(_ u: Universe, needsAt: Double = 99, at override: Location? = nil) -> WindowSpec {
    let w = promoReel(u).window
    let (place, claude, other, agentA, agentB, extra, prompt, otherPrompt) =
        (w.place, w.claude, w.other, w.agentA, w.agentB, w.extra, w.prompt, w.otherPrompt)
    let duel = fightIsCloseQuarters(claude.weapon, other.weapon)
    return WindowSpec(place: override ?? place, crew: { local, t in
        let needs = local > needsAt
        let roles = fightRoles(claude.weapon, other.weapon)
        var c = Actor(cast: claude, x: 140, role: needs ? .none : roles.0)
        var o = Actor(cast: other, x: duel ? 197 : 214, facing: -1, role: roles.1, ai: .codex)
        if needs { o.role = .none; o.mode = .waiting; o.bubble = .waiting; o.urgent = true; o.lift = abs(sin(t * 2 * .pi * 1.6)) * 4; c.mode = .working }
        let a = Actor(cast: agentA, x: 72, session: false, role: .cheer, label: "Run the tests")
        let b = Actor(cast: agentB, x: 30, session: false, role: .cheer, label: "Check git history")
        let e = Actor(cast: extra, x: 290, facing: -1, session: false, ai: .codex)
        return ([b, a, c, o, e], needs ? [] : [(c, o)])
    }, cards: { local in
        let ticks = max(0, Int(local))
        let now = ["Now: Read Overlay.swift", "Now: Edit WindowMode.swift", "Now: Bash: swift build"][min(2, max(0, Int(local / 0.9)))]
        let needs = local > needsAt
        return [(nil, Card(who: claude, ai: .claude, name: claude.name, project: "idle-claude", status: "WORKING · \(24 + ticks)s",
                           statusColor: green, lines: [("claude-opus-5-5", dimText), (now, bodyText), (prompt, bodyText)],
                           agents: [(agentA, agentA.name, "Run the tests", "Bash: swift test · \(34 + ticks)s · 9 tool calls"),
                                    (agentB, agentB.name, "Check git history", "Bash: git log · 1m \(21 + ticks)s · 25 tool calls")])),
                (.codex, Card(who: other, ai: .codex, name: other.name, project: "website",
                              status: needs ? "NEEDS YOU · \(max(1, Int(local - needsAt) + 1))s" : "THINKING",
                              statusColor: needs ? red : NSColor(white: 0.85, alpha: 1),
                              lines: [("gpt-5-codex", dimText), (needs ? "Wants to run: npm run deploy" : "Now: Thinking…", bodyText),
                                      (otherPrompt, bodyText)]))]
    })
}

/// The window, where every promo shot puts it.
let windowRect = CGRect(x: 300, y: 20, width: 1320, height: 800)

/// The app window over a dimmed desktop.
func windowShot(_ ctx: CGContext, _ u: Universe, local: Double, t: Double, rise: Bool, needsAt: Double = 99, at place: Location? = nil) {
    desktop(ctx, dim: 1, floor: false)
    let f = rise ? easeOut(local / 0.6) : 1, s = 0.94 + 0.06 * f
    let b = windowRect
    let r = CGRect(x: b.midX - b.width * s / 2, y: b.minY + 20 * (1 - f), width: b.width * s, height: b.height * s)
    windowMode(ctx, frame: r, local: local, t: t, spec: windowSpec(u, needsAt: needsAt, at: place))
}
