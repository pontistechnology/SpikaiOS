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
    private let messageDetailsView = MessageDetailsView()
        
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
        viewModel.setFetch()
        viewModel.frc?.delegate = self
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier, for: indexPath) as? ContactsTableViewCell,
              let data = viewModel.getDataForCell(at: indexPath)
        else {
            return EmptyTableViewCell()
        }
        cell.backgroundColor = .secondaryBackground // TODO: - move to cell
        if indexPath.section == 0 {
            cell.configureCell(title: data.name, description: data.telephoneNumber, leftImage: data.avatarUrl,
                               type: .doubleEntry(firstText: data.time, firstImage: .sent,
                                                  secondText: data.editedTime, secondImage: .editIcon))
        } else {
            cell.configureCell(title: data.name, description: data.telephoneNumber, leftImage: data.avatarUrl, type: .text(text: data.time))
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let customFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! TableViewHeaderWithIcon
        let title = viewModel.sectionTitles[section]
        customFooterView.title.text = title
        switch section {
        case 0:
            customFooterView.icon.image = UIImage(safeImage: .senderAction)
        case 1:
            customFooterView.icon.image = UIImage(safeImage: .seen)
        case 2:
            customFooterView.icon.image = UIImage(safeImage: .delivered)
        case 3:
            customFooterView.icon.image = UIImage(safeImage: .sent)
        default:
            break
        }
        return customFooterView
    }
}

extension MessageDetailsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        viewModel.refreshData()
        messageDetailsView.recordsTableView.reloadData()
    }
}
