//
//  TogetherGame.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 27.06.2021.
//

import SceneKit
import SwiftUI
import GameController

class TogetherGame: Game, ObservableObject {
  let name: String
  let description: String
  let iconName = "circlebadge.2"

  var field: Field
  var scene: SCNScene = SCNScene()
  var enemies: [Hero] = []

  let contactDelegate = ContactDelegate()

  var firstHero: Hero!
  var secondHero: Hero!
  let speed: Float = 20
  
  @Published var score: Int = 0

  private let cameraNode: SCNNode = SCNNode()
  private let cameraHeight: Float = 40

  init(
    name: String,
    description: String,
    field: Field
  ) {
    self.name = name
    self.description = description
    self.field = field

    // Add Field node
    scene.rootNode.addChildNode(field.node)

    scene.physicsWorld.contactDelegate = contactDelegate
    contactDelegate.onBegin = onContactBegin(contact:)

    // Set backround for Scene
    scene.background.contents = Color.DarkTheme.Violet.background.cgColor

    prepareCamera()
    // prepareLight()
    preparePlayers()
    addEnemies()
  }

  func handleLeftPad(xAxis: Float, yAxis: Float) {
    if xAxis == yAxis, xAxis == 0 {
      firstHero.node.physicsBody?.angularVelocity = SCNVector4()
      firstHero.node.physicsBody?.velocity = SCNVector3()
      firstHero.node.physicsBody?.mass = 0

      return
    }

    let velocity = SCNVector3(xAxis, 0, -yAxis) * speed
    firstHero.node.physicsBody?.velocity = velocity
    firstHero.node.physicsBody?.mass = 1
  }

  func handleRightPad(xAxis: Float, yAxis: Float) {
    if xAxis == yAxis, xAxis == 0 {
      secondHero.node.physicsBody?.angularVelocity = SCNVector4()
      secondHero.node.physicsBody?.velocity = SCNVector3()
      secondHero.node.physicsBody?.mass = 0

      return
    }

    let velocity = SCNVector3(xAxis, 0, -yAxis) * speed
    secondHero.node.physicsBody?.velocity = velocity
    secondHero.node.physicsBody?.mass = 1
  }

  func onEachFrame() {

    let firstHeroPosition = firstHero.node.presentation.position
    let secondHeroPosition = secondHero.node.presentation.position

    let lineNode = scene.rootNode.addDebugLine2(
      from: firstHeroPosition,
      to: secondHeroPosition,
      color: .lightRed,
      width: 0.1,
      time: 0.01)

    lineNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
    lineNode.physicsBody?.contactTestBitMask = EntityType.hero.rawValue

    let distanceBetweenHeroes = SCNVector3.distanceBetween(
      vector1: firstHeroPosition,
      vector2: secondHeroPosition)

    let cameraOffset = SCNVector3(
      0,
      cameraHeight + Float(distanceBetweenHeroes / 2),
      cameraHeight / 2)

    cameraNode.position = lineNode.position + cameraOffset
    cameraNode.look(at: lineNode.position)

    for enemy in enemies {
      if enemy.node.parent == nil { continue }
      
      let closestHero = closestHero(for: enemy.node)
      let vectorBetween = closestHero.node.presentation.position - enemy.node.presentation.position

      enemy.node.physicsBody?.velocity = vectorBetween
    }
  }

  // Called from SwiftUI
  // Timers needs runloop
  func onTimer() {
    if scene.isPaused {
      return
    }
    
    addEnemies()
  }
  
}

// MARK: - Preparing

private extension TogetherGame {

  func prepareLight() {
    let fieldCenter = field.center()
    let spotlight = defaultLightNode(mode: .spot)
    spotlight.position = fieldCenter + SCNVector3(0, cameraHeight, 20)
    spotlight.look(at: fieldCenter)

    scene.rootNode.addChildNode(spotlight)
    scene.rootNode.addChildNode(defaultLightNode(mode: .ambient))
  }

  func prepareCamera() {
    // Setup camera
    cameraNode.name = "CameraHuyamera"
    cameraNode.camera = SCNCamera()
    cameraNode.eulerAngles = SCNVector3(Float.pi / -3, 0, 0)
    cameraNode.camera?.fieldOfView = 40
    cameraNode.camera?.automaticallyAdjustsZRange = true

    scene.rootNode.addChildNode(cameraNode)
  }

  func preparePlayers() {
    firstHero = Heroes.Eric()

    let fieldCellForFirstHero = field.fieldCell(in: field.size - 2, column: 1)!
    field.put(object: firstHero.node, to: fieldCellForFirstHero)

    secondHero = Heroes.Eric()
    let fieldCellForSecondHero = field.fieldCell(in: field.size - 2, column: field.size - 2)!
    field.put(object: secondHero.node, to: fieldCellForSecondHero)
  }

}

// MARK: - Enemies

private extension TogetherGame {

  func addEnemies() {
    let newEnemies = [Heroes.Eric(), Heroes.Eric(), Heroes.Eric()]

    for enemy in newEnemies {
      field.put(object: enemy.node, to: field.cells.randomElement()!)
    }

    enemies.append(contentsOf: newEnemies)
  }

  func closestHero(for node: SCNNode) -> Hero {
    let distanceToFirstHero = SCNVector3.distanceBetween(
      vector1: node.presentation.position,
      vector2: firstHero.node.presentation.position)

    let distanceToSecondHero = SCNVector3.distanceBetween(
      vector1: node.presentation.position,
      vector2: secondHero.node.presentation.position)

    if distanceToFirstHero < distanceToSecondHero {
      return firstHero
    } else {
      return secondHero
    }
  }

}

// MARK: - SCNPhysicsContact

private extension TogetherGame {

  func onContactBegin(contact: SCNPhysicsContact) {
    let nodeA = contact.nodeA
    let nodeB = contact.nodeB

    let enemyNodes = enemies.map { hero in
      return hero.node as SCNNode
    }

    let heroNodes = [firstHero.node as SCNNode, secondHero.node as SCNNode]

    // Ignore enemy balls collisions
    if enemyNodes.contains(nodeA) &&
        enemyNodes.contains(nodeB) {
      return
    }
    
    // Remove enemies touched by Line
    if nodeA.name == "debug-line2" {
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
      
      DispatchQueue.main.async {
        self.score = self.score + 1
      }

      nodeB.removeFromParentNode()
      return
    }
    
    if nodeB.name == "debug-line2" {
      UIImpactFeedbackGenerator(style: .light).impactOccurred()

      DispatchQueue.main.async {
        self.score = self.score + 1
      }
      
      nodeA.removeFromParentNode()
      return
    }

    // Game over if enemy touched Heroes
    if enemyNodes.contains(nodeA) && heroNodes.contains(nodeB) {
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()

      nodeB.highlight(with: .red, for: 2)
      return
    }

    if enemyNodes.contains(nodeB) && heroNodes.contains(nodeA) {
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
      
      nodeA.highlight(with: .red, for: 2)
      return
    }
  }

}
