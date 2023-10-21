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
    static let appBlueLight = spikaColors().appBlueLight.uiColor
    static let appGreen = spikaColors().appGreen.uiColor
    static let appRed = spikaColors().appRed.uiColor
    static let appOrange = spikaColors().appOrange.uiColor
    static let primaryBackground = spikaColors().primaryBackground.uiColor
    static let borderColor = spikaColors().borderColor.uiColor
    static let chatBackground = spikaColors().chatBackground.uiColor
    static let secondaryBackground = spikaColors().secondaryBackground.uiColor
    static let myChatBackground = spikaColors().myChatBackground.uiColor
    static let primaryColor = spikaColors().primaryColor.uiColor
    static let textPrimary = spikaColors().textPrimary.uiColor
    static let textSecondary = spikaColors().textSecondary.uiColor
    static let textTertiary = spikaColors().textTertiary.uiColor
    
    // FIXME: change this
    static let errorRedLight = UIColor(named: "errorRedLight")
}
