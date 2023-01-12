//
//  ReactionsViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.01.2023..
//

import Foundation
import UIKit

class ReactionsViewController: BaseViewController {
    private let reactionsView: ReactionsView
    private let records: [MessageRecord]
    private let users: [User]
    private var filter: String?
    
    
    init(users: [User], records: [MessageRecord]) {
        self.records = records
        self.users = users
        
        var filter = ["ALL"]
        let reactions = records.compactMap { $0.reaction }
        let d = Dictionary(grouping: reactions) { $0 }
            .sorted { $0.value.count > $1.value.count }
        d.forEach { filter.append($0.key + " \($0.value.count)") }
        
        reactionsView = ReactionsView(categories: filter)
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(reactionsView)
        setupBindings()
    }
}

extension ReactionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier, for: indexPath) as? ContactsTableViewCell
        else { return EmptyTableViewCell()}
        let user = users.first { $0.id == filteredRecords[indexPath.row].userId }
        cell.configureCell(title: user?.getDisplayName() ?? "Missing User",
                           description: user?.telephoneNumber,
                           leftImage: user?.avatarFileId?.fullFilePathFromId(),
                           type: .emoji(emoji: filteredRecords[indexPath.row].reaction ?? "#", size: 32))
        return cell
    }
    
    func setupBindings() {
        reactionsView.tableView.delegate = self
        reactionsView.tableView.dataSource = self
        
        reactionsView.stackviewTapPublisher.sink { [weak self] ss in
            self?.filter = ss
            self?.reactionsView.tableView.reloadData()
        }.store(in: &subscriptions)
    }
    
    var filteredRecords: [MessageRecord] {
        if let filter = filter,
           filter != "A" {
            return records.filter { $0.reaction == filter }
        }
        return records
    }
}
