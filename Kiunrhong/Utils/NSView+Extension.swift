//
//  NSView+Extension.swift
//  Kiunrhong
//
//

import AppKit

extension NSView {
    /// Anchors the current view to the four edges of its superview.
    func fillParentView() {
        self.topAnchor.constraint(equalTo: superview!.topAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: superview!.trailingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: superview!.leadingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: superview!.bottomAnchor).isActive = true
    }

    /// Anchors the current view to the layout margins of its superview.
    func fillToParentLayoutMarginsGuide() {
        self.topAnchor.constraint(equalTo: superview!.layoutMarginsGuide.topAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: superview!.layoutMarginsGuide.trailingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: superview!.layoutMarginsGuide.leadingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: superview!.layoutMarginsGuide.bottomAnchor).isActive = true
    }
}
