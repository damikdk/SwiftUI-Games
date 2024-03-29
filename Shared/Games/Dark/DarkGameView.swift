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
  @ObservedObject var game: DarkGame
  @Binding var showing: Bool

  var sceneRendererDelegate = SceneRendererDelegate()

  var superController = SuperController(elements: [GCInputRightThumbstick])

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
      superController.disconnect()
      sceneRendererDelegate.onEachFrame = nil
    })
    .onAppear(perform: {
      superController.connect()
      superController.handleRightPad = game.handleRightPad
      
      sceneRendererDelegate.onEachFrame = game.onEachFrame
    })

  }
}
