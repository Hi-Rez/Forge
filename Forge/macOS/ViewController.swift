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
    open var lowPower: Bool = false
    open var mtkView: MTKView? {
        didSet {
            if let mtkView = self.mtkView, let renderer = self.renderer {
                renderer.mtkView = mtkView
                mtkView.delegate = renderer
            }
        }
    }
        
    open var renderer: Renderer? = nil {
        willSet {
            if let mtkView = self.mtkView, let _ = self.renderer {
                mtkView.delegate = nil
            }
        }
        didSet {
            if let mtkView = self.mtkView, let renderer = self.renderer {
                renderer.mtkView = mtkView
                mtkView.delegate = renderer
            }
        }
    }
    
    open var trackingArea: NSTrackingArea?
    open var keyDownHandler: Any?
    open var keyUpHandler: Any?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupEvents()
        self.setupTracking()
    }
    
    open func setupTracking() {
        let area = NSTrackingArea(rect: self.view.bounds, options: [.activeAlways, .mouseEnteredAndExited, .mouseMoved, .inVisibleRect], owner: self, userInfo: nil)
        self.view.addTrackingArea(area)
        self.trackingArea = area
    }
    
    open func removeTracking() {
        if let trackingArea = trackingArea {
            self.view.removeTrackingArea(trackingArea)
            self.trackingArea = nil
            NSCursor.setHiddenUntilMouseMoves(false)
        }
    }
    
    open override var acceptsFirstResponder: Bool { return true }
    open override func becomeFirstResponder() -> Bool { return true }
    open override func resignFirstResponder() -> Bool { return true }
    
    open func setupEvents() {
        self.view.allowedTouchTypes = .indirect
        self.keyDownHandler = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [unowned self] (aEvent) -> NSEvent? in
            self.keyDown(with: aEvent)
            return aEvent
        }
        
        self.keyUpHandler = NSEvent.addLocalMonitorForEvents(matching: .keyUp) { [unowned self] (aEvent) -> NSEvent? in
            self.keyUp(with: aEvent)
            return aEvent
        }
        
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAppearance),
            name: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil
        )
        
        updateAppearance()
    }
    
    @objc func updateAppearance() {
        guard let renderer = self.renderer else { return }
        
        if let _ = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") {
            renderer.appearence = .dark
        }
        else {
            renderer.appearence = .light
        }
    }
    
    open func removeEvents() {
        guard let keyDownHandler = self.keyDownHandler else { return }
        NSEvent.removeMonitor(keyDownHandler)
        
        guard let keyUpHandler = self.keyUpHandler else { return }
        NSEvent.removeMonitor(keyUpHandler)
        
        DistributedNotificationCenter.default.removeObserver(self,
                                                             name: Notification.Name("AppleInterfaceThemeChangedNotification"),
                                                             object: nil)
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
        
        var forgeDevice = defaultDevice
        if !lowPower {
            let devices = MTLCopyAllDevices()
            for device in devices {
                if !device.isLowPower {
                    forgeDevice = device
                    break
                }
            }
        }
        
        mtkView.device = forgeDevice
        self.mtkView = mtkView
    }
    
    open func setupRenderer() {
        guard let renderer = self.renderer, let mtkView = self.mtkView else { return }
        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
    }
    
    open override func touchesBegan(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.touchesBegan(with: event)
        }
    }
    
    open override func touchesEnded(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.touchesEnded(with: event)
        }
    }
    
    open override func touchesMoved(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.touchesMoved(with: event)
        }
    }
    
    open override func touchesCancelled(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.touchesCancelled(with: event)
        }
    }
    
    open override func mouseMoved(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.mouseMoved(with: event)
        }
    }
    
    open override func mouseDown(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.mouseDown(with: event)
        }
    }
    
    open override func mouseDragged(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.mouseDragged(with: event)
        }
    }
    
    open override func mouseUp(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.mouseUp(with: event)
        }
    }
    
    open override func mouseEntered(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.mouseEntered(with: event)
        }
    }
    
    open override func mouseExited(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.mouseExited(with: event)
        }
    }
    
    open override func magnify(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.magnify(with: event)
        }
    }
    
    open override func rotate(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.rotate(with: event)
        }
    }
    
    open override func scrollWheel(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.scrollWheel(with: event)
        }
    }
    
    open override func keyDown(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.keyDown(with: event)
        }
    }
    
    open override func keyUp(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.keyUp(with: event)
        }
    }
    
    deinit {
        removeTracking()
        removeEvents()
    }
}
