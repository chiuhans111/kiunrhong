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

    static let oklabToLMS3 = Matrix3x3(
        (1.0,  0.3963377773761749,   0.21580375730991364),
        (1.0, -0.10556134581565857, -0.0638541728258133 ),
        (1.0, -0.08948417752981186, -1.2914855480194092 ))

    static let lmsToXYZ = Matrix3x3(
        ( 1.226879875845924,   -0.5578149944602171,   0.2813910456659647),
        (-0.04057574521480083,  1.112286803280317,   -0.07171105806551635),
        (-0.07637293667466008, -0.42149333240224324,  1.5869240198367818))

    static let xyzToLMS = Matrix3x3(
        (0.8190224379967030, 0.3619062600528904, -0.1288737815209879),
        (0.0329836539323885, 0.9292868615863434,  0.0361446663506424),
        (0.0481771893596242, 0.2642395317527308,  0.6335478284694309))

    static let lms3ToOKLab = Matrix3x3(
        (0.21045426830931396,   0.7936177747023053, -0.0040720430116192585),
        (1.9779985324311686,   -2.42859224204858,    0.450593709617411),
        (0.025904042465547734,  0.7827717124575297, -0.8086757549230774))

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
}

extension XYZColor {
    /// Convert the XYZ color to the OKLab color space.
    func toOKLab() -> OKLabColor {
        (self * OKLabColor.xyzToLMS).map(cbrt) * OKLabColor.lms3ToOKLab
    }
}
