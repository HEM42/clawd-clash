import AppKit

// The Stranger Clawds trailer: `REEL=hawkins build/renderpromo video promo` → promo/stranger-clawds-promo.mp4. Drawn
// with RenderPromo's kit (Tools/RenderPromo/Kit: `Shot`, `brawl`, `windowShot`, `statusOf`, `agentsOf`, `everyAI`,
// `Mix`…) and compiled only into that tool, never into the app: Tools/universes.sh keeps the folder's Promo/ out of it.
//
// Unlike every other trailer it has no set piece from the show: it opens with the opening titles, slowly, the way the
// show's do (the app's Title trip, slowed right down and stopped before the camera goes through), and goes straight
// into the shared shots. The Upside Down's surprise is never in it.
//   REEL=hawkins build/renderpromo storyboard promo   the storyboard sheet, from `beats`
//   REEL=hawkins build/renderpromo check               every frame once

/// The trailer, as the tool asks for it (`PromoReel`, Tools/RenderPromo/Kit/Reel.swift).
struct HawkinsReel: PromoReel {
    /// Its REEL name (the manifest's `reel`), its video's file name and the GitHub-sized copy's.
    let name = "hawkins", base = "stranger-clawds-promo", small = "Stranger-Clawds"
    var title: String { universe.title.uppercased() }
    /// What Gemini's terminal is busy with on the desktop, in the universe's voice.
    let geminiTask = "gemini ▸ check the walkie-talkie batteries"
    var shots: [Shot] { hawkinsShots }
    var beats: [(key: Double, beat: Beat)] { hawkinsBeats }
    var universe: Universe { .hawkins }
    /// Who's in its desktop brawl, and the caption under the universe's pill (the promo plays this shot too).
    var brawl: BrawlCast {
        BrawlCast(claude: .hero(HawkinsHero.eleven), other: .villain(HawkinsVillain.vecna),
                  agent: .hero(HawkinsHero.steveHarringclawd), otherAgent: .villain(HawkinsVillain.demodog),
                  line: universe.isReleased ? "Or ride out to \(universe.title)." : "Coming soon: \(universe.title).",
                  sub: "Walkie-talkies, Eggos and something in the walls.")
    }
    /// Who's in its window, and what you asked them (the promo plays this shot too).
    var window: WindowCast {
        WindowCast(place: .hawkinsBasement, claude: .hero(HawkinsHero.eleven), other: .villain(HawkinsVillain.vecna),
                   agentA: .hero(HawkinsHero.mikeWheeler), agentB: .hero(HawkinsHero.dustinHenderson), extra: .villain(HawkinsVillain.demodog),
                   prompt: "You: “roll a d20 for the flaky test”", otherPrompt: "You: “open the gate”")
    }
    func sound(_ m: Mix) { hawkinsSound(m) }
    /// Its panel on the promo's comic page: Eleven against Vecna, and the opening titles as the red neon letters lock
    /// into place, with the synth's low drone swelling under them.
    var comic: ComicPanel? {
        ComicPanel(hero: .hero(HawkinsHero.eleven), villain: .villain(HawkinsVillain.vecna), sound: "SKREEE!", pop: (0xE8467A, 0xFF9CBC),
                   word: "BZZZT!", piece: { hawkinsIntro($0, local: 14.0 + $1, t: $2) },
                   hit: { m, at in
                       m.tone(at, 1.2, 55, wave: .saw, vol: 0.06, attack: 0.2, release: 0.4)
                       m.tone(at + 0.1, 1.0, 110, to: 116, wave: .square(0.3), vol: 0.03, attack: 0.3, release: 0.4)
                   })
    }
}

/// The end card's line under "Have fun. Keep track.": never a count of universes.
let hawkinsTagline = "One of many universes in Clawd Clash · free for macOS"

/// A Stranger Clawds character's name, as the app has it.
func hawkinsName(_ h: HawkinsHero) -> String { Cast.hero(h).name }
func hawkinsName(_ v: HawkinsVillain) -> String { Cast.villain(v).name }

// MARK: The opening titles

