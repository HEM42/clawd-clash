import AppKit

/// The menu bar's Full Screen: the screen saver itself (`ClawdClashSaverView`, clock and all), fed by the app like
/// the window's screen-saver view, in macOS's own full screen on the display the mouse is on. It's a Space of its own
/// there, so you can swipe between it and your other Spaces and keep working on another display. A click on it,
/// Escape or the system's own Exit Full Screen leaves it.
final class FullScreenSaver: NSObject, NSWindowDelegate {
    private let window: NSWindow
    private let board: ClawdClashSaverView
    private var timer: Timer?
    private var leaving = false
    var onClose: (() -> Void)?
    var isShown: Bool { timer != nil }
    /// The display it's on.
    let screenFrame: NSRect

    init(feed: @escaping () -> SaverFeed?) {
        let screen = NSScreen.screens.first { $0.frame.contains(NSEvent.mouseLocation) } ?? NSScreen.main ?? NSScreen.screens[0]
        screenFrame = screen.frame
        // Titled so macOS takes it full screen (the title bar only shows when the mouse goes to the top). No `screen:`
        // here: with one, AppKit reads the rect as relative to that screen, and on a second display it landed off
        // every screen.
        window = KeyWindow(contentRect: screen.frame, styleMask: [.titled, .resizable, .fullSizeContentView],
                           backing: .buffered, defer: false)
        board = ClawdClashSaverView(frame: NSRect(origin: .zero, size: screen.frame.size), isPreview: false)!
        super.init()
        window.title = "Clawd Clash"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = .black
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.fullScreenPrimary]
        window.delegate = self
        board.feedSource = feed
        board.autoresizingMask = [.width, .height]
        window.contentView = board
        (window as? KeyWindow)?.onLeave = { [weak self] in self?.leave() }
    }

    func show() {
        board.animateOneFrame()
        let t = Timer(timeInterval: board.animationTimeInterval, repeats: true) { [weak self] _ in self?.board.animateOneFrame() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        window.toggleFullScreen(nil)
    }

    /// Out of full screen first (its Space goes with it), then away once that's done (`windowDidExitFullScreen`).
    func leave() {
        guard timer != nil, !leaving else { return }
        leaving = true
        if window.styleMask.contains(.fullScreen) { window.toggleFullScreen(nil) } else { close() }
    }

    func windowDidEnterFullScreen(_ notification: Notification) {
        NSCursor.setHiddenUntilMouseMoves(true)
    }

    /// However it left full screen (a click, Escape, the green button, ⌃⌘F), it's done.
    func windowDidExitFullScreen(_ notification: Notification) { close() }
    func windowDidFailToEnterFullScreen(_ window: NSWindow) { close() }

    func close() {
        guard timer != nil else { return }
        timer?.invalidate(); timer = nil
        window.orderOut(nil)
        // Not from inside the window's own event: letting go of this object then would free the window mid-event.
        DispatchQueue.main.async { [onClose] in onClose?() }
    }

    private final class KeyWindow: NSWindow {
        var onLeave: (() -> Void)?
        override func sendEvent(_ event: NSEvent) {
            switch event.type {
            case .keyDown where event.keyCode == 53, .leftMouseDown:   // 53: Escape
                onLeave?()
            default: super.sendEvent(event)
            }
        }
    }
}
