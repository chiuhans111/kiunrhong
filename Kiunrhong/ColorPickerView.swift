//
//  ColorPickerView.swift
//  Kiunrhong
//
//

import AppKit
import MetalKit

class ColorPickerView : NSView {

    let colorSpace = CGColorSpace(name: CGColorSpace.displayP3)!

    let lightness = 0.7, chroma = 0.168 // at the P3 edge when h=268
    // at c = 0.16, two suitable P3 edges (l, h) have been determined to be usable for the color ring: (0.6784, 88.41) and (0.715, 268)
    // for Rec2020, consider using (0.6638, 88.41)

    var metalView: MTKView!
    var device: MTLDevice!
    var renderer: Renderer!

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.translatesAutoresizingMaskIntoConstraints = false

        self.metalView = MTKView()
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.widthAnchor.constraint(equalTo: metalView.heightAnchor).isActive = true
        self.addSubview(metalView)
        metalView.widthAnchor.constraint(lessThanOrEqualTo: self.layoutMarginsGuide.widthAnchor).isActive = true
        metalView.heightAnchor.constraint(lessThanOrEqualTo: self.layoutMarginsGuide.heightAnchor, multiplier: 1).isActive = true
        metalView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        metalView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        metalView.colorPixelFormat = .rgba16Float
        metalView.colorspace = NSColorSpace.displayP3.cgColorSpace
        metalView.clearColor = MTLClearColor(nsColor: NSColor.windowBackgroundColor)
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = true

        self.device = MTLCreateSystemDefaultDevice()
        metalView.device = self.device

        self.renderer = Renderer(metalView: metalView)
        metalView.delegate = renderer
        metalView.needsDisplay = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class Renderer : NSObject, MTKViewDelegate {

        weak var metalView: MTKView?
        var commandQueue: MTLCommandQueue!
        var pipelineState: MTLRenderPipelineState!
        var vertexBuffer: MTLBuffer!
        var fragmentBuffer: MTLBuffer!

        init(metalView: MTKView) {
            self.metalView = metalView

            let device = metalView.device!
            self.commandQueue = device.makeCommandQueue()

            // Load library
            let library = device.makeDefaultLibrary()!
            let vertexFunction = library.makeFunction(name: "vertexShader")!
            let fragmentFunction = library.makeFunction(name: "fragmentShader")!

            // Set up pipeline
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = vertexFunction
            descriptor.fragmentFunction = fragmentFunction
            descriptor.colorAttachments[0].pixelFormat = .rgba16Float
            descriptor.isRasterizationEnabled = true
            self.pipelineState = try! device.makeRenderPipelineState(descriptor: descriptor)

            // Set up buffer
            let vertices : [simd_float4] = [
                [-1.0, 1.0, 0.0, 1.0],
                [1.0, -1.0, 0.0, 1.0],
                [-1.0, -1.0, 0.0, 1.0],
                [-1.0, 1.0, 0.0, 1.0],
                [1.0, 1.0, 0.0, 1.0],
                [1.0, -1.0, 0.0, 1.0],
            ]
            self.vertexBuffer = device.makeBuffer(bytes: vertices, length: MemoryLayout<simd_float4>.stride * vertices.count)
            self.fragmentBuffer = device.makeBuffer(length: MemoryLayout<Context>.stride, options: .storageModeShared)
        }

        /// Calls when resized.
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        }

        func draw(in view: MTKView) {
            guard let descriptor = view.currentRenderPassDescriptor else { return }

            let buffer = commandQueue.makeCommandBuffer()!
            let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor)!
            encoder.setRenderPipelineState(self.pipelineState)
            encoder.setVertexBuffer(self.vertexBuffer, offset: 0, index: 0)

            var context = Context(size: view.drawableSize)
            memcpy(self.fragmentBuffer.contents(), &context, MemoryLayout<Context>.stride)
            encoder.setFragmentBuffer(fragmentBuffer, offset: 0, index: 0)

            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: 1)
            encoder.endEncoding()

            let drawable = view.currentDrawable!
            buffer.present(drawable)
            buffer.commit()
        }

        struct Context {
            var origin: simd_packed_float2
            var size: simd_packed_float2

            init(size: CGSize) {
                self.origin = simd_packed_float2(Float(size.width / 2.0), Float(size.height / 2.0))
                self.size = simd_packed_float2(Float(size.width), Float(size.height))
            }
        }
    }
}

extension MTLClearColor {
    init(nsColor: NSColor) {
        let color = nsColor.usingColorSpace(NSColorSpace.displayP3)!
        self.init(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: color.alphaComponent)
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
    }.frame(width: 480, height: 480)
}
#endif
