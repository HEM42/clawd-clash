import AppKit

// The Clawd Burton trailer: `REEL=burton build/renderpromo video promo` → promo/clawd-burton-promo.mp4.
// Drawn with RenderPromo's kit (Tools/RenderPromo/Kit: `Shot`, `brawl`, `windowShot`, `everyAI`, `Mix`…) and compiled
// only into that tool.

/// The Clawd Burton trailer, as the tool asks for it.
struct BurtonReel: PromoReel {
    let name = "burton", base = "clawd-burton-promo", small = "Clawd-Burton"
    var title: String { Universe.clawdBurton.title.uppercased() }
    let geminiTask = "gemini ▸ say the bug's name three times"
    var shots: [Shot] { burtonShots }
    var beats: [(key: Double, beat: Beat)] { burtonBeats }
    var universe: Universe { .clawdBurton }
    var brawl: BrawlCast {
        BrawlCast(claude: .hero(BurtonHero.jackSkullington), other: .villain(BurtonVillain.ooogieBoogie),
                  agent: .hero(BurtonHero.edwardScissorclawds), otherAgent: .villain(BurtonVillain.beetlejooce),
                  line: universe.isReleased ? "Or visit Clawd Burton." : "Coming soon: Clawd Burton.",
                  sub: "Skeletons, stripes, scissors and Martians: 107 characters in 23 places.")
    }
    var window: WindowCast {
        WindowCast(place: .halloweenTown, claude: .hero(BurtonHero.jackSkullington),
                   other: .villain(BurtonVillain.ooogieBoogie), agentA: .hero(BurtonHero.sallee),
                   agentB: .hero(BurtonHero.theMayor), extra: .villain(BurtonVillain.lok),
                   prompt: "You: “find out what's this”", otherPrompt: "You: “say the function name three times”")
    }
    func sound(_ m: Mix) { burtonSound(m) }
}

// MARK: The opening: the Model Town Flyover

/// Draws a picture `cw`×`ch` pixels over the whole frame as a camera would see it: `zoom` times the size that fits the
/// frame's width, the picture's point `focus` (pixels, y down) in the middle of the frame.
private func burtonCamera(_ ctx: CGContext, _ img: CGImage, focus: (x: Double, y: Double), zoom: Double) {
    let sc = Double(W) / Double(img.width) * zoom
    let r = CGRect(x: Double(W) / 2 - focus.x * sc, y: Double(H) / 2 + focus.y * sc - Double(img.height) * sc,
                   width: Double(img.width) * sc, height: Double(img.height) * sc)
    ctx.saveGState(); ctx.interpolationQuality = .none; ctx.draw(img, in: r); ctx.restoreGState()
}

/// Where a picture's point (pixels, y down) lands on screen through `burtonCamera`.
private func burtonOnScreen(_ p: (x: Double, y: Double), imgW: Int, focus: (x: Double, y: Double),
                            zoom: Double) -> CGPoint {
    let sc = Double(W) / Double(imgW) * zoom
    return CGPoint(x: Double(W) / 2 + (p.x - focus.x) * sc, y: Double(H) / 2 - (p.y - focus.y) * sc)
}

/// The giant spider, seen from above, walking left: a black body with a red glint of eyes, eight jointed legs stepping
/// in turn. Drawn `width` screen pixels across, centred on `at`.
private func burtonSpider(_ ctx: CGContext, at p: CGPoint, width: Double, t: Double, alpha: Double = 1) {
    guard width > 2, alpha > 0.01 else { return }
    let c = PixelCanvas(44, 30), ink = C(0x0C0A08), sheen = C(0x2A2620)
    for side in [-1.0, 1.0] {
        for k in 0..<4 {
            let phase = sin(t * 9 + Double(k) * 1.6 + (side > 0 ? .pi : 0)), spread = Double(k) - 1.5
            let hip = (x: 18.0 + Double(k) * 2.5, y: 15.0)
            let knee = (x: hip.x + spread * 5 + phase * 1.5, y: hip.y + side * (6 + abs(spread)))
            let foot = (x: knee.x + spread * 4 + phase * 2, y: hip.y + side * (13 - abs(spread) * 0.8))
            c.glowLine(hip.x, hip.y, knee.x, knee.y, core: ink, glow: C(0, 0), coreR: 0.9, glowR: 1)
            c.glowLine(knee.x, knee.y, foot.x, foot.y, core: ink, glow: C(0, 0), coreR: 0.7, glowR: 0.8)
        }
    }
    c.ellipse(26, 15, 8, 6, ink); c.ellipse(25, 13, 4, 2, sheen)
    c.circle(15, 15, 4, ink); c.px(12, 14, C(0xC8202A)); c.px(12, 16, C(0xC8202A))
    c.addOutline(C(0xFFFFFF, 0.25))
    guard let img = c.makeImage() else { return }
    let h = width * 30 / 44
    ctx.saveGState(); ctx.setAlpha(CGFloat(alpha)); ctx.interpolationQuality = .none
    ctx.draw(img, in: CGRect(x: p.x - width / 2, y: p.y - h / 2, width: width, height: h))
    ctx.restoreGState()
}

/// The size of the town and the attic as the camera sees them, and the moment the spider covers the cut to the attic.
private let burtonIntroW = 400, burtonIntroH = 225, burtonIntroSwap = 4.25

