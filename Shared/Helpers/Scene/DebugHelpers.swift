//
//  DebugHelpers.swift
//  TBS
//
//  Created by Damir Minnegalimov on 11.05.2021.
//  Copyright © 2021 Damirka. All rights reserved.
//

import SceneKit
import SwiftUI

extension SCNGeometry {
  static func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
    let indices: [Int32] = [0, 1]
    
    let source = SCNGeometrySource(vertices: [vector1, vector2])
    let element = SCNGeometryElement(indices: indices, primitiveType: .line)
    
    return SCNGeometry(sources: [source], elements: [element])
  }
}

extension UUID {
  static func short() -> String{
    return String(UUID().uuidString.prefix(6))
  }
}
