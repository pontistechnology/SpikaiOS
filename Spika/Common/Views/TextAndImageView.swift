//
//  TextAndImageView.swift
//  Spika
//
//  Created by Vedran Vugrin on 02.02.2023..
//

import UIKit

final class TextAndImageView: CustomStackView {
    
    let label = CustomLabel(text: "", textSize: 14, fontName: .MontserratLight, alignment: .right)
    let imageView = UIImageView()
    
    init() {
        super.init(axis: .horizontal, distribution: .fill, alignment: .fill, spacing: 10)
        self.addArrangedSubview(label)
        self.addArrangedSubview(imageView)
        imageView.contentMode = .center
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

final class ContactsCellRightView: CustomStackView {
    
    let firstRow = TextAndImageView()
    let secondRow = TextAndImageView()
    
    init() {
        super.init(axis: .vertical, distribution: .equalSpacing, alignment: .fill, spacing: 6)
        self.addArrangedSubview(firstRow)
        self.addArrangedSubview(secondRow)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
