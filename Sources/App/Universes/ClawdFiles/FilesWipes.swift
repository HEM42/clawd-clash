import AppKit
import CoreText

/// The Clawd Files' trips between places, a different one each time: mostly something slightly unnatural happening to
/// an ordinary picture, the way the show does it. Drawn in the app's pixel art (every frame is put together a cell to
/// an art pixel and scaled up crisp), in its colours: desaturated forest greens, cold blue-greys, deep black shadows
/// and the odd eerie fluorescent green. Whoever's on screen, and where it's going, bring their own up more often.
/// When a trip is over, the new place's name types itself in (`FilesCaption`), as every scene opens in the show.
enum FilesWipe: Int, CaseIterable {
    case blackOil        // black oil creeps up the walls against gravity, swallows the scene, ripples, drains off the new one
    case blinkingEye     // a huge eye with the old place in its pupil blinks; it opens on the new place and dives into it
    case classifiedFile  // the old place goes into a case file as a photo; papers, redactions, TOP SECRET; the new photo comes out
    case interference    // a CRT loses sync: rolling, tearing, surveillance stills, static; it clears on the new place
    case montage         // the opening titles: the UFO, the eye, the warped face, the corridor, the hand, the racing clouds
    case abduction       // a saucer over the darkened scene; its beam widens until all is light, and leaves the new place
    case flashlight      // the lights go out; two flashlight beams sweep, cross in a flash, and find the new place
    case smoke           // a ribbon of cigarette smoke thickens into a fog with shapes in it, and clears on the new place
    case satellite       // the old place seen from orbit, pulled back to a dot on a map; the reticle finds the new one
    case distortion      // the picture's rows slide out of line and stretch, collapse to a line, and open on the new place

    var duration: Double {
        switch self {
        case .blackOil: return 2.4
        case .blinkingEye: return 2.4
        case .classifiedFile: return 2.8
        case .interference: return 2.2
        case .montage: return 6.0
        case .abduction: return 2.6
        case .flashlight: return 2.2
        case .smoke: return 2.4
        case .satellite: return 2.6
        case .distortion: return 2.0
        }
    }

    /// The longest, and the rarest: it only comes up now and then.
    var isRare: Bool { self == .montage }

    /// Whose it is: with one of them on screen it comes up more often.
    func isOwned(by c: Cast) -> Bool {
        guard c.universe == .clawdFiles else { return false }
        if c.isDark {
            guard let v = FilesVillain(rawValue: c.index) else { return false }
            switch self {
            case .blackOil: return [.blackOil, .clawcek].contains(v)
            case .abduction: return [.grey, .colonist, .facelessRebel, .bountyHunter, .lordKinbote].contains(v)
            case .smoke: return [.smokingClawd, .wellManicured, .firstElder, .strughold, .billClawder, .crewCutMan].contains(v)
            case .classifiedFile: return [.kersh, .follmer, .dianaFowlclaw].contains(v)
            case .distortion: return v.isParanormal
            default: return false
            }
        }
        guard let h = FilesHero(rawValue: c.index) else { return false }
        switch self {
        case .blackOil: return h == .marita
        case .blinkingEye: return h == .gibsonPrays
        case .classifiedFile: return [.foxClawder, .danaScrawly, .skinnard, .doggedd, .reyez, .einstine, .millar].contains(h)
        case .interference: return [.bytes, .frohack, .lanky, .jimmyBondd, .yvesHarlowe].contains(h)
        case .flashlight: return h == .foxClawder || h == .danaScrawly
        case .abduction: return h == .samantha || h == .maxFenig
        case .smoke: return h == .deepClawt || h == .misterX
        default: return false
        }
    }

    /// Its home turf: a trip there brings it up more often too.
    var turf: [Location] {
        switch self {
        case .blackOil: return [.antarctic]
        case .blinkingEye: return []
        case .classifiedFile: return [.xFilesOffice, .skinnardsOffice]
        case .interference: return [.gunclawdsDen, .apartment42]
        case .abduction: return [.area51, .mothership]
        case .flashlight: return [.bellefleurWoods, .newarkSewers, .toomsBlock, .quarantineCar]
        case .smoke: return [.syndicateClub]
        case .distortion: return [.autopsyBay, .chaneyMotel]
        case .montage, .satellite: return []
        }
    }
}

extension FilesVillain {
    /// The monsters of the week; the Pusher, Eve 6 and Luther Lee Boggs most of all.
    var isParanormal: Bool {
        switch self {
        case .pusher, .eve6, .lutherLeeBoggs, .tooms, .flukeman, .jerseyDevil, .leonardBetts, .greatMutato, .wendigo,
             .chuckleteeth, .virgilIncanto, .chupacabra, .bigBlue, .tithonus, .cecilLively, .eddieVanBlundht,
             .ronnieStrickland, .guyMann, .trashman, .tulpa, .mothmen, .rainKing, .teliko:
            return true
        default:
            return false
        }
    }
}

/// One trip's transition. Shared by the window and the screen saver, which hand over the old picture (frozen), the new
/// one (as it is right now) and how far through it is; a frame is drawn over the whole of `r`.
struct FilesTrip {
    let kind: FilesWipe
    /// Where it's coming from and going to: the satellite needs both to find them on its map.
    var from: Location? = nil
    var to: Location? = nil
    var duration: Double { kind.duration }

    /// Any transition but the last one, those of whoever's on screen and of the place it's going to weighted up, the
    /// satellite for long trips; the opening montage only now and then.
    static func pick(after last: FilesWipe?, cast: [Cast], from: Location?, to place: Location) -> FilesTrip {
        var kinds: [FilesWipe] = []
        let far = from.map { FilesMap.distance($0, place) > 12 } ?? false
        for kind in FilesWipe.allCases where kind != last {
            if kind.isRare { if Double.random(in: 0..<1) < 0.3 { kinds.append(kind) }; continue }
            kinds.append(kind)
            if cast.contains(where: kind.isOwned) { kinds += [kind, kind, kind] }
            if kind.turf.contains(place) { kinds += [kind, kind] }
            if kind == .satellite && far { kinds += [kind, kind, kind] }
        }
        return FilesTrip(kind: kinds.randomElement() ?? .flashlight, from: from, to: place)
    }

    /// A frame `k` (0…1) of the way from `old` to `new`, over the whole of `r`: put together at one cell per art
    /// pixel, then scaled up without smoothing.
    func draw(_ ctx: CGContext, old: CGImage, new: CGImage, k: Double, in r: CGRect) {
        let cell = max(1, (max(r.height / CGFloat(max(1, old.height)), r.height / 200)).rounded(.down))
        let w = max(8, Int((r.width / cell).rounded())), h = max(8, Int((r.height / cell).rounded()))
        guard let lo = Lo(w, h) else { ctx.draw(k < 0.5 ? old : new, in: r); return }
        let k = min(1, max(0, k))
        switch kind {
        case .blackOil: drawBlackOil(lo, old: old, new: new, k: k)
        case .blinkingEye: drawBlinkingEye(lo, old: old, new: new, k: k)
        case .classifiedFile: drawClassifiedFile(lo, old: old, new: new, k: k)
        case .interference: drawInterference(lo, old: old, new: new, k: k)
        case .montage: drawMontage(lo, old: old, new: new, k: k)
        case .abduction: drawAbduction(lo, old: old, new: new, k: k)
        case .flashlight: drawFlashlight(lo, old: old, new: new, k: k)
        case .smoke: drawSmoke(lo, old: old, new: new, k: k)
        case .satellite: drawSatellite(lo, old: old, new: new, k: k)
        case .distortion: drawDistortion(lo, old: old, new: new, k: k)
        }
        guard let img = lo.ctx.makeImage() else { return }
        ctx.saveGState()
        ctx.interpolationQuality = .none
        ctx.draw(img, in: r)
        ctx.restoreGState()
    }

    // MARK: Timing

    private static func ease(_ k: Double) -> Double { k * k * (3 - 2 * k) }
    private static func clamp(_ k: Double) -> Double { min(1, max(0, k)) }
    /// How far `k` is through `a…b`: 0 before, 1 after.
    private static func span(_ k: Double, _ a: Double, _ b: Double) -> Double { clamp((k - a) / (b - a)) }
    /// Up over `a…b`, down over `c…d`.
    private static func bump(_ k: Double, _ a: Double, _ b: Double, _ c: Double, _ d: Double) -> Double {
        span(k, a, b) * (1 - span(k, c, d))
    }

    // MARK: The Black Oil

    /// A pool of black oil creeps up from the floor against gravity, fingers of it running ahead up the walls, until
    /// the scene is a glossy black surface; rings ripple across it; then it drains back down off the new place.
    private func drawBlackOil(_ lo: Lo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        let rising = k < 0.5
        lo.image(rising ? old : new)
        let level = rising ? Self.ease(Self.span(k, 0, 0.42)) : 1 - Self.ease(Self.span(k, 0.58, 1))
        let reach = sin(.pi * (rising ? Self.span(k, 0, 0.45) : Self.span(k, 0.55, 1)))
        let top = CGFloat(level) * (h + 10) - 5
        let oil: UInt32 = 0x050708, sheen: UInt32 = 0x2A3540, glint: UInt32 = 0x7A8C98
        for x in 0..<lo.w {
            let fx = Double(x)
            let wave = sin(fx * 0.16 + k * 13) * 1.5 + sin(fx * 0.045 - k * 7) * 2.5
            var y = top + CGFloat(wave)
            // The fingers running on ahead, each a couple of pixels wide, tapering.
            for i in 0..<12 {
                let cx = noise(i * 7 + 3) * Double(lo.w), d = abs(fx - cx)
                guard d < 2.5 else { continue }
                let tall = (8 + noise(i * 7 + 4) * Double(lo.h) * 0.35) * reach * (1 - d / 2.5)
                y = max(y, top + CGFloat(tall))
            }
            guard y > 0 else { continue }
            lo.fill(oil, 1, CGRect(x: CGFloat(x), y: 0, width: 1, height: y))
            lo.fill(glint, 0.55, CGRect(x: CGFloat(x), y: y - 1, width: 1, height: 1))
            lo.fill(sheen, 0.6, CGRect(x: CGFloat(x), y: y - 3, width: 1, height: 2))
        }
        // The surface's sheen: long streaks drifting slowly, and rings rippling out once it's all black.
        for i in 0..<9 {
            let y = CGFloat(noise(i * 5) * 0.9 + 0.05) * h
            guard y < top - 4 else { continue }
            let len = CGFloat(10 + noise(i * 5 + 1) * 40)
            let x = CGFloat((noise(i * 5 + 2) + k * 0.3).truncatingRemainder(dividingBy: 1)) * (w + len) - len
            lo.fill(sheen, 0.7, CGRect(x: x, y: y, width: len, height: 1))
        }
        let ripple = Self.bump(k, 0.3, 0.42, 0.6, 0.7)
        if ripple > 0 {
            let c = CGPoint(x: w / 2, y: h * 0.45)
            for i in 0..<4 {
                let f = (k * 2.2 + Double(i) * 0.25).truncatingRemainder(dividingBy: 1)
                let rx = CGFloat(f) * w * 0.7, ry = rx * 0.32
                lo.ctx.setStrokeColor(rgb(i % 2 == 0 ? 0x3A4854 : 0x5A6C78, CGFloat(ripple * (1 - f))))
                lo.ctx.setLineWidth(1)
                lo.ctx.strokeEllipse(in: CGRect(x: c.x - rx, y: c.y - ry, width: rx * 2, height: ry * 2))
            }
            lo.fill(0x9AF0C8, CGFloat(ripple * 0.12), CGRect(x: c.x - 1, y: c.y - 1, width: 2, height: 2))
        }
    }

