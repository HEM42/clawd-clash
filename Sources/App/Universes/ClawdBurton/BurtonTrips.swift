import CoreGraphics
import Foundation

/// The trips between Clawd Burton places. Each is drawn in its own `Burton…Trip.swift` file; every one ends with the new
/// place's name written in spidery, curling letters in the top-left corner, a little spiral flourish under it.
enum BurtonWipe: Int, CaseIterable {
    case flyover        // the Model Town Flyover: dusk over a hill town, a giant spider, it's the attic model (the rarest)
    case spiralHill     // Spiral Hill rises against the moon and uncurls across the screen, rolling out the new place
    case jackOLantern   // a huge carved pumpkin swings in, its grin opening wider until the new place fills the mouth
    case stripes        // black-and-white stripes slide in, twist into a spinning spiral and unwind on the new place
    case sandworm       // the floor ripples, the striped sandworm bursts up, swallows the picture, dives, sand settles
    case greyToColour   // the old place drains to grey-blue, blue butterflies sweep across, the new one blooms in colour
    case horseman       // mist, hoofbeats, the Headless Horseman gallops across, his sword slicing the picture in two
    case iceDance       // ice shavings fly up and fall as snow until the screen is white; it thins on the new place
    case saucers        // Martian saucers swoop in zapping the picture into pixels, peel off, a tiny "ACK ACK"
    case wonkavision    // the picture breaks into tiny pixels that fly up and come down inside an old TV, which zooms out
    case rabbitHole     // the picture falls away; down a long earthy hole past clocks, teacups and a piano
    case itsAlive       // lightning strikes a kite, the scene flashes black and white, the new place, colour seeps back

    var duration: Double {
        switch self {
        case .flyover: return 3.4
        case .stripes, .greyToColour, .saucers: return 2.0
        case .spiralHill, .jackOLantern, .horseman, .iceDance, .itsAlive: return 2.2
        case .sandworm, .wonkavision, .rabbitHole: return 2.4
        }
    }

    /// Who makes it likelier (on stage when the crew moves on).
    var owners: [Cast] {
        switch self {
        case .flyover: return []
        case .spiralHill: return [.hero(BurtonHero.jackSkullington), .hero(BurtonHero.zeero)]
        case .jackOLantern:
            return ([.jackSkullington, .sallee, .zeero, .theMayor, .largeMarge] as [BurtonHero]).map { Cast.hero($0) }
                + ([.ooogieBoogie, .lok, .shok, .barrell, .drFinkelclawd, .wolfclawd, .tearAwayClown, .halloweenWitch]
                   as [BurtonVillain]).map { Cast.villain($0) }
        case .stripes: return [.villain(BurtonVillain.beetlejooce), .villain(BurtonVillain.bob)]
        case .sandworm: return [.villain(BurtonVillain.sandwurm), .hero(BurtonHero.adamMaitclawd), .hero(BurtonHero.barbaraMaitclawd)]
        case .greyToColour:
            return ([.emilee, .bonejingles, .victorVanDawt, .victoriaEverclawt, .scrapz, .elderGutknocked,
                     .generalBonesapart] as [BurtonHero]).map { Cast.hero($0) }
        case .horseman: return [.villain(BurtonVillain.headlessHorseclawd), .hero(BurtonHero.ichabodCraine)]
        case .iceDance: return [.hero(BurtonHero.edwardScissorclaws), .hero(BurtonHero.kimBoggz)]
        case .saucers:
            return ([.martianLeader, .martianAmbassador, .martianTrooper, .martianSpy, .martianWalker]
                    as [BurtonVillain]).map { Cast.villain($0) }
        case .wonkavision: return [.hero(BurtonHero.willyWonky), .villain(BurtonVillain.mikeTeevee)]
        case .rabbitHole: return [.hero(BurtonHero.aliceKingsclaw), .hero(BurtonHero.mcTwisp), .hero(BurtonHero.tarrantHightop)]
        case .itsAlive: return [.hero(BurtonHero.victorFrankenstien), .hero(BurtonHero.sparkie)]
        }
    }

