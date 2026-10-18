import CoreGraphics
import Foundation

// The Watcher's Tome (`SlayerWipe.tome`): a heavy book thuds down, its pages flip, and the new place is a woodcut
// plate in it that fills with colour and grows to the screen.

extension SlayerTrip {
    /// The old place dims to candlelight and a dusty, leather-bound Watcher's tome drops onto it, brass corners and a
    /// faded gilt emblem on its cover (0–0.14); it lands with a thud, the picture shakes and dust puffs out from under
    /// it (0.14–0.26); the cover swings open over the spine (0.2–0.34) and four pages riffle over (0.34–0.52),
    /// uncovering a plate on the right-hand page: the new place cut as a black-and-white woodcut, hatched in ink
    /// (0.52); colour washes into it from the middle, raggedly, like paint soaking into paper (0.56–0.74); then the
    /// plate grows out of the book to fill the frame while its ink lines fade, leaving the new place (0.68–1). The
    /// places are drawn as they are; the tome, the dust and the woodcut are pixel art about 180 pixels tall, scaled
    /// up without smoothing, with a little grain over it all.
    func drawTome(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.draw(old, in: r); return }
        guard k < 1 else { ctx.draw(new, in: r); return }
        let px: CGFloat = max(1, (r.height / 180).rounded())    // screen pixels per pixel of the tome's art
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = Self.artCanvas(width: w, height: h, px: px, in: r) else { return }
        let book = TomeLayout(r, px: px)
        let u = book.u

        // The beats.
        let fall = Self.span(k, 0, 0.14)
        let landed = k >= 0.14
        let thud = landed ? 1 - Self.span(k, 0.14, 0.26) : 0                  // the shake and squash, dying away
        let cover = Self.ease(Self.span(k, 0.2, 0.34))                          // 0 shut … 1 lying open on the left
        let grow = Self.ease(Self.span(k, 0.68, 1))
        let dim = 0.62 * Self.ease(Self.span(k, 0, 0.18))

        // The old place, shaken by the thud, dimmed to candlelight.
        let shake = book.snap(CGFloat(noise(Int(k * 240)) - 0.5) * 2 * u * 5 * CGFloat(thud * thud))
        let jolt = book.snap(CGFloat(noise(Int(k * 240) + 7) - 0.5) * 2 * u * 3 * CGFloat(thud * thud))
        ctx.setFillColor(rgb(0x05060C)); ctx.fill(r)
        ctx.draw(old, in: r.offsetBy(dx: shake, dy: jolt).insetBy(dx: -abs(shake), dy: -abs(jolt)))
        art.setFillColor(rgb(0x05060C, CGFloat(dim))); art.fill(r)
        // Shut, the tome lies in the middle; as its cover opens it slides left until its spine is in the middle.
        art.saveGState()
        art.translateBy(x: book.snap(-book.pageW / 2 * CGFloat(1 - cover)), y: 0)
        // A pool of candlelight on the table where the tome lies.
        Self.tomePool(art, centre: CGPoint(x: book.spine, y: book.midY), radius: book.pageW * 2.1,
                      alpha: CGFloat(Self.ease(Self.span(k, 0.04, 0.2))), px: px)

        if !landed {
            // Falling: from above the frame, a little bigger (nearer), its shadow gathering under where it lands.
            let f = CGFloat(fall * fall)
            let drop = (1 - f) * (r.maxY - book.coverRect.minY + u * 10)
            let scale = 1 + 0.25 * (1 - f)
            Self.tomeShadow(art, book.coverRect, u: u, alpha: 0.6 * f, spread: 1 + 0.15 * (1 - f))
            art.saveGState()
            art.translateBy(x: book.coverRect.midX, y: book.coverRect.midY + drop)
            art.scaleBy(x: scale, y: scale)
            art.translateBy(x: -book.coverRect.midX, y: -book.coverRect.midY)
            book.drawClosed(art)
            art.restoreGState()
        } else if cover <= 0 {
            // Landed, shut, squashed a moment by the thud.
            Self.tomeShadow(art, book.coverRect, u: u, alpha: 0.6, spread: 1)
            let squash = 1 - 0.06 * CGFloat(sin(Self.span(k, 0.14, 0.22) * .pi))
            art.saveGState()
            art.translateBy(x: 0, y: book.coverRect.minY); art.scaleBy(x: 1, y: squash); art.translateBy(x: 0, y: -book.coverRect.minY)
            book.drawClosed(art)
            art.restoreGState()
        } else {
            // Open: the boards, the page blocks, the two pages lying flat and whatever is turning over them.
            Self.tomeShadow(art, cover >= 1 ? book.openRect : book.coverRect, u: u, alpha: 0.6, spread: 1)
            book.drawBoards(art, leftOpen: cover >= 1)
            let flips = 4
            let starts = (0..<flips).map { 0.34 + Double($0) * 0.035 }
            let dur = 0.075
            let landedPages = starts.filter { k >= $0 + dur / 2 }.count
            // The left page: the inside of the cover until the first page lands on it, then the last page to land.
            if cover >= 1 {
                if landedPages == 0 { book.drawEndpaper(art, book.left) }
                else { book.drawText(art, book.left, seed: 20 + landedPages, diagram: landedPages == flips) }
            }
            // The right page: text until the last page starts to turn, then the plate.
            let plateShown = k >= starts[flips - 1]
            if plateShown { book.drawPlatePage(art) } else { book.drawText(art, book.right, seed: 3, diagram: false) }
            book.drawGutter(art)
            // The cover, swinging over the spine.
            if cover < 1 { book.drawSwing(art, angle: Double.pi * cover, cover: true, seed: 0) }
            // The pages, riffling over.
            for (i, start) in starts.enumerated() where k > start && k < start + dur {
                let t = Self.ease(Self.span(k, start, start + dur))
                book.drawSwing(art, angle: Double.pi * t, cover: false, seed: 10 + i)
            }
        }

