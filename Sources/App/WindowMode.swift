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
    var spriteColor = NSColor.white                     // the character's main colour, for the name pill
    var remote: String? = nil                           // "GitHub", "GitLab"… or "Local", in a pill by the name
    /// One of several sessions in the same project, drawn on a tree under a project header.
    struct Tree: Equatable {
        let sessions: Int?   // on the first card only: the header goes above it, saying how many there are
        let last: Bool       // the last card, where the tree line ends (└)
    }
    var tree: Tree? = nil
    var id = ""                                         // the session's id: which cards have their agents unfolded

    /// The card's visible content as text (portraits are cached per character, so the villain's name stands in).
    var signature: String {
        var parts = [id, villain, project, accent.description, status, statusColor.description, "\(focused)", "\(pid ?? 0)",
                     group?.title ?? "", remote ?? "", tree.map { "\($0.sessions ?? 0)/\($0.last)" } ?? ""]
        parts += lines.map { $0.text + "\u{2}" + $0.color.description }
        parts += agents.map { $0.name + "\u{2}" + $0.task + "\u{2}" + $0.detail }
        return parts.joined(separator: "\u{3}")
    }
}

/// "Show in Window" mode: a normal window with the crew in a scene strip on top and a card per Claude
/// below. The crew is laid out and drawn by the same code as the desktop overlay; the scene strip just
/// acts as the "screen" they stand on.
final class ClawdWindow: NSObject, NSWindowDelegate {
    let window: NSWindow
    let sceneView = SceneView()
    let roomView = RoomView()
    let cardsView = CardsView()
    private let scroll = NSScrollView()
    let header = HeaderView()
    static let headerHeight: CGFloat = 30
    /// Settings → Small Window: the whole window — header, scene, characters, cards — drawn at 75%. Every view keeps
    /// its normal (logical) size in its bounds and is shown in a frame `scale` times as big.
    static var scale: CGFloat { UserDefaults.standard.bool(forKey: "windowSmall") ? 0.75 : 1 }
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
        window.minSize = NSSize(width: 520 * Self.scale, height: 240 * Self.scale)
        window.backgroundColor = NSColor(srgbRed: 0.17, green: 0.13, blue: 0.10, alpha: 1)
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.setFrameAutosaveName("ClawdWarsWindow")
        if !window.setFrameUsingName("ClawdWarsWindow") { window.center() }

        sceneView.controller = controller
        cardsView.controller = controller
        cardsView.onHeightChange = { [weak self] in self?.fitToContent() }

