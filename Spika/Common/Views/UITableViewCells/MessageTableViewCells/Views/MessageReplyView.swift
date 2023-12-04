//
//  MessageReplyView.swift
//  Spika
//
//  Created by Nikola Barbarić on 29.11.2022..
//

import UIKit
import SwiftUI

//struct HelloWorldView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIHelloWorldView()
//            .frame(height: 100)
//    }
//}
//
//struct SwiftUIHelloWorldView: UIViewRepresentable {
//    // 1
//    func makeUIView(context: Context) -> MessageReplyView2 {
//        return MessageReplyView2(senderName: "Petar", message: Message(createdAt: 2, modifiedAt: 2, fromUserId: 2, roomId: 2, id: 2, localId: "f", totalUserCount: 2, deliveredCount: 2, seenCount: 2, replyId: 2, deleted: true, type: .image, body: MessageBody(text: "safoaisjdfoja idjfoiasj ofdiajs oiajf od daosjfaisjd oiaj oifjaoi jasoj foa", file: nil, thumb: FileData(id: 12971, fileName: "m", mimeType: "mm", size: 23, metaData: nil)), records: nil), backgroundColor: .blue, showCloseButton: true)
//
//    }
//    
//    func updateUIView(_ view: MessageReplyView2, context: Context) {}
//}

class MessageReplyView2: UIStackView {
    
    private let thumbnailImageView = UIImageView()
    private let senderNameLabel: CustomLabel
    private var showCloseButton = false
    private let bubbleHStack = UIStackView()
    private let leftVStack = UIStackView()
    private let descriptionHStack = UIStackView()
    private let closeButton = UIButton()
    private let photoAndText: IconAndLabelView2
    
    init(senderName: String, message: Message, backgroundColor: UIColor, showCloseButton: Bool) {
        self.showCloseButton = showCloseButton
        senderNameLabel = CustomLabel(text: senderName, textSize: 12, textColor: .textPrimary, fontName: .MontserratSemiBold)
        photoAndText = IconAndLabelView2(messageType: message.type,
                                         text: message.body?.text)
        super.init(frame: .zero)
        
        addArrangedSubview(bubbleHStack)
        addArrangedSubview(closeButton)
        bubbleHStack.addArrangedSubview(leftVStack)
        bubbleHStack.addArrangedSubview(thumbnailImageView)
        leftVStack.addArrangedSubview(senderNameLabel)
        leftVStack.addArrangedSubview(photoAndText)
        
        bubbleHStack.backgroundColor = .secondaryColor
        closeButton.setImage(UIImage(resource: .rDx).withTintColor(.tertiaryColor), for: .normal)
        thumbnailImageView.kf.setImage(with: message.body?.thumb?.id?.fullFilePathFromId())
        
        axis = .horizontal
        distribution = .fill
        bubbleHStack.axis = .horizontal
        bubbleHStack.distribution = .fill
        bubbleHStack.alignment = .center
        leftVStack.axis = .vertical
        leftVStack.distribution = .fill
        leftVStack.isLayoutMarginsRelativeArrangement = true
        leftVStack.directionalLayoutMargins = .init(top: 0, leading: 16, bottom: 0, trailing: 8)
        
        
        
        closeButton.constrainWidth(24)
        closeButton.constrainHeight(24)
        
        thumbnailImageView.constrainWidth(40)
//        thumbnailImageView.constrainHeight(40)
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.isHidden = message.type == .text
        closeButton.isHidden = !showCloseButton
        
        
        
        
//        containerView.backgroundColor = backgroundColor
//        senderNameLabel = CustomLabel(text: senderName, textSize: 12, textColor: .textPrimary, fontName: .MontserratSemiBold)
//        iconAndTextView = IconAndLabelView(messageType: message.type, text: message.body?.text)
//        super.init(frame: .zero)
//        thumbnailImageView.kf.setImage(with: message.body?.thumb?.id?.fullFilePathFromId())
//        setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MessageReplyView: UIView {
    private let senderNameLabel: CustomLabel
    private let iconAndTextView: IconAndLabelView
    private let thumbnailImageView = UIImageView()
    let containerView = UIView()
    let closeButton = UIButton()
    private var showCloseButton = false
    // TODO: - refactor
    init(senderName: String, message: Message, backgroundColor: UIColor, showCloseButton: Bool = false) {
        self.showCloseButton = showCloseButton
        containerView.backgroundColor = backgroundColor
        senderNameLabel = CustomLabel(text: senderName, textSize: 12, textColor: .textPrimary, fontName: .MontserratSemiBold)
        iconAndTextView = IconAndLabelView(messageType: message.type, text: message.body?.text)
        super.init(frame: .zero)
        thumbnailImageView.kf.setImage(with: message.body?.thumb?.id?.fullFilePathFromId())
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
        
        if showCloseButton {
            addSubview(closeButton)
        }
    }
    
    func styleSubviews() {
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        closeButton.setImage(UIImage(resource: .rDx).withTintColor(.tertiaryColor, renderingMode: .alwaysOriginal), for: .normal)
    }
    
    func positionSubviews() {
        
        containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 140).isActive = true
        containerView.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 8, left: 10, bottom: 0, right: 0))
        
        let aaa = containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        aaa.priority = .defaultLow // This is needed because reply will be reused in cells
        aaa.isActive = true
        
        senderNameLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, trailing: thumbnailImageView.leadingAnchor, padding: UIEdgeInsets(top: 10, left: 12, bottom: 0, right: 10))
        
        iconAndTextView.anchor(top: senderNameLabel.bottomAnchor, leading: senderNameLabel.leadingAnchor, bottom: containerView.bottomAnchor, trailing: thumbnailImageView.leadingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 12, right: 4))
        
        thumbnailImageView.anchor(trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        thumbnailImageView.constrainWidth(44)
        thumbnailImageView.constrainHeight(54)
        thumbnailImageView.centerYToSuperview()
        
        if showCloseButton {
            containerView.anchor(trailing: closeButton.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 160))
            closeButton.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 15), size: CGSize(width: 24, height: 24))
        } else {
            containerView.anchor(trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10))
        }
    }
}
