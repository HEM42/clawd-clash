import AppKit
import CoreText

// Renders docs/social-preview.png (1280×640, GitHub → Settings → Social preview): a comic cover in slanted panels,
// one per universe, each with a fight in full swing, drawn with the app's own sprite and fight-effect code: Luke and
// Vader's sabers locked under the stars, Thor and Loki trading lightning and magic, Batman against the Joker, Doctor
// Ten's sonic on a Dalick in the time vortex's blue, Fox Clawder against the Grey in the woods at night. CLAWD CLASH
// runs across them all, coloured by the panel each part is in, with a sound effect in each panel and the tagline in a
// caption box. A new universe adds a panel: a cut, a centre, a sky, a floor, a fight, a sound and a face.
//   swiftc Sources/App/{Pixel,Characters,Fights,Persona,Theme,Pose,Locations,Cast,Habits,Drills,Icon,Rides}.swift \
//          Sources/App/Universes/**/*.swift Sources/Shared/*.swift Tools/MakeSocial/main.swift -o build/makesocial \
//          && build/makesocial docs/social-preview.png

let W: CGFloat = 1280, H: CGFloat = 640
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(W), pixelsHigh: Int(H), bitsPerSample: 8, samplesPerPixel: 4,
                           hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
let gc = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.current = gc
let ctx = gc.cgContext
ctx.interpolationQuality = .none

func hex(_ h: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(h >> 16 & 0xFF) / 255, green: CGFloat(h >> 8 & 0xFF) / 255, blue: CGFloat(h & 0xFF) / 255, alpha: a)
}
func rnd(_ i: Int) -> CGFloat { CGFloat(noise(i)) }
let inkColor = hex(0x111018)

/// STYLE=1 slanted panels (the default), 2 a comic page of square panels, 3 a line-up on the horizon, 4 windows into
/// each universe's own place, 5 everyone in one Clawd Royale brawl. Every style takes `verses`, so another universe
/// is another entry.
let style = Int(ProcessInfo.processInfo.environment["STYLE"] ?? "") ?? 1
struct Verse { let name: String; let hero: Cast; let villain: Cast; let place: Location; let sound: String
               let burst: UInt32; let face: (UInt32, UInt32); let sky: (UInt32, UInt32); var caption = "" }
let allVerses: [Verse] = [
    Verse(name: "STAR CLAWDS", hero: .hero(SWHero.luke), villain: .villain(SWVillain.vader), place: .deathStar, sound: "VWOOM!",
          burst: 0xFFE14D, face: (0xFFFFFF, 0xFF6A5A), sky: (0x7A0E1E, 0x14050C), caption: "A LONG TIME AGO…"),
    Verse(name: "MARVELOUS CLAWDS", hero: .hero(MarvelHero.thor), villain: .villain(MarvelVillain.loki), place: .avengersTower, sound: "KRAKOOM!",
          burst: 0x7FD0FF, face: (0xFFF6B0, 0xFFC21A), sky: (0xC21E2E, 0x0E2A6E), caption: "MEANWHILE, AT THE TOWER…"),
    Verse(name: "DETECTIVE CLAWDS", hero: .hero(DCHero.batman), villain: .villain(DCVillain.joker), place: .gotham, sound: "BLAM!",
          burst: 0xFF5A8A, face: (0xFFFFFF, 0xC8F06A), sky: (0x2E4482, 0x0A1028), caption: "LATER, IN GOTHAMBURG…"),
    Verse(name: "DOCTOR CLAWD", hero: .hero(DoctorHero.doctorTen), villain: .villain(DoctorVillain.dalick), place: .skarro, sound: "VWORP!",
          burst: 0xFFB45A, face: (0xFFFFFF, 0x8FB8FF), sky: (0x2A4AC8, 0x0A0A2E), caption: "SOMEWHERE IN TIME…"),
    Verse(name: "THE CLAWD FILES", hero: .hero(FilesHero.foxClawder), villain: .villain(FilesVillain.grey), place: .bellefleurWoods, sound: "ZZZT!",
          burst: 0x9AF0C8, face: (0xFFFFFF, 0x6AE88A), sky: (0x2A5A44, 0x050A08), caption: "THE TRUTH IS OUT THERE…"),
]
/// `UNIVERSES=8` repeats the list up to that many, to see how a style holds up with more universes.
let versesWanted = Int(ProcessInfo.processInfo.environment["UNIVERSES"] ?? "") ?? 0
let verses: [Verse] = versesWanted > 0 ? (0..<versesWanted).map { allVerses[$0 % allVerses.count] } : allVerses

// MARK: The panels

