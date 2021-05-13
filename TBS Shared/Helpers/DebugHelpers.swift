//
//  DebugHelpers.swift
//  TBS
//
//  Created by Damir Minnegalimov on 11.05.2021.
//  Copyright © 2021 Damirka. All rights reserved.
//

import SceneKit

extension SCNNode {
  @discardableResult
  func addDebugLine(
    from vector1: SCNVector3,
    to vector2: SCNVector3,
    with color: SCNColor = .darkBlue
  ) -> SCNNode {
    
    let lineGeometry = SCNGeometry.line(from: vector1, to: vector2)
    lineGeometry.firstMaterial?.emission.contents = color
    
    let debugLineNode = SCNNode(geometry: lineGeometry)
    debugLineNode.name = "debug-line"
    
    self.addChildNode(debugLineNode)
    
    return debugLineNode
  }
  
  @discardableResult
  func addPopup(
    with text: String,
    color: SCNColor = .white
  ) -> SCNNode {
    
    let popupGeometry = SCNText(string: "\(text)", extrusionDepth: 1.0)
    popupGeometry.firstMaterial?.emission.contents = color
    
    let popupNode = SCNNode(geometry: popupGeometry)
    
    popupNode.scale = SCNVector3(0.05, 0.05, 0.05)
    popupNode.position = SCNVector3(
      popupNode.position.x,
      popupNode.position.y + 2.5,
      popupNode.position.z)
    
    popupNode.constraints = [SCNBillboardConstraint()]
    
    self.addChildNode(popupNode)
    return popupNode
  }
}


extension SCNGeometry {
  class func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
    let indices: [Int32] = [0, 1]
    
    let source = SCNGeometrySource(vertices: [vector1, vector2])
    let element = SCNGeometryElement(indices: indices, primitiveType: .line)
    
    return SCNGeometry(sources: [source], elements: [element])
  }
}