/// The opening, the Model Town Flyover: dusk clouds part over Winter River, and the camera glides across the river and
/// up to the white house on its hill. A spider, enormous, walks across; the camera pulls back and it's a model on the
/// attic table, the spider on it. In the model's graveyard a little striped figure pops up and waves. The title curls
/// up out of the mist, and the camera plunges in through the model house's door.
private func burtonIntro(_ ctx: CGContext, local l: Double, t: Double) {
    if l < burtonIntroSwap { burtonIntroTown(ctx, local: l, t: t) } else { burtonIntroAttic(ctx, local: l, t: t) }
    // The spider: huge, walking across the town (a real spider, close to the camera), and on across the model once the
    // camera has pulled back, getting smaller with the pull.
    if l > 3.2 && l < 7.7 {
        let a = clamp((l - 3.2) / 0.3) * (1 - clamp((l - 7.3) / 0.4))
        if l < burtonIntroSwap {
            let k = (l - 3.2) / (burtonIntroSwap - 3.2)
            burtonSpider(ctx, at: CGPoint(x: lerp(Double(W) + 500, Double(W) / 2, k), y: Double(H) / 2 - 60),
                         width: 1300, t: t, alpha: a)
        } else {
            let pull = easeOut((l - burtonIntroSwap) / 1.7), walk = (l - burtonIntroSwap) * 22
            burtonSpider(ctx, at: CGPoint(x: Double(W) / 2 - walk * lerp(1, 0.25, pull) - pull * 260,
                                          y: Double(H) / 2 - 60 + pull * 40),
                         width: lerp(1300, 70, pull), t: t, alpha: a)
        }
    }
    // The title curls up out of the mist, settles, then rushes at us with the camera.
    if l > 5.7 {
        let rise = easeOut((l - 5.7) / 1.0), dive = easeIn((l - 7.9) / 0.9)
        burtonTitle(ctx, center: CGPoint(x: Double(W) / 2, y: lerp(420, 800, rise)),
                    scale: (0.5 + 0.72 * backOut((l - 5.7) / 1.0)) * (1 + dive * 4),
                    alpha: clamp((l - 5.7) / 0.5) * (1 - clamp((l - 8.3) / 0.3)))
    }
    // out of the black at the start, into the black at the end
    let dark = max(1 - clamp(l / 0.7), clamp((l - 8.4) / 0.5))
    if dark > 0 { ctx.setFillColor(CGColor(gray: 0, alpha: dark)); ctx.fill(fullRect) }
}

/// Winter River at dusk: the clouds part, and the camera glides from the river up the hill to the white house.
private func burtonIntroTown(_ ctx: CGContext, local l: Double, t: Double) {
    let cw = burtonIntroW, ch = burtonIntroH
    let town = place(.maitlandHouse, floorRows: 18, t: t, w: cw, h: ch)
    guard let img = town.makeImage() else { return }
    let f = Scenes.mhFrame(town, ch - 18)
    let k = easeOut(l / 3.6), houseFocus = (x: Double(f.x), y: Double(f.base) - 30)
    burtonCamera(ctx, img, focus: (lerp(150, houseFocus.x, k), lerp(150, houseFocus.y + 10, k)),
                 zoom: lerp(1.15, 1.7, k))
    // dusk over it, and the clouds parting
    ctx.setFillColor(hexColor(0x3A1A5A, 0.42)); ctx.fill(fullRect)
    ctx.setFillColor(hexColor(0xFF8A3A, 0.12)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H / 2))
    let part = easeIn(l / 1.6)
    for i in 0..<14 {
        let left = i % 2 == 0, y = 120 + noise(i + 7700) * Double(H - 240), r = 160 + noise(i + 7710) * 200
        let x = Double(W) / 2 + (left ? -1 : 1) * (noise(i + 7720) * 300 + part * 1300)
        ctx.setFillColor(hexColor(left ? 0x2A1840 : 0x34204C, 0.95 * (1 - part * 0.6)))
        ctx.fillEllipse(in: CGRect(x: x - r, y: y - r * 0.5, width: r * 2, height: r))
    }
}

/// The attic: the camera pulls back off the model house until the whole table shows, Beetlejooce pops up in the
/// model's graveyard and waves, mist rolls in, and the camera plunges back in at the model house.
private func burtonIntroAttic(_ ctx: CGContext, local l: Double, t: Double) {
    let cw = burtonIntroW, ch = burtonIntroH
    let attic = place(.modelWinterRiver, floorRows: 18, t: t, w: cw, h: ch)
    let f = Scenes.mtFrame(attic, ch - 18)
    let house = Scenes.mtAt(f, 0.86, 0.06), houseY = Double(house.y) - 9 * Double(f.k)
    guard let img = attic.makeImage() else { return }
    let pull = easeOut((l - burtonIntroSwap) / 1.7), plunge = easeIn((l - 7.9) / 1.0)
    let zoom = lerp(5.0, 1.05, pull) * (1 + plunge * 9)
    let settled = (x: lerp(Double(house.x), Double(cw) / 2 + 10, pull), y: lerp(houseY, Double(ch) / 2, pull))
    let focus = (x: lerp(settled.x, Double(house.x), plunge), y: lerp(settled.y, houseY, plunge))
    burtonCamera(ctx, img, focus: focus, zoom: zoom)
    // Beetlejooce pops up in the model's graveyard, a quarter of a model house tall, and waves.
    let grave = Scenes.mtAt(f, 0.53, 0.5), gu = Double(max(1, Int(Double(f.k) * grave.z)))
    let pop = clamp((l - 5.0) / 0.35) * (1 - clamp((l - 7.6) / 0.3))
    if pop > 0 {
        let sp = PixelCanvas(Sprite.width, Sprite.height)
        Cast.villain(BurtonVillain.beetlejooce).draw(sp, t: t, mode: .working, walking: false,
                                                     role: l > 5.4 ? .cheer : .none, asSession: true)
        sp.addOutline(C(0xFFFFFF, 0.9))
        if let jimg = sp.onlyRows(0..<(10 + Int(pop * 34))).makeImage() {
            let sc = Double(W) / Double(cw) * zoom / 2.4
            let foot = burtonOnScreen((Double(grave.x) + 12 * gu, Double(grave.y) + (1 - pop) * 6), imgW: cw,
                                      focus: focus, zoom: zoom)
            ctx.saveGState(); ctx.interpolationQuality = .none
            ctx.draw(jimg, in: CGRect(x: foot.x - Sprite.bodyCenterX * sc,
                                      y: foot.y - (Double(Sprite.height) - 44) * sc,
                                      width: Double(Sprite.width) * sc, height: Double(Sprite.height) * sc))
            ctx.restoreGState()
        }
    }
    // the mist the title rises out of
    let mist = clamp((l - 5.6) / 0.8) * (1 - plunge)
    for i in 0..<5 {
        let y = 40.0 + Double(i) * 70 + sin(t * 0.7 + Double(i)) * 20
        ctx.setFillColor(hexColor(0xC8C0E8, 0.12 * mist))
        ctx.fillEllipse(in: CGRect(x: -200 + sin(t * 0.4 + Double(i)) * 150, y: y, width: Double(W) + 400, height: 160))
    }
}

