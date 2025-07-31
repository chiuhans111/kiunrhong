//
//  ColorPickerComponent.swift
//  Kiunrhong
//
//

import AppKit

class ColorPickerComponent: NSView, NSTextFieldDelegate {

    var label: NSTextField!
    var field: NSTextField!
    var stepper: NSStepper!

    var name: String = "" { didSet { label.stringValue = "\(name): " } }
    var minValue: Double = 0.0
    var maxValue: Double = 1.0
    var increment: Double = 0.01
    var doubleValue: Double = 0.0

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

        numberRangeDidSet() // Sets the initial number range and formatters

        field.alignment = .right
        field.delegate = self
        stepper.target = self
        stepper.action = #selector(onStepperChanged(_:))
    }

    required init(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }

    //
    // Functions
    //

    func setNumberRange(minValue: Double, maxValue: Double, increment: Double) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.increment = increment
        numberRangeDidSet()
    }

    func setDoubleValue(_ value: Double) {
        self.doubleValue = value
        valueDidSet()
    }

    //
    // Events
    //

    func numberRangeDidSet() {
        stepper.minValue = self.minValue
        stepper.maxValue = self.maxValue
        stepper.increment = self.increment

        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.maximumFractionDigits = 4
        formatter.minimum = NSNumber(floatLiteral: self.minValue)
        formatter.maximum = NSNumber(floatLiteral: self.maxValue)
        formatter.roundingIncrement = NSNumber(floatLiteral: self.increment)
        field.formatter = formatter
    }

    func valueDidSet() {
        let value = self.doubleValue
        field.doubleValue = value
        stepper.doubleValue = value
    }

    //
    // Actions and delegate functions
    //

    @objc
    func onStepperChanged(_: NSStepper) {
        self.doubleValue = stepper.doubleValue
        valueDidSet()
    }

    func controlTextDidChange(_ obj: Notification) {
        self.doubleValue = field.doubleValue
        valueDidSet()
    }
}
