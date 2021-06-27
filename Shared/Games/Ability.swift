//
//  Ability.swift
//  TBS
//
//  Created by Damir Minnegalimov on 07.05.2021.
//  Copyright © 2021 Damirka. All rights reserved.
//

import SceneKit
import SwiftUI

struct Ability {
  let name: String
  let icon: Image
  let action: ((TBSGame, Hero) -> Void)
}

struct Abilities {
  struct TBS {
    // Extenstion for TBSGame Abilities
  }
}

extension Abilities.TBS {
  
  static let all = [
    Abilities.TBS.ShieldUp,
    Abilities.TBS.FrozenArrow,
    Abilities.TBS.HealUp,
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
    
    withAnimation {
      game.switchTeam()
    }
  })
  
  static let FrozenArrow = Ability(
    name: "Frozen Arrow",
    icon: Image(systemName: "thermometer.snowflake"),
    action: { game, hero in
    
    print("Run action for Frozen Array ability")
    
    var game = game
    
    game.onHeroPress = { game, hero in
      var game = game
      
      guard let hostCharacter = game.currentHero else {
        print("Can't fire Frozen Arrow action because there is no currentHero")
        game.onHeroPress = TBSGame.defaultOnHeroPress
        return
      }
      
      if let teamMate = game.currentTeam?.heroes.first(where: { $0 == hero }) {
        // Pressed hero is Teammate
        print("Frozen Arrow on teammate: \(teamMate.gameID)!")
        return
      }
      
      // Add debug line showing direction
      game.scene.rootNode.addDebugLine(
        from: hostCharacter.node.worldPosition,
        to: hero.node.worldPosition)
      
      let materialNodes = hitscan(
        from: hostCharacter.node.worldPosition,
        to: hero.node.worldPosition,
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
        
        if body.type == .hero {
          let damage = 2
          let damagePopUpNode = body.addPopup(with: "\(damage)", color: .red)
          
          damagePopUpNode.runAction(
            SCNAction.sequence([
              SCNAction.moveBy(x: 0, y: 0.6, z: 0, duration: 3),
              SCNAction.removeFromParentNode()
            ]))
          
          var hero = hero
          hero.damage(amount: damage)
        }
      }
      
      game.onFieldPress = TBSGame.defaultOnFieldPress
      game.onHeroPress = TBSGame.defaultOnHeroPress
      
      withAnimation {
        game.switchTeam()
      }
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
      game.onHeroPress = TBSGame.defaultOnHeroPress
      
      withAnimation {
        game.switchTeam()
      }
    }
  })
}
