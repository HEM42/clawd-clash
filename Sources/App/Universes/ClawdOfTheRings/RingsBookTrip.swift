import CoreGraphics
import CoreText
import Foundation

// The Red Book page turn between Clawd of the Rings places (`RingsWipe.redBook`).

extension RingsTrip {
    /// A frame `k` (0…1) of the Red Book turning from the old place's page to the new one's, over the whole of `r`.
    /// The view pulls back from the old place to the open book, the old place the picture on its right-hand page
    /// (0–0.2); the page lifts from its outer edge, curls over the spine and lies down on the left, uncovering the new
    /// place on the page behind it, its name in red letters at the top (0.2–0.75); the view pushes into the new picture
    /// until it fills the frame (0.75–1). The places are drawn as they are; the book (binding, gilt edges, parchment,
    /// lettering, writing) is pixel art, drawn into a bitmap about a sixth of `r` in each direction and scaled up
    /// without smoothing, and the turning page is cut into columns on that same grid.
    func drawBook(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.draw(old, in: r); return }
        guard k < 1 else { ctx.draw(new, in: r); return }
        let book = RedBook(r)
        let px: CGFloat = max(1, (r.height / 180).rounded())       // screen pixels per pixel of the book's art
        let zoom = CGFloat(bookEase(bookSpan(k, 0, 0.2)) * (1 - bookEase(bookSpan(k, 0.75, 1))))
        let turn = bookEase(bookSpan(k, 0.2, 0.75))
        let cam = book.camera(zoom)
        let unit = px / cam.scale                                   // one pixel of the art, in the book's units
        let grid = BookGrid(r: r, px: px)
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = bookCanvas(width: w, height: h, px: px, in: r) else { return }

        // The desk, the open book, and on it the pages that aren't turning.
        art.concatenate(cam.transform)
        book.drawDesk(art, visible: cam.visible, unit: unit)
        book.drawBinding(art, unit: unit)
        if turn >= 1 {
            book.drawTextPage(art, book.left, initial: nil, seed: 2, unit: unit)    // the old page's back, turned
        } else {
            book.drawTextPage(art, book.left, initial: "T", seed: 1, unit: unit)    // There and Back Again
        }
        book.drawPicturePage(art, title: turn > 0 ? to.name : from.name, unit: unit)
        book.drawCrease(art, unit: unit)
        bookBlit(art, onto: ctx, width: w, height: h, px: px, in: r)

