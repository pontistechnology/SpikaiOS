//
//  TextMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 05.03.2022..
//

import Foundation
import UIKit

class TextMessageTableViewCell: UITableViewCell, BaseView {
    
    enum TextReuseIdentifier : String {
        case myText = "TextMessageTableViewCell"
        case myTextAndReply = "TextMessageTableViewCell+Reply"
        case friendText = "FriendTextMessageTableViewCell"
        case friendTextAndReply = "FriendTextMessageTableViewCell+Reply"
    }
    
    let currentReuseIdentifier: TextReuseIdentifier?
    
    let containerView = UIView()
    let messageLabel = CustomLabel(text: "u cant see me", textSize: 14, textColor: .logoBlue)
    let messageStateView = MessageStateView(state: .waiting)
    let replyView = ReplyMessageView()
    let reactionImageView = UIImageView(image: UIImage(named: "reaction"))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        if let identifier = TextReuseIdentifier(rawValue: reuseIdentifier ?? "errrrrrorr") {
            currentReuseIdentifier = identifier
        } else {
            currentReuseIdentifier = nil
        }
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        guard let currentReuseIdentifier = currentReuseIdentifier else { return }
        
        contentView.addSubview(containerView)
        containerView.addSubview(messageLabel)
        
        switch currentReuseIdentifier {
        case .myText:
            contentView.addSubview(messageStateView)
        case .myTextAndReply:
            containerView.addSubview(replyView)
            contentView.addSubview(messageStateView)
        case .friendText:
            contentView.addSubview(reactionImageView)
            break
        case .friendTextAndReply:
            containerView.addSubview(replyView)
            contentView.addSubview(reactionImageView)
        }
    }
    
    func styleSubviews() {
        guard let currentReuseIdentifier = currentReuseIdentifier else {
            return
        }
        switch currentReuseIdentifier {
        case .myText:
            containerView.backgroundColor = UIColor(hexString: "C8EBFE") // ask nika for color
        case .myTextAndReply:
            containerView.backgroundColor = UIColor(hexString: "C8EBFE") // ask nika for color
        case .friendText:
            containerView.backgroundColor = .chatBackground
        case .friendTextAndReply:
            containerView.backgroundColor = .chatBackground
        }
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        messageLabel.numberOfLines = 0
    }
    
    func positionSubviews() {
        
        guard let currentReuseIdentifier = currentReuseIdentifier else {
            return
        }
        
        messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 256).isActive = true
        
        switch currentReuseIdentifier {
        case .myText:
            containerView.anchor(top: contentView.topAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20))
            
            messageLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
           
            messageStateView.anchor(top: containerView.bottomAnchor, bottom: contentView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0))
            
        case .myTextAndReply:
            containerView.anchor(top: contentView.topAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20))
            
            messageLabel.anchor(top: replyView.bottomAnchor,leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            
            replyView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))
            
            messageStateView.anchor(top: containerView.bottomAnchor, bottom: contentView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
            
        case .friendText:
            containerView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 4, right: 0))
            
            messageLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            
            reactionImageView.anchor(top: containerView.topAnchor, leading: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0), size: CGSize(width: 24, height: 24))
            
        case .friendTextAndReply:
            containerView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 4, right: 0))
            
            replyView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))
            
            messageLabel.anchor(top: replyView.bottomAnchor,leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            
            reactionImageView.anchor(top: containerView.topAnchor, leading: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0), size: CGSize(width: 24, height: 24))
        }
    }
    
    func updateCell(message: Message2, replyMessageTest: Message2? = nil) {
        guard let currentReuseIdentifier = currentReuseIdentifier else {
            return
        }
        messageLabel.text = message.messageBody.text
        
        switch currentReuseIdentifier {
        case .myText:
            break
        case .myTextAndReply:
            
//            replyView.updateReplyView(message: replyMessageTest ?? message)
            break
        case .friendText:
            break
        case .friendTextAndReply:
//            replyView.updateReplyView(message: replyMessageTest ?? message)
            break
        }
        
    }
    
}
