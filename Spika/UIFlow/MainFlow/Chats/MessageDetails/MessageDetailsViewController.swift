//
//  MessageDetailsViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 13.05.2022..
//

// TODO: filter me from users and records

import Foundation
import UIKit
import CoreData

class MessageDetailsViewController: BaseViewController {
    
    var viewModel: MessageDetailsViewModel!
    let sectionTitles:[String] = [.getStringFor(.readBy), .getStringFor(.deliveredTo), .getStringFor(.sentTo)]
//    let seenRecords: [MessageRecord]
//    let deliveredRecords: [MessageRecord]
//    var remainingUsers: [User]
//    let users: [User]
    
    let messageDetailsView = MessageDetailsView()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(messageDetailsView)
        view.backgroundColor = .secondaryBackground
        setupBindings()
    }
}

extension MessageDetailsViewController {
    func setupBindings() {
        messageDetailsView.recordsTableView.delegate = self
        messageDetailsView.recordsTableView.dataSource = self
        viewModel.frc?.delegate = self
        viewModel.setFetch()
    }
}

extension MessageDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = .secondaryBackground
            headerView.textLabel?.textColor = .textPrimary
            headerView.textLabel?.font = .customFont(name: .MontserratRegular, size: 12)
        }
    }
}

extension MessageDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageDetailTableViewCell.reuseIdentifier, for: indexPath) as? MessageDetailTableViewCell,
              let data = viewModel.getDataForCell(at: indexPath)
        else {
            return EmptyTableViewCell()
        }
        cell.configureCell(avatarUrl: data.avatarUrl, name: data.name, time: data.time)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionTitles[section]
    }
}

extension MessageDetailsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        messageDetailsView.recordsTableView.reloadData()
    }
}