/// The intro's length, and its beats (shot-local seconds): the letters drift in from `introDrift` to `introLock`,
/// the glow swells to `introHold`, the title holds, and it fades to black from `introFade`.
let hawkinsIntroLength = 19.0
private let introDrift = 0.8, introLock = 14.6, introHold = 16.0, introFade = 17.6
/// Where the Title trip's own frame stands at a moment of the intro: its dark (0–0.12) over the first second, then the
/// letters' slide (0.1–0.6) stretched over the drift, then the swell (0.6–0.7), and it stops there, short of the push
/// through the D (from 0.74).
func hawkinsIntroK(_ l: Double) -> Double {
    if l < introDrift { return 0.1 * l / introDrift }
    if l < introLock { return 0.1 + 0.5 * (l - introDrift) / (introLock - introDrift) }
    return 0.6 + 0.1 * min(1, (l - introLock) / (introHold - introLock))
}

/// What the titles are drawn over: black, made the first time it's needed (a `static let`, since the frame's globals
/// aren't set up yet when this file's globals are).
enum HawkinsStills {
    static let black: CGImage? = shotImage { $0.setFillColor(CGColor(gray: 0, alpha: 1)); $0.fill(fullRect) }
}

/// The opening titles: black, then red neon letters drifting in very slowly from off the edges, out of the dark,
/// close up, the camera pulling back as they glide into place and lock into STRANGER CLAWDS between two bars; the
/// glow swells, the title holds, and it fades to black.
func hawkinsIntro(_ ctx: CGContext, local l: Double, t: Double) {
    guard let black = HawkinsStills.black else { return }
    HawkinsTrip(kind: .title).drawTitle(ctx, old: black, new: black, k: hawkinsIntroK(l), in: fullRect)
    let out = clamp((l - introFade) / (hawkinsIntroLength - 0.3 - introFade))
    if out > 0 { ctx.setFillColor(CGColor(gray: 0, alpha: out)); ctx.fill(fullRect) }
}

// MARK: The shots

/// Every shot, in order, each with its start and end in seconds and how it comes in (the soft wipe unless it says).
let hawkinsShots: [Shot] = [
    // The opening titles, slow, out of the dark and back into it.
    Shot(name: "intro", start: 0, end: hawkinsIntroLength, into: .cut) { ctx, local, t in hawkinsIntro(ctx, local: local, t: t) },
    Shot(name: "hook", start: hawkinsIntroLength, end: hawkinsIntroLength + 4.0, into: .cut) { ctx, local, _ in
        let zoom = 1 + 0.03 * local
        ctx.saveGState()
        ctx.translateBy(x: Double(W) / 2, y: Double(H) / 2); ctx.scaleBy(x: zoom, y: zoom); ctx.translateBy(x: -Double(W) / 2, y: -Double(H) / 2)
        desktop(ctx, dim: 0)
        ctx.restoreGState()
        caption("Three AIs. Nine agents. One very confused babysitter.", ctx, local: local, start: 0.05, y: 860, size: 60)
        caption("Sound familiar?", ctx, local: local, start: 0.7, y: 120, size: 76, color: yellow)
    },
    Shot(name: "desktop", start: 23.0, end: 27.6) { ctx, local, t in
        brawl(ctx, .hawkins, local: local, t: t, drop: true, chrome: false)
        badge("DESKTOP MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Something is living in your build folder.", ctx, local: local, start: 0.35, y: 900)
        caption("A pixel-art \(Universe.hawkins.title) brawl along the bottom of your screen. They fight while they work.", ctx,
                local: local, start: 0.6, y: 830, size: 36, color: yellow, weight: .bold)
    },
    Shot(name: "status", start: 27.6, end: 31.8) { ctx, local, t in
        let cast: [Cast] = [.hero(HawkinsHero.eleven), .hero(HawkinsHero.mikeWheeler), .hero(HawkinsHero.dustinHenderson),
                            .hero(HawkinsHero.chiefHopper)]
        statusOf(ctx, local: local, t: t, cast: cast, badgeText: Universe.hawkins.title.uppercased(),
                 aside: "(\(cast[2].name) needs you: “Do you copy?” \(cast[3].name) says mornings are for coffee.)")
    },
    Shot(name: "agents", start: 31.8, end: 35.8) { ctx, local, t in
        agentsOf(ctx, local: local, t: t, guardCast: .hero(HawkinsHero.steveHarringclawd),
                 crew: [.hero(HawkinsHero.dustinHenderson), .hero(HawkinsHero.lucasSinclawd), .hero(HawkinsHero.maxMayfield),
                        .hero(HawkinsHero.ericaSinclair)],
                 line: "Every subagent gets to join the Party.", badgeText: Universe.hawkins.title.uppercased())
    },
    // In through the app's Walkie Static trip, ending on Joyce's lights spelling the basement's name.
    Shot(name: "window", start: 35.8, end: 40.6,
         into: .trip(ComicTransition(HawkinsTrip(kind: .walkie, from: .hawkinsBasement, to: .hawkinsBasement)))) { ctx, local, t in
        windowShot(ctx, .hawkins, local: local, t: t, rise: true, needsAt: 2.5, at: .hawkinsBasement)
        badge("WINDOW MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Prefer a window? The lights will tell you where.", ctx, local: local, start: 0.1, y: 955, size: 56)
        caption("A live card per session: what it's doing, your last prompt, every agent.", ctx, local: local, start: 0.4, y: 890,
                size: 32, color: yellow, weight: .bold)
    },
    Shot(name: "ais", start: 40.6, end: 45.0) { ctx, local, t in
        everyAI(ctx, local: local, t: t, cast: [.hero(HawkinsHero.eleven), .hero(HawkinsHero.steveHarringclawd), .villain(HawkinsVillain.vecna),
                                                .villain(HawkinsVillain.drBrenner), .villain(HawkinsVillain.billyHargrove),
                                                .villain(HawkinsVillain.democlawdgon), .villain(HawkinsVillain.demodog)])
    },
    // The end card: the basement, the crew lines up, the title lands in red neon, then the app's icon and where to get it.
    Shot(name: "endcard", start: 45.0, end: 49.2) { ctx, local, t in hawkinsEndcard(ctx, local: local, t: t) },
]

