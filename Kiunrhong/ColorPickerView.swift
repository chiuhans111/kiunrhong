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
    var componentFields: [ColorPickerComponent]!

    var currentSelection: OKLCHColor?

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

        let componentsStack = NSStackView()
        componentsStack.orientation = .vertical
        componentsStack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(componentsStack)
        
        componentsStack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        componentsStack.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        componentsStack.widthAnchor.constraint(greaterThanOrEqualToConstant: 90).isActive = true

        self.componentFields = []
        for componentName in "LCH" {
            let component = ColorPickerComponent(frame: .zero)
            component.name = String(componentName)

            if componentName == "H" {
                component.setNumberRange(minValue: 0.0, maxValue: 360.0, increment: 0.01)
            } else {
                component.setNumberRange(minValue: 0.0, maxValue: 1.0, increment: 0.0001)
            }

            componentsStack.addArrangedSubview(component)
            componentFields.append(component)
        }
    }

    required init(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }
}
