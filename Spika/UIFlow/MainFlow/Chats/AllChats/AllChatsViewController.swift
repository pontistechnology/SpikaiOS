//
//  ChatsViewController.swift
//  Spika
//
//  Created by Marko on 21.10.2021..
//

import UIKit

class AllChatsViewController: BaseViewController {
    
    private let allChatsView = AllChatsView()
    var viewModel: AllChatsViewModel!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(allChatsView)
        setupBindings()
    }
    
    func setupBindings() {
        allChatsView.pencilImageView.tap().sink { [weak self] _ in
            self?.viewModel.presentNewChatScreen()
        }.store(in: &subscriptions)
    }
    
}
