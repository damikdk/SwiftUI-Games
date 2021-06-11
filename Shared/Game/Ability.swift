//
//  Ability.swift
//  TBS
//
//  Created by Damir Minnegalimov on 07.05.2021.
//  Copyright © 2021 Damirka. All rights reserved.
//

import SceneKit
import SwiftUI

let defaultAbilityAction: ((TBSGame, Character) -> Void) = { gameVC, charater in
  print("defaultAbilityAction")
}

struct Ability {
  let name: String
  let icon: Image
  let action: ((TBSGame, Hero) -> Void)
}

struct Abilities {
  static let all = [
    Abilities.ShieldUp,
    Abilities.FrozenArrow,
    Abilities.HealUp,
  ]
  
  static let ShieldUp = Ability(
    name: "Shield",
    icon: Image(systemName: "shield"),
    action: { game, hero in
    print("Run action for Shield ability")
    
    let newShield = Shield(
      type: .regular,
      form: .sphere,
      for: hero)
    
    hero.node.addChildNode(newShield.node)
  })
  
  static let FrozenArrow = Ability(
    name: "Frozen Arrow",
    icon: Image(systemName: "arrow"),
    action: { game, charater in
    
    print("Run action for Frozen Array ability")
    
    var game = game
    
    game.onHeroPress = { game, hero in
      var game = game
      
      guard let hostCharacter = game.currentHero else {
        print("Can't fire Frozen Arrow action because there is no currentHero")
        game.onHeroPress = defaultOnHeroPress
        return
      }
      
      // Add debug line showing direction
      game.scene.rootNode.addDebugLine(
        from: hostCharacter.node.worldPosition,
        to: charater.node.worldPosition)
      
      let materialNodes = hitscan(
        from: hostCharacter.node.worldPosition,
        to: charater.node.worldPosition,
        in: game.scene,
        with: [.hero, .shield, .field])
      
      for (index, body) in materialNodes.enumerated() {
        if body == hostCharacter.node {
          // Skip host damage
          continue
        }
        
        // Uncomment if you want shields breaks hitscan
        let breakingTypes: [EntityType] = [.shield, .field]
        
        if breakingTypes.contains(body.type) {
          break
        }
        
        if body.type == .hero,
           var hero = game.findEntity(by: body.gameID) as? Hero {
          let damage = 2
          let damagePopUpNode = body.addPopup(with: "\(damage)", color: .red)
          
          damagePopUpNode.runAction(
            SCNAction.sequence([
              SCNAction.moveBy(x: 0, y: 0.6, z: 0, duration: 3),
              SCNAction.removeFromParentNode()
            ]))
          
          hero.damage(amount: damage)
        }
      }
      
      game.onFieldPress = defaultOnFieldPress
      game.onHeroPress = defaultOnHeroPress
    }
  })
  
  static let HealUp = Ability(
    name: "Heal",
    icon: Image(systemName: "cross"),
    action: { game, charater in
    
    print("Run action for Heal ability")
    var game = game
    
    game.onHeroPress = { game, hero in
      var hero = hero
      let heal = 2
      
      hero.heal(amount: heal)
      
      let healPopUpNode = hero.node.addPopup(with: "\(heal)", color: .yellow)
    
      healPopUpNode.runAction(
        SCNAction.sequence([
          SCNAction.moveBy(x: 0, y: 0.6, z: 0, duration: 3),
          SCNAction.removeFromParentNode()
        ]))
      
      var game = game
      game.onHeroPress = defaultOnHeroPress
    }
  })
}