/// Where the gutters cross the bottom and top edges, and how far they lean.
let cuts: [CGFloat] = [-200, 296, 552, 808, 1064, 1500], tilt: CGFloat = 60
let panels = cuts.count - 1
/// Panel `i` (0 Star Wars, 1 Marvel, 2 DC, 3 Doctor Clawd, 4 The Clawd Files).
func panel(_ i: Int) -> CGPath {
    let p = CGMutablePath()
    p.addLines(between: [CGPoint(x: cuts[i] - tilt, y: 0), CGPoint(x: cuts[i + 1] - tilt, y: 0),
                         CGPoint(x: cuts[i + 1] + tilt, y: H), CGPoint(x: cuts[i] + tilt, y: H)])
    p.closeSubpath()
    return p
}
/// Each panel's middle, along the ground.
let centres: [CGFloat] = [138, 384, 640, 896, 1150]

func halftone(_ r: CGRect, color: CGColor, cell: CGFloat, dot: (CGPoint) -> CGFloat) {
    var y = r.minY, row = 0
    while y < r.maxY + cell {
        var x = r.minX + (row % 2 == 0 ? 0 : cell / 2)
        while x < r.maxX + cell {
            let d = dot(CGPoint(x: x, y: y)) * cell
            if d > 0.5 { ctx.addEllipse(in: CGRect(x: x - d / 2, y: y - d / 2, width: d, height: d)) }
            x += cell
        }
        y += cell; row += 1
    }
    ctx.setFillColor(color); ctx.fillPath()
}

let ground: CGFloat = 108          // where the fighters stand
if style == 1 {
let skies: [(UInt32, UInt32)] = [(0x7A0E1E, 0x14050C), (0xC21E2E, 0x0E2A6E), (0x2E4482, 0x0A1028), (0x2A4AC8, 0x0A0A2E),
                                 (0x2A5A44, 0x050A08)]
let floors: [UInt32] = [0x22141C, 0x16203E, 0x121A30, 0x141A3A, 0x0E1A14]
for i in 0..<panels {
    ctx.saveGState()
    ctx.addPath(panel(i)); ctx.clip()
    let sky = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [hex(skies[i].0), hex(skies[i].1)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: 0), options: [])
    // Speed rays bursting from where the fight is.
    let focus = CGPoint(x: centres[i], y: ground + 110)
    for r in 0..<36 {
        let a = CGFloat(r) / 36 * 2 * .pi, w = 0.035 + 0.03 * rnd(r + i * 50)
        ctx.move(to: focus)
        ctx.addLine(to: CGPoint(x: focus.x + cos(a - w) * 1500, y: focus.y + sin(a - w) * 1500))
        ctx.addLine(to: CGPoint(x: focus.x + cos(a + w) * 1500, y: focus.y + sin(a + w) * 1500))
        ctx.closePath()
    }
    ctx.setFillColor(hex(0xFFFFFF, 0.06)); ctx.fillPath()
    halftone(CGRect(x: 0, y: 0, width: W, height: H), color: hex(0x000000, 0.2), cell: 14) { p in 0.15 + 0.45 * (1 - p.y / H) }
    if i == 0 || i == 4 {
        for s in 0..<60 {   // pixel stars
            let big = rnd(7 + s * 3 + 2) > 0.85, d: CGFloat = big ? 6 : 3
            let x = (i == 0 ? 0 : W * 0.75) + rnd(7 + s * 3 + i) * W * 0.3, y = 250 + rnd(7 + s * 3 + 1) * (H - 250)
            ctx.setFillColor(hex(0xFFFFFF, big ? 0.95 : 0.55))
            ctx.fill(CGRect(x: (x / d).rounded() * d, y: (y / d).rounded() * d, width: d, height: d))
        }
    }
    if i == 2 {
        let signal = CGPoint(x: 700, y: 410)   // high in the sky, under the name
        ctx.setFillColor(hex(0xFFE36B, 0.14))
        ctx.move(to: CGPoint(x: 740, y: 0)); ctx.addLine(to: CGPoint(x: signal.x - 36, y: signal.y)); ctx.addLine(to: CGPoint(x: signal.x + 36, y: signal.y))
        ctx.closePath(); ctx.fillPath()
        ctx.setFillColor(hex(0xFFE36B, 0.92)); ctx.fillEllipse(in: CGRect(x: signal.x - 36, y: signal.y - 25, width: 72, height: 50))
        ctx.addPath(cowlMaskPath(signal, width: 57)); ctx.setFillColor(inkColor); ctx.fillPath(using: .evenOdd)
    }
    if i == 4 {   // a saucer's beam slanting down through the trees
        ctx.setFillColor(hex(0xC8FFE0, 0.12))
        ctx.move(to: CGPoint(x: 1120, y: 440)); ctx.addLine(to: CGPoint(x: 1180, y: 440))
        ctx.addLine(to: CGPoint(x: 1260, y: ground)); ctx.addLine(to: CGPoint(x: 1040, y: ground)); ctx.closePath(); ctx.fillPath()
    }
    // The ground each fight stands on.
    ctx.setFillColor(hex(floors[i])); ctx.fill(CGRect(x: 0, y: 0, width: W, height: ground))
    ctx.setFillColor(hex(0xD97757)); ctx.fill(CGRect(x: 0, y: ground - 4, width: W, height: 4))   // Claude-orange horizon
    ctx.restoreGState()
}
}

