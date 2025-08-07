//
//  AppDelegate.swift
//  Kiunrhong
//
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowRestoration {

    var colorPicker = ColorPickerWindowController()
    var gradientChart = GradientChartWindowController(windowNibName: "")

    func createApplicationMenu() -> NSMenu {
        let menu = NSMenu(title: "Main Menu")
        let appName = NSRunningApplication.current.localizedName ?? "Kiunrhong"

        menu.addItem(withSubmenuTitle: "Application") { appMenu in
            appMenu.addItem(withTitle: String(format: NSLocalizedString("About %@", comment: ""), appName),
                            action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)))
                       { $0.image = NSImage(systemSymbolName: "loupe", accessibilityDescription: nil) }
            appMenu.addSeparator()
            appMenu.addItem(withSubmenuTitle: "Services", localizedTitle: NSLocalizedString("Services", comment: "")) { servicesMenu in
                NSApp.servicesMenu = servicesMenu
            }
            appMenu.addSeparator()
            appMenu.addItem(withTitle: String(format: NSLocalizedString("Hide %@", comment: ""), appName),
                            action: #selector(NSApplication.hide(_:)),
                            keyEquivalent: "h")
            appMenu.addItem(withTitle: NSLocalizedString("Hide Others", comment: ""),
                            action: #selector(NSApplication.hideOtherApplications(_:)),
                            keyEquivalent: "h")
                       { $0.keyEquivalentModifierMask = [.command, .option] }
            appMenu.addItem(withTitle: NSLocalizedString("Show All", comment: ""),
                            action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
            appMenu.addSeparator()
            appMenu.addItem(withTitle: String(format: NSLocalizedString("Quit %@", comment: ""), appName),
                            action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        }

        menu.addItem(withSubmenuTitle: "Edit", localizedTitle: NSLocalizedString("Edit", comment: "")) { editMenu in
            editMenu.addItem(withTitle: NSLocalizedString("Cut", comment: ""),
                             action: #selector(NSText.cut(_:)),
                             keyEquivalent: "x")
            editMenu.addItem(withTitle: NSLocalizedString("Copy", comment: ""),
                             action: #selector(NSText.copy(_:)),
                             keyEquivalent: "c")
            editMenu.addItem(withTitle: NSLocalizedString("Paste", comment: ""),
                             action: #selector(NSText.paste(_:)),
                             keyEquivalent: "v")
            editMenu.addItem(withTitle: NSLocalizedString("Delete", comment: ""),
                             action: #selector(NSText.delete(_:)),
                             keyEquivalent: String(UnicodeScalar(NSBackspaceCharacter)!))
            editMenu.addSeparator()
            editMenu.addItem(withTitle: NSLocalizedString("Select All", comment: ""),
                             action: #selector(NSText.selectAll(_:)),
                             keyEquivalent: "a")
        }.isHidden = true   // Hides the Edit menu but retains the action

        menu.addItem(withSubmenuTitle: "Color", localizedTitle: NSLocalizedString("Color", comment: "")) { colorMenu in
            colorMenu.addItem(withTitle: NSLocalizedString("Copy Color", comment: ""),
                              action: #selector(ColorPickerViewController.copyCurrentColor(_:)),
                              keyEquivalent: "c")
                         { $0.keyEquivalentModifierMask = [.option, .command] }
            colorMenu.addItem(withTitle: NSLocalizedString("Paste Color", comment: ""),
                              action: #selector(ColorPickerViewController.pasteColor(_:)),
                              keyEquivalent: "p")
                         { $0.keyEquivalentModifierMask = [.option, .command] }
            colorMenu.addSeparator()
            colorMenu.addItem(withTitle: NSLocalizedString("Sample Color", comment: ""),
                              action: #selector(ColorPickerViewController.sampleColor(_:)), keyEquivalent: "")
            colorMenu.addItem(withTitle: NSLocalizedString("Randomize", comment: ""),
                              action: #selector(ColorPickerViewController.randomizeColor(_:)),
                              keyEquivalent: "r")
        }

        menu.addItem(withSubmenuTitle: "View", localizedTitle: NSLocalizedString("View", comment: "")) { viewMenu in
            viewMenu.addItem(withTitle: NSLocalizedString("Show in Decimal", comment: ""),
                             action: nil, keyEquivalent: "")
            viewMenu.addItem(withTitle: NSLocalizedString("Show in Percentage", comment: ""),
                             action: nil, keyEquivalent: "")
            viewMenu.addSeparator()
            viewMenu.addItem(withTitle: NSLocalizedString("Show Colors", comment: ""),
                             action: #selector(showColorPicker),
                             keyEquivalent: "C")
            viewMenu.addItem(withTitle: NSLocalizedString("Show Gradient Chart", comment: ""),
                             action: #selector(showGradientWindow),
                             keyEquivalent: "H")
        }

        menu.addItem(withSubmenuTitle: "Window", localizedTitle: NSLocalizedString("Window", comment: "")) { windowMenu in
            windowMenu.addItem(withTitle: NSLocalizedString("Minimize", comment: ""),
                               action: #selector(NSWindow.performMiniaturize(_:)),
                               keyEquivalent: "m")
            windowMenu.addItem(withTitle: NSLocalizedString("Zoom", comment: ""),
                               action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
            windowMenu.addItem(withTitle: NSLocalizedString("Close", comment: ""),
                               action: #selector(NSWindow.performClose(_:)),
                               keyEquivalent: "w")
            windowMenu.addSeparator()
            windowMenu.addItem(withTitle: NSLocalizedString("Bring All to Front", comment: ""),
                               action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: "")
            NSApp.windowsMenu = windowMenu
        }

        menu.addItem(withSubmenuTitle: "Help", localizedTitle: NSLocalizedString("Help", comment: "")) { helpMenu in
            helpMenu.addItem(withTitle: NSLocalizedString("Project Website", comment: ""),
                             action: #selector(openProjectWebsite), keyEquivalent: "")
            helpMenu.addItem(withTitle: NSLocalizedString("Report an Issue", comment: ""),
                             action: #selector(reportIssue), keyEquivalent: "")
            NSApp.helpMenu = helpMenu
        }

        return menu
    }

    //
    // Menu stuff
    //

    @objc func showColorPicker() {
        colorPicker.showWindow(self)
    }

    @objc func showGradientWindow() {
        gradientChart.showWindow(self)
    }

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
