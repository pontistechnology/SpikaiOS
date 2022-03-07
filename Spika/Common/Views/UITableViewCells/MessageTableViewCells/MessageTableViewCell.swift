//
//  MessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.02.2022..
//

import Foundation
import Combine
import UIKit

class MessageTableViewCell: UITableViewCell, BaseView {
    
    static let reuseIdentifier = "MessageTableViewCell"
    static let seenViewHeight  = 20.0
    static let textPadding = 20.0
    static let textMaximumWidth  = 256.0
    static let portraitMediaHeight = 240.0
    static let landscapeMediaHeight = 140.0
    static let replyViewPadding = 20.0
    static let defaultTextFont = UIFont(name: CustomFontName.MontserratMedium.rawValue, size: 14)
    
    private let containerView = UIView()
    private var replyView: ReplyMessageView?
    private var messageStateView = MessageStateView(state: .waiting)
    
    private var containerViewWidthConstraint = NSLayoutConstraint()
    private var containerViewHeightConstraint = NSLayoutConstraint()
    
    let messageLabel = CustomLabel(text: " ")
    let mediaImageView = UIImageView(image: UIImage(named: "leaf"))
    let voiceMessageView = VoiceMessageView(duration: 123)
    
    var replyId: Int?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(containerView)
        addSubview(messageStateView)
    }
    
    func styleSubviews() {
        
        contentView.backgroundColor = .yellow
        
        containerView.backgroundColor = UIColor(hexString: "C8EBFE") // TODO: ask nika for color
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
        messageLabel.numberOfLines = 0
    }
        
    func positionSubviews() {
        
        containerView.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20))
        containerViewWidthConstraint  = containerView.widthAnchor.constraint(equalToConstant: 80)
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 80)
        containerViewHeightConstraint.priority = .defaultLow
        containerViewWidthConstraint.isActive  = true
        containerViewHeightConstraint.isActive = true

        messageStateView.anchor(top: containerView.bottomAnchor, bottom: bottomAnchor,  trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0))
    }
    
    
    private func updateContainerViewDimensions(width: CGFloat, height: CGFloat) {
        containerViewWidthConstraint.constant = width > 276 ? 276 : width
        containerViewHeightConstraint.constant = height
    }
    
    private func addMessageLabel() {
        containerView.addSubview(messageLabel)
        messageLabel.anchor(leading: containerView.leadingAnchor,
                            bottom: containerView.bottomAnchor,
                            trailing: containerView.trailingAnchor,
                            padding: UIEdgeInsets(top: 0,
                                                  left: MessageTableViewCell.textPadding / 2,
                                                  bottom: MessageTableViewCell.textPadding / 2,
                                                  right: MessageTableViewCell.textPadding / 2))
    }
    
    private func addMediaView() {
        containerView.addSubview(mediaImageView)
        mediaImageView.anchor(leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 2, bottom: 2, right: 2))
        mediaImageView.constrainHeight(MessageTableViewCell.portraitMediaHeight)
    }
    
    private func addVoiceMessageView() {
        containerView.addSubview(voiceMessageView)
        voiceMessageView.anchor(leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        voiceMessageView.constrainHeight(VoiceMessageView.voiceMessageHeight)
    }
    
    private func addReplyView() {
        guard let replyView = replyView else {
            print("GUARD: ReplyView doesn't exist.")
            return
        }
        containerView.addSubview(replyView)
        replyView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0))
    }
    
    //TEST
    func testUpdate(message: MessageTest, replyMessage: MessageTest? = nil) {
        
        guard let font = MessageTableViewCell.defaultTextFont else {
            print("Font is missing.")
            return
        }
        
        switch message.messageType {
        case .text:
            guard let textOfMessage = message.textOfMessage else {
                print("GUARD: TextOfMessage is missing.")
                return
            }
            let messageSize = textOfMessage.idealSizeForMessage(font: font, maximumWidth: MessageTableViewCell.textMaximumWidth)
            
            if let replyMessage = replyMessage {
                updateContainerViewDimensions(width: MessageTableViewCell.textPadding + (messageSize.width < ReplyMessageView.replyMessageViewWidth
                                                                                         ? ReplyMessageView.replyMessageViewWidth
                                                                                         : messageSize.width),
                                              height: messageSize.height + MessageTableViewCell.textPadding / 2 + ReplyMessageView.replyMessageViewHeight + MessageTableViewCell.replyViewPadding)
                replyId = message.replyMessageId
                replyView = ReplyMessageView(message: replyMessage)
                addReplyView()
            } else {
                updateContainerViewDimensions(width: messageSize.width + MessageTableViewCell.textPadding,
                                              height: messageSize.height + MessageTableViewCell.textPadding)
            }
        
            messageLabel.text = textOfMessage
            addMessageLabel()
            
        case .photo, .video:
            if let replyMessage = replyMessage {
                updateContainerViewDimensions(width: 160, height: MessageTableViewCell.portraitMediaHeight + ReplyMessageView.replyMessageViewHeight + MessageTableViewCell.replyViewPadding)
                replyId = message.replyMessageId
                replyView = ReplyMessageView(message: replyMessage)
                addReplyView()
            } else {
                updateContainerViewDimensions(width: 160, height: 240)
            }
            
            addMediaView()
        case .voice:
            
            if let replyMessage = replyMessage {
                updateContainerViewDimensions(width: 240, height: 50 + ReplyMessageView.replyMessageViewHeight + MessageTableViewCell.replyViewPadding)
                replyId = message.replyMessageId
                replyView = ReplyMessageView(message: replyMessage)
                addReplyView()
            } else {
                updateContainerViewDimensions(width: 240, height: 50)
            }
            addVoiceMessageView()
        }
    }
    
    override func prepareForReuse() {
        replyView?.removeFromSuperview()
        mediaImageView.removeFromSuperview()
        messageLabel.removeFromSuperview()
        voiceMessageView.removeFromSuperview()
        
        replyView = nil
        replyId = nil
        messageLabel.text = ""
        super.prepareForReuse()
    }
}
