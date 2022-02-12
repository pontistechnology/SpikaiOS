//
//  SharedViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 11.02.2022..
//

import Foundation

class SharedViewController: BaseViewController {
    
    private let sharedView = SharedView()
    var viewModel: SharedViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(sharedView)
        setupBindings()
    }
    
    func setupBindings() {
        
    }
}
