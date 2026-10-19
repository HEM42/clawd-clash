import AppKit
import CoreText

// The Doctor Clawd trailer: `REEL=doctor build/renderpromo video promo` → promo/doctor-clawd-promo.mp4.
// Drawn with RenderPromo's kit (Tools/RenderPromo/Kit: `Shot`, `brawl`, `windowShot`, `everyAI`, `Mix`…) and compiled
// only into that tool.

/// The Doctor Clawd trailer, as the tool asks for it.
struct DoctorReel: PromoReel {
    let name = "doctor", base = "doctor-clawd-promo", small = "Doctor-Clawd"
    let title = "DOCTOR CLAWD"
    let geminiTask = "gemini ▸ reverse the polarity"
    var shots: [Shot] { doctorShots }
    var beats: [(key: Double, beat: Beat)] { doctorBeats }
    func sound(_ m: Mix) { doctorSound(m) }
}

// MARK: The Doctor Clawd trailer

/// The vortex's palette, darkest first, and the 4×4 ordered dither between its bands.
let vortexBlues: [UInt32] = [0x060A1E, 0x0E1A4A, 0x1A3290, 0x2C56CC, 0x5A86F0, 0x9CBCFF, 0xD8E6FF]
let vortexBayer: [Double] = [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5].map { Double($0) / 15 }

/// The time vortex of the title sequence, at the frame's pixel size: a tunnel of blue cloud with streams of orange and violet
/// fire twisting through it, spiralling down to a bright eye in the middle, streaks of light flying past. `glow` 0…1 fades it
/// up from the dark.
func vortexTunnel(_ g: CGContext, t: Double, glow: Double, centre c: CGPoint) {
    let w = fxW, h = fxH
    guard let data = g.data else { return }
    let px = data.bindMemory(to: UInt8.self, capacity: g.bytesPerRow * h)
    let far = hypot(Double(w), Double(h)) / 2
    for y in 0..<h {
        for x in 0..<w {
            let dx = Double(x) - c.x, dy = (Double(h - 1 - y) - c.y) / 0.8
            let d = max(0.004, hypot(dx, dy) / far), depth = 1 / (d + 0.06)
            let a = atan2(dy, dx) + depth * 0.42 + t * 0.9                      // the twist, deeper is turned further
            let flow = depth * 1.1 - t * 3.2                                    // rushing towards us
            var cloud = 0.5 + 0.3 * sin(a * 3 + flow) + 0.2 * sin(a * 7 - flow * 1.7 + sin(flow * 0.6) * 2)
            cloud += 0.12 * sin(a * 13 + flow * 2.3)
            cloud = clamp(cloud)
            let fire = clamp((sin(a * 2 - flow * 0.8 + 1.3) - 0.55) * 2.6) * clamp(cloud * 1.6 - 0.4)
            let edge = min(1, d * 5), eye = exp(-d * 14)
            // shaded in hard bands from a small palette, with a little ordered dither between them, like the sprites
            let dither = (vortexBayer[(y % 4) * 4 + x % 4] - 0.5) * 0.18
            let lit = pow(cloud, 1.6) * edge + eye * 1.6 + dither
            var col = vortexBlues[min(vortexBlues.count - 1, max(0, Int(lit * Double(vortexBlues.count))))]
            let violet = clamp((sin(a * 2 - flow * 0.9 + 4.2) - 0.6) * 2.8) * clamp(cloud * 1.6 - 0.3)
            if violet + dither > 0.3 && eye < 0.5 { col = violet + dither > 0.75 ? 0xC48CFF : violet + dither > 0.5 ? 0x8A4ADC : 0x50248E }
            if fire + dither > 0.35 && eye < 0.5 { col = fire + dither > 0.7 ? 0xFFB15A : 0xE0782E }
            let r = Double((col >> 16) & 0xFF) / 255, gg = Double((col >> 8) & 0xFF) / 255, b = Double(col & 0xFF) / 255
            let o = y * g.bytesPerRow + x * 4
            px[o] = UInt8(clamp(r * glow) * 255); px[o + 1] = UInt8(clamp(gg * glow) * 255)
            px[o + 2] = UInt8(clamp(b * glow) * 255); px[o + 3] = 255
        }
    }
    for i in 0..<30 {                                                              // streaks flying out
        let a = noise(i * 7 + 400) * 2 * .pi + t * 0.8, d = (noise(i * 7 + 401) + t * 0.9).truncatingRemainder(dividingBy: 1)
        let r0 = d * d * far, r1 = r0 + d * far * 0.22
        g.move(to: CGPoint(x: c.x + cos(a) * r0, y: c.y + sin(a) * r0 * 0.8))
        g.addLine(to: CGPoint(x: c.x + cos(a) * r1, y: c.y + sin(a) * r1 * 0.8))
        g.setStrokeColor(hexColor(0xE8F0FF, 0.6 * glow * d)); g.setLineWidth(1); g.strokePath()
    }
}

