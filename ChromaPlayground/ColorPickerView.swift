//
//  ColorPickerView.swift
//  ChromaPlayground
//
//

import AppKit

class ColorPickerView : NSView {

    let colorSpace = CGColorSpace(name: CGColorSpace.displayP3)!
    let lightness = 0.7, chroma = 0.168 // at the P3 edge when h=268
    // at c = 0.16, two suitable P3 edges (l, h) have been determined to be usable for the color ring: (0.6784, 88.41) and (0.715, 268)
    // for Rec2020, consider using (0.6638, 88.41)

    override func draw(_ dirtyRect: NSRect) {
        let bound = self.bounds.insetBy(dx: 32, dy: 32)
        let middle = NSPoint(x: bound.midX, y: bound.midY)

        let callback: CGFunctionEvaluateCallback = { info, inData, outData in
            let percentage = inData[0]
            let oklch: Vector3 = (l: 0.7, c: 0.168, h: 360.0 * percentage)
            let p3 = xyzToP3(oklchToXYZ(oklch))
            outData[0] = p3.0
            outData[1] = p3.1
            outData[2] = p3.2
            outData[3] = 1
        }

        let domain: [CGFloat] = [0, 1]
        let range: [CGFloat] = [0, 1, 0, 1, 0, 1, 0, 1]
        var callbacks = CGFunctionCallbacks(version: 0, evaluate: callback, releaseInfo: nil)
        let function = CGFunction(info: nil, domainDimension: domain.count / 2, domain: domain, rangeDimension: range.count / 2, range: range, callbacks: &callbacks)!

        let shading = CGShading(axialSpace: colorSpace, start: .init(x: bound.minX, y: bound.minY), end: .init(x: bound.maxX, y: bound.maxY), function: function, extendStart: true, extendEnd: true)!

        let context = NSGraphicsContext.current!.cgContext
        context.drawShading(shading)
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
