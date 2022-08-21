//
//  GameLogger.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 20.08.2022.
//

import Foundation

class GameLogger: ObservableObject {
  
  @Published var messages: [String] = []
  
  init(messages: [String] = []) {
    self.messages = messages
  }
  
  func post(newMessage: String) {
    print(newMessage)
    messages.append(newMessage)
  }
  
  func clear() {
    messages.removeAll()
  }
  
}