        // The picture on the right-hand page: the new place once the old one's page has started to lift.
        let picture = grid.rect(cam.rect(book.picture))
        ctx.draw(turn > 0 ? new : old, in: picture)
        if turn > 0 && turn < 1 {
            drawTurningPage(ctx, book: book, cam: cam, grid: grid, old: old, turn: turn, px: px)
        }
    }

    /// The old place's page, mid-turn: cut into columns one pixel of the art wide, each tilted by how far it has turned
    /// (the outer edge leading, so the page curls), squeezed towards the spine, taller as it comes up towards you,
    /// darker as it turns edge-on, and showing its back (a page of writing) once it's past upright.
    private func drawTurningPage(_ ctx: CGContext, book: RedBook, cam: BookCamera, grid: BookGrid, old: CGImage,
                                 turn: Double, px: CGFloat) {
        let page = book.page
        let n = max(12, Int((page.width * cam.scale / px).rounded()))
        let th = max(8, Int((page.height * cam.scale / px).rounded()))
        let unit = page.width / CGFloat(n)
        let title = from.name
        guard let front = book.texture(width: n, height: th, of: page, draw: { c in
                  book.drawPicturePage(c, title: title, unit: unit)
                  book.drawCrease(c, unit: unit)
              }),
              let back = book.texture(width: n, height: th, of: book.left, draw: { c in
                  book.drawTextPage(c, book.left, initial: nil, seed: 2, unit: unit)
              }) else { return }

        // The curl: each column's angle (0 lying on the right, π lying on the left), and where its edges land.
        let bend = 0.5 * sin(Double.pi * turn)
        var phis = [Double](repeating: 0, count: n)
        var xs = [CGFloat](repeating: 0, count: n + 1)
        var zs = [CGFloat](repeating: 0, count: n + 1)
        var sx = 0.0, sz = 0.0
        xs[0] = grid.x(cam.x(book.spineX))
        for i in 0..<n {
            let u = (Double(i) + 0.5) / Double(n)
            let phi = Double.pi * min(1, max(0, turn + bend * (u - 0.35)))
            phis[i] = phi
            sx += cos(phi) / Double(n)
            sz += sin(phi) / Double(n)
            xs[i + 1] = grid.x(cam.x(book.spineX + CGFloat(sx) * page.width))
            zs[i + 1] = CGFloat(sz)
        }

        // Its shadow on the page it's uncovering, and on the left-hand page as it comes down.
        let spine = xs[0]
        let reach = page.width * cam.scale * 0.09
        let lift = CGFloat(sin(Double.pi * turn))
        if let most = xs.max(), most > spine + px {
            bookShadow(ctx, edge: most, towards: 1, width: reach * lift, strength: lift,
                       within: grid.rect(cam.rect(page)), grid: grid)
        }
        let edgeLift = CGFloat(sin(phis[n - 1]))
        if let least = xs.min(), least < spine - px {
            bookShadow(ctx, edge: least, towards: -1, width: reach * edgeLift, strength: edgeLift,
                       within: grid.rect(cam.rect(book.left)), grid: grid)
        }

        // The columns, from the spine out: those further out are higher up, so they're drawn over the rest.
        let cy = cam.y(page.midY), fullHeight = page.height * cam.scale
        let picLo = (book.picture.minY - page.minY) / page.height, picHi = (book.picture.maxY - page.minY) / page.height
        let picU0 = (book.picture.minX - page.minX) / page.width, picU1 = (book.picture.maxX - page.minX) / page.width
        let ow = CGFloat(old.width), oh = CGFloat(old.height)
        for i in 0..<n {
            let x0 = min(xs[i], xs[i + 1]), x1 = max(xs[i], xs[i + 1])
            guard x1 > x0 else { continue }
            let height = fullHeight * (1 + 0.22 * (zs[i] + zs[i + 1]) / 2)
            let bottom = grid.y(cy - height / 2), top = grid.y(cy + height / 2)
            let dest = CGRect(x: x0, y: bottom, width: x1 - x0, height: top - bottom)
            if xs[i + 1] > xs[i] {
                // The front: the parchment, and the old place where the column crosses the picture.
                if let col = front.cropping(to: CGRect(x: i, y: 0, width: 1, height: th)) { ctx.draw(col, in: dest) }
                let u = (CGFloat(i) + 0.5) / CGFloat(n)
                if u > picU0 && u < picU1 {
                    let p0 = (CGFloat(i) / CGFloat(n) - picU0) / (picU1 - picU0)
                    let p1 = (CGFloat(i + 1) / CGFloat(n) - picU0) / (picU1 - picU0)
                    let c0 = max(0, (p0 * ow).rounded(.down)), c1 = min(ow, max(c0 + 1, (p1 * ow).rounded(.up)))
                    let pb = grid.y(bottom + (top - bottom) * picLo), pt = grid.y(bottom + (top - bottom) * picHi)
                    if pt > pb, let col = old.cropping(to: CGRect(x: c0, y: 0, width: c1 - c0, height: oh)) {
                        ctx.draw(col, in: CGRect(x: x0, y: pb, width: x1 - x0, height: pt - pb))
                    }
                }
            } else if let col = back.cropping(to: CGRect(x: n - 1 - i, y: 0, width: 1, height: th)) {
                ctx.draw(col, in: dest)                              // the back, as it will lie on the left
            }
            // Darker as it turns edge-on, in steps.
            let shade = ((1 - abs(cos(phis[i]))) * 0.6 * 6).rounded() / 6
            if shade > 0 {
                ctx.setFillColor(bookRGB(0x2A1606, CGFloat(shade))); ctx.fill(dest)
            }
            // The page's top and bottom edges, a line of ink.
            ctx.setFillColor(bookRGB(0x6A4A26))
            ctx.fill(CGRect(x: x0, y: top - px, width: x1 - x0, height: px))
            ctx.fill(CGRect(x: x0, y: bottom, width: x1 - x0, height: px))
        }
    }
}

// MARK: - The book

/// Where everything is in the open Red Book, in `r`'s units, laid out so that the right-hand page's picture is `r`
/// itself (so the trip can start and end on a place filling the frame), and how far the view pulls back to show it.
private struct RedBook {
    let r: CGRect
    let picture: CGRect          // the place, on the right-hand page
    let page: CGRect             // the right-hand page
    let left: CGRect             // the left-hand page
    let spineX: CGFloat
    let cover: CGRect
    let marginX: CGFloat, marginTop: CGFloat, marginBottom: CGFloat
    let titleSize: CGFloat
    let gilt: CGFloat
    let pulled: CGFloat          // the view's scale, pulled back
    let view: CGPoint            // where the pulled-back view is centred

