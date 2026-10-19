import AppKit
import CoreText

// The Clawd Slayer trailer: `REEL=slayer build/renderpromo video promo` → promo/clawd-slayer-promo.mp4.
// Drawn with RenderPromo's kit (Tools/RenderPromo/Kit: `Shot`, `brawl`, `windowShot`, `everyAI`, `Mix`…) and compiled
// only into that tool.

/// The Clawd Slayer trailer, as the tool asks for it.
struct SlayerReel: PromoReel {
    let name = "slayer", base = "clawd-slayer-promo", small = "Clawd-Slayer"
    var title: String { Universe.slayer.title.uppercased() }
    let geminiTask = "gemini ▸ stake the flaky test"
    var shots: [Shot] { slayerShots }
    var beats: [(key: Double, beat: Beat)] { slayerBeats }
    var universe: Universe { .slayer }
    var brawl: BrawlCast {
        BrawlCast(claude: .hero(SlayerHero.buffyClawmers), other: .villain(SlayerVillain.oldMaster),
                  agent: .hero(SlayerHero.willowRosenclaw), otherAgent: .villain(SlayerVillain.lukewarm),
                  line: universe.isReleased ? "Or patrol with Clawd Slayer." : "Coming soon: Clawd Slayer.",
                  sub: "Stakes, spells and a Hellmouth under the library.")
    }
    var window: WindowCast {
        WindowCast(place: .slayerLibrary, claude: .hero(SlayerHero.buffyClawmers), other: .villain(SlayerVillain.oldMaster),
                   agentA: .hero(SlayerHero.willowRosenclaw), agentB: .hero(SlayerHero.rupertGyles), extra: .villain(SlayerVillain.lukewarm),
                   prompt: "You: “stake the memory leak”", otherPrompt: "You: “reopen the Hellmouth”")
    }
    func sound(_ m: Mix) { slayerSound(m) }
}

// MARK: The Clawd Slayer trailer

/// The end card's line under "Have fun. Keep track.": never a count of universes.
let slayerTagline = "One of many universes in Clawd Clash · free for macOS"

/// A Clawd Slayer character's name, as the app has it.
func slayerName(_ h: SlayerHero) -> String { Cast.hero(h).name }
func slayerName(_ v: SlayerVillain) -> String { Cast.villain(v).name }

/// The title's letters, as the opening titles brush them: each a width and its strokes, in units of a letter 8.2 tall.
let slayerTitleGlyphs: [Character: (w: Double, strokes: [[(Double, Double)]])] = [
    "C": (5, [[(5, 6.8), (3.4, 8), (1.4, 7.4), (0.2, 5), (0.2, 3), (1.3, 0.6), (3.3, 0), (5.2, 1)]]),
    "L": (4.6, [[(0.6, 8.2), (0.6, 0)], [(0.2, 0.2), (4.8, 0)]]),
    "A": (5.4, [[(0, 0), (2.7, 8.2)], [(2.5, 8.2), (5.4, 0)], [(1.0, 3.0), (4.2, 3.4)]]),
    "W": (6.6, [[(0, 8.2), (1.5, 0)], [(1.4, 0.2), (3.3, 5.6)], [(3.3, 5.6), (5.0, 0)], [(5.0, 0.2), (6.6, 8.2)]]),
    "D": (5.2, [[(0.6, 8.2), (0.6, 0)], [(0.2, 8), (3.1, 7.7), (4.8, 5.6), (4.9, 2.6), (3.2, 0.4), (0.2, 0)]]),
    "S": (5, [[(5, 7), (3.3, 8.1), (1.0, 7.5), (0.6, 5.3), (2.6, 4.2), (4.5, 3.1), (4.5, 1.0), (2.5, 0), (0, 0.9)]]),
    "Y": (5.4, [[(0, 8.2), (2.7, 4)], [(5.4, 8.2), (2.6, 4)], [(2.7, 4.2), (2.7, 0)]]),
    "E": (4.8, [[(0.6, 8.2), (0.6, 0)], [(0.2, 8), (4.8, 8.2)], [(0.6, 4.2), (3.9, 4.4)], [(0.2, 0), (5.0, 0.2)]]),
    "R": (5.4, [[(0.6, 0), (0.6, 8.2)], [(0.2, 8), (3.4, 8.1), (4.9, 6.9), (4.8, 5.1), (3.3, 4.2), (0.6, 4.2)], [(1.6, 4.4), (3.6, 2.0), (5.6, -0.2)]]),
]

/// The title laid out as the opening titles lay it on a screen: CLAWD smaller over SLAYER, slanted a little and tilted
/// 20° up to the right, every stroke a list of points in pixels of a `slayerTitleW`×`slayerTitleH` canvas (y up);
/// SLAYER's L has a stake for a stem, laid out upright and drawn through `tilt`.
let slayerTitleW = 150, slayerTitleH = 100
struct SlayerTitleLayout {
    var strokes: [(points: [CGPoint], width: Double)] = []
    var footStroke = -1
    var stake: (x: Double, top: Double, bottom: Double, width: Double) = (0, 0, 0, 0)
    var tilt = CGAffineTransform.identity
    var u = 1.0

    init() {
        let W = Double(slayerTitleW), H = Double(slayerTitleH), gap = 1.3, small = 0.72
        func width(_ s: String) -> Double { s.reduce(0) { $0 + (slayerTitleGlyphs[$1]?.w ?? 3) } + gap * Double(s.count - 1) }
        let top = width("CLAWD"), bottom = width("SLAYER")
        u = min(W * 0.84 / bottom, H * 0.7 / (8.2 * (1 + small) + 2.4))
        let block = 8.2 * (1 + small) * u + 2.4 * u, yb = (H - block) / 2
        place("CLAWD", x: (W - top * u * small) / 2, y: yb + (8.2 + 2.4) * u, u: u * small, gap: gap, stakeL: false)
        place("SLAYER", x: (W - bottom * u) / 2, y: yb, u: u, gap: gap, stakeL: true)
        // Tilted 20° up to the right about the middle, and shrunk to fit (as the opening titles do).
        let a = 20 * Double.pi / 180, mid = CGPoint(x: W / 2, y: H / 2)
        let turn = CGAffineTransform(translationX: mid.x, y: mid.y).rotated(by: a).translatedBy(x: -mid.x, y: -mid.y)
        let st = stake
        let all = (strokes.flatMap { $0.points } + [CGPoint(x: st.x - st.width / 2, y: st.top), CGPoint(x: st.x + st.width / 2, y: st.top),
                                                     CGPoint(x: st.x, y: st.bottom)]).map { $0.applying(turn) }
        let x0 = all.map(\.x).min()!, x1 = all.map(\.x).max()!, y0 = all.map(\.y).min()!, y1 = all.map(\.y).max()!
        let s = min(1, W * 0.9 / Double(x1 - x0), H * 0.9 / Double(y1 - y0))
        tilt = turn.concatenating(CGAffineTransform(translationX: -(x0 + x1) / 2, y: -(y0 + y1) / 2))
            .concatenating(CGAffineTransform(scaleX: s, y: s)).concatenating(CGAffineTransform(translationX: mid.x, y: mid.y))
        strokes = strokes.map { ($0.points.map { $0.applying(tilt) }, $0.width * s) }
        u *= s
    }

