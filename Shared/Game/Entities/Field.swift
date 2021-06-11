//
//  Field.swift
//  TBS
//
//  Created by Damik Minnegalimov on 18/02/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import SwiftUI
import SceneKit

struct FieldConstants {
  static let indexSeparator = ","
  static let defaultPlacementExtraHeight = CGFloat(0)
  static let defaultCellSize = CGFloat(5)
  static let maxFieldSize = 15
}

class Field {
  let node: SCNNode!
  let size: Int!
  let cellSize: CGFloat!
  
  var cells: [FieldCell] = []
  
  init(size: Int = 9, cellSize: CGFloat = FieldConstants.defaultCellSize) {
    node = SCNNode()
    node.name = "Field (size: \(size))"
    
    self.size = size
    self.cellSize = cellSize
    
    for row in 0..<size {
      for column in 0..<size {
        let stringIndex = String(row) + FieldConstants.indexSeparator + String(column)
        
        let cellGeometry = SCNPlane(
          width: CGFloat(cellSize),
          height: CGFloat(cellSize))
        
        // Make the plane visible from both sides
        cellGeometry.firstMaterial?.isDoubleSided = true
        cellGeometry.firstMaterial?.diffuse.contents = Color.DarkTheme.Violet.fieldColor.cgColor
        cellGeometry.cornerRadius = FieldConstants.defaultCellSize / 40
        
        let cell = MaterialNode(type: .field, id: stringIndex)
        cell.geometry = cellGeometry
        cell.position = SCNVector3(CGFloat(column) * cellSize, 0, CGFloat(row) * cellSize)
        cell.eulerAngles = SCNVector3Make(Float.pi / 2, 0, 0)
        
        cell.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        cell.physicsBody?.categoryBitMask = EntityType.field.rawValue
        cell.physicsBody?.collisionBitMask = EntityType.hero.rawValue | EntityType.field.rawValue
        
        cells.append(FieldCell(gameID: stringIndex, node: cell))
        node.addChildNode(cell)
      }
    }
  }
  
  func center() -> SCNVector3 {
    let centerIndex = cells.count / 2
    let centerCell = cells[centerIndex]
    
    return centerCell.node.position
  }
  
  func put(object: SCNNode, to cell: FieldCell) {
    let objectHeight = object.height()
    let cellPosition = cell.node.position

    let position = SCNVector3(
      cellPosition.x,
      FieldConstants.defaultPlacementExtraHeight.float() + objectHeight.float() / 2,
      cellPosition.z)
    
    print("Put node to FieldCell \(cell.gameID)")

    object.position = position
    node.addChildNode(object)
  }
  
  func move(node: SCNNode, to cell: FieldCell) {
    let objectHeight = node.height()
    let cellPosition = cell.node.position
    
    let position = SCNVector3(
      cellPosition.x,
      FieldConstants.defaultPlacementExtraHeight.float() + objectHeight.float() / 2,
      cellPosition.z)
    
    let moveAction = SCNAction.move(to: position, duration: 0.4)
    moveAction.timingMode = .easeInEaseOut
    
    print("Move node to FieldCell \(cell.gameID)")
    node.runAction(moveAction)
  }
}

struct FieldCell: Entity {
  var gameID: String
  var node: MaterialNode
}

extension CGFloat {
  func float() -> Float {
    return Float(self)
  }
}
