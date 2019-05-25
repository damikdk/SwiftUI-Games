//
//  SKButton.swift
//  TBS
//
//  Created by Damik Minnegalimov on 11/05/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import SpriteKit

class SKButton: SKSpriteNode {
    
    enum FTButtonActionType: Int {
        case TouchUpInside = 1,
        TouchDown,
        TouchUp
    }
    
    var isEnabled: Bool = true {
        didSet {
            if (disabledTexture != nil) {
                texture = isEnabled ? defaultTexture : disabledTexture
            }
        }
    }
    var isSelected: Bool = false {
        didSet {
            texture = isSelected ? selectedTexture : defaultTexture
        }
    }
    
    var defaultTexture: SKTexture
    var selectedTexture: SKTexture
    var disabledTexture: SKTexture?
    var label: SKLabelNode
    var onPress: (() -> Void)?

    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(normalTexture defaultTexture: SKTexture!, selectedTexture:SKTexture!, disabledTexture: SKTexture?) {
        self.defaultTexture = defaultTexture
        self.selectedTexture = selectedTexture
        self.disabledTexture = disabledTexture
        self.label = SKLabelNode(fontNamed: "Helvetica");
        
        super.init(texture: defaultTexture, color: SCNColor.white, size: defaultTexture.size())
        isUserInteractionEnabled = true
        
        //Creating and adding a blank label, centered on the button
        self.label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center;
        self.label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center;
        addChild(self.label)
    }
    
    /*
     New function for setting text. Calling function multiple times does
     not create a ton of new labels, just updates existing label.
     You can set the title, font type and font size with this function
     */
    
    func setButtonLabel(title: NSString, font: String, fontSize: CGFloat) {
        self.label.text = title as String
        self.label.fontSize = fontSize
        self.label.fontName = font
    }
    
    #if os(macOS)
    override func touchesBegan(with event: NSEvent?) {
        if (!isEnabled) {
            return
        }
        
        isSelected = true
    }
    
    override func touchesMoved(with event: NSEvent?) {
        if (!isEnabled) {
            return
        }
        
        if (frame.contains(event!.locationInWindow)) {
            isSelected = true
        } else {
            isSelected = false
        }
    }
    
    override func touchesEnded(with event: NSEvent?) {
        if (!isEnabled) {
            return
        }
        
        isSelected = false
        
        onPress?()
    }
    
    override func touchesCancelled(with event: NSEvent?) {
        if (!isEnabled) {
            return
        }
        
        isSelected = false
        
        onPress?()
    }
    #else
    override func mouseDown(with event: NSEvent) {
        if (!isEnabled) {
            return
        }
        
        isSelected = true
    }
    
    override func mouseUp(with event: NSEvent) {
        if (!isEnabled) {
            return
        }
        
        isSelected = false
        
        onPress?()
    }
    
    override func mouseMoved(with event: NSEvent) {
        if (!isEnabled) {
            return
        }
        
        let touch: AnyObject! = touches.first
        let touchLocation = touch.location(in: parent!)
        
        if (frame.contains(touchLocation)) {
            isSelected = true
        } else {
            isSelected = false
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        // Hover
    }
    
    override func mouseExited(with event: NSEvent) {
        isSelected = false
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    #endif
}
