//
//  Matrix3x3.swift
//  Kiunrhong
//
//

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
