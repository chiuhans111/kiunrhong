//
//  ColorPickerWindowController.swift
//  Kiunrhong
//
//

import AppKit

/// A controller that manages the color picker window.
class ColorPickerWindowController: NSWindowController, NSWindowDelegate {

    static let identifier = "\(Bundle.main.bundleIdentifier!).ColorPickerWindow"

    var viewController: ColorPickerViewController!

    init() {
        let screenFrame = NSScreen.main?.visibleFrame ?? .zero
        let size = NSSize(width: 480, height: 360)
        let position = NSPoint(x: max(screenFrame.midX - size.width / 2.0, 0.0),
                               y: max(screenFrame.midY - size.height / 2.0, 0.0))

        let window = NSWindow(
            contentRect: .init(origin: position, size: size),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false)

        window.title = "Kiunrhong"
        window.identifier = .init(rawValue: ColorPickerWindowController.identifier)
        window.titlebarAppearsTransparent = true

        window.standardWindowButton(.zoomButton)?.isHidden = true
        if let windowTitle = window.standardTitleText() {
            windowTitle.font = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .medium)
            windowTitle.sizeToFit()
        }

        super.init(window: window)

        self.viewController = ColorPickerViewController()
        window.contentView = viewController.view
        viewController.view.fillParentView()

        window.delegate = self
        window.restorationClass = AppDelegate.self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Hide the window to background
        sender.orderOut(self)
        return false
    }

    func windowWillClose(_: Notification) {
        // Release any reference we retain
        self.viewController = nil
    }
}
