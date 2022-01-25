//
//  EnterUsernameViewController.swift
//  Spika
//
//  Created by Nikola Barbarić on 25.01.2022..
//

import Foundation

class EnterUsernameViewController: BaseViewController {
    
    private let enterUsernameView = EnterUsernameView()
    var viewModel: EnterUsernameViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView(enterUsernameView)
        setupBindings()
    }
    
    func setupBindings() {
        
    }
    
}
