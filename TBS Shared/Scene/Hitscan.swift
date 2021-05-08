//
//  Hitscan.swift
//  TBS
//
//  Created by Damir Minnegalimov on 08.05.2021.
//  Copyright © 2021 Damirka. All rights reserved.
//

import SceneKit

func hitscan(
  from: SCNVector3,
  to: SCNVector3,
  in scene: SCNScene,
  with types: [BodyType] = []
) -> [MaterialNode] {

  let hitResults = scene.physicsWorld.rayTestWithSegment(from: from, to: to)
  var materialNodes: [MaterialNode] = []

  for hitResult in hitResults {
//    print("Hit by Frozen Arrow: ", hitResult.node)

    if let materialNode = hitResult.node as? MaterialNode {
      materialNodes.append(materialNode)
    }
  }

  if types.count > 0 {
    materialNodes = materialNodes.filter { node in
      return types.contains { $0 == node.type}
    }
  }

  return materialNodes
}
