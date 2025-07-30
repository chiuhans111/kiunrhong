//
//  ColorPickerView.swift
//  Kiunrhong
//
//

import AppKit
import MetalKit

/// Renders the color spectrum.
class ColorSpectrumView : MTKView, MTKViewDelegate {

    private var commandQueue: MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    private var vertexBuffer: MTLBuffer!
    private var fragmentBuffer: MTLBuffer!

    var lightness = 0.6
    var chroma = 0.168

    init(frame frameRect: NSRect) {
        let device = MTLCreateSystemDefaultDevice()!
        super.init(frame: frameRect, device: device)

        self.colorPixelFormat = .rgba16Float
        self.colorspace = CGColorSpace(name: CGColorSpace.displayP3)
        self.layer!.isOpaque = false
        self.layer!.wantsExtendedDynamicRangeContent = true
        self.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)

        // Load our shaders
        let library = device.makeDefaultLibrary()!
        let vertexFunction = library.makeFunction(name: "vertexShader")!
        let fragmentFunction = library.makeFunction(name: "fragmentShader")!

        // Set up pipeline

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = .rgba16Float

        let pipelineState = try! device.makeRenderPipelineState(descriptor: descriptor)
        self.commandQueue = device.makeCommandQueue()!
        self.pipelineState = pipelineState

        // Create buffers
        self.vertexBuffer = makeVertexBuffer(device: device)!
        self.fragmentBuffer = makeFragmentBuffer(device: device)!

        // Configure render frequency and mark for display
        self.isPaused = true
        self.enableSetNeedsDisplay = true
        self.delegate = self
        self.needsDisplay = true
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //
    // Buffer functions
    //

    private func makeVertexBuffer(device: MTLDevice) -> MTLBuffer? {
        // Create a simple 2D surface
        let vertices: [simd_float4] = [
            [-1.0,  1.0, 0.0, 1.0],
            [ 1.0, -1.0, 0.0, 1.0],
            [-1.0, -1.0, 0.0, 1.0],
            [-1.0,  1.0, 0.0, 1.0],
            [ 1.0,  1.0, 0.0, 1.0],
            [ 1.0, -1.0, 0.0, 1.0],
        ]

        let size = MemoryLayout<simd_float4>.stride * vertices.count
        return device.makeBuffer(bytes: vertices, length: size)
    }

    struct FragmentContext {
        var drawableSize: simd_packed_float2

        init(size: CGSize) {
            self.drawableSize = simd_packed_float2(Float(size.width), Float(size.height))
        }
    }

    private func makeFragmentBuffer(device: MTLDevice) -> MTLBuffer? {
        return device.makeBuffer(length: MemoryLayout<FragmentContext>.stride, options: .storageModeShared)
    }

    private func updateFragmentBuffer(_ context: inout FragmentContext) {
        memcpy(self.fragmentBuffer.contents(), &context, MemoryLayout<FragmentContext>.stride)
    }

    //
    // Renderer functions
    //

    /// Calls when resized.
    func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {
    }

    func draw(in _: MTKView) {
        guard let descriptor = self.currentRenderPassDescriptor else { return }

        // Set up render pipeline
        let buffer = self.commandQueue.makeCommandBuffer()!
        let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor)!
        encoder.setRenderPipelineState(self.pipelineState)

        // Set up buffers
        encoder.setVertexBuffer(self.vertexBuffer, offset: 0, index: 0)

        var context = FragmentContext(size: self.drawableSize)
        updateFragmentBuffer(&context)
        encoder.setFragmentBuffer(self.fragmentBuffer, offset: 0, index: 0)

        // Render
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: 1)
        encoder.endEncoding()

        let drawable = self.currentDrawable!
        buffer.present(drawable)
        buffer.commit()
    }
}