// MARK: The set piece: Mars Attacks Halloween Town

/// A Martian saucer at frame-pixel size, centred on (x, y): a silver disc, its underside darker, rim lights chasing,
/// a green glass dome on top with a pink brain in it.
private func burtonSaucer(_ c: PixelCanvas, x: Int, y: Int, t: Double) {
    c.ellipse(x, y - 4, 6, 5, C(0x8AF0A0, 0.55)); c.ellipse(x, y - 5, 3, 2, C(0xE88AB0))
    c.ellipse(x, y, 16, 4, C(0xB8BCC8)); c.ellipse(x, y + 2, 13, 2, C(0x6A6E7A))
    c.rect(x - 16, y - 1, 32, 1, C(0xE4E8F0))
    for k in 0..<7 {
        let on = (k + Int(t * 8)) % 3 == 0
        c.px(x - 12 + k * 4, y + 1, on ? C(0xFFF07A) : C(0x8A8040))
    }
}

/// The set piece's timings (shot-local seconds) and where everyone stands.
private let bzGround = 160.0, bzSaucers: [(x: Double, hover: Double)] = [(212, 52), (252, 40), (290, 56)]
private let bzBeamDown = 1.8, bzScare = 2.6, bzGran = 4.0, bzRecord = 4.9, bzPops = [5.2, 5.5, 5.8], bzJooce = 6.2

