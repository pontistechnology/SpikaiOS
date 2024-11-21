//
//  MessageFileView.swift
//  Spika
//
//  Created by Nikola Barbarić on 29.11.2022..
//

import UIKit

class MessageFileView: UIView {
    
    private let iconImageView = UIImageView()
    private let nameLabel = CustomLabel(text: "-", textSize: 14, textColor: .textPrimary, fontName: .RobotoFlexSemiBold, alignment: .left)
    private let sizeLabel = CustomLabel(text: "", textSize: 12, textColor: .textPrimary, fontName: .RobotoFlexRegular)
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessageFileView: BaseView {
    func addSubviews() {
        addSubview(iconImageView)
        addSubview(nameLabel)
        addSubview(sizeLabel)
    }
    
    func styleSubviews() {
        nameLabel.lineBreakMode = .byTruncatingMiddle
    }
    
    func positionSubviews() {
        iconImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 20, left: 12, bottom: 20, right: 0), size: CGSize(width: 18, height: 18))

        nameLabel.anchor(leading: iconImageView.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 12, bottom: 0, right: 12))
        nameLabel.centerYToSuperview(offset: -8)
        
        sizeLabel.anchor(leading: nameLabel.leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 2, left: 0, bottom: 10, right: 12))
        sizeLabel.centerYToSuperview(offset: 8)
    }
}

extension MessageFileView {
    func setup(icon: UIImage, name: String, size: String) {
        iconImageView.image = icon
        nameLabel.text = name
        sizeLabel.text = size
    }
    
    func reset() {
        nameLabel.text = nil
        sizeLabel.text = nil
        iconImageView.image = nil
    }
}
