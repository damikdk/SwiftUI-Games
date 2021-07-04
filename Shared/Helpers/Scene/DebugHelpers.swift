//
//  DebugHelpers.swift
//  TBS
//
//  Created by Damir Minnegalimov on 11.05.2021.
//  Copyright © 2021 Damirka. All rights reserved.
//

import SceneKit
import SwiftUI

extension SCNNode {
  @discardableResult
  func addDebugLine(
    from vector1: SCNVector3,
    to vector2: SCNVector3,
    with color: Color = .lightViolet,
    time: Double = 2
  ) -> SCNNode {
    
    let lineGeometry = SCNGeometry.line(from: vector1, to: vector2)
    lineGeometry.firstMaterial?.emission.contents = color.cgColor

    let debugLineNode = SCNNode(geometry: lineGeometry)
    debugLineNode.name = "debug-line"

    debugLineNode.castsShadow = false
    self.addChildNode(debugLineNode)
    
    if time > 0 {
      debugLineNode.runAction(
        SCNAction.sequence([
          SCNAction.wait(duration: time),
          SCNAction.removeFromParentNode()
        ]))
    }
    
    return debugLineNode
  }

  @discardableResult
  func addDebugLine2(
    from vector1: SCNVector3,
    to vector2: SCNVector3,
    color: Color = .lightViolet,
    width: CGFloat = 0.1,
    time: Double = 2
  ) -> SCNNode {
    let debugLineNode = SCNNode.line(from: vector1,
                                     to: vector2,
                                     width: width,
                                     color: color)

    debugLineNode.name = "debug-line2"

    debugLineNode.castsShadow = false
    self.addChildNode(debugLineNode)

    if time > 0 {
      debugLineNode.runAction(
        SCNAction.sequence([
          SCNAction.wait(duration: time),
          SCNAction.removeFromParentNode()
        ]))
    }

    return debugLineNode
  }
  
  @discardableResult
  func addPopup(
    with text: String,
    color: Color = .white,
    scale: Double = 0.15,
    time: Double = 2
  ) -> SCNNode {
    let textGeometry = SCNText(string: text, extrusionDepth: 0)
    textGeometry.flatness = 0.2
    
    // Color text (it't not working!)
    for material in textGeometry.materials {
      material.emission.contents = color.cgColor
      material.diffuse.contents = color.cgColor
    }
    
    let popupNode = SCNNode(geometry: textGeometry)
    
    popupNode.scale = SCNVector3(scale, scale, scale)
    popupNode.position = SCNVector3(
      popupNode.position.x,
      popupNode.position.y + 3,
      popupNode.position.z)
    
    popupNode.constraints = [SCNBillboardConstraint()]
    
    // Center text node in parent
    // (https://stackoverflow.com/a/49860463/7996650)
    let (min, max) = popupNode.boundingBox
    let dx = min.x + 0.5 * (max.x - min.x)
    let dy = min.y + 0.5 * (max.y - min.y)
    let dz = min.z + 0.5 * (max.z - min.z)
    popupNode.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)

    popupNode.castsShadow = false

    self.addChildNode(popupNode)
    
    if time > 0 {
      popupNode.runAction(
        SCNAction.sequence([
          SCNAction.moveBy(x: 0, y: 2, z: 0, duration: 1),
        ]))
      
      popupNode.runAction(
        SCNAction.sequence([
          SCNAction.wait(duration: time),
          SCNAction.removeFromParentNode()
        ]))
    }
    
    return popupNode
  }
}

extension SCNGeometry {
  static func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
    let indices: [Int32] = [0, 1]
    
    let source = SCNGeometrySource(vertices: [vector1, vector2])
    let element = SCNGeometryElement(indices: indices, primitiveType: .line)
    
    return SCNGeometry(sources: [source], elements: [element])
  }
}

extension SCNNode {
  static func line(from: SCNVector3, to: SCNVector3, width: CGFloat, color: Color) -> SCNNode {
    let vector = to - from,
        length = vector.length()

    let cylinder = SCNCylinder(radius: width, height: CGFloat(length))
    cylinder.radialSegmentCount = 3
    cylinder.firstMaterial?.diffuse.contents = color.cgColor

    let node = SCNNode(geometry: cylinder)

    node.position = (to + from) / 2
    node.eulerAngles = SCNVector3(
      Double.pi / 2,
      acos(Double(to.z - from.z) / length),
      Double(atan2((to.y - from.y), (to.x - from.x))))

    return node
  }
}

extension UUID {
  static func short() -> String{
    return String(UUID().uuidString.prefix(6))
  }
}
