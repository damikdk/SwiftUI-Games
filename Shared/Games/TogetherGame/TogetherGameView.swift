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
  @Binding var showing: Bool
  @ObservedObject var game: TogetherGame

  let virtualController = { () -> GCVirtualController in

    // Controller shows up behind this View and crashes on dismiss
    // I think, because this View is actually content of sheet
    // https://developer.apple.com/forums/thread/682138

    let virtualConfiguration = GCVirtualControllerConfiguration()
    virtualConfiguration.elements = [GCInputLeftThumbstick,
                                     GCInputRightThumbstick]

    let virtualController = GCVirtualController(configuration: virtualConfiguration)
    virtualController.connect()

    return virtualController
  }()

  var body: some View {
    ZStack {
      SceneView(
        scene: game.scene,
        options: [
          .temporalAntialiasingEnabled
        ])
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
    }
    .font(.largeTitle)
    .padding(5)
  }

}
