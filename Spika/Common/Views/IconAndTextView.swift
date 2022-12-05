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
    
    init(messageType: MessageType, text: String?) {
        super.init(frame: .zero)
        
        addSubview(iconImageView)
        addSubview(textLabel)
        let textLeftPadding: CGFloat
        
        switch messageType {
        case .text:
            textLabel.text = text
            iconImageView.image = nil
            textLeftPadding = 0
        case .image:
            textLabel.text = "Photo message"
            iconImageView.image = .init(safeImage: .photoIcon)
            textLeftPadding = 16
        case .video:
            textLabel.text = "Video message"
            iconImageView.image = .init(safeImage: .videoIcon)
            textLeftPadding = 16
        case .audio:
            textLabel.text = "Audio message"
            iconImageView.image = .init(safeImage: .micIcon)
            textLeftPadding = 16
        default:
            textLabel.text = "Unknown message"
            iconImageView.image = .imageFor(mimeType: "unknown")
            textLeftPadding = 16
        }
        
        iconImageView.constrainWidth(12)
        iconImageView.constrainHeight(12)
        iconImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        textLabel.centerYToSuperview()
        textLabel.anchor(leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: textLeftPadding, bottom: 0, right: 2))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
