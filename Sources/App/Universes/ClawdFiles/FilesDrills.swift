import Foundation

// The Clawd Files' own solo practice (`UniverseModule.drills`): the agents at the FBI's firing range, Scrawly reading a
// case file, the Lone Gunclawds hacking, Skinnard's jumping jacks and Queequeg chasing his tail.

let filesBespokeDrills: [Cast: BespokeDrill] = {
    var drills: [Cast: BespokeDrill] = [
        .hero(FilesHero.danaScrawly): drawCaseFile,
        .hero(FilesHero.skinnard): drawJumpingJacks,
        .hero(FilesHero.queequeg): drawTailChase,
    ]
    for h in [FilesHero.foxClawder, .doggedd, .reyez, .einstine, .millar, .jeffreySpendr, .leylaHarriclaw] {
        drills[.hero(h)] = drawFiringRange
    }
    for h in [FilesHero.bytes, .frohack, .lanky] { drills[.hero(h)] = drawHacking }
    return drills
}()

/// The firing range: shooting straight ahead at a paper target on its stand, a new hole in it with every shot (the
/// holes clustering round the middle).
private func drawFiringRange(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    drawPersona(c, who, t: t, mode: .working, walking: false, role: .none)
    let r = setRamp(d)
    guard r > 0.2 else { return }
    let paper = C(0xF2EEE0, r), ink = C(0x2A2A30, r), ring = C(0xC83A3A, r)
    let x0 = 62, top = 27
    c.rect(x0 + 2, 41, 1, 4, C(0x6A5A40, r))                 // the stand
    c.rect(x0, top, 6, 14, paper)
    c.rect(x0 + 1, top + 1, 4, 3, ink)                       // the silhouette's head
    c.rect(x0, top + 5, 6, 8, ink)                           // and shoulders
    c.rect(x0 + 2, top + 7, 2, 3, ring)                      // the bullseye
    let shots = min(8, Int(d.e / blasterPeriod))
    for i in 0..<shots {
        let hx = x0 + 1 + Int(noise(d.seed &+ i * 7) * 4), hy = top + 5 + Int(noise(d.seed &+ i * 7 + 1) * 7)
        c.px(hx, hy, paper)
    }
}

/// Scrawly reading a case file: the manila folder open in front of her, a page turned every few seconds.
private func drawCaseFile(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    standing(c, who, t: t)
    let r = setRamp(d)
    guard r > 0.3 else { return }
    let folder = C(0xD8B870), page = C(0xF4F2EA), line = C(0x8A8676)
    c.rect(38, 29, 12, 9, folder)
    c.rect(39, 30, 5, 7, page); c.rect(45, 30, 4, 7, page)
    for y in stride(from: 31, to: 37, by: 2) { c.rect(40, y, 3, 1, line); c.rect(45, y, 3, 1, line) }
    c.rect(44, 29, 1, 9, C(0xB89A58))
    // A page turning over, every 3 s.
    let k = frac(d.e / 3)
    if k < 0.25 {
        let w = Int((4 * (1 - k / 0.25)).rounded())
        c.rect(45, 29, max(1, w), 8, page.alpha(0.9))
    }
}

/// The Lone Gunclawds hacking: lines of green code scrolling up over their heads, a cursor blinking.
private func drawHacking(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    standing(c, who, t: t)
    let r = setRamp(d)
    guard r > 0.2 else { return }
    let scroll = d.e * 3
    for i in 0..<5 {
        let row = Int(floor(scroll)) + i
        let y = 18 - i * 3 + Int((frac(scroll) * 3).rounded())
        guard y > 1 else { continue }
        let len = 4 + Int(noise(row * 13 + d.seed) * 10)
        let fade = r * (1 - Double(i) / 5)
        for k in 0..<len where noise(row * 31 + k) > 0.25 { c.px(18 + k * 2, y, C(0x6AFF8A, fade)) }
    }
    if Int(t * 2) % 2 == 0 { c.rect(18, 19, 2, 1, C(0x6AFF8A, r)) }
}

/// Skinnard's jumping jacks: a hop on every beat, his shirt-sleeved arms flung up over his head at the top of it and
/// back down by his sides as he lands.
private func drawJumpingJacks(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    let r = setRamp(d)
    let beat = r > 0.5 ? frac(d.e / 0.7) : 0
    let up = beat > 0.15 && beat < 0.65
    standing(c, who, t: t)
    guard up else { return }
    // The hands off his sides and up beside his head, and a hop.
    c.move(columns: 13..<18, rows: 31..<37, dy: -11)
    c.move(columns: 38..<43, rows: 31..<37, dy: -11)
    c.shift(dx: 0, dy: -2)
}

/// Queequeg chasing his tail: round and round, turning to face one way then the other, a little hop each time.
private func drawTailChase(_ c: PixelCanvas, _ who: Cast, _ d: DrillPlay, _ t: Double) {
    let r = setRamp(d)
    drawPersona(c, who, t: t, mode: .idle, walking: r > 0.3, role: .none)
    guard r > 0.3 else { return }
    let spin = Int(floor(d.e / 0.35))
    if spin % 2 == 1 { c.flipHorizontally() }
    c.shift(dx: 0, dy: -Int((2 * abs(sin(d.e * .pi / 0.35))).rounded()))
}