        // Dust: a cloud puffing out from under the tome as it lands and a smaller one as the cover slaps open; motes
        // drifting in the candlelight all the way through.
        Self.tomeDust(art, book: book, k: k, px: px)
        art.restoreGState()
        Self.blit(art, onto: ctx, width: w, height: h, px: px, in: r)

        // The plate: the new place as a woodcut on the right-hand page, colour soaking into it, then growing to fill
        // the frame.
        if k >= 0.34 + 3 * 0.035 {
            // It lifts off the page and comes forward: its middle swings to the frame's middle in the first part of
            // the growth, so it grows from the centre rather than sitting off to the right.
            let size = Self.tomeLerp(book.plate, r, grow), centre = CGFloat(Self.ease(min(1, grow * 2.2)))
            let plate = book.grid(CGRect(x: book.plate.midX + (r.midX - book.plate.midX) * centre - size.width / 2,
                                         y: book.plate.midY + (r.midY - book.plate.midY) * centre - size.height / 2,
                                         width: size.width, height: size.height))
            drawTomePlate(ctx, new: new, plate: plate, start: book.plate, k: k, grow: grow, book: book, in: r)
        }
        Self.tomeGrain(ctx, k: k, strength: CGFloat(1 - Self.span(k, 0.82, 1)), px: px, in: r)
    }

    /// The plate at `plate` (its first place on the page is `start`): paper, the new place washing in from the middle
    /// in ragged rows, the woodcut's ink over it, and a ruled border, the ink and the border fading as it grows.
    private func drawTomePlate(_ ctx: CGContext, new: CGImage, plate: CGRect, start: CGRect, k: Double, grow: Double,
                               book: TomeLayout, in r: CGRect) {
        guard plate.width > 1, plate.height > 1 else { return }
        let px = book.px
        // Where the whole new place lies so that it covers the plate (its middle in the plate's middle).
        let ar = r.width / r.height
        let frame: CGRect = plate.width / plate.height <= ar
            ? CGRect(x: plate.midX - plate.height * ar / 2, y: plate.minY, width: plate.height * ar, height: plate.height)
            : CGRect(x: plate.minX, y: plate.midY - plate.width / ar / 2, width: plate.width, height: plate.width / ar)
        // The part of it the woodcut was cut from (the plate's shape on the page).
        let pa = start.width / start.height
        let cutW = min(1, pa / ar), cutH = min(1, ar / pa)
        let cut = CGRect(x: frame.midX - frame.width * cutW / 2, y: frame.midY - frame.height * cutH / 2,
                         width: frame.width * cutW, height: frame.height * cutH)

        ctx.saveGState(); defer { ctx.restoreGState() }
        ctx.clip(to: plate)
        ctx.interpolationQuality = .none
        ctx.setFillColor(rgb(0xE8D8AE)); ctx.fill(plate)

        // The colour, soaking in from the middle: a pale wash a little ahead, then the full colour.
        let soak = Self.ease(Self.span(k, 0.56, 0.76))
        if soak > 0 {
            for (reach, alpha) in [(soak * 1.25, 0.45), (soak * 1.1, 1.0)] {
                let rows = Self.tomeSoak(plate, reach: CGFloat(reach), px: px)
                guard !rows.isEmpty else { continue }
                ctx.saveGState()
                ctx.clip(to: rows)
                ctx.setAlpha(CGFloat(alpha))
                ctx.draw(new, in: frame)
                ctx.restoreGState()
            }
        }

        // The woodcut's ink, cut once at the plate's size on the page and scaled up with it.
        let ink = CGFloat(1 - Self.ease(Self.span(k, 0.72, 0.96)))
        let printed = CGFloat(Self.span(k, 0.5, 0.56))
        if ink * printed > 0 {
            let tw = max(8, Int((start.width / px).rounded())), th = max(8, Int((start.height / px).rounded()))
            let iw = CGFloat(new.width), ih = CGFloat(new.height)
            let crop = CGRect(x: iw * (1 - cutW) / 2, y: ih * (1 - cutH) / 2, width: iw * cutW, height: ih * cutH)
            if let wood = Self.tomeWoodcut(new, crop: crop, width: tw, height: th) {
                ctx.setAlpha(ink * printed)
                ctx.draw(wood, in: cut)
                ctx.setAlpha(1)
            }
        }

        // The ruled border, a heavy line and a fine one inside it, fading as the plate grows.
        let rule = CGFloat(1 - grow) * printed
        if rule > 0 {
            ctx.setFillColor(rgb(0x1E140C, rule))
            let t = px * 2, gap = px * 2
            ctx.fill([CGRect(x: plate.minX, y: plate.minY, width: plate.width, height: t),
                      CGRect(x: plate.minX, y: plate.maxY - t, width: plate.width, height: t),
                      CGRect(x: plate.minX, y: plate.minY, width: t, height: plate.height),
                      CGRect(x: plate.maxX - t, y: plate.minY, width: t, height: plate.height)])
            let i = plate.insetBy(dx: t + gap, dy: t + gap)
            if i.width > 0, i.height > 0 {
                ctx.fill([CGRect(x: i.minX, y: i.minY, width: i.width, height: px), CGRect(x: i.minX, y: i.maxY - px, width: i.width, height: px),
                          CGRect(x: i.minX, y: i.minY, width: px, height: i.height), CGRect(x: i.maxX - px, y: i.minY, width: px, height: i.height)])
            }
        }
    }

    /// `a` moved and stretched `t` (0…1) of the way to `b`.
    private static func tomeLerp(_ a: CGRect, _ b: CGRect, _ t: Double) -> CGRect {
        let f = CGFloat(t)
        return CGRect(x: a.minX + (b.minX - a.minX) * f, y: a.minY + (b.minY - a.minY) * f,
                      width: a.width + (b.width - a.width) * f, height: a.height + (b.height - a.height) * f)
    }

    // MARK: The woodcut

    /// `image`'s `crop` (in its pixels, top-left origin) as a woodcut `width`×`height`: ink (and nothing else) where
    /// it's dark, hatched in diagonal lines, cross-hatched and then solid as it darkens, and along its sharper edges.
    private static func tomeWoodcut(_ image: CGImage, crop: CGRect, width tw: Int, height th: Int) -> CGImage? {
        guard let piece = image.cropping(to: crop.integral),
              let gray = CGContext(data: nil, width: tw, height: th, bitsPerComponent: 8, bytesPerRow: tw,
                                   space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue),
              let out = CGContext(data: nil, width: tw, height: th, bitsPerComponent: 8, bytesPerRow: tw * 4,
                                  space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let src = gray.data, let dst = out.data else { return nil }
        gray.interpolationQuality = .medium
        gray.draw(piece, in: CGRect(x: 0, y: 0, width: tw, height: th))
        let lum = src.bindMemory(to: UInt8.self, capacity: tw * th)
        let pix = dst.bindMemory(to: UInt8.self, capacity: tw * th * 4)
        // The night is dark: stretch its tones between the darkest and brightest few per cent.
        var hist = [Int](repeating: 0, count: 256)
        for i in 0..<(tw * th) { hist[Int(lum[i])] += 1 }
        func percentile(_ p: Double) -> Int {
            var sum = 0, goal = Int(Double(tw * th) * p)
            goal = max(0, goal)
            for v in 0..<256 { sum += hist[v]; if sum > goal { return v } }
            return 255
        }
        let lo = Double(percentile(0.04)), hi = max(lo + 24, Double(percentile(0.97)))
        for y in 0..<th {
            for x in 0..<tw {
                let i = y * tw + x
                let v = Double(lum[i])
                let tone = pow(min(1, max(0, (v - lo) / (hi - lo))), 0.7)
                let right = Double(lum[y * tw + min(tw - 1, x + 1)]), below = Double(lum[min(th - 1, y + 1) * tw + x])
                let edge = (abs(v - right) + abs(v - below)) / (hi - lo)
                let d1 = (x + y) % 4 == 0, d2 = (x - y + 4096) % 4 == 0, fine = (x + y) % 2 == 0
                let inked: Bool
                if edge > 0.5 { inked = true }
                else if tone < 0.08 { inked = true }
                else if tone < 0.2 { inked = fine || d2 }
                else if tone < 0.38 { inked = d1 || d2 }
                else if tone < 0.6 { inked = d1 }
                else { inked = false }
                pix[i * 4] = inked ? 0x1E : 0; pix[i * 4 + 1] = inked ? 0x14 : 0
                pix[i * 4 + 2] = inked ? 0x0C : 0; pix[i * 4 + 3] = inked ? 255 : 0
            }
        }
        return out.makeImage()
    }

    /// The rows of the art's grid soaked by colour spreading from the middle of `plate`, `reach` (0…~1.3) of the way
    /// to its corners, each row's ends ragged.
    private static func tomeSoak(_ plate: CGRect, reach: CGFloat, px: CGFloat) -> [CGRect] {
        guard reach > 0 else { return [] }
        let a = plate.width / 2 * 1.42 * reach, b = plate.height / 2 * 1.42 * reach
        var rows: [CGRect] = []
        var y = plate.minY
        var j = 0
        while y < plate.maxY {
            let d = (y + px / 2 - plate.midY) / b
            if abs(d) < 1 {
                let rag = 0.82 + 0.3 * CGFloat(noise(j * 7 + 3)) + 0.08 * CGFloat(noise(j / 3 * 5 + 1))
                let half = a * (1 - d * d).squareRoot() * rag
                let x0 = max(plate.minX, ((plate.midX - half - plate.minX) / px).rounded() * px + plate.minX)
                let x1 = min(plate.maxX, ((plate.midX + half - plate.minX) / px).rounded() * px + plate.minX)
                if x1 > x0 { rows.append(CGRect(x: x0, y: y, width: x1 - x0, height: px)) }
            }
            y += px; j += 1
        }
        return rows
    }

    // MARK: Light, shadow, dust and grain

    /// A warm pool of candlelight in stepped rings.
    private static func tomePool(_ c: CGContext, centre: CGPoint, radius: CGFloat, alpha: CGFloat, px: CGFloat) {
        guard alpha > 0 else { return }
        for i in 0..<5 {
            let rr = radius * CGFloat(5 - i) / 5
            c.setFillColor(rgb(0xFFB060, 0.045 * alpha))
            c.fillEllipse(in: CGRect(x: centre.x - rr, y: centre.y - rr * 0.6, width: rr * 2, height: rr * 1.2))
        }
    }

    /// The tome's shadow on the table, down and to the right.
    private static func tomeShadow(_ c: CGContext, _ rect: CGRect, u: CGFloat, alpha: CGFloat, spread: CGFloat) {
        let s = rect.insetBy(dx: -u * 4 * (spread - 1) * 10, dy: -u * 2 * (spread - 1) * 10).offsetBy(dx: u * 6, dy: -u * 6)
        c.setFillColor(rgb(0x000000, alpha * 0.5)); c.fill(s.insetBy(dx: -u * 3, dy: -u * 3))
        c.setFillColor(rgb(0x000000, alpha)); c.fill(s)
    }

    /// The dust: puffs from under the tome when it lands (0.14) and when the cover slaps down (0.34), and motes.
    private static func tomeDust(_ c: CGContext, book: TomeLayout, k: Double, px: CGFloat) {
        let u = book.u
        func dot(_ x: CGFloat, _ y: CGFloat, _ hex: UInt32, _ a: CGFloat, _ size: CGFloat) {
            guard a > 0.02 else { return }
            c.setFillColor(rgb(hex, a)); c.fill(CGRect(x: book.snap(x), y: book.snap(y), width: px * size, height: px * size))
        }
        // The thud: dust rolling out along the table both ways from the tome's foot, rising and thinning.
        let base = book.landed
        for (start, from, count, spread) in [(0.14, base, 46, CGFloat(1)), (0.33, book.leftFoot, 22, CGFloat(0.6))] {
            let t = span(k, start, start + 0.2)
            guard t > 0, t < 1 else { continue }
            let fade = CGFloat(1 - t)
            for i in 0..<count {
                let side: CGFloat = i % 2 == 0 ? -1 : 1
                let along = CGFloat(noise(i * 13 + 1))
                let x0 = from.minX + from.width * along
                let out = CGFloat(1 - pow(1 - t, 2)) * u * CGFloat(30 + 70 * noise(i * 13 + 2)) * spread
                let up = CGFloat(t) * u * CGFloat(6 + 30 * noise(i * 13 + 3)) * spread
                let edge = along < 0.5 ? from.minX : from.maxX
                let x = (abs(x0 - edge) < from.width * 0.25 ? edge : x0) + side * out
                let size: CGFloat = noise(i * 13 + 4) < 0.35 ? 2 : 1
                dot(x, from.minY + up, i % 3 == 0 ? 0xD8CCB0 : 0xA89A80, fade * 0.8, size + (t > 0.5 ? 1 : 0))
            }
        }
        // Motes hanging in the candlelight, drifting up slowly, catching the light now and then.
        let shown = CGFloat(span(k, 0.12, 0.3) * (1 - span(k, 0.7, 0.92)))
        guard shown > 0 else { return }
        for i in 0..<40 {
            let x = book.spine + (CGFloat(noise(i * 9 + 1)) - 0.5) * book.pageW * 4 + CGFloat(sin(k * 6 + Double(i))) * u * 4
            let y = book.midY + (CGFloat(noise(i * 9 + 2)) - 0.5) * book.pageH * 1.3 + CGFloat(k) * u * 30 * CGFloat(noise(i * 9 + 3))
            let glint = noise(i * 9 + Int(k * 30)) > 0.85
            dot(x, y, glint ? 0xFFF0C8 : 0xC8B898, shown * (glint ? 0.9 : 0.45), 1)
        }
    }

    /// Film grain: scattered pixels of the art, a little lighter or darker, different every frame.
    private static func tomeGrain(_ ctx: CGContext, k: Double, strength: CGFloat, px: CGFloat, in r: CGRect) {
        guard strength > 0 else { return }
        let w = Int(r.width / px), h = Int(r.height / px)
        let n = w * h / 70, frame = Int(k * 30) * 7919
        var light: [CGRect] = [], dark: [CGRect] = []
        light.reserveCapacity(n / 2); dark.reserveCapacity(n / 2)
        for i in 0..<n {
            let x = Int(noise(i * 3 + frame) * Double(w)), y = Int(noise(i * 3 + 1 + frame) * Double(h))
            let rect = CGRect(x: r.minX + CGFloat(x) * px, y: r.minY + CGFloat(y) * px, width: px, height: px)
            if i % 2 == 0 { light.append(rect) } else { dark.append(rect) }
        }
        ctx.setFillColor(rgb(0xFFF4E0, 0.07 * strength)); ctx.fill(light)
        ctx.setFillColor(rgb(0x000000, 0.12 * strength)); ctx.fill(dark)
    }
}

