//
//  PlainTextView.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.11.2022..
//

import UIKit

class MessageTextView: UIView {
    let textView = CustomTextView(text: "", textSize: 14, textColor: .logoBlue, fontName: .MontserratMedium)
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessageTextView: BaseView {
    func addSubviews() {
        addSubview(textView)
    }
    
    func styleSubviews() {
        
    }
    
    func positionSubviews() {
        textView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}

extension MessageTextView {
    func setup(text: String?, color: UIColor = .logoBlue) {
        textView.text = text
        textView.textColor = color
    }
    
    func reset() {
        textView.text = nil
    }
}
