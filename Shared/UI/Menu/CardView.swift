//
//  SwiftUIView.swift
//  TBS
//
//  Created by Damir Minnegalimov on 28.05.2021.
//  Copyright © 2021 Damirka. All rights reserved.
//

import SwiftUI

struct CardInfo: Hashable {
  var title: String
  var details: String = ""
  var color: Color = .darkDeepBlue
  var iconName: String
}

struct CardView: View {
  let cardInfo: CardInfo
  let action: () -> Void
  
  var body: some View {
    Button {
      action()
    } label: {
        VStack {
          Image(systemName: cardInfo.iconName)
            .resizable(resizingMode: .tile)

          ZStack {
            HStack(alignment: .bottom) {
              Text(cardInfo.title)
                .font(.title2
                        .weight(.heavy))
                .foregroundColor(.primary)
              
              Text(cardInfo.details)
                .font(.body.weight(.bold))
                .foregroundColor(.secondary)
            }
          }
          .frame(
            maxWidth: .infinity,
            maxHeight: 40,
            alignment: .leading)
          .padding()
          .background(.thickMaterial)

      }
      .cornerRadius(20)
      .frame(minHeight: 200, maxHeight: 300)
    }
    .buttonStyle(ScaleButtonStyle())
  }
}
