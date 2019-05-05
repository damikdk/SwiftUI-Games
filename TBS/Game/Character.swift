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

class Character {
    let node: MaterialNode!
    let role: CharacterRole!
    var gameID: String!

    init(role: CharacterRole) {
        let box: SCNBox
        let color: UIColor
        let cellSize: CGFloat = 10
        var uuid = UUID().uuidString
        
        switch role {
        case .tank:
            box = SCNBox(width: cellSize * 0.8, height: cellSize * 2, length: cellSize * 0.4, chamferRadius: 0)
            color = .blue
            uuid.append("-tank")
        case .dps:
            box = SCNBox(width: cellSize * 0.4, height: cellSize * 1, length: cellSize * 0.4, chamferRadius: 0)
            color = .red
            uuid.append("-dps")
        case .support:
            box = SCNBox(width: cellSize * 0.2, height: cellSize * 0.8, length: cellSize * 0.2, chamferRadius: 0)
            color = .yellow
            uuid.append("-support")
        }
        
        box.firstMaterial?.diffuse.contents = color
        box.firstMaterial?.isDoubleSided = true
        
        node = MaterialNode(type: .material, id: uuid)
        node.geometry = box

        self.role = role
        self.gameID = uuid
        
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.categoryBitMask = BodyType.material.rawValue
        node.physicsBody?.collisionBitMask = BodyType.field.rawValue
        node.physicsBody?.contactTestBitMask = BodyType.field.rawValue
    }
}
