import AppKit
import CoreText

// The Marvelous Clawds trailer: `REEL=marvelous build/renderpromo video promo` → promo/marvelous-clawds-promo.mp4.
// Drawn with RenderPromo's kit (Tools/RenderPromo/Kit: `Shot`, `brawl`, `windowShot`, `everyAI`, `Mix`…) and compiled
// only into that tool.

/// The Marvelous Clawds trailer, as the tool asks for it.
struct MarvelousReel: PromoReel {
    let name = "marvelous", base = "marvelous-clawds-promo", small = "Marvelous-Clawds"
    let title = "MARVELOUS CLAWDS"
    let geminiTask = "gemini ▸ polish the shield"
    var shots: [Shot] { marvelousShots }
    var beats: [(key: Double, beat: Beat)] { marvelousBeats }
    func sound(_ m: Mix) { marvelousSound(m) }
}

// MARK: The Marvelous Clawds showcase (in its trailer, and on the promo's comic page)

/// The Battle of New York backdrop from the app, at frame size: the portal over Stark Tower, smoke, the Leviathans.
func newYork(_ t: Double, floorRows: Int = 14) -> PixelCanvas {
    let c = PixelCanvas(fxW, fxH)
    Location("battleOfNewYork").drawStatic(c, floorRows: floorRows)
    Location("battleOfNewYork").drawAnimated(c, floorRows: floorRows, t: t)
    return c
}

/// Where the giant Leviathan's tail is (fx units) and how big it is, at shot-local time `l`: it noses out of the
/// portal small, then swells and dives toward us until it fills the frame.
func leviathan(_ l: Double) -> (x: Double, y: Double, k: Double) {
    let f = clamp((l - 2.6) / 5.0)
    let e = f * f
    return (lerp(150, -120, e), lerp(14, 70, e), lerp(1, 9, e))
}

