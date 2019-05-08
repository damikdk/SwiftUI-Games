//
//  Field.swift
//  TBS
//
//  Created by Damik Minnegalimov on 18/02/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import Foundation
import SceneKit

struct FieldConstants {
    static let indexSeparator = ","
    static let defaultPlacementExtraHeight = 0
    static let defaultCellSize = Float(5)
}

class Field {
    let node: SCNNode!
    let size: Int!
    let cellSize: Float!
    
    init(in position: SCNVector3, size: Int = 9, cellSize: Float = FieldConstants.defaultCellSize) {
        node = SCNNode()
        node.position = position
        self.size = size
        self.cellSize = cellSize
        
        for row in 0..<size {
            for column in 0..<size {
                let stringIndex = String(row) + FieldConstants.indexSeparator + String(column)
                
                let cellGeometry = SCNPlane(width: CGFloat(cellSize), height: CGFloat(cellSize))
                // Make the plane visible from both sides
                cellGeometry.firstMaterial?.isDoubleSided = true
                cellGeometry.firstMaterial?.diffuse.contents = UIColor.DarkTheme.Violet.fieldColor
                cellGeometry.cornerRadius = CGFloat(FieldConstants.defaultCellSize / 10)
                
                let cell = MaterialNode(type: .field, id: stringIndex)
                cell.geometry = cellGeometry
                cell.position = SCNVector3(Float(column) * cellSize, 0, Float(row) * cellSize)
                cell.eulerAngles = SCNVector3Make(Float.pi / 2, 0, 0)
                
                cell.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
                cell.physicsBody?.categoryBitMask = BodyType.material.rawValue
                cell.physicsBody?.collisionBitMask = BodyType.material.rawValue
                cell.physicsBody?.contactTestBitMask = BodyType.material.rawValue
                
                node.addChildNode(cell)
            }
        }
    }
    
    func put(object: SCNNode, row: Int? = nil, column: Int? = nil) {
        let objectHeight = object.height()
        var cellPosition: SCNVector3
        
        if (row != nil && column != nil) {
            cellPosition = centerOfCell(row: row!, column: column!)
        } else {
            cellPosition = centerOfRandomCell()
        }

        let position = SCNVector3(cellPosition.x,
                                  Float(FieldConstants.defaultPlacementExtraHeight) + objectHeight / 2,
                                  cellPosition.z)

        print("Put node to row \(String(describing: row)) and column \(String(describing: column)) (position: \(position)")
        
        object.position = position
        node.addChildNode(object)
    }

    func move(node: SCNNode, toRow: Int? = nil, column: Int? = nil) {
        let objectHeight = node.height()
        var cellPosition: SCNVector3
        
        if (toRow != nil && column != nil) {
            cellPosition = centerOfCell(row: toRow!, column: column!)
        } else {
            cellPosition = centerOfRandomCell()
        }
        
        let position = SCNVector3(cellPosition.x,
                                  Float(FieldConstants.defaultPlacementExtraHeight) + objectHeight / 2,
                                  cellPosition.z)
        
        let moveAction = SCNAction.move(to: position, duration: 0.4)
        moveAction.timingMode = .easeInEaseOut
        
        print("Move node to row \(String(describing: toRow)) and column \(String(describing: column)) (position: \(position)")
        node.runAction(moveAction)
    }
    
    func centerOfCell(row: Int = 0, column: Int = 0) -> SCNVector3 {
        let x = cellSize * Float(column)
        let z = cellSize * Float(row)

        return SCNVector3(x, 0, z)
    }
    
    func centerOfRandomCell() -> SCNVector3 {
        let row = Int.random(in: 0 ..< size)
        let column = Int.random(in: 0 ..< size)
        
        let x = cellSize * Float(column)
        let z = cellSize * Float(row)
        
        return SCNVector3(x, 0, z)
    }
}
