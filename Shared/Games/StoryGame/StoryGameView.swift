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
  
  @State private var showingChapter = false
  @State private var currentChapter: Chapter?

  fileprivate let backgroundGradient = LinearGradient(gradient: Gradient(colors: [.black, .darkRed]), startPoint: .top, endPoint: .bottom)
   
  var body: some View {
    ZStack {
      
      // Story path
      
      // TODO: Disable bounce
      ScrollView {
        ZStack {
          backgroundGradient
          
          VStack {
            
            // TODO: Draw path between chapters

            ForEach(game.chapters, id: \.name) { chapter in
              Button {
                withAnimation {
                  currentChapter = chapter
                  showingChapter.toggle()
                }
              } label: {
                VStack {
                  Text(chapter.name)
                    .font(.title2.weight(.heavy))
                    .foregroundColor(.primary)

                  Text(chapter.description)
                    .font(.body.weight(.bold))
                    .foregroundColor(.secondary)
                }
                .padding()
                .frame(height: 200)
                .offset(x: Double.random(in: -100...100))
              }
              .disabled(!chapter.available)
            }
          }

        }
      }
      .ignoresSafeArea()


      // Top HUD

      VStack {

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
      .font(.largeTitle)
      .padding()

    }
  }
}
