//
//  GradientChartWindowController.swift
//  Kiunrhong
//
//

import AppKit

class GradientChartWindowController: NSWindowController {

    override func loadWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false)
        window.title = "Gradient"
        window.contentView = ColorGradientView()
        window.contentView!.translatesAutoresizingMaskIntoConstraints = false
        window.contentView!.fillParentView()
        window.center()
        self.window = window
    }
}
