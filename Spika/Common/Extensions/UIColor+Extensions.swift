//
//  UIColor+Extensions.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

public extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int, opacity: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: opacity)
    }
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff, opacity:alpha)
    }
    
    convenience init(hexString: String) {
        var hexValue: UInt64 = 0
        let scanner = Scanner(string: hexString)
        scanner.scanHexInt64(&hexValue)
        let value = Int(hexValue)
        self.init(red:(value >> 16) & 0xff, green:(value >> 8) & 0xff, blue:value & 0xff)
    }
    
}

extension UIColor {
    
    /* Common Individual colors
        - These are the colors that are defined in the Design as color styles
        - Sort it like in Assets folder
    */
    
    static let appBlueLight = UIColor(named: "appBlueLight") ?? .clear
    static let appGreen = UIColor(named: "appGreen")
    static let appRed = UIColor(named: "appRed")
    static let appWhite = UIColor(named: "appWhite")
    static let borderColor = UIColor(named: "borderColor")
    static let chatBackground = UIColor(named: "chatBackground")
    static let darkBackground = UIColor(named: "darkBackground")
    static let darkBackground2 = UIColor(named: "darkBackground2")
    static let logoBlue = UIColor(named: "logoBlue")
    static let logoBlueLighter = UIColor(named: "logoBlueLighter")
    static let navigation = UIColor(named: "navigation")
    static let primaryColor = UIColor(named: "primaryColor")
    static let secondaryColor = UIColor(named: "secondaryColor")
    static let textPrimary = UIColor(named: "textPrimary")
    static let textSecondary = UIColor(named: "textSecondary")
    static let textTertiary = UIColor(named: "textTertiary")
    
    /* Common Combinations of colors
        - These colors are combinations of individual colors
        - They are used for light and dark mode
        - There are two colors in a color name, the first one is for lightMode and the second one for darkMode
    */
    
    static let textPrimaryAndWhite = UIColor(named: "textPrimary+white")
    static let textTertiaryAndDarkBackground2 = UIColor(named: "textTertiary+darkBackground2")
    static let chatBackgroundAndDarkBackground2 = UIColor(named: "chatBackground+darkBackground2")
    static let whiteAndDarkBackground = UIColor(named: "white+darkBackground")
    static let whiteAndDarkBackground2 = UIColor(named: "white+darkBackground2")
    
}
