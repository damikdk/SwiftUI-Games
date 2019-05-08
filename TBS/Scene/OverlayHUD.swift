//
//  OverlayHUD.swift
//  TBS
//
//  Created by Damik Minnegalimov on 08/05/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import Foundation
import SpriteKit

class OverlayHUD: SKScene {
    var currentChaarcterLabel: SKLabelNode!
    
    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = UIColor.white
        
        let label = SKLabelNode(fontNamed: "Verdana-Bold")
      
        let message = "Current Player"
        label.text = message
        label.fontSize = 20
        label.fontColor = UIColor.white
        
        label.verticalAlignmentMode = .bottom
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: size.width / 2, y: 0)

        currentChaarcterLabel = label
        addChild(label)        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
