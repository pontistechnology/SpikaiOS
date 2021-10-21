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
    
    func setupBindings() {
        contactsView.detailsButton.publisher(for: .touchUpInside).sink { _ in
            self.viewModel.showDetailsScreen(id: 3)
    //        viewModel.createChat(name: "first chat", type: "group", id: 1)
    //        let user1 = User(loginName: "Marko", avatarUrl: nil, localName: "Marko", id: 1, blocked: false)
    //        viewModel.repository.saveUser(user1)
    //        let chat = Chat(name: "first chat", id: 1, type: "group")
    //        let message = Message(chat: chat, user: user1, message: "SecondMEssage", id: 1)
    //        viewModel.saveMessage(message: message)
    //        viewModel.getUsersForChat(chat: chat)
    //        viewModel.getMessagesForChat(chat: chat)
        }.store(in: &subscriptions)
        
        viewModel.chatsSubject
            .receive(on: DispatchQueue.main)
            .sink { chats in
                print(chats)
            }.store(in: &subscriptions)
    }
    
}
