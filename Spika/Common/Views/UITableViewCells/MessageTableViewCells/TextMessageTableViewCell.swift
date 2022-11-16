//
//  TextMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 05.03.2022..
//

import Foundation
import UIKit

final class TextMessageTableViewCell: BaseMessageTableViewCell {
    
    let messageTextView = CustomTextView(text: "", textSize: 14, textColor: .logoBlue, fontName: .MontserratMedium)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTextCell()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("textcell deinit")
    }
    
    func setupTextCell() {
        containerView.addSubview(messageTextView)
        
        messageTextView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}

// MARK: Public Functions

extension TextMessageTableViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageTextView.text = ""
    }
    
    func updateCell(message: Message) {
        
        messageTextView.text = message.body?.text
//        """
//        text: \(message.body?.text),
//        id: \(message.id),
//        from id: \(message.fromUserId),
//        roomId: \(message.roomId),
//        totalUsers: \(message.totalUserCount),
//        createdAt: \(message.createdAt),
//        localId: \(message.localId),
//        \n
//        """
        
        
//        for record in message.records ?? [] {
//            messageTextView.text?.append("\n\n")
//            messageTextView.text?.append("record: \(record)")
//        }
    }
}
