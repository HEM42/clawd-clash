import AppKit
import CoreText

// The Star Clawds trailer: `REEL=starclawds build/renderpromo video promo` → promo/star-clawds-promo.mp4.
// Drawn with RenderPromo's kit (Tools/RenderPromo/Kit: `Shot`, `brawl`, `windowShot`, `everyAI`, `Mix`…) and compiled
// only into that tool.

/// The Star Clawds trailer, as the tool asks for it.
struct StarClawdsReel: PromoReel {
    let name = "starclawds", base = "star-clawds-promo", small = "Star-Clawds"
    let title = "STAR CLAWDS"
    var geminiTask: String { "gemini ▸ add a \(Cast.hero(StarClawdsHero.tauntaun).name.lowercased())" }
    var shots: [Shot] { starClawdsShots }
    var beats: [(key: Double, beat: Beat)] { starClawdsBeats }
    var universe: Universe { .starWars }
    var brawl: BrawlCast {
        BrawlCast(claude: .villain(StarClawdsVillain.vader), other: .hero(StarClawdsHero.luke),
                  agent: .hero(StarClawdsHero.han), otherAgent: .villain(StarClawdsVillain.trooper),
                  line: "One app. Three universes.",
                  sub: "Star Clawds: laser swords, blasters, 81 characters in 22 places.")
    }
    var window: WindowCast {
        WindowCast(place: .cantina, claude: .villain(StarClawdsVillain.vader), other: .hero(StarClawdsHero.luke),
                   agentA: .hero(StarClawdsHero.han), agentB: .hero(StarClawdsHero.chewie), extra: .hero(StarClawdsHero.r2d2),
                   prompt: "You: “make the cape swish more”", otherPrompt: "You: “make the hero section pop”")
    }
    func sound(_ m: Mix) { starClawdsSound(m) }
}

// MARK: The Star Clawds showcase (in its trailer, and on the promo's comic page)

/// Deep-space starfield; `shift` moves it up (the camera tilting down).
private func starfield(_ c: PixelCanvas, shift: Double = 0, t: Double) {
    for i in 0..<260 {
        let x = Int(noise(i * 5) * Double(c.w))
        let y = Int((noise(i * 5 + 1) * Double(c.h + 120) - shift).rounded()) - 0
        guard y >= 0, y < c.h else { continue }
        let b = noise(i * 5 + 2)
        let tw = 0.75 + 0.25 * sin(t * 4 + Double(i))
        if b > 0.93 {                                   // a few bright ones with a little cross
            c.px(x, y, C(0xFFFFFF, tw)); c.px(x - 1, y, C(0xBFD8FF, 0.5 * tw)); c.px(x + 1, y, C(0xBFD8FF, 0.5 * tw))
            c.px(x, y - 1, C(0xBFD8FF, 0.5 * tw)); c.px(x, y + 1, C(0xBFD8FF, 0.5 * tw))
        } else {
            c.px(x, y, C(0xFFFFFF, (0.25 + b * 0.5) * tw))
        }
    }
}

/// Tatooine rising from the bottom of the frame, with its two moons. `rise` 0…1 brings it into view.
private func tatooine(_ c: PixelCanvas, rise: Double) {
    let r = 330.0, cx = 205.0, cy = Double(c.h) + r - 34 - (1 - rise) * 70
    let bands = [C(0xE2B77A), C(0xD8A465), C(0xC98F52), C(0xDDAE70), C(0xB97C44), C(0xD39C5E)]
    for y in min(c.h, max(0, Int(cy - r)))..<c.h {
        let dy = Double(y) - cy
        let half = max(0, r * r - dy * dy).squareRoot()
        let x0 = max(0, Int(cx - half)), x1 = min(c.w - 1, Int(cx + half))
        guard x0 <= x1 else { continue }
        for x in x0...x1 {
            let dx = Double(x) - cx
            let lat = Int((dy + r) / 9 + noise(x / 7 + y * 3) * 1.2) % bands.count
            var col = bands[lat]
            // the night side to the left, dithered at the terminator
            let shade = (dx + r * 0.35) / (r * 0.6)
            if shade < 0 || (shade < 0.1 && (x + y) % 2 == 0) { col = C(0x3A2416) }
            else if shade < 0.2 && (x + y) % 3 == 0 { col = C(0x7A4E2C) }
            // thin bright atmosphere at the limb
            if hypot(dx, dy) > r - 1.5 && shade > 0 { col = C(0xF6E2B8) }
            c.px(x, y, col)
        }
    }
    // the two moons, up and to the left of the planet
    for (mx, my, mr) in [(70.0, cy - r - 40 + 30 * rise, 9.0), (98.0, cy - r - 18 + 30 * rise, 5.0)] {
        for y in Int(my - mr)...Int(my + mr) {
            for x in Int(mx - mr)...Int(mx + mr) where hypot(Double(x) - mx, Double(y) - my) <= mr && y >= 0 && y < c.h {
                let lit = Double(x) - mx > -mr * 0.2
                c.px(x, y, lit ? C(0xD9D2C4) : C(0x4A4640))
            }
        }
    }
}

