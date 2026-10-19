import AppKit

// The Clawd Files: the sedan picking someone up, missing time, the saucer taking an alien home.
// The showcase README's own pictures, drawn by Tools/RenderShowcase (`build/rendershowcase docs files`) with its kit
// (`canvas`, `strip`, `sprite`, `at`, `tag`…). Compiled only into that tool.

struct FilesShowcase: Showcase {
    let name = "files"
    func render() { filesShowcase() }
}

// MARK: The Clawd Files

/// A ride (the sedan, the saucer) standing on the floor of a panel, centred on `x`.
func ride(_ ctx: CGContext, _ o: CGPoint, _ kind: Ride, x: Double, lift: Double = 0, ramp: Double, lit: Bool, alpha: CGFloat = 1) {
    let c = PixelCanvas(Ride.width, Ride.height)
    drawRide(c, kind, ramp: ramp, engines: lit, gear: true)
    c.addOutline(C(0xFFFFFF, 0.92))
    put(c, ctx, x: x - Double(Ride.width) / 2, y: Double(ph - 8 - Ride.height + 1) - lift, unit: unit, frameH: ph, origin: o, alpha: alpha)
}

/// The abduction beam, from `top` down to the floor, centred on `x`.
func beam(_ ctx: CGContext, _ o: CGPoint, x: Double, top: Double, strength: Double) {
    let h = Int(Double(ph - 8) - top)
    guard h > 0 else { return }
    let c = PixelCanvas(26, h)
    drawAbductionBeam(c, strength: strength, t: 1.1)
    put(c, ctx, x: x - 13, y: top, unit: unit, frameH: ph, origin: o)
}

/// MISSING TIME over a character, typed in the typewriter face.
func typed(_ s: String, _ ctx: CGContext, centerX: CGFloat, bottom: CGFloat) {
    let text = NSAttributedString(string: s, attributes: [.font: FilesCaption.font(17), .foregroundColor: NSColor(srgbRed: 0.8, green: 1, blue: 0.85, alpha: 1)])
    NSGraphicsContext.saveGraphicsState()
    text.draw(at: NSPoint(x: centerX - text.size().width / 2, y: bottom))
    NSGraphicsContext.restoreGraphicsState()
}