    init(_ r: CGRect) {
        self.r = r
        let width = r.width, height = r.height
        let aspect = width / max(1, height)
        // Pulled back to about half on a screen; less in a short strip, where the book is cropped top and bottom.
        pulled = min(0.85, max(0.52, 0.52 + (aspect - 1.8) * 0.1))
        titleSize = max(0.13 * height, 18 / pulled)
        marginX = 0.07 * height + 0.015 * width
        marginBottom = 0.09 * height
        marginTop = titleSize * 1.7
        picture = r
        page = CGRect(x: r.minX - marginX, y: r.minY - marginBottom,
                      width: width + 2 * marginX, height: height + marginBottom + marginTop)
        spineX = page.minX
        left = page.offsetBy(dx: -page.width, dy: 0)
        gilt = 0.03 * height
        let edge = 0.05 * height
        cover = left.union(page).insetBy(dx: -(gilt + edge), dy: -(gilt + edge))

        // The right-hand edge of the cover near the frame's, with the left-hand page running off the other side;
        // the whole book, centred, if it fits. The top of the page kept in, so its name shows.
        let gap = 0.05 * height
        let halfW = width / 2 / pulled, halfH = height / 2 / pulled
        let vx = cover.width + 2 * gap <= 2 * halfW ? cover.midX : cover.maxX + gap - halfW
        let vy = max(page.midY, page.maxY + 0.02 * height - halfH)
        view = CGPoint(x: vx, y: vy)
    }

    /// The view `zoom` of the way (0…1) from the picture filling the frame to pulled back.
    func camera(_ zoom: CGFloat) -> BookCamera {
        let scale = 1 + (pulled - 1) * zoom
        let focus = CGPoint(x: picture.midX + (view.x - picture.midX) * zoom, y: picture.midY + (view.y - picture.midY) * zoom)
        return BookCamera(r: r, scale: scale, focus: focus)
    }

    // MARK: Drawing (in the book's units; `unit` is one pixel of the art)

    /// A dark wooden desk in a pool of candlelight.
    func drawDesk(_ c: CGContext, visible: CGRect, unit: CGFloat) {
        c.setFillColor(bookRGB(0x1E1209)); c.fill(visible)
        let pool: [(CGFloat, UInt32)] = [(1.0, 0x2A190D), (0.82, 0x342012), (0.64, 0x3E2716)]
        for (f, hex) in pool {
            let rx = cover.width * 0.72 * f, ry = cover.height * 0.95 * f
            c.setFillColor(bookRGB(hex))
            c.fillEllipse(in: CGRect(x: cover.midX - rx, y: cover.midY - ry, width: rx * 2, height: ry * 2))
        }
        // Planks, and the joints between their boards.
        let plank = 0.34 * r.height
        c.setFillColor(bookRGB(0x0E0804, 0.55))
        var y = (visible.minY / plank).rounded(.down) * plank
        var j = Int((visible.minY / plank).rounded(.down))
        while y < visible.maxY {
            c.fill(CGRect(x: visible.minX, y: y, width: visible.width, height: unit))
            for b in 0..<3 {
                let jx = visible.minX + CGFloat(noise(j * 11 + b * 3 + 5)) * visible.width
                c.fill(CGRect(x: jx, y: y, width: unit, height: plank))
            }
            y += plank; j += 1
        }
    }

