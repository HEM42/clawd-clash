import AppKit

// Doctor Clawd: the TARDIS picking someone up, the Weeping Angle moving while nobody looks, a regeneration, and the icon.
// The showcase README's own pictures, drawn by Tools/RenderShowcase (`build/rendershowcase docs doctor`) with its kit
// (`canvas`, `strip`, `sprite`, `at`, `tag`…). Compiled only into that tool.

struct DoctorShowcase: Showcase {
    let name = "doctor"
    func render() { doctorShowcase() }
}

// MARK: Doctor Clawd

// The TARDIS: it wheezes in beside Rose, the door opens, she steps in, and it fades away. A Dalick looks on.
func tardisBox(_ ctx: CGContext, _ o: CGPoint, x: Double, door: Double, lamp: Bool, alpha: CGFloat) {
    let c = PixelCanvas(Ride.width, Ride.tardis.canvasHeight)
    drawRide(c, .tardis, ramp: door, engines: lamp, gear: true)
    c.addOutline(C(0xFFFFFF, 0.92))
    put(c, ctx, x: x - Double(Ride.width) / 2, y: Double(ph - 8 - Ride.tardis.canvasHeight + 1), unit: unit, frameH: ph, origin: o, alpha: alpha)
}
func doctorShowcase() {
Universe.shown = .doctor
let rose = Cast.hero(DoctorHero.rose), dalick = Cast.villain(DoctorVillain.dalick)
let roseX = 22.0, boxX = 66.0
strip(.powellEstate, [
    Panel(caption: "1 · the TARDIS wheezes in") { ctx, o, sy in
        tardisBox(ctx, o, x: boxX, door: 0, lamp: true, alpha: 0.55)
        at(sprite(rose), ctx, o, bodyX: roseX)
        at(sprite(dalick, left: true), ctx, o, bodyX: 124, left: true)
        tag("Verify the fix", ctx, centerX: o.x + CGFloat(roseX) * unit, bottom: sy(spriteTop + 18))
    },
    Panel(caption: "2 · the door swings open") { ctx, o, sy in
        tardisBox(ctx, o, x: boxX, door: 1, lamp: false, alpha: 1)
        at(sprite(rose), ctx, o, bodyX: roseX)
        at(sprite(dalick, left: true), ctx, o, bodyX: 124, left: true)
        tag("Verify the fix", ctx, centerX: o.x + CGFloat(roseX) * unit, bottom: sy(spriteTop + 18))
    },
    Panel(caption: "3 · Rose Tiler steps inside") { ctx, o, sy in
        tardisBox(ctx, o, x: boxX, door: 1, lamp: false, alpha: 1)
        at(sprite(rose, t: 0.06, walking: true), ctx, o, bodyX: 60, alpha: 0.75)
        at(sprite(dalick, left: true), ctx, o, bodyX: 124, left: true)
    },
    Panel(caption: "4 · and it's gone") { ctx, o, _ in
        tardisBox(ctx, o, x: boxX, door: 0, lamp: true, alpha: 0.3)
        at(sprite(dalick, left: true), ctx, o, bodyX: 124, left: true)
    },
], file: "tardis.png")

// The Weeping Angle: still while the Doctor looks at it, closer every time he looks away.
let angle = Cast.villain(DoctorVillain.weepingAngle), ten = Cast.hero(DoctorHero.doctorTen)
strip(.theLibrary, [
    Panel(caption: "Doctor Ten keeps an eye on it") { ctx, o, _ in
        at(sprite(ten), ctx, o, bodyX: 30)
        at(sprite(angle, left: true), ctx, o, bodyX: 128, left: true)
    },
    Panel(caption: "he looks away…") { ctx, o, _ in
        at(sprite(ten, left: true), ctx, o, bodyX: 30, left: true)
        at(sprite(angle, mode: .working, walking: true, role: .none, left: true), ctx, o, bodyX: 98, left: true, alpha: 0.85)
    },
    Panel(caption: "…and back. It's closer.") { ctx, o, _ in
        at(sprite(ten), ctx, o, bodyX: 30)
        at(sprite(angle, mode: .working, role: .none, left: true), ctx, o, bodyX: 80, left: true)
    },
    Panel(caption: "Don't blink.") { ctx, o, _ in
        at(sprite(ten, mode: .waiting, role: .hit), ctx, o, bodyX: 30)
        at(sprite(angle, mode: .working, role: .hit, left: true), ctx, o, bodyX: 56, left: true)
    },
], file: "angle.png")

// Regeneration: /compact, and the session's Doctor goes up in golden fire and comes out as the next one.
let eleven = Cast.hero(DoctorHero.doctorEleven)
strip(.consoleRoom, [
    Panel(caption: "you type /compact") { ctx, o, sy in
        at(sprite(ten), ctx, o, bodyX: 75)
        tag("Doctor Ten", ctx, centerX: o.x + 75 * unit, bottom: sy(spriteTop + 16), leader: true)
    },
    Panel(caption: "the context goes…") { ctx, o, sy in
        at(sprite(ten, t: 0.4, flare: 0.1), ctx, o, bodyX: 75)
        tag("Doctor Ten", ctx, centerX: o.x + 75 * unit, bottom: sy(spriteTop + 16), leader: true)
    },
    Panel(caption: "…and so does the face") { ctx, o, sy in
        at(sprite(eleven, t: 0.7, flare: 0.3), ctx, o, bodyX: 75)
        tag("Doctor Eleven", ctx, centerX: o.x + 75 * unit, bottom: sy(spriteTop + 16), leader: true)
    },
    Panel(caption: "same session, new Doctor") { ctx, o, sy in
        at(sprite(eleven), ctx, o, bodyX: 75)
        tag("Doctor Eleven", ctx, centerX: o.x + 75 * unit, bottom: sy(spriteTop + 16), leader: true)
    },
], file: "regeneration.png")

// MARK: Icon

/// The icon: Doctor Ten's sonic screwdriver against a Dalick's gunstick, their rays meeting in the middle, in front of
/// the time vortex, on a rounded square like the other universes' icons.
let iconRep = canvas(1024, 1024, bg: nil) { ctx in
    let box = CGRect(x: 100, y: 100, width: 824, height: 824)
    let path = CGPath(roundedRect: box, cornerWidth: 185, cornerHeight: 185, transform: nil)
    ctx.saveGState(); ctx.addPath(path); ctx.clip()
    // The vortex: a deep blue sky with rings of blue and orange cloud round a bright eye, drawn chunky.
    let px = 12, n = 824 / px + 1
    let eye = (x: 0.5, y: 0.66)
    for j in 0..<n {
        for i in 0..<n {
            let u = (Double(i) + 0.5) / Double(n), v = (Double(j) + 0.5) / Double(n)
            let dx = u - eye.x, dy = (v - eye.y) * 1.25
            let r = (dx * dx + dy * dy).squareRoot(), a = atan2(dy, dx)
            let band = sin(r * 34 - a * 2 + 1.2), warm = sin(r * 21 + a * 3)
            var col: UInt32 = r < 0.05 ? 0xE8F2FF : r < 0.09 ? 0x8AB8FF : 0x0C1440
            if r >= 0.09 {
                if band > 0.55 { col = 0x2A4AB8 } else if band > 0.2 { col = 0x1A2A78 }
                if warm > 0.86 && r > 0.18 { col = 0xC86A2A } else if warm > 0.72 && r > 0.18 { col = 0x7A3A3A }
            }
            ctx.setFillColor(hexRGB(col))
            ctx.fill(CGRect(x: box.minX + CGFloat(i * px), y: box.minY + CGFloat(j * px), width: CGFloat(px), height: CGFloat(px)))
        }
    }
    // The floor.
    ctx.setFillColor(hexRGB(0x1A1F33)); ctx.fill(CGRect(x: box.minX, y: box.minY, width: box.width, height: 228))
    ctx.setFillColor(hexRGB(0x6A9AA4)); ctx.fill(CGRect(x: box.minX, y: box.minY + 222, width: box.width, height: 6))
    ctx.restoreGState()

    // The fighters and the fight between them, at 13 screen pixels per sprite pixel.
    let s: CGFloat = 10.5, floorY: CGFloat = box.minY + 222, headroom = 20.0
    let lx = 24.0, rx = 58.0                 // body centres, in sprite pixels from the box's left edge
    let left = Fighter(weapon: dalick.weapon, x: lx, k: 1, top: headroom, side: 1, muzzle: dalick.muzzle,
                       armoured: dalick.armoured, pivot: dalick.weaponPivot).dressed(as: dalick)
    let right = Fighter(weapon: ten.weapon, x: rx, k: 1, top: headroom, side: -1, muzzle: ten.muzzle,
                        armoured: ten.armoured, pivot: ten.weaponPivot).dressed(as: ten)
    let fxW = 80, fxH = Sprite.height + Int(headroom)
    let fx = PixelCanvas(fxW, fxH)
    drawFightFX(fx, t: 0.42, left: left, right: right)
    func body(_ c: PixelCanvas, _ bodyX: Double, flipped: Bool) {
        let x = flipped ? bodyX - (Double(Sprite.width) - Sprite.bodyCenterX) : bodyX - Sprite.bodyCenterX
        ctx.draw(c.makeImage()!, in: CGRect(x: box.minX + 10 + CGFloat(x) * s, y: floorY - 8 * s,
                                           width: CGFloat(Sprite.width) * s, height: CGFloat(Sprite.height) * s))
    }
    body(sprite(dalick, t: 0.42, mode: .working, role: .hit), lx, flipped: false)
    body(sprite(ten, t: 0.42, mode: .working, role: .zap, left: true), rx, flipped: true)
    ctx.draw(fx.makeImage()!, in: CGRect(x: box.minX + 10, y: floorY - 8 * s, width: CGFloat(fxW) * s, height: CGFloat(fxH) * s))
    // A thin edge round the square.
    ctx.addPath(path); ctx.setStrokeColor(hexRGB(0xFFFFFF, 0.12)); ctx.setLineWidth(3); ctx.strokePath()
}
save(iconRep, "icon.png")
}