func filesShowcase() {
    Universe.shown = .clawdFiles
    let dana = Cast.hero(FilesHero.danaScrawly), fox = Cast.hero(FilesHero.foxClawder)
    let grey = Cast.villain(FilesVillain.grey), smoker = Cast.villain(FilesVillain.smokingClawd)

    // The sedan: it drives in along the street, the back door opens, Scrawly gets in, and it drives off.
    strip(.toomsBlock, [
        Panel(caption: "1 · the FBI's sedan pulls up") { ctx, o, sy in
            ride(ctx, o, .sedan, x: 92, ramp: 0, lit: true)
            at(sprite(dana), ctx, o, bodyX: 26)
            tag("Verify the fix", ctx, centerX: o.x + 26 * unit, bottom: sy(spriteTop + 18))
        },
        Panel(caption: "2 · the back door opens") { ctx, o, sy in
            ride(ctx, o, .sedan, x: 92, ramp: 1, lit: false)
            at(sprite(dana), ctx, o, bodyX: 26)
            tag("Verify the fix", ctx, centerX: o.x + 26 * unit, bottom: sy(spriteTop + 18))
        },
        Panel(caption: "3 · Scrawly gets in") { ctx, o, _ in
            ride(ctx, o, .sedan, x: 92, ramp: 1, lit: false)
            at(sprite(dana, t: 0.06, walking: true), ctx, o, bodyX: 70, alpha: 0.8)
        },
        Panel(caption: "4 · and it drives off") { ctx, o, _ in
            ride(ctx, o, .sedan, x: 146, ramp: 0, lit: true)
        },
    ], file: "sedan.png")

    // Missing time: /compact, and an FBI agent is taken up into the light and set back down, some time gone.
    strip(.bellefleurWoods, [
        Panel(caption: "you type /compact") { ctx, o, sy in
            at(sprite(fox), ctx, o, bodyX: 75)
            tag("Fox Clawder", ctx, centerX: o.x + 75 * unit, bottom: sy(spriteTop + 16), leader: true)
        },
        Panel(caption: "a light comes down…") { ctx, o, sy in
            beam(ctx, o, x: 75, top: 0, strength: 1)
            at(sprite(fox), ctx, o, bodyX: 75)
            tag("Fox Clawder", ctx, centerX: o.x + 75 * unit, bottom: sy(spriteTop + 16), leader: true)
        },
        Panel(caption: "…and up he goes") { ctx, o, _ in
            beam(ctx, o, x: 75, top: 0, strength: 1)
            at(sprite(fox), ctx, o, bodyX: 75, alpha: 0.45, lift: 18)
        },
        Panel(caption: "same session, some time gone") { ctx, o, sy in
            at(sprite(fox), ctx, o, bodyX: 75)
            typed("MISSING TIME", ctx, centerX: o.x + 75 * unit, bottom: sy(spriteTop + 18))
        },
    ], file: "missing-time.png")

    // The saucer: it comes down over Area 51, its beam lands, the Grey walks into it, and it's gone.
    strip(.area51, [
        Panel(caption: "1 · a saucer comes over") { ctx, o, _ in
            ride(ctx, o, .saucer, x: 90, lift: 26, ramp: 0, lit: true, alpha: 0.85)
            at(sprite(grey), ctx, o, bodyX: 30)
            at(sprite(smoker, left: true), ctx, o, bodyX: 132, left: true)
        },
        Panel(caption: "2 · its beam comes down") { ctx, o, _ in
            ride(ctx, o, .saucer, x: 90, lift: 26, ramp: 1, lit: true)
            at(sprite(grey), ctx, o, bodyX: 30)
            at(sprite(smoker, left: true), ctx, o, bodyX: 132, left: true)
        },
        Panel(caption: "3 · the Grey walks into the light") { ctx, o, _ in
            ride(ctx, o, .saucer, x: 90, lift: 26, ramp: 1, lit: true)
            at(sprite(grey, t: 0.06, walking: true), ctx, o, bodyX: 86, alpha: 0.7)
            at(sprite(smoker, left: true), ctx, o, bodyX: 132, left: true)
        },
        Panel(caption: "4 · and it's gone") { ctx, o, _ in
            ride(ctx, o, .saucer, x: 120, lift: 44, ramp: 0, lit: true, alpha: 0.5)
            at(sprite(smoker, left: true), ctx, o, bodyX: 132, left: true)
        },
    ], file: "saucer.png")

    // The icon: Fox Clawder's flashlight and sidearm against the Grey, under a saucer and its beam, in the woods at night.
    let icon = canvas(1024, 1024, bg: nil) { ctx in
        let box = CGRect(x: 100, y: 100, width: 824, height: 824)
        let path = CGPath(roundedRect: box, cornerWidth: 185, cornerHeight: 185, transform: nil)
        ctx.saveGState(); ctx.addPath(path); ctx.clip()
        // The night sky, chunky: deep green-black, lighter low down, a few stars.
        let px = 12, n = 824 / px + 1
        for j in 0..<n {
            let v = Double(j) / Double(n)
            let col: UInt32 = v > 0.8 ? 0x070C0B : v > 0.6 ? 0x0B1412 : v > 0.42 ? 0x0F1C18 : 0x14261F
            ctx.setFillColor(hexRGB(col))
            ctx.fill(CGRect(x: box.minX, y: box.minY + CGFloat(j * px), width: box.width, height: CGFloat(px)))
        }
        for i in 0..<40 {
            ctx.setFillColor(hexRGB(0xD8F0E0, CGFloat(0.4 + 0.5 * noise(i * 3 + 2))))
            ctx.fill(CGRect(x: box.minX + CGFloat(noise(i * 3)) * box.width, y: box.minY + 420 + CGFloat(noise(i * 3 + 1)) * 400, width: 8, height: 8))
        }
        // The treeline and the floor.
        for k in 0..<14 {
            let x = box.minX + CGFloat(k) * 64 - 20, h: CGFloat = 150 + CGFloat(noise(k * 5) * 90)
            let tree = CGMutablePath()
            tree.move(to: CGPoint(x: x, y: box.minY + 228)); tree.addLine(to: CGPoint(x: x + 40, y: box.minY + 228 + h)); tree.addLine(to: CGPoint(x: x + 80, y: box.minY + 228))
            ctx.addPath(tree); ctx.setFillColor(hexRGB(0x050A08)); ctx.fillPath()
        }
        ctx.setFillColor(hexRGB(0x121C17)); ctx.fill(CGRect(x: box.minX, y: box.minY, width: box.width, height: 228))
        ctx.setFillColor(hexRGB(0x3A5A48)); ctx.fill(CGRect(x: box.minX, y: box.minY + 222, width: box.width, height: 6))
        // The saucer and its beam, over the middle.
        let ship = PixelCanvas(Ride.width, Ride.height)
        drawSaucer(ship, ramp: 0, engines: true)
        ship.addOutline(C(0xFFFFFF, 0.92))
        let sc: CGFloat = 7.5
        let shipRect = CGRect(x: box.midX - 33 * sc, y: box.maxY - 70 - 29 * sc, width: 66 * sc, height: 29 * sc)
        let cone = CGMutablePath()
        cone.move(to: CGPoint(x: box.midX - 50, y: shipRect.minY + 12 * sc)); cone.addLine(to: CGPoint(x: box.midX + 50, y: shipRect.minY + 12 * sc))
        cone.addLine(to: CGPoint(x: box.midX + 210, y: box.minY + 228)); cone.addLine(to: CGPoint(x: box.midX - 210, y: box.minY + 228)); cone.closeSubpath()
        ctx.addPath(cone); ctx.setFillColor(hexRGB(0xC8FFE0, 0.18)); ctx.fillPath()
        ctx.draw(ship.makeImage()!, in: shipRect)
        ctx.restoreGState()
        // The fighters and the fight between them.
        let s: CGFloat = 10.5, floorY: CGFloat = box.minY + 222, headroom = 20.0
        let lx = 24.0, rx = 58.0
        let left = Fighter(weapon: fox.weapon, x: lx, k: 1, top: headroom, side: 1, muzzle: fox.muzzle,
                           armoured: fox.armoured, pivot: fox.weaponPivot).dressed(as: fox)
        let right = Fighter(weapon: grey.weapon, x: rx, k: 1, top: headroom, side: -1, muzzle: grey.muzzle,
                            armoured: grey.armoured, pivot: grey.weaponPivot).dressed(as: grey)
        let fxW = 80, fxH = Sprite.height + Int(headroom)
        let fx = PixelCanvas(fxW, fxH)
        drawFightFX(fx, t: 0.42, left: left, right: right)
        let (rl, rr) = fightRoles(fox.weapon, grey.weapon)
        func body(_ c: PixelCanvas, _ bodyX: Double, flipped: Bool) {
            let x = flipped ? bodyX - (Double(Sprite.width) - Sprite.bodyCenterX) : bodyX - Sprite.bodyCenterX
            ctx.draw(c.makeImage()!, in: CGRect(x: box.minX + 10 + CGFloat(x) * s, y: floorY - 8 * s,
                                               width: CGFloat(Sprite.width) * s, height: CGFloat(Sprite.height) * s))
        }
        body(sprite(fox, t: 0.42, mode: .working, role: rl), lx, flipped: false)
        body(sprite(grey, t: 0.42, mode: .working, role: rr, left: true), rx, flipped: true)
        ctx.draw(fx.makeImage()!, in: CGRect(x: box.minX + 10, y: floorY - 8 * s, width: CGFloat(fxW) * s, height: CGFloat(fxH) * s))
        ctx.addPath(path); ctx.setStrokeColor(hexRGB(0xFFFFFF, 0.12)); ctx.setLineWidth(3); ctx.strokePath()
    }
    save(icon, "icon.png")
}
