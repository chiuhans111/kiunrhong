//
//  GradientChartWindowController.swift
//  Kiunrhong
//
//

import AppKit

class GradientChartWindowController: NSWindowController {

    static let identifier = "\(Bundle.main.bundleIdentifier!).GradientChartWindow"

    override func loadWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false)
        window.title = NSLocalizedString("Wide Gamut Gradient Chart", comment: "")

        window.contentView = ColorGradientView()
        //window.contentView!.translatesAutoresizingMaskIntoConstraints = false
        //window.contentView!.fillParentView()

        if let title = window.standardTitleText() {
            // Opt in to auto layout to avoid weird sizing things
            title.translatesAutoresizingMaskIntoConstraints = false
            title.trailingAnchor.constraint(equalTo: title.superview!.trailingAnchor, constant: -8).isActive = true
            title.centerYAnchor.constraint(equalTo: title.superview!.centerYAnchor).isActive = true

            // Sets the title font to our preference
            title.font = .monospacedSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .medium)
            title.alignment = .right
        }

        window.center()
        self.window = window
    }
}
