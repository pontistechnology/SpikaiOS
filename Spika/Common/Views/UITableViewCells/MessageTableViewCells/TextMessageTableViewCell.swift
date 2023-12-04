//
//  TextMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 05.03.2022..
//

import Foundation
import UIKit

final class TextMessageTableViewCell: BaseMessageTableViewCell2 {
    
    private let plainTextView = MessageTextView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        guard let reuseIdentifier, let messageSender = getMessageSenderType(reuseIdentifier: reuseIdentifier)
        else { return }
        setupTextCell(messageSender)
    }
    
    init(text: String, sender: MessageSender) {
        super.init(style: .default, reuseIdentifier: nil)
        setupContainer(sender: sender)
        setupTextCell(sender) // TODO: - check
        plainTextView.setup(text: "This message is deleted.")
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("textcell deinit")
    }
    
    func setupTextCell(_ sender: MessageSender) {
        containerStackView.addArrangedSubview(plainTextView)
//        if sender == .me {
//            hSTack.addArrangedSubview(plainTextView)
//        } else {
//            hSTack.insertArrangedSubview(plainTextView, at: 0)
//        }
    }
}

// MARK: Public Functions

extension TextMessageTableViewCell: BaseMessageTableViewCellProtocol {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        plainTextView.reset()
    }
    
    func updateCell(message: Message) {
        plainTextView.setup(text: message.body?.text)
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