/// Mars Attacks Halloween Town: saucers drop over the square and zap the pumpkins while the residents cheer as if it's
/// a holiday. The Martians beam down; Jack pulls his scariest face, and they aren't scared ("Ack! Ack!"). Then Grandma
/// Florenz turns up her record and the yodel pops their domes in green goo, and Beetlejooce springs out of the
/// fountain.
private func burtonInvasion(_ ctx: CGContext, local l: Double, t: Double) {
    blit(place(.halloweenTown, floorRows: 30, t: t), ctx)
    onStage(ctx, fullRect, scale: 6, ground: bzGround) {
        let fx = PixelCanvas(fxW, fxH)
        // the saucers, dropping in and hovering, wobbling; their beams on the pumpkins, then the tractor beams down
        for (i, s) in bzSaucers.enumerated() {
            let down = easeOut((l - 0.3 - Double(i) * 0.3) / 1.2), fled = easeIn((l - bzPops[i] - 0.2) / 1.0)
            let y = lerp(-20, s.hover, down) - fled * 90 + sin(t * 2 + Double(i)) * 1.5
            guard y > -12 else { continue }
            if l > 1.1 && l < bzBeamDown, Int(t * 5 + Double(i) * 1.3) % 3 != 2 {
                let tx = 30 + noise(i * 13 + Int(t * 5)) * 150, ty = 150 + noise(i * 17 + Int(t * 5)) * 8
                fx.glowLine(s.x, y + 3, tx, ty, core: C(0xFFF07A), glow: C(0x3AE05A), coreR: 0.6, glowR: 1.8)
                drawSparks(fx, x: tx, y: ty, t: t + Double(i), size: 3)
                for k in 0..<6 {
                    let dx = Int((noise(k + i * 9 + Int(t * 5)) - 0.5) * 8), dy = Int(noise(k + 40 + i) * 5)
                    fx.px(Int(tx) + dx, Int(ty) - dy, C(0xFF8A2A))
                }
            }
            let beam = clamp((l - bzBeamDown) / 0.3) * (1 - clamp((l - bzBeamDown - 0.9) / 0.3))
            if beam > 0 {
                for yy in Int(y + 3)..<Int(bzGround) {
                    let half = 3 + (Double(yy) - y) * 0.12
                    fx.rect(Int(s.x - half), yy, Int(half * 2), 1, C(0x8AF0A0, 0.22 * beam))
                }
            }
            burtonSaucer(fx, x: Int(s.x), y: Int(y), t: t)
        }
        // the residents: cheering at the light show, then Jack scares
        let cheering = l > 1.0 && l < bzScare
        var mayor = Actor(cast: .hero(BurtonHero.theMayor), x: 34, facing: 1, mode: .idle,
                          role: cheering ? .cheer : .none)
        var sallee = Actor(cast: .hero(BurtonHero.sallee), x: 60, facing: 1, mode: .idle,
                           role: cheering || l > bzJooce + 0.6 ? .cheer : .none)
        var jack = Actor(cast: .hero(BurtonHero.jackSkullington), x: 132, facing: 1, mode: .idle)
        mayor.urgent = false; sallee.urgent = false
        // the Martians, beamed down under their saucers
        var martians: [Actor] = []
        let invaders: [Cast] = [.villain(BurtonVillain.martianLeader), .villain(BurtonVillain.martianAmbassador),
                                .villain(BurtonVillain.martianTrooper)]
        for (i, who) in invaders.enumerated() {
            var m = Actor(cast: who, x: bzSaucers[i].x, facing: -1, mode: .idle)
            m.alpha = clamp((l - bzBeamDown - 0.3) / 0.5) * (1 - clamp((l - bzPops[i] - 0.5) / 0.3))
            let popped = l > bzPops[i]
            m.role = popped ? .hit : (l > bzScare + 0.6 && l < bzRecord ? .shoot(offset: Double(i) * 0.3) : .none)
            if popped { m.lift = -easeIn((l - bzPops[i]) / 0.6) * 8 }
            martians.append(m)
        }
        // Grandma Florenz walks in with her record player and turns it up
        var gran = Actor(cast: .hero(BurtonHero.grandmaFlorenz), x: lerp(-20, 164, easeOut((l - bzGran) / 0.9)),
                         facing: 1, mode: .idle)
        gran.walking = l > bzGran && l < bzGran + 0.9
        gran.alpha = l > bzGran ? 1 : 0
        let leader = martians[0]
        if l > bzScare && l < bzRecord - 0.3 {
            jack.role = .zap
            drawFX([(jack, leader)], ctx, t: t)
        }
        if l > bzRecord && l < bzPops[2] + 0.4,
           let i = bzPops.firstIndex(where: { l < $0 }) ?? (l < bzPops[2] + 0.4 ? 2 : nil) {
            let target = martians[i]
            gran.role = .zap
            drawFX([(gran, target)], ctx, t: t)
            for k in 0..<5 {                                                        // the yodel's notes floating over
                let f = frac(t * 0.8 + Double(k) / 5), nx = 170 + f * 90, ny = 120 - f * 40 - sin(f * 9) * 4
                fx.pattern(Int(nx), Int(ny), [".XX", ".X.", "XX.", "XX."], ["X": C(0xFF9EC8, 1 - f)])
            }
        }
        // the domes popping in green goo
        for (i, at) in bzPops.enumerated() where l > at && l < at + 0.9 {
            let f = (l - at) / 0.9, hx = bzSaucers[i].x - 1, hy = bzGround - 40
            for k in 0..<14 {
                let a = Double(k) / 14 * 2 * .pi, r = 3 + f * 14
                fx.rect(Int(hx + cos(a) * r), Int(hy + sin(a) * r * 0.7 + f * f * 10), 2, 2, C(0x6ADB2E, 1 - f))
            }
            fx.ellipse(Int(hx), Int(hy), Int(6 * (1 - f)) + 1, Int(4 * (1 - f)) + 1, C(0xB8F060, 1 - f))
        }
        // Beetlejooce springs out of the fountain in a gout of slime
        var jooce = Actor(cast: .villain(BurtonVillain.beetlejooce), x: 96, facing: 1, mode: .idle)
        if l > bzJooce {
            let up = easeOut((l - bzJooce) / 0.45), fall = easeIn((l - bzJooce - 0.45) / 0.35)
            jooce.lift = lerp(-30, 26, up) - 26 * fall
            jooce.role = l > bzJooce + 0.9 ? .cheer : .none
            for k in 0..<16 where l < bzJooce + 1.0 {
                let f = clamp((l - bzJooce) / 1.0), a = -Double.pi / 2 + (noise(k + 7800) - 0.5) * 1.6, r = f * 30
                fx.rect(Int(96 + cos(a) * r), Int(bzGround - 8 + sin(a) * r + f * f * 30), 2, 2, C(0x6ADB2E, 1 - f))
            }
        }
        for a in [mayor, sallee, jack] + martians where a.alpha > 0.01 { draw(a, ctx, t: t) }
        if gran.alpha > 0 { draw(gran, ctx, t: t) }
        if l > bzJooce { draw(jooce, ctx, t: t) }
        if let img = fx.makeImage() {
            ctx.saveGState(); ctx.interpolationQuality = .none; ctx.draw(img, in: fullRect); ctx.restoreGState()
        }
        if l > bzScare + 0.9 && l < bzRecord - 0.2 {
            balloon("Ack! Ack!", ctx, center: CGPoint(x: leader.x * S + 140, y: 880), tail: headPoint(leader),
                    size: 44, width: 400, alpha: clamp((l - bzScare - 0.9) / 0.15))
        }
        if l > bzJooce + 0.7 {
            balloon("It's showtime!", ctx, center: CGPoint(x: jooce.x * S + 260, y: 860), tail: headPoint(jooce),
                    size: 48, width: 520, alpha: clamp((l - bzJooce - 0.7) / 0.15))
        }
    }
    // out of the black of the opening
    let dark = 1 - clamp(l / 0.5)
    if dark > 0 { ctx.setFillColor(CGColor(gray: 0, alpha: dark)); ctx.fill(fullRect) }
}

// MARK: The end card

/// The end card's line under "Have fun. Keep track.": never a count of universes.
private let burtonTagline = "One of many universes in Clawd Clash · free for macOS"

