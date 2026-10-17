import CoreGraphics
import Foundation

// The opening titles (`SlayerWipe.titles`): see the plan's Transitions table.

extension SlayerTrip {
    /// A frame `k` (0…1) of the opening titles, from `old` to `new`, over the whole of `r`. The old place sinks into a
    /// night sky (0–0.08); the sky holds, a full moon swelling over the graveyard's skyline while clouds and a bat cross
    /// it (the organ chord, 0.08–0.26); then hard cuts, punk-fast, each on a flash: a vampire in game face lunging at
    /// the view (0.26–0.33), a gravestone in the fog (0.33–0.39), an old book flaring open (0.39–0.46); the leads slam
    /// in one after another as black silhouettes against the moon, Buffy with her stake, Giles with his crossbow,
    /// Willow with a spell glowing green in her hand, Xander with a rocket launcher on his shoulder (0.46–0.65);
    /// CLAWD SLAYER is brushed on in jagged strokes, a stake slamming down for the stem of SLAYER's L (0.65–0.88); and
    /// the black is swept off in ragged brush strokes, the title breaking up after it, onto the new place (0.88–1).
    /// Everything but the places is pixel art: drawn into a bitmap about 180 pixels tall and scaled up without
    /// smoothing, with a little grain; the leads are their own sprites, blacked out, at a whole number of pixels.
    func drawTitles(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        guard k > 0 else { ctx.draw(old, in: r); return }
        guard k < 1 else { ctx.draw(new, in: r); return }
        let px: CGFloat = max(1, (r.height / 180).rounded())      // screen pixels per pixel of the art
        let w = Int((r.width / px).rounded(.up)), h = Int((r.height / px).rounded(.up))
        guard let art = Self.artCanvas(width: w, height: h, px: px, in: r) else {
            Self.crossfade(ctx, old: old, new: new, k: k, in: r); return
        }
        art.translateBy(x: r.minX, y: r.minY)
        art.scaleBy(x: px, y: px)                                 // from here on, in pixels of the art, y up
        let W = Double(w), H = Double(h)
        let frame = Int(k * SlayerWipe.titles.duration * 30)      // for the grain and the twinkle, about 30 a second
        let shake = TitlesShake(k: k, frame: frame, px: px)

        switch k {
        case ..<0.26:
            // The old place sinks into the night; the moon swells.
            let fade = Self.ease(Self.span(k, 0, 0.08))
            let sky = Self.span(k, 0, 0.26)
            titlesSky(art, W: W, H: H, t: sky, frame: frame)
            titlesGrain(art, W: W, H: H, frame: frame)
            if fade < 1 { ctx.draw(old, in: r) }
            ctx.saveGState()
            ctx.setAlpha(CGFloat((fade * 5).rounded() / 5))
            Self.blit(art, onto: ctx, width: w, height: h, px: px, in: r)
            ctx.restoreGState()
        case ..<0.33:
            titlesVampire(art, W: W, H: H, t: Self.span(k, 0.26, 0.33), frame: frame)
            titlesGrain(art, W: W, H: H, frame: frame)
            shake.blit(art, onto: ctx, width: w, height: h, in: r)
            titlesFlash(ctx, r, k, at: 0.26, hex: 0xFFE8E0)
        case ..<0.39:
            titlesGrave(art, W: W, H: H, t: Self.span(k, 0.33, 0.39), frame: frame)
            titlesGrain(art, W: W, H: H, frame: frame)
            shake.blit(art, onto: ctx, width: w, height: h, in: r)
            titlesFlash(ctx, r, k, at: 0.33, hex: 0xDCE6FF)
        case ..<0.46:
            titlesBook(art, W: W, H: H, t: Self.span(k, 0.39, 0.46), frame: frame)
            titlesGrain(art, W: W, H: H, frame: frame)
            shake.blit(art, onto: ctx, width: w, height: h, in: r)
            titlesFlash(ctx, r, k, at: 0.39, hex: 0xFFE2B0)
        case ..<0.65:
            titlesMoonStage(art, W: W, H: H, frame: frame)
            titlesGrain(art, W: W, H: H, frame: frame)
            shake.blit(art, onto: ctx, width: w, height: h, in: r)
            titlesLeads(ctx, k: k, r: r, px: px, ground: CGFloat(TitlesLayout.ground(H)) * px, shake: shake.offset)
            for at in TitlesLayout.slams { titlesFlash(ctx, r, k, at: at, hex: 0xF4F8FF, strength: 0.7) }
        default:
            // The title, then the black swept off onto the new place.
            let clear = Self.span(k, 0.88, 0.995)
            let layout = TitlesLayout(W: W, H: H)
            if clear > 0 {
                ctx.draw(new, in: r)
                titlesSweep(art, W: W, H: H, p: clear)
            } else {
                art.setFillColor(titlesRGB(0x050509)); art.fill(CGRect(x: 0, y: 0, width: W, height: H))
                titlesStars(art, W: W, H: H, frame: frame, dim: true)
            }
            titlesLettering(art, layout, k: k)
            titlesTear(art, W: W, H: H, fade: Self.span(clear, 0.3, 0.85))
            if clear <= 0 { titlesGrain(art, W: W, H: H, frame: frame) }
            shake.blit(art, onto: ctx, width: w, height: h, in: r)
            titlesFlash(ctx, r, k, at: TitlesLayout.stakeLands, hex: 0xFFF2DC, strength: 0.8)
        }
    }

    // MARK: Cuts

    /// A flash of `hex` over everything for a frame or two from `at`, fading in steps.
    private func titlesFlash(_ ctx: CGContext, _ r: CGRect, _ k: Double, at: Double, hex: UInt32, strength: Double = 1) {
        let f = (k - at) / 0.016
        guard f >= 0, f < 1 else { return }
        let a = ((1 - f) * 3).rounded(.up) / 3 * strength
        ctx.setFillColor(titlesRGB(hex, CGFloat(a))); ctx.fill(r)
    }