// MARK: The fights

/// A face-off: `left` facing right, `right` facing left, `dist` sprite pixels apart, `p` image pixels a sprite pixel,
/// at moment `t`, with the fight effects between them, as the app draws them.
func fight(_ left: Cast, _ right: Cast, centre: CGFloat, dist: Double, p: CGFloat, t: Double, floor: CGFloat = ground) {
    let ground = floor
    let (lr, rr) = fightRoles(left.weapon, right.weapon)
    let headroom = 30.0, margin = 30.0
    func sprite(_ who: Cast, role: FightRole, x: CGFloat, mirrored: Bool) {
        let c = PixelCanvas(72, 52)
        who.draw(c, t: t, mode: .working, walking: false, role: role, asSession: true)
        if mirrored { c.flipHorizontally() }
        c.addOutline(C(0xFFFFFF, 0.92))
        let bodyX = (mirrored ? CGFloat(c.w) - 28 : 28) * p
        ctx.draw(c.makeImage()!, in: CGRect(x: x - bodyX, y: ground - 8 * p, width: CGFloat(c.w) * p, height: CGFloat(c.h) * p))
    }
    let lx = centre - CGFloat(dist) / 2 * p, rx = centre + CGFloat(dist) / 2 * p
    sprite(left, role: lr, x: lx, mirrored: false)
    sprite(right, role: rr, x: rx, mirrored: true)
    func fighter(_ who: Cast, x: Double, side: Double) -> Fighter {
        Fighter(weapon: who.weapon, x: x, k: 1, top: headroom, side: side, muzzle: who.muzzle, armoured: who.armoured,
                pivot: who.weaponPivot).dressed(as: who)
    }
    let fx = PixelCanvas(Int(dist + margin * 2), 52 + Int(headroom))
    drawFightFX(fx, t: t, left: fighter(left, x: margin, side: 1), right: fighter(right, x: margin + dist, side: -1))
    ctx.draw(fx.makeImage()!, in: CGRect(x: lx - CGFloat(margin) * p, y: ground - 8 * p, width: CGFloat(fx.w) * p, height: CGFloat(fx.h) * p))
}

let p: CGFloat = 3.1
if style == 1 {
fight(.hero(SWHero.luke), .villain(SWVillain.vader), centre: centres[0], dist: 40, p: p, t: 0.55)
fight(.hero(MarvelHero.thor), .villain(MarvelVillain.loki), centre: centres[1], dist: 46, p: p, t: 0.35)
fight(.hero(DCHero.batman), .villain(DCVillain.joker), centre: centres[2], dist: 46, p: p, t: 0.3)
fight(.hero(DoctorHero.doctorTen), .villain(DoctorVillain.dalick), centre: centres[3], dist: 46, p: p, t: 0.42)
fight(.hero(FilesHero.foxClawder), .villain(FilesVillain.grey), centre: centres[4], dist: 44, p: p, t: 0.42)
}

// MARK: Lettering

/// The outline of `s` in Futura Condensed ExtraBold, centred on the origin.
func letters(_ s: String) -> CGPath {
    let font = CTFontCreateWithName("Futura-CondensedExtraBold" as CFString, 200, nil)
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: s, attributes: [.font: font]))
    let path = CGMutablePath()
    for run in CTLineGetGlyphRuns(line) as! [CTRun] {
        let count = CTRunGetGlyphCount(run)
        var glyphs = [CGGlyph](repeating: 0, count: count), at = [CGPoint](repeating: .zero, count: count)
        CTRunGetGlyphs(run, CFRange(location: 0, length: count), &glyphs)
        CTRunGetPositions(run, CFRange(location: 0, length: count), &at)
        for i in 0..<count {
            if let g = CTFontCreatePathForGlyph(font, glyphs[i], nil) { path.addPath(g, transform: CGAffineTransform(translationX: at[i].x, y: at[i].y)) }
        }
    }
    let b = path.boundingBox
    var t = CGAffineTransform(translationX: -b.midX, y: -b.midY)
    return path.copy(using: &t)!
}

