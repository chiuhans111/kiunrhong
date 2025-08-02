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

    func colorSpectrum(_: ColorSpectrumView, mouseDidMove event: ColorSpectrumViewEvent) {
        let color = event.color!
        this.infoTextField.stringValue = String(format: "L: %.4f\nC: %.4f\nH: %.2f", color.l, color.c, color.h)
    }

    func colorSpectrum(_: ColorSpectrumView, mouseDidLeave event: ColorSpectrumViewEvent) {
        this.infoTextField.stringValue = ""
    }

    func colorSpectrum(_: ColorSpectrumView, didSelectColor color: OKLCHColor) {
        setCurrentSelection(color)
    }

    func setCurrentSelection(_ color: OKLCHColor?) {
        self.currentSelection = color
        if (color != nil) {
            updateComponentFields()
            updatePinLocation()
        } else {
            clearPinLocation()
        }
    }

    private func updatePinLocation() {
        // Calculate the pin position
        let color = self.currentSelection!
        let polarCoord = this.spectrumView.colorToCoordinate(color)
        let viewCoord = this.spectrumView.pointFromPolarCoordinate(polarCoord!)

        let position = this.convert(viewCoord, from: this.spectrumView)
        let size = this.selectionPin.image!.size
        this.selectionPin.setFrameOrigin(.init(x: position.x - size.width / 2, y: position.y - size.height / 2))
        this.selectionPin.isHidden = false
    }

    private func clearPinLocation() {
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
