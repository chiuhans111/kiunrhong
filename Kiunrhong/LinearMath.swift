//
//  LinearMath.swift
//  Kiunrhong
//
//

import Foundation

/// Represents a generic vector with three components.
protocol Vector3 {

    /// Access the values of the vector in a tuple.
    var values: (Double, Double, Double) { get }

    /// Initialize a vector with three components.
    init(_ a1: Double, _ a2: Double, _ a3: Double)
}

/// Multiply a vector by a matrix.
func * <T: Vector3>(_ lhs: T, _ rhs: Matrix3x3) -> T {
    let vec = lhs.values
    let m = rhs.values
    return .init(vec.0 * m.0.0 + vec.1 * m.0.1 + vec.2 * m.0.2,
                 vec.0 * m.1.0 + vec.1 * m.1.1 + vec.2 * m.1.2,
                 vec.0 * m.2.0 + vec.1 * m.2.1 + vec.2 * m.2.2)
}

/// Multiply a vector by a scalar.
func * <T: Vector3>(_ lhs: T, _ rhs: Double) -> T {
    let vec = lhs.values
    return .init(vec.0 * rhs, vec.1 * rhs, vec.2 * rhs)
}

infix operator ** : MultiplicationPrecedence

/// Raise a vector to a power.
func ** <T: Vector3>(_ lhs: T, _ rhs: Double) -> T {
    let vec = lhs.values
    return .init(pow(vec.0, rhs), pow(vec.1, rhs), pow(vec.2, rhs))
}

extension Vector3 {
    /// Apply a function to each component of the vector.
    func map<T: Vector3>(_ f: (Double) -> Double) -> T {
        let vec = self.values
        return .init(f(vec.0), f(vec.1), f(vec.2))
    }

    /// Cast the vector to a different type, preserving the values.
    func cast<T: Vector3>() -> T {
        let vec = self.values
        return .init(vec.0, vec.1, vec.2)
    }
}

/// Represent a 3x3 matrix.
struct Matrix3x3 {

    typealias Row = (Double, Double, Double)
    let values: (Row, Row, Row)

    init (_ r1: Row, _ r2: Row, _ r3: Row) {
        self.values = (r1, r2, r3)
    }

    init(_ a11: Double, _ a12: Double, _ a13: Double, _ a21: Double, _ a22: Double, _ a23: Double, _ a31: Double, _ a32: Double, _ a33: Double) {
        self.values = ((a11, a12, a13), (a21, a22, a23), (a31, a32, a33))
    }
}

/// Represent a relative 2D polar coordinate.
struct PolarCoordinate {
    /// Relative distance `(0...1)` from the origin.
    let r: Double

    /// θ (theta) - angle in radians.
    let t: Double

    /// φ (phi) -  returns the angle in degrees.
    var phi: Double {
        t * 180.0 / .pi
    }

    /// Create a polar coordinate from a set of relative distance and angle.
    init(_ r: Double, _ t: Double) {
        self.r = r
        self.t = t
    }

    /// Create a polar coordinate from a specified Cartesian coordinate.
    init(point: CGPoint, bounds: CGSize) {
        // Make the coordinates relative to the center of the bounds
        let dx = point.x - bounds.width / 2.0
        let dy = point.y - bounds.height / 2.0

        // Calculate relative distance and angle
        let radius = min(bounds.width, bounds.height) / 2.0
        let r = sqrt(dx * dx + dy * dy) / radius
        let t = atan2(dy, dx)
        self.init(r, t)
    }

    /// Convert the polar coordinate to a Cartesian coordinate within a specified bounds.
    func toCartesian(bounds: CGSize) -> CGPoint {
        // Calculate coordinates in a perfect square
        let radius = min(bounds.width, bounds.height) / 2.0
        let x = (1 + r * cos(t)) * radius
        let y = (1 + r * sin(t)) * radius

        // Short-circuit if we have a square bounds
        if bounds.width == bounds.height { return CGPoint(x: x, y: y) }

        // Add necessary padding otherwise
        let padding = max(bounds.width, bounds.height) / 2.0
        return if bounds.width >= bounds.height {
            CGPoint(x: x + padding, y: y)
        } else {
            CGPoint(x: x, y: y + padding)
        }
    }

}