/// The Tantive IV seen from behind as it flees: engine bank at the top, hammerhead nose at the bottom.
private let tantiveRows = [
    "..EEEEEEEEE..",
    ".EEEEEEEEEEE.",
    ".HHHHHHHHHHH.",
    "HHHHHHHHHHHHH",
    "HHDHHDHHDHHDH",
    ".HHHHHHHHHHH.",
    "...HHHHHHH...",
    "....HHHHH....",
    "....HLHLH....",
    "....HHHHH....",
    "....HLHLH....",
    "....HHHHH....",
    "...HHHHHHH...",
    "..HHHHHHHHH..",
    "..HLLHHHLLH..",
    "..HHHHHHHHH..",
    "...HHHHHHH...",
    "....HHHHH....",
    ".....HWH.....",
    "......H......",
]

private func tantive(t: Double) -> PixelCanvas {
    let c = PixelCanvas(15, tantiveRows.count + 2)
    c.pattern(1, 1, tantiveRows, ["H": C(0xD6D4CC), "D": C(0x8A8880), "L": C(0x6FA0D0), "W": C(0xFFFFFF),
                                  "E": C(0xFFC8D0, 0.75 + 0.25 * sin(t * 30))])
    c.addOutline(C(0xFFFFFF, 0.92))
    return c
}

/// The Star Destroyer seen from below, nose pointing the way it flies (down the frame). `tipY` is the row of
/// its nose; the hull reaches `length` rows back up to the engine block.
private let sdLength = 300.0, sdHalf = 190.0, sdX = 165.0

private func starDestroyer(_ c: PixelCanvas, tipY: Double, t: Double) {
    let base = tipY - sdLength
    let lit = [C(0xA9ABB0), C(0x9A9CA2), C(0xB9BBC0)], shade = [C(0x8F9197), C(0x82848A), C(0x9C9EA4)]
    for y in min(c.h, max(0, Int(base) - 18))..<max(min(c.h, max(0, Int(base) - 18)), min(c.h, Int(tipY) + 1)) {
        let back = tipY - Double(y)                       // rows behind the nose
        if back > sdLength {                              // the engine block behind the hull
            let hw = sdHalf * 0.8
            let x0 = max(0, Int(sdX - hw)), x1 = min(c.w - 1, Int(sdX + hw))
            guard x0 <= x1 else { continue }
            for x in x0...x1 {
                let g = noise(y * 211 + x * 13)
                c.px(x, y, g > 0.9 ? C(0x6A6C72) : (x % 7 == 0 ? C(0x45474C) : C(0x55575D)))
            }
            continue
        }
        let hw = back * sdHalf / sdLength
        guard hw >= 0.5 else { c.px(Int(sdX), y, C(0xC9CBD0)); continue }
        let row = Int(back), band = row / 10
        let segW = 5 + Int(noise(band * 17) * 8)
        let x0 = max(0, Int(sdX - hw)), x1 = min(c.w - 1, Int(sdX + hw))
        guard x0 <= x1 else { continue }
        for x in x0...x1 {
            let dx = Double(x) - sdX, edge = hw - abs(dx)
            let seg = (x + 400) / segW
            let tone = noise(band * 131 + seg)
            let pal = dx < 0 ? lit : shade                                 // lit from the left
            var col = tone < 0.15 ? pal[1] : (tone > 0.85 ? pal[2] : pal[0])
            if (x + 400) % segW == 0 && edge > 3 { col = C(0x74767C) }      // plate seams
            if row % 10 == 0 && edge > 3 { col = C(0x6A6C72) }
            let g = noise(row * 313 + x * 7)
            if edge > 8 && g > 0.996 { col = C(0x55575D) } else if edge > 8 && g > 0.992 { col = C(0xD4D6DA) }   // greebles
            if edge >= 6 && edge < 7 { col = C(0x5E6066) }                 // trench along each edge
            if edge < 2.5 { col = dx < 0 ? C(0xD0D2D6) : C(0x6E7076) }     // bevelled rims
            if abs(dx) < 1.5 { col = C(0x6E7076) }                         // keel line
            if row > 118 && row < 150 && abs(dx) < 16 {                     // the docking bay
                col = (row == 119 || row == 149 || abs(dx) > 14.5) ? C(0x8A8C92) : C(0x24262A)
            }
            c.px(x, y, col)
        }
        // running lights along the edges
        if row % 18 == 7 {
            let on = sin(t * 6 + Double(row)) > 0
            c.px(Int(sdX - hw) + 3, y, on ? C(0xFFFFFF) : C(0x9FA3AA)); c.px(Int(sdX + hw) - 3, y, on ? C(0xFFFFFF) : C(0x9FA3AA))
        }
    }
    // three big engines glowing at the back, flickering
    let ey = Int(base) - 18
    for (k, ex) in [sdX - 80, sdX, sdX + 80].enumerated() {
        let r = (k == 1 ? 13.0 : 10.0) + sin(t * 25 + Double(k)) * 0.6
        for y in (ey - Int(r))...(ey + Int(r)) where y >= 0 && y < c.h {
            for x in Int(ex - r)...Int(ex + r) where x >= 0 && x < c.w {
                let d = hypot(Double(x) - ex, Double(y - ey))
                if d <= r { c.px(x, y, d < r * 0.45 ? C(0xFFFFFF) : (d < r * 0.75 ? C(0xBFE0FF) : C(0x6FB8FF))) }
            }
        }
    }
}