        let content = NSView(frame: NSRect(origin: .zero, size: window.frame.size))
        content.autoresizingMask = [.width, .height]
        window.contentView = content
        scroll.documentView = cardsView
        scroll.hasVerticalScroller = true
        scroll.drawsBackground = false
        scroll.autohidesScrollers = true
        // A real scrollbar, shown whenever the list is longer than the window (past three sessions with fit height):
        // overlay scrollers only appear while scrolling, so nothing said there were more. Dark, to sit on the panel.
        scroll.scrollerStyle = .legacy
        let scroller = ThemedScroller()
        scroller.panel = { [weak controller] in controller?.location.panel }
        scroll.verticalScroller = scroller
        // The scrollbar takes a column when it appears, so the cards follow the visible width.
        scroll.contentView.postsFrameChangedNotifications = true
        NotificationCenter.default.addObserver(forName: NSView.frameDidChangeNotification, object: scroll.contentView,
                                               queue: .main) { [weak self] _ in self?.fitCardsWidth() }
        sceneView.wantsLayer = true    // `showFrame` hands its sprites to this layer
        content.addSubview(roomView)   // behind the scene: the place itself, redrawn only when it changes
        content.addSubview(sceneView)
        sceneView.roomView = roomView
        content.addSubview(scroll)
        content.addSubview(header)
        header.controller = controller
        header.scene = sceneView
        sceneView.onDarkTopChange = { [weak self] in self?.header.needsDisplay = true }
        layout()
        applyPin()
    }

    /// Make the window exactly as tall as the scene plus the cards (one per Claude), keeping its top edge
    /// where it is and never taller than the screen — past that the cards scroll.
    /// Settings → Show Session List in Window. Off: the window is just the header and the scene.
    static var listShown: Bool { UserDefaults.standard.object(forKey: "windowList") as? Bool ?? true }
    /// How many session cards "fit height" makes room for before the list scrolls.
    static let cardsShown = 3

    func fitToContent() {
        let k = Self.scale
        let top = (Self.headerHeight + sceneHeight) * k
        // Without the list the window is exactly header + scene, whatever "fit height" says.
        guard Self.listShown ? UserDefaults.standard.object(forKey: "autoHeight") as? Bool ?? true : true,
              !window.inLiveResize, let screen = window.screen ?? NSScreen.main else { return }
        let vf = screen.visibleFrame
        // Up to three sessions fit; more scroll, with a sliver of the next card showing so it's clear there are more.
        let list = min(cardsView.contentHeight, cardsView.height(showingCards: Self.cardsShown), cardsView.maxListHeight)
        let wanted = Self.listShown ? min(max(top + list, top + 60), vf.height) : top
        let delta = wanted - window.frame.height
        guard abs(delta) > 1 else { return }
        var f = window.frame
        f.size.height += delta
        f.origin.y -= delta
        window.setFrame(onScreen(f), display: true, animate: true)
    }

    /// Grows downward from where the window is, but never past the screen: a window parked at the bottom grows
    /// upward instead, and nothing gets taller than the screen.
    private func onScreen(_ frame: NSRect) -> NSRect {
        guard let vf = (window.screen ?? NSScreen.main)?.visibleFrame else { return frame }
        var f = frame
        f.size.height = min(f.height, vf.height)
        if f.minY < vf.minY { f.origin.y = vf.minY }
        if f.maxY > vf.maxY { f.origin.y = vf.maxY - f.height }
        return f
    }

    /// The stage the crew is laid out on: where the scene sits on screen, at its logical (unscaled) size.
    var sceneScreenRect: NSRect {
        NSRect(origin: window.convertToScreen(sceneView.convert(sceneView.bounds, to: nil)).origin, size: sceneView.bounds.size)
    }

    /// A point on screen, in the stage's logical coordinates (for hovering and clicking characters).
    func toStage(_ p: NSPoint) -> NSPoint {
        let o = sceneScreenRect.origin, k = Self.scale
        return NSPoint(x: o.x + (p.x - o.x) / k, y: o.y + (p.y - o.y) / k)
    }

    func setSceneHeight(_ h: CGFloat) {
        sceneHeight = h
        let top = (Self.headerHeight + h) * Self.scale
        if !Self.listShown { window.minSize.height = top; window.maxSize.height = top }
        layout()
    }

    /// Show or hide the session list (Settings → Show Session List in Window).
    func applyListShown() {
        let top = (Self.headerHeight + sceneHeight) * Self.scale
        scroll.isHidden = !Self.listShown
        window.minSize = NSSize(width: 520 * Self.scale, height: Self.listShown ? 240 * Self.scale : top)
        window.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: Self.listShown ? .greatestFiniteMagnitude : top)
        if Self.listShown, !(UserDefaults.standard.object(forKey: "autoHeight") as? Bool ?? true) {
            // Back to the height it had before the list was hidden.
            let h = UserDefaults.standard.double(forKey: "windowListHeight")
            if h > top {
                var f = window.frame
                f.origin.y -= h - f.height
                f.size.height = h
                window.setFrame(onScreen(f), display: true, animate: true)
            }
        }
        fitToContent()
    }

    private func layout() {
        guard let content = window.contentView else { return }
        let b = content.bounds, k = Self.scale
        let hh = Self.headerHeight * k, sh = sceneHeight * k
        header.frame = NSRect(x: 0, y: b.height - hh, width: b.width, height: hh)
        header.autoresizingMask = [.width, .minYMargin]
        sceneView.frame = NSRect(x: 0, y: b.height - hh - sh, width: b.width, height: sh)
        sceneView.autoresizingMask = [.width, .minYMargin]
        roomView.frame = sceneView.frame
        roomView.autoresizingMask = sceneView.autoresizingMask
        scroll.frame = NSRect(x: 0, y: 0, width: b.width, height: max(0, b.height - hh - sh))
        scroll.autoresizingMask = [.width, .height]
        applyScale()
    }

    /// Keep each view's logical size in its bounds, `1 / scale` times its frame, after any resize.
    private func applyScale() {
        let k = Self.scale
        header.setBoundsSize(NSSize(width: header.frame.width / k, height: Self.headerHeight))
        sceneView.setBoundsSize(NSSize(width: sceneView.frame.width / k, height: sceneHeight))
        roomView.setBoundsSize(sceneView.bounds.size)
        cardsView.frame.size.width = scroll.contentView.bounds.width
        cardsView.relayout()   // always: the Small Window changes the cards' heights, not just their width
        header.needsDisplay = true; sceneView.showFrame()
    }

    /// The scrollbar's track takes the location's colour.
    func redrawScroller() { scroll.verticalScroller?.needsDisplay = true }

    private func fitCardsWidth() {
        let w = scroll.contentView.bounds.width
        guard cardsView.frame.width != w else { return }
        cardsView.frame.size.width = w
        cardsView.relayout()
    }

    /// Settings → Small Window toggled: the window itself shrinks (or grows back) by the same factor, keeping its top
    /// left corner, then the layout is redone at the new scale and refit.
    func applySmall() {
        let factor = Self.scale < 1 ? 0.75 : 1 / 0.75
        var f = window.frame
        let top = f.maxY
        f.size.width = (f.width * factor).rounded()
        f.size.height = (f.height * factor).rounded()
        f.origin.y = top - f.height
        window.minSize = NSSize(width: 520 * Self.scale, height: 0)          // let it shrink below the old minimum
        window.setFrame(onScreen(f), display: true, animate: true)
        window.minSize = NSSize(width: 520 * Self.scale, height: Self.listShown ? 240 * Self.scale : (Self.headerHeight + sceneHeight) * Self.scale)
        if !Self.listShown { window.maxSize.height = (Self.headerHeight + sceneHeight) * Self.scale }
        layout()
        header.updateTrackingAreas()
        onGeometryChange?()
        fitToContent()
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
        scroll.scrollerStyle = .legacy           // the system can switch it back when the trackpad/mouse changes
        applyScale()
        onGeometryChange?()
    }
}

