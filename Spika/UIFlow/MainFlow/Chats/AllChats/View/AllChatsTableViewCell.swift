//
//  AllChatsTableViewCell.swift
//  Spika
//
//  Created by Nikola Barbarić on 21.02.2022..
//

import UIKit

class AllChatsTableViewCell: UITableViewCell, BaseView {
    static let reuseIdentifier: String = "AllChatsTableViewCell"
    
    let nameLabel = CustomLabel(text: "Matej Vidaaaaaaaaaaaaakakakkakkakakkakkaka", fontName: .MontserratSemiBold)
    let descriptionLabel = CustomLabel(text: "Matej Vida: Kaže da može sada, a i sutra", textSize: 11, textColor: .textTertiary)
    let leftImageView = UIImageView(image: UIImage(named: "matejVida"))
    let timeLabel = CustomLabel(text: "Yesterday", textSize: 10, textColor: .textTertiary)
    let messagesNumberLabel = CustomLabel(text: "2", textSize: 10, textColor: .white, fontName: .MontserratSemiBold, alignment: .center)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(leftImageView)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(timeLabel)
        addSubview(messagesNumberLabel)
    }
    
    func styleSubviews() {
        leftImageView.clipsToBounds = true
        leftImageView.layer.cornerRadius = 24
        nameLabel.numberOfLines = 1
        descriptionLabel.numberOfLines = 1
        timeLabel.numberOfLines = 1
        
        messagesNumberLabel.backgroundColor = .primaryColor
        messagesNumberLabel.layer.cornerRadius = 10
        messagesNumberLabel.clipsToBounds = true
    }
    
    func positionSubviews() {
        leftImageView.centerYToSuperview()
        leftImageView.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0), size: CGSize(width: 48, height: 48))
        
        nameLabel.anchor(top: topAnchor, leading: leftImageView.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 14, left: 12, bottom: 0, right: 100))
        descriptionLabel.anchor(leading: nameLabel.leadingAnchor, bottom: bottomAnchor, trailing: nameLabel.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0))
        
        timeLabel.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 18, left: 0, bottom: 0, right: 20))
        
        messagesNumberLabel.anchor(top: timeLabel.bottomAnchor, trailing: timeLabel.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0), size: CGSize(width: 20, height: 20))
    }
    
    func configureCell(image: UIImage, name: String, desc: String) {
        leftImageView.image = image
        nameLabel.text = name
        descriptionLabel.text = desc
    }
    
    override func prepareForReuse() {
        leftImageView.image = UIImage(systemName: "house")
        nameLabel.text = ""
        descriptionLabel.text = ""
    }
}
