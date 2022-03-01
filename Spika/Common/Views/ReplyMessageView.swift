//
//  ReplyMessageView.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.03.2022..
//

import Foundation
import UIKit

class ReplyMessageView: UIView, BaseView {
    
    private let senderNameLabel: CustomLabel
    private let messageLabel: CustomLabel
    
    init(senderName: String, message: String) {
        senderNameLabel = CustomLabel(text: senderName, textSize: 9, textColor: .logoBlue, fontName: .MontserratSemiBold)
        messageLabel =  CustomLabel(text: message, textSize: 9, textColor: .logoBlue, fontName: .MontserratMedium)
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(senderNameLabel)
        addSubview(messageLabel)
    }
    
    func styleSubviews() {
        backgroundColor = .chatBackground
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    func positionSubviews() {
        senderNameLabel.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 12, bottom: 0, right: 10))
        
        messageLabel.anchor(top: senderNameLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 10))
    }
}
