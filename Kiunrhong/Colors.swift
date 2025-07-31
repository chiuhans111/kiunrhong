//
//  Colors.swift
//  Kiunrhong
//
//

import AppKit
import CoreGraphics

infix operator ** : MultiplicationPrecedence

struct Vector3 {
    let a1, a2, a3: Double

    init(_ a1: Double, _ a2: Double, _ a3: Double) {
        self.a1 = a1
        self.a2 = a2
        self.a3 = a3
    }

    static func * (_ lhs: Vector3, _ rhs: Matrix3x3) -> Vector3 {
        return .init(lhs.a1 * rhs.a11 + lhs.a2 * rhs.a12 + lhs.a3 * rhs.a13,
                     lhs.a1 * rhs.a21 + lhs.a2 * rhs.a22 + lhs.a3 * rhs.a23,
                     lhs.a1 * rhs.a31 + lhs.a2 * rhs.a32 + lhs.a3 * rhs.a33)
    }

    static func * (_ lhs: Vector3, _ rhs: Double) -> Vector3 {
        return .init(lhs.a1 * rhs, lhs.a2 * rhs, lhs.a3 * rhs)
    }

    static func ** (_ lhs: Vector3, _ rhs: Double) -> Vector3 {
        return .init(pow(lhs.a1, rhs), pow(lhs.a2, rhs), pow(lhs.a3, rhs))
    }

    func map(_ f: (Double) -> Double) -> Vector3 {
        return .init(f(a1), f(a2), f(a3))
    }
}

struct Matrix3x3 {
    let a11, a12, a13, a21, a22, a23, a31, a32, a33: Double

    init(_ a11: Double, _ a12: Double, _ a13: Double, _ a21: Double, _ a22: Double, _ a23: Double, _ a31: Double, _ a32: Double, _ a33: Double) {
        self.a11 = a11
        self.a12 = a12
        self.a13 = a13
        self.a21 = a21
        self.a22 = a22
        self.a23 = a23
        self.a31 = a31
        self.a32 = a32
        self.a33 = a33
    }
}

struct Conversion {

    static let oklabToLMS = Matrix3x3(
        1.0,  0.3963377773761749,  0.2158037573099136,
        1.0, -0.1055613458156586, -0.0638541728258133,
        1.0, -0.0894841775298119, -1.2914855480194092)

    static let lmsToXYZ = Matrix3x3(
         1.2268798758459243, -0.5578149944602171,  0.2813910456659647,
        -0.0405757452148008,  1.1122868032803170, -0.0717110580655164,
        -0.0763729366746601, -0.4214933324022432,  1.5869240198367816)

    static let xyzToLinearP3 = Matrix3x3(
        446124.0 / 178915.0, -333277.0 / 357830.0, -72051.0 / 178915.0,
        -14852.0 /  17905.0,   63121.0 /  35810.0,    423.0 /  17905.0,
         11844.0 / 330415.0,  -50337.0 / 660830.0, 316169.0 / 330415.0)

    static let xyzToLinearRec2020 = Matrix3x3(
         30757411.0 / 17917100.0, -6372589.0 / 17917100.0, -4539589.0 / 17917100.0,
        -19765991.0 / 29648200.0, 47925759.0 / 29648200.0,   467509.0 / 29648200.0,
           792561.0 / 44930125.0, -1921689.0 / 44930125.0, 42328811.0 / 44930125.0)

}

typealias OKLCHColor = Vector3
typealias XYZColor = Vector3
typealias RGBColor = Vector3

extension Vector3 {

    func oklchToXYZ() -> XYZColor {
        let oklab = Vector3(/* l: */ self.a1,
                            /* a: */ self.a2 * cos(self.a3 * .pi / 180.0),
                            /* b: */ self.a2 * sin(self.a3 * .pi / 180.0))
        return ((oklab * Conversion.oklabToLMS) ** 3) * Conversion.lmsToXYZ
    }

    func xyzToDisplayP3() -> RGBColor {
        return (self * Conversion.xyzToLinearP3).map { i in
            let abs_i = abs(i)
            if abs_i > 0.0031308 {
                let val = 1.055 * pow(abs_i, 1.0 / 2.4) - 0.055
                return i < 0.0 ? -val : val
            } else {
                return i * 12.92
            }
        }
    }

    func xyzToRec2020() -> RGBColor {
        return (self * Conversion.xyzToLinearRec2020).map { i in
            let abs_i = abs(i)
            if abs_i > 0.018053968510807 {
                let val = 1.09929682680944 * pow(abs_i, 0.45) - 0.09929682680944
                return i < 0.0 ? -val : val
            } else {
                return i * 4.5
            }
        }
    }

    /// Creates a Display P3 color from the values.
    func toDisplayP3Color(alpha: CGFloat = 1.0) -> NSColor {
        return .init(displayP3Red: self.a1, green: self.a2, blue: self.a3, alpha: alpha)
    }

    /// Creates a `CoreGraphics` color from the values, with the specified `CGColorSpace`.
    func toCGColor(withColorSpace colorSpace: CGColorSpace, alpha: CGFloat = 1.0) -> CGColor? {
        return .init(colorSpace: colorSpace, components: [self.a1, self.a2, self.a3, alpha])
    }

}
