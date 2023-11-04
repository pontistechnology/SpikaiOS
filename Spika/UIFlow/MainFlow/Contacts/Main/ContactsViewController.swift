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
    
    
    func setupBindings() {
        contactsView.tableView.dataSource = self
        contactsView.tableView.delegate   = self
        contactsView.searchBar.delegate = self
        
        contactsView.refreshControl
            .publisher(for: .valueChanged)
            .sink { [weak self] _ in
                self?.viewModel.refreshContacts()
            }.store(in: &subscriptions)
        contactsView.refreshControl
            .publisher(for: .valueChanged)
            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.contactsView.refreshControl.endRefreshing()
            }.store(in: &subscriptions)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return CustomTableViewHeader(text: self.frc?.sections?[section].name ?? "-",
                                     textSize: 18,
                                     textColor: ._textPrimary,
                                     fontName: .MontserratSemiBold,
                                     alignment: .left,
                                     labelMargins: UIEdgeInsets(top: 8, left: 18, bottom: 8, right: 14))
    }
}

extension ContactsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        frc?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.frc?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.reuseIdentifier, for: indexPath) as? ContactsTableViewCell
        guard let userEntity = frc?.object(at: indexPath) else {
            return EmptyTableViewCell()
        }
        let user = User(entity: userEntity)
        cell?.configureCell(title: user.getDisplayName(),
                            description: user.telephoneNumber,
                            leftImage: user.avatarFileId?.fullFilePathFromId(),
                            type: .normal)
        return cell ?? EmptyTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("t: ", indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        guard let userEntity = frc?.object(at: indexPath) else { return }
        let user = User(entity: userEntity)
        viewModel.showDetailsScreen(user: user)
    }
}

// MARK: - Search bar
extension ContactsViewController: SearchBarDelegate {
    func searchBar(_ searchBar: SearchBar, valueDidChange value: String?) {
        if let value = value {
            changePredicate(to: value)
        }
    }
    
    func searchBar(_ searchBar: SearchBar, didPressCancel value: Bool) {
        changePredicate(to: "")
    }
    
    func changePredicate(to newString: String) {
        self.frc?.fetchRequest.predicate = newString.isEmpty
        ? nil : NSPredicate(format: "contactsName CONTAINS[c] '\(newString)' OR telephoneNumber CONTAINS[c] '\(newString)'")
        // TODO: better search, begins or something like that
        try? self.frc?.performFetch()
        self.contactsView.tableView.reloadData()
    }
}

// MARK: - NSFetchedResultsController

extension ContactsViewController: NSFetchedResultsControllerDelegate {
    
    func setFetch() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let fetchRequest = UserEntity.fetchRequest()
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "contactsName", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:))),
                NSSortDescriptor(key: #keyPath(UserEntity.displayName), ascending: true)]
            self.frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.viewModel.repository.getMainContext(), sectionNameKeyPath: "sectionName", cacheName: nil)
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
        DispatchQueue.main.async { [weak self] in
            self?.contactsView.tableView.reloadData()
        }
    }
}

