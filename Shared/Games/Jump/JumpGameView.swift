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
    
    // Left-right control
    
    let drag = DragGesture()
      .onChanged({ gesture in
        let horizontalTranslation = gesture.translation.width
        game.onControlChange(newValue: horizontalTranslation)
      })
      .onEnded { gesture in
        game.onControlEnd()
      }

    ZStack {
      
      // Scene itself
      SceneView(
        scene: game.scene,
        options: [
          .temporalAntialiasingEnabled
        ],
        delegate: sceneRendererDelegate)
      .gesture(drag)
      .ignoresSafeArea()
      
      // Overlay
      VStack {
        
        // Top panel
        
        HStack(alignment: .top) {
          
          // Top left button
          
          Button {
            showing.toggle()
          } label: {
            Image(systemName: "xmark")
          }
          .font(.largeTitle)
          .buttonStyle(MaterialButtonStyle())
          
          Spacer()
          
          // Top right panel
          
          Button {
          } label: {
            Text("Score \(game.score)")
          }
          .font(.largeTitle)
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
