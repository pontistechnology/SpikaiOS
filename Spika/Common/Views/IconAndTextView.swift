//
//  IconAndTextView.swift
//  Spika
//
//  Created by Nikola Barbarić on 29.11.2022..
//

import UIKit

final class IconAndTextView: UIView {
    private let iconImageView = UIImageView()
    private let textLabel = CustomLabel(text: "", textSize: 9, textColor: .logoBlue, fontName: .MontserratMedium)
    
    init(icon: UIImage?, text: String) {
        super.init(frame: .zero)
        
        addSubview(iconImageView)
        addSubview(textLabel)
        
        textLabel.text = text
        iconImageView.image = icon
        
        iconImageView.constrainWidth(12)
        iconImageView.constrainHeight(12)
        iconImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        textLabel.centerYToSuperview()
        textLabel.anchor(leading: iconImageView.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 2))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
