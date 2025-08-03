//
//  XYZColor.swift
//  Kiunrhong
//
// Color conversion functions reimplemented in Swift.
// Values adapted from W3C CSS Color Module spec.
//

import Foundation

/// Represents a color in the XYZ color space.
struct XYZColor: Vector3 {

    let x, y, z: Double
    var values: (Double, Double, Double) { (x, y, z) }

    init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    static let xyzToLinearP3 = Matrix3x3(
        (446124.0 / 178915.0, -333277.0 / 357830.0, -72051.0 / 178915.0),
        (-14852.0 /  17905.0,   63121.0 /  35810.0,    423.0 /  17905.0),
        ( 11844.0 / 330415.0,  -50337.0 / 660830.0, 316169.0 / 330415.0))

    static let xyzToLinearRec2020 = Matrix3x3(
        ( 30757411.0 / 17917100.0, -6372589.0 / 17917100.0, -4539589.0 / 17917100.0),
        (-19765991.0 / 29648200.0, 47925759.0 / 29648200.0,   467509.0 / 29648200.0),
        (   792561.0 / 44930125.0, -1921689.0 / 44930125.0, 42328811.0 / 44930125.0))

    static let xyzToLMS = Matrix3x3(
        (0.8190224379967030, 0.3619062600528904, -0.1288737815209879),
        (0.0329836539323885, 0.9292868615863434,  0.0361446663506424),
        (0.0481771893596242, 0.2642395317527308,  0.6335478284694309))

    static let lmsToOKLab = Matrix3x3(
        (0.2104542683093140,  0.7936177747023054, -0.0040720430116193),
        (1.9779985324311684, -2.4285922420485799,  0.4505937096174110),
        (0.0259040424655478,  0.7827717124575296, -0.8086757549230774))

    /// Convert the XYZ color to Display P3 color space.
    func toDisplayP3() -> RGBColor {
        (self * XYZColor.xyzToLinearP3).map { i in
            let abs_i = abs(i)
            if abs_i > 0.0031308 {
                let val = 1.055 * pow(abs_i, 1.0 / 2.4) - 0.055
                return i < 0.0 ? -val : val
            } else {
                return i * 12.92
            }
        }
    }

    /// Convert the XYZ color to ITU-R BT.2020-2 (Rec.2020) color space.
    func toRec2020() -> RGBColor {
        (self * XYZColor.xyzToLinearRec2020).map { i in
            let abs_i = abs(i)
            if abs_i > 0.018053968510807 {
                let val = 1.09929682680944 * pow(abs_i, 0.45) - 0.09929682680944
                return i < 0.0 ? -val : val
            } else {
                return i * 4.5
            }
        }
    }

    /// Convert the XYZ color to OKLCH color space.
    func toOKLCH() -> OKLCHColor {
        let oklab: GenericColor = (self * XYZColor.xyzToLMS).map(cbrt) * XYZColor.lmsToOKLab
        let c = sqrt(oklab.b * oklab.b + oklab.c * oklab.c)
        let h = atan2(oklab.c, oklab.b) * 180.0 / .pi
        return OKLCHColor(oklab.a, c, h < 0.0 ? h + 360.0 : h)
    }
}
