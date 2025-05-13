//
//  SCNNode+Helpers.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 04.08.2022.
//

import SceneKit
import SwiftUI


// MARK: - Getters
extension SCNNode {
  
  func height() -> CGFloat {
    return CGFloat(self.boundingBox.max.y - self.boundingBox.min.y)
  }

}

// MARK: - Animations

extension SCNNode {
  
  /// EasyIn-EasyOut forever scale animation
  func pulse(from: Double, to: Double, duration: Double) {
    let scaleAnimation = CABasicAnimation(keyPath: "radius")
    scaleAnimation.fromValue = from
    scaleAnimation.toValue = to
    scaleAnimation.duration = duration
    scaleAnimation.autoreverses = true
    scaleAnimation.repeatCount = .greatestFiniteMagnitude
    scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    
    geometry?.addAnimation(scaleAnimation, forKey: nil)
  }
  
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
  
}

// MARK: - Debug UI

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
  
  static func line(from: SCNVector3, to: SCNVector3, width: CGFloat, color: Color) -> SCNNode {
    let vector = to - from,
        length = vector.length()
    
    let cylinder = SCNCylinder(radius: width, height: CGFloat(length - 3))
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
