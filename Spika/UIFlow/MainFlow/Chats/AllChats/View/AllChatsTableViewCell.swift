//
//  AllChatsTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 21.02.2022..
//

import UIKit

class AllChatsTableViewCell: UITableViewCell, BaseView {
    static let reuseIdentifier: String = "AllChatsTableViewCell"
    
    let nameLabel = CustomLabel(text: "", textSize: 14, fontName: .MontserratSemiBold)
    let descriptionLabel = CustomLabel(text: "", textSize: 14, textColor: .textTertiary)
    let leftImageView = UIImageView(image: UIImage(safeImage: .userImage))
    let timeLabel = CustomLabel(text: "", textSize: 12, textColor: .textTertiary)
    
    let messagesStackView = CustomStackView(axis: .horizontal, distribution: .fill, alignment: .fill, spacing: 8)
    let messagesNumberLabel = CustomLabel(text: "", textSize: 10, textColor: .primaryBackground, fontName: .MontserratSemiBold, alignment: .center)
    let mutedIcon = UIImageView(image: UIImage(safeImage: .mutedIcon))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        contentView.addSubview(leftImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(timeLabel)
        
        contentView.addSubview(messagesStackView)
        messagesStackView.addArrangedSubview(mutedIcon)
        messagesStackView.addArrangedSubview(messagesNumberLabel)
    }
    
    func styleSubviews() {
        leftImageView.clipsToBounds = true
        leftImageView.layer.cornerRadius = 27
        nameLabel.numberOfLines = 1
        descriptionLabel.numberOfLines = 1
        timeLabel.numberOfLines = 1
        
        messagesNumberLabel.backgroundColor = .primaryColor
        messagesNumberLabel.layer.cornerRadius = 10
        messagesNumberLabel.clipsToBounds = true
        messagesNumberLabel.isHidden = true
        
        mutedIcon.translatesAutoresizingMaskIntoConstraints = false
        mutedIcon.contentMode = .center
    }
    
    func positionSubviews() {
        leftImageView.centerYToSuperview()
        leftImageView.anchor(leading: contentView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0), size: CGSize(width: 54, height: 54))
        
        nameLabel.anchor(top: contentView.topAnchor, leading: leftImageView.trailingAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 14, left: 12, bottom: 0, right: 100))
        descriptionLabel.anchor(leading: nameLabel.leadingAnchor, bottom: contentView.bottomAnchor, trailing: nameLabel.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0))
        
        timeLabel.anchor(top: contentView.topAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 18, left: 0, bottom: 0, right: 20))
        
        messagesStackView.anchor(top: timeLabel.bottomAnchor, trailing: timeLabel.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
        messagesStackView.constrainHeight(20)
        messagesNumberLabel.constrainWidth(20)
//        mutedIcon.constrainWidth(20)
    }
    
    func configureCell(avatarUrl: URL?, name: String, description: String, time: String, badgeNumber: Int, muted: Bool) {
        leftImageView.kf.setImage(with: avatarUrl, placeholder: UIImage(safeImage: .userImage))

        nameLabel.text = name
        descriptionLabel.text = description
        timeLabel.text = time
        messagesNumberLabel.text = "\(badgeNumber)"
        messagesNumberLabel.isHidden = badgeNumber == 0
        
        mutedIcon.isHidden = !muted
    }
    
    override func prepareForReuse() {
        leftImageView.image = UIImage(safeImage: .userImage)
        nameLabel.text = ""
        descriptionLabel.text = ""
    }
}
