import AppKit

// Shots and how they come in, and the shared shots every trailer has: the brawl, every AI, the status line-up and the subagents.
// Part of RenderPromo's kit: declarations only. main.swift picks the reel and runs it; its header has the build
// command.

// MARK: Shots and their transitions

/// How a shot comes in: a hard cut, the soft promo wipe, or one of the app's own universe transitions (over the whole
/// frame, or inside the window, `inWindow`).
enum Into {
    case cut
    case wipe
    case starWars(clock: Bool)
    case marvel(MarvelousComicTrip)
    case dc(DetectiveComicTrip)
    case middleEarth(RingsTrip)
    case trip(ComicTransition)    // any other universe's own trips (Doctor Clawd, The Clawd Files, Stevie Clawdberg)

    var duration: Double {
        switch self {
        case .cut: return 0
        case .wipe: return softWipe
        case .starWars: return Wipe.duration * 1.6
        case .marvel(let t): return t.duration * 1.25
        case .dc(let t): return t.duration * 1.25
        case .middleEarth(let t): return t.duration * 1.25
        case .trip(let t): return t.duration * 1.25
        }
    }
}

struct Shot {
    let name: String; var start: Double; var end: Double
    var into: Into = .wipe
    var inWindow = false
    let render: (CGContext, Double, Double) -> Void

    func shifted(_ by: Double) -> Shot { var s = self; s.start += by; s.end += by; return s }
}

/// Something drawn over the cut, unaffected by transitions (a caption that runs across several shots).
struct Overlay { let start: Double; let end: Double; let draw: (CGContext, Double) -> Void }

// MARK: The shared shots

/// The desktop brawl in one universe: Claude's session against another AI's, and two agents trading shots.
func brawl(_ ctx: CGContext, _ u: Universe, local: Double, t: Double, drop: Bool, chrome: Bool = true) {
    desktop(ctx, dim: drop ? easeOut(local / 0.4) : 1)
    let fall = { (d: Double) -> Double in drop ? max(0, 40 * (1 - easeIn((local - d) / 0.3))) : 0 }
    let cast = promoReel(u).brawl
    let (a, b, c, d) = (cast.claude, cast.other, cast.agent, cast.otherAgent)
    let (ra, rb) = fightRoles(a.weapon, b.weapon), close = fightIsCloseQuarters(a.weapon, b.weapon)
    var s1 = Actor(cast: a, x: 58, role: ra, label: "idle-claude")
    var s2 = Actor(cast: b, x: close ? 115 : 130, facing: -1, role: rb, label: "website", ai: .codex)
    let (rc, rd) = fightRoles(c.weapon, d.weapon)
    var g1 = Actor(cast: c, x: 196, session: false, role: rc, label: "Run the test suite")
    var g2 = Actor(cast: d, x: 258, facing: -1, session: false, role: rd, label: "Review Overlay.swift", ai: .codex)
    if case .shoot = rd, case .shoot = rc { g2.role = .shoot(offset: blasterPeriod / 2) }
    s1.lift = fall(0); s2.lift = fall(0.12); g1.lift = fall(0.24); g2.lift = fall(0.32)
    for x in [s1, s2, g1, g2] where x.lift < 40 { draw(x, ctx, t: t) }
    if !drop || local > 0.45 { drawFX([(s1, s2), (g1, g2)], ctx, t: t) }
    guard chrome else { return }
    badge(u.title.uppercased(), ctx, alpha: 1)
    // each universe its own caption
    let (line, sub) = (cast.line, cast.sub)
    caption(line, ctx, local: local, start: drop ? 0.3 : 0.15, y: 900)
    caption(sub, ctx, local: local, start: drop ? 0.6 : 0.4, y: 830, size: 40, color: yellow, weight: .bold)
}

