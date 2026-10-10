import AppKit

/// Everything one card in the window shows about a Claude session.
struct CardModel {
    struct Agent {
        let name: String
        let task: String
        let detail: String
        let portrait: CGImage?
    }
    let villain: String
    let project: String
    let accent: NSColor
    let status: String
    let statusColor: NSColor
    let focused: Bool
    let lines: [(text: String, color: NSColor)]
    let agents: [Agent]
    let portrait: CGImage?
    let pid: Int32?
    var group: (title: String, color: NSColor)? = nil   // first card of an AI's group, when several AIs run
}

/// "Show in Window" mode: a normal window with the crew in a scene strip on top and a card per Claude
/// below. The crew is laid out and drawn by the same code as the desktop overlay; the scene strip just
/// acts as the "screen" they stand on.
final class ClawdWindow: NSObject, NSWindowDelegate {
    let window: NSWindow
    let sceneView = SceneView()
    let cardsView = CardsView()
    private let scroll = NSScrollView()
    let header = HeaderView()
    static let headerHeight: CGFloat = 30
    var onClose: (() -> Void)?
    var onGeometryChange: (() -> Void)?
    private(set) var sceneHeight: CGFloat

    init(controller: OverlayController, sceneHeight: CGFloat) {
        self.sceneHeight = sceneHeight
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 760, height: 620),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                          backing: .buffered, defer: false)
        super.init()
        window.title = "Clawd Wars"
        // Our own themed title bar instead of the system one; the traffic lights stay.
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        // Our header has its own close and minimize (which hides the list); no system traffic lights.
        for b in [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton] { window.standardWindowButton(b)?.isHidden = true }
        window.minSize = NSSize(width: 520, height: 240)
        window.backgroundColor = NSColor(srgbRed: 0.17, green: 0.13, blue: 0.10, alpha: 1)
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.setFrameAutosaveName("ClawdWarsWindow")
        if !window.setFrameUsingName("ClawdWarsWindow") { window.center() }

        sceneView.controller = controller
        cardsView.controller = controller

        let content = NSView(frame: NSRect(origin: .zero, size: window.frame.size))
        content.autoresizingMask = [.width, .height]
        window.contentView = content
        scroll.documentView = cardsView
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false
        scroll.autohidesScrollers = true
        // Overlay scrollers float over the cards instead of reserving a column for themselves.
        scroll.scrollerStyle = .overlay
        content.addSubview(sceneView)
        content.addSubview(scroll)
        content.addSubview(header)
        header.controller = controller
        layout()
        applyPin()
    }

    /// Make the window exactly as tall as the scene plus the cards (one per Claude), keeping its top edge
    /// where it is and never taller than the screen — past that the cards scroll.
    /// Settings → Show Session List in Window. Off: the window is just the header and the scene.
    static var listShown: Bool { UserDefaults.standard.object(forKey: "windowList") as? Bool ?? true }

    func fitToContent() {
        let top = Self.headerHeight + sceneHeight
        // Without the list the window is exactly header + scene, whatever "fit height" says.
        guard Self.listShown ? UserDefaults.standard.object(forKey: "autoHeight") as? Bool ?? true : true,
              !window.inLiveResize, let screen = window.screen ?? NSScreen.main else { return }
        let vf = screen.visibleFrame
        let wanted = Self.listShown ? min(max(top + cardsView.contentHeight, top + 60), vf.height) : top
        let delta = wanted - window.frame.height
        guard abs(delta) > 1 else { return }
        var f = window.frame
        f.size.height += delta
        f.origin.y -= delta
        if f.minY < vf.minY { f.origin.y = vf.minY }
        window.setFrame(f, display: true, animate: true)
    }

    var sceneScreenRect: NSRect { window.convertToScreen(sceneView.convert(sceneView.bounds, to: nil)) }

    func setSceneHeight(_ h: CGFloat) {
        sceneHeight = h
        if !Self.listShown { window.minSize.height = Self.headerHeight + h; window.maxSize.height = Self.headerHeight + h }
        layout()
    }

    /// Show or hide the session list (Settings → Show Session List in Window).
    func applyListShown() {
        let top = Self.headerHeight + sceneHeight
        scroll.isHidden = !Self.listShown
        window.minSize = NSSize(width: 520, height: Self.listShown ? 240 : top)
        window.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: Self.listShown ? .greatestFiniteMagnitude : top)
        if Self.listShown, !(UserDefaults.standard.object(forKey: "autoHeight") as? Bool ?? true) {
            // Back to the height it had before the list was hidden.
            let h = UserDefaults.standard.double(forKey: "windowListHeight")
            if h > top {
                var f = window.frame
                f.origin.y -= h - f.height
                f.size.height = h
                window.setFrame(f, display: true, animate: true)
            }
        }
        fitToContent()
    }

    private func layout() {
        guard let content = window.contentView else { return }
        let b = content.bounds
        let hh = Self.headerHeight
        header.frame = NSRect(x: 0, y: b.height - hh, width: b.width, height: hh)
        header.autoresizingMask = [.width, .minYMargin]
        sceneView.frame = NSRect(x: 0, y: b.height - hh - sceneHeight, width: b.width, height: sceneHeight)
        sceneView.autoresizingMask = [.width, .minYMargin]
        scroll.frame = NSRect(x: 0, y: 0, width: b.width, height: max(0, b.height - hh - sceneHeight))
        scroll.autoresizingMask = [.width, .height]
        cardsView.frame.size.width = scroll.bounds.width
    }

    /// Settings → Keep Window on Top.
    func applyPin() {
        let pinned = UserDefaults.standard.bool(forKey: "windowPinned")
        window.level = pinned ? .floating : .normal
        window.collectionBehavior = pinned ? [.canJoinAllSpaces, .fullScreenAuxiliary, .fullScreenNone] : [.fullScreenNone]
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        onClose?()          // closing the window goes back to the desktop overlay
        return false
    }

    func windowDidMove(_ notification: Notification) { onGeometryChange?() }
    func windowDidEndLiveResize(_ notification: Notification) { fitToContent() }
    func windowDidResize(_ notification: Notification) {
        scroll.scrollerStyle = .overlay          // the system can switch it back when a mouse is plugged in
        cardsView.frame.size.width = scroll.bounds.width
        cardsView.relayout()
        onGeometryChange?()
    }
}

