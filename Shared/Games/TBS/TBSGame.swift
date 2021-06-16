//
//  Game.swift
//  TBS2 (iOS)
//
//  Created by Damir Minnegalimov on 04.06.2021.
//

import SceneKit

class TBSGame: Game, ObservableObject {
  let name: String
  let description: String

  var scene: SCNScene = SCNScene()
  var field: Field
  var entities: [Entity]?
  
  init(
    name: String,
    description: String,
    field: Field,
    entities: [Entity]? = []
  ) {
    self.name = name
    self.description = description
    self.field = field
    self.entities = entities
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
  }
  
  func findEntity(by gameID: String) -> Entity? {
    return entities?.first(where: { entity in
      return entity.gameID == gameID
    })
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

let tbsGames: [Game] = [
  TBSGame(
    name: "Default",
    description: "7x7 field with default set of Heroes",
    field: Field(size: 7)),
  
  TBSGame(
    name: "Small field",
    description: "3x3 field with a couple of Heroes",
    field: Field(size: 3)),
  
  TBSGame(
    name: "Big field",
    description: "\(FieldConstants.maxFieldSize)x\(FieldConstants.maxFieldSize) field with random set of Heroes",
    field: Field(size: FieldConstants.maxFieldSize)),
  
  TBSGame(
    name: "Random",
    description: "Random field size (3x3 to \(FieldConstants.maxFieldSize)x\(FieldConstants.maxFieldSize)) with random set of Heroes",
    field: Field(size: Int.random(in: 3..<FieldConstants.maxFieldSize))),
]
