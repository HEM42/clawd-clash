import CoreGraphics
import Foundation

/// The trips between Clawd Slayer places. Each is drawn in its own `Slayer…Trip.swift` file.
enum SlayerWipe: Int, CaseIterable {
    case titles     // the opening titles: organ, moon, fast cuts, the leads' silhouettes, CLAWD SLAYER (the rarest)
    case dusting    // a stake strikes and the old place bursts into dust that blows away (the most common)
    case tome       // a Watcher's book thuds down, pages flip, the new place is a woodcut that fills with colour
    case spell      // a circle of candles, Willow's green ribbon spirals in, the scene twists through it
    case boredNow   // black veins crawl in from the edges until it's dark, then draw back (only with Dark Willow)
    case hellmouth  // the floor splits, red light, the old place tumbles in, the new one rises as it seals
    case hush       // colour drains, the Gentlemen float across, voices drift into a box (only with the Gentlemen)
    case musical    // "Once More, With Feeling": red curtains shut, a spotlight on a top hat, they open again
    case sunrise    // a line of dawn light sweeps across and burns the old place off
    case key        // green energy coils in and the tower's portal tears open on the new place
    case coatSwish  // a long black coat sweeps across as someone strides past, city lights in its folds
    case lift       // Wolfram & Hart's lift doors close, the floors count, ding, they open on the new place
    case restless   // sand blows across, the First Slayer's painted face looms out of it, the sand clears

    var duration: Double {
        switch self {
        case .titles: return 3.4
        case .dusting: return 1.6
        case .coatSwish: return 1.4
        case .hellmouth, .musical, .lift, .hush: return 2.2
        case .tome, .spell, .boredNow, .sunrise, .key, .restless: return 2.0
        }
    }

    /// Who makes it likelier (on stage when the crew moves on).
    var owners: [Cast] {
        switch self {
        case .titles: return []
        case .dusting:
            return [.hero(.buffyClawmers), .hero(.faithLehayne), .hero(.kendraYung), .hero(.kennedie), .hero(.vy),
                    .hero(.rhona)] + Self.vampires
        case .tome: return [.hero(.rupertGyles), .hero(.wesleyWindupPryce), .hero(.jennyClawlendar),
                            .villain(.quentinTravesty), .villain(.gwendolynPoste)]
        case .spell: return [.hero(.willowRosenclaw), .hero(.taraMaclaw)]
        case .boredNow: return [.villain(.darkWillow)]
        case .hellmouth: return [.villain(.oldMaster), .villain(.firstEvil), .villain(.turokHahn)]
        case .hush: return [.villain(.gentlemen)]
        case .musical: return [.villain(.sweete), .hero(.taraMaclaw), .hero(.anyaJinkins)]
        case .sunrise: return [.hero(.spyke), .hero(.angstel)]
        case .key: return [.villain(.glorificlaws), .hero(.dawnClawmers), .villain(.dok)]
        case .coatSwish: return [.hero(.angstel), .hero(.spyke)]
        case .lift: return [.villain(.lilahMorgane), .villain(.lindseyMcDonclawd), .villain(.hollandMannerly),
                            .hero(.wesleyWindupPryce)]
        case .restless: return [.hero(.firstSlayer)]
        }
    }

    /// Where it's likelier to go.
    var turf: [Location] {
        switch self {
        case .titles, .dusting, .boredNow: return []
        case .tome: return [.slayerLibrary, .slayerMagicBox]
        case .spell: return [.slayerMagicBox]
        case .hellmouth: return [.slayerHellmouth, .slayerLibrary]
        case .hush: return [.slayerCampus]
        case .musical: return [.slayerBronze]
        case .sunrise: return [.slayerCemetery, .slayerCrater]
        case .key: return [.slayerTower]
        case .coatSwish: return [.slayerHyperion, .slayerWolframHart]
        case .lift: return [.slayerWolframHart]
        case .restless: return [.slayerDreamDesert]
        }
    }

