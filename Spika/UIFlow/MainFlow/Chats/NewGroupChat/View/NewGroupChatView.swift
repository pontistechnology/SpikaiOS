//
//  NewGroupChatView.swift
//  Spika
//
//  Created by Nikola Barbarić on 07.03.2022..
//

import Foundation
import UIKit

class NewGroupChatView: UIView, BaseView {
    
    let newGroupLabel = CustomLabel(text: .getStringFor(.newGroup), textSize: 28, textColor: .textPrimary, fontName: .MontserratSemiBold)
    var avatarPictureView: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(resource: .camer), for: .normal)
        btn.layer.cornerRadius = 60
        btn.layer.masksToBounds = true
        return btn
    } ()
    let groupNameTextfield = TextField(textPlaceholder: .getStringFor(.groupName))
    let chatMembersView = ChatUsersView(canAddNewMore: false)
    
    
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
        self.chatMembersView.editable.send(true)
    }
    
    func positionSubviews() {
        newGroupLabel.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 0))
        
        avatarPictureView.anchor(top: newGroupLabel.bottomAnchor, padding: UIEdgeInsets(top: 34, left: 0, bottom: 0, right: 0))
        avatarPictureView.centerXToSuperview()
        avatarPictureView.constrainWidth(120)
        avatarPictureView.constrainHeight(120)
        
        groupNameTextfield.anchor(top: avatarPictureView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 23, left: 20, bottom: 0, right: 20))
        groupNameTextfield.constrainHeight(50)
                
        chatMembersView.anchor(top: groupNameTextfield.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0))
        
    }
}
