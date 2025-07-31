//
//  Colors.swift
//  Kiunrhong
//
//

import AppKit
import CoreGraphics

struct OKLCHColor: Vector3 {

    let l, c, h: Double
    var values: (Double, Double, Double) { (l, c, h) }

    init(_ l: Double, _ c: Double, _ h: Double) {
        self.l = l
        self.c = c
        self.h = h
    }

    static let oklabToLMS = Matrix3x3(
        (1.0,  0.3963377773761749,  0.2158037573099136),
        (1.0, -0.1055613458156586, -0.0638541728258133),
        (1.0, -0.0894841775298119, -1.2914855480194092))

    static let lmsToXYZ = Matrix3x3(
        ( 1.2268798758459243, -0.5578149944602171,  0.2813910456659647),
        (-0.0405757452148008,  1.1122868032803170, -0.0717110580655164),
        (-0.0763729366746601, -0.4214933324022432,  1.5869240198367816))

    func toXYZ() -> XYZColor {
        // It’s not actually XYZ yet but we’ll use this from the start to avoid casting
        let oklab = XYZColor(/* l: */ self.l,
                             /* a: */ self.c * cos(self.h * .pi / 180.0),
                             /* b: */ self.c * sin(self.h * .pi / 180.0))
        return ((oklab * OKLCHColor.oklabToLMS) ** 3) * OKLCHColor.lmsToXYZ
    }
}

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

    func toDisplayP3() -> RGBColor {
        return (self * XYZColor.xyzToLinearP3).map { i in
            let abs_i = abs(i)
            if abs_i > 0.0031308 {
                let val = 1.055 * pow(abs_i, 1.0 / 2.4) - 0.055
                return i < 0.0 ? -val : val
            } else {
                return i * 12.92
            }
        }
    }

    func toRec2020() -> RGBColor {
        return (self * XYZColor.xyzToLinearRec2020).map { i in
            let abs_i = abs(i)
            if abs_i > 0.018053968510807 {
                let val = 1.09929682680944 * pow(abs_i, 0.45) - 0.09929682680944
                return i < 0.0 ? -val : val
            } else {
                return i * 4.5
            }
        }
    }
}

struct RGBColor: Vector3 {

    let r, g, b: Double
    var values: (Double, Double, Double) { (r, g, b) }

    init(_ r: Double, _ g: Double, _ b: Double) {
        self.r = r
        self.g = g
        self.b = b
    }

    /// Creates a Display P3 color from the values.
    func toDisplayP3Color(alpha: CGFloat = 1.0) -> NSColor {
        return .init(displayP3Red: self.r, green: self.g, blue: self.b, alpha: alpha)
    }

    /// Creates a `CoreGraphics` color from the values, with the specified `CGColorSpace`.
    func toCGColor(withColorSpace colorSpace: CGColorSpace, alpha: CGFloat = 1.0) -> CGColor? {
        return .init(colorSpace: colorSpace, components: [self.r, self.g, self.b, alpha])
    }
}
