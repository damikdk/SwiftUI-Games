//
//  SCNNode.swift
//  TBS
//
//  Created by Damik Minnegalimov on 30/04/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import Foundation
import SceneKit

enum BodyType: Int {
  case field = 1
  case character
  case shield
}

class MaterialNode: SCNNode {
  var type: BodyType
  var gameID: String!

  init(type: BodyType, id: String? = nil) {
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
    with color: SCNColor = SCNColor.lightGray,
    for seconds: Double = 0.3
  ) {
    let material = geometry!.firstMaterial!

    SCNTransaction.begin()
    SCNTransaction.animationDuration = seconds

    // on completion - unhighlight
    SCNTransaction.completionBlock = {
      SCNTransaction.begin()
      SCNTransaction.animationDuration = seconds

      material.emission.contents = SCNColor.clear
      SCNTransaction.commit()
    }

    material.emission.contents = color
    SCNTransaction.commit()
  }

  func height() -> CGFloat {
    return CGFloat(self.boundingBox.max.y - self.boundingBox.min.y)
  }
}
