//
//  ColorPickerView.swift
//  Kiunrhong
//
//

import AppKit
import MetalKit

class ColorPickerView : NSView {

    var spectrumView: ColorSpectrumView!
    var trackingArea: NSTrackingArea?
    var infoTextField: NSTextField!
    var selectionPin: NSImageView!

    var isLocked = false
    var currentSelection: (Double, Double, Double)?

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
        infoTextField.font = createTabularLabelFont()
        self.addSubview(infoTextField)

        infoTextField.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        infoTextField.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true

        let crosshairImage = NSImage(systemSymbolName: "plus", accessibilityDescription: "Crosshair")!
        self.selectionPin = NSImageView(image: crosshairImage)
        selectionPin.symbolConfiguration = .init(pointSize: 20, weight: .light).applying(.init(paletteColors: [.black]))
        selectionPin.isHidden = true
        self.addSubview(selectionPin)
    }

    required init(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }

    private func createTabularLabelFont() -> NSFont {
        let systemFont = NSFont.labelFont(ofSize: NSFont.labelFontSize)
        let descriptor = NSFontDescriptor(fontAttributes: [
            .family: systemFont.familyName!,
            .featureSettings: [
                [
                    NSFontDescriptor.FeatureKey.typeIdentifier: kNumberSpacingType,
                    NSFontDescriptor.FeatureKey.selectorIdentifier: kMonospacedNumbersSelector,
                ],
            ]
        ])
        return NSFont(descriptor: descriptor, size: systemFont.pointSize)!
    }

    override func updateTrackingAreas() {
        // Remove the existing one if exists
        if trackingArea != nil {
            self.removeTrackingArea(trackingArea!)
        }

        // Set the new one in accordance to updated bounds
        let bounds = self.convert(spectrumView.bounds, from: spectrumView)
        self.trackingArea = NSTrackingArea(rect: bounds,
                                           options: [.mouseEnteredAndExited, .mouseMoved, .activeInActiveApp],
                                           owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea!)
    }

    override func mouseMoved(with event: NSEvent) {
        // Calculate the polar coordinate within the color wheel
        if let coordinate = spectrumView.calculatePolarCoordinate(from: event.locationInWindow) {
            NSCursor.crosshair.set()
            if !isLocked { updateSelection(distance: coordinate.r, angleInDegrees: coordinate.t) }
        } else {
            // We’re outside of the wheel. Clear everything unless the cursor is locked.
            NSCursor.arrow.set()
            if !isLocked { clearSelection() }
        }
    }

    private func updateSelection(distance: Double, angleInDegrees: Double) {
        // Estimate plotted color
        let l = spectrumView.lightness + (1.0 - spectrumView.lightness) * (1.0 - distance)
        let c = spectrumView.chroma
        let h = Double(angleInDegrees + 360.0).truncatingRemainder(dividingBy: 360.0)

        // Update the view with selection
        currentSelection = (l, c, h)
        infoTextField.stringValue = String(format: "L: %.4f\nC: %.4f\nH: %.2f", l, c, h)
    }

    override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set()
    }

    private func clearSelection() {
        currentSelection = nil
        infoTextField.stringValue = ""
    }

    override func mouseUp(with event: NSEvent) {
        if let coordinate = spectrumView.calculatePolarCoordinate(from: event.locationInWindow) {
            // We’re within the color wheel. Lock to the new coordinate.
            isLocked = true
            updateSelection(distance: coordinate.r, angleInDegrees: coordinate.t)

            // Calculate the pin position and show the crosshair
            let position = self.convert(event.locationInWindow, from: nil)
            let size = selectionPin.image!.size
            selectionPin.setFrameOrigin(.init(x: position.x - size.width / 2, y: position.y - size.height / 2))
            selectionPin.isHidden = false
        } else {
            // We’re outside of the view. Unlock (deselect) if needed.
            if isLocked {
                isLocked = false
                clearSelection()
                selectionPin.isHidden = true
            }
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
