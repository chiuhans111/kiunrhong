//
//  ColorPickerViewController.swift
//  Kiunrhong
//
//

import AppKit

class ColorPickerViewController: ViewController<ColorPickerView>, ColorSpectrumViewDelegate {

    var currentSelection: OKLCHColor?

    override func viewDidLoad() {
        super.viewDidLoad()
        this.spectrumView.parentDelegate = self
    }

    func colorSpectrum(_: ColorSpectrumView, mouseEvent event: NSEvent) {
        guard let coordinate = this.spectrumView.pointToPolarCoordinate(from: event.locationInWindow) else {
            NSCursor.arrow.set()    // We’re outside of the wheel. Clear everything.
            this.infoTextField.stringValue = ""
            return
        }

        // Set the current cursor as crosshair
        NSCursor.crosshair.set()

        // Calculate the color and update the info text.
        let color = this.spectrumView.colorAtCoordinate(coordinate)
        this.infoTextField.stringValue = String(format: "L: %.4f\nC: %.4f\nH: %.2f", color.l, color.c, color.h)

        switch event.type {
        case .leftMouseDown, .leftMouseDragged, .leftMouseUp:
            // Select the color at the coordinate.
            let location = this.convert(event.locationInWindow, from: nil)
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
            let polarCoord = this.spectrumView.colorToCoordinate(self.currentSelection!)
            let viewCoord = this.spectrumView.pointFromPolarCoordinate(polarCoord!)
            position = this.convert(viewCoord, from: this.spectrumView)
        }

        let size = this.selectionPin.image!.size
        this.selectionPin.setFrameOrigin(.init(x: position.x - size.width / 2, y: position.y - size.height / 2))
        this.selectionPin.isHidden = false
    }

    func clearPinLocation() {
        this.selectionPin.isHidden = true
    }

    private func updateComponentFields() {
        let color = self.currentSelection!
        for case let (value, index) in [(color.l, 0), (color.c, 1), (color.h, 2)] {
            this.componentFields[index].setDoubleValue(value)
        }
    }
}

#if DEBUG
import SwiftUI
struct ColorPickerViewController_Preview : View, NSViewControllerRepresentable {

    typealias NSViewControllerType = ColorPickerViewController

    func makeNSViewController(context: Context) -> NSViewControllerType {
        return NSViewControllerType()
    }

    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
    }
}

#Preview {
    ZStack {
        ColorPickerViewController_Preview()
    }.frame(width: 480, height: 360)
}
#endif
