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

func * <T: Vector3>(_ lhs: T, _ rhs: Matrix3x3) -> T {
    let vec = lhs.values
    let m = rhs.values
    return .init(vec.0 * m.0.0 + vec.1 * m.0.1 + vec.2 * m.0.2,
                 vec.0 * m.1.0 + vec.1 * m.1.1 + vec.2 * m.1.2,
                 vec.0 * m.2.0 + vec.1 * m.2.1 + vec.2 * m.2.2)
}

func * <T: Vector3>(_ lhs: T, _ rhs: Double) -> T {
    let vec = lhs.values
    return .init(vec.0 * rhs, vec.1 * rhs, vec.2 * rhs)
}

infix operator ** : MultiplicationPrecedence

func ** <T: Vector3>(_ lhs: T, _ rhs: Double) -> T {
    let vec = lhs.values
    return .init(pow(vec.0, rhs), pow(vec.1, rhs), pow(vec.2, rhs))
}

extension Vector3 {
    func map<T: Vector3>(_ f: (Double) -> Double) -> T {
        let vec = self.values
        return .init(f(vec.0), f(vec.1), f(vec.2))
    }

    func cast<T: Vector3>() -> T {
        let vec = self.values
        return .init(vec.0, vec.1, vec.2)
    }
}

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

struct PolarCoordinate {
    /// Relative distance `(0...1)` from the origin.
    let r: Double

    /// Angle in degrees.
    let t: Double
}
