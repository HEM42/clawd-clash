import AppKit

// Clawd of the Rings: the Great Eagle picking someone up, Frodough slipping the Ring on, Shellob's climb.
// The showcase README's own pictures, drawn by Tools/RenderShowcase (`build/rendershowcase docs rings`) with its kit
// (`canvas`, `strip`, `sprite`, `at`, `tag`…). Compiled only into that tool.

struct RingsShowcase: Showcase {
    let name = "rings"
    func render() { ringsShowcase() }
}

// MARK: Clawd of the Rings

/// A character `k` (0…1) through its signature move, outlined, facing right (or left), and how far through the move
/// the drawing says it is (`drawnSignature`, for a move that climbs a thread).
private func signatureSprite(_ who: Cast, k: Double, t: Double = 0.3, left: Bool = false) -> (PixelCanvas, Double?) {
    let len = who.signatureLength ?? IdleHabit.signature.length
    forcedHabit = HabitPlay(kind: .signature, e: len * k, length: len)
    let c = PixelCanvas(Sprite.width, Sprite.height)
    who.draw(c, t: t, mode: .idle, walking: false, role: .none, asSession: true)
    forcedHabit = nil
    let drawn = drawnSignature
    if left { c.flipHorizontally() }
    c.addOutline(C(0xFFFFFF, 0.92))
    return (c, drawn)
}

/// A character in a signature that climbs a thread (`Persona.climb`, Shellob), standing at `bodyX`: risen and faded
/// by the move, its thread drawn from where it leaves the body up to the top of the panel, as the overlay draws it.
private func climber(_ who: Cast, k: Double, _ ctx: CGContext, _ o: CGPoint, bodyX: Double, left: Bool = false,
             sy: (Double) -> CGFloat) {
    let (c, drawn) = signatureSprite(who, k: k, left: left)
    guard let move = who.persona.climb, let p = drawn else { at(c, ctx, o, bodyX: bodyX, left: left); return }
    let rise = move.rise(p), alpha = move.alpha(p), facing: Double = left ? -1 : 1
    let fx = bodyX + facing * (move.from.x - Sprite.bodyCenterX)
    let fy = spriteTop - rise + move.from.y
    let reach = fy * move.thread(p)
    if reach > 1 {
        ctx.saveGState(); ctx.setAlpha(CGFloat(0.9 * max(alpha, 0.35)))
        ctx.setFillColor(CGColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1))
        ctx.fill(CGRect(x: o.x + CGFloat(fx - 0.3) * unit, y: sy(fy), width: 0.6 * unit, height: CGFloat(reach) * unit))
        ctx.restoreGState()
    }
    at(c, ctx, o, bodyX: bodyX, left: left, alpha: CGFloat(alpha), lift: rise)
}

/// The Great Eagle, `lift` pixels off the floor, its wings beating on the clock `t`.
private func eagle(_ ctx: CGContext, _ o: CGPoint, x: Double, lift: Double = 0, ramp: Double, flying: Bool, t: Double = 0.1,
           alpha: CGFloat = 1) {
    let c = PixelCanvas(Ride.width, Ride.height)
    drawRide(c, .eagle, ramp: ramp, engines: flying, gear: !flying || lift < 6, t: t)
    c.addOutline(C(0xFFFFFF, 0.92))
    put(c, ctx, x: x - Double(Ride.width) / 2, y: Double(ph - 8 - Ride.height + 1) - lift, unit: unit, frameH: ph, origin: o,
        alpha: alpha)
}

