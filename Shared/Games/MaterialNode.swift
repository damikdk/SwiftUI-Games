//
//  SCNNode.swift
//  TBS
//
//  Created by Damik Minnegalimov on 30/04/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import SwiftUI
import SceneKit

class MaterialNode: SCNNode {
  var type: EntityType
  var gameID: String!
  var host: Hero?
  
  init(type: EntityType, id: String? = nil) {
    self.type = type
    
    if (id != nil) {
      self.gameID = id
    }
    
    super.init()
    name = "Material Node (\(type), \(gameID ?? ""))"
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension SCNNode {
  func highlight(
    with color: Color = Color.lightGrayFancy,
    for seconds: Double = 0.4
  ) {
    let material = geometry!.firstMaterial!
    
    SCNTransaction.begin()
    SCNTransaction.animationDuration = seconds
    
    // on completion - unhighlight
    SCNTransaction.completionBlock = {
      SCNTransaction.begin()
      SCNTransaction.animationDuration = seconds
      
      material.emission.contents = Color.clear.cgColor
      SCNTransaction.commit()
    }
    
    material.emission.contents = color.cgColor
    SCNTransaction.commit()
  }
  
  func height() -> CGFloat {
    return CGFloat(self.boundingBox.max.y - self.boundingBox.min.y)
  }
}

let bigCubeNode = { (color: Color) -> MaterialNode in
  var box = SCNBox()
  let cellSize: CGFloat = FieldConstants.defaultCellSize
  var uuid = UUID.short()
  
  box = SCNBox(
    width: cellSize * 0.4,
    height: cellSize,
    length: cellSize * 0.4,
    chamferRadius: 0)
  uuid.append("-big")
  
  for material in box.materials {
    material.diffuse.contents = color.cgColor
    //material.emission.contents = color.cgColor
    //material.isDoubleSided = true
  }
  
  let node = defaultHeroNode()
  node.gameID = uuid
  node.geometry = box
  
  return node
}

let regularCubeNode = { (color: Color) -> MaterialNode in
  var box = SCNBox()
  let cellSize: CGFloat = FieldConstants.defaultCellSize
  var uuid = UUID.short()
  
  box = SCNBox(
    width: cellSize * 0.4,
    height: cellSize * 0.9,
    length: cellSize * 0.4,
    chamferRadius: 0)
  
  uuid.append("-regular")
  
  for material in box.materials {
    material.diffuse.contents = color.cgColor
    //material.emission.contents = color.cgColor
    //material.isDoubleSided = true
  }
  
  let node = defaultHeroNode()
  node.gameID = uuid
  node.geometry = box
  
  return node
}

let smallCubeNode = { (color: Color) -> MaterialNode in
  var box = SCNBox()
  let cellSize: CGFloat = FieldConstants.defaultCellSize
  var uuid = UUID.short()
  
  box = SCNBox(
    width: cellSize * 0.2,
    height: cellSize * 0.8,
    length: cellSize * 0.2,
    chamferRadius: 0)
  
  uuid.append("-small")
  
  for material in box.materials {
    material.diffuse.contents = color.cgColor
    //material.emission.contents = color.cgColor
    //material.isDoubleSided = true
  }
  
  let node = defaultHeroNode()
  node.gameID = uuid
  node.geometry = box
  
  return node
}

let defaultHeroNode = { () -> MaterialNode in
  let node = MaterialNode(type: .hero)
  
  node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
  node.physicsBody?.mass = 4
  node.physicsBody?.restitution = 0
  node.physicsBody?.categoryBitMask = EntityType.hero.rawValue
  node.physicsBody?.collisionBitMask = EntityType.hero.rawValue | EntityType.field.rawValue
  node.physicsBody?.contactTestBitMask = EntityType.hero.rawValue
  
  return node
}

