//
//  MessageDetailsViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.05.2022..
//

import Foundation
import UIKit

class MessageDetailsViewController: BaseViewController {
    
    let sectionTitles = ["Read by", "Delivered to", "Sent to"]
    let users: [User]
    let records: [MessageRecord]
    
    let messageDetailsView = MessageDetailsView()
    
    init(users: [User], records: [MessageRecord]) {
        self.users = users
        self.records = records
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(messageDetailsView)
        view.backgroundColor = .white
        setupBindings()
    }
}

extension MessageDetailsViewController {
    func setupBindings() {
        messageDetailsView.recordsTableView.delegate = self
        messageDetailsView.recordsTableView.dataSource = self
    }
}

extension MessageDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = .white
            headerView.textLabel?.textColor = .textPrimary
            headerView.textLabel?.customFont(name: .MontserratRegular, size: 12)
        }
    }
}

extension MessageDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageDetailTableViewCell.reuseIdentifier, for: indexPath) as? MessageDetailTableViewCell
        cell?.configureCell(avatarUrl: users[indexPath.row].getAvatarUrl(),
                            name: users[indexPath.row].getDisplayName(),
                            time: "22.05.2024. 23:59")
        return cell ?? UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionTitles[section]
    }
}
