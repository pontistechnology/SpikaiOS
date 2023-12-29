//
//  SystemMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 29.12.2023..
//

import Foundation
import UIKit

class SystemMessageTableViewCell: BaseMessageTableViewCell2 {
    private let plainTextView = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    func setupCell() {
        containerStackView.addArrangedSubview(plainTextView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(message: Message) {
        plainTextView.text = message.body?.text
    }
}
