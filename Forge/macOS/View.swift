//
//  MetalView.swift
//  Forge
//
//  Created by Reza Ali on 8/20/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import MetalKit

@objc public protocol DragDelegate: AnyObject {
    @objc optional func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation
    @objc optional func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation
    @objc optional func draggingEnded(_ sender: NSDraggingInfo)
    @objc optional func draggingExited(_ sender: NSDraggingInfo?)
    @objc optional func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool
    @objc optional func performDragOperation(_ sender: NSDraggingInfo) -> Bool
    @objc optional func concludeDragOperation(_ sender: NSDraggingInfo?)
}

class View: MTKView {
    open weak var dragDelegate: DragDelegate?
    
    open override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let modifiers: NSEvent.ModifierFlags = [.capsLock, .control, .option, .command, .numericPad, .help, .function]
        let result = event.modifierFlags.isDisjoint(with: modifiers)
        return result
    }
    
    open override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let dd = dragDelegate, let result = dd.draggingEntered?(sender) {
            return result
        }
        return []
    }
    
    open override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if let dd = dragDelegate, let result = dd.draggingUpdated?(sender) {
            return result
        }
        return []
    }
    
    open override func draggingEnded(_ sender: NSDraggingInfo) {
        dragDelegate?.draggingEnded?(sender)
    }
    
    open override func draggingExited(_ sender: NSDraggingInfo?) {
        dragDelegate?.draggingExited?(sender)
    }
    
    open override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let dd = dragDelegate, let result = dd.prepareForDragOperation?(sender) {
            return result
        }
        return false
    }
    
    open override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let dd = dragDelegate, let result = dd.performDragOperation?(sender) {
            return result
        }
        return false
    }
    
    open override func concludeDragOperation(_ sender: NSDraggingInfo?) {
        dragDelegate?.concludeDragOperation?(sender)
    }
    
    open override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}
