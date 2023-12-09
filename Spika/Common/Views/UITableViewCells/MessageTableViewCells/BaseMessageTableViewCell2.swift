//
//  BaseMessageTableViewCell22.swift
//  Spika
//
//  Created by Nikola Barbarić on 30.11.2023..
//

import Foundation
import UIKit
import Combine

class BaseMessageTableViewCell2: UITableViewCell {
    
    private let senderNameLabel = CustomLabel(text: "", textSize: 12, textColor: .textPrimary, fontName: .MontserratRegular, alignment: .left)
    private let senderPhotoImageview = UIImageView()
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
        vStack.alignment = .leading
        
        hSTack.axis = .horizontal
        hSTack.distribution = .fill
        hSTack.alignment = .bottom
        hSTack.spacing = 4
        
        senderPhotoImageview.layer.cornerRadius = 10
        senderPhotoImageview.clipsToBounds = true
        senderPhotoImageview.contentMode = .scaleAspectFill
        timeLabel.hide()
        backgroundColor = .clear
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
            senderPhotoImageview.hide()
            containerStackView.layer.maskedCorners = .allButBottomLeft
        case .group:
            leftEmptyView.hide()
            containerStackView.layer.maskedCorners = .allButBottomLeft
        }
        
    }
}

extension BaseMessageTableViewCell2 {
    
    func updateTime(to timestamp: Int64) {
        timeLabel.text = timestamp.convert(to: .HHmm)
    }
    
    func updateSender(name: String, isMyMessage: Bool) {
        isMyMessage ? senderNameLabel.hide() : senderNameLabel.unhide()
        senderNameLabel.text = name.isEmpty ? "(missing username)" : name
    }
    
    func updateSender(photoUrl: URL?, isMyMessage: Bool) {
        guard !isMyMessage else { return }
        senderPhotoImageview.kf.setImage(with: photoUrl, placeholder: UIImage(resource: .rDdefaultUser))
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
        leftEmptyView.unhide()
        rightEmptyView.unhide()
    }
}
