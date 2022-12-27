//
//  MessageDetailsViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.05.2022..
//

// TODO: filter me from users and records

import Foundation
import UIKit

class MessageDetailsViewController: BaseViewController {
    
    let sectionTitles:[String] = [.getStringFor(.readBy), .getStringFor(.deliveredTo), .getStringFor(.sentTo)]
    let seenRecords: [MessageRecord]
    let deliveredRecords: [MessageRecord]
    var remainingUsers: [User]
    let users: [User]
    
    let messageDetailsView = MessageDetailsView()
    
    init(users: [User], records: [MessageRecord]) {
        self.users = users
        self.seenRecords = records.filter{$0.type == .seen}
        self.deliveredRecords = records.filter{$0.type == .delivered}
        self.remainingUsers = users.filter({ user in
            !records.contains { record in
                record.userId == user.id
            }
        })
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
            headerView.textLabel?.font = .customFont(name: .MontserratRegular, size: 12)
        }
    }
}

extension MessageDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return seenRecords.count
        case 1:
            return deliveredRecords.count
        case 2:
            return remainingUsers.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageDetailTableViewCell.reuseIdentifier, for: indexPath) as? MessageDetailTableViewCell
        switch indexPath.section {
        case 0:
            guard let user = users.first(where: { user in
                seenRecords[indexPath.row].userId == user.id
            }) else { break }
            
            cell?.configureCell(avatarUrl: user.avatarFileId.fullFilePathFromId(),
                                name: user.getDisplayName(),
                                time: seenRecords[indexPath.row].createdAt.convert(to: .allChatsTimeFormat))
        case 1:
            guard let user = users.first(where: { user in
                deliveredRecords[indexPath.row].userId == user.id
            }) else { break }
            
            cell?.configureCell(avatarUrl: user.avatarFileId.fullFilePathFromId(),
                                name: user.getDisplayName(),
                                time: deliveredRecords[indexPath.row].createdAt.convert(to: .allChatsTimeFormat))
        case 2:
            cell?.configureCell(avatarUrl: remainingUsers[indexPath.row].avatarFileId.fullFilePathFromId(),
                                name: remainingUsers[indexPath.row].getDisplayName(),
                                time: .getStringFor(.waiting))
        default:
            break
        }
        
        return cell ?? EmptyTableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionTitles[section]
    }
}