/// `s` as big as fits `width`×`height`, centred on `c` and tilted by `angle`: a block extrusion, a thick inkColor outline
/// and a face in `faces` (top colour, bottom colour), one per panel, or the same everywhere if there's one.
func word(_ s: String, at c: CGPoint, width: CGFloat, height: CGFloat, angle: CGFloat, depth: Int, faces: [(UInt32, UInt32)]) {
    var path = letters(s)
    let k = min(width / path.boundingBox.width, height / path.boundingBox.height)
    var t = CGAffineTransform(scaleX: k, y: k).concatenating(CGAffineTransform(rotationAngle: angle))
        .concatenating(CGAffineTransform(translationX: c.x, y: c.y))
    path = path.copy(using: &t)!
    let b = path.boundingBox, step = b.height / 70, line = max(4, b.height * 0.14)
    ctx.saveGState()
    ctx.setLineJoin(.round)
    for i in stride(from: depth, through: 1, by: -1) {
        ctx.saveGState()
        ctx.translateBy(x: CGFloat(i) * step * 0.6, y: -CGFloat(i) * step)
        ctx.addPath(path); ctx.setStrokeColor(inkColor); ctx.setLineWidth(line); ctx.strokePath()
        ctx.addPath(path); ctx.setFillColor(inkColor); ctx.fillPath()
        ctx.restoreGState()
    }
    ctx.addPath(path); ctx.setStrokeColor(inkColor); ctx.setLineWidth(line); ctx.strokePath()
    for i in 0..<panels {
        let f = faces[min(i, faces.count - 1)]
        ctx.saveGState()
        if faces.count > 1 { ctx.addPath(panel(i)); ctx.clip() }
        ctx.addPath(path); ctx.clip()
        let face = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [hex(f.0), hex(f.1)] as CFArray, locations: [0.2, 1])!
        ctx.drawLinearGradient(face, start: CGPoint(x: 0, y: b.maxY), end: CGPoint(x: 0, y: b.minY), options: [])
        ctx.setFillColor(hex(0xFFFFFF, 0.3)); ctx.fill(CGRect(x: b.minX, y: b.midY + b.height * 0.1, width: b.width, height: b.height * 0.09))
        ctx.restoreGState()
        if faces.count == 1 { break }
    }
    ctx.restoreGState()
}

/// A jagged starburst behind a sound effect.
func burst(_ c: CGPoint, r: CGFloat, color: UInt32, seed: Int) {
    let path = CGMutablePath(), n = 14
    for k in 0..<(n * 2) {
        let a = CGFloat(k) / CGFloat(n * 2) * 2 * .pi
        let rr = k % 2 == 0 ? r * (0.9 + 0.25 * rnd(seed + k)) : r * 0.6
        let pt = CGPoint(x: c.x + cos(a) * rr * 1.25, y: c.y + sin(a) * rr * 0.8)
        if k == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
    }
    path.closeSubpath()
    ctx.saveGState()
    ctx.addPath(path); ctx.setFillColor(hex(color)); ctx.fillPath()
    ctx.addPath(path); ctx.setStrokeColor(inkColor); ctx.setLineWidth(5); ctx.setLineJoin(.round); ctx.strokePath()
    ctx.restoreGState()
}

// A sound effect in each panel, over the fight.
let sounds: [(String, UInt32, (UInt32, UInt32), CGFloat)] = [
    ("VWOOM!", 0xFFE14D, (0xFFFFFF, 0xFF6A5A), 0.12), ("KRAKOOM!", 0x7FD0FF, (0xFFF6B0, 0xFFC21A), -0.1),
    ("BLAM!", 0xFF5A8A, (0xFFFFFF, 0xC8F06A), 0.1), ("VWORP!", 0xFFB45A, (0xFFFFFF, 0x8FB8FF), -0.08),
    ("ZZZT!", 0x9AF0C8, (0xFFFFFF, 0x6AE88A), 0.1),
]
for (i, s) in sounds.enumerated() where style == 1 {
    let c = CGPoint(x: centres[i] + (i == 2 ? -30 : 0), y: 330)
    burst(c, r: 38, color: s.1, seed: 11 + i * 20)
    word(s.0, at: c, width: 74, height: 32, angle: s.3, depth: 3, faces: [s.2])
}

// MARK: The other styles

