//
//  JumpGameView.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 04.08.2022.
//

import SwiftUI
import SceneKit

struct JumpGameView: GameView {
  @ObservedObject var game: JumpGame
  @Binding var showing: Bool
  
  var sceneRendererDelegate = SceneRendererDelegate()

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
          
          Button {
          } label: {
            Text("Score \(game.score)")
          }
          .buttonStyle(MaterialButtonStyle())
          .disabled(true)
        }
        
        Spacer()
      }
      .padding()
    }
    .onDisappear(perform: {
      sceneRendererDelegate.onEachFrame = nil
    })
    .onAppear(perform: {
      sceneRendererDelegate.onEachFrame = game.onEachFrame
    })

  }
}
