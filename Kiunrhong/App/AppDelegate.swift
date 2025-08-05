//
//  AppDelegate.swift
//  Kiunrhong
//
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowRestoration {

    var colorPicker: ColorPickerWindowController!

    func createApplicationMenu() -> NSMenu {
        let menu = NSMenu(title: "Main Menu")
        let appName = NSRunningApplication.current.localizedName ?? "Kiunrhong"

        let appMenu = NSMenu(title: "Application")

        let aboutMenuItem = NSMenuItem(title: "About \(appName)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        aboutMenuItem.image = NSImage(systemSymbolName: "loupe", accessibilityDescription: nil)
        appMenu.addItem(aboutMenuItem)
        appMenu.addSeparator()

        let servicesMenu = NSMenu(title: "Services")
        appMenu.addItem(withSubmenu: servicesMenu)
        NSApp.servicesMenu = servicesMenu
        appMenu.addSeparator()

        appMenu.addItem(withTitle: "Hide \(appName)", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.addItem(withTitle: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h", modifiers: [.command, .option])
        appMenu.addItem(withTitle: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
        appMenu.addSeparator()
        appMenu.addItem(withTitle: "Quit \(appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(withSubmenu: appMenu)

        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Delete", action: #selector(NSText.delete(_:)), keyEquivalent: String(UnicodeScalar(NSBackspaceCharacter)!))
        editMenu.addSeparator()
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editMenuItem.submenu = editMenu
        editMenuItem.isHidden = true    // Menu still works when hidden
        menu.addItem(editMenuItem)

        let colorMenu = NSMenu(title: "Color")
        colorMenu.addItem(withTitle: "Copy Color", action: #selector(ColorPickerViewController.copyCurrentColor(_:)), keyEquivalent: "C")
        colorMenu.addItem(withTitle: "Paste Color", action: #selector(ColorPickerViewController.pasteColor(_:)), keyEquivalent: "P")
        colorMenu.addSeparator()
        colorMenu.addItem(withTitle: "Sample Color", action: #selector(ColorPickerViewController.sampleColor(_:)), keyEquivalent: "")
        colorMenu.addItem(withTitle: "Randomize", action: #selector(ColorPickerViewController.randomizeColor(_:)), keyEquivalent: "R")
        menu.addItem(withSubmenu: colorMenu)

        let viewMenu = NSMenu(title: "View")
        menu.addItem(withSubmenu: viewMenu)

        let windowMenu = NSMenu(title: "Window")
        windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
        windowMenu.addSeparator()
        windowMenu.addItem(withTitle: "Bring All to Front", action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: "")
        menu.addItem(withSubmenu: windowMenu)
        NSApp.windowsMenu = windowMenu

        let helpMenu = NSMenu(title: "Help")
        helpMenu.addItem(withTitle: "Project Website", action: #selector(openProjectWebsite), keyEquivalent: "")
        helpMenu.addItem(withTitle: "Report an Issue", action: #selector(reportIssue), keyEquivalent: "")
        menu.addItem(withSubmenu: helpMenu)
        NSApp.helpMenu = helpMenu

        return menu
    }

    //
    // Help menu stuff
    //

    @objc func openProjectWebsite() {
        NSWorkspace.shared.open(URL(string: "https://github.com/rschiang/kiunrhong")!)
    }

    @objc func reportIssue() {
        NSWorkspace.shared.open(URL(string: "https://github.com/rschiang/kiunrhong/issues")!)
    }

    //
    // Application lifecyle stuff
    //


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.colorPicker = ColorPickerWindowController()
        colorPicker.showWindow(self)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    static func restoreWindow(withIdentifier identifier: NSUserInterfaceItemIdentifier, state: NSCoder) async throws -> NSWindow {
        if identifier == NSUserInterfaceItemIdentifier(ColorPickerWindowController.identifier) {
            if let window = (NSApplication.shared.delegate as? AppDelegate)?.colorPicker.window {
                return window
            }
        }
        throw NSError(domain: "AppDelegate", code: 0, userInfo: [NSDebugDescriptionErrorKey: "Window identifier not found: \(identifier)"])
    }

    static func main() {
        let delegate = AppDelegate()
        withExtendedLifetime(delegate, {
            let app = NSApplication.shared
            app.delegate = delegate
            app.mainMenu = delegate.createApplicationMenu()
            app.run()
        })
    }
}
