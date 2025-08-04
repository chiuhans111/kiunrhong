//
//  OKLCHColor.swift
//  Kiunrhong
//
// Color conversion functions reimplemented in Swift.
// Values adapted from W3C CSS Color Module spec.
//

import Foundation

/// Represents a OKLCH color in the OKLab color space.
struct OKLCHColor: Vector3 {

    let l, c, h: Double
    var values: (Double, Double, Double) { (l, c, h) }

    init(_ l: Double, _ c: Double, _ h: Double) {
        self.l = l
        self.c = c
        self.h = h
    }

    /// Convert the OKLCH color to OKLab representation. The color space remains unchanged.
    func toOKLab() -> OKLabColor {
        .init(self.l, self.c * cos(self.h * .pi / 180.0), self.c * sin(self.h * .pi / 180.0))
    }

    /// Convenience function to convert the OKLCH color to Display P3 color space.
    func toDisplayP3() -> RGBColor {
        self.toOKLab().toDisplayP3()
    }
}
