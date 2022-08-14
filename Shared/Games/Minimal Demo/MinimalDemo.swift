//
//  MinimalGame.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 17.06.2021.
//

import SceneKit
import SwiftUI

class MinimalDemo: Game, ObservableObject {
  let name: String
  let description: String

  let iconName = "circlebadge"

  var scene: SCNScene = SCNScene()
  
  init(
    name: String,
    description: String
  ) {
    self.name = name
    self.description = description
    
    scene.background.contents = Color.DarkTheme.Violet.background.cgColor
    
    let sphereGeometry = SCNSphere(radius: 2)
    sphereGeometry.firstMaterial?.diffuse.contents = Color.darkRed.cgColor
    sphereGeometry.segmentCount = 20
  
    let sphereNode = SCNNode(geometry: sphereGeometry)
    sphereNode.pulse(from: 2, to: 5, duration: 3)
    
    // Create directional light
    let directionalLight = SCNNode()
    directionalLight.light = SCNLight()
    directionalLight.light!.type = .directional
    directionalLight.eulerAngles = SCNVector3(x: 0, y: 0, z: 0)
    
    let myAmbientLight = SCNLight()
    myAmbientLight.type = .ambient
    myAmbientLight.intensity = 100
    let myAmbientLightNode = SCNNode()
    myAmbientLightNode.light = myAmbientLight
    
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.position = SCNVector3(x: 10, y: 10, z: 10)
    let centerConstraint = SCNLookAtConstraint(target: sphereNode)
    cameraNode.constraints = [centerConstraint]
    
    scene.rootNode.addChildNode(cameraNode)
    scene.rootNode.addChildNode(directionalLight)
    scene.rootNode.addChildNode(myAmbientLightNode)
    scene.rootNode.addChildNode(sphereNode)
  }
}