    // MARK: The Blinking Eye

    /// An eye, `ew` pixels from corner to corner over half its width, open `open` (0 shut … 1), with `img` reflected in
    /// its pupil; the pupil grows to the whole picture when it's big enough.
    private static func eye(_ lo: Lo, at c: CGPoint, halfWidth ew: CGFloat, open: CGFloat, pupil img: CGImage?,
                            reflect: CGFloat = 0.85) {
        let eh = ew * 0.42
        let ctx = lo.ctx
        // The skin round it.
        ctx.setFillColor(rgb(0x1A201C))
        ctx.fillEllipse(in: CGRect(x: c.x - ew * 1.3, y: c.y - eh * 2.2, width: ew * 2.6, height: eh * 4.4))
        ctx.setFillColor(rgb(0x262E28))
        ctx.fillEllipse(in: CGRect(x: c.x - ew * 1.05, y: c.y - eh * 1.4, width: ew * 2.1, height: eh * 2.9))
        // The opening: an almond, narrower as the lids close.
        let almond = CGMutablePath()
        let steps = max(8, Int(ew))
        for i in 0...steps {
            let x = -ew + 2 * ew * CGFloat(i) / CGFloat(steps), u = x / ew
            let hh = eh * CGFloat(pow(Double(max(0, 1 - u * u)), 0.8)) * open
            let p = CGPoint(x: c.x + x, y: c.y + hh * 1.08)
            if i == 0 { almond.move(to: p) } else { almond.addLine(to: p) }
        }
        for i in stride(from: steps, through: 0, by: -1) {
            let x = -ew + 2 * ew * CGFloat(i) / CGFloat(steps), u = x / ew
            let hh = eh * CGFloat(pow(Double(max(0, 1 - u * u)), 0.8)) * open
            almond.addLine(to: CGPoint(x: c.x + x, y: c.y - hh * 0.92))
        }
        almond.closeSubpath()
        // The crease over the lid.
        ctx.setStrokeColor(rgb(0x0C100E)); ctx.setLineWidth(max(1, ew / 60))
        ctx.strokeEllipse(in: CGRect(x: c.x - ew * 0.95, y: c.y - eh * 0.3, width: ew * 1.9, height: eh * 1.9))
        guard open > 0.02 else {
            ctx.setStrokeColor(rgb(0x050605)); ctx.setLineWidth(max(1, ew / 50))
            ctx.move(to: CGPoint(x: c.x - ew, y: c.y)); ctx.addLine(to: CGPoint(x: c.x + ew, y: c.y)); ctx.strokePath()
            return
        }
        ctx.saveGState()
        ctx.addPath(almond); ctx.clip()
        ctx.setFillColor(rgb(0xA8ADA4)); ctx.fill(lo.rect)
        ctx.setFillColor(rgb(0x6E746C)); ctx.fill(CGRect(x: c.x - ew, y: c.y + eh * 0.5, width: ew * 2, height: eh))   // the lid's shadow
        let ir = eh * 0.95, pr = ir * 0.46
        ctx.setFillColor(rgb(0x1A2A22)); ctx.fillEllipse(in: CGRect(x: c.x - ir, y: c.y - ir, width: ir * 2, height: ir * 2))
        ctx.setFillColor(rgb(0x3E5E4C)); ctx.fillEllipse(in: CGRect(x: c.x - ir * 0.9, y: c.y - ir * 0.9, width: ir * 1.8, height: ir * 1.8))
        ctx.setFillColor(rgb(0x5A7A64)); ctx.fillEllipse(in: CGRect(x: c.x - ir * 0.62, y: c.y - ir * 0.62, width: ir * 1.24, height: ir * 1.24))
        for i in 0..<16 {   // the iris's streaks
            let a = Double(i) / 16 * 2 * .pi + noise(i) * 0.2
            ctx.move(to: CGPoint(x: c.x + CGFloat(cos(a)) * pr, y: c.y + CGFloat(sin(a)) * pr))
            ctx.addLine(to: CGPoint(x: c.x + CGFloat(cos(a)) * ir * 0.85, y: c.y + CGFloat(sin(a)) * ir * 0.85))
        }
        ctx.setStrokeColor(rgb(0x2A4234, 0.8)); ctx.setLineWidth(max(1, ir / 30)); ctx.strokePath()
        // The pupil, the picture in it.
        let pupil = CGRect(x: c.x - pr, y: c.y - pr, width: pr * 2, height: pr * 2)
        ctx.setFillColor(rgb(0x020302)); ctx.fillEllipse(in: pupil)
        if let img {
            ctx.saveGState()
            ctx.addEllipse(in: pupil); ctx.clip()
            let ih = min(lo.rect.height, pr * 2), iw = ih * lo.rect.width / lo.rect.height
            ctx.setAlpha(reflect)
            ctx.draw(img, in: CGRect(x: c.x - iw / 2, y: c.y - ih / 2, width: iw, height: ih))
            ctx.restoreGState()
        }
        // The catchlight.
        let g = max(1, (pr * 0.22).rounded())
        ctx.setFillColor(rgb(0xE8F0EA, 0.85 * max(0, 1 - (pr * 2 / lo.rect.height) * 1.5))); ctx.fill(CGRect(x: c.x - pr * 0.55, y: c.y + pr * 0.3, width: g, height: g))
        ctx.restoreGState()
        // The lids' edges and lashes.
        ctx.addPath(almond); ctx.setStrokeColor(rgb(0x050605)); ctx.setLineWidth(max(1, ew / 50)); ctx.strokePath()
    }

    /// A huge eye fades in, the old place reflected in its pupil. It blinks; when it opens the new place is in the
    /// pupil, and the eye rushes at you until the pupil is the whole picture.
    private func drawBlinkingEye(_ lo: Lo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        let c = CGPoint(x: w / 2, y: h / 2)
        lo.fill(0x030504)
        let fadeOld = Self.span(k, 0, 0.2)
        if fadeOld < 1 { lo.image(old, alpha: CGFloat(1 - fadeOld)) }
        let ew0 = min(w * 0.36, h * 0.8)
        let shut = Self.bump(k, 0.36, 0.44, 0.47, 0.55)
        // The dive: the eye grows until the pupil covers the corners.
        let pupil0 = ew0 * 0.42 * 0.95 * 0.46
        let zEnd = Double(hypot(w, h) / 2 / pupil0) * 1.08
        let z = CGFloat(pow(zEnd, Self.ease(Self.span(k, 0.58, 0.97))))
        let appear = CGFloat(Self.span(k, 0.04, 0.22))
        guard appear > 0 else { return }
        guard let layer = Lo(lo.w, lo.h) else { return }
        Self.eye(layer, at: c, halfWidth: ew0 * z, open: CGFloat(1 - shut), pupil: k < 0.47 ? old : new,
                 reflect: CGFloat(0.55 + 0.45 * Self.span(k, 0.6, 0.9)))
        if let img = layer.ctx.makeImage() { lo.image(img, alpha: appear) }
        if k < 0.97 { lo.grain(seed: Int(k * 40), amount: 10) }
    }

    // MARK: The Classified File

    /// A desk and an open case file; `photo` its picture (a black-and-white print with a white border, clipped on),
    /// `colour` how much of its colour it has, at `s` of full size, turned `turn`, centred on `c`.
    private static func photo(_ lo: Lo, _ img: CGImage, grey: CGImage?, at c: CGPoint, scale s: CGFloat, turn: CGFloat,
                              colour: CGFloat) {
        let ctx = lo.ctx
        let pw = lo.rect.width * s, ph = lo.rect.height * s
        let border = max(0, min(4, (1 - s) * 8)).rounded()
        ctx.saveGState()
        ctx.translateBy(x: c.x, y: c.y); ctx.rotate(by: turn)
        if border > 0 {
            ctx.setFillColor(rgb(0x050605, 0.5)); ctx.fill(CGRect(x: -pw / 2 - border + 2, y: -ph / 2 - border - 2, width: pw + border * 2, height: ph + border * 2))
            ctx.setFillColor(rgb(0xE2E0D6)); ctx.fill(CGRect(x: -pw / 2 - border, y: -ph / 2 - border, width: pw + border * 2, height: ph + border * 2))
        }
        let rect = CGRect(x: -pw / 2, y: -ph / 2, width: pw, height: ph)
        ctx.draw(img, in: rect)
        if let grey, colour < 1 { ctx.setAlpha(1 - colour); ctx.draw(grey, in: rect); ctx.setAlpha(1) }
        if border > 0 {   // the paper clip
            let u = max(1, border / 2)
            ctx.setStrokeColor(rgb(0x9AA2A8)); ctx.setLineWidth(u)
            ctx.stroke(CGRect(x: -pw / 2 + pw * 0.12, y: ph / 2 - border * 2.5, width: border * 1.6, height: border * 4))
            ctx.stroke(CGRect(x: -pw / 2 + pw * 0.12 + u, y: ph / 2 - border * 1.5, width: border * 1.6 - u * 2, height: border * 2.8))
        }
        ctx.restoreGState()
    }

