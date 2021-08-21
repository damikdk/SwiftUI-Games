//
//  DarkGame.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 09.08.2021.
//

import SceneKit
import SwiftUI

class DarkGame: Game, ObservableObject {
  let name: String
  let description: String
  let iconName = "moon.stars"

  var field: Field
  var scene: SCNScene = SCNScene()
  let contactDelegate = ContactDelegate()

  private let cameraNode: SCNNode = SCNNode()
  private let cameraHeight: Float = 6
  private let lightOffset = SCNVector3(0, 5, 0)

  var hero: Hero!
  var enemies: [Hero] = []
  var lightNode: SCNNode?
  let heroSpeed: Float = 5

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

    preparePlayers()
    prepareLight()
    prepareCamera()
    prepareDebugStuff()

    addEnemies()
  }

  func handleRightPad(xAxis: Float, yAxis: Float) {
    if xAxis == yAxis, xAxis == 0 {
      hero.node.physicsBody?.angularVelocity = SCNVector4()
      hero.node.physicsBody?.velocity = SCNVector3()
      hero.node.physicsBody?.mass = 0

      return
    }

    let velocity = SCNVector3(xAxis, 0, -yAxis) * heroSpeed
    hero.node.physicsBody?.velocity = velocity
    hero.node.physicsBody?.mass = 1
  }

  func onEachFrame() {

    let heroPosition = hero.node.presentation.position

    // Move camera to the player
    let cameraOffset = SCNVector3(0, cameraHeight, cameraHeight)
    cameraNode.position = heroPosition + cameraOffset
    cameraNode.look(at: heroPosition)

    // Make enemies closer
    for enemy in enemies {
      if enemy.node.parent == nil { continue }

      // The further the hero is, the faster the enemy moves in his direction
      let vectorBetween = heroPosition - enemy.node.presentation.position
      enemy.node.physicsBody?.velocity = vectorBetween * 0.5
    }

    // Keep light close to player
    // (it's strange way to do it, but I want the node to move smoothly to the hero.
    // I preferr to just add velocity to light node, but LightNode doesn't have physicsBody)
    let moveAction = SCNAction.move(to: heroPosition + lightOffset, duration: 0.2)
    moveAction.timingMode = .easeInEaseOut
    lightNode?.runAction(moveAction)

    lightNode?.look(at: heroPosition)
  }

}


// MARK: - Preparing

private extension DarkGame {

  func preparePlayers() {
    hero = Heroes.Eric()

    let fieldCellForFirstHero = field.fieldCell(in: 45, column: 24)!
    field.put(object: hero.node, to: fieldCellForFirstHero)
  }

  func prepareLight() {
    lightNode = defaultLightNode(mode: .spot)
    lightNode?.position = hero.node.position + lightOffset
    lightNode?.look(at: hero.node.position)

    scene.rootNode.addChildNode(lightNode!)
  }

  func prepareCamera() {
    // Setup camera
    cameraNode.name = "CameraHuyamera"
    cameraNode.camera = SCNCamera()
    cameraNode.eulerAngles = SCNVector3(Float.pi / -3, 0, 0)
    cameraNode.camera?.fieldOfView = 90

    scene.rootNode.addChildNode(cameraNode)
  }

  func prepareDebugStuff() {
    // Debug sphere in the center of the Field
    let sphereGeometry = SCNSphere(radius: 0.1)

    // Color for light
    sphereGeometry.firstMaterial?.diffuse.contents = Color.white.cgColor

    // Color if we ignores light
    sphereGeometry.firstMaterial?.emission.contents = Color.white.cgColor

    let sphereNode = SCNNode(geometry: sphereGeometry)
    sphereNode.position = SCNVector3(0, 0, -1)

    lightNode?.addChildNode(sphereNode)
  }

}


// MARK: - Enemies

private extension DarkGame {

  func addEnemies() {
    let newEnemies = [Heroes.Eric(), Heroes.Eric(), Heroes.Eric(), Heroes.Eric(), Heroes.Eric()]

    for enemy in newEnemies {
      field.put(object: enemy.node, to: field.cells.randomElement()!)
    }

    enemies.append(contentsOf: newEnemies)
  }

}


// MARK: - SCNPhysicsContact

private extension DarkGame {

  func onContactBegin(contact: SCNPhysicsContact) {
    let nodeA = contact.nodeA
    let nodeB = contact.nodeB

    let enemyNodes = enemies.map { hero in
      return hero.node as SCNNode
    }

    // Ignore enemy balls collisions
    if enemyNodes.contains(nodeA) &&
        enemyNodes.contains(nodeB) {
      return
    }

    // Game over if enemy touched Heroes
    if enemyNodes.contains(nodeA) && hero.node === nodeB {
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()

      nodeB.highlight(with: .red, for: 2)
      return
    }

    if enemyNodes.contains(nodeB) && hero.node === nodeA {
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()

      nodeA.highlight(with: .red, for: 2)
      return
    }
  }

}
