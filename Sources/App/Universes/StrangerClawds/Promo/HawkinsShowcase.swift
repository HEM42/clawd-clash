import AppKit

// Stranger Clawds: the Party's bikes picking someone up, and Taken to the Upside Down.
// The showcase README's own pictures, drawn by Tools/RenderShowcase (`build/rendershowcase docs hawkins`) with its kit
// (`canvas`, `strip`, `sprite`, `at`, `tag`…). Compiled only into that tool. Nothing here shows the Upside Down's
// surprise.

struct HawkinsShowcase: Showcase {
    let name = "hawkins"
    func render() { hawkinsShowcase() }
}

// MARK: Stranger Clawds

/// Taken to the Upside Down round someone standing at `bodyX`, `k` (0…1) through it: the lights and the membrane
/// behind them, then their own picture pulled back into it, as the overlay draws it.
private func taken(_ who: Cast, k: Double, _ ctx: CGContext, _ o: CGPoint, bodyX: Double) {
    let s = HawkinsTaken(k: k)
    let fx = PixelCanvas(hawkinsTakenWidth, hawkinsTakenTop + Sprite.height)
    hawkinsDrawTaken(fx, s, headTop: who.drawnTop(), t: 1.1)
    put(fx, ctx, x: bodyX - Sprite.bodyCenterX, y: spriteTop - Double(hawkinsTakenTop), unit: unit, frameH: ph, origin: o)
    guard s.alpha > 0 else { return }
    let c = PixelCanvas(Sprite.width, Sprite.height)
    who.draw(c, t: 0.3, mode: .idle, walking: false, role: .rest, asSession: true)
    hawkinsTakenTouch(c, s, t: 1.1)
    c.addOutline(C(0xFFFFFF, 0.92))
    at(c, ctx, o, bodyX: bodyX, alpha: CGFloat(s.alpha))
}

/// The caption the overlay types over the spot, in a dark box.
private func typed(_ s: String, _ ctx: CGContext, centerX: CGFloat, bottom: CGFloat) {
    let text = NSAttributedString(string: s, attributes: [.font: NSFont.monospacedSystemFont(ofSize: 15, weight: .heavy),
                                                          .foregroundColor: NSColor(srgbRed: 1, green: 0.42, blue: 0.36, alpha: 1)])
    let ts = text.size()
    let box = CGRect(x: centerX - ts.width / 2 - 8, y: bottom, width: ts.width + 16, height: ts.height + 6)
    let path = CGPath(roundedRect: box, cornerWidth: 6, cornerHeight: 6, transform: nil)
    ctx.addPath(path); ctx.setFillColor(CGColor(gray: 0.05, alpha: 0.85)); ctx.fillPath()
    NSGraphicsContext.saveGraphicsState()
    text.draw(at: NSPoint(x: box.minX + 8, y: box.minY + 3))
    NSGraphicsContext.restoreGraphicsState()
}

/// The bikes standing on the floor of a panel, centred on `x`.
private func bikes(_ ctx: CGContext, _ o: CGPoint, x: Double, ramp: Double, moving: Bool, t: Double = 0.4) {
    let ride = Ride.hawkinsBikes
    let c = PixelCanvas(Ride.width, ride.canvasHeight)
    drawRide(c, ride, ramp: ramp, engines: moving, gear: true, t: t)
    c.addOutline(C(0xFFFFFF, 0.92))
    put(c, ctx, x: x - Double(Ride.width) / 2, y: Double(ph - 8 - ride.canvasHeight + 1), unit: unit, frameH: ph, origin: o)
}

