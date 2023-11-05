//
//  TableViewHeader.swift
//  Spika
//
//  Created by Vedran Vugrin on 25.10.2022..
//

import UIKit

final class CustomTableViewHeader: UIView, BaseView {
    
    let mainLabel: CustomLabel
    let labelMargins: UIEdgeInsets
    
    init(text: String,
         textSize: CGFloat = 14,
         textColor: UIColor = .textPrimary,
         fontName: CustomFontName = .MontserratRegular,
         alignment: NSTextAlignment = .natural,
         labelMargins: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)) {
        self.mainLabel = CustomLabel(text: text, textSize: textSize, textColor: textColor, fontName: fontName, alignment: alignment)
        self.labelMargins = labelMargins
        super.init(frame: CGRectZero)
        self.setupView()
    }
    
    func addSubviews() {
        self.addSubview(self.mainLabel)
    }
    
    func styleSubviews() {
        self.backgroundColor = ._additionalColor // TODO: - check clear
    }
    
    func positionSubviews() {
        mainLabel.fillSuperview(padding: self.labelMargins)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
