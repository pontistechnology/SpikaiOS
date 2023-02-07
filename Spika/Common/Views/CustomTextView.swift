//
//  CustomTextView.swift
//  Spika
//
//  Created by Nikola Barbarić on 17.10.2022..
//

import Foundation
import UIKit

class CustomTextView: UITextView {
    
    private var title: String
    private var titleSize: CGFloat
    private var titleColor: UIColor
    private var fontName: CustomFontName
    private var alignment: NSTextAlignment
    
    init(text: String, textSize: CGFloat = 14, textColor: UIColor = .textPrimary, fontName: CustomFontName = .MontserratRegular, alignment: NSTextAlignment = .natural) {
        self.title = text
        self.titleSize = textSize
        self.titleColor = textColor
        self.fontName = fontName
        self.alignment = alignment
        super.init(frame: .zero, textContainer: nil)
        setupTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomTextView {
    func setupTextView() {
        text = title
        isScrollEnabled = false
        backgroundColor = .clear
        font = .customFont(name: fontName, size: titleSize)
        textColor = titleColor
        linkTextAttributes = [.foregroundColor: UIColor.link, .underlineColor: UIColor.link]
        isEditable = false
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        dataDetectorTypes = [.link, .phoneNumber]
    }
}
