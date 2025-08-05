//
//  AppDelegate.swift
//  Kiunrhong
//
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func createApplicationWindow() -> NSWindow {
        let window = NSWindow(contentRect: .init(x: 0, y: 0, width: 480, height: 360),
                              styleMask: [.titled, .closable], backing: .buffered, defer: false)
        let viewController = ColorPickerViewController()
        window.title = "Kiunrhong"
        window.contentView = viewController.view
        return window
    }

    func createApplicationMenu() -> NSMenu {
        let menu = NSMenu(title: "Main Menu")
        let appName = NSRunningApplication.current.localizedName ?? "Kiunrhong"

        let appMenu = NSMenu(title: "Application")
        appMenu.addItem(withTitle: "About \(appName)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addSeparator()
        appMenu.addItem(withSubmenu: NSMenu(title: "Services"))
        appMenu.addSeparator()
        appMenu.addItem(withTitle: "Hide \(appName)", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.addItem(withTitle: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h", modifiers: [.command, .option])
        appMenu.addItem(withTitle: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
        appMenu.addSeparator()
        appMenu.addItem(withTitle: "Quit \(appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(withSubmenu: appMenu)

        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenuItem.submenu = editMenu
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Delete", action: #selector(NSText.delete(_:)), keyEquivalent: String(UnicodeScalar(NSBackspaceCharacter)!))
        editMenu.addSeparator()
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        menu.addItem(editMenuItem)

        let colorMenu = NSMenu(title: "Color")
        colorMenu.addItem(withTitle: "Copy Color", action: #selector(ColorPickerViewController.copyButtonClicked), keyEquivalent: "C")
        menu.addItem(withSubmenu: colorMenu)

        let viewMenu = NSMenu(title: "View")
        menu.addItem(withSubmenu: viewMenu)

        let windowMenu = NSMenu(title: "Window")
        windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
        windowMenu.addSeparator()
        windowMenu.addItem(withTitle: "Bring All to Front", action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: "")
        menu.addItem(withSubmenu: windowMenu)

        let helpMenu = NSMenu(title: "Help")
        helpMenu.addItem(withTitle: "\(appName) Help", action: #selector(NSApplication.showHelp(_:)), keyEquivalent: "")
        helpMenu.addItem(withTitle: "Project Website", action: #selector(openProjectWebsite), keyEquivalent: "")
        helpMenu.addItem(withTitle: "Report Issue", action: #selector(reportIssue), keyEquivalent: "")
        menu.addItem(withSubmenu: helpMenu)

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

    func applicationWillFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.set(true, forKey: "NSDisabledDictationMenuItem")
        UserDefaults.standard.set(true, forKey: "NSDisabledCharacterPaletteMenuItem")
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.window = createApplicationWindow()
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.makeMain()
        NSApp.activate()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.mainMenu = delegate.createApplicationMenu()
        _  = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    }
}
