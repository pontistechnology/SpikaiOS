//
//  BaseMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.07.2022..
//

import Foundation
import UIKit
import Combine

class BaseMessageTableViewCell: UITableViewCell {
    
    private let senderNameLabel = CustomLabel(text: "", textSize: 12, textColor: .textTertiary, fontName: .MontserratRegular, alignment: .left)
    private let senderPhotoImageview = UIImageView(image: UIImage(safeImage: .userImage))
    private let timeLabel = CustomLabel(text: "", textSize: 11, textColor: .textTertiary, fontName: .MontserratMedium)
    private let messageStateView = MessageStateView(state: .waiting)
    let containerStackView = UIStackView()
    private var replyView: MessageReplyView?
    private let progressView = CircularProgressBar(spinnerWidth: 20)
    private let reactionsView = MessageReactionsView()
    
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
        containerStackView.layer.cornerRadius = 10
        containerStackView.layer.masksToBounds = true
        containerStackView.axis = .vertical
        containerStackView.distribution = .fill
        senderPhotoImageview.layer.cornerRadius = 10
        senderPhotoImageview.clipsToBounds = true
        senderPhotoImageview.isHidden = true
        timeLabel.isHidden = true
    }
    
    func positionSubviews() {
        containerStackView.widthAnchor.constraint(lessThanOrEqualToConstant: 276).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: containerStackView.centerYAnchor).isActive = true
    }
    
    func setupContainer(sender: MessageSender) {
        containerStackView.backgroundColor = sender.backgroundColor
        messageStateView.isHidden = sender != .me
        
        containerBottomConstraint = containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2)
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
        timeLabel.isHidden = true
        senderNameLabel.text = ""
        senderPhotoImageview.image = nil
        subs.removeAll()
        replyView?.removeFromSuperview()
        self.replyView = nil
        print("AA")
        progressView.removeFromSuperview()
        containerBottomConstraint = nil
//        senderPhotoImageview.isHidden = true
    }
    
    func updateCellState(to state: MessageState) {
        messageStateView.changeState(to: state)
    }
    
    func updateTime(to timestamp: Int64) {
        timeLabel.text = timestamp.convert(to: .HHmm)
    }
    
    func updateSender(name: String) {
        senderNameLabel.text = name
    }
    
    func updateSender(photoUrl: URL?) {
        senderPhotoImageview.isHidden = false
        senderPhotoImageview.kf.setImage(with: photoUrl, placeholder: UIImage(safeImage: .userImage))
    }
    
    func tapHandler() {
        timeLabel.isHidden.toggle()
    }
    
    func setTimeLabelVisible(_ value: Bool) {
        timeLabel.isHidden = !value
    }
    
    func showReplyView(senderName: String, message: Message, sender: MessageSender?, indexPath: IndexPath?) {
        if replyView == nil, let sender = sender {
            
            let containerColor = sender == .me ? .chatBackground : UIColor(hexString: "C8EBFE")
            
            self.replyView = MessageReplyView(senderName: senderName, message: message, backgroundColor: containerColor, indexPath: indexPath)
            
            containerStackView.insertArrangedSubview(replyView!, at: 0)
            
            replyView?.tap().sink(receiveValue: { [weak self] _ in
                guard let self = self,
                      let indexPath = self.replyView?.indexPath
                else { return }
                self.tapPublisher.send(.scrollToReply(indexPath))
            }).store(in: &subs)
        }
    }
    
    func showReactions(emojis: [String]) {
        contentView.addSubview(reactionsView)
        containerBottomConstraint?.constant -= 15
        
        guard let reuseIdentifier = self.reuseIdentifier,
              let senderType = getMessageSenderType(reuseIdentifier: reuseIdentifier)
        else { return }
        
        switch senderType {
        case .me:
            reactionsView.anchor(bottom: containerStackView.bottomAnchor, trailing: containerStackView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: -15, right: 1))
        case .friend, .group:
            reactionsView.anchor(leading: containerStackView.leadingAnchor, bottom: containerStackView.bottomAnchor, padding: UIEdgeInsets(top: 0, left: 1, bottom: -15, right: 0))
        }
        reactionsView.backgroundColor = senderType.backgroundColor
        
        reactionsView.show(emojis: emojis)
    }
    
    func showUploadProgress(at percent: CGFloat) {
        if progressView.superview == nil {
            containerStackView.addSubview(progressView)
            progressView.fillSuperview()
            containerStackView.bringSubviewToFront(progressView)
        }
        progressView.setProgress(to: percent)
    }
    
    func hideUploadProgress() {
        progressView.removeFromSuperview()
    }
}
