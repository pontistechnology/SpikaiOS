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
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    private func setupBindings() {
       
    }
    
    
    deinit {
        print("DetailsViewController deinit")
    }
    
}