// MARK: - The tome

/// Where everything is in the Watcher's tome, in `r`'s units, and how to draw it into the art. The book sits a little
/// below the middle of the frame, as tall as most of it; its pages are as wide as fits either aspect.
private struct TomeLayout {
    let r: CGRect, px: CGFloat, u: CGFloat
    let pageW: CGFloat, pageH: CGFloat, spine: CGFloat, midY: CGFloat, board: CGFloat, block: CGFloat

    init(_ r: CGRect, px: CGFloat) {
        self.r = r; self.px = px
        u = r.height / 200
        // As tall as it can be in a short window strip, where the height is all there is to go on.
        pageH = (r.height * (r.width / r.height > 2.4 ? 0.82 : 0.74) / px).rounded() * px
        pageW = (min(pageH * 0.8, r.width * 0.34) / px).rounded() * px
        spine = ((r.midX - r.minX) / px).rounded() * px + r.minX
        midY = ((r.midY - r.height * 0.02 - r.minY) / px).rounded() * px + r.minY
        board = max(px * 2, (u * 4 / px).rounded() * px)       // how far the boards stand out past the pages
        block = max(px * 2, (u * 5 / px).rounded() * px)       // the thickness of the page blocks, seen at the foot
    }

    func snap(_ v: CGFloat) -> CGFloat { (v / px).rounded() * px }
    func grid(_ rect: CGRect) -> CGRect {
        let x0 = ((rect.minX - r.minX) / px).rounded() * px + r.minX, y0 = ((rect.minY - r.minY) / px).rounded() * px + r.minY
        let x1 = ((rect.maxX - r.minX) / px).rounded() * px + r.minX, y1 = ((rect.maxY - r.minY) / px).rounded() * px + r.minY
        return CGRect(x: x0, y: y0, width: x1 - x0, height: y1 - y0)
    }

