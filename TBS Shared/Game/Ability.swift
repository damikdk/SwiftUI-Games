//
//  Ability.swift
//  TBS
//
//  Created by Damir Minnegalimov on 07.05.2021.
//  Copyright © 2021 Damirka. All rights reserved.
//

import Foundation

let defaultAbilityAction: ((Game, Character) -> Void) = { gameVC, charater in print("defaultAbilityAction") }

struct Ability {
  let name: String!
  let icon: SCNImage!
  let action: ((Game, Character) -> Void)!
}

struct Abilities {
  static let ShieldUp = Ability(name: "Shield",
                                icon: SCNImage(named: "bolt-shield"),
                                action: { game, charater in
                                  print("Run action for Shield ability")
                                  
                                  let newShield = Shield(type: .regular, form: .sphere)
                                  charater.node.addChildNode(newShield.node)
                                })
  static let FrozenArrow = Ability(name: "Frozen Array",
                                   icon: SCNImage(named: "frozen-arrow"),
                                   action: { game, charater in
                                    print("Run action for Frozen Array ability")
                                    
                                    game.onCharacterPress = { game, charater in
                                      charater.damage(amount: 2)
                                      game.onCharacterPress = defaultOnCharacterPress
                                    }
                                   })
  
  static let HealUp = Ability(name: "Heal",
                              icon: SCNImage(named: "christ-power"),
                              action: { game, charater in
                                print("Run action for Heal ability")
                                
                                game.onCharacterPress = { game, charater in
                                  charater.heal(amount: 2)
                                  game.onCharacterPress = defaultOnCharacterPress
                                }
                              })
}
