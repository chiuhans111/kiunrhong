//
//  GenericColor.swift
//  Kiunrhong
//
//

/// Represents a generic color of three components.
/// This struct is intended for use in intermediate calculations only.
struct GenericColor: Vector3 {

    let a, b, c: Double
    var values: (Double, Double, Double) { (a, b, c) }

    init(_ a: Double, _ b: Double, _ c: Double) {
        self.a = a
        self.b = b
        self.c = c
    }
}