/// The themed title bar: the location's colours and, on the right, where the crew is.
/// The traffic lights sit on its left; drag anywhere else on it to move the window.
final class HeaderView: NSView {
    weak var controller: OverlayController?
    var onClose: (() -> Void)?
    var onToggleList: (() -> Void)?

    static let yellow = NSColor(srgbRed: 1, green: 0.91, blue: 0.12, alpha: 1)   // the opening-crawl yellow

    private enum Button { case minimize, close }
    private var hovered: Button?
    private static let buttonSize: CGFloat = 22

    /// Our own buttons on the right (the system traffic lights are hidden): minimize, then close.
    private func rect(_ b: Button) -> NSRect {
        let s = Self.buttonSize, y = ((bounds.height - s) / 2).rounded()
        let closeX = bounds.width - 8 - s
        return NSRect(x: b == .close ? closeX : closeX - 4 - s, y: y, width: s, height: s)
    }

    private func button(at p: NSPoint) -> Button? {
        [Button.minimize, .close].first { rect($0).contains(p) }
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingAreas.forEach(removeTrackingArea)
        addTrackingArea(NSTrackingArea(rect: bounds, options: [.mouseMoved, .mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                                       owner: self))
        removeAllToolTips()
        addToolTip(rect(.close), owner: "Close the window (back to the desktop)" as NSString, userData: nil)
        addToolTip(rect(.minimize), owner: "Show or hide the session list" as NSString, userData: nil)
    }

    override func mouseMoved(with event: NSEvent) {
        let now = button(at: convert(event.locationInWindow, from: nil))
        if now != hovered { hovered = now; needsDisplay = true }
    }

    override func mouseExited(with event: NSEvent) {
        if hovered != nil { hovered = nil; needsDisplay = true }
    }

    override func draw(_ dirtyRect: NSRect) {
        let b = bounds
        let base = controller?.location.panel ?? NSColor(white: 0.12, alpha: 1)
        (base.blended(withFraction: 0.45, of: .black) ?? base).setFill()
        b.fill()
        // a faint highlight of the location's tone along the top
        (base.blended(withFraction: 0.15, of: .white) ?? base).withAlphaComponent(0.35).setFill()
        NSRect(x: 0, y: b.height - 1, width: b.width, height: 1).fill()
        // …and a matching edge along the bottom, so the bar visibly ends where the scene starts. Many scenes open with
        // a dark ceiling, which otherwise reads as part of the bar and makes its contents look off-centre.
        NSColor(white: 1, alpha: 0.16).setFill()
        NSRect(x: 0, y: 0, width: b.width, height: 1).fill()

        // Where the crew is, on the left.
        if let where_ = controller?.location.name {
            let label = NSAttributedString(string: where_.uppercased(), attributes: [
                .font: NSFont.systemFont(ofSize: 10.5, weight: .semibold), .foregroundColor: NSColor(white: 0.78, alpha: 1),
                .kern: 1.2])
            label.draw(at: NSPoint(x: 14, y: (b.height - label.size().height) / 2))
        }

        // Collapse to just the scene (arrows in) / back to the full view (arrows out), and close.
        let symbols: [(Button, String)] = [(.minimize, ClawdWindow.listShown ? "rectangle.compress.vertical" : "rectangle.expand.vertical"),
                                           (.close, "xmark")]
        for (button, name) in symbols {
            let r = rect(button)
            if hovered == button {
                (button == .close ? NSColor(srgbRed: 0.85, green: 0.25, blue: 0.25, alpha: 0.9) : NSColor(white: 1, alpha: 0.14)).setFill()
                NSBezierPath(roundedRect: r, xRadius: 5, yRadius: 5).fill()
            }
            let tint = NSColor(white: hovered == button ? 1 : 0.72, alpha: 1)
            if button == .close {
                // Drawn by hand, centred exactly on the bar: the xmark symbol's odd pixel height sat half a pixel low.
                let c = NSPoint(x: r.midX, y: b.height / 2), d: CGFloat = 4.5
                let x = NSBezierPath()
                x.move(to: NSPoint(x: c.x - d, y: c.y - d)); x.line(to: NSPoint(x: c.x + d, y: c.y + d))
                x.move(to: NSPoint(x: c.x - d, y: c.y + d)); x.line(to: NSPoint(x: c.x + d, y: c.y - d))
                x.lineWidth = 1.7
                x.lineCapStyle = .round
                tint.setStroke()
                x.stroke()
                continue
            }
            let config = NSImage.SymbolConfiguration(pointSize: 11, weight: .bold)
            guard let img = NSImage(systemSymbolName: name, accessibilityDescription: nil)?.withSymbolConfiguration(config) else { continue }
            let tinted = NSImage(size: img.size, flipped: false) { rr in
                img.draw(in: rr)
                tint.set()
                rr.fill(using: .sourceAtop)
                return true
            }
            tinted.draw(in: NSRect(x: (r.midX - img.size.width / 2).rounded(), y: (r.midY - img.size.height / 2).rounded(),
                                   width: img.size.width, height: img.size.height))
        }
    }

    override func mouseDown(with event: NSEvent) {
        switch button(at: convert(event.locationInWindow, from: nil)) {
        case .close?: onClose?()
        case .minimize?: onToggleList?(); needsDisplay = true
        case nil: window?.performDrag(with: event)
        }
    }
}

/// The scene strip: the Mos Eisley cantina, with the crew standing on its floor.
final class SceneView: NSView {
    weak var controller: OverlayController?
    private var room: (size: NSSize, location: Location, image: CGImage)?

