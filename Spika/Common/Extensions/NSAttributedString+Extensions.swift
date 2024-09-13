//
//  NSAttributedString+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.02.2024..
//

import Foundation
import UIKit.UIFont

extension String {
    func bold(_ font: UIFont = .customFont(name: .RobotoFlexSemiBold, size: 14)) -> NSAttributedString {
        NSAttributedString(string: self, attributes: [.font: font])
    }
    
    var attributedString: NSMutableAttributedString {
        NSMutableAttributedString(string: self, attributes: [.font: UIFont.customFont(name: .RobotoFlexMedium, size: 14)])
    }
}

extension NSAttributedString {
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSMutableAttributedString {
        let result = NSMutableAttributedString(attributedString: lhs)
        result.append(rhs)
        return result
    }
}
