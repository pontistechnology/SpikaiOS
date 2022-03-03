//
//  MessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.02.2022..
//

import Foundation
import Combine
import UIKit

protocol MessageTableViewCellDelegate: AnyObject {
    func messageTableViewCell(didPressOnReplyView: Bool)
}

class MessageTableViewCell: UITableViewCell, BaseView {
    
    static let reuseIdentifier = "MessageTableViewCell"
    
    private let containerView = UIView()
    private var replyView: ReplyMessageView?
    
    private var containerViewWidthConstraint = NSLayoutConstraint()
    private var containerViewHeightConstraint = NSLayoutConstraint()
    
    var messageLabel = CustomLabel(text: " ")
    var replyId: Int?
    weak var delegate: MessageTableViewCellDelegate?
    var subs = Set<AnyCancellable>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(containerView)
        containerView.addSubview(messageLabel)
    }
    
    func styleSubviews() {
        containerView.backgroundColor = UIColor(hexString: "C8EBFE") // TODO: ask nika for color
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
        messageLabel.numberOfLines = 0
    }
        
    func positionSubviews() {
        
        containerView.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20))
        containerViewWidthConstraint = containerView.widthAnchor.constraint(equalToConstant: 20)
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 20)
        containerViewWidthConstraint.isActive = true
        containerViewHeightConstraint.isActive = true
        
        messageLabel.anchor(leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    func setupBindings() {
        replyView?.tap().sink(receiveValue: { _ in
            print("kliknuoooo")
        }).store(in: &subs)
    }
    
    func updateCell(message: MessageTest) {
        
        guard let font = UIFont(name: CustomFontName.MontserratMedium.rawValue, size: 14) else {
            return
        }
        let messageSize = message.textOfMessage!.idealSizeForMessage(font: font, maximumWidth: 256)
        messageLabel.text = message.textOfMessage
        
        containerViewWidthConstraint.constant = messageSize.width + 20
        containerViewHeightConstraint.constant = messageSize.height + 20
    }
    
    func updateCell(message: MessageTest, replyMessage: MessageTest) {
        guard let font = UIFont(name: CustomFontName.MontserratMedium.rawValue, size: 14) else {
            return
        }
        
        replyId = message.replyMessageId
        let messageSize = message.textOfMessage!.idealSizeForMessage(font: font, maximumWidth: 256)
        messageLabel.text = message.textOfMessage
        
        containerViewWidthConstraint.constant = messageSize.width < ReplyMessageView.replyMessageViewWidth ? ReplyMessageView.replyMessageViewWidth + 20 : messageSize.width + 20
        containerViewHeightConstraint.constant = messageSize.height + 20 + 54 + 10
        
        replyView = ReplyMessageView(message: replyMessage)
        addSubview(replyView!)
        replyView!.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, padding: UIEdgeInsets(top: 8, left: 10, bottom: 0, right: 0))
        
    }
    
    override func prepareForReuse() {
        replyView?.removeFromSuperview()
        replyView = nil
        replyId = nil
        messageLabel.text = ""
        super.prepareForReuse()
    }
}