    private mutating func place(_ word: String, x: Double, y: Double, u: Double, gap: Double, stakeL: Bool) {
        var cx = x
        let slant = 0.16
        for (n, ch) in word.enumerated() {
            guard let g = slayerTitleGlyphs[ch] else { continue }
            let jitter = (noise(n * 19 + word.count) - 0.5) * 0.5
            for (si, s) in g.strokes.enumerated() {
                if stakeL && ch == "L" && si == 0 {
                    stake = (x: cx + (0.6 + 4.1 * slant) * u, top: y + 9.6 * u, bottom: y - 1.6 * u, width: u * 1.6)
                    footStroke = strokes.count
                    continue
                }
                let pts = s.map { p in CGPoint(x: cx + (p.0 + p.1 * slant) * u, y: y + (p.1 + jitter * (p.0 / max(1, g.w))) * u) }
                strokes.append((pts, u * 1.15))
            }
            cx += (g.w + gap) * u
        }
    }
}
let slayerTitleLayout = SlayerTitleLayout()

/// One brush stroke along `pts`, dragged on as far as `p` (0…1) of its length: dabs under a pixel apart, ragged in
/// width and tapering at both ends.
func slayerBrush(_ c: CGContext, _ pts: [CGPoint], width: Double, upTo p: Double, seed: Int, color: CGColor) {
    guard pts.count > 1 else { return }
    var lens: [Double] = [0]
    for i in 1..<pts.count { lens.append(lens[i - 1] + hypot(Double(pts[i].x - pts[i - 1].x), Double(pts[i].y - pts[i - 1].y))) }
    let total = lens.last ?? 0
    guard total > 0 else { return }
    c.setFillColor(color)
    var seg = 1, d = 0.0, i = 0
    while d <= total * p {
        while seg < pts.count - 1 && lens[seg] < d { seg += 1 }
        let a = pts[seg - 1], b = pts[seg]
        let f = lens[seg] - lens[seg - 1] > 0 ? (d - lens[seg - 1]) / (lens[seg] - lens[seg - 1]) : 0
        let x = Double(a.x) + Double(b.x - a.x) * f, y = Double(a.y) + Double(b.y - a.y) * f
        let k = d / total
        let taper = min(1, 0.55 + k * 4) * (k > 0.8 ? 1 - (k - 0.8) * 2.2 : 1)
        let hw = width / 2 * taper * (0.82 + 0.36 * noise(seed * 131 + i))
        c.fill(CGRect(x: floor(x - hw), y: floor(y - hw + (noise(seed * 77 + i) - 0.5) * 1.2), width: max(1, (hw * 2).rounded()),
                      height: max(1, (hw * 2).rounded())))
        d += 0.7; i += 1
    }
}

