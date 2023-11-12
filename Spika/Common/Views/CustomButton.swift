//
//  CustomButton.swift
//  Spika
//
//  Created by Vedran Vugrin on 01.02.2023..
//

import UIKit

class CustomButton: UIButton {
    
    init(text: String? = nil,
         assetName: ImageResource? = nil,
         textSize: CGFloat = 14,
         textColor: UIColor = .textPrimary,
         disabledTextColor: UIColor = .textSecondary,
         fontName: CustomFontName = .MontserratRegular,
         alignment: UIControl.ContentHorizontalAlignment = .center) {
        super.init(frame: CGRectZero)
        self.setTitle(text, for: .normal)
        self.setTitleColor(textColor, for: .normal)
        self.setTitleColor(disabledTextColor, for: .disabled)
        self.titleLabel?.font = .customFont(name: fontName, size: textSize)
        self.contentHorizontalAlignment = alignment
        if let assetName {
            self.setImage(.init(resource: assetName), for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