/// The end card, its line under "Have fun. Keep track." never a count of universes.
func hawkinsEndcard(_ ctx: CGContext, local: Double, t: Double) {
    blit(place(.hawkinsBasement, floorRows: 34, t: t), ctx)
    ctx.setFillColor(CGColor(gray: 0, alpha: 0.3)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    let crew: [(Cast, FightRole, AI)] = [(.hero(HawkinsHero.mikeWheeler), .cheer, .desktop), (.hero(HawkinsHero.eleven), .zap, .claude),
                                         (.villain(HawkinsVillain.vecna), .zap, .codex)]
    var placed: [Actor] = []
    for (i, (who, role, ai)) in crew.enumerated() {
        var a = Actor(cast: who, x: [60.0, 130, 200][i], facing: i < 2 ? 1 : -1, role: role, ai: ai)
        a.lift = 8
        a.alpha = clamp((local - 0.15 - Double(i) * 0.05) / 0.2)
        draw(a, ctx, t: t)
        placed.append(a)
    }
    if local > 0.5 { drawFX([(placed[1], placed[2])], ctx, t: t) }
    // The title in red neon: a soft red glow behind, the tube's pale core in front.
    let lit = easeOut((local - 0.35) / 0.35)
    if lit > 0 {
        ctx.saveGState()
        ctx.setShadow(offset: .zero, blur: 40, color: CGColor(red: 0.9, green: 0.08, blue: 0.08, alpha: lit))
        caption(Universe.hawkins.title.uppercased(), ctx, local: local, start: 0.35, y: 760, size: 120,
                color: NSColor(srgbRed: 0.85, green: 0.12, blue: 0.1, alpha: 1))
        ctx.restoreGState()
    }
    caption("Have fun. Keep track.", ctx, local: local, start: 0.6, y: 520, size: 56)
    caption(hawkinsTagline, ctx, local: local, start: 0.8, y: 462, size: 34, color: NSColor(white: 0.85, alpha: 1), weight: .bold)
    let ff = easeOut((local - 0.9) / 0.3)
    if ff > 0, let icon = appIcon {
        ctx.setFillColor(CGColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 0.8 * ff)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: 170))
        ctx.saveGState(); ctx.setAlpha(CGFloat(ff)); ctx.interpolationQuality = .high
        ctx.draw(icon, in: CGRect(x: 580, y: 20, width: 130, height: 130))
        ctx.restoreGState()
        text("github.com/rodclemen/clawd-clash", ctx, x: 740, y: 60, size: 44, weight: .bold, alpha: ff)
    }
}

// MARK: The storyboard

