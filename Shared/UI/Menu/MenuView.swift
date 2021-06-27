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
    // Hack since iOS 14 can't update State
    // (https://developer.apple.com/forums/thread/652080)
    Text(currentGame?.name ?? "")
      .frame(width: 0, height: 0)
      .hidden()

    // ZStack it is just a bad workaround for GCVirtualController.
    // Earlier I used `fullScreenCover`, but GCVirtualController appears BELOW it.
    // So keep GCVirtualController in View, not Overlay/Modal/Sheet containers
    ZStack {
      List(Games, id: \.name) { game in
        let cardInfo = CardInfo(
          title: game.name,
          details: game.description)

        CardView(cardInfo: cardInfo) {
          withAnimation {
            currentGame = game
            showingGame.toggle()
          }
        }
        .padding(.horizontal, -5)
      }
      .listStyle(.plain)

      if let game = currentGame, showingGame {
        if let minimalGame = game as? MinimalDemo {
          MinimalDemoView(showing: $showingGame, game: minimalGame)
        } else if let tbsGame = game as? TBSGame {
          TBSGameView(showing: $showingGame, game: tbsGame)
        } else if let togetherGame = game as? TogetherGame {
          TogetherGameView(showing: $showingGame, game: togetherGame)
        }
      }
    }
  }
}
