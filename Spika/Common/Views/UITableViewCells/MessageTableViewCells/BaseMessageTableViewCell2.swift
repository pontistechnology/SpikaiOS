//
//  BaseMessageTableViewCell22.swift
//  Spika
//
//  Created by Nikola Barbarić on 30.11.2023..
//

import Foundation
import UIKit
import Combine



class ReactionsEditedCheckmarkStackview: UIStackView {
    private let emptyView = UIView()
    let editedLabel = CustomLabel(text: "edited", textSize: 10, textColor: .textSecondary)
    let messageStateView = MessageStateView()
    let reactionsView: MessageReactionsView
    init(emojis: [String], isMyMessage: Bool) {
        self.reactionsView = MessageReactionsView(emojis: emojis)
        super.init(frame: .zero)
        self.axis = .horizontal
        self.distribution = .fill
        self.alignment = .bottom
        if isMyMessage {
            addArrangedSubview(emptyView)
            addArrangedSubview(reactionsView)
            addArrangedSubview(editedLabel)
            addArrangedSubview(messageStateView)
        } else {
            addArrangedSubview(editedLabel)
            addArrangedSubview(reactionsView)
            addArrangedSubview(emptyView)
        }
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 4, trailing: 10)
        
        editedLabel.hide()
        reactionsView.hide()
        messageStateView.hide()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BaseMessageTableViewCell2: UITableViewCell {
    
    private let senderNameLabel = CustomLabel(text: "", textSize: 12, textColor: .textPrimary, fontName: .MontserratRegular, alignment: .left)
    private let senderPhotoImageview = UIImageView(image: UIImage(resource: .rDdefaultUser))
    private let timeLabel = CustomLabel(text: "", textSize: 11, textColor: .textPrimary, fontName: .MontserratMedium)
    
    let hSTack = UIStackView()
    let vStack = UIStackView()
    let leftEmptyView = UIStackView()
    let containerStackView = UIStackView()
    let rightEmptyView = UIStackView()
    private var reactionsEditedStateView: ReactionsEditedCheckmarkStackview?
    private var replyView: MessageReplyView2?
    private let progressView = CircularProgressBar(spinnerWidth: 20)
    
    
    let tapPublisher = PassthroughSubject<MessageCellTaps, Never>()
    var subs = Set<AnyCancellable>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("BASE MESSAGE TABLEVIEW CELL DEINIT")
    }
}

// TODO: - MY VS OTHER
extension BaseMessageTableViewCell2: BaseView {
    func addSubviews() {
        contentView.addSubview(hSTack)
        
        hSTack.addArrangedSubview(leftEmptyView)
        hSTack.addArrangedSubview(senderPhotoImageview)
        hSTack.addArrangedSubview(vStack)
        vStack.addArrangedSubview(senderNameLabel)
        vStack.addArrangedSubview(containerStackView)
        vStack.addArrangedSubview(timeLabel)
        hSTack.addArrangedSubview(rightEmptyView)
    }
    
    func styleSubviews() {
        containerStackView.axis = .vertical
        containerStackView.distribution = .fill
        containerStackView.layer.cornerRadius = 16
        containerStackView.clipsToBounds = true
        
        vStack.axis = .vertical
        vStack.distribution = .fill

        
        hSTack.axis = .horizontal
        hSTack.distribution = .fill
        hSTack.alignment = .bottom
        hSTack.spacing = 4
        leftEmptyView.backgroundColor = .orange
        rightEmptyView.backgroundColor = .systemPink
        leftEmptyView.axis = .vertical
        rightEmptyView.axis = .vertical
        
        senderPhotoImageview.layer.cornerRadius = 10
        senderPhotoImageview.clipsToBounds = true
        senderPhotoImageview.contentMode = .scaleAspectFill
        senderPhotoImageview.hide()
        timeLabel.hide()
        backgroundColor = .clear
        hSTack.isLayoutMarginsRelativeArrangement = true
    }
    