    /// Only ever with its owner on stage: Dark Willow's veins, the Gentlemen's silence.
    var needsOwner: Bool { self == .boredNow || self == .hush }

    static let vampires: [Cast] = ([.oldMaster, .lukewarm, .darlah, .drusillah, .mrTricks, .harmonyClawdall, .kakistoes,
                                   .sundae, .lyleGrouch, .draclawla, .turokHahn, .fledgling] as [SlayerVillain]).map { Cast.villain($0) }
}

/// One trip's transition. Shared by the window and the screen saver, which hand over the old picture (frozen), the
/// new one (as it is right now) and how far through it is; a frame is drawn over the whole of `r`.
struct SlayerTrip {
    let kind: SlayerWipe
    var from: Location = .slayerLibrary, to: Location = .slayerLibrary
    var duration: Double { kind.duration }
    /// How much of the crew shows at `k` (`ComicTransition.crewShown`): 1 unless a trip leaves the ground.
    func crewShown(_ k: Double) -> Double { 1 }

    /// Any trip but the last one's kind: likelier with one of its owners on stage or going to its turf, never one
    /// that needs its owner without them; Dusting is the most common and the opening titles the rarest.
    static func pick(after last: SlayerWipe?, cast: [Cast], from: Location?, to place: Location) -> SlayerTrip {
        let here = Set(cast)
        var kinds: [SlayerWipe] = []
        for kind in SlayerWipe.allCases where kind != last {
            let owned = kind.owners.contains(where: here.contains)
            if kind.needsOwner && !owned { continue }
            if kind == .titles { if Double.random(in: 0..<1) < 0.3 { kinds.append(kind) }; continue }
            kinds.append(kind)
            if kind == .dusting { kinds.append(kind) }
            if owned { kinds += [kind, kind, kind] }
            if kind.turf.contains(place) { kinds += [kind, kind] }
        }
        let start = from.flatMap { $0.universe == .slayer ? $0 : nil } ?? .slayerLibrary
        return SlayerTrip(kind: kinds.randomElement() ?? .dusting, from: start, to: place)
    }

    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`.
    func draw(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        ctx.saveGState(); defer { ctx.restoreGState() }
        ctx.interpolationQuality = .none
        switch kind {
        case .titles: drawTitles(ctx, old: old, new: new, k: k, in: r)
        case .dusting: drawDusting(ctx, old: old, new: new, k: k, in: r)
        case .tome: drawTome(ctx, old: old, new: new, k: k, in: r)
        case .spell: drawSpell(ctx, old: old, new: new, k: k, in: r)
        case .boredNow: drawBoredNow(ctx, old: old, new: new, k: k, in: r)
        case .hellmouth: drawHellmouth(ctx, old: old, new: new, k: k, in: r)
        case .hush: drawHush(ctx, old: old, new: new, k: k, in: r)
        case .musical: drawMusical(ctx, old: old, new: new, k: k, in: r)
        case .sunrise: drawSunrise(ctx, old: old, new: new, k: k, in: r)
        case .key: drawKey(ctx, old: old, new: new, k: k, in: r)
        case .coatSwish: drawCoatSwish(ctx, old: old, new: new, k: k, in: r)
        case .lift: drawLift(ctx, old: old, new: new, k: k, in: r)
        case .restless: drawRestless(ctx, old: old, new: new, k: k, in: r)
        }
    }

    // MARK: Shared helpers, for every trip file

    static func ease(_ k: Double) -> Double { k * k * (3 - 2 * k) }
    static func clamp(_ k: Double) -> Double { min(1, max(0, k)) }
    /// How far `k` is through `a…b`: 0 before, 1 after.
    static func span(_ k: Double, _ a: Double, _ b: Double) -> Double { clamp((k - a) / (b - a)) }

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

    /// A plain crossfade, for a trip not drawn yet.
    static func crossfade(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        ctx.draw(old, in: r)
        ctx.setAlpha(CGFloat(ease(k)))
        ctx.draw(new, in: r)
        ctx.setAlpha(1)
    }
}
