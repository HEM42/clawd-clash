import AppKit

// Renders a universe's showcase README's own pictures with the app's sprite code: its icon and the strips showing its
// set pieces. Doctor Clawd: the TARDIS picking someone up, the Weeping Angle moving while nobody looks, a regeneration.
// The Clawd Files: the sedan picking someone up, missing time, the saucer taking an alien home. Stevie Clawdberg: the
// DeLorean picking someone up, 88 mph, the mothership's light. (The roster,
// locations, desktop and social preview come from Tools/RenderDocs, the transitions sheet from Tools/Transitions; the
// window, screen saver and hover shots are CLAWD_SHOT captures of a Playground run.)
//   swiftc -swift-version 5 Sources/App/{Pixel,Characters,Fights,Persona,Theme,Pose,Locations,Cast,Habits,Drills,Icon,Rides}.swift \
//          Sources/App/Universes/**/*.swift Sources/Shared/*.swift Tools/RenderShowcase/main.swift -o build/rendershowcase
//   build/rendershowcase docs doctor
//   build/rendershowcase docs files
//   build/rendershowcase docs clawdberg

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "docs"
let which = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "doctor"

func hexRGB(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}

func canvas(_ w: Int, _ h: Int, bg: UInt32?, _ draw: (CGContext) -> Void) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h, bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let gc = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = gc
    let ctx = gc.cgContext
    if let bg { ctx.setFillColor(hexRGB(bg)); ctx.fill(CGRect(x: 0, y: 0, width: w, height: h)) }
    ctx.interpolationQuality = .none
    draw(ctx)
    NSGraphicsContext.current = nil
    return rep
}

func save(_ rep: NSBitmapImageRep, _ name: String) {
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(out)/\(name)"))
    print("wrote \(out)/\(name)")
}

/// One character drawn on its own canvas, outlined, facing right (or left).
func sprite(_ who: Cast, t: Double = 0.3, mode: VaderMode = .idle, walking: Bool = false, role: FightRole = .rest,
            left: Bool = false, flare: Double? = nil) -> PixelCanvas {
    let c = PixelCanvas(Sprite.width, Sprite.height)
    who.draw(c, t: t, mode: mode, walking: walking, role: role, asSession: false)
    if let flare { drawRegeneration(c, k: flare, t: t) }
    if left { c.flipHorizontally() }
    c.addOutline(C(0xFFFFFF, 0.92))
    return c
}

/// A pixel canvas drawn into `ctx` with its top-left at pixel (`x`, `y`) of a frame `unit` screen pixels per pixel,
/// `frameH` pixels tall (CoreGraphics is y-up).
func put(_ c: PixelCanvas, _ ctx: CGContext, x: Double, y: Double, unit: CGFloat, frameH: Int, origin: CGPoint, alpha: CGFloat = 1) {
    guard let img = c.makeImage() else { return }
    ctx.saveGState(); ctx.setAlpha(alpha)
    ctx.draw(img, in: CGRect(x: origin.x + CGFloat(x) * unit, y: origin.y + CGFloat(Double(frameH) - y - Double(c.h)) * unit,
                             width: CGFloat(c.w) * unit, height: CGFloat(c.h) * unit))
    ctx.restoreGState()
}

/// A label box over a character, as the app draws an agent's.
func tag(_ s: String, _ ctx: CGContext, centerX: CGFloat, bottom: CGFloat, leader: Bool = false) {
    let font = leader ? NSFont.monospacedSystemFont(ofSize: 15, weight: .bold) : NSFont.monospacedSystemFont(ofSize: 13, weight: .semibold)
    let text = NSAttributedString(string: s, attributes: [.font: font, .foregroundColor: NSColor.white])
    let ts = text.size()
    let box = CGRect(x: centerX - ts.width / 2 - 8, y: bottom, width: ts.width + 16, height: ts.height + 6)
    let path = CGPath(roundedRect: box, cornerWidth: 6, cornerHeight: 6, transform: nil)
    ctx.addPath(path)
    ctx.setFillColor(leader ? CGColor(gray: 0.08, alpha: 0.85) : CGColor(red: 0.05, green: 0.10, blue: 0.24, alpha: 0.85)); ctx.fillPath()
    ctx.addPath(path)
    ctx.setStrokeColor(leader ? CGColor(gray: 1, alpha: 0.35) : CGColor(red: 0.45, green: 0.65, blue: 1, alpha: 0.5))
    ctx.setLineWidth(1.5); ctx.strokePath()
    NSGraphicsContext.saveGraphicsState()
    text.draw(at: NSPoint(x: box.minX + 8, y: box.minY + 3))
    NSGraphicsContext.restoreGraphicsState()
}

// MARK: Strips

/// A strip of panels in one place, each with its caption above it, the way the Star Clawds page shows the shoot-out.
let pw = 150, ph = 66, unit: CGFloat = 3.2, gap: CGFloat = 10, capH: CGFloat = 34
struct Panel { let caption: String; let draw: (CGContext, CGPoint, (Double) -> CGFloat) -> Void }

func strip(_ place: Location, _ panels: [Panel], file: String) {
    let W = CGFloat(pw) * unit, H = CGFloat(ph) * unit
    let total = CGFloat(panels.count) * W + CGFloat(panels.count + 1) * gap
    let rep = canvas(Int(total), Int(H + capH + gap), bg: 0x121219) { ctx in
        for (i, p) in panels.enumerated() {
            let o = CGPoint(x: gap + CGFloat(i) * (W + gap), y: gap / 2)
            let bg = PixelCanvas(pw, ph); place.drawStatic(bg, floorRows: 8)
            let mv = PixelCanvas(pw, ph); place.drawAnimated(mv, floorRows: 8, t: 1.3 + Double(i) * 0.7)
            for img in [bg.makeImage(), mv.makeImage()].compactMap({ $0 }) { ctx.draw(img, in: CGRect(x: o.x, y: o.y, width: W, height: H)) }
            ctx.saveGState(); ctx.clip(to: CGRect(x: o.x, y: o.y, width: W, height: H))
            p.draw(ctx, o) { y in o.y + CGFloat(Double(ph) - y) * unit }   // pixel row → screen y
            ctx.restoreGState()
            let text = NSAttributedString(string: p.caption, attributes: [
                .font: NSFont.systemFont(ofSize: 17, weight: .bold), .foregroundColor: NSColor(srgbRed: 1, green: 0.91, blue: 0.3, alpha: 1)])
            NSGraphicsContext.saveGraphicsState()
            text.draw(at: NSPoint(x: o.x + (W - text.size().width) / 2, y: o.y + H + 8))
            NSGraphicsContext.restoreGraphicsState()
        }
    }
    save(rep, file)
}

/// Feet on the ground row: a sprite's canvas top for a panel whose floor is 8 rows tall.
let spriteTop = Double(ph - 8 - 44)
func at(_ c: PixelCanvas, _ ctx: CGContext, _ o: CGPoint, bodyX: Double, left: Bool = false, alpha: CGFloat = 1, lift: Double = 0) {
    let x = left ? bodyX - (Double(Sprite.width) - Sprite.bodyCenterX) : bodyX - Sprite.bodyCenterX
    put(c, ctx, x: x, y: spriteTop - lift, unit: unit, frameH: ph, origin: o, alpha: alpha)
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

if which == "files" { filesShowcase() } else if which == "clawdberg" { clawdbergShowcase() } else { doctorShowcase() }
