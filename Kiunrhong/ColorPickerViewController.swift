//
//  ColorPickerViewController.swift
//  Kiunrhong
//
//

import AppKit

class ColorPickerViewController: ViewController<ColorPickerView>, ColorSpectrumViewDelegate, NumericFieldDelegate {

    var currentSelection: OKLCHColor?

    override func viewDidLoad() {
        super.viewDidLoad()
        this.spectrumView.parentDelegate = self
        this.componentDelegate = self
        this.addColorComponent(.lightness, withLabel: "L")
        this.addColorComponent(.chroma, withLabel: "C")
        this.addColorComponent(.hue, withLabel: "H")
        this.addColorComponent(.red, withLabel: "R")
        this.addColorComponent(.green, withLabel: "G")
        this.addColorComponent(.blue, withLabel: "B")
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
        updateComponentFields()
        updatePinLocation()
    }

    private func updatePinLocation() {
        // Calculate the pin position
        guard let color = self.currentSelection,
              let coord = this.spectrumView.colorToCoordinate(color) else {
            // Either we don’t have a selection or the color is out of bounds. Hide the selection pin.
            this.selectionPin.isHidden = true
            return
        }

        let viewCoord = this.spectrumView.pointFromPolarCoordinate(coord)
        let position = this.convert(viewCoord, from: this.spectrumView)
        let size = this.selectionPin.image!.size
        this.selectionPin.setFrameOrigin(.init(x: position.x - size.width / 2, y: position.y - size.height / 2))
        this.selectionPin.isHidden = false
    }

    func numericFieldValueDidChange(_ numericField: NumericField) {
        let componentName = ColorComponent.Name(rawValue: numericField.tag)!
        let color = if [.lightness, .chroma, .hue].contains(componentName) {
            OKLCHColor(
                this.components[.lightness]!.doubleValue,
                this.components[.chroma]!.doubleValue,
                this.components[.hue]!.doubleValue)
        } else {
            RGBColor(
                this.components[.red]!.doubleValue,
                this.components[.green]!.doubleValue,
                this.components[.blue]!.doubleValue).toXYZ().toOKLCH()
        }
        self.setCurrentSelection(color)
    }

    private func updateComponentFields() {
        let color = self.currentSelection!
        this.components[.lightness]!.doubleValue = color.l
        this.components[.chroma]!.doubleValue = color.c
        this.components[.hue]!.doubleValue = color.h

        // Convert the color to other color spaces.
        // Note that we don’t need to create an actual `CGColor` as plain vector shall suffice.
        let rgb = color.toXYZ().toDisplayP3()
        this.components[.red]!.doubleValue = rgb.r
        this.components[.green]!.doubleValue = rgb.g
        this.components[.blue]!.doubleValue = rgb.b
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
