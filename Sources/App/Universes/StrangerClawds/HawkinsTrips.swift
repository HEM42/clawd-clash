import CoreGraphics
import Foundation

// The trips between Stranger Clawds places. Each is drawn in its own `Hawkins…Trip.swift` file, and every one of them
// ends the same way: Joyce's Christmas lights spell the new place's name over her painted alphabet
// (HawkinsLights.swift). Everything of a trip's own is pixel art in the Upside Down's blue-grey and red, 80s neon and
// the warm yellow of the bulbs, drawn into a `HawkinsArt` canvas and scaled up crisp; the old and new places are drawn
// with `drawShot`, so the window's info list stays sharp while the universe changes.

/// The ten kinds of trip.
enum HawkinsWipe: Int, CaseIterable {
    case title       // the opening titles: red neon letters slide in out of the dark and lock, then the camera pushes
                     // through the gap in a letter onto the new place (the rarest, and the longest)
    case flip        // the old place drains to the Upside Down's blue-grey, vines creep over it, spores rise, and it
                     // splits like a membrane onto the new place
    case gate        // a red, glowing crack splits the picture from top to bottom, pulses, and opens wide on the new place
    case walkie      // static rolls in, DO YOU COPY? OVER., and the picture tunes in through the noise on the new place
    case void        // everything goes black over a thin sheet of water; the new place shows in it and rises out of it
    case storm       // a red storm cloud rolls in with the Mind Flayer's shape in it, lightning, and it parts
    case clock       // the grandfather clock fills the picture and chimes four times; on the fourth its glass shatters
    case natural20   // a giant d20 tumbles across, stops on 20, flashes, and the new place is in the flash
    case fireworks   // fireworks burst over the dark, and the new place lights up in their glow
    case insertCoin  // an arcade screen: GAME OVER, INSERT COIN, and the new place loads like the next level

    /// How long its own part takes, in seconds; the lights take `HawkinsTrip.lights` more, overlapping its end.
    var effect: Double {
        switch self {
        case .title: return 2.75
        case .clock: return 2.0
        case .gate, .walkie: return 1.5
        case .flip, .void, .storm, .natural20, .fireworks, .insertCoin: return 1.7
        }
    }

    /// The whole trip, the lights included.
    var duration: Double { effect + HawkinsTrip.lights - HawkinsTrip.overlap }

    /// Who makes it likelier (on stage when the crew moves on).
    var owners: [Cast] {
        switch self {
        case .title: return [.hero(HawkinsHero.eleven), .hero(HawkinsHero.mikeWheeler)]
        case .flip: return [.hero(HawkinsHero.willByers)]
        case .gate: return [.villain(HawkinsVillain.drBrenner), .hero(HawkinsHero.drOwens)]
        case .walkie: return [.hero(HawkinsHero.mikeWheeler), .hero(HawkinsHero.dustinHenderson), .hero(HawkinsHero.suzie)]
        case .void: return [.hero(HawkinsHero.eleven), .hero(HawkinsHero.kali)]
        case .storm: return [.hero(HawkinsHero.willByers), .villain(HawkinsVillain.vecna)]
        case .clock: return [.villain(HawkinsVillain.vecna), .villain(HawkinsVillain.one)]
        case .natural20: return [.hero(HawkinsHero.eddieMunclawd), .hero(HawkinsHero.mikeWheeler),
                                 .hero(HawkinsHero.dustinHenderson), .hero(HawkinsHero.lucasSinclawd)]
        case .fireworks: return [.hero(HawkinsHero.steveHarringclawd), .hero(HawkinsHero.robinBuckley),
                                 .hero(HawkinsHero.ericaSinclair), .hero(HawkinsHero.dustinHenderson)]
        case .insertCoin: return [.hero(HawkinsHero.maxMayfield), .hero(HawkinsHero.dustinHenderson)]
        }
    }

    /// Where it's likelier to go.
    var turf: [Location] {
        switch self {
        case .title: return []
        case .flip, .storm: return [.hawkinsUpsideDown]
        case .gate: return [.hawkinsLab]
        case .walkie: return [.hawkinsBasement]
        case .void: return [.hawkinsVoid]
        case .clock: return [.hawkinsMind, .hawkinsCreel]
        case .natural20: return [.hawkinsTrailer, .hawkinsBasement]
        case .fireworks: return [.hawkinsStarcourt]
        case .insertCoin: return [.hawkinsArcade]
        }
    }
}

/// One trip's transition. Shared by the window and the screen saver, which hand over the old picture (frozen), the
/// new one (as it is right now) and how far through it is; a frame is drawn over the whole of `r`.
struct HawkinsTrip {
    let kind: HawkinsWipe
    var from: Location = .hawkinsBasement, to: Location = .hawkinsBasement
    var duration: Double { kind.duration }

