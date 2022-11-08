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
    
    static func safeColor(named name: String) -> UIColor {
        return UIColor(named: name) ?? .clear
    }
}

extension UIColor {
    
    /* Common Individual colors
        - These are the colors that are defined in the Design as color styles
        - Sort it like in Assets folder
    */
    
    static let appBlueLight = safeColor(named: "appBlueLight")
    static let appGreen = safeColor(named: "appGreen")
    static let appRed = safeColor(named: "appRed")
    static let appOrange = safeColor(named: "appOrange")
    static let appWhite = safeColor(named: "appWhite")
    static let borderColor = safeColor(named: "borderColor")
    static let chatBackground = safeColor(named: "chatBackground")
    static let darkBackground = safeColor(named: "darkBackground")
    static let darkBackground2 = safeColor(named: "darkBackground2")
    static let logoBlue = safeColor(named: "logoBlue")
    static let logoBlueLighter = safeColor(named: "logoBlueLighter")
    static let navigation = safeColor(named: "navigation")
    static let primaryColor = safeColor(named: "primaryColor")
    static let secondaryColor = safeColor(named: "secondaryColor")
    static let textPrimary = safeColor(named: "textPrimary")
    static let textSecondary = safeColor(named: "textSecondary")
    static let textTertiary = safeColor(named: "textTertiary")
    
    /* Common Combinations of colors
        - These colors are combinations of individual colors
        - They are used for light and dark mode
        - There are two colors in a color name, the first one is for lightMode and the second one for darkMode
    */
    
    static let textPrimaryAndWhite = safeColor(named: "textPrimary+white")
    static let textTertiaryAndDarkBackground2 = safeColor(named: "textTertiary+darkBackground2")
    static let chatBackgroundAndDarkBackground2 = safeColor(named: "chatBackground+darkBackground2")
    static let whiteAndDarkBackground = safeColor(named: "white+darkBackground")
    static let whiteAndDarkBackground2 = safeColor(named: "white+darkBackground2")
    
    // Uncommon colors
    
    static let errorRedLight = safeColor(named: "errorRedLight")
    
}
