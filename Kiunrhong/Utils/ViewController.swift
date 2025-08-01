//
//  ViewController.swift
//  Kiunrhong
//
//

import AppKit

class ViewController<View: NSView>: NSViewController {

    var this: View {
        return self.view as! View
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = View()
    }
}
