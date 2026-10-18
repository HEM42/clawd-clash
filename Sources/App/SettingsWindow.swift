import AppKit

/// What the Settings window shows: a tab per section, each with rows that read and change a setting through closures,
/// so the window knows nothing about the app (`OverlayController.settingsSections` builds them).
struct SettingsSection {
    let title: String
    /// The tab's SF Symbol.
    let symbol: String
    var note: String? = nil
    let rows: [SettingsRow]
}

enum SettingsRow {
    /// A label and a checkbox, with an optional line under it.
    case toggle(String, note: String? = nil, get: () -> Bool, set: (Bool) -> Void)
    /// A label and a column of checkboxes under it, each with its own title.
    case checks(String, items: [(title: String, get: () -> Bool, set: (Bool) -> Void)])
    /// A label and a pop-up of choices, left out while not `shown`.
    case choice(String, options: [String], shown: () -> Bool = { true }, get: () -> Int, set: (Int) -> Void)
    /// A label, what it says now, and a button (none when `button` gives nil). `dimmed` greys the row out.
    case status(String, detail: () -> String, button: () -> String?, dimmed: () -> Bool = { false }, action: () -> Void)
    /// A button on its own, with a line beside it saying what it does.
    case button(String, note: String, action: () -> Void)
    /// A line between groups of rows.
    case separator
    /// Anything else, across the whole width (the About tab).
    case custom(() -> NSView)
}

