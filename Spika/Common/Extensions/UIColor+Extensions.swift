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

extension UIColor {
    private static func spikaColors() -> SpikaTheme.SpikaColors {
        let savedString = UserDefaults(suiteName: Constants.Networking.appGroupName)?.string(forKey: Constants.Database.selectedTheme) ?? "none"
        let selectedTheme: SpikaTheme = SpikaTheme(rawValue: savedString) ?? .nika
        return selectedTheme.colors()
    }
    
    // MARK: - this is shortcut for use throughout the whole app
    static var appBlueLight: UIColor { spikaColors().appBlueLight.uiColor}
    static var appGreen: UIColor { spikaColors().appGreen.uiColor}
    static var appRed: UIColor { spikaColors().appRed.uiColor}
    static var appOrange: UIColor { spikaColors().appOrange.uiColor}
    static var primaryBackground: UIColor { spikaColors().primaryBackground.uiColor}
    static var borderColor: UIColor { spikaColors().borderColor.uiColor}
    static var chatBackground: UIColor { spikaColors().chatBackground.uiColor}
    static var secondaryBackground: UIColor { spikaColors().secondaryBackground.uiColor}
    static var myChatBackground: UIColor { spikaColors().myChatBackground.uiColor}
    static var primaryColor: UIColor { spikaColors().primaryColor.uiColor}
    static var textPrimary: UIColor { spikaColors().textPrimary.uiColor}
    static var textSecondary: UIColor { spikaColors().textSecondary.uiColor}
    static var textTertiary: UIColor { spikaColors().textTertiary.uiColor}
    
    // FIXME: change this
    static let errorRedLight = UIColor(named: "errorRedLight")
}
