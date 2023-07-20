//
//  CustomLabel.swift
//  Spika
//
//  Created by Nikola Barbarić on 25.01.2022..
//

import Foundation
import UIKit

class CustomLabel: UILabel {
    
    private var title: String
    private var titleSize: CGFloat
    private var titleColor: UIColor
    private var fontName: CustomFontName
    private var alignment: NSTextAlignment
    
    init(text: String, textSize: CGFloat = 14, textColor: UIColor = .textPrimary,
         fontName: CustomFontName = .MontserratRegular, alignment: NSTextAlignment = .natural) {
        self.title = text
        self.titleSize = textSize
        self.titleColor = textColor
        self.fontName = fontName
        self.alignment = alignment
        super.init(frame: .zero)
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabel() {
        text = title
        textAlignment = alignment
        textColor = titleColor
        font = .customFont(name: fontName, size: titleSize)
    }
    
    func setText(text: String) {
        self.title = text
        self.text = text
    }
    
}
