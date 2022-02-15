//
//  FavoritesViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation

class FavoritesViewController: BaseViewController {
    
    private let favoritesView = FavoritesView()
    var viewModel: FavoritesViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(favoritesView)
        setupBindings()
        navigationItem.title = "Favorites"
    }
    
    func setupBindings() {
        
    }
}