/// A fork of lightning from the top of the frame down into the vortex's eye (pixel-size coordinates).
func vortexLightning(_ g: CGContext, seed: Int, to c: CGPoint, alpha: Double) {
    var p = CGPoint(x: c.x + (noise(seed) - 0.5) * 160, y: Double(fxH) + 4)
    g.move(to: p)
    for k in 1...9 {
        let f = Double(k) / 9
        p = CGPoint(x: lerp(p.x, c.x, f) + (noise(seed + k) - 0.5) * 26 * (1 - f), y: lerp(Double(fxH) + 4, c.y, f))
        g.addLine(to: p)
    }
    g.setStrokeColor(hexColor(0x9AC0FF, alpha * 0.6)); g.setLineWidth(3); g.strokePath()
    g.move(to: CGPoint(x: c.x + (noise(seed) - 0.5) * 160, y: Double(fxH) + 4))
    p = CGPoint(x: c.x + (noise(seed) - 0.5) * 160, y: Double(fxH) + 4)
    for k in 1...9 {
        let f = Double(k) / 9
        p = CGPoint(x: lerp(p.x, c.x, f) + (noise(seed + k) - 0.5) * 26 * (1 - f), y: lerp(Double(fxH) + 4, c.y, f))
        g.addLine(to: p)
    }
    g.setStrokeColor(hexColor(0xFFFFFF, alpha)); g.setLineWidth(1); g.strokePath()
}

/// The police box on its own, outlined, its lamp lit or not: for tumbling through the vortex.
func tumblingBox(lamp: Bool) -> CGImage? {
    let c = PixelCanvas(28, 26)
    drawPoliceBoxIcon(c)
    if !lamp { c.rect(12, 2, 4, 2, C(0x8A94A8)) }
    c.addOutline(C(0xFFFFFF, 0.85))
    return c.makeImage()
}

/// The box drawn `height` tall, centred on `p`, turned `turn` radians.
func drawBox(_ ctx: CGContext, at p: CGPoint, height h: Double, turn: Double, lamp: Bool, alpha: Double = 1) {
    guard h > 2, alpha > 0.01, let box = tumblingBox(lamp: lamp) else { return }
    ctx.saveGState(); ctx.interpolationQuality = .none
    ctx.translateBy(x: p.x, y: p.y); ctx.rotate(by: CGFloat(turn)); ctx.setAlpha(CGFloat(alpha))
    ctx.draw(box, in: CGRect(x: -h * 28 / 26 / 2, y: -h / 2, width: h * 28 / 26, height: h))
    ctx.restoreGState()
}

/// The title: DOCTOR over CLAWD in glowing silver, on a blue lozenge, in the spirit of the show's logos.
func doctorTitle(_ ctx: CGContext, center: CGPoint, scale s: Double, alpha: Double = 1) {
    guard s > 0.01, alpha > 0.01 else { return }
    ctx.saveGState()
    ctx.translateBy(x: center.x, y: center.y); ctx.scaleBy(x: s, y: s)
    ctx.setAlpha(CGFloat(alpha))
    let lozenge = CGMutablePath()
    lozenge.addLines(between: [CGPoint(x: -600, y: 0), CGPoint(x: -470, y: 165), CGPoint(x: 470, y: 165), CGPoint(x: 600, y: 0),
                               CGPoint(x: 470, y: -165), CGPoint(x: -470, y: -165)])
    lozenge.closeSubpath()
    ctx.setShadow(offset: .zero, blur: 60, color: hexColor(0x4A8CFF, 0.9))
    ctx.addPath(lozenge); ctx.setFillColor(hexColor(0x0A1A4A, 0.88)); ctx.fillPath()
    ctx.setShadow(offset: .zero, blur: 0, color: nil)
    ctx.addPath(lozenge); ctx.setStrokeColor(hexColor(0x9AC4FF)); ctx.setLineWidth(10); ctx.strokePath()
    var inner = CGAffineTransform(scaleX: 0.95, y: 0.88)
    ctx.addPath(lozenge.copy(using: &inner)!)
    ctx.setStrokeColor(hexColor(0x4A7ADA, 0.8)); ctx.setLineWidth(4); ctx.strokePath()
    let font = NSFont(name: "AvenirNextCondensed-Heavy", size: 100) ?? .systemFont(ofSize: 100, weight: .black)
    for (word, size, y, kern) in [("DOCTOR", 92.0, 38.0, 26.0), ("CLAWD", 176.0, -150.0, 14.0)] {
        let f = NSFont(descriptor: font.fontDescriptor, size: size) ?? font
        let base: [NSAttributedString.Key: Any] = [.font: f, .kern: kern]
        let sz = NSAttributedString(string: word, attributes: base).size()
        let p = NSPoint(x: -sz.width / 2 + kern / 2, y: y)
        var dark = base; dark[.foregroundColor] = NSColor(srgbRed: 0.03, green: 0.08, blue: 0.25, alpha: 1)
        let stamp = NSAttributedString(string: word, attributes: dark), r = size * 0.06
        for k in 0..<16 { let a = Double(k) / 16 * 2 * .pi; stamp.draw(at: NSPoint(x: p.x + cos(a) * r, y: p.y + sin(a) * r)) }
        var silver = base; silver[.foregroundColor] = NSColor(srgbRed: 0.80, green: 0.85, blue: 0.93, alpha: 1)
        NSAttributedString(string: word, attributes: silver).draw(at: p)
        // the shine across the top half of the letters
        ctx.saveGState()
        ctx.clip(to: CGRect(x: p.x - 20, y: p.y + sz.height * 0.48, width: sz.width + 40, height: sz.height))
        var shine = base; shine[.foregroundColor] = NSColor(srgbRed: 0.97, green: 0.98, blue: 1, alpha: 1)
        NSAttributedString(string: word, attributes: shine).draw(at: p)
        ctx.restoreGState()
    }
    ctx.restoreGState()
}