/// The cards' scrollbar, quiet and in the location's colours: the track is the cards' own panel colour (so it reads
/// as part of the list, not a column beside it) and the knob a thin, faint bar.
final class ThemedScroller: NSScroller {
    var panel: () -> NSColor? = { nil }

    override class var isCompatibleWithOverlayScrollers: Bool { false }
    override class func scrollerWidth(for controlSize: NSControl.ControlSize, scrollerStyle: NSScroller.Style) -> CGFloat { 10 }

    override func drawKnobSlot(in slotRect: NSRect, highlight flag: Bool) {
        (panel() ?? NSColor(srgbRed: 0.17, green: 0.13, blue: 0.10, alpha: 1)).setFill()
        bounds.fill()
    }

    override func drawKnob() {
        let r = rect(for: .knob).insetBy(dx: 2.5, dy: 4)
        guard r.height > 0 else { return }
        NSColor(white: 1, alpha: 0.16).setFill()
        NSBezierPath(roundedRect: r, xRadius: r.width / 2, yRadius: r.width / 2).fill()
    }
}

/// The themed title bar: the location's colours and, on the right, where the crew is.
/// The traffic lights sit on its left; drag anywhere else on it to move the window.
final class HeaderView: NSView {
    weak var controller: OverlayController?
    weak var scene: SceneView?
    var onClose: (() -> Void)?
    var onToggleList: (() -> Void)?

    static let yellow = NSColor(srgbRed: 1, green: 0.91, blue: 0.12, alpha: 1)   // the opening-crawl yellow

    private enum Button { case minimize, close }
    private var hovered: Button?
    private static let buttonSize: CGFloat = 20

    /// The vertical centre of the bar as you see it. Some scenes start with a dark ceiling (the cantina's beam) that
    /// reads as part of the bar, so centre on bar + that band rather than on the bar alone.
    private var midY: CGFloat { (bounds.height - min(scene?.darkTop ?? 0, 10)) / 2 }

