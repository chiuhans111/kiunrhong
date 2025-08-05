//
//  NSMenu+Extension.swift
//  Kiunrhong
//
//

import AppKit

extension NSMenu {
    /// Adds a menu item that is used to separate logical groups of menu commands to the end of the menu.
    func addSeparator() {
        self.addItem(NSMenuItem.separator())
    }

    /// Creates a new menu item with the specified keyboard equivalent modifiers and adds it to the end of the menu.
    func addItem(withTitle title: String, action selector: Selector?, keyEquivalent: String, modifiers: NSEvent.ModifierFlags = []) {
        let item = NSMenuItem(title: title, action: selector, keyEquivalent: keyEquivalent)
        item.keyEquivalentModifierMask = modifiers
        self.addItem(item)
    }

    /// Creates a new menu item with the specified submenu and adds it to the end of the menu.
    func addItem(withSubmenu submenu: NSMenu) {
        let item = NSMenuItem()
        item.title = submenu.title
        item.submenu = submenu
        self.addItem(item)
    }
}