/// A comic panel's sky: a gradient, rays from `focus`, halftone shading.
func panelSky(_ r: CGRect, _ sky: (UInt32, UInt32), focus: CGPoint, seed: Int) {
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [hex(sky.0), hex(sky.1)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: r.maxY), end: CGPoint(x: 0, y: r.minY), options: [])
    for k in 0..<30 {
        let a = CGFloat(k) / 30 * 2 * .pi, w = 0.04 + 0.03 * rnd(k + seed * 50)
        ctx.move(to: focus)
        ctx.addLine(to: CGPoint(x: focus.x + cos(a - w) * 1500, y: focus.y + sin(a - w) * 1500))
        ctx.addLine(to: CGPoint(x: focus.x + cos(a + w) * 1500, y: focus.y + sin(a + w) * 1500))
        ctx.closePath()
    }
    ctx.setFillColor(hex(0xFFFFFF, 0.06)); ctx.fillPath()
    halftone(r, color: hex(0x000000, 0.2), cell: 12) { q in 0.15 + 0.45 * (1 - (q.y - r.minY) / r.height) }
}

/// Cells for `n` items in `area`: one row up to `perRow`, then more rows, the last one centred.
func grid(_ n: Int, in area: CGRect, perRow: Int, gap: CGFloat) -> [CGRect] {
    let cols = min(n, perRow), rows = (n + cols - 1) / cols
    let cw = (area.width - gap * CGFloat(cols - 1)) / CGFloat(cols), ch = (area.height - gap * CGFloat(rows - 1)) / CGFloat(rows)
    return (0..<n).map { i in
        let r = i / cols, c = i % cols, inRow = min(cols, n - r * cols)
        let off = CGFloat(cols - inRow) * (cw + gap) / 2
        return CGRect(x: area.minX + off + CGFloat(c) * (cw + gap), y: area.maxY - CGFloat(r + 1) * ch - CGFloat(r) * gap, width: cw, height: ch)
    }
}

let full = CGRect(x: 0, y: 0, width: W, height: H)
var titleY: CGFloat = 522, titleH: CGFloat = 138, titleFaces: [(UInt32, UInt32)] =
    [(0xFFFFFF, 0xFF8A8A), (0xFFFFFF, 0x8FB8FF), (0xFFF3B0, 0xFFC21A), (0xFFFFFF, 0x8AB0FF), (0xE8FFF0, 0x6AE88A)]

switch style {
case 2:   // a comic page: square panels in rows, the title over them
    ctx.setFillColor(hex(0xF4ECD8)); ctx.fill(full)
    halftone(full, color: hex(0xE0D2B0), cell: 10) { _ in 0.35 }
    for (i, (v, cell)) in zip(verses, grid(verses.count, in: CGRect(x: 30, y: 96, width: W - 60, height: 372), perRow: 3, gap: 14)).enumerated() {
        ctx.saveGState(); ctx.clip(to: cell)
        let gy = cell.minY + cell.height * 0.2
        panelSky(cell, v.sky, focus: CGPoint(x: cell.midX, y: gy + 60), seed: i)
        ctx.setFillColor(hex(0x161420)); ctx.fill(CGRect(x: cell.minX, y: cell.minY, width: cell.width, height: gy - cell.minY))
        ctx.setFillColor(hex(0xD97757)); ctx.fill(CGRect(x: cell.minX, y: gy - 3, width: cell.width, height: 3))
        let pp = cell.height * 0.74 / 44
        fight(v.hero, v.villain, centre: cell.midX, dist: 44, p: pp, t: 0.42, floor: gy)
        burst(CGPoint(x: cell.minX + 62, y: cell.maxY - 36), r: 26, color: v.burst, seed: 11 + i * 20)
        word(v.sound, at: CGPoint(x: cell.minX + 62, y: cell.maxY - 36), width: 54, height: 22, angle: 0.1, depth: 2, faces: [v.face])
        ctx.restoreGState()
        ctx.setStrokeColor(inkColor); ctx.setLineWidth(7); ctx.stroke(cell)
    }
    titleY = 555; titleH = 120; titleFaces = [(0xFFF3B0, 0xFFC21A)]
case 3:   // one line-up on the horizon, a face-off per universe
    let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [hex(0x2A1A4A), hex(0x05060E)] as CFArray, locations: [0, 1])!
    ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: H), end: CGPoint(x: 0, y: 0), options: [])
    for k in 0..<150 {
        let big = rnd(k * 3 + 2) > 0.85
        ctx.setFillColor(hex(0xFFFFFF, big ? 0.9 : 0.45))
        ctx.fill(CGRect(x: rnd(k * 3) * W, y: 200 + rnd(k * 3 + 1) * 440, width: big ? 4 : 2, height: big ? 4 : 2))
    }
    let gy: CGFloat = 170
    ctx.setFillColor(hex(0x14121E)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: gy))
    ctx.setFillColor(hex(0xD97757)); ctx.fill(CGRect(x: 0, y: gy - 4, width: W, height: 4))
    let n = CGFloat(verses.count), pairW: CGFloat = 40 + 40, gapPairs: CGFloat = 14
    let pp = min(4, (W - 80) / (n * pairW + (n - 1) * gapPairs))
    let span = n * pairW * pp + (n - 1) * gapPairs * pp
    for (i, v) in verses.enumerated() {
        let c = (W - span) / 2 + (CGFloat(i) + 0.5) * pairW * pp + CGFloat(i) * gapPairs * pp
        fight(v.hero, v.villain, centre: c, dist: 40, p: pp, t: 0.42, floor: gy)
    }
    titleY = 470; titleH = 130; titleFaces = [(0xFFF3B0, 0xFFC21A)]