/// The title sequence: lightning, then down the time vortex with the police box tumbling past, the title swelling out
/// of the eye of it, the box diving away into the depths, and the camera plunging into the title.
func doctorIntro(_ ctx: CGContext, local l: Double, t: Double) {
    let c = CGPoint(x: Double(fxW) / 2 + sin(l * 0.7) * 14, y: Double(fxH) / 2 + cos(l * 0.5) * 6)
    let bolts: [(Double, Int)] = [(0.25, 11), (0.95, 23), (4.35, 37)]
    if let img = lowRes({ g in
        vortexTunnel(g, t: l, glow: clamp(l / 0.9) * (1 - clamp((l - 8.4) / 0.4)), centre: c)
        for (at, seed) in bolts where l > at && l < at + 0.3 { vortexLightning(g, seed: seed, to: c, alpha: 1 - (l - at) / 0.3) }
    }) { ctx.saveGState(); ctx.interpolationQuality = .none; ctx.draw(img, in: fullRect); ctx.restoreGState() }
    for (at, _) in bolts where l > at && l < at + 0.18 {                            // each bolt lights up the whole frame
        ctx.setFillColor(hexColor(0xDDE8FF, 0.5 * (1 - (l - at) / 0.18))); ctx.fill(fullRect)
    }
    let eye = CGPoint(x: c.x * 6, y: c.y * 6), lamp = Int(l * 5) % 2 == 0
    // the box comes up out of the depths, tumbling, and flies past us to the right
    if l > 0.8 && l < 4.9 {
        let f = (l - 0.8) / 4.1, z = pow(f, 2.6)
        drawBox(ctx, at: CGPoint(x: eye.x + z * 760 + sin(l * 1.4) * 30, y: eye.y + z * 160 + cos(l * 1.2) * 24),
                height: 24 + z * 1300, turn: 0.5 * sin(l * 1.5) - 0.1, lamp: lamp, alpha: clamp(f * 8))
    }
    // ...and comes back past us from behind, diving away into the eye of the vortex, behind the title
    if l > 6.0 && l < 8.0 {
        let f = (l - 6.0) / 2.0, z = pow(1 - f, 2.4)
        drawBox(ctx, at: CGPoint(x: eye.x - z * 700, y: eye.y - z * 220), height: 18 + z * 1100, turn: -l * 1.1, lamp: lamp,
                alpha: 1 - clamp((f - 0.8) / 0.2))
    }
    // the title swells out of the eye, settles, then rushes at us
    if l > 4.4 {
        let grow = backOut((l - 4.4) / 1.4), dive = easeIn((l - 7.9) / 1.0)
        doctorTitle(ctx, center: CGPoint(x: lerp(eye.x, Double(W) / 2, clamp((l - 4.4) / 1.4)), y: lerp(eye.y, Double(H) / 2, clamp((l - 4.4) / 1.4))),
                    scale: grow * 0.72 + dive * 5, alpha: clamp((l - 4.4) / 0.4))
    }
    // and it all goes white
    let white = clamp((l - 8.35) / 0.5)
    if white > 0 { ctx.setFillColor(CGColor(gray: 1, alpha: white)); ctx.fill(fullRect) }
}

/// The invasion's timings (shot-local seconds).
let dalickXs = [178.0, 216.0, 254.0, 292.0], dalickHover = [34.0, 58.0, 40.0, 64.0]
let invGround = 160.0, tardisX = 62.0
let boxIn = 3.6, doorOpen = 5.5, zapFrom = 6.5, zapEach = 0.45