/// The title as pixel art: CLAWD SLAYER brushed on in bone-white over a red under-stroke, `write` (0…1) of the strokes
/// down, and the whittled stake falling point first into place as SLAYER's L as `stake` goes 0…1.
func slayerTitleImage(write: Double, stake: Double) -> CGImage? {
    guard let g = CGContext(data: nil, width: slayerTitleW, height: slayerTitleH, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
    g.setShouldAntialias(false)
    let L = slayerTitleLayout, total = L.strokes.count
    for pass in 0..<2 {
        let off = pass == 0 ? L.u * 0.22 : 0
        let col = hexCG(pass == 0 ? 0x9E1424 : 0xEDE8DC)
        for (i, s) in L.strokes.enumerated() {
            var p = clamp(write * Double(total) * 1.15 - Double(i))
            if i == L.footStroke { p = min(p, clamp(stake * 4 - 3)) }      // the L's foot only once its stem has landed
            guard p > 0 else { continue }
            slayerBrush(g, s.points.map { CGPoint(x: $0.x + off, y: $0.y - off) }, width: s.width, upTo: p, seed: i * 37 + 5, color: col)
        }
    }
    if stake > 0 {
        g.saveGState(); defer { g.restoreGState() }
        g.concatenate(L.tilt)
        let pivot = CGPoint(x: L.stake.x, y: (L.stake.top + L.stake.bottom) / 2)    // leaning as the letters do
        g.translateBy(x: pivot.x, y: pivot.y); g.rotate(by: -atan(0.16)); g.translateBy(x: -pivot.x, y: -pivot.y)
        let st = L.stake, fall = (1 - stake * stake) * Double(slayerTitleH) * 1.1
        let x = st.x, top = st.top + fall, bottom = st.bottom + fall, wd = st.width
        func shape(_ dx: Double, _ dy: Double, _ hex: UInt32, inset: Double = 0) {
            g.setFillColor(hexColor(hex))
            g.beginPath()
            g.move(to: CGPoint(x: x - wd / 2 + dx + inset, y: top + dy - inset))
            g.addLine(to: CGPoint(x: x + wd / 2 + dx - inset, y: top + dy - inset))
            g.addLine(to: CGPoint(x: x + wd * 0.42 + dx - inset, y: bottom + wd * 2.2 + dy))
            g.addLine(to: CGPoint(x: x + dx, y: bottom + dy + inset))
            g.addLine(to: CGPoint(x: x - wd * 0.42 + dx + inset, y: bottom + wd * 2.2 + dy))
            g.closePath(); g.fillPath()
        }
        shape(L.u * 0.22, -L.u * 0.22, 0x9E1424)
        shape(0, 0, 0x2A1606)
        shape(0, 0, 0xB07A44, inset: 1)
        g.setFillColor(hexColor(0xD8A868))
        g.fill(CGRect(x: floor(x - wd / 2 + 1), y: floor(bottom + wd * 2.2), width: max(1, floor(wd * 0.25)), height: floor(top - bottom - wd * 2.2 - 1)))
        g.setFillColor(hexColor(0xF0D8A8))
        g.fill(CGRect(x: floor(x - 1), y: floor(bottom + 1), width: 2, height: max(2, floor(wd * 1.2))))
    }
    return g.makeImage()
}

/// The title drawn `px` screen pixels to a pixel, centred on `center`, with a dark smudge behind it so it reads on a place.
func slayerTitle(_ ctx: CGContext, center: CGPoint, px: Double, alpha: Double = 1, write: Double = 1, stake: Double = 1) {
    guard alpha > 0.01, let img = slayerTitleImage(write: write, stake: stake) else { return }
    let w = Double(slayerTitleW) * px, h = Double(slayerTitleH) * px
    let r = CGRect(x: (center.x - w / 2).rounded(), y: (center.y - h / 2).rounded(), width: w, height: h)
    ctx.saveGState(); ctx.setAlpha(CGFloat(alpha))
    ctx.setShadow(offset: .zero, blur: 50, color: CGColor(gray: 0, alpha: 0.85))
    ctx.setFillColor(CGColor(gray: 0, alpha: 0.35)); ctx.fillEllipse(in: r.insetBy(dx: w * 0.12, dy: h * 0.2))
    ctx.setShadow(offset: .zero, blur: 0, color: nil)
    ctx.interpolationQuality = .none
    ctx.draw(img, in: r)
    ctx.restoreGState()
}

/// The opening titles, played over the whole intro: the trip's art, slowed to the shot, from black to the town sign.
let slayerTitlesTrip = SlayerTrip(kind: .titles, from: .slayerLibrary, to: .slayerTownSign)
/// The intro's length, and where in it the trip's beats land (shot-local seconds).
let slayerIntroLength = 9.0
func slayerIntroAt(_ k: Double) -> Double { k * slayerIntroLength }
/// What the titles open from (black) and clear onto (the set piece's first frame), made the first time they're needed
/// (a `static let`, since the frame's globals further down aren't set up yet when this file's globals are).
enum SlayerStills {
    static let black: CGImage? = shotImage { $0.setFillColor(CGColor(gray: 0, alpha: 1)); $0.fill(fullRect) }
    static let sign: CGImage? = shotImage { slayerHomecoming($0, local: 0, t: slayerIntroLength) }
}

/// The opening titles: an organ chord over a night sky and a swelling moon; then hard cuts, punk-fast (a vampire in
/// game face, a gravestone in the fog, an old book flaring open); the four leads slam in as silhouettes against the
/// moon; CLAWD SLAYER is brushed on, its stake slamming down; and the black is swept off onto the town sign.
func slayerIntro(_ ctx: CGContext, local l: Double, t: Double) {
    guard let old = SlayerStills.black, let new = SlayerStills.sign else { return }
    slayerTitlesTrip.draw(ctx, old: old, new: new, k: clamp(l / slayerIntroLength), in: fullRect)
}

/// The set piece's timings (shot-local seconds): the DeSoto at the sign, then Restfield.
private let homeCarIn = 0.4, homeCarStop = 1.75, homeDoor = 1.85, homeSpyke = 2.0
let slayerHomeCut = 4.0
private let homeGround = 150.0, homeCarScale = 2.0, homeCarFrom = -150.0, homeCarTo = 172.0
/// In the cemetery (seconds after the cut): the fledglings rise, the bus pulls up, the gang gets off and fights,
/// dawn breaks and the vampires go up in dust.
private let homeRise: [Double] = [0.1, 0.3, 0.5], homeRiseLength = 0.8
private let homeBusIn = 0.6, homeBusStop = 1.4, homeBusDoor = 1.5, homeOff: [Double] = [1.6, 1.75, 1.9]
private let homeFlip = 2.2, homeDawn = 3.2, homeDust: [Double] = [3.5, 3.7, 3.9]
let slayerHomeFight = 2.85
private let homeFledglingXs: [Double] = [217, 256, 296], homeHeroXs: [Double] = [150, 118, 86]
private let homeBusLeft = -50.0

/// The DeSoto's left edge (fx columns) at shot time `l`, and how fast it's going (0…1).
private func deSotoAt(_ l: Double) -> (x: Double, speed: Double) {
    guard l > homeCarIn else { return (homeCarFrom, 1) }
    let f = clamp((l - homeCarIn) / (homeCarStop - homeCarIn))
    return (lerp(homeCarFrom, homeCarTo, easeOut(f)), 1 - f)
}

/// The sign's board and posts in the town sign's frame-sized canvas, and the moment the car's nose reaches the first post.
private let homeSignFrame = Scenes.slayerTownSignFrame(PixelCanvas(fxW, fxH), fxH - 30)
private let homeSignBox: (x: Int, y: Int, w: Int, h: Int) = {
    let b = homeSignFrame.board
    return (b.x - 2, b.y - 2, b.w + 4, fxH - 30 - b.y + 2)
}()
private let homeCrash: Double = {
    let post = Double(homeSignFrame.board.x + homeSignFrame.board.w / 6)
    var l = homeCarIn
    while l < homeCarStop && deSotoAt(l).x + 62 * homeCarScale < post { l += 0.005 }
    return l
}()

/// The town sign with the sign itself painted out: the same place drawn four times as wide (so the board and the
/// lamp are far off to the right), its pixels under the board copied over the board.
private let homeSignGone: PixelCanvas = {
    let wide = PixelCanvas(fxW * 4, fxH)
    Location.slayerTownSign.drawStatic(wide, floorRows: 30)
    return wide
}()
/// The board and its posts, cut out of the place to be smashed off it: just the pixels that differ from the place
/// without them.
private let homeBoard: CGImage? = {
    let c = PixelCanvas(fxW, fxH); Location.slayerTownSign.drawStatic(c, floorRows: 30)
    let b = homeSignBox, out = PixelCanvas(b.w, b.h), gone = homeSignGone
    for y in 0..<b.h {
        for x in 0..<b.w {
            let i = ((b.y + y) * c.w + b.x + x) * 4, j = ((b.y + y) * gone.w + b.x + x) * 4
            if (0..<3).allSatisfy({ c.buf[i + $0] == gone.buf[j + $0] }) { continue }
            out.px(x, y, Px(r: c.buf[i], g: c.buf[i + 1], b: c.buf[i + 2], a: c.buf[i + 3]))
        }
    }
    return out.makeImage()
}()

/// Pixel dust: a puff of grey-gold specks blowing up and away from (x, y), `k` 0…1 through it (fx units).
func slayerDustPuff(_ c: PixelCanvas, x: Double, y: Double, k: Double, seed: Int, count: Int = 60, spread: Double = 12) {
    guard k > 0, k < 1 else { return }
    for i in 0..<count {
        let a = noise(seed + i * 3) * 2 * .pi, sp = 0.3 + noise(seed + i * 3 + 1) * 0.7
        let dx = cos(a) * spread * sp * easeOut(k) + k * 22 * noise(seed + i * 3 + 2)    // the wind takes it to the right
        let dy = sin(a) * spread * 0.7 * sp * easeOut(k) - k * 14 * sp
        let col = [C(0xB8A890), C(0x8A8070), C(0xE0C890), C(0x6A6458)][i % 4]
        c.px(Int(x + dx), Int(y + dy), col.alpha(1 - k * k))
    }
}

/// "Home sweet home." Night at the Welcome to Sunnydale sign: Spyke's DeSoto tears in and smashes straight through it,
/// skids to a stop and he steps out. Then Restfield: fledglings claw up out of their graves, the yellow school bus
/// pulls up, Buffy flips her stake, Willow's green spell lights the graves, Giles fires his crossbow, and as dawn
/// breaks the vampires go up in dust.
func slayerHomecoming(_ ctx: CGContext, local l: Double, t: Double) {
    if l < slayerHomeCut { slayerSignCrash(ctx, local: l, t: t) } else { slayerRestfield(ctx, local: l - slayerHomeCut, t: t) }
}

func slayerSignCrash(_ ctx: CGContext, local l: Double, t: Double) {
    let since = l - homeCrash
    if since > 0 && since < 0.45 { let sh = (0.45 - since) * 36; ctx.translateBy(x: sin(t * 90) * sh, y: cos(t * 77) * sh) }
    let sign = place(.slayerTownSign, floorRows: 30, t: l + 0.5)
    if since > 0 {
        let b = homeSignBox
        for y in b.y..<(b.y + b.h) {
            for x in b.x..<(b.x + b.w) {
                let i = (y * homeSignGone.w + x) * 4, g = homeSignGone.buf
                sign.px(x, y, Px(r: g[i], g: g[i + 1], b: g[i + 2], a: 255))
            }
        }
        // Splintered stumps left of the two posts.
        let bd = homeSignFrame.board
        for px in [bd.x + bd.w / 6, bd.x + bd.w * 5 / 6 - 3] {
            let g = fxH - 30
            sign.rect(px, g - 5, 4, 5, C(0x4A3020)); sign.rect(px, g - 5, 1, 5, C(0x6A4A30))
            sign.px(px + 1, g - 6, C(0x6A4A30)); sign.px(px + 3, g - 7, C(0x4A3020))
        }
    }
    blit(sign, ctx)
    onStage(ctx, fullRect, scale: 6, ground: homeGround) {
        let fx = PixelCanvas(fxW, fxH)
        let car = deSotoAt(l)
        // Headlight beams ahead of the car, and the skid's dust under its wheels.
        if l > homeCarIn - 0.3 {
            let nose = car.x + 63 * homeCarScale, beam = homeGround - 15 * homeCarScale
            for k in 0..<3 { fx.rect(Int(nose), Int(beam) - k, 70 - k * 18, 1 + 2 * k, C(0xFFF4D0, 0.10)) }
        }
        if car.speed < 0.6 && l < homeCarStop + 0.6 {
            for w in [12.0, 52.0] { slayerDustPuff(fx, x: car.x + w * homeCarScale, y: homeGround - 2, k: clamp((l - homeCrash) / 1.6), seed: Int(w), count: 30, spread: 8) }
        }
        // The board and posts, smashed off and flung tumbling up and over the car.
        if since > 0, let board = homeBoard {
            let b = homeSignBox
            let pieces = 3, pw = b.w / pieces
            for i in 0..<pieces {
                guard let part = board.cropping(to: CGRect(x: i * pw, y: 0, width: i == pieces - 1 ? b.w - i * pw : pw, height: b.h)) else { continue }
                let vx = 70.0 + Double(i) * 34, vy = 90.0 - Double(i) * 14, spin = (i % 2 == 0 ? 1.0 : -1.0) * (5 + Double(i) * 2)
                let cx = Double(b.x + i * pw) + Double(pw) / 2 + vx * since, cy = Double(b.y) + Double(b.h) / 2 - vy * since + 160 * since * since
                ctx.saveGState(); ctx.interpolationQuality = .none
                ctx.translateBy(x: cx * 6, y: Double(H) - cy * 6); ctx.rotate(by: CGFloat(spin * since))
                ctx.draw(part, in: CGRect(x: -Double(part.width) * 3, y: -Double(b.h) * 3, width: Double(part.width) * 6, height: Double(b.h) * 6))
                ctx.restoreGState()
            }
            // Splinters and dust where it hit.
            let hit = Double(homeSignFrame.board.x + homeSignFrame.board.w / 6)
            slayerDustPuff(fx, x: hit, y: homeGround - 14, k: since / 1.2, seed: 500, count: 90, spread: 26)
            for i in 0..<26 where since < 1.4 {
                let a = 0.3 + noise(i + 600) * 2.4, sp = 40 + noise(i + 601) * 90
                let x = hit + cos(a) * sp * since + 30 * since, y = homeGround - 18 - sin(a) * sp * since + 120 * since * since
                if y < homeGround { fx.rect(Int(x), Int(y), 2, 1, [C(0xC8B080), C(0x6A4A30), C(0xEDE4C8)][i % 3]) }
            }
        }
        // The DeSoto, lit, its back door swinging open; Spyke steps out and looks the town over.
        let door = clamp((l - homeDoor) / 0.25)
        let rc = PixelCanvas(Ride.width, Ride.height)
        drawRide(rc, .deSoto, ramp: door, engines: true, gear: true)
        rc.addOutline(C(0xFFFFFF, 0.92))
        if let img = rc.makeImage() {
            ctx.saveGState(); ctx.interpolationQuality = .none
            let bob = car.speed > 0.05 ? (Int(t * 20) % 2 == 0 ? 0.0 : 1.0) : 0
            ctx.draw(img, in: CGRect(x: car.x * S, y: stageH - homeGround * S + bob * S, width: Double(Ride.width) * S * homeCarScale,
                                     height: Double(Ride.height) * S * homeCarScale))
            ctx.restoreGState()
        }
        if l > homeSpyke {
            let k = easeOut((l - homeSpyke) / 0.6)
            var spyke = Actor(cast: .hero(SlayerHero.spyke), x: lerp(homeCarTo + 30, homeCarTo - 14, k), facing: -1, mode: .idle)
            spyke.walking = k < 0.97
            spyke.alpha = clamp((l - homeSpyke) / 0.12)
            draw(spyke, ctx, t: t)
            if l > homeSpyke + 0.45 {
                let pop = backOut((l - homeSpyke - 0.45) / 0.25)
                balloon("Home sweet home.", ctx, center: CGPoint(x: 820, y: 640), tail: headPoint(spyke), size: max(4, 44 * CGFloat(pop)), width: 520)
            }
        }
        if let img = fx.makeImage() { ctx.saveGState(); ctx.interpolationQuality = .none; ctx.draw(img, in: fullRect); ctx.restoreGState() }
    }
    if since > 0 && since < 0.12 { ctx.setFillColor(CGColor(red: 1, green: 0.95, blue: 0.85, alpha: 0.5 * (1 - since / 0.12))); ctx.fill(fullRect) }
}

func slayerRestfield(_ ctx: CGContext, local c: Double, t: Double) {
    blit(place(.slayerCemetery, floorRows: 30, t: t), ctx)
    let dawn = easeOut((c - homeDawn) / 1.3)
    // Dawn: the sky blushes from the horizon up, a line of light coming up behind the hills.
    if dawn > 0 {
        let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                           colors: [hexColor(0xFF9A4A, 0.55 * dawn), hexColor(0xFF6A5A, 0.3 * dawn), hexColor(0x6A4A8A, 0.0)] as CFArray,
                           locations: [0, 0.4, 1])!
        ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: Double(H) - 100 * 6), end: CGPoint(x: 0, y: Double(H)), options: [])
        ctx.setFillColor(hexColor(0xFFE0A0, 0.5 * dawn)); ctx.fill(CGRect(x: 0, y: Double(H) - 101 * 6, width: Double(W), height: 6))
    }
    let floorY = stageH - homeGround * 6
    onStage(ctx, fullRect, scale: 6, ground: homeGround) {
        let fx = PixelCanvas(fxW, fxH)
        // The fledglings: first a hand, then the rest, clawing up out of the earth, a mound of dirt heaped round them.
        var vamps: [Actor] = []
        for (i, at) in homeRise.enumerated() {
            let x = homeFledglingXs[i]
            fx.ellipse(Int(x), Int(homeGround) - 1, 13, 3, C(0x2A1E16)); fx.ellipse(Int(x) - 2, Int(homeGround) - 2, 9, 2, C(0x3E2C1E))
            let r = clamp((c - at) / homeRiseLength)
            guard r > 0 else { continue }
            if r < 1 { for k in 0..<5 { fx.px(Int(x) - 6 + Int(noise(k + i * 9 + Int(t * 14)) * 12), Int(homeGround) - 3 - Int(noise(k + i * 5 + Int(t * 10)) * 6), C(0x4A3624)) } }
            let chase = easeOut((c - slayerHomeFight + 0.5) / 0.6)
            var v = Actor(cast: .villain(SlayerVillain.fledgling), x: x - (i == 0 ? 10 * chase : 0), facing: -1, mode: .idle)
            v.lift = -(1 - easeOut(r)) * 46
            vamps.append(v)
        }
        // The bus, pulling up and folding its door open.
        let bk = clamp((c - homeBusIn) / (homeBusStop - homeBusIn))
        let busX = lerp(-140, homeBusLeft, easeOut(bk))
        if c > homeBusIn {
            let bc = PixelCanvas(Ride.width, Ride.height)
            drawRide(bc, .schoolBus, ramp: clamp((c - homeBusDoor) / 0.2), engines: true, gear: true)
            bc.addOutline(C(0xFFFFFF, 0.92))
            if let img = bc.makeImage() {
                ctx.saveGState(); ctx.interpolationQuality = .none
                ctx.draw(img, in: CGRect(x: busX * S, y: stageH - homeGround * S, width: Double(Ride.width) * S * homeCarScale,
                                         height: Double(Ride.height) * S * homeCarScale))
                ctx.restoreGState()
            }
        }
        // The gang gets off and goes to it.
        let gang: [Cast] = [.hero(SlayerHero.buffyClawmers), .hero(SlayerHero.willowRosenclaw), .hero(SlayerHero.rupertGyles)]
        var heroes: [Actor] = []
        for (i, who) in gang.enumerated() where c > homeOff[i] {
            let k = easeOut((c - homeOff[i]) / 0.55), doorX = homeBusLeft + 44.5 * homeCarScale
            var a = Actor(cast: who, x: lerp(doorX, homeHeroXs[i], k), facing: 1, mode: .idle)
            a.walking = k < 0.97
            a.alpha = clamp((c - homeOff[i]) / 0.1)
            heroes.append(a)
        }
        // Who's dust, and how far through it.
        func dusted(_ i: Int) -> Double { clamp((c - homeDust[i]) / 0.7) }
        // The fight: Buffy's stake on the first, Willow's spell on the second, Giles's crossbow on the third.
        var pairs: [(Actor, Actor)] = []
        if c > slayerHomeFight {
            for i in 0..<min(heroes.count, vamps.count) {
                if dusted(i) > 0.3 { heroes[i].role = .cheer; continue }     // theirs is dust: a little cheer
                guard dusted(i) == 0 else { continue }
                let (rh, rv) = fightRoles(heroes[i].cast.weapon, vamps[i].cast.weapon)
                heroes[i].role = rh; vamps[i].role = rv
                pairs.append((heroes[i], vamps[i]))
            }
        }
        // Willow's green light on the graves.
        if heroes.count > 1, c > slayerHomeFight - 0.2, c < homeDust[1] + 0.3 {
            let w = heroes[1], glow = clamp((c - slayerHomeFight + 0.2) / 0.3) * (1 - clamp((c - homeDust[1]) / 0.3))
            fx.rect(0, 0, fxW, fxH, C(0x3CFF6A, 0.06 * glow))
            fx.ellipse(Int(w.x) + 50, Int(homeGround) - 2, 90, 7, C(0x5CFF7A, 0.2 * glow))
            fx.circle(Int(w.x) + 8, Int(homeGround) - 26, 26, C(0x5CFF7A, 0.1 * glow))
            fx.circle(Int(w.x) + 8, Int(homeGround) - 26, 12, C(0x8CFFA0, 0.14 * glow))
        }
        // Clipped to above the ground, so the fledglings come up out of it.
        ctx.saveGState(); ctx.clip(to: CGRect(x: 0, y: floorY - 6, width: Double(W), height: Double(H)))
        for (i, v) in vamps.enumerated() {
            let d = dusted(i)
            guard d < 0.25 else { continue }
            var vv = pairs.first(where: { $0.1.x == v.x })?.1 ?? v
            vv.alpha = 1 - d * 4
            draw(vv, ctx, t: t)
        }
        ctx.restoreGState()
        for (i, h) in heroes.enumerated() {
            if i == 0 && c > homeFlip && c < slayerHomeFight {      // Buffy flips her stake
                let len = h.cast.signatureLength ?? 2.0
                forcedHabit = HabitPlay(kind: .signature, e: (c - homeFlip) / (slayerHomeFight - homeFlip) * len, length: len)
                draw(h, ctx, t: t)
                forcedHabit = nil
            } else {
                draw(pairs.first(where: { $0.0.x == h.x })?.0 ?? h, ctx, t: t)
            }
        }
        drawFX(pairs, ctx, t: t)
        for i in vamps.indices { slayerDustPuff(fx, x: vamps[i].x, y: homeGround - 16, k: dusted(i), seed: 900 + i * 101, count: 110, spread: 14) }
        if let img = fx.makeImage() { ctx.saveGState(); ctx.interpolationQuality = .none; ctx.draw(img, in: fullRect); ctx.restoreGState() }
    }
    caption("In every terminal, a Clawd is chosen.", ctx, local: c, start: homeDust[0] - 0.2, y: 930, size: 60)
}

