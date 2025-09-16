//
//  DeletedMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 24.01.2023..
//

import Foundation
import UIKit

final class DeletedMessageTableViewCell: BaseMessageTableViewCell2 {
    
    private let plainTextView = MessageTextView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTextCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTextCell() {
        containerStackView.addArrangedSubview(plainTextView)
    }
}

// MARK: Public Functions

extension DeletedMessageTableViewCell: BaseMessageTableViewCellProtocol {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        plainTextView.reset()
    }
    
    func updateCell(message: Message) {
        plainTextView.setup(text: "This message is deleted", color: .textPrimary)
        containerStackView.backgroundColor = .additionalColor
        containerStackView.layer.borderColor = UIColor.primaryColor.cgColor
        containerStackView.layer.borderWidth = 1
    }
}


