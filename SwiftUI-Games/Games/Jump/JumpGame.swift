//
//  JumpGame.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 04.08.2022.
//

import SceneKit
import SwiftUI

fileprivate let GRAVITY: Float = 20
fileprivate let JUMP_FORCE: Float = 25
fileprivate let CAMERA_FOV: CGFloat = 40
fileprivate let FIELD_SIZE: Int = 5
fileprivate let CELL_SIZE: CGFloat = 5
fileprivate let CAMERA_HEIGHT: Float = 30

class JumpGame: Game, ObservableObject {
  let name: String
  let description: String
  let iconName = "chevron.up"
  
  var scene: SCNScene = SCNScene()
  let contactDelegate = ContactDelegate()
  
  @Published var score: Int = 0
  var hero: Hero
  var currentField: Field
  var platforms: [SCNNode] = []
  
  private let cameraNode: SCNNode = SCNNode()
  private var lastOffset: Double = 0
  
  init(
    name: String,
    description: String
  ) {
    self.name = name
    self.description = description
    
    scene.physicsWorld.gravity = SCNVector3(0, -GRAVITY, 0)
    scene.background.contents = Color.DarkTheme.Violet.background.cgColor
    
    // Keep it odd
    currentField = Field(size: FIELD_SIZE, cellSize: CELL_SIZE)
    currentField.node.eulerAngles = SCNVector3(Double.pi / 2, 0, Double.pi / 2)
    scene.rootNode.addChildNode(currentField.node)
    
    hero = Heroes.Eric()
    scene.rootNode.addChildNode(hero.node)
    
    scene.physicsWorld.contactDelegate = contactDelegate
    contactDelegate.onBegin = onContactBegin(contact:)
    
    // Set backround for Scene
    scene.background.contents = Color.DarkTheme.Violet.background.cgColor
    
    prepareCamera()
    preparePlayers()
    fill(field: currentField)
  }
  
  func onEachFrame() {
    let heroPosition = hero.node.presentation.position
    
    // Move camera with the player
    let cameraOffset = SCNVector3(0, CAMERA_HEIGHT, CAMERA_HEIGHT)
    cameraNode.position = heroPosition + cameraOffset
    cameraNode.look(at: heroPosition)
    
    // Change FOV with speed
    if let velocity = hero.node.physicsBody?.velocity {
      SCNTransaction.begin()
      SCNTransaction.animationDuration = 1
      
      let newFOV = CAMERA_FOV + CGFloat(velocity.y)
      cameraNode.camera?.fieldOfView = newFOV
            
      SCNTransaction.commit()
    }
    
    // Check record height
    changeScore(value: Int(hero.node.presentation.worldPosition.y))
        
    // Add next part after user half way to the end
    if hero.node.presentation.worldPosition.y > currentField.centerCell().node.presentation.worldPosition.y {
      let newField = addField(above: currentField)
      fill(field: newField)
      currentField = newField
    }

  }
  
  // MARK: - Control

  func onControlChange(newValue: Double) {
    // You want do this, but it doesn't work. IDK why
    // hero.node.physicsBody?.velocity.x = Float(newValue)
    
    hero.node.physicsBody?.applyForce(SCNVector3(newValue / 3 - lastOffset, 0, 0), asImpulse: true)
    
    lastOffset = newValue / 3
  }
  
  func onControlEnd() {
    lastOffset = 0
  }

}

// MARK: - Preparing

private extension JumpGame {
    
  func prepareCamera() {
    // Setup camera
    cameraNode.name = "CameraHuyamera"
    cameraNode.camera = SCNCamera()
    cameraNode.eulerAngles = SCNVector3(Float.pi / -3, 0, 0)
    cameraNode.camera?.fieldOfView = CAMERA_FOV
    cameraNode.camera?.automaticallyAdjustsZRange = true

    scene.rootNode.addChildNode(cameraNode)
  }
  
  func preparePlayers() {
    let fieldCellForHero = currentField.fieldCell(in: currentField.size / 2, column: 1)!
    
    hero.node.position = fieldCellForHero.node.worldPosition + SCNVector3(x: 0, y: 0, z: 3)
//    hero.node.pulse(from: 1, to: 1.2, duration: 0.5)
    
    hero.node.physicsBody?.applyForce(SCNVector3(x: 0, y: JUMP_FORCE * 2, z: 0), asImpulse: true)
  }
  
}

// MARK: - SCNPhysicsContact

private extension JumpGame {
  
  func onContactBegin(contact: SCNPhysicsContact) {
    let nodeA = contact.nodeA
    let nodeB = contact.nodeB
        
    let heroNode = hero.node
    
    if let velocity = heroNode.physicsBody?.velocity, velocity.y > 0 {
      // We want to collide only when hero is falling
      
      return
    }
    
    // Punish gamer if enemy touched Heroes
    if platforms.contains(nodeA) && heroNode.contains(nodeB) {
      changeScore(value: -1)
      
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
          
      nodeB.physicsBody?.velocity.y = JUMP_FORCE

      return
    }
    
    if platforms.contains(nodeB) && heroNode.contains(nodeA) {
      changeScore(value: -1)
      
      UIImpactFeedbackGenerator(style: .light).impactOccurred()

      nodeA.physicsBody?.velocity.y = JUMP_FORCE

      return
    }
    
  }
  
}

// MARK: - Level generation

private extension JumpGame {
  
  func addField(above field: Field) -> Field {
    print("Adding new field above \(field.node.name ?? "<NIL>")")
    
    let newField = Field(size: FIELD_SIZE, cellSize: CELL_SIZE)
    
    newField.node.eulerAngles = SCNVector3(Double.pi / 2, 0, Double.pi / 2)
    newField.node.worldPosition.y = field.node.boundingBox.max.z + field.node.presentation.worldPosition.y

    scene.rootNode.addChildNode(newField.node)
    return newField
  }
  
  func fill(field: Field) {
    (field.size * field.size / 4).times {
      let newPlatform = regularCubeNode(.lightGrayFancy)
      newPlatform.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
      newPlatform.physicsBody?.categoryBitMask = EntityType.platform.rawValue
      newPlatform.physicsBody?.contactTestBitMask = EntityType.platform.rawValue

      field.put(object: newPlatform, to: field.cells.randomElement()!)
      platforms.append(newPlatform)
    }
  }
  
}

// MARK: - Scoring

private extension JumpGame {
  
  func changeScore(value: Int) {
    if value < score {
      return
    }
    
    DispatchQueue.main.async {
      self.score = value
    }
  }
  
}
