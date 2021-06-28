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
  var field: Field

  var firstHero: Hero?
  var secondHero: Hero?
  let speed: Float = 10
  private let cameraHeight: Float = 40

  var scene: SCNScene = SCNScene()

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

    // Set backround for Scene
    scene.background.contents = Color.DarkTheme.Violet.background.cgColor

    prepareCamera()
    prepareLight()
    preparePlayers()
  }

  func handleLeftPad(xAxis: Float, yAxis: Float) {
    let velocity = SCNVector3(xAxis, 0, -yAxis) * speed
    firstHero?.node.physicsBody?.velocity = velocity
  }

  func handleRightPad(xAxis: Float, yAxis: Float) {
    let velocity = SCNVector3(xAxis, 0, -yAxis) * speed
    secondHero?.node.physicsBody?.velocity = velocity
  }
}

// MARK: Preparing

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
    let cameraNode = SCNNode()
    cameraNode.name = "CameraHuyamera"
    cameraNode.camera = SCNCamera()
    cameraNode.eulerAngles = SCNVector3(Float.pi / -3, 0, 0)
    cameraNode.camera?.fieldOfView = 55
    cameraNode.camera?.automaticallyAdjustsZRange = true

    // Place camera
    let fieldCenter = field.center()
    cameraNode.position = fieldCenter + SCNVector3(0, cameraHeight, cameraHeight / 2)
    cameraNode.look(at: fieldCenter)

    scene.rootNode.addChildNode(cameraNode)
  }

  func preparePlayers() {
    firstHero = Heroes.Arina()

    let fieldCellForFirstHero = field.fieldCell(in: field.size - 1, column: 1)!
    field.put(object: firstHero!.node, to: fieldCellForFirstHero)

    secondHero = Heroes.Lexa()
    let fieldCellForSecondHero = field.fieldCell(in: field.size - 1, column: field.size - 2)!
    field.put(object: secondHero!.node, to: fieldCellForSecondHero)
  }
}
