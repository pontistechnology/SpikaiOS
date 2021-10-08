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
        self.viewModel.getPosts()
    }
    
    func setupBindings() {
        let detailsTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDetailsButtonTap(_:)))
        homeView.detailsButton.addGestureRecognizer(detailsTap)
    }
    
    @objc func handleDetailsButtonTap(_ sender: UITapGestureRecognizer? = nil) {
        self.viewModel.showDetailsScreen(id: 3)
    }
    
}
