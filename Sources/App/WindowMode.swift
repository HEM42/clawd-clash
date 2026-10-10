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
}

/// "Show in Window" mode: a normal window with the crew in a scene strip on top and a card per Claude
/// below. The crew is laid out and drawn by the same code as the desktop overlay; the scene strip just
/// acts as the "screen" they stand on.
final class ClawdWindow: NSObject, NSWindowDelegate {
    let window: NSWindow
    let sceneView = SceneView()
    let cardsView = CardsView()
    private let scroll = NSScrollView()
    private let pin = NSButton(checkboxWithTitle: "Keep on top", target: nil, action: nil)
    var onClose: (() -> Void)?
    var onGeometryChange: (() -> Void)?
    private(set) var sceneHeight: CGFloat

    init(controller: OverlayController, sceneHeight: CGFloat) {
        self.sceneHeight = sceneHeight
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 760, height: 620),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)
        super.init()
        window.title = "Clawd Wars"
        window.minSize = NSSize(width: 520, height: 240)
        window.backgroundColor = NSColor(srgbRed: 0.17, green: 0.13, blue: 0.10, alpha: 1)
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.setFrameAutosaveName("ClawdWarsWindow")
        if !window.setFrameUsingName("ClawdWarsWindow") { window.center() }

        sceneView.controller = controller
        cardsView.controller = controller

        let content = NSView(frame: window.contentLayoutRect)
        content.autoresizingMask = [.width, .height]
        window.contentView = content
        scroll.documentView = cardsView
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false
        scroll.autohidesScrollers = true
        content.addSubview(sceneView)
        content.addSubview(scroll)
        layout()

        pin.target = self
        pin.action = #selector(togglePin)
        pin.state = UserDefaults.standard.bool(forKey: "windowPinned") ? .on : .off
        pin.controlSize = .small
        let accessory = NSTitlebarAccessoryViewController()
        let holder = NSView(frame: NSRect(x: 0, y: 0, width: 110, height: 22))
        pin.frame = NSRect(x: 4, y: 2, width: 104, height: 18)
        holder.addSubview(pin)
        accessory.view = holder
        accessory.layoutAttribute = .trailing
        window.addTitlebarAccessoryViewController(accessory)
        applyPin()
    }

    /// Make the window exactly as tall as the scene plus the cards (one per Claude), keeping its top edge
    /// where it is and never taller than the screen — past that the cards scroll.
    func fitToContent() {
        guard let screen = window.screen ?? NSScreen.main else { return }
        let chrome = window.frame.height - window.contentLayoutRect.height       // title bar
        let vf = screen.visibleFrame
        let wanted = min(max(sceneHeight + cardsView.contentHeight, sceneHeight + 60), vf.height - chrome)
        let delta = wanted - window.contentLayoutRect.height
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
        layout()
    }

    private func layout() {
        guard let content = window.contentView else { return }
        let b = content.bounds
        sceneView.frame = NSRect(x: 0, y: b.height - sceneHeight, width: b.width, height: sceneHeight)
        sceneView.autoresizingMask = [.width, .minYMargin]
        scroll.frame = NSRect(x: 0, y: 0, width: b.width, height: max(0, b.height - sceneHeight))
        scroll.autoresizingMask = [.width, .height]
        cardsView.frame.size.width = scroll.contentSize.width
    }

    @objc private func togglePin() {
        UserDefaults.standard.set(pin.state == .on, forKey: "windowPinned")
        applyPin()
    }

    private func applyPin() {
        window.level = pin.state == .on ? .floating : .normal
        window.collectionBehavior = pin.state == .on ? [.canJoinAllSpaces, .fullScreenAuxiliary] : []
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        onClose?()          // closing the window goes back to the desktop overlay
        return false
    }

    func windowDidMove(_ notification: Notification) { onGeometryChange?() }
    func windowDidResize(_ notification: Notification) {
        cardsView.frame.size.width = scroll.contentSize.width
        cardsView.relayout()
        onGeometryChange?()
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
    private static let portraitSize = NSSize(width: 46 * portraitScale, height: 38 * portraitScale)
    private static let lineH: CGFloat = 16
    private static let agentH: CGFloat = 34

    private func cardHeight(_ c: CardModel) -> CGFloat {
        let text = 22 + CGFloat(c.lines.count) * Self.lineH + (c.agents.isEmpty ? 0 : 6 + CGFloat(c.agents.count) * Self.agentH)
        return max(Self.portraitSize.height + 4, text) + Self.pad * 2
    }

    func relayout() {
        var h = Self.pad + (banner == nil ? 0 : 34)
        for c in cards { h += cardHeight(c) + 10 }
        if cards.isEmpty { h += 30 }
        contentHeight = h
        let minH = enclosingScrollView?.contentSize.height ?? 0
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
            let h = cardHeight(c)
            let r = NSRect(x: x, y: y, width: w, height: h)
            hitRects.append((r, c.pid))
            let box = NSBezierPath(roundedRect: r, xRadius: 8, yRadius: 8)
            (controller?.location.panel.blended(withFraction: 0.35, of: .black) ?? NSColor.black).withAlphaComponent(0.94).setFill()
            box.fill()
            (c.focused ? NSColor(srgbRed: 1, green: 0.88, blue: 0.29, alpha: 0.9) : c.accent.withAlphaComponent(0.55)).setStroke()
            box.lineWidth = c.focused ? 2 : 1
            box.stroke()
            c.accent.setFill()
            NSBezierPath(roundedRect: NSRect(x: r.minX, y: r.minY, width: 5, height: r.height), xRadius: 2.5, yRadius: 2.5).fill()

            // Portrait (drawn upright: this view is flipped)
            let pw = Self.portraitSize.width, ph = Self.portraitSize.height
            if let img = c.portrait {
                ctx.saveGState()
                ctx.translateBy(x: r.minX + 10, y: r.minY + Self.pad + ph)
                ctx.scaleBy(x: 1, y: -1)
                ctx.draw(img, in: CGRect(x: 0, y: 0, width: pw, height: ph))
                ctx.restoreGState()
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
                        ctx.saveGState()
                        ctx.translateBy(x: tx - 4, y: ty + 30)
                        ctx.scaleBy(x: 1, y: -1)
                        ctx.draw(img, in: CGRect(x: 0, y: 0, width: 36, height: 30))
                        ctx.restoreGState()
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
