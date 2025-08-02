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

    /// The suggested increment value of the color component. Formatters may use this value to round the color component value.
    let increment: Double

    /// The unit of the color component. Default is `none`.
    let unit: Unit

    /// The practical range of the color component for the user. Some controls may choose to clip their values to this range.
    // Default is the full range of the color component.
    let practicalRange: ClosedRange<Double>

    //
    // Initializer
    //

    /// Creates a new color component with the given properties.
    init(name: Name = .none, minValue: Double = 0.0, maxValue: Double = 1.0, increment: Double = 0.0001, unit: Unit = .none, practicalRange: ClosedRange<Double>? = nil) {
        self.name = name
        self.minValue = minValue
        self.maxValue = maxValue
        self.increment = increment
        self.unit = unit
        self.practicalRange = practicalRange ?? minValue...maxValue
    }

    //
    // Nested types
    //

    /// Represents the unit of a color component.
    enum Unit {
        case none
        case degree
    }

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

    static let lightness = ColorComponent(name: .lightness, minValue: 0.0, maxValue: 1.0, increment: 0.0001)

    static let chroma = ColorComponent(name: .chroma, minValue: 0.0, maxValue: 0.5, increment: 0.0001, practicalRange: 0.0...0.4)

    static let hue = ColorComponent(name: .hue, minValue: 0.0, maxValue: 360.0, increment: 0.01, unit: .degree)

    static let red = ColorComponent(name: .red, minValue: 0.0, maxValue: 1.0, increment: 0.0001)

    static let green = ColorComponent(name: .green, minValue: 0.0, maxValue: 1.0, increment: 0.0001)

    static let blue = ColorComponent(name: .blue, minValue: 0.0, maxValue: 1.0, increment: 0.0001)
}
