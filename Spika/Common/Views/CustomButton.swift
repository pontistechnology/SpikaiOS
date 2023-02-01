//
//  CustomButton.swift
//  Spika
//
//  Created by Vedran Vugrin on 01.02.2023..
//

import UIKit

class CustomButton: UIButton {
    
    init(text: String,
         textSize: CGFloat = 14,
         textColor: UIColor = .textPrimaryAndWhite,
         fontName: CustomFontName = .MontserratRegular,
         alignment: UIControl.ContentHorizontalAlignment = .center) {
        super.init(frame: CGRectZero)
        self.setTitle(text, for: .normal)
        self.setTitleColor(textColor, for: .normal)
        self.titleLabel?.font = .customFont(name: fontName, size: textSize)
        self.contentHorizontalAlignment = alignment
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
