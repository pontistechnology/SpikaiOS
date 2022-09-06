//
//  InAppNotificationView.swift
//  Spika
//
//  Created by Nikola Barbarić on 01.04.2022..
//

import UIKit

class MessageNotificationView: UIView {
    
    
    private let avatarImageView: UIImageView
    private let senderNameLabel: CustomLabel
    private let descriptionLabel: CustomLabel
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    
    init(imageUrl: URL?, senderName: String, textOrDescription: String){
        senderNameLabel = CustomLabel(text: senderName, textSize: 14, textColor: .white, fontName: .MontserratSemiBold)
        descriptionLabel = CustomLabel(text: textOrDescription, textSize: 11, textColor: .white)
        
        avatarImageView = UIImageView()
        avatarImageView.kf.setImage(with: imageUrl, placeholder: UIImage.userImage)
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("notificaiton deinit")
    }
}

extension MessageNotificationView: BaseView {
    func addSubviews() {
        addSubview(blurEffectView)
        addSubview(avatarImageView)
        addSubview(senderNameLabel)
        addSubview(descriptionLabel)
    }
    
    func styleSubviews() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        avatarImageView.layer.cornerRadius = 28
        avatarImageView.layer.masksToBounds = true
        
        senderNameLabel.numberOfLines = 1
        descriptionLabel.numberOfLines = 1
    }
    
    func positionSubviews() {
        constrainWidth(344)
        constrainHeight(76)
        
        blurEffectView.fillSuperview()
        
        avatarImageView.constrainWidth(56)
        avatarImageView.constrainHeight(56)
        
        avatarImageView.anchor(leading: leadingAnchor, padding: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0))
        avatarImageView.centerYToSuperview()
        
        senderNameLabel.anchor(top: topAnchor, leading: avatarImageView.trailingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 18, left: 12, bottom: 0, right: 12))
        
        descriptionLabel.anchor(top: senderNameLabel.bottomAnchor, leading: senderNameLabel.leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 12))
    }
}
