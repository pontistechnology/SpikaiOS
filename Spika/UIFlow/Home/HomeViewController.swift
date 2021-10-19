//
//  HomeViewController.swift
//  Spika
//
//  Created by Marko on 06.10.2021..
//

import UIKit
import Combine

class HomeViewController: BaseViewController {
    
    private let homeView = HomeView()
    var viewModel: HomeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(homeView)
        setupBindings()
        //self.viewModel.getPosts()
        self.viewModel.getChats()
        //self.viewModel.getUsers()
    }
    
    func setupBindings() {
        let detailsTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDetailsButtonTap(_:)))
        homeView.detailsButton.addGestureRecognizer(detailsTap)
        
        viewModel.chatsSubject
            .receive(on: DispatchQueue.main)
            .sink { chats in
                print(chats)
            }.store(in: &subscriptions)
    }
    
    @objc func handleDetailsButtonTap(_ sender: UITapGestureRecognizer? = nil) {
        //self.viewModel.showDetailsScreen(id: 3)
//        viewModel.createChat(name: "first chat", type: "group", id: 1)
//        viewModel.createChat(name: "second chat", type: "group", id: 2)
//        viewModel.createChat(name: "third chat", type: "group", id: 3)
        
//        let user1 = User(loginName: "Marko", avatarUrl: nil, localName: "Marko", id: 1, blocked: false)
//        viewModel.repository.saveUser(user1)
//        viewModel.repository.saveUser(User(loginName: "Mirko", localName: "Mirko"))
//        viewModel.repository.saveUser(User(loginName: "Ivan", localName: "Ivan"))
        
        let chat = Chat(name: "first chat", id: 1, type: "group")

//        let message = Message(chat: chat, user: user1, message: "SecondMEssage", id: 1)
//        viewModel.saveMessage(message: message)
//
//        viewModel.getUsersForChat(chat: chat)
        viewModel.getMessagesForChat(chat: chat)
    }
    
}