    /// Our own buttons on the right (the system traffic lights are hidden): minimize, then close.
    private func rect(_ b: Button) -> NSRect {
        let s = Self.buttonSize, y = (midY - s / 2).rounded()
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
        addToolTip(rect(.close), owner: "Quit Clawd Wars" as NSString, userData: nil)
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

        // Where the crew is, on the left.
        if let where_ = controller?.location.name {
            let label = NSAttributedString(string: where_.uppercased(), attributes: [
                .font: NSFont.systemFont(ofSize: 10.5, weight: .semibold), .foregroundColor: NSColor(white: 0.78, alpha: 1),
                .kern: 1.2])
            label.draw(at: NSPoint(x: 14, y: (midY - label.size().height / 2).rounded()))
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
                let c = NSPoint(x: r.midX, y: midY), d: CGFloat = 4.5
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
/// The location's static picture, behind `SceneView`. Its own view so its pixels are kept between frames:
/// redrawing it 10–30 times a second was most of the window's CPU time.
final class RoomView: NSView {
    var image: CGImage? { didSet { needsDisplay = true } }
    var drawRect = CGRect.zero

    override var isFlipped: Bool { false }
    override func hitTest(_ point: NSPoint) -> NSView? { nil }   // clicks go to the scene above

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext, let image else { return }
        ctx.interpolationQuality = .none
        ctx.draw(image, in: drawRect)
    }
}

final class SceneView: NSView {
    weak var controller: OverlayController?
    weak var roomView: RoomView?
    var onDarkTopChange: (() -> Void)?
    /// How many points at the top of the scene are a dark band that looks like part of the title bar.
    private(set) var darkTop: CGFloat = 0
    private var room: (size: NSSize, location: Location, image: CGImage)?
    /// The animated layer's canvas, reused every frame until the scene's pixel size changes.
    private var live: PixelCanvas?
    private let sprites = SpriteLayers()
    /// CLAWD_SHOT captures the window by drawing its views, which can't see layers: draw the old way then.
    static let drawsItself = ProcessInfo.processInfo.environment["CLAWD_SHOT"] != nil

    override var isFlipped: Bool { false }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override var wantsUpdateLayer: Bool { !Self.drawsItself }
    override func updateLayer() { layer?.masksToBounds = true }

    private var geometry: (pw: Int, ph: Int, floorRows: Int, drawRect: CGRect) {
        let b = bounds, p = Cantina.pixel
        let pw = Int((b.width / p).rounded(.up)), ph = Int((b.height / p).rounded(.up))
        return (pw, ph, Int((OverlayController.cantinaFloor / p).rounded()),
                CGRect(x: 0, y: 0, width: CGFloat(pw) * p, height: CGFloat(ph) * p))
    }

    /// The place only changes when the window is resized or the location changes; `RoomView` shows it.
    private func prepareRoom() {
        guard let controller else { return }
        let g = geometry, location = controller.location
        if room?.location != location && location == .cantina { Cantina.maxReboTonight = Bool.random() }   // a new night
        guard room?.size != bounds.size || room?.location != location else { return }
        let c = PixelCanvas(g.pw, g.ph)
        location.drawStatic(c, floorRows: g.floorRows)
        if let img = c.makeImage() {
            room = (bounds.size, location, img)
            roomView?.drawRect = g.drawRect
            roomView?.image = img
        }
        // Dark rows along the top (row 0 is the top), minus whatever overhangs the view and is clipped.
        var rows = 0
        while rows < min(g.ph, 8), c.rowLuminance(rows) < 0.24 { rows += 1 }
        let dark = max(0, CGFloat(rows) * Cantina.pixel - (CGFloat(g.ph) * Cantina.pixel - bounds.height))
        if dark != darkTop { darkTop = dark; onDarkTopChange?() }
    }

    /// What moves there (the cantina band, sarlacc tentacles, laser gates, fog…) and the crew, as one frame.
    private func frameItems(origin: NSPoint) -> [OverlayController.DrawItem] {
        guard let controller else { return [] }
        let g = geometry
        guard controller.location.hasAnimatedLayer else { return controller.items }   // a still picture: nothing to add
        let canvas: PixelCanvas
        if let live, live.w == g.pw, live.h == g.ph { canvas = live; canvas.clear() } else { canvas = PixelCanvas(g.pw, g.ph); live = canvas }
        controller.location.drawAnimated(canvas, floorRows: g.floorRows, t: Date().timeIntervalSince1970)
        var items: [OverlayController.DrawItem] = []
        if let img = canvas.makeImage() {   // in screen coordinates, like the crew's items
            items.append(OverlayController.DrawItem(image: img, rect: g.drawRect.offsetBy(dx: origin.x, dy: origin.y)))
        }
        return items + controller.items
    }

    /// A new frame: handed to Core Animation, which scales and composites it on the GPU.
    func showFrame() {
        guard !Self.drawsItself else { needsDisplay = true; return }
        guard let window, let host = layer else { return }
        prepareRoom()
        let origin = window.convertToScreen(convert(bounds, to: nil)).origin
        // The layer works in the view's bounds, which AppKit already shows at 75% in the Small Window; the text
        // only needs rendering at the resolution it ends up at.
        let k = frame.width / max(bounds.width, 1)
        sprites.update(frameItems(origin: origin), origin: origin, in: host, pixelsPerPoint: window.backingScaleFactor * k)
    }

    override func draw(_ dirtyRect: NSRect) {   // CLAWD_SHOT only
        guard let ctx = NSGraphicsContext.current?.cgContext, let window else { return }
        prepareRoom()
        ctx.interpolationQuality = .none
        if roomView == nil, let img = room?.image { ctx.draw(img, in: geometry.drawRect) }
        let origin = window.convertToScreen(convert(bounds, to: nil)).origin
        OverlayView.render(frameItems(origin: origin), origin: origin, in: ctx)
    }

    override func mouseUp(with event: NSEvent) {
        guard let window else { return }
        // In the stage's logical coordinates: where the scene sits on screen, plus the (unscaled) point in it.
        let local = convert(event.locationInWindow, from: nil)
        let origin = window.convertToScreen(convert(bounds, to: nil)).origin
        controller?.click(at: NSPoint(x: origin.x + local.x, y: origin.y + local.y))
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
    /// The "▸ 25 more agents" / "▾ Show fewer" rows, by the session they fold.
    private var toggleRects: [(NSRect, String)] = []
    /// Sessions whose agents are all shown. Not remembered across launches.
    private var unfolded: Set<String> = []
    var onHeightChange: (() -> Void)?
    /// Height the cards actually need (the window sizes itself to this).
    private(set) var contentHeight: CGFloat = 0

    override var isFlipped: Bool { true }

    static let focusYellow = NSColor(srgbRed: 1, green: 0.88, blue: 0.29, alpha: 1)

    /// Everything the cards show, so an update that changes nothing (most of them) doesn't redraw.
    private var shown = ""

    func update(cards: [CardModel], banner: String?) {
        // The cards are tinted with the location's colours, so a new location redraws them too.
        let now = ([banner ?? "", controller?.location.rawValue ?? ""] + cards.map(\.signature)).joined(separator: "\u{1}")
        guard now != shown else { return }
        shown = now
        self.cards = cards
        self.banner = banner
        relayout()
    }

    private static let pad: CGFloat = 12
    // Portraits are cropped to 46×38 sprite pixels; the Small Window draws them at 1.5× to save height.
    private static var portraitScale: CGFloat { ClawdWindow.scale < 1 ? 1.5 : 2 }
    // Measured: the widest portrait is the AT-AT (53 px), the tallest the Rancor (42 px) — both fit at 2×.
    private static var portraitSize: NSSize { NSSize(width: 56 * portraitScale, height: 43 * portraitScale) }
    private static let lineH: CGFloat = 16
    private static let agentH: CGFloat = 34
    /// A card shows this many agents; more fold behind a chevron row.
    private static let agentsShown = 4
    private static let toggleH: CGFloat = 22
    private static let groupH: CGFloat = 22
    private static let projectH: CGFloat = 24
    /// How far a project's cards sit in from its header, to make room for the tree line.
    private static let treeIndent: CGFloat = 20

    /// Each host its own colour (its brand's where it has a recognisable one); grey for Local, pink for any other host.
    static func remoteColor(_ remote: String) -> NSColor {
        func rgb(_ hex: Int) -> NSColor {
            NSColor(srgbRed: CGFloat(hex >> 16 & 0xff) / 255, green: CGFloat(hex >> 8 & 0xff) / 255, blue: CGFloat(hex & 0xff) / 255, alpha: 1)
        }
        switch remote {
        case "GitHub": return rgb(0xA371F7)        // GitHub's purple
        case "GitLab": return rgb(0xFC6D26)        // GitLab orange
        case "Bitbucket": return rgb(0x2684FF)     // Atlassian blue
        case "Azure DevOps": return rgb(0x4CC2FF)  // lighter blue, to tell it from Bitbucket
        case "Codeberg": return rgb(0x2FBF8F)
        case "SourceHut": return rgb(0xE0C050)
        case "Local": return NSColor(white: 0.6, alpha: 1)
        default: return rgb(0xE06C9F)              // self-hosted and anything else
        }
    }

    private func shownAgents(_ c: CardModel) -> ArraySlice<CardModel.Agent> {
        c.agents.count > Self.agentsShown && !unfolded.contains(c.id) ? c.agents.prefix(Self.agentsShown) : c.agents[...]
    }

    private func cardHeight(_ c: CardModel) -> CGFloat {
        let rows = CGFloat(shownAgents(c).count) * Self.agentH + (c.agents.count > Self.agentsShown ? Self.toggleH : 0)
        let text = 22 + CGFloat(c.lines.count) * Self.lineH + (c.agents.isEmpty ? 0 : 6 + rows)
        return max(Self.portraitSize.height + 4, text) + Self.pad * 2
    }

    /// The tallest the list gets before it scrolls, whatever is in it: about three plain cards and a peek at a fourth,
    /// so one session with a crowd of agents unfolded doesn't stretch the window either.
    var maxListHeight: CGFloat {
        Self.pad + (banner == nil ? 0 : 34) + 3 * (Self.portraitSize.height + 4 + Self.pad * 2 + 10) + 28
    }

    /// Height of the list cut off after `n` cards, plus a sliver of the next card when there is one.
    func height(showingCards n: Int) -> CGFloat {
        var h = Self.pad + (banner == nil ? 0 : 34)
        for (i, c) in cards.enumerated() {
            let above = (c.group == nil ? 0 : Self.groupH) + (c.tree?.sessions == nil ? 0 : Self.projectH)
            if i == n { return h + above + 28 }
            h += cardHeight(c) + 10 + above
        }
        return h + (cards.isEmpty ? 30 : 0)
    }

    func relayout() {
        let h = height(showingCards: .max)
        contentHeight = h
        // The cards keep normal-size text even in the Small Window (they get more compact instead).
        let minH = enclosingScrollView?.bounds.height ?? 0
        setFrameSize(NSSize(width: frame.width, height: max(h, minH)))
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        ctx.interpolationQuality = .none
        hitRects = []
        toggleRects = []
        // The location's tone, with a faint texture, so the whole window feels like the place.
        let panel = controller?.location.panel ?? NSColor(srgbRed: 0.17, green: 0.13, blue: 0.10, alpha: 1)
        panel.setFill()
        bounds.fill()
        // Two colours, filled in two batches: blending a colour per speck was half of this view's drawing time.
        var light: [CGRect] = [], dark: [CGRect] = []
        for i in 0..<Int(bounds.width * bounds.height / 260) {
            let x = noise(i * 13) * Double(bounds.width), y = noise(i * 13 + 1) * Double(bounds.height)
            let speck = CGRect(x: CGFloat(x).rounded(), y: CGFloat(y).rounded(), width: 2, height: 2)
            if noise(i * 13 + 2) > 0.5 { light.append(speck) } else { dark.append(speck) }
        }
        ctx.setFillColor((panel.blended(withFraction: 0.12, of: .white) ?? panel).cgColor)
        ctx.fill(light)
        ctx.setFillColor((panel.blended(withFraction: 0.25, of: .black) ?? panel).cgColor)
        ctx.fill(dark)
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
                 font: .systemFont(ofSize: 13), color: NSColor(white: 0.62, alpha: 1))   // the panel is dark in light mode too
        }

        var treeTop: CGFloat = 0   // where the current project's tree line continues from
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
            if let n = c.tree?.sessions {
                // The project header: its name in its colour, then where it lives and how many sessions are in it.
                let title = NSMutableAttributedString(string: c.project, attributes: [
                    .font: NSFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: c.accent])
                title.append(NSAttributedString(string: "   " + [c.remote, "\(n) sessions"].compactMap { $0 }.joined(separator: "  ·  "),
                                                attributes: [.font: NSFont.systemFont(ofSize: 11, weight: .semibold),
                                                             .foregroundColor: NSColor(white: 0.62, alpha: 1)]))
                title.draw(with: NSRect(x: x + 2, y: y + 1, width: w - 4, height: 20),
                           options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine])
                y += Self.projectH
                treeTop = y - 4
            }
            let h = cardHeight(c)
            var r = NSRect(x: x, y: y, width: w, height: h)
            if let tree = c.tree {
                // ├ into each card at its title, └ (rounded) into the last.
                r.origin.x += Self.treeIndent; r.size.width -= Self.treeIndent
                let trunkX = x + 7.5, mid = r.minY + 22
                let line = NSBezierPath()
                line.lineWidth = 1.5
                line.move(to: NSPoint(x: trunkX, y: treeTop))
                if tree.last {
                    line.line(to: NSPoint(x: trunkX, y: mid - 5))
                    line.curve(to: NSPoint(x: trunkX + 5, y: mid), controlPoint1: NSPoint(x: trunkX, y: mid - 2),
                               controlPoint2: NSPoint(x: trunkX + 2, y: mid))
                } else {
                    line.line(to: NSPoint(x: trunkX, y: r.maxY + 10))   // on past this card to the next
                    line.move(to: NSPoint(x: trunkX, y: mid))
                }
                line.line(to: NSPoint(x: r.minX, y: mid))
                c.accent.withAlphaComponent(0.5).setStroke()
                line.stroke()
                treeTop = r.maxY + 10
            }
            hitRects.append((r, c.pid))
            let box = NSBezierPath(roundedRect: r, xRadius: 8, yRadius: 8)
            (controller?.location.panel.blended(withFraction: 0.35, of: .black) ?? NSColor.black).withAlphaComponent(0.94).setFill()
            box.fill()
            c.accent.withAlphaComponent(0.55).setStroke()     // steady; the focused card's project name fades instead
            box.lineWidth = 1
            box.stroke()

            // Portrait (drawn upright: this view is flipped)
            let pw = Self.portraitSize.width, ph = Self.portraitSize.height
            if let img = c.portrait {
                draw(img, fitting: NSRect(x: r.minX + 10, y: r.minY + Self.pad, width: pw, height: ph), in: ctx, maxScale: Self.portraitScale)
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
            // The project as the title, in its colour; the character in a pill on the right under the status.
            // (No project? Then the character is the title and there's no pill.)
            // In a project's tree the header above names the project and where it lives, so the card is titled with
            // the character instead, in the project's colour, and needs no pills.
            let inTree = c.tree != nil
            let header = NSMutableAttributedString(string: inTree || c.project.isEmpty ? c.villain : c.project, attributes: [
                .font: NSFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: c.project.isEmpty ? NSColor.white : c.accent])
            var namePill: NSRect?
            if !c.project.isEmpty && !inTree {
                // Tinted with the character's main colour; the text lightened enough to read on the dark card,
                // and very dark costumes (Vader) lifted a little so the pill still shows.
                let base = c.spriteColor.usingColorSpace(.sRGB) ?? c.spriteColor
                let lum = 0.2126 * base.redComponent + 0.7152 * base.greenComponent + 0.0722 * base.blueComponent
                let fill = lum < 0.2 ? (base.blended(withFraction: 0.35, of: .white) ?? base) : base
                let text = base.blended(withFraction: max(0.35, 0.85 - lum), of: .white) ?? .white
                let name = NSAttributedString(string: c.villain, attributes: [
                    .font: NSFont.systemFont(ofSize: 10.5, weight: .semibold), .foregroundColor: text])
                let nw = name.size().width
                let pill = NSRect(x: r.maxX - 12 - nw - 14, y: chip.maxY + 5, width: nw + 14, height: 17)
                fill.withAlphaComponent(0.28).setFill()
                NSBezierPath(roundedRect: pill, xRadius: 8.5, yRadius: 8.5).fill()
                name.draw(at: NSPoint(x: pill.minX + 7, y: pill.minY + 2))
                namePill = pill
                // Where the repo lives, in a pill to its left, in that host's colour.
                if let remote = c.remote {
                    let hue = Self.remoteColor(remote)
                    let label = NSAttributedString(string: remote, attributes: [
                        .font: NSFont.systemFont(ofSize: 10.5, weight: .semibold),
                        .foregroundColor: hue.blended(withFraction: 0.45, of: .white) ?? hue])
                    let lw = label.size().width
                    let rp = NSRect(x: pill.minX - 6 - lw - 14, y: pill.minY, width: lw + 14, height: pill.height)
                    hue.withAlphaComponent(0.24).setFill()
                    NSBezierPath(roundedRect: rp, xRadius: 8.5, yRadius: 8.5).fill()
                    label.draw(at: NSPoint(x: rp.minX + 7, y: rp.minY + 2))
                    namePill = pill.union(rp)
                }
            }
            if c.focused {
                header.append(NSAttributedString(string: "   ◆ you're here", attributes: [
                    .font: NSFont.systemFont(ofSize: 11, weight: .semibold),
                    .foregroundColor: Self.focusYellow]))
            }
            header.draw(with: NSRect(x: tx, y: ty, width: chip.minX - tx - 8, height: 20),
                        options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine])
            ty += 22

            for line in c.lines {
                // Lines level with the pills stop short of them.
                let beside = namePill.map { ty < $0.maxY && ty + Self.lineH > $0.minY } ?? false
                let width = beside ? namePill!.minX - tx - 8 : tw
                draw(line.text, at: NSPoint(x: tx, y: ty), width: width, font: .systemFont(ofSize: 11.5), color: line.color)
                ty += Self.lineH
            }

            if !c.agents.isEmpty {
                ty += 6
                // A tree: a trunk from the session down the left, a branch into each agent (├ … └).
                let trunkX = tx + 5.5, indent: CGFloat = 20, top = ty - 4
                let shown = shownAgents(c)
                let folds = c.agents.count > Self.agentsShown
                let branch = NSBezierPath()
                branch.lineWidth = 1.5
                for i in 0..<shown.count {
                    let mid = ty + CGFloat(i) * Self.agentH + 15.5
                    if i == shown.count - 1 && !folds {   // └ with a rounded corner
                        branch.move(to: NSPoint(x: trunkX, y: top))
                        branch.line(to: NSPoint(x: trunkX, y: mid - 5))
                        branch.curve(to: NSPoint(x: trunkX + 5, y: mid), controlPoint1: NSPoint(x: trunkX, y: mid - 2),
                                     controlPoint2: NSPoint(x: trunkX + 2, y: mid))
                        branch.line(to: NSPoint(x: tx + indent - 2, y: mid))
                    } else {
                        branch.move(to: NSPoint(x: trunkX, y: mid))
                        branch.line(to: NSPoint(x: tx + indent - 2, y: mid))
                    }
                }
                if folds {   // the trunk runs on to the chevron row, which gets the └
                    let mid = ty + CGFloat(shown.count) * Self.agentH + Self.toggleH / 2
                    branch.move(to: NSPoint(x: trunkX, y: top))
                    branch.line(to: NSPoint(x: trunkX, y: mid - 5))
                    branch.curve(to: NSPoint(x: trunkX + 5, y: mid), controlPoint1: NSPoint(x: trunkX, y: mid - 2),
                                 controlPoint2: NSPoint(x: trunkX + 2, y: mid))
                    branch.line(to: NSPoint(x: tx + indent - 2, y: mid))
                }
                c.accent.withAlphaComponent(0.5).setStroke()
                branch.stroke()
                for a in shown {
                    let tx = tx + indent, tw = tw - indent
                    if let img = a.portrait {
                        draw(img, fitting: NSRect(x: tx - 4, y: ty, width: 36, height: 30), in: ctx, maxScale: 1)
                    }
                    // A small "AGENT" tag in front, so a row can't be mistaken for a session.
                    let tag = NSAttributedString(string: "AGENT", attributes: [
                        .font: NSFont.systemFont(ofSize: 8.5, weight: .heavy), .kern: 0.8,
                        .foregroundColor: NSColor(white: 0.78, alpha: 1)])
                    let tagSize = tag.size()
                    let chip = NSRect(x: tx + 40, y: ty + 2, width: (tagSize.width + 10).rounded(), height: 14)
                    NSColor(white: 1, alpha: 0.12).setFill()
                    NSBezierPath(roundedRect: chip, xRadius: 4, yRadius: 4).fill()
                    tag.draw(at: NSPoint(x: chip.minX + 5, y: (chip.midY - tagSize.height / 2).rounded()))
                    let ax = chip.maxX + 6
                    let title = NSMutableAttributedString(string: a.name, attributes: [
                        .font: NSFont.systemFont(ofSize: 11.5, weight: .semibold), .foregroundColor: NSColor.white])
                    title.append(NSAttributedString(string: "  —  " + a.task, attributes: [
                        .font: NSFont.systemFont(ofSize: 11.5), .foregroundColor: c.accent]))
                    title.draw(with: NSRect(x: ax, y: ty + 1, width: tx + tw - ax, height: 16),
                               options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine])
                    draw(a.detail, at: NSPoint(x: tx + 40, y: ty + 17), width: tw - 40,
                         font: .systemFont(ofSize: 10.5), color: NSColor(white: 0.62, alpha: 1))
                    ty += Self.agentH
                }
                if folds {
                    let open = unfolded.contains(c.id)
                    let label = open ? "Show fewer" : "\(c.agents.count - shown.count) more agent\(c.agents.count - shown.count == 1 ? "" : "s")"
                    let text = NSAttributedString(string: label, attributes: [
                        .font: NSFont.systemFont(ofSize: 11, weight: .semibold), .foregroundColor: c.accent])
                    let ts = text.size()
                    let row = NSRect(x: tx + indent, y: ty + 1, width: 18 + ts.width + 8, height: Self.toggleH - 2)
                    if let img = NSImage(systemSymbolName: open ? "chevron.down" : "chevron.right", accessibilityDescription: nil)?
                        .withSymbolConfiguration(.init(pointSize: 9, weight: .bold)) {
                        let tinted = NSImage(size: img.size, flipped: false) { rr in
                            img.draw(in: rr); c.accent.set(); rr.fill(using: .sourceAtop); return true
                        }
                        tinted.draw(in: NSRect(x: row.minX + 4, y: (row.midY - img.size.height / 2).rounded(),
                                               width: img.size.width, height: img.size.height))
                    }
                    text.draw(at: NSPoint(x: row.minX + 18, y: (row.midY - ts.height / 2).rounded()))
                    toggleRects.append((row, c.id))
                    ty += Self.toggleH
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
        if k >= 1 { k = (k * 2).rounded(.down) / 2 }   // whole or half steps (1.5× in the Small Window)
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
        if let toggle = toggleRects.first(where: { $0.0.contains(p) }) {
            if unfolded.remove(toggle.1) == nil { unfolded.insert(toggle.1) }
            relayout()
            window?.invalidateCursorRects(for: self)
            onHeightChange?()
            return
        }
        guard let hit = hitRects.first(where: { $0.0.contains(p) }) else { return }
        if let pid = hit.1 { Jump.toSession(pid: pid) } else { NSSound.beep() }
    }

    override func resetCursorRects() {
        for (r, pid) in hitRects where pid != nil { addCursorRect(r, cursor: .pointingHand) }
        for (r, _) in toggleRects { addCursorRect(r, cursor: .pointingHand) }
    }

    override func rightMouseDown(with event: NSEvent) {
        guard let controller else { return }
        NSMenu.popUpContextMenu(controller.menu(), with: event, for: self)
    }
}
