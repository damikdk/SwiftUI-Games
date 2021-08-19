//
//  TogetherGameView.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 27.06.2021.
//

import SwiftUI
import SceneKit
import GameController

struct TogetherGameView: GameView {
  @ObservedObject var game: TogetherGame

  @Binding var showing: Bool {
    didSet { game.scene.isPaused = showing }
  }

  var sceneRendererDelegate = SceneRendererDelegate()
  let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

  let virtualController = { () -> GCVirtualController in

    // Earlier I used `fullScreenCover` for games in MenuScreen,
    // but GCVirtualController was BELOW it.
    // So keep GCVirtualController in View, not Overlay/Modal/Sheet containers
    // https://developer.apple.com/forums/thread/682138

    let virtualConfiguration = GCVirtualController.Configuration()
    virtualConfiguration.elements = [GCInputLeftThumbstick, GCInputRightThumbstick]

    let virtualController = GCVirtualController(configuration: virtualConfiguration)
    return virtualController
  }()

  var body: some View {
    ZStack {
      SceneView(
        scene: game.scene,
        options: [
          .temporalAntialiasingEnabled
        ],
        delegate: sceneRendererDelegate)
        .ignoresSafeArea()

      VStack {
        // Top HUD

        HStack {
          // Top left botton
          Button {
            showing.toggle()
          } label: {
            Image(systemName: "xmark")
          }
          .buttonStyle(MaterialButtonStyle())

          Spacer()
        }

        Spacer()
      }

      GeometryReader { (geometry) in
        VStack(alignment: .center) {
          Spacer()

          if geometry.size.width < 500 {
            Button("GCVirtualController requires more horizontal space") {
              showing.toggle()
            }
            .buttonStyle(MaterialButtonStyle())
          }

          Spacer()
        }
      }
    }
    .onDisappear(perform: {
      virtualController.disconnect()
      sceneRendererDelegate.onEachFrame = nil
    })
    .onAppear(perform: {
      virtualController.connect()
      sceneRendererDelegate.onEachFrame = { game.onEachFrame() }

      if let leftPad = virtualController.controller?.extendedGamepad?.leftThumbstick {
        leftPad.valueChangedHandler = { (dpad, xValue, yValue) in
          game.handleLeftPad(xAxis: xValue, yAxis: yValue)
        }
      }

      if let rightPad = virtualController.controller?.extendedGamepad?.rightThumbstick {
        rightPad.valueChangedHandler = { (dpad, xValue, yValue) in
          game.handleRightPad(xAxis: xValue, yAxis: yValue)
        }
      }
    })
    .onReceive(timer) { input in
      game.onTimer()
    }
    .font(.largeTitle)
    .padding(5)
    .ignoresSafeArea()
  }

}
