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
            
            print(layoutManager.lineFragmentRect(
                forGlyphAt: index, effectiveRange: &lineRange
            ))
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        return numberOfLines
    }
}
