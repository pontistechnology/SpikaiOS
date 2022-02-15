//
//  ChatSearchViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation

class ChatSearchViewController: BaseViewController {
    
    private let chatSearchView = ChatSearchView()
    var viewModel: ChatSearchViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(chatSearchView)
        setupBindings()
        navigationItem.title = "Chat Search"
    }
    
    func setupBindings() {
        
    }
}
