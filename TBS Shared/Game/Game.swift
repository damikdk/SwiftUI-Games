//
//  GameController.swift
//  TBS Shared
//
//  Created by Damik Minnegalimov on 19/05/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import SceneKit

let defaultOnCharacterPress: ((Game, Character) -> Void) = { gameVC, character in
  gameVC.currentCharacter = character
  character.node.highlight()
}

let defaultOnFieldPress: ((Game, MaterialNode, Int, Int) -> Void) = { game, cellNode, row, column in
  game.currentField.move(
    node: game.currentCharacter!.node,
    toRow: row,
    column: column)
  cellNode.highlight()
}

class Game: NSObject, SCNSceneRendererDelegate {
  var cameraNode: SCNNode!
  var lightNode: SCNNode!
  var scene: SCNScene!
  let sceneRenderer: SCNSceneRenderer!
  var cameraHeight: CGFloat = FieldConstants.defaultCellSize * 7

  var startScale: CGFloat = 0
  var lastScale: CGFloat = 1
  var previousTranslateX: CGFloat = 0.0
  var previousTranslateZ: CGFloat = 0.0

  var overlay: OverlayHUD!
  var currentCharacter: Character? {
    didSet {
      overlay.setupUI(for: self)

      let textPopup = currentCharacter?.node.addPopup(with: "GO")

      textPopup!.runAction(
        SCNAction.sequence([
          SCNAction.moveBy(x: 0, y: 0.3, z: 0, duration: 0.4),
          SCNAction.removeFromParentNode()
        ]))
    }
  }
  var characters: [Character] = []
  var currentField: Field! {
    didSet {
      scene.rootNode.addChildNode(currentField.node)

      let fieldCenter = currentField.centerOfCell(row: (currentField.size / 2) + 2,
                                                  column: (currentField.size / 2))

      let cameraPosition = SCNVector3(x: fieldCenter.x,
                                      y: fieldCenter.y + cameraHeight.universal(),
                                      z: fieldCenter.z + cameraHeight.universal())

      let moveCamera = SCNAction.move(to: cameraPosition, duration: 0);

      cameraNode.runAction(moveCamera) {
        self.cameraNode.look(at: fieldCenter)
        self.lightNode.position = SCNVector3(x: fieldCenter.x,
                                             y: fieldCenter.y + FieldConstants.defaultCellSize.universal() * 5,
                                             z: fieldCenter.z + FieldConstants.defaultCellSize.universal() * 4)
        self.lightNode.look(at: fieldCenter)
        self.lastScale = 1 / (self.cameraNode.camera?.fieldOfView)!
      }
    }
  }

  var onCharacterPress: ((Game, Character) -> Void)!
  var onFieldPress: ((Game, MaterialNode, Int, Int) -> Void)!

  init(sceneRenderer renderer: SCNSceneRenderer) {
    sceneRenderer = renderer

    // create a new scene
    scene = SCNScene()

    super.init()

    sceneRenderer.delegate = self
    scene.physicsWorld.contactDelegate = self

    setupCamera()
    setupSceneView()
    setupOverlay()
    setupLight()

    defer {
      // set up field and characters
      currentField = Field(in: SCNVector3(), size: 7)
      createCharacters(random: false)
      onCharacterPress = defaultOnCharacterPress
      onFieldPress = defaultOnFieldPress
    }
  }

  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    // Called before each frame is rendered

    //    overlay.setupUI(for: self)
  }
}

// MARK: - Setup Game

extension Game {
  func setupCamera() {
    cameraNode = SCNNode()
    cameraNode.name = "Camera"
    cameraNode.camera = SCNCamera()
    cameraNode.eulerAngles = SCNVector3Make(Float.pi.universal() / -3, 0, 0)
    cameraNode.camera!.zFar = 200

    scene.rootNode.addChildNode(cameraNode)
  }

  func setupSceneView() {
    let scnView = sceneRenderer as! SCNView
    scnView.scene = scene
    scnView.backgroundColor = SCNColor.black

    scnView.allowsCameraControl = true
    scnView.defaultCameraController.interactionMode = .orbitTurntable
    scnView.defaultCameraController.inertiaEnabled = true
    scnView.defaultCameraController.inertiaFriction = 0.1
    scnView.defaultCameraController.maximumVerticalAngle = 80
    scnView.defaultCameraController.minimumVerticalAngle = 20
    scnView.cameraControlConfiguration.rotationSensitivity = 0.5
    //        scnView.showsStatistics = true
  }

