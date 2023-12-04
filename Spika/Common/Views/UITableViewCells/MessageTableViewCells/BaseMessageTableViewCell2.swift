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
    private let editedLabel = CustomLabel(text: "edited", textSize: 10, textColor: .textSecondary)
    let messageStateView = MessageStateView()
    private let reactionsView: MessageReactionsView
    init(emojis: [String], sender: MessageSender) {
        self.reactionsView = MessageReactionsView(emojis: emojis)
        super.init(frame: .zero)
        self.axis = .horizontal
        self.distribution = .fill
        self.alignment = .bottom
        if sender == .me {
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
//    private let progressView = CircularProgressBar(spinnerWidth: 20)
    private var reactionsView: MessageReactionsView?
    
    let tapPublisher = PassthroughSubject<MessageCellTaps, Never>()
    var subs = Set<AnyCancellable>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        guard let reuseIdentifier = reuseIdentifier,
              let sender = getMessageSenderType(reuseIdentifier: reuseIdentifier)
        else { return }
        setupContainer(sender: sender)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("BASE MESSAGE TABLEVIEW CELL DEINIT")
    }
}

extension BaseMessageTableViewCell2 {
    func getMessageSenderType(reuseIdentifier: String) -> MessageSender? {
        if reuseIdentifier.starts(with: MessageSender.me.reuseIdentifierPrefix) {
            return .me
        } else if reuseIdentifier.starts(with: MessageSender.friend.reuseIdentifierPrefix) {
            return .friend
        } else if reuseIdentifier.starts(with: MessageSender.group.reuseIdentifierPrefix) {
            return .group
        }
        return nil
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
        leftEmptyView.backgroundColor = .orange
        rightEmptyView.backgroundColor = .systemPink
        leftEmptyView.axis = .vertical
        rightEmptyView.axis = .vertical
        
        senderPhotoImageview.layer.cornerRadius = 10
        senderPhotoImageview.clipsToBounds = true
//        senderPhotoImageview.hide()
//        timeLabel.hide()
        backgroundColor = .clear
        senderPhotoImageview.contentMode = .scaleAspectFill
    }
    
    func positionSubviews() {
        hSTack.fillSuperview(padding: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        containerStackView.widthAnchor.constraint(lessThanOrEqualToConstant: 276).isActive = true
    }
    
    func setupContainer(sender: MessageSender) {
        containerStackView.backgroundColor = sender.backgroundColor
        senderPhotoImageview.constrainWidth(20)
        senderPhotoImageview.constrainHeight(20)
        
//        messageStateView.isHidden = sender != .me
        timeLabel.textAlignment = sender == .me ? .right : .left
        switch sender {
        case .me:
            rightEmptyView.hide()
            containerStackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        case .friend:
            leftEmptyView.hide()
            containerStackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        case .group:
            leftEmptyView.hide()
            containerStackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
        
    }
}

extension BaseMessageTableViewCell2 {
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        timeLabel.hide()
//        senderNameLabel.text = ""
        senderPhotoImageview.image = nil
//        subs.removeAll()
//        replyView?.removeFromSuperview()
//        progressView.removeFromSuperview()
        reactionsView?.removeFromSuperview()
//        editedIconImageView.removeFromSuperview()
//        editedLabel.removeFromSuperview()
//        self.replyView = nil
        self.reactionsView = nil
//        containerBottomConstraint?.constant = -2
//                senderPhotoImageview.hide()
    }
    
    func updateCellState(to state: MessageState) {
        reactionsEditedStateView?.messageStateView.changeState(to: state)
    }
    
    func updateTime(to timestamp: Int64) {
        timeLabel.text = timestamp.convert(to: .HHmm)
    }
    
    func updateSender(name: String) {
        senderNameLabel.text = name.isEmpty ? "(missing username)" : name
    }
    
    func updateSender(photoUrl: URL?) {
        senderPhotoImageview.unhide()
        senderPhotoImageview.kf.setImage(with: photoUrl, placeholder: UIImage(resource: .rDdefaultUser))
    }
    
    func tapHandler() {
        timeLabel.isHidden.toggle()
    }
    
    func setTimeLabelVisible(_ value: Bool) {
        timeLabel.isHidden = !value
    }
    
    func showReplyView(senderName: String, message: Message, sender: MessageSender?) {
        if replyView == nil, let sender = sender {
            self.replyView = MessageReplyView2(senderName: senderName, message: message, backgroundColor: sender.replyBackgroundColor, showCloseButton: false)
            
            containerStackView.insertArrangedSubview(replyView!, at: 0)
            
            replyView?.tap().sink(receiveValue: { [weak self] _ in
                self?.tapPublisher.send(.scrollToReply)
            }).store(in: &subs)
        }
    }
    
    func showReactions(reactionRecords: [MessageRecord], forText: Bool) {
        guard let reuseIdentifier = self.reuseIdentifier,
              let senderType = getMessageSenderType(reuseIdentifier: reuseIdentifier)
        else { return }
        reactionsEditedStateView = ReactionsEditedCheckmarkStackview(emojis: reactionRecords.compactMap { $0.reaction }, sender: senderType)
        if forText && reactionsEditedStateView?.superview == nil {
            containerStackView.addArrangedSubview(reactionsEditedStateView!)
        }
//        contentView.addSubview(reactionsView!)
//        containerBottomConstraint?.constant = -17
        
//        switch senderType {
//        case .me:
////            reactionsView?.anchor(bottom: containerStackView.bottomAnchor, trailing: containerStackView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: -15, right: 1))
//        case .friend, .group:
//            reactionsView?.anchor(leading: containerStackView.leadingAnchor, bottom: containerStackView.bottomAnchor, padding: UIEdgeInsets(top: 0, left: 1, bottom: -15, right: 0))
//        }
//        reactionsView?.backgroundColor = senderType.backgroundColor
//        
//        reactionsView?.tap().sink { [weak self] _ in
//            self?.tapPublisher.send(.showReactions)
//        }.store(in: &subs)
    }

    func showProgressViewIfNecessary() {
//        if progressView.superview == nil {
//            containerStackView.addSubview(progressView)
//            progressView.fillSuperview()
//            containerStackView.bringSubviewToFront(progressView)
//        }
    }
    
    func showUploadProgress(at percent: CGFloat) {
        showProgressViewIfNecessary()
//        progressView.setProgress(to: percent)
    }
    
    func hideUploadProgress() {
//        progressView.removeFromSuperview()
    }
    
    func startSpinning() {
        showProgressViewIfNecessary()
//        progressView.startSpinning()
    }
}
