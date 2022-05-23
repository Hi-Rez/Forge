//
//  MetalView.swift
//  Forge
//
//  Created by Reza Ali on 8/20/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import MetalKit

#if os(macOS)

public protocol DragDelegate: AnyObject {
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation
    func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation
    func draggingEnded(_ sender: NSDraggingInfo)
    func draggingExited(_ sender: NSDraggingInfo?)
    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool
    func concludeDragOperation(_ sender: NSDraggingInfo?)
}

public protocol TouchDelegate: AnyObject {
    func touchesBegan(with event: NSEvent)
    func touchesMoved(with event: NSEvent)
    func touchesEnded(with event: NSEvent)
    func touchesCancelled(with event: NSEvent)
}

open class MetalView: MTKView {
    open weak var dragDelegate: DragDelegate?
    open weak var touchDelegate: TouchDelegate?
    
    override public init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        allowedTouchTypes = [.indirect]
        wantsRestingTouches = false
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Key Equivalent
    
    override open func performKeyEquivalent(with event: NSEvent) -> Bool {
        let modifiers: NSEvent.ModifierFlags = [.capsLock, .control, .option, .command, .numericPad, .help, .function]
        let result = event.modifierFlags.isDisjoint(with: modifiers)
        return result || (event.keyCode > 122 && event.keyCode < 127)
    }
    
    // MARK: - Drag & Drop
    
    override open func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let dd = dragDelegate {
            return dd.draggingEntered(sender)
        }
        return []
    }
    
    override open func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let dd = dragDelegate {
            return dd.draggingUpdated(sender)
        }
        return []
    }
    
    override open func draggingEnded(_ sender: NSDraggingInfo) {
        dragDelegate?.draggingEnded(sender)
    }
    
    override open func draggingExited(_ sender: NSDraggingInfo?) {
        dragDelegate?.draggingExited(sender)
    }
    
    override open func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let dd = dragDelegate {
            return dd.prepareForDragOperation(sender)
        }
        return false
    }
    
    override open func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let dd = dragDelegate {
            return dd.performDragOperation(sender)
        }
        return false
    }
    
    override open func concludeDragOperation(_ sender: NSDraggingInfo?) {
        dragDelegate?.concludeDragOperation(sender)
    }
    
    // MARK: - Mouse
    
    override open func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
    // MARK: - Touches
    
    override open func touchesBegan(with event: NSEvent) {
        touchDelegate?.touchesBegan(with: event)
    }
    
    override open func touchesMoved(with event: NSEvent) {
        touchDelegate?.touchesMoved(with: event)
    }
    
    override open func touchesEnded(with event: NSEvent) {
        touchDelegate?.touchesEnded(with: event)
    }
    
    override open func touchesCancelled(with event: NSEvent) {
        touchDelegate?.touchesCancelled(with: event)
    }
}

#endif
