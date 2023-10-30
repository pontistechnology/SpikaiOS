//
//  BaseMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.07.2022..
//

import Foundation
import UIKit
import Combine

protocol BaseMessageTableViewCellProtocol {
    func updateCell(message: Message)
}

class BaseMessageTableViewCell: UITableViewCell {
    
    private let senderNameLabel = CustomLabel(text: "", textSize: 12, textColor: .textTertiary, fontName: .MontserratRegular, alignment: .left)
    private let senderPhotoImageview = UIImageView(image: UIImage(safeImage: .userImage))
    private let timeLabel = CustomLabel(text: "", textSize: 11, textColor: .textTertiary, fontName: .MontserratMedium)
    private let messageStateView = MessageStateView()
    let containerStackView = UIStackView()
    private var replyView: MessageReplyView?
    private let progressView = CircularProgressBar(spinnerWidth: 20)
    private var reactionsView: MessageReactionsView?
    
    private var editedIconImageView = UIImageView(image: UIImage(safeImage: .editIcon).withTintColor(.textSecondary, renderingMode: .alwaysOriginal))
    private var editedLabel = CustomLabel(text: "edited", textSize: 10, textColor: .textSecondary)
    
    private var containerBottomConstraint: NSLayoutConstraint?
    
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

extension BaseMessageTableViewCell {
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
extension BaseMessageTableViewCell: BaseView {
    func addSubviews() {
        contentView.addSubview(containerStackView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(messageStateView)
    }
    
    func styleSubviews() {
        containerStackView.axis = .vertical
        containerStackView.distribution = .fill
        senderPhotoImageview.layer.cornerRadius = 10
        senderPhotoImageview.clipsToBounds = true
        senderPhotoImageview.hide()
        timeLabel.hide()
        backgroundColor = .primaryBackground
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // round corners needs to be called after viewDidAppear
        // TODO: - move to function
        guard let reuseIdentifier,
              let sender = getMessageSenderType(reuseIdentifier: reuseIdentifier)
        else { return }
        switch sender {
        case .me:
            containerStackView.roundCorners(corners: .bottomLeft, radius: 16)
        case .friend, .group:
            containerStackView.roundCorners(corners: .bottomRight, radius: 16)
        }
    }
    
    func positionSubviews() {
        containerStackView.widthAnchor.constraint(lessThanOrEqualToConstant: 276).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: containerStackView.centerYAnchor).isActive = true
    }
    
    func setupContainer(sender: MessageSender) {
        containerStackView.backgroundColor = sender.backgroundColor
        messageStateView.isHidden = sender != .me
        
        containerBottomConstraint = containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2)
        containerBottomConstraint?.priority = .defaultLow
        containerBottomConstraint?.isActive = true
        
        switch sender {
        case .me:
            containerStackView.anchor(top: contentView.topAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 20))
            
            messageStateView.anchor(leading: containerStackView.trailingAnchor, bottom: containerStackView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 6))

            timeLabel.anchor(trailing: containerStackView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
        case .friend:
            containerStackView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, padding: UIEdgeInsets(top: 2, left: 20, bottom: 0, right: 0))
    
            timeLabel.anchor(leading: containerStackView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
        case .group:
            contentView.addSubview(senderNameLabel)
            contentView.addSubview(senderPhotoImageview)
            
            senderNameLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: containerStackView.topAnchor, padding: UIEdgeInsets(top: 2, left: 68, bottom: 4, right: 0))

            containerStackView.anchor(leading: contentView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0))
    
            senderPhotoImageview.anchor(bottom: containerStackView.bottomAnchor, trailing: containerStackView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 14), size: CGSize(width: 20, height: 20))
            
            timeLabel.anchor(leading: containerStackView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
        }
    }
}

extension BaseMessageTableViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timeLabel.hide()
        senderNameLabel.text = ""
        senderPhotoImageview.image = nil
        subs.removeAll()
        replyView?.removeFromSuperview()
        progressView.removeFromSuperview()
        reactionsView?.removeFromSuperview()
        editedIconImageView.removeFromSuperview()
        editedLabel.removeFromSuperview()
        self.replyView = nil
        self.reactionsView = nil
        containerBottomConstraint?.constant = -2
        //        senderPhotoImageview.hide()
    }
    
    func updateCellState(to state: MessageState) {
        messageStateView.changeState(to: state)
    }
    
    func updateTime(to timestamp: Int64) {
        timeLabel.text = timestamp.convert(to: .HHmm)
    }
    
    func updateSender(name: String) {
        senderNameLabel.text = name.isEmpty ? "(missing username)" : name
    }
    
    func updateSender(photoUrl: URL?) {
        senderPhotoImageview.unhide()
        senderPhotoImageview.kf.setImage(with: photoUrl, placeholder: UIImage(safeImage: .userImage))
    }
    
    func tapHandler() {
        timeLabel.isHidden.toggle()
    }
    
    func setTimeLabelVisible(_ value: Bool) {
        timeLabel.isHidden = !value
    }
    
    func showReplyView(senderName: String, message: Message, sender: MessageSender?) {
        if replyView == nil, let sender = sender {
            
            let containerColor: UIColor = sender == .me ? .chatBackground : .myChatBackground
            
            self.replyView = MessageReplyView(senderName: senderName, message: message, backgroundColor: containerColor)
            
            containerStackView.insertArrangedSubview(replyView!, at: 0)
            
            replyView?.tap().sink(receiveValue: { [weak self] _ in
                self?.tapPublisher.send(.scrollToReply)
            }).store(in: &subs)
        }
    }
    
    func showReactions(reactionRecords: [MessageRecord]) {
        guard let reuseIdentifier = self.reuseIdentifier,
              let senderType = getMessageSenderType(reuseIdentifier: reuseIdentifier)
        else { return }
        reactionsView = MessageReactionsView(emojis: reactionRecords.compactMap { $0.reaction })
        contentView.addSubview(reactionsView!)
        containerBottomConstraint?.constant = -17
        
        switch senderType {
        case .me:
            reactionsView?.anchor(bottom: containerStackView.bottomAnchor, trailing: containerStackView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: -15, right: 1))
        case .friend, .group:
            reactionsView?.anchor(leading: containerStackView.leadingAnchor, bottom: containerStackView.bottomAnchor, padding: UIEdgeInsets(top: 0, left: 1, bottom: -15, right: 0))
        }
        reactionsView?.backgroundColor = senderType.backgroundColor
        
        reactionsView?.tap().sink { [weak self] _ in
            self?.tapPublisher.send(.showReactions)
        }.store(in: &subs)
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
    
    func showEditedIcon() {
        guard let reuseIdentifier,
              let sender = getMessageSenderType(reuseIdentifier: reuseIdentifier)
        else { return }
        if editedIconImageView.superview == nil, editedLabel.superview == nil {
            contentView.addSubview(editedIconImageView)
            contentView.addSubview(editedLabel)
            editedIconImageView.constrainWidth(12)
            editedIconImageView.constrainHeight(12)
            editedIconImageView.anchor(top: containerStackView.topAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            editedLabel.anchor(top: containerStackView.topAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            switch sender {
            case .me:
                editedIconImageView.anchor(trailing: containerStackView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 2))
                editedLabel.anchor(trailing: editedIconImageView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4))
            case .friend, .group:
                editedIconImageView.anchor(leading: containerStackView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0))
                editedLabel.anchor(leading: editedIconImageView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0))
            }
        }
    }
}
