//
//  LightHelpers.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 20.06.2021.
//

import SceneKit

func defaultLightNode(mode: SCNLight.LightType) -> SCNNode{
  switch mode {
  case .directional:
    // Create directional light
    let directionalLight = SCNLight()
    directionalLight.type = .directional
    directionalLight.automaticallyAdjustsShadowProjection = true
    directionalLight.intensity = 1000
    directionalLight.castsShadow = true
    
    directionalLight.orthographicScale = 1000

    directionalLight.shadowMapSize = CGSize(width: 2048, height: 2048)
    directionalLight.shadowMode = .forward
    directionalLight.shadowSampleCount = 128
    directionalLight.shadowRadius = 3
    directionalLight.shadowBias  = 32

    let directionalLightNode = SCNNode()
    directionalLightNode.light = directionalLight
    directionalLightNode.eulerAngles = SCNVector3(-Float.pi / 4, -Float.pi / 4, 0)
    
    return directionalLightNode
  case .ambient:
    // Create ambient light
    let ambientLight = SCNLight()
    ambientLight.type = .ambient
    ambientLight.intensity = 200
    
    let ambientLightNode = SCNNode()
    ambientLightNode.light = ambientLight
    return ambientLightNode
  case .spot:
    // create and add a light to the scene
    let light = SCNLight()
    
    light.type = .spot
    light.intensity = 1000
    light.castsShadow = true
    light.spotOuterAngle = 100
    light.shadowMode = .deferred
    light.shadowSampleCount = 32
    light.shadowRadius = 3
    light.maximumShadowDistance = 20
    
    let lightNode = SCNNode()
    lightNode.name = "Light"
    lightNode.light = light

    return lightNode
  default:
    let defaultLight = SCNLight()
    let defaultLightNode = SCNNode()
    defaultLightNode.light = defaultLight
    return defaultLightNode
  }
}

