//
//  GradientChartWindowController.swift
//  Kiunrhong
//
//

import AppKit

class GradientChartWindowController: NSWindowController {

    static let identifier = "\(Bundle.main.bundleIdentifier!).GradientChartWindow"

    override func loadWindow() {
        let screenFrame = NSScreen.main?.visibleFrame ?? .zero
        let size = NSSize(width: 800, height: 600)
        let origin = NSPoint(x: (screenFrame.width - size.width) * 0.8,
                             y: (screenFrame.height - size.height) * 0.2)

        let window = NSWindow(
            contentRect: .init(origin: origin, size: size),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false)

        window.title = NSLocalizedString("Wide Gamut Gradient Chart", comment: "")
        window.identifier = .init(GradientChartWindowController.identifier)
        window.contentView = ColorGradientView()

        if let titleText = window.standardTitleText() {
            // Opt in to auto layout to avoid weird sizing things
            titleText.translatesAutoresizingMaskIntoConstraints = false
            titleText.trailingAnchor.constraint(equalTo: titleText.superview!.trailingAnchor, constant: -8).isActive = true
            titleText.centerYAnchor.constraint(equalTo: titleText.superview!.centerYAnchor).isActive = true

            // Sets the title font to our preference
            titleText.font = .monospacedSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .medium)
            titleText.alignment = .right
        }

        self.window = window
    }
}
