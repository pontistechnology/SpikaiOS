//
//  ContactsViewController.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit
import Combine

class ContactsViewController: BaseViewController {
    
    private let contactsView = ContactsView()
    var viewModel: ContactsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(contactsView)
        setupBindings()
        
        self.viewModel.getChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    var testC = 0
    
    func setupBindings() {
        contactsView.tableView.dataSource = self
        contactsView.tableView.delegate   = self
        contactsView.searchBar.delegate = self
        
        contactsView.titleLabel.tap().sink { tap in
            PopUpManager.shared.presentAlert(.copy)
            
        }.store(in: &subscriptions)
        
        //TODO: delete this cooments
//        contactsView.detailsButton.tap().sink { _ in
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
        
        viewModel.chatsSubject
            .receive(on: DispatchQueue.main)
            .sink { chats in
                print(chats)
            }.store(in: &subscriptions)
        
        viewModel.contactsSubject.receive(on: DispatchQueue.main).sink { contacts in
            self.contactsView.tableView.reloadData()
        }.store(in: &subscriptions)
        
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

