//
//  AppDelegate.swift
//  Kiunrhong
//
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowRestoration {

    var colorPicker: ColorPickerWindowController!
    var gradientWindow: NSWindow?

    func createApplicationMenu() -> NSMenu {
        let menu = NSMenu(title: "Main Menu")
        let appName = NSRunningApplication.current.localizedName ?? "Kiunrhong"

        menu.addItem(withSubmenuTitle: "Application") { appMenu in
            appMenu.addItem(withTitle: "About \(appName)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:))) { aboutMenuItem in
                aboutMenuItem.image = NSImage(systemSymbolName: "loupe", accessibilityDescription: nil)
            }
            appMenu.addSeparator()
            appMenu.addItem(withSubmenuTitle: "Services") { servicesMenu in
                NSApp.servicesMenu = servicesMenu
            }
            appMenu.addSeparator()
            appMenu.addItem(withTitle: "Hide \(appName)", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
            appMenu.addItem(withTitle: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h") { hideOthersMenuItem in
                hideOthersMenuItem.keyEquivalentModifierMask = [.command, .option]
            }
            appMenu.addItem(withTitle: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
            appMenu.addSeparator()
            appMenu.addItem(withTitle: "Quit \(appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        }

        menu.addItem(withSubmenuTitle: "Edit") { editMenu in
            editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
            editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
            editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
            editMenu.addItem(withTitle: "Delete", action: #selector(NSText.delete(_:)), keyEquivalent: String(UnicodeScalar(NSBackspaceCharacter)!))
            editMenu.addSeparator()
            editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        }.isHidden = true   // Hides the Edit menu but retains the action

        menu.addItem(withSubmenuTitle: "Color") { colorMenu in
            colorMenu.addItem(withTitle: "Copy Color", action: #selector(ColorPickerViewController.copyCurrentColor(_:)), keyEquivalent: "C")
            colorMenu.addItem(withTitle: "Paste Color", action: #selector(ColorPickerViewController.pasteColor(_:)), keyEquivalent: "P")
            colorMenu.addSeparator()
            colorMenu.addItem(withTitle: "Sample Color", action: #selector(ColorPickerViewController.sampleColor(_:)), keyEquivalent: "")
            colorMenu.addItem(withTitle: "Randomize", action: #selector(ColorPickerViewController.randomizeColor(_:)), keyEquivalent: "R")
        }

        menu.addItem(withSubmenuTitle: "View") { viewMenu in
            viewMenu.addItem(withTitle: "Show in Decimal", action: nil, keyEquivalent: "")
            viewMenu.addItem(withTitle: "Show in Percentage", action: nil, keyEquivalent: "")
            viewMenu.addSeparator()
            viewMenu.addItem(withTitle: "Display Gradient", action: #selector(showGradientWindow), keyEquivalent: "")
        }

        menu.addItem(withSubmenuTitle: "Window") { windowMenu in
            windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
            windowMenu.addItem(withTitle: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
            windowMenu.addSeparator()
            windowMenu.addItem(withTitle: "Bring All to Front", action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: "")
            NSApp.windowsMenu = windowMenu
        }

        menu.addItem(withSubmenuTitle: "Help") { helpMenu in
            helpMenu.addItem(withTitle: "Project Website", action: #selector(openProjectWebsite), keyEquivalent: "")
            helpMenu.addItem(withTitle: "Report an Issue", action: #selector(reportIssue), keyEquivalent: "")
            NSApp.helpMenu = helpMenu
        }

        return menu
    }

    //
    // Menu stuff
    //

    @objc func showGradientWindow() {
        if gradientWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered, defer: false)
            window.title = "Gradient"
            window.titlebarAppearsTransparent = true
            window.contentView = ColorGradientView()
            window.setIsZoomed(true)
            self.gradientWindow = window
        }
        gradientWindow!.makeKeyAndOrderFront(self)
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
