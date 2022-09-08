//
//  BaseMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.07.2022..
//

import Foundation
import UIKit

enum MessageSender {
    case me
    case friend
    case group
}

class BaseMessageTableViewCell: UITableViewCell {
    
    let containerView = UIView()
    let senderNameLabel = CustomLabel(text: "Matej Vida", textSize: 12, textColor: .textTertiary, fontName: .MontserratRegular, alignment: .left)
    let senderPhotoImageview = UIImageView(image: UIImage(safeImage: .userImage))
    let timeLabel = CustomLabel(text: "11:54", textSize: 11, textColor: .textTertiary, fontName: .MontserratMedium)
    let messageStateView = MessageStateView(state: .waiting)
    let replyView = ReplyMessageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        
        if let reuseIdentifier = reuseIdentifier {
            if reuseIdentifier == TextMessageTableViewCell.myTextReuseIdentifier ||
                reuseIdentifier == ImageMessageTableViewCell.myImageReuseIdentifier ||
                reuseIdentifier == FileMessageTableViewCell.myFileReuseIdentifier
            {
                setupContainer(sender: .me)
            } else if reuseIdentifier == TextMessageTableViewCell.friendTextReuseIdentifier ||
                reuseIdentifier == ImageMessageTableViewCell.friendImageReuseIdentifier ||
                        reuseIdentifier == FileMessageTableViewCell.friendFileReuseIdentifier{
                setupContainer(sender: .friend)
            } else if reuseIdentifier == TextMessageTableViewCell.groupTextReuseIdentifier ||
                reuseIdentifier == ImageMessageTableViewCell.groupImageReuseIdentifier  ||
                        reuseIdentifier == FileMessageTableViewCell.groupFileReuseIdentifier{
                setupContainer(sender: .group)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// TODO: - MY VS OTHER
extension BaseMessageTableViewCell: BaseView {
    func addSubviews() {
        contentView.addSubview(containerView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(messageStateView)
    }
    
    func styleSubviews() {
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
        timeLabel.isHidden = true
    }
    
    func positionSubviews() {
        
        containerView.widthAnchor.constraint(lessThanOrEqualToConstant: 276).isActive = true
        timeLabel.centerYToSuperview()
    }
    
    func setupContainer(sender: MessageSender) {
        containerView.backgroundColor = sender == .me ?  UIColor(hexString: "C8EBFE") : .chatBackground // TODO: ask nika for color
        messageStateView.isHidden = !(sender == .me)
        
        switch sender {
        case .me:
            containerView.anchor(top: contentView.topAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 20))
            
            messageStateView.anchor(leading: containerView.trailingAnchor, bottom: containerView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 6))

            timeLabel.anchor(trailing: containerView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
        case .friend:
            containerView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, padding: UIEdgeInsets(top: 2, left: 20, bottom: 2, right: 0))
    
            timeLabel.anchor(leading: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
        case .group:
            contentView.addSubview(senderNameLabel)
            contentView.addSubview(senderPhotoImageview)
            
            senderPhotoImageview.layer.cornerRadius = 10
            senderPhotoImageview.clipsToBounds = true
            
            senderNameLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, padding: UIEdgeInsets(top: 6, left: 68, bottom: 0, right: 0))
            
            containerView.anchor(top: senderNameLabel.bottomAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, padding: UIEdgeInsets(top: 8, left: 60, bottom: 2, right: 0))
            
            senderPhotoImageview.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, padding: UIEdgeInsets(top: 28, left: 24, bottom: 0, right: 0), size: CGSize(width: 20, height: 20))
    
            timeLabel.anchor(leading: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
        }
    }
}

extension BaseMessageTableViewCell {
    
    override func prepareForReuse() {
        timeLabel.isHidden = true
    }
    
    func updateCellState(to state: MessageState) {
        messageStateView.changeState(to: state)
    }
    
    func updateTime(to timestamp: Int64) {
        timeLabel.text = timestamp.convert(to: .HHmm)
    }
    
    func updateSenderInfo(name: String, photoUrl: URL?) {
        senderNameLabel.text = name
        senderPhotoImageview.kf.setImage(with: photoUrl, placeholder: UIImage(systemName: "apple")) // TODO: Change apple
    }
    
    func tapHandler() {
        timeLabel.isHidden.toggle()
    }
}
