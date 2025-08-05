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
            // Do not trigger any events if value is the same (perf optimizationl no need to worry float equity here)
            guard _value != newValue else { return }

            // clamp values
            _value = if newValue < minValue { minValue }
                else if newValue > maxValue { maxValue }
                else { newValue }

            // Update the related controls
            field.doubleValue = _value
            stepper.doubleValue = _value
        }
    }

    /// Indicates whether the numeric field wraps its value after reaching the boundary.
    var valueWraps: Bool {
        get { stepper.valueWraps }
        set { stepper.valueWraps = newValue }
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

    /// The internal tag value of the numeric field. Use the `tag` property instead.
    private var _tag: Int = -1

    /// The tag of the numeric field to identify itself.
    override var tag: Int {
        get { _tag }
        set { _tag = newValue }
    }

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
        field.font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize(for: field.controlSize), weight: .regular)
        field.delegate = self

        stepper.valueWraps = false  // Defaults to false
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

    /// Update the control value and notify its delegate of user-triggered actions.
    func setValue(_ value: Double) {
        self.doubleValue = value
        self.delegate?.numericFieldValueDidChange(self)
    }

    //
    // Actions and delegate functions
    //

    @objc
    func onStepperChanged(_: NSStepper) {
        self.setValue(stepper.doubleValue)
    }

    func controlTextDidChange(_ notification: Notification) {
        let fieldEditor = notification.userInfo?["NSFieldEditor"] as? NSTextView
        let string = fieldEditor!.string

        // We need to manually convert the number ourselves to determine its validity
        let formatter = field.formatter as! NumberFormatter
        guard let number = formatter.number(from: string) else { return }

        // Updates the value only if it’s valid and it exactly matches itself
        let value = number.doubleValue
        if (minValue...maxValue).contains(value) && formatter.string(from: number) == string {
            self.setValue(value)
        }
    }

    func controlTextDidEndEditing(_: Notification) {
        self.setValue(field.doubleValue)
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(moveUp):
            self.stepper.moveUp(self)
        case #selector(moveDown):
            self.stepper.moveDown(self)
        default:
            return false
        }
        return true
    }
}

/// Delegate protocol for `NumericField`.
protocol NumericFieldDelegate {

    /// Called when the value of the numeric field changes.
    func numericFieldValueDidChange(_ numericField: NumericField)

}
