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
    }
    
    private func setupBindings() {
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseButtonTap(_:)))
        detailsView.closeButton.addGestureRecognizer(closeTap)
    }
    
    @objc func handleCloseButtonTap(_ sender: UITapGestureRecognizer? = nil) {
        self.viewModel.closeDetialsScreen()
    }
    
    deinit {
        print("DetailsViewController deinit")
    }
    
}
