import AppKit
import CoreText

// The Clawd Files trailer: `REEL=files build/renderpromo video promo` → promo/the-clawd-files-promo.mp4.
// Drawn with RenderPromo's kit (Tools/RenderPromo/Kit: `Shot`, `brawl`, `windowShot`, `everyAI`, `Mix`…) and compiled
// only into that tool.

/// The Clawd Files trailer, as the tool asks for it.
struct FilesReel: PromoReel {
    let name = "files", base = "the-clawd-files-promo", small = "The-Clawd-Files"
    let title = "THE CLAWD FILES"
    let geminiTask = "gemini ▸ declassify the logs"
    var shots: [Shot] { filesShots }
    var beats: [(key: Double, beat: Beat)] { filesBeats }
    func sound(_ m: Mix) { filesSound(m) }
}

// MARK: The Clawd Files trailer

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
