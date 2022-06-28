//
//  SelectUsersViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 20.02.2022..
//

import Foundation
import UIKit
import CoreData

class SelectUsersViewController: BaseViewController {
    
    private let selectUsersView = SelectUsersView()
    var viewModel: SelectUsersViewModel!
    
    var frc: NSFetchedResultsController<UserEntity>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(selectUsersView)
        setupBindings()
        setFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setupBindings() {
        selectUsersView.searchBar.delegate = self
        selectUsersView.contactsTableView.delegate = self
        selectUsersView.contactsTableView.dataSource = self
        selectUsersView.groupUsersCollectionView.delegate = self
        selectUsersView.groupUsersCollectionView.dataSource = self
        
        selectUsersView.cancelLabel.tap().sink { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }.store(in: &subscriptions)
        
        selectUsersView.chatOptionLabel.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.selectUsersView.setGroupUserVisible(self.selectUsersView.groupUsersCollectionView.isHidden ? true : false)
        }.store(in: &subscriptions)
        
        selectUsersView.nextLabel.tap().sink { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.presentNewGroupScreen()
        }.store(in: &subscriptions)
        
        viewModel.contactsSubject.receive(on: DispatchQueue.main).sink { [weak self] _ in
            guard let self = self else { return }
            self.selectUsersView.contactsTableView.reloadData()
        }.store(in: &subscriptions)
        
        viewModel.selectedUsersSubject.receive(on: DispatchQueue.main).sink { [weak self] selectedContacts in
            guard let self = self else { return }
            self.selectUsersView.numberSelectedUsersLabel.text = "\(selectedContacts.count) / 100 selected"
            self.selectUsersView.groupUsersCollectionView.reloadData()
        }.store(in: &subscriptions)
    }
}

extension SelectUsersViewController: UITableViewDelegate {
    private func printSwipe() {
        print("Swipe.")
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let firstLeft = UIContextualAction(style: .normal, title: "First left") { (action, view, completionHandler) in
                self.printSwipe()
                completionHandler(true)
            }
        firstLeft.backgroundColor = .systemBlue
        
        let secondLeft = UIContextualAction(style: .normal, title: "Second left") { (action, view, completionHandler) in
                self.printSwipe()
                completionHandler(true)
            }
        secondLeft.backgroundColor = .systemPink
        
        let configuration = UISwipeActionsConfiguration(actions: [firstLeft, secondLeft])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let firstRightAction = UIContextualAction(style: .normal, title: "First Right") { (action, view, completionHandler) in
                self.printSwipe()
                completionHandler(true)
            }
        firstRightAction.backgroundColor = .systemGreen
        
        let secondRightAction = UIContextualAction(style: .destructive, title: "Second Right") { (action, view, completionHandler) in
                self.printSwipe()
                completionHandler(true)
            }
        secondRightAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [secondRightAction, firstRightAction])
    }
    
}

extension SelectUsersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.contactsSubject.value[section].first?.getDisplayName().prefix(1).uppercased()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.contactsSubject.value.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.contactsSubject.value[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier) as? ContactsTableViewCell
        cell?.configureCell(viewModel.contactsSubject.value[indexPath.section][indexPath.row])
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectUsersView.groupUsersCollectionView.isHidden {
            // one person chat
            // navigate to current chat
        } else {
            // group chat
            let selectedUser = viewModel.contactsSubject.value[indexPath.section][indexPath.row]
            
            var value = viewModel.selectedUsersSubject.value
            if value.contains(selectedUser) == false {
                value.append(selectedUser)
                viewModel.selectedUsersSubject.send(value)
            }
        }
    }
}

extension SelectUsersViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var value = viewModel.selectedUsersSubject.value
        value.remove(at: indexPath.row)
        viewModel.selectedUsersSubject.send(value)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.selectedUsersSubject.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedUsersCollectionViewCell.reuseIdentifier, for: indexPath) as? SelectedUsersCollectionViewCell
        cell?.updateCell(user: viewModel.selectedUsersSubject.value[indexPath.row])
        return cell ?? UICollectionViewCell()
    }
}

extension SelectUsersViewController: UICollectionViewDelegate {
    
}

extension SelectUsersViewController: UICollectionViewDelegateFlowLayout {
    
}

extension SelectUsersViewController: SearchBarDelegate {
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

extension SelectUsersViewController: NSFetchedResultsControllerDelegate {
    
    func setFetch() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let fetchRequest = UserEntity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(UserEntity.displayName), ascending: true)]
            self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.viewModel.repository.getMainContext(), sectionNameKeyPath: nil, cacheName: nil)
            self.frc?.delegate = self
            do {
                try self.frc?.performFetch()
                self.selectUsersView.contactsTableView.reloadData()
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