    /// A typed sheet `w`×`h` centred on `c`, turned `turn`: lines of type, some of them blacked out, `stamp` across it.
    private static func sheet(_ lo: Lo, seed: Int, at c: CGPoint, size: CGSize, turn: CGFloat, stamp: CGFloat) {
        let ctx = lo.ctx
        ctx.saveGState()
        ctx.translateBy(x: c.x, y: c.y); ctx.rotate(by: turn)
        let r = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
        ctx.setFillColor(rgb(0x050605, 0.45)); ctx.fill(r.offsetBy(dx: 2, dy: -2))
        ctx.setFillColor(rgb(seed % 2 == 0 ? 0xD8D6CA : 0xCFCDBF)); ctx.fill(r)
        let m = max(2, (size.width * 0.1).rounded()), step = max(2, (size.height / 22).rounded())
        // The letterhead: FBI and a case number.
        let head = max(5, (size.height / 16).rounded())
        lo.text("FBI", size: head, at: CGPoint(x: r.minX + m, y: r.maxY - m - head * 0.8), colour: 0x2A2C2A)
        lo.text("X-\(Int(noise(seed * 3) * 90000) + 10000)", size: head * 0.8, at: CGPoint(x: r.maxX - m - head * 3.6, y: r.maxY - m - head * 0.8), colour: 0x4A4C48)
        var y = r.maxY - m - head * 2
        var line = 0
        while y > r.minY + m {
            let len = CGFloat(0.55 + 0.45 * noise(seed * 31 + line)) * (size.width - m * 2)
            let redacted = noise(seed * 17 + line) < 0.3
            ctx.setFillColor(redacted ? rgb(0x0A0A0A) : rgb(0x6A6A62))
            ctx.fill(CGRect(x: r.minX + m, y: y, width: len, height: redacted ? max(2, step * 0.8) : 1))
            y -= step; line += 1
        }
        ctx.restoreGState()
        if stamp > 0 {
            // TOP SECRET, slammed on: big and faint, then down hard.
            let s = 1 + (1 - stamp) * 0.8
            let size = max(6, (size.height / 9).rounded())
            ctx.saveGState()
            ctx.translateBy(x: c.x, y: c.y); ctx.rotate(by: turn - 0.2); ctx.scaleBy(x: s, y: s)
            let tw = lo.textWidth("TOP SECRET", size: size)
            let box = CGRect(x: -tw / 2 - 3, y: -size * 0.45, width: tw + 6, height: size * 1.25)
            ctx.setStrokeColor(rgb(0x9A2A22, stamp)); ctx.setLineWidth(max(1, (size / 7).rounded()))
            ctx.stroke(box)
            lo.text("TOP SECRET", size: size, at: CGPoint(x: -tw / 2, y: -size * 0.2), colour: 0x9A2A22, alpha: stamp)
            ctx.restoreGState()
        }
    }

    /// The old place drains to a black-and-white photo clipped into a case file; typed sheets slide in over it, blacked
    /// out in places, and TOP SECRET comes down; they slide off a photo of the new place, which comes back to full
    /// size and colour.
    private func drawClassifiedFile(_ lo: Lo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        let first = k < 0.56
        let img = first ? old : new
        let grey = lo.greyed(img)
        // The photo's way into the file and out: size, turn, place.
        let f = first ? Self.ease(Self.span(k, 0.02, 0.26)) : 1 - Self.ease(Self.span(k, 0.72, 0.96))
        let colour = first ? 1 - Self.span(k, 0, 0.14) : Self.span(k, 0.8, 1)
        let s = CGFloat(1 - f * 0.56)
        let c = CGPoint(x: w / 2 - CGFloat(f) * w * 0.2, y: h / 2 + CGFloat(f) * h * 0.02)
        // The desk and the open folder, the typed page on the right.
        lo.fill(0x161A18)
        if f > 0.02 {
            let fold = CGRect(x: w * 0.06, y: h * 0.06, width: w * 0.88, height: h * 0.88)
            lo.ctx.setAlpha(CGFloat(min(1, f * 3)))
            lo.fill(0x0A0C0B, 0.5, fold.offsetBy(dx: 3, dy: -3))
            lo.fill(0xA8956A, 1, fold)
            lo.fill(0x96845C, 1, CGRect(x: fold.minX, y: fold.maxY - 2, width: fold.width, height: 2))
            lo.fill(0x7A6A48, 1, CGRect(x: fold.midX, y: fold.minY, width: 1, height: fold.height))
            Self.sheet(lo, seed: first ? 1 : 2, at: CGPoint(x: w * 0.72, y: h * 0.5), size: CGSize(width: w * 0.34, height: h * 0.78),
                       turn: 0.02, stamp: 0)
            lo.ctx.setAlpha(1)
        }
        Self.photo(lo, img, grey: grey, at: c, scale: s, turn: CGFloat(-0.05 * f), colour: CGFloat(colour))
        // The sheets sliding over, from either side, and off the other way.
        for i in 0..<5 {
            let inAt = 0.22 + Double(i) * 0.05, outAt = 0.56 + Double(i) * 0.035
            let come = Self.ease(Self.span(k, inAt, inAt + 0.12)), go = Self.ease(Self.span(k, outAt, outAt + 0.12))
            guard come > 0, go < 1 else { continue }
            let side: CGFloat = i % 2 == 0 ? -1 : 1
            let rest = CGPoint(x: w / 2 + CGFloat(noise(i * 9) - 0.5) * w * 0.2, y: h / 2 + CGFloat(noise(i * 9 + 1) - 0.5) * h * 0.16)
            let x = rest.x + side * w * CGFloat(1 - come) - side * w * CGFloat(go)
            let stamp = i == 4 || i == 2 ? CGFloat(Self.span(k, inAt + 0.12, inAt + 0.16)) : 0
            Self.sheet(lo, seed: i + 7, at: CGPoint(x: x, y: rest.y), size: CGSize(width: w * 0.5, height: h * 0.86),
                       turn: CGFloat(noise(i * 9 + 2) - 0.5) * 0.3, stamp: stamp)
        }
        if k < 0.96 { lo.grain(seed: Int(k * 40), amount: 6) }
    }

    // MARK: Television interference

    /// The old place pulls back into an old CRT; the picture loses sync, rolling and tearing, flashes of surveillance
    /// stills cut in, and it goes to static; it clears on the new place, steadies, and the view pushes back through the
    /// glass.
    private func drawInterference(_ lo: Lo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        guard let screen = Lo(lo.w, lo.h) else { return }
        let first = k < 0.52
        let img = first ? old : new
        let frame = Int(k * 60)
        // What's on the screen.
        let lost = first ? Self.ease(Self.span(k, 0.12, 0.42)) : 1 - Self.ease(Self.span(k, 0.6, 0.86))
        let roll = first ? pow(Self.span(k, 0.18, 0.5), 1.6) * 2.6 : (1 - Self.ease(Self.span(k, 0.55, 0.8))) * 0.7
        let off = CGFloat(roll.truncatingRemainder(dividingBy: 1)) * h
        screen.fill(0x050605)
        screen.image(img, CGRect(x: 0, y: -off, width: w, height: h))
        screen.image(img, CGRect(x: 0, y: h - off, width: w, height: h))
        if off > 1 { screen.fill(0x020302, 1, CGRect(x: 0, y: h - off - 2, width: w, height: 4)) }   // the sync bar
        screen.tear(amount: CGFloat(lost) * w * 0.08, k: k)
        screen.grade(amount: lost)
        // Surveillance stills cut in: a corner of the new place, grainy and green, with REC and the time.
        for (at, seed) in [(0.3, 1), (0.37, 2), (0.44, 3)] where k >= at && k < at + 0.035 {
            let crop = CGRect(x: w * CGFloat(noise(seed * 5)) * 0.5, y: h * CGFloat(noise(seed * 5 + 1)) * 0.5, width: w * 0.5, height: h * 0.5)
            screen.ctx.saveGState()
            screen.ctx.translateBy(x: -crop.minX * 2, y: -crop.minY * 2); screen.ctx.scaleBy(x: 2, y: 2)
            screen.image(seed == 2 ? old : new)
            screen.ctx.restoreGState()
            screen.green(amount: 1)
            let u = max(4, (h / 18).rounded())
            screen.fill(0xC8302A, 1, CGRect(x: u, y: h - u * 1.8, width: u * 0.8, height: u * 0.8))
            screen.text("REC", size: u, at: CGPoint(x: u * 2.1, y: h - u * 1.9), colour: 0xD8E8DC)
            screen.text(String(format: "CAM %02d  02:%02d:%02d", seed + 1, 13 + seed, frame % 60), size: u,
                        at: CGPoint(x: u, y: u * 0.8), colour: 0xD8E8DC)
            let b = u * 1.5
            for (x, y, dx, dy) in [(u, u * 2.5, 1, 1), (w - u, u * 2.5, -1, 1), (u, h - u * 2.5, 1, -1), (w - u, h - u * 2.5, -1, -1)] as [(CGFloat, CGFloat, CGFloat, CGFloat)] {
                screen.fill(0xD8E8DC, 0.8, CGRect(x: min(x, x + dx * b), y: y, width: b, height: 1))
                screen.fill(0xD8E8DC, 0.8, CGRect(x: x, y: min(y, y + dy * b), width: 1, height: b))
            }
        }
        // Static.
        let noisy = Self.bump(k, 0.42, 0.47, 0.56, 0.62)
        if noisy > 0 { screen.snow(seed: frame, amount: noisy) }
        screen.scanlines(0.28)
        // The set: the screen at `s` of the frame, in its cabinet, until the view pushes back through the glass.
        let s = CGFloat(1 - 0.24 * Self.ease(Self.span(k, 0, 0.14)) * (1 - Self.ease(Self.span(k, 0.82, 1))))
        let sw = w * s, sh = h * s
        let sr = CGRect(x: (w - sw) / 2, y: (h - sh) / 2 + h * 0.03 * (1 - s) / 0.24, width: sw, height: sh)
        lo.fill(0x0A0C0B)
        if s < 0.999 {
            let rim = h * 0.07
            let cab = sr.insetBy(dx: -rim, dy: -rim)
            lo.fill(0x1E2124, 1, CGRect(x: cab.minX, y: cab.minY - rim * 1.6, width: cab.width, height: cab.height + rim * 1.6))
            lo.fill(0x2C3034, 1, CGRect(x: cab.minX, y: cab.maxY - 2, width: cab.width, height: 2))
            for i in 0..<2 {   // the knobs under the screen
                let kx = cab.maxX - rim * CGFloat(2 + i * 2), ky = cab.minY - rim * 0.9
                lo.ctx.setFillColor(rgb(0x3A3E42)); lo.ctx.fillEllipse(in: CGRect(x: kx, y: ky, width: rim * 1.1, height: rim * 1.1))
            }
            lo.fill(0x9A2A22, 1, CGRect(x: cab.minX + rim, y: cab.minY - rim * 0.5, width: 2, height: 2))
            lo.fill(0x050605, 1, sr.insetBy(dx: -2, dy: -2))
        }
        if let img = screen.ctx.makeImage() {
            lo.ctx.saveGState()
            lo.ctx.addPath(CGPath(roundedRect: sr, cornerWidth: sw * 0.04 * (1 - s) / 0.24, cornerHeight: sh * 0.06 * (1 - s) / 0.24, transform: nil))
            lo.ctx.clip()
            lo.ctx.draw(img, in: sr)
            lo.fill(0xC8F0D8, 0.06 * (1 - s) / 0.24, sr)   // the glass
            lo.ctx.restoreGState()
        }
    }

