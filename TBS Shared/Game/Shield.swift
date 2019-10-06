//
//  Shield.swift
//  TBS
//
//  Created by Damik Minnegalimov on 03.10.2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import SceneKit

enum ShieldType {
    case absorber
    case regular
}

enum ShieldForm {
    case cube
    case sphere
    case rect
    case circle
}

class Shield {
    let node: MaterialNode!
    var type: ShieldType
    var form: ShieldForm
    var gameID: String!
    
    init(type: ShieldType = .regular, form: ShieldForm = .sphere) {
        self.type = type
        self.form = form
        
        let geometry: SCNGeometry
        let color: SCNColor
        let cellSize: CGFloat = FieldConstants.defaultCellSize
        var uuid = UUID().uuidString
        
        switch form {
            case .circle:
                geometry = SCNCylinder(radius: cellSize / 2, height: 0.1)
                uuid.append("-circle")
            
            case .cube:
                geometry = SCNBox(width: cellSize, height: cellSize, length: cellSize, chamferRadius: 0)
                uuid.append("-cube")
            
            case .rect:
                geometry = SCNPlane(width: cellSize, height: cellSize)
                uuid.append("-rect")
            
            case .sphere:
                geometry = SCNSphere(radius: cellSize * 1.15 / 2)
                uuid.append("-sphere")
        }
        
        switch type {
            case .regular:
                color = SCNColor.DarkTheme.Violet.minor
                uuid.append("-regular")
            case .absorber:
                color = SCNColor.DarkTheme.Violet.accent
                uuid.append("-absorber")
        }
        
        gameID = uuid.appending("-shield")
        
        geometry.firstMaterial?.diffuse.contents = color.withAlphaComponent(0.4)
        
        node = MaterialNode(type: .shield, id: uuid)
        node.geometry = geometry
        
        node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        node.physicsBody?.restitution = 0
        node.physicsBody?.categoryBitMask = BodyType.shield.rawValue
        node.physicsBody?.collisionBitMask = BodyType.projectile.rawValue
        node.physicsBody?.contactTestBitMask = BodyType.shield.rawValue
    }
}