    /// Red leather covers, the spine's head and tail showing above and below, and the stacks of gilt-edged pages.
    func drawBinding(_ c: CGContext, unit: CGFloat) {
        let edge = (cover.width - left.width - page.width) / 2 - gilt
        // The spine's head and tail.
        c.setFillColor(bookRGB(0x4A0C08))
        c.fill(CGRect(x: spineX - edge * 0.7, y: cover.minY - edge * 0.3, width: edge * 1.4, height: cover.height + edge * 0.6))
        c.setFillColor(bookRGB(0xC89A3A))
        for y in [cover.minY - edge * 0.15, cover.maxY + edge * 0.15 - unit] {
            c.fill(CGRect(x: spineX - edge * 0.7, y: y, width: edge * 1.4, height: unit))
        }
        // The covers: dark leather at the rim, redder within, a gilt rule tooled round.
        let outer = CGPath(roundedRect: cover, cornerWidth: edge * 0.5, cornerHeight: edge * 0.5, transform: nil)
        c.addPath(outer); c.setFillColor(bookRGB(0x5A100C)); c.fillPath()
        let inner = cover.insetBy(dx: max(unit, edge * 0.2), dy: max(unit, edge * 0.2))
        c.addPath(CGPath(roundedRect: inner, cornerWidth: edge * 0.35, cornerHeight: edge * 0.35, transform: nil))
        c.setFillColor(bookRGB(0x8A1C14)); c.fillPath()
        bookFrame(c, cover.insetBy(dx: edge * 0.55, dy: edge * 0.55), thickness: unit, hex: 0xD9A93C)
        // A darker fold down the middle of the leather.
        c.setFillColor(bookRGB(0x5A100C))
        c.fill(CGRect(x: spineX - edge * 0.5, y: cover.minY, width: edge, height: cover.height))
        // The page stacks, their gilt edges in stripes.
        let stripes: [(CGFloat, UInt32)] = [(1, 0x8A5E16), (0.7, 0xE8BC56), (0.4, 0xB8842A), (0.15, 0xF4D684)]
        for (f, hex) in stripes {
            let e = gilt * f
            c.setFillColor(bookRGB(hex))
            c.fill(CGRect(x: left.minX - e, y: left.minY - e, width: left.width + e, height: left.height + 2 * e))
            c.fill(CGRect(x: spineX, y: page.minY - e, width: page.width + e, height: page.height + 2 * e))
        }
    }

    /// Cream parchment, darkening in steps towards its edges.
    func drawParchment(_ c: CGContext, _ p: CGRect, unit: CGFloat) {
        let e = max(unit, 0.009 * r.height)
        let steps: [(CGFloat, UInt32)] = [(0, 0xC9AC7A), (1, 0xD9C192), (2.5, 0xE6D3A8), (4.5, 0xF0E2BE)]
        for (f, hex) in steps {
            c.setFillColor(bookRGB(hex)); c.fill(p.insetBy(dx: e * f, dy: e * f))
        }
    }

    /// The right-hand page: parchment, the place's name in red at the top between two flourishes, and an inked frame
    /// round where the picture goes.
    func drawPicturePage(_ c: CGContext, title: String, unit: CGFloat) {
        drawParchment(c, page, unit: unit)
        let red: UInt32 = 0xA8201A
        let rule = max(4 * unit, 0.025 * r.height)
        bookFrame(c, picture.insetBy(dx: -rule, dy: -rule), thickness: unit, hex: red)
        c.setFillColor(bookRGB(0x3A2414)); c.fill(picture.insetBy(dx: -2 * unit, dy: -2 * unit))

        let cy = picture.maxY + rule + (page.maxY - picture.maxY - rule) * 0.48
        let wide = bookTitle(c, title, centre: CGPoint(x: picture.midX, y: cy), size: titleSize,
                             maxWidth: picture.width * 0.75, hex: red)
        // Flourishes either side: a rule and a lozenge.
        let gap = titleSize * 0.35, long = min(picture.width * 0.1, max(0, (picture.width - wide) / 2 - gap * 2))
        guard long > 4 * unit else { return }
        c.setFillColor(bookRGB(red))
        for side: CGFloat in [-1, 1] {
            let inner = picture.midX + side * (wide / 2 + gap)
            let outer = inner + side * long
            c.fill(CGRect(x: min(inner, outer), y: cy - unit / 2, width: long, height: unit))
            let d = max(unit, titleSize * 0.06)
            let diamond = CGMutablePath()
            diamond.move(to: CGPoint(x: outer - d, y: cy)); diamond.addLine(to: CGPoint(x: outer, y: cy + d))
            diamond.addLine(to: CGPoint(x: outer + d, y: cy)); diamond.addLine(to: CGPoint(x: outer, y: cy - d))
            diamond.closeSubpath()
            c.addPath(diamond); c.fillPath()
        }
    }

