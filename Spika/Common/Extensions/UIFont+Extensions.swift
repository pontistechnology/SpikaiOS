//
//  UIFont+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 17.10.2022..
//

import UIKit
import SwiftUI

extension UIFont {
    static func customFont(name: CustomFontName, size: CGFloat = 14) -> UIFont {
        let customFont = UIFont(name: name.rawValue, size: size) ?? .systemFont(ofSize: size)
        return UIFontMetrics.default.scaledFont(for: customFont)
    }
}

extension Font {
    static func customFont(_ fontName: CustomFontName, size: CGFloat) -> Font {
        .custom(fontName.rawValue, size: size)
    }
}