    // MARK: The opening montage

    /// The title sequence, cut by cut: the saucer over the trees, the eye, the warped face, the ghost at the end of
    /// the corridor, the hand in red light, time-lapse clouds racing with THE TRUTH IS OUT THERE, and the clouds
    /// part on the new place.
    private func drawMontage(_ lo: Lo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        let cuts: [Double] = [0, 0.06, 0.2, 0.32, 0.44, 0.56, 0.66, 0.9, 1]
        let shot = (cuts.lastIndex { k >= $0 } ?? 0)
        let a = cuts[min(shot, cuts.count - 2)], b = cuts[min(shot + 1, cuts.count - 1)]
        let u = Self.span(k, a, b)   // how far through this shot
        switch shot {
        case 0:   // the old place drains and goes dark
            lo.image(old)
            lo.grade(amount: Self.span(u, 0, 0.6))
            lo.fill(0x020302, CGFloat(Self.span(u, 0.3, 1)))
        case 1:   // the saucer over the treeline
            Self.nightSky(lo, t: k * 2)
            if let saucer = Self.saucer(lit: Int(k * 30) % 2 == 0, beam: 0.6) {
                let sc = max(1, (w * 0.32 / 66).rounded(.down))
                let x = w * CGFloat(0.22 + 0.2 * u) - 33 * sc, y = h * 0.52 + CGFloat(sin(u * 6)) * sc
                lo.image(saucer, CGRect(x: x, y: y, width: 66 * sc, height: 29 * sc))
            }
            Self.treeline(lo)
        case 2:   // the eye, wide open and staring
            lo.fill(0x030504)
            Self.eye(lo, at: CGPoint(x: w / 2, y: h / 2), halfWidth: min(w * 0.42, h * 0.95) * CGFloat(1 + u * 0.15),
                     open: CGFloat(1 - Self.bump(u, 0.7, 0.8, 0.85, 0.95)), pupil: nil)
            lo.tear(amount: CGFloat(Self.bump(u, 0.3, 0.5, 0.5, 0.7)) * w * 0.025, k: k)
        case 3:   // the face, warped
            lo.fill(0x030504)
            if let face = Self.sprite(.hero(.foxClawder), working: false) {
                // Close in on the eyes: the body (rows 22 down) fills the frame.
                let sc = max(2, (h / 30).rounded(.down))
                let fw = CGFloat(Sprite.width) * sc, fh = CGFloat(Sprite.height) * sc
                lo.image(face, CGRect(x: w / 2 - CGFloat(Sprite.bodyCenterX) * sc, y: h / 2 - (CGFloat(Sprite.height) - 33) * sc,
                                      width: fw, height: fh))
            }
            lo.warp(amount: CGFloat(0.3 + 0.7 * sin(.pi * u)) * w * 0.045, stretch: 0.3, k: k)
        case 4:   // the ghost at the end of the corridor
            Self.corridor(lo, k: k)
            let flicker = noise(Int(k * 50)) > 0.25 ? 1.0 : 0.3
            if let ghost = Self.sprite(.villain(.colonist), working: false, silhouette: 0xD8F0E0) {
                let sc = max(1, (h * 0.34 / CGFloat(Sprite.height)).rounded(.down))
                let gw = CGFloat(Sprite.width) * sc, gh = CGFloat(Sprite.height) * sc
                lo.image(ghost, CGRect(x: w / 2 - CGFloat(Sprite.bodyCenterX) * sc, y: h * 0.38 - gh * 0.18, width: gw, height: gh),
                         alpha: CGFloat(flicker * (0.4 + 0.5 * u)))
            }
        case 5:   // the hand, in red light
            lo.fill(0x060202)
            Self.hand(lo, reach: u)
        case 6:   // time-lapse clouds, THE TRUTH IS OUT THERE
            Self.clouds(lo, t: k * 9)
            let words = Self.bump(u, 0.12, 0.3, 0.8, 0.95)
            if words > 0 {
                let size = max(6, (h * 0.075).rounded())
                let tw = lo.textWidth("THE TRUTH IS OUT THERE", size: size)
                lo.text("THE TRUTH IS OUT THERE", size: size, at: CGPoint(x: (w - tw) / 2, y: h * 0.46), colour: 0xF2F4EE,
                        alpha: CGFloat(words))
            }
        default:   // the clouds part on the new place
            lo.image(new)
            guard let sky = Lo(lo.w, lo.h) else { break }
            let e = Self.ease(u)
            Self.clouds(sky, t: k * 9, part: e)
            sky.grade(amount: 0.85)
            if let img = sky.ctx.makeImage() { lo.image(img) }
        }
        // Over every shot: the show's cold green cast, grain, dark corners, and a flash on each cut.
        if shot > 0 && shot < 7 && shot != 5 { lo.grade(amount: 0.85) }
        if k < 0.98 {
            lo.grain(seed: Int(k * 120), amount: 14)
            lo.vignette(0.55 * (1 - Self.span(k, 0.9, 1)))
        }
        let flash = shot > 0 && shot < 8 ? 1 - Self.span(u, 0, 0.12) : 0
        if flash > 0 { lo.fill(0xD8F0E0, CGFloat(flash * 0.35)) }
    }

    /// A night sky with low cloud drifting.
    private static func nightSky(_ lo: Lo, t: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        for y in 0..<lo.h {
            let f = Double(y) / Double(lo.h)
            lo.fill(lerp(0x1C2A26, 0x070C0B, f), 1, CGRect(x: 0, y: CGFloat(y), width: w, height: 1))
        }
        for i in 0..<30 {
            let x = CGFloat(noise(i * 3)) * w, y = h * 0.4 + CGFloat(noise(i * 3 + 1)) * h * 0.6
            lo.fill(0xC8D8D0, CGFloat(0.3 + 0.5 * noise(i * 3 + 2)), CGRect(x: x, y: y, width: 1, height: 1))
        }
        for i in 0..<10 {
            let rw = CGFloat(20 + noise(i * 4) * 60) * w / 320, rh = rw * 0.22
            let x = CGFloat((noise(i * 4 + 1) + t * 0.04 * (0.5 + noise(i * 4 + 2))).truncatingRemainder(dividingBy: 1.4) - 0.2) * w
            let y = h * CGFloat(0.55 + noise(i * 4 + 3) * 0.4)
            lo.ctx.setFillColor(rgb(0x24302C, 0.8)); lo.ctx.fillEllipse(in: CGRect(x: x, y: y, width: rw, height: rh))
        }
    }

    /// A dark ragged line of pines along the bottom.
    private static func treeline(_ lo: Lo) {
        let h = CGFloat(lo.h)
        for x in 0..<lo.w {
            let tip = Double(x % 9) < 4.5 ? Double(x % 9) : 9 - Double(x % 9)
            let tall = h * CGFloat(0.16 + 0.08 * noise(x / 9 * 5)) + CGFloat(tip) * h / 60
            lo.fill(0x040706, 1, CGRect(x: CGFloat(x), y: 0, width: 1, height: tall))
        }
    }