/// The end card: the library, the crew lined up, the title brushed on and its stake slamming down.
func slayerEndcard(_ ctx: CGContext, local: Double, t: Double) {
    let since = local - 1.05
    if since > 0 && since < 0.3 { let sh = (0.3 - since) * 30; ctx.translateBy(x: sin(t * 90) * sh, y: cos(t * 77) * sh) }
    blit(place(.slayerLibrary, floorRows: 34, t: t), ctx)
    ctx.setFillColor(CGColor(gray: 0, alpha: 0.35)); ctx.fill(CGRect(x: -40, y: -40, width: W + 80, height: H + 80))
    let crew: [(Cast, FightRole, AI)] = [(.hero(SlayerHero.rupertGyles), .cheer, .desktop), (.hero(SlayerHero.buffyClawmers), .none, .claude),
                                         (.villain(SlayerVillain.oldMaster), .none, .codex), (.villain(SlayerVillain.drusillah), .none, .copilot),
                                         (.hero(SlayerHero.spyke), .cheer, .qwen), (.hero(SlayerHero.willowRosenclaw), .none, .gemini)]
    var placed: [Actor] = []
    let (ra, rb) = fightRoles(crew[1].0.weapon, crew[2].0.weapon)
    for (i, (who, role, ai)) in crew.enumerated() {
        var a = Actor(cast: who, x: [28.0, 84, 140, 206, 252, 296][i], facing: i < 2 ? 1 : -1, role: i == 1 ? ra : i == 2 ? rb : role, ai: ai)
        a.lift = 8
        a.alpha = clamp((local - 0.15 - Double(i) * 0.05) / 0.2)
        draw(a, ctx, t: t)
        placed.append(a)
    }
    if local > 0.5 { drawFX([(placed[1], placed[2])], ctx, t: t) }
    if local > 0.3 {
        slayerTitle(ctx, center: CGPoint(x: Double(W) / 2, y: 770), px: 5, write: clamp((local - 0.3) / 0.6), stake: clamp((local - 0.9) / 0.15))
    }
    if since > 0 && since < 0.1 { ctx.setFillColor(CGColor(red: 1, green: 0.95, blue: 0.86, alpha: 0.45 * (1 - since / 0.1))); ctx.fill(fullRect) }
    caption("Have fun. Keep track.", ctx, local: local, start: 1.2, y: 470, size: 56)
    caption(slayerTagline, ctx, local: local, start: 1.4, y: 412, size: 34, color: NSColor(white: 0.85, alpha: 1), weight: .bold)
    let ff = easeOut((local - 1.5) / 0.3)
    if ff > 0, let icon = appIcon {
        ctx.setFillColor(CGColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 0.8 * ff)); ctx.fill(CGRect(x: -40, y: -40, width: W + 80, height: 210))
        ctx.saveGState(); ctx.setAlpha(CGFloat(ff)); ctx.interpolationQuality = .high
        ctx.draw(icon, in: CGRect(x: 580, y: 20, width: 130, height: 130))
        ctx.restoreGState()
        text("github.com/rodclemen/clawd-clash", ctx, x: 740, y: 60, size: 44, weight: .bold, alpha: ff)
    }
}

