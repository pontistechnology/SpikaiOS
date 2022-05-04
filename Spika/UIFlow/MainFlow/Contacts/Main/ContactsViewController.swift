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
        
        //TODO: check this cooments
//        contactsView.detailsButton.tap().sink { [weak self] _ in
//        guard let self = self else { return }
//            self.viewModel.showDetailsScreen(id: 3)
    //        viewModel.createChat(name: "first chat", type: "group", id: 1)
    //        let user1 = User(loginName: "Marko", avatarUrl: nil, localName: "Marko", id: 1, blocked: false)
    //        viewModel.repository.saveUser(user1)
    //        let chat = Chat(name: "first chat", id: 1, type: "group")
    //        let message = Message(chat: chat, user: user1, message: "SecondMEssage", id: 1)
    //        viewModel.saveMessage(message: message)
    //        viewModel.getUsersForChat(chat: chat)
    //        viewModel.getMessagesForChat(chat: chat)
//        }.store(in: &subscriptions)
        
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
//            fetchRequest.predicate = NSPredicate(format: "%K == %d", #keyPath(MessageEntity.roomId), room.id)
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
    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        currentPrivateChatView.messagesTableView.beginUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        print("TYPE: ", type.rawValue)
//        switch type {
//        case .insert:
//            guard let newIndexPath = newIndexPath else {
//                return
//            }
//            currentPrivateChatView.messagesTableView.insertRows(at: [newIndexPath], with: .fade)
//
//        case .delete:
//            guard let indexPath = indexPath else {
//                return
//            }
//            currentPrivateChatView.messagesTableView.deleteRows(at: [indexPath], with: .left)
//        case .move:
//            guard let indexPath = indexPath,
//                  let newIndexPath = newIndexPath
//            else {
//                return
//            }
//            currentPrivateChatView.messagesTableView.moveRow(at: indexPath, to: newIndexPath)
//
//        case .update:
//            guard let indexPath = indexPath else {
//                return
//            }
////            currentPrivateChatView.messagesTableView.deleteRows(at: [indexPath], with: .left)
////            currentPrivateChatView.messagesTableView.insertRows(at: [newIndexPath!], with: .left)
//
//            currentPrivateChatView.messagesTableView.reloadRows(at: [indexPath], with: .fade)
//
////            let cell = currentPrivateChatView.messagesTableView.cellForRow(at: indexPath) as? TextMessageTableViewCell
////            let entity = frc?.object(at: indexPath)
////            let message = Message(messageEntity: entity!)
////            cell?.updateCell(message: message)
//            break
//        default:
//            break
//        }
//    }
//
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        currentPrivateChatView.messagesTableView.endUpdates()
//        currentPrivateChatView.messagesTableView.scrollToBottom()
        self.viewModel.updateUsersFromFrc(controller.fetchedObjects! as! [UserEntity])
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
//        print("snapshot begi: ", snapshot)
//        currentPrivateChatView.messagesTableView.reloadData()
//        currentPrivateChatView.messagesTableView.scrollToBottom()
        self.viewModel.updateUsersFromFrc(controller.fetchedObjects! as! [UserEntity])
    }
}

