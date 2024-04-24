//
//  SystemMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 29.12.2023..
//

import Foundation
import UIKit

class SystemMessageTableViewCell: UITableViewCell {
    private let plainTextView = CustomTextView(text: "", textSize: 14, textColor: .textPrimary, fontName: .MontserratMedium, alignment: .center)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    func setupCell() {
        contentView.addSubview(plainTextView)
        plainTextView.fillSuperview(padding: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SystemMessageTableViewCell {
    func updateCell(message: Message) {
        if let text = message.body?.text {
            plainTextView.text = message.createdAt.convert(to: .HHmm) + " " + text
        }
    }
    
    func updateCell(attributedString: NSMutableAttributedString) {
        let pS = NSMutableParagraphStyle()
        pS.alignment = .center
        attributedString.addAttributes(
            [.foregroundColor: UIColor.textPrimary,
             .paragraphStyle: pS
            ],
            range: NSRange(location: 0, length: attributedString.length)
        )
        plainTextView.attributedText = attributedString
    }
    
    override func prepareForReuse() {
        plainTextView.attributedText = nil
    }
}
