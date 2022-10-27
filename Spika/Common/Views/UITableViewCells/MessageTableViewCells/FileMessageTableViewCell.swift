//
//  FileMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 17.08.2022..
//

import UIKit

class FileMessageTableViewCell: BaseMessageTableViewCell {
    static let myFileReuseIdentifier = "MyFileMessageTableViewCell"
    static let friendFileReuseIdentifier = "FriendFileMessageTableViewCell"
    static let groupFileReuseIdentifier = "GroupFileMessageTableViewCell"
    
    private let photoImageView = UIImageView()
    private let nameLabel = CustomLabel(text: "fileName", textSize: 14, textColor: .textPrimary, fontName: .MontserratBold, alignment: .center)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        print("text cell init")

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupFileCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("textcell deinit")
    }
    
    func setupFileCell() {
        containerView.addSubview(photoImageView)
        containerView.addSubview(nameLabel)
        
        nameLabel.numberOfLines = 2
        photoImageView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        photoImageView.constrainWidth(160)
        photoImageView.constrainHeight(160)

        nameLabel.anchor(leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10))
    }
}

// MARK: Public Functions

extension FileMessageTableViewCell {
    
    func updateCell(message: Message) {
        photoImageView.image = UIImage(systemName: "doc")
        nameLabel.text = message.body?.file?.fileName ?? "fileName"
    }
}
