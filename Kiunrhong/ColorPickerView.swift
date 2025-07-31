//
//  ColorPickerView.swift
//  Kiunrhong
//
//

import AppKit
import MetalKit

class ColorPickerView : NSView, ColorSpectrumViewDelegate {

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
        spectrumView.target = self
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

    func colorSpectrumMouseEvent(_: ColorSpectrumView, with event: NSEvent) {
        guard let coordinate = spectrumView.pointToPolarCoordinate(from: event.locationInWindow) else {
            NSCursor.arrow.set()    // We’re outside of the wheel. Clear everything.
            infoTextField.stringValue = ""
            return
        }

        // Set the current cursor as crosshair
        NSCursor.crosshair.set()

        // Calculate the color and update the info text.
        let color = spectrumView.colorAtCoordinate(coordinate)
        infoTextField.stringValue = String(format: "L: %.4f\nC: %.4f\nH: %.2f", color.l, color.c, color.h)

        switch event.type {
        case .leftMouseDown, .leftMouseDragged, .leftMouseUp:
            // Select the color at the coordinate.
            let location = self.convert(event.locationInWindow, from: nil)
            setCurrentSelection(color, at: location)
        default: break
        }
    }

    func setCurrentSelection(_ color: OKLCHColor?, at location: CGPoint? = nil) {
        self.currentSelection = color
        if (color != nil) {
            updateComponentFields()
            updatePinLocation(location: location)
        } else {
            clearPinLocation()
        }
    }

    private func updatePinLocation(location: CGPoint? = nil) {
        // Calculate the pin position if not provided
        var position: CGPoint
        if location != nil {
            position = location!
        } else {
            let polarCoord = spectrumView.colorToCoordinate(self.currentSelection!)
            let viewCoord = spectrumView.pointFromPolarCoordinate(polarCoord!)
            position = self.convert(viewCoord, from: spectrumView)
        }

        let size = selectionPin.image!.size
        selectionPin.setFrameOrigin(.init(x: position.x - size.width / 2, y: position.y - size.height / 2))
        selectionPin.isHidden = false
    }

    func clearPinLocation() {
        selectionPin.isHidden = true
    }

    private func updateComponentFields() {
        let color = self.currentSelection!
        for case let (value, index) in [(color.l, 0), (color.c, 1), (color.h, 2)] {
            componentFields[index].setDoubleValue(value)
        }
    }
}

#if DEBUG
import SwiftUI
struct ColorPickerView_Preview : View, NSViewRepresentable {
    typealias NSViewType = ColorPickerView

    func makeNSView(context: Context) -> NSViewType {
        return NSViewType()
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
    }
}

#Preview {
    ZStack {
        ColorPickerView_Preview()
    }.frame(width: 480, height: 360)
}
#endif
