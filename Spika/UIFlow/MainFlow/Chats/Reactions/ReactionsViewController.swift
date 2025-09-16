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
    private let allCategories: [String]
    private let actionPublisher: ActionPublisher
    private let myId: Int64
    
    init(users: [User], records: [MessageRecord], actionPublisher: ActionPublisher, myId: Int64) {
        self.records = records
        self.users = users
        self.actionPublisher = actionPublisher
        self.myId = myId
        
        var keysAndCounts = ["ALL"]
        var keys = ["ALL"]
        let reactions = records.compactMap { $0.reaction }
        Dictionary(grouping: reactions) { $0 }
            .sorted { $0.value.count > $1.value.count }
            .forEach {
            keysAndCounts.append($0.key + " \($0.value.count)")
            keys.append($0.key)
        }
        self.allCategories = keys
        
        reactionsView = ReactionsView(emojisAndCounts: keysAndCounts)
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(reactionsView)
        view.backgroundColor = .secondaryColor // TODO: - check
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reactionRecord = filteredRecords[indexPath.row]
        guard reactionRecord.userId == myId else { return }
        actionPublisher.send(.deleteReaction(reactionRecord.id))
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier, for: indexPath) as? ContactsTableViewCell
        else { return UnknownTableViewCell()}
        let reactionRecord = filteredRecords[indexPath.row]
        let user = users.first { $0.id == reactionRecord.userId }
        
        let description = reactionRecord.userId == myId ? "Tap to remove" : user?.telephoneNumber
        cell.configureCell(title: user?.getDisplayName() ?? "Missing User",
                           description: description,
                           leftImage: user?.avatarFileId?.fullFilePathFromId(),
                           type: .emoji(emoji: filteredRecords[indexPath.row].reaction ?? "#", size: 32))
        return cell
    }
    
    func setupBindings() {
        reactionsView.tableView.delegate = self
        reactionsView.tableView.dataSource = self
        
        reactionsView.stackviewTapPublisher.sink { [weak self] _ in
            self?.reactionsView.tableView.reloadData()
        }.store(in: &subscriptions)
        
        reactionsView.closeImageView.tap().sink { [weak self] _ in
            self?.dismiss(animated: true)
        }.store(in: &subscriptions)
    }
    
    var filteredRecords: [MessageRecord] {
        let index = reactionsView.stackviewTapPublisher.value
        guard index < allCategories.count,
              index > 0
        else { return records }
        return records.filter { $0.reaction == allCategories[index] }
    }
}