/// The storyboard's beats: a time in the reel, and its title, what happens, what's on screen and what's heard.
let hawkinsBeats: [(key: Double, beat: Beat)] = [
    (0.6, ("BLACK", "Black, a faint grain over it.", "no text", "a low synth drone fading in")),
    (4.5, ("THE LETTERS", "Red neon letters drift in out of the dark from off the edges, very slowly, close up and soft, each in its own time.",
           "no text", "the synth pulse: our own notes, a slow arpeggio over the drone")),
    (10.0, ("PULLING BACK", "The camera pulls slowly back as the letters glide together; the bars slide in over the first word and under the last.",
            "no text", "the pulse building, a second voice joining")),
    (15.2, ("THE TITLE", "The letters lock into STRANGER CLAWDS and the red glow swells.", "STRANGER CLAWDS", "a deep swell and a soft boom as they lock")),
    (17.0, ("THE HOLD", "The finished title holds, glowing; then it fades to black.", "STRANGER CLAWDS", "the chord rings out")),
    (21.0, ("THE HOOK", "Three busy terminals, slow push-in.", "“Three AIs. Nine agents. One very confused babysitter.”  →  “Sound familiar?”",
            "keyboard clicks, the groove fading in")),
    (25.3, ("DESKTOP MODE", "\(hawkinsName(HawkinsHero.eleven)) against \(hawkinsName(HawkinsVillain.vecna)); \(hawkinsName(HawkinsHero.steveHarringclawd))'s nail bat against a \(hawkinsName(HawkinsVillain.demodog)).",
            "DESKTOP MODE  ·  “Something is living in your build folder.”", "footsteps, a crackle of power, bat swings")),
    (29.7, ("AT A GLANCE", "\(hawkinsName(HawkinsHero.eleven)) working, \(hawkinsName(HawkinsHero.mikeWheeler)) thinking, \(hawkinsName(HawkinsHero.dustinHenderson)) jumping NEEDS YOU, \(hawkinsName(HawkinsHero.chiefHopper)) sat down napping.",
            "“(Dustin Henderson needs you: “Do you copy?” Chief Hopper says mornings are for coffee.)”", "pops, alert beeps")),
    (33.8, ("SUBAGENTS", "\(hawkinsName(HawkinsHero.steveHarringclawd)) keeps watch; \(hawkinsName(HawkinsHero.dustinHenderson)), \(hawkinsName(HawkinsHero.lucasSinclawd)), \(hawkinsName(HawkinsHero.maxMayfield)) and \(hawkinsName(HawkinsHero.ericaSinclair)) ride in with their jobs on their labels.",
            "“Every subagent gets to join the Party.”", "running feet")),
    (38.2, ("WINDOW MODE", "In through the app's Walkie Static trip, Joyce's lights spelling the place's name; the window in \(Location.hawkinsBasement.name), live cards tick, then a card flips to NEEDS YOU.",
            "WINDOW MODE  ·  “Prefer a window? The lights will tell you where.”", "static, DO YOU COPY?, a ping")),
    (42.8, ("EVERY AI", "Seven sessions, one per AI outline: \(hawkinsName(HawkinsHero.eleven)) (Claude Code, a head taller) and \(hawkinsName(HawkinsHero.steveHarringclawd)) against \(hawkinsName(HawkinsVillain.vecna)), \(hawkinsName(HawkinsVillain.drBrenner)), \(hawkinsName(HawkinsVillain.billyHargrove)) and \(hawkinsName(HawkinsVillain.democlawdgon)); a \(hawkinsName(HawkinsVillain.demodog)) in pi's pink.",
            "BRING YOUR OWN AI*  ·  “One AI plays everyone. Run two and they pick sides.”  ·  *README for the full list", "zaps, pops")),
    (47.6, ("END CARD", "\(Location.hawkinsBasement.name): the crew lines up, STRANGER CLAWDS lands in red neon, then the icon and the URL.",
            "STRANGER CLAWDS  ·  “Have fun. Keep track.”  ·  “\(hawkinsTagline)”  ·  github.com/rodclemen/clawd-clash", "the synth pulse back for a bar, a last chord")),
]

// MARK: The sound

extension Mix {
    /// One synth note in the opening titles' sound: two detuned saws and a soft square, a quick attack and a long tail.
    func hawkinsSynth(_ t: Double, _ dur: Double, _ n: Int, vol: Double) {
        tone(t, dur, midi(n) * 0.996, wave: .saw, vol: vol * 0.5, attack: 0.01, release: 0.25, decay: dur * 0.6)
        tone(t, dur, midi(n) * 1.004, wave: .saw, vol: vol * 0.5, attack: 0.01, release: 0.25, decay: dur * 0.6)
        tone(t, dur, midi(n) / 2, wave: .square(0.3), vol: vol * 0.3, attack: 0.01, release: 0.2, decay: dur * 0.5)
    }
    /// A slow synth pad: each note on detuned saws, swelling in over `attack`.
    func hawkinsPad(_ t: Double, _ dur: Double, _ notes: [Int], vol: Double, attack: Double = 1.2) {
        for n in notes {
            tone(t, dur, midi(n) * 0.997, wave: .saw, vol: vol, attack: attack, release: 1.2, vibrato: 0.002)
            tone(t, dur, midi(n) * 1.003, wave: .saw, vol: vol, attack: attack, release: 1.2, vibrato: 0.002)
        }
    }
}

