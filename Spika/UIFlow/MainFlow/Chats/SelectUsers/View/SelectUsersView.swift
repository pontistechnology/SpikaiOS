//
//  SelectUsersView.swift
//  Spika
//
//  Created by Nikola Barbarić on 20.02.2022..
//

import Foundation
import UIKit

class SelectUsersView: UIView, BaseView {
    
    let numberSelectedUsersLabel = CustomLabel(text: "0/100 " + .getStringFor(.selected), textSize: 11, textColor: .textPrimary)
    let cancelLabel = CustomLabel(text: .getStringFor(.cancel), textSize: 14, textColor: .primaryColor, fontName: .MontserratBold)
    let nextLabel = CustomLabel(text: .getStringFor(.next), textSize: 14, textColor: .primaryColor, fontName: .MontserratSemiBold)
    let chatLabel = CustomLabel(text: .getStringFor(.newChat), textSize: 28, textColor: .textPrimary)
    let searchBar = SearchBar(placeholder: .getStringFor(.searchForContact), shouldShowCancel: false)
    let chatOptionLabel = CustomLabel(text: .getStringFor(.newGroupChat), textSize: 14, textColor: .primaryColor, fontName: .MontserratBold)
    let contactsTableView = ContactsTableView()
    let groupUsersCollectionView = SelectedUsersCollectionView()
    var groupUsersCollectionViewHeightConstraint: NSLayoutConstraint?
    
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
        addSubview(groupUsersCollectionView)
        addSubview(numberSelectedUsersLabel)
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
        
        groupUsersCollectionView.anchor(top: chatOptionLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 20))
        
        numberSelectedUsersLabel.anchor(top: groupUsersCollectionView.topAnchor, leading: groupUsersCollectionView.leadingAnchor, padding: UIEdgeInsets(top: 4, left: 4, bottom: 0, right: 0))
        setGroupUserVisible(false)
        
        contactsTableView.anchor(top: groupUsersCollectionView.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
    }
    
    func setGroupUserVisible(_ isVisible: Bool) {
        groupUsersCollectionViewHeightConstraint?.isActive = false
        groupUsersCollectionViewHeightConstraint = groupUsersCollectionView.heightAnchor.constraint(equalToConstant: isVisible ? 100 : 0)
        groupUsersCollectionViewHeightConstraint?.isActive = true
        groupUsersCollectionView.isHidden = !isVisible
        numberSelectedUsersLabel.isHidden = !isVisible
        nextLabel.isHidden = !isVisible
        chatLabel.text = isVisible ? .getStringFor(.newGroup) : .getStringFor(.newChat)
        chatOptionLabel.text = isVisible ? .getStringFor(.newPrivateChat) : .getStringFor(.newGroupChat)
    }
    
    
}