    /// Grain: a scatter of lighter and darker art pixels, fresh every frame.
    private func titlesGrain(_ c: CGContext, W: Double, H: Double, frame: Int) {
        let n = Int(W * H / 45)
        let seed = frame * 7919
        c.setFillColor(titlesRGB(0xFFFFFF, 0.07))
        for i in 0..<n / 2 {
            c.fill(CGRect(x: floor(noise(seed + i * 2) * W), y: floor(noise(seed + i * 2 + 1) * H), width: 1, height: 1))
        }
        c.setFillColor(titlesRGB(0x000000, 0.16))
        for i in n / 2..<n {
            c.fill(CGRect(x: floor(noise(seed + i * 2) * W), y: floor(noise(seed + i * 2 + 1) * H), width: 1, height: 1))
        }
    }

    private func titlesStars(_ c: CGContext, W: Double, H: Double, frame: Int, dim: Bool = false, from lo: Double = 0.25) {
        let n = Int(W * H / 260)
        for i in 0..<n {
            let x = floor(noise(i * 3 + 11) * W), y = floor(H * lo + noise(i * 3 + 12) * H * (1 - lo))
            let tw = noise(i * 5 + frame / 4)
            guard tw > 0.18 else { continue }
            let bright = noise(i * 3 + 13) > 0.85
            c.setFillColor(titlesRGB(bright ? 0xDCE6FF : 0x7F92C0, dim ? 0.45 : 1))
            c.fill(CGRect(x: x, y: y, width: 1, height: 1))
        }
    }

    // MARK: The night sky and the moon

    /// The opening shot: a night sky in stepped bands of navy, stars, a full moon swelling as the view pushes in,
    /// clouds and a bat crossing it, and the graveyard's black skyline along the bottom.
    private func titlesSky(_ c: CGContext, W: Double, H: Double, t: Double, frame: Int) {
        let bands: [UInt32] = [0x04060F, 0x070B1C, 0x0A1028, 0x0E1632, 0x121C3E, 0x18244A]
        for (i, hex) in bands.enumerated() {
            let y0 = H * (1 - Double(i + 1) / Double(bands.count))
            c.setFillColor(titlesRGB(hex)); c.fill(CGRect(x: 0, y: floor(y0), width: W, height: ceil(H / Double(bands.count)) + 1))
        }
        titlesStars(c, W: W, H: H, frame: frame)
        let R = min(H * 0.26, W * 0.2) * (1 + 0.16 * Self.ease(t))
        let cx = W * 0.56, cy = H * 0.56 + H * 0.04 * t
        titlesMoon(c, cx: cx, cy: cy, R: R)

        // Clouds drifting across it: long ragged streaks of near-black.
        for i in 0..<4 {
            let len = R * (2.2 + noise(i * 17 + 3) * 1.6), thick = max(2, (R * (0.07 + 0.05 * noise(i * 17 + 4))).rounded())
            let y = cy + R * (-0.7 + 0.45 * Double(i)) + R * 0.1 * noise(i * 17 + 5)
            let x = cx - R * 2.6 + (t * (1.4 + 0.5 * noise(i * 17 + 6)) + noise(i * 17 + 7)) * R * 2.4
            c.setFillColor(titlesRGB(0x070A16, 0.92))
            c.fill(CGRect(x: floor(x), y: floor(y), width: floor(len), height: thick))
            c.fill(CGRect(x: floor(x + len * 0.15), y: floor(y + thick), width: floor(len * 0.55), height: max(1, floor(thick / 2))))
        }

        // A bat flapping across the moon's face.
        let bx = cx - R * 1.8 + t * R * 3.6, by = cy + R * 0.3 + sin(t * 9) * R * 0.08
        titlesBat(c, x: bx, y: by, size: max(3, (R * 0.12).rounded()), flap: frame % 4 < 2)

        titlesSkyline(c, W: W, H: H, top: H * 0.2)
    }

    /// A full moon: stepped halo rings, the disc, its seas.
    private func titlesMoon(_ c: CGContext, cx: Double, cy: Double, R: Double, halo: Bool = true) {
        func disc(_ rad: Double, _ hex: UInt32, _ a: CGFloat = 1, dx: Double = 0, dy: Double = 0) {
            c.setFillColor(titlesRGB(hex, a))
            c.fillEllipse(in: CGRect(x: floor(cx + dx - rad), y: floor(cy + dy - rad), width: floor(rad * 2), height: floor(rad * 2)))
        }
        if halo {
            disc(R * 1.6, 0x22325E, 0.45); disc(R * 1.32, 0x2E4272, 0.55); disc(R * 1.13, 0x4A5F92, 0.6)
        }
        disc(R, 0xE6ECF6)
        disc(R * 0.92, 0xD2DCEC, 1, dx: R * 0.08, dy: -R * 0.08)    // the shaded limb, the light from upper left
        disc(R * 0.86, 0xE6ECF6, 1, dx: -R * 0.02, dy: R * 0.02)
        disc(R * 0.24, 0xB8C6DE, 1, dx: -R * 0.3, dy: R * 0.25)     // its seas
        disc(R * 0.17, 0xB8C6DE, 1, dx: R * 0.28, dy: R * 0.32)
        disc(R * 0.3, 0xC4D0E4, 1, dx: R * 0.12, dy: -R * 0.3)
        disc(R * 0.1, 0xA9B8D2, 1, dx: -R * 0.42, dy: -R * 0.2)
    }

    /// A bat, wings up or down.
    private func titlesBat(_ c: CGContext, x: Double, y: Double, size s: Double, flap: Bool) {
        c.setFillColor(titlesRGB(0x05060C))
        c.fill(CGRect(x: floor(x - s * 0.25), y: floor(y - s * 0.3), width: max(2, floor(s * 0.5)), height: max(2, floor(s * 0.6))))
        let wy = flap ? s * 0.45 : -s * 0.35
        c.beginPath()
        c.move(to: CGPoint(x: x - s * 0.2, y: y)); c.addLine(to: CGPoint(x: x - s * 1.6, y: y + wy))
        c.addLine(to: CGPoint(x: x - s * 1.1, y: y + wy * 0.2)); c.addLine(to: CGPoint(x: x - s * 0.7, y: y - s * 0.15))
        c.move(to: CGPoint(x: x + s * 0.2, y: y)); c.addLine(to: CGPoint(x: x + s * 1.6, y: y + wy))
        c.addLine(to: CGPoint(x: x + s * 1.1, y: y + wy * 0.2)); c.addLine(to: CGPoint(x: x + s * 0.7, y: y - s * 0.15))
        c.closePath(); c.fillPath()
        c.fill(CGRect(x: floor(x - s * 0.7), y: floor(y - s * 0.15), width: floor(s * 1.4), height: max(1, floor(s * 0.3))))
    }

