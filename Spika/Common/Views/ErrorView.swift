//
//  ErrorView.swift
//  Spika
//
//  Created by Marko on 27.10.2021..
//

import UIKit

class ErrorView: UIView, BaseView {
    
    private let message: String
    private let errorImage: UIImage
    
    private let errorImageView = UIImageView()
    private let errorLabel = CustomLabel(text: "", textSize: 13, textColor: .warningColor, fontName: .MontserratMedium)
    
    init(message: String, errorImage: UIImage = UIImage(safeImage: .error)) {
        self.message = message
        self.errorImage = errorImage
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(errorImageView)
        addSubview(errorLabel)
    }
    
    func styleSubviews() {
        self.layer.cornerRadius = 10
        self.backgroundColor = .secondWarningColor
        
        errorLabel.numberOfLines = 1
        errorLabel.text = message
        
        errorImageView.image = errorImage
    }
    
    func positionSubviews() {
        self.constrainHeight(35)
        
        errorImageView.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), size: CGSize(width: 20, height: 20))
        errorImageView.centerY(inView: self)
        
        errorLabel.anchor(leading: errorImageView.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        errorLabel.centerY(inView: self)
    }
    
}