func ringsShowcase() {
    Universe.shown = .middleEarth
    let gandalf = Cast.hero(RingsHero.gandalf), frodo = Cast.hero(RingsHero.frodo), sam = Cast.hero(RingsHero.sam)
    let balrog = Cast.villain(RingsVillain.balrog), gollum = Cast.villain(RingsVillain.gollum)
    let shelob = Cast.villain(RingsVillain.shelob)

    // The Great Eagle: it swoops down on Mount Doomscroll, lowers a wing, Samwise climbs on, and it soars away.
    strip(.mountDoom, [
        Panel(caption: "1 · the Great Eagle swoops in") { ctx, o, sy in
            eagle(ctx, o, x: 96, lift: 22, ramp: 0, flying: true, t: 0.1)
            at(sprite(sam), ctx, o, bodyX: 30)
            tag("Ship the release", ctx, centerX: o.x + 30 * unit, bottom: sy(spriteTop + 20))
        },
        Panel(caption: "2 · it lands and lowers a wing") { ctx, o, sy in
            eagle(ctx, o, x: 96, ramp: 1, flying: false)
            at(sprite(sam), ctx, o, bodyX: 30)
            tag("Ship the release", ctx, centerX: o.x + 30 * unit, bottom: sy(spriteTop + 20))
        },
        Panel(caption: "3 · Samwise climbs on") { ctx, o, _ in
            eagle(ctx, o, x: 96, ramp: 1, flying: false)
            at(sprite(sam, t: 0.06, walking: true), ctx, o, bodyX: 78, alpha: 0.8)
        },
        Panel(caption: "4 · and it soars away") { ctx, o, _ in
            eagle(ctx, o, x: 100, lift: 34, ramp: 0, flying: true, t: 0.35, alpha: 0.7)
            at(sprite(gollum, left: true), ctx, o, bodyX: 132, left: true)
        },
    ], file: "eagle.png")

    // The Ring: Frodough draws it out on its chain, slips it on and is gone, a ghost and a few sparkles, until he
    // takes it off again.
    strip(.bagEnd, [
        Panel(caption: "1 · Frodough draws out the Ring") { ctx, o, _ in
            at(signatureSprite(frodo, k: 0.14).0, ctx, o, bodyX: 70)
        },
        Panel(caption: "2 · slips it on…") { ctx, o, _ in
            at(signatureSprite(frodo, k: 0.33, t: 0.5).0, ctx, o, bodyX: 70)
        },
        Panel(caption: "3 · …and he's gone") { ctx, o, _ in
            at(signatureSprite(frodo, k: 0.6, t: 0.9).0, ctx, o, bodyX: 70)
        },
        Panel(caption: "4 · until he takes it off again") { ctx, o, _ in
            at(signatureSprite(frodo, k: 0.93).0, ctx, o, bodyX: 70)
        },
    ], file: "the-ring.png")

    // Shellob's climb: a thread shoots up out of sight, she climbs it and fades away, and drops back down on it.
    strip(.mountDoom, [
        Panel(caption: "1 · Shellob faces Samwise") { ctx, o, _ in
            at(sprite(sam), ctx, o, bodyX: 30)
            at(sprite(shelob, left: true), ctx, o, bodyX: 104, left: true)
        },
        Panel(caption: "2 · climbs a thread out of sight…") { ctx, o, sy in
            at(sprite(sam), ctx, o, bodyX: 30)
            climber(shelob, k: 0.05, ctx, o, bodyX: 104, left: true, sy: sy)
        },
        Panel(caption: "3 · …drops back down…") { ctx, o, sy in
            at(sprite(sam), ctx, o, bodyX: 30)
            climber(shelob, k: 0.25, ctx, o, bodyX: 104, left: true, sy: sy)
        },
        Panel(caption: "4 · …and dangles there") { ctx, o, sy in
            at(sprite(sam), ctx, o, bodyX: 30)
            climber(shelob, k: 0.5, ctx, o, bodyX: 104, left: true, sy: sy)
        },
    ], file: "shellob.png")

    // The icon: Gandclawd the Grey against the Ballrog on the bridge in the Mines of Mori-ah, fire glowing up from the
    // deep.
    let icon = canvas(1024, 1024, bg: nil) { ctx in
        let box = CGRect(x: 100, y: 100, width: 824, height: 824)
        let path = CGPath(roundedRect: box, cornerWidth: 185, cornerHeight: 185, transform: nil)
        ctx.saveGState(); ctx.addPath(path); ctx.clip()
        // The dark of the hall, chunky: black at the top, warming to ember red down by the bridge; under it the chasm,
        // its fire glowing up from far below.
        let px = 12, n = 824 / px + 1
        for j in 0..<n {
            let v = Double(j) / Double(n)
            let col: UInt32 = v > 0.7 ? 0x07060A : v > 0.5 ? 0x0E0A0E : v > 0.36 ? 0x1C0E0C : v > 0.27 ? 0x34140C
                : v > 0.19 ? 0x6A240A : v > 0.11 ? 0x3A1208 : 0x1E0806
            ctx.setFillColor(hexRGB(col))
            ctx.fill(CGRect(x: box.minX, y: box.minY + CGFloat(j * px), width: box.width, height: CGFloat(px)))
        }
        // The great pillars of the hall, fading into the dark.
        for k in 0..<5 {
            let x = box.minX + 40 + CGFloat(k) * 180
            ctx.setFillColor(hexRGB(0x18141A, 0.9))
            ctx.fill(CGRect(x: x, y: box.minY + 300, width: 72, height: 524))
            ctx.setFillColor(hexRGB(0x26202A, 0.9))
            ctx.fill(CGRect(x: x, y: box.minY + 300, width: 12, height: 524))
        }
        // Embers rising from the chasm.
        for i in 0..<46 {
            ctx.setFillColor(hexRGB(i % 3 == 0 ? 0xFFD060 : 0xFF7A1E, CGFloat(0.35 + 0.55 * noise(i * 3 + 2))))
            ctx.fill(CGRect(x: box.minX + CGFloat(noise(i * 3)) * box.width, y: box.minY + CGFloat(noise(i * 3 + 1)) * 420,
                            width: 8, height: 8))
        }
        // The bridge: a narrow span of stone over the chasm, lit from below.
        ctx.setFillColor(hexRGB(0x2A2226)); ctx.fill(CGRect(x: box.minX, y: box.minY + 190, width: box.width, height: 38))
        ctx.setFillColor(hexRGB(0x6A4A3A)); ctx.fill(CGRect(x: box.minX, y: box.minY + 222, width: box.width, height: 6))
        ctx.setFillColor(hexRGB(0xC8501A, 0.55)); ctx.fill(CGRect(x: box.minX, y: box.minY + 184, width: box.width, height: 8))
        ctx.restoreGState()
        // The fighters and the fight between them.
        let s: CGFloat = 10.5, floorY: CGFloat = box.minY + 222, headroom = 20.0
        let lx = 20.0, rx = 56.0              // closer than the others: the Ballrog's wings are wide
        ctx.saveGState(); ctx.addPath(path); ctx.clip()
        let left = Fighter(weapon: gandalf.weapon, x: lx, k: 1, top: headroom, side: 1, muzzle: gandalf.muzzle,
                           armoured: gandalf.armoured, pivot: gandalf.weaponPivot).dressed(as: gandalf)
        let right = Fighter(weapon: balrog.weapon, x: rx, k: 1, top: headroom, side: -1, muzzle: balrog.muzzle,
                            armoured: balrog.armoured, pivot: balrog.weaponPivot).dressed(as: balrog)
        let fxW = 80, fxH = Sprite.height + Int(headroom)
        let fx = PixelCanvas(fxW, fxH)
        let tIcon = Double(ProcessInfo.processInfo.environment["ICON_T"] ?? "") ?? 0.3
        drawFightFX(fx, t: tIcon, left: left, right: right)
        let (rl, rr) = fightRoles(gandalf.weapon, balrog.weapon)
        func body(_ c: PixelCanvas, _ bodyX: Double, flipped: Bool) {
            let x = flipped ? bodyX - (Double(Sprite.width) - Sprite.bodyCenterX) : bodyX - Sprite.bodyCenterX
            ctx.draw(c.makeImage()!, in: CGRect(x: box.minX + 10 + CGFloat(x) * s, y: floorY - 8 * s,
                                               width: CGFloat(Sprite.width) * s, height: CGFloat(Sprite.height) * s))
        }
        body(sprite(gandalf, t: tIcon, mode: .working, role: rl), lx, flipped: false)
        body(sprite(balrog, t: tIcon, mode: .working, role: rr, left: true), rx, flipped: true)
        ctx.draw(fx.makeImage()!, in: CGRect(x: box.minX + 10, y: floorY - 8 * s, width: CGFloat(fxW) * s, height: CGFloat(fxH) * s))
        ctx.restoreGState()
        ctx.addPath(path); ctx.setStrokeColor(hexRGB(0xFFFFFF, 0.12)); ctx.setLineWidth(3); ctx.strokePath()
    }
    save(icon, "icon.png")
}
