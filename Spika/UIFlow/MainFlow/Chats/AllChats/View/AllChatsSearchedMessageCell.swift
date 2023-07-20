//
//  AllChatsSearchedMessageCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.06.2023..
//

import UIKit

class AllChatsSearchedMessageCell: UITableViewCell {
    static let reuseIdentifier: String = "AllChatsSearchedMessageCell"
    
    private let timeLabel = CustomLabel(text: "-", textSize: 14, fontName: .MontserratSemiBold)
    private let senderNameLabel = CustomLabel(text: "-", textSize: 14, fontName: .MontserratSemiBold)
    private let messageTextLabel = CustomLabel(text: "-", textSize: 14, fontName: .MontserratRegular)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AllChatsSearchedMessageCell: BaseView {
    func addSubviews() {
        contentView.addSubview(timeLabel)
        contentView.addSubview(senderNameLabel)
        contentView.addSubview(messageTextLabel)
    }
    
    func styleSubviews() {
        messageTextLabel.numberOfLines = 4
        timeLabel.textAlignment = .right
    }
    
    func positionSubviews() {
        timeLabel.anchor(top: contentView.topAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 6))
        senderNameLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, trailing: timeLabel.leadingAnchor, padding: UIEdgeInsets(top: 6, left: 12, bottom: 0, right: 6))
        messageTextLabel.anchor(top: senderNameLabel.bottomAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 20))
    }
    
    func configureCell(senderName: String, time: String, text: String) {
        senderNameLabel.text = senderName
        timeLabel.text = time
        messageTextLabel.text = text
    }
}