    /// Time-lapse clouds racing across a dusk sky; `part` 0…1 opens them from the middle out, the sky clearing.
    private static func clouds(_ lo: Lo, t: Double, part: Double = 0) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        for y in 0..<lo.h {
            let f = Double(y) / Double(lo.h)
            lo.fill(lerp(0x3A4A50, 0x121A1E, f), CGFloat(1 - part), CGRect(x: 0, y: CGFloat(y), width: w, height: 1))
        }
        for i in 0..<46 {
            let speed = 0.12 + 0.2 * noise(i * 5 + 2)
            var x = CGFloat((noise(i * 5) + t * speed).truncatingRemainder(dividingBy: 1.5) - 0.25) * w
            x += (x < w / 2 ? -1 : 1) * CGFloat(part) * w * CGFloat(0.6 + 0.4 * noise(i * 5 + 4))
            let y = CGFloat(noise(i * 5 + 1)) * h
            let rw = CGFloat(0.12 + 0.2 * noise(i * 5 + 3)) * w, rh = rw * CGFloat(0.3 + 0.15 * noise(i * 5 + 4))
            lo.ctx.setFillColor(rgb(i % 3 == 0 ? 0x8A969A : 0x5A666C, 0.7))
            lo.ctx.fillEllipse(in: CGRect(x: x - rw / 2, y: y - rh / 2, width: rw, height: rh))
            lo.ctx.setFillColor(rgb(0xA8B2B4, 0.35))
            lo.ctx.fillEllipse(in: CGRect(x: x - rw * 0.3, y: y, width: rw * 0.5, height: rh * 0.45))
        }
    }

    /// A corridor running away to a lit doorway.
    private static func corridor(_ lo: Lo, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        lo.fill(0x0A100D)
        let end = CGRect(x: w * 0.42, y: h * 0.32, width: w * 0.16, height: h * 0.4)
        lo.fill(0x6A8476, 1, end)
        lo.fill(0x9AB8A8, 0.5, end.insetBy(dx: end.width * 0.2, dy: end.height * 0.1))
        let ctx = lo.ctx
        ctx.setStrokeColor(rgb(0x2A3A32)); ctx.setLineWidth(1)
        for (sx, sy, ex, ey) in [(0, 0, end.minX, end.minY), (w, 0, end.maxX, end.minY), (0, h, end.minX, end.maxY), (w, h, end.maxX, end.maxY)] {
            ctx.move(to: CGPoint(x: sx, y: sy)); ctx.addLine(to: CGPoint(x: ex, y: ey))
        }
        ctx.strokePath()
        // Door frames and ceiling lights passing, as if walking down it.
        for i in 0..<5 {
            let f = CGFloat(pow((Double(i) / 5 + k * 3).truncatingRemainder(dividingBy: 1), 2))
            let fr = CGRect(x: end.minX * (1 - f), y: end.minY * (1 - f), width: end.width + (w - end.width) * f,
                            height: end.height + (h - end.height) * f)
            ctx.setStrokeColor(rgb(0x3A5044, 0.3 + 0.5 * f)); ctx.stroke(fr)
            ctx.setFillColor(rgb(0xC8E8D8, 0.4 + 0.4 * f))
            ctx.fill(CGRect(x: fr.midX - fr.width * 0.08, y: fr.maxY - 1 - f * 2, width: fr.width * 0.16, height: 1 + f * 2))
        }
    }

    /// The hand reaching up into red light.
    private static func hand(_ lo: Lo, reach: Double) {
        let rows = [
            "      ##        ",
            "   ## ##  ##    ",
            "   ## ## ###    ",
            "   ## ## ###    ",
            "   ## ## ## ##  ",
            "   ## ## ## ##  ",
            "   ## ## ## ##  ",
            "   ########## ##",
            "   ######### ###",
            "  ############# ",
            "  ############# ",
            "  ############  ",
            "   ##########   ",
            "   #########    ",
            "    ########    ",
            "    #######     ",
            "    #######     ",
            "    #######     ",
            "    #######     ",
            "    #######     ",
        ]
        let c = PixelCanvas(16, rows.count)
        c.pattern(0, 0, rows, ["#": C(0x9A2216)])
        // Lit from the upper left: the left edge of every run bright, the right dark.
        for (y, row) in rows.enumerated() {
            let chars = Array(row)
            for x in chars.indices where chars[x] == "#" {
                if x == 0 || chars[x - 1] != "#" { c.px(x, y, C(0xF05A3A)) }
                else if x == chars.count - 1 || chars[x + 1] != "#" { c.px(x, y, C(0x4A0E0A)) }
            }
        }
        guard let img = c.makeImage() else { return }
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        let sc = max(1, (h * CGFloat(0.7 + 0.15 * reach) / CGFloat(rows.count)).rounded(.down))
        lo.ctx.saveGState()
        lo.ctx.setShadow(offset: .zero, blur: h * 0.3, color: rgb(0xB82A18, 0.9))
        lo.image(img, CGRect(x: w / 2 - 8 * sc, y: -h * 0.1 + CGFloat(reach) * h * 0.1, width: 16 * sc, height: CGFloat(rows.count) * sc))
        lo.ctx.restoreGState()
    }

    /// A character's sprite, outlined dark, or all one colour.
    private static func sprite(_ who: Cast, working: Bool, silhouette: UInt32? = nil) -> CGImage? {
        let c = PixelCanvas(Sprite.width, Sprite.height)
        who.draw(c, t: 0, mode: working ? .working : .idle, walking: false, role: .none, asSession: false)
        guard let img = c.makeImage() else { return nil }
        guard let silhouette, let lo = Lo(Sprite.width, Sprite.height) else { return img }
        lo.image(img)
        lo.ctx.setBlendMode(.sourceIn)
        lo.fill(silhouette)
        return lo.ctx.makeImage()
    }

    /// The saucer's canvas (`Ride.width`×`Ride.height`, which the screen saver doesn't build with).
    private static let saucerW = 66, saucerH = 29

    /// The saucer, its beam down `beam` of the way.
    private static func saucer(lit: Bool, beam: Double) -> CGImage? {
        let c = PixelCanvas(Self.saucerW, Self.saucerH)
        drawSaucer(c, ramp: beam, engines: lit)
        return c.makeImage()
    }

    // MARK: The UFO abduction

    /// The lights go down on the old place and a saucer comes over; its pale green cone widens until everything is
    /// light, strange symbols flickering in it; the new place shows through under the same light, the cone narrows and
    /// pulls back up into the saucer, and it's gone.
    private func drawAbduction(_ lo: Lo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        lo.image(k < 0.5 ? old : new)
        let dark = Self.span(k, 0, 0.15) * (1 - Self.span(k, 0.82, 1))
        lo.fill(0x040A10, CGFloat(0.62 * dark))
        let sc = max(1, (w * 0.3 / CGFloat(Self.saucerW)).rounded(.down))
        let sw = CGFloat(Self.saucerW) * sc, shh = CGFloat(Self.saucerH) * sc
        let arrive = Self.ease(Self.span(k, 0.04, 0.22)), leave = Self.ease(Self.span(k, 0.84, 1))
        let hover = h * 0.97 - shh * 0.62
        let y = hover + (h + shh - hover) * CGFloat(1 - arrive) + (h + shh - hover) * CGFloat(leave * leave)
        let x = w / 2 - sw / 2 + CGFloat(sin(k * 9)) * sc + CGFloat(leave) * w * 0.3
        // The beam, from the saucer's belly to the ground: widening, washing everything out, then drawn back up.
        let widen = Self.ease(Self.span(k, 0.2, 0.46)) * (1 - Self.ease(Self.span(k, 0.56, 0.8)))
        let lift = Self.ease(Self.span(k, 0.7, 0.84))
        let topY = y + 18 * sc, ground = h * 0.06 + (topY - h * 0.06) * CGFloat(lift)
        let beamOn = Self.span(k, 0.14, 0.2) * (1 - Self.span(k, 0.82, 0.86))
        if beamOn > 0, topY > ground {
            let cx = x + 33 * sc
            let top = 7 * sc, bottom = (0.08 + 0.7 * CGFloat(widen)) * w + top
            let cone = CGMutablePath()
            cone.move(to: CGPoint(x: cx - top, y: topY)); cone.addLine(to: CGPoint(x: cx + top, y: topY))
            cone.addLine(to: CGPoint(x: cx + bottom, y: ground)); cone.addLine(to: CGPoint(x: cx - bottom, y: ground)); cone.closeSubpath()
            lo.ctx.addPath(cone); lo.ctx.setFillColor(rgb(0xC8FFE0, CGFloat(0.32 * beamOn))); lo.ctx.fillPath()
            let core = CGMutablePath()
            core.move(to: CGPoint(x: cx - top * 0.4, y: topY)); core.addLine(to: CGPoint(x: cx + top * 0.4, y: topY))
            core.addLine(to: CGPoint(x: cx + bottom * 0.4, y: ground)); core.addLine(to: CGPoint(x: cx - bottom * 0.4, y: ground)); core.closeSubpath()
            lo.ctx.addPath(core); lo.ctx.setFillColor(rgb(0xE8FFF2, CGFloat(0.25 * beamOn))); lo.ctx.fillPath()
            lo.ctx.setFillColor(rgb(0xC8FFE0, CGFloat(0.4 * beamOn)))
            lo.ctx.fillEllipse(in: CGRect(x: cx - bottom, y: ground - 3, width: bottom * 2, height: 6))
            // The symbols in the light.
            let glyphs = Self.bump(k, 0.24, 0.32, 0.62, 0.72)
            if glyphs > 0 {
                let g = max(1, (h / 100).rounded())
                for i in 0..<14 {
                    let seed = i * 13 + Int(k * 14) * 7
                    let gy = ground + (topY - ground) * CGFloat(0.1 + 0.8 * noise(seed))
                    let half = top + (bottom - top) * (topY - gy) / (topY - ground)
                    let gx = cx + (CGFloat(noise(seed + 1)) - 0.5) * half * 1.4
                    for bit in 0..<15 where noise(seed * 3 + bit) < 0.5 {
                        lo.fill(0x5AE88A, CGFloat(glyphs * 0.9), CGRect(x: gx + CGFloat(bit % 3) * g, y: gy + CGFloat(bit / 3) * g, width: g, height: g))
                    }
                }
            }
        }
        // The washout at its height, which hides the change of place.
        let wash = Self.bump(k, 0.36, 0.48, 0.52, 0.66)
        if wash > 0 { lo.fill(0xE0FFEC, CGFloat(wash)) }
        if y < h, let saucer = Self.saucer(lit: Int(k * 24) % 2 == 0, beam: 0) {
            lo.image(saucer, CGRect(x: x, y: y, width: sw, height: shh))
        }
    }

    // MARK: The flashlight investigation

    /// The old place goes dark to faint shapes; two flashlight beams sweep it, crossing in the middle in a white
    /// flash; then they find the new place, and the light comes back up.
    private func drawFlashlight(_ lo: Lo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        let img = k < 0.5 ? old : new
        lo.image(img)
        let dark = Self.ease(Self.span(k, 0, 0.16)) * (1 - Self.ease(Self.span(k, 0.74, 1)))
        lo.grade(amount: dark * 0.8)
        lo.fill(0x02060A, CGFloat(0.9 * dark))
        guard dark > 0.01 else { return }
        // Where they point: wandering, then meeting in the middle, then apart and wider as the light comes back.
        let meet = Self.ease(Self.span(k, 0.36, 0.5)) * (1 - Self.ease(Self.span(k, 0.5, 0.62)))
        let grow = 1 + 2.5 * Self.ease(Self.span(k, 0.62, 0.95))
        let rad = h * 0.17 * CGFloat(grow)
        for side in [-1.0, 1.0] {
            let wx = 0.5 + side * (0.22 + 0.1 * sin(k * 7 + side)), wy = 0.55 + 0.18 * sin(k * 5.3 + side * 2)
            let sx = CGFloat(wx + (0.5 - wx) * meet) * w, sy = CGFloat(wy + (0.5 - wy) * meet) * h
            let from = CGPoint(x: w / 2 + CGFloat(side) * w * 0.42, y: -h * 0.15)
            // The beam through the dark, and the pool of light where it lands.
            let cone = CGMutablePath()
            cone.move(to: CGPoint(x: from.x - 2, y: from.y)); cone.addLine(to: CGPoint(x: from.x + 2, y: from.y))
            cone.addLine(to: CGPoint(x: sx + rad * 0.9, y: sy)); cone.addLine(to: CGPoint(x: sx - rad * 0.9, y: sy)); cone.closeSubpath()
            lo.ctx.addPath(cone); lo.ctx.setFillColor(rgb(0xE8F0F0, CGFloat(0.07 * dark))); lo.ctx.fillPath()
            for (scale, alpha) in [(1.25, 0.35), (1.0, 1.0)] as [(CGFloat, CGFloat)] {
                let spot = CGRect(x: sx - rad * 1.2 * scale, y: sy - rad * scale, width: rad * 2.4 * scale, height: rad * 2 * scale)
                lo.ctx.saveGState()
                lo.ctx.addEllipse(in: spot); lo.ctx.clip()
                lo.image(img, alpha: alpha)
                lo.fill(0xFFF4D8, 0.08 * alpha)
                lo.ctx.restoreGState()
            }
        }
        let flash = Self.bump(k, 0.44, 0.5, 0.5, 0.6)
        if flash > 0 { lo.fill(0xF4F8F4, CGFloat(flash)) }
    }

    // MARK: Cigarette smoke

    /// A ribbon of smoke drifts in, thickens and curls into a fog with shapes passing in it (the Capitol's dome, men in
    /// suits, a tower of offices); it thins out on the new place, leaving a last wisp curling up.
    private func drawSmoke(_ lo: Lo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        lo.image(k < 0.5 ? old : new)
        guard let smoke = Lo(lo.w, lo.h) else { return }
        let thick = pow(sin(.pi * Self.span(k, 0.04, 0.96)), 1.3)
        let reach = Self.span(k, 0, 0.3)
        let ctx = smoke.ctx
        // The fog itself, at its thickest hiding the change of place.
        smoke.fill(0x6A706C, CGFloat(min(1, thick * thick * 1.25)))
        for i in 0..<70 {
            let u = Double(i) / 70
            guard u < reach || k > 0.5 else { continue }
            let rx = -0.1 + 1.2 * u, ry = 0.12 + 0.76 * u + sin(u * 8 + k * 4) * 0.12
            let swirl = k * 3 + Double(i) * 1.7, around = 0.08 + 0.3 * thick
            let x = CGFloat(rx + cos(swirl) * around * noise(i)) * w, y = CGFloat(ry + sin(swirl) * around * noise(i + 3)) * h
            let rad = h * CGFloat(0.04 + 0.4 * thick * (0.5 + noise(i * 3)))
            ctx.setFillColor(rgb(0x9A9E98, 0.22)); ctx.fillEllipse(in: CGRect(x: x - rad, y: y - rad, width: rad * 2, height: rad * 2))
            ctx.setFillColor(rgb(0xC8CAC2, 0.14)); ctx.fillEllipse(in: CGRect(x: x - rad * 0.5, y: y, width: rad, height: rad * 0.8))
        }
        // The shapes in it, each there for a moment.
        let shapes: [(Double, Double, CGFloat)] = [(0.28, 0.46, 0.28), (0.4, 0.58, 0.72), (0.52, 0.7, 0.4)]
        for (i, (a, b, x)) in shapes.enumerated() {
            let f = Self.bump(k, a, a + 0.06, b - 0.06, b)
            guard f > 0 else { continue }
            Self.smokeShape(smoke, i, at: x * w, alpha: CGFloat(f * 0.55))
        }
        // The last wisp, curling up as it clears.
        let wisp = Self.bump(k, 0.75, 0.82, 0.92, 1)
        if wisp > 0 {
            for i in 0..<24 {
                let u = Double(i) / 24
                let x = w * CGFloat(0.55 + sin(u * 7 + k * 6) * 0.06 * u), y = h * CGFloat(u * 0.9)
                let rad = max(1, h * CGFloat(0.012 + 0.03 * u))
                ctx.setFillColor(rgb(0xC8CAC2, CGFloat(wisp * (1 - u) * 0.6)))
                ctx.fillEllipse(in: CGRect(x: x - rad, y: y - rad, width: rad * 2, height: rad * 2))
            }
        }
        smoke.dither()
        if let img = smoke.ctx.makeImage() { lo.image(img) }
    }

    /// Shape `i` in the smoke: the dome of the Capitol, three men in suits, a tower of offices.
    private static func smokeShape(_ lo: Lo, _ i: Int, at x: CGFloat, alpha: CGFloat) {
        let h = CGFloat(lo.h), ctx = lo.ctx
        ctx.setFillColor(rgb(0x2A2E2C, alpha))
        switch i {
        case 0:
            let s = h * 0.5
            ctx.fill(CGRect(x: x - s * 0.7, y: h * 0.18, width: s * 1.4, height: s * 0.28))
            for c in 0..<7 { ctx.fill(CGRect(x: x - s * 0.6 + CGFloat(c) * s * 0.2, y: h * 0.18 + s * 0.28, width: max(1, s * 0.06), height: s * 0.3)) }
            ctx.fill(CGRect(x: x - s * 0.65, y: h * 0.18 + s * 0.58, width: s * 1.3, height: s * 0.06))
            ctx.fillEllipse(in: CGRect(x: x - s * 0.35, y: h * 0.18 + s * 0.45, width: s * 0.7, height: s * 0.6))
            ctx.fill(CGRect(x: x - max(1, s * 0.03), y: h * 0.18 + s * 1.0, width: max(2, s * 0.06), height: s * 0.2))
        case 1:
            for (n, dx) in [-1.0, 0.0, 1.0].enumerated() {
                guard let man = sprite(.villain(n == 1 ? .smokingClawd : .wellManicured), working: false, silhouette: 0x2A2E2C) else { continue }
                let sc = max(1, (h * 0.55 / 30).rounded(.down))
                lo.image(man, CGRect(x: x + CGFloat(dx) * 30 * sc - CGFloat(Sprite.bodyCenterX) * sc, y: h * 0.12,
                                     width: CGFloat(Sprite.width) * sc, height: CGFloat(Sprite.height) * sc), alpha: alpha * 1.4)
            }
        default:
            let s = h * 0.7
            ctx.fill(CGRect(x: x - s * 0.18, y: h * 0.1, width: s * 0.36, height: s))
            ctx.setFillColor(rgb(0x6A706C, alpha))
            for r in 0..<10 { for c in 0..<4 where noise(r * 4 + c) < 0.5 {
                ctx.fill(CGRect(x: x - s * 0.14 + CGFloat(c) * s * 0.075, y: h * 0.14 + CGFloat(r) * s * 0.09, width: max(1, s * 0.03), height: max(1, s * 0.04)))
            } }
        }
    }

    // MARK: The surveillance satellite

    /// The old place, seen from orbit in green, pulls up into a dot on a map; the reticle slides across to the new
    /// place, reading off its coordinates, and locks on; the view dives through the clouds into it, and its colour
    /// comes back.
    private func drawSatellite(_ lo: Lo, old: CGImage, new: CGImage, k: Double) {
        let w = CGFloat(lo.w), h = CGFloat(lo.h)
        let a = FilesMap.point(from), b = FilesMap.point(to)
        let mid = (lat: (a.lat + b.lat) / 2, lon: (a.lon + b.lon) / 2)
        let apart = max(14, FilesMap.distance(a, b) * 1.7)
        // The camera: degrees across the frame, and what it's centred on.
        let close = 0.035
        let out = Self.ease(Self.span(k, 0.02, 0.3)), back = Self.ease(Self.span(k, 0.62, 0.92))
        let zoom: Double = k < 0.5 ? close * pow(apart / close, out) : apart * pow(close / apart, back)
        // Panning only as fast as it pulls out, so the place stays in view.
        let pan = (zoom - close) / (apart - close)
        let near = k < 0.5 ? a : b
        let centre = (lat: near.lat + (mid.lat - near.lat) * pan, lon: near.lon + (mid.lon - near.lon) * pan)
        let perPx = zoom / Double(w)
        lo.map(centre: centre, degreesPerPixel: perPx)
        // The two places, as pictures on the ground.
        for (p, img) in [(a, old), (b, new)] {
            let pw = CGFloat(close / perPx), ph = pw * h / w
            guard pw >= 1 else { continue }
            let x = w / 2 + CGFloat((p.lon - centre.lon) / perPx) - pw / 2, y = h / 2 + CGFloat((p.lat - centre.lat) / perPx) - ph / 2
            lo.image(img, CGRect(x: x, y: y, width: pw, height: ph))
        }
        let tint = Self.span(k, 0, 0.12) * (1 - Self.span(k, 0.9, 1))
        lo.green(amount: tint)
        guard tint > 0 else { return }
        // The grid.
        let step = max(8, (h / 10).rounded())
        let gx = CGFloat((centre.lon / perPx).truncatingRemainder(dividingBy: Double(step)))
        let gy = CGFloat((centre.lat / perPx).truncatingRemainder(dividingBy: Double(step)))
        for x in stride(from: -gx, to: w, by: step) { lo.fill(0x5AE88A, CGFloat(0.16 * tint), CGRect(x: x, y: 0, width: 1, height: h)) }
        for y in stride(from: -gy, to: h, by: step) { lo.fill(0x5AE88A, CGFloat(0.16 * tint), CGRect(x: 0, y: y, width: w, height: 1)) }
        // The reticle, moving from one to the other, locking on.
        let move = Self.ease(Self.span(k, 0.3, 0.52))
        let target = (lat: a.lat + (b.lat - a.lat) * move, lon: a.lon + (b.lon - a.lon) * move)
        let tx = w / 2 + CGFloat((target.lon - centre.lon) / perPx), ty = h / 2 + CGFloat((target.lat - centre.lat) / perPx)
        let locked = k > 0.54
        let showReticle = Self.span(k, 0.2, 0.26) * (1 - Self.span(k, 0.66, 0.7))
        if showReticle > 0 && (!locked || k > 0.6 || Int(k * 60) % 2 == 0) {
            let col: UInt32 = locked ? 0xE8FFE8 : 0x7AF09A, al = CGFloat(showReticle)
            lo.fill(col, al * 0.35, CGRect(x: 0, y: ty, width: w, height: 1))
            lo.fill(col, al * 0.35, CGRect(x: tx, y: 0, width: 1, height: h))
            let s = h * (locked ? 0.07 : 0.1), arm = s * 0.5
            for (dx, dy) in [(-1, -1), (1, -1), (-1, 1), (1, 1)] as [(CGFloat, CGFloat)] {
                let cx = tx + dx * s, cy = ty + dy * s
                lo.fill(col, al, CGRect(x: min(cx, cx - dx * arm), y: cy, width: arm, height: 1))
                lo.fill(col, al, CGRect(x: cx, y: min(cy, cy - dy * arm), width: 1, height: arm))
            }
        }
        // The readout.
        if showReticle > 0 {
            let size = max(5, (h / 22).rounded())
            lo.text(FilesMap.reading(target), size: size, at: CGPoint(x: size, y: size), colour: 0x9AF0B0, alpha: CGFloat(showReticle))
            if locked { lo.text("TARGET ACQUIRED", size: size, at: CGPoint(x: size, y: size * 2.3), colour: 0xE8FFE8, alpha: CGFloat(showReticle)) }
            lo.text("KH-11  PASS \(4 + Int(noise(7) * 5))", size: size, at: CGPoint(x: w - size * 9, y: h - size * 1.6), colour: 0x9AF0B0, alpha: CGFloat(showReticle))
        }
        // Through the clouds on the way down.
        let dive = Self.bump(k, 0.62, 0.68, 0.8, 0.88)
        if dive > 0 {
            for i in 0..<26 {
                let f = (noise(i * 3) + k * 4).truncatingRemainder(dividingBy: 1)
                let ang = noise(i * 3 + 1) * 2 * .pi, d = CGFloat(f * f) * hypot(w, h) * 0.7
                let rad = h * CGFloat(0.05 + 0.3 * f)
                lo.ctx.setFillColor(rgb(0xD8E4DC, CGFloat(dive * 0.7)))
                lo.ctx.fillEllipse(in: CGRect(x: w / 2 + CGFloat(cos(ang)) * d - rad, y: h / 2 + CGFloat(sin(ang)) * d - rad * 0.6,
                                              width: rad * 2, height: rad * 1.2))
            }
        }
    }

    // MARK: Paranormal distortion

    /// The picture's rows slide out of line and stretch, like the warped face in the titles; it collapses into a thin
    /// bright line, which opens out on the new place, the rows settling back.
    private func drawDistortion(_ lo: Lo, old: CGImage, new: CGImage, k: Double) {
        guard let src = Lo(lo.w, lo.h) else { return }
        src.image(k < 0.5 ? old : new)
        let amp = CGFloat(sin(.pi * Self.span(k, 0, 1))) * CGFloat(lo.w) * 0.1
        let squash = k < 0.5 ? 1 - Self.ease(Self.span(k, 0.28, 0.48)) : Self.ease(Self.span(k, 0.52, 0.72))
        lo.fill(0x020403)
        lo.warp(from: src, amount: amp, stretch: CGFloat(0.3 * sin(.pi * k)), squash: CGFloat(squash), k: k)
        lo.grade(amount: Double(amp / (CGFloat(lo.w) * 0.1)) * 0.6)
        // The line it collapses to.
        let line = Self.bump(k, 0.4, 0.48, 0.52, 0.6)
        if line > 0 {
            let w = CGFloat(lo.w), h = CGFloat(lo.h)
            let half = w * CGFloat(0.5 * (1 - Self.span(k, 0.46, 0.5) * 0.4))
            lo.fill(0x9AF0C8, CGFloat(line * 0.4), CGRect(x: w / 2 - half, y: h / 2 - 2, width: half * 2, height: 5))
            lo.fill(0xF0FFF6, CGFloat(line), CGRect(x: w / 2 - half, y: h / 2, width: half * 2, height: 1))
        }
    }
}

