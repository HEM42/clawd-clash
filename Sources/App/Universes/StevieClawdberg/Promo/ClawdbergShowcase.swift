import AppKit

// Stevie Clawdberg: the DeLorean picking someone up, 88 mph, the mothership's light.
// The showcase README's own pictures, drawn by Tools/RenderShowcase (`build/rendershowcase docs clawdberg`) with its kit
// (`canvas`, `strip`, `sprite`, `at`, `tag`…). Compiled only into that tool.

struct ClawdbergShowcase: Showcase {
    let name = "clawdberg"
    func render() { clawdbergShowcase() }
}

// MARK: Stevie Clawdberg

/// The 88 mph effects (sparks, flash, fire trails) for a traveller standing at `bodyX`, facing right.
func outaTime(_ ctx: CGContext, _ o: CGPoint, bodyX: Double, k: Double) {
    let c = PixelCanvas(outaTimeWidth, Sprite.height)
    drawOutaTime(c, OutaTime(k: k), t: 1.2)
    put(c, ctx, x: bodyX - Double(outaTimeAnchor), y: spriteTop, unit: unit, frameH: ph, origin: o)
}

/// OUTATIME over a traveller's head, in the number plate's bold capitals.
func plate(_ s: String, _ ctx: CGContext, centerX: CGFloat, bottom: CGFloat) {
    let text = NSAttributedString(string: s, attributes: [.font: NSFont.monospacedSystemFont(ofSize: 17, weight: .heavy),
                                                          .foregroundColor: NSColor(srgbRed: 1, green: 0.62, blue: 0.24, alpha: 1)])
    NSGraphicsContext.saveGraphicsState()
    text.draw(at: NSPoint(x: centerX - text.size().width / 2, y: bottom))
    NSGraphicsContext.restoreGraphicsState()
}