/// The chase: where the Tantive IV is at shot-local time `l` (fx units) and how big.
private func tantivePos(_ l: Double) -> (x: Double, y: Double, k: Double) {
    let f = easeOut((l - 1.6) / 3.0)
    return (lerp(186, 150, f) + sin(l * 2.3) * 3, lerp(-28, 118, f) + (l > 4.6 ? (l - 4.6) * 3 : 0), lerp(1.4, 0.7, clamp((l - 1.6) / 6)))
}

private func destroyerTip(_ l: Double) -> Double { -4 + (l - 3.0) * 85 }

func starClawdsShowcase(_ ctx: CGContext, local l: Double, t: Double) {
    let tilt = easeOut((l - 0.2) / 1.6)
    let sky = PixelCanvas(fxW, fxH)
    sky.rect(0, 0, fxW, fxH, C(0x000000))
    starfield(sky, shift: 60 * tilt, t: t)
    tatooine(sky, rise: tilt)
    blit(sky, ctx)
    // the blockade runner, behind the destroyer
    let p = tantivePos(l)
    if l > 1.4 && l < 6.5 {                    // swallowed by the destroyer after that
        let tc = tantive(t: t)
        if let img = tc.makeImage() {
            let s = 6 * p.k
            ctx.saveGState(); ctx.interpolationQuality = .none
            ctx.draw(img, in: CGRect(x: p.x * 6 - Double(tc.w) * s / 2, y: Double(H) - (p.y * 6 + Double(tc.h) * s / 2),
                                     width: Double(tc.w) * s, height: Double(tc.h) * s))
            ctx.restoreGState()
        }
    }
    // the destroyer, closest to us
    let tip = destroyerTip(min(l, 7.05))      // it comes to rest with its engines at the top
    let fx = PixelCanvas(fxW, fxH)
    if tip > -2 {
        starDestroyer(fx, tipY: tip, t: t)
        fx.addOutline(C(0xFFFFFF, 0.92))
    }
    // red turbolaser bolts chasing the runner: from off the top at first, then from the destroyer's nose
    for i in 0..<40 {
        let born = 1.3 + Double(i) * 0.17
        let age = l - born
        guard age > 0, age < 0.55 else { continue }
        let tipAt = destroyerTip(born)
        let from = tipAt > 4 ? (sdX + (noise(i * 7) - 0.5) * 30, tipAt - noise(i * 7 + 1) * 20) : (150 + noise(i * 7) * 70, -4.0)
        let aim = tantivePos(born + 0.45)
        let miss = (noise(i * 7 + 2) - 0.5) * 34
        let to = (aim.x + miss, aim.y + abs(miss) * 0.3)
        let g = age / 0.55
        let x = lerp(from.0, to.0, g), y = lerp(from.1, to.1, g)
        let len = hypot(to.0 - from.0, to.1 - from.1)
        let ux = (to.0 - from.0) / max(len, 0.01), uy = (to.1 - from.1) / max(len, 0.01)
        fx.glowLine(x - ux * 7, y - uy * 7, x, y, core: C(0xFFE0E0), glow: C(0xFF2A2A), coreR: 0.6, glowR: 1.8)
        if g > 0.92 && abs(miss) < 8 { drawSparks(fx, x: to.0, y: to.1, t: t, size: 3) }
    }
    blit(fx, ctx)
}

// MARK: The boarding (Star Clawds): the door blows, Stormtroupers pour in, Darth Vapor steps through the smoke

private let doorX = 268.0, doorW = 46.0, doorTop = 62.0       // the blast door at the end of the corridor (fx units)
private let blowAt = 1.6

