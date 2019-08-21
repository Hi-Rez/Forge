//
//  ViewController.swift
//  Forge
//
//  Created by Reza Ali on 8/19/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import Cocoa
import MetalKit

// Our macOS specific view controller
open class ViewController: NSViewController {
    open var mtkView: MTKView!
    open var renderer: Renderer?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupRenderer()
        self.setupEvents()
    }
    
    open func setupEvents() {
        self.mtkView.allowedTouchTypes = .indirect
    }
    
    open func setupView() {
        guard let mtkView = self.view as? MTKView else {
            print("View attached to ViewController is not an MTKView")
            return
        }
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        
        mtkView.device = defaultDevice
        self.mtkView = mtkView
    }
    
    open func setupRenderer() {
        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        let typ: AnyClass = NSClassFromString("\(namespace).Renderer")!
        let cls = typ as! Renderer.Type
        if let renderer = cls.init(metalKitView: self.mtkView) {
            renderer.mtkView(self.mtkView, drawableSizeWillChange: self.mtkView.drawableSize)
            self.mtkView.delegate = renderer
            self.renderer = renderer
        }
    }
    
    open override func touchesBegan(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        renderer.touchesBegan(with: event)
    }
    
    open override func touchesEnded(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        renderer.touchesEnded(with: event)
    }
    
    open override func touchesMoved(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        renderer.touchesMoved(with: event)
    }
    
    open override func touchesCancelled(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        renderer.touchesCancelled(with: event)
    }
    
    open override func mouseMoved(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        renderer.mouseMoved(with: event)
    }
    
    open override func mouseDown(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        renderer.mouseDown(with: event)
    }
    
    open override func mouseDragged(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        renderer.mouseDragged(with: event)
    }
    
    open override func mouseUp(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        renderer.mouseUp(with: event)
    }
    
    open override func mouseEntered(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        renderer.mouseEntered(with: event)
    }
    
    open override func mouseExited(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        renderer.mouseExited(with: event)
    }
    
    open override func magnify(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        renderer.magnify(with: event)
    }
    
    open override func rotate(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        renderer.rotate(with: event)
    }
    
    open override func scrollWheel(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        renderer.scrollWheel(with: event)
    }
    
    open override func keyDown(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        renderer.keyDown(with: event)
    }
    
    open override func keyUp(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        renderer.keyUp(with: event)
    }
}