// MARK: - The map

/// Where the places are, for the satellite: latitude and longitude, roughly (or where they'd be).
enum FilesMap {
    static let points: [Location: (lat: Double, lon: Double)] = [
        .xFilesOffice: (38.895, -77.025), .skinnardsOffice: (38.894, -77.024), .gunclawdsDen: (38.98, -77.0),
        .apartment42: (38.80, -77.05), .syndicateClub: (40.75, -73.98), .bellefleurWoods: (44.6, -123.4),
        .area51: (37.24, -115.81), .antarctic: (-75.5, -45.0), .quarantineCar: (38.7, -80.6), .toomsBlock: (39.29, -76.61),
        .newarkSewers: (40.73, -74.17), .gibsonton: (27.85, -82.38), .beeDomes: (29.6, -97.9), .lakeOkobogee: (31.3, -84.4),
        .mutatoFarm: (41.4, -85.4), .ruskinDam: (37.6, -79.6), .autopsyBay: (38.52, -77.3), .chaneyMotel: (33.6, -101.8),
        .reflectingPool: (38.889, -77.045), .mothership: (-73.0, -38.0),
    ]

    static func point(_ l: Location?) -> (lat: Double, lon: Double) {
        guard let l else { return (38.9, -77.0) }
        if let p = points[l] { return p }
        let h = abs(l.rawValue.hashValue % 1000)
        return (30 + Double(h % 17), -120 + Double(h % 43))
    }

