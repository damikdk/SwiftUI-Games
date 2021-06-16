//
//  MinimalDemoView.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 17.06.2021.
//

import SwiftUI
import SceneKit

struct MinimalDemoView: GameView {
  @Binding var showing: Bool
  @ObservedObject var game: MinimalDemo
  
  var body: some View {
    ZStack {
      
      // Scene itself
      SceneView(
        scene: game.scene,
        options: [
          .allowsCameraControl,
          .temporalAntialiasingEnabled
        ])
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
        
        // Bottom Center Panel
        HStack(alignment: .bottom) {
          VStack {
            Text("I want that ball\nI want it now\nI don’t care where\nOr why or how\n\nI want to throw it\nIn the air\nAnd kick the thing\nFrom here to there")
              .font(.title3.bold())
            
            Text("“That Ball” by Jaymie Gerard")
              .font(.caption.italic())
              .padding(.top)
          }
          .foregroundColor(.primary)
          .padding(30)
          .background(.ultraThinMaterial)
          .cornerRadius(30)
          
          Spacer()
        }
      }
      .padding()
    }
  }
}
