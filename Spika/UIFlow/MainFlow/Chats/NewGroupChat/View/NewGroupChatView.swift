//
//  NewGroupChatView.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Foundation
import UIKit

class NewGroupChatView: UIView, BaseView {
    
    let newGroupLabel = CustomLabel(text: .getStringFor(.newGroup), textSize: 28, textColor: .textPrimaryAndWhite, fontName: .MontserratSemiBold)
    let avatarPictureView = ImageViewWithIcon(image: UIImage(safeImage: .logo), size: CGSize(width: 100, height: 100))
    let groupNameTextfield = TextField(textPlaceholder: .getStringFor(.groupName))
    let chatMembersView = ChatMembersView(contactsEditable: false)
    
    
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
        addSubview(groupNameTextfield)
        addSubview(chatMembersView)
    }
    
    func styleSubviews() {
    }
    
    func positionSubviews() {
        newGroupLabel.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 0))
        
        avatarPictureView.anchor(top: newGroupLabel.bottomAnchor, padding: UIEdgeInsets(top: 34, left: 0, bottom: 0, right: 0))
        avatarPictureView.centerXToSuperview()
        
        groupNameTextfield.anchor(top: avatarPictureView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 23, left: 20, bottom: 0, right: 20))
        groupNameTextfield.constrainHeight(50)
                
        chatMembersView.anchor(top: groupNameTextfield.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0))
        
    }
}
