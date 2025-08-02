//
//  ColorComponent.swift
//  Kiunrhong
//
//

/// Represents the metadata of a color component.
struct ColorComponent {

    /// The name of the color component.
    let name: Name

    /// The minimum value of the color component.
    let minValue: Double

    /// The maximum value of the color component.
    let maxValue: Double

    /// The suggested increment value of the color component.
    let increment: Double

    /// The number of digits to round the color component value to.
    let fractionDigits: Int

    /// The practical range of the color component for the user. Some controls may choose to clip their values to this range.
    // Default is the full range of the color component.
    let practicalRange: ClosedRange<Double>

    //
    // Initializer
    //

    /// Creates a new color component with the given properties.
    init(name: Name = .none, minValue: Double = 0.0, maxValue: Double = 1.0, increment: Double = 0.01, fractionDigits: Int = 4, practicalRange: ClosedRange<Double>? = nil) {
        self.name = name
        self.minValue = minValue
        self.maxValue = maxValue
        self.increment = increment
        self.fractionDigits = fractionDigits
        self.practicalRange = practicalRange ?? minValue...maxValue
    }

    //
    // Nested types
    //

    /// Represents the name of a color component.
    enum Name {
        case none
        case lightness
        case chroma
        case hue
        case red
        case green
        case blue
    }

    //
    // Static members
    //

    /// The lightness color component of the OKLCH color space.
    static let lightness = ColorComponent(name: .lightness, minValue: 0.0, maxValue: 1.0)

    /// The chroma color component of the OKLCH color space.
    static let chroma = ColorComponent(name: .chroma, minValue: 0.0, maxValue: 0.5, increment: 0.0001, practicalRange: 0.0...0.4)

    /// The hue color component of the OKLCH color space.
    static let hue = ColorComponent(name: .hue, minValue: 0.0, maxValue: 360.0, increment: 1.0, fractionDigits: 2)

    /// The red color component of the RGB color space.
    static let red = ColorComponent(name: .red, minValue: 0.0, maxValue: 1.0)

    /// The green color component of the RGB color space.
    static let green = ColorComponent(name: .green, minValue: 0.0, maxValue: 1.0)

    /// The blue color component of the RGB color space.
    static let blue = ColorComponent(name: .blue, minValue: 0.0, maxValue: 1.0)
}