func clawdbergShowcase() {
    Universe.shown = .clawdberg
    let clara = Cast.hero(ClawdbergHero.claraClawton), marty = Cast.hero(ClawdbergHero.martyMcFry)
    let roy = Cast.hero(ClawdbergHero.royNeery), jillian = Cast.hero(ClawdbergHero.jillianGeyser)
    let madDog = Cast.villain(ClawdbergVillain.madDogTannin)
    let indy = Cast.hero(ClawdbergHero.indianaBones), bellock = Cast.villain(ClawdbergVillain.reneBellock)

    // The DeLorean: it pulls up crackling, the gull-wing door lifts, Clara gets in, and it's gone in two lines of fire.
    strip(.hillValley1885, [
        Panel(caption: "1 · the DeLorean pulls up") { ctx, o, sy in
            ride(ctx, o, .delorean, x: 92, ramp: 0, lit: true)
            at(sprite(clara), ctx, o, bodyX: 26)
            tag("Verify the fix", ctx, centerX: o.x + 26 * unit, bottom: sy(spriteTop + 18))
        },
        Panel(caption: "2 · the gull-wing door lifts") { ctx, o, sy in
            ride(ctx, o, .delorean, x: 92, ramp: 1, lit: false)
            at(sprite(clara), ctx, o, bodyX: 26)
            tag("Verify the fix", ctx, centerX: o.x + 26 * unit, bottom: sy(spriteTop + 18))
        },
        Panel(caption: "3 · Clara Clawton gets in") { ctx, o, _ in
            ride(ctx, o, .delorean, x: 92, ramp: 1, lit: false)
            at(sprite(clara, t: 0.06, walking: true), ctx, o, bodyX: 70, alpha: 0.8)
        },
        Panel(caption: "4 · and it's gone at 88 mph") { ctx, o, _ in
            outaTime(ctx, o, bodyX: 40, k: 0.3)
            at(sprite(madDog, left: true), ctx, o, bodyX: 134, left: true)
        },
    ], file: "delorean.png")

    // 88 mph: /compact, and a time traveller crackles, flashes away in two lines of fire and booms back.
    strip(.hillValley1955, [
        Panel(caption: "you type /compact") { ctx, o, sy in
            at(sprite(marty), ctx, o, bodyX: 50)
            tag("Marty McFry", ctx, centerX: o.x + 50 * unit, bottom: sy(spriteTop + 16), leader: true)
        },
        Panel(caption: "he hits 88 mph…") { ctx, o, sy in
            at(sprite(marty), ctx, o, bodyX: 50)
            outaTime(ctx, o, bodyX: 50, k: 0.17)
            tag("Marty McFry", ctx, centerX: o.x + 50 * unit, bottom: sy(spriteTop + 16), leader: true)
        },
        Panel(caption: "…and he's gone") { ctx, o, _ in
            outaTime(ctx, o, bodyX: 50, k: 0.3)
        },
        Panel(caption: "same session, back again") { ctx, o, sy in
            at(sprite(marty), ctx, o, bodyX: 50)
            plate("OUTATIME", ctx, centerX: o.x + 50 * unit, bottom: sy(spriteTop + 18))
        },
    ], file: "88-mph.png")

    // The mothership: it comes over Devils Tower, its light pours down, Roy walks up into it, and it rises away.
    strip(.devilsTower, [
        Panel(caption: "1 · the mothership comes over") { ctx, o, _ in
            ride(ctx, o, .mothership, x: 90, lift: 26, ramp: 0, lit: true, alpha: 0.85)
            at(sprite(roy), ctx, o, bodyX: 30)
            at(sprite(jillian, left: true), ctx, o, bodyX: 132, left: true)
        },
        Panel(caption: "2 · its light pours down") { ctx, o, _ in
            ride(ctx, o, .mothership, x: 90, lift: 26, ramp: 1, lit: true)
            at(sprite(roy), ctx, o, bodyX: 30)
            at(sprite(jillian, left: true), ctx, o, bodyX: 132, left: true)
        },
        Panel(caption: "3 · Roy Neery walks into it") { ctx, o, _ in
            ride(ctx, o, .mothership, x: 90, lift: 26, ramp: 1, lit: true)
            at(sprite(roy, t: 0.06, walking: true), ctx, o, bodyX: 86, alpha: 0.7)
            at(sprite(jillian, left: true), ctx, o, bodyX: 132, left: true)
        },
        Panel(caption: "4 · and it rises away") { ctx, o, _ in
            ride(ctx, o, .mothership, x: 96, lift: 44, ramp: 0, lit: true, alpha: 0.5)
            at(sprite(jillian, left: true), ctx, o, bodyX: 132, left: true)
        },
    ], file: "mothership.png")

    // The icon: Indiana Bones's whip against René Bellock's arrows, under a huge full moon with the bike crossing it.
    let icon = canvas(1024, 1024, bg: nil) { ctx in
        let box = CGRect(x: 100, y: 100, width: 824, height: 824)
        let path = CGPath(roundedRect: box, cornerWidth: 185, cornerHeight: 185, transform: nil)
        ctx.saveGState(); ctx.addPath(path); ctx.clip()
        // The night sky, chunky: deep blue, lighter low down, a few stars.
        let px = 12, n = 824 / px + 1
        for j in 0..<n {
            let v = Double(j) / Double(n)
            let col: UInt32 = v > 0.8 ? 0x060A1C : v > 0.6 ? 0x0A1028 : v > 0.42 ? 0x0E1634 : 0x141E42
            ctx.setFillColor(hexRGB(col))
            ctx.fill(CGRect(x: box.minX, y: box.minY + CGFloat(j * px), width: box.width, height: CGFloat(px)))
        }
        for i in 0..<40 {
            ctx.setFillColor(hexRGB(0xE8EEFF, CGFloat(0.4 + 0.5 * noise(i * 3 + 2))))
            ctx.fill(CGRect(x: box.minX + CGFloat(noise(i * 3)) * box.width, y: box.minY + 420 + CGFloat(noise(i * 3 + 1)) * 400, width: 8, height: 8))
        }
        // The full moon, in chunky pixels, with its seas and a faint halo.
        let mc = CGPoint(x: box.midX, y: box.maxY - 180), mr: CGFloat = 150
        for j in 0..<n {
            for i in 0..<n {
                let x = box.minX + CGFloat(i * px) + 6, y = box.minY + CGFloat(j * px) + 6
                let dx = x - mc.x, dy = y - mc.y, d = (dx * dx + dy * dy).squareRoot()
                guard d < mr + 18 else { continue }
                var col: UInt32 = d < mr ? 0xF4EEC8 : 0x3A4466
                if d < mr {
                    for (sx, sy, r) in [(-50.0, 45.0, 38.0), (45.0, 65.0, 26.0), (30.0, -30.0, 34.0), (-38.0, -66.0, 22.0)] {
                        let ex = Double(dx) - sx, ey = Double(dy) - sy
                        if (ex * ex + ey * ey).squareRoot() < r { col = 0xDCD4A8 }
                    }
                }
                ctx.setFillColor(hexRGB(col, d < mr ? 1 : 0.6))
                ctx.fill(CGRect(x: x - 6, y: y - 6, width: CGFloat(px), height: CGFloat(px)))
            }
        }
        // The bike across it, a black silhouette.
        let bike = PixelCanvas(Ride.width, Ride.height)
        drawMoonBike(bike, ramp: 0, lit: true)
        let shadow = PixelCanvas(Ride.width, Ride.height)
        for y in 0..<bike.h { for x in 0..<bike.w where bike.buf[(y * bike.w + x) * 4 + 3] > 40 { shadow.px(x, y, C(0x05060C)) } }
        let sc: CGFloat = 4
        ctx.draw(shadow.makeImage()!, in: CGRect(x: mc.x - 33 * sc + 20, y: mc.y - 16 * sc, width: 66 * sc, height: 29 * sc))
        // The hills and the floor.
        for k in 0..<9 {
            let x = box.minX + CGFloat(k) * 110 - 40, h: CGFloat = 60 + CGFloat(noise(k * 5) * 70)
            ctx.setFillColor(hexRGB(0x070A16))
            ctx.fillEllipse(in: CGRect(x: x, y: box.minY + 228 - h, width: 220, height: h * 2))
        }
        ctx.setFillColor(hexRGB(0x101628)); ctx.fill(CGRect(x: box.minX, y: box.minY, width: box.width, height: 228))
        ctx.setFillColor(hexRGB(0x4A5A80)); ctx.fill(CGRect(x: box.minX, y: box.minY + 222, width: box.width, height: 6))
        ctx.restoreGState()
        // The fighters and the fight between them.
        let s: CGFloat = 10.5, floorY: CGFloat = box.minY + 222, headroom = 20.0
        let lx = 21.0, rx = 61.0              // a little further apart than the others: Indy's hat is wide
        let left = Fighter(weapon: bellock.weapon, x: lx, k: 1, top: headroom, side: 1, muzzle: bellock.muzzle,
                           armoured: bellock.armoured, pivot: bellock.weaponPivot).dressed(as: bellock)
        let right = Fighter(weapon: indy.weapon, x: rx, k: 1, top: headroom, side: -1, muzzle: indy.muzzle,
                            armoured: indy.armoured, pivot: indy.weaponPivot).dressed(as: indy)
        let fxW = 80, fxH = Sprite.height + Int(headroom)
        let fx = PixelCanvas(fxW, fxH)
        let tIcon = Double(ProcessInfo.processInfo.environment["ICON_T"] ?? "") ?? 0.3   // the arrow meets the whip
        drawFightFX(fx, t: tIcon, left: left, right: right)
        let (rl, rr) = fightRoles(bellock.weapon, indy.weapon)
        func body(_ c: PixelCanvas, _ bodyX: Double, flipped: Bool) {
            let x = flipped ? bodyX - (Double(Sprite.width) - Sprite.bodyCenterX) : bodyX - Sprite.bodyCenterX
            ctx.draw(c.makeImage()!, in: CGRect(x: box.minX + 10 + CGFloat(x) * s, y: floorY - 8 * s,
                                               width: CGFloat(Sprite.width) * s, height: CGFloat(Sprite.height) * s))
        }
        body(sprite(bellock, t: tIcon, mode: .working, role: rl), lx, flipped: false)
        body(sprite(indy, t: tIcon, mode: .working, role: rr, left: true), rx, flipped: true)
        ctx.draw(fx.makeImage()!, in: CGRect(x: box.minX + 10, y: floorY - 8 * s, width: CGFloat(fxW) * s, height: CGFloat(fxH) * s))
        ctx.addPath(path); ctx.setStrokeColor(hexRGB(0xFFFFFF, 0.12)); ctx.setLineWidth(3); ctx.strokePath()
    }
    save(icon, "icon.png")
}
