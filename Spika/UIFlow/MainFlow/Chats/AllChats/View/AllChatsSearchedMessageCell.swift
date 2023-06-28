//
//  AllChatsSearchedMessageCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 27.06.2023..
//

import UIKit

class AllChatsSearchedMessageCell: UITableViewCell {
    static let reuseIdentifier: String = "AllChatsSearchedMessageCell"
    
    private let nameLabel = CustomLabel(text: "default", textSize: 14, fontName: .MontserratSemiBold)
    
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
        contentView.addSubview(nameLabel)
    }
    
    func styleSubviews() {
        
    }
    
    func positionSubviews() {
        nameLabel.centerInSuperview()
    }
    
    func configureCell(text: String) {
        nameLabel.text = text
    }
}
