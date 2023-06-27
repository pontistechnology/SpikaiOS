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
    private let stackview = UIStackView()
    let searchBar = SearchBar(placeholder: .getStringFor(.searchByGroupOrContactName), shouldShowCancel: false)
    let segmentedControl = UISegmentedControl(items: ["Chats", "Messages"])
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
        addSubview(stackview)
        stackview.addArrangedSubview(searchBar)
        stackview.addArrangedSubview(segmentedControl)
        addSubview(allChatsTableView)
    }
    
    func styleSubviews() {
        newChatButton.setImage(UIImage(safeImage: .plus), for: .normal)
        allChatsTableView.separatorStyle = .none
        allChatsTableView.rowHeight = 70
        stackview.axis = .vertical
        segmentedControl.isHidden = true
    }
    
    func positionSubviews() {
        chatLabel.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 0))
        newChatButton.anchor(top: topAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 20), size: CGSize(width: 28, height: 28))
        stackview.anchor(top: chatLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20))
        allChatsTableView.anchor(top: stackview.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 0, bottom: HomeTabBar.tabBarHeight, right: 0))
    }
}
