//
//  LinksTableView.swift
//  Spika
//
//  Created by Nikola Barbarić on 04.02.2022..
//

import Foundation
import UIKit

class MessageDetailTableViewCell: UITableViewCell, BaseView {
    static let reuseIdentifier: String = "MessageDetailTableViewCell"
    
    private let leftImageView = UIImageView(image: UIImage(safeImage: .userImage))
    private let userNameLabel = CustomLabel(text: "", textSize: 14, textColor: ._textPrimary, fontName: .MontserratMedium)
    private let timeLabel  = CustomLabel(text: "", textSize: 12, textColor: ._textSecondary, fontName: .MontserratRegular, alignment: .right)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(leftImageView)
        addSubview(userNameLabel)
        addSubview(timeLabel)
    }
    
    func styleSubviews() {
        backgroundColor = .checkWithDesign
        leftImageView.clipsToBounds = true
        leftImageView.layer.cornerRadius = 35/2
        userNameLabel.numberOfLines = 1
        timeLabel.numberOfLines = 1
    }
    
    func positionSubviews() {
        leftImageView.centerYToSuperview()
        leftImageView.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0), size: CGSize(width: 35, height: 35))
        
        userNameLabel.centerYToSuperview()
        userNameLabel.anchor(leading: leftImageView.trailingAnchor, trailing: timeLabel.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        
        timeLabel.centerYToSuperview()
        timeLabel.anchor(trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20))
    }
    
    func configureCell(avatarUrl: URL?, name: String, time: String) {
        leftImageView.kf.setImage(with: avatarUrl, placeholder: UIImage(safeImage: .userImage))
        userNameLabel.text = name
        timeLabel.text = time
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userNameLabel.text = ""
        timeLabel.text = ""
        leftImageView.image = UIImage(safeImage: .userImage)
    }
}
