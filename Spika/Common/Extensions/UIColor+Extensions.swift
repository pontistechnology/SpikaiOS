//
//  UIColor+Extensions.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

public extension UIColor {
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
    static let myChatBackground = safeColor(named: "myChatBackground")
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
    static let askNika = safeColor(named: "askNika")
    
    /* Common Combinations of colors
        - These colors are combinations of individual colors
        - They are used for light and dark mode
        - There are two colors in a color name, the first one is for lightMode and the second one for darkMode
    */
    
//    static let textPrimaryAndWhite = safeColor(named: "textPrimary+white")
//    static let textTertiaryAndDarkBackground2 = safeColor(named: "textTertiary+darkBackground2")
//    static let chatBackgroundAndDarkBackground2 = safeColor(named: "chatBackground+darkBackground2")
//    static let whiteAndDarkBackground = safeColor(named: "white+darkBackground")
//    static let whiteAndDarkBackground2 = safeColor(named: "white+darkBackground2")
    
    // Uncommon colors
    
    static let errorRedLight = safeColor(named: "errorRedLight")
    
}