    /// The graveyard's skyline in black: a low rise, headstones and crosses, a bare tree, the crypt's roof.
    private func titlesSkyline(_ c: CGContext, W: Double, H: Double, top: Double) {
        c.setFillColor(titlesRGB(0x030409))
        c.beginPath()
        c.move(to: CGPoint(x: 0, y: 0))
        let steps = 24
        for i in 0...steps {
            let x = W * Double(i) / Double(steps)
            let y = top * (0.55 + 0.25 * sin(Double(i) * 0.7) + 0.12 * noise(i + 400))
            c.addLine(to: CGPoint(x: x, y: floor(y)))
        }
        c.addLine(to: CGPoint(x: W, y: 0)); c.closePath(); c.fillPath()
        let unit = max(2, (top * 0.09).rounded())
        // Headstones and crosses along the rise.
        for i in 0..<Int(W / (unit * 7)) {
            let x = floor(Double(i) * unit * 7 + noise(i * 9 + 1) * unit * 4)
            let base = floor(top * (0.55 + 0.25 * sin(x / W * Double(steps) * 0.7))) - 1
            let ht = unit * (1.6 + noise(i * 9 + 2) * 1.6)
            if noise(i * 9 + 3) > 0.7 {
                c.fill(CGRect(x: x, y: base, width: max(1, floor(unit * 0.5)), height: floor(ht * 1.3)))
                c.fill(CGRect(x: x - floor(unit * 0.5), y: base + floor(ht * 0.8), width: floor(unit * 1.5), height: max(1, floor(unit * 0.5))))
            } else {
                c.fill(CGRect(x: x, y: base, width: floor(unit * 1.4), height: floor(ht)))
                c.fillEllipse(in: CGRect(x: x, y: base + floor(ht - unit * 0.7), width: floor(unit * 1.4), height: floor(unit * 1.4)))
            }
        }
        // The bare tree on the left, its branches clawing up.
        let tx = floor(W * 0.12), tw = max(2, floor(unit * 1.2))
        c.fill(CGRect(x: tx, y: 0, width: tw, height: floor(top * 2.4)))
        func branch(_ x0: Double, _ y0: Double, _ x1: Double, _ y1: Double, _ th: Double) {
            let n = Int(max(abs(x1 - x0), abs(y1 - y0)))
            for s in 0...max(1, n) {
                let f = Double(s) / Double(max(1, n))
                c.fill(CGRect(x: floor(x0 + (x1 - x0) * f), y: floor(y0 + (y1 - y0) * f), width: th, height: th))
            }
        }
        let tt = top * 2.4
        branch(tx, tt * 0.7, tx - unit * 5, tt * 1.1, max(1, tw - 1))
        branch(tx + tw, tt * 0.8, tx + unit * 6, tt * 1.2, max(1, tw - 1))
        branch(tx, tt, tx - unit * 2, tt * 1.35, 1)
        branch(tx + tw, tt, tx + unit * 2.5, tt * 1.4, 1)
        branch(tx - unit * 3, tt * 0.95, tx - unit * 4.5, tt * 1.25, 1)
    }

    // MARK: The vampire

    /// A vampire lunging at the view in game face: a huge pale Clawd head, ridged brow, yellow eyes, fangs bared, claws
    /// reaching in from the sides, against red speed lines.
    private func titlesVampire(_ c: CGContext, W: Double, H: Double, t: Double, frame: Int) {
        c.setFillColor(titlesRGB(0x140306)); c.fill(CGRect(x: 0, y: 0, width: W, height: H))
        // Speed lines rushing out from the centre.
        let cx = W / 2, cy = H / 2
        let n = 22
        for i in 0..<n {
            let a0 = Double(i) / Double(n) * 2 * .pi + Double(frame % 3) * 0.05
            let a1 = a0 + 2 * .pi / Double(n) * (0.35 + 0.3 * noise(i + 50))
            let far = max(W, H)
            c.setFillColor(titlesRGB(i % 2 == 0 ? 0x3A0A12 : 0x24060C))
            c.beginPath(); c.move(to: CGPoint(x: cx, y: cy))
            c.addLine(to: CGPoint(x: cx + cos(a0) * far, y: cy + sin(a0) * far))
            c.addLine(to: CGPoint(x: cx + cos(a1) * far, y: cy + sin(a1) * far))
            c.closePath(); c.fillPath()
        }
        // The lunge: it comes at the view fast, then fills it.
        let lunge = 1 - pow(1 - t, 3)
        let s = min(H * 1.25, W * 0.62) * (0.55 + 0.6 * lunge)          // the head's width
        let hx = cx - s / 2 + (1 - lunge) * W * 0.06, hy = cy - s * 0.36 - (1 - lunge) * H * 0.05
        let u = s / 20                                                    // one pixel of the sprite's 20-wide body
        func box(_ x: Double, _ y: Double, _ bw: Double, _ bh: Double, _ hex: UInt32) {
            c.setFillColor(titlesRGB(hex))
            c.fill(CGRect(x: floor(hx + x * u), y: floor(hy + y * u), width: ceil(bw * u), height: ceil(bh * u)))
        }
        // Claws reaching in from both sides, behind the head.
        for side in [-1.0, 1.0] {
            let ax = side < 0 ? -6.0 : 21.0
            box(side < 0 ? -9 : 20, 3, 9, 4, 0x1A1A24)                     // the dark sleeves
            box(ax, 2.5, 5, 5, 0x9EA494)
            for j in 0..<3 {
                let nx = side < 0 ? ax - 2.0 : ax + 5.0
                box(nx, 2.8 + Double(j) * 1.7, 2, 0.9, 0xE8E0C8)
            }
        }
        // The head: outline, pallid skin, shading.
        box(-0.6, -0.6, 21.2, 13.2, 0x16161B)
        box(0, 0, 20, 12, 0xA9AE9C)
        box(0, 0, 20, 2, 0x868B7A)
        box(18, 0, 2, 12, 0x868B7A)
        // The ridged brow: a heavy lumpy shelf, furrows up the forehead.
        box(1, 7.5, 18, 2.2, 0x787D6C)
        for i in 0..<6 { box(1.5 + Double(i) * 3, 9.6, 2, 0.9, 0x6A6F5E) }
        box(9.4, 9.6, 1.2, 2.2, 0x6A6F5E)
        box(6, 10.5, 2.5, 0.8, 0x787D6C); box(11.5, 10.5, 2.5, 0.8, 0x787D6C)
        // Yellow eyes under it, slanted in a scowl.
        for ex in [4.0, 12.0] {
            let inner = ex < 9 ? 3.0 : 0.0
            box(ex, 4.8, 4, 2.6, 0xF2C230)
            box(ex + inner, 6.4, 1, 1.0, 0x787D6C)
            box(ex + 1.4, 5.0, 1.4, 1.8, 0xC2321E)
        }
        // The open mouth and the fangs.
        box(5, 0.8, 10, 3.2, 0x2A0508)
        box(5.5, 1.0, 9, 1.0, 0x5A0E16)
        box(5.4, 2.8, 9.2, 1.2, 0xE8E4D6)
        box(6.0, 1.6, 1.2, 1.3, 0xF4F0E4); box(12.8, 1.6, 1.2, 1.3, 0xF4F0E4)    // the fangs, down
        box(6.2, 1.2, 0.8, 0.5, 0xF4F0E4); box(13.0, 1.2, 0.8, 0.5, 0xF4F0E4)
        box(5.4, 0.8, 9.2, 0.6, 0xD8D4C6)
        // Moonlight on its upper edge.
        box(0, 11.4, 18, 0.6, 0xD6DCCB)
    }

