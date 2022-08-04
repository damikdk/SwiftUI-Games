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

  let virtualController = createVirtualController([GCInputLeftThumbstick, GCInputRightThumbstick])

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
          
          Button {
          } label: {
            Text("Score \(game.score)")
          }
          .buttonStyle(MaterialButtonStyle())
          .disabled(true)
        }

        Spacer()
      }
      .font(.largeTitle)
      .padding()

      GeometryReader { geometry in
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
      
      sceneRendererDelegate.onEachFrame = { game.onEachFrame() }
    })
    .onReceive(timer) { input in
      game.onTimer()
    }
    
  }

}
