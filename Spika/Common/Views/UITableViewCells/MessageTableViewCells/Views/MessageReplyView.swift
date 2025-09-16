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
        senderNameLabel = CustomLabel(text: senderName, textSize: 14, textColor: .textPrimary, fontName: .RobotoFlexSemiBold)
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