    // MARK: The gravestone

    /// A gravestone in moonlight, fog drifting past its foot, the view pushing in.
    private func titlesGrave(_ c: CGContext, W: Double, H: Double, t: Double, frame: Int) {
        let bands: [UInt32] = [0x0A1028, 0x101A3A, 0x16224A, 0x1E2C58]
        for (i, hex) in bands.enumerated() {
            c.setFillColor(titlesRGB(hex))
            c.fill(CGRect(x: 0, y: floor(H * (1 - Double(i + 1) / 4)), width: W, height: ceil(H / 4) + 1))
        }
        titlesStars(c, W: W, H: H, frame: frame, from: 0.5)
        let zoom = 1 + 0.18 * t
        let gh = H * 0.64 * zoom, gw = min(gh * 0.62, W * 0.4)
        let gx = floor(W * 0.5 - gw / 2 - W * 0.04 * t), gy = floor(H * 0.12 - H * 0.06 * t)
        titlesMoon(c, cx: gx + gw * 1.6, cy: H * 0.78, R: H * 0.11, halo: true)
        // The stone: dark body, lit left edge, rounded top.
        func stone(_ dx: Double, _ hex: UInt32) {
            c.setFillColor(titlesRGB(hex))
            c.fill(CGRect(x: gx + dx, y: gy, width: gw, height: floor(gh - gw / 2)))
            c.fillEllipse(in: CGRect(x: gx + dx, y: floor(gy + gh - gw), width: gw, height: gw))
        }
        stone(-2, 0x8E9AB4)
        stone(0, 0x4A5266)
        c.setFillColor(titlesRGB(0x2E3444)); c.fill(CGRect(x: gx + gw - max(2, floor(gw * 0.08)), y: gy, width: max(2, floor(gw * 0.08)), height: floor(gh - gw / 2)))
        // The carved cross and a crack.
        let cw = max(2, floor(gw * 0.09))
        c.setFillColor(titlesRGB(0x22283A))
        c.fill(CGRect(x: floor(gx + gw / 2 - cw / 2), y: floor(gy + gh * 0.34), width: cw, height: floor(gh * 0.42)))
        c.fill(CGRect(x: floor(gx + gw / 2 - gw * 0.2), y: floor(gy + gh * 0.62), width: floor(gw * 0.4), height: cw))
        c.setFillColor(titlesRGB(0x6E7890))
        c.fill(CGRect(x: floor(gx + gw / 2 - cw / 2) - 1, y: floor(gy + gh * 0.34), width: 1, height: floor(gh * 0.42)))
        c.setFillColor(titlesRGB(0x1A1E2A))
        var x = gx + gw * 0.78, y = gy + gh * 0.82
        for i in 0..<Int(gh * 0.3) {
            c.fill(CGRect(x: floor(x), y: floor(y), width: 1, height: 1))
            y -= 1; x += noise(i + 300) > 0.6 ? -1 : (noise(i + 301) > 0.7 ? 1 : 0)
        }
        // The ground and the fog.
        c.setFillColor(titlesRGB(0x05060C)); c.fill(CGRect(x: 0, y: 0, width: W, height: floor(gy + 2)))
        for i in 0..<Int(W / 3) {
            let gx2 = Double(i) * 3 + noise(i + 600) * 2
            c.fill(CGRect(x: floor(gx2), y: floor(gy + 1), width: 1, height: floor(1 + noise(i + 700) * 4)))
        }
        for i in 0..<5 {
            let fy = gy - H * 0.04 + Double(i) * H * 0.045
            let fx = -W * 0.3 + (t * 0.5 + noise(i + 900)) * W * 0.6
            c.setFillColor(titlesRGB(0x9FB0D0, 0.13 + 0.05 * CGFloat(i % 2)))
            c.fill(CGRect(x: floor(fx), y: floor(fy), width: floor(W * 0.9), height: max(2, floor(H * 0.035))))
            c.fill(CGRect(x: floor(fx + W * 0.95), y: floor(fy + 1), width: floor(W * 0.6), height: max(2, floor(H * 0.03))))
        }
    }

    // MARK: The book

