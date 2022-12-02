//
//  MessageReplyView.swift
//  Spika
//
//  Created by Nikola Barbarić on 29.11.2022..
//

import UIKit

class MessageReplyView: UIView {
    private let senderNameLabel: CustomLabel
    private let iconAndTextView: IconAndTextView
    private let thumbnailImageView = UIImageView()
    private let containerView = UIView()
    
    init(senderName: String, iconAndText: String, thumbnail: URL?) {
        senderNameLabel = CustomLabel(text: senderName, textSize: 9, textColor: .textPrimary, fontName: .MontserratMedium)
        iconAndTextView = IconAndTextView(icon: .imageFor(mimeType: "unknown"), text: "i")
        super.init(frame: .zero)
        thumbnailImageView.kf.setImage(with: thumbnail)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessageReplyView: BaseView {
    func addSubviews() {
        addSubview(containerView)
        containerView.addSubview(senderNameLabel)
        containerView.addSubview(iconAndTextView)
        containerView.addSubview(thumbnailImageView)
    }
    
    func styleSubviews() {
        thumbnailImageView.image = UIImage(safeImage: .chatBubble)
        thumbnailImageView.contentMode = .scaleAspectFill
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        containerView.backgroundColor = .green
    }
    
    func positionSubviews() {
        containerView.constrainHeight(54)
        containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 140).isActive = true
        containerView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 8, left: 10, bottom: 0, right: 10))
        
        senderNameLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: thumbnailImageView.leadingAnchor, padding: UIEdgeInsets(top: 10, left: 12, bottom: 0, right: 10))
        
        iconAndTextView.anchor(leading: senderNameLabel.leadingAnchor, bottom: containerView.bottomAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0))
        
        thumbnailImageView.anchor(top: containerView.topAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        thumbnailImageView.constrainWidth(44)
    }
}