private func boarding(_ ctx: CGContext, local l: Double, t: Double) {
    let since = l - blowAt
    if since > 0 && since < 0.5 { let sh = (0.5 - since) * 40; ctx.translateBy(x: sin(t * 90) * sh, y: cos(t * 80) * sh) }   // the blast shakes the frame
    set(ctx, .tantive, t: t)
    let fx = PixelCanvas(fxW, fxH)
    let floorRow = Int(stageGroundRow) - 4
    // the door and its frame; before it blows, its seams glow hotter and hotter
    fx.rect(Int(doorX) - 4, Int(doorTop) - 4, Int(doorW) + 8, floorRow - Int(doorTop) + 4, C(0x7A808C))
    if l < blowAt {
        fx.rect(Int(doorX), Int(doorTop), Int(doorW), floorRow - Int(doorTop), C(0x9AA0AA))
        for y in stride(from: Int(doorTop) + 8, to: floorRow, by: 14) { fx.rect(Int(doorX) + 3, y, Int(doorW) - 6, 2, C(0x80868F)) }
        let heat = clamp((l - 0.5) / (blowAt - 0.5))
        if heat > 0 {
            let glow = C(0xFF8A2A, 0.35 + 0.6 * heat * (0.75 + 0.25 * sin(t * 30)))
            fx.rect(Int(doorX), Int(doorTop), Int(doorW), 2, glow); fx.rect(Int(doorX), floorRow - 2, Int(doorW), 2, glow)
            fx.rect(Int(doorX), Int(doorTop), 2, floorRow - Int(doorTop), glow); fx.rect(Int(doorX + doorW) - 2, Int(doorTop), 2, floorRow - Int(doorTop), glow)
            fx.rect(Int(doorX + doorW / 2) - 1, Int(doorTop), 2, floorRow - Int(doorTop), glow)
        }
    } else {
        fx.rect(Int(doorX), Int(doorTop), Int(doorW), floorRow - Int(doorTop), C(0x23262C))   // the hole, dark beyond
        for i in 0..<5 { fx.rect(Int(doorX) + 2 + i * 9, floorRow - 4 - Int(noise(i) * 6), 6, 4 + Int(noise(i) * 6), C(0x6A707A)) }   // wreckage
    }
    blit(fx, ctx)
    // the crew: the rebels hold the corridor, the droids and the princess behind them
    let fire = l > blowAt + 0.6, retreat = clamp((l - 4.6) / 1.4)
    var wedge = Actor(cast: .hero(StarClawdsHero.wedge), x: lerp(118, -40, retreat), mode: .idle, role: fire && retreat == 0 ? .shoot(offset: 0) : .none)
    var cassius = Actor(cast: .hero(StarClawdsHero.cassian), x: lerp(150, -20, retreat), mode: .idle, role: fire && retreat == 0 ? .shoot(offset: blasterPeriod / 2) : .none)
    wedge.walking = retreat > 0 && retreat < 1; cassius.walking = wedge.walking
    let away = clamp((l - 3.6) / 1.6)
    var laya = Actor(cast: .hero(StarClawdsHero.leia), x: lerp(70, -30, away), facing: away > 0 ? -1 : 1, mode: .idle); laya.walking = away > 0 && away < 1
    var r2 = Actor(cast: .hero(StarClawdsHero.r2d2), x: lerp(36, -50, away), facing: away > 0 ? -1 : 1, session: false, mode: .idle); r2.walking = laya.walking
    var c3 = Actor(cast: .hero(StarClawdsHero.c3po), x: lerp(16, -60, clamp((l - 6.6) / 0.9)), facing: l > 6.6 ? -1 : 1, mode: .idle); c3.walking = l > 6.6 && l < 7.5
    // the Stormtroupers, through the smoke one after another, firing as they come
    var troopers: [Actor] = []
    for i in 0..<5 {
        let at = blowAt + 0.35 + Double(i) * 0.32
        guard l > at else { continue }
        let f = easeOut((l - at) / 0.8), stop = [250.0, 218, 282, 190, 236][i]
        var tr = Actor(cast: .villain(StarClawdsVillain.trooper), x: lerp(doorX + 22, stop, f), facing: -1, mode: .idle,
                       role: f > 0.95 && retreat < 1 ? .shoot(offset: Double(i) * 0.17) : .none)
        tr.walking = f < 0.95
        troopers.append(tr)
    }
    // Darth Vapor, last through, slow
    let vf = clamp((l - 4.2) / 1.8)
    var vapor = Actor(cast: .villain(StarClawdsVillain.vader), x: lerp(doorX + 22, 148, easeOut(vf)), facing: -1, mode: .idle)
    vapor.walking = vf > 0 && vf < 1
    for a in [c3, r2, laya] { draw(a, ctx, t: t) }
    for a in troopers.reversed() { draw(a, ctx, t: t) }
    if l > 4.2 { draw(vapor, ctx, t: t) }
    for a in [cassius, wedge] { draw(a, ctx, t: t) }
    // the firefight: each rebel against a trouper
    var pairs: [(Actor, Actor)] = []
    if troopers.count > 1 && retreat == 0 { pairs = [(wedge, troopers[0]), (cassius, troopers[1])] }
    if troopers.count > 3 && retreat == 0 { pairs += [(wedge, troopers[3])] }
    drawFX(pairs, ctx, t: t)
    // the blast: a white flash, flying debris, then smoke rolling out of the doorway and thinning
    if since > 0 {
        let smoke = PixelCanvas(fxW, fxH)
        for i in 0..<18 {
            let a = noise(i * 3) * .pi - .pi / 2, sp = 16 + noise(i * 3 + 1) * 40
            let r = 6 + since * (6 + noise(i) * 8), fade = max(0, 0.75 - since * 0.18)
            let x = doorX + doorW / 2 - cos(a) * since * sp * 0.6, y = (doorTop + Double(floorRow)) / 2 + sin(a) * since * sp * 0.3
            smoke.circle(Int(x), Int(y), Int(r), C(noise(i + 7) > 0.5 ? 0xC8CCD2 : 0x9AA0AA, fade))
        }
        if since < 0.7 {
            for i in 0..<30 {
                let a = noise(i * 5) * 2 * .pi, d = since * (60 + noise(i * 5 + 1) * 90)
                smoke.rect(Int(doorX + doorW / 2 - abs(cos(a)) * d), Int(doorTop + 40 + sin(a) * d * 0.6 + since * since * 40), 2, 2, C(0x5A606A))
            }
        }
        blit(smoke, ctx)
        if since < 0.3 { ctx.setFillColor(CGColor(gray: 1, alpha: 0.8 * (1 - since / 0.3))); ctx.fill(fullRect) }
    }
    if l > 5.0 && l < 6.9 { balloon("I'd like to formally object to all of this.", ctx, center: CGPoint(x: 520, y: 760), tail: headPoint(c3), size: 38, width: 640) }
}

