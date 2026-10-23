import AppKit

// Clawd Slayer: the school bus picking someone up, Tabula Rasa, the First Evil's guises.
// The showcase README's own pictures, drawn by Tools/RenderShowcase (`build/rendershowcase docs slayer`) with its kit
// (`canvas`, `strip`, `sprite`, `at`, `tag`…). Compiled only into that tool.

struct SlayerShowcase: Showcase {
    let name = "slayer"
    func render() { slayerShowcase() }
}

// MARK: Clawd Slayer

/// Tabula Rasa round a forgetter standing at `bodyX`, `k` (0…1) through it: the spell's own canvas (glow, smoke,
/// crystal, the "?") behind them, then the forgetter with the remembering shimmer on their sprite, as the overlay
/// draws it.
private func tabulaRasa(_ who: Cast, k: Double, _ ctx: CGContext, _ o: CGPoint, bodyX: Double) {
    let tr = SlayerTabulaRasa(k: k, cast: who)
    let fx = PixelCanvas(slayerTabulaWidth, slayerTabulaTop + Sprite.height)
    slayerDrawTabulaRasa(fx, tr, headTop: who.drawnTop(), t: 1.1)
    put(fx, ctx, x: bodyX - Sprite.bodyCenterX, y: spriteTop - Double(slayerTabulaTop), unit: unit, frameH: ph, origin: o)
    let c = PixelCanvas(Sprite.width, Sprite.height)
    who.draw(c, t: 0.3, mode: .idle, walking: false, role: .rest, asSession: true)
    slayerTabulaShimmer(c, tr, t: 1.1)
    c.addOutline(C(0xFFFFFF, 0.92))
    at(c, ctx, o, bodyX: bodyX)
}

/// What a forgetter says, in a cream speech box over their head, as the overlay's bubble shows it.
private func said(_ s: String, _ ctx: CGContext, centerX: CGFloat, bottom: CGFloat) {
    let text = NSAttributedString(string: s, attributes: [.font: NSFont.monospacedSystemFont(ofSize: 15, weight: .heavy),
                                                          .foregroundColor: NSColor(srgbRed: 0.16, green: 0.11, blue: 0.08, alpha: 1)])
    let ts = text.size()
    let box = CGRect(x: centerX - ts.width / 2 - 8, y: bottom, width: ts.width + 16, height: ts.height + 6)
    let path = CGPath(roundedRect: box, cornerWidth: 6, cornerHeight: 6, transform: nil)
    ctx.addPath(path); ctx.setFillColor(hexRGB(0xFAF0D6)); ctx.fillPath()
    ctx.addPath(path); ctx.setStrokeColor(hexRGB(0x2A1C14)); ctx.setLineWidth(1.5); ctx.strokePath()
    NSGraphicsContext.saveGraphicsState()
    text.draw(at: NSPoint(x: box.minX + 8, y: box.minY + 3))
    NSGraphicsContext.restoreGraphicsState()
}

/// A ride standing on the floor of a panel, centred on `x`.
private func ride(_ ctx: CGContext, _ o: CGPoint, _ kind: Ride, x: Double, lift: Double = 0, ramp: Double, lit: Bool, alpha: CGFloat = 1) {
    let c = PixelCanvas(Ride.width, Ride.height)
    drawRide(c, kind, ramp: ramp, engines: lit, gear: true)
    c.addOutline(C(0xFFFFFF, 0.92))
    put(c, ctx, x: x - Double(Ride.width) / 2, y: Double(ph - 8 - Ride.height + 1) - lift, unit: unit, frameH: ph, origin: o, alpha: alpha)
}