/// Each Dalick: how far it has come down, whether the Doctor's sonic is on it, and how far it has fled.
func dalickState(_ i: Int, _ l: Double) -> (down: Double, zapped: Bool, fled: Double) {
    let down = easeOut((l - 0.3 - Double(i) * 0.32) / 1.3)
    let z0 = zapFrom + Double(i) * zapEach
    return (down, l > z0 && l < z0 + zapEach, easeIn((l - z0 - zapEach * 0.7) / 1.1))
}

/// London on a winter's night: a squadron of Dalicks drops out of the sky, shrieks EXTERMINATE! and rakes the street;
/// the TARDIS wheezes into being under their fire, Doctor Ten strolls out, and his sonic sends them spinning away.
func doctorInvasion(_ ctx: CGContext, local l: Double, t: Double) {
    blit(place(.christmasLondon, floorRows: 30, t: t), ctx)
    let lamp = Int(l * 5) % 2 == 0
    onStage(ctx, fullRect, scale: 6, ground: invGround) {
        let fx = PixelCanvas(fxW, fxH)
        // the TARDIS fades in and out of being, its lamp flashing, then holds; the door swings open for the Doctor
        if l > boxIn {
            let k = clamp((l - boxIn) / 1.8)
            let alpha = k >= 1 ? 1 : min(1, max(0, k * (0.75 + 0.25 * sin(k * 7 * .pi))))
            let door = clamp((l - doorOpen) / 0.25) * (1 - clamp((l - 6.3) / 0.25))
            let c = PixelCanvas(Ride.width, Ride.tardis.canvasHeight)
            drawRide(c, .tardis, ramp: door, engines: k < 1 ? lamp : true, gear: true)
            c.addOutline(C(0xFFFFFF, 0.92))
            if let img = c.makeImage() {
                ctx.saveGState(); ctx.interpolationQuality = .none; ctx.setAlpha(CGFloat(alpha))
                ctx.draw(img, in: CGRect(x: (tardisX - Double(Ride.width) / 2) * 6, y: Double(H) - invGround * 6 - 6,
                                         width: Double(Ride.width) * 6, height: Double(Ride.tardis.canvasHeight) * 6))
                ctx.restoreGState()
            }
        }
        // the Doctor steps out and strolls up to them
        var doc = Actor(cast: .hero(DoctorHero.doctorTen), x: lerp(tardisX + 4, 104, easeOut((l - 5.75) / 0.8)), facing: 1, mode: .idle)
        doc.walking = l < 6.5
        doc.alpha = clamp((l - 5.65) / 0.15)
        // the Dalicks
        var dalicks: [Actor] = []
        for i in dalickXs.indices {
            let s = dalickState(i, l)
            var d = Actor(cast: .villain(DoctorVillain.dalick), x: dalickXs[i] + s.fled * 60, facing: -1, mode: .idle)
            d.airborne = true
            d.lift = lerp(170, dalickHover[i], s.down) + s.fled * 160 + (s.zapped ? sin(t * 70) * 1.5 : 0)
            d.role = s.zapped ? .hit : .none
            d.alpha = 1 - clamp((s.fled - 0.85) / 0.15)
            dalicks.append(d)
        }
        // their fire: raking the street, then at the box as it lands
        if l > 2.7 && l < 5.4 {
            for (i, d) in dalicks.enumerated() where Int(t * 6 + Double(i) * 1.7) % 3 != 0 {
                let m = d.fighter.point(d.cast.muzzle.x, d.cast.muzzle.y)
                let atBox = l > 4.1
                let tx = atBox ? tardisX + 6 + (noise(i + Int(t * 6)) - 0.5) * 18 : 40 + frac(l * 0.45 + Double(i) * 0.23) * 220
                let ty = atBox ? invGround - 12 - noise(i * 3 + Int(t * 6)) * 18 : invGround
                fx.glowLine(m.x, m.y, tx, ty, core: C(0xF0FAFF), glow: C(0x4AB8FF), coreR: 0.6, glowR: 1.8)
                drawSparks(fx, x: tx, y: ty, t: t + Double(i), size: 3)
            }
        }
        for d in dalicks { draw(d, ctx, t: t) }
        if doc.alpha > 0 {
            // the sonic, on each Dalick in turn
            if let i = dalickXs.indices.first(where: { dalickState($0, l).zapped }) {
                doc.role = .zap
                drawFX([(doc, dalicks[i])], ctx, t: t)
            }
            draw(doc, ctx, t: t)
        }
        if let img = fx.makeImage() { ctx.saveGState(); ctx.interpolationQuality = .none; ctx.draw(img, in: fullRect); ctx.restoreGState() }
    }
    // EXTERMINATE!, shrieked
    if l > 2.2 && l < 4.0 {
        let f = easeOut((l - 2.2) / 0.15), a = 1 - clamp((l - 3.7) / 0.3)
        ctx.saveGState(); ctx.translateBy(x: sin(t * 80) * 6, y: cos(t * 67) * 4)
        text("EXTERMINATE!", ctx, y: 860, size: CGFloat(100 + 20 * (1 - f)), weight: .black,
             color: NSColor(srgbRed: 1, green: 0.32, blue: 0.24, alpha: 1), alpha: f * a, kern: 8)
        ctx.restoreGState()
    }
    // out of the white of the title sequence
    let white = 1 - clamp(l / 0.6)
    if white > 0 { ctx.setFillColor(CGColor(gray: 1, alpha: white)); ctx.fill(fullRect) }
}

