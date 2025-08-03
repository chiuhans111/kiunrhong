//
//  RGBColor.swift
//  Kiunrhong
//
// Color conversion functions reimplemented in Swift.
// Values adapted from W3C CSS Color Module spec.
//

import AppKit
import CoreGraphics

/// Represents a color in the RGB color space.
struct RGBColor: Vector3 {

    let r, g, b: Double
    var values: (Double, Double, Double) { (r, g, b) }

    init(_ r: Double, _ g: Double, _ b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }

    /// Create a Display P3 color from the values.
    func toNSColorInDisplayP3(alpha: CGFloat = 1.0) -> NSColor {
        .init(displayP3Red: self.r, green: self.g, blue: self.b, alpha: alpha)
    }

    /// Create a `CoreGraphics` color from the values, with the specified `CGColorSpace`.
    func toCGColor(withColorSpace colorSpace: CGColorSpace, alpha: CGFloat = 1.0) -> CGColor? {
        .init(colorSpace: colorSpace, components: [self.r, self.g, self.b, alpha])
    }

    static let linearP3toXYZ = Matrix3x3(
        (608311.0 / 1250200.0, 189793.0 / 714400.0,  198249.0 / 1000160.0),
        ( 35783.0 /  156275.0, 247089.0 / 357200.0,  198249.0 / 2500400.0),
        (                 0.0,  32229.0 / 714400.0, 5220557.0 / 5000800.0))

    /// Convert the color to XYZ color space. Color values are assumed to be in the Display P3 color space.
    func toXYZ() -> XYZColor {
        self.map { i in
            let abs_i = abs(i)
            if abs_i <= 0.04045 {
                return i / 12.92
            } else {
                let val  = pow((abs_i + 0.055) / 1.055, 2.4)
                return i < 0.0 ? -val : val
            }
        } * RGBColor.linearP3toXYZ
    }
}
