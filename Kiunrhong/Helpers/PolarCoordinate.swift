//
//  PolarCoordinate.swift
//  Kiunrhong
//
//

import CoreGraphics

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