func slayerShowcase() {
    Universe.shown = .slayer
    let buffy = Cast.hero(SlayerHero.buffyClawmers), willow = Cast.hero(SlayerHero.willowRosenclaw)
    let master = Cast.villain(SlayerVillain.oldMaster), firstEvil = Cast.villain(SlayerVillain.firstEvil)
    let fledgling = Cast.villain(SlayerVillain.fledgling)

    // The school bus: it pulls up on Revello Drive, its folding door opens up front, Willow climbs aboard, and it
    // drives off, leaving a fledgling vampire on the pavement.
    strip(.slayerRevello, [
        Panel(caption: "1 · the school bus pulls up") { ctx, o, sy in
            ride(ctx, o, .schoolBus, x: 98, ramp: 0, lit: true)
            at(sprite(willow), ctx, o, bodyX: 26)
            tag("Verify the fix", ctx, centerX: o.x + 26 * unit, bottom: sy(spriteTop + 18))
        },
        Panel(caption: "2 · its door folds open") { ctx, o, sy in
            ride(ctx, o, .schoolBus, x: 98, ramp: 1, lit: false)
            at(sprite(willow), ctx, o, bodyX: 26)
            tag("Verify the fix", ctx, centerX: o.x + 26 * unit, bottom: sy(spriteTop + 18))
        },
        Panel(caption: "3 · Willow climbs aboard") { ctx, o, _ in
            ride(ctx, o, .schoolBus, x: 98, ramp: 1, lit: false)
            at(sprite(willow, t: 0.06, walking: true), ctx, o, bodyX: 104, alpha: 0.8)
        },
        Panel(caption: "4 · and it drives off") { ctx, o, _ in
            ride(ctx, o, .schoolBus, x: 152, ramp: 0, lit: true)
            at(sprite(fledgling), ctx, o, bodyX: 30)
        },
    ], file: "school-bus.png")

    // Tabula Rasa: /compact, and Willow's forgetting spell goes off on Buffy: the crystal glows, she has no idea who
    // she is ("JOAN?"), then it cracks underfoot and it all comes back.
    let name = "Buffy Clawdmers", bx = 62.0
    strip(.slayerMagicBox, [
        Panel(caption: "you type /compact") { ctx, o, sy in
            at(sprite(buffy), ctx, o, bodyX: bx)
            tag(name, ctx, centerX: o.x + CGFloat(bx) * unit, bottom: sy(spriteTop + 16), leader: true)
        },
        Panel(caption: "a crystal glows at her feet…") { ctx, o, sy in
            tabulaRasa(buffy, k: 0.14, ctx, o, bodyX: bx)
            tag(name, ctx, centerX: o.x + CGFloat(bx) * unit, bottom: sy(spriteTop + 16), leader: true)
        },
        Panel(caption: "…and she forgets who she is") { ctx, o, sy in
            let tr = SlayerTabulaRasa(k: 0.5, cast: buffy)
            tabulaRasa(buffy, k: 0.5, ctx, o, bodyX: bx)
            said(tr.caption ?? "", ctx, centerX: o.x + CGFloat(bx) * unit, bottom: sy(spriteTop + 16 - tr.markRoom))
        },
        Panel(caption: "it cracks: same session, she remembers") { ctx, o, sy in
            tabulaRasa(buffy, k: 0.8, ctx, o, bodyX: bx)
            tag(name, ctx, centerX: o.x + CGFloat(bx) * unit, bottom: sy(spriteTop + 16), leader: true)
        },
    ], file: "tabula-rasa.png")

    // The First Evil's guises: facing Buffy over the Hellmouth, it becomes the Big Bads before it, whole, as in
    // "Lessons".
    func guise(_ i: Int?) -> PixelCanvas {
        slayerForcedGuise = i.map { ($0, 0.5) }
        defer { slayerForcedGuise = nil }
        return sprite(firstEvil, left: true)
    }
    strip(.slayerHellmouth, [
        Panel(caption: "the First Evil faces Buffy") { ctx, o, _ in
            at(sprite(buffy), ctx, o, bodyX: 30)
            at(guise(nil), ctx, o, bodyX: 108, left: true)
        },
        Panel(caption: "it wears the Old Master…") { ctx, o, _ in
            at(sprite(buffy), ctx, o, bodyX: 30)
            at(guise(0), ctx, o, bodyX: 108, left: true)
        },
        Panel(caption: "…the Mayor…") { ctx, o, _ in
            at(sprite(buffy), ctx, o, bodyX: 30)
            at(guise(1), ctx, o, bodyX: 108, left: true)
        },
        Panel(caption: "…and Glory") { ctx, o, _ in
            at(sprite(buffy), ctx, o, bodyX: 30)
            at(guise(2), ctx, o, bodyX: 108, left: true)
        },
    ], file: "first-evil.png")

    // The icon: Buffy's stake against the Old Master in Restfield Cemetery, under a full moon, headstones behind.
    let icon = canvas(1024, 1024, bg: nil) { ctx in
        let box = CGRect(x: 100, y: 100, width: 824, height: 824)
        let path = CGPath(roundedRect: box, cornerWidth: 185, cornerHeight: 185, transform: nil)
        ctx.saveGState(); ctx.addPath(path); ctx.clip()
        // The night sky, chunky: deep navy, lighter low down, a few stars.
        let px = 12, n = 824 / px + 1
        for j in 0..<n {
            let v = Double(j) / Double(n)
            let col: UInt32 = v > 0.8 ? 0x05070F : v > 0.6 ? 0x080C1A : v > 0.42 ? 0x0C1226 : 0x121A32
            ctx.setFillColor(hexRGB(col))
            ctx.fill(CGRect(x: box.minX, y: box.minY + CGFloat(j * px), width: box.width, height: CGFloat(px)))
        }
        for i in 0..<36 {
            ctx.setFillColor(hexRGB(0xE6ECFF, CGFloat(0.4 + 0.5 * noise(i * 3 + 2))))
            ctx.fill(CGRect(x: box.minX + CGFloat(noise(i * 3)) * box.width, y: box.minY + 420 + CGFloat(noise(i * 3 + 1)) * 400, width: 8, height: 8))
        }
        // The full moon, in chunky pixels, moonlight blue-white with grey seas and a faint halo, up to the right.
        let mc = CGPoint(x: box.maxX - 230, y: box.maxY - 200), mr: CGFloat = 120
        for j in 0..<n {
            for i in 0..<n {
                let x = box.minX + CGFloat(i * px) + 6, y = box.minY + CGFloat(j * px) + 6
                let dx = x - mc.x, dy = y - mc.y, d = (dx * dx + dy * dy).squareRoot()
                guard d < mr + 18 else { continue }
                var col: UInt32 = d < mr ? 0xEEF2FA : 0x2E3A5E
                if d < mr {
                    for (sx, sy, r) in [(-40.0, 36.0, 30.0), (36.0, 52.0, 20.0), (24.0, -24.0, 28.0), (-30.0, -54.0, 18.0)] {
                        let ex = Double(dx) - sx, ey = Double(dy) - sy
                        if (ex * ex + ey * ey).squareRoot() < r { col = 0xC8D0E0 }
                    }
                }
                ctx.setFillColor(hexRGB(col, d < mr ? 1 : 0.6))
                ctx.fill(CGRect(x: x - 6, y: y - 6, width: CGFloat(px), height: CGFloat(px)))
            }
        }
        // Mist low over the graves.
        for k in 0..<10 {
            ctx.setFillColor(hexRGB(0x8A98B8, 0.10))
            ctx.fillEllipse(in: CGRect(x: box.minX + CGFloat(k) * 96 - 60, y: box.minY + 210 + CGFloat(noise(k * 7) * 40),
                                       width: 220, height: 70))
        }
        // Headstones and a crypt in silhouette along the horizon: rounded tops, a cross or two.
        let stone = hexRGB(0x1C2440)
        ctx.setFillColor(stone)
        ctx.fill(CGRect(x: box.minX + 40, y: box.minY + 228, width: 160, height: 150))     // the crypt
        let roof = CGMutablePath()
        roof.addLines(between: [CGPoint(x: box.minX + 24, y: box.minY + 378), CGPoint(x: box.minX + 120, y: box.minY + 440),
                                CGPoint(x: box.minX + 216, y: box.minY + 378)])
        roof.closeSubpath(); ctx.addPath(roof); ctx.fillPath()
        for (k, (x, h)) in [(250.0, 96.0), (420.0, 150.0), (560.0, 84.0), (720.0, 120.0)].enumerated() {
            let gx = box.minX + CGFloat(x), gh = CGFloat(h)
            if k == 1 {
                ctx.fill(CGRect(x: gx + 22, y: box.minY + 228, width: 24, height: gh))
                ctx.fill(CGRect(x: gx, y: box.minY + 228 + gh - 64, width: 68, height: 22))
            } else {
                ctx.fill(CGRect(x: gx, y: box.minY + 228, width: 64, height: gh - 32))
                ctx.fillEllipse(in: CGRect(x: gx, y: box.minY + 228 + gh - 64, width: 64, height: 64))
            }
        }
        // The grass and the floor.
        ctx.setFillColor(hexRGB(0x0E1418)); ctx.fill(CGRect(x: box.minX, y: box.minY, width: box.width, height: 228))
        ctx.setFillColor(hexRGB(0x3A5A50)); ctx.fill(CGRect(x: box.minX, y: box.minY + 222, width: box.width, height: 6))
        ctx.restoreGState()
        // The fighters and the fight between them.
        let s: CGFloat = 10.5, floorY: CGFloat = box.minY + 222, headroom = 20.0
        let lx = 22.0, rx = 58.0
        ctx.saveGState(); ctx.addPath(path); ctx.clip()
        let left = Fighter(weapon: buffy.weapon, x: lx, k: 1, top: headroom, side: 1, muzzle: buffy.muzzle,
                           armoured: buffy.armoured, pivot: buffy.weaponPivot).dressed(as: buffy)
        let right = Fighter(weapon: master.weapon, x: rx, k: 1, top: headroom, side: -1, muzzle: master.muzzle,
                            armoured: master.armoured, pivot: master.weaponPivot).dressed(as: master)
        let fxW = 80, fxH = Sprite.height + Int(headroom)
        let fx = PixelCanvas(fxW, fxH)
        let tIcon = Double(ProcessInfo.processInfo.environment["ICON_T"] ?? "") ?? 0.55   // the stake thrust home, the Master swinging back
        drawFightFX(fx, t: tIcon, left: left, right: right)
        let (rl, rr) = fightRoles(buffy.weapon, master.weapon)
        func body(_ c: PixelCanvas, _ bodyX: Double, flipped: Bool) {
            let x = flipped ? bodyX - (Double(Sprite.width) - Sprite.bodyCenterX) : bodyX - Sprite.bodyCenterX
            ctx.draw(c.makeImage()!, in: CGRect(x: box.minX + 10 + CGFloat(x) * s, y: floorY - 8 * s,
                                               width: CGFloat(Sprite.width) * s, height: CGFloat(Sprite.height) * s))
        }
        body(sprite(buffy, t: tIcon, mode: .working, role: rl), lx, flipped: false)
        body(sprite(master, t: tIcon, mode: .working, role: rr, left: true), rx, flipped: true)
        ctx.draw(fx.makeImage()!, in: CGRect(x: box.minX + 10, y: floorY - 8 * s, width: CGFloat(fxW) * s, height: CGFloat(fxH) * s))
        ctx.restoreGState()
        ctx.addPath(path); ctx.setStrokeColor(hexRGB(0xFFFFFF, 0.12)); ctx.setLineWidth(3); ctx.strokePath()
    }
    save(icon, "icon.png")
}
