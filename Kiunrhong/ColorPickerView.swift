//
//  ColorPickerView.swift
//  Kiunrhong
//
//

import AppKit
import MetalKit

class ColorPickerView : NSView {

    var spectrumView: ColorSpectrumView!
    var infoTextField: NSTextField!
    var selectionPin: NSImageView!
    var componentStack: NSStackView!
    var toolbarStack: NSStackView!
    var colorWell: NSColorWell!

    var componentDelegate: NumericFieldDelegate?
    var components: [ColorComponent.Name: NumericField] = [:]
    var toolButtons: [NSButton] = []

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.translatesAutoresizingMaskIntoConstraints = false

        self.widthAnchor.constraint(greaterThanOrEqualToConstant: 240).isActive = true
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: 240).isActive = true
        self.widthAnchor.constraint(greaterThanOrEqualTo: self.heightAnchor, multiplier: 1.33).isActive = true

        self.spectrumView = ColorSpectrumView(frame: frameRect)
        spectrumView.translatesAutoresizingMaskIntoConstraints = false
        spectrumView.widthAnchor.constraint(equalTo: spectrumView.heightAnchor).isActive = true
        self.addSubview(spectrumView)

        spectrumView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.layoutMarginsGuide.leadingAnchor, multiplier: 0.5).isActive = true
        spectrumView.trailingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: self.layoutMarginsGuide.trailingAnchor, multiplier: -0.5).isActive = true
        spectrumView.topAnchor.constraint(equalToSystemSpacingBelow: self.layoutMarginsGuide.topAnchor, multiplier: 0.5).isActive = true
        spectrumView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.layoutMarginsGuide.bottomAnchor, multiplier: -0.5).isActive = true

        self.infoTextField = NSTextField(labelWithString: "")
        infoTextField.translatesAutoresizingMaskIntoConstraints = false
        infoTextField.font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.labelFontSize, weight: .regular)
        self.addSubview(infoTextField)

        infoTextField.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        infoTextField.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true

        self.selectionPin = NSImageView(image: NSImage(systemSymbolName: "plus", accessibilityDescription: "Crosshair")!)
        selectionPin.symbolConfiguration = .init(pointSize: 20, weight: .light).applying(.init(paletteColors: [.black]))
        selectionPin.isHidden = true
        self.addSubview(selectionPin)
        self.componentStack = NSStackView()
        componentStack.orientation = .vertical
        componentStack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(componentStack)

        componentStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        componentStack.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        componentStack.widthAnchor.constraint(greaterThanOrEqualToConstant: 90).isActive = true

        self.toolbarStack = NSStackView()
        toolbarStack.orientation = .horizontal
        toolbarStack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(toolbarStack)

        toolbarStack.topAnchor.constraint(equalToSystemSpacingBelow: componentStack.bottomAnchor, multiplier: 1).isActive = true
        toolbarStack.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true

        self.colorWell = NSColorWell()
        colorWell.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(colorWell)

        colorWell.topAnchor.constraint(equalToSystemSpacingBelow: toolbarStack.bottomAnchor, multiplier: 1).isActive = true
        colorWell.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        colorWell.widthAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        colorWell.heightAnchor.constraint(greaterThanOrEqualToConstant: 36).isActive = true

    }

    required init(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }

    //
    // View functions
    //

    func addColorComponent(_ component: ColorComponent, withLabel label: String) {
        let field = NumericField(frame: .zero)
        field.tag = component.name.rawValue
        field.name = label
        field.valueWraps = component.traits.contains(.valueWraps)
        field.delegate = self.componentDelegate

        field.minValue = component.minValue
        field.maxValue = component.maxValue
        field.increment = component.increment
        field.maximumFractionDigits = component.fractionDigits

        components[component.name] = field
        componentStack.addArrangedSubview(field)
    }

    func addToolButton(withSystemSymbolName symbolName: String, title: String, target: AnyObject?, action: Selector?) {
        let button = NSButton(image: NSImage(systemSymbolName: symbolName, accessibilityDescription: title)!, target: target, action: action)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bezelStyle = .circular
        button.controlSize = .regular
        button.toolTip = title
        button.showsBorderOnlyWhileMouseInside = true
        toolButtons.append(button)
        toolbarStack.addArrangedSubview(button)
    }

    //
    // Overrides
    //

    override var mouseDownCanMoveWindow: Bool { true }
}