let slayerShots: [Shot] = [
    // The opening titles: the organ, the moon, the fast cuts, the leads, the title, onto the town sign.
    Shot(name: "intro", start: 0, end: 9.0, into: .cut) { ctx, local, t in slayerIntro(ctx, local: local, t: t) },
    // "Home sweet home": the DeSoto through the sign, the fledglings rising, the bus, the gang, dust at dawn.
    Shot(name: "homecoming", start: 9.0, end: 18.5, into: .cut) { ctx, local, t in slayerHomecoming(ctx, local: local, t: t) },
    Shot(name: "hook", start: 18.5, end: 22.5, into: .trip(ComicTransition(SlayerTrip(kind: .dusting, from: .slayerCemetery, to: .slayerLibrary)))) { ctx, local, t in
        let zoom = 1 + 0.03 * local
        ctx.saveGState()
        ctx.translateBy(x: Double(W) / 2, y: Double(H) / 2); ctx.scaleBy(x: zoom, y: zoom); ctx.translateBy(x: -Double(W) / 2, y: -Double(H) / 2)
        desktop(ctx, dim: 0)
        ctx.restoreGState()
        caption("Three AIs. Nine agents. One very confused Watcher.", ctx, local: local, start: 0.05, y: 860, size: 60)
        caption("Sound familiar?", ctx, local: local, start: 0.7, y: 120, size: 76, color: yellow)
    },
    Shot(name: "desktop", start: 22.5, end: 27.1) { ctx, local, t in
        brawl(ctx, .slayer, local: local, t: t, drop: true, chrome: false)
        badge("DESKTOP MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Patrolling your desktop.", ctx, local: local, start: 0.35, y: 900)
        caption("A pixel-art \(Universe.slayer.title) brawl along the bottom of your screen. They fight while they work.", ctx, local: local,
                start: 0.6, y: 830, size: 40, color: yellow, weight: .bold)
    },
    Shot(name: "status", start: 27.1, end: 31.3) { ctx, local, t in
        let cast: [Cast] = [.hero(SlayerHero.buffyClawmers), .hero(SlayerHero.willowRosenclaw), .hero(SlayerHero.spyke), .hero(SlayerHero.rupertGyles)]
        statusOf(ctx, local: local, t: t, cast: cast, badgeText: Universe.slayer.title.uppercased(),
                 aside: "(\(cast[2].name) needs you: “Bloody hell!” \(cast[3].name) has gone for a lie-down.)")
    },
    Shot(name: "agents", start: 31.3, end: 35.3) { ctx, local, t in
        agentsOf(ctx, local: local, t: t, guardCast: .hero(SlayerHero.rupertGyles),
                 crew: [.hero(SlayerHero.xanderHarrows), .hero(SlayerHero.cordeliaChaise), .hero(SlayerHero.ozz), .hero(SlayerHero.anyaJinkins)],
                 line: "Every subagent gets to be part of the Scoobies.", badgeText: Universe.slayer.title.uppercased())
    },
    Shot(name: "window", start: 35.3, end: 40.1, into: .trip(ComicTransition(SlayerTrip(kind: .hellmouth, from: .slayerLibrary, to: .slayerLibrary)))) { ctx, local, t in
        windowShot(ctx, .slayer, local: local, t: t, rise: true, needsAt: 2.5, at: .slayerLibrary)
        badge("WINDOW MODE", ctx, alpha: clamp((local - 0.2) / 0.3))
        caption("Prefer a window? Welcome to the Hellmouth.", ctx, local: local, start: 0.1, y: 955, size: 56)
        caption("A live card per session: what it's doing, your last prompt, every agent.", ctx, local: local, start: 0.4, y: 890, size: 32, color: yellow, weight: .bold)
    },
    Shot(name: "ais", start: 40.1, end: 44.5) { ctx, local, t in
        everyAI(ctx, local: local, t: t, cast: [.hero(SlayerHero.buffyClawmers), .hero(SlayerHero.faithLehayne), .villain(SlayerVillain.oldMaster),
                                                .villain(SlayerVillain.drusillah), .villain(SlayerVillain.glorificlaws), .villain(SlayerVillain.mayorWilclaws),
                                                .villain(SlayerVillain.fledgling)])
    },
    // The end card: the library, the crew lines up, the title is brushed on.
    Shot(name: "endcard", start: 44.5, end: 48.7) { ctx, local, t in slayerEndcard(ctx, local: local, t: t) },
]

