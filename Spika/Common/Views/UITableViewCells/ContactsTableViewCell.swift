//
//  ContactsTableView.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.02.2022..
//

import Foundation
import UIKit
import Kingfisher

class ContactsTableViewCell: UITableViewCell, BaseView {
    static let reuseIdentifier: String = "ContactsTableViewCell"
    let nameLabel = CustomLabel(text: "*Contact Name*", textSize: 14, fontName: .MontserratMedium)
    let descriptionLabel = CustomLabel(text: "CTO", textSize: 12, fontName: .MontserratRegular)
    let leftImageView = UIImageView(image: UIImage(safeImage: .userImage))
    lazy var removeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(safeImage: .close), for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    } ()
    
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
        addSubview(removeButton)
    }
    
    func styleSubviews() {
        leftImageView.clipsToBounds = true
        leftImageView.layer.cornerRadius = 21
        leftImageView.contentMode = .scaleAspectFill
        nameLabel.numberOfLines = 1
        descriptionLabel.numberOfLines = 1
        
    }
    
    func positionSubviews() {
        leftImageView.centerYToSuperview()
        leftImageView.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0), size: CGSize(width: 42, height: 42))
        
        nameLabel.anchor(top: topAnchor, leading: leftImageView.trailingAnchor, trailing: self.removeButton.leadingAnchor, padding: UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 20))
        descriptionLabel.anchor(leading: leftImageView.trailingAnchor, bottom: bottomAnchor, trailing: self.removeButton.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 16, bottom: 13, right: 20))
        
        self.removeButton.centerYToSuperview()
        self.removeButton.anchor(trailing: trailingAnchor, padding: UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 14), size: CGSize(width: 50, height: 50))
    }
    
    func configureCell(image: UIImage, name: String, desc: String) {
        leftImageView.image = image
        nameLabel.text = name
        descriptionLabel.text = desc
    }
    
    func configureCell(_ model: User, isEditable: Bool = false) {
        nameLabel.text = model.getDisplayName()
        descriptionLabel.text = model.telephoneNumber
        
        let url = URL(string: model.getAvatarUrl() ?? "")
        leftImageView.kf.setImage(with: url, placeholder: UIImage(safeImage: .userImage))
        
        self.removeButton.isHidden = !isEditable
    }
    
    override func prepareForReuse() {
        leftImageView.image = UIImage(safeImage: .userImage)
        nameLabel.text = ""
        descriptionLabel.text = ""
    }
}
