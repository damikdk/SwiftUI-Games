//
//  ScaleButtonStyle.swift
//  TBS3 (iOS)
//
//  Created by Damir Minnegalimov on 09.06.2021.
//

import SwiftUI

import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
  }
}
