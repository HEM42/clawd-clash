import AppKit

/// Marvel's trips between places, in place of Star Wars' wipes: five comic-book transitions, a different one each time.
/// Shared by the window and the screen saver, which hand over the old picture (frozen), the new one (as it is right
/// now) and how far through it is; a frame is drawn over the whole of `r`. Sizes are against an 800-pixel-tall frame.
enum ComicWipe: Int, CaseIterable {
    case halftone       // the new place prints in as halftone dots, sweeping left to right
    case burst          // a starburst with a sound effect covers the screen and bursts away on the new place
    case panels         // the new place drops in as three comic panels
    case speedLines     // action lines rush in, a white flash, and the new place zooms out of it
    case meanwhile      // an iris closes, "MEANWHILE, IN …", and opens on the new place

    var duration: Double {
        switch self {
        case .halftone: return 1.4
        case .burst: return 1.6
        case .panels: return 1.5
        case .speedLines: return 1.3
        case .meanwhile: return 2.4
        }
    }

    /// Any but the last one.
    static func next(after last: ComicWipe?) -> ComicWipe {
        allCases.filter { $0 != last }.randomElement() ?? .halftone
    }

    /// What the starburst says: a sound effect of someone on screen (Wolverine's SNIKT!, Nightcrawler's BAMF!…), one
    /// of Deadpool's own when he's about, or KAPOW!.
    static func word(for cast: [Cast]) -> String {
        let heroes = Set(cast.filter { $0.universe == .marvel && !$0.isDark }.compactMap { MarvelHero(rawValue: $0.index) })
        if heroes.contains(.deadpool), Bool.random() { return deadpoolWords.randomElement()! }
        let words = heroes.flatMap { soundEffects[$0] ?? [] }
        return words.randomElement() ?? "KAPOW!"
    }

    /// The caption box: "MEANWHILE, IN WAKANDA…", or, with Deadpool about, sometimes his version of it.
    static func caption(to place: Location, cast: [Cast]) -> String {
        let deadpool = Cast.hero(.deadpool)
        if cast.contains(where: { $0.universe == deadpool.universe && $0.isDark == deadpool.isDark && $0.index == deadpool.index }),
           Bool.random() {
            return deadpoolCaptions.randomElement()!(place.name.uppercased())
        }
        return "MEANWHILE, IN \(place.name.uppercased())…"
    }

    private static let soundEffects: [MarvelHero: [String]] = [
        .wolverine: ["SNIKT!"], .x23: ["SNIKT!"],
        .nightcrawler: ["BAMF!"],
        .thor: ["KRAKATOOM!", "THOOM!"],
        .spiderMan: ["THWIP!"], .milesMorales: ["THWIP!"], .spiderGwen: ["THWIP!"],
        .hulk: ["BAROOM!"], .thing: ["BAROOM!"],
    ]

    private static let deadpoolWords = [
        "CHIMICHANGA!", "MAXIMUM EFFORT!", "HI, MOM!", "BUDGET CUTS!", "SKIP INTRO!", "FOURTH WALL: BROKEN!",
        "SCENE CHANGE!", "PEW PEW!",
    ]

    private static let deadpoolCaptions: [(String) -> String] = [
        { _ in "MEANWHILE, ON A SMALLER BUDGET…" },
        { "MEANWHILE, IN \($0) (THE WRITERS GOT BORED)…" },
        { _ in "MEANWHILE, AT THE CHIMICHANGA STAND…" },
        { "MEANWHILE, IN \($0). YES, AGAIN." },
    ]

    // MARK: Drawing

    private static let ink = CGColor(red: 0.07, green: 0.06, blue: 0.08, alpha: 1)
    private static let yellow = CGColor(red: 1, green: 0.86, blue: 0.16, alpha: 1)
    private static let red = CGColor(red: 0.86, green: 0.12, blue: 0.14, alpha: 1)

