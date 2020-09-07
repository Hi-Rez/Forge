//
//  ViewController.swift
//  Forge-iOS
//
//  Created by Reza Ali on 10/15/19.
//

import MetalKit
import UIKit

open class ViewController: UIViewController {
    open var lowPower: Bool = false
    open var mtkView: MTKView? {
        didSet {
            if let mtkView = self.mtkView, let renderer = self.renderer {
                renderer.mtkView = mtkView
                mtkView.delegate = renderer
            }
        }
    }
    
    open var renderer: Renderer? {
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
    
    open func setupRenderer() {
        guard let renderer = self.renderer, let mtkView = self.mtkView else { return }
        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
    }
    
    open func resize() {
        guard let renderer = self.renderer, let mtkView = self.mtkView else { return }
        let frame = view.frame
        let scale = UIScreen.main.scale
        let pixels = CGSize(width: frame.width * scale, height: frame.height * scale)
        renderer.mtkView.drawableSize = pixels
        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.resize()
    }
    
    open override func viewWillLayoutSubviews() {
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
