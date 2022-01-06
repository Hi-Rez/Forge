//
//  Renderer.swift
//  Satin
//
//  Created by Reza Ali on 7/22/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import Metal
import MetalKit
import simd 

public let maxBuffersInFlight: Int = 3

open class Renderer: NSObject, MTKViewDelegate {
    public enum Appearance {
        case dark
        case light
    }
    
    public weak var mtkView: MTKView! {
        didSet {
            if self.mtkView != nil {
                self.device = self.mtkView.device!
                
                guard let queue = self.device.makeCommandQueue() else { return }
                self.commandQueue = queue
                
                self.mtkView.depthStencilPixelFormat = .depth32Float_stencil8
                self.mtkView.colorPixelFormat = .bgra8Unorm
                
                self.setupMtkView(self.mtkView)
                
                self.setup()
            }
        }
    }
        
    public var appearance: Appearance = .dark {
        didSet {
            self.updateAppearance()
        }
    }
    
    public var device: MTLDevice!
    public var commandQueue: MTLCommandQueue!
    
    public var sampleCount: Int {
        return self.mtkView.sampleCount
    }
    
    public var colorPixelFormat: MTLPixelFormat {
        return self.mtkView.colorPixelFormat
    }
    
    public var depthStencilPixelFormat: MTLPixelFormat {
        return self.mtkView.depthStencilPixelFormat
    }
    
    public var depthPixelFormat: MTLPixelFormat {
        return self.mtkView.depthStencilPixelFormat
    }
    
    public var stencilPixelFormat: MTLPixelFormat {
        if self.depthPixelFormat == .depth32Float {
            return .invalid
        }
        return self.mtkView.depthStencilPixelFormat
    }
    
    let inFlightSemaphore = DispatchSemaphore(value: maxBuffersInFlight)
    var inFlightSemaphoreWait = 0
    var inFlightSemaphoreRelease = 0
        
    override public init() {
        super.init()
    }
    
    deinit {
//        print("forge dealloc wait: \(inFlightSemaphoreWait)")
//        print("forge dealloc release: \(inFlightSemaphoreRelease)")
//        print("forge dealloc count: \(inFlightSemaphoreCount)")
        let delta = inFlightSemaphoreWait + inFlightSemaphoreRelease
        for _ in 0 ..< delta {
            inFlightSemaphore.signal()
        }
    }
    
    open func setupMtkView(_ metalKitView: MTKView) {}
    
    open func draw(in view: MTKView) {
        guard let _ = view.currentDrawable, let commandBuffer = self.preDraw() else { return }
        self.draw(view, commandBuffer)
        self.postDraw(view, commandBuffer)
    }
    
    open func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.resize((width: Float(size.width), height: Float(size.height)))
    }
    
    open func preDraw() -> MTLCommandBuffer? {
        _ = self.inFlightSemaphore.wait(timeout: DispatchTime.distantFuture)
        self.update()
        self.inFlightSemaphoreWait += 1
        return self.commandQueue.makeCommandBuffer()
    }
    
    open func postDraw(_ view: MTKView, _ commandBuffer: MTLCommandBuffer) {
        guard let drawable = view.currentDrawable else { return }
        commandBuffer.present(drawable)
        let blockSemaphone = self.inFlightSemaphore
        commandBuffer.addCompletedHandler { [weak self] _ in
            blockSemaphone.signal()
            if let strongSelf = self {
                strongSelf.inFlightSemaphoreRelease -= 1
            }
        }
        commandBuffer.commit()
    }
    
    open func setup() {}
    
    open func update() {}
    
    open func draw(_ view: MTKView, _ commandBuffer: MTLCommandBuffer) {}
    
    open func resize(_ size: (width: Float, height: Float)) {}
    
    open func updateAppearance() {}
    
    #if os(macOS)
    
    open func touchesBegan(with event: NSEvent) {}
    
    open func touchesEnded(with event: NSEvent) {}
    
    open func touchesMoved(with event: NSEvent) {}
    
    open func touchesCancelled(with event: NSEvent) {}
    
    open func scrollWheel(with event: NSEvent) {}
    
    open func mouseMoved(with event: NSEvent) {}
    
    open func mouseDown(with event: NSEvent) {}
    
    open func mouseDragged(with event: NSEvent) {}
    
    open func mouseUp(with event: NSEvent) {}
    
    open func mouseEntered(with event: NSEvent) {}
    
    open func mouseExited(with event: NSEvent) {}
    
    open func rightMouseDown(with event: NSEvent) {}
    
    open func rightMouseDragged(with event: NSEvent) {}
    
    open func rightMouseUp(with event: NSEvent) {}
    
    open func otherMouseDown(with event: NSEvent) {}
    
    open func otherMouseDragged(with event: NSEvent) {}
    
    open func otherMouseUp(with event: NSEvent) {}
        
    open func keyDown(with event: NSEvent) {}
    
    open func keyUp(with event: NSEvent) {}
    
    open func flagsChanged(with event: NSEvent) {}
    
    open func magnify(with event: NSEvent) {}
    
    open func rotate(with event: NSEvent) {}
    
    #elseif os(iOS) || os(tvOS)
    
    open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {}
    
    open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}
    
    open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {}
    
    open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
    
    #endif
}
