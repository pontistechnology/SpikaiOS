//
//  NewGroupChatView.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Foundation
import UIKit

class NewGroupChatView: UIView, BaseView {
    
    let newGroupLabel = CustomLabel(text: "New Group", textSize: 28, textColor: .textPrimaryAndWhite, fontName: .MontserratSemiBold)
    let avatarPictureView = ImageViewWithIcon(image: .logo, size: CGSize(width: 100, height: 100))
    let usernameTextfield = TextField(textPlaceholder: "Group name...")
    let numberOfUsersLabel = CustomLabel(text: "people selected", textSize: 16, textColor: .textPrimaryAndWhite, fontName: .MontserratSemiBold)
    let selectedUsersTableView = ContactsTableView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(newGroupLabel)
        addSubview(avatarPictureView)
        addSubview(usernameTextfield)
        addSubview(numberOfUsersLabel)
        addSubview(selectedUsersTableView)
    }
    
    func styleSubviews() {
    }
    
    func positionSubviews() {
        newGroupLabel.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 0))
        
        avatarPictureView.anchor(top: newGroupLabel.bottomAnchor, padding: UIEdgeInsets(top: 34, left: 0, bottom: 0, right: 0))
        avatarPictureView.centerXToSuperview()
        
        usernameTextfield.anchor(top: avatarPictureView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 23, left: 20, bottom: 0, right: 20))
        usernameTextfield.constrainHeight(50)
        
        numberOfUsersLabel.anchor(top: usernameTextfield.bottomAnchor, leading: usernameTextfield.leadingAnchor, padding: UIEdgeInsets(top: 34, left: 0, bottom: 0, right: 0))
        
        selectedUsersTableView.anchor(top: numberOfUsersLabel.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0))
        
    }
}