    /// How far apart two places are, in degrees on the map.
    static func distance(_ a: (lat: Double, lon: Double), _ b: (lat: Double, lon: Double)) -> Double {
        hypot(a.lat - b.lat, a.lon - b.lon)
    }
    static func distance(_ a: Location, _ b: Location) -> Double { distance(point(a), point(b)) }

    /// 38°53'N 077°01'W.
    static func reading(_ p: (lat: Double, lon: Double)) -> String {
        func dm(_ v: Double, _ width: Int) -> String {
            let a = abs(v), d = Int(a), m = Int((a - Double(d)) * 60)
            return String(format: "%0\(width)d°%02d'", d, m)
        }
        return "\(dm(p.lat, 2))\(p.lat >= 0 ? "N" : "S") \(dm(p.lon, 3))\(p.lon >= 0 ? "E" : "W")"
    }
}

// MARK: - The typed caption

/// The place's name and where it is, typed in a letter at a time in a corner when the scene changes, the way every
/// scene opens in the show: "THE X-FILES OFFICE / FBI HEADQUARTERS, WASHINGTON, D.C.". The window and the screen saver
/// show it in place of the usual place name.
enum FilesCaption {
    static let cities: [Location: String] = [
        .xFilesOffice: "FBI HEADQUARTERS, WASHINGTON, D.C.", .skinnardsOffice: "FBI HEADQUARTERS, WASHINGTON, D.C.",
        .gunclawdsDen: "TAKOMA PARK, MARYLAND", .apartment42: "ALEXANDRIA, VIRGINIA", .syndicateClub: "46TH STREET, NEW YORK CITY",
        .bellefleurWoods: "BELLEFLEUR, OREGON", .area51: "GROOM LAKE, NEVADA", .antarctic: "WEDDELL SEA, ANTARCTICA",
        .quarantineCar: "SOMEWHERE IN WEST VIRGINIA", .toomsBlock: "BALTIMORE, MARYLAND", .newarkSewers: "NEWARK, NEW JERSEY",
        .gibsonton: "THE WINTER QUARTERS", .beeDomes: "BLACKWOOD, TEXAS", .lakeOkobogee: "OKOBOGEE COUNTY, GEORGIA",
        .mutatoFarm: "ALBION, INDIANA", .ruskinDam: "RUSKIN DAM, VIRGINIA", .autopsyBay: "QUANTICO, VIRGINIA",
        .chaneyMotel: "THE BLUE MOON MOTEL", .reflectingPool: "THE NATIONAL MALL, WASHINGTON, D.C.",
        .mothership: "ALTITUDE UNKNOWN",
    ]

    /// The two lines it types.
    static func lines(_ l: Location) -> [String] { [l.name.uppercased(), cities[l] ?? ""].filter { !$0.isEmpty } }

    /// Seconds a letter.
    static let letter = 0.05

    /// What's been typed `t` seconds after it started, line by line, with the cursor on the end while it types and
    /// for a few blinks after.
    static func typed(_ l: Location, after t: Double) -> [String] {
        var left = max(0, Int(t / letter))
        let all = lines(l)
        var out: [String] = []
        for line in all {
            let n = min(line.count, left)
            out.append(String(line.prefix(n)))
            left -= n
            if n < line.count { break }
        }
        let total = all.reduce(0) { $0 + $1.count }
        let blinking = Double(total) * letter + 1.6
        let cursor = t < blinking && Int(t * 4) % 2 == 0
        if cursor, !out.isEmpty { out[out.count - 1] += "\u{2588}" }
        return out
    }

    /// Whether it's done typing (and blinking) `t` seconds after it started.
    static func done(_ l: Location, after t: Double) -> Bool {
        t > Double(lines(l).reduce(0) { $0 + $1.count }) * letter + 1.7
    }

    /// The typewriter face.
    static func font(_ size: CGFloat) -> NSFont {
        NSFont(name: "AmericanTypewriter-Semibold", size: size) ?? NSFont(name: "Courier-Bold", size: size)
            ?? .monospacedSystemFont(ofSize: size, weight: .bold)
    }
}

// MARK: - The frame

/// A frame at one cell per art pixel: drawn into with Core Graphics (no smoothing), its pixels read and written too.
private final class Lo {
    let w: Int, h: Int, ctx: CGContext
    var rect: CGRect { CGRect(x: 0, y: 0, width: w, height: h) }

    init?(_ w: Int, _ h: Int) {
        guard let c = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                                space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              c.data != nil
        else { return nil }
        self.w = w; self.h = h; ctx = c
        c.interpolationQuality = .none
        c.setShouldAntialias(false)
    }

    /// RGBA, premultiplied, the top row first.
    private var bytes: UnsafeMutablePointer<UInt8> { ctx.data!.assumingMemoryBound(to: UInt8.self) }

    func fill(_ hex: UInt32, _ a: CGFloat = 1, _ r: CGRect? = nil) {
        ctx.setFillColor(rgb(hex, a)); ctx.fill(r ?? rect)
    }

    func image(_ img: CGImage, _ r: CGRect? = nil, alpha: CGFloat = 1) {
        guard alpha > 0.005 else { return }
        ctx.saveGState(); ctx.setAlpha(alpha); ctx.draw(img, in: r ?? rect); ctx.restoreGState()
    }