case 4:   // windows into each universe's own place
    ctx.setFillColor(hex(0x17151F)); ctx.fill(full)
    halftone(full, color: hex(0x23202E), cell: 12) { _ in 0.5 }
    for (v, cell) in zip(verses, grid(verses.count, in: CGRect(x: 34, y: 120, width: W - 68, height: 330), perRow: verses.count <= 5 ? 5 : 4, gap: 18)) {
        let pic = CGRect(x: cell.minX, y: cell.minY + 34, width: cell.width, height: cell.height - 34)
        let px: CGFloat = pic.height > 200 ? 3 : 1.5   // small windows draw their place finer, so it still has rows to work with
        let pw = Int(pic.width / px), ph = Int(pic.height / px), floorRows = Int(36 / px)
        let still = PixelCanvas(pw, ph); v.place.drawStatic(still, floorRows: floorRows)
        let moving = PixelCanvas(pw, ph); v.place.drawAnimated(moving, floorRows: floorRows, t: 1.3)
        ctx.saveGState(); ctx.clip(to: pic)
        for img in [still.makeImage(), moving.makeImage()].compactMap({ $0 }) { ctx.draw(img, in: pic) }
        fight(v.hero, v.villain, centre: pic.midX, dist: 34, p: min(2.3, pic.height / 110), t: 0.42, floor: pic.minY + CGFloat(floorRows) * px * 0.6)
        ctx.restoreGState()
        ctx.setStrokeColor(inkColor); ctx.setLineWidth(10); ctx.stroke(pic)
        ctx.setStrokeColor(hex(0xFFFFFF, 0.9)); ctx.setLineWidth(3); ctx.stroke(pic.insetBy(dx: -6, dy: -6))
        let label = NSAttributedString(string: v.name, attributes: [.font: NSFont(name: "Futura-Bold", size: 16) ?? .boldSystemFont(ofSize: 16),
                                                                    .foregroundColor: NSColor.white, .kern: 1.5])
        label.draw(at: NSPoint(x: cell.midX - label.size().width / 2, y: cell.minY + 4))
    }
    titleY = 548; titleH = 120; titleFaces = [(0xFFF3B0, 0xFFC21A)]
case 5:   // Clawd Royale: everyone in one brawl, across universes
    let gy: CGFloat = 112
    panelSky(full, (0x5A1E8A, 0x0A0614), focus: CGPoint(x: W / 2, y: gy + 120), seed: 9)
    ctx.setFillColor(hex(0x1A1424)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: gy))
    ctx.setFillColor(hex(0xD97757)); ctx.fill(CGRect(x: 0, y: gy - 4, width: W, height: 4))
    // Mixed pairs: each hero against another universe's villain.
    let n = verses.count
    let pairs = (0..<n).map { i in (verses[i].hero, verses[(i + 1) % n].villain) }
    let pp = min(3.6, (W - 60) / (CGFloat(n) * 74))
    for (i, pr) in pairs.enumerated() {
        let c = 30 + (CGFloat(i) + 0.5) * (W - 60) / CGFloat(n)
        fight(pr.0, pr.1, centre: c, dist: 34, p: pp, t: 0.35 + 0.07 * Double(i), floor: gy)
    }
    burst(CGPoint(x: W / 2, y: 365), r: 54, color: 0xFFE14D, seed: 3)
    word("CLASH!", at: CGPoint(x: W / 2, y: 365), width: 110, height: 42, angle: -0.08, depth: 4, faces: [(0xFFFFFF, 0xFF6A5A)])
    titleFaces = [(0xFFF3B0, 0xFFC21A)]
