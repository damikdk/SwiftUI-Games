//
//  JumpGame.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 04.08.2022.
//

import SceneKit
import SwiftUI

class JumpGame: Game, ObservableObject {
  let name: String
  let description: String
  let iconName = "chevron.up"
  
  var scene: SCNScene = SCNScene()
  let contactDelegate = ContactDelegate()
  
  @Published var score: Int = 0
  var hero: Hero
  var field: Field
  var platforms: [SCNNode] = []

  private let cameraNode: SCNNode = SCNNode()
  private let cameraHeight: Float = 35

  init(
    name: String,
    description: String
  ) {
    self.name = name
    self.description = description
    
    scene.background.contents = Color.DarkTheme.Violet.background.cgColor
    
    field = Field(size: 50, cellSize: 3)
    field.node.eulerAngles = SCNVector3(Double.pi / 2, 0, Double.pi / 2)
    scene.rootNode.addChildNode(field.node)
    

    hero = Heroes.Eric()
    scene.rootNode.addChildNode(hero.node)

    scene.physicsWorld.contactDelegate = contactDelegate
    contactDelegate.onBegin = onContactBegin(contact:)
    
    // Set backround for Scene
    scene.background.contents = Color.DarkTheme.Violet.background.cgColor
    
    prepareCamera()
    preparePlayers()
    fillField()
  }
  
  func onEachFrame() {
    
    let heroPosition = hero.node.presentation.position
    
    // Move camera to the player
    let cameraOffset = SCNVector3(0, cameraHeight, cameraHeight)
    cameraNode.position = heroPosition + cameraOffset
    cameraNode.look(at: heroPosition)
    
    changeScore(value: Int(hero.node.presentation.worldPosition.y))
  }

}

// MARK: - Preparing

private extension JumpGame {
    
  func prepareCamera() {
    // Setup camera
    cameraNode.name = "CameraHuyamera"
    cameraNode.camera = SCNCamera()
    cameraNode.eulerAngles = SCNVector3(Float.pi / -3, 0, 0)
    cameraNode.camera?.fieldOfView = 50
    cameraNode.camera?.automaticallyAdjustsZRange = true

    scene.rootNode.addChildNode(cameraNode)
  }
  
  func preparePlayers() {
    let fieldCellForHero = field.fieldCell(in: field.size / 2, column: 1)!
    
    hero.node.position = fieldCellForHero.node.worldPosition + SCNVector3(x: 0, y: 0, z: 3)
    hero.node.pulse(from: 1, to: 1.2, duration: 0.5)
    
    hero.node.physicsBody?.velocity = SCNVector3(x: 0, y: 20, z: 0)
  }
  
}

// MARK: - SCNPhysicsContact

private extension JumpGame {
  
  func onContactBegin(contact: SCNPhysicsContact) {
    let nodeA = contact.nodeA
    let nodeB = contact.nodeB
        
    let heroNode = hero.node
    
    // Punish gamer if enemy touched Heroes
    if platforms.contains(nodeA) && heroNode.contains(nodeB) {
      changeScore(value: -1)
      
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
      
      nodeB.highlight(with: .red, for: 2)
      
      nodeB.physicsBody?.velocity = SCNVector3(x: 0, y: 20, z: 0)

      return
    }
    
    if platforms.contains(nodeB) && heroNode.contains(nodeA) {
      changeScore(value: -1)
      
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
      
      nodeA.highlight(with: .red, for: 2)
      
      nodeA.physicsBody?.velocity = SCNVector3(x: 0, y: 20, z: 0)
      
      return
    }
  }
  
}

// MARK: - Level generation

private extension JumpGame {
  
  func addField() {
    field = Field(size: 10, cellSize: 3)
    field.node.eulerAngles = SCNVector3(0, Double.pi / 2, 0)
    
    fillField()
    
    scene.rootNode.addChildNode(field.node)
  }
  
  func fillField() {
    (field.size * field.size / 3).times {
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