    /// An old book slamming open on a dark desk, light flaring up out of its pages: candle-orange rays and sparks.
    private func titlesBook(_ c: CGContext, W: Double, H: Double, t: Double, frame: Int) {
        c.setFillColor(titlesRGB(0x0C0806)); c.fill(CGRect(x: 0, y: 0, width: W, height: H))
        let open = Self.ease(Self.span(t, 0, 0.45))
        let flare = Self.span(t, 0.25, 1)
        let bw = min(W * 0.26, H * 0.5), bh = bw * 1.3
        let sx = floor(W / 2), by = floor(H * 0.5 - bh * 0.42)

        // The rays: wedges fanning up from the spine, growing as it opens.
        if flare > 0 {
            let reach = max(W, H) * (0.3 + 0.9 * flare)
            let n = 14
            for i in 0..<n {
                let a = .pi * (0.08 + 0.84 * Double(i) / Double(n - 1)) + sin(Double(frame) * 0.7 + Double(i)) * 0.02
                let wdt = 0.035 + 0.03 * noise(i + 70)
                let col: UInt32 = i % 3 == 0 ? 0xFFD27A : (i % 3 == 1 ? 0xF0902A : 0xB85A18)
                c.setFillColor(titlesRGB(col, CGFloat(0.35 + 0.35 * flare)))
                c.beginPath(); c.move(to: CGPoint(x: sx, y: by + bh * 0.5))
                c.addLine(to: CGPoint(x: sx + cos(a - wdt) * reach, y: by + bh * 0.5 + sin(a - wdt) * reach))
                c.addLine(to: CGPoint(x: sx + cos(a + wdt) * reach, y: by + bh * 0.5 + sin(a + wdt) * reach))
                c.closePath(); c.fillPath()
            }
        }
        // The back cover and the right-hand pages, always there.
        c.setFillColor(titlesRGB(0x3A1C0C)); c.fill(CGRect(x: sx - 1, y: by - 2, width: floor(bw + 3), height: floor(bh + 4)))
        c.setFillColor(titlesRGB(0xE8D4A4)); c.fill(CGRect(x: sx, y: by, width: floor(bw), height: floor(bh)))
        c.setFillColor(titlesRGB(0xB89A68))
        for i in 0..<Int(bh / 4) where i > 1 && i < Int(bh / 4) - 2 {
            c.fill(CGRect(x: sx + floor(bw * 0.12), y: by + Double(i) * 4, width: floor(bw * (0.6 + 0.2 * noise(i + 20))), height: 1))
        }
        // The front cover swinging over: its width on screen goes as the cosine of its angle.
        let swing = cos(.pi * open)
        if swing < 0 {
            // Past upright: the left-hand pages are showing, the cover lying out beyond them.
            c.setFillColor(titlesRGB(0x3A1C0C)); c.fill(CGRect(x: floor(sx - bw - 2), y: by - 2, width: floor(bw + 2), height: floor(bh + 4)))
            c.setFillColor(titlesRGB(0xE8D4A4)); c.fill(CGRect(x: floor(sx - bw * -swing), y: by, width: floor(bw * -swing), height: floor(bh)))
            c.setFillColor(titlesRGB(0xB89A68))
            for i in 2..<max(3, Int(bh / 4) - 2) {
                c.fill(CGRect(x: floor(sx - bw * -swing + bw * 0.12), y: by + Double(i) * 4, width: floor(bw * -swing * 0.65), height: 1))
            }
        } else {
            let cwd = floor(bw * swing + 2)
            c.setFillColor(titlesRGB(0x5A2A12)); c.fill(CGRect(x: sx, y: by - 2, width: cwd, height: floor(bh + 4)))
            c.setFillColor(titlesRGB(0xC89A3A))                    // a tooled border and a pentacle-ish boss, in brass
            if cwd > 6 {
                c.stroke(CGRect(x: sx + 2.5, y: by + 0.5, width: cwd - 5, height: floor(bh - 1)), width: 1)
                let d = max(2, floor(cwd * 0.25))
                c.fill(CGRect(x: floor(sx + cwd / 2 - d / 2), y: floor(by + bh / 2 - d / 2), width: d, height: d))
            }
        }
        c.setFillColor(titlesRGB(0x1E0E06)); c.fill(CGRect(x: sx - 1, y: by - 2, width: 2, height: floor(bh + 4)))
        // The glow on the pages, and sparks thrown up.
        if flare > 0 {
            c.setFillColor(titlesRGB(0xFFF2C8, CGFloat(0.5 * flare)))
            c.fillEllipse(in: CGRect(x: floor(sx - bw * 0.7), y: floor(by + bh * 0.2), width: floor(bw * 1.4), height: floor(bh * 0.7)))
            for i in 0..<30 {
                let a = .pi * (0.1 + 0.8 * noise(i + 80))
                let d = (0.1 + noise(i + 81) * 0.9) * flare * max(W, H) * 0.45
                let col: UInt32 = noise(i + 82) > 0.5 ? 0xFFE6A0 : 0xF0902A
                c.setFillColor(titlesRGB(col))
                c.fill(CGRect(x: floor(sx + cos(a) * d), y: floor(by + bh * 0.5 + sin(a) * d), width: 1 + Double(i % 2), height: 1 + Double(i % 2)))
            }
        }
    }

    // MARK: The leads

    /// The backdrop for the silhouettes: a great moon low behind them, the sky lit round it, black ground.
    private func titlesMoonStage(_ c: CGContext, W: Double, H: Double, frame: Int) {
        let bands: [UInt32] = [0x0A1028, 0x101A3A, 0x16224A, 0x1E2C58, 0x283A6A]
        for (i, hex) in bands.enumerated() {
            c.setFillColor(titlesRGB(hex))
            c.fill(CGRect(x: 0, y: floor(H * (1 - Double(i + 1) / 5)), width: W, height: ceil(H / 5) + 1))
        }
        titlesStars(c, W: W, H: H, frame: frame, from: 0.6)
        let R = min(H * 0.46, W * 0.3)
        titlesMoon(c, cx: W / 2, cy: TitlesLayout.ground(H) + R * 0.55, R: R)
        c.setFillColor(titlesRGB(0x030409)); c.fill(CGRect(x: 0, y: 0, width: W, height: TitlesLayout.ground(H) + 1))
    }