    private static func ease(_ k: Double) -> Double { k * k * (3 - 2 * k) }
    private static func clamp(_ k: Double) -> Double { min(1, max(0, k)) }

    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`. `word` is the starburst's, `caption`
    /// the caption box's.
    func draw(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect, word: String, caption: String) {
        let s = r.height / 800, c = CGPoint(x: r.midX, y: r.midY)
        let ease = Self.ease, clamp = Self.clamp
        ctx.saveGState(); defer { ctx.restoreGState() }
        ctx.interpolationQuality = .none
        switch self {
        case .halftone:
            ctx.draw(old, in: r)
            let cell = 26 * s
            let path = CGMutablePath()
            let cols = Int(r.width / cell) + 2, rows = Int(r.height / cell) + 2
            for row in 0..<rows {
                for col in 0..<cols {
                    let x = r.minX + CGFloat(col) * cell + (row % 2 == 0 ? 0 : cell / 2), y = r.minY + CGFloat(row) * cell
                    // Dots start on the left and sweep right, each growing from nothing to covering its cell.
                    let local = clamp(k * 1.6 - Double((x - r.minX) / r.width) * 0.6)
                    let d = cell * 0.75 * CGFloat(ease(local))
                    if d > 0.5 { path.addEllipse(in: CGRect(x: x - d, y: y - d, width: d * 2, height: d * 2)) }
                }
            }
            // Clipping to an empty path clips nothing, which flashed the whole new place up on the first frame.
            guard !path.isEmpty else { return }
            ctx.addPath(path); ctx.clip()
            ctx.draw(new, in: r)

        case .burst:
            ctx.draw(k < 0.5 ? old : new, in: r)
            let grow = k < 0.5 ? ease(k / 0.5) : 1 - ease((k - 0.5) / 0.5)
            let rad = CGFloat(grow) * hypot(r.width, r.height) * 0.62
            guard rad > 2 else { return }
            ctx.addPath(Self.starburst(c, r: rad * 1.04, seed: 3)); ctx.setFillColor(Self.ink); ctx.fillPath()
            ctx.addPath(Self.starburst(c, r: rad, seed: 3)); ctx.setFillColor(Self.yellow); ctx.fillPath()
            ctx.addPath(Self.starburst(c, r: rad * 0.7, seed: 5)); ctx.setFillColor(Self.red); ctx.fillPath()
            Self.letters(ctx, word, at: c, size: (40 + 150 * CGFloat(grow)) * s, maxWidth: r.width * 0.9, angle: -0.12)

        case .panels:
            ctx.draw(old, in: r)
            let gutter = 14 * s, w = r.width / 3
            for i in 0..<3 {
                let local = clamp((k - Double(i) * 0.18) / 0.46)
                guard local > 0 else { continue }
                let drop = CGFloat(1 - ease(local)) * r.height * 1.1 * (i % 2 == 0 ? 1 : -1)
                let tilt = CGFloat(1 - ease(local)) * (i == 1 ? -0.08 : 0.06)
                ctx.saveGState()
                ctx.translateBy(x: r.minX + w * CGFloat(i) + w / 2, y: r.midY + drop)
                ctx.rotate(by: tilt)
                let panel = CGRect(x: -w / 2, y: -r.height / 2, width: w, height: r.height)
                ctx.setFillColor(Self.ink); ctx.fill(panel)
                ctx.clip(to: panel.insetBy(dx: gutter / 2, dy: gutter / 2))
                ctx.draw(new, in: CGRect(x: -w / 2 - w * CGFloat(i), y: -r.height / 2, width: r.width, height: r.height))
                ctx.restoreGState()
            }
            // Once all three are down, the gutters close up.
            if k > 0.86 { ctx.setAlpha(CGFloat((k - 0.86) / 0.14)); ctx.draw(new, in: r); ctx.setAlpha(1) }

        case .speedLines:
            let zoom: CGFloat = k < 0.5 ? 1 + CGFloat(ease(k / 0.5)) * 0.35 : 1.35 - CGFloat(ease((k - 0.5) / 0.5)) * 0.35
            ctx.saveGState()
            ctx.clip(to: r)
            ctx.translateBy(x: c.x, y: c.y); ctx.scaleBy(x: zoom, y: zoom); ctx.translateBy(x: -c.x, y: -c.y)
            ctx.draw(k < 0.5 ? old : new, in: r)
            ctx.restoreGState()
            let strength = k < 0.5 ? ease(k / 0.5) : 1 - ease((k - 0.5) / 0.5)
            let far = hypot(r.width, r.height), inner = far * 0.53 * CGFloat(1 - strength)
            for i in 0..<90 {
                let a = CGFloat(noise(i * 3)) * 2 * .pi, wdt = 0.012 + 0.02 * CGFloat(noise(i * 3 + 1))
                let p = CGMutablePath()
                p.move(to: CGPoint(x: c.x + cos(a) * far, y: c.y + sin(a) * far))
                p.addLine(to: CGPoint(x: c.x + cos(a - wdt) * inner, y: c.y + sin(a - wdt) * inner))
                p.addLine(to: CGPoint(x: c.x + cos(a + wdt) * far, y: c.y + sin(a + wdt) * far))
                p.closeSubpath()
                ctx.addPath(p)
            }
            ctx.setFillColor(CGColor(gray: 0.05, alpha: 0.85)); ctx.fillPath()
            if strength > 0.85 { ctx.setFillColor(CGColor(gray: 1, alpha: CGFloat((strength - 0.85) / 0.15))); ctx.fill(r) }

        case .meanwhile:
            let maxR = hypot(r.width, r.height) / 2 + 10
            ctx.setFillColor(Self.ink); ctx.fill(r)
            let closing = k < 0.32, opening = k > 0.68
            let rad: CGFloat = closing ? maxR * CGFloat(1 - ease(k / 0.32)) : opening ? maxR * CGFloat(ease((k - 0.68) / 0.32)) : 0
            if rad > 1 {
                let iris = CGRect(x: c.x - rad, y: c.y - rad, width: rad * 2, height: rad * 2)
                ctx.saveGState()
                ctx.addEllipse(in: iris); ctx.clip()
                ctx.draw(closing ? old : new, in: r)
                ctx.restoreGState()
                ctx.addEllipse(in: iris)
                ctx.setStrokeColor(Self.ink); ctx.setLineWidth(10 * s); ctx.strokePath()
            }
            if k > 0.22 && k < 0.82 {
                var size = 38 * s
                func font() -> NSFont { NSFont(name: "AvenirNext-HeavyItalic", size: size) ?? .boldSystemFont(ofSize: size) }
                // Long captions (or a short window) get smaller type, so the box always fits.
                let room = r.width * 0.9 - 48 * s
                let width = NSAttributedString(string: caption, attributes: [.font: font()]).size().width
                if width > room { size *= room / width }
                let whole = NSAttributedString(string: caption, attributes: [.font: font()]).size()
                let shown = String(caption.prefix(Int(Double(caption.count) * clamp((k - 0.26) / 0.3))))
                let text = NSAttributedString(string: shown, attributes: [.font: font(), .foregroundColor: NSColor.black])
                let pad = 24 * s
                let box = CGRect(x: c.x - whole.width / 2 - pad, y: c.y - whole.height / 2 - pad / 2,
                                 width: whole.width + pad * 2, height: whole.height + pad)
                ctx.setFillColor(Self.yellow); ctx.fill(box)
                ctx.setStrokeColor(Self.ink); ctx.setLineWidth(5 * s); ctx.stroke(box)
                NSGraphicsContext.saveGraphicsState()
                NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
                text.draw(at: NSPoint(x: box.minX + pad, y: box.minY + pad / 2))
                NSGraphicsContext.restoreGraphicsState()
            }
        }
    }

    /// Comic lettering, centred at `c`, tilted by `angle` radians, with a thick black outline; never wider than `maxWidth`.
    private static func letters(_ ctx: CGContext, _ text: String, at c: CGPoint, size: CGFloat, maxWidth: CGFloat, angle: CGFloat) {
        func strings(_ size: CGFloat) -> (NSAttributedString, NSAttributedString) {
            let font = NSFont(name: "Futura-CondensedExtraBold", size: size) ?? .systemFont(ofSize: size, weight: .black)
            return (NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: NSColor.black,
                                                                  .strokeColor: NSColor.black, .strokeWidth: 12]),
                    NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: NSColor.white]))
        }
        var (outline, face) = strings(size)
        if face.size().width > maxWidth { (outline, face) = strings(size * maxWidth / face.size().width) }
        let sz = face.size()
        ctx.saveGState()
        ctx.translateBy(x: c.x, y: c.y); ctx.rotate(by: angle)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
        outline.draw(at: NSPoint(x: -sz.width / 2, y: -sz.height / 2))
        face.draw(at: NSPoint(x: -sz.width / 2, y: -sz.height / 2))
        NSGraphicsContext.restoreGraphicsState()
        ctx.restoreGState()
    }

    /// A jagged comic starburst round `c`, radius `r`, with `n` points.
    private static func starburst(_ c: CGPoint, r: CGFloat, n: Int = 18, seed: Int = 0) -> CGPath {
        let p = CGMutablePath()
        for i in 0..<(n * 2) {
            let a = CGFloat(i) / CGFloat(n * 2) * 2 * .pi + 0.1
            let k = i % 2 == 0 ? 1 : 0.62 + 0.12 * CGFloat(noise(i + seed * 31))
            let rr = r * k * (0.9 + 0.2 * CGFloat(noise(i * 7 + seed)))
            let pt = CGPoint(x: c.x + cos(a) * rr, y: c.y + sin(a) * rr)
            i == 0 ? p.move(to: pt) : p.addLine(to: pt)
        }
        p.closeSubpath()
        return p
    }
}