func hawkinsShowcase() {
    Universe.shown = .hawkins
    let eleven = Cast.hero(HawkinsHero.eleven), will = Cast.hero(HawkinsHero.willByers)
    let lucas = Cast.hero(HawkinsHero.lucasSinclawd), democlawdgon = Cast.villain(HawkinsVillain.democlawdgon)
    let demodog = Cast.villain(HawkinsVillain.demodog)

    // The bikes: Lucas's agent is done, Mike and Dustin race in on their BMX bikes, skid to a stop, Lucas hops on the
    // back pegs, and they pedal off, leaving a Demodog behind.
    strip(.hawkinsCastleByers, [
        Panel(caption: "1 · the bikes race in") { ctx, o, sy in
            bikes(ctx, o, x: 98, ramp: 0, moving: true)
            at(sprite(lucas), ctx, o, bodyX: 26)
            tag("Verify the fix", ctx, centerX: o.x + 26 * unit, bottom: sy(spriteTop + 18))
        },
        Panel(caption: "2 · and skid to a stop") { ctx, o, sy in
            bikes(ctx, o, x: 98, ramp: 0.7, moving: false)
            at(sprite(lucas), ctx, o, bodyX: 26)
            tag("Verify the fix", ctx, centerX: o.x + 26 * unit, bottom: sy(spriteTop + 18))
        },
        Panel(caption: "3 · Lucas hops on the pegs") { ctx, o, _ in
            bikes(ctx, o, x: 98, ramp: 1, moving: false)
            at(sprite(lucas, t: 0.06, walking: true), ctx, o, bodyX: 66, alpha: 0.8)
        },
        Panel(caption: "4 · and they pedal off") { ctx, o, _ in
            bikes(ctx, o, x: 122, ramp: 0, moving: true, t: 0.9)
            at(sprite(demodog), ctx, o, bodyX: 30)
        },
    ], file: "bikes.png")

    // Taken to the Upside Down: /compact, and Will is pulled back through the wall, gone while it presses back from the
    // other side, and stumbles out again, slimy.
    let name = "Will Byers", wx = 70.0
    strip(.hawkinsByers, [
        Panel(caption: "you type /compact") { ctx, o, sy in
            taken(will, k: 0, ctx, o, bodyX: wx)
            tag(name, ctx, centerX: o.x + CGFloat(wx) * unit, bottom: sy(spriteTop + 16), leader: true)
        },
        Panel(caption: "the wall goes soft behind him…") { ctx, o, _ in
            taken(will, k: 0.22, ctx, o, bodyX: wx)
        },
        Panel(caption: "…and takes him") { ctx, o, sy in
            let s = HawkinsTaken(k: 0.5)
            taken(will, k: 0.5, ctx, o, bodyX: wx)
            typed(s.caption ?? "", ctx, centerX: o.x + CGFloat(wx) * unit, bottom: sy(spriteTop + 4))
        },
        Panel(caption: "back again, slime and all") { ctx, o, sy in
            taken(will, k: 0.74, ctx, o, bodyX: wx)
            tag(name, ctx, centerX: o.x + CGFloat(wx) * unit, bottom: sy(spriteTop + 16), leader: true)
        },
    ], file: "upside-down.png")

    // The icon: Eleven's power against the Democlawdgon in the Upside Down, the storm red over the black town, spores
    // drifting.
    let icon = canvas(1024, 1024, bg: nil) { ctx in
        let box = CGRect(x: 100, y: 100, width: 824, height: 824)
        let path = CGPath(roundedRect: box, cornerWidth: 185, cornerHeight: 185, transform: nil)
        ctx.saveGState(); ctx.addPath(path); ctx.clip()
        // The storm sky, chunky: near black at the top, a deep red glow low down behind the town.
        let px = 12, n = 824 / px + 1
        for j in 0..<n {
            let v = Double(j) / Double(n)
            let col: UInt32 = v > 0.8 ? 0x08080E : v > 0.62 ? 0x140C14 : v > 0.46 ? 0x2A0E14 : v > 0.36 ? 0x4A1218 : 0x6A1A1E
            ctx.setFillColor(hexRGB(col))
            ctx.fill(CGRect(x: box.minX, y: box.minY + CGFloat(j * px), width: box.width, height: CGFloat(px)))
        }
        // Red lightning forking down out of the cloud, between the two of them.
        ctx.setFillColor(hexRGB(0xFF5A4A))
        var bolt = (x: 430, y: 760)
        for step in 0..<16 {
            ctx.fill(CGRect(x: box.minX + CGFloat(bolt.x), y: box.minY + CGFloat(bolt.y), width: CGFloat(px), height: CGFloat(px)))
            if step == 7 {   // the fork
                for k in 1...5 { ctx.fill(CGRect(x: box.minX + CGFloat(bolt.x + k * px), y: box.minY + CGFloat(bolt.y - k * px),
                                                 width: CGFloat(px), height: CGFloat(px))) }
            }
            bolt = (bolt.x + [px, -px, 0, px][step % 4], bolt.y - px)
        }
        // Houses and dead trees in silhouette along the horizon.
        let dark = hexRGB(0x0A0A10)
        ctx.setFillColor(dark)
        for (x, w, h) in [(30.0, 170.0, 120.0), (560.0, 200.0, 140.0)] {
            ctx.fill(CGRect(x: box.minX + CGFloat(x), y: box.minY + 228, width: CGFloat(w), height: CGFloat(h)))
            let roof = CGMutablePath()
            roof.addLines(between: [CGPoint(x: box.minX + CGFloat(x) - 16, y: box.minY + 228 + CGFloat(h)),
                                    CGPoint(x: box.minX + CGFloat(x + w / 2), y: box.minY + 228 + CGFloat(h) + 70),
                                    CGPoint(x: box.minX + CGFloat(x + w) + 16, y: box.minY + 228 + CGFloat(h))])
            roof.closeSubpath(); ctx.addPath(roof); ctx.fillPath()
        }
        for (x, h) in [(260.0, 230.0), (420.0, 190.0), (790.0, 210.0)] {
            ctx.fill(CGRect(x: box.minX + CGFloat(x), y: box.minY + 228, width: 20, height: CGFloat(h)))
            ctx.fill(CGRect(x: box.minX + CGFloat(x) - 40, y: box.minY + 228 + CGFloat(h) - 70, width: 40, height: 12))
            ctx.fill(CGRect(x: box.minX + CGFloat(x) + 20, y: box.minY + 228 + CGFloat(h) - 110, width: 44, height: 12))
        }
        // The ground, black, with vines across it.
        ctx.setFillColor(hexRGB(0x0C0A0E)); ctx.fill(CGRect(x: box.minX, y: box.minY, width: box.width, height: 228))
        ctx.setFillColor(hexRGB(0x3A1A20)); ctx.fill(CGRect(x: box.minX, y: box.minY + 222, width: box.width, height: 6))
        // Spores drifting.
        for i in 0..<40 {
            ctx.setFillColor(hexRGB(0xE8E4DA, CGFloat(0.35 + 0.45 * noise(i * 3 + 2))))
            ctx.fill(CGRect(x: box.minX + CGFloat(noise(i * 3)) * box.width, y: box.minY + 240 + CGFloat(noise(i * 3 + 1)) * 560,
                            width: 8, height: 8))
        }
        ctx.restoreGState()
        // The fighters and the fight between them.
        let s: CGFloat = 10.5, floorY: CGFloat = box.minY + 222, headroom = 20.0
        let lx = 22.0, rx = 58.0
        ctx.saveGState(); ctx.addPath(path); ctx.clip()
        let left = Fighter(weapon: eleven.weapon, x: lx, k: 1, top: headroom, side: 1, muzzle: eleven.muzzle,
                           armoured: eleven.armoured, pivot: eleven.weaponPivot).dressed(as: eleven)
        let right = Fighter(weapon: democlawdgon.weapon, x: rx, k: 1, top: headroom, side: -1, muzzle: democlawdgon.muzzle,
                            armoured: democlawdgon.armoured, pivot: democlawdgon.weaponPivot).dressed(as: democlawdgon)
        let fxW = 80, fxH = Sprite.height + Int(headroom)
        let fx = PixelCanvas(fxW, fxH)
        let tIcon = Double(ProcessInfo.processInfo.environment["ICON_T"] ?? "") ?? 0.55
        drawFightFX(fx, t: tIcon, left: left, right: right)
        let (rl, rr) = fightRoles(eleven.weapon, democlawdgon.weapon)
        func body(_ c: PixelCanvas, _ bodyX: Double, flipped: Bool) {
            let x = flipped ? bodyX - (Double(Sprite.width) - Sprite.bodyCenterX) : bodyX - Sprite.bodyCenterX
            ctx.draw(c.makeImage()!, in: CGRect(x: box.minX + 10 + CGFloat(x) * s, y: floorY - 8 * s,
                                               width: CGFloat(Sprite.width) * s, height: CGFloat(Sprite.height) * s))
        }
        body(sprite(eleven, t: tIcon, mode: .working, role: rl), lx, flipped: false)
        body(sprite(democlawdgon, t: tIcon, mode: .working, role: rr, left: true), rx, flipped: true)
        ctx.draw(fx.makeImage()!, in: CGRect(x: box.minX + 10, y: floorY - 8 * s, width: CGFloat(fxW) * s, height: CGFloat(fxH) * s))
        ctx.restoreGState()
        ctx.addPath(path); ctx.setStrokeColor(hexRGB(0xFFFFFF, 0.12)); ctx.setLineWidth(3); ctx.strokePath()
    }
    save(icon, "icon.png")
}
