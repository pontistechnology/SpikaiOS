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
        view.backgroundColor = .secondaryColor
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

extension MessageDetailsViewController: UITableViewDataSource, UITableViewDelegate {
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
            return UnknownTableViewCell()
        }

        if indexPath.section == 0 && data.editedTime != nil {
            cell.configureCell(title: data.name,
                               description: data.telephoneNumber,
                               leftImage: data.avatarUrl,
                               type: .doubleEntry(firstText: data.time,
                                                  firstImage: .done,
                                                  secondText: data.editedTime,
                                                  secondImage: .editIcon))
        } else {
            cell.configureCell(title: data.name, description: data.telephoneNumber, leftImage: data.avatarUrl, type: .text(text: data.time))
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let customFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? TableViewHeaderWithIcon
        else { return nil }
        let title = viewModel.sections[section].type.titleString()//viewModel.sectionTitles[section]
        customFooterView.title.text = title
        customFooterView.icon.image = viewModel.sections[section].type.sectionIcon()
        return customFooterView
    }
}

extension MessageDetailsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        viewModel.refreshData()
        messageDetailsView.recordsTableView.reloadData()
    }
}