/// The end card: Halloween Town at night, the crew lines up, the title lands with its spiral flourish, then the app's
/// icon and where to get it.
private func burtonEndcard(_ ctx: CGContext, local: Double, t: Double) {
    blit(place(.halloweenTown, floorRows: 34, t: t), ctx)
    ctx.setFillColor(CGColor(gray: 0, alpha: 0.3)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
    let crew: [(Cast, FightRole, AI)] = [
        (.hero(BurtonHero.sallee), .cheer, .desktop), (.hero(BurtonHero.jackSkullington), .zap, .claude),
        (.villain(BurtonVillain.ooogieBoogie), .hit, .codex), (.villain(BurtonVillain.beetlejooce), .none, .copilot),
        (.hero(BurtonHero.edwardScissorclawds), .cheer, .qwen), (.hero(BurtonHero.willyWonky), .none, .gemini),
    ]
    var placed: [Actor] = []
    for (i, (who, role, ai)) in crew.enumerated() {
        var a = Actor(cast: who, x: [28.0, 84, 160, 210, 256, 298][i], facing: i < 2 ? 1 : -1, role: role, ai: ai)
        a.lift = 8
        a.alpha = clamp((local - 0.15 - Double(i) * 0.05) / 0.2)
        draw(a, ctx, t: t)
        placed.append(a)
    }
    if local > 0.5 { drawFX([(placed[1], placed[2])], ctx, t: t) }
    if local > 0.35 {
        burtonTitle(ctx, center: CGPoint(x: Double(W) / 2, y: 770), scale: backOut((local - 0.35) / 0.4) * 0.72)
    }
    caption("Have fun. Keep track.", ctx, local: local, start: 0.6, y: 520, size: 56)
    caption(burtonTagline, ctx, local: local, start: 0.8, y: 462, size: 34, color: NSColor(white: 0.85, alpha: 1),
            weight: .bold)
    let ff = easeOut((local - 0.9) / 0.3)
    if ff > 0, let icon = appIcon {
        ctx.setFillColor(CGColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 0.8 * ff))
        ctx.fill(CGRect(x: 0, y: 0, width: W, height: 170))
        ctx.saveGState(); ctx.setAlpha(CGFloat(ff)); ctx.interpolationQuality = .high
        ctx.draw(icon, in: CGRect(x: 580, y: 20, width: 130, height: 130))
        ctx.restoreGState()
        text("github.com/rodclemen/clawd-clash", ctx, x: 740, y: 60, size: 44, weight: .bold, alpha: ff)
    }
}

// MARK: The shots

