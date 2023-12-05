//
//  MessageReplyView.swift
//  Spika
//
//  Created by Nikola Barbarić on 29.11.2022..
//

import UIKit

class MessageReplyView2: UIView {
    let outSideView = UIStackView() // needed to enable corner radius
    private let thumbnailImageView = UIImageView()
    private let senderNameLabel: CustomLabel
    private var showCloseButton = false
    private let bubbleHStack = UIStackView()
    private let leftVStack = UIStackView()
    private let descriptionHStack = UIStackView()
    let closeButton = UIButton()
    private let photoAndText: IconAndLabelView2
    
    init(senderName: String, message: Message, isInMyMessage: Bool, showCloseButton: Bool) {
        self.showCloseButton = showCloseButton
        senderNameLabel = CustomLabel(text: senderName, textSize: 14, textColor: .textPrimary, fontName: .MontserratSemiBold)
        photoAndText = IconAndLabelView2(messageType: message.type,
                                         text: message.body?.text)
        super.init(frame: .zero)
        addSubview(outSideView)
        outSideView.fillSuperview(padding: .init(top: 10, left: 10, bottom: 0, right: 10))
        outSideView.layer.cornerRadius = 15
        outSideView.layer.masksToBounds = true
        outSideView.layer.maskedCorners = isInMyMessage ? .allButBottomLeft : .allButBottomRight
        
        outSideView.addArrangedSubview(bubbleHStack)
        outSideView.addArrangedSubview(closeButton)
        bubbleHStack.addArrangedSubview(leftVStack)
        bubbleHStack.addArrangedSubview(thumbnailImageView)
        leftVStack.addArrangedSubview(senderNameLabel)
        leftVStack.addArrangedSubview(photoAndText)
        
        bubbleHStack.backgroundColor = isInMyMessage ? .secondaryColor : .primaryColor
        closeButton.setImage(UIImage(resource: .rDx).withTintColor(.tertiaryColor), for: .normal)
        closeButton.tintColor = .tertiaryColor
        thumbnailImageView.kf.setImage(with: message.body?.thumb?.id?.fullFilePathFromId())
        
        outSideView.axis = .horizontal
        outSideView.distribution = .fill
        bubbleHStack.axis = .horizontal
        bubbleHStack.alignment = .center
        leftVStack.axis = .vertical

        leftVStack.isLayoutMarginsRelativeArrangement = true
        leftVStack.directionalLayoutMargins = .init(top: 10, leading: 16, bottom: 10, trailing: 16)
        thumbnailImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        thumbnailImageView.constrainWidth(40)
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.isHidden = message.type == .text
        closeButton.isHidden = !showCloseButton
        closeButton.constrainWidth(48)
        closeButton.contentHorizontalAlignment = .right
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//
//class MessageReplyView: UIView {
//    private let senderNameLabel: CustomLabel
//    private let iconAndTextView: IconAndLabelView
//    private let thumbnailImageView = UIImageView()
//    let containerView = UIView()
//    let closeButton = UIButton()
//    private var showCloseButton = false
//    // TODO: - refactor
//    init(senderName: String, message: Message, backgroundColor: UIColor, showCloseButton: Bool = false) {
//        self.showCloseButton = showCloseButton
////        containerView.backgroundColor = backgroundColor
//        senderNameLabel = CustomLabel(text: senderName, textSize: 12, textColor: .textPrimary, fontName: .MontserratSemiBold)
//        iconAndTextView = IconAndLabelView(messageType: message.type, text: message.body?.text)
//        super.init(frame: .zero)
//        thumbnailImageView.kf.setImage(with: message.body?.thumb?.id?.fullFilePathFromId())
//        setupView()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//extension MessageReplyView: BaseView {
//    func addSubviews() {
//        addSubview(containerView)
//        containerView.addSubview(senderNameLabel)
//        containerView.addSubview(iconAndTextView)
//        containerView.addSubview(thumbnailImageView)
//        
//        if showCloseButton {
//            addSubview(closeButton)
//        }
//    }
//    
//    func styleSubviews() {
//        thumbnailImageView.contentMode = .scaleAspectFill
//        thumbnailImageView.clipsToBounds = true
//        containerView.layer.cornerRadius = 10
//        containerView.clipsToBounds = true
//        closeButton.setImage(UIImage(resource: .rDx).withTintColor(.tertiaryColor, renderingMode: .alwaysOriginal), for: .normal)
//    }
//    
//    func positionSubviews() {
//        
//        containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 140).isActive = true
//        containerView.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 8, left: 10, bottom: 0, right: 0))
//        
//        let aaa = containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
//        aaa.priority = .defaultLow // This is needed because reply will be reused in cells
//        aaa.isActive = true
//        
//        senderNameLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: thumbnailImageView.leadingAnchor, padding: UIEdgeInsets(top: 10, left: 12, bottom: 0, right: 10))
//        
//        iconAndTextView.anchor(top: senderNameLabel.bottomAnchor, leading: senderNameLabel.leadingAnchor, bottom: containerView.bottomAnchor, trailing: thumbnailImageView.leadingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 12, right: 4))
//        
//        thumbnailImageView.anchor(trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
//        thumbnailImageView.constrainWidth(44)
//        thumbnailImageView.constrainHeight(54)
//        thumbnailImageView.centerYToSuperview()
//        
//        if showCloseButton {
//            containerView.anchor(trailing: closeButton.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 160))
//            closeButton.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 15), size: CGSize(width: 24, height: 24))
//        } else {
//            containerView.anchor(trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
//        }
//    }
//}