    /// Where it's likelier to go.
    var turf: [Location] {
        switch self {
        case .flyover: return [.modelWinterRiver, .maitlandHouse, .breakfastMachineHouse]
        case .spiralHill: return [.halloweenTown, .spiralHill]
        case .jackOLantern: return [.halloweenTown, .oogiesLair]
        case .stripes: return [.modelWinterRiver]
        case .sandworm: return [.sandwormSaturn, .maitlandHouse]
        case .greyToColour: return [.landOfTheDead, .everglotVillage]
        case .horseman: return [.treeOfTheDead, .hollowVillage]
        case .iceDance: return [.inventorsCastle, .pastelSuburbia]
        case .saucers: return [.martianSaucerDeck, .perkinsvilleKansas, .galaxyHotel]
        case .wonkavision: return [.chocolateRoom]
        case .rabbitHole: return [.madTeaParty, .salazenGrum]
        case .itsAlive: return [.newHollandAttic, .windmillMiniGolf]
        }
    }
}

/// One trip's transition. Shared by the window and the screen saver, which hand over the old picture (frozen), the
/// new one (as it is right now) and how far through it is; a frame is drawn over the whole of `r`.
struct BurtonTrip {
    let kind: BurtonWipe
    var from: Location = .halloweenTown, to: Location = .halloweenTown
    var duration: Double { kind.duration }
    /// How much of the crew shows at `k` (`ComicTransition.crewShown`): 1 unless a trip leaves the ground.
    func crewShown(_ k: Double) -> Double { 1 }

