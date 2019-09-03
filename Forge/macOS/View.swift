//
//  MetalView.swift
//  Forge
//
//  Created by Reza Ali on 8/20/19.
//  Copyright © 2019 Reza Ali. All rights reserved.
//

import MetalKit

open class View: MTKView {
    open override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let modifiers: NSEvent.ModifierFlags = [.capsLock, .control, .option, .command, .numericPad, .help, .function]
        let result = event.modifierFlags.isDisjoint(with: modifiers)
        return result
    }
}
