//
//  OKLabColor.swift
//  Kiunrhong
//
// Color conversion functions reimplemented in Swift.
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

    /// Convert a lightness value to relative scale (Lr).
    static func toRelativeLightness(_ l: Double) -> Double {
        let k3_l = (1 + 0.206) / (1 + 0.03) * l
        let dk = k3_l - 0.206
        return (dk + sqrt(dk * dk + 4 * 0.03 * k3_l)) / 2.0
    }

    /// Converts a lightness value from relative scale.
    static func fromRelativeLightness(_ lr: Double) -> Double {
        lr * (lr + 0.206) / ((1.206 / 1.02) * (lr + 0.03))
    }

    /// Minimum effective chroma.
    static let chromaEpsilon: Double = 0.000004

    //
    // Main conversion functions
    //

    static let oklabToLMS3 = Matrix3x3(
        (1.0,  0.3963377773761749,  0.2158037573099136),
        (1.0, -0.1055613458156586, -0.0638541728258133),
        (1.0, -0.0894841775298119, -1.2914855480194092))

    static let lmsToXYZ = Matrix3x3(
        ( 1.2268798758459243, -0.5578149944602171,  0.2813910456659647),
        (-0.0405757452148008,  1.1122868032803170, -0.0717110580655164),
        (-0.0763729366746601, -0.4214933324022432,  1.5869240198367816))

    static let xyzToLMS = Matrix3x3(
        (0.8190224379967030, 0.3619062600528904, -0.1288737815209879),
        (0.0329836539323885, 0.9292868615863434,  0.0361446663506424),
        (0.0481771893596242, 0.2642395317527308,  0.6335478284694309))

    static let lms3ToOKLab = Matrix3x3(
        (0.2104542683093140,  0.7936177747023054, -0.0040720430116193),
        (1.9779985324311684, -2.4285922420485799,  0.4505937096174110),
        (0.0259040424655478,  0.7827717124575296, -0.8086757549230774))

    /// Convert the OKLab color to an XYZ color.
    func toXYZ() -> XYZColor {
        ((self * OKLabColor.oklabToLMS3).cast() ** 3) * OKLabColor.lmsToXYZ
    }

    /// Convert the OKLab color to OKLCH representation. The color space remains unchanged.
    func toOKLCH() -> OKLCHColor {
        // Note: we skipped a `c <= epsilon` test here
        let c = sqrt(self.a * self.a + self.b * self.b)
        let h = atan2(self.b, self.a) * 180.0 / .pi
        return OKLCHColor(self.l, c, h < 0.0 ? h + 360.0 : h)
    }

    //
    // Premultiplied conversion functions
    //
    // These values are precalculated in `float128` with W3C reference implementation values.
    // Utilize these functions to cut rendering time.

    static let lmsToLinearP3 = Matrix3x3(
        (3.1283616399776282, -2.2583188611418157, 0.1304782704783530),
        (-1.0907196908026295, 2.4143049540498769, -0.3237262553320767),
        (-0.0260300288121365, -0.5083773063387490, 1.5343162453218291))

    static let linearP3ToLMS = Matrix3x3(
        (0.4167340191913979, 0.4753116030807249, 0.0724103366269894),
        (0.2140289579972230, 0.7464571772622752, 0.0460060797636696),
        (0.0518277711726535, 0.3179106254752030, 0.6629479003742361))

    /// Convert the OKLab color to Display P3 color space, utilizing precalculated matrices.
    func toDisplayP3() -> RGBColor {
        (((self * OKLabColor.oklabToLMS3) ** 3) * OKLabColor.lmsToLinearP3 as RGBColor).gammaCorrected()
    }
}

extension XYZColor {
    /// Convert the XYZ color to the OKLab color space.
    func toOKLab() -> OKLabColor {
        (self * OKLabColor.xyzToLMS).map(cbrt) * OKLabColor.lms3ToOKLab
    }
}

extension RGBColor {
    /// Convert from Display P3 color space to OKLab color space, utilizing precalculated matrices.
    func toOKLab() -> OKLabColor {
        (self.linearized() * OKLabColor.linearP3ToLMS).map(cbrt) * OKLabColor.lms3ToOKLab
    }
}
