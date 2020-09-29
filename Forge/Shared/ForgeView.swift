//
//  ForgeView.swift
//  Forge
//
//  Created by Reza Ali on 9/29/20.
//

import SwiftUI

#if os(macOS)
public struct ForgeView: NSViewControllerRepresentable {
    public var renderer: Forge.Renderer
    public typealias NSViewControllerType = Forge.ViewController
    
    public init(renderer: Forge.Renderer) {
        self.renderer = renderer
    }
    
    public func makeNSViewController(context: Self.Context) -> Self.NSViewControllerType {
        let vc = Forge.ViewController(nibName: .init("ViewController"), bundle: Bundle(for: Forge.ViewController.self))
        vc.renderer = renderer
        return vc
    }
    
    public func updateNSViewController(_ nsViewController: Self.NSViewControllerType, context: Self.Context) {
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject {
        var parent: ForgeView
        init(_ parent: ForgeView) {
            self.parent = parent
        }
    }
}

#else

public struct ForgeView: UIViewControllerRepresentable {
    public var renderer: Forge.Renderer
    public typealias UIViewControllerType = Forge.ViewController
        
    public init(renderer: Forge.Renderer) {
        self.renderer = renderer
    }
    
    public func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType {
        let vc = Forge.ViewController(nibName: .init("ViewController"), bundle: Bundle(for: Forge.ViewController.self))
        vc.renderer = renderer
        return vc
    }
    
    public func updateUIViewController(_ uiViewController: Self.UIViewControllerType, context: Self.Context) {
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject {
        var parent: ForgeView
        init(_ parent: ForgeView) {
            self.parent = parent
        }
    }
}

#endif
