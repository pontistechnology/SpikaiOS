//
//  UserSelectionView.swift
//  Spika
//
//  Created by Vedran Vugrin on 16.11.2022..
//

import Foundation
import UIKit

class UserSelectionView: UIView, BaseView {
    
    let numberSelectedUsersLabel = CustomLabel(text: "0/100 selected", textSize: 11, textColor: .textPrimaryAndWhite)
    let cancelLabel = CustomLabel(text: "Cancel", textSize: 18, textColor: .primaryColor, fontName: .MontserratSemiBold)
    let nextLabel = CustomLabel(text: "Next", textSize: 18, textColor: .primaryColor, fontName: .MontserratSemiBold)
    let chatLabel = CustomLabel(text: "New chat", textSize: 28, textColor: .textPrimaryAndWhite)
    let searchBar = SearchBar(placeholder: "Search for contact", shouldShowCancel: false)
    let chatOptionLabel = CustomLabel(text: "New group chat", textSize: 14, textColor: .primaryColor, fontName: .MontserratBold)
    let contactsTableView = ContactsTableView()
    let groupUsersCollectionView = SelectedUsersCollectionView()
    var groupUsersCollectionViewHeightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
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
        self.contactsTableView.allowsMultipleSelection = true
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
        chatLabel.text = isVisible ? "New group" : "New chat"
        chatOptionLabel.text = isVisible ? "New private chat" : "New group chat"
    }

}