/// Every AI it supports in one line-up, each session in its AI's outline, Claude's character a head taller, duelling
/// Codex's: BRING YOUR OWN AI, every session gets a character, and with more than one AI they pick sides. A footnote
/// sends you to the README for the full list, so the shot needn't change when another AI or harness is supported.
/// `cast` is one character per AI in `AI.lineUp` order, and a seventh (pi, labelled with the model it runs) if given.
func everyAI(_ ctx: CGContext, local: Double, t: Double, cast: [Cast]) {
    desktop(ctx, dim: 1)
    let withPi = cast.count > AI.lineUp.count
    let ais: [AI] = withPi ? AI.lineUp + [.pi] : AI.lineUp
    // Where each stands: Claude Desktop far left, then Claude Code, Codex, Qwen, Gemini, Copilot (and pi).
    let xs: [Double] = withPi ? [86, 26, 144, 186, 224, 262, 300] : [104, 36, 165, 216, 258, 298]
    var actors: [Actor] = []
    let (ra, rb) = fightRoles(cast[0].weapon, cast[2].weapon)
    for (i, ai) in ais.enumerated() {
        let d = 0.15 + Double(i) * 0.1
        guard local > d else { continue }
        let f = backOut((local - d) / 0.3)
        let label = ai == .pi ? "PI · MISTRAL" : ai.tag
        // Claude Code faces Codex; everyone else faces left.
        var a = Actor(cast: cast[i], x: xs[i], facing: i == 0 ? 1 : -1, role: i == 0 ? ra : (i == 2 ? rb : .cheer), label: label, ai: ai)
        if ai == .claude { a.grow = 1.25; a.labelSize = 36 } else { a.labelSize = ai == .pi ? 18 : 22 }
        a.lift = (1 - f) * -10; a.alpha = clamp(f)
        actors.append(a)
        draw(a, ctx, t: t)
    }
    if let c = actors.first(where: { $0.ai == .claude }), let x = actors.first(where: { $0.ai == .codex }) { drawFX([(c, x)], ctx, t: t) }
    let fc = easeOut((local - 0.05) / 0.35)
    if fc > 0 {
        let tf = NSFont(name: "Futura-CondensedExtraBold", size: 130) ?? .systemFont(ofSize: 120, weight: .black)
        text("BRING YOUR OWN AI*", ctx, y: 800 - 30 * (1 - fc), size: 130, alpha: fc, font: tf, kern: 6)
    }
    caption("Every session gets a character, whatever runs it.", ctx, local: local, start: 0.35, y: 730, size: 44, color: bodyText)
    caption("One AI plays everyone. Run two and they pick sides.", ctx, local: local, start: 0.7, y: 655, size: 40, color: yellow, weight: .bold)
    caption("*Every supported AI and harness, and how to connect it, is in the README.", ctx, local: local, start: 1.0, y: 40,
            size: 26, color: dimText, weight: .semibold)
}

/// A line-up of four sessions, one per state, with the state named under each.
func statusOf(_ ctx: CGContext, local: Double, t: Double, cast: [Cast], badgeText: String, aside: String) {
    desktop(ctx, dim: 1)
    let states: [(AI, VaderMode, BubbleKind?, String, NSColor, Bool)] = [
        (.claude, .working, nil, "WORKING", green, false), (.qwen, .thinking, .thinking, "THINKING…", NSColor(white: 0.9, alpha: 1), false),
        (.gemini, .waiting, .waiting, "NEEDS YOU!", red, false), (.copilot, .idle, .sleeping, "NAPPING", NSColor(srgbRed: 0.6, green: 0.55, blue: 1, alpha: 1), true),
    ]
    for (i, (ai, mode, bubble, word, col, sits)) in states.enumerated() {
        let d = 0.1 + Double(i) * 0.22
        guard local > d else { continue }
        let f = backOut((local - d) / 0.35)
        var a = Actor(cast: cast[i], x: 48 + Double(i) * 75, mode: mode, bubble: bubble, ai: ai)
        a.sitting = sits && cast[i].persona.canSit
        a.urgent = mode == .waiting
        if a.urgent { a.lift = abs(sin(t * 2 * .pi * 1.6)) * 6 }
        a.lift += (1 - f) * -8
        a.alpha = clamp(f)
        draw(a, ctx, t: t)
        let w = NSAttributedString(string: word, attributes: [.font: NSFont.systemFont(ofSize: 40, weight: .black), .kern: 2]).size().width
        text(word, ctx, x: a.x * S - w / 2, y: 70, size: 40, weight: .black, color: col, alpha: clamp(f), kern: 2)
    }
    badge(badgeText, ctx, alpha: 1)
    caption("All fun and games, and you still see everything.", ctx, local: local, start: 0.05, y: 900, size: 58)
    caption(aside, ctx, local: local, start: 0.9, y: 835, size: 36, color: yellow, weight: .bold)
}

/// Subagents walking in with their jobs on their labels, while their session stands guard.
func agentsOf(_ ctx: CGContext, local: Double, t: Double, guardCast: Cast, crew: [Cast], line: String, badgeText: String) {
    desktop(ctx, dim: 1)
    draw(Actor(cast: guardCast, x: 262, facing: -1, mode: .standGuard, label: "idle-claude"), ctx, t: t)
    let jobs = ["Find hook events", "Write changelog", "Check git history", "Plan the refactor"], stops: [Double] = [190, 140, 90, 40]
    for (i, who) in crew.enumerated() {
        let f = easeOut((local - Double(i) * 0.18) / 0.75)
        draw(Actor(cast: who, x: lerp(-30, stops[i], f), session: false, walking: f < 0.98, label: jobs[i]), ctx, t: t)
    }
    badge(badgeText, ctx, alpha: 1)
    caption(line, ctx, local: local, start: 0.1, y: 900)
    caption("Its job is right there on its label. No more guessing.", ctx, local: local, start: 0.45, y: 835, size: 40, color: yellow, weight: .bold)
}