/// The opening titles' pulse, our own notes: a low D pedal under a slow figure that keeps coming back to the A, in
/// eighths, `vol` scaled by `level(t)`.
private func hawkinsPulse(_ m: Mix, from t0: Double, to t1: Double, level: (Double) -> Double) {
    let figure = [50, 57, 53, 57, 60, 57, 53, 57, 50, 57, 55, 57, 58, 57, 55, 57]
    let step = 0.24
    var i = 0
    var t = t0
    while t < t1 {
        m.hawkinsSynth(t, step * 1.6, figure[i % figure.count], vol: 0.05 * level(t))
        if i % 8 == 0 { m.hawkinsSynth(t, step * 7.5, 38, vol: 0.06 * level(t)) }
        i += 1; t += step
    }
}

/// The score and effects: the opening titles' synth (a drone, the pulse building as the letters come, a swell and a
/// boom as they lock), the shared groove under the app shots, each shot's effects, the trips' own sounds, and the
/// pulse back on the end card under a last chord. Music in the spirit of the show's synths, never its notes.
func hawkinsSound(_ m: Mix) {
    // the opening titles
    m.hawkinsPad(0.2, introFade + 1.0, [38, 45], vol: 0.03, attack: 3.0)
    hawkinsPulse(m, from: 2.0, to: introFade + 0.4) { t in min(1, (t - 2.0) / 6.0) * (t > introFade - 0.5 ? 0.6 : 1) }
    m.hawkinsPad(introLock - 0.4, introFade - introLock + 2.0, [50, 53, 57, 64], vol: 0.02, attack: 1.0)
    m.boom(introLock, vol: 0.4)
    m.noise(introLock - 1.2, 1.4, vol: 0.05, cutoff: 0.3, cutoffTo: 0.9, attack: 1.2, release: 0.1, seed: 9)
    // the app shots: the shared groove, and each shot's effects
    groove(m, from: start("hook"), to: start("endcard"), fadeIn: 1.2)
    let hook = start("hook")
    for i in 0..<26 { m.click(hook + 0.2 + Double(i) * 0.13 + noise(i) * 0.06) }
    let desk = start("desktop"), deskEnd = end("desktop") + 1.3
    for (i, d) in [0.0, 0.12, 0.24, 0.32].enumerated() { m.step(desk + d + 0.3, vol: 0.1 + Double(i % 2) * 0.03) }
    for t in shotTimes(desk + 0.45, deskEnd, offset: 0) { m.whoosh(t, 0.2, vol: 0.05) }
    m.crackle(desk + 0.5, deskEnd - desk - 0.5, vol: 0.02)
    let st = start("status")
    for i in 0..<4 { m.pop(st + 0.1 + Double(i) * 0.22, step: i) }
    for k in 0..<5 { m.tone(st + 1.2 + Double(k) * 0.62, 0.08, 1568, wave: .square(0.5), vol: 0.035, release: 0.03) }
    let ag = start("agents")
    for k in 0..<14 { m.step(ag + Double(k) * 0.125, vol: 0.06) }
    let wi = start("window")
    m.noise(wi - 1.1, 1.4, vol: 0.05, cutoff: 0.8, attack: 0.1, release: 0.3, highpass: true, seed: 41)   // the static
    m.ping(wi + 2.5)
    let ais = start("ais")
    for i in 0..<6 { m.pop(ais + 0.15 + Double(i) * 0.1, step: i % 4) }
    m.crackle(ais + 0.4, end("ais") - ais, vol: 0.02)
    for s in shots { transitionSound(m, s) }
    // the end card: the pulse for a bar, then a last chord
    let ec = start("endcard")
    hawkinsPulse(m, from: ec, to: ec + 1.9) { _ in 0.8 }
    m.boom(ec + 0.35, vol: 0.35)
    m.hawkinsPad(ec + 1.9, 2.4, [38, 50, 57, 62, 65], vol: 0.025, attack: 0.15)
}
