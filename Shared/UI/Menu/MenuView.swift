//
//  SwiftUIView.swift
//  TBS
//
//  Created by Damir Minnegalimov on 28.05.2021.
//  Copyright © 2021 Damirka. All rights reserved.
//

import SwiftUI


struct MenuView: View {
  @State private var showingGame = false
  @State private var currentGame: Game?
  
  var body: some View {
    // ZStack it is just a bad workaround for GCVirtualController.
    // Earlier I used `fullScreenCover`, but GCVirtualController appears BELOW it.
    // So keep GCVirtualController in View, not Overlay/Modal/Sheet containers
    ZStack {
      List(Games, id: \.name) { game in
        Button {
          withAnimation {
            currentGame = game
            showingGame.toggle()
          }
        } label: {
          HStack {
            Image(systemName: game.iconName)
              .resizable()
              .scaledToFit()
              .frame(width: 100, height: 100)
              .padding()

            VStack(alignment: .leading) {
              Text(game.name)
                .font(.title2.weight(.heavy))
                .foregroundColor(.primary)

              Text(game.description)
                .font(.body.weight(.bold))
                .foregroundColor(.secondary)
            }
          }
        }
        .padding(.horizontal, -5)
      }
      .listStyle(.plain)

      if showingGame {
        switch currentGame {
        case let currentGame as MinimalDemo:
          MinimalDemoView(game: currentGame, showing: $showingGame)
        case let currentGame as TBSGame:
          TBSGameView(game: currentGame, showing: $showingGame)
        case let currentGame as TogetherGame:
          TogetherGameView(game: currentGame, showing: $showingGame)
        case let currentGame as DarkGame:
          DarkGameView(game: currentGame, showing: $showingGame)
        default:
          EmptyView()
        }
      }
    }
  }
}
