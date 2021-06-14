//
//  Hero.swift
//  TBS3 (iOS)
//
//  Created by Damir Minnegalimov on 11.06.2021.
//

import SwiftUI
import SceneKit

struct Hero: Entity, Identifiable {
  let id = UUID()

  static func == (lhs: Hero, rhs: Hero) -> Bool {
    return lhs.gameID != rhs.gameID
  }

  var gameID: String
  
  var node: MaterialNode
    
  let name: String
  
  var HP: Int = 10
  let abilities: [Ability]
  let image: Image

  mutating func damage(amount: Int) {
    self.HP = self.HP - amount
    
    if self.HP <= 0 {
      print("DEATH of \(self)")
      
      self.node.runAction(
        SCNAction.sequence([
          SCNAction.scale(by: 0.3, duration: 1),
          SCNAction.moveBy(x: 0, y: 3, z: 0, duration: 2),
          SCNAction.fadeOpacity(to: 0, duration: 2),
          SCNAction.removeFromParentNode()
        ]))
    }
  }
  
  mutating func heal(amount: Int) {
    self.HP = self.HP + amount
  }
}

struct Heroes {
  static let all = [
    Heroes.Muhammad(),
    Heroes.Lexa(),
    Heroes.Arina(),
    Heroes.Sofia()
  ]

  static let Muhammad = { () -> Hero in
    var uuid = UUID.short() + "-Hero-Muhammad"

    let hero = Hero(
      gameID: uuid,
      node: regularCubeNode(),
      name: "Muhammad",
      abilities: [Abilities.HealUp],
      image: Image(systemName: "hand.point.up"))

    return hero
  }

  static let Lexa = { () -> Hero in
    var uuid = UUID.short() + "-Hero-Lexa"

    let hero = Hero(
      gameID: uuid,
      node: bigCubeNode(),
      name: "Lexa",
      abilities: [Abilities.ShieldUp],
      image: Image(systemName: "person"))

    return hero
  }

  static let Arina = { () -> Hero in
    var uuid = UUID.short() + "-Hero-Arina"

    let hero = Hero(
      gameID: uuid,
      node: smallCubeNode(),
      name: "Arina",
      abilities: [Abilities.HealUp],
      image: Image(systemName: "person.3"))

    return hero
  }

  static let Sofia = { () -> Hero in
    var uuid = UUID.short() + "-Hero-Sofia"

    let hero = Hero(
      gameID: uuid,
      node: regularCubeNode(),
      name: "Sofia",
      abilities: [Abilities.FrozenArrow],
      image: Image(systemName: "snow"))

    return hero
  }
}

