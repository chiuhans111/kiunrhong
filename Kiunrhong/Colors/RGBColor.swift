//
//  RGBColor.swift
//  Kiunrhong
//
// Color conversion functions reimplemented in Swift.
// Values adapted from W3C CSS Color Module spec.
//

import AppKit
import CoreGraphics

struct RGBColor: Vector3 {

    let r, g, b: Double
    var values: (Double, Double, Double) { (r, g, b) }

    init(_ r: Double, _ g: Double, _ b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }

    /// Creates a Display P3 color from the values.
    func toDisplayP3Color(alpha: CGFloat = 1.0) -> NSColor {
        return .init(displayP3Red: self.r, green: self.g, blue: self.b, alpha: alpha)
    }

    /// Creates a `CoreGraphics` color from the values, with the specified `CGColorSpace`.
    func toCGColor(withColorSpace colorSpace: CGColorSpace, alpha: CGFloat = 1.0) -> CGColor? {
        return .init(colorSpace: colorSpace, components: [self.r, self.g, self.b, alpha])
    }
}
