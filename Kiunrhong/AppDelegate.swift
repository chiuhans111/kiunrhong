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
                          styleMask: [.titled, .closable, .resizable, .miniaturizable], backing: .buffered, defer: false)
        window.title = "Kiunrhong"
        window.contentView = ColorPickerView()
        return window
    }

    func createApplicationMenu() -> NSMenu {
        let menu = NSMenu(title: "Main Menu")

        let appMenu = NSMenu(title: "Application")
        appMenu.addItem(withTitle: "About", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addSeparator()
        appMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        menu.addItem(withSubmenu: appMenu)

        return menu
    }

    // Application lifecyle stuff

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.window = createApplicationWindow()
        window.center()
        window.makeKeyAndOrderFront(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
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
