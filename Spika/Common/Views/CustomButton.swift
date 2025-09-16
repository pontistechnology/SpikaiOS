//
//  CustomButton.swift
//  Spika
//
//  Created by Vedran Vugrin on 01.02.2023..
//

import UIKit

class CustomButton: UIButton {
    
    init(text: String? = nil,
         imageResource: ImageResource? = nil,
         imageResourceTintColor: UIColor? = nil,
         textSize: CGFloat = 14,
         textColor: UIColor = .textPrimary,
         disabledTextColor: UIColor = .textSecondary,
         fontName: CustomFontName = .RobotoFlexRegular,
         alignment: UIControl.ContentHorizontalAlignment = .center) {
        super.init(frame: CGRectZero)
        self.setTitle(text, for: .normal)
        self.setTitleColor(textColor, for: .normal)
        self.setTitleColor(disabledTextColor, for: .disabled)
        self.titleLabel?.font = .customFont(name: fontName, size: textSize)
        self.contentHorizontalAlignment = alignment
        if let imageResource {
            if let imageResourceTintColor {
                self.setImage(.init(resource: imageResource).withTintColor(imageResourceTintColor, renderingMode: .alwaysOriginal), for: .normal)
            } else {
                self.setImage(.init(resource: imageResource), for: .normal)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
