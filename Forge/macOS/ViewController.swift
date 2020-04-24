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
    var trackingArea: NSTrackingArea?
    open var renderer: Renderer? {
        willSet {
            if renderer == nil {
                mtkView.delegate = nil
            }
        }
        didSet {
            if renderer != nil {
                mtkView.delegate = renderer
                setupRenderer()
            }
        }
    }
    
    open var keyDownHandler: Any?
    open var keyUpHandler: Any?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupRenderer()
        self.setupEvents()
        self.setupTracking()
    }
    
    func setupTracking() {
        let area = NSTrackingArea(rect: mtkView.bounds, options: [.activeAlways, .mouseEnteredAndExited, .mouseMoved, .inVisibleRect], owner: self, userInfo: nil)
        self.mtkView.addTrackingArea(area)
        self.trackingArea = area
    }
    
    func removeTracking() {
        if let trackingArea = trackingArea {
            self.mtkView.removeTrackingArea(trackingArea)
            self.trackingArea = nil
            NSCursor.setHiddenUntilMouseMoves(false)
        }
    }
    
    open override var acceptsFirstResponder: Bool { return true }
    open override func becomeFirstResponder() -> Bool { return true }
    open override func resignFirstResponder() -> Bool { return true }
    
    open func setupEvents() {
        self.mtkView.allowedTouchTypes = .indirect
        self.keyDownHandler = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [unowned self] (aEvent) -> NSEvent? in
            self.keyDown(with: aEvent)
            return aEvent
        }
        
        self.keyUpHandler = NSEvent.addLocalMonitorForEvents(matching: .keyUp) { [unowned self] (aEvent) -> NSEvent? in
            self.keyUp(with: aEvent)
            return aEvent
        }
    }
    
    open func removeEvents() {
        guard let keyDownHandler = self.keyDownHandler else { return }
        NSEvent.removeMonitor(keyDownHandler)
        
        guard let keyUpHandler = self.keyUpHandler else { return }
        NSEvent.removeMonitor(keyUpHandler)
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
        if let renderer = self.renderer {
            renderer.mtkView(self.mtkView, drawableSizeWillChange: self.mtkView.drawableSize)
        }
    }
    
    open override func touchesBegan(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.mtkView.window {
            renderer.touchesBegan(with: event)
        }
    }
    
    open override func touchesEnded(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.mtkView.window {
            renderer.touchesEnded(with: event)
        }
    }
    
    open override func touchesMoved(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.mtkView.window {
            renderer.touchesMoved(with: event)
        }
    }
    
    open override func touchesCancelled(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.mtkView.window {
            renderer.touchesCancelled(with: event)
        }
    }
    
    open override func mouseMoved(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.mtkView.window {
            renderer.mouseMoved(with: event)
        }
    }
    
    open override func mouseDown(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.mtkView.window {
            renderer.mouseDown(with: event)
        }
    }
    
    open override func mouseDragged(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.mtkView.window {
            renderer.mouseDragged(with: event)
        }
    }
    
    open override func mouseUp(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.mtkView.window {
            renderer.mouseUp(with: event)
        }
    }
    
    open override func mouseEntered(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.mtkView.window {
            renderer.mouseEntered(with: event)
        }
    }
    
    open override func mouseExited(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.mtkView.window {
            renderer.mouseExited(with: event)
        }
    }
    
    open override func magnify(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.mtkView.window {
            renderer.magnify(with: event)
        }
    }
    
    open override func rotate(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.mtkView.window {
            renderer.rotate(with: event)
        }
    }
    
    open override func scrollWheel(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.mtkView.window {
            renderer.scrollWheel(with: event)
        }
    }
    
    open override func keyDown(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.mtkView.window {
            renderer.keyDown(with: event)
        }
    }
    
    open override func keyUp(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.mtkView.window {
            renderer.keyUp(with: event)
        }
    }
    
    deinit {
        removeTracking()
        removeEvents()
    }
}