case 6:   // a comic page: a masthead, then panels of uneven widths with slanted gutters, rows as needed
    ctx.setFillColor(hex(0xF6F0E0)); ctx.fill(full)
    // The masthead: an issue box on the left, the title, a banner on the right.
    let mast = CGRect(x: 24, y: 494, width: W - 48, height: 122)
    ctx.setFillColor(hex(0xD8342E)); ctx.fill(mast)
    halftone(mast, color: hex(0xB0221E), cell: 9) { _ in 0.4 }
    ctx.setStrokeColor(inkColor); ctx.setLineWidth(6); ctx.stroke(mast)
    let issue = CGRect(x: mast.minX + 14, y: mast.minY + 14, width: 94, height: mast.height - 28)
    ctx.setFillColor(hex(0xFFFFFF)); ctx.fill(issue); ctx.setStrokeColor(inkColor); ctx.setLineWidth(4); ctx.stroke(issue)
    for (txt, size, y) in [("NO.", 15.0, 62.0), ("1", 44.0, 18.0)] as [(String, CGFloat, CGFloat)] {
        let a = NSAttributedString(string: txt, attributes: [.font: NSFont(name: "Futura-CondensedExtraBold", size: size) ?? .boldSystemFont(ofSize: size),
                                                             .foregroundColor: NSColor(cgColor: inkColor)!])
        a.draw(at: NSPoint(x: issue.midX - a.size().width / 2, y: issue.minY + y))
    }
    let free = NSAttributedString(string: "FREE", attributes: [.font: NSFont(name: "Futura-Bold", size: 13) ?? .boldSystemFont(ofSize: 13),
                                                              .foregroundColor: NSColor(cgColor: hex(0xD8342E))!])
    free.draw(at: NSPoint(x: issue.midX - free.size().width / 2, y: issue.minY + 4))
    let banner = NSAttributedString(string: "★ MANY UNIVERSES ★", attributes: [.font: NSFont(name: "Futura-Bold", size: 16) ?? .boldSystemFont(ofSize: 16),
                                                                               .foregroundColor: NSColor.white, .kern: 2])
    banner.draw(at: NSPoint(x: mast.maxX - banner.size().width - 16, y: mast.maxY - banner.size().height - 10))
    // The panels.
    let n = verses.count, perRow = n <= 3 ? n : (n <= 6 ? (n + 1) / 2 : 4)
    let rows = (n + perRow - 1) / perRow
    let area = CGRect(x: 24, y: 92, width: W - 48, height: 388), gut: CGFloat = 12
    let rowH = (area.height - gut * CGFloat(rows - 1)) / CGFloat(rows)
    let weights: [CGFloat] = [1.25, 0.85, 1.05, 0.95]
    var idx = 0
    for r in 0..<rows {
        let inRow = min(perRow, n - idx)
        let ws = (0..<inRow).map { weights[($0 + r) % weights.count] }, total = ws.reduce(0, +)
        let y1 = area.maxY - CGFloat(r) * (rowH + gut), y0 = y1 - rowH
        let free = area.width - gut * CGFloat(inRow - 1)
        var x = area.minX
        for k in 0..<inRow {
            let v = verses[idx], w = free * ws[k] / total
            // slanted gutters: each inner edge leans, alternately
            let lean: CGFloat = 16
            let left0 = k == 0 ? x : x - (k % 2 == 0 ? lean : -lean), left1 = k == 0 ? x : x + (k % 2 == 0 ? lean : -lean)
            let rx = x + w, right0 = k == inRow - 1 ? rx : rx - ((k + 1) % 2 == 0 ? lean : -lean), right1 = k == inRow - 1 ? rx : rx + ((k + 1) % 2 == 0 ? lean : -lean)
            let shape = CGMutablePath()
            shape.addLines(between: [CGPoint(x: left0, y: y0), CGPoint(x: right0, y: y0), CGPoint(x: right1, y: y1), CGPoint(x: left1, y: y1)])
            shape.closeSubpath()
            let box = CGRect(x: x, y: y0, width: w, height: rowH)
            ctx.saveGState(); ctx.addPath(shape); ctx.clip()
            let gy = y0 + rowH * 0.2
            panelSky(box.insetBy(dx: -lean, dy: 0), v.sky, focus: CGPoint(x: box.midX, y: gy + 70), seed: idx)
            ctx.setFillColor(hex(0x161420)); ctx.fill(CGRect(x: box.minX - lean, y: y0, width: w + lean * 2, height: gy - y0))
            ctx.setFillColor(hex(0xD97757)); ctx.fill(CGRect(x: box.minX - lean, y: gy - 3, width: w + lean * 2, height: 3))
            fight(v.hero, v.villain, centre: box.midX + 10, dist: 42, p: rowH * 0.72 / 44, t: 0.42, floor: gy)
            // The narration box, top left.
            let cap = NSAttributedString(string: v.caption, attributes: [.font: NSFont(name: "Futura-Bold", size: 11) ?? .boldSystemFont(ofSize: 11),
                                                                         .foregroundColor: NSColor(cgColor: inkColor)!])
            let cb = CGRect(x: max(left1, left0) + 8, y: y1 - cap.size().height - 14, width: cap.size().width + 14, height: cap.size().height + 6)
            ctx.setFillColor(hex(0xFFE96B)); ctx.fill(cb); ctx.setStrokeColor(inkColor); ctx.setLineWidth(2.5); ctx.stroke(cb)
            cap.draw(at: NSPoint(x: cb.minX + 7, y: cb.minY + 3))
            ctx.restoreGState()
            ctx.addPath(shape); ctx.setStrokeColor(inkColor); ctx.setLineWidth(6); ctx.strokePath()
            idx += 1; x += w + gut
        }
    }
    // The sound effects, over the borders.
    idx = 0
    for r in 0..<rows {
        let inRow = min(perRow, n - idx)
        let ws = (0..<inRow).map { weights[($0 + r) % weights.count] }, total = ws.reduce(0, +)
        let y1 = area.maxY - CGFloat(r) * (rowH + gut)
        let free = area.width - gut * CGFloat(inRow - 1)
        var x = area.minX
        for k in 0..<inRow {
            let v = verses[idx], w = free * ws[k] / total
            let c = CGPoint(x: x + w - 44, y: y1 - 26)
            burst(c, r: 28, color: v.burst, seed: 11 + idx * 20)
            word(v.sound, at: c, width: 58, height: 24, angle: k % 2 == 0 ? 0.12 : -0.1, depth: 2, faces: [v.face])
            idx += 1; x += w + gut
        }
    }
    titleY = 556; titleH = 96; titleFaces = [(0xFFF3B0, 0xFFC21A)]
