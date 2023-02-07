//
//  AllChatsView.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

class AllChatsView: UIView, BaseView {
    
    let chatLabel = CustomLabel(text: .getStringFor(.chat), textSize: 28, textColor: .textPrimary)
    let newChatButton = UIButton()
    let searchBar = SearchBar(placeholder: .getStringFor(.searchForContact), shouldShowCancel: false)
    let allChatsTableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        allChatsTableView.register(AllChatsTableViewCell.self, forCellReuseIdentifier: AllChatsTableViewCell.reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(chatLabel)
        addSubview(newChatButton)
        addSubview(searchBar)
        addSubview(allChatsTableView)
    }
    
    func styleSubviews() {
        newChatButton.setImage(UIImage(safeImage: .plus), for: .normal)
        allChatsTableView.separatorStyle = .none
        allChatsTableView.rowHeight = 70
    }
    
    func positionSubviews() {
        chatLabel.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 0))
        newChatButton.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 20), size: CGSize(width: 28, height: 28))
        searchBar.anchor(top: chatLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        allChatsTableView.anchor(top: searchBar.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 0, bottom: HomeTabBar.tabBarHeight, right: 0))
    }
}