    /// A left-hand page of Bilbo's small brown writing in a red rule, starting (if `initial` is given) with a red
    /// and gold capital; `seed` picks the words.
    func drawTextPage(_ c: CGContext, _ p: CGRect, initial: String?, seed: Int, unit: CGFloat) {
        drawParchment(c, p, unit: unit)
        let block = CGRect(x: p.minX + marginX, y: p.minY + marginBottom,
                           width: p.width - 2 * marginX, height: p.height - marginBottom - marginTop * 0.55)
        let rule = max(4 * unit, 0.025 * r.height)
        bookFrame(c, block.insetBy(dx: -rule, dy: -rule), thickness: unit, hex: 0xA8201A)

        let line = titleSize * 0.42
        let ink = unit * max(1, (line * 0.22 / unit).rounded(.down))
        let wordGap = line * 0.45
        var capital: CGFloat = 0
        if let letter = initial {
            let size = line * 3 - wordGap * 0.5
            let box = CGRect(x: block.minX, y: block.maxY - size, width: size, height: size)
            c.setFillColor(bookRGB(0x9A1A12)); c.fill(box)
            bookFrame(c, box, thickness: unit, hex: 0xD9A93C)
            _ = bookTitle(c, letter, centre: CGPoint(x: box.midX, y: box.midY), size: size * 0.8, maxWidth: size, hex: 0xF0C450)
            capital = size + wordGap
        }
        c.setFillColor(bookRGB(0x4A3220))
        var row = 0, paragraph = 0
        var y = block.maxY - line * 0.75
        while y > block.minY {
            let indent: CGFloat = row < 3 ? capital : 0
            let endsParagraph = paragraph >= 6 + Int(noise(seed * 97 + row) * 5)
            let start = block.minX + indent + (paragraph == 0 && row > 0 ? line * 1.5 : 0)
            let end = endsParagraph ? start + (block.maxX - start) * CGFloat(0.3 + 0.4 * noise(seed * 53 + row)) : block.maxX
            var x = start, word = 0
            while x < end - line {
                let length = min(end - x, line * CGFloat(0.6 + 2.0 * noise(seed * 389 + row * 31 + word * 7)))
                c.fill(CGRect(x: x, y: y, width: length, height: ink))
                x += length + wordGap; word += 1
            }
            paragraph = endsParagraph ? 0 : paragraph + 1
            row += 1
            y -= line
        }
        drawGutter(c, p, spineOnRight: true)
    }

    /// The fold down the middle: a line of shadow, and both pages darkening in steps as they dip into it.
    func drawCrease(_ c: CGContext, unit: CGFloat) {
        drawGutter(c, page, spineOnRight: false)
        c.setFillColor(bookRGB(0x4A2A14))
        c.fill(CGRect(x: spineX - unit / 2, y: page.minY, width: unit, height: page.height))
    }

    private func drawGutter(_ c: CGContext, _ p: CGRect, spineOnRight: Bool) {
        let wide = marginX * 0.7
        c.setFillColor(bookRGB(0x6A4220, 0.13))
        for f: CGFloat in [1, 0.6, 0.3] {
            let x = spineOnRight ? p.maxX - wide * f : p.minX
            c.fill(CGRect(x: x, y: p.minY, width: wide * f, height: p.height))
        }
    }

    /// A page drawn into its own `width`×`height` bitmap, unsmoothed, to be cut into columns as it turns.
    func texture(width: Int, height: Int, of p: CGRect, draw: (CGContext) -> Void) -> CGImage? {
        guard let c = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        c.setShouldAntialias(false)
        c.scaleBy(x: CGFloat(width) / p.width, y: CGFloat(height) / p.height)
        c.translateBy(x: -p.minX, y: -p.minY)
        draw(c)
        return c.makeImage()
    }
}

/// Where the view is: the book's units scaled by `scale` about `focus`, which lands in the middle of `r`.
private struct BookCamera {
    let r: CGRect, scale: CGFloat, focus: CGPoint
    var transform: CGAffineTransform {
        CGAffineTransform(translationX: r.midX, y: r.midY).scaledBy(x: scale, y: scale).translatedBy(x: -focus.x, y: -focus.y)
    }
    func x(_ bx: CGFloat) -> CGFloat { r.midX + (bx - focus.x) * scale }
    func y(_ by: CGFloat) -> CGFloat { r.midY + (by - focus.y) * scale }
    func rect(_ b: CGRect) -> CGRect { CGRect(x: x(b.minX), y: y(b.minY), width: b.width * scale, height: b.height * scale) }
    /// What of the book is in view.
    var visible: CGRect {
        CGRect(x: focus.x - r.width / 2 / scale, y: focus.y - r.height / 2 / scale, width: r.width / scale, height: r.height / scale)
    }
}

