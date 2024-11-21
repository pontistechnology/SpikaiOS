//
//  ContactsView.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

class ContactsView: UIView, BaseView {
    
    let titleLabel = CustomLabel(text: .getStringFor(.contacts), textSize: 28, textColor: .textPrimary, fontName: .RobotoFlexSemiBold)
    let detailsButton = UIButton()
    let searchBar = SearchBar(placeholder: .getStringFor(.searchForContact))
    let tableView = ContactsTableView()
    
    let refreshControl = UIRefreshControl()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(titleLabel)
        addSubview(searchBar)
        addSubview(detailsButton)
        addSubview(tableView)
        
        tableView.addSubview(refreshControl)
    }
    
    func styleSubviews() {
        detailsButton.setTitle(.getStringFor(.details), for: .normal)
        detailsButton.setTitleColor(UIColor.systemTeal, for: .normal)
    }
    
    func positionSubviews() {
        titleLabel.anchor(top: topAnchor, leading: leadingAnchor, padding: UIEdgeInsets(top: 12, left: 20, bottom: 0, right: 0))
        
        searchBar.anchor(top: titleLabel.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 24, left: 20, bottom: 0, right: 20))
            
        tableView.anchor(top: searchBar.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: HomeTabBar.tabBarHeight, right: 0))
    }
    
}
