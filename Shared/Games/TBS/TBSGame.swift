//
//  Game.swift
//  TBS2 (iOS)
//
//  Created by Damir Minnegalimov on 04.06.2021.
//

import SceneKit
import SwiftUI

class TBSGame: Game, ObservableObject {
  let name: String
  let description: String

  var scene: SCNScene = SCNScene()
  var field: Field
  
  private let cameraHeight: Float = 35
  
  init(
    name: String,
    description: String,
    field: Field
  ) {
    self.name = name
    self.description = description
    self.field = field
    
    prepare()
  }
  
  @Published var currentHero: Hero?
  @Published var currentFieldCell: FieldCell? {
    didSet {
      print("New currentFieldCell is \(currentFieldCell?.gameID ?? "ERROR")")
    }
  }
  
  var onHeroPress: ((TBSGame, Hero) -> Void) = defaultOnHeroPress
  var onFieldPress: ((TBSGame, FieldCell) -> Void) = defaultOnFieldPress
  
  func prepare() {
    scene.rootNode.addChildNode(field.node)
    scene.background.contents = Color.DarkTheme.Violet.background.cgColor
            
    let cameraNode = SCNNode()
    cameraNode.name = "Camera"
    cameraNode.camera = SCNCamera()
    cameraNode.eulerAngles = SCNVector3Make(Float.pi / -3, 0, 0)
    cameraNode.camera?.fieldOfView = 50
    
    let fieldCenter = field.center()
    cameraNode.position = fieldCenter + SCNVector3(0, cameraHeight, cameraHeight)
    cameraNode.look(at: fieldCenter)
    
    let centerConstraint = SCNLookAtConstraint(target: field.centerCell().node)
    cameraNode.constraints = [centerConstraint]
    
    // Debug sphere
    let sphereGeometry = SCNSphere(radius: 1)
    sphereGeometry.firstMaterial?.diffuse.contents = Color.darkRed.cgColor
    sphereGeometry.segmentCount = 20
    let sphereNode = SCNNode(geometry: sphereGeometry)
    sphereNode.position = fieldCenter

    scene.rootNode.addChildNode(sphereNode)
    scene.rootNode.addChildNode(cameraNode)
    
    // Left side heroes
    for row in 1..<(field.size - 1) {
      for column in 1..<(field.size - 1) {
        let hero = Heroes.all().randomElement()!
        let fieldCell = field.cells[row + field.size * column]
        field.put(object: hero.node, to: fieldCell)
      }
    }
  }
    
  func pick(_ materialNode: MaterialNode) {
    switch materialNode.type {
    case .field:
      let fieldCell = field.cells.first(where: { $0.gameID == materialNode.gameID })
      
      if let fieldCell = fieldCell {
        onFieldPress(self, fieldCell)
      } else {
        print("Can't find \(materialNode) in Field")
      }
      
      break;
    case .hero:
      if let hero = materialNode.host {
        onHeroPress(self, hero)
      }
      
      break;
    case .shield:
      if let host = materialNode.host {
        // If shield have a host, pick it
        onHeroPress(self, host)
      } else {
        print("Shield without host was touched")
      }
      break;
    }
  }
}

let defaultOnHeroPress: ((TBSGame, Hero) -> Void) = { game, hero in
  var game = game
  game.currentHero = hero
  hero.node.highlight()
}

let defaultOnFieldPress: ((TBSGame, FieldCell) -> Void) = { game, cell in
  var game = game
  
  cell.node.highlight()
  game.currentFieldCell = cell
  
  if let hero = game.currentHero {
    game.field.move(node: hero.node, to: cell)
  }
}
