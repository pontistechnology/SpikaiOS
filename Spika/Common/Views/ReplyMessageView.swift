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
    
    private let quotedMessage: MessageTest
        
    init(message: MessageTest) {
        quotedMessage = message
        super.init(frame: .zero)
        setupView()
        updateReplyView(message: quotedMessage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(senderNameLabel)
        
        switch quotedMessage.messageType {
        case .photo, .voice, .video, .text:
            addSubview(leftImageView)
            addSubview(messageLabel)
        case .text:
            addSubview(messageLabel)
        }
    }
    
    func styleSubviews() {
        backgroundColor = UIColor(hexString: "C8EB0A") // ask nika for color
        layer.cornerRadius = 10
        layer.masksToBounds = true
        leftImageView.backgroundColor = .white
        leftImageView.contentMode = .scaleAspectFit
        leftImageView.layer.cornerRadius = 4
        leftImageView.layer.masksToBounds = true
        
        senderNameLabel.text = quotedMessage.senderName

        switch quotedMessage.messageType {
        case .video, .photo, .voice, .text:
            messageLabel.text = "Media message"
            leftImageView.image = UIImage(systemName: "textformat")
        case .text:
            messageLabel.text = quotedMessage.textOfMessage
            messageLabel.numberOfLines = 2
        }
    }
    
    func positionSubviews() {
        constrainHeight(ReplyMessageView.replyMessageViewHeight)
        constrainWidth(ReplyMessageView.replyMessageViewWidth)

        switch quotedMessage.messageType {
    
        case .photo, .video, .voice, .text:
            leftImageView.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0), size: CGSize(width: 18, height: 32))
            leftImageView.centerYToSuperview()
            
            senderNameLabel.anchor(top: topAnchor, leading: leftImageView.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 5, bottom: 0, right: 10))
            
            messageLabel.anchor(top: senderNameLabel.bottomAnchor, leading: leftImageView.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 10))
        
        case .text:
            senderNameLabel.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 12, bottom: 0, right: 10))
            
            messageLabel.anchor(top: senderNameLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 5, left: 12, bottom: 0, right: 10))
        }
    }
    
    func updateReplyView(message: MessageTest) {
        senderNameLabel.text = message.senderName
        
        switch message.messageType {
        case .text:
            leftImageView.image = UIImage(systemName: "textformat")
            messageLabel.text = message.textOfMessage
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
