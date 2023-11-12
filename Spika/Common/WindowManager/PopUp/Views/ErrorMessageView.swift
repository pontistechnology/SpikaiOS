//
//  OnlyMessageView.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.11.2022..
//

import UIKit

class ErrorMessageView: UIView {
    private let errorLabel: CustomLabel
    private let errorImageView = UIImageView(image: UIImage(resource: .error))
    
    init(message: String) {
        errorLabel = CustomLabel(text: message, textSize: 13, textColor: .warningColor, fontName: .MontserratMedium, alignment: .natural)
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ErrorMessageView: BaseView {
    func addSubviews() {
        addSubview(errorLabel)
        addSubview(errorImageView)
    }
    
    func styleSubviews() {
        backgroundColor = .secondWarningColor
        layer.cornerRadius = 10
        layer.masksToBounds = true
        errorLabel.numberOfLines = 0
    }
    
    func positionSubviews() {
        constrainWidth(376)
        errorImageView.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0), size: CGSize(width: 20, height: 20))
        errorImageView.centerYToSuperview()
        
        errorLabel.anchor(top: topAnchor, leading: errorImageView.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}
