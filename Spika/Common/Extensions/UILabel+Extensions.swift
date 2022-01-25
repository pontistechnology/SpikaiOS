//
//  test+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 25.01.2022..
//

import Foundation
import UIKit

enum CustomFontName: String {
    case MontserratRegular = "Montserrat-Regular"
    case MontserratBold = "Montserrat-Bold"
    case MontserratBlack = "Montserrat-Black"
    case MontserratExtraBold = "Montserrat-ExtraBold"
    case MontserratExtraLight = "Montserrat-ExtraLight"
    case MontserratLight = "Montserrat-Light"
    case MontserratMedium = "Montserrat-Medium"
    case MontserratSemiBold = "Montserrat-SemiBold"
    case MontserratThin = "Montserrat-Thin"
}

extension UILabel {
    func customFont(name: CustomFontName, size: CGFloat = 14) {
        let customFont = UIFont(name: name.rawValue, size: size) ?? .systemFont(ofSize: size)
        self.font = UIFontMetrics.default.scaledFont(for: customFont)
        self.adjustsFontForContentSizeCategory = true
    }
}

extension UITextField {
    func customFont(name: CustomFontName, size: CGFloat = 14) {
        let customFont = UIFont(name: name.rawValue, size: size) ?? .systemFont(ofSize: size)
        self.font = UIFontMetrics.default.scaledFont(for: customFont)
        self.adjustsFontForContentSizeCategory = true
    }
}
