//
//  AllChatsView.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

class AllChatsView: UIView, BaseView {
    
    private let chatLabel = CustomLabel(text: .getStringFor(.chat), textSize: 28, textColor: .textPrimary)
    let infoLabel = CustomLabel(text: "", textSize: 12, textColor: .textPrimary)
    let newChatButton = UIButton()
    let searchBar = UISearchBar()
    let roomsTableView = UITableView()
    let searchedMessagesTableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        roomsTableView.register(AllChatsTableViewCell.self, forCellReuseIdentifier: AllChatsTableViewCell.reuseIdentifier)
        searchedMessagesTableView.register(AllChatsSearchedMessageCell.self, forCellReuseIdentifier: AllChatsSearchedMessageCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(chatLabel)
        addSubview(infoLabel)
        addSubview(searchBar)
        addSubview(roomsTableView)
        addSubview(searchedMessagesTableView)
        addSubview(newChatButton)
    }
    
    func styleSubviews() {
        newChatButton.setImage(UIImage(resource: .rDnewChat).withTintColor(.textPrimary, renderingMode: .alwaysOriginal), for: .normal)
        newChatButton.layer.cornerRadius = 26
        
        
        newChatButton.backgroundColor = .primaryColor
        roomsTableView.separatorStyle = .none
        roomsTableView.rowHeight = 70
        roomsTableView.backgroundColor = .clear
        
        searchBar.scopeButtonTitles = ["Chats", "Messages"]
        searchBar.showsScopeBar = false
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.textColor = .textSecondary
        // TODO: - check dark mode color
        searchBar.searchTextField.leftView?.tintColor = .textSecondary
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: .getStringFor(.search), attributes: [NSAttributedString.Key.foregroundColor: UIColor.textSecondary])
        searchBar.barTintColor = ._backgroundGradientColors.first // TODO: - check
        searchedMessagesTableView.isHidden = true
        searchedMessagesTableView.backgroundColor = .clear
    }
    
    func positionSubviews() {
        chatLabel.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 0))
        infoLabel.anchor(top: chatLabel.bottomAnchor, leading: chatLabel.leadingAnchor, padding: .init(top: 4, left: 0, bottom: 0, right: 0))
        
        newChatButton.anchor(bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: HomeTabBar.tabBarHeight, right: 20), size: CGSize(width: 52, height: 52))
        searchBar.anchor(top: chatLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 12, bottom: 0, right: 12))
        roomsTableView.anchor(top: searchBar.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 0, bottom: HomeTabBar.tabBarHeight, right: 0))
        searchedMessagesTableView.anchor(top: roomsTableView.topAnchor, leading: roomsTableView.leadingAnchor, bottom: roomsTableView.bottomAnchor, trailing: roomsTableView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
}
