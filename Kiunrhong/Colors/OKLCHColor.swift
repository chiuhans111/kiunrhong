//
//  Colors.swift
//  Kiunrhong
//
// Color conversion functions reimplemented in Swift.
// Values adapted from W3C CSS Color Module spec.
//

import Foundation

/// Represents a color in the OKLCH color space.
struct OKLCHColor: Vector3 {

    let l, c, h: Double
    var values: (Double, Double, Double) { (l, c, h) }

    init(_ l: Double, _ c: Double, _ h: Double) {
        self.l = l
        self.c = c
        self.h = h
    }

    /// Relative lightness for the construction of OKLrCH.
    var relativeLightness: Double {
        let k3_l = (1 + 0.206) / (1 + 0.03) * self.l
        let dk = k3_l - 0.206
        return (dk + sqrt(dk * dk + 4 * 0.03 * k3_l)) / 2.0
    }

    static let chromaEpsilon: Double = 0.000004

    static let oklabToLMS = Matrix3x3(
        (1.0,  0.3963377773761749,  0.2158037573099136),
        (1.0, -0.1055613458156586, -0.0638541728258133),
        (1.0, -0.0894841775298119, -1.2914855480194092))

    static let lmsToXYZ = Matrix3x3(
        ( 1.2268798758459243, -0.5578149944602171,  0.2813910456659647),
        (-0.0405757452148008,  1.1122868032803170, -0.0717110580655164),
        (-0.0763729366746601, -0.4214933324022432,  1.5869240198367816))

    /// Converts the OKLCH color to an XYZ color.
    func toXYZ() -> XYZColor {
        // We don’t create a separate type for OKLab color as it’s largely intermediary.
        let oklab = GenericColor(/* l: */ self.l,
                                 /* a: */ self.c * cos(self.h * .pi / 180.0),
                                 /* b: */ self.c * sin(self.h * .pi / 180.0))
        return (((oklab * OKLCHColor.oklabToLMS) ** 3) * OKLCHColor.lmsToXYZ).cast()
    }
}
