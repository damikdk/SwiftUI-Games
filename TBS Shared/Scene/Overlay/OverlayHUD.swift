//
//  OverlayHUD.swift
//  TBS
//
//  Created by Damik Minnegalimov on 08/05/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import Foundation
import SpriteKit

let panelPadding: CGFloat = 50

class OverlayHUD: SKScene {
  var characterPanel: SKSpriteNode!
  var abilitiesPanel: SKSpriteNode!
  
  override init(size: CGSize) {
    super.init(size: size)
    
    // set up character info node
    characterPanel = SKSpriteNode()
    
    characterPanel.anchorPoint = .init(x: 0.5, y: 1)
    characterPanel.position = CGPoint(x: size.width / 2, y: size.height - panelPadding)
    addChild(characterPanel)
    
    // set up abilities node
    abilitiesPanel = SKSpriteNode()
    
    abilitiesPanel.anchorPoint = .init(x: 0.5, y: 0)
    abilitiesPanel.position = CGPoint(x: size.width / 2, y: 0 + panelPadding)
    addChild(abilitiesPanel)
  }
  
  func setupUI(for game: Game) {
    characterPanel.removeAllChildren()
    abilitiesPanel.removeAllChildren()

    guard let character = game.currentCharacter else {
      return
    }
    
    // set up label node
    let label = SKLabelNode(fontNamed: "Verdana-Bold")
    label.name = "Current Player's Name"
    
    label.text = character.role.rawValue + " (\(character.HP!) HP)"
    label.fontSize = 14
    label.fontColor = SCNColor.white
    
    label.verticalAlignmentMode = .top
    label.horizontalAlignmentMode = .center
    label.position = CGPoint(x: 0, y: 0)
    
    characterPanel.addChild(label)
    
    let buttonWidth = 80
    
    for (index, ability) in character.abilities.enumerated() {
      let abilityIcon = ability.icon!
      let selectedAbilityIcon = abilityIcon.tinted(with: SCNColor.gray, backgroundColor: SCNColor.clear)
      
      let buttonTexture = SKTexture(image: abilityIcon)
      let buttonTextureSelected = SKTexture(image: selectedAbilityIcon!)
      
      let button = SKButton(normalTexture: buttonTexture,
                            selectedTexture: buttonTextureSelected,
                            disabledTexture: buttonTexture)
      
      button.onPress = {
        ability.action(game, character)
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
