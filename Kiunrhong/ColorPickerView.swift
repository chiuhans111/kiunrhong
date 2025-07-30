//
//  ColorPickerView.swift
//  Kiunrhong
//
//

import AppKit
import MetalKit

class ColorPickerView : NSView {

    var spectrumView: ColorSpectrumView!

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.translatesAutoresizingMaskIntoConstraints = false

        self.spectrumView = ColorSpectrumView(frame: frameRect)
        spectrumView.translatesAutoresizingMaskIntoConstraints = false
        spectrumView.widthAnchor.constraint(equalTo: spectrumView.heightAnchor).isActive = true
        self.addSubview(spectrumView)

        spectrumView.widthAnchor.constraint(lessThanOrEqualTo: self.layoutMarginsGuide.widthAnchor).isActive = true
        spectrumView.heightAnchor.constraint(lessThanOrEqualTo: self.layoutMarginsGuide.heightAnchor, multiplier: 1).isActive = true
        spectrumView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        spectrumView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

    required init(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
}

#if DEBUG
import SwiftUI
struct ColorPickerView_Preview : View, NSViewRepresentable {
    typealias NSViewType = ColorPickerView

    func makeNSView(context: Context) -> NSViewType {
        return NSViewType()
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
    }
}

#Preview {
    ZStack {
        ColorPickerView_Preview()
    }.frame(width: 480, height: 480)
}
#endif
