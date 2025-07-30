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

        self.infoTextField = NSTextField(labelWithString: "-")
        infoTextField.translatesAutoresizingMaskIntoConstraints = false
        infoTextField.font = createTabularLabelFont()

        self.addSubview(infoTextField)

        infoTextField.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        infoTextField.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    required init(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
    }

    private func createTabularLabelFont() -> NSFont {
        let systemFont = NSFont.labelFont(ofSize: NSFont.labelFontSize)
        let descriptor = NSFontDescriptor(fontAttributes: [
            .family: systemFont.familyName!,
            .featureSettings: [kNumberSpacingType: kMonospacedNumbersSelector]
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
        // Don’t update the values if we are in Lock mode
        guard !isLocked else { return }
        updateSelection(with: event)
    }

    private func updateSelection(with event: NSEvent) {
        // Convert the coordinates to spectrum view’s coordinates
        let localPoint = spectrumView.convert(event.locationInWindow, from: nil)
        let relativePosition = (dx: localPoint.x - spectrumView.bounds.width / 2.0, dy: localPoint.y - spectrumView.bounds.height / 2.0)
        let wheelRadius = min(spectrumView.bounds.width, spectrumView.bounds.height) / 2.0

        // Calculate the distance and angle in the color wheel
        let distance = sqrt(relativePosition.dx * relativePosition.dx + relativePosition.dy * relativePosition.dy) / wheelRadius
        let angleInDegrees = atan2(relativePosition.dy, relativePosition.dx) * 180.0 / .pi

        guard distance <= 1.0 else {
            clearSelection(); return // Out-of-bound
        }

        // Set the mouse cursor if haven’t done so
        if NSCursor.current != NSCursor.crosshair {
            NSCursor.crosshair.set()
        }

        // Estimate plotted color
        let l = spectrumView.lightness + (1.0 - spectrumView.lightness) * (1.0 - distance)
        let c = spectrumView.chroma
        let h = Double(angleInDegrees + 360.0).truncatingRemainder(dividingBy: 360.0)

        // Update the view with selection
        setSelection(l: l, c: c, h: h)
    }

    private func setSelection(l: Double, c: Double, h: Double) {
        currentSelection = (l, c, h)
        infoTextField.stringValue = String(format: "L: %.4f\nC: %.4f\nH: %.2f", l, c, h)
    }

    override func mouseExited(with event: NSEvent) {
        if !isLocked { clearSelection() }
        NSCursor.pop()
    }

    private func clearSelection() {
        currentSelection = nil
        infoTextField.stringValue = ""
    }

    override func mouseUp(with event: NSEvent) {
        // Only perform locking/unlocking when there is current color
        guard currentSelection != nil else { return }

        if isLocked { updateSelection(with: event) }
        isLocked = !isLocked
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
