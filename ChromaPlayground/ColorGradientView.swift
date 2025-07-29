//
//  ColorPickerView.swift
//  ChromaPlayground
//

import AppKit

class ColorPickerView : NSView {

    override func draw(_ dirtyRect: NSRect) {
        let gradients = [
            (NSColor(oklchToRec2020L: 0.8647, c: 0.3398, h: 141.88), NSColor(oklchToRec2020L: 0.7133, c: 0.3478, h: 331.41)), // P3-only color to Rec2020
            (NSColor(oklchToDisplayP3L: 0.8647, c: 0.3398, h: 141.88), NSColor(oklchToDisplayP3L: 0.7133, c: 0.3478, h: 331.41)),  // P3-only color to P3
            (NSColor(oklchL: 0.8647, c: 0.3398, h: 141.88), NSColor(oklchL: 0.7133, c: 0.3478, h: 331.41)), // P3-only color to P3
            (NSColor(displayP3Red: 0.3818, green: 0.9995, blue: 0.0311, alpha: 1.0), NSColor(displayP3Red: 0.973, green: 0.0835, blue: 0.9733, alpha: 1.0)), // P3-only color
            (NSColor(oklchL: 0.8325, c: 0.46, h: 152.1), NSColor(oklchL: 0.742, c: 0.4205, h: 337)), // Rec2020-only color to P3
            (NSColor(oklchToRec2020L: 0.8325, c: 0.46, h: 152.1), NSColor(oklchToRec2020L: 0.742, c: 0.4205, h: 337)), // Rec2020-only color to Rec2020
        ]
        let bounds = self.bounds
        let size = CGSize(width: bounds.width / CGFloat(gradients.count), height: bounds.height)

        var i = 0
        for case let (start, end) in gradients {
            let gradient = NSGradient(starting: start, ending: end)
            let bound = NSRect(origin: .init(x: bounds.minX + size.width * CGFloat(i), y: bounds.minY), size: size)
            gradient?.draw(in: bound, angle: 90.0)
            i += 1
        }
    }
}

#if DEBUG
import SwiftUI
struct ColorPickerView_Preview : View, NSViewRepresentable {
    typealias NSViewType = ColorPickerView

    func makeNSView(context: Context) -> ColorPickerView {
        return ColorPickerView()
    }
    
    func updateNSView(_ nsView: ColorPickerView, context: Context) {
    }
}

#Preview {
    ZStack {
        ColorPickerView_Preview()
    }.frame(width: 480, height: 560)
}
#endif
