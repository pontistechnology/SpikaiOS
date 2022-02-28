//
//  UITextView+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.02.2022..
//

import UIKit

extension UITextView {
    func numberOfLines() -> Int {
        let layoutManager = self.layoutManager
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var lineRange: NSRange = NSMakeRange(0, 1)
        var index = 0
        var numberOfLines = 0

        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(
                forGlyphAt: index, effectiveRange: &lineRange
            )
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        if String(self.text.last ?? "_") == "\n" {
            numberOfLines += 1
        }
        return numberOfLines
    }
    
    func customFont(name: CustomFontName, size: CGFloat = 14) {
        let customFont = UIFont(name: name.rawValue, size: size) ?? .systemFont(ofSize: size)
        self.font = UIFontMetrics.default.scaledFont(for: customFont)
        self.adjustsFontForContentSizeCategory = true
    }
}
