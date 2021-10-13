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
        viewModel.createChat(name: "third chat", type: "group", id: 3)
    }
    
}
