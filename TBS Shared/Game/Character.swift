//
//  Character.swift
//  TBS
//
//  Created by Damik Minnegalimov on 18/02/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import Foundation
import SceneKit

enum CharacterRole: Int {
    case tank = 1
    case support = 2
    case dps = 3
}

let defaultAbilityAction: ((Game, Character) -> Void) = { gameVC, charater in print("defaultAbilityAction") }

struct Ability {
    let name: String!
    let icon: SCNImage!
    let action: ((Game, Character) -> Void)!
}

class Character {
    var HP: Int! = 10 {
        didSet {
            if (HP <= 0) {
                print("Character \(gameID!) died")
                node.highlight()
            }
        }
    }
    
    let node: MaterialNode!
    let role: CharacterRole!
    var gameID: String!
    var abilities = [Ability]()
    
    init(role: CharacterRole) {
        let box: SCNBox
        let color: SCNColor
        let cellSize: CGFloat = FieldConstants.defaultCellSize
        var uuid = UUID().uuidString
        
        switch role {
            case .tank:
                box = SCNBox(width: cellSize * 0.4, height: cellSize, length: cellSize * 0.4, chamferRadius: 0)
                color = SCNColor.DarkTheme.Violet.primary
                uuid.append("-tank")
                
                HP = 12
                abilities.append(Ability(name: "Shield",
                                         icon: SCNImage(named: "bolt-shield"),
                                         action: { game, charater in
                                            print("Run action for Shield ability")
                                            
                                            let newShield = Shield(type: .regular, form: .sphere)
                                            charater.node.addChildNode(newShield.node)

                }))
            case .dps:
                box = SCNBox(width: cellSize * 0.4, height: cellSize * 0.9, length: cellSize * 0.4, chamferRadius: 0)
                color = SCNColor.DarkTheme.Violet.accent
                uuid.append("-dps")
                
                HP = 10
                abilities.append(Ability(name: "Frozen Array",
                                         icon: SCNImage(named: "frozen-arrow"),
                                         action: { game, charater in
                                            print("Run action for Frozen Array ability")
                                            
                                            game.onCharacterPress = { game, charater in
                                                charater.damage(amount: 2)
                                                game.onCharacterPress = defaultOnCharacterPress
                                            }
                }))
            case .support:
                box = SCNBox(width: cellSize * 0.2, height: cellSize * 0.8, length: cellSize * 0.2, chamferRadius: 0)
                color = SCNColor.DarkTheme.Violet.minor
                uuid.append("-support")
                
                HP = 8
                abilities.append(Ability(name: "Heal",
                                         icon: SCNImage(named: "christ-power"),
                                         action: { game, charater in
                                            print("Run action for Heal ability")

                                            game.onCharacterPress = { game, charater in
                                                charater.heal(amount: 2)
                                                game.onCharacterPress = defaultOnCharacterPress
                                            }
                }))
        }
        
        box.firstMaterial?.diffuse.contents = color
        box.firstMaterial?.isDoubleSided = true
        
        node = MaterialNode(type: .character, id: uuid)
        node.geometry = box
        
        self.role = role
        self.gameID = uuid
        
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.mass = 4
        node.physicsBody?.restitution = 0
        node.physicsBody?.categoryBitMask = BodyType.character.rawValue
        node.physicsBody?.collisionBitMask = BodyType.character.rawValue | BodyType.field.rawValue
        node.physicsBody?.contactTestBitMask = BodyType.character.rawValue
    }
}

extension Character {
    func heal(amount: Int) {
        HP += amount
    }
    
    func damage(amount: Int) {
        HP -= amount
    }
}