    /// Any trip but the last one's kind: likelier with one of its owners on stage or going to its turf; the Model Town
    /// Flyover is the rarest.
    static func pick(after last: BurtonWipe?, cast: [Cast], from: Location?, to place: Location) -> BurtonTrip {
        let here = Set(cast)
        var kinds: [BurtonWipe] = []
        for kind in BurtonWipe.allCases where kind != last {
            let owned = kind.owners.contains(where: here.contains), home = kind.turf.contains(place)
            if kind == .flyover {
                if Double.random(in: 0..<1) < (home ? 0.6 : 0.25) { kinds.append(kind) }
                continue
            }
            kinds.append(kind)
            if owned { kinds += [kind, kind, kind] }
            if home { kinds += [kind, kind] }
        }
        let start = from.flatMap { $0.universe == .clawdBurton ? $0 : nil } ?? .halloweenTown
        return BurtonTrip(kind: kinds.randomElement() ?? .stripes, from: start, to: place)
    }

    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`, with the new place's name written in.
    func draw(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        ctx.saveGState()
        ctx.interpolationQuality = .none
        switch kind {
        case .flyover: drawFlyover(ctx, old: old, new: new, k: k, in: r)
        case .spiralHill: drawSpiralHill(ctx, old: old, new: new, k: k, in: r)
        case .jackOLantern: drawJackOLantern(ctx, old: old, new: new, k: k, in: r)
        case .stripes: drawStripes(ctx, old: old, new: new, k: k, in: r)
        case .sandworm: drawSandworm(ctx, old: old, new: new, k: k, in: r)
        case .greyToColour: drawGreyToColour(ctx, old: old, new: new, k: k, in: r)
        case .horseman: drawHorseman(ctx, old: old, new: new, k: k, in: r)
        case .iceDance: drawIceDance(ctx, old: old, new: new, k: k, in: r)
        case .saucers: drawSaucers(ctx, old: old, new: new, k: k, in: r)
        case .wonkavision: drawWonkavision(ctx, old: old, new: new, k: k, in: r)
        case .rabbitHole: drawRabbitHole(ctx, old: old, new: new, k: k, in: r)
        case .itsAlive: drawItsAlive(ctx, old: old, new: new, k: k, in: r)
        }
        ctx.restoreGState()
        drawPlaceName(ctx, k: k, in: r)
    }

    // MARK: Shared helpers, for every trip file

    static func ease(_ k: Double) -> Double { k * k * (3 - 2 * k) }
    static func clamp(_ k: Double) -> Double { min(1, max(0, k)) }
    /// How far `k` is through `a…b`: 0 before, 1 after.
    static func span(_ k: Double, _ a: Double, _ b: Double) -> Double { clamp((k - a) / (b - a)) }

    /// Screen pixels per art pixel for a frame `r`: the trips' pixel art is as chunky as the places' in the window, and
    /// grows with the screen saver.
    static func artPixel(_ r: CGRect) -> CGFloat { max(2, (r.height / 200).rounded()) }

    /// A bitmap for a trip's own pixel art over `r`, drawn into in `r`'s coordinates at `px` screen pixels per art
    /// pixel, unsmoothed; `blit` scales it back up onto `r`.
    static func artCanvas(width w: Int, height h: Int, px: CGFloat, in r: CGRect) -> CGContext? {
        guard w > 0, h > 0, let c = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                                              space: CGColorSpaceCreateDeviceRGB(),
                                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        c.setShouldAntialias(false)
        c.scaleBy(x: 1 / px, y: 1 / px)
        c.translateBy(x: -r.minX, y: -r.minY)
        return c
    }

    /// The art, scaled up onto `r` without smoothing.
    static func blit(_ art: CGContext, onto ctx: CGContext, width w: Int, height h: Int, px: CGFloat, in r: CGRect) {
        guard let img = art.makeImage() else { return }
        ctx.saveGState()
        ctx.clip(to: r)
        ctx.interpolationQuality = .none
        ctx.draw(img, in: CGRect(x: r.minX, y: r.minY, width: CGFloat(w) * px, height: CGFloat(h) * px))
        ctx.restoreGState()
    }

    /// A `PixelCanvas` the size of `r` in art pixels, for drawing a trip's pixel art with the app's own canvas helpers
    /// (y down, as the sprites and places are); `blitCanvas` puts it on screen.
    static func pixelCanvas(in r: CGRect) -> (canvas: PixelCanvas, px: CGFloat) {
        let px = artPixel(r)
        return (PixelCanvas(max(1, Int((r.width / px).rounded(.up))), max(1, Int((r.height / px).rounded(.up)))), px)
    }

    /// A `PixelCanvas` from `pixelCanvas` drawn over `r`, crisp, faded to `alpha`.
    static func blitCanvas(_ c: PixelCanvas, onto ctx: CGContext, px: CGFloat, in r: CGRect, alpha: CGFloat = 1) {
        guard alpha > 0.01, let img = c.makeImage() else { return }
        ctx.saveGState()
        ctx.clip(to: r)
        ctx.interpolationQuality = .none
        ctx.setAlpha(alpha)
        ctx.draw(img, in: CGRect(x: r.minX, y: r.maxY - CGFloat(c.h) * px, width: CGFloat(c.w) * px, height: CGFloat(c.h) * px))
        ctx.restoreGState()
    }

    /// `img` drawn centred on `c`, turned `turn` radians and scaled `scale`, over a frame the size of `r`.
    static func picture(_ ctx: CGContext, _ img: CGImage, in r: CGRect, at c: CGPoint, scale: CGFloat, turn: CGFloat = 0,
                        alpha: CGFloat = 1) {
        guard scale > 0.003, alpha > 0.01 else { return }
        ctx.saveGState()
        ctx.translateBy(x: c.x, y: c.y); ctx.rotate(by: turn); ctx.scaleBy(x: scale, y: scale)
        ctx.setAlpha(alpha)
        ctx.interpolationQuality = .none
        ctx.draw(img, in: CGRect(x: -r.width / 2, y: -r.height / 2, width: r.width, height: r.height))
        ctx.restoreGState()
    }

    /// A plain crossfade, for a trip not drawn yet.
    static func crossfade(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        ctx.draw(old, in: r)
        ctx.setAlpha(CGFloat(ease(k)))
        ctx.draw(new, in: r)
        ctx.setAlpha(1)
    }

    // MARK: The finishing touch: the new place's name, written in

    /// The letters of the place-name lettering, as strokes in each letter's own box (`u` across, `v` down, 0…1): tall,
    /// thin and a little wobbly, the C, the L and the N curling at their ends, as Burton's titles look (our own hand).
    static let letters: [Character: [[(Double, Double)]]] = {
        func arc(_ cx: Double, _ cy: Double, _ rx: Double, _ ry: Double, _ a0: Double, _ a1: Double, _ n: Int = 10) -> [(Double, Double)] {
            (0...n).map { i in
                let a = (a0 + (a1 - a0) * Double(i) / Double(n)) * .pi / 180
                return (cx + cos(a) * rx, cy + sin(a) * ry)
            }
        }
        let bowlTop = arc(0.15, 0.27, 0.7, 0.27, -90, 90, 8), ring = arc(0.5, 0.5, 0.45, 0.5, 0, 360, 16)
        return [
            "A": [[(0, 1), (0.5, 0), (1, 1)], [(0.22, 0.62), (0.8, 0.6)]],
            "B": [[(0.15, 0), (0.15, 1)], arc(0.15, 0.25, 0.64, 0.25, -90, 90, 8), arc(0.15, 0.74, 0.8, 0.26, -90, 90, 8)],
            "C": [[(0.98, 0.16), (0.9, 0.08), (0.8, 0.14), (0.84, 0.24)] + arc(0.55, 0.5, 0.48, 0.5, -50, -310, 14)],
            "D": [[(0.18, 0), (0.18, 1)], arc(0.18, 0.5, 0.74, 0.5, -90, 90, 12)],
            "E": [[(0.85, 0), (0.15, 0), (0.15, 1), (0.88, 1)], [(0.15, 0.5), (0.7, 0.48)]],
            "F": [[(0.85, 0), (0.15, 0), (0.15, 1)], [(0.15, 0.5), (0.7, 0.48)]],
            "G": [arc(0.55, 0.5, 0.48, 0.5, -40, -340, 14) + [(0.6, 0.6)]],
            "H": [[(0.15, 0), (0.15, 1)], [(0.85, 0), (0.85, 1)], [(0.15, 0.52), (0.85, 0.48)]],
            "I": [[(0.5, 0), (0.5, 1)], [(0.25, 0), (0.75, 0)], [(0.25, 1), (0.75, 1)]],
            "J": [[(0.85, 0), (0.85, 0.7)] + arc(0.5, 0.7, 0.35, 0.3, 0, 180, 8)],
            "K": [[(0.15, 0), (0.15, 1)], [(0.85, 0), (0.15, 0.56)], [(0.36, 0.42), (0.9, 1)]],
            "L": [[(0.2, 0), (0.2, 1), (0.94, 1), (1.0, 0.9), (0.93, 0.82), (0.86, 0.9)]],
            "M": [[(0.05, 1), (0.15, 0), (0.5, 0.6), (0.85, 0), (0.95, 1)]],
            "N": [[(0.12, 1), (0.12, 0), (0.88, 1), (0.88, 0.04), (0.96, -0.06), (1.04, 0.0), (0.98, 0.07)]],
            "O": [ring],
            "P": [[(0.15, 1), (0.15, 0)] + bowlTop],
            "Q": [ring, [(0.6, 0.72), (0.95, 1.05)]],
            "R": [[(0.15, 1), (0.15, 0)] + bowlTop, [(0.4, 0.54), (0.95, 1)]],
            "S": [arc(0.5, 0.27, 0.4, 0.27, -20, -270, 9) + arc(0.5, 0.75, 0.42, 0.25, -90, 150, 9)],
            "T": [[(0, 0.05), (1, 0)], [(0.53, 0), (0.47, 1)]],
            "U": [[(0.12, 0), (0.12, 0.62)] + arc(0.5, 0.62, 0.38, 0.38, 180, 0, 10) + [(0.88, 0)]],
            "V": [[(0, 0), (0.5, 1), (1, 0)]],
            "W": [[(0, 0.04), (0.24, 1), (0.5, 0.34), (0.76, 1), (1, 0.04)]],
            "X": [[(0.05, 0), (0.95, 1)], [(0.95, 0), (0.05, 1)]],
            "Y": [[(0, 0), (0.5, 0.5), (1, 0)], [(0.5, 0.5), (0.5, 1)]],
            "Z": [[(0.1, 0), (0.9, 0), (0.1, 1), (0.9, 1)]],
            "'": [[(0.55, -0.05), (0.62, 0.08), (0.5, 0.14), (0.35, 0.32)]],
            ",": [[(0.55, 0.88), (0.35, 1.2)]],
            ".": [[(0.5, 0.94), (0.5, 1.0)]],
            "-": [[(0.1, 0.55), (0.9, 0.5)]],
            "!": [[(0.5, 0), (0.5, 0.7)], [(0.5, 0.94), (0.5, 1.0)]],
        ]
    }()

    /// How wide each letter is, against its height.
    static func letterWidth(_ ch: Character) -> Double {
        switch ch {
        case "W", "M": return 1.0
        case "I": return 0.45
        case "'", ",", ".", "!": return 0.25
        case " ": return 0.45
        default: return 0.68
        }
    }

    /// The new place's name, written in over the end of the trip in the top-left corner: the strokes drawn in one
    /// after another, then a little spiral flourish under them; it fades as the trip finishes. Bone white with an ink
    /// edge and a moonlit violet glow, in the art's own chunky pixels.
    func drawPlaceName(_ ctx: CGContext, k: Double, in r: CGRect) {
        let write = Self.span(k, 0.5, 0.82), fade = 1 - Self.span(k, 0.93, 1)
        guard write > 0, fade > 0 else { return }
        let (c, px) = Self.pixelCanvas(in: r)
        let name = to.name.uppercased(), x0 = max(3, Double(c.w) * 0.03), y0 = max(3, Double(c.h) * 0.05)
        // As tall as suits the frame, but never wider than most of it: long names come out smaller.
        let units = name.reduce(0) { $0 + Self.letterWidth($1) + 0.22 } + 0.4
        let h = max(5.0, min(max(7.0, Double(c.h) * 0.07), (Double(c.w) * 0.94 - x0) / units)), gap = h * 0.22
        // The strokes, letter by letter, then the underline curling into a spiral.
        var strokes: [[(x: Double, y: Double)]] = []
        var x = x0
        for (i, ch) in name.enumerated() {
            let w = Self.letterWidth(ch) * h
            for line in Self.letters[ch] ?? [] {
                strokes.append(line.enumerated().map { j, p in
                    (x + p.0 * w + (1 - p.1) * h * 0.1 + (noise(i * 31 + j * 7 + 4600) - 0.5) * 0.6,
                     y0 + p.1 * h + (noise(i * 31 + j * 7 + 4603) - 0.5) * 0.5)
                })
            }
            x += w + gap
        }
        let under = y0 + h + max(2, h * 0.3)
        var flourish: [(x: Double, y: Double)] = [(x0, under), (x - gap - h * 0.4, under + 0.5)]
        for i in 0...18 {
            let f = Double(i) / 18, a = (-90 + f * 560) * .pi / 180, rr = h * 0.4 * (1 - f * 0.75)
            flourish.append((x - gap + cos(a) * rr, under - h * 0.4 + sin(a) * rr + h * 0.4))
        }
        strokes.append(flourish)
        // How much of the total length is written so far.
        let lengths = strokes.map { s in zip(s, s.dropFirst()).reduce(0) { $0 + hypot($1.1.x - $1.0.x, $1.1.y - $1.0.y) } }
        var budget = lengths.reduce(0, +) * write
        let violet = C(0x6B5BD6), ink = C(0x16161B), bone = C(0xF2EEE3), thin = h < 10
        var segments: [((x: Double, y: Double), (x: Double, y: Double))] = []
        for (s, len) in zip(strokes, lengths) where budget > 0 {
            var left = min(budget, len)
            for (a, b) in zip(s, s.dropFirst()) where left > 0 {
                let d = hypot(b.x - a.x, b.y - a.y), f = min(1, left / max(d, 0.001))
                segments.append((a, (a.x + (b.x - a.x) * f, a.y + (b.y - a.y) * f)))
                left -= d
            }
            budget -= len
        }
        for (a, b) in segments { c.glowLine(a.x, a.y, b.x, b.y, core: violet.alpha(0.3), glow: violet.alpha(0.28), coreR: 1.4, glowR: 3.4) }
        for (a, b) in segments { c.glowLine(a.x, a.y, b.x, b.y, core: ink, glow: C(0, 0), coreR: thin ? 1.0 : 1.3, glowR: thin ? 1.05 : 1.35) }
        for (a, b) in segments { c.glowLine(a.x, a.y, b.x, b.y, core: bone, glow: C(0, 0), coreR: thin ? 0.45 : 0.6, glowR: thin ? 0.5 : 0.65) }
        Self.blitCanvas(c, onto: ctx, px: px, in: r, alpha: CGFloat(fade))
    }
}
