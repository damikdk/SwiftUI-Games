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
    var currentCharacterLabel: SKLabelNode!
    var abilitiesPanel: SKSpriteNode!
    
    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = UIColor.white
        
        // set up label node
        let label = SKLabelNode(fontNamed: "Verdana-Bold")
        label.name = "Current Player's Name"
      
        let message = "Current Player"
        label.text = message
        label.fontSize = 14
        label.fontColor = UIColor.white
        
        label.verticalAlignmentMode = .top
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: size.width / 2, y: size.height)

        currentCharacterLabel = label
        addChild(label)
        
        // set up abilities node
        abilitiesPanel = SKSpriteNode()
        
        abilitiesPanel.anchorPoint = .init(x: 0.5, y: 0)
        abilitiesPanel.position = CGPoint(x: size.width / 2, y: 0)
        addChild(abilitiesPanel)
    }
    
    func setupUI(character: Character) {
        currentCharacterLabel.text = character.gameID
        
        let buttonWidth = 80
        
        for (index, ability) in character.abilities.enumerated() {
            let abilityIcon = ability.icon!
            let selectedAbilityIcon = abilityIcon.tinted(with: UIColor.gray, backgroundColor: UIColor.clear)
            
            let buttonTexture = SKTexture(image: abilityIcon)
            let buttonTextureSelected = SKTexture(image: selectedAbilityIcon!)
           
            let button = SKButton(normalTexture: buttonTexture,
                                  selectedTexture: buttonTextureSelected,
                                  disabledTexture: buttonTexture)
           
            button.onPress = {
                print("BUTTON PRESSED OMG")
            }
                        
            button.position = CGPoint(x: 0 + buttonWidth * index, y: 0)
            button.zPosition = 1
            button.name = "Ability Button (\(ability.name!))"
            button.anchorPoint = .init(x: 0.5, y: 0)
            button.size = .init(width: buttonWidth, height: buttonWidth)
            abilitiesPanel.addChild(button)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
