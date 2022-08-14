//
//  MaterialButton.swift
//  TBS3 (iOS)
//
//  Created by Damir Minnegalimov on 09.06.2021.
//

import SwiftUI

struct MaterialButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(.primary)
      .padding()
      .background(.ultraThinMaterial)
      .cornerRadius(25)
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
      .hoverEffect(.lift)
  }
}