let slayerBeats: [(key: Double, beat: Beat)] = [
    (1.6, ("THE OPENING TITLES", "Out of the black, a night sky in navy bands, stars and a full moon swelling over the graveyard's black skyline; clouds and a bat cross its face.",
           "no text", "one long, low church-organ chord, the wind")),
    (3.2, ("THE CUTS", "Then hard cuts, punk-fast, each on a flash: a vampire in game face lunging at us, a gravestone in the fog, an old book slamming open in a flare of gold light.",
           "no text", "the band crashes in: fast, crunchy punk power chords and pounding drums, our own notes; a cymbal crash on every cut")),
    (5.5, ("THE LEADS", "\(slayerName(SlayerHero.buffyClawmers)) with her stake, \(slayerName(SlayerHero.rupertGyles)) with his crossbow, \(slayerName(SlayerHero.willowRosenclaw)) with a spell glowing green, \(slayerName(SlayerHero.xanderHarrows)) with a rocket launcher: four black silhouettes slamming in against the moon, one after another.",
           "no text", "a hit on each slam")),
    (7.5, ("THE TITLE", "CLAWD SLAYER brushed on in jagged bone-white strokes over red, a whittled stake slamming down as SLAYER's L; then the black is torn away in ragged strokes onto the Welcome to Sunnydale sign.",
           "CLAWD SLAYER", "the big hit as the stake lands, a ringing chord, a sweep")),
    (10.0, ("HOME SWEET HOME", "Night at the \(Location.slayerTownSign.name) sign. Spyke's black DeSoto, its windows painted over, tears in with its headlights on and smashes straight through the sign: the board flies off in three pieces, splinters and dust everywhere.",
            "no text", "an engine roaring in, the crash, wood splintering")),
    (12.2, ("SPYKE", "The car skids to a stop, its back door swings open and \(slayerName(SlayerHero.spyke)) steps out to look the town over.",
            "“Home sweet home.”", "a skid, the door, boots on the road")),
    (15.0, ("RESTFIELD", "\(Location.slayerCemetery.name): three fledglings claw up out of their graves. The yellow school bus pulls up and folds its door open; \(slayerName(SlayerHero.buffyClawmers)), \(slayerName(SlayerHero.willowRosenclaw)) and \(slayerName(SlayerHero.rupertGyles)) get off. \(slayerName(SlayerHero.buffyClawmers)) flips her stake.",
            "no text", "earth crumbling, the bus's engine and brakes, the door")),
    (17.0, ("DUST AT DAWN", "The fight: the stake, Willow's spell lighting the graves green, Giles's crossbow. The sky blushes, dawn breaks behind the hills and the fledglings go up in dust, one, two, three.",
            "“In every terminal, a Clawd is chosen.”", "stake thuds, a spell, a crossbow bolt; a rising dawn chord, three puffs of dust")),
    (18.3, ("DUSTING", "The app's Dusting trip: a stake strikes and the cemetery bursts into dust that blows away onto the desktop.", "(none)", "a thud, a rush of dust")),
    (20.0, ("THE HOOK", "Three busy terminals, slow push-in.", "“Three AIs. Nine agents. One very confused Watcher.”  →  “Sound familiar?”", "keyboard clicks")),
    (24.8, ("DESKTOP MODE", "\(slayerName(SlayerHero.buffyClawmers)) against \(slayerName(SlayerVillain.oldMaster)); \(slayerName(SlayerHero.willowRosenclaw)) against \(slayerName(SlayerVillain.lukewarm)).",
            "DESKTOP MODE  ·  “Patrolling your desktop.”  ·  “A pixel-art \(Universe.slayer.title) brawl along the bottom of your screen. They fight while they work.”", "stake thuds, spells")),
    (29.4, ("AT A GLANCE", "\(slayerName(SlayerHero.buffyClawmers)) working, \(slayerName(SlayerHero.willowRosenclaw)) thinking, \(slayerName(SlayerHero.spyke))'s jumping NEEDS YOU, \(slayerName(SlayerHero.rupertGyles)) sat down napping.",
            "“All fun and games, and you still see everything.”  ·  “(\(slayerName(SlayerHero.spyke)) needs you: “Bloody hell!” \(slayerName(SlayerHero.rupertGyles)) has gone for a lie-down.)”", "blips, alert beeps")),
    (33.5, ("SUBAGENTS", "\(slayerName(SlayerHero.rupertGyles)) stands guard; \(slayerName(SlayerHero.xanderHarrows)), \(slayerName(SlayerHero.cordeliaChaise)), \(slayerName(SlayerHero.ozz)) and \(slayerName(SlayerHero.anyaJinkins)) arrive with their jobs on their labels.",
            "“Every subagent gets to be part of the Scoobies.”", "footsteps")),
    (38.1, ("WINDOW MODE", "In through the app's Hellmouth trip: the window in the \(Location.slayerLibrary.name), \(slayerName(SlayerHero.buffyClawmers)) against \(slayerName(SlayerVillain.oldMaster)), live cards tick, then the Codex card flips to NEEDS YOU.",
            "WINDOW MODE  ·  “Prefer a window? Welcome to the Hellmouth.”", "a rumble, a ping")),
    (42.5, ("EVERY AI", "Seven sessions, one per AI outline: \(slayerName(SlayerHero.buffyClawmers)) (Claude Code, a head taller) and \(slayerName(SlayerHero.faithLehayne)) against \(slayerName(SlayerVillain.oldMaster)), \(slayerName(SlayerVillain.drusillah)), \(slayerName(SlayerVillain.glorificlaws)) and \(slayerName(SlayerVillain.mayorWilclaws)); a fledgling in pi's pink.",
            "BRING YOUR OWN AI*  ·  “One AI plays everyone. Run two and they pick sides.”  ·  *README for the full list", "stake thuds")),
    (47.5, ("END CARD", "The \(Location.slayerLibrary.name): the crew lines up, CLAWD SLAYER is brushed on and its stake slams down, then the icon and the URL.",
            "CLAWD SLAYER  ·  “Have fun. Keep track.”  ·  “\(slayerTagline)”  ·  github.com/rodclemen/clawd-clash", "the organ chord, a last punk stab and crash")),
]

