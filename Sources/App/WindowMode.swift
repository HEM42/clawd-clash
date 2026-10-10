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
        window.minSize = NSSize(width: 520, height: 380)
        window.backgroundColor = NSColor(srgbRed: 0.055, green: 0.063, blue: 0.125, alpha: 1)
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

/// The scene strip: a starfield with a horizon, and the crew standing on it.
final class SceneView: NSView {
    weak var controller: OverlayController?

    override var isFlipped: Bool { false }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext, let controller else { return }
        let b = bounds
        let space = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                               colors: [CGColor(red: 0.16, green: 0.10, blue: 0.30, alpha: 1),
                                        CGColor(red: 0.03, green: 0.04, blue: 0.10, alpha: 1)] as CFArray,
                               locations: [0, 1])!
        ctx.drawLinearGradient(space, start: CGPoint(x: 0, y: b.maxY), end: CGPoint(x: 0, y: b.minY), options: [])
        let floor = controller.windowFloor
        for i in 0..<Int(b.width / 9) {
            let x = noise(i * 3) * Double(b.width), y = Double(floor + 6) + noise(i * 3 + 1) * Double(b.height - floor - 6)
            let big = noise(i * 3 + 2) > 0.85
            ctx.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: big ? 0.9 : 0.45))
            let s: CGFloat = big ? 3 : 2
            ctx.fill(CGRect(x: CGFloat(x).rounded(), y: CGFloat(y).rounded(), width: s, height: s))
        }
        ctx.setFillColor(CGColor(red: 0.10, green: 0.10, blue: 0.16, alpha: 1))
        ctx.fill(CGRect(x: 0, y: 0, width: b.width, height: floor))
        ctx.setFillColor(CGColor(red: 0.85, green: 0.47, blue: 0.34, alpha: 1))
        ctx.fill(CGRect(x: 0, y: floor - 2, width: b.width, height: 2))

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
        let minH = enclosingScrollView?.contentSize.height ?? 0
        setFrameSize(NSSize(width: frame.width, height: max(h, minH)))
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        ctx.interpolationQuality = .none
        hitRects = []
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
            NSColor(srgbRed: 0.085, green: 0.095, blue: 0.16, alpha: 1).setFill()
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
