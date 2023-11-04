//
//  AllChatsTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 21.02.2022..
//

import UIKit

class AllChatsTableViewCell: UITableViewCell, BaseView {
    static let reuseIdentifier: String = "AllChatsTableViewCell"
    
    let nameLabel = CustomLabel(text: "", textSize: 14, textColor: ._textPrimary, fontName: .MontserratSemiBold)
    private let descriptionStackView = UIStackView()
    let descriptionNameLabel = CustomLabel(text: " ", textSize: 14, textColor: ._textPrimary)
    let descriptionIcon = UIImageView()
    let descriptionTextLabel = CustomLabel(text: "boto", textSize: 14, textColor: ._textPrimary, alignment: .left)
    let helperView = UIView()
    let leftImageView = UIImageView(image: UIImage(safeImage: .userImage))
    let timeLabel = CustomLabel(text: "", textSize: 12, textColor: ._textPrimary)
    
    let messagesStackView = CustomStackView(axis: .horizontal, distribution: .fill, alignment: .fill, spacing: 8)
    let messagesNumberLabel = CustomLabel(text: "", textSize: 10, textColor: ._textPrimary, fontName: .MontserratSemiBold, alignment: .center)
    let pinnedIcon = UIImageView(image: UIImage(safeImage: .pinnedChatIcon))
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
        contentView.addSubview(descriptionStackView)
        contentView.addSubview(timeLabel)
        
        descriptionStackView.addArrangedSubview(descriptionNameLabel)
        descriptionStackView.addArrangedSubview(descriptionIcon)
        descriptionStackView.addArrangedSubview(descriptionTextLabel)
        descriptionStackView.addArrangedSubview(helperView)
        
        contentView.addSubview(messagesStackView)
        messagesStackView.addArrangedSubview(pinnedIcon)
        messagesStackView.addArrangedSubview(mutedIcon)
        messagesStackView.addArrangedSubview(messagesNumberLabel)
    }
    
    func styleSubviews() {
        descriptionStackView.axis = .horizontal
        descriptionStackView.distribution = .fill
        descriptionIcon.contentMode = .scaleAspectFit
        
        
        leftImageView.clipsToBounds = true
        leftImageView.layer.cornerRadius = 27
        leftImageView.contentMode = .scaleAspectFill
        nameLabel.numberOfLines = 1
        descriptionNameLabel.numberOfLines = 1
        timeLabel.numberOfLines = 1
        
        messagesNumberLabel.backgroundColor = .primaryColor
        messagesNumberLabel.layer.cornerRadius = 10
        messagesNumberLabel.clipsToBounds = true
        messagesNumberLabel.hide()
        backgroundColor = .clear
        
        pinnedIcon.translatesAutoresizingMaskIntoConstraints = false
        pinnedIcon.contentMode = .center
        
        mutedIcon.translatesAutoresizingMaskIntoConstraints = false
        mutedIcon.contentMode = .center
    }
    
    func positionSubviews() {
        leftImageView.centerYToSuperview()
        leftImageView.anchor(leading: contentView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0), size: CGSize(width: 54, height: 54))
        
        nameLabel.anchor(top: contentView.topAnchor, leading: leftImageView.trailingAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 14, left: 12, bottom: 0, right: 100))
        
        descriptionNameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        helperView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        descriptionTextLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        descriptionNameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 140).isActive = true
        descriptionStackView.anchor(leading: nameLabel.leadingAnchor, bottom: contentView.bottomAnchor, trailing: nameLabel.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0))
        descriptionStackView.setCustomSpacing(4, after: descriptionIcon)
        
        timeLabel.anchor(top: contentView.topAnchor, trailing: contentView.trailingAnchor, padding: UIEdgeInsets(top: 18, left: 0, bottom: 0, right: 20))
        
        messagesStackView.anchor(top: timeLabel.bottomAnchor, trailing: timeLabel.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
        messagesStackView.constrainHeight(20)
        messagesNumberLabel.constrainWidth(20)
//        mutedIcon.constrainWidth(20)
    }
    
    func configureCell(avatarUrl: URL?, name: String, description: (String?, MessageType, String?), time: String, badgeNumber: Int64, muted: Bool, pinned: Bool) {
        leftImageView.kf.setImage(with: avatarUrl, placeholder: UIImage(safeImage: .userImage))

        nameLabel.text = name
        descriptionNameLabel.text = description.0
        descriptionIcon.image = description.1.icon
        descriptionIcon.isHidden = description.1 == .text
        descriptionTextLabel.text = description.2
        timeLabel.text = time
        messagesNumberLabel.text = "\(badgeNumber)"
        messagesNumberLabel.isHidden = badgeNumber == 0
        
        mutedIcon.isHidden = !muted
        pinnedIcon.isHidden = !pinned
        
        
    }
    
    override func prepareForReuse() {
        leftImageView.image = UIImage(safeImage: .userImage)
        nameLabel.text = nil
        descriptionNameLabel.text = nil
        descriptionTextLabel.text = nil
        descriptionIcon.image = nil
    }
}