    override var isFlipped: Bool { false }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext, let controller else { return }
        let b = bounds
        let p = Cantina.pixel
        let pw = Int((b.width / p).rounded(.up)), ph = Int((b.height / p).rounded(.up))
        let floorRows = Int((OverlayController.cantinaFloor / p).rounded())
        let drawRect = CGRect(x: 0, y: 0, width: CGFloat(pw) * p, height: CGFloat(ph) * p)
        ctx.interpolationQuality = .none

        // The place only changes when the window is resized or the location changes.
        let location = controller.location
        if room?.location != location && location == .cantina { Cantina.maxReboTonight = Bool.random() }   // a new night
        if room?.size != b.size || room?.location != location {
            let c = PixelCanvas(pw, ph)
            location.drawStatic(c, floorRows: floorRows)
            if let img = c.makeImage() { room = (b.size, location, img) }
        }
        if let img = room?.image { ctx.draw(img, in: drawRect) }

        // Whatever moves there: the cantina band, sarlacc tentacles, torches, laser gates, fog…
        let live = PixelCanvas(pw, ph)
        location.drawAnimated(live, floorRows: floorRows, t: Date().timeIntervalSince1970)
        if let img = live.makeImage() { ctx.draw(img, in: drawRect) }

        guard let window else { return }
        let origin = window.convertToScreen(convert(bounds, to: nil)).origin
        OverlayView.render(controller.items, origin: origin, in: ctx)
    }

