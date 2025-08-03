//
//  OKLabColor.swift
//  Kiunrhong
//
// Color conversion functions reimplemented in Swift.
// Values adapted from W3C CSS Color Module spec.
//

import Foundation

/// Represents a color in the OKLab color space.
struct OKLabColor: Vector3 {

    let l, a, b: Double
    var values: (Double, Double, Double) { (l, a, b) }

    init(_ l: Double, _ a: Double, _ b: Double) {
        self.l = l
        self.a = a
        self.b = b
    }

    /// Relative lightness for the construction of OKLrCH.
    var relativeLightness: Double {
        let k3_l = (1 + 0.206) / (1 + 0.03) * self.l
        let dk = k3_l - 0.206
        return (dk + sqrt(dk * dk + 4 * 0.03 * k3_l)) / 2.0
    }

    /// Minimum effective chroma.
    static let chromaEpsilon: Double = 0.000004

    static let oklabToLMS_ = Matrix3x3(
        (1.0,  0.3963377773761749,  0.2158037573099136),
        (1.0, -0.1055613458156586, -0.0638541728258133),
        (1.0, -0.0894841775298119, -1.2914855480194092))

    static let lms_ToOKLab = Matrix3x3(
        (0.2104542683093140,  0.7936177747023054, -0.0040720430116193),
        (1.9779985324311684, -2.4285922420485799,  0.4505937096174110),
        (0.0259040424655478,  0.7827717124575296, -0.8086757549230774))

    /// Convert the OKLab color to an LMS color.
    func toLMS() -> LMSColor {
        (self * OKLabColor.oklabToLMS_).cast() ** 3
    }

    /// Convert the OKLab color to OKLCH representation. The color space remains unchanged.
    func toOKLCH() -> OKLCHColor {
        // Note: we skipped a `c <= epsilon` test here
        let c = sqrt(self.a * self.a + self.b * self.b)
        let h = atan2(self.b, self.a) * 180.0 / .pi
        return OKLCHColor(self.l, c, h < 0.0 ? h + 360.0 : h)
    }
}

extension LMSColor {
    /// Convert the LMS color to the OKLab color space.
    func toOKLab() -> OKLabColor {
        self.map(cbrt) * OKLabColor.lms_ToOKLab
    }
}