// Clawd Slayer sound effects
extension Mix {
    /// A church organ chord: each note on a few drawbars (sines an octave and a twelfth apart), a slow swell and a
    /// little tremolo.
    func organ(_ t: Double, _ dur: Double, _ notes: [Int], vol: Double = 0.05) {
        for n in notes {
            for (mul, v) in [(0.5, 0.6), (1.0, 1.0), (1.5, 0.35), (2.0, 0.45), (4.0, 0.12)] {
                tone(t, dur, midi(n) * mul, wave: .sine, vol: vol * v, attack: 0.25, release: 0.6, vibrato: 0.002)
            }
            tone(t, dur, midi(n), wave: .square(0.5), vol: vol * 0.08, attack: 0.3, release: 0.6)
        }
    }
    /// One crunchy power-chord chug on `root` (root, fifth, octave on detuned saws and a square), `len` long; `mute`
    /// palm-mutes it to a short thud.
    func chug(_ t: Double, root: Int, len: Double, mute: Bool, vol: Double = 0.05) {
        let d: Double = mute ? 0.05 : 0
        for (n, v) in [(root, 1.0), (root + 7, 0.8), (root + 12, 0.55)] {
            tone(t, len, midi(n) * 0.997, wave: .saw, vol: vol * v, attack: 0.002, release: 0.02, decay: d)
            tone(t, len, midi(n) * 1.004, wave: .saw, vol: vol * v, attack: 0.002, release: 0.02, decay: d)
            tone(t, len, midi(n), wave: .square(0.3), vol: vol * v * 0.5, attack: 0.002, release: 0.02, decay: d)
        }
        noise(t, min(len, 0.05), vol: vol * 0.5, cutoff: 0.6, decay: 0.015, seed: Int(t * 389))      // the pick
    }
    /// A crash cymbal.
    func crash(_ t: Double, vol: Double = 0.1) { noise(t, 1.4, vol: vol, cutoff: 0.95, decay: 0.45, highpass: true, seed: Int(t * 211)) }
    /// A car engine revving past: a low growl that climbs.
    func engine(_ t: Double, _ dur: Double, from: Double, to: Double, vol: Double = 0.06) {
        tone(t, dur, from, to: to, wave: .saw, vol: vol, attack: 0.2, release: 0.15)
        tone(t, dur, from * 0.5, to: to * 0.5, wave: .square(0.3), vol: vol * 0.7, attack: 0.2, release: 0.15)
        noise(t, dur, vol: vol * 0.6, cutoff: 0.05, cutoffTo: 0.12, attack: 0.2, release: 0.15, seed: Int(t * 97))
    }
    /// A puff of dust: a soft hiss blowing away.
    func dust(_ t: Double, vol: Double = 0.08) {
        noise(t, 0.6, vol: vol, cutoff: 0.5, cutoffTo: 0.08, attack: 0.01, release: 0.4, seed: Int(t * 131))
        tone(t, 0.25, 220, to: 90, wave: .sine, vol: vol * 0.6, release: 0.1)
    }
}

/// The opening titles' band, in the sound of the show's theme (an organ chord, then fast, crunchy punk guitar and
/// drums) but our own notes: no melody, just a driving riff of power chords, eight chugs a bar at a punk tempo, with
/// kick and snare pounding under it. `bars` of it from `t0`.
func slayerBand(_ m: Mix, from t0: Double, bars: Int, beat: Double = 0.3) {
    let roots = [38, 38, 41, 36, 43, 41, 38, 45]                        // D D F C G F D A, low; our own run
    for b in 0..<bars {
        let s = t0 + Double(b) * 4 * beat, r = roots[b % roots.count]
        for e in 0..<8 {
            let at = s + Double(e) * beat / 2, open = e == 0 || e == 3 || e == 6
            m.chug(at, root: r + (e == 7 ? 2 : 0), len: beat / 2 * (open ? 0.95 : 0.7), mute: !open, vol: open ? 0.055 : 0.04)
            m.hat(at, vol: e % 2 == 0 ? 0.05 : 0.03)
        }
        for k in [0.0, 1.5, 2.0] { m.kick(s + k * beat, vol: 0.32) }
        for k in [1.0, 3.0] { m.snare(s + k * beat, vol: 0.14) }
        m.tone(s, 4 * beat * 0.98, midi(r - 12), wave: .triangle, vol: 0.09, release: 0.05)  // the bass, under it
    }
}