    /// The four leads, slamming in one after another as black silhouettes, each with what they fight with.
    private func titlesLeads(_ ctx: CGContext, k: Double, r: CGRect, px: CGFloat, ground: CGFloat, shake: CGPoint) {
        let spriteH = 30.0, spriteW = 27.0                  // a sprite's height and the spacing, in its own pixels
        let raw = min(Double(r.height) * 0.58 / spriteH, Double(r.width) * 0.2 / spriteW)
        let sp = max(1, CGFloat(raw).rounded(.down))        // screen pixels per pixel of the sprites
        let gap = CGFloat(spriteW) * sp
        ctx.saveGState()
        ctx.interpolationQuality = .none
        for (i, lead) in TitlesLead.all.enumerated() {
            let at = TitlesLayout.slams[i]
            guard k >= at, let img = lead.image else { continue }
            let f = Self.span(k, at, at + 0.014)
            let scale = sp * CGFloat(1 + 1.4 * (1 - f) * (1 - f))
            let cx = r.midX + (CGFloat(i) - 1.5) * gap + shake.x
            // The body's centre and its feet (sprite row 44) land on the ground.
            let dw = CGFloat(Sprite.width) * scale, dh = CGFloat(Sprite.height) * scale
            let x = (cx - CGFloat(Sprite.bodyCenterX + 3) * scale).rounded()
            let y = (r.minY + ground - (CGFloat(Sprite.height) - 44) * scale + shake.y).rounded()
            if lead == .willow {
                // Her spell lights the ground and the sky round her hand.
                let hx = x + CGFloat(Sprite.hand.x + 2) * scale, hy = y + (CGFloat(Sprite.height) - CGFloat(Sprite.hand.y)) * scale
                for (rad, a) in [(9.0, 0.18), (6.0, 0.3), (3.5, 0.5)] {
                    let rr = CGFloat(rad) * scale
                    ctx.setFillColor(titlesRGB(0x5CFF7A, CGFloat(a)))
                    ctx.fillEllipse(in: CGRect(x: hx - rr, y: hy - rr, width: rr * 2, height: rr * 2))
                }
            }
            ctx.draw(img, in: CGRect(x: x, y: y, width: dw, height: dh))
        }
        ctx.restoreGState()
    }

    // MARK: The lettering

    /// CLAWD SLAYER in jagged brush strokes, each stroke dragged on in turn, then the stake slamming down as the stem
    /// of SLAYER's L.
    private func titlesLettering(_ c: CGContext, _ L: TitlesLayout, k: Double) {
        let total = L.strokes.count
        let write = Self.span(k, 0.655, TitlesLayout.written)
        // The red under-stroke first, then the bone-white over it.
        for pass in 0..<2 {
            let off = pass == 0 ? L.u * 0.22 : 0
            let col = titlesRGB(pass == 0 ? 0x9E1424 : 0xEDE8DC)
            for (i, s) in L.strokes.enumerated() {
                let p = Self.clamp(write * Double(total) * 1.15 - Double(i))
                guard p > 0 else { continue }
                titlesBrush(c, s.points.map { CGPoint(x: $0.x + off, y: $0.y - off) }, width: s.width, upTo: p,
                            seed: i * 37 + 5, color: col)
            }
        }
        // The stake: a whittled wooden stake falling point first into place.
        let drop = Self.span(k, TitlesLayout.stakeFalls, TitlesLayout.stakeLands)
        guard drop > 0 else { return }
        let fall = (1 - drop * drop) * L.H * 1.1
        let st = L.stake
        let x = st.x, top = st.top + fall, bottom = st.bottom + fall, wd = st.width
        func stakeShape(_ dx: Double, _ dy: Double, _ hex: UInt32, inset: Double = 0) {
            c.setFillColor(titlesRGB(hex))
            c.beginPath()
            c.move(to: CGPoint(x: x - wd / 2 + dx + inset, y: top + dy - inset))
            c.addLine(to: CGPoint(x: x + wd / 2 + dx - inset, y: top + dy - inset))
            c.addLine(to: CGPoint(x: x + wd * 0.42 + dx - inset, y: bottom + wd * 2.2 + dy))
            c.addLine(to: CGPoint(x: x + dx, y: bottom + dy + inset))
            c.addLine(to: CGPoint(x: x - wd * 0.42 + dx + inset, y: bottom + wd * 2.2 + dy))
            c.closePath(); c.fillPath()
        }
        stakeShape(L.u * 0.22, -L.u * 0.22, 0x9E1424)
        stakeShape(0, 0, 0x2A1606)
        stakeShape(0, 0, 0xB07A44, inset: 1)
        c.setFillColor(titlesRGB(0xD8A868))                        // the lit side, and the grain
        c.fill(CGRect(x: floor(x - wd / 2 + 1), y: floor(bottom + wd * 2.2), width: max(1, floor(wd * 0.25)), height: floor(top - bottom - wd * 2.2 - 1)))
        c.setFillColor(titlesRGB(0x7A4E26))
        for g in 0..<3 {
            let gx = floor(x - wd * 0.1 + Double(g) * wd * 0.18)
            let gt = top - 2 - noise(g + 40) * (top - bottom) * 0.3
            c.fill(CGRect(x: gx, y: floor(bottom + wd * 2.6 + noise(g + 41) * wd), width: 1, height: max(1, floor(gt - bottom - wd * 3))))
        }
        c.setFillColor(titlesRGB(0xF0D8A8))                        // the whittled point
        c.fill(CGRect(x: floor(x - 1), y: floor(bottom + 1), width: 2, height: max(2, floor(wd * 1.2))))
    }

    /// Clearing: the title and what's left of the black torn away in rows, more of them as it goes.
    private func titlesTear(_ c: CGContext, W: Double, H: Double, fade: Double) {
        guard fade > 0 else { return }
        c.saveGState()
        c.setBlendMode(.clear)
        var y = 0, row = 0
        while Double(y) < H {
            let th = 1 + Int(noise(row * 7 + 3) * 3)
            if noise(row * 13 + 1) < fade { c.fill(CGRect(x: 0, y: Double(y), width: W, height: Double(th))) }
            y += th; row += 1
        }
        c.restoreGState()
    }

