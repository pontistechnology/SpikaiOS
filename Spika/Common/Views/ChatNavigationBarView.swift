//
//  ChatNavigationTitleView.swift
//  Spika
//
//  Created by Nikola Barbarić on 16.03.2022..
//

import Foundation
import UIKit

class ChatNavigationBarView: UIView, BaseView {
    
    private let avatarImageView = UIImageView()
    private let nameLabel = CustomLabel(text: "u cant see me ", textSize: 14, textColor: .textPrimary, fontName: .MontserratSemiBold)
    private let statusLabel = CustomLabel(text: "u stats see me", textSize: 12, textColor: .textPrimary, fontName: .MontserratRegular)
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addSubviews() {
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(statusLabel)
    }
    
    func styleSubviews() {
        avatarImageView.image = .userImage
        avatarImageView.layer.cornerRadius = 19
        avatarImageView.layer.masksToBounds = true
    }
    
    func positionSubviews() {
        constrainHeight(44)
        
        avatarImageView.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 38, height: 38))
        avatarImageView.centerYToSuperview()
        
        nameLabel.anchor(top: topAnchor, leading: avatarImageView.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 3, left: 10, bottom: 0, right: 0))
        
        statusLabel.anchor(leading: avatarImageView.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 3, right: 0))
    }
    
    func changeStatus(to value: String) {
        statusLabel.text = value
    }
    
    func change(avatarUrl: String?, name: String?, lastSeen status: String) {
        let url = URL(string: avatarUrl ?? "noUrl")
        avatarImageView.kf.setImage(with: url, placeholder: UIImage.userImage)
        nameLabel.text = name
        statusLabel.text = status
    }
}
