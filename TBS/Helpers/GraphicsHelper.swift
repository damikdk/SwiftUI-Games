//
//  GraphicsHelper.swift
//  TBS
//
//  Created by Damik Minnegalimov on 29/04/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SceneKit

func highlight(node: SCNNode) {
    let material = node.geometry!.firstMaterial!

    SCNTransaction.begin()
    SCNTransaction.animationDuration = 0.3
    
    // on completion - unhighlight
    SCNTransaction.completionBlock = {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3
        
        material.emission.contents = UIColor.clear
        SCNTransaction.commit()
    }
    
    material.emission.contents = UIColor.lightGray
    SCNTransaction.commit()
}
