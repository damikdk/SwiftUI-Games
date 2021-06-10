//
//  ContentView.swift
//  Shared
//
//  Created by Damir Minnegalimov on 04.06.2021.
//

import SwiftUI
import SceneKit

let cameraHeight: Float = 40

struct GameView: View {
  @Binding var showing: Bool
  var game: Game

  var scene = SCNScene()
  var sceneRendererDelegate = StupidDelegate()

  var cameraNode: SCNNode {
    let cameraNode = SCNNode()
    cameraNode.name = "Camera"
    cameraNode.camera = SCNCamera()
    //cameraNode.eulerAngles = SCNVector3Make(Float.pi / -3, 0, 0)
    cameraNode.camera!.zFar = 200
    cameraNode.position = SCNVector3(x: 0, y: cameraHeight, z: cameraHeight)

    let fieldCenter = game.field.center()
    cameraNode.look(at: fieldCenter)

    return cameraNode
  }

  var body: some View {
    // We can't get touch location with TapGesture, so hack:
    // (https://stackoverflow.com/a/56567649/7996650)
    let tap = DragGesture(minimumDistance: 0, coordinateSpace: .global)
      .onEnded { value in
        let translation = value.translation

        if abs(translation.height) < 20,
           abs(translation.width) < 20,
          let firstNode = findFirstNode(atPoint: value.location) {
          /// highlight it
          firstNode.highlight()
        }
      }

    ZStack(alignment: .topLeading) {
      SceneView(
        scene: scene,
        options: [
          .allowsCameraControl,
          .temporalAntialiasingEnabled
        ],
        delegate: sceneRendererDelegate)
        .ignoresSafeArea()
        .onAppear() {
          scene.rootNode.addChildNode(game.field.node)
          scene.rootNode.addChildNode(cameraNode)
          scene.background.contents = Color.DarkTheme.Violet.background.cgColor
        }
        .gesture(tap)

      HStack() {
        Button {
          showing.toggle()
        } label: {
          Image(systemName: "xmark")
        }
        .buttonStyle(MaterialButtonStyle())
        .font(.largeTitle)
        .padding(.leading)
      }
    }
  }
}

extension GameView {
  func findFirstNode(atPoint point: CGPoint) -> SCNNode? {
    guard let sceneRenderer = sceneRendererDelegate.renderer else {
      print("There is no SceneRenderer!")
      return nil
    }

    let hitResults = sceneRenderer.hitTest(point, options: [:])

    if hitResults.count == 0 {
      // check that we clicked on at least one object
      return nil
    }

    // retrieved the first clicked object
    let hitResult = hitResults[0]

    return hitResult.node
  }

  func findFirstTouchableNode(atPoint point: CGPoint) -> SCNNode? {
    guard let sceneRenderer = sceneRendererDelegate.renderer else {
      print("There is no SceneRenderer!")
      return nil
    }

    let options: [SCNHitTestOption : Any] = [SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue]
    let hitResults = sceneRenderer.hitTest(point, options: options)

    if hitResults.count == 0 {
      // check that we clicked on at least one object
      return nil
    }

    // retrieved the first clicked object
    let hitResult = hitResults.first { $0.node.physicsBody != nil }

    return hitResult?.node
  }
}

// Hackest hack ever. And stupidest one!
// For handling touches in SceneView we need SCNSceneRenderer,
// but SwiftUI's SceneView don't provide it.
class StupidDelegate: NSObject, SCNSceneRendererDelegate {
  var renderer: SCNSceneRenderer?

  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    if self.renderer == nil {
      self.renderer = renderer
      print(renderer, "HAHA GOT 'EM STUPID MACHINE")
    }
  }
}
