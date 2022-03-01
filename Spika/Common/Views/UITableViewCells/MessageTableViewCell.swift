//
//  MessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 28.02.2022..
//

import Foundation
import UIKit

class MessageTableViewCell: UITableViewCell, BaseView {
    
    static let reuseIdentifier = "MessageTableViewCell"
    
    private let containerView = UIView()
    private let replyView = UIView()
    
    private var containerViewWidthConstraint = NSLayoutConstraint()
    private var containerViewHeightConstraint = NSLayoutConstraint()
    
    var messageLabel = CustomLabel(text: " ")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(containerView)
        containerView.addSubview(replyView)
        containerView.addSubview(messageLabel)
    }
    
    func styleSubviews() {
        containerView.backgroundColor = UIColor(hexString: "C8EBFE") // TODO: ask nika for color
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
        replyView.backgroundColor = .chatBackground
        
        messageLabel.numberOfLines = 0
    }
        
    func positionSubviews() {
        
        containerView.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20))
        containerViewWidthConstraint = containerView.widthAnchor.constraint(equalToConstant: 20)
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 20)
        containerViewWidthConstraint.isActive = true
        containerViewHeightConstraint.isActive = true
        
        replyView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 10, bottom: 0, right: 10))
        replyView.constrainHeight(54)
        
        messageLabel.anchor(leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    func updateCell(text: String) {
        guard let font = UIFont(name: CustomFontName.MontserratMedium.rawValue, size: 14) else {
            return
        }
        let messageSize = text.idealSizeForMessage(font: font, maximumWidth: 256)
        
        messageLabel.text = text
        containerViewWidthConstraint.constant = messageSize.width + 20
        containerViewHeightConstraint.constant = messageSize.height + 20 + 54 + 10
        
    }
    
    func hideReply() {
        replyView.removeFromSuperview()
    }
}
