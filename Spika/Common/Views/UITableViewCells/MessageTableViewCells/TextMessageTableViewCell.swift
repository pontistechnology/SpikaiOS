//
//  TextMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 05.03.2022..
//

import Foundation
import UIKit

class TextMessageTableViewCell: BaseMessageTableViewCell {
    
    static let myTextReuseIdentifier = "MyTextMessageTableViewCell"
    static let friendTextReuseIdentifier = "FriendTextMessageTableViewCell"
    static let groupTextReuseIdentifier = "GroupTextMessageTableViewCell"
    
    let messageLabel = CustomLabel(text: "u cant see me", textSize: 14, textColor: .logoBlue)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        print("CELL INTI: ", style.rawValue, "reuse identifieer: ", reuseIdentifier)
        setupTextCell()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("textcell deinit")
    }
    
    func setupTextCell() {
        containerView.addSubview(messageLabel)
        
        messageLabel.numberOfLines = 0
        
        messageLabel.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))

    }
}

// MARK: Public Functions

extension TextMessageTableViewCell {
    
    func updateCell(message: Message) {
        
        messageLabel.text = message.body?.text
        """
        text: \(message.body?.text),
        id: \(message.id),
        from id: \(message.fromUserId),
        roomId: \(message.roomId),
        createdAt: \(message.createdAt),
        localId: \(message.localId),
        \n
        """
        
//        for record in message.records! {
//            messageLabel.text?.append("\n\n")
//            messageLabel.text?.append("record: \(record)")
//        }
        
        if let createdAt = message.createdAt {
            updateTime(to: createdAt)
        }
    }
}