    var right: CGRect { CGRect(x: spine, y: midY - pageH / 2, width: pageW, height: pageH) }
    var left: CGRect { CGRect(x: spine - pageW, y: midY - pageH / 2, width: pageW, height: pageH) }
    var coverRect: CGRect { CGRect(x: spine - board, y: midY - pageH / 2 - board - block, width: pageW + board * 2,
                                   height: pageH + board * 2 + block) }
    var openRect: CGRect { CGRect(x: spine - pageW - board, y: midY - pageH / 2 - board - block, width: pageW * 2 + board * 2,
                                  height: pageH + board * 2 + block) }
    /// Where the dust rolls out when it lands, and when the cover slaps down on the left.
    var landed: CGRect { CGRect(x: coverRect.minX, y: coverRect.minY, width: coverRect.width, height: px) }
    var leftFoot: CGRect { CGRect(x: openRect.minX, y: openRect.minY, width: pageW, height: px) }

    /// The plate on the right-hand page, its first place: a landscape picture in the upper part of the page.
    var plate: CGRect {
        let pw = pageW * 0.88
        let ph = min(pw / 1.25, pageH * 0.64)
        return grid(CGRect(x: right.midX - pw / 2, y: right.maxY - pageH * 0.1 - ph, width: pw, height: ph))
    }

