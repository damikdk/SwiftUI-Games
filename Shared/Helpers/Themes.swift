//
//  GraphicsHelper.swift
//  TBS
//
//  Created by Damik Minnegalimov on 29/04/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import Foundation
import QuartzCore
import SceneKit
import SwiftUI

extension Color {
  static var darkDeepBlue = Color(hex:"061A40")
  static var darkGrayFancy = Color(hex:"424B54")
  static var darkGreen = Color(hex:"6B818C")
  static var darkViolet = Color(hex:"061A40")
  static var lightViolet = Color(hex:"6F73D2")
  static var plum = Color(hex:"0353A4")
  static var lightGrayFancy = Color(hex:"D9F0FF")
  static var lightBlue = Color(hex:"83C9F4")
}

extension Color {
  struct DarkTheme {
    struct Violet {
      static var fieldColor = Color.darkGrayFancy
      static var primary = Color.plum
      static var accent = Color.darkViolet
      static var minor = Color.lightBlue
      static var background = Color.black
    }
  }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64

        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
