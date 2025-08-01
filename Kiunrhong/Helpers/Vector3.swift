//
//  Vector3.swift
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
