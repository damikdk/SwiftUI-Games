//
//  Swift+Helpers.swift
//  SwiftUI-Games (iOS)
//
//  Created by Damir Minnegalimov on 04.08.2022.
//

extension Int {
  func times(_ f: () -> ()) {
    if self > 0 {
      for _ in 0..<self {
        f()
      }
    }
  }
  
  func times(_ f: @autoclosure () -> ()) {
    if self > 0 {
      for _ in 0..<self {
        f()
      }
    }
  }
}