func clawvelShowcase(_ ctx: CGContext, local l: Double, t: Double) {
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
        // its body arches about 16 units above and below its line, so leave that much room on both sides
        let c = PixelCanvas(60 * k + 40, 32 * k + 38)
        Scenes.battleOfNewYorkLeviathan(c, x: 20, y: 18 + 16 * k, k: k, flip: false)
        c.addOutline(C(0xFFFFFF, 0.92))
        let s = 6 * p.k / Double(k)
        blit(c, ctx, scale: s, dx: p.x * 6 - 20 * s, dy: p.y * 6 - (Double(c.h) - 18 - 16 * Double(k)) * s)
    }
    // Iron Man rockets up from the street to meet it, firing repulsors
    if l > 4.2 {
        let f = easeOut((l - 4.2) / 1.6)
        onStage(ctx, CGRect(x: 0, y: 0, width: W, height: H), scale: 6, ground: Double(fxH) + 10) {
            var im = Actor(cast: .hero(MarvelHero.ironMan), x: lerp(300, 236, f), facing: -1, role: .shoot(offset: 0))
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

// MARK: The Marvelous Clawds trailer (the old Avengers trailer, rebuilt on Clawd Clash)

/// MARVELOUS over CLAWDS: comic lettering with a heavy round black outline.
func marvelousTitle(_ ctx: CGContext, center: CGPoint, scale s: Double, alpha: Double = 1) {
    let tf = NSFont(name: "Futura-CondensedExtraBold", size: 200) ?? .systemFont(ofSize: 190, weight: .black)
    ctx.saveGState()
    ctx.translateBy(x: center.x, y: center.y); ctx.scaleBy(x: s, y: s)
    for (i, (word, col, size)) in [("MARVELOUS", NSColor(srgbRed: 0.93, green: 0.16, blue: 0.16, alpha: alpha), 0.62),
                                   ("CLAWDS", yellow.withAlphaComponent(alpha), 1.0)].enumerated() {
        let f = NSFont(descriptor: tf.fontDescriptor, size: 200 * size) ?? tf
        let base: [NSAttributedString.Key: Any] = [.font: f, .kern: 10 * size]
        var outlined = base; outlined[.foregroundColor] = NSColor.black.withAlphaComponent(alpha)
        var filled = base; filled[.foregroundColor] = col
        let sz = NSAttributedString(string: word, attributes: base).size()
        let p = NSPoint(x: -sz.width / 2, y: i == 0 ? 40 : -sz.height + 40)
        let ink = NSAttributedString(string: word, attributes: outlined), r = 12 * size
        for k in 0..<16 { let a = Double(k) / 16 * 2 * .pi; ink.draw(at: NSPoint(x: p.x + cos(a) * r, y: p.y + sin(a) * r)) }
        NSAttributedString(string: word, attributes: filled).draw(at: p)
    }
    ctx.restoreGState()
}

/// The heroes' ring: six of them back to back on the street of the Battle of New York, the camera circling round them.
func heroesRing(_ ctx: CGContext, local l: Double, t: Double) {
    blit(newYork(t, floorRows: 26), ctx)
    let heroes: [MarvelHero] = [.captainAmerica, .ironMan, .thor, .hulk, .blackWidow, .hawkeye]
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

let marvelousShots: [Shot] = [
    Shot(name: "meanwhile", start: 0, end: 3.5, into: .cut) { ctx, local, t in
        ctx.setFillColor(CGColor(gray: 0, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let line = "MEANWHILE, IN A TERMINAL NEAR YOU..."
        let n = Int(clamp((local - 0.3) / 1.6) * Double(line.count))
        let a = 1 - clamp((local - 3.0) / 0.4)
        if n > 0 { captionBox(String(line.prefix(n)), ctx, center: CGPoint(x: Double(W) / 2, y: Double(H) / 2), size: 54, alpha: a) }
    },
    // Comic panels of the cast flip past, then MARVELOUS CLAWDS slams in on a burst.
    Shot(name: "panels", start: 3.5, end: 7.0, into: .cut) { ctx, local, t in
        let cast: [Cast] = [.hero(MarvelHero.ironMan), .villain(MarvelVillain.thanos), .hero(MarvelHero.captainAmerica), .villain(MarvelVillain.loki),
                            .hero(MarvelHero.thor), .villain(MarvelVillain.ultron), .hero(MarvelHero.hulk), .villain(MarvelVillain.redSkull),
                            .hero(MarvelHero.spiderMan), .villain(MarvelVillain.greenGoblin), .hero(MarvelHero.blackPanther),
                            .villain(MarvelVillain.doctorDoom), .hero(MarvelHero.doctorStrange), .villain(MarvelVillain.venom), .hero(MarvelHero.groot)]
        let colours: [(CGColor, CGColor)] = [(CGColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 1), CGColor(red: 1, green: 0.4, blue: 0.3, alpha: 1)),
                                             (CGColor(red: 0.15, green: 0.35, blue: 0.85, alpha: 1), CGColor(red: 0.4, green: 0.6, blue: 1, alpha: 1)),
                                             (CGColor(red: 1, green: 0.8, blue: 0.1, alpha: 1), CGColor(red: 1, green: 0.95, blue: 0.5, alpha: 1)),
                                             (CGColor(red: 0.45, green: 0.2, blue: 0.7, alpha: 1), CGColor(red: 0.7, green: 0.45, blue: 0.95, alpha: 1))]
        ctx.setFillColor(CGColor(gray: 0, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let flip = Int(local / 0.11), settle = clamp((local - 1.7) / 0.4)
        for i in 0..<6 {
            let r = CGRect(x: 40 + Double(i % 3) * 620, y: 40 + Double(i / 3) * 510, width: 600, height: 490)
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
        if local > 1.7 {
            let f = backOut((local - 1.7) / 0.35)
            starburst(ctx, center: CGPoint(x: Double(W) / 2, y: Double(H) / 2), inner: 330 * f, outer: 560 * f, spikes: 16,
                      color: CGColor(red: 1, green: 0.88, blue: 0.29, alpha: 1), spin: local * 0.15)
            starburst(ctx, center: CGPoint(x: Double(W) / 2, y: Double(H) / 2), inner: 250 * f, outer: 420 * f, spikes: 12,
                      color: CGColor(red: 0.93, green: 0.2, blue: 0.16, alpha: 1), spin: -local * 0.2)
            marvelousTitle(ctx, center: CGPoint(x: Double(W) / 2, y: Double(H) / 2 - 20), scale: f * 0.95)
        }
    },
    // The Battle of New York: the portal, the space whale diving at us, Iron Clawd rocketing up to meet it.
    Shot(name: "invasion", start: 7.0, end: 15.5, into: .cut) { ctx, local, t in clawvelShowcase(ctx, local: local, t: t) },
    Shot(name: "ring", start: 15.5, end: 20.0, into: .cut) { ctx, local, t in heroesRing(ctx, local: local, t: t) },
    Shot(name: "hook", start: 20.0, end: 24.0) { ctx, local, t in
        let zoom = 1 + 0.03 * local
        ctx.saveGState()
        ctx.translateBy(x: Double(W) / 2, y: Double(H) / 2); ctx.scaleBy(x: zoom, y: zoom); ctx.translateBy(x: -Double(W) / 2, y: -Double(H) / 2)
        desktop(ctx, dim: 0)
        ctx.restoreGState()
        caption("Three AIs. Nine agents. One very confused human.", ctx, local: local, start: 0.05, y: 860, size: 60)
        caption("Sound familiar?", ctx, local: local, start: 0.7, y: 120, size: 76, color: yellow)
    },
    Shot(name: "desktop", start: 24.0, end: 28.6) { ctx, local, t in
        brawl(ctx, .marvel, local: local, t: t, drop: true, chrome: false)
        badge("DESKTOP MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Now they're a pixel-art Marvelous Clawds brawl", ctx, local: local, start: 0.35, y: 900)
        caption("along the bottom of your screen. They fight while they work.", ctx, local: local, start: 0.6, y: 830, size: 40, color: yellow, weight: .bold)
    },
    Shot(name: "status", start: 28.6, end: 32.8) { ctx, local, t in
        let cast: [Cast] = [.hero(MarvelHero.thor), .villain(MarvelVillain.loki), .villain(MarvelVillain.ultron), .villain(MarvelVillain.thanos)]
        statusOf(ctx, local: local, t: t, cast: cast, badgeText: "MARVELOUS CLAWDS", aside: "(\(cast[3].name) sits down when the job's done. Relatable.)")
    },
    Shot(name: "agents", start: 32.8, end: 36.8) { ctx, local, t in
        agentsOf(ctx, local: local, t: t, guardCast: .hero(MarvelHero.ironMan),
                 crew: [.hero(MarvelHero.spiderMan), .hero(MarvelHero.blackWidow), .hero(MarvelHero.groot), .hero(MarvelHero.rocket)],
                 line: "Every subagent suits up.", badgeText: "MARVELOUS CLAWDS")
    },
    Shot(name: "window", start: 36.8, end: 41.6) { ctx, local, t in
        windowShot(ctx, .marvel, local: local, t: t, rise: true, needsAt: 2.5)
        badge("WINDOW MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Prefer a window? Grab some shawarma.", ctx, local: local, start: 0.1, y: 955, size: 56)
        caption("A live card per session: what it's doing, your last prompt, every agent.", ctx, local: local, start: 0.4, y: 890, size: 32, color: yellow, weight: .bold)
    },
    Shot(name: "ais", start: 41.6, end: 46.0) { ctx, local, t in
        everyAI(ctx, local: local, t: t, cast: [.hero(MarvelHero.captainAmerica), .hero(MarvelHero.ironMan), .villain(MarvelVillain.thanos),
                                                .villain(MarvelVillain.loki), .villain(MarvelVillain.ultron), .villain(MarvelVillain.greenGoblin),
                                                .villain(MarvelVillain.hydraAgent)])
    },
    // The end card: Clawdvengers Tower at night, the Clawdjet flies through, the title lands.
    Shot(name: "endcard", start: 46.0, end: 50.2) { ctx, local, t in
        blit(place(.avengersTower, floorRows: 34, t: t), ctx)
        ctx.setFillColor(CGColor(gray: 0, alpha: 0.35)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let fp = local / 1.2
        if fp > 0 && fp < 1 {
            let qc = PixelCanvas(Ride.width, Ride.height)
            drawRide(qc, .quinjet, ramp: 0, engines: true, gear: false); qc.addOutline(C(0xFFFFFF, 0.92))
            if let img = qc.makeImage() {
                let x = lerp(-600, Double(W) + 100, easeIn(fp) * 0.6 + fp * 0.4)
                ctx.saveGState(); ctx.interpolationQuality = .none
                ctx.draw(img, in: CGRect(x: x, y: 600 + 200 * fp, width: Double(Ride.width) * 6, height: Double(Ride.height) * 6))
                ctx.restoreGState()
            }
        }
        let crew: [(Cast, FightRole, AI)] = [(.hero(MarvelHero.ironMan), .cheer, .desktop), (.hero(MarvelHero.captainAmerica), .block, .claude),
                                             (.villain(MarvelVillain.thanos), .zap, .codex), (.villain(MarvelVillain.greenGoblin), .none, .copilot),
                                             (.villain(MarvelVillain.loki), .cheer, .qwen), (.villain(MarvelVillain.ultron), .none, .gemini)]
        var placed: [Actor] = []
        for (i, (who, role, ai)) in crew.enumerated() {
            var a = Actor(cast: who, x: [28.0, 84, 156, 206, 252, 296][i], facing: i < 2 ? 1 : -1, role: role, ai: ai)
            a.lift = 8
            a.alpha = clamp((local - 0.15 - Double(i) * 0.05) / 0.2)
            draw(a, ctx, t: t)
            placed.append(a)
        }
        if local > 0.5 { drawFX([(placed[1], placed[2])], ctx, t: t) }
        if local > 0.35 { marvelousTitle(ctx, center: CGPoint(x: Double(W) / 2, y: 760), scale: backOut((local - 0.35) / 0.4) * 0.8) }
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

let marvelousBeats: [(key: Double, beat: Beat)] = [
    (2.4, ("MEANWHILE...", "Black screen. A yellow comic caption types itself out.", "“MEANWHILE, IN A TERMINAL NEAR YOU...”", "typewriter keys, a bell")),
    (5.6, ("THE PANELS", "Six comic panels flip through the cast every beat (Iron Clawd, Thanoz, Captain Americlawd, Lokee, Thorr, Ultraton...), then fade back as MARVELOUS CLAWDS slams in on a yellow and red burst.", "MARVELOUS / CLAWDS", "page flips, then a big hit and a fanfare")),
    (13.0, ("THE INVASION", "The Battle of New York: the portal over the tower, a space whale noses out and dives at us until it fills the frame, Iron Clawd rockets up from the street firing repulsors.", "no text", "the portal hum, roars, repulsors, the rumble")),
    (18.0, ("THE RING", "On the street below, Captain Americlawd, Iron Clawd, Thorr, the Bulk, Black Window and Hawk-I stand back to back while the camera circles them.", "no text", "a heroic swell")),
    (21.4, ("THE HOOK", "Three busy terminals, slow push-in.", "“Three AIs. Nine agents. One very confused human.”  →  “Sound familiar?”", "keyboard clicks")),
    (26.3, ("DESKTOP MODE", "Captain Americlawd and Red Skulk drop onto the bottom edge: Red Skulk fires, the shield knocks every shot aside. Spider-Clawd's webs against the Green Gobbler's bombs.", "DESKTOP MODE  ·  “Now they're a pixel-art Marvelous Clawds brawl along the bottom of your screen. They fight while they work.”", "shield clangs, web thwips, bombs")),
    (30.9, ("AT A GLANCE", "Thorr working, Lokee thinking, Ultraton's jumping NEEDS YOU, Thanoz sat down napping.", "“All fun and games, and you still see everything.”  ·  “(Thanoz sits down when the job's done. Relatable.)”", "blips, alert beeps")),
    (35.0, ("SUBAGENTS", "Iron Clawd stands guard; Spider-Clawd, Black Window, Grout and Racket march in with their jobs on their labels.", "“Every subagent suits up.”", "footsteps, a Grout rumble")),
    (39.6, ("WINDOW MODE", "The window at Clawdvengers Tower: the shield blocks Red Skulk, live cards tick, then his Codex card flips to NEEDS YOU.", "WINDOW MODE  ·  “Prefer a window? Grab some shawarma.”", "a ping")),
    (44.0, ("EVERY AI", "Six sessions, one per AI outline; Claude's Captain Americlawd a head taller, holding his shield into Thanoz' gauntlet.", "BRING YOUR OWN AI*  ·  “One AI plays everyone. Run two and they pick sides.”  ·  *README for the full list", "the beam on the shield")),
    (49.0, ("END CARD", "Clawdvengers Tower at night: the Clawdjet streaks across, the crew lines up, MARVELOUS CLAWDS lands.", "MARVELOUS CLAWDS  ·  “Have fun. Keep track.”  ·  “One of many universes in Clawd Clash · free for macOS”  ·  github.com/rodclemen/clawd-clash", "a flyby, the final sting")),
]

/// The Marvelous Clawds trailer's score and effects.
func marvelousSound(_ m: Mix) {
    let mw = start("meanwhile")
    for i in 0..<35 { m.type(mw + 0.3 + Double(i) / 35 * 1.6 + noise(i) * 0.02, vol: 0.18 + noise(i + 50) * 0.08) }
    m.ding(mw + 2.0)
    m.tone(mw + 0.2, 3.0, midi(33), wave: .sine, vol: 0.05, attack: 1.0, release: 0.8)
    let pn = start("panels")
    for i in 0..<16 { m.flip(pn + Double(i) * 0.11, vol: 0.04 + Double(i) * 0.003) }
    let hit = pn + 1.7
    m.boom(hit, vol: 0.55); m.noise(hit, 1.6, vol: 0.12, cutoff: 0.9, decay: 0.5, highpass: true, seed: 3)
    for n in [48, 55, 60, 64, 67] { m.tone(hit, 1.0, midi(n), wave: .saw, vol: 0.05, release: 0.5, decay: 0.6) }
    for (s, d, n) in [(0.25, 0.22, 67), (0.5, 0.22, 72), (0.75, 0.5, 76), (1.3, 0.5, 74)] as [(Double, Double, Int)] {
        m.tone(hit + s, d, midi(n + 12), wave: .square(0.5), vol: 0.07, release: 0.08, vibrato: 0.006)
        m.tone(hit + s, d, midi(n), wave: .saw, vol: 0.045, release: 0.08)
    }
    let inv = start("invasion")
    m.tone(inv, 8.5 + 1.0, 110, wave: .sine, vol: 0.05, attack: 1, release: 1.5, vibrato: 0.03)
    for i in 0..<Int(9.5 / 0.25) { m.tone(inv + Double(i) * 0.25, 0.22, midi(i % 8 == 7 ? 37 : 36), wave: .square(0.25), vol: 0.04 + 0.06 * min(1, Double(i) / 30), release: 0.04) }
    for (s, chord) in [(0.0, [48, 51, 55]), (2.0, [44, 48, 51]), (4.0, [46, 50, 53]), (6.0, [48, 51, 55]), (7.0, [43, 47, 50])] {
        for n in chord { m.tone(inv + s, 1.8, midi(n), wave: .saw, vol: 0.035, attack: 0.05, release: 0.6) }
    }
    m.roar(inv + 2.6, 1.6, vol: 0.22); m.roar(inv + 5.6, 2.2, vol: 0.3)
    m.noise(inv + 3.0, 6.5, vol: 0.3, cutoff: 0.004, cutoffTo: 0.03, attack: 3.0, release: 1.5, seed: 5)
    m.tone(inv + 3.0, 6.5, 41, wave: .sine, vol: 0.16, attack: 3.0, release: 1.5)
    m.noise(inv + 4.2, 4.0, vol: 0.1, cutoff: 0.05, cutoffTo: 0.2, attack: 0.6, release: 1.2, seed: 12)
    for i in 0..<10 { m.repulsor(inv + 4.9 + Double(i) * 0.3, vol: 0.08) }
    let ring = start("ring")
    for k in 0..<10 { m.tone(ring - 0.5 + Double(k) * 0.05, 0.08, 70, to: 55, wave: .sine, vol: 0.05 + Double(k) * 0.012, decay: 0.05) }
    for (s, d, chord) in [(0.0, 1.1, [48, 52, 55, 60]), (1.1, 1.1, [41, 45, 48, 53]), (2.2, 1.1, [43, 47, 50, 55]), (3.3, 1.6, [48, 52, 55, 60])] {
        for n in chord { m.tone(ring + s, d, midi(n), wave: .saw, vol: 0.035, attack: 0.15, release: 0.4) }
        m.tone(ring + s, d, midi(chord[0] - 12), wave: .sine, vol: 0.16, attack: 0.05, release: 0.4)
    }
    for (s, d, n) in [(0.2, 0.4, 67), (0.6, 0.5, 72), (1.1, 0.9, 74), (2.2, 0.4, 71), (2.6, 0.5, 74), (3.3, 1.4, 79)] as [(Double, Double, Int)] {
        m.tone(ring + s, d, midi(n), wave: .square(0.5), vol: 0.06, attack: 0.02, release: 0.12, vibrato: 0.006)
    }
    groove(m, from: start("hook"), to: start("endcard"), fadeIn: 1.2)
    let hook = start("hook")
    for i in 0..<26 { m.click(hook + 0.2 + Double(i) * 0.13 + noise(i) * 0.06) }
    let desk = start("desktop"), deskEnd = end("desktop") + 1.3
    for (i, d) in [0.0, 0.12, 0.24, 0.32].enumerated() { m.step(desk + d + 0.3, vol: 0.1 + Double(i % 2) * 0.03) }
    for t in shotTimes(desk + 0.45, deskEnd, offset: 0) { m.pew(t, vol: 0.1); m.clang(t + boltArrival * blasterPeriod); m.thwip(t + 0.02, vol: 0.07) }
    for t in shotTimes(desk + 0.45, deskEnd, offset: blasterPeriod / 2) { m.bomb(t, vol: 0.08) }
    let st = start("status")
    for i in 0..<4 { m.pop(st + 0.1 + Double(i) * 0.22, step: i) }
    for k in 0..<5 { m.tone(st + 1.2 + Double(k) * 0.62, 0.08, 1568, wave: .square(0.5), vol: 0.035, release: 0.03) }
    let ag = start("agents")
    for k in 0..<14 { m.step(ag + Double(k) * 0.125, vol: 0.06) }
    m.groot(ag + 1.4)
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