let doctorShots: [Shot] = [
    // The title sequence: down the time vortex with the box, to the title.
    Shot(name: "intro", start: 0, end: 9.0, into: .cut) { ctx, local, t in doctorIntro(ctx, local: local, t: t) },
    // London at Christmas: the Dalicks invade, the TARDIS lands under fire, the Doctor sees them off.
    Shot(name: "invasion", start: 9.0, end: 18.5, into: .cut) { ctx, local, t in doctorInvasion(ctx, local: local, t: t) },
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
        brawl(ctx, .doctor, local: local, t: t, drop: true, chrome: false)
        badge("DESKTOP MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Now they're a pixel-art Doctor Clawd brawl", ctx, local: local, start: 0.35, y: 900)
        caption("along the bottom of your screen. They fight while they work.", ctx, local: local, start: 0.6, y: 830, size: 40, color: yellow, weight: .bold)
    },
    Shot(name: "status", start: 27.1, end: 31.3) { ctx, local, t in
        let cast: [Cast] = [.hero(DoctorHero.doctorEleven), .villain(DoctorVillain.master), .villain(DoctorVillain.missy), .hero(DoctorHero.donna)]
        statusOf(ctx, local: local, t: t, cast: cast, badgeText: "DOCTOR CLAWD", aside: "(\(cast[3].name), napping. Nobody wake her. Seriously.)")
    },
    Shot(name: "agents", start: 31.3, end: 35.3) { ctx, local, t in
        agentsOf(ctx, local: local, t: t, guardCast: .hero(DoctorHero.brigadier),
                 crew: [.hero(DoctorHero.rose), .hero(DoctorHero.jack), .hero(DoctorHero.kCanine), .hero(DoctorHero.martha)],
                 line: "Every subagent gets to be a companion.", badgeText: "DOCTOR CLAWD")
    },
    Shot(name: "window", start: 35.3, end: 40.1) { ctx, local, t in
        windowShot(ctx, .doctor, local: local, t: t, rise: true, needsAt: 2.5, at: .consoleRoom)
        badge("WINDOW MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Prefer a window? It's bigger on the inside.", ctx, local: local, start: 0.1, y: 955, size: 56)
        caption("A live card per session: what it's doing, your last prompt, every agent.", ctx, local: local, start: 0.4, y: 890, size: 32, color: yellow, weight: .bold)
    },
    Shot(name: "ais", start: 40.1, end: 44.5) { ctx, local, t in
        everyAI(ctx, local: local, t: t, cast: [.hero(DoctorHero.doctorTen), .hero(DoctorHero.doctorThirteen), .villain(DoctorVillain.dalick),
                                                .villain(DoctorVillain.cyberperson), .villain(DoctorVillain.weepingAngle), .villain(DoctorVillain.master),
                                                .villain(DoctorVillain.sontaron)])
    },
    // The end card: the console room, the crew lines up, the title lands.
    Shot(name: "endcard", start: 44.5, end: 48.7) { ctx, local, t in
        blit(place(.consoleRoom, floorRows: 34, t: t), ctx)
        ctx.setFillColor(CGColor(gray: 0, alpha: 0.3)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let crew: [(Cast, FightRole, AI)] = [(.hero(DoctorHero.rose), .cheer, .desktop), (.hero(DoctorHero.doctorTen), .zap, .claude),
                                             (.villain(DoctorVillain.dalick), .hit, .codex), (.villain(DoctorVillain.cyberperson), .none, .copilot),
                                             (.villain(DoctorVillain.master), .cheer, .qwen), (.villain(DoctorVillain.weepingAngle), .none, .gemini)]
        var placed: [Actor] = []
        for (i, (who, role, ai)) in crew.enumerated() {
            var a = Actor(cast: who, x: [28.0, 84, 156, 206, 252, 296][i], facing: i < 2 ? 1 : -1, role: role, ai: ai)
            a.lift = 8
            a.alpha = clamp((local - 0.15 - Double(i) * 0.05) / 0.2)
            draw(a, ctx, t: t)
            placed.append(a)
        }
        if local > 0.5 { drawFX([(placed[1], placed[2])], ctx, t: t) }
        if local > 0.35 { doctorTitle(ctx, center: CGPoint(x: Double(W) / 2, y: 760), scale: backOut((local - 0.35) / 0.4) * 0.62) }
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

let doctorBeats: [(key: Double, beat: Beat)] = [
    (2.2, ("THE TITLE SEQUENCE", "Lightning cracks into the dark, and we fall down the time vortex, a tunnel of blue and orange cloud spiralling round a bright eye. The police box comes tumbling up out of the depths, lamp flashing, and sweeps past us.", "no text", "a plucked galloping bass, swells of wind and a wobbly swooping lead, in the sound of the old electronic theme but our own notes; thunder")),
    (6.6, ("THE TITLE", "A last bolt, and DOCTOR / CLAWD swells out of the eye of the vortex in glowing silver on a blue lozenge. The box flies back past us and dives away into the depths behind it; then the camera plunges into the title and everything goes white.", "DOCTOR CLAWD", "the theme's big hit, a rising sweep into the white")),
    (12.0, ("THE INVASION", "Out of the white into London on a winter's night: four Dalicks drop out of the sky in formation, shriek EXTERMINATE! and rake the street with their beams.", "EXTERMINATE!", "a pulsing drone, the robot shriek, Dalick beams")),
    (14.0, ("THE TARDIS LANDS", "The TARDIS wheezes into being right under their fire, its lamp flashing, beams sparking off it.", "no text", "the grinding wheeze, sparks")),
    (16.4, ("ALLONS-Y", "The door swings open, Doctor Ten strolls out, raises his sonic screwdriver and zaps each Dalick in turn; they spin away into the sky.", "no text", "footsteps, the sonic's warble, each Dalick whirring off")),
    (20.0, ("THE HOOK", "Three busy terminals, slow push-in.", "“Three AIs. Nine agents. One very confused human.”  →  “Sound familiar?”", "keyboard clicks")),
    (24.8, ("DESKTOP MODE", "Doctor Ten's sonic on a Dalick; River Tune trades shots with a Sontaron.", "DESKTOP MODE  ·  “Now they're a pixel-art Doctor Clawd brawl along the bottom of your screen. They fight while they work.”", "the sonic, shots")),
    (29.4, ("AT A GLANCE", "Doctor Eleven working, the Master thinking, Missy's jumping NEEDS YOU, Donna Nobble sat down napping.", "“All fun and games, and you still see everything.”  ·  “(Donna Nobble, napping. Nobody wake her. Seriously.)”", "blips, alert beeps")),
    (33.5, ("SUBAGENTS", "The Brigadier stands guard; Rose, Captain Jack, K-Canine and Martha arrive with their jobs on their labels.", "“Every subagent gets to be a companion.”", "footsteps")),
    (38.1, ("WINDOW MODE", "The window in the Console Room: Doctor Ten against a Dalick, live cards tick, then the Dalick's Codex card flips to NEEDS YOU.", "WINDOW MODE  ·  “Prefer a window? It's bigger on the inside.”", "a ping")),
    (42.5, ("EVERY AI", "Six sessions, one per AI outline; Claude's Doctor Ten a head taller, his sonic on Codex's Dalick.", "BRING YOUR OWN AI*  ·  “One AI plays everyone. Run two and they pick sides.”  ·  *README for the full list", "the sonic")),
    (47.5, ("END CARD", "The console room: the crew lines up, DOCTOR CLAWD lands.", "DOCTOR CLAWD  ·  “Have fun. Keep track.”  ·  “One of many universes in Clawd Clash · free for macOS”  ·  github.com/rodclemen/clawd-clash", "the wheeze, the final sting")),
]

extension Mix {

    /// The sonic screwdriver's warble.
    func sonic(_ t: Double, _ dur: Double, vol: Double = 0.05) {
        tone(t, dur, 2100, to: 2350, wave: .sine, vol: vol, attack: 0.03, release: 0.06, vibrato: 0.05)
        tone(t, dur, 1050, to: 1175, wave: .triangle, vol: vol * 0.4, attack: 0.03, release: 0.06, vibrato: 0.05)
    }
    /// A Dalick's beam.
    func dalickBeam(_ t: Double, vol: Double = 0.06) {
        tone(t, 0.22, 1400, to: 500, wave: .saw, vol: vol, release: 0.08)
        noise(t, 0.2, vol: vol * 0.6, cutoff: 0.5, decay: 0.08, highpass: true, seed: Int(t * 311))
    }
    /// EX-TER-MI-NATE!, in a grating robot shriek.
    func exterminate(_ t: Double, vol: Double = 0.09) {
        for (s, d, f) in [(0.0, 0.16, 330.0), (0.2, 0.16, 370.0), (0.4, 0.16, 415.0), (0.6, 0.55, 520.0)] {
            tone(t + s, d, f, to: f * 1.04, wave: .saw, vol: vol, attack: 0.01, release: 0.05, vibrato: 0.09)
            tone(t + s, d, f * 1.5, wave: .square(0.3), vol: vol * 0.5, attack: 0.01, release: 0.05, vibrato: 0.11)
        }
    }
}

/// The title sequence's tune, in the manner of the old electronic theme (its sounds, not its melody): a plucked,
/// galloping bass ostinato, swells of filtered "wind" every couple of bars, and a wobbly sine lead that swoops up into
/// long notes and slides between them, with the odd "oo-ee" glissando. The notes are our own.
func doctorTune(_ m: Mix, from t0: Double, bars: Int) {
    let bar = 1.6, sx = bar / 16
    let roots = [40, 40, 43, 38, 40, 45, 47, 40]                       // E E G D E A B E, low
    for b in 0..<bars {
        let r = roots[b % roots.count], s = t0 + Double(b) * bar
        for beat in 0..<4 {                                            // dum-da-da, dum-da-da, each note plucked
            for (o, d) in [(0, 2), (2, 1), (3, 1)] {
                let at = s + Double(beat * 4 + o) * sx, f = midi(r + (o == 0 ? 0 : 12)), len = Double(d) * sx * 0.95
                m.tone(at, len, f * 1.06, to: f, wave: .triangle, vol: o == 0 ? 0.14 : 0.1, attack: 0.002, release: 0.02, decay: 0.09)
                m.tone(at, len, f * 1.06, to: f, wave: .square(0.18), vol: 0.025, attack: 0.002, release: 0.02, decay: 0.05)
                if o == 0 { m.tone(at, len, midi(r - 12), wave: .sine, vol: 0.18, release: 0.03, decay: 0.16) }
            }
        }
        if b % 2 == 0 {                                                // the wind, swelling up and dying away
            m.noise(s, bar, vol: 0.07, cutoff: 0.005, cutoffTo: 0.09, attack: bar * 0.8, release: 0.1, seed: 60 + b)
            m.noise(s + bar, bar, vol: 0.07, cutoff: 0.09, cutoffTo: 0.005, attack: 0.1, release: bar * 0.8, seed: 61 + b)
        }
    }
    // the lead: (start, length, from, to): swoops up into a note, holds it wobbling, or slides down to the next
    let lead: [(Double, Double, Int, Int)] = [
        (1.6, 0.3, 64, 71), (1.9, 1.3, 71, 71), (3.2, 0.3, 71, 76), (3.5, 1.1, 76, 76), (4.6, 0.4, 74, 74), (5.0, 0.4, 72, 71),
        (5.4, 0.3, 71, 79), (5.7, 1.4, 79, 79), (7.1, 0.5, 79, 76), (7.6, 0.6, 76, 76)]
    for (s, d, from, to) in lead where s < Double(bars) * bar {
        let held = from == to
        for (detune, vol) in [(1.0, 0.085), (1.004, 0.04)] {          // two sines a hair apart, for the wobble
            m.tone(t0 + s, d, midi(from) * detune, to: midi(to) * detune, wave: .sine, vol: vol,
                   attack: held ? 0.02 : 0.06, release: held ? 0.12 : 0.02, vibrato: held ? 0.018 : 0.004)
        }
        m.tone(t0 + s, d, midi(from + 12), to: midi(to + 12), wave: .triangle, vol: 0.012, attack: 0.05, release: 0.1, vibrato: 0.018)
    }
    for at in [0.6, 4.4] {                                             // oo-ee: a sine sweeping up an octave and back
        m.tone(t0 + at, 0.45, midi(76), to: midi(88), wave: .sine, vol: 0.035, attack: 0.15, release: 0.05, vibrato: 0.01)
        m.tone(t0 + at + 0.45, 0.5, midi(88), to: midi(76), wave: .sine, vol: 0.035, attack: 0.02, release: 0.3, vibrato: 0.01)
    }
}

/// The Doctor Clawd trailer's score and effects.
func doctorSound(_ m: Mix) {
    let i0 = start("intro")
    for at in [0.25, 0.95, 4.35] {                                     // the lightning: a crack, then thunder
        m.noise(i0 + at, 0.25, vol: 0.22, cutoff: 0.9, decay: 0.06, highpass: true, seed: Int(at * 100))
        m.boom(i0 + at + 0.05, vol: 0.3)
    }
    m.noise(i0 + 0.2, 8.6, vol: 0.05, cutoff: 0.01, cutoffTo: 0.05, attack: 1.0, release: 0.6, seed: 3)   // the vortex's roar
    doctorTune(m, from: i0 + 0.5, bars: 5)
    m.whoosh(i0 + 4.3, 1.2, vol: 0.16)                                 // the box sweeping past
    let logo = i0 + 4.6
    m.boom(logo, vol: 0.4)
    for n in [40, 47, 52, 55, 59] { m.tone(logo, 1.8, midi(n), wave: .saw, vol: 0.04, attack: 0.02, release: 1.0) }
    m.whoosh(i0 + 7.0, 1.4, vol: 0.12)                                 // the box diving away
    m.tone(i0 + 7.6, 1.2, 200, to: 3200, wave: .saw, vol: 0.05, attack: 0.3, release: 0.1)
    m.noise(i0 + 7.8, 1.2, vol: 0.12, cutoff: 0.05, cutoffTo: 0.9, attack: 0.6, release: 0.3, seed: 9)
    let inv = start("invasion")
    for i in 0..<Int(9.5 / 0.4) { m.tone(inv + Double(i) * 0.4, 0.3, midi(i % 4 == 3 ? 31 : 28), wave: .saw, vol: 0.06 + 0.04 * min(1, Double(i) / 10), release: 0.1); m.kick(inv + Double(i) * 0.4, vol: 0.12 + 0.1 * min(1, Double(i) / 8)) }
    for i in 0..<4 { m.tone(inv + 0.3 + Double(i) * 0.32, 1.2, 140, to: 90, wave: .sine, vol: 0.06, attack: 0.2, release: 0.4) }   // the Dalicks coming down
    m.exterminate(inv + 2.2, vol: 0.13)
    for (s, chord) in [(0.0, [40, 43, 47]), (3.2, [41, 44, 48]), (6.4, [40, 44, 47])] {
        for n in chord { m.tone(inv + s, 3.2, midi(n), wave: .saw, vol: 0.03, attack: 0.4, release: 0.6) }
    }
    var b = inv + 2.8
    while b < inv + 5.4 { m.dalickBeam(b, vol: 0.07); b += 0.17 }
    m.wheeze(inv + boxIn, cycles: 3, vol: 0.18)
    m.clunk(inv + doorOpen, vol: 0.1)
    for k in 0..<5 { m.step(inv + 5.8 + Double(k) * 0.16, vol: 0.07) }
    for i in 0..<4 {
        let z = inv + zapFrom + Double(i) * zapEach
        m.sonic(z, zapEach * 0.95, vol: 0.08)
        m.tone(z + zapEach * 0.7, 0.9, 600, to: 1500, wave: .square(0.3), vol: 0.03, release: 0.3)   // whirring off
    }
    groove(m, from: start("hook"), to: start("endcard"), fadeIn: 1.2)
    let hook = start("hook")
    for i in 0..<26 { m.click(hook + 0.2 + Double(i) * 0.13 + noise(i) * 0.06) }
    let desk = start("desktop"), deskEnd = end("desktop") + 1.3
    for (i, d) in [0.0, 0.12, 0.24, 0.32].enumerated() { m.step(desk + d + 0.3, vol: 0.1 + Double(i % 2) * 0.03) }
    m.sonic(desk + 0.6, deskEnd - desk - 0.6, vol: 0.025)
    for t in shotTimes(desk + 0.45, deskEnd, offset: 0) { m.pew(t, vol: 0.08) }
    for t in shotTimes(desk + 0.45, deskEnd, offset: blasterPeriod / 2) { m.pew(t, vol: 0.06) }
    let st = start("status")
    for i in 0..<4 { m.pop(st + 0.1 + Double(i) * 0.22, step: i) }
    for k in 0..<5 { m.tone(st + 1.2 + Double(k) * 0.62, 0.08, 1568, wave: .square(0.5), vol: 0.035, release: 0.03) }
    let ag = start("agents")
    for k in 0..<14 { m.step(ag + Double(k) * 0.125, vol: 0.06) }
    let wi = start("window")
    m.sonic(wi + 0.3, 2.2, vol: 0.02)
    for k in [0.9, 1.8] { m.click(wi + k, vol: 0.06) }
    m.ping(wi + 2.5)
    let ais = start("ais")
    for i in 0..<6 { m.pop(ais + 0.15 + Double(i) * 0.1, step: i % 4) }
    m.sonic(ais + 0.4, end("ais") + 1.0 - ais - 0.4, vol: 0.02)
    for s in shots { transitionSound(m, s) }
    let ec = start("endcard")
    m.wheeze(ec - 0.4, cycles: 2, vol: 0.07)
    for (s, d, chord, lead) in [(0.0, 0.7, [52, 55, 59, 64], 79), (0.7, 0.7, [50, 54, 57, 62], 78), (1.4, 2.8, [52, 56, 59, 64], 83)] {
        for n in chord { m.tone(ec + s, d, midi(n), wave: .saw, vol: 0.045, attack: 0.02, release: d > 1 ? 1.6 : 0.1) }
        m.tone(ec + s, d, midi(lead), wave: .sine, vol: 0.08, release: d > 1 ? 1.6 : 0.1, vibrato: 0.012)
        m.tone(ec + s, d, midi(chord[0] - 24), wave: .sine, vol: 0.2, release: d > 1 ? 1.6 : 0.1)
    }
    m.boom(ec + 0.35, vol: 0.45)
    m.noise(ec + 1.4, 2.5, vol: 0.08, cutoff: 0.9, decay: 0.8, highpass: true, seed: 8)
}