    /// One brush stroke along `pts`, dragged on as far as `p` (0…1) of its length: dabs under a pixel apart, their
    /// width ragged and tapering at both ends.
    private func titlesBrush(_ c: CGContext, _ pts: [CGPoint], width: Double, upTo p: Double, seed: Int, color: CGColor) {
        guard pts.count > 1 else { return }
        var lens: [Double] = [0]
        for i in 1..<pts.count { lens.append(lens[i - 1] + hypot(pts[i].x - pts[i - 1].x, pts[i].y - pts[i - 1].y)) }
        let total = lens.last ?? 0
        guard total > 0 else { return }
        let reach = total * p
        c.setFillColor(color)
        var seg = 1
        var d = 0.0, i = 0
        while d <= reach {
            while seg < pts.count - 1 && lens[seg] < d { seg += 1 }
            let a = pts[seg - 1], b = pts[seg]
            let f = (lens[seg] - lens[seg - 1]) > 0 ? (d - lens[seg - 1]) / (lens[seg] - lens[seg - 1]) : 0
            let x = Double(a.x) + Double(b.x - a.x) * f, y = Double(a.y) + Double(b.y - a.y) * f
            let u = d / total
            let taper = min(1, 0.55 + u * 4) * (u > 0.8 ? 1 - (u - 0.8) * 2.2 : 1)
            let hw = width / 2 * taper * (0.82 + 0.36 * noise(seed * 131 + i))
            // Breaking up: rows of it gone, more and more, as the title clears.
            c.fill(CGRect(x: floor(x - hw), y: floor(y - hw + (noise(seed * 77 + i) - 0.5) * 1.2), width: max(1, (hw * 2).rounded()),
                          height: max(1, (hw * 2).rounded())))
            d += 0.7; i += 1
        }
    }

    /// The clearing: the black painted off in ragged horizontal strokes from the left, the new place behind.
    private func titlesSweep(_ c: CGContext, W: Double, H: Double, p: Double) {
        let band = max(3, (H / 18).rounded())
        c.setFillColor(titlesRGB(0x050509))
        var y = 0.0, i = 0
        while y < H {
            let lag = noise(i * 13 + 1) * 0.35
            let edge = (Self.ease(Self.clamp((p - lag * 0.6) / 0.75)) * 1.25) * W - noise(i * 13 + 2) * W * 0.08
            if edge < W {
                c.fill(CGRect(x: max(0, floor(edge)), y: y, width: W, height: band))
                // A dry, broken leading edge.
                for j in 0..<Int(band) where noise(i * 101 + j) > 0.4 {
                    c.fill(CGRect(x: floor(edge - noise(i * 101 + j + 50) * band * 2.5), y: y + Double(j), width: band * 3, height: 1))
                }
            }
            y += band; i += 1
        }
    }
}

// MARK: - Layout, timing and the leads

/// Where the title's strokes go, as wide or tall as the frame allows: one line in a short strip, two on a screen
/// (CLAWD smaller over SLAYER), slanted a little, every stroke a list of points in art pixels.
private struct TitlesLayout {
    static let slams: [Double] = [0.47, 0.508, 0.546, 0.584]
    static let stakeFalls = 0.70, stakeLands = 0.72, written = 0.8
    static func ground(_ H: Double) -> Double { floor(H * 0.14) }

    struct Stroke { let points: [CGPoint]; let width: Double }
    let W: Double, H: Double, u: Double
    var strokes: [Stroke] = []
    var stake: (x: Double, top: Double, bottom: Double, width: Double) = (0, 0, 0, 0)

    private static let glyphs: [Character: (w: Double, strokes: [[(Double, Double)]])] = [
        "C": (5, [[(5, 6.8), (3.4, 8), (1.4, 7.4), (0.2, 5), (0.2, 3), (1.3, 0.6), (3.3, 0), (5.2, 1)]]),
        "L": (4.6, [[(0.6, 8.2), (0.6, 0)], [(0.2, 0.2), (4.8, 0)]]),
        "A": (5.4, [[(0, 0), (2.7, 8.2)], [(2.5, 8.2), (5.4, 0)], [(1.0, 3.0), (4.2, 3.4)]]),
        "W": (6.6, [[(0, 8.2), (1.5, 0)], [(1.4, 0.2), (3.3, 5.6)], [(3.3, 5.6), (5.0, 0)], [(5.0, 0.2), (6.6, 8.2)]]),
        "D": (5.2, [[(0.6, 8.2), (0.6, 0)], [(0.2, 8), (3.1, 7.7), (4.8, 5.6), (4.9, 2.6), (3.2, 0.4), (0.2, 0)]]),
        "S": (5, [[(5, 7), (3.3, 8.1), (1.0, 7.5), (0.6, 5.3), (2.6, 4.2), (4.5, 3.1), (4.5, 1.0), (2.5, 0), (0, 0.9)]]),
        "Y": (5.4, [[(0, 8.2), (2.7, 4)], [(5.4, 8.2), (2.6, 4)], [(2.7, 4.2), (2.7, 0)]]),
        "E": (4.8, [[(0.6, 8.2), (0.6, 0)], [(0.2, 8), (4.8, 8.2)], [(0.6, 4.2), (3.9, 4.4)], [(0.2, 0), (5.0, 0.2)]]),
        "R": (5.2, [[(0.6, 0), (0.6, 8.2)], [(0.2, 8), (3.4, 8.1), (4.9, 6.9), (4.8, 5.1), (3.3, 4.2), (0.6, 4.2)], [(2.4, 4.2), (5.3, 0)]]),
    ]

    init(W: Double, H: Double) {
        self.W = W; self.H = H
        let gap = 1.3
        func width(_ s: String) -> Double {
            s.reduce(0) { $0 + (Self.glyphs[$1]?.w ?? 3) } + gap * Double(s.count - 1)
        }
        let top = width("CLAWD"), bottom = width("SLAYER")
        let oneLine = W / H > 2.4
        if oneLine {
            u = min(W * 0.86 / (top + 3 + bottom), H * 0.56 / 8.2)
            let x0 = (W - (top + 3 + bottom) * u) / 2, y0 = (H - 8.2 * u) / 2
            place("CLAWD", x: x0, y: y0, u: u, gap: gap, stakeL: false)
            place("SLAYER", x: x0 + (top + 3) * u, y: y0, u: u, gap: gap, stakeL: true)
        } else {
            let small = 0.72
            u = min(W * 0.84 / bottom, H * 0.7 / (8.2 * (1 + small) + 2.4))
            let block = 8.2 * (1 + small) * u + 2.4 * u
            let yb = (H - block) / 2
            place("CLAWD", x: (W - top * u * small) / 2, y: yb + (8.2 + 2.4) * u, u: u * small, gap: gap, stakeL: false)
            place("SLAYER", x: (W - bottom * u) / 2, y: yb, u: u, gap: gap, stakeL: true)
        }
    }

