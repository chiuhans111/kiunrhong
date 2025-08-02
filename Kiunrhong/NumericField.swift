//
//  ColorPickerComponent.swift
//  Kiunrhong
//
//

import AppKit

/// Represents a numeric field with a label and a stepper.
class NumericField: NSView, NSTextFieldDelegate {

    var label: NSTextField!
    var field: NSTextField!
    var stepper: NSStepper!

    /// Gets or sets the label text of the numeric field.
    var name: String = "" {
        didSet {
            label.stringValue = "\(name): "
        }
    }

    /// Gets or sets the value of the numeric field.
    var doubleValue: Double {
        get { _value }
        set {
            _value = newValue
            self.valueDidChange()
        }
    }

    /// The internal value of the numeric field. Setting this value will not trigger the `valueDidChange()` method.
    private var _value: Double = 0.0

    /// The minimum value of the numeric field.
    /// Call `numberRangeDidChange()` after updating all the related properties.
    var minValue: Double = 0.0

    /// The maximum value of the numeric field.
    /// Call `numberRangeDidChange()` after updating all the related properties.
    var maxValue: Double = 1.0

    /// The increment value of the numeric field.
    /// Call `numberRangeDidChange()` after updating all the related properties.
    var increment: Double = 0.01

    /// The maximum number of fraction digits to display.
    /// Call `numberRangeDidChange()` after updating all the related properties.
    var maximumFractionDigits: Int = 2

    /// The delegate of the numeric field to handle its events.
    var delegate: NumericFieldDelegate?

    /// Creates a new numeric field.
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.label = NSTextField(labelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)

        self.field = NSTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(field)

        self.stepper = NSStepper()
        stepper.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stepper)

        label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalToSystemSpacingAfter: field.leadingAnchor, multiplier: -0.25).isActive = true
        label.firstBaselineAnchor.constraint(equalTo: field.firstBaselineAnchor).isActive = true

        self.heightAnchor.constraint(greaterThanOrEqualTo: field.heightAnchor).isActive = true
        field.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        stepper.leadingAnchor.constraint(equalToSystemSpacingAfter: field.trailingAnchor, multiplier: 0.5).isActive = true
        stepper.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stepper.topAnchor.constraint(equalTo: field.topAnchor).isActive = true
        stepper.bottomAnchor.constraint(equalTo: field.bottomAnchor).isActive = true

        numberRangeDidChange() // Sets the initial number range and formatters

        field.alignment = .right
        field.delegate = self

        stepper.valueWraps = false
        stepper.target = self
        stepper.action = #selector(onStepperChanged(_:))
    }

    required init(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }

    //
    // Functions
    //

    /// Update the number range of the stepper and the formatter.
    func numberRangeDidChange() {
        stepper.minValue = self.minValue
        stepper.maxValue = self.maxValue
        stepper.increment = self.increment

        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.maximumFractionDigits = self.maximumFractionDigits
        formatter.minimum = NSNumber(floatLiteral: self.minValue)
        formatter.maximum = NSNumber(floatLiteral: self.maxValue)
        formatter.roundingIncrement = NSNumber(floatLiteral: pow(10, Double(-self.maximumFractionDigits)))
        field.formatter = formatter
    }

    /// Updates the value of the text field and its associated stepper.
    func valueDidChange() {
        field.doubleValue = _value
        stepper.doubleValue = _value
    }

    //
    // Actions and delegate functions
    //

    @objc
    func onStepperChanged(_: NSStepper) {
        self.doubleValue = stepper.doubleValue
        self.delegate?.numericFieldValueDidChange(self)
    }

    func controlTextDidChange(_ obj: Notification) {
        self.doubleValue = field.doubleValue
        self.delegate?.numericFieldValueDidChange(self)
    }
}

/// Delegate protocol for `NumericField`.
protocol NumericFieldDelegate {

    /// Called when the value of the numeric field changes.
    func numericFieldValueDidChange(_ numericField: NumericField)

}
