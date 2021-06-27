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

    // Earlier I used `fullScreenCover` for games in MenuScreen,
    // but GCVirtualController was BELOW it.
    // So keep GCVirtualController in View, not Overlay/Modal/Sheet containers
    // https://developer.apple.com/forums/thread/682138

    let virtualConfiguration = GCVirtualControllerConfiguration()
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
        ])

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

          if geometry.size.width < 400 {
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
    })
    .onAppear(perform: {
      virtualController.connect()
    })
    .font(.largeTitle)
    .padding(5)
  }

}