    override func mouseUp(with event: NSEvent) {
        guard let window else { return }
        let p = window.convertPoint(toScreen: event.locationInWindow)
        controller?.click(at: p)
    }

    override func rightMouseDown(with event: NSEvent) {
        guard let controller else { return }
        NSMenu.popUpContextMenu(controller.menu(), with: event, for: self)
    }
}

/// One card per Claude: status and how long, what it's doing, your last prompt, its last reply, and its agents.
final class CardsView: NSView {
    weak var controller: OverlayController?
    private var cards: [CardModel] = []
    private var banner: String?
    private var hitRects: [(NSRect, Int32?)] = []
    /// Height the cards actually need (the window sizes itself to this).
    private(set) var contentHeight: CGFloat = 0

    override var isFlipped: Bool { true }

    func update(cards: [CardModel], banner: String?) {
        self.cards = cards
        self.banner = banner
        relayout()
    }

    private static let pad: CGFloat = 12
    private static let portraitScale: CGFloat = 2          // portraits are cropped to 46×38 sprite pixels
    // Measured: the widest portrait is the AT-AT (53 px), the tallest the Rancor (42 px) — both fit at 2×.
    private static let portraitSize = NSSize(width: 56 * portraitScale, height: 43 * portraitScale)
    private static let lineH: CGFloat = 16
    private static let agentH: CGFloat = 34
    private static let groupH: CGFloat = 22

    private func cardHeight(_ c: CardModel) -> CGFloat {
        let text = 22 + CGFloat(c.lines.count) * Self.lineH + (c.agents.isEmpty ? 0 : 6 + CGFloat(c.agents.count) * Self.agentH)
        return max(Self.portraitSize.height + 4, text) + Self.pad * 2
    }

