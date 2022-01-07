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

  let text = """
  I want that ball
  I want it now
  I don’t care where
  Or why or how

  I want to throw it
  In the air
  And kick the thing
  From here to there
  """
  
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
            Text(text)
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
