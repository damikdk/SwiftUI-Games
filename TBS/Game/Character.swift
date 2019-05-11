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

let defaultAbilityAction: ((GameVC, Character) -> Void) = { gameVC, charater in print("defaultAbilityAction") }

struct Ability {
    let name: String!
    let icon: UIImage!
    let action: ((GameVC, Character) -> Void)!
}

class Character {
    var HP: Int! = 10 {
        didSet {
            if (HP <= 0) {
                print("Character \(gameID!) died")
                highlight(node: node)
            }
        }
    }
    
    let node: MaterialNode!
    let role: CharacterRole!
    var gameID: String!
    var abilities = [Ability]()

    init(role: CharacterRole) {
        let box: SCNBox
        let color: UIColor
        let cellSize: CGFloat = CGFloat(FieldConstants.defaultCellSize)
        var uuid = UUID().uuidString
        
        switch role {
        case .tank:
            box = SCNBox(width: cellSize * 0.6, height: cellSize * 1.2, length: cellSize * 0.4, chamferRadius: 0)
            color = UIColor.DarkTheme.Violet.primary
            uuid.append("-tank")
            
            HP = 12
            abilities.append(Ability(name: "Shield",
                                     icon: UIImage(named: "bolt-shield"),
                                     action: defaultAbilityAction))
        case .dps:
            box = SCNBox(width: cellSize * 0.4, height: cellSize * 1, length: cellSize * 0.4, chamferRadius: 0)
            color = UIColor.DarkTheme.Violet.accent
            uuid.append("-dps")
            
            HP = 10
            abilities.append(Ability(name: "Frozen Array",
                                     icon: UIImage(named: "frozen-arrow"),
                                     action: { gameVC, charater in
                                        gameVC.onCharacterPress = { gameVC, charater in
                                            charater.HP -= 2
                                            gameVC.onCharacterPress = defaultOnCharacterPress
                                        }
                                    }))
        case .support:
            box = SCNBox(width: cellSize * 0.2, height: cellSize * 0.8, length: cellSize * 0.2, chamferRadius: 0)
            color = UIColor.DarkTheme.Violet.minor
            uuid.append("-support")
            
            HP = 8
            abilities.append(Ability(name: "Heal AOE",
                                     icon: UIImage(named: "christ-power"),
                                     action: defaultAbilityAction))
        }
        
        box.firstMaterial?.diffuse.contents = color
        box.firstMaterial?.isDoubleSided = true
        
        node = MaterialNode(type: .material, id: uuid)
        node.geometry = box

        self.role = role
        self.gameID = uuid
        
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.mass = 4
        node.physicsBody?.restitution = 0
        node.physicsBody?.categoryBitMask = BodyType.material.rawValue
        node.physicsBody?.collisionBitMask = BodyType.material.rawValue | BodyType.field.rawValue
        node.physicsBody?.contactTestBitMask = BodyType.material.rawValue
    }
}
