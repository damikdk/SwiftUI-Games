//
//  StoryGameView.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 10.07.2021.
//

import SwiftUI
import SceneKit

struct StoryGameView: GameView {  
  @ObservedObject var game: StoryGame
  @Binding var showing: Bool

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
  }
}
