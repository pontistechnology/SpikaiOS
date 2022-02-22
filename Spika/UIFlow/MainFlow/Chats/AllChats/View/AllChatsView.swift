//
//  AllChatsView.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

class AllChatsView: UIView, BaseView {
    
    let chatLabel = CustomLabel(text: "Chat", textSize: 28, textColor: .textPrimaryAndWhite)
    let pencilImageView = UIImageView()
    let searchBar = SearchBar(placeholder: "Search for contact", shouldShowCancel: false)
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
        addSubview(pencilImageView)
        addSubview(searchBar)
        addSubview(allChatsTableView)
    }
    
    func styleSubviews() {
        pencilImageView.image = UIImage(named: "pencil")
        allChatsTableView.backgroundColor = .gray
        allChatsTableView.rowHeight = 70
    }
    
    func positionSubviews() {
        chatLabel.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 0))
        pencilImageView.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 20), size: CGSize(width: 21, height: 21))
        searchBar.anchor(top: chatLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        allChatsTableView.anchor(top: searchBar.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 0, bottom: HomeTabBar.tabBarHeight, right: 0))
    }
}
