//
//  ReplyMessageView.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.03.2022..
//

import Foundation
import UIKit

class ReplyMessageView: UIView, BaseView {
    
    static let replyMessageViewHeight = 54.0
    static let replyMessageViewWidth  = 140.0
    
    private let senderNameLabel = CustomLabel(text: "", textSize: 9, textColor: .logoBlue, fontName: .MontserratSemiBold)
    private let messageLabel = CustomLabel(text: "", textSize: 9, textColor: .logoBlue, fontName: .MontserratMedium)
    private let leftImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(senderNameLabel)
        addSubview(leftImageView)
        addSubview(messageLabel)
    }
    
    func styleSubviews() {
        backgroundColor = UIColor(hexString: "C8EB0A") // ask nika for color
        layer.cornerRadius = 10
        layer.masksToBounds = true
        leftImageView.backgroundColor = .white
        leftImageView.contentMode = .scaleAspectFit
        leftImageView.layer.cornerRadius = 4
        leftImageView.layer.masksToBounds = true
        
        senderNameLabel.text = "Nemam ime"

        messageLabel.text = "Default text"
        leftImageView.image = UIImage(systemName: "textformat")
    }
    
    func positionSubviews() {
        constrainHeight(ReplyMessageView.replyMessageViewHeight)
        constrainWidth(ReplyMessageView.replyMessageViewWidth)

        leftImageView.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0), size: CGSize(width: 18, height: 32))
        leftImageView.centerYToSuperview()
            
        senderNameLabel.anchor(top: topAnchor, leading: leftImageView.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 5, bottom: 0, right: 10))
            
        messageLabel.anchor(top: senderNameLabel.bottomAnchor, leading: leftImageView.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 10))
    }
    
    func updateReplyView(message: Message) {
        senderNameLabel.text = "user with id: \(message.id)"
        
        guard let messageType = MessageType(rawValue: message.type) else { return }
        
        switch messageType {
        case .text:
            leftImageView.image = UIImage(systemName: "textformat")
            messageLabel.text = message.body.text
        case .photo:
            leftImageView.image = UIImage(systemName: "photo")
            messageLabel.text = "Photo message"
        case .video:
            leftImageView.image = UIImage(systemName: "video")
            messageLabel.text = "Video message"
        case .voice:
            leftImageView.image = UIImage(systemName: "music.note")
            messageLabel.text = "Voice message"
        }
    }
}
