//
//  ContactDelegate.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 08.07.2021.
//

import SceneKit

class ContactDelegate: NSObject, SCNPhysicsContactDelegate {
  var onBegin: ((SCNPhysicsContact) -> ())? = nil

  func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    onBegin?(contact)
  }
}
