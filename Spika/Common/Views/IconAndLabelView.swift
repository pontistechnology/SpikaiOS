//
//  IconAndLabelView.swift
//  Spika
//
//  Created by Nikola Barbarić on 29.11.2022..
//

import UIKit

final class IconAndLabelView: UIView {
    private let iconImageView = UIImageView()
    private let textLabel = CustomLabel(text: "", textSize: 11, textColor: .textPrimary, fontName: .MontserratMedium)
    private let messageType: MessageType
    private let text: String?
    
    init(messageType: MessageType, text: String?) {
        self.messageType = messageType
        self.text = text
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension IconAndLabelView: BaseView {
    func addSubviews() {
        addSubview(iconImageView)
        addSubview(textLabel)
    }
    
    func styleSubviews() {
        switch messageType {
        case .text:
            textLabel.text = text
            textLabel.numberOfLines = 3
            iconImageView.image = nil
        case .image:
            textLabel.text = .getStringFor(.photoMessage)
        case .video:
            textLabel.text = .getStringFor(.videoMessage)
        case .audio:
            textLabel.text = .getStringFor(.audioMessage)
        case .file:
            textLabel.text = .getStringFor(.fileMessage)
        default:
            textLabel.text = .getStringFor(.unknownMessage)
        }
        iconImageView.image = messageType.icon
    }
    
    func positionSubviews() {
        let textLeftPadding: CGFloat
        switch messageType {
        case .text:
            textLeftPadding = 0
        default:
            textLeftPadding = 16
        }
        iconImageView.constrainWidth(12)
//        iconImageView.constrainHeight(12)
        iconImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
//        textLabel.centerYToSuperview()
//        textLabel.anchor(leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: textLeftPadding, bottom: 0, right: 2))
        
        textLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: textLeftPadding, bottom: 0, right: 0))
    }
}
