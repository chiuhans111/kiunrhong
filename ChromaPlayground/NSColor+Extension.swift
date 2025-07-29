//
//  NSColor+Extension.swift
//  ChromaPlayground
//
//

import AppKit
import CoreGraphics

let oklabToLMS = Matrix3x3(1.0,  0.3963377773761749,  0.2158037573099136,
                           1.0, -0.1055613458156586, -0.0638541728258133,
                           1.0, -0.0894841775298119, -1.2914855480194092)

let lmsToXYZ = Matrix3x3( 1.2268798758459243, -0.5578149944602171,  0.2813910456659647,
                         -0.0405757452148008,  1.1122868032803170, -0.0717110580655164,
                         -0.0763729366746601, -0.4214933324022432,  1.5869240198367816)

let xyzToLinearP3 = Matrix3x3(446124.0 / 178915.0, -333277.0 / 357830.0, -72051.0 / 178915.0,
                              -14852.0 /  17905.0,   63121.0 /  35810.0,    423.0 /  17905.0,
                               11844.0 / 330415.0,  -50337.0 / 660830.0, 316169.0 / 330415.0)

let xyzToLinear2020 = Matrix3x3( 30757411.0 / 17917100.0, -6372589.0 / 17917100.0, -4539589.0 / 17917100.0,
                                -19765991.0 / 29648200.0, 47925759.0 / 29648200.0,   467509.0 / 29648200.0,
                                   792561.0 / 44930125.0, -1921689.0 / 44930125.0, 42328811.0 / 44930125.0)

extension NSColor {

    convenience init(oklchL: CGFloat, c: CGFloat, h: CGFloat, alpha: CGFloat = 1.0) {
        let xyz = oklchToXYZ((oklchL, c, h))
        let p3 = matrixMultiply(xyzToLinearP3, xyz)
        self.init(displayP3Red: gammaCorrectSRGB(p3.0), green: gammaCorrectSRGB(p3.1), blue: gammaCorrectSRGB(p3.2), alpha: alpha)
        print(self, self.cgColor)
    }

    convenience init(oklchToDisplayP3L: CGFloat, c: CGFloat, h: CGFloat, alpha: CGFloat = 1.0) {
        let xyz = oklchToXYZ((oklchToDisplayP3L, c, h))
        let p3 = matrixMultiply(xyzToLinearP3, xyz)
        let components = [gammaCorrectSRGB(p3.0),
                          gammaCorrectSRGB(p3.1),
                          gammaCorrectSRGB(p3.2),
                          alpha]
        let cgColorSpace = CGColorSpace(name: CGColorSpace.displayP3)!
        let nsColorSpace = NSColorSpace(cgColorSpace: cgColorSpace)!
        self.init(colorSpace: nsColorSpace, components: components, count: components.count)
        print(self, self.cgColor)
    }

    convenience init(oklchToRec2020L: CGFloat, c: CGFloat, h: CGFloat, alpha: CGFloat = 1.0) {
        let xyz = oklchToXYZ((oklchToRec2020L, c, h))
        let rec2020 = matrixMultiply(xyzToLinear2020, xyz)
        let components = [gammaCorrectRec2020(rec2020.0),
                          gammaCorrectRec2020(rec2020.1),
                          gammaCorrectRec2020(rec2020.2),
                          alpha]
        let cgColorSpace = CGColorSpace(name: CGColorSpace.itur_2020)!
        let nsColorSpace = NSColorSpace(cgColorSpace: cgColorSpace)!
        self.init(colorSpace: nsColorSpace, components: components, count: components.count)
        print(self, self.cgColor)
    }

}

typealias Vector3 = (CGFloat, CGFloat, CGFloat)
typealias Matrix3x3 = (CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)

func matrixMultiply(_ lhs: Matrix3x3, _ rhs: Vector3) -> Vector3 {
    return (
        lhs.0 * rhs.0 + lhs.1 * rhs.1 + lhs.2 * rhs.2,
        lhs.3 * rhs.0 + lhs.4 * rhs.1 + lhs.5 * rhs.2,
        lhs.6 * rhs.0 + lhs.7 * rhs.1 + lhs.8 * rhs.2
        )
}

func oklchToXYZ(_ oklch: Vector3) -> Vector3 {
    let oklab = (
        l: oklch.0,
        a: oklch.1 * cos(oklch.2 * .pi / 180.0),
        b: oklch.1 * sin(oklch.2 * .pi / 180.0)
    )
    let lms = matrixMultiply(oklabToLMS, oklab)
    return matrixMultiply(lmsToXYZ, (pow(lms.0, 3), pow(lms.1, 3), pow(lms.2, 3)))
}

func gammaCorrectSRGB(_ a: CGFloat) -> CGFloat {
    let abs_a = abs(a)
    if abs_a > 0.0031308 {
        let val = 1.055 * pow(abs_a, 1.0 / 2.4) - 0.055
        return a < 0.0 ? -val : val
    } else {
        return a * 12.92
    }
}

func gammaCorrectRec2020(_ i: CGFloat) -> CGFloat {
    let abs_i = abs(i)
    if abs_i > 0.018053968510807 {
        let val = 1.09929682680944 * pow(abs_i, 0.45) - 0.09929682680944
        return i < 0.0 ? -val : val
    } else {
        return i * 4.5
    }
}
