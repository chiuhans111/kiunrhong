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

    //
    // Properties
    //

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

            // Update the related controls
            field.doubleValue = _value
            stepper.doubleValue = _value
        }
    }

    /// The minimum value of the numeric field.
    var minValue: Double {
        get { stepper.minValue }
        set { stepper.minValue = newValue }
    }

    /// The maximum value of the numeric field.
    var maxValue: Double {
        get { stepper.maxValue }
        set { stepper.maxValue = newValue }
    }

    /// The increment value of the numeric field.
    var increment: Double {
        get { stepper.increment }
        set { stepper.increment = newValue }
    }

    /// Indicates whether the numeric field wraps its value after reaching the boundary.
    var valueWraps: Bool {
        get { stepper.valueWraps }
        set { stepper.valueWraps = newValue }
    }

    /// The maximum number of fraction digits to display.
    var maximumFractionDigits: Int = 2 {
        didSet {
            // Update field formatter to reflect the digit preference
            let formatter = NumberFormatter()
            formatter.allowsFloats = true
            formatter.maximumFractionDigits = self.maximumFractionDigits
            formatter.roundingIncrement = NSNumber(floatLiteral: pow(10, Double(-self.maximumFractionDigits)))
            field.formatter = formatter
        }
    }

    /// The delegate of the numeric field to handle its events.
    var delegate: NumericFieldDelegate?

    /// The tag of the numeric field to identify itself.
    override var tag: Int {
        get { _tag }
        set { _tag = newValue }
    }

    //
    // Private properties
    //

    /// The internal tag value of the numeric field. Use the `tag` property instead.
    private var _tag: Int = -1

    /// The internal value of the numeric field. Use `doubleValue` property instead as setting this value will not trigger `didSet` side effects.
    private var _value: Double = 0.0

    //
    // Initializers
    //

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

    /// Update the control value and notify its delegate of user-triggered actions.
    func setValue(_ value: Double) {
        self.doubleValue = value
        self.delegate?.numericFieldValueDidChange(self)
    }

    ///
    func parseValue(_ input: String) -> Double? {
        // Aquire the same formatter we use for validation
        (field.formatter as! NumberFormatter).number(from: input)?.doubleValue
    }

    func practiallyEqual(with value: Double) -> Bool {
        abs(self.doubleValue - value) <= pow(10, Double(-self.maximumFractionDigits))
    }

    //
    // Actions and delegate functions
    //

    @objc
    func onStepperChanged(_: NSStepper) {
        self.setValue(stepper.doubleValue)
    }

    func controlTextDidChange(_ notification: Notification) {
        // We’re in the middle of editing session; do not attempt to access `stringValue`
        let fieldEditor = notification.userInfo?["NSFieldEditor"] as? NSTextView
        let input = fieldEditor!.string

        // If the input parses as a float, falls within the range, and significantly different,
        // we abort the editing process early and update the color value real-time.
        // Otherwise, wait for the user to commit the edit.
        guard let value = parseValue(input) else { return }
        if (minValue...maxValue).contains(value) && !self.practiallyEqual(with: value) {
            self.setValue(value)
        }
    }

    func controlTextDidEndEditing(_: Notification) {
        // Our formatter does not check value range. Clamp the value if necessary.
        let value = field.doubleValue
        self.setValue(
            value < self.minValue ? self.minValue :
            value > self.maxValue ? self.maxValue : value)
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(moveUp):
            stepper.moveUp(self)
        case #selector(moveDown):
            stepper.moveDown(self)
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
