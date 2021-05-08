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

#if os(iOS)
import UIKit
#endif

typealias SCNColor = UIColor
typealias SCNImage = UIImage


extension SCNColor {
  static var darkDeepBlue: SCNColor { return "061A40".hexColor }

  static var darkGrayFancy: SCNColor { return "424B54".hexColor }
  static var darkGreen: SCNColor { return "6B818C".hexColor }
  static var darkViolet: SCNColor { return "6F73D2".hexColor }
  static var darkBlue: SCNColor { return "0353A4".hexColor }

  static var plum: SCNColor { return "8F3985".hexColor }

  static var lightGrayFancy: SCNColor { return "D9F0FF".hexColor }
  static var lightBlue: SCNColor { return "83C9F4".hexColor }

  static var red: SCNColor { return "FF0000".hexColor }
  static var yellow: SCNColor { return "FFFF00".hexColor }
}

extension SCNColor {
  struct DarkTheme {
    struct Violet {
      static var fieldColor: SCNColor { return SCNColor.darkGrayFancy }
      static var primary: SCNColor { return SCNColor.plum }
      static var accent: SCNColor { return SCNColor.darkViolet }
      static var minor: SCNColor { return SCNColor.lightBlue }
    }
  }
}

extension String {
  var hexColor: SCNColor {
    let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int = UInt32()
    Scanner(string: hex).scanHexInt32(&int)
    let a, r, g, b: UInt32

    switch hex.count {
    case 3: // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      return .clear
    }
    return SCNColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
  }
}

extension SCNImage {
  func tinted(with color: SCNColor, backgroundColor: SCNColor) -> SCNImage? {
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    let currentContext = UIGraphicsGetCurrentContext()

    // Set background color
    backgroundColor.setFill()
    // Fill context with it
    currentContext?.fill(CGRect(origin: .zero, size: size))

    // Set tint color
    color.set()

    // Make sure that renderingMode == alwaysTemplate (otherwise image always will be original)
    // and draw image with current color
    withRenderingMode(.alwaysTemplate)
      .draw(in: CGRect(origin: .zero, size: size))

    let resultImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return resultImage
  }
}

extension Float {
  func universal() -> Float {
    return self
  }
}

extension CGFloat {
  func universal() -> Float {
    return Float(self)
  }
}

