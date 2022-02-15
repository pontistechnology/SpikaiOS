//
//  DetailsViewController.swift
//  Spika
//
//  Created by Marko on 08.10.2021..
//

import UIKit

class DetailsViewController: BaseViewController {
    
    private let detailsView = DetailsView()
    var viewModel: DetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(detailsView)
        setupBindings()
        navigationItem.title = "detailll"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    private func setupBindings() {
        detailsView.contentView.sharedMediaOptionButton.tap().sink { [weak self] _ in
            self?.viewModel.presentSharedScreen()
        }.store(in: &subscriptions)
        
        detailsView.contentView.chatSearchOptionButton.tap().sink { [weak self] _ in
            self?.viewModel.presentChatSearchScreen()
        }.store(in: &subscriptions)
        
        detailsView.contentView.favoriteMessagesOptionButton.tap().sink { [weak self] _ in
            self?.viewModel.presentFavoritesScreen()
        }.store(in: &subscriptions)
        
        detailsView.contentView.notesOptionButton.tap().sink { [weak self] _ in
            self?.viewModel.presentNotesScreen()
        }.store(in: &subscriptions)
        
        detailsView.contentView.callHistoryOptionButton.tap().sink { [weak self] _ in
            self?.viewModel.presentCallHistoryScreen()
        }.store(in: &subscriptions)
    }
    
    
    deinit {
        print("DetailsViewController deinit")
    }
    
}