default:
    break
}

// The name, across all the panels.
word("CLAWD CLASH", at: CGPoint(x: 640, y: titleY), width: 1060 * titleH / 138, height: titleH, angle: style == 1 ? 0.035 : 0.02, depth: 12,
     faces: titleFaces)

// The gutters, over everything, cutting through the name too.
for i in 1..<panels where style == 1 {
    ctx.move(to: CGPoint(x: cuts[i] - tilt, y: 0)); ctx.addLine(to: CGPoint(x: cuts[i] + tilt, y: H))
    ctx.setStrokeColor(inkColor); ctx.setLineWidth(18); ctx.strokePath()
    ctx.move(to: CGPoint(x: cuts[i] - tilt, y: 0)); ctx.addLine(to: CGPoint(x: cuts[i] + tilt, y: H))
    ctx.setStrokeColor(hex(0xFFFFFF)); ctx.setLineWidth(9); ctx.strokePath()
}

// The tagline in a caption box, along the bottom.
let tagline = "Your AI coding sessions as a pixel-art battle across many universes"
/// The tagline at the largest size (up to 25 pt) that fits the cover with a margin.
func taglineText(_ size: CGFloat) -> NSAttributedString {
    let font = NSFont(name: "Futura-Bold", size: size) ?? .boldSystemFont(ofSize: size)
    return NSAttributedString(string: tagline.uppercased(), attributes: [.font: font, .foregroundColor: NSColor(cgColor: inkColor)!, .kern: 1])
}
var tagSize: CGFloat = 25
while tagSize > 12 && taglineText(tagSize).size().width > W - 140 { tagSize -= 1 }
let text = taglineText(tagSize)
let ts = text.size()
let box = CGRect(x: (W - ts.width) / 2 - 22, y: 26, width: ts.width + 44, height: ts.height + 18)
ctx.saveGState()
ctx.setFillColor(inkColor); ctx.fill(box.offsetBy(dx: 6, dy: -6))
ctx.setFillColor(hex(0xFFE96B)); ctx.fill(box)
ctx.setStrokeColor(inkColor); ctx.setLineWidth(5); ctx.stroke(box)
ctx.restoreGState()
text.draw(at: NSPoint(x: box.minX + 22, y: box.minY + 9))

// A frame round the whole cover.
ctx.setStrokeColor(inkColor); ctx.setLineWidth(14); ctx.stroke(CGRect(x: 0, y: 0, width: W, height: H))

NSGraphicsContext.current = nil
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
