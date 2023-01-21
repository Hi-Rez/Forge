//
//  ViewController.swift
//  Forge-iOS
//
//  Created by Reza Ali on 10/15/19.
//

import MetalKit

#if os(iOS) || os(tvOS)

import UIKit

open class ViewController: UIViewController {
    open var lowPower: Bool = false
    open var autoRotate: Bool = true

    var drawableSize: CGSize = .zero {
        didSet {
            guard let mtkView = self.mtkView, let renderer = self.renderer else { return }
            if self.drawableSize.width != oldValue.width || self.drawableSize.height != oldValue.height {
                if self.drawableSize.width > 0, self.drawableSize.height > 0 {
                    renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
                }
            }
        }
    }

    open var mtkView: MTKView?

    open var renderer: Renderer? {
        willSet {
            if let mtkView = self.mtkView, let _ = self.renderer {
                mtkView.delegate = nil
                drawableSize = .zero
            }
        }
        didSet {
            setupRenderer()
        }
    }

    open var keyDownHandler: Any?
    open var keyUpHandler: Any?

    public init(renderer: Renderer?, lowPower: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.renderer = renderer
        self.lowPower = lowPower
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func loadView() {
        view = MTKView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupEvents()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupRenderer()
    }

    override open func viewWillDisappear(_ animated: Bool) {
        self.cleanupRenderer()
        super.viewWillDisappear(animated)
    }

    open func setupRenderer() {
        guard let mtkView = self.mtkView, let renderer = self.renderer else { return }
        renderer.mtkView = mtkView
        self.drawableSize = mtkView.drawableSize
        self.updateAppearance()
        mtkView.delegate = renderer
    }

    open func cleanupRenderer() {
        guard let mtkView = self.mtkView, let renderer = self.renderer else { return }
        renderer.cleanup()
        renderer.isSetup = false
        mtkView.delegate = nil
    }

    func updateAppearance() {
        guard let renderer = renderer else { return }
        if self.traitCollection.userInterfaceStyle == .dark {
            renderer.appearance = .dark
        }
        else if self.traitCollection.userInterfaceStyle == .light {
            renderer.appearance = .light
        }
        else if self.traitCollection.userInterfaceStyle == .unspecified {
            renderer.appearance = .light
        }
    }

    open func setupEvents() {}

    open func removeEvents() {}

    open func setupView() {
        #if os(iOS)
        view.isMultipleTouchEnabled = true
        #endif

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

    open func resize() {
        guard let mtkView = self.mtkView else { return }
        let frame = view.frame
        let scale = UIScreen.main.scale
        let pixels = CGSize(width: frame.width * scale, height: frame.height * scale)
        mtkView.drawableSize = pixels
        self.drawableSize = mtkView.drawableSize
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.resize()
    }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            self.updateAppearance()
        }
        super.traitCollectionDidChange(previousTraitCollection)
    }

    #if os(iOS)
    override open var shouldAutorotate: Bool { return self.autoRotate }
    #endif

    deinit {
        mtkView?.delegate = nil
        renderer = nil
        removeEvents()
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let renderer = self.renderer else { return }
        renderer.touchesBegan(touches, with: event)
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let renderer = self.renderer else { return }
        renderer.touchesMoved(touches, with: event)
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let renderer = self.renderer else { return }
        renderer.touchesEnded(touches, with: event)
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let renderer = self.renderer else { return }
        renderer.touchesCancelled(touches, with: event)
    }
}

#elseif os(macOS)

import Cocoa
// Our macOS specific view controller
open class ViewController: NSViewController {
    open var lowPower: Bool = false

    var drawableSize: CGSize = .zero {
        didSet {
            guard let mtkView = self.mtkView, let renderer = self.renderer else { return }
            if self.drawableSize.width != oldValue.width || self.drawableSize.height != oldValue.height {
                if self.drawableSize.width > 0, self.drawableSize.height > 0 {
                    renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
                }
            }
        }
    }

    @objc open var mtkView: MTKView?

    @objc open var renderer: Renderer? {
        willSet {
            if let mtkView = self.mtkView, let _ = self.renderer {
                mtkView.delegate = nil
                drawableSize = .zero
            }
        }
        didSet {
            setupRenderer()
        }
    }

    open var trackingArea: NSTrackingArea?
    open var keyDownHandler: Any?
    open var keyUpHandler: Any?
    open var flagsChangedHandler: Any?

    public init(renderer: Renderer?, lowPower: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.lowPower = lowPower
        self.renderer = renderer
    }

    public required init?(coder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }

    override open func loadView() {
        view = MetalView()
        view.autoresizingMask = [.width, .height]
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupEvents()
        self.setupTracking()
    }

    override open func viewWillAppear() {
        super.viewWillAppear()
        self.setupRenderer()
    }

    override open func viewWillDisappear() {
        self.cleanupRenderer()
        super.viewWillDisappear()
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
        self.keyDownHandler = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [unowned self] aEvent -> NSEvent? in
            self.keyDown(with: aEvent)
            return aEvent
        }

        self.keyUpHandler = NSEvent.addLocalMonitorForEvents(matching: .keyUp) { [unowned self] aEvent -> NSEvent? in
            self.keyUp(with: aEvent)
            return aEvent
        }

        self.flagsChangedHandler = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [unowned self] aEvent -> NSEvent? in
            self.flagsChanged(with: aEvent)
            return aEvent
        }

        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateAppearance),
            name: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil
        )
    }

    @objc func updateAppearance() {
        guard let renderer = self.renderer else { return }
        let appleInterfaceStyle: String? = UserDefaults.standard.string(forKey: "AppleInterfaceStyle")
        renderer.appearance = appleInterfaceStyle == nil ? .light : .dark
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
        guard let mtkView = self.mtkView, let renderer = self.renderer else { return }
        renderer.mtkView = mtkView
        self.drawableSize = mtkView.drawableSize
        self.updateAppearance()
        mtkView.delegate = renderer
    }

    open func cleanupRenderer() {
        guard let mtkView = self.mtkView, let renderer = self.renderer else { return }
        renderer.cleanup()
        renderer.isSetup = false
        mtkView.delegate = nil
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

    override open func swipe(with event: NSEvent) {
        guard let renderer = self.renderer else { return }
        if event.window == self.view.window {
            renderer.swipe(with: event)
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
        mtkView?.delegate = nil
        renderer = nil
        removeTracking()
        removeEvents()
    }
}

#endif
