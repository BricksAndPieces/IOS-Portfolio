//
//  ColorPallete.swift
//  Shape Slide
//
//  Created by 90307332 on 3/14/20.
//  Copyright © 2020 Ishan Shetty. All rights reserved.
//

import Foundation
import UIKit

struct ColorPallete {
    
    public static let BACKGROUND = UIColor(hexString: "#322C3E")
    public static let TEXT = UIColor(hexString: "#ffffff")
    
    public static let PUZZLE_GRID = UIColor(hexString: "#ffffff")
    public static let WALL = UIColor(hexString: "#322C3E")
    
    public static let PUZZLE_BACK = UIColor(hexString: "#423C4E")
    public static let SQUARE_ONE = UIColor(hexString: "#de6e1e")
    public static let SQUARE_TWO = UIColor(hexString: "#316af0")
    public static let TRIANGLE = UIColor(hexString: "#3dc924")
    public static let CIRCLE = UIColor(hexString: "#cc1f33")
}

extension UIColor {
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
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
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor {
      return self.adjustBrightness(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor {
      return self.adjustBrightness(by: -abs(percentage))
    }
    
    func adjustBrightness(by percentage: CGFloat = 30.0) -> UIColor {
      var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
      if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
        if b < 1.0 {
          let newB: CGFloat = max(min(b + (percentage/100.0)*b, 1.0), 0.0)
          return UIColor(hue: h, saturation: s, brightness: newB, alpha: a)
        } else {
          let newS: CGFloat = min(max(s - (percentage/100.0)*s, 0.0), 1.0)
          return UIColor(hue: h, saturation: newS, brightness: b, alpha: a)
        }
      }
        
      return self
    }
}
