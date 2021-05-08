//
//  Character.swift
//  TBS
//
//  Created by Damik Minnegalimov on 18/02/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import Foundation
import SceneKit

enum CharacterRole: String {
  case tank = "tank"
  case support = "support"
  case dps = "dps"
}

class Character {
  var HP: Int! = 10 {
    didSet {
      if (HP <= 0) {
        print("Character \(gameID!) died")
        node.highlight()
      }
    }
  }
  
  let node: MaterialNode!
  let role: CharacterRole!
  var gameID: String!
  var abilities = [Ability]()
  
  init(role: CharacterRole) {
    let box: SCNBox
    let color: SCNColor
    let cellSize: CGFloat = FieldConstants.defaultCellSize
    var uuid = UUID().uuidString
    
    switch role {
    case .tank:
      box = SCNBox(width: cellSize * 0.4, height: cellSize, length: cellSize * 0.4, chamferRadius: 0)
      color = SCNColor.DarkTheme.Violet.primary
      uuid.append("-tank")
      
      HP = 12
      abilities.append(Abilities.ShieldUp)
    case .dps:
      box = SCNBox(width: cellSize * 0.4, height: cellSize * 0.9, length: cellSize * 0.4, chamferRadius: 0)
      color = SCNColor.DarkTheme.Violet.accent
      uuid.append("-dps")
      
      HP = 10
      abilities.append(Abilities.FrozenArrow)
    case .support:
      box = SCNBox(width: cellSize * 0.2, height: cellSize * 0.8, length: cellSize * 0.2, chamferRadius: 0)
      color = SCNColor.DarkTheme.Violet.minor
      uuid.append("-support")
      
      HP = 8
      
      abilities.append(Abilities.HealUp)
    }
    
    box.firstMaterial?.diffuse.contents = color
    box.firstMaterial?.isDoubleSided = true
    
    node = MaterialNode(type: .character, id: uuid)
    node.geometry = box
    
    self.role = role
    self.gameID = uuid
    
    node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
    node.physicsBody?.mass = 4
    node.physicsBody?.restitution = 0
    node.physicsBody?.categoryBitMask = BodyType.character.rawValue
    node.physicsBody?.collisionBitMask = BodyType.character.rawValue | BodyType.field.rawValue
    node.physicsBody?.contactTestBitMask = BodyType.character.rawValue
  }
}

extension Character {
  func heal(amount: Int) {
    HP += amount
    node.highlight(with: SCNColor.yellow, for: 0.6)
  }
  
  func damage(amount: Int) {
    HP -= amount
    node.highlight(with: SCNColor.red, for: 0.6)
  }
}
