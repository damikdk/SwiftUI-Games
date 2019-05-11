//
//  GraphicsHelper.swift
//  TBS
//
//  Created by Damik Minnegalimov on 29/04/2019.
//  Copyright © 2019 Damirka. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SceneKit

extension UIColor {
    static var darkDeepBlue: UIColor { return "061A40".hexColor }

    static var darkGrayFancy: UIColor { return "424B54".hexColor }
    static var darkGreen: UIColor { return "6B818C".hexColor }
    static var darkViolet: UIColor { return "6F73D2".hexColor }
    static var darkBlue: UIColor { return "0353A4".hexColor }
    
    static var plum: UIColor { return "8F3985".hexColor }
    
    static var lightGrayFancy: UIColor { return "D9F0FF".hexColor }
    static var lightBlue: UIColor { return "83C9F4".hexColor }
}

extension UIColor {
    struct DarkTheme {
        struct Violet {
            static var fieldColor: UIColor { return UIColor.darkGrayFancy }
            static var primary: UIColor { return UIColor.plum }
            static var accent: UIColor { return UIColor.darkViolet }
            static var minor: UIColor { return UIColor.lightBlue }
        }
    }
}

func highlight(node: SCNNode) {
    let material = node.geometry!.firstMaterial!

    SCNTransaction.begin()
    SCNTransaction.animationDuration = 0.3
    
    // on completion - unhighlight
    SCNTransaction.completionBlock = {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3
        
        material.emission.contents = UIColor.clear
        SCNTransaction.commit()
    }
    
    material.emission.contents = UIColor.lightGray
    SCNTransaction.commit()
}

extension String {
    var hexColor: UIColor {
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
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIImage {
    func tinted(with color: UIColor, backgroundColor: UIColor) -> UIImage? {
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
