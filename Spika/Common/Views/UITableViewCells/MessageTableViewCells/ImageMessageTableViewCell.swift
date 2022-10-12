//
//  ImageMessageTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 09.07.2022..
//

import Foundation
import UIKit

class ImageMessageTableViewCell: BaseMessageTableViewCell {
    
    static let myImageReuseIdentifier = "MyImageMessageTableViewCell"
    static let friendImageReuseIdentifier = "FriendImageMessageTableViewCell"
    static let groupImageReuseIdentifier = "GroupImageMessageTableViewCell"
    
    let photoImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        print("text cell init")

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupImageCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("textcell deinit")
    }
    
    func setupImageCell() {
        containerView.addSubview(photoImageView)
        
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.layer.cornerRadius = 10
        photoImageView.clipsToBounds = true
        
        photoImageView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
        photoImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 256).isActive = true
    }
}
// MARK: Public Functions

extension ImageMessageTableViewCell {
    
    func updateCell(message: Message) {
        photoImageView.kf.setImage(with: URL(string: message.body?.file?.path?.getAvatarUrl() ?? "error"), placeholder: UIImage(systemName: "house"))
        
        updateTime(to: message.createdAt)
    }
}
