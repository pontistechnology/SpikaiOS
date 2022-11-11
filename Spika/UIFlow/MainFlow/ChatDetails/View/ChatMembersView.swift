//
//  ChatMembersView.swift
//  Spika
//
//  Created by Vedran Vugrin on 11.11.2022..
//

import UIKit

final class ChatMembersView: UIView, BaseView {
    
    let contactsEditable: Bool
    
    let cellHeight: CGFloat = 80
    
    var viewIsExpanded = false
    
    var tableViewHeightConstraint: NSLayoutConstraint!
    
    lazy var mainStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    } ()
    
    lazy var horizontalTitleStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    } ()
    
    let titleLabel = CustomLabel(text: "Members", textSize: 22,
                                 textColor: .textPrimaryAndWhite,
                                 fontName: .MontserratSemiBold)
    
    lazy var addContactButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(safeImage: .plus), for: .normal)
        return button
    } ()
    
    lazy var showMoreButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Show more", comment: "Show more"), for: .normal)
        button.setTitleColor(UIColor.primaryColor, for: .normal)
        button.addTarget(self, action: #selector(onShowMore), for: .touchUpInside)
        return button
    } ()
    
    let tableView = ContactsTableView()
    
    var users: [RoomUser] = []
    
    init(contactsEditable: Bool) {
        self.contactsEditable = contactsEditable
        super.init(frame: CGRectZero)
        setupView()
        self.setupForInitialHeight()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWithUsers(users: [RoomUser]) {
        self.users = users

        self.titleLabel.text = "\(users.count) Members"
        self.tableView.reloadData()
        
        if self.viewIsExpanded {
            self.setupExpandedView()
        } else {
            self.setupForInitialHeight()
        }
    }
    
    func setupForInitialHeight() {
        if self.users.count <= 3 {
            self.tableViewHeightConstraint.constant = CGFloat(self.users.count) * self.cellHeight
            self.showMoreButton.isHidden = true
        } else {
            self.tableViewHeightConstraint.constant = 3 * self.cellHeight
            self.showMoreButton.isHidden = false
        }
        self.showMoreButton.setTitle(NSLocalizedString("Show more", comment: "Show more"), for: .normal)
    }
    
    func setupExpandedView() {
        self.tableViewHeightConstraint.constant = CGFloat(self.users.count) * self.cellHeight
        self.showMoreButton.setTitle(NSLocalizedString("Show less", comment: "Show more"), for: .normal)
    }
    
    
    func addSubviews() {
        self.addSubview(self.mainStackView)
        
        self.mainStackView.addArrangedSubview(self.horizontalTitleStackView)
        self.horizontalTitleStackView.addArrangedSubview(self.titleLabel)
        
        if self.contactsEditable {
            self.horizontalTitleStackView.addArrangedSubview(self.addContactButton)
        }
        
        self.mainStackView.addArrangedSubview(self.tableView)
        self.mainStackView.addArrangedSubview(self.showMoreButton)
    }
    
    func styleSubviews() {
        self.tableViewHeightConstraint = self.tableView.heightAnchor.constraint(equalToConstant: cellHeight)
        self.tableViewHeightConstraint.isActive = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func positionSubviews() {
        self.mainStackView.fillSuperview()
    }
    
    @objc func onShowMore() {
        self.viewIsExpanded = !self.viewIsExpanded
        if self.viewIsExpanded {
            self.setupForInitialHeight()
        } else {
            self.setupExpandedView()
        }
    }
    
}

extension ChatMembersView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier,
                                                 for: indexPath) as! ContactsTableViewCell
        cell.configureCell(self.users[indexPath.row].user, isEditable: true)
        return cell
    }
}
