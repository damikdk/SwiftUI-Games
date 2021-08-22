//
//  DarkGameView.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 09.08.2021.
//
import SwiftUI
import SceneKit
import GameController

struct DarkGameView: GameView {
  @Binding var showing: Bool
  @ObservedObject var game: DarkGame

  var sceneRendererDelegate = SceneRendererDelegate()

  let virtualController = { () -> GCVirtualController in

    // Earlier I used `fullScreenCover` for games in MenuScreen,
    // but GCVirtualController was BELOW it.
    // So keep GCVirtualController in View, not Overlay/Modal/Sheet containers
    // https://developer.apple.com/forums/thread/682138

    let virtualConfiguration = GCVirtualController.Configuration()
    virtualConfiguration.elements = [GCInputRightThumbstick]

    let virtualController = GCVirtualController(configuration: virtualConfiguration)
    return virtualController
  }()

  var body: some View {
    ZStack {

      // Scene itself
      SceneView(
        scene: game.scene,
        options: [
          .temporalAntialiasingEnabled
        ],
        delegate: sceneRendererDelegate)
        .ignoresSafeArea()

      // Overlay
      VStack {

        // Top left botton
        HStack(alignment: .top) {
          Button {
            showing.toggle()
          } label: {
            Image(systemName: "xmark")
          }
          .font(.largeTitle)
          .buttonStyle(MaterialButtonStyle())

          Spacer()
        }

        Spacer()
      }
      .padding()
    }
    .onDisappear(perform: {
      virtualController.disconnect()
      sceneRendererDelegate.onEachFrame = nil
    })
    .onAppear(perform: {
      virtualController.connect()
      sceneRendererDelegate.onEachFrame = { game.onEachFrame() }

      if let rightPad = virtualController.controller?.extendedGamepad?.rightThumbstick {
        rightPad.valueChangedHandler = { (dpad, xValue, yValue) in
          game.handleRightPad(xAxis: xValue, yAxis: yValue)
        }
      }
    })

  }
}