    func relayout() {
        var h = Self.pad + (banner == nil ? 0 : 34)
        for c in cards { h += cardHeight(c) + 10 + (c.group == nil ? 0 : Self.groupH) }
        if cards.isEmpty { h += 30 }
        contentHeight = h
        let minH = enclosingScrollView?.bounds.height ?? 0
        setFrameSize(NSSize(width: frame.width, height: max(h, minH)))
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        ctx.interpolationQuality = .none
        hitRects = []
        // The location's tone, with a faint texture, so the whole window feels like the place.
        let panel = controller?.location.panel ?? NSColor(srgbRed: 0.17, green: 0.13, blue: 0.10, alpha: 1)
        panel.setFill()
        bounds.fill()
        for i in 0..<Int(bounds.width * bounds.height / 260) {
            let x = noise(i * 13) * Double(bounds.width), y = noise(i * 13 + 1) * Double(bounds.height)
            (noise(i * 13 + 2) > 0.5 ? panel.blended(withFraction: 0.12, of: .white)
                                     : panel.blended(withFraction: 0.25, of: .black))?.setFill()
            NSRect(x: CGFloat(x).rounded(), y: CGFloat(y).rounded(), width: 2, height: 2).fill()
        }
        var y = Self.pad
        let x = Self.pad, w = bounds.width - Self.pad * 2

        if let banner {
            let r = NSRect(x: x, y: y, width: w, height: 26)
            NSColor(srgbRed: 0.35, green: 0.08, blue: 0.10, alpha: 1).setFill()
            NSBezierPath(roundedRect: r, xRadius: 6, yRadius: 6).fill()
            draw(banner, at: NSPoint(x: r.minX + 10, y: r.minY + 5), width: r.width - 20,
                 font: .systemFont(ofSize: 12, weight: .semibold), color: NSColor(srgbRed: 1, green: 0.7, blue: 0.7, alpha: 1))
            y += 34
        }
        if cards.isEmpty {
            draw("No Claude sessions running.", at: NSPoint(x: x + 4, y: y + 4), width: w,
                 font: .systemFont(ofSize: 13), color: .secondaryLabelColor)
        }

        for c in cards {
            if let g = c.group {
                // A small divider naming the AI: "CODEX ─────"
                let t = NSAttributedString(string: g.title.uppercased(), attributes: [
                    .font: NSFont.systemFont(ofSize: 10.5, weight: .heavy), .kern: 1.2, .foregroundColor: g.color])
                let ts = t.size()
                t.draw(at: NSPoint(x: x + 2, y: y + 2))
                g.color.withAlphaComponent(0.35).setFill()
                NSRect(x: x + ts.width + 10, y: (y + 2 + ts.height / 2).rounded(), width: w - ts.width - 12, height: 1).fill()
                y += Self.groupH
            }
            let h = cardHeight(c)
            let r = NSRect(x: x, y: y, width: w, height: h)
            hitRects.append((r, c.pid))
            let box = NSBezierPath(roundedRect: r, xRadius: 8, yRadius: 8)
            (controller?.location.panel.blended(withFraction: 0.35, of: .black) ?? NSColor.black).withAlphaComponent(0.94).setFill()
            box.fill()
            (c.focused ? NSColor(srgbRed: 1, green: 0.88, blue: 0.29, alpha: 0.9) : c.accent.withAlphaComponent(0.55)).setStroke()
            box.lineWidth = c.focused ? 2 : 1
            box.stroke()

            // Portrait (drawn upright: this view is flipped)
            let pw = Self.portraitSize.width, ph = Self.portraitSize.height
            if let img = c.portrait {
                draw(img, fitting: NSRect(x: r.minX + 10, y: r.minY + Self.pad, width: pw, height: ph), in: ctx, maxScale: 2)
            }

            let tx = r.minX + 16 + pw, tw = r.maxX - tx - 12
            var ty = r.minY + Self.pad
            // Header: villain · project, status on the right
            let status = NSAttributedString(string: c.status, attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .bold), .foregroundColor: c.statusColor])
            let sw = status.size().width
            let chip = NSRect(x: r.maxX - 12 - sw - 14, y: ty - 1, width: sw + 14, height: 19)
            c.statusColor.withAlphaComponent(0.16).setFill()
            NSBezierPath(roundedRect: chip, xRadius: 9.5, yRadius: 9.5).fill()
            status.draw(at: NSPoint(x: chip.minX + 7, y: chip.minY + 2))
            let header = NSMutableAttributedString(string: c.villain, attributes: [
                .font: NSFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: NSColor.white])
            if !c.project.isEmpty {
                header.append(NSAttributedString(string: "  ·  " + c.project, attributes: [
                    .font: NSFont.systemFont(ofSize: 13, weight: .semibold), .foregroundColor: c.accent]))
            }
            if c.focused {
                header.append(NSAttributedString(string: "   ◆ you're here", attributes: [
                    .font: NSFont.systemFont(ofSize: 11, weight: .semibold),
                    .foregroundColor: NSColor(srgbRed: 1, green: 0.88, blue: 0.29, alpha: 1)]))
            }
            header.draw(with: NSRect(x: tx, y: ty, width: chip.minX - tx - 8, height: 20),
                        options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine])
            ty += 22

            for line in c.lines {
                draw(line.text, at: NSPoint(x: tx, y: ty), width: tw, font: .systemFont(ofSize: 11.5), color: line.color)
                ty += Self.lineH
            }

            if !c.agents.isEmpty {
                ty += 6
                for a in c.agents {
                    if let img = a.portrait {
                        draw(img, fitting: NSRect(x: tx - 4, y: ty, width: 36, height: 30), in: ctx, maxScale: 1)
                    }
                    let ax = tx + 40
                    let title = NSMutableAttributedString(string: a.name, attributes: [
                        .font: NSFont.systemFont(ofSize: 11.5, weight: .semibold), .foregroundColor: NSColor.white])
                    title.append(NSAttributedString(string: "  —  " + a.task, attributes: [
                        .font: NSFont.systemFont(ofSize: 11.5), .foregroundColor: c.accent]))
                    title.draw(with: NSRect(x: ax, y: ty + 1, width: tw - 40, height: 16),
                               options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine])
                    draw(a.detail, at: NSPoint(x: ax, y: ty + 17), width: tw - 40,
                         font: .systemFont(ofSize: 10.5), color: NSColor(white: 0.62, alpha: 1))
                    ty += Self.agentH
                }
            }
            y += h + 10
        }
    }

    /// Draw a pixel-art portrait as large as fits in `box` (never above `maxScale`), centred at the
    /// bottom of the box, upright in this flipped view. Whole-number scales keep the pixels crisp.
    private func draw(_ img: CGImage, fitting box: NSRect, in ctx: CGContext, maxScale: CGFloat) {
        let iw = CGFloat(img.width), ih = CGFloat(img.height)
        var k = min(box.width / iw, box.height / ih, maxScale)
        if k >= 1 { k = k.rounded(.down) }
        let w = iw * k, h = ih * k
        ctx.saveGState()
        ctx.interpolationQuality = .none
        ctx.translateBy(x: (box.midX - w / 2).rounded(), y: box.maxY)
        ctx.scaleBy(x: 1, y: -1)
        ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
        ctx.restoreGState()
    }

    private func draw(_ s: String, at p: NSPoint, width: CGFloat, font: NSFont, color: NSColor) {
        let para = NSMutableParagraphStyle()
        para.lineBreakMode = .byTruncatingTail
        NSAttributedString(string: s, attributes: [.font: font, .foregroundColor: color, .paragraphStyle: para])
            .draw(with: NSRect(x: p.x, y: p.y, width: width, height: font.pointSize + 6),
                  options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine])
    }

    override func mouseUp(with event: NSEvent) {
        let p = convert(event.locationInWindow, from: nil)
        guard let hit = hitRects.first(where: { $0.0.contains(p) }) else { return }
        if let pid = hit.1 { Jump.toSession(pid: pid) } else { NSSound.beep() }
    }

    override func resetCursorRects() {
        for (r, pid) in hitRects where pid != nil { addCursorRect(r, cursor: .pointingHand) }
    }

    override func rightMouseDown(with event: NSEvent) {
        guard let controller else { return }
        NSMenu.popUpContextMenu(controller.menu(), with: event, for: self)
    }
}
