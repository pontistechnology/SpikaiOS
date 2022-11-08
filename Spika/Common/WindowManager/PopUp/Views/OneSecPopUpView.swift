//
//  OneSecPopUpView.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.11.2022..
//

import UIKit

class OneSecPopUpView: UIView {
    private let imageView: UIImageView
    private let descriptionLabel: CustomLabel
    
    init(type: OneSecPopUpType) {
        imageView = UIImageView(image: type.image)
        descriptionLabel = CustomLabel(text: type.description, textSize: 11, textColor: .textSecondary, fontName: .MontserratMedium, alignment: .center)
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OneSecPopUpView: BaseView {
    func addSubviews() {
        addSubview(imageView)
        addSubview(descriptionLabel)
    }
    
    func styleSubviews() {
        backgroundColor = .appWhite.withAlphaComponent(0.98)
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    func positionSubviews() {
        imageView.anchor(top: topAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0), size: CGSize(width: 33, height: 33))
        imageView.centerXToSuperview()
        
        descriptionLabel.anchor(top: imageView.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 8, left: 16, bottom: 12, right: 16))
    }
}