    func positionSubviews() {
        hSTack.fillSuperview(padding: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        containerStackView.widthAnchor.constraint(lessThanOrEqualToConstant: 276).isActive = true
        senderPhotoImageview.constrainWidth(20)
        senderPhotoImageview.constrainHeight(20)
    }
    
    func setupContainer(sender: MessageSender) {
        containerStackView.backgroundColor = sender.backgroundColor
        timeLabel.textAlignment = sender == .me ? .right : .left
        switch sender {
        case .me:
            rightEmptyView.hide()
            containerStackView.layer.maskedCorners = .allButBottomRight
        case .friend:
            leftEmptyView.hide()
            containerStackView.layer.maskedCorners = .allButBottomLeft
        case .group:
            leftEmptyView.hide()
            containerStackView.layer.maskedCorners = .allButBottomLeft
            hSTack.directionalLayoutMargins = .init(top: 0, leading: 20, bottom: 0, trailing: 0)
        }
        
    }
}

extension BaseMessageTableViewCell2 {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timeLabel.hide()
        senderNameLabel.text = ""
        senderPhotoImageview.image = nil
        reactionsEditedStateView?.removeFromSuperview()
        reactionsEditedStateView = nil
        subs.removeAll()
        replyView?.removeFromSuperview()
        self.replyView = nil
//        senderPhotoImageview.hide()
        leftEmptyView.unhide()
        rightEmptyView.unhide()
        hSTack.directionalLayoutMargins = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
    
    func updateTime(to timestamp: Int64) {
        timeLabel.text = timestamp.convert(to: .HHmm)
    }
    
    func updateSender(name: String, isMyMessage: Bool) {
        isMyMessage ? senderNameLabel.hide() : senderNameLabel.unhide()
        senderNameLabel.text = name.isEmpty ? "(missing username)" : name
    }
    
    func updateSender(photoUrl: URL?, isMyMessage: Bool) {
        isMyMessage ? senderPhotoImageview.hide() : senderPhotoImageview.unhide()
        senderPhotoImageview.kf.setImage(with: photoUrl, placeholder: UIImage(resource: .rDdefaultUser))
        hSTack.directionalLayoutMargins = .init(top: 0, leading: 0, bottom: 0, trailing: 0) // TODO: - this is bug, isnt reusing properly
    }
    
    func tapHandler() {
        timeLabel.unhide()
    }
    
    func setTimeLabelVisible(_ value: Bool) {
        timeLabel.isHidden = !value
    }
    
    func showReplyView(senderName: String, message: Message, sender: MessageSender?) {
        if replyView == nil, let sender = sender {
            self.replyView = MessageReplyView2(senderName: senderName, 
                                               message: message,
                                               isInMyMessage: sender == .me,
                                               showCloseButton: false)
            
            containerStackView.insertArrangedSubview(replyView!, at: 0)
            
            replyView?.tap().sink(receiveValue: { [weak self] _ in
                self?.tapPublisher.send(.scrollToReply)
            }).store(in: &subs)
        }
    }
    
    func showReactionEditedAndCheckMark(reactionRecords: [MessageRecord], 
                                        isEdited: Bool,
                                        messageState: MessageState,
                                        isForTextCell: Bool,
                                        isMyMessage: Bool) {
        reactionsEditedStateView = ReactionsEditedCheckmarkStackview(emojis: reactionRecords.compactMap { $0.reaction }, isMyMessage: isMyMessage)
        if reactionsEditedStateView?.superview == nil {
            if isForTextCell {
                containerStackView.addArrangedSubview(reactionsEditedStateView!)
            } else {
                containerStackView.addSubview(reactionsEditedStateView!)
                reactionsEditedStateView?.anchor(bottom: containerStackView.bottomAnchor, trailing: containerStackView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            }
        }
        
        if !reactionRecords.isEmpty {
            reactionsEditedStateView?.reactionsView.unhide()
        }
        
        if isEdited {
            reactionsEditedStateView?.editedLabel.unhide()
        }
        if isMyMessage {
            reactionsEditedStateView?.messageStateView.changeState(to: messageState)
            reactionsEditedStateView?.messageStateView.unhide()
        }
        
        reactionsEditedStateView?.tap().sink { [weak self] _ in
            self?.tapPublisher.send(.showReactions)
        }.store(in: &subs)
    }
    
    func showEdited() {
        reactionsEditedStateView?.editedLabel.unhide()
    }

    func showProgressViewIfNecessary() {
        if progressView.superview == nil {
            containerStackView.addSubview(progressView)
            progressView.fillSuperview()
            containerStackView.bringSubviewToFront(progressView)
        }
    }
    
    func showUploadProgress(at percent: CGFloat) {
        showProgressViewIfNecessary()
        progressView.setProgress(to: percent)
    }
    
    func hideUploadProgress() {
        progressView.removeFromSuperview()
    }
    
    func startSpinning() {
        showProgressViewIfNecessary()
        progressView.startSpinning()
    }
}