/// The art's grid on screen: `px` pixels square, from `r`'s corner.
private struct BookGrid {
    let r: CGRect, px: CGFloat
    func x(_ v: CGFloat) -> CGFloat { r.minX + ((v - r.minX) / px).rounded() * px }
    func y(_ v: CGFloat) -> CGFloat { r.minY + ((v - r.minY) / px).rounded() * px }
    func rect(_ a: CGRect) -> CGRect {
        let x0 = x(a.minX), x1 = x(a.maxX), y0 = y(a.minY), y1 = y(a.maxY)
        return CGRect(x: x0, y: y0, width: x1 - x0, height: y1 - y0)
    }
}

// MARK: - Helpers

private func bookEase(_ k: Double) -> Double { k * k * (3 - 2 * k) }
/// How far `k` is through `a…b`: 0 before, 1 after.
private func bookSpan(_ k: Double, _ a: Double, _ b: Double) -> Double { min(1, max(0, (k - a) / (b - a))) }

/// A colour from 0xRRGGBB.
private func bookRGB(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}

/// The outline of `rect`, `thickness` wide, inside it.
private func bookFrame(_ c: CGContext, _ rect: CGRect, thickness t: CGFloat, hex: UInt32) {
    c.setFillColor(bookRGB(hex))
    c.fill(CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: t))
    c.fill(CGRect(x: rect.minX, y: rect.maxY - t, width: rect.width, height: t))
    c.fill(CGRect(x: rect.minX, y: rect.minY, width: t, height: rect.height))
    c.fill(CGRect(x: rect.maxX - t, y: rect.minY, width: t, height: rect.height))
}

/// `text` in a bookish serif, centred on `centre` and shrunk to fit `maxWidth`; returns how wide it came out.
@discardableResult
private func bookTitle(_ c: CGContext, _ text: String, centre: CGPoint, size: CGFloat, maxWidth: CGFloat, hex: UInt32) -> CGFloat {
    let font = CTFontCreateWithName("Palatino-Bold" as CFString, size, nil)
    let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): font,
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): bookRGB(hex),
    ]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attributes))
    var ascent: CGFloat = 0, descent: CGFloat = 0, leading: CGFloat = 0
    let width = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))
    guard width > 0 else { return 0 }
    let fit = min(1, maxWidth / width)
    let capHeight = CTFontGetCapHeight(font)
    c.saveGState()
    c.translateBy(x: centre.x, y: centre.y)
    c.scaleBy(x: fit, y: fit)
    c.textMatrix = .identity
    c.textPosition = CGPoint(x: -width / 2, y: -capHeight / 2)
    CTLineDraw(line, c)
    c.restoreGState()
    return width * fit
}

/// A shadow cast beside a lifted page's edge at `edge` (screen x), reaching `width` `towards` +1 (right) or -1 (left),
/// in three steps, kept within `within`.
private func bookShadow(_ ctx: CGContext, edge: CGFloat, towards dir: CGFloat, width: CGFloat, strength: CGFloat,
                        within: CGRect, grid: BookGrid) {
    guard width > grid.px, strength > 0.02 else { return }
    ctx.saveGState(); defer { ctx.restoreGState() }
    ctx.clip(to: within)
    ctx.setFillColor(bookRGB(0x2A1606, 0.16 * strength))
    for f: CGFloat in [1, 0.66, 0.33] {
        let far = grid.x(edge + dir * width * f)
        ctx.fill(CGRect(x: min(edge, far), y: within.minY, width: abs(far - edge), height: within.height))
    }
}

/// A clear bitmap `width`×`height`, set up so that drawing into it in `r`'s units lands on its grid, unsmoothed.
private func bookCanvas(width w: Int, height h: Int, px: CGFloat, in r: CGRect) -> CGContext? {
    guard w > 0, h > 0, let c = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
    c.setShouldAntialias(false)
    c.scaleBy(x: 1 / px, y: 1 / px)
    c.translateBy(x: -r.minX, y: -r.minY)
    return c
}

/// The art, scaled up onto `r` without smoothing.
private func bookBlit(_ art: CGContext, onto ctx: CGContext, width w: Int, height h: Int, px: CGFloat, in r: CGRect) {
    guard let img = art.makeImage() else { return }
    ctx.saveGState()
    ctx.clip(to: r)
    ctx.interpolationQuality = .none
    ctx.draw(img, in: CGRect(x: r.minX, y: r.minY, width: CGFloat(w) * px, height: CGFloat(h) * px))
    ctx.restoreGState()
}
