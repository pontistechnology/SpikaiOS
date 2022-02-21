//
//  NewChatView.swift
//  Spika
//
//  Created by Nikola Barbarić on 20.02.2022..
//

import Foundation
import UIKit

class NewChatView: UIView, BaseView {
    
    let cancelLabel = CustomLabel(text: "Cancel", textSize: 14, textColor: .primaryColor, fontName: .MontserratBold)
    let nextLabel = CustomLabel(text: "Next", textSize: 14, textColor: .primaryColor, fontName: .MontserratBold)
    let chatLabel = CustomLabel(text: "New chat", textSize: 28, textColor: .textPrimaryAndWhite)
    let searchBar = SearchBar(placeholder: "Search for contact", shouldShowCancel: false)
    let chatOptionLabel = CustomLabel(text: "New group chat", textSize: 14, textColor: .primaryColor, fontName: .MontserratBold)
    let contactsTableView = ContactsTableView()
    let groupMembersCollectionView = SelectedMembersCollectionView()
    var groupMembersCollectionViewHeightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(cancelLabel)
        addSubview(nextLabel)
        addSubview(chatLabel)
        addSubview(searchBar)
        addSubview(chatOptionLabel)
        addSubview(groupMembersCollectionView)
        addSubview(contactsTableView)
    }
    
    func styleSubviews() {
        
    }
    
    func positionSubviews() {
        cancelLabel.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 0))
        
        nextLabel.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 20))
        
        chatLabel.anchor(top: cancelLabel.bottomAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 26, left: 20, bottom: 0, right: 0))
        
        searchBar.anchor(top: chatLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        
        chatOptionLabel.anchor(top: searchBar.bottomAnchor, trailing: searchBar.trailingAnchor, padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        
        groupMembersCollectionView.anchor(top: chatOptionLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 20))
        setGroupMemberVisible(false)
        
        
        contactsTableView.anchor(top: groupMembersCollectionView.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
    }
    
    func setGroupMemberVisible(_ isVisible: Bool) {
        groupMembersCollectionViewHeightConstraint?.isActive = false
        groupMembersCollectionViewHeightConstraint = groupMembersCollectionView.heightAnchor.constraint(equalToConstant: isVisible ? 100 : 0)
        groupMembersCollectionViewHeightConstraint?.isActive = true
        groupMembersCollectionView.isHidden = !isVisible
        
        chatLabel.text = isVisible ? "New group" : "New chat"
        chatOptionLabel.text = isVisible ? "New private chat" : "New group chat"
    }
    
    
}
