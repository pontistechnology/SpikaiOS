//
//  ChatUsersView.swift
//  Spika
//
//  Created by Vedran Vugrin on 18.04.2023..
//

import UIKit
import Combine

final class ChatUsersView: ChatMembersView {
    
    private var users: [User] = []
    
    func updateWithUsers(users: [User]) {
        self.users = users.sorted(by: { $0.getDisplayName().localizedCaseInsensitiveCompare($1.getDisplayName()) == .orderedAscending })

        self.titleLabel.text = "\(users.count) " + .getStringFor(.members)
        self.tableView.reloadData()
        
        if self.viewIsExpanded {
            self.setupExpandedView()
        } else {
            self.setupForInitialHeight()
        }
    }
    
    override func setupForInitialHeight() {
        if self.users.count <= 3 {
            self.tableViewHeightConstraint.constant = CGFloat(self.users.count) * self.cellHeight
            self.showMoreButton.hide()
        } else {
            self.tableViewHeightConstraint.constant = 3 * self.cellHeight
            self.showMoreButton.unhide()
        }
        self.showMoreButton.setTitle(.getStringFor(.showMore), for: .normal)
    }
    
    override func setupExpandedView() {
        self.tableViewHeightConstraint.constant = CGFloat(self.users.count) * self.cellHeight
        self.showMoreButton.setTitle(.getStringFor(.showLess), for: .normal)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier,
                                                 for: indexPath) as! ContactsTableViewCell
        let model = self.users[indexPath.row]
        
        let userName = model.getDisplayName()
        
        cell.configureCell(title: userName,
                           description: model.telephoneNumber,
                           leftImage: model.avatarFileId?.fullFilePathFromId(),
                           type: .normal)
        
        cell.onRightClickAction
            .compactMap ({ [weak self] cell in
                return self?.tableView.indexPath(for: cell)
            })
            .subscribe(self.onRemoveUser)
            .store(in: &cell.subscriptions)
        return cell
    }
    
}
