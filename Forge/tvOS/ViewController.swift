//
//  ViewController.swift
//  Forge-iOS
//
//  Created by Reza Ali on 10/15/19.
//

import MetalKit
import UIKit

open class ViewController: UIViewController {
    open var mtkView: MTKView!
    open var renderer: Renderer? {
        willSet {
            if renderer != nil {
                mtkView.delegate = nil
            }
        }
        didSet {
            if renderer != nil {
                mtkView.delegate = renderer
            }
        }
    }
    
    open var rendererClassName: String? {
        didSet {
            self.setupRenderer()
        }
    }
    
    open var keyDownHandler: Any?
    open var keyUpHandler: Any?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupRenderer()
        self.setupEvents()
    }
    
    open func setupEvents() {}
    
    open func removeEvents() {}
    
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
        if let mtkView = self.mtkView, let rendererClass = rendererClassName {
            let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
            if let typ: AnyClass = NSClassFromString("\(namespace)." + "\(rendererClass)") {
                let cls = typ as! Renderer.Type
                if let renderer = cls.init(metalKitView: mtkView) {
                    renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
                    self.renderer = renderer
                }
            }
        }
    }
    
    open func resize() {
        if let renderer = self.renderer {
            let frame = view.frame
            let scale = UIScreen.main.scale
            let pixels = CGSize(width: frame.width * scale, height: frame.height * scale)
            renderer.mtkView.drawableSize = pixels
            renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        }
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.resize()
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.resize()
    }
    
    deinit {
        removeEvents()
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let renderer = self.renderer else { return }
        renderer.touchesBegan(touches, with: event)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let renderer = self.renderer else { return }
        renderer.touchesMoved(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let renderer = self.renderer else { return }
        renderer.touchesEnded(touches, with: event)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let renderer = self.renderer else { return }
        renderer.touchesCancelled(touches, with: event)
    }
}