    private mutating func place(_ word: String, x: Double, y: Double, u: Double, gap: Double, stakeL: Bool) {
        var cx = x
        let slant = 0.16
        for (n, ch) in word.enumerated() {
            guard let g = Self.glyphs[ch] else { continue }
            let jitter = (noise(n * 19 + word.count) - 0.5) * 0.5
            for (si, s) in g.strokes.enumerated() {
                if stakeL && ch == "L" && si == 0 {
                    stake = (x: cx + (0.6 + 4.1 * slant) * u, top: y + 9.6 * u, bottom: y - 1.6 * u, width: u * 1.6)
                    continue
                }
                let pts = s.map { p in CGPoint(x: cx + (p.0 + p.1 * slant) * u, y: y + (p.1 + jitter * (p.0 / max(1, g.w))) * u) }
                strokes.append(Stroke(points: pts, width: u * 1.15))
            }
            cx += (g.w + gap) * u
        }
    }
}

/// The view shaking for a moment after something slams down: the art blitted a few whole pixels off.
private struct TitlesShake {
    let offset: CGPoint
    let px: CGFloat
    init(k: Double, frame: Int, px: CGFloat) {
        self.px = px
        var amount = 0.0
        for at in TitlesLayout.slams + [0.26, TitlesLayout.stakeLands] where k >= at && k < at + 0.03 {
            amount = max(amount, 1 - (k - at) / 0.03)
        }
        let m = CGFloat((amount * 3).rounded(.up)) * px
        offset = CGPoint(x: (CGFloat(noise(frame * 3 + 1)) - 0.5) * 2 * m, y: (CGFloat(noise(frame * 3 + 2)) - 0.5) * 2 * m)
    }

    func blit(_ art: CGContext, onto ctx: CGContext, width w: Int, height h: Int, in r: CGRect) {
        guard offset != .zero else { SlayerTrip.blit(art, onto: ctx, width: w, height: h, px: px, in: r); return }
        ctx.saveGState()
        ctx.clip(to: r)
        ctx.setFillColor(titlesRGB(0x050509)); ctx.fill(r)       // what shows at the edge it's knocked off
        ctx.translateBy(x: (offset.x / px).rounded() * px, y: (offset.y / px).rounded() * px)
        SlayerTrip.blit(art, onto: ctx, width: w, height: h, px: px, in: r)
        ctx.restoreGState()
    }
}

/// The four leads, as black silhouettes of their own sprites with a rim of moonlight, each with their weapon.
private enum TitlesLead: CaseIterable {
    case buffy, giles, willow, xander
    static let all: [TitlesLead] = [.buffy, .giles, .willow, .xander]
    private static var cache: [TitlesLead: CGImage] = [:]

    var image: CGImage? {
        if let hit = Self.cache[self] { return hit }
        let c = PixelCanvas(Sprite.width, Sprite.height)
        let solid = C(0x101018)
        switch self {
        case .buffy:
            Cast.hero(.buffyClawmers).draw(c, t: 0, mode: .idle, walking: false, role: .none, asSession: true)
            // The stake raised high overhead, point up.
            c.rect(38, 27, 3, 8, solid); c.rect(39, 24, 4, 4, solid)
            c.rect(40, 12, 3, 12, solid); c.px(41, 10, solid); c.rect(41, 11, 1, 1, solid); c.px(40, 11, solid)
        case .giles:
            Cast.hero(.rupertGyles).draw(c, t: 0, mode: .idle, walking: false, role: .none, asSession: true)
            // A crossbow levelled: stock, the bow across its front, the string.
            c.rect(36, 31, 20, 3, solid); c.rect(38, 34, 3, 3, solid)
            for (i, y) in (22...43).enumerated() {
                let bend = abs(i - 10) / 4
                c.rect(53 - bend, y, 2, 1, solid)
            }
            c.rect(56, 32, 2, 1, solid)
        case .willow:
            Cast.hero(.willowRosenclaw).draw(c, t: 0, mode: .idle, walking: false, role: .none, asSession: true)
            c.rect(38, 30, 5, 2, solid)                             // the arm out, the palm up
        case .xander:
            Cast.hero(.xanderHarrows).draw(c, t: 0, mode: .idle, walking: false, role: .none, asSession: true)
            // A rocket launcher on his shoulder: the tube, its flared back, the sight and the grip.
            c.rect(12, 21, 40, 5, solid); c.rect(9, 20, 4, 7, solid); c.rect(51, 20, 3, 7, solid)
            c.rect(30, 26, 2, 4, solid); c.rect(38, 26, 2, 7, solid); c.rect(26, 18, 4, 3, solid)
        }
        // Black it out, a rim along the top and the left (moonlight, or Willow's green) to lift it off the sky.
        let rim = self == .willow ? C(0x8CFFA0) : C(0x41557F)
        let out = PixelCanvas(c.w, c.h)
        func solidAt(_ x: Int, _ y: Int) -> Bool {
            x >= 0 && y >= 0 && x < c.w && y < c.h && c.buf[(y * c.w + x) * 4 + 3] > 40
        }
        for y in 0..<c.h {
            for x in 0..<c.w where solidAt(x, y) {
                out.px(x, y, !solidAt(x, y - 1) || !solidAt(x - 1, y) ? rim : C(0x06070C))
            }
        }
        if self == .willow {
            out.glowLine(43, 27, 43, 27.5, core: C(0xE8FFE8), glow: C(0x5CFF7A), coreR: 1.4, glowR: 4.2)
        }
        let img = out.makeImage()
        Self.cache[self] = img
        return img
    }
}

private func titlesRGB(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
