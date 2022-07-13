//
//  ImageMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 09.07.2022..
//

import Foundation
import UIKit

class ImageMessageTableViewCell: UITableViewCell, BaseView {
    
    enum ImageReuseIdentifier : String {
        case myImage = "ImageMessageTableViewCell"
        case friendImage = "FriendImageMessageTableViewCell"
    }
    
    let currentReuseIdentifier: ImageReuseIdentifier?
    
    let containerView = UIView()
    let photoImageView = UIImageView()
    let timeLabel = CustomLabel(text: "11:54", textSize: 11, textColor: .textTertiary, fontName: .MontserratMedium)
    let messageStateView = MessageStateView(state: .waiting)
    let replyView = ReplyMessageView()
    let reactionImageView = UIImageView(image: UIImage(named: "reaction"))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        print("text cell init")
        if let identifier = ImageReuseIdentifier(rawValue: reuseIdentifier ?? "errrrrrorr") {
            currentReuseIdentifier = identifier
        } else {
            currentReuseIdentifier = nil
        }
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("textcell deinit")
    }
    
    override func prepareForReuse() {
        timeLabel.isHidden = true
    }
    
    func addSubviews() {
        guard let currentReuseIdentifier = currentReuseIdentifier else { return }
        
        contentView.addSubview(containerView)
        contentView.addSubview(timeLabel)
        containerView.addSubview(photoImageView)
        
        switch currentReuseIdentifier {
        case .myImage:
            contentView.addSubview(messageStateView)
        case .friendImage:
            contentView.addSubview(reactionImageView)
        }
    }
    
    func styleSubviews() {
        guard let currentReuseIdentifier = currentReuseIdentifier else {
            return
        }
        switch currentReuseIdentifier {
        case .myImage:
            containerView.backgroundColor = UIColor(hexString: "C8EBFE") // TODO: ask nika for color
        case .friendImage:
            containerView.backgroundColor = .chatBackground
        }
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        timeLabel.isHidden = true
    }
    
    func positionSubviews() {
        
        guard let currentReuseIdentifier = currentReuseIdentifier else {
            return
        }
        
        photoImageView.constrainWidth(256)
        photoImageView.constrainHeight(256)
        
        switch currentReuseIdentifier {
        case .myImage:
            containerView.anchor(top: contentView.topAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 20))
            
            photoImageView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
           
            messageStateView.anchor(leading: containerView.trailingAnchor, bottom: containerView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 6))
            
            timeLabel.anchor(trailing: containerView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
            timeLabel.centerYToSuperview()
            
        case .friendImage:
            containerView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 4, right: 0))
            
            photoImageView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            
            reactionImageView.anchor(top: containerView.topAnchor, leading: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0), size: CGSize(width: 24, height: 24))
        }
    }
}

// MARK: Public Functions

extension ImageMessageTableViewCell {
    
    func updateCell(message: Message) {
        guard let currentReuseIdentifier = currentReuseIdentifier else {
            return
        }
        photoImageView.kf.setImage(with: URL(string: Constants.Networking.baseUrl + (message.body?.file?.path ?? "a").dropFirst()), placeholder: UIImage(systemName: "house"))
        
        if let createdAt = message.createdAt {
            timeLabel.text = createdAt.convert(to: .HHmm)
        }
                
        switch currentReuseIdentifier {
        case .myImage:
            break
        case .friendImage:
            break
        }
    }
    
    func updateCellState(to state: MessageState) {
        messageStateView.changeState(to: state)
    }
    
    func tapHandler() {
        timeLabel.isHidden.toggle()
    }
    
//    func updateCell(message: Message, replyMessageTest: Message? = nil) {
//        guard let currentReuseIdentifier = currentReuseIdentifier else {
//            return
//        }
//        messageLabel.text = message.body.text
//
//        switch currentReuseIdentifier {
//        case .myText:
//            break
//        case .myTextAndReply:
//
////            replyView.updateReplyView(message: replyMessageTest ?? message)
//            break
//        case .friendText:
//            break
//        case .friendTextAndReply:
////            replyView.updateReplyView(message: replyMessageTest ?? message)
//            break
//        }
//    }
}