    /// `img` in black and white, at this frame's size.
    func greyed(_ img: CGImage) -> CGImage? {
        guard let g = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceGray(),
                                bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return nil }
        g.interpolationQuality = .none
        g.draw(img, in: rect)
        return g.makeImage()
    }

    private func line(_ s: String, size: CGFloat, colour: UInt32, alpha: CGFloat) -> CTLine {
        let font = CTFontCreateWithName("Courier-Bold" as CFString, size, nil)
        let attrs: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(kCTFontAttributeName as String): font,
            NSAttributedString.Key(kCTForegroundColorAttributeName as String): rgb(colour, alpha),
        ]
        return CTLineCreateWithAttributedString(NSAttributedString(string: s, attributes: attrs))
    }

    func textWidth(_ s: String, size: CGFloat) -> CGFloat {
        CGFloat(CTLineGetTypographicBounds(line(s, size: size, colour: 0, alpha: 1), nil, nil, nil))
    }

    /// Typewriter lettering, its baseline at `p`, unsmoothed so it stays in pixels.
    func text(_ s: String, size: CGFloat, at p: CGPoint, colour: UInt32, alpha: CGFloat = 1) {
        guard alpha > 0.01 else { return }
        ctx.saveGState()
        ctx.setShouldSmoothFonts(false); ctx.setAllowsFontSmoothing(false)
        ctx.textMatrix = .identity
        ctx.textPosition = p
        CTLineDraw(line(s, size: size, colour: colour, alpha: alpha), ctx)
        ctx.restoreGState()
    }

    /// Every pixel through `f` (red, green, blue, premultiplied, 0…255; x, y from the top).
    private func each(_ f: (inout Double, inout Double, inout Double, Int, Int) -> Void) {
        let p = bytes
        for y in 0..<h {
            for x in 0..<w {
                let i = (y * w + x) * 4
                var r = Double(p[i]), g = Double(p[i + 1]), b = Double(p[i + 2])
                f(&r, &g, &b, x, y)
                let a = Double(p[i + 3])
                p[i] = UInt8(max(0, min(a, r))); p[i + 1] = UInt8(max(0, min(a, g))); p[i + 2] = UInt8(max(0, min(a, b)))
            }
        }
    }

    /// Drains the colour toward the show's: cold, a little green, darker in the shadows.
    func grade(amount: Double) {
        guard amount > 0.01 else { return }
        each { r, g, b, _, _ in
            let l = 0.3 * r + 0.59 * g + 0.11 * b
            let d = l * l / 255
            r += (d * 0.8 - r) * amount; g += (d * 0.95 - g) * amount; b += (d * 0.9 - b) * amount
        }
    }

    /// Monochrome green, like a night-vision or satellite picture.
    func green(amount: Double) {
        guard amount > 0.01 else { return }
        each { r, g, b, _, _ in
            let l = 0.3 * r + 0.59 * g + 0.11 * b
            r += (l * 0.28 - r) * amount; g += (l * 0.92 + 14 - g) * amount; b += (l * 0.48 - b) * amount
        }
    }

    func grain(seed: Int, amount: Double) {
        each { r, g, b, x, y in
            let n = Double(hash(x, y, seed) % 64) / 63 - 0.5
            r += n * amount; g += n * amount; b += n * amount
        }
    }

    /// Television snow, `amount` of the way over the picture.
    func snow(seed: Int, amount: Double) {
        each { r, g, b, x, y in
            let n = Double(hash(x, y / 1, seed) % 256)
            let band = (y + seed * 7) % 37 < 3 ? 60.0 : 0
            r += (min(255, n + band) - r) * amount; g += (min(255, n + band) - g) * amount; b += (min(255, n + band) - b) * amount
        }
    }

    func scanlines(_ a: CGFloat) {
        for y in stride(from: 0, to: h, by: 2) { fill(0x000000, a, CGRect(x: 0, y: CGFloat(y), width: CGFloat(w), height: 1)) }
    }

    func vignette(_ amount: Double) {
        guard amount > 0.01 else { return }
        let cx = Double(w) / 2, cy = Double(h) / 2
        each { r, g, b, x, y in
            let dx = (Double(x) - cx) / cx, dy = (Double(y) - cy) / cy
            let m = 1 - amount * min(1, (dx * dx + dy * dy) * 0.5)
            r *= m; g *= m; b *= m
        }
    }

    /// Smoke's softness in pixels: each pixel's opacity stepped to a quarter, ordered-dithered between.
    func dither() {
        let bayer = [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]
        let p = bytes
        for y in 0..<h {
            for x in 0..<w {
                let i = (y * w + x) * 4
                let a = Double(p[i + 3])
                guard a > 0 else { continue }
                let q = a / 255 * 4, lowS = floor(q), frac = q - lowS
                let t = (Double(bayer[(y % 4) * 4 + x % 4]) + 0.5) / 16
                let na = min(4, frac > t ? lowS + 1 : lowS) / 4 * 255
                let m = na / a
                for c in 0..<3 { p[i + c] = UInt8(min(na, Double(p[i + c]) * m)) }
                p[i + 3] = UInt8(na)
            }
        }
    }

    /// The picture's rows torn sideways, bands of them, like a set losing horizontal hold.
    func tear(amount: CGFloat, k: Double) {
        guard amount >= 1 else { return }
        let copy = Array(UnsafeBufferPointer(start: bytes, count: w * h * 4))
        let p = bytes
        for y in 0..<h {
            let band = y / 3
            let shift = Int((sin(Double(y) * 0.13 + k * 40) * 0.6 + (noise(band * 7 + Int(k * 20)) - 0.5)) * Double(amount))
            for x in 0..<w {
                let sx = (x - shift + w * 4) % w
                let i = (y * w + x) * 4, j = (y * w + sx) * 4
                p[i] = copy[j]; p[i + 1] = copy[j + 1]; p[i + 2] = copy[j + 2]; p[i + 3] = copy[j + 3]
            }
        }
    }

    /// This frame's own picture warped (see the other `warp`).
    func warp(amount: CGFloat, stretch: CGFloat, k: Double) {
        guard let src = Lo(w, h), let img = ctx.makeImage() else { return }
        src.image(img)
        fill(0x020403)
        warp(from: src, amount: amount, stretch: stretch, squash: 1, k: k)
    }

    /// `src`'s rows slid sideways by up to `amount` and stretched about the middle by up to `stretch`, the whole
    /// squashed toward a line across the middle (`squash` 1 whole … 0 a line).
    func warp(from src: Lo, amount: CGFloat, stretch: CGFloat, squash: CGFloat, k: Double) {
        let p = bytes, s = src.bytes
        let cy = Double(h) / 2, cx = Double(w) / 2
        for y in 0..<h {
            let dy = Double(y) - cy
            guard squash > 0.01 else { break }
            let sy = Int((cy + dy / Double(squash) + sin(Double(y) * 0.05 + k * 9) * Double(amount) * 0.25).rounded())
            guard sy >= 0, sy < h else { continue }
            let band = y / 4
            let slide = sin(Double(y) * 0.11 + k * 17) * Double(amount) + (noise(band * 13 + Int(k * 12)) - 0.5) * Double(amount) * 0.8
            let wide = 1 + Double(stretch) * sin(Double(y) * 0.04 + k * 6)
            for x in 0..<w {
                let sx = Int((cx + (Double(x) - cx) / wide - slide).rounded())
                guard sx >= 0, sx < w else { continue }
                let i = (y * w + x) * 4, j = (sy * w + sx) * 4
                p[i] = s[j]; p[i + 1] = s[j + 1]; p[i + 2] = s[j + 2]; p[i + 3] = s[j + 3]
            }
        }
    }

    /// The map from orbit: land and sea and the odd cloud, centred on `centre`, `degreesPerPixel` across.
    func map(centre: (lat: Double, lon: Double), degreesPerPixel d: Double) {
        let p = bytes
        let detail = d < 0.01 ? 3.0 : 1.0
        for y in 0..<h {
            let lat = centre.lat + (Double(h) / 2 - Double(y)) * d
            for x in 0..<w {
                let lon = centre.lon + (Double(x) - Double(w) / 2) * d
                let land = valueNoise(lon * 0.07, lat * 0.07) * 0.8 + valueNoise(lon * 0.3 * detail, lat * 0.3 * detail) * 0.2
                let cloud = valueNoise(lon * 0.22 + 40, lat * 0.3 - 9)
                var r: Double, g: Double, b: Double
                if land > 0.5 {
                    let t = min(1, (land - 0.5) * 4)
                    r = 34 + 30 * t; g = 52 + 30 * t; b = 38 + 16 * t
                } else {
                    r = 12; g = 22 + 20 * land; b = 28 + 24 * land
                }
                if cloud > 0.78 { let c = min(1, (cloud - 0.78) * 6) * 0.7; r += (190 - r) * c; g += (200 - g) * c; b += (196 - b) * c }
                let i = (y * w + x) * 4
                p[i] = UInt8(r); p[i + 1] = UInt8(g); p[i + 2] = UInt8(b); p[i + 3] = 255
            }
        }
    }
}

/// Smooth noise in 0…1 over the plane.
private func valueNoise(_ x: Double, _ y: Double) -> Double {
    let xi = Int(floor(x)), yi = Int(floor(y))
    let fx = x - floor(x), fy = y - floor(y)
    let ux = fx * fx * (3 - 2 * fx), uy = fy * fy * (3 - 2 * fy)
    func corner(_ i: Int, _ j: Int) -> Double { Double(hash(i, j, 99) % 1000) / 999 }
    let top = corner(xi, yi) + (corner(xi + 1, yi) - corner(xi, yi)) * ux
    let bottom = corner(xi, yi + 1) + (corner(xi + 1, yi + 1) - corner(xi, yi + 1)) * ux
    return top + (bottom - top) * uy
}

/// A quick integer hash, never negative.
private func hash(_ x: Int, _ y: Int, _ s: Int) -> Int {
    var v = UInt32(truncatingIfNeeded: x &* 374_761_393 &+ y &* 668_265_263 &+ s &* 1_274_126_177)
    v = (v ^ (v >> 13)) &* 1_274_126_177
    return Int(v ^ (v >> 16))
}

/// Between two colours, 0xRRGGBB.
private func lerp(_ a: UInt32, _ b: UInt32, _ t: Double) -> UInt32 {
    func ch(_ s: UInt32) -> UInt32 {
        let x = Double(a >> s & 0xFF), y = Double(b >> s & 0xFF)
        return UInt32(x + (y - x) * t) << s
    }
    return ch(16) | ch(8) | ch(0)
}

/// A colour from 0xRRGGBB.
private func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
