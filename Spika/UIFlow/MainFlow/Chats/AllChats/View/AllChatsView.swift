//
//  AllChatsView.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

class AllChatsView: UIView, BaseView {
    
    private let chatLabel = CustomLabel(text: .getStringFor(.chat), textSize: 28, textColor: .textPrimary)
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
        addSubview(newChatButton)
        addSubview(searchBar)
        addSubview(roomsTableView)
        addSubview(searchedMessagesTableView)
    }
    
    func styleSubviews() {
        newChatButton.setImage(UIImage(safeImage: .plus), for: .normal)
        roomsTableView.separatorStyle = .none
        roomsTableView.rowHeight = 70
        roomsTableView.backgroundColor = .clear
        
        searchBar.scopeButtonTitles = ["Chats", "Messages"]
        searchBar.showsScopeBar = false
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.textColor = ._textSecondary
        // TODO: - check dark mode color
        searchBar.searchTextField.leftView?.tintColor = ._textSecondary
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: .getStringFor(.search), attributes: [NSAttributedString.Key.foregroundColor: UIColor._textSecondary])
        searchBar.barTintColor = ._backgroundGradientColors.first // TODO: - check
        searchedMessagesTableView.isHidden = true
        searchedMessagesTableView.backgroundColor = .clear
    }
    
    func positionSubviews() {
        chatLabel.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 0))
        newChatButton.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 20), size: CGSize(width: 28, height: 28))
        searchBar.anchor(top: chatLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 12, bottom: 0, right: 12))
        roomsTableView.anchor(top: searchBar.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 0, bottom: HomeTabBar.tabBarHeight, right: 0))
        searchedMessagesTableView.anchor(top: roomsTableView.topAnchor, leading: roomsTableView.leadingAnchor, bottom: roomsTableView.bottomAnchor, trailing: roomsTableView.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
}
