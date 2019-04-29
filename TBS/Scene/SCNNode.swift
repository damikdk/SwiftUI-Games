//
//  SCNNode.swift
//  TBS
//
//  Created by Damik Minnegalimov on 30/04/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import Foundation
import SceneKit

class MaterialNode: SCNNode {
    var type: BodyType

    init(type: BodyType) {
        self.type = type
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