    // Leather, brass, gilt and parchment.
    static let leather: UInt32 = 0x4A2218, leatherDark: UInt32 = 0x2E140E, leatherLight: UInt32 = 0x6A3624
    static let gilt: UInt32 = 0xB08A3A, giltLight: UInt32 = 0xE0C070, brass: UInt32 = 0x9A7C40, brassLight: UInt32 = 0xD8C080
    static let paper: UInt32 = 0xE2CFA0, paperDark: UInt32 = 0xC4A878, ink: UInt32 = 0x3A2A1A

    private func box(_ c: CGContext, _ rect: CGRect, _ hex: UInt32, _ a: CGFloat = 1) {
        c.setFillColor(rgb(hex, a)); c.fill(rect)
    }
    private func frame(_ c: CGContext, _ rect: CGRect, _ t: CGFloat, _ hex: UInt32, _ a: CGFloat = 1) {
        c.setFillColor(rgb(hex, a))
        c.fill([CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: t), CGRect(x: rect.minX, y: rect.maxY - t, width: rect.width, height: t),
                CGRect(x: rect.minX, y: rect.minY, width: t, height: rect.height), CGRect(x: rect.maxX - t, y: rect.minY, width: t, height: rect.height)])
    }

    /// The shut tome seen from above: the front cover, the page block at its foot and the back board under it.
    func drawClosed(_ c: CGContext) {
        let cr = coverRect
        box(c, cr, TomeLayout.leatherDark)                                   // the back board
        let pages = CGRect(x: cr.minX + px, y: cr.minY + px, width: cr.width - board - px, height: block)
        box(c, pages, TomeLayout.paperDark)
        var y = pages.minY + px
        while y < pages.maxY - px { box(c, CGRect(x: pages.minX, y: y, width: pages.width, height: px), TomeLayout.paper); y += px * 2 }
        let face = CGRect(x: cr.minX, y: cr.minY + block, width: cr.width, height: cr.height - block)
        drawCoverFace(c, face)
    }

    /// The front cover over `face`: tooled leather, a gilt frame, brass corners, a lozenge with a cross on it, raised
    /// bands down the spine, a clasp, scuffs and a fur of dust.
    func drawCoverFace(_ c: CGContext, _ face: CGRect) {
        guard face.width > px * 2 else { box(c, face, TomeLayout.leatherDark); return }
        box(c, face, TomeLayout.leather)
        frame(c, face, px, TomeLayout.leatherDark)
        // The spine's raised bands, on the left edge.
        let sw = max(px * 3, face.width * 0.08)
        box(c, CGRect(x: face.minX, y: face.minY, width: sw, height: face.height), TomeLayout.leatherDark)
        for i in 1...4 {
            let y = snap(face.minY + face.height * CGFloat(i) / 5)
            box(c, CGRect(x: face.minX, y: y, width: sw, height: px * 2), TomeLayout.leatherLight)
        }
        // A blind-tooled frame and a gilt one inside it.
        let inner = face.insetBy(dx: face.width * 0.12, dy: face.height * 0.08).offsetBy(dx: sw * 0.4, dy: 0)
        frame(c, grid(inner), px, TomeLayout.leatherDark)
        frame(c, grid(inner.insetBy(dx: px * 3, dy: px * 3)), px, TomeLayout.gilt, 0.75)
        // The emblem: a gilt lozenge, a cross on it.
        let m = CGPoint(x: snap(inner.midX), y: snap(inner.midY + inner.height * 0.08))
        let lz = min(inner.width, inner.height) * 0.22
        let lozenge = CGMutablePath()
        lozenge.move(to: CGPoint(x: m.x, y: m.y + lz)); lozenge.addLine(to: CGPoint(x: m.x + lz * 0.75, y: m.y))
        lozenge.addLine(to: CGPoint(x: m.x, y: m.y - lz)); lozenge.addLine(to: CGPoint(x: m.x - lz * 0.75, y: m.y)); lozenge.closeSubpath()
        c.addPath(lozenge); c.setFillColor(rgb(TomeLayout.gilt, 0.85)); c.fillPath()
        c.addPath(lozenge); c.setStrokeColor(rgb(TomeLayout.leatherDark)); c.setLineWidth(px); c.strokePath()
        let arm = snap(lz * 0.55)
        box(c, CGRect(x: m.x - px, y: m.y - arm, width: px * 2, height: arm * 2), TomeLayout.leatherDark)
        box(c, CGRect(x: m.x - arm * 0.6, y: m.y + arm * 0.2, width: snap(arm * 1.2), height: px * 2), TomeLayout.leatherDark)
        // Gilt lettering: three short bars under the emblem, half worn away.
        for (i, wide) in [0.5, 0.36].enumerated() {
            let y = snap(m.y - lz - inner.height * 0.1 - CGFloat(i) * px * 4)
            let lw = snap(inner.width * CGFloat(wide))
            var x = snap(m.x - lw / 2)
            var j = 0
            while x < m.x + lw / 2 {
                let seg = px * CGFloat(1 + Int(noise(i * 31 + j) * 3))
                if noise(i * 17 + j * 3) > 0.2 { box(c, CGRect(x: x, y: y, width: seg, height: px * 2), TomeLayout.gilt, 0.6) }
                x += seg + px; j += 1
            }
        }
        // Brass corners, on the outer edge.
        let cs = max(px * 3, snap(face.width * 0.1))
        for (x, y) in [(face.maxX - cs, face.maxY - cs), (face.maxX - cs, face.minY)] {
            box(c, CGRect(x: x, y: y, width: cs, height: cs), TomeLayout.brass)
            box(c, CGRect(x: x + px, y: y + cs - px * 2, width: cs - px * 2, height: px), TomeLayout.brassLight)
            box(c, CGRect(x: x + cs / 2 - px / 2, y: y + cs / 2 - px / 2, width: px, height: px), TomeLayout.leatherDark)
        }
        // The clasp, across the outer edge.
        let clasp = CGRect(x: face.maxX - cs * 0.9, y: snap(face.midY - cs * 0.35), width: cs * 1.2, height: snap(cs * 0.7))
        box(c, clasp, TomeLayout.brass); box(c, CGRect(x: clasp.minX, y: clasp.maxY - px, width: clasp.width, height: px), TomeLayout.brassLight)
        // Scuffs, and dust settled on it.
        for i in 0..<Int(face.width * face.height / (px * px) / 50) {
            let x = face.minX + CGFloat(noise(i * 5 + 1)) * face.width, y = face.minY + CGFloat(noise(i * 5 + 2)) * face.height
            let hex: UInt32 = i % 3 == 0 ? TomeLayout.leatherLight : 0xB8AC94
            box(c, CGRect(x: snap(x), y: snap(y), width: px * (i % 4 == 0 ? 2 : 1), height: px), hex, i % 3 == 0 ? 0.5 : 0.35)
        }
    }

    /// The open boards (the leather around the pages) and the page blocks' edges at the foot.
    func drawBoards(_ c: CGContext, leftOpen: Bool) {
        let o = openRect
        let rightBoard = CGRect(x: spine - px, y: o.minY, width: pageW + board + px, height: o.height)
        box(c, rightBoard, TomeLayout.leather); frame(c, rightBoard, px, TomeLayout.leatherDark)
        if leftOpen {
            let leftBoard = CGRect(x: o.minX, y: o.minY, width: pageW + board + px, height: o.height)
            box(c, leftBoard, TomeLayout.leather); frame(c, leftBoard, px, TomeLayout.leatherDark)
        }
        // The page blocks, seen at their foot: thin lines of paper.
        let rightBlock = CGRect(x: spine, y: right.minY - block, width: pageW, height: block)
        box(c, rightBlock, TomeLayout.paperDark)
        var y = rightBlock.minY + px
        while y < rightBlock.maxY { box(c, CGRect(x: rightBlock.minX, y: y, width: rightBlock.width - px * CGFloat(Int(y / px) % 3), height: px), TomeLayout.paper); y += px * 2 }
        if leftOpen {
            let lb = CGRect(x: spine - pageW, y: left.minY - px * 2, width: pageW, height: px * 2)
            box(c, lb, TomeLayout.paperDark); box(c, CGRect(x: lb.minX + px, y: lb.minY + px, width: lb.width - px, height: px), TomeLayout.paper)
        }
        // The spine's hollow, a dark line down the middle.
        box(c, CGRect(x: spine - px, y: o.minY, width: px * 2, height: o.height), TomeLayout.leatherDark)
    }

    /// Parchment: the paper, browner at its edges, foxed with spots.
    func drawParchment(_ c: CGContext, _ page: CGRect, seed: Int) {
        box(c, page, TomeLayout.paper)
        frame(c, page, px, TomeLayout.paperDark)
        frame(c, page.insetBy(dx: px, dy: px), px, TomeLayout.paperDark, 0.45)
        let n = max(3, Int(page.width * page.height / (px * px) / 260))
        for i in 0..<n {
            let x = page.minX + CGFloat(noise(seed * 101 + i * 3)) * page.width, y = page.minY + CGFloat(noise(seed * 101 + i * 3 + 1)) * page.height
            box(c, CGRect(x: snap(x), y: snap(y), width: px * (i % 3 == 0 ? 2 : 1), height: px), 0xB89868, 0.45)
        }
    }

    /// A page of a Watcher's handwriting: lines of inked words, a red initial, now and then a diagram of a summoning
    /// circle in the middle.
    func drawText(_ c: CGContext, _ page: CGRect, seed: Int, diagram: Bool) {
        drawParchment(c, page, seed: seed)
        guard page.width > px * 6 else { return }
        let margin = page.width * 0.12
        let lineGap = max(px * 3, snap(page.height / 24))
        var y = page.maxY - page.height * 0.1
        var row = 0
        let hole: ClosedRange<CGFloat>? = diagram ? (page.midY - page.height * 0.22)...(page.midY + page.height * 0.2) : nil
        while y > page.minY + page.height * 0.08 {
            defer { y -= lineGap; row += 1 }
            if let gap = hole, gap.contains(y) { continue }
            var x = page.minX + margin
            if row == 0 {
                let cap = snap(lineGap * 2 - px)
                box(c, CGRect(x: snap(x), y: snap(y - cap + px * 2), width: cap, height: cap), 0x8A1A14)
                box(c, CGRect(x: snap(x) + px, y: snap(y - cap + px * 2) + px, width: cap - px * 2, height: px), TomeLayout.giltLight)
                x += cap + px * 2
            }
            let end = page.maxX - margin * (noise(seed * 13 + row) < 0.15 ? 2.5 : 1)
            var j = 0
            while x < end {
                let word = page.width * CGFloat(0.04 + 0.1 * noise(seed * 37 + row * 11 + j))
                box(c, CGRect(x: snap(x), y: snap(y), width: max(px, snap(min(word, end - x))), height: px), TomeLayout.ink, 0.8)
                x += word + max(px, page.width * 0.025); j += 1
            }
        }
        if diagram {
            // A summoning circle: two rings and a five-pointed star.
            let m = CGPoint(x: snap(page.midX), y: snap(page.midY - page.height * 0.01))
            let rr = min(page.width, page.height) * 0.17
            c.setStrokeColor(rgb(TomeLayout.ink, 0.85)); c.setLineWidth(px)
            c.strokeEllipse(in: CGRect(x: m.x - rr, y: m.y - rr, width: rr * 2, height: rr * 2))
            c.strokeEllipse(in: CGRect(x: m.x - rr * 0.82, y: m.y - rr * 0.82, width: rr * 1.64, height: rr * 1.64))
            let star = CGMutablePath()
            for i in 0..<6 {
                let a = Double.pi / 2 + Double(i * 2 % 5) * 2 * .pi / 5
                let p = CGPoint(x: m.x + rr * 0.82 * CGFloat(cos(a)), y: m.y + rr * 0.82 * CGFloat(sin(a)))
                if i == 0 { star.move(to: p) } else { star.addLine(to: p) }
            }
            c.addPath(star); c.strokePath()
            box(c, CGRect(x: m.x - px, y: m.y - px, width: px * 2, height: px * 2), 0x8A1A14)
        }
    }

    /// The inside of the front cover: a leather turn-in round dark marbled endpaper.
    func drawEndpaper(_ c: CGContext, _ page: CGRect) {
        box(c, page, 0x3A2A3A)
        for i in 0..<Int(page.width * page.height / (px * px) / 18) {
            let x = page.minX + CGFloat(noise(i * 7 + 400)) * page.width, y = page.minY + CGFloat(noise(i * 7 + 401)) * page.height
            let hex: UInt32 = [0x5A3A52, 0x2A4A4A, 0x6A5A3A][i % 3]
            box(c, CGRect(x: snap(x), y: snap(y), width: px * CGFloat(1 + i % 3), height: px), hex, 0.8)
        }
        frame(c, page, max(px * 2, board), TomeLayout.leather)
    }

    /// The right-hand page with the plate on it: the plate's space left bare (it's drawn over the art), a caption
    /// under it in the Watcher's hand.
    func drawPlatePage(_ c: CGContext) {
        let page = right
        drawParchment(c, page, seed: 9)
        let p = plate
        let lineGap = max(px * 3, snap(page.height / 24))
        var y = p.minY - lineGap * 1.6
        for row in 0..<4 where y > page.minY + page.height * 0.06 {
            let indent = row == 0 ? page.width * 0.3 : page.width * 0.12
            var x = page.minX + indent
            let end = page.maxX - page.width * (row == 0 ? 0.3 : 0.12)
            var j = 0
            while x < end {
                let word = page.width * CGFloat(0.04 + 0.09 * noise(row * 11 + j + 900))
                box(c, CGRect(x: snap(x), y: snap(y), width: max(px, snap(min(word, end - x))), height: px), row == 0 ? 0x8A1A14 : TomeLayout.ink, 0.8)
                x += word + max(px, page.width * 0.025); j += 1
            }
            y -= lineGap
        }
    }

    /// The fold in the middle, shaded in steps either side of the spine.
    func drawGutter(_ c: CGContext) {
        let steps = 3
        for i in 0..<steps {
            let wd = max(px, snap(pageW * 0.035)) * CGFloat(steps - i)
            let a = 0.12 * CGFloat(i + 1)
            box(c, CGRect(x: spine - wd, y: left.minY, width: wd * 2, height: pageH), 0x5A3A1A, a)
        }
        box(c, CGRect(x: spine - px, y: left.minY, width: px, height: pageH), 0x3A2410)
    }

    /// The cover or a page turning over the spine, `angle` from 0 (lying on the right) to π (lying on the left):
    /// squeezed towards the spine, a little taller as it stands up towards you, darker edge-on.
    func drawSwing(_ c: CGContext, angle: Double, cover: Bool, seed: Int) {
        let cosA = CGFloat(cos(angle)), lift = CGFloat(sin(angle))
        let squeeze = max(px / pageW, abs(cosA))
        c.saveGState()
        c.translateBy(x: spine, y: midY); c.scaleBy(x: squeeze, y: 1 + 0.12 * lift); c.translateBy(x: -spine, y: -midY)
        if cover {
            let o = openRect
            if cosA >= 0 {
                drawCoverFace(c, CGRect(x: spine - px, y: o.minY + block, width: pageW + board + px, height: o.height - block))
            } else {
                let inside = CGRect(x: o.minX, y: o.minY + block, width: pageW + board + px, height: o.height - block)
                box(c, inside, TomeLayout.leather)
                drawEndpaper(c, CGRect(x: spine - pageW, y: midY - pageH / 2, width: pageW, height: pageH))
            }
        } else if cosA >= 0 {
            drawText(c, right, seed: seed, diagram: false)
        } else {
            drawText(c, left, seed: seed + 1, diagram: seed % 2 == 1)
        }
        c.restoreGState()
        // Darker as it turns edge-on, in steps.
        let shade = ((1 - abs(cosA)) * 0.55 * 5).rounded() / 5
        if shade > 0 {
            let width = (cover ? pageW + board : pageW) * squeeze
            let x0 = cosA >= 0 ? spine : spine - width
            let tall = (cover ? openRect.height : pageH) * (1 + 0.12 * lift)
            c.setFillColor(rgb(0x1A0C04, shade)); c.fill(grid(CGRect(x: x0, y: midY - tall / 2, width: width, height: tall)))
        }
    }
}
