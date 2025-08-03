//
//  ColorPickerView.swift
//  Kiunrhong
//

import AppKit

class ColorGradientView : NSView {

    override func draw(_ dirtyRect: NSRect) {
        let c1 = OKLCHColor(0.8647, 0.3398, 141.88).toOKLab().toXYZ()
        let c2 = OKLCHColor(0.7133, 0.3478, 331.41).toOKLab().toXYZ()    // These two colors are only available in P3 space
        let c3 = OKLCHColor(0.8325, 0.46, 152.1).toOKLab().toXYZ()
        let c4 = OKLCHColor(0.742, 0.4205, 337).toOKLab().toXYZ()        // These two colors are only available in Rec2020 space

        let displayP3 = CGColorSpace(name: CGColorSpace.displayP3)!
        let rec2020 = CGColorSpace(name: CGColorSpace.itur_2020)!

        let gradients = [
            (NSColor(cgColor: c1.toRec2020().toCGColor(withColorSpace: rec2020)!)!,
             NSColor(cgColor: c2.toRec2020().toCGColor(withColorSpace: rec2020)!)!), // P3-only color to Rec2020
            (NSColor(cgColor: c1.toDisplayP3().toCGColor(withColorSpace: displayP3)!)!,
             NSColor(cgColor: c2.toDisplayP3().toCGColor(withColorSpace: displayP3)!)!),  // P3-only color to P3
            (c1.toDisplayP3().toNSColorInDisplayP3(),
             c2.toDisplayP3().toNSColorInDisplayP3()), // P3-only color to P3
            (NSColor(displayP3Red: 0.3818, green: 0.9995, blue: 0.0311, alpha: 1.0),
             NSColor(displayP3Red: 0.973, green: 0.0835, blue: 0.9733, alpha: 1.0)), // P3-only color comparison
            (c3.toDisplayP3().toNSColorInDisplayP3(),
             c4.toDisplayP3().toNSColorInDisplayP3()), // Rec2020-only color to P3
            (NSColor(cgColor: c3.toRec2020().toCGColor(withColorSpace: rec2020)!)!,
             NSColor(cgColor: c4.toRec2020().toCGColor(withColorSpace: rec2020)!)!), // Rec2020-only color to Rec2020
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
struct ColorGradientView_Preview : View, NSViewRepresentable {
    typealias NSViewType = ColorGradientView

    func makeNSView(context: Context) -> NSViewType {
        return NSViewType()
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
    }
}

#Preview {
    ZStack {
        ColorGradientView_Preview()
    }.frame(width: 480, height: 560)
}
#endif
