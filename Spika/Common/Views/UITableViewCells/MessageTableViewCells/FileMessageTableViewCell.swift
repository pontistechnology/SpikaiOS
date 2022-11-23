//
//  FileMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 17.08.2022..
//

import UIKit

final class FileMessageTableViewCell: BaseMessageTableViewCell {
    
    private let iconImageView = UIImageView()
    private let nameLabel = CustomLabel(text: "fileName", textSize: 14, textColor: .logoBlue, fontName: .MontserratSemiBold, alignment: .center)
    private let sizeLabel = CustomLabel(text: "", textSize: 12, textColor: .logoBlue, fontName: .MontserratRegular)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupFileCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupFileCell() {
        containerView.addSubview(iconImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(sizeLabel)
        
        iconImageView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, padding: UIEdgeInsets(top: 20, left: 12, bottom: 20, right: 0), size: CGSize(width: 18, height: 18))

        nameLabel.anchor(leading: iconImageView.trailingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 12, bottom: 0, right: 12))
        nameLabel.centerYToSuperview(offset: -8)
        
        sizeLabel.anchor(leading: nameLabel.leadingAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 2, left: 0, bottom: 10, right: 12))
        sizeLabel.centerYToSuperview(offset: 8)
    }
}

// MARK: Public Functions

extension FileMessageTableViewCell {
    
    func updateCell(message: Message) {
        iconImageView.image = .imageFor(mimeType: message.body?.file?.mimeType ?? "unknown")
        nameLabel.text = message.body?.file?.fileName ?? "fileName"
        sizeLabel.text = "\((message.body?.file?.size ?? 0) / 1000000) MB"
    }
}
