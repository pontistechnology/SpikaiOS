//
//  ContactsViewController.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit
import Combine
import CoreData

class ContactsViewController: BaseViewController {
    
    private let contactsView = ContactsView()
    var viewModel: ContactsViewModel!
    
    var frc: NSFetchedResultsController<UserEntity>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(contactsView)
        setupBindings()
        setFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    var testC = 0
    
    func setupBindings() {
        contactsView.tableView.dataSource = self
        contactsView.tableView.delegate   = self
        contactsView.searchBar.delegate = self
        
        contactsView.titleLabel.tap().sink { [weak self] tap in
            guard let _ = self else { return }
            PopUpManager.shared.presentAlert(errorMessage: "tititi")
        }.store(in: &subscriptions)
        
        viewModel.contactsSubject.receive(on: DispatchQueue.main).sink { [weak self] contacts in
            guard let self = self else { return }
            self.contactsView.tableView.reloadData()
        }.store(in: &subscriptions)
        
//        viewModel.getUsersAndUpdateUI()
        viewModel.getContacts()
        viewModel.getOnlineContacts(page: 1)
    }
}

extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.customFont(name: .MontserratSemiBold, size: 16)
        header.textLabel?.textColor = .textPrimary
    }
}

extension ContactsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let char = viewModel.contactsSubject.value[section].first?.displayName?.prefix(1) {
            return char.localizedUppercase
        } else {
            return "@"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.contactsSubject.value.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.contactsSubject.value[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier, for: indexPath) as? ContactsTableViewCell
        cell?.configureCell(viewModel.contactsSubject.value[indexPath.section][indexPath.row])
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("t: ", indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        let user = viewModel.contactsSubject.value[indexPath.section][indexPath.row]
        viewModel.showDetailsScreen(user: user)
    }
}

extension ContactsViewController: SearchBarDelegate {
    func searchBar(_ searchBar: SearchBar, valueDidChange value: String?) {
        if let value = value {
            viewModel.filterContactsUI(filter: value)
        }
    }
    
    func searchBar(_ searchBar: SearchBar, didPressCancel value: Bool) {
        viewModel.filterContactsUI(filter: "")
    }
}

// MARK: - NSFetchedResultsController

extension ContactsViewController: NSFetchedResultsControllerDelegate {
    
    func setFetch() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let fetchRequest = UserEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(UserEntity.displayName), ascending: true)]
            self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.viewModel.repository.getMainContext(), sectionNameKeyPath: nil, cacheName: nil)
            self.frc?.delegate = self
            do {
                try self.frc?.performFetch()
                self.contactsView.tableView.reloadData()
            } catch {
                fatalError("Failed to fetch entities: \(error)") // TODO: handle error
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.viewModel.updateUsersFromFrc(controller.fetchedObjects! as! [UserEntity])
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        self.viewModel.updateUsersFromFrc(controller.fetchedObjects! as! [UserEntity])
    }
}

