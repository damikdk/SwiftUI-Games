//
//  View+Extenstions.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 19.06.2021.
//

import SwiftUI

struct OnFirstAppearModifier: ViewModifier {
  
  @State private var firstTime: Bool = true
  
  let perform: () -> Void
  
  func body(content: Content) -> some View {
    ZStack {
      // Hack since iOS 14 can't update State
      // (https://developer.apple.com/forums/thread/652080)
      Text(firstTime.description)
        .frame(width: 0, height: 0)
        .hidden()
      
      content
        .onAppear{
          if firstTime {
            firstTime = false
            self.perform()
          }
        }
    }
  }
}

extension View {
  func onFirstAppear( perform: @escaping () -> Void ) -> some View {
    return self.modifier(OnFirstAppearModifier(perform: perform))
  }
}
