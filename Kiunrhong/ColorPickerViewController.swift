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

        // Set up color components
        this.addColorComponent(.lightness, withLabel: "L")
        this.addColorComponent(.chroma, withLabel: "C")
        this.addColorComponent(.hue, withLabel: "H")
        this.addColorComponent(.red, withLabel: "R")
        this.addColorComponent(.green, withLabel: "G")
        this.addColorComponent(.blue, withLabel: "B")

        // Hook up tool buttons
        this.addToolButton(withSystemSymbolName: "eyedropper", title: "Sample Color from Screen", target: self, action: #selector(sampleColorButtonClicked))
        this.addToolButton(withSystemSymbolName: "dice", title: "Randomize!", target: self, action: #selector(randomizeButtonClicked))
        this.addToolButton(withSystemSymbolName: "doc.on.doc", title: "Copy Color Value", target: self, action: #selector(copyButtonClicked))
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
                this.components[.blue]!.doubleValue).toOKLCH()
        }
        setCurrentSelection(color)
    }

    private func updateComponentFields() {
        let color = self.currentSelection!
        this.components[.lightness]!.doubleValue = color.l
        this.components[.chroma]!.doubleValue = color.c
        this.components[.hue]!.doubleValue = color.h

        // Convert the color to other color spaces.
        // Note that we don’t need to create an actual `CGColor` as plain vector shall suffice.
        let rgb = color.toDisplayP3()
        this.components[.red]!.doubleValue = rgb.r
        this.components[.green]!.doubleValue = rgb.g
        this.components[.blue]!.doubleValue = rgb.b
    }

    @objc func copyButtonClicked() {
        guard let color = self.currentSelection else { return }
        let nsColor = color.toDisplayP3().toNSColorInDisplayP3()
        let serializedString = String(format: "oklch(%.4f %.4f %.2f)", color.l, color.c, color.h) as NSString

        let clipboard = NSPasteboard.general
        clipboard.declareTypes([.color, .string], owner: nil)
        clipboard.writeObjects([nsColor, serializedString])
    }

    @objc func randomizeButtonClicked(_ sender: NSButton) {
        let color = OKLCHColor(
            Double.random(in: ColorComponent.lightness.practicalRange),
            Double.random(in: ColorComponent.chroma.practicalRange),
            Double.random(in: ColorComponent.hue.practicalRange))
        setCurrentSelection(color)

        // Have some fun on the buttons
        var dieRoll = Int.random(in: 1...6)
        if dieRoll == sender.tag { dieRoll += 1 }
        sender.tag = dieRoll
        sender.image = NSImage(systemSymbolName: dieRoll > 6 ? "dice" : "die.face.\(dieRoll)", accessibilityDescription: sender.accessibilityLabel())
    }

    @objc func sampleColorButtonClicked() {
        let sampler = NSColorSampler()
        sampler.show(selectionHandler: { color in
            guard let nsColor = color?.usingColorSpace(NSColorSpace.displayP3) else { return }
            let color = RGBColor(nsColor.redComponent, nsColor.greenComponent, nsColor.blueComponent).toOKLCH()
            self.setCurrentSelection(color)
        })
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
