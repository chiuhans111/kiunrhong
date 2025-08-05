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

    /// Creates a new menu item and adds it to the end of the menu, additionally modifies its properties using the provided closure.
    @discardableResult
    func addItem(withTitle title: String, action selector: Selector?, keyEquivalent: String? = nil, _ transform: ((_ item: NSMenuItem) -> Void)) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: selector, keyEquivalent: keyEquivalent ?? "")
        transform(item)
        self.addItem(item)
        return item
    }

    /// Creates a new menu item with the specified submenu and adds it to the end of the menu, additionally modifies its properties using the provided closure.
    @discardableResult
    func addItem(withSubmenuTitle title: String, localizedTitle: String? = nil, _ transform: ((_ submenu: NSMenu) -> Void)) -> NSMenuItem {
        let item = NSMenuItem()
        item.title = title

        let submenu = NSMenu(title: localizedTitle ?? title)
        item.submenu = submenu

        transform(submenu)
        self.addItem(item)
        return item
    }
}