    /// How long Joyce's lights take at the end of every trip, and how much of that runs over the trip's own end.
    static let lights = 1.5, overlap = 0.25

    /// Any trip but the last one's kind: likelier with one of its owners on stage or going to its turf; the opening
    /// titles the rarest, their owners only making them a little less rare.
    static func pick(after last: HawkinsWipe?, cast: [Cast], from: Location?, to place: Location) -> HawkinsTrip {
        let here = Set(cast)
        var kinds: [HawkinsWipe] = []
        for kind in HawkinsWipe.allCases where kind != last {
            let owned = kind.owners.contains(where: here.contains)
            if kind == .title {
                if Double.random(in: 0..<1) < (owned ? 0.45 : 0.25) { kinds.append(kind) }
                continue
            }
            kinds.append(kind)
            if owned { kinds += [kind, kind, kind] }
            if kind.turf.contains(place) { kinds += [kind, kind] }
        }
        let start = from.flatMap { $0.universe == .hawkins ? $0 : nil } ?? .hawkinsBasement
        return HawkinsTrip(kind: kinds.randomElement() ?? .gate, from: start, to: place)
    }

    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`: the trip's own part, then the lights.
    func draw(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        ctx.saveGState(); defer { ctx.restoreGState() }
        ctx.interpolationQuality = .none
        ctx.clip(to: r)
        let t = k * duration
        if t < kind.effect {
            let e = t / kind.effect
            switch kind {
            case .title: drawTitle(ctx, old: old, new: new, k: e, in: r)
            case .flip: drawFlip(ctx, old: old, new: new, k: e, in: r)
            case .gate: drawGate(ctx, old: old, new: new, k: e, in: r)
            case .walkie: drawWalkie(ctx, old: old, new: new, k: e, in: r)
            case .void: drawVoid(ctx, old: old, new: new, k: e, in: r)
            case .storm: drawStorm(ctx, old: old, new: new, k: e, in: r)
            case .clock: drawClock(ctx, old: old, new: new, k: e, in: r)
            case .natural20: drawNatural20(ctx, old: old, new: new, k: e, in: r)
            case .fireworks: drawFireworks(ctx, old: old, new: new, k: e, in: r)
            case .insertCoin: drawInsertCoin(ctx, old: old, new: new, k: e, in: r)
            }
        } else {
            ctx.drawShot(new, in: r)
        }
        let lit = t - (duration - Self.lights)
        if lit > 0 { drawLights(ctx, t: lit, in: r) }
    }

    // MARK: Shared helpers, for every trip file

    static func ease(_ k: Double) -> Double { k * k * (3 - 2 * k) }
    static func clamp(_ k: Double) -> Double { min(1, max(0, k)) }
    /// How far `k` is through `a…b`: 0 before, 1 after.
    static func span(_ k: Double, _ a: Double, _ b: Double) -> Double { clamp((k - a) / (b - a)) }

    /// A colour that's `k` of the way from `a` to `b`.
    static func mix(_ a: UInt32, _ b: UInt32, _ k: Double, _ alpha: Double = 1) -> Px {
        func ch(_ s: UInt32) -> UInt32 {
            let x = Double(a >> s & 0xFF), y = Double(b >> s & 0xFF)
            return UInt32(max(0, min(255, (x + (y - x) * k).rounded())))
        }
        return C(ch(16) << 16 | ch(8) << 8 | ch(0), alpha)
    }

    /// A whole-picture wash over `r` in `hex` at `alpha`, stepped to quarters so it darkens in pixel-art steps.
    static func wash(_ ctx: CGContext, _ hex: UInt32, _ alpha: Double, in r: CGRect) {
        let a = (alpha * 8).rounded() / 8
        guard a > 0 else { return }
        ctx.setFillColor(rgb(hex, CGFloat(a))); ctx.fill(r)
    }
}

extension HawkinsTrip: Trip {}

/// A trip's own pixel art: a canvas over the whole frame, rows counted down from the top, about 160 pixels tall (two
/// screen pixels to one at the least, so the window's strip gets real pixels too), scaled up onto the frame without
/// smoothing. The window's strip comes out about 480×112, the screen saver about 256×160.
final class HawkinsArt {
    let c: PixelCanvas
    let px: CGFloat
    let r: CGRect

    init(_ r: CGRect) {
        self.r = r
        px = max(2, (r.height / 160).rounded())
        c = PixelCanvas(max(1, Int((r.width / px).rounded(.up))), max(1, Int((r.height / px).rounded(.up))))
    }

    var w: Int { c.w }
    var h: Int { c.h }
    /// The window's short, wide strip, as against the screen saver's taller frame.
    var wide: Bool { Double(w) / Double(h) > 2.4 }

    /// A box of the art (`x`, `y` from the top-left, in art pixels) in the frame's own coordinates.
    func frame(_ x: Int, _ y: Int, _ w: Int, _ hh: Int) -> CGRect {
        CGRect(x: r.minX + CGFloat(x) * px, y: r.maxY - CGFloat(y + hh) * px, width: CGFloat(w) * px, height: CGFloat(hh) * px)
    }

    /// The rows `y` of the art where `inside(x, y)` holds, as one rectangle per run, in the frame's coordinates: to clip
    /// an old or new place to a shape cut on the art's grid.
    func runs(_ inside: (Int, Int) -> Bool) -> [CGRect] {
        var out: [CGRect] = []
        for y in 0..<h {
            var x = 0
            while x < w {
                guard inside(x, y) else { x += 1; continue }
                let x0 = x
                while x < w && inside(x, y) { x += 1 }
                out.append(frame(x0, y, x - x0, 1))
            }
        }
        return out
    }

    /// The art onto `ctx`, scaled up crisp.
    func show(_ ctx: CGContext, alpha: Double = 1) {
        guard alpha > 0, let img = c.makeImage() else { return }
        ctx.saveGState()
        ctx.clip(to: r)
        ctx.interpolationQuality = .none
        ctx.setAlpha(CGFloat(alpha))
        ctx.draw(img, in: frame(0, 0, w, h))
        ctx.restoreGState()
    }
}

// MARK: Lettering

/// The trips' lettering, 5 dots tall (`hawkinsSoftText`'s glyph strings, row by row): Joyce's alphabet (as the Byers'
/// wall has it: three dots wide, M and W five, N four, so their diagonals read), the digits and a little punctuation.
let hawkinsTripGlyphs: [Character: String] = [
    "A": "010101111101101", "B": "110101110101110", "C": "011100100100011", "D": "110101101101110",
    "E": "111100110100111", "F": "111100110100100", "G": "011100101101011", "H": "101101111101101",
    "I": "111010010010111", "J": "001001001101010", "K": "101101110101101", "L": "100100100100111",
    "M": "1000111011101011000110001", "N": "10011101101110011001", "O": "010101101101010", "P": "110101110100100",
    "Q": "010101101110011", "R": "110101110101101", "S": "011100010001110", "T": "111010010010010",
    "U": "101101101101111", "V": "101101101101010", "W": "1000110001101011101110001", "X": "101101010101101",
    "Y": "101101010010010", "Z": "111001010100111",
    "0": "111101101101111", "1": "010110010010111", "2": "111001111100111", "3": "111001011001111",
    "4": "101101111001001", "5": "111100111001111", "6": "111100111101111", "7": "111001001010010",
    "8": "111101111101111", "9": "111101111001111",
    "'": "11000", ".": "00001", "?": "111001010000010", "!": "11101", "-": "000000111000000",
]

/// How wide `text` comes out at `p` pixels a dot (a space is three dots, as `hawkinsSoftText` leaves it).
func hawkinsTripTextWidth(_ text: String, _ p: Int) -> Int {
    var dots = 0, last = false
    for ch in text {
        if let g = hawkinsTripGlyphs[ch] { dots += g.count / 5 + 1; last = true } else { dots += 3; last = false }
    }
    return max(0, (dots - (last ? 1 : 0)) * p)
}

/// Lettering at `p` pixels a dot, from its top-left corner, with a drop of `shadow` (if any) a pixel down and right of
/// it all round, so it stands off whatever's behind it.
func hawkinsTripText(_ c: PixelCanvas, _ x: Int, _ y: Int, _ text: String, _ col: Px, _ p: Int, shadow: Px? = nil) {
    if let shadow {
        let d = max(1, p / 2)
        for (dx, dy) in [(d, d), (-d, 0), (d, 0), (0, -d), (0, d), (d, -d), (-d, d)] {
            hawkinsSoftText(c, x + dx, y + dy, text, hawkinsTripGlyphs, shadow, p)
        }
    }
    hawkinsSoftText(c, x, y, text, hawkinsTripGlyphs, col, p)
}

/// Lettering centred on `cx`.
func hawkinsTripCentred(_ c: PixelCanvas, _ cx: Int, _ y: Int, _ text: String, _ col: Px, _ p: Int, shadow: Px? = nil) {
    hawkinsTripText(c, cx - hawkinsTripTextWidth(text, p) / 2, y, text, col, p, shadow: shadow)
}