/// Clawd Clash's settings, a tab per section in the toolbar (as macOS's own Settings windows do): labels on the
/// left, right-aligned against their controls, groups split by lines. Rebuilt from `sections()` whenever something
/// changes, here or elsewhere (it reloads when it comes to the front), and remembers which tab was open.
final class SettingsWindow: NSObject, NSWindowDelegate, NSToolbarDelegate {
    private let window: NSWindow
    private let sections: () -> [SettingsSection]
    /// The level to show at: as high as Clawd Clash's own window or characters, so they never cover it.
    private let level: () -> NSWindow.Level
    /// Actions by control, so a control's target can find its closure.
    private var actions: [ObjectIdentifier: (NSControl) -> Void] = [:]
    private static let width: CGFloat = 600
    /// The tabs the toolbar was built with; a different set (the screen saver appears) builds it again.
    private var tabs: [String] = []
    private var tab: String {
        get { UserDefaults.standard.string(forKey: "settingsTab") ?? tabs.first ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "settingsTab") }
    }

    init(level: @escaping () -> NSWindow.Level = { .normal }, sections: @escaping () -> [SettingsSection]) {
        self.sections = sections
        self.level = level
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: Self.width, height: 400), styleMask: [.titled, .closable],
                          backing: .buffered, defer: false)
        super.init()
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.toolbarStyle = .preference
        reload()
        window.center()
    }

    func show() {
        reload()
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func windowDidBecomeKey(_ notification: Notification) { reload() }

    /// Builds the open tab again from the current settings, keeping the window's top edge where it is.
    func reload() {
        actions.removeAll()
        window.level = level()
        let all = sections()
        if all.map(\.title) != tabs {
            tabs = all.map(\.title)
            let toolbar = NSToolbar(identifier: "settings")
            toolbar.delegate = self
            toolbar.displayMode = .iconAndLabel
            toolbar.allowsUserCustomization = false
            window.toolbar = toolbar
        }
        if !tabs.contains(tab) { tab = tabs.first ?? "" }
        window.toolbar?.selectedItemIdentifier = NSToolbarItem.Identifier(tab)
        window.title = tab
        guard let section = all.first(where: { $0.title == tab }) else { return }

        let grid = NSGridView(numberOfColumns: 2, rows: 0)
        grid.column(at: 0).xPlacement = .trailing
        grid.yPlacement = .center
        grid.columnSpacing = 12
        grid.rowSpacing = 9
        if let note = section.note {
            let r = grid.addRow(with: [Self.note(note, width: Self.width - 80), NSGridCell.emptyContentView])
            r.mergeCells(in: NSRange(location: 0, length: 2))
            r.cell(at: 0).xPlacement = .center
            r.bottomPadding = 6
        }
        for row in section.rows { add(row, to: grid) }

        let content = NSView()
        grid.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(grid)
        NSLayoutConstraint.activate([
            grid.topAnchor.constraint(equalTo: content.topAnchor, constant: 22),
            grid.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -24),
            grid.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            grid.leadingAnchor.constraint(greaterThanOrEqualTo: content.leadingAnchor, constant: 24),
        ])
        let top = window.frame.maxY
        window.contentView = content
        let height = grid.fittingSize.height + 22 + 24
        var frame = window.frameRect(forContentRect: NSRect(x: 0, y: 0, width: Self.width, height: height))
        frame.origin = NSPoint(x: window.frame.minX, y: top - frame.height)
        window.setFrame(frame, display: true, animate: window.isVisible)
    }

    private func add(_ row: SettingsRow, to grid: NSGridView) {
        switch row {
        case let .toggle(title, note, get, set):
            let box = NSButton(checkboxWithTitle: "", target: nil, action: nil)
            box.state = get() ? .on : .off
            box.setAccessibilityLabel(title)
            hook(box) { set(($0 as? NSButton)?.state == .on) }
            grid.addRow(with: [Self.label(title), box])
            if let note { addNote(note, to: grid) }
        case let .checks(title, items):
            for (i, item) in items.enumerated() {
                let box = NSButton(checkboxWithTitle: item.title, target: nil, action: nil)
                box.state = item.get() ? .on : .off
                let set = item.set
                hook(box) { set(($0 as? NSButton)?.state == .on) }
                let r = grid.addRow(with: [i == 0 ? Self.label(title) : NSGridCell.emptyContentView, box])
                if i > 0 { r.topPadding = -3 }
            }
        case let .choice(title, options, shown, get, set):
            let popup = NSPopUpButton(frame: .zero, pullsDown: false)
            popup.addItems(withTitles: options)
            popup.selectItem(at: get())
            hook(popup) { set(($0 as? NSPopUpButton)?.indexOfSelectedItem ?? 0) }
            guard shown() else { return }
            grid.addRow(with: [Self.label(title), popup])
        case let .status(title, detail, button, dimmed, action):
            let d = NSTextField(labelWithString: detail())
            d.textColor = dimmed() ? .tertiaryLabelColor : .secondaryLabelColor
            d.widthAnchor.constraint(greaterThanOrEqualToConstant: 96).isActive = true
            let l = Self.label(title)
            if dimmed() { l.textColor = .tertiaryLabelColor }
            var views: [NSView] = [d]
            if let name = button() {
                let b = NSButton(title: name, target: nil, action: nil)
                b.bezelStyle = .rounded
                hook(b) { _ in action() }
                views.append(b)
            }
            grid.addRow(with: [l, Self.line(views)])
        case let .button(title, note, action):
            let b = NSButton(title: title, target: nil, action: nil)
            b.bezelStyle = .rounded
            hook(b) { _ in action() }
            grid.addRow(with: [NSGridCell.emptyContentView, b])
            addNote(note, to: grid)
        case .separator:
            let line = NSBox()
            line.boxType = .separator
            let r = grid.addRow(with: [line, NSGridCell.emptyContentView])
            r.mergeCells(in: NSRange(location: 0, length: 2))
            r.cell(at: 0).xPlacement = .fill
            r.topPadding = 3; r.bottomPadding = 3
            line.widthAnchor.constraint(equalToConstant: Self.width - 48).isActive = true
        case let .custom(make):
            let r = grid.addRow(with: [make(), NSGridCell.emptyContentView])
            r.mergeCells(in: NSRange(location: 0, length: 2))
            r.cell(at: 0).xPlacement = .center
        }
    }

    /// Small grey text under the control in the row above.
    private func addNote(_ s: String, to grid: NSGridView) {
        let r = grid.addRow(with: [NSGridCell.emptyContentView, Self.note(s, width: 300)])
        r.topPadding = -5
    }

    private static func line(_ views: [NSView]) -> NSView {
        let v = NSStackView(views: views)
        v.orientation = .horizontal
        v.alignment = .centerY
        v.spacing = 10
        return v
    }

    private static func label(_ s: String) -> NSTextField {
        let l = NSTextField(labelWithString: s)
        l.alignment = .right
        return l
    }

    /// Small grey text, wrapped to `width`.
    private static func note(_ s: String, width: CGFloat) -> NSTextField {
        let n = NSTextField(wrappingLabelWithString: s)
        n.font = .systemFont(ofSize: NSFont.smallSystemFontSize)
        n.textColor = .secondaryLabelColor
        n.preferredMaxLayoutWidth = width
        n.widthAnchor.constraint(lessThanOrEqualToConstant: width).isActive = true
        return n
    }

    // MARK: The tabs

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] { tabs.map { .init($0) } }
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] { tabs.map { .init($0) } }
    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] { tabs.map { .init($0) } }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier id: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let item = NSToolbarItem(itemIdentifier: id)
        item.label = id.rawValue
        let symbol = sections().first { $0.title == id.rawValue }?.symbol ?? "gearshape"
        item.image = NSImage(systemSymbolName: symbol, accessibilityDescription: id.rawValue)
            ?? NSImage(systemSymbolName: "gearshape", accessibilityDescription: id.rawValue)   // a symbol this macOS lacks
        item.target = self
        item.action = #selector(choose(_:))
        return item
    }

    @objc private func choose(_ item: NSToolbarItem) {
        tab = item.itemIdentifier.rawValue
        reload()
    }

    /// Runs `action` when the control is used, then shows what changed.
    private func hook(_ control: NSControl, _ action: @escaping (NSControl) -> Void) {
        actions[ObjectIdentifier(control)] = action
        control.target = self
        control.action = #selector(used(_:))
    }

    @objc private func used(_ sender: NSControl) {
        actions[ObjectIdentifier(sender)]?(sender)
        // After the action's own effects (an alert, a hook install) have settled.
        DispatchQueue.main.async { [weak self] in self?.reload() }
    }
}
