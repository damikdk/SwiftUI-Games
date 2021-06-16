//
//  Shield.swift
//  TBS
//
//  Created by Damik Minnegalimov on 03.10.2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import SceneKit
import SwiftUI

enum ShieldType {
  case absorber
  case regular
}

enum ShieldForm {
  case cube
  case sphere
  case rect
  case circle
}

class Shield: Entity {
  var gameID: String
  
  var node: MaterialNode
    
  var type: ShieldType
  var form: ShieldForm
  var host: Hero?
  
  init(
    type: ShieldType = .regular,
    form: ShieldForm = .sphere,
    for host: Hero?
  ) {
    self.type = type
    self.form = form
    
    let geometry: SCNGeometry
    let color: Color
    let cellSize: CGFloat = FieldConstants.defaultCellSize
    var uuid = UUID.short()

    switch form {
    case .circle:
      geometry = SCNCylinder(radius: cellSize / 2, height: cellSize)
      uuid.append("-circle")
      
    case .cube:
      geometry = SCNBox(width: cellSize, height: cellSize, length: cellSize, chamferRadius: 0)
      uuid.append("-cube")
      
    case .rect:
      geometry = SCNPlane(width: cellSize, height: cellSize)
      uuid.append("-rect")
      
    case .sphere:
      geometry = SCNSphere(radius: cellSize * 1.15 / 2)
      uuid.append("-sphere")
    }
    
    switch type {
    case .regular:
      color = Color.DarkTheme.Violet.minor
      uuid.append("-regular")
    case .absorber:
      color = Color.DarkTheme.Violet.accent
      uuid.append("-absorber")
    }
    
    gameID = uuid.appending("-shield")
    self.host = host

    geometry.firstMaterial?.diffuse.contents = color.opacity(0.4).cgColor
    
    node = MaterialNode(type: .shield, id: uuid)
    node.geometry = geometry
    node.host = host

    node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
    node.physicsBody?.restitution = 0
    node.physicsBody?.categoryBitMask = EntityType.shield.rawValue
    // node.physicsBody?.collisionBitMask = BodyType.projectile.rawValue
    node.physicsBody?.contactTestBitMask = EntityType.shield.rawValue
  }
}
