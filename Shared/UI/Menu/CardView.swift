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
}

struct CardView: View {
  let cardInfo: CardInfo
  let action: () -> Void
  
  var body: some View {
    Button {
      action()
    } label: {
      ZStack(alignment: .topLeading) {
        // Preparing for future preview
        //        images.randomElement()!
        //          .resizable()
        //          .scaledToFill()
        //          .frame(maxHeight: 300, alignment: .center)
        //          .clipped()
        //          .foregroundColor(cardInfo.color)
        
        cardInfo.color
          .scaledToFill()
          .frame(maxHeight: 300, alignment: .center)
        
        VStack {
          Spacer()
          
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
      }
      .cornerRadius(20)
    }
    .buttonStyle(ScaleButtonStyle())
  }
}

struct CardView_Previews: PreviewProvider {
  static var cardInfo = CardInfo(title: "First Try")
  
  static var previews: some View {
    CardView(cardInfo: cardInfo) {}
    .previewLayout(.fixed(width: 800, height: 400))
  }
}