// MARK: The Star Clawds trailer (the old Clawd Wars trailer, rebuilt on Clawd Clash)

let starClawdsShots: [Shot] = [
    // The film's opening line, reworded for terminals, in that blue, on black.
    Shot(name: "longago", start: 0, end: 3.5, into: .cut) { ctx, local, t in
        ctx.setFillColor(CGColor(gray: 0, alpha: 1)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let a = clamp(local / 0.6) * (1 - clamp((local - 2.7) / 0.6))
        let blue = NSColor(srgbRed: 0.29, green: 0.84, blue: 0.93, alpha: a)
        for (i, line) in ["A long time ago, in a terminal", "far, far away...."].enumerated() {
            NSAttributedString(string: line, attributes: [.font: NSFont.systemFont(ofSize: 60, weight: .regular), .foregroundColor: blue])
                .draw(at: NSPoint(x: 520, y: 580 - Double(i) * 84))
        }
    },
    // STAR CLAWDS, outlined in yellow, falling away into the stars.
    Shot(name: "logo", start: 3.5, end: 7.0, into: .cut) { ctx, local, t in
        let sky = PixelCanvas(fxW, fxH)
        sky.rect(0, 0, fxW, fxH, C(0x000000)); starfield(sky, t: t); blit(sky, ctx)
        let p = clamp(local / 3.5), s = 2.4 * exp(-3.4 * p), a = 1 - clamp((p - 0.8) / 0.2)
        let tf = NSFont(name: "Futura-CondensedExtraBold", size: 260) ?? .systemFont(ofSize: 240, weight: .black)
        ctx.saveGState()
        ctx.translateBy(x: Double(W) / 2, y: Double(H) / 2); ctx.scaleBy(x: s, y: s)
        for (i, word) in ["STAR", "CLAWDS"].enumerated() {
            let w = NSAttributedString(string: word, attributes: [.font: tf, .kern: 20, .strokeWidth: 3, .strokeColor: yellow.withAlphaComponent(a)])
            let sz = w.size()
            w.draw(at: NSPoint(x: -sz.width / 2, y: i == 0 ? 0 : -sz.height * 0.82))
        }
        ctx.restoreGState()
    },
    // Tilt down to the desert planet: the blockade runner flees, the giant ship slides in overhead.
    Shot(name: "destroyer", start: 7.0, end: 15.5, into: .cut) { ctx, local, t in starClawdsShowcase(ctx, local: local, t: t) },
    // Aboard the blockade runner: the door blows, the Stormtroupers pour in, Darth Vapor steps through.
    Shot(name: "boarding", start: 15.5, end: 23.0, into: .starWars(clock: false)) { ctx, local, t in boarding(ctx, local: local, t: t) },
    Shot(name: "hook", start: 23.0, end: 27.0) { ctx, local, t in
        let zoom = 1 + 0.03 * local
        ctx.saveGState()
        ctx.translateBy(x: Double(W) / 2, y: Double(H) / 2); ctx.scaleBy(x: zoom, y: zoom); ctx.translateBy(x: -Double(W) / 2, y: -Double(H) / 2)
        desktop(ctx, dim: 0)
        ctx.restoreGState()
        caption("Three AIs. Nine agents. One very confused human.", ctx, local: local, start: 0.05, y: 860, size: 60)
        caption("Sound familiar?", ctx, local: local, start: 0.7, y: 120, size: 76, color: yellow)
    },
    Shot(name: "desktop", start: 27.0, end: 31.6) { ctx, local, t in
        brawl(ctx, .starWars, local: local, t: t, drop: true, chrome: false)
        badge("DESKTOP MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Now they're a pixel-art Star Clawds brawl", ctx, local: local, start: 0.35, y: 900)
        caption("along the bottom of your screen. They fight while they work.", ctx, local: local, start: 0.6, y: 830, size: 40, color: yellow, weight: .bold)
    },
    Shot(name: "status", start: 31.6, end: 35.8) { ctx, local, t in
        let cast: [Cast] = [.villain(StarClawdsVillain.vader), .villain(StarClawdsVillain.emperor), .villain(StarClawdsVillain.boba), .villain(StarClawdsVillain.jabba)]
        statusOf(ctx, local: local, t: t, cast: cast, badgeText: "STAR CLAWDS", aside: "(Leave \(cast[2].name) waiting and he starts jumping.)")
    },
    Shot(name: "agents", start: 35.8, end: 39.8) { ctx, local, t in
        agentsOf(ctx, local: local, t: t, guardCast: .villain(StarClawdsVillain.vader),
                 crew: [.hero(StarClawdsHero.luke), .hero(StarClawdsHero.leia), .hero(StarClawdsHero.chewie), .hero(StarClawdsHero.r2d2)],
                 line: "Every subagent reports for duty.", badgeText: "STAR CLAWDS")
    },
    Shot(name: "window", start: 39.8, end: 44.6) { ctx, local, t in
        windowShot(ctx, .starWars, local: local, t: t, rise: true, needsAt: 2.5)
        badge("WINDOW MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Prefer a window? Grab the popcorn.", ctx, local: local, start: 0.1, y: 955, size: 56)
        caption("A live card per session: what it's doing, your last prompt, every agent.", ctx, local: local, start: 0.4, y: 890, size: 32, color: yellow, weight: .bold)
    },
    Shot(name: "ais", start: 44.6, end: 49.0) { ctx, local, t in
        everyAI(ctx, local: local, t: t, cast: [.villain(StarClawdsVillain.vader), .villain(StarClawdsVillain.kylo), .hero(StarClawdsHero.luke), .hero(StarClawdsHero.yoda),
                                                .hero(StarClawdsHero.leia), .hero(StarClawdsHero.r2d2), .villain(StarClawdsVillain.trooper)])
    },
    // The end card: the Millennial Falcon flies through, the crew on the horizon, the title lands.
    Shot(name: "endcard", start: 49.0, end: 53.2) { ctx, local, t in
        space(ctx, t: local)
        let fp = local / 1.1
        if fp > 0 && fp < 1 {
            let fc = PixelCanvas(Ride.width, Ride.height)
            drawRide(fc, .falcon, ramp: 0, engines: true, gear: false); fc.addOutline(C(0xFFFFFF, 0.92))
            if let img = fc.makeImage() {
                let x = lerp(-500, Double(W) + 100, easeIn(fp) * 0.6 + fp * 0.4)
                ctx.saveGState(); ctx.interpolationQuality = .none
                ctx.draw(img, in: CGRect(x: x, y: 560 + 200 * fp, width: Double(Ride.width) * 6, height: Double(Ride.height) * 6))
                ctx.restoreGState()
            }
        }
        let crew: [(Cast, FightRole, AI)] = [(.villain(StarClawdsVillain.kylo), .cheer, .desktop), (.villain(StarClawdsVillain.vader), .duel, .claude),
                                             (.hero(StarClawdsHero.luke), .duel, .codex), (.hero(StarClawdsHero.r2d2), .none, .copilot),
                                             (.hero(StarClawdsHero.yoda), .cheer, .qwen), (.hero(StarClawdsHero.leia), .none, .gemini)]
        var placed: [Actor] = []
        for (i, (who, role, ai)) in crew.enumerated() {
            var a = Actor(cast: who, x: [28.0, 80, 137, 190, 240, 290][i], facing: i < 2 ? 1 : -1, role: role, ai: ai)
            a.lift = groundY - (Double(H) - 242) / S
            a.alpha = clamp((local - 0.15 - Double(i) * 0.05) / 0.2)
            draw(a, ctx, t: t)
            placed.append(a)
        }
        if local > 0.5 { drawFX([(placed[1], placed[2])], ctx, t: t) }
        if local > 0.35 {
            let f = backOut((local - 0.35) / 0.4)
            let tf = NSFont(name: "Futura-CondensedExtraBold", size: 190) ?? .systemFont(ofSize: 170, weight: .black)
            ctx.saveGState()
            ctx.translateBy(x: Double(W) / 2, y: 700); ctx.scaleBy(x: f, y: f); ctx.translateBy(x: -Double(W) / 2, y: -700)
            text("STAR CLAWDS", ctx, y: 620, size: 190, color: yellow, font: tf, kern: 14)
            ctx.restoreGState()
        }
        caption("Have fun. Keep track.", ctx, local: local, start: 0.6, y: 540, size: 56)
        caption("One of many universes in Clawd Clash · free for macOS", ctx, local: local, start: 0.8, y: 480, size: 34,
                color: NSColor(white: 0.8, alpha: 1), weight: .bold)
        let ff = easeOut((local - 0.9) / 0.3)
        if ff > 0, let icon = appIcon {
            ctx.saveGState(); ctx.setAlpha(CGFloat(ff)); ctx.interpolationQuality = .high
            ctx.draw(icon, in: CGRect(x: 600, y: 50, width: 140, height: 140))
            ctx.restoreGState()
            text("github.com/rodclemen/clawd-clash", ctx, x: 770, y: 92, size: 44, weight: .bold, alpha: ff)
        }
    },
]

let starClawdsBeats: [(key: Double, beat: Beat)] = [
    (1.8, ("A LONG TIME AGO", "Black screen. The film's blue opening line, reworded for terminals, fades in and out.", "“A long time ago, in a terminal far, far away....”", "silence")),
    (4.4, ("THE LOGO", "Hard cut to stars. STAR CLAWDS, outlined in yellow, starts bigger than the screen and falls away into the starfield.", "STAR CLAWDS", "big hit, then an original fanfare")),
    (11.2, ("THE BIG SHIP", "The camera tilts down to the desert planet; a blockade runner flees under laser fire; the giant wedge ship slides in overhead until its engines fill the top of the frame.", "no text", "a dark pulse, a turbolaser per bolt, the rumble")),
    (19.8, ("THE BOARDING", "An edge wipe into the blockade runner's white corridor. Wedge Antlers and Cassius Andoor hold it, Princess Laya, Ahh2-De2 and C-3P-Uh-Oh behind them. The blast door's seams glow, it blows in a white flash and a cloud of smoke, Stormtroupers pour through firing, the rebels fall back, and Darth Vapor steps slowly through the smoke.", "C-3P-Uh-Oh: “I'd like to formally object to all of this.”", "sizzling seams, the blast, a firefight, heavy breathing and footsteps")),
    (25.0, ("THE HOOK", "Three busy terminals, slow push-in.", "“Three AIs. Nine agents. One very confused human.”  →  “Sound familiar?”", "keyboard clicks")),
    (29.5, ("DESKTOP MODE", "Darth Vapor and Luke Skyclawder drop onto the bottom edge and duel; Han Yolo and a Stormtrouper trade shots.", "DESKTOP MODE  ·  “Now they're a pixel-art Star Clawds brawl along the bottom of your screen. They fight while they work.”", "laser swords, blasters")),
    (33.9, ("AT A GLANCE", "Four sessions pop in, each in its AI's outline: Darth Vapor working, the Emperor thinking, Boba Feta's jumping NEEDS YOU, Jabbo the Glutt napping.", "“All fun and games, and you still see everything.”  ·  “(Leave Boba Feta waiting and he starts jumping.)”", "blips, alert beeps")),
    (38.0, ("SUBAGENTS", "Darth Vapor stands guard; Luke, Princess Laya, Chewbarka and Ahh2-De2 march in with their jobs on their labels.", "“Every subagent reports for duty.”", "footsteps, a droid chirp")),
    (42.6, ("WINDOW MODE", "The window in the Mos Easy Cantina; live cards tick, then Luke's Codex card flips to NEEDS YOU.", "WINDOW MODE  ·  “Prefer a window? Grab the popcorn.”", "a ping")),
    (47.0, ("EVERY AI", "Six sessions, one per AI outline; Claude's Darth Vapor a head taller, duelling Codex's Luke.", "BRING YOUR OWN AI*  ·  “One AI plays everyone. Run two and they pick sides.”  ·  *README for the full list", "laser-sword clashes")),
    (52.0, ("END CARD", "Space: the Millennial Falcon flies through, the crew lines up on the horizon, STAR CLAWDS lands.", "STAR CLAWDS  ·  “Have fun. Keep track.”  ·  “One of many universes in Clawd Clash · free for macOS”  ·  github.com/rodclemen/clawd-clash", "a flyby, the final sting")),
]

/// The Star Clawds trailer's score and effects.
func starClawdsSound(_ m: Mix) {
    // the logo: a big hit and a fanfare
    let lg = start("logo")
    m.boom(lg, vol: 0.55); m.noise(lg, 1.6, vol: 0.12, cutoff: 0.9, decay: 0.5, highpass: true, seed: 3)
    for n in [48, 55, 60, 64, 67] { m.tone(lg, 1.1, midi(n), wave: .saw, vol: 0.05, release: 0.6, decay: 0.7) }
    for (s, d, n) in [(0.3, 0.28, 64), (0.6, 0.28, 67), (0.9, 0.85, 72), (1.8, 0.28, 71), (2.1, 0.28, 69), (2.4, 1.05, 74)] as [(Double, Double, Int)] {
        m.tone(lg + s, d, midi(n + 12), wave: .square(0.5), vol: 0.07, release: 0.08, vibrato: 0.006)
        m.tone(lg + s, d, midi(n), wave: .saw, vol: 0.05, release: 0.08)
    }
    // the big ship: a dark pulse, turbolasers, the rumble
    let sd = start("destroyer"), sde = end("destroyer") + 1.3
    for i in 0..<Int((sde - sd) / 0.25) { m.tone(sd + Double(i) * 0.25, 0.22, midi(i % 8 == 7 ? 37 : 36), wave: .square(0.25), vol: 0.05 + 0.06 * min(1, Double(i) / 30), release: 0.04) }
    for (s, chord) in [(0.0, [48, 51, 55]), (2.0, [44, 48, 51]), (4.0, [46, 50, 53]), (6.0, [48, 51, 55]), (7.0, [43, 47, 50])] {
        for n in chord { m.tone(sd + s, 1.8, midi(n), wave: .saw, vol: 0.04, attack: 0.05, release: 0.6) }
    }
    m.boom(sd + 3.0, vol: 0.4)
    m.noise(sd + 2.6, 6.5, vol: 0.32, cutoff: 0.004, cutoffTo: 0.03, attack: 3.0, release: 2.0, seed: 5)
    m.tone(sd + 2.6, 6.5, 41, wave: .sine, vol: 0.18, attack: 3.0, release: 2.0)
    for i in 0..<40 { let b = sd + 1.3 + Double(i) * 0.17; if b < sde { m.turbolaser(b, pitch: noise(i * 7) > 0.5 ? 1 : 0.8, vol: 0.07) } }
    // the boarding: the seams sizzle, the door blows, a firefight, then the breathing and the footsteps
    let bd = start("boarding")
    m.noise(bd + 0.5, blowAt - 0.5, vol: 0.06, cutoff: 0.7, attack: 0.8, release: 0.05, highpass: true, seed: 61)
    m.tone(bd + 0.5, blowAt - 0.5, 180, to: 420, wave: .saw, vol: 0.03, attack: 0.8, release: 0.05)
    m.boom(bd + blowAt, vol: 0.6); m.noise(bd + blowAt, 1.2, vol: 0.2, cutoff: 0.5, cutoffTo: 0.05, decay: 0.4, seed: 62)
    for t in shotTimes(bd + blowAt + 0.6, bd + 4.6, offset: 0) { m.pew(t, vol: 0.09) }
    for t in shotTimes(bd + blowAt + 0.6, bd + 4.6, offset: blasterPeriod / 2) { m.pew(t, vol: 0.08) }
    for i in 0..<5 { for t in shotTimes(bd + blowAt + 1.2 + Double(i) * 0.32, bd + 6.0, offset: Double(i) * 0.17) { m.pew(t, vol: 0.05) } }
    for (s, chord) in [(blowAt, [43, 46, 50]), (4.2, [41, 44, 48]), (6.0, [43, 46, 50])] {
        for n in chord { m.tone(bd + s, 1.4, midi(n), wave: .saw, vol: 0.05, attack: 0.02, release: 0.6) }
    }
    var b = 4.4
    while b < 7.6 {                                            // in and out, in and out, under a mask
        m.noise(bd + b, 0.9, vol: 0.07, cutoff: 0.08, attack: 0.3, release: 0.4, seed: Int(b * 10))
        m.noise(bd + b + 1.0, 0.9, vol: 0.05, cutoff: 0.04, attack: 0.3, release: 0.4, seed: Int(b * 10) + 1)
        b += 2.0
    }
    for k in 0..<4 { m.step(bd + 4.4 + Double(k) * 0.45, vol: 0.16) }
    for k in 0..<4 { m.step(bd + 6.6 + Double(k) * 0.12, vol: 0.05) }
    // the groove, from the hook to the end card, faded in under the wipe from the big ship
    groove(m, from: start("hook"), to: start("endcard"), fadeIn: 1.2)
    let hook = start("hook")
    for i in 0..<26 { m.click(hook + 0.2 + Double(i) * 0.13 + noise(i) * 0.06) }
    let desk = start("desktop"), deskEnd = end("desktop") + 1.3
    for (i, d) in [0.0, 0.12, 0.24, 0.32].enumerated() { m.step(desk + d + 0.3, vol: 0.1 + Double(i % 2) * 0.03) }
    m.ignite(desk + 0.45); m.hum(desk + 0.45, deskEnd - desk - 0.45)
    for t in clashTimes(desk + 0.45, deskEnd) { m.clash(t) }
    for t in shotTimes(desk + 0.45, deskEnd, offset: 0) { m.pew(t) }
    for t in shotTimes(desk + 0.45, deskEnd, offset: blasterPeriod / 2) { m.pew(t, vol: 0.12) }
    let st = start("status")
    for i in 0..<4 { m.pop(st + 0.1 + Double(i) * 0.22, step: i) }
    for k in 0..<5 { m.tone(st + 1.2 + Double(k) * 0.62, 0.08, 1568, wave: .square(0.5), vol: 0.035, release: 0.03) }
    let ag = start("agents")
    for k in 0..<14 { m.step(ag + Double(k) * 0.125, vol: 0.06) }
    m.r2(ag + 1.4)
    let wi = start("window")
    m.hum(wi, 2.5, vol: 0.02)
    for t in clashTimes(wi, wi + 2.5) { m.clash(t, vol: 0.09) }
    for k in [0.9, 1.8] { m.click(wi + k, vol: 0.06) }
    m.ping(wi + 2.5)
    let ais = start("ais")
    for i in 0..<6 { m.pop(ais + 0.15 + Double(i) * 0.1, step: i % 4) }
    m.ignite(ais + 0.3, vol: 0.12); m.hum(ais + 0.35, end("ais") - ais)
    for t in clashTimes(ais + 0.35, end("ais") + 1.3) { m.clash(t) }
    for s in shots { transitionSound(m, s) }
    let ec = start("endcard")
    for (s, d, chord, lead) in [(0.0, 0.7, [53, 57, 60, 65], 81), (0.7, 0.7, [55, 59, 62, 67], 83), (1.4, 2.8, [57, 61, 64, 69], 85)] {
        for n in chord { m.tone(ec + s, d, midi(n), wave: .saw, vol: 0.045, attack: 0.02, release: d > 1 ? 1.6 : 0.1) }
        m.tone(ec + s, d, midi(lead), wave: .square(0.5), vol: 0.06, release: d > 1 ? 1.6 : 0.1, vibrato: 0.006)
        m.tone(ec + s, d, midi(chord[0] - 24), wave: .sine, vol: 0.2, release: d > 1 ? 1.6 : 0.1)
    }
    m.boom(ec + 0.35, vol: 0.45)
    m.whoosh(ec + 0.55, 1.1, vol: 0.22); m.tone(ec, 1.1, 300, to: 900, wave: .saw, vol: 0.025, attack: 0.4, release: 0.5)
    for t in clashTimes(ec + 0.5, duration) { m.clash(t, vol: 0.12) }
}
