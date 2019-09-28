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
    func highlight() {
        let material = geometry!.firstMaterial!

        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3
        
        // on completion - unhighlight
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.3
            
            material.emission.contents = SCNColor.clear
            SCNTransaction.commit()
        }
        
        material.emission.contents = SCNColor.lightGray
        SCNTransaction.commit()
    }

    func height() -> CGFloat {
        return CGFloat(self.boundingBox.max.y - self.boundingBox.min.y)
    }
}
