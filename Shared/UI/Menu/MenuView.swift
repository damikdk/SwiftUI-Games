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
  @State private var currentGameMode: GameMode?

  let cardInfos = gameModes.map { gameMode in
    return CardInfo(
      title: gameMode.name,
      details: gameMode.description)
  }

  var body: some View {
    // Hack since iOS 14 can't update State
    // (https://developer.apple.com/forums/thread/652080)
    Text(currentGameMode?.name ?? "")
      .frame(width: 0, height: 0)
      .hidden()

    List(cardInfos, id: \.self) { cardInfo in
      CardView(cardInfo: cardInfo) {
        withAnimation {
          currentGameMode = gameModes.first(where: { gameMode in
            gameMode.name == cardInfo.title
          })

          showingGame.toggle()
        }
      }
      .padding(.horizontal, -15)
    }
    .listStyle(.plain)
    .fullScreenCover(isPresented: $showingGame) {
      if let game = Game(gameMode: currentGameMode) {
        GameView(showing: $showingGame, game: game)
      }
    }
  }
}

struct MenuView_Previews: PreviewProvider {
  static var previews: some View {
    MenuView()
      .previewLayout(.fixed(width: 400, height: 600))

    MenuView()
      .previewLayout(.fixed(width: 300, height: 500))

    MenuView()
      .previewLayout(.fixed(width: 800, height: 300))
  }
}
