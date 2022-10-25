//
//  TableViewHeader.swift
//  Spika
//
//  Created by Vedran Vugrin on 25.10.2022..
//

import UIKit

final class CustomTableViewHeader: UIView, BaseView {
    
    let mainLabel: CustomLabel
    
    init(text: String,
         textSize: CGFloat = 14,
         textColor: UIColor = .textPrimaryAndWhite,
         fontName: CustomFontName = .MontserratRegular,
         alignment: NSTextAlignment = .natural) {
        self.mainLabel = CustomLabel(text: text, textSize: textSize, textColor: textColor, fontName: fontName, alignment: alignment)
        super.init(frame: CGRectZero)
    }
    
    func addSubviews() {
        self.addSubview(self.mainLabel)
    }
    
    func styleSubviews() {}
    
    func positionSubviews() {}
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