  func setupOverlay() {
    let scnView = sceneRenderer as! SCNView
    let overlayScene = OverlayHUD(size: scnView.bounds.size)

    overlayScene.backgroundColor = SCNColor.lightBlue
    overlayScene.scaleMode = .resizeFill
    scnView.overlaySKScene = overlayScene
    overlay = overlayScene
  }

  func setupLight() {
    // create and add a light to the scene
    let light = SCNLight()
    lightNode = SCNNode()
    lightNode.name = "Light"

    light.type = .spot
    light.intensity = 1200
    light.castsShadow = true
    light.spotOuterAngle = 120
    light.shadowMode = .deferred
    light.shadowSampleCount = 32

    lightNode.light = light
    scene.rootNode.addChildNode(lightNode)
  }
}

// MARK: - Character methods

extension Game {
  func createCharacters(random: Bool) {
    if (random) {
      var squadsCount = 1

      while squadsCount > 0 {
        createCharacter(role: .dps)
        createCharacter(role: .tank)
        createCharacter(role: .support)

        squadsCount -= 1
      }

      return
    }

    for row in 1...(currentField.size - 2) {
      createCharacter(role: .tank, row: row, column: 3)
      createCharacter(role: .dps, row: row, column: 2)
      createCharacter(role: .support, row: row, column: 1)

      let rightSideColumn = currentField.size - 2

      createCharacter(role: .tank, row: row, column: rightSideColumn - 2)
      createCharacter(role: .dps, row: row, column: rightSideColumn - 1)
      createCharacter(role: .support, row: row, column: rightSideColumn)
    }
  }

  func createCharacter(role: CharacterRole, row: Int? = nil, column: Int? = nil) -> Void {
    let newCharacter = Character(role: role)

    if (row != nil && column != nil) {
      currentField.put(object: newCharacter.node, row: row!, column: column!)
    } else {
      currentField.put(object: newCharacter.node)
    }

    characters.append(newCharacter)
  }

  func findCharacter(by gameID: String!) -> Character? {
    for character in characters {
      if character.gameID == gameID {
        return character
      }
    }

    return nil
  }
}

// MARK: - Node methods

extension Game {
  func findFirstNode(atPoint point: CGPoint) -> SCNNode? {
    let hitResults = self.sceneRenderer.hitTest(point, options: [:])

    if hitResults.count == 0 {
      // check that we clicked on at least one object
      return nil
    }

    // retrieved the first clicked object
    let hitResult = hitResults[0]

    return hitResult.node
  }

  func findFirstTouchableNode(atPoint point: CGPoint) -> SCNNode? {
    let options: [SCNHitTestOption : Any] = [SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue]
    let hitResults = self.sceneRenderer.hitTest(point, options: options)

    if hitResults.count == 0 {
      // check that we clicked on at least one object
      return nil
    }

    // retrieved the first clicked object
    let hitResult = hitResults.first { $0.node.physicsBody != nil }

    return hitResult?.node
  }
}

// MARK: - Touch handlers

extension Game {
  func preview(atPoint point: CGPoint) {
    print("Preview requested for point: \(point)")

    /// Find closest node
    if let firstNode = findFirstNode(atPoint: point) {
      /// highlight it
      firstNode.highlight()
    }
  }

  func pick(atPoint point: CGPoint) {
    print("Pick requested for point: \(point)")

    // MARK: TODO: Fix touch through shields

    // Find closest node
    if let firstNode = findFirstTouchableNode(atPoint: point) {
      // Highlight it
      // firstNode.highlight()

      if let materialNode = firstNode as? MaterialNode {
        if (materialNode.type == .field && currentCharacter != nil) {
          let fieldIndexes = materialNode.gameID!
            .components(separatedBy: FieldConstants.indexSeparator)
            .map { Int($0)!}

          onFieldPress(self, materialNode, fieldIndexes[0], fieldIndexes[1])
        } else if (materialNode.type == .character) {
          if let tappedCharacter = findCharacter(by: materialNode.gameID!) {
            onCharacterPress(self, tappedCharacter)
          }

        } else if materialNode.type == .shield {
          if let host = materialNode.host {
            // If shield have a host, pick it
            onCharacterPress(self, host)
          } else {
            print("Shield without host was touched")
          }
        }
      } else {
        print("Touched node is not material:", firstNode.name ?? "<NO NAME>")
        return
      }
    }
  }
}

// MARK: - Physics

extension Game: SCNPhysicsContactDelegate {
  func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    //    print("contact")
  }
}