private let burtonShots: [Shot] = [
    // The Model Town Flyover: dusk over Winter River, the spider, the attic model, the title out of the mist.
    Shot(name: "intro", start: 0, end: 9.0, into: .cut) { ctx, local, t in burtonIntro(ctx, local: local, t: t) },
    // Mars Attacks Halloween Town.
    Shot(name: "invasion", start: 9.0, end: 18.5, into: .cut) { ctx, local, t in
        burtonInvasion(ctx, local: local, t: t)
    },
    Shot(name: "hook", start: 18.5, end: 22.5) { ctx, local, _ in
        let zoom = 1 + 0.03 * local
        ctx.saveGState()
        ctx.translateBy(x: Double(W) / 2, y: Double(H) / 2); ctx.scaleBy(x: zoom, y: zoom)
        ctx.translateBy(x: -Double(W) / 2, y: -Double(H) / 2)
        desktop(ctx, dim: 0)
        ctx.restoreGState()
        caption("Three AIs. Nine agents. One very confused Mayor.", ctx, local: local, start: 0.05, y: 860, size: 60)
        caption("Sound familiar?", ctx, local: local, start: 0.7, y: 120, size: 76, color: yellow)
    },
    Shot(name: "desktop", start: 22.5, end: 27.1) { ctx, local, t in
        brawl(ctx, .clawdBurton, local: local, t: t, drop: true, chrome: false)
        badge("DESKTOP MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("The ghost with the most, on your desktop.", ctx, local: local, start: 0.35, y: 900)
        caption("A pixel-art \(Universe.clawdBurton.title) brawl along the bottom of your screen. "
                + "They fight while they work.", ctx, local: local, start: 0.6, y: 830, size: 40, color: yellow,
                weight: .bold)
    },
    Shot(name: "status", start: 27.1, end: 31.3) { ctx, local, t in
        let cast: [Cast] = [.hero(BurtonHero.jackSkullington), .hero(BurtonHero.lydiaDeathz),
                            .hero(BurtonHero.theMayor), .hero(BurtonHero.grampaJoe)]
        statusOf(ctx, local: local, t: t, cast: cast, badgeText: Universe.clawdBurton.title.uppercased(),
                 aside: "(\(cast[2].name): working… or worried? \(cast[3].name) has gone back to bed.)")
    },
    Shot(name: "agents", start: 31.3, end: 35.3) { ctx, local, t in
        agentsOf(ctx, local: local, t: t, guardCast: .hero(BurtonHero.jackSkullington),
                 crew: [.villain(BurtonVillain.lok), .villain(BurtonVillain.shok), .villain(BurtonVillain.barrell),
                        .hero(BurtonHero.scrapz)],
                 line: "Every subagent gets to be a monster.", badgeText: Universe.clawdBurton.title.uppercased())
    },
    Shot(name: "window", start: 35.3, end: 40.1) { ctx, local, t in
        windowShot(ctx, .clawdBurton, local: local, t: t, rise: true, needsAt: 2.5, at: .halloweenTown)
        badge("WINDOW MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Prefer a window? Strange and unusual.", ctx, local: local, start: 0.1, y: 955, size: 56)
        caption("A live card per session: what it's doing, your last prompt, every agent.", ctx, local: local,
                start: 0.4, y: 890, size: 32, color: yellow, weight: .bold)
    },
    Shot(name: "ais", start: 40.1, end: 44.5) { ctx, local, t in
        everyAI(ctx, local: local, t: t, cast: [.hero(BurtonHero.jackSkullington), .hero(BurtonHero.willyWonky),
                                                .hero(BurtonHero.edwardScissorclawds), .hero(BurtonHero.ichabodCraine),
                                                .hero(BurtonHero.lydiaDeathz), .hero(BurtonHero.aliceKingsclawd),
                                                .hero(BurtonHero.sparkie)])
    },
    // The end card: Halloween Town at night, the crew lines up, the title lands with its spiral flourish.
    Shot(name: "endcard", start: 44.5, end: 48.7) { ctx, local, t in burtonEndcard(ctx, local: local, t: t) },
]

// MARK: The storyboard

/// A Clawd Burton character's name, as the app has it.
private func burtonName(_ h: BurtonHero) -> String { Cast.hero(h).name }
private func burtonName(_ v: BurtonVillain) -> String { Cast.villain(v).name }

private let burtonJack = burtonName(BurtonHero.jackSkullington), burtonJooce = burtonName(BurtonVillain.beetlejooce)

private let burtonBeats: [(key: Double, beat: Beat)] = [
    (1.8, ("THE MODEL TOWN FLYOVER",
           "Out of the black: dusk clouds part over Winter River, and the camera glides from the river and the covered "
           + "bridge up the hill to the white house with its black tower.",
           "no text",
           "a lopsided waltz on celesta and pizzicato strings over a tuba, wordless la-la choir, the wind; "
           + "our own notes")),
    (4.0, ("THE SPIDER",
           "A spider, enormous, walks across the frame in front of the house; as it passes, the camera pulls back and "
           + "it's the model on the attic table, the spider picking its way across it.",
           "no text", "the choir swells, soft spider steps")),
    (6.2, ("SHOWTIME, IN MINIATURE",
           "In the model's graveyard a tiny striped figure pops up and waves: \(burtonJooce). Mist rolls in, and CLAWD "
           + "over BURTON curls up out of it in spidery bone-white strokes, the O a full moon, a small \"universe\" "
           + "under it.",
           "CLAWD BURTON universe", "a celesta glissando, the big hit as the title lands")),
    (8.4, ("INTO THE MODEL", "The camera plunges in through the model house's door, into the black.", "no text",
           "a rising whoosh")),
    (10.5, ("MARS ATTACKS HALLOWEEN TOWN",
            "Halloween Town square: three Martian saucers drop out of the night and zap the pumpkins; "
            + "\(burtonName(BurtonHero.theMayor)) and \(burtonName(BurtonHero.sallee)) cheer as if it's a holiday.",
            "no text", "a theremin's wobble, ray-gun zaps, pumpkins splatting, cheering")),
    (12.0, ("THE SCARE", "The Martians beam down. \(burtonJack) pulls his scariest face at them; they aren't scared.",
            "“Ack! Ack!”", "the scare's throb, Martian chirps")),
    (14.2, ("THE YODEL",
            "\(burtonName(BurtonHero.grandmaFlorenz)) walks in with her record player and turns it up: the yodel sails "
            + "out, and one by one the Martians' domes pop in green goo.",
            "no text", "a yodelling record (our own notes), three pops and splats")),
    (15.9, ("IT'S SHOWTIME", "\(burtonJooce) springs out of the slime fountain.", "“It's showtime!”",
            "a boing, a splash, a brass stab")),
    (20.0, ("THE HOOK", "Three busy terminals, slow push-in.",
            "“Three AIs. Nine agents. One very confused Mayor.”  →  “Sound familiar?”", "keyboard clicks")),
    (24.8, ("DESKTOP MODE",
            "\(burtonJack) scaring \(burtonName(BurtonVillain.ooogieBoogie)); "
            + "\(burtonName(BurtonHero.edwardScissorclawds)) against \(burtonJooce)'s snake arm.",
            "DESKTOP MODE  ·  “The ghost with the most, on your desktop.”  ·  “A pixel-art Clawd Burton brawl along "
            + "the bottom of your screen. They fight while they work.”",
            "scares, snips, dice")),
    (29.4, ("AT A GLANCE",
            "\(burtonJack) working, \(burtonName(BurtonHero.lydiaDeathz)) thinking, \(burtonName(BurtonHero.theMayor)) "
            + "jumping NEEDS YOU in his worried face, \(burtonName(BurtonHero.grampaJoe)) napping.",
            "“All fun and games, and you still see everything.”  ·  “(The Mayor: working… or worried? Grampa Joe has "
            + "gone back to bed.)”",
            "blips, alert beeps")),
    (33.5, ("SUBAGENTS",
            "\(burtonJack) stands guard; \(burtonName(BurtonVillain.lok)), \(burtonName(BurtonVillain.shok)), "
            + "\(burtonName(BurtonVillain.barrell)) and \(burtonName(BurtonHero.scrapz)) arrive with their jobs on "
            + "their labels.",
            "“Every subagent gets to be a monster.”", "footsteps")),
    (38.1, ("WINDOW MODE",
            "The window in Halloween Town: \(burtonJack) against \(burtonName(BurtonVillain.ooogieBoogie)), live cards "
            + "tick, then the Codex card flips to NEEDS YOU.",
            "WINDOW MODE  ·  “Prefer a window? Strange and unusual.”", "a ping")),
    (42.5, ("EVERY AI",
            "Seven sessions, one per AI outline: \(burtonJack) (Claude Code, a head taller) against "
            + "\(burtonName(BurtonHero.edwardScissorclawds)), with \(burtonName(BurtonHero.willyWonky)), "
            + "\(burtonName(BurtonHero.ichabodCraine)), \(burtonName(BurtonHero.lydiaDeathz)), "
            + "\(burtonName(BurtonHero.aliceKingsclawd)) and \(burtonName(BurtonHero.sparkie)).",
            "BRING YOUR OWN AI*  ·  “One AI plays everyone. Run two and they pick sides.”  ·  "
            + "*README for the full list",
            "the scare's throb")),
    (47.5, ("END CARD", "Halloween Town at night: the crew lines up, CLAWD BURTON lands, then the icon and the URL.",
            "CLAWD BURTON universe  ·  “Have fun. Keep track.”  ·  “\(burtonTagline)”  ·  "
            + "github.com/rodclemen/clawd-clash",
            "the waltz's last chord, choir and celesta")),
]

// MARK: The sound

/// The trailer's own instruments, played into a mix: a celesta, pizzicato strings, a tuba, a wordless choir, a
/// theremin, a yodelling record, and the effects (a boing, a Martian ray gun, a splat).
private struct BurtonBand {
    let m: Mix

    /// A celesta note: a bright sine with a quick bell-like decay and a faint octave above.
    func celesta(_ t: Double, _ n: Int, vol: Double = 0.05) {
        m.tone(t, 0.6, midi(n), wave: .sine, vol: vol, attack: 0.002, release: 0.3, decay: 0.25)
        m.tone(t, 0.4, midi(n + 12), wave: .sine, vol: vol * 0.35, attack: 0.002, release: 0.2, decay: 0.12)
    }
    /// A pizzicato pluck.
    func pizz(_ t: Double, _ n: Int, vol: Double = 0.05) {
        m.tone(t, 0.18, midi(n), wave: .triangle, vol: vol, attack: 0.002, release: 0.06, decay: 0.07)
    }
    /// A tuba note.
    func tuba(_ t: Double, _ n: Int, _ dur: Double, vol: Double = 0.12) {
        m.tone(t, dur, midi(n), wave: .saw, vol: vol * 0.35, attack: 0.03, release: 0.08)
        m.tone(t, dur, midi(n), wave: .sine, vol: vol, attack: 0.02, release: 0.08)
    }
    /// The wordless choir: a held "la" on each note, soft at the start, with a slow wobble.
    func choir(_ t: Double, _ dur: Double, _ notes: [Int], vol: Double = 0.03) {
        for n in notes {
            for d in [1.0, 1.006] {
                m.tone(t, dur, midi(n) * d, wave: .sine, vol: vol, attack: 0.35, release: 0.6, vibrato: 0.012)
            }
            m.tone(t, dur, midi(n), wave: .triangle, vol: vol * 0.25, attack: 0.4, release: 0.6, vibrato: 0.012)
        }
    }
    /// A theremin's wobbling glide, from `from` to `to`.
    func theremin(_ t: Double, _ dur: Double, from: Double, to: Double, vol: Double = 0.05) {
        m.tone(t, dur, from, to: to, wave: .sine, vol: vol, attack: 0.15, release: 0.2, vibrato: 0.03)
    }
    /// The yodelling record: a voice flipping fast between a low and a high note, with a scratchy needle under it.
    func yodel(_ t: Double, _ dur: Double, vol: Double = 0.06) {
        let notes = [67, 79, 72, 84, 71, 79, 67, 76]
        var s = t, k = 0
        while s < t + dur {
            let n = notes[k % notes.count], d = k % 2 == 0 ? 0.16 : 0.24
            m.tone(s, d, midi(n), wave: .square(0.4), vol: vol, attack: 0.01, release: 0.03, vibrato: 0.02)
            m.tone(s, d, midi(n), wave: .sine, vol: vol * 0.8, attack: 0.01, release: 0.03, vibrato: 0.02)
            s += d; k += 1
        }
        m.noise(t, dur, vol: vol * 0.25, cutoff: 0.6, highpass: true, seed: 77)
    }
    /// A spring: a boing.
    func boing(_ t: Double, vol: Double = 0.08) {
        m.tone(t, 0.35, 160, to: 420, wave: .sine, vol: vol, release: 0.1, vibrato: 0.08)
    }
    /// A Martian ray gun.
    func martianZap(_ t: Double, vol: Double = 0.05) {
        m.tone(t, 0.18, 1800, to: 700, wave: .square(0.3), vol: vol, release: 0.06)
        m.tone(t, 0.18, 2400, to: 900, wave: .sine, vol: vol * 0.6, release: 0.06)
    }
    /// A wet splat.
    func splat(_ t: Double, vol: Double = 0.12) {
        m.noise(t, 0.2, vol: vol, cutoff: 0.25, decay: 0.07, seed: Int(t * 131))
    }

    /// The lopsided waltz in D minor: a tuba on the downbeat, pizzicato chords on two and three (the two a hair early),
    /// a celesta tune above, our own notes. `bars` of it from `t0`.
    func waltz(from t0: Double, bars: Int, tune: Bool = true, vol: Double = 1) {
        let beat = 0.42, bar = beat * 3
        let roots = [38, 33, 34, 33, 38, 31, 33, 38]
        let chords = [[62, 65, 69], [61, 64, 69], [62, 65, 70], [61, 64, 67], [62, 65, 69], [62, 67, 70], [61, 64, 69],
                      [62, 65, 69]]
        let melody: [[(Int, Double)]] = [[(74, 1), (77, 1), (76, 1)], [(73, 2), (76, 1)], [(77, 1), (74, 1), (70, 1)],
                                         [(73, 3)], [(74, 1), (81, 1), (79, 1)], [(77, 1), (74, 1), (79, 1)],
                                         [(76, 1), (73, 1), (69, 1)], [(74, 3)]]
        for b in 0..<bars {
            let s = t0 + Double(b) * bar, c = b % roots.count
            tuba(s, roots[c], beat * 0.9, vol: 0.12 * vol)
            for off in [beat * 0.92, beat * 2] { for n in chords[c] { pizz(s + off, n - 12, vol: 0.035 * vol) } }
            if tune {
                var tt = s
                for (n, d) in melody[c] { celesta(tt, n, vol: 0.05 * vol); tt += d * beat }
            }
        }
    }
}

/// The Clawd Burton trailer's score and effects.
private func burtonSound(_ m: Mix) {
    let band = BurtonBand(m: m)
    // the opening: the wind, the waltz and the choir, the spider's feet, the title's hit, the plunge
    let i0 = start("intro")
    m.noise(i0, 4.5, vol: 0.05, cutoff: 0.02, cutoffTo: 0.06, attack: 1.2, release: 1.0, seed: 5)           // the wind
    band.waltz(from: i0 + 0.4, bars: 5, tune: true)
    band.choir(i0 + 0.4, 3.6, [62, 65, 69], vol: 0.02)
    band.choir(i0 + 3.6, 2.4, [61, 64, 69], vol: 0.03)
    for k in 0..<8 { m.step(i0 + 3.4 + Double(k) * 0.12, vol: 0.05) }                           // the spider's feet
    band.boing(i0 + 5.45, vol: 0.05)
    for (k, n) in [74, 77, 81, 86, 89, 93].enumerated() { band.celesta(i0 + 5.7 + Double(k) * 0.07, n, vol: 0.05) }
    let logo = i0 + 6.3
    m.boom(logo, vol: 0.4)
    band.choir(logo, 2.2, [50, 62, 65, 69, 74], vol: 0.035)
    band.tuba(logo, 26, 1.6, vol: 0.18)
    m.whoosh(i0 + 8.2, 1.0, vol: 0.14)
    m.tone(i0 + 7.9, 1.0, 200, to: 2600, wave: .saw, vol: 0.04, attack: 0.4, release: 0.1)
    // the set piece: theremins, zaps and splats, cheering, the scare, Ack! Ack!, the yodel, the pops, Beetlejooce
    let inv = start("invasion")
    band.waltz(from: inv + 0.2, bars: 8, tune: false, vol: 0.7)
    for (i, s) in bzSaucers.indices.enumerated() {
        band.theremin(inv + 0.3 + Double(s) * 0.3, 1.6, from: 900 + Double(i) * 120, to: 420, vol: 0.04)
    }
    var z = inv + 1.1
    while z < inv + bzBeamDown { band.martianZap(z, vol: 0.045); band.splat(z + 0.1, vol: 0.06); z += 0.2 }
    for k in 0..<10 { m.click(inv + 1.1 + Double(k) * 0.17, vol: 0.05) }                         // cheering claps
    band.theremin(inv + bzBeamDown, 0.9, from: 300, to: 1200, vol: 0.05)
    // the scare
    m.noise(inv + bzScare, 1.4, vol: 0.08, cutoff: 0.03, cutoffTo: 0.12, attack: 0.3, release: 0.4, seed: 21)
    m.tone(inv + bzScare, 1.4, 70, to: 55, wave: .saw, vol: 0.08, attack: 0.2, release: 0.4)
    for (k, s) in [0.0, 0.2, 0.55, 0.75].enumerated() {                                                  // Ack! Ack!
        m.tone(inv + bzScare + 0.9 + s, 0.14, k % 2 == 0 ? 1300 : 1000, wave: .square(0.5), vol: 0.05, release: 0.04)
    }
    z = inv + bzScare + 0.6
    while z < inv + bzRecord { band.martianZap(z, vol: 0.04); z += 0.33 }
    for k in 0..<6 { m.step(inv + bzGran + Double(k) * 0.15, vol: 0.06) }
    m.click(inv + bzRecord - 0.1, vol: 0.08)
    band.yodel(inv + bzRecord, bzPops[2] + 0.5 - bzRecord, vol: 0.055)
    for at in bzPops { m.pop(inv + at, step: 2, vol: 0.14); band.splat(inv + at + 0.05, vol: 0.12) }
    band.boing(inv + bzJooce, vol: 0.1); band.splat(inv + bzJooce + 0.05, vol: 0.14)
    for n in [50, 57, 62, 65] {                                                                    // the brass stab
        m.tone(inv + bzJooce + 0.7, 0.5, midi(n), wave: .saw, vol: 0.04, release: 0.2)
    }
    // the app shots: the shared groove, and each shot's effects
    groove(m, from: start("hook"), to: start("endcard"), fadeIn: 1.2)
    let hook = start("hook")
    for i in 0..<26 { m.click(hook + 0.2 + Double(i) * 0.13 + noise(i) * 0.06) }
    let desk = start("desktop"), deskEnd = end("desktop") + 1.3
    for (i, d) in [0.0, 0.12, 0.24, 0.32].enumerated() { m.step(desk + d + 0.3, vol: 0.1 + Double(i % 2) * 0.03) }
    for t in shotTimes(desk + 0.45, deskEnd, offset: 0) { m.pew(t, vol: 0.06) }
    let st = start("status")
    for i in 0..<4 { m.pop(st + 0.1 + Double(i) * 0.22, step: i) }
    for k in 0..<5 { m.tone(st + 1.2 + Double(k) * 0.62, 0.08, 1568, wave: .square(0.5), vol: 0.035, release: 0.03) }
    let ag = start("agents")
    for k in 0..<14 { m.step(ag + Double(k) * 0.125, vol: 0.06) }
    let wi = start("window")
    for k in [0.9, 1.8] { m.click(wi + k, vol: 0.06) }
    m.ping(wi + 2.5)
    let ais = start("ais")
    for i in 0..<6 { m.pop(ais + 0.15 + Double(i) * 0.1, step: i % 4) }
    for s in shots { transitionSound(m, s) }
    // the end card: two bars of the waltz, the choir, the hit, a last celesta run and the tuba
    let ec = start("endcard")
    band.waltz(from: ec, bars: 2, tune: true, vol: 0.8)
    band.choir(ec + 0.35, 3.4, [50, 62, 65, 69, 74], vol: 0.035)
    m.boom(ec + 0.35, vol: 0.4)
    for (k, n) in [74, 77, 81, 86].enumerated() { band.celesta(ec + 2.6 + Double(k) * 0.09, n, vol: 0.05) }
    band.tuba(ec + 2.52, 26, 1.6, vol: 0.16)
}