/// The Clawd Slayer trailer's score and effects.
func slayerSound(_ m: Mix) {
    let i0 = start("intro"), at = { (k: Double) -> Double in i0 + slayerIntroAt(k) }
    // the night: wind, then the organ chord as the moon swells
    m.noise(i0 + 0.1, at(0.26) - i0, vol: 0.04, cutoff: 0.01, cutoffTo: 0.04, attack: 0.8, release: 0.3, seed: 5)
    m.organ(at(0.06), at(0.26) - at(0.06) + 0.3, [38, 50, 53, 57, 62], vol: 0.045)
    // the band crashes in on the first cut and drives through to the title
    let band0 = at(0.26), beat = 0.3
    let bars = Int(((at(0.88) - band0) / (4 * beat)).rounded(.down))
    slayerBand(m, from: band0, bars: bars, beat: beat)
    for k in [0.26, 0.33, 0.39] { m.crash(at(k), vol: 0.12); m.boom(at(k), vol: 0.3) }
    for k in [0.47, 0.508, 0.546, 0.584] { m.boom(at(k), vol: 0.35); m.snare(at(k), vol: 0.12) }
    let stake = at(0.712)
    m.boom(stake, vol: 0.6); m.crash(stake, vol: 0.16)
    m.chug(stake, root: 38, len: 1.2, mute: false, vol: 0.07)
    let fill = band0 + Double(bars) * 4 * beat
    for k in 0..<8 { m.snare(fill + Double(k) * beat / 4, vol: 0.07 + Double(k) * 0.012) }
    m.whoosh(at(0.93), 1.0, vol: 0.14)
    m.chug(at(0.88), root: 38, len: 1.6, mute: false, vol: 0.06); m.crash(at(0.88), vol: 0.12)
    // the sign: the DeSoto roaring in, the crash, the skid, the door, the boots
    let hc = start("homecoming")
    m.engine(hc + homeCarIn - 0.4, homeCrash - homeCarIn + 0.4, from: 70, to: 140, vol: 0.07)
    m.engine(hc + homeCrash, homeCarStop - homeCrash + 0.2, from: 140, to: 60, vol: 0.05)
    let crash = hc + homeCrash
    m.boom(crash, vol: 0.6); m.crash(crash, vol: 0.18)
    m.noise(crash, 0.5, vol: 0.25, cutoff: 0.7, decay: 0.12, seed: 77)
    for k in 0..<6 { m.noise(crash + 0.05 + Double(k) * 0.07, 0.05, vol: 0.1, cutoff: 0.9, decay: 0.02, highpass: true, seed: 80 + k) }
    m.chug(crash, root: 38, len: 0.9, mute: false, vol: 0.06)
    m.noise(crash + 0.1, homeCarStop - homeCrash, vol: 0.06, cutoff: 0.6, cutoffTo: 0.3, attack: 0.05, release: 0.2, highpass: true, seed: 88)
    m.clunk(hc + homeDoor, vol: 0.1)
    for k in 0..<4 { m.step(hc + homeSpyke + Double(k) * 0.16, vol: 0.08) }
    // Restfield: a low drone, earth crumbling, the bus's engine and brakes, the door, the fight, the dawn, the dust
    let rf = hc + slayerHomeCut
    m.tone(rf, 6.0, midi(26), wave: .saw, vol: 0.035, attack: 0.5, release: 1.0)
    m.tone(rf, 6.0, midi(33), wave: .saw, vol: 0.02, attack: 0.5, release: 1.0)
    for k in 0..<Int(4.2 / beat) where k % 2 == 0 { m.kick(rf + Double(k) * beat, vol: 0.18) }
    for (i, r) in homeRise.enumerated() { m.noise(rf + r, homeRiseLength, vol: 0.07, cutoff: 0.08, decay: 0.4, seed: 120 + i) }
    m.engine(rf + homeBusIn - 0.2, homeBusStop - homeBusIn + 0.2, from: 90, to: 55, vol: 0.06)
    m.noise(rf + homeBusStop - 0.1, 0.5, vol: 0.08, cutoff: 0.9, attack: 0.02, release: 0.3, highpass: true, seed: 131)   // the brakes' hiss
    m.clunk(rf + homeBusDoor, vol: 0.08)
    for i in homeOff.indices { for k in 0..<3 { m.step(rf + homeOff[i] + Double(k) * 0.15, vol: 0.06) } }
    m.whoosh(rf + homeFlip + 0.3, 0.4, vol: 0.08)
    m.ding(rf + slayerHomeFight - 0.05, vol: 0.05)
    slayerBand(m, from: rf + slayerHomeFight, bars: 1, beat: beat)
    m.shimmer(rf + slayerHomeFight - 0.2, homeDust[1] - slayerHomeFight + 0.4, vol: 0.03)
    for k in 0..<3 { m.thwip(rf + slayerHomeFight + 0.2 + Double(k) * 0.35, vol: 0.06); m.snare(rf + slayerHomeFight + 0.1 + Double(k) * 0.3, vol: 0.06) }
    m.organ(rf + homeDawn, 2.0, [50, 57, 62, 66], vol: 0.03)
    for d in homeDust { m.dust(rf + d, vol: 0.1) }
    // the app shots: the shared groove, and each shot's effects
    groove(m, from: start("hook"), to: start("endcard"), fadeIn: 1.2)
    let hook = start("hook")
    m.dust(hook - 0.6, vol: 0.12); m.boom(hook - 0.75, vol: 0.2)
    for i in 0..<26 { m.click(hook + 0.2 + Double(i) * 0.13 + noise(i) * 0.06) }
    let desk = start("desktop"), deskEnd = end("desktop") + 1.3
    for (i, d) in [0.0, 0.12, 0.24, 0.32].enumerated() { m.step(desk + d + 0.3, vol: 0.1 + Double(i % 2) * 0.03) }
    for t in clashTimes(desk + 0.45, deskEnd) { m.clang(t, vol: 0.07) }
    m.crackle(desk + 0.5, deskEnd - desk - 0.5, vol: 0.02)
    let st = start("status")
    for i in 0..<4 { m.pop(st + 0.1 + Double(i) * 0.22, step: i) }
    for k in 0..<5 { m.tone(st + 1.2 + Double(k) * 0.62, 0.08, 1568, wave: .square(0.5), vol: 0.035, release: 0.03) }
    let ag = start("agents")
    for k in 0..<14 { m.step(ag + Double(k) * 0.125, vol: 0.06) }
    let wi = start("window")
    m.tone(wi - 1.0, 1.4, 60, to: 40, wave: .saw, vol: 0.06, attack: 0.2, release: 0.4); m.boom(wi - 0.3, vol: 0.2)   // the Hellmouth
    for t in clashTimes(wi, wi + 2.5) { m.clang(t, vol: 0.05) }
    for k in [0.9, 1.8] { m.click(wi + k, vol: 0.06) }
    m.ping(wi + 2.5)
    let ais = start("ais")
    for i in 0..<6 { m.pop(ais + 0.15 + Double(i) * 0.1, step: i % 4) }
    for t in clashTimes(ais + 0.4, end("ais") + 1.0) { m.clang(t, vol: 0.04) }
    for s in shots { transitionSound(m, s) }
    // the end card: the organ chord, the band's last bar, then the stake slamming down on a big ringing chord
    let ec = start("endcard")
    m.organ(ec, 1.2, [38, 50, 53, 57], vol: 0.035)
    for k in 0..<4 { m.chug(ec + 0.45 + Double(k) * beat / 2, root: 41 - (k / 2) * 3, len: beat / 2 * 0.7, mute: true); m.kick(ec + 0.45 + Double(k) * beat / 2, vol: 0.2) }
    let slam = ec + 1.05
    m.boom(slam, vol: 0.6); m.crash(slam, vol: 0.18)
    m.chug(slam, root: 38, len: 2.6, mute: false, vol: 0.07)
    m.organ(slam, 2.8, [50, 57, 62, 65], vol: 0.03)
    m.boom(slam + 1.2, vol: 0.25)
}
