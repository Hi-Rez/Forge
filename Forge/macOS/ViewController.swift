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
    @objc open var mtkView: MTKView? {
        didSet {
            if let mtkView = self.mtkView, let renderer = self.renderer {
                renderer.mtkView = mtkView
                mtkView.delegate = renderer
                renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
            }
        }
    }
        
    @objc open var renderer: Renderer? {
        willSet {
            if let mtkView = self.mtkView, let _ = self.renderer {
                mtkView.delegate = nil
            }
        }
        didSet {
            if let mtkView = self.mtkView, let renderer = self.renderer {
                renderer.mtkView = mtkView
                mtkView.delegate = renderer
                renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
            }
        }
    }
    
    open var trackingArea: NSTrackingArea?
    open var keyDownHandler: Any?
    open var keyUpHandler: Any?
    open var flagsChangedHandler: Any?
    
    override open func viewDidLoad() {
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
    
    override open var acceptsFirstResponder: Bool { return true }
    override open func becomeFirstResponder() -> Bool { return true }
    override open func resignFirstResponder() -> Bool { return true }
    
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
        
        self.flagsChangedHandler = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [unowned self] (aEvent) -> NSEvent? in
            self.flagsChanged(with: aEvent)
            return aEvent
        }
        
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateAppearance),
            name: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil
        )
        
        self.updateAppearance()
    }
    
    @objc func updateAppearance() {
        guard let renderer = self.renderer else { return }
        
        if let _ = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") {
            renderer.appearance = .dark
        }
        else {
            renderer.appearance = .light
        }
    }
    
    open func removeEvents() {
        guard let keyDownHandler = self.keyDownHandler else { return }
        NSEvent.removeMonitor(keyDownHandler)
        
        guard let keyUpHandler = self.keyUpHandler else { return }
        NSEvent.removeMonitor(keyUpHandler)
        
        guard let flagsChangedHandler = self.flagsChangedHandler else { return }
        NSEvent.removeMonitor(flagsChangedHandler)
        
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
        if !self.lowPower {
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
    
    override open func touchesBegan(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.touchesBegan(with: event)
        }
    }
    
    override open func touchesEnded(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.touchesEnded(with: event)
        }
    }
    
    override open func touchesMoved(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.touchesMoved(with: event)
        }
    }
    
    override open func touchesCancelled(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.touchesCancelled(with: event)
        }
    }
    
    override open func mouseMoved(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.mouseMoved(with: event)
        }
    }
    
    override open func mouseDown(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.mouseDown(with: event)
        }
    }
    
    override open func mouseDragged(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.mouseDragged(with: event)
        }
    }
    
    override open func mouseUp(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.mouseUp(with: event)
        }
    }
    
    override open func rightMouseDown(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.rightMouseDown(with: event)
        }
    }
    
    override open func rightMouseDragged(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.rightMouseDragged(with: event)
        }
    }
    
    override open func rightMouseUp(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.rightMouseUp(with: event)
        }
    }
    
    override open func otherMouseDown(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.otherMouseDown(with: event)
        }
    }
    
    override open func otherMouseDragged(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.otherMouseDragged(with: event)
        }
    }
    
    override open func otherMouseUp(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.otherMouseUp(with: event)
        }
    }
    
    override open func mouseEntered(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.mouseEntered(with: event)
        }
    }
    
    override open func mouseExited(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.mouseExited(with: event)
        }
    }
    
    override open func magnify(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.magnify(with: event)
        }
    }
    
    override open func rotate(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.rotate(with: event)
        }
    }
    
    override open func scrollWheel(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.scrollWheel(with: event)
        }
    }
    
    override open func keyDown(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.keyDown(with: event)
        }
    }
    
    override open func keyUp(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.keyUp(with: event)
        }
    }
    
    override open func flagsChanged(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.flagsChanged(with: event)
        }
    }
    
    deinit {
        removeTracking()
        removeEvents()
    }
}
