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

    /// Relative lightness for the construction of OKLrCH.
    var relativeLightness: Double {
        let k3_l = (1 + 0.206) / (1 + 0.03) * self.l
        let dk = k3_l - 0.206
        return (dk + sqrt(dk * dk + 4 * 0.03 * k3_l)) / 2.0
    }

    /// Minimum effective chroma.
    static let chromaEpsilon: Double = 0.000004

    //
    // Main conversion functions
    //
    // These values were adapted from the W3C reference implementation.

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
        ( 3.127768971361873753, -2.257135762591638368,  0.129366791229765164),
        (-1.091009018437797782,  2.413331710306922162, -0.322322691869124789),
        (-0.026010801938570483, -0.508041331704166866,  1.53405213364273723 ))

    static let linearP3ToLMS = Matrix3x3(
        (0.481379852749954441, 0.462118371011318044, 0.056501776238727554),
        (0.22883194181124476 , 0.653216819383567598, 0.117951238805187788),
        (0.083945752322993189, 0.22416527097756641 , 0.691888976699440452))

    /// Convert the OKLab color to linear Display P3 color space, utilizing precalculated matrices.
    func toLinearP3() -> RGBColor {
        ((self * OKLabColor.oklabToLMS3) ** 3) * OKLabColor.lmsToLinearP3
    }

    /// Convert the OKLab color to Display P3 color space, utilizing precalculated matrices.
    func toDisplayP3() -> RGBColor {
        toLinearP3().gammaCorrected()
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
