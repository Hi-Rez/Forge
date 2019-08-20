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
        self.setupMTKView()
        self.setupRenderer()
    }

    open func setupMTKView() {
        guard let mtkView = self.view as? MTKView else {
            print("View attached to ViewController is not an MTKView")
            return
        }

        // Select the device to render with.  We choose the default device
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
}
