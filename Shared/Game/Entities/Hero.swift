//
//  Hero.swift
//  TBS3 (iOS)
//
//  Created by Damir Minnegalimov on 11.06.2021.
//

import SwiftUI
import SceneKit

struct Hero: Entity {
  var gameID: String
  
  var node: MaterialNode
    
  let name: String
  
  var HP: Int = 10
    
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

//static let Heroes = [
//  
//]
//
//let Lexa = Hero(
//  gameID: "hero-Lexa",
//  node: <#T##MaterialNode#>,
//  name: "Lexa")
//
