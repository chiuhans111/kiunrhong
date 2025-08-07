//
//  NSWindow+Extension.swift
//  Kiunrhong
//
//

import AppKit

extension NSWindow {
    /// Trickery to acquire the window title label. Do not do this at home.
    func standardTitleText() -> NSTextField? {
        let titlebarView = self.standardWindowButton(.closeButton)?.superview
        return titlebarView?.subviews.first(where: { $0 is NSTextField }) as? NSTextField
    }
}
