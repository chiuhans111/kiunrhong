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
        self.addSubview(infoTextField)

        infoTextField.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        infoTextField.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    required init(coder: NSCoder) {
        fatalError( "init(coder:) has not been implemented" )
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
        super.mouseMoved(with: event)

        // Convert the coordinates to spectrum view’s coordinates
        let localPoint = spectrumView.convert(event.locationInWindow, from: nil)
        let relativePosition = (dx: localPoint.x - spectrumView.bounds.width / 2.0, dy: localPoint.y - spectrumView.bounds.height / 2.0)
        let wheelRadius = min(spectrumView.bounds.width, spectrumView.bounds.height) / 2.0

        // Calculate the distance and angle in the color wheel
        let distance = sqrt(relativePosition.dx * relativePosition.dx + relativePosition.dy * relativePosition.dy) / wheelRadius
        let angleInDegrees = atan2(relativePosition.dy, relativePosition.dx) * 180.0 / .pi

        guard distance <= 1.0 else {
            infoTextField.stringValue = ""; return // Out-of-bound
        }

        // Estimate plotted color
        let l = spectrumView.lightness + (1.0 - spectrumView.lightness) * (1.0 - distance)
        let c = spectrumView.chroma
        let h = (angleInDegrees + 360.0).truncatingRemainder(dividingBy: 360.0)

        infoTextField.stringValue = String(format: "L: \t%.4f\nC: \t%.4f\nH: \t%.4f", l, c, h)
    }


    override func mouseExited(with event: NSEvent) {
        infoTextField.stringValue = ""
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
