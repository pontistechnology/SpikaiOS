//
//  UIColor+Extensions.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

extension ColorResource {
    var uiColor: UIColor { UIColor(resource: self) }
}

extension [ColorResource] {
    var uiColors: [UIColor] { self.map { UIColor(resource: $0)} }
}

extension UIColor {
    private static func spikaColors() -> SpikaTheme.SpikaColors {
        let savedString = UserDefaults(suiteName: Constants.Networking.appGroupName)?.string(forKey: Constants.Database.selectedTheme) ?? "none"
        let selectedTheme: SpikaTheme = SpikaTheme(rawValue: savedString) ?? .darkMarine
        return selectedTheme.colors()
    }
    
    // MARK: - this is shortcut for use throughout the whole app
    static var _backgroundGradientColors: [UIColor] {
        spikaColors()._backgroundGradientColors.uiColors
    }
    static var primaryColor: UIColor {
        spikaColors()._primaryColor.uiColor
    }
    static var secondaryColor: UIColor {
        spikaColors()._secondaryColor.uiColor
    }
    static var tertiaryColor: UIColor {
        spikaColors()._tertiaryColor.uiColor
    }
    static var textPrimary: UIColor {
        spikaColors()._textPrimary.uiColor
    }
    static var textSecondary: UIColor {
        spikaColors()._textSecondary.uiColor
    }
    static var textTertiary: UIColor {
        spikaColors()._textTertiary.uiColor
    }
    static var additionalColor: UIColor {
        spikaColors()._additionalColor.uiColor
    }
    static var secondAdditionalColor: UIColor {
        spikaColors()._secondAdditionalColor.uiColor
    }
    static var thirdAdditionalColor: UIColor {
        spikaColors()._thirdAdditionalColor.uiColor
    }
    static var fourthAdditionalColor: UIColor {
        spikaColors()._fourthAdditionalColor.uiColor
    }
    static var warningColor: UIColor {
        spikaColors()._warningColor.uiColor
    }
    static var secondWarningColor: UIColor {
        spikaColors()._secondWarningColor.uiColor
    }
    
    static var checkWithDesign: UIColor {
        .green
    }
    
    // FIXME: change this
//    static let errorRedLight = UIColor(named: "errorRedLight")
}

import SwiftUI

extension Color {
    static func fromUIColor(_ uicolor: UIColor) -> Color {
        Color(uiColor: uicolor)
    }
}